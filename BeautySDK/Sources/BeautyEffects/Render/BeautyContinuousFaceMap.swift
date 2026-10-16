import BeautyCore
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
    private let xs: [Double]
    private let ys: [Double]
    private let offsets: [SIMD2<Double>]
    let width: Int
    let height: Int
    let maximumGradient: Double
    let maximumDisplacement: Double

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths) {
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
        if contour[0].x > contour.last!.x { contour.reverse() }
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
        let radius = span * 0.18
        func imagePoint(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
        let imageCurve = curve.map(imagePoint)
        let minX = max(0, imageCurve.map(\.x).min()! - radius)
        let maxX = min(w, imageCurve.map(\.x).max()! + radius)
        let minY = max(0, imageCurve.map(\.y).min()! - radius)
        let maxY = min(h, imageCurve.map(\.y).max()! + radius)
        guard maxX > minX, maxY > minY else { return nil }
        // Full feature boxes are zero-displacement regions. Their edges are
        // required lattice knots so interpolation cannot bleed across them.
        let boxes = [left, right, mouth].map { points -> [Double] in
            let p = points.map(pixel)
            return [p.map(\.x).min()! - 2, p.map(\.x).max()! + 2,
                    p.map(\.y).min()! - 2, p.map(\.y).max()! + 2]
        }
        func axis(_ lo: Double, _ hi: Double, _ edges: [Double]) -> [Double] {
            Array(Set((0...64).map { lo + (hi - lo) * Double($0) / 64 }
                + edges.filter { $0 > lo && $0 < hi })).sorted()
        }
        let xs = axis(minX, maxX, boxes.flatMap { [$0[0], $0[1]] })
        let ys = axis(minY, maxY, boxes.flatMap { [$0[2], $0[3]] })
        func smooth(_ t: Double) -> Double { let v = min(1, max(0, t)); return v*v*(3-2*v) }
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
            let small = Double(values.faceSmall / BeautySafetyCaps.faceSmall)
            let lower = smooth((y + 0.04) / 0.30)
            d += SIMD2(-p.x, -(p.y - chinY * 0.12)) * (0.045 * small * lower)
            let jaw = Double(values.jawSlim / BeautySafetyCaps.jawSlim)
            let jawWeight = bell(y, 0.72, 0.35) * lateral
            d += SIMD2(-side * span * 0.030, -span * 0.008) * (jaw * jawWeight)
            let v = Double(values.faceVShape / BeautySafetyCaps.faceVShape)
            d.x -= p.x * 0.10 * v * smooth((y - 0.35) / 0.55)
            d.y -= span * 0.010 * v * bell(y, 1, 0.27)
            d.x += side * span * 0.020 * Double(values.templeFullness / BeautySafetyCaps.templeFullness) * bell(y, -0.10, 0.28)
            d.x -= side * span * 0.028 * Double(values.cheekboneSlim / BeautySafetyCaps.cheekboneSlim) * bell(y, 0.22, 0.32)
            d.x -= p.x * 0.14 * Double(values.chinTaper / BeautySafetyCaps.chinTaper) * smooth((y - 0.58) / 0.36)
            d.y += span * 0.008 * Double(values.chinTaper / BeautySafetyCaps.chinTaper) * bell(y, 1, 0.24)
            d.y += span * 0.028 * Double(values.chinLength / BeautySafetyCaps.chinLength) * bell(y, 1, 0.35)
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
            var nearest = curve[0], distance2 = Double.infinity
            for (a, b) in zip(curve, curve.dropFirst()) {
                let v = b - a, vv = v.x*v.x + v.y*v.y
                guard vv > 0 else { continue }
                let t = min(1, max(0, ((q-a).x*v.x + (q-a).y*v.y) / vv))
                let p = a + v*t, diff = q-p, dd = diff.x*diff.x + diff.y*diff.y
                if dd < distance2 { distance2 = dd; nearest = p }
            }
            var weight = distance2 < radius*radius ? pow(1-distance2/(radius*radius), 2) : 0
            for b in boxes {
                let dx = max(b[0]-x, 0, x-b[1]), dy = max(b[2]-y, 0, y-b[3])
                weight *= smooth(hypot(dx, dy) / (span * 0.07))
            }
            if x == minX || x == maxX || y == minY || y == maxY { weight = 0 }
            actual.append(displacement(nearest, strengths) * weight)
            ceiling.append(displacement(nearest, cap) * weight)
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
        let g = max(gradient(actual), gradient(ceiling))
        let magnitude = (actual+ceiling).map { hypot($0.x, $0.y) }.max() ?? 0
        guard g.isFinite, magnitude.isFinite, magnitude > 0 else { return nil }
        let pose = Double(face.denseSupport?.geometryScale ?? 1)
        guard pose.isFinite, pose > 0 else { return nil }
        let scale = min(1, g > 0 ? 0.45/g : 1, span*0.06/magnitude) * pose
        self.xs=xs; self.ys=ys; self.width=width; self.height=height
        offsets=actual.map { $0*scale }
        maximumGradient=gradient(actual)*scale
        maximumDisplacement=(actual.map { hypot($0.x, $0.y) }.max() ?? 0)*scale
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
                guard px >= xs[0], px < xs.last! else { continue }
                while col+1 < xs.count-1 && px >= xs[col+1] { col += 1 }
                let fx=(px-xs[col])/(xs[col+1]-xs[col]), i=row*xs.count+col
                let top=offsets[i]*(1-fx)+offsets[i+1]*fx
                let bottom=offsets[i+xs.count]*(1-fx)+offsets[i+xs.count+1]*fx
                let d=top*(1-fy)+bottom*fy
                guard abs(d.x)+abs(d.y) > 1e-10 else { continue }
                let sx=min(Double(width-1),max(0,Double(x)-d.x))
                let sy=min(Double(height-1),max(0,Double(y)-d.y))
                let x0=Int(floor(sx)), y0=Int(floor(sy)), x1=min(x0+1,width-1), y1=min(y0+1,height-1)
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
        return output
    }
}

extension BeautyContinuousFaceMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyContinuousFaceMap(width: \(width), height: \(height), nodeCount: \(offsets.count))" }
    var debugDescription: String { description }
    var customMirror: Mirror {
        Mirror(self, children: ["width": width, "height": height, "nodeCount": offsets.count])
    }
}
