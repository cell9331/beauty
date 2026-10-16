import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects
@testable import BeautySDK

/// Internal candidate only. The frozen source semantic annotations are an
/// independent oracle, never an input to the candidate or its admission.
final class BeautyEngineContourTransitionCandidateTests: XCTestCase {
    private let space = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)

    func testSourceFixedNarrowWidthCandidateKeepsEntirePermanentSourceAndExterior() throws {
        let env = ProcessInfo.processInfo.environment
        guard let path = env["BEAUTY_FACE_REFERENCE_INPUT"] else {
            let image = CIImage(color: CIColor(red: 0.4, green: 0.4, blue: 0.4))
                .cropped(to: CGRect(x: 0, y: 0, width: 64, height: 96))
            let result = try BeautyEngine().processResult(image: image, metadata: metadata,
                parameters: BeautyFaceShapeSlider.faceWidth.applying(position: 1, to: .init()))
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
            return
        }
        let output = URL(fileURLWithPath: try XCTUnwrap(env["BEAUTY_FACE_REFERENCE_OUTPUT"]))
        let canonicalizer = BeautyStillImageCanonicalizer()
        let input = try XCTUnwrap(CIImage(contentsOf: URL(fileURLWithPath: path), options: [.applyOrientationProperty: true]))
        let full = try canonicalizer.canonicalize(image: input, metadata: metadata,
            maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
        var records = [[String: Any]]()
        for (id, scale) in [("full", 1.0), ("preview960", min(1, 960 / Double(max(full.width, full.height))))] {
            let image = full.ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
                .cropped(to: CGRect(x: 0, y: 0, width: floor(Double(full.width) * scale), height: floor(Double(full.height) * scale)))
            let raster = try canonicalizer.canonicalize(image: image, metadata: metadata,
                maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
            let width = raster.width, height = raster.height, source = Array(raster.rgba8Data)
            var detector = BeautyFaceDetector.production()
            let detection = detector.detect(image: raster.ciImage, metadata: metadata,
                imageExtent: raster.ciImage.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detection.summary.availability, .usable)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: try XCTUnwrap(detection.observations.first))
            func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height)) }
            func mean(_ p: [SIMD2<Float>]) -> SIMD2<Double> { p.map(pixel).reduce(.zero, +) / Double(p.count) }
            let left = face.leftEyeSupport?.contour ?? face.leftEye
            let right = face.rightEyeSupport?.contour ?? face.rightEye
            let vector = mean(right) - mean(left), axisX = vector / hypot(vector.x, vector.y)
            let axisY = SIMD2(-axisX.y, axisX.x), origin = (mean(left) + mean(right)) * 0.5
            func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
                let q = p - origin
                return SIMD2(q.x * axisX.x + q.y * axisX.y, q.x * axisY.x + q.y * axisY.y)
            }
            let contour = try XCTUnwrap(face.observedFaceSupport).contour.map(pixel)
            let coordinates = contour.map(local)
            let span = coordinates.map(\.x).max()! - coordinates.map(\.x).min()!, chin = coordinates.map(\.y).max()!
            let nasal = try XCTUnwrap(face.observedNoseSupport)
            let noseBottom = (nasal.crest + nasal.contour).map { local(SIMD2($0.x * Double(width), $0.y * Double(height))).y }.max()!
            let scope = try XCTUnwrap(BeautyContourTransitionScope(width: width, height: height,
                contour: contour, origin: origin, axisX: axisX, axisY: axisY, span: span,
                chin: chin, lowerBound: max(chin * 0.32, noseBottom + span * 0.008)))
            let names = ["ears_core", "eyes_core", "brows_core", "nose_core", "lips_core", "hair_core", "crossing_hair_core"]
            let masks = try names.map { try mask($0, width: width, height: height) }
            var permanentOverlap = 0
            for p in 0..<(width * height) where scope.allowsDestination(x: p % width, y: p / width) {
                if masks.prefix(5).contains(where: { $0[p] }) { permanentOverlap += 1 }
            }
            XCTAssertEqual(permanentOverlap, 0, "entire source tube must avoid permanent ears and features BEFORE rendering")
            guard permanentOverlap == 0 else { continue }
            for sign: Float in [-1, 1] { for fraction: Float in [0.25, 0.5, 0.75, 1] {
                var strengths = BeautyEffectiveStrengths()
                strengths.faceSlim = sign * BeautySafetyCaps.faceSlim * fraction
                let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height,
                    face: face, strengths: strengths, sourceRGBA: source, transitionScope: scope))
                let actual = map.applyRGBA(source)
                XCTAssertTrue(actual == map.applyRGBA(source), "candidate deterministic RGBA")
                var outside = 0, permanent = 0, hairBody = 0, alpha = 0, changed = 0
                for p in 0..<(width * height) {
                    let i = p * 4
                    let differs = (0..<4).contains { source[i + $0] != actual[i + $0] }
                    guard differs else { continue }
                    changed += 1
                    let admitted = scope.allowsDestination(x: p % width, y: p / width)
                    if !admitted { outside += 1 }
                    if masks.prefix(5).contains(where: { $0[p] }) { permanent += 1 }
                    if !admitted && (masks[5][p] || masks[6][p]) { hairBody += 1 }
                    if source[i + 3] != actual[i + 3] { alpha += 1 }
                }
                XCTAssertEqual(outside, 0); XCTAssertEqual(permanent, 0)
                XCTAssertEqual(hairBody, 0); XCTAssertEqual(alpha, 0)
                XCTAssertGreaterThan(changed, 16, "no-op is not a useful width candidate")
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement, span * 0.060001)
                let name = "\(id)-width-\(sign < 0 ? "left" : "right")-\(Int(fraction * 100))"
                try save(actual, width: width, height: height, to: output.appendingPathComponent(name + ".png"))
                records.append(["layer": id, "sign": sign, "fraction": fraction,
                    "scopeRadiusSourcePixels": scope.radius, "scopeNormalizedTotalWidth": scope.normalizedWidth,
                    "entireSourcePermanentOverlap": permanentOverlap, "exteriorChangedPixels": outside,
                    "permanentChangedPixels": permanent, "bodyHairChangedPixels": hairBody,
                    "alphaChangedPixels": alpha, "changedPixels": changed,
                    "maximumGradient": map.maximumGradient, "maximumDisplacement": map.maximumDisplacement,
                    "publicDefaultReplaced": false, "referenceAmplitudeQualified": false])
            } }
        }
        let url = output.appendingPathComponent("narrow-transition-candidate-aggregates.json")
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys]).write(to: url)
    }

    private func mask(_ name: String, width: Int, height: Int) throws -> [Bool] {
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let url = package.appendingPathComponent(".build/face-reference/protection-masks-v2/\(name).png")
        let image = try XCTUnwrap(CIImage(contentsOf: url)), w = Int(image.extent.width), h = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: w * h * 4)
        CIContext().render(image, toBitmap: &bytes, rowBytes: w * 4, bounds: image.extent, format: .RGBA8, colorSpace: space)
        return (0..<(width * height)).map { p in
            let x = min(w - 1, Int((Double(p % width) + 0.5) * Double(w) / Double(width)))
            let y = min(h - 1, Int((Double(p / width) + 0.5) * Double(h) / Double(height)))
            return bytes[(y * w + x) * 4] >= 128
        }
    }
    private func save(_ bytes: [UInt8], width: Int, height: Int, to url: URL) throws {
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        let image = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: space)
        let cg = try XCTUnwrap(CIContext().createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: space))
        let target = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(target, cg, nil)
        XCTAssertTrue(CGImageDestinationFinalize(target))
    }
}
