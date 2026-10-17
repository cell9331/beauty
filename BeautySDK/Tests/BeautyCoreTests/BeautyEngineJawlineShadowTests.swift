import BeautyCore
import BeautyDetection
@testable import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautySDK

/// Mapped source/observation carriers verify the public CPU composition path;
/// they do not claim native-detector, actual-Metal or general skin semantics.
final class BeautyEngineJawlineShadowTests: XCTestCase {
    private let width = 320, height = 400
    private let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    private func points(_ x0: Double, _ x1: Double, _ y0: Double, _ y1: Double) -> [CoordinatePoint] {
        [CoordinatePoint(x: x0, y: y0), CoordinatePoint(x: x1, y: y0),
         CoordinatePoint(x: x1, y: y1), CoordinatePoint(x: x0, y: y1)]
    }
    private func observation(closedBrowTrace: Bool = false, shortEyeContour: Bool = false) -> BeautyFaceObservation {
        let contour = (0...20).map { i -> CoordinatePoint in
            let a = Double(i) / 20 * .pi
            return CoordinatePoint(x: (160 - 100 * cos(a)) / 320, y: (130 + 170 * sin(a)) / 400)
        }
        let nasal = points(0.465, 0.535, 0.42, 0.50)
        func brow(_ x0: Double, _ x1: Double) -> [CoordinatePoint] {
            if closedBrowTrace { return points(x0, x1, 0.27, 0.29) }
            // The production adapter consumes an open eyebrow trace. Preserve
            // the original source envelope while supplying a nonzero chord.
            return [CoordinatePoint(x: x0, y: 0.29),
                    CoordinatePoint(x: x0 + (x1 - x0) / 3, y: 0.27),
                    CoordinatePoint(x: x0 + (x1 - x0) * 2 / 3, y: 0.27),
                    CoordinatePoint(x: x1, y: 0.29)]
        }
        func eye(_ x0: Double, _ x1: Double) -> [CoordinatePoint] {
            let corners = points(x0, x1, 0.3375, 0.3675)
            if shortEyeContour { return corners }
            // Subdivide the same polygon without changing its envelope,
            // area or center. Observed eye evidence requires 6...16 points.
            return corners.indices.flatMap { i -> [CoordinatePoint] in
                let a = corners[i], b = corners[(i + 1) % corners.count]
                return [a, CoordinatePoint(x: (a.x + b.x) * 0.5, y: (a.y + b.y) * 0.5)]
            }
        }
        return BeautyFaceObservation(confidence: 1,
            imageBounds: CoordinateRect(x: 0.18, y: 0.18, width: 0.64, height: 0.60),
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: eye(0.3125, 0.4375)),
                BeautyObservedEyeSupport(side: .right, contour: eye(0.5625, 0.6875))],
            observedEyeOrder: .canonical,
            observedFaceSupport: BeautyObservedFaceSupport(contour: contour, medianLine: [
                CoordinatePoint(x: 0.5, y: 0.35), CoordinatePoint(x: 0.5, y: 0.55), CoordinatePoint(x: 0.5, y: 0.75)]),
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: brow(0.27, 0.43), right: brow(0.57, 0.73)),
            observedLipSupport: BeautyObservedLipSupport(outer: points(0.4125, 0.5875, 0.5875, 0.635)),
            observedNoseSupport: BeautyObservedNoseSupport(crest: nasal, contour: nasal))
    }
    private func engine(noFace: Bool = false, closedBrowTrace: Bool = false, shortEyeContour: Bool = false) throws -> BeautyEngine {
        let observations = noFace ? [] : [observation(closedBrowTrace: closedBrowTrace, shortEyeContour: shortEyeContour)]
        let detector = BeautyFaceDetector(mappedObservationProvider: { _ in BeautyMappedFaceObservations(observations: observations) })
        return try BeautyEngine(faceDetector: detector)
    }
    private func source() -> CIImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let px = Double(x) + 0.5, py = Double(y) + 0.5
            let edge = 130 + 170 * sqrt(max(0, 1 - pow((px - 160) / 100, 2)))
            var rgb = [35.0, 80, 110]
            if (abs(px - 160) <= 100 && py >= 90 && py <= edge) ||
                ((90...230).contains(px) && py >= edge && py < 340) {
                let t = min(1, max(0, (py - edge + 3) / 6))
                let gain = 1 - 0.06 * t * t * (3 - 2 * t)
                rgb = [210, 158, 125].map { Double($0) * gain }
            }
            // A separate foreign native strand crosses the otherwise
            // qualified source neck; it must not authorize its own corridor.
            if (175...176).contains(x) && (280...322).contains(y) { rgb = [28, 24, 20] }
            let p = (y * width + x) * 4
            for c in 0..<3 { bytes[p + c] = UInt8(rgb[c].rounded()) }
        } }
        return CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: cs)
    }
    private func pixels(_ image: CIImage) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.workingColorSpace: cs, .outputColorSpace: cs]).render(image,
            toBitmap: &result, rowBytes: width * 4, bounds: image.extent, format: .RGBA8, colorSpace: cs)
        return result
    }

    func testPublicCPUShadingChangesOnlyUnderJawAndPreservesCurrentColorBaseline() throws {
        // Qualify the mapped carrier itself before exercising public dispatch.
        // These assertions expose which source family is missing without raw
        // point arrays or a misleading inference from changed-pixel counts.
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation())
        XCTAssertEqual(geometry.freshness, .fresh)
        XCTAssertEqual(geometry.bounds.x, Float(0.18))
        XCTAssertEqual(geometry.bounds.y, Float(0.18))
        XCTAssertEqual(geometry.bounds.width, Float(0.64))
        XCTAssertEqual(geometry.bounds.height, Float(0.60))
        XCTAssertEqual(geometry.observedFaceSupport?.contour.count, 21)
        XCTAssertEqual(geometry.observedFaceSupport?.medianLine?.count, 3)
        XCTAssertNotNil(geometry.observedFaceSupport?.apexIndex)
        XCTAssertEqual(geometry.leftEyeSupport?.contour.count, 8)
        XCTAssertEqual(geometry.rightEyeSupport?.contour.count, 8)
        XCTAssertEqual(geometry.leftEye.count, 8)
        XCTAssertEqual(geometry.rightEye.count, 8)
        XCTAssertEqual(geometry.observedEyebrowSupport?.left?.points.count, 4)
        XCTAssertEqual(geometry.observedEyebrowSupport?.right?.points.count, 4)
        XCTAssertEqual(geometry.observedNoseSupport?.crest.count, 4)
        XCTAssertEqual(geometry.observedNoseSupport?.contour.count, 4)
        XCTAssertEqual(geometry.observedOuterLips?.count, 4)
        XCTAssertTrue(BeautyJawlineShadow.hasGeometrySupport(geometry))
        let qualification = BeautyJawlineShadow.assess(sourceRGBA: pixels(source()),
            width: width, height: height, face: geometry)
        XCTAssertNotNil(qualification.evidence, "generated source qualification: \(qualification.refusal?.rawValue ?? "none") \(qualification.aggregates)")
        XCTAssertNil(qualification.refusal)
        let engine = try engine(), image = source(), metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for brightness: Float in [0, 0.10] {
            var base = BeautyParameters(); base.brightness = brightness
            let neutral = try engine.processResult(image: image, metadata: metadata, parameters: base)
            let baseline = pixels(neutral.output)
            var parameters = base; parameters.jawlineShadow = 0.25
            let result = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
            let again = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
            let output = pixels(result.output)
            XCTAssertEqual(result.output.extent, image.extent)
            XCTAssertTrue(output == pixels(again.output))
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertEqual(result.metrics["beauty.effects.jawlineShadow.sourceQualificationDeferred"], 1)
            var changed = 0, protectedChanged = 0, brighter = 0, alphaChanged = 0
            var tailDarkening = 0, tailCount = 0, budgetExceeded = 0
            for y in 0..<height { for x in 0..<width {
                let p = (y * width + x) * 4
                let px = Double(x) + 0.5, py = Double(y) + 0.5
                let jaw = 130 + 170 * sqrt(max(0, 1 - pow((px - 160) / 100, 2)))
                if output[p..<(p + 4)] != baseline[p..<(p + 4)] {
                    changed += 1
                    // Independent analytic source classes: face core,
                    // foreign strand, lower background and neck sides.
                    if py <= jaw || py >= 340 || px < 90 || px >= 230 ||
                        ((175...176).contains(x) && (280...322).contains(y)) { protectedChanged += 1 }
                }
                if output[p + 3] != baseline[p + 3] { alphaChanged += 1 }
                for c in 0..<3 {
                    if output[p + c] > baseline[p + c] { brighter += 1 }
                    if Double(output[p + c]) < Double(baseline[p + c]) * 0.82 - 0.5 { budgetExceeded += 1 }
                }
                if (140...165).contains(px), (20...30).contains(py - jaw) {
                    tailCount += 1; tailDarkening += Int(baseline[p + 1]) - Int(output[p + 1])
                }
            } }
            XCTAssertGreaterThan(changed, 32, "a planned request must actually shade this qualified generated source")
            XCTAssertEqual(protectedChanged, 0); XCTAssertEqual(brighter, 0); XCTAssertEqual(alphaChanged, 0)
            XCTAssertEqual(budgetExceeded, 0)
            XCTAssertGreaterThan(tailCount, 32)
            XCTAssertGreaterThan(Double(tailDarkening) / Double(tailCount), 3,
                "public output must contain the new broad tail on both current-colour baselines")
            XCTAssertTrue(pixels(try engine.processResult(image: image, metadata: metadata, parameters: base).output) == baseline)
        }
    }

    func testPublicNoFaceToneRequestKeepsPixelsAndRecoversWithoutSourceState() throws {
        let engine = try engine(noFace: true), image = source()
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let baseline = pixels(try engine.processResult(image: image, metadata: metadata, parameters: .init()).output)
        let refused = try engine.processResult(image: image, metadata: metadata, parameters: .init(jawlineShadow: 0.25))
        XCTAssertEqual(refused.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertTrue(refused.warnings.contains { $0.code == "jawline_shadow_source_scope_unavailable" })
        XCTAssertTrue(pixels(refused.output) == baseline)
        XCTAssertTrue(pixels(try engine.processResult(image: image, metadata: metadata, parameters: .init()).output) == baseline)
    }

    func testOriginalClosedBrowFixtureRemainsRejectedWithoutFakeActivity() throws {
        let engine = try engine(closedBrowTrace: true, shortEyeContour: true), image = source()
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for brightness: Float in [0, 0.10] {
            var base = BeautyParameters(); base.brightness = brightness
            let baseline = pixels(try engine.processResult(image: image, metadata: metadata, parameters: base).output)
            var requested = base; requested.jawlineShadow = 0.25
            let refused = try engine.processResult(image: image, metadata: metadata, parameters: requested)
            XCTAssertEqual(refused.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertNil(refused.metrics["beauty.effects.jawlineShadow.sourceQualificationDeferred"])
            XCTAssertTrue(refused.warnings.contains { $0.code == "jawline_shadow_source_scope_unavailable" })
            XCTAssertTrue(pixels(refused.output) == baseline,
                "the original rectangle is invalid open-brow support and cannot authorize the tone")
        }
    }

    func testOriginalFourPointEyeCarrierIsRejectedWithoutSyntheticFallback() throws {
        let mapped = observation(shortEyeContour: true)
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: mapped)
        XCTAssertEqual(mapped.observedEyeSupport?.first?.contour.count, 4)
        XCTAssertNil(geometry.leftEyeSupport); XCTAssertNil(geometry.rightEyeSupport)
        XCTAssertTrue(geometry.leftEye.isEmpty); XCTAssertTrue(geometry.rightEye.isEmpty)
        XCTAssertEqual(geometry.observedFaceSupport?.contour.count, 21)
        XCTAssertEqual(geometry.observedEyebrowSupport?.left?.points.count, 4)
        XCTAssertEqual(geometry.observedEyebrowSupport?.right?.points.count, 4)
        XCTAssertEqual(geometry.observedNoseSupport?.crest.count, 4)
        XCTAssertEqual(geometry.observedOuterLips?.count, 4)
        XCTAssertFalse(BeautyJawlineShadow.hasGeometrySupport(geometry))
        let engine = try engine(shortEyeContour: true), image = source()
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for brightness: Float in [0, 0.10] {
            var base = BeautyParameters(); base.brightness = brightness
            let baseline = pixels(try engine.processResult(image: image, metadata: metadata, parameters: base).output)
            var requested = base; requested.jawlineShadow = 0.25
            let refused = try engine.processResult(image: image, metadata: metadata, parameters: requested)
            XCTAssertNil(refused.metrics["beauty.effects.jawlineShadow.sourceQualificationDeferred"])
            XCTAssertTrue(refused.warnings.contains { $0.code == "jawline_shadow_source_scope_unavailable" })
            XCTAssertTrue(pixels(refused.output) == baseline)
        }
    }

}
