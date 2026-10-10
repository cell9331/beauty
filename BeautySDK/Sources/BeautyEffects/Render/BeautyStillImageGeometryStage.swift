import BeautyCore
import BeautyDetection

/// A request-local geometry stage shared by the still-image executors.
/// Each executor supplies its raster at the existing stage boundary: this does
/// not reorder color, texture or local-retouch composition.
struct BeautyStillImageGeometryStage {
    let sourceRGBA: [UInt8]
    let controlPoints: [WarpControlPoint]
    let face: FaceGeometry?
    private let width: Int
    private let height: Int
    private let translationX: Float
    private let translationY: Float

    var usesDenseMap: Bool { face?.denseSupport != nil }

    init(sourceRGBA: [UInt8], width: Int, height: Int,
         plan: BeautyEffectPlan, face: FaceGeometry?) {
        self.face = face
        self.width = width
        self.height = height
        translationX = plan.effectiveStrengths.wholeFaceXPosition
        translationY = plan.effectiveStrengths.wholeFaceYPosition
        guard let face else {
            self.sourceRGBA = sourceRGBA
            controlPoints = []
            return
        }

        let strengths = plan.effectiveStrengths
        let contour = FaceContourSubpixelRefiner.refineWithProtection(
            sourceRGBA, width: width, height: height, face: face,
            strength: strengths.faceContourSmooth
        )
        let hairline = HairlineBoundaryRefiner.apply(
            contour.bytes, width: width, height: height, face: face,
            strength: HairlineBoundaryRefiner.combinedStrength(
                hairline: strengths.hairlineHeight, forehead: strengths.foreheadHeight
            )
        )
        self.sourceRGBA = SubmentalContourRefiner.apply(
            hairline, width: width, height: height, face: face,
            baseStrength: strengths.doubleChinReduction,
            proStrength: strengths.doubleChinReductionPro
        )

        // Admission uses the same pre-hairline/submental raster as before.
        // Failed source admission must not re-enable a legacy proxy emission.
        let suppressHeadWrap = strengths.headWrap != 0 &&
            !HairlineBoundaryRefiner.hasCoherentHairCap(
                contour.bytes, width: width, height: height, face: face
            )
        let suppressPhiltrum = strengths.philtrumLength != 0 &&
            !PhiltrumSourceAdmission.hasRegisteredUpperLip(
                contour.bytes, width: width, height: height, face: face
            )
        controlPoints = BeautyGeometryEffectPipeline.controlPoints(
            for: plan, face: face,
            protectedLeftContour: contour.protectedLeft,
            protectedRightContour: contour.protectedRight,
            suppressHairlinePoints: strengths.hairlineHeight != 0,
            suppressSubmentalPoints: strengths.doubleChinReduction != 0 ||
                strengths.doubleChinReductionPro != 0,
            suppressHeadWrapPoints: suppressHeadWrap,
            suppressForeheadPoints: strengths.foreheadHeight != 0,
            suppressPhiltrumPoints: suppressPhiltrum,
            suppressWholeFaceTranslationPoints: true
        )
    }

    /// Dense geometry is CPU-owned on either backend. A rejected map preserves
    /// its supplied pre-map raster, including independently admitted color.
    func applyingDenseMap(to bytes: [UInt8]) -> [UInt8] {
        guard let face, usesDenseMap else { return bytes }
        return BeautyDenseGeometryMap(width: width, height: height,
                                      face: face, points: controlPoints)?.applyRGBA(bytes) ?? bytes
    }

    /// Rigid source-qualified translation remains after the selected sampler.
    func applyingTranslation(to bytes: [UInt8]) -> [UInt8] {
        guard let face else { return bytes }
        return WholeFaceTranslationRefiner.apply(
            bytes, width: width, height: height, face: face,
            xStrength: translationX, yStrength: translationY
        )
    }
}
