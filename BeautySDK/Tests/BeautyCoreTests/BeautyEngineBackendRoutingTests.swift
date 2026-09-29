import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@_spi(Testing) @testable import BeautySDK
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

    func testSourceContourStillImageControlsMatchCPUAndMetal() throws {
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let source = makeSourceContourPortrait()
        let original = semanticRGBA(source)
        let cpu = try BeautyEngine(
            configuration: .init(renderBackend: .cpu),
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let gpu = try BeautyEngine(
            configuration: .init(renderBackend: .gpu),
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        for parameters in [
            BeautyParameters(hairlineHeight: 0.25),
            BeautyParameters(hairlineHeight: -0.25),
            BeautyParameters(foreheadHeight: 0.30),
            BeautyParameters(foreheadHeight: -0.30),
            BeautyParameters(doubleChinReduction: 0.25),
            BeautyParameters(doubleChinReductionPro: 0.25),
            BeautyParameters(headWrap: 0.25),
        ] {
            let cpuResult = try cpu.processResult(
                image: source, metadata: metadata, parameters: parameters
            )
            let gpuResult = try gpu.processResult(
                image: source, metadata: metadata, parameters: parameters
            )
            let cpuBytes = semanticRGBA(cpuResult.output)
            XCTAssertNotEqual(cpuBytes, original)
            XCTAssertEqual(cpuBytes, semanticRGBA(gpuResult.output))
            XCTAssertEqual(cpuResult.output.extent, gpuResult.output.extent)
        }
        let hairless = makeSourceContourPortrait(hairline: 0)
        let hairlessBytes = semanticRGBA(hairless)
        for parameters in [BeautyParameters(headWrap: 0.25),
                           BeautyParameters(foreheadHeight: 0.30),
                           BeautyParameters(foreheadHeight: -0.30)] {
            let cpuNegative = try cpu.processResult(
                image: hairless, metadata: metadata, parameters: parameters
            )
            let gpuNegative = try gpu.processResult(
                image: hairless, metadata: metadata, parameters: parameters
            )
            XCTAssertTrue(semanticRGBA(cpuNegative.output) == hairlessBytes)
            XCTAssertEqual(semanticRGBA(cpuNegative.output), semanticRGBA(gpuNegative.output))
        }
        for negative in [
            makeSourceContourPortrait(bulge: false, detachedCollar: true),
            makeSourceContourPortrait(bulge: false, internalFold: true),
        ] {
            let before = semanticRGBA(negative)
            for parameters in [BeautyParameters(doubleChinReduction: 0.25),
                               BeautyParameters(doubleChinReductionPro: 0.25)] {
                let cpuOutput = try cpu.processResult(
                    image: negative, metadata: metadata, parameters: parameters
                )
                let gpuOutput = try gpu.processResult(
                    image: negative, metadata: metadata, parameters: parameters
                )
                XCTAssertTrue(semanticRGBA(cpuOutput.output) == before)
                XCTAssertEqual(semanticRGBA(cpuOutput.output), semanticRGBA(gpuOutput.output))
            }
        }
    }

    private func makeSourceContourPortrait(
        hairline: Int = 170, bulge hasBulge: Bool = true,
        detachedCollar: Bool = false, internalFold: Bool = false
    ) -> CIImage {
        let side = 512
        var bytes = [UInt8](repeating: 255, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let head = pow(Double(x - 256) / 108, 2) +
                    pow(Double(y - 256) / 160, 2) <= 1
                let bulge = hasBulge && pow(Double(x - 256) / 42, 2) +
                    pow(Double(y - 408) / 22, 2) <= 1
                let rgb: (UInt8, UInt8, UInt8)
                if detachedCollar && (435...448).contains(y) && (210...302).contains(x) {
                    rgb = (155, 130, 112)
                } else if !head && !bulge {
                    rgb = (25, 40, 55)
                } else if internalFold && (392...399).contains(y) && (230...282).contains(x) {
                    rgb = (45, 40, 38)
                } else if y < hairline {
                    rgb = (28, 25, 25)
                } else {
                    rgb = (195, 150, 125)
                }
                let offset = (y * side + x) * 4
                bytes[offset] = rgb.0
                bytes[offset + 1] = rgb.1
                bytes[offset + 2] = rgb.2
            }
        }
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        return CIImage(bitmapData: Data(bytes), bytesPerRow: side * 4,
                       size: CGSize(width: side, height: side), format: .RGBA8,
                       colorSpace: colorSpace)
    }

    private func semanticRGBA(_ image: CIImage) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        var bytes = [UInt8](repeating: 0, count: 512 * 512 * 4)
        CIContext(options: [.workingColorSpace: colorSpace,
                            .outputColorSpace: colorSpace]).render(
            image, toBitmap: &bytes, rowBytes: 512 * 4,
            bounds: CGRect(x: 0, y: 0, width: 512, height: 512),
            format: .RGBA8, colorSpace: colorSpace
        )
        return bytes
    }

    func testInjectedGPUEngineCarriesMetalPolicyForStillImageAndPixelBuffer() throws {
        let executor = RecordingExecutor()
        let engine = try BeautyEngine(
            configuration: BeautyConfiguration(renderBackend: .gpu),
            backendExecutor: executor
        )
        let image = try makeOpaqueStillImage(colorSpaceName: CGColorSpace.sRGB)

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
            let image = try makeOpaqueStillImage(colorSpaceName: CGColorSpace.sRGB)
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
        let image = try makeOpaqueStillImage(colorSpaceName: CGColorSpace.sRGB)
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)

        _ = try cpuEngine.processResult(image: image, metadata: metadata, parameters: BeautyParameters())
        _ = try gpuEngine.processResult(image: image, metadata: metadata, parameters: BeautyParameters())
        _ = try cpuEngine.processResult(image: image, metadata: metadata, parameters: BeautyParameters())

        XCTAssertEqual(cpuExecutor.callCount, 2)
        XCTAssertEqual(cpuExecutor.lastPolicy, .cpu)
        XCTAssertEqual(gpuExecutor.callCount, 1)
        XCTAssertEqual(gpuExecutor.lastPolicy, .metal)
    }

    func testGPUStillImageRejectsTransparencyBeforeBackendExecution() throws {
        let executor = RecordingExecutor()
        let engine = try BeautyEngine(
            configuration: BeautyConfiguration(renderBackend: .gpu),
            backendExecutor: executor
        )
        let image = try makeStillImage(
            bytes: [51, 102, 153, 254],
            colorSpaceName: CGColorSpace.sRGB
        )

        XCTAssertThrowsError(
            try engine.processResult(
                image: image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: BeautyParameters(faceSlim: 0.4)
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(executor.callCount, 0)
    }

    func testOpaqueDisplayP3GPUStillImagePreservesRawCarrierAndMetadata() throws {
        let executor = RecordingExecutor()
        let engine = try BeautyEngine(
            configuration: BeautyConfiguration(renderBackend: .gpu),
            backendExecutor: executor
        )
        let rawExtent = CGRect(x: 3, y: -2, width: 1, height: 1)
        let image = try makeOpaqueStillImage(
            colorSpaceName: CGColorSpace.displayP3,
            origin: rawExtent.origin
        )
        let metadata = BeautyInputMetadata(
            orientation: .left,
            isInputMirrored: true,
            isPreviewMirrored: true,
            source: .photo,
            timestamp: 42
        )

        _ = try engine.processResult(
            image: image,
            metadata: metadata,
            parameters: BeautyParameters(brightness: 0.2)
        )

        XCTAssertEqual(executor.callCount, 1)
        XCTAssertEqual(executor.lastPolicy, .metal)
        XCTAssertEqual(executor.lastMetadata, metadata)
        XCTAssertEqual(executor.lastStillImageExtent, rawExtent)
        XCTAssertEqual(executor.lastStillImageColorSpaceName, CGColorSpace.displayP3)
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

    func testPublicRawRoutesPreserveNonUpAndMirroredMetadata() throws {
        let executor = RecordingExecutor()
        let engine = try BeautyEngine(
            configuration: .default,
            backendExecutor: executor
        )
        let pixelBufferMetadata = BeautyInputMetadata(
            orientation: .right,
            source: .camera
        )
        let stillImageMetadata = BeautyInputMetadata(
            orientation: .down,
            isInputMirrored: true,
            source: .photo
        )

        _ = try engine.processResult(
            pixelBuffer: makePixelBuffer(),
            metadata: pixelBufferMetadata,
            parameters: BeautyParameters()
        )
        XCTAssertEqual(executor.lastMetadata, pixelBufferMetadata)

        let image = CIImage(color: .white).cropped(
            to: CGRect(x: 0, y: 0, width: 1, height: 1)
        )
        _ = try engine.processResult(
            image: image,
            metadata: stillImageMetadata,
            parameters: BeautyParameters()
        )
        XCTAssertEqual(executor.lastMetadata, stillImageMetadata)
        XCTAssertEqual(executor.callCount, 2)
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

    private func makeOpaqueStillImage(
        colorSpaceName: CFString,
        origin: CGPoint = .zero
    ) throws -> CIImage {
        try makeStillImage(
            bytes: [51, 102, 153, 255],
            colorSpaceName: colorSpaceName
        ).transformed(by: CGAffineTransform(translationX: origin.x, y: origin.y))
    }

    private func makeStillImage(
        bytes: [UInt8],
        colorSpaceName: CFString
    ) throws -> CIImage {
        guard bytes.count == 4,
              let colorSpace = CGColorSpace(name: colorSpaceName)
        else {
            throw BeautyError.unsupportedPixelFormat
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: 4,
            size: CGSize(width: 1, height: 1),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }
}

private final class RecordingExecutor: BeautyBackendExecutor {
    private(set) var callCount = 0
    private(set) var lastInputKind: BeautyBackendInputKind?
    private(set) var lastMetadata: BeautyInputMetadata?
    private(set) var lastPolicy: BeautyBackendExecutionPolicy?
    private(set) var lastStillImageExtent: CGRect?
    private(set) var lastStillImageColorSpaceName: CFString?
    private let error: BeautyError?

    init(error: BeautyError? = nil) {
        self.error = error
    }

    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        callCount += 1
        lastInputKind = request.inputKind
        lastMetadata = request.metadata
        lastPolicy = request.policy
        if let error {
            throw error
        }
        let output: BeautyBackendOutput
        switch request.input {
        case .pixelBuffer(let pixelBuffer):
            output = .pixelBuffer(pixelBuffer)
        case .stillImage(let image):
            lastStillImageExtent = image.extent
            lastStillImageColorSpaceName = image.colorSpace?.name
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

final class BeautyMetalGeometryCapacityTests: XCTestCase {
    func testPublicDenseGeometryPreservesAllControlsViaCPUCapacityPath() throws {
        let width = 64
        let height = 64
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let source = (0..<(width * height)).flatMap { index -> [UInt8] in
            let x = index % width
            let y = index / width
            return [UInt8((x * 7 + y * 3) % 256), UInt8((x * 2 + y * 5) % 256),
                    UInt8((x * 11 + y * 13) % 256), 255]
        }
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: colorSpace
        )
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let fields = [
            "faceSlim", "faceSmall", "wholeFaceYPosition", "wholeFaceXPosition", "wholeFaceTilt",
            "faceVShape", "jawSlim", "chinLength", "faceContourSmooth", "templeFullness",
            "cheekboneSlim", "chinTaper", "eyeSize", "eyeDistance", "eyeYPosition",
            "eyeTailLift", "eyeHeight", "eyeLength", "upperEyelidLift", "pupilSize",
            "gazeCorrection", "lowerEyelidDrop", "eyeTilt", "innerCornerOpen",
            "outerCornerOpen", "eyeSymmetry", "eyebrowYPosition", "eyebrowThickness",
            "eyebrowLength", "eyebrowSpacing", "eyebrowHeadSpacing", "eyebrowTilt",
            "eyebrowPeakDefinition", "noseSlim", "noseWingSlim", "noseTipSize",
            "noseBridge", "noseTipLift", "mouthSize", "mouthWidth", "smile",
            "mouthYPosition", "mouthTilt", "mouthXPosition", "lipPeakDefinition", "lipPlump",
        ]
        var encoded = try XCTUnwrap(JSONSerialization.jsonObject(
            with: JSONEncoder().encode(BeautyParameters())
        ) as? [String: Any])
        for field in fields { encoded[field] = 0.8 }
        let parameters = try JSONDecoder().decode(
            BeautyParameters.self, from: JSONSerialization.data(withJSONObject: encoded)
        )
        func engine(_ backend: BeautyRenderBackend) throws -> BeautyEngine {
            let provider = SDKTestingFaceDetectionProvider([.denseObservedEyebrows])
            let executor: BeautyBackendExecutor = backend == .gpu
                ? try BeautyMetalBackend() : BeautyCPUBackend()
            return try BeautyEngine(
                configuration: BeautyConfiguration(renderBackend: backend),
                faceDetector: VisionFaceDetector(
                    observationProvider: provider.makeObservationProvider()
                ),
                backendExecutor: executor
            )
        }
        let cpu = try engine(.cpu)
        let gpu: BeautyEngine
        do {
            gpu = try engine(.gpu)
        } catch BeautyError.metalUnavailable {
            return
        }
        let expected = try cpu.processResult(image: image, metadata: metadata, parameters: parameters)
        let actual = try gpu.processResult(image: image, metadata: metadata, parameters: parameters)
        func bytes(_ output: CIImage) -> [UInt8] {
            var pixels = [UInt8](repeating: 0, count: source.count)
            CIContext().render(
                output, toBitmap: &pixels, rowBytes: width * 4,
                bounds: image.extent, format: .RGBA8, colorSpace: colorSpace
            )
            return pixels
        }
        XCTAssertEqual(actual.output.extent, image.extent)
        let actualBytes = bytes(actual.output)
        XCTAssertEqual(actualBytes, bytes(expected.output))
        XCTAssertNotEqual(actualBytes, source)
        XCTAssertNil(expected.metrics["beauty.backend.cpuGeometryCapacityFallback"])
        XCTAssertEqual(actual.metrics["beauty.backend.cpuGeometryCapacityFallback"], 1,
                       "aggregate metrics: \(actual.metrics)")
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            actualBytes[$0] == 255
        })
        let recovered = try gpu.processResult(
            image: image, metadata: metadata,
            parameters: BeautyParameters(faceSmall: 0.3)
        )
        XCTAssertNil(recovered.metrics["beauty.backend.cpuGeometryCapacityFallback"])
        XCTAssertEqual(recovered.output.extent, image.extent)
    }
}
