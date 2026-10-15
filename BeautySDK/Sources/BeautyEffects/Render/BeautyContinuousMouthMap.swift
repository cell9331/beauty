import BeautyCore
import Foundation

/// Source-registered, pixel-metric mouth geometry shared by both still-image
/// executors. The local lattice keeps whole-mouth motion independent of the
/// detector's lip sample count and gives the oral opening an exact zero band
/// for thickness and Cupid's-bow work.
struct BeautyContinuousMouthMap {
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] { [
        \.mouthSize, \.mouthWidth, \.smile, \.mouthYPosition,
        \.mouthTilt, \.mouthXPosition, \.lipPeakDefinition, \.lipPlump
    ] }

    static func replacesLegacy(for face: FaceGeometry) -> Bool {
        face.observedOuterLips != nil || face.denseSupport != nil
    }

    /// Whole-mouth fields need actual outer support. Inner support is admitted
    /// independently; a missing opening must not erase valid position/size work.
    static func eligibleFieldMask(face: FaceGeometry) -> UInt8 {
        guard let support = support(face: face) else { return 0 }
        return support.inner == nil ? 63 : 255
    }

    private typealias Point = SIMD2<Double>
    private let xs: [Double]
    private let ys: [Double]
    private let offsets: [Point]
    private let horizontalClip: Double?
    private let analyticHorizontal: AnalyticHorizontal?
    private let composedMaps: [Self]?
    private let composedScale: Double
    private let origin: Point
    private let axisX: Point
    private let axisY: Point
    private let protection: [Box]
    private let rasterBounds: Box
    let width: Int
    let height: Int
    let maximumGradient: Double
    let maximumDisplacement: Double

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths) {
        self.init(width: width, height: height, face: face, strengths: strengths, separatesLocalFields: true)
    }

    private init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths,
                  separatesLocalFields: Bool) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              let support = Self.support(face: face),
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite }) else { return nil }
        let limits: [Float] = [BeautySafetyCaps.mouthSize, BeautySafetyCaps.mouthWidth,
            BeautySafetyCaps.smile, BeautySafetyCaps.mouthYPosition, BeautySafetyCaps.mouthTilt,
            BeautySafetyCaps.mouthXPosition, BeautySafetyCaps.lipPeakDefinition, BeautySafetyCaps.lipPlump]
        var values = zip(Self.keys, limits).map { min(1.0, max(-1.0, Double(strengths[keyPath: $0.0] / $0.1))) }
        if support.inner == nil { values[6] = 0; values[7] = 0 }
        guard values.contains(where: { abs($0) > Double(Float.ulpOfOne) }) else { return nil }
        let w = Double(width), h = Double(height)
        // Position and local tissue controls have independent source-fixed
        // admission. Starting another slider at zero must not introduce its
        // full endpoint into the existing edit's safety budget or change its
        // vertical envelope. Only the actual summed displacement is limited.
        if separatesLocalFields, values[5] != 0,
           values.enumerated().contains(where: { $0.offset != 5 && $0.element != 0 }) {
            var horizontalStrengths = BeautyEffectiveStrengths()
            horizontalStrengths.mouthXPosition = strengths.mouthXPosition
            var otherStrengths = strengths
            otherStrengths.mouthXPosition = 0
            let horizontal = Self(width: width, height: height, face: face,
                strengths: horizontalStrengths, separatesLocalFields: false)
            let other = Self(width: width, height: height, face: face,
                strengths: otherStrengths, separatesLocalFields: true)
            guard let horizontal, let other else {
                guard let surviving = horizontal ?? other else { return nil }
                self = surviving
                return
            }
            // O is the unchanged, already admitted non-X aggregate. The
            // analytic X derivative is not a bilinear cell derivative; use
            // global Lipschitz/norm triangle bounds on the two actual samplers.
            // As either child tends to zero, this extra scale tends to one.
            let pose = Double(face.denseSupport?.geometryScale ?? 1)
            let sourceSpan = (horizontal.xs.last! - horizontal.xs[0]) / 2.5
            let faceSpan = min(Double(face.bounds.width) * w, Double(face.bounds.height) * h)
            let gradient = other.maximumGradient + horizontal.maximumGradient
            let magnitude = other.maximumDisplacement + horizontal.maximumDisplacement
            let scale = min(1, gradient > 0 ? 0.45 * pose / gradient : 1,
                magnitude > 0 ? min(sourceSpan * 0.20, faceSpan * 0.06) * pose / magnitude : 1)
            self.width = width; self.height = height
            self.xs = other.xs; self.ys = other.ys; self.offsets = []
            self.origin = other.origin; self.axisX = other.axisX; self.axisY = other.axisY
            self.protection = other.protection; self.rasterBounds = other.rasterBounds
            self.horizontalClip = nil; self.analyticHorizontal = nil
            self.composedMaps = [other, horizontal]; self.composedScale = scale
            self.maximumGradient = gradient * scale
            self.maximumDisplacement = magnitude * scale
            return
        }
        if separatesLocalFields {
            let affineAndSmile = (0..<5).filter { values[$0] != 0 }
            var groups = affineAndSmile.isEmpty ? [[Int]]() : [affineAndSmile]
            groups += (5..<8).filter { values[$0] != 0 }.map { [$0] }
            if groups.count > 1 {
                var components = [Self]()
                for group in groups {
                    var isolated = BeautyEffectiveStrengths()
                    for index in group { isolated[keyPath: Self.keys[index]] = strengths[keyPath: Self.keys[index]] }
                    if let component = Self(width: width, height: height, face: face, strengths: isolated,
                                            separatesLocalFields: false) {
                        components.append(component)
                    }
                }
                guard let first = components.first else { return nil }
                // Include every component's breakpoints. Subdividing its
                // bilinear cells preserves the admitted fields. A clipped X
                // component retains its actual sampler in the sum below.
                let combinedXs = Array(Set(components.flatMap(\.xs))).sorted()
                let combinedYs = Array(Set(components.flatMap(\.ys))).sorted()
                let retainsComposition = components.contains { $0.horizontalClip != nil }
                var combined = [Point](), otherNodes = [Point](), rawCombinedNodes = [Point]()
                combined.reserveCapacity(combinedXs.count * combinedYs.count)
                for y in combinedYs { for x in combinedXs {
                    let pixel = first.origin + first.axisX * x + first.axisY * y
                    var displacement = Point.zero, other = Point.zero, rawHorizontal = Point.zero
                    for component in components {
                        let value = component.displacement(at: pixel)
                        displacement += value
                        if retainsComposition {
                            if component.horizontalClip != nil {
                                rawHorizontal += component.interpolatedDisplacement(at: pixel, appliesHorizontalClip: false)
                            } else { other += value }
                        }
                    }
                    if retainsComposition {
                        func projected(_ value: Point) -> Point {
                            Point(value.x * first.axisX.x + value.y * first.axisX.y,
                                  value.x * first.axisY.x + value.y * first.axisY.y)
                        }
                        otherNodes.append(projected(other))
                        rawCombinedNodes.append(projected(other + rawHorizontal))
                    }
                    combined.append(Point(displacement.x * first.axisX.x + displacement.y * first.axisX.y,
                                          displacement.x * first.axisY.x + displacement.y * first.axisY.y))
                } }
                // There is one clipped X component. Its actual Jacobian is
                // Jother + t * JrawX, t in [0,1]. On each joint cell these
                // entries are multi-affine in x,y,t; the convex norm is bounded
                // by the two endpoint fields at all cell corners. This retains
                // the original X sampler when another field crosses zero.
                let gradient = retainsComposition
                    ? max(Self.gradient(otherNodes, xs: combinedXs, ys: combinedYs),
                          Self.gradient(rawCombinedNodes, xs: combinedXs, ys: combinedYs))
                    : Self.gradient(combined, xs: combinedXs, ys: combinedYs)
                let magnitude = retainsComposition
                    ? min(components.reduce(0) { $0 + $1.maximumDisplacement },
                          (otherNodes + rawCombinedNodes).map { hypot($0.x, $0.y) }.max() ?? 0)
                    : combined.map { hypot($0.x, $0.y) }.max() ?? 0
                let span = (first.xs.last! - first.xs[0]) / 2.5
                let faceSpan = min(Double(face.bounds.width) * w, Double(face.bounds.height) * h)
                let pose = Double(face.denseSupport?.geometryScale ?? 1)
                // Children already include pose once. Retain that reduced
                // budget for their sum without applying pose again to an
                // otherwise admissible low-strength combination.
                let scale = min(1, gradient > 0 ? 0.45 * pose / gradient : 1,
                                magnitude > 0 ? min(span * 0.20, faceSpan * 0.06) * pose / magnitude : 1)
                self.xs = combinedXs; self.ys = combinedYs
                self.width = width; self.height = height
                self.origin = first.origin; self.axisX = first.axisX; self.axisY = first.axisY
                self.protection = first.protection; self.rasterBounds = first.rasterBounds
                self.offsets = combined.map { $0 * scale }
                self.horizontalClip = nil
                self.analyticHorizontal = nil
                self.composedMaps = retainsComposition ? components : nil
                self.composedScale = scale
                self.maximumGradient = retainsComposition ? gradient * scale
                    : Self.gradient(self.offsets, xs: combinedXs, ys: combinedYs)
                self.maximumDisplacement = retainsComposition ? magnitude * scale
                    : self.offsets.map { hypot($0.x, $0.y) }.max() ?? 0
                return
            }
        }
        func pixel(_ p: SIMD2<Float>) -> Point { Point(Double(p.x) * w, Double(p.y) * h) }
        let outerImage = support.outer.map(pixel)
        guard let left = outerImage.min(by: { $0.x < $1.x }),
              let right = outerImage.max(by: { $0.x < $1.x }) else { return nil }
        let vector = right - left, span = hypot(vector.x, vector.y)
        guard span >= 6 else { return nil }
        let axisX = vector / span, axisY = Point(-axisX.y, axisX.x), origin = (left + right) * 0.5
        func local(_ p: Point) -> Point {
            let q = p - origin
            return Point(q.x * axisX.x + q.y * axisX.y, q.x * axisY.x + q.y * axisY.y)
        }
        func image(_ p: Point) -> Point { origin + axisX * p.x + axisY * p.y }
        let outer = outerImage.map(local), inner = support.inner?.map { local(pixel($0)) }
        let half = span * 0.5, outerTop = outer.map(\.y).min()!, outerBottom = outer.map(\.y).max()!
        guard outerBottom - outerTop >= 1, outerBottom - outerTop < span * 0.9 else { return nil }
        // Full inner-lip envelope, including a half-pixel safety margin. Its
        // edges are exact lattice knots; local shape work cannot move teeth,
        // the mouth opening, or the lip seam through interpolation leakage.
        let seamTop = (inner?.map(\.y).min() ?? 0) - 0.5
        let seamBottom = (inner?.map(\.y).max() ?? 0) + 0.5
        // Thin upper tissue already limits peak amplitude. Shorten only its
        // positive-M exterior transition; retain the same exact protection and
        // source-defined peak target. The gate is fixed for every slider step.
        let maximumUpperTissue = max(0, seamTop - outerTop)
        let positiveTissueThreshold = span * 0.040 / 0.55
        let upperTissueRatio = maximumUpperTissue / positiveTissueThreshold
        let positiveTransition = 0.25 - 0.05 * Self.smooth((1 - upperTissueRatio) / 0.5)
        // Resolve negative fullness and the fixed .02-span X distance toe
        // without changing the physical anchors or their gradient budget.
        let refineHorizontal = values[5] != 0 && values.enumerated().allSatisfy { $0.offset == 5 || $0.element == 0 }
        let gridRefinement = values[7] < 0 || refineHorizontal ? 2 : 1
        var boxes = support.protection.enumerated().map { index, points in
            // The nasal contour can stop at the nostril ridge. Reserve a
            // source-relative margin toward the mouth for the visible base;
            // eyes keep their existing two-pixel envelope.
            Box(points: points.map { local(pixel($0)) }, padding: 2,
                extraBottom: index == 2 ? max(3, span * 0.03) : 0)
        }
        let loX = -span * 1.25, hiX = span * 1.25
        // Keep the transition in the perioral neighborhood, including on a
        // wide raster. A lip-width-sized vertical halo can otherwise move
        // unrelated cheek/chin texture despite protected nasal landmarks.
        let isPureHorizontal = values[5] != 0 && values.enumerated().allSatisfy { $0.offset == 5 || $0.element == 0 }
        let isPureTilt = values[4] != 0 && values.enumerated().allSatisfy { $0.offset == 4 || $0.element == 0 }
        let rigidEnvelope = isPureHorizontal || isPureTilt
        let verticalHalo = span * 0.26, verticalPlateau = rigidEnvelope ? 0 : span * 0.08
        let loY = outerTop - verticalHalo, hiY = outerBottom + verticalHalo
        if isPureHorizontal {
            // Keep each original protected rectangle in its own native frame.
            // No enclosing local hull adds extra zero anchors between L and P.
            let physicalBoxes = support.protection.enumerated().map { index, points in
                Box(points: points.map(pixel), padding: 2,
                    extraBottom: index == 2 ? max(3, span * 0.03) : 0)
            }
            // Native source centres are index + .5. The smallest convex hull
            // of strictly nonzero bilinear coefficient centres is a cell face;
            // exactly centred coordinates have one seed, without an epsilon.
            func nativeSupport(_ coordinate: Double) -> (lower: Double, upper: Double) {
                let position = coordinate - 0.5, first = floor(position)
                let last = position == first ? first : first + 1
                return (first + 0.5, last + 0.5)
            }
            let sourceDomains = [left, right].map { corner -> Box in
                let xSupport = nativeSupport(corner.x), ySupport = nativeSupport(corner.y)
                return Box(points: [Point(xSupport.lower, ySupport.lower),
                    Point(xSupport.upper, ySupport.upper)], padding: 0)
            }
            let faceSpan = min(Double(face.bounds.width) * w, Double(face.bounds.height) * h)
            let pose = Double(face.denseSupport?.geometryScale ?? 1)
            let radius = min(span * 0.20, faceSpan * 0.06)
            guard faceSpan.isFinite, faceSpan > 0, pose.isFinite, pose > 0 else { return nil }
            let budget = 0.45 * (1 - 1e-10)
            let sign = values[5] < 0 ? -1.0 : 1.0
            let lower = Point(loX, loY), upper = Point(hiX, hiY)
            func trajectoryMinimum(_ shift: Double) -> Double {
                var minimum = Double.infinity
                for domain in sourceDomains {
                    // The Minkowski sum with the image-horizontal trajectory is
                    // exactly this rectangle, not a sampled or enlarged hull.
                    let lowerImage = Point(domain.minX + min(0, sign * shift), domain.minY)
                    let upperImage = Point(domain.maxX + max(0, sign * shift), domain.maxY)
                    let swept = Box(points: [lowerImage, upperImage], padding: 0)
                    let imageCorners = [lowerImage, Point(upperImage.x, lowerImage.y),
                        upperImage, Point(lowerImage.x, upperImage.y)]
                    let localCorners = imageCorners.map(local)
                    // Every halo clearance is affine; all extrema are vertices.
                    for point in localCorners {
                        minimum = min(minimum, point.x - loX, hiX - point.x,
                            point.y - loY, hiY - point.y)
                    }
                    for box in boxes {
                        minimum = min(minimum, box.minimumDistance(to: localCorners))
                    }
                    for box in physicalBoxes {
                        minimum = min(minimum, box.distance(to: swept))
                    }
                }
                return max(0, minimum) * budget
            }
            let transitionRatio = 0.02
            var lo = 0.0, hi = min(span * 0.14, radius)
            if trajectoryMinimum(hi) >= (1 + transitionRatio) * hi { lo = hi }
            else {
                for _ in 0..<64 {
                    let trial = (lo + hi) * 0.5
                    if trajectoryMinimum(trial) >= (1 + transitionRatio) * trial { lo = trial }
                    else { hi = trial }
                }
            }
            // One representable step toward the feasible interior, with the
            // same source-fixed inward gradient margin as the lattice version.
            let endpoint = lo.nextDown
            guard endpoint.isFinite, endpoint > 1e-10,
                  trajectoryMinimum(endpoint) >= (1 + transitionRatio) * endpoint else { return nil }
            // Couple complete original tensor-basis profiles by source distance.
            // The fixed radial carrier is not rigid support or T admission.
            let sweeps = sourceDomains.map { domain in
                Box(points: [Point(domain.minX + min(0, sign * endpoint), domain.minY),
                    Point(domain.maxX + max(0, sign * endpoint), domain.maxY)], padding: 0)
            }
            let lambda = trajectoryMinimum(endpoint)
            let widthBudget = 0.45, gamma = widthBudget * (1 - budget)
            let basisRadius = sqrt(2.0)
            let terminalLowerProfile = Self.clippedScalar(max(0, lambda - budget * basisRadius),
                target: endpoint)
            let terminalCeiling = terminalLowerProfile + Self.clippedScalar(endpoint - terminalLowerProfile,
                target: gamma)
            let amount = pose * abs(values[5])
            self.width = width; self.height = height
            self.xs = [loX, hiX]; self.ys = [loY, hiY]; self.offsets = []
            self.origin = origin; self.axisX = axisX; self.axisY = axisY
            self.protection = boxes
            self.rasterBounds = Box(points: [Point(loX, loY), Point(loX, hiY),
                Point(hiX, loY), Point(hiX, hiY)].map(image), padding: 0)
            self.horizontalClip = nil
            self.analyticHorizontal = AnalyticHorizontal(lower: lower, upper: upper,
                budget: budget, endpoint: endpoint, signedAmount: sign * amount,
                physicalProtection: physicalBoxes, sourceSweeps: sweeps,
                sourceClearance: lambda, profileRadius: basisRadius, profileGamma: gamma,
                terminalCeiling: terminalCeiling)
            self.composedMaps = nil; self.composedScale = 1
            self.maximumGradient = budget * amount
            self.maximumDisplacement = endpoint * amount
            return
        }
        func axis(_ lo: Double, _ hi: Double, required: [Double], count: Int) -> [Double] {
            Array(Set((0...count).map { lo + (hi - lo) * Double($0) / Double(count) }
                + required.filter { $0 > lo && $0 < hi })).sorted()
        }
        let xs = axis(loX, hiX, required: boxes.flatMap { [$0.minX, $0.maxX] }
            + [-half, -half * 0.95, -half * 0.5, -half * 0.28, 0, half * 0.28, half * 0.5, half * 0.95, half], count: 96 * gridRefinement)
        let ys = axis(loY, hiY, required: boxes.flatMap { [$0.minY, $0.maxY] }
            + [outerTop, seamTop, 0, seamBottom, outerBottom], count: 72 * gridRefinement)

        func smooth(_ value: Double) -> Double { Self.smooth(value) }
        func band(_ value: Double, plateau: Double, end: Double) -> Double {
            1 - smooth((abs(value) - plateau) / (end - plateau))
        }
        func upperBoundary(_ x: Double) -> Double? { Self.verticalSpan(outer, x: x)?.0 }
        let flatLeft = upperBoundary(-half * 0.5) ?? outerTop
        let flatRight = upperBoundary(half * 0.5) ?? outerTop
        let fullnessAvailabilityKnee = span * 0.02
        let horizontalLimit = min(span * 0.20, min(Double(face.bounds.width) * w, Double(face.bounds.height) * h) * 0.06)

        func field(_ q: Point, _ v: [Double]) -> Point {
            if v[7] < 0, inner != nil {
                // Compress tissue toward the complete fixed oral band. The
                // visible rim may extend beyond the observed outer contour;
                // use that contour to bound amplitude, not to stop the ramp.
                let upper = q.y < seamTop, lower = q.y > seamBottom
                guard upper || lower else { return .zero }
                let depth = upper ? seamTop - q.y : q.y - seamBottom
                let sourceDepthCap = 2 * (upper ? max(0, seamTop - outerTop) : max(0, outerBottom - seamBottom))
                func easedDistance(_ distance: Double) -> Double {
                    distance * distance / (distance + span * 0.02)
                }
                let cornerDistance = max(0, half * 0.95 - abs(q.x))
                let distances = [depth, sourceDepthCap, q.y - loY, hiY - q.y, easedDistance(cornerDistance)]
                    + boxes.map { easedDistance($0.distance(x: q.x, y: q.y)) }
                let minimum = distances.min() ?? 0
                guard minimum > 0 else { return .zero }
                // Smooth minimum never exceeds any source/anchor distance.
                // Eased corners avoid a sharp lattice transition; the final
                // complete field still passes the same gradient admission.
                let cone = minimum / pow(distances.reduce(0) { $0 + pow(minimum / $1, 8) }, 1.0 / 8)
                return Point(0, (upper ? 1 : -1) * cone * -v[7])
            }
            func verticalRamp(_ value: Double) -> Double {
                rigidEnvelope ? Self.softLinear(value) : smooth(value)
            }
            let wholeHorizontalWeight = band(q.x, plateau: half * 1.28, end: span * 1.25)
            let wholeWeight = wholeHorizontalWeight
                * (1 - verticalRamp((outerTop - q.y - verticalPlateau) / (verticalHalo - verticalPlateau)))
                * (1 - verticalRamp((q.y - outerBottom - verticalPlateau) / (verticalHalo - verticalPlateau)))
            // Exact affine inverse inside the mouth plateau. Rotation happens
            // in pixels, so rectangular input cannot stretch a tilted mouth.
            let size = 1 + 0.16 * v[0], wide = 1 + 0.20 * v[1]
            let angle = 0.22 * v[4], cosine = cos(angle), sine = sin(angle)
            let moved = q - Point(span * 0.14 * v[5], span * 0.041 * v[3])
            let inverse = Point((moved.x * cosine + moved.y * sine) / (size * wide),
                                (moved.y * cosine - moved.x * sine) / size)
            var result = q - inverse
            var localFullnessY = 0.0
            // Symmetric corner bending leaves the central lip seam level and
            // carries both edges of the corner together, instead of pulling
            // only a detector sample and stretching its immediate neighbors.
            let corner = smooth((abs(q.x) / half - 0.22) / 0.73)
            let cornerVertical = exp(-pow(q.y / (span * 0.30), 2))
            result.y -= span * 0.044 * v[2] * corner * cornerVertical
            // Smile opens the two corners locally as it bends them. The
            // central seam stays fixed; width remains a whole-mouth scale.
            result.x += span * 0.030 * v[2] * (q.x < 0 ? -1 : 1) * corner * cornerVertical

            if inner != nil, abs(q.x) < half * 0.95,
               let bounds = Self.verticalSpan(outer, x: q.x) {
                let fullnessGain = v[7] >= 0 ? 0.80 : 0.50
                let fullnessCoefficient = 1 - 1 / (1 + fullnessGain * v[7])
                let edgeWeight = 1 - smooth((abs(q.x) / half - 0.65) / 0.30)
                if q.y < seamTop, bounds.0 < seamTop {
                    let thickness = seamTop - bounds.0
                    let depth = seamTop - q.y
                    // Retain a continuous availability ramp as local tissue
                    // approaches the opening, without suppressing thin lips
                    // until four percent of the entire mouth width.
                    let fullnessAvailability = smooth(thickness / fullnessAvailabilityKnee)
                    let exterior = 1 - smooth((bounds.0 - q.y) / (span * 0.22))
                    let thicknessCoefficient = fullnessCoefficient
                    // Cover both source and transformed outer edges: safety
                    // attenuation moves a thinning edge back between them.
                    // Preserve its affine inverse there, then carry the
                    // boundary displacement into the exterior taper without
                    // amplifying availability gradients by distant skin depth.
                    let fullnessDepth = min(depth, max(thickness, thickness / (1 - thicknessCoefficient)))
                    // Both signs taper inside the existing global halo.
                    // Avoid multiplying by a second vertical taper, whose
                    // skin gradient can suppress the entire lip.
                    let fullnessExterior = 1 - Self.softLinear((bounds.0 - q.y) / (span * 0.26))
                    localFullnessY -= fullnessDepth * thicknessCoefficient * edgeWeight * fullnessExterior * fullnessAvailability
                    let peak: Double
                    if v[6] >= 0 {
                        func bell(_ x: Double, _ center: Double, _ reach: Double) -> Double {
                            let t = abs(x - center) / reach
                            return t < 1 ? pow(1 - t * t, 2) : 0
                        }
                        let shape = bell(q.x, -half * 0.28, half * 0.31)
                            + bell(q.x, half * 0.28, half * 0.31)
                            - 0.38 * bell(q.x, 0, half * 0.27)
                        peak = -min(span * 0.040, thickness * 0.55) * v[6] * shape
                    } else {
                        // The negative endpoint relaxes the source Cupid's
                        // bow toward a broad smooth line. It does not create
                        // an inverted M on lips that already lack two peaks.
                        let t = min(1, max(0, (q.x + half * 0.5) / half))
                        let flat = flatLeft + (flatRight - flatLeft) * t
                        let correction = min(thickness * 0.42, max(-thickness * 0.42, flat - bounds.0))
                        peak = correction * -v[6] * band(q.x, plateau: half * 0.36, end: half * 0.72)
                    }
                    // Peak amplitude already shrinks with available tissue.
                    // A second thin-layer weight suppresses a thin source bow
                    // cubically; the seam ramp and shared safety bound remain.
                    if v[6] < 0 {
                        let targetDelta = peak * edgeWeight
                        let endpointDelta = targetDelta / abs(v[6])
                        let targetThickness = max(0.5, thickness - endpointDelta)
                        // Complete the source-defined flattening motion within
                        // the tissue, so an interior visible lip rim follows it.
                        // Fix the ramp from the endpoint for continuous slider
                        // steps. Aim for a .30 vertical slope; thin tissue still
                        // goes through the complete .45 lattice check below.
                        let rampDepth = min(targetThickness, max(1, abs(endpointDelta) * 1.5 / 0.30))
                        let tissueInverse = targetDelta * smooth(depth / rampDepth)
                        let skinDistance = max(0, q.y - loY)
                        let outside = depth > targetThickness
                            ? min(1, skinDistance / max(1, (seamTop - targetThickness) - loY)) : 1
                        result.y += tissueInverse * outside
                    } else {
                        let peakDepthRamp = Self.softLinear(depth / thickness)
                        result.y += peak * peakDepthRamp * edgeWeight * exterior
                    }
                } else if q.y > seamBottom, bounds.1 > seamBottom {
                    let thickness = bounds.1 - seamBottom
                    let fullnessAvailability = smooth(thickness / fullnessAvailabilityKnee)
                    let coefficient = fullnessCoefficient
                    let fullnessDepth = min(q.y - seamBottom, max(thickness, thickness / (1 - coefficient)))
                    let fullnessExterior = 1 - Self.softLinear((q.y - bounds.1) / (span * 0.26))
                    localFullnessY += fullnessDepth * coefficient * edgeWeight * fullnessExterior * fullnessAvailability
                }
            }
            return result * wholeWeight + Point(0, localFullnessY * wholeHorizontalWeight)
        }

        let cap = values.map { $0 == 0 ? 0 : ($0 < 0 ? -1.0 : 1.0) }
        var actual = [Point](), ceiling = [Point](), weights = [Double]()
        actual.reserveCapacity(xs.count * ys.count); ceiling.reserveCapacity(xs.count * ys.count)
        for y in ys { for x in xs {
            var weight = 1.0
            // Negative M has a source-tissue ramp of its own. Reserve the
            // same exact feature boxes, with a shorter C1 exterior feather;
            // the final lattice bound still controls the complete transition.
            let featureFeather = values[6] < 0 ? 0.08 : (values[6] > 0 ? positiveTransition : 0.25)
            for box in boxes {
                if values[7] < 0 || isPureHorizontal {
                    // These fields already include the distance to
                    // each protected box. Do not attenuate it a second time.
                    if box.contains(Point(x, y)) { weight = 0 }
                } else {
                    weight *= smooth(box.distance(x: x, y: y) / (span * featureFeather))
                }
            }
            if x == loX || x == hiX || y == loY || y == hiY { weight = 0 }
            weights.append(weight)
            actual.append(field(Point(x, y), values) * weight)
            ceiling.append(field(Point(x, y), cap) * weight)
        } }
        let gradient = max(Self.gradient(actual, xs: xs, ys: ys), Self.gradient(ceiling, xs: xs, ys: ys))
        let magnitude = (actual + ceiling).map { hypot($0.x, $0.y) }.max() ?? 0
        let pose = Double(face.denseSupport?.geometryScale ?? 1)
        let faceSpan = min(Double(face.bounds.width) * w, Double(face.bounds.height) * h)
        guard gradient.isFinite, magnitude.isFinite, magnitude > 1e-10,
              faceSpan.isFinite, faceSpan > 0, pose.isFinite, pose > 0 else { return nil }
        // The cap-shaped bound stays fixed along one slider half, avoiding a
        // strength-dependent safety plateau or reversal during fine edits.
        let scale = isPureHorizontal ? 1 : min(1, gradient > 0 ? 0.45 / gradient : 1,
                        min(span * 0.20, faceSpan * 0.06) / magnitude) * pose
        var admitted = actual.map { $0 * scale }
        if scale < 1, values[4] != 0,
           values.enumerated().allSatisfy({ $0.offset == 4 || $0.element == 0 }) {
            // Multiplying a rotation displacement by a safety scalar blends
            // its matrix with identity and changes lengths. Reduce the angle
            // itself, then recheck the complete tapered inverse field instead.
            func rotationNodes(_ value: Double) -> [Point] {
                var values = [Double](repeating: 0, count: 8); values[4] = value
                var nodes = [Point](); nodes.reserveCapacity(weights.count)
                for y in ys { for x in xs {
                    nodes.append(field(Point(x, y), values) * weights[nodes.count])
                } }
                return nodes
            }
            var angleScale = scale
            var capNodes = rotationNodes(cap[4] * angleScale)
            for _ in 0..<4 {
                let capGradient = Self.gradient(capNodes, xs: xs, ys: ys)
                let capMagnitude = capNodes.map { hypot($0.x, $0.y) }.max() ?? 0
                let reduction = min(1, capGradient > 0 ? 0.45 / capGradient : 1,
                                    capMagnitude > 0 ? min(span * 0.20, faceSpan * 0.06) / capMagnitude : 1)
                if reduction >= 1 { break }
                angleScale *= reduction * 0.995
                capNodes = rotationNodes(cap[4] * angleScale)
            }
            guard Self.gradient(capNodes, xs: xs, ys: ys) <= 0.450001 else { return nil }
            admitted = rotationNodes(values[4] * angleScale)
        }
        if values[7] < 0 {
            // Keep the continuous source cone and move only the nodes required
            // by the actual discrete turning-gradient bound.
            let radius = min(span * 0.20, faceSpan * 0.06)
            let endpointScale = min(0.45, radius / magnitude)
            let target = ceiling.map { $0 * endpointScale }
            guard let projected = Self.scalarMinorant(target.map { abs($0.y) },
                xs: xs, ys: ys, budget: 0.45 * (1 - 1e-10)) else { return nil }
            let endpoint = target.indices.map { i in
                Point(0, target[i].y < 0 ? -projected[i] : projected[i])
            }
            let requestedFraction = abs(values[7])
            let responseFraction = requestedFraction / (1 + 0.45 * (1 - requestedFraction))
            let amount = responseFraction * pose
            admitted = endpoint.map { $0 * amount }
            let finalGradient = Self.gradient(admitted, xs: xs, ys: ys)
            let finalMagnitude = admitted.map { hypot($0.x, $0.y) }.max() ?? 0
            guard finalGradient <= 0.45 * pose + 1e-10,
                  finalMagnitude <= radius * pose + 1e-8 else { return nil }
        }
        self.xs = xs; self.ys = ys; self.width = width; self.height = height
        self.origin = origin; self.axisX = axisX; self.axisY = axisY
        self.protection = boxes
        self.offsets = admitted
        self.horizontalClip = nil
        self.analyticHorizontal = nil
        self.composedMaps = nil; self.composedScale = 1
        self.maximumGradient = Self.gradient(admitted, xs: xs, ys: ys)
        self.maximumDisplacement = admitted.map { hypot($0.x, $0.y) }.max() ?? 0
        self.rasterBounds = Box(points: [Point(loX, loY), Point(loX, hiY), Point(hiX, loY), Point(hiX, hiY)].map(image), padding: 0)
    }

    /// Inverse-map displacement at an image pixel center; request-local only.
    func displacement(at pixel: SIMD2<Double>) -> SIMD2<Double> {
        if let composedMaps {
            return composedMaps.reduce(Point.zero) { $0 + $1.displacement(at: pixel) } * composedScale
        }
        if let analyticHorizontal {
            let d = pixel - origin
            let q = Point(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
            let lower = analyticHorizontal.lower, upper = analyticHorizontal.upper
            guard q.x > lower.x, q.x < upper.x, q.y > lower.y, q.y < upper.y else { return .zero }
            var distance = min(q.x - lower.x, upper.x - q.x, q.y - lower.y, upper.y - q.y)
            for box in protection { distance = min(distance, box.distance(x: q.x, y: q.y)) }
            // Use the actual incoming image pixel, preserving exact physical-box
            // zero even at boundaries without a local/image round trip.
            for box in analyticHorizontal.physicalProtection {
                distance = min(distance, box.distance(x: pixel.x, y: pixel.y))
            }
            guard distance > 0 else { return .zero }
            let raw = analyticHorizontal.budget * distance
            let target = analyticHorizontal.endpoint, epsilon = target * 0.02
            var scalar: Double
            if raw <= target - epsilon { scalar = raw }
            else if raw >= target + epsilon { scalar = target }
            else { scalar = target - pow(target + epsilon - raw, 2) / (4 * epsilon) }
            // Apply the fixed source-basis radial envelope after original g0.
            // It preserves the original H platform, zero set and global cap.
            let r = analyticHorizontal.sourceSweeps.map {
                $0.distance(x: pixel.x, y: pixel.y)
            }.min()!
            let innerRadius = min(r, analyticHorizontal.profileRadius)
            let lowerProfile = Self.clippedScalar(max(0, analyticHorizontal.sourceClearance
                - analyticHorizontal.budget * innerRadius), target: target)
            let ceiling = lowerProfile + Self.clippedScalar(target - lowerProfile,
                target: analyticHorizontal.profileGamma)
            let z = analyticHorizontal.budget * max(0, r - analyticHorizontal.profileRadius)
            scalar = min(scalar, ceiling + z * z / (z + target * 0.02))
            // Replace only the inner terminal jet, retaining its original lower corridor.
            // At and beyond R the complete original radial result remains unchanged.
            if r < analyticHorizontal.profileRadius {
                let inwardZ = analyticHorizontal.budget * (analyticHorizontal.profileRadius - r)
                let terminalProfile = analyticHorizontal.terminalCeiling
                    + inwardZ * inwardZ / (inwardZ + target * 0.02)
                scalar = max(lowerProfile, min(scalar, terminalProfile))
            }
            // Return upright image X directly, eliminating an avoidable
            // local-to-image round trip and retaining exactly zero Y.
            return Point(scalar * analyticHorizontal.signedAmount, 0)
        }
        return interpolatedDisplacement(at: pixel, appliesHorizontalClip: true)
    }

    private func interpolatedDisplacement(at pixel: Point, appliesHorizontalClip: Bool) -> Point {
        let d = pixel - origin
        let q = Point(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        guard q.x > xs[0], q.x < xs.last!, q.y > ys[0], q.y < ys.last!,
              !protection.contains(where: { $0.contains(q) }) else { return .zero }
        let col = Self.cell(q.x, axis: xs), row = Self.cell(q.y, axis: ys)
        let fx = (q.x - xs[col]) / (xs[col + 1] - xs[col])
        let fy = (q.y - ys[row]) / (ys[row + 1] - ys[row]), i = row * xs.count + col
        let top = offsets[i] * (1 - fx) + offsets[i + 1] * fx
        let bottom = offsets[i + xs.count] * (1 - fx) + offsets[i + xs.count + 1] * fx
        var value = top * (1 - fy) + bottom * fy
        if appliesHorizontalClip, let target = horizontalClip {
            let magnitude = hypot(value.x, value.y), epsilon = target * 0.02
            if magnitude > target - epsilon {
                let clipped = magnitude >= target + epsilon ? target
                    : target - pow(target + epsilon - magnitude, 2) / (4 * epsilon)
                value *= clipped / magnitude
            }
        }
        return axisX * value.x + axisY * value.y
    }

    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        guard source.count == width * height * 4 else { return source }
        var output = source
        for y in max(0, Int(floor(rasterBounds.minY)))..<min(height, Int(ceil(rasterBounds.maxY))) {
            for x in max(0, Int(floor(rasterBounds.minX)))..<min(width, Int(ceil(rasterBounds.maxX))) {
                let delta = displacement(at: Point(Double(x) + 0.5, Double(y) + 0.5))
                guard abs(delta.x) + abs(delta.y) > 1e-10 else { continue }
                let sx = min(Double(width - 1), max(0, Double(x) - delta.x))
                let sy = min(Double(height - 1), max(0, Double(y) - delta.y))
                let x0 = Int(floor(sx)), y0 = Int(floor(sy)), x1 = min(x0 + 1, width - 1), y1 = min(y0 + 1, height - 1)
                let indices = [(y0 * width + x0) * 4, (y0 * width + x1) * 4,
                               (y1 * width + x0) * 4, (y1 * width + x1) * 4]
                let dst = (y * width + x) * 4, alpha = source[dst + 3]
                guard indices.allSatisfy({ source[$0 + 3] == alpha }) else { continue }
                let ax = sx - Double(x0), ay = sy - Double(y0)
                for channel in 0..<3 {
                    let a = Double(source[indices[0] + channel]), b = Double(source[indices[1] + channel])
                    let c = Double(source[indices[2] + channel]), d = Double(source[indices[3] + channel])
                    let value = (a + (b - a) * ax) * (1 - ay) + (c + (d - c) * ax) * ay
                    output[dst + channel] = UInt8(min(255, max(0, Int(value.rounded()))))
                }
            }
        }
        return output
    }

    private struct Support {
        let outer: [SIMD2<Float>]
        let inner: [SIMD2<Float>]?
        let protection: [[SIMD2<Float>]]
    }

    private static func support(face: FaceGeometry) -> Support? {
        guard face.freshness == .fresh,
              face.bounds.x.isFinite, face.bounds.y.isFinite,
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.bounds.minX >= 0, face.bounds.minY >= 0,
              face.bounds.maxX <= 1, face.bounds.maxY <= 1,
              let observed = face.observedOuterLips, let outer = contour(observed),
              let left = contour(face.leftEyeSupport?.contour ?? face.leftEye),
              let right = contour(face.rightEyeSupport?.contour ?? face.rightEye) else { return nil }
        if let dense = face.denseSupport {
            guard dense.geometryScale.isFinite, dense.geometryScale > 0 else { return nil }
        }
        let nosePoints = face.observedNoseSupport.map {
            ($0.crest + $0.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        } ?? face.nose
        guard (3...64).contains(nosePoints.count), nosePoints.allSatisfy(valid), Set(nosePoints).count >= 3,
              outer.allSatisfy({ $0.x >= face.bounds.minX && $0.x <= face.bounds.maxX
                  && $0.y >= face.bounds.minY && $0.y <= face.bounds.maxY }) else { return nil }
        let box = Box(points: outer.map { Point(Double($0.x), Double($0.y)) }, padding: 0)
        let span = box.maxX - box.minX, height = box.maxY - box.minY
        guard span > 0.006, span < Double(face.bounds.width) * 0.95,
              height > 0.001, height < Double(face.bounds.height) * 0.5,
              abs(signedArea(outer)) > span * height * 0.15,
              BeautyDenseFaceSupport.simplePolygon(outer) else { return nil }
        var inner: [SIMD2<Float>]?
        if let candidate = face.observedInnerLips, (4...64).contains(candidate.count),
           candidate.allSatisfy(valid), Set(candidate).count >= 3 {
            let bounds = Box(points: candidate.map { Point(Double($0.x), Double($0.y)) }, padding: 0)
            let tolerance = span * 0.025
            if bounds.maxX - bounds.minX >= span * 0.25,
               bounds.minX >= box.minX - tolerance, bounds.maxX <= box.maxX + tolerance,
               bounds.minY >= box.minY - tolerance, bounds.maxY <= box.maxY + tolerance,
               candidate.allSatisfy({ containsOrNearBoundary($0, polygon: outer, tolerance: tolerance) }) {
                inner = candidate
            }
        }
        return Support(outer: outer, inner: inner, protection: [left, right, nosePoints])
    }

    private static func contour(_ input: [SIMD2<Float>]) -> [SIMD2<Float>]? {
        var points = input
        if points.count > 1, points.first == points.last { points.removeLast() }
        guard (4...64).contains(points.count), points.allSatisfy(valid),
              Set(points).count == points.count else { return nil }
        return points
    }

    private static func valid(_ p: SIMD2<Float>) -> Bool {
        p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y)
    }

    private static func signedArea(_ points: [SIMD2<Float>]) -> Double {
        var sum = 0.0
        for i in points.indices {
            let p = points[i], q = points[(i + 1) % points.count]
            sum += Double(p.x) * Double(q.y) - Double(q.x) * Double(p.y)
        }
        return sum * 0.5
    }

    private static func containsOrNearBoundary(_ point: SIMD2<Float>, polygon: [SIMD2<Float>], tolerance: Double) -> Bool {
        let p = Point(Double(point.x), Double(point.y))
        var inside = false
        for i in polygon.indices {
            let first = polygon[i], last = polygon[(i + 1) % polygon.count]
            let a = Point(Double(first.x), Double(first.y)), b = Point(Double(last.x), Double(last.y))
            let v = b - a, length2 = v.x * v.x + v.y * v.y
            if length2 > 0 {
                let t = min(1, max(0, ((p.x - a.x) * v.x + (p.y - a.y) * v.y) / length2))
                let delta = p - (a + v * t)
                if delta.x * delta.x + delta.y * delta.y <= tolerance * tolerance { return true }
            }
            if (a.y > p.y) != (b.y > p.y), p.x < a.x + (b.x - a.x) * (p.y - a.y) / (b.y - a.y) {
                inside.toggle()
            }
        }
        return inside
    }

    private static func verticalSpan(_ points: [Point], x: Double) -> (Double, Double)? {
        var values = [Double]()
        for i in points.indices {
            let a = points[i], b = points[(i + 1) % points.count]
            let delta = b.x - a.x
            if abs(delta) < 1e-10 {
                if abs(x - a.x) < 1e-8 { values.append(a.y); values.append(b.y) }
            } else if x >= min(a.x, b.x), x <= max(a.x, b.x) {
                values.append(a.y + (b.y - a.y) * (x - a.x) / delta)
            }
        }
        guard let lo = values.min(), let hi = values.max() else { return nil }
        return (lo, hi)
    }

    private static func smooth(_ value: Double) -> Double {
        let v = min(1, max(0, value)); return v * v * (3 - 2 * v)
    }

    /// C1 transition with short eased ends and a constant-slope middle. Pure
    /// horizontal translation and tilt need no extra vertical lip plateau;
    /// this uses their existing halo without spending the gradient budget on
    /// a steep cubic midpoint. Every resulting cell is still checked below.
    private static func softLinear(_ value: Double) -> Double {
        let t = min(1, max(0, value)), ease = 0.15
        if t < ease { return t * t / (2 * ease * (1 - ease)) }
        if t > 1 - ease { return 1 - (1 - t) * (1 - t) / (2 * ease * (1 - ease)) }
        return (t - ease * 0.5) / (1 - ease)
    }

    private static func cell(_ value: Double, axis: [Double]) -> Int {
        var lo = 0, hi = axis.count - 1
        while hi - lo > 1 {
            let mid = (lo + hi) / 2
            if value < axis[mid] { hi = mid } else { lo = mid }
        }
        return min(lo, axis.count - 2)
    }

    private static func gradient(_ deltas: [Point], xs: [Double], ys: [Double]) -> Double {
        var result = 0.0
        for row in 0..<(ys.count - 1) { for col in 0..<(xs.count - 1) {
            let i = row * xs.count + col
            let tl = deltas[i], tr = deltas[i + 1], bl = deltas[i + xs.count], br = deltas[i + xs.count + 1]
            let dx = xs[col + 1] - xs[col], dy = ys[row + 1] - ys[row]
            for gx in [(tr - tl) / dx, (br - bl) / dx] {
                for gy in [(bl - tl) / dy, (br - tr) / dy] {
                    result = max(result, sqrt(gx.x * gx.x + gx.y * gx.y + gy.x * gy.x + gy.y * gy.y))
                }
            }
        } }
        return result
    }

    private static func scalarMinorant(_ target: [Double],
                        xs: [Double], ys: [Double], budget: Double)
        -> [Double]? {
        let columns = xs.count, rows = ys.count
        guard columns >= 2, rows >= 2, columns <= Int.max / rows,
              target.count == columns * rows, budget.isFinite, budget > 0,
              target.allSatisfy({ $0.isFinite && $0 >= 0 }),
              xs.allSatisfy(\.isFinite), ys.allSatisfy(\.isFinite),
              zip(xs, xs.dropFirst()).allSatisfy({ $0 < $1 }),
              zip(ys, ys.dropFirst()).allSatisfy({ $0 < $1 }) else { return nil }
        let count = target.count
        var distances = target
        var horizontal = [Double](repeating: .infinity, count: rows * (columns - 1))
        var vertical = [Double](repeating: .infinity, count: (rows - 1) * columns)
        for row in 0..<(rows - 1) { for col in 0..<(columns - 1) {
            let i = row * columns + col, tl = target[i], tr = target[i + 1]
            let bl = target[i + columns], br = target[i + columns + 1]
            let dx = xs[col + 1] - xs[col], dy = ys[row + 1] - ys[row]
            let a = max(abs(tr - tl), abs(br - bl)) / dx
            let b = max(abs(bl - tl), abs(br - tr)) / dy
            guard a.isFinite, b.isFinite else { return nil }
            let g = hypot(a, b), factor = g > budget ? budget / g : 1
            let xLimit = a * factor * dx, yLimit = b * factor * dy
            guard xLimit.isFinite, yLimit.isFinite else { return nil }
            let top = row * (columns - 1) + col, bottom = (row + 1) * (columns - 1) + col
            horizontal[top] = min(horizontal[top], xLimit)
            horizontal[bottom] = min(horizontal[bottom], xLimit)
            vertical[i] = min(vertical[i], yLimit)
            vertical[i + 1] = min(vertical[i + 1], yLimit)
        } }
        // Multi-source Dijkstra: min_j(target[j] + shortest path cost(j,i)).
        // Each source is nonnegative. Zero anchors cannot move. Shared edge
        // limits satisfy both neighboring cell budgets.
        var heap = Array(0..<count), positions = Array(0..<count)
        func precedes(_ a: Int, _ b: Int) -> Bool {
            distances[a] < distances[b] || (distances[a] == distances[b] && a < b)
        }
        func swap(_ a: Int, _ b: Int) {
            heap.swapAt(a, b); positions[heap[a]] = a; positions[heap[b]] = b
        }
        func siftDown(_ start: Int) {
            var parent = start
            while true {
                let left = parent * 2 + 1
                guard left < heap.count else { return }
                var best = left
                if left + 1 < heap.count, precedes(heap[left + 1], heap[left]) { best = left + 1 }
                if !precedes(heap[best], heap[parent]) { return }
                swap(best, parent); parent = best
            }
        }
        func siftUp(_ start: Int) {
            var child = start
            while child > 0 {
                let parent = (child - 1) / 2
                if !precedes(heap[child], heap[parent]) { return }
                swap(child, parent); child = parent
            }
        }
        for i in stride(from: count / 2 - 1, through: 0, by: -1) { siftDown(i) }
        while !heap.isEmpty {
            let node = heap[0], last = heap.removeLast(); positions[node] = -1
            if !heap.isEmpty { heap[0] = last; positions[last] = 0; siftDown(0) }
            let row = node / columns, col = node % columns
            func relax(_ neighbor: Int, _ cost: Double) {
                guard positions[neighbor] >= 0 else { return }
                let candidate = distances[node] + cost
                if candidate < distances[neighbor] {
                    distances[neighbor] = candidate; siftUp(positions[neighbor])
                }
            }
            if col > 0 { relax(node - 1, horizontal[row * (columns - 1) + col - 1]) }
            if col + 1 < columns { relax(node + 1, horizontal[row * (columns - 1) + col]) }
            if row > 0 { relax(node - columns, vertical[(row - 1) * columns + col]) }
            if row + 1 < rows { relax(node + columns, vertical[row * columns + col]) }
        }
        return distances
    }

    private static func clippedScalar(_ raw: Double, target: Double) -> Double {
        let epsilon = target * 0.02
        if raw <= target - epsilon { return raw }
        if raw >= target + epsilon { return target }
        return target - pow(target + epsilon - raw, 2) / (4 * epsilon)
    }

    private struct AnalyticHorizontal {
        let lower: Point, upper: Point
        let budget: Double, endpoint: Double, signedAmount: Double
        let physicalProtection: [Box]
        let sourceSweeps: [Box]
        let sourceClearance: Double, profileRadius: Double, profileGamma: Double
        let terminalCeiling: Double
    }

    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        init(points: [Point], padding: Double, extraBottom: Double = 0) {
            minX = points.map(\.x).min()! - padding; maxX = points.map(\.x).max()! + padding
            minY = points.map(\.y).min()! - padding; maxY = points.map(\.y).max()! + padding + extraBottom
        }
        func contains(_ p: Point) -> Bool { p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY }
        func distance(x: Double, y: Double) -> Double {
            hypot(max(minX - x, 0, x - maxX), max(minY - y, 0, y - maxY))
        }
        /// Exact real-arithmetic segment/AABB minimum. Coordinate-clamp
        /// changes split the squared distance into at most five quadratics.
        func minimumDistance(from source: Point, direction: Point, length: Double) -> Double {
            guard length > 0 else { return distance(x: source.x, y: source.y) }
            var steps = [0.0, length]
            if direction.x != 0 {
                for boundary in [minX, maxX] {
                    let t = (boundary - source.x) / direction.x
                    if t > 0, t < length { steps.append(t) }
                }
            }
            if direction.y != 0 {
                for boundary in [minY, maxY] {
                    let t = (boundary - source.y) / direction.y
                    if t > 0, t < length { steps.append(t) }
                }
            }
            steps = Array(Set(steps)).sorted()
            var result = min(distance(x: source.x, y: source.y),
                distance(x: source.x + direction.x * length, y: source.y + direction.y * length))
            for i in 0..<(steps.count - 1) {
                let lo = steps[i], hi = steps[i + 1]
                let start = source + direction * lo
                let end = source + direction * hi
                result = min(result, distance(x: start.x, y: start.y), distance(x: end.x, y: end.y))
                let middle = source + direction * ((lo + hi) * 0.5)
                var a = Point.zero, b = Point.zero
                if middle.x < minX { a.x = -direction.x; b.x = minX - start.x }
                else if middle.x > maxX { a.x = direction.x; b.x = start.x - maxX }
                if middle.y < minY { a.y = -direction.y; b.y = minY - start.y }
                else if middle.y > maxY { a.y = direction.y; b.y = start.y - maxY }
                let curvature = a.x * a.x + a.y * a.y
                if curvature > 0 {
                    let localT = -(a.x * b.x + a.y * b.y) / curvature
                    if localT > 0, localT < hi - lo {
                        let q = start + direction * localT
                        result = min(result, distance(x: q.x, y: q.y))
                    }
                }
            }
            return result
        }

        /// Exact distance between two closed image-axis rectangles.
        func distance(to other: Box) -> Double {
            hypot(max(minX - other.maxX, 0, other.minX - maxX),
                  max(minY - other.maxY, 0, other.minY - maxY))
        }

        /// Exact real-arithmetic distance from a closed oriented rectangle.
        /// Closed SAT handles overlap/containment; disjoint minima lie on edges.
        func minimumDistance(to rectangle: [Point]) -> Double {
            guard rectangle.count == 4,
                  rectangle.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return 0 }
            let corners = [Point(minX, minY), Point(maxX, minY),
                Point(maxX, maxY), Point(minX, maxY)]
            let firstEdge = rectangle[1] - rectangle[0]
            let secondEdge = rectangle[3] - rectangle[0]
            let axes = [Point(1, 0), Point(0, 1),
                Point(-firstEdge.y, firstEdge.x), Point(-secondEdge.y, secondEdge.x)]
            var separated = false
            for axis in axes {
                let a = rectangle.map { $0.x * axis.x + $0.y * axis.y }
                let b = corners.map { $0.x * axis.x + $0.y * axis.y }
                if a.max()! < b.min()! || b.max()! < a.min()! {
                    separated = true
                    break
                }
            }
            if !separated { return 0 }
            var result = Double.infinity
            for index in 0..<4 {
                let source = rectangle[index]
                let direction = rectangle[(index + 1) % 4] - source
                // Parameter t in [0,1] spans the whole edge; the original
                // crossing/quadratic helper accepts arbitrary directions.
                result = min(result, minimumDistance(from: source, direction: direction, length: 1))
            }
            return result
        }
    }
}

extension BeautyContinuousMouthMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyContinuousMouthMap(width: \(width), height: \(height), nodeCount: \(offsets.count))" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["width": width, "height": height, "nodeCount": offsets.count]) }
}
