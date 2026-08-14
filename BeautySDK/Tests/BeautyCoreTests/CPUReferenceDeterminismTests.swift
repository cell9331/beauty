import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) @testable import BeautySDK

/// Generated public-facade oracles for request-local state and degradation.
///
/// The harness exposes aggregate observations only. Images are generated in
/// memory and rendered transiently so repeated/recovery assertions never need
/// a fixture path, a private model, or durable pixel evidence.
final class CPUReferenceDeterminismTests: XCTestCase {
    func testRepeatedAndFreshEnginesProduceIdenticalFiniteOutput() throws {
        let image = try generatedCombinedImage()
        let parameters = BeautyParameters(
            brightness: 0.12,
            teethWhitening: 1,
            scleraRednessReduction: 1
        )
        let repeatedHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired, .paired]
        )
        let first = try repeatedHarness.invoke(entry: .processResult, image: image, parameters: parameters)
        let firstBytes = try renderedRGBA8(first.output)
        let firstProviderObservation = repeatedHarness.providerObservation
        let firstScleraObservation = repeatedHarness.scleraProviderObservation
        let firstCompositionObservation = repeatedHarness.compositionObservation

        let second = try repeatedHarness.invoke(entry: .processResult, image: image, parameters: parameters)
        let secondBytes = try renderedRGBA8(second.output)

        let freshHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired]
        )
        let fresh = try freshHarness.invoke(entry: .processResult, image: image, parameters: parameters)
        let freshBytes = try renderedRGBA8(fresh.output)
        let secondProviderObservation = repeatedHarness.providerObservation
        let secondScleraObservation = repeatedHarness.scleraProviderObservation
        let secondCompositionObservation = repeatedHarness.compositionObservation
        let freshProviderObservation = freshHarness.providerObservation
        let freshScleraObservation = freshHarness.scleraProviderObservation
        let freshCompositionObservation = freshHarness.compositionObservation

        XCTAssertEqual(firstBytes, secondBytes)
        XCTAssertEqual(firstBytes, freshBytes)
        XCTAssertEqual(firstProviderObservation, secondProviderObservation)
        XCTAssertEqual(firstProviderObservation, freshProviderObservation)
        XCTAssertEqual(firstScleraObservation, secondScleraObservation)
        XCTAssertEqual(firstScleraObservation, freshScleraObservation)
        XCTAssertEqual(firstCompositionObservation, secondCompositionObservation)
        XCTAssertEqual(firstCompositionObservation, freshCompositionObservation)
        XCTAssertEqual(first.width, 64)
        XCTAssertEqual(first.height, 64)
        XCTAssertTrue(hasOpaqueAlpha(firstBytes))
        XCTAssertTrue(firstBytes.allSatisfy { $0 <= 255 })
        XCTAssertEqual(repeatedHarness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(repeatedHarness.retainedMappedCoordinateCount, 0)
        XCTAssertTrue(repeatedHarness.reusedNormalizationOwnerAcrossRequests)
    }

    func testValidInvalidValidRecoveryClearsRequestObservationsAndPixels() throws {
        let image = try generatedCombinedImage()
        let parameters = BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired, .invalidOrder, .paired]
        )

        let first = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        let firstBytes = try renderedRGBA8(first.output)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)

        let middle = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        XCTAssertEqual(try renderedRGBA8(middle.output), try renderedRGBA8(image))
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 0)
        XCTAssertEqual(harness.compositionObservation.changedPixelCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)

        let third = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        XCTAssertEqual(try renderedRGBA8(third.output), firstBytes)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
    }

    func testTransparentInputRejectsBeforeProviderCompositionAndRender() throws {
        let transparent = try CPUReferenceFacadeFixture.alphaBoundary().image
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired]
        )

        XCTAssertThrowsError(try harness.invoke(
            entry: .processResult,
            image: transparent,
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(harness.providerObservation, SDKTestingTeethProviderObservation())
        XCTAssertEqual(harness.scleraProviderObservation, SDKTestingScleraProviderObservation())
        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertFalse(harness.hasCurrentCanonicalObservation)
        XCTAssertFalse(harness.usedExplicitSRGBRender)
    }

    func testMalformedEyePeerLeavesValidEyeAndTeethEligible() throws {
        let image = try generatedCombinedImage()
        let parameters = BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.leftValidRightMalformed]
        )
        let result = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        let bytes = try renderedRGBA8(result.output)

        XCTAssertTrue(hasOpaqueAlpha(bytes))
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.acceptedLeftEyeCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.acceptedRightEyeCount, 0)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 2)
        XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
    }

    func testMalformedScleraSupportDoesNotSuppressEligibleTeeth() throws {
        let image = try generatedCombinedImage()
        let teethOnly = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportSequence: [.available(valueID: 1)]
        )
        let teethResult = try teethOnly.invoke(
            entry: .processResult,
            image: image,
            parameters: BeautyParameters(teethWhitening: 1)
        )

        let combinedHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportSequence: [.available(valueID: 1)]
        )
        let combinedResult = try combinedHarness.invoke(
            entry: .processResult,
            image: image,
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )

        XCTAssertEqual(try renderedRGBA8(combinedResult.output), try renderedRGBA8(teethResult.output))
        XCTAssertEqual(combinedHarness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(combinedHarness.scleraProviderObservation.issuedUnitCount, 0)
        XCTAssertEqual(combinedHarness.compositionObservation.acceptedUnitCount, 1)
        XCTAssertEqual(combinedHarness.retainedRequestOwnerCount, 0)
    }

    func testNoFaceAndMissingSupportReturnExactGeneratedSource() throws {
        let image = try generatedCombinedImage()
        let sourceBytes = try renderedRGBA8(image)
        for fixture in [SDKTestingLocalSupportFixture.noFace, .missingSupport] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                supportFixture: fixture
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: image,
                parameters: BeautyParameters(
                    teethWhitening: 1,
                    scleraRednessReduction: 1
                )
            )
            XCTAssertEqual(try renderedRGBA8(result.output), sourceBytes)
            XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
            XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 0)
            XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 0)
            XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
            XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        }
    }

    func testIndependentRequestsKeepSupportAggregatesLocal() async throws {
        let identifiers = try await withThrowingTaskGroup(of: Int.self) { group in
            for valueID in 1...8 {
                group.addTask {
                    try await SDKTestingLocalRetouchFoundationHarness.runIndependent(valueID: valueID)
                }
            }
            return try await group.reduce(into: []) { values, identifier in
                values.append(identifier)
            }
        }
        XCTAssertEqual(identifiers.sorted(), Array(1...8))
    }

    func testAggregateObservationsContainNoRawFixtureOrSupportData() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired]
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try generatedCombinedImage(),
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )

        let description = String(describing: (
            harness.providerObservation,
            harness.scleraProviderObservation,
            harness.compositionObservation
        )).lowercased()
        for forbidden in [
            "coordinate", "pupil", "mask", "pixelindex", "candidatecolor",
            "fixture", "path", "digest", "owneridentity",
        ] {
            XCTAssertFalse(description.contains(forbidden), forbidden)
        }
    }

    private func generatedCombinedImage() throws -> CIImage {
        let width = 64
        let height = 64
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        for index in 0..<(width * height) {
            let offset = index * 4
            bytes[offset] = 45
            bytes[offset + 1] = 24
            bytes[offset + 2] = 30
            bytes[offset + 3] = 255
        }
        for y in 16...29 {
            for x in 4...59 {
                let offset = (y * width + x) * 4
                bytes[offset] = 209
                bytes[offset + 1] = 150
                bytes[offset + 2] = 150
            }
        }
        for y in 32...33 {
            for x in 29...34 {
                let offset = (y * width + x) * 4
                bytes[offset] = 181
                bytes[offset + 1] = 161
                bytes[offset + 2] = 120
            }
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

    private func renderedRGBA8(_ image: CIImage) throws -> [UInt8] {
        let bounds = image.extent.integral
        guard bounds.width > 0, bounds.height > 0,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.invalidInput
        }
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        softwareContext(colorSpace: colorSpace).render(
            image,
            toBitmap: &bytes,
            rowBytes: width * 4,
            bounds: bounds,
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return bytes
    }

    private func hasOpaqueAlpha(_ bytes: [UInt8]) -> Bool {
        stride(from: 3, to: bytes.count, by: 4).allSatisfy { bytes[$0] == 255 }
    }

    private func softwareContext(colorSpace: CGColorSpace) -> CIContext {
        CIContext(options: [
            .useSoftwareRenderer: true,
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
    }
}
