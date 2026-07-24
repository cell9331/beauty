import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

private struct Phase46ResolverFieldRow {
    let name: String
    let makeParameters: (Float) -> BeautyParameters
    let publicValue: KeyPath<BeautyParameters, Float>
    let effectiveValue: KeyPath<BeautyEffectiveStrengths, Float>
    let requiresCenterline: Bool
    let emissionPoints: (FaceGeometry, BeautyEffectiveStrengths) -> [WarpControlPoint]
}

final class BeautyEffectResolverTests: XCTestCase {
    func testDefaultParametersResolveToNoActiveDomains() {
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters())

        XCTAssertTrue(plan.activeDomains.isEmpty)
        XCTAssertTrue(plan.skippedDomains.isEmpty)
        XCTAssertTrue(plan.warnings.isEmpty)
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 0)
    }

    func testSkinValuesKeepPublicRangeButResolveToCappedEffectiveStrengths() {
        let parameters = BeautyParameters(
            skinSmoothing: 1,
            skinWhitening: 1,
            skinRosy: 1,
            skinSharpen: 1
        )

        XCTAssertEqual(parameters.normalized().skinSmoothing, 1)

        let plan = BeautyEffectResolver.resolve(parameters: parameters)

        XCTAssertTrue(plan.activeDomains.contains(.skin))
        XCTAssertEqual(plan.effectiveStrengths.skinSmoothing, 0.60, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.skinWhitening, 0.50, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.skinRosy, 0.40, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.skinSharpen, 0.40, accuracy: 0.0001)
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 4)
    }

    func testNonZeroSkinColorAndFilterValuesActivateExpectedDomains() {
        let parameters = BeautyParameters(
            skinWhitening: 0.35,
            brightness: 0.15,
            contrast: -0.10,
            filterId: "soft_clean",
            filterIntensity: 0.50
        )

        let plan = BeautyEffectResolver.resolve(parameters: parameters)

        XCTAssertEqual(plan.activeDomains, [.skin, .color, .filter])
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 3)
    }

    func testPublicResolverKeepsBasicSkinActiveWithoutFaceGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(skinSmoothing: 0.4, skinWhitening: 0.3)
        )

        XCTAssertTrue(plan.activeDomains.contains(.skin))
        XCTAssertFalse(plan.skippedDomains.contains(.skin))
        XCTAssertFalse(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 1)
    }

    func testPublicResolverDoesNotActivateGeometryDomainsWithoutFaceGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1
            )
        )

        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertFalse(plan.activeDomains.contains(.lipColor))
        XCTAssertTrue(plan.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        assertRedacted(plan)
    }

    func testInternalNoFaceResolverSkipsBasicSkinWithRedactedWarning() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(skinSmoothing: 0.4, skinWhitening: 0.3),
            faceGeometry: nil
        )

        XCTAssertFalse(plan.activeDomains.contains(.skin))
        XCTAssertTrue(plan.skippedDomains.contains(.skin))
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertEqual(plan.metrics["beauty.effects.skippedFaceDomains"], 1)

        let combined = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["/private" + "/var", "NSE" + "rror", "VNFace" + "Observation", "bounding", "land" + "mark", "rawPreset" + "Json"] {
            XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testWarningsAndMetricsDoNotExposeSensitiveTerms() {
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinSmoothing: 1))
        let combined = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["/private" + "/var", "NSE" + "rror", "VNFace" + "Observation", "bounding", "land" + "mark", "rawPreset" + "Json"] {
            XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testRequiresFaceGeometryOnlyForGeometryTriggeredParameters() {
        XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters()))
        XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(skinSmoothing: 0.4)))
        XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(brightness: 0.2)))
        XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(filterId: "soft_clean", filterIntensity: 0.5)))

        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(faceSlim: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(eyeSize: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(noseSlim: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(noseRootNarrowing: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(noseTipLift: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(mouthSize: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(mouthYPosition: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(mouthTilt: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(mouthXPosition: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(lipPeakDefinition: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(lipPlump: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(lipColor: 0.4)))

        let independentEyeParameters = [
            BeautyParameters(eyeHeight: 0.4),
            BeautyParameters(eyeLength: 0.4),
            BeautyParameters(upperEyelidLift: 0.4),
            BeautyParameters(pupilSize: 0.4),
            BeautyParameters(gazeCorrection: 0.4),
            BeautyParameters(lowerEyelidDrop: 0.4),
            BeautyParameters(eyeTilt: 0.4),
            BeautyParameters(innerCornerOpen: 0.4),
            BeautyParameters(outerCornerOpen: 0.4),
            BeautyParameters(eyeSymmetry: 0.4)
        ]
        for parameters in independentEyeParameters {
            XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: parameters))
        }
    }

    func testBROW02SevenNonzeroEyebrowFieldsRemainRuntimeInert() {
        let baseline = BeautyParameters(
            skinSmoothing: 0.18,
            brightness: 0.12,
            faceSlim: 0.19,
            eyeSize: 0.17,
            noseSlim: 0.16,
            mouthSize: -0.15,
            lipColor: 0.14,
            filterId: "soft_clean",
            filterIntensity: 0.13
        )
        let withEyebrows = BeautyParameters(
            skinSmoothing: 0.18,
            brightness: 0.12,
            faceSlim: 0.19,
            eyeSize: 0.17,
            eyebrowYPosition: -0.71,
            eyebrowThickness: -0.52,
            eyebrowLength: -0.33,
            eyebrowSpacing: 0.14,
            eyebrowHeadSpacing: 0.35,
            eyebrowTilt: 0.56,
            eyebrowPeakDefinition: 0.77,
            noseSlim: 0.16,
            mouthSize: -0.15,
            lipColor: 0.14,
            filterId: "soft_clean",
            filterIntensity: 0.13
        )
        let face = FaceGeometry.fixture

        XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(
            eyebrowYPosition: -0.71,
            eyebrowThickness: -0.52,
            eyebrowLength: -0.33,
            eyebrowSpacing: 0.14,
            eyebrowHeadSpacing: 0.35,
            eyebrowTilt: 0.56,
            eyebrowPeakDefinition: 0.77
        )))
        XCTAssertEqual(
            BeautyEffectResolver.requiresFaceGeometry(parameters: withEyebrows),
            BeautyEffectResolver.requiresFaceGeometry(parameters: baseline)
        )

        let baselinePlan = BeautyEffectResolver.resolve(parameters: baseline, faceGeometry: face)
        let eyebrowPlan = BeautyEffectResolver.resolve(parameters: withEyebrows, faceGeometry: face)

        XCTAssertEqual(eyebrowPlan, baselinePlan)
        XCTAssertEqual(eyebrowPlan.effectiveStrengths, baselinePlan.effectiveStrengths)
        XCTAssertEqual(eyebrowPlan.activeDomains, baselinePlan.activeDomains)
        XCTAssertEqual(eyebrowPlan.skippedDomains, baselinePlan.skippedDomains)
        XCTAssertEqual(eyebrowPlan.warnings, baselinePlan.warnings)
        XCTAssertEqual(eyebrowPlan.metrics, baselinePlan.metrics)
        XCTAssertEqual(
            BeautyGeometryEffectPipeline.controlPoints(for: eyebrowPlan.effectiveStrengths, face: face),
            BeautyGeometryEffectPipeline.controlPoints(for: baselinePlan.effectiveStrengths, face: face)
        )
        assertRedacted(eyebrowPlan)
    }

    func testBROW03SevenFieldsRequireGeometryCapAndActivateOnlyEyebrows() {
        let face = eyebrowResolverFace()
        let rows: [(String, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            ("y positive", BeautyParameters(eyebrowYPosition: 1), \.eyebrowYPosition, 0.25),
            ("y negative", BeautyParameters(eyebrowYPosition: -1), \.eyebrowYPosition, -0.25),
            ("thickness", BeautyParameters(eyebrowThickness: 1), \.eyebrowThickness, 0.25),
            ("length", BeautyParameters(eyebrowLength: 1), \.eyebrowLength, 0.25),
            ("spacing", BeautyParameters(eyebrowSpacing: 1), \.eyebrowSpacing, 0.25),
            ("head spacing", BeautyParameters(eyebrowHeadSpacing: 1), \.eyebrowHeadSpacing, 0.25),
            ("tilt", BeautyParameters(eyebrowTilt: -1), \.eyebrowTilt, -0.25),
            ("peak", BeautyParameters(eyebrowPeakDefinition: 1), \.eyebrowPeakDefinition, 0.25),
        ]

        for (name, parameters, keyPath, expected) in rows {
            XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: parameters), name)
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.000_001, name)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1, name)
            XCTAssertTrue(plan.activeDomains.contains(.eyebrows), name)
            XCTAssertFalse(plan.activeDomains.contains(.eyes), name)
            XCTAssertFalse(plan.activeDomains.contains(.faceShape), name)
            XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, name)
            assertRedacted(plan)
        }
    }

    func testGEOMFourFieldsRequireGeometryCapIndependentlyAndPreserveExplicitZeroPlan() {
        let omitted = BeautyParameters(
            faceSlim: 0.24,
            eyeSize: 0.18,
            noseSlim: 0.17,
            mouthSize: -0.16
        )
        let explicitZero = BeautyParameters(
            faceSlim: 0.24,
            faceContourSmooth: 0,
            templeFullness: 0,
            cheekboneSlim: 0,
            chinTaper: 0,
            eyeSize: 0.18,
            noseSlim: 0.17,
            mouthSize: -0.16
        )

        let omittedPlan = BeautyEffectResolver.resolve(parameters: omitted, faceGeometry: .fixture)
        let explicitZeroPlan = BeautyEffectResolver.resolve(parameters: explicitZero, faceGeometry: .fixture)

        XCTAssertEqual(explicitZeroPlan, omittedPlan)
        XCTAssertEqual(explicitZeroPlan.effectiveStrengths, omittedPlan.effectiveStrengths)
        XCTAssertEqual(explicitZeroPlan.activeDomains, omittedPlan.activeDomains)
        XCTAssertEqual(explicitZeroPlan.skippedDomains, omittedPlan.skippedDomains)
        XCTAssertEqual(explicitZeroPlan.warnings, omittedPlan.warnings)
        XCTAssertEqual(explicitZeroPlan.metrics, omittedPlan.metrics)
        XCTAssertEqual(
            explicitZeroPlan.metrics["beauty.effects.geometryPointCount"],
            omittedPlan.metrics["beauty.effects.geometryPointCount"]
        )

        let face = FaceGeometry.phase46AsymmetricComplete
        let reusedFace = phase46Face(face, freshness: .reused)
        let staleFace = phase46Face(face, freshness: .stale)
        let allowedMetricKeys: Set<String> = [
            "beauty.effects.activeCount",
            "beauty.effects.cappedCount",
            "beauty.effects.geometryPointCount",
            "beauty.effects.reusedGeometryScale",
            "beauty.effects.skippedFaceDomains",
        ]

        for row in phase46ResolverRows {
            let negative = row.makeParameters(-1)
            XCTAssertFalse(
                BeautyEffectResolver.requiresFaceGeometry(parameters: negative),
                "\(row.name) negative normalized input"
            )
            XCTAssertEqual(negative[keyPath: row.publicValue], 0, row.name)

            let overflow = row.makeParameters(1)
            XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: overflow), row.name)
            let fresh = BeautyEffectResolver.resolve(parameters: overflow, faceGeometry: face)
            XCTAssertEqual(fresh.effectiveStrengths[keyPath: row.effectiveValue], 0.25, accuracy: 0.000_001, row.name)
            XCTAssertEqual(fresh.metrics["beauty.effects.cappedCount"], 1, row.name)
            XCTAssertEqual(fresh.warnings.filter { $0.code == "beauty_strength_capped" }.count, 1, row.name)
            XCTAssertTrue(fresh.activeDomains.contains(.faceShape), row.name)
            XCTAssertFalse(fresh.skippedDomains.contains(.faceShape), row.name)
            let freshEmission = row.emissionPoints(face, fresh.effectiveStrengths)
            XCTAssertFalse(freshEmission.isEmpty, row.name)
            XCTAssertEqual(
                fresh.metrics["beauty.effects.geometryPointCount"],
                Double(freshEmission.count),
                row.name
            )
            XCTAssertTrue(Set(fresh.metrics.keys).isSubset(of: allowedMetricKeys), row.name)
            assertRedacted(fresh)

            let reused = BeautyEffectResolver.resolve(parameters: overflow, faceGeometry: reusedFace)
            XCTAssertEqual(reused.effectiveStrengths[keyPath: row.effectiveValue], 0.125, accuracy: 0.000_001, row.name)
            XCTAssertFalse(row.emissionPoints(reusedFace, reused.effectiveStrengths).isEmpty, row.name)
            XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5, row.name)

            let noFace = BeautyEffectResolver.resolve(parameters: overflow, faceGeometry: nil)
            XCTAssertEqual(noFace.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertNil(noFace.metrics["beauty.effects.geometryPointCount"], row.name)

            let stale = BeautyEffectResolver.resolve(parameters: overflow, faceGeometry: staleFace)
            XCTAssertEqual(stale.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertNil(stale.metrics["beauty.effects.geometryPointCount"], row.name)

            let proxyOnly = BeautyEffectResolver.resolve(
                parameters: overflow,
                faceGeometry: .phase46LegacyProxyOnly
            )
            XCTAssertEqual(proxyOnly.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertTrue(
                row.emissionPoints(.phase46LegacyProxyOnly, proxyOnly.effectiveStrengths).isEmpty,
                row.name
            )
            XCTAssertNil(proxyOnly.metrics["beauty.effects.geometryStrengthScale"], row.name)
            XCTAssertNil(proxyOnly.metrics["beauty.effects.geometryPointCount"], row.name)

            let contourOnly = BeautyEffectResolver.resolve(
                parameters: overflow,
                faceGeometry: .phase46ContourOnly
            )
            XCTAssertEqual(
                contourOnly.effectiveStrengths[keyPath: row.effectiveValue],
                row.requiresCenterline ? 0 : 0.25,
                accuracy: 0.000_001,
                row.name
            )
        }
    }

    func testSAFE01FinalFaceCapInputClassesAreExactAndRedacted() {
        let inputs: [(name: String, value: Float, expected: Float, cappedCount: Double)] = [
            ("zero", 0, 0, 0),
            ("algorithmic neutral edge", Float.ulpOfOne, 0, 0),
            ("exact cap", 0.25, 0.25, 0),
            ("overflow", 1, 0.25, 1),
            ("negative", -1, 0, 0),
            ("nan", .nan, 0, 0),
            ("positive infinity", .infinity, 0, 0),
            ("negative infinity", -.infinity, 0, 0),
        ]
        let face = FaceGeometry.phase46AsymmetricComplete

        XCTAssertEqual(phase46ResolverRows.count, 4)
        XCTAssertEqual(Set(phase46ResolverRows.map(\.name)).count, 4)
        for row in phase46ResolverRows {
            for input in inputs {
                let parameters = row.makeParameters(input.value)
                let plan = BeautyEffectResolver.resolve(
                    parameters: parameters,
                    faceGeometry: face
                )
                let label = "\(row.name) \(input.name)"

                XCTAssertEqual(
                    plan.effectiveStrengths[keyPath: row.effectiveValue],
                    input.expected,
                    accuracy: 0.000_001,
                    label
                )
                XCTAssertEqual(
                    plan.metrics["beauty.effects.cappedCount"],
                    input.cappedCount,
                    label
                )
                XCTAssertEqual(
                    plan.warnings.filter { $0.code == "beauty_strength_capped" }.count,
                    input.cappedCount == 1 ? 1 : 0,
                    label
                )
                XCTAssertEqual(
                    row.emissionPoints(face, plan.effectiveStrengths).isEmpty,
                    input.expected == 0,
                    label
                )
                XCTAssertEqual(
                    plan.activeDomains.contains(.faceShape),
                    input.expected > 0,
                    label
                )
                XCTAssertFalse(plan.skippedDomains.contains(.faceShape), label)
                assertRedacted(plan)
            }
        }
    }

    func testGEOMProviderEmptyFaceWorkIsRemovedBeforeDomainAndConflictAccounting() {
        let row = phase46ResolverRows[0]
        let face = FaceGeometry.phase46LocallyStraightContour
        let parameters = row.makeParameters(0.25)
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)

        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: parameters))
        XCTAssertTrue(row.emissionPoints(face, plan.effectiveStrengths).isEmpty)
        XCTAssertEqual(plan.effectiveStrengths[keyPath: row.effectiveValue], 0)
        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.skippedDomains.contains(.faceShape))
        XCTAssertFalse(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertNil(plan.metrics["beauty.effects.geometryStrengthScale"])
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 0)
        XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 0)
        XCTAssertTrue(
            BeautyGeometryEffectPipeline.controlPoints(
                for: plan.effectiveStrengths,
                face: face
            ).isEmpty
        )

        for invalidRow in phase46ResolverRows {
            var siblingParameters = invalidRow.makeParameters(1)
            siblingParameters.faceSlim = 0.20
            let siblingPlan = BeautyEffectResolver.resolve(
                parameters: siblingParameters,
                faceGeometry: .phase46LegacyProxyOnly
            )
            let shippedFacePoints = FaceShapeWarpProvider().fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: siblingPlan.effectiveStrengths
            ).faceSlim

            XCTAssertEqual(
                siblingPlan.effectiveStrengths[keyPath: invalidRow.effectiveValue],
                0,
                invalidRow.name
            )
            XCTAssertTrue(siblingPlan.activeDomains.contains(.faceShape), invalidRow.name)
            XCTAssertFalse(siblingPlan.skippedDomains.contains(.faceShape), invalidRow.name)
            XCTAssertFalse(shippedFacePoints.isEmpty, invalidRow.name)
            XCTAssertTrue(
                invalidRow.emissionPoints(
                    .phase46LegacyProxyOnly,
                    siblingPlan.effectiveStrengths
                ).isEmpty,
                invalidRow.name
            )
            XCTAssertEqual(
                siblingPlan.metrics["beauty.effects.geometryPointCount"],
                Double(shippedFacePoints.count),
                invalidRow.name
            )
            XCTAssertNil(
                siblingPlan.metrics["beauty.effects.geometryStrengthScale"],
                invalidRow.name
            )
            XCTAssertFalse(
                siblingPlan.warnings.contains { $0.code == "combined_geometry_weakened" },
                invalidRow.name
            )
            assertRedacted(siblingPlan)
        }
    }

    func testPhase38MOUTH05Through08ExactCapsRoutingWarningsAndCounts() {
        let cases: [(String, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            ("Y positive", BeautyParameters(mouthYPosition: 1), \.mouthYPosition, 0.25),
            ("Y negative", BeautyParameters(mouthYPosition: -1), \.mouthYPosition, -0.25),
            ("tilt positive", BeautyParameters(mouthTilt: 1), \.mouthTilt, 0.25),
            ("tilt negative", BeautyParameters(mouthTilt: -1), \.mouthTilt, -0.25),
            ("X positive", BeautyParameters(mouthXPosition: 1), \.mouthXPosition, 0.25),
            ("X negative", BeautyParameters(mouthXPosition: -1), \.mouthXPosition, -0.25),
            ("peak", BeautyParameters(lipPeakDefinition: 1), \.lipPeakDefinition, 0.25),
            ("plump", BeautyParameters(lipPlump: 1), \.lipPlump, 0.25),
        ]

        for (name, parameters, keyPath, expected) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: parameters), name)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.000001, name)
            XCTAssertTrue(plan.activeDomains.contains(.mouth), name)
            XCTAssertFalse(plan.skippedDomains.contains(.mouth), name)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1, name)
            XCTAssertEqual(plan.warnings.filter { $0.code == "beauty_strength_capped" }.count, 1, name)
            XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" }, name)
            XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, name)
            assertRedacted(plan)
        }
    }

    func testPhase38NegativePositiveOnlyLipInputsAreSilentNoOps() {
        let cases: [(String, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>)] = [
            ("peak", BeautyParameters(lipPeakDefinition: -1), \.lipPeakDefinition),
            ("plump", BeautyParameters(lipPlump: -1), \.lipPlump),
        ]
        for (name, parameters, keyPath) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: parameters), name)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], 0, name)
            XCTAssertFalse(plan.activeDomains.contains(.mouth), name)
            XCTAssertFalse(plan.skippedDomains.contains(.mouth), name)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 0, name)
            XCTAssertTrue(plan.warnings.isEmpty, name)
        }
    }

    func testMOUTH12ExactCapInputsDoNotCountAsCappedAndOverflowCountsExactlyOnce() {
        let cases: [(String, BeautyParameters, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            ("Y positive", BeautyParameters(mouthYPosition: 0.25), BeautyParameters(mouthYPosition: 1), \.mouthYPosition, 0.25),
            ("Y negative", BeautyParameters(mouthYPosition: -0.25), BeautyParameters(mouthYPosition: -1), \.mouthYPosition, -0.25),
            ("tilt positive", BeautyParameters(mouthTilt: 0.25), BeautyParameters(mouthTilt: 1), \.mouthTilt, 0.25),
            ("tilt negative", BeautyParameters(mouthTilt: -0.25), BeautyParameters(mouthTilt: -1), \.mouthTilt, -0.25),
            ("X positive", BeautyParameters(mouthXPosition: 0.25), BeautyParameters(mouthXPosition: 1), \.mouthXPosition, 0.25),
            ("X negative", BeautyParameters(mouthXPosition: -0.25), BeautyParameters(mouthXPosition: -1), \.mouthXPosition, -0.25),
            ("peak", BeautyParameters(lipPeakDefinition: 0.25), BeautyParameters(lipPeakDefinition: 1), \.lipPeakDefinition, 0.25),
            ("plump", BeautyParameters(lipPlump: 0.25), BeautyParameters(lipPlump: 1), \.lipPlump, 0.25),
        ]

        for (name, exactParameters, overflowParameters, keyPath, expected) in cases {
            let exact = BeautyEffectResolver.resolve(parameters: exactParameters, faceGeometry: .fixture)
            XCTAssertEqual(exact.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.000001, name)
            XCTAssertEqual(exact.metrics["beauty.effects.cappedCount"], 0, name)
            XCTAssertFalse(exact.warnings.contains { $0.code == "beauty_strength_capped" }, name)

            let overflow = BeautyEffectResolver.resolve(parameters: overflowParameters, faceGeometry: .fixture)
            XCTAssertEqual(overflow.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.000001, name)
            XCTAssertEqual(overflow.metrics["beauty.effects.cappedCount"], 1, name)
            XCTAssertEqual(overflow.warnings.filter { $0.code == "beauty_strength_capped" }.count, 1, name)
            assertRedacted(overflow)
        }
    }

    func testEYE04EyeCapsResolveExactValuesDirectionsWarningsAndCounts() {
        let cases: [(name: String, parameters: BeautyParameters, keyPath: KeyPath<BeautyEffectiveStrengths, Float>, expected: Float)] = [
            ("eyeSize positive", BeautyParameters(eyeSize: 1), \.eyeSize, BeautySafetyCaps.eyeSize),
            ("eyeDistance positive", BeautyParameters(eyeDistance: 1), \.eyeDistance, BeautySafetyCaps.eyeDistance),
            ("eyeDistance negative", BeautyParameters(eyeDistance: -1), \.eyeDistance, -BeautySafetyCaps.eyeDistance),
            ("eyeYPosition positive", BeautyParameters(eyeYPosition: 1), \.eyeYPosition, BeautySafetyCaps.eyeYPosition),
            ("eyeYPosition negative", BeautyParameters(eyeYPosition: -1), \.eyeYPosition, -BeautySafetyCaps.eyeYPosition),
            ("eyeTailLift positive", BeautyParameters(eyeTailLift: 1), \.eyeTailLift, BeautySafetyCaps.eyeTailLift),
        ]

        for entry in cases {
            let plan = BeautyEffectResolver.resolve(
                parameters: entry.parameters,
                faceGeometry: .fixture
            )

            XCTAssertTrue(plan.activeDomains.contains(.eyes), entry.name)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: entry.keyPath], entry.expected, accuracy: 0.0001, entry.name)
            XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" }, entry.name)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1, entry.name)
            XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" }, entry.name)
        }
    }

    func testEYE04NegativePositiveOnlyEyeInputsAreNoOps() {
        let cases: [(name: String, parameters: BeautyParameters, publicKeyPath: KeyPath<BeautyParameters, Float>, effectiveKeyPath: KeyPath<BeautyEffectiveStrengths, Float>)] = [
            ("negative eyeSize", BeautyParameters(eyeSize: -1), \.eyeSize, \.eyeSize),
            ("negative eyeTailLift", BeautyParameters(eyeTailLift: -1), \.eyeTailLift, \.eyeTailLift),
        ]

        for entry in cases {
            let plan = BeautyEffectResolver.resolve(
                parameters: entry.parameters,
                faceGeometry: .fixture
            )

            XCTAssertEqual(entry.parameters[keyPath: entry.publicKeyPath], 0, entry.name)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: entry.effectiveKeyPath], 0, entry.name)
            XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: entry.parameters), entry.name)
            XCTAssertFalse(plan.activeDomains.contains(.eyes), entry.name)
            XCTAssertFalse(plan.skippedDomains.contains(.eyes), entry.name)
            XCTAssertFalse(plan.warnings.contains { $0.code == "eye_inputs_missing" }, entry.name)
            XCTAssertFalse(plan.warnings.contains { $0.code == "beauty_strength_capped" }, entry.name)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 0, entry.name)
        }
    }

    func testEYE19FinalEyeCapNormalizationWarningAndMetricMatrix() {
        struct Field {
            let name: String
            let cap: Float
            let makeParameters: (Float) -> BeautyParameters
            let publicValue: KeyPath<BeautyParameters, Float>
            let effectiveValue: KeyPath<BeautyEffectiveStrengths, Float>
        }
        struct Row {
            let name: String
            let input: Float
            let normalized: Float
            let effectiveMultiplier: Float
            let cappedCount: Double
        }

        let positiveFields = [
            Field(name: "eyeHeight", cap: BeautySafetyCaps.eyeHeight, makeParameters: { BeautyParameters(eyeHeight: $0) }, publicValue: \.eyeHeight, effectiveValue: \.eyeHeight),
            Field(name: "eyeLength", cap: BeautySafetyCaps.eyeLength, makeParameters: { BeautyParameters(eyeLength: $0) }, publicValue: \.eyeLength, effectiveValue: \.eyeLength),
            Field(name: "upperEyelidLift", cap: BeautySafetyCaps.upperEyelidLift, makeParameters: { BeautyParameters(upperEyelidLift: $0) }, publicValue: \.upperEyelidLift, effectiveValue: \.upperEyelidLift),
            Field(name: "pupilSize", cap: BeautySafetyCaps.pupilSize, makeParameters: { BeautyParameters(pupilSize: $0) }, publicValue: \.pupilSize, effectiveValue: \.pupilSize),
            Field(name: "gazeCorrection", cap: BeautySafetyCaps.gazeCorrection, makeParameters: { BeautyParameters(gazeCorrection: $0) }, publicValue: \.gazeCorrection, effectiveValue: \.gazeCorrection),
            Field(name: "lowerEyelidDrop", cap: BeautySafetyCaps.lowerEyelidDrop, makeParameters: { BeautyParameters(lowerEyelidDrop: $0) }, publicValue: \.lowerEyelidDrop, effectiveValue: \.lowerEyelidDrop),
            Field(name: "innerCornerOpen", cap: BeautySafetyCaps.innerCornerOpen, makeParameters: { BeautyParameters(innerCornerOpen: $0) }, publicValue: \.innerCornerOpen, effectiveValue: \.innerCornerOpen),
            Field(name: "outerCornerOpen", cap: BeautySafetyCaps.outerCornerOpen, makeParameters: { BeautyParameters(outerCornerOpen: $0) }, publicValue: \.outerCornerOpen, effectiveValue: \.outerCornerOpen),
            Field(name: "eyeSymmetry", cap: BeautySafetyCaps.eyeSymmetry, makeParameters: { BeautyParameters(eyeSymmetry: $0) }, publicValue: \.eyeSymmetry, effectiveValue: \.eyeSymmetry),
        ]
        let rows = [
            Row(name: "zero", input: 0, normalized: 0, effectiveMultiplier: 0, cappedCount: 0),
            Row(name: "exact cap", input: 0.25, normalized: 0.25, effectiveMultiplier: 1, cappedCount: 0),
            Row(name: "public overflow", input: 1, normalized: 1, effectiveMultiplier: 1, cappedCount: 1),
            Row(name: "negative", input: -1, normalized: 0, effectiveMultiplier: 0, cappedCount: 0),
            Row(name: "nan", input: .nan, normalized: 0, effectiveMultiplier: 0, cappedCount: 0),
            Row(name: "positive infinity", input: .infinity, normalized: 0, effectiveMultiplier: 0, cappedCount: 0),
            Row(name: "negative infinity", input: -.infinity, normalized: 0, effectiveMultiplier: 0, cappedCount: 0),
        ]

        for field in positiveFields {
            for row in rows {
                let input = row.name == "exact cap" ? field.cap : row.input
                let expectedPublic = row.name == "exact cap" ? field.cap : row.normalized
                let parameters = field.makeParameters(input)
                let plan = BeautyEffectResolver.resolve(parameters: parameters)
                let message = "\(field.name) \(row.name)"

                XCTAssertEqual(parameters[keyPath: field.publicValue], expectedPublic, accuracy: 0.000_001, message)
                XCTAssertEqual(plan.effectiveStrengths[keyPath: field.effectiveValue], field.cap * row.effectiveMultiplier, accuracy: 0.000_001, message)
                XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], row.cappedCount, message)
                XCTAssertEqual(plan.warnings.filter { $0.code == "beauty_strength_capped" }.count, row.cappedCount == 0 ? 0 : 1, message)
                assertRedacted(plan)
            }
        }

        for (name, input, expected, cappedCount) in [
            ("zero", Float(0), Float(0), Double(0)),
            ("exact positive", BeautySafetyCaps.eyeTilt, BeautySafetyCaps.eyeTilt, Double(0)),
            ("exact negative", -BeautySafetyCaps.eyeTilt, -BeautySafetyCaps.eyeTilt, Double(0)),
            ("overflow positive", Float(1), BeautySafetyCaps.eyeTilt, Double(1)),
            ("overflow negative", Float(-1), -BeautySafetyCaps.eyeTilt, Double(1)),
            ("nan", Float.nan, Float(0), Double(0)),
            ("positive infinity", Float.infinity, Float(0), Double(0)),
            ("negative infinity", -Float.infinity, Float(0), Double(0)),
        ] {
            let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(eyeTilt: input))
            XCTAssertEqual(plan.effectiveStrengths.eyeTilt, expected, accuracy: 0.000_001, name)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], cappedCount, name)
            XCTAssertEqual(plan.warnings.filter { $0.code == "beauty_strength_capped" }.count, cappedCount == 0 ? 0 : 1, name)
            assertRedacted(plan)
        }
    }

    func testPhase35NOSE03ExactCapsRoutingWarningsAndCounts() {
        let cases: [(BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (BeautyParameters(noseSlim: 1), \.noseSlim, 0.35),
            (BeautyParameters(noseWingSlim: 1), \.noseWingSlim, 0.35),
            (BeautyParameters(noseTipSize: 1), \.noseTipSize, 0.30),
            (BeautyParameters(noseTipSize: -1), \.noseTipSize, -0.30),
            (BeautyParameters(noseBridge: 1), \.noseBridge, 0.30),
            (BeautyParameters(noseRootNarrowing: 1), \.noseRootNarrowing, 0.25),
            (BeautyParameters(noseTipLift: 1), \.noseTipLift, 0.25),
        ]

        for (parameters, keyPath, expected) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.0001)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1)
            XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
            XCTAssertTrue(plan.activeDomains.contains(.nose))
            XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
            assertRedacted(plan)
        }

        let all = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(noseSlim: 1, noseWingSlim: 1, noseTipSize: -1, noseBridge: 1),
            faceGeometry: .fixture
        )
        XCTAssertEqual(all.metrics["beauty.effects.cappedCount"], 4)
        XCTAssertLessThan(all.effectiveStrengths.noseTipSize, 0)
    }

    func testPhase35NOSE03NegativePositiveOnlyInputsAreSilentNoOps() {
        let cases: [(BeautyParameters, KeyPath<BeautyParameters, Float>, KeyPath<BeautyEffectiveStrengths, Float>)] = [
            (BeautyParameters(noseSlim: -1), \.noseSlim, \.noseSlim),
            (BeautyParameters(noseWingSlim: -1), \.noseWingSlim, \.noseWingSlim),
            (BeautyParameters(noseBridge: -1), \.noseBridge, \.noseBridge),
            (BeautyParameters(noseRootNarrowing: -1), \.noseRootNarrowing, \.noseRootNarrowing),
            (BeautyParameters(noseTipLift: -1), \.noseTipLift, \.noseTipLift),
        ]

        for (parameters, publicKeyPath, effectiveKeyPath) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertEqual(parameters[keyPath: publicKeyPath], 0)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: effectiveKeyPath], 0)
            XCTAssertFalse(BeautyEffectResolver.requiresFaceGeometry(parameters: parameters))
            XCTAssertFalse(plan.activeDomains.contains(.nose))
            XCTAssertFalse(plan.skippedDomains.contains(.nose))
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 0)
            assertRedacted(plan)
        }
    }

    func testNOSE10FinalRemainingNoseCapNormalizationWarningAndMetricMatrix() {
        struct Field {
            let name: String
            let makeParameters: (Float) -> BeautyParameters
            let publicValue: KeyPath<BeautyParameters, Float>
            let effectiveValue: KeyPath<BeautyEffectiveStrengths, Float>
        }
        struct Row {
            let name: String
            let input: Float
            let normalized: Float
            let effective: Float
            let cappedCount: Double
            let eligible: Bool
        }

        let fields = [
            Field(
                name: "noseRootNarrowing",
                makeParameters: { BeautyParameters(noseRootNarrowing: $0) },
                publicValue: \.noseRootNarrowing,
                effectiveValue: \.noseRootNarrowing
            ),
            Field(
                name: "noseTipLift",
                makeParameters: { BeautyParameters(noseTipLift: $0) },
                publicValue: \.noseTipLift,
                effectiveValue: \.noseTipLift
            ),
        ]
        let rows = [
            Row(name: "zero", input: 0, normalized: 0, effective: 0, cappedCount: 0, eligible: false),
            Row(name: "exact cap", input: 0.25, normalized: 0.25, effective: 0.25, cappedCount: 0, eligible: true),
            Row(name: "public overflow", input: 1, normalized: 1, effective: 0.25, cappedCount: 1, eligible: true),
            Row(name: "negative", input: -1, normalized: 0, effective: 0, cappedCount: 0, eligible: false),
            Row(name: "nan", input: .nan, normalized: 0, effective: 0, cappedCount: 0, eligible: false),
            Row(name: "positive infinity", input: .infinity, normalized: 0, effective: 0, cappedCount: 0, eligible: false),
            Row(name: "negative infinity", input: -.infinity, normalized: 0, effective: 0, cappedCount: 0, eligible: false),
        ]

        for field in fields {
            for row in rows {
                let message = "\(field.name) \(row.name)"
                let parameters = field.makeParameters(row.input)
                let normalized = parameters.normalized()
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)

                XCTAssertEqual(parameters[keyPath: field.publicValue], row.normalized, message)
                XCTAssertEqual(normalized[keyPath: field.publicValue], row.normalized, message)
                XCTAssertEqual(plan.effectiveStrengths[keyPath: field.effectiveValue], row.effective, message)
                XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], row.cappedCount, message)
                XCTAssertEqual(plan.activeDomains.contains(.nose), row.eligible, message)
                XCTAssertFalse(plan.skippedDomains.contains(.nose), message)
                XCTAssertEqual(
                    plan.warnings.filter { $0.code == "beauty_strength_capped" }.count,
                    row.cappedCount == 0 ? 0 : 1,
                    message
                )
                XCTAssertFalse(plan.warnings.contains { $0.code == "nose_inputs_missing" }, message)
                XCTAssertEqual(
                    Set(plan.metrics.keys),
                    row.eligible
                        ? ["beauty.effects.activeCount", "beauty.effects.cappedCount", "beauty.effects.geometryPointCount"]
                        : ["beauty.effects.activeCount", "beauty.effects.cappedCount"],
                    message
                )
                if row.eligible {
                    XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, message)
                }
                assertRedacted(plan)
            }
        }
    }

    func testSelectedFaceObservationActivatesGeometryPlanningWithRedactedEvidence() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 0.4,
                eyeSize: 0.4,
                noseSlim: 0.4,
                mouthSize: 0.4,
                lipColor: 0.4
            ),
            selectedFaceObservation: .usableFixture
        )

        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.lipColor))
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        assertRedacted(plan)
    }

    func testSelectedFaceObservationFallbackBoundsStillActivateGeometryPlanning() {
        let observation = BeautyFaceObservation(
            stableID: "fallback",
            confidence: 0.95,
            normalizedArea: 0.30,
            landmarks: .complete
        )

        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.4, eyeSize: 0.4, noseSlim: 0.4),
            selectedFaceObservation: observation
        )

        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        assertRedacted(plan)
    }

    private func assertRedacted(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["land" + "mark", "control point", "control" + "Point", "bounding", "VNFace" + "Observation", "/private" + "/var", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }

    private func eyebrowResolverFace(
        freshness: LandmarkGeometryFreshness = .fresh,
        includeRight: Bool = true
    ) -> FaceGeometry {
        func trace(side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
            let points: [SIMD2<Float>] = side == .left
                ? [.init(0.25, 0.40), .init(0.30, 0.36), .init(0.36, 0.34), .init(0.42, 0.37), .init(0.47, 0.41)]
                : [.init(0.75, 0.40), .init(0.70, 0.36), .init(0.64, 0.34), .init(0.58, 0.37), .init(0.53, 0.41)]
            return BeautyEyebrowSemanticTrace(
                side: side,
                points: points,
                innerEndpoint: points[0],
                outerEndpoint: points[points.count - 1],
                center: points.reduce(.zero, +) / Float(points.count),
                apexIndex: 2
            )
        }
        let left = trace(side: .left)
        let right = includeRight ? trace(side: .right) : nil
        return FaceGeometry(
            bounds: FaceBounds(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: FaceGeometry.fixture.nose,
            outerLips: FaceGeometry.fixture.outerLips,
            freshness: freshness,
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(left: left, right: right)
        )
    }

    private var phase46ResolverRows: [Phase46ResolverFieldRow] {
        [
            Phase46ResolverFieldRow(
                name: "faceContourSmooth",
                makeParameters: { BeautyParameters(faceContourSmooth: $0) },
                publicValue: \.faceContourSmooth,
                effectiveValue: \.faceContourSmooth,
                requiresCenterline: false,
                emissionPoints: {
                    FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).faceContourSmooth
                }
            ),
            Phase46ResolverFieldRow(
                name: "templeFullness",
                makeParameters: { BeautyParameters(templeFullness: $0) },
                publicValue: \.templeFullness,
                effectiveValue: \.templeFullness,
                requiresCenterline: false,
                emissionPoints: {
                    FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).templeFullness
                }
            ),
            Phase46ResolverFieldRow(
                name: "cheekboneSlim",
                makeParameters: { BeautyParameters(cheekboneSlim: $0) },
                publicValue: \.cheekboneSlim,
                effectiveValue: \.cheekboneSlim,
                requiresCenterline: false,
                emissionPoints: {
                    FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).cheekboneSlim
                }
            ),
            Phase46ResolverFieldRow(
                name: "chinTaper",
                makeParameters: { BeautyParameters(chinTaper: $0) },
                publicValue: \.chinTaper,
                effectiveValue: \.chinTaper,
                requiresCenterline: true,
                emissionPoints: {
                    ChinWarpProvider().fieldEmissions(face: $0, strengths: $1).chinTaper
                }
            ),
        ]
    }

    private func phase46Face(
        _ face: FaceGeometry,
        freshness: LandmarkGeometryFreshness
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: face.bounds,
            faceContour: face.faceContour,
            observedFaceSupport: face.observedFaceSupport,
            leftEye: face.leftEye,
            rightEye: face.rightEye,
            nose: face.nose,
            noseRoot: face.noseRoot,
            noseTip: face.noseTip,
            outerLips: face.outerLips,
            upperLips: face.upperLips,
            lowerLips: face.lowerLips,
            innerLips: face.innerLips,
            leftEyeSupport: face.leftEyeSupport,
            rightEyeSupport: face.rightEyeSupport,
            freshness: freshness
        )
    }
}

extension BeautyFaceObservation {
    static let usableFixture = BeautyFaceObservation(
        stableID: "selected",
        confidence: 0.96,
        imageBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
        landmarks: .complete
    )
}
