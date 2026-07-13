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
        weakened.eyeSize *= scale
        weakened.eyeDistance *= scale
        weakened.eyeYPosition *= scale
        weakened.eyeTailLift *= scale
        weakened.noseSlim *= scale
        weakened.noseWingSlim *= scale
        weakened.noseTipSize *= scale
        weakened.noseBridge *= scale
        weakened.noseRootNarrowing *= scale
        weakened.noseTipLift *= scale
        weakened.mouthSize *= scale
        weakened.mouthWidth *= scale
        weakened.smile *= scale

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
        strengths.faceSlim +
            strengths.faceSmall +
            strengths.faceVShape +
            strengths.jawSlim +
            abs(strengths.chinLength) +
            abs(strengths.eyeSize) +
            abs(strengths.eyeDistance) +
            abs(strengths.eyeYPosition) +
            abs(strengths.eyeTailLift) +
            strengths.noseSlim +
            strengths.noseWingSlim +
            abs(strengths.noseTipSize) +
            strengths.noseBridge +
            strengths.noseRootNarrowing +
            strengths.noseTipLift +
            abs(strengths.mouthSize) +
            abs(strengths.mouthWidth) +
            strengths.smile
    }

    private func nonZeroFaceShapeFieldCount(_ strengths: BeautyEffectiveStrengths) -> Int {
        [
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            abs(strengths.chinLength),
            abs(strengths.eyeSize),
            abs(strengths.eyeDistance),
            abs(strengths.eyeYPosition),
            abs(strengths.eyeTailLift),
            strengths.noseSlim,
            strengths.noseWingSlim,
            abs(strengths.noseTipSize),
            strengths.noseBridge,
            strengths.noseRootNarrowing,
            strengths.noseTipLift,
            abs(strengths.mouthSize),
            abs(strengths.mouthWidth),
            strengths.smile
        ].filter { $0 > Float.ulpOfOne }.count
    }
}
