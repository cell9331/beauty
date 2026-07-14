import XCTest
import BeautyCore
@testable import BeautyEffects

final class GeometryConflictResolverTests: XCTestCase {
    func testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum() {
        let independent = strengths(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1,
            chinLength: 1,
            eyeSize: 1,
            noseSlim: 1,
            mouthSize: 1,
            mouthWidth: 1,
            smile: 1
        )
        let resolved = GeometryConflictResolver().resolve(strengths: independent)

        XCTAssertLessThan(resolved.strengths.geometryTotal, independent.geometryTotal)
        XCTAssertLessThan(resolved.strengths.mouthSize, independent.mouthSize)
        XCTAssertLessThan(resolved.strengths.smile, independent.smile)
        XCTAssertTrue(resolved.warnings.contains { $0.code == "combined_geometry_weakened" })
    }

    func testCombinedGeometryWeakeningMetadataUsesOnlyRedactedCodesAndMetrics() {
        let resolved = GeometryConflictResolver().resolve(strengths: strengths(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1,
            chinLength: 1,
            eyeSize: 1,
            eyeDistance: 1,
            eyeYPosition: 1,
            eyeTailLift: 1,
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: 1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1,
            mouthSize: 1,
            mouthWidth: 1,
            smile: 1
        ))

        XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
        XCTAssertEqual(Set(resolved.metrics.keys), [
            "beauty.effects.weakenedCount",
            "beauty.effects.geometryStrengthScale"
        ])
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 18)
        XCTAssertLessThan(resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1)

        let metadata = (
            resolved.warnings.map { "\($0.code) \($0.message)" } +
            Array(resolved.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["land" + "mark", "control point", "control" + "Point", "bounding", "VNFace" + "Observation", "/private" + "/var", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testPhase35NOSE03IndependentNoseFieldsContributeToConflictTotalCountAndScaling() {
        let independent = strengths(noseRootNarrowing: 1, noseTipLift: 1)
        let resolved = GeometryConflictResolver(totalThreshold: 0.25).resolve(strengths: independent)

        XCTAssertEqual(independent.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing, accuracy: 0.0001)
        XCTAssertEqual(independent.noseTipLift, BeautySafetyCaps.noseTipLift, accuracy: 0.0001)
        XCTAssertGreaterThan(resolved.strengths.noseRootNarrowing, 0)
        XCTAssertGreaterThan(resolved.strengths.noseTipLift, 0)
        XCTAssertLessThan(resolved.strengths.noseRootNarrowing, independent.noseRootNarrowing)
        XCTAssertLessThan(resolved.strengths.noseTipLift, independent.noseTipLift)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 2)
        XCTAssertEqual(resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0, 0.5, accuracy: 0.0001)
        XCTAssertTrue(resolved.warnings.contains { $0.code == "combined_geometry_weakened" })
    }

    func testNOSE12AllSixNoseFieldsContributeExactlyOnceWithEveryGeometryDomain() {
        let independent = strengths(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1,
            chinLength: -1,
            eyeSize: 1,
            eyeDistance: -1,
            eyeYPosition: 1,
            eyeTailLift: 1,
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1,
            mouthSize: -1,
            mouthWidth: 1,
            smile: 1
        )
        let expectedTotal: Float = 6.65
        let expectedScale = 1 / expectedTotal
        let resolved = GeometryConflictResolver().resolve(strengths: independent)

        XCTAssertEqual(independent.geometryTotal, expectedTotal, accuracy: 0.0000001)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 18)
        XCTAssertEqual(
            resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
            Double(expectedScale),
            accuracy: 0.0000001
        )
        XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
        XCTAssertEqual(resolved.strengths.geometryTotal, 1, accuracy: 0.000001)

        let fields: [(KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (\.faceSlim, BeautySafetyCaps.faceSlim),
            (\.faceSmall, BeautySafetyCaps.faceSmall),
            (\.faceVShape, BeautySafetyCaps.faceVShape),
            (\.jawSlim, BeautySafetyCaps.jawSlim),
            (\.chinLength, -BeautySafetyCaps.chinLength),
            (\.eyeSize, BeautySafetyCaps.eyeSize),
            (\.eyeDistance, -BeautySafetyCaps.eyeDistance),
            (\.eyeYPosition, BeautySafetyCaps.eyeYPosition),
            (\.eyeTailLift, BeautySafetyCaps.eyeTailLift),
            (\.noseSlim, BeautySafetyCaps.noseSlim),
            (\.noseWingSlim, BeautySafetyCaps.noseWingSlim),
            (\.noseTipSize, -BeautySafetyCaps.noseTipSize),
            (\.noseBridge, BeautySafetyCaps.noseBridge),
            (\.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing),
            (\.noseTipLift, BeautySafetyCaps.noseTipLift),
            (\.mouthSize, -BeautySafetyCaps.mouthSize),
            (\.mouthWidth, BeautySafetyCaps.mouthWidth),
            (\.smile, BeautySafetyCaps.smile),
        ]
        for (keyPath, unscaled) in fields {
            XCTAssertEqual(
                resolved.strengths[keyPath: keyPath],
                unscaled * expectedScale,
                accuracy: 0.0000001
            )
            XCTAssertEqual(resolved.strengths[keyPath: keyPath].sign, unscaled.sign)
        }
    }

    func testResolverReportsGeometryPointAndCapMetricsForFaceShapeContext() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1, chinLength: 1),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertGreaterThanOrEqual(plan.metrics["beauty.effects.cappedCount"] ?? 0, 5)
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
    }

    func testSignedChinLengthCapsAndWeakeningStayScopedToFaceShape() {
        let positive = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1, chinLength: 1),
            faceGeometry: .fixture
        )
        let negative = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1, chinLength: -1),
            faceGeometry: .fixture
        )

        XCTAssertTrue(positive.activeDomains.contains(.faceShape))
        XCTAssertTrue(negative.activeDomains.contains(.faceShape))
        XCTAssertGreaterThan(positive.effectiveStrengths.chinLength, 0)
        XCTAssertLessThan(negative.effectiveStrengths.chinLength, 0)
        XCTAssertLessThan(abs(positive.effectiveStrengths.chinLength), BeautySafetyCaps.chinLength)
        XCTAssertLessThan(abs(negative.effectiveStrengths.chinLength), BeautySafetyCaps.chinLength)
        XCTAssertTrue(positive.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertTrue(negative.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertTrue(positive.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertTrue(negative.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertEqual(
            Set(positive.metrics.keys).intersection([
                "beauty.effects.cappedCount",
                "beauty.effects.weakenedCount",
                "beauty.effects.geometryStrengthScale",
                "beauty.effects.geometryPointCount"
            ]).count,
            4
        )
    }

    func testGeometryPipelineProducesDeterministicRenderPlanEvidence() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, chinLength: 1),
            faceGeometry: .fixture
        )

        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture)

        XCTAssertFalse(points.isEmpty)
        XCTAssertEqual(points, BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture))
    }

    func testGeometryPipelineMVPProxyProducesDeterministicVisibleBytes() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, chinLength: 1),
            faceGeometry: .fixture
        )
        let input: [UInt8] = [
            20, 30, 40, 255,
            80, 90, 100, 255
        ]

        let output = BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture)

        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output, BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture))
    }

    func testNoFaceSkipsFaceShapeButKeepsColorAndFilterDomains() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: nil
        )

        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
    }

    private func strengths(
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        noseRootNarrowing: Float = 0,
        noseTipLift: Float = 0,
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.faceSlim = min(faceSlim, BeautySafetyCaps.faceSlim)
        strengths.faceSmall = min(faceSmall, BeautySafetyCaps.faceSmall)
        strengths.faceVShape = min(faceVShape, BeautySafetyCaps.faceVShape)
        strengths.jawSlim = min(jawSlim, BeautySafetyCaps.jawSlim)
        strengths.chinLength = min(max(chinLength, -BeautySafetyCaps.chinLength), BeautySafetyCaps.chinLength)
        strengths.eyeSize = min(max(eyeSize, -BeautySafetyCaps.eyeSize), BeautySafetyCaps.eyeSize)
        strengths.eyeDistance = min(max(eyeDistance, -BeautySafetyCaps.eyeDistance), BeautySafetyCaps.eyeDistance)
        strengths.eyeYPosition = min(max(eyeYPosition, -BeautySafetyCaps.eyeYPosition), BeautySafetyCaps.eyeYPosition)
        strengths.eyeTailLift = min(max(eyeTailLift, -BeautySafetyCaps.eyeTailLift), BeautySafetyCaps.eyeTailLift)
        strengths.noseSlim = min(noseSlim, BeautySafetyCaps.noseSlim)
        strengths.noseWingSlim = min(noseWingSlim, BeautySafetyCaps.noseWingSlim)
        strengths.noseTipSize = min(max(noseTipSize, -BeautySafetyCaps.noseTipSize), BeautySafetyCaps.noseTipSize)
        strengths.noseBridge = min(noseBridge, BeautySafetyCaps.noseBridge)
        strengths.noseRootNarrowing = min(max(noseRootNarrowing, 0), BeautySafetyCaps.noseRootNarrowing)
        strengths.noseTipLift = min(max(noseTipLift, 0), BeautySafetyCaps.noseTipLift)
        strengths.mouthSize = min(max(mouthSize, -BeautySafetyCaps.mouthSize), BeautySafetyCaps.mouthSize)
        strengths.mouthWidth = min(max(mouthWidth, -BeautySafetyCaps.mouthWidth), BeautySafetyCaps.mouthWidth)
        strengths.smile = min(smile, BeautySafetyCaps.smile)
        return strengths
    }
}

private extension BeautyEffectiveStrengths {
    var geometryTotal: Float {
        faceSlim +
            faceSmall +
            faceVShape +
            jawSlim +
            abs(chinLength) +
            abs(eyeSize) +
            abs(eyeDistance) +
            abs(eyeYPosition) +
            abs(eyeTailLift) +
            noseSlim +
            noseWingSlim +
            abs(noseTipSize) +
            noseBridge +
            noseRootNarrowing +
            noseTipLift +
            abs(mouthSize) +
            abs(mouthWidth) +
            smile
    }
}
