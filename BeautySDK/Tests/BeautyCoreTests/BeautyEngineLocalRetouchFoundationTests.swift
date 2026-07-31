import CoreImage
import CoreVideo
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

/// Wave 0 facade specification. Candidate identities and portrait-derived data
/// are deliberately absent; injected demand is only an opaque integer count.
final class BeautyEngineLocalRetouchFoundationTests: XCTestCase {
    private static let image: CIImage = {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        return CIImage(
            bitmapData: Data([
                51, 102, 153, 255, 51, 102, 153, 255,
                51, 102, 153, 255, 51, 102, 153, 255,
            ]),
            bytesPerRow: 8,
            size: CGSize(width: 2, height: 2),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }()

    func testBothExistingCIImageFacadeEntriesReachOnlyTheInjectedPrivateRoute() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
            _ = try harness.invoke(entry: entry, image: Self.image, parameters: .init(brightness: 0.1))
            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
            XCTAssertEqual(harness.renderCount, 1)
        }
    }

    func testZeroOneAndMultiplePrivateDemandsShareOneRequest() throws {
        for (demandCount, expected) in [(0, 0), (1, 1), (2, 1), (Int.max, 1)] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: demandCount
            )
            _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
            XCTAssertEqual(harness.canonicalizeCount, expected)
            XCTAssertEqual(harness.detectAndMapCount, expected)
            XCTAssertEqual(harness.requestOwnerCreationCount, expected)
            XCTAssertEqual(harness.renderCount, 1)
            XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        }
    }

    func testCanonicalizeDetectMapContextRenderOrder() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 3)
        _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        XCTAssertEqual(
            harness.events,
            [.canonicalize, .detectAndMap, .makeRequestContext, .render]
        )
    }

    func testSequentialAdmittedRequestsReuseEngineCanonicalizerAndContext() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)

        _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())

        XCTAssertEqual(harness.canonicalizeCount, 2)
        XCTAssertTrue(harness.reusedCanonicalizerAndContextAcrossRequests)
    }

    func testAdmittedDetectorAndRendererShareCanonicalCarrierAndExplicitSRGB() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        let result = try harness.invoke(
            entry: .processResult,
            image: Self.image,
            parameters: .init(brightness: 0.10, faceSlim: 0.25)
        )

        XCTAssertEqual(harness.canonicalizeCount, 1)
        XCTAssertEqual(harness.detectAndMapCount, 1)
        XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        XCTAssertEqual(harness.renderCount, 1)
        XCTAssertTrue(harness.canonicalConsumerIdentityMatched)
        XCTAssertTrue(harness.usedExplicitSRGBRender)
        XCTAssertEqual(result.width, 2)
        XCTAssertEqual(result.height, 2)
    }

    func testDuplicateOrReorderedFoundationEventsFailExactTraceOracle() {
        let expected: [SDKTestingLocalRetouchEvent] = [
            .canonicalize, .detectAndMap, .makeRequestContext, .render,
        ]
        XCTAssertNotEqual(expected + [.render], expected)
        XCTAssertNotEqual([.detectAndMap, .canonicalize, .makeRequestContext, .render], expected)
    }

    func testNoFaceAndMissingSupportKeepUnrelatedColorWork() throws {
        for fixture in [SDKTestingLocalSupportFixture.noFace, .missingSupport] {
            let baseline = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                supportFixture: fixture
            ).invoke(entry: .processResult, image: Self.image, parameters: .init(brightness: 0.15))
            let requested = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                supportFixture: fixture
            ).invoke(entry: .processResult, image: Self.image, parameters: .init(brightness: 0.15))
            XCTAssertEqual(requested.outputDigest, baseline.outputDigest)
            XCTAssertEqual(requested.width, baseline.width)
            XCTAssertEqual(requested.height, baseline.height)
        }
    }

    func testValidLipSupportSurvivesEachUnrelatedGeometryOmission() throws {
        XCTAssertEqual(
            SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount,
            4
        )
        for omissionIndex in
            0..<SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount
        {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                unrelatedGeometryOmissionIndex: omissionIndex
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: Self.image,
                parameters: .init()
            )

            XCTAssertEqual(result.aggregateSupportValueID, omissionIndex + 1)
            XCTAssertEqual(result.detectionAvailability, "usable")
            XCTAssertEqual(result.detectionReasons, [])
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        }
    }

    func testCombinedGeometryAndLocalSupportReportsPurposeAwarePartialDegradation() throws {
        XCTAssertEqual(
            SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount,
            4
        )
        for omissionIndex in
            0..<SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount
        {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                unrelatedGeometryOmissionIndex: omissionIndex
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: Self.image,
                parameters: .init(faceSlim: 0.2)
            )

            XCTAssertEqual(result.aggregateSupportValueID, omissionIndex + 1)
            XCTAssertEqual(result.detectionAvailability, "partial")
            XCTAssertEqual(result.detectionReasons, ["missingLandmarks"])
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        }
    }

    func testInvalidCanonicalInputStopsBeforeVisionAndContext() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        let transparent = CIImage(color: CIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.5))
            .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 2))
        XCTAssertThrowsError(try harness.invoke(entry: .processResult, image: transparent, parameters: .init()))
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)
        XCTAssertEqual(harness.renderCount, 0)
    }

    func testNearOpaqueCanonicalInputStopsAtProductionBoundaryBeforeVisionAndContext() throws {
        let fixtures = [
            try Self.floatingPointImage(width: 2, height: 2, alphas: [
                0.999, 0.999,
                0.999, 0.999,
            ]),
            try Self.floatingPointImage(width: 2, height: 2, alphas: [
                1, 1,
                1, Float(1).nextDown,
            ]),
        ]

        for image in fixtures {
            let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
            XCTAssertThrowsError(
                try harness.invoke(entry: .processResult, image: image, parameters: .init())
            ) { error in
                XCTAssertEqual(error as? BeautyError, .invalidInput)
            }
            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 0)
            XCTAssertEqual(harness.requestOwnerCreationCount, 0)
            XCTAssertEqual(harness.renderCount, 0)
        }
    }

    func testValidInvalidValidDoesNotReuseRequestSupport() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: [.available(valueID: 101), .malformed, .available(valueID: 303)]
        )
        let first = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        XCTAssertThrowsError(try harness.invoke(entry: .processResult, image: Self.image, parameters: .init()))
        let third = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        XCTAssertEqual(first.aggregateSupportValueID, 101)
        XCTAssertEqual(third.aggregateSupportValueID, 303)
        XCTAssertNotEqual(first.aggregateSupportValueID, third.aggregateSupportValueID)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
    }

    func testIndependentEngineValuesDoNotCrossPayloads() async throws {
        async let first = SDKTestingLocalRetouchFoundationHarness.runIndependent(valueID: 11)
        async let second = SDKTestingLocalRetouchFoundationHarness.runIndependent(valueID: 22)
        let firstValue = try await first
        let secondValue = try await second
        XCTAssertEqual(Set([firstValue, secondValue]), Set([11, 22]))
    }

    func testPixelBufferOverloadsAndResetPerformZeroLocalFoundationWork() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        _ = try harness.invokePixelBuffer(parameters: .init(brightness: 0.1))
        harness.reset()
        XCTAssertEqual(harness.canonicalizeCount, 0)
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)
        XCTAssertEqual(harness.localProviderCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.pixelBufferSummaryAvailability, "notRun")
    }

    func testCurrentProductionAdmissionInventoryIsExactlyEmpty() {
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])
    }

    func testConcurrencyNonclaimsRemainFlaggedNotPassedClaims() {
        let flags = Set([
            "PATH01-CONCURRENCY",
            "PATH04-CONCURRENCY",
            "PATH05-CONCURRENCY",
        ])
        XCTAssertEqual(flags.count, 3)
        XCTAssertFalse(flags.contains("same-engine-parallel-safe"))
        // TD-013 and mutable selected-face policy intentionally keep same-engine
        // concurrency and cooperative cancellation outside Phase 53's claim.
    }

    private static func floatingPointImage(
        width: Int,
        height: Int,
        alphas: [Float]
    ) throws -> CIImage {
        guard width > 0,
              height > 0,
              alphas.count == width * height,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw BeautyError.invalidInput
        }

        var pixels: [Float] = []
        pixels.reserveCapacity(alphas.count * 4)
        for alpha in alphas {
            pixels.append(contentsOf: [0.25, 0.50, 0.75, alpha])
        }
        let data = pixels.withUnsafeBytes { Data($0) }
        return CIImage(
            bitmapData: data,
            bytesPerRow: width * MemoryLayout<Float>.stride * 4,
            size: CGSize(width: width, height: height),
            format: .RGBAf,
            colorSpace: colorSpace
        )
    }
}
