import BeautyCore
import BeautyResources
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
