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
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(mouthSize: 0.4)))
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: BeautyParameters(lipColor: 0.4)))
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
