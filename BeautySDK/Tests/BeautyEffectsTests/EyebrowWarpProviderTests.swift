import XCTest
@testable import BeautyEffects
@testable import BeautyDetection

final class EyebrowWarpProviderTests: XCTestCase {
    private enum EdgePredicate: String, CaseIterable {
        case sideLocalValidity
        case pairedSpacingEligibility
        case canonicalInnerOuterOrder
        case finiteUnitBounds
        case traceCardinality
        case uniqueInteriorApex
        case nondegenerateChord
        case fieldLocalSanitizing
        case siblingProviderEquality
        case mirroredDirection
        case stableConcatenationOrder
        case requestIsolation
        case concurrencyIsolation
        case adjacencyConflict
        case monotoneRemoval
        case providerEmpty
        case unrelatedContinuation
    }

    private let bounds = FaceBounds(x: 0.1, y: 0.1, width: 0.8, height: 0.8)

    private func trace(
        leftSide: Bool,
        points: [SIMD2<Float>]? = nil,
        apexIndex: Int? = 2
    ) -> BeautyEyebrowSemanticTrace {
        let canonical = points ?? (leftSide
            ? [SIMD2<Float>(0.25, 0.40), SIMD2<Float>(0.30, 0.36), SIMD2<Float>(0.36, 0.34), SIMD2<Float>(0.42, 0.37), SIMD2<Float>(0.47, 0.41)]
            : [SIMD2<Float>(0.75, 0.40), SIMD2<Float>(0.70, 0.36), SIMD2<Float>(0.64, 0.34), SIMD2<Float>(0.58, 0.37), SIMD2<Float>(0.53, 0.41)])
        return BeautyEyebrowSemanticTrace(
            side: leftSide ? .left : .right,
            points: canonical,
            innerEndpoint: canonical[0],
            outerEndpoint: canonical[canonical.count - 1],
            center: canonical.reduce(SIMD2<Float>.zero, +) / Float(canonical.count),
            apexIndex: apexIndex
        )
    }

    private func face(
        left: BeautyEyebrowSemanticTrace? = nil,
        right: BeautyEyebrowSemanticTrace? = nil
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: bounds,
            faceContour: [SIMD2<Float>(0.1, 0.2), SIMD2<Float>(0.5, 0.9), SIMD2<Float>(0.9, 0.2)],
            leftEye: [SIMD2<Float>(0.30, 0.50), SIMD2<Float>(0.40, 0.50)],
            rightEye: [SIMD2<Float>(0.60, 0.50), SIMD2<Float>(0.70, 0.50)],
            nose: [SIMD2<Float>(0.50, 0.55)],
            outerLips: [SIMD2<Float>(0.45, 0.75), SIMD2<Float>(0.55, 0.75)],
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(left: left, right: right)
        )
    }

    private func yStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowYPosition = value; return valueSet }
    private func thicknessStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowThickness = value; return valueSet }
    private func lengthStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowLength = value; return valueSet }
    private func spacingStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowSpacing = value; return valueSet }
    private func headSpacingStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowHeadSpacing = value; return valueSet }
    private func tiltStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowTilt = value; return valueSet }
    private func peakStrength(_ value: Float) -> BeautyEffectiveStrengths { var valueSet = BeautyEffectiveStrengths(); valueSet.eyebrowPeakDefinition = value; return valueSet }

    private func assertRenderable(_ points: [WarpControlPoint], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(points.isEmpty, file: file, line: line)
        for point in points {
            XCTAssertTrue(point.source.x.isFinite && point.source.y.isFinite, file: file, line: line)
            XCTAssertTrue(point.target.x.isFinite && point.target.y.isFinite, file: file, line: line)
            XCTAssertTrue((0...1).contains(point.source.x) && (0...1).contains(point.source.y), file: file, line: line)
            XCTAssertTrue((0...1).contains(point.target.x) && (0...1).contains(point.target.y), file: file, line: line)
            XCTAssertGreaterThan(point.radius, 0, file: file, line: line)
            XCTAssertGreaterThan(point.falloff, 0, file: file, line: line)
        }
    }

    func testGEOM01VerticalPositionNamedEmission() {
        let geometry = face(left: trace(leftSide: true), right: trace(leftSide: false))
        let positive = EyebrowWarpProvider().fieldEmissions(face: geometry, strengths: yStrength(0.25))
        let negative = EyebrowWarpProvider().fieldEmissions(face: geometry, strengths: yStrength(-0.25))
        assertRenderable(positive.eyebrowYPosition)
        XCTAssertEqual(positive.eyebrowYPosition.map { $0.source }, negative.eyebrowYPosition.map { $0.source })
        XCTAssertTrue(zip(positive.eyebrowYPosition, negative.eyebrowYPosition).allSatisfy { ($0.target.y - $0.source.y) * ($1.target.y - $1.source.y) < 0 })
    }

    func testGEOM02ThicknessNamedEmission() {
        let geometry = face(left: trace(leftSide: true), right: trace(leftSide: false))
        let emissions = EyebrowWarpProvider().fieldEmissions(face: geometry, strengths: thicknessStrength(0.25))
        assertRenderable(emissions.eyebrowThickness)
        XCTAssertEqual(emissions.eyebrowThickness.count % 2, 0, "balanced normal-strip samples")
        XCTAssertNotEqual(emissions.eyebrowThickness, emissions.eyebrowYPosition)
    }

    func testGEOM03LengthNamedEmission() {
        let left = trace(leftSide: true)
        let emissions = EyebrowWarpProvider().fieldEmissions(face: face(left: left), strengths: lengthStrength(0.25))
        assertRenderable(emissions.eyebrowLength)
        XCTAssertTrue(emissions.eyebrowLength.allSatisfy { $0.source != left.innerEndpoint })
    }

    func testGEOM04WholeSpacingNamedEmission() {
        let left = trace(leftSide: true)
        let right = trace(leftSide: false)
        let provider = EyebrowWarpProvider()
        let paired = provider.fieldEmissions(face: face(left: left, right: right), strengths: spacingStrength(0.25))
        let single = provider.fieldEmissions(face: face(left: left), strengths: spacingStrength(0.25))
        assertRenderable(paired.eyebrowSpacing)
        XCTAssertTrue(single.eyebrowSpacing.isEmpty, "whole spacing is pair-only")
        XCTAssertTrue(paired.eyebrowSpacing.contains { $0.target.x < $0.source.x })
        XCTAssertTrue(paired.eyebrowSpacing.contains { $0.target.x > $0.source.x })
    }

    func testGEOM05HeadSpacingNamedEmission() {
        let left = trace(leftSide: true)
        let emissions = EyebrowWarpProvider().fieldEmissions(face: face(left: left), strengths: headSpacingStrength(0.25))
        assertRenderable(emissions.eyebrowHeadSpacing)
        XCTAssertTrue(emissions.eyebrowHeadSpacing.contains { $0.source == left.innerEndpoint })
        XCTAssertFalse(emissions.eyebrowHeadSpacing.contains { $0.source == left.outerEndpoint })
    }

    func testGEOM06TiltNamedEmission() {
        let provider = EyebrowWarpProvider()
        let geometry = face(left: trace(leftSide: true), right: trace(leftSide: false))
        let positive = provider.fieldEmissions(face: geometry, strengths: tiltStrength(0.25)).eyebrowTilt
        let negative = provider.fieldEmissions(face: geometry, strengths: tiltStrength(-0.25)).eyebrowTilt
        assertRenderable(positive)
        XCTAssertEqual(positive.map { $0.source }, negative.map { $0.source })
        XCTAssertNotEqual(positive.map { $0.target }, negative.map { $0.target }, "signed canonical-chord rotation")
    }

    func testGEOM07PeakNamedEmission() {
        let provider = EyebrowWarpProvider()
        let eligible = provider.fieldEmissions(face: face(left: trace(leftSide: true)), strengths: peakStrength(0.25))
        let noApex = provider.fieldEmissions(face: face(left: trace(leftSide: true, apexIndex: nil)), strengths: peakStrength(0.25))
        let negative = provider.fieldEmissions(face: face(left: trace(leftSide: true)), strengths: peakStrength(-0.25))
        assertRenderable(eligible.eyebrowPeakDefinition)
        XCTAssertTrue(noApex.eyebrowPeakDefinition.isEmpty)
        XCTAssertTrue(negative.eyebrowPeakDefinition.isEmpty, "peak is positive-only")
    }

    func testSeventeenFlaggedPredicatesRemainExecutableVocabulary() {
        XCTAssertEqual(EdgePredicate.allCases.count, 17)
        XCTAssertEqual(Set(EdgePredicate.allCases.map(\.rawValue)).count, 17)
    }

    func testFieldLocalSanitizingStableOrderAndProviderEmpty() {
        var requested = BeautyEffectiveStrengths()
        requested.eyebrowYPosition = 0.25
        requested.eyebrowSpacing = 0.25
        let emissions = EyebrowWarpProvider().fieldEmissions(face: face(left: trace(leftSide: true)), strengths: requested)
        let sanitized = emissions.sanitizing(requested)
        XCTAssertEqual(sanitized.eyebrowYPosition, requested.eyebrowYPosition)
        XCTAssertEqual(sanitized.eyebrowSpacing, 0)
        let verticalAndThickness = emissions.eyebrowYPosition + emissions.eyebrowThickness
        let lengthAndSpacing = emissions.eyebrowLength + emissions.eyebrowSpacing
        let headAndTilt = emissions.eyebrowHeadSpacing + emissions.eyebrowTilt
        let stableOrder = verticalAndThickness + lengthAndSpacing + headAndTilt + emissions.eyebrowPeakDefinition
        XCTAssertEqual(emissions.points, stableOrder)
        XCTAssertEqual(emissions.sanitizing(sanitized), sanitized)
    }

    func testRequestAndConcurrencyIsolationUsesImmutableFixtures() {
        let valid = face(left: trace(leftSide: true), right: trace(leftSide: false))
        let missing = face()
        let fixtures = [valid, missing, valid, face(left: trace(leftSide: true)), face(right: trace(leftSide: false))]
        let values = fixtures.map { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: yStrength(0.25)).points.count }
        XCTAssertEqual(values.filter { $0 == 0 }.count, 1)
        XCTAssertEqual(EyebrowWarpProvider().fieldEmissions(face: valid, strengths: yStrength(0.25)).points.count, 10)
    }

    func testEyebrowOnlyInputLeavesShippedProviderArraysByteEqual() {
        let geometry = face(left: trace(leftSide: true), right: trace(leftSide: false))
        let baseline = BeautyEffectiveStrengths()
        var eyebrowOnly = baseline
        eyebrowOnly.eyebrowYPosition = 0.25
        XCTAssertEqual(FaceShapeWarpProvider().fieldEmissions(face: geometry, strengths: baseline), FaceShapeWarpProvider().fieldEmissions(face: geometry, strengths: eyebrowOnly))
        XCTAssertEqual(ChinWarpProvider().fieldEmissions(face: geometry, strengths: baseline), ChinWarpProvider().fieldEmissions(face: geometry, strengths: eyebrowOnly))
        XCTAssertEqual(EyeWarpProvider().fieldEmissions(face: geometry, strengths: baseline), EyeWarpProvider().fieldEmissions(face: geometry, strengths: eyebrowOnly))
        XCTAssertEqual(NoseWarpProvider().fieldEmissions(face: geometry, strengths: baseline), NoseWarpProvider().fieldEmissions(face: geometry, strengths: eyebrowOnly))
        XCTAssertEqual(MouthWarpProvider().fieldEmissions(face: geometry, strengths: baseline), MouthWarpProvider().fieldEmissions(face: geometry, strengths: eyebrowOnly))
    }
}
