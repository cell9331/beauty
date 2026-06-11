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
            chinLength: -2,
            eyeSize: .nan,
            noseTipSize: .infinity,
            mouthSize: -.infinity,
            filterIntensity: 4
        )

        XCTAssertEqual(parameters.skinSmoothing, 1)
        XCTAssertEqual(parameters.brightness, -1)
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

    func testBeautyParametersIsSendable() {
        assertSendable(BeautyParameters())
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
