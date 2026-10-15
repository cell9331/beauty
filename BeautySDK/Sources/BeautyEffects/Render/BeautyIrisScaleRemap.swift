import BeautyCore
import BeautyDetection
import Foundation

/// A request-local source-space iris sampler, independent of the eye lattice.
/// The observed horizontal ring pair admits a pixel-space circle. Its visible
/// core uses one uniform inverse scale; no single-axis projection is allowed.
/// Geometric windows are not semantic tissue masks or hidden-texture evidence.
struct BeautyIrisScaleRemap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    private struct Curve {
        let sourceRadius: Double
        let scale: Double
        let innerRadius: Double
        let outerRadius: Double
        let interval: Double
        let a: Double
        let b: Double
        let c: Double

        init?(sourceRadius: Double, scale: Double, margin: Double) {
            guard sourceRadius.isFinite, sourceRadius > 0,
                  scale.isFinite, scale > 0, margin.isFinite, margin > 0 else { return nil }
            let inner = scale * sourceRadius
            let outer = (scale + margin) * sourceRadius
            let h = outer - inner
            guard inner.isFinite, outer.isFinite, h.isFinite,
                  h > 0, outer > sourceRadius else { return nil }
            let startSlope = 1 / scale
            let aa = 2 * sourceRadius - 2 * outer + h * (startSlope + 1)
            let bb = -3 * sourceRadius + 3 * outer - h * (2 * startSlope + 1)
            let cc = h * startSlope
            // The Hermite derivative is quadratic. Check its endpoints and
            // its sole possible interior minimum, rather than sampled steps.
            func derivative(_ t: Double) -> Double {
                (3 * aa * t * t + 2 * bb * t + cc) / h
            }
            var minimum = min(derivative(0), derivative(1))
            if aa > 0 {
                let t = -bb / (3 * aa)
                if t > 0, t < 1 { minimum = min(minimum, derivative(t)) }
            }
            guard aa.isFinite, bb.isFinite, cc.isFinite,
                  minimum.isFinite, minimum > 0 else { return nil }
            self.sourceRadius = sourceRadius
            self.scale = scale
            innerRadius = inner
            outerRadius = outer
            interval = h
            a = aa; b = bb; c = cc
        }

        func inverse(_ radius: Double) -> Double {
            if scale == 1 || radius >= outerRadius { return radius }
            if radius <= innerRadius { return radius / scale }
            let t = (radius - innerRadius) / interval
            return ((a * t + b) * t + c) * t + sourceRadius
        }
    }

    private struct Eye {
        let center: SIMD2<Double>
        let corners: [SIMD2<Double>]
        let cornerCollar: Double
        let contour: [SIMD2<Double>]
        let protection: [[Double]]
        let curve: Curve
    }

    private enum SourceSample {
        case owned(SIMD3<Double>)
        case openingOcclusion
        case catchlight
        case unsafe
    }

    private struct Edit {
        let index: Int
        let color: SIMD3<Double>
    }

    /// A conditional illumination field, admitted only when every observable
    /// white-material sample agrees within RGBA8 quantization. It is not a
    /// tissue classifier or an estimate for textured/non-affine source white.
    private struct AffineWhiteField {
        let center: SIMD2<Double>
        let radius: Double
        let intercept: SIMD3<Double>
        let horizontal: SIMD3<Double>
        let vertical: SIMD3<Double>

        func color(at p: SIMD2<Double>) -> SIMD3<Double>? {
            let local = (p - center) / radius
            let color = intercept + horizontal * local.x + vertical * local.y
            guard (0..<3).allSatisfy({ color[$0].isFinite && color[$0] >= 0 && color[$0] <= 255 })
            else { return nil }
            return color
        }
    }

    /// Opaque, request-local authorization from eyes that actually completed
    /// this sampler. Its query projects a view pixel into original units;
    /// neither geometry nor an exportable mask crosses the package boundary.
    struct SourceOwner: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        private let width: Int
        private let height: Int
        let appliedEyeCount: Int
        private let query: (SIMD2<Double>) -> Bool

        fileprivate init(width: Int, height: Int, appliedEyeCount: Int,
                         query: @escaping (SIMD2<Double>) -> Bool) {
            self.width = width
            self.height = height
            self.appliedEyeCount = appliedEyeCount
            self.query = query
        }

        func permitsPreviewPixel(column: Int, row: Int, width viewWidth: Int, height viewHeight: Int) -> Bool {
            guard viewWidth > 0, viewHeight > 0, column >= 0, column < viewWidth,
                  row >= 0, row < viewHeight else { return false }
            return query(SIMD2((Double(column) + 0.5) * Double(width) / Double(viewWidth),
                               (Double(row) + 0.5) * Double(height) / Double(viewHeight)))
        }

        static func empty(width: Int, height: Int) -> SourceOwner {
            SourceOwner(width: width, height: height, appliedEyeCount: 0, query: { _ in false })
        }

        var description: String {
            "BeautyIrisSourceOwner(width: \(width), height: \(height), appliedEyeCount: \(appliedEyeCount))"
        }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["width": width, "height": height, "appliedEyeCount": appliedEyeCount],
                   displayStyle: .struct)
        }
    }

    struct OwnedRaster: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let rgba: [UInt8]
        let owner: SourceOwner
        var description: String { "BeautyIrisOwnedRaster(byteCount: \(rgba.count), appliedEyeCount: \(owner.appliedEyeCount))" }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["byteCount": rgba.count, "appliedEyeCount": owner.appliedEyeCount],
                   displayStyle: .struct)
        }
    }

    // Request-local texture exception only; diagnostics expose counts.
    private struct GlintRepair: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let background: [Int: SIMD3<Double>]
        let restoreWeights: [Int: Double]
        let candidateCoreCount: Int
        let corroboratedCoreCount: Int
        let qualifiedComponentCount: Int
        let materialPixelCount: Int
        let footprintPixelCount: Int

        var description: String {
            "BeautyIrisGlintRepair(candidateCoreCount: \(candidateCoreCount), corroboratedCoreCount: \(corroboratedCoreCount), qualifiedComponentCount: \(qualifiedComponentCount), materialPixelCount: \(materialPixelCount), footprintPixelCount: \(footprintPixelCount), pixelCount: \(background.count))"
        }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["pixelCount": background.count,
                                    "restoreCount": restoreWeights.count,
                                    "candidateCoreCount": candidateCoreCount,
                                    "corroboratedCoreCount": corroboratedCoreCount,
                                    "qualifiedComponentCount": qualifiedComponentCount,
                                    "materialPixelCount": materialPixelCount,
                                    "footprintPixelCount": footprintPixelCount], displayStyle: .struct)
        }
    }

    // Destination pixels keep the known one-pixel lid strip unchanged.
    // Opening RGB coverage transitions only at signed distances 1...1.25px;
    // it reaches one at 1.25px without expanding the destination support.
    // Source four-tap ownership, window and canthal feathers remain independent.
    private static let destinationErosion = 1.0
    private static let openingFeather = 0.25
    private static let edgeFeather = 1.0
    private static let sourceFootprint = sqrt(2.0)
    private static let margin = 1.0
    private static let polarStep = Double.pi / 180
    private static let polarSteps = 180

    let width: Int
    let height: Int
    private let eyes: [Eye]

    init?(width: Int, height: Int, face: FaceGeometry,
          strengths: BeautyEffectiveStrengths, sourceRGBA: [UInt8]? = nil) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              sourceRGBA == nil || sourceRGBA!.count == width * height * 4,
              face.freshness == .fresh, strengths.pupilSize.isFinite,
              strengths.pupilSize != 0, let dense = face.denseSupport,
              dense.mesh.points.count == 478,
              dense.geometryScale.isFinite, dense.geometryScale > 0 else { return nil }
        let w = Double(width), h = Double(height)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x) * w, Double(p.y) * h)
        }
        func box(_ path: [SIMD2<Float>]) -> [Double]? {
            guard !path.isEmpty, path.allSatisfy(Self.valid) else { return nil }
            let p = path.map(pixel)
            return [p.map(\.x).min()! - 1.5, p.map(\.x).max()! + 1.5,
                    p.map(\.y).min()! - 1.5, p.map(\.y).max()! + 1.5]
        }
        let supports = [face.leftEyeSupport, face.rightEyeSupport].compactMap { $0 }
        let featurePaths = [face.nose + face.noseTip + face.noseRoot, face.outerLips,
                            face.observedEyebrowSupport?.left?.points ?? [],
                            face.observedEyebrowSupport?.right?.points ?? []]
        let featureProtection = featurePaths.compactMap(box)
        let normalized = Double(min(BeautySafetyCaps.pupilSize,
                                    max(-BeautySafetyCaps.pupilSize, strengths.pupilSize))
                                / BeautySafetyCaps.pupilSize)
        var admitted = [Eye]()
        for support in supports {
            guard (4...64).contains(support.contour.count),
                  support.contour.allSatisfy(Self.valid),
                  BeautyDenseFaceSupport.simplePolygon(support.contour),
                  let pupil = support.pupil, Self.valid(pupil),
                  let inner = support.inner.first, let outer = support.outer.first,
                  Self.valid(inner), Self.valid(outer),
                  let visible = dense.iris(side: support.side, eye: support) else { continue }
            let a = pixel(inner), b = pixel(outer)
            var axis = b - a
            if axis.x < 0 { axis = -axis }
            let span = hypot(axis.x, axis.y)
            guard span >= 6, span < min(w, h) * 0.45, axis.x > span * 0.40 else { continue }
            axis /= span
            let normal = SIMD2(-axis.y, axis.x)
            let contour = support.contour.map(pixel)
            let midpoint = (a + b) * 0.5
            let opening = contour.map { Self.dot($0 - midpoint, normal) }
            guard let top = opening.min(), let bottom = opening.max(),
                  top < -0.5, bottom > 0.5,
                  bottom - top >= span * 0.08, bottom - top <= span * 0.85 else { continue }
            let centerIndex = support.side == .left ? 468 : 473
            let observedCenter = dense.mesh.points[centerIndex]
            let centerPoint = SIMD2<Float>(observedCenter.x, observedCenter.y)
            guard Self.valid(centerPoint) else { continue }
            let rawCenter = pixel(centerPoint)
            var center = rawCenter
            let ring = visible.map(pixel)
            guard let left = ring.min(by: { Self.dot($0 - center, axis) < Self.dot($1 - center, axis) }),
                  let right = ring.max(by: { Self.dot($0 - center, axis) < Self.dot($1 - center, axis) }),
                  Self.dot(left - center, axis) < 0, Self.dot(right - center, axis) > 0 else { continue }
            let rawRadius = hypot((right - left).x, (right - left).y) * 0.5
            var radius = rawRadius
            let pairMidpoint = (left + right) * 0.5
            // The upper eye-width bound corroborates an observed pair. Small
            // observed irises retain their measured radius; a typical lower
            // ratio is not an admission requirement or a fabricated prior.
            guard radius.isFinite, radius >= 1,
                  radius <= span * 0.26,
                  hypot((pairMidpoint - center).x, (pairMidpoint - center).y) <= radius * 0.20,
                  Self.signedDistance(center, contour) > Self.sourceFootprint else { continue }
            let peer = supports.filter { $0.side != support.side }.compactMap { box($0.contour) }
            let sourceProtection = featureProtection + peer
            let rawNearestCorner = min(hypot((a - rawCenter).x, (a - rawCenter).y),
                                       hypot((b - rawCenter).x, (b - rawCenter).y))
            // Registration owns a strength-independent subset of the original
            // source geometry. No fitted circle can move these owners or use
            // pixels outside the minimum original signed-window budget.
            let registrationWindow = min((1 + 100.0 / 121.0) * rawRadius,
                rawNearestCorner - span * 0.08 - Self.sourceFootprint - Self.edgeFeather)
            let registrationOwner = BeautyIrisSourceCircleRegistration.Owner(
                contour: contour,
                protectedRects: sourceProtection.map {
                    BeautyIrisSourceCircleRegistration.Rect(minX: $0[0], maxX: $0[1], minY: $0[2], maxY: $0[3])
                },
                canthi: [a, b], canthalRadius: span * 0.08,
                windowCenter: rawCenter, windowRadius: registrationWindow)
            if let sourceRGBA,
               let registered = BeautyIrisSourceCircleRegistration.register(
                    sourceRGBA: sourceRGBA, width: width, height: height,
                    modelCenter: rawCenter, modelRadius: rawRadius,
                    eyeAxis: axis, owner: registrationOwner),
               registered.radius >= 1, registered.radius <= span * 0.26,
               registrationOwner.owns(registered.center),
               Self.signedDistance(registered.center, contour) > Self.sourceFootprint {
                center = registered.center
                radius = registered.radius
            }
            // A source-fixed aperture budget observes full bilinear ownership
            // at 72 equally spaced circle-boundary directions. It reads no RGBA
            // and cannot authorize a source sample rejected by the existing gates.
            let boundarySampleCount = 72
            var ownedBoundaryCount = 0
            for sampleIndex in 0..<boundarySampleCount {
                let angle = Double(sampleIndex) * 5 * Double.pi / 180
                let q = center + SIMD2(cos(angle), sin(angle)) * radius
                guard q.x.isFinite, q.y.isFinite else { continue }
                let u = q.x - 0.5, v = q.y - 0.5
                // Validate floating-point bounds before converting to Int.
                guard u >= 0, v >= 0,
                      u < Double(width - 1), v < Double(height - 1) else { continue }
                let x = Int(floor(u)), y = Int(floor(v))
                let taps = [SIMD2(Double(x) + 0.5, Double(y) + 0.5),
                            SIMD2(Double(x + 1) + 0.5, Double(y) + 0.5),
                            SIMD2(Double(x) + 0.5, Double(y + 1) + 0.5),
                            SIMD2(Double(x + 1) + 0.5, Double(y + 1) + 0.5)]
                if taps.allSatisfy({ registrationOwner.owns($0) }) { ownedBoundaryCount += 1 }
            }
            let visibleSupportFraction = Double(ownedBoundaryCount) / Double(boundarySampleCount)
            // Source geometry with at most one-third full-tap boundary support
            // receives a separate still-image budget. The classification has a
            // discrete gain step; it does not identify blinking or promise temporal continuity.
            let visibleSupportGain: Double
            if ownedBoundaryCount <= 24 {
                visibleSupportGain = max(0.85, 0.88 - 0.72 * (1.0 / 3.0 - visibleSupportFraction))
            } else {
                visibleSupportGain = min(1, max(0.9, 2 * visibleSupportFraction))
            }
            let proposedScale = 1 / (1 - 0.21 * normalized * Double(dense.geometryScale) * visibleSupportGain)
            // Absent or ambiguous source evidence preserves the observed
            // model for compatibility; that fallback is not a repaired-circle
            // effect claim and cannot erase a separately failing acceptance.
            var scale = proposedScale
            let nearestCorner = min(hypot((a - center).x, (a - center).y),
                                    hypot((b - center).x, (b - center).y))
            if normalized > 0 {
                let ceiling = min(1.3, 0.9 * nearestCorner / radius)
                guard ceiling > 1 else { continue }
                scale = min(scale, ceiling)
            }
            let cornerCollar = span * 0.08
            // The white transition must fit before the original canthus
            // owner, including the complete bilinear footprint and feather.
            // Insufficient space rejects this eye; it never reverses a sign.
            let windowBudget = nearestCorner - cornerCollar - Self.sourceFootprint - Self.edgeFeather
            let windowRadius = min((scale + Self.margin) * radius, windowBudget)
            let margin = windowRadius / radius - scale
            guard scale.isFinite, scale > 0, scale != 1,
                  windowRadius.isFinite, windowRadius > radius, margin > 0,
                  let curve = Curve(sourceRadius: radius, scale: scale, margin: margin) else { continue }
            admitted.append(Eye(center: center, corners: [a, b], cornerCollar: cornerCollar, contour: contour,
                                protection: sourceProtection, curve: curve))
        }
        guard !admitted.isEmpty else { return nil }
        self.width = width; self.height = height; eyes = admitted
    }

    /// Exposes only the scalar analytic function to target-internal checks.
    static func inverseRadius(_ radius: Double, sourceRadius: Double,
                              scale: Double, margin: Double = 1) -> Double? {
        guard radius.isFinite, radius >= 0,
              let curve = Curve(sourceRadius: sourceRadius, scale: scale, margin: margin) else { return nil }
        return curve.inverse(radius)
    }

    private static func valid(_ p: SIMD2<Float>) -> Bool {
        p.x.isFinite && p.y.isFinite && p.x >= 0 && p.x <= 1 && p.y >= 0 && p.y <= 1
    }

    private static func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double {
        a.x * b.x + a.y * b.y
    }

    private static func smooth(_ value: Double) -> Double {
        let t = min(1, max(0, value))
        return t * t * (3 - 2 * t)
    }

    private static func contains(_ p: SIMD2<Double>, _ contour: [SIMD2<Double>]) -> Bool {
        var inside = false
        var j = contour.count - 1
        for i in contour.indices {
            let a = contour[i], b = contour[j]
            if (a.y > p.y) != (b.y > p.y),
               p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
            j = i
        }
        return inside
    }

    private static func signedDistance(_ p: SIMD2<Double>, _ contour: [SIMD2<Double>]) -> Double {
        var distance = Double.infinity
        for i in contour.indices {
            let a = contour[i], v = contour[(i + 1) % contour.count] - a
            let length = dot(v, v)
            guard length > 0 else { continue }
            let t = min(1, max(0, dot(p - a, v) / length))
            let delta = p - a - v * t
            distance = min(distance, hypot(delta.x, delta.y))
        }
        return contains(p, contour) ? distance : -distance
    }

    private static func protected(_ p: SIMD2<Double>, eye: Eye) -> Bool {
        eye.protection.contains { b in
            p.x >= b[0] && p.x <= b[1] && p.y >= b[2] && p.y <= b[3]
        }
    }

    private static func cornerClearance(_ p: SIMD2<Double>, eye: Eye) -> Double {
        eye.corners.map { corner in
            let delta = p - corner
            return hypot(delta.x, delta.y) - eye.cornerCollar
        }.min() ?? -Double.infinity
    }

    private func glintRepair(for eye: Eye, source: [UInt8]) -> GlintRepair? {
        let radius = eye.curve.sourceRadius
        let scanRadius = radius * 0.75
        let areaLimit = 0.04 * Double.pi * radius * radius
        let x0 = max(0, Int(floor(eye.center.x - scanRadius)))
        let x1 = min(width - 1, Int(ceil(eye.center.x + scanRadius)))
        let y0 = max(0, Int(floor(eye.center.y - scanRadius)))
        let y1 = min(height - 1, Int(ceil(eye.center.y + scanRadius)))
        guard x0 <= x1, y0 <= y1 else { return nil }

        func point(_ index: Int) -> SIMD2<Double> {
            let pixel = index / 4
            return SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
        }
        func neighbors(_ index: Int) -> [Int]? {
            let pixel = index / 4, x = pixel % width, y = pixel / width
            guard x > 0, x < width - 1, y > 0, y < height - 1 else { return nil }
            var result = [Int]()
            for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                result.append(((y + dy) * width + x + dx) * 4)
            } }
            return result
        }
        func luminance(_ rgb: SIMD3<Double>) -> Double {
            0.2126 * rgb.x + 0.7152 * rgb.y + 0.0722 * rgb.z
        }
        func median(_ values: [Double]) -> Double {
            let sorted = values.sorted(), middle = sorted.count / 2
            return sorted.count.isMultiple(of: 2)
                ? (sorted[middle - 1] + sorted[middle]) * 0.5 : sorted[middle]
        }
        var legalColors = [Int: SIMD3<Double>]()
        func legalColor(_ index: Int) -> SIMD3<Double>? {
            if let rgb = legalColors[index] { return rgb }
            // At a pixel center this is its original RGB, but every one of
            // the four taps must first pass the unchanged geometric/alpha gates.
            guard case let .owned(rgb) = sample(point(index), eye: eye, source: source,
                                                alpha: 255) else { return nil }
            legalColors[index] = rgb
            return rgb
        }
        var inner = [Int: SIMD3<Double>]()
        for y in y0...y1 { for x in x0...x1 {
            let index = (y * width + x) * 4, offset = point(index) - eye.center
            guard hypot(offset.x, offset.y) <= scanRadius,
                  let rgb = legalColor(index) else { continue }
            inner[index] = rgb
        } }
        // With no legal inner sample, no source highlight can be qualified.
        // Preserve the original sampler path rather than reading excluded data.
        guard !inner.isEmpty else { return GlintRepair(background: [:], restoreWeights: [:], candidateCoreCount: 0,
                                                  corroboratedCoreCount: 0, qualifiedComponentCount: 0,
                                                  materialPixelCount: 0, footprintPixelCount: 0) }
        let baseline = SIMD3(median(inner.values.map(\.x)), median(inner.values.map(\.y)),
                             median(inner.values.map(\.z)))
        let baselineLuma = median(inner.values.map(luminance))
        let globalCore = Set(inner.compactMap { index, rgb -> Int? in
            rgb.x > baseline.x + 32 && rgb.y > baseline.y + 32 && rgb.z > baseline.z + 32
                && luminance(rgb) > baselineLuma + 50 ? index : nil
        })
        guard !globalCore.isEmpty else {
            return GlintRepair(background: [:], restoreWeights: [:], candidateCoreCount: 0,
                               corroboratedCoreCount: 0, qualifiedComponentCount: 0,
                                                  materialPixelCount: 0, footprintPixelCount: 0)
        }
        // The inner-disk median proposes a bright core, but a dark pupil can
        // make ordinary iris texture pass that contrast test. Corroborate each
        // candidate against two original, same-radius source stencils that
        // exclude every global core. The original source/alpha gates still
        // precede RGB; insufficient background support rejects this eye.
        var core = Set<Int>(), coreBackground = [Int: SIMD3<Double>]()
        for index in globalCore.sorted() {
            guard let local = glintBackground(point(index), eye: eye, source: source,
                                               excluding: globalCore) else { return nil }
            coreBackground[index] = local
            let rgb = inner[index]!
            if rgb.x > local.x + 32 && rgb.y > local.y + 32 && rgb.z > local.z + 32
                && luminance(rgb) > luminance(local) + 50 { core.insert(index) }
        }
        // Zero corroborated cores explicitly means this input has no qualified
        // glint. The empty repair retains the original sampler, without a
        // claim that a source highlight has been preserved or repaired.
        guard !core.isEmpty else {
            return GlintRepair(background: [:], restoreWeights: [:], candidateCoreCount: globalCore.count,
                               corroboratedCoreCount: 0, qualifiedComponentCount: 0,
                                                  materialPixelCount: 0, footprintPixelCount: 0)
        }
        guard Double(core.count) <= areaLimit else { return nil }

        // The bright cores are explicitly eight-connected small components.
        // Multiple components share one fixed total area budget for this eye.
        var unvisited = core, components = [[Int]]()
        while let first = unvisited.min() {
            unvisited.remove(first)
            var component = [first], cursor = 0
            while cursor < component.count {
                guard let adjacent = neighbors(component[cursor]) else { return nil }
                cursor += 1
                for index in adjacent where unvisited.remove(index) != nil { component.append(index) }
            }
            components.append(component)
        }
        var antialias = core
        for component in components {
            // Each component owns one source-only background estimate. AA
            // contrast uses its per-channel/luma medians rather than the
            // pupil-biased whole-inner-disk medians. Every corroborated core
            // remains included regardless of this lower AA contrast test.
            let estimates = component.map { coreBackground[$0]! }
            let local = SIMD3(median(estimates.map(\.x)), median(estimates.map(\.y)),
                              median(estimates.map(\.z)))
            let localLuma = median(estimates.map(luminance))
            var componentAA = Set(component), frontier = component, cursor = 0
            while cursor < frontier.count {
                guard let adjacent = neighbors(frontier[cursor]) else { return nil }
                cursor += 1
                for index in adjacent where !componentAA.contains(index) {
                    // Even deciding an AA boundary requires a complete legal
                    // opaque stencil. Unknown data cannot terminate a patch.
                    guard let rgb = legalColor(index) else { return nil }
                    if rgb.x > local.x + 8 && rgb.y > local.y + 8 && rgb.z > local.z + 8
                        && luminance(rgb) > localLuma + 12 {
                        componentAA.insert(index)
                        frontier.append(index)
                        antialias.insert(index)
                        guard Double(antialias.count) <= areaLimit else { return nil }
                    }
                }
            }
        }
        // The fixed 4% area budget owns only the observed bright/AA material.
        // Reconnect the final AA union because separate core components can
        // join during source-only AA growth. Each material component must fit
        // a source-pixel bounding box whose maximum complete cell side is <= .4R,
        // matching the diameter of a circle with the same 4% area budget.
        guard Double(antialias.count) <= areaLimit else { return nil }
        var remaining = antialias, qualifiedComponentCount = 0
        while let first = remaining.min() {
            remaining.remove(first)
            let firstPixel = first / 4
            var minX = firstPixel % width, maxX = minX
            var minY = firstPixel / width, maxY = minY
            var component = [first], cursor = 0
            while cursor < component.count {
                let index = component[cursor], pixel = index / 4
                minX = min(minX, pixel % width); maxX = max(maxX, pixel % width)
                minY = min(minY, pixel / width); maxY = max(maxY, pixel / width)
                guard let adjacent = neighbors(index) else { return nil }
                cursor += 1
                for neighbor in adjacent where remaining.remove(neighbor) != nil {
                    component.append(neighbor)
                }
            }
            // Include complete pixel cells, not just their center coordinates.
            let boxWidth = Double(maxX - minX + 1), boxHeight = Double(maxY - minY + 1)
            guard max(boxWidth, boxHeight) <= radius * 0.4 else { return nil }
            qualifiedComponentCount += 1
        }
        // The separately certified sampling footprint is exactly AA union
        // Chebyshev-one neighbors. Known halo taps retain source RGB and full
        // ownership validation; only AA material is repaired/excluded for donors.
        // No further footprint growth or 4% footprint-area claim is permitted.
        var envelope = antialias
        for index in antialias {
            guard let adjacent = neighbors(index) else { return nil }
            envelope.formUnion(adjacent)
        }
        for index in envelope {
            let offset = point(index) - eye.center
            guard hypot(offset.x, offset.y) < radius - Self.sourceFootprint,
                  legalColor(index) != nil else { return nil }
        }
        var background = [Int: SIMD3<Double>](), restoreWeights = [Int: Double]()
        for index in envelope.sorted() {
            let p = point(index)
            if antialias.contains(index) {
                // Only observed bright/AA material needs a replacement
                // background. Known halo taps retain their original source RGB;
                // donors still exclude every AA tap after the full source gates.
                guard let rgb = glintBackground(p, eye: eye, source: source,
                                               excluding: antialias) else { return nil }
                background[index] = rgb
                // The observed bright/AA source pixels keep their original
                // positions and RGB. Only the footprint halo is feathered.
                restoreWeights[index] = 1
            } else {
                let distance = antialias.map { other -> Double in
                    let offset = p - point(other)
                    return hypot(offset.x, offset.y)
                }.min()!
                let edgeDistance = max(0, distance - 0.5)
                restoreWeights[index] = Self.smooth(1 - edgeDistance / Self.sourceFootprint)
            }
        }
        return GlintRepair(background: background, restoreWeights: restoreWeights,
                           candidateCoreCount: globalCore.count, corroboratedCoreCount: core.count,
                           qualifiedComponentCount: qualifiedComponentCount,
                           materialPixelCount: antialias.count, footprintPixelCount: envelope.count)
    }

    private func glintBackground(_ q: SIMD2<Double>, eye: Eye, source: [UInt8],
                                 excluding envelope: Set<Int>) -> SIMD3<Double>? {
        let offset = q - eye.center, radius = hypot(offset.x, offset.y)
        guard radius.isFinite, radius > 0, radius < eye.curve.sourceRadius else { return nil }
        let angle = atan2(offset.y, offset.x)
        var sides = [(distance: Double, color: SIMD3<Double>)]()
        var firstCell: SIMD2<Int>?
        for direction in [-1.0, 1.0] {
            var donor: (Double, SIMD3<Double>, SIMD2<Int>)?
            for step in 1...Self.polarSteps {
                let distance = Double(step) * Self.polarStep
                let theta = angle + direction * distance
                let candidate = eye.center + SIMD2(cos(theta), sin(theta)) * radius
                let cell = SIMD2(Int(floor(candidate.x - 0.5)), Int(floor(candidate.y - 0.5)))
                if let firstCell, cell == firstCell { continue }
                if case let .owned(rgb) = sample(candidate, eye: eye, source: source,
                                                 alpha: 255, excludingPixels: envelope) {
                    donor = (distance, rgb, cell)
                    break
                }
            }
            guard let donor else { return nil }
            sides.append((donor.0, donor.1))
            firstCell = donor.2
        }
        let total = sides[0].distance + sides[1].distance
        return (sides[0].color * sides[1].distance + sides[1].color * sides[0].distance) / total
    }

    private func sample(_ q: SIMD2<Double>, eye: Eye, source: [UInt8],
                        alpha: UInt8, minimumRadius: Double? = nil,
                        rejectCatchlight: Bool = false,
                        repair: GlintRepair? = nil,
                        excludingPixels: Set<Int>? = nil) -> SourceSample {
        guard q.x.isFinite, q.y.isFinite else { return .unsafe }
        let u = q.x - 0.5, v = q.y - 0.5
        guard u >= 0, v >= 0, u < Double(width - 1), v < Double(height - 1) else { return .unsafe }
        let x = Int(floor(u)), y = Int(floor(v))
        let centers = [SIMD2(Double(x) + 0.5, Double(y) + 0.5),
                       SIMD2(Double(x + 1) + 0.5, Double(y) + 0.5),
                       SIMD2(Double(x) + 0.5, Double(y + 1) + 0.5),
                       SIMD2(Double(x + 1) + 0.5, Double(y + 1) + 0.5)]
        // Check ownership before reading any pixel, including alpha. Unknown
        // pixels outside the opening can neither authorize nor disable a donor.
        guard centers.allSatisfy({ !Self.protected($0, eye: eye)
            && hypot(($0 - eye.center).x, ($0 - eye.center).y) < eye.curve.outerRadius }) else { return .unsafe }
        // The inner one-pixel lid/lash strip and source-fixed canthal collars
        // are excluded material too. Their RGB and alpha stay unknown even
        // inside the raw contour. Polar donors share this geometric owner.
        let owned = centers.map {
            Self.contains($0, eye.contour) && Self.signedDistance($0, eye.contour) > 1
                && Self.cornerClearance($0, eye: eye) > 0
        }
        let indices = [(y * width + x) * 4, (y * width + x + 1) * 4,
                       ((y + 1) * width + x) * 4, ((y + 1) * width + x + 1) * 4]
        // An already-owned alpha mismatch is a safety rejection even when a
        // different corner is occluded. Unknown opening-exterior alpha is
        // never read, so it cannot influence admission or donor selection.
        for i in indices.indices where owned[i] {
            if source[indices[i] + 3] != alpha { return .unsafe }
        }
        guard owned.allSatisfy({ $0 }) else { return .openingOcclusion }
        if let minimumRadius,
           !centers.allSatisfy({ hypot(($0 - eye.center).x, ($0 - eye.center).y) >= minimumRadius }) { return .unsafe }
        // A glint donor excludes every supplied excluded material tap after
        // ownership and known alpha checks, before any RGB can be read. C54
        // supplies AA material rather than the known sampling-footprint halo.
        if let excludingPixels, indices.contains(where: { excludingPixels.contains($0) }) {
            return .catchlight
        }
        if rejectCatchlight, indices.indices.contains(where: { i in
            // A bright stencil corner in the limbus antialias footprint or
            // adjacent white material is not evidence of a catchlight. Only
            // pixels inside the observed circle by a full bilinear footprint
            // can veto an occluded-sector iris donor for this reason. This
            // does not alter a raw legal sample or any ownership/alpha gate.
            let offset = centers[i] - eye.center
            guard hypot(offset.x, offset.y) <= eye.curve.sourceRadius - Self.sourceFootprint else { return false }
            let index = indices[i]
            let red = Double(source[index]), green = Double(source[index + 1]), blue = Double(source[index + 2])
            return 0.2126 * red + 0.7152 * green + 0.0722 * blue >= 200
                || max(red, green, blue) >= 250
        }) { return .catchlight }
        let fx = u - Double(x), fy = v - Double(y)
        let weights = [(1 - fx) * (1 - fy), fx * (1 - fy), (1 - fx) * fy, fx * fy]
        var rgb = SIMD3<Double>.zero
        for (index, weight) in zip(indices, weights) {
            // The repair changes only this explicitly qualified source texture
            // patch, after the original complete sample checks have passed.
            let color = repair?.background[index]
                ?? SIMD3(Double(source[index]), Double(source[index + 1]), Double(source[index + 2]))
            rgb += color * weight
        }
        return .owned(rgb)
    }

    private func polarEstimate(_ q: SIMD2<Double>, eye: Eye,
                               source: [UInt8], alpha: UInt8,
                               repair: GlintRepair? = nil) -> SIMD3<Double>? {
        let delta = q - eye.center, radius = hypot(delta.x, delta.y)
        // This explicitly admitted local estimate is not recovered anatomical
        // texture. Only same-radius observed side samples may supply it; raw
        // legal uniform-scale samples are never replaced by this completion.
        guard radius.isFinite, radius > 0, radius < eye.curve.outerRadius else { return nil }
        let angle = atan2(delta.y, delta.x)
        var sides = [(distance: Double, color: SIMD3<Double>)]()
        // The outer white transition can have its observable sector entirely
        // in one angular half. Circular bracketing must then cross that half's
        // boundary; inner-iris completion keeps its original narrower budget.
        let steps = radius > eye.curve.sourceRadius + Self.sourceFootprint ? 359 : Self.polarSteps
        var firstDonorCell: SIMD2<Int>?
        for direction in [-1.0, 1.0] {
            var donor: (Double, SIMD3<Double>, SIMD2<Int>)?
            for step in 1...steps {
                let offset = Double(step) * Self.polarStep
                let theta = angle + direction * offset
                let candidate = eye.center + SIMD2(cos(theta), sin(theta)) * radius
                let cell = SIMD2(Int(floor(candidate.x - 0.5)), Int(floor(candidate.y - 0.5)))
                // Repeating the same four-corner stencil is not independent
                // two-sided material support, even after circular wraparound.
                if let firstDonorCell, cell == firstDonorCell { continue }
                if case let .owned(rgb) = sample(candidate, eye: eye, source: source,
                                                 alpha: alpha,
                                                 rejectCatchlight: radius <= eye.curve.sourceRadius + Self.sourceFootprint,
                                                 repair: repair) {
                    donor = (offset, rgb, cell)
                    break
                }
            }
            guard let donor else { return nil }
            sides.append((donor.0, donor.1))
            firstDonorCell = donor.2
        }
        let total = sides[0].distance + sides[1].distance
        return (sides[0].color * sides[1].distance + sides[1].color * sides[0].distance) / total
    }

    private func affineWhiteField(for eye: Eye, source: [UInt8]) -> AffineWhiteField? {
        guard eye.curve.scale < 1 else { return nil }
        let radius = eye.curve.sourceRadius, window = eye.curve.outerRadius
        let x0 = max(0, Int(floor(eye.center.x - window)))
        let x1 = min(width - 1, Int(ceil(eye.center.x + window)))
        let y0 = max(0, Int(floor(eye.center.y - window)))
        let y1 = min(height - 1, Int(ceil(eye.center.y + window)))
        guard x0 <= x1, y0 <= y1 else { return nil }
        // Both passes enumerate the immutable source in the same pixel order
        // through one nonescaping owner gate. Keep only scalar/vector moments;
        // a window-sized array of source RGB and locations is unnecessary.
        func forEachWhiteSample(_ visit: (SIMD2<Double>, SIMD3<Double>) -> Bool) -> Bool {
            for y in y0...y1 { for x in x0...x1 {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                let offset = p - eye.center
                guard hypot(offset.x, offset.y) >= radius + Self.sourceFootprint else { continue }
                // This is the existing complete four-tap source owner, including
                // opening erosion, feature/window/canthal exclusion and opaque
                // alpha. No RGB outside that owner participates, even as a veto.
                guard case let .owned(rgb) = sample(p, eye: eye, source: source, alpha: 255,
                                                    minimumRadius: radius + Self.sourceFootprint)
                else { continue }
                guard visit(offset / radius, rgb) else { return false }
            } }
            return true
        }
        var sampleCount = 0
        var sumX = 0.0, sumY = 0.0, sumXX = 0.0, sumXY = 0.0, sumYY = 0.0
        var sumColor = SIMD3<Double>.zero
        var sumXColor = SIMD3<Double>.zero, sumYColor = SIMD3<Double>.zero
        var left = 0, right = 0, above = 0, below = 0
        _ = forEachWhiteSample { local, rgb in
            sampleCount += 1
            sumX += local.x; sumY += local.y
            sumXX += local.x * local.x; sumXY += local.x * local.y; sumYY += local.y * local.y
            sumColor += rgb; sumXColor += rgb * local.x; sumYColor += rgb * local.y
            if local.x <= -0.5 { left += 1 }
            if local.x >= 0.5 { right += 1 }
            if local.y <= -0.25 { above += 1 }
            if local.y >= 0.25 { below += 1 }
            return true
        }
        // Require distributed two-sided observations as well as a conditioned
        // two-dimensional design. A narrow visible stripe cannot authorize
        // extrapolation into an occluded illumination direction.
        guard sampleCount >= 32, min(left, right, above, below) >= 8 else { return nil }
        let count = Double(sampleCount)
        let meanX = sumX / count, meanY = sumY / count, meanColor = sumColor / count
        let xx = sumXX / count - meanX * meanX
        let xy = sumXY / count - meanX * meanY
        let yy = sumYY / count - meanY * meanY
        let eigenGap = hypot(xx - yy, 2 * xy)
        let minimumVariance = (xx + yy - eigenGap) * 0.5
        let maximumVariance = (xx + yy + eigenGap) * 0.5
        let determinant = xx * yy - xy * xy
        guard determinant.isFinite, determinant > 0, minimumVariance >= 0.01,
              maximumVariance <= 100 * minimumVariance else { return nil }
        let xColor = sumXColor / count - meanColor * meanX
        let yColor = sumYColor / count - meanColor * meanY
        let horizontal = (xColor * yy - yColor * xy) / determinant
        let vertical = (yColor * xx - xColor * xy) / determinant
        let intercept = meanColor - horizontal * meanX - vertical * meanY
        // Rounding a true affine RGB field to RGBA8 introduces at most half
        // a code per observation. One code permits that input quantization and
        // fit arithmetic; it does not admit photographic texture or gradients
        // with measurable curvature. Every available sample must pass.
        guard forEachWhiteSample({ local, rgb in
            let estimate = intercept + horizontal * local.x + vertical * local.y
            return (0..<3).allSatisfy({ estimate[$0].isFinite
                && abs(estimate[$0] - rgb[$0]) <= 1 })
        }) else { return nil }
        let field = AffineWhiteField(center: eye.center, radius: radius, intercept: intercept,
                                     horizontal: horizontal, vertical: vertical)
        // A shallow opening does not guarantee that all destination points
        // lie in the convex hull of observable white samples. Admit the field
        // for the whole eye only if every prospective nonzero use stays in
        // RGB range. Otherwise the original sampler owns the whole eye;
        // per-pixel range rejection must not introduce a new color seam.
        let materialUnion = max(radius, eye.curve.innerRadius)
        let materialHalo = 1.3 * (sqrt(0.5) + Self.sourceFootprint)
        for y in y0...y1 { for x in x0...x1 {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let offset = p - eye.center, r = hypot(offset.x, offset.y)
            guard r < window, r > eye.curve.innerRadius,
                  r < materialUnion + materialHalo + Self.edgeFeather,
                  !Self.protected(p, eye: eye),
                  Self.signedDistance(p, eye.contour) > Self.destinationErosion,
                  Self.cornerClearance(p, eye: eye) > 0 else { continue }
            let sourceRadius = eye.curve.inverse(r)
            guard sourceRadius > radius + Self.sourceFootprint,
                  window - max(r, sourceRadius) - Self.sourceFootprint > 0 else { continue }
            guard field.color(at: p) != nil else { return nil }
        } }
        return field
    }

    private func edits(for eye: Eye, source: [UInt8]) -> [Edit]? {
        guard let glint = glintRepair(for: eye, source: source) else { return nil }
        let whiteField = affineWhiteField(for: eye, source: source)
        let radius = eye.curve.outerRadius
        let x0 = max(0, Int(floor(eye.center.x - radius)))
        let x1 = min(width - 1, Int(ceil(eye.center.x + radius)))
        let y0 = max(0, Int(floor(eye.center.y - radius)))
        let y1 = min(height - 1, Int(ceil(eye.center.y + radius)))
        guard x0 <= x1, y0 <= y1 else { return nil }
        var edits = [Edit]()
        for y in y0...y1 { for x in x0...x1 {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let delta = p - eye.center, r = hypot(delta.x, delta.y)
            guard r < radius, !Self.protected(p, eye: eye) else { continue }
            let sourceRadius = eye.curve.inverse(r)
            let opening = Self.signedDistance(p, eye.contour) - Self.destinationErosion
            let window = radius - max(r, sourceRadius) - Self.sourceFootprint
            let corner = Self.cornerClearance(p, eye: eye)
            let weight = min(Self.smooth(opening / Self.openingFeather), Self.smooth(window / Self.edgeFeather),
                             Self.smooth(corner / Self.edgeFeather))
            guard weight > 0 else { continue }
            let index = (y * width + x) * 4
            let alpha = source[index + 3]
            guard alpha == 255 else { return nil }
            let q = r > 1e-12 ? eye.center + delta * (sourceRadius / r) : eye.center
            let remapped: SIMD3<Double>
            switch sample(q, eye: eye, source: source, alpha: alpha, repair: glint) {
            case let .owned(rgb): remapped = rgb
            case .unsafe, .catchlight: return nil
            case .openingOcclusion:
                // Geometric opening occlusion may use observed same-radius
                // low-frequency support for either signed core. The inverse
                // radius remains unchanged; hidden tissue is still unobserved.
                if eye.curve.scale < 1
                    || r <= eye.curve.innerRadius
                    || (r > eye.curve.innerRadius
                        && sourceRadius > eye.curve.sourceRadius + Self.sourceFootprint) {
                    guard let rgb = polarEstimate(q, eye: eye, source: source, alpha: alpha,
                                                  repair: glint) else { return nil }
                    remapped = rgb
                } else {
                    // The uniform iris core cannot change its radial function
                    // to satisfy a lid gate. Only the outer white transition
                    // may try bounded ray contraction, with a final full check.
                    guard r > eye.curve.innerRadius else { return nil }
                    var ray = q
                    var rgb: SIMD3<Double>?
                    for _ in 0..<4 {
                        ray = eye.center + (ray - eye.center) * 0.75
                        let radial = hypot((ray - eye.center).x, (ray - eye.center).y)
                        guard radial >= eye.curve.sourceRadius + Self.sourceFootprint else { break }
                        switch sample(ray, eye: eye, source: source, alpha: alpha,
                                      minimumRadius: eye.curve.sourceRadius + Self.edgeFeather,
                                      repair: glint) {
                        case let .owned(value): rgb = value
                        case .unsafe, .catchlight: return nil
                        case .openingOcclusion: continue
                        }
                        if rgb != nil { break }
                    }
                    guard let rgb else { return nil }
                    remapped = rgb
                }
            }
            // An affine source white field belongs at the destination point,
            // rather than at an angular donor's illumination. Admission is
            // source-only and all required material/alpha checks above still
            // run first. The uniform iris core and its raw bilinear AA stay
            // untouched. Both the destination-material join and source-white
            // entry are C1; unsupported photographic fields retain the exact
            // original sampler and color composition.
            let transported: SIMD3<Double>
            if let white = whiteField?.color(at: p) {
                let exposedWhite = Self.smooth((r - eye.curve.innerRadius) / Self.sourceFootprint)
                let sourceWhite = Self.smooth((sourceRadius - eye.curve.sourceRadius
                                              - Self.sourceFootprint) / Self.openingFeather)
                let fieldWeight = exposedWhite * sourceWhite
                transported = remapped * (1 - fieldWeight) + white * fieldWeight
            } else {
                transported = remapped
            }
            let original = SIMD3(Double(source[index]), Double(source[index + 1]), Double(source[index + 2]))
            // Color transport only needs the old/new circular iris union
            // and its complete material sampling footprint. A source pixel
            // cell contributes sqrt(.5), the four-corner sampler sqrt(2), and
            // the admitted positive scale is bounded by 1.3. Keep that entire
            // AA footprint unchanged, then join to original color over 1px.
            // This guard is C1; the radial inverse/Hermite and all mandatory
            // ownership, opaque-alpha and donor checks above remain unchanged.
            let materialUnion = max(eye.curve.sourceRadius, eye.curve.innerRadius)
            let materialHalo = 1.3 * (sqrt(0.5) + Self.sourceFootprint)
            let materialCoverage = Self.smooth((materialUnion + materialHalo + Self.edgeFeather - r)
                                               / Self.edgeFeather)
            let colorWeight = weight * materialCoverage
            let color = original * (1 - colorWeight) + transported * colorWeight
            // Qualified AA material is replaced before remap and restored
            // once. Known halo-only source texture may still be transported
            // and needs appearance review. Alpha is unchanged.
            let restore = glint.restoreWeights[index] ?? 0
            edits.append(Edit(index: index, color: color * (1 - restore) + original * restore))
        } }
        return edits
    }

    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        renderRGBA(source, capturingSourceOwner: false).rgba
    }

    func applyRGBAWithSourceOwner(_ source: [UInt8]) -> OwnedRaster {
        renderRGBA(source, capturingSourceOwner: true)
    }

    private func renderRGBA(_ source: [UInt8], capturingSourceOwner: Bool) -> OwnedRaster {
        guard source.count == width * height * 4 else {
            return OwnedRaster(rgba: source, owner: .empty(width: width, height: height))
        }
        var output = source
        var owners = Set<Int>()
        var collisions = Set<Int>()
        var completedEyes = [Eye]()
        for eye in eyes {
            // A failed required sample rejects the whole eye. No partial iris
            // or fallback grid field can be exposed by incomplete ownership.
            guard let edits = edits(for: eye, source: source) else { continue }
            if capturingSourceOwner { completedEyes.append(eye) }
            for edit in edits {
                if !owners.insert(edit.index).inserted { collisions.insert(edit.index) }
                guard !collisions.contains(edit.index) else {
                    for channel in 0..<3 { output[edit.index + channel] = source[edit.index + channel] }
                    continue
                }
                for channel in 0..<3 {
                    output[edit.index + channel] = UInt8(min(255, max(0, edit.color[channel].rounded())))
                }
            }
        }
        guard capturingSourceOwner else {
            return OwnedRaster(rgba: output, owner: .empty(width: width, height: height))
        }
        let admittedEyes = completedEyes
        let rejectedPixels = collisions
        let sourceWidth = width, sourceHeight = height
        let owner = SourceOwner(width: width, height: height, appliedEyeCount: admittedEyes.count) { p in
            guard p.x.isFinite, p.y.isFinite, p.x >= 0, p.y >= 0,
                  p.x < Double(sourceWidth), p.y < Double(sourceHeight),
                  !rejectedPixels.contains((Int(floor(p.y)) * sourceWidth + Int(floor(p.x))) * 4)
            else { return false }
            var count = 0
            for eye in admittedEyes {
                let delta = p - eye.center, radius = hypot(delta.x, delta.y)
                let window = eye.curve.outerRadius - max(radius, eye.curve.inverse(radius)) - Self.sourceFootprint
                guard window > 0, !Self.protected(p, eye: eye),
                      Self.signedDistance(p, eye.contour) > Self.destinationErosion,
                      Self.cornerClearance(p, eye: eye) > 0 else { continue }
                count += 1
                if count > 1 { return false }
            }
            return count == 1
        }
        return OwnedRaster(rgba: output, owner: owner)
    }

    var description: String { "BeautyIrisScaleRemap(width: \(width), height: \(height), eyeCount: \(eyes.count))" }
    var debugDescription: String { description }
    var customMirror: Mirror {
        Mirror(self, children: ["width": width, "height": height, "eyeCount": eyes.count], displayStyle: .struct)
    }
}

// Internal bounded source registration; appearance qualification is separate.
// The input is the immutable upright source raster in pixel coordinates.
// No candidate output, reference image, or private coordinate enters this fit.
fileprivate enum BeautyIrisSourceCircleRegistration {
    struct Circle: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let center: SIMD2<Double>
        let radius: Double
        var description: String { "BeautyIrisRegisteredCircle(requestLocal: true)" }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["requestLocal": true], displayStyle: .struct)
        }
    }

    struct Rect: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let minX: Double
        let maxX: Double
        let minY: Double
        let maxY: Double
        func contains(_ p: SIMD2<Double>) -> Bool {
            p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY
        }
        var description: String { "BeautyIrisSourceRect(requestLocal: true)" }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["requestLocal": true], displayStyle: .struct)
        }
    }

    // The production adapter must supply its source-fixed owner, not a fit mask.
    // Canthal radii are owned by opening protection; the fitter never adjusts them.
    struct Owner: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let contour: [SIMD2<Double>]
        let protectedRects: [Rect]
        let canthi: [SIMD2<Double>]
        let canthalRadius: Double
        let windowCenter: SIMD2<Double>
        let windowRadius: Double

        func owns(_ p: SIMD2<Double>) -> Bool {
            guard BeautyIrisSourceCircleRegistration.finite(p),
                  BeautyIrisSourceCircleRegistration.length(p - windowCenter) < windowRadius,
                  !protectedRects.contains(where: { $0.contains(p) }),
                  !canthi.contains(where: { BeautyIrisSourceCircleRegistration.length(p - $0) <= canthalRadius }),
                  BeautyIrisSourceCircleRegistration.pointInside(p, contour),
                  BeautyIrisSourceCircleRegistration.boundaryDistance(p, contour) > 1 else { return false }
            return true
        }
        var description: String {
            "BeautyIrisSourceOwner(contourCount: \(contour.count), protectedCount: \(protectedRects.count), canthusCount: \(canthi.count))"
        }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["contourCount": contour.count,
                "protectedCount": protectedRects.count, "canthusCount": canthi.count], displayStyle: .struct)
        }
    }

    private struct Observation {
        let point: SIMD2<Double>
        let side: Int
        let holdout: Bool
    }
    private struct RadialSample {
        let radius: Double
        let color: SIMD3<Double>
    }

    // All numeric choices are prospective, source-only registration proposal values.
    private static let rayStepDegrees = 3.0
    private static let sampleStep = 0.25
    private static let contrast = 18.0
    private static let maximumCondition = 200.0

    static func register(sourceRGBA: [UInt8], width: Int, height: Int,
                         modelCenter: SIMD2<Double>, modelRadius: Double,
                         eyeAxis: SIMD2<Double>, owner: Owner) -> Circle? {
        guard width > 1, height > 1, width <= Int.max / height / 4,
              sourceRGBA.count == width * height * 4,
              finite(modelCenter), finite(eyeAxis), modelRadius.isFinite, modelRadius >= 1,
              owner.contour.count >= 4, owner.contour.allSatisfy(finite),
              owner.protectedRects.allSatisfy({ rect in
                  rect.minX.isFinite && rect.maxX.isFinite && rect.minY.isFinite && rect.maxY.isFinite
                      && rect.minX <= rect.maxX && rect.minY <= rect.maxY
              }),
              owner.canthi.allSatisfy(finite), owner.canthalRadius.isFinite,
              owner.canthalRadius >= 0, finite(owner.windowCenter),
              owner.windowRadius.isFinite, owner.windowRadius > 0,
              simple(owner.contour), owner.owns(modelCenter)
        else { return nil }
        let axisLength = length(eyeAxis)
        guard axisLength.isFinite, axisLength > 0 else { return nil }
        let axis = eyeAxis / axisLength
        let normal = SIMD2(-axis.y, axis.x)
        var observations = [Observation]()
        for side in [-1, 1] {
            for ray in 0...30 {
                let angle = (-45.0 + Double(ray) * rayStepDegrees) * Double.pi / 180
                let direction = (axis * cos(angle) + normal * sin(angle)) * Double(side)
                guard let edge = observedEdge(sourceRGBA, width, height, modelCenter,
                                              modelRadius, direction, owner) else { continue }
                observations.append(Observation(point: modelCenter + direction * edge,
                                                side: side, holdout: ray % 3 == 2))
            }
        }
        let training = observations.filter { !$0.holdout }
        let holdout = observations.filter(\.holdout)
        for side in [-1, 1] {
            let trainSide = training.filter { $0.side == side }
            let testSide = holdout.filter { $0.side == side }
            guard trainSide.count >= 8, testSide.count >= 3 else { return nil }
            let vertical = trainSide.map { dot($0.point - modelCenter, normal) }
            guard let low = vertical.min(), let high = vertical.max(),
                  high - low >= 0.30 * modelRadius,
                  vertical.filter({ $0 <= -0.10 * modelRadius }).count >= 2,
                  vertical.filter({ $0 >= 0.10 * modelRadius }).count >= 2 else { return nil }
        }
        guard let fitted = fit(training.map(\.point), origin: modelCenter, unit: modelRadius),
              owner.owns(fitted.center),
              length(fitted.center - modelCenter) <= 0.20 * modelRadius,
              fitted.radius >= 0.85 * modelRadius, fitted.radius <= 1.15 * modelRadius,
              residualPass(holdout.map(\.point), circle: fitted) else { return nil }
        // Preserve an already-corroborated model when the worst boundary shift
        // is no larger than half a source pixel; avoid AA-driven fixture jitter.
        let model = Circle(center: modelCenter, radius: modelRadius)
        if length(fitted.center - modelCenter) + abs(fitted.radius - modelRadius) <= 0.5,
           residualPass(holdout.map(\.point), circle: model) { return model }
        return fitted
    }

    private static func observedEdge(_ source: [UInt8], _ width: Int, _ height: Int,
                                     _ center: SIMD2<Double>, _ radius: Double,
                                     _ direction: SIMD2<Double>, _ owner: Owner) -> Double? {
        let low = 0.75 * radius, high = 1.25 * radius
        guard high - low >= 3.0 else { return nil }
        var samples = [RadialSample]()
        let count = Int(floor((high - low) / sampleStep))
        for i in 0...count {
            let r = low + Double(i) * sampleStep
            if let color = sample(source, width, height, center + direction * r, owner) {
                samples.append(RadialSample(radius: r, color: color))
            }
        }
        // Missing samples may not be bridged by an interpolated edge.
        var transitions = [(radius: Double, score: Double)]()
        for point in samples {
            let r = point.radius
            guard r - 1.5 >= low, r + 1.5 <= high,
                  let innerA = sample(source, width, height, center + direction * (r - 1.5), owner),
                  let innerB = sample(source, width, height, center + direction * (r - 1.0), owner),
                  let outerA = sample(source, width, height, center + direction * (r + 1.0), owner),
                  let outerB = sample(source, width, height, center + direction * (r + 1.5), owner)
            else { continue }
            let inner = (innerA + innerB) * 0.5, outer = (outerA + outerB) * 0.5
            let delta = outer - inner
            let score = min(delta.x, delta.y, delta.z)
            if score >= contrast { transitions.append((r, score)) }
        }
        guard let strongest = transitions.max(by: { $0.score < $1.score }) else { return nil }
        // Equal-strength separated boundaries indicate texture, a false owner,
        // or multiple edges, not a unique iris-to-white transition.
        guard !transitions.contains(where: {
            abs($0.radius - strongest.radius) >= 2.0 && $0.score >= strongest.score * 0.80
        }) else { return nil }
        let peak = strongest.radius
        guard let innerA = sample(source, width, height, center + direction * (peak - 1.5), owner),
              let innerB = sample(source, width, height, center + direction * (peak - 1.0), owner),
              let outerA = sample(source, width, height, center + direction * (peak + 1.0), owner),
              let outerB = sample(source, width, height, center + direction * (peak + 1.5), owner) else { return nil }
        let inner = (innerA + innerB) * 0.5, outer = (outerA + outerB) * 0.5
        let delta = outer - inner
        guard min(delta.x, delta.y, delta.z) >= contrast else { return nil }
        func fraction(_ rgb: SIMD3<Double>) -> Double {
            let values = [(rgb.x - inner.x) / delta.x,
                          (rgb.y - inner.y) / delta.y,
                          (rgb.z - inner.z) / delta.z].sorted()
            return values[1]
        }
        var prior: (radius: Double, fraction: Double)?
        var crossings = [Double]()
        for i in 0...8 {
            let r = peak - 1.0 + Double(i) * sampleStep
            guard let rgb = sample(source, width, height, center + direction * r, owner) else { return nil }
            let f = fraction(rgb)
            if let p = prior, p.fraction <= 0.5, f >= 0.5, f > p.fraction {
                crossings.append(p.radius + (r - p.radius) * (0.5 - p.fraction) / (f - p.fraction))
            }
            prior = (r, f)
        }
        guard crossings.count == 1 else { return nil }
        return crossings[0]
    }

    private static func sample(_ source: [UInt8], _ width: Int, _ height: Int,
                               _ q: SIMD2<Double>, _ owner: Owner) -> SIMD3<Double>? {
        guard finite(q) else { return nil }
        let u = q.x - 0.5, v = q.y - 0.5
        guard u >= 0, v >= 0, u < Double(width - 1), v < Double(height - 1) else { return nil }
        let x = Int(floor(u)), y = Int(floor(v))
        let taps = [SIMD2(Double(x) + 0.5, Double(y) + 0.5),
                    SIMD2(Double(x + 1) + 0.5, Double(y) + 0.5),
                    SIMD2(Double(x) + 0.5, Double(y + 1) + 0.5),
                    SIMD2(Double(x + 1) + 0.5, Double(y + 1) + 0.5)]
        guard taps.allSatisfy(owner.owns) else { return nil }
        let indices = [(y * width + x) * 4, (y * width + x + 1) * 4,
                       ((y + 1) * width + x) * 4, ((y + 1) * width + x + 1) * 4]
        guard indices.allSatisfy({ source[$0 + 3] == 255 }) else { return nil }
        let fx = u - Double(x), fy = v - Double(y)
        let weights = [(1 - fx) * (1 - fy), fx * (1 - fy), (1 - fx) * fy, fx * fy]
        var color = SIMD3<Double>.zero
        for (i, weight) in zip(indices, weights) {
            color += SIMD3(Double(source[i]), Double(source[i + 1]), Double(source[i + 2])) * weight
        }
        return color
    }

    private static func fit(_ points: [SIMD2<Double>], origin: SIMD2<Double>, unit: Double) -> Circle? {
        let p = points.map { ($0 - origin) / unit }
        var matrix = [[Double]](repeating: [Double](repeating: 0, count: 3), count: 3)
        var rhs = [Double](repeating: 0, count: 3)
        for point in p {
            let row = [2 * point.x, 2 * point.y, 1.0], target = dot(point, point)
            for i in 0..<3 { rhs[i] += row[i] * target
                for j in 0..<3 { matrix[i][j] += row[i] * row[j] }
            }
        }
        guard let algebraic = solve(matrix, rhs) else { return nil }
        var center = SIMD2(algebraic[0], algebraic[1])
        let rSquared = algebraic[2] + dot(center, center)
        guard rSquared.isFinite, rSquared > 0 else { return nil }
        var radius = sqrt(rSquared)
        // One-source-pixel Huber scale is fixed before any candidate output.
        for _ in 0..<8 {
            matrix = [[Double]](repeating: [Double](repeating: 0, count: 3), count: 3)
            rhs = [Double](repeating: 0, count: 3)
            for point in p {
                let d = point - center, distance = length(d)
                guard distance > 1e-9 else { return nil }
                let residual = distance - radius
                let weight = min(1, (1 / unit) / max(abs(residual), 1e-12))
                let row = [-d.x / distance, -d.y / distance, -1.0]
                for i in 0..<3 { rhs[i] -= weight * row[i] * residual
                    for j in 0..<3 { matrix[i][j] += weight * row[i] * row[j] }
                }
            }
            guard let update = solve(matrix, rhs) else { return nil }
            center += SIMD2(update[0], update[1]); radius += update[2]
            guard finite(center), radius.isFinite, radius > 0 else { return nil }
            if length(SIMD2(update[0], update[1])) + abs(update[2]) < 1e-7 { break }
        }
        matrix = [[Double]](repeating: [Double](repeating: 0, count: 3), count: 3)
        for point in p {
            let d = point - center, distance = length(d)
            guard distance > 1e-9 else { return nil }
            let row = [-d.x / distance, -d.y / distance, -1.0]
            for i in 0..<3 { for j in 0..<3 { matrix[i][j] += row[i] * row[j] } }
        }
        let eigen = symmetricEigenvalues(matrix)
        guard let low = eigen.min(), let high = eigen.max(), low > 0,
              high / low <= maximumCondition else { return nil }
        return Circle(center: origin + center * unit, radius: radius * unit)
    }

    private static func residualPass(_ points: [SIMD2<Double>], circle: Circle) -> Bool {
        guard !points.isEmpty else { return false }
        var square = 0.0, maximum = 0.0
        for p in points {
            let residual = abs(length(p - circle.center) - circle.radius)
            guard residual.isFinite else { return false }
            square += residual * residual; maximum = max(maximum, residual)
        }
        return sqrt(square / Double(points.count)) <= 1 && maximum <= 2
    }

    private static func solve(_ matrix: [[Double]], _ rhs: [Double]) -> [Double]? {
        var a = (0..<3).map { matrix[$0] + [rhs[$0]] }
        for column in 0..<3 {
            let pivot = (column..<3).max(by: { abs(a[$0][column]) < abs(a[$1][column]) })!
            guard a[pivot][column].isFinite, abs(a[pivot][column]) > 1e-12 else { return nil }
            if pivot != column { a.swapAt(pivot, column) }
            let divisor = a[column][column]
            for j in column...3 { a[column][j] /= divisor }
            for i in 0..<3 where i != column {
                let factor = a[i][column]
                for j in column...3 { a[i][j] -= factor * a[column][j] }
            }
        }
        let result = a.map { $0[3] }
        return result.allSatisfy(\.isFinite) ? result : nil
    }

    private static func symmetricEigenvalues(_ matrix: [[Double]]) -> [Double] {
        var a = matrix
        for _ in 0..<12 {
            var p = 0, q = 1
            for pair in [(0, 2), (1, 2)] where abs(a[pair.0][pair.1]) > abs(a[p][q]) {
                p = pair.0; q = pair.1
            }
            if abs(a[p][q]) < 1e-12 { break }
            let angle = 0.5 * atan2(2 * a[p][q], a[q][q] - a[p][p])
            let c = cos(angle), s = sin(angle), pp = a[p][p], qq = a[q][q], pq = a[p][q]
            for k in 0..<3 where k != p && k != q {
                let kp = a[k][p], kq = a[k][q]
                a[k][p] = c * kp - s * kq; a[p][k] = a[k][p]
                a[k][q] = s * kp + c * kq; a[q][k] = a[k][q]
            }
            a[p][p] = c * c * pp - 2 * c * s * pq + s * s * qq
            a[q][q] = s * s * pp + 2 * c * s * pq + c * c * qq
            a[p][q] = 0; a[q][p] = 0
        }
        return [a[0][0], a[1][1], a[2][2]]
    }

    private static func finite(_ p: SIMD2<Double>) -> Bool { p.x.isFinite && p.y.isFinite }
    private static func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x * b.x + a.y * b.y }
    private static func length(_ p: SIMD2<Double>) -> Double { hypot(p.x, p.y) }
    private static func pointInside(_ p: SIMD2<Double>, _ contour: [SIMD2<Double>]) -> Bool {
        var inside = false
        for i in contour.indices {
            let a = contour[i], b = contour[(i + 1) % contour.count]
            if (a.y > p.y) != (b.y > p.y), p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x {
                inside.toggle()
            }
        }
        return inside
    }
    private static func boundaryDistance(_ p: SIMD2<Double>, _ contour: [SIMD2<Double>]) -> Double {
        var result = Double.infinity
        for i in contour.indices {
            let a = contour[i], v = contour[(i + 1) % contour.count] - a, denominator = dot(v, v)
            guard denominator > 0 else { continue }
            let t = min(1, max(0, dot(p - a, v) / denominator))
            result = min(result, length(p - a - v * t))
        }
        return result
    }
    private static func simple(_ contour: [SIMD2<Double>]) -> Bool {
        func orientation(_ a: SIMD2<Double>, _ b: SIMD2<Double>, _ c: SIMD2<Double>) -> Double {
            let u = b - a, v = c - a
            return u.x * v.y - u.y * v.x
        }
        func onSegment(_ a: SIMD2<Double>, _ b: SIMD2<Double>, _ p: SIMD2<Double>) -> Bool {
            abs(orientation(a, b, p)) <= 1e-9 && p.x >= min(a.x, b.x) && p.x <= max(a.x, b.x)
                && p.y >= min(a.y, b.y) && p.y <= max(a.y, b.y)
        }
        var area = 0.0
        for i in contour.indices {
            let a = contour[i], b = contour[(i + 1) % contour.count]
            guard length(b - a) > 1e-9 else { return false }
            area += a.x * b.y - a.y * b.x
            for j in (i + 1)..<contour.count {
                if j == i + 1 || (i == 0 && j == contour.count - 1) { continue }
                let c = contour[j], d = contour[(j + 1) % contour.count]
                let abC = orientation(a, b, c), abD = orientation(a, b, d)
                let cdA = orientation(c, d, a), cdB = orientation(c, d, b)
                if (abC * abD < 0 && cdA * cdB < 0) || onSegment(a, b, c) || onSegment(a, b, d)
                    || onSegment(c, d, a) || onSegment(c, d, b) { return false }
            }
        }
        return abs(area) > 1e-6
    }
}
