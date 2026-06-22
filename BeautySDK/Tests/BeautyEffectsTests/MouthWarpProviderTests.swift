import XCTest
import BeautyCore
@testable import BeautyEffects

final class MouthWarpProviderTests: XCTestCase {
    func testMouthSizeExpandsLipRegionAroundMouthCenterWithCappedStrength() {
        let face = FaceGeometry.fixture
        let result = MouthWarpProvider().makeControlPoints(
            face: face,
            strengths: strengths(mouthSize: 1)
        )
        let center = try! XCTUnwrap(LandmarkGeometryHelper.center(of: face.outerLips))

        XCTAssertNil(result.skipReason)
        XCTAssertGreaterThanOrEqual(result.points.count, 4)
        for point in result.points {
            XCTAssertGreaterThan(
                LandmarkGeometryHelper.distance(point.target, center),
                LandmarkGeometryHelper.distance(point.source, center)
            )
            XCTAssertLessThanOrEqual(point.strength, BeautySafetyCaps.mouthSize)
        }
    }

    func testMouthWidthMovesCornersOutwardWithCappedStrength() {
        let face = FaceGeometry.fixture
        let result = MouthWarpProvider().makeControlPoints(
            face: face,
            strengths: strengths(mouthWidth: 1)
        )
        let center = try! XCTUnwrap(LandmarkGeometryHelper.center(of: face.outerLips))
        let left = try! XCTUnwrap(result.points.first { $0.source.x < center.x })
        let right = try! XCTUnwrap(result.points.first { $0.source.x > center.x })

        XCTAssertLessThan(left.target.x, left.source.x)
        XCTAssertGreaterThan(right.target.x, right.source.x)
        XCTAssertLessThanOrEqual(left.strength, BeautySafetyCaps.mouthWidth)
        XCTAssertLessThanOrEqual(right.strength, BeautySafetyCaps.mouthWidth)
    }

    func testSmileLiftsBothMouthCornersWithCappedStrength() {
        let result = MouthWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(smile: 1)
        )

        XCTAssertEqual(result.points.count, 2)
        XCTAssertTrue(result.points.allSatisfy { $0.target.y < $0.source.y })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.smile })
    }

    func testMissingOuterLipsReturnsMissingMouthSkipReason() {
        let result = MouthWarpProvider().makeControlPoints(
            face: .missingMouth,
            strengths: strengths(mouthSize: 1, mouthWidth: 1, smile: 1)
        )

        XCTAssertTrue(result.points.isEmpty)
        XCTAssertEqual(result.skipReason, "mouth_landmarks_missing")
    }

    private func strengths(
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.mouthSize = min(mouthSize, BeautySafetyCaps.mouthSize)
        strengths.mouthWidth = min(mouthWidth, BeautySafetyCaps.mouthWidth)
        strengths.smile = min(smile, BeautySafetyCaps.smile)
        return strengths
    }
}
