import BeautyCore

struct GeometryConflictResolution: Equatable, Sendable {
    let strengths: BeautyEffectiveStrengths
    let warnings: [BeautyValidationWarning]
    let metrics: [String: Double]
}

struct GeometryConflictResolver: Sendable {
    private let totalThreshold: Float

    init(totalThreshold: Float = 1.0) {
        self.totalThreshold = totalThreshold
    }

    func resolve(strengths: BeautyEffectiveStrengths) -> GeometryConflictResolution {
        let total = geometryTotal(strengths)
        guard total > totalThreshold else {
            return GeometryConflictResolution(strengths: strengths, warnings: [], metrics: [:])
        }

        let scale = totalThreshold / total
        var weakened = strengths
        weakened.faceSlim *= scale
        weakened.faceSmall *= scale
        weakened.faceVShape *= scale
        weakened.jawSlim *= scale
        weakened.chinLength *= scale
        weakened.faceContourSmooth *= scale
        weakened.templeFullness *= scale
        weakened.cheekboneSlim *= scale
        weakened.chinTaper *= scale
        weakened.eyeSize *= scale
        weakened.eyeDistance *= scale
        weakened.eyeYPosition *= scale
        weakened.eyeTailLift *= scale
        weakened.eyeHeight *= scale
        weakened.eyeLength *= scale
        weakened.upperEyelidLift *= scale
        weakened.pupilSize *= scale
        weakened.gazeCorrection *= scale
        weakened.lowerEyelidDrop *= scale
        weakened.eyeTilt *= scale
        weakened.innerCornerOpen *= scale
        weakened.outerCornerOpen *= scale
        weakened.eyeSymmetry *= scale
        weakened.eyebrowYPosition *= scale
        weakened.eyebrowThickness *= scale
        weakened.eyebrowLength *= scale
        weakened.eyebrowSpacing *= scale
        weakened.eyebrowHeadSpacing *= scale
        weakened.eyebrowTilt *= scale
        weakened.eyebrowPeakDefinition *= scale
        weakened.noseSlim *= scale
        weakened.noseWingSlim *= scale
        weakened.noseTipSize *= scale
        weakened.noseBridge *= scale
        weakened.noseRootNarrowing *= scale
        weakened.noseTipLift *= scale
        weakened.mouthSize *= scale
        weakened.mouthWidth *= scale
        weakened.smile *= scale
        weakened.mouthYPosition *= scale
        weakened.mouthTilt *= scale
        weakened.mouthXPosition *= scale
        weakened.lipPeakDefinition *= scale
        weakened.lipPlump *= scale

        return GeometryConflictResolution(
            strengths: weakened,
            warnings: [
                BeautyValidationWarning(
                    code: "combined_geometry_weakened",
                    message: "Combined geometry strength was reduced for natural output."
                )
            ],
            metrics: [
                "beauty.effects.weakenedCount": Double(nonZeroFaceShapeFieldCount(strengths)),
                "beauty.effects.geometryStrengthScale": Double(scale)
            ]
        )
    }

    private func geometryTotal(_ strengths: BeautyEffectiveStrengths) -> Float {
        let fields: [Float] = [
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            abs(strengths.chinLength),
            strengths.faceContourSmooth,
            strengths.templeFullness,
            strengths.cheekboneSlim,
            strengths.chinTaper,
            abs(strengths.eyeSize),
            abs(strengths.eyeDistance),
            abs(strengths.eyeYPosition),
            abs(strengths.eyeTailLift),
            strengths.eyeHeight,
            strengths.eyeLength,
            strengths.upperEyelidLift,
            strengths.pupilSize,
            strengths.gazeCorrection,
            strengths.lowerEyelidDrop,
            abs(strengths.eyeTilt),
            strengths.innerCornerOpen,
            strengths.outerCornerOpen,
            strengths.eyeSymmetry,
            abs(strengths.eyebrowYPosition),
            abs(strengths.eyebrowThickness),
            abs(strengths.eyebrowLength),
            abs(strengths.eyebrowSpacing),
            abs(strengths.eyebrowHeadSpacing),
            abs(strengths.eyebrowTilt),
            strengths.eyebrowPeakDefinition,
            strengths.noseSlim,
            strengths.noseWingSlim,
            abs(strengths.noseTipSize),
            strengths.noseBridge,
            strengths.noseRootNarrowing,
            strengths.noseTipLift,
            abs(strengths.mouthSize),
            abs(strengths.mouthWidth),
            strengths.smile,
            abs(strengths.mouthYPosition),
            abs(strengths.mouthTilt),
            abs(strengths.mouthXPosition),
            strengths.lipPeakDefinition,
            strengths.lipPlump,
        ]
        return Float(fields.reduce(0.0) { $0 + Double($1) })
    }

    private func nonZeroFaceShapeFieldCount(_ strengths: BeautyEffectiveStrengths) -> Int {
        [
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            abs(strengths.chinLength),
            strengths.faceContourSmooth,
            strengths.templeFullness,
            strengths.cheekboneSlim,
            strengths.chinTaper,
            abs(strengths.eyeSize),
            abs(strengths.eyeDistance),
            abs(strengths.eyeYPosition),
            abs(strengths.eyeTailLift),
            strengths.eyeHeight,
            strengths.eyeLength,
            strengths.upperEyelidLift,
            strengths.pupilSize,
            strengths.gazeCorrection,
            strengths.lowerEyelidDrop,
            abs(strengths.eyeTilt),
            strengths.innerCornerOpen,
            strengths.outerCornerOpen,
            strengths.eyeSymmetry,
            abs(strengths.eyebrowYPosition),
            abs(strengths.eyebrowThickness),
            abs(strengths.eyebrowLength),
            abs(strengths.eyebrowSpacing),
            abs(strengths.eyebrowHeadSpacing),
            abs(strengths.eyebrowTilt),
            strengths.eyebrowPeakDefinition,
            strengths.noseSlim,
            strengths.noseWingSlim,
            abs(strengths.noseTipSize),
            strengths.noseBridge,
            strengths.noseRootNarrowing,
            strengths.noseTipLift,
            abs(strengths.mouthSize),
            abs(strengths.mouthWidth),
            strengths.smile,
            abs(strengths.mouthYPosition),
            abs(strengths.mouthTilt),
            abs(strengths.mouthXPosition),
            strengths.lipPeakDefinition,
            strengths.lipPlump
        ].filter { $0 > Float.ulpOfOne }.count
    }
}
