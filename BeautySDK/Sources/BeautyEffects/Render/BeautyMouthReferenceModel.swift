import Foundation

/// Candidate source-domain fields from the measured mouth reference pairs.
/// Coordinates and displacements are in source mouth-width units. Responses
/// about zero are implementation choices; the screenshots do not establish a
/// common neutral state. This type performs no image sampling or face detection.
struct BeautyMouthReferenceModel: Sendable {
    typealias Point = SIMD2<Double>

    enum Field: Int, CaseIterable, Sendable {
        // Keep the existing continuous-map field order for explicit admission.
        case size, width, smile, vertical, tilt, horizontal, mShape, fullness
    }

    struct Sample: Sendable {
        var displacement: Point
        /// Columns of the complete source-domain displacement derivative.
        var gradientX: Point
        var gradientY: Point
        static let zero = Self(displacement: .zero, gradientX: .zero, gradientY: .zero)

        func scaled(by scale: Double) -> Self {
            Self(displacement: displacement * scale,
                 gradientX: gradientX * scale, gradientY: gradientY * scale)
        }
    }

    struct Bounds: Sendable {
        /// Supremum bounds, derived analytically rather than sampled maxima.
        var maximumDisplacement: Double
        var maximumGradient: Double
        static let zero = Self(maximumDisplacement: 0, maximumGradient: 0)
    }

    /// Optional two-dimensional taper. Separate upper/lower radii preserve a
    /// longer central chin tail without moving the lateral chin equally far.
    struct Radial: Sendable {
        var center: Point
        var radiusX: Double
        var radiusUp: Double
        var radiusDown: Double
        var innerRadius: Double

        var isValid: Bool {
            center.x.isFinite && center.y.isFinite && radiusX.isFinite && radiusUp.isFinite
                && radiusDown.isFinite && innerRadius.isFinite && radiusX > 0 && radiusUp > 0
                && radiusDown > 0 && innerRadius >= 0 && innerRadius < 1
        }

        var gradientBounds: Point {
            let derivative = 1.5 / (1 - innerRadius)
            return Point(derivative / radiusX, derivative / min(radiusUp, radiusDown))
        }

        fileprivate func sample(at p: Point) -> ScalarSample {
            let d = p - center, ry = d.y < 0 ? radiusUp : radiusDown
            let x = d.x / radiusX, y = d.y / ry, r = hypot(x, y)
            if r <= innerRadius { return ScalarSample(value: 1, gradient: .zero) }
            if r >= 1 { return ScalarSample(value: 0, gradient: .zero) }
            let width = 1 - innerRadius, t = (r - innerRadius) / width
            let derivative = -6 * t * (1 - t) / width
            return ScalarSample(value: 1 - t * t * (3 - 2 * t),
                                gradient: derivative * Point(x / (radiusX * r), y / (ry * r)))
        }
    }

    /// Four independent cubic C1 transitions surrounding a rectangular plateau.
    /// For M shape and fullness, y is distance from the source seam, not image y.
    struct Envelope: Sendable {
        var innerMin: Point
        var innerMax: Point
        var outerMin: Point
        var outerMax: Point
        var radial: Radial? = nil

        var isValid: Bool {
            [innerMin, innerMax, outerMin, outerMax].allSatisfy(Self.finite)
                && outerMin.x < innerMin.x && innerMin.x <= innerMax.x && innerMax.x < outerMax.x
                && outerMin.y < innerMin.y && innerMin.y <= innerMax.y && innerMax.y < outerMax.y
                && radial?.isValid != false
        }

        var gradientBounds: Point {
            let rectangular = Point(max(1.5 / (innerMin.x - outerMin.x), 1.5 / (outerMax.x - innerMax.x)),
                                    max(1.5 / (innerMin.y - outerMin.y), 1.5 / (outerMax.y - innerMax.y)))
            return rectangular + (radial?.gradientBounds ?? .zero)
        }

        fileprivate func sample(at point: Point) -> ScalarSample {
            let x = Self.axis(point.x, outerMin.x, innerMin.x, innerMax.x, outerMax.x)
            let y = Self.axis(point.y, outerMin.y, innerMin.y, innerMax.y, outerMax.y)
            let value = x.0 * y.0, gradient = Point(x.1 * y.0, x.0 * y.1)
            guard let radial else { return ScalarSample(value: value, gradient: gradient) }
            let r = radial.sample(at: point)
            return ScalarSample(value: value * r.value, gradient: gradient * r.value + value * r.gradient)
        }

        private static func axis(_ x: Double, _ outerLow: Double, _ innerLow: Double,
                                 _ innerHigh: Double, _ outerHigh: Double) -> (Double, Double) {
            guard x > outerLow, x < outerHigh else { return (0, 0) }
            if x < innerLow {
                let width = innerLow - outerLow, t = (x - outerLow) / width
                return (t * t * (3 - 2 * t), 6 * t * (1 - t) / width)
            }
            if x > innerHigh {
                let width = outerHigh - innerHigh, t = (x - innerHigh) / width
                return (1 - t * t * (3 - 2 * t), -6 * t * (1 - t) / width)
            }
            return (1, 0)
        }

        private static func finite(_ p: Point) -> Bool { p.x.isFinite && p.y.isFinite }
    }

    /// C1 cubic Hermite seam reconstructed once from current source geometry.
    /// Endpoint tangents are zero, so constant continuation is also C1.
    struct Seam: Sendable {
        let knots: [Point]
        let maximumSlope: Double
        let minimumValue: Double
        let maximumValue: Double
        private let segments: [Segment]

        init?(knots: [Point]) {
            guard knots.count >= 2, knots.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
                  zip(knots, knots.dropFirst()).allSatisfy({ $0.0.x < $0.1.x }) else { return nil }
            var slopes = Array(repeating: 0.0, count: knots.count)
            if knots.count > 2 {
                for i in 1..<(knots.count - 1) {
                    slopes[i] = (knots[i + 1].y - knots[i - 1].y) / (knots[i + 1].x - knots[i - 1].x)
                }
            }
            var segments = [Segment]()
            var maximumSlope = 0.0
            var minimumValue = knots.map(\.y).min()!
            var maximumValue = knots.map(\.y).max()!
            for i in 0..<(knots.count - 1) {
                let p = knots[i], q = knots[i + 1], h = q.x - p.x
                let a = 2 * p.y - 2 * q.y + h * (slopes[i] + slopes[i + 1])
                let b = -3 * p.y + 3 * q.y - h * (2 * slopes[i] + slopes[i + 1])
                let c = h * slopes[i]
                let segment = Segment(x: p.x, h: h, a: a, b: b, c: c, d: p.y)
                var slopeCandidates = [0.0, 1.0]
                if a != 0 {
                    let t = -b / (3 * a)
                    if t > 0 && t < 1 { slopeCandidates.append(t) }
                }
                maximumSlope = max(maximumSlope, slopeCandidates.map { abs(segment.slope($0)) }.max()!)
                for t in Self.quadraticRoots(a: 3 * a, b: 2 * b, c: c) where t > 0 && t < 1 {
                    minimumValue = min(minimumValue, segment.value(t))
                    maximumValue = max(maximumValue, segment.value(t))
                }
                segments.append(segment)
            }
            guard maximumSlope.isFinite, minimumValue.isFinite, maximumValue.isFinite else { return nil }
            self.knots = knots; self.segments = segments
            self.maximumSlope = maximumSlope
            self.minimumValue = minimumValue; self.maximumValue = maximumValue
        }

        func sample(at x: Double) -> (value: Double, slope: Double) {
            if x <= knots[0].x { return (knots[0].y, 0) }
            if x >= knots[knots.count - 1].x { return (knots[knots.count - 1].y, 0) }
            // There are few geometric knots; avoid a per-pixel allocation.
            for segment in segments where x < segment.x + segment.h {
                let t = (x - segment.x) / segment.h
                return (segment.value(t), segment.slope(t))
            }
            return (knots[knots.count - 1].y, 0)
        }

        /// Outward interval Horner evaluation on every intersected cubic.
        /// This bounds whole source intervals, including constant exterior.
        fileprivate func valueRange(from low: Double, to high: Double) -> (Double, Double) {
            var lower = min(sample(at: low).value, sample(at: high).value).nextDown
            var upper = max(sample(at: low).value, sample(at: high).value).nextUp
            for segment in segments {
                let a = max(low, segment.x), b = min(high, segment.x + segment.h)
                guard a < b else { continue }
                let t = (Interval(a, b) - .point(segment.x)) / segment.h
                let value = ((Interval.point(segment.a) * t + .point(segment.b)) * t
                    + .point(segment.c)) * t + .point(segment.d)
                lower = min(lower, value.lower); upper = max(upper, value.upper)
            }
            return (lower, upper)
        }

        private struct Segment: Sendable {
            var x: Double, h: Double, a: Double, b: Double, c: Double, d: Double
            func value(_ t: Double) -> Double { ((a * t + b) * t + c) * t + d }
            func slope(_ t: Double) -> Double { ((3 * a * t + 2 * b) * t + c) / h }
        }

        private static func quadraticRoots(a: Double, b: Double, c: Double) -> [Double] {
            if a == 0 { return b == 0 ? [] : [-c / b] }
            let discriminant = b * b - 4 * a * c
            guard discriminant >= 0 else { return [] }
            let root = sqrt(discriminant)
            return [(-b - root) / (2 * a), (-b + root) / (2 * a)]
        }
    }

    /// Ordered source-x / vertical-amplitude nodes, joined with quintic steps.
    /// The zero-height exterior and zero endpoint derivatives give C2 support.
    struct Profile: Sendable {
        let knots: [Point]
        let maximumValue: Double
        let maximumDerivative: Double

        init?(knots: [Point]) {
            guard (5...11).contains(knots.count), knots.first?.y == 0, knots.last?.y == 0,
                  knots.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
                  zip(knots, knots.dropFirst()).allSatisfy({ $0.0.x < $0.1.x }) else { return nil }
            let derivative = zip(knots, knots.dropFirst()).map { 1.875 * abs($0.1.y - $0.0.y) / ($0.1.x - $0.0.x) }.max()!
            guard derivative.isFinite else { return nil }
            self.knots = knots
            self.maximumValue = knots.map { abs($0.y) }.max()!
            self.maximumDerivative = derivative
        }

        func sample(at x: Double) -> (value: Double, derivative: Double) {
            guard x > knots[0].x, x < knots[knots.count - 1].x else { return (0, 0) }
            for i in 0..<(knots.count - 1) where x <= knots[i + 1].x {
                let left = knots[i], right = knots[i + 1], width = right.x - left.x
                let t = (x - left.x) / width, delta = right.y - left.y
                return (left.y + delta * BeautyMouthReferenceModel.smooth5(t),
                        delta * BeautyMouthReferenceModel.smooth5Derivative(t) / width)
            }
            return (0, 0)
        }
    }

    struct Affine: Sendable {
        var rates: Point
        var envelope: Envelope
        var center: Point = .zero
    }
    struct Translation: Sendable {
        var vector: Point
        var envelope: Envelope
    }
    struct Tilt: Sendable {
        var angle: Double
        var envelope: Envelope
        var center: Point = .zero
    }
    struct Lobe: Sendable {
        var center: Point
        var radius: Point
        var vector: Point

        fileprivate var isValid: Bool {
            [center, radius, vector].allSatisfy(BeautyMouthReferenceModel.finite)
                && radius.x > 0 && radius.y > 0
        }

        fileprivate var gradientBound: Double {
            // max |d(1-r²)²/dr| = 8/(3 sqrt(3)); product factors <= 1.
            let derivative = 8 / (3 * sqrt(3.0))
            return hypot(derivative / radius.x, derivative / radius.y)
        }

        fileprivate func sample(at p: Point) -> ScalarSample {
            let x = (p.x - center.x) / radius.x, y = (p.y - center.y) / radius.y
            guard abs(x) < 1, abs(y) < 1 else { return ScalarSample(value: 0, gradient: .zero) }
            let a = 1 - x * x, b = 1 - y * y
            return ScalarSample(value: a * a * b * b,
                                gradient: Point(-4 * x * a * b * b / radius.x,
                                                -4 * y * b * a * a / radius.y))
        }
    }
    struct MShape: Sendable {
        var profile: Profile
        var envelope: Envelope
        /// A small independent lower-edge peak is required by four reliable
        /// lower-center correspondences. Its center.y is seam-relative. It
        /// does not extend a reverse motion across the entire lower lip.
        var lowerCenter: Lobe?
        /// Optional absolute-source envelope, independent of seam-relative
        /// tissue depth, for physical nose/eye protection.
        var sourceEnvelope: Envelope? = nil
        /// Optional seam-relative support for the upper profile alone. The
        /// independent lower-edge peak retains the outer tissue envelope.
        var profileEnvelope: Envelope? = nil
    }
    struct Fullness: Sendable {
        var upperRate: Double
        var lowerRate: Double
        var blendHalfWidth: Double
        var envelope: Envelope
        /// Absolute source protection is independent of the curved seam.
        var sourceEnvelope: Envelope? = nil
        /// Source-depth response: zero retains the linear stretch; one uses
        /// a C1 ramp from the seam to the observed lip depth. Outside that
        /// depth the response remains bounded by the original linear field.
        var depthCurvature: Double = 0
        var upperDepth: Double = 1
        var lowerDepth: Double = 1
        /// Optional upper-lip lateral support. Its vertical envelope matches
        /// `envelope`; a C2 seam blend joins the two lateral widths.
        var upperEnvelope: Envelope? = nil
    }
    struct Smile: Sendable {
        /// Left corner, central reverse peak, right corner. Vectors need not
        /// be exact mirror images; three source-defined peaks are sufficient.
        var lobes: [Lobe]
        var envelope: Envelope
        /// Optional source-local central upper-lip plateau. When present, it
        /// blends the two corner fields toward the central lobe's vector,
        /// instead of adding a bell that can be canceled by negative tails.
        var centralEnvelope: Envelope? = nil
    }
    struct Configuration: Sendable {
        var seam: Seam
        var size: Affine
        var width: Affine
        var vertical: Translation
        var tilt: Tilt
        var horizontal: Translation
        var mShape: MShape
        var fullness: Fullness
        var smile: Smile
    }

    let configuration: Configuration

    init?(configuration c: Configuration) {
        var envelopes = [c.size.envelope, c.width.envelope, c.vertical.envelope,
                         c.tilt.envelope, c.horizontal.envelope, c.mShape.envelope,
                         c.fullness.envelope, c.smile.envelope]
        if let source = c.mShape.sourceEnvelope { envelopes.append(source) }
        if let profile = c.mShape.profileEnvelope { envelopes.append(profile) }
        if let source = c.fullness.sourceEnvelope { envelopes.append(source) }
        if let upper = c.fullness.upperEnvelope { envelopes.append(upper) }
        if let central = c.smile.centralEnvelope { envelopes.append(central) }
        guard envelopes.allSatisfy(\.isValid),
              [c.size.rates, c.size.center, c.width.rates, c.width.center,
               c.vertical.vector, c.horizontal.vector, c.tilt.center].allSatisfy(Self.finite),
              c.tilt.angle.isFinite, c.fullness.upperRate.isFinite, c.fullness.lowerRate.isFinite,
              c.fullness.blendHalfWidth.isFinite, c.fullness.blendHalfWidth > 0,
              c.fullness.depthCurvature.isFinite, (0...1).contains(c.fullness.depthCurvature),
              c.fullness.upperDepth.isFinite, c.fullness.upperDepth > 0,
              c.fullness.lowerDepth.isFinite, c.fullness.lowerDepth > 0,
              c.fullness.envelope.radial == nil,
              c.fullness.sourceEnvelope?.radial == nil,
              c.fullness.upperEnvelope?.radial == nil,
              c.fullness.upperEnvelope.map({ $0.outerMin.y == c.fullness.envelope.outerMin.y
                && $0.innerMin.y == c.fullness.envelope.innerMin.y
                && $0.innerMax.y == c.fullness.envelope.innerMax.y
                && $0.outerMax.y == c.fullness.envelope.outerMax.y }) != false,
              c.smile.lobes.count == 3, c.smile.lobes.allSatisfy(\.isValid),
              c.mShape.lowerCenter?.isValid != false else { return nil }
        self.configuration = c
        guard Field.allCases.allSatisfy({
            let b = bounds(field: $0, strength: 1)
            return b.maximumGradient.isFinite && b.maximumDisplacement.isFinite
        }) else { return nil }
    }

    func sample(field: Field, strength: Double, at p: Point) -> Sample {
        guard strength.isFinite, strength != 0, Self.finite(p) else { return .zero }
        switch field {
        case .size: return affine(configuration.size, strength: strength, at: p)
        case .width: return affine(configuration.width, strength: strength, at: p)
        case .vertical: return translation(configuration.vertical, strength: strength, at: p)
        case .horizontal: return translation(configuration.horizontal, strength: strength, at: p)
        case .tilt:
            let c = configuration.tilt, w = c.envelope.sample(at: p), r = p - c.center
            guard w.value != 0 else { return .zero }
            let theta = c.angle * strength, phi = theta * w.value
            let co = cos(phi), si = sin(phi)
            let rotated = Point(co * r.x - si * r.y, si * r.x + co * r.y)
            let angular = theta * Point(-rotated.y, rotated.x)
            return Sample(displacement: rotated - r,
                          gradientX: Point(co - 1, si) + angular * w.gradient.x,
                          gradientY: Point(-si, co - 1) + angular * w.gradient.y)
        case .mShape:
            let c = configuration.mShape, seam = configuration.seam.sample(at: p.x)
            let z = Point(p.x, p.y - seam.value), w = c.envelope.sample(at: z)
            guard w.value != 0 else { return .zero }
            let profile = c.profile.sample(at: p.x)
            var v = Point(0, profile.value)
            var vx = Point(0, profile.derivative), vy = Point.zero
            if let profileEnvelope = c.profileEnvelope {
                let g = profileEnvelope.sample(at: z)
                v = Point(0, profile.value * g.value)
                vx = Point(0, profile.derivative * g.value + profile.value * g.gradient.x)
                vy = Point(0, profile.value * g.gradient.y)
            }
            if let lobe = c.lowerCenter {
                let b = lobe.sample(at: z)
                v += lobe.vector * b.value
                vx += lobe.vector * b.gradient.x
                vy += lobe.vector * b.gradient.y
            }
            // Chain rule t=y-m(s), including the independent lower-edge peak.
            let sourceGradient = Point(w.gradient.x - seam.slope * w.gradient.y, w.gradient.y)
            let dx = vx - seam.slope * vy
            var result = Sample(displacement: v * (strength * w.value),
                          gradientX: strength * (dx * w.value + v * sourceGradient.x),
                          gradientY: strength * (vy * w.value + v * sourceGradient.y))
            if let source = c.sourceEnvelope {
                let s = source.sample(at: p), displacement = result.displacement
                result = Sample(displacement: displacement * s.value,
                                gradientX: result.gradientX * s.value + displacement * s.gradient.x,
                                gradientY: result.gradientY * s.value + displacement * s.gradient.y)
            }
            return result
        case .fullness:
            let c = configuration.fullness, seam = configuration.seam.sample(at: p.x)
            let t = p.y - seam.value, z = Point(p.x, t)
            let down = c.envelope.sample(at: z), up = c.upperEnvelope?.sample(at: z) ?? down
            guard down.value != 0 || up.value != 0 else { return .zero }
            let blend = Self.fullnessBlend(c, at: t)
            let w = (1 - blend.value) * up.value + blend.value * down.value
            let wx = (1 - blend.value) * up.gradient.x + blend.value * down.gradient.x
            let twy = t * ((1 - blend.value) * up.gradient.y + blend.value * down.gradient.y)
                + blend.tTimesDerivative * (down.value - up.value)
            let transition = Self.fullnessRate(c, at: t)
            let rate = transition.rate
            let v = rate * t, vt = rate + transition.tTimesDerivative
            let dt = twy * rate + w * vt
            let ds = wx * v - seam.slope * dt
            var result = Sample(displacement: Point(0, strength * w * v),
                                gradientX: Point(0, strength * ds), gradientY: Point(0, strength * dt))
            if let source = c.sourceEnvelope {
                let z = source.sample(at: p), displacement = result.displacement
                result = Sample(displacement: displacement * z.value,
                                gradientX: result.gradientX * z.value + displacement * z.gradient.x,
                                gradientY: result.gradientY * z.value + displacement * z.gradient.y)
            }
            return result
        case .smile:
            let c = configuration.smile, w = c.envelope.sample(at: p)
            guard w.value != 0 else { return .zero }
            var v = Point.zero, vx = Point.zero, vy = Point.zero
            for (index, lobe) in c.lobes.enumerated() where c.centralEnvelope == nil || index != 1 {
                let b = lobe.sample(at: p)
                v += lobe.vector * b.value
                vx += lobe.vector * b.gradient.x
                vy += lobe.vector * b.gradient.y
            }
            if let central = c.centralEnvelope {
                let b = central.sample(at: p), difference = c.lobes[1].vector - v
                vx = (1 - b.value) * vx + difference * b.gradient.x
                vy = (1 - b.value) * vy + difference * b.gradient.y
                v = (1 - b.value) * v + b.value * c.lobes[1].vector
            }
            return Sample(displacement: strength * w.value * v,
                          gradientX: strength * (w.value * vx + w.gradient.x * v),
                          gradientY: strength * (w.value * vy + w.gradient.y * v))
        }
    }

    func bounds(field: Field, strength: Double) -> Bounds {
        guard strength.isFinite, strength != 0 else { return .zero }
        let u = abs(strength)
        switch field {
        case .size: return affineBounds(configuration.size, strength: u)
        case .width: return affineBounds(configuration.width, strength: u)
        case .vertical: return translationBounds(configuration.vertical, strength: u)
        case .horizontal: return translationBounds(configuration.horizontal, strength: u)
        case .tilt:
            let c = configuration.tilt, theta = abs(c.angle) * u
            let radius = Self.radius(envelope: c.envelope, center: c.center)
            let rotation = 2 * sin(min(theta, Double.pi) * 0.5)
            return Bounds(maximumDisplacement: rotation * radius,
                          maximumGradient: rotation + theta * radius * Self.norm(c.envelope.gradientBounds))
        case .mShape:
            let c = configuration.mShape, slope = configuration.seam.maximumSlope
            let g = c.envelope.gradientBounds
            let envelopeGradient = hypot(g.x + slope * g.y, g.y)
            let p = c.profile.maximumValue, dp = c.profile.maximumDerivative
            let magnitude = c.lowerCenter.map { Self.norm($0.vector) } ?? 0
            let derivative = c.lowerCenter.map { $0.gradientBound * Self.shearNorm(slope) } ?? 0
            let displacement = u * (p + magnitude)
            let sourceGradient = c.sourceEnvelope.map { Self.norm($0.gradientBounds) } ?? 0
            let profileGradient = c.profileEnvelope.map { envelope -> Double in
                let g = envelope.gradientBounds
                return hypot(g.x + slope * g.y, g.y)
            } ?? 0
            return Bounds(maximumDisplacement: displacement,
                          maximumGradient: u * (dp + p * profileGradient + magnitude * derivative + (p + magnitude) * envelopeGradient)
                            + displacement * sourceGradient)
        case .fullness:
            let c = configuration.fullness, slope = configuration.seam.maximumSlope
            var g = c.envelope.gradientBounds
            if let upper = c.upperEnvelope {
                let h = upper.gradientBounds
                g = Point(max(g.x, h.x), max(g.y, h.y))
            }
            let envelopeGradient = hypot(g.x + slope * g.y, g.y)
            let rate = max(abs(c.upperRate), abs(c.lowerRate))
            let t = max(abs(c.envelope.outerMin.y), abs(c.envelope.outerMax.y))
            // b' is confined to |t|<=delta. max S5'=1.875, hence
            // |t b'| <= 0.9375 |bDown-bUp| independently of delta.
            // max r*S3'(r)=8/9. The depth ramp is constant for r>=1.
            let derivative = rate * (1 + (8.0 / 9.0) * c.depthCurvature)
                + 0.9375 * abs(c.lowerRate - c.upperRate)
                + (c.upperEnvelope == nil ? 0 : 0.9375 * rate)
            let displacement = u * rate * t
            let sourceGradient = c.sourceEnvelope.map { Self.norm($0.gradientBounds) } ?? 0
            return Bounds(maximumDisplacement: displacement,
                          maximumGradient: u * (rate * t * envelopeGradient + derivative * hypot(1, slope))
                            + displacement * sourceGradient)
        case .smile:
            let c = configuration.smile
            if let central = c.centralEnvelope {
                let corners = Self.lobeBounds([c.lobes[0], c.lobes[2]])
                let centerMagnitude = Self.norm(c.lobes[1].vector)
                let magnitude = max(corners.0, centerMagnitude)
                let gradient = corners.1 + (corners.0 + centerMagnitude) * Self.norm(central.gradientBounds)
                return Bounds(maximumDisplacement: u * magnitude,
                              maximumGradient: u * (gradient + magnitude * Self.norm(c.envelope.gradientBounds)))
            }
            let combined = Self.lobeBounds(c.lobes)
            return Bounds(maximumDisplacement: u * combined.0,
                          maximumGradient: u * (combined.1 + combined.0 * Self.norm(c.envelope.gradientBounds)))
        }
    }

    /// Certified lower bound on the source-y derivative of the fullness
    /// displacement. Unlike a two-dimensional Lipschitz cap, this does not
    /// penalize harmless expansion or seam-induced horizontal shear. Pure
    /// fullness keeps source x unchanged, so `1 + result > 0` proves strict
    /// monotonicity of every entire vertical source column (exterior included).
    ///
    /// Write D_y=u*X(s,t)*Z(s,y)*h(t), h(t)=w_y(t)*b(t)*t*K(t). For fixed source s,
    /// dt/dy=1. Its derivative is u*[X*(Z*h'+Z_y*h)+Z*h*X_t]. The source
    /// envelope's separate x factor is in [0,1], so its omission followed by
    /// a hull with zero is conservative. We bound this on an exact covering
    /// of its analytic pieces with outward-rounded interval arithmetic; the
    /// subdivisions bound whole intervals, rather than evaluating grid points.
    func minimumVerticalDerivativeForFullness(strength: Double) -> Double {
        guard strength.isFinite else { return -.infinity }
        guard strength != 0 else { return 0 }
        let c = configuration.fullness, e = c.envelope, delta = c.blendHalfWidth
        var breakpoints = [e.outerMin.y, e.innerMin.y, e.innerMax.y, e.outerMax.y,
                              max(e.outerMin.y, min(e.outerMax.y, -delta)),
                              max(e.outerMin.y, min(e.outerMax.y, delta))]
        if c.depthCurvature != 0 {
            breakpoints += [-c.upperDepth, 0, c.lowerDepth].map { max(e.outerMin.y, min(e.outerMax.y, $0)) }
        }
        if let source = c.sourceEnvelope {
            for y in [source.outerMin.y, source.innerMin.y, source.innerMax.y, source.outerMax.y] {
                for seam in [configuration.seam.minimumValue, configuration.seam.maximumValue] {
                    breakpoints.append(max(e.outerMin.y, min(e.outerMax.y, y - seam)))
                }
            }
        }
        let cuts = Array(Set(breakpoints)).sorted()
        var lower = 0.0, upper = 0.0
        // The absolute protection transition and seam are correlated in x.
        // Keep this correlation in continuous column boxes; a global seam
        // range paired with every x weight needlessly suppresses the field.
        var columns = [(Double, Double)]()
        if c.sourceEnvelope != nil || c.upperEnvelope != nil {
            let u = c.upperEnvelope ?? e
            let outerLow = min(e.outerMin.x, u.outerMin.x), outerHigh = max(e.outerMax.x, u.outerMax.x)
            let xs = Array(Set([e.outerMin.x, e.outerMax.x, e.innerMin.x, e.innerMax.x,
                               u.outerMin.x, u.outerMax.x, u.innerMin.x, u.innerMax.x]
                + configuration.seam.knots.map(\.x).filter { $0 > outerLow && $0 < outerHigh })).sorted()
            for (a, b) in zip(xs, xs.dropFirst()) {
                for part in 0..<8 {
                    columns.append((part == 0 ? a : a + (b - a) * Double(part) / 8,
                                    part == 7 ? b : a + (b - a) * Double(part + 1) / 8))
                }
            }
        } else { columns = [(e.outerMin.x, e.outerMax.x)] }
        for column in columns {
          let seamRange = configuration.seam.valueRange(from: column.0, to: column.1)
          // The source envelope's own horizontal factor is in [0,1]; it
          // cannot make the lower bound worse than its hull with zero.
          let downX = c.sourceEnvelope == nil && c.upperEnvelope == nil ? Interval(0, 1)
            : Self.axisEnvelopeRange(Interval(column.0, column.1), outerLow: e.outerMin.x,
                innerLow: e.innerMin.x, innerHigh: e.innerMax.x, outerHigh: e.outerMax.x).value
          let upX: Interval
          if let u = c.upperEnvelope {
            upX = Self.axisEnvelopeRange(Interval(column.0, column.1), outerLow: u.outerMin.x,
                innerLow: u.innerMin.x, innerHigh: u.innerMax.x, outerHigh: u.outerMax.x).value
          } else { upX = downX }
          for index in 0..<(cuts.count - 1) {
            let a = cuts[index], b = cuts[index + 1]
            guard b > a else { continue }
            for segment in 0..<64 {
                let lo = segment == 0 ? a : a + (b - a) * (Double(segment) / 64)
                let hi = segment == 63 ? b : a + (b - a) * (Double(segment + 1) / 64)
                guard hi > lo else { continue }
                let t = Interval(lo, hi)
                let vertical = Self.verticalEnvelopeInterval(t, envelope: e)
                let response = Self.fullnessRateInterval(c, at: t)
                let xWeight: Interval, txPrime: Interval
                if c.upperEnvelope != nil {
                    let blend = Self.fullnessBlendInterval(c, at: t)
                    xWeight = ((Interval.point(1) - blend.value) * upX + blend.value * downX).clampedUnit
                    txPrime = (downX - upX) * blend.tTimesDerivative
                } else { xWeight = downX; txPrime = .point(0) }
                var derivative = vertical.derivative * response.rate * t
                    + vertical.value * (response.rate + response.tTimesDerivative)
                var sourceValue = Interval.point(1)
                if let source = c.sourceEnvelope {
                    // One source-y interval covers every possible seam value.
                    // It can cross several source-envelope branches: split
                    // and hull all of them instead of treating it as plateau.
                    let y = t + Interval(seamRange.0, seamRange.1)
                    let z = Self.verticalEnvelopeRange(y, envelope: source)
                    derivative = z.value * derivative + z.derivative * vertical.value * response.rate * t
                    sourceValue = z.value
                }
                derivative = xWeight * derivative + sourceValue * vertical.value * response.rate * txPrime
                guard derivative.lower.isFinite, derivative.upper.isFinite else { return -.infinity }
                lower = min(lower, derivative.lower)
                upper = max(upper, derivative.upper)
            }
          }
        }
        // Negative strength reverses the interval ordering. Multiplication is
        // also rounded outwards; the exterior and zero x-weight contribute 0.
        let result = Interval(lower, upper) * Interval.point(strength)
        return min(0, result.lower)
    }

    private func affine(_ c: Affine, strength: Double, at p: Point) -> Sample {
        let w = c.envelope.sample(at: p), r = p - c.center
        let v = c.rates * r
        return Sample(displacement: strength * w.value * v,
                      gradientX: strength * (Point(c.rates.x * w.value, 0) + v * w.gradient.x),
                      gradientY: strength * (Point(0, c.rates.y * w.value) + v * w.gradient.y))
    }

    private func translation(_ c: Translation, strength: Double, at p: Point) -> Sample {
        let w = c.envelope.sample(at: p), vector = strength * c.vector
        return Sample(displacement: w.value * vector,
                      gradientX: vector * w.gradient.x, gradientY: vector * w.gradient.y)
    }

    private func affineBounds(_ c: Affine, strength: Double) -> Bounds {
        let x = max(abs(c.envelope.outerMin.x - c.center.x), abs(c.envelope.outerMax.x - c.center.x))
        let y = max(abs(c.envelope.outerMin.y - c.center.y), abs(c.envelope.outerMax.y - c.center.y))
        let magnitude = hypot(c.rates.x * x, c.rates.y * y)
        return Bounds(maximumDisplacement: strength * magnitude,
                      maximumGradient: strength * (max(abs(c.rates.x), abs(c.rates.y))
                          + magnitude * Self.norm(c.envelope.gradientBounds)))
    }

    private func translationBounds(_ c: Translation, strength: Double) -> Bounds {
        let magnitude = strength * Self.norm(c.vector)
        return Bounds(maximumDisplacement: magnitude,
                      maximumGradient: magnitude * Self.norm(c.envelope.gradientBounds))
    }

    /// Split only at exact rectangular support boundaries. On every resulting
    /// open cell the set of possibly active lobes is fixed. Taking a triangle
    /// bound per cell avoids summing disjoint corner peaks; no sampled maximum
    /// is used as a certificate. Boundary values and derivatives are zero.
    private static func lobeBounds(_ lobes: [Lobe]) -> (Double, Double) {
        let xs = Array(Set(lobes.flatMap { [$0.center.x - $0.radius.x, $0.center.x + $0.radius.x] })).sorted()
        let ys = Array(Set(lobes.flatMap { [$0.center.y - $0.radius.y, $0.center.y + $0.radius.y] })).sorted()
        var magnitude = 0.0, derivative = 0.0
        guard xs.count >= 2, ys.count >= 2 else { return (0, 0) }
        for ix in 0..<(xs.count - 1) { for iy in 0..<(ys.count - 1) {
            let x = (xs[ix] + xs[ix + 1]) * 0.5, y = (ys[iy] + ys[iy + 1]) * 0.5
            var v = 0.0, d = 0.0
            for lobe in lobes where abs(x - lobe.center.x) < lobe.radius.x && abs(y - lobe.center.y) < lobe.radius.y {
                let length = norm(lobe.vector)
                v += length; d += length * lobe.gradientBound
            }
            magnitude = max(magnitude, v); derivative = max(derivative, d)
        } }
        return (magnitude, derivative)
    }

    private static func radius(envelope: Envelope, center: Point) -> Double {
        let x = max(abs(envelope.outerMin.x - center.x), abs(envelope.outerMax.x - center.x))
        let y = max(abs(envelope.outerMin.y - center.y), abs(envelope.outerMax.y - center.y))
        return hypot(x, y)
    }
    private static func shearNorm(_ slope: Double) -> Double { (hypot(slope, 2) + abs(slope)) * 0.5 }
    private static func norm(_ p: Point) -> Double { hypot(p.x, p.y) }
    private static func finite(_ p: Point) -> Bool { p.x.isFinite && p.y.isFinite }
    private static func smooth5(_ t: Double) -> Double {
        if t <= 0 { return 0 }; if t >= 1 { return 1 }
        return t * t * t * (10 + t * (-15 + 6 * t))
    }
    private static func smooth5Derivative(_ t: Double) -> Double {
        guard t > 0, t < 1 else { return 0 }
        return 30 * t * t * (1 - t) * (1 - t)
    }

    private static func fullnessRate(_ c: Fullness, at t: Double) -> (rate: Double, tTimesDerivative: Double) {
        let rate: Double, tTimesDerivative: Double
        if t <= -c.blendHalfWidth { rate = c.upperRate; tTimesDerivative = 0 }
        else if t >= c.blendHalfWidth { rate = c.lowerRate; tTimesDerivative = 0 }
        else {
        // Computing t*b'(t) directly avoids a potentially huge intermediate
        // b' when the source seam blend is exceptionally narrow.
        let normalized = t / c.blendHalfWidth, z = (normalized + 1) * 0.5
        let difference = c.lowerRate - c.upperRate
            rate = c.upperRate + difference * smooth5(z)
            tTimesDerivative = difference * 0.5 * normalized * smooth5Derivative(z)
        }
        let r = min(1, abs(t) / (t < 0 ? c.upperDepth : c.lowerDepth))
        let k = 1 - c.depthCurvature + c.depthCurvature * r * r * (3 - 2 * r)
        let tkPrime = c.depthCurvature * 6 * r * r * (1 - r)
        return (rate * k, tTimesDerivative * k + rate * tkPrime)
    }

    private static func fullnessBlend(_ c: Fullness, at t: Double) -> (value: Double, tTimesDerivative: Double) {
        if t <= -c.blendHalfWidth { return (0, 0) }
        if t >= c.blendHalfWidth { return (1, 0) }
        let normalized = t / c.blendHalfWidth, z = (normalized + 1) * 0.5
        return (smooth5(z), 0.5 * normalized * smooth5Derivative(z))
    }

    private static func fullnessBlendInterval(_ c: Fullness, at t: Interval)
        -> (value: Interval, tTimesDerivative: Interval) {
        if t.upper <= -c.blendHalfWidth { return (.point(0), .point(0)) }
        if t.lower >= c.blendHalfWidth { return (.point(1), .point(0)) }
        let normalized = t / c.blendHalfWidth
        let z = ((normalized + .point(1)) * .point(0.5)).clampedUnit
        let derivative = Interval.point(30) * z * z * (.point(1) - z) * (.point(1) - z)
        return (smooth5Interval(z), .point(0.5) * normalized * derivative)
    }

    private static func verticalEnvelopeInterval(_ t: Interval, envelope e: Envelope)
        -> (value: Interval, derivative: Interval) {
        if t.upper <= e.outerMin.y || t.lower >= e.outerMax.y { return (.point(0), .point(0)) }
        if t.upper <= e.innerMin.y {
            let width = e.innerMin.y - e.outerMin.y
            let z = ((t - .point(e.outerMin.y)) / width).clampedUnit
            return (smooth3Interval(z), (.point(6) * z * (.point(1) - z)) / width)
        }
        if t.lower >= e.innerMax.y {
            let width = e.outerMax.y - e.innerMax.y
            let z = ((t - .point(e.innerMax.y)) / width).clampedUnit
            return (.point(1) - smooth3Interval(z), (.point(-6) * z * (.point(1) - z)) / width)
        }
        return (.point(1), .point(0))
    }

    /// Enclose the complete piecewise cubic, including exterior and every
    /// transition crossed by an arbitrary source-y interval.
    private static func verticalEnvelopeRange(_ y: Interval, envelope e: Envelope)
        -> (value: Interval, derivative: Interval) {
        axisEnvelopeRange(y, outerLow: e.outerMin.y, innerLow: e.innerMin.y,
                          innerHigh: e.innerMax.y, outerHigh: e.outerMax.y)
    }

    private static func axisEnvelopeRange(_ y: Interval, outerLow: Double, innerLow: Double,
                                          innerHigh: Double, outerHigh: Double)
        -> (value: Interval, derivative: Interval) {
        let cuts = [y.lower] + [outerLow, innerLow, innerHigh, outerHigh]
            .filter { $0 > y.lower && $0 < y.upper } + [y.upper]
        // Only the y coordinates are used by verticalEnvelopeInterval.
        let e = Envelope(innerMin: Point(-1, innerLow), innerMax: Point(1, innerHigh),
                         outerMin: Point(-2, outerLow), outerMax: Point(2, outerHigh))
        var valueLow = Double.infinity, valueHigh = -Double.infinity
        var derivativeLow = Double.infinity, derivativeHigh = -Double.infinity
        for (lo, hi) in zip(cuts, cuts.dropFirst()) {
            let part = verticalEnvelopeInterval(Interval(lo, hi), envelope: e)
            valueLow = min(valueLow, part.value.lower); valueHigh = max(valueHigh, part.value.upper)
            derivativeLow = min(derivativeLow, part.derivative.lower)
            derivativeHigh = max(derivativeHigh, part.derivative.upper)
        }
        return (Interval(valueLow, valueHigh), Interval(derivativeLow, derivativeHigh))
    }

    private static func fullnessRateInterval(_ c: Fullness, at t: Interval)
        -> (rate: Interval, tTimesDerivative: Interval) {
        let rate: Interval, tTimesDerivative: Interval
        if t.upper <= -c.blendHalfWidth { rate = .point(c.upperRate); tTimesDerivative = .point(0) }
        else if t.lower >= c.blendHalfWidth { rate = .point(c.lowerRate); tTimesDerivative = .point(0) }
        else {
        let normalized = t / c.blendHalfWidth
        let z = ((normalized + .point(1)) * .point(0.5)).clampedUnit
        let difference = Interval.point(c.lowerRate) - .point(c.upperRate)
        let derivative = Interval.point(30) * z * z * (.point(1) - z) * (.point(1) - z)
            rate = .point(c.upperRate) + difference * smooth5Interval(z)
            tTimesDerivative = difference * .point(0.5) * normalized * derivative
        }
        guard c.depthCurvature != 0 else { return (rate, tTimesDerivative) }
        // The exact covering includes zero and both lip depths, so each
        // interval lies on one side of the seam and of each saturation cut.
        let depth = t.upper <= 0 ? c.upperDepth : c.lowerDepth
        let absolute = t.upper <= 0 ? Interval(-t.upper, -t.lower) : t
        let r = (absolute / depth).clampedUnit
        let a = Interval.point(c.depthCurvature)
        let k = .point(1) - a + a * smooth3Interval(r)
        let tkPrime = a * .point(6) * r * r * (.point(1) - r)
        return (rate * k, tTimesDerivative * k + rate * tkPrime)
    }

    private static func smooth3Interval(_ t: Interval) -> Interval {
        // S3 and S5 are monotone on [0,1]. Evaluate their two endpoints with
        // outward arithmetic, rather than a dependency-heavy whole polynomial.
        func endpoint(_ value: Double) -> Interval {
            let z = Interval.point(value)
            return z * z * (.point(3) - .point(2) * z)
        }
        return Interval(endpoint(t.lower).lower, endpoint(t.upper).upper).clampedUnit
    }

    private static func smooth5Interval(_ t: Interval) -> Interval {
        func endpoint(_ value: Double) -> Interval {
            let z = Interval.point(value)
            return z * z * z * (.point(10) + z * (.point(-15) + .point(6) * z))
        }
        return Interval(endpoint(t.lower).lower, endpoint(t.upper).upper).clampedUnit
    }

    /// Elementary interval operations with a one-ULP outward enclosure for
    /// every floating point operation. The finite source parameters are exact
    /// constants here; every interval contains the corresponding real result.
    private struct Interval {
        var lower: Double
        var upper: Double
        init(_ lower: Double, _ upper: Double) { self.lower = lower; self.upper = upper }
        static func point(_ x: Double) -> Self { Self(x, x) }
        var clampedUnit: Self { Self(min(1, max(0, lower)), min(1, max(0, upper))) }
        static func + (a: Self, b: Self) -> Self {
            Self((a.lower + b.lower).nextDown, (a.upper + b.upper).nextUp)
        }
        static func - (a: Self, b: Self) -> Self {
            Self((a.lower - b.upper).nextDown, (a.upper - b.lower).nextUp)
        }
        static func * (a: Self, b: Self) -> Self {
            let values = [a.lower * b.lower, a.lower * b.upper, a.upper * b.lower, a.upper * b.upper]
            return Self(values.min()!.nextDown, values.max()!.nextUp)
        }
        static func / (a: Self, b: Double) -> Self {
            // Every caller supplies a validated positive source distance.
            Self((a.lower / b).nextDown, (a.upper / b).nextUp)
        }
    }
    fileprivate struct ScalarSample {
        var value: Double
        var gradient: Point
    }
}
