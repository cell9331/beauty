import CoreImage
import CoreVideo
import XCTest
import BeautyCore
@testable import BeautyEffects

final class LipColorEffectTests: XCTestCase {
    func testLipColorResolvesToCappedActiveDomainWhenMouthLandmarksExist() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(lipColor: 1),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.contains(.lipColor))
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.lipColor, BeautySafetyCaps.lipColor)
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
    }

    func testLipColorZeroKeepsLipDomainInactiveAndPixelBufferNoop() throws {
        let inputBytes = uniformBGRA(width: 10, height: 10)
        let input = try makeBGRA(width: 10, height: 10, bytes: inputBytes)
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(lipColor: 0),
            faceGeometry: .fixture
        )

        let output = try BeautyColorEffectPipeline.apply(to: input, plan: plan, face: .fixture)

        XCTAssertFalse(plan.activeDomains.contains(.lipColor))
        XCTAssertEqual(try bytes(from: output), inputBytes)
    }

    func testLipColorPixelBufferChangesOnlyMouthRegionSubset() throws {
        let width = 10
        let height = 10
        let inputBytes = uniformBGRA(width: width, height: height)
        let input = try makeBGRA(width: width, height: height, bytes: inputBytes)
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(lipColor: 0.5),
            faceGeometry: .fixture
        )

        let output = try BeautyColorEffectPipeline.apply(to: input, plan: plan, face: .fixture)
        let outputBytes = try bytes(from: output)
        let changedPixels = changedPixelCoordinates(input: inputBytes, output: outputBytes, width: width)

        XCTAssertFalse(changedPixels.isEmpty)
        XCTAssertLessThan(changedPixels.count, width * height)
        for pixel in changedPixels {
            let x = (Float(pixel.column) + 0.5) / Float(width)
            let y = (Float(pixel.row) + 0.5) / Float(height)
            XCTAssertTrue((0.35...0.65).contains(x), "Unexpected changed x: \(x)")
            XCTAssertTrue((0.55...0.78).contains(y), "Unexpected changed y: \(y)")
        }
    }

    func testLipColorImageOutputKeepsExtentAndChangesRenderedBytes() throws {
        let image = CIImage(color: CIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 10, height: 10))
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(lipColor: 0.5),
            faceGeometry: .fixture
        )

        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan, face: .fixture)

        XCTAssertEqual(output.extent, image.extent)
        XCTAssertNotEqual(try rgbaBytes(from: output, width: 10, height: 10), try rgbaBytes(from: image, width: 10, height: 10))
    }

    private func uniformBGRA(width: Int, height: Int) -> [UInt8] {
        Array(repeating: [70, 80, 90, 255], count: width * height).flatMap { $0 }
    }

    private func makeBGRA(width: Int, height: Int, bytes: [UInt8]) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        guard CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        try bytes.withUnsafeBytes { rawBytes in
            guard let sourceBase = rawBytes.baseAddress else {
                throw BeautyError.invalidInput
            }
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let expectedRowBytes = width * 4
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

    private func bytes(from pixelBuffer: CVPixelBuffer) throws -> [UInt8] {
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

    private func changedPixelCoordinates(input: [UInt8], output: [UInt8], width: Int) -> [(column: Int, row: Int)] {
        stride(from: 0, to: min(input.count, output.count), by: 4).compactMap { offset in
            guard input[offset..<(offset + 4)] != output[offset..<(offset + 4)] else {
                return nil
            }
            let pixel = offset / 4
            return (column: pixel % width, row: pixel / width)
        }
    }

    private func rgbaBytes(from image: CIImage, width: Int, height: Int) throws -> [UInt8] {
        let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
        var output = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image,
            toBitmap: &output,
            rowBytes: width * 4,
            bounds: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return output
    }
}
