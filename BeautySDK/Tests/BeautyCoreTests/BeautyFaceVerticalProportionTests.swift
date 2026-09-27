import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyFaceVerticalProportionTests: XCTestCase {
    private let side = 128

    func testForeheadHeightMovesOnlyUpperMarkerInBothDirections() throws {
        try assertDirection(
            positive: .init(foreheadHeight: 0.30),
            negative: .init(foreheadHeight: -0.30),
            channel: 0, positiveDirection: -1,
            protected: [(1, 62..<67), (2, 84..<89)]
        )
    }

    func testMidfaceLengthMovesOnlyMiddleMarkerInBothDirections() throws {
        try assertDirection(
            positive: .init(midfaceLength: 0.30),
            negative: .init(midfaceLength: -0.30),
            channel: 1, positiveDirection: 1,
            protected: [(0, 37..<42), (2, 84..<89)]
        )
    }

    func testNeutralLegacyAndMissingFaceStayExact() throws {
        let source = makeImage()
        let before = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        XCTAssertEqual(rgba(try engine.processResult(
            image: source, metadata: metadata(), parameters: .init()
        ).output), before)
        let value = BeautyParameters(foreheadHeight: 0.25, midfaceLength: -0.25)
        XCTAssertEqual(value.normalized().foreheadHeight, 0.25)
        XCTAssertEqual(value.normalized().midfaceLength, -0.25)
        XCTAssertEqual(BeautyParameters(foreheadHeight: .nan).foreheadHeight, 0)
        XCTAssertEqual(BeautyParameters(midfaceLength: .infinity).midfaceLength, 0)
        let encoded = try JSONEncoder().encode(value)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: encoded), value)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "foreheadHeight")
        object.removeValue(forKey: "midfaceLength")
        let old = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertEqual(old.foreheadHeight, 0)
        XCTAssertEqual(old.midfaceLength, 0)
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        for parameters in [BeautyParameters(foreheadHeight: 0.3),
                           BeautyParameters(midfaceLength: 0.3)] {
            XCTAssertEqual(rgba(try noFace.processResult(
                image: source, metadata: metadata(), parameters: parameters
            ).output), before)
        }
    }

    func testOrientationMirrorProtectionAndTypedRecovery() throws {
        let source = makeImage()
        let before = rgba(source)
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let engine = try BeautyEngine(
                    configuration: BeautyConfiguration(maximumInputPixelCount: side * side),
                    faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
                )
                let metadata = metadata(orientation: orientation, mirrored: mirrored)
                for parameters in [BeautyParameters(foreheadHeight: 0.3),
                                   BeautyParameters(midfaceLength: 0.3)] {
                    let first = try engine.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    )
                    let after = rgba(first.output)
                    XCTAssertEqual(first.output.extent, source.extent)
                    assertExteriorAndAlpha(before: before, after: after)
                    XCTAssertEqual(rgba(try engine.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    ).output), after)
                }
                let oversized = CIImage(color: CIColor(red: 0.2, green: 0.3, blue: 0.4))
                    .cropped(to: CGRect(x: 0, y: 0, width: side + 1, height: side))
                XCTAssertThrowsError(try engine.processResult(
                    image: oversized, metadata: metadata,
                    parameters: .init(foreheadHeight: 0.3)
                )) { error in
                    XCTAssertEqual(error as? BeautyError, .invalidInput)
                }
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(foreheadHeight: 0.3)
                ).output).count, before.count)
            }
        }
    }

    private func assertDirection(
        positive: BeautyParameters, negative: BeautyParameters,
        channel: Int, positiveDirection: Double,
        protected: [(Int, Range<Int>)]
    ) throws {
        let source = makeImage()
        let before = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let plus = rgba(try engine.processResult(
            image: source, metadata: metadata(), parameters: positive
        ).output)
        let minus = rgba(try engine.processResult(
            image: source, metadata: metadata(), parameters: negative
        ).output)
        let originalY = centroidY(before, channel: channel)
        XCTAssertGreaterThan((centroidY(plus, channel: channel) - originalY) * positiveDirection, 1)
        XCTAssertLessThan((centroidY(minus, channel: channel) - originalY) * positiveDirection, -1)
        for after in [plus, minus] {
            assertExteriorAndAlpha(before: before, after: after)
            for (protectedChannel, rows) in protected {
                for y in rows {
                    for x in 62..<67 {
                        let offset = (y * side + x) * 4
                        XCTAssertEqual(after[offset + protectedChannel], before[offset + protectedChannel])
                    }
                }
            }
        }
    }

    private func metadata(
        orientation: CGImagePropertyOrientation = .up, mirrored: Bool = false
    ) -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: orientation, isInputMirrored: mirrored, source: .testFixture)
    }

    private func makeImage() -> CIImage {
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let offset = (y * side + x) * 4
                bytes[offset] = (62..<67).contains(x) && (37..<42).contains(y) ? 240 : 30
                bytes[offset + 1] = (62..<67).contains(x) && (62..<67).contains(y) ? 240 : 40
                bytes[offset + 2] = (62..<67).contains(x) && (84..<89).contains(y) ? 240 : 50
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
        var weightedY = 0.0
        var total = 0.0
        for y in 20..<105 {
            for x in 25..<103 {
                let offset = (y * side + x) * 4
                let other = channel == 0 ? 1 : 0
                let weight = Double(max(0, Int(bytes[offset + channel]) -
                    Int(bytes[offset + other]) - 40))
                weightedY += Double(y) * weight
                total += weight
            }
        }
        return weightedY / max(1, total)
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
