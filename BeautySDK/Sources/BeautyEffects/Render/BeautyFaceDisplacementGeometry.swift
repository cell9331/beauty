import BeautyCore
import BeautyDetection
import Foundation

/// Source-fixed observed geometry for the reference-derived candidate fields.
/// Pixel centres are integer indices: normalized coordinates map to
/// normalized*imageSize-0.5. The new defaults are informed by reference endpoint
/// checks, not measured single-endpoint responses or a uniquely identified model.
struct BeautyFaceDisplacementGeometry: Sendable {
    private typealias Model = BeautyFaceDisplacementModel

    let origin: SIMD2<Double>
    let axisX: SIMD2<Double>
    let axisY: SIMD2<Double>
    let scale: Double
    let normalizedContour: [SIMD2<Double>]

    private let width: Int
    private let height: Int
    private let chin: SIMD2<Double>
    private let mouth: SIMD2<Double>
    private let leftEye: [SIMD2<Double>]
    private let rightEye: [SIMD2<Double>]
    private let lips: [SIMD2<Double>]
    private let nasalCore: [SIMD2<Double>]?
    private let apex: Int
    private let poseScale: Double

    /// Source-normalized reference ranges seed these engineering defaults.
    /// Signed amplitudes and the neutral response are design choices, checked
    /// as complete low.inverse -> high endpoint maps, never labelled as a
    /// measured single-endpoint response. The public report records residuals.
    private enum FiveFieldDefaults {
        static let templeRadial = 0.045
        static let templeAnchorMouthFraction = 0.24
        static let templeAboveContour = 0.17
        static let templeInwardFromContour = 0.08
        static let templeRadius = SIMD2(0.30, 0.65)
        static let cheekRadial = 0.027
        static let cheekHeightMouthFraction = 0.29
        static let cheekAnchorMouthFraction = 0.24
        static let cheekRadius = SIMD2(0.355, 0.70)
        static let chinLengthVertical = 0.07
        // k=0 preserves the competing, purely vertical minimal baseline until
        // independent material correspondences identify horizontal contraction.
        static let chinLengthHorizontal = 0.0
        static let chinLengthUpperStart = -0.05
        static let chinLengthPlateauStart = 0.80
        static let chinLengthPlateauBelow = -0.10
        static let chinLengthReleaseBelow = 1.08
        static let chinLengthMinimumRelease = 0.50
        static let chinLengthRadiusWidthFraction = 1.65
        static let chinPeakAbove = 0.10
        static let chinPeakHorizontal = 0.008
        static let chinPeakVertical = 0.055
        // 1/sqrt(5) < delta/radius < 1 gives two vertical maxima with
        // nonzero central tails for b(s)=(1-s*s)^3. This is a shape design,
        // not a measured peak-width ratio.
        static let chinPeakSeparationRatio = 0.66
        static let chinPeakRadiusHeightFraction = 0.57
        static let vRadial = 0.030
        static let vAnchorY = -0.04
        static let vHeightMouthToChinFraction = 0.65
        // A narrow peak-only fit misses the approximately 2 px central tail.
        // This width preserves that independent constraint as a reviewable
        // compromise; the full protected output still needs a pair comparison.
        static let vRadiusWidthFraction = 1.50
        static let vRadiusHeightFraction = 0.70
    }

    init?(width: Int, height: Int, face: FaceGeometry) {
        guard width > 4, height > 4,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              face.freshness == .fresh,
              let observed = face.observedFaceSupport,
              let left = face.leftEyeSupport, let right = face.rightEyeSupport,
              left.side == .left, right.side == .right,
              let observedLips = face.observedOuterLips,
              (7...32).contains(observed.contour.count),
              (4...32).contains(left.contour.count), (4...32).contains(right.contour.count),
              (4...40).contains(observedLips.count),
              (observed.contour + left.contour + right.contour + observedLips).allSatisfy(Self.valid),
              Set(observed.contour).count == observed.contour.count,
              Set(left.contour).count >= 4, Set(right.contour).count >= 4,
              Set(observedLips).count >= 4 else { return nil }
        let admittedPoseScale: Double
        if let dense = face.denseSupport {
            guard dense.geometryScale.isFinite, dense.geometryScale > 0 else { return nil }
            // Dense support's compatibility initializer treats an unavailable
            // pose as full strength. A supplied transform must still be a
            // proper pose: a shear cannot use that compatibility fallback.
            if let matrix = dense.mesh.facialTransformation,
               BeautyDenseFaceSupport.poseScale(matrix) == nil { return nil }
            admittedPoseScale = Double(min(1, dense.geometryScale))
        } else {
            admittedPoseScale = 1
        }
        let w = Double(width), h = Double(height)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x) * w - 0.5, Double(p.y) * h - 0.5)
        }
        func mean(_ path: [SIMD2<Float>]) -> SIMD2<Double> {
            path.map(pixel).reduce(.zero, +) / Double(path.count)
        }
        let leftCenter = mean(left.contour), rightCenter = mean(right.contour)
        let direction = rightCenter - leftCenter
        let length = hypot(direction.x, direction.y)
        // The eye pair owns a roll-aware frame. Nearly vertical, inverted or
        // collapsed pairs cannot establish the supported frontal geometry.
        guard length >= 6, length >= Double(min(width, height)) * 0.04,
              direction.x > length * 0.35 else { return nil }
        let xAxis = direction / length, yAxis = SIMD2(-xAxis.y, xAxis.x)
        let center = (leftCenter + rightCenter) * 0.5
        func local(_ p: SIMD2<Float>) -> SIMD2<Double> {
            let delta = pixel(p) - center
            return SIMD2(Self.dot(delta, xAxis), Self.dot(delta, yAxis)) / length
        }
        let eyeL = left.contour.map(local), eyeR = right.contour.map(local)
        let lipPath = observedLips.map(local)
        var contour = observed.contour.map(local)
        if contour[0].x > contour[contour.count - 1].x { contour.reverse() }
        guard let lowX = contour.map(\.x).min(), let highX = contour.map(\.x).max(),
              let index = contour.indices.max(by: { contour[$0].y < contour[$1].y }),
              index >= 2, index <= contour.count - 3 else { return nil }
        let chin = contour[index], span = highX - lowX
        let mouth = lipPath.reduce(.zero, +) / Double(lipPath.count)
        guard span > 1.15, span < 3.8, chin.y > 0.65, chin.y < 3.5,
              abs(chin.x) < span * 0.18,
              contour[0].x < -0.55, contour[contour.count - 1].x > 0.55,
              abs(contour[0].x / contour[contour.count - 1].x) > 0.45,
              abs(contour[0].x / contour[contour.count - 1].x) < 2.2,
              contour[0].y < chin.y * 0.55, contour[contour.count - 1].y < chin.y * 0.55,
              abs(contour[0].y - contour[contour.count - 1].y) < chin.y * 0.35,
              mouth.y > 0.25, mouth.y < chin.y - 0.20,
              abs(mouth.x) < 0.30,
              Self.plausibleEye(eyeL), Self.plausibleEye(eyeR),
              Self.pairedEyes(eyeL, eyeR),
              Self.plausibleLips(lipPath),
              Self.simpleOpenPath(contour),
              Self.descends(Array(contour[...index])),
              Self.descends(Array(contour[index...].reversed())) else { return nil }
        // Require the observed mouth to remain inside both independently
        // visible sides. This rejects side/profile or detached lip geometry.
        guard let leftAtMouth = Self.sidePoint(contour: contour, apex: index, side: -1, y: mouth.y),
              let rightAtMouth = Self.sidePoint(contour: contour, apex: index, side: 1, y: mouth.y),
              lipPath.allSatisfy({ $0.x > leftAtMouth.x + 0.06 && $0.x < rightAtMouth.x - 0.06 })
        else { return nil }

        let nose: [SIMD2<Double>]?
        if let observedNose = face.observedNoseSupport {
            let crest = observedNose.crest.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
            let border = observedNose.contour.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
            guard (3...32).contains(crest.count), (3...32).contains(border.count),
                  (crest + border).allSatisfy(Self.valid), Set(crest).count >= 3, Set(border).count >= 3
            else { return nil }
            let path = (crest + border).map(local)
            guard path.allSatisfy({ abs($0.x) < 0.55 && $0.y > -0.25 && $0.y < mouth.y + 0.08 })
            else { return nil }
            // A small central observed nasal region, rather than the complete
            // bounding box of the nose, owns width's conservative exact core.
            let nasalCenter = path.reduce(.zero, +) / Double(path.count)
            nose = path.map { nasalCenter + ($0 - nasalCenter) * 0.35 }
        } else {
            nose = nil
        }
        self.width = width; self.height = height
        origin = center; axisX = xAxis; axisY = yAxis; scale = length
        normalizedContour = contour; self.chin = chin; self.mouth = mouth
        leftEye = eyeL; rightEye = eyeR; lips = lipPath; nasalCore = nose; apex = index
        poseScale = admittedPoseScale
    }

    func local(_ pixel: SIMD2<Double>) -> SIMD2<Double> {
        let delta = pixel - origin
        return SIMD2(Self.dot(delta, axisX), Self.dot(delta, axisY)) / scale
    }

    func image(_ local: SIMD2<Double>) -> SIMD2<Double> {
        origin + scale * (axisX * local.x + axisY * local.y)
    }

    func model(strengths: BeautyEffectiveStrengths,
               hairlineSupport: BeautyHairlineDisplacement.Support? = nil) -> BeautyFaceDisplacementModel? {
        guard strengths.faceSlim.isFinite, strengths.faceSmall.isFinite,
              strengths.faceContourSmooth.isFinite, strengths.templeFullness.isFinite,
              strengths.cheekboneSlim.isFinite, strengths.chinLength.isFinite,
              strengths.chinTaper.isFinite, strengths.faceVShape.isFinite,
              strengths.jawSlim.isFinite, strengths.hairlineHeight.isFinite else { return nil }
        let widthAmount = Self.clamp(Double(strengths.faceSlim) / 0.60, -1, 1) * poseScale
        let smallAmount = Self.clamp(Double(strengths.faceSmall) / 0.45, -1, 1) * poseScale
        let smoothAmount = Self.clamp(Double(strengths.faceContourSmooth) / 0.25, 0, 1) * poseScale
        let templeAmount = Self.clamp(Double(strengths.templeFullness) / Double(BeautySafetyCaps.templeFullness), -1, 1) * poseScale
        let cheekAmount = Self.clamp(Double(strengths.cheekboneSlim) / Double(BeautySafetyCaps.cheekboneSlim), -1, 1) * poseScale
        let lengthAmount = Self.clamp(Double(strengths.chinLength) / Double(BeautySafetyCaps.chinLength), -1, 1) * poseScale
        let taperAmount = Self.clamp(Double(strengths.chinTaper) / Double(BeautySafetyCaps.chinTaper), -1, 1) * poseScale
        let vAmount = Self.clamp(Double(strengths.faceVShape) / Double(BeautySafetyCaps.faceVShape), 0, 1) * poseScale
        let jawAmount = Self.clamp(Double(strengths.jawSlim) / Double(BeautySafetyCaps.jawSlim), -1, 1) * poseScale
        let hairlineAmount = Self.clamp(Double(strengths.hairlineHeight) / Double(BeautySafetyCaps.hairlineHeight), -1, 1) * poseScale
        var components = [Model.Component]()
        if widthAmount != 0 {
            guard let component = widthComponent(amount: widthAmount) else { return nil }
            components.append(component)
        }
        if smallAmount != 0 {
            guard let component = smallComponent(amount: smallAmount) else { return nil }
            components.append(component)
        }
        if smoothAmount != 0 {
            guard let component = smoothComponent(amount: smoothAmount) else { return nil }
            components.append(component)
        }
        if templeAmount != 0 {
            guard let component = templeComponent(amount: templeAmount) else { return nil }
            components.append(component)
        }
        if cheekAmount != 0 {
            guard let component = cheekComponent(amount: cheekAmount) else { return nil }
            components.append(component)
        }
        if lengthAmount != 0 {
            guard let component = chinLengthComponent(amount: lengthAmount) else { return nil }
            components.append(component)
        }
        if taperAmount != 0 {
            guard let component = chinTaperComponent(amount: taperAmount) else { return nil }
            components.append(component)
        }
        if vAmount != 0 {
            guard let component = vComponent(amount: vAmount) else { return nil }
            components.append(component)
        }
        var admittedJaw = false
        if jawAmount != 0,
           let protections = fiveFieldProtections(protectMouth: true, protectChin: true),
           let component = BeautyJawAngleDisplacement.component(
                    contour: normalizedContour, chin: chin, amount: jawAmount,
                    protections: protections, supported: supported) {
            components.append(component)
            admittedJaw = true
        }
        // A refused source hairline support only removes that component. It
        // cannot erase independently admitted siblings or revive the old band.
        if hairlineAmount != 0, let hairlineSupport,
           let component = BeautyHairlineDisplacement.component(support: hairlineSupport, amount: hairlineAmount) {
            components.append(component)
        }
        // Preserve the established three-control certificate and amplitude
        // exactly when none of the new controls participates. The new fields
        // need local interval enclosures to avoid paying for disjoint peaks
        // and protection transitions at the same hypothetical source point.
        let refine = templeAmount != 0 || cheekAmount != 0 || lengthAmount != 0 ||
            taperAmount != 0 || vAmount != 0 || admittedJaw || (hairlineAmount != 0 && hairlineSupport != nil)
        return Model(components: components, refineGradientBound: refine)
    }

    private func widthComponent(amount: Double) -> Model.Component? {
        guard let nose = nasalProtection() else { return nil }
        var modes = [Model.Mode]()
        let cheekY = mouth.y * 0.60
        let jawY = mouth.y + (chin.y - mouth.y) * 0.48
        for side in [-1.0, 1.0] {
            guard let cheek = sidePoint(side, y: cheekY), let jaw = sidePoint(side, y: jawY) else { return nil }
            // Four fixed, smooth source windows, with shared left/right
            // amplitudes. Wider lower windows overlap weakly at chin centre.
            let cheekWindow = window(center: cheek,
                radius: SIMD2(abs(cheek.x) * 0.84, max(0.50, chin.y * 0.52)))
            let jawWindow = window(center: jaw,
                radius: SIMD2(abs(jaw.x) * 1.14, max(0.40, (chin.y - mouth.y) * 0.95)))
            guard supported(cheekWindow), supported(jawWindow) else { return nil }
            modes.append(.vector(weight: cheekWindow, displacement: SIMD2(-side * 0.13 * amount, 0)))
            modes.append(.vector(weight: jawWindow, displacement: SIMD2(0, -0.10 * amount)))
        }
        return Model.Component(modes: modes, protections: [nose])
    }

    private func smallComponent(amount: Double) -> Model.Component? {
        guard let left = eyeProtection(leftEye), let right = eyeProtection(rightEye) else { return nil }
        let halfWidth = normalizedContour.map { abs($0.x) }.max() ?? 0
        let anchor = max(0.08, mouth.y * 0.15)
        let mouthToChin = chin.y - mouth.y
        // This continuation is a candidate source-box neck transition, not a
        // detected neck boundary. Missing image margin rejects the component;
        // it is never silently clipped at the chin or image edge.
        let horizontalBottom = chin.y + max(0.25, mouthToChin * 0.40)
        let verticalBottom = chin.y + max(0.45, mouthToChin * 0.85)
        let horizontal = window(center: SIMD2(0, (anchor + horizontalBottom) * 0.5),
            radius: SIMD2(halfWidth * 1.15, (horizontalBottom - anchor) * 0.5), innerFraction: 0.50)
        let vertical = window(center: SIMD2(0, (anchor + verticalBottom) * 0.5),
            radius: SIMD2(halfWidth * 1.10, (verticalBottom - anchor) * 0.5), innerFraction: 0.50)
        guard supported(horizontal), supported(vertical) else { return nil }
        return Model.Component(modes: [.smallFace(horizontal: horizontal, vertical: vertical,
            horizontalAmount: 0.13 * amount, verticalAmount: 0.14 * amount, anchorY: anchor)],
            protections: [left, right])
    }

    private func smoothComponent(amount: Double) -> Model.Component? {
        guard let left = eyeProtection(leftEye), let right = eyeProtection(rightEye),
              let nose = nasalProtection(),
              let mouth = coreProtection(lips, fraction: 0.55, padding: SIMD2(0.06, 0.05))
        else { return nil }
        var modes = [Model.Mode]()
        // Only the lower pair is supported by current independent evidence.
        // An upper opposite pair needs new reliable correspondences before it
        // becomes a transferable rule. No curvature or RGB residual drives it.
        let level = self.mouth.y + (chin.y - self.mouth.y) * 0.28
        for side in [-1.0, 1.0] {
            guard let p = sidePoint(side, y: level), let basis = sideBasis(side, y: level) else { return nil }
            let support = Model.Window(center: p, axisX: basis.tangent, axisY: basis.normal,
                radius: SIMD2(max(0.28, (chin.y - self.mouth.y) * 0.72), 0.27))
            guard supported(support) else { return nil }
            modes.append(.vector(weight: support, displacement: basis.normal * (-0.025 * amount)))
        }
        return Model.Component(modes: modes, protections: [left, right, nose, mouth])
    }

    private func templeComponent(amount: Double) -> Model.Component? {
        guard let protections = fiveFieldProtections(protectMouth: true, protectChin: true) else { return nil }
        let anchor = SIMD2(chin.x, mouth.y * FiveFieldDefaults.templeAnchorMouthFraction)
        var modes = [Model.Mode]()
        for endpoint in [normalizedContour[0], normalizedContour[normalizedContour.count - 1]] {
            // The observed upper face-side endpoints locate each support. The
            // small upward continuation includes adjacent skin/hair; it is not
            // an independently detected temple boundary or a binary skin mask.
            let side = endpoint.x < chin.x ? -1.0 : 1.0
            let center = endpoint - SIMD2(side * FiveFieldDefaults.templeInwardFromContour,
                                          FiveFieldDefaults.templeAboveContour)
            let support = window(center: center, radius: FiveFieldDefaults.templeRadius)
            guard supported(support), center.y < anchor.y else { return nil }
            let coefficient = FiveFieldDefaults.templeRadial * amount
            modes.append(.affine(weight: support, anchor: anchor,
                                 scale: SIMD2(repeating: coefficient), translation: .zero))
        }
        return Model.Component(modes: modes, protections: protections)
    }

    private func cheekComponent(amount: Double) -> Model.Component? {
        guard let protections = fiveFieldProtections(protectMouth: true, protectChin: true) else { return nil }
        let level = mouth.y * FiveFieldDefaults.cheekHeightMouthFraction
        // Both windows share a direction anchor independent of their peak
        // height. Vertical contraction changes sign across the anchor.
        let anchor = SIMD2(chin.x, mouth.y * FiveFieldDefaults.cheekAnchorMouthFraction)
        var modes = [Model.Mode]()
        for side in [-1.0, 1.0] {
            guard let center = sidePoint(side, y: level) else { return nil }
            let support = window(center: center, radius: FiveFieldDefaults.cheekRadius)
            guard supported(support) else { return nil }
            let coefficient = -FiveFieldDefaults.cheekRadial * amount
            modes.append(.affine(weight: support, anchor: anchor,
                                 scale: SIMD2(repeating: coefficient), translation: .zero))
        }
        return Model.Component(modes: modes, protections: protections)
    }

    private func chinLengthComponent(amount: Double) -> Model.Component? {
        // The lower lip edge and nearby neck are permitted to follow the
        // field. Protecting the whole mouth would erase the measured ingress.
        guard let protections = fiveFieldProtections(protectMouth: false, protectChin: false) else { return nil }
        let gap = chin.y - mouth.y
        let top = mouth.y + gap * FiveFieldDefaults.chinLengthUpperStart
        let plateauStart = mouth.y + gap * FiveFieldDefaults.chinLengthPlateauStart
        let plateauEnd = chin.y + gap * FiveFieldDefaults.chinLengthPlateauBelow
        let bottom = chin.y + max(FiveFieldDefaults.chinLengthMinimumRelease,
                                  gap * FiveFieldDefaults.chinLengthReleaseBelow)
        let shoulderLevel = mouth.y + gap * 0.45
        guard let left = sidePoint(-1, y: shoulderLevel), let right = sidePoint(1, y: shoulderLevel) else { return nil }
        let halfWidth = max(abs(left.x - chin.x), abs(right.x - chin.x))
        let center = SIMD2(chin.x, (top + bottom) * 0.5)
        let radius = SIMD2(max(0.80, halfWidth * FiveFieldDefaults.chinLengthRadiusWidthFraction),
                           (bottom - top) * 0.5)
        let plateau = SIMD2((plateauStart - center.y) / radius.y,
                            (plateauEnd - center.y) / radius.y)
        let support = Model.Window(center: center, axisX: SIMD2(1, 0), axisY: SIMD2(0, 1),
                                   radius: radius, verticalPlateau: plateau)
        guard supported(support) else { return nil }
        // Direct API semantics retain negative=shorter/up. Positive elongation
        // is a symmetric engineering extension, not an observed endpoint fit.
        return Model.Component(modes: [.affine(weight: support, anchor: SIMD2(chin.x, 0),
            scale: SIMD2(FiveFieldDefaults.chinLengthHorizontal * amount, 0),
            translation: SIMD2(0, FiveFieldDefaults.chinLengthVertical * amount))],
            protections: protections)
    }

    private func chinTaperComponent(amount: Double) -> Model.Component? {
        guard let protections = fiveFieldProtections(protectMouth: true, protectChin: false) else { return nil }
        let gap = chin.y - mouth.y
        let level = chin.y - gap * FiveFieldDefaults.chinPeakAbove
        guard let left = sidePoint(-1, y: level), let right = sidePoint(1, y: level) else { return nil }
        let delta = (abs(left.x - chin.x) + abs(right.x - chin.x)) * 0.5
        guard delta > 0.04 else { return nil }
        let radius = SIMD2(delta / FiveFieldDefaults.chinPeakSeparationRatio,
                           max(0.38, gap * FiveFieldDefaults.chinPeakRadiusHeightFraction))
        var modes = [Model.Mode]()
        for side in [-1.0, 1.0] {
            // Shared peak shape is an explicit low-freedom design assumption.
            // Overlap gives the centre nonzero vertical motion; only its
            // horizontal components cancel, and no chin core is frozen.
            let support = window(center: SIMD2(chin.x + side * delta, level), radius: radius)
            guard supported(support), abs(chin.y - level) < radius.y else { return nil }
            modes.append(.vector(weight: support,
                displacement: SIMD2(-side * FiveFieldDefaults.chinPeakHorizontal * amount,
                                     -FiveFieldDefaults.chinPeakVertical * amount)))
        }
        return Model.Component(modes: modes, protections: protections)
    }

    private func vComponent(amount: Double) -> Model.Component? {
        guard let protections = fiveFieldProtections(protectMouth: true, protectChin: false) else { return nil }
        let gap = chin.y - mouth.y
        let level = mouth.y + gap * FiveFieldDefaults.vHeightMouthToChinFraction
        let anchor = SIMD2(chin.x, FiveFieldDefaults.vAnchorY)
        var modes = [Model.Mode]()
        for side in [-1.0, 1.0] {
            guard let center = sidePoint(side, y: level) else { return nil }
            let support = window(center: center,
                radius: SIMD2(abs(center.x - chin.x) * FiveFieldDefaults.vRadiusWidthFraction,
                              max(0.49, gap * FiveFieldDefaults.vRadiusHeightFraction)))
            guard supported(support), center.y > anchor.y,
                  support.bounds.contains(chin) else { return nil }
            let coefficient = -FiveFieldDefaults.vRadial * amount
            modes.append(.affine(weight: support, anchor: anchor,
                                 scale: SIMD2(repeating: coefficient), translation: .zero))
        }
        return Model.Component(modes: modes, protections: protections)
    }

    private func fiveFieldProtections(protectMouth: Bool, protectChin: Bool) -> [Model.Protection]? {
        guard let left = eyeProtection(leftEye), let right = eyeProtection(rightEye),
              let nose = nasalProtection() else { return nil }
        var protections = [left, right, nose]
        if protectMouth {
            guard let mouth = coreProtection(lips, fraction: 0.40, padding: SIMD2(0.025, 0.015)) else { return nil }
            protections.append(mouth)
        }
        if protectChin {
            guard let chin = coreProtection([chin], fraction: 0.65, padding: SIMD2(0.07, 0.08)) else { return nil }
            protections.append(chin)
        }
        return protections
    }

    private func window(center: SIMD2<Double>, radius: SIMD2<Double>, innerFraction: Double = 0) -> Model.Window {
        Model.Window(center: center, axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), radius: radius,
                     innerFraction: innerFraction)
    }

    private func nasalProtection() -> Model.Protection? {
        guard let nasalCore else { return nil }
        return coreProtection(nasalCore, fraction: 0.70, padding: SIMD2(0.05, 0.06))
    }

    private func eyeProtection(_ points: [SIMD2<Double>]) -> Model.Protection? {
        // Protect the aperture's conservative central core, not a full eye-
        // region box or an eyelid/eyebrow envelope.
        coreProtection(points, fraction: 0.55, padding: SIMD2(0.035, 0.025))
    }

    private func coreProtection(_ points: [SIMD2<Double>], fraction: Double,
                                padding: SIMD2<Double>) -> Model.Protection? {
        guard let minX = points.map(\.x).min(), let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(), let maxY = points.map(\.y).max() else { return nil }
        let center = SIMD2((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        let radius = SIMD2(max(0.04, (maxX - minX) * 0.5) + padding.x,
                           max(0.025, (maxY - minY) * 0.5) + padding.y)
        let support = window(center: center, radius: radius)
        guard supported(support) else { return nil }
        return Model.Protection(window: support, innerFraction: fraction)
    }

    private func supported(_ support: Model.Window) -> Bool {
        // Checking all rotated rectangle corners proves containment of the
        // complete product support in the convex image domain. A bilinear-tap
        // margin remains on every edge, including rolled images.
        for x in [-1.0, 1.0] { for y in [-1.0, 1.0] {
            let p = image(support.center + support.axisX * (support.radius.x * x) +
                          support.axisY * (support.radius.y * y))
            guard p.x >= 2, p.y >= 2, p.x <= Double(width - 3), p.y <= Double(height - 3) else { return false }
        } }
        return true
    }

    private func sidePoint(_ side: Double, y: Double) -> SIMD2<Double>? {
        Self.sidePoint(contour: normalizedContour, apex: apex, side: side, y: y)
    }

    private static func sidePoint(contour: [SIMD2<Double>], apex: Int, side: Double,
                                  y: Double) -> SIMD2<Double>? {
        let path = side < 0 ? Array(contour[...apex]) : Array(contour[apex...].reversed())
        for i in 0..<(path.count - 1) {
            let a = path[i], b = path[i + 1]
            if a.y <= y && b.y >= y && b.y - a.y > 1e-8 {
                let point = a + (b - a) * ((y - a.y) / (b.y - a.y))
                return side * point.x > 0.04 ? point : nil
            }
        }
        return nil
    }

    private func sideBasis(_ side: Double, y: Double) -> (tangent: SIMD2<Double>, normal: SIMD2<Double>)? {
        let radius = min(0.14, (chin.y - mouth.y) * 0.2)
        guard let a = sidePoint(side, y: y - radius), let b = sidePoint(side, y: y + radius) else { return nil }
        let difference = b - a, length = hypot(difference.x, difference.y)
        guard length > 0.04 else { return nil }
        let tangent = difference / length
        var normal = SIMD2(tangent.y, -tangent.x)
        if normal.x * side < 0 { normal = -normal }
        return (tangent, normal)
    }

    private static func plausibleEye(_ points: [SIMD2<Double>]) -> Bool {
        guard let x0 = points.map(\.x).min(), let x1 = points.map(\.x).max(),
              let y0 = points.map(\.y).min(), let y1 = points.map(\.y).max() else { return false }
        return (0.15...0.85).contains(x1 - x0) && (0.025...0.50).contains(y1 - y0)
    }

    private static func plausibleLips(_ points: [SIMD2<Double>]) -> Bool {
        guard let x0 = points.map(\.x).min(), let x1 = points.map(\.x).max(),
              let y0 = points.map(\.y).min(), let y1 = points.map(\.y).max() else { return false }
        // These are outer-path plausibility bounds only; an outer lip trace
        // cannot prove a closed mouth or qualify an arbitrary expression.
        return (0.20...1.20).contains(x1 - x0) && (0.025...0.55).contains(y1 - y0)
    }

    private static func pairedEyes(_ left: [SIMD2<Double>], _ right: [SIMD2<Double>]) -> Bool {
        func span(_ points: [SIMD2<Double>]) -> SIMD2<Double> {
            SIMD2(points.map(\.x).max()! - points.map(\.x).min()!,
                  points.map(\.y).max()! - points.map(\.y).min()!)
        }
        // Positive spans were established by plausibleEye before this call.
        let a = span(left), b = span(right)
        return (0.55...1.8).contains(a.x / b.x) && (0.4...2.5).contains(a.y / b.y)
    }

    private static func descends(_ path: [SIMD2<Double>]) -> Bool {
        zip(path, path.dropFirst()).allSatisfy { $1.y >= $0.y - 0.035 && hypot(($1 - $0).x, ($1 - $0).y) > 1e-5 }
    }

    private static func simpleOpenPath(_ points: [SIMD2<Double>]) -> Bool {
        guard points.count > 3 else { return false }
        func cross(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x * b.y - a.y * b.x }
        for i in 0..<(points.count - 3) {
            for j in (i + 2)..<(points.count - 1) {
                let a = points[i], b = points[i + 1], c = points[j], d = points[j + 1]
                let u = cross(b - a, c - a), v = cross(b - a, d - a)
                let w = cross(d - c, a - c), x = cross(d - c, b - c)
                if u * v <= 0 && w * x <= 0,
                   max(min(a.x,b.x), min(c.x,d.x)) <= min(max(a.x,b.x), max(c.x,d.x)),
                   max(min(a.y,b.y), min(c.y,d.y)) <= min(max(a.y,b.y), max(c.y,d.y)) { return false }
            }
        }
        return true
    }

    private static func valid(_ p: SIMD2<Float>) -> Bool {
        p.x.isFinite && p.y.isFinite && p.x >= 0 && p.x <= 1 && p.y >= 0 && p.y <= 1
    }
    private static func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x * b.x + a.y * b.y }
    private static func clamp(_ value: Double, _ low: Double, _ high: Double) -> Double { min(high, max(low, value)) }
}
