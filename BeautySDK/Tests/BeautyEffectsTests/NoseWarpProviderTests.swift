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

    func testNoseTipSizePreservesOppositeSignedDirections() {
        let provider = NoseWarpProvider()
        let positive = provider.makeControlPoints(face: .fixture, strengths: strengths(noseTipSize: 1))
        let negative = provider.makeControlPoints(face: .fixture, strengths: strengths(noseTipSize: -1))

        XCTAssertFalse(positive.points.isEmpty)
        XCTAssertEqual(positive.points.map(\.source), negative.points.map(\.source))
        XCTAssertNotEqual(positive.points.map(\.target), negative.points.map(\.target))
        for (positivePoint, negativePoint) in zip(positive.points, negative.points) {
            XCTAssertGreaterThan(
                LandmarkGeometryHelper.distance(negativePoint.target, positivePoint.target),
                Float.ulpOfOne
            )
            XCTAssertEqual(positivePoint.strength, BeautySafetyCaps.noseTipSize, accuracy: 0.0001)
            XCTAssertEqual(negativePoint.strength, BeautySafetyCaps.noseTipSize, accuracy: 0.0001)
        }
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

    func testNoseRootNarrowingProducesSymmetricHorizontalBoundedVectors() {
        let provider = NoseWarpProvider()
        let first = provider.makeControlPoints(
            face: .fixture,
            strengths: strengths(noseRootNarrowing: 1)
        )
        let second = provider.makeControlPoints(
            face: .fixture,
            strengths: strengths(noseRootNarrowing: 1)
        )

        XCTAssertEqual(first, second)
        XCTAssertNil(first.skipReason)
        XCTAssertEqual(first.points.map(\.source), FaceGeometry.fixture.noseRoot.sorted { $0.x < $1.x })
        XCTAssertEqual(first.points.count, 2)
        let left = first.points[0]
        let right = first.points[1]
        let leftDelta = left.target.x - left.source.x
        let rightDelta = right.target.x - right.source.x
        XCTAssertGreaterThan(leftDelta, 0)
        XCTAssertLessThan(rightDelta, 0)
        XCTAssertEqual(abs(leftDelta), abs(rightDelta), accuracy: 0.0001)
        XCTAssertEqual(left.target.y, left.source.y)
        XCTAssertEqual(right.target.y, right.source.y)
        XCTAssertLessThan(left.target.x, FaceGeometry.fixture.bounds.midX)
        XCTAssertGreaterThan(right.target.x, FaceGeometry.fixture.bounds.midX)
        assertSafe(points: first.points, strength: BeautySafetyCaps.noseRootNarrowing)
        let emissions = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(noseSlim: 1, noseRootNarrowing: 1, noseTipLift: 1)
        )
        XCTAssertFalse(emissions.noseSlim.isEmpty)
        XCTAssertFalse(emissions.noseRootNarrowing.isEmpty)
        XCTAssertFalse(emissions.noseTipLift.isEmpty)
    }

    func testNoseTipLiftProducesDeterministicVerticalUpwardBoundedVectors() {
        let provider = NoseWarpProvider()
        let first = provider.makeControlPoints(
            face: .fixture,
            strengths: strengths(noseTipLift: 1)
        )
        let second = provider.makeControlPoints(
            face: .fixture,
            strengths: strengths(noseTipLift: 1)
        )
        let expectedSources = FaceGeometry.fixture.noseTip.sorted {
            $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x
        }

        XCTAssertEqual(first, second)
        XCTAssertNil(first.skipReason)
        XCTAssertEqual(first.points.map(\.source), expectedSources)
        XCTAssertFalse(first.points.isEmpty)
        XCTAssertTrue(first.points.allSatisfy { $0.source.y >= FaceGeometry.fixture.bounds.midY })
        XCTAssertTrue(first.points.allSatisfy { $0.target.x == $0.source.x })
        XCTAssertTrue(first.points.allSatisfy { $0.target.y < $0.source.y })
        assertSafe(points: first.points, strength: BeautySafetyCaps.noseTipLift)
    }

    func testNewNoseVectorsDoNotAliasLegacyBridgeOrSignedTipSize() {
        let provider = NoseWarpProvider()
        let root = provider.makeControlPoints(face: .fixture, strengths: strengths(noseRootNarrowing: 1))
        let bridge = provider.makeControlPoints(face: .fixture, strengths: strengths(noseBridge: 1))
        let lift = provider.makeControlPoints(face: .fixture, strengths: strengths(noseTipLift: 1))
        let positiveTip = provider.makeControlPoints(face: .fixture, strengths: strengths(noseTipSize: 1))
        let negativeTip = provider.makeControlPoints(face: .fixture, strengths: strengths(noseTipSize: -1))

        assertDifferentVectors(root, bridge)
        assertDifferentVectors(lift, positiveTip)
        assertDifferentVectors(lift, negativeTip)
    }

    func testMalformedRootSupportsFailClosedWithoutLegacySubstitution() {
        let malformed: [(String, FaceGeometry)] = [
            ("empty", .missingNose),
            ("one-point", .onePointNoseRoot),
            ("non-finite", .nonFiniteNoseRoot),
            ("same-side", .sameSideNoseRoot),
            ("asymmetric", .asymmetricNoseRoot),
            ("degenerate", .degenerateNoseRoot),
            ("unequal-y", replacingRoot([SIMD2<Float>(0.476, 0.487), SIMD2<Float>(0.524, 0.489)])),
            ("out-of-bounds", replacingRoot([SIMD2<Float>(-0.024, 0.488), SIMD2<Float>(1.024, 0.488)]))
        ]

        for (name, face) in malformed {
            let result = NoseWarpProvider().makeControlPoints(
                face: face,
                strengths: strengths(noseRootNarrowing: 1)
            )
            XCTAssertTrue(result.points.isEmpty, name)
            XCTAssertEqual(result.skipReason, "nose_inputs_missing", name)
            XCTAssertTrue(
                NoseWarpProvider()
                    .fieldEmissions(face: face, strengths: strengths(noseRootNarrowing: 1))
                    .noseRootNarrowing
                    .isEmpty,
                name
            )
        }
    }

    func testMalformedTipSupportsFailClosedWithoutLegacySubstitution() {
        let malformed: [(String, FaceGeometry)] = [
            ("empty", .missingNose),
            ("one-point", .onePointNoseTip),
            ("non-finite", .nonFiniteNoseTip),
            ("degenerate", .degenerateNoseTip),
            ("upper", replacingTip([SIMD2<Float>(0.476, 0.40), SIMD2<Float>(0.524, 0.40)])),
            ("out-of-bounds", replacingTip([SIMD2<Float>(0.476, 1.20), SIMD2<Float>(0.524, 1.20)]))
        ]

        for (name, face) in malformed {
            let result = NoseWarpProvider().makeControlPoints(
                face: face,
                strengths: strengths(noseTipLift: 1)
            )
            XCTAssertTrue(result.points.isEmpty, name)
            XCTAssertEqual(result.skipReason, "nose_inputs_missing", name)
            XCTAssertTrue(
                NoseWarpProvider()
                    .fieldEmissions(face: face, strengths: strengths(noseTipLift: 1))
                    .noseTipLift
                    .isEmpty,
                name
            )
        }
    }

    func testNewNoseFieldsDoNotDependOnLegacyNoseCenterGuard() {
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: [],
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
        let provider = NoseWarpProvider()

        let root = provider.makeControlPoints(face: face, strengths: strengths(noseRootNarrowing: 1))
        let tip = provider.makeControlPoints(face: face, strengths: strengths(noseTipLift: 1))

        XCTAssertFalse(root.points.isEmpty)
        XCTAssertFalse(tip.points.isEmpty)
        XCTAssertNil(root.skipReason)
        XCTAssertNil(tip.skipReason)
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(noseSlim: 1, noseRootNarrowing: 1, noseTipLift: 1)
        )
        XCTAssertTrue(emissions.noseSlim.isEmpty)
        XCTAssertFalse(emissions.noseRootNarrowing.isEmpty)
        XCTAssertFalse(emissions.noseTipLift.isEmpty)
    }

    func testLegacyFieldEmissionsUseEachHelpersActualPrerequisites() {
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: [SIMD2<Float>(0.50, 0.52)],
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
        let requested = strengths(
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1
        )
        let emissions = NoseWarpProvider().fieldEmissions(
            face: face,
            strengths: requested
        )
        let sanitized = emissions.sanitizing(requested)

        XCTAssertTrue(emissions.noseSlim.isEmpty)
        XCTAssertFalse(emissions.noseWingSlim.isEmpty)
        XCTAssertFalse(emissions.noseTipSize.isEmpty)
        XCTAssertFalse(emissions.noseBridge.isEmpty)
        XCTAssertFalse(emissions.noseRootNarrowing.isEmpty)
        XCTAssertEqual(emissions.points.count, 5)
        XCTAssertEqual(sanitized.noseSlim, 0)
        XCTAssertEqual(sanitized.noseWingSlim, requested.noseWingSlim)
        XCTAssertEqual(sanitized.noseTipSize, requested.noseTipSize)
        XCTAssertEqual(sanitized.noseBridge, requested.noseBridge)
        XCTAssertEqual(sanitized.noseRootNarrowing, requested.noseRootNarrowing)
    }

    func testIndependentFieldEmissionsIncludeStrengthAndDisplacementGuards() {
        let nearCenterRoot = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: FaceGeometry.fixture.nose,
            noseRoot: [
                SIMD2<Float>(0.49989995, 0.488),
                SIMD2<Float>(0.50010005, 0.488)
            ],
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
        let provider = NoseWarpProvider()
        let rootBlocked = provider.fieldEmissions(
            face: nearCenterRoot,
            strengths: strengths(noseRootNarrowing: 1, noseTipLift: 1)
        )
        let tinyTip = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(
                noseRootNarrowing: 1,
                noseTipLift: Float.ulpOfOne * 2
            )
        )

        XCTAssertTrue(rootBlocked.noseRootNarrowing.isEmpty)
        XCTAssertFalse(rootBlocked.noseTipLift.isEmpty)
        XCTAssertFalse(tinyTip.noseRootNarrowing.isEmpty)
        XCTAssertTrue(tinyTip.noseTipLift.isEmpty)

        let legacyThreshold = strengths(noseTipSize: Float.ulpOfOne)
        let legacyThresholdEmissions = provider.fieldEmissions(face: .fixture, strengths: legacyThreshold)
        XCTAssertEqual(legacyThresholdEmissions.sanitizing(legacyThreshold).noseTipSize, 0)
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
        noseBridge: Float = 0,
        noseRootNarrowing: Float = 0,
        noseTipLift: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.noseSlim = min(noseSlim, BeautySafetyCaps.noseSlim)
        strengths.noseWingSlim = min(noseWingSlim, BeautySafetyCaps.noseWingSlim)
        strengths.noseTipSize = min(max(noseTipSize, -BeautySafetyCaps.noseTipSize), BeautySafetyCaps.noseTipSize)
        strengths.noseBridge = min(noseBridge, BeautySafetyCaps.noseBridge)
        strengths.noseRootNarrowing = min(max(noseRootNarrowing, 0), BeautySafetyCaps.noseRootNarrowing)
        strengths.noseTipLift = min(max(noseTipLift, 0), BeautySafetyCaps.noseTipLift)
        return strengths
    }

    private func assertSafe(
        points: [WarpControlPoint],
        strength: Float,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(points.allSatisfy { point in
            point.source.x.isFinite && point.source.y.isFinite &&
                point.target.x.isFinite && point.target.y.isFinite &&
                (0...1).contains(point.source.x) && (0...1).contains(point.source.y) &&
                (0...1).contains(point.target.x) && (0...1).contains(point.target.y) &&
                (0.03...0.20).contains(point.radius) &&
                point.falloff == 2
        }, file: file, line: line)
        XCTAssertTrue(points.allSatisfy { abs($0.target.x - $0.source.x) > Float.ulpOfOne ||
            abs($0.target.y - $0.source.y) > Float.ulpOfOne
        }, file: file, line: line)
        XCTAssertTrue(points.allSatisfy { abs($0.strength - strength) <= 0.0001 }, file: file, line: line)
    }

    private func assertDifferentVectors(
        _ lhs: WarpControlPointResult,
        _ rhs: WarpControlPointResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNotEqual(lhs, rhs, file: file, line: line)
        XCTAssertNotEqual(lhs.points.map(\.source), rhs.points.map(\.source), file: file, line: line)
        XCTAssertNotEqual(lhs.points.map(\.target), rhs.points.map(\.target), file: file, line: line)
        XCTAssertNotEqual(
            lhs.points.map { $0.target - $0.source },
            rhs.points.map { $0.target - $0.source },
            file: file,
            line: line
        )
    }

    private func replacingRoot(_ root: [SIMD2<Float>]) -> FaceGeometry {
        FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: FaceGeometry.fixture.nose,
            noseRoot: root,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
    }

    private func replacingTip(_ tip: [SIMD2<Float>]) -> FaceGeometry {
        FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: FaceGeometry.fixture.nose,
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: tip,
            outerLips: FaceGeometry.fixture.outerLips
        )
    }
}
