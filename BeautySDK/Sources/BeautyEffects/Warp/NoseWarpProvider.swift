struct NoseWarpFieldEmissions: Equatable, Sendable {
    let noseSlim: [WarpControlPoint]
    let noseWingSlim: [WarpControlPoint]
    let noseTipSize: [WarpControlPoint]
    let noseBridge: [WarpControlPoint]
    let noseRootNarrowing: [WarpControlPoint]
    let noseTipLift: [WarpControlPoint]

    var points: [WarpControlPoint] {
        noseSlim +
            noseWingSlim +
            noseTipSize +
            noseBridge +
            noseRootNarrowing +
            noseTipLift
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.noseSlim != 0, noseSlim.isEmpty {
            sanitized.noseSlim = 0
        }
        if strengths.noseWingSlim != 0, noseWingSlim.isEmpty {
            sanitized.noseWingSlim = 0
        }
        if strengths.noseTipSize != 0, noseTipSize.isEmpty {
            sanitized.noseTipSize = 0
        }
        if strengths.noseBridge != 0, noseBridge.isEmpty {
            sanitized.noseBridge = 0
        }
        if strengths.noseRootNarrowing != 0, noseRootNarrowing.isEmpty {
            sanitized.noseRootNarrowing = 0
        }
        if strengths.noseTipLift != 0, noseTipLift.isEmpty {
            sanitized.noseTipLift = 0
        }
        return sanitized
    }
}

struct NoseWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        let emissions = fieldEmissions(face: face, strengths: strengths)
        let requestedWork = strengths.noseSlim > 0 ||
            strengths.noseWingSlim > 0 ||
            abs(strengths.noseTipSize) > Float.ulpOfOne ||
            strengths.noseBridge > 0 ||
            strengths.noseRootNarrowing > 0 ||
            strengths.noseTipLift > 0

        return WarpControlPointResult(
            points: emissions.points,
            skipReason: requestedWork && emissions.points.isEmpty ? "nose_inputs_missing" : nil
        )
    }

    func fieldEmissions(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> NoseWarpFieldEmissions {
        let center = LandmarkGeometryHelper.center(of: face.nose)
        return NoseWarpFieldEmissions(
            noseSlim: strengths.noseSlim > 0
                ? center.map { slimPoints(face: face, center: $0, strength: strengths.noseSlim) } ?? []
                : [],
            noseWingSlim: strengths.noseWingSlim > 0
                ? center.map { wingPoints(face: face, center: $0, strength: strengths.noseWingSlim) } ?? []
                : [],
            noseTipSize: abs(strengths.noseTipSize) > Float.ulpOfOne
                ? center.map { tipPoints(face: face, center: $0, strength: strengths.noseTipSize) } ?? []
                : [],
            noseBridge: strengths.noseBridge > 0
                ? center.map { bridgePoints(face: face, center: $0, strength: strengths.noseBridge) } ?? []
                : [],
            noseRootNarrowing: strengths.noseRootNarrowing > 0
                ? rootNarrowingPoints(face: face, strength: strengths.noseRootNarrowing)
                : [],
            noseTipLift: strengths.noseTipLift > 0
                ? tipLiftPoints(face: face, strength: strengths.noseTipLift)
                : []
        )
    }

    func validatedRootPair(in face: FaceGeometry) -> (left: SIMD2<Float>, right: SIMD2<Float>)? {
        guard face.noseRoot.count == 2,
              face.bounds.width.isFinite,
              face.bounds.width > 0
        else {
            return nil
        }

        let pair = face.noseRoot.sorted { lhs, rhs in
            lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
        }
        let left = pair[0]
        let right = pair[1]
        let centerX = face.bounds.midX
        let leftDistance = centerX - left.x
        let rightDistance = right.x - centerX

        guard isValidSupportPoint(left, in: face.bounds),
              isValidSupportPoint(right, in: face.bounds),
              left != right,
              abs(left.y - right.y) <= 0.0001,
              left.x < centerX,
              right.x > centerX,
              abs(leftDistance - rightDistance) <= 0.0001,
              leftDistance > 0.0001,
              rightDistance > 0.0001
        else {
            return nil
        }

        return (left, right)
    }

    func validatedTipSupport(in face: FaceGeometry) -> [SIMD2<Float>]? {
        guard face.noseTip.count >= 2,
              face.bounds.height.isFinite,
              face.bounds.height > 0,
              face.noseTip.allSatisfy({ point in
                  isValidSupportPoint(point, in: face.bounds) && point.y >= face.bounds.midY
              }),
              hasOnlyDistinctPoints(face.noseTip)
        else {
            return nil
        }

        return face.noseTip.sorted { lhs, rhs in
            lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
        }
    }

    func rootNarrowingPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard strength.isFinite,
              strength > Float.ulpOfOne,
              let pair = validatedRootPair(in: face)
        else {
            return []
        }

        let requestedDisplacement = face.bounds.width * 0.025 * strength / BeautySafetyCaps.noseRootNarrowing
        let room = min(face.bounds.midX - pair.left.x, pair.right.x - face.bounds.midX)
        let displacement = min(requestedDisplacement, room - 0.0001)
        guard displacement.isFinite, displacement > Float.ulpOfOne else {
            return []
        }

        let leftTarget = SIMD2<Float>(pair.left.x + displacement, pair.left.y)
        let rightTarget = SIMD2<Float>(pair.right.x - displacement, pair.right.y)
        guard isValidNormalizedPoint(leftTarget),
              isValidNormalizedPoint(rightTarget),
              leftTarget.x < face.bounds.midX,
              rightTarget.x > face.bounds.midX
        else {
            return []
        }

        return [
            makePoint(
                source: pair.left,
                target: leftTarget,
                radius: face.bounds.width * 0.07,
                strength: strength
            ),
            makePoint(
                source: pair.right,
                target: rightTarget,
                radius: face.bounds.width * 0.07,
                strength: strength
            )
        ]
    }

    func tipLiftPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard strength.isFinite,
              strength > Float.ulpOfOne,
              let support = validatedTipSupport(in: face)
        else {
            return []
        }

        let displacement = face.bounds.height * 0.020 * strength / BeautySafetyCaps.noseTipLift
        guard displacement.isFinite, displacement > Float.ulpOfOne else {
            return []
        }

        let targets = support.map { SIMD2<Float>($0.x, $0.y - displacement) }
        guard zip(support, targets).allSatisfy({ source, target in
            isValidNormalizedPoint(target) && target.x == source.x && target.y < source.y
        }) else {
            return []
        }

        return zip(support, targets).map { source, target in
            makePoint(
                source: source,
                target: target,
                radius: face.bounds.width * 0.08,
                strength: strength
            )
        }
    }

    private func isValidSupportPoint(_ point: SIMD2<Float>, in bounds: FaceBounds) -> Bool {
        isValidNormalizedPoint(point) &&
            point.x >= bounds.minX && point.x <= bounds.maxX &&
            point.y >= bounds.minY && point.y <= bounds.maxY
    }

    private func isValidNormalizedPoint(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite &&
            (0...1).contains(point.x) && (0...1).contains(point.y)
    }

    private func hasOnlyDistinctPoints(_ points: [SIMD2<Float>]) -> Bool {
        for index in points.indices {
            for otherIndex in points.indices where otherIndex > index && points[index] == points[otherIndex] {
                return false
            }
        }
        return true
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
            let displacement = face.bounds.height * 0.025 * strength / BeautySafetyCaps.noseTipSize
            return makePoint(
                source: source,
                target: LandmarkGeometryHelper.move(source, toward: center, by: displacement),
                radius: face.bounds.width * 0.09,
                strength: abs(strength)
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
