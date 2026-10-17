import Foundation

/// Source-normalized calibration variables for the two fullness endpoints.
/// These are implementation choices, not measured single-endpoint strengths:
/// the reference screenshots do not establish a common neutral image.
struct BeautyMouthFullnessCalibration: Sendable {
    // Design calibration against reference endpoint spans using actual Swift
    // maps and a frozen fresh native observation. These nominal values remain
    // subject to each request's continuous safety certificate; they are not
    // measured neutral-to-endpoint strengths or owner appearance acceptance.
    var upperRate: Double = 0.363750
    var lowerRate: Double = 0.450000
    /// Distances along the source mouth axis, in source mouth-width units.
    var innerHalfWidth: Double = 0.197500
    var outerHalfWidth: Double = 0.422500
    /// Additional skin support beyond each observed central lip depth, also
    /// in mouth-width units. They do not specify a red-lip segmentation mask.
    var upperSkinReach: Double = 0.163750
    var lowerSkinReach: Double = 0.197500
    /// Suppress the seam/interior response and recover the full expansion at
    /// the source-observed depth. Zero preserves the linear tissue response.
    var depthCurvature: Double = 0.112500
    /// One relative-width degree of freedom: the upper lip can retain its
    /// lateral response while the lower lip and its side skin taper sooner.
    var upperWidthScale: Double = 1.234375

    var isValid: Bool {
        [upperRate, lowerRate, innerHalfWidth, outerHalfWidth,
         upperSkinReach, lowerSkinReach, depthCurvature, upperWidthScale].allSatisfy(\.isFinite)
            && upperRate >= 0 && lowerRate >= 0
            && innerHalfWidth > 0 && outerHalfWidth > innerHalfWidth
            && upperSkinReach > 0 && lowerSkinReach > 0
            && depthCurvature >= 0 && depthCurvature <= 1
            && upperWidthScale >= 1 && upperWidthScale <= 1.6
    }
}

extension BeautyMouthReferenceGeometry {
    /// Construct a candidate from request-local source anatomy. Variant
    /// calibration is explicit; no image coordinates or saved landmarks enter
    /// this configuration. Invalid variants abstain instead of being clamped
    /// into a different, unreported calibration.
    func makeFullnessConfiguration(
        calibration c: BeautyMouthFullnessCalibration = .init()
    ) -> Model.Fullness? {
        guard c.isValid else { return nil }
        let innerTop = -upperDepth * 1.05
        let innerBottom = lowerDepth * 1.05
        let outerTop = -upperDepth - c.upperSkinReach
        let envelope = Model.Envelope(
            innerMin: Point(-c.innerHalfWidth, innerTop),
            innerMax: Point(c.innerHalfWidth, innerBottom),
            outerMin: Point(-c.outerHalfWidth, outerTop),
            outerMax: Point(c.outerHalfWidth, lowerDepth + c.lowerSkinReach)
        )
        var upperEnvelope = envelope
        upperEnvelope.innerMin.x *= c.upperWidthScale
        upperEnvelope.innerMax.x *= c.upperWidthScale
        upperEnvelope.outerMin.x *= c.upperWidthScale
        upperEnvelope.outerMax.x *= c.upperWidthScale
        let widestOuterX = c.outerHalfWidth * c.upperWidthScale
        // Tissue depth follows the curved seam. Physical eye/nose protection
        // belongs to an absolute source-y plane, so it must not be translated
        // by the difference between the central and minimum seam heights.
        // Use the observed available gap for the transition rather than a
        // nearly discontinuous fixed epsilon immediately below protection.
        let protectedGap = top - protectedTop
        let sourcePlateauTop = protectedTop + protectedGap * 0.75
        let sourcePlateauBottom = seam.maximumValue + envelope.outerMax.y
        let sourceEnvelope = Model.Envelope(
            innerMin: Point(-widestOuterX, sourcePlateauTop),
            innerMax: Point(widestOuterX, sourcePlateauBottom),
            outerMin: Point(-widestOuterX - 0.10, protectedTop),
            outerMax: Point(widestOuterX + 0.10, sourcePlateauBottom + 0.10)
        )
        let blend = min(upperDepth, lowerDepth) * 0.12
        guard envelope.isValid, upperEnvelope.isValid, sourceEnvelope.isValid,
              protectedGap.isFinite, protectedGap > 0,
              blend.isFinite, blend > 0 else { return nil }
        var result = Model.Fullness(upperRate: c.upperRate, lowerRate: c.lowerRate,
                     blendHalfWidth: blend, envelope: envelope,
                     sourceEnvelope: sourceEnvelope, depthCurvature: c.depthCurvature,
                     upperDepth: upperDepth, lowerDepth: lowerDepth)
        result.upperEnvelope = upperEnvelope
        return result
    }
}
