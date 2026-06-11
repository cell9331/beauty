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

        let error = BeautyError.invalidInput
        XCTAssertEqual(error.code, "invalid_input")

        let engine = try BeautyEngine(configuration: .default)
        XCTAssertEqual(engine.configuration, configuration)
    }
}
