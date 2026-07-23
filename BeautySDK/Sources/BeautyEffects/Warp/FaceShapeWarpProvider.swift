struct FaceShapeWarpFieldEmissions: Equatable, Sendable {
    let faceSlim: [WarpControlPoint]
    let faceSmall: [WarpControlPoint]
    let faceVShape: [WarpControlPoint]
    let jawSlim: [WarpControlPoint]
    let faceContourSmooth: [WarpControlPoint]
    let templeFullness: [WarpControlPoint]
    let cheekboneSlim: [WarpControlPoint]

    var points: [WarpControlPoint] {
        faceSlim + faceSmall + faceVShape + jawSlim +
            faceContourSmooth + templeFullness + cheekboneSlim
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.faceSlim != 0, faceSlim.isEmpty { sanitized.faceSlim = 0 }
        if strengths.faceSmall != 0, faceSmall.isEmpty { sanitized.faceSmall = 0 }
        if strengths.faceVShape != 0, faceVShape.isEmpty { sanitized.faceVShape = 0 }
        if strengths.jawSlim != 0, jawSlim.isEmpty { sanitized.jawSlim = 0 }
        if strengths.faceContourSmooth != 0, faceContourSmooth.isEmpty {
            sanitized.faceContourSmooth = 0
        }
        if strengths.templeFullness != 0, templeFullness.isEmpty {
            sanitized.templeFullness = 0
        }
        if strengths.cheekboneSlim != 0, cheekboneSlim.isEmpty {
            sanitized.cheekboneSlim = 0
        }
        return sanitized
    }
}

struct FaceShapeWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        let emissions = fieldEmissions(face: face, strengths: strengths)
        let observedOnlyPoints =
            emissions.faceContourSmooth + emissions.templeFullness + emissions.cheekboneSlim
        if face.faceContour.isEmpty, observedOnlyPoints.isEmpty {
            return .missingFaceContour
        }
        return WarpControlPointResult(points: emissions.points)
    }

    func fieldEmissions(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> FaceShapeWarpFieldEmissions {
        let hasLegacyContour = !face.faceContour.isEmpty
        return FaceShapeWarpFieldEmissions(
            faceSlim: hasLegacyContour && strengths.faceSlim > 0
                ? cheekPoints(face: face, strength: strengths.faceSlim)
                : [],
            faceSmall: hasLegacyContour && strengths.faceSmall > 0
                ? smallFacePoints(face: face, strength: strengths.faceSmall)
                : [],
            faceVShape: hasLegacyContour && strengths.faceVShape > 0
                ? lowerFacePoints(
                    face: face,
                    strength: strengths.faceVShape,
                    maxStrength: BeautySafetyCaps.faceVShape,
                    horizontalScale: 0.09,
                    verticalScale: 0.025
                )
                : [],
            jawSlim: hasLegacyContour && strengths.jawSlim > 0
                ? lowerFacePoints(
                    face: face,
                    strength: strengths.jawSlim,
                    maxStrength: BeautySafetyCaps.jawSlim,
                    horizontalScale: 0.07,
                    verticalScale: 0
                )
                : [],
            faceContourSmooth: strengths.faceContourSmooth > 0
                ? smoothContourPoints(face: face, strength: strengths.faceContourSmooth)
                : [],
            templeFullness: strengths.templeFullness > 0
                ? templeFullnessPoints(face: face, strength: strengths.templeFullness)
                : [],
            cheekboneSlim: strengths.cheekboneSlim > 0
                ? cheekboneSlimPoints(face: face, strength: strengths.cheekboneSlim)
                : []
        )
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

    private func smoothContourPoints(
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        guard strength.isFinite,
              strength > 0,
              face.bounds.width.isFinite,
              face.bounds.width > 0,
              let support = face.observedFaceSupport,
              support.contourEligible
        else {
            return []
        }

        let contour = support.contour
        guard contour.count >= 4,
              contour.allSatisfy(isFiniteUnitPoint),
              let minimumXIndex = contour.indices.min(by: { contour[$0].x < contour[$1].x }),
              let maximumXIndex = contour.indices.max(by: { contour[$0].x < contour[$1].x })
        else {
            return []
        }

        let eligibleIndices = contour.indices.filter { index in
            index > contour.startIndex &&
                index < contour.index(before: contour.endIndex) &&
                index != minimumXIndex &&
                index != maximumXIndex
        }
        guard eligibleIndices.count >= 2 else { return [] }

        let rawDeltas = eligibleIndices.map { index in
            (contour[index - 1].x + contour[index + 1].x) / 2 - contour[index].x
        }
        guard rawDeltas.allSatisfy(\.isFinite) else { return [] }

        let rawMean = rawDeltas.reduce(0, +) / Float(rawDeltas.count)
        guard rawMean.isFinite else { return [] }
        let centeredDeltas = rawDeltas.map { $0 - rawMean }
        guard centeredDeltas.allSatisfy(\.isFinite),
              let maximumAbsoluteCenteredDelta = centeredDeltas.map({ abs($0) }).max(),
              maximumAbsoluteCenteredDelta.isFinite,
              maximumAbsoluteCenteredDelta > Float.ulpOfOne
        else {
            return []
        }

        let ceiling =
            0.012 * face.bounds.width * strength / BeautySafetyCaps.faceContourSmooth
        guard ceiling.isFinite, ceiling > 0 else { return [] }
        let uniformScaleCeiling = min(1, ceiling / maximumAbsoluteCenteredDelta)
        guard uniformScaleCeiling.isFinite,
              uniformScaleCeiling > 0,
              uniformScaleCeiling <= 1,
              let uniformScale = representableUniformScale(
                  sources: eligibleIndices.map { contour[$0].x },
                  centeredDeltas: centeredDeltas,
                  ceiling: ceiling,
                  upperBound: uniformScaleCeiling
              )
        else {
            return []
        }

        let displacements = centeredDeltas.map { $0 * uniformScale }
        guard displacements.allSatisfy({ $0.isFinite && abs($0) <= ceiling }),
              displacements.contains(where: { abs($0) > Float.ulpOfOne })
        else {
            return []
        }

        var proposedContour = contour
        for (index, displacement) in zip(eligibleIndices, displacements) {
            let target = SIMD2<Float>(contour[index].x + displacement, contour[index].y)
            guard isFiniteUnitPoint(target) else { return [] }
            proposedContour[index] = target
        }

        let finalDisplacements = eligibleIndices.map { index in
            proposedContour[index].x - contour[index].x
        }
        let finalSum = finalDisplacements.reduce(0, +)
        let finalMean = finalSum / Float(finalDisplacements.count)
        guard finalDisplacements.allSatisfy({ $0.isFinite && abs($0) <= ceiling }),
              finalSum.isFinite,
              finalMean.isFinite,
              abs(finalSum) <= 0.000001,
              abs(finalMean) <= 0.000001
        else {
            return []
        }

        let baselineEligibleRoughness = lateralRoughness(
            contour,
            at: eligibleIndices
        )
        let proposedEligibleRoughness = lateralRoughness(
            proposedContour,
            at: eligibleIndices
        )
        let baselineRoughness = lateralRoughness(contour)
        let proposedRoughness = lateralRoughness(proposedContour)
        guard baselineEligibleRoughness.isFinite,
              proposedEligibleRoughness.isFinite,
              proposedEligibleRoughness < baselineEligibleRoughness,
              baselineRoughness.isFinite,
              proposedRoughness.isFinite,
              proposedRoughness < baselineRoughness
        else {
            return []
        }

        let radius = face.bounds.width * 0.08
        var points: [WarpControlPoint] = []
        for index in eligibleIndices {
            guard let point = validatedPoint(
                source: contour[index],
                target: proposedContour[index],
                radius: radius,
                strength: strength,
                falloff: 2
            ) else {
                return []
            }
            points.append(point)
        }
        return points
    }

    private func representableUniformScale(
        sources: [Float],
        centeredDeltas: [Float],
        ceiling: Float,
        upperBound: Float
    ) -> Float? {
        guard sources.count == centeredDeltas.count,
              !sources.isEmpty,
              ceiling.isFinite,
              ceiling > 0,
              upperBound.isFinite,
              upperBound > 0,
              upperBound <= 1
        else {
            return nil
        }

        var candidate = upperBound
        for _ in 0..<4096 {
            let finalDisplacements = zip(sources, centeredDeltas).map {
                ($0 + $1 * candidate) - $0
            }
            let ratios = zip(centeredDeltas, finalDisplacements).compactMap {
                abs($0) > Float.ulpOfOne ? $1 / $0 : nil
            }
            let sum = finalDisplacements.reduce(0, +)
            let mean = sum / Float(finalDisplacements.count)
            if let firstRatio = ratios.first,
               finalDisplacements.allSatisfy({
                   $0.isFinite && abs($0) <= ceiling
               }),
               ratios.allSatisfy({
                   $0.isFinite && abs($0 - firstRatio) <= 0.000001
               }),
               sum.isFinite,
               mean.isFinite,
               abs(sum) <= 0.000001,
               abs(mean) <= 0.000001 {
                return candidate
            }
            candidate = candidate.nextDown
            guard candidate.isFinite, candidate > 0 else { return nil }
        }
        return nil
    }

    private func templeFullnessPoints(
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        contourBandPoints(
            face: face,
            strength: strength,
            bands: [0.10..<0.30, 0.70..<0.90],
            displacementScale: 0.018,
            cap: BeautySafetyCaps.templeFullness,
            movesOutward: true
        )
    }

    private func cheekboneSlimPoints(
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        contourBandPoints(
            face: face,
            strength: strength,
            bands: [0.30..<0.46, 0.54..<0.70],
            displacementScale: 0.018,
            cap: BeautySafetyCaps.cheekboneSlim,
            movesOutward: false
        )
    }

    private func contourBandPoints(
        face: FaceGeometry,
        strength: Float,
        bands: [Range<Float>],
        displacementScale: Float,
        cap: Float,
        movesOutward: Bool
    ) -> [WarpControlPoint] {
        guard strength.isFinite,
              strength > 0,
              face.bounds.width.isFinite,
              face.bounds.width > 0,
              displacementScale.isFinite,
              displacementScale > 0,
              cap.isFinite,
              cap > 0,
              let support = face.observedFaceSupport,
              support.contourEligible
        else {
            return []
        }

        let contour = support.contour
        guard contour.count >= 2,
              contour.allSatisfy(isFiniteUnitPoint),
              let minimumX = contour.map(\.x).min(),
              let maximumX = contour.map(\.x).max()
        else {
            return []
        }
        let axisX = (minimumX + maximumX) / 2
        guard axisX.isFinite, (0...1).contains(axisX) else { return [] }

        let selected = contour.indices.filter { index in
            let progress = pathProgress(index: index, count: contour.count)
            return progress.isFinite && bands.contains { $0.contains(progress) }
        }
        guard !selected.isEmpty,
              selected.contains(where: { contour[$0].x < axisX }),
              selected.contains(where: { contour[$0].x > axisX })
        else {
            return []
        }

        let maximumDisplacement =
            displacementScale * face.bounds.width * strength / cap
        let radius = face.bounds.width * 0.14
        let falloff: Float = 2
        guard maximumDisplacement.isFinite,
              maximumDisplacement > 0,
              radius.isFinite,
              radius > 0,
              falloff.isFinite,
              falloff > 0
        else {
            return []
        }

        var points: [WarpControlPoint] = []
        for index in selected {
            let source = contour[index]
            let distanceToAxis = abs(source.x - axisX)
            guard distanceToAxis.isFinite, distanceToAxis > 0 else { return [] }

            let signedDisplacement: Float
            if movesOutward {
                signedDisplacement = source.x < axisX
                    ? -maximumDisplacement
                    : maximumDisplacement
            } else {
                let displacement = min(maximumDisplacement, distanceToAxis)
                guard displacement.isFinite, displacement > 0 else { return [] }
                signedDisplacement = source.x < axisX ? displacement : -displacement
            }

            let target = SIMD2<Float>(source.x + signedDisplacement, source.y)
            guard isFiniteUnitPoint(target),
                  movesOutward
                    ? abs(target.x - axisX) > distanceToAxis
                    : abs(target.x - axisX) < distanceToAxis,
                  let point = validatedPoint(
                      source: source,
                      target: target,
                      radius: radius,
                      strength: strength,
                      falloff: falloff
                  )
            else {
                return []
            }
            points.append(point)
        }
        return points
    }

    private func pathProgress(index: Int, count: Int) -> Float {
        guard count > 1, index >= 0, index < count else { return .nan }
        return Float(index) / Float(count - 1)
    }

    private func lateralRoughness(
        _ contour: [SIMD2<Float>],
        at indices: [Int]? = nil
    ) -> Float {
        guard contour.count >= 3 else { return 0 }
        let evaluated = indices ?? Array(1..<(contour.count - 1))
        return evaluated.reduce(0) { result, index in
            result + abs(
                contour[index].x -
                    (contour[index - 1].x + contour[index + 1].x) / 2
            )
        }
    }

    private func validatedPoint(
        source: SIMD2<Float>,
        target: SIMD2<Float>,
        radius: Float,
        strength: Float,
        falloff: Float
    ) -> WarpControlPoint? {
        guard isFiniteUnitPoint(source),
              isFiniteUnitPoint(target),
              radius.isFinite,
              radius > 0,
              strength.isFinite,
              strength > 0,
              falloff.isFinite,
              falloff > 0
        else {
            return nil
        }
        return WarpControlPoint(
            source: source,
            target: target,
            radius: min(max(radius, 0.04), 0.35),
            strength: strength,
            falloff: falloff
        )
    }

    private func isFiniteUnitPoint(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite &&
            point.y.isFinite &&
            (0...1).contains(point.x) &&
            (0...1).contains(point.y)
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
