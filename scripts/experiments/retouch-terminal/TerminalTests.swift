import CryptoKit
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK

// Development diagnostics only. Reference data never enters Candidate methods.
final class RetouchTerminalTests: XCTestCase {
    let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    struct Raster {
        var bytes: [UInt8]; let width: Int; let height: Int
        var count: Int { width * height }
        func luma(_ p: Int, eye: Bool = false) -> Double {
            let k = p * 4
            return eye ? (2126 * Double(bytes[k]) + 7152 * Double(bytes[k+1]) + 722 * Double(bytes[k+2])) / 10000
                : (77 * Double(bytes[k]) + 150 * Double(bytes[k+1]) + 29 * Double(bytes[k+2])) / 256
        }
        func image(_ space: CGColorSpace) -> CIImage {
            CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
                    size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: space)
        }
    }
    struct EyePair { let source: Raster; let target: Raster; let rois: [[Int]]; let allowed: Set<Int> }
    struct EyeScore { let improvement: [Double]; let hp: [Double]; let hard: Int; let direction: Bool }
    final class Requests: @unchecked Sendable { var value: [BeautyUpperEyelidSemanticRequest] = [] }
    enum PilotError: Error { case invalidFixture, invalidGeometry }

    func emit(_ row: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
        print("TERMINAL " + String(decoding: data, as: UTF8.self))
    }
    func canonical(_ image: CIImage) throws -> Raster {
        let c = try BeautyStillImageCanonicalizer().canonicalize(image: image, metadata: metadata, maximumPixelCount: 4_000_000)
        return Raster(bytes: Array(c.rgba8Data), width: c.width, height: c.height)
    }
    func fixture(_ name: String) throws -> Raster {
        let root = try XCTUnwrap(ProcessInfo.processInfo.environment["PILOT_FIXTURES"])
        let url = URL(fileURLWithPath: root).appendingPathComponent(name)
        let image = try XCTUnwrap(CIImage(contentsOf: url, options: [.applyOrientationProperty: true]))
        let scale = 1024 / max(image.extent.width, image.extent.height)
        // CI rounds the transformed extent outward; without edge extension a
        // non-square source gains partial-alpha pixels at that rounded boundary.
        let resized = image.clampedToExtent().transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let grid = CGRect(x:0,y:0,width:floor(image.extent.width*scale),height:floor(image.extent.height*scale))
        return try canonical(resized.cropped(to:grid))
    }
    func export(_ image: Raster, _ name: String) throws {
        let root = try XCTUnwrap(ProcessInfo.processInfo.environment["PILOT_REVIEW"])
        try CIContext().writePNGRepresentation(of: image.image(space),
            to: URL(fileURLWithPath: root).appendingPathComponent(name + ".png"), format: .RGBA8, colorSpace: space)
    }
    func requests(_ image: Raster) -> [BeautyUpperEyelidSemanticRequest] {
        var detector = VisionFaceDetector(); let box = Requests()
        _ = detector.detectWithUpperEyelidSupport(image: image.image(space), metadata: metadata,
            imageExtent: CGSize(width: image.width, height: image.height), configuration: BeautyConfiguration(),
            semanticOwner: { input in box.value = input; return [] })
        return box.value
    }
    func eyePair() throws -> EyePair {
        let target = try fixture("upper-eyelid-generated-base.png")
        let detected = requests(target)
        guard detected.count == 2 else { throw PilotError.invalidGeometry }
        var source = target; var rois = [[Int]](); var allowed = Set<Int>()
        for request in detected {
            let e = request.permittedEnvelope
            let cx = (e.minX + e.width / 2) * Double(target.width)
            let cy = (e.minY + e.height / 2) * Double(target.height)
            let rx = e.width * Double(target.width) * 0.45
            let ry = e.height * Double(target.height) * 0.45
            var roi = [Int]()
            for y in 0..<target.height { for x in 0..<target.width {
                let p = y * target.width + x
                let nx = (Double(x)+0.5)/Double(target.width), ny = (Double(y)+0.5)/Double(target.height)
                if nx >= e.minX && nx <= e.minX+e.width && ny >= e.minY && ny <= e.minY+e.height { allowed.insert(p) }
                let r2 = pow((Double(x)+0.5-cx)/rx, 2) + pow((Double(y)+0.5-cy)/ry, 2)
                if r2 < 1 {
                    roi.append(p)
                    let increment = Int((16 * pow(1-r2, 2)).rounded())
                    for c in 0..<3 {
                        let v = Int(source.bytes[p*4+c]) + increment
                        guard v <= 255 else { throw PilotError.invalidFixture }
                        source.bytes[p*4+c] = UInt8(v)
                    }
                }
            }}
            guard !roi.isEmpty else { throw PilotError.invalidFixture }
            let mae = roi.reduce(0.0) { $0 + abs(source.luma($1,eye:true)-target.luma($1,eye:true)) } / Double(roi.count)
            guard mae >= 4 else { throw PilotError.invalidFixture }
            rois.append(roi)
        }
        return EyePair(source: source, target: target, rois: rois, allowed: allowed)
    }
    func highpass(_ image: Raster, _ p: Int) -> Double {
        let x = p % image.width, y = p / image.width
        var mean = 0.0
        for dy in -1...1 { for dx in -1...1 {
            let q = min(image.height-1,max(0,y+dy))*image.width + min(image.width-1,max(0,x+dx))
            mean += image.luma(q,eye:true)/9
        }}
        return image.luma(p,eye:true) - mean
    }
    func eyeScore(_ output: Raster, _ pair: EyePair, _ strength: Double) -> EyeScore {
        var hard = 0; var improvements = [Double](); var hp = [Double]()
        for p in 0..<output.count {
            if output.bytes[p*4+3] != pair.source.bytes[p*4+3] { hard += 1 }
            for c in 0..<3 {
                let delta = Int(output.bytes[p*4+c]) - Int(pair.source.bytes[p*4+c])
                if delta > 0 || delta < -16 || (!pair.allowed.contains(p) && delta != 0) { hard += 1 }
            }
        }
        for roi in pair.rois {
            var before = 0.0, after = 0.0, baseHP = 0.0, deltaHP = 0.0
            for p in roi {
                before += abs(pair.source.luma(p,eye:true)-pair.target.luma(p,eye:true))
                after += abs(output.luma(p,eye:true)-pair.target.luma(p,eye:true))
                let srcHP = highpass(pair.source,p)
                baseHP += abs(srcHP); deltaHP += abs(highpass(output,p)-srcHP)
            }
            improvements.append(1-after/before)
            hp.append(baseHP / Double(roi.count) >= 1 ? deltaHP/baseHP : -1)
        }
        // -1 denotes low-texture, requiring visual review, never a visual pass.
        let direction = improvements.allSatisfy { $0 >= 0.10*strength }
        if hp.contains(where: { $0 > 0.10 }) { hard += 1 }
        return EyeScore(improvement: improvements, hp: hp, hard: hard, direction: direction)
    }
    func testEyeControls() throws {
        let pair = try eyePair()
        // Controls must validate every actual candidate input, including negatives.
        let negative = try fixture("upper-eyelid-negative-control.png")
        XCTAssertEqual(max(negative.width,negative.height),1024)
        XCTAssertEqual(requests(negative).count,2)
        var witness = pair.source
        for k in stride(from:0,to:witness.bytes.count,by:4) { for c in 0..<3 {
            let signal = Int(pair.source.bytes[k+c])-Int(pair.target.bytes[k+c])
            witness.bytes[k+c] = UInt8(Int(pair.source.bytes[k+c])-Int((0.125*Double(signal)).rounded()))
        }}
        let correct = eyeScore(witness,pair,1)
        XCTAssertTrue(correct.direction && correct.hard==0,"eye_correct_control")
        XCTAssertFalse(eyeScore(pair.source,pair,1).direction,"eye_noop_rejection")
        var global = pair.source
        for k in stride(from:0,to:global.bytes.count,by:4) { for c in 0..<3 { global.bytes[k+c] = global.bytes[k+c] > 0 ? global.bytes[k+c]-1 : 0 } }
        XCTAssertGreaterThan(eyeScore(global,pair,1).hard,0,"eye_global_rejection")
        var ring = witness
        for roi in pair.rois {
            for p in roi where abs(Double(p % ring.width)-Double(roi[roi.count/2] % ring.width)) < 2 {
                for c in 0..<3 { ring.bytes[p*4+c] = UInt8(clamping:Int(ring.bytes[p*4+c])-12) }
            }
        }
        XCTAssertFalse(eyeScore(ring,pair,1).direction && eyeScore(ring,pair,1).hard==0,"eye_trough_rejection")
        try export(pair.source,"eye-source"); try export(pair.target,"eye-reference")
        try export(witness,"eye-correct-control"); try export(ring,"eye-wrong-trough")
        emit(["kind":"eye_controls","direction":correct.direction,"hard":correct.hard,
              "improvement":correct.improvement,"hp":correct.hp,"visual":"pending"])
    }
}
