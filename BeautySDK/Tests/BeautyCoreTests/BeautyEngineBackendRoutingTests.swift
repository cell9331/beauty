import CoreImage
import XCTest
import BeautyCore
@testable import BeautySDK
@testable import BeautyEffects

final class BeautyEngineBackendRoutingTests: XCTestCase {
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
}

private final class RecordingExecutor: BeautyBackendExecutor {
    private(set) var callCount = 0
    private(set) var lastInputKind: BeautyBackendInputKind?
    private let error: BeautyError?

    init(error: BeautyError? = nil) {
        self.error = error
    }

    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        callCount += 1
        lastInputKind = request.inputKind
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
