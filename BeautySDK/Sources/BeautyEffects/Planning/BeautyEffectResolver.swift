import BeautyCore

public enum BeautyEffectResolver {
    public static func resolve(parameters: BeautyParameters) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: nil)
    }

    static func resolve(parameters: BeautyParameters, faceGeometry: FaceGeometry?) -> BeautyEffectPlan {
        let normalized = parameters.normalized()
        var activeDomains: Set<BeautyEffectDomain> = []
        var skippedDomains: Set<BeautyEffectDomain> = []
        var metrics: [String: Double] = [:]
        var cappedCount = 0
        var geometryPointCount = 0

        var strengths = BeautyEffectiveStrengths()
        strengths.skinSmoothing = capUnit(normalized.skinSmoothing, cap: BeautySafetyCaps.skinSmoothing, cappedCount: &cappedCount)
        strengths.skinWhitening = capUnit(normalized.skinWhitening, cap: BeautySafetyCaps.skinWhitening, cappedCount: &cappedCount)
        strengths.skinRosy = capUnit(normalized.skinRosy, cap: BeautySafetyCaps.skinRosy, cappedCount: &cappedCount)
        strengths.skinSharpen = capUnit(normalized.skinSharpen, cap: BeautySafetyCaps.skinSharpen, cappedCount: &cappedCount)

        strengths.brightness = normalized.brightness
        strengths.contrast = normalized.contrast
        strengths.saturation = normalized.saturation
        strengths.temperature = normalized.temperature
        strengths.tint = normalized.tint
        strengths.exposure = normalized.exposure
        strengths.highlight = normalized.highlight
        strengths.shadow = normalized.shadow
        strengths.filterIntensity = min(normalized.filterIntensity, BeautySafetyCaps.filterIntensity)

        strengths.faceSlim = capUnit(normalized.faceSlim, cap: BeautySafetyCaps.faceSlim, cappedCount: &cappedCount)
        strengths.faceSmall = capUnit(normalized.faceSmall, cap: BeautySafetyCaps.faceSmall, cappedCount: &cappedCount)
        strengths.faceVShape = capUnit(normalized.faceVShape, cap: BeautySafetyCaps.faceVShape, cappedCount: &cappedCount)
        strengths.jawSlim = capUnit(normalized.jawSlim, cap: BeautySafetyCaps.jawSlim, cappedCount: &cappedCount)
        strengths.chinLength = capSigned(normalized.chinLength, cap: BeautySafetyCaps.chinLength, cappedCount: &cappedCount)

        strengths.eyeSize = capSigned(normalized.eyeSize, cap: BeautySafetyCaps.eyeSize, cappedCount: &cappedCount)
        strengths.eyeDistance = capSigned(normalized.eyeDistance, cap: BeautySafetyCaps.eyeDistance, cappedCount: &cappedCount)
        strengths.eyeYPosition = capSigned(normalized.eyeYPosition, cap: BeautySafetyCaps.eyeYPosition, cappedCount: &cappedCount)
        strengths.eyeTailLift = capSigned(normalized.eyeTailLift, cap: BeautySafetyCaps.eyeTailLift, cappedCount: &cappedCount)

        strengths.noseSlim = capUnit(normalized.noseSlim, cap: BeautySafetyCaps.noseSlim, cappedCount: &cappedCount)
        strengths.noseWingSlim = capUnit(normalized.noseWingSlim, cap: BeautySafetyCaps.noseWingSlim, cappedCount: &cappedCount)
        strengths.noseTipSize = capSigned(normalized.noseTipSize, cap: BeautySafetyCaps.noseTipSize, cappedCount: &cappedCount)
        strengths.noseBridge = capUnit(normalized.noseBridge, cap: BeautySafetyCaps.noseBridge, cappedCount: &cappedCount)

        strengths.mouthSize = capSigned(normalized.mouthSize, cap: BeautySafetyCaps.mouthSize, cappedCount: &cappedCount)
        strengths.mouthWidth = capSigned(normalized.mouthWidth, cap: BeautySafetyCaps.mouthWidth, cappedCount: &cappedCount)
        strengths.smile = capUnit(normalized.smile, cap: BeautySafetyCaps.smile, cappedCount: &cappedCount)
        strengths.lipColor = capUnit(normalized.lipColor, cap: BeautySafetyCaps.lipColor, cappedCount: &cappedCount)

        var extraWarnings: [BeautyValidationWarning] = []
        var appendedStaleGeometryWarning = false
        let staleGeometry = faceGeometry?.freshness == .stale
        let hasGeometryValues = anyNonZero(
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            strengths.chinLength,
            strengths.eyeSize,
            strengths.eyeDistance,
            strengths.eyeYPosition,
            strengths.eyeTailLift,
            strengths.noseSlim,
            strengths.noseWingSlim,
            strengths.noseTipSize,
            strengths.noseBridge
        )

        func appendStaleGeometryWarningIfNeeded() {
            guard !appendedStaleGeometryWarning else {
                return
            }
            appendedStaleGeometryWarning = true
            extraWarnings.append(Self.staleGeometryWarning)
        }

        if faceGeometry?.freshness == .reused, hasGeometryValues {
            Self.scaleGeometryStrengths(&strengths, by: 0.5)
            metrics["beauty.effects.reusedGeometryScale"] = 0.5
            extraWarnings.append(Self.reusedGeometryWarning)
        }

        if anyNonZero(strengths.skinSmoothing, strengths.skinWhitening, strengths.skinRosy, strengths.skinSharpen) {
            activeDomains.insert(.skin)
        }
        if anyNonZero(
            strengths.brightness,
            strengths.contrast,
            strengths.saturation,
            strengths.temperature,
            strengths.tint,
            strengths.exposure,
            strengths.highlight,
            strengths.shadow
        ) {
            activeDomains.insert(.color)
        }
        if normalized.filterId != nil, strengths.filterIntensity > 0 {
            activeDomains.insert(.filter)
            if normalized.filterId == "soft_clean" {
                metrics["beauty.effects.filter.softClean"] = 1
            }
            if normalized.filterId == "warm_light" {
                metrics["beauty.effects.filter.warmLight"] = 1
            }
        }
        let hasFaceShapeValues = anyNonZero(
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            strengths.chinLength
        )

        if hasFaceShapeValues {
            if staleGeometry {
                skippedDomains.insert(.faceShape)
                metrics["beauty.effects.skippedFaceDomains"] = 1
                appendStaleGeometryWarningIfNeeded()
            } else if let faceGeometry {
                let conflict = GeometryConflictResolver().resolve(strengths: strengths)
                strengths = conflict.strengths
                extraWarnings.append(contentsOf: conflict.warnings)
                metrics.merge(conflict.metrics) { _, new in new }

                let faceShapePointCount = BeautyGeometryEffectPipeline
                    .controlPoints(for: strengths, face: faceGeometry)
                    .count
                if faceShapePointCount > 0 {
                    activeDomains.insert(.faceShape)
                    geometryPointCount += faceShapePointCount
                } else {
                    skippedDomains.insert(.faceShape)
                    extraWarnings.append(Self.faceShapeSkippedWarning)
                }
            } else {
                skippedDomains.insert(.faceShape)
                metrics["beauty.effects.skippedFaceDomains"] = 1
                extraWarnings.append(Self.faceShapeSkippedWarning)
            }
        }
        if anyNonZero(strengths.eyeSize, strengths.eyeDistance, strengths.eyeYPosition, strengths.eyeTailLift) {
            if staleGeometry {
                skippedDomains.insert(.eyes)
                metrics["beauty.effects.skippedEyeDomains"] = 1
                appendStaleGeometryWarningIfNeeded()
            } else if let faceGeometry {
                let result = EyeWarpProvider().makeControlPoints(face: faceGeometry, strengths: strengths)
                if result.points.isEmpty {
                    skippedDomains.insert(.eyes)
                    metrics["beauty.effects.skippedEyeDomains"] = 1
                    extraWarnings.append(Self.eyeSkippedWarning)
                } else {
                    activeDomains.insert(.eyes)
                    geometryPointCount += result.points.count
                }
            } else {
                skippedDomains.insert(.eyes)
                metrics["beauty.effects.skippedEyeDomains"] = 1
                extraWarnings.append(Self.eyeSkippedWarning)
            }
        }
        if anyNonZero(strengths.noseSlim, strengths.noseWingSlim, strengths.noseTipSize, strengths.noseBridge) {
            if staleGeometry {
                skippedDomains.insert(.nose)
                metrics["beauty.effects.skippedNoseDomains"] = 1
                appendStaleGeometryWarningIfNeeded()
            } else if let faceGeometry {
                let result = NoseWarpProvider().makeControlPoints(face: faceGeometry, strengths: strengths)
                if result.points.isEmpty {
                    skippedDomains.insert(.nose)
                    metrics["beauty.effects.skippedNoseDomains"] = 1
                    extraWarnings.append(Self.noseSkippedWarning)
                } else {
                    activeDomains.insert(.nose)
                    geometryPointCount += result.points.count
                }
            } else {
                skippedDomains.insert(.nose)
                metrics["beauty.effects.skippedNoseDomains"] = 1
                extraWarnings.append(Self.noseSkippedWarning)
            }
        }
        if anyNonZero(strengths.mouthSize, strengths.mouthWidth, strengths.smile) {
            activeDomains.insert(.mouth)
        }
        if strengths.lipColor > 0 {
            activeDomains.insert(.lipColor)
        }

        metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
        metrics["beauty.effects.cappedCount"] = Double(cappedCount)
        if geometryPointCount > 0 {
            metrics["beauty.effects.geometryPointCount"] = Double(geometryPointCount)
        }

        var warnings = cappedCount > 0 ? [
            BeautyValidationWarning(
                code: "beauty_strength_capped",
                message: "Effective beauty strength was capped for natural output."
            )
        ] : []
        warnings.append(contentsOf: extraWarnings)

        return BeautyEffectPlan(
            activeDomains: activeDomains,
            skippedDomains: skippedDomains,
            warnings: warnings,
            metrics: metrics,
            effectiveStrengths: strengths
        )
    }

    private static func capUnit(_ value: Float, cap: Float, cappedCount: inout Int) -> Float {
        guard value > cap else {
            return value
        }
        cappedCount += 1
        return cap
    }

    private static func capSigned(_ value: Float, cap: Float, cappedCount: inout Int) -> Float {
        guard abs(value) > cap else {
            return value
        }
        cappedCount += 1
        return value < 0 ? -cap : cap
    }

    private static func anyNonZero(_ values: Float...) -> Bool {
        values.contains { abs($0) > Float.ulpOfOne }
    }

    private static func scaleGeometryStrengths(_ strengths: inout BeautyEffectiveStrengths, by scale: Float) {
        strengths.faceSlim *= scale
        strengths.faceSmall *= scale
        strengths.faceVShape *= scale
        strengths.jawSlim *= scale
        strengths.chinLength *= scale
        strengths.eyeSize *= scale
        strengths.eyeDistance *= scale
        strengths.eyeYPosition *= scale
        strengths.eyeTailLift *= scale
        strengths.noseSlim *= scale
        strengths.noseWingSlim *= scale
        strengths.noseTipSize *= scale
        strengths.noseBridge *= scale
    }

    private static var faceShapeSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "face_effects_skipped_no_face",
            message: "Face-dependent geometry was skipped because no usable face was available."
        )
    }

    private static var eyeSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "eye_landmarks_missing",
            message: "Eye geometry was skipped because required eye inputs were unavailable."
        )
    }

    private static var noseSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "nose_landmarks_missing",
            message: "Nose geometry was skipped because required nose inputs were unavailable."
        )
    }

    private static var reusedGeometryWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "geometry_stale_reduced",
            message: "Reused face geometry reduced effective geometry strength."
        )
    }

    private static var staleGeometryWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "geometry_stale_skipped",
            message: "Stale face geometry skipped strong geometry output."
        )
    }
}
