struct NoseWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        guard let center = LandmarkGeometryHelper.center(of: face.nose) else {
            return WarpControlPointResult(points: [], skipReason: "nose_inputs_missing")
        }

        var points: [WarpControlPoint] = []

        if strengths.noseSlim > 0 {
            points.append(contentsOf: slimPoints(face: face, center: center, strength: strengths.noseSlim))
        }

        if strengths.noseWingSlim > 0 {
            points.append(contentsOf: wingPoints(face: face, center: center, strength: strengths.noseWingSlim))
        }

        if abs(strengths.noseTipSize) > Float.ulpOfOne {
            points.append(contentsOf: tipPoints(face: face, center: center, strength: abs(strengths.noseTipSize)))
        }

        if strengths.noseBridge > 0 {
            points.append(contentsOf: bridgePoints(face: face, center: center, strength: strengths.noseBridge))
        }

        return WarpControlPointResult(points: points)
    }

    private func slimPoints(
        face: FaceGeometry,
        center: SIMD2<Float>,
        strength: Float
    ) -> [WarpControlPoint] {
        guard let left = face.nose.min(by: { $0.x < $1.x }),
              let right = face.nose.max(by: { $0.x < $1.x }),
              left != right
        else {
            return []
        }

        let displacement = face.bounds.width * 0.035 * strength / BeautySafetyCaps.noseSlim
        return [
            makePoint(
                source: left,
                target: SIMD2<Float>(min(left.x + displacement, center.x), left.y),
                radius: face.bounds.width * 0.11,
                strength: strength
            ),
            makePoint(
                source: right,
                target: SIMD2<Float>(max(right.x - displacement, center.x), right.y),
                radius: face.bounds.width * 0.11,
                strength: strength
            )
        ]
    }

    private func wingPoints(
        face: FaceGeometry,
        center: SIMD2<Float>,
        strength: Float
    ) -> [WarpControlPoint] {
        lowerNosePoints(face: face, center: center).map { source in
            let horizontal = (center.x - source.x) * 0.45 * strength / BeautySafetyCaps.noseWingSlim
            return makePoint(
                source: source,
                target: SIMD2<Float>(source.x + horizontal, source.y),
                radius: face.bounds.width * 0.10,
                strength: strength
            )
        }
    }

    private func tipPoints(
        face: FaceGeometry,
        center: SIMD2<Float>,
        strength: Float
    ) -> [WarpControlPoint] {
        lowerNosePoints(face: face, center: center).map { source in
            makePoint(
                source: source,
                target: LandmarkGeometryHelper.move(source, toward: center, by: face.bounds.height * 0.025),
                radius: face.bounds.width * 0.09,
                strength: strength
            )
        }
    }

    private func bridgePoints(
        face: FaceGeometry,
        center: SIMD2<Float>,
        strength: Float
    ) -> [WarpControlPoint] {
        let upper = face.nose.filter { $0.y <= center.y }
        return upper.map { source in
            makePoint(
                source: source,
                target: SIMD2<Float>(center.x, source.y),
                radius: face.bounds.width * 0.08,
                strength: strength
            )
        }
    }

    private func lowerNosePoints(face: FaceGeometry, center: SIMD2<Float>) -> [SIMD2<Float>] {
        face.nose
            .filter { $0.y >= center.y }
            .sorted { $0.x < $1.x }
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
            radius: min(max(radius, 0.03), 0.20),
            strength: strength,
            falloff: 2
        )
    }
}
