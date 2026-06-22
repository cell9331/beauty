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
        let total = faceShapeTotal(strengths)
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

    private func faceShapeTotal(_ strengths: BeautyEffectiveStrengths) -> Float {
        strengths.faceSlim +
            strengths.faceSmall +
            strengths.faceVShape +
            strengths.jawSlim +
            abs(strengths.chinLength)
    }

    private func nonZeroFaceShapeFieldCount(_ strengths: BeautyEffectiveStrengths) -> Int {
        [
            strengths.faceSlim,
            strengths.faceSmall,
            strengths.faceVShape,
            strengths.jawSlim,
            abs(strengths.chinLength)
        ].filter { $0 > Float.ulpOfOne }.count
    }
}
