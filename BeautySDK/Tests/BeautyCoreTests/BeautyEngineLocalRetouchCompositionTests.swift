import CoreImage
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

/// Facade-adjacent mechanics coverage. Scenario names describe only opaque
/// unit shapes; public output bytes are rendered locally under explicit sRGB.
final class BeautyEngineLocalRetouchCompositionTests: XCTestCase {
    func testExactRequestContextSourceComposesOnce() throws {
        let harness = try makeHarness(.disjoint)
        _ = try invoke(harness, entry: .processResult)

        XCTAssertEqual(
            harness.events,
            [.canonicalize, .detectAndMap, .makeRequestContext, .compose, .render]
        )
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
        XCTAssertTrue(harness.compositionObservation.sourceBindingMatched)
    }

    func testOpaqueObservationIsAggregateOnlyAndDigestFree() throws {
        let harness = try makeHarness(.disjoint)
        _ = try invoke(harness, entry: .processResult)

        let labels = Set(
            Mirror(reflecting: harness.compositionObservation).children.compactMap(\.label)
        )
        XCTAssertEqual(labels, [
            "width",
            "height",
            "compositionInvocationCount",
            "sourceBindingMatched",
            "acceptedUnitCount",
            "rejectedUnitCount",
            "ownedPixelCount",
            "changedPixelCount",
            "changedOutsideUnionPixelCount",
            "collisionPixelCount",
        ])
    }

    func testBothExistingCIImageEntriesConsumeOneCanonicalBackingOnce() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let harness = try makeHarness(.disjoint)
            let result = try invoke(harness, entry: entry)

            XCTAssertEqual(try renderedRGBA8(result.output), Self.disjointBytes)
            XCTAssertEqual(
                harness.compositionObservation,
                SDKTestingLocalCompositionObservation(
                    width: 2,
                    height: 2,
                    compositionInvocationCount: 1,
                    sourceBindingMatched: true,
                    acceptedUnitCount: 3,
                    rejectedUnitCount: 0,
                    ownedPixelCount: 3,
                    changedPixelCount: 3,
                    changedOutsideUnionPixelCount: 0,
                    collisionPixelCount: 0
                )
            )
        }
    }

    func testOpaqueDisjointCollisionInvalidAndEmptyScenariosReachBothEntries() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            for scenario in [
                SDKTestingLocalCompositionScenario.disjoint,
                .collision,
                .invalidUnit,
                .empty,
            ] {
                let harness = try makeHarness(scenario)
                _ = try invoke(harness, entry: entry)
                XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
                XCTAssertTrue(harness.compositionObservation.sourceBindingMatched)
            }
        }
    }

    func testCollisionPreservesSourcePixelAndCountsOnce() throws {
        let harness = try makeHarness(.collision)
        let result = try invoke(harness, entry: .processResult)

        XCTAssertEqual(try renderedRGBA8(result.output), Self.collisionBytes)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)
        XCTAssertEqual(harness.compositionObservation.rejectedUnitCount, 0)
        XCTAssertEqual(harness.compositionObservation.ownedPixelCount, 1)
        XCTAssertEqual(harness.compositionObservation.changedPixelCount, 1)
        XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0)
        XCTAssertEqual(harness.compositionObservation.collisionPixelCount, 1)
    }

    func testAbsentAndMalformedLocalWorkPreserveUnrelatedBrightnessAndFilterContinuation() throws {
        let parameters = BeautyParameters(
            brightness: 0.15,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )
        for fixture in [SDKTestingLocalSupportFixture.noFace, .missingSupport] {
            let invalid = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                supportFixture: fixture,
                compositionScenario: .invalidUnit
            )
            let matchingAcceptedSiblings = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                supportFixture: fixture,
                compositionScenario: .secondUnitAbsent
            )
            let uncolored = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                supportFixture: fixture,
                compositionScenario: .invalidUnit
            )

            let invalidBytes = try renderedRGBA8(
                try invoke(invalid, entry: .processResult, parameters: parameters).output
            )
            let siblingBytes = try renderedRGBA8(
                try invoke(
                    matchingAcceptedSiblings,
                    entry: .processResult,
                    parameters: parameters
                ).output
            )
            let uncoloredBytes = try renderedRGBA8(
                try invoke(uncolored, entry: .processResult).output
            )

            XCTAssertEqual(invalidBytes, siblingBytes)
            XCTAssertNotEqual(invalidBytes, uncoloredBytes)
            XCTAssertEqual(invalid.compositionObservation.acceptedUnitCount, 2)
            XCTAssertEqual(invalid.compositionObservation.rejectedUnitCount, 0)
            XCTAssertEqual(invalid.compositionObservation.changedPixelCount, 2)
        }
    }

    func testOpaqueWholeRegionAndSubunitFailuresPreserveUnaffectedBytes() throws {
        let cases: [(SDKTestingLocalCompositionScenario, [UInt8], Int)] = [
            (.firstUnitAbsent, Self.firstAbsentBytes, 2),
            (.pairedUnitsAbsent, Self.pairedAbsentBytes, 1),
            (.secondUnitAbsent, Self.secondAbsentBytes, 2),
            (.thirdUnitAbsent, Self.thirdAbsentBytes, 2),
        ]

        for (scenario, expectedBytes, acceptedCount) in cases {
            let harness = try makeHarness(scenario)
            let result = try invoke(harness, entry: .processResult)
            XCTAssertEqual(try renderedRGBA8(result.output), expectedBytes)
            XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, acceptedCount)
            XCTAssertEqual(harness.compositionObservation.rejectedUnitCount, 0)
            XCTAssertEqual(harness.compositionObservation.changedPixelCount, acceptedCount)
        }
    }

    func testValidInvalidValidRequestsResetEveryCompositionObservation() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: [
                .available(valueID: 1),
                .available(valueID: 2),
                .available(valueID: 3),
            ],
            compositionScenarios: [.disjoint, .invalidUnit, .collision]
        )

        let first = try invoke(harness, entry: .processResult)
        let firstObservation = harness.compositionObservation
        let middle = try invoke(harness, entry: .processResult)
        let middleObservation = harness.compositionObservation
        let third = try invoke(harness, entry: .processResult)
        let thirdObservation = harness.compositionObservation

        XCTAssertEqual(try renderedRGBA8(first.output), Self.disjointBytes)
        XCTAssertEqual(try renderedRGBA8(middle.output), Self.secondAbsentBytes)
        XCTAssertEqual(try renderedRGBA8(third.output), Self.collisionBytes)
        XCTAssertEqual(firstObservation.acceptedUnitCount, 3)
        XCTAssertEqual(firstObservation.rejectedUnitCount, 0)
        XCTAssertEqual(middleObservation.acceptedUnitCount, 2)
        XCTAssertEqual(middleObservation.rejectedUnitCount, 0)
        XCTAssertEqual(middleObservation.collisionPixelCount, 0)
        XCTAssertEqual(thirdObservation.acceptedUnitCount, 3)
        XCTAssertEqual(thirdObservation.rejectedUnitCount, 0)
        XCTAssertEqual(thirdObservation.ownedPixelCount, 1)
        XCTAssertEqual(thirdObservation.collisionPixelCount, 1)
    }

    func testThrownRequestClearsObservationBeforeThirdValidRequest() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: [
                .available(valueID: 1),
                .malformed,
                .available(valueID: 3),
            ],
            compositionScenarios: [.disjoint, .collision, .thirdUnitAbsent]
        )

        _ = try invoke(harness, entry: .processResult)
        XCTAssertThrowsError(try invoke(harness, entry: .processResult))
        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
        let third = try invoke(harness, entry: .processResult)

        XCTAssertEqual(try renderedRGBA8(third.output), Self.thirdAbsentBytes)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 2)
        XCTAssertEqual(harness.compositionObservation.rejectedUnitCount, 0)
        XCTAssertEqual(harness.compositionObservation.collisionPixelCount, 0)
    }

    func testExistingFoundationTraceRemainsCanonicalizeDetectMapContextRender() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        _ = try invoke(harness, entry: .processResult)
        XCTAssertEqual(
            harness.events,
            [.canonicalize, .detectAndMap, .makeRequestContext, .render]
        )
        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
    }

    func testPixelBufferAndResetRoutesPerformZeroCompositionWork() throws {
        let harness = try makeHarness(.disjoint)
        try harness.invokePixelBuffer(parameters: .init(brightness: 0.1))
        harness.reset()

        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
        XCTAssertEqual(harness.events, [])
        XCTAssertEqual(harness.canonicalizeCount, 0)
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)

        _ = try invoke(harness, entry: .processResult)
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
    }

    func testProductionAdmissionAndCandidateInventoryRemainExactlyEmpty() {
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])
    }

    func testPhase58FeatureNeutralCompositionPublishesOnlySixAggregateCounters() throws {
        let harness = try makeHarness(.disjoint)
        _ = try invoke(harness, entry: .processResult)
        let observation = harness.compositionObservation

        let counters = [
            observation.acceptedUnitCount,
            observation.rejectedUnitCount,
            observation.ownedPixelCount,
            observation.changedPixelCount,
            observation.changedOutsideUnionPixelCount,
            observation.collisionPixelCount,
        ]
        XCTAssertEqual(counters, [3, 0, 3, 3, 0, 0])
        XCTAssertEqual(counters.count, 6)
        XCTAssertTrue(observation.sourceBindingMatched)
        XCTAssertEqual(observation.compositionInvocationCount, 1)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])
    }
}

private extension BeautyEngineLocalRetouchCompositionTests {
    static let sourceBytes: [UInt8] = [
        51, 102, 153, 255, 51, 102, 153, 255,
        51, 102, 153, 255, 51, 102, 153, 255,
    ]
    static let disjointBytes: [UInt8] = [
        201, 41, 11, 255, 21, 211, 61, 255,
        71, 31, 221, 255, 51, 102, 153, 255,
    ]
    static let collisionBytes: [UInt8] = [
        51, 102, 153, 255, 71, 31, 221, 255,
        51, 102, 153, 255, 51, 102, 153, 255,
    ]
    static let firstAbsentBytes: [UInt8] = [
        51, 102, 153, 255, 21, 211, 61, 255,
        71, 31, 221, 255, 51, 102, 153, 255,
    ]
    static let pairedAbsentBytes: [UInt8] = [
        201, 41, 11, 255, 51, 102, 153, 255,
        51, 102, 153, 255, 51, 102, 153, 255,
    ]
    static let secondAbsentBytes: [UInt8] = [
        201, 41, 11, 255, 51, 102, 153, 255,
        71, 31, 221, 255, 51, 102, 153, 255,
    ]
    static let thirdAbsentBytes: [UInt8] = [
        201, 41, 11, 255, 21, 211, 61, 255,
        51, 102, 153, 255, 51, 102, 153, 255,
    ]

    func makeHarness(
        _ scenario: SDKTestingLocalCompositionScenario
    ) throws -> SDKTestingLocalRetouchFoundationHarness {
        try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            compositionScenario: scenario
        )
    }

    func invoke(
        _ harness: SDKTestingLocalRetouchFoundationHarness,
        entry: SDKTestingStillImageFacadeEntry,
        parameters: BeautyParameters = .init()
    ) throws -> SDKTestingLocalResult {
        try harness.invoke(
            entry: entry,
            image: Self.image(),
            parameters: parameters
        )
    }

    static func image() -> CIImage {
        CIImage(
            bitmapData: Data(sourceBytes),
            bytesPerRow: 8,
            size: CGSize(width: 2, height: 2),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    func renderedRGBA8(_ image: CIImage) throws -> [UInt8] {
        let bounds = image.extent.integral
        guard bounds.width == 2,
              bounds.height == 2,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw BeautyError.invalidInput
        }
        var bytes = [UInt8](repeating: 0, count: 16)
        CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ]).render(
            image,
            toBitmap: &bytes,
            rowBytes: 8,
            bounds: bounds,
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return bytes
    }
}
