import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import BeautyCore
import BeautyDetection
import BeautyEffects

public final class BeautyEngine {
    public let configuration: BeautyConfiguration
    var faceDetector: VisionFaceDetector
    private let localRetouchTestingHooks: BeautyLocalRetouchTestingHooks?
    private let backendExecutor: BeautyBackendExecutor
    private lazy var stillImageCanonicalizer: BeautyStillImageCanonicalizer = {
        let canonicalizer = BeautyStillImageCanonicalizer()
        localRetouchTestingHooks?.recordCanonicalizerConstruction()
        return canonicalizer
    }()
    private var resetGeneration: UInt64 = 0

    public init(configuration: BeautyConfiguration = .default) throws {
        self.configuration = configuration
        self.faceDetector = VisionFaceDetector()
        self.localRetouchTestingHooks = nil
        self.backendExecutor = BeautyCPUBackend()
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
        localRetouchTestingHooks?.prepareForFacadeInvocation()
        try Self.validate(
            pixelBuffer: pixelBuffer,
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        let validated = try BeautySDKResources.validate(parameters: parameters)
        let plan = BeautyEffectResolver.resolve(parameters: validated)
        let request = try BeautyBackendRequest(
            input: .pixelBuffer(pixelBuffer),
            metadata: metadata,
            plan: plan
        )
        let backendResult = try backendExecutor.execute(request)
        return BeautyResult(
            output: try Self.pixelBufferOutput(from: backendResult),
            warnings: plan.warnings,
            metrics: plan.metrics,
            detectionSummary: initialDetectionSummary
        )
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

    public func processResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CIImage> {
        localRetouchTestingHooks?.prepareForFacadeInvocation()
        try Self.validate(
            image: image,
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        let validated = try BeautySDKResources.validate(parameters: parameters)

        let productionAdmission = BeautyEffectResolver.localRetouchAdmission(
            parameters: validated
        )
        let admission = productionAdmission.isEmpty
            ? localRetouchTestingHooks.map {
                BeautyLocalRetouchAdmission(opaqueDemandCount: $0.admittedPrivateDemandCount)
            } ?? productionAdmission
            : productionAdmission

        guard admission.isEmpty == false else {
            return try legacyStillImageResult(
                image: image,
                metadata: metadata,
                parameters: validated
            )
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
            requiresLocalSupport: true
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
        let hasOpaqueCompositionScenario =
            localRetouchTestingHooks?.hasOpaqueCompositionScenario == true
        let renderCarrier: BeautyCanonicalStillImage
        var compositionSummary: BeautyLocalRetouchCompositionSummary?
        if hasDirectTeethIntent || hasDirectScleraIntent || hasOpaqueCompositionScenario {
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
            input: .stillImage(renderCarrier.ciImage),
            metadata: renderCarrier.metadata,
            plan: route.plan,
            selectedFaceSupport: requestContext.selectedFaceObservation,
            canonicalImage: renderCarrier,
            compositionSummary: compositionSummary
        )
        let backendResult = try backendExecutor.execute(request)
        if let sRGB = CGColorSpace(name: CGColorSpace.sRGB) {
            localRetouchTestingHooks?.recordCanonicalRasterize(
                carrier: renderCarrier,
                colorSpace: sRGB
            )
        }
        return BeautyResult(
            output: try Self.stillImageOutput(from: backendResult),
            warnings: route.plan.warnings,
            metrics: route.plan.metrics,
            detectionSummary: route.detectionSummary
        )
    }

    private func legacyStillImageResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CIImage> {
        let route = resolveStillImageGeometry(
            image: image,
            metadata: metadata,
            imageExtent: image.extent.size,
            parameters: parameters
        )
        localRetouchTestingHooks?.record(.render)
        let request = try BeautyBackendRequest(
            input: .stillImage(image),
            metadata: metadata,
            plan: route.plan,
            selectedFaceSupport: route.selectedFaceObservation
        )
        let backendResult = try backendExecutor.execute(request)
        return BeautyResult(
            output: try Self.stillImageOutput(from: backendResult),
            warnings: route.plan.warnings,
            metrics: route.plan.metrics,
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

    private static func validate(image: CIImage, maximumPixelCount: Int) throws {
        let extent = image.extent
        guard extent.isFiniteAndNonEmpty,
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
