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
        XCTAssertEqual(object.count, 62)
        XCTAssertEqual(
            try XCTUnwrap(object["upperEyelidFullnessReduction"] as? Double),
            0.4,
            accuracy: 0.000_001
        )
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(
            Array(Mirror(reflecting: parameters).children.compactMap(\.label).suffix(3)),
            ["teethWhitening", "scleraRednessReduction", "upperEyelidFullnessReduction"]
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
                parameters: BeautyParameters(upperEyelidFullnessReduction: 1)
            )
            let firstBytes = try render(first.output)

            let secondHarness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                upperEyelidSupportSequence: [.paired]
            )
            let second = try secondHarness.invoke(
                entry: entry,
                image: input,
                parameters: BeautyParameters(upperEyelidFullnessReduction: 1)
            )
            let secondBytes = try render(second.output)

            XCTAssertEqual(first.width, 96)
            XCTAssertEqual(first.height, 96)
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
