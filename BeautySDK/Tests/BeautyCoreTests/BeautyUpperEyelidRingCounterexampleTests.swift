import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@_spi(Testing) @testable import BeautySDK

/// Keeps the deterministic source that exposed the historical closed-ring defect.
/// These numeric checks alone do not qualify visual no-worsening. Independent
/// shape/direction bounds live in BeautyUpperEyelidArtifactOracleTests.
final class BeautyUpperEyelidRingCounterexampleTests: XCTestCase {
    func testControlledDomeAndFlatNegativeRemainReproducible() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let source = makeImage(bulgeMagnitude: 30, colorSpace: colorSpace)
        let negative = makeImage(bulgeMagnitude: 0, colorSpace: colorSpace)

        func output(_ image: CIImage, strength: Float = 1) throws -> (CIImage, Int, Int) {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                upperEyelidSupportSequence: [.paired]
            )
            let result = try harness.invoke(
                entry: .processResult, image: image,
                parameters: BeautyParameters(upperEyelidFullnessReduction: strength)
            )
            return (result.output, harness.compositionObservation.changedPixelCount,
                    harness.compositionObservation.acceptedUnitCount)
        }

        let positiveResult = try output(source)
        let negativeResult = try output(negative)
        let repeatedResult = try output(source)
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        let sourceBytes = render(source, using: context, colorSpace: colorSpace)
        let negativeBytes = render(negative, using: context, colorSpace: colorSpace)
        let positiveBytes = render(positiveResult.0, using: context, colorSpace: colorSpace)
        let negativeOutputBytes = render(negativeResult.0, using: context, colorSpace: colorSpace)
        let repeatedBytes = render(repeatedResult.0, using: context, colorSpace: colorSpace)

        XCTAssertEqual(source.extent, positiveResult.0.extent)
        XCTAssertEqual(negative.extent, negativeResult.0.extent)
        XCTAssertEqual(positiveResult.2, 2)
        XCTAssertGreaterThan(positiveResult.1, 200)
        XCTAssertEqual(negativeResult.2, 0)
        XCTAssertEqual(negativeResult.1, 0)
        XCTAssertEqual(negativeOutputBytes, negativeBytes)
        XCTAssertEqual(repeatedBytes, positiveBytes)

        let width = 384
        let height = 384
        for centerX in [96, 288] {
            let center = (166 * width + centerX) * 4
            XCTAssertGreaterThan(Int(sourceBytes[center]) - Int(negativeBytes[center]), 20)
        }
        var changedByEye = [0, 0]
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                XCTAssertEqual(positiveBytes[offset + 3], sourceBytes[offset + 3])
                let sourceRGB = sourceBytes[offset..<(offset + 3)]
                let outputRGB = positiveBytes[offset..<(offset + 3)]
                guard sourceRGB != outputRGB else { continue }
                let leftBand = (40..<152).contains(x) && (150..<194).contains(y)
                let rightBand = (232..<344).contains(x) && (150..<194).contains(y)
                XCTAssertTrue(leftBand || rightBand, "change outside generated upper-lid band")
                changedByEye[leftBand ? 0 : 1] += 1
                for channel in 0..<3 {
                    XCTAssertLessThanOrEqual(
                        abs(Int(positiveBytes[offset + channel]) - Int(sourceBytes[offset + channel])),
                        16
                    )
                }
            }
        }
        XCTAssertGreaterThan(changedByEye[0], 100)
        XCTAssertGreaterThan(changedByEye[1], 100)

        // Opt-in local visual repro. These PNGs are temporary and never test evidence.
        if let directory = ProcessInfo.processInfo.environment["UPPER_LID_DIAG_DIR"] {
            try context.writePNGRepresentation(of: source,
                to: URL(fileURLWithPath: directory).appendingPathComponent("source.png"),
                format: .RGBA8, colorSpace: colorSpace)
            try context.writePNGRepresentation(of: positiveResult.0,
                to: URL(fileURLWithPath: directory).appendingPathComponent("output.png"),
                format: .RGBA8, colorSpace: colorSpace)
            try context.writePNGRepresentation(of: negative,
                to: URL(fileURLWithPath: directory).appendingPathComponent("negative.png"),
                format: .RGBA8, colorSpace: colorSpace)
            for (strength, label) in [(Float(0.25), "0p25"), (0.5, "0p50"), (0.75, "0p75")] {
                let candidate = try output(source, strength: strength)
                try context.writePNGRepresentation(of: candidate.0,
                    to: URL(fileURLWithPath: directory).appendingPathComponent("output-\(label).png"),
                    format: .RGBA8, colorSpace: colorSpace)
            }
        }
    }

    private func render(_ image: CIImage, using context: CIContext, colorSpace: CGColorSpace) -> Data {
        let width = Int(image.extent.width)
        let height = Int(image.extent.height)
        var bytes = Data(count: width * height * 4)
        bytes.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: width * 4,
                           bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        return bytes
    }

    private func makeImage(bulgeMagnitude: Double, colorSpace: CGColorSpace) -> CIImage {
        let width = 384
        let height = 384
        var bytes = Data(count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let isFace = pow((Double(x) - 192) / 180, 2) +
                    pow((Double(y) - 195) / 180, 2) < 1
                let base = isFace ? 112 + x / 28 + y / 36 : 85
                let texture = ((x * 17 + y * 13) % 7) - 3
                let dome = [96.0, 288.0].reduce(0.0) { partial, cx in
                    let r2 = pow((Double(x) - cx) / 48, 2) +
                        pow((Double(y) - 166) / 21, 2)
                    return partial + (r2 < 1 ? bulgeMagnitude * pow(1 - r2, 2) : 0)
                }
                let brows = ([96.0, 288.0].contains { cx in
                    abs(Double(x) - cx) < 51 && (133...137).contains(y)
                }) ? -30 : 0
                let eye = ([96.0, 288.0].contains { cx in
                    abs(Double(x) - cx) < 37 && (193...198).contains(y)
                }) ? -27 : 0
                let red = UInt8(clamping: base + texture + Int(dome.rounded()) + brows + eye + 20)
                let green = UInt8(clamping: base + texture + Int(dome.rounded()) + brows + eye + 10)
                let blue = UInt8(clamping: base + texture + Int(dome.rounded()) + brows + eye)
                let offset = (y * width + x) * 4
                bytes[offset] = red
                bytes[offset + 1] = green
                bytes[offset + 2] = blue
                bytes[offset + 3] = 255
            }
        }
        return CIImage(bitmapData: bytes, bytesPerRow: width * 4,
                       size: CGSize(width: width, height: height),
                       format: .RGBA8, colorSpace: colorSpace)
    }
}
