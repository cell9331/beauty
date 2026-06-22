struct FaceShapeWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        guard !face.faceContour.isEmpty else {
            return .missingFaceContour
        }

        var points: [WarpControlPoint] = []

        if strengths.faceSlim > 0 {
            points.append(contentsOf: cheekPoints(face: face, strength: strengths.faceSlim))
        }

        if strengths.faceSmall > 0 {
            points.append(contentsOf: smallFacePoints(face: face, strength: strengths.faceSmall))
        }

        if strengths.faceVShape > 0 {
            points.append(contentsOf: lowerFacePoints(
                face: face,
                strength: strengths.faceVShape,
                maxStrength: BeautySafetyCaps.faceVShape,
                horizontalScale: 0.09,
                verticalScale: 0.025
            ))
        }

        if strengths.jawSlim > 0 {
            points.append(contentsOf: lowerFacePoints(
                face: face,
                strength: strengths.jawSlim,
                maxStrength: BeautySafetyCaps.jawSlim,
                horizontalScale: 0.07,
                verticalScale: 0
            ))
        }

        return WarpControlPointResult(points: points)
    }

    private func cheekPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        let y = face.bounds.minY + face.bounds.height * 0.58
        let leftSource = SIMD2<Float>(face.bounds.minX + face.bounds.width * 0.14, y)
        let rightSource = SIMD2<Float>(face.bounds.maxX - face.bounds.width * 0.14, y)
        let displacement = face.bounds.width * 0.10 * strength / BeautySafetyCaps.faceSlim

        return [
            makePoint(
                source: leftSource,
                target: SIMD2<Float>(leftSource.x + displacement, leftSource.y),
                radius: face.bounds.width * 0.28,
                strength: strength
            ),
            makePoint(
                source: rightSource,
                target: SIMD2<Float>(rightSource.x - displacement, rightSource.y),
                radius: face.bounds.width * 0.28,
                strength: strength
            )
        ]
    }

    private func smallFacePoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        let movement = face.bounds.width * 0.07 * strength / BeautySafetyCaps.faceSmall
        return face.faceContour.map { source in
            makePoint(
                source: source,
                target: LandmarkGeometryHelper.move(source, toward: face.center, by: movement),
                radius: face.bounds.width * 0.22,
                strength: strength
            )
        }
    }

    private func lowerFacePoints(
        face: FaceGeometry,
        strength: Float,
        maxStrength: Float,
        horizontalScale: Float,
        verticalScale: Float
    ) -> [WarpControlPoint] {
        let lowerContour = face.faceContour
            .filter { $0.y >= face.bounds.midY }
            .sorted { $0.x < $1.x }

        guard let left = lowerContour.first, let right = lowerContour.last, left != right else {
            return []
        }

        let horizontal = face.bounds.width * horizontalScale * strength / maxStrength
        let vertical = face.bounds.height * verticalScale * strength / maxStrength
        return [
            makePoint(
                source: left,
                target: SIMD2<Float>(left.x + horizontal, left.y + vertical),
                radius: face.bounds.width * 0.24,
                strength: strength
            ),
            makePoint(
                source: right,
                target: SIMD2<Float>(right.x - horizontal, right.y + vertical),
                radius: face.bounds.width * 0.24,
                strength: strength
            )
        ]
    }

    private func makePoint(
        source: SIMD2<Float>,
        target: SIMD2<Float>,
        radius: Float,
        strength: Float
    ) -> WarpControlPoint {
        WarpControlPoint(
            source: LandmarkGeometryHelper.clamp(source),
            target: LandmarkGeometryHelper.clamp(target),
            radius: min(max(radius, 0.04), 0.35),
            strength: strength,
            falloff: 2
        )
    }
}
