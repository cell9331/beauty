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
    }

    package init(
        configuration: BeautyConfiguration = .default,
        faceDetector: VisionFaceDetector,
        localRetouchTestingHooks: BeautyLocalRetouchTestingHooks? = nil
    ) throws {
        self.configuration = configuration
        self.faceDetector = faceDetector
        self.localRetouchTestingHooks = localRetouchTestingHooks
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
        localRetouchTestingHooks?.clearTeethProviderObservation()
        try Self.validate(
            pixelBuffer: pixelBuffer,
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        _ = metadata
        let validated = try BeautySDKResources.validate(parameters: parameters)
        let plan = BeautyEffectResolver.resolve(parameters: validated)
        return BeautyResult(
            output: try BeautyColorEffectPipeline.apply(to: pixelBuffer, plan: plan),
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
        localRetouchTestingHooks?.clearTeethProviderObservation()
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
            return legacyStillImageResult(
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
        let hasOpaqueCompositionScenario =
            localRetouchTestingHooks?.hasOpaqueCompositionScenario == true
        let renderCarrier: BeautyCanonicalStillImage
        if hasDirectTeethIntent || hasOpaqueCompositionScenario {
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
        } else {
            renderCarrier = requestContext.canonicalImage
        }

        localRetouchTestingHooks?.record(.render)
        let output = BeautyColorEffectPipeline.apply(
            to: renderCarrier,
            plan: route.plan,
            selectedFaceObservation: requestContext.selectedFaceObservation,
            onCanonicalRasterize: { [localRetouchTestingHooks] carrier, colorSpace in
                localRetouchTestingHooks?.recordCanonicalRasterize(
                    carrier: carrier,
                    colorSpace: colorSpace
                )
            }
        )
        return BeautyResult(
            output: output,
            warnings: route.plan.warnings,
            metrics: route.plan.metrics,
            detectionSummary: route.detectionSummary
        )
    }

    private func legacyStillImageResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) -> BeautyResult<CIImage> {
        let route = resolveStillImageGeometry(
            image: image,
            metadata: metadata,
            imageExtent: image.extent.size,
            parameters: parameters
        )
        localRetouchTestingHooks?.record(.render)
        return BeautyResult(
            output: BeautyColorEffectPipeline.apply(
                to: image,
                plan: route.plan,
                selectedFaceObservation: route.selectedFaceObservation
            ),
            warnings: route.plan.warnings,
            metrics: route.plan.metrics,
            detectionSummary: route.detectionSummary
        )
    }

    public func reset() {
        localRetouchTestingHooks?.clearTeethProviderObservation()
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
