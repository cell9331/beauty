import BeautyCore
import BeautyDetection
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects

final class BeautyCPUBackendTests: XCTestCase {
    func testPixelBufferCPUBackendPreservesNeutralBytesAndAlpha() throws {
        let input = try Self.makePixelBuffer(bytes: [
            1, 2, 3, 255,
            4, 5, 6, 127,
        ], width: 2, height: 1)
        let request = try BeautyBackendRequest(
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )

        let result = try BeautyCPUBackend().execute(request)

        guard case .pixelBuffer(let output) = result.output else {
            return XCTFail("CPU backend changed the output kind")
        }
        XCTAssertEqual(try Self.bytes(from: output), try Self.bytes(from: input))
        XCTAssertEqual(result.diagnostics.width, 2)
        XCTAssertEqual(result.diagnostics.height, 1)
        XCTAssertTrue(result.diagnostics.preservesAlpha)
        XCTAssertTrue(result.diagnostics.preservesExtent)
    }

    func testStillCPUBackendUsesCanonicalCarrierAndPreservesExtent() throws {
        let canonical = try Self.canonical(
            width: 2,
            height: 1,
            bytes: [10, 20, 30, 255, 40, 50, 60, 255]
        )
        var strengths = BeautyEffectiveStrengths()
        strengths.brightness = 0.2
        let request = try BeautyBackendRequest(
            input: .stillImage(canonical.ciImage),
            metadata: canonical.metadata,
            plan: BeautyEffectPlan(effectiveStrengths: strengths),
            canonicalImage: canonical
        )

        let result = try BeautyCPUBackend().execute(request)

        guard case .stillImage(let output) = result.output else {
            return XCTFail("CPU backend changed the output kind")
        }
        XCTAssertEqual(output.extent, canonical.ciImage.extent)
        XCTAssertEqual(result.diagnostics.width, canonical.width)
        XCTAssertEqual(result.diagnostics.height, canonical.height)
    }

    private static func metadata(source: BeautyInputSource) -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: .up, source: source)
    }

    private static func canonical(
        width: Int,
        height: Int,
        bytes: [UInt8]
    ) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: metadata(source: .testFixture)
        )
    }

    private static func makePixelBuffer(
        bytes: [UInt8],
        width: Int,
        height: Int
    ) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        guard bytes.count == width * height * 4,
              CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
        else {
            throw BeautyError.invalidInput
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        bytes.withUnsafeBytes { rawBytes in
            guard let source = rawBytes.baseAddress else { return }
            for row in 0..<height {
                memcpy(
                    baseAddress.advanced(by: row * CVPixelBufferGetBytesPerRow(pixelBuffer)),
                    source.advanced(by: row * width * 4),
                    width * 4
                )
            }
        }
        return pixelBuffer
    }

    private static func bytes(from pixelBuffer: CVPixelBuffer) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        for row in 0..<height {
            bytes.replaceSubrange(
                row * width * 4..<(row + 1) * width * 4,
                with: UnsafeBufferPointer(
                    start: baseAddress.advanced(by: row * rowBytes).assumingMemoryBound(to: UInt8.self),
                    count: width * 4
                )
            )
        }
        return bytes
    }
}
