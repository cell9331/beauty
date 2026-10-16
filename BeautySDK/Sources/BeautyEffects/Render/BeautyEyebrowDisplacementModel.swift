import Foundation

/// Source-coordinate eyebrow geometry from docs/eyebrow-displacement. The
/// coefficients below are adjustable design candidates, not reference fits.
/// The model moves both hair and adjacent skin; RGB never determines its field.
struct BeautyEyebrowDisplacementModel {
    /// C1 cubic Hermite interpolation with first-order endpoint continuation.
    /// Default tangents preserve shape; explicit endpoint derivatives can hold
    /// thickness envelopes flat outside their knots. Stored extrema cover the
    /// knot span; `bounds(in:)` includes continuation in a finite interval.
    struct Profile {
        private struct Segment {
            let start: Double, end: Double
            let a: Double, b: Double, c: Double, d: Double

            func value(_ t: Double) -> Double { ((a * t + b) * t + c) * t + d }
            func derivative(_ t: Double) -> Double { (3 * a * t * t + 2 * b * t + c) / (end - start) }
            var stationaryPoints: [Double] {
                if a == 0 { return b == 0 ? [] : [-c / (2 * b)] }
                let discriminant = 4 * b * b - 12 * a * c
                guard discriminant >= 0 else { return [] }
                let root = sqrt(discriminant)
                return [(-2 * b - root) / (6 * a), (-2 * b + root) / (6 * a)]
            }
        }

        let samples: [SIMD2<Double>]
        private let tangents: [Double]
        private let segments: [Segment]
        let maximumAbsoluteDerivative: Double
        let minimumValue: Double
        let maximumValue: Double

        init?(samples: [SIMD2<Double>], endpointDerivatives: SIMD2<Double>? = nil) {
            guard !samples.isEmpty, samples.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
                  zip(samples, samples.dropFirst()).allSatisfy({ $0.x < $1.x }) else { return nil }
            if let endpoints = endpointDerivatives, !endpoints.x.isFinite || !endpoints.y.isFinite { return nil }
            if samples.count == 1 {
                if let endpoints = endpointDerivatives, endpoints.x != endpoints.y { return nil }
                let slope = endpointDerivatives?.x ?? 0
                self.samples = samples; tangents = [slope]; segments = []
                maximumAbsoluteDerivative = abs(slope)
                minimumValue = samples[0].y; maximumValue = samples[0].y
                return
            }
            let spans = zip(samples, samples.dropFirst()).map { $1.x - $0.x }
            let secants = zip(samples, samples.dropFirst()).enumerated().map { index, pair in
                (pair.1.y - pair.0.y) / spans[index]
            }
            guard spans.allSatisfy({ $0.isFinite && $0 > 0 }), secants.allSatisfy(\.isFinite) else { return nil }
            var slopes = [Double](repeating: 0, count: samples.count)
            if samples.count == 2 {
                slopes = [secants[0], secants[0]]
            } else {
                func endpoint(_ h0: Double, _ h1: Double, _ d0: Double, _ d1: Double) -> Double {
                    var result = ((2 * h0 + h1) * d0 - h0 * d1) / (h0 + h1)
                    if !Self.sameSign(result, d0) { result = 0 }
                    else if !Self.sameSign(d0, d1), abs(result) > 3 * abs(d0) { result = 3 * d0 }
                    return result
                }
                slopes[0] = endpoint(spans[0], spans[1], secants[0], secants[1])
                let last = spans.count - 1
                slopes[samples.count - 1] = endpoint(spans[last], spans[last - 1], secants[last], secants[last - 1])
                for i in 1..<(samples.count - 1) where Self.sameSign(secants[i - 1], secants[i]) {
                    let w0 = 2 * spans[i] + spans[i - 1], w1 = spans[i] + 2 * spans[i - 1]
                    slopes[i] = (w0 + w1) / (w0 / secants[i - 1] + w1 / secants[i])
                }
            }
            if let endpoints = endpointDerivatives {
                slopes[0] = endpoints.x; slopes[slopes.count - 1] = endpoints.y
            }
            guard slopes.allSatisfy(\.isFinite) else { return nil }
            var pieces = [Segment](), minimum = samples[0].y, maximum = samples[0].y
            var derivative = slopes.map { abs($0) }.max() ?? 0
            for i in spans.indices {
                let y0 = samples[i].y, y1 = samples[i + 1].y
                let m0 = slopes[i] * spans[i], m1 = slopes[i + 1] * spans[i]
                let piece = Segment(start: samples[i].x, end: samples[i + 1].x,
                    a: 2 * y0 - 2 * y1 + m0 + m1,
                    b: -3 * y0 + 3 * y1 - 2 * m0 - m1, c: m0, d: y0)
                guard [piece.a, piece.b, piece.c, piece.d].allSatisfy(\.isFinite) else { return nil }
                let positions = [0.0, 1.0] + piece.stationaryPoints.filter { $0 > 0 && $0 < 1 }
                for t in positions {
                    minimum = min(minimum, piece.value(t)); maximum = max(maximum, piece.value(t))
                }
                var derivativePositions = [0.0, 1.0]
                if piece.a != 0 {
                    let t = -piece.b / (3 * piece.a)
                    if t > 0, t < 1 { derivativePositions.append(t) }
                }
                for t in derivativePositions { derivative = max(derivative, abs(piece.derivative(t))) }
                pieces.append(piece)
            }
            guard minimum.isFinite, maximum.isFinite, derivative.isFinite else { return nil }
            self.samples = samples; tangents = slopes; segments = pieces
            minimumValue = Self.lowerBound(minimum); maximumValue = Self.upperBound(maximum)
            maximumAbsoluteDerivative = derivative == 0 ? 0 : Self.upperBound(derivative)
        }

        func value(at r: Double) -> Double {
            if r <= samples[0].x { return samples[0].y + (r - samples[0].x) * tangents[0] }
            let last = samples.count - 1
            if r >= samples[last].x { return samples[last].y + (r - samples[last].x) * tangents[last] }
            let piece = segments[interval(r)]
            return piece.value((r - piece.start) / (piece.end - piece.start))
        }

        func derivative(at r: Double) -> Double {
            if r <= samples[0].x { return tangents[0] }
            if r >= samples[samples.count - 1].x { return tangents[tangents.count - 1] }
            let piece = segments[interval(r)]
            return piece.derivative((r - piece.start) / (piece.end - piece.start))
        }

        func bounds(in range: ClosedRange<Double>) -> (minimum: Double, maximum: Double) {
            var minimum = min(value(at: range.lowerBound), value(at: range.upperBound))
            var maximum = max(value(at: range.lowerBound), value(at: range.upperBound))
            if !segments.isEmpty, range.upperBound >= segments[0].start,
               range.lowerBound <= segments[segments.count - 1].end {
                let first = interval(range.lowerBound)
                var last = interval(range.upperBound)
                // Both pieces touched by an exact knot were included before;
                // retain their zero-length intersections and rounding behavior.
                if last + 1 < segments.count, segments[last + 1].start <= range.upperBound { last += 1 }
                for index in first...last {
                    let piece = segments[index]
                    let lower = max(0, (range.lowerBound - piece.start) / (piece.end - piece.start))
                    let upper = min(1, (range.upperBound - piece.start) / (piece.end - piece.start))
                    for t in [lower, upper] + piece.stationaryPoints.filter({ $0 >= lower && $0 <= upper }) {
                        minimum = min(minimum, piece.value(t)); maximum = max(maximum, piece.value(t))
                    }
                }
            }
            return (Self.lowerBound(minimum), Self.upperBound(maximum))
        }

        func derivativeBounds(in range: ClosedRange<Double>) -> (minimum: Double, maximum: Double) {
            var minimum = min(derivative(at: range.lowerBound), derivative(at: range.upperBound))
            var maximum = max(derivative(at: range.lowerBound), derivative(at: range.upperBound))
            if !segments.isEmpty, range.upperBound >= segments[0].start,
               range.lowerBound <= segments[segments.count - 1].end {
                let first = interval(range.lowerBound)
                var last = interval(range.upperBound)
                if last + 1 < segments.count, segments[last + 1].start <= range.upperBound { last += 1 }
                for index in first...last {
                    let piece = segments[index]
                    let lower = max(0, (range.lowerBound - piece.start) / (piece.end - piece.start))
                    let upper = min(1, (range.upperBound - piece.start) / (piece.end - piece.start))
                    var positions = [lower, upper]
                    if piece.a != 0 {
                        let stationary = -piece.b / (3 * piece.a)
                        if stationary > lower, stationary < upper { positions.append(stationary) }
                    }
                    for t in positions {
                        minimum = min(minimum, piece.derivative(t)); maximum = max(maximum, piece.derivative(t))
                    }
                }
            }
            return (Self.lowerBound(minimum), Self.upperBound(maximum))
        }

        private func interval(_ r: Double) -> Int {
            var lower = 0, upper = segments.count - 1
            while lower < upper {
                let middle = (lower + upper) / 2
                if r > segments[middle].end { lower = middle + 1 } else { upper = middle }
            }
            return lower
        }
        private static func sameSign(_ a: Double, _ b: Double) -> Bool { (a > 0 && b > 0) || (a < 0 && b < 0) }
        private static func lowerBound(_ x: Double) -> Double { x - max(1, abs(x)) * 32 * Double.ulpOfOne }
        private static func upperBound(_ x: Double) -> Double { x + max(1, abs(x)) * 32 * Double.ulpOfOne }
    }

    struct Geometry {
        let origin: SIMD2<Double>
        let horizontal: SIMD2<Double>
        let vertical: SIMD2<Double>
        let isLeft: Bool
        let length: Double
        let ridge: Profile
        let upper: Profile
        let lower: Profile

        var outward: SIMD2<Double> { horizontal * (isLeft ? -1 : 1) }
        func local(_ point: SIMD2<Double>) -> SIMD2<Double> {
            let delta = point - origin
            return SIMD2(delta.x * outward.x + delta.y * outward.y,
                         delta.x * vertical.x + delta.y * vertical.y)
        }
    }

    struct Support {
        let upper: Double
        let lower: Double
        let head: Double
        let tail: Double
    }

    /// Every amplitude and location remains a candidate until reference fitting
    /// and output review. Independent endpoints avoid claiming neutral symmetry.
    struct Calibration {
        var verticalPositiveFraction = 0.041
        var verticalNegativeFraction = 0.041
        var thicknessUpperPositive = 0.23
        var thicknessUpperNegative = 0.23
        var thicknessLowerPositive = 0.23
        var thicknessLowerNegative = 0.23
        var thicknessBlendWidthFraction = 0.025
        var lengthPositiveFraction = 0.055
        var lengthNegativeFraction = 0.040
        var lengthAnchorT = 0.20
        var lengthPlateauT = 0.65
        var lengthTailDecayStartT: Double? = nil
        var lengthTailZeroT: Double? = nil
        var spacingPositiveFraction = 0.10
        var spacingNegativeFraction = 0.10
        var spacingTailRatio = 0.30
        var headSpacingPositiveFraction = 0.12
        var headSpacingNegativeFraction = 0.12
        var headPlateauEndT = 0.08
        var headZeroT = 0.75
        // Symmetric +/-4.5 degrees is an initial design assumption only.
        var tiltPositiveRadians = Double.pi / 40
        var tiltNegativeRadians = Double.pi / 40
        var tiltPivotT = 0.65
        var tiltPivotVerticalOffsetFraction = 0.0
        var peakPositiveFraction = 0.065
        var peakNegativeFraction = 0.045
        var peakStartT = 0.15
        var peakPositionT = 0.68
        var peakEndT = 1.08

        fileprivate var isValid: Bool {
            let amplitudes = [verticalPositiveFraction, verticalNegativeFraction,
                thicknessUpperPositive, thicknessUpperNegative, thicknessLowerPositive, thicknessLowerNegative,
                lengthPositiveFraction, lengthNegativeFraction, spacingPositiveFraction, spacingNegativeFraction,
                headSpacingPositiveFraction, headSpacingNegativeFraction, tiltPositiveRadians, tiltNegativeRadians,
                peakPositiveFraction, peakNegativeFraction]
            let positions = [thicknessBlendWidthFraction, lengthAnchorT, lengthPlateauT, spacingTailRatio,
                headPlateauEndT, headZeroT, tiltPivotT, tiltPivotVerticalOffsetFraction,
                peakStartT, peakPositionT, peakEndT]
            guard amplitudes.allSatisfy({ $0.isFinite && $0 >= 0 }), positions.allSatisfy(\.isFinite),
                  tiltPositiveRadians <= .pi, tiltNegativeRadians <= .pi,
                  thicknessBlendWidthFraction > 0,
                  lengthAnchorT >= 0, lengthAnchorT < lengthPlateauT, lengthPlateauT <= 1,
                  spacingTailRatio >= 0, spacingTailRatio < 1,
                  headPlateauEndT >= 0, headPlateauEndT < headZeroT, headZeroT < 1,
                  tiltPivotT >= 0, tiltPivotT <= 1,
                  peakStartT < peakPositionT, peakPositionT < peakEndT else { return false }
            switch (lengthTailDecayStartT, lengthTailZeroT) {
            case (nil, nil): return true
            case let (start?, end?): return start.isFinite && end.isFinite && start >= lengthPlateauT && start < end
            default: return false
            }
        }
    }

    let geometry: Geometry
    let values: [Double]
    let supports: [Support]
    let calibration: Calibration
    let ownerBoundary: Double
    let ownerTransition: Double
    let maximumGradient: Double
    let maximumDisplacement: Double
    /// Bounds for each currently supplied signed strength, including the face
    /// basis and floating-point margin. Inactive components have exact zero
    /// bounds. Their sums are exactly the two global bounds above.
    let componentMaximumGradients: [Double]
    let componentMaximumDisplacements: [Double]
    /// Bounds in ||W Q^T v||_2, W=diag(1,2). Q is the orthonormal
    /// face frame whose horizontal axis follows `geometry.horizontal`.
    /// The two spacing controls use their rank-one horizontal Jacobian;
    /// other controls use the conservative cond(W)*Euclidean bound.
    let componentWeightedMaximumGradients: [Double]
    var maximumWeightedGradient: Double { componentWeightedMaximumGradients.reduce(0, +) }
    var inverseContraction: Double { min(maximumGradient, maximumWeightedGradient) }
    private let bounds: (minR: Double, maxR: Double, minY: Double, maxY: Double)

    init?(geometry: Geometry, values: [Double], supports: [Support], calibration: Calibration = .init(),
          ownerBoundary: Double, ownerTransition: Double) {
        let g = geometry
        guard [g.origin.x, g.origin.y, g.horizontal.x, g.horizontal.y, g.vertical.x, g.vertical.y,
               g.length, ownerBoundary, ownerTransition].allSatisfy(\.isFinite),
              g.length > 0,
              abs(hypot(g.horizontal.x, g.horizontal.y) - 1) <= 1e-6,
              abs(hypot(g.vertical.x, g.vertical.y) - 1) <= 1e-6,
              abs(g.horizontal.x * g.vertical.x + g.horizontal.y * g.vertical.y) <= 1e-6,
              values.count == 7, values.allSatisfy({ $0.isFinite && abs($0) <= 1 }),
              supports.count == 7, supports.allSatisfy({ support in
                  [support.upper, support.lower, support.head, support.tail].allSatisfy { $0.isFinite && $0 > 0 }
              }), calibration.isValid, ownerTransition > 0,
              ownerBoundary + ownerTransition <= 0 else { return nil }
        if values[6] != 0, calibration.peakEndT > 1 + supports[6].tail / g.length { return nil }

        // Account conservatively for the small accepted floating-point error
        // in the caller's orthonormal face basis, in both coordinate transforms.
        let horizontalSquared = g.horizontal.x * g.horizontal.x + g.horizontal.y * g.horizontal.y
        let verticalSquared = g.vertical.x * g.vertical.x + g.vertical.y * g.vertical.y
        let basisDot = abs(g.horizontal.x * g.vertical.x + g.horizontal.y * g.vertical.y)
        let basisNorm = sqrt(max(horizontalSquared + basisDot, verticalSquared + basisDot))

        var minR = 0.0, maxR = g.length, minY = Double.infinity, maxY = -Double.infinity
        var componentGradients = [Double](repeating: 0, count: 7)
        var componentDisplacements = [Double](repeating: 0, count: 7)
        var componentWeightedGradients = [Double](repeating: 0, count: 7)
        for i in values.indices where values[i] != 0 {
            let support = supports[i], rRange = (-support.head)...(g.length + support.tail)
            let ridge = g.ridge.bounds(in: rRange), upper = g.upper.bounds(in: rRange), lower = g.lower.bounds(in: rRange)
            guard upper.minimum > 0, lower.minimum > 0,
                  [ridge.minimum, ridge.maximum, upper.maximum, lower.maximum].allSatisfy(\.isFinite) else { return nil }
            let y0 = ridge.minimum - upper.maximum - support.upper
            let y1 = ridge.maximum + lower.maximum + support.lower
            minR = min(minR, rRange.lowerBound); maxR = max(maxR, rRange.upperBound)
            minY = min(minY, y0); maxY = max(maxY, y1)

            // The upper/lower transition strips cannot overlap because both
            // core thicknesses are positive. Head/tail strips are disjoint too.
            let ridgeSlope = g.ridge.maximumAbsoluteDerivative
            let upperGradient = 1.5 * hypot(ridgeSlope + g.upper.maximumAbsoluteDerivative, 1) / support.upper
            let lowerGradient = 1.5 * hypot(ridgeSlope + g.lower.maximumAbsoluteDerivative, 1) / support.lower
            let endGradient = 1.5 / min(support.head, support.tail)
            let ownerGradient = rRange.lowerBound < ownerBoundary + ownerTransition ? 1.5 / ownerTransition : 0
            let envelopeGradient = max(upperGradient, lowerGradient) + endGradient + ownerGradient
            let raw = values[i], c = calibration
            func amplitude(_ positive: Double, _ negative: Double) -> Double { g.length * abs(raw) * (raw >= 0 ? positive : negative) }
            let baseMaximum: Double, baseGradient: Double
            var completeGradient: Double?
            switch i {
            case 0:
                baseMaximum = amplitude(c.verticalPositiveFraction, c.verticalNegativeFraction); baseGradient = 0
            case 1:
                let ku = raw * (raw >= 0 ? c.thicknessUpperPositive : c.thicknessUpperNegative)
                let kd = raw * (raw >= 0 ? c.thicknessLowerPositive : c.thicknessLowerNegative)
                let k = max(abs(ku), abs(kd))
                baseMaximum = k * max(upper.maximum + support.upper, lower.maximum + support.lower)
                // k' exists only where |d|<epsilon: |d*k'| <= .75*|kd-ku|.
                baseGradient = (k + 0.75 * abs(kd - ku)) * hypot(ridgeSlope, 1)
                let epsilon = c.thicknessBlendWidthFraction * g.length
                if upper.minimum >= epsilon, lower.minimum >= epsilon {
                    completeGradient = Self.thicknessGradientBound(geometry: g, support: support, calibration: c,
                        upperK: ku, lowerK: kd, ownerBoundary: ownerBoundary, ownerTransition: ownerTransition)
                }
            case 2:
                baseMaximum = amplitude(c.lengthPositiveFraction, c.lengthNegativeFraction)
                var derivative = 1.5 / ((c.lengthPlateauT - c.lengthAnchorT) * g.length)
                if let start = c.lengthTailDecayStartT, let end = c.lengthTailZeroT {
                    derivative = max(derivative, 1.5 / ((end - start) * g.length))
                }
                baseGradient = baseMaximum * derivative
            case 3:
                baseMaximum = amplitude(c.spacingPositiveFraction, c.spacingNegativeFraction)
                baseGradient = baseMaximum * (1 - c.spacingTailRatio) * 1.5 / g.length
            case 4:
                baseMaximum = amplitude(c.headSpacingPositiveFraction, c.headSpacingNegativeFraction)
                baseGradient = baseMaximum * 1.5 / ((c.headZeroT - c.headPlateauEndT) * g.length)
            case 5:
                let angle = abs(raw) * (raw >= 0 ? c.tiltPositiveRadians : c.tiltNegativeRadians)
                // ||R(theta)-I|| = 2|sin(theta/2)| <= |theta|.
                // The angle bound is deliberately linear in raw strength, so
                // rebuilding with uniformly scaled values also scales these
                // admission bounds. The displacement itself remains exact R.
                let rotationNormBound = angle
                let pivotR = c.tiltPivotT * g.length
                let pivotY = g.ridge.value(at: pivotR) + c.tiltPivotVerticalOffsetFraction * g.length
                let radius = hypot(max(abs(rRange.lowerBound - pivotR), abs(rRange.upperBound - pivotR)),
                                   max(abs(y0 - pivotY), abs(y1 - pivotY)))
                baseMaximum = rotationNormBound * radius; baseGradient = rotationNormBound
                completeGradient = angle * Self.tiltGradientBound(geometry: g, support: support,
                    calibration: c, ownerBoundary: ownerBoundary, ownerTransition: ownerTransition)
            default:
                baseMaximum = amplitude(c.peakPositiveFraction, c.peakNegativeFraction)
                baseGradient = baseMaximum * 1.5 / (g.length * min(c.peakPositionT - c.peakStartT, c.peakEndT - c.peakPositionT))
            }
            if i != 1, i != 5 {
                let scalarBounds = Self.scalarGradientBounds(index: i, geometry: g, support: support,
                    calibration: c, ownerBoundary: ownerBoundary, ownerTransition: ownerTransition)
                completeGradient = baseMaximum * scalarBounds.euclidean
                if i == 3 || i == 4 { componentWeightedGradients[i] = baseMaximum * scalarBounds.weighted }
            }
            // Product rule and triangle inequality bound the complete analytic
            // field, including ridge, core, support and owner derivatives.
            componentDisplacements[i] = baseMaximum
            componentGradients[i] = completeGradient ?? (baseGradient + baseMaximum * envelopeGradient)
        }
        if minY == .infinity {
            let ridge = g.ridge.bounds(in: 0...g.length)
            let upper = g.upper.bounds(in: 0...g.length), lower = g.lower.bounds(in: 0...g.length)
            guard upper.minimum > 0, lower.minimum > 0 else { return nil }
            minY = ridge.minimum - upper.maximum; maxY = ridge.maximum + lower.maximum
        }
        let boundedGradients = componentGradients.map { value in
            value == 0 ? 0 : value * basisNorm * basisNorm * (1 + 64 * Double.ulpOfOne)
        }
        let boundedDisplacements = componentDisplacements.map { value in
            value == 0 ? 0 : value * basisNorm * (1 + 64 * Double.ulpOfOne)
        }
        let boundedWeightedGradients = componentWeightedGradients.indices.map { index -> Double in
            if index == 3 || index == 4 {
                let value = componentWeightedGradients[index]
                return value == 0 ? 0 : value * (1 + 64 * Double.ulpOfOne)
            }
            return 2 * boundedGradients[index]
        }
        let boundedGradient = boundedGradients.reduce(0, +)
        let boundedDisplacement = boundedDisplacements.reduce(0, +)
        let boundedWeightedGradient = boundedWeightedGradients.reduce(0, +)
        guard [minR, maxR, minY, maxY, boundedGradient, boundedDisplacement,
               boundedWeightedGradient].allSatisfy(\.isFinite) else { return nil }
        self.geometry = geometry; self.values = values; self.supports = supports; self.calibration = calibration
        self.ownerBoundary = ownerBoundary; self.ownerTransition = ownerTransition
        maximumGradient = boundedGradient
        maximumDisplacement = boundedDisplacement
        componentMaximumGradients = boundedGradients
        componentMaximumDisplacements = boundedDisplacements
        componentWeightedMaximumGradients = boundedWeightedGradients
        bounds = (minR, maxR, minY, maxY)
    }

    func localBounds() -> (minR: Double, maxR: Double, minY: Double, maxY: Double) { bounds }

    /// Scale raw strengths before forming finite rotations. Scaling a completed
    /// displacement would destroy the rigid core of the tilt component.
    func scaled(by scale: Double) -> Self? {
        guard scale.isFinite, scale >= 0, scale <= 1 else { return nil }
        return Self(geometry: geometry, values: values.map { $0 * scale }, supports: supports,
                    calibration: calibration, ownerBoundary: ownerBoundary, ownerTransition: ownerTransition)
    }

    func displacement(at imagePoint: SIMD2<Double>) -> SIMD2<Double> {
        let q = geometry.local(imagePoint), r = q.x, y = q.y
        guard r >= bounds.minR, r <= bounds.maxR, y >= bounds.minY, y <= bounds.maxY else { return .zero }
        let length = geometry.length, t = r / length, c = calibration
        let d = y - geometry.ridge.value(at: r)
        let upper = geometry.upper.value(at: r), lower = geometry.lower.value(at: r)
        let owner = Self.smooth((r - ownerBoundary) / ownerTransition)
        guard owner > 0 else { return .zero }
        var result = SIMD2<Double>.zero
        for index in values.indices where values[index] != 0 {
            let support = supports[index]
            guard r > -support.head, r < length + support.tail else { continue }
            let envelope = Self.smooth((d + upper + support.upper) / support.upper) *
                (1 - Self.smooth((d - lower) / support.lower)) *
                Self.smooth((r + support.head) / support.head) *
                (1 - Self.smooth((r - length) / support.tail)) * owner
            guard envelope > 0 else { continue }
            let raw = values[index]
            func amount(_ positive: Double, _ negative: Double) -> Double { raw * length * (raw >= 0 ? positive : negative) }
            let local: SIMD2<Double>
            switch index {
            case 0: // Preserve the existing SDK raw convention: positive is down.
                local = SIMD2(0, amount(c.verticalPositiveFraction, c.verticalNegativeFraction))
            case 1:
                let upperK = raw * (raw >= 0 ? c.thicknessUpperPositive : c.thicknessUpperNegative)
                let lowerK = raw * (raw >= 0 ? c.thicknessLowerPositive : c.thicknessLowerNegative)
                let epsilon = c.thicknessBlendWidthFraction * length
                let blend = Self.smooth((d + epsilon) / (2 * epsilon))
                local = SIMD2(0, ((1 - blend) * upperK + blend * lowerK) * d)
            case 2:
                var profile = Self.smooth((t - c.lengthAnchorT) / (c.lengthPlateauT - c.lengthAnchorT))
                if let start = c.lengthTailDecayStartT, let end = c.lengthTailZeroT {
                    profile *= 1 - Self.smooth((t - start) / (end - start))
                }
                local = SIMD2(amount(c.lengthPositiveFraction, c.lengthNegativeFraction) * profile, 0)
            case 3:
                let profile = 1 - (1 - c.spacingTailRatio) * Self.smooth(t)
                local = SIMD2(amount(c.spacingPositiveFraction, c.spacingNegativeFraction) * profile, 0)
            case 4:
                let profile = 1 - Self.smooth((t - c.headPlateauEndT) / (c.headZeroT - c.headPlateauEndT))
                local = SIMD2(amount(c.headSpacingPositiveFraction, c.headSpacingNegativeFraction) * profile, 0)
            case 5: // Positive raw raises the tail on both image sides.
                let angle = -raw * (raw >= 0 ? c.tiltPositiveRadians : c.tiltNegativeRadians)
                let pivotR = c.tiltPivotT * length
                let pivotY = geometry.ridge.value(at: pivotR) + c.tiltPivotVerticalOffsetFraction * length
                let a = r - pivotR, b = y - pivotY
                local = SIMD2(a * (cos(angle) - 1) - b * sin(angle), a * sin(angle) + b * (cos(angle) - 1))
            default:
                let bump: Double
                if t <= c.peakStartT || t >= c.peakEndT { bump = 0 }
                else if t < c.peakPositionT { bump = Self.smooth((t - c.peakStartT) / (c.peakPositionT - c.peakStartT)) }
                else { bump = 1 - Self.smooth((t - c.peakPositionT) / (c.peakEndT - c.peakPositionT)) }
                local = SIMD2(0, -amount(c.peakPositiveFraction, c.peakNegativeFraction) * bump)
            }
            // Explicit simultaneous source-space composition. Individual tilt
            // is rigid on the core; combined controls are not sequential affine
            // composition and still require their own image-effect review.
            result += (geometry.outward * local.x + geometry.vertical * local.y) * envelope
        }
        return result
    }

    private static func smooth(_ value: Double) -> Double {
        let x = min(1, max(0, value))
        return x * x * (3 - 2 * x)
    }

    /// A polynomial on one finite r interval in Bernstein form. The convex
    /// hull of its coefficients bounds every value on that interval. The
    /// derivative has coefficients n*(b[i+1]-b[i])/intervalLength. Subdivision
    /// tightens this analytic enclosure; it never treats sample maxima as bounds.
    private struct Bernstein {
        var coefficients: [Double]
        /// Independent product-rule enclosure, in physical r units. This
        /// avoids dividing coefficient rounding error by a nearly zero cell.
        var derivativeUpperBound = 0.0
        var maximum: Double {
            guard coefficients.allSatisfy(\.isFinite) else { return .infinity }
            let value = coefficients.max() ?? 0
            if value == 0 { return 0 }
            return min(1, max(0, value + 128 * Double.ulpOfOne))
        }
        func derivativeMagnitude(span: Double) -> Double {
            guard coefficients.allSatisfy(\.isFinite), span.isFinite, span > 0,
                  !derivativeUpperBound.isNaN, derivativeUpperBound >= 0 else { return .infinity }
            let degree = coefficients.count - 1
            guard degree > 0 else { return 0 }
            var result = 0.0
            for i in 0..<degree { result = max(result, abs(coefficients[i + 1] - coefficients[i])) }
            let coefficientMagnitude = coefficients.map { abs($0) }.max() ?? 0
            let margin = 128 * Double.ulpOfOne * coefficientMagnitude
            let differenceBound = Double(degree) * (result + margin) / span
            // Both enclosures cover the whole interval. Keep the original
            // Bernstein rounding allowance and cap it by the independent
            // physical-ramp derivative bound, never by a sample maximum.
            return min(differenceBound, derivativeUpperBound)
        }
        func multiplied(by other: Bernstein) -> Bernstein {
            if coefficients == [0] || other.coefficients == [0] { return Bernstein(coefficients: [0]) }
            let m = coefficients.count - 1, n = other.coefficients.count - 1
            var product = [Double](repeating: 0, count: m + n + 1)
            for k in product.indices {
                for i in max(0, k - n)...min(m, k) {
                    let weight = Self.binomial(m, i) * Self.binomial(n, k - i) / Self.binomial(m + n, k)
                    product[k] += coefficients[i] * other.coefficients[k - i] * weight
                }
            }
            let productDerivative = derivativeUpperBound * other.maximum + maximum * other.derivativeUpperBound
            return Bernstein(coefficients: product,
                             derivativeUpperBound: productDerivative * (1 + 128 * Double.ulpOfOne))
        }
        private static func binomial(_ n: Int, _ k: Int) -> Double {
            if k == 0 || k == n { return 1 }
            var result = 1.0
            let count = min(k, n - k)
            for i in 1...count { result *= Double(n - count + i) / Double(i) }
            return result
        }
    }

    private static func ramp(start: Double, end: Double, ascending: Bool,
                             range: ClosedRange<Double>) -> Bernstein {
        let width = end - start
        guard start.isFinite, end.isFinite, width.isFinite, width > 0 else { return Bernstein(coefficients: [.infinity]) }
        if range.upperBound <= start { return Bernstein(coefficients: [ascending ? 0 : 1]) }
        if range.lowerBound >= end { return Bernstein(coefficients: [ascending ? 1 : 0]) }
        let a = min(1, max(0, (range.lowerBound - start) / width))
        let b = min(1, max(0, (range.upperBound - start) / width))
        let first = smooth(a), last = smooth(b), span = b - a
        let firstSlope = 6 * a * (1 - a), lastSlope = 6 * b * (1 - b)
        var coefficients = [first, first + span * firstSlope / 3, last - span * lastSlope / 3, last]
        if !ascending { coefficients = coefficients.map { 1 - $0 } }
        let slope = a <= 0.5 && b >= 0.5 ? 1.5 : max(firstSlope, lastSlope)
        // The absolute rounding allowance is divided by the REAL ramp width,
        // not this query cell's width. Even a one-ULP query remains well scaled.
        let derivative = (slope + 128 * Double.ulpOfOne) / width
        return Bernstein(coefficients: coefficients,
                         derivativeUpperBound: derivative * (1 + 128 * Double.ulpOfOne))
    }

    private static func longitudinal(index: Int, length: Double, support: Support, calibration c: Calibration,
                                     ownerBoundary: Double, ownerTransition: Double,
                                     range: ClosedRange<Double>) -> Bernstein {
        var result = ramp(start: -support.head, end: 0, ascending: true, range: range)
        result = result.multiplied(by: ramp(start: length, end: length + support.tail, ascending: false, range: range))
        result = result.multiplied(by: ramp(start: ownerBoundary, end: ownerBoundary + ownerTransition,
                                            ascending: true, range: range))
        switch index {
        case 2:
            result = result.multiplied(by: ramp(start: c.lengthAnchorT * length, end: c.lengthPlateauT * length,
                                                ascending: true, range: range))
            if let start = c.lengthTailDecayStartT, let end = c.lengthTailZeroT {
                result = result.multiplied(by: ramp(start: start * length, end: end * length,
                                                    ascending: false, range: range))
            }
        case 3:
            var profile = ramp(start: 0, end: length, ascending: false, range: range)
            profile.coefficients = profile.coefficients.map { c.spacingTailRatio + (1 - c.spacingTailRatio) * $0 }
            profile.derivativeUpperBound *= (1 - c.spacingTailRatio) * (1 + 128 * Double.ulpOfOne)
            result = result.multiplied(by: profile)
        case 4:
            result = result.multiplied(by: ramp(start: c.headPlateauEndT * length, end: c.headZeroT * length,
                                                ascending: false, range: range))
        case 6:
            result = result.multiplied(by: ramp(start: c.peakStartT * length, end: c.peakPositionT * length,
                                                ascending: true, range: range))
            result = result.multiplied(by: ramp(start: c.peakPositionT * length, end: c.peakEndT * length,
                                                ascending: false, range: range))
        default: break
        }
        return result
    }

    private static func longitudinalCells(index: Int, geometry g: Geometry, support: Support, calibration c: Calibration,
                                          ownerBoundary: Double, ownerTransition: Double) -> [ClosedRange<Double>] {
        let lower = -support.head, upper = g.length + support.tail, length = g.length
        var points = [lower, 0, length, upper, ownerBoundary, ownerBoundary + ownerTransition]
        points += g.ridge.samples.map(\.x) + g.upper.samples.map(\.x) + g.lower.samples.map(\.x)
        switch index {
        case 2:
            points += [c.lengthAnchorT * length, c.lengthPlateauT * length]
            if let start = c.lengthTailDecayStartT, let end = c.lengthTailZeroT { points += [start * length, end * length] }
        case 3: break
        case 4: points += [c.headPlateauEndT * length, c.headZeroT * length]
        case 6: points += [c.peakStartT * length, c.peakPositionT * length, c.peakEndT * length]
        default: break
        }
        points = points.filter { $0.isFinite && $0 >= lower && $0 <= upper }.sorted()
        var unique = [Double]()
        for point in points where point != unique.last { unique.append(point) }
        var cells = [ClosedRange<Double>]()
        for i in 0..<(unique.count - 1) {
            for step in 0..<8 {
                let a = unique[i] + (unique[i + 1] - unique[i]) * Double(step) / 8
                let b = unique[i] + (unique[i + 1] - unique[i]) * Double(step + 1) / 8
                if b > a { cells.append(a...b) }
            }
        }
        return cells
    }

    private static func verticalCrossBounds(geometry g: Geometry, range: ClosedRange<Double>) -> (upper: Double, lower: Double) {
        let c = g.ridge.derivativeBounds(in: range), u = g.upper.derivativeBounds(in: range)
        let d = g.lower.derivativeBounds(in: range)
        let upper = max(abs(u.minimum - c.maximum), abs(u.maximum - c.minimum))
        let lower = max(abs(-c.maximum - d.maximum), abs(-c.minimum - d.minimum))
        return (upper, lower)
    }

    private static func scalarGradientBounds(index: Int, geometry g: Geometry, support: Support, calibration: Calibration,
                                             ownerBoundary: Double, ownerTransition: Double)
        -> (euclidean: Double, weighted: Double) {
        var result = 0.0, weightedResult = 0.0
        let h = g.outward, v = g.vertical
        let horizontalSquared = h.x * h.x + h.y * h.y
        let axisDot = abs(h.x * v.x + h.y * v.y)
        let axisDeterminant = abs(h.x * v.y - h.y * v.x)
        for range in longitudinalCells(index: index, geometry: g, support: support, calibration: calibration,
                                        ownerBoundary: ownerBoundary, ownerTransition: ownerTransition) {
            let h = longitudinal(index: index, length: g.length, support: support, calibration: calibration,
                                 ownerBoundary: ownerBoundary, ownerTransition: ownerTransition, range: range)
            let value = h.maximum, derivative = h.derivativeMagnitude(span: range.upperBound - range.lowerBound)
            guard value.isFinite, derivative.isFinite else { return (.infinity, .infinity) }
            if value == 0, derivative == 0 { continue }
            let cross = verticalCrossBounds(geometry: g, range: range)
            let vr = max(1.5 * cross.upper / support.upper, 1.5 * cross.lower / support.lower)
            let vy = 1.5 / min(support.upper, support.lower)
            let rDerivative = derivative + value * vr
            let yDerivative = value * vy
            let bound = hypot(rDerivative, yDerivative)
            guard bound.isFinite else { return (.infinity, .infinity) }
            result = max(result, bound)
            if index == 3 || index == 4 {
                // In the EXACT orthonormal frame Qx=h/|h|, Qy perpendicular
                // to h, D=h*u has Jacobian row
                // [|h|^2*u_r+(h.v)*u_y, det(h,v)*u_y]. Its second row is
                // zero. W J W^-1 divides that second column by two. This
                // includes accepted nonorthogonality/axis-length error directly
                // instead of incorrectly treating an approximate face basis as Q.
                let weightedR = horizontalSquared * rDerivative + axisDot * yDerivative
                let weightedY = axisDeterminant * yDerivative / 2
                let weightedBound = hypot(weightedR, weightedY)
                guard weightedBound.isFinite else { return (.infinity, .infinity) }
                weightedResult = max(weightedResult, weightedBound)
            }
        }
        let margin = 1 + 256 * Double.ulpOfOne
        return (result * margin, weightedResult * margin)
    }

    private static func tiltGradientBound(geometry g: Geometry, support: Support, calibration c: Calibration,
                                          ownerBoundary: Double, ownerTransition: Double) -> Double {
        let pivotR = c.tiltPivotT * g.length
        let pivotY = g.ridge.value(at: pivotR) + c.tiltPivotVerticalOffsetFraction * g.length
        func radius(_ range: ClosedRange<Double>, _ minY: Double, _ maxY: Double) -> Double {
            let x = max(abs(range.lowerBound - pivotR), abs(range.upperBound - pivotR))
            return hypot(x, max(abs(minY - pivotY), abs(maxY - pivotY)))
        }
        var result = 0.0
        for range in longitudinalCells(index: 5, geometry: g, support: support, calibration: c,
                                        ownerBoundary: ownerBoundary, ownerTransition: ownerTransition) {
            let h = longitudinal(index: 5, length: g.length, support: support, calibration: c,
                                 ownerBoundary: ownerBoundary, ownerTransition: ownerTransition, range: range)
            let value = h.maximum, derivative = h.derivativeMagnitude(span: range.upperBound - range.lowerBound)
            guard value.isFinite, derivative.isFinite else { return .infinity }
            if value == 0, derivative == 0 { continue }
            let ridge = g.ridge.bounds(in: range), upper = g.upper.bounds(in: range), lower = g.lower.bounds(in: range)
            let cross = verticalCrossBounds(geometry: g, range: range)
            let coreRadius = radius(range, ridge.minimum - upper.maximum, ridge.maximum + lower.maximum)
            let coreBound = value + coreRadius * derivative
            guard coreBound.isFinite else { return .infinity }
            result = max(result, coreBound)
            // Separate both transition strips into finite z intervals. Radius,
            // S and S' are enclosed over the ENTIRE strip cell, not at its grid
            // center. ||m(R-I)+delta*grad(m)|| <= |theta|*(m+rho*|grad(m)|).
            for step in 0..<8 {
                let z0 = Double(step) / 8, z1 = Double(step + 1) / 8
                let slope = z0 <= 0.5 && z1 >= 0.5 ? 1.5 : max(6 * z0 * (1 - z0), 6 * z1 * (1 - z1))
                let upperV = smooth(z1), lowerV = 1 - smooth(z0)
                let upperRadius = radius(range, ridge.minimum - upper.maximum + support.upper * (z0 - 1),
                                         ridge.maximum - upper.minimum + support.upper * (z1 - 1))
                let lowerRadius = radius(range, ridge.minimum + lower.minimum + support.lower * z0,
                                         ridge.maximum + lower.maximum + support.lower * z1)
                let upperR = derivative * upperV + value * slope * cross.upper / support.upper
                let lowerR = derivative * lowerV + value * slope * cross.lower / support.lower
                let upperY = value * slope / support.upper, lowerY = value * slope / support.lower
                let upperBound = value * upperV + upperRadius * hypot(upperR, upperY)
                let lowerBound = value * lowerV + lowerRadius * hypot(lowerR, lowerY)
                guard upperBound.isFinite, lowerBound.isFinite else { return .infinity }
                result = max(result, upperBound, lowerBound)
            }
        }
        return result * (1 + 256 * Double.ulpOfOne)
    }

    private static func thicknessGradientBound(geometry g: Geometry, support: Support, calibration c: Calibration,
                                               upperK ku: Double, lowerK kd: Double,
                                               ownerBoundary: Double, ownerTransition: Double) -> Double? {
        var result = 0.0
        for range in longitudinalCells(index: 1, geometry: g, support: support, calibration: c,
                                        ownerBoundary: ownerBoundary, ownerTransition: ownerTransition) {
            let h = longitudinal(index: 1, length: g.length, support: support, calibration: c,
                                 ownerBoundary: ownerBoundary, ownerTransition: ownerTransition, range: range)
            let value = h.maximum, derivative = h.derivativeMagnitude(span: range.upperBound - range.lowerBound)
            guard value.isFinite, derivative.isFinite else { return nil }
            if value == 0, derivative == 0 { continue }
            let upper = g.upper.bounds(in: range), lower = g.lower.bounds(in: range)
            guard let ut = thicknessTransitionBounds(minimumRatio: upper.minimum / support.upper,
                                                     maximumRatio: upper.maximum / support.upper),
                  let dt = thicknessTransitionBounds(minimumRatio: lower.minimum / support.lower,
                                                     maximumRatio: lower.maximum / support.lower) else { return nil }
            let cd = g.ridge.derivativeBounds(in: range), ud = g.upper.derivativeBounds(in: range)
            let dd = g.lower.derivativeBounds(in: range)
            let ridgeSlope = max(abs(cd.minimum), abs(cd.maximum))
            let upperSlope = max(abs(ud.minimum), abs(ud.maximum))
            let lowerSlope = max(abs(dd.minimum), abs(dd.maximum))
            let coreY = max(abs(ku), abs(kd)) + 0.75 * abs(kd - ku)
            let upperY = abs(ku) * ut.derivative, lowerY = abs(kd) * dt.derivative
            let verticalY = max(coreY, upperY, lowerY)
            let upperR = ridgeSlope * upperY + abs(ku) * upperSlope * ut.slopeMoment
            let lowerR = ridgeSlope * lowerY + abs(kd) * lowerSlope * dt.slopeMoment
            let verticalR = max(ridgeSlope * coreY, upperR, lowerR)
            let verticalMagnitude = max(abs(ku) * support.upper * ut.magnitude,
                                        abs(kd) * support.lower * dt.magnitude)
            let rDerivative = value * verticalR + derivative * verticalMagnitude
            let bound = hypot(rDerivative, value * verticalY)
            guard bound.isFinite else { return nil }
            result = max(result, bound)
        }
        return result * (1 + 256 * Double.ulpOfOne)
    }

    /// Exact one-dimensional extrema for a thickness transition, with small
    /// floating-point margins. In the upper strip put a=h_upper/R_upper and
    /// z=(d+h_upper+R_upper)/R_upper. Then d/R=z-1-a and:
    ///   d/dy[d*S(z)] = Q(z,a) = S(z)-(1+a-z)*S'(z).
    /// The lower strip is identical after replacing z by 1-z. |Q| is convex
    /// in a, so its maximum over the thickness interval is at an endpoint.
    /// The other two nonnegative quantities increase with a; only its maximum
    /// is needed. Every extremum below is an endpoint or an analytic quadratic
    /// stationary root; no sampled gradient is used as an admission bound.
    private static func thicknessTransitionBounds(minimumRatio: Double, maximumRatio: Double)
        -> (derivative: Double, slopeMoment: Double, magnitude: Double)? {
        guard minimumRatio.isFinite, maximumRatio.isFinite,
              minimumRatio >= 0, maximumRatio >= minimumRatio,
              maximumRatio <= Double.greatestFiniteMagnitude / 64 else { return nil }
        var derivative = 0.0
        for a in [minimumRatio, maximumRatio] {
            let positions = [0.0, 1.0] + quadraticRoots(-24, 30 + 12 * a, -6 * (1 + a))
                .filter { $0 > 0 && $0 < 1 }
            for z in positions {
                let slope = 6 * z * (1 - z)
                derivative = max(derivative, abs(smooth(z) - (1 + a - z) * slope))
            }
        }
        let a = maximumRatio
        // T=(1+a-z)*S'(z) multiplies the core-thickness r derivative.
        let momentPositions = [0.0, 1.0] + quadraticRoots(18, -12 * (2 + a), 6 * (1 + a))
            .filter { $0 > 0 && $0 < 1 }
        let slopeMoment: Double = momentPositions.map { (z: Double) -> Double in
            let slope = 6.0 * z * (1.0 - z)
            return (1.0 + a - z) * slope
        }.max() ?? 0
        // M=(1+a-z)*S(z) bounds |d*m_vertical|/R. Its derivative is
        // -Q; the nonzero stationary roots solve the quadratic Q/z=0.
        let magnitudePositions = [0.0, 1.0] + quadraticRoots(-8, 15 + 6 * a, -6 * (1 + a))
            .filter { $0 > 0 && $0 < 1 }
        let magnitude: Double = magnitudePositions.map { (z: Double) -> Double in
            (1.0 + a - z) * smooth(z)
        }.max() ?? 0
        let margin = 128 * Double.ulpOfOne * max(1, 1 + a)
        let result = (derivative + margin, slopeMoment + margin, magnitude + margin)
        guard [result.0, result.1, result.2].allSatisfy(\.isFinite) else { return nil }
        return result
    }

    private static func quadraticRoots(_ a: Double, _ b: Double, _ c: Double) -> [Double] {
        let scale = max(abs(a), abs(b), abs(c))
        guard scale.isFinite, scale > 0 else { return [] }
        let aa = a / scale, bb = b / scale, cc = c / scale
        if aa == 0 { return bb == 0 ? [] : [-cc / bb] }
        let discriminant = bb * bb - 4 * aa * cc
        guard discriminant >= 0 else { return [] }
        let root = sqrt(discriminant)
        let q = -0.5 * (bb + (bb >= 0 ? root : -root))
        return q == 0 ? [-bb / (2 * aa)] : [q / aa, cc / q]
    }
}
