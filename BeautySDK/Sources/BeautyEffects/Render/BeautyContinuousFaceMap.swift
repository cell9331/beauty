import BeautyCore
import BeautyDetection
import Foundation

/// Continuous, source-anchored contour band. A normalized sum of point pulls
/// is deliberately avoided: nearest-curve displacement remains independent of
/// detector point density. All coordinates and pixels expire with the request.
struct BeautyContinuousFaceMap {
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] { [
        \.faceSlim, \.faceSmall, \.jawSlim, \.faceVShape, \.templeFullness,
        \.cheekboneSlim, \.chinLength, \.chinTaper
    ] }
    static func replacesLegacy(for face: FaceGeometry) -> Bool {
        face.observedFaceSupport != nil && face.observedOuterLips != nil
    }
    static func requiresSourceOwnershipProof(face: FaceGeometry, strengths: BeautyEffectiveStrengths) -> Bool {
        face.observedFaceSupport != nil && face.observedOuterLips != nil &&
            face.observedNoseSupport != nil && face.observedEyebrowSupport != nil &&
            (strengths.faceSlim != 0 || strengths.templeFullness != 0 || strengths.cheekboneSlim != 0)
    }
    private let xs: [Double]
    private let ys: [Double]
    private let offsets: [SIMD2<Double>]
    private let protection: [Box]
    private let attachments: BeautySourceContourAttachments.Evidence?
    private let ownership: BeautyFaceSourceOwnership.Evidence?
    private let transitionScope: BeautyContourTransitionScope?
    private let sourceContour: [SIMD2<Double>]
    private let interiorRadiusSquared: Double
    private let exteriorRadiusSquared: Double
    let width: Int
    let height: Int
    let maximumGradient: Double
    let maximumDisplacement: Double
    let capGradientBeforeFinalBound: Double
    let minimumLatticeSpacing: Double
    let qualifiedAttachmentSideCount: Int
    let recoveredInnerSkinSideCount: Int
    let recoveredDepartureSkinSideCount: Int
    let reversedCapDirectionNodeCount: Int

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths,
          sourceRGBA: [UInt8]? = nil, transitionScope: BeautyContourTransitionScope? = nil) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              face.freshness == .fresh,
              let support = face.observedFaceSupport,
              let registeredMouth = face.observedOuterLips,
              (7...32).contains(support.contour.count),
              support.contour.allSatisfy(Self.valid),
              Self.keys.contains(where: { strengths[keyPath: $0] != 0 }),
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite })
        else { return nil }
        let w = Double(width), h = Double(height)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * w, Double(p.y) * h) }
        let left = face.leftEyeSupport?.contour ?? face.leftEye
        let right = face.rightEyeSupport?.contour ?? face.rightEye
        let mouth = registeredMouth
        guard left.count >= 4, right.count >= 4, mouth.count >= 4,
              (left + right + mouth).allSatisfy(Self.valid) else { return nil }
        // A closed aperture alone does not cover the complete eyelid, and an
        // outer-lip trace does not include its immediate material rim. Reserve
        // source-scale collars before composing the contour field.
        var featurePaths: [(points: [SIMD2<Float>], collar: Double)] = [
            (left, 0.055), (right, 0.055), (mouth, 0.08)
        ]
        if let nasal = face.observedNoseSupport {
            let crest = nasal.crest.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
            let contour = nasal.contour.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
            guard (3...32).contains(crest.count), (3...32).contains(contour.count),
                  (crest + contour).allSatisfy(Self.valid),
                  Set(crest).count >= 3, Set(contour).count >= 3 else { return nil }
            var nasalEnvelope = crest + contour
            if let dense = face.denseSupport {
                let envelope = BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseCrest)
                    + BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseContour)
                guard envelope.allSatisfy(Self.valid), Set(envelope).count >= 3 else { return nil }
                nasalEnvelope += envelope
            }
            featurePaths.append((nasalEnvelope, 0.008))
        } else {
            // Retain coarse compatibility without inventing a new nasal path.
            // No observed support means this protects only the supplied legacy
            // geometry, not a complete observed nasal envelope.
            let legacyNose = face.nose + face.noseRoot + face.noseTip
            if !legacyNose.isEmpty {
                guard legacyNose.allSatisfy(Self.valid), Set(legacyNose).count >= 3 else { return nil }
                featurePaths.append((legacyNose, 0.008))
            }
        }
        if let brows = face.observedEyebrowSupport {
            guard let leftBrow = brows.left, let rightBrow = brows.right,
                  leftBrow.side == .left, rightBrow.side == .right else { return nil }
            for (brow, indices) in zip([leftBrow, rightBrow],
                                      [MediaPipeFaceTopology.leftBrowEnvelope, MediaPipeFaceTopology.rightBrowEnvelope]) {
                guard (2...16).contains(brow.points.count), Set(brow.points).count >= 2,
                      (brow.points + [brow.innerEndpoint, brow.outerEndpoint, brow.center])
                        .allSatisfy(Self.valid) else { return nil }
                var browEnvelope = brow.points
                // Observed support owns dense topology. An arbitrary synthetic
                // mesh without observed brows cannot supply an anatomical rim.
                if let dense = face.denseSupport {
                    let envelope = BeautyDenseFaceSupport.path(dense.mesh, indices)
                    guard envelope.allSatisfy(Self.valid), Set(envelope).count >= 3 else { return nil }
                    browEnvelope += envelope
                }
                featurePaths.append((browEnvelope, 0.045))
            }
        }
        func mean(_ points: [SIMD2<Float>]) -> SIMD2<Double> {
            points.map(pixel).reduce(.zero, +) / Double(points.count)
        }
        let eyeVector = mean(right) - mean(left)
        let eyeDistance = hypot(eyeVector.x, eyeVector.y)
        guard eyeDistance >= 4 else { return nil }
        let axisX = eyeVector / eyeDistance
        let axisY = SIMD2(-axisX.y, axisX.x)
        let origin = (mean(left) + mean(right)) * 0.5
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        var contour = support.contour.map { local(pixel($0)) }
        guard let lowX = contour.map(\.x).min(), let highX = contour.map(\.x).max(),
              let chinY = contour.map(\.y).max(), chinY > eyeDistance * 0.4,
              highX - lowX > eyeDistance * 1.1,
              highX - lowX < eyeDistance * 4 else { return nil }
        let span = highX - lowX
        // An internal source-fixed experiment only. It does not replace the
        // strict default or qualify ears from a face oval. Its caller must
        // independently verify permanent source semantics for the entire tube.
        if let transitionScope {
            guard transitionScope.matches(width: width, height: height,
                    contour: support.contour.map(pixel)),
                  let sourceRGBA, sourceRGBA.count == width * height * 4,
                  stride(from: 3, to: sourceRGBA.count, by: 4).allSatisfy({ sourceRGBA[$0] == 255 }),
                  face.observedNoseSupport != nil, face.observedEyebrowSupport != nil,
                  Self.keys.allSatisfy({ $0 == \.faceSlim || strengths[keyPath: $0] == 0 })
            else { return nil }
        }
        if contour[0].x > contour.last!.x { contour.reverse() }
        let scopedKeys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] = [
            \.faceSlim, \.templeFullness, \.cheekboneSlim
        ]
        let requestedFaceKeys = Self.keys.filter { strengths[keyPath: $0] != 0 }
        var sourceOwnership: BeautyFaceSourceOwnership.Evidence?
        if transitionScope == nil, sourceRGBA != nil, face.observedNoseSupport != nil, face.observedEyebrowSupport != nil,
           requestedFaceKeys.contains(where: { scopedKeys.contains($0) }) {
            guard requestedFaceKeys.allSatisfy({ scopedKeys.contains($0) }) else { return nil }
            // This evidence owns fixed source coordinates. Another geometry
            // stage could move those materials before this sampler. Admit only
            // the lateral fields and independent pixel-color work; unknown or
            // future geometry combinations must not reuse stale ownership.
            var remaining = strengths
            for key in scopedKeys { remaining[keyPath: key] = 0 }
            let colorKeys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] = [
                \.skinWhitening, \.skinRosy,
                \.brightness, \.contrast, \.saturation, \.temperature, \.tint,
                \.exposure, \.highlight, \.shadow, \.filterIntensity, \.lipColor
            ]
            for key in colorKeys { remaining[keyPath: key] = 0 }
            guard remaining == BeautyEffectiveStrengths() else { return nil }
            var controls = Set<BeautyFaceSourceOwnership.Control>()
            if strengths.faceSlim != 0 { controls.insert(.faceWidth) }
            if strengths.templeFullness != 0 { controls.insert(.temple) }
            if strengths.cheekboneSlim != 0 { controls.insert(.cheekbone) }
            // Complete material evidence is mandatory for this source-aware
            // lateral route. Missing proof cannot revive unprotected sampling.
            guard let evidence = BeautyFaceSourceOwnership.qualify(sourceRGBA: sourceRGBA,
                width: width, height: height, face: face, controls: controls) else { return nil }
            sourceOwnership = evidence
        }
        var attachmentEvidence: BeautySourceContourAttachments.Evidence?
        // The upper contour joins the fixed lateral head attachments. With
        // paired observed brows and nasal support, reserve a conservative
        // collar outside those joins; the jaw below it remains editable.
        // This is a geometric exclusion, not an ear or hair segmentation.
        if transitionScope == nil, let nasal = face.observedNoseSupport, face.observedEyebrowSupport != nil {
            let bottom = (nasal.crest + nasal.contour).map {
                local(pixel(SIMD2(Float($0.x), Float($0.y)))).y
            }.max() ?? 0
            let y0 = -span * 0.04
            let y1 = min(chinY * 0.48, max(0, bottom) + span * 0.04)
            if y1 > y0 {
                attachmentEvidence = BeautySourceContourAttachments.qualify(sourceRGBA: sourceRGBA,
                    width: width, height: height, contour: contour, origin: origin,
                    axisX: axisX, axisY: axisY, span: span, chin: chinY,
                    attachmentBottom: max(0, bottom) + span * 0.04)
                for (endpoint, side) in [(contour[0], -1.0), (contour.last!, 1.0)] {
                    let recovered = side < 0 ? attachmentEvidence?.left.hasRecoveredReserve : attachmentEvidence?.right.hasRecoveredReserve
                    if recovered == true { continue }
                    let outer = endpoint.x + side * span * 0.24
                    let inner = endpoint.x - side * span * 0.08
                    let imagePoints = [SIMD2(outer, y0), SIMD2(inner, y0),
                                       SIMD2(inner, y1), SIMD2(outer, y1)].map { p in
                        let image = origin + axisX * p.x + axisY * p.y
                        return SIMD2<Float>(Float(image.x / w), Float(image.y / h))
                    }
                    // Clipped, source-bounded corners preserve tilted photos.
                    featurePaths.append((imagePoints.map {
                        SIMD2(min(1, max(0, $0.x)), min(1, max(0, $0.y)))
                    }, 0.008))
                }
            }
        }
        // Reference/playbook temple support is above the outer eye. Vision's
        // open jaw path does not include it: extend only the two upper sides,
        // explicitly as a 2-D approximation, never as hair segmentation.
        let first = contour[0], last = contour.last!
        contour = [SIMD2(first.x * 0.96, -chinY * 0.32),
                   SIMD2(first.x, -chinY * 0.12)] + contour +
                  [SIMD2(last.x, -chinY * 0.12), SIMD2(last.x * 0.96, -chinY * 0.32)]
        // Fixed parameter samples of a C1 Hermite path. Smooth displacement is a
        // function of anatomy, not the number/spacing of detector landmarks.
        var curve = [SIMD2<Double>]()
        for i in 0..<(contour.count - 1) {
            let a = contour[i], b = contour[i + 1]
            let m0 = (b - contour[max(0, i - 1)]) * 0.5
            let m1 = (contour[min(contour.count - 1, i + 2)] - a) * 0.5
            for k in 0..<4 {
                let t = Double(k) / 4, t2 = t * t, t3 = t2 * t
                curve.append(a * (2*t3 - 3*t2 + 1) + m0 * (t3 - 2*t2 + t)
                    + b * (-2*t3 + 3*t2) + m1 * (t3 - t2))
            }
        }
        curve.append(contour.last!)
        let innerRadius = max(0, span * 0.20 - 0.002)
        let outerRadius = max(0, span * 0.06 - 0.002)
        let radius = max(innerRadius, outerRadius)
        func imagePoint(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
        let imageCurve = curve.map(imagePoint)
        let minX = max(0, imageCurve.map(\.x).min()! - radius)
        let maxX = min(w, imageCurve.map(\.x).max()! + radius)
        let minY = max(0, imageCurve.map(\.y).min()! - radius)
        let maxY = min(h, imageCurve.map(\.y).max()! + radius)
        guard maxX > minX, maxY > minY else { return nil }
        // Full feature boxes are zero-displacement regions. Their edges are
        // required lattice knots so interpolation cannot bleed across them.
        let boxes = featurePaths.map { Box(points: $0.points.map(pixel), padding: max(2, span * $0.collar)) }
        let feather = span * 0.07
        func axis(_ lo: Double, _ hi: Double, _ edges: [Double]) -> [Double] {
            let ordered = Array(Set((0...128).map { lo + (hi - lo) * Double($0) / 128 }
                + edges.filter { $0 > lo && $0 < hi })).sorted()
            // Several independent feature edges can differ by hundredths of
            // a source pixel. They represent one protected texel boundary;
            // retaining an ill-conditioned cell between them amplifies round-
            // off in the local gradient projection. Whole-texel protection
            // below still owns the exact, unrounded anatomical envelopes.
            var result = [Double](), cluster = [Double]()
            for value in ordered {
                if let first = cluster.first, value - first >= 0.125 {
                    result.append(cluster[0] == lo ? lo : cluster.reduce(0, +) / Double(cluster.count))
                    cluster = []
                }
                cluster.append(value)
            }
            if !cluster.isEmpty { result.append(cluster.last == hi ? hi : cluster.reduce(0, +) / Double(cluster.count)) }
            return result
        }
        let xs = axis(minX, maxX, boxes.flatMap {
            [$0.minX - feather, $0.minX, $0.maxX, $0.maxX + feather]
        })
        let ys = axis(minY, maxY, boxes.flatMap {
            [$0.minY - feather, $0.minY, $0.maxY, $0.maxY + feather]
        })
        func smooth(_ t: Double) -> Double { let v = min(1, max(0, t)); return v*v*(3-2*v) }
        // A mostly linear C1 ramp spends the finite gradient budget evenly.
        // The ten-percent rounded ends still meet the fixed source pixels
        // with zero derivative; the slope never exceeds 1 / 0.9.
        func ramp(_ t: Double) -> Double {
            let v = min(1, max(0, t)), end = 0.1, slope = 1 / 0.9
            if v < end { return slope * v * v / (2 * end) }
            if v > 1 - end { return 1 - slope * (1 - v) * (1 - v) / (2 * end) }
            return slope * (v - end * 0.5)
        }
        func bell(_ value: Double, _ center: Double, _ reach: Double) -> Double {
            let t = abs(value - center) / reach
            return t < 1 ? pow(1 - t*t, 2) : 0
        }
        func displacement(_ p: SIMD2<Double>, _ values: BeautyEffectiveStrengths) -> SIMD2<Double> {
            let y = p.y / chinY, lateral = min(1, abs(p.x) / (span * 0.30))
            let side = p.x < 0 ? -1.0 : 1.0
            var d = SIMD2<Double>.zero
            let width = Double(values.faceSlim / BeautySafetyCaps.faceSlim)
            d.x -= side * span * 0.035 * width * bell(y, 0.47, 0.64) * lateral
            let jaw = Double(values.jawSlim / BeautySafetyCaps.jawSlim)
            let jawWeight = bell(y, 0.72, 0.35) * lateral
            let jawResponse = jaw < 0 ? 0.4 : 1.0
            d += SIMD2(-side * span * 0.030, -span * 0.008) * (jaw * jawWeight * jawResponse)
            let v = Double(values.faceVShape / BeautySafetyCaps.faceVShape)
            d.x -= side * span * 0.035 * v * bell(y, 0.74, 0.24) * lateral
            d.y -= span * 0.0035 * v * bell(y, 1, 0.27)
            d.x += side * span * 0.020 * Double(values.templeFullness / BeautySafetyCaps.templeFullness) * bell(y, -0.10, 0.28)
            d.x -= side * span * 0.028 * Double(values.cheekboneSlim / BeautySafetyCaps.cheekboneSlim) * bell(y, 0.22, 0.32)
            let taper = Double(values.chinTaper / BeautySafetyCaps.chinTaper)
            d.x -= p.x * (taper < 0 ? 0.24 : 0.14) * taper * smooth((y - 0.58) / 0.36)
            d.y += span * 0.008 * Double(values.chinTaper / BeautySafetyCaps.chinTaper) * bell(y, 1, 0.24)
            d.y += span * 0.028 * Double(values.chinLength / BeautySafetyCaps.chinLength) * bell(y, 1, 0.35)
            return axisX * d.x + axisY * d.y
        }
        func smallFaceInverse(_ q: SIMD2<Double>, _ values: BeautyEffectiveStrengths) -> SIMD2<Double> {
            let small = Double(values.faceSmall / BeautySafetyCaps.faceSmall)
            let lower = smooth((q.y / chinY + 0.04) / 0.30)
            let k = 0.045 * small * lower
            // Destination-to-source inverse scaling, rather than a forward
            // contour displacement evaluated at a nearest detector segment.
            // The lower core remains affine at every slider quarter level.
            let factor = k / (1 - k)
            let d = SIMD2(-q.x, -(q.y - chinY * 0.12)) * factor
            return axisX * d.x + axisY * d.y
        }
        var cap = strengths
        let caps: [Float] = [BeautySafetyCaps.faceSlim, BeautySafetyCaps.faceSmall,
            BeautySafetyCaps.jawSlim, BeautySafetyCaps.faceVShape,
            BeautySafetyCaps.templeFullness, BeautySafetyCaps.cheekboneSlim,
            BeautySafetyCaps.chinLength, BeautySafetyCaps.chinTaper]
        for (key, limit) in zip(Self.keys, caps) where strengths[keyPath: key] != 0 {
            cap[keyPath: key] = strengths[keyPath: key] < 0 ? -limit : limit
        }
        var actual = [SIMD2<Double>](), ceiling = actual
        for y in ys { for x in xs {
            let q = local(SIMD2(x, y))
            var nearest = curve[0], normal = SIMD2<Double>.zero, distance2 = Double.infinity
            for (a, b) in zip(curve, curve.dropFirst()) {
                let v = b - a, vv = v.x*v.x + v.y*v.y
                guard vv > 0 else { continue }
                let t = min(1, max(0, ((q-a).x*v.x + (q-a).y*v.y) / vv))
                let p = a + v*t, diff = q-p, dd = diff.x*diff.x + diff.y*diff.y
                if dd < distance2 {
                    distance2 = dd; nearest = p
                    normal = SIMD2(v.y, -v.x) / sqrt(vv)
                }
            }
            // The original source polyline owns both support and taper. The
            // legitimate narrow outer transition participates in resampling;
            // hard source-material ownership would expose a static old outline.
            var sourceDistance2 = Double.infinity
            for (a, b) in zip(contour, contour.dropFirst()) {
                let v = b - a, length2 = v.x * v.x + v.y * v.y
                guard length2 > 0 else { continue }
                let t = min(1, max(0, ((q - a).x * v.x + (q - a).y * v.y) / length2))
                let residual = q - (a + v * t)
                sourceDistance2 = min(sourceDistance2, residual.x * residual.x + residual.y * residual.y)
            }
            var inside = false
            for i in contour.indices {
                let a = contour[i], b = contour[(i + 1) % contour.count]
                if (a.y > q.y) != (b.y > q.y), q.x < (b.x - a.x) * (q.y - a.y) / (b.y - a.y) + a.x {
                    inside.toggle()
                }
            }
            // Hermite distance owns the smooth shape near the actual outline.
            // Using the raw polyline distance there would imprint its detector
            // segments on the quantized chin. The original polyline only owns
            // a conservative fade near the permitted support's outer boundary.
            let residual = q - nearest
            let curveInside = residual.x * normal.x + residual.y * normal.y >= 0
            let curveRadius = curveInside ? innerRadius : outerRadius
            let weight = curveRadius > 0 ? ramp(1 - sqrt(distance2) / curveRadius) : 0
            // Contraction samples outward from the observed edge. A flat
            // exterior core would shorten that edge's transition and consume
            // its gradient budget before an affine lower-face shrink can act.
            let smallPlateau = curveRadius * (curveInside ? 0.30 : 0)
            let smallWeight = curveRadius > smallPlateau
                ? ramp((curveRadius - sqrt(distance2)) / (curveRadius - smallPlateau)) : 0
            let supportRadius = inside ? innerRadius : outerRadius
            let supportFeather = min(feather, supportRadius * 0.5)
            var protectionWeight = supportFeather > 0
                ? ramp((supportRadius - sqrt(sourceDistance2)) / supportFeather) : 0
            // The open path ends on an inferred upper chord. Taper to zero
            // before that chord so switching inner/outer radii there cannot
            // create a discontinuous temple cap or move unsupported forehead.
            protectionWeight *= ramp((q.y + chinY * 0.32) / feather)
            var featureWeight = 1.0
            for b in boxes {
                featureWeight = min(featureWeight, ramp(b.distance(x: x, y: y) / feather))
            }
            if let attachmentEvidence {
                featureWeight = min(featureWeight, ramp(attachmentEvidence.distanceToReserve(x: x, y: y) / feather))
            }
            if let sourceOwnership {
                featureWeight = min(featureWeight, ramp(sourceOwnership.distanceToReserve(x: x, y: y) / feather))
            }
            protectionWeight *= featureWeight
            if let transitionScope {
                // Use one continuous source geometry before projection. Both
                // transport admission and destination copying use this same
                // tube; a hard final restore cannot enlarge its editable set.
                protectionWeight = featureWeight * ramp(transitionScope.distanceToFixed(x: x, y: y)
                    / max(1, transitionScope.radius * 0.55))
            }
            if x == minX || x == maxX || y == minY || y == maxY { protectionWeight = 0 }
            actual.append((displacement(nearest, strengths) * (transitionScope == nil ? weight : 1) +
                smallFaceInverse(q, strengths) * smallWeight) * protectionWeight)
            ceiling.append((displacement(nearest, cap) * (transitionScope == nil ? weight : 1) +
                smallFaceInverse(q, cap) * smallWeight) * protectionWeight)
        } }
        func gradient(_ deltas: [SIMD2<Double>]) -> Double {
            var result = 0.0
            for row in 0..<(ys.count-1) { for col in 0..<(xs.count-1) {
                let i = row*xs.count+col
                let tl=deltas[i], tr=deltas[i+1], bl=deltas[i+xs.count], br=deltas[i+xs.count+1]
                let dx=xs[col+1]-xs[col], dy=ys[row+1]-ys[row]
                for gx in [(tr-tl)/dx, (br-bl)/dx] {
                    for gy in [(bl-tl)/dy, (br-tr)/dy] {
                        result=max(result, sqrt(gx.x*gx.x + gx.y*gx.y + gy.x*gy.x + gy.y*gy.y))
                    }
                }
            } }
            return result
        }
        let activeKeys = Self.keys.filter { strengths[keyPath: $0] != 0 }
        let unprojectedCap = ceiling
        if let key = activeKeys.first, activeKeys.count == 1, key != \.faceSmall {
            // Project only the offending local gradients onto the existing
            // admissible set. One steep feature collar must not attenuate an
            // unrelated chin or jaw. Fixed source nodes remain Dirichlet zero.
            // The cap owns the shape, so every slider quarter follows the same
            // trajectory instead of changing the projection with strength.
            ceiling = Self.boundedField(ceiling, xs: xs, ys: ys,
                maximumGradient: 0.45, maximumDisplacement: span * 0.06)
            let fraction = Double(strengths[keyPath: key] / cap[keyPath: key])
            actual = ceiling.map { $0 * fraction }
        }
        let g = max(gradient(actual), gradient(ceiling))
        let magnitude = (actual+ceiling).map { hypot($0.x, $0.y) }.max() ?? 0
        guard g.isFinite, magnitude.isFinite, magnitude > 0 else { return nil }
        let pose = Double(face.denseSupport?.geometryScale ?? 1)
        guard pose.isFinite, pose > 0 else { return nil }
        let scale = min(1, g > 0 ? 0.45/g : 1, span*0.06/magnitude) * pose
        self.xs=xs; self.ys=ys; self.width=width; self.height=height
        protection = boxes
        attachments = attachmentEvidence
        ownership = sourceOwnership
        self.transitionScope = transitionScope
        sourceContour = contour.map(imagePoint)
        // The source polyline owns the permitted destination band. Hermite
        // overshoot cannot expand it, including near the open contour's
        // extended temple endpoints. This is geometric transition support,
        // not a semantic claim about materials occupying that band.
        interiorRadiusSquared = innerRadius * innerRadius
        exteriorRadiusSquared = outerRadius * outerRadius
        offsets=actual.map { $0*scale }
        maximumGradient=gradient(actual)*scale
        maximumDisplacement=(actual.map { hypot($0.x, $0.y) }.max() ?? 0)*scale
        capGradientBeforeFinalBound = g
        minimumLatticeSpacing = min(zip(xs, xs.dropFirst()).map { $1 - $0 }.min()!,
            zip(ys, ys.dropFirst()).map { $1 - $0 }.min()!)
        qualifiedAttachmentSideCount = (attachmentEvidence?.left.isQualified == true ? 1 : 0)
            + (attachmentEvidence?.right.isQualified == true ? 1 : 0)
        recoveredInnerSkinSideCount = (attachmentEvidence?.left.hasInnerSkinRecovery == true ? 1 : 0)
            + (attachmentEvidence?.right.hasInnerSkinRecovery == true ? 1 : 0)
        recoveredDepartureSkinSideCount = (attachmentEvidence?.left.hasDepartureSkinRecovery == true ? 1 : 0)
            + (attachmentEvidence?.right.hasDepartureSkinRecovery == true ? 1 : 0)
        reversedCapDirectionNodeCount = zip(unprojectedCap, ceiling).filter { pair in
            pair.0.x * pair.1.x + pair.0.y * pair.1.y < -1e-8
        }.count
    }

    /// Cyclic convex projections of the four cell-corner gradient constraints.
    /// The final common bound below contains any finite-iteration residual.
    /// No source pixels, observations or fields escape this request.
    private static func boundedField(_ seed: [SIMD2<Double>], xs: [Double], ys: [Double],
        maximumGradient: Double, maximumDisplacement: Double) -> [SIMD2<Double>] {
        var field = seed
        let fixed = seed.map { $0 == .zero }
        func norm(_ p: SIMD2<Double>) -> Double { hypot(p.x, p.y) }
        func project(_ a: Int, _ b: Int, _ c: Int, _ dx: Double, _ dy: Double) {
            let ax = 1 / dx, ay = 1 / dy
            let gx = (field[b] - field[a]) * ax, gy = (field[c] - field[a]) * ay
            guard sqrt(gx.x*gx.x + gx.y*gx.y + gy.x*gy.x + gy.y*gy.y) > maximumGradient else { return }
            let m00 = (fixed[a] ? 0 : ax*ax) + (fixed[b] ? 0 : ax*ax)
            let m11 = (fixed[a] ? 0 : ay*ay) + (fixed[c] ? 0 : ay*ay)
            let m01 = fixed[a] ? 0 : ax*ay
            guard m00 + m11 > 0 else { return }
            func reduced(_ multiplier: Double) -> (SIMD2<Double>, SIMD2<Double>) {
                let determinant = 1 + multiplier * (m00 + m11)
                    + multiplier * multiplier * max(0, m00 * m11 - m01 * m01)
                return ((gx * (1 + multiplier * m11) - gy * (multiplier * m01)) / determinant,
                        (gy * (1 + multiplier * m00) - gx * (multiplier * m01)) / determinant)
            }
            func admissible(_ multiplier: Double) -> Bool {
                let (x, y) = reduced(multiplier)
                return sqrt(x.x*x.x + x.y*x.y + y.x*y.x + y.y*y.y) <= maximumGradient
            }
            var lower = 0.0, upper = 1 / (m00 + m11)
            for _ in 0..<40 where !admissible(upper) { upper *= 2 }
            for _ in 0..<12 {
                let middle = (lower + upper) * 0.5
                if admissible(middle) { upper = middle } else { lower = middle }
            }
            let (x, y) = reduced(upper)
            if !fixed[a] { field[a] += (x * ax + y * ay) * upper }
            if !fixed[b] { field[b] -= x * (ax * upper) }
            if !fixed[c] { field[c] -= y * (ay * upper) }
        }
        // Narrow collars converge more slowly than the open contour. Keep
        // solving their local constraints before applying the final common
        // bound, which would otherwise weaken every unaffected jaw segment.
        for pass in 0..<64 {
            let rows = pass.isMultiple(of: 2) ? Array(0..<(ys.count - 1)) : Array((0..<(ys.count - 1)).reversed())
            let columns = pass.isMultiple(of: 2) ? Array(0..<(xs.count - 1)) : Array((0..<(xs.count - 1)).reversed())
            for row in rows { for col in columns {
                let tl = row * xs.count + col, tr = tl + 1, bl = tl + xs.count, br = bl + 1
                let dx = xs[col + 1] - xs[col], dy = ys[row + 1] - ys[row]
                project(tl, tr, bl, dx, dy); project(tr, tl, br, dx, dy)
                project(bl, br, tl, dx, dy); project(br, bl, tr, dx, dy)
            } }
            for index in field.indices {
                let length = norm(field[index])
                if length > maximumDisplacement { field[index] *= maximumDisplacement / length }
            }
        }
        return field
    }

    private static func valid(_ p: SIMD2<Float>) -> Bool {
        p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y)
    }

    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        guard source.count == width*height*4 else { return source }
        var output=source
        var row=0
        for y in max(0, Int(ys[0]))..<min(height, Int(ceil(ys.last!))) {
            let py=Double(y)+0.5
            guard py >= ys[0], py < ys.last! else { continue }
            while row+1 < ys.count-1 && py >= ys[row+1] { row += 1 }
            let fy=(py-ys[row])/(ys[row+1]-ys[row])
            var col=0
            for x in max(0, Int(xs[0]))..<min(width, Int(ceil(xs.last!))) {
                let px=Double(x)+0.5
                guard px >= xs[0], px < xs.last!,
                      transitionScope.map({ $0.allowsDestination(x: x, y: y) }) ?? true,
                      !protection.contains(where: { $0.contains(x: px, y: py) }),
                      attachments?.protectsPixel(x: x, y: y) != true,
                      ownership?.preservesDestinationPixel(x: x, y: y) != true,
                      ownership.map({ $0.distanceToReserve(x: px, y: py) > 0 }) ?? true else { continue }
                while col+1 < xs.count-1 && px >= xs[col+1] { col += 1 }
                let fx=(px-xs[col])/(xs[col+1]-xs[col]), i=row*xs.count+col
                let top=offsets[i]*(1-fx)+offsets[i+1]*fx
                let bottom=offsets[i+xs.count]*(1-fx)+offsets[i+xs.count+1]*fx
                let d=top*(1-fy)+bottom*fy
                guard abs(d.x)+abs(d.y) > 1e-10 else { continue }
                let sx=min(Double(width-1),max(0,Double(x)-d.x))
                let sy=min(Double(height-1),max(0,Double(y)-d.y))
                let x0=Int(floor(sx)), y0=Int(floor(sy)), x1=min(x0+1,width-1), y1=min(y0+1,height-1)
                let samples = [(x0, y0), (x1, y0), (x0, y1), (x1, y1)]
                guard ownership.map({ $0.allowsSourceFootprint(x: sx + 0.5, y: sy + 0.5) }) ?? true,
                      transitionScope.map({ $0.allowsSourceFootprint(x: sx + 0.5, y: sy + 0.5) }) ?? true else { continue }
                // Complete texel footprints must not import protected tissue
                // into the contour band, even after lattice interpolation.
                guard !samples.contains(where: { sample in
                    protection.contains { $0.intersectsPixel(x: sample.0, y: sample.1) } ||
                        attachments?.protectsPixel(x: sample.0, y: sample.1) == true
                }) else { continue }
                // The field already tapers to zero at the source-fixed band.
                // This final hard copy only contains lattice interpolation;
                // it never clips sampling at the original material boundary.
                guard admitsDestination(x: px, y: py) else { continue }
                let indices=[(y0*width+x0)*4,(y0*width+x1)*4,(y1*width+x0)*4,(y1*width+x1)*4]
                let dst=(y*width+x)*4, alpha=source[dst+3]
                guard indices.allSatisfy({ source[$0+3] == alpha }) else { continue }
                let ax=sx-Double(x0), ay=sy-Double(y0)
                for c in 0..<3 {
                    let a=Double(source[indices[0]+c]), b=Double(source[indices[1]+c])
                    let c0=Double(source[indices[2]+c]), d0=Double(source[indices[3]+c])
                    let v=(a+(b-a)*ax)*(1-ay)+(c0+(d0-c0)*ax)*ay
                    output[dst+c]=UInt8(min(255,max(0,Int(v.rounded()))))
                }
            }
        }
        if let ownership {
            return ownership.compositePreservingSourceCores(originalRGBA: source, warpedRGBA: output) ?? source
        }
        return output
    }

    private func admitsDestination(x: Double, y: Double) -> Bool {
        let q = SIMD2(x, y)
        var distanceSquared = Double.infinity
        for (a, b) in zip(sourceContour, sourceContour.dropFirst()) {
            let d = b - a, lengthSquared = d.x * d.x + d.y * d.y
            guard lengthSquared > 0 else { continue }
            let t = min(1, max(0, ((q - a).x * d.x + (q - a).y * d.y) / lengthSquared))
            let residual = q - (a + d * t)
            distanceSquared = min(distanceSquared, residual.x * residual.x + residual.y * residual.y)
        }
        guard distanceSquared <= max(interiorRadiusSquared, exteriorRadiusSquared) else { return false }
        if distanceSquared <= exteriorRadiusSquared { return true }
        var inside = false
        for i in sourceContour.indices {
            let a = sourceContour[i], b = sourceContour[(i + 1) % sourceContour.count]
            if (a.y > y) != (b.y > y), x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x {
                inside.toggle()
            }
        }
        return inside && distanceSquared <= interiorRadiusSquared
    }

    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        init(points: [SIMD2<Double>], padding: Double) {
            minX = points.map(\.x).min()! - padding; maxX = points.map(\.x).max()! + padding
            minY = points.map(\.y).min()! - padding; maxY = points.map(\.y).max()! + padding
        }
        func contains(x: Double, y: Double) -> Bool { x >= minX && x <= maxX && y >= minY && y <= maxY }
        func intersectsPixel(x: Int, y: Int) -> Bool {
            Double(x + 1) >= minX && Double(x) <= maxX && Double(y + 1) >= minY && Double(y) <= maxY
        }
        func distance(x: Double, y: Double) -> Double {
            hypot(max(minX - x, 0, x - maxX), max(minY - y, 0, y - maxY))
        }
    }
}

extension BeautyContinuousFaceMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyContinuousFaceMap(width: \(width), height: \(height), nodeCount: \(offsets.count))" }
    var debugDescription: String { description }
    var customMirror: Mirror {
        Mirror(self, children: ["width": width, "height": height, "nodeCount": offsets.count])
    }
}
