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
}
