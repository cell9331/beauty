import BeautyCore
import BeautyDetection
import BeautyRender
import CoreImage
import CoreVideo
import Foundation
import Metal
import XCTest
@testable import BeautyEffects

final class BeautyMetalBackendTests: XCTestCase {
    func testMetalPolicyUsesTheSharedRequestBoundary() throws {
        let input = try Self.makePixelBuffer(width: 2, height: 1, bytes: [1, 2, 3, 255, 4, 5, 6, 255])
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )

        XCTAssertEqual(request.policy, .metal)
        XCTAssertEqual(request.inputKind, .pixelBuffer)
    }

    func testPixelBufferMetalResultPreservesBytesDimensionsAndAlpha() throws {
        guard let runtime = makeRuntime() else { return }
        let inputBytes: [UInt8] = [
            1, 2, 3, 255,
            4, 5, 6, 127,
        ]
        let input = try Self.makePixelBuffer(width: 2, height: 1, bytes: inputBytes)
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )
        let counters = HookCounters()
        let backend = BeautyMetalBackend(runtime: runtime, hooks: counters.hooks)

        let result = try backend.execute(request)

        guard case .pixelBuffer(let output) = result.output else {
            return XCTFail("Metal changed the output kind")
        }
        XCTAssertEqual(try Self.bytes(from: output), inputBytes)
        XCTAssertEqual(result.diagnostics.width, 2)
        XCTAssertEqual(result.diagnostics.height, 1)
        XCTAssertTrue(result.diagnostics.preservesAlpha)
        XCTAssertTrue(result.diagnostics.preservesExtent)
        XCTAssertEqual(counters.runtimeInvocations, 1)
        XCTAssertEqual(counters.terminalErrors, 0)
    }

    func testCanonicalStillImageMetalResultPreservesExtentAndAggregates() throws {
        guard let runtime = makeRuntime() else { return }
        let metadata = Self.metadata(source: .testFixture)
        let canonical = try Self.canonical(
            width: 2,
            height: 1,
            metadata: metadata,
            bytes: [10, 20, 30, 255, 40, 50, 60, 255]
        )
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(canonical.ciImage),
            metadata: metadata,
            plan: BeautyEffectPlan(),
            canonicalImage: canonical,
            compositionSummary: BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 1,
                rejectedUnitCount: 1,
                ownedPixelCount: 1,
                changedPixelCount: 1,
                collisionPixelCount: 1
            )
        )
        let counters = HookCounters()
        let backend = BeautyMetalBackend(runtime: runtime, hooks: counters.hooks)

        let result = try backend.execute(request)

        guard case .stillImage(let output) = result.output else {
            return XCTFail("Metal changed the output kind")
        }
        XCTAssertEqual(output.extent, canonical.ciImage.extent)
        XCTAssertEqual(result.diagnostics.width, 2)
        XCTAssertEqual(result.diagnostics.height, 1)
        XCTAssertEqual(result.diagnostics.unitCount, 1)
        XCTAssertEqual(result.diagnostics.failureCount, 1)
        XCTAssertEqual(result.diagnostics.collisionCount, 1)
        XCTAssertEqual(result.diagnostics.changedPixelCount, 1)
        XCTAssertTrue(result.diagnostics.preservesAlpha)
        XCTAssertTrue(result.diagnostics.preservesExtent)
        XCTAssertEqual(counters.runtimeInvocations, 1)
        XCTAssertEqual(counters.terminalErrors, 0)
    }

    func testStillImageWithoutCanonicalCarrierRestoresOriginalExtent() throws {
        guard let runtime = makeRuntime() else { return }
        let image = Self.image(width: 2, height: 1, origin: CGPoint(x: 3, y: -2))
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(image),
            metadata: Self.metadata(source: .photo),
            plan: BeautyEffectPlan()
        )
        let counters = HookCounters()
        let backend = BeautyMetalBackend(runtime: runtime, hooks: counters.hooks)

        let result = try backend.execute(request)

        guard case .stillImage(let output) = result.output else {
            return XCTFail("Metal changed the output kind")
        }
        XCTAssertEqual(output.extent, image.extent)
        XCTAssertEqual(result.diagnostics.width, 2)
        XCTAssertEqual(result.diagnostics.height, 1)
        XCTAssertEqual(counters.runtimeInvocations, 1)
        XCTAssertEqual(counters.terminalErrors, 0)
    }

    func testUnavailableHostIsTypedAndDoesNotCreditExecution() {
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { nil }
        let counters = HookCounters()

        XCTAssertThrowsError(try BeautyMetalBackend(dependencies: dependencies, hooks: counters.hooks)) { error in
            XCTAssertEqual(error as? BeautyError, .metalUnavailable)
        }
        XCTAssertEqual(counters.runtimeInvocations, 0)
        XCTAssertEqual(counters.terminalErrors, 0)
    }

    func testMalformedInputIsRejectedBeforeMetalBackendWork() throws {
        let input = try Self.makePixelBuffer(width: 1, height: 1, bytes: [1, 2, 3, 255])
        let invalidMetadata = BeautyInputMetadata(
            orientation: .right,
            source: .testFixture
        )

        XCTAssertThrowsError(try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: invalidMetadata,
            plan: BeautyEffectPlan()
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }

        let unsupported = try Self.makePixelBuffer(
            width: 1,
            height: 1,
            pixelFormat: kCVPixelFormatType_32ARGB,
            bytes: [1, 2, 3, 255]
        )
        XCTAssertThrowsError(try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(unsupported),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )) { error in
            XCTAssertEqual(error as? BeautyError, .unsupportedPixelFormat)
        }
    }

    func testCommandFailureIsTerminalAndInvokesRuntimeOnce() throws {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        dependencies.commandStatusProvider = { _ in .error }
        let runtime = try BeautyMetalRuntime(dependencies: dependencies)
        let input = try Self.makePixelBuffer(width: 1, height: 1, bytes: [1, 2, 3, 255])
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )
        let counters = HookCounters()
        let backend = BeautyMetalBackend(runtime: runtime, hooks: counters.hooks)

        XCTAssertThrowsError(try backend.execute(request)) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("command_failed"))
        }
        XCTAssertEqual(counters.runtimeInvocations, 1)
        XCTAssertEqual(counters.terminalErrors, 1)
        XCTAssertEqual(counters.lastError, .renderFailed("command_failed"))
        XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
        XCTAssertEqual(
            runtime.resourceCountersForTesting.created,
            runtime.resourceCountersForTesting.released
        )
    }

    func testTextureFailureIsTerminalAndLeavesNoActiveResources() throws {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        dependencies.textureProvider = { _, _ in nil }
        let runtime = try BeautyMetalRuntime(dependencies: dependencies)
        let input = try Self.makePixelBuffer(width: 1, height: 1, bytes: [1, 2, 3, 255])
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )
        let counters = HookCounters()
        let backend = BeautyMetalBackend(runtime: runtime, hooks: counters.hooks)

        XCTAssertThrowsError(try backend.execute(request)) { error in
            XCTAssertEqual(error as? BeautyError, .textureCreationFailed)
        }
        XCTAssertEqual(counters.runtimeInvocations, 1)
        XCTAssertEqual(counters.terminalErrors, 1)
        XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
        XCTAssertEqual(
            runtime.resourceCountersForTesting.created,
            runtime.resourceCountersForTesting.released
        )
    }

    func testFailedThenValidAndMixedBackendRequestsRemainIndependent() throws {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        let status = StatusSwitch()
        dependencies.commandStatusProvider = { _ in
            status.shouldFail ? .error : .completed
        }
        let runtime = try BeautyMetalRuntime(dependencies: dependencies)
        let bytes: [UInt8] = [7, 8, 9, 255]
        let input = try Self.makePixelBuffer(width: 1, height: 1, bytes: bytes)
        let metalRequest = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )
        let cpuRequest = try BeautyBackendRequest(
            policy: .cpu,
            input: .pixelBuffer(input),
            metadata: Self.metadata(source: .camera),
            plan: BeautyEffectPlan()
        )
        let counters = HookCounters()
        let backend = BeautyMetalBackend(runtime: runtime, hooks: counters.hooks)

        XCTAssertThrowsError(try backend.execute(metalRequest))
        XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
        status.shouldFail = false
        let metalResult = try backend.execute(metalRequest)
        let cpuResult = try BeautyCPUBackend().execute(cpuRequest)

        guard case .pixelBuffer(let metalOutput) = metalResult.output,
              case .pixelBuffer(let cpuOutput) = cpuResult.output
        else {
            return XCTFail("Backend output kind changed")
        }
        XCTAssertEqual(try Self.bytes(from: metalOutput), bytes)
        XCTAssertEqual(try Self.bytes(from: cpuOutput), bytes)
        XCTAssertEqual(counters.runtimeInvocations, 2)
        XCTAssertEqual(counters.terminalErrors, 1)
        XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
        XCTAssertEqual(
            runtime.resourceCountersForTesting.created,
            runtime.resourceCountersForTesting.released
        )
    }

    private func makeRuntime() -> BeautyMetalRuntime? {
        do {
            return try BeautyMetalRuntime()
        } catch BeautyError.metalUnavailable {
            return nil
        } catch {
            XCTFail("unexpected runtime setup failure: \(error)")
            return nil
        }
    }

    private static func metadata(source: BeautyInputSource) -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: .up, source: source)
    }

    private static func canonical(
        width: Int,
        height: Int,
        metadata: BeautyInputMetadata,
        bytes: [UInt8]
    ) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: metadata
        )
    }

    private static func image(width: Int, height: Int, origin: CGPoint) -> CIImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bytes = Data([10, 20, 30, 255, 40, 50, 60, 255])
        return CIImage(
            bitmapData: bytes,
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        ).transformed(by: CGAffineTransform(translationX: origin.x, y: origin.y))
    }

    private static func makePixelBuffer(
        width: Int,
        height: Int,
        pixelFormat: OSType = kCVPixelFormatType_32BGRA,
        bytes: [UInt8]
    ) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormat,
            attributes as CFDictionary,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        guard bytes.count == width * height * 4,
              CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
        else {
            throw BeautyError.invalidInput
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let destinationRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeBytes { source in
            for row in 0..<height {
                memcpy(
                    baseAddress.advanced(by: row * destinationRowBytes),
                    source.baseAddress!.advanced(by: row * width * 4),
                    width * 4
                )
            }
        }
        return pixelBuffer
    }

    private static func bytes(from pixelBuffer: CVPixelBuffer) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let sourceRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { destination in
            for row in 0..<height {
                memcpy(
                    destination.baseAddress!.advanced(by: row * width * 4),
                    baseAddress.advanced(by: row * sourceRowBytes),
                    width * 4
                )
            }
        }
        return bytes
    }
}

private final class HookCounters: @unchecked Sendable {
    private let lock = NSLock()
    private var invocationStorage = 0
    private var terminalStorage = 0
    private var errorStorage: BeautyError?

    var hooks: BeautyMetalBackend.ExecutionHooks {
        BeautyMetalBackend.ExecutionHooks(
            onRuntimeInvocation: { [self] in
                lock.lock()
                invocationStorage += 1
                lock.unlock()
            },
            onTerminalError: { [self] error in
                lock.lock()
                terminalStorage += 1
                errorStorage = error
                lock.unlock()
            }
        )
    }

    var runtimeInvocations: Int {
        lock.lock()
        defer { lock.unlock() }
        return invocationStorage
    }

    var terminalErrors: Int {
        lock.lock()
        defer { lock.unlock() }
        return terminalStorage
    }

    var lastError: BeautyError? {
        lock.lock()
        defer { lock.unlock() }
        return errorStorage
    }
}

private final class StatusSwitch: @unchecked Sendable {
    var shouldFail = true
}
