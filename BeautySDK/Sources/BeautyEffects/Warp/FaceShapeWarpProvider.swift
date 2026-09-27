import Foundation

struct FaceShapeWarpFieldEmissions: Equatable, Sendable {
    let faceSlim: [WarpControlPoint]
    let faceSmall: [WarpControlPoint]
    let wholeFaceYPosition: [WarpControlPoint]
    let wholeFaceXPosition: [WarpControlPoint]
    let wholeFaceTilt: [WarpControlPoint]
    let faceShortening: [WarpControlPoint]
    let foreheadHeight: [WarpControlPoint]
    let midfaceLength: [WarpControlPoint]
    let philtrumLength: [WarpControlPoint]
    let lowerFaceLength: [WarpControlPoint]
    let headSmall: [WarpControlPoint]
    let headWrap: [WarpControlPoint]
    let cranialCrownHeight: [WarpControlPoint]
    let hairlineHeight: [WarpControlPoint]
    let wholeFaceSymmetry: [WarpControlPoint]
    let doubleChinReduction: [WarpControlPoint]
    let doubleChinReductionPro: [WarpControlPoint]
    let faceVShape: [WarpControlPoint]
    let jawSlim: [WarpControlPoint]
    let faceContourSmooth: [WarpControlPoint]
    let templeFullness: [WarpControlPoint]
    let cheekboneSlim: [WarpControlPoint]

    var points: [WarpControlPoint] {
        faceSlim + faceSmall + wholeFaceYPosition + wholeFaceXPosition + wholeFaceTilt + faceShortening + foreheadHeight + midfaceLength + philtrumLength + lowerFaceLength + headSmall + headWrap + cranialCrownHeight + hairlineHeight + wholeFaceSymmetry + doubleChinReduction + doubleChinReductionPro + faceVShape + jawSlim +
            faceContourSmooth + templeFullness + cheekboneSlim
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.faceSlim != 0, faceSlim.isEmpty { sanitized.faceSlim = 0 }
        if strengths.faceSmall != 0, faceSmall.isEmpty { sanitized.faceSmall = 0 }
        if strengths.wholeFaceYPosition != 0, wholeFaceYPosition.isEmpty {
            sanitized.wholeFaceYPosition = 0
        }
        if strengths.wholeFaceXPosition != 0, wholeFaceXPosition.isEmpty {
            sanitized.wholeFaceXPosition = 0
        }
        if strengths.wholeFaceTilt != 0, wholeFaceTilt.isEmpty {
            sanitized.wholeFaceTilt = 0
        }
        if strengths.faceShortening != 0, faceShortening.isEmpty {
            sanitized.faceShortening = 0
        }
        if strengths.foreheadHeight != 0, foreheadHeight.isEmpty {
            sanitized.foreheadHeight = 0
        }
        if strengths.midfaceLength != 0, midfaceLength.isEmpty {
            sanitized.midfaceLength = 0
        }
        if strengths.philtrumLength != 0, philtrumLength.isEmpty {
            sanitized.philtrumLength = 0
        }
        if strengths.lowerFaceLength != 0, lowerFaceLength.isEmpty {
            sanitized.lowerFaceLength = 0
        }
        if strengths.headSmall != 0, headSmall.isEmpty { sanitized.headSmall = 0 }
        if strengths.headWrap != 0, headWrap.isEmpty { sanitized.headWrap = 0 }
        if strengths.cranialCrownHeight != 0, cranialCrownHeight.isEmpty {
            sanitized.cranialCrownHeight = 0
        }
        if strengths.hairlineHeight != 0, hairlineHeight.isEmpty {
            sanitized.hairlineHeight = 0
        }
        if strengths.wholeFaceSymmetry != 0, wholeFaceSymmetry.isEmpty {
            sanitized.wholeFaceSymmetry = 0
        }
        if strengths.doubleChinReduction != 0, doubleChinReduction.isEmpty {
            sanitized.doubleChinReduction = 0
        }
        if strengths.doubleChinReductionPro != 0, doubleChinReductionPro.isEmpty {
            sanitized.doubleChinReductionPro = 0
        }
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
            wholeFaceYPosition: hasLegacyContour
                ? wholeFaceYPositionPoints(face: face, strength: strengths.wholeFaceYPosition)
                : [],
            wholeFaceXPosition: hasLegacyContour
                ? wholeFaceXPositionPoints(face: face, strength: strengths.wholeFaceXPosition)
                : [],
            wholeFaceTilt: hasLegacyContour
                ? wholeFaceTiltPoints(face: face, strength: strengths.wholeFaceTilt)
                : [],
            faceShortening: hasLegacyContour
                ? faceShorteningPoints(face: face, strength: strengths.faceShortening)
                : [],
            foreheadHeight: hasLegacyContour
                ? verticalRegionPoint(face: face, strength: strengths.foreheadHeight,
                                      cap: BeautySafetyCaps.foreheadHeight,
                                      yFraction: 0.17, movementFraction: -0.06,
                                      radiusFraction: 0.16)
                : [],
            midfaceLength: hasLegacyContour
                ? verticalRegionPoint(face: face, strength: strengths.midfaceLength,
                                      cap: BeautySafetyCaps.midfaceLength,
                                      yFraction: 0.52, movementFraction: 0.055,
                                      radiusFraction: 0.14)
                : [],
            philtrumLength: hasLegacyContour
                ? philtrumPoint(face: face, strength: strengths.philtrumLength)
                : [],
            lowerFaceLength: hasLegacyContour
                ? lowerFaceLengthPoint(face: face, strength: strengths.lowerFaceLength)
                : [],
            headSmall: hasLegacyContour
                ? headSmallPoints(face: face, strength: strengths.headSmall)
                : [],
            headWrap: hasLegacyContour
                ? headWrapPoints(face: face, strength: strengths.headWrap)
                : [],
            cranialCrownHeight: hasLegacyContour
                ? crownPoints(face: face, strength: strengths.cranialCrownHeight)
                : [],
            hairlineHeight: hasLegacyContour
                ? hairlinePoints(face: face, strength: strengths.hairlineHeight)
                : [],
            wholeFaceSymmetry: hasLegacyContour
                ? symmetryPoints(face: face, strength: strengths.wholeFaceSymmetry)
                : [],
            doubleChinReduction: hasLegacyContour
                ? doubleChinPoints(face: face, strength: strengths.doubleChinReduction,
                                   pro: false)
                : [],
            doubleChinReductionPro: hasLegacyContour
                ? doubleChinPoints(face: face, strength: strengths.doubleChinReductionPro,
                                   pro: true)
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

    private func wholeFaceYPositionPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard strength.isFinite,
              abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.wholeFaceYPosition,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return [] }
        let source = face.bounds.center
        let movement = face.bounds.height * 0.035 * strength /
            BeautySafetyCaps.wholeFaceYPosition
        let target = SIMD2<Float>(source.x, source.y + movement)
        let radius = min(1, max(face.bounds.width, face.bounds.height) * 0.60)
        guard source.x.isFinite, source.y.isFinite,
              (0...1).contains(source.x), (0...1).contains(source.y),
              (0...1).contains(target.y),
              radius.isFinite, radius >= 0.001
        else { return [] }
        return [WarpControlPoint(
            source: source, target: target, radius: radius,
            strength: abs(strength), falloff: 2
        )]
    }

    private func wholeFaceXPositionPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard strength.isFinite,
              abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.wholeFaceXPosition,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return [] }
        let source = face.bounds.center
        let movement = face.bounds.width * 0.035 * strength /
            BeautySafetyCaps.wholeFaceXPosition
        let target = SIMD2<Float>(source.x + movement, source.y)
        let radius = min(1, max(face.bounds.width, face.bounds.height) * 0.60)
        guard source.x.isFinite, source.y.isFinite,
              (0...1).contains(source.x), (0...1).contains(source.y),
              (0...1).contains(target.x),
              radius.isFinite, radius >= 0.001
        else { return [] }
        return [WarpControlPoint(
            source: source, target: target, radius: radius,
            strength: abs(strength), falloff: 2
        )]
    }

    private func wholeFaceTiltPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard strength.isFinite,
              abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.wholeFaceTilt,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return [] }
        let center = face.bounds.center
        let dx = face.bounds.width * 0.27
        let dy = face.bounds.height * 0.27
        let angle = Double(strength / BeautySafetyCaps.wholeFaceTilt) * 0.12
        let cosine = Float(cos(angle))
        let sine = Float(sin(angle))
        let radius = min(1, max(face.bounds.width, face.bounds.height) * 0.38)
        guard center.x.isFinite, center.y.isFinite,
              (0...1).contains(center.x), (0...1).contains(center.y),
              radius.isFinite, radius >= 0.001
        else { return [] }
        let offsets = [
            SIMD2<Float>(0, -dy), SIMD2<Float>(dx, 0),
            SIMD2<Float>(0, dy), SIMD2<Float>(-dx, 0),
        ]
        var points: [WarpControlPoint] = []
        for offset in offsets {
            let source = center + offset
            let rotated = SIMD2<Float>(
                cosine * offset.x - sine * offset.y,
                sine * offset.x + cosine * offset.y
            )
            let target = center + rotated
            guard source.x.isFinite, source.y.isFinite,
                  target.x.isFinite, target.y.isFinite,
                  (0...1).contains(source.x), (0...1).contains(source.y),
                  (0...1).contains(target.x), (0...1).contains(target.y)
            else { return [] }
            points.append(WarpControlPoint(
                source: source, target: target, radius: radius,
                strength: abs(strength), falloff: 2
            ))
        }
        return points
    }

    private func faceShorteningPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard strength.isFinite, strength > Float.ulpOfOne,
              strength <= BeautySafetyCaps.faceShortening,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.bounds.height / face.bounds.width >= 1.25,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return [] }
        let bounds = face.bounds
        let upper = SIMD2<Float>(bounds.midX, bounds.minY + bounds.height * 0.24)
        let lower = SIMD2<Float>(bounds.midX, bounds.maxY - bounds.height * 0.12)
        let distance = bounds.height * 0.08 * strength / BeautySafetyCaps.faceShortening
        let radius = min(1, max(bounds.width, bounds.height) * 0.16)
        guard radius.isFinite, radius >= 0.001,
              (0...1).contains(upper.x), (0...1).contains(upper.y),
              (0...1).contains(lower.x), (0...1).contains(lower.y),
              (0...1).contains(upper.y + distance),
              (0...1).contains(lower.y - distance)
        else { return [] }
        return [
            WarpControlPoint(
                source: upper, target: SIMD2<Float>(upper.x, upper.y + distance),
                radius: radius, strength: strength, falloff: 2
            ),
            WarpControlPoint(
                source: lower, target: SIMD2<Float>(lower.x, lower.y - distance),
                radius: radius, strength: strength, falloff: 2
            ),
        ]
    }

    private func verticalRegionPoint(
        face: FaceGeometry, strength: Float, cap: Float,
        yFraction: Float, movementFraction: Float, radiusFraction: Float
    ) -> [WarpControlPoint] {
        guard strength.isFinite, abs(strength) > Float.ulpOfOne,
              abs(strength) <= cap,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return [] }
        let bounds = face.bounds
        let source = SIMD2<Float>(bounds.midX, bounds.minY + bounds.height * yFraction)
        let target = SIMD2<Float>(
            source.x, source.y + bounds.height * movementFraction * strength / cap
        )
        let radius = min(1, max(bounds.width, bounds.height) * radiusFraction)
        guard (0...1).contains(source.x), (0...1).contains(source.y),
              (0...1).contains(target.y), radius.isFinite, radius >= 0.001
        else { return [] }
        return [WarpControlPoint(
            source: source, target: target, radius: radius,
            strength: abs(strength), falloff: 2
        )]
    }

    private func philtrumPoint(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        let nose = face.noseTip.isEmpty ? face.nose : face.noseTip
        let lips = face.upperLips.isEmpty ? face.outerLips : face.upperLips
        guard let noseCenter = LandmarkGeometryHelper.center(of: nose),
              let lipCenter = LandmarkGeometryHelper.center(of: lips)
        else { return [] }
        return verticalGapPoint(
            face: face, upper: noseCenter, lower: lipCenter,
            strength: strength, cap: BeautySafetyCaps.philtrumLength,
            displacementScale: 0.65
        )
    }

    private func lowerFaceLengthPoint(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let lipCenter = LandmarkGeometryHelper.center(of: face.outerLips),
              let chin = face.faceContour.max(by: { $0.y < $1.y })
        else { return [] }
        return verticalGapPoint(
            face: face, upper: lipCenter, lower: chin,
            strength: strength, cap: BeautySafetyCaps.lowerFaceLength,
            displacementScale: 0.16
        )
    }

    private func verticalGapPoint(
        face: FaceGeometry, upper: SIMD2<Float>, lower: SIMD2<Float>,
        strength: Float, cap: Float, displacementScale: Float
    ) -> [WarpControlPoint] {
        let gap = lower.y - upper.y
        guard strength.isFinite, abs(strength) > Float.ulpOfOne,
              abs(strength) <= cap,
              gap.isFinite, gap > face.bounds.height * 0.035,
              [upper, lower].allSatisfy({
                  $0.x.isFinite && $0.y.isFinite &&
                      (0...1).contains($0.x) && (0...1).contains($0.y)
              })
        else { return [] }
        let source = SIMD2<Float>((upper.x + lower.x) * 0.5, (upper.y + lower.y) * 0.5)
        let target = SIMD2<Float>(
            source.x, source.y + gap * displacementScale * strength / cap
        )
        let radius = min(face.bounds.width * 0.15, gap * 1.5)
        guard (0...1).contains(source.x), (0...1).contains(source.y),
              (0...1).contains(target.y), radius.isFinite, radius >= 0.001
        else { return [] }
        return [WarpControlPoint(
            source: source, target: target, radius: radius,
            strength: abs(strength), falloff: 2
        )]
    }

    private func headSmallPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard validHeadBounds(face), strength.isFinite,
              strength > Float.ulpOfOne, strength <= BeautySafetyCaps.headSmall
        else { return [] }
        let bounds = face.bounds
        let horizontal = bounds.width * 0.055 * strength / BeautySafetyCaps.headSmall
        let vertical = bounds.height * 0.035 * strength / BeautySafetyCaps.headSmall
        let y = bounds.minY + bounds.height * 0.28
        let left = SIMD2<Float>(bounds.minX + bounds.width * 0.13, y)
        let right = SIMD2<Float>(bounds.maxX - bounds.width * 0.13, y)
        let top = SIMD2<Float>(bounds.midX, bounds.minY + bounds.height * 0.07)
        let chin = SIMD2<Float>(bounds.midX, bounds.maxY - bounds.height * 0.10)
        let radius = min(1, max(bounds.width, bounds.height) * 0.15)
        return boundedPoints([
            (left, SIMD2<Float>(left.x + horizontal, left.y)),
            (right, SIMD2<Float>(right.x - horizontal, right.y)),
            (top, SIMD2<Float>(top.x, top.y + vertical)),
            (chin, SIMD2<Float>(chin.x, chin.y - vertical)),
        ], radius: radius, strength: strength)
    }

    private func headWrapPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard validHeadBounds(face), strength.isFinite,
              strength > Float.ulpOfOne, strength <= BeautySafetyCaps.headWrap
        else { return [] }
        let bounds = face.bounds
        let y = bounds.minY + bounds.height * 0.15
        let left = SIMD2<Float>(bounds.minX + bounds.width * 0.08, y)
        let right = SIMD2<Float>(bounds.maxX - bounds.width * 0.08, y)
        let distance = bounds.width * 0.045 * strength / BeautySafetyCaps.headWrap
        return boundedPoints([
            (left, SIMD2<Float>(left.x - distance, left.y)),
            (right, SIMD2<Float>(right.x + distance, right.y)),
        ], radius: min(1, max(bounds.width, bounds.height) * 0.13), strength: strength)
    }

    private func crownPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard validHeadBounds(face), strength.isFinite,
              abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.cranialCrownHeight
        else { return [] }
        let bounds = face.bounds
        let source = SIMD2<Float>(bounds.midX, bounds.minY - bounds.height * 0.08)
        let target = SIMD2<Float>(
            source.x,
            source.y - bounds.height * 0.035 * strength / BeautySafetyCaps.cranialCrownHeight
        )
        return boundedPoints(
            [(source, target)], radius: min(1, max(bounds.width, bounds.height) * 0.11),
            strength: abs(strength)
        )
    }

    private func hairlinePoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard validHeadBounds(face), strength.isFinite,
              abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.hairlineHeight
        else { return [] }
        let bounds = face.bounds
        let y = bounds.minY + bounds.height * 0.08
        let distance = bounds.height * 0.045 * strength / BeautySafetyCaps.hairlineHeight
        let left = SIMD2<Float>(bounds.minX + bounds.width * 0.30, y)
        let right = SIMD2<Float>(bounds.maxX - bounds.width * 0.30, y)
        return boundedPoints([
            (left, SIMD2<Float>(left.x, left.y + distance)),
            (right, SIMD2<Float>(right.x, right.y + distance)),
        ], radius: min(1, max(bounds.width, bounds.height) * 0.09), strength: abs(strength))
    }

    private func symmetryPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard validHeadBounds(face), strength.isFinite,
              strength > Float.ulpOfOne,
              strength <= BeautySafetyCaps.wholeFaceSymmetry,
              let support = face.observedFaceSupport,
              let median = support.medianLine,
              !median.isEmpty, median.allSatisfy({ unitPoint($0) }),
              support.contour.count >= 6,
              support.contour.allSatisfy({ unitPoint($0) })
        else { return [] }
        let bounds = face.bounds
        let targetY = bounds.minY + bounds.height * 0.58
        guard let axis = median.min(by: {
            abs($0.y - targetY) < abs($1.y - targetY)
        })?.x else { return [] }
        let band = support.contour.filter {
            $0.y >= bounds.minY + bounds.height * 0.42 &&
                $0.y <= bounds.minY + bounds.height * 0.78
        }
        guard let left = band.filter({ $0.x < axis }).min(by: {
            abs($0.y - targetY) < abs($1.y - targetY)
        }), let right = band.filter({ $0.x > axis }).min(by: {
            abs($0.y - targetY) < abs($1.y - targetY)
        }), abs(left.y - right.y) <= bounds.height * 0.22
        else { return [] }
        let leftWidth = axis - left.x
        let rightWidth = right.x - axis
        let imbalance = leftWidth - rightWidth
        guard imbalance.isFinite,
              abs(imbalance) >= bounds.width * 0.006
        else { return [] }
        let adjustment = min(max(imbalance * 0.5, -bounds.width * 0.04),
                             bounds.width * 0.04) * strength / BeautySafetyCaps.wholeFaceSymmetry
        return boundedPoints([
            (left, SIMD2<Float>(left.x + adjustment, left.y)),
            (right, SIMD2<Float>(right.x + adjustment, right.y)),
        ], radius: min(1, max(bounds.width, bounds.height) * 0.12), strength: strength)
    }

    private func doubleChinPoints(
        face: FaceGeometry, strength: Float, pro: Bool
    ) -> [WarpControlPoint] {
        let cap = pro ? BeautySafetyCaps.doubleChinReductionPro :
            BeautySafetyCaps.doubleChinReduction
        guard validHeadBounds(face), strength.isFinite,
              strength > Float.ulpOfOne, strength <= cap,
              let chin = face.faceContour.max(by: { $0.y < $1.y }),
              chin.y > face.bounds.minY + face.bounds.height * 0.65
        else { return [] }
        let bounds = face.bounds
        let factor = strength / cap
        let centerLift = bounds.height * (pro ? 0.065 : 0.045) * factor
        let radius = min(1, max(bounds.width, bounds.height) * 0.14)
        let center = (chin, SIMD2<Float>(chin.x, chin.y - centerLift))
        guard pro else { return boundedPoints([center], radius: radius, strength: strength) }
        let lower = face.faceContour.filter {
            $0.y >= bounds.minY + bounds.height * 0.70 && $0.y < chin.y
        }
        guard let left = lower.filter({ $0.x < chin.x }).min(by: { $0.x < $1.x }),
              let right = lower.filter({ $0.x > chin.x }).max(by: { $0.x < $1.x })
        else { return [] }
        let inset = bounds.width * 0.04 * factor
        let flankLift = bounds.height * 0.025 * factor
        return boundedPoints([
            center,
            (left, SIMD2<Float>(left.x + inset, left.y - flankLift)),
            (right, SIMD2<Float>(right.x - inset, right.y - flankLift)),
        ], radius: radius, strength: strength)
    }

    private func validHeadBounds(_ face: FaceGeometry) -> Bool {
        face.bounds.width.isFinite && face.bounds.height.isFinite &&
            face.bounds.width > 0 && face.bounds.height > 0 &&
            face.faceContour.allSatisfy { unitPoint($0) }
    }

    private func boundedPoints(
        _ pairs: [(SIMD2<Float>, SIMD2<Float>)], radius: Float, strength: Float
    ) -> [WarpControlPoint] {
        guard radius.isFinite, radius >= 0.001, strength.isFinite, strength > 0,
              pairs.allSatisfy({ unitPoint($0.0) && unitPoint($0.1) })
        else { return [] }
        return pairs.map {
            WarpControlPoint(source: $0.0, target: $0.1,
                             radius: radius, strength: strength, falloff: 2)
        }
    }

    private func unitPoint(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite &&
            (0...1).contains(point.x) && (0...1).contains(point.y)
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
              let lateralRuns = FaceContourLateralRuns.make(
                  from: contour,
                  centralExclusionFraction: contour.count <= 12 ? 1 / 12 : 1 / 6
              ),
              let minimumXIndex = contour.indices.min(by: { contour[$0].x < contour[$1].x }),
              let maximumXIndex = contour.indices.max(by: { contour[$0].x < contour[$1].x })
        else {
            return []
        }

        let eligibleIndices = lateralRuns.flatMap { run in
            let membership = Set(run.indices)
            return run.indices.filter { index in
                index > contour.startIndex &&
                    index < contour.index(before: contour.endIndex) &&
                    membership.contains(index - 1) &&
                    membership.contains(index + 1) &&
                    index != minimumXIndex &&
                    index != maximumXIndex
            }
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
            0.004 * face.bounds.width * strength / BeautySafetyCaps.faceContourSmooth
        guard ceiling.isFinite, ceiling > 0 else { return [] }
        let normalizedStrength = min(
            1,
            strength / BeautySafetyCaps.faceContourSmooth
        )
        let uniformScaleCeiling = min(
            1,
            normalizedStrength,
            ceiling / maximumAbsoluteCenteredDelta
        )
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
              proposedRoughness <= baselineRoughness + 0.000_001
        else {
            return []
        }

        let radius = face.bounds.width * 0.014
        var points: [WarpControlPoint] = []
        for index in eligibleIndices {
            guard let point = validatedPoint(
                source: contour[index],
                target: proposedContour[index],
                radius: radius,
                strength: strength,
                falloff: 2,
                minimumRadius: 0.001
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
        // Float addition can round a displacement a few ULPs above its
        // mathematical ceiling. Step the shared scale down until every stored
        // target is bounded and the quantized field remains centered.
        for _ in 0..<16_384 {
            let finalDisplacements = zip(sources, centeredDeltas).map {
                ($0 + $1 * candidate) - $0
            }
            let sum = finalDisplacements.reduce(0, +)
            let mean = sum / Float(finalDisplacements.count)
            if finalDisplacements.allSatisfy({
                    $0.isFinite && abs($0) <= ceiling
                }),
                finalDisplacements.contains(where: { abs($0) > Float.ulpOfOne }),
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
        falloff: Float,
        minimumRadius: Float = 0.04
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
            radius: min(max(radius, minimumRadius), 0.35),
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
