import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class FaceShapeWarpProviderTests: XCTestCase {
    func testFaceGeometryAdapterKeepsLegacyNoseAndAddsExplicitRootAndTipSupports() {
        let bounds = CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60)
        let complete = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        )
        let missingNoseGroups = Set(BeautyLandmarkGroup.allCases).subtracting([.nose])
        let missing = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: bounds,
                landmarks: BeautyFaceLandmarks(availableGroups: missingNoseGroups)
            )
        )

        assertPoints(complete.nose, equalTo: [
            SIMD2<Float>(0.484, 0.458),
            SIMD2<Float>(0.500, 0.530),
            SIMD2<Float>(0.460, 0.584),
            SIMD2<Float>(0.540, 0.584)
        ])
        assertPoints(complete.noseRoot, equalTo: [
            SIMD2<Float>(0.476, 0.488),
            SIMD2<Float>(0.524, 0.488)
        ])
        assertPoints(complete.noseTip, equalTo: [
            SIMD2<Float>(0.476, 0.572),
            SIMD2<Float>(0.500, 0.596),
            SIMD2<Float>(0.524, 0.572)
        ])
        XCTAssertTrue(missing.nose.isEmpty)
        XCTAssertTrue(missing.noseRoot.isEmpty)
        XCTAssertTrue(missing.noseTip.isEmpty)
    }

    private func assertPoints(
        _ actual: [SIMD2<Float>],
        equalTo expected: [SIMD2<Float>],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual.count, expected.count, file: file, line: line)
        for (actualPoint, expectedPoint) in zip(actual, expected) {
            XCTAssertEqual(actualPoint.x, expectedPoint.x, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(actualPoint.y, expectedPoint.y, accuracy: 0.000001, file: file, line: line)
        }
    }

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

    func testFaceShapeOutputsAreDeterministicClampedAndProportionAdjacent() {
        let face = FaceGeometry.fixture
        let provider = FaceShapeWarpProvider()
        let partialStrengths = strengths(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1
        )

        let first = provider.makeControlPoints(face: face, strengths: partialStrengths)
        let second = provider.makeControlPoints(face: face, strengths: partialStrengths)

        XCTAssertEqual(first, second)
        XCTAssertFalse(first.points.isEmpty)
        XCTAssertTrue(first.points.allSatisfy { point in
            (0...1).contains(point.source.x) &&
                (0...1).contains(point.source.y) &&
                (0...1).contains(point.target.x) &&
                (0...1).contains(point.target.y)
        })
        XCTAssertTrue(first.points.allSatisfy { $0.radius >= 0.04 && $0.radius <= 0.35 })
        XCTAssertTrue(first.points.allSatisfy { $0.strength <= BeautySafetyCaps.faceSlim })

        let faceSmallOnly = provider.makeControlPoints(face: face, strengths: strengths(faceSmall: 1))
        XCTAssertGreaterThanOrEqual(faceSmallOnly.points.count, face.faceContour.count)
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

    func testJawSlimEvidenceCoversJawAngleAndAliasBackedJawline() {
        let provider = FaceShapeWarpProvider()
        let face = FaceGeometry.fixture

        let result = provider.makeControlPoints(face: face, strengths: strengths(jawSlim: 1))

        XCTAssertNil(result.skipReason)
        XCTAssertEqual(result.points.count, 2)
        XCTAssertTrue(result.points.allSatisfy { $0.source.y >= face.bounds.midY })
        XCTAssertTrue(result.points.allSatisfy { $0.target.y == $0.source.y })
        XCTAssertTrue(result.points.allSatisfy { $0.strength <= BeautySafetyCaps.jawSlim })

        let left = try! XCTUnwrap(result.points.first { $0.source.x < face.center.x })
        let right = try! XCTUnwrap(result.points.first { $0.source.x > face.center.x })
        XCTAssertGreaterThan(left.target.x, left.source.x)
        XCTAssertLessThan(right.target.x, right.source.x)
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

    func testChinLengthOutputIsDeterministicAndClamped() {
        let provider = ChinWarpProvider()
        let face = FaceGeometry.fixture

        let first = provider.makeControlPoints(face: face, strengths: strengths(chinLength: 1))
        let second = provider.makeControlPoints(face: face, strengths: strengths(chinLength: 1))

        XCTAssertEqual(first, second)
        let point = try! XCTUnwrap(first.points.first)
        XCTAssertTrue((0...1).contains(point.source.x))
        XCTAssertTrue((0...1).contains(point.source.y))
        XCTAssertTrue((0...1).contains(point.target.x))
        XCTAssertTrue((0...1).contains(point.target.y))
        XCTAssertLessThanOrEqual(point.strength, BeautySafetyCaps.chinLength)
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
        ],
        leftEye: [
            SIMD2<Float>(0.39, 0.39),
            SIMD2<Float>(0.43, 0.37),
            SIMD2<Float>(0.46, 0.39)
        ],
        rightEye: [
            SIMD2<Float>(0.54, 0.39),
            SIMD2<Float>(0.57, 0.37),
            SIMD2<Float>(0.61, 0.39)
        ],
        nose: [
            SIMD2<Float>(0.48, 0.45),
            SIMD2<Float>(0.50, 0.52),
            SIMD2<Float>(0.46, 0.58),
            SIMD2<Float>(0.54, 0.58)
        ],
        noseRoot: [
            SIMD2<Float>(0.476, 0.488),
            SIMD2<Float>(0.524, 0.488)
        ],
        noseTip: [
            SIMD2<Float>(0.476, 0.572),
            SIMD2<Float>(0.500, 0.596),
            SIMD2<Float>(0.524, 0.572)
        ],
        outerLips: [
            SIMD2<Float>(0.42, 0.66),
            SIMD2<Float>(0.46, 0.63),
            SIMD2<Float>(0.50, 0.62),
            SIMD2<Float>(0.54, 0.63),
            SIMD2<Float>(0.58, 0.66),
            SIMD2<Float>(0.54, 0.69),
            SIMD2<Float>(0.50, 0.70),
            SIMD2<Float>(0.46, 0.69)
        ]
    )

    static let missingContour = FaceGeometry(
        bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
        faceContour: []
    )

    static let missingLeftEye = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: [],
        rightEye: fixture.rightEye,
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips
    )

    static let missingRightEye = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: [],
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips
    )

    static let missingNose = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: [],
        noseRoot: [],
        noseTip: []
    )

    static let missingLegacyNose = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: [],
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips
    )

    static let onePointLegacyNose = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: [SIMD2<Float>(0.50, 0.52)],
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips
    )

    static let onePointNoseRoot = replacingNoseRoot([fixture.noseRoot[0]])

    static let nonFiniteNoseRoot = replacingNoseRoot([
        SIMD2<Float>(.nan, fixture.noseRoot[0].y),
        fixture.noseRoot[1]
    ])

    static let sameSideNoseRoot = replacingNoseRoot([
        SIMD2<Float>(0.510, 0.488),
        SIMD2<Float>(0.524, 0.488)
    ])

    static let asymmetricNoseRoot = replacingNoseRoot([
        SIMD2<Float>(0.470, 0.488),
        SIMD2<Float>(0.524, 0.488)
    ])

    static let degenerateNoseRoot = replacingNoseRoot([
        SIMD2<Float>(0.476, 0.488),
        SIMD2<Float>(0.476, 0.488)
    ])

    static let onePointNoseTip = replacingNoseTip([fixture.noseTip[0]])

    static let nonFiniteNoseTip = replacingNoseTip([
        SIMD2<Float>(fixture.noseTip[0].x, .infinity),
        fixture.noseTip[1]
    ])

    static let degenerateNoseTip = replacingNoseTip([
        SIMD2<Float>(0.500, 0.596),
        SIMD2<Float>(0.500, 0.596)
    ])

    static let missingMouth = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: []
    )

    static let reused = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips,
        freshness: .reused
    )

    static let stale = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips,
        freshness: .stale
    )

    private static func replacingNoseRoot(_ noseRoot: [SIMD2<Float>]) -> FaceGeometry {
        FaceGeometry(
            bounds: fixture.bounds,
            faceContour: fixture.faceContour,
            leftEye: fixture.leftEye,
            rightEye: fixture.rightEye,
            nose: fixture.nose,
            noseRoot: noseRoot,
            noseTip: fixture.noseTip,
            outerLips: fixture.outerLips,
            freshness: fixture.freshness
        )
    }

    private static func replacingNoseTip(_ noseTip: [SIMD2<Float>]) -> FaceGeometry {
        FaceGeometry(
            bounds: fixture.bounds,
            faceContour: fixture.faceContour,
            leftEye: fixture.leftEye,
            rightEye: fixture.rightEye,
            nose: fixture.nose,
            noseRoot: fixture.noseRoot,
            noseTip: noseTip,
            outerLips: fixture.outerLips,
            freshness: fixture.freshness
        )
    }
}
