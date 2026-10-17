import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Generated observations verify source admission and retained-field accounting;
/// they do not establish reference amplitude or appearance qualification.
final class BeautyFaceFivePlanningTests: XCTestCase {
    private enum Defect: CaseIterable {
        case none, missingContour, duplicateContour, nonfiniteContour, shortContour,
             missingEye, wrongEyeSide, reversedEyes, nonfiniteEye, shortEye,
             missingLips, nonfiniteLips, shortLips, missingNose, nonfiniteNose,
             shortNose, reused, stale
    }

    private let controls: [(WritableKeyPath<BeautyParameters, Float>,
                            WritableKeyPath<BeautyEffectiveStrengths, Float>, Float, UInt8)] = [
        (\.templeFullness, \.templeFullness, BeautySafetyCaps.templeFullness, 8),
        (\.cheekboneSlim, \.cheekboneSlim, BeautySafetyCaps.cheekboneSlim, 16),
        (\.chinLength, \.chinLength, BeautySafetyCaps.chinLength, 32),
        (\.chinTaper, \.chinTaper, BeautySafetyCaps.chinTaper, 64),
        (\.faceVShape, \.faceVShape, BeautySafetyCaps.faceVShape, 128)
    ]

    /// No median line is supplied. The independently observed contour owns
    /// these fields; the legacy chin point provider cannot qualify taper here.
    private func face(_ defect: Defect = .none, legacyContour: Bool = true) -> FaceGeometry {
        func rectangle(_ x0: Float, _ x1: Float, _ y0: Float, _ y1: Float) -> [SIMD2<Float>] {
            [SIMD2(x0, y0), SIMD2(x1, y0), SIMD2(x1, y1), SIMD2(x0, y1)]
        }
        var contour: [SIMD2<Float>] = [SIMD2(0.25, 0.25), SIMD2(0.3125, 0.375),
            SIMD2(0.375, 0.5), SIMD2(0.4375, 0.625), SIMD2(0.5, 0.75),
            SIMD2(0.5625, 0.625), SIMD2(0.625, 0.5), SIMD2(0.6875, 0.375), SIMD2(0.75, 0.25)]
        var leftPath = rectangle(0.36, 0.44, 0.234375, 0.265625)
        let rightPath = rectangle(0.56, 0.64, 0.234375, 0.265625)
        var lips = rectangle(0.44, 0.56, 0.546875, 0.578125)
        if defect == .duplicateContour { contour[1] = contour[0] }
        if defect == .nonfiniteContour { contour[0].x = .nan }
        if defect == .shortContour { contour = Array(contour.prefix(6)) }
        if defect == .nonfiniteEye { leftPath[0].x = .nan }
        if defect == .shortEye { leftPath.removeLast() }
        if defect == .nonfiniteLips { lips[0].y = .infinity }
        if defect == .shortLips { lips.removeLast() }
        func eye(_ side: BeautyObservedEyeSide, _ path: [SIMD2<Float>]) -> BeautyEyeSemanticSupport {
            BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)),
                inner: [path[0]], outer: [path[1]], corners: [path[0], path[1]],
                center: (path[0] + path[2]) * 0.5, pupil: nil, span: SIMD2(0.08, 0.03125), tilt: 0)
        }
        var crest = [CoordinatePoint(x: 0.5, y: 0.35), CoordinatePoint(x: 0.5, y: 0.425),
                     CoordinatePoint(x: 0.5, y: 0.50)]
        if defect == .nonfiniteNose { crest[0] = CoordinatePoint(x: .nan, y: 0.35) }
        if defect == .shortNose { crest.removeLast() }
        let nose = BeautyObservedNoseSupport(crest: crest,
            contour: [CoordinatePoint(x: 0.46, y: 0.50), CoordinatePoint(x: 0.5, y: 0.515625),
                      CoordinatePoint(x: 0.54, y: 0.50)])
        let freshness: LandmarkGeometryFreshness = defect == .stale ? .stale : defect == .reused ? .reused : .fresh
        return FaceGeometry(bounds: FaceBounds(x: 0.25, y: 0.20, width: 0.50, height: 0.55),
            faceContour: legacyContour ? contour : [],
            observedFaceSupport: defect == .missingContour ? nil : BeautyFaceSemanticSupport(
                contour: contour, medianLine: nil, apexIndex: 4),
            leftEye: leftPath, rightEye: rightPath, outerLips: lips,
            leftEyeSupport: defect == .missingEye ? nil : eye(
                defect == .wrongEyeSide ? .right : .left, defect == .reversedEyes ? rightPath : leftPath),
            rightEyeSupport: eye(.right, defect == .reversedEyes ? leftPath : rightPath),
            freshness: freshness,
            observedOuterLips: defect == .missingLips ? nil : lips,
            observedNoseSupport: defect == .missingNose ? nil : nose)
    }

    private func allParameters() -> BeautyParameters {
        var result = BeautyParameters()
        for (key, _, cap, _) in controls { result[keyPath: key] = cap }
        return result
    }

    private func allStrengths() -> BeautyEffectiveStrengths {
        var result = BeautyEffectiveStrengths()
        for (_, key, cap, _) in controls { result[keyPath: key] = cap }
        return result
    }

    func testEachFieldRetainsSignedSourceAdmissionWithoutInventingPointPulls() {
        let source = face(), provider = FaceShapeWarpProvider()
        for (parameterKey, strengthKey, cap, mask) in controls {
            for sign: Float in (strengthKey == \.faceVShape ? [1] : [-1, 1]) {
                var requested = BeautyEffectiveStrengths()
                requested[keyPath: strengthKey] = sign * cap
                let emissions = provider.planningEmissions(face: source, strengths: requested)
                XCTAssertEqual(emissions.continuousFaceMask, mask)
                XCTAssertTrue(emissions.hasAdmittedWork)
                XCTAssertTrue(emissions.points.isEmpty)
                XCTAssertEqual(emissions.sanitizing(requested), requested)
                var parameters = BeautyParameters()
                parameters[keyPath: parameterKey] = sign * cap
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: source)
                XCTAssertEqual(plan.effectiveStrengths[keyPath: strengthKey], sign * cap)
                XCTAssertTrue(plan.activeDomains.contains(.faceShape))
                XCTAssertFalse(plan.skippedDomains.contains(.faceShape))
                XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
            }
        }
    }

    func testSourceChinAdmissionDoesNotUseLegacyContourOrMedianLineRequirements() {
        let source = face(legacyContour: false)
        var requested = BeautyEffectiveStrengths()
        requested.chinLength = -BeautySafetyCaps.chinLength
        requested.chinTaper = BeautySafetyCaps.chinTaper
        XCTAssertTrue(ChinWarpProvider().fieldEmissions(face: source, strengths: requested).points.isEmpty)
        let emissions = FaceShapeWarpProvider().planningEmissions(face: source, strengths: requested)
        XCTAssertEqual(emissions.continuousFaceMask, 32 | 64)
        XCTAssertTrue(emissions.points.isEmpty)
        XCTAssertEqual(emissions.sanitizing(requested), requested)
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(
            chinLength: requested.chinLength, chinTaper: requested.chinTaper), faceGeometry: source)
        XCTAssertEqual(plan.effectiveStrengths.chinLength, requested.chinLength)
        XCTAssertEqual(plan.effectiveStrengths.chinTaper, requested.chinTaper)
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
    }

    func testJointFieldsRetainOneSharedConflictScaleAndNoLegacyPointCount() {
        let requested = allStrengths()
        let emissions = FaceShapeWarpProvider().planningEmissions(face: face(), strengths: requested)
        XCTAssertEqual(emissions.continuousFaceMask, 248)
        XCTAssertTrue(emissions.points.isEmpty)
        XCTAssertEqual(emissions.sanitizing(requested), requested)
        let plan = BeautyEffectResolver.resolve(parameters: allParameters(), faceGeometry: face())
        let ratio = plan.effectiveStrengths.templeFullness / requested.templeFullness
        XCTAssertGreaterThan(ratio, 0)
        XCTAssertLessThan(ratio, 1)
        for (_, key, cap, _) in controls {
            XCTAssertEqual(plan.effectiveStrengths[keyPath: key] / cap, ratio, accuracy: 1e-6)
        }
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
    }

    func testMissingOrUnreliableObservationsRejectEachNewFieldWithoutPointFallback() {
        let requested = allStrengths(), provider = FaceShapeWarpProvider()
        for defect in Defect.allCases where defect != .none {
            let source = face(defect)
            let emissions = provider.planningEmissions(face: source, strengths: requested)
            XCTAssertEqual(emissions.continuousFaceMask, 0, "\(defect)")
            XCTAssertTrue(emissions.points.isEmpty, "\(defect)")
            XCTAssertFalse(emissions.hasAdmittedWork, "\(defect)")
            let sanitized = emissions.sanitizing(requested)
            let plan = BeautyEffectResolver.resolve(parameters: allParameters(), faceGeometry: source)
            for (_, key, _, _) in controls {
                XCTAssertEqual(sanitized[keyPath: key], 0, "\(defect)")
                XCTAssertEqual(plan.effectiveStrengths[keyPath: key], 0, "\(defect)")
            }
            XCTAssertFalse(plan.activeDomains.contains(.faceShape), "\(defect)")
            XCTAssertTrue(plan.skippedDomains.contains(.faceShape), "\(defect)")
            XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"], "\(defect)")
        }
    }

    func testCoarseOrAbsentGeometryRejectsReferenceFieldsIncludingJawAngle() {
        let provider = FaceShapeWarpProvider(), requested = allStrengths()
        XCTAssertFalse(provider.fieldEmissions(face: .fixture, strengths: requested).faceVShape.isEmpty)
        XCTAssertFalse(ChinWarpProvider().fieldEmissions(face: .fixture, strengths: requested).chinLength.isEmpty)
        let emissions = provider.planningEmissions(face: .fixture, strengths: requested)
        XCTAssertEqual(emissions.continuousFaceMask, 0)
        XCTAssertTrue(emissions.points.isEmpty)
        for source: FaceGeometry? in [.fixture, nil] {
            let plan = BeautyEffectResolver.resolve(parameters: allParameters(), faceGeometry: source)
            for (_, key, _, _) in controls { XCTAssertEqual(plan.effectiveStrengths[keyPath: key], 0) }
            XCTAssertFalse(plan.activeDomains.contains(.faceShape))
            XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
        }
        var parameters = allParameters()
        parameters.jawSlim = 0.2
        let sibling = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        for (_, key, _, _) in controls { XCTAssertEqual(sibling.effectiveStrengths[keyPath: key], 0) }
        XCTAssertEqual(sibling.effectiveStrengths.jawSlim, 0)
        XCTAssertFalse(sibling.activeDomains.contains(.faceShape))
        XCTAssertTrue(sibling.skippedDomains.contains(.faceShape))
    }

    func testJawAngleUsesObservedFieldAndNeverRestoresCoarsePointFallback() {
        let provider = FaceShapeWarpProvider()
        for sign: Float in [-1, 1] {
            var requested = BeautyEffectiveStrengths()
            requested.jawSlim = sign * BeautySafetyCaps.jawSlim
            let admitted = provider.planningEmissions(face: face(), strengths: requested)
            XCTAssertTrue(admitted.continuousJawAngle)
            XCTAssertTrue(admitted.points.isEmpty)
            XCTAssertEqual(admitted.sanitizing(requested).jawSlim, requested.jawSlim)
            for defect in Defect.allCases where defect != .none {
                let refused = provider.planningEmissions(face: face(defect), strengths: requested)
                XCTAssertFalse(refused.continuousJawAngle, "\(defect)")
                XCTAssertTrue(refused.points.isEmpty, "\(defect)")
                XCTAssertEqual(refused.sanitizing(requested).jawSlim, 0, "\(defect)")
            }
        }
    }

    func testRejectedHairlineSourcePreservesAdmittedJawFieldWithoutLegacyBand() throws {
        let source = face(), w = 1200, h = 1200
        var jaw = BeautyEffectiveStrengths(); jaw.jawSlim = BeautySafetyCaps.jawSlim
        var combined = jaw; combined.hairlineHeight = BeautySafetyCaps.hairlineHeight
        let bytes = [UInt8](repeating: 255, count: w * h * 4)
        let jawMap = try XCTUnwrap(BeautyFaceDisplacementMap(width: w, height: h,
            face: source, strengths: jaw, sourceRGBA: bytes))
        let combinedMap = try XCTUnwrap(BeautyFaceDisplacementMap(width: w, height: h,
            face: source, strengths: combined, sourceRGBA: bytes))
        XCTAssertGreaterThan(jawMap.forwardDisplacement(at: SIMD2(490, 680)).x, 0)
        for p in [SIMD2(490.0, 680.0), SIMD2(710.0, 680.0), SIMD2(600.0, 900.0)] {
            XCTAssertEqual(combinedMap.forwardDisplacement(at: p), jawMap.forwardDisplacement(at: p))
        }
        let malformed = try XCTUnwrap(BeautyFaceDisplacementMap(width: w, height: h,
            face: source, strengths: combined, sourceRGBA: []))
        XCTAssertEqual(malformed.forwardDisplacement(at: SIMD2(490, 680)),
                       jawMap.forwardDisplacement(at: SIMD2(490, 680)))
    }

    func testInvalidStrengthCannotAdmitNewWorkOrRecoverLegacyPoints() {
        let provider = FaceShapeWarpProvider()
        for (_, key, cap, _) in controls {
            for value in [Float.nan, .infinity, -.infinity, cap.nextUp, -cap.nextUp] {
                var requested = BeautyEffectiveStrengths()
                requested[keyPath: key] = value
                let emissions = provider.planningEmissions(face: face(), strengths: requested)
                XCTAssertEqual(emissions.continuousFaceMask, 0)
                XCTAssertTrue(emissions.points.isEmpty)
                XCTAssertFalse(emissions.hasAdmittedWork)
                XCTAssertEqual(emissions.sanitizing(requested)[keyPath: key], 0)
            }
        }
        var invalidV = BeautyEffectiveStrengths()
        invalidV.faceVShape = -0.1
        XCTAssertFalse(provider.planningEmissions(face: face(), strengths: invalidV).hasAdmittedWork)
    }
}
