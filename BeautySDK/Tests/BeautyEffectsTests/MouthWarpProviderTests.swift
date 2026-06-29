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

    func testMouthProviderOutputIsDeterministicAndClampedForAllCurrentFields() {
        let provider = MouthWarpProvider()
        let currentFieldStrengths = strengths(mouthSize: 1, mouthWidth: -1, smile: 1)

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
        XCTAssertTrue(first.points.allSatisfy { $0.radius >= 0.035 && $0.radius <= 0.20 })
        XCTAssertTrue(first.points.allSatisfy { $0.strength <= BeautySafetyCaps.smile })
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

    func testNegativeMouthSizeAndWidthMoveLipPointsInwardWithCappedStrength() {
        let face = FaceGeometry.fixture
        let center = try! XCTUnwrap(LandmarkGeometryHelper.center(of: face.outerLips))

        let smaller = MouthWarpProvider().makeControlPoints(
            face: face,
            strengths: strengths(mouthSize: -1)
        )
        let narrower = MouthWarpProvider().makeControlPoints(
            face: face,
            strengths: strengths(mouthWidth: -1)
        )

        XCTAssertFalse(smaller.points.isEmpty)
        for point in smaller.points {
            XCTAssertLessThan(
                LandmarkGeometryHelper.distance(point.target, center),
                LandmarkGeometryHelper.distance(point.source, center)
            )
            XCTAssertLessThanOrEqual(point.strength, BeautySafetyCaps.mouthSize)
        }

        let left = try! XCTUnwrap(narrower.points.first { $0.source.x < center.x })
        let right = try! XCTUnwrap(narrower.points.first { $0.source.x > center.x })
        XCTAssertGreaterThan(left.target.x, left.source.x)
        XCTAssertLessThan(right.target.x, right.source.x)
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
        XCTAssertEqual(result.skipReason, "mouth_inputs_missing")
    }

    private func strengths(
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.mouthSize = min(max(mouthSize, -BeautySafetyCaps.mouthSize), BeautySafetyCaps.mouthSize)
        strengths.mouthWidth = min(max(mouthWidth, -BeautySafetyCaps.mouthWidth), BeautySafetyCaps.mouthWidth)
        strengths.smile = min(smile, BeautySafetyCaps.smile)
        return strengths
    }
}
