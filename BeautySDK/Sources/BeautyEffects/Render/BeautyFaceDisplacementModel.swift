import Foundation

/// Low-dimensional, source-fixed face fields in eye-distance units, x right/y
/// down. Coefficients are design inputs; this model does not fit reference data.
/// Every admitted field has a conservative analytic global derivative bound
/// below one, including all window and overlapping protection derivatives.
struct BeautyFaceDisplacementModel: Sendable {
    struct Bounds: Sendable {
        let minimum: SIMD2<Double>
        let maximum: SIMD2<Double>

        func contains(_ point: SIMD2<Double>) -> Bool {
            point.x >= minimum.x && point.x <= maximum.x &&
                point.y >= minimum.y && point.y <= maximum.y
        }

        fileprivate func union(_ other: Bounds) -> Bounds {
            Bounds(minimum: SIMD2(min(minimum.x, other.minimum.x), min(minimum.y, other.minimum.y)),
                   maximum: SIMD2(max(maximum.x, other.maximum.x), max(maximum.y, other.maximum.y)))
        }

        fileprivate func intersection(_ other: Bounds) -> Bounds? {
            let low = SIMD2(max(minimum.x, other.minimum.x), max(minimum.y, other.minimum.y))
            let high = SIMD2(min(maximum.x, other.maximum.x), min(maximum.y, other.maximum.y))
            guard low.x <= high.x, low.y <= high.y else { return nil }
            return Bounds(minimum: low, maximum: high)
        }

        fileprivate var isFinite: Bool {
            BeautyFaceDisplacementModel.finite(minimum) && BeautyFaceDisplacementModel.finite(maximum)
        }

        fileprivate var maximumAbsoluteX: Double { max(abs(minimum.x), abs(maximum.x)) }
        fileprivate func maximumAbsoluteY(from anchor: Double) -> Double {
            max(abs(minimum.y - anchor), abs(maximum.y - anchor))
        }
    }

    /// Scalar profile extrema used by interval certification. A plateau may
    /// be asymmetric and need not contain zero; its two derivative maxima
    /// occur halfway along the separate quintic transitions.
    fileprivate enum AxisProfile {
        case bump
        case plateau(lower: Double, upper: Double)

        func evaluate(_ value: Double) -> (value: Double, derivative: Double) {
            switch self {
            case .bump:
                return BeautyFaceDisplacementModel.bump(value)
            case let .plateau(lower, upper):
                if value <= -1 || value >= 1 { return (0, 0) }
                if value < lower {
                    let width = lower + 1, t = (value + 1) / width
                    return (t * t * t * (10 + t * (-15 + 6 * t)),
                            30 * t * t * (1 - t) * (1 - t) / width)
                }
                if value <= upper { return (1, 0) }
                let width = 1 - upper, t = (value - upper) / width, r = 1 - t
                return (r * r * r * (1 + 3 * t + 6 * t * t), -30 * t * t * r * r / width)
            }
        }

        func enclosure(in interval: SIMD2<Double>) -> (weight: Double, derivative: Double) {
            // Nonfinite projected ranges can arise from overflow even when
            // the input box is finite. Enclose the whole scalar support then;
            // never interpret an unavailable projection as zero motion.
            let low = interval.x.isNaN ? -1 : max(-1, interval.x)
            let high = interval.y.isNaN ? 1 : min(1, interval.y)
            guard low <= high else { return (0, 0) }
            let weight: Double
            var derivative = max(abs(evaluate(low).derivative), abs(evaluate(high).derivative))
            switch self {
            case .bump:
                let nearest = low > 0 ? low : (high < 0 ? high : 0)
                weight = evaluate(nearest).value
                let peak = 1 / sqrt(5.0)
                if (low <= -peak && high >= -peak) || (low <= peak && high >= peak) {
                    derivative = max(derivative, 96 / (25 * sqrt(5.0)))
                }
            case let .plateau(lower, upper):
                if high >= lower && low <= upper {
                    weight = 1
                } else {
                    weight = evaluate(high < lower ? high : low).value
                }
                let leftPeak = (lower - 1) * 0.5, rightPeak = (upper + 1) * 0.5
                if low <= leftPeak && high >= leftPeak {
                    derivative = max(derivative, (15.0 / 8) / (lower + 1))
                }
                if low <= rightPeak && high >= rightPeak {
                    derivative = max(derivative, (15.0 / 8) / (1 - upper))
                }
            }
            // Keep exact zero for disjoint supports, while rounding nonzero
            // scalar enclosures outward before their product is assembled.
            return (weight > 0 ? weight.nextUp : 0, derivative > 0 ? derivative.nextUp : 0)
        }
    }

    /// Product of two C² compact weights. The default uses b(s)=(1-s²)³;
    /// a positive innerFraction selects quintic transitions around a plateau.
    /// Axes must be orthogonal unit vectors; radius contains positive half widths.
    struct Window: Sendable {
        let center: SIMD2<Double>
        let axisX: SIMD2<Double>
        let axisY: SIMD2<Double>
        let radius: SIMD2<Double>
        let innerFraction: Double

        /// Optional asymmetric vertical plateau, between compact endpoints
        /// -1 and 1. The horizontal axis retains its existing profile.
        let verticalPlateau: SIMD2<Double>?

        init(center: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>,
             radius: SIMD2<Double>, innerFraction: Double = 0,
             verticalPlateau: SIMD2<Double>? = nil) {
            self.center = center
            self.axisX = axisX
            self.axisY = axisY
            self.radius = radius
            self.innerFraction = innerFraction
            self.verticalPlateau = verticalPlateau
        }

        var bounds: Bounds {
            let extent = SIMD2(abs(axisX.x) * radius.x + abs(axisY.x) * radius.y,
                               abs(axisX.y) * radius.x + abs(axisY.y) * radius.y)
            return Bounds(minimum: center - extent, maximum: center + extent)
        }

        fileprivate var isValid: Bool {
            guard BeautyFaceDisplacementModel.finite(center),
                  BeautyFaceDisplacementModel.finite(axisX),
                  BeautyFaceDisplacementModel.finite(axisY),
                  BeautyFaceDisplacementModel.finite(radius), radius.x > 0, radius.y > 0,
                  innerFraction.isFinite, innerFraction >= 0, innerFraction < 1,
                  abs(BeautyFaceDisplacementModel.dot(axisX, axisX) - 1) <= 1e-10,
                  abs(BeautyFaceDisplacementModel.dot(axisY, axisY) - 1) <= 1e-10,
                  abs(BeautyFaceDisplacementModel.dot(axisX, axisY)) <= 1e-10,
                  bounds.isFinite else { return false }
            if let verticalPlateau {
                guard BeautyFaceDisplacementModel.finite(verticalPlateau),
                      verticalPlateau.x > -1, verticalPlateau.x <= verticalPlateau.y,
                      verticalPlateau.y < 1 else { return false }
            }
            return gradientBound.isFinite
        }

        /// max |b'| = 96/(25√5), attained at |s|=1/√5; a plateau
        /// instead uses max S'(t)/(1-f)=(15/8)/(1-f).
        /// Triangle inequality also covers admitted floating-point unit axes.
        fileprivate var gradientBound: Double {
            let c = innerFraction == 0 ? 96 / (25 * sqrt(5.0)) : (15.0 / 8) / (1 - innerFraction)
            guard let verticalPlateau else {
                // Preserve the arithmetic order of the established controls,
                // including their safety scale, when no new profile is used.
                return c * (hypot(axisX.x, axisX.y) / radius.x + hypot(axisY.x, axisY.y) / radius.y)
            }
            let cy = (15.0 / 8) / min(verticalPlateau.x + 1, 1 - verticalPlateau.y)
            return c * hypot(axisX.x, axisX.y) / radius.x + cy * hypot(axisY.x, axisY.y) / radius.y
        }

        private var horizontalProfile: AxisProfile {
            innerFraction == 0 ? .bump : .plateau(lower: -innerFraction, upper: innerFraction)
        }

        private var verticalProfile: AxisProfile {
            verticalPlateau.map { .plateau(lower: $0.x, upper: $0.y) } ?? horizontalProfile
        }

        /// Complete product-window derivative bound on every point of a box.
        /// The extrema are analytic extrema over projected intervals, not
        /// evaluations of the field at a finite set of spatial sample points.
        fileprivate func gradientBound(in box: Bounds) -> Double {
            gradientBound(in: box, horizontal: horizontalProfile, vertical: verticalProfile)
        }

        fileprivate func gradientBound(in box: Bounds, horizontal: AxisProfile, vertical: AxisProfile) -> Double {
            guard let overlap = bounds.intersection(box) else { return 0 }
            let x = horizontal.enclosure(in: projectedInterval(overlap, axis: axisX, radius: radius.x))
            let y = vertical.enclosure(in: projectedInterval(overlap, axis: axisY, radius: radius.y))
            let gx = x.derivative * y.weight / radius.x
            let gy = x.weight * y.derivative / radius.y
            let nx = hypot(axisX.x, axisX.y), ny = hypot(axisY.x, axisY.y)
            // Admitted axes are orthogonal only to floating-point tolerance.
            // |aX+bY|² ≤ (1+|cos θ|)(|aX|²+|bY|²), so the small actual
            // correlation is included rather than assuming exact orthogonality.
            let correlation = abs(BeautyFaceDisplacementModel.dot(axisX, axisY)) / nx / ny
            return hypot(gx * nx, gy * ny) * sqrt(1 + correlation)
        }

        private func projectedInterval(_ box: Bounds, axis: SIMD2<Double>, radius: Double) -> SIMD2<Double> {
            let dx0 = (box.minimum.x - center.x).nextDown, dx1 = (box.maximum.x - center.x).nextUp
            let dy0 = (box.minimum.y - center.y).nextDown, dy1 = (box.maximum.y - center.y).nextUp
            let x0 = min(dx0 * axis.x, dx1 * axis.x).nextDown
            let x1 = max(dx0 * axis.x, dx1 * axis.x).nextUp
            let y0 = min(dy0 * axis.y, dy1 * axis.y).nextDown
            let y1 = max(dy0 * axis.y, dy1 * axis.y).nextUp
            return SIMD2(((x0 + y0).nextDown / radius).nextDown,
                         ((x1 + y1).nextUp / radius).nextUp)
        }

        fileprivate func evaluate(at point: SIMD2<Double>) -> Weight {
            guard bounds.contains(point) else { return .zero }
            let delta = point - center
            let u = BeautyFaceDisplacementModel.dot(delta, axisX) / radius.x
            let v = BeautyFaceDisplacementModel.dot(delta, axisY) / radius.y
            let x = axisWeight(u)
            let y = verticalWeight(v)
            return Weight(value: x.value * y.value,
                gradient: axisX * (x.derivative * y.value / radius.x) +
                    axisY * (x.value * y.derivative / radius.y))
        }

        /// Interval enclosure on a world-aligned box, not a sampled maximum.
        /// The maxima of the two one-dimensional weights may occur at different
        /// points; their product is consequently a conservative upper bound.
        fileprivate func maximumWeight(in box: Bounds) -> Double {
            guard let overlap = bounds.intersection(box) else { return 0 }
            func maximumBump(axis: SIMD2<Double>, radius: Double, vertical: Bool) -> Double {
                let dx0 = overlap.minimum.x - center.x, dx1 = overlap.maximum.x - center.x
                let dy0 = overlap.minimum.y - center.y, dy1 = overlap.maximum.y - center.y
                let low = (min(dx0 * axis.x, dx1 * axis.x) + min(dy0 * axis.y, dy1 * axis.y)) / radius
                let high = (max(dx0 * axis.x, dx1 * axis.x) + max(dy0 * axis.y, dy1 * axis.y)) / radius
                if vertical, let plateau = verticalPlateau {
                    if high >= plateau.x && low <= plateau.y { return 1 }
                    return verticalWeight(high < plateau.x ? high : low).value
                }
                let nearest = low > 0 ? low : (high < 0 ? high : 0)
                return axisWeight(nearest).value
            }
            return maximumBump(axis: axisX, radius: radius.x, vertical: false) *
                maximumBump(axis: axisY, radius: radius.y, vertical: true)
        }

        /// Refinement uses outward-rounded projected intervals. Keeping this
        /// separate preserves the established coarse certificate bit-for-bit
        /// for controls that have not opted into interval refinement.
        fileprivate func enclosedMaximumWeight(in box: Bounds) -> Double {
            guard let overlap = bounds.intersection(box) else { return 0 }
            let x = horizontalProfile.enclosure(in: projectedInterval(overlap, axis: axisX, radius: radius.x))
            let y = verticalProfile.enclosure(in: projectedInterval(overlap, axis: axisY, radius: radius.y))
            return x.weight * y.weight
        }

        private func verticalWeight(_ value: Double) -> (value: Double, derivative: Double) {
            guard let plateau = verticalPlateau else { return axisWeight(value) }
            if value <= -1 || value >= 1 { return (0, 0) }
            if value < plateau.x {
                let width = plateau.x + 1
                let t = (value + 1) / width
                return (t * t * t * (10 + t * (-15 + 6 * t)),
                        30 * t * t * (1 - t) * (1 - t) / width)
            }
            if value <= plateau.y { return (1, 0) }
            let width = 1 - plateau.y, t = (value - plateau.y) / width, r = 1 - t
            return (r * r * r * (1 + 3 * t + 6 * t * t), -30 * t * t * r * r / width)
        }

        private func axisWeight(_ value: Double) -> (value: Double, derivative: Double) {
            innerFraction == 0 ? BeautyFaceDisplacementModel.bump(value) :
                BeautyFaceDisplacementModel.plateau(value, innerFraction: innerFraction)
        }
    }

    /// A product window with a rectangular C² plateau core. Within each axis's
    /// innerFraction the one-dimensional protection is exactly one.
    struct Protection: Sendable {
        let window: Window
        let innerFraction: Double

        init(window: Window, innerFraction: Double = 0.6) {
            self.window = window
            self.innerFraction = innerFraction
        }

        fileprivate var isValid: Bool {
            window.isValid && innerFraction.isFinite && innerFraction >= 0 && innerFraction < 1 &&
                gradientBound.isFinite
        }

        /// max S'(t)=15/8 for quintic smoothstep S; include both axes.
        fileprivate var gradientBound: Double {
            let c = (15.0 / 8) / (1 - innerFraction)
            return c * (hypot(window.axisX.x, window.axisX.y) / window.radius.x +
                        hypot(window.axisY.x, window.axisY.y) / window.radius.y)
        }

        fileprivate func gradientBound(in box: Bounds) -> Double {
            // A protection always uses its own symmetric quintic plateau,
            // including innerFraction=0. The window's bump/asymmetric profile
            // is not the function evaluated by Protection.evaluate.
            let profile = AxisProfile.plateau(lower: -innerFraction, upper: innerFraction)
            return window.gradientBound(in: box, horizontal: profile, vertical: profile)
        }

        fileprivate func evaluate(at point: SIMD2<Double>) -> Weight {
            guard window.bounds.contains(point) else { return .zero }
            let delta = point - window.center
            let u = BeautyFaceDisplacementModel.dot(delta, window.axisX) / window.radius.x
            let v = BeautyFaceDisplacementModel.dot(delta, window.axisY) / window.radius.y
            let x = axisWeight(u), y = axisWeight(v)
            return Weight(value: x.value * y.value,
                gradient: window.axisX * (x.derivative * y.value / window.radius.x) +
                    window.axisY * (x.value * y.derivative / window.radius.y))
        }

        private func axisWeight(_ value: Double) -> (value: Double, derivative: Double) {
            BeautyFaceDisplacementModel.plateau(value, innerFraction: innerFraction)
        }
    }

    enum Mode: Sendable {
        case vector(weight: Window, displacement: SIMD2<Double>)
        /// W(z) [diag(scale) (z-anchor) + translation]. Equal diagonal
        /// entries yield radial motion; a constant vertical term yields
        /// a chin platform, with optional weak horizontal convergence.
        case affine(weight: Window, anchor: SIMD2<Double>, scale: SIMD2<Double>, translation: SIMD2<Double>)
        case smallFace(horizontal: Window, vertical: Window,
                       horizontalAmount: Double, verticalAmount: Double, anchorY: Double)

        fileprivate var isValid: Bool {
            switch self {
            case let .vector(weight, displacement):
                return weight.isValid && BeautyFaceDisplacementModel.finite(displacement)
            case let .affine(weight, anchor, scale, translation):
                return weight.isValid && BeautyFaceDisplacementModel.finite(anchor) &&
                    BeautyFaceDisplacementModel.finite(scale) && BeautyFaceDisplacementModel.finite(translation)
            case let .smallFace(horizontal, vertical, a, b, anchor):
                // The vertical support begins at/below the stable anchor. This
                // avoids an unrequested opposite vertical lobe above it.
                return horizontal.isValid && vertical.isValid && a.isFinite && b.isFinite &&
                    anchor.isFinite && vertical.bounds.minimum.y >= anchor - 1e-12
            }
        }

        fileprivate var isZero: Bool {
            switch self {
            case let .vector(_, displacement): return displacement == .zero
            case let .affine(_, _, scale, translation): return scale == .zero && translation == .zero
            case let .smallFace(_, _, a, b, _): return a == 0 && b == 0
            }
        }

        fileprivate var bounds: Bounds {
            switch self {
            case let .vector(weight, _): return weight.bounds
            case let .affine(weight, _, _, _): return weight.bounds
            case let .smallFace(horizontal, vertical, a, b, _):
                if a == 0 { return vertical.bounds }
                if b == 0 { return horizontal.bounds }
                return horizontal.bounds.union(vertical.bounds)
            }
        }

        fileprivate var gradientBound: Double {
            switch self {
            case let .vector(weight, displacement):
                return hypot(displacement.x, displacement.y) * weight.gradientBound
            case let .affine(weight, anchor, scale, translation):
                let magnitude = Self.affineMagnitude(in: weight.bounds, anchor: anchor,
                                                     scale: scale, translation: translation)
                return magnitude * weight.gradientBound + max(abs(scale.x), abs(scale.y))
            case let .smallFace(horizontal, vertical, a, b, anchor):
                // Complete rows of ∇d: -a[h ∇Wh + Wh e₁] and
                // -b[(v-anchor) ∇Wv + Wv e₂]. Frobenius bounds operator norm.
                let rowX = abs(a) * (horizontal.bounds.maximumAbsoluteX * horizontal.gradientBound + 1)
                let rowY = abs(b) * (vertical.bounds.maximumAbsoluteY(from: anchor) * vertical.gradientBound + 1)
                return hypot(rowX, rowY)
            }
        }

        fileprivate func gradientBound(in box: Bounds) -> Double {
            switch self {
            case let .vector(weight, displacement):
                return hypot(displacement.x, displacement.y) * weight.gradientBound(in: box)
            case let .affine(weight, anchor, scale, translation):
                guard let overlap = weight.bounds.intersection(box) else { return 0 }
                let magnitude = Self.affineMagnitude(in: overlap, anchor: anchor, scale: scale, translation: translation)
                return magnitude * weight.gradientBound(in: overlap) +
                    max(abs(scale.x), abs(scale.y)) * weight.enclosedMaximumWeight(in: overlap)
            case let .smallFace(horizontal, vertical, a, b, anchor):
                let rowX = horizontal.bounds.intersection(box).map {
                    abs(a) * ($0.maximumAbsoluteX * horizontal.gradientBound(in: $0) + horizontal.enclosedMaximumWeight(in: $0))
                } ?? 0
                let rowY = vertical.bounds.intersection(box).map {
                    abs(b) * ($0.maximumAbsoluteY(from: anchor) * vertical.gradientBound(in: $0) + vertical.enclosedMaximumWeight(in: $0))
                } ?? 0
                return hypot(rowX, rowY)
            }
        }

        fileprivate func maximumDisplacement(in box: Bounds, intervalEnclosure: Bool = false) -> Double {
            func weightBound(_ weight: Window, in bounds: Bounds) -> Double {
                intervalEnclosure ? weight.enclosedMaximumWeight(in: bounds) : weight.maximumWeight(in: bounds)
            }
            switch self {
            case let .vector(weight, displacement):
                return hypot(displacement.x, displacement.y) * weightBound(weight, in: box)
            case let .affine(weight, anchor, scale, translation):
                guard let overlap = weight.bounds.intersection(box) else { return 0 }
                return Self.affineMagnitude(in: overlap, anchor: anchor, scale: scale,
                                            translation: translation) * weightBound(weight, in: overlap)
            case let .smallFace(horizontal, vertical, a, b, anchor):
                let horizontalOverlap = horizontal.bounds.intersection(box)
                let verticalOverlap = vertical.bounds.intersection(box)
                let x = horizontalOverlap.map {
                    abs(a) * $0.maximumAbsoluteX * weightBound(horizontal, in: $0)
                } ?? 0
                let y = verticalOverlap.map {
                    abs(b) * $0.maximumAbsoluteY(from: anchor) * weightBound(vertical, in: $0)
                } ?? 0
                return hypot(x, y)
            }
        }

        fileprivate func evaluate(at point: SIMD2<Double>) -> Sample {
            guard bounds.contains(point) else { return .zero }
            switch self {
            case let .vector(weight, displacement):
                let w = weight.evaluate(at: point)
                return Sample(displacement: displacement * w.value,
                              derivativeX: displacement * w.gradient.x,
                              derivativeY: displacement * w.gradient.y)
            case let .affine(weight, anchor, scale, translation):
                let w = weight.evaluate(at: point)
                let m = scale * (point - anchor) + translation
                return Sample(displacement: m * w.value,
                    derivativeX: m * w.gradient.x + SIMD2(scale.x * w.value, 0),
                    derivativeY: m * w.gradient.y + SIMD2(0, scale.y * w.value))
            case let .smallFace(horizontal, vertical, a, b, anchor):
                let h = horizontal.evaluate(at: point), v = vertical.evaluate(at: point)
                let dy = point.y - anchor
                return Sample(displacement: SIMD2(-a * h.value * point.x, -b * v.value * dy),
                    derivativeX: SIMD2(-a * (point.x * h.gradient.x + h.value), -b * dy * v.gradient.x),
                    derivativeY: SIMD2(-a * point.x * h.gradient.y, -b * (dy * v.gradient.y + v.value)))
            }
        }

        private static func affineMagnitude(in box: Bounds, anchor: SIMD2<Double>,
                                            scale: SIMD2<Double>, translation: SIMD2<Double>) -> Double {
            let x0 = scale.x * (box.minimum.x - anchor.x) + translation.x
            let x1 = scale.x * (box.maximum.x - anchor.x) + translation.x
            let y0 = scale.y * (box.minimum.y - anchor.y) + translation.y
            let y1 = scale.y * (box.maximum.y - anchor.y) + translation.y
            return hypot(max(abs(x0), abs(x1)), max(abs(y0), abs(y1)))
        }
    }

    struct Sample: Sendable {
        let displacement: SIMD2<Double>
        /// Columns of the complete displacement derivative ∂d/∂z.
        let derivativeX: SIMD2<Double>
        let derivativeY: SIMD2<Double>
        /// Columns of the forward Jacobian I+∂d/∂z.
        var jacobianX: SIMD2<Double> { derivativeX + SIMD2(1, 0) }
        var jacobianY: SIMD2<Double> { derivativeY + SIMD2(0, 1) }
        fileprivate static var zero: Sample { Sample(displacement: .zero, derivativeX: .zero, derivativeY: .zero) }
    }

    /// A function owns its protection independently. For example, protecting a
    /// nose core for face width must not freeze small-face vertical motion.
    struct Component: Sendable {
        let modes: [Mode]
        let protections: [Protection]
    }

    fileprivate struct Weight {
        let value: Double
        let gradient: SIMD2<Double>
        static var zero: Weight { Weight(value: 0, gradient: .zero) }
    }

    private let components: [Component]
    /// AABB of all active source supports; zero-size at the origin for identity.
    let bounds: Bounds
    let isIdentity: Bool
    let unscaledGradientBound: Double
    let gradientBound: Double
    let amplitudeScale: Double
    /// Conservative bound on |d| in normalized eye-distance units.
    let maximumDisplacement: Double

    init?(modes: [Mode], protections: [Protection], maximumGradient: Double = 0.80,
          refineGradientBound: Bool = false) {
        self.init(components: [Component(modes: modes, protections: protections)],
                  maximumGradient: maximumGradient, refineGradientBound: refineGradientBound)
    }

    init?(components: [Component], maximumGradient: Double = 0.80,
          refineGradientBound: Bool = false) {
        guard maximumGradient.isFinite, maximumGradient > 0, maximumGradient < 1,
              components.allSatisfy({ $0.modes.allSatisfy(\.isValid) && $0.protections.allSatisfy(\.isValid) })
        else { return nil }
        let active = components.compactMap { component -> Component? in
            let modes = component.modes.filter { !$0.isZero }
            return modes.isEmpty ? nil : Component(modes: modes, protections: component.protections)
        }
        let modes = active.flatMap(\.modes)
        let support = modes.dropFirst().reduce(modes.first?.bounds ?? Bounds(minimum: .zero, maximum: .zero)) {
            $0.union($1.bounds)
        }
        var derivative = 0.0
        for component in active {
            derivative += component.modes.reduce(0.0) { $0 + $1.gradientBound }
            // |∇G| ≤ Σ|∇Pj|, independently within this component.
            // Bound |d₀| only on each protection's support; disjoint distant
            // protections cost zero. Other product factors are ≤1, and no
            // division occurs at cores. Protected components are then summed.
            for protection in component.protections {
                let localAmplitude = component.modes.reduce(0.0) {
                    $0 + $1.maximumDisplacement(in: protection.window.bounds)
                }
                derivative += localAmplitude * protection.gradientBound
            }
        }
        let amplitude = modes.reduce(0.0) { $0 + $1.maximumDisplacement(in: support) }
        guard support.isFinite, derivative.isFinite, amplitude.isFinite else { return nil }
        if refineGradientBound {
            let partitioned = Self.partitionedGradientBound(components: active, support: support)
            if partitioned.isFinite { derivative = min(derivative, partitioned) }
        }
        // Analytic polynomial extrema, interval enclosures, sum/product norm
        // inequalities certify the whole plane. A small rounding margin is
        // retained; no finite set of sampled Jacobians is used as a proof.
        let certified = derivative == 0 ? 0 : derivative * (1 + 1e-12)
        guard certified.isFinite else { return nil }
        let budget = maximumGradient * (1 - 1e-12)
        let scale = certified > budget ? budget / certified : 1
        self.components = active
        bounds = support
        isIdentity = active.isEmpty
        unscaledGradientBound = certified
        gradientBound = certified * scale
        amplitudeScale = scale
        maximumDisplacement = amplitude * scale
    }

    /// A fixed tiling covers the complete compact source domain. Each cell
    /// encloses its modes and protection derivatives over the whole rectangle;
    /// taking the maximum of these enclosures is a global certificate. No
    /// sampled Jacobian, refinement heuristic or field-dependent probe is used.
    private static func partitionedGradientBound(components: [Component], support: Bounds) -> Double {
        guard !components.isEmpty else { return 0 }
        let count = 32
        func edges(_ low: Double, _ high: Double) -> [Double] {
            // Convex interpolation avoids overflow in high-low for a finite
            // box spanning large values. Shared edges leave no spatial gaps.
            [low] + (1..<count).map {
                let t = Double($0) / Double(count)
                return low * (1 - t) + high * t
            } + [high]
        }
        let xs = edges(support.minimum.x, support.maximum.x)
        let ys = edges(support.minimum.y, support.maximum.y)
        var maximum = 0.0
        for row in 0..<count { for column in 0..<count {
            let box = Bounds(minimum: SIMD2(xs[column], ys[row]),
                             maximum: SIMD2(xs[column + 1], ys[row + 1]))
            var derivative = 0.0
            for component in components {
                derivative += component.modes.reduce(0.0) { $0 + $1.gradientBound(in: box) }
                for protection in component.protections {
                    guard let overlap = box.intersection(protection.window.bounds) else { continue }
                    let protectionDerivative = protection.gradientBound(in: overlap)
                    if protectionDerivative == 0 { continue }
                    let amplitude = component.modes.reduce(0.0) {
                        $0 + $1.maximumDisplacement(in: overlap, intervalEnclosure: true)
                    }
                    derivative += amplitude * protectionDerivative
                }
            }
            // Retain the independent coarse certificate if an extreme finite
            // input overflows during interval arithmetic, rather than using a
            // partial tiling or allowing NaN to disappear inside max/min.
            guard derivative.isFinite else { return .infinity }
            maximum = max(maximum, derivative)
        } }
        return maximum
    }

    func sample(at point: SIMD2<Double>) -> Sample {
        guard !isIdentity, Self.finite(point), bounds.contains(point) else { return .zero }
        var displacement = SIMD2<Double>.zero
        var dx = SIMD2<Double>.zero, dy = SIMD2<Double>.zero
        for component in components {
            var localDisplacement = SIMD2<Double>.zero
            var localDX = SIMD2<Double>.zero, localDY = SIMD2<Double>.zero
            for mode in component.modes {
                let value = mode.evaluate(at: point)
                localDisplacement += value.displacement
                localDX += value.derivativeX
                localDY += value.derivativeY
            }
            var factor = 1.0
            var gradient = SIMD2<Double>.zero
            for protection in component.protections {
                let p = protection.evaluate(at: point)
                // Iterative product rule works at overlapping exact cores.
                gradient = gradient * (1 - p.value) - p.gradient * factor
                factor *= 1 - p.value
            }
            displacement += localDisplacement * factor
            dx += localDX * factor + localDisplacement * gradient.x
            dy += localDY * factor + localDisplacement * gradient.y
        }
        return Sample(displacement: displacement * amplitudeScale,
                      derivativeX: dx * amplitudeScale, derivativeY: dy * amplitudeScale)
    }

    /// Solves p=q-d(p). The certified gradient bound makes this a contraction.
    /// Accept only a finite solution with measured forward residual ≤ tolerance.
    func inverse(of target: SIMD2<Double>, tolerance: Double = 1e-7,
                 maxIterations: Int = 96) -> SIMD2<Double>? {
        guard Self.finite(target), tolerance.isFinite, tolerance > 0, maxIterations > 0 else { return nil }
        if isIdentity || !bounds.contains(target) { return target }
        var source = target
        for _ in 0..<maxIterations {
            let displacement = sample(at: source).displacement
            let next = target - displacement
            guard Self.finite(next) else { return nil }
            let residual = next + sample(at: next).displacement - target
            if hypot(residual.x, residual.y) <= tolerance { return next }
            source = next
        }
        return nil
    }

    private static func finite(_ vector: SIMD2<Double>) -> Bool { vector.x.isFinite && vector.y.isFinite }
    private static func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x * b.x + a.y * b.y }
    private static func bump(_ value: Double) -> (value: Double, derivative: Double) {
        guard abs(value) < 1 else { return (0, 0) }
        let remaining = 1 - value * value
        return (remaining * remaining * remaining, -6 * value * remaining * remaining)
    }

    private static func plateau(_ value: Double, innerFraction: Double) -> (value: Double, derivative: Double) {
        let distance = abs(value)
        if distance <= innerFraction { return (1, 0) }
        if distance >= 1 { return (0, 0) }
        let t = (distance - innerFraction) / (1 - innerFraction)
        // Factored 1-S(t) is stable near the compact support boundary.
        let remaining = 1 - t
        let weight = remaining * remaining * remaining * (1 + 3 * t + 6 * t * t)
        let derivative = -30 * t * t * remaining * remaining / (1 - innerFraction)
        return (weight, value < 0 ? -derivative : derivative)
    }
}
