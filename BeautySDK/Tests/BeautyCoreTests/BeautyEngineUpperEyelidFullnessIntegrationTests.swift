import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@_spi(Testing) @testable import BeautySDK

final class BeautyEngineUpperEyelidFullnessIntegrationTests: XCTestCase {
    func testPublicScalarIsPositiveOnlyCodableAndLegacyNeutral() throws {
        let cases: [(Float, Float)] = [
            (-1, 0),
            (0, 0),
            (0.37, 0.37),
            (1, 1),
            (2, 1),
            (.nan, 0),
            (.infinity, 0),
        ]
        for (value, expected) in cases {
            let parameters = BeautyParameters(upperEyelidFullnessReduction: value)
            XCTAssertEqual(parameters.upperEyelidFullnessReduction, expected, accuracy: 0.000_001)
            XCTAssertEqual(
                parameters.normalized().upperEyelidFullnessReduction,
                expected,
                accuracy: 0.000_001
            )
        }

        let legacy = try JSONDecoder().decode(BeautyParameters.self, from: Data("{}".utf8))
        XCTAssertEqual(legacy.upperEyelidFullnessReduction, 0)

        let parameters = BeautyParameters(
            filterId: "owner-local",
            teethWhitening: 0.2,
            scleraRednessReduction: 0.3,
            upperEyelidFullnessReduction: 0.4
        )
        let data = try JSONEncoder().encode(parameters)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)
        XCTAssertEqual(object.count, 66)
        XCTAssertEqual(
            try XCTUnwrap(object["upperEyelidFullnessReduction"] as? Double),
            0.4,
            accuracy: 0.000_001
        )
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(
            Array(Mirror(reflecting: parameters).children.compactMap(\.label).suffix(6)),
            ["scleraRednessReduction", "upperEyelidFullnessReduction", "wholeFaceYPosition", "wholeFaceXPosition", "wholeFaceTilt", "faceShortening"]
        )
    }

    func testPublicStillImageEntriesProduceBoundedDeterministicPixels() throws {
        let input = try reliefImage()
        let inputBytes = try render(input)

        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let firstHarness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                upperEyelidSupportSequence: [.paired]
            )
            let first = try firstHarness.invoke(
                entry: entry,
                image: input,
                parameters: BeautyParameters(upperEyelidFullnessReduction: 0.5)
            )
            let firstBytes = try render(first.output)

            let secondHarness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                upperEyelidSupportSequence: [.paired]
            )
            let second = try secondHarness.invoke(
                entry: entry,
                image: input,
                parameters: BeautyParameters(upperEyelidFullnessReduction: 0.5)
            )
            let secondBytes = try render(second.output)

            XCTAssertEqual(first.width, 96)
            XCTAssertEqual(first.height, 96)
            XCTAssertEqual(first.output.extent, input.extent)
            XCTAssertNotEqual(firstBytes, inputBytes)
            XCTAssertEqual(firstBytes, secondBytes)
            XCTAssertEqual(firstHarness.canonicalizeCount, 1)
            XCTAssertEqual(firstHarness.detectAndMapCount, 1)
            XCTAssertEqual(firstHarness.requestOwnerCreationCount, 1)
            XCTAssertEqual(firstHarness.compositionObservation.compositionInvocationCount, 1)
            XCTAssertGreaterThan(firstHarness.compositionObservation.acceptedUnitCount, 0)
            XCTAssertGreaterThan(firstHarness.compositionObservation.changedPixelCount, 0)
            XCTAssertEqual(firstHarness.compositionObservation.changedOutsideUnionPixelCount, 0)
            XCTAssertEqual(firstHarness.renderCount, 1)
            XCTAssertEqual(
                firstHarness.events,
                [.canonicalize, .detectAndMap, .makeRequestContext, .compose, .render]
            )
            assertAlphaIsPreserved(inputBytes, firstBytes)
            var targetChanges = 0
            for y in 0..<96 {
                for x in 0..<96 {
                    let offset = (y * 96 + x) * 4
                    let sourceRGB = inputBytes[offset..<(offset + 3)]
                    let outputRGB = firstBytes[offset..<(offset + 3)]
                    let protected = x < 10 || x >= 86 || (40..<56).contains(x)
                        || y < 35 || y >= 53
                    if protected {
                        XCTAssertEqual(outputRGB, sourceRGB, "protected public pixel (\(x), \(y))")
                    }
                    guard sourceRGB != outputRGB else { continue }
                    XCTAssertFalse(protected, "changed protected public pixel (\(x), \(y))")
                    targetChanges += 1
                    for channel in 0..<3 {
                        XCTAssertLessThanOrEqual(
                            abs(Int(firstBytes[offset + channel]) - Int(inputBytes[offset + channel])),
                            16
                        )
                    }
                }
            }
            XCTAssertGreaterThan(targetChanges, 10)
        }
    }

    func testPublicPairedAndSingleEyeOutputsAreIndependent() throws {
        let input = try reliefImage()
        let source = try render(input)
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            func output(_ support: SDKTestingUpperEyelidSupport) throws -> Data {
                let harness = try SDKTestingLocalRetouchFoundationHarness(
                    admittedPrivateDemandCount: 0,
                    upperEyelidSupportSequence: [support]
                )
                let result = try harness.invoke(
                    entry: entry,
                    image: input,
                    parameters: BeautyParameters(upperEyelidFullnessReduction: 0.5)
                )
                return try render(result.output)
            }

            let paired = try output(.paired)
            let left = try output(.leftOnly)
            let right = try output(.rightOnly)
            var leftChanges = 0
            var rightChanges = 0
            for y in 0..<96 {
                for x in 0..<96 {
                    let offset = (y * 96 + x) * 4
                    let range = offset..<(offset + 4)
                    let original = source[range]
                    let leftPixel = left[range]
                    let rightPixel = right[range]
                    let pairedPixel = paired[range]
                    if leftPixel != original {
                        XCTAssertLessThan(x, 48)
                        XCTAssertEqual(rightPixel, original)
                        XCTAssertEqual(pairedPixel, leftPixel)
                        leftChanges += 1
                    } else if rightPixel != original {
                        XCTAssertGreaterThanOrEqual(x, 48)
                        XCTAssertEqual(leftPixel, original)
                        XCTAssertEqual(pairedPixel, rightPixel)
                        rightChanges += 1
                    } else {
                        XCTAssertEqual(pairedPixel, original)
                    }
                }
            }
            XCTAssertGreaterThan(leftChanges, 10)
            XCTAssertGreaterThan(rightChanges, 10)
        }
    }

    func testMissingFaceAndZeroStrengthRemainSourceExact() throws {
        let input = try reliefImage()
        let inputBytes = try render(input)

        let noFaceHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportFixture: .noFace
        )
        let noFace = try noFaceHarness.invoke(
            entry: .processResult,
            image: input,
            parameters: BeautyParameters(upperEyelidFullnessReduction: 1)
        )
        XCTAssertEqual(try render(noFace.output), inputBytes)
        XCTAssertEqual(noFaceHarness.compositionObservation.changedPixelCount, 0)

        let neutralHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            upperEyelidSupportSequence: [.paired]
        )
        let neutral = try neutralHarness.invoke(
            entry: .processResult,
            image: input,
            parameters: BeautyParameters(upperEyelidFullnessReduction: 0)
        )
        XCTAssertEqual(try render(neutral.output), inputBytes)
        XCTAssertEqual(neutralHarness.canonicalizeCount, 0)
        XCTAssertEqual(neutralHarness.detectAndMapCount, 0)
    }

    func testUpperEyelidSupportFailsClosedPerEyeAndForMalformedOrMissingSupport() throws {
        let input = try reliefImage()
        let sourceBytes = try render(input)

        for support in [
            SDKTestingUpperEyelidSupport.leftOnly,
            .rightOnly,
        ] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                upperEyelidSupportSequence: [support]
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: input,
                parameters: BeautyParameters(upperEyelidFullnessReduction: 1)
            )
            XCTAssertNotEqual(try render(result.output), sourceBytes)
            XCTAssertGreaterThan(harness.compositionObservation.acceptedUnitCount, 0)
            XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0)
        }

        for support in [
            SDKTestingUpperEyelidSupport.malformed,
            .noFace,
        ] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                upperEyelidSupportSequence: [support]
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: input,
                parameters: BeautyParameters(upperEyelidFullnessReduction: 1)
            )
            XCTAssertEqual(try render(result.output), sourceBytes)
            XCTAssertEqual(harness.compositionObservation.changedPixelCount, 0)
        }
    }

    private func reliefImage() throws -> CIImage {
        let width = 96
        let height = 96
        let bytes = (0..<(width * height)).flatMap { pixelIndex -> [UInt8] in
            let x = pixelIndex % width
            let y = pixelIndex / width
            let normalizedX = (Double(x) + 0.5) / Double(width)
            let relief = [0.25, 0.50, 0.75].reduce(0.0) { partial, center in
                let distance = normalizedX - center
                return partial + 24 * exp(-(distance * distance) / 0.004)
            }
            let texture = ((x * 7 + y * 11) % 5) - 2
            let base = Int((92 + Double(x) * 0.10 + Double(y) * 0.08 + relief).rounded()) + texture
            return [UInt8(base + 18), UInt8(base + 8), UInt8(base), 255]
        }
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private func render(_ image: CIImage) throws -> Data {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        let width = Int(image.extent.width)
        let height = Int(image.extent.height)
        var bytes = Data(count: width * height * 4)
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
        bytes.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            context.render(
                image,
                toBitmap: baseAddress,
                rowBytes: width * 4,
                bounds: image.extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }

    private func assertAlphaIsPreserved(_ source: Data, _ output: Data) {
        let sourceBytes = Array(source)
        let outputBytes = Array(output)
        XCTAssertEqual(sourceBytes.count, outputBytes.count)
        for offset in stride(from: 3, to: sourceBytes.count, by: 4) {
            XCTAssertEqual(outputBytes[offset], sourceBytes[offset], "alpha byte \(offset)")
        }
    }
}
