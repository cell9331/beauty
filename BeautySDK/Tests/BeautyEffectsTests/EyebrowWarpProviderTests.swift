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

    func testSAFE01DeadZoneAdjacencyUsesStrengthBoundaryNotGeometryEpsilon() {
        let provider = EyebrowWarpProvider()
        let firstEligible = Float.ulpOfOne.nextUp

        for row in EyebrowSafetyFixtures.rows {
            let face: FaceGeometry
            if row.name == "eyebrowTilt" {
                face = EyebrowSafetyFixtures.adjacentTiltFace
            } else if row.name == "eyebrowThickness" {
                face = EyebrowSafetyFixtures.adjacentThicknessFace
            } else {
                face = EyebrowSafetyFixtures.adjacentStrengthFace
            }
            for neutral in [Float.zero, Float.ulpOfOne] + (row.isSigned ? [-Float.ulpOfOne] : []) {
                let emissions = provider.fieldEmissions(face: face, strengths: row.strengths(neutral))
                XCTAssertTrue(row.emission(emissions).isEmpty, "\(row.name) neutral \(neutral)")
            }

            let positive = row.emission(provider.fieldEmissions(face: face, strengths: row.strengths(firstEligible)))
            XCTAssertFalse(positive.isEmpty, "\(row.name) first representable magnitude above the dead zone")
            XCTAssertTrue(positive.allSatisfy { $0.strength == firstEligible }, row.name)

            if row.isSigned {
                let negative = row.emission(provider.fieldEmissions(face: face, strengths: row.strengths(-firstEligible)))
                XCTAssertFalse(negative.isEmpty, "\(row.name) negative first eligible magnitude")
                XCTAssertEqual(negative.map(\.source), positive.map(\.source), row.name)
                XCTAssertNotEqual(negative.map(\.target), positive.map(\.target), row.name)
            }
        }
    }

    func testSAFE01NamedFinalCapsRadiiBoundsAndUnavailableFixtures() {
        let provider = EyebrowWarpProvider()
        let eligibleFace = EyebrowSafetyFixtures.face()

        for row in EyebrowSafetyFixtures.rows {
            let points = row.emission(provider.fieldEmissions(
                face: eligibleFace,
                strengths: row.strengths(row.cap)
            ))
            XCTAssertFalse(points.isEmpty, row.name)
            XCTAssertTrue(points.allSatisfy { point in
                point.source.x.isFinite && point.source.y.isFinite &&
                    point.target.x.isFinite && point.target.y.isFinite &&
                    (0...1).contains(point.source.x) && (0...1).contains(point.source.y) &&
                    (0...1).contains(point.target.x) && (0...1).contains(point.target.y) &&
                    (row.name == "eyebrowHeadSpacing"
                        ? point.radius <= eligibleFace.bounds.width * 0.045
                        : point.radius == eligibleFace.bounds.width * row.maximumRadiusFraction) &&
                    point.strength == row.cap
            }, row.name)

            let unavailable = EyebrowSafetyFixtures.unavailableFace(for: row.narrowestUnavailableFixture)
            let missingPoints = row.emission(provider.fieldEmissions(
                face: unavailable,
                strengths: row.strengths(row.cap)
            ))
            XCTAssertTrue(missingPoints.isEmpty, "\(row.name) \(row.narrowestUnavailableFixture.rawValue)")

            let overflow = row.emission(provider.fieldEmissions(
                face: eligibleFace,
                strengths: row.strengths(row.cap.nextUp)
            ))
            XCTAssertTrue(overflow.isEmpty, "public resolver must clamp before provider: \(row.name)")
        }

        let unitBounds = FaceBounds(x: 0, y: 0, width: 1, height: 1)
        let minimum = BeautyFaceGeometryAdapter.minimumBrowChord
        let maximum = BeautyFaceGeometryAdapter.maximumBrowChord
        let minimumTrace = EyebrowSafetyFixtures.validatedTrace(
            side: .right,
            points: boundaryPoints(chord: minimum),
            bounds: unitBounds
        )
        let maximumTrace = EyebrowSafetyFixtures.validatedTrace(
            side: .right,
            points: boundaryPoints(chord: maximum),
            bounds: unitBounds
        )
        XCTAssertNotNil(minimumTrace, "the exact 0.08 chord boundary is inclusive")
        XCTAssertNotNil(maximumTrace, "the exact 0.50 chord boundary is inclusive")
        XCTAssertNil(EyebrowSafetyFixtures.validatedTrace(
            side: .right,
            points: boundaryPoints(chord: minimum.nextDown),
            bounds: unitBounds
        ))
        XCTAssertNil(EyebrowSafetyFixtures.validatedTrace(
            side: .right,
            points: boundaryPoints(chord: maximum.nextUp),
            bounds: unitBounds
        ))
        XCTAssertEqual(minimumTrace?.innerEndpoint, boundaryPoints(chord: minimum).first)
        XCTAssertEqual(minimumTrace?.outerEndpoint, boundaryPoints(chord: minimum).last)
        XCTAssertNil(minimumTrace?.apexIndex, "equal projection keeps order but has no invented apex")

        let invalidInputs: [[SIMD2<Float>]?] = [
            nil,
            [],
            [.init(0.20, 0.20)],
            [.init(0.20, 0.20), .init(0.20, 0.20), .init(0.30, 0.20), .init(0.40, 0.20)],
            [.init(.nan, 0.20), .init(0.25, 0.19), .init(0.30, 0.18), .init(0.40, 0.20)],
        ]
        for invalid in invalidInputs {
            XCTAssertNil(EyebrowSafetyFixtures.validatedTrace(
                side: .right,
                points: invalid,
                bounds: unitBounds
            ))
        }
        let validLeft = EyebrowSafetyFixtures.trace(side: .left)
        let invalidRight = EyebrowSafetyFixtures.validatedTrace(
            side: .right,
            points: [.init(0.53, 0.40), .init(0.53, 0.40), .init(0.61, 0.34), .init(0.69, 0.40)]
        )
        let leftOnly = provider.fieldEmissions(
            face: face(left: validLeft, right: invalidRight),
            strengths: yStrength(0.25)
        )
        XCTAssertEqual(leftOnly.eyebrowYPosition.count, validLeft.points.count)
    }

    func testBROW01HeadSpacingUsesOwnAxisInnerHalfMonotoneTaperAndTargetClearance() {
        let provider = EyebrowWarpProvider()
        let tolerance: Float = 0.000_01

        for count in [4, 5, 16] {
            for side: BeautyObservedEyebrowSide in [.left, .right] {
                let trace = densityTrace(side: side, count: count)
                let geometry = face(
                    left: side == .left ? trace : nil,
                    right: side == .right ? trace : nil
                )
                let positive = provider.fieldEmissions(
                    face: geometry,
                    strengths: headSpacingStrength(0.25)
                ).eyebrowHeadSpacing
                let negative = provider.fieldEmissions(
                    face: geometry,
                    strengths: headSpacingStrength(-0.25)
                ).eyebrowHeadSpacing
                let progress = cumulativeProgress(trace.points)
                let expectedIndices = progress.indices.filter { progress[$0] < 0.5 }
                let expectedSources = expectedIndices.map { trace.points[$0] }
                let axis = unit(trace.outerEndpoint - trace.innerEndpoint)
                let cutoff = trace.innerEndpoint + (trace.outerEndpoint - trace.innerEndpoint) * 0.5

                XCTAssertEqual(positive.map(\.source), expectedSources, "\(side) count \(count)")
                XCTAssertEqual(negative.map(\.source), expectedSources, "\(side) count \(count)")
                XCTAssertFalse(positive.contains { $0.source == trace.outerEndpoint }, "\(side) count \(count)")
                XCTAssertEqual(positive.map(\.radius), negative.map(\.radius), "\(side) count \(count)")

                var previousWeight = Float.infinity
                var previousRadius = Float.infinity
                let comparableCount = [expectedIndices.count, positive.count, negative.count].min() ?? 0
                for emissionIndex in 0..<comparableCount {
                    let traceIndex = expectedIndices[emissionIndex]
                    let positivePoint = positive[emissionIndex]
                    let negativePoint = negative[emissionIndex]
                    let p = progress[traceIndex]
                    let normalized = p / 0.5
                    let smoothstep = normalized * normalized * (3 - 2 * normalized)
                    let weight = 1 - smoothstep
                    let expectedMagnitude = geometry.bounds.width * 0.065 * weight
                    let positiveDelta = positivePoint.target - positivePoint.source
                    let negativeDelta = negativePoint.target - negativePoint.source
                    let positiveAlongAxis = dot(positiveDelta, axis)
                    let negativeAlongAxis = dot(negativeDelta, axis)
                    let positivePlaneClearance = dot(cutoff - positivePoint.target, axis)
                    let negativePlaneClearance = dot(cutoff - negativePoint.target, axis)
                    let nominalRadius = geometry.bounds.width * (0.020 + 0.025 * weight)

                    XCTAssertGreaterThan(positiveAlongAxis, 0, "\(side) count \(count) p \(p)")
                    XCTAssertLessThan(negativeAlongAxis, 0, "\(side) count \(count) p \(p)")
                    XCTAssertEqual(positiveAlongAxis, expectedMagnitude, accuracy: tolerance, "\(side) count \(count) p \(p)")
                    XCTAssertEqual(negativeAlongAxis, -expectedMagnitude, accuracy: tolerance, "\(side) count \(count) p \(p)")
                    XCTAssertEqual(positiveDelta.x, -negativeDelta.x, accuracy: tolerance)
                    XCTAssertEqual(positiveDelta.y, -negativeDelta.y, accuracy: tolerance)
                    XCTAssertLessThanOrEqual(weight, previousWeight)
                    XCTAssertLessThanOrEqual(positivePoint.radius, previousRadius)
                    XCTAssertTrue(positivePoint.radius.isFinite)
                    XCTAssertGreaterThan(positivePoint.radius, 0)
                    XCTAssertLessThanOrEqual(positivePoint.radius, nominalRadius + tolerance)
                    XCTAssertGreaterThan(positivePlaneClearance, 0)
                    XCTAssertGreaterThan(negativePlaneClearance, 0)
                    XCTAssertLessThanOrEqual(positivePoint.radius, positivePlaneClearance * 0.5 + tolerance)
                    XCTAssertLessThanOrEqual(negativePoint.radius, negativePlaneClearance * 0.5 + tolerance)
                    XCTAssertTrue(isUnit(positivePoint.source) && isUnit(positivePoint.target))
                    XCTAssertTrue(isUnit(negativePoint.source) && isUnit(negativePoint.target))
                    previousWeight = weight
                    previousRadius = positivePoint.radius
                }
            }
        }
    }

    func testBROW01HeadSpacingPreservesDeadZoneCapPeerIndependenceAndRequestIsolation() {
        let provider = EyebrowWarpProvider()
        let left = densityTrace(side: .left, count: 5)
        let right = densityTrace(side: .right, count: 5)
        let valid = face(left: left, right: right)

        for neutral in [Float.zero, Float.ulpOfOne, -Float.ulpOfOne] {
            XCTAssertTrue(provider.fieldEmissions(
                face: valid,
                strengths: headSpacingStrength(neutral)
            ).eyebrowHeadSpacing.isEmpty, "exact dead zone \(neutral)")
        }
        let cap = BeautySafetyCaps.eyebrowHeadSpacing
        let capPositive = provider.fieldEmissions(face: valid, strengths: headSpacingStrength(cap))
        let capNegative = provider.fieldEmissions(face: valid, strengths: headSpacingStrength(-cap))
        XCTAssertFalse(capPositive.eyebrowHeadSpacing.isEmpty)
        XCTAssertEqual(capPositive.eyebrowHeadSpacing.map(\.source), capNegative.eyebrowHeadSpacing.map(\.source))
        XCTAssertEqual(capPositive.eyebrowHeadSpacing.map(\.radius), capNegative.eyebrowHeadSpacing.map(\.radius))
        XCTAssertTrue(provider.fieldEmissions(
            face: valid,
            strengths: headSpacingStrength(cap.nextUp)
        ).eyebrowHeadSpacing.isEmpty)
        XCTAssertTrue(provider.fieldEmissions(
            face: valid,
            strengths: headSpacingStrength(-cap.nextUp)
        ).eyebrowHeadSpacing.isEmpty)

        var siblingStrengths = BeautyEffectiveStrengths()
        siblingStrengths.eyebrowYPosition = 0.25
        siblingStrengths.eyebrowThickness = 0.25
        siblingStrengths.eyebrowLength = 0.25
        siblingStrengths.eyebrowSpacing = 0.25
        siblingStrengths.eyebrowTilt = 0.25
        siblingStrengths.eyebrowPeakDefinition = 0.25
        let siblingBaseline = provider.fieldEmissions(face: valid, strengths: siblingStrengths)
        siblingStrengths.eyebrowHeadSpacing = cap
        let siblingWithHead = provider.fieldEmissions(face: valid, strengths: siblingStrengths)
        XCTAssertEqual(siblingWithHead.eyebrowYPosition, siblingBaseline.eyebrowYPosition)
        XCTAssertEqual(siblingWithHead.eyebrowThickness, siblingBaseline.eyebrowThickness)
        XCTAssertEqual(siblingWithHead.eyebrowLength, siblingBaseline.eyebrowLength)
        XCTAssertEqual(siblingWithHead.eyebrowSpacing, siblingBaseline.eyebrowSpacing)
        XCTAssertEqual(siblingWithHead.eyebrowTilt, siblingBaseline.eyebrowTilt)
        XCTAssertEqual(siblingWithHead.eyebrowPeakDefinition, siblingBaseline.eyebrowPeakDefinition)

        let malformedLeft = EyebrowSafetyFixtures.validatedTrace(
            side: .left,
            points: [.init(0.47, 0.41), .init(0.47, 0.41), .init(0.39, 0.34), .init(0.31, 0.41)],
            bounds: bounds
        )
        let malformedRight = EyebrowSafetyFixtures.validatedTrace(
            side: .right,
            points: [.init(0.53, 0.41), .init(0.53, 0.41), .init(0.61, 0.34), .init(0.69, 0.41)],
            bounds: bounds
        )
        XCTAssertNil(malformedLeft)
        XCTAssertNil(malformedRight)

        let leftOnly = provider.fieldEmissions(
            face: face(left: left, right: malformedRight),
            strengths: headSpacingStrength(cap)
        ).eyebrowHeadSpacing
        let rightOnly = provider.fieldEmissions(
            face: face(left: malformedLeft, right: right),
            strengths: headSpacingStrength(cap)
        ).eyebrowHeadSpacing
        XCTAssertEqual(leftOnly.map(\.source), cumulativeProgress(left.points).indices.filter { cumulativeProgress(left.points)[$0] < 0.5 }.map { left.points[$0] })
        XCTAssertEqual(rightOnly.map(\.source), cumulativeProgress(right.points).indices.filter { cumulativeProgress(right.points)[$0] < 0.5 }.map { right.points[$0] })
        XCTAssertTrue(leftOnly.allSatisfy { !right.points.contains($0.source) })
        XCTAssertTrue(rightOnly.allSatisfy { !left.points.contains($0.source) })

        let missing = face()
        let malformedBoth = face(left: malformedLeft, right: malformedRight)
        let noFace = FaceGeometry(bounds: .init(x: 0, y: 0, width: 0, height: 0), faceContour: [])
        for unavailable in [missing, malformedBoth, noFace] {
            let emissions = provider.fieldEmissions(face: unavailable, strengths: headSpacingStrength(cap))
            XCTAssertTrue(emissions.eyebrowHeadSpacing.isEmpty)
            XCTAssertEqual(emissions.sanitizing(headSpacingStrength(cap)).eyebrowHeadSpacing, 0)
        }

        let sequence = [valid, malformedBoth, valid].map {
            provider.fieldEmissions(face: $0, strengths: headSpacingStrength(cap)).eyebrowHeadSpacing
        }
        XCTAssertEqual(sequence[0], sequence[2])
        XCTAssertTrue(sequence[1].isEmpty)
    }

    private func boundaryPoints(chord: Float) -> [SIMD2<Float>] {
        [
            .init(0, 0.20),
            .init(chord * 0.25, 0.20),
            .init(chord * 0.50, 0.20),
            .init(chord * 0.75, 0.20),
            .init(chord, 0.20),
        ]
    }

    private func densityTrace(
        side: BeautyObservedEyebrowSide,
        count: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> BeautyEyebrowSemanticTrace {
        precondition(count >= 4)
        let innerX: Float = side == .left ? 0.47 : 0.53
        let direction: Float = side == .left ? -1 : 1
        let points = (0..<count).map { index -> SIMD2<Float> in
            let progress = Float(index) / Float(count - 1)
            return SIMD2<Float>(
                innerX + direction * 0.16 * progress,
                0.41 - 0.05 * sin(Float.pi * progress)
            )
        }
        guard let trace = EyebrowSafetyFixtures.validatedTrace(
            side: side,
            points: points,
            bounds: bounds
        ) else {
            XCTFail("density trace must pass production adapter", file: file, line: line)
            return EyebrowSafetyFixtures.trace(side: side, bounds: bounds, file: file, line: line)
        }
        return trace
    }

    private func cumulativeProgress(_ points: [SIMD2<Float>]) -> [Float] {
        var cumulative = [Float](repeating: 0, count: points.count)
        for index in points.indices.dropFirst() {
            cumulative[index] = cumulative[index - 1] + magnitude(points[index] - points[index - 1])
        }
        guard let total = cumulative.last, total.isFinite, total > 0 else {
            return cumulative
        }
        return cumulative.map { $0 / total }
    }

    private func unit(_ vector: SIMD2<Float>) -> SIMD2<Float> {
        let length = magnitude(vector)
        return vector / length
    }

    private func magnitude(_ vector: SIMD2<Float>) -> Float {
        sqrt(vector.x * vector.x + vector.y * vector.y)
    }

    private func dot(_ lhs: SIMD2<Float>, _ rhs: SIMD2<Float>) -> Float {
        lhs.x * rhs.x + lhs.y * rhs.y
    }

    private func isUnit(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite
            && (0...1).contains(point.x) && (0...1).contains(point.y)
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
        let geometry = face(
            left: EyebrowSafetyFixtures.trace(side: .left),
            right: EyebrowSafetyFixtures.trace(side: .right)
        )
        let positive = EyebrowWarpProvider().fieldEmissions(face: geometry, strengths: yStrength(0.25))
        let negative = EyebrowWarpProvider().fieldEmissions(face: geometry, strengths: yStrength(-0.25))
        assertRenderable(positive.eyebrowYPosition)
        XCTAssertEqual(positive.eyebrowYPosition.map { $0.source }, negative.eyebrowYPosition.map { $0.source })
        XCTAssertTrue(zip(positive.eyebrowYPosition, negative.eyebrowYPosition).allSatisfy { ($0.target.y - $0.source.y) * ($1.target.y - $1.source.y) < 0 })
    }

    func testGEOM02ThicknessNamedEmission() {
        let geometry = face(
            left: EyebrowSafetyFixtures.trace(side: .left),
            right: EyebrowSafetyFixtures.trace(side: .right)
        )
        let emissions = EyebrowWarpProvider().fieldEmissions(face: geometry, strengths: thicknessStrength(0.25))
        assertRenderable(emissions.eyebrowThickness)
        XCTAssertEqual(emissions.eyebrowThickness.count % 2, 0, "balanced normal-strip samples")
        XCTAssertNotEqual(emissions.eyebrowThickness, emissions.eyebrowYPosition)
    }

    func testGEOM02DegenerateAdjacencySkipsOnlyAffectedThicknessSample() {
        let locallyDegenerate = [
            SIMD2<Float>(0.47, 0.40),
            SIMD2<Float>(0.3900004, 0.36),
            SIMD2<Float>(0.3900002, 0.3599999),
            SIMD2<Float>(0.39, 0.3600001),
            SIMD2<Float>(0.31, 0.40),
        ]
        let left = EyebrowSafetyFixtures.trace(
            side: .left,
            points: locallyDegenerate,
            apexIndex: nil
        )
        let emissions = EyebrowWarpProvider().fieldEmissions(
            face: face(left: left),
            strengths: thicknessStrength(0.25)
        )

        assertRenderable(emissions.eyebrowThickness)
        XCTAssertEqual(emissions.eyebrowThickness.count, 8, "only the locally degenerate tangent is omitted")
        XCTAssertEqual(emissions.eyebrowThickness.count % 2, 0, "remaining samples stay balanced")
    }

    func testGEOM03LengthNamedEmission() {
        let left = EyebrowSafetyFixtures.trace(side: .left)
        let emissions = EyebrowWarpProvider().fieldEmissions(face: face(left: left), strengths: lengthStrength(0.25))
        assertRenderable(emissions.eyebrowLength)
        XCTAssertTrue(emissions.eyebrowLength.allSatisfy { $0.source != left.innerEndpoint })
    }

    func testGEOM04WholeSpacingNamedEmission() {
        let left = EyebrowSafetyFixtures.trace(side: .left)
        let right = EyebrowSafetyFixtures.trace(side: .right)
        let provider = EyebrowWarpProvider()
        let paired = provider.fieldEmissions(face: face(left: left, right: right), strengths: spacingStrength(0.25))
        let single = provider.fieldEmissions(face: face(left: left), strengths: spacingStrength(0.25))
        assertRenderable(paired.eyebrowSpacing)
        XCTAssertTrue(single.eyebrowSpacing.isEmpty, "whole spacing is pair-only")
        XCTAssertTrue(paired.eyebrowSpacing.contains { $0.target.x < $0.source.x })
        XCTAssertTrue(paired.eyebrowSpacing.contains { $0.target.x > $0.source.x })
    }

    func testGEOM05HeadSpacingNamedEmission() {
        let left = EyebrowSafetyFixtures.trace(side: .left)
        let emissions = EyebrowWarpProvider().fieldEmissions(face: face(left: left), strengths: headSpacingStrength(0.25))
        assertRenderable(emissions.eyebrowHeadSpacing)
        XCTAssertTrue(emissions.eyebrowHeadSpacing.contains { $0.source == left.innerEndpoint })
        XCTAssertFalse(emissions.eyebrowHeadSpacing.contains { $0.source == left.outerEndpoint })
    }

    func testGEOM06TiltNamedEmission() {
        let provider = EyebrowWarpProvider()
        let geometry = face(
            left: EyebrowSafetyFixtures.trace(side: .left),
            right: EyebrowSafetyFixtures.trace(side: .right)
        )
        let positive = provider.fieldEmissions(face: geometry, strengths: tiltStrength(0.25)).eyebrowTilt
        let negative = provider.fieldEmissions(face: geometry, strengths: tiltStrength(-0.25)).eyebrowTilt
        assertRenderable(positive)
        XCTAssertEqual(positive.map { $0.source }, negative.map { $0.source })
        XCTAssertNotEqual(positive.map { $0.target }, negative.map { $0.target }, "signed canonical-chord rotation")
    }

    func testGEOM07PeakNamedEmission() {
        let provider = EyebrowWarpProvider()
        let eligible = provider.fieldEmissions(
            face: face(left: EyebrowSafetyFixtures.trace(side: .left)),
            strengths: peakStrength(0.25)
        )
        let noApex = provider.fieldEmissions(
            face: face(left: EyebrowSafetyFixtures.trace(side: .left, apexIndex: nil)),
            strengths: peakStrength(0.25)
        )
        let negative = provider.fieldEmissions(
            face: face(left: EyebrowSafetyFixtures.trace(side: .left)),
            strengths: peakStrength(-0.25)
        )
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
        let emissions = EyebrowWarpProvider().fieldEmissions(
            face: face(left: EyebrowSafetyFixtures.trace(side: .left)),
            strengths: requested
        )
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
        let valid = face(
            left: EyebrowSafetyFixtures.trace(side: .left),
            right: EyebrowSafetyFixtures.trace(side: .right)
        )
        let missing = face()
        let fixtures = [
            valid,
            missing,
            valid,
            face(left: EyebrowSafetyFixtures.trace(side: .left)),
            face(right: EyebrowSafetyFixtures.trace(side: .right)),
        ]
        let values = fixtures.map { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: yStrength(0.25)).points.count }
        XCTAssertEqual(values.filter { $0 == 0 }.count, 1)
        XCTAssertEqual(EyebrowWarpProvider().fieldEmissions(face: valid, strengths: yStrength(0.25)).points.count, 10)
    }

    func testEyebrowOnlyInputLeavesShippedProviderArraysByteEqual() {
        let geometry = face(
            left: EyebrowSafetyFixtures.trace(side: .left),
            right: EyebrowSafetyFixtures.trace(side: .right)
        )
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
