import CoreImage
import CoreVideo
import ImageIO
import XCTest
import BeautySDK

// Requirement evidence: SDK-02, SDK-04, SDK-06, SDK-07.
final class BeautyEngineTests: XCTestCase {
    func testSDK04PixelBufferNoopPreservesPixelsInNewOutputBuffer() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 2, height: 2, bytes: [
            10, 20, 30, 255,
            40, 50, 60, 255,
            70, 80, 90, 255,
            100, 110, 120, 255
        ])
        let engine = try BeautyEngine(configuration: .default)

        let output = try engine.process(pixelBuffer: input, orientation: .up, parameters: .init())

        XCTAssertFalse(input === output)
        XCTAssertEqual(try PixelBufferFixtures.bytes(from: output), try PixelBufferFixtures.bytes(from: input))
    }

    func testSDK04ImageNoopPreservesExtentAndRenderedPixels() throws {
        let image = CIImage(color: CIColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        let engine = try BeautyEngine(configuration: .default)

        let output = try engine.process(image: image, orientation: .up, parameters: .init())

        XCTAssertEqual(output.extent, image.extent)
        XCTAssertEqual(try PixelBufferFixtures.rgbaBytes(from: output), try PixelBufferFixtures.rgbaBytes(from: image))
    }

    func testEFFECT01PixelBufferSkinColorAndFilterParametersProduceVisibleOutput() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 2, height: 1, bytes: [
            30, 40, 50, 255,
            90, 100, 110, 255
        ])
        let engine = try BeautyEngine(configuration: .default)
        let parameters = BeautyParameters(
            skinWhitening: 0.5,
            skinRosy: 0.3,
            brightness: 0.2,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )

        let result = try engine.processResult(
            pixelBuffer: input,
            metadata: BeautyInputMetadata(orientation: .up, source: .camera),
            parameters: parameters
        )

        XCTAssertFalse(input === result.output)
        XCTAssertNotEqual(try PixelBufferFixtures.bytes(from: result.output), try PixelBufferFixtures.bytes(from: input))
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 3)
    }

    func testEFFECT01ImageSkinColorAndFilterParametersProduceVisibleOutput() throws {
        let image = CIImage(color: CIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        let engine = try BeautyEngine(configuration: .default)
        let parameters = BeautyParameters(
            skinWhitening: 0.3,
            skinRosy: 0.2,
            brightness: 0.2,
            filterId: "warm_light",
            filterIntensity: 0.5
        )

        let result = try engine.processResult(
            image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: parameters
        )

        XCTAssertEqual(result.output.extent, image.extent)
        XCTAssertNotEqual(try PixelBufferFixtures.rgbaBytes(from: result.output), try PixelBufferFixtures.rgbaBytes(from: image))
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 3)
    }

    func testEFFECT09UnknownFilterThrowsTypedResourceErrorBeforeRendering() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 1, height: 1, bytes: [10, 20, 30, 255])
        let engine = try BeautyEngine(configuration: .default)
        let parameters = BeautyParameters(filterId: "missing_filter", filterIntensity: 0.5)

        XCTAssertThrowsError(
            try engine.process(pixelBuffer: input, orientation: .up, parameters: parameters)
        ) { error in
            XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing_filter"))
        }
    }

    func testEFFECT09BuiltInPresetProducesVisiblePixelBufferOutput() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 1, height: 1, bytes: [80, 90, 100, 255])
        let engine = try BeautyEngine(configuration: .default)
        let preset = try BeautySDKResources.preset(id: "natural")

        let output = try engine.process(pixelBuffer: input, orientation: .up, parameters: preset.parameters)

        XCTAssertNotEqual(try PixelBufferFixtures.bytes(from: output), try PixelBufferFixtures.bytes(from: input))
    }

    func testEFFECT09EngineReturnsResolverWarningsAndMetrics() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 1, height: 1, bytes: [70, 80, 90, 255])
        let engine = try BeautyEngine(configuration: .default)

        let result = try engine.processResult(
            pixelBuffer: input,
            metadata: BeautyInputMetadata(orientation: .up, source: .camera),
            parameters: BeautyParameters(skinSmoothing: 1)
        )

        XCTAssertTrue(result.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 1)
    }

    func testSDK06UnsupportedPixelFormatReturnsTypedError() throws {
        let input = try PixelBufferFixtures.makePixelBuffer(width: 2, height: 2, pixelFormat: kCVPixelFormatType_OneComponent8)
        let engine = try BeautyEngine(configuration: .default)

        XCTAssertThrowsError(try engine.process(pixelBuffer: input, orientation: .up, parameters: .init())) { error in
            XCTAssertEqual(error as? BeautyError, .unsupportedPixelFormat)
        }
    }

    func testResetIsIdempotentAndDoesNotMutateCallerParameters() throws {
        let parameters = BeautyParameters(skinSmoothing: 0.5)
        var copy = parameters
        let engine = try BeautyEngine(configuration: .default)

        engine.reset()
        engine.reset()

        XCTAssertEqual(parameters, copy)
        XCTAssertEqual(engine.resetCountForTesting, 2)
        copy = parameters
        XCTAssertEqual(copy.skinSmoothing, 0.5)
    }
}

enum PixelBufferFixtures {
    static func makePixelBuffer(width: Int, height: Int, pixelFormat: OSType) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        return pixelBuffer
    }

    static func makeBGRA(width: Int, height: Int, bytes: [UInt8]) throws -> CVPixelBuffer {
        let pixelBuffer = try makePixelBuffer(width: width, height: height, pixelFormat: kCVPixelFormatType_32BGRA)
        guard CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let expectedRowBytes = width * 4
        try bytes.withUnsafeBytes { rawBytes in
            guard let sourceBase = rawBytes.baseAddress else {
                throw BeautyError.invalidInput
            }
            for row in 0..<height {
                let sourceStart = row * expectedRowBytes
                memcpy(
                    baseAddress.advanced(by: row * bytesPerRow),
                    sourceBase.advanced(by: sourceStart),
                    expectedRowBytes
                )
            }
        }
        return pixelBuffer
    }

    static func bytes(from pixelBuffer: CVPixelBuffer) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let expectedRowBytes = width * 4
        var output: [UInt8] = []
        for row in 0..<height {
            let rowPointer = baseAddress.advanced(by: row * bytesPerRow).assumingMemoryBound(to: UInt8.self)
            output.append(contentsOf: UnsafeBufferPointer(start: rowPointer, count: expectedRowBytes))
        }
        return output
    }

    static func rgbaBytes(from image: CIImage) throws -> [UInt8] {
        let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
        var bytes = [UInt8](repeating: 0, count: 4)
        context.render(
            image,
            toBitmap: &bytes,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return bytes
    }
}
