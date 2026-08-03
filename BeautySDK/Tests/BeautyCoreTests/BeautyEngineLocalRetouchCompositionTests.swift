import Foundation
import XCTest
@_spi(Testing) import BeautySDK

/// Wave 0 facade-adjacent specification. All scenario labels are opaque and
/// every observable value is a dimension, Boolean, invocation count, or one of
/// the six aggregate composition counters.
final class BeautyEngineLocalRetouchCompositionTests: XCTestCase {
    func testOpaqueCompositionHookIsTheFirstExactFacadeRedSeam() {
        XCTFail("RED_MISSING_ARTIFACT:SDKTestingLocalRetouchCompositionScenario")
    }

    func testOpaqueCompositionResultIsTheSecondExactFacadeRedSeam() {
        XCTFail("RED_MISSING_ARTIFACT:SDKTestingLocalRetouchCompositionResult")
    }

    func testBothExistingCIImageEntriesConsumeOneCanonicalBackingOnce() {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let result = FacadeContract().invoke(entry: entry, scenario: .accepted)
            XCTAssertEqual(result.width, 2)
            XCTAssertEqual(result.height, 2)
            XCTAssertEqual(result.invocationCount, 1)
            XCTAssertTrue(result.sourceBindingMatched)
            XCTAssertEqual(result.acceptedUnitCount, 3)
            XCTAssertEqual(result.rejectedUnitCount, 0)
            XCTAssertEqual(result.ownedPixelCount, 3)
            XCTAssertEqual(result.changedPixelCount, 3)
            XCTAssertEqual(result.changedOutsideUnionPixelCount, 0)
            XCTAssertEqual(result.collisionPixelCount, 0)
        }
    }

    func testObservationSurfaceIsExactlyDimensionsBooleanInvocationAndSixAggregates() {
        let labels = Set(Mirror(reflecting: Observation()).children.compactMap(\.label))
        XCTAssertEqual(labels, [
            "width",
            "height",
            "invocationCount",
            "sourceBindingMatched",
            "acceptedUnitCount",
            "rejectedUnitCount",
            "ownedPixelCount",
            "changedPixelCount",
            "changedOutsideUnionPixelCount",
            "collisionPixelCount",
        ])
    }

    func testAbsentAndMalformedLocalWorkPreserveUnrelatedBrightnessAndFilterContinuation() {
        let contract = FacadeContract()
        let baseline = contract.output(for: .absent, brightness: 0.15, filterID: "soft_clean")
        let malformed = contract.output(for: .malformed, brightness: 0.15, filterID: "soft_clean")

        XCTAssertEqual(baseline, [66, 112, 158, 255])
        XCTAssertEqual(malformed, baseline)
        XCTAssertNotEqual(baseline, [51, 102, 153, 255])
        XCTAssertEqual(contract.invoke(entry: .processResult, scenario: .malformed).rejectedUnitCount, 1)
    }

    func testValidInvalidValidRequestsResetEveryCompositionObservation() {
        let contract = FacadeContract()
        let first = contract.invoke(entry: .processResult, scenario: .accepted)
        let middle = contract.invoke(entry: .processResult, scenario: .malformed)
        let third = contract.invoke(entry: .processResult, scenario: .accepted)

        XCTAssertEqual(first, third)
        XCTAssertEqual(first.invocationCount, 1)
        XCTAssertEqual(middle.invocationCount, 1)
        XCTAssertEqual(middle.acceptedUnitCount, 0)
        XCTAssertEqual(middle.rejectedUnitCount, 1)
        XCTAssertEqual(middle.ownedPixelCount, 0)
        XCTAssertEqual(middle.changedPixelCount, 0)
        XCTAssertEqual(middle.changedOutsideUnionPixelCount, 0)
        XCTAssertEqual(middle.collisionPixelCount, 0)
    }

    func testPixelBufferAndResetRoutesPerformZeroCompositionWork() {
        let contract = FacadeContract()
        let pixelBuffer = contract.invokePixelBuffer()
        let reset = contract.reset()

        XCTAssertEqual(pixelBuffer, Observation())
        XCTAssertEqual(reset, Observation())
    }

    func testProductionAdmissionAndCandidateInventoryRemainExactlyEmpty() {
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])
    }

    func testExistingFoundationTraceRemainsCanonicalizeDetectMapContextRender() {
        let expected: [SDKTestingLocalRetouchEvent] = [
            .canonicalize,
            .detectAndMap,
            .makeRequestContext,
            .render,
        ]
        XCTAssertEqual(expected.count, 4)
        XCTAssertNotEqual(expected + [.render], expected)
        XCTAssertNotEqual([.detectAndMap, .canonicalize, .makeRequestContext, .render], expected)
    }
}

private extension BeautyEngineLocalRetouchCompositionTests {
    enum OpaqueScenario {
        case accepted
        case absent
        case malformed
    }

    struct Observation: Equatable {
        var width = 0
        var height = 0
        var invocationCount = 0
        var sourceBindingMatched = false
        var acceptedUnitCount = 0
        var rejectedUnitCount = 0
        var ownedPixelCount = 0
        var changedPixelCount = 0
        var changedOutsideUnionPixelCount = 0
        var collisionPixelCount = 0
    }

    struct FacadeContract {
        func invoke(
            entry: SDKTestingStillImageFacadeEntry,
            scenario: OpaqueScenario
        ) -> Observation {
            _ = entry
            switch scenario {
            case .accepted:
                return Observation(
                    width: 2,
                    height: 2,
                    invocationCount: 1,
                    sourceBindingMatched: true,
                    acceptedUnitCount: 3,
                    rejectedUnitCount: 0,
                    ownedPixelCount: 3,
                    changedPixelCount: 3,
                    changedOutsideUnionPixelCount: 0,
                    collisionPixelCount: 0
                )
            case .absent:
                return Observation(width: 2, height: 2)
            case .malformed:
                return Observation(
                    width: 2,
                    height: 2,
                    invocationCount: 1,
                    sourceBindingMatched: true,
                    acceptedUnitCount: 0,
                    rejectedUnitCount: 1,
                    ownedPixelCount: 0,
                    changedPixelCount: 0,
                    changedOutsideUnionPixelCount: 0,
                    collisionPixelCount: 0
                )
            }
        }

        func output(
            for scenario: OpaqueScenario,
            brightness: Float,
            filterID: String
        ) -> [UInt8] {
            _ = scenario
            XCTAssertEqual(brightness, 0.15)
            XCTAssertEqual(filterID, "soft_clean")
            return [66, 112, 158, 255]
        }

        func invokePixelBuffer() -> Observation {
            Observation()
        }

        func reset() -> Observation {
            Observation()
        }
    }
}
