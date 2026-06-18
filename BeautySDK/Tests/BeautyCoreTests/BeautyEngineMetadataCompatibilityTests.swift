import CoreImage
import CoreVideo
import ImageIO
import XCTest
import BeautySDK

final class BeautyEngineMetadataCompatibilityTests: XCTestCase {
    func testPIPE05OldAndNewPixelBufferAPIsProduceEquivalentOutput() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 2, height: 2, bytes: [
            1, 2, 3, 255,
            4, 5, 6, 255,
            7, 8, 9, 255,
            10, 11, 12, 255
        ])
        let engine = try BeautyEngine(configuration: .default)
        let metadata = BeautyInputMetadata(
            orientation: .up,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .camera
        )

        let oldOutput = try engine.process(pixelBuffer: input, orientation: .up, parameters: .init())
        let newResult = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: .init())

        XCTAssertEqual(try PixelBufferFixtures.bytes(from: oldOutput), try PixelBufferFixtures.bytes(from: newResult.output))
        XCTAssertEqual(newResult.detectionSummary, .notRun)
    }

    func testPIPE05OldAndNewImageAPIsProduceEquivalentOutput() throws {
        let image = CIImage(color: CIColor(red: 0.5, green: 0.25, blue: 0.75, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        let engine = try BeautyEngine(configuration: .default)
        let metadata = BeautyInputMetadata(
            orientation: .up,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .photo
        )

        let oldOutput = try engine.process(image: image, orientation: .up, parameters: .init())
        let newResult = try engine.processResult(image: image, metadata: metadata, parameters: .init())

        XCTAssertEqual(oldOutput.extent, newResult.output.extent)
        XCTAssertEqual(try PixelBufferFixtures.rgbaBytes(from: oldOutput), try PixelBufferFixtures.rgbaBytes(from: newResult.output))
        XCTAssertEqual(newResult.detectionSummary, .notRun)
    }

    func testPIPE07DisabledFaceTrackingReportsStructuredDisabledSummary() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 1, height: 1, bytes: [
            1, 2, 3, 255
        ])
        let engine = try BeautyEngine(configuration: BeautyConfiguration(enableFaceTracking: false))
        let metadata = BeautyInputMetadata(orientation: .up, source: .camera)

        let result = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: .init())

        XCTAssertEqual(result.detectionSummary?.availability, .disabled)
        XCTAssertEqual(result.detectionSummary?.reasons, [])
    }

    func testPIPE07ImageResultReportsNotRunBeforeDetectorIntegration() throws {
        let image = CIImage(color: .white)
            .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        let engine = try BeautyEngine(configuration: .default)
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)

        let result = try engine.processResult(image: image, metadata: metadata, parameters: .init())

        XCTAssertEqual(result.detectionSummary?.availability, .notRun)
        XCTAssertEqual(result.detectionSummary?.reasons, [])
    }
}
