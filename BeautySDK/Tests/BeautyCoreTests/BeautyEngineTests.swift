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
