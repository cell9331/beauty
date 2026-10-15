import BeautyCore
import BeautyDetection
import Foundation

/// Request-local source RGB deformation. Source profiles define compact support;
/// the source/target union blends immutable RGB inverse samples with the carrier.
/// Alpha, protected features and rejected source ownership remain unchanged.
struct BeautyContinuousEyebrowMap {
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
        var mask: UInt8 = 0b00110111
        if traces.count == 2 { mask |= 1 << 3 }
        if traces.contains(where: { $0.apexIndex != nil }) { mask |= 1 << 6 }
        return mask
    }

    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        init?(_ points: [SIMD2<Double>], padding: Double) {
            guard !points.isEmpty, points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return nil }
            minX = points.map(\.x).min()! - padding; maxX = points.map(\.x).max()! + padding
            minY = points.map(\.y).min()! - padding; maxY = points.map(\.y).max()! + padding
        }
        func contains(_ p: SIMD2<Double>) -> Bool { p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY }
    }
    private struct Material {
        let x: Int, y: Int, width: Int, height: Int
        let opacity: [Float]
        let sourceAlphaUnsafe: Bool
        let excluded: [Bool]
        func excludes(_ point: SIMD2<Double>) -> Bool {
            let xx = Int(floor(point.x - 0.5)), yy = Int(floor(point.y - 0.5))
            for dy in 0...1 { for dx in 0...1 {
                let px = xx + dx, py = yy + dy
                if px >= x, px < x + width, py >= y, py < y + height,
                   excluded[(py - y) * width + px - x] { return true }
            } }
            return false
        }
        func alpha(_ px: Int, _ py: Int) -> Double {
            guard px >= x, px < x + width, py >= y, py < y + height else { return 0 }
            return Double(opacity[(py - y) * width + px - x])
        }
        func coverage(_ p: SIMD2<Double>) -> Double {
            let px = p.x - 0.5, py = p.y - 0.5
            guard px >= Double(x - 1), px < Double(x + width),
                  py >= Double(y - 1), py < Double(y + height) else { return 0 }
            let x0 = Int(floor(px)), y0 = Int(floor(py))
            let fx = px - Double(x0), fy = py - Double(y0)
            let top = alpha(x0, y0) * (1 - fx) + alpha(x0 + 1, y0) * fx
            let bottom = alpha(x0, y0 + 1) * (1 - fx) + alpha(x0 + 1, y0 + 1) * fx
            return top * (1 - fy) + bottom * fy
        }
    }
    private struct Brow {
        let isLeft: Bool
        let origin: SIMD2<Double>, axis: SIMD2<Double>, normal: SIMD2<Double>
        let length: Double, halfThickness: Double
        let line: [SIMD2<Double>]
        let apex: Double?
        let apexSign: Double
        let material: Material
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axis.x + d.y * axis.y, d.x * normal.x + d.y * normal.y)
        }
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axis * p.x + normal * p.y }
        func centerline(_ u: Double) -> Double { BeautyContinuousEyebrowMap.interpolate(line, u) }
        func component(_ p: SIMD2<Double>, index: Int, value: Double, paired: Bool) -> SIMD2<Double> {
            let q = local(p), u = q.x / length, v = q.y - centerline(q.x)
            switch index {
            case 0: return SIMD2(0, 1) * (length * 0.041 * value)
            case 1: return normal * (v * 0.23 * value)
            case 2:
                let tail = BeautyContinuousEyebrowMap.smooth((u-0.20)/0.80)
                return axis * (length * (value >= 0 ? 0.055 : 0.040) * value * tail)
            case 3:
                guard paired else { return .zero }
                let head = 1-min(1,max(0,u))
                return SIMD2(isLeft ? -1.0 : 1.0, 0) * (length * (value >= 0 ? 0.055 : 0.075) * value * (0.30+0.70*head))
            case 4:
                let head = 1 - BeautyContinuousEyebrowMap.smooth(u / 0.75)
                return SIMD2(isLeft ? -1.0 : 1.0, 0) * (length * (value >= 0 ? 0.085 : 0.095) * value * head)
            case 5:
                let angle = -0.06981317007977318 * value
                let a = q.x - length * 0.65, b = q.y - centerline(length * 0.65)
                return axis * (a * (cos(angle) - 1) - b * sin(angle)) +
                    normal * (a * sin(angle) + b * (cos(angle) - 1))
            case 6:
                guard apex != nil else { return .zero }
                let lobe = BeautyContinuousEyebrowMap.smooth((u-0.15)/0.60) *
                    (1-0.30*BeautyContinuousEyebrowMap.smooth((u-0.78)/0.22))
                let amount = value >= 0 ? 0.065 : 0.017
                return SIMD2(0, 1) * (apexSign * length * amount * value * lobe)
            default: return .zero
            }
        }
    }
    private struct Field {
        let brow: Brow
        let xs: [Double], ys: [Double]
        let offsets: [SIMD2<Double>]
        let destination: Box
        func displacement(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let q = brow.local(p)
            // Edge extrapolation is confined to a zero material border. It
            // cannot expand the actual write domain or read an organ sample.
            let x = min(xs.last!, max(xs[0], q.x)), y = min(ys.last!, max(ys[0], q.y))
            let col = BeautyContinuousEyebrowMap.interval(x, axis: xs)
            let row = BeautyContinuousEyebrowMap.interval(y, axis: ys)
            let fx = (x - xs[col]) / (xs[col + 1] - xs[col]), fy = (y - ys[row]) / (ys[row + 1] - ys[row])
            let i = row * xs.count + col
            let top: SIMD2<Double> = offsets[i] * (1 - fx) + offsets[i + 1] * fx
            let bottom: SIMD2<Double> = offsets[i + xs.count] * (1 - fx) + offsets[i + xs.count + 1] * fx
            return top * (1 - fy) + bottom * fy
        }
        func inverse(_ p: SIMD2<Double>) -> SIMD2<Double> {
            var source = p
            // The admitted .45 Lipschitz field makes this a contraction. The
            // fixed iteration count gives deterministic subpixel convergence.
            for _ in 0..<18 { source = p - displacement(source) }
            return source
        }
    }

    private let fields: [Field]
    private let fieldsWithoutSpacing: [Field]
    private let hasPairedSpacing: Bool
    private let protection: [Box]
    private let ownershipMidX: Double
    private let originalRGBA: [UInt8]
    let width: Int, height: Int
    let maximumGradient: Double
    let maximumDisplacement: Double
    var admittedBrowCount: Int { fields.count }

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths,
          sourceRGBA: [UInt8]? = nil, onAdmission: ((String) -> Void)? = nil) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              Self.isEligible(face: face),
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite }),
              Self.keys.contains(where: { abs(strengths[keyPath: $0]) > Float.ulpOfOne }),
              let sourceRGBA, sourceRGBA.count == width * height * 4 else { onAdmission?("eyebrow_initial_rejected"); return nil }
        onAdmission?("eyebrow_geometry_admitted")
        let w = Double(width), h = Double(height)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * w, Double(p.y) * h) }
        let paths = [face.leftEyeSupport?.contour ?? face.leftEye, face.rightEyeSupport?.contour ?? face.rightEye,
            Self.nosePath(face), face.observedOuterLips ?? face.outerLips]
        let protection = paths.filter(Self.validPath).compactMap { Box($0.map(pixel), padding: 2) }
        var brows = [Brow]()
        let candidates: [(BeautyEyebrowSemanticTrace?, BeautyObservedEyebrowSide)] = [
            (face.observedEyebrowSupport?.left, .left), (face.observedEyebrowSupport?.right, .right)
        ]
        for (candidate, side) in candidates {
            let sideName = side == .left ? "left" : "right"
            guard let trace = candidate, trace.side == side, Self.validTrace(trace, bounds: face.bounds),
                  Self.validPath(side == .left ? paths[0] : paths[1]) else { onAdmission?("eyebrow_\(sideName)_inputs_rejected"); continue }
            let a = pixel(trace.innerEndpoint), b = pixel(trace.outerEndpoint), vector = b - a
            let length = hypot(vector.x, vector.y)
            guard length >= 6, length < min(w, h) * 0.50, abs(vector.x) > length * 0.45 else { onAdmission?("eyebrow_\(sideName)_axis_rejected"); continue }
            let axis = vector / length
            let normal = axis.x > 0 ? SIMD2(-axis.y, axis.x) : SIMD2(axis.y, -axis.x)
            let observed = trace.points.map { p -> SIMD2<Double> in
                let d = pixel(p) - a
                return SIMD2(d.x * axis.x + d.y * axis.y, d.x * normal.x + d.y * normal.y)
            }
            guard let openLine = Self.projectedCenterline(observed, length: length)
            else { onAdmission?("eyebrow_\(sideName)_source_path_rejected"); continue }
            var line=openLine,observedAxis:ClosedRange<Double>?
            if let dense=face.denseSupport {
                let indices=side == .left ? MediaPipeFaceTopology.leftBrowEnvelope : MediaPipeFaceTopology.rightBrowEnvelope
                let path=BeautyDenseFaceSupport.path(dense.mesh,indices)
                guard Self.validPath(path),BeautyDenseFaceSupport.simplePolygon(path) else {
                    onAdmission?("eyebrow_\(sideName)_source_closed_path_rejected");continue
                }
                let envelope=path.map { point -> SIMD2<Double> in
                    let d=pixel(point)-a
                    return SIMD2(d.x*axis.x+d.y*axis.y,d.x*normal.x+d.y*normal.y)
                }
                guard let closed=Self.projectedClosedCenterline(envelope,length:length) else {
                    onAdmission?("eyebrow_\(sideName)_source_closed_path_rejected");continue
                }
                // Upper-only mesh traces locate anatomy; they do not locate
                // the visible black core. The observed lower boundary supplies
                // a source prior, while RGB still registers the actual hair.
                line=closed.line;observedAxis=closed.axis
            }
            guard let visible = Self.material(sourceRGBA, width: width, height: height, origin: a,
                axis: axis, normal: normal, line: line, length: length, protection: protection,
                ownershipMidX:Double(face.bounds.midX)*w,isLeft:side == .left,observedAxis:observedAxis,
                onFailure: { onAdmission?("eyebrow_\(sideName)_\($0)") })
            else { onAdmission?("eyebrow_\(sideName)_material_rejected"); continue }
            let apex = trace.apexIndex.flatMap { i -> Double? in
                guard i > 0, i < observed.count - 1 else { return nil }
                let u = observed[i].x / length; return u > 0 && u < 1 ? u : nil
            }
            let apexSign = trace.apexIndex.map { observed[$0].y < 0 ? -1.0 : 1.0 } ?? -1
            onAdmission?("eyebrow_\(sideName)_material_admitted")
            brows.append(Brow(isLeft: side == .left, origin: a, axis: axis, normal: normal, length: length,
                halfThickness: visible.half, line: visible.line, apex: apex, apexSign: apexSign, material: visible.material))
        }
        guard !brows.isEmpty else { onAdmission?("eyebrow_no_material"); return nil }
        let paired = brows.count == 2 && brows[0].isLeft != brows[1].isLeft
        var values = zip(Self.keys, Self.caps).map { min(1, max(-1, Double(strengths[keyPath: $0.0] / $0.1))) }
        if !paired { values[3] = 0 }
        if brows.allSatisfy({ $0.apex == nil }) { values[6] = 0 }
        guard values.contains(where: { $0 != 0 }) else { return nil }
        let pose = min(1, Double(face.denseSupport?.geometryScale ?? 1))
        guard pose.isFinite, pose > 0 else { return nil }
        func buildFields(_ fieldValues:[Double],emitAdmission:Bool) -> (fields:[Field],gradient:Double,displacement:Double)? {
            var fields = [Field](), maxGradient = 0.0, maxDisplacement = 0.0
            for brow in brows {
                if brow.material.sourceAlphaUnsafe {
                    if emitAdmission { onAdmission?(brow.isLeft ? "eyebrow_left_sampling_rejected" : "eyebrow_right_sampling_rejected") }
                    continue
                }
                let minY = brow.line.map(\.y).min()! - brow.halfThickness - brow.length * 0.10
                let maxY = brow.line.map(\.y).max()! + brow.halfThickness + brow.length * 0.10
                let xs = (0...64).map { brow.length * (-0.12 + 1.24 * Double($0) / 64) }
                let ys = (0...24).map { minY + (maxY - minY) * Double($0) / 24 }
                let locations = ys.flatMap { y in xs.map { brow.image(SIMD2($0, y)) } }
                let sourceBox=Box(locations,padding:0)!
                let componentCaps=(0..<7).map { index -> ([SIMD2<Double>],[SIMD2<Double>]) in
                    let positive=locations.map { brow.component($0,index:index,value:1,paired:paired) }
                    let negative=locations.map { brow.component($0,index:index,value:-1,paired:paired) }
                    return (positive,negative)
                }
                let positiveFields=componentCaps.map { Field(brow:brow,xs:xs,ys:ys,offsets:$0.0,destination:sourceBox) }
                let negativeFields=componentCaps.map { Field(brow:brow,xs:xs,ys:ys,offsets:$0.1,destination:sourceBox) }
                var ownershipAdmission=[Double](repeating:1,count:7)
                let mid=Double(face.bounds.midX)*w,inward=brow.isLeft ? 1.0 : -1.0
                for y in brow.material.y..<(brow.material.y+brow.material.height) {
                    for x in brow.material.x..<(brow.material.x+brow.material.width) {
                        guard brow.material.alpha(x,y) > 0 else { continue }
                        let p=SIMD2(Double(x)+0.5,Double(y)+0.5)
                        // One pixel encloses the bilinear material support.
                        let margin=max(0,inward*(mid-p.x)-1)
                        let dangers=(0..<7).map { index in
                            max(0,inward*positiveFields[index].displacement(p).x,inward*negativeFields[index].displacement(p).x)
                        }
                        let total=dangers.reduce(0,+)
                        if total > 0 {
                            let allowance=min(1,margin/total)
                            for index in 0..<7 where dangers[index] > 0 { ownershipAdmission[index]=min(ownershipAdmission[index],allowance) }
                        }
                    }
                }
                var combined = [SIMD2<Double>](repeating: .zero, count: locations.count)
                for index in fieldValues.indices where fieldValues[index] != 0 {
                    let actual = locations.map { brow.component($0, index: index, value: fieldValues[index], paired: paired) }
                    let positive=componentCaps[index].0,negative=componentCaps[index].1
                    let g = max(Self.gradient(positive, xs: xs, ys: ys), Self.gradient(negative, xs: xs, ys: ys))
                    let m = max(Self.magnitude(positive), Self.magnitude(negative))
                    guard g.isFinite, m.isFinite else { return nil }
                    let admission = min(ownershipAdmission[index], g > 0 ? 0.45 / g : 1, m > 0 ? brow.length * 0.15 / m : 1)
                    for i in combined.indices { combined[i] += actual[i] * admission }
                }
                let g = Self.gradient(combined, xs: xs, ys: ys), m = Self.magnitude(combined)
                guard g.isFinite, m.isFinite else { return nil }
                if m == 0 { continue }
                let admission = min(1, g > 0 ? 0.45 / g : 1, brow.length * 0.15 / m) * pose
                let offsets = combined.map { $0 * admission }
                let targets = zip(locations, offsets).map { $0.0 + $0.1 }
                let destination = Box(targets, padding: 2)!
                let field = Field(brow: brow, xs: xs, ys: ys, offsets: offsets, destination: destination)
                // Reject a side as a whole before subtracting its old material if
                // any transported hair would touch a feature or unlike alpha.
                var safe = true
                for y in brow.material.y..<(brow.material.y + brow.material.height) {
                    for x in brow.material.x..<(brow.material.x + brow.material.width) {
                        guard brow.material.alpha(x,y) > 0 else { continue }
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                        let target = p + field.displacement(p)
                        let tx=Int(floor(target.x-0.5))
                        let ownedTarget=brow.isLeft ? Double(tx)+1.5 < mid : Double(tx)+0.5 >= mid
                        if !ownedTarget || !Self.safeSample(sourceRGBA, width: width, height: height, at: target, protection: protection) { safe = false; break }
                    }
                    if !safe { break }
                }
                if safe {
                    let x0=max(0,min(brow.material.x,Int(floor(destination.minX)))),x1=min(width,max(brow.material.x+brow.material.width,Int(ceil(destination.maxX))))
                    let y0=max(0,min(brow.material.y,Int(floor(destination.minY)))),y1=min(height,max(brow.material.y+brow.material.height,Int(ceil(destination.maxY))))
                    for y in y0..<y1 { for x in x0..<x1 {
                        let p=SIMD2(Double(x)+0.5,Double(y)+0.5),q=field.inverse(p)
                        if brow.material.excludes(p) || brow.material.excludes(q) { continue }
                        guard brow.material.alpha(x,y) > 0 || brow.material.coverage(q) > 0 else { continue }
                        let qx=Int(floor(q.x-0.5)),ownedQ=brow.isLeft ? Double(qx)+1.5 < mid : Double(qx)+0.5 >= mid
                        let ownedP=brow.isLeft ? p.x < mid : p.x >= mid
                        if !ownedP || !ownedQ || !Self.safeSample(sourceRGBA,width:width,height:height,at:q,protection:protection) ||
                            sourceRGBA[(y*width+x)*4+3] != 255 || protection.contains(where:{ $0.contains(p) }) { safe=false;break }
                    };if !safe { break } }
                }
                if safe {
                    fields.append(field); maxGradient = max(maxGradient, g * admission)
                    maxDisplacement = max(maxDisplacement, m * admission)
                    if emitAdmission { onAdmission?(brow.isLeft ? "eyebrow_left_sampling_admitted" : "eyebrow_right_sampling_admitted") }
                } else {
                    if emitAdmission { onAdmission?(brow.isLeft ? "eyebrow_left_sampling_rejected" : "eyebrow_right_sampling_rejected") }
                }
            }
            return (fields,maxGradient,maxDisplacement)
        }
        guard let complete=buildFields(values,emitAdmission:true) else { return nil }
        var selected=complete,withoutSpacing=[Field]()
        var pairedSpacing=paired && values[3] != 0
        if pairedSpacing {
            var independent=values;independent[3]=0
            guard let siblings=buildFields(independent,emitAdmission:false) else { return nil }
            if complete.fields.count == 2 {
                withoutSpacing=siblings.fields
            } else {
                // Whole-brow spacing requires both actual transported sides.
                // Rebuild only the other six fields after late target refusal.
                selected=siblings;pairedSpacing=false
                onAdmission?("eyebrow_spacing_pair_rejected")
            }
        }
        let fields=selected.fields,maxGradient=selected.gradient,maxDisplacement=selected.displacement
        guard !fields.isEmpty else { onAdmission?("eyebrow_no_admitted_field"); return nil }
        self.fields = fields; self.fieldsWithoutSpacing=withoutSpacing;self.hasPairedSpacing=pairedSpacing
        self.protection = protection; self.width = width; self.height = height
        ownershipMidX=Double(face.bounds.midX)*w
        originalRGBA=sourceRGBA
        maximumGradient = maxGradient; maximumDisplacement = maxDisplacement
    }

    /// Source-domain field inspection is internal and excluded from reflection.
    func displacement(at point: SIMD2<Double>) -> SIMD2<Double> {
        fields.reduce(SIMD2<Double>.zero) { result, field in
            let q = field.brow.local(point)
            guard q.x >= field.xs[0], q.x <= field.xs.last!, q.y >= field.ys[0], q.y <= field.ys.last! else { return result }
            return result + field.displacement(point)
        }
    }
    func operationContains(_ point: SIMD2<Double>) -> Bool {
        guard !protection.contains(where: { $0.contains(point) }) else { return false }
        return fields.contains { field in
            guard !field.brow.material.excludes(point),!field.brow.material.excludes(field.inverse(point)) else { return false }
            return field.brow.material.coverage(point) > 0 ||
                (field.destination.contains(point) && field.brow.material.coverage(field.inverse(point)) > 0)
        }
    }
    private func ownsSource(_ field:Field,_ source:[UInt8]) -> Bool {
        let material=field.brow.material,box=field.destination
        let x0=max(0,min(material.x,Int(floor(box.minX)))),x1=min(width,max(material.x+material.width,Int(ceil(box.maxX))))
        let y0=max(0,min(material.y,Int(floor(box.minY)))),y1=min(height,max(material.y+material.height,Int(ceil(box.maxY))))
        for y in y0..<y1 { for x in x0..<x1 {
            let p=SIMD2(Double(x)+0.5,Double(y)+0.5)
            let sourcePosition=field.inverse(p),moved=material.coverage(sourcePosition)
            if material.excludes(p) || material.excludes(sourcePosition) { continue }
            if material.alpha(x,y) > 0 || moved > 0 {
                let i=(y*width+x)*4
                if field.brow.isLeft ? p.x >= ownershipMidX : p.x < ownershipMidX { return false }
                if source[i+3] != 255 { return false }
                if !Self.safeSample(source,width:width,height:height,at:sourcePosition,protection:protection) { return false }
                let xx=Int(floor(sourcePosition.x-0.5)),yy=Int(floor(sourcePosition.y-0.5))
                if field.brow.isLeft ? Double(xx)+1.5 >= ownershipMidX : Double(xx)+0.5 < ownershipMidX { return false }
                for dy in 0...1 { for dx in 0...1 {
                    let j=((yy+dy)*width+xx+dx)*4
                    if (0..<4).contains(where:{ source[j+$0] != originalRGBA[j+$0] }) { return false }
                } }
                if (0..<4).contains(where:{ source[i+$0] != originalRGBA[i+$0] }) { return false }
            }
        } }
        return true
    }
    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        guard source.count == width * height * 4 else { return source }
        var output = source
        let untouched=source == originalRGBA
        // A sibling stage can invalidate source ownership after construction.
        // Pair spacing is atomic at this final admission boundary as well.
        let selectedFields=hasPairedSpacing && !untouched && !fields.allSatisfy({ ownsSource($0,source) })
            ? fieldsWithoutSpacing : fields
        for field in selectedFields {
            let material = field.brow.material, box = field.destination
            let x0 = max(0, min(material.x, Int(floor(box.minX)))), x1 = min(width, max(material.x + material.width, Int(ceil(box.maxX))))
            let y0 = max(0, min(material.y, Int(floor(box.minY)))), y1 = min(height, max(material.y + material.height, Int(ceil(box.maxY))))
            guard untouched || ownsSource(field,source) else { continue }
            for y in y0..<y1 { for x in x0..<x1 {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), i = (y * width + x) * 4
                guard source[i + 3] == 255, !protection.contains(where: { $0.contains(p) }) else { continue }
                let sourcePosition = field.inverse(p), moved = material.coverage(sourcePosition)
                guard material.alpha(x,y) > 0 || moved > 0 else { continue }
                guard !material.excludes(p),!material.excludes(sourcePosition),
                    Self.safeSample(source, width: width, height: height, at: sourcePosition, protection: protection) else { continue }
                let overlapping = selectedFields.filter { other in
                    other.brow.material.coverage(p) > 0 ||
                        (other.destination.contains(p) && other.brow.material.coverage(other.inverse(p)) > 0)
                }.count
                guard overlapping == 1 else { continue }
                let sampled=Self.sourceColor(originalRGBA,width:width,at:sourcePosition)
                let weight=max(material.alpha(x,y),moved)
                for c in 0..<3 {
                    let value=Double(source[i+c])+(sampled[c]-Double(source[i+c]))*weight
                    output[i + c] = UInt8(min(255, max(0, Int(value.rounded()))))
                }
            } }
        }
        return output
    }

    private struct BandSample {
        let u: Double, lo: Double, hi: Double
        let coreLo: Double, coreHi: Double, donorLo: Double, donorHi: Double
        let upper: SIMD3<Double>, lower: SIMD3<Double>
        let core: SIMD3<Double>?
        var rawLo:Double? = nil
        var rawHi:Double? = nil
    }
    /// Project the observed adjacent path into the source chord frame. Small
    /// detector backtracks remain observed intersections; a separated second
    /// branch rejects rather than manufacturing a replacement eyebrow.
    private static func projectedCenterline(_ observed: [SIMD2<Double>], length: Double) -> [SIMD2<Double>]? {
        var result = [SIMD2<Double>]()
        for i in 0...48 {
            let u = length * Double(i) / 48
            var crossings = [Double]()
            for j in 1..<observed.count {
                let a = observed[j-1], b = observed[j], dx = b.x-a.x
                if abs(dx) > 1e-8, u >= min(a.x,b.x)-1e-8, u <= max(a.x,b.x)+1e-8 {
                    crossings.append(a.y+(b.y-a.y)*(u-a.x)/dx)
                }
            }
            guard let lo = crossings.min(), let hi = crossings.max(), hi-lo <= length*0.08 else { return nil }
            result.append(SIMD2(u,crossings.reduce(0,+)/Double(crossings.count)))
        }
        return result
    }
    private static func projectedClosedCenterline(_ envelope:[SIMD2<Double>],length:Double)
        -> (line:[SIMD2<Double>],axis:ClosedRange<Double>)? {
        guard envelope.count >= 8,let lo=envelope.map(\.x).min(),let hi=envelope.map(\.x).max(),
              lo <= 1e-8,hi >= length-1e-8 else { return nil }
        var result=[SIMD2<Double>]()
        for i in 0...48 {
            let u=length*Double(i)/48
            var crossings=[Double]()
            for j in envelope.indices {
                let a=envelope[j],b=envelope[(j+1)%envelope.count],dx=b.x-a.x
                if abs(dx) > 1e-8,u >= min(a.x,b.x)-1e-8,u <= max(a.x,b.x)+1e-8 {
                    crossings.append(a.y+(b.y-a.y)*(u-a.x)/dx)
                }
            }
            let sorted=crossings.sorted()
            var distinct=[Double]()
            for v in sorted where distinct.last.map({ abs($0-v) > length*1e-6 }) ?? true { distinct.append(v) }
            guard let lower=distinct.first,let upper=distinct.last,distinct.count <= 2 else { return nil }
            result.append(SIMD2(u,(lower+upper)*0.5))
        }
        return (result,lo...hi)
    }
    private static func material(_ source: [UInt8], width: Int, height: Int,
        origin: SIMD2<Double>, axis: SIMD2<Double>, normal: SIMD2<Double>,
        line: [SIMD2<Double>], length: Double, protection: [Box],
        ownershipMidX:Double,isLeft:Bool,observedAxis:ClosedRange<Double>?,onFailure: ((String)->Void)?)
        -> (material: Material, line: [SIMD2<Double>], half: Double)? {
        func position(_ u: Double, _ v: Double) -> SIMD2<Double> { origin + axis * u + normal * v }
        func owned(_ p:SIMD2<Double>) -> Bool { isLeft ? p.x < ownershipMidX : p.x >= ownershipMidX }
        func ownedSample(_ p:SIMD2<Double>) -> Bool {
            let x=Int(floor(p.x-0.5)),y=Int(floor(p.y-0.5))
            let x0=Double(x)+0.5,y0=Double(y)+0.5
            return owned(SIMD2<Double>(x0,y0)) && owned(SIMD2<Double>(x0+1,y0)) &&
                owned(SIMD2<Double>(x0,y0+1)) && owned(SIMD2<Double>(x0+1,y0+1))
        }
        var sourceAlphaUnsafe=false
        // Only actual classification dependencies are retained. A point that
        // already fails bounds, protected-feature or side ownership is not an
        // alpha-dependent attempt. No nonopaque RGB is read.
        func recordAlphaDependency(_ p:SIMD2<Double>) {
            let x=p.x-0.5,y=p.y-0.5
            guard x.isFinite,y.isFinite,x >= 0,y >= 0,x < Double(width-1),y < Double(height-1),ownedSample(p) else { return }
            let xx=Int(floor(x)),yy=Int(floor(y))
            let taps=[(xx,yy),(xx+1,yy),(xx,yy+1),(xx+1,yy+1)]
            guard !taps.contains(where:{ px,py in protection.contains(where:{ $0.contains(SIMD2(Double(px)+0.5,Double(py)+0.5)) }) }) else { return }
            if taps.contains(where:{ source[($0.1*width+$0.0)*4+3] != 255 }) { sourceAlphaUnsafe=true }
        }
        func color(_ p: SIMD2<Double>) -> SIMD3<Double>? {
            recordAlphaDependency(p)
            guard safeSample(source, width: width, height: height, at: p, protection: []) else { return nil }
            let px = p.x - 0.5, py = p.y - 0.5, x = Int(floor(px)), y = Int(floor(py))
            let fx = px - Double(x), fy = py - Double(y)
            func value(_ x: Int, _ y: Int) -> SIMD3<Double> {
                let i = (y * width + x) * 4
                return SIMD3(Double(source[i]), Double(source[i + 1]), Double(source[i + 2]))
            }
            let top: SIMD3<Double> = value(x,y) * (1 - fx) + value(x+1,y) * fx
            let bottom: SIMD3<Double> = value(x,y+1) * (1 - fx) + value(x+1,y+1) * fx
            return top * (1 - fy) + bottom * fy
        }
        func luminance(_ c: SIMD3<Double>) -> Double { (c.x + c.y + c.z) / 3 }
        struct SkinDonor {
            let v: Double
            let color: SIMD3<Double>
        }
        struct SourceProfile {
            let center: Double, low: Double, dv: Double
            let score: [Double], weak: [Bool], dark: [Int]
            let colors: [SIMD3<Double>]
            let upper: SkinDonor, lower: SkinDonor
            func position(_ index: Double) -> Double { low+index*dv }
        }
        struct SourceCore {
            let lo: Double, hi: Double
            let first: Int, last: Int, peak: Int
        }
        // A small source-only median patch removes isolated strands from skin
        // donors. Every contributing sample must remain outside protected paths.
        func skinPatch(_ u: Double, _ v: Double) -> SIMD3<Double>? {
            var samples=[SIMD3<Double>]()
            for du in [-0.75,0.0,0.75] { for dv in [-0.75,0.0,0.75] {
                let p=position(u+du,v+dv)
                guard ownedSample(p) else { continue }
                recordAlphaDependency(p)
                guard safeSample(source,width:width,height:height,at:p,protection:protection),let c=color(p) else { continue }
                samples.append(c)
            } }
            guard samples.count >= 5 else { return nil }
            let i=samples.count/2
            return SIMD3(samples.map(\.x).sorted()[i],samples.map(\.y).sorted()[i],samples.map(\.z).sorted()[i])
        }
        func readProfile(_ u: Double,_ center: Double,_ upper: SkinDonor,_ lower: SkinDonor) -> SourceProfile? {
            let steps=max(24,Int(length*0.36)),dv=length*0.36/Double(steps)
            var score=[Double](),weak=[Bool](),dark=[Int](),colors=[SIMD3<Double>]()
            for k in 0...steps {
                let v=center-length*0.18+Double(k)*dv,p=position(u,v)
                if !owned(p) || protection.contains(where:{ $0.contains(p) }) { score.append(0);weak.append(false);colors.append(.zero);continue }
                guard let c=color(p) else { return nil }
                let mix=min(1,max(0,(v-upper.v)/max(1e-8,lower.v-upper.v)))
                let skin=upper.color*(1-mix)+lower.color*mix,d=skin-c
                score.append(max(0,min(luminance(d),min(d.x,d.y,d.z)*1.5)))
                weak.append(luminance(d) >= 12 && min(d.x,d.y,d.z) >= 5);colors.append(c)
                if luminance(d) >= 30 && min(d.x,d.y,d.z) >= 16 { dark.append(k) }
            }
            return SourceProfile(center:center,low:center-length*0.18,dv:dv,score:score,weak:weak,dark:dark,colors:colors,upper:upper,lower:lower)
        }
        func sourceCore(_ p: SourceProfile,_ reference: Double,registered:Bool=true) -> (SourceCore?,String?) {
            // The source trace supplies ownership. A remote forehead strand or
            // temple hair cannot win simply by being darker than the eyebrow.
            let candidates=p.dark.filter { abs(p.position(Double($0))-reference) <= length*0.12 }
            guard let peak=candidates.max(by:{ a,b in
                func rank(_ k:Int) -> Double {
                    let distance=(p.position(Double(k))-reference)/(length*0.06)
                    return p.score[k]/(1+distance*distance)
                }
                return rank(a) < rank(b)
            }) else { return (nil,nil) }
            let qualified=Set(p.dark),level=p.score[peak]*0.5
            let values=p.score.indices.map { qualified.contains($0) ? p.score[$0] : 0 }
            var first=peak,last=peak
            while first > 0,values[first-1] >= level { first -= 1 }
            while last < values.count-1,values[last+1] >= level { last += 1 }
            guard first > 0,last < values.count-1 else { return (nil,"dark_core_boundary") }
            func crossing(_ a:Int,_ b:Int) -> Double {
                let t=min(1,max(0,(level-values[a])/(values[b]-values[a])))
                return Double(a)+(Double(b)-Double(a))*t
            }
            let lo=p.position(crossing(first-1,first)),hi=p.position(crossing(last,last+1))
            if registered,hi-lo > length*0.17 { return (nil,"dark_width") }
            return (SourceCore(lo:lo,hi:hi,first:first,last:last,peak:peak),nil)
        }
        func nearbyDonor(_ u:Double,_ center:Double,_ half:Double,_ sign:Double) -> SkinDonor? {
            let start=half+length*0.025
            guard start < length*0.24 else { return nil }
            var candidates=[SkinDonor]()
            for i in 0...23 {
                let distance=start+(length*0.24-start)*Double(i)/23,v=center+sign*distance
                guard let c=skinPatch(u,v),luminance(c) >= 55 else { continue }
                // A stable source patch is required; a steep hair boundary is
                // not a skin donor even when one central pixel is bright.
                guard let a=skinPatch(u,v-0.75),let b=skinPatch(u,v+0.75),
                    abs(luminance(a)-luminance(b)) <= 12 else { continue }
                candidates.append(SkinDonor(v:v,color:c))
            }
            guard let maximum=candidates.map({ luminance($0.color) }).max() else { return nil }
            // Among the local bright plateaus, retain the nearest one. Its
            // actual coordinate is used below, preserving skin illumination.
            return candidates.first(where:{ luminance($0.color) >= maximum-6 })
        }
        var bands=[BandSample](),coherent=0
        for j in 0...48 {
            let u=length*(-0.10+1.20*Double(j)/48),observedCenter=interpolate(line,u)
            let region:String
            if u < 0 { region="head_cap" }
            else if u > length { region="tail_cap" }
            else if u <= length*0.20 { region="head_body" }
            else if u >= length*0.80 { region="tail_body" }
            else { region="central_body" }
            if let observedAxis {
                let rim=min(4,max(1.5,length*0.020))
                if u < observedAxis.lowerBound-rim || u > observedAxis.upperBound+rim {
                    // A remote cap column has no observed eyebrow provenance.
                    // Temple hair and forelocks remain source pixels. This is
                    // only axial registration admission, never a body mask.
                    let donorU=min(observedAxis.upperBound,max(observedAxis.lowerBound,u))
                    let donorCenter=interpolate(line,donorU)
                    let a=skinPatch(donorU,donorCenter-length*0.24),b=skinPatch(donorU,donorCenter+length*0.24)
                    bands.append(BandSample(u:u,lo:observedCenter,hi:observedCenter,coreLo:observedCenter,coreHi:observedCenter,
                        donorLo:donorCenter-length*0.24,donorHi:donorCenter+length*0.24,upper:a ?? b ?? .zero,lower:b ?? a ?? .zero,core:nil))
                    continue
                }
            }
            let a=skinPatch(u,observedCenter-length*0.24),b=skinPatch(u,observedCenter+length*0.24)
            guard let initialUpper=a ?? b,let initialLower=b ?? a else {
                if u < 0 || u > length {
                    bands.append(BandSample(u:u,lo:observedCenter,hi:observedCenter,coreLo:observedCenter,coreHi:observedCenter,
                        donorLo:observedCenter-length*0.24,donorHi:observedCenter+length*0.24,upper:.zero,lower:.zero,core:nil))
                    continue
                }
                onFailure?("seed_skin_sampling_\(region)_rejected");return nil
            }
            guard max(luminance(initialUpper),luminance(initialLower)) >= 55 else { onFailure?("skin_luminance_rejected");return nil }
            let coarseUpper=SkinDonor(v:observedCenter-length*0.24,color:initialUpper)
            let coarseLower=SkinDonor(v:observedCenter+length*0.24,color:initialLower)
            guard let initial=readProfile(u,observedCenter,coarseUpper,coarseLower) else { onFailure?("band_sampling_rejected");return nil }
            let (seed,seedFailure)=sourceCore(initial,observedCenter,registered:false)
            if let seedFailure,u >= 0,u <= length { onFailure?("seed_\(seedFailure)_\(region)_rejected");return nil }
            guard let seed else {
                // Source endpoint caps can contain ordinary skin or separate
                // forehead hair. No observed eyebrow core means zero material,
                // never a replacement eyebrow or a borrowed peer trace.
                bands.append(BandSample(u:u,lo:observedCenter,hi:observedCenter,coreLo:observedCenter,coreHi:observedCenter,
                    donorLo:coarseUpper.v,donorHi:coarseLower.v,upper:initialUpper,lower:initialLower,core:nil))
                continue
            }
            let center=(seed.lo+seed.hi)*0.5,half=(seed.hi-seed.lo)*0.5
            guard let upper=nearbyDonor(u,center,half,-1),let lower=nearbyDonor(u,center,half,1),upper.v < lower.v
            else { onFailure?("registered_skin_sampling_\(region)_rejected");return nil }
            guard let profile=readProfile(u,center,upper,lower) else { onFailure?("band_sampling_rejected");return nil }
            let (core,coreFailure)=sourceCore(profile,center)
            if let coreFailure { onFailure?("registered_\(coreFailure)_\(region)_rejected");return nil }
            guard let core else {
                bands.append(BandSample(u:u,lo:center,hi:center,coreLo:center,coreHi:center,
                    donorLo:upper.v,donorHi:lower.v,upper:upper.color,lower:lower.color,core:nil))
                continue
            }
            var first=core.first,last=core.last
            // Only the connected source lobe belonging to this eyebrow can
            // extend its fringe; global dark extrema include forehead hair.
            while first > 0,profile.weak[first-1],profile.score[first-1] <= profile.score[first]+12 { first -= 1 }
            while last < profile.score.count-1,profile.weak[last+1],profile.score[last+1] <= profile.score[last]+12 { last += 1 }
            guard first > 0,last < profile.score.count-1 else { onFailure?("registered_fringe_boundary_\(region)_rejected");return nil }
            let ownedDark=profile.dark.filter { $0 >= first && $0 <= last }
            guard !ownedDark.isEmpty else { onFailure?("source_core_rejected");return nil }
            let coreColor=ownedDark.reduce(SIMD3<Double>.zero) { $0+profile.colors[$1] }/Double(ownedDark.count)
            let rawLo=profile.position(Double(first))-profile.dv*0.5,rawHi=profile.position(Double(last))+profile.dv*0.5
            // The strong connected lobe supplies qualification. Its outward
            // antialiased cover must then reach the weak source contrast tail;
            // the old twelve-level cutoff cannot be a hard material edge.
            while first > 1,profile.score[first-1] > 1,profile.score[first-1] <= profile.score[first]+1 { first -= 1 }
            while last < profile.score.count-2,profile.score[last+1] > 1,profile.score[last+1] <= profile.score[last]+1 { last += 1 }
            if let previous=bands.last,previous.core != nil {
                let step=(core.lo+core.hi)*0.5-(previous.coreLo+previous.coreHi)*0.5
                guard abs(step) <= length*0.08 else { onFailure?("source_branch_\(region)_rejected");return nil }
            }
            if u >= length*0.10,u <= length*0.90 { coherent += 1 }
            bands.append(BandSample(u:u,lo:profile.position(Double(first))-profile.dv*0.5,hi:profile.position(Double(last))+profile.dv*0.5,
                coreLo:core.lo,coreHi:core.hi,donorLo:upper.v,donorHi:lower.v,upper:upper.color,lower:lower.color,core:coreColor,
                rawLo:rawLo,rawHi:rawHi))
        }
        guard coherent >= 28 else { onFailure?("dark_coherence_rejected"); return nil }
        let bandAxis = bands.map(\.u)
        func band(_ u: Double) -> (lo: Double, hi: Double,coreLo:Double,coreHi:Double,donorLo:Double,donorHi:Double,
                                  upper: SIMD3<Double>, lower: SIMD3<Double>, core: SIMD3<Double>) {
            let index = interval(u, axis: bandAxis), a = bands[index], b = bands[index + 1]
            let t = min(1, max(0, (u - a.u) / (b.u - a.u)))
            let core: SIMD3<Double>
            if let ac = a.core, let bc = b.core { core = ac*(1-t)+bc*t }
            else { core = a.core ?? b.core ?? (a.upper+a.lower)*0.5 }
            return (a.lo + (b.lo - a.lo) * t, a.hi + (b.hi - a.hi) * t,
                a.coreLo+(b.coreLo-a.coreLo)*t,a.coreHi+(b.coreHi-a.coreHi)*t,a.donorLo+(b.donorLo-a.donorLo)*t,a.donorHi+(b.donorHi-a.donorHi)*t,
                a.upper * (1-t) + b.upper * t, a.lower * (1-t) + b.lower * t, core)
        }
        let half = bands.map { ($0.coreHi - $0.coreLo) * 0.5 }.max()!
        guard half >= 0.75 else { return nil }
        let registered = line.map { p -> SIMD2<Double> in
            let b = band(p.x)
            return SIMD2(p.x, b.coreHi > b.coreLo ? (b.coreLo+b.coreHi)*0.5 : p.y)
        }
        // Skin is a continuous source surface, not independently selected
        // bright columns. Stable bare-skin samples on both sides retain the
        // local low-frequency illumination and reject narrow hair texture.
        func texture(_ x:Int,_ y:Int) -> (luma:Double,minimum:Double)? {
            var values=[SIMD3<Double>]()
            for dy in -2...2 { for dx in -2...2 {
                let xx=x+dx,yy=y+dy
                guard xx >= 0,xx < width,yy >= 0,yy < height else { continue }
                let p=SIMD2(Double(xx)+0.5,Double(yy)+0.5),i=(yy*width+xx)*4
                guard owned(p),!protection.contains(where:{ $0.contains(p) }) else { continue }
                guard source[i+3] == 255 else { sourceAlphaUnsafe=true;continue }
                values.append(SIMD3(Double(source[i]),Double(source[i+1]),Double(source[i+2])))
            } }
            guard values.count >= 13 else { return nil }
            let index=values.count/2
            let median=SIMD3(values.map(\.x).sorted()[index],values.map(\.y).sorted()[index],values.map(\.z).sorted()[index])
            let i=(y*width+x)*4
            guard source[i+3] == 255 else {
                let p=SIMD2(Double(x)+0.5,Double(y)+0.5)
                if owned(p),!protection.contains(where:{ $0.contains(p) }) { sourceAlphaUnsafe=true }
                return nil
            }
            let c=SIMD3(Double(source[i]),Double(source[i+1]),Double(source[i+2])),d=median-c
            return (luminance(d),min(d.x,d.y,d.z))
        }
        var skinSamples=[(features:[Double],color:SIMD3<Double>)]()
        for sample in bands where sample.core != nil {
            let center=(sample.coreLo+sample.coreHi)*0.5,half=(sample.coreHi-sample.coreLo)*0.5
            for sign in [-1.0,1.0] { for k in 0...11 {
                let distance=half+length*(0.035+0.165*Double(k)/11),v=center+sign*distance,p=position(sample.u,v)
                guard let c=skinPatch(sample.u,v),luminance(c) >= 55 else { continue }
                let x=Int(floor(p.x)),y=Int(floor(p.y))
                guard let t=texture(x,y),t.luma <= 3 else { continue }
                let a=sample.u/length-0.5,b=v/length
                skinSamples.append(([1,a,b,a*a,a*b,b*b],c))
            } }
        }
        guard skinSamples.count >= 24 else { onFailure?("skin_surface_rejected");return nil }
        var coefficients=[SIMD3<Double>](repeating:.zero,count:6),weights=[Double](repeating:1,count:skinSamples.count)
        for iteration in 0..<3 {
            var matrix=[[Double]](repeating:[Double](repeating:0,count:6),count:6)
            var rhs=[SIMD3<Double>](repeating:.zero,count:6)
            for i in skinSamples.indices {
                let sample=skinSamples[i],weight=weights[i]
                for row in 0..<6 {
                    rhs[row] += sample.color*(weight*sample.features[row])
                    for col in 0..<6 { matrix[row][col] += weight*sample.features[row]*sample.features[col] }
                }
            }
            for i in 0..<6 { matrix[i][i] += 1e-7 }
            for col in 0..<6 {
                let pivot=(col..<6).max(by:{ abs(matrix[$0][col]) < abs(matrix[$1][col]) })!
                guard abs(matrix[pivot][col]) > 1e-12 else { onFailure?("skin_surface_rejected");return nil }
                matrix.swapAt(col,pivot);rhs.swapAt(col,pivot)
                let divisor=matrix[col][col]
                for j in col..<6 { matrix[col][j] /= divisor };rhs[col] /= divisor
                for row in 0..<6 where row != col {
                    let factor=matrix[row][col]
                    for j in col..<6 { matrix[row][j] -= factor*matrix[col][j] }
                    rhs[row] -= rhs[col]*factor
                }
            }
            coefficients=rhs
            if iteration < 2 {
                let errors=skinSamples.map { sample -> Double in
                    var predicted=SIMD3<Double>.zero
                    for i in 0..<6 { predicted += coefficients[i]*sample.features[i] }
                    let d=predicted-sample.color
                    return max(abs(d.x),abs(d.y),abs(d.z))
                }
                let sorted=errors.sorted(),scale=max(4,sorted[sorted.count/2]*2.5)
                for i in errors.indices { weights[i]=min(1,scale/max(1e-8,errors[i])) }
            }
        }
        func skinSurface(_ u:Double,_ v:Double) -> SIMD3<Double> {
            let a=u/length-0.5,b=v/length,features=[1,a,b,a*a,a*b,b*b]
            var c=SIMD3<Double>.zero
            for i in 0..<6 { c += coefficients[i]*features[i] }
            return c
        }
        let observedCores=bands.filter { $0.core != nil }
        func nearestCore(_ u:Double) -> SIMD3<Double> {
            observedCores.min(by:{ abs($0.u-u) < abs($1.u-u) })!.core!
        }
        let fringe = min(4, max(1.5, length*0.020))
        let corners = [position(-length*0.16, bands.map(\.lo).min()!-length*0.18-fringe),
            position(length*1.12, bands.map(\.lo).min()!-length*0.18-fringe),
            position(-length*0.16, bands.map(\.hi).max()!+length*0.18+fringe), position(length*1.12,bands.map(\.hi).max()!+length*0.18+fringe)]
        let x0 = max(0, Int(floor(corners.map(\.x).min()!))), x1 = min(width, Int(ceil(corners.map(\.x).max()!)))
        let y0 = max(0, Int(floor(corners.map(\.y).min()!))), y1 = min(height, Int(ceil(corners.map(\.y).max()!)))
        guard x1 > x0, y1 > y0, x1-x0 <= width, y1-y0 <= height else { return nil }
        let count=(x1-x0)*(y1-y0)
        var opacity = [Float](repeating: 0, count: count)
        // Continuous source body coverage carries the immutable photograph.
        // It does not inherit individual alpha holes from layer unmixing.
        let rawAxes=observedCores.map(\.u),rim=1.0
        func rawBand(_ u:Double) -> (lo:Double,hi:Double) {
            if observedCores.count == 1 { return (observedCores[0].rawLo!,observedCores[0].rawHi!) }
            let i=interval(u,axis:rawAxes),a=observedCores[i],b=observedCores[i+1]
            let t=min(1,max(0,(u-a.u)/(b.u-a.u)))
            let lo=a.rawLo!+(b.rawLo!-a.rawLo!)*t,hi=a.rawHi!+(b.rawHi!-a.rawHi!)*t
            let center=(a.coreLo+a.coreHi)*0.5*(1-t)+(b.coreLo+b.coreHi)*0.5*t
            let shift=interpolate(registered,u)-center
            return (lo+shift,hi+shift)
        }
        var ridgeDirections=[SIMD2<Double>?](repeating:nil,count:count)
        func luma(_ x:Int,_ y:Int) -> Double {
            let i=(y*width+x)*4
            if source[i+3] != 255 {
                let p=SIMD2(Double(x)+0.5,Double(y)+0.5)
                if owned(p),!protection.contains(where:{ $0.contains(p) }) { sourceAlphaUnsafe=true }
                return 0
            }
            return (Double(source[i])+Double(source[i+1])+Double(source[i+2]))/3
        }
        for index in 0..<count {
            let x=x0+index%(x1-x0),y=y0+index/(x1-x0),p=SIMD2(Double(x)+0.5,Double(y)+0.5)
            guard x > 0,x < width-1,y > 0,y < height-1,owned(p),
                  source[(y*width+x)*4+3] == 255,!protection.contains(where:{ $0.contains(p) }),
                  let t=texture(x,y),t.luma >= 3,t.minimum >= 1 else { continue }
            let c=luma(x,y),xx=luma(x-1,y)+luma(x+1,y)-2*c,yy=luma(x,y-1)+luma(x,y+1)-2*c
            let xy=(luma(x-1,y-1)+luma(x+1,y+1)-luma(x-1,y+1)-luma(x+1,y-1))*0.25
            let separation=hypot(xx-yy,2*xy),maximum=(xx+yy+separation)*0.5,minimum=(xx+yy-separation)*0.5
            guard maximum >= 3,maximum-abs(minimum) >= 2 else { continue }
            var direction=SIMD2(xx-maximum,xy)
            if hypot(direction.x,direction.y) < 1e-8 { direction=xx >= yy ? SIMD2(0,1) : SIMD2(1,0) }
            else { direction /= hypot(direction.x,direction.y) }
            ridgeDirections[index]=direction
        }
        var excluded=[Bool](repeating:false,count:count)
        for initial in 0..<count {
            guard var direction=ridgeDirections[initial] else { continue }
            let x=x0+initial%(x1-x0),y=y0+initial/(x1-x0),p=SIMD2(Double(x)+0.5,Double(y)+0.5),q=p-origin
            let u=q.x*axis.x+q.y*axis.y,v=q.x*normal.x+q.y*normal.y,b=rawBand(u)
            guard u >= -length*0.12,u <= length*1.06,v < b.lo-2,
                  abs(direction.x*normal.x+direction.y*normal.y) >= 0.55 else { continue }
            if direction.x*normal.x+direction.y*normal.y < 0 { direction = -direction }
            var path=[initial],current=initial,minV=v,maxV=v,entered=false
            for _ in 0..<max(12,Int(length*0.6)) {
                let cx=current%(x1-x0),cy=current/(x1-x0)
                var next:Int?,nextDirection=direction,best = -Double.infinity
                for dy in -2...2 { for dx in -2...2 where dx != 0 || dy != 0 {
                    let xx=cx+dx,yy=cy+dy,distance=hypot(Double(dx),Double(dy))
                    guard distance <= 2.5,xx >= 0,xx < x1-x0,yy >= 0,yy < y1-y0 else { continue }
                    let candidate=yy*(x1-x0)+xx
                    guard !path.contains(candidate),var tangent=ridgeDirections[candidate] else { continue }
                    let forward=(Double(dx)*direction.x+Double(dy)*direction.y)/distance
                    let alignment=abs(tangent.x*direction.x+tangent.y*direction.y)
                    guard forward >= 0.7,alignment >= 0.75 else { continue }
                    let score=forward+alignment-distance*0.05
                    if score > best {
                        if tangent.x*direction.x+tangent.y*direction.y < 0 { tangent = -tangent }
                        best=score;next=candidate;nextDirection=tangent
                    }
                } }
                guard let next else { break }
                current=next;direction=nextDirection;path.append(next)
                let point=SIMD2(Double(x0+next%(x1-x0))+0.5,Double(y0+next/(x1-x0))+0.5),d=point-origin
                let uu=d.x*axis.x+d.y*axis.y,vv=d.x*normal.x+d.y*normal.y,bb=rawBand(uu)
                minV=min(minV,vv);maxV=max(maxV,vv)
                if vv >= bb.lo,vv <= bb.hi { entered=true }
            }
            guard entered,maxV-minV >= length*0.12 else { continue }
            for index in path {
                let xx=index%(x1-x0),yy=index/(x1-x0)
                for dy in -1...1 { for dx in -1...1 {
                    let x=xx+dx,y=yy+dy
                    if x >= 0,x < x1-x0,y >= 0,y < y1-y0 { excluded[y*(x1-x0)+x]=true }
                } }
            }
        }
        // Source-cap qualification uses the nearest
        // safe bare patches beside its own raw band, not a quadratic fit
        // extrapolated outside the observed dark-core stations.
        func localCapSkin(_ u:Double,_ v:Double) -> SIMD3<Double>? {
            let band=rawBand(u)
            func donor(_ sign:Double) -> SkinDonor? {
                for distance in 2...8 {
                    let vv=(sign < 0 ? band.lo : band.hi)+sign*Double(distance)
                    let p=position(u,vv),x=Int(floor(p.x)),y=Int(floor(p.y))
                    guard x >= 2,x < width-2,y >= 2,y < height-2,
                          let t=texture(x,y),abs(t.luma) <= 3,
                          let c=skinPatch(u,vv),let a=skinPatch(u,vv-0.75),let b=skinPatch(u,vv+0.75),
                          luminance(c) >= 55,abs(luminance(a)-luminance(b)) <= 12 else { continue }
                    var bare=true
                    for du in [-0.75,0.0,0.75] { for dv in [-0.75,0.0,0.75] {
                        let point=position(u+du,vv+dv),relative=point-origin
                        let uu=relative.x*axis.x+relative.y*axis.y,vvv=relative.x*normal.x+relative.y*normal.y,ownBand=rawBand(uu)
                        if !(vvv < ownBand.lo-0.5 || vvv > ownBand.hi+0.5) { bare=false }
                    } }
                    if bare { return SkinDonor(v:vv,color:c) }
                }
                return nil
            }
            guard let upper=donor(-1),let lower=donor(1),upper.v < lower.v else { return nil }
            let mix=min(1,max(0,(v-upper.v)/(lower.v-upper.v)))
            return upper.color*(1-mix)+lower.color*mix
        }
        let head=observedCores[0].u-length*0.10,tail=observedCores.last!.u+length*0.02
        for index in 0..<count {
            let x=x0+index%(x1-x0),y=y0+index/(x1-x0),p=SIMD2(Double(x)+0.5,Double(y)+0.5),q=p-origin
            let u=q.x*axis.x+q.y*axis.y,v=q.x*normal.x+q.y*normal.y,b=rawBand(u)
            guard owned(p),!excluded[index],source[(y*width+x)*4+3] == 255,
                  !protection.contains(where:{ $0.contains(p) }) else { continue }
            let clearance=min(u-head,tail-u,v-b.lo,b.hi-v)
            if u < observedCores[0].u || u > observedCores.last!.u {
                let i=(y*width+x)*4,original=SIMD3(Double(source[i]),Double(source[i+1]),Double(source[i+2]))
                guard let skin=localCapSkin(u,v) else { continue }
                let core=nearestCore(u),difference=skin-original
                let limit=luminance(core)+(luminance(skin)-luminance(core))*0.96
                guard luminance(difference) > 3,min(difference.x,difference.y,difference.z) > 1,
                      luminance(original) <= limit else { continue }
            }
            opacity[index]=Float(smooth((clearance+rim)/rim))
        }
        let pixelCount=opacity.reduce(0) { $0+($1 > 0 ? 1 : 0) }
        guard pixelCount >= max(8, Int(length*2)) else { onFailure?("material_coverage_rejected"); return nil }
        return (Material(x:x0,y:y0,width:x1-x0,height:y1-y0,opacity:opacity,sourceAlphaUnsafe:sourceAlphaUnsafe,excluded:excluded),registered,half)
    }
    private static func sourceColor(_ source:[UInt8],width:Int,at point:SIMD2<Double>) -> SIMD3<Double> {
        let xx=point.x-0.5,yy=point.y-0.5,x=Int(floor(xx)),y=Int(floor(yy)),fx=xx-Double(x),fy=yy-Double(y)
        func color(_ x:Int,_ y:Int) -> SIMD3<Double> {
            let i=(y*width+x)*4
            return SIMD3(Double(source[i]),Double(source[i+1]),Double(source[i+2]))
        }
        let top:SIMD3<Double>=color(x,y)*(1-fx)+color(x+1,y)*fx
        let bottom:SIMD3<Double>=color(x,y+1)*(1-fx)+color(x+1,y+1)*fx
        return top*(1-fy)+bottom*fy
    }
    private static func safeSample(_ source:[UInt8],width:Int,height:Int,at p:SIMD2<Double>,protection:[Box]) -> Bool {
        let x = p.x-0.5, y = p.y-0.5
        guard x.isFinite,y.isFinite,x >= 0,y >= 0,x < Double(width-1),y < Double(height-1) else { return false }
        let x0=Int(floor(x)),y0=Int(floor(y))
        for (px,py) in [(x0,y0),(x0+1,y0),(x0,y0+1),(x0+1,y0+1)] {
            if source[(py*width+px)*4+3] != 255 || protection.contains(where: { $0.contains(SIMD2(Double(px)+0.5,Double(py)+0.5)) }) { return false }
        }
        return true
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
    private static func nonzero(_ c:SIMD3<Double>) -> Bool { abs(c.x)+abs(c.y)+abs(c.z) > 1e-8 }
    private static func smooth(_ x:Double) -> Double { let v=min(1,max(0,x));return v*v*(3-2*v) }
    private static func interpolate(_ line:[SIMD2<Double>],_ x:Double) -> Double {
        if x <= line[0].x { return line[0].y }
        if x >= line.last!.x { return line.last!.y }
        for i in 1..<line.count where x <= line[i].x {
            let a=line[i-1],b=line[i]
            return a.y+(b.y-a.y)*(x-a.x)/(b.x-a.x)
        }
        return line.last!.y
    }
    private static func interval(_ value:Double,axis:[Double]) -> Int {
        var lo=0,hi=axis.count-1
        while hi-lo > 1 { let mid=(lo+hi)/2;if value < axis[mid] { hi=mid } else { lo=mid } }
        return lo
    }
    private static func magnitude(_ d:[SIMD2<Double>]) -> Double { d.map { hypot($0.x,$0.y) }.max() ?? 0 }
    private static func gradient(_ d:[SIMD2<Double>],xs:[Double],ys:[Double]) -> Double {
        var maximum=0.0
        for row in 0..<(ys.count-1) { for col in 0..<(xs.count-1) {
            let i=row*xs.count+col,tl=d[i],tr=d[i+1],bl=d[i+xs.count],br=d[i+xs.count+1]
            let dx=xs[col+1]-xs[col],dy=ys[row+1]-ys[row]
            for gx in [(tr-tl)/dx,(br-bl)/dx] { for gy in [(bl-tl)/dy,(br-tr)/dy] {
                maximum=max(maximum,sqrt(gx.x*gx.x+gx.y*gx.y+gy.x*gy.x+gy.y*gy.y))
            } }
        } }
        return maximum
    }
}

extension BeautyContinuousEyebrowMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description:String { "BeautyContinuousEyebrowMap(width: \(width), height: \(height), browCount: \(fields.count))" }
    var debugDescription:String { description }
    var customMirror:Mirror { Mirror(self,children:["width":width,"height":height,"browCount":fields.count]) }
}
