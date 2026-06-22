struct ChinWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        guard !face.faceContour.isEmpty else {
            return .missingFaceContour
        }
        guard abs(strengths.chinLength) > Float.ulpOfOne,
              let chin = face.faceContour.max(by: { $0.y < $1.y })
        else {
            return WarpControlPointResult(points: [])
        }

        let direction: Float = strengths.chinLength < 0 ? -1 : 1
        let strength = min(abs(strengths.chinLength), BeautySafetyCaps.chinLength)
        let displacement = face.bounds.height * 0.08 * strength / BeautySafetyCaps.chinLength
        let target = SIMD2<Float>(chin.x, chin.y + direction * displacement)

        return WarpControlPointResult(points: [
            WarpControlPoint(
                source: LandmarkGeometryHelper.clamp(chin),
                target: LandmarkGeometryHelper.clamp(target),
                radius: min(max(face.bounds.width * 0.22, 0.04), 0.30),
                strength: strength,
                falloff: 2
            )
        ])
    }
}
