import CoreGraphics
import CoreImage
import ImageIO
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

    func testRequestMaskProtectsSameColorDecorationWithoutDisablingCheekTexture() throws {
        let source = portrait(sameColorDecoration: true)
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: colorSpace
        )
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.textureFace])
        )
        var bytes = [UInt8](repeating: 0, count: side * side)
        for y in 34..<41 {
            for x in 38..<45 { bytes[y * side + x] = 255 }
        }
        let mask = try BeautyTextureExclusionMask(width: side, height: side, bytes: bytes)
        XCTAssertEqual(Mirror(reflecting: mask).children.compactMap(\.label),
                       ["width", "height"])

        for parameters in [
            BeautyParameters(skinSmoothing: 1),
            BeautyParameters(skinSharpen: 1),
        ] {
            let withoutMask = rgba(try engine.processResult(
                image: image, metadata: metadata, parameters: parameters
            ).output)
            XCTAssertGreaterThan(changed(source, withoutMask, x: 40..<43, y: 36..<39), 0)

            let result = try engine.processResult(
                image: image, metadata: metadata, parameters: parameters,
                textureExclusionMask: mask
            )
            let protected = rgba(result.output)
            XCTAssertEqual(result.output.extent, image.extent)
            XCTAssertEqual(changed(source, protected, x: 38..<45, y: 34..<41), 0)
            XCTAssertGreaterThan(changed(source, protected, x: 22..<28, y: 36..<42), 0)
            for index in bytes.indices where bytes[index] == 0 {
                let offset = index * 4
                XCTAssertEqual(Array(protected[offset..<(offset + 4)]),
                               Array(withoutMask[offset..<(offset + 4)]))
            }
            XCTAssertEqual(alpha(protected), alpha(source))
            XCTAssertEqual(protected, rgba(try engine.processResult(
                image: image, metadata: metadata, parameters: parameters,
                textureExclusionMask: mask
            ).output))
        }

        XCTAssertThrowsError(try BeautyTextureExclusionMask(
            width: side, height: side, bytes: [UInt8](repeating: 127, count: side * side)
        )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
        let wrongSize = try BeautyTextureExclusionMask(
            width: side - 1, height: side,
            bytes: [UInt8](repeating: 0, count: (side - 1) * side)
        )
        XCTAssertThrowsError(try engine.processResult(
            image: image, metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1),
            textureExclusionMask: wrongSize
        )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
    }

    func testMaskUsesCanonicalGridAfterOrientationAndInputMirror() throws {
        let inputWidth = side
        let inputHeight = 48
        let source = Array(portrait(sameColorDecoration: true).prefix(inputWidth * inputHeight * 4))
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: inputWidth * 4,
            size: CGSize(width: inputWidth, height: inputHeight), format: .RGBA8,
            colorSpace: colorSpace
        )
        let metadata = BeautyInputMetadata(
            orientation: .right, isInputMirrored: true, source: .testFixture
        )
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.textureFace])
        )
        let mask = try BeautyTextureExclusionMask(
            width: inputHeight, height: inputWidth,
            bytes: [UInt8](repeating: 255, count: inputWidth * inputHeight)
        )
        let neutral = try engine.processResult(
            image: image, metadata: metadata, parameters: .init(),
            textureExclusionMask: mask
        )
        let smoothed = try engine.processResult(
            image: image, metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1),
            textureExclusionMask: mask
        )
        XCTAssertEqual(smoothed.output.extent,
                       CGRect(x: 0, y: 0, width: inputHeight, height: inputWidth))
        XCTAssertEqual(rgba(smoothed.output, width: inputHeight, height: inputWidth),
                       rgba(neutral.output, width: inputHeight, height: inputWidth))

        let wrongGrid = try BeautyTextureExclusionMask(
            width: inputWidth, height: inputHeight,
            bytes: [UInt8](repeating: 255, count: inputWidth * inputHeight)
        )
        XCTAssertThrowsError(try engine.processResult(
            image: image, metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1),
            textureExclusionMask: wrongGrid
        )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
    }

    func testEncodedImageMaskProtectsDecorationAndRecoversAfterWrongGrid() throws {
        let source = portrait(sameColorDecoration: true)
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: colorSpace
        )
        let context = CIContext(options: [
            .workingColorSpace: colorSpace, .outputColorSpace: colorSpace
        ])
        let cgImage = try XCTUnwrap(context.createCGImage(image, from: image.extent))
        let encoded = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(
            encoded as CFMutableData, "public.png" as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, cgImage, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))

        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.textureFace])
        )
        let parameters = BeautyParameters(skinSmoothing: 1)
        var bytes = [UInt8](repeating: 0, count: side * side)
        for y in 34..<41 {
            for x in 38..<45 { bytes[y * side + x] = 255 }
        }
        let mask = try BeautyTextureExclusionMask(
            width: side, height: side, bytes: bytes
        )
        let wrongGrid = try BeautyTextureExclusionMask(
            width: side - 1, height: side,
            bytes: [UInt8](repeating: 0, count: (side - 1) * side)
        )
        let neutral = rgba(try engine.processResult(
            encodedImageData: encoded as Data, metadata: metadata, parameters: .init()
        ).output)
        let unmasked = rgba(try engine.processResult(
            encodedImageData: encoded as Data, metadata: metadata,
            parameters: parameters
        ).output)
        XCTAssertGreaterThan(changed(neutral, unmasked, x: 40..<43, y: 36..<39), 0)

        XCTAssertThrowsError(try engine.processResult(
            encodedImageData: encoded as Data, metadata: metadata,
            parameters: parameters, textureExclusionMask: wrongGrid
        )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }

        let protected = try engine.processResult(
            encodedImageData: encoded as Data, metadata: metadata,
            parameters: parameters, textureExclusionMask: mask
        )
        let output = rgba(protected.output)
        XCTAssertEqual(protected.output.extent, image.extent)
        XCTAssertEqual(changed(neutral, output, x: 38..<45, y: 34..<41), 0)
        XCTAssertGreaterThan(changed(neutral, output, x: 22..<28, y: 36..<42), 0)
        XCTAssertEqual(alpha(output), alpha(neutral))
        XCTAssertEqual(output, rgba(try engine.processResult(
            encodedImageData: encoded as Data, metadata: metadata,
            parameters: parameters, textureExclusionMask: mask
        ).output))
    }

    private func portrait(sameColorDecoration: Bool = false) -> [UInt8] {
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
                    if sameColorDecoration {
                        let value = 10 * detail
                        rgb = (170 + value, 125 + value, 110 + value)
                    } else {
                        let value = 5 * detail
                        rgb = (210 + value, 90 + value, 60 + value)
                    }
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

    private func rgba(_ image: CIImage, width: Int = 64, height: Int = 64) -> [UInt8] {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
            .render(image, toBitmap: &pixels, rowBytes: width * 4,
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
