import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyFaceShorteningTests: XCTestCase {
    private let width = 128
    private let height = 128

    func testShortFaceMovesUpperAndLowerMarkersTogetherWhileProtectingCenter() throws {
        let source = makeImage()
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let neutral = try engine.processResult(
            image: source, metadata: metadata, parameters: .init()
        )
        let shortened = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(faceShortening: 0.30)
        )
        let repeated = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(faceShortening: 0.30)
        )
        let before = rgba(source)
        let after = rgba(shortened.output)
        XCTAssertEqual(rgba(neutral.output), before)
        XCTAssertEqual(after, rgba(repeated.output))
        let upperBefore = centroid(before, channel: 0).y
        let lowerBefore = centroid(before, channel: 1).y
        let upperAfter = centroid(after, channel: 0).y
        let lowerAfter = centroid(after, channel: 1).y
        XCTAssertGreaterThan(upperAfter, upperBefore + 1)
        XCTAssertLessThan(lowerAfter, lowerBefore - 1)
        XCTAssertLessThan(lowerAfter - upperAfter, lowerBefore - upperBefore - 2)
        XCTAssertEqual(shortened.output.extent, source.extent)
        assertProtected(source: before, output: after)
    }

    func testParameterNormalizationCodableAndMissingFace() throws {
        let cases: [(Float, Float)] = [
            (-1, 0), (0, 0), (0.24, 0.24), (1.5, 1),
            (.nan, 0), (.infinity, 0),
        ]
        for (input, expected) in cases {
            let value = BeautyParameters(faceShortening: input)
            XCTAssertEqual(value.normalized().faceShortening, expected, accuracy: 0.000_001)
        }
        let parameters = BeautyParameters(faceSmall: 0.2, faceShortening: 0.3)
        let encoded = try JSONEncoder().encode(parameters)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: encoded), parameters)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "faceShortening")
        let legacy = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertEqual(legacy.faceShortening, 0)
        XCTAssertEqual(legacy.faceSmall, 0.2, accuracy: 0.000_001)

        let source = makeImage()
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        let output = try engine.processResult(
            image: source,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: .init(faceShortening: 0.3)
        )
        XCTAssertEqual(rgba(output.output), rgba(source))
    }

    func testOrientationMirrorAndTypedFailureRecover() throws {
        let source = makeImage()
        let before = rgba(source)
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let metadata = BeautyInputMetadata(
                    orientation: orientation, isInputMirrored: mirrored,
                    source: .testFixture
                )
                let engine = try BeautyEngine(
                    configuration: BeautyConfiguration(maximumInputPixelCount: width * height),
                    faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
                )
                let output = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(faceShortening: 0.3)
                )
                let rendered = rgba(output.output)
                XCTAssertEqual(output.output.extent, source.extent)
                assertProtected(source: before, output: rendered)
                let oversized = CIImage(color: CIColor(red: 0.2, green: 0.3, blue: 0.4))
                    .cropped(to: CGRect(x: 0, y: 0, width: width + 1, height: height))
                XCTAssertThrowsError(try engine.processResult(
                    image: oversized, metadata: metadata,
                    parameters: .init(faceShortening: 0.3)
                )) { error in
                    XCTAssertEqual(error as? BeautyError, .invalidInput)
                }
                XCTAssertEqual(try rgba(engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(faceShortening: 0.3)
                ).output), rendered)
            }
        }
    }

    private func makeImage() -> CIImage {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                pixels[offset] = (62...66).contains(x) && (41...45).contains(y) ? 240 : 30
                pixels[offset + 1] = (62...66).contains(x) && (91...95).contains(y) ? 240 : 40
                pixels[offset + 2] = (62...66).contains(x) && (66...70).contains(y) ? 240 : 50
                pixels[offset + 3] = 255
            }
        }
        return CIImage(
            bitmapData: Data(pixels), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).render(
            image, toBitmap: &pixels, rowBytes: width * 4,
            bounds: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8, colorSpace: space
        )
        return pixels
    }

    private func centroid(_ pixels: [UInt8], channel: Int) -> (x: Double, y: Double) {
        var sumX = 0.0
        var sumY = 0.0
        var weight = 0.0
        for y in 28..<105 {
            for x in 28..<100 {
                let offset = (y * width + x) * 4
                let signal = max(0, Int(pixels[offset + channel]) -
                    Int(pixels[offset + (channel == 0 ? 1 : 0)]) - 40)
                sumX += Double(signal * x)
                sumY += Double(signal * y)
                weight += Double(signal)
            }
        }
        return (sumX / max(1, weight), sumY / max(1, weight))
    }

    private func assertProtected(source: [UInt8], output: [UInt8],
                                 file: StaticString = #filePath, line: UInt = #line) {
        for y in 0..<height {
            for x in 0..<width where x < 12 || x >= width - 12 ||
                y < 12 || y >= height - 12 ||
                ((62...66).contains(x) && (66...70).contains(y)) {
                let offset = (y * width + x) * 4
                XCTAssertEqual(Array(output[offset..<(offset + 4)]),
                               Array(source[offset..<(offset + 4)]), file: file, line: line)
            }
        }
        XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy {
            output[$0] == 255
        }, file: file, line: line)
    }
}
