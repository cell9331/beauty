struct ChinWarpFieldEmissions: Equatable, Sendable {
    let chinLength: [WarpControlPoint]
    let chinTaper: [WarpControlPoint]

    var points: [WarpControlPoint] {
        chinLength + chinTaper
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.chinLength != 0, chinLength.isEmpty { sanitized.chinLength = 0 }
        if strengths.chinTaper != 0, chinTaper.isEmpty { sanitized.chinTaper = 0 }
        return sanitized
    }
}

struct ChinWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        let emissions = fieldEmissions(face: face, strengths: strengths)
        if face.faceContour.isEmpty, emissions.chinTaper.isEmpty {
            return .missingFaceContour
        }
        return WarpControlPointResult(points: emissions.points)
    }

    func fieldEmissions(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> ChinWarpFieldEmissions {
        ChinWarpFieldEmissions(
            chinLength: !face.faceContour.isEmpty &&
                abs(strengths.chinLength) > Float.ulpOfOne
                ? chinLengthPoints(face: face, strength: strengths.chinLength)
                : [],
            chinTaper: strengths.chinTaper > 0
                ? chinTaperPoints(face: face, strength: strengths.chinTaper)
                : []
        )
    }

    private func chinLengthPoints(
        face: FaceGeometry,
        strength requestedStrength: Float
    ) -> [WarpControlPoint] {
        guard abs(requestedStrength) > Float.ulpOfOne,
              let chin = face.faceContour.max(by: { $0.y < $1.y })
        else {
            return []
        }

        let direction: Float = requestedStrength < 0 ? -1 : 1
        let strength = min(abs(requestedStrength), BeautySafetyCaps.chinLength)
        let displacement =
            face.bounds.height * 0.08 * strength / BeautySafetyCaps.chinLength
        let target = SIMD2<Float>(chin.x, chin.y + direction * displacement)

        return [
            WarpControlPoint(
                source: LandmarkGeometryHelper.clamp(chin),
                target: LandmarkGeometryHelper.clamp(target),
                radius: min(max(face.bounds.width * 0.22, 0.04), 0.30),
                strength: strength,
                falloff: 2
            )
        ]
    }

    private func chinTaperPoints(
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        guard strength.isFinite,
              strength > 0,
              face.bounds.width.isFinite,
              face.bounds.width > 0,
              let support = face.observedFaceSupport,
              support.centerlineEligible,
              let medianLine = support.medianLine,
              medianLine.count >= 2,
              medianLine.allSatisfy(isFiniteUnitPoint),
              let apexIndex = support.apexIndex,
              apexIndex > support.contour.startIndex,
              apexIndex < support.contour.index(before: support.contour.endIndex),
              support.contour.allSatisfy(isFiniteUnitPoint)
        else {
            return []
        }

        let sourceIndices = [apexIndex - 1, apexIndex + 1]
        let maximumDisplacement =
            0.016 * face.bounds.width * strength / BeautySafetyCaps.chinTaper
        let radius = face.bounds.width * 0.12
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
        for index in sourceIndices {
            let source = support.contour[index]
            guard let axisX = medianX(at: source.y, medianLine: medianLine),
                  axisX.isFinite,
                  (0...1).contains(axisX)
            else {
                return []
            }
            let distanceToAxis = abs(source.x - axisX)
            let displacement = min(maximumDisplacement, distanceToAxis)
            guard distanceToAxis.isFinite,
                  distanceToAxis > 0,
                  displacement.isFinite,
                  displacement > 0
            else {
                return []
            }

            let signedDisplacement = source.x < axisX ? displacement : -displacement
            let target = SIMD2<Float>(source.x + signedDisplacement, source.y)
            guard isFiniteUnitPoint(target),
                  abs(target.x - axisX) < distanceToAxis,
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

    private func medianX(
        at y: Float,
        medianLine: [SIMD2<Float>]
    ) -> Float? {
        guard y.isFinite else { return nil }
        for (first, second) in zip(medianLine, medianLine.dropFirst()) {
            let lowerY = min(first.y, second.y)
            let upperY = max(first.y, second.y)
            let deltaY = second.y - first.y
            guard lowerY.isFinite,
                  upperY.isFinite,
                  deltaY.isFinite
            else {
                return nil
            }
            if (lowerY...upperY).contains(y), abs(deltaY) > Float.ulpOfOne {
                let progress = (y - first.y) / deltaY
                let x = first.x + (second.x - first.x) * progress
                return x.isFinite ? x : nil
            }
        }
        return nil
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
}
