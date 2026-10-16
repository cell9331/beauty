import BeautyCore
import BeautyDetection
import Foundation

/// Source-fixed under-jaw tone. This is a bounded photographic hypothesis,
/// not a skin segmenter: absent bilateral skin and a coherent source jaw
/// contrast, the independent intent refuses without changing another effect.
enum BeautyJawlineShadow {
    enum Refusal: String, Sendable {
        case invalidRaster, nonopaqueSource, invalidSupport, unsupportedScope
        case skinEvidenceUnavailable, jawContrastUnavailable, emptyTarget
    }
    struct Qualification {
        let evidence: Evidence?
        let refusal: Refusal?
        let aggregates: [String: Int]
    }
    struct Evidence {
        let aggregates: [String: Int]
        private let width: Int, height: Int, x0: Int, y0: Int, columns: Int
        private let weights: [Float]
        private let sourceDomain: [Bool]

        fileprivate init(width: Int, height: Int, x0: Int, y0: Int, columns: Int,
                         weights: [Float], sourceDomain: [Bool], aggregates: [String: Int]) {
            self.width = width; self.height = height; self.x0 = x0; self.y0 = y0
            self.columns = columns; self.weights = weights; self.sourceDomain = sourceDomain
            self.aggregates = aggregates
        }

        /// Gain-independent source authority, for local safety assertions.
        /// It exposes no raster, coordinates, palette or geometric trace.
        func ownsSourceDomainPixel(x: Int, y: Int) -> Bool {
            guard x >= x0, x < x0 + columns, y >= y0, y < height else { return false }
            let j = (y - y0) * columns + x - x0
            return j < sourceDomain.count && sourceDomain[j]
        }

        func apply(to current: [UInt8], strength: Float) -> [UInt8] {
            guard current.count == width * height * 4, strength.isFinite, strength > 0,
                  stride(from: 3, to: current.count, by: 4).allSatisfy({ current[$0] == 255 }) else { return current }
            let fraction = Double(min(strength, BeautySafetyCaps.jawlineShadow) / BeautySafetyCaps.jawlineShadow)
            var output = current
            for j in weights.indices where weights[j] > 0 {
                let p = ((y0 + j / columns) * width + x0 + j % columns) * 4
                let gain = 1 - 0.18 * fraction * Double(weights[j])
                for channel in 0..<3 {
                    output[p + channel] = UInt8((Double(current[p + channel]) * gain).rounded())
                }
            }
            return output
        }
    }
    private struct Color {
        let r: Double, g: Double, b: Double
        var luma: Double { r * 0.2126 + g * 0.7152 + b * 0.0722 }
        var chroma: SIMD2<Double> { let s = max(1, r + g + b); return SIMD2(r / s, g / s) }
    }
    private struct SourceLightingProfile {
        let phase: Double, center: Double, width: Double
        let netDescent: Double, brightLuma: Double
    }
    private struct Box {
        let lo: SIMD2<Double>, hi: SIMD2<Double>
        func covers(_ p: SIMD2<Double>) -> Bool {
            p.x + 0.5 >= lo.x && p.x - 0.5 <= hi.x && p.y + 0.5 >= lo.y && p.y - 0.5 <= hi.y
        }
    }
    private struct Frame {
        let origin: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>
        let span: Double, chin: Double, curve: [SIMD2<Double>], features: [Box]
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        func boundary(_ x: Double) -> Double? {
            for i in 0..<(curve.count - 1) {
                let a = curve[i], b = curve[i + 1]
                if a.x <= x, x <= b.x, b.x - a.x > 0.001 {
                    let y = a.y + (b.y - a.y) * (x - a.x) / (b.x - a.x)
                    return y >= chin * 0.55 ? y : nil
                }
            }
            return nil
        }
    }

    /// Pointwise colour may coexist. Geometry, texture and future fields
    /// refuse this tone intent rather than moving a source-owned tonal mask.
    static func hasIndependentSourceCoordinates(_ strengths: BeautyEffectiveStrengths) -> Bool {
        var remaining = strengths
        remaining.jawlineShadow = 0
        remaining.skinWhitening = 0; remaining.skinRosy = 0
        remaining.brightness = 0; remaining.contrast = 0; remaining.saturation = 0
        remaining.temperature = 0; remaining.tint = 0; remaining.exposure = 0
        remaining.highlight = 0; remaining.shadow = 0; remaining.filterIntensity = 0
        remaining.lipColor = 0
        return remaining == BeautyEffectiveStrengths()
    }

    static func hasIndependentSourceRequest(_ parameters: BeautyParameters) -> Bool {
        var remaining = parameters.normalized()
        remaining.jawlineShadow = 0
        remaining.skinWhitening = 0; remaining.skinRosy = 0
        remaining.brightness = 0; remaining.contrast = 0; remaining.saturation = 0
        remaining.temperature = 0; remaining.tint = 0; remaining.exposure = 0
        remaining.highlight = 0; remaining.shadow = 0; remaining.filterIntensity = 0
        remaining.filterId = nil; remaining.lipColor = 0
        return remaining == BeautyParameters()
    }

    static func hasGeometrySupport(_ face: FaceGeometry) -> Bool {
        frame(face, width: 1024, height: 1024) != nil
    }

    static func assess(sourceRGBA: [UInt8], width: Int, height: Int, face: FaceGeometry) -> Qualification {
        func refuse(_ reason: Refusal, _ counts: [String: Int] = [:]) -> Qualification {
            Qualification(evidence: nil, refusal: reason, aggregates: counts)
        }
        guard width >= 64, height >= 64,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              sourceRGBA.count == width * height * 4 else { return refuse(.invalidRaster) }
        guard stride(from: 3, to: sourceRGBA.count, by: 4).allSatisfy({ sourceRGBA[$0] == 255 }) else {
            return refuse(.nonopaqueSource)
        }
        guard let f = frame(face, width: width, height: height) else { return refuse(.invalidSupport) }
        func color(_ x: Int, _ y: Int) -> Color {
            let i = (y * width + x) * 4
            return Color(r: Double(sourceRGBA[i]), g: Double(sourceRGBA[i + 1]), b: Double(sourceRGBA[i + 2]))
        }
        func patch(_ q: SIMD2<Double>, radius: Int = 1) -> [Color]? {
            let p = f.image(q), x = Int(floor(p.x)), y = Int(floor(p.y))
            guard x >= radius, y >= radius, x + radius < width, y + radius < height else { return nil }
            var result = [Color]()
            for dy in -radius...radius { for dx in -radius...radius {
                let center = SIMD2(Double(x + dx) + 0.5, Double(y + dy) + 0.5)
                guard !f.features.contains(where: { $0.covers(center) }) else { return nil }
                result.append(color(x + dx, y + dy))
            } }
            return result
        }
        func median(_ a: [Double]) -> Double { a.sorted()[a.count / 2] }
        func middle(_ a: [Color]) -> Color {
            Color(r: median(a.map(\.r)), g: median(a.map(\.g)), b: median(a.map(\.b)))
        }
        // These independent anatomical source families match the existing
        // source-skin corroboration's chroma/MAD limits, without assuming warm RGB.
        let seedRadius = max(1, Int(floor(f.span * 0.012)))
        guard let left = patch(SIMD2(-f.span * 0.25, f.chin * 0.42), radius: seedRadius),
              let right = patch(SIMD2(f.span * 0.25, f.chin * 0.42), radius: seedRadius) else {
            return refuse(.skinEvidenceUnavailable)
        }
        let lm = middle(left), rm = middle(right)
        for (samples, center) in [(left, lm), (right, rm)] {
            guard (24...240).contains(center.luma),
                  median(samples.map { abs($0.luma - center.luma) }) <= 8,
                  median(samples.map { hypot($0.chroma.x - center.chroma.x, $0.chroma.y - center.chroma.y) }) <= 0.012 else {
                return refuse(.skinEvidenceUnavailable)
            }
        }
        guard hypot(lm.chroma.x - rm.chroma.x, lm.chroma.y - rm.chroma.y) <= 0.025,
              max(lm.luma, rm.luma) / max(1, min(lm.luma, rm.luma)) <= 1.35 else {
            return refuse(.skinEvidenceUnavailable)
        }
        let palette = Color(r: (lm.r + rm.r) * 0.5, g: (lm.g + rm.g) * 0.5, b: (lm.b + rm.b) * 0.5)
        func skin(_ c: Color) -> Bool {
            hypot(c.chroma.x - palette.chroma.x, c.chroma.y - palette.chroma.y) <= 0.035 &&
                c.luma >= max(18, palette.luma * 0.58) && c.luma <= min(250, palette.luma * 1.30 + 8)
        }
        // A source-lighting edge is allowed to have moderate luminance
        // variation. Material identity still requires every native RGB sample
        // in the complete 3x3 footprint to match the corroborated palette.
        // A fixed native-pixel range test can confuse a downsampled soft jaw
        // transition with a foreign material; it remains diagnostic below.
        func materialPatch(_ q: SIMD2<Double>) -> Bool {
            guard let samples = patch(q) else { return false }
            return samples.allSatisfy(skin)
        }
        func smooth(_ t: Double) -> Double { let u = min(1, max(0, t)); return u * u * (3 - 2 * u) }
        func normal(_ x: Double) -> SIMD2<Double>? {
            let aperture = f.span * 0.005
            guard let a = f.boundary(x - aperture), let b = f.boundary(x + aperture) else { return nil }
            let slope = (b - a) / (2 * aperture), length = hypot(slope, 1)
            return SIMD2(-slope / length, 1 / length)
        }
        enum ProfileReading { case complete(SourceLightingProfile), incomplete, missingDescent, outsideSearch }
        func sourceLightingProfile(_ base: SIMD2<Double>, normal n: SIMD2<Double>, center: Double) -> ProfileReading {
            var samples = [(phase: Double, luma: Double)]()
            for j in -5...5 {
                let phase = center + Double(j) * f.span * 0.0024
                guard let colors = patch(base + n * phase), colors.allSatisfy(skin) else { return .incomplete }
                samples.append((phase, middle(colors).luma))
            }
            var descent = [Double]()
            for i in 0..<(samples.count - 1) { descent.append(max(0, samples[i].luma - samples[i + 1].luma)) }
            let mass = descent.reduce(0, +)
            guard mass >= 1.5 else { return .missingDescent }
            func quantile(_ fraction: Double) -> (interpolated: Double, upper: Double) {
                let target = mass * fraction
                var cumulative = 0.0
                for i in descent.indices {
                    if descent[i] > 0, cumulative + descent[i] >= target {
                        let t = (target - cumulative) / descent[i]
                        return (samples[i].phase + (samples[i + 1].phase - samples[i].phase) * t, samples[i + 1].phase)
                    }
                    cumulative += descent[i]
                }
                return (samples.last!.phase, samples.last!.phase)
            }
            let light = quantile(0.10), dark = quantile(0.90)
            guard abs(dark.upper) <= f.span * 0.025 else { return .outsideSearch }
            return .complete(SourceLightingProfile(phase: dark.upper, center: center,
                width: max(0, dark.interpolated - light.interpolated),
                netDescent: max(0, samples.first!.luma - samples.last!.luma), brightLuma: samples.first!.luma))
        }
        var splitContextTracks = 0
        enum SourceProfileTopology { case single, competing, incomplete }
        func sourceProfileTopology(_ base: SIMD2<Double>, normal n: SIMD2<Double>,
                                   contrast: Double, anchorPhase: Double) -> SourceProfileTopology {
            // This is read-only competition context, not an edit mask. A
            // foreign sample splits a source component; it cannot erase or
            // bridge evidence in another component. Only the native component
            // containing the already-qualified dark-side anchor owns the ray.
            let tangent = SIMD2(n.y, -n.x)
            let steps = max(1, Int(ceil(f.span * 0.05 / 0.5)))
            let limit = max(1.5, contrast * 0.85)
            var positions = (0...steps).map { -f.span * 0.025 + f.span * 0.05 * Double($0) / Double(steps) }
            positions.append(anchorPhase)
            positions.sort()
            for cross in [-1.0, 0, 1.0] {
                let anchorPoint = f.image(base + n * anchorPhase + tangent * cross)
                let ax = Int(floor(anchorPoint.x)), ay = Int(floor(anchorPoint.y))
                guard ax >= 0, ay >= 0, ax < width, ay < height else { return .incomplete }
                let anchorPixel = ay * width + ax
                var visited = Set<Int>(), samples = [(pixel: Int, luma: Double?)]()
                for phase in positions {
                    let point = f.image(base + n * phase + tangent * cross)
                    let x = Int(floor(point.x)), y = Int(floor(point.y))
                    guard x >= 0, y >= 0, x < width, y < height else {
                        samples.append((-1, nil)); continue
                    }
                    let pixel = y * width + x
                    if !visited.insert(pixel).inserted { continue }
                    let sample = color(x, y)
                    samples.append((pixel, skin(sample) ? sample.luma : nil))
                }
                guard let anchor = samples.firstIndex(where: { $0.pixel == anchorPixel }),
                      samples[anchor].luma != nil else { return .incomplete }
                var lo = anchor, hi = anchor
                while lo > 0 && samples[lo - 1].luma != nil { lo -= 1 }
                while hi + 1 < samples.count && samples[hi + 1].luma != nil { hi += 1 }
                if lo != 0 || hi != samples.count - 1 { splitContextTracks += 1 }
                guard hi - lo + 1 >= 4 else { return .incomplete }
                let values = samples[lo...hi].map { $0.luma! }
                var prefixMaximum = values, suffixMinimum = values
                for i in 1..<values.count { prefixMaximum[i] = max(prefixMaximum[i - 1], values[i]) }
                for i in stride(from: values.count - 2, through: 0, by: -1) {
                    suffixMinimum[i] = min(suffixMinimum[i + 1], values[i])
                }
                for valley in 1..<(values.count - 2) {
                    guard prefixMaximum[valley - 1] - values[valley] >= limit else { continue }
                    for recovered in (valley + 1)..<(values.count - 1) {
                        if values[recovered] - values[valley] >= limit &&
                            values[recovered] - suffixMinimum[recovered + 1] >= limit { return .competing }
                    }
                }
            }
            return .single
        }
        // Register the observed jaw to an actual moderate, same-material
        // light-to-dark transition. Every proposal is read from original RGB;
        // neither an output nor a private annotation participates.
        var rays = [(x: Double, lighting: SourceLightingProfile)]()
        var leftRays = 0, rightRays = 0, competingRays = 0
        var contrastWindowRays = 0, incompleteProfiles = 0, missingDescents = 0, outOfSearchPhases = 0
        var rawCompetingRays = 0, incompleteRawProfiles = 0
        for k in -7...7 {
            let x = Double(k) / 7 * f.span * 0.26
            guard let edge = f.boundary(x), let n = normal(x) else { continue }
            let base = SIMD2(x, edge)
            var proposals = [(phase: Double, contrast: Double)]()
            for j in -10...10 {
                let phase = Double(j) * f.span * 0.0025
                guard let above = patch(base + n * (phase - f.span * 0.012)),
                      let below = patch(base + n * (phase + f.span * 0.012)),
                      above.allSatisfy(skin), below.allSatisfy(skin) else { continue }
                let contrast = middle(above).luma - middle(below).luma
                if contrast >= 1.5 && contrast <= 35 { proposals.append((phase, contrast)) }
            }
            guard let peak = proposals.map(\.contrast).max() else { continue }
            let credible = proposals.filter { $0.contrast >= peak * 0.85 }
            // Separate equally credible source edges cannot establish one jaw.
            var groups = [[(phase: Double, contrast: Double)]]()
            for item in credible {
                if let last = groups.last?.last, item.phase - last.phase <= f.span * 0.003 {
                    groups[groups.count - 1].append(item)
                } else { groups.append([item]) }
            }
            guard groups.count == 1, let group = groups.first else { competingRays += 1; continue }
            contrastWindowRays += 1
            let total = group.reduce(0.0) { $0 + $1.contrast }
            let center = group.reduce(0.0) { $0 + $1.phase * $1.contrast } / total
            // A wide contrast window locates the middle of a source lighting
            // transition, not its editable dark side. Observe the original
            // normal profile and reserve the bright side through 90% of its
            // positive descent. This phase is independent of any output mask.
            let lighting: SourceLightingProfile
            switch sourceLightingProfile(base, normal: n, center: center) {
            case let .complete(value): lighting = value
            case .incomplete: incompleteProfiles += 1; continue
            case .missingDescent: missingDescents += 1; continue
            case .outsideSearch: outOfSearchPhases += 1; continue
            }
            switch sourceProfileTopology(base, normal: n, contrast: peak, anchorPhase: lighting.phase) {
            case .competing: rawCompetingRays += 1; continue
            case .incomplete: incompleteRawProfiles += 1; continue
            case .single: break
            }
            rays.append((x, lighting))
            if k < 0 { leftRays += 1 }; if k > 0 { rightRays += 1 }
        }
        var counts = ["qualifiedSkinFamilies": 2, "contrastRayCount": rays.count,
                      "competingSourceRays": competingRays, "sourceContrastWindowRays": contrastWindowRays,
                      "incompleteDarkProfiles": incompleteProfiles, "missingSourceDescents": missingDescents,
                      "darkPhaseOutsideSearchRays": outOfSearchPhases,
                      "rawCompetingSourceRays": rawCompetingRays, "incompleteRawSourceProfiles": incompleteRawProfiles,
                      "splitRawContextTracks": splitContextTracks]
        guard rays.count >= 9, leftRays >= 3, rightRays >= 3 else { return refuse(.jawContrastUnavailable, counts) }
        // One source phase cannot make a discontinuous jump to a different
        // boundary. Sparse/competing intervals remain unavailable locally.
        func coarseLighting(_ x: Double) -> SourceLightingProfile? {
            guard let first = rays.first, let last = rays.last else { return nil }
            if x <= first.x { return first.lighting }
            if x >= last.x { return last.lighting }
            for i in 0..<(rays.count - 1) {
                let a = rays[i], b = rays[i + 1]
                if a.x <= x && x <= b.x {
                    guard b.x - a.x <= f.span * 0.13,
                          abs(b.lighting.phase - a.lighting.phase) <= f.span * 0.02 else { return nil }
                    let t = smooth((x - a.x) / (b.x - a.x))
                    func mix(_ key: KeyPath<SourceLightingProfile, Double>) -> Double {
                        a.lighting[keyPath: key] + (b.lighting[keyPath: key] - a.lighting[keyPath: key]) * t
                    }
                    return SourceLightingProfile(phase: mix(\.phase), center: mix(\.center), width: mix(\.width),
                        netDescent: mix(\.netDescent), brightLuma: mix(\.brightLuma))
                }
            }
            return nil
        }
        // The fifteen rays establish a global source hypothesis; their
        // interpolated phase alone cannot grant editing authority between
        // rays. Re-read native RGB at bounded subpixel axial intervals, then
        // reserve the upper dark-side envelope of adjacent source columns.
        // Missing or competing material leaves a gap rather than a bridge.
        let axialStep = max(0.5, f.span / 2048)
        let axialStart = -f.span * 0.30 - axialStep * 2
        let axialCount = Int(ceil(f.span * 0.60 / axialStep)) + 5
        var localProfiles = [SourceLightingProfile?](repeating: nil, count: axialCount)
        var localIncomplete = 0, localCompeting = 0
        let coarseSplitTracks = splitContextTracks
        for i in localProfiles.indices {
            let x = axialStart + Double(i) * axialStep
            guard let coarse = coarseLighting(x), let edge = f.boundary(x), let n = normal(x) else { continue }
            let base = SIMD2(x, edge)
            guard case let .complete(local) = sourceLightingProfile(base, normal: n, center: coarse.center) else {
                localIncomplete += 1; continue
            }
            switch sourceProfileTopology(base, normal: n, contrast: max(1.5, local.netDescent), anchorPhase: local.phase) {
            case .competing: localCompeting += 1; continue
            case .incomplete: localIncomplete += 1; continue
            case .single: break
            }
            localProfiles[i] = SourceLightingProfile(phase: max(coarse.phase, local.phase), center: local.center,
                width: local.width, netDescent: local.netDescent, brightLuma: local.brightLuma)
        }
        counts["localSourceProfileColumns"] = localProfiles.compactMap { $0 }.count
        counts["incompleteLocalSourceProfiles"] = localIncomplete
        counts["competingLocalSourceProfiles"] = localCompeting
        counts["splitLocalContextTracks"] = splitContextTracks - coarseSplitTracks
        // Source-only continuous segments own their own fade. No gain is
        // carried across a missing profile, a competing edge or foreign RGB.
        var arcDistances = [Double](repeating: 0, count: axialCount)
        var segmentStart = 0
        while segmentStart < axialCount {
            guard localProfiles[segmentStart] != nil else { segmentStart += 1; continue }
            var end = segmentStart
            while end + 1 < axialCount && localProfiles[end + 1] != nil { end += 1 }
            for i in segmentStart...end {
                arcDistances[i] = Double(max(0, min(i - segmentStart - 1, end - i - 1))) * axialStep
            }
            segmentStart = end + 1
        }
        func sourceGain(_ p: SourceLightingProfile) -> Double {
            // The added peak cannot exceed the observed original contrast.
            // Subpixel-width source steps cannot prove a broad light field.
            min(0.18, p.netDescent / max(1, p.brightLuma)) * smooth(p.width)
        }
        let gains = localProfiles.compactMap { $0 }.map(sourceGain)
        counts["maximumSourceGainPermille"] = Int(((gains.max() ?? 0) * 1000).rounded())
        func registeredLighting(_ x: Double) -> (phase: Double, width: Double, gain: Double, arcFade: Double)? {
            let u = (x - axialStart) / axialStep, i = Int(floor(u))
            guard i >= 1, i + 2 < localProfiles.count,
                  let before = localProfiles[i - 1], let a = localProfiles[i],
                  let b = localProfiles[i + 1], let after = localProfiles[i + 2] else { return nil }
            let upperA = max(before.phase, a.phase, b.phase)
            let upperB = max(a.phase, b.phase, after.phase)
            let t = smooth(u - Double(i))
            let sourceWidthA = max(before.width, a.width, b.width)
            let sourceWidthB = max(a.width, b.width, after.width)
            let sourceWidth = sourceWidthA + (sourceWidthB - sourceWidthA) * t
            let gainA = min(sourceGain(before), sourceGain(a), sourceGain(b))
            let gainB = min(sourceGain(a), sourceGain(b), sourceGain(after))
            let arcDistance = arcDistances[i] + (arcDistances[i + 1] - arcDistances[i]) * t
            return (upperA + (upperB - upperA) * t, sourceWidth, gainA + (gainB - gainA) * t,
                smooth(arcDistance / max(f.span * 0.0125, sourceWidth * 2)))
        }
        func registered(_ q: SIMD2<Double>) -> (distance: Double, geometricOffset: Double, normalWidth: Double,
                                               sourceWidth: Double, gain: Double, arcFade: Double, start: SIMD2<Double>)? {
            guard abs(q.x) < f.span * 0.30, let edge = f.boundary(q.x),
                  let n = normal(q.x), let lighting = registeredLighting(q.x), n.y > 0.5 else { return nil }
            // A parallel normal offset intersects the vertical source column
            // at phase/n.y; signed normal distance retains physical width.
            let y = edge + lighting.phase / n.y
            let normalWidth = min(f.span * 0.05, (edge + f.span * 0.045 - y) * n.y)
            guard normalWidth >= f.span * 0.0125 else { return nil }
            return ((q.y - y) * n.y, q.y - edge, normalWidth, lighting.width, lighting.gain, lighting.arcFade,
                SIMD2(q.x, y - f.span * 0.025 / n.y))
        }
        let minX = -f.span * 0.30, maxX = f.span * 0.30
        let lower = f.curve.filter { $0.x >= minX - f.span * 0.05 && $0.x <= maxX + f.span * 0.05 }
        guard !lower.isEmpty else { return refuse(.emptyTarget, counts) }
        let corners = [f.image(SIMD2(minX, lower.map(\.y).min()! - f.span * 0.04)),
                       f.image(SIMD2(maxX, lower.map(\.y).min()! - f.span * 0.04)),
                       f.image(SIMD2(minX, f.chin + f.span * 0.10)),
                       f.image(SIMD2(maxX, f.chin + f.span * 0.10))]
        let x0 = max(1, Int(floor(corners.map(\.x).min()!)) - 2)
        let y0 = max(1, Int(floor(corners.map(\.y).min()!)) - 2)
        let x1 = min(width - 2, Int(ceil(corners.map(\.x).max()!)) + 2)
        let y1 = min(height - 2, Int(ceil(corners.map(\.y).max()!)) + 2)
        guard x0 < x1, y0 < y1 else { return refuse(.emptyTarget, counts) }
        let columns = x1 - x0 + 1, rows = y1 - y0 + 1
        var weights = [Float](repeating: 0, count: columns * rows)
        var sourceDomain = [Bool](repeating: false, count: weights.count)
        var material = [Bool](repeating: false, count: weights.count)
        var rangeRejected = 0
        for y in y0...y1 { for x in x0...x1 {
            let q = f.local(SIMD2(Double(x) + 0.5, Double(y) + 0.5))
            material[(y - y0) * columns + x - x0] = materialPatch(q)
            if let samples = patch(q) {
                let values = samples.map(\.luma)
                if values.max()! - values.min()! > 18 { rangeRejected += 1 }
            }
        } }
        func connectedMaterial(_ q: SIMD2<Double>) -> Bool {
            let p = f.image(q), x = Int(floor(p.x)), y = Int(floor(p.y))
            guard x >= x0, x <= x1, y >= y0, y <= y1 else { return false }
            return material[(y - y0) * columns + x - x0]
        }
        var domainPixels = 0, footprintRejected = 0, disconnectedPixels = 0
        for y in y0...y1 { for x in x0...x1 {
            let j = (y - y0) * columns + x - x0
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), q = f.local(p)
            guard let r = registered(q), r.distance > 0, r.distance < f.span * 0.05,
                  r.geometricOffset > f.span * 0.005, r.geometricOffset < f.span * 0.045 else { continue }
            domainPixels += 1
            guard material[j] else { continue }
            var completeTexel = true
            for dy in [-0.5, 0.5] { for dx in [-0.5, 0.5] {
                guard let corner = registered(f.local(p + SIMD2(dx, dy))),
                      corner.distance > 0, corner.distance < f.span * 0.05,
                      corner.geometricOffset > f.span * 0.005, corner.geometricOffset < f.span * 0.045 else { completeTexel = false; continue }
            } }
            guard completeTexel else { footprintRejected += 1; continue }
            // Native source samples, rather than an upsampled qualification
            // raster, prove skin continuity all the way from inside the jaw.
            let steps = max(1, Int(ceil(q.y - r.start.y)))
            var connected = true
            for k in 0...steps {
                if !connectedMaterial(SIMD2(q.x, r.start.y + (q.y - r.start.y) * Double(k) / Double(steps))) {
                    connected = false; break
                }
            }
            guard connected else { disconnectedPixels += 1; continue }
            sourceDomain[j] = true
            // Fill the available legal thickness with a broad symmetric C1
            // light field. The observed 10--90 width controls both ramps;
            // a source segment's ends fade independently along the jaw arc.
            let ramp = min(r.normalWidth * 0.5, max(r.sourceWidth, r.normalWidth * 0.25))
            let lighting = smooth(r.distance / ramp) * smooth((r.normalWidth - r.distance) / ramp)
            weights[j] = Float(lighting * r.arcFade * (r.gain / 0.18) * smooth((0.30 - abs(q.x) / f.span) / 0.08))
        } }
        counts["registeredDarkSideRayCount"] = rays.count
        counts["sourceDomainPixels"] = domainPixels
        counts["nativeFootprintRejectedPixels"] = footprintRejected
        counts["disconnectedMaterialPixels"] = disconnectedPixels
        counts["legacyNativeRangeRejectedPixels"] = rangeRejected
        // Source rejection boundaries receive their own compact C1 feather.
        // The rectangle carries a zero ring; no full-canvas float mask is kept.
        var distances = [Int](repeating: Int.max, count: weights.count), queue = [Int]()
        for j in weights.indices where weights[j] == 0 || j % columns == 0 || j % columns == columns - 1 || j < columns || j >= (rows - 1) * columns {
            if j % columns == 0 || j % columns == columns - 1 || j < columns || j >= (rows - 1) * columns { sourceDomain[j] = false }
            weights[j] = 0; distances[j] = 0; queue.append(j)
        }
        var head = 0
        while head < queue.count {
            let j = queue[head]; head += 1
            let x = j % columns, y = j / columns
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, -1), (-1, 1), (1, 1)] {
                let nx = x + dx, ny = y + dy
                guard nx >= 0, ny >= 0, nx < columns, ny < rows else { continue }
                let n = ny * columns + nx
                if distances[n] > distances[j] + 1 { distances[n] = distances[j] + 1; queue.append(n) }
            }
        }
        let feather = max(0.5, f.span * 0.008)
        for j in weights.indices where weights[j] > 0 {
            weights[j] *= Float(smooth(Double(distances[j]) / feather))
        }
        counts["eligibleTargetPixels"] = weights.filter { $0 > 0 }.count
        counts["sourceAuthorityPixels"] = sourceDomain.filter { $0 }.count
        guard counts["eligibleTargetPixels", default: 0] >= 12 else { return refuse(.emptyTarget, counts) }
        let evidence = Evidence(width: width, height: height, x0: x0, y0: y0, columns: columns,
            weights: weights, sourceDomain: sourceDomain, aggregates: counts)
        return Qualification(evidence: evidence, refusal: nil, aggregates: counts)
    }

    private static func frame(_ face: FaceGeometry, width: Int, height: Int) -> Frame? {
        guard face.bounds.minX.isFinite, face.bounds.minY.isFinite,
              face.bounds.maxX.isFinite, face.bounds.maxY.isFinite,
              face.bounds.width > 0, face.bounds.height > 0,
              face.bounds.minX >= 0, face.bounds.minY >= 0, face.bounds.maxX <= 1, face.bounds.maxY <= 1,
              face.freshness == .fresh, let support = face.observedFaceSupport,
              let brows = face.observedEyebrowSupport, let lb = brows.left, let rb = brows.right,
              let nose = face.observedNoseSupport, let lips = face.observedOuterLips,
              (7...32).contains(support.contour.count), face.leftEye.count >= 4, face.rightEye.count >= 4,
              lb.side == .left, rb.side == .right, lb.points.count >= 2, rb.points.count >= 2,
              lips.count >= 4, nose.crest.count >= 3, nose.contour.count >= 3 else { return nil }
        let nasal = (nose.crest + nose.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        var paths = [face.leftEyeSupport?.contour ?? face.leftEye, face.rightEyeSupport?.contour ?? face.rightEye,
                     lb.points, rb.points, lips, nasal]
        if let dense = face.denseSupport {
            paths[2] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.leftBrowEnvelope)
            paths[3] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.rightBrowEnvelope)
            paths[5] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseCrest)
                + BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseContour)
        }
        guard paths[0].count >= 4, paths[1].count >= 4,
              zip(paths, [4, 4, 2, 2, 4, 3]).allSatisfy({ Set($0.0).count >= $0.1 }),
              (support.contour + paths.flatMap { $0 }).allSatisfy({
                  $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
              }), Set(support.contour).count >= 7 else { return nil }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height)) }
        func mean(_ p: [SIMD2<Float>]) -> SIMD2<Double> { p.map(pixel).reduce(.zero, +) / Double(p.count) }
        let left = mean(face.leftEye), right = mean(face.rightEye), delta = right - left
        let distance = hypot(delta.x, delta.y)
        guard distance >= 4 else { return nil }
        let axisX = delta / distance, axisY = SIMD2(-axisX.y, axisX.x), origin = (left + right) * 0.5
        var curve = support.contour.map { p -> SIMD2<Double> in
            let q = pixel(p) - origin
            return SIMD2(q.x * axisX.x + q.y * axisX.y, q.x * axisY.x + q.y * axisY.y)
        }
        if curve[0].x > curve.last!.x { curve.reverse() }
        let span = curve.map(\.x).max()! - curve.map(\.x).min()!, chin = curve.map(\.y).max()!
        guard span >= 32, span > distance * 1.1, span < distance * 4, chin > distance * 0.4,
              zip(curve, curve.dropFirst()).allSatisfy({ $0.1.x >= $0.0.x }),
              curve.first!.y < chin * 0.75, curve.last!.y < chin * 0.75 else { return nil }
        let margins = [0.04, 0.04, 0.04, 0.04, 0.07, 0.008]
        let features = zip(paths, margins).map { path, margin -> Box in
            let p = path.map(pixel), padding = max(2, span * margin)
            return Box(lo: SIMD2(p.map(\.x).min()! - padding, p.map(\.y).min()! - padding),
                       hi: SIMD2(p.map(\.x).max()! + padding, p.map(\.y).max()! + padding))
        }
        return Frame(origin: origin, axisX: axisX, axisY: axisY, span: span, chin: chin, curve: curve, features: features)
    }
}

extension BeautyJawlineShadow.Evidence: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyJawlineShadow.Evidence(aggregates: \(aggregates))" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["aggregates": aggregates]) }
}
