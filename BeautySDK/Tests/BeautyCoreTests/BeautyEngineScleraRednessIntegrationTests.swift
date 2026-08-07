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
        let cases: [(SDKTestingScleraEyeSupport, Int, Int)] = [
            (.leftOnly, 1, 0),
            (.rightOnly, 0, 1),
            (.leftValidRightMalformed, 1, 0),
            (.rightValidLeftMalformed, 0, 1),
        ]
        for (sequence, acceptedLeft, acceptedRight) in cases {
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
            XCTAssertEqual(harness.scleraProviderObservation.acceptedLeftEyeCount, acceptedLeft)
            XCTAssertEqual(harness.scleraProviderObservation.acceptedRightEyeCount, acceptedRight)
        }
    }

    func testBlinkGazeGlareAndOcclusionAbstainLocallyWithoutSuppressingPeer() throws {
        let cases: [(SDKTestingScleraEyeSupport, EyeAppearance)] = [
            (.leftValidRightBlink, .red),
            (.leftValidRightSevereGaze, .red),
            (.leftValidRightGlare, .glare),
            (.leftValidRightOccluded, .occluded),
        ]
        for (support, appearance) in cases {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                eyeSupportSequence: [support]
            )
            _ = try harness.invoke(
                entry: .processResult,
                image: try Self.redEyeImage(rightEyeAppearance: appearance),
                parameters: BeautyParameters(scleraRednessReduction: 1)
            )
            XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 1)
            XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 1)
            XCTAssertEqual(harness.scleraProviderObservation.acceptedLeftEyeCount, 1)
            XCTAssertEqual(harness.scleraProviderObservation.acceptedRightEyeCount, 0)
            XCTAssertEqual(harness.scleraProviderObservation.abstentionCount, 1)
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

    func testThrownCanonicalRequestClearsScleraObservationAndNextRequestRecovers() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired, .paired]
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters(scleraRednessReduction: 1)
        )
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)

        XCTAssertThrowsError(try harness.invoke(
            entry: .processResult,
            image: Self.unsupportedImage(),
            parameters: BeautyParameters(scleraRednessReduction: 1)
        ))
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)

        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(),
            parameters: BeautyParameters(scleraRednessReduction: 1)
        )
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)
    }

    func testMalformedScleraPeerDoesNotSuppressEligibleTeethUnit() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.leftValidRightMalformed]
        )
        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.redEyeImage(includeYellowMouth: true),
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 2)
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
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

    private enum EyeAppearance {
        case red
        case glare
        case occluded
    }

    private static func redEyeImage(
        rightEyeAppearance: EyeAppearance = .red,
        includeYellowMouth: Bool = false
    ) throws -> CIImage {
        let width = 64
        let height = 64
        var bytes = Array(repeating: UInt8(0), count: width * height * 4)
        for index in 0..<(width * height) {
            let offset = index * 4
            let isRightHalf = index % width >= width / 2
            let color: (UInt8, UInt8, UInt8) = if includeYellowMouth {
                (45, 24, 30)
            } else if isRightHalf {
                switch rightEyeAppearance {
                case .red: (209, 150, 150)
                case .glare: (246, 246, 246)
                case .occluded: (28, 25, 25)
                }
            } else {
                (209, 150, 150)
            }
            bytes[offset] = color.0
            bytes[offset + 1] = color.1
            bytes[offset + 2] = color.2
            bytes[offset + 3] = .max
        }
        if includeYellowMouth {
            for y in 16...29 {
                for x in 20...43 {
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

    private static func unsupportedImage() -> CIImage {
        CIImage(color: CIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 80, height: 48))
    }
}
