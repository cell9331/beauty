import Foundation
import Metal
import XCTest
@testable import BeautyRender
import BeautyCore

final class BeautyMetalRuntimeTests: XCTestCase {
    func testUnavailableHostIsAnExplicitTypedOutcome() {
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { nil }

        XCTAssertThrowsError(try BeautyMetalRuntime(dependencies: dependencies)) { error in
            XCTAssertEqual(error as? BeautyError, .metalUnavailable)
        }
    }

    func testInitializationFailureSeamsAreTypedAndRedacted() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTAssertTrue(true, "metalUnavailable")
            return
        }

        var queueFailure = BeautyMetalRuntime.Dependencies.live
        queueFailure.deviceProvider = { device }
        queueFailure.commandQueueProvider = { _ in nil }
        assertInitFailure(queueFailure, expected: .commandQueueCreationFailed)

        var libraryFailure = BeautyMetalRuntime.Dependencies.live
        libraryFailure.deviceProvider = { device }
        libraryFailure.libraryProvider = { _ in nil }
        assertInitFailure(libraryFailure, expected: .renderFailed("library_creation_failed"))

        var functionFailure = BeautyMetalRuntime.Dependencies.live
        functionFailure.deviceProvider = { device }
        functionFailure.functionProvider = { _, _ in nil }
        assertInitFailure(functionFailure, expected: .shaderFunctionNotFound("beauty_warp_placeholder"))

        var pipelineFailure = BeautyMetalRuntime.Dependencies.live
        pipelineFailure.deviceProvider = { device }
        pipelineFailure.pipelineProvider = { _, _ in nil }
        assertInitFailure(pipelineFailure, expected: .renderFailed("pipeline_creation_failed"))
    }

    func testMalformedWorkIsRejectedBeforeAnyRequestAllocation() throws {
        guard let runtime = makeRuntime() else { return }
        let before = runtime.resourceCountersForTesting
        let malformed: [(Int, Int, [UInt8])] = [
            (0, 1, []),
            (-1, 1, []),
            (1, 0, []),
            (2, 2, [0, 1, 2]),
            (2, 2, Array(repeating: 0, count: 17))
        ]

        for (width, height, bytes) in malformed {
            XCTAssertThrowsError(try runtime.render(width: width, height: height, rgba8Bytes: bytes)) { error in
                XCTAssertEqual(error as? BeautyError, .invalidInput)
            }
            XCTAssertEqual(runtime.resourceCountersForTesting, before)
        }

        let capped = try BeautyMetalRuntime(maximumPixelCount: 1)
        XCTAssertThrowsError(try capped.render(width: 2, height: 1, rgba8Bytes: [0, 1, 2, 3, 4, 5, 6, 7])) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(capped.resourceCountersForTesting.active, 0)
        XCTAssertEqual(capped.resourceCountersForTesting.created, capped.resourceCountersForTesting.released)
    }

    func testTerminalRequestFailureSeamsReleaseAllRequestResources() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTAssertTrue(true, "metalUnavailable")
            return
        }
        let bytes = [UInt8](0..<16)

        var commandFailure = BeautyMetalRuntime.Dependencies.live
        commandFailure.deviceProvider = { device }
        commandFailure.commandBufferProvider = { _ in nil }
        let commandRuntime = try BeautyMetalRuntime(dependencies: commandFailure)
        assertRenderFailure(commandRuntime, bytes: bytes, expected: .renderFailed("command_buffer_creation_failed"))

        var encoderFailure = BeautyMetalRuntime.Dependencies.live
        encoderFailure.deviceProvider = { device }
        encoderFailure.computeEncoderProvider = { _ in nil }
        let encoderRuntime = try BeautyMetalRuntime(dependencies: encoderFailure)
        assertRenderFailure(encoderRuntime, bytes: bytes, expected: .renderFailed("compute_encoder_creation_failed"))

        var textureFailure = BeautyMetalRuntime.Dependencies.live
        textureFailure.deviceProvider = { device }
        textureFailure.textureProvider = { _, _ in nil }
        let textureRuntime = try BeautyMetalRuntime(dependencies: textureFailure)
        assertRenderFailure(textureRuntime, bytes: bytes, expected: .textureCreationFailed)

        var statusFailure = BeautyMetalRuntime.Dependencies.live
        statusFailure.deviceProvider = { device }
        statusFailure.commandStatusProvider = { _ in .error }
        let statusRuntime = try BeautyMetalRuntime(dependencies: statusFailure)
        assertRenderFailure(statusRuntime, bytes: bytes, expected: .renderFailed("command_failed"))

        let recorder = GeometryBufferRecorder()
        var geometryBufferFailure = BeautyMetalRuntime.Dependencies.live
        geometryBufferFailure.deviceProvider = { device }
        geometryBufferFailure.geometryBufferProvider = { _, points in
            recorder.record(
                pointCount: points.count,
                byteCount: points.count * MemoryLayout<BeautyMetalWarpPoint>.stride
            )
            return nil
        }
        let geometryRuntime = try BeautyMetalRuntime(dependencies: geometryBufferFailure)
        let maximum = BeautyMetalGeometryParameters.maximumPointCount
        let geometryPass = BeautyMetalPass.geometry(
            try BeautyMetalGeometryParameters(points: makePoints(count: maximum))
        )
        XCTAssertThrowsError(
            try geometryRuntime.render(
                width: 2,
                height: 2,
                rgba8Bytes: bytes,
                passes: [geometryPass]
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("request_resource_unavailable"))
        }
        XCTAssertEqual(
            recorder.snapshot,
            [GeometryBufferRecord(
                pointCount: maximum,
                byteCount: maximum * MemoryLayout<BeautyMetalWarpPoint>.stride
            )]
        )
        XCTAssertEqual(geometryRuntime.resourceCountersForTesting.active, 0)
        XCTAssertEqual(
            geometryRuntime.resourceCountersForTesting.created,
            geometryRuntime.resourceCountersForTesting.released
        )
    }

    func testAvailableHostCopiesBytesAndRecoversAfterFailure() throws {
        guard let runtime = makeRuntime() else { return }
        let bytes = [UInt8](0..<16)

        let output = try runtime.render(width: 2, height: 2, rgba8Bytes: bytes)
        XCTAssertEqual(output, bytes)
        let successCounters = runtime.resourceCountersForTesting
        XCTAssertGreaterThan(successCounters.created, 0)
        XCTAssertEqual(successCounters.active, 0)
        XCTAssertEqual(successCounters.created, successCounters.released)

        let repeated = try runtime.render(width: 2, height: 2, rgba8Bytes: bytes)
        XCTAssertEqual(repeated, bytes)
        let repeatedCounters = runtime.resourceCountersForTesting
        XCTAssertEqual(repeatedCounters.active, 0)
        XCTAssertEqual(repeatedCounters.created, repeatedCounters.released)
    }

    func testFailedThenValidRequestDoesNotRetainPriorResources() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTAssertTrue(true, "metalUnavailable")
            return
        }
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        let failureSwitch = FailureSwitch()
        dependencies.commandStatusProvider = { _ in
            defer { failureSwitch.shouldFail = false }
            return failureSwitch.shouldFail ? .error : .completed
        }
        let runtime = try BeautyMetalRuntime(dependencies: dependencies)
        let bytes = [UInt8](repeating: 7, count: 4)

        XCTAssertThrowsError(try runtime.render(width: 1, height: 1, rgba8Bytes: bytes)) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("command_failed"))
        }
        let failed = runtime.resourceCountersForTesting
        XCTAssertEqual(failed.active, 0)
        XCTAssertEqual(failed.created, failed.released)

        XCTAssertEqual(try runtime.render(width: 1, height: 1, rgba8Bytes: bytes), bytes)
        let recovered = runtime.resourceCountersForTesting
        XCTAssertEqual(recovered.active, 0)
        XCTAssertEqual(recovered.created, recovered.released)
    }

    func testOrderedPassGraphUsesBoundedGeometryBuffersAndCleansEveryRequestResource() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTAssertTrue(true, "metalUnavailable")
            return
        }
        let recorder = GeometryBufferRecorder()
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        dependencies.geometryBufferProvider = { device, points in
            points.withUnsafeBytes { bytes -> MTLBuffer? in
                recorder.record(pointCount: points.count, byteCount: bytes.count)
                guard let baseAddress = bytes.baseAddress, !bytes.isEmpty else { return nil }
                return device.makeBuffer(
                    bytes: baseAddress,
                    length: bytes.count,
                    options: .storageModeShared
                )
            }
        }
        let runtime = try BeautyMetalRuntime(dependencies: dependencies)
        let color = try BeautyMetalColorParameters(
            saturationDelta: 0.08,
            contrastScale: 1.04,
            lightLift: 0.02,
            redBias: 0.01,
            greenBias: 0,
            blueBias: -0.01,
            highlightLift: 0.01,
            shadowLift: 0.02,
            smoothing: 0.04
        )
        let point = try BeautyMetalWarpPoint(
            sourceX: 0.5,
            sourceY: 0.5,
            targetX: 0.51,
            targetY: 0.5,
            radius: 0.2,
            strength: 0.1,
            falloff: 0.8
        )
        let graph: [BeautyMetalPass] = [
            .color(color),
            .geometry(try BeautyMetalGeometryParameters(points: [point])),
            .composedRetouch(try BeautyMetalComposedRetouchParameters()),
        ]
        let bytes = [UInt8](0..<16)
        let output = try runtime.render(width: 2, height: 2, rgba8Bytes: bytes, passes: graph)
        XCTAssertEqual(output.count, bytes.count)
        XCTAssertEqual(output.enumerated().filter { $0.offset % 4 == 3 }.map(\.element), [3, 7, 11, 15])
        let counters = runtime.resourceCountersForTesting
        XCTAssertEqual(counters.active, 0)
        XCTAssertEqual(counters.created, counters.released)
        XCTAssertEqual(
            recorder.snapshot,
            [GeometryBufferRecord(
                pointCount: 1,
                byteCount: MemoryLayout<BeautyMetalWarpPoint>.stride
            )]
        )

        let stableBytes: [UInt8] = [
            0, 1, 2, 255,
            3, 4, 5, 255,
            6, 7, 8, 255,
            9, 10, 11, 255,
        ]
        let pointStride = MemoryLayout<BeautyMetalWarpPoint>.stride
        XCTAssertEqual(pointStride, 28, "Swift point layout must keep the retained shader ABI")
        let lastInlineSizedCount = 4_096 / pointStride
        let counts = [
            lastInlineSizedCount,
            lastInlineSizedCount + 1,
            BeautyMetalGeometryParameters.maximumPointCount,
        ]
        let beforeIdentity = runtime.resourceCountersForTesting
        XCTAssertEqual(
            try runtime.render(width: 2, height: 2, rgba8Bytes: stableBytes),
            stableBytes
        )
        let afterIdentity = runtime.resourceCountersForTesting
        let identityCreated = afterIdentity.created - beforeIdentity.created
        XCTAssertGreaterThan(identityCreated, 0)
        XCTAssertEqual(afterIdentity.active, 0)
        XCTAssertEqual(afterIdentity.created, afterIdentity.released)
        var maximumOutput: [UInt8]?

        for count in counts {
            let before = runtime.resourceCountersForTesting
            let boundaryOutput = try runtime.render(
                width: 2,
                height: 2,
                rgba8Bytes: stableBytes,
                passes: [.geometry(try BeautyMetalGeometryParameters(points: makePoints(count: count)))]
            )
            XCTAssertEqual(boundaryOutput.count, stableBytes.count)
            XCTAssertEqual(
                stride(from: 3, to: boundaryOutput.count, by: 4).map { boundaryOutput[$0] },
                [255, 255, 255, 255]
            )
            if count == BeautyMetalGeometryParameters.maximumPointCount {
                maximumOutput = boundaryOutput
            }
            let after = runtime.resourceCountersForTesting
            XCTAssertEqual(after.active, 0)
            XCTAssertEqual(after.created, after.released)
            let created = after.created - before.created
            XCTAssertEqual(created, identityCreated + 1, "geometry adds exactly one tracked point buffer")
        }

        let records = recorder.snapshot
        XCTAssertEqual(
            Array(records.dropFirst()),
            counts.map { GeometryBufferRecord(pointCount: $0, byteCount: $0 * pointStride) }
        )
        guard records.count == 4 else { return XCTFail("expected one graph binding and three boundary bindings") }
        XCTAssertLessThanOrEqual(records[1].byteCount, 4_096)
        XCTAssertGreaterThan(records[2].byteCount, 4_096)
        XCTAssertEqual(records[3].pointCount, BeautyMetalGeometryParameters.maximumPointCount)

        let repeated = try runtime.render(
            width: 2,
            height: 2,
            rgba8Bytes: stableBytes,
            passes: [.geometry(try BeautyMetalGeometryParameters(
                points: makePoints(count: BeautyMetalGeometryParameters.maximumPointCount)
            ))]
        )
        XCTAssertEqual(repeated, maximumOutput)
        XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
        XCTAssertEqual(
            runtime.resourceCountersForTesting.created,
            runtime.resourceCountersForTesting.released
        )
    }

    func testPassSpecificSetupFailureIsTypedBeforeRequestAllocation() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTAssertTrue(true, "metalUnavailable")
            return
        }
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        dependencies.functionProvider = { library, name in
            name == "beauty_color_pass" ? nil : library.makeFunction(name: name)
        }
        XCTAssertThrowsError(try BeautyMetalRuntime(dependencies: dependencies)) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("shader_function_missing"))
        }
    }

    func testRepeatedPassGraphExecutionHasNoActiveResources() throws {
        guard let runtime = makeRuntime() else { return }
        let color = try BeautyMetalColorParameters(
            saturationDelta: 0,
            contrastScale: 1,
            lightLift: 0,
            redBias: 0,
            greenBias: 0,
            blueBias: 0,
            highlightLift: 0,
            shadowLift: 0,
            smoothing: 0
        )
        let graph: [BeautyMetalPass] = [.color(color)]
        let bytes = [UInt8](repeating: 9, count: 16)
        for _ in 0..<3 {
            XCTAssertEqual(try runtime.render(width: 2, height: 2, rgba8Bytes: bytes, passes: graph).count, bytes.count)
            let counters = runtime.resourceCountersForTesting
            XCTAssertEqual(counters.active, 0)
            XCTAssertEqual(counters.created, counters.released)
        }
    }

    private func makeRuntime() -> BeautyMetalRuntime? {
        do {
            return try BeautyMetalRuntime()
        } catch BeautyError.metalUnavailable {
            XCTAssertTrue(true, "metalUnavailable")
            return nil
        } catch {
            XCTFail("unexpected runtime setup failure: \(error)")
            return nil
        }
    }

    private func makePoints(count: Int) throws -> [BeautyMetalWarpPoint] {
        try (0..<count).map { index in
            let coordinate = 0.25 + Float(index % 8) * 0.05
            return try BeautyMetalWarpPoint(
                sourceX: coordinate,
                sourceY: coordinate,
                targetX: coordinate,
                targetY: coordinate,
                radius: 0.2,
                strength: 0.1,
                falloff: 1
            )
        }
    }

    private func assertInitFailure(
        _ dependencies: BeautyMetalRuntime.Dependencies,
        expected: BeautyError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try BeautyMetalRuntime(dependencies: dependencies), file: file, line: line) { error in
            XCTAssertEqual(error as? BeautyError, expected, file: file, line: line)
        }
    }

    private func assertRenderFailure(
        _ runtime: BeautyMetalRuntime,
        bytes: [UInt8],
        expected: BeautyError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try runtime.render(width: 2, height: 2, rgba8Bytes: bytes), file: file, line: line) { error in
            XCTAssertEqual(error as? BeautyError, expected, file: file, line: line)
        }
        let counters = runtime.resourceCountersForTesting
        XCTAssertEqual(counters.active, 0, file: file, line: line)
        XCTAssertEqual(counters.created, counters.released, file: file, line: line)
    }

    private final class FailureSwitch: @unchecked Sendable {
        var shouldFail = true
    }

    private struct GeometryBufferRecord: Equatable, Sendable {
        let pointCount: Int
        let byteCount: Int
    }

    private final class GeometryBufferRecorder: @unchecked Sendable {
        private let lock = NSLock()
        private var records: [GeometryBufferRecord] = []

        func record(pointCount: Int, byteCount: Int) {
            lock.lock()
            records.append(GeometryBufferRecord(pointCount: pointCount, byteCount: byteCount))
            lock.unlock()
        }

        var snapshot: [GeometryBufferRecord] {
            lock.lock()
            defer { lock.unlock() }
            return records
        }
    }
}
