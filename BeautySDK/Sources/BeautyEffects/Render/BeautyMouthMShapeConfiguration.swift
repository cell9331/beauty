import Foundation

/// Low-dimensional M-shape calibration surface. Positions and displacements
/// use the current source mouth width; vertical placement follows the current
/// source upper/lower lip depths. No image coordinates or observations persist.
struct BeautyMouthMShapeParameters: Sendable {
    // These are forward single-end design coefficients. Only the total
    // reference endpoint span has been observed; a neutral is not established.
    var centralPeak: Double = 0.007176
    var shoulderPeak: Double = -0.004236
    var outerRebound: Double = 0.0022
    var cornerPeak: Double = -0.003041
    var lowerEdgePeak: Double = -0.00392

    var shoulderPosition: Double = 0.1508
    /// Zero keeps the nine-node compatibility control. A positive value
    /// restores source-normalized positive shoulders around the central peak.
    var centralPlateauHalfWidth: Double = 0.07224
    var centralShoulderRatio: Double = 0.65592
    var reboundPosition: Double = 0.35
    var cornerPosition: Double = 0.54
    var supportRadius: Double = 0.78

    var upperTail: Double = 0.30
    /// Positive depth multiple; the lower edge of the upper plateau is above
    /// the seam. Its feather reduces the central peak before reaching the seam.
    var upperPlateauEndInUpperDepth: Double = 0.20
    var profileEndInLowerDepth: Double = 0.43056

    var lowerCenterInLowerDepth: Double = 1.0584
    var lowerHorizontalRadius: Double = 0.11952
    var lowerVerticalRadiusInLowerDepth: Double = 0.5684

    /// Design coefficients calibrated to the observed reference endpoint span
    /// with actual Swift maps. They are not measurements of a neutral state or
    /// isolated single-end strengths. The physical upper protection feather
    /// intentionally retains a residual weak-skin-tail mismatch.
    static let referenceCalibration = Self()

    var isValid: Bool {
        let values = [centralPeak, shoulderPeak, outerRebound, cornerPeak, lowerEdgePeak,
                      shoulderPosition, centralPlateauHalfWidth, centralShoulderRatio,
                      reboundPosition, cornerPosition, supportRadius,
                      upperTail, upperPlateauEndInUpperDepth, profileEndInLowerDepth,
                      lowerCenterInLowerDepth, lowerHorizontalRadius, lowerVerticalRadiusInLowerDepth]
        return values.allSatisfy(\.isFinite)
            && centralPeak > 0 && shoulderPeak < 0 && outerRebound >= 0
            && cornerPeak <= 0 && lowerEdgePeak <= 0
            && 0 < shoulderPosition && shoulderPosition < reboundPosition
            && centralPlateauHalfWidth >= 0 && centralPlateauHalfWidth < shoulderPosition
            && centralShoulderRatio > 0 && centralShoulderRatio <= 1
            && reboundPosition < cornerPosition && cornerPosition < supportRadius
            && upperTail > 0 && upperPlateauEndInUpperDepth > 0
            && upperPlateauEndInUpperDepth < 1 && profileEndInLowerDepth > 0
            && lowerCenterInLowerDepth > 0 && lowerHorizontalRadius > 0
            && lowerVerticalRadiusInLowerDepth > 0
    }

    /// Pure configuration construction also supports synthetic regression
    /// geometry. All arguments are already normalized by source mouth width.
    func configuration(upperDepth: Double, lowerDepth: Double, top: Double,
                       bottom: Double, protectedTop: Double) -> BeautyMouthReferenceModel.MShape? {
        typealias Model = BeautyMouthReferenceModel
        typealias Point = SIMD2<Double>
        guard isValid,
              [upperDepth, lowerDepth, top, bottom, protectedTop].allSatisfy(\.isFinite),
              upperDepth > 0, lowerDepth > 0, top < bottom,
              protectedTop < top - 0.001 else { return nil }
        // Ordered source nodes preserve both outer sign changes. Optional
        // positive shoulders separate central width from the negative peaks.
        var knots = [
            Point(-supportRadius, 0), Point(-cornerPosition, cornerPeak),
            Point(-reboundPosition, outerRebound), Point(-shoulderPosition, shoulderPeak)
        ]
        if centralPlateauHalfWidth > 0 {
            knots.append(Point(-centralPlateauHalfWidth, centralPeak * centralShoulderRatio))
        }
        knots.append(Point(0, centralPeak))
        if centralPlateauHalfWidth > 0 {
            knots.append(Point(centralPlateauHalfWidth, centralPeak * centralShoulderRatio))
        }
        knots += [Point(shoulderPosition, shoulderPeak),
            Point(reboundPosition, outerRebound), Point(cornerPosition, cornerPeak),
            Point(supportRadius, 0)
        ]
        guard let profile = Model.Profile(knots: knots) else { return nil }

        let upperEnd = -upperDepth - upperTail
        let lowerCenter = lowerCenterInLowerDepth * lowerDepth
        let lowerRadius = lowerVerticalRadiusInLowerDepth * lowerDepth
        let lowerEnd = max(profileEndInLowerDepth * lowerDepth, lowerCenter + lowerRadius)
        // The common envelope contains the complete profile/lower-edge support;
        // their own feathers determine amplitude. The absolute source envelope
        // independently enforces the current nose/eye protection boundary.
        let tissue = Model.Envelope(
            innerMin: Point(-supportRadius - 0.02, upperEnd),
            innerMax: Point(supportRadius + 0.02, lowerEnd),
            outerMin: Point(-supportRadius - 0.10, upperEnd - 0.10),
            outerMax: Point(supportRadius + 0.10, lowerEnd + 0.10))
        let sourceTop = max(protectedTop, top - upperTail - 0.10)
        // When protection clips the requested upper tail, use the available
        // source gap rather than collapsing its C1 feather to an epsilon.
        // The upper lip boundary remains inside the full-weight plateau.
        let sourcePlateauTop = max((sourceTop + top) * 0.5, top - upperTail * 0.65)
        let sourcePlateauBottom = bottom + lowerRadius + 0.10
        guard sourcePlateauTop <= sourcePlateauBottom else { return nil }
        let source = Model.Envelope(
            innerMin: Point(-supportRadius - 0.02, sourcePlateauTop),
            innerMax: Point(supportRadius + 0.02, sourcePlateauBottom),
            outerMin: Point(-supportRadius - 0.12, sourceTop),
            outerMax: Point(supportRadius + 0.12, sourcePlateauBottom + 0.10))
        let upperProfile = Model.Envelope(
            innerMin: Point(-supportRadius - 0.02, -upperDepth),
            innerMax: Point(supportRadius + 0.02, -upperDepth * upperPlateauEndInUpperDepth),
            outerMin: Point(-supportRadius - 0.10, upperEnd),
            outerMax: Point(supportRadius + 0.10, lowerDepth * profileEndInLowerDepth))
        guard tissue.isValid, source.isValid, upperProfile.isValid else { return nil }
        return .init(profile: profile, envelope: tissue,
            lowerCenter: .init(center: Point(0, lowerCenter),
                               radius: Point(lowerHorizontalRadius, lowerRadius),
                               vector: Point(0, lowerEdgePeak)),
            sourceEnvelope: source, profileEnvelope: upperProfile)
    }
}

extension BeautyMouthReferenceGeometry {
    func makeMShapeConfiguration(
        parameters: BeautyMouthMShapeParameters = .referenceCalibration
    ) -> BeautyMouthReferenceModel.MShape? {
        parameters.configuration(upperDepth: upperDepth, lowerDepth: lowerDepth,
                                 top: top, bottom: bottom, protectedTop: protectedTop)
    }
}
