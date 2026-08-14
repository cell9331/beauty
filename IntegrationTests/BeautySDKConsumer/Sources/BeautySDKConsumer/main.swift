import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import BeautySDK

@main
struct BeautySDKConsumer {
    private static let width = 4
    private static let height = 3
    private static let expectedBytes: [UInt8] = [
        12, 34, 56, 255, 210, 180, 140, 255, 48, 96, 144, 255, 240, 220, 200, 255,
        32, 64, 96, 255, 128, 96, 64, 255, 72, 144, 216, 255, 16, 32, 48, 255,
        200, 100, 50, 255, 80, 40, 20, 255, 160, 200, 240, 255, 4, 8, 12, 255
    ]

    static func main() {
        guard run() else {
            exit(1)
        }
        print("beauty_sdk_consumer_smoke_passed width=4 height=3 rgba_bytes=48")
    }

    private static func run() -> Bool {
        guard expectedBytes.count == width * height * 4,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let input = makeInput(colorSpace: colorSpace),
              input.extent == CGRect(x: 0, y: 0, width: width, height: height)
        else {
            return false
        }

        do {
            let engine = try BeautyEngine(configuration: .default)
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: BeautyParameters()
            )

            guard result.warnings.isEmpty,
                  result.metrics == [
                    "beauty.effects.activeCount": 0,
                    "beauty.effects.cappedCount": 0
                  ],
                  result.detectionSummary == .notRun,
                  result.output.extent == input.extent,
                  result.output.extent.width == CGFloat(width),
                  result.output.extent.height == CGFloat(height),
                  let output = render(result.output, colorSpace: colorSpace),
                  output.width == width,
                  output.height == height,
                  output.bytes == expectedBytes
            else {
                return false
            }
            return true
        } catch {
            return false
        }
    }

    private static func makeInput(colorSpace: CGColorSpace) -> CIImage? {
        let data = Data(expectedBytes)
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }
        return CIImage(cgImage: image)
    }

    private static func render(_ image: CIImage, colorSpace: CGColorSpace) -> RenderedImage? {
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        guard let output = context.createCGImage(image, from: image.extent),
              let data = output.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data)
        else {
            return nil
        }
        let count = CFDataGetLength(data)
        return RenderedImage(
            width: output.width,
            height: output.height,
            bytes: Array(UnsafeBufferPointer(start: bytes, count: count))
        )
    }
}

private struct RenderedImage {
    let width: Int
    let height: Int
    let bytes: [UInt8]
}
