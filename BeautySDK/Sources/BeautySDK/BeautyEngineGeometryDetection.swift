import CoreGraphics
import CoreImage
import BeautyCore
import BeautyEffects

struct BeautyEngineGeometryRoute {
    let plan: BeautyEffectPlan
    let detectionSummary: BeautyDetectionSummary
}

extension BeautyEngine {
    func resolveStillImageGeometry(
        image: CIImage? = nil,
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        parameters: BeautyParameters
    ) -> BeautyEngineGeometryRoute {
        guard BeautyEffectResolver.requiresFaceGeometry(parameters: parameters) else {
            return BeautyEngineGeometryRoute(
                plan: BeautyEffectResolver.resolve(parameters: parameters),
                detectionSummary: initialDetectionSummary
            )
        }

        guard configuration.enableFaceTracking else {
            let plan = BeautyEffectResolver.resolve(
                parameters: parameters,
                selectedFaceObservation: nil
            )
            return BeautyEngineGeometryRoute(
                plan: withDetectionMetrics(plan, summary: .disabled, geometryRequired: true),
                detectionSummary: .disabled
            )
        }

        let detection = faceDetector.detect(
            image: image,
            metadata: metadata,
            imageExtent: imageExtent,
            configuration: configuration
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: parameters,
            selectedFaceObservation: detection.observations.first
        )
        return BeautyEngineGeometryRoute(
            plan: withDetectionMetrics(plan, summary: detection.summary, geometryRequired: true),
            detectionSummary: detection.summary
        )
    }

    private func withDetectionMetrics(
        _ plan: BeautyEffectPlan,
        summary: BeautyDetectionSummary,
        geometryRequired: Bool
    ) -> BeautyEffectPlan {
        var metrics = plan.metrics
        metrics["beauty.detection.geometryRequired"] = geometryRequired ? 1 : 0
        metrics["beauty.detection.faceCount"] = Double(summary.faceCount)
        metrics["beauty.detection.usedFaceCount"] = Double(summary.usedFaceCount)
        return BeautyEffectPlan(
            activeDomains: plan.activeDomains,
            skippedDomains: plan.skippedDomains,
            warnings: plan.warnings,
            metrics: metrics,
            effectiveStrengths: plan.effectiveStrengths
        )
    }
}
