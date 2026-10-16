import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyEyebrowBackendAdmissionTests: XCTestCase {
    private let metric = "beauty.effects.eyebrowAdmittedSideCount"

    func testAdmissionDiagnosticsExposeOnlyTheFixedBoundedStillImageCounter() throws {
        let request = try makeRequest(policy: .cpu, plan: requestedPlan())
        for count in 0...2 {
            let diagnostics = BeautyBackendDiagnostics(width: 2, height: 2,
                preservesAlpha: true, preservesExtent: true, eyebrowAdmittedSideCount: count)
            let result = try BeautyBackendResult(output: requestOutput(request), diagnostics: diagnostics, for: request)
            XCTAssertEqual(result.diagnostics.eyebrowAdmittedSideCount, count)
            XCTAssertEqual(result.diagnostics.metrics, [metric: Double(count)])
        }
        for count in [-1, 3, Int.max] {
            let invalid = BeautyBackendDiagnostics(width: 2, height: 2,
                preservesAlpha: true, preservesExtent: true, eyebrowAdmittedSideCount: count)
            XCTAssertThrowsError(try BeautyBackendResult(output: requestOutput(request), diagnostics: invalid, for: request)) {
                XCTAssertEqual($0 as? BeautyError, .invalidInput)
            }
        }
        let neutral = try makeRequest(policy: .cpu, plan: .init())
        let unrelated = BeautyBackendDiagnostics(width: 2, height: 2,
            preservesAlpha: true, preservesExtent: true, eyebrowAdmittedSideCount: 1)
        XCTAssertThrowsError(try BeautyBackendResult(output: requestOutput(neutral), diagnostics: unrelated, for: neutral))
        let absent = BeautyBackendDiagnostics(width: 2, height: 2, preservesAlpha: true, preservesExtent: true)
        XCTAssertNil(absent.eyebrowAdmittedSideCount)
        XCTAssertTrue(absent.metrics.isEmpty)
    }

    func testCPURequestedButMissingMapReportsZeroAndNeutralDoesNotReuseTheCounter() throws {
        let backend = BeautyCPUBackend()
        for canonical in [false, true] {
            for plan in [requestedPlan(), BeautyEffectPlan(skippedDomains: [.eyebrows])] {
                let rejected = try backend.execute(makeRequest(policy: .cpu, plan: plan, canonical: canonical))
                XCTAssertEqual(rejected.diagnostics.eyebrowAdmittedSideCount, 0)
                XCTAssertEqual(rejected.diagnostics.metrics, [metric: 0])
            }
            let neutral = try backend.execute(makeRequest(policy: .cpu, plan: .init(), canonical: canonical))
            XCTAssertNil(neutral.diagnostics.eyebrowAdmittedSideCount)
            XCTAssertTrue(neutral.diagnostics.metrics.isEmpty, "Admission is request-local, not sticky backend state")
        }
    }

    func testSelectedMetalRequestedButMissingMapReportsZeroAndNeutralDoesNotReuseTheCounter() throws {
        let counter = InvocationCounter()
        let backend: BeautyMetalBackend
        do { backend = try BeautyMetalBackend(hooks: .init(onRuntimeInvocation: { counter.increment() })) }
        catch BeautyError.metalUnavailable { throw XCTSkip("Metal unavailable; no executed admission-counter claim") }
        for plan in [requestedPlan(), BeautyEffectPlan(skippedDomains: [.eyebrows])] {
            let rejected = try backend.execute(makeRequest(policy: .metal, plan: plan, canonical: true))
            XCTAssertEqual(rejected.diagnostics.eyebrowAdmittedSideCount, 0)
            XCTAssertEqual(rejected.diagnostics.metrics, [metric: 0])
        }
        let neutral = try backend.execute(makeRequest(policy: .metal, plan: .init(), canonical: true))
        XCTAssertNil(neutral.diagnostics.eyebrowAdmittedSideCount)
        XCTAssertTrue(neutral.diagnostics.metrics.isEmpty)
        XCTAssertEqual(counter.value, 3, "All selected calls execute the Metal runtime")
    }

    func testMissingMapAndMissingFacePublishOneZeroAtTheStageAndColorCutpoints() throws {
        let plan = requestedPlan()
        let pixels: [UInt8] = Array(repeating: [80, 70, 60, 255], count: 4).flatMap { $0 }
        let stage = BeautyStillImageGeometryStage(sourceRGBA: pixels, width: 2, height: 2, plan: plan, face: nil)
        var stageCounts = [Int]()
        XCTAssertEqual(stage.applyingContinuousEyebrows(to: pixels, onAppliedSideCount: { stageCounts.append($0) }), pixels)
        XCTAssertEqual(stageCounts, [0])
        let input = try makeRequest(policy: .cpu, plan: plan)
        guard case .stillImage(let image) = input.input else { return XCTFail("still image required") }
        var colorCounts = [Int]()
        _ = BeautyColorEffectPipeline.apply(to: image, plan: plan, selectedFaceObservation: nil,
            onEyebrowAppliedSideCount: { colorCounts.append($0) })
        XCTAssertEqual(colorCounts, [0])
    }

    private func requestedPlan() -> BeautyEffectPlan {
        var strengths = BeautyEffectiveStrengths()
        strengths.eyebrowThickness = 0.00125
        return BeautyEffectPlan(activeDomains: [.eyebrows], effectiveStrengths: strengths)
    }
    private func makeRequest(policy: BeautyBackendExecutionPolicy, plan: BeautyEffectPlan,
                         canonical: Bool = false) throws -> BeautyBackendRequest {
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let source = try BeautyCanonicalStillImage(
            rgba8Data: Data(Array(repeating: [UInt8(80), 70, 60, 255], count: 4).flatMap { $0 }),
            width: 2, height: 2, rowBytes: 8, metadata: metadata)
        return try BeautyBackendRequest(policy: policy, input: .stillImage(source.ciImage),
            metadata: metadata, plan: plan, canonicalImage: canonical ? source : nil)
    }
    private func requestOutput(_ request: BeautyBackendRequest) -> BeautyBackendOutput {
        switch request.input {
        case .stillImage(let image): .stillImage(image)
        case .pixelBuffer(let buffer): .pixelBuffer(buffer)
        }
    }
    private final class InvocationCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); defer { lock.unlock() }; count += 1 }
    }
}
