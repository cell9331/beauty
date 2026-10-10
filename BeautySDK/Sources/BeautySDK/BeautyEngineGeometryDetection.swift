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
        requiresLocalSupport: Bool = false,
        skipDetectionForInterval: Bool = false,
        preparedSource: BeautyPreparedStillImageState? = nil,
        canonicalDetection: Bool = false
    ) -> BeautyEngineGeometryRoute {
        let requiresFaceGeometry = BeautyEffectResolver.requiresFaceGeometry(parameters: parameters)
        let normalized = parameters.normalized()
        let requiresTextureSupport = normalized.skinSmoothing > 0 || normalized.skinSharpen > 0
        guard requiresFaceGeometry || requiresLocalSupport || requiresTextureSupport else {
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

        if skipDetectionForInterval {
            let summary = BeautyDetectionSummary(
                availability: .skipped, reasons: [.detectionInterval]
            )
            let plan = BeautyEffectResolver.resolve(
                parameters: parameters, selectedFaceObservation: nil
            )
            return BeautyEngineGeometryRoute(
                plan: withDetectionMetrics(
                    plan, summary: summary, geometryRequired: requiresFaceGeometry
                ),
                detectionSummary: summary,
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
            purpose = .geometry
        }

        let detect = {
            self.faceDetector.detect(image: image, metadata: metadata,
                imageExtent: imageExtent, configuration: self.configuration, purpose: purpose)
        }
        let (detection, reused) = preparedSource.map {
            $0.detection(purpose: purpose, canonical: canonicalDetection, produce: detect)
        } ?? (detect(), false)
        let plan = BeautyEffectResolver.resolve(
            parameters: parameters,
            selectedFaceObservation: detection.observations.first
        )
        return BeautyEngineGeometryRoute(
            plan: withDetectionMetrics(
                plan,
                summary: detection.summary,
                geometryRequired: requiresFaceGeometry,
                observation: detection.observations.first,
                preparedReuse: preparedSource == nil ? nil : reused
            ),
            detectionSummary: detection.summary,
            selectedFaceObservation: detection.observations.first
        )
    }

    private func withDetectionMetrics(
        _ plan: BeautyEffectPlan,
        summary: BeautyDetectionSummary,
        geometryRequired: Bool,
        observation: BeautyFaceObservation? = nil,
        preparedReuse: Bool? = nil
    ) -> BeautyEffectPlan {
        var metrics = plan.metrics
        metrics["beauty.detection.geometryRequired"] = geometryRequired ? 1 : 0
        metrics["beauty.detection.faceCount"] = Double(summary.faceCount)
        metrics["beauty.detection.usedFaceCount"] = Double(summary.usedFaceCount)
        if let preparedReuse { metrics["beauty.detection.preparedReuse"] = preparedReuse ? 1 : 0 }
        if let mesh = observation?.mesh {
            metrics["beauty.detection.meshPointCount"] = Double(mesh.points.count)
            metrics["beauty.detection.hasFacialTransformation"] = mesh.facialTransformation == nil ? 0 : 1
        }
        return BeautyEffectPlan(
            activeDomains: plan.activeDomains,
            skippedDomains: plan.skippedDomains,
            warnings: plan.warnings,
            metrics: metrics,
            effectiveStrengths: plan.effectiveStrengths
        )
    }
}
