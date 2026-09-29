import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyLowerVerticalProportionTests: XCTestCase {
    private let side = 128

    func testSignedLowerFaceMovesGeneratedMarkerAndProtectsUpperMarker() throws {
        let source = makeImage()
        let original = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        // The 128-pixel upper marker is too close to the synthetic nose
        // support for a nose-protected philtrum oracle. The registered
        // 512-pixel portrait suite covers that visible gap and protection.
        for (channel, positive, negative, protectedRow) in [
            (1, BeautyParameters(lowerFaceLength: 0.30),
             BeautyParameters(lowerFaceLength: -0.30), 77),
        ] {
            let plus = rgba(try engine.processResult(
                image: source, metadata: metadata(), parameters: positive
            ).output)
            let minus = rgba(try engine.processResult(
                image: source, metadata: metadata(), parameters: negative
            ).output)
            XCTAssertGreaterThan(centroidY(plus, channel: channel),
                                 centroidY(original, channel: channel))
            XCTAssertLessThan(centroidY(minus, channel: channel),
                              centroidY(original, channel: channel))
            for after in [plus, minus] {
                assertExteriorAndAlpha(before: original, after: after)
                for y in (protectedRow - 2)...(protectedRow + 2) {
                    for x in 62...66 {
                        let offset = (y * side + x) * 4
                        let protectedChannel = channel == 0 ? 1 : 0
                        XCTAssertEqual(after[offset + protectedChannel],
                                       original[offset + protectedChannel])
                    }
                }
            }
        }
    }

    func testNeutralCodableNoFaceAndTypedRecovery() throws {
        let source = makeImage()
        let original = rgba(source)
        let value = BeautyParameters(philtrumLength: 0.3, lowerFaceLength: -0.3)
        XCTAssertEqual(value.normalized(), value)
        XCTAssertEqual(BeautyParameters(philtrumLength: .nan).philtrumLength, 0)
        XCTAssertEqual(BeautyParameters(lowerFaceLength: .infinity).lowerFaceLength, 0)
        let encoded = try JSONEncoder().encode(value)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: encoded), value)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "philtrumLength")
        object.removeValue(forKey: "lowerFaceLength")
        let legacy = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertEqual(legacy.philtrumLength, 0)
        XCTAssertEqual(legacy.lowerFaceLength, 0)
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        for parameters in [BeautyParameters(philtrumLength: 0.3),
                           BeautyParameters(lowerFaceLength: 0.3)] {
            XCTAssertEqual(rgba(try noFace.processResult(
                image: source, metadata: metadata(), parameters: parameters
            ).output), original)
        }
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let engine = try BeautyEngine(
                    configuration: .init(maximumInputPixelCount: side * side),
                    faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
                )
                let metadata = metadata(orientation: orientation, mirrored: mirrored)
                for parameters in [BeautyParameters(philtrumLength: 0.3),
                                   BeautyParameters(lowerFaceLength: 0.3)] {
                    let first = try engine.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    )
                    XCTAssertEqual(first.output.extent, source.extent)
                    let after = rgba(first.output)
                    assertExteriorAndAlpha(before: original, after: after)
                    XCTAssertEqual(rgba(try engine.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    ).output), after)
                }
                let tooLarge = source.transformed(by: CGAffineTransform(scaleX: 2, y: 2))
                XCTAssertThrowsError(try engine.processResult(
                    image: tooLarge, metadata: metadata,
                    parameters: .init(philtrumLength: 0.3)
                )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(philtrumLength: 0.3)
                ).output).count, original.count)
            }
        }
    }

    private func metadata(
        orientation: CGImagePropertyOrientation = .up, mirrored: Bool = false
    ) -> BeautyInputMetadata {
        .init(orientation: orientation, isInputMirrored: mirrored, source: .testFixture)
    }

    private func makeImage() -> CIImage {
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let offset = (y * side + x) * 4
                bytes[offset] = (62...66).contains(x) && (75...79).contains(y) ? 240 : 30
                bytes[offset + 1] = (62...66).contains(x) && (91...95).contains(y) ? 240 : 40
                bytes[offset + 2] = 50
                bytes[offset + 3] = 255
            }
        }
        return CIImage(
            bitmapData: Data(bytes), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).render(
            image, toBitmap: &bytes, rowBytes: side * 4,
            bounds: CGRect(x: 0, y: 0, width: side, height: side),
            format: .RGBA8, colorSpace: space
        )
        return bytes
    }

    private func centroidY(_ bytes: [UInt8], channel: Int) -> Double {
        var weighted = 0.0
        var total = 0.0
        for y in 60..<110 {
            for x in 35..<95 {
                let offset = (y * side + x) * 4
                let other = channel == 0 ? 1 : 0
                let weight = Double(max(0, Int(bytes[offset + channel]) -
                    Int(bytes[offset + other]) - 40))
                weighted += Double(y) * weight
                total += weight
            }
        }
        return weighted / max(1, total)
    }

    private func assertExteriorAndAlpha(before: [UInt8], after: [UInt8],
                                        file: StaticString = #filePath, line: UInt = #line) {
        for y in 0..<side {
            for x in 0..<side where x < 12 || x >= side - 12 || y < 12 || y >= side - 12 {
                let offset = (y * side + x) * 4
                XCTAssertEqual(Array(after[offset..<(offset + 4)]),
                               Array(before[offset..<(offset + 4)]), file: file, line: line)
            }
        }
        XCTAssertTrue(stride(from: 3, to: after.count, by: 4).allSatisfy {
            after[$0] == 255
        }, file: file, line: line)
    }
}
