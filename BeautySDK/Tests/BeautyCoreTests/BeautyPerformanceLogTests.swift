import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import XCTest
import BeautySDK

final class BeautyPerformanceLogTests: XCTestCase {
    private let size = 32
    private let key = "beauty.performance.facadeElapsedMilliseconds"

    func testStillAndEncodedEntriesOptInWithoutChangingPixels() throws {
        let image = makeImage()
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let quiet = try BeautyEngine(configuration: .init(enablePerformanceLog: false))
        let measured = try BeautyEngine(configuration: .init(enablePerformanceLog: true))
        let parameters = BeautyParameters(brightness: 0.25)
        let quietResult = try quiet.processResult(image: image, metadata: metadata, parameters: parameters)
        let measuredResult = try measured.processResult(image: image, metadata: metadata, parameters: parameters)
        XCTAssertNil(quietResult.metrics[key])
        assertElapsed(measuredResult.metrics[key])
        XCTAssertEqual(rgba(quietResult.output), rgba(measuredResult.output))

        let encoded = try png(image)
        let encodedResult = try measured.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: parameters
        )
        assertElapsed(encodedResult.metrics[key])
        XCTAssertEqual(rgba(encodedResult.output), rgba(measuredResult.output))
        XCTAssertThrowsError(try measured.processResult(
            encodedImageData: Data(), metadata: metadata, parameters: parameters
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        assertElapsed(try measured.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: parameters
        ).metrics[key])
    }

    func testPixelBufferEntryOptInWithoutChangingPixels() throws {
        let buffer = try makeBuffer()
        let metadata = BeautyInputMetadata(orientation: .up, source: .camera)
        let quiet = try BeautyEngine(configuration: .init(enablePerformanceLog: false))
        let measured = try BeautyEngine(configuration: .init(enablePerformanceLog: true))
        let parameters = BeautyParameters(brightness: 0.25)
        let a = try quiet.processResult(pixelBuffer: buffer, metadata: metadata, parameters: parameters)
        let b = try measured.processResult(pixelBuffer: buffer, metadata: metadata, parameters: parameters)
        XCTAssertNil(a.metrics[key])
        assertElapsed(b.metrics[key])
        XCTAssertEqual(bufferBytes(a.output), bufferBytes(b.output))
    }

    private func assertElapsed(_ value: Double?, file: StaticString = #filePath, line: UInt = #line) {
        guard let value else { return XCTFail("missing elapsed metric", file: file, line: line) }
        XCTAssertTrue(value.isFinite && value >= 0, file: file, line: line)
    }

    private func makeImage() -> CIImage {
        CIImage(color: CIColor(red: 0.35, green: 0.25, blue: 0.2))
            .cropped(to: CGRect(x: 0, y: 0, width: size, height: size))
    }

    private func png(_ image: CIImage) throws -> Data {
        let space = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        let cg = try XCTUnwrap(context.createCGImage(image, from: image.extent))
        let data = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(
            data as CFMutableData, "public.png" as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, cg, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return data as Data
    }

    private func makeBuffer() throws -> CVPixelBuffer {
        var optional: CVPixelBuffer?
        XCTAssertEqual(CVPixelBufferCreate(
            kCFAllocatorDefault, size, size, kCVPixelFormatType_32BGRA,
            [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary, &optional
        ), kCVReturnSuccess)
        let buffer = try XCTUnwrap(optional)
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { throw BeautyError.invalidInput }
        for row in 0..<size {
            let bytes = base.advanced(by: row * CVPixelBufferGetBytesPerRow(buffer))
                .assumingMemoryBound(to: UInt8.self)
            for column in 0..<size {
                let offset = column * 4
                bytes[offset] = 51
                bytes[offset + 1] = 64
                bytes[offset + 2] = 89
                bytes[offset + 3] = 255
            }
        }
        return buffer
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        var pixels = [UInt8](repeating: 0, count: size * size * 4)
        context.render(image, toBitmap: &pixels, rowBytes: size * 4,
                       bounds: CGRect(x: 0, y: 0, width: size, height: size),
                       format: .RGBA8, colorSpace: space)
        return pixels
    }

    private func bufferBytes(_ buffer: CVPixelBuffer) -> [UInt8] {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return [] }
        let stride = CVPixelBufferGetBytesPerRow(buffer)
        return (0..<size).flatMap { row in
            let start = base.advanced(by: row * stride).assumingMemoryBound(to: UInt8.self)
            return Array(UnsafeBufferPointer(start: start, count: size * 4))
        }
    }
}
