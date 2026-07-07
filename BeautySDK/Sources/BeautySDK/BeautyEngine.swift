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
    private var resetGeneration: UInt64 = 0

    public init(configuration: BeautyConfiguration = .default) throws {
        self.configuration = configuration
        self.faceDetector = VisionFaceDetector()
    }

    package init(
        configuration: BeautyConfiguration = .default,
        faceDetector: VisionFaceDetector
    ) throws {
        self.configuration = configuration
        self.faceDetector = faceDetector
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
        _ = metadata
        try Self.validate(pixelBuffer: pixelBuffer)
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
        guard image.extent.isFiniteAndNonEmpty else {
            throw BeautyError.invalidInput
        }
        let validated = try BeautySDKResources.validate(parameters: parameters)
        let route = resolveStillImageGeometry(
            image: image,
            metadata: metadata,
            imageExtent: image.extent.size,
            parameters: validated
        )
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
        resetGeneration &+= 1
        faceDetector.resetTracking()
    }

    public var resetCountForTesting: UInt64 {
        resetGeneration
    }

    var initialDetectionSummary: BeautyDetectionSummary {
        configuration.enableFaceTracking ? .notRun : .disabled
    }

    private static func validate(pixelBuffer: CVPixelBuffer) throws {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard width > 0, height > 0 else {
            throw BeautyError.invalidInput
        }
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
            throw BeautyError.unsupportedPixelFormat
        }
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
