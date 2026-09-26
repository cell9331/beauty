import CoreGraphics
import CoreImage
import CoreVideo
import Dispatch
import Foundation
import ImageIO
import BeautyCore
import BeautyDetection
import BeautyEffects

/// A stateful, intentionally non-`Sendable` processing engine.
///
/// Callers must serialize all `process`, `processResult`, and `reset` access to the same instance.
/// Independent `BeautyEngine` instances may execute concurrently.
public final class BeautyEngine {
    public let configuration: BeautyConfiguration
    var faceDetector: VisionFaceDetector
    private let localRetouchTestingHooks: BeautyLocalRetouchTestingHooks?
    private let backendExecutor: BeautyBackendExecutor
    private let backendPolicy: BeautyBackendExecutionPolicy
    private lazy var stillImageCanonicalizer: BeautyStillImageCanonicalizer = {
        let canonicalizer = BeautyStillImageCanonicalizer()
        localRetouchTestingHooks?.recordCanonicalizerConstruction()
        return canonicalizer
    }()
    private var resetGeneration: UInt64 = 0

    public init(configuration: BeautyConfiguration = .default) throws {
        let selection = try BeautyBackendFactory.select(configuration: configuration)
        self.configuration = configuration
        self.faceDetector = VisionFaceDetector()
        self.localRetouchTestingHooks = nil
        self.backendExecutor = selection.executor
        self.backendPolicy = selection.policy
    }

    package init(
        configuration: BeautyConfiguration = .default,
        faceDetector: VisionFaceDetector,
        localRetouchTestingHooks: BeautyLocalRetouchTestingHooks? = nil,
        backendExecutor: BeautyBackendExecutor = BeautyCPUBackend()
    ) throws {
        self.configuration = configuration
        self.faceDetector = faceDetector
        self.localRetouchTestingHooks = localRetouchTestingHooks
        self.backendExecutor = backendExecutor
        self.backendPolicy = configuration.renderBackend == .gpu ? .metal : .cpu
    }

    package convenience init(
        configuration: BeautyConfiguration = .default,
        backendExecutor: BeautyBackendExecutor
    ) throws {
        try self.init(
            configuration: configuration,
            faceDetector: VisionFaceDetector(),
            backendExecutor: backendExecutor
        )
    }

    /// Returns an SDK-created output pixel buffer that is readable for the current processing result lifecycle.
    public func process(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer {
        let metadata = BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .camera
        )
        return try processResult(
            pixelBuffer: pixelBuffer,
            metadata: metadata,
            parameters: parameters
        ).output
    }

    public func processResult(
        pixelBuffer: CVPixelBuffer,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CVPixelBuffer> {
        let performanceStart = configuration.enablePerformanceLog
            ? DispatchTime.now().uptimeNanoseconds : nil
        localRetouchTestingHooks?.prepareForFacadeInvocation()
        try Self.validate(
            pixelBuffer: pixelBuffer,
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        let validated = try BeautySDKResources.validate(parameters: parameters)
        guard BeautyTextureResourceBudget.admits(
            parameters: validated,
            width: CVPixelBufferGetWidth(pixelBuffer),
            height: CVPixelBufferGetHeight(pixelBuffer)
        ) else { throw BeautyError.invalidInput }
        let plan = BeautyEffectResolver.resolve(parameters: validated)
        let request = try BeautyBackendRequest(
            policy: backendPolicy,
            input: .pixelBuffer(pixelBuffer),
            metadata: metadata,
            plan: plan,
            renderQuality: configuration.renderQuality
        )
        let backendResult = try backendExecutor.execute(request)
        return withConfiguredResultMetadata(BeautyResult(
            output: try Self.pixelBufferOutput(from: backendResult),
            warnings: plan.warnings,
            metrics: plan.metrics,
            detectionSummary: initialDetectionSummary
        ), since: performanceStart)
    }

    /// Returns an SDK-created image value that is readable for the current processing result lifecycle.
    public func process(
        image: CIImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CIImage {
        let metadata = BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .photo
        )
        return try processResult(
            image: image,
            metadata: metadata,
            parameters: parameters
        ).output
    }

    /// Decodes one in-memory still image after enforcing the configured
    /// encoded-byte and declared-pixel limits. Orientation comes from
    /// `metadata`, exactly as for the decoded-image entry.
    public func processResult(
        encodedImageData: Data,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CIImage> {
        let performanceStart = configuration.enablePerformanceLog
            ? DispatchTime.now().uptimeNanoseconds : nil
        guard !encodedImageData.isEmpty,
              configuration.maximumInputByteCount > 0,
              encodedImageData.count <= configuration.maximumInputByteCount,
              let source = CGImageSourceCreateWithData(
                  encodedImageData as CFData,
                  [kCGImageSourceShouldCache: false] as CFDictionary
              ),
              CGImageSourceGetCount(source) == 1,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                  as? [CFString: Any],
              let declaredWidth = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
              let declaredHeight = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue,
              Self.dimensionsAreWithinPixelLimit(
                  width: declaredWidth,
                  height: declaredHeight,
                  maximumPixelCount: configuration.maximumInputPixelCount
              ),
              BeautyTextureResourceBudget.admits(
                  parameters: parameters,
                  width: declaredWidth,
                  height: declaredHeight
              ),
              let decoded = CGImageSourceCreateImageAtIndex(source, 0, nil),
              Self.dimensionsAreWithinPixelLimit(
                  width: decoded.width,
                  height: decoded.height,
                  maximumPixelCount: configuration.maximumInputPixelCount
              ),
              BeautyTextureResourceBudget.admits(
                  parameters: parameters,
                  width: decoded.width,
                  height: decoded.height
              )
        else {
            throw BeautyError.invalidInput
        }
        let colorSpace = decoded.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let image = CIImage(cgImage: decoded, options: [.colorSpace: colorSpace])
        return try withConfiguredResultMetadata(
            processResult(image: image, metadata: metadata, parameters: parameters),
            since: performanceStart
        )
    }

    public func processResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CIImage> {
        try processStillImageResult(
            image: image, metadata: metadata, parameters: parameters,
            frameIndex: nil
        )
    }

    /// Processes one explicitly indexed camera/video image. Frames that are
    /// not scheduled for detection fail closed for face-dependent effects;
    /// no prior face support is reused across frames.
    public func processResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        frameIndex: Int,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CIImage> {
        guard frameIndex >= 0,
              metadata.source == .camera || metadata.source == .video else {
            throw BeautyError.invalidInput
        }
        return try processStillImageResult(
            image: image, metadata: metadata, parameters: parameters,
            frameIndex: frameIndex
        )
    }

    private func processStillImageResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters,
        frameIndex: Int?
    ) throws -> BeautyResult<CIImage> {
        let performanceStart = configuration.enablePerformanceLog
            ? DispatchTime.now().uptimeNanoseconds : nil
        localRetouchTestingHooks?.prepareForFacadeInvocation()
        if backendPolicy == .metal {
            try stillImageCanonicalizer.preflightOpaqueBoundedRGBForMetalStillImage(
                image: image,
                maximumPixelCount: configuration.maximumInputPixelCount
            )
        }
        try Self.validate(
            image: image,
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        let validated = try BeautySDKResources.validate(parameters: parameters)
        guard let dimensions = BeautyBackendRequest.checkedDimensions(for: image.extent),
              BeautyTextureResourceBudget.admits(
                  parameters: validated,
                  width: dimensions.width,
                  height: dimensions.height
              ) else { throw BeautyError.invalidInput }

        let productionAdmission = BeautyEffectResolver.localRetouchAdmission(
            parameters: validated
        )
        let admission = productionAdmission.isEmpty
            ? localRetouchTestingHooks.map {
                BeautyLocalRetouchAdmission(opaqueDemandCount: $0.admittedPrivateDemandCount)
            } ?? productionAdmission
            : productionAdmission

        guard admission.isEmpty == false else {
            return try withConfiguredResultMetadata(legacyStillImageResult(
                image: image,
                metadata: metadata,
                parameters: validated,
                skipDetectionForInterval: skipsDetection(frameIndex)
            ), since: performanceStart)
        }

        localRetouchTestingHooks?.beginStillRequest()
        defer { localRetouchTestingHooks?.finishStillRequest() }
        localRetouchTestingHooks?.record(.canonicalize)
        localRetouchTestingHooks?.recordCanonicalizer(stillImageCanonicalizer)
        let canonical = try stillImageCanonicalizer.canonicalize(
            image: image,
            metadata: metadata,
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        localRetouchTestingHooks?.recordCanonicalCarrier(canonical)

        localRetouchTestingHooks?.record(.detectAndMap)
        let route = resolveStillImageGeometry(
            image: canonical.ciImage,
            metadata: canonical.metadata,
            imageExtent: CGSize(width: canonical.width, height: canonical.height),
            parameters: validated,
            requiresLocalSupport: true,
            skipDetectionForInterval: skipsDetection(frameIndex)
        )

        if localRetouchTestingHooks?.consumeMalformedRequest() == true {
            throw BeautyError.invalidInput
        }

        localRetouchTestingHooks?.record(.makeRequestContext)
        let requestContext = BeautyStillImageRequestContext(
            canonicalImage: canonical,
            selectedFaceObservation: route.selectedFaceObservation
        )
        localRetouchTestingHooks?.recordRequestContext(requestContext)

        let hasDirectTeethIntent = validated.teethWhitening > 0
        let hasDirectScleraIntent = validated.scleraRednessReduction > 0
        let hasDirectUpperEyelidIntent = validated.upperEyelidFullnessReduction > 0
        let hasOpaqueCompositionScenario =
            localRetouchTestingHooks?.hasOpaqueCompositionScenario == true
        let renderCarrier: BeautyCanonicalStillImage
        var compositionSummary: BeautyLocalRetouchCompositionSummary?
        if hasDirectTeethIntent || hasDirectScleraIntent || hasDirectUpperEyelidIntent
            || hasOpaqueCompositionScenario {
            let compositionOwner = BeautyLocalRetouchCompositionOwner(
                source: requestContext.canonicalImage
            )
            var units: [BeautyLocalRetouchUnit] = []
            if hasDirectTeethIntent {
                let providerResult = BeautyTeethWhiteningProvider.makeResult(
                    source: requestContext.canonicalImage,
                    lipSupport: requestContext.selectedFaceObservation?.observedLipSupport,
                    strength: validated.teethWhitening,
                    owner: compositionOwner
                )
                localRetouchTestingHooks?.recordTeethProvider(
                    providerResult,
                    source: requestContext.canonicalImage,
                    expectedSource: canonical
                )
                if let providerResult {
                    units.append(providerResult.unit)
                }
            }
            if hasDirectScleraIntent {
                let providerResult = BeautyScleraRednessProvider.makeResult(
                    source: requestContext.canonicalImage,
                    eyeSupport: requestContext.selectedFaceObservation?.observedEyeSupport,
                    eyeOrder: requestContext.selectedFaceObservation?.observedEyeOrder,
                    strength: validated.scleraRednessReduction,
                    owner: compositionOwner
                )
                localRetouchTestingHooks?.recordScleraProvider(
                    providerResult,
                    source: requestContext.canonicalImage,
                    expectedSource: canonical
                )
                units.append(contentsOf: providerResult.units)
            }
            if hasDirectUpperEyelidIntent,
               let observation = requestContext.selectedFaceObservation {
                let support = BeautyUpperEyelidSemanticSupportOwner.resolve(
                    observation: observation,
                    imageWidth: requestContext.canonicalImage.width,
                    imageHeight: requestContext.canonicalImage.height,
                    semanticOwner: BeautyExperimentalUpperEyelidFullnessSemanticAnalyzer.makeOwner(
                        source: requestContext.canonicalImage
                    )
                )
                let edit = BeautyExperimentalUpperEyelidReliefEditor.edit(
                    source: requestContext.canonicalImage,
                    support: support,
                    strength: Double(validated.upperEyelidFullnessReduction)
                )
                units.append(contentsOf: edit.makeUnits(using: compositionOwner))
            }
            if let localRetouchTestingHooks, hasOpaqueCompositionScenario {
                units.append(contentsOf: localRetouchTestingHooks.makeOpaqueCompositionUnits(
                    using: compositionOwner,
                    source: requestContext.canonicalImage,
                    expectedSource: canonical
                ))
            }
            localRetouchTestingHooks?.record(.compose)
            let compositionResult = try compositionOwner.compose(units)
            localRetouchTestingHooks?.recordComposition(compositionResult)
            renderCarrier = compositionResult.canonicalImage
            compositionSummary = compositionResult.summary
        } else {
            renderCarrier = requestContext.canonicalImage
            compositionSummary = nil
        }

        localRetouchTestingHooks?.record(.render)
        let request = try BeautyBackendRequest(
            policy: backendPolicy,
            input: .stillImage(renderCarrier.ciImage),
            metadata: renderCarrier.metadata,
            plan: route.plan,
            renderQuality: configuration.renderQuality,
            selectedFaceSupport: requestContext.selectedFaceObservation,
            canonicalImage: renderCarrier,
            compositionSummary: compositionSummary
        )
        let (backendResult, usedCapacityFallback) = try executeStillImageWithinGeometryBudget(request)
        if let sRGB = CGColorSpace(name: CGColorSpace.sRGB) {
            localRetouchTestingHooks?.recordCanonicalRasterize(
                carrier: renderCarrier,
                colorSpace: sRGB
            )
        }
        return withConfiguredResultMetadata(BeautyResult(
            output: try Self.stillImageOutput(from: backendResult),
            warnings: route.plan.warnings,
            metrics: metrics(route.plan.metrics, usedCapacityFallback: usedCapacityFallback),
            detectionSummary: route.detectionSummary
        ), since: performanceStart)
    }

    private func withConfiguredResultMetadata<Output>(
        _ result: BeautyResult<Output>, since start: UInt64?
    ) -> BeautyResult<Output> {
        var metrics = result.metrics
        if let start {
            let end = DispatchTime.now().uptimeNanoseconds
            let milliseconds = end >= start ? Double(end - start) / 1_000_000 : 0
            metrics["beauty.performance.facadeElapsedMilliseconds"] = milliseconds
        }
        var diagnostics: [BeautyDiagnosticEvent] = []
        if configuration.logLevel >= .warning, !result.warnings.isEmpty {
            diagnostics.append(BeautyDiagnosticEvent(code: .warningsPresent))
        }
        if configuration.logLevel >= .info {
            diagnostics.append(BeautyDiagnosticEvent(code: .requestSucceeded))
        }
        if configuration.logLevel >= .debug, configuration.enableDebugMode {
            diagnostics.append(BeautyDiagnosticEvent(code: .backendExecuted))
        }
        if start == nil, diagnostics.isEmpty { return result }
        return BeautyResult(
            output: result.output, warnings: result.warnings,
            metrics: metrics, detectionSummary: result.detectionSummary,
            diagnostics: diagnostics
        )
    }

    private func executeStillImageWithinGeometryBudget(
        _ request: BeautyBackendRequest
    ) throws -> (BeautyBackendResult, Bool) {
        guard request.policy == .metal,
              backendExecutor is BeautyMetalBackend,
              let observation = request.selectedFaceSupport,
              BeautyGeometryPointBudget.requiresCPU(
                  plan: request.plan, observation: observation
              )
        else {
            return (try backendExecutor.execute(request), false)
        }
        let cpuRequest = try BeautyBackendRequest(
            policy: .cpu,
            input: request.input,
            metadata: request.metadata,
            plan: request.plan,
            renderQuality: request.renderQuality,
            selectedFaceSupport: observation,
            canonicalImage: request.canonicalImage,
            compositionSummary: request.compositionSummary
        )
        return (try BeautyCPUBackend().execute(cpuRequest), true)
    }

    private func metrics(
        _ original: [String: Double], usedCapacityFallback: Bool
    ) -> [String: Double] {
        guard usedCapacityFallback else { return original }
        var result = original
        result["beauty.backend.cpuGeometryCapacityFallback"] = 1
        return result
    }

    private func legacyStillImageResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters,
        skipDetectionForInterval: Bool = false
    ) throws -> BeautyResult<CIImage> {
        let route = resolveStillImageGeometry(
            image: image,
            metadata: metadata,
            imageExtent: image.extent.size,
            parameters: parameters,
            skipDetectionForInterval: skipDetectionForInterval
        )
        localRetouchTestingHooks?.record(.render)
        let request = try BeautyBackendRequest(
            policy: backendPolicy,
            input: .stillImage(image),
            metadata: metadata,
            plan: route.plan,
            renderQuality: configuration.renderQuality,
            selectedFaceSupport: route.selectedFaceObservation
        )
        let (backendResult, usedCapacityFallback) = try executeStillImageWithinGeometryBudget(request)
        return BeautyResult(
            output: try Self.stillImageOutput(from: backendResult),
            warnings: route.plan.warnings,
            metrics: metrics(route.plan.metrics, usedCapacityFallback: usedCapacityFallback),
            detectionSummary: route.detectionSummary
        )
    }

    private static func pixelBufferOutput(
        from result: BeautyBackendResult
    ) throws -> CVPixelBuffer {
        guard case .pixelBuffer(let output) = result.output else {
            throw BeautyError.invalidInput
        }
        return output
    }

    private static func stillImageOutput(
        from result: BeautyBackendResult
    ) throws -> CIImage {
        guard case .stillImage(let output) = result.output else {
            throw BeautyError.invalidInput
        }
        return output
    }

    public func reset() {
        localRetouchTestingHooks?.resetLocalRetouchObservations()
        resetGeneration &+= 1
        faceDetector.resetTracking()
    }

    public var resetCountForTesting: UInt64 {
        resetGeneration
    }

    var initialDetectionSummary: BeautyDetectionSummary {
        configuration.enableFaceTracking ? .notRun : .disabled
    }

    private func skipsDetection(_ frameIndex: Int?) -> Bool {
        guard let frameIndex else { return false }
        return !frameIndex.isMultiple(of: configuration.detectionFrameInterval)
    }

    private static func validate(image: CIImage, maximumPixelCount: Int) throws {
        let extent = image.extent
        guard extent.isFiniteAndNonEmpty,
              extent.width.rounded(.towardZero) == extent.width,
              extent.height.rounded(.towardZero) == extent.height,
              dimensionsAreWithinPixelLimit(
                width: extent.width,
                height: extent.height,
                maximumPixelCount: maximumPixelCount
              )
        else {
            throw BeautyError.invalidInput
        }
    }

    private static func validate(pixelBuffer: CVPixelBuffer, maximumPixelCount: Int) throws {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard dimensionsAreWithinPixelLimit(
            width: width,
            height: height,
            maximumPixelCount: maximumPixelCount
        ) else {
            throw BeautyError.invalidInput
        }
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
            throw BeautyError.unsupportedPixelFormat
        }
    }

    private static func dimensionsAreWithinPixelLimit(
        width: Int,
        height: Int,
        maximumPixelCount: Int
    ) -> Bool {
        width > 0 &&
            height > 0 &&
            maximumPixelCount > 0 &&
            width <= maximumPixelCount / height
    }

    private static func dimensionsAreWithinPixelLimit(
        width: CGFloat,
        height: CGFloat,
        maximumPixelCount: Int
    ) -> Bool {
        width.isFinite &&
            height.isFinite &&
            width > 0 &&
            height > 0 &&
            maximumPixelCount > 0 &&
            width <= CGFloat(maximumPixelCount) / height
    }
}

private extension CGRect {
    var isFiniteAndNonEmpty: Bool {
        origin.x.isFinite &&
            origin.y.isFinite &&
            size.width.isFinite &&
            size.height.isFinite &&
            size.width > 0 &&
            size.height > 0
    }
}
