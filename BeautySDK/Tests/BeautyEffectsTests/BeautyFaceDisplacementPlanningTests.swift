import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyFaceDisplacementPlanningTests: XCTestCase {
    private enum Defect: CaseIterable {
        case none, reused, stale, missingEye, wrongEyeSide, nonfiniteEye, shortEye,
             missingLips, nonfiniteLips, shortLips, nonfiniteContour, duplicateContour,
             shortContour, missingNose, nonfiniteNose
    }

    /// Both lateral paths are perfectly linear in x. The retired roughness
    /// planner has no centered correction, while the new smooth field is a
    /// separately owned normal displacement and must remain requestable.
    private func face(_ defect: Defect = .none) -> FaceGeometry {
        func rectangle(_ x0: Float, _ x1: Float, _ y0: Float, _ y1: Float) -> [SIMD2<Float>] {
            [SIMD2(x0, y0), SIMD2(x1, y0), SIMD2(x1, y1), SIMD2(x0, y1)]
        }
        var contour: [SIMD2<Float>] = [SIMD2(0.25, 0.25), SIMD2(0.3125, 0.375),
            SIMD2(0.375, 0.5), SIMD2(0.4375, 0.625), SIMD2(0.5, 0.75),
            SIMD2(0.5625, 0.625), SIMD2(0.625, 0.5), SIMD2(0.6875, 0.375), SIMD2(0.75, 0.25)]
        var leftPath = rectangle(0.36, 0.44, 0.234375, 0.265625)
        let rightPath = rectangle(0.56, 0.64, 0.234375, 0.265625)
        var lips = rectangle(0.44, 0.56, 0.546875, 0.578125)
        if defect == .nonfiniteContour { contour[0].x = .nan }
        if defect == .duplicateContour { contour[1] = contour[0] }
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
        let nose = BeautyObservedNoseSupport(crest: crest,
            contour: [CoordinatePoint(x: 0.46, y: 0.50), CoordinatePoint(x: 0.5, y: 0.515625),
                      CoordinatePoint(x: 0.54, y: 0.50)])
        let freshness: LandmarkGeometryFreshness = defect == .stale ? .stale : defect == .reused ? .reused : .fresh
        return FaceGeometry(bounds: FaceBounds(x: 0.25, y: 0.20, width: 0.50, height: 0.55),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 4),
            leftEye: leftPath, rightEye: rightPath, outerLips: lips,
            leftEyeSupport: defect == .missingEye ? nil : eye(defect == .wrongEyeSide ? .right : .left, leftPath),
            rightEyeSupport: eye(.right, rightPath), freshness: freshness,
            observedOuterLips: defect == .missingLips ? nil : lips,
            observedNoseSupport: defect == .missingNose ? nil : nose)
    }

    private func strengths(width: Float = 0, small: Float = 0, smooth: Float = 0) -> BeautyEffectiveStrengths {
        var result = BeautyEffectiveStrengths()
        result.faceSlim = width; result.faceSmall = small; result.faceContourSmooth = smooth
        return result
    }

    func testSmoothSourceContourRetainsNewFieldWithoutLegacyCurvaturePoints() {
        let source = face(), requested = strengths(smooth: 0.25), provider = FaceShapeWarpProvider()
        XCTAssertTrue(provider.fieldEmissions(face: source, strengths: requested).faceContourSmooth.isEmpty)
        let emissions = provider.planningEmissions(face: source, strengths: requested)
        XCTAssertEqual(emissions.continuousFaceMask, 4)
        XCTAssertTrue(emissions.hasAdmittedWork)
        XCTAssertTrue(emissions.points.isEmpty)
        XCTAssertEqual(emissions.sanitizing(requested).faceContourSmooth, requested.faceContourSmooth)
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(faceContourSmooth: 0.25), faceGeometry: source)
        XCTAssertEqual(plan.effectiveStrengths.faceContourSmooth, 0.25)
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.skippedDomains.contains(.faceShape))
    }

    func testSignedWidthAndSmallFieldsRetainStrengthWithoutProxyPointCounts() {
        let provider = FaceShapeWarpProvider(), source = face()
        for sign in [Float(-1), Float(1)] {
            let requested = strengths(width: sign * 0.60, small: sign * 0.45, smooth: 0.25)
            let raw = provider.fieldEmissions(face: source, strengths: requested)
            XCTAssertFalse(raw.faceSlim.isEmpty)
            XCTAssertFalse(raw.faceSmall.isEmpty)
            let emissions = provider.planningEmissions(face: source, strengths: requested)
            XCTAssertEqual(emissions.continuousFaceMask, 7)
            XCTAssertTrue(emissions.faceSlim.isEmpty)
            XCTAssertTrue(emissions.faceSmall.isEmpty)
            XCTAssertTrue(emissions.faceContourSmooth.isEmpty)
            XCTAssertTrue(emissions.points.isEmpty)
            XCTAssertEqual(emissions.sanitizing(requested), requested)
            let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(
                faceSlim: sign * 0.60, faceSmall: sign * 0.45, faceContourSmooth: 0.25), faceGeometry: source)
            let resolved = plan.effectiveStrengths
            // The existing shared geometry budget can scale all admitted
            // siblings together. Admission must preserve each sign and a
            // common nonzero response, rather than bypassing that budget.
            XCTAssertGreaterThan(resolved.faceSlim * sign, 0)
            XCTAssertGreaterThan(resolved.faceSmall * sign, 0)
            XCTAssertGreaterThan(resolved.faceContourSmooth, 0)
            XCTAssertLessThanOrEqual(abs(resolved.faceSlim), abs(requested.faceSlim))
            XCTAssertLessThanOrEqual(abs(resolved.faceSmall), abs(requested.faceSmall))
            XCTAssertLessThanOrEqual(resolved.faceContourSmooth, requested.faceContourSmooth)
            let widthRatio = resolved.faceSlim / requested.faceSlim
            XCTAssertEqual(resolved.faceSmall / requested.faceSmall, widthRatio, accuracy: 1e-6)
            XCTAssertEqual(resolved.faceContourSmooth / requested.faceContourSmooth, widthRatio, accuracy: 1e-6)
            XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        }
    }

    func testUnreliableObservedSupportsRejectWithoutRestoringLegacyPlanningPoints() {
        let provider = FaceShapeWarpProvider(), requested = strengths(width: 0.60, small: 0.45, smooth: 0.25)
        for defect in Defect.allCases where defect != .none && defect != .missingNose && defect != .nonfiniteNose {
            let source = face(defect), emissions = provider.planningEmissions(face: source, strengths: requested)
            XCTAssertEqual(emissions.continuousFaceMask, 0, "\(defect)")
            XCTAssertTrue(emissions.faceSlim.isEmpty)
            XCTAssertTrue(emissions.faceSmall.isEmpty)
            XCTAssertTrue(emissions.faceContourSmooth.isEmpty)
            XCTAssertFalse(emissions.hasAdmittedWork)
            let sanitized = emissions.sanitizing(requested)
            XCTAssertEqual(sanitized.faceSlim, 0)
            XCTAssertEqual(sanitized.faceSmall, 0)
            XCTAssertEqual(sanitized.faceContourSmooth, 0)
            let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(
                faceSlim: 0.60, faceSmall: 0.45, faceContourSmooth: 0.25), faceGeometry: source)
            XCTAssertFalse(plan.activeDomains.contains(.faceShape), "\(defect)")
        }
    }

    func testNasalQualificationBelongsOnlyToWidthAndSmoothFields() {
        let provider = FaceShapeWarpProvider(), requested = strengths(width: 0.60, small: 0.45, smooth: 0.25)
        for defect in [Defect.missingNose, .nonfiniteNose] {
            let emissions = provider.planningEmissions(face: face(defect), strengths: requested)
            XCTAssertEqual(emissions.continuousFaceMask, 2)
            let sanitized = emissions.sanitizing(requested)
            XCTAssertEqual(sanitized.faceSlim, 0)
            XCTAssertEqual(sanitized.faceContourSmooth, 0)
            XCTAssertEqual(sanitized.faceSmall, requested.faceSmall)
        }
    }

    func testSourceOwnedFieldsIncludingJawHaveNoPlanningFallback() {
        let provider = FaceShapeWarpProvider()
        var requested = strengths(width: 0.3, small: 0.2, smooth: 0.1)
        requested.jawSlim = 0.2; requested.faceVShape = 0.15
        let legacy = provider.fieldEmissions(face: .fixture, strengths: requested)
        let plannedLegacy = provider.planningEmissions(face: .fixture, strengths: requested)
        XCTAssertFalse(legacy.faceSlim.isEmpty)
        XCTAssertFalse(legacy.faceSmall.isEmpty)
        XCTAssertTrue(plannedLegacy.faceSlim.isEmpty)
        XCTAssertTrue(plannedLegacy.faceSmall.isEmpty)
        XCTAssertTrue(plannedLegacy.faceContourSmooth.isEmpty)
        XCTAssertEqual(plannedLegacy.continuousFaceMask, 0)
        XCTAssertFalse(legacy.jawSlim.isEmpty)
        XCTAssertTrue(plannedLegacy.jawSlim.isEmpty)
        XCTAssertFalse(plannedLegacy.continuousJawAngle)
        XCTAssertFalse(legacy.faceVShape.isEmpty)
        XCTAssertTrue(plannedLegacy.faceVShape.isEmpty)
        XCTAssertEqual(plannedLegacy.sourceRefinementMask, legacy.sourceRefinementMask)
        let sanitized = plannedLegacy.sanitizing(requested)
        XCTAssertEqual(sanitized.faceSlim, 0)
        XCTAssertEqual(sanitized.faceSmall, 0)
        XCTAssertEqual(sanitized.faceContourSmooth, 0)
        XCTAssertEqual(sanitized.jawSlim, 0)
        XCTAssertEqual(sanitized.faceVShape, 0)
        let raw = provider.fieldEmissions(face: face(), strengths: requested)
        let continuous = provider.planningEmissions(face: face(), strengths: requested)
        XCTAssertFalse(raw.jawSlim.isEmpty)
        XCTAssertTrue(continuous.jawSlim.isEmpty)
        XCTAssertTrue(continuous.continuousJawAngle)
        XCTAssertEqual(continuous.sanitizing(requested).jawSlim, requested.jawSlim)
        XCTAssertFalse(raw.faceVShape.isEmpty)
        XCTAssertTrue(continuous.faceVShape.isEmpty)
        XCTAssertEqual(continuous.continuousFaceMask & 128, 128)
        XCTAssertEqual(continuous.sourceRefinementMask, raw.sourceRefinementMask)
    }

    func testCoarseResolverSkipsNonexecutableTrioAndJawRequiresObservedSupport() {
        let requests = [BeautyParameters(faceSlim: 0.3), BeautyParameters(faceSmall: -0.2),
                        BeautyParameters(faceContourSmooth: 0.1),
                        BeautyParameters(faceSlim: 0.3, faceSmall: -0.2, faceContourSmooth: 0.1)]
        for parameters in requests {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertEqual(plan.effectiveStrengths.faceSlim, 0)
            XCTAssertEqual(plan.effectiveStrengths.faceSmall, 0)
            XCTAssertEqual(plan.effectiveStrengths.faceContourSmooth, 0)
            XCTAssertFalse(plan.activeDomains.contains(.faceShape))
            XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
        }
        let sibling = BeautyEffectResolver.resolve(parameters: BeautyParameters(
            faceSlim: 0.3, faceSmall: -0.2, jawSlim: 0.2, faceContourSmooth: 0.1), faceGeometry: .fixture)
        XCTAssertEqual(sibling.effectiveStrengths.faceSlim, 0)
        XCTAssertEqual(sibling.effectiveStrengths.faceSmall, 0)
        XCTAssertEqual(sibling.effectiveStrengths.faceContourSmooth, 0)
        XCTAssertEqual(sibling.effectiveStrengths.jawSlim, 0)
        XCTAssertFalse(sibling.activeDomains.contains(.faceShape))
        XCTAssertTrue(sibling.skippedDomains.contains(.faceShape))
        let observedJaw = BeautyEffectResolver.resolve(parameters: BeautyParameters(jawSlim: 0.2),
                                                       faceGeometry: face())
        XCTAssertGreaterThan(observedJaw.effectiveStrengths.jawSlim, 0)
        XCTAssertTrue(observedJaw.activeDomains.contains(.faceShape))
        XCTAssertFalse(observedJaw.skippedDomains.contains(.faceShape))
    }

    func testNonfiniteOutOfRangeAndNegativeSmoothRequestsHaveNoContinuousAdmission() {
        let provider = FaceShapeWarpProvider()
        for requested in [strengths(width: .nan), strengths(width: .infinity), strengths(width: 0.61),
                          strengths(small: -0.46), strengths(smooth: -0.1), strengths(smooth: 0.26)] {
            let emissions = provider.planningEmissions(face: face(), strengths: requested)
            XCTAssertEqual(emissions.continuousFaceMask, 0)
            XCTAssertTrue(emissions.points.isEmpty)
            XCTAssertFalse(emissions.hasAdmittedWork)
        }
    }
}
