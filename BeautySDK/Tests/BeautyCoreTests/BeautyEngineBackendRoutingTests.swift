import CoreImage
import CoreVideo
import XCTest
import BeautyCore
@testable import BeautySDK
@testable import BeautyEffects

final class BeautyEngineBackendRoutingTests: XCTestCase {
    func testFactorySelectsCPUWithoutEvaluatingMetalFactory() throws {
        let metalFactoryCalls = CallCounter()
        let selection = try BeautyBackendFactory.select(
            configuration: BeautyConfiguration(renderBackend: .cpu),
            metalFactory: { _ in
                metalFactoryCalls.increment()
                throw BeautyError.metalUnavailable
            }
        )

        XCTAssertEqual(selection.policy, .cpu)
        XCTAssertEqual(metalFactoryCalls.value, 0)
    }

    func testFactorySelectsGPUAndPropagatesUnavailableMetalWithoutCPUFallback() {
        let metalFactoryCalls = CallCounter()
        XCTAssertThrowsError(
            try BeautyBackendFactory.select(
                configuration: BeautyConfiguration(renderBackend: .gpu),
                metalFactory: { _ in
                    metalFactoryCalls.increment()
                    throw BeautyError.metalUnavailable
                }
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .metalUnavailable)
        }
        XCTAssertEqual(metalFactoryCalls.value, 1)
    }

    func testInjectedGPUEngineCarriesMetalPolicyForStillImageAndPixelBuffer() throws {
        let executor = RecordingExecutor()
        let engine = try BeautyEngine(
            configuration: BeautyConfiguration(renderBackend: .gpu),
            backendExecutor: executor
        )
        let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))

        _ = try engine.processResult(
            image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: BeautyParameters()
        )
        XCTAssertEqual(executor.lastPolicy, .metal)

        let pixelBuffer = try makePixelBuffer()
        _ = try engine.processResult(
            pixelBuffer: pixelBuffer,
            metadata: BeautyInputMetadata(orientation: .up, source: .camera),
            parameters: BeautyParameters()
        )
        XCTAssertEqual(executor.callCount, 2)
        XCTAssertEqual(executor.lastPolicy, .metal)
    }

    func testPublicGPUConstructionIsExplicitlyAvailableOrTypedUnavailable() throws {
        do {
            let engine = try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .gpu))
            let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
            let result = try engine.processResult(
                image: image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: BeautyParameters()
            )
            XCTAssertEqual(result.output.extent, image.extent)
        } catch {
            XCTAssertEqual(error as? BeautyError, .metalUnavailable)
        }
    }

    func testCPUAndGPUInjectedEnginesKeepRequestLocalPolicies() throws {
        let cpuExecutor = RecordingExecutor()
        let gpuExecutor = RecordingExecutor()
        let cpuEngine = try BeautyEngine(
            configuration: BeautyConfiguration(renderBackend: .cpu),
            backendExecutor: cpuExecutor
        )
        let gpuEngine = try BeautyEngine(
            configuration: BeautyConfiguration(renderBackend: .gpu),
            backendExecutor: gpuExecutor
        )
        let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)

        _ = try cpuEngine.processResult(image: image, metadata: metadata, parameters: BeautyParameters())
        _ = try gpuEngine.processResult(image: image, metadata: metadata, parameters: BeautyParameters())
        _ = try cpuEngine.processResult(image: image, metadata: metadata, parameters: BeautyParameters())

        XCTAssertEqual(cpuExecutor.callCount, 2)
        XCTAssertEqual(cpuExecutor.lastPolicy, .cpu)
        XCTAssertEqual(gpuExecutor.callCount, 1)
        XCTAssertEqual(gpuExecutor.lastPolicy, .metal)
    }

    func testStillImageDispatchesExactlyOnceThroughInjectedExecutor() throws {
        let executor = RecordingExecutor()
        let engine = try BeautyEngine(
            configuration: .default,
            backendExecutor: executor
        )
        let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))

        let result = try engine.processResult(
            image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: BeautyParameters(brightness: 0.2)
        )

        XCTAssertEqual(executor.callCount, 1)
        XCTAssertEqual(executor.lastInputKind, .stillImage)
        XCTAssertEqual(result.output.extent, image.extent)
    }

    func testInjectedTerminalFailureEscapesWithoutFallback() throws {
        let executor = RecordingExecutor(error: .renderFailed("terminal"))
        let engine = try BeautyEngine(
            configuration: .default,
            backendExecutor: executor
        )
        let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertThrowsError(
            try engine.processResult(
                image: image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: BeautyParameters()
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("terminal"))
        }
        XCTAssertEqual(executor.callCount, 1)
    }

    private func makePixelBuffer() throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            1,
            1,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        return pixelBuffer
    }
}

private final class RecordingExecutor: BeautyBackendExecutor {
    private(set) var callCount = 0
    private(set) var lastInputKind: BeautyBackendInputKind?
    private(set) var lastPolicy: BeautyBackendExecutionPolicy?
    private let error: BeautyError?

    init(error: BeautyError? = nil) {
        self.error = error
    }

    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        callCount += 1
        lastInputKind = request.inputKind
        lastPolicy = request.policy
        if let error {
            throw error
        }
        let output: BeautyBackendOutput
        switch request.input {
        case .pixelBuffer(let pixelBuffer):
            output = .pixelBuffer(pixelBuffer)
        case .stillImage(let image):
            output = .stillImage(image)
        }
        return try BeautyBackendResult(
            output: output,
            diagnostics: BeautyBackendDiagnostics(
                width: request.inputKind == .stillImage ? Int(requestImageExtent(request).width) : 1,
                height: request.inputKind == .stillImage ? Int(requestImageExtent(request).height) : 1,
                preservesAlpha: true,
                preservesExtent: true
            ),
            for: request
        )
    }

    private func requestImageExtent(_ request: BeautyBackendRequest) -> CGRect {
        if case .stillImage(let image) = request.input {
            return image.extent
        }
        return .zero
    }
}

private final class CallCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func increment() {
        lock.lock()
        storage += 1
        lock.unlock()
    }
}
