import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyWholeFaceXPositionTests: XCTestCase {
    private let width = 128
    private let height = 128

    func testSignedParameterNormalizesAndLegacyPayloadDefaultsToNeutral() throws {
        let cases: [(Float, Float)] = [
            (-2, -1), (-0.27, -0.27), (0, 0), (0.19, 0.19), (2, 1),
            (.nan, 0), (.infinity, 0), (-.infinity, 0),
        ]
        for (input, expected) in cases {
            let parameters = BeautyParameters(wholeFaceXPosition: input)
            XCTAssertEqual(parameters.wholeFaceXPosition, expected, accuracy: 0.000_001)
            XCTAssertEqual(parameters.normalized().wholeFaceXPosition, expected, accuracy: 0.000_001)
        }
        let source = BeautyParameters(faceSmall: 0.21, wholeFaceXPosition: -0.28)
        let encoded = try JSONEncoder().encode(source)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: encoded), source)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        XCTAssertEqual(
            try XCTUnwrap(object["wholeFaceXPosition"] as? Double),
            -0.28,
            accuracy: 0.000_01
        )
        object.removeValue(forKey: "wholeFaceXPosition")
        let legacy = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertEqual(legacy.wholeFaceXPosition, 0)
        XCTAssertEqual(legacy.faceSmall, 0.21, accuracy: 0.000_001)
    }

    func testPublicStillImageMovesFaceMarkerInSignedDirectionsAndProtectsExterior() throws {
        let source = makeImage()
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        let engine = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace]))
        let neutral = try engine.processResult(image: source, metadata: metadata, parameters: .init())
        let right = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceXPosition: 0.30)
        )
        let left = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceXPosition: -0.30)
        )
        let repeated = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceXPosition: 0.30)
        )
        let sourceBytes = rgba(source)
        let rightBytes = rgba(right.output)
        let leftBytes = rgba(left.output)
        XCTAssertEqual(rgba(neutral.output), sourceBytes)
        XCTAssertEqual(rightBytes, rgba(repeated.output))
        XCTAssertGreaterThan(markerCentroidX(rightBytes), markerCentroidX(sourceBytes) + 1)
        XCTAssertLessThan(markerCentroidX(leftBytes), markerCentroidX(sourceBytes) - 1)
        for output in [right.output, left.output] {
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
        XCTAssertEqual(right.metrics["beauty.effects.geometryPointCount"], 1)
        XCTAssertEqual(left.metrics["beauty.effects.geometryPointCount"], 1)
        XCTAssertEqual(right.detectionSummary?.availability, .usable)
    }

    func testMissingFaceIsSourceExactAndInvalidInputRecovers() throws {
        let source = makeImage()
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        let skipped = try noFace.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceXPosition: 0.30)
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
            parameters: .init(wholeFaceXPosition: 0.30)
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        let recovered = try engine.processResult(
            image: source, metadata: metadata,
            parameters: .init(wholeFaceXPosition: 0.30)
        )
        XCTAssertGreaterThan(markerCentroidX(rgba(recovered.output)), markerCentroidX(rgba(source)) + 1)
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
                let right = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceXPosition: 0.30)
                )
                let left = try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(wholeFaceXPosition: -0.30)
                )
                XCTAssertEqual(rgba(neutral.output), original)
                let rightBytes = rgba(right.output)
                let leftBytes = rgba(left.output)
                let first = markerCentroid(rightBytes)
                let second = markerCentroid(leftBytes)
                XCTAssertGreaterThan(
                    hypot(first.x - second.x, first.y - second.y), 2,
                    "\(orientation), mirrored=\(mirrored)"
                )
                XCTAssertEqual(right.output.extent, source.extent)
                XCTAssertEqual(left.output.extent, source.extent)
                for bytes in [rightBytes, leftBytes] {
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
                XCTAssertEqual(right.metrics["beauty.effects.geometryPointCount"], 1)
                XCTAssertEqual(left.metrics["beauty.effects.geometryPointCount"], 1)
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

    private func markerCentroidX(_ pixels: [UInt8]) -> Double {
        markerCentroid(pixels).x
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
