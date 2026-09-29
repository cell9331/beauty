import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyWholeFaceYPositionTests: XCTestCase {
    private let width = 128
    private let height = 128

    func testSignedParameterNormalizesAndLegacyPayloadDefaultsToNeutral() throws {
        let cases: [(Float, Float)] = [
            (-2, -1), (-0.27, -0.27), (0, 0), (0.19, 0.19), (2, 1),
            (.nan, 0), (.infinity, 0), (-.infinity, 0),
        ]
        for (input, expected) in cases {
            let parameters = BeautyParameters(wholeFaceYPosition: input)
            XCTAssertEqual(parameters.wholeFaceYPosition, expected, accuracy: 0.000_001)
            XCTAssertEqual(parameters.normalized().wholeFaceYPosition, expected, accuracy: 0.000_001)
        }
        let source = BeautyParameters(faceSmall: 0.21, wholeFaceYPosition: -0.28)
        let encoded = try JSONEncoder().encode(source)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: encoded), source)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        XCTAssertEqual(
            try XCTUnwrap(object["wholeFaceYPosition"] as? Double),
            -0.28,
            accuracy: 0.000_01
        )
        object.removeValue(forKey: "wholeFaceYPosition")
        let legacy = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertEqual(legacy.wholeFaceYPosition, 0)
        XCTAssertEqual(legacy.faceSmall, 0.21, accuracy: 0.000_001)
    }

    func testUnqualifiedMarkerSourceExitsWithoutMovingBackground() throws {
        let source = makeImage()
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        let engine = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace]))
        let neutral = try engine.processResult(image: source, metadata: metadata, parameters: .init())
        let down = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceYPosition: 0.30)
        )
        let up = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceYPosition: -0.30)
        )
        let repeated = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceYPosition: 0.30)
        )
        let sourceBytes = rgba(source)
        let downBytes = rgba(down.output)
        let upBytes = rgba(up.output)
        XCTAssertEqual(rgba(neutral.output), sourceBytes)
        XCTAssertEqual(downBytes, rgba(repeated.output))
        XCTAssertTrue(downBytes == sourceBytes)
        XCTAssertTrue(upBytes == sourceBytes)
        for output in [down.output, up.output] {
            XCTAssertEqual(output.extent, source.extent)
            let bytes = rgba(output)
            for y in 0..<height {
                for x in 0..<width where x < 10 || x >= width - 10 || y < 10 || y >= height - 10 {
                    let offset = (y * width + x) * 4
                    XCTAssertEqual(Array(bytes[offset..<(offset + 4)]), Array(sourceBytes[offset..<(offset + 4)]))
                }
            }
            XCTAssertTrue(stride(from: 3, to: bytes.count, by: 4).allSatisfy { bytes[$0] == 255 })
        }
        XCTAssertEqual(down.metrics["beauty.effects.geometryPointCount"], 5)
        XCTAssertEqual(up.metrics["beauty.effects.geometryPointCount"], 5)
        XCTAssertEqual(down.detectionSummary?.availability, .usable)
    }

    func testMissingFaceIsSourceExactAndInvalidInputRecovers() throws {
        let source = makeImage()
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        let skipped = try noFace.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceYPosition: 0.30)
        )
        XCTAssertEqual(rgba(skipped.output), rgba(source))
        let engine = try BeautyEngine(
            configuration: BeautyConfiguration(maximumInputPixelCount: width * height),
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let oversized = CIImage(color: CIColor(red: 0.1, green: 0.1, blue: 0.1))
            .cropped(to: CGRect(x: 0, y: 0, width: width + 1, height: height))
        XCTAssertThrowsError(try engine.processResult(
            image: oversized, metadata: metadata,
            parameters: .init(wholeFaceYPosition: 0.30)
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        let recovered = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceYPosition: 0.30)
        )
        XCTAssertTrue(rgba(recovered.output) == rgba(source))
    }

    func testOrientationAndInputMirrorKeepSignedPairDistinctAndExteriorExact() throws {
        let source = makeImage()
        let original = rgba(source)
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let metadata = BeautyInputMetadata(
                    orientation: orientation,
                    isInputMirrored: mirrored,
                    source: .testFixture
                )
                let engine = try BeautyEngine(
                    faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
                )
                let neutral = try engine.processResult(
                    image: source, metadata: metadata, parameters: .init()
                )
                let down = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceYPosition: 0.30)
                )
                let up = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceYPosition: -0.30)
                )
                XCTAssertEqual(rgba(neutral.output), original)
                let downBytes = rgba(down.output)
                let upBytes = rgba(up.output)
                let first = markerCentroid(downBytes)
                let second = markerCentroid(upBytes)
                XCTAssertEqual(first.x, second.x, accuracy: 0.01)
                XCTAssertEqual(first.y, second.y, accuracy: 0.01)
                XCTAssertTrue(downBytes == original)
                XCTAssertTrue(upBytes == original)
                XCTAssertEqual(down.output.extent, source.extent)
                XCTAssertEqual(up.output.extent, source.extent)
                for bytes in [downBytes, upBytes] {
                    for y in 0..<height {
                        for x in 0..<width where x < 10 || x >= width - 10 || y < 10 || y >= height - 10 {
                            let offset = (y * width + x) * 4
                            XCTAssertEqual(
                                Array(bytes[offset..<(offset + 4)]),
                                Array(original[offset..<(offset + 4)])
                            )
                        }
                    }
                }
                XCTAssertEqual(down.metrics["beauty.effects.geometryPointCount"], 5)
                XCTAssertEqual(up.metrics["beauty.effects.geometryPointCount"], 5)
            }
        }
    }

    private func makeImage() -> CIImage {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                pixels[offset] = (62...66).contains(x) && (62...66).contains(y) ? 230 : 30
                pixels[offset + 1] = 40
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

    private func markerCentroidY(_ pixels: [UInt8]) -> Double {
        markerCentroid(pixels).y
    }

    private func markerCentroid(_ pixels: [UInt8]) -> (x: Double, y: Double) {
        var weightedX = 0.0
        var weightedY = 0.0
        var weight = 0.0
        for y in 40..<88 {
            for x in 40..<88 {
                let offset = (y * width + x) * 4
                let signal = Double(max(0, Int(pixels[offset]) - Int(pixels[offset + 1]) - 50))
                weightedX += signal * Double(x)
                weightedY += signal * Double(y)
                weight += signal
            }
        }
        return (weightedX / max(1, weight), weightedY / max(1, weight))
    }
}
