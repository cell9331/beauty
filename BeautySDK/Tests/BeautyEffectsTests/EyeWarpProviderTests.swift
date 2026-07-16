import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class EyeWarpProviderTests: XCTestCase {
    func testEyeSizeCreatesControlPointsAroundBothEyesWithCappedStrength() {
        let result = EyeWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(eyeSize: 1)
        )

        XCTAssertNil(result.skipReason)
        XCTAssertGreaterThanOrEqual(result.points.count, 4)
        XCTAssertTrue(result.points.contains { $0.source.x < 0.5 })
        XCTAssertTrue(result.points.contains { $0.source.x > 0.5 })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.eyeSize })
    }

    func testEyeProviderOutputIsDeterministicAndClampedForAllCurrentFields() {
        let provider = EyeWarpProvider()
        let currentFieldStrengths = strengths(
            eyeSize: 1,
            eyeDistance: -1,
            eyeYPosition: 1,
            eyeTailLift: 1
        )

        let first = provider.makeControlPoints(face: .fixture, strengths: currentFieldStrengths)
        let second = provider.makeControlPoints(face: .fixture, strengths: currentFieldStrengths)

        XCTAssertEqual(first, second)
        XCTAssertFalse(first.points.isEmpty)
        XCTAssertTrue(first.points.allSatisfy { point in
            (0...1).contains(point.source.x) &&
                (0...1).contains(point.source.y) &&
                (0...1).contains(point.target.x) &&
                (0...1).contains(point.target.y)
        })
        XCTAssertTrue(first.points.allSatisfy { $0.radius >= 0.035 && $0.radius <= 0.24 })
        XCTAssertTrue(first.points.allSatisfy { $0.strength <= BeautySafetyCaps.eyeSize })
    }

    func testEyeDistanceMovesEyeRegionsOutwardWithCappedStrength() {
        let result = EyeWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(eyeDistance: 1)
        )

        let left = try! XCTUnwrap(result.points.first { $0.source.x < 0.5 })
        let right = try! XCTUnwrap(result.points.first { $0.source.x > 0.5 })

        XCTAssertLessThan(left.target.x, left.source.x)
        XCTAssertGreaterThan(right.target.x, right.source.x)
        XCTAssertLessThanOrEqual(left.strength, BeautySafetyCaps.eyeDistance)
        XCTAssertLessThanOrEqual(right.strength, BeautySafetyCaps.eyeDistance)
    }

    func testEyeYPositionMovesBothEyesVerticallyWithCappedStrength() {
        let result = EyeWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(eyeYPosition: 1)
        )

        XCTAssertFalse(result.points.isEmpty)
        XCTAssertTrue(result.points.allSatisfy { $0.target.y > $0.source.y })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.eyeYPosition })
    }

    func testEyeTailLiftMovesOuterTailPointsUpWithCappedStrength() {
        let result = EyeWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(eyeTailLift: 1)
        )

        XCTAssertEqual(result.points.count, 2)
        XCTAssertTrue(result.points.allSatisfy { $0.target.y < $0.source.y })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.eyeTailLift })
    }

    func testMissingEitherEyeInputReturnsStableSkipReasonWithoutPoints() {
        for face in [FaceGeometry.missingLeftEye, .missingRightEye] {
            let result = EyeWarpProvider().makeControlPoints(
                face: face,
                strengths: strengths(eyeSize: 1, eyeDistance: 1, eyeYPosition: 1, eyeTailLift: 1)
            )

            XCTAssertTrue(result.points.isEmpty)
            XCTAssertEqual(result.skipReason, "eye_inputs_missing")
        }
    }

    func testZeroNewEyeFieldsPreserveShippedProviderControlPoints() throws {
        let legacy = BeautyParameters(
            eyeSize: 0.31,
            eyeDistance: -0.22,
            eyeYPosition: 0.17,
            eyeTailLift: 0.19
        )
        let expanded = BeautyParameters(
            eyeSize: 0.31,
            eyeDistance: -0.22,
            eyeYPosition: 0.17,
            eyeTailLift: 0.19,
            eyeHeight: 0,
            eyeLength: 0,
            upperEyelidLift: 0,
            pupilSize: 0,
            gazeCorrection: 0,
            lowerEyelidDrop: 0,
            eyeTilt: 0,
            innerCornerOpen: 0,
            outerCornerOpen: 0,
            eyeSymmetry: 0
        )
        let legacyStrengths = shippedStrengths(from: legacy)
        let expandedStrengths = shippedStrengths(from: expanded)
        let provider = EyeWarpProvider()

        XCTAssertEqual(legacyStrengths, expandedStrengths)
        XCTAssertEqual(
            provider.makeControlPoints(face: .fixture, strengths: legacyStrengths),
            provider.makeControlPoints(face: .fixture, strengths: expandedStrengths)
        )

        let legacyJSON = try JSONEncoder().encode(legacy)
        let expandedJSON = try JSONEncoder().encode(expanded)
        let legacyDecoded = try JSONDecoder().decode(BeautyParameters.self, from: legacyJSON)
        let expandedDecoded = try JSONDecoder().decode(BeautyParameters.self, from: expandedJSON)
        XCTAssertEqual(legacyDecoded.eyeSize, expandedDecoded.eyeSize)
        XCTAssertEqual(legacyDecoded.eyeDistance, expandedDecoded.eyeDistance)
        XCTAssertEqual(legacyDecoded.eyeYPosition, expandedDecoded.eyeYPosition)
        XCTAssertEqual(legacyDecoded.eyeTailLift, expandedDecoded.eyeTailLift)
    }

    func testMalformedObservedEyeSupportFailsClosedWithoutChangingNeutralProviderContract() {
        let observation = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.80),
            landmarks: .complete,
            observedEyeSupport: [
                BeautyObservedEyeSupport(
                    side: .left,
                    contour: [CoordinatePoint(x: .infinity, y: 0)]
                ),
                BeautyObservedEyeSupport(
                    side: .right,
                    contour: [CoordinatePoint(x: .infinity, y: 0)]
                )
            ],
            observedEyeOrder: .canonical
        )
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let result = EyeWarpProvider().makeControlPoints(
            face: geometry,
            strengths: strengths(eyeSize: 0.4)
        )

        XCTAssertTrue(result.points.isEmpty)
        XCTAssertEqual(result.skipReason, "eye_inputs_missing")
    }

    func testPhase42FourteenNamedEmissionsAreIndependentAndEvidenceGated() {
        let left = semanticSupport(side: .left, contour: FaceGeometry.fixture.leftEye, pupil: SIMD2<Float>(0.425, 0.385))
        let right = semanticSupport(side: .right, contour: FaceGeometry.fixture.rightEye, pupil: SIMD2<Float>(0.575, 0.385))
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: left.contour,
            rightEye: right.contour,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips,
            upperLips: FaceGeometry.fixture.upperLips,
            lowerLips: FaceGeometry.fixture.lowerLips,
            innerLips: FaceGeometry.fixture.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right
        )
        var values = BeautyEffectiveStrengths()
        values.eyeHeight = BeautySafetyCaps.eyeHeight
        values.eyeLength = BeautySafetyCaps.eyeLength
        values.upperEyelidLift = BeautySafetyCaps.upperEyelidLift
        values.pupilSize = BeautySafetyCaps.pupilSize
        values.gazeCorrection = BeautySafetyCaps.gazeCorrection
        values.lowerEyelidDrop = BeautySafetyCaps.lowerEyelidDrop
        values.eyeTilt = BeautySafetyCaps.eyeTilt
        values.innerCornerOpen = BeautySafetyCaps.innerCornerOpen
        values.outerCornerOpen = BeautySafetyCaps.outerCornerOpen
        values.eyeSymmetry = BeautySafetyCaps.eyeSymmetry
        let emissions = EyeWarpProvider().fieldEmissions(face: face, strengths: values)

        XCTAssertFalse(emissions.eyeHeight.isEmpty)
        XCTAssertFalse(emissions.eyeLength.isEmpty)
        XCTAssertFalse(emissions.upperEyelidLift.isEmpty)
        XCTAssertFalse(emissions.pupilSize.isEmpty)
        XCTAssertFalse(emissions.gazeCorrection.isEmpty)
        XCTAssertFalse(emissions.lowerEyelidDrop.isEmpty)
        XCTAssertFalse(emissions.eyeTilt.isEmpty)
        XCTAssertFalse(emissions.innerCornerOpen.isEmpty)
        XCTAssertFalse(emissions.outerCornerOpen.isEmpty)
        XCTAssertTrue(emissions.eyeSymmetry.isEmpty, "neutral measured pair is a symmetry no-op")
        XCTAssertTrue(emissions.points.allSatisfy { $0.source.x.isFinite && $0.target.y.isFinite && (0...1).contains($0.target.x) })

        values.pupilSize = BeautySafetyCaps.pupilSize
        let noPupil = FaceGeometry(
            bounds: face.bounds, faceContour: face.faceContour, leftEye: face.leftEye, rightEye: face.rightEye,
            nose: face.nose, noseRoot: face.noseRoot, noseTip: face.noseTip, outerLips: face.outerLips,
            upperLips: face.upperLips, lowerLips: face.lowerLips, innerLips: face.innerLips,
            leftEyeSupport: semanticSupport(side: .left, contour: left.contour, pupil: nil),
            rightEyeSupport: semanticSupport(side: .right, contour: right.contour, pupil: nil)
        )
        XCTAssertTrue(EyeWarpProvider().fieldEmissions(face: noPupil, strengths: values).pupilSize.isEmpty)
    }

    func testPhase42EyeFieldsPreserveLocalDirectionsAndDistinctSources() {
        let left = semanticSupport(side: .left, contour: FaceGeometry.fixture.leftEye, pupil: SIMD2<Float>(0.425, 0.385))
        let right = semanticSupport(side: .right, contour: FaceGeometry.fixture.rightEye, pupil: SIMD2<Float>(0.575, 0.385))
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: left.contour,
            rightEye: right.contour,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips,
            upperLips: FaceGeometry.fixture.upperLips,
            lowerLips: FaceGeometry.fixture.lowerLips,
            innerLips: FaceGeometry.fixture.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right
        )
        let provider = EyeWarpProvider()
        var values = BeautyEffectiveStrengths()
        values.eyeHeight = BeautySafetyCaps.eyeHeight
        values.eyeLength = BeautySafetyCaps.eyeLength
        values.upperEyelidLift = BeautySafetyCaps.upperEyelidLift
        values.lowerEyelidDrop = BeautySafetyCaps.lowerEyelidDrop
        values.innerCornerOpen = BeautySafetyCaps.innerCornerOpen
        values.outerCornerOpen = BeautySafetyCaps.outerCornerOpen
        let emissions = provider.fieldEmissions(face: face, strengths: values)

        XCTAssertFalse(emissions.eyeHeight.isEmpty)
        XCTAssertTrue(emissions.eyeHeight.contains { $0.target.y < $0.source.y })
        XCTAssertTrue(emissions.eyeHeight.contains { $0.target.y > $0.source.y })
        XCTAssertTrue(emissions.eyeHeight.allSatisfy { $0.target.x == $0.source.x })
        XCTAssertFalse(emissions.eyeLength.isEmpty)
        XCTAssertTrue(emissions.eyeLength.allSatisfy { $0.target.y == $0.source.y })
        XCTAssertTrue(emissions.eyeLength.allSatisfy { $0.target.x != $0.source.x })
        XCTAssertTrue(emissions.upperEyelidLift.allSatisfy { $0.target.y < $0.source.y })
        XCTAssertTrue(emissions.lowerEyelidDrop.allSatisfy { $0.target.y > $0.source.y })
        XCTAssertTrue(emissions.innerCornerOpen.allSatisfy { $0.source.x != $0.target.x })
        XCTAssertTrue(emissions.outerCornerOpen.allSatisfy { $0.source.x != $0.target.x })
        XCTAssertNotEqual(emissions.eyeLength.map(\.source), emissions.innerCornerOpen.map(\.source))
        XCTAssertTrue(emissions.points.allSatisfy { point in
            (0...1).contains(point.source.x) && (0...1).contains(point.source.y) &&
                (0...1).contains(point.target.x) && (0...1).contains(point.target.y)
        })
    }

    func testPhase42TiltSignsAndPupilGazeAreBoundedAndMonotonic() {
        let left = semanticSupport(side: .left, contour: FaceGeometry.fixture.leftEye, pupil: SIMD2<Float>(0.425, 0.385))
        let right = semanticSupport(side: .right, contour: FaceGeometry.fixture.rightEye, pupil: SIMD2<Float>(0.575, 0.385))
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: left.contour,
            rightEye: right.contour,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips,
            upperLips: FaceGeometry.fixture.upperLips,
            lowerLips: FaceGeometry.fixture.lowerLips,
            innerLips: FaceGeometry.fixture.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right
        )
        let provider = EyeWarpProvider()
        var positive = BeautyEffectiveStrengths()
        positive.eyeTilt = BeautySafetyCaps.eyeTilt
        var negative = BeautyEffectiveStrengths()
        negative.eyeTilt = -BeautySafetyCaps.eyeTilt
        let positiveTilt = provider.fieldEmissions(face: face, strengths: positive).eyeTilt
        let negativeTilt = provider.fieldEmissions(face: face, strengths: negative).eyeTilt
        XCTAssertEqual(positiveTilt.count, negativeTilt.count)
        XCTAssertTrue(zip(positiveTilt, negativeTilt).contains { pair in
            let positiveDelta = pair.0.target.y - pair.0.source.y
            let negativeDelta = pair.1.target.y - pair.1.source.y
            return abs(positiveDelta) > 0.0001 && abs(negativeDelta) > 0.0001 && positiveDelta * negativeDelta < 0
        })
        XCTAssertTrue(positiveTilt.allSatisfy { $0.strength <= BeautySafetyCaps.eyeTilt })

        var halfGaze = BeautyEffectiveStrengths()
        halfGaze.gazeCorrection = BeautySafetyCaps.gazeCorrection * 0.5
        var fullGaze = BeautyEffectiveStrengths()
        fullGaze.gazeCorrection = BeautySafetyCaps.gazeCorrection
        let pupil = SIMD2<Float>(0.425, 0.385)
        let center = left.center
        let half = provider.fieldEmissions(face: face, strengths: halfGaze).gazeCorrection[0]
        let full = provider.fieldEmissions(face: face, strengths: fullGaze).gazeCorrection[0]
        func distance(_ point: SIMD2<Float>) -> Float {
            let delta = point - center
            return sqrt(delta.x * delta.x + delta.y * delta.y)
        }
        XCTAssertLessThan(distance(full.target), distance(half.target))
        XCTAssertGreaterThan(distance(half.source), distance(half.target))
        XCTAssertLessThan(distance(half.source), distance(pupil) + 0.0001)

        let neutral = semanticSupport(side: .left, contour: left.contour, pupil: left.center)
        let neutralRight = semanticSupport(side: .right, contour: right.contour, pupil: right.center)
        let neutralFace = FaceGeometry(
            bounds: face.bounds, faceContour: face.faceContour, leftEye: face.leftEye, rightEye: face.rightEye,
            nose: face.nose, noseRoot: face.noseRoot, noseTip: face.noseTip, outerLips: face.outerLips,
            upperLips: face.upperLips, lowerLips: face.lowerLips, innerLips: face.innerLips,
            leftEyeSupport: neutral, rightEyeSupport: neutralRight
        )
        XCTAssertTrue(provider.fieldEmissions(face: neutralFace, strengths: fullGaze).gazeCorrection.isEmpty)
    }

    func testSymmetryReducesPairedSpanAndTiltDifferencesWithBoundedVectors() {
        let left = semanticSupport(
            side: .left,
            contour: [
                SIMD2<Float>(0.24, 0.45), SIMD2<Float>(0.30, 0.36), SIMD2<Float>(0.44, 0.40),
                SIMD2<Float>(0.42, 0.49), SIMD2<Float>(0.28, 0.50)
            ],
            tilt: -0.18
        )
        let right = semanticSupport(
            side: .right,
            contour: [
                SIMD2<Float>(0.57, 0.43), SIMD2<Float>(0.62, 0.34), SIMD2<Float>(0.78, 0.39),
                SIMD2<Float>(0.80, 0.53), SIMD2<Float>(0.60, 0.55)
            ],
            tilt: 0.22
        )
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: left.contour,
            rightEye: right.contour,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips,
            upperLips: FaceGeometry.fixture.upperLips,
            lowerLips: FaceGeometry.fixture.lowerLips,
            innerLips: FaceGeometry.fixture.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right
        )
        var requested = BeautyEffectiveStrengths()
        requested.eyeSymmetry = BeautySafetyCaps.eyeSymmetry

        let points = EyeWarpProvider().fieldEmissions(face: face, strengths: requested).eyeSymmetry
        let leftPoints = points.filter { $0.source.x < 0.5 }
        let rightPoints = points.filter { $0.source.x > 0.5 }

        XCTAssertFalse(points.isEmpty)
        XCTAssertTrue(points.contains { $0.source != $0.target })
        XCTAssertTrue(points.allSatisfy { $0.strength <= BeautySafetyCaps.eyeSymmetry })

        func span(_ points: [WarpControlPoint], target: Bool) -> SIMD2<Float> {
            let values = points.map { target ? $0.target : $0.source }
            return SIMD2<Float>(
                (values.map(\.x).max() ?? 0) - (values.map(\.x).min() ?? 0),
                (values.map(\.y).max() ?? 0) - (values.map(\.y).min() ?? 0)
            )
        }
        let sourceSpanDelta = abs(span(leftPoints, target: false).x - span(rightPoints, target: false).x)
        let targetSpanDelta = abs(span(leftPoints, target: true).x - span(rightPoints, target: true).x)
        XCTAssertLessThan(targetSpanDelta, sourceSpanDelta)

        func endpointTilt(_ points: [WarpControlPoint], target: Bool) -> Float {
            let outer = points.min { $0.source.x < $1.source.x }!
            let inner = points.max { $0.source.x < $1.source.x }!
            let outerPoint = target ? outer.target : outer.source
            let innerPoint = target ? inner.target : inner.source
            return atan2(innerPoint.y - outerPoint.y, abs(innerPoint.x - outerPoint.x)) / (.pi / 2)
        }
        let sourceTiltDelta = abs(endpointTilt(leftPoints, target: false) - endpointTilt(rightPoints, target: false))
        let targetTiltDelta = abs(endpointTilt(leftPoints, target: true) - endpointTilt(rightPoints, target: true))
        XCTAssertLessThan(targetTiltDelta, sourceTiltDelta)
    }

    func testSymmetryRejectsImplausibleSemanticSpanWithoutEmissions() {
        let left = semanticSupport(side: .left, contour: FaceGeometry.fixture.leftEye, tilt: 0)
        let right = BeautyEyeSemanticSupport(
            side: .right,
            contour: FaceGeometry.fixture.rightEye,
            upper: FaceGeometry.fixture.rightEye,
            lower: FaceGeometry.fixture.rightEye,
            inner: [SIMD2<Float>(.infinity, 0)],
            outer: [SIMD2<Float>(0.7, 0.4)],
            corners: [],
            center: SIMD2<Float>(0.7, 0.4),
            pupil: nil,
            span: SIMD2<Float>(.infinity, 0.1),
            tilt: 0.2
        )
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: left.contour,
            rightEye: right.contour,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips,
            upperLips: FaceGeometry.fixture.upperLips,
            lowerLips: FaceGeometry.fixture.lowerLips,
            innerLips: FaceGeometry.fixture.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right
        )
        var requested = BeautyEffectiveStrengths()
        requested.eyeSymmetry = BeautySafetyCaps.eyeSymmetry
        XCTAssertTrue(EyeWarpProvider().fieldEmissions(face: face, strengths: requested).eyeSymmetry.isEmpty)
    }

    func testSymmetryRejectsMalformedContourEvenWhenScalarMetadataLooksPlausible() {
        let left = semanticSupport(side: .left, contour: FaceGeometry.fixture.leftEye)
        let right = BeautyEyeSemanticSupport(
            side: .right,
            contour: [SIMD2<Float>(.infinity, 0.4), SIMD2<Float>(0.72, 0.5)],
            upper: [SIMD2<Float>(.infinity, 0.4)],
            lower: [SIMD2<Float>(0.72, 0.5)],
            inner: [SIMD2<Float>(0.72, 0.5)],
            outer: [SIMD2<Float>(.infinity, 0.4)],
            corners: [],
            center: SIMD2<Float>(0.70, 0.45),
            pupil: nil,
            span: SIMD2<Float>(0.10, 0.10),
            tilt: 0.15
        )
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: left.contour,
            rightEye: right.contour,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips,
            upperLips: FaceGeometry.fixture.upperLips,
            lowerLips: FaceGeometry.fixture.lowerLips,
            innerLips: FaceGeometry.fixture.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right
        )
        var requested = BeautyEffectiveStrengths()
        requested.eyeSymmetry = BeautySafetyCaps.eyeSymmetry

        XCTAssertTrue(EyeWarpProvider().fieldEmissions(face: face, strengths: requested).eyeSymmetry.isEmpty)
    }

    private func shippedStrengths(from parameters: BeautyParameters) -> BeautyEffectiveStrengths {
        strengths(
            eyeSize: parameters.eyeSize,
            eyeDistance: parameters.eyeDistance,
            eyeYPosition: parameters.eyeYPosition,
            eyeTailLift: parameters.eyeTailLift
        )
    }

    private func strengths(
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.eyeSize = clampSigned(eyeSize, BeautySafetyCaps.eyeSize)
        strengths.eyeDistance = clampSigned(eyeDistance, BeautySafetyCaps.eyeDistance)
        strengths.eyeYPosition = clampSigned(eyeYPosition, BeautySafetyCaps.eyeYPosition)
        strengths.eyeTailLift = clampSigned(eyeTailLift, BeautySafetyCaps.eyeTailLift)
        return strengths
    }

    private func clampSigned(_ value: Float, _ cap: Float) -> Float {
        min(max(value, -cap), cap)
    }

    private func semanticSupport(side: BeautyObservedEyeSide, contour: [SIMD2<Float>], pupil: SIMD2<Float>? = nil, tilt: Float = 0) -> BeautyEyeSemanticSupport {
        let center = LandmarkGeometryHelper.center(of: contour)!
        let upper = contour.filter { $0.y <= center.y }
        let lower = contour.filter { $0.y >= center.y }
        let outer = side == .left ? contour.min { $0.x < $1.x }! : contour.max { $0.x < $1.x }!
        let inner = side == .left ? contour.max { $0.x < $1.x }! : contour.min { $0.x < $1.x }!
        return BeautyEyeSemanticSupport(
            side: side, contour: contour, upper: upper, lower: lower, inner: [inner], outer: [outer],
            corners: [outer, inner], center: center, pupil: pupil,
            span: SIMD2<Float>(contour.map(\.x).max()! - contour.map(\.x).min()!, contour.map(\.y).max()! - contour.map(\.y).min()!), tilt: tilt
        )
    }
}
