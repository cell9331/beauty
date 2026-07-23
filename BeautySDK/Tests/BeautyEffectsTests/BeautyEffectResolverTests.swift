import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

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

    func testFACE07FACE08FACE09FACE12ExplicitZeroPreservesShippedPlanAndNonzeroDoesNotRouteYet() {
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

        let deferredRequests = [
            BeautyParameters(faceContourSmooth: 0.4),
            BeautyParameters(templeFullness: 0.4),
            BeautyParameters(cheekboneSlim: 0.4),
            BeautyParameters(chinTaper: 0.4),
        ]
        for parameters in deferredRequests {
            XCTAssertFalse(
                BeautyEffectResolver.requiresFaceGeometry(parameters: parameters),
                "Phase 46 owns provider eligibility and routing"
            )
            XCTAssertEqual(
                BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture),
                BeautyEffectResolver.resolve(parameters: BeautyParameters(), faceGeometry: .fixture),
                "nonzero public intent remains unrouted in Phase 45"
            )
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
}

extension BeautyFaceObservation {
    static let usableFixture = BeautyFaceObservation(
        stableID: "selected",
        confidence: 0.96,
        imageBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
        landmarks: .complete
    )
}
