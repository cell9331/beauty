import Foundation
import XCTest
import BeautySDK

// Requirement evidence: SDK-05, SDK-06, SDK-07.
final class BeautyPresetTests: XCTestCase {
    func testSDK05DecodingIgnoresUnknownJSONFields() throws {
        let data = Data(
            #"""
            {
              "id": "natural_01",
              "version": 1,
              "displayName": "Natural",
              "futureField": "ignored",
              "parameters": {
                "skinSmoothing": 0.22,
                "unknownParameter": 1
              }
            }
            """#.utf8
        )

        let preset = try BeautyPreset.decode(from: data)
        XCTAssertEqual(preset.id, "natural_01")
        XCTAssertEqual(preset.parameters.skinSmoothing, 0.22, accuracy: 0.0001)
    }

    func testSDK05UnknownFilterResourceReturnsTypedError() {
        let data = Data(
            #"""
            {
              "id": "natural_01",
              "version": 1,
              "displayName": "Natural",
              "parameters": {
                "filterId": "missing_filter",
                "filterIntensity": 0.5
              }
            }
            """#.utf8
        )

        XCTAssertThrowsError(try BeautyPreset.decode(from: data)) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing_filter"))
        }
    }

    func testSDK05InvalidFilterResourceReturnsRedactedTypedError() {
        let data = Data(
            #"""
            {
              "id": "natural_01",
              "version": 1,
              "displayName": "Natural",
              "parameters": {
                "filterId": "/private/var/filter",
                "filterIntensity": 0.5
              }
            }
            """#.utf8
        )

        XCTAssertThrowsError(try BeautyPreset.decode(from: data)) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("invalid_filter"))
        }
    }

    func testEFFECT08SchemaVersionOnePresetDecodes() throws {
        let data = Data(
            #"""
            {
              "schemaVersion": 1,
              "id": "natural",
              "version": 2,
              "displayName": "Natural",
              "parameters": {
                "skinSmoothing": 0.18,
                "filterId": "soft_clean",
                "filterIntensity": 0.25
              }
            }
            """#.utf8
        )

        let preset = try BeautyPreset.decode(from: data, availableFilterIds: ["soft_clean"])

        XCTAssertEqual(preset.id, "natural")
        XCTAssertEqual(preset.version, 2)
        XCTAssertEqual(preset.displayName, "Natural")
        XCTAssertEqual(preset.parameters.skinSmoothing, 0.18, accuracy: 0.0001)
        XCTAssertEqual(preset.parameters.filterId, "soft_clean")
        XCTAssertEqual(preset.parameters.filterIntensity, 0.25, accuracy: 0.0001)
        XCTAssertEqual(preset.parameters.teethWhitening, 0, accuracy: 0.0001)
    }

    func testPhase59LegacyPresetWithoutTeethKeyRemainsNeutral() throws {
        let data = Data(
            #"""
            {
              "schemaVersion": 1,
              "id": "legacy-neutral",
              "version": 1,
              "displayName": "Legacy Neutral",
              "parameters": {
                "skinWhitening": 0.2,
                "lipColor": 0.3
              }
            }
            """#.utf8
        )

        let preset = try BeautyPreset.decode(from: data)

        XCTAssertEqual(preset.parameters.skinWhitening, 0.2, accuracy: 0.0001)
        XCTAssertEqual(preset.parameters.lipColor, 0.3, accuracy: 0.0001)
        XCTAssertEqual(preset.parameters.teethWhitening, 0, accuracy: 0.0001)
    }

    func testEFFECT08UnsupportedSchemaVersionReturnsTypedError() {
        let data = Data(
            #"""
            {
              "schemaVersion": 2,
              "id": "natural",
              "version": 1,
              "displayName": "Natural",
              "parameters": {}
            }
            """#.utf8
        )

        XCTAssertThrowsError(try BeautyPreset.decode(from: data)) { error in
            XCTAssertEqual(error as? BeautyError, .presetDecodeFailed("unsupported_schema"))
        }
    }

    func testSDK06InvalidPresetSchemaReturnsRedactedTypedError() {
        let data = Data(
            #"""
            {
              "id": "../private/path",
              "version": 1,
              "displayName": "Natural",
              "parameters": {}
            }
            """#.utf8
        )

        XCTAssertThrowsError(try BeautyPreset.decode(from: data)) { error in
            guard case .presetDecodeFailed(let reason) = error as? BeautyError else {
                return XCTFail("Expected presetDecodeFailed")
            }
            XCTAssertFalse(reason.contains("/private"))
        }
    }

    func testEFFECT08Phase5ExposesBuiltInPresetResourceContracts() throws {
        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources")

        let files = try FileManager.default.subpathsOfDirectory(atPath: sourceRoot.path)
            .filter { $0.hasSuffix(".swift") }

        let combined = try files
            .map { try String(contentsOf: sourceRoot.appendingPathComponent($0), encoding: .utf8) }
            .joined(separator: "\n")

        XCTAssertTrue(combined.contains("builtInPresets"))
        XCTAssertTrue(combined.contains("BeautyResourceCatalog"))
    }
}
