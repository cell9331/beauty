import BeautyCore
import BeautyDetection

public enum BeautyEffectResolver {
    public static func resolve(parameters: BeautyParameters) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: nil, treatsMissingFaceAsNoFace: false)
    }

    package static func requiresFaceGeometry(parameters: BeautyParameters) -> Bool {
        let normalized = parameters.normalized()
        return anyNonZero(
            normalized.faceSlim,
            normalized.faceSmall,
            normalized.faceVShape,
            normalized.jawSlim,
            normalized.chinLength,
            normalized.eyeSize,
            normalized.eyeDistance,
            normalized.eyeYPosition,
            normalized.eyeTailLift,
            normalized.eyeHeight,
            normalized.eyeLength,
            normalized.upperEyelidLift,
            normalized.pupilSize,
            normalized.gazeCorrection,
            normalized.lowerEyelidDrop,
            normalized.eyeTilt,
            normalized.innerCornerOpen,
            normalized.outerCornerOpen,
            normalized.eyeSymmetry,
            normalized.noseSlim,
            normalized.noseWingSlim,
            normalized.noseTipSize,
            normalized.noseBridge,
            normalized.noseRootNarrowing,
            normalized.noseTipLift,
            normalized.mouthSize,
            normalized.mouthWidth,
            normalized.smile,
            normalized.mouthYPosition,
            normalized.mouthTilt,
            normalized.mouthXPosition,
            normalized.lipPeakDefinition,
            normalized.lipPlump,
            normalized.lipColor
        )
    }

    package static func resolve(
        parameters: BeautyParameters,
        selectedFaceObservation: BeautyFaceObservation?
    ) -> BeautyEffectPlan {
        resolve(
            parameters: parameters,
            faceGeometry: selectedFaceObservation.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
        )
    }

    static func resolve(parameters: BeautyParameters, faceGeometry: FaceGeometry?) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: faceGeometry, treatsMissingFaceAsNoFace: true)
    }

    private static func resolve(
        parameters: BeautyParameters,
        faceGeometry: FaceGeometry?,
        treatsMissingFaceAsNoFace: Bool
    ) -> BeautyEffectPlan {
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

        strengths.eyeSize = capUnit(normalized.eyeSize, cap: BeautySafetyCaps.eyeSize, cappedCount: &cappedCount)
        strengths.eyeDistance = capSigned(normalized.eyeDistance, cap: BeautySafetyCaps.eyeDistance, cappedCount: &cappedCount)
        strengths.eyeYPosition = capSigned(normalized.eyeYPosition, cap: BeautySafetyCaps.eyeYPosition, cappedCount: &cappedCount)
        strengths.eyeTailLift = capUnit(normalized.eyeTailLift, cap: BeautySafetyCaps.eyeTailLift, cappedCount: &cappedCount)
        strengths.eyeHeight = capUnit(normalized.eyeHeight, cap: BeautySafetyCaps.eyeHeight, cappedCount: &cappedCount)
        strengths.eyeLength = capUnit(normalized.eyeLength, cap: BeautySafetyCaps.eyeLength, cappedCount: &cappedCount)
        strengths.upperEyelidLift = capUnit(normalized.upperEyelidLift, cap: BeautySafetyCaps.upperEyelidLift, cappedCount: &cappedCount)
        strengths.pupilSize = capUnit(normalized.pupilSize, cap: BeautySafetyCaps.pupilSize, cappedCount: &cappedCount)
        strengths.gazeCorrection = capUnit(normalized.gazeCorrection, cap: BeautySafetyCaps.gazeCorrection, cappedCount: &cappedCount)
        strengths.lowerEyelidDrop = capUnit(normalized.lowerEyelidDrop, cap: BeautySafetyCaps.lowerEyelidDrop, cappedCount: &cappedCount)
        strengths.eyeTilt = capSigned(normalized.eyeTilt, cap: BeautySafetyCaps.eyeTilt, cappedCount: &cappedCount)
        strengths.innerCornerOpen = capUnit(normalized.innerCornerOpen, cap: BeautySafetyCaps.innerCornerOpen, cappedCount: &cappedCount)
        strengths.outerCornerOpen = capUnit(normalized.outerCornerOpen, cap: BeautySafetyCaps.outerCornerOpen, cappedCount: &cappedCount)
        strengths.eyeSymmetry = capUnit(normalized.eyeSymmetry, cap: BeautySafetyCaps.eyeSymmetry, cappedCount: &cappedCount)
        let hasRequestedEyeValues = anyNonZero(
            strengths.eyeSize,
            strengths.eyeDistance,
            strengths.eyeYPosition,
            strengths.eyeTailLift,
            strengths.eyeHeight,
            strengths.eyeLength,
            strengths.upperEyelidLift,
            strengths.pupilSize,
            strengths.gazeCorrection,
            strengths.lowerEyelidDrop,
            strengths.eyeTilt,
            strengths.innerCornerOpen,
            strengths.outerCornerOpen,
            strengths.eyeSymmetry
        )

        strengths.noseSlim = capUnit(normalized.noseSlim, cap: BeautySafetyCaps.noseSlim, cappedCount: &cappedCount)
        strengths.noseWingSlim = capUnit(normalized.noseWingSlim, cap: BeautySafetyCaps.noseWingSlim, cappedCount: &cappedCount)
        strengths.noseTipSize = capSigned(normalized.noseTipSize, cap: BeautySafetyCaps.noseTipSize, cappedCount: &cappedCount)
        strengths.noseBridge = capUnit(normalized.noseBridge, cap: BeautySafetyCaps.noseBridge, cappedCount: &cappedCount)
        strengths.noseRootNarrowing = capUnit(normalized.noseRootNarrowing, cap: BeautySafetyCaps.noseRootNarrowing, cappedCount: &cappedCount)
        strengths.noseTipLift = capUnit(normalized.noseTipLift, cap: BeautySafetyCaps.noseTipLift, cappedCount: &cappedCount)

        strengths.mouthSize = capSigned(normalized.mouthSize, cap: BeautySafetyCaps.mouthSize, cappedCount: &cappedCount)
        strengths.mouthWidth = capSigned(normalized.mouthWidth, cap: BeautySafetyCaps.mouthWidth, cappedCount: &cappedCount)
        strengths.smile = capUnit(normalized.smile, cap: BeautySafetyCaps.smile, cappedCount: &cappedCount)
        strengths.mouthYPosition = capSigned(normalized.mouthYPosition, cap: BeautySafetyCaps.mouthYPosition, cappedCount: &cappedCount)
        strengths.mouthTilt = capSigned(normalized.mouthTilt, cap: BeautySafetyCaps.mouthTilt, cappedCount: &cappedCount)
        strengths.mouthXPosition = capSigned(normalized.mouthXPosition, cap: BeautySafetyCaps.mouthXPosition, cappedCount: &cappedCount)
        strengths.lipPeakDefinition = capUnit(normalized.lipPeakDefinition, cap: BeautySafetyCaps.lipPeakDefinition, cappedCount: &cappedCount)
        strengths.lipPlump = capUnit(normalized.lipPlump, cap: BeautySafetyCaps.lipPlump, cappedCount: &cappedCount)
        strengths.lipColor = capUnit(normalized.lipColor, cap: BeautySafetyCaps.lipColor, cappedCount: &cappedCount)

        var extraWarnings: [BeautyValidationWarning] = []
        var appendedNoFaceWarning = false
        var appendedStaleGeometryWarning = false
        let staleGeometry = faceGeometry?.freshness == .stale
        let noUsableFace = treatsMissingFaceAsNoFace && faceGeometry == nil
        let hasReusableNonEyeGeometryValues = anyNonZero(
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            strengths.chinLength,
            strengths.noseSlim,
            strengths.noseWingSlim,
            strengths.noseTipSize,
            strengths.noseBridge,
            strengths.noseRootNarrowing,
            strengths.noseTipLift,
            strengths.mouthSize,
            strengths.mouthWidth,
            strengths.smile,
            strengths.mouthYPosition,
            strengths.mouthTilt,
            strengths.mouthXPosition,
            strengths.lipPeakDefinition,
            strengths.lipPlump
        )

        func appendStaleGeometryWarningIfNeeded() {
            guard !appendedStaleGeometryWarning else {
                return
            }
            appendedStaleGeometryWarning = true
            extraWarnings.append(Self.staleGeometryWarning)
        }

        func appendNoFaceWarningIfNeeded() {
            guard !appendedNoFaceWarning else {
                return
            }
            appendedNoFaceWarning = true
            extraWarnings.append(Self.faceShapeSkippedWarning)
        }

        if faceGeometry?.freshness == .reused, hasReusableNonEyeGeometryValues {
            Self.scaleReusableNonEyeGeometryStrengths(&strengths, by: 0.5)
            metrics["beauty.effects.reusedGeometryScale"] = 0.5
            extraWarnings.append(Self.reusedGeometryWarning)
        }
        if faceGeometry?.freshness == .reused, hasRequestedEyeValues {
            Self.zeroEyeStrengths(&strengths)
        } else if staleGeometry, hasRequestedEyeValues {
            Self.zeroEyeStrengths(&strengths)
        }

        let hadRequestedNoseValues = anyNonZero(
            strengths.noseSlim,
            strengths.noseWingSlim,
            strengths.noseTipSize,
            strengths.noseBridge,
            strengths.noseRootNarrowing,
            strengths.noseTipLift
        )
        let hadRequestedMouthValues = anyNonZero(
            strengths.mouthSize,
            strengths.mouthWidth,
            strengths.smile,
            strengths.mouthYPosition,
            strengths.mouthTilt,
            strengths.mouthXPosition,
            strengths.lipPeakDefinition,
            strengths.lipPlump
        )
        let noseProvider = NoseWarpProvider()
        let mouthProvider = MouthWarpProvider()
        let eyeProvider = EyeWarpProvider()
        if !staleGeometry, let faceGeometry {
            strengths = eyeProvider
                .fieldEmissions(face: faceGeometry, strengths: strengths)
                .sanitizing(strengths)
            strengths = noseProvider
                .fieldEmissions(face: faceGeometry, strengths: strengths)
                .sanitizing(strengths)
            strengths = mouthProvider
                .fieldEmissions(face: faceGeometry, strengths: strengths)
                .sanitizing(strengths)
        }

        if anyNonZero(strengths.skinSmoothing, strengths.skinWhitening, strengths.skinRosy, strengths.skinSharpen) {
            if noUsableFace {
                skippedDomains.insert(.skin)
                appendNoFaceWarningIfNeeded()
            } else {
                activeDomains.insert(.skin)
            }
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
        let hasMouthGeometryValues = anyNonZero(
            strengths.mouthSize,
            strengths.mouthWidth,
            strengths.smile,
            strengths.mouthYPosition,
            strengths.mouthTilt,
            strengths.mouthXPosition,
            strengths.lipPeakDefinition,
            strengths.lipPlump
        )
        if !staleGeometry,
           let faceGeometry,
           hasFaceShapeValues || hasMouthGeometryValues
        {
            let conflict = Self.resolveGeometryConflict(
                strengths: strengths,
                faceGeometry: faceGeometry,
                noseProvider: noseProvider,
                mouthProvider: mouthProvider
            )
            strengths = conflict.strengths
            extraWarnings.append(contentsOf: conflict.warnings)
            metrics.merge(conflict.metrics) { _, new in new }
        }

        if hasFaceShapeValues {
            if staleGeometry {
                skippedDomains.insert(.faceShape)
                metrics["beauty.effects.skippedFaceDomains"] = 1
                appendStaleGeometryWarningIfNeeded()
            } else if let faceGeometry {
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
                if noUsableFace {
                    appendNoFaceWarningIfNeeded()
                } else {
                    extraWarnings.append(Self.faceShapeSkippedWarning)
                }
            }
        }
        if hasRequestedEyeValues {
            if faceGeometry?.freshness == .reused {
                skippedDomains.insert(.eyes)
                metrics["beauty.effects.skippedEyeDomains"] = 1
                extraWarnings.append(Self.reusedEyeSkippedWarning)
            } else if staleGeometry {
                skippedDomains.insert(.eyes)
                metrics["beauty.effects.skippedEyeDomains"] = 1
                extraWarnings.append(Self.staleEyeSkippedWarning)
            } else if let faceGeometry {
                let result = eyeProvider.makeControlPoints(face: faceGeometry, strengths: strengths)
                if result.points.isEmpty {
                    Self.zeroEyeStrengths(&strengths)
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
                if noUsableFace {
                    appendNoFaceWarningIfNeeded()
                } else {
                    extraWarnings.append(Self.eyeSkippedWarning)
                }
            }
        }
        if hadRequestedNoseValues {
            if staleGeometry {
                Self.zeroNoseStrengths(&strengths)
                skippedDomains.insert(.nose)
                metrics["beauty.effects.skippedNoseDomains"] = 1
                appendStaleGeometryWarningIfNeeded()
            } else if let faceGeometry {
                let result = noseProvider.makeControlPoints(face: faceGeometry, strengths: strengths)
                if result.points.isEmpty {
                    Self.zeroNoseStrengths(&strengths)
                    skippedDomains.insert(.nose)
                    metrics["beauty.effects.skippedNoseDomains"] = 1
                    extraWarnings.append(Self.noseSkippedWarning)
                } else {
                    activeDomains.insert(.nose)
                    geometryPointCount += result.points.count
                }
            } else {
                Self.zeroNoseStrengths(&strengths)
                skippedDomains.insert(.nose)
                metrics["beauty.effects.skippedNoseDomains"] = 1
                if noUsableFace {
                    appendNoFaceWarningIfNeeded()
                } else {
                    extraWarnings.append(Self.noseSkippedWarning)
                }
            }
        }
        if hadRequestedMouthValues {
            if staleGeometry {
                Self.zeroMouthGeometryStrengths(&strengths)
                skippedDomains.insert(.mouth)
                metrics["beauty.effects.skippedMouthDomains"] = 1
                appendStaleGeometryWarningIfNeeded()
            } else if let faceGeometry {
                let result = mouthProvider.makeControlPoints(face: faceGeometry, strengths: strengths)
                if result.points.isEmpty {
                    Self.zeroMouthGeometryStrengths(&strengths)
                    skippedDomains.insert(.mouth)
                    metrics["beauty.effects.skippedMouthDomains"] = 1
                    extraWarnings.append(Self.mouthSkippedWarning)
                } else {
                    activeDomains.insert(.mouth)
                    geometryPointCount += result.points.count
                }
            } else {
                Self.zeroMouthGeometryStrengths(&strengths)
                skippedDomains.insert(.mouth)
                metrics["beauty.effects.skippedMouthDomains"] = 1
                if noUsableFace {
                    appendNoFaceWarningIfNeeded()
                } else {
                    extraWarnings.append(Self.mouthSkippedWarning)
                }
            }
        }
        if strengths.lipColor > 0 {
            if let faceGeometry, !faceGeometry.outerLips.isEmpty {
                activeDomains.insert(.lipColor)
            } else {
                strengths.lipColor = 0
                skippedDomains.insert(.lipColor)
                metrics["beauty.effects.skippedLipDomains"] = 1
                if noUsableFace {
                    appendNoFaceWarningIfNeeded()
                } else {
                    extraWarnings.append(Self.lipSkippedWarning)
                }
            }
        }

        if noUsableFace {
            let skippedFaceDependentCount = skippedDomains
                .intersection([.skin, .faceShape, .eyes, .nose, .mouth, .lipColor])
                .count
            if skippedFaceDependentCount > 0 {
                metrics["beauty.effects.skippedFaceDomains"] = Double(skippedFaceDependentCount)
            }
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

    private static func resolveGeometryConflict(
        strengths: BeautyEffectiveStrengths,
        faceGeometry: FaceGeometry,
        noseProvider: NoseWarpProvider,
        mouthProvider: MouthWarpProvider
    ) -> GeometryConflictResolution {
        var retainedBaseline = strengths

        // A conflict scale can move a previously emitting nose or mouth field
        // below its provider threshold. Remove that work from the unscaled
        // baseline and recompute so final emissions and conflict evidence share
        // one mask. Each pass can only remove fields: six nose plus eight mouth,
        // for an exact bounded convergence maximum of fourteen removals.
        for _ in 0..<14 {
            let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
            var nextBaseline = noseProvider
                .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
                .sanitizing(retainedBaseline)
            nextBaseline = mouthProvider
                .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
                .sanitizing(nextBaseline)
            if nextBaseline == retainedBaseline {
                return resolution
            }
            retainedBaseline = nextBaseline
        }

        return GeometryConflictResolver().resolve(strengths: retainedBaseline)
    }

    private static func zeroEyeStrengths(_ strengths: inout BeautyEffectiveStrengths) {
        strengths.eyeSize = 0
        strengths.eyeDistance = 0
        strengths.eyeYPosition = 0
        strengths.eyeTailLift = 0
        strengths.eyeHeight = 0
        strengths.eyeLength = 0
        strengths.upperEyelidLift = 0
        strengths.pupilSize = 0
        strengths.gazeCorrection = 0
        strengths.lowerEyelidDrop = 0
        strengths.eyeTilt = 0
        strengths.innerCornerOpen = 0
        strengths.outerCornerOpen = 0
        strengths.eyeSymmetry = 0
    }

    private static func zeroNoseStrengths(_ strengths: inout BeautyEffectiveStrengths) {
        zeroLegacyNoseStrengths(&strengths)
        strengths.noseRootNarrowing = 0
        strengths.noseTipLift = 0
    }

    private static func zeroLegacyNoseStrengths(_ strengths: inout BeautyEffectiveStrengths) {
        strengths.noseSlim = 0
        strengths.noseWingSlim = 0
        strengths.noseTipSize = 0
        strengths.noseBridge = 0
    }

    private static func zeroMouthGeometryStrengths(_ strengths: inout BeautyEffectiveStrengths) {
        strengths.mouthSize = 0
        strengths.mouthWidth = 0
        strengths.smile = 0
        strengths.mouthYPosition = 0
        strengths.mouthTilt = 0
        strengths.mouthXPosition = 0
        strengths.lipPeakDefinition = 0
        strengths.lipPlump = 0
    }

    private static func scaleReusableNonEyeGeometryStrengths(_ strengths: inout BeautyEffectiveStrengths, by scale: Float) {
        strengths.faceSlim *= scale
        strengths.faceSmall *= scale
        strengths.faceVShape *= scale
        strengths.jawSlim *= scale
        strengths.chinLength *= scale
        strengths.noseSlim *= scale
        strengths.noseWingSlim *= scale
        strengths.noseTipSize *= scale
        strengths.noseBridge *= scale
        strengths.noseRootNarrowing *= scale
        strengths.noseTipLift *= scale
        strengths.mouthSize *= scale
        strengths.mouthWidth *= scale
        strengths.smile *= scale
        strengths.mouthYPosition *= scale
        strengths.mouthTilt *= scale
        strengths.mouthXPosition *= scale
        strengths.lipPeakDefinition *= scale
        strengths.lipPlump *= scale
    }

    private static var faceShapeSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "face_effects_skipped_no_face",
            message: "Face-dependent geometry was skipped because no usable face was available."
        )
    }

    private static var eyeSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "eye_inputs_missing",
            message: "Eye effects skipped: inputs incomplete."
        )
    }

    private static var reusedEyeSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "eye_geometry_reused_skipped",
            message: "Eye effects skipped: inputs reused."
        )
    }

    private static var staleEyeSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "eye_geometry_stale_skipped",
            message: "Eye effects skipped: inputs stale."
        )
    }

    private static var noseSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "nose_inputs_missing",
            message: "Nose geometry was skipped because required nose inputs were unavailable."
        )
    }

    private static var mouthSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "mouth_inputs_missing",
            message: "Mouth geometry was skipped because required mouth inputs were unavailable."
        )
    }

    private static var lipSkippedWarning: BeautyValidationWarning {
        BeautyValidationWarning(
            code: "lip_inputs_missing",
            message: "Lip color was skipped because required mouth inputs were unavailable."
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
