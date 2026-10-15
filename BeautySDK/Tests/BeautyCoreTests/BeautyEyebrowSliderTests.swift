import XCTest
import BeautySDK

final class BeautyEyebrowSliderTests: XCTestCase {
    private let controls: [(BeautyEyebrowSlider, WritableKeyPath<BeautyParameters, Float>)] = [
        (.verticalPosition, \.eyebrowYPosition), (.thickness, \.eyebrowThickness),
        (.length, \.eyebrowLength), (.spacing, \.eyebrowSpacing),
        (.headSpacing, \.eyebrowHeadSpacing), (.tilt, \.eyebrowTilt),
        (.peak, \.eyebrowPeakDefinition)
    ]

    func testAllSevenControlsReachSignedCapsRoundTripAndPreserveSiblings() throws {
        XCTAssertEqual(Set(controls.map { $0.0 }), Set(BeautyEyebrowSlider.allCases))
        XCTAssertEqual(BeautyEyebrowSlider.allCases.count, 7)
        let original = BeautyParameters(
            skinSmoothing: 0.21, eyebrowYPosition: -0.03, eyebrowThickness: 0.06,
            eyebrowLength: -0.09, eyebrowSpacing: 0.12, eyebrowHeadSpacing: -0.15,
            eyebrowTilt: 0.18, eyebrowPeakDefinition: -0.21, noseWingSlim: -0.12
        )
        for (slider, field) in controls {
            let polarity: Float = slider == .verticalPosition || slider == .tilt ? -1 : 1
            XCTAssertEqual(slider.neutralPosition, 0.5)
            XCTAssertEqual(slider.position(in: BeautyParameters()), 0.5)
            for position: Float in [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1] {
                let result = slider.applying(position: position, to: original)
                XCTAssertEqual(result[keyPath: field], (2 * position - 1) * 0.25 * polarity,
                               accuracy: 0.000001, slider.rawValue)
                XCTAssertEqual(slider.position(in: result), position,
                               accuracy: 0.000001, slider.rawValue)
                let decoded = try JSONDecoder().decode(BeautyParameters.self,
                                                       from: JSONEncoder().encode(result))
                XCTAssertEqual(decoded, result)
                var restored = result
                restored[keyPath: field] = original[keyPath: field]
                XCTAssertEqual(restored, original, "Only the selected eyebrow field changes: \(slider)")
            }
            XCTAssertEqual(try JSONDecoder().decode(BeautyEyebrowSlider.self,
                                                    from: JSONEncoder().encode(slider)), slider)
        }
    }

    func testNeutralNonfiniteAndOutOfBoundsPositionsArePredictable() {
        for (slider, field) in controls {
            let active = slider.applying(position: 1, to: BeautyParameters())
            for position: Float in [slider.neutralPosition, .nan, .infinity, -.infinity] {
                XCTAssertEqual(slider.applying(position: position, to: active)[keyPath: field], 0,
                               slider.rawValue)
            }
            XCTAssertEqual(slider.applying(position: -2, to: active),
                           slider.applying(position: 0, to: active))
            XCTAssertEqual(slider.applying(position: 2, to: active),
                           slider.applying(position: 1, to: active))
        }
    }

    func testInverseMappingClampsDisplayWithoutMutatingDirectValues() {
        for (slider, field) in controls {
            for directValue: Float in [-1, -0.25, 0, 0.25, 1] {
                var direct = BeautyParameters()
                direct[keyPath: field] = directValue
                let polarity: Float = slider == .verticalPosition || slider == .tilt ? -1 : 1
                let expected = (min(1, max(-1, directValue / (0.25 * polarity))) + 1) * 0.5
                XCTAssertEqual(slider.position(in: direct), expected, slider.rawValue)
                XCTAssertEqual(direct[keyPath: field], directValue,
                               "Reading the slider does not change the direct value")
            }
            for nonfinite: Float in [.nan, .infinity, -.infinity] {
                var direct = BeautyParameters()
                direct[keyPath: field] = nonfinite
                XCTAssertEqual(slider.position(in: direct), slider.neutralPosition, slider.rawValue)
                XCTAssertFalse(direct[keyPath: field].isFinite)
            }
        }
    }
}
