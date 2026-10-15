import BeautyCore
import BeautyDetection

/// Request-local shared geometry stage. The retained iris sampler precedes
/// the existing main geometry; other reference-effect maps are not integrated.
struct BeautyStillImageGeometryStage {
    let sourceRGBA: [UInt8]
    let controlPoints: [WarpControlPoint]
    let face: FaceGeometry?
    private let width: Int
    private let height: Int
    private let translationX: Float
    private let translationY: Float
    var usesDenseMap: Bool { face?.denseSupport != nil }

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

    init(sourceRGBA: [UInt8], width: Int, height: Int,
         plan: BeautyEffectPlan, face: FaceGeometry?) {
        let prefix = Self.prepareSourcePrefix(sourceRGBA, width: width, height: height,
                                              plan: plan, face: face)
        let iris = face.flatMap { BeautyIrisScaleRemap(width: width, height: height,
            face: $0, strengths: plan.effectiveStrengths, sourceRGBA: prefix.rgba) }
        self.init(postIrisRGBA: iris?.applyRGBA(prefix.rgba) ?? prefix.rgba,
                  mapAdmissionRGBA: sourceRGBA, width: width, height: height,
                  plan: plan, face: face, sourceAdmission: prefix.admission)
    }

    init(postIrisRGBA: [UInt8], mapAdmissionRGBA: [UInt8], width: Int, height: Int,
         plan: BeautyEffectPlan, face: FaceGeometry?, sourceAdmission: SourceAdmission) {
        self.face = face
        self.width = width
        self.height = height
        self.sourceRGBA = postIrisRGBA
        translationX = plan.effectiveStrengths.wholeFaceXPosition
        translationY = plan.effectiveStrengths.wholeFaceYPosition
        guard let face else { controlPoints = []; return }
        var strengths = plan.effectiveStrengths
        // Dense iris is owned by the source-space radial sampler, even on
        // rejection. Never revive the legacy mesh proxy for that request.
        if face.denseSupport != nil { strengths.pupilSize = 0 }
        let pointPlan = BeautyEffectPlan(activeDomains: plan.activeDomains,
            skippedDomains: plan.skippedDomains, warnings: plan.warnings,
            metrics: plan.metrics, effectiveStrengths: strengths)
        controlPoints = BeautyGeometryEffectPipeline.controlPoints(
            for: pointPlan, face: face,
            protectedLeftContour: sourceAdmission.protectedLeftContour,
            protectedRightContour: sourceAdmission.protectedRightContour,
            suppressHairlinePoints: strengths.hairlineHeight != 0,
            suppressSubmentalPoints: strengths.doubleChinReduction != 0 || strengths.doubleChinReductionPro != 0,
            suppressHeadWrapPoints: sourceAdmission.suppressHeadWrap,
            suppressForeheadPoints: strengths.foreheadHeight != 0,
            suppressPhiltrumPoints: sourceAdmission.suppressPhiltrum,
            suppressWholeFaceTranslationPoints: true)
    }

    static func prepareSourcePrefix(_ sourceRGBA: [UInt8], width: Int, height: Int,
                                    plan: BeautyEffectPlan, face: FaceGeometry?) -> SourcePrefix {
        guard let face else {
            return SourcePrefix(rgba: sourceRGBA, admission: SourceAdmission(
                protectedLeftContour: false, protectedRightContour: false,
                suppressHeadWrap: false, suppressPhiltrum: false))
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
        let submental = SubmentalContourRefiner.apply(
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
        return SourcePrefix(rgba: submental, admission: SourceAdmission(
            protectedLeftContour: contour.protectedLeft,
            protectedRightContour: contour.protectedRight,
            suppressHeadWrap: suppressHeadWrap, suppressPhiltrum: suppressPhiltrum))
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
