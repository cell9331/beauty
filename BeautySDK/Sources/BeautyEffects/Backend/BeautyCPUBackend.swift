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
        var eyebrowAdmittedSideCount: Int? = request.inputKind == .stillImage &&
            BeautyBackendDiagnostics.requestsEyebrowAdmission(request.plan) ? 0 : nil
        let onEyebrowAppliedSideCount: (Int) -> Void = { count in
            if eyebrowAdmittedSideCount != nil { eyebrowAdmittedSideCount = count }
        }
        let output: BeautyBackendOutput
        switch request.input {
        case .pixelBuffer(let pixelBuffer):
            output = .pixelBuffer(
                try BeautyColorEffectPipeline.apply(
                    to: pixelBuffer,
                    plan: request.plan,
                    renderQuality: request.renderQuality,
                    face: nil,
                    textureFaceBounds: request.textureFaceBounds,
                    textureExclusionMask: request.textureExclusionMask
                )
            )
        case .stillImage(let image):
            let rendered: CIImage
            if let canonicalImage = request.canonicalImage {
                rendered = BeautyColorEffectPipeline.apply(
                    to: canonicalImage,
                    plan: request.plan,
                    renderQuality: request.renderQuality,
                    selectedFaceObservation: request.selectedFaceSupport,
                    textureExclusionMask: request.textureExclusionMask,
                    onEyebrowAppliedSideCount: onEyebrowAppliedSideCount
                )
            } else {
                rendered = BeautyColorEffectPipeline.apply(
                    to: image,
                    plan: request.plan,
                    renderQuality: request.renderQuality,
                    selectedFaceObservation: request.selectedFaceSupport,
                    textureExclusionMask: request.textureExclusionMask,
                    onEyebrowAppliedSideCount: onEyebrowAppliedSideCount
                )
            }
            output = .stillImage(rendered)
        }

        let dimensions = dimensions(of: output)
        let diagnostics = BeautyBackendDiagnostics(
            width: dimensions.width,
            height: dimensions.height,
            compositionSummary: request.compositionSummary,
            eyebrowAdmittedSideCount: eyebrowAdmittedSideCount
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
