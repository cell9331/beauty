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

    func testOrderedPassGraphExecutesAndCleansEveryRequestResource() throws {
        guard let runtime = makeRuntime() else { return }
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
}
