import Foundation

/// Continuous interval certificates for the six affine/platform/rotation/peak
/// fields. Every box covers a whole source rectangle, including transitions.
/// This tightens the model's simple triangle inequalities without replacing
/// them with a maximum evaluated on a finite set of source points.
enum BeautyMouthReferenceCertificate {
    typealias Model = BeautyMouthReferenceModel
    typealias Point = SIMD2<Double>

    static func bounds(model: Model, field: Model.Field, strength: Double) -> Model.Bounds {
        let fallback = model.bounds(field: field, strength: strength)
        guard strength.isFinite, strength != 0 else { return fallback }
        let c = model.configuration
        let envelope: Model.Envelope
        var extraX = [Double](), extraY = [Double]()
        switch field {
        case .size: envelope = c.size.envelope; extraX = [c.size.center.x]; extraY = [c.size.center.y]
        case .width: envelope = c.width.envelope; extraX = [c.width.center.x]; extraY = [c.width.center.y]
        case .vertical: envelope = c.vertical.envelope
        case .horizontal: envelope = c.horizontal.envelope
        case .tilt: envelope = c.tilt.envelope; extraX = [c.tilt.center.x]; extraY = [c.tilt.center.y]
        case .smile:
            envelope = c.smile.envelope
            for lobe in c.smile.lobes {
                // Values change monotonicity at the center; derivatives have
                // extrema at +/-radius/sqrt(3). Include support boundaries.
                let t = 1 / sqrt(3.0)
                for offset in [-1.0, -t, 0.0, t, 1.0] {
                    extraX.append(lobe.center.x + offset * lobe.radius.x)
                    extraY.append(lobe.center.y + offset * lobe.radius.y)
                }
            }
            if let central = c.smile.centralEnvelope {
                let cuts = envelopeBreakpoints(central)
                extraX += cuts.0; extraY += cuts.1
            }
        case .mShape, .fullness: return fallback
        }
        let (xs, ys) = partition(envelope, extraX: extraX, extraY: extraY)
        var magnitude = 0.0, gradient = 0.0
        for ix in 0..<(xs.count - 1) { for iy in 0..<(ys.count - 1) {
            let x = Interval(xs[ix], xs[ix + 1]), y = Interval(ys[iy], ys[iy + 1])
            let w = envelopeInterval(envelope, x: x, y: y)
            let sample: Enclosure
            switch field {
            case .size: sample = affine(c.size, u: strength, x: x, y: y, w: w)
            case .width: sample = affine(c.width, u: strength, x: x, y: y, w: w)
            case .vertical: sample = translation(c.vertical, u: strength, w: w)
            case .horizontal: sample = translation(c.horizontal, u: strength, w: w)
            case .tilt: sample = tilt(c.tilt, u: strength, x: x, y: y, w: w)
            case .smile: sample = smile(c.smile, u: strength, x: x, y: y, w: w)
            case .mShape, .fullness: return fallback
            }
            let m = normUpper(sample.dx.maximumAbsolute, sample.dy.maximumAbsolute)
            let g = matrixNormUpper(sample)
            guard m.isFinite, g.isFinite else { return fallback }
            magnitude = max(magnitude, m); gradient = max(gradient, g)
        } }
        // The old analytic certificate is independently valid. Their minimum
        // remains valid and protects extreme, poorly conditioned parameters.
        return .init(maximumDisplacement: min(magnitude, fallback.maximumDisplacement),
                     maximumGradient: min(gradient, fallback.maximumGradient))
    }

    /// For D=u*t*w the matrix determinant lemma gives
    /// det(I+J_D)=1+u*t·grad(w). Lines parallel to t are invariant. A positive
    /// derivative on each complete line, together with the compact exterior
    /// identity, proves global invertibility independently of perpendicular
    /// shear. This certificate bounds that directed derivative on whole boxes.
    static func minimumTranslationDeterminantOffset(model: Model, field: Model.Field,
                                                     strength: Double) -> Double {
        guard strength.isFinite else { return -.infinity }
        let translation: Model.Translation
        switch field {
        case .vertical: translation = model.configuration.vertical
        case .horizontal: translation = model.configuration.horizontal
        default: return -.infinity
        }
        guard strength != 0 else { return 0 }
        let e = translation.envelope, (xs, ys) = partition(e)
        let vx = Interval.point(translation.vector.x), vy = Interval.point(translation.vector.y)
        let u = Interval.point(strength)
        var lower = 0.0 // exterior identity and every zero support weight
        for ix in 0..<(xs.count - 1) { for iy in 0..<(ys.count - 1) {
            let w = envelopeInterval(e, x: Interval(xs[ix], xs[ix + 1]), y: Interval(ys[iy], ys[iy + 1]))
            let trace = u * (vx * w.x + vy * w.y)
            guard trace.lower.isFinite else { return -.infinity }
            lower = min(lower, trace.lower)
        } }
        return lower
    }

    /// Radius-preserving tilt is an angular map on every source circle.
    /// Its complete determinant is 1+theta*grad(w)·Omega(p-center). Strict
    /// positivity therefore proves monotonicity and a unique inverse angle
    /// on each complete circle, independent of harmless radial shear.
    static func minimumTiltDeterminantOffset(model: Model, strength: Double) -> Double {
        tiltDeterminantRange(model: model, strength: strength).lower
    }

    struct TiltDeterminantRange {
        var lower: Double
        var upper: Double
        var boxes: Int
        var reachedTolerance: Bool
    }

    /// Branch-and-bound over continuous boxes. Lower bounds always come from
    /// interval enclosures of complete boxes. Point intervals only provide an
    /// upper bound on the unknown global minimum, allowing a certified gap
    /// stop; their evaluations are never used as a lower-bound certificate.
    /// A budget/depth stop preserves every leaf box and its conservative bound.
    static func tiltDeterminantRange(model: Model, strength: Double,
                                     tolerance: Double = 0.02) -> TiltDeterminantRange {
        guard strength.isFinite, tolerance.isFinite, tolerance > 0 else {
            return .init(lower: -.infinity, upper: 0, boxes: 0, reachedTolerance: false)
        }
        guard strength != 0, model.configuration.tilt.angle != 0 else {
            return .init(lower: 0, upper: 0, boxes: 0, reachedTolerance: true)
        }
        let c = model.configuration.tilt
        let (xs, ys) = partition(c.envelope, extraX: [c.center.x], extraY: [c.center.y])
        let theta = Interval.point(c.angle) * .point(strength)
        var heap = [TiltBox](), upper = 0.0
        for ix in 0..<(xs.count - 1) { for iy in 0..<(ys.count - 1) {
            let box = TiltBox(x0: xs[ix], x1: xs[ix + 1], y0: ys[iy], y1: ys[iy + 1], depth: 0, lower: 0)
            guard let enclosed = encloseTiltBox(box, configuration: c, theta: theta) else {
                return .init(lower: -.infinity, upper: upper, boxes: heap.count, reachedTolerance: false)
            }
            push(enclosed.0, into: &heap); upper = min(upper, enclosed.1)
        } }
        var refinements = 0
        while let first = heap.first, upper - min(0, first.lower) > tolerance, refinements < 8192 {
            let box = pop(&heap)
            guard box.depth < 18 else { push(box, into: &heap); break }
            var splitX = box.depth % 2 == 0
            let midX = box.x0 + (box.x1 - box.x0) * 0.5
            let midY = box.y0 + (box.y1 - box.y0) * 0.5
            if splitX && (midX <= box.x0 || midX >= box.x1) { splitX = false }
            if !splitX && (midY <= box.y0 || midY >= box.y1) { push(box, into: &heap); break }
            var left = box, right = box
            left.depth += 1; right.depth += 1
            if splitX { left.x1 = midX; right.x0 = midX }
            else { left.y1 = midY; right.y0 = midY }
            for child in [left, right] {
                guard let enclosed = encloseTiltBox(child, configuration: c, theta: theta) else {
                    return .init(lower: -.infinity, upper: upper, boxes: heap.count, reachedTolerance: false)
                }
                push(enclosed.0, into: &heap); upper = min(upper, enclosed.1)
            }
            refinements += 1
        }
        let lower = min(0, heap.first?.lower ?? 0)
        return .init(lower: lower, upper: upper, boxes: heap.count, reachedTolerance: upper - lower <= tolerance)
    }

    private struct TiltBox {
        var x0: Double, x1: Double, y0: Double, y1: Double
        var depth: Int
        var lower: Double
    }

    private static func encloseTiltBox(_ input: TiltBox, configuration c: Model.Tilt, theta: Interval)
        -> (TiltBox, Double)? {
        var box = input
        let whole = tiltOffset(c, theta: theta, x: Interval(box.x0, box.x1), y: Interval(box.y0, box.y1))
        let x = box.x0 + (box.x1 - box.x0) * 0.5, y = box.y0 + (box.y1 - box.y0) * 0.5
        let point = tiltOffset(c, theta: theta, x: .point(x), y: .point(y))
        guard whole.lower.isFinite, point.upper.isFinite else { return nil }
        box.lower = whole.lower
        return (box, point.upper)
    }

    private static func tiltOffset(_ c: Model.Tilt, theta: Interval, x: Interval, y: Interval) -> Interval {
        var rectangle = c.envelope
        rectangle.radial = nil
        let w = envelopeInterval(rectangle, x: x, y: y)
        let rx = x - .point(c.center.x), ry = y - .point(c.center.y)
        let rectangular = w.y * rx - w.x * ry
        guard let radial = c.envelope.radial else { return theta * rectangular }
        let r = radialInterval(radial, x: x, y: y)
        let angular = radialAngularDerivative(radial, rotationCenter: c.center, x: x, y: y, range: r)
        return theta * (r.value * rectangular + w.value * angular)
    }

    /// Combine the two radial gradient components before taking intervals:
    /// grad(r)·Omega(p-center) = [dx*dy*(1/ry²-1/rx²)
    ///                         +dy*dcx/ry²-dx*dcy/rx²]/r.
    /// This retains the exact cancellation for a circular radial envelope and
    /// sharply reduces shared-coordinate dependency for elliptical envelopes.
    private static func radialAngularDerivative(_ c: Model.Radial, rotationCenter: Point,
                                                x: Interval, y: Interval, range: EnvelopeRange) -> Interval {
        let dx = x - .point(c.center.x), dy = y - .point(c.center.y)
        let ry: Interval
        if y.upper <= c.center.y { ry = .point(c.radiusUp) }
        else if y.lower >= c.center.y { ry = .point(c.radiusDown) }
        else { ry = Interval(min(c.radiusUp, c.radiusDown), max(c.radiusUp, c.radiusDown)) }
        let radius = ((dx / c.radiusX).squared + (dy / ry).squared).squareRoot.clamped(0, .infinity)
        if radius.lower >= 1 || radius.upper <= c.innerRadius { return .point(0) }
        let transition = radius.clamped(c.innerRadius, 1)
        guard transition.lower > 0 else {
            return range.y * (x - .point(rotationCenter.x)) - range.x * (y - .point(rotationCenter.y))
        }
        let width = 1 - c.innerRadius
        let z = ((radius - .point(c.innerRadius)) / width).clamped(0, 1)
        let derivative = (Interval.point(-1) * smooth3Derivative(z)) / width
        let inverseX = Interval.point(1) / Interval.point(c.radiusX).squared
        let inverseY = Interval.point(1) / ry.squared
        let cx = Interval.point(c.center.x) - .point(rotationCenter.x)
        let cy = Interval.point(c.center.y) - .point(rotationCenter.y)
        var result = derivative * (dx * dy * (inverseY - inverseX) + dy * cx * inverseY - dx * cy * inverseX) / transition
        if radius.lower <= c.innerRadius || radius.upper >= 1 { result = result.hull(.point(0)) }
        return result
    }

    private static func push(_ box: TiltBox, into heap: inout [TiltBox]) {
        heap.append(box)
        var child = heap.count - 1
        while child > 0 {
            let parent = (child - 1) / 2
            if heap[parent].lower <= heap[child].lower { break }
            heap.swapAt(parent, child); child = parent
        }
    }

    private static func pop(_ heap: inout [TiltBox]) -> TiltBox {
        let result = heap[0], last = heap.removeLast()
        guard !heap.isEmpty else { return result }
        heap[0] = last
        var parent = 0
        while 2 * parent + 1 < heap.count {
            var child = 2 * parent + 1
            if child + 1 < heap.count && heap[child + 1].lower < heap[child].lower { child += 1 }
            if heap[parent].lower <= heap[child].lower { break }
            heap.swapAt(parent, child); parent = child
        }
        return result
    }

    /// Certifies the complete linear homotopy F_s(p)=p+s*D(p), 0<=s<=scale,
    /// for size, width and smile. On each continuous source box, interval
    /// enclosure A of J_D gives det(I+s*A) >= 1+s*tr(A).lower+s²*det(A).lower.
    /// The quadratic's minimum includes its endpoints and any convex vertex.
    /// Positive determinant throughout a compact C1 perturbation of identity
    /// makes the proper planar local diffeomorphism globally invertible; this
    /// does not substitute a sampled determinant or a bound on shear norm.
    static func maximumLinearScale(model: Model, field: Model.Field, strength: Double,
                                   minimumDeterminant: Double = 0.25) -> Double {
        linearScaleRange(model: model, field: field, strength: strength,
                         minimumDeterminant: minimumDeterminant).lower
    }

    struct LinearScaleRange {
        var lower: Double
        var upper: Double
        var boxes: Int
        var reachedTolerance: Bool
    }

    /// Complete leaf-box bounds give an admissible scale lower bound. Exact
    /// point intervals give a necessary-condition upper bound on the unknown
    /// maximal admissible scale. Refinement stops at a certified gap or finite
    /// budget; a point evaluation is never used to admit a larger scale.
    static func linearScaleRange(model: Model, field: Model.Field, strength: Double,
                                 minimumDeterminant: Double = 0.25,
                                 tolerance: Double = 0.01) -> LinearScaleRange {
        guard strength.isFinite, minimumDeterminant.isFinite,
              minimumDeterminant > 0, minimumDeterminant <= 1,
              tolerance.isFinite, tolerance > 0 else {
            return .init(lower: 0, upper: 1, boxes: 0, reachedTolerance: false)
        }
        let c = model.configuration
        let e: Model.Envelope
        var extraX = [Double](), extraY = [Double]()
        switch field {
        case .size: e = c.size.envelope; extraX = [c.size.center.x]; extraY = [c.size.center.y]
        case .width: e = c.width.envelope; extraX = [c.width.center.x]; extraY = [c.width.center.y]
        case .smile:
            e = c.smile.envelope
            let critical = 1 / sqrt(3.0)
            for lobe in c.smile.lobes { for position in [-1.0, -critical, 0.0, critical, 1.0] {
                extraX.append(lobe.center.x + position * lobe.radius.x)
                extraY.append(lobe.center.y + position * lobe.radius.y)
            } }
            if let central = c.smile.centralEnvelope {
                let cuts = envelopeBreakpoints(central)
                extraX += cuts.0; extraY += cuts.1
            }
        default: return .init(lower: 0, upper: 1, boxes: 0, reachedTolerance: false)
        }
        guard strength != 0 else { return .init(lower: 1, upper: 1, boxes: 0, reachedTolerance: true) }
        let (xs, ys) = partition(e, extraX: extraX, extraY: extraY)
        var heap = [TiltBox](), upper = 1.0
        for ix in 0..<(xs.count - 1) { for iy in 0..<(ys.count - 1) {
            let box = TiltBox(x0: xs[ix], x1: xs[ix + 1], y0: ys[iy], y1: ys[iy + 1], depth: 0, lower: 0)
            guard let enclosed = encloseLinearBox(box, model: model, field: field, strength: strength,
                                                  envelope: e, minimumDeterminant: minimumDeterminant) else {
                return .init(lower: 0, upper: upper, boxes: heap.count, reachedTolerance: false)
            }
            push(enclosed.0, into: &heap); upper = min(upper, enclosed.1)
        } }
        var refinements = 0
        while let first = heap.first, upper - first.lower > tolerance, refinements < 8192 {
            let box = pop(&heap)
            guard box.depth < 18 else { push(box, into: &heap); break }
            var splitX = box.depth % 2 == 0
            let midX = box.x0 + (box.x1 - box.x0) * 0.5, midY = box.y0 + (box.y1 - box.y0) * 0.5
            if splitX && (midX <= box.x0 || midX >= box.x1) { splitX = false }
            if !splitX && (midY <= box.y0 || midY >= box.y1) { push(box, into: &heap); break }
            var left = box, right = box
            left.depth += 1; right.depth += 1
            if splitX { left.x1 = midX; right.x0 = midX }
            else { left.y1 = midY; right.y0 = midY }
            for child in [left, right] {
                guard let enclosed = encloseLinearBox(child, model: model, field: field, strength: strength,
                                                      envelope: e, minimumDeterminant: minimumDeterminant) else {
                    return .init(lower: 0, upper: upper, boxes: heap.count, reachedTolerance: false)
                }
                push(enclosed.0, into: &heap); upper = min(upper, enclosed.1)
            }
            refinements += 1
        }
        let lower = heap.first?.lower ?? 0
        return .init(lower: lower, upper: upper, boxes: heap.count, reachedTolerance: upper - lower <= tolerance)
    }

    private static func encloseLinearBox(_ input: TiltBox, model: Model, field: Model.Field, strength: Double,
                                         envelope e: Model.Envelope, minimumDeterminant: Double) -> (TiltBox, Double)? {
        func coefficients(x: Interval, y: Interval) -> (a: Interval, b: Interval)? {
            let w = envelopeInterval(e, x: x, y: y), c = model.configuration
            let a: Enclosure
            switch field {
            case .size: a = affine(c.size, u: strength, x: x, y: y, w: w)
            case .width: a = affine(c.width, u: strength, x: x, y: y, w: w)
            case .smile: a = smile(c.smile, u: strength, x: x, y: y, w: w)
            default: return nil
            }
            return (a.xx * a.yy - a.xy * a.yx, a.xx + a.yy)
        }
        var box = input
        guard let whole = coefficients(x: Interval(box.x0, box.x1), y: Interval(box.y0, box.y1)),
              let point = coefficients(x: .point(box.x0 + (box.x1 - box.x0) * 0.5),
                                       y: .point(box.y0 + (box.y1 - box.y0) * 0.5)),
              whole.a.lower.isFinite, whole.b.lower.isFinite,
              point.a.upper.isFinite, point.b.upper.isFinite else { return nil }
        box.lower = quadraticScale(a: whole.a.lower, b: whole.b.lower,
                                   minimumDeterminant: minimumDeterminant, optimistic: false)
        let upper = quadraticScale(a: point.a.upper, b: point.b.upper,
                                   minimumDeterminant: minimumDeterminant, optimistic: true)
        return (box, upper)
    }

    /// The optimistic result returns a verified *failing* high endpoint (or 1
    /// when no failure was proven), giving an upper bound. The admissible result
    /// returns only a verified feasible low endpoint. Rounding directions are
    /// different intentionally; swapping them would invalidate branch pruning.
    private static func quadraticScale(a: Double, b: Double, minimumDeterminant: Double,
                                       optimistic: Bool) -> Double {
        func minimum(_ scale: Double) -> Double {
            optimistic ? minimumQuadraticUpper(a: a, b: b, through: scale)
                : minimumQuadratic(a: a, b: b, through: scale)
        }
        if minimum(1) >= minimumDeterminant { return 1 }
        var low = 0.0, high = 1.0
        for _ in 0..<44 {
            let middle = low + (high - low) * 0.5
            if minimum(middle) >= minimumDeterminant { low = middle }
            else { high = middle }
        }
        return optimistic ? high : low
    }

    /// A lower bound on min_{0<=s<=limit}(1+b*s+a*s²), including outward
    /// arithmetic when evaluating both the endpoint and analytic vertex.
    private static func minimumQuadratic(a: Double, b: Double, through limit: Double) -> Double {
        let s = Interval.point(limit), ai = Interval.point(a), bi = Interval.point(b)
        var lower = min(1, (Interval.point(1) + bi * s + ai * s.squared).lower)
        if a > 0, b < 0 {
            let vertex = (Interval.point(-1) * bi) / (Interval.point(2) * ai)
            if vertex.upper > 0 && vertex.lower < limit {
                lower = min(lower, (Interval.point(1) - bi.squared / (Interval.point(4) * ai)).lower)
            }
        }
        return lower
    }

    /// An upper bound on the polynomial minimum, using endpoint intervals
    /// and a clamped floating point vertex that is guaranteed inside [0,limit].
    /// Any such point gives an upper bound on the minimum, even if rounding
    /// makes it differ slightly from the exact quadratic vertex.
    private static func minimumQuadraticUpper(a: Double, b: Double, through limit: Double) -> Double {
        func at(_ value: Double) -> Double {
            let s = Interval.point(value)
            return (Interval.point(1) + .point(b) * s + .point(a) * s.squared).upper
        }
        var upper = min(1, at(limit))
        if a > 0, b < 0 {
            let vertex = min(limit, max(0, (-b / a) * 0.5))
            upper = min(upper, at(vertex))
        }
        return upper
    }

    private static func partition(_ e: Model.Envelope, extraX: [Double] = [], extraY: [Double] = [])
        -> ([Double], [Double]) {
        let boundaries = envelopeBreakpoints(e)
        return (cuts(low: e.outerMin.x, high: e.outerMax.x, extras: extraX + boundaries.0),
                cuts(low: e.outerMin.y, high: e.outerMax.y, extras: extraY + boundaries.1))
    }

    private static func envelopeBreakpoints(_ e: Model.Envelope) -> ([Double], [Double]) {
        var ex = [e.outerMin.x, e.innerMin.x, e.innerMax.x, e.outerMax.x]
        var ey = [e.outerMin.y, e.innerMin.y, e.innerMax.y, e.outerMax.y]
        if let radial = e.radial {
            for radius in [radial.innerRadius, 1.0] {
                ex += [radial.center.x - radius * radial.radiusX, radial.center.x + radius * radial.radiusX]
                ey += [radial.center.y - radius * radial.radiusUp, radial.center.y + radius * radial.radiusDown]
            }
            ex.append(radial.center.x); ey.append(radial.center.y)
        }
        return (ex, ey)
    }

    private static func cuts(low: Double, high: Double, extras: [Double]) -> [Double] {
        var result = [low, high]
        for i in 1..<24 { result.append(low + (high - low) * Double(i) / 24) }
        result += extras.filter { $0 > low && $0 < high }
        return Array(Set(result)).sorted()
    }

    private struct EnvelopeRange {
        var value: Interval
        var x: Interval
        var y: Interval
    }
    private struct Enclosure {
        var dx: Interval, dy: Interval
        var xx: Interval, yx: Interval, xy: Interval, yy: Interval
    }

    private static func envelopeInterval(_ e: Model.Envelope, x: Interval, y: Interval) -> EnvelopeRange {
        let a = axis(x, outerLow: e.outerMin.x, innerLow: e.innerMin.x,
                     innerHigh: e.innerMax.x, outerHigh: e.outerMax.x)
        let b = axis(y, outerLow: e.outerMin.y, innerLow: e.innerMin.y,
                     innerHigh: e.innerMax.y, outerHigh: e.outerMax.y)
        let value = a.0 * b.0, dx = a.1 * b.0, dy = a.0 * b.1
        guard let radial = e.radial else { return EnvelopeRange(value: value, x: dx, y: dy) }
        let r = radialInterval(radial, x: x, y: y)
        return EnvelopeRange(value: value * r.value, x: dx * r.value + value * r.x,
                             y: dy * r.value + value * r.y)
    }

    /// Radial values are monotone in r. For transition gradients we enclose
    /// w'(r)*(normalizedCoordinate/r)/radius, retaining the actual angular
    /// ratio when r is separated from zero. A box crossing the r=0 platform
    /// uses the universal |normalizedCoordinate/r|<=1 bound; no division by
    /// a zero-containing interval is used. Upper/lower radius pieces meet
    /// with zero y-gradient on the common source-y center line.
    private static func radialInterval(_ c: Model.Radial, x: Interval, y: Interval) -> EnvelopeRange {
        let dx = x - .point(c.center.x), dy = y - .point(c.center.y)
        let ry: Interval
        if y.upper <= c.center.y { ry = .point(c.radiusUp) }
        else if y.lower >= c.center.y { ry = .point(c.radiusDown) }
        else { ry = Interval(min(c.radiusUp, c.radiusDown), max(c.radiusUp, c.radiusDown)) }
        let nx = dx / c.radiusX, ny = dy / ry
        let radius = (nx.squared + ny.squared).squareRoot.clamped(0, .infinity)
        if radius.lower >= 1 { return EnvelopeRange(value: .point(0), x: .point(0), y: .point(0)) }
        if radius.upper <= c.innerRadius { return EnvelopeRange(value: .point(1), x: .point(0), y: .point(0)) }
        let width = 1 - c.innerRadius
        let z = ((radius - .point(c.innerRadius)) / width).clamped(0, 1)
        let value = Interval.point(1) - smooth3(z)
        let derivative = (Interval.point(-1) * smooth3Derivative(z)) / width
        let transition = radius.clamped(c.innerRadius, 1)
        let ratioX: Interval, ratioY: Interval
        if transition.lower > 0 {
            ratioX = (nx / transition).clamped(-1, 1)
            ratioY = (ny / transition).clamped(-1, 1)
        } else { ratioX = Interval(-1, 1); ratioY = Interval(-1, 1) }
        var gx = (derivative * ratioX) / c.radiusX, gy = (derivative * ratioY) / ry
        if radius.lower <= c.innerRadius || radius.upper >= 1 {
            gx = gx.hull(.point(0)); gy = gy.hull(.point(0))
        }
        return EnvelopeRange(value: value.clamped(0, 1), x: gx, y: gy)
    }

    /// The boxes are split at every branch boundary. Cubic values are
    /// monotone on each transition; derivative extrema are at endpoints or 1/2.
    private static func axis(_ p: Interval, outerLow: Double, innerLow: Double,
                             innerHigh: Double, outerHigh: Double) -> (Interval, Interval) {
        if p.upper <= outerLow || p.lower >= outerHigh { return (.point(0), .point(0)) }
        if p.upper <= innerLow {
            let width = innerLow - outerLow
            let z = ((p - .point(outerLow)) / width).clamped(0, 1)
            return (smooth3(z), smooth3Derivative(z) / width)
        }
        if p.lower >= innerHigh {
            let width = outerHigh - innerHigh
            let z = ((p - .point(innerHigh)) / width).clamped(0, 1)
            return (.point(1) - smooth3(z), (Interval.point(-1) * smooth3Derivative(z)) / width)
        }
        return (.point(1), .point(0))
    }

    private static func smooth3(_ z: Interval) -> Interval {
        func at(_ t: Double) -> Interval {
            let p = Interval.point(t)
            return p * p * (.point(3) - .point(2) * p)
        }
        return Interval(at(z.lower).lower, at(z.upper).upper).clamped(0, 1)
    }

    private static func smooth3Derivative(_ z: Interval) -> Interval {
        func at(_ t: Double) -> Interval {
            let p = Interval.point(t)
            return .point(6) * p * (.point(1) - p)
        }
        let a = at(z.lower), b = at(z.upper)
        var upper = max(a.upper, b.upper)
        if z.lower <= 0.5 && z.upper >= 0.5 { upper = max(upper, 1.5) }
        return Interval(max(0, min(a.lower, b.lower)), upper)
    }

    private static func affine(_ c: Model.Affine, u: Double, x: Interval, y: Interval,
                               w: EnvelopeRange) -> Enclosure {
        let vx = Interval.point(c.rates.x) * (x - .point(c.center.x))
        let vy = Interval.point(c.rates.y) * (y - .point(c.center.y))
        let u = Interval.point(u)
        return Enclosure(dx: u * w.value * vx, dy: u * w.value * vy,
            xx: u * (.point(c.rates.x) * w.value + vx * w.x),
            yx: u * vy * w.x, xy: u * vx * w.y,
            yy: u * (.point(c.rates.y) * w.value + vy * w.y))
    }

    private static func translation(_ c: Model.Translation, u: Double, w: EnvelopeRange) -> Enclosure {
        let x = Interval.point(u) * .point(c.vector.x), y = Interval.point(u) * .point(c.vector.y)
        return Enclosure(dx: x * w.value, dy: y * w.value,
                         xx: x * w.x, yx: y * w.x, xy: x * w.y, yy: y * w.y)
    }

    private static func tilt(_ c: Model.Tilt, u: Double, x: Interval, y: Interval,
                             w: EnvelopeRange) -> Enclosure {
        let theta = Interval.point(c.angle) * .point(u), phi = theta * w.value
        let co = cosine(phi), si = sine(phi), com1 = co - .point(1)
        let rx = x - .point(c.center.x), ry = y - .point(c.center.y)
        let ax = theta * (.point(-1) * si * rx - co * ry)
        let ay = theta * (co * rx - si * ry)
        return Enclosure(dx: com1 * rx - si * ry, dy: si * rx + com1 * ry,
                         xx: com1 + ax * w.x, yx: si + ay * w.x,
                         xy: .point(-1) * si + ax * w.y, yy: com1 + ay * w.y)
    }

    private static func smile(_ c: Model.Smile, u: Double, x: Interval, y: Interval,
                              w: EnvelopeRange) -> Enclosure {
        var vx = Interval.point(0), vy = Interval.point(0)
        var vxx = Interval.point(0), vyx = Interval.point(0)
        var vxy = Interval.point(0), vyy = Interval.point(0)
        for (index, lobe) in c.lobes.enumerated() where c.centralEnvelope == nil || index != 1 {
            let a = bell(x, center: lobe.center.x, radius: lobe.radius.x)
            let b = bell(y, center: lobe.center.y, radius: lobe.radius.y)
            let value = a.0 * b.0, dx = a.1 * b.0, dy = a.0 * b.1
            vx = vx + .point(lobe.vector.x) * value; vy = vy + .point(lobe.vector.y) * value
            vxx = vxx + .point(lobe.vector.x) * dx; vyx = vyx + .point(lobe.vector.y) * dx
            vxy = vxy + .point(lobe.vector.x) * dy; vyy = vyy + .point(lobe.vector.y) * dy
        }
        if let central = c.centralEnvelope {
            let b = envelopeInterval(central, x: x, y: y)
            let differenceX = Interval.point(c.lobes[1].vector.x) - vx
            let differenceY = Interval.point(c.lobes[1].vector.y) - vy
            let corner = Interval.point(1) - b.value
            vxx = corner * vxx + differenceX * b.x
            vyx = corner * vyx + differenceY * b.x
            vxy = corner * vxy + differenceX * b.y
            vyy = corner * vyy + differenceY * b.y
            vx = corner * vx + b.value * .point(c.lobes[1].vector.x)
            vy = corner * vy + b.value * .point(c.lobes[1].vector.y)
        }
        let u = Interval.point(u)
        return Enclosure(dx: u * w.value * vx, dy: u * w.value * vy,
                         xx: u * (w.value * vxx + w.x * vx), yx: u * (w.value * vyx + w.x * vy),
                         xy: u * (w.value * vxy + w.y * vx), yy: u * (w.value * vyy + w.y * vy))
    }

    /// Compact b(r)=(1-r²)². Value extrema are endpoints or zero;
    /// derivative extrema are endpoints or +/-1/sqrt(3), all included.
    private static func bell(_ p: Interval, center: Double, radius: Double) -> (Interval, Interval) {
        let raw = (p - .point(center)) / radius
        if raw.upper <= -1 || raw.lower >= 1 { return (.point(0), .point(0)) }
        let r = raw.clamped(-1, 1)
        func value(_ x: Double) -> Interval {
            let z = Interval.point(x)
            return (.point(1) - z.squared).squared
        }
        func derivative(_ x: Double) -> Interval {
            let z = Interval.point(x)
            return (.point(-4) * z * (.point(1) - z.squared)) / radius
        }
        let a = value(r.lower), b = value(r.upper)
        var val = Interval(min(a.lower, b.lower), r.lower <= 0 && r.upper >= 0 ? 1 : max(a.upper, b.upper)).clamped(0, 1)
        let da = derivative(r.lower), db = derivative(r.upper)
        var d = Interval(min(da.lower, db.lower), max(da.upper, db.upper))
        let critical = Interval.point(1) / Interval.point(3).squareRoot
        let maximum = (Interval.point(8) / (.point(3) * Interval.point(3).squareRoot)) / radius
        if r.lower <= critical.upper && r.upper >= critical.lower { d.lower = min(d.lower, -maximum.upper) }
        if r.lower <= -critical.lower && r.upper >= -critical.upper { d.upper = max(d.upper, maximum.upper) }
        // In the unusual case that a roundoff-expanded box intersects both a
        // zero exterior and a support interior, include the exterior exactly.
        if raw.lower < -1 || raw.upper > 1 { val = val.hull(.point(0)); d = d.hull(.point(0)) }
        return (val, d)
    }

    private static func sine(_ p: Interval) -> Interval {
        let a = sineEndpoint(p.lower), b = sineEndpoint(p.upper)
        var result = Interval(min(a.lower, b.lower), max(a.upper, b.upper))
        let halfPi = Double.pi * 0.5
        if p.lower <= halfPi.nextUp && p.upper >= halfPi.nextDown { result.upper = 1 }
        if p.lower <= (-halfPi).nextUp && p.upper >= (-halfPi).nextDown { result.lower = -1 }
        return result.clamped(-1, 1)
    }

    private static func cosine(_ p: Interval) -> Interval {
        let a = cosineEndpoint(p.lower), b = cosineEndpoint(p.upper)
        var result = Interval(min(a.lower, b.lower), max(a.upper, b.upper))
        if p.lower <= 0 && p.upper >= 0 { result.upper = 1 }
        if p.lower <= Double.pi.nextUp && p.upper >= Double.pi.nextDown { result.lower = -1 }
        if p.lower <= (-Double.pi).nextUp && p.upper >= (-Double.pi).nextDown { result.lower = -1 }
        return result.clamped(-1, 1)
    }

    /// Taylor endpoints use explicit analytic remainders and outward interval
    /// arithmetic. They do not assume a platform libm rounding guarantee.
    /// Outside [-pi,pi] a full [-1,1] enclosure remains valid; the independent
    /// simple model certificate is then usually tighter and wins the minimum.
    private static func sineEndpoint(_ value: Double) -> Interval {
        guard abs(value) <= Double.pi else { return Interval(-1, 1) }
        let x = Interval.point(value), x2 = x.squared
        var term = x, result = x
        for k in 1...14 {
            term = (term * .point(-1) * x2) / Double((2 * k) * (2 * k + 1))
            result = result + term
        }
        let remainder = ((Interval.point(term.maximumAbsolute) * x2) / Double(30 * 31)).upper
        return (result + Interval(-remainder, remainder)).clamped(-1, 1)
    }

    private static func cosineEndpoint(_ value: Double) -> Interval {
        guard abs(value) <= Double.pi else { return Interval(-1, 1) }
        let x2 = Interval.point(value).squared
        var term = Interval.point(1), result = Interval.point(1)
        for k in 1...15 {
            term = (term * .point(-1) * x2) / Double((2 * k - 1) * (2 * k))
            result = result + term
        }
        let remainder = ((Interval.point(term.maximumAbsolute) * x2) / Double(31 * 32)).upper
        return (result + Interval(-remainder, remainder)).clamped(-1, 1)
    }

    private static func normUpper(_ x: Double, _ y: Double) -> Double {
        (Interval.point(x).squared + Interval.point(y).squared).squareRoot.upper
    }

    /// For an interval matrix A, choose an exact floating point center C and
    /// entrywise radius R containing A-C. ||A||2 <= ||C||2 + ||R||F. This keeps
    /// the skew signs of rotation instead of replacing every entry by abs(A).
    private static func matrixNormUpper(_ e: Enclosure) -> Double {
        let entries = [e.xx, e.xy, e.yx, e.yy]
        let centers = entries.map { $0.lower + ($0.upper - $0.lower) * 0.5 }
        let radii = zip(entries, centers).map { pair -> Double in
            max((Interval.point(pair.0.lower) - .point(pair.1)).maximumAbsolute,
                (Interval.point(pair.0.upper) - .point(pair.1)).maximumAbsolute)
        }
        let a = Interval.point(centers[0]), b = Interval.point(centers[1])
        let c = Interval.point(centers[2]), d = Interval.point(centers[3])
        let aa = a.squared + c.squared, dd = b.squared + d.squared, ad = a * b + c * d
        let eigenvalue = (aa + dd + ((aa - dd).squared + .point(4) * ad.squared).squareRoot) / 2
        let centerNorm = eigenvalue.squareRoot
        var radiusSquared = Interval.point(0)
        for radius in radii { radiusSquared = radiusSquared + Interval.point(radius).squared }
        return (centerNorm + radiusSquared.squareRoot).upper
    }

    /// All arithmetic operations include a one-ULP outward rounding step.
    /// Inputs are exact source/configuration floating point constants.
    private struct Interval {
        var lower: Double, upper: Double
        init(_ lower: Double, _ upper: Double) { self.lower = lower; self.upper = upper }
        static func point(_ value: Double) -> Self { Self(value, value) }
        var maximumAbsolute: Double { max(abs(lower), abs(upper)) }
        var squared: Self {
            let a = lower * lower, b = upper * upper
            return Self(lower <= 0 && upper >= 0 ? 0 : min(a, b).nextDown, max(a, b).nextUp)
        }
        var squareRoot: Self { Self(sqrt(max(0, lower)).nextDown, sqrt(max(0, upper)).nextUp) }
        func clamped(_ low: Double, _ high: Double) -> Self { Self(max(low, lower), min(high, upper)) }
        func hull(_ other: Self) -> Self { Self(min(lower, other.lower), max(upper, other.upper)) }
        static func + (a: Self, b: Self) -> Self {
            Self((a.lower + b.lower).nextDown, (a.upper + b.upper).nextUp)
        }
        static func - (a: Self, b: Self) -> Self {
            Self((a.lower - b.upper).nextDown, (a.upper - b.lower).nextUp)
        }
        static func * (a: Self, b: Self) -> Self {
            let p = [a.lower * b.lower, a.lower * b.upper, a.upper * b.lower, a.upper * b.upper]
            return Self(p.min()!.nextDown, p.max()!.nextUp)
        }
        static func / (a: Self, b: Double) -> Self {
            Self((a.lower / b).nextDown, (a.upper / b).nextUp)
        }
        static func / (a: Self, b: Self) -> Self {
            guard b.lower > 0 else { return Self(-.infinity, .infinity) }
            return a * Self((1 / b.upper).nextDown, (1 / b.lower).nextUp)
        }
    }
}
