import BeautySDK
import XCTest
@testable import BeautyEditor

@MainActor final class MouthControlContractTests: XCTestCase {
    private let expected: [(String, String, Float)] = [
        ("mouth.size", "mouthSize", -0.35), ("mouth.width", "mouthWidth", 0.35),
        ("mouth.positionY", "mouthYPosition", -0.25), ("mouth.tilt", "mouthTilt", 0.25),
        ("mouth.positionX", "mouthXPosition", 0.25), ("mouth.mShape", "lipPeakDefinition", 0.25),
        ("mouth.fullness", "lipPlump", 0.25), ("mouth.smile", "smile", 0.50),
        ("mouth.teethWhitening", "teethWhitening", 1)
    ]

    func testMouthCatalogUsesEightCenteredControlsAndOneWhiteningControl() throws {
        let tools = ToolCatalog.tools(in: .mouth)
        XCTAssertEqual(tools.map(\.id), expected.map { $0.0 })
        for (id, field, _) in expected {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            XCTAssertEqual(tool.field, field)
            XCTAssertNotNil(tool.mouthSlider, id)
            XCTAssertEqual(tool.range, id == "mouth.teethWhitening" ? .unit : .signed, id)
            XCTAssertEqual(tool.value(in: BeautyParameters()), 0, id)
            XCTAssertEqual(tool.range.bounds.lowerBound, id == "mouth.teethWhitening" ? 0 : -100, id)
        }
    }

    func testMouthDirectionsRoundTripWithoutChangingOtherTools() throws {
        let original = BeautyParameters(skinSmoothing: 0.2, noseWingSlim: -0.1)
        for (id, _, right) in expected {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            let values: [Float] = tool.range == .signed
                ? [-100, -75, -50, -25, 0, 25, 50, 75, 100] : [0, 25, 50, 75, 100]
            for value in values {
                var parameters = original
                tool.setValue(value, in: &parameters)
                XCTAssertEqual(tool.sdkValue(in: parameters), value / 100 * right, accuracy: 0.000001, id)
                XCTAssertEqual(tool.value(in: parameters), value, accuracy: 0.0001, id)
                let decoded = try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(parameters))
                XCTAssertEqual(tool.value(in: decoded), value, accuracy: 0.0001, id)
                for other in ToolCatalog.canonicalTools where other.field != tool.field {
                    XCTAssertEqual(other.sdkValue(in: parameters), other.sdkValue(in: original), other.id)
                }
                XCTAssertEqual(parameters.skinSmoothing, original.skinSmoothing)
            }
            var invalid = original
            tool.setValue(.nan, in: &invalid)
            XCTAssertEqual(tool.value(in: invalid), 0, id)
        }
    }

    func testSizeDirectionAndHistoryRestoreTheVisibleSignedValue() throws {
        let size = try XCTUnwrap(ToolCatalog.find("mouth.size"))
        let tilt = try XCTUnwrap(ToolCatalog.find("mouth.tilt"))
        var history = EditHistory()
        let neutral = EditorSnapshot()
        var smallerClockwise = neutral
        size.setValue(100, in: &smallerClockwise.parameters)
        tilt.setValue(50, in: &smallerClockwise.parameters)
        XCTAssertEqual(smallerClockwise.parameters.mouthSize, -0.35)
        XCTAssertEqual(smallerClockwise.parameters.mouthTilt, 0.125)
        history.record(neutral, replacing: smallerClockwise)
        let undone = try XCTUnwrap(history.undo(smallerClockwise))
        XCTAssertEqual(size.value(in: undone.parameters), 0)
        let redone = try XCTUnwrap(history.redo(undone))
        XCTAssertEqual(size.value(in: redone.parameters), 100)
        XCTAssertEqual(tilt.value(in: redone.parameters), 50)
        XCTAssertEqual(size.value(in: BeautyParameters(mouthSize: 0.35)), -100)
    }
}
