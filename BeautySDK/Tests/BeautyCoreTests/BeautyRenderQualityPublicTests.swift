import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautySDK

final class BeautyRenderQualityPublicTests: XCTestCase {
    private let size = 80
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testThreeQualityModesOrderTextureEffectAndProtectNegativeRegions() throws {
        let source = textured()
        let image = makeImage(source)
        let parameters = BeautyParameters(skinSmoothing: 0.5)
        let modes: [BeautyRenderQuality] = [.performance, .balanced, .quality]
        let outputs = try modes.map { mode -> [UInt8] in
            let engine = try BeautyEngine(configuration: .init(renderQuality: mode))
            let neutral = rgba(try engine.processResult(
                image: image, metadata: metadata, parameters: .init()
            ).output)
            let result = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
            XCTAssertEqual(result.output.extent, image.extent)
            let output = rgba(result.output)
            XCTAssertEqual(output, rgba(try engine.processResult(
                image: image, metadata: metadata, parameters: parameters
            ).output))
            XCTAssertLessThanOrEqual(protectedMaxDelta(neutral, output), 1, "\(mode)")
            XCTAssertTrue(alphaExact(neutral, output))
            return output
        }
        let deviations = outputs.map(textureDeviation)
        XCTAssertGreaterThan(textureDeviation(source), deviations[0])
        XCTAssertGreaterThan(deviations[0], deviations[1])
        XCTAssertGreaterThan(deviations[1], deviations[2])

        let flat = flatNegative()
        for mode in modes {
            let engine = try BeautyEngine(configuration: .init(renderQuality: mode))
            let flatImage = makeImage(flat)
            XCTAssertEqual(rgba(try engine.processResult(
                image: flatImage, metadata: metadata, parameters: parameters
            ).output), rgba(try engine.processResult(
                image: flatImage, metadata: metadata, parameters: .init()
            ).output))
            XCTAssertEqual(rgba(try engine.processResult(
                image: image, metadata: metadata, parameters: .init()
            ).output), rgba(image))
        }
    }

    func testQualityModeMatchesAvailableMetalAndKeepsTypedRecovery() throws {
        let source = textured()
        let image = makeImage(source)
        let parameters = BeautyParameters(skinSmoothing: 0.5)
        let cpu = try BeautyEngine(configuration: .init(renderQuality: .quality))
        let cpuOutput = rgba(try cpu.processResult(
            image: image, metadata: metadata, parameters: parameters
        ).output)
        let limited = try BeautyEngine(configuration: .init(
            renderQuality: .quality, maximumInputPixelCount: size * size - 1
        ))
        XCTAssertThrowsError(try limited.processResult(
            image: image, metadata: metadata, parameters: parameters
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(cpuOutput, rgba(try cpu.processResult(
            image: image, metadata: metadata, parameters: parameters
        ).output))

        let gpu: BeautyEngine
        do {
            gpu = try BeautyEngine(configuration: .init(
                renderQuality: .quality, renderBackend: .gpu
            ))
        } catch BeautyError.metalUnavailable {
            return
        }
        let metal = rgba(try gpu.processResult(
            image: image, metadata: metadata, parameters: parameters
        ).output)
        let metalNeutral = rgba(try gpu.processResult(
            image: image, metadata: metadata, parameters: .init()
        ).output)
        XCTAssertEqual(metal.count, cpuOutput.count)
        XCTAssertLessThanOrEqual(zip(cpuOutput, metal).map { abs(Int($0) - Int($1)) }.max() ?? Int.max, 2)
        XCTAssertLessThanOrEqual(protectedMaxDelta(metalNeutral, metal), 1)
        XCTAssertTrue(alphaExact(metalNeutral, metal))
    }

    private func textured() -> [UInt8] { fixture(textured: true) }
    private func flatNegative() -> [UInt8] { fixture(textured: false) }

    private func fixture(textured: Bool) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: size * size * 4)
        for y in 0..<size {
            for x in 0..<size {
                let inside = (20..<60).contains(x) && (20..<60).contains(y)
                let wave = ((x / 4 + y / 4).isMultiple(of: 2) ? 10 : -10)
                let value = inside ? 150 + (textured ? wave : 0) : 36
                let offset = (y * size + x) * 4
                result[offset] = UInt8(value)
                result[offset + 1] = UInt8(value)
                result[offset + 2] = UInt8(value)
                result[offset + 3] = 255
            }
        }
        return result
    }

    private func makeImage(_ pixels: [UInt8]) -> CIImage {
        CIImage(bitmapData: Data(pixels), bytesPerRow: size * 4,
                size: CGSize(width: size, height: size), format: .RGBA8,
                colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
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

    private func textureDeviation(_ pixels: [UInt8]) -> Double {
        let values = (27..<53).flatMap { y in (27..<53).map { x in
            abs(Int(pixels[(y * size + x) * 4]) - 150)
        } }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    private func protectedMaxDelta(_ source: [UInt8], _ output: [UInt8]) -> Int {
        var maximum = 0
        for y in 0..<size {
            for x in 0..<size where x <= 20 || x >= 59 || y <= 20 || y >= 59 {
                let offset = (y * size + x) * 4
                for channel in 0..<4 {
                    maximum = max(maximum, abs(Int(source[offset + channel]) - Int(output[offset + channel])))
                }
            }
        }
        return maximum
    }

    private func alphaExact(_ source: [UInt8], _ output: [UInt8]) -> Bool {
        stride(from: 3, to: source.count, by: 4).allSatisfy { source[$0] == output[$0] }
    }
}
