import CoreImage
import CoreVideo
import Foundation
import XCTest
import BeautyCore
@testable import BeautyEffects

final class SkinBasicEffectTests: XCTestCase {
    func testDefaultPlanPreservesCIImagePixelsAndExtent() throws {
        let image = ciImage(width: 2, height: 1, rgba: [
            60, 90, 120, 255,
            130, 110, 95, 255
        ])
        let inputPixels = rgbaPixels(from: image, width: 2, height: 1)
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters())

        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)

        XCTAssertEqual(output.extent, image.extent)
        XCTAssertEqual(rgbaPixels(from: output, width: 2, height: 1), inputPixels)
    }

    func testSkinWhiteningLiftsLuminanceConservativelyInCIAndPixelBufferPaths() throws {
        let parameters = BeautyParameters(skinWhitening: 0.5)
        let plan = BeautyEffectResolver.resolve(parameters: parameters)
        let image = ciImage(width: 1, height: 1, rgba: [96, 82, 70, 255])
        let inputPixel = rgbaPixels(from: image, width: 1, height: 1)[0]

        let ciOutput = BeautyColorEffectPipeline.apply(to: image, plan: plan)
        let ciPixel = rgbaPixels(from: ciOutput, width: 1, height: 1)[0]

        XCTAssertGreaterThan(luminance(ciPixel), luminance(inputPixel))
        XCTAssertLessThanOrEqual(ciPixel.red - inputPixel.red, 34)
        XCTAssertLessThanOrEqual(ciPixel.green - inputPixel.green, 36)
        XCTAssertLessThanOrEqual(ciPixel.blue - inputPixel.blue, 34)

        let pixelBuffer = try makeBGRA(width: 1, height: 1, rgba: [96, 82, 70, 255])
        let rendered = try BeautyColorEffectPipeline.apply(to: pixelBuffer, plan: plan)
        let bufferPixel = try rgbaPixels(from: rendered, width: 1, height: 1)[0]

        XCTAssertGreaterThan(luminance(bufferPixel), luminance(inputPixel))
        XCTAssertLessThanOrEqual(abs(bufferPixel.red - ciPixel.red), 8)
        XCTAssertLessThanOrEqual(abs(bufferPixel.green - ciPixel.green), 8)
        XCTAssertLessThanOrEqual(abs(bufferPixel.blue - ciPixel.blue), 8)
    }

    func testSkinRosyAddsConservativeRedBiasWithoutLargeBlueShift() throws {
        let image = ciImage(width: 1, height: 1, rgba: [116, 96, 86, 255])
        let inputPixel = rgbaPixels(from: image, width: 1, height: 1)[0]
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinRosy: 0.4))

        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)
        let pixel = rgbaPixels(from: output, width: 1, height: 1)[0]

        XCTAssertGreaterThan(pixel.red - inputPixel.red, pixel.blue - inputPixel.blue)
        XCTAssertGreaterThan(pixel.red, inputPixel.red)
        XCTAssertLessThanOrEqual(pixel.red - inputPixel.red, 18)
        XCTAssertLessThanOrEqual(abs(pixel.blue - inputPixel.blue), 4)
    }

    func testSkinSharpenIncreasesLocalContrastWithoutChangingExtent() throws {
        let image = ciImage(width: 2, height: 1, rgba: [
            74, 74, 74, 255,
            172, 172, 172, 255
        ])
        let input = rgbaPixels(from: image, width: 2, height: 1)
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinSharpen: 0.4))

        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)
        let pixels = rgbaPixels(from: output, width: 2, height: 1)

        XCTAssertEqual(output.extent, image.extent)
        XCTAssertGreaterThan(pixels[1].red - pixels[0].red, input[1].red - input[0].red)
    }

    func testSkinSmoothingMovesChannelsTowardLuminanceWithoutFlatteningTextureProxy() throws {
        let image = ciImage(width: 1, height: 1, rgba: [178, 78, 48, 255])
        let inputPixel = rgbaPixels(from: image, width: 1, height: 1)[0]
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinSmoothing: 0.5))

        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)
        let pixel = rgbaPixels(from: output, width: 1, height: 1)[0]

        XCTAssertLessThan(channelSpread(pixel), channelSpread(inputPixel))
        XCTAssertGreaterThan(channelSpread(pixel), 45)
        XCTAssertGreaterThanOrEqual(
            Double(channelSpread(inputPixel) - channelSpread(pixel)) / Double(channelSpread(inputPixel)),
            0.08
        )
    }

    func testStillImageHighlightAndShadowSelectTheirOwnLuminanceRegion() {
        let image = ciImage(width: 2, height: 1, rgba: [
            40, 40, 40, 255,
            200, 200, 200, 255
        ])
        let source = rgbaPixels(from: image, width: 2, height: 1)
        let highlight = rgbaPixels(
            from: BeautyColorEffectPipeline.apply(
                to: image,
                plan: BeautyEffectResolver.resolve(parameters: BeautyParameters(highlight: 0.8))
            ),
            width: 2,
            height: 1
        )
        let shadow = rgbaPixels(
            from: BeautyColorEffectPipeline.apply(
                to: image,
                plan: BeautyEffectResolver.resolve(parameters: BeautyParameters(shadow: 0.8))
            ),
            width: 2,
            height: 1
        )

        XCTAssertGreaterThan(highlight[1].red, source[1].red)
        XCTAssertLessThanOrEqual(abs(highlight[0].red - source[0].red), 1)
        XCTAssertGreaterThan(shadow[0].red, source[0].red)
        XCTAssertLessThanOrEqual(abs(shadow[1].red - source[1].red), 1)
        XCTAssertEqual(highlight.map(\.alpha), source.map(\.alpha))
        XCTAssertEqual(shadow.map(\.alpha), source.map(\.alpha))
    }

    func testStillImageSelectiveTonePreservesTranslucentAndTransparentAlpha() {
        let image = ciImage(width: 2, height: 1, rgba: [
            180, 180, 180, 128,
            0, 0, 0, 0
        ])
        let source = rgbaPixels(from: image, width: 2, height: 1)
        let output = BeautyColorEffectPipeline.apply(
            to: image,
            plan: BeautyEffectResolver.resolve(
                parameters: BeautyParameters(highlight: 0.8, shadow: 0.8)
            )
        )
        let pixels = rgbaPixels(from: output, width: 2, height: 1)

        XCTAssertEqual(output.extent, image.extent)
        XCTAssertEqual(pixels.map(\.alpha), source.map(\.alpha))
        XCTAssertEqual(pixels[1], source[1])
    }

    func testSkinComboProducesVisibleCappedMediumStrengthOutput() throws {
        let image = ciImage(width: 2, height: 1, rgba: [
            116, 90, 74, 255,
            150, 118, 96, 255
        ])
        let inputPixels = rgbaPixels(from: image, width: 2, height: 1)
        let parameters = BeautyParameters(
            skinSmoothing: 0.5,
            skinWhitening: 0.5,
            skinRosy: 0.35,
            skinSharpen: 0.25
        )
        let plan = BeautyEffectResolver.resolve(parameters: parameters)

        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)
        let outputPixels = rgbaPixels(from: output, width: 2, height: 1)

        XCTAssertNotEqual(outputPixels, inputPixels)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinSmoothing, BeautySafetyCaps.skinSmoothing)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinWhitening, BeautySafetyCaps.skinWhitening)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinRosy, BeautySafetyCaps.skinRosy)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinSharpen, BeautySafetyCaps.skinSharpen)
        XCTAssertLessThanOrEqual(maxChannelDelta(inputPixels, outputPixels), 42)
    }
}

private struct RGBAPixel: Equatable {
    let red: Int
    let green: Int
    let blue: Int
    let alpha: Int
}

private func ciImage(width: Int, height: Int, rgba: [UInt8]) -> CIImage {
    CIImage(
        bitmapData: Data(rgba),
        bytesPerRow: width * 4,
        size: CGSize(width: width, height: height),
        format: .RGBA8,
        colorSpace: CGColorSpaceCreateDeviceRGB()
    )
}

private func rgbaPixels(from image: CIImage, width: Int, height: Int) -> [RGBAPixel] {
    let context = CIContext(options: [
        .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
        .outputColorSpace: CGColorSpaceCreateDeviceRGB()
    ])
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    context.render(
        image,
        toBitmap: &bytes,
        rowBytes: width * 4,
        bounds: CGRect(x: 0, y: 0, width: width, height: height),
        format: .RGBA8,
        colorSpace: CGColorSpaceCreateDeviceRGB()
    )
    var pixels: [RGBAPixel] = []
    pixels.reserveCapacity(width * height)
    var offset = 0
    while offset < bytes.count {
        pixels.append(RGBAPixel(
            red: Int(bytes[offset]),
            green: Int(bytes[offset + 1]),
            blue: Int(bytes[offset + 2]),
            alpha: Int(bytes[offset + 3])
        ))
        offset += 4
    }
    return pixels
}

private func makeBGRA(width: Int, height: Int, rgba: [UInt8]) throws -> CVPixelBuffer {
    let attributes: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
        kCVPixelBufferIOSurfacePropertiesKey as String: [:]
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
    for row in 0..<height {
        let outputRow = baseAddress.advanced(by: row * bytesPerRow).assumingMemoryBound(to: UInt8.self)
        for column in 0..<width {
            let rgbaOffset = (row * width + column) * 4
            let bgraOffset = column * 4
            outputRow[bgraOffset] = rgba[rgbaOffset + 2]
            outputRow[bgraOffset + 1] = rgba[rgbaOffset + 1]
            outputRow[bgraOffset + 2] = rgba[rgbaOffset]
            outputRow[bgraOffset + 3] = rgba[rgbaOffset + 3]
        }
    }
    return pixelBuffer
}

private func rgbaPixels(from pixelBuffer: CVPixelBuffer, width: Int, height: Int) throws -> [RGBAPixel] {
    guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
        throw BeautyError.invalidInput
    }
    defer {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
        throw BeautyError.invalidInput
    }
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    var pixels: [RGBAPixel] = []
    for row in 0..<height {
        let inputRow = baseAddress.advanced(by: row * bytesPerRow).assumingMemoryBound(to: UInt8.self)
        for column in 0..<width {
            let offset = column * 4
            pixels.append(
                RGBAPixel(
                    red: Int(inputRow[offset + 2]),
                    green: Int(inputRow[offset + 1]),
                    blue: Int(inputRow[offset]),
                    alpha: Int(inputRow[offset + 3])
                )
            )
        }
    }
    return pixels
}

private func luminance(_ pixel: RGBAPixel) -> Double {
    (0.299 * Double(pixel.red) + 0.587 * Double(pixel.green) + 0.114 * Double(pixel.blue)) / 255.0
}

private func channelSpread(_ pixel: RGBAPixel) -> Int {
    let values = [pixel.red, pixel.green, pixel.blue]
    return (values.max() ?? 0) - (values.min() ?? 0)
}

private func maxChannelDelta(_ lhs: [RGBAPixel], _ rhs: [RGBAPixel]) -> Int {
    zip(lhs, rhs).reduce(0) { partial, pair in
        max(
            partial,
            abs(pair.0.red - pair.1.red),
            abs(pair.0.green - pair.1.green),
            abs(pair.0.blue - pair.1.blue)
        )
    }
}
