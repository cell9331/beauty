import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyHeadRegionControlsTests: XCTestCase {
    private let side = 128

    func testIndependentGeneratedTargetDirectionsAndProtectedPixels() throws {
        try assertDirection(
            marker: (45, 47), parameter: .init(headSmall: 0.30),
            axis: .x, sign: 1
        )
        try assertDirection(
            marker: (43, 37), parameter: .init(headWrap: 0.25),
            axis: .x, sign: -1
        )
        try assertDirection(
            marker: (64, 20), parameter: .init(cranialCrownHeight: 0.25),
            axis: .y, sign: -1
        )
        try assertDirection(
            marker: (64, 20), parameter: .init(cranialCrownHeight: -0.25),
            axis: .y, sign: 1
        )
        try assertDirection(
            marker: (54, 32), parameter: .init(hairlineHeight: 0.25),
            axis: .y, sign: 1
        )
        try assertDirection(
            marker: (54, 32), parameter: .init(hairlineHeight: -0.25),
            axis: .y, sign: -1
        )
    }

    func testGeneratedPortraitHeadAndHairBoundariesMoveInBothSkinVariants() throws {
        let cases: [((Int, Int), BeautyParameters, Axis, Double)] = [
            ((45, 47), .init(headSmall: 0.30), .x, 1),
            ((43, 37), .init(headWrap: 0.25), .x, -1),
            ((64, 20), .init(cranialCrownHeight: 0.25), .y, -1),
            ((64, 20), .init(cranialCrownHeight: -0.25), .y, 1),
            ((54, 32), .init(hairlineHeight: 0.25), .y, 1),
            ((54, 32), .init(hairlineHeight: -0.25), .y, -1),
        ]
        for deepSkin in [false, true] {
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            for (marker, parameters, axis, sign) in cases {
                let source = makePortraitImage(marker: marker, deepSkin: deepSkin)
                let original = rgba(source)
                let beforeCenter = centroid(original, near: marker)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata(), parameters: .init()
                ).output), original)
                let result = try engine.processResult(
                    image: source, metadata: metadata(), parameters: parameters
                )
                let output = rgba(result.output)
                let afterCenter = centroid(output, near: marker)
                let displacement = axis == .x ? afterCenter.0 - beforeCenter.0 :
                    afterCenter.1 - beforeCenter.1
                XCTAssertGreaterThan(displacement * sign, 0.15)
                XCTAssertEqual(result.output.extent, source.extent)
                assertProtection(original, output)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata(), parameters: parameters
                ).output), output)
                XCTAssertEqual(rgba(try noFace.processResult(
                    image: source, metadata: metadata(), parameters: parameters
                ).output), original)
            }
        }
    }

    func testNeutralLegacyNoFaceOrientationRepeatAndTypedRecovery() throws {
        let source = makeImage(marker: (45, 47))
        let original = rgba(source)
        let parameters: [BeautyParameters] = [
            .init(headSmall: 0.30), .init(headWrap: 0.25),
            .init(cranialCrownHeight: 0.25), .init(hairlineHeight: 0.25),
        ]
        for value in parameters {
            XCTAssertEqual(try JSONDecoder().decode(
                BeautyParameters.self, from: JSONEncoder().encode(value)
            ), value)
        }
        XCTAssertEqual(BeautyParameters(headSmall: -.infinity).headSmall, 0)
        XCTAssertEqual(BeautyParameters(headWrap: .nan).headWrap, 0)
        XCTAssertEqual(BeautyParameters(cranialCrownHeight: .infinity).cranialCrownHeight, 0)
        XCTAssertEqual(BeautyParameters(hairlineHeight: .nan).hairlineHeight, 0)
        var old = try XCTUnwrap(JSONSerialization.jsonObject(
            with: JSONEncoder().encode(BeautyParameters())
        ) as? [String: Any])
        for key in ["headSmall", "headWrap", "cranialCrownHeight", "hairlineHeight"] {
            old.removeValue(forKey: key)
        }
        XCTAssertEqual(try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: old)
        ), BeautyParameters())
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        for value in parameters {
            XCTAssertEqual(rgba(try noFace.processResult(
                image: source, metadata: metadata(), parameters: value
            ).output), original)
        }
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let engine = try BeautyEngine(
                    configuration: .init(maximumInputPixelCount: side * side),
                    faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
                )
                let meta = metadata(orientation: orientation, mirrored: mirrored)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: meta, parameters: .init()
                ).output), original)
                for value in parameters {
                    let first = try engine.processResult(
                        image: source, metadata: meta, parameters: value
                    )
                    XCTAssertEqual(first.output.extent, source.extent)
                    let after = rgba(first.output)
                    assertProtection(original, after)
                    XCTAssertEqual(rgba(try engine.processResult(
                        image: source, metadata: meta, parameters: value
                    ).output), after)
                }
                let tooLarge = source.transformed(by: .init(scaleX: 2, y: 2))
                XCTAssertThrowsError(try engine.processResult(
                    image: tooLarge, metadata: meta, parameters: .init(headSmall: 0.3)
                )) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: meta, parameters: .init(headSmall: 0.3)
                ).output).count, original.count)
            }
        }
    }

    private enum Axis { case x, y }

    private func assertDirection(
        marker: (Int, Int), parameter: BeautyParameters, axis: Axis, sign: Double
    ) throws {
        let source = makeImage(marker: marker)
        let original = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let after = rgba(try engine.processResult(
            image: source, metadata: metadata(), parameters: parameter
        ).output)
        let beforeCenter = centroid(original, near: marker)
        let afterCenter = centroid(after, near: marker)
        let difference = axis == .x ? afterCenter.0 - beforeCenter.0 :
            afterCenter.1 - beforeCenter.1
        XCTAssertGreaterThan(difference * sign, 0.15)
        assertProtection(original, after)
    }

    private func metadata(
        orientation: CGImagePropertyOrientation = .up, mirrored: Bool = false
    ) -> BeautyInputMetadata {
        .init(orientation: orientation, isInputMirrored: mirrored, source: .testFixture)
    }

    private func makeImage(marker: (Int, Int)) -> CIImage {
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let offset = (y * side + x) * 4
                bytes[offset] = abs(x - marker.0) <= 2 && abs(y - marker.1) <= 2 ? 240 : 30
                bytes[offset + 1] = 40
                bytes[offset + 2] = (62...66).contains(x) && (68...72).contains(y) ? 240 : 50
                bytes[offset + 3] = 255
            }
        }
        return CIImage(
            bitmapData: Data(bytes), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private func makePortraitImage(marker: (Int, Int), deepSkin: Bool) -> CIImage {
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = Double(x - 64) / 37
                let dy = Double(y - 63) / 49
                let insideHead = dx * dx + dy * dy <= 1
                let eye = (52...55).contains(y) &&
                    ((47...53).contains(x) || (75...81).contains(x))
                let nose = (65...75).contains(y) && (62...66).contains(x)
                let mouth = (83...86).contains(y) && (53...75).contains(x)
                let skin: (UInt8, UInt8, UInt8) = deepSkin ? (90, 77, 68) : (157, 132, 116)
                let rgb: (UInt8, UInt8, UInt8)
                if abs(x - marker.0) <= 2 && abs(y - marker.1) <= 2 {
                    rgb = (240, 40, 50)
                } else if (62...66).contains(x) && (68...72).contains(y) {
                    rgb = (30, 40, 240)
                } else if !insideHead {
                    rgb = (30, 40, 50)
                } else if y < 35 {
                    rgb = (35, 33, 32)
                } else if eye || nose {
                    rgb = (45, 40, 38)
                } else if mouth {
                    rgb = (110, 70, 75)
                } else {
                    rgb = skin
                }
                let offset = (y * side + x) * 4
                bytes[offset] = rgb.0
                bytes[offset + 1] = rgb.1
                bytes[offset + 2] = rgb.2
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

    private func centroid(_ bytes: [UInt8], near marker: (Int, Int)) -> (Double, Double) {
        var xTotal = 0.0
        var yTotal = 0.0
        var weightTotal = 0.0
        for y in max(0, marker.1 - 12)..<min(side, marker.1 + 13) {
            for x in max(0, marker.0 - 12)..<min(side, marker.0 + 13) {
                let offset = (y * side + x) * 4
                let weight = Double(max(0, Int(bytes[offset]) - Int(bytes[offset + 1]) - 40))
                xTotal += Double(x) * weight
                yTotal += Double(y) * weight
                weightTotal += weight
            }
        }
        return (xTotal / max(1, weightTotal), yTotal / max(1, weightTotal))
    }

    private func assertProtection(_ before: [UInt8], _ after: [UInt8],
                                  file: StaticString = #filePath, line: UInt = #line) {
        for y in 0..<side {
            for x in 0..<side where x < 12 || x >= side - 12 || y < 12 || y >= side - 12 ||
                ((62...66).contains(x) && (68...72).contains(y)) {
                let offset = (y * side + x) * 4
                XCTAssertEqual(Array(after[offset..<(offset + 4)]),
                               Array(before[offset..<(offset + 4)]), file: file, line: line)
            }
        }
        XCTAssertTrue(stride(from: 3, to: after.count, by: 4).allSatisfy { after[$0] == 255 },
                      file: file, line: line)
    }
}
