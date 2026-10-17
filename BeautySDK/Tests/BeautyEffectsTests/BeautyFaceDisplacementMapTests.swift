import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic source-texture, inverse and stage-ownership checks. These tests
/// do not claim perceptual agreement with the reference photographs.
final class BeautyFaceDisplacementMapTests: XCTestCase {
    private let width = 240
    private let height = 320
    private let eyeDistance = 40.0
    private let origin = SIMD2<Double>(120, 100)

    private func pixel(_ local: SIMD2<Double>, angle: Double = 0,
                       offset: SIMD2<Double> = .zero) -> SIMD2<Double> {
        let x = SIMD2(cos(angle), sin(angle)), y = SIMD2(-sin(angle), cos(angle))
        return origin + offset + eyeDistance * (x * local.x + y * local.y)
    }

    private func face(angle: Double = 0, offset: SIMD2<Double> = .zero,
                      freshness: LandmarkGeometryFreshness = .fresh,
                      observedEyes: Bool = true, observedMouth: Bool = true,
                      observedNose: Bool = true, invalidContour: Bool = false) -> FaceGeometry {
        func normalized(_ p: SIMD2<Double>) -> SIMD2<Float> {
            let image = pixel(p, angle: angle, offset: offset)
            return SIMD2(Float((image.x + 0.5) / Double(width)),
                         Float((image.y + 0.5) / Double(height)))
        }
        func box(_ center: SIMD2<Double>, _ radius: SIMD2<Double>) -> [SIMD2<Float>] {
            [center + SIMD2(-radius.x, -radius.y), center + SIMD2(radius.x, -radius.y),
             center + SIMD2(radius.x, radius.y), center + SIMD2(-radius.x, radius.y)].map(normalized)
        }
        var contour = (0..<21).map { index in
            let angle = Double(index) / 20 * Double.pi
            return normalized(SIMD2(-1.10 * cos(angle), 1.80 * sin(angle)))
        }
        if invalidContour { contour.swapAt(3, 16) }
        func eye(_ side: BeautyObservedEyeSide, _ center: SIMD2<Double>) -> BeautyEyeSemanticSupport {
            let path = box(center, SIMD2(0.22, 0.085))
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)),
                inner: [path[0]], outer: [path[1]], corners: [path[0], path[1]],
                center: normalized(center), pupil: normalized(center),
                span: SIMD2(0.074, 0.025), tilt: 0)
        }
        let left = eye(.left, SIMD2(-0.5, 0)), right = eye(.right, SIMD2(0.5, 0))
        let lips = box(SIMD2(0, 1.10), SIMD2(0.30, 0.08))
        func coordinate(_ p: SIMD2<Double>) -> CoordinatePoint {
            let n = normalized(p)
            return CoordinatePoint(x: Double(n.x), y: Double(n.y))
        }
        let nose = BeautyObservedNoseSupport(
            crest: [SIMD2(0.0, 0.20), SIMD2(0, 0.40), SIMD2(0, 0.65)].map(coordinate),
            contour: [SIMD2(-0.2, 0.65), SIMD2(0, 0.75), SIMD2(0.2, 0.65)].map(coordinate))
        return FaceGeometry(bounds: FaceBounds(x: 0.25, y: 0.20, width: 0.50, height: 0.50),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 10),
            leftEye: left.contour, rightEye: right.contour, outerLips: lips,
            leftEyeSupport: observedEyes ? left : nil, rightEyeSupport: observedEyes ? right : nil,
            freshness: freshness, observedOuterLips: observedMouth ? lips : nil,
            observedNoseSupport: observedNose ? nose : nil)
    }

    private func strengths(width: Float = 0, small: Float = 0,
                           smooth: Float = 0) -> BeautyEffectiveStrengths {
        var result = BeautyEffectiveStrengths()
        result.faceSlim = width; result.faceSmall = small; result.faceContourSmooth = smooth
        return result
    }

    private func map(_ strengths: BeautyEffectiveStrengths, face: FaceGeometry? = nil) throws -> BeautyFaceDisplacementMap {
        try XCTUnwrap(BeautyFaceDisplacementMap(width: width, height: height,
                                              face: face ?? self.face(), strengths: strengths))
    }

    private func stage(_ source: [UInt8], strengths: BeautyEffectiveStrengths,
                       face: FaceGeometry?) -> BeautyStillImageGeometryStage {
        BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: BeautyEffectPlan(effectiveStrengths: strengths), face: face)
    }

    /// R is the source column and G increases downwards around the measured
    /// cheeks/jaw. B gives independently visible texture for byte protection.
    private func texture(mouthMarker: Bool = false) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            result[i] = UInt8(x)
            result[i + 1] = UInt8((y * 3) % 256)
            if mouthMarker {
                let distance = Double((x - 120) * (x - 120) + (y - 144) * (y - 144))
                result[i + 2] = UInt8((240 * exp(-distance / 8)).rounded())
            } else {
                result[i + 2] = UInt8((x * 37 + y * 19) % 256)
            }
            result[i + 3] = 255
        } }
        return result
    }

    private func byte(_ pixels: [UInt8], _ x: Int, _ y: Int, _ channel: Int) -> UInt8 {
        pixels[(y * width + x) * 4 + channel]
    }

    private func assertPatchEqual(_ actual: [UInt8], _ expected: [UInt8], center: SIMD2<Int>,
                                  radius: Int = 1, file: StaticString = #filePath, line: UInt = #line) {
        for y in (center.y - radius)...(center.y + radius) {
            for x in (center.x - radius)...(center.x + radius) {
                let i = (y * width + x) * 4
                XCTAssertEqual(Array(actual[i..<(i + 4)]), Array(expected[i..<(i + 4)]),
                               "pixel (\(x), \(y))", file: file, line: line)
            }
        }
    }

    private func vectorEqual(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                             accuracy: Double = 1e-4, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    private func markerCenter(_ pixels: [UInt8]) throws -> SIMD2<Double> {
        var total = 0.0, weighted = SIMD2<Double>.zero
        for y in 125...153 { for x in 108...132 {
            let weight = Double(byte(pixels, x, y, 2))
            total += weight; weighted += SIMD2(Double(x), Double(y)) * weight
        } }
        XCTAssertGreaterThan(total, 100)
        return weighted / total
    }

    func testFaceWidthRendersCheekInwardAndJawUpwardWithExactNasalCore() throws {
        let map = try self.map(strengths(width: 0.60)), source = texture()
        let output = map.applyRGBA(source)
        // These locations are selected from the source fixture, independently
        // of the map's mode centres or its displacement maximum.
        XCTAssertLessThan(byte(output, 80, 124, 0), byte(source, 80, 124, 0))
        XCTAssertGreaterThan(byte(output, 160, 124, 0), byte(source, 160, 124, 0))
        XCTAssertGreaterThan(byte(output, 93, 156, 1), byte(source, 93, 156, 1))
        XCTAssertGreaterThan(byte(output, 147, 156, 1), byte(source, 147, 156, 1))
        assertPatchEqual(output, source, center: SIMD2(120, 122))
        vectorEqual(map.forwardDisplacement(at: pixel(SIMD2(0, 0.55))), .zero, accuracy: 0)
    }

    func testSmallFaceMovesOriginalMouthMarkerAndChinButPreservesEyeCoreBytes() throws {
        let map = try self.map(strengths(small: 0.45)), source = texture(mouthMarker: true)
        let output = map.applyRGBA(source)
        let before = try markerCenter(source), after = try markerCenter(output)
        XCTAssertLessThan(after.y, before.y - 1)
        XCTAssertEqual(after.x, before.x, accuracy: 0.1)
        let mouth = map.forwardDisplacement(at: SIMD2(120, 144))
        let chin = map.forwardDisplacement(at: SIMD2(120, 172))
        XCTAssertLessThan(mouth.y, -1)
        XCTAssertLessThan(chin.y, mouth.y - 0.5)
        XCTAssertEqual(after.y, before.y + mouth.y, accuracy: 0.5)
        assertPatchEqual(output, source, center: SIMD2(100, 100))
        assertPatchEqual(output, source, center: SIMD2(140, 100))
        vectorEqual(map.forwardDisplacement(at: SIMD2(100, 100)), .zero, accuracy: 0)
        vectorEqual(map.forwardDisplacement(at: SIMD2(140, 100)), .zero, accuracy: 0)
    }

    func testSmoothUsesTwoDimensionalContourMotionWithoutSourceRGBPrepass() throws {
        let requested = strengths(smooth: 0.25), map = try self.map(requested), source = texture()
        let stage = self.stage(source, strengths: requested, face: face())
        let d = map.forwardDisplacement(at: SIMD2(90, 152))
        XCTAssertGreaterThan(d.x, 0)
        XCTAssertLessThan(d.y, -0.05)
        let output = stage.applyingContinuousContour(to: stage.sourceRGBA)
        XCTAssertEqual(stage.sourceRGBA, source)
        XCTAssertEqual(output, map.applyRGBA(source))
        XCTAssertLessThan(byte(output, 90, 152, 0), byte(source, 90, 152, 0))
        XCTAssertGreaterThan(byte(output, 90, 152, 1), byte(source, 90, 152, 1))
        assertPatchEqual(output, source, center: SIMD2(120, 144))
    }

    func testThreeControlsAreOneComposedSourceMapAndNeverExecuteLegacyPoints() throws {
        let requested = strengths(width: 0.60, small: 0.45, smooth: 0.25)
        let source = texture(), face = face(), map = try self.map(requested, face: face)
        let stage = self.stage(source, strengths: requested, face: face)
        let legacy = FaceShapeWarpProvider().fieldEmissions(face: face, strengths: requested)
        // Planning proxies exist, so an empty executable point list is an
        // actual ownership assertion rather than an empty fixture accident.
        XCTAssertFalse(legacy.faceSlim.isEmpty)
        XCTAssertFalse(legacy.faceSmall.isEmpty)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertEqual(stage.sourceRGBA, source)
        XCTAssertEqual(stage.applyingDenseMap(to: source), source)
        let actual = stage.applyingContinuousContour(to: source)
        XCTAssertEqual(actual, map.applyRGBA(source))
        XCTAssertNotEqual(actual, source)
        let serial = try self.map(strengths(smooth: 0.25)).applyRGBA(
            self.map(strengths(small: 0.45)).applyRGBA(
                self.map(strengths(width: 0.60)).applyRGBA(source)))
        XCTAssertNotEqual(actual, serial)
    }

    func testRejectedMissingLegacyStaleAndMalformedGeometryCannotReviveOldPoints() throws {
        let requested = strengths(width: 0.60, small: 0.45, smooth: 0.25), source = texture()
        let invalidFaces: [FaceGeometry?] = [nil, .fixture, face(freshness: .reused),
            face(freshness: .stale), face(observedEyes: false), face(observedMouth: false),
            face(observedNose: false), face(invalidContour: true), face(offset: SIMD2(-100, 0))]
        for invalid in invalidFaces {
            if let invalid {
                XCTAssertNil(BeautyFaceDisplacementMap(width: width, height: height,
                                                       face: invalid, strengths: requested))
            }
            let stage = self.stage(source, strengths: requested, face: invalid)
            XCTAssertTrue(stage.controlPoints.isEmpty)
            XCTAssertEqual(stage.sourceRGBA, source)
            XCTAssertEqual(stage.applyingContinuousContour(to: source), source)
            XCTAssertEqual(stage.applyingDenseMap(to: source), source)
        }
        var malformedStrengths = requested; malformedStrengths.faceSmall = .nan
        XCTAssertNil(BeautyFaceDisplacementMap(width: width, height: height,
                                               face: face(), strengths: malformedStrengths))
        let rejected = self.stage(source, strengths: malformedStrengths, face: face())
        XCTAssertTrue(rejected.controlPoints.isEmpty)
        XCTAssertEqual(rejected.applyingContinuousContour(to: source), source)
    }

    func testNonopaqueAndMalformedRastersRemainByteExactWithoutLegacyFallback() throws {
        let requested = strengths(width: 0.60, small: 0.45, smooth: 0.25)
        let map = try self.map(requested)
        var translucent = texture(); translucent[(140 * width + 120) * 4 + 3] = 127
        for source in [translucent, [UInt8](), [UInt8](repeating: 255, count: 31)] {
            XCTAssertEqual(map.applyRGBA(source), source)
            let stage = self.stage(source, strengths: requested, face: face())
            XCTAssertTrue(stage.controlPoints.isEmpty)
            XCTAssertEqual(stage.sourceRGBA, source)
            XCTAssertEqual(stage.applyingContinuousContour(to: source), source)
        }
    }

    func testCompositionIsRepeatablePreservesExtentAlphaAndAllPeripheralBytes() throws {
        let requested = strengths(width: 0.60, small: 0.45, smooth: 0.25)
        let map = try self.map(requested), source = texture(), output = map.applyRGBA(source)
        XCTAssertEqual(output.count, source.count)
        XCTAssertEqual(output, map.applyRGBA(source))
        XCTAssertEqual(output, try self.map(requested).applyRGBA(source))
        XCTAssertNotEqual(output, source)
        for y in 0..<height { for x in 0..<width {
            XCTAssertEqual(byte(output, x, y, 3), 255)
            if x < 20 || x >= width - 20 || y < 30 || y >= height - 40 {
                let i = (y * width + x) * 4
                XCTAssertEqual(Array(output[i..<(i + 4)]), Array(source[i..<(i + 4)]))
            }
        } }
    }

    func testInverseClosesForwardMotionAcrossPositiveNegativeAndCombinedRequests() throws {
        let requests = [strengths(width: 0.60), strengths(width: -0.60),
            strengths(small: 0.45), strengths(small: -0.45), strengths(smooth: 0.25),
            strengths(width: 0.60, small: 0.45, smooth: 0.25)]
        for requested in requests {
            let map = try self.map(requested)
            XCTAssertLessThan(map.maximumGradient, 1)
            XCTAssertGreaterThan(map.amplitudeScale, 0)
            XCTAssertLessThanOrEqual(map.amplitudeScale, 1)
            var moving = 0, stationary = 0
            for y in stride(from: 80, through: 204, by: 7) {
                for x in stride(from: 48, through: 192, by: 9) {
                    let source = SIMD2(Double(x), Double(y))
                    let d = map.forwardDisplacement(at: source)
                    if hypot(d.x, d.y) > 0.05 { moving += 1 } else { stationary += 1 }
                    let target = source + d
                    let recovered = try XCTUnwrap(map.sourcePoint(for: target))
                    vectorEqual(recovered, source, accuracy: 2e-4)
                    vectorEqual(recovered + map.forwardDisplacement(at: recovered), target, accuracy: 2e-4)
                }
            }
            XCTAssertGreaterThan(moving, 0)
            XCTAssertGreaterThan(stationary, 0)
        }
    }

    func testMapRotatesAndTranslatesWithObservedEyeFrame() throws {
        let requested = strengths(width: 0.60, small: 0.45, smooth: 0.25)
        let angle = 0.27, offset = SIMD2<Double>(8, 12)
        let level = try self.map(requested), rolled = try self.map(requested, face: face(angle: angle, offset: offset))
        for local in [SIMD2(-1.0, 0.60), SIMD2(0.75, 1.30), SIMD2(0, 1.10), SIMD2(0, 1.80)] {
            let a = pixel(local), b = pixel(local, angle: angle, offset: offset)
            let d = level.forwardDisplacement(at: a)
            let rotated = SIMD2(cos(angle) * d.x - sin(angle) * d.y,
                                sin(angle) * d.x + cos(angle) * d.y)
            vectorEqual(rolled.forwardDisplacement(at: b), rotated, accuracy: 2e-4)
            let recovered = try XCTUnwrap(rolled.sourcePoint(for: b + rotated))
            vectorEqual(recovered, b, accuracy: 3e-4)
        }
    }
}
