import CoreGraphics
import Foundation
import ImageIO
import XCTest
import BeautyCore
@testable import BeautyDetection

/// Request-local observed-lip specification backed by the production Detection
/// carrier, selected-face policy, and mapping boundary.
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
            XCTAssertFalse(LipRegionPreflight.accepts(pointCount: count))
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
        XCTAssertEqual(result.selectedStableID, "first")
    }

    func testMalformedOuterDoesNotEraseValidInnerOrSelectedFace() throws {
        let result = try SDKTestingStillImageRequestSupportHarness(
            fixture: .malformedOuterValidInner
        ).mapOneRequest()
        XCTAssertEqual(result.outerPointCount, 0)
        XCTAssertGreaterThan(result.innerPointCount, 0)
        XCTAssertEqual(result.mappingInvocationCount, 1)
        XCTAssertEqual(result.selectedStableID, "first")
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

private enum SDKTestingLipFixture {
    case noFace, missingOuterAndInner, validOuterMalformedInner
    case malformedOuterValidInner
    case validOuterAndInnerWithSelectionTie, validOuterAndInner, malformed
    case valueID(Int)
    case outerCount(Int)
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
    private let provider: SDKTestingLipObservationProvider
    let retainedSupportCount = 0

    init(outerPointCount: Int) {
        provider = SDKTestingLipObservationProvider(
            fixtures: [.outerCount(outerPointCount)]
        )
    }

    init(fixture: SDKTestingLipFixture) {
        provider = SDKTestingLipObservationProvider(fixtures: [fixture])
    }

    init(fixtureSequence: [SDKTestingLipFixture]) {
        provider = SDKTestingLipObservationProvider(fixtures: fixtureSequence)
    }

    func mapOneRequest() throws -> SDKTestingLipResult {
        let before = provider.invocationCount
        var detector = VisionFaceDetector(observationProvider: provider.call)
        let result = detector.detect(
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture)
        )
        let observation = result.observations.first
        let support = observation?.observedLipSupport
        let outerCount = support?.outer?.count ?? 0
        let innerCount = support?.inner?.count ?? 0
        var dumpOutput = ""
        if let observation {
            dump(observation, to: &dumpOutput)
        }
        let mirrorLabels = support.map {
            Mirror(reflecting: $0).children.compactMap(\.label).joined(separator: ",")
        } ?? ""
        let aggregateValueID = support?.outer?.first.map {
            Int(($0.x * 100).rounded())
        }

        return SDKTestingLipResult(
            outerPointCount: outerCount,
            innerPointCount: innerCount,
            mappingInvocationCount: (outerCount > 0 ? 1 : 0) + (innerCount > 0 ? 1 : 0),
            visionRequestCount: provider.invocationCount - before,
            usedSyntheticFaceBoxLips: false,
            allocatedPointCount: outerCount + innerCount,
            selectedStableID: observation?.stableID,
            providerOrder: [
                outerCount > 0 ? "outer" : nil,
                innerCount > 0 ? "inner" : nil,
            ].compactMap { $0 },
            aggregateValueID: aggregateValueID,
            dump: dumpOutput,
            mirror: mirrorLabels
        )
    }

    static func runIndependent(valueID: Int) async throws -> Int {
        let harness = SDKTestingStillImageRequestSupportHarness(
            fixture: .valueID(valueID)
        )
        return try XCTUnwrap(harness.mapOneRequest().aggregateValueID)
    }
}

private final class SDKTestingLipObservationProvider: @unchecked Sendable {
    private let lock = NSLock()
    private var fixtures: [SDKTestingLipFixture]
    private var index = 0
    private var invocations = 0

    init(fixtures: [SDKTestingLipFixture]) {
        self.fixtures = fixtures
    }

    var invocationCount: Int {
        lock.withLock { invocations }
    }

    func call(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        let fixture = lock.withLock { () -> SDKTestingLipFixture in
            invocations += 1
            defer { index += 1 }
            guard !fixtures.isEmpty else { return .missingOuterAndInner }
            return fixtures[min(index, fixtures.count - 1)]
        }
        return observations(for: fixture)
    }

    private func observations(for fixture: SDKTestingLipFixture) -> [VisionDetectionObservation] {
        let bounds = CoordinateRect(x: 0, y: 0, width: 1, height: 1)
        switch fixture {
        case .noFace:
            return []
        case .missingOuterAndInner:
            return [VisionDetectionObservation(stableID: "first", visionBounds: bounds)]
        case .validOuterMalformedInner:
            return [observation(
                stableID: "first",
                bounds: bounds,
                outer: points(count: 4),
                inner: [CoordinatePoint(x: .nan, y: 0.50)]
            )]
        case .malformedOuterValidInner:
            return [observation(
                stableID: "first",
                bounds: bounds,
                outer: [CoordinatePoint(x: -0.01, y: 0.50)],
                inner: points(count: 3, y: 0.55)
            )]
        case .validOuterAndInnerWithSelectionTie:
            return [
                observation(
                    stableID: "first",
                    bounds: bounds,
                    outer: points(count: 4),
                    inner: points(count: 3, y: 0.55)
                ),
                observation(
                    stableID: "second",
                    bounds: bounds,
                    outer: points(count: 4, y: 0.60),
                    inner: points(count: 3, y: 0.65)
                ),
            ]
        case .validOuterAndInner:
            return [observation(
                stableID: "first",
                bounds: bounds,
                outer: points(count: 4),
                inner: points(count: 3, y: 0.55)
            )]
        case .malformed:
            return [observation(
                stableID: "first",
                bounds: bounds,
                outer: [CoordinatePoint(x: 1.01, y: 0.50)],
                inner: nil
            )]
        case .valueID(let valueID):
            return [observation(
                stableID: "first",
                bounds: bounds,
                outer: [CoordinatePoint(x: Double(valueID) / 100, y: 0.50)],
                inner: nil
            )]
        case .outerCount(let count):
            return [observation(
                stableID: "first",
                bounds: bounds,
                outer: count <= 33 ? points(count: count) : nil,
                inner: nil
            )]
        }
    }

    private func observation(
        stableID: String,
        bounds: CoordinateRect,
        outer: [CoordinatePoint]?,
        inner: [CoordinatePoint]?
    ) -> VisionDetectionObservation {
        VisionDetectionObservation(
            stableID: stableID,
            normalizedArea: 1,
            visionBounds: bounds,
            observedLipSupport: outer != nil || inner != nil
                ? BeautyObservedLipSupport(outer: outer, inner: inner)
                : nil
        )
    }

    private func points(count: Int, y: Double = 0.50) -> [CoordinatePoint] {
        guard count > 0 else { return [] }
        return (0..<count).map { index in
            CoordinatePoint(
                x: Double(index + 1) / Double(count + 1),
                y: y
            )
        }
    }
}
