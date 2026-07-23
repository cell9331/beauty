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

    func testPhase38MOUTH04AdapterBuildsDeterministicGroupGatedLipSupportsWithoutOuterDrift() {
        let imageBounds = CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60)
        let completeObservation = BeautyFaceObservation(imageBounds: imageBounds, landmarks: .complete)
        let complete = BeautyFaceGeometryAdapter.makeGeometry(from: completeObservation)
        let repeated = BeautyFaceGeometryAdapter.makeGeometry(from: completeObservation)
        let missingOuter = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: imageBounds,
                landmarks: BeautyFaceLandmarks(
                    availableGroups: Set(BeautyLandmarkGroup.allCases).subtracting([.outerLips])
                )
            )
        )
        let missingInner = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: imageBounds,
                landmarks: BeautyFaceLandmarks(
                    availableGroups: Set(BeautyLandmarkGroup.allCases).subtracting([.innerLips])
                )
            )
        )

        assertPoints(complete.outerLips, equalTo: [
            SIMD2<Float>(0.420, 0.656),
            SIMD2<Float>(0.460, 0.620),
            SIMD2<Float>(0.500, 0.608),
            SIMD2<Float>(0.540, 0.620),
            SIMD2<Float>(0.580, 0.656),
            SIMD2<Float>(0.540, 0.692),
            SIMD2<Float>(0.500, 0.704),
            SIMD2<Float>(0.460, 0.692)
        ])
        assertPoints(complete.upperLips, equalTo: [
            SIMD2<Float>(0.460, 0.620),
            SIMD2<Float>(0.500, 0.608),
            SIMD2<Float>(0.540, 0.620)
        ])
        assertPoints(complete.lowerLips, equalTo: [
            SIMD2<Float>(0.460, 0.692),
            SIMD2<Float>(0.500, 0.704),
            SIMD2<Float>(0.540, 0.692)
        ])
        assertPoints(complete.innerLips, equalTo: [
            SIMD2<Float>(0.460, 0.656),
            SIMD2<Float>(0.480, 0.638),
            SIMD2<Float>(0.520, 0.638),
            SIMD2<Float>(0.540, 0.656),
            SIMD2<Float>(0.520, 0.674),
            SIMD2<Float>(0.480, 0.674)
        ])

        XCTAssertEqual(complete, repeated)
        XCTAssertTrue(missingOuter.outerLips.isEmpty)
        XCTAssertTrue(missingOuter.upperLips.isEmpty)
        XCTAssertTrue(missingOuter.lowerLips.isEmpty)
        XCTAssertEqual(missingOuter.innerLips, complete.innerLips)
        XCTAssertEqual(missingInner.outerLips, complete.outerLips)
        XCTAssertEqual(missingInner.upperLips, complete.upperLips)
        XCTAssertEqual(missingInner.lowerLips, complete.lowerLips)
        XCTAssertTrue(missingInner.innerLips.isEmpty)

        let supports = [complete.outerLips, complete.upperLips, complete.lowerLips, complete.innerLips]
        for support in supports {
            XCTAssertTrue(support.allSatisfy { point in
                point.x.isFinite && point.y.isFinite &&
                    (0...1).contains(point.x) && (0...1).contains(point.y) &&
                    point.x >= complete.bounds.minX && point.x <= complete.bounds.maxX &&
                    point.y >= complete.bounds.minY && point.y <= complete.bounds.maxY
            })
            assertOnlyDistinctPoints(support)
        }
        XCTAssertNotEqual(complete.upperLips, complete.outerLips)
        XCTAssertNotEqual(complete.lowerLips, complete.outerLips)
        XCTAssertNotEqual(complete.upperLips, complete.lowerLips)
        XCTAssertNotEqual(complete.innerLips, complete.upperLips)
    }

    func testPhase38MOUTH04FaceGeometryNewSupportsDefaultEmptyForSourceCompatibility() {
        let legacySourceStyle = FaceGeometry(
            bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            faceContour: FaceGeometry.fixture.faceContour,
            outerLips: FaceGeometry.fixture.outerLips
        )

        XCTAssertEqual(legacySourceStyle.outerLips, FaceGeometry.fixture.outerLips)
        XCTAssertTrue(legacySourceStyle.upperLips.isEmpty)
        XCTAssertTrue(legacySourceStyle.lowerLips.isEmpty)
        XCTAssertTrue(legacySourceStyle.innerLips.isEmpty)
    }

    func testPhase38MOUTH04NamedLipFixturesPreserveIndependentSupportFailures() {
        XCTAssertTrue(FaceGeometry.missingMouth.outerLips.isEmpty)
        XCTAssertTrue(FaceGeometry.missingMouth.upperLips.isEmpty)
        XCTAssertTrue(FaceGeometry.missingMouth.lowerLips.isEmpty)
        XCTAssertTrue(FaceGeometry.missingMouth.innerLips.isEmpty)

        XCTAssertTrue(FaceGeometry.missingOuterLips.outerLips.isEmpty)
        XCTAssertTrue(FaceGeometry.missingOuterLips.upperLips.isEmpty)
        XCTAssertTrue(FaceGeometry.missingOuterLips.lowerLips.isEmpty)
        XCTAssertEqual(FaceGeometry.missingOuterLips.innerLips, FaceGeometry.fixture.innerLips)
        XCTAssertTrue(FaceGeometry.missingUpperLips.upperLips.isEmpty)
        XCTAssertEqual(FaceGeometry.missingUpperLips.lowerLips, FaceGeometry.fixture.lowerLips)
        XCTAssertEqual(FaceGeometry.missingUpperLips.innerLips, FaceGeometry.fixture.innerLips)
        XCTAssertTrue(FaceGeometry.missingLowerLips.lowerLips.isEmpty)
        XCTAssertEqual(FaceGeometry.missingLowerLips.upperLips, FaceGeometry.fixture.upperLips)
        XCTAssertTrue(FaceGeometry.missingInnerLips.innerLips.isEmpty)
        XCTAssertEqual(FaceGeometry.missingInnerLips.upperLips, FaceGeometry.fixture.upperLips)
        XCTAssertEqual(FaceGeometry.missingInnerLips.lowerLips, FaceGeometry.fixture.lowerLips)

        XCTAssertEqual(FaceGeometry.insufficientUpperLips.upperLips.count, 1)
        XCTAssertEqual(FaceGeometry.insufficientLowerLips.lowerLips.count, 1)
        XCTAssertEqual(FaceGeometry.insufficientInnerLips.innerLips.count, 1)
        XCTAssertEqual(FaceGeometry.duplicateUpperLips.upperLips[0], FaceGeometry.duplicateUpperLips.upperLips[1])
        XCTAssertEqual(FaceGeometry.duplicateLowerLips.lowerLips[0], FaceGeometry.duplicateLowerLips.lowerLips[1])
        XCTAssertEqual(FaceGeometry.duplicateInnerLips.innerLips[0], FaceGeometry.duplicateInnerLips.innerLips[1])
        XCTAssertTrue(FaceGeometry.nonFiniteUpperLips.upperLips.contains { !$0.x.isFinite || !$0.y.isFinite })
        XCTAssertTrue(FaceGeometry.nonFiniteLowerLips.lowerLips.contains { !$0.x.isFinite || !$0.y.isFinite })
        XCTAssertTrue(FaceGeometry.nonFiniteInnerLips.innerLips.contains { !$0.x.isFinite || !$0.y.isFinite })

        XCTAssertEqual(FaceGeometry.reused.upperLips, FaceGeometry.fixture.upperLips)
        XCTAssertEqual(FaceGeometry.reused.lowerLips, FaceGeometry.fixture.lowerLips)
        XCTAssertEqual(FaceGeometry.reused.innerLips, FaceGeometry.fixture.innerLips)
        XCTAssertEqual(FaceGeometry.reused.freshness, .reused)
        XCTAssertEqual(FaceGeometry.stale.upperLips, FaceGeometry.fixture.upperLips)
        XCTAssertEqual(FaceGeometry.stale.lowerLips, FaceGeometry.fixture.lowerLips)
        XCTAssertEqual(FaceGeometry.stale.innerLips, FaceGeometry.fixture.innerLips)
        XCTAssertEqual(FaceGeometry.stale.freshness, .stale)
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

    private func assertOnlyDistinctPoints(
        _ points: [SIMD2<Float>],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for index in points.indices {
            for otherIndex in points.indices where otherIndex > index {
                XCTAssertNotEqual(points[index], points[otherIndex], file: file, line: line)
            }
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

    func testGEOM01SmoothContourNamedEmissionRedContract() {
        let face = FaceGeometry.phase46AsymmetricComplete
        let provider = FaceShapeWarpProvider()
        let requested = BeautySafetyCaps.faceContourSmooth * 0.8
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(faceContourSmooth: requested)
        )
        let contour = try! XCTUnwrap(face.observedFaceSupport?.contour)
        let minimumXIndex = try! XCTUnwrap(contour.indices.min(by: { contour[$0].x < contour[$1].x }))
        let maximumXIndex = try! XCTUnwrap(contour.indices.max(by: { contour[$0].x < contour[$1].x }))
        let expectedIndices = contour.indices.filter { index in
            index > contour.startIndex &&
                index < contour.index(before: contour.endIndex) &&
                index != minimumXIndex &&
                index != maximumXIndex
        }
        let expectedSources = expectedIndices.map { contour[$0] }

        XCTAssertEqual(emissions.faceContourSmooth.map { $0.source }, expectedSources)
        assertPhase46ControlPoints(emissions.faceContourSmooth, face: face, strength: requested)
        XCTAssertTrue(emissions.faceContourSmooth.allSatisfy { $0.target.y == $0.source.y })
        XCTAssertFalse(emissions.faceContourSmooth.contains { point in
            point.source == contour.first || point.source == contour.last
        })
        let horizontalExtrema = [
            contour.min(by: { $0.x < $1.x }),
            contour.max(by: { $0.x < $1.x }),
        ].compactMap { $0 }
        XCTAssertTrue(emissions.faceContourSmooth.allSatisfy { !horizontalExtrema.contains($0.source) })

        let displacements = emissions.faceContourSmooth.map { $0.target.x - $0.source.x }
        let ceiling = 0.012 * face.bounds.width * requested / BeautySafetyCaps.faceContourSmooth
        XCTAssertTrue(displacements.allSatisfy { $0.isFinite && abs($0) <= ceiling + 0.000001 })
        XCTAssertEqual(displacements.reduce(0, +), 0, accuracy: 0.000001)
        XCTAssertEqual(
            displacements.reduce(0, +) / Float(max(displacements.count, 1)),
            0,
            accuracy: 0.000001
        )

        let raw = expectedIndices.map { index in
            (contour[index - 1].x + contour[index + 1].x) / 2 - contour[index].x
        }
        let rawMean = raw.reduce(0, +) / Float(raw.count)
        let centered = raw.map { $0 - rawMean }
        let nonzeroPairs = zip(centered, displacements).filter {
            abs($0.0) > Float.ulpOfOne
        }
        let scales = nonzeroPairs.map { $0.1 / $0.0 }
        let uniformScale = try! XCTUnwrap(scales.first)
        XCTAssertTrue(uniformScale.isFinite && (0...1).contains(uniformScale))
        XCTAssertTrue(scales.allSatisfy { abs($0 - uniformScale) <= 0.000001 })

        var smoothed = contour
        for point in emissions.faceContourSmooth {
            let index = try! XCTUnwrap(contour.firstIndex(of: point.source))
            smoothed[index] = point.target
        }
        XCTAssertLessThan(lateralRoughness(smoothed), lateralRoughness(contour))

        let faceSmall = provider.fieldEmissions(
            face: face,
            strengths: strengths(faceSmall: BeautySafetyCaps.faceSmall)
        )
        XCTAssertNotEqual(emissions.faceContourSmooth, faceSmall.faceSmall)
        XCTAssertNotEqual(
            emissions.faceContourSmooth.map { $0.source },
            faceSmall.faceSmall.map { $0.source }
        )
        for contourEligible in [
            FaceGeometry.phase46ContourOnly,
            .phase46CenterlineMissing,
            .phase46CenterlineIneligible,
        ] {
            XCTAssertEqual(
                provider.fieldEmissions(
                    face: contourEligible,
                    strengths: strengths(faceContourSmooth: requested)
                ).faceContourSmooth,
                emissions.faceContourSmooth
            )
        }
        XCTAssertTrue(
            provider.fieldEmissions(
                face: .phase46LocallyStraightContour,
                strengths: strengths(faceContourSmooth: requested)
            ).faceContourSmooth.isEmpty
        )
        XCTAssertTrue(
            provider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: strengths(faceContourSmooth: requested)
            ).faceContourSmooth.isEmpty
        )
        XCTAssertTrue(
            provider.fieldEmissions(
                face: face,
                strengths: strengths(faceContourSmooth: 0)
            ).faceContourSmooth.isEmpty
        )
    }

    func testGEOM02TempleFullnessNamedEmissionRedContract() {
        let face = FaceGeometry.phase46AsymmetricComplete
        let provider = FaceShapeWarpProvider()
        let requested = BeautySafetyCaps.templeFullness * 0.8
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(templeFullness: requested)
        )
        let contour = try! XCTUnwrap(face.observedFaceSupport?.contour)
        let expectedSources = contour.indices.compactMap { index -> SIMD2<Float>? in
            let progress = Float(index) / Float(contour.count - 1)
            return (0.10..<0.30).contains(progress) || (0.70..<0.90).contains(progress)
                ? contour[index]
                : nil
        }
        let axis = (contour.map(\.x).min()! + contour.map(\.x).max()!) / 2

        XCTAssertEqual(emissions.templeFullness.map { $0.source }, expectedSources)
        assertPhase46ControlPoints(emissions.templeFullness, face: face, strength: requested)
        XCTAssertTrue(emissions.templeFullness.allSatisfy {
            $0.target.y == $0.source.y && movesOutward($0, from: axis)
        })
        let ceiling = 0.018 * face.bounds.width * requested / BeautySafetyCaps.templeFullness
        XCTAssertTrue(emissions.templeFullness.allSatisfy {
            abs($0.target.x - $0.source.x) <= ceiling + 0.000001
        })

        let all = provider.fieldEmissions(
            face: face,
            strengths: strengths(
                faceSlim: BeautySafetyCaps.faceSlim,
                faceSmall: BeautySafetyCaps.faceSmall,
                jawSlim: BeautySafetyCaps.jawSlim,
                templeFullness: requested,
                cheekboneSlim: BeautySafetyCaps.cheekboneSlim * 0.8
            )
        )
        assertDisjointSources(all.templeFullness, all.cheekboneSlim)
        assertDisjointSources(all.templeFullness, all.faceSlim)
        assertDisjointSources(all.templeFullness, all.faceSmall)
        assertDisjointSources(all.templeFullness, all.jawSlim)
        for contourEligible in [
            FaceGeometry.phase46ContourOnly,
            .phase46CenterlineMissing,
            .phase46CenterlineIneligible,
        ] {
            XCTAssertEqual(
                provider.fieldEmissions(
                    face: contourEligible,
                    strengths: strengths(templeFullness: requested)
                ).templeFullness,
                emissions.templeFullness
            )
        }
        XCTAssertTrue(
            provider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: strengths(templeFullness: requested)
            ).templeFullness.isEmpty
        )
        XCTAssertTrue(
            provider.fieldEmissions(
                face: face,
                strengths: strengths(templeFullness: 0)
            ).templeFullness.isEmpty
        )
    }

    func testGEOM03CheekboneSlimNamedEmissionRedContract() {
        let face = FaceGeometry.phase46AsymmetricComplete
        let provider = FaceShapeWarpProvider()
        let requested = BeautySafetyCaps.cheekboneSlim * 0.8
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(cheekboneSlim: requested)
        )
        let contour = try! XCTUnwrap(face.observedFaceSupport?.contour)
        let expectedSources = contour.indices.compactMap { index -> SIMD2<Float>? in
            let progress = Float(index) / Float(contour.count - 1)
            return (0.30..<0.46).contains(progress) || (0.54..<0.70).contains(progress)
                ? contour[index]
                : nil
        }
        let axis = (contour.map(\.x).min()! + contour.map(\.x).max()!) / 2

        XCTAssertEqual(emissions.cheekboneSlim.map { $0.source }, expectedSources)
        assertPhase46ControlPoints(emissions.cheekboneSlim, face: face, strength: requested)
        XCTAssertTrue(emissions.cheekboneSlim.allSatisfy { point in
            point.target.y == point.source.y &&
                movesInward(point, toward: axis) &&
                abs(point.target.x - axis) < abs(point.source.x - axis)
        })
        let ceiling = 0.018 * face.bounds.width * requested / BeautySafetyCaps.cheekboneSlim
        XCTAssertTrue(emissions.cheekboneSlim.allSatisfy {
            abs($0.target.x - $0.source.x) <= ceiling + 0.000001
        })

        let all = provider.fieldEmissions(
            face: face,
            strengths: strengths(
                faceSlim: BeautySafetyCaps.faceSlim,
                faceSmall: BeautySafetyCaps.faceSmall,
                jawSlim: BeautySafetyCaps.jawSlim,
                templeFullness: BeautySafetyCaps.templeFullness * 0.8,
                cheekboneSlim: requested
            )
        )
        assertDisjointSources(all.cheekboneSlim, all.templeFullness)
        assertDisjointSources(all.cheekboneSlim, all.faceSlim)
        assertDisjointSources(all.cheekboneSlim, all.faceSmall)
        assertDisjointSources(all.cheekboneSlim, all.jawSlim)
        for contourEligible in [
            FaceGeometry.phase46ContourOnly,
            .phase46CenterlineMissing,
            .phase46CenterlineIneligible,
        ] {
            XCTAssertEqual(
                provider.fieldEmissions(
                    face: contourEligible,
                    strengths: strengths(cheekboneSlim: requested)
                ).cheekboneSlim,
                emissions.cheekboneSlim
            )
        }
        XCTAssertTrue(
            provider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: strengths(cheekboneSlim: requested)
            ).cheekboneSlim.isEmpty
        )
        XCTAssertTrue(
            provider.fieldEmissions(
                face: face,
                strengths: strengths(cheekboneSlim: 0)
            ).cheekboneSlim.isEmpty
        )
    }

    func testGEOM04ChinTaperNamedEmissionRedContract() {
        let face = FaceGeometry.phase46AsymmetricComplete
        let provider = ChinWarpProvider()
        let requested = BeautySafetyCaps.chinTaper * 0.8
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(chinTaper: requested)
        )
        let support = try! XCTUnwrap(face.observedFaceSupport)
        let apexIndex = try! XCTUnwrap(support.apexIndex)
        let expectedSources = [support.contour[apexIndex - 1], support.contour[apexIndex + 1]]

        XCTAssertEqual(emissions.chinTaper.map { $0.source }, expectedSources)
        assertPhase46ControlPoints(emissions.chinTaper, face: face, strength: requested)
        XCTAssertFalse(emissions.chinTaper.contains { $0.source == support.contour[apexIndex] })
        XCTAssertTrue(emissions.chinTaper.allSatisfy { point in
            let axis = interpolatedMedianX(at: point.source.y, median: support.medianLine!)
            return point.target.y == point.source.y &&
                abs(point.target.x - axis) < abs(point.source.x - axis)
        })
        let ceiling = 0.016 * face.bounds.width * requested / BeautySafetyCaps.chinTaper
        XCTAssertTrue(emissions.chinTaper.allSatisfy {
            abs($0.target.x - $0.source.x) <= ceiling + 0.000001
        })

        let shippedChin = provider.fieldEmissions(
            face: face,
            strengths: strengths(
                chinLength: -BeautySafetyCaps.chinLength,
                chinTaper: requested
            )
        )
        assertDisjointSources(shippedChin.chinTaper, shippedChin.chinLength)
        let shippedFace = FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths(faceVShape: BeautySafetyCaps.faceVShape)
        )
        assertDisjointSources(emissions.chinTaper, shippedFace.faceVShape)

        for ineligible in [
            FaceGeometry.phase46ContourOnly,
            .phase46CenterlineMissing,
            .phase46CenterlineIneligible,
            .phase46LegacyProxyOnly,
        ] {
            XCTAssertTrue(
                provider.fieldEmissions(
                    face: ineligible,
                    strengths: strengths(chinTaper: requested)
                ).chinTaper.isEmpty
            )
        }
        XCTAssertTrue(
            provider.fieldEmissions(
                face: face,
                strengths: strengths(chinTaper: 0)
            ).chinTaper.isEmpty
        )
    }

    func testGEOMNamedEmissionsPreserveFiveShippedFaceAndChinArrays() {
        let face = FaceGeometry.phase46AsymmetricComplete
        let faceProvider = FaceShapeWarpProvider()
        let chinProvider = ChinWarpProvider()
        let baselineFaceSlim = faceProvider.makeControlPoints(
            face: face,
            strengths: strengths(faceSlim: BeautySafetyCaps.faceSlim)
        ).points
        let baselineFaceSmall = faceProvider.makeControlPoints(
            face: face,
            strengths: strengths(faceSmall: BeautySafetyCaps.faceSmall)
        ).points
        let baselineFaceVShape = faceProvider.makeControlPoints(
            face: face,
            strengths: strengths(faceVShape: BeautySafetyCaps.faceVShape)
        ).points
        let baselineJawSlim = faceProvider.makeControlPoints(
            face: face,
            strengths: strengths(jawSlim: BeautySafetyCaps.jawSlim)
        ).points
        let baselineChinLength = chinProvider.makeControlPoints(
            face: face,
            strengths: strengths(chinLength: -BeautySafetyCaps.chinLength)
        ).points
        let combined = strengths(
            faceSlim: BeautySafetyCaps.faceSlim,
            faceSmall: BeautySafetyCaps.faceSmall,
            faceVShape: BeautySafetyCaps.faceVShape,
            jawSlim: BeautySafetyCaps.jawSlim,
            chinLength: -BeautySafetyCaps.chinLength,
            faceContourSmooth: BeautySafetyCaps.faceContourSmooth,
            templeFullness: BeautySafetyCaps.templeFullness,
            cheekboneSlim: BeautySafetyCaps.cheekboneSlim,
            chinTaper: BeautySafetyCaps.chinTaper
        )
        let faceEmissions = faceProvider.fieldEmissions(face: face, strengths: combined)
        let chinEmissions = chinProvider.fieldEmissions(face: face, strengths: combined)

        XCTAssertEqual(faceEmissions.faceSlim, baselineFaceSlim)
        XCTAssertEqual(faceEmissions.faceSmall, baselineFaceSmall)
        XCTAssertEqual(faceEmissions.faceVShape, baselineFaceVShape)
        XCTAssertEqual(faceEmissions.jawSlim, baselineJawSlim)
        XCTAssertEqual(chinEmissions.chinLength, baselineChinLength)

        let proxyOnly = FaceGeometry.phase46LegacyProxyOnly
        let proxyFace = faceProvider.fieldEmissions(face: proxyOnly, strengths: combined)
        let proxyChin = chinProvider.fieldEmissions(face: proxyOnly, strengths: combined)
        XCTAssertEqual(proxyFace.faceSlim, baselineFaceSlim)
        XCTAssertEqual(proxyFace.faceSmall, baselineFaceSmall)
        XCTAssertEqual(proxyFace.faceVShape, baselineFaceVShape)
        XCTAssertEqual(proxyFace.jawSlim, baselineJawSlim)
        XCTAssertEqual(proxyChin.chinLength, baselineChinLength)
        XCTAssertTrue(proxyFace.faceContourSmooth.isEmpty)
        XCTAssertTrue(proxyFace.templeFullness.isEmpty)
        XCTAssertTrue(proxyFace.cheekboneSlim.isEmpty)
        XCTAssertTrue(proxyChin.chinTaper.isEmpty)
    }

    func testMissingFaceContourReturnsNoFaceShapePoints() {
        let result = FaceShapeWarpProvider().makeControlPoints(
            face: .missingContour,
            strengths: strengths(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1)
        )

        XCTAssertTrue(result.points.isEmpty)
        XCTAssertEqual(result.skipReason, "missing_face_contour")
    }

    private func assertPhase46ControlPoints(
        _ points: [WarpControlPoint],
        face: FaceGeometry,
        strength: Float,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(points.isEmpty, file: file, line: line)
        XCTAssertTrue(points.allSatisfy { point in
            point.source.x.isFinite && point.source.y.isFinite &&
                point.target.x.isFinite && point.target.y.isFinite &&
                point.radius.isFinite && point.strength.isFinite && point.falloff.isFinite &&
                (0...1).contains(point.source.x) && (0...1).contains(point.source.y) &&
                (0...1).contains(point.target.x) && (0...1).contains(point.target.y) &&
                point.radius >= 0.035 && point.radius <= face.bounds.width * 0.20 &&
                point.strength == strength && point.falloff == 2
        }, file: file, line: line)
    }

    private func assertDisjointSources(
        _ lhs: [WarpControlPoint],
        _ rhs: [WarpControlPoint],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            lhs.allSatisfy { left in rhs.allSatisfy { right in left.source != right.source } },
            file: file,
            line: line
        )
    }

    private func movesOutward(_ point: WarpControlPoint, from axis: Float) -> Bool {
        point.source.x < axis
            ? point.target.x < point.source.x
            : point.target.x > point.source.x
    }

    private func movesInward(_ point: WarpControlPoint, toward axis: Float) -> Bool {
        point.source.x < axis
            ? point.target.x > point.source.x
            : point.target.x < point.source.x
    }

    private func lateralRoughness(_ contour: [SIMD2<Float>]) -> Float {
        guard contour.count >= 3 else { return 0 }
        return (1..<(contour.count - 1)).reduce(0) { result, index in
            result + abs(contour[index].x - (contour[index - 1].x + contour[index + 1].x) / 2)
        }
    }

    private func interpolatedMedianX(at y: Float, median: [SIMD2<Float>]) -> Float {
        for (first, second) in zip(median, median.dropFirst()) {
            let lower = min(first.y, second.y)
            let upper = max(first.y, second.y)
            if (lower...upper).contains(y), abs(second.y - first.y) > Float.ulpOfOne {
                let progress = (y - first.y) / (second.y - first.y)
                return first.x + (second.x - first.x) * progress
            }
        }
        return median.min(by: { abs($0.y - y) < abs($1.y - y) })!.x
    }

    private func strengths(
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0,
        faceContourSmooth: Float = 0,
        templeFullness: Float = 0,
        cheekboneSlim: Float = 0,
        chinTaper: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.faceSlim = min(faceSlim, BeautySafetyCaps.faceSlim)
        strengths.faceSmall = min(faceSmall, BeautySafetyCaps.faceSmall)
        strengths.faceVShape = min(faceVShape, BeautySafetyCaps.faceVShape)
        strengths.jawSlim = min(jawSlim, BeautySafetyCaps.jawSlim)
        strengths.chinLength = min(max(chinLength, -BeautySafetyCaps.chinLength), BeautySafetyCaps.chinLength)
        strengths.faceContourSmooth = min(faceContourSmooth, BeautySafetyCaps.faceContourSmooth)
        strengths.templeFullness = min(templeFullness, BeautySafetyCaps.templeFullness)
        strengths.cheekboneSlim = min(cheekboneSlim, BeautySafetyCaps.cheekboneSlim)
        strengths.chinTaper = min(chinTaper, BeautySafetyCaps.chinTaper)
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
        ],
        upperLips: [
            SIMD2<Float>(0.46, 0.62),
            SIMD2<Float>(0.50, 0.608),
            SIMD2<Float>(0.54, 0.62)
        ],
        lowerLips: [
            SIMD2<Float>(0.46, 0.692),
            SIMD2<Float>(0.50, 0.704),
            SIMD2<Float>(0.54, 0.692)
        ],
        innerLips: [
            SIMD2<Float>(0.46, 0.656),
            SIMD2<Float>(0.48, 0.638),
            SIMD2<Float>(0.52, 0.638),
            SIMD2<Float>(0.54, 0.656),
            SIMD2<Float>(0.52, 0.674),
            SIMD2<Float>(0.48, 0.674)
        ]
    )

    static let phase46AsymmetricComplete = replacingObservedFaceSupport(
        BeautyFaceSemanticSupport(
            contour: phase46AsymmetricContour,
            medianLine: [
                SIMD2<Float>(0.480, 0.300),
                SIMD2<Float>(0.495, 0.550),
                SIMD2<Float>(0.510, 0.820),
            ],
            apexIndex: 5
        )
    )

    static let phase46ContourOnly = replacingObservedFaceSupport(
        BeautyFaceSemanticSupport(
            contour: phase46AsymmetricContour,
            medianLine: nil,
            apexIndex: nil
        )
    )

    static let phase46CenterlineMissing = replacingObservedFaceSupport(
        BeautyFaceSemanticSupport(
            contour: phase46AsymmetricContour,
            medianLine: nil,
            apexIndex: 5
        )
    )

    static let phase46CenterlineIneligible = replacingObservedFaceSupport(
        BeautyFaceSemanticSupport(
            contour: phase46AsymmetricContour,
            medianLine: [
                SIMD2<Float>(0.480, 0.300),
                SIMD2<Float>(0.495, 0.550),
                SIMD2<Float>(0.510, 0.820),
            ],
            apexIndex: phase46AsymmetricContour.endIndex
        )
    )

    static let phase46LegacyProxyOnly = replacingObservedFaceSupport(nil)

    static let phase46LocallyStraightContour = replacingObservedFaceSupport(
        BeautyFaceSemanticSupport(
            contour: [
                SIMD2<Float>(0.300, 0.360),
                SIMD2<Float>(0.340, 0.430),
                SIMD2<Float>(0.380, 0.500),
                SIMD2<Float>(0.420, 0.590),
                SIMD2<Float>(0.460, 0.700),
                SIMD2<Float>(0.500, 0.800),
                SIMD2<Float>(0.540, 0.700),
                SIMD2<Float>(0.580, 0.590),
                SIMD2<Float>(0.620, 0.500),
                SIMD2<Float>(0.660, 0.430),
                SIMD2<Float>(0.700, 0.360),
            ],
            medianLine: nil,
            apexIndex: nil
        )
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
        outerLips: fixture.outerLips,
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
    )

    static let missingRightEye = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: [],
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips,
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
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
        outerLips: fixture.outerLips,
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
    )

    static let onePointLegacyNose = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: [SIMD2<Float>(0.50, 0.52)],
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: fixture.outerLips,
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
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
        outerLips: [],
        upperLips: [],
        lowerLips: [],
        innerLips: []
    )

    static let missingOuterLips = FaceGeometry(
        bounds: fixture.bounds,
        faceContour: fixture.faceContour,
        leftEye: fixture.leftEye,
        rightEye: fixture.rightEye,
        nose: fixture.nose,
        noseRoot: fixture.noseRoot,
        noseTip: fixture.noseTip,
        outerLips: [],
        upperLips: [],
        lowerLips: [],
        innerLips: fixture.innerLips
    )

    static let missingUpperLips = replacingLipSupports(
        upperLips: [],
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
    )

    static let missingLowerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: [],
        innerLips: fixture.innerLips
    )

    static let missingInnerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: []
    )

    static let insufficientUpperLips = replacingLipSupports(
        upperLips: [fixture.upperLips[0]],
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
    )

    static let insufficientLowerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: [fixture.lowerLips[0]],
        innerLips: fixture.innerLips
    )

    static let insufficientInnerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: [fixture.innerLips[0]]
    )

    static let duplicateUpperLips = replacingLipSupports(
        upperLips: [fixture.upperLips[0], fixture.upperLips[0]],
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
    )

    static let duplicateLowerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: [fixture.lowerLips[0], fixture.lowerLips[0]],
        innerLips: fixture.innerLips
    )

    static let duplicateInnerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: [fixture.innerLips[0], fixture.innerLips[0]]
    )

    static let nonFiniteUpperLips = replacingLipSupports(
        upperLips: [SIMD2<Float>(.nan, fixture.upperLips[0].y)] + fixture.upperLips.dropFirst(),
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips
    )

    static let nonFiniteLowerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: [SIMD2<Float>(fixture.lowerLips[0].x, .infinity)] + fixture.lowerLips.dropFirst(),
        innerLips: fixture.innerLips
    )

    static let nonFiniteInnerLips = replacingLipSupports(
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: [SIMD2<Float>(-.infinity, fixture.innerLips[0].y)] + fixture.innerLips.dropFirst()
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
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips,
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
        upperLips: fixture.upperLips,
        lowerLips: fixture.lowerLips,
        innerLips: fixture.innerLips,
        freshness: .stale
    )

    private static let phase46AsymmetricContour = [
        SIMD2<Float>(0.310, 0.360),
        SIMD2<Float>(0.290, 0.440),
        SIMD2<Float>(0.325, 0.520),
        SIMD2<Float>(0.350, 0.620),
        SIMD2<Float>(0.415, 0.730),
        SIMD2<Float>(0.505, 0.800),
        SIMD2<Float>(0.585, 0.710),
        SIMD2<Float>(0.640, 0.600),
        SIMD2<Float>(0.675, 0.490),
        SIMD2<Float>(0.705, 0.410),
        SIMD2<Float>(0.680, 0.340),
    ]

    private static func replacingObservedFaceSupport(
        _ observedFaceSupport: BeautyFaceSemanticSupport?
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: fixture.bounds,
            faceContour: fixture.faceContour,
            observedFaceSupport: observedFaceSupport,
            leftEye: fixture.leftEye,
            rightEye: fixture.rightEye,
            nose: fixture.nose,
            noseRoot: fixture.noseRoot,
            noseTip: fixture.noseTip,
            outerLips: fixture.outerLips,
            upperLips: fixture.upperLips,
            lowerLips: fixture.lowerLips,
            innerLips: fixture.innerLips,
            leftEyeSupport: fixture.leftEyeSupport,
            rightEyeSupport: fixture.rightEyeSupport,
            freshness: fixture.freshness
        )
    }

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
            upperLips: fixture.upperLips,
            lowerLips: fixture.lowerLips,
            innerLips: fixture.innerLips,
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
            upperLips: fixture.upperLips,
            lowerLips: fixture.lowerLips,
            innerLips: fixture.innerLips,
            freshness: fixture.freshness
        )
    }

    private static func replacingLipSupports(
        upperLips: [SIMD2<Float>],
        lowerLips: [SIMD2<Float>],
        innerLips: [SIMD2<Float>]
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: fixture.bounds,
            faceContour: fixture.faceContour,
            leftEye: fixture.leftEye,
            rightEye: fixture.rightEye,
            nose: fixture.nose,
            noseRoot: fixture.noseRoot,
            noseTip: fixture.noseTip,
            outerLips: fixture.outerLips,
            upperLips: upperLips,
            lowerLips: lowerLips,
            innerLips: innerLips,
            freshness: fixture.freshness
        )
    }
}
