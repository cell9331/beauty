import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@_spi(Testing) @testable import BeautySDK

final class BeautyEngineTeethWhiteningIntegrationTests: XCTestCase {
    func testDirectPositiveIntentUsesOneCanonicalRequestProviderCompositionAndRenderForBothEntries() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0
            )
            let result = try harness.invoke(
                entry: entry,
                image: try yellowMouthImage(),
                parameters: BeautyParameters(teethWhitening: 1)
            )

            XCTAssertEqual(result.width, 64)
            XCTAssertEqual(result.height, 64)
            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
            XCTAssertEqual(harness.renderCount, 1)
            XCTAssertEqual(harness.providerObservation.invocationCount, 1)
            XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
            XCTAssertEqual(harness.providerObservation.abstentionCount, 0)
            XCTAssertEqual(harness.providerObservation.droppedFixedStrongPixelCount, 0)
            XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
            XCTAssertTrue(harness.compositionObservation.sourceBindingMatched)
            XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 1)
            XCTAssertGreaterThan(harness.compositionObservation.changedPixelCount, 0)
            XCTAssertEqual(
                harness.events,
                [.canonicalize, .detectAndMap, .makeRequestContext, .compose, .render]
            )
        }
    }

    func testOpaqueTestingDemandCannotActivateProductionTeethProvider() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try yellowMouthImage(),
            parameters: .init()
        )

        XCTAssertEqual(harness.providerObservation.invocationCount, 0)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.providerObservation.abstentionCount, 0)
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 0)
        XCTAssertEqual(harness.events, [.canonicalize, .detectAndMap, .makeRequestContext, .render])
    }

    func testZeroIntentRetainsLegacyRouteEvenWithYellowPixelsAndValidSupportFixture() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try yellowMouthImage(),
            parameters: BeautyParameters(teethWhitening: 1)
        )
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)

        _ = try harness.invoke(
            entry: .processResult,
            image: try yellowMouthImage(),
            parameters: .init()
        )

        XCTAssertEqual(harness.canonicalizeCount, 1)
        XCTAssertEqual(harness.detectAndMapCount, 1)
        XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        XCTAssertEqual(harness.providerObservation.invocationCount, 0)
        XCTAssertEqual(harness.renderCount, 2)
    }

    func testNoFaceAndMissingSupportAbstainLocallyAfterOneProviderAttempt() throws {
        for support in [SDKTestingLocalSupportFixture.noFace, .missingSupport] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                supportFixture: support
            )
            _ = try harness.invoke(
                entry: .processResult,
                image: try yellowMouthImage(),
                parameters: BeautyParameters(teethWhitening: 1)
            )

            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.providerObservation.invocationCount, 1)
            XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
            XCTAssertEqual(harness.providerObservation.abstentionCount, 1)
            XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
            XCTAssertEqual(harness.compositionObservation.changedPixelCount, 0)
            XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        }
    }

    func testAlreadyLightMouthAbstainsAtMaximumIntent() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try alreadyLightMouthImage(),
            parameters: BeautyParameters(teethWhitening: 1)
        )

        XCTAssertEqual(harness.providerObservation.invocationCount, 1)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.providerObservation.abstentionCount, 1)
        XCTAssertEqual(harness.compositionObservation.changedPixelCount, 0)
    }

    func testProviderAbstentionDoesNotSuppressUnrelatedEligibleColorOutput() throws {
        let image = try alreadyLightMouthImage()
        let baseline = try render(image)
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportFixture: .missingSupport
        )
        let result = try harness.invoke(
            entry: .processResult,
            image: image,
            parameters: BeautyParameters(brightness: 0.5, teethWhitening: 1)
        )
        let output = try render(result.output)

        XCTAssertNotEqual(output, baseline)
        XCTAssertEqual(harness.providerObservation.abstentionCount, 1)
        XCTAssertEqual(harness.compositionObservation.changedPixelCount, 0)
        XCTAssertEqual(harness.renderCount, 1)
    }

    func testValidMalformedValidRequestSequenceRetainsNoProviderState() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportSequence: [.available(valueID: 11), .malformed, .available(valueID: 22)]
        )
        let image = try yellowMouthImage()
        let parameters = BeautyParameters(teethWhitening: 1)

        _ = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertThrowsError(try harness.invoke(
            entry: .processResult,
            image: image,
            parameters: parameters
        ))
        XCTAssertEqual(harness.providerObservation.invocationCount, 0)
        _ = try harness.invoke(entry: .processResult, image: image, parameters: parameters)

        XCTAssertEqual(harness.providerObservation.invocationCount, 1)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.providerObservation.droppedFixedStrongPixelCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
    }

    func testPixelBufferAndResetPerformZeroTeethProviderWork() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0
        )
        let image = try yellowMouthImage()
        let parameters = BeautyParameters(teethWhitening: 1)
        _ = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)

        try harness.invokePixelBuffer(parameters: parameters)
        XCTAssertEqual(harness.providerObservation.invocationCount, 0)

        _ = try harness.invoke(entry: .processResult, image: image, parameters: parameters)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        harness.reset()

        XCTAssertEqual(harness.providerObservation.invocationCount, 0)
        XCTAssertEqual(harness.canonicalizeCount, 2)
        XCTAssertEqual(harness.detectAndMapCount, 2)
        XCTAssertEqual(harness.requestOwnerCreationCount, 2)
        XCTAssertEqual(harness.pixelBufferSummaryAvailability, "notRun")
    }

    func testProductionAndOpaqueTestingUnitsShareOneOwnerAndOneComposition() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            compositionScenario: .disjoint
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try yellowMouthImage(),
            parameters: BeautyParameters(teethWhitening: 1)
        )

        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 4)
        XCTAssertEqual(harness.compositionObservation.rejectedUnitCount, 0)
        XCTAssertEqual(
            harness.events,
            [.canonicalize, .detectAndMap, .makeRequestContext, .compose, .render]
        )
    }

    func testIndependentParallelRequestsKeepProviderAndSourceOwnershipIsolated() async throws {
        let results = try await withThrowingTaskGroup(of: (Int, Int, Int).self) { group in
            for index in 0..<16 {
                group.addTask {
                    let harness = try SDKTestingLocalRetouchFoundationHarness(
                        admittedPrivateDemandCount: 0,
                        supportSequence: [.available(valueID: index + 1)]
                    )
                    _ = try harness.invoke(
                        entry: .processResult,
                        image: try Self.makeMouthImage(color: (181, 161, 120)),
                        parameters: BeautyParameters(teethWhitening: 1)
                    )
                    return (
                        harness.providerObservation.invocationCount,
                        harness.providerObservation.issuedUnitCount,
                        harness.compositionObservation.changedPixelCount
                    )
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        XCTAssertEqual(results.count, 16)
        XCTAssertTrue(results.allSatisfy { $0.0 == 1 && $0.1 == 1 && $0.2 > 0 })
    }

    private func yellowMouthImage() throws -> CIImage {
        try Self.makeMouthImage(color: (181, 161, 120))
    }

    private func alreadyLightMouthImage() throws -> CIImage {
        try Self.makeMouthImage(color: (232, 229, 219))
    }

    private static func makeMouthImage(color: (UInt8, UInt8, UInt8)) throws -> CIImage {
        let width = 64
        let height = 64
        var bytes = Array(repeating: UInt8(0), count: width * height * 4)
        for index in 0..<(width * height) {
            let offset = index * 4
            bytes[offset] = 45
            bytes[offset + 1] = 24
            bytes[offset + 2] = 30
            bytes[offset + 3] = .max
        }
        // Keep dark mouth pixels around the enamel patch so this fixture proves
        // the provider's strong-area gate instead of presenting a synthetic
        // 100%-tooth aperture.
        for y in 32...33 {
            for x in 29...34 {
                let offset = (y * width + x) * 4
                bytes[offset] = color.0
                bytes[offset + 1] = color.1
                bytes[offset + 2] = color.2
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
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }
}
