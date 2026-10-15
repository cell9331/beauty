import XCTest
import BeautySDK

final class BeautyMouthSliderTests: XCTestCase {
    private let controls: [(BeautyMouthSlider, WritableKeyPath<BeautyParameters, Float>, Float)] = [
        (.size, \.mouthSize, -0.35), (.width, \.mouthWidth, 0.35),
        (.verticalPosition, \.mouthYPosition, -0.25), (.tilt, \.mouthTilt, 0.25),
        (.horizontalPosition, \.mouthXPosition, 0.25), (.mShape, \.lipPeakDefinition, 0.25),
        (.fullness, \.lipPlump, 0.25), (.smile, \.smile, 0.50),
        (.teethWhitening, \.teethWhitening, 1)
    ]

    func testAllControlsReachBothReferenceEndpointsAndRoundTripQuarterSteps() throws {
        XCTAssertEqual(Set(controls.map { $0.0 }), Set(BeautyMouthSlider.allCases))
        let original = BeautyParameters(skinSmoothing: 0.21, noseWingSlim: -0.12)
        for (slider, field, right) in controls {
            let neutral = slider == .teethWhitening ? Float(0) : 0.5
            XCTAssertEqual(slider.neutralPosition, neutral)
            XCTAssertEqual(slider.position(in: original), neutral)
            for position: Float in [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1] {
                let result = slider.applying(position: position, to: original)
                let amount = slider == .teethWhitening ? position : 2 * position - 1
                XCTAssertEqual(result[keyPath: field], amount * right, accuracy: 0.000001, slider.rawValue)
                XCTAssertEqual(slider.position(in: result), position, accuracy: 0.000001, slider.rawValue)
                let decoded = try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(result))
                XCTAssertEqual(decoded[keyPath: field], result[keyPath: field], slider.rawValue)
                var restored = result
                restored[keyPath: field] = original[keyPath: field]
                XCTAssertEqual(restored, original, "Only the selected mouth field changes: \(slider)")
            }
        }
    }

    func testNeutralNonfiniteAndOutOfBoundsPositionsArePredictable() {
        for (slider, field, _) in controls {
            let active = slider.applying(position: 1, to: BeautyParameters())
            for position: Float in [slider.neutralPosition, .nan, .infinity, -.infinity] {
                XCTAssertEqual(slider.applying(position: position, to: active)[keyPath: field], 0, slider.rawValue)
            }
            XCTAssertEqual(slider.applying(position: -2, to: active), slider.applying(position: 0, to: active))
            XCTAssertEqual(slider.applying(position: 2, to: active), slider.applying(position: 1, to: active))
        }
    }

    func testInverseMappingPreservesDirectSizeMeaningAndClampsDisplayOnly() {
        var direct = BeautyParameters(mouthSize: 0.8, mouthYPosition: 0.5, mouthTilt: 0.5, mouthXPosition: -0.5)
        XCTAssertEqual(BeautyMouthSlider.size.position(in: direct), 0)
        XCTAssertEqual(BeautyMouthSlider.verticalPosition.position(in: direct), 0)
        XCTAssertEqual(BeautyMouthSlider.tilt.position(in: direct), 1)
        XCTAssertEqual(BeautyMouthSlider.horizontalPosition.position(in: direct), 0)
        XCTAssertEqual(direct.mouthSize, 0.8)
        direct.mouthSize = .nan
        XCTAssertEqual(BeautyMouthSlider.size.position(in: direct), 0.5)
        direct.teethWhitening = -.infinity
        XCTAssertEqual(BeautyMouthSlider.teethWhitening.position(in: direct), 0)
    }
}
