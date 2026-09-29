import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyFaceSymmetryAndChinTests: XCTestCase {
    private let side = 128

    func testObservedAsymmetryChangesPublicPixelsInsideFaceAndProtectsExterior() throws {
        let source = makeImage(textured: true)
        let before = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let after = rgba(try engine.processResult(
            image: source, metadata: metadata(),
            parameters: .init(wholeFaceSymmetry: 0.25)
        ).output)
        let changed = changedCount(before, after, x: 25..<103, y: 45..<100)
        XCTAssertGreaterThan(changed, 10)
        assertExteriorAndAlpha(before, after)
        XCTAssertEqual(rgba(try engine.processResult(
            image: source, metadata: metadata(),
            parameters: .init(wholeFaceSymmetry: 0.25)
        ).output), after)
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        XCTAssertEqual(rgba(try noFace.processResult(
            image: source, metadata: metadata(),
            parameters: .init(wholeFaceSymmetry: 0.25)
        ).output), before)
    }

    func testNeutralCodableOrientationNoFaceAndTypedRecovery() throws {
        let source = makeImage(textured: false)
        let before = rgba(source)
        let values = [
            BeautyParameters(wholeFaceSymmetry: 0.25),
            BeautyParameters(doubleChinReduction: 0.25),
            BeautyParameters(doubleChinReductionPro: 0.25),
        ]
        for value in values {
            XCTAssertEqual(try JSONDecoder().decode(
                BeautyParameters.self, from: JSONEncoder().encode(value)
            ), value)
        }
        XCTAssertEqual(BeautyParameters(wholeFaceSymmetry: .nan).wholeFaceSymmetry, 0)
        XCTAssertEqual(BeautyParameters(doubleChinReduction: -.infinity).doubleChinReduction, 0)
        XCTAssertEqual(BeautyParameters(doubleChinReductionPro: .infinity).doubleChinReductionPro, 0)
        var legacy = try XCTUnwrap(JSONSerialization.jsonObject(
            with: JSONEncoder().encode(BeautyParameters())
        ) as? [String: Any])
        for key in ["wholeFaceSymmetry", "doubleChinReduction", "doubleChinReductionPro"] {
            legacy.removeValue(forKey: key)
        }
        XCTAssertEqual(try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: legacy)
        ), BeautyParameters())
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let engine = try BeautyEngine(
                    configuration: .init(maximumInputPixelCount: side * side),
                    faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
                )
                let metadata = metadata(orientation: orientation, mirrored: mirrored)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: .init()
                ).output), before)
                for value in values {
                    let result = try engine.processResult(
                        image: source, metadata: metadata, parameters: value
                    )
                    XCTAssertEqual(result.output.extent, source.extent)
                    let after = rgba(result.output)
                    assertExteriorAndAlpha(before, after)
                    XCTAssertEqual(rgba(try engine.processResult(
                        image: source, metadata: metadata, parameters: value
                    ).output), after)
                }
                let tooLarge = source.transformed(by: .init(scaleX: 2, y: 2))
                XCTAssertThrowsError(try engine.processResult(
                    image: tooLarge, metadata: metadata,
                    parameters: .init(doubleChinReduction: 0.25)
                )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: .init(doubleChinReduction: 0.25)
                ).output).count, before.count)
            }
        }
    }

    private func metadata(
        orientation: CGImagePropertyOrientation = .up, mirrored: Bool = false
    ) -> BeautyInputMetadata {
        .init(orientation: orientation, isInputMirrored: mirrored, source: .testFixture)
    }

    private func makeImage(textured: Bool) -> CIImage {
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let offset = (y * side + x) * 4
                let checker = textured && (25..<103).contains(x) && (45..<100).contains(y)
                    ? ((x / 3 + y / 3) % 2 == 0 ? 90 : 45) : 0
                bytes[offset] = (61...66).contains(x) && (99...104).contains(y) ? 240 :
                    UInt8(30 + checker)
                bytes[offset + 1] = ((48...52).contains(x) || (76...80).contains(x)) &&
                    (90...94).contains(y) ? 240 : UInt8(40 + checker)
                bytes[offset + 2] = (61...66).contains(x) && (74...79).contains(y) ? 240 :
                    UInt8(50 + checker)
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

    private func changedCount(_ before: [UInt8], _ after: [UInt8],
                              x: Range<Int>, y: Range<Int>) -> Int {
        var changed = 0
        for row in y {
            for column in x {
                let offset = (row * side + column) * 4
                if before[offset..<(offset + 3)] != after[offset..<(offset + 3)] {
                    changed += 1
                }
            }
        }
        return changed
    }

    private func assertExteriorAndAlpha(_ before: [UInt8], _ after: [UInt8],
                                        file: StaticString = #filePath, line: UInt = #line) {
        for y in 0..<side {
            for x in 0..<side where x < 12 || x >= side - 12 || y < 12 || y >= side - 12 {
                let offset = (y * side + x) * 4
                XCTAssertEqual(Array(after[offset..<(offset + 4)]),
                               Array(before[offset..<(offset + 4)]), file: file, line: line)
            }
        }
        XCTAssertTrue(stride(from: 3, to: after.count, by: 4).allSatisfy { after[$0] == 255 },
                      file: file, line: line)
    }
}
