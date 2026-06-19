import XCTest
import BeautySDK

// Requirement evidence: SDK-01, SDK-02.
final class BeautySDKFacadeTests: XCTestCase {
    func testFacadeProductCanBeImported() {
        XCTAssertEqual(BeautySDKModule.name, "BeautySDK")
    }

    func testSDK02FacadeExposesFoundationTypesThroughBeautySDKOnly() throws {
        let configuration = BeautyConfiguration.default
        XCTAssertEqual(configuration.logLevel, .error)

        let parameters = BeautyParameters(skinSmoothing: 0.25)
        XCTAssertEqual(parameters.skinSmoothing, 0.25)

        let preset = BeautyPreset(
            id: "natural.test",
            version: 1,
            displayName: "Natural Test",
            parameters: .init()
        )
        XCTAssertEqual(preset.parameters, BeautyParameters())

        let result = BeautyResult(output: "ok")
        XCTAssertEqual(result.output, "ok")
        XCTAssertNil(result.detectionSummary)

        let metadata = BeautyInputMetadata(
            orientation: .right,
            isInputMirrored: false,
            isPreviewMirrored: true,
            source: .camera,
            timestamp: 1
        )
        XCTAssertEqual(metadata.source, .camera)

        let detectionSummary = BeautyDetectionSummary.noFace
        XCTAssertEqual(detectionSummary.availability, .noFace)

        let error = BeautyError.invalidInput
        XCTAssertEqual(error.code, "invalid_input")

        let engine = try BeautyEngine(configuration: .default)
        XCTAssertEqual(engine.configuration, configuration)
    }

    func testEFFECT03FacadeExposesBuiltInFiltersThroughBeautySDKOnly() throws {
        XCTAssertEqual(
            try BeautySDKResources.availableFilters().map(\.id),
            ["soft_clean", "warm_light"]
        )
    }

    func testEFFECT08FacadeExposesBuiltInPresetsThroughBeautySDKOnly() throws {
        XCTAssertEqual(
            try BeautySDKResources.builtInPresets().map(\.displayName),
            ["Natural", "Clear", "Refined", "Male Natural", "ID Photo Natural"]
        )

        let preset = try BeautySDKResources.preset(id: "clear")
        XCTAssertEqual(preset.displayName, "Clear")
        XCTAssertEqual(preset.parameters.filterId, "warm_light")
    }

    func testEFFECT03FacadeValidatesFilterReferences() throws {
        let noFilter = try BeautySDKResources.validate(parameters: BeautyParameters(filterId: nil, filterIntensity: 0))
        XCTAssertNil(noFilter.filterId)
        XCTAssertEqual(noFilter.filterIntensity, 0)

        let knownFilter = try BeautySDKResources.validate(
            parameters: BeautyParameters(filterId: "soft_clean", filterIntensity: 0.35)
        )
        XCTAssertEqual(knownFilter.filterId, "soft_clean")
        XCTAssertEqual(knownFilter.filterIntensity, 0.35, accuracy: 0.0001)

        XCTAssertThrowsError(
            try BeautySDKResources.validate(parameters: BeautyParameters(filterId: "missing_filter"))
        ) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing_filter"))
        }
    }
}
