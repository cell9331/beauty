import XCTest
import BeautyCore
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

    private func strengths(
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.eyeSize = min(eyeSize, BeautySafetyCaps.eyeSize)
        strengths.eyeDistance = min(eyeDistance, BeautySafetyCaps.eyeDistance)
        strengths.eyeYPosition = min(eyeYPosition, BeautySafetyCaps.eyeYPosition)
        strengths.eyeTailLift = min(eyeTailLift, BeautySafetyCaps.eyeTailLift)
        return strengths
    }
}
