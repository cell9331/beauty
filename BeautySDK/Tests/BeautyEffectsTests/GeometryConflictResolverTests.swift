import XCTest
import BeautyCore
@testable import BeautyEffects

private struct Phase46GeometryFieldRow {
    let name: String
    let effectiveValue: KeyPath<BeautyEffectiveStrengths, Float>
    let unscaled: Float
}

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

    func testPhase38MOUTH08FiveNewFieldsContributeExactlyOnceAndPreserveSigns() {
        let independent = strengths(
            mouthYPosition: -1,
            mouthTilt: 1,
            mouthXPosition: -1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let resolved = GeometryConflictResolver(totalThreshold: 0.50).resolve(strengths: independent)
        let expectedScale: Float = 0.40

        XCTAssertEqual(independent.geometryTotal, 1.25, accuracy: 0.000001)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 5)
        XCTAssertEqual(resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthYPosition, -0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthTilt, 0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthXPosition, -0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.lipPeakDefinition, 0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.lipPlump, 0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.lipColor, 0)
        XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
    }

    func testMOUTH14FaceEyeSixNoseEightMouthFieldsShareOneExactScale() {
        let strengths = self.strengths(
            faceSlim: 1,
            eyeSize: 1,
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1,
            mouthSize: -1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: -1,
            mouthTilt: 1,
            mouthXPosition: -1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let resolved = GeometryConflictResolver().resolve(strengths: strengths)
        let retainedTotal: Float = 0.60 + 0.45 + 0.35 + 0.35 + 0.30 + 0.30 + 0.25 + 0.25 +
            0.35 + 0.35 + 0.50 + 0.25 + 0.25 + 0.25 + 0.25 + 0.25
        let expectedScale: Float = 1 / retainedTotal

        XCTAssertEqual(retainedTotal, 5.30, accuracy: 0.000001)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 16)
        XCTAssertEqual(resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.000001)
        XCTAssertEqual(resolved.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)
        XCTAssertEqual(resolved.strengths.faceSlim, 0.60 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.eyeSize, 0.45 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.noseTipSize, -0.30 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthSize, -0.35 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthYPosition, -0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthTilt, 0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.mouthXPosition, -0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.lipPeakDefinition, 0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(resolved.strengths.lipPlump, 0.25 * expectedScale, accuracy: 0.000001)
    }

    func testGEOMAllThirtySevenFieldsShareExactElevenPointSevenBaseline() {
        let independent = strengths(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1,
            chinLength: -1,
            faceContourSmooth: 1,
            templeFullness: 1,
            cheekboneSlim: 1,
            chinTaper: 1,
            eyeSize: 1,
            eyeDistance: -1,
            eyeYPosition: 1,
            eyeTailLift: 1,
            eyeHeight: 1,
            eyeLength: 1,
            upperEyelidLift: 1,
            pupilSize: 1,
            gazeCorrection: 1,
            lowerEyelidDrop: 1,
            eyeTilt: -1,
            innerCornerOpen: 1,
            outerCornerOpen: 1,
            eyeSymmetry: 1,
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1,
            mouthSize: -1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: -1,
            mouthTilt: 1,
            mouthXPosition: -1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let resolved = GeometryConflictResolver().resolve(strengths: independent)
        let rows = phase46GeometryRows
        let expectedTotal = Float(
            rows.reduce(0.0) { $0 + Double(abs($1.unscaled)) }
        )
        let expectedScale: Float = 1 / expectedTotal

        XCTAssertEqual(rows.count, 37)
        XCTAssertEqual(Set(rows.map(\.name)).count, 37)
        XCTAssertEqual(expectedTotal, 11.70, accuracy: 0.000_001)
        XCTAssertEqual(independent.geometryTotal, expectedTotal, accuracy: 0.000_001)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 37)
        XCTAssertEqual(resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.000_000_1)
        XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
        XCTAssertEqual(resolved.strengths.geometryTotal, 1, accuracy: 0.000_001)

        for row in rows {
            XCTAssertEqual(
                independent[keyPath: row.effectiveValue],
                row.unscaled,
                accuracy: 0.000_000_1,
                row.name
            )
            XCTAssertEqual(
                resolved.strengths[keyPath: row.effectiveValue],
                row.unscaled * expectedScale,
                accuracy: 0.000_000_1,
                row.name
            )
            XCTAssertEqual(
                resolved.strengths[keyPath: row.effectiveValue].sign,
                row.unscaled.sign,
                row.name
            )
        }

        var belowThreshold = BeautyEffectiveStrengths()
        belowThreshold.eyeHeight = 0.40
        belowThreshold.eyeTilt = -0.30
        let unchanged = GeometryConflictResolver().resolve(strengths: belowThreshold)
        XCTAssertEqual(unchanged.strengths, belowThreshold)
        XCTAssertTrue(unchanged.warnings.isEmpty)
        XCTAssertTrue(unchanged.metrics.isEmpty)
    }

    func testGEOMFourFieldsContributeExactlyOnceAndPreservePositiveDirection() {
        let independent = strengths(
            faceContourSmooth: 1,
            templeFullness: 1,
            cheekboneSlim: 1,
            chinTaper: 1
        )
        let rows = Array(phase46GeometryRows.prefix(9).suffix(4))
        let resolved = GeometryConflictResolver(totalThreshold: 0.25).resolve(strengths: independent)
        let expectedScale: Float = 0.25

        XCTAssertEqual(rows.map(\.name), [
            "faceContourSmooth",
            "templeFullness",
            "cheekboneSlim",
            "chinTaper",
        ])
        XCTAssertEqual(independent.geometryTotal, 1, accuracy: 0.000_001)
        XCTAssertEqual(rows.reduce(Float(0)) { $0 + $1.unscaled }, 1, accuracy: 0.000_001)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 4)
        XCTAssertEqual(
            resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
            Double(expectedScale),
            accuracy: 0.000_001
        )
        XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
        for row in rows {
            XCTAssertEqual(independent[keyPath: row.effectiveValue], 0.25, accuracy: 0.000_001, row.name)
            XCTAssertEqual(
                resolved.strengths[keyPath: row.effectiveValue],
                0.25 * expectedScale,
                accuracy: 0.000_001,
                row.name
            )
            XCTAssertGreaterThan(resolved.strengths[keyPath: row.effectiveValue], 0, row.name)
        }
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
        faceContourSmooth: Float = 0,
        templeFullness: Float = 0,
        cheekboneSlim: Float = 0,
        chinTaper: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        eyeHeight: Float = 0,
        eyeLength: Float = 0,
        upperEyelidLift: Float = 0,
        pupilSize: Float = 0,
        gazeCorrection: Float = 0,
        lowerEyelidDrop: Float = 0,
        eyeTilt: Float = 0,
        innerCornerOpen: Float = 0,
        outerCornerOpen: Float = 0,
        eyeSymmetry: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        noseRootNarrowing: Float = 0,
        noseTipLift: Float = 0,
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
        strengths.faceSlim = min(faceSlim, BeautySafetyCaps.faceSlim)
        strengths.faceSmall = min(faceSmall, BeautySafetyCaps.faceSmall)
        strengths.faceVShape = min(faceVShape, BeautySafetyCaps.faceVShape)
        strengths.jawSlim = min(jawSlim, BeautySafetyCaps.jawSlim)
        strengths.chinLength = min(max(chinLength, -BeautySafetyCaps.chinLength), BeautySafetyCaps.chinLength)
        strengths.faceContourSmooth = min(max(faceContourSmooth, 0), BeautySafetyCaps.faceContourSmooth)
        strengths.templeFullness = min(max(templeFullness, 0), BeautySafetyCaps.templeFullness)
        strengths.cheekboneSlim = min(max(cheekboneSlim, 0), BeautySafetyCaps.cheekboneSlim)
        strengths.chinTaper = min(max(chinTaper, 0), BeautySafetyCaps.chinTaper)
        strengths.eyeSize = min(max(eyeSize, -BeautySafetyCaps.eyeSize), BeautySafetyCaps.eyeSize)
        strengths.eyeDistance = min(max(eyeDistance, -BeautySafetyCaps.eyeDistance), BeautySafetyCaps.eyeDistance)
        strengths.eyeYPosition = min(max(eyeYPosition, -BeautySafetyCaps.eyeYPosition), BeautySafetyCaps.eyeYPosition)
        strengths.eyeTailLift = min(max(eyeTailLift, -BeautySafetyCaps.eyeTailLift), BeautySafetyCaps.eyeTailLift)
        strengths.eyeHeight = min(max(eyeHeight, 0), BeautySafetyCaps.eyeHeight)
        strengths.eyeLength = min(max(eyeLength, 0), BeautySafetyCaps.eyeLength)
        strengths.upperEyelidLift = min(max(upperEyelidLift, 0), BeautySafetyCaps.upperEyelidLift)
        strengths.pupilSize = min(max(pupilSize, 0), BeautySafetyCaps.pupilSize)
        strengths.gazeCorrection = min(max(gazeCorrection, 0), BeautySafetyCaps.gazeCorrection)
        strengths.lowerEyelidDrop = min(max(lowerEyelidDrop, 0), BeautySafetyCaps.lowerEyelidDrop)
        strengths.eyeTilt = min(max(eyeTilt, -BeautySafetyCaps.eyeTilt), BeautySafetyCaps.eyeTilt)
        strengths.innerCornerOpen = min(max(innerCornerOpen, 0), BeautySafetyCaps.innerCornerOpen)
        strengths.outerCornerOpen = min(max(outerCornerOpen, 0), BeautySafetyCaps.outerCornerOpen)
        strengths.eyeSymmetry = min(max(eyeSymmetry, 0), BeautySafetyCaps.eyeSymmetry)
        strengths.noseSlim = min(noseSlim, BeautySafetyCaps.noseSlim)
        strengths.noseWingSlim = min(noseWingSlim, BeautySafetyCaps.noseWingSlim)
        strengths.noseTipSize = min(max(noseTipSize, -BeautySafetyCaps.noseTipSize), BeautySafetyCaps.noseTipSize)
        strengths.noseBridge = min(noseBridge, BeautySafetyCaps.noseBridge)
        strengths.noseRootNarrowing = min(max(noseRootNarrowing, 0), BeautySafetyCaps.noseRootNarrowing)
        strengths.noseTipLift = min(max(noseTipLift, 0), BeautySafetyCaps.noseTipLift)
        strengths.mouthSize = min(max(mouthSize, -BeautySafetyCaps.mouthSize), BeautySafetyCaps.mouthSize)
        strengths.mouthWidth = min(max(mouthWidth, -BeautySafetyCaps.mouthWidth), BeautySafetyCaps.mouthWidth)
        strengths.smile = min(smile, BeautySafetyCaps.smile)
        strengths.mouthYPosition = min(max(mouthYPosition, -BeautySafetyCaps.mouthYPosition), BeautySafetyCaps.mouthYPosition)
        strengths.mouthTilt = min(max(mouthTilt, -BeautySafetyCaps.mouthTilt), BeautySafetyCaps.mouthTilt)
        strengths.mouthXPosition = min(max(mouthXPosition, -BeautySafetyCaps.mouthXPosition), BeautySafetyCaps.mouthXPosition)
        strengths.lipPeakDefinition = min(max(lipPeakDefinition, 0), BeautySafetyCaps.lipPeakDefinition)
        strengths.lipPlump = min(max(lipPlump, 0), BeautySafetyCaps.lipPlump)
        return strengths
    }

    private var phase46GeometryRows: [Phase46GeometryFieldRow] {
        [
            Phase46GeometryFieldRow(name: "faceSlim", effectiveValue: \.faceSlim, unscaled: BeautySafetyCaps.faceSlim),
            Phase46GeometryFieldRow(name: "faceSmall", effectiveValue: \.faceSmall, unscaled: BeautySafetyCaps.faceSmall),
            Phase46GeometryFieldRow(name: "faceVShape", effectiveValue: \.faceVShape, unscaled: BeautySafetyCaps.faceVShape),
            Phase46GeometryFieldRow(name: "jawSlim", effectiveValue: \.jawSlim, unscaled: BeautySafetyCaps.jawSlim),
            Phase46GeometryFieldRow(name: "chinLength", effectiveValue: \.chinLength, unscaled: -BeautySafetyCaps.chinLength),
            Phase46GeometryFieldRow(name: "faceContourSmooth", effectiveValue: \.faceContourSmooth, unscaled: BeautySafetyCaps.faceContourSmooth),
            Phase46GeometryFieldRow(name: "templeFullness", effectiveValue: \.templeFullness, unscaled: BeautySafetyCaps.templeFullness),
            Phase46GeometryFieldRow(name: "cheekboneSlim", effectiveValue: \.cheekboneSlim, unscaled: BeautySafetyCaps.cheekboneSlim),
            Phase46GeometryFieldRow(name: "chinTaper", effectiveValue: \.chinTaper, unscaled: BeautySafetyCaps.chinTaper),
            Phase46GeometryFieldRow(name: "eyeSize", effectiveValue: \.eyeSize, unscaled: BeautySafetyCaps.eyeSize),
            Phase46GeometryFieldRow(name: "eyeDistance", effectiveValue: \.eyeDistance, unscaled: -BeautySafetyCaps.eyeDistance),
            Phase46GeometryFieldRow(name: "eyeYPosition", effectiveValue: \.eyeYPosition, unscaled: BeautySafetyCaps.eyeYPosition),
            Phase46GeometryFieldRow(name: "eyeTailLift", effectiveValue: \.eyeTailLift, unscaled: BeautySafetyCaps.eyeTailLift),
            Phase46GeometryFieldRow(name: "eyeHeight", effectiveValue: \.eyeHeight, unscaled: BeautySafetyCaps.eyeHeight),
            Phase46GeometryFieldRow(name: "eyeLength", effectiveValue: \.eyeLength, unscaled: BeautySafetyCaps.eyeLength),
            Phase46GeometryFieldRow(name: "upperEyelidLift", effectiveValue: \.upperEyelidLift, unscaled: BeautySafetyCaps.upperEyelidLift),
            Phase46GeometryFieldRow(name: "pupilSize", effectiveValue: \.pupilSize, unscaled: BeautySafetyCaps.pupilSize),
            Phase46GeometryFieldRow(name: "gazeCorrection", effectiveValue: \.gazeCorrection, unscaled: BeautySafetyCaps.gazeCorrection),
            Phase46GeometryFieldRow(name: "lowerEyelidDrop", effectiveValue: \.lowerEyelidDrop, unscaled: BeautySafetyCaps.lowerEyelidDrop),
            Phase46GeometryFieldRow(name: "eyeTilt", effectiveValue: \.eyeTilt, unscaled: -BeautySafetyCaps.eyeTilt),
            Phase46GeometryFieldRow(name: "innerCornerOpen", effectiveValue: \.innerCornerOpen, unscaled: BeautySafetyCaps.innerCornerOpen),
            Phase46GeometryFieldRow(name: "outerCornerOpen", effectiveValue: \.outerCornerOpen, unscaled: BeautySafetyCaps.outerCornerOpen),
            Phase46GeometryFieldRow(name: "eyeSymmetry", effectiveValue: \.eyeSymmetry, unscaled: BeautySafetyCaps.eyeSymmetry),
            Phase46GeometryFieldRow(name: "noseSlim", effectiveValue: \.noseSlim, unscaled: BeautySafetyCaps.noseSlim),
            Phase46GeometryFieldRow(name: "noseWingSlim", effectiveValue: \.noseWingSlim, unscaled: BeautySafetyCaps.noseWingSlim),
            Phase46GeometryFieldRow(name: "noseTipSize", effectiveValue: \.noseTipSize, unscaled: -BeautySafetyCaps.noseTipSize),
            Phase46GeometryFieldRow(name: "noseBridge", effectiveValue: \.noseBridge, unscaled: BeautySafetyCaps.noseBridge),
            Phase46GeometryFieldRow(name: "noseRootNarrowing", effectiveValue: \.noseRootNarrowing, unscaled: BeautySafetyCaps.noseRootNarrowing),
            Phase46GeometryFieldRow(name: "noseTipLift", effectiveValue: \.noseTipLift, unscaled: BeautySafetyCaps.noseTipLift),
            Phase46GeometryFieldRow(name: "mouthSize", effectiveValue: \.mouthSize, unscaled: -BeautySafetyCaps.mouthSize),
            Phase46GeometryFieldRow(name: "mouthWidth", effectiveValue: \.mouthWidth, unscaled: BeautySafetyCaps.mouthWidth),
            Phase46GeometryFieldRow(name: "smile", effectiveValue: \.smile, unscaled: BeautySafetyCaps.smile),
            Phase46GeometryFieldRow(name: "mouthYPosition", effectiveValue: \.mouthYPosition, unscaled: -BeautySafetyCaps.mouthYPosition),
            Phase46GeometryFieldRow(name: "mouthTilt", effectiveValue: \.mouthTilt, unscaled: BeautySafetyCaps.mouthTilt),
            Phase46GeometryFieldRow(name: "mouthXPosition", effectiveValue: \.mouthXPosition, unscaled: -BeautySafetyCaps.mouthXPosition),
            Phase46GeometryFieldRow(name: "lipPeakDefinition", effectiveValue: \.lipPeakDefinition, unscaled: BeautySafetyCaps.lipPeakDefinition),
            Phase46GeometryFieldRow(name: "lipPlump", effectiveValue: \.lipPlump, unscaled: BeautySafetyCaps.lipPlump),
        ]
    }
}

private extension BeautyEffectiveStrengths {
    var geometryTotal: Float {
        Float([
            faceSlim,
            faceSmall,
            faceVShape,
            jawSlim,
            abs(chinLength),
            faceContourSmooth,
            templeFullness,
            cheekboneSlim,
            chinTaper,
            abs(eyeSize),
            abs(eyeDistance),
            abs(eyeYPosition),
            abs(eyeTailLift),
            eyeHeight,
            eyeLength,
            upperEyelidLift,
            pupilSize,
            gazeCorrection,
            lowerEyelidDrop,
            abs(eyeTilt),
            innerCornerOpen,
            outerCornerOpen,
            eyeSymmetry,
            noseSlim,
            noseWingSlim,
            abs(noseTipSize),
            noseBridge,
            noseRootNarrowing,
            noseTipLift,
            abs(mouthSize),
            abs(mouthWidth),
            smile,
            abs(mouthYPosition),
            abs(mouthTilt),
            abs(mouthXPosition),
            lipPeakDefinition,
            lipPlump,
        ].reduce(0.0) { $0 + Double($1) })
    }
}
