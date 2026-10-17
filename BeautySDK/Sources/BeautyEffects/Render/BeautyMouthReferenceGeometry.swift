import BeautyCore
import Foundation

/// Request-local source geometry. No points or image-derived masks are retained.
struct BeautyMouthReferenceGeometry {
    typealias Point = SIMD2<Double>
    typealias Model = BeautyMouthReferenceModel
    let origin: Point
    let axisX: Point
    let axisY: Point
    let span: Double
    let outer: [Point]
    let inner: [Point]?
    let seam: Model.Seam
    let top: Double
    let bottom: Double
    let upperDepth: Double
    let lowerDepth: Double
    let protectedTop: Double
    let pose: Double

    static func eligible(face: FaceGeometry) -> UInt8 {
        guard let g = Self(width: 1000, height: 1000, face: face) else { return 0 }
        return g.inner == nil ? 63 : 255
    }

    init?(width: Int, height: Int, face: FaceGeometry) {
        guard width > 1, height > 1, face.freshness == .fresh,
              face.bounds.x.isFinite, face.bounds.y.isFinite,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.bounds.minX >= 0, face.bounds.minY >= 0,
              face.bounds.maxX <= 1, face.bounds.maxY <= 1,
              let rawOuter = face.observedOuterLips, Self.validContour(rawOuter),
              rawOuter.allSatisfy({ $0.x >= face.bounds.minX && $0.x <= face.bounds.maxX
                  && $0.y >= face.bounds.minY && $0.y <= face.bounds.maxY }),
              BeautyDenseFaceSupport.simplePolygon(rawOuter) else { return nil }
        let leftEye = face.leftEyeSupport?.contour ?? face.leftEye
        let rightEye = face.rightEyeSupport?.contour ?? face.rightEye
        let nose = face.observedNoseSupport.map {
            ($0.crest + $0.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        } ?? face.nose
        guard Self.validContour(leftEye), Self.validContour(rightEye),
              (3...64).contains(nose.count), nose.allSatisfy(Self.valid), Set(nose).count >= 3 else { return nil }
        let pose = Double(face.denseSupport?.geometryScale ?? 1)
        guard pose.isFinite, pose > 0, pose <= 1 else { return nil }
        func pixel(_ p: SIMD2<Float>) -> Point { Point(Double(p.x) * Double(width), Double(p.y) * Double(height)) }
        let pixels = rawOuter.map(pixel)
        guard let left = pixels.min(by: { $0.x < $1.x }), let right = pixels.max(by: { $0.x < $1.x }) else { return nil }
        let vector = right - left, span = hypot(vector.x, vector.y)
        guard span >= 6 else { return nil }
        let axisX = vector / span, axisY = Point(-axisX.y, axisX.x), origin = (left + right) * 0.5
        func local(_ p: Point) -> Point {
            let d = p - origin
            return Point(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y) / span
        }
        let outer = pixels.map(local)
        let top = outer.map(\.y).min()!, bottom = outer.map(\.y).max()!
        guard bottom - top > 0.006, bottom - top < 0.85,
              abs(Self.area(outer)) > (bottom - top) * 0.15 else { return nil }
        var inner: [Point]?
        var closedSeam: Model.Seam?
        if let raw = face.observedInnerLips, (4...64).contains(raw.count), raw.allSatisfy(Self.valid) {
            let q = raw.map { local(pixel($0)) }
            let minX = q.map(\.x).min()!, maxX = q.map(\.x).max()!
            if maxX - minX >= 0.25, q.allSatisfy({ $0.x >= -0.525 && $0.x <= 0.525
                && $0.y >= top - 0.025 && $0.y <= bottom + 0.025
                && Self.contains($0, polygon: outer, tolerance: 0.025) }) {
                if Set(raw).count == raw.count, BeautyDenseFaceSupport.simplePolygon(raw) {
                    inner = q
                } else if let seam = Self.closedObservedSeam(q, top: top, bottom: bottom) {
                    // A closed lip seam is observed tissue support even when
                    // contact or a slight crossing leaves no simple oral area.
                    inner = q; closedSeam = seam
                }
            }
        }
        let source = inner ?? outer
        let low = max(-0.48, source.map(\.x).min()! + 0.001)
        let high = min(0.48, source.map(\.x).max()! - 0.001)
        guard high > low else { return nil }
        var knots = [Point]()
        for i in 0...8 {
            let x = low + (high - low) * Double(i) / 8
            guard let range = Self.verticalSpan(source, x: x) else { return nil }
            knots.append(Point(x, (range.0 + range.1) * 0.5))
        }
        guard let seam = closedSeam ?? Model.Seam(knots: knots) else { return nil }
        let center = seam.sample(at: 0).value
        // A source-fixed half-plane containing every physical eye/nose box is
        // outside all field support. This avoids an unaccounted mask derivative.
        var protectedTop = -Double.infinity
        for points in [leftEye, rightEye, nose] {
            let p = points.map(pixel), pad = 2.0
            let x0 = p.map(\.x).min()! - pad, x1 = p.map(\.x).max()! + pad
            let y0 = p.map(\.y).min()! - pad, y1 = p.map(\.y).max()! + pad
            protectedTop = max(protectedTop, [Point(x0,y0),Point(x1,y0),Point(x0,y1),Point(x1,y1)].map(local).map(\.y).max()!)
        }
        guard protectedTop < top - 0.001 else { return nil }
        self.origin = origin; self.axisX = axisX; self.axisY = axisY; self.span = span
        self.outer = outer; self.inner = inner; self.seam = seam
        self.top = top; self.bottom = bottom
        self.upperDepth = max(0.008, center - top)
        self.lowerDepth = max(0.008, bottom - center)
        self.protectedTop = protectedTop; self.pose = pose
    }

    func local(_ p: Point) -> Point {
        let d = p - origin
        return Point(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y) / span
    }
    func image(_ p: Point) -> Point { origin + span * (axisX * p.x + axisY * p.y) }
    func vectorToLocal(_ v: Point) -> Point { Point(v.x * axisX.x + v.y * axisX.y, v.x * axisY.x + v.y * axisY.y) }

    func configuration() -> Model.Configuration? {
        let center = Point(0, seam.sample(at: 0).value)
        func envelope(innerX: Double = 0.53, outerX: Double = 0.94,
                      innerTop: Double, innerBottom: Double, outerTop: Double, outerBottom: Double) -> Model.Envelope {
            let lower=max(protectedTop,outerTop)
            let plateauTop=max(lower+0.0001,innerTop)
            return .init(innerMin: Point(-innerX,plateauTop),innerMax: Point(innerX,max(plateauTop,innerBottom)),
                         outerMin: Point(-outerX,lower),outerMax: Point(outerX,outerBottom))
        }
        var whole = envelope(innerTop: top - 0.015, innerBottom: bottom - 0.015,
                             outerTop: top - 0.28, outerBottom: bottom + 0.48)
        whole.radial = .init(center: center, radiusX: 0.79, radiusUp: max(0.24,upperDepth + 0.20), radiusDown: lowerDepth + 0.48, innerRadius: 0.73)
        var rotated = envelope(innerX: 0.52, outerX: 0.90, innerTop: top - 0.005, innerBottom: bottom + 0.005,
                               outerTop: top - 0.25, outerBottom: bottom + 0.40)
        rotated.radial = .init(center: center, radiusX: 0.80, radiusUp: max(0.36,upperDepth + 0.28), radiusDown: lowerDepth + 0.40, innerRadius: 0.73)
        let tissueMin = -upperDepth - 0.25
        let tissue = Model.Envelope(innerMin: Point(-0.43, -upperDepth * 0.75),
            innerMax: Point(0.43, 0.002), outerMin: Point(-0.72, tissueMin),
            outerMax: Point(0.72, lowerDepth + 0.12))
        let fullness = Model.Envelope(innerMin: Point(-0.29, max(-upperDepth - 0.005,max(-upperDepth - 0.24,protectedTop - seam.minimumValue)+0.0001)),
            innerMax: Point(0.29, lowerDepth + 0.005),
            outerMin: Point(-0.52, max(-upperDepth - 0.24, protectedTop - seam.minimumValue)),
            outerMax: Point(0.52, lowerDepth + 0.30))
        guard let profile = Model.Profile(knots: [Point(-0.60,0),Point(-0.16,-0.0039),Point(-0.06,0.0065),Point(0,0.0078),
                                                   Point(0.06,0.0065),Point(0.16,-0.0040),Point(0.60,0)]) else { return nil }
        // Initial endpoint calibration: normalized pair constraints. Choosing
        // symmetric responses around zero is a design assumption, not measured
        // neutral or single-end strength. See the local calibration report.
        return .init(seam: seam,
            size: .init(rates: Point(0.06572,0.0400), envelope: whole, center: center),
            width: .init(rates: Point(0.08283,0), envelope: whole, center: center),
            vertical: .init(vector: vectorToLocal(Point(0.00235,0.035565)), envelope: whole),
            tilt: .init(angle: 0.1375, envelope: rotated, center: center),
            horizontal: .init(vector: vectorToLocal(Point(0.096,0.00049)), envelope: whole),
            mShape: .init(profile: profile, envelope: tissue,
                lowerCenter: .init(center: Point(0,lowerDepth * 0.94),radius: Point(0.19,max(0.04,lowerDepth * 0.50)),
                                   vector: Point(0,-0.025)),
                sourceEnvelope: envelope(innerX: 0.80,outerX: 0.90,innerTop: top - 0.06,innerBottom: bottom + 0.20,outerTop: protectedTop,outerBottom: bottom + 0.30),
                profileEnvelope: .init(innerMin: Point(-1,tissueMin - 0.01),innerMax: Point(1,0.002),
                    outerMin: Point(-2,tissueMin - 0.10),outerMax: Point(2,0.075))),
            fullness: .init(upperRate: 0.30,lowerRate: 0.40,blendHalfWidth: 0.012,envelope: fullness),
            smile: .init(lobes: [
                .init(center: Point(-0.45,0.01),radius: Point(0.58,0.34),vector: Point(-0.032,-0.060)),
                .init(center: Point(0,center.y - upperDepth * 0.55),radius: Point(0.40,0.18),vector: Point(0.001,0.0055)),
                .init(center: Point(0.45,0.01),radius: Point(0.58,0.34),vector: Point(0.030,-0.060))
            ],envelope: whole,
                centralEnvelope: .init(innerMin: Point(-0.16,top + upperDepth * 0.20),
                    innerMax: Point(0.16,center.y + upperDepth * 0.05),
                    outerMin: Point(-0.28,top - 0.04),
                    outerMax: Point(0.28,center.y + upperDepth * 0.55))))
    }

    private static func valid(_ p: SIMD2<Float>) -> Bool { p.x.isFinite && p.y.isFinite && p.x >= 0 && p.x <= 1 && p.y >= 0 && p.y <= 1 }
    private static func validContour(_ p: [SIMD2<Float>]) -> Bool {
        (4...64).contains(p.count) && p.allSatisfy(valid) && Set(p).count == p.count
    }
    private static func area(_ p: [Point]) -> Double {
        p.indices.reduce(0) { s,i in let q=p[(i+1)%p.count]; return s+p[i].x*q.y-q.x*p[i].y } * 0.5
    }

    /// Admit only two source-ordered, x-monotone observations of a near-closed
    /// seam. Never sort, form a hull, fabricate an opening, or relax the shared
    /// polygon validator: missing or ambiguous inner evidence still abstains.
    private static func closedObservedSeam(_ points: [Point], top: Double, bottom: Double) -> Model.Seam? {
        guard let left = points.indices.min(by: { points[$0].x < points[$1].x }),
              let right = points.indices.max(by: { points[$0].x < points[$1].x }), left != right else { return nil }
        func trace(step: Int) -> [Point]? {
            var result = [points[left]], index = left
            for _ in 0..<points.count {
                index = (index + step + points.count) % points.count
                let p = points[index]
                if p != result.last! {
                    guard p.x > result.last!.x else { return nil }
                    result.append(p)
                }
                if index == right { return result.count >= 3 ? result : nil }
            }
            return nil
        }
        guard let a = trace(step: 1), let b = trace(step: -1),
              a[0].x == b[0].x, a.last!.x == b.last!.x else { return nil }
        let low = max(-0.48, a[0].x + 0.001), high = min(0.48, a.last!.x - 0.001)
        guard low < 0, high > 0 else { return nil }
        func value(_ trace: [Point], _ x: Double) -> Double {
            for (p, q) in zip(trace, trace.dropFirst()) where x <= q.x {
                return p.y + (q.y - p.y) * (x - p.x) / (q.x - p.x)
            }
            return trace.last!.y
        }
        let observedX = Set((a + b).map(\.x)).sorted()
        // The gap is piecewise linear: checking every original breakpoint
        // bounds its absolute value everywhere, including between seam knots.
        guard observedX.allSatisfy({ abs(value(a, $0) - value(b, $0)) <= 0.025 }) else { return nil }
        func midpoint(_ x: Double) -> Double { (value(a, x) + value(b, x)) * 0.5 }
        let knots = (0...8).map { i -> Point in
            let x = low + (high - low) * Double(i) / 8
            return Point(x, midpoint(x))
        }
        guard let seam = Model.Seam(knots: knots), seam.minimumValue >= top - 0.025,
              seam.maximumValue <= bottom + 0.025 else { return nil }
        let divisions = Set(observedX.filter { $0 > low && $0 < high } + knots.map(\.x)).sorted()
        // On each interval the reconstructed seam is cubic and the original
        // midpoint linear. Check all extrema of their difference, so a narrow
        // spike or Hermite overshoot cannot be hidden by the nine-knot fit.
        for (x0, x1) in zip(divisions, divisions.dropFirst()) {
            let h = x1 - x0, slope = (midpoint(x1) - midpoint(x0)) / h
            let d0 = seam.sample(at: x0).slope - slope
            let d1 = seam.sample(at: x1).slope - slope
            let dm = seam.sample(at: (x0 + x1) * 0.5).slope - slope
            let qa = 2 * (d0 + d1 - 2 * dm), qb = d1 - d0 - qa
            var candidates = [0.0, 1.0]
            if abs(qa) < 1e-12 {
                if abs(qb) > 1e-12 { candidates.append(-d0 / qb) }
            } else {
                let discriminant = qb * qb - 4 * qa * d0
                if discriminant >= 0 {
                    let r = sqrt(discriminant)
                    candidates += [(-qb - r) / (2 * qa), (-qb + r) / (2 * qa)]
                }
            }
            for t in candidates where t >= 0 && t <= 1 {
                let x = x0 + h * t
                guard abs(seam.sample(at: x).value - midpoint(x)) <= 0.025 else { return nil }
            }
        }
        return seam
    }
    private static func verticalSpan(_ p: [Point], x: Double) -> (Double,Double)? {
        var values = [Double]()
        for i in p.indices {
            let a=p[i],b=p[(i+1)%p.count]
            if a.x == b.x { continue }
            if x >= min(a.x,b.x), x <= max(a.x,b.x) { values.append(a.y+(b.y-a.y)*(x-a.x)/(b.x-a.x)) }
        }
        guard let low=values.min(),let high=values.max() else { return nil }; return (low,high)
    }
    private static func contains(_ p: Point, polygon: [Point], tolerance: Double) -> Bool {
        var inside=false
        for i in polygon.indices {
            let a=polygon[i],b=polygon[(i+1)%polygon.count],v=b-a
            let t=max(0,min(1,((p-a).x*v.x+(p-a).y*v.y)/(v.x*v.x+v.y*v.y)))
            let d=p-(a+v*t)
            if hypot(d.x,d.y)<=tolerance { return true }
            if (a.y>p.y) != (b.y>p.y), p.x < (b.x-a.x)*(p.y-a.y)/(b.y-a.y)+a.x { inside.toggle() }
        }
        return inside
    }
}
