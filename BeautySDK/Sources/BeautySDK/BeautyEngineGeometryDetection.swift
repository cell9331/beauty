import CoreGraphics
import CoreImage
import BeautyCore
import BeautyDetection
import BeautyEffects

struct BeautyEngineGeometryRoute {
    let plan: BeautyEffectPlan
    let detectionSummary: BeautyDetectionSummary
    let selectedFaceObservation: BeautyFaceObservation?
}

extension BeautyEngine {
    func resolveStillImageGeometry(
        image: CIImage? = nil,
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        parameters: BeautyParameters,
        requiresLocalSupport: Bool = false
    ) -> BeautyEngineGeometryRoute {
        let requiresFaceGeometry = BeautyEffectResolver.requiresFaceGeometry(parameters: parameters)
        guard requiresFaceGeometry || requiresLocalSupport else {
            return BeautyEngineGeometryRoute(
                plan: BeautyEffectResolver.resolve(parameters: parameters),
                detectionSummary: initialDetectionSummary,
                selectedFaceObservation: nil
            )
        }

        guard configuration.enableFaceTracking else {
            let plan = BeautyEffectResolver.resolve(
                parameters: parameters,
                selectedFaceObservation: nil
            )
            return BeautyEngineGeometryRoute(
                plan: withDetectionMetrics(
                    plan,
                    summary: .disabled,
                    geometryRequired: requiresFaceGeometry
                ),
                detectionSummary: .disabled,
                selectedFaceObservation: nil
            )
        }

        let purpose: VisionFaceDetector.DetectionPurpose
        switch (requiresFaceGeometry, requiresLocalSupport) {
        case (true, true):
            purpose = .geometryAndLocalSupport
        case (true, false):
            purpose = .geometry
        case (false, true):
            purpose = .localSupport
        case (false, false):
            preconditionFailure("detection purpose requires geometry or local support")
        }

        let detection = faceDetector.detect(
            image: image,
            metadata: metadata,
            imageExtent: imageExtent,
            configuration: configuration,
            purpose: purpose
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: parameters,
            selectedFaceObservation: detection.observations.first
        )
        return BeautyEngineGeometryRoute(
            plan: withDetectionMetrics(
                plan,
                summary: detection.summary,
                geometryRequired: requiresFaceGeometry
            ),
            detectionSummary: detection.summary,
            selectedFaceObservation: detection.observations.first
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
