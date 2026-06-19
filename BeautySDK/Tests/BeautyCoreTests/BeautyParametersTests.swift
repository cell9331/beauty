import XCTest
import BeautySDK

// Requirement evidence: SDK-03, SDK-05.
final class BeautyParametersTests: XCTestCase {
    func testSDK03DefaultsAreZeroEffectAndExpose31StoredFields() {
        let parameters = BeautyParameters()

        XCTAssertEqual(Mirror(reflecting: parameters).children.count, 31)
        XCTAssertEqual(parameters.skinSmoothing, 0)
        XCTAssertEqual(parameters.skinWhitening, 0)
        XCTAssertEqual(parameters.skinRosy, 0)
        XCTAssertEqual(parameters.skinSharpen, 0)
        XCTAssertEqual(parameters.brightness, 0)
        XCTAssertEqual(parameters.contrast, 0)
        XCTAssertEqual(parameters.saturation, 0)
        XCTAssertEqual(parameters.temperature, 0)
        XCTAssertEqual(parameters.tint, 0)
        XCTAssertEqual(parameters.exposure, 0)
        XCTAssertEqual(parameters.highlight, 0)
        XCTAssertEqual(parameters.shadow, 0)
        XCTAssertEqual(parameters.faceSlim, 0)
        XCTAssertEqual(parameters.faceSmall, 0)
        XCTAssertEqual(parameters.faceVShape, 0)
        XCTAssertEqual(parameters.jawSlim, 0)
        XCTAssertEqual(parameters.chinLength, 0)
        XCTAssertEqual(parameters.eyeSize, 0)
        XCTAssertEqual(parameters.eyeDistance, 0)
        XCTAssertEqual(parameters.eyeYPosition, 0)
        XCTAssertEqual(parameters.eyeTailLift, 0)
        XCTAssertEqual(parameters.noseSlim, 0)
        XCTAssertEqual(parameters.noseWingSlim, 0)
        XCTAssertEqual(parameters.noseTipSize, 0)
        XCTAssertEqual(parameters.noseBridge, 0)
        XCTAssertEqual(parameters.mouthSize, 0)
        XCTAssertEqual(parameters.mouthWidth, 0)
        XCTAssertEqual(parameters.smile, 0)
        XCTAssertEqual(parameters.lipColor, 0)
        XCTAssertNil(parameters.filterId)
        XCTAssertEqual(parameters.filterIntensity, 0)
    }

    func testSDK05NormalizationClampsRangesAndZerosNonFiniteValues() {
        let parameters = BeautyParameters(
            skinSmoothing: 2,
            brightness: -2,
            contrast: 2,
            saturation: -2,
            temperature: 2,
            tint: -2,
            exposure: 2,
            highlight: -2,
            shadow: 2,
            chinLength: -2,
            eyeSize: .nan,
            noseTipSize: .infinity,
            mouthSize: -.infinity,
            filterIntensity: 4
        )

        XCTAssertEqual(parameters.skinSmoothing, 1)
        XCTAssertEqual(parameters.brightness, -1)
        XCTAssertEqual(parameters.contrast, 1)
        XCTAssertEqual(parameters.saturation, -1)
        XCTAssertEqual(parameters.temperature, 1)
        XCTAssertEqual(parameters.tint, -1)
        XCTAssertEqual(parameters.exposure, 1)
        XCTAssertEqual(parameters.highlight, -1)
        XCTAssertEqual(parameters.shadow, 1)
        XCTAssertEqual(parameters.chinLength, -1)
        XCTAssertEqual(parameters.eyeSize, 0)
        XCTAssertEqual(parameters.noseTipSize, 0)
        XCTAssertEqual(parameters.mouthSize, 0)
        XCTAssertEqual(parameters.filterIntensity, 1)
    }

    func testSDK03CodableRoundTripAndMissingFieldsUseDefaults() throws {
        let parameters = BeautyParameters(
            skinSmoothing: 0.2,
            contrast: -0.4,
            filterId: "clean_01",
            filterIntensity: 0.3
        )

        let data = try JSONEncoder().encode(parameters)
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)
        XCTAssertEqual(decoded, parameters)

        let partial = Data(#"{"skinSmoothing":0.4}"#.utf8)
        let partialDecoded = try JSONDecoder().decode(BeautyParameters.self, from: partial)
        XCTAssertEqual(partialDecoded.skinSmoothing, 0.4)
        XCTAssertEqual(partialDecoded.eyeSize, 0)
        XCTAssertNil(partialDecoded.filterId)
    }

    func testEFFECT02ColorAndFilterFieldsRoundTripThroughCodable() throws {
        let parameters = BeautyParameters(
            brightness: -0.25,
            contrast: 0.15,
            saturation: 0.2,
            temperature: -0.1,
            tint: 0.05,
            exposure: 0.4,
            highlight: -0.3,
            shadow: 0.35,
            filterId: "soft_clean",
            filterIntensity: 0.35
        )

        let data = try JSONEncoder().encode(parameters)
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(decoded.brightness, -0.25)
        XCTAssertEqual(decoded.contrast, 0.15)
        XCTAssertEqual(decoded.saturation, 0.2)
        XCTAssertEqual(decoded.temperature, -0.1)
        XCTAssertEqual(decoded.tint, 0.05)
        XCTAssertEqual(decoded.exposure, 0.4)
        XCTAssertEqual(decoded.highlight, -0.3)
        XCTAssertEqual(decoded.shadow, 0.35)
        XCTAssertEqual(decoded.filterId, "soft_clean")
        XCTAssertEqual(decoded.filterIntensity, 0.35)
    }

    func testEFFECT03FilterDefaultsRepresentNoFilterState() {
        let parameters = BeautyParameters()

        XCTAssertNil(parameters.filterId)
        XCTAssertEqual(parameters.filterIntensity, 0)
    }

    func testBeautyParametersIsSendable() {
        assertSendable(BeautyParameters())
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
