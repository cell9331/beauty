import Foundation
import CryptoKit

// Generated-only prototype. No file/image input, report promotion, Vision,
// renderer, or production metric dispatch is provided by this executable.
enum RootEdgeFailure: Error { case invalidInput, unavailable, ambiguous, identityMismatch }

struct RootEdgePlane {
    let width: Int
    let height: Int
    let values: [Double]
    init(width: Int, height: Int, values: [Double]) throws {
        guard (32...8192).contains(width), (16...8192).contains(height),
              width * height <= 16_777_216, values.count == width * height,
              values.allSatisfy({ $0.isFinite && (0...255).contains($0) && ($0 * 256).rounded() == $0 * 256 })
        else { throw RootEdgeFailure.invalidInput }
        self.width = width; self.height = height; self.values = values
    }
    func sample(_ x: Double, _ y: Int) -> Double {
        let lo = Int(floor(x)), hi = Int(ceil(x)), fraction = x - Double(lo)
        return values[y * width + lo] * (1 - fraction) + values[y * width + hi] * fraction
    }
}

struct RootEdgeRegion {
    let minX: Int, maxX: Int, minY: Int, maxY: Int
}

struct RootEdgeInterval {
    let lo: Double, hi: Double
}

struct RootEdgeAnchor {
    let row: Int, edge: Int, searchLo: Int, searchHi: Int
    let sourceProfile: [Double]
}

struct RootEdgeRegistration {
    let width: Int, height: Int
    let pairs: [(RootEdgeAnchor, RootEdgeAnchor)]
    let sourceDigest: String
    let roi: RootEdgeRegion
    let exclusions: [RootEdgeRegion]
    let commitment: String
}

struct RootWidthInterval {
    let lo: Int64, hi: Int64
}

enum RootStructuralMetricPrototype {
    static let identifier = "rootStructuralEdgeSpanQ16_v2_draft2"
    static let samples = 16
    static let requiredRows = 12
    // Six offsets each way retain plateau evidence across the full two-pixel
    // blur support and three-pixel admissible localization half-span. A short
    // nine-sample window loses that constraint under fractional resampling.
    static let templateRadius = 6
    static let blurRadius = 2
    static let profileRadius = templateRadius + blurRadius + 2
    static let noise = 2.0
    static let minimumContrast = 10.0
    static let step = 1.0 / 16.0

    static func digest(_ words: [UInt64], domain: String) -> String {
        var data = Data(domain.utf8)
        for word in words {
            var canonical = word.bigEndian
            withUnsafeBytes(of: &canonical) { data.append(contentsOf: $0) }
        }
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func commitment(width: Int, height: Int, sourceDigest: String, roi: RootEdgeRegion,
                           exclusions: [RootEdgeRegion], pairs: [(RootEdgeAnchor, RootEdgeAnchor)]) -> String {
        var words = [UInt64(width), UInt64(height), UInt64(exclusions.count), UInt64(pairs.count)]
        for region in [roi] + exclusions {
            words += [UInt64(region.minX), UInt64(region.maxX), UInt64(region.minY), UInt64(region.maxY)]
        }
        for pair in pairs { for anchor in [pair.0, pair.1] {
            words += [UInt64(anchor.row), UInt64(anchor.edge), UInt64(anchor.searchLo), UInt64(anchor.searchHi)]
            words += anchor.sourceProfile.map(\.bitPattern)
        } }
        return digest(words, domain: identifier + ":registration:" + sourceDigest + ":")
    }

    // Fixed finite convex-blur envelope: all nonnegative horizontal kernels
    // supported within +/-2 source pixels (even spatially varying kernels).
    // Candidate noise <=2 and positive affine nuisance gain in [0.5,2].
    // This is an explicit nuisance class, not a claim about arbitrary blur.
    static func anchor(_ source: RootEdgePlane, row: Int, lo: Int, hi: Int) throws -> RootEdgeAnchor {
        let guardBand = profileRadius
        guard hi - lo >= 2 * guardBand + 3 else { throw RootEdgeFailure.unavailable }
        let candidates = (lo + guardBand)..<(hi - guardBand)
        var ranked: [(Int, Double)] = []
        for x in candidates {
            let difference = source.values[row * source.width + x + 1] - source.values[row * source.width + x]
            ranked.append((x, abs(difference)))
        }
        ranked.sort { a, b in a.1 == b.1 ? a.0 < b.0 : a.1 > b.1 }
        guard let best = ranked.first, best.1 > 0 else { throw RootEdgeFailure.unavailable }
        // Ambiguous remote transitions are rejected, never chosen by outputs.
        let competitor = ranked.filter { abs($0.0 - best.0) > guardBand }.map { $0.1 }.max() ?? 0
        guard best.1 > 2 * competitor else { throw RootEdgeFailure.ambiguous }
        let edge = best.0
        let contrast = abs(source.values[row * source.width + edge + 4]
            - source.values[row * source.width + edge - 4])
        guard contrast >= minimumContrast else { throw RootEdgeFailure.unavailable }
        let profile = (-profileRadius...profileRadius).map { source.values[row * source.width + edge + $0] }
        let search = max(8, (source.width + 31) / 32)
        return RootEdgeAnchor(row: row, edge: edge,
            searchLo: max(lo + guardBand, edge - search), searchHi: min(hi - guardBand - 1, edge + search),
            sourceProfile: profile)
    }

    static func compatible(_ anchor: RootEdgeAnchor, _ image: RootEdgePlane, _ position: Double) -> Bool {
        // Forward model: C[k] = gain * convex_s P(k-d+s) + offset + error,
        // |s|<=2, |error|<=2, with P the source piecewise-linear interpolant.
        // Compare INTEGER candidate samples against the source envelope for
        // the entire displacement cell. Never interpolate C a second time.
        var outputLow: [Double] = [], outputHigh: [Double] = []
        var templateLow: [Double] = [], templateHigh: [Double] = []
        let integerPosition = Int(floor(position))
        func profile(_ x: Double) -> Double {
            let shifted = x + Double(profileRadius)
            let lo = Int(floor(shifted)), hi = Int(ceil(shifted)), f = shifted - Double(lo)
            return anchor.sourceProfile[lo] * (1 - f) + anchor.sourceProfile[hi] * f
        }
        for offset in -templateRadius...templateRadius {
            let k = integerPosition + offset
            let value = image.values[anchor.row * image.width + k]
            if value <= 0 || value >= 255 { return false }
            outputLow.append(value - noise); outputHigh.append(value + noise)
            let center = Double(k) - position
            let lo = center - step / 2 - Double(blurRadius)
            let hi = center + step / 2 + Double(blurRadius)
            var extrema = [profile(lo), profile(hi)]
            for knot in Int(ceil(lo))...Int(floor(hi)) { extrema.append(profile(Double(knot))) }
            templateLow.append(extrema.min()!); templateHigh.append(extrema.max()!)
        }
        var gainLo = 0.5, gainHi = 2.0
        // Exact linear-feasibility projection in (gain,offset), not a
        // least-squares winner that could discard a compatible zero shift.
        for i in outputLow.indices { for j in outputLow.indices {
            let coefficient = templateLow[j] - templateHigh[i]
            let bound = outputHigh[j] - outputLow[i]
            if coefficient > 0 { gainHi = min(gainHi, (bound / coefficient).nextUp) }
            else if coefficient < 0 { gainLo = max(gainLo, (bound / coefficient).nextDown) }
            else if bound < 0 { return false }
        } }
        return gainLo <= gainHi
    }

    static func locate(_ anchor: RootEdgeAnchor, _ image: RootEdgePlane) throws -> RootEdgeInterval {
        var accepted: [Int] = []
        for tick in (anchor.searchLo * 16)...(anchor.searchHi * 16) {
            if compatible(anchor, image, Double(tick) / 16) { accepted.append(tick) }
        }
        guard let first = accepted.first, let last = accepted.last else { throw RootEdgeFailure.unavailable }
        // Disconnected solutions and a solution touching the search boundary
        // are ambiguous; no relocalization, best-fit selection or clipping.
        guard first > anchor.searchLo * 16, last < anchor.searchHi * 16,
              zip(accepted, accepted.dropFirst()).allSatisfy({ $1 == $0 + 1 }),
              admittedHull(first: first, last: last) else { throw RootEdgeFailure.ambiguous }
        return .init(lo: (Double(first) / 16 - step / 2).nextDown,
                     hi: (Double(last) / 16 + step / 2).nextUp)
    }

    static func admittedHull(first: Int, last: Int) -> Bool {
        // Internal ticks are nonnegative and bounded by 8192*16; apply the
        // six-pixel limit to the mathematical closed-cell hull, before the
        // representational nextDown/nextUp expansion of its endpoints.
        guard first >= 0, last >= first, last <= 8192 * 16 else { return false }
        return last - first + 1 <= 6 * 16
    }

    static func register(_ source: RootEdgePlane, roi: RootEdgeRegion,
                         exclusions: [RootEdgeRegion] = []) throws -> RootEdgeRegistration {
        guard roi.minX >= 0, roi.minX < roi.maxX, roi.maxX <= source.width,
              roi.minY >= 0, roi.minY < roi.maxY, roi.maxY <= source.height,
              roi.maxX - roi.minX >= 40, roi.maxY - roi.minY >= samples else { throw RootEdgeFailure.invalidInput }
        let split = (roi.minX + roi.maxX) / 2
        guard exclusions.count <= 2, exclusions.allSatisfy({ box in
            box.minX >= 0 && box.maxX <= source.width && box.minY >= 0 && box.maxY <= source.height &&
            box.minX < box.maxX && box.minY < box.maxY
        }) else { throw RootEdgeFailure.invalidInput }
        let orderedExclusions = exclusions.sorted { a, b in
            [a.minY, a.minX, a.maxY, a.maxX].lexicographicallyPrecedes([b.minY, b.minX, b.maxY, b.maxX])
        }
        var pairs: [(RootEdgeAnchor, RootEdgeAnchor)] = []
        var polarity: Bool?
        var previous: (Int, Int)?
        for index in 0..<samples {
            let y = roi.minY + (2 * index + 1) * (roi.maxY - roi.minY) / (2 * samples)
            let left: RootEdgeAnchor, right: RootEdgeAnchor
            do {
                var leftBound = roi.minX, rightBound = roi.maxX
                // Eye exclusions are source-only anatomical measurement
                // registration, NOT new target/protected acceptance rectangles.
                // Their exact extents are explicitly bound in the commitment.
                for box in orderedExclusions where y >= box.minY && y < box.maxY {
                    if box.maxX <= split { leftBound = max(leftBound, box.maxX) }
                    else if box.minX >= split { rightBound = min(rightBound, box.minX) }
                    else { throw RootEdgeFailure.unavailable }
                }
                left = try anchor(source, row: y, lo: leftBound, hi: split)
                right = try anchor(source, row: y, lo: split, hi: rightBound)
            } catch RootEdgeFailure.unavailable { continue }
            let l = source.values[y * source.width + left.edge + 1] - source.values[y * source.width + left.edge]
            let r = source.values[y * source.width + right.edge + 1] - source.values[y * source.width + right.edge]
            guard l * r < 0 else { throw RootEdgeFailure.ambiguous }
            if let polarity, polarity != (l > 0) { throw RootEdgeFailure.ambiguous }
            polarity = l > 0
            if let previous, max(abs(left.edge - previous.0), abs(right.edge - previous.1)) > 4 {
                throw RootEdgeFailure.ambiguous
            }
            _ = try locate(left, source); _ = try locate(right, source)
            pairs.append((left, right)); previous = (left.edge, right.edge)
        }
        guard pairs.count >= requiredRows else { throw RootEdgeFailure.unavailable }
        let sourceDigest = digest([UInt64(source.width), UInt64(source.height)] + source.values.map(\.bitPattern),
                                  domain: identifier + ":source-ieee754be:")
        let binding = commitment(width: source.width, height: source.height, sourceDigest: sourceDigest,
                                 roi: roi, exclusions: orderedExclusions, pairs: pairs)
        return .init(width: source.width, height: source.height, pairs: pairs, sourceDigest: sourceDigest,
                     roi: roi, exclusions: orderedExclusions, commitment: binding)
    }

    static func width(_ image: RootEdgePlane, registration: RootEdgeRegistration,
                      expectedCommitment: String) throws -> RootWidthInterval {
        guard image.width == registration.width, image.height == registration.height,
              registration.sourceDigest.count == 64,
              registration.sourceDigest.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
              (requiredRows...samples).contains(registration.pairs.count),
              registration.roi.minX >= 0, registration.roi.maxX <= image.width,
              registration.roi.minY >= 0, registration.roi.maxY <= image.height,
              registration.roi.minX < registration.roi.maxX, registration.roi.minY < registration.roi.maxY,
              registration.exclusions.count <= 2 else { throw RootEdgeFailure.invalidInput }
        for box in registration.exclusions {
            guard box.minX >= 0, box.minX < box.maxX, box.maxX <= image.width,
                  box.minY >= 0, box.minY < box.maxY, box.maxY <= image.height else { throw RootEdgeFailure.invalidInput }
        }
        var previousRow = -1
        for pair in registration.pairs {
            guard pair.0.row == pair.1.row, pair.0.row > previousRow,
                  pair.0.edge < pair.1.edge else { throw RootEdgeFailure.invalidInput }
            previousRow = pair.0.row
            for a in [pair.0, pair.1] {
                guard a.row >= 0, a.row < image.height, a.searchLo >= templateRadius + 1,
                      a.searchHi < image.width - templateRadius - 1, a.searchLo <= a.edge, a.edge <= a.searchHi,
                      a.sourceProfile.count == profileRadius * 2 + 1
                else { throw RootEdgeFailure.invalidInput }
                for value in a.sourceProfile {
                    guard value.isFinite, value >= 0, value <= 255,
                          (value * 256).rounded() == value * 256 else { throw RootEdgeFailure.invalidInput }
                }
            }
        }
        guard registration.commitment == expectedCommitment,
              commitment(width: registration.width, height: registration.height, sourceDigest: registration.sourceDigest,
                         roi: registration.roi, exclusions: registration.exclusions, pairs: registration.pairs) == expectedCommitment
        else { throw RootEdgeFailure.identityMismatch }
        var lower = 0.0, upper = 0.0
        for (left, right) in registration.pairs {
            let l = try locate(left, image), r = try locate(right, image)
            guard r.lo > l.hi else { throw RootEdgeFailure.ambiguous }
            lower = (lower + (r.lo - l.hi).nextDown).nextDown
            upper = (upper + (r.hi - l.lo).nextUp).nextUp
        }
        let scale = 65_536.0 / Double(image.width * registration.pairs.count)
        return .init(lo: Int64(floor((lower * scale.nextDown).nextDown)),
                     hi: Int64(ceil((upper * scale.nextUp).nextUp)))
    }

    static func margins(source: RootWidthInterval, neutral: RootWidthInterval, candidate: RootWidthInterval,
                        siblings: [RootWidthInterval]) throws -> (signed: Int64, distinct: Int64) {
        guard siblings.count == 3, ([source, neutral, candidate] + siblings).allSatisfy({
            $0.lo >= 0 && $0.lo <= $0.hi && $0.hi <= 65_536
        }) else { throw RootEdgeFailure.invalidInput }
        let signed = min(source.lo - candidate.hi, neutral.lo - candidate.hi)
        let distinct = siblings.map { max(0, $0.lo - candidate.hi, candidate.lo - $0.hi) }.min()!
        return (signed, distinct)
    }
}

var rootEdgePrototypeStage = "initialization"
func rootEdgePrototypeSelfTest() throws -> Int {
    var checks = 0
    func require(_ condition: Bool) throws { guard condition else { throw RootEdgeFailure.invalidInput }; checks += 1 }
    func stripe(half: Double, background: Double = 180, contrast: Double = 40,
                shift: Double = 0, perturb: Bool = false, blur: Bool = false) throws -> RootEdgePlane {
        let w = 512, h = 32
        let row = (0..<w).map { x in abs((Double(x) + 0.5) / Double(w) - 0.5 - shift) < half ? background + contrast : background }
        var values: [Double] = []
        for _ in 0..<h { for x in 0..<w {
            var v = row[x]
            if blur { v = (-2...2).map { row[min(w - 1, max(0, x + $0))] }.reduce(0,+) / 5 }
            if perturb { v += x % 2 == 0 ? 1 : -1 }
            values.append((v * 256).rounded() / 256)
        } }
        return try .init(width: w, height: h, values: values)
    }
    let roi = RootEdgeRegion(minX: 153, maxX: 359, minY: 0, maxY: 32)
    for contrast in [40.0, -40.0, 10.0] {
        rootEdgePrototypeStage = "source_registration_\(Int(contrast))"
        let source = try stripe(half: 0.12, contrast: contrast)
        let registration = try RootStructuralMetricPrototype.register(source, roi: roi)
        let before = try RootStructuralMetricPrototype.width(source, registration: registration, expectedCommitment: registration.commitment)
        rootEdgePrototypeStage = "known_contraction_\(Int(contrast))"
        let narrow = try RootStructuralMetricPrototype.width(stripe(half: 0.10, contrast: contrast), registration: registration, expectedCommitment: registration.commitment)
        try require(before.lo - narrow.hi >= 16)
        for (index, noNarrowing) in [try stripe(half: 0.12, background: 160, contrast: contrast),
                            try stripe(half: 0.12, contrast: contrast, perturb: true),
                            try stripe(half: 0.12, contrast: contrast, blur: true),
                            try stripe(half: 0.12, contrast: contrast, shift: 0.008),
                            try stripe(half: 0.14, contrast: contrast)].enumerated() {
            rootEdgePrototypeStage = "no_contraction_\(Int(contrast))_\(index)"
            if index < 3 {
                try require(registration.pairs.allSatisfy { pair in
                    RootStructuralMetricPrototype.compatible(pair.0, noNarrowing, Double(pair.0.edge)) &&
                    RootStructuralMetricPrototype.compatible(pair.1, noNarrowing, Double(pair.1.edge))
                })
            }
            do {
                let after = try RootStructuralMetricPrototype.width(noNarrowing, registration: registration, expectedCommitment: registration.commitment)
                try require(before.lo - after.hi < 16)
            } catch RootEdgeFailure.ambiguous { checks += 1 }
            catch RootEdgeFailure.unavailable { checks += 1 }
        }
        // The source's own no-movement explanation must be retained.
        for pair in registration.pairs {
            let left = try RootStructuralMetricPrototype.locate(pair.0, source)
            try require(left.lo <= Double(pair.0.edge) && left.hi >= Double(pair.0.edge))
        }
        let repeated = try RootStructuralMetricPrototype.register(source, roi: roi)
        try require(repeated.commitment == registration.commitment)
        do {
            _ = try RootStructuralMetricPrototype.width(source, registration: registration, expectedCommitment: String(repeating: "0", count: 64))
            throw RootEdgeFailure.invalidInput
        } catch RootEdgeFailure.identityMismatch { checks += 1 }
        for gain in [0.5, 2.0] {
            let shifted = try stripe(half: 0.12, background: 140, contrast: contrast * gain)
            try require(registration.pairs.allSatisfy { pair in
                RootStructuralMetricPrototype.compatible(pair.0, shifted, Double(pair.0.edge)) &&
                RootStructuralMetricPrototype.compatible(pair.1, shifted, Double(pair.1.edge))
            })
        }
    }
    for amount: Int64 in [15, 16, 17] {
        let point = RootWidthInterval(lo: 1000, hi: 1000)
        let candidate = RootWidthInterval(lo: 1000 - amount, hi: 1000 - amount)
        let result = try RootStructuralMetricPrototype.margins(source: point, neutral: point, candidate: candidate,
                                                               siblings: [point, point, point])
        try require((result.signed >= 16 && result.distinct >= 16) == (amount >= 16))
        for index in 0..<3 {
            var siblings = [point, point, point]; siblings[index] = candidate
            let copied = try RootStructuralMetricPrototype.margins(source: point, neutral: point, candidate: candidate, siblings: siblings)
            try require(copied.distinct == 0)
        }
        for neutral in [point, candidate] {
            let copied = try RootStructuralMetricPrototype.margins(source: point, neutral: neutral, candidate: neutral,
                                                                   siblings: [point, point, point])
            try require(copied.signed <= 0)
        }
    }
    do {
        _ = try RootStructuralMetricPrototype.register(stripe(half: 0.12, contrast: 0), roi: roi)
        throw RootEdgeFailure.invalidInput
    } catch RootEdgeFailure.unavailable { checks += 1 }
    rootEdgePrototypeStage = "adversarial_source_registration"
    let ordinary = try stripe(half: 0.12)
    let registration = try RootStructuralMetricPrototype.register(ordinary, roi: roi)
    var pairs = registration.pairs
    let old = pairs[0].0
    var changedTemplate = old.sourceProfile; changedTemplate[0] += 1
    pairs[0].0 = .init(row: old.row, edge: old.edge, searchLo: old.searchLo, searchHi: old.searchHi,
                      sourceProfile: changedTemplate)
    let tampered = RootEdgeRegistration(width: registration.width, height: registration.height,
        pairs: pairs, sourceDigest: registration.sourceDigest, roi: registration.roi,
        exclusions: registration.exclusions, commitment: registration.commitment)
    do {
        _ = try RootStructuralMetricPrototype.width(ordinary, registration: tampered, expectedCommitment: registration.commitment)
        throw RootEdgeFailure.invalidInput
    } catch RootEdgeFailure.identityMismatch { checks += 1 }
    var repeatedEdges = ordinary.values
    for y in 0..<ordinary.height { for x in 164..<176 { repeatedEdges[y * ordinary.width + x] = 220 } }
    do {
        _ = try RootStructuralMetricPrototype.register(RootEdgePlane(width: ordinary.width, height: ordinary.height, values: repeatedEdges), roi: roi)
        throw RootEdgeFailure.invalidInput
    } catch RootEdgeFailure.ambiguous { checks += 1 }
    do {
        _ = try RootStructuralMetricPrototype.register(ordinary, roi: roi,
            exclusions: [.init(minX: 0, maxX: 215, minY: 0, maxY: 32)])
        throw RootEdgeFailure.invalidInput
    } catch RootEdgeFailure.unavailable { checks += 1 }
    do {
        _ = try RootStructuralMetricPrototype.register(stripe(half: 0.12, background: 215, contrast: 40), roi: roi)
        throw RootEdgeFailure.invalidInput
    } catch RootEdgeFailure.unavailable { checks += 1 }
    do {
        _ = try RootEdgePlane(width: 512, height: 32, values: Array(repeating: .nan, count: 512 * 32))
        throw RootEdgeFailure.unavailable
    } catch RootEdgeFailure.invalidInput { checks += 1 }
    rootEdgePrototypeStage = "generated_size_and_subpixel_grid"
    func analyticStripe(width: Int, half: Double, phase: Double, contrast: Double) throws -> RootEdgePlane {
        let center = Double(width) / 2 + phase
        var row: [Double] = []
        for x in 0..<width {
            let coverage = max(0, min(Double(x + 1), center + half) - max(Double(x), center - half))
            row.append(((140 + contrast * coverage) * 256).rounded() / 256)
        }
        return try .init(width: width, height: 16, values: Array(repeating: row, count: 16).flatMap { $0 })
    }
    for w in [256, 513, 1024] { for phase in [0.0, 0.25, 0.5, 0.75] { for contrast in [-60.0, 60.0] {
        rootEdgePrototypeStage = "generated_size_\(w)_phase_\(phase)_contrast_\(Int(contrast))_source"
        let half = Double(w) * 0.12
        let source = try analyticStripe(width: w, half: half, phase: phase, contrast: contrast)
        let region = RootEdgeRegion(minX: w * 3 / 10, maxX: (w * 7 + 9) / 10, minY: 0, maxY: 16)
        let registered = try RootStructuralMetricPrototype.register(source, roi: region)
        let before = try RootStructuralMetricPrototype.width(source, registration: registered, expectedCommitment: registered.commitment)
        let truth = 2 * half * 65_536 / Double(w)
        try require(Double(before.lo) <= truth && truth <= Double(before.hi))
        let narrowedHalf = half - Double(max(8, (w + 31) / 32)) / 2
        let rerasterized = try analyticStripe(width: w, half: narrowedHalf, phase: phase, contrast: contrast)
        // Independent area rasterization is a different sampling order from
        // translation of the frozen discrete source. Keep its regression, but
        // require bounds or typed abstention rather than claim equivalence.
        do {
            let measured = try RootStructuralMetricPrototype.width(rerasterized, registration: registered,
                                                                   expectedCommitment: registered.commitment)
            let known = 2 * narrowedHalf * 65_536 / Double(w)
            try require(Double(measured.lo) <= known && known <= Double(measured.hi))
        } catch RootEdgeFailure.ambiguous { checks += 1 }
        catch RootEdgeFailure.unavailable { checks += 1 }
        // Measurable positive: translate the fixed source's left/right
        // piecewise-linear profiles inward before integer quantization.
        let displacement = half - narrowedHalf
        let changedRow = (0..<w).map { x -> Double in
            let p = Double(x) + (x < w / 2 ? -displacement : displacement)
            return (source.sample(min(Double(w - 1), max(0, p)), 0) * 256).rounded() / 256
        }
        let changed = try RootEdgePlane(width: w, height: 16, values: Array(repeating: changedRow, count: 16).flatMap { $0 })
        rootEdgePrototypeStage = "generated_size_\(w)_phase_\(phase)_contrast_\(Int(contrast))_candidate"
        let after = try RootStructuralMetricPrototype.width(changed, registration: registered, expectedCommitment: registered.commitment)
        let changedTruth = 2 * narrowedHalf * 65_536 / Double(w)
        try require(Double(after.lo) <= changedTruth && changedTruth <= Double(after.hi))
        if before.lo - after.hi >= 16 { try require(truth - changedTruth >= 16) }
    } } }
    rootEdgePrototypeStage = "bounded_nuisance_adversaries"
    let baseline = try RootStructuralMetricPrototype.width(ordinary, registration: registration,
                                                           expectedCommitment: registration.commitment)
    // Independent pixel-domain constructions. All kernels are convex, have
    // integer weights / 8 and remain inside the declared +/-2 support.
    // Thus quantization adds no error in these generated 180/220 stripes.
    let kernels = [[0,0,8,0,0], [8,0,0,0,0], [0,0,0,0,8],
                   [1,2,2,2,1], [0,0,2,2,4], [4,2,2,0,0]]
    for (kernelIndex, kernel) in kernels.enumerated() { for noiseKind in 0..<4 {
        rootEdgePrototypeStage = "bounded_nuisance_\(kernelIndex)_\(noiseKind)"
        var pixels: [Double] = []
        for y in 0..<ordinary.height { for x in 0..<ordinary.width {
            var value = 0.0
            for k in 0..<5 {
                let sourceX = min(ordinary.width - 1, max(0, x + k - 2))
                value += ordinary.values[y * ordinary.width + sourceX] * Double(kernel[k]) / 8
            }
            // Full declared noise endpoints: impulses, stripe and spatially
            // correlated perturbations, all with unchanged latent geometry.
            if noiseKind == 1 { value += x % 2 == 0 ? 2 : -2 }
            if noiseKind == 2 && (x == 210 || x == 302) { value += 1 }
            if noiseKind == 3 { value += (x + y) % 7 < 3 ? -2 : 2 }
            pixels.append(value)
        } }
        let image = try RootEdgePlane(width: ordinary.width, height: ordinary.height, values: pixels)
        try require(registration.pairs.allSatisfy { pair in
            RootStructuralMetricPrototype.compatible(pair.0, image, Double(pair.0.edge)) &&
            RootStructuralMetricPrototype.compatible(pair.1, image, Double(pair.1.edge))
        })
        do {
            let measured = try RootStructuralMetricPrototype.width(image, registration: registration,
                                                                   expectedCommitment: registration.commitment)
            try require(baseline.lo - measured.hi < 16)
        } catch RootEdgeFailure.ambiguous { checks += 1 }
        catch RootEdgeFailure.unavailable { checks += 1 }
    } }
    rootEdgePrototypeStage = "pixel_domain_threshold_and_translation"
    for phase in [0.0, 0.25, 0.75] {
        let source = try analyticStripe(width: 513, half: 61.5, phase: phase, contrast: 60)
        let fixed = try RootStructuralMetricPrototype.register(source, roi: .init(minX: 153, maxX: 360, minY: 0, maxY: 16))
        let before = try RootStructuralMetricPrototype.width(source, registration: fixed, expectedCommitment: fixed.commitment)
        for q16 in [0.0, 15, 16, 17] {
            // Independent analytic area coverage, not a synthetic interval
            // passed directly to the predicate. Conservative abstention near
            // threshold is legitimate; rounding must never manufacture a pass.
            let moved = try analyticStripe(width: 513, half: 61.5 - q16 * 513 / 131_072,
                                           phase: phase, contrast: 60)
            do {
                let after = try RootStructuralMetricPrototype.width(moved, registration: fixed, expectedCommitment: fixed.commitment)
                try require(before.lo - after.hi < 16 || q16 >= 16)
            } catch RootEdgeFailure.ambiguous { checks += 1 }
            catch RootEdgeFailure.unavailable { checks += 1 }
        }
        for translation in [-7.25, -0.25, 0.25, 7.25, 32] {
            let moved = try analyticStripe(width: 513, half: 61.5, phase: phase + translation, contrast: 60)
            do {
                let after = try RootStructuralMetricPrototype.width(moved, registration: fixed, expectedCommitment: fixed.commitment)
                try require(before.lo - after.hi < 16)
            } catch RootEdgeFailure.ambiguous { checks += 1 }
            catch RootEdgeFailure.unavailable { checks += 1 }
        }
    }
    rootEdgePrototypeStage = "review_combined_sampling_regression"
    let referencePair = registration.pairs[0]
    let trueWidth = Double(referencePair.1.edge - referencePair.0.edge) * 65_536 / Double(ordinary.width)
    for displacement in [0.125, 0.25, 0.5, 0.75, 0.875] { for kernel in 0..<3 {
        var row: [Double] = []
        for x in 0..<ordinary.width {
            let shift: Double = kernel == 0 ? -2 : (kernel == 1 ? 2 : (x < ordinary.width / 2 ? -2 : 2))
            let position = min(Double(ordinary.width - 1), max(0, Double(x) - displacement + shift))
            row.append(ordinary.sample(position, 0))
        }
        let changed = try RootEdgePlane(width: ordinary.width, height: ordinary.height,
            values: Array(repeating: row, count: ordinary.height).flatMap { $0 })
        for anchor in [referencePair.0, referencePair.1] {
            // Independent truth is the pre-blur common displacement. A
            // nuisance kernel may move visible intensity edges, not truth.
            let truth = Double(anchor.edge) + displacement
            do {
                let found = try RootStructuralMetricPrototype.locate(anchor, changed)
                try require(found.lo <= truth && truth <= found.hi)
            } catch RootEdgeFailure.ambiguous { checks += 1 }
            catch RootEdgeFailure.unavailable { checks += 1 }
        }
        do {
            let found = try RootStructuralMetricPrototype.width(changed, registration: registration,
                                                                expectedCommitment: registration.commitment)
            try require(Double(found.lo) <= trueWidth && trueWidth <= Double(found.hi))
            let margin = try RootStructuralMetricPrototype.margins(source: baseline, neutral: baseline,
                candidate: found, siblings: [baseline, baseline, baseline])
            try require(margin.signed < 16 || margin.distinct < 16)
        } catch RootEdgeFailure.ambiguous { checks += 1 }
        catch RootEdgeFailure.unavailable { checks += 1 }
    } }
    rootEdgePrototypeStage = "review_hull_and_invalid_roi_regression"
    try require(RootStructuralMetricPrototype.admittedHull(first: 100, last: 195))
    try require(!RootStructuralMetricPrototype.admittedHull(first: 100, last: 196))
    // Actual five-step ramp that reached the old off-by-one hull boundary.
    // Its current forward-model registration may abstain; any admitted
    // localization must respect the complete six-pixel mathematical hull.
    var rampValues = ordinary.values
    for y in 0..<ordinary.height { for anchor in [referencePair.0, referencePair.1] {
        let increasing = ordinary.values[y * ordinary.width + anchor.edge + 1] > ordinary.values[y * ordinary.width + anchor.edge]
        for offset in -2...2 {
            rampValues[y * ordinary.width + anchor.edge + offset] = increasing
                ? 180 + Double(offset + 3) * 8 : 220 - Double(offset + 3) * 8
        }
    } }
    do {
        let ramp = try RootEdgePlane(width: ordinary.width, height: ordinary.height, values: rampValues)
        let bound = try RootStructuralMetricPrototype.register(ramp, roi: roi)
        for a in [bound.pairs[0].0, bound.pairs[0].1] {
            let interval = try RootStructuralMetricPrototype.locate(a, ramp)
            // Remove only the single representational outward step applied
            // to exact dyadic hull endpoints; never an entire grid cell.
            try require(interval.hi.nextDown - interval.lo.nextUp <= 6)
        }
    } catch RootEdgeFailure.ambiguous { checks += 1 }
    catch RootEdgeFailure.unavailable { checks += 1 }
    let invalidRegions = [
        RootEdgeRegion(minX: 1, maxX: Int.min, minY: 0, maxY: 32),
        .init(minX: 0, maxX: 512, minY: 1, maxY: Int.min),
        .init(minX: Int.max, maxX: 512, minY: 0, maxY: 32),
        .init(minX: 0, maxX: 512, minY: Int.max, maxY: 32),
        .init(minX: 200, maxX: 199, minY: 0, maxY: 32),
        .init(minX: 0, maxX: 512, minY: 20, maxY: 19),
        .init(minX: 0, maxX: 0, minY: 0, maxY: 32),
        .init(minX: 0, maxX: 512, minY: 0, maxY: 0)
    ]
    for invalid in invalidRegions {
        do {
            _ = try RootStructuralMetricPrototype.register(ordinary, roi: invalid)
            throw RootEdgeFailure.unavailable
        } catch RootEdgeFailure.invalidInput { checks += 1 }
    }
    return checks
}

guard CommandLine.arguments.dropFirst().elementsEqual(["--self-test"]) else {
    print("root_edge_prototype_generated_only"); exit(2)
}
do {
    let checks = try rootEdgePrototypeSelfTest()
    print("root_edge_prototype_self_test=pass checks=\(checks) portrait_scoring=disabled")
} catch {
    print("root_edge_prototype_self_test=fail stage=\(rootEdgePrototypeStage) reason=\(error)"); exit(1)
}
