import BeautySDK
import CoreVideo
import XCTest
@testable import BeautyDemo

final class CompareStateTests: XCTestCase {
    func testD10CompareLabelsToggleBetweenBeforeAndAfter() {
        var state = CompareState()

        XCTAssertEqual(state.display, .after)
        XCTAssertEqual(state.actionTitle, "Show Before")
        XCTAssertEqual(state.accessibilityValue, "Showing after")

        state.toggle()

        XCTAssertEqual(state.display, .before)
        XCTAssertEqual(state.actionTitle, "Show After")
        XCTAssertEqual(state.accessibilityValue, "Showing before")
    }

    func testD10PhotoCompareSelectsInputOrOutputOnly() throws {
        let snapshot = try makeImageSnapshot()
        var state = CompareState(display: .after)

        XCTAssertTrue(state.photoImage(from: snapshot) === snapshot.outputCGImage)

        state.toggle()

        XCTAssertTrue(state.photoImage(from: snapshot) === snapshot.inputCGImage)
    }

    func testD10CameraCompareSelectsInputOrOutputOnly() throws {
        let input = try makePixelBuffer()
        let output = try makePixelBuffer()
        let snapshot = CameraProcessingSnapshot(
            inputPixelBuffer: input,
            outputPixelBuffer: output,
            orientation: .right,
            timestamp: 4,
            parameters: .init(skinSmoothing: 0.4),
            extent: CGSize(width: 2, height: 2)
        )
        var state = CompareState(display: .after)

        XCTAssertTrue(state.cameraPixelBuffer(from: snapshot) === output)

        state.toggle()

        XCTAssertTrue(state.cameraPixelBuffer(from: snapshot) === input)
    }

    func testD10CompareTogglePreservesEditorSelectionAndParameters() {
        var state = CompareState()
        let parameters = BeautyParameters(skinSmoothing: 0.6, eyeSize: 0.2)

        let snapshot = CompareState.preservingEditorState(
            mode: .photo,
            category: .facialFeatures,
            subcategory: .nose,
            parameters: parameters,
            toggle: &state
        )

        XCTAssertEqual(state.display, .before)
        XCTAssertEqual(snapshot.mode, .photo)
        XCTAssertEqual(snapshot.category, .facialFeatures)
        XCTAssertEqual(snapshot.subcategory, .nose)
        XCTAssertEqual(snapshot.parameters, parameters)
    }

    private func makeImageSnapshot() throws -> ImageProcessingSnapshot {
        let renderer = ImageDisplayRenderer()
        let input = DemoFixtures.photoFixtureImage()
        let output = DemoFixtures.photoFixtureImage()
            .cropped(to: CGRect(x: 0, y: 0, width: 3, height: 3))

        return ImageProcessingSnapshot(
            sourceKind: .fixture,
            sourceID: "compare",
            inputImage: input,
            outputImage: output,
            inputCGImage: try renderer.render(input),
            outputCGImage: try renderer.render(output),
            orientation: .up,
            parameters: .init(skinSmoothing: 0.2)
        )
    }

    private func makePixelBuffer() throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: 2,
            kCVPixelBufferHeightKey as String: 2,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            2,
            2,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }
}
