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

    func testPhase38LegacyMouthEmissionArraysRemainExact() {
        let emissions = MouthWarpProvider().fieldEmissions(
            face: .fixture,
            strengths: strengths(mouthSize: 1, mouthWidth: 1, smile: 1)
        )

        assertPoints(
            emissions.mouthSize,
            sources: [
                SIMD2<Float>(0.42, 0.66),
                SIMD2<Float>(0.58, 0.66),
                SIMD2<Float>(0.50, 0.62),
                SIMD2<Float>(0.50, 0.70)
            ],
            targets: [
                SIMD2<Float>(0.406, 0.66),
                SIMD2<Float>(0.594, 0.66),
                SIMD2<Float>(0.50, 0.606),
                SIMD2<Float>(0.50, 0.714)
            ],
            radius: 0.052,
            strength: BeautySafetyCaps.mouthSize
        )
        assertPoints(
            emissions.mouthWidth,
            sources: [SIMD2<Float>(0.42, 0.66), SIMD2<Float>(0.58, 0.66)],
            targets: [SIMD2<Float>(0.404, 0.66), SIMD2<Float>(0.596, 0.66)],
            radius: 0.044,
            strength: BeautySafetyCaps.mouthWidth
        )
        assertPoints(
            emissions.smile,
            sources: [SIMD2<Float>(0.42, 0.66), SIMD2<Float>(0.58, 0.66)],
            targets: [SIMD2<Float>(0.42, 0.639), SIMD2<Float>(0.58, 0.639)],
            radius: 0.048,
            strength: BeautySafetyCaps.smile
        )
    }

    func testPhase38SignedTranslationsUseUniformAxesAndReverseExactly() {
        let provider = MouthWarpProvider()
        let positiveY = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(mouthYPosition: 1)
        ).mouthYPosition
        let negativeY = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(mouthYPosition: -1)
        ).mouthYPosition
        let positiveX = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(mouthXPosition: 1)
        ).mouthXPosition
        let negativeX = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(mouthXPosition: -1)
        ).mouthXPosition

        XCTAssertEqual(positiveY.map(\.source), FaceGeometry.fixture.outerLips)
        XCTAssertEqual(negativeY.map(\.source), FaceGeometry.fixture.outerLips)
        XCTAssertEqual(positiveX.map(\.source), FaceGeometry.fixture.outerLips)
        XCTAssertEqual(negativeX.map(\.source), FaceGeometry.fixture.outerLips)
        for (positive, negative) in zip(positiveY, negativeY) {
            let positiveDelta = positive.target.y - positive.source.y
            let negativeDelta = negative.target.y - negative.source.y
            XCTAssertEqual(positive.target.x, positive.source.x)
            XCTAssertEqual(negative.target.x, negative.source.x)
            XCTAssertGreaterThan(positiveDelta, 0)
            XCTAssertLessThan(negativeDelta, 0)
            XCTAssertEqual(positiveDelta, -negativeDelta, accuracy: 0.000001)
            XCTAssertEqual(positiveDelta, 0.015, accuracy: 0.000001)
        }
        for (positive, negative) in zip(positiveX, negativeX) {
            let positiveDelta = positive.target.x - positive.source.x
            let negativeDelta = negative.target.x - negative.source.x
            XCTAssertEqual(positive.target.y, positive.source.y)
            XCTAssertEqual(negative.target.y, negative.source.y)
            XCTAssertGreaterThan(positiveDelta, 0)
            XCTAssertLessThan(negativeDelta, 0)
            XCTAssertEqual(positiveDelta, -negativeDelta, accuracy: 0.000001)
            XCTAssertEqual(positiveDelta, 0.010, accuracy: 0.000001)
        }

        let width = provider.fieldEmissions(face: .fixture, strengths: strengths(mouthWidth: 1)).mouthWidth
        XCTAssertNotEqual(vectors(positiveX), vectors(width))
        let smile = provider.fieldEmissions(face: .fixture, strengths: strengths(smile: 1)).smile
        XCTAssertNotEqual(vectors(positiveY), vectors(smile))
    }

    func testPhase38TiltUsesStableClockwiseImageConventionAndOppositeTangents() {
        let provider = MouthWarpProvider()
        let positive = provider.fieldEmissions(face: .fixture, strengths: strengths(mouthTilt: 1)).mouthTilt
        let negative = provider.fieldEmissions(face: .fixture, strengths: strengths(mouthTilt: -1)).mouthTilt
        let center = try! XCTUnwrap(LandmarkGeometryHelper.center(of: FaceGeometry.fixture.outerLips))

        XCTAssertEqual(positive.map(\.source), FaceGeometry.fixture.outerLips)
        XCTAssertEqual(negative.map(\.source), FaceGeometry.fixture.outerLips)
        XCTAssertEqual(positive.map(\.source), negative.map(\.source))
        XCTAssertNotEqual(positive.map(\.target), negative.map(\.target))
        for (clockwise, counterclockwise) in zip(positive, negative) {
            let sourceVector = clockwise.source - center
            let clockwiseDelta = clockwise.target - clockwise.source
            let counterclockwiseDelta = counterclockwise.target - counterclockwise.source
            let clockwiseTangent = sourceVector.x * clockwiseDelta.y - sourceVector.y * clockwiseDelta.x
            let counterclockwiseTangent = sourceVector.x * counterclockwiseDelta.y - sourceVector.y * counterclockwiseDelta.x
            XCTAssertGreaterThan(clockwiseTangent, 0)
            XCTAssertLessThan(counterclockwiseTangent, 0)
            XCTAssertEqual(
                LandmarkGeometryHelper.distance(clockwise.source, center),
                LandmarkGeometryHelper.distance(clockwise.target, center),
                accuracy: 0.000001
            )
            XCTAssertEqual(
                LandmarkGeometryHelper.distance(counterclockwise.source, center),
                LandmarkGeometryHelper.distance(counterclockwise.target, center),
                accuracy: 0.000001
            )
        }
        XCTAssertNotEqual(vectors(positive), vectors(provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(smile: 1)
        ).smile))
    }

    func testPhase38PeakUsesUpperAndInnerForLocalSymmetricCupidBow() {
        let provider = MouthWarpProvider()
        let peak = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(lipPeakDefinition: 1)
        ).lipPeakDefinition
        let sortedUpper = FaceGeometry.fixture.upperLips.sorted { $0.x < $1.x }

        XCTAssertEqual(peak.map(\.source), sortedUpper)
        XCTAssertEqual(peak.count, 3)
        XCTAssertLessThan(peak[0].target.y, peak[0].source.y)
        XCTAssertGreaterThan(peak[1].target.y, peak[1].source.y)
        XCTAssertLessThan(peak[2].target.y, peak[2].source.y)
        XCTAssertEqual(
            peak[0].target.y - peak[0].source.y,
            peak[2].target.y - peak[2].source.y,
            accuracy: 0.000001
        )
        XCTAssertTrue(peak.allSatisfy { $0.target.x == $0.source.x })

        let smile = provider.fieldEmissions(face: .fixture, strengths: strengths(smile: 1)).smile
        let size = provider.fieldEmissions(face: .fixture, strengths: strengths(mouthSize: 1)).mouthSize
        let yPosition = provider.fieldEmissions(face: .fixture, strengths: strengths(mouthYPosition: 1)).mouthYPosition
        XCTAssertNotEqual(vectors(peak), vectors(smile))
        XCTAssertNotEqual(vectors(peak), vectors(size))
        XCTAssertNotEqual(vectors(peak), vectors(yPosition))
    }

    func testPhase38PlumpUsesBothSurfacesAwayFromInnerOpeningAndDoesNotAliasPeak() {
        let provider = MouthWarpProvider()
        let plump = provider.fieldEmissions(face: .fixture, strengths: strengths(lipPlump: 1)).lipPlump
        let peak = provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(lipPeakDefinition: 1)
        ).lipPeakDefinition
        let upper = FaceGeometry.fixture.upperLips.sorted { $0.x < $1.x }
        let lower = FaceGeometry.fixture.lowerLips.sorted { $0.x < $1.x }
        let innerCenter = try! XCTUnwrap(LandmarkGeometryHelper.center(of: FaceGeometry.fixture.innerLips))

        XCTAssertEqual(plump.map(\.source), upper + lower)
        XCTAssertEqual(plump.count, 6)
        for point in plump {
            XCTAssertGreaterThan(
                LandmarkGeometryHelper.distance(point.target, innerCenter),
                LandmarkGeometryHelper.distance(point.source, innerCenter)
            )
        }
        XCTAssertTrue(plump.prefix(upper.count).allSatisfy { $0.target.y < $0.source.y })
        XCTAssertTrue(plump.dropFirst(upper.count).allSatisfy { $0.target.y > $0.source.y })
        XCTAssertNotEqual(vectors(plump), vectors(peak))
        XCTAssertNotEqual(vectors(plump), vectors(provider.fieldEmissions(
            face: .fixture,
            strengths: strengths(mouthSize: 1)
        ).mouthSize))
    }

    func testPhase38EightEmissionsAggregateInCanonicalOrderAndRemainSafe() {
        let provider = MouthWarpProvider()
        let requested = strengths(
            mouthSize: 1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: 1,
            mouthTilt: 1,
            mouthXPosition: 1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let first = provider.fieldEmissions(face: .fixture, strengths: requested)
        let second = provider.fieldEmissions(face: .fixture, strengths: requested)
        let expectedOrder = first.mouthSize + first.mouthWidth + first.smile +
            first.mouthYPosition + first.mouthTilt + first.mouthXPosition +
            first.lipPeakDefinition + first.lipPlump

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.points, expectedOrder)
        XCTAssertTrue([
            first.mouthSize,
            first.mouthWidth,
            first.smile,
            first.mouthYPosition,
            first.mouthTilt,
            first.mouthXPosition,
            first.lipPeakDefinition,
            first.lipPlump
        ].allSatisfy { !$0.isEmpty })
        assertSafe(first.points, in: FaceGeometry.fixture.bounds)
        XCTAssertEqual(first.sanitizing(requested), requested)
    }

    func testPhase38MalformedLocalSupportFailsOnlyDependentFields() {
        struct Row {
            let name: String
            let face: FaceGeometry
            let peakEligible: Bool
            let plumpEligible: Bool
        }
        let fixture = FaceGeometry.fixture
        let flatInner = [
            SIMD2<Float>(0.46, 0.656),
            SIMD2<Float>(0.48, 0.656),
            SIMD2<Float>(0.52, 0.656),
            SIMD2<Float>(0.54, 0.656)
        ]
        let rows = [
            Row(name: "missing upper", face: .missingUpperLips, peakEligible: false, plumpEligible: false),
            Row(name: "missing lower", face: .missingLowerLips, peakEligible: true, plumpEligible: false),
            Row(name: "missing inner", face: .missingInnerLips, peakEligible: false, plumpEligible: false),
            Row(name: "insufficient upper", face: .insufficientUpperLips, peakEligible: false, plumpEligible: false),
            Row(name: "insufficient lower", face: .insufficientLowerLips, peakEligible: true, plumpEligible: false),
            Row(name: "insufficient inner", face: .insufficientInnerLips, peakEligible: false, plumpEligible: false),
            Row(name: "duplicate upper", face: .duplicateUpperLips, peakEligible: false, plumpEligible: false),
            Row(name: "duplicate lower", face: .duplicateLowerLips, peakEligible: true, plumpEligible: false),
            Row(name: "duplicate inner", face: .duplicateInnerLips, peakEligible: false, plumpEligible: false),
            Row(name: "non-finite upper", face: .nonFiniteUpperLips, peakEligible: false, plumpEligible: false),
            Row(name: "non-finite lower", face: .nonFiniteLowerLips, peakEligible: true, plumpEligible: false),
            Row(name: "non-finite inner", face: .nonFiniteInnerLips, peakEligible: false, plumpEligible: false),
            Row(name: "out-of-bounds upper", face: replacing(upperLips: [SIMD2<Float>(1.2, 0.62)] + fixture.upperLips.dropFirst()), peakEligible: false, plumpEligible: false),
            Row(name: "out-of-bounds lower", face: replacing(lowerLips: [SIMD2<Float>(-0.2, 0.69)] + fixture.lowerLips.dropFirst()), peakEligible: true, plumpEligible: false),
            Row(name: "out-of-bounds inner", face: replacing(innerLips: [SIMD2<Float>(0.46, 1.2)] + fixture.innerLips.dropFirst()), peakEligible: false, plumpEligible: false),
            Row(name: "degenerate inner opening", face: replacing(innerLips: flatInner), peakEligible: false, plumpEligible: false)
        ]
        let provider = MouthWarpProvider()

        for row in rows {
            let requested = strengths(mouthYPosition: 1, lipPeakDefinition: 1, lipPlump: 1)
            let emissions = provider.fieldEmissions(face: row.face, strengths: requested)
            let sanitized = emissions.sanitizing(requested)
            XCTAssertFalse(emissions.mouthYPosition.isEmpty, row.name)
            XCTAssertEqual(!emissions.lipPeakDefinition.isEmpty, row.peakEligible, row.name)
            XCTAssertEqual(!emissions.lipPlump.isEmpty, row.plumpEligible, row.name)
            XCTAssertEqual(sanitized.mouthYPosition, requested.mouthYPosition, row.name)
            XCTAssertEqual(sanitized.lipPeakDefinition, row.peakEligible ? requested.lipPeakDefinition : 0, row.name)
            XCTAssertEqual(sanitized.lipPlump, row.plumpEligible ? requested.lipPlump : 0, row.name)
            XCTAssertFalse(emissions.points.isEmpty, row.name)
        }
    }

    func testPhase38MalformedWholeSupportDoesNotMaskValidLocalSiblings() {
        let fixture = FaceGeometry.fixture
        let flatOuter = [
            SIMD2<Float>(0.42, 0.66),
            SIMD2<Float>(0.47, 0.66),
            SIMD2<Float>(0.53, 0.66),
            SIMD2<Float>(0.58, 0.66)
        ]
        let rows: [(String, FaceGeometry)] = [
            ("missing", replacing(outerLips: [])),
            ("one point", replacing(outerLips: [fixture.outerLips[0]])),
            ("duplicate only", replacing(outerLips: Array(repeating: fixture.outerLips[0], count: 4))),
            ("non-finite", replacing(outerLips: [SIMD2<Float>(.nan, 0.66)] + fixture.outerLips.dropFirst())),
            ("out-of-bounds", replacing(outerLips: [SIMD2<Float>(1.2, 0.66)] + fixture.outerLips.dropFirst())),
            ("degenerate", replacing(outerLips: flatOuter))
        ]
        let requested = strengths(
            mouthSize: 1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: 1,
            mouthTilt: 1,
            mouthXPosition: 1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let provider = MouthWarpProvider()

        for (name, face) in rows {
            let emissions = provider.fieldEmissions(face: face, strengths: requested)
            let sanitized = emissions.sanitizing(requested)
            XCTAssertTrue(emissions.mouthSize.isEmpty, name)
            XCTAssertTrue(emissions.mouthWidth.isEmpty, name)
            XCTAssertTrue(emissions.smile.isEmpty, name)
            XCTAssertTrue(emissions.mouthYPosition.isEmpty, name)
            XCTAssertTrue(emissions.mouthTilt.isEmpty, name)
            XCTAssertTrue(emissions.mouthXPosition.isEmpty, name)
            XCTAssertFalse(emissions.lipPeakDefinition.isEmpty, name)
            XCTAssertFalse(emissions.lipPlump.isEmpty, name)
            XCTAssertEqual(sanitized.mouthSize, 0, name)
            XCTAssertEqual(sanitized.mouthYPosition, 0, name)
            XCTAssertEqual(sanitized.lipPeakDefinition, requested.lipPeakDefinition, name)
            XCTAssertEqual(sanitized.lipPlump, requested.lipPlump, name)
            XCTAssertFalse(emissions.points.isEmpty, name)
        }
    }

    func testPhase38DisplacementEmptyAndInvalidBoundsFailClosedPerField() {
        let provider = MouthWarpProvider()
        let tiny = Float.ulpOfOne * 2
        let tinyRequested = strengths(
            mouthYPosition: tiny,
            mouthTilt: tiny,
            mouthXPosition: tiny,
            lipPeakDefinition: tiny,
            lipPlump: tiny
        )
        let tinyEmissions = provider.fieldEmissions(face: .fixture, strengths: tinyRequested)
        let tinySanitized = tinyEmissions.sanitizing(tinyRequested)

        XCTAssertTrue(tinyEmissions.points.isEmpty)
        XCTAssertEqual(tinySanitized.mouthYPosition, 0)
        XCTAssertEqual(tinySanitized.mouthTilt, 0)
        XCTAssertEqual(tinySanitized.mouthXPosition, 0)
        XCTAssertEqual(tinySanitized.lipPeakDefinition, 0)
        XCTAssertEqual(tinySanitized.lipPlump, 0)
        XCTAssertEqual(
            provider.makeControlPoints(face: .fixture, strengths: tinyRequested).skipReason,
            "mouth_inputs_missing"
        )

        let invalidBounds = replacing(bounds: FaceBounds(x: 0.30, y: 0.20, width: .infinity, height: 0.60))
        let allRequested = strengths(
            mouthSize: 1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: 1,
            mouthTilt: 1,
            mouthXPosition: 1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        XCTAssertTrue(provider.fieldEmissions(face: invalidBounds, strengths: allRequested).points.isEmpty)
        XCTAssertEqual(
            provider.makeControlPoints(face: invalidBounds, strengths: allRequested).skipReason,
            "mouth_inputs_missing"
        )
    }

    func testPhase38SkipReasonRequiresRequestedAggregateEmptyWorkAndStaysRedacted() {
        let provider = MouthWarpProvider()
        XCTAssertNil(provider.makeControlPoints(face: .missingMouth, strengths: strengths()).skipReason)

        let failedLocal = provider.makeControlPoints(
            face: .missingInnerLips,
            strengths: strengths(lipPeakDefinition: 1, lipPlump: 1)
        )
        XCTAssertTrue(failedLocal.points.isEmpty)
        XCTAssertEqual(failedLocal.skipReason, "mouth_inputs_missing")

        let mixed = provider.makeControlPoints(
            face: .missingInnerLips,
            strengths: strengths(mouthXPosition: 1, lipPeakDefinition: 1, lipPlump: 1)
        )
        XCTAssertFalse(mixed.points.isEmpty)
        XCTAssertNil(mixed.skipReason)

        let diagnostic = [failedLocal.skipReason, mixed.skipReason]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
        for forbidden in ["upper", "lower", "inner", "support", "coordinate", "simd", "bounds", "point["] {
            XCTAssertFalse(diagnostic.contains(forbidden), forbidden)
        }
    }

    private func strengths(
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0,
        mouthYPosition: Float = 0,
        mouthTilt: Float = 0,
        mouthXPosition: Float = 0,
        lipPeakDefinition: Float = 0,
        lipPlump: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.mouthSize = min(max(mouthSize, -BeautySafetyCaps.mouthSize), BeautySafetyCaps.mouthSize)
        strengths.mouthWidth = min(max(mouthWidth, -BeautySafetyCaps.mouthWidth), BeautySafetyCaps.mouthWidth)
        strengths.smile = min(smile, BeautySafetyCaps.smile)
        strengths.mouthYPosition = min(max(mouthYPosition, -BeautySafetyCaps.mouthYPosition), BeautySafetyCaps.mouthYPosition)
        strengths.mouthTilt = min(max(mouthTilt, -BeautySafetyCaps.mouthTilt), BeautySafetyCaps.mouthTilt)
        strengths.mouthXPosition = min(max(mouthXPosition, -BeautySafetyCaps.mouthXPosition), BeautySafetyCaps.mouthXPosition)
        strengths.lipPeakDefinition = min(lipPeakDefinition, BeautySafetyCaps.lipPeakDefinition)
        strengths.lipPlump = min(lipPlump, BeautySafetyCaps.lipPlump)
        return strengths
    }

    private func vectors(_ points: [WarpControlPoint]) -> [SIMD2<Float>] {
        points.map { $0.target - $0.source }
    }

    private func assertPoints(
        _ points: [WarpControlPoint],
        sources: [SIMD2<Float>],
        targets: [SIMD2<Float>],
        radius: Float,
        strength: Float,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(points.count, sources.count, file: file, line: line)
        XCTAssertEqual(points.count, targets.count, file: file, line: line)
        for (index, point) in points.enumerated() {
            XCTAssertEqual(point.source.x, sources[index].x, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(point.source.y, sources[index].y, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(point.target.x, targets[index].x, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(point.target.y, targets[index].y, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(point.radius, radius, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(point.strength, strength, accuracy: 0.000001, file: file, line: line)
            XCTAssertEqual(point.falloff, 2, file: file, line: line)
        }
    }

    private func assertSafe(
        _ points: [WarpControlPoint],
        in bounds: FaceBounds,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(points.isEmpty, file: file, line: line)
        for point in points {
            XCTAssertTrue(point.source.x.isFinite && point.source.y.isFinite, file: file, line: line)
            XCTAssertTrue(point.target.x.isFinite && point.target.y.isFinite, file: file, line: line)
            XCTAssertTrue(point.radius.isFinite && point.strength.isFinite && point.falloff.isFinite, file: file, line: line)
            XCTAssertTrue((0...1).contains(point.source.x) && (0...1).contains(point.source.y), file: file, line: line)
            XCTAssertTrue((0...1).contains(point.target.x) && (0...1).contains(point.target.y), file: file, line: line)
            XCTAssertTrue((bounds.minX...bounds.maxX).contains(point.source.x), file: file, line: line)
            XCTAssertTrue((bounds.minY...bounds.maxY).contains(point.source.y), file: file, line: line)
            XCTAssertTrue((bounds.minX...bounds.maxX).contains(point.target.x), file: file, line: line)
            XCTAssertTrue((bounds.minY...bounds.maxY).contains(point.target.y), file: file, line: line)
            XCTAssertGreaterThan(LandmarkGeometryHelper.distance(point.source, point.target), Float.ulpOfOne, file: file, line: line)
            XCTAssertTrue((0.035...0.20).contains(point.radius), file: file, line: line)
            XCTAssertGreaterThan(point.strength, 0, file: file, line: line)
            XCTAssertLessThanOrEqual(point.strength, BeautySafetyCaps.smile, file: file, line: line)
            XCTAssertEqual(point.falloff, 2, file: file, line: line)
        }
    }

    private func replacing(
        bounds: FaceBounds = FaceGeometry.fixture.bounds,
        outerLips: [SIMD2<Float>] = FaceGeometry.fixture.outerLips,
        upperLips: [SIMD2<Float>] = FaceGeometry.fixture.upperLips,
        lowerLips: [SIMD2<Float>] = FaceGeometry.fixture.lowerLips,
        innerLips: [SIMD2<Float>] = FaceGeometry.fixture.innerLips
    ) -> FaceGeometry {
        let fixture = FaceGeometry.fixture
        return FaceGeometry(
            bounds: bounds,
            faceContour: fixture.faceContour,
            leftEye: fixture.leftEye,
            rightEye: fixture.rightEye,
            nose: fixture.nose,
            noseRoot: fixture.noseRoot,
            noseTip: fixture.noseTip,
            outerLips: outerLips,
            upperLips: upperLips,
            lowerLips: lowerLips,
            innerLips: innerLips,
            freshness: fixture.freshness
        )
    }
}
