import BeautyCore
import BeautyResources
import CryptoKit
import XCTest

// Requirement evidence: EFFECT-03, EFFECT-08, SEC-03.
final class BeautyResourceCatalogTests: XCTestCase {
    func testEFFECT03BundledCatalogListsMetadataFilters() throws {
        let catalog = try BeautyResourceCatalog.bundled()

        XCTAssertEqual(
            catalog.availableFilters,
            [
                BeautyFilterDefinition(id: "soft_clean", displayName: "Soft Clean"),
                BeautyFilterDefinition(id: "warm_light", displayName: "Warm Light")
            ]
        )
        XCTAssertEqual(catalog.availableFilterIds, ["soft_clean", "warm_light"])
    }

    func testEFFECT08BundledCatalogLoadsRequiredPresetNames() throws {
        let catalog = try BeautyResourceCatalog.bundled()

        XCTAssertEqual(
            try catalog.builtInPresets().map(\.displayName),
            ["Natural", "Clear", "Refined", "Male Natural", "ID Photo Natural"]
        )
    }

    func testNOSE02BundledPresetsDecodeNewNoseFieldsAsZero() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()

        XCTAssertEqual(
            presets.map(\.id),
            ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        )
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            XCTAssertEqual(
                preset.parameters.noseRootNarrowing,
                0,
                "\(preset.id) noseRootNarrowing"
            )
            XCTAssertEqual(
                preset.parameters.noseTipLift,
                0,
                "\(preset.id) noseTipLift"
            )
        }
    }

    func testPhase38MOUTH03BundledPresetsDecodeNewMouthFieldsAsZero() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()

        XCTAssertEqual(
            presets.map(\.id),
            ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        )
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            XCTAssertEqual(
                preset.parameters.mouthYPosition,
                0,
                "\(preset.id) mouthYPosition"
            )
            XCTAssertEqual(
                preset.parameters.mouthTilt,
                0,
                "\(preset.id) mouthTilt"
            )
            XCTAssertEqual(
                preset.parameters.mouthXPosition,
                0,
                "\(preset.id) mouthXPosition"
            )
            XCTAssertEqual(
                preset.parameters.lipPeakDefinition,
                0,
                "\(preset.id) lipPeakDefinition"
            )
            XCTAssertEqual(
                preset.parameters.lipPlump,
                0,
                "\(preset.id) lipPlump"
            )
        }
    }

    func testFACE07FACE08FACE09FACE12BundledPresetsDecodeNewFaceFieldsAsZero() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()

        XCTAssertEqual(
            presets.map(\.id),
            ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        )
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            XCTAssertEqual(
                preset.parameters.faceContourSmooth,
                0,
                "\(preset.id) faceContourSmooth"
            )
            XCTAssertEqual(
                preset.parameters.templeFullness,
                0,
                "\(preset.id) templeFullness"
            )
            XCTAssertEqual(
                preset.parameters.cheekboneSlim,
                0,
                "\(preset.id) cheekboneSlim"
            )
            XCTAssertEqual(
                preset.parameters.chinTaper,
                0,
                "\(preset.id) chinTaper"
            )
        }
    }

    func testBROW02ExactlyFiveBundledPresetsDecodeSevenMissingEyebrowFieldsAsZero() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()

        XCTAssertEqual(
            presets.map(\.id),
            ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        )
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            XCTAssertEqual(
                [
                    preset.parameters.eyebrowYPosition,
                    preset.parameters.eyebrowThickness,
                    preset.parameters.eyebrowLength,
                    preset.parameters.eyebrowSpacing,
                    preset.parameters.eyebrowHeadSpacing,
                    preset.parameters.eyebrowTilt,
                    preset.parameters.eyebrowPeakDefinition,
                ],
                Array(repeating: Float(0), count: 7),
                preset.id
            )
        }
    }

    func testEFFECT08PresetLookupIsDeterministicAndComplete() throws {
        let catalog = try BeautyResourceCatalog.bundled()

        let preset = try catalog.preset(id: "id-photo-natural")

        XCTAssertEqual(preset.displayName, "ID Photo Natural")
        XCTAssertEqual(preset.parameters.filterId, nil)
        XCTAssertEqual(preset.parameters.filterIntensity, 0, accuracy: 0.0001)
        XCTAssertEqual(preset.parameters.brightness, 0.04, accuracy: 0.0001)
        XCTAssertEqual(preset.parameters.contrast, 0.03, accuracy: 0.0001)
    }

    func testEFFECT03ManifestReferencesRemainMetadataOnly() throws {
        let catalog = try BeautyResourceCatalog.bundled()
        let forbiddenTokens = ["/", "..", "." + "cube", "thumb" + "nail", "sw" + "atch"]

        XCTAssertEqual(catalog.manifest.schemaVersion, 1)
        XCTAssertEqual(catalog.manifest.filters.count, 2)

        for filter in catalog.manifest.filters {
            XCTAssertTrue(BeautyResourceManifest.isValidResourceIdentifier(filter.id))
            XCTAssertFalse(filter.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertTrue(forbiddenTokens.allSatisfy { !filter.id.contains($0) })
        }

        for preset in catalog.manifest.presets {
            XCTAssertTrue(BeautyResourceManifest.isValidResourceIdentifier(preset.id))
            XCTAssertTrue(BeautyResourceManifest.isValidResourceIdentifier(preset.resourceName))
            XCTAssertTrue(forbiddenTokens.allSatisfy { !preset.id.contains($0) })
            XCTAssertTrue(forbiddenTokens.allSatisfy { !preset.resourceName.contains($0) })
        }
    }

    func testEFFECT03MissingPresetAndFilterReferencesFailWithTypedErrors() throws {
        let catalog = try BeautyResourceCatalog.bundled()

        XCTAssertThrowsError(try catalog.preset(id: "missing")) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing"))
        }

        let data = Data(
            #"""
            {
              "schemaVersion": 1,
              "id": "invalid_filter",
              "version": 1,
              "displayName": "Invalid Filter",
              "parameters": {
                "filterId": "missing_filter",
                "filterIntensity": 0.4
              }
            }
            """#.utf8
        )

        XCTAssertThrowsError(try BeautyPreset.decode(from: data, availableFilterIds: catalog.availableFilterIds)) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing_filter"))
        }
    }

    func testEFFECT03TraversalLikeResourceIdsAreRejected() throws {
        let catalog = try BeautyResourceCatalog.bundled()

        XCTAssertFalse(BeautyResourceManifest.isValidResourceIdentifier(".." + "/natural"))
        XCTAssertFalse(BeautyResourceManifest.isValidResourceIdentifier("Presets/natural"))
        XCTAssertFalse(BeautyResourceManifest.isValidResourceIdentifier("/private" + "/var/natural"))
        XCTAssertTrue(BeautyResourceManifest.isValidResourceIdentifier("id-photo-natural"))

        XCTAssertThrowsError(try catalog.preset(id: "/private" + "/var/natural")) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("invalid_preset"))
        }
    }
}

extension BeautyResourceCatalogTests {
    func testPhase53PresetInventoryRemainsExactlyFiveWithNeutralLocalRetouchKeys() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()
        XCTAssertEqual(presets.map(\.id), ["natural", "clear", "refined", "male-natural", "id-photo-natural"])
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            let object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(preset.parameters)) as? [String: Any])
            XCTAssertEqual(Mirror(reflecting: preset.parameters).children.count, 61)
            XCTAssertEqual(object.count, preset.parameters.filterId == nil ? 60 : 61)
            XCTAssertEqual(object["teethWhitening"] as? Double, 0)
            XCTAssertEqual(object["scleraRednessReduction"] as? Double, 0)
            for forbidden in ["upperEyelidFullnessReduction"] {
                XCTAssertNil(object[forbidden], "\(preset.id): \(forbidden)")
            }
        }
    }

    func testPhase53PresetSourceHashesRemainExact() throws {
        let expectedHashes = [
            "clear.json": "58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8",
            "id-photo-natural.json": "d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609",
            "male-natural.json": "1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08",
            "natural.json": "bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da",
            "refined.json": "67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722",
        ]
        let presetDirectory = repositoryRootURL()
            .appendingPathComponent("BeautySDK/Sources/BeautyResources/Resources/Presets")
        let actualNames = try FileManager.default.contentsOfDirectory(
            at: presetDirectory,
            includingPropertiesForKeys: nil
        )
            .filter { $0.pathExtension == "json" }
            .map(\.lastPathComponent)
            .sorted()

        XCTAssertEqual(actualNames, expectedHashes.keys.sorted())
        for fileName in actualNames {
            let data = try Data(contentsOf: presetDirectory.appendingPathComponent(fileName))
            let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            XCTAssertEqual(hash, expectedHashes[fileName], fileName)
        }
    }

    func testPhase59TeethPresetKeysRemainNeutralAndNoTeethResourceIsAdded() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()
        let expectedIDs = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        let candidateNames = [
            "teethWhite", "toothWhitening", "teethBrightness",
        ]

        XCTAssertEqual(presets.map(\.id), expectedIDs)
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            let object = try XCTUnwrap(
                JSONSerialization.jsonObject(with: JSONEncoder().encode(preset.parameters)) as? [String: Any]
            )
            XCTAssertEqual(Mirror(reflecting: preset.parameters).children.count, 61)
            XCTAssertEqual(object.count, preset.parameters.filterId == nil ? 60 : 61)
            XCTAssertEqual(object["teethWhitening"] as? Double, 0, "\(preset.id): teethWhitening")
            XCTAssertEqual(
                object["scleraRednessReduction"] as? Double,
                0,
                "\(preset.id): scleraRednessReduction"
            )
            for forbidden in candidateNames {
                XCTAssertNil(object[forbidden], "\(preset.id): \(forbidden)")
            }
        }

        let presetDirectory = repositoryRootURL()
            .appendingPathComponent("BeautySDK/Sources/BeautyResources/Resources/Presets")
        let fileNames = try FileManager.default.contentsOfDirectory(
            at: presetDirectory,
            includingPropertiesForKeys: nil
        )
            .filter { $0.pathExtension == "json" }
            .map(\.lastPathComponent)
            .sorted()
        XCTAssertEqual(fileNames, expectedIDs.map { "\($0).json" }.sorted())
    }

    func testPhase57ClosedEyeRetouchGatesAddNoPresetKeyOrResource() throws {
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()
        let expectedIDs = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        let candidateNames = [
            "scleraRedness", "scleraWhitening", "scleraWhite",
            "scleraBrightness", "whitenSclera", "eyeRedness", "eyeRednessReduction",
            "redEye", "redEyeReduction", "conjunctivaRedness", "conjunctivaRednessReduction",
            "conjunctivalRedness", "conjunctivalRednessReduction", "conjunctivaWhitening", "conjunctivalWhitening",
            "ocularRedness", "ocularRednessReduction", "ocularWhitening", "bloodshotReduction",
            "bloodshotEyeCorrection", "sclera_redness", "sclera_redness_reduction", "sclera_whitening",
            "sclera_white", "sclera_brightness", "whiten_sclera", "eye_redness",
            "eye_redness_reduction", "red_eye", "red_eye_reduction", "conjunctiva_redness",
            "conjunctiva_redness_reduction", "conjunctival_redness", "conjunctival_redness_reduction", "conjunctiva_whitening",
            "conjunctival_whitening", "ocular_redness", "ocular_redness_reduction", "ocular_whitening",
            "bloodshot_reduction", "bloodshot_eye_correction", "eyes.redness", "祛红血丝",
            "upperEyelidFullness", "upperLidFullness", "eyelidFullness", "lidFullness",
            "upperEyelidFullnessReduction", "upperLidFullnessReduction", "eyelidFullnessReduction", "lidFullnessReduction",
            "upperEyelidFullnessRemoval", "upperLidFullnessRemoval", "eyelidFullnessRemoval", "lidFullnessRemoval",
            "upperEyelidFat", "upperLidFat", "eyelidFat", "lidFat",
            "upperEyelidFatReduction", "upperLidFatReduction", "eyelidFatReduction", "lidFatReduction",
            "upperEyelidFatRemoval", "upperLidFatRemoval", "eyelidFatRemoval", "lidFatRemoval",
            "removeUpperEyelidFat", "removeEyelidFat", "removeUpperLidFat", "removeLidFat",
            "upperEyelidDefatting", "upperLidDefatting", "eyelidDefatting", "lidDefatting",
            "defatUpperEyelid", "defatEyelid", "defatUpperLid", "defatLid",
            "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fullness", "lid_fullness",
            "upper_eyelid_fullness_reduction", "upper_lid_fullness_reduction", "eyelid_fullness_reduction", "lid_fullness_reduction",
            "upper_eyelid_fullness_removal", "upper_lid_fullness_removal", "eyelid_fullness_removal", "lid_fullness_removal",
            "upper_eyelid_fat", "upper_lid_fat", "eyelid_fat", "lid_fat",
            "upper_eyelid_fat_reduction", "upper_lid_fat_reduction", "eyelid_fat_reduction", "lid_fat_reduction",
            "upper_eyelid_fat_removal", "upper_lid_fat_removal", "eyelid_fat_removal", "lid_fat_removal",
            "remove_upper_eyelid_fat", "remove_eyelid_fat", "remove_upper_lid_fat", "remove_lid_fat",
            "upper_eyelid_defatting", "upper_lid_defatting", "eyelid_defatting", "lid_defatting",
            "defat_upper_eyelid", "defat_eyelid", "defat_upper_lid", "defat_lid",
            "eyes.fat", "去脂",
        ]

        XCTAssertEqual(presets.map(\.id), expectedIDs)
        XCTAssertEqual(presets.count, 5)
        for preset in presets {
            let object = try XCTUnwrap(
                JSONSerialization.jsonObject(with: JSONEncoder().encode(preset.parameters)) as? [String: Any]
            )
            XCTAssertEqual(Mirror(reflecting: preset.parameters).children.count, 61)
            XCTAssertEqual(object.count, preset.parameters.filterId == nil ? 60 : 61)
            XCTAssertEqual(object["scleraRednessReduction"] as? Double, 0)
            for forbidden in candidateNames {
                XCTAssertNil(object[forbidden], "\(preset.id): \(forbidden)")
            }
        }

        let presetDirectory = repositoryRootURL()
            .appendingPathComponent("BeautySDK/Sources/BeautyResources/Resources/Presets")
        let fileNames = try FileManager.default.contentsOfDirectory(
            at: presetDirectory,
            includingPropertiesForKeys: nil
        )
            .filter { $0.pathExtension == "json" }
            .map(\.lastPathComponent)
            .sorted()
        XCTAssertEqual(fileNames, expectedIDs.map { "\($0).json" }.sorted())
    }

    func testPhase62IntentAdmissionKeepsExactFivePresetSourcesAndNeutralLocalRetouchKeys() throws {
        let expectedIDs = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        let candidates = [
            "upperEyelidFullnessReduction",
        ]
        let presets = try BeautyResourceCatalog.bundled().builtInPresets()
        XCTAssertEqual(presets.map(\.id), expectedIDs)
        XCTAssertEqual(presets.count, 5)

        for preset in presets {
            let object = try XCTUnwrap(
                JSONSerialization.jsonObject(with: JSONEncoder().encode(preset.parameters)) as? [String: Any]
            )
            XCTAssertEqual(Mirror(reflecting: preset.parameters).children.count, 61)
            XCTAssertEqual(object["teethWhitening"] as? Double, 0)
            XCTAssertEqual(object["scleraRednessReduction"] as? Double, 0)
            for candidate in candidates {
                XCTAssertNil(object[candidate], "\(preset.id): \(candidate)")
            }
        }

        let presetDirectory = repositoryRootURL()
            .appendingPathComponent("BeautySDK/Sources/BeautyResources/Resources/Presets")
        let fileNames = try FileManager.default.contentsOfDirectory(
            at: presetDirectory,
            includingPropertiesForKeys: nil
        )
            .filter { $0.pathExtension == "json" }
            .map(\.lastPathComponent)
            .sorted()
        XCTAssertEqual(fileNames, expectedIDs.map { "\($0).json" }.sorted())
    }

    private func repositoryRootURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
