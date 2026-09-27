import CoreGraphics
import CoreImage
import XCTest
@_spi(Testing) import BeautySDK

/// A source-fixed in-face non-skin negative for the public texture path.
final class BeautySkinTextureDecorationTests: XCTestCase {
    private let side = 64
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    func testSaturatedWarmCheekDecorationStaysExactWhileOppositeCheekChanges() throws {
        let source = portrait()
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: colorSpace
        )
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.textureFace])
        )

        XCTAssertNotEqual(source[(36 * side + 40) * 4], source[(36 * side + 42) * 4])
        XCTAssertEqual(rgba(try engine.processResult(
            image: image, metadata: metadata, parameters: .init()
        ).output), source)
        for parameters in [
            BeautyParameters(skinSmoothing: 1),
            BeautyParameters(skinSharpen: 1),
        ] {
            let result = try engine.processResult(
                image: image, metadata: metadata, parameters: parameters
            )
            let output = rgba(result.output)
            XCTAssertEqual(result.output.extent, image.extent)
            XCTAssertEqual(changed(source, output, x: 40..<43, y: 36..<39), 0)
            XCTAssertGreaterThan(changed(source, output, x: 22..<28, y: 36..<42), 0)
            XCTAssertEqual(output, rgba(try engine.processResult(
                image: image, metadata: metadata, parameters: parameters
            ).output))
            XCTAssertEqual(alpha(output), alpha(source))
        }
    }

    private func portrait() -> [UInt8] {
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = Double(x - 32) / 20
                let dy = Double(y - 33) / 24
                let inFace = dx * dx + dy * dy <= 1
                let onCheek = (34..<44).contains(y) &&
                    ((20..<29).contains(x) || (35..<44).contains(x))
                let decoration = (38..<45).contains(x) && (34..<41).contains(y)
                let detail = (x / 2 + y / 2).isMultiple(of: 2) ? 1 : -1
                let rgb: (Int, Int, Int)
                if !inFace { rgb = (35, 45, 65) }
                else if y < 20 { rgb = (32, 28, 26) }
                else if ((23..<28).contains(x) || (37..<42).contains(x)) &&
                            (25..<29).contains(y) { rgb = (50, 40, 38) }
                else if (27..<38).contains(x) && (48..<51).contains(y) {
                    rgb = (125, 63, 70)
                }
                else if decoration {
                    let value = 5 * detail
                    rgb = (210 + value, 90 + value, 60 + value)
                }
                else {
                    let value = onCheek ? 10 * detail : 0
                    rgb = (170 + value, 125 + value, 110 + value)
                }
                let offset = (y * side + x) * 4
                pixels[offset] = UInt8(rgb.0)
                pixels[offset + 1] = UInt8(rgb.1)
                pixels[offset + 2] = UInt8(rgb.2)
                pixels[offset + 3] = 255
            }
        }
        return pixels
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
            .render(image, toBitmap: &pixels, rowBytes: side * 4,
                    bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        return pixels
    }

    private func changed(_ source: [UInt8], _ output: [UInt8],
                         x: Range<Int>, y: Range<Int>) -> Int {
        y.reduce(0) { total, row in
            total + x.reduce(0) { subtotal, column in
                let offset = (row * side + column) * 4
                return subtotal + ((0..<3).contains {
                    source[offset + $0] != output[offset + $0]
                } ? 1 : 0)
            }
        }
    }

    private func alpha(_ pixels: [UInt8]) -> [UInt8] {
        stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
    }
}
