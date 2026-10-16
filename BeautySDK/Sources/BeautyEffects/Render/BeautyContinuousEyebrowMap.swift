import BeautyCore
import BeautyDetection
import Foundation

/// Source-coordinate deformation of the brow AND surrounding skin. The compact
/// envelope multiplies displacement, never a blend of displaced and stationary
/// RGB. Seven controls share one admitted inverse and one immutable-source sample.
/// Default shape/amplitude parameters still require reference calibration.
struct BeautyContinuousEyebrowMap {
    typealias Model = BeautyEyebrowDisplacementModel
    // A strict contraction keeps the source inverse unique. The wider budget
    // allows visible endpoint changes while preserving a positive Jacobian.
    static let gradientBudget = 0.65
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] { [
        \.eyebrowYPosition, \.eyebrowThickness, \.eyebrowLength,
        \.eyebrowSpacing, \.eyebrowHeadSpacing, \.eyebrowTilt,
        \.eyebrowPeakDefinition
    ] }
    static var caps: [Float] { [
        BeautySafetyCaps.eyebrowYPosition, BeautySafetyCaps.eyebrowThickness,
        BeautySafetyCaps.eyebrowLength, BeautySafetyCaps.eyebrowSpacing,
        BeautySafetyCaps.eyebrowHeadSpacing, BeautySafetyCaps.eyebrowTilt,
        BeautySafetyCaps.eyebrowPeakDefinition
    ] }
    static func replacesLegacy(for face: FaceGeometry) -> Bool {
        face.denseSupport != nil || face.observedEyebrowSupport != nil
    }
    static func isEligible(face: FaceGeometry) -> Bool { eligibleFieldMask(face: face) != 0 }

    /// Geometry-only planning eligibility. Raster material admission can reject
    /// a side later; it never restores the old point-pull route.
    static func eligibleFieldMask(face: FaceGeometry) -> UInt8 {
        guard face.freshness != .stale, validBounds(face.bounds),
              face.denseSupport.map({ $0.geometryScale.isFinite && $0.geometryScale > 0 }) ?? true else { return 0 }
        guard validPath(nosePath(face)), validPath(face.observedOuterLips ?? face.outerLips) else { return 0 }
        let candidates: [(BeautyEyebrowSemanticTrace?, [SIMD2<Float>], BeautyObservedEyebrowSide)] = [
            (face.observedEyebrowSupport?.left, face.leftEyeSupport?.contour ?? face.leftEye, .left),
            (face.observedEyebrowSupport?.right, face.rightEyeSupport?.contour ?? face.rightEye, .right)
        ]
        let traces = candidates.compactMap { candidate -> BeautyEyebrowSemanticTrace? in
            let (trace, eye, side) = candidate
            guard let trace, trace.side == side, validTrace(trace, bounds: face.bounds), validPath(eye) else { return nil }
            return trace
        }
        guard !traces.isEmpty else { return 0 }
        // A displacement peak is independent of the source anatomical apex.
        var mask: UInt8 = 0b01110111
        if traces.count == 2 { mask |= 1 << 3 }
        return mask
    }


    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        init?(_ points: [SIMD2<Double>], padding: Double = 0) {
            guard !points.isEmpty, points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return nil }
            minX = points.map(\.x).min()! - padding; maxX = points.map(\.x).max()! + padding
            minY = points.map(\.y).min()! - padding; maxY = points.map(\.y).max()! + padding
        }
        var corners: [SIMD2<Double>] {
            [SIMD2(minX,minY), SIMD2(maxX,minY), SIMD2(minX,maxY), SIMD2(maxX,maxY)]
        }
        func contains(_ p: SIMD2<Double>) -> Bool {
            p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY
        }
    }
    /// Request-local inverse coordinates, with no image-derived blend weights.
    private struct Sample {
        let destination: Int, source: Int
        let fraction: SIMD2<Double>
    }
    private struct Field {
        let model: Model
        let samples: [Sample]
    }
    private let fields: [Field]
    private let fieldsWithoutSpacing: [Field]
    private let hasPairedSpacing: Bool
    private let originalRGBA: [UInt8]
    let width: Int, height: Int
    let maximumGradient: Double, maximumDisplacement: Double
    let maximumInverseContraction: Double
    var admittedBrowCount: Int { fields.count }

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths,
          sourceRGBA: [UInt8]? = nil, onAdmission: ((String) -> Void)? = nil,
          calibration: Model.Calibration = .init()) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              Self.isEligible(face: face),
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite }),
              Self.keys.contains(where: { strengths[keyPath: $0] != 0 }),
              let sourceRGBA, sourceRGBA.count == width * height * 4,
              let frame = BeautyEyebrowSourceGeometry.frame(face: face, width: width, height: height,
                onFailure: { onAdmission?("eyebrow_\($0)") })
        else { onAdmission?("eyebrow_initial_rejected"); return nil }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x) * Double(width) - 0.5, Double(p.y) * Double(height) - 0.5)
        }
        let paths = [face.leftEyeSupport?.contour ?? face.leftEye,
                     face.rightEyeSupport?.contour ?? face.rightEye,
                     Self.nosePath(face), face.observedOuterLips ?? face.outerLips]
        let protection = paths.filter(Self.validPath).compactMap { Box($0.map(pixel), padding: 2) }
        let mid = frame.midpoint
        let candidates: [(BeautyEyebrowSemanticTrace?, BeautyObservedEyebrowSide)] = [
            (face.observedEyebrowSupport?.left, .left), (face.observedEyebrowSupport?.right, .right)
        ]
        var geometries = [Model.Geometry]()
        for (candidate, side) in candidates {
            let name = side == .left ? "left" : "right"
            guard let trace = candidate, trace.side == side, Self.validTrace(trace, bounds: face.bounds),
                  let geometry = BeautyEyebrowSourceGeometry.make(width: width, height: height,
                    face: face, trace: trace, sourceRGBA: sourceRGBA,
                    horizontal: frame.horizontal, vertical: frame.vertical,
                    onFailure: { onAdmission?("eyebrow_\(name)_\($0)") })
            else { onAdmission?("eyebrow_\(name)_source_geometry_rejected"); continue }
            geometries.append(geometry)
            onAdmission?("eyebrow_\(name)_source_geometry_admitted")
        }
        guard !geometries.isEmpty else { onAdmission?("eyebrow_no_source_geometry"); return nil }
        var values = zip(Self.keys, Self.caps).map {
            min(1, max(-1, Double(strengths[keyPath: $0.0] / $0.1)))
        }
        let paired = geometries.count == 2 && geometries[0].isLeft != geometries[1].isLeft
        if !paired { values[3] = 0 }
        let pose = min(1, Double(face.denseSupport?.geometryScale ?? 1))
        guard pose.isFinite, pose > 0 else { return nil }
        values = values.map { $0 * pose }
        func build(_ requested: [Double], report: Bool) -> [Field] {
            guard requested.contains(where: { $0 != 0 }) else { return [] }
            return geometries.compactMap { geometry in
                let name = geometry.isLeft ? "left" : "right"
                let boundary = geometry.local(mid).x
                let ownerTransition = max(1.5, geometry.length * 0.025)
                guard boundary + ownerTransition < 0,
                      let supports = Self.supports(for: geometry, values: requested, ownerBoundary: boundary,
                        ownerTransition: ownerTransition, protection: protection, calibration: calibration),
                      let proposed = Model(geometry: geometry, values: requested, supports: supports,
                        calibration: calibration, ownerBoundary: boundary, ownerTransition: ownerTransition)
                else { if report { onAdmission?("eyebrow_\(name)_support_rejected") }; return nil }
                // Reserve each control's full-travel budget independently.
                // Limiting the current single field alone would cancel its raw
                // strength once saturated, making the upper slider range flat.
                // Bounds are linear in |raw|, so this factor is independent of
                // the current magnitude on either signed half of the slider.
                let normalized = requested.indices.map { index -> Double in
                    let raw = requested[index], magnitude = abs(raw)
                    guard magnitude > 0 else { return 0 }
                    let gradient = min(proposed.componentMaximumGradients[index],
                                       proposed.componentWeightedMaximumGradients[index])
                    let displacement = proposed.componentMaximumDisplacements[index]
                    let factor = min(1,
                        gradient > 0 ? magnitude * Self.gradientBudget / gradient : 1,
                        displacement > 0 ? magnitude * geometry.length * 0.15 / displacement : 1)
                    return raw * factor
                }
                guard let composed = Model(geometry: geometry, values: normalized, supports: supports,
                    calibration: calibration, ownerBoundary: boundary, ownerTransition: ownerTransition) else { return nil }
                // Simultaneous requests still share the total safe budget.
                // Reduce raw parameters BEFORE constructing finite rotations.
                let scale = min(1,
                    composed.inverseContraction > 0 ? Self.gradientBudget / composed.inverseContraction : 1,
                    composed.maximumDisplacement > 0 ? geometry.length * 0.15 / composed.maximumDisplacement : 1)
                guard let model = composed.scaled(by: scale),
                      model.inverseContraction <= Self.gradientBudget + 1e-9,
                      let samples = Self.prepareSamples(model, geometry: geometry, width: width, height: height,
                        source: sourceRGBA, protection: protection)
                else { if report { onAdmission?("eyebrow_\(name)_sampling_rejected") }; return nil }
                if report { onAdmission?("eyebrow_\(name)_sampling_admitted") }
                return Field(model: model, samples: samples)
            }
        }
        let complete = build(values, report: true)
        var selected = complete, independent = [Field]()
        var pairedSpacing = paired && values[3] != 0
        if pairedSpacing {
            var siblings = values; siblings[3] = 0
            independent = build(siblings, report: false)
            if complete.count != 2 {
                selected = independent; independent = []; pairedSpacing = false
                onAdmission?("eyebrow_spacing_pair_rejected")
            }
        }
        guard !selected.isEmpty else { onAdmission?("eyebrow_no_admitted_field"); return nil }
        self.fields = selected; fieldsWithoutSpacing = independent; hasPairedSpacing = pairedSpacing
        originalRGBA = sourceRGBA; self.width = width; self.height = height
        maximumGradient = selected.map { $0.model.maximumGradient }.max() ?? 0
        maximumDisplacement = selected.map { $0.model.maximumDisplacement }.max() ?? 0
        maximumInverseContraction = selected.map { $0.model.inverseContraction }.max() ?? 0
    }

    /// Supports occupy disjoint source half-planes and meet a stationary band.
    /// Thus the total global bound is the maximum of the two field bounds.
    func displacement(at point: SIMD2<Double>) -> SIMD2<Double> {
        fields.reduce(.zero) { $0 + $1.model.displacement(at: point) }
    }
    func operationContains(_ point: SIMD2<Double>) -> Bool {
        let d = displacement(at: point)
        return abs(d.x) + abs(d.y) > 1e-12
    }
    func applyRGBA(_ source: [UInt8], onAppliedSideCount: ((Int) -> Void)? = nil) -> [UInt8] {
        guard source.count == width * height * 4 else { onAppliedSideCount?(0); return source }
        let untouched = source == originalRGBA
        let selected = hasPairedSpacing && !untouched && !fields.allSatisfy({ ownsSource($0, source) })
            ? fieldsWithoutSpacing : fields
        var output = source
        var appliedSideCount = 0
        for field in selected {
            guard untouched || ownsSource(field, source) else { continue }
            appliedSideCount += 1
            for sample in field.samples {
                let a = sample.source, b = a + 4, c = a + width * 4, d = c + 4
                let fx = sample.fraction.x, fy = sample.fraction.y
                for channel in 0..<3 {
                    let top = Double(originalRGBA[a+channel]) * (1-fx) + Double(originalRGBA[b+channel]) * fx
                    let bottom = Double(originalRGBA[c+channel]) * (1-fx) + Double(originalRGBA[d+channel]) * fx
                    output[sample.destination+channel] = UInt8(min(255, max(0, Int((top*(1-fy)+bottom*fy).rounded()))))
                }
            }
        }
        // Quantization can leave RGB unchanged at a valid tiny strength. This
        // reports source admission, independently of visible byte differences.
        onAppliedSideCount?(appliedSideCount)
        return output
    }
    private func ownsSource(_ field: Field, _ source: [UInt8]) -> Bool {
        for sample in field.samples {
            let offsets = [sample.destination, sample.source, sample.source+4,
                           sample.source+width*4, sample.source+width*4+4]
            for offset in offsets {
                for c in 0..<4 where source[offset+c] != originalRGBA[offset+c] { return false }
            }
        }
        return true
    }

    /// Independent anatomical boxes reserve a positive stationary band BEFORE
    /// field construction; no protection edge hard-cuts a moving field/core.
    private static func supports(for geometry: Model.Geometry, values: [Double], ownerBoundary: Double,
                                 ownerTransition: Double, protection: [Box], calibration: Model.Calibration) -> [Model.Support]? {
        let length = geometry.length, minimum = max(0.5, geometry.length*0.005)
        // Independent, uncalibrated support choices; vertical is asymmetric.
        let up = [0.48, 0.24, 0.24, 0.24, 0.24, 0.24, 0.30]
        let down = [0.10, 0.14, 0.14, 0.14, 0.14, 0.14, 0.12]
        let head = [0.18, 0.16, 0.18, 0.20, 0.20, 0.20, 0.18]
        let tail = [0.20, 0.20, 0.30, 0.20, 0.20, 0.25, 0.28]
        let boxes = protection.compactMap { Box($0.corners.map(geometry.local), padding: 1.5) }
        // Bound the same r interval in all three profiles. Summing extrema
        // from unrelated head/tail positions can invent a core extending into
        // the eye and consume almost all clearance on one side.
        func coreBounds(_ range: ClosedRange<Double>) -> (top: Double, bottom: Double) {
            var knots = [range.lowerBound, range.upperBound]
            knots += (geometry.ridge.samples + geometry.upper.samples + geometry.lower.samples)
                .map(\.x).filter { $0 > range.lowerBound && $0 < range.upperBound }
            knots = Array(Set(knots)).sorted()
            if knots.count == 1 {
                let r = range.lowerBound
                return (geometry.ridge.value(at: r)-geometry.upper.value(at: r),
                        geometry.ridge.value(at: r)+geometry.lower.value(at: r))
            }
            var top = Double.infinity, bottom = -Double.infinity
            for k in 1..<knots.count {
                let mid = (knots[k-1]+knots[k])/2
                for cell in [knots[k-1]...mid, mid...knots[k]] {
                    let ridge = geometry.ridge.bounds(in: cell)
                    let upper = geometry.upper.bounds(in: cell), lower = geometry.lower.bounds(in: cell)
                    top = min(top, ridge.minimum-upper.maximum)
                    bottom = max(bottom, ridge.maximum+lower.maximum)
                }
            }
            return (top, bottom)
        }
        var result = [Model.Support]()
        for i in 0..<7 {
            if values[i] == 0 {
                result.append(Model.Support(upper: up[i]*length, lower: down[i]*length,
                                            head: head[i]*length, tail: tail[i]*length))
                continue
            }
            var rh = min(head[i]*length, -ownerBoundary-ownerTransition), rt = tail[i]*length
            let localized = i == 3 || i == 4 || i == 6
            func activeRange(_ head: Double, _ tail: Double) -> ClosedRange<Double> {
                let lower = i == 6 ? max(-head, min(length+tail, calibration.peakStartT*length)) : -head
                let upper = i == 6 ? max(lower, min(length+tail, calibration.peakEndT*length))
                    : i == 4 ? min(length+tail, calibration.headZeroT*length) : length+tail
                return lower...upper
            }
            let range = localized ? activeRange(rh, rt) : -rh...(length+rt)
            let ridge = geometry.ridge.bounds(in: range)
            let upper = geometry.upper.bounds(in: range), lower = geometry.lower.bounds(in: range)
            let core = localized ? coreBounds(range) : (top: ridge.minimum-upper.maximum, bottom: ridge.maximum+lower.maximum)
            let supportTop = core.top-up[i]*length
            let supportBottom = core.bottom+down[i]*length
            // A distant nose/lip box cannot consume head/tail clearance just
            // because its horizontal projection lies next to a brow.
            for box in boxes where box.maxY >= supportTop && box.minY <= supportBottom {
                if box.maxX < 0 { rh = min(rh, -box.maxX) }
                if box.minX > length { rt = min(rt, box.minX-length) }
            }
            guard rh > minimum, rt > minimum else { return nil }
            var ru = up[i]*length, rd = down[i]*length
            let active = localized ? activeRange(rh, rt) : -rh...(length+rt)
            for box in boxes where box.maxX > active.lowerBound && box.minX < active.upperBound {
                // A curved tail outside an eye's horizontal extent must not
                // consume the eye-side clearance of the rest of the brow.
                let range = max(active.lowerBound,box.minX)...min(active.upperBound,box.maxX)
                let ridge = geometry.ridge.bounds(in: range)
                let upper = geometry.upper.bounds(in: range), lower = geometry.lower.bounds(in: range)
                let core = localized ? coreBounds(range) : (top: ridge.minimum-upper.maximum, bottom: ridge.maximum+lower.maximum)
                let coreTop = core.top, coreBottom = core.bottom
                if box.maxY < coreTop { ru = min(ru, coreTop-box.maxY) }
                else if box.minY > coreBottom { rd = min(rd, box.minY-coreBottom) }
                else { return nil }
            }
            guard ru > minimum, rd > minimum else { return nil }
            result.append(Model.Support(upper: ru, lower: rd, head: rh, tail: rt))
        }
        return result
    }
    private static func prepareSamples(_ model: Model, geometry: Model.Geometry,
                                       width: Int, height: Int, source: [UInt8],
                                       protection: [Box]) -> [Sample]? {
        let bounds = model.localBounds()
        let outward = geometry.horizontal * (geometry.isLeft ? -1.0 : 1.0)
        func image(_ r: Double, _ y: Double) -> SIMD2<Double> {
            geometry.origin + outward*r + geometry.vertical*y
        }
        guard let box = Box([image(bounds.minR,bounds.minY), image(bounds.maxR,bounds.minY),
                             image(bounds.minR,bounds.maxY), image(bounds.maxR,bounds.maxY)],
                            padding: model.maximumDisplacement+1) else { return nil }
        let x0 = max(0,Int(floor(box.minX))), x1 = min(width-1,Int(ceil(box.maxX)))
        let y0 = max(0,Int(floor(box.minY))), y1 = min(height-1,Int(ceil(box.maxY)))
        guard x0 <= x1, y0 <= y1 else { return nil }
        var result = [Sample]()
        // Source-pixel inverse budget: admit the entire side before writing RGB.
        let epsilon = 0.000001
        // Each disjoint side uses one uniform norm: Euclidean or face-frame
        // W=diag(1,2). The latter has condition number 2, so the Euclidean
        // residual is bounded by 2*M*C^n. Still require the actual residual.
        let contraction = model.inverseContraction
        let iterations = contraction > 0 && model.maximumDisplacement > epsilon
            ? max(2, Int(ceil(log(epsilon / (2*model.maximumDisplacement)) / log(contraction))) + 2) : 2
        for y in y0...y1 { for x in x0...x1 {
            let target = SIMD2(Double(x),Double(y)), initial = model.displacement(at: SIMD2(Double(x),Double(y)))
            if initial.x == 0 && initial.y == 0 { continue }
            guard !protection.contains(where: { $0.contains(target) }), source[(y*width+x)*4+3] == 255 else { return nil }
            var p = target, converged = false
            for _ in 0..<iterations {
                let delta = model.displacement(at: p)
                let residual = p+delta-target
                if hypot(residual.x,residual.y) <= epsilon { converged = true; break }
                p = target-delta
            }
            guard converged, p.x.isFinite, p.y.isFinite,
                  p.x >= 0, p.y >= 0, p.x < Double(width-1), p.y < Double(height-1) else { return nil }
            let px = Int(floor(p.x)), py = Int(floor(p.y))
            for dy in 0...1 { for dx in 0...1 {
                let q = SIMD2(Double(px+dx),Double(py+dy))
                guard source[((py+dy)*width+px+dx)*4+3] == 255,
                      !protection.contains(where: { $0.contains(q) }) else { return nil }
            } }
            result.append(Sample(destination: (y*width+x)*4, source: (py*width+px)*4,
                                 fraction: SIMD2(p.x-Double(px),p.y-Double(py))))
        } }
        return result.isEmpty ? nil : result
    }

    private static func nosePath(_ face:FaceGeometry) -> [SIMD2<Float>] {
        face.observedNoseSupport.map { ($0.crest+$0.contour).map { SIMD2<Float>(Float($0.x),Float($0.y)) } }
            ?? (face.nose+face.noseRoot+face.noseTip)
    }
    private static func valid(_ p:SIMD2<Float>) -> Bool { p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y) }
    private static func validPath(_ path:[SIMD2<Float>]) -> Bool { path.count >= 3 && path.allSatisfy(valid) && Set(path).count >= 3 }
    private static func validBounds(_ b:FaceBounds) -> Bool {
        b.x.isFinite && b.y.isFinite && b.width.isFinite && b.height.isFinite && b.width > 0 && b.height > 0 &&
            b.minX >= 0 && b.minY >= 0 && b.maxX <= 1 && b.maxY <= 1
    }
    private static func validTrace(_ t:BeautyEyebrowSemanticTrace,bounds:FaceBounds) -> Bool {
        guard (4...16).contains(t.points.count),t.points.allSatisfy(valid),t.innerEndpoint == t.points.first,t.outerEndpoint == t.points.last,
              valid(t.center),Set(t.points).count == t.points.count,
              abs(t.innerEndpoint.x-bounds.midX) < abs(t.outerEndpoint.x-bounds.midX),
              t.side == .left ? t.outerEndpoint.x < t.innerEndpoint.x && t.center.x < bounds.midX : t.outerEndpoint.x > t.innerEndpoint.x && t.center.x > bounds.midX,
              let checked=BeautyFaceGeometryAdapter.validatedBrowTrace(t.points.map { CoordinatePoint(x:Double($0.x),y:Double($0.y)) },side:t.side,bounds:bounds)
        else { return false }
        guard checked.points == t.points, checked.innerEndpoint == t.innerEndpoint,
              checked.outerEndpoint == t.outerEndpoint,
              abs(checked.center.x-t.center.x) <= 4*Float.ulpOfOne,
              abs(checked.center.y-t.center.y) <= 4*Float.ulpOfOne else { return false }
        return t.apexIndex == nil || t.apexIndex == checked.apexIndex
    }
}

extension BeautyContinuousEyebrowMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description:String { "BeautyContinuousEyebrowMap(width: \(width), height: \(height), browCount: \(fields.count))" }
    var debugDescription:String { description }
    var customMirror:Mirror { Mirror(self,children:["width":width,"height":height,"browCount":fields.count]) }
}
