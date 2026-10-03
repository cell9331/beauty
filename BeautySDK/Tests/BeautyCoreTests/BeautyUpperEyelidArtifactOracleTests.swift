import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@_spi(Testing) @testable import BeautySDK

/// An output oracle independent of the production relief analyzer. The flat
/// image is an exact counterfactual for these generated luminance domes, not a
/// label for tissue volume or a claim about live Vision admission.
final class BeautyUpperEyelidArtifactOracleTests: XCTestCase {
    private struct Fixture {
        let name: String
        let base: Double
        let magnitude: Double
        let slopeX: Double
        let slopeY: Double
        let radiusX: Int
        let radiusY: Int
        let centerY: Int

        init(name: String, base: Double, magnitude: Double, slopeX: Double, slopeY: Double,
             radiusX: Int = 48, radiusY: Int = 21, centerY: Int = 166) {
            self.name = name
            self.base = base
            self.magnitude = magnitude
            self.slopeX = slopeX
            self.slopeY = slopeY
            self.radiusX = radiusX
            self.radiusY = radiusY
            self.centerY = centerY
        }
    }

    private let strengths: [Float] = [0.25, 0.5, 0.75, 1]

    private var fixtures: [Fixture] {
        var fixtures = [
            Fixture(name: "original-dome", base: 112, magnitude: 30,
                    slopeX: 1.0 / 28, slopeY: 1.0 / 36),
            Fixture(name: "darker-opposed-light", base: 76, magnitude: 24,
                    slopeX: -0.025, slopeY: 0.04),
            Fixture(name: "lighter-flat-light", base: 160, magnitude: 36,
                    slopeX: 0, slopeY: 0),
            Fixture(name: "narrow-upper-offset", base: 112, magnitude: 30,
                    slopeX: 1.0 / 28, slopeY: 1.0 / 36,
                    radiusX: 40, radiusY: 18, centerY: 163),
            Fixture(name: "wide-lower-offset", base: 112, magnitude: 30,
                    slopeX: 1.0 / 28, slopeY: 1.0 / 36,
                    radiusX: 54, radiusY: 22, centerY: 169)
        ]
        // Freeze base color and linear illumination independently at the
        // original geometry and magnitude 30. The original dome already owns
        // one matrix cell; the other original magnitudes/geometries stay intact.
        let lighting: [(name: String, x: Double, y: Double)] = [
            ("flat", 0, 0),
            ("opposed", -0.025, 0.04),
            ("rising", 1.0 / 28, 1.0 / 36)
        ]
        for base: Double in [76, 112, 160] {
            for light in lighting {
                if base == 112 && light.name == "rising" { continue }
                fixtures.append(Fixture(name: "base-\(Int(base))-\(light.name)",
                    base: base, magnitude: 30, slopeX: light.x, slopeY: light.y))
            }
        }
        return fixtures
    }

    /// Frozen before candidate output: one byte of rounding tolerance; at full
    /// strength, at least 20% removal of the known central dome (scaled by the
    /// requested strength); no outward residual rise greater than one byte.
    func testPublicDomeCompressionHasNoDarkRingOrOvershoot() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        XCTAssertEqual(fixtures.count, 13)
        for fixture in fixtures {
            let source = makeImage(fixture, magnitude: fixture.magnitude, colorSpace: colorSpace)
            let flat = makeImage(fixture, magnitude: 0, colorSpace: colorSpace)
            let sourceBytes = render(source, context: context, colorSpace: colorSpace)
            let flatBytes = render(flat, context: context, colorSpace: colorSpace)
            let negative = try output(flat, strength: 1)
            assertBytesEqual(render(negative, context: context, colorSpace: colorSpace), flatBytes,
                             "\(fixture.name): flat negative must stay exact")
            let neutral = try output(source, strength: 0)
            assertBytesEqual(render(neutral, context: context, colorSpace: colorSpace), sourceBytes,
                             "\(fixture.name): neutral must stay exact")

            var previousBytes = sourceBytes
            for strength in strengths {
                let label = "\(fixture.name), strength=\(strength)"
                let result = try output(source, strength: strength)
                XCTAssertEqual(result.extent, source.extent, label)
                let edited = render(result, context: context, colorSpace: colorSpace)
                let repeated = try output(source, strength: strength)
                assertBytesEqual(render(repeated, context: context, colorSpace: colorSpace), edited, label)
                var protectedChanges = 0
                var alphaChanges = 0
                var maximumDelta = 0
                var minimumResidual = 0
                var maximumOvershoot = 0
                var belowFlatCount = 0
                var maximumStrengthReversal = 0
                for y in 0..<384 {
                    for x in 0..<384 {
                        let offset = (y * 384 + x) * 4
                        if edited[offset + 3] != sourceBytes[offset + 3] { alphaChanges += 1 }
                        let target = ((40..<152).contains(x) || (232..<344).contains(x))
                            && (150..<194).contains(y)
                        for channel in 0..<3 {
                            let delta = Int(edited[offset + channel]) - Int(sourceBytes[offset + channel])
                            maximumStrengthReversal = max(maximumStrengthReversal,
                                Int(edited[offset + channel]) - Int(previousBytes[offset + channel]))
                            maximumDelta = max(maximumDelta, abs(delta))
                            if !target && delta != 0 { protectedChanges += 1 }
                            guard target else { continue }
                            let originalDome = Int(sourceBytes[offset + channel]) - Int(flatBytes[offset + channel])
                            let residual = Int(edited[offset + channel]) - Int(flatBytes[offset + channel])
                            minimumResidual = min(minimumResidual, residual)
                            maximumOvershoot = max(maximumOvershoot, residual - originalDome)
                            if residual < -1 { belowFlatCount += 1 }
                        }
                    }
                }
                XCTAssertEqual(protectedChanges, 0, label)
                XCTAssertEqual(alphaChanges, 0, label)
                XCTAssertLessThanOrEqual(maximumDelta, 16, label)
                XCTAssertEqual(maximumStrengthReversal, 0,
                    "\(label): stronger request must not undo a weaker correction")
                XCTAssertGreaterThanOrEqual(minimumResidual, -1,
                    "\(label): new dark residual; \(belowFlatCount) channel samples below flat minus one")
                XCTAssertLessThanOrEqual(maximumOvershoot, 1, "\(label): newly amplified dome/bright halo")

                for centerX in [96, 288] {
                    var sourceCenter = 0.0
                    var outputCenter = 0.0
                    var centerCount = 0
                    var sums = Array(repeating: Array(repeating: 0.0, count: 10), count: 4)
                    var counts = Array(repeating: Array(repeating: 0, count: 10), count: 4)
                    for y in (fixture.centerY - fixture.radiusY)...(fixture.centerY + fixture.radiusY) {
                        for x in (centerX - fixture.radiusX)...(centerX + fixture.radiusX) {
                            let nx = Double(x - centerX) / Double(fixture.radiusX)
                            let ny = Double(y - fixture.centerY) / Double(fixture.radiusY)
                            let radiusSquared = nx * nx + ny * ny
                            guard radiusSquared < 1 else { continue }
                            let offset = (y * 384 + x) * 4
                            let originalDome = Double(Int(sourceBytes[offset]) - Int(flatBytes[offset]))
                            let residual = Double(Int(edited[offset]) - Int(flatBytes[offset]))
                            if radiusSquared <= 0.09 {
                                sourceCenter += originalDome
                                outputCenter += residual
                                centerCount += 1
                            }
                            let sector = (x < centerX ? 0 : 1) + (y < fixture.centerY ? 0 : 2)
                            let bin = min(9, Int(sqrt(radiusSquared) * 10))
                            sums[sector][bin] += residual
                            counts[sector][bin] += 1
                        }
                    }
                    XCTAssertGreaterThan(centerCount, 0, label)
                    XCTAssertGreaterThan(sourceCenter / Double(centerCount), fixture.magnitude * 0.8, label)
                    let reduction = (sourceCenter - outputCenter) / sourceCenter
                    XCTAssertGreaterThanOrEqual(reduction, 0.20 * Double(strength),
                        "\(label), eye=\(centerX): meaningful source-defined central reduction")
                    var maximumOutwardRise = 0.0
                    for sector in 0..<4 {
                        for bin in 1..<10 where counts[sector][bin - 1] > 0 && counts[sector][bin] > 0 {
                            let inner = sums[sector][bin - 1] / Double(counts[sector][bin - 1])
                            let outer = sums[sector][bin] / Double(counts[sector][bin])
                            maximumOutwardRise = max(maximumOutwardRise, outer - inner)
                        }
                    }
                    XCTAssertLessThanOrEqual(maximumOutwardRise, 1,
                        "\(label), eye=\(centerX): new radial valley in a source-defined monotone dome")
                }
                previousBytes = edited
            }
        }
    }

    func testPublicMatchedValleysRemainSourceExact() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        for fixture in fixtures {
            let valley = makeImage(fixture, magnitude: -fixture.magnitude, colorSpace: colorSpace)
            let sourceBytes = render(valley, context: context, colorSpace: colorSpace)
            for strength in strengths {
                let label = "\(fixture.name), valley, strength=\(strength)"
                let result = try output(valley, strength: strength)
                XCTAssertEqual(result.extent, valley.extent, label)
                let edited = render(result, context: context, colorSpace: colorSpace)
                assertBytesEqual(edited, sourceBytes,
                    "\(label): a matched concave negative must stay exact")
                let repeated = try output(valley, strength: strength)
                assertBytesEqual(render(repeated, context: context, colorSpace: colorSpace), edited,
                    "\(label): repeat must stay exact")
            }
        }
    }

    private func assertBytesEqual(
        _ actual: [UInt8], _ expected: [UInt8], _ message: String,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(actual.count, expected.count, message, file: file, line: line)
        var changedByteCount = 0
        var maximumAbsoluteDelta = 0
        for (actualByte, expectedByte) in zip(actual, expected) {
            let delta = abs(Int(actualByte) - Int(expectedByte))
            if delta > 0 { changedByteCount += 1 }
            maximumAbsoluteDelta = max(maximumAbsoluteDelta, delta)
        }
        XCTAssertEqual(changedByteCount, 0,
            "\(message); maximum absolute byte delta=\(maximumAbsoluteDelta)", file: file, line: line)
    }

    private func output(_ image: CIImage, strength: Float) throws -> CIImage {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0, upperEyelidSupportSequence: [.paired])
        let result = try harness.invoke(entry: .processResult, image: image,
            parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
        XCTAssertEqual(result.width, 384)
        XCTAssertEqual(result.height, 384)
        return result.output
    }

    private func render(_ image: CIImage, context: CIContext, colorSpace: CGColorSpace) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 384 * 384 * 4)
        context.render(image, toBitmap: &bytes, rowBytes: 384 * 4,
                       bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func makeImage(_ fixture: Fixture, magnitude: Double, colorSpace: CGColorSpace) -> CIImage {
        var bytes = [UInt8](repeating: 0, count: 384 * 384 * 4)
        var outOfRangePixelCount = 0
        for y in 0..<384 {
            for x in 0..<384 {
                let isFace = pow((Double(x) - 192) / 180, 2) + pow((Double(y) - 195) / 180, 2) < 1
                let base = isFace ? fixture.base + Double(x) * fixture.slopeX + Double(y) * fixture.slopeY : 85
                let texture = ((x * 17 + y * 13) % 7) - 3
                let dome = [96.0, 288.0].reduce(0.0) { partial, centerX in
                    let radiusSquared = pow((Double(x) - centerX) / Double(fixture.radiusX), 2) +
                        pow(Double(y - fixture.centerY) / Double(fixture.radiusY), 2)
                    return partial + (radiusSquared < 1 ? magnitude * pow(1 - radiusSquared, 2) : 0)
                }
                let brow = [96, 288].contains { abs(x - $0) < 51 && (133...137).contains(y) } ? -30 : 0
                let eye = [96, 288].contains { abs(x - $0) < 37 && (193...198).contains(y) } ? -27 : 0
                let value = Int(base.rounded()) + texture + Int(dome.rounded()) + brow + eye
                let offset = (y * 384 + x) * 4
                guard value >= 0, value + 20 <= 255 else {
                    outOfRangePixelCount += 1
                    continue
                }
                bytes[offset] = UInt8(value + 20)
                bytes[offset + 1] = UInt8(value + 10)
                bytes[offset + 2] = UInt8(value)
                bytes[offset + 3] = 255
            }
        }
        XCTAssertEqual(outOfRangePixelCount, 0,
            "\(fixture.name), magnitude=\(magnitude): generated RGB must fit without channel clipping")
        return CIImage(bitmapData: Data(bytes), bytesPerRow: 384 * 4,
                       size: CGSize(width: 384, height: 384), format: .RGBA8, colorSpace: colorSpace)
    }
}
