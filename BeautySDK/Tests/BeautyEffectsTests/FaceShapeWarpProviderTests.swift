import XCTest
import BeautyCore
@testable import BeautyEffects

final class FaceShapeWarpProviderTests: XCTestCase {
    func testFaceSlimCreatesSymmetricCheekPointsMovingInward() {
        let result = FaceShapeWarpProvider().makeControlPoints(
            face: .fixture,
            strengths: strengths(faceSlim: 1)
        )

        XCTAssertNil(result.skipReason)
        XCTAssertEqual(result.points.count, 2)

        let left = try! XCTUnwrap(result.points.first { $0.source.x < 0.5 })
        let right = try! XCTUnwrap(result.points.first { $0.source.x > 0.5 })

        XCTAssertGreaterThan(left.target.x, left.source.x)
        XCTAssertLessThan(right.target.x, right.source.x)
        XCTAssertEqual(abs(left.target.x - left.source.x), abs(right.source.x - right.target.x), accuracy: 0.0001)
        XCTAssertLessThanOrEqual(left.strength, BeautySafetyCaps.faceSlim)
        XCTAssertLessThanOrEqual(right.strength, BeautySafetyCaps.faceSlim)
        XCTAssertTrue((0...1).contains(left.source.x))
        XCTAssertTrue((0...1).contains(right.source.y))
    }

    func testFaceSmallMovesMultipleContourPointsTowardFaceCenter() {
        let face = FaceGeometry.fixture
        let result = FaceShapeWarpProvider().makeControlPoints(
            face: face,
            strengths: strengths(faceSmall: 1)
        )

        XCTAssertGreaterThanOrEqual(result.points.count, 4)
        for point in result.points {
            XCTAssertLessThan(
                LandmarkGeometryHelper.distance(point.target, face.center),
                LandmarkGeometryHelper.distance(point.source, face.center)
            )
            XCTAssertLessThanOrEqual(point.strength, BeautySafetyCaps.faceSmall)
        }
    }

    func testVShapeAndJawSlimProduceOnlyLowerFacePoints() {
        let provider = FaceShapeWarpProvider()
        let face = FaceGeometry.fixture

        let vShape = provider.makeControlPoints(face: face, strengths: strengths(faceVShape: 1))
        let jawSlim = provider.makeControlPoints(face: face, strengths: strengths(jawSlim: 1))

        XCTAssertFalse(vShape.points.isEmpty)
        XCTAssertFalse(jawSlim.points.isEmpty)
        XCTAssertTrue(vShape.points.allSatisfy { $0.source.y >= face.bounds.midY })
        XCTAssertTrue(jawSlim.points.allSatisfy { $0.source.y >= face.bounds.midY })
    }

    func testChinLengthMovesOppositeDirectionsAndCapsStrength() {
        let provider = ChinWarpProvider()
        let face = FaceGeometry.fixture

        let longer = provider.makeControlPoints(face: face, strengths: strengths(chinLength: 1))
        let shorter = provider.makeControlPoints(face: face, strengths: strengths(chinLength: -1))

        let longPoint = try! XCTUnwrap(longer.points.first)
        let shortPoint = try! XCTUnwrap(shorter.points.first)

        XCTAssertGreaterThan(longPoint.target.y, longPoint.source.y)
        XCTAssertLessThan(shortPoint.target.y, shortPoint.source.y)
        XCTAssertLessThanOrEqual(longPoint.strength, BeautySafetyCaps.chinLength)
        XCTAssertLessThanOrEqual(shortPoint.strength, BeautySafetyCaps.chinLength)
    }

    func testMissingFaceContourReturnsNoFaceShapePoints() {
        let result = FaceShapeWarpProvider().makeControlPoints(
            face: .missingContour,
            strengths: strengths(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1)
        )

        XCTAssertTrue(result.points.isEmpty)
        XCTAssertEqual(result.skipReason, "missing_face_contour")
    }

    private func strengths(
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.faceSlim = min(faceSlim, BeautySafetyCaps.faceSlim)
        strengths.faceSmall = min(faceSmall, BeautySafetyCaps.faceSmall)
        strengths.faceVShape = min(faceVShape, BeautySafetyCaps.faceVShape)
        strengths.jawSlim = min(jawSlim, BeautySafetyCaps.jawSlim)
        strengths.chinLength = min(max(chinLength, -BeautySafetyCaps.chinLength), BeautySafetyCaps.chinLength)
        return strengths
    }
}

extension FaceGeometry {
    static let fixture = FaceGeometry(
        bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
        faceContour: [
            SIMD2<Float>(0.31, 0.38),
            SIMD2<Float>(0.34, 0.55),
            SIMD2<Float>(0.39, 0.72),
            SIMD2<Float>(0.50, 0.80),
            SIMD2<Float>(0.61, 0.72),
            SIMD2<Float>(0.66, 0.55),
            SIMD2<Float>(0.69, 0.38)
        ]
    )

    static let missingContour = FaceGeometry(
        bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
        faceContour: []
    )
}
