import BeautySDK
import XCTest
@testable import BeautyDemo

final class ParameterJSONCodingTests: XCTestCase {
    func testExportUsesOnlySchemaAndParametersTopLevelKeys() throws {
        let json = try ParameterJSONCoding.export(
            parameters: BeautyParameters(skinSmoothing: 0.25, brightness: -0.4)
        )
        let object = try normalizedJSONObject(from: json)

        XCTAssertEqual(Set(object.keys), ["parameters", "schemaVersion"])
        XCTAssertEqual(object["schemaVersion"] as? Int, 1)
    }

    func testExportIsDeterministicForSameParameterSnapshot() throws {
        let parameters = BeautyParameters(
            skinSmoothing: 0.42,
            brightness: -0.2,
            filterId: "soft_clean",
            filterIntensity: 0.35
        )

        let first = try ParameterJSONCoding.export(parameters: parameters)
        let second = try ParameterJSONCoding.export(parameters: parameters)

        XCTAssertEqual(first, second)
    }

    func testExportPreviewImportRoundTripsThroughFacadeValidation() throws {
        let parameters = BeautyParameters(
            skinSmoothing: 0.42,
            brightness: -0.2,
            filterId: "soft_clean",
            filterIntensity: 0.35
        )
        let exported = try ParameterJSONCoding.export(parameters: parameters)
        let preview = ParameterJSONCoding.previewImport(exported)
        let validated = try BeautySDKResources.validate(parameters: parameters)

        XCTAssertEqual(preview, .preview(validated))
    }

    func testOversizedPayloadFailsBeforeDecodeWithStableCopy() {
        let oversizedPayload = String(repeating: " ", count: ParameterJSONCoding.maxPayloadBytes + 1)

        XCTAssertEqual(
            ParameterJSONCoding.previewImport(oversizedPayload),
            .failed(.oversized)
        )
        XCTAssertEqual(
            ParameterJSONImportError.oversized.message,
            "Parameter JSON is too large. Paste a smaller parameter payload."
        )
    }

    func testUnsupportedSchemaFailsWithStableCopy() {
        let json = #"{"schemaVersion":2,"parameters":{}}"#

        XCTAssertEqual(
            ParameterJSONCoding.previewImport(json),
            .failed(.unsupportedSchema)
        )
        XCTAssertEqual(
            ParameterJSONImportError.unsupportedSchema.message,
            "Unsupported parameter JSON version. Export a fresh payload from this build and try again."
        )
    }

    func testMalformedJSONFailsWithoutRawJSONEcho() {
        let rawJSON = #"{"schemaVersion":"#
        let result = ParameterJSONCoding.previewImport(rawJSON)

        XCTAssertEqual(result, .failed(.invalidJSON))
        XCTAssertEqual(
            ParameterJSONImportError.invalidJSON.message,
            "Parameter JSON could not be read. Fix the pasted payload and preview again. Current settings stay unchanged."
        )
        XCTAssertFalse(ParameterJSONImportError.invalidJSON.message.contains(rawJSON))
    }

    func testUnknownFilterFailsBeforePreviewOrApply() throws {
        let json = try ParameterJSONCoding.export(
            parameters: BeautyParameters(filterId: "missing_filter", filterIntensity: 0.4)
        )

        XCTAssertEqual(
            ParameterJSONCoding.previewImport(json),
            .failed(.unknownFilter)
        )
        XCTAssertEqual(
            ParameterJSONImportError.unknownFilter.message,
            "Filter is unavailable in this build. Current settings stay unchanged."
        )
        XCTAssertFalse(ParameterJSONImportError.unknownFilter.message.contains("/"))
        XCTAssertFalse(ParameterJSONImportError.unknownFilter.message.contains("http"))
    }

    func testErrorValuesDoNotRetainRawPayloadText() {
        let payload = #"{"schemaVersion":1,"parameters":{"filterId":"missing_filter"}}"#
        _ = ParameterJSONCoding.previewImport(payload)

        XCTAssertFalse(ParameterJSONImportError.unknownFilter.message.contains(payload))
        XCTAssertFalse(ParameterJSONImportError.invalidJSON.message.contains(payload))
    }

    private func normalizedJSONObject(from json: String) throws -> [String: Any] {
        let data = try XCTUnwrap(json.data(using: .utf8))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
