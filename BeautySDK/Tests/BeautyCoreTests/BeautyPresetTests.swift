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

    func testD13Phase1DoesNotExposeBuiltInPresetRegistry() throws {
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

        XCTAssertFalse(combined.contains("builtInPresets"))
        XCTAssertFalse(combined.contains("loadBuiltInPresets"))
    }
}
