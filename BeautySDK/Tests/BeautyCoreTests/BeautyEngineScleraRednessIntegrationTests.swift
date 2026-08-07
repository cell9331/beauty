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
                image: redEyeImage(),
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
        let teethOnly = try makeHarness()
        _ = try teethOnly.invoke(
            entry: .processResult,
            image: redEyeImage(),
            parameters: BeautyParameters(teethWhitening: 1)
        )
        XCTAssertEqual(teethOnly.providerObservation.invocationCount, 1)
        XCTAssertEqual(teethOnly.scleraProviderObservation.invocationCount, 0)

        let scleraOnly = try makeHarness()
        _ = try scleraOnly.invoke(
            entry: .processResult,
            image: redEyeImage(),
            parameters: BeautyParameters(scleraRednessReduction: 1)
        )
        XCTAssertEqual(scleraOnly.providerObservation.invocationCount, 0)
        XCTAssertEqual(scleraOnly.scleraProviderObservation.invocationCount, 1)

        let both = try makeHarness()
        _ = try both.invoke(
            entry: .processResult,
            image: redEyeImage(),
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
                image: redEyeImage(),
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
                image: redEyeImage(),
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
            image: redEyeImage(),
            parameters: BeautyParameters()
        )
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)

        _ = try harness.invoke(
            entry: .processResult,
            image: redEyeImage(),
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
                    let harness = try self.makeHarness()
                    _ = try harness.invoke(
                        entry: .processResult,
                        image: self.redEyeImage(),
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

    private func makeHarness() throws -> SDKTestingLocalRetouchFoundationHarness {
        try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired]
        )
    }

    private func redEyeImage() -> CIImage {
        CIImage(color: CIColor(red: 0.82, green: 0.59, blue: 0.59, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 80, height: 48))
    }
}
