struct EyeWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        guard let leftCenter = LandmarkGeometryHelper.center(of: face.leftEye),
              let rightCenter = LandmarkGeometryHelper.center(of: face.rightEye)
        else {
            return WarpControlPointResult(points: [], skipReason: "eye_landmarks_missing")
        }

        var points: [WarpControlPoint] = []

        if strengths.eyeSize > 0 {
            points.append(contentsOf: sizePoints(
                centers: [leftCenter, rightCenter],
                face: face,
                strength: strengths.eyeSize
            ))
        }

        if abs(strengths.eyeDistance) > Float.ulpOfOne {
            points.append(contentsOf: distancePoints(
                leftCenter: leftCenter,
                rightCenter: rightCenter,
                face: face,
                strength: strengths.eyeDistance
            ))
        }

        if abs(strengths.eyeYPosition) > Float.ulpOfOne {
            points.append(contentsOf: verticalPoints(
                centers: [leftCenter, rightCenter],
                face: face,
                strength: strengths.eyeYPosition
            ))
        }

        if strengths.eyeTailLift > 0 {
            points.append(contentsOf: tailLiftPoints(face: face, strength: strengths.eyeTailLift))
        }

        return WarpControlPointResult(points: points)
    }

    private func sizePoints(
        centers: [SIMD2<Float>],
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        let displacement = face.bounds.height * 0.025 * strength / BeautySafetyCaps.eyeSize
        return centers.flatMap { center in
            [
                makePoint(
                    source: SIMD2<Float>(center.x, center.y - displacement),
                    target: SIMD2<Float>(center.x, center.y - displacement * 1.8),
                    radius: face.bounds.width * 0.12,
                    strength: strength
                ),
                makePoint(
                    source: SIMD2<Float>(center.x, center.y + displacement),
                    target: SIMD2<Float>(center.x, center.y + displacement * 1.8),
                    radius: face.bounds.width * 0.12,
                    strength: strength
                )
            ]
        }
    }

    private func distancePoints(
        leftCenter: SIMD2<Float>,
        rightCenter: SIMD2<Float>,
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        let displacement = face.bounds.width * 0.045 * abs(strength) / BeautySafetyCaps.eyeDistance
        let direction: Float = strength < 0 ? -1 : 1
        return [
            makePoint(
                source: leftCenter,
                target: SIMD2<Float>(leftCenter.x - displacement * direction, leftCenter.y),
                radius: face.bounds.width * 0.14,
                strength: abs(strength)
            ),
            makePoint(
                source: rightCenter,
                target: SIMD2<Float>(rightCenter.x + displacement * direction, rightCenter.y),
                radius: face.bounds.width * 0.14,
                strength: abs(strength)
            )
        ]
    }

    private func verticalPoints(
        centers: [SIMD2<Float>],
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        let displacement = face.bounds.height * 0.035 * abs(strength) / BeautySafetyCaps.eyeYPosition
        let direction: Float = strength < 0 ? -1 : 1
        return centers.map { center in
            makePoint(
                source: center,
                target: SIMD2<Float>(center.x, center.y + displacement * direction),
                radius: face.bounds.width * 0.14,
                strength: abs(strength)
            )
        }
    }

    private func tailLiftPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let leftTail = face.leftEye.min(by: { $0.x < $1.x }),
              let rightTail = face.rightEye.max(by: { $0.x < $1.x })
        else {
            return []
        }

        let displacement = face.bounds.height * 0.035 * strength / BeautySafetyCaps.eyeTailLift
        return [
            makePoint(
                source: leftTail,
                target: SIMD2<Float>(leftTail.x, leftTail.y - displacement),
                radius: face.bounds.width * 0.10,
                strength: strength
            ),
            makePoint(
                source: rightTail,
                target: SIMD2<Float>(rightTail.x, rightTail.y - displacement),
                radius: face.bounds.width * 0.10,
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
            radius: min(max(radius, 0.035), 0.24),
            strength: strength,
            falloff: 2
        )
    }
}
