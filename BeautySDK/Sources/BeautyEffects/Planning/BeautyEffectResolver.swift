import BeautyCore

public enum BeautyEffectResolver {
    public static func resolve(parameters: BeautyParameters) -> BeautyEffectPlan {
        let normalized = parameters.normalized()
        var activeDomains: Set<BeautyEffectDomain> = []
        var metrics: [String: Double] = [:]
        var cappedCount = 0

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
        if anyNonZero(strengths.faceSlim, strengths.faceSmall, strengths.faceVShape, strengths.jawSlim, strengths.chinLength) {
            activeDomains.insert(.faceShape)
        }
        if anyNonZero(strengths.eyeSize, strengths.eyeDistance, strengths.eyeYPosition, strengths.eyeTailLift) {
            activeDomains.insert(.eyes)
        }
        if anyNonZero(strengths.noseSlim, strengths.noseWingSlim, strengths.noseTipSize, strengths.noseBridge) {
            activeDomains.insert(.nose)
        }
        if anyNonZero(strengths.mouthSize, strengths.mouthWidth, strengths.smile) {
            activeDomains.insert(.mouth)
        }
        if strengths.lipColor > 0 {
            activeDomains.insert(.lipColor)
        }

        metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
        metrics["beauty.effects.cappedCount"] = Double(cappedCount)

        let warnings = cappedCount > 0 ? [
            BeautyValidationWarning(
                code: "beauty_strength_capped",
                message: "Effective beauty strength was capped for natural output."
            )
        ] : []

        return BeautyEffectPlan(
            activeDomains: activeDomains,
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
}
