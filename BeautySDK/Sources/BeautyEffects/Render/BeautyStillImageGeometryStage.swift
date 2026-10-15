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
    private let continuousMap: BeautyContinuousFaceMap?
    private let eyeMap: BeautyContinuousEyeMap?
    private let noseMap: BeautyContinuousNoseMap?
    private let mouthMap: BeautyContinuousMouthMap?
    private let translationX: Float
    private let translationY: Float
    private let jawlineShadow: BeautyJawlineShadow.Evidence?
    private let jawlineShadowStrength: Float
    let jawlineShadowRefusal: BeautyJawlineShadow.Refusal?

    var usesDenseMap: Bool { face?.denseSupport != nil }

    init(sourceRGBA: [UInt8], width: Int, height: Int,
         plan: BeautyEffectPlan, face: FaceGeometry?, sourceOwnershipRGBA: [UInt8]? = nil,
         jawlineShadowSourceRGBA: [UInt8]? = nil) {
        self.face = face
        self.width = width
        self.height = height
        jawlineShadowStrength = plan.effectiveStrengths.jawlineShadow
        // Metal enters with the pre-colour raster; CPU supplies an explicit
        // immutable pre-colour proof. A present malformed proof stays present.
        if jawlineShadowStrength > 0, let face,
           BeautyJawlineShadow.hasIndependentSourceCoordinates(plan.effectiveStrengths) {
            let qualification = BeautyJawlineShadow.assess(
                sourceRGBA: jawlineShadowSourceRGBA ?? sourceRGBA, width: width, height: height, face: face)
            jawlineShadow = qualification.evidence
            jawlineShadowRefusal = qualification.refusal
        } else {
            jawlineShadow = nil
            jawlineShadowRefusal = jawlineShadowStrength > 0 ? .unsupportedScope : nil
        }
        var geometryStrengths = plan.effectiveStrengths
        geometryStrengths.jawlineShadow = 0
        continuousMap = face.flatMap { geometry in
            let proof = BeautyContinuousFaceMap.requiresSourceOwnershipProof(
                face: geometry, strengths: geometryStrengths) ? (sourceOwnershipRGBA ?? sourceRGBA) : sourceRGBA
            return BeautyContinuousFaceMap(width: width, height: height, face: geometry,
                strengths: geometryStrengths, sourceRGBA: proof)
        }
        eyeMap = face.flatMap { BeautyContinuousEyeMap(
            width: width, height: height, face: $0, strengths: geometryStrengths,
            sourceRGBA: sourceRGBA) }
        noseMap = face.flatMap { BeautyContinuousNoseMap(
            width: width, height: height, face: $0, strengths: geometryStrengths) }
        mouthMap = face.flatMap { BeautyContinuousMouthMap(
            width: width, height: height, face: $0, strengths: geometryStrengths) }
        translationX = plan.effectiveStrengths.wholeFaceXPosition
        translationY = plan.effectiveStrengths.wholeFaceYPosition
        guard let face else {
            self.sourceRGBA = sourceRGBA
            controlPoints = []
            return
        }

        let strengths = geometryStrengths
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
        // Observed eyes own the continuous stage, including when its local
        // admission rejects. Rejection never revives a coarse point proxy.
        var pointStrengths = strengths
        // The observed source-raster refiner owns smoothing on both samplers.
        // Its local rejection cannot revive a second coarse/dense proxy.
        if face.observedFaceSupport != nil {
            pointStrengths.faceContourSmooth = 0
        }
        if BeautyContinuousEyeMap.replacesLegacy(for: face) {
            for key in BeautyContinuousEyeMap.keys {
                pointStrengths[keyPath: key] = 0
            }
        }
        let pointPlan = BeautyEffectPlan(activeDomains: plan.activeDomains,
            skippedDomains: plan.skippedDomains, warnings: plan.warnings,
            metrics: plan.metrics, effectiveStrengths: pointStrengths)
        controlPoints = BeautyGeometryEffectPipeline.controlPoints(
            for: pointPlan, face: face,
            protectedLeftContour: contour.protectedLeft,
            protectedRightContour: contour.protectedRight,
            suppressHairlinePoints: strengths.hairlineHeight != 0,
            suppressSubmentalPoints: strengths.doubleChinReduction != 0 ||
                strengths.doubleChinReductionPro != 0,
            suppressHeadWrapPoints: suppressHeadWrap,
            suppressForeheadPoints: strengths.foreheadHeight != 0,
            suppressPhiltrumPoints: suppressPhiltrum,
            suppressWholeFaceTranslationPoints: true,
            suppressContinuousFacePoints: BeautyContinuousFaceMap.replacesLegacy(for: face),
            suppressContinuousNosePoints: BeautyContinuousNoseMap.replacesLegacy(for: face),
            suppressContinuousMouthPoints: BeautyContinuousMouthMap.replacesLegacy(for: face)
        )
    }

    /// Dense geometry is CPU-owned on either backend. A rejected map preserves
    /// its supplied pre-map raster, including independently admitted color.
    func applyingDenseMap(to bytes: [UInt8]) -> [UInt8] {
        guard let face, usesDenseMap else { return bytes }
        return BeautyDenseGeometryMap(width: width, height: height,
                                      face: face, points: controlPoints)?.applyRGBA(bytes) ?? bytes
    }

    func applyingContinuousContour(to bytes: [UInt8]) -> [UInt8] {
        let contour = continuousMap?.applyRGBA(bytes) ?? bytes
        return eyeMap?.applyRGBA(contour) ?? contour
    }

    func applyingContinuousNose(to bytes: [UInt8]) -> [UInt8] {
        noseMap?.applyRGBA(bytes) ?? bytes
    }

    func applyingContinuousMouth(to bytes: [UInt8]) -> [UInt8] {
        mouthMap?.applyRGBA(bytes) ?? bytes
    }

    /// Rigid source-qualified translation remains after the selected sampler.
    func applyingTranslation(to bytes: [UInt8]) -> [UInt8] {
        // Both executors reach this point after their pointwise colour pass.
        // The immutable evidence never replaces the current stage's RGB bytes.
        let shaded = jawlineShadow?.apply(to: bytes, strength: jawlineShadowStrength) ?? bytes
        guard let face else { return shaded }
        return WholeFaceTranslationRefiner.apply(
            shaded, width: width, height: height, face: face,
            xStrength: translationX, yStrength: translationY
        )
    }
}
