import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyWholeFaceTiltTests: XCTestCase {
    private let width = 128
    private let height = 128

    func testSignedTiltRotatesTwoFaceMarkersAndProtectsExterior() throws {
        let source = makeImage()
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let neutral = try engine.processResult(
            image: source, metadata: metadata, parameters: .init()
        )
        let clockwise = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceTilt: 0.30)
        )
        let counterclockwise = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceTilt: -0.30)
        )
        let repeatClockwise = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceTilt: 0.30)
        )
        let original = rgba(source)
        let positive = rgba(clockwise.output)
        let negative = rgba(counterclockwise.output)
        XCTAssertEqual(rgba(neutral.output), original)
        XCTAssertEqual(positive, rgba(repeatClockwise.output))
        XCTAssertGreaterThan(centroid(positive, red: true).x, centroid(original, red: true).x + 1)
        XCTAssertLessThan(centroid(negative, red: true).x, centroid(original, red: true).x - 1)
        XCTAssertLessThan(centroid(positive, red: false).y, centroid(original, red: false).y - 1)
        XCTAssertGreaterThan(centroid(negative, red: false).y, centroid(original, red: false).y + 1)
        for output in [clockwise.output, counterclockwise.output] {
            XCTAssertEqual(output.extent, source.extent)
            let pixels = rgba(output)
            for y in 0..<height {
                for x in 0..<width where x < 12 || x >= width - 12 || y < 12 || y >= height - 12 {
                    let offset = (y * width + x) * 4
                    XCTAssertEqual(
                        Array(pixels[offset..<(offset + 4)]),
                        Array(original[offset..<(offset + 4)])
                    )
                }
            }
            XCTAssertTrue(stride(from: 3, to: pixels.count, by: 4).allSatisfy { pixels[$0] == 255 })
        }
    }

    func testTiltParameterRoundTripsAndMissingFaceFailsClosed() throws {
        let cases: [(Float, Float)] = [
            (-2, -1), (-0.24, -0.24), (0, 0), (0.24, 0.24), (2, 1),
            (.nan, 0), (.infinity, 0), (-.infinity, 0),
        ]
        for (input, expected) in cases {
            let value = BeautyParameters(wholeFaceTilt: input)
            XCTAssertEqual(value.wholeFaceTilt, expected, accuracy: 0.000_001)
            XCTAssertEqual(value.normalized().wholeFaceTilt, expected, accuracy: 0.000_001)
        }
        let parameters = BeautyParameters(faceSmall: 0.2, wholeFaceTilt: -0.3)
        let encoded = try JSONEncoder().encode(parameters)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: encoded), parameters)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "wholeFaceTilt")
        let legacy = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertEqual(legacy.wholeFaceTilt, 0)
        XCTAssertEqual(legacy.faceSmall, 0.2, accuracy: 0.000_001)

        let source = makeImage()
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        let result = try noFace.processResult(
            image: source,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: .init(wholeFaceTilt: 0.30)
        )
        XCTAssertEqual(rgba(result.output), rgba(source))
    }

    func testOrientationMirrorAndTypedFailureRecoverWithoutChangingTiltDirection() throws {
        let source = makeImage()
        let original = rgba(source)
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
                let positive = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceTilt: 0.30)
                )
                let negative = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceTilt: -0.30)
                )
                let positiveBytes = rgba(positive.output)
                let negativeBytes = rgba(negative.output)
                let positiveMarker = centroid(positiveBytes, red: true)
                let negativeMarker = centroid(negativeBytes, red: true)
                XCTAssertGreaterThan(
                    hypot(positiveMarker.x - negativeMarker.x,
                          positiveMarker.y - negativeMarker.y),
                    1.5
                )
                XCTAssertEqual(positive.output.extent, source.extent)
                XCTAssertEqual(negative.output.extent, source.extent)
                for pixels in [positiveBytes, negativeBytes] {
                    for y in 0..<height {
                        for x in 0..<width where x < 12 || x >= width - 12 || y < 12 || y >= height - 12 {
                            let offset = (y * width + x) * 4
                            XCTAssertEqual(
                                Array(pixels[offset..<(offset + 4)]),
                                Array(original[offset..<(offset + 4)])
                            )
                        }
                    }
                }
                let oversized = CIImage(color: CIColor(red: 0.1, green: 0.1, blue: 0.1))
                    .cropped(to: CGRect(x: 0, y: 0, width: width + 1, height: height))
                XCTAssertThrowsError(try engine.processResult(
                    image: oversized, metadata: metadata,
                    parameters: .init(wholeFaceTilt: 0.30)
                )) { error in
                    XCTAssertEqual(error as? BeautyError, .invalidInput)
                }
                let recovered = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceTilt: 0.30)
                )
                XCTAssertEqual(rgba(recovered.output), positiveBytes)
            }
        }
    }

    private func makeImage() -> CIImage {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                pixels[offset] = (62...66).contains(x) && (39...43).contains(y) ? 240 : 30
                pixels[offset + 1] = (46...50).contains(x) && (62...66).contains(y) ? 240 : 40
                pixels[offset + 2] = 50
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
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image, toBitmap: &pixels, rowBytes: width * 4,
            bounds: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8, colorSpace: space
        )
        return pixels
    }

    private func centroid(_ pixels: [UInt8], red: Bool) -> (x: Double, y: Double) {
        var sumX = 0.0
        var sumY = 0.0
        var weight = 0.0
        for y in 28..<100 {
            for x in 28..<100 {
                let offset = (y * width + x) * 4
                let signal = red
                    ? max(0, Int(pixels[offset]) - Int(pixels[offset + 1]) - 40)
                    : max(0, Int(pixels[offset + 1]) - Int(pixels[offset]) - 40)
                sumX += Double(signal * x)
                sumY += Double(signal * y)
                weight += Double(signal)
            }
        }
        return (sumX / max(1, weight), sumY / max(1, weight))
    }
}
