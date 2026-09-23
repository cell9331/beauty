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
        strength requestedStrength: Float
    ) -> [WarpControlPoint] {
        guard requestedStrength.isFinite,
              requestedStrength > Float.ulpOfOne,
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

        let strength = min(requestedStrength, BeautySafetyCaps.chinTaper)
        let normalizedStrength = strength / BeautySafetyCaps.chinTaper
        let maximumDisplacement =
            (face.observedOuterLips == nil ? 0.016 : 0.024) * face.bounds.width * normalizedStrength
        let radius = face.bounds.width * 0.12
        let falloff: Float = 2
        guard strength.isFinite,
              strength > 0,
              normalizedStrength.isFinite,
              normalizedStrength > 0,
              maximumDisplacement.isFinite,
              maximumDisplacement > 0,
              radius.isFinite,
              radius > 0,
              falloff.isFinite,
              falloff > 0
        else {
            return []
        }

        let immediateIndices = [apexIndex - 1, apexIndex + 1]
        var immediateDistance: Float = 0
        for index in immediateIndices {
            let source = support.contour[index]
            guard let axisX = medianX(at: source.y, medianLine: medianLine),
                  axisX.isFinite,
                  (0...1).contains(axisX)
            else {
                return []
            }
            immediateDistance += abs(source.x - axisX)
        }
        guard immediateDistance.isFinite, immediateDistance > 0 else {
            return []
        }
        let immediateFieldIsQuantizationHostile = immediateDistance < maximumDisplacement * 0.5
        let exactCapNeedsValidatedBand = strength == BeautySafetyCaps.chinTaper
        let pairCount = immediateFieldIsQuantizationHostile || exactCapNeedsValidatedBand ? 3 : 1
        guard apexIndex - pairCount >= support.contour.startIndex,
              apexIndex + pairCount < support.contour.endIndex
        else { return [] }
        // Sub-cap fields retain the original two points when their immediate
        // flanks have enough leverage. Exact-cap requests and quantization-
        // hostile flanks expand to the narrowest three paired contour samples
        // around the same observed apex so the validated chin ROI receives a
        // raster-visible field. No legacy or sibling geometry enters this
        // request-local centerline-owned band.
        var points: [WarpControlPoint] = []
        var requestedMagnitudes: [Float] = []
        let observedMouthBottom: Float?
        if let lips = face.observedOuterLips {
            guard lips.count >= 4, lips.count <= 32, lips.allSatisfy(isFiniteUnitPoint),
                  Set(lips).count == lips.count else { return [] }
            observedMouthBottom = lips.map(\.y).max()
        } else { observedMouthBottom = nil }
        let eligiblePairs = (1...pairCount).filter { offset in
            guard let bottom = observedMouthBottom else { return true }
            return [apexIndex - offset, apexIndex + offset].allSatisfy {
                support.contour[$0].y - bottom > face.bounds.width * 0.04
            }
        }
        for offset in eligiblePairs {
            let pair = [apexIndex - offset, apexIndex + offset]
            if let bottom = observedMouthBottom,
               pair.contains(where: { support.contour[$0].y <= bottom }) { continue }
            var pairSides: [Float] = []
            for index in pair {
                let source = support.contour[index]
                guard let axisX = medianX(at: source.y, medianLine: medianLine),
                      axisX.isFinite,
                      (0...1).contains(axisX)
                else {
                    return []
                }
                let signedDistance = source.x - axisX
                let distanceToAxis = abs(signedDistance)
                let displacement = min(
                    maximumDisplacement,
                    distanceToAxis * normalizedStrength
                )
                guard signedDistance.isFinite,
                      signedDistance != 0,
                      distanceToAxis.isFinite,
                      displacement.isFinite,
                      displacement > 0
                else {
                    return []
                }

                let signedDisplacement = signedDistance < 0 ? displacement : -displacement
                var target = SIMD2<Float>(source.x + signedDisplacement, source.y)
                var localRadius = radius
                if let mouthBottom = observedMouthBottom {
                    // Keep a face-relative lip clearance and use at most 3/4
                    // of the gap. Ordered inward fields use the x-Jacobian
                    // bound, while nil-support legacy outputs remain exact.
                    let clearance = source.y - mouthBottom
                    localRadius = min(radius, clearance * 0.75, clearance - face.bounds.width * 0.04)
                    let slopePerPoint = Float(0.8 / Double(max(1, eligiblePairs.count)))
                    let bounded = min(displacement, localRadius * slopePerPoint * normalizedStrength)
                        * (1 - 32 * Float.ulpOfOne)
                    target.x = source.x + (signedDistance < 0 ? bounded : -bounded)
                }
                guard isFiniteUnitPoint(target),
                      abs(target.x - axisX) < distanceToAxis,
                      let point = validatedPoint(
                          source: source,
                          target: target,
                          radius: localRadius,
                          strength: strength,
                          falloff: observedMouthBottom == nil ? falloff : 1,
                          preserveRadius: observedMouthBottom != nil
                      )
                else {
                    return []
                }
                pairSides.append(signedDistance)
                points.append(point)
                requestedMagnitudes.append(displacement)
            }
            guard pairSides.count == 2,
                  pairSides[0] * pairSides[1] < 0
            else {
                return []
            }
        }
        if observedMouthBottom != nil {
            // Water-fill each side's unchanged slope budget. Equal allocation
            // wastes the unused share of wide-radius, physical-cap-limited
            // points and unnecessarily suppresses narrower eligible supports.
            for positive in [true, false] {
                let indices = points.indices.filter {
                    (points[$0].target.x > points[$0].source.x) == positive
                }
                let budget = 0.8 * Double(normalizedStrength) * (1 - 32 * Double(Float.ulpOfOne))
                var low = 0.0, high = budget
                for _ in 0..<48 {
                    let level = (low + high) * 0.5
                    let used = indices.reduce(0.0) {
                        $0 + min(Double(requestedMagnitudes[$1]) / Double(points[$1].radius), level)
                    }
                    if used <= budget { low = level } else { high = level }
                }
                for index in indices {
                    let point = points[index]
                    let magnitude = min(Double(requestedMagnitudes[index]), low * Double(point.radius))
                        * (1 - 32 * Double(Float.ulpOfOne))
                    var x = Float(Double(point.source.x) + (positive ? magnitude : -magnitude))
                    if abs(Double(x) - Double(point.source.x)) > magnitude {
                        x = positive ? x.nextDown : x.nextUp
                    }
                    points[index] = WarpControlPoint(source: point.source,
                        target: SIMD2<Float>(x, point.source.y), radius: point.radius,
                        strength: point.strength, falloff: point.falloff)
                }
            }
            return HorizontalInwardWarpSafety.admitted(points, maximumSlope: 0.8)
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
        falloff: Float,
        preserveRadius: Bool = false
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
            radius: preserveRadius ? radius : min(max(radius, 0.04), 0.35),
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
