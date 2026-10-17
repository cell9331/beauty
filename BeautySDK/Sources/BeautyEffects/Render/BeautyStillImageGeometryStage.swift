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
    private let faceDisplacementMap: BeautyFaceDisplacementMap?
    private let eyeMap: BeautyContinuousEyeMap?
    private let noseMap: BeautyContinuousNoseMap?
    private let mouthMap: BeautyContinuousMouthMap?
    private let eyebrowMap: BeautyContinuousEyebrowMap?
    private let translationX: Float
    private let translationY: Float
    private let jawlineShadow: BeautyJawlineShadow.Evidence?
    private let jawlineShadowStrength: Float
    private let movesJawlineShadowWithFaceField: Bool
    let jawlineShadowRefusal: BeautyJawlineShadow.Refusal?
    /// Present even when the explicit research route refuses. It must never
    /// be mistaken for an absent request and revived through a legacy mapper.
    let irisFollowingResult: BeautyIrisFollowingResult?

    var usesDenseMap: Bool { irisFollowingResult == nil && face?.denseSupport != nil }

    /// Only source-qualified decisions cross the cutpoint. No output raster
    /// is used to resolve strengths or repeat source admission.
    struct SourceAdmission {
        let protectedLeftContour: Bool
        let protectedRightContour: Bool
        let suppressHeadWrap: Bool
        let suppressPhiltrum: Bool
    }

    struct SourcePrefix: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let rgba: [UInt8]
        let admission: SourceAdmission

        var description: String { "BeautyGeometrySourcePrefix(byteCount: \(rgba.count))" }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["byteCount": rgba.count], displayStyle: .struct)
        }
    }

    private enum Preparation {
        case original
        case afterIris(SourceAdmission)
    }

    init(sourceRGBA: [UInt8], width: Int, height: Int,
         plan: BeautyEffectPlan, face: FaceGeometry?, eyebrowSourceRGBA: [UInt8]? = nil, sourceOwnershipRGBA: [UInt8]? = nil,
         jawlineShadowSourceRGBA: [UInt8]? = nil, irisGeometryRoute: BeautyIrisGeometryRoute = .legacy) {
        self.init(sourceRGBA: sourceRGBA, mapAdmissionRGBA: sourceRGBA,
                  width: width, height: height, plan: plan, face: face,
                  eyebrowSourceRGBA: eyebrowSourceRGBA, sourceOwnershipRGBA: sourceOwnershipRGBA, jawlineShadowSourceRGBA: jawlineShadowSourceRGBA,
                  preparation: .original, irisGeometryRoute: irisGeometryRoute)
    }

    /// All source refiners and IR have already run on the original. Map
    /// admission still reads the separately resized pre-refiner source.
    init(postIrisRGBA: [UInt8], mapAdmissionRGBA: [UInt8], width: Int, height: Int,
         plan: BeautyEffectPlan, face: FaceGeometry?, sourceAdmission: SourceAdmission,
         eyebrowSourceRGBA: [UInt8]? = nil, sourceOwnershipRGBA: [UInt8]? = nil, jawlineShadowSourceRGBA: [UInt8]? = nil) {
        self.init(sourceRGBA: postIrisRGBA, mapAdmissionRGBA: mapAdmissionRGBA,
                  width: width, height: height, plan: plan, face: face,
                  eyebrowSourceRGBA: eyebrowSourceRGBA, sourceOwnershipRGBA: sourceOwnershipRGBA, jawlineShadowSourceRGBA: jawlineShadowSourceRGBA,
                  preparation: .afterIris(sourceAdmission), irisGeometryRoute: .legacy)
    }

    private init(sourceRGBA: [UInt8], mapAdmissionRGBA: [UInt8], width: Int, height: Int,
                 plan: BeautyEffectPlan, face: FaceGeometry?, eyebrowSourceRGBA: [UInt8]?, sourceOwnershipRGBA: [UInt8]?,
                 jawlineShadowSourceRGBA: [UInt8]?,
                 preparation: Preparation, irisGeometryRoute: BeautyIrisGeometryRoute) {
        self.face = face
        self.width = width
        self.height = height
        if case .calibrated(let request) = irisGeometryRoute {
            // Calibrations bind exactly this immutable stage input. No old IR,
            // source refiner, point proxy, dense map, or continuous eye field
            // participates, including after a refusal.
            let result: BeautyIrisFollowingResult
            if !BeautyIrisGeometryRoute.permitsIsolatedGeometry(plan.effectiveStrengths) {
                result = BeautyIrisGeometryRoute.refusal(request, sourceRGBA: sourceRGBA,
                    reason: .unsupportedStageCombination)
            } else {
                result = BeautyIrisFollowingMap.render(request, sourceRGBA: sourceRGBA,
                    width: width, height: height,
                    availableObservedSides: BeautyIrisGeometryRoute.availableObservedSides(face, width: width, height: height))
            }
            irisFollowingResult = result
            self.sourceRGBA = result.rgba
            controlPoints = []
            continuousMap = nil
            faceDisplacementMap = nil
            eyeMap = nil
            noseMap = nil
            mouthMap = nil
            eyebrowMap = nil
            translationX = 0
            translationY = 0
            jawlineShadow = nil
            jawlineShadowStrength = 0
            movesJawlineShadowWithFaceField = false
            jawlineShadowRefusal = nil
            return
        }
        irisFollowingResult = nil
        jawlineShadowStrength = plan.effectiveStrengths.jawlineShadow
        // Metal enters with the pre-colour raster; CPU supplies an explicit
        // immutable pre-colour proof. A present malformed proof stays present.
        if jawlineShadowStrength > 0, let face,
           BeautyJawlineShadow.hasIndependentSourceCoordinates(plan.effectiveStrengths) {
            let qualification = BeautyJawlineShadow.assess(
                sourceRGBA: jawlineShadowSourceRGBA ?? mapAdmissionRGBA, width: width, height: height, face: face)
            jawlineShadow = qualification.evidence
            jawlineShadowRefusal = qualification.refusal
        } else {
            jawlineShadow = nil
            jawlineShadowRefusal = jawlineShadowStrength > 0 ? .unsupportedScope : nil
        }
        var geometryStrengths = plan.effectiveStrengths
        geometryStrengths.jawlineShadow = 0
        faceDisplacementMap = face.flatMap {
            BeautyFaceDisplacementMap(width: width, height: height, face: $0, strengths: geometryStrengths,
                                      sourceRGBA: sourceOwnershipRGBA ?? mapAdmissionRGBA)
        }
        movesJawlineShadowWithFaceField = jawlineShadow != nil && faceDisplacementMap != nil
        // The reference-derived fields own these controls even when geometry
        // or inverse admission refuses. A refusal cannot revive old point pulls,
        // old whole-feature protection, or the pixel-boundary smoother.
        var legacyFaceStrengths = geometryStrengths
        for key in BeautyFaceDisplacementMap.keys { legacyFaceStrengths[keyPath: key] = 0 }
        continuousMap = face.flatMap { geometry in
            let proof = BeautyContinuousFaceMap.requiresSourceOwnershipProof(
                face: geometry, strengths: legacyFaceStrengths) ? (sourceOwnershipRGBA ?? mapAdmissionRGBA) : mapAdmissionRGBA
            return BeautyContinuousFaceMap(width: width, height: height, face: geometry,
                strengths: legacyFaceStrengths, sourceRGBA: proof)
        }
        var eyeStrengths = geometryStrengths
        if face?.denseSupport != nil { eyeStrengths.pupilSize = 0 }
        if case .afterIris = preparation { eyeStrengths.pupilSize = 0 }
        eyeMap = face.flatMap { BeautyContinuousEyeMap(
            width: width, height: height, face: $0, strengths: eyeStrengths,
            sourceRGBA: mapAdmissionRGBA) }
        noseMap = face.flatMap { BeautyContinuousNoseMap(
            width: width, height: height, face: $0, strengths: geometryStrengths) }
        mouthMap = face.flatMap { BeautyContinuousMouthMap(
            width: width, height: height, face: $0, strengths: geometryStrengths) }
        eyebrowMap = face.flatMap { BeautyContinuousEyebrowMap(
            width: width, height: height, face: $0, strengths: geometryStrengths,
            sourceRGBA: eyebrowSourceRGBA ?? mapAdmissionRGBA) }
        translationX = plan.effectiveStrengths.wholeFaceXPosition
        translationY = plan.effectiveStrengths.wholeFaceYPosition
        guard let face else {
            self.sourceRGBA = sourceRGBA
            controlPoints = []
            return
        }

        let strengths = geometryStrengths
        let admission: SourceAdmission
        switch preparation {
        case .original:
            let prefix = Self.prepareSourcePrefix(sourceRGBA, width: width, height: height,
                                                  plan: plan, face: face)
            self.sourceRGBA = BeautyIrisScaleRemap(
                width: width, height: height, face: face, strengths: strengths,
                sourceRGBA: prefix.rgba)?.applyRGBA(prefix.rgba) ?? prefix.rgba
            admission = prefix.admission
        case .afterIris(let sourceAdmission):
            self.sourceRGBA = sourceRGBA
            admission = sourceAdmission
        }

        // Observed eyes own the continuous stage, including when its local
        // admission rejects. Rejection never revives a coarse point proxy.
        var pointStrengths = strengths
        for key in BeautyFaceDisplacementMap.keys { pointStrengths[keyPath: key] = 0 }
        // Observed source smoothing owns the raster even when its local admission refuses.
        if face.observedFaceSupport != nil {
            pointStrengths.faceContourSmooth = 0
        }
        if face.denseSupport != nil { pointStrengths.pupilSize = 0 }
        if case .afterIris = preparation { pointStrengths.pupilSize = 0 }
        if BeautyContinuousEyeMap.replacesLegacy(for: face) {
            for key in BeautyContinuousEyeMap.keys {
                pointStrengths[keyPath: key] = 0
            }
        }
        if BeautyContinuousEyebrowMap.replacesLegacy(for: face) {
            for key in BeautyContinuousEyebrowMap.keys { pointStrengths[keyPath: key] = 0 }
        }
        let pointPlan = BeautyEffectPlan(activeDomains: plan.activeDomains,
            skippedDomains: plan.skippedDomains, warnings: plan.warnings,
            metrics: plan.metrics, effectiveStrengths: pointStrengths)
        controlPoints = BeautyGeometryEffectPipeline.controlPoints(
            for: pointPlan, face: face,
            protectedLeftContour: admission.protectedLeftContour,
            protectedRightContour: admission.protectedRightContour,
            suppressHairlinePoints: strengths.hairlineHeight != 0,
            suppressSubmentalPoints: strengths.doubleChinReduction != 0 ||
                strengths.doubleChinReductionPro != 0,
            suppressHeadWrapPoints: admission.suppressHeadWrap,
            suppressForeheadPoints: strengths.foreheadHeight != 0,
            suppressPhiltrumPoints: admission.suppressPhiltrum,
            suppressWholeFaceTranslationPoints: true,
            suppressContinuousFacePoints: BeautyContinuousFaceMap.replacesLegacy(for: face),
            suppressContinuousNosePoints: BeautyContinuousNoseMap.replacesLegacy(for: face),
            suppressContinuousMouthPoints: BeautyContinuousMouthMap.replacesLegacy(for: face)
        )
    }

    static func prepareSourcePrefix(_ sourceRGBA: [UInt8], width: Int, height: Int,
                                    plan: BeautyEffectPlan, face: FaceGeometry?) -> SourcePrefix {
        guard let face else {
            return SourcePrefix(rgba: sourceRGBA, admission: SourceAdmission(
                protectedLeftContour: false, protectedRightContour: false,
                suppressHeadWrap: false, suppressPhiltrum: false))
        }
        let strengths = plan.effectiveStrengths
        // Hairline height is owned by the wide two-dimensional source field.
        // The legacy raster refiner remains only for forehead height here.
        let hairline = HairlineBoundaryRefiner.apply(
            sourceRGBA, width: width, height: height, face: face,
            strength: HairlineBoundaryRefiner.combinedStrength(
                hairline: 0, forehead: strengths.foreheadHeight
            )
        )
        let submental = SubmentalContourRefiner.apply(
            hairline, width: width, height: height, face: face,
            baseStrength: strengths.doubleChinReduction,
            proStrength: strengths.doubleChinReductionPro
        )

        // Admission uses the same pre-hairline/submental raster as before.
        // Failed source admission must not re-enable a legacy proxy emission.
        let suppressHeadWrap = strengths.headWrap != 0 &&
            !HairlineBoundaryRefiner.hasCoherentHairCap(
                sourceRGBA, width: width, height: height, face: face
            )
        let suppressPhiltrum = strengths.philtrumLength != 0 &&
            !PhiltrumSourceAdmission.hasRegisteredUpperLip(
                sourceRGBA, width: width, height: height, face: face
            )
        return SourcePrefix(rgba: submental, admission: SourceAdmission(
            protectedLeftContour: false,
            protectedRightContour: false,
            suppressHeadWrap: suppressHeadWrap, suppressPhiltrum: suppressPhiltrum))
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
        // The admitted jaw-angle/hairline fields and this tone share immutable
        // source coordinates. Shade the current colour baseline before their
        // single inverse sample, so material ownership moves with the jaw.
        let source = movesJawlineShadowWithFaceField
            ? (jawlineShadow?.apply(to: contour, strength: jawlineShadowStrength) ?? contour) : contour
        let face = faceDisplacementMap?.applyRGBA(source) ?? source
        return eyeMap?.applyRGBA(face) ?? face
    }

    func applyingContinuousNose(to bytes: [UInt8]) -> [UInt8] {
        noseMap?.applyRGBA(bytes) ?? bytes
    }

    func applyingContinuousMouth(to bytes: [UInt8]) -> [UInt8] {
        mouthMap?.applyRGBA(bytes) ?? bytes
    }

    func applyingContinuousEyebrows(to bytes: [UInt8], onAppliedSideCount: ((Int) -> Void)? = nil) -> [UInt8] {
        guard let eyebrowMap else { onAppliedSideCount?(0); return bytes }
        return eyebrowMap.applyRGBA(bytes, onAppliedSideCount: onAppliedSideCount)
    }

    /// Rigid source-qualified translation remains after the selected sampler.
    func applyingTranslation(to bytes: [UInt8]) -> [UInt8] {
        guard irisFollowingResult == nil else { return bytes }
        // Both executors reach this point after their pointwise colour pass.
        // The immutable evidence never replaces the current stage's RGB bytes.
        let shaded = movesJawlineShadowWithFaceField ? bytes :
            (jawlineShadow?.apply(to: bytes, strength: jawlineShadowStrength) ?? bytes)
        guard let face else { return shaded }
        return WholeFaceTranslationRefiner.apply(
            shaded, width: width, height: height, face: face,
            xStrength: translationX, yStrength: translationY
        )
    }
}
