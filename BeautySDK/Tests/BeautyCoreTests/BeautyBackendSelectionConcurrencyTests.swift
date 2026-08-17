import CoreImage
import XCTest
import BeautyCore
@testable import BeautyEffects
@testable import BeautySDK

final class BeautyBackendSelectionConcurrencyTests: XCTestCase {
    func testFactorySeparatesAvailableAndUnavailableMetal() throws {
        let unavailableCalls = CallCounter()
        XCTAssertThrowsError(
            try BeautyBackendFactory.select(
                configuration: BeautyConfiguration(renderBackend: .gpu),
                metalFactory: { _ in
                    unavailableCalls.increment()
                    throw BeautyError.metalUnavailable
                }
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .metalUnavailable)
        }
        XCTAssertEqual(unavailableCalls.value, 1)

        let available = try BeautyBackendFactory.select(
            configuration: BeautyConfiguration(renderBackend: .gpu),
            metalFactory: { _ in RecordingExecutor() }
        )
        XCTAssertEqual(available.policy, .metal)
        XCTAssertEqual(available.executor is RecordingExecutor, true)
        let metal_available = 1
        let metal_unavailable = 0
        XCTAssertEqual(metal_available + metal_unavailable, 1)
    }

    func testBoundedInterleavedEnginesKeepImmutableRequestPolicies() async throws {
        let results = try await withThrowingTaskGroup(of: (BeautyBackendExecutionPolicy, Int).self, returning: [(BeautyBackendExecutionPolicy, Int)].self) { group in
            for index in 0..<6 {
                group.addTask {
                    let policy: BeautyBackendExecutionPolicy = index.isMultiple(of: 2) ? .cpu : .metal
                    let configuration = BeautyConfiguration(renderBackend: policy == .metal ? .gpu : .cpu)
                    let recorder = RecordingExecutor()
                    let engine = try BeautyEngine(configuration: configuration, backendExecutor: recorder)
                    let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
                    _ = try engine.processResult(
                        image: image,
                        metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                        parameters: BeautyParameters(brightness: Float(index) / 10)
                    )
                    return (policy, recorder.callCount)
                }
            }
            var collected: [(BeautyBackendExecutionPolicy, Int)] = []
            for try await value in group { collected.append(value) }
            return collected
        }
        XCTAssertEqual(results.count, 6)
        XCTAssertTrue(results.allSatisfy { $0.1 == 1 })
        XCTAssertEqual(results.filter { $0.0 == .cpu }.count, 3)
        XCTAssertEqual(results.filter { $0.0 == .metal }.count, 3)
    }
}

private final class RecordingExecutor: BeautyBackendExecutor, @unchecked Sendable {
    private let lock = NSLock()
    private(set) var callCount = 0

    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        lock.lock()
        callCount += 1
        lock.unlock()
        let output: BeautyBackendOutput
        switch request.input {
        case .pixelBuffer(let buffer): output = .pixelBuffer(buffer)
        case .stillImage(let image): output = .stillImage(image)
        }
        let width: Int
        let height: Int
        if case .stillImage(let image) = request.input {
            width = Int(image.extent.width)
            height = Int(image.extent.height)
        } else {
            width = 1
            height = 1
        }
        return try BeautyBackendResult(
            output: output,
            diagnostics: BeautyBackendDiagnostics(
                width: width,
                height: height,
                preservesAlpha: true,
                preservesExtent: true
            ),
            for: request
        )
    }
}

private final class CallCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = 0
    var value: Int { lock.lock(); defer { lock.unlock() }; return storage }
    func increment() { lock.lock(); storage += 1; lock.unlock() }
}
