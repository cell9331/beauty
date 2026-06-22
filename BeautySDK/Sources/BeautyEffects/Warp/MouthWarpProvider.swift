struct MouthWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        guard let center = LandmarkGeometryHelper.center(of: face.outerLips) else {
            return WarpControlPointResult(points: [], skipReason: "mouth_landmarks_missing")
        }

        var points: [WarpControlPoint] = []

        if abs(strengths.mouthSize) > Float.ulpOfOne {
            points.append(contentsOf: sizePoints(face: face, center: center, strength: strengths.mouthSize))
        }

        if abs(strengths.mouthWidth) > Float.ulpOfOne {
            points.append(contentsOf: widthPoints(face: face, center: center, strength: strengths.mouthWidth))
        }

        if strengths.smile > 0 {
            points.append(contentsOf: smilePoints(face: face, strength: strengths.smile))
        }

        return WarpControlPointResult(points: points)
    }

    private func sizePoints(
        face: FaceGeometry,
        center: SIMD2<Float>,
        strength: Float
    ) -> [WarpControlPoint] {
        let displacement = face.bounds.width * 0.035 * abs(strength) / BeautySafetyCaps.mouthSize
        return cardinalLipPoints(face.outerLips, center: center).map { source in
            let target = strength < 0 ?
                LandmarkGeometryHelper.move(source, toward: center, by: displacement) :
                move(source, awayFrom: center, by: displacement)
            return makePoint(
                source: source,
                target: target,
                radius: face.bounds.width * 0.13,
                strength: abs(strength)
            )
        }
    }

    private func widthPoints(
        face: FaceGeometry,
        center: SIMD2<Float>,
        strength: Float
    ) -> [WarpControlPoint] {
        guard let left = face.outerLips.min(by: { $0.x < $1.x }),
              let right = face.outerLips.max(by: { $0.x < $1.x }),
              left != right
        else {
            return []
        }

        let displacement = face.bounds.width * 0.040 * abs(strength) / BeautySafetyCaps.mouthWidth
        let direction: Float = strength < 0 ? -1 : 1
        return [
            makePoint(
                source: left,
                target: SIMD2<Float>(left.x - displacement * direction, left.y),
                radius: face.bounds.width * 0.11,
                strength: abs(strength)
            ),
            makePoint(
                source: right,
                target: SIMD2<Float>(right.x + displacement * direction, right.y),
                radius: face.bounds.width * 0.11,
                strength: abs(strength)
            )
        ]
    }

    private func smilePoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let left = face.outerLips.min(by: { $0.x < $1.x }),
              let right = face.outerLips.max(by: { $0.x < $1.x }),
              left != right
        else {
            return []
        }

        let displacement = face.bounds.height * 0.035 * strength / BeautySafetyCaps.smile
        return [
            makePoint(
                source: left,
                target: SIMD2<Float>(left.x, left.y - displacement),
                radius: face.bounds.width * 0.12,
                strength: strength
            ),
            makePoint(
                source: right,
                target: SIMD2<Float>(right.x, right.y - displacement),
                radius: face.bounds.width * 0.12,
                strength: strength
            )
        ]
    }

    private func cardinalLipPoints(_ points: [SIMD2<Float>], center: SIMD2<Float>) -> [SIMD2<Float>] {
        var result: [SIMD2<Float>] = []
        if let left = points.min(by: { $0.x < $1.x }) {
            result.append(left)
        }
        if let right = points.max(by: { $0.x < $1.x }), !result.contains(right) {
            result.append(right)
        }
        if let top = points.min(by: { $0.y < $1.y }), !result.contains(top) {
            result.append(top)
        }
        if let bottom = points.max(by: { $0.y < $1.y }), !result.contains(bottom) {
            result.append(bottom)
        }
        if result.count < 4 {
            result.append(contentsOf: points.filter { !result.contains($0) }.prefix(4 - result.count))
        }
        return result
    }

    private func move(_ point: SIMD2<Float>, awayFrom center: SIMD2<Float>, by amount: Float) -> SIMD2<Float> {
        let vector = point - center
        let length = LandmarkGeometryHelper.distance(point, center)
        guard length > Float.ulpOfOne else {
            return point
        }
        return LandmarkGeometryHelper.clamp(point + vector / length * amount)
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
            radius: min(max(radius, 0.035), 0.20),
            strength: strength,
            falloff: 2
        )
    }
}
