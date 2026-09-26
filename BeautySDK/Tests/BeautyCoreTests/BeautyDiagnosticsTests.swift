import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyDiagnosticsTests: XCTestCase {
    private let size = 16
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testLogLevelAndDebugModeFilterOnlyClosedSuccessEvents() throws {
        let image = makeImage()
        let request = BeautyParameters(faceSlim: 0.8)
        let rows: [(BeautyLogLevel, Bool, [BeautyDiagnosticCode])] = [
            (.none, false, []), (.error, false, []),
            (.warning, false, [.warningsPresent]),
            (.info, false, [.warningsPresent, .requestSucceeded]),
            (.debug, false, [.warningsPresent, .requestSucceeded]),
            (.debug, true, [.warningsPresent, .requestSucceeded, .backendExecuted]),
            (.error, true, []),
        ]
        var reference: [UInt8]?
        for (level, debug, expected) in rows {
            let engine = try BeautyEngine(
                configuration: .init(enableDebugMode: debug, logLevel: level),
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            let result = try engine.processResult(image: image, metadata: metadata, parameters: request)
            XCTAssertFalse(result.warnings.isEmpty)
            XCTAssertEqual(result.diagnostics.map(\.code), expected)
            XCTAssertEqual(result.diagnostics.map(\.level), expected.map { $0.level })
            let output = rgba(result.output)
            if let reference { XCTAssertEqual(output, reference) } else { reference = output }
            XCTAssertEqual(result.diagnostics, try engine.processResult(
                image: image, metadata: metadata, parameters: request
            ).diagnostics)
        }
    }

    func testPixelBufferAndEncodedRoutesKeepDiagnosticsRequestLocal() throws {
        let configuration = BeautyConfiguration(enableDebugMode: true, logLevel: .debug)
        let engine = try BeautyEngine(configuration: configuration)
        let image = makeImage()
        let encoded = try png(image)
        let expected: [BeautyDiagnosticCode] = [.requestSucceeded, .backendExecuted]
        let still = try engine.processResult(image: image, metadata: metadata, parameters: .init())
        let coded = try engine.processResult(
            encodedImageData: encoded, metadata: metadata, parameters: .init()
        )
        XCTAssertEqual(still.diagnostics.map(\.code), expected)
        XCTAssertEqual(coded.diagnostics.map(\.code), expected)
        XCTAssertEqual(rgba(still.output), rgba(coded.output))
        XCTAssertThrowsError(try engine.processResult(
            encodedImageData: Data(), metadata: metadata, parameters: .init()
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(try engine.processResult(
            image: image, metadata: metadata, parameters: .init()
        ).diagnostics.map(\.code), expected)

        let buffer = try makeBuffer()
        let frame = try engine.processResult(pixelBuffer: buffer, metadata: metadata, parameters: .init())
        XCTAssertEqual(frame.diagnostics.map(\.code), expected)
        XCTAssertEqual(bufferBytes(frame.output), bufferBytes(buffer))
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
                bytes[offset] = 51; bytes[offset + 1] = 64
                bytes[offset + 2] = 89; bytes[offset + 3] = 255
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
