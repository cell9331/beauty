import CoreGraphics
import Foundation
import ImageIO
import XCTest
import BeautyCore
@testable import BeautyDetection

/// Wave 0 request-local observed-lip specification. The opaque test harness and
/// observed-lip carrier are supplied by Plan 53-03, so this suite is RED now.
final class StillImageRequestSupportTests: XCTestCase {
    func testRequestMappingBoundaryCountsAreExact() throws {
        for (count, accepted) in [(0, false), (1, true), (32, true), (33, false)] {
            let harness = SDKTestingStillImageRequestSupportHarness(outerPointCount: count)
            let result = try harness.mapOneRequest()
            XCTAssertEqual(result.outerPointCount, accepted ? count : 0)
            XCTAssertEqual(result.mappingInvocationCount, accepted ? 1 : 0)
            XCTAssertEqual(result.visionRequestCount, 1)
        }
    }

    func testNoFaceAndMissingLipsRemainEmpty() throws {
        for fixture in [SDKTestingLipFixture.noFace, .missingOuterAndInner] {
            let result = try SDKTestingStillImageRequestSupportHarness(fixture: fixture).mapOneRequest()
            XCTAssertEqual(result.outerPointCount, 0)
            XCTAssertEqual(result.innerPointCount, 0)
            XCTAssertEqual(result.mappingInvocationCount, 0)
            XCTAssertFalse(result.usedSyntheticFaceBoxLips)
        }
    }

    func testMappingCountPrecisionAndOverflowAreExact() throws {
        for count in [Int.max, Int.max - 1, 33] {
            let result = try SDKTestingStillImageRequestSupportHarness(outerPointCount: count).mapOneRequest()
            XCTAssertEqual(result.outerPointCount, 0)
            XCTAssertEqual(result.mappingInvocationCount, 0)
            XCTAssertEqual(result.allocatedPointCount, 0)
        }
    }

    func testMalformedInnerDoesNotEraseValidOuter() throws {
        let result = try SDKTestingStillImageRequestSupportHarness(
            fixture: .validOuterMalformedInner
        ).mapOneRequest()
        XCTAssertGreaterThan(result.outerPointCount, 0)
        XCTAssertEqual(result.innerPointCount, 0)
        XCTAssertEqual(result.mappingInvocationCount, 1)
    }

    func testStableProviderOrderAndTiesMapEachAcceptedRegionOnce() throws {
        let result = try SDKTestingStillImageRequestSupportHarness(
            fixture: .validOuterAndInnerWithSelectionTie
        ).mapOneRequest()
        XCTAssertEqual(result.selectedStableID, "first")
        XCTAssertEqual(result.mappingInvocationCount, 2)
        XCTAssertEqual(result.providerOrder, ["outer", "inner"])
    }

    func testValidInvalidValidDoesNotReuseObservedLipSupport() throws {
        let harness = SDKTestingStillImageRequestSupportHarness(
            fixtureSequence: [.valueID(7), .malformed, .valueID(9)]
        )
        XCTAssertEqual(try harness.mapOneRequest().aggregateValueID, 7)
        XCTAssertEqual(try harness.mapOneRequest().aggregateValueID, nil)
        XCTAssertEqual(try harness.mapOneRequest().aggregateValueID, 9)
        XCTAssertEqual(harness.retainedSupportCount, 0)
    }

    func testIndependentParallelDetectorValuesDoNotCross() async throws {
        async let a = SDKTestingStillImageRequestSupportHarness.runIndependent(valueID: 41)
        async let b = SDKTestingStillImageRequestSupportHarness.runIndependent(valueID: 82)
        let first = try await a
        let second = try await b
        XCTAssertEqual(Set([first, second]), Set([41, 82]))
        // PATH04-CONCURRENCY remains a same-engine selected-face nonclaim.
    }

    func testDescriptionsDebugDumpsAndMirrorsExposeCountsOnly() throws {
        let result = try SDKTestingStillImageRequestSupportHarness(
            fixture: .validOuterAndInner
        ).mapOneRequest()
        let aggregate = [result.description, result.debugDescription, result.dump, result.mirror]
            .joined(separator: " ").lowercased()
        XCTAssertTrue(aggregate.contains("outercount"))
        XCTAssertTrue(aggregate.contains("innercount"))
        for forbidden in ["coordinate", "point(", "stableid", "bounds", "pixel", "mask", "/private/", "file://"] {
            XCTAssertFalse(aggregate.contains(forbidden), forbidden)
        }
    }
}

private enum Phase53MissingObservedLipSeam: Error { case absent }
private enum SDKTestingLipFixture {
    case noFace, missingOuterAndInner, validOuterMalformedInner
    case validOuterAndInnerWithSelectionTie, validOuterAndInner, malformed
    case valueID(Int)
}
private struct SDKTestingLipResult: CustomStringConvertible, CustomDebugStringConvertible {
    let outerPointCount: Int
    let innerPointCount: Int
    let mappingInvocationCount: Int
    let visionRequestCount: Int
    let usedSyntheticFaceBoxLips: Bool
    let allocatedPointCount: Int
    let selectedStableID: String?
    let providerOrder: [String]
    let aggregateValueID: Int?
    let dump: String
    let mirror: String
    var description: String { "outerCount=\(outerPointCount) innerCount=\(innerPointCount)" }
    var debugDescription: String { description }
}
private final class SDKTestingStillImageRequestSupportHarness {
    let retainedSupportCount = 0
    init(outerPointCount: Int) { _ = outerPointCount }
    init(fixture: SDKTestingLipFixture) { _ = fixture }
    init(fixtureSequence: [SDKTestingLipFixture]) { _ = fixtureSequence }
    func mapOneRequest() throws -> SDKTestingLipResult {
        throw Phase53MissingObservedLipSeam.absent
    }
    static func runIndependent(valueID: Int) async throws -> Int {
        _ = valueID
        throw Phase53MissingObservedLipSeam.absent
    }
}
