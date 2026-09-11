import BeautyCore
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautyDetection
@_spi(Testing) import BeautySDK

final class BeautyEngineMouthLifecycleTests: XCTestCase {
    private enum Stage: String, Error {
        case source = "P94N_STAGE_SOURCE", detect = "P94N_STAGE_DETECT"
        case result = "P94N_STAGE_RESULT", legacy = "P94N_STAGE_LEGACY"
        case extract = "P94N_STAGE_EXTRACT", metric = "P94N_STAGE_METRIC"
    }
    private var row = "source"
    private var orientationID = "up"
    private func check(_ value: Bool, _ marker: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(value, marker + " row=" + row + " orientation=" + orientationID, file: file, line: line)
    }
    private func run(_ action: () throws -> Void) {
        do { try action() }
        catch let stage as Stage { XCTFail(stage.rawValue + " row=" + row + " orientation=" + orientationID) }
        catch { XCTFail("P94N_STAGE_METRIC") }
    }
    private func at<T>(_ stage: Stage, _ action: () throws -> T) throws -> T {
        do { return try action() }
        catch let known as Stage { throw known }
        catch { throw stage }
    }
    private func label(_ sign: Float) { row = sign < 0 ? "mouthWidth_minus0p35" : "mouthWidth_plus0p35" }
    private func engine(_ provider: SDKTestingFaceDetectionProvider) throws -> BeautyEngine {
        try at(.detect) { try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: provider) }
    }

    func testNeutralCapsExtentAndDeterminism() {
        run {
            let original = try at(.source) { try MouthRepairFixture.image() }
            for image in [original, original.transformed(by: CGAffineTransform(translationX: 13,y: 17))] {
                let source = try extract(image, extent: image.extent, geometry: false)
                check(image.extent.size == CGSize(width: 640,height: 800), "P94N_META_EXTENT")
                for zero: Float in [0,.nan,.infinity,-.infinity] {
                    row = "geometryBaseline_noop"
                    let neutral = try repeated(image, metadata: MouthRepairFixture.metadata(), width: zero, active: false)
                    check(neutral.bytes == source, "P94N_META_REPEAT")
                }
                for sign: Float in [-1,1] {
                    label(sign)
                    let cap = try repeated(image, metadata: MouthRepairFixture.metadata(), width: sign * 0.35)
                    let overflow = try repeated(image, metadata: MouthRepairFixture.metadata(), width: sign)
                    check(cap.bytes == overflow.bytes, "P94N_META_CAP")
                    check(cap.result.metrics["beauty.effects.cappedCount"] == 0, "P94N_META_CAP")
                    check(overflow.result.metrics["beauty.effects.cappedCount"] == 1, "P94N_META_CAP")
                    check(overflow.result.warnings.contains { $0.code == "beauty_strength_capped" }, "P94N_META_CAP")
                }
            }
        }
    }

    func testOrientationEncodingsPreserveRawContract() {
        run {
            let image = try at(.source) { try MouthRepairFixture.image() }
            let source = MouthRepairFixture.source()
            let pairs: [(String,CGImagePropertyOrientation,CGImagePropertyOrientation,Bool)] = [
                ("up",.up,.up,false), ("upMirrored",.upMirrored,.upMirrored,false),
                ("down",.down,.down,false), ("downMirrored",.downMirrored,.downMirrored,false),
                ("leftMirrored",.leftMirrored,.leftMirrored,true), ("right",.right,.left,true),
                ("rightMirrored",.rightMirrored,.rightMirrored,true), ("left",.left,.right,true)
            ]
            for (name,orientation,inverse,swapped) in pairs {
                orientationID = name
                let encoded = image.oriented(inverse)
                let expected = CGRect(x: 0,y: 0,width: swapped ? 800 : 640,height: swapped ? 640 : 800)
                check(encoded.extent == expected, "P94N_META_ORIENTATION")
                let decoded = encoded.oriented(orientation)
                let roundtrip = try extract(decoded, extent: image.extent, geometry: false)
                check(roundtrip == source, "P94N_META_ORIENTATION")
                let metadata = BeautyInputMetadata(orientation: orientation, source: .testFixture)
                row = "geometryBaseline_noop"
                let neutral = try repeated(encoded, metadata: metadata, width: 0, active: false, repeats: 1)
                let encodedSource = try extract(encoded, extent: expected, geometry: false)
                check(neutral.bytes == encodedSource, "P94N_META_ORIENTATION")
                for sign: Float in [-1,1] {
                    label(sign)
                    _ = try repeated(encoded, metadata: metadata, width: sign * 0.35)
                }
            }
            // The raw facade retains encoded orientation. No fixed canonical
            // ROI or contraction claim is made for the other seven encodings.
        }
    }

    func testMirrorPoliciesUseMappedSourceSupport() {
        run {
            orientationID = "up"
            let image = try at(.source) { try MouthRepairFixture.image() }
            for input in [false,true] {
                for sign: Float in [-1,1] {
                    label(sign)
                    var unmirroredPreview: Processed?
                    for preview in [false,true] {
                        let metadata = BeautyInputMetadata(orientation: .up, isInputMirrored: input,
                                                           isPreviewMirrored: preview, source: .testFixture)
                        let mapper = CoordinateMapper(metadata: metadata, imageExtent: image.extent.size,
                                                      previewExtent: image.extent.size)
                        // Asymmetric source coordinate and rectangle distinguish
                        // input mirroring from preview-only presentation.
                        let mapped = try at(.metric) {
                            try mapper.map(point: CoordinatePoint(x: 0.25,y: 0.75), from: .visionNormalized, to: .imageNormalized)
                        }
                        check(abs(mapped.x - (input ? 0.75 : 0.25)) < 1e-12 && abs(mapped.y - 0.25) < 1e-12,
                              "P94N_META_MIRROR")
                        let rectangle = try at(.metric) {
                            try mapper.map(rect: CoordinateRect(x: 0.20,y: 0.30,width: 0.25,height: 0.20),
                                           from: .visionNormalized, to: .imageNormalized)
                        }
                        check(abs(rectangle.x - (input ? 0.55 : 0.20)) < 1e-12 && abs(rectangle.y - 0.50) < 1e-12,
                              "P94N_META_MIRROR")
                        check(abs(rectangle.width - 0.25) < 1e-12 && abs(rectangle.height - 0.20) < 1e-12,
                              "P94N_META_MIRROR")
                        let presentation = try at(.metric) {
                            try mapper.map(point: mapped, from: .imageNormalized, to: .mirroredPreview)
                        }
                        check(abs(presentation.x - (preview ? 1-mapped.x : mapped.x)*640) < 1e-9
                              && abs(presentation.y - mapped.y*800) < 1e-9, "P94N_META_MIRROR")
                        let current = try result(image, metadata: metadata, width: sign*0.35, active: true)
                        let repeated = try result(image, metadata: metadata, width: sign*0.35, active: true)
                        same(current,repeated)
                        if let first = unmirroredPreview {
                            check(current.bytes == first.bytes, "P94N_META_MIRROR")
                            check(current.result.metrics == first.result.metrics, "P94N_META_MIRROR")
                        } else { unmirroredPreview = current }
                    }
                }
            }
        }
    }

    func testRejectedSupportResetRecoveryIsSourceSafe() {
        run {
            orientationID = "up"
            let image = try at(.source) { try MouthRepairFixture.image() }
            let source = MouthRepairFixture.source()
            for missing: SDKTestingFaceDetectionFixture in [.phase94MouthPortraitMissingOuterLips,.noFace] {
                let reasons: [DetectionDegradationReason] = missing == .noFace ? [.noFaceDetected] : [.missingLandmarks]
                for sign: Float in [-1,1] {
                    label(sign)
                    let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait,missing,.phase94MouthPortrait])
                    let currentEngine = try engine(provider)
                    func request() throws -> BeautyResult<CIImage> {
                        try at(.result) {
                            try currentEngine.processResult(image: image, metadata: MouthRepairFixture.metadata(),
                                                            parameters: .init(mouthWidth: sign*0.35))
                        }
                    }
                    let first = try request()
                    check(provider.invocationCount == 1 && currentEngine.resetCountForTesting == 0, "P94N_META_RECOVERY")
                    currentEngine.reset()
                    let rejected = try request()
                    check(provider.invocationCount == 2 && currentEngine.resetCountForTesting == 1, "P94N_META_RECOVERY")
                    currentEngine.reset()
                    let recovered = try request()
                    check(provider.invocationCount == 3 && currentEngine.resetCountForTesting == 2, "P94N_META_RECOVERY")
                    let firstBytes = try extract(first.output, extent: image.extent, geometry: true)
                    let rejectedBytes = try extract(rejected.output, extent: image.extent, geometry: false)
                    let recoveredBytes = try extract(recovered.output, extent: image.extent, geometry: true)
                    check(rejectedBytes == source, "P94N_META_RECOVERY")
                    same(Processed(result: first,bytes: firstBytes), Processed(result: recovered,bytes: recoveredBytes))
                    redacted(first,reasons: []); redacted(rejected,reasons: reasons); redacted(recovered,reasons: [])
                    check(first.detectionSummary?.availability == .usable && recovered.detectionSummary?.availability == .usable,
                          "P94N_META_RECOVERY")
                    check(rejected.detectionSummary?.usedFaceCount == 0, "P94N_META_RECOVERY")
                    check(rejected.metrics["beauty.effects.activeCount"] == 0
                          && (rejected.metrics["beauty.effects.geometryPointCount"] ?? 0) == 0, "P94N_META_RECOVERY")
                    check(!rejected.warnings.isEmpty, "P94N_META_REASONS")
                }
            }
        }
    }

    private struct Processed {
        let result: BeautyResult<CIImage>
        let bytes: [UInt8]
    }
    private func result(_ image: CIImage, metadata: BeautyInputMetadata, width: Float, active: Bool) throws -> Processed {
        let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
        let currentEngine = try engine(provider)
        let output = try at(.result) {
            try currentEngine.processResult(image: image, metadata: metadata, parameters: .init(mouthWidth: width))
        }
        check(provider.invocationCount == (active ? 1 : 0), "P94N_STAGE_DETECT")
        check(output.detectionSummary?.availability == (active ? .usable : .notRun), "P94N_META_REASONS")
        redacted(output,reasons: [])
        return try Processed(result: output, bytes: extract(output.output, extent: image.extent, geometry: active))
    }
    private func repeated(_ image: CIImage, metadata: BeautyInputMetadata, width: Float,
                          active: Bool = true, repeats: Int = 2) throws -> Processed {
        var first: Processed?
        for _ in 0..<repeats {
            let current = try result(image, metadata: metadata, width: width, active: active)
            let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let oldEngine = try engine(provider)
            let legacy = try at(.legacy) {
                try oldEngine.process(image: image, orientation: metadata.orientation, parameters: .init(mouthWidth: width))
            }
            let legacyBytes = try extract(legacy, extent: image.extent, geometry: active)
            check(provider.invocationCount == (active ? 1 : 0), "P94N_STAGE_DETECT")
            check(current.bytes == legacyBytes, "P94N_META_REPEAT")
            if let previous = first { same(previous,current) } else { first = current }
        }
        guard let first else { throw Stage.result }
        return first
    }
    private func same(_ a: Processed, _ b: Processed) {
        check(a.bytes == b.bytes && a.result.metrics == b.result.metrics && a.result.warnings == b.result.warnings,
              "P94N_META_REPEAT")
        check(a.result.detectionSummary?.availability == b.result.detectionSummary?.availability
              && a.result.detectionSummary?.reasons == b.result.detectionSummary?.reasons, "P94N_META_REPEAT")
        check(a.result.detectionSummary?.faceCount == b.result.detectionSummary?.faceCount
              && a.result.detectionSummary?.usedFaceCount == b.result.detectionSummary?.usedFaceCount, "P94N_META_REPEAT")
    }
    private func redacted(_ result: BeautyResult<CIImage>, reasons: [DetectionDegradationReason]) {
        check(result.detectionSummary?.reasons == reasons, "P94N_META_REASONS")
        check(result.metrics.values.allSatisfy { $0.isFinite }, "P94N_META_REASONS")
        let text = (result.warnings.map { $0.code+" "+$0.message } + Array(result.metrics.keys)).joined(separator: " ").lowercased()
        let forbidden = ["landmark","coordinate","controlpoint","control point","simd","mask","raw","pixel",
                         "image bytes","transcript","path","/private/","file://"]
        check(forbidden.allSatisfy { !text.contains($0) }, "P94N_META_REASONS")
    }
    private func extract(_ image: CIImage, extent: CGRect, geometry: Bool) throws -> [UInt8] {
        try at(.extract) {
            check(image.extent == extent && image.extent == image.extent.integral, "P94N_META_EXTENT")
            guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else { throw Stage.extract }
            let expected = geometry ? CGColorSpaceCreateDeviceRGB() : sRGB
            if let actual = image.colorSpace {
                check(actual.model == expected.model && actual.name == expected.name
                      && actual.numberOfComponents == expected.numberOfComponents && CFEqual(actual,expected), "P94N_META_COLOR")
            } else { check(false,"P94N_META_COLOR") }
            let width = Int(extent.width), height = Int(extent.height)
            guard width > 0 && height > 0 && width*height == 640*800 else { throw Stage.extract }
            var bytes = [UInt8](repeating: 0,count: width*height*4)
            let context = CIContext(options: [.workingColorSpace:sRGB,.outputColorSpace:sRGB])
            bytes.withUnsafeMutableBytes { buffer in
                context.render(image,toBitmap: buffer.baseAddress!,rowBytes: width*4,bounds: extent,format: .RGBA8,colorSpace: sRGB)
            }
            var opaque = true
            for i in stride(from: 3,to: bytes.count,by: 4) {
                if bytes[i] != 255 { opaque = false; break }
            }
            check(opaque,"P94N_META_ALPHA")
            return bytes
        }
    }
}
