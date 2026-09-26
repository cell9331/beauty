import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
import BeautySDK

final class BeautyEncodedInputLimitTests: XCTestCase {
    private let size = 32

    func testExactByteLimitAdmitsEncodedPNGAndProducesPublicPixels() throws {
        let encoded = try generatedPNG()
        let engine = try BeautyEngine(configuration: .init(maximumInputByteCount: encoded.count))
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let neutral = try engine.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: .init()
        )
        let bright = try engine.processResult(
            encodedImageData: encoded, metadata: metadata,
            parameters: .init(brightness: 0.5)
        )
        XCTAssertEqual(neutral.output.extent, CGRect(x: 0, y: 0, width: size, height: size))
        XCTAssertEqual(bright.output.extent, neutral.output.extent)
        let before = rgba(neutral.output)
        let after = rgba(bright.output)
        XCTAssertGreaterThan(Int(after[0]), Int(before[0]) + 5)
        XCTAssertEqual(
            stride(from: 3, to: before.count, by: 4).map { before[$0] },
            stride(from: 3, to: after.count, by: 4).map { after[$0] }
        )
        XCTAssertEqual(
            rgba(try engine.processResult(
                encodedImageData: encoded, metadata: metadata,
                parameters: .init(brightness: 0.5)
            ).output), after
        )
    }

    func testOverLimitAndMalformedEncodedDataFailTypedThenRecover() throws {
        let encoded = try generatedPNG()
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let lowLimit = try BeautyEngine(
            configuration: .init(maximumInputByteCount: encoded.count - 1)
        )
        XCTAssertThrowsError(try lowLimit.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: .init()
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        let pixelLimited = try BeautyEngine(configuration: .init(
            maximumInputByteCount: encoded.count,
            maximumInputPixelCount: size * size - 1
        ))
        XCTAssertThrowsError(try pixelLimited.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: .init()
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        let decoded = CIImage(color: CIColor(red: 0.35, green: 0.25, blue: 0.2))
            .cropped(to: CGRect(x: 0, y: 0, width: size, height: size))
        XCTAssertNoThrow(try lowLimit.processResult(
            image: decoded, metadata: metadata, parameters: .init()
        ), "decoded-image entry must keep its existing pixel-only limit")

        let engine = try BeautyEngine(configuration: .init(maximumInputByteCount: encoded.count))
        for malformed in [Data(), Data([0, 1, 2, 3])] {
            XCTAssertThrowsError(try engine.processResult(
                encodedImageData: malformed, metadata: metadata, parameters: .init()
            )) { error in
                XCTAssertEqual(error as? BeautyError, .invalidInput)
            }
        }
        XCTAssertNoThrow(try engine.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: .init()
        ))
    }

    private func generatedPNG() throws -> Data {
        let space = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = CIImage(color: CIColor(red: 0.35, green: 0.25, blue: 0.2))
            .cropped(to: CGRect(x: 0, y: 0, width: size, height: size))
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        let cgImage = try XCTUnwrap(context.createCGImage(image, from: image.extent))
        let buffer = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(
            buffer as CFMutableData, "public.png" as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, cgImage, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return buffer as Data
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        var bytes = [UInt8](repeating: 0, count: size * size * 4)
        context.render(
            image, toBitmap: &bytes, rowBytes: size * 4,
            bounds: CGRect(x: 0, y: 0, width: size, height: size),
            format: .RGBA8, colorSpace: space
        )
        return bytes
    }
}
