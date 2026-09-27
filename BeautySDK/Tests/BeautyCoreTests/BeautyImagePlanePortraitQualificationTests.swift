import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

/// Portrait-shaped generated pixels complement the isolated marker and provider
/// oracles. They qualify only the documented two-dimensional image-plane scope.
final class BeautyImagePlanePortraitQualificationTests: XCTestCase {
    private let side = 128
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testWholeFaceTranslationsAndTiltOnGeneratedPortraits() throws {
        for deepSkin in [false, true] {
            try assertDirection(.init(wholeFaceYPosition: 0.30),
                                marker: (64, 64), axis: .y, sign: 1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceYPosition: -0.30),
                                marker: (64, 64), axis: .y, sign: -1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceXPosition: 0.30),
                                marker: (64, 64), axis: .x, sign: 1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceXPosition: -0.30),
                                marker: (64, 64), axis: .x, sign: -1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: 0.30),
                                marker: (64, 41), axis: .x, sign: 1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: -0.30),
                                marker: (64, 41), axis: .x, sign: -1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: 0.30),
                                marker: (48, 64), axis: .y, sign: -1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: -0.30),
                                marker: (48, 64), axis: .y, sign: 1,
                                minimum: 1, deepSkin: deepSkin)
        }
    }

    func testVerticalProportionsOnGeneratedPortraits() throws {
        for deepSkin in [false, true] {
            for (value, marker, sign, minimum) in [
                (BeautyParameters(foreheadHeight: 0.30), (64, 39), -1.0, 1.0),
                (BeautyParameters(foreheadHeight: -0.30), (64, 39), 1.0, 1.0),
                (BeautyParameters(midfaceLength: 0.30), (64, 64), 1.0, 1.0),
                (BeautyParameters(midfaceLength: -0.30), (64, 64), -1.0, 1.0),
                (BeautyParameters(philtrumLength: 0.30), (64, 77), 1.0, 0.0),
                (BeautyParameters(philtrumLength: -0.30), (64, 77), -1.0, 0.0),
                (BeautyParameters(lowerFaceLength: 0.30), (64, 93), 1.0, 0.0),
                (BeautyParameters(lowerFaceLength: -0.30), (64, 93), -1.0, 0.0),
                (BeautyParameters(faceShortening: 0.30), (64, 43), 1.0, 1.0),
                (BeautyParameters(faceShortening: 0.30), (64, 93), -1.0, 1.0),
            ] {
                try assertDirection(value, marker: marker, axis: .y,
                                    sign: sign, minimum: minimum,
                                    deepSkin: deepSkin)
            }
        }
    }

    func testChinTiersAndSymmetryOnGeneratedPortraits() throws {
        for deepSkin in [false, true] {
            try assertDirection(.init(doubleChinReduction: 0.25),
                                marker: (64, 101), axis: .y, sign: -1,
                                minimum: 0.25, deepSkin: deepSkin)
            try assertDirection(.init(doubleChinReductionPro: 0.25),
                                marker: (64, 101), axis: .y, sign: -1,
                                minimum: 0.25, deepSkin: deepSkin)
            let chinSource = makePortrait(markers: [(64, 101, 0)], deepSkin: deepSkin)
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let base = rgba(try engine.processResult(
                image: chinSource, metadata: metadata,
                parameters: .init(doubleChinReduction: 0.25)
            ).output)
            let pro = rgba(try engine.processResult(
                image: chinSource, metadata: metadata,
                parameters: .init(doubleChinReductionPro: 0.25)
            ).output)
            XCTAssertNotEqual(base, pro)
            assertExterior(rgba(chinSource), base)
            assertExterior(rgba(chinSource), pro)

            let symmetrySource = makePortrait(markers: [], deepSkin: deepSkin)
            let original = rgba(symmetrySource)
            let result = try engine.processResult(
                image: symmetrySource, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            )
            let output = rgba(result.output)
            XCTAssertGreaterThan(changedPixels(original, output, x: 25..<103, y: 45..<100), 10)
            assertExterior(original, output)
            XCTAssertEqual(result.output.extent, symmetrySource.extent)
            XCTAssertEqual(rgba(try engine.processResult(
                image: symmetrySource, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            ).output), output)
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            XCTAssertEqual(rgba(try noFace.processResult(
                image: symmetrySource, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            ).output), original)
        }
    }

    private enum Axis { case x, y }

    private func assertDirection(
        _ parameters: BeautyParameters, marker: (Int, Int), axis: Axis,
        sign: Double, minimum: Double, deepSkin: Bool
    ) throws {
        let source = makePortrait(markers: [(marker.0, marker.1, 0)], deepSkin: deepSkin)
        let original = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        let before = centroid(original, marker: marker)
        XCTAssertEqual(rgba(try engine.processResult(
            image: source, metadata: metadata, parameters: .init()
        ).output), original)
        let result = try engine.processResult(
            image: source, metadata: metadata, parameters: parameters
        )
        let output = rgba(result.output)
        let after = centroid(output, marker: marker)
        let displacement = axis == .x ? after.x - before.x : after.y - before.y
        XCTAssertGreaterThan(displacement * sign, minimum)
        XCTAssertEqual(result.output.extent, source.extent)
        assertExterior(original, output)
        XCTAssertEqual(rgba(try engine.processResult(
            image: source, metadata: metadata, parameters: parameters
        ).output), output)
        XCTAssertEqual(rgba(try noFace.processResult(
            image: source, metadata: metadata, parameters: parameters
        ).output), original)
    }

    private func makePortrait(markers: [(Int, Int, Int)], deepSkin: Bool) -> CIImage {
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = Double(x - 64) / 37
                let dy = Double(y - 63) / 49
                let inside = dx * dx + dy * dy <= 1
                let eye = (52...55).contains(y) &&
                    ((47...53).contains(x) || (75...81).contains(x))
                let nose = (65...75).contains(y) && (62...66).contains(x)
                let mouth = (83...86).contains(y) && (53...75).contains(x)
                let texture = (x / 3 + y / 3).isMultiple(of: 2) ? 3 : -3
                let skin: (Int, Int, Int) = deepSkin
                    ? (90 + texture, 77 + texture, 68 + texture)
                    : (157 + texture, 132 + texture, 116 + texture)
                var rgb: (Int, Int, Int)
                if !inside { rgb = (30, 40, 50) }
                else if y < 35 { rgb = (35, 33, 32) }
                else if eye || nose { rgb = (45, 40, 38) }
                else if mouth { rgb = (110, 70, 75) }
                else { rgb = skin }
                for (markerX, markerY, channel) in markers
                where abs(x - markerX) <= 2 && abs(y - markerY) <= 2 {
                    switch channel {
                    case 0: rgb = (240, 40, 50)
                    case 1: rgb = (40, 240, 50)
                    default: rgb = (40, 50, 240)
                    }
                }
                let offset = (y * side + x) * 4
                pixels[offset] = UInt8(rgb.0)
                pixels[offset + 1] = UInt8(rgb.1)
                pixels[offset + 2] = UInt8(rgb.2)
                pixels[offset + 3] = 255
            }
        }
        return CIImage(
            bitmapData: Data(pixels), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace]).render(
            image, toBitmap: &pixels, rowBytes: side * 4,
            bounds: CGRect(x: 0, y: 0, width: side, height: side),
            format: .RGBA8, colorSpace: colorSpace
        )
        return pixels
    }

    private func centroid(_ pixels: [UInt8], marker: (Int, Int)) -> (x: Double, y: Double) {
        var total = 0.0
        var xTotal = 0.0
        var yTotal = 0.0
        for y in max(0, marker.1 - 14)..<min(side, marker.1 + 15) {
            for x in max(0, marker.0 - 14)..<min(side, marker.0 + 15) {
                let offset = (y * side + x) * 4
                let signal = Double(max(0, Int(pixels[offset]) -
                    max(Int(pixels[offset + 1]), Int(pixels[offset + 2])) - 80))
                xTotal += Double(x) * signal
                yTotal += Double(y) * signal
                total += signal
            }
        }
        return (xTotal / max(1, total), yTotal / max(1, total))
    }

    private func changedPixels(
        _ before: [UInt8], _ after: [UInt8], x: Range<Int>, y: Range<Int>
    ) -> Int {
        y.reduce(0) { total, row in
            total + x.reduce(0) { count, column in
                let offset = (row * side + column) * 4
                return count + (before[offset..<(offset + 3)] !=
                    after[offset..<(offset + 3)] ? 1 : 0)
            }
        }
    }

    private func assertExterior(
        _ before: [UInt8], _ after: [UInt8],
        file: StaticString = #filePath, line: UInt = #line
    ) {
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
