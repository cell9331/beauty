import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Independent source markers and coordinate-encoded rasters exercise sampling
/// and stage ownership. They do not establish likeness to the reference photos.
final class BeautyFaceFiveMapTests: XCTestCase {
    private let width = 240
    private let height = 320
    private let eyeDistance = 50.0
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


    private typealias Control = (WritableKeyPath<BeautyEffectiveStrengths, Float>, Float)
    private var controls: [Control] {
        [(\.templeFullness, BeautySafetyCaps.templeFullness),
         (\.cheekboneSlim, BeautySafetyCaps.cheekboneSlim),
         (\.chinLength, -BeautySafetyCaps.chinLength),
         (\.chinTaper, BeautySafetyCaps.chinTaper),
         (\.faceVShape, BeautySafetyCaps.faceVShape)]
    }

    private func request(_ key: WritableKeyPath<BeautyEffectiveStrengths, Float>,
                         _ amount: Float) -> BeautyEffectiveStrengths {
        var values = BeautyEffectiveStrengths(); values[keyPath: key] = amount
        return values
    }

    private func combined(includeOriginalThree: Bool) -> BeautyEffectiveStrengths {
        var values = BeautyEffectiveStrengths()
        for (key, amount) in controls { values[keyPath: key] = amount }
        if includeOriginalThree {
            values.faceSlim = BeautySafetyCaps.faceSlim
            values.faceSmall = BeautySafetyCaps.faceSmall
            values.faceContourSmooth = BeautySafetyCaps.faceContourSmooth
        }
        return values
    }

    private func map(_ strengths: BeautyEffectiveStrengths, face: FaceGeometry? = nil) throws -> BeautyFaceDisplacementMap {
        try XCTUnwrap(BeautyFaceDisplacementMap(width: width, height: height,
                                              face: face ?? self.face(), strengths: strengths))
    }

    private func stage(_ bytes: [UInt8], strengths: BeautyEffectiveStrengths,
                       face: FaceGeometry) -> BeautyStillImageGeometryStage {
        BeautyStillImageGeometryStage(sourceRGBA: bytes, width: width, height: height,
            plan: BeautyEffectPlan(effectiveStrengths: strengths), face: face)
    }

    /// R/G independently encode source x/y over the face ROI. Blue is either
    /// a localized material marker or high-frequency texture for preservation.
    private func texture(marker: SIMD2<Double>? = nil) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            bytes[i] = UInt8(x)
            bytes[i + 1] = UInt8(clamping: y - 64)
            if let marker {
                let dx = Double(x) - marker.x, dy = Double(y) - marker.y
                bytes[i + 2] = UInt8((240 * exp(-(dx * dx + dy * dy) / 2)).rounded())
            } else {
                bytes[i + 2] = UInt8((x * 47 + y * 23) % 256)
            }
            bytes[i + 3] = 255
        } }
        return bytes
    }

    private func markerCenter(_ bytes: [UInt8], near point: SIMD2<Double>) throws -> SIMD2<Double> {
        let center = SIMD2(Int(point.x.rounded()), Int(point.y.rounded()))
        var total = 0.0, weighted = SIMD2<Double>.zero
        for y in (center.y - 12)...(center.y + 12) {
            for x in (center.x - 12)...(center.x + 12) {
                let weight = Double(bytes[(y * width + x) * 4 + 2])
                total += weight
                weighted += SIMD2(Double(x), Double(y)) * weight
            }
        }
        XCTAssertGreaterThan(total, 200)
        return weighted / total
    }

    private func vectorEqual(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                             accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    private func assertPatchEqual(_ actual: [UInt8], _ expected: [UInt8], at point: SIMD2<Double>,
                                  file: StaticString = #filePath, line: UInt = #line) {
        let center = SIMD2(Int(point.x.rounded()), Int(point.y.rounded()))
        for y in (center.y - 1)...(center.y + 1) { for x in (center.x - 1)...(center.x + 1) {
            let index = (y * width + x) * 4
            XCTAssertEqual(Array(actual[index..<(index + 4)]), Array(expected[index..<(index + 4)]),
                           "pixel (\(x), \(y))", file: file, line: line)
        } }
    }

    func testFiveFieldsMoveActualSourceMarkersWithCorrectTwoComponentSamplingDirection() throws {
        // Source material probes are selected by facial regions, not by searching
        // the estimated field for its strongest or most agreeable locations.
        let probes = [SIMD2(-1.10, -0.05), SIMD2(-1.0, 0.70), SIMD2(0, 1.70),
                      SIMD2(-0.30, 1.73), SIMD2(-0.66, 1.415)]
        for ((key, amount), local) in zip(controls, probes) {
            let requested = request(key, amount), sourcePoint = pixel(local)
            let source = texture(marker: sourcePoint), field = try map(requested)
            let output = field.applyRGBA(source)
            let before = try markerCenter(source, near: sourcePoint)
            let after = try markerCenter(output, near: sourcePoint)
            let measured = after - before
            let forward = field.forwardDisplacement(at: before)
            XCTAssertLessThan(measured.y, -0.04, "\(key)")
            if key == \.templeFullness { XCTAssertLessThan(measured.x, -0.04) }
            else if key == \.chinLength { XCTAssertEqual(measured.x, 0, accuracy: 0.05) }
            else { XCTAssertGreaterThan(measured.x, 0.025) }
            // The source centroid is an independent raster observation. This
            // also rejects applying the forward map as a backward sampler.
            vectorEqual(measured, forward, accuracy: 0.35)
            let restored = try XCTUnwrap(field.sourcePoint(for: sourcePoint + forward))
            vectorEqual(restored, sourcePoint, accuracy: 0.002)
            let stage = self.stage(source, strengths: requested, face: face())
            XCTAssertTrue(stage.controlPoints.isEmpty)
            XCTAssertEqual(stage.sourceRGBA, source)
            XCTAssertEqual(stage.applyingContinuousContour(to: source), output)
        }
    }

    func testFiveAndEightFieldsUseOneOriginalCoordinateSampleAndNeverLegacyPoints() throws {
        let source = texture(), face = face()
        for includeOriginalThree in [false, true] {
            let requested = combined(includeOriginalThree: includeOriginalThree)
            let field = try map(requested), stage = self.stage(source, strengths: requested, face: face)
            let output = stage.applyingContinuousContour(to: stage.sourceRGBA)
            XCTAssertEqual(stage.sourceRGBA, source)
            XCTAssertTrue(stage.controlPoints.isEmpty)
            XCTAssertEqual(stage.applyingDenseMap(to: source), source)
            XCTAssertEqual(output, field.applyRGBA(source))
            XCTAssertNotEqual(output, source)
            // Decode the original source coordinates from the final raster,
            // independently of the inverse solver or its bilinear helper.
            var moved = 0
            for q in [SIMD2(65, 98), SIMD2(70, 135), SIMD2(95, 180), SIMD2(120, 190), SIMD2(153, 171)] {
                let index = (q.y * width + q.x) * 4
                let recovered = SIMD2(Double(output[index]), Double(output[index + 1]) + 64)
                let target = SIMD2(Double(q.x), Double(q.y))
                let closed = recovered + field.forwardDisplacement(at: recovered)
                // Each encoded channel is rounded at most half a source texel;
                // the forward derivative budget covers the remaining expansion.
                vectorEqual(closed, target, accuracy: 1.0)
                if recovered != target { moved += 1 }
            }
            XCTAssertGreaterThan(moved, 0)
            var serial = source
            for (key, amount) in controls {
                serial = try map(request(key, amount)).applyRGBA(serial)
            }
            if includeOriginalThree {
                let originals: [Control] = [(\.faceSlim, BeautySafetyCaps.faceSlim),
                                              (\.faceSmall, BeautySafetyCaps.faceSmall),
                                              (\.faceContourSmooth, BeautySafetyCaps.faceContourSmooth)]
                for (key, cap) in originals {
                    serial = try map(request(key, cap)).applyRGBA(serial)
                }
            }
            XCTAssertNotEqual(output, serial)
        }
    }

    func testEachNewFieldPreservesEyeNasalCoresAndFarBackgroundBytes() throws {
        let source = texture()
        for (key, amount) in controls {
            let output = try map(request(key, amount)).applyRGBA(source)
            for point in [pixel(SIMD2(-0.5, 0)), pixel(SIMD2(0.5, 0)), pixel(SIMD2(0, 0.55)),
                          SIMD2(8, 8), SIMD2(230, 310)] {
                assertPatchEqual(output, source, at: point)
            }
            if key != \.chinLength {
                assertPatchEqual(output, source, at: pixel(SIMD2(0, 1.10)))
            }
            if key == \.templeFullness || key == \.cheekboneSlim {
                assertPatchEqual(output, source, at: pixel(SIMD2(0, 1.80)))
            }
            if key == \.chinTaper {
                // Real raster bytes, outside the tightened lower-chin scope.
                for point in [SIMD2(-0.80, 1.40), SIMD2(0.80, 1.40), SIMD2(0, 1.30)] {
                    assertPatchEqual(output, source, at: pixel(point))
                }
            }
            for i in stride(from: 3, to: output.count, by: 4) { XCTAssertEqual(output[i], 255) }
        }
    }

    func testRefusedFiveFieldsAndJawCannotRestoreOldPointsOrRemoveAdmittedSmallSibling() throws {
        let source = texture(), missingNose = face(observedNose: false)
        var jawOnly = BeautyEffectiveStrengths(); jawOnly.jawSlim = 0.25
        let jawStage = stage(source, strengths: jawOnly, face: missingNose)
        XCTAssertNil(BeautyFaceDisplacementMap(width: width, height: height,
            face: missingNose, strengths: jawOnly))
        XCTAssertTrue(jawStage.controlPoints.isEmpty)
        XCTAssertTrue(jawStage.applyingContinuousContour(to: source) == source)
        // Small-face has independently admitted observed eyes/lips/contour and
        // needs no nasal core. It remains an executable sibling after planning
        // clears the refused nose-dependent requests.
        var smallOnly = BeautyEffectiveStrengths(); smallOnly.faceSmall = 0.20
        let smallStage = stage(source, strengths: smallOnly, face: missingNose)
        let expected = smallStage.applyingContinuousContour(to: source)
        XCTAssertFalse(expected == source)
        for (key, amount) in controls {
            let refused = request(key, amount)
            XCTAssertNil(BeautyFaceDisplacementMap(width: width, height: height,
                face: missingNose, strengths: refused))
            let refusedStage = stage(source, strengths: refused, face: missingNose)
            XCTAssertTrue(refusedStage.controlPoints.isEmpty)
            XCTAssertTrue(refusedStage.applyingContinuousContour(to: source) == source)
            var withJaw = refused; withJaw.jawSlim = jawOnly.jawSlim
            let refusedJaw = stage(source, strengths: withJaw, face: missingNose)
            XCTAssertTrue(refusedJaw.controlPoints.isEmpty)
            XCTAssertTrue(refusedJaw.applyingContinuousContour(to: source) == source)
            withJaw.faceSmall = smallOnly.faceSmall
            let admitted = FaceShapeWarpProvider().planningEmissions(face: missingNose,
                strengths: withJaw).sanitizing(withJaw)
            XCTAssertEqual(admitted[keyPath: key], 0)
            XCTAssertEqual(admitted.jawSlim, 0)
            XCTAssertEqual(admitted.faceSmall, smallOnly.faceSmall)
            let mixed = stage(source, strengths: admitted, face: missingNose)
            XCTAssertEqual(mixed.controlPoints, smallStage.controlPoints)
            XCTAssertTrue(mixed.applyingContinuousContour(to: source) == expected)
        }
        for legacy in [FaceGeometry.fixture, face(freshness: .stale), face(observedEyes: false),
                       face(invalidContour: true), face(offset: SIMD2(-90, 0))] {
            let refused = stage(source, strengths: combined(includeOriginalThree: true), face: legacy)
            XCTAssertTrue(refused.controlPoints.isEmpty)
            XCTAssertTrue(refused.sourceRGBA == source)
            XCTAssertTrue(refused.applyingContinuousContour(to: source) == source)
        }
    }

    func testFiveFieldRasterAdmissionRequiresCompleteOpaqueInputAndKeepsImageExtent() throws {
        let requested = combined(includeOriginalThree: false), field = try map(requested)
        let opaque = texture(), output = field.applyRGBA(opaque)
        XCTAssertEqual(output.count, opaque.count)
        XCTAssertNotEqual(output, opaque)
        var transparent = opaque; transparent[3] = 0
        var translucent = opaque; translucent[(190 * width + 120) * 4 + 3] = 254
        for bytes in [transparent, translucent, [], Array(opaque.dropLast())] {
            XCTAssertEqual(field.applyRGBA(bytes), bytes)
            let refused = stage(bytes, strengths: requested, face: face())
            XCTAssertTrue(refused.controlPoints.isEmpty)
            XCTAssertEqual(refused.sourceRGBA, bytes)
            XCTAssertEqual(refused.applyingContinuousContour(to: bytes), bytes)
        }
        // Compact support makes the entire frame edge byte-preserving.
        for y in 0..<height { for x in 0..<width where x < 3 || x >= width - 3 || y < 3 || y >= height - 3 {
            let i = (y * width + x) * 4
            XCTAssertEqual(Array(output[i..<(i + 4)]), Array(opaque[i..<(i + 4)]))
        } }
    }
}
