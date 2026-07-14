import CoreImage
import XCTest
import BeautyCore
import BeautyResources
@testable import BeautyEffects

final class CombinedEffectSafetyTests: XCTestCase {
    func testMOUTH05ExactCapsSignedSemanticsWarningAndCappedCount() {
        let cases: [(BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (BeautyParameters(mouthSize: 1), \.mouthSize, 0.35),
            (BeautyParameters(mouthSize: -1), \.mouthSize, -0.35),
            (BeautyParameters(mouthWidth: 1), \.mouthWidth, 0.35),
            (BeautyParameters(mouthWidth: -1), \.mouthWidth, -0.35),
            (BeautyParameters(smile: 1), \.smile, 0.50),
            (BeautyParameters(lipColor: 1), \.lipColor, 0.50),
        ]
        for (parameters, keyPath, expected) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.0001)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1)
            XCTAssertTrue(plan.warnings.contains {
                $0.code == "beauty_strength_capped" &&
                    $0.message == "Effective beauty strength was capped for natural output."
            })
            assertCombinedMetadataRedacted(plan)
        }
    }

    func testNoFaceSkipsFaceDependentDomainsButKeepsColorAndFilterActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 0.6,
                brightness: 0.2,
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                chinLength: -1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: nil
        )

        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertFalse(plan.activeDomains.contains(.skin))
        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertFalse(plan.activeDomains.contains(.lipColor))

        XCTAssertTrue(plan.skippedDomains.contains(.skin))
        XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
        XCTAssertTrue(plan.skippedDomains.contains(.eyes))
        XCTAssertTrue(plan.skippedDomains.contains(.nose))
        XCTAssertTrue(plan.skippedDomains.contains(.mouth))
        XCTAssertTrue(plan.skippedDomains.contains(.lipColor))
        XCTAssertGreaterThanOrEqual(plan.metrics["beauty.effects.skippedFaceDomains"] ?? 0, 6)
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
    }

    func testCombinedHighStrengthAllDomainsCapAndWeakenGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 1,
                skinWhitening: 1,
                skinRosy: 1,
                skinSharpen: 1,
                brightness: 0.2,
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
                mouthSize: 1,
                mouthWidth: 1,
                smile: 1,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 1
            ),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.skin, .color, .filter, .faceShape, .eyes, .nose, .mouth, .lipColor]))
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertGreaterThan(plan.metrics["beauty.effects.cappedCount"] ?? 0, 0)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.weakenedCount"] ?? 0, 0)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertLessThan(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim)
        XCTAssertLessThan(plan.effectiveStrengths.faceSmall, BeautySafetyCaps.faceSmall)
        XCTAssertLessThan(plan.effectiveStrengths.faceVShape, BeautySafetyCaps.faceVShape)
        XCTAssertLessThan(plan.effectiveStrengths.jawSlim, BeautySafetyCaps.jawSlim)
        XCTAssertLessThan(abs(plan.effectiveStrengths.chinLength), BeautySafetyCaps.chinLength)
        XCTAssertLessThan(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
        XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertLessThan(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize)
    }

    func testPERF03HighCappedTimingParametersPreserveSafetyCapsAndRedactedMetrics() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 1,
                skinWhitening: 1,
                brightness: 0.2,
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: 1,
                noseBridge: 1,
                mouthSize: 1,
                mouthWidth: 1,
                smile: 1,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 1
            ),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertGreaterThan(plan.metrics["beauty.effects.cappedCount"] ?? 0, 0)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.weakenedCount"] ?? 0, 0)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinSmoothing, BeautySafetyCaps.skinSmoothing)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinWhitening, BeautySafetyCaps.skinWhitening)
        XCTAssertLessThan(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim)
        XCTAssertLessThan(plan.effectiveStrengths.faceSmall, BeautySafetyCaps.faceSmall)
        XCTAssertLessThan(plan.effectiveStrengths.faceVShape, BeautySafetyCaps.faceVShape)
        XCTAssertLessThan(plan.effectiveStrengths.jawSlim, BeautySafetyCaps.jawSlim)
        XCTAssertLessThan(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
        XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertLessThan(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)

        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["VNFace" + "Observation", "bounding" + "Box", "/private" + "/var", "NSE" + "rror", "rawPreset" + "Json", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testBuiltInPresetsStayWithinCapsAndProduceVisibleFixtureEvidence() throws {
        let image = CIImage(color: CIColor(red: 0.25, green: 0.30, blue: 0.35, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 1))
        let inputBytes = rgbaBytes(from: image)
        let catalog = try BeautyResourceCatalog.bundled()

        for presetID in ["natural", "clear", "refined", "male-natural", "id-photo-natural"] {
            let preset = try catalog.preset(id: presetID)
            let plan = BeautyEffectResolver.resolve(
                parameters: preset.parameters,
                faceGeometry: .fixture
            )
            let output = BeautyColorEffectPipeline.apply(to: image, plan: plan, face: .fixture)

            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.faceSlim), BeautySafetyCaps.faceSlim, presetID)
            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.eyeSize), BeautySafetyCaps.eyeSize, presetID)
            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.noseSlim), BeautySafetyCaps.noseSlim, presetID)
            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.mouthSize), BeautySafetyCaps.mouthSize, presetID)
            XCTAssertLessThanOrEqual(plan.effectiveStrengths.lipColor, BeautySafetyCaps.lipColor, presetID)
            XCTAssertNotEqual(rgbaBytes(from: output), inputBytes, presetID)
        }
    }

    func testWarningAndMetricMetadataStayRedactedForCombinedPlan() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 1,
                faceSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1
            ),
            faceGeometry: .fixture
        )
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["VNFace" + "Observation", "bounding" + "Box", "land" + "mark", "/private" + "/var", "NSE" + "rror", "rawPreset" + "Json", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testEYE06EachVisibleEyeBehaviorWeakensWithFaceShapeAndPreservesDirection() {
        let cases: [(name: String, parameters: BeautyParameters, keyPath: KeyPath<BeautyEffectiveStrengths, Float>, expected: Float)] = [
            ("eyeSize positive", BeautyParameters(eyeSize: 1), \.eyeSize, BeautySafetyCaps.eyeSize),
            ("eyeDistance positive", BeautyParameters(eyeDistance: 1), \.eyeDistance, BeautySafetyCaps.eyeDistance),
            ("eyeDistance negative", BeautyParameters(eyeDistance: -1), \.eyeDistance, -BeautySafetyCaps.eyeDistance),
            ("eyeYPosition positive", BeautyParameters(eyeYPosition: 1), \.eyeYPosition, BeautySafetyCaps.eyeYPosition),
            ("eyeYPosition negative", BeautyParameters(eyeYPosition: -1), \.eyeYPosition, -BeautySafetyCaps.eyeYPosition),
            ("eyeTailLift positive", BeautyParameters(eyeTailLift: 1), \.eyeTailLift, BeautySafetyCaps.eyeTailLift),
        ]

        for entry in cases {
            let normal = BeautyEffectResolver.resolve(parameters: entry.parameters, faceGeometry: .fixture)
            var combinedParameters = entry.parameters
            combinedParameters.faceSlim = 1
            combinedParameters.faceSmall = 1
            let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)
            let normalValue = normal.effectiveStrengths[keyPath: entry.keyPath]
            let combinedValue = combined.effectiveStrengths[keyPath: entry.keyPath]

            XCTAssertEqual(normalValue, entry.expected, accuracy: 0.0001, entry.name)
            XCTAssertTrue(combined.activeDomains.isSuperset(of: [.eyes, .faceShape]), entry.name)
            XCTAssertGreaterThan(abs(combinedValue), 0, entry.name)
            XCTAssertLessThan(abs(combinedValue), abs(normalValue), entry.name)
            XCTAssertEqual(combinedValue.sign, normalValue.sign, entry.name)
            XCTAssertTrue(combined.warnings.contains { $0.code == "combined_geometry_weakened" }, entry.name)
            XCTAssertGreaterThan(combined.metrics["beauty.effects.weakenedCount"] ?? 0, 0, entry.name)
            XCTAssertLessThan(combined.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1, entry.name)
        }
    }

    func testEYE06AllEyeMultiDomainCaseEmitsStableWeakeningEvidence() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                eyeSize: 1,
                eyeDistance: -1,
                eyeYPosition: 1,
                eyeTailLift: 1,
                noseSlim: 1
            ),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.eyes, .faceShape, .nose]))
        XCTAssertLessThan(plan.effectiveStrengths.eyeDistance, 0)
        XCTAssertGreaterThan(plan.effectiveStrengths.eyeYPosition, 0)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 6)
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertLessThan(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        assertCombinedMetadataRedacted(plan)
    }

    func testNOSE12EveryNoseDirectionUsesExactOnceOnlyFaceEyeMouthScaling() {
        let cases: [(name: String, parameters: BeautyParameters, keyPath: KeyPath<BeautyEffectiveStrengths, Float>, unscaled: Float)] = [
            ("noseSlim", BeautyParameters(noseSlim: 1), \.noseSlim, BeautySafetyCaps.noseSlim),
            ("noseWingSlim", BeautyParameters(noseWingSlim: 1), \.noseWingSlim, BeautySafetyCaps.noseWingSlim),
            ("noseTipSize positive", BeautyParameters(noseTipSize: 1), \.noseTipSize, BeautySafetyCaps.noseTipSize),
            ("noseTipSize negative", BeautyParameters(noseTipSize: -1), \.noseTipSize, -BeautySafetyCaps.noseTipSize),
            ("noseBridge", BeautyParameters(noseBridge: 1), \.noseBridge, BeautySafetyCaps.noseBridge),
            ("noseRootNarrowing", BeautyParameters(noseRootNarrowing: 1), \.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing),
            ("noseTipLift", BeautyParameters(noseTipLift: 1), \.noseTipLift, BeautySafetyCaps.noseTipLift),
        ]

        for entry in cases {
            let normal = BeautyEffectResolver.resolve(parameters: entry.parameters, faceGeometry: .fixture)
            var combinedParameters = entry.parameters
            combinedParameters.faceSlim = 1
            combinedParameters.eyeSize = 1
            combinedParameters.mouthSize = 1
            let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)
            let retainedTotal = BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.eyeSize +
                BeautySafetyCaps.mouthSize +
                abs(entry.unscaled)
            let expectedScale = 1 / retainedTotal

            XCTAssertEqual(normal.effectiveStrengths[keyPath: entry.keyPath], entry.unscaled, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths[keyPath: entry.keyPath], entry.unscaled * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths[keyPath: entry.keyPath].sign, entry.unscaled.sign, entry.name)
            XCTAssertEqual(combined.metrics["beauty.effects.weakenedCount"], 4, entry.name)
            XCTAssertEqual(
                combined.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
                Double(expectedScale),
                accuracy: 0.0000001,
                entry.name
            )
            XCTAssertEqual(combined.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1, entry.name)
            XCTAssertTrue(combined.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth]), entry.name)
            assertCombinedMetadataRedacted(combined)
        }
    }

    func testMOUTH08EveryMouthGeometryFieldWeakensWithFaceEyeNoseAndPreservesDirection() {
        let cases: [(BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (BeautyParameters(mouthSize: 1, lipColor: 1), \.mouthSize, 0.35),
            (BeautyParameters(mouthSize: -1, lipColor: 1), \.mouthSize, -0.35),
            (BeautyParameters(mouthWidth: 1, lipColor: 1), \.mouthWidth, 0.35),
            (BeautyParameters(mouthWidth: -1, lipColor: 1), \.mouthWidth, -0.35),
            (BeautyParameters(smile: 1, lipColor: 1), \.smile, 0.50),
        ]

        for (mouthParameters, keyPath, expected) in cases {
            let normal = BeautyEffectResolver.resolve(parameters: mouthParameters, faceGeometry: .fixture)
            var combinedParameters = mouthParameters
            combinedParameters.faceSlim = 1
            combinedParameters.eyeSize = 1
            combinedParameters.noseSlim = 1
            let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)
            let normalValue = normal.effectiveStrengths[keyPath: keyPath]
            let combinedValue = combined.effectiveStrengths[keyPath: keyPath]

            XCTAssertEqual(normalValue, expected, accuracy: 0.0001)
            XCTAssertGreaterThan(abs(combinedValue), 0)
            XCTAssertLessThan(abs(combinedValue), abs(normalValue))
            XCTAssertEqual(combinedValue.sign, normalValue.sign)
            XCTAssertEqual(combined.effectiveStrengths.lipColor, 0.50, accuracy: 0.0001)
            XCTAssertTrue(combined.warnings.contains { $0.code == "combined_geometry_weakened" })
            assertCombinedMetadataRedacted(combined)
        }
    }

    private func assertCombinedMetadataRedacted(
        _ plan: BeautyEffectPlan,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } + Array(plan.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["VNFace" + "Observation", "bounding" + "Box", "land" + "mark", "/private" + "/var", "NSE" + "rror", "rawPreset" + "Json", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }

    private func rgbaBytes(from image: CIImage) -> [UInt8] {
        let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
        var output = [UInt8](repeating: 0, count: 2 * 1 * 4)
        context.render(
            image,
            toBitmap: &output,
            rowBytes: 2 * 4,
            bounds: CGRect(x: 0, y: 0, width: 2, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return output
    }
}
