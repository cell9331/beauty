import CoreImage
import XCTest
@_spi(Testing) @testable import BeautySDK

final class BeautyEngineScleraRednessIntegrationTests: XCTestCase {
    func testDirectScleraIntentUsesOneRequestOneProviderAndOneComposition() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                eyeSupportSequence: [.paired]
            )
            _ = try harness.invoke(
                entry: entry,
                image: try Self.redEyeImage(),
                parameters: BeautyParameters(scleraRednessReduction: 1)
            )

            XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 1)
            XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)
            XCTAssertEqual(harness.scleraProviderObservation.acceptedLeftEyeCount, 1)
            XCTAssertEqual(harness.scleraProviderObservation.acceptedRightEyeCount, 1)
            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
            XCTAssertEqual(harness.events, [.canonicalize, .detectAndMap, .makeRequestContext, .compose, .render])
        }
    }

    func testTeethScleraAndBothActivateIndependentlyButShareOneOwner() throws {
        let teethOnly = try Self.makeHarness()
        _ = try teethOnly.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters(teethWhitening: 1)
        )
        XCTAssertEqual(teethOnly.providerObservation.invocationCount, 1)
        XCTAssertEqual(teethOnly.scleraProviderObservation.invocationCount, 0)

        let scleraOnly = try Self.makeHarness()
        _ = try scleraOnly.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters(scleraRednessReduction: 1)
        )
        XCTAssertEqual(scleraOnly.providerObservation.invocationCount, 0)
        XCTAssertEqual(scleraOnly.scleraProviderObservation.invocationCount, 1)

        let both = try Self.makeHarness()
        _ = try both.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )
        XCTAssertEqual(both.providerObservation.invocationCount, 1)
        XCTAssertEqual(both.scleraProviderObservation.invocationCount, 1)
        XCTAssertEqual(both.compositionObservation.compositionInvocationCount, 1)
    }

    func testOneInvalidEyeDoesNotSuppressAcceptedPeer() throws {
        for sequence in [SDKTestingScleraEyeSupport.leftOnly, .rightOnly, .leftValidRightMalformed] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                eyeSupportSequence: [sequence]
            )
            _ = try harness.invoke(
                entry: .processResult,
                image: try Self.redEyeImage(),
                parameters: BeautyParameters(scleraRednessReduction: 1)
            )
            XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 1)
            XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 1)
        }
    }

    func testInvalidOrderNoFaceAndUnsafeEyesAbstainWithoutStaleReuse() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired, .invalidOrder, .noFace, .paired]
        )
        for expectedUnits in [2, 0, 0, 2] {
            _ = try harness.invoke(
                entry: .processResult,
                image: try Self.redEyeImage(),
                parameters: BeautyParameters(scleraRednessReduction: 1)
            )
            XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, expectedUnits)
            XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
            XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        }
    }

    func testPixelBufferResetAndOpaqueTestingDemandPerformZeroScleraWork() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            eyeSupportSequence: [.paired]
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters()
        )
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)

        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters(scleraRednessReduction: 1)
        )
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 1)
        try harness.invokePixelBuffer(parameters: BeautyParameters(scleraRednessReduction: 1))
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)
        harness.reset()
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)
    }

    func testIndependentParallelRequestsKeepPerEyeStateIsolated() async throws {
        let observations = try await withThrowingTaskGroup(of: (Int, Int).self) { group in
            for _ in 0..<12 {
                group.addTask {
                    let harness = try Self.makeHarness()
                    _ = try harness.invoke(
                        entry: .processResult,
                        image: try Self.redEyeImage(),
                        parameters: BeautyParameters(scleraRednessReduction: 1)
                    )
                    return (
                        harness.scleraProviderObservation.invocationCount,
                        harness.scleraProviderObservation.issuedUnitCount
                    )
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        XCTAssertEqual(observations.count, 12)
        XCTAssertTrue(observations.allSatisfy { $0 == 1 && $1 == 2 })
    }

    private static func makeHarness() throws -> SDKTestingLocalRetouchFoundationHarness {
        try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired]
        )
    }

    private static func redEyeImage() throws -> CIImage {
        let width = 80
        let height = 48
        var bytes = Array(repeating: UInt8(0), count: width * height * 4)
        for index in 0..<(width * height) {
            let offset = index * 4
            bytes[offset] = 209
            bytes[offset + 1] = 150
            bytes[offset + 2] = 150
            bytes[offset + 3] = .max
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
}
