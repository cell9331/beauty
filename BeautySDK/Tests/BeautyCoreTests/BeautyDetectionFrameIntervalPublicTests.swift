import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyDetectionFrameIntervalPublicTests: XCTestCase {
    private let image: CIImage = {
        let bytes = (0..<(96 * 96)).flatMap { index -> [UInt8] in
            let x = index % 96
            let y = index / 96
            return [UInt8((x * 3 + y * 5) % 256),
                    UInt8((x * 7 + y * 2) % 256),
                    UInt8((x * 2 + y * 11) % 256), 255]
        }
        return CIImage(
            bitmapData: Data(bytes), bytesPerRow: 96 * 4,
            size: CGSize(width: 96, height: 96), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }()
    private let metadata = BeautyInputMetadata(
        orientation: .left, isInputMirrored: true, source: .video
    )

    func testExplicitFrameIndexSchedulesDetectionAndFailsClosedBetweenFrames() throws {
        let provider = SDKTestingFaceDetectionProvider([.usableFace])
        let engine = try BeautyEngine(
            configuration: .init(detectionFrameInterval: 3),
            faceDetectionProvider: provider
        )
        let parameters = BeautyParameters(faceSlim: 0.5)
        let neutral = pixels(try engine.processResult(
            image: image, metadata: metadata, parameters: .init()
        ).output)
        for index in 0..<7 {
            let result = try engine.processResult(
                image: image, metadata: metadata, frameIndex: index,
                parameters: parameters
            )
            XCTAssertEqual(result.output.extent, image.extent)
            if index.isMultiple(of: 3) {
                XCTAssertEqual(result.detectionSummary?.availability, .usable)
                XCTAssertEqual(result.detectionSummary?.reasons, [])
                XCTAssertNotEqual(pixels(result.output), neutral)
            } else {
                XCTAssertEqual(result.detectionSummary?.availability, .skipped)
                XCTAssertEqual(result.detectionSummary?.reasons, [.detectionInterval])
                XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
                XCTAssertEqual(pixels(result.output), neutral)
            }
        }
        XCTAssertEqual(provider.invocationCount, 3)

        let noFaceIntent = try engine.processResult(
            image: image, metadata: metadata, frameIndex: 8,
            parameters: BeautyParameters(saturation: 0.3)
        )
        XCTAssertEqual(noFaceIntent.detectionSummary?.availability, .notRun)
        XCTAssertEqual(provider.invocationCount, 3)

        let legacy = try engine.processResult(
            image: image, metadata: metadata, parameters: parameters
        )
        XCTAssertEqual(legacy.detectionSummary?.availability, .usable)
        XCTAssertEqual(provider.invocationCount, 4)
    }

    func testCadenceRejectsInvalidFrameContextAndRecovers() throws {
        let provider = SDKTestingFaceDetectionProvider([.usableFace])
        var configuration = BeautyConfiguration(detectionFrameInterval: 3)
        configuration.detectionFrameInterval = 0
        XCTAssertEqual(configuration.detectionFrameInterval, 1)
        let engine = try BeautyEngine(
            configuration: configuration, faceDetectionProvider: provider
        )
        let parameters = BeautyParameters(faceSlim: 0.5)
        for (source, index) in [(BeautyInputSource.photo, 0), (.video, -1)] {
            XCTAssertThrowsError(try engine.processResult(
                image: image,
                metadata: BeautyInputMetadata(
                    orientation: metadata.orientation,
                    isInputMirrored: metadata.isInputMirrored,
                    source: source
                ),
                frameIndex: index,
                parameters: parameters
            )) { error in
                XCTAssertEqual(error as? BeautyError, .invalidInput)
            }
        }
        XCTAssertEqual(provider.invocationCount, 0)
        let recovered = try engine.processResult(
            image: image, metadata: metadata, frameIndex: 1,
            parameters: parameters
        )
        XCTAssertEqual(recovered.detectionSummary?.availability, .usable)
        XCTAssertEqual(provider.invocationCount, 1)
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [
            .workingColorSpace: colorSpace, .outputColorSpace: colorSpace
        ])
        let width = Int(image.extent.width)
        let height = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image, toBitmap: &bytes, rowBytes: width * 4,
            bounds: image.extent, format: .RGBA8, colorSpace: colorSpace
        )
        return bytes
    }
}
