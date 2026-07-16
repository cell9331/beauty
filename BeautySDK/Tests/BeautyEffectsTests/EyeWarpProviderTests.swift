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

    private func semanticSupport(side: BeautyObservedEyeSide, contour: [SIMD2<Float>], pupil: SIMD2<Float>?) -> BeautyEyeSemanticSupport {
        let center = LandmarkGeometryHelper.center(of: contour)!
        let upper = contour.filter { $0.y <= center.y }
        let lower = contour.filter { $0.y >= center.y }
        let outer = side == .left ? contour.min { $0.x < $1.x }! : contour.max { $0.x < $1.x }!
        let inner = side == .left ? contour.max { $0.x < $1.x }! : contour.min { $0.x < $1.x }!
        return BeautyEyeSemanticSupport(
            side: side, contour: contour, upper: upper, lower: lower, inner: [inner], outer: [outer],
            corners: [outer, inner], center: center, pupil: pupil,
            span: SIMD2<Float>(contour.map(\.x).max()! - contour.map(\.x).min()!, contour.map(\.y).max()! - contour.map(\.y).min()!), tilt: 0
        )
    }
}
