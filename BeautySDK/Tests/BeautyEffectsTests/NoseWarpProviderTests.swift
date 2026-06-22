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

    private func strengths(
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.noseSlim = min(noseSlim, BeautySafetyCaps.noseSlim)
        strengths.noseWingSlim = min(noseWingSlim, BeautySafetyCaps.noseWingSlim)
        strengths.noseTipSize = min(noseTipSize, BeautySafetyCaps.noseTipSize)
        strengths.noseBridge = min(noseBridge, BeautySafetyCaps.noseBridge)
        return strengths
    }
}
