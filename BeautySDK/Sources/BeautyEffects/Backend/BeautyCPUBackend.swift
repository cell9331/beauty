import CoreImage
import CoreVideo
import BeautyCore

/// The deterministic CPU reference implementation of the backend contract.
///
/// Validation, support discovery, effect resolution, and local-retouch
/// composition remain owned by the facade. This type only performs the final
/// retained CPU render and publishes bounded result diagnostics.
package struct BeautyCPUBackend: BeautyBackendExecutor, Sendable {
    package init() {}

    package func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        let output: BeautyBackendOutput
        switch request.input {
        case .pixelBuffer(let pixelBuffer):
            output = .pixelBuffer(
                try BeautyColorEffectPipeline.apply(
                    to: pixelBuffer,
                    plan: request.plan
                )
            )
        case .stillImage(let image):
            let rendered: CIImage
            if let canonicalImage = request.canonicalImage {
                rendered = BeautyColorEffectPipeline.apply(
                    to: canonicalImage,
                    plan: request.plan,
                    selectedFaceObservation: request.selectedFaceSupport
                )
            } else {
                rendered = BeautyColorEffectPipeline.apply(
                    to: image,
                    plan: request.plan,
                    selectedFaceObservation: request.selectedFaceSupport
                )
            }
            output = .stillImage(rendered)
        }

        let dimensions = dimensions(of: output)
        let summary = request.compositionSummary
        let pixelCount = dimensions.width.multipliedReportingOverflow(by: dimensions.height)
        let boundedPixelCount = pixelCount.overflow
            ? BeautyConfiguration.defaultMaximumInputPixelCount
            : pixelCount.partialValue
        let diagnostics = BeautyBackendDiagnostics(
            width: dimensions.width,
            height: dimensions.height,
            preservesAlpha: true,
            preservesExtent: true,
            unitCount: min(summary?.acceptedUnitCount ?? 0, boundedPixelCount),
            failureCount: min(summary?.rejectedUnitCount ?? 0, boundedPixelCount),
            collisionCount: min(summary?.collisionPixelCount ?? 0, boundedPixelCount),
            changedPixelCount: min(summary?.changedPixelCount ?? 0, boundedPixelCount)
        )
        return try BeautyBackendResult(
            output: output,
            diagnostics: diagnostics,
            for: request
        )
    }

    private func dimensions(of output: BeautyBackendOutput) -> (width: Int, height: Int) {
        switch output {
        case .pixelBuffer(let pixelBuffer):
            (CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
        case .stillImage(let image):
            (Int(image.extent.width), Int(image.extent.height))
        }
    }
}
