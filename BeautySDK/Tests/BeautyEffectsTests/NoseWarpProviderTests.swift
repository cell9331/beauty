import XCTest
import BeautyCore
@testable import BeautyEffects

final class NoseWarpProviderTests: XCTestCase {
    func testNoseSlimMovesSidePointsTowardNoseCenterWithCappedStrength() {
        let result = NoseWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(noseSlim: 1)
        )
        let center = try! XCTUnwrap(LandmarkGeometryHelper.center(of: FaceGeometry.fixture.nose))
        let left = try! XCTUnwrap(result.points.first { $0.source.x < center.x })
        let right = try! XCTUnwrap(result.points.first { $0.source.x > center.x })

        XCTAssertGreaterThan(left.target.x, left.source.x)
        XCTAssertLessThan(right.target.x, right.source.x)
        XCTAssertLessThanOrEqual(left.strength, BeautySafetyCaps.noseSlim)
        XCTAssertLessThanOrEqual(right.strength, BeautySafetyCaps.noseSlim)
    }

    func testNoseProviderOutputIsDeterministicAndClampedForAllCurrentFields() {
        let provider = NoseWarpProvider()
        let currentFieldStrengths = strengths(
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1
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
        XCTAssertTrue(first.points.allSatisfy { $0.radius >= 0.03 && $0.radius <= 0.20 })
        XCTAssertTrue(first.points.allSatisfy { $0.strength <= BeautySafetyCaps.noseSlim })
    }

    func testNoseWingSlimCreatesLowerNosePointsWithCappedStrength() {
        let result = NoseWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(noseWingSlim: 1)
        )
        let centerY = try! XCTUnwrap(LandmarkGeometryHelper.center(of: FaceGeometry.fixture.nose)).y

        XCTAssertFalse(result.points.isEmpty)
        XCTAssertTrue(result.points.allSatisfy { $0.source.y >= centerY })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.noseWingSlim })
    }

    func testNoseTipSizeCreatesTipRegionPointsWithCappedStrength() {
        let result = NoseWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(noseTipSize: 1)
        )
        let centerY = try! XCTUnwrap(LandmarkGeometryHelper.center(of: FaceGeometry.fixture.nose)).y

        XCTAssertFalse(result.points.isEmpty)
        XCTAssertTrue(result.points.allSatisfy { $0.source.y >= centerY })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.noseTipSize })
    }

    func testNoseBridgeCreatesUpperBridgePointsWithCappedStrength() {
        let result = NoseWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(noseBridge: 1)
        )
        let centerY = try! XCTUnwrap(LandmarkGeometryHelper.center(of: FaceGeometry.fixture.nose)).y

        XCTAssertFalse(result.points.isEmpty)
        XCTAssertTrue(result.points.allSatisfy { $0.source.y <= centerY })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.noseBridge })
    }

    func testMissingNoseInputsReturnSkipReason() {
        let result = NoseWarpProvider().makeControlPoints(
            face: .missingNose,
            strengths: strengths(noseSlim: 1, noseWingSlim: 1, noseTipSize: 1, noseBridge: 1)
        )

        XCTAssertTrue(result.points.isEmpty)
        XCTAssertEqual(result.skipReason, "nose_inputs_missing")
    }

    private func strengths(
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.noseSlim = min(noseSlim, BeautySafetyCaps.noseSlim)
        strengths.noseWingSlim = min(noseWingSlim, BeautySafetyCaps.noseWingSlim)
        strengths.noseTipSize = min(max(noseTipSize, -BeautySafetyCaps.noseTipSize), BeautySafetyCaps.noseTipSize)
        strengths.noseBridge = min(noseBridge, BeautySafetyCaps.noseBridge)
        return strengths
    }
}
