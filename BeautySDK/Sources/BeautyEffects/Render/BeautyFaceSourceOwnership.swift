import BeautyCore
import BeautyDetection
import Foundation

/// A bounded, request-local material proof for the three lateral contour
/// controls. This is not semantic segmentation. Unknown material remains
/// fixed, and neither a displacement nor its output participates in admission.
enum BeautyFaceSourceOwnership {
    enum Control: Hashable, Sendable { case faceWidth, temple, cheekbone }
    enum Material: UInt8, CaseIterable, Sendable {
        case unknown, connectedSkin, highConfidenceHair, highConfidenceBackground
        case mixedTransition, protectedFeature, protectedSourceRidge
    }
    enum Refusal: String, Sendable {
        case sourceUnavailable, invalidRaster, nonopaqueSource, unsupportedScope
        case invalidFreshSupport, seedUnavailable, seedAmbiguous
        case disconnectedSkin, externalMaterialUnproved, emptyEditableRegion
    }

    struct Qualification: Sendable {
        let evidence: Evidence?
        let refusal: Refusal?
        let aggregates: [String: Int]
    }

    struct Evidence: Sendable {
        let width: Int, height: Int
        let aggregates: [String: Int]
        private let owners: [UInt8]
        private let editable: [Bool]
        private let reserveDistance: [UInt16]

        fileprivate init(width: Int, height: Int, owners: [UInt8], editable: [Bool],
                         reserveDistance: [UInt16], aggregates: [String: Int]) {
            self.width = width; self.height = height; self.owners = owners
            self.editable = editable; self.reserveDistance = reserveDistance
            self.aggregates = aggregates
        }

        func material(x: Int, y: Int) -> Material {
            guard x >= 0, y >= 0, x < width, y < height else { return .unknown }
            return Material(rawValue: owners[y * width + x]) ?? .unknown
        }

        /// Final restoration and source transport are separate responsibilities.
        /// Outside scope, unknown, features and proved external cores are fixed.
        func preservesDestinationPixel(x: Int, y: Int) -> Bool {
            guard x >= 0, y >= 0, x < width, y < height else { return true }
            return !editable[y * width + x]
        }

        func allowsTransitionDestination(x: Int, y: Int) -> Bool {
            !preservesDestinationPixel(x: x, y: y) && material(x: x, y: y) == .mixedTransition
        }

        /// Continuous source coordinates use pixel centres at n + .5. All four
        /// bilinear texels must have proved ownership, even at a zero weight.
        func allowsSourceFootprint(x: Double, y: Double) -> Bool {
            guard x.isFinite, y.isFinite else { return false }
            let px = x - 0.5, py = y - 0.5
            guard px >= 0, py >= 0, px < Double(width - 1), py < Double(height - 1) else { return false }
            let ix = Int(floor(px)), iy = Int(floor(py))
            return !preservesDestinationPixel(x: ix, y: iy)
                && !preservesDestinationPixel(x: ix + 1, y: iy)
                && !preservesDestinationPixel(x: ix, y: iy + 1)
                && !preservesDestinationPixel(x: ix + 1, y: iy + 1)
        }

        /// A conservative Euclidean lower bound from an O(pixelCount) eight-
        /// neighbour distance transform. The subtraction covers the query's
        /// offset, the complete reserved texel, and the sampling footprint.
        func distanceToReserve(x: Double, y: Double) -> Double {
            guard x.isFinite, y.isFinite, x >= 0, y >= 0,
                  x < Double(width), y < Double(height) else { return 0 }
            let ix = Int(floor(x)), iy = Int(floor(y))
            return max(0, Double(reserveDistance[iy * width + ix]) - 3)
        }

        /// The caller supplies its current stage input, not the source used to
        /// classify material. This keeps earlier admitted colour/hairline work
        /// intact. Source-footprint admission must also be enforced upstream;
        /// restoration alone cannot prevent transport/cloning of a hair core.
        func compositePreservingSourceCores(originalRGBA: [UInt8], warpedRGBA: [UInt8]) -> [UInt8]? {
            guard originalRGBA.count == width * height * 4,
                  warpedRGBA.count == originalRGBA.count else { return nil }
            for i in stride(from: 3, to: originalRGBA.count, by: 4) {
                guard originalRGBA[i] == 255, warpedRGBA[i] == originalRGBA[i] else { return nil }
            }
            var result = warpedRGBA
            for p in editable.indices where !editable[p] {
                let i = p * 4
                result[i] = originalRGBA[i]; result[i + 1] = originalRGBA[i + 1]
                result[i + 2] = originalRGBA[i + 2]; result[i + 3] = originalRGBA[i + 3]
            }
            return result
        }
    }

    private struct Color {
        let r: Double, g: Double, b: Double
        var luma: Double { r * 0.2126 + g * 0.7152 + b * 0.0722 }
        var sum: Double { max(1, r + g + b) }
        var chroma: SIMD2<Double> { SIMD2(r / sum, g / sum) }
        var vector: SIMD3<Double> { SIMD3(r, g, b) }
    }
    private struct Palette {
        let color: Color
        let deviation: Double
        func admits(_ c: Color) -> Bool {
            hypot(c.chroma.x - color.chroma.x, c.chroma.y - color.chroma.y) <= 0.035
                && c.luma >= max(18, color.luma * 0.58)
                && c.luma <= min(250, color.luma * 1.30 + 8)
        }
    }
    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        func covers(_ p: SIMD2<Double>) -> Bool {
            p.x + 0.5 >= minX && p.x - 0.5 <= maxX && p.y + 0.5 >= minY && p.y - 0.5 <= maxY
        }
        func distanceFromTexel(_ p: SIMD2<Double>) -> Double {
            let dx = max(0, max(minX - p.x - 0.5, p.x - 0.5 - maxX))
            let dy = max(0, max(minY - p.y - 0.5, p.y - 0.5 - maxY))
            return hypot(dx, dy)
        }
    }
    private struct Frame {
        let origin: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>
        let span: Double, chin: Double
        let curve: [SIMD2<Double>], polygon: [SIMD2<Double>], features: [Box]
        let attachments: [Box]
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
        func protectsAttachment(_ p: SIMD2<Double>) -> Bool {
            let halfX = (abs(axisX.x) + abs(axisX.y)) * 0.5
            let halfY = (abs(axisY.x) + abs(axisY.y)) * 0.5
            return attachments.contains { p.x + halfX >= $0.minX && p.x - halfX <= $0.maxX
                && p.y + halfY >= $0.minY && p.y - halfY <= $0.maxY }
        }
        func inside(_ p: SIMD2<Double>) -> Bool {
            var result = false, j = polygon.count - 1
            for i in polygon.indices {
                let a = polygon[i], b = polygon[j]
                if (a.y > p.y) != (b.y > p.y),
                   p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x { result.toggle() }
                j = i
            }
            return result
        }
        func contourDistance(_ p: SIMD2<Double>) -> Double {
            var squared = Double.infinity
            for i in 0..<(curve.count - 1) {
                let a = curve[i], d = curve[i + 1] - a, q = p - a
                let denominator = d.x * d.x + d.y * d.y
                let t = denominator > 0 ? min(1, max(0, (q.x * d.x + q.y * d.y) / denominator)) : 0
                let v = q - d * t
                squared = min(squared, v.x * v.x + v.y * v.y)
            }
            return sqrt(squared)
        }
        func inScope(_ p: SIMD2<Double>, controls: Set<Control>) -> Bool {
            let ranges: [(Control, Double, Double)] = [(.faceWidth, -0.17, 1.0),
                (.temple, -0.38, 0.18), (.cheekbone, -0.10, 0.54)]
            let halfY = (abs(axisY.x) + abs(axisY.y)) * 0.5
            return ranges.contains { controls.contains($0.0) && p.y - halfY >= $0.1 * chin && p.y + halfY <= $0.2 * chin }
        }
    }

    static func qualify(sourceRGBA: [UInt8]?, width: Int, height: Int, face: FaceGeometry,
                        controls: Set<Control>) -> Evidence? {
        assess(sourceRGBA: sourceRGBA, width: width, height: height, face: face, controls: controls).evidence
    }

    static func assess(sourceRGBA: [UInt8]?, width: Int, height: Int, face: FaceGeometry,
                       controls: Set<Control>) -> Qualification {
        func refused(_ reason: Refusal, _ counts: [String: Int] = [:]) -> Qualification {
            Qualification(evidence: nil, refusal: reason, aggregates: counts)
        }
        guard let sourceRGBA else { return refused(.sourceUnavailable) }
        guard width > 8, height > 8, width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              sourceRGBA.count == width * height * 4 else { return refused(.invalidRaster) }
        guard !controls.isEmpty else { return refused(.unsupportedScope) }
        guard stride(from: 3, to: sourceRGBA.count, by: 4).allSatisfy({ sourceRGBA[$0] == 255 }) else {
            return refused(.nonopaqueSource)
        }
        guard let frame = makeFrame(face: face, width: width, height: height) else { return refused(.invalidFreshSupport) }
        let count = width * height
        func color(_ i: Int) -> Color {
            let p = i * 4
            return Color(r: Double(sourceRGBA[p]), g: Double(sourceRGBA[p + 1]), b: Double(sourceRGBA[p + 2]))
        }
        func index(_ p: SIMD2<Double>) -> Int? {
            guard p.x >= 0, p.y >= 0, p.x < Double(width), p.y < Double(height) else { return nil }
            return Int(floor(p.y)) * width + Int(floor(p.x))
        }
        func median(_ values: [Double]) -> Double { let a = values.sorted(); return a[a.count / 2] }
        var seedDiagnostics = [String: Int]()
        let seedRadius = max(2, floor(frame.span * 0.018))
        func geometryPatch(_ center: SIMD2<Double>) -> (indices: [Int]?, rejection: String?) {
            var indices = [Int]()
            for dy in [-seedRadius, 0, seedRadius] { for dx in [-seedRadius, 0, seedRadius] {
                let p = frame.image(center + SIMD2(dx, dy))
                guard let i = index(p) else { return (nil, "OutsideRaster") }
                let texel = SIMD2(Double(i % width) + 0.5, Double(i / width) + 0.5)
                for cy in [-0.5, 0.5] { for cx in [-0.5, 0.5] {
                    guard frame.inside(frame.local(texel + SIMD2(cx, cy))) else { return (nil, "OutsideFacePolygon") }
                } }
                guard !frame.features.contains(where: { $0.covers(texel) }) else { return (nil, "ProtectedFeature") }
                guard !frame.protectsAttachment(frame.local(texel)) else { return (nil, "LateralAttachment") }
                guard frame.features.allSatisfy({ $0.distanceFromTexel(texel) >= 1 }) else { return (nil, "FeatureClearance") }
                indices.append(i)
            } }
            return (indices, nil)
        }
        func cheekGeometryPatch(side: Double, ordinal: Int) -> [Int]? {
            let prefix = "seedFamily\(ordinal)", original = SIMD2(side * frame.span * 0.25, frame.chin * 0.42)
            let originalPatch = geometryPatch(original)
            if let indices = originalPatch.indices {
                seedDiagnostics[prefix + "GeometryCandidateCount"] = 1
                seedDiagnostics[prefix + "SelectedOriginal"] = 1
                return indices
            }
            seedDiagnostics[prefix + "Original" + (originalPatch.rejection ?? "UnknownGeometryRejection")] = 1
            // This cell is declared from anatomy, not source colours. A
            // physical one-pixel grid and fixed distance/tie order choose the
            // nearest complete cheek patch before any RGB qualification.
            let minX = side < 0 ? -frame.span * 0.40 : frame.span * 0.15
            let maxX = side < 0 ? -frame.span * 0.15 : frame.span * 0.40
            let loX = Int(ceil(minX - original.x)), hiX = Int(floor(maxX - original.x))
            let loY = Int(ceil(frame.chin * 0.24 - original.y)), hiY = Int(floor(frame.chin * 0.60 - original.y))
            guard loX <= hiX, loY <= hiY else { seedDiagnostics[prefix + "GeometryCellEmpty"] = 1; return nil }
            var offsets = [SIMD2<Int>]()
            for dy in loY...hiY { for dx in loX...hiX { offsets.append(SIMD2(dx, dy)) } }
            offsets.sort {
                let a = Double($0.x) * Double($0.x) + Double($0.y) * Double($0.y)
                let b = Double($1.x) * Double($1.x) + Double($1.y) * Double($1.y)
                if a != b { return a < b }
                if abs($0.y) != abs($1.y) { return abs($0.y) < abs($1.y) }
                if $0.y != $1.y { return $0.y < $1.y }
                return $0.x < $1.x
            }
            for offset in offsets {
                seedDiagnostics[prefix + "GeometryCandidateCount", default: 0] += 1
                let patch = geometryPatch(original + SIMD2(Double(offset.x), Double(offset.y)))
                if let indices = patch.indices {
                    seedDiagnostics[prefix + "SelectedRelocated"] = 1
                    return indices
                }
                seedDiagnostics[prefix + "GeometryRejected" + (patch.rejection ?? "Unknown"), default: 0] += 1
            }
            seedDiagnostics[prefix + "NoLegalGeometryPatch"] = 1
            return nil
        }
        func family(_ indices: [Int], ordinal: Int) -> (Palette, [Int])? {
            let prefix = "seedFamily\(ordinal)"
            func reject(_ reason: String) { seedDiagnostics[prefix + reason, default: 0] += 1 }
            let samples = indices.map(color)
            seedDiagnostics[prefix + "SampleCount"] = samples.count
            let middle = Color(r: median(samples.map(\.r)), g: median(samples.map(\.g)), b: median(samples.map(\.b)))
            let deviation = median(samples.map { abs($0.luma - middle.luma) })
            let chromaDeviation = median(samples.map { hypot($0.chroma.x - middle.chroma.x, $0.chroma.y - middle.chroma.y) })
            guard middle.luma >= 24, middle.luma <= 240 else { reject("BasicLuma"); return nil }
            guard deviation <= 8 else { reject("LumaMAD"); return nil }
            guard chromaDeviation <= 0.012 else { reject("ChromaMAD"); return nil }
            seedDiagnostics[prefix + "Qualified"] = 1
            return (Palette(color: middle, deviation: deviation), indices)
        }
        // Two cheek families are mandatory and independent. The forehead is
        // optional: a headwrap or fringe may occupy it without supplying skin.
        let leftPatch = cheekGeometryPatch(side: -1, ordinal: 0)
        let rightPatch = cheekGeometryPatch(side: 1, ordinal: 1)
        let leftFamily = leftPatch.flatMap { family($0, ordinal: 0) }
        let rightFamily = rightPatch.flatMap { family($0, ordinal: 1) }
        guard let left = leftFamily, let right = rightFamily else {
            seedDiagnostics["qualifiedSeedFamilies"] = [leftFamily, rightFamily].compactMap { $0 }.count
            return refused(.seedUnavailable, seedDiagnostics)
        }
        let chromaSeparation = hypot(left.0.color.chroma.x - right.0.color.chroma.x,
                                    left.0.color.chroma.y - right.0.color.chroma.y)
        guard chromaSeparation <= 0.025,
              max(left.0.color.luma, right.0.color.luma) / max(1, min(left.0.color.luma, right.0.color.luma)) <= 1.35 else {
            seedDiagnostics["qualifiedSeedFamilies"] = 0
            seedDiagnostics["bilateralPaletteAgreementRejected"] = 1
            return refused(.seedAmbiguous, seedDiagnostics)
        }
        let palette = Palette(color: Color(r: (left.0.color.r + right.0.color.r) * 0.5,
            g: (left.0.color.g + right.0.color.g) * 0.5, b: (left.0.color.b + right.0.color.b) * 0.5),
            deviation: max(left.0.deviation, right.0.deviation))
        var seeds = left.1 + right.1, seedFamilies = 2
        let foreheadPatch = geometryPatch(SIMD2(0, -frame.chin * 0.26))
        if let indices = foreheadPatch.indices, let forehead = family(indices, ordinal: 2), palette.admits(forehead.0.color) {
            seeds += forehead.1; seedFamilies += 1
        } else if let rejection = foreheadPatch.rejection {
            seedDiagnostics["seedFamily2" + rejection] = 1
        }
        var owners = [UInt8](repeating: Material.unknown.rawValue, count: count)
        var interior = [Bool](repeating: false, count: count)
        var sweep = [Bool](repeating: false, count: count)
        var skinCandidate = [Bool](repeating: false, count: count)
        var externalCandidate = [Bool](repeating: false, count: count)
        var hairCandidate = [Bool](repeating: false, count: count)
        var attachmentReserve = [Bool](repeating: false, count: count)
        var hairSeeds = [Int]()
        var geometricAttachmentPixels = 0
        func directionalTexture(_ x: Int, _ y: Int) -> Bool {
            guard x >= 3, y >= 3, x + 3 < width, y + 3 < height else { return false }
            var xx = 0.0, yy = 0.0, xy = 0.0
            for dy in -2...2 { for dx in -2...2 {
                let p = (y + dy) * width + x + dx
                let gx = (color(p + 1).luma - color(p - 1).luma) * 0.5
                let gy = (color(p + width).luma - color(p - width).luma) * 0.5
                xx += gx * gx; yy += gy * gy; xy += gx * gy
            } }
            let trace = xx + yy, delta = hypot(xx - yy, 2 * xy)
            guard trace / 25 >= 9 && (trace + delta) >= 6 * max(1, trace - delta) else { return false }
            // One skin/material colour step has a direction, but is not hair
            // texture. Require repeated, substantial reversals along the
            // dominant tensor axis; weak stripes beside a strong single edge
            // cannot supply this proof for the antialiased boundary itself.
            var differences = [Double]()
            for k in -3..<3 {
                let a = xx >= yy ? y * width + x + k : (y + k) * width + x
                let b = xx >= yy ? a + 1 : a + width
                differences.append(color(b).luma - color(a).luma)
            }
            let significant = max(2, (differences.map { abs($0) }.max() ?? 0) * 0.15)
            var previous = 0, reversals = 0
            for value in differences where abs(value) >= significant {
                let sign = value > 0 ? 1 : -1
                if previous != 0 && sign != previous { reversals += 1 }
                previous = sign
            }
            return reversals >= 2
        }
        // Border palettes are read independently of the anatomical seeds.
        // They must agree locally and differ clearly from the skin palette.
        var borderPalettes = [Color]()
        for p in [SIMD2(2.5, 2.5), SIMD2(Double(width) - 3.5, 2.5),
                  SIMD2(2.5, Double(height) - 3.5), SIMD2(Double(width) - 3.5, Double(height) - 3.5)] {
            guard let i = index(p) else { continue }
            let c = color(i)
            let separated = hypot(c.chroma.x - palette.color.chroma.x, c.chroma.y - palette.color.chroma.y) >= 0.06
                || abs(c.luma - palette.color.luma) >= 55
            let x = i % width, y = i / width
            var homogeneous = true
            for dy in -2...2 { for dx in -2...2 {
                let other = color((y + dy) * width + x + dx)
                if abs(other.luma - c.luma) > 6 || hypot(other.chroma.x - c.chroma.x, other.chroma.y - c.chroma.y) > 0.012 {
                    homogeneous = false
                }
            } }
            if separated && homogeneous { borderPalettes.append(c) }
        }
        func matchesBackground(_ c: Color) -> Bool {
            borderPalettes.contains { abs(c.luma - $0.luma) <= 12
                && hypot(c.chroma.x - $0.chroma.x, c.chroma.y - $0.chroma.y) <= 0.022 }
        }
        for y in 0..<height { for x in 0..<width {
            let i = y * width + x, p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), q = frame.local(p)
            if frame.features.contains(where: { $0.covers(p) }) { owners[i] = Material.protectedFeature.rawValue; continue }
            if frame.protectsAttachment(q) { geometricAttachmentPixels += 1; attachmentReserve[i] = true }
            interior[i] = frame.inside(q)
            let d = frame.contourDistance(q)
            let reach = frame.span * (interior[i] ? 0.20 : 0.06) - 1
            sweep[i] = frame.inScope(q, controls: controls) && d <= reach
            let c = color(i), skinLike = palette.admits(c)
            let inHead = abs(q.x) <= frame.span * 0.82 && q.y >= -frame.chin * 0.95 && q.y <= frame.chin * 0.55
            let separated = hypot(c.chroma.x - palette.color.chroma.x, c.chroma.y - palette.color.chroma.y) >= 0.045
            let dark = c.luma < palette.color.luma * 0.62
            let gold = separated && c.r > c.b * 1.25 && c.g > c.b * 1.15
            // The texture result is relevant only to these two predicates.
            // Spatial pruning preserves the exact admission rule and avoids
            // a 25-cell analysis of the unrelated background on every request.
            let textureRelevant = (interior[i] && skinLike) || (inHead && !skinLike && (dark || gold))
            let textured = textureRelevant && directionalTexture(x, y)
            skinCandidate[i] = interior[i] && skinLike && !textured
            externalCandidate[i] = !interior[i] && matchesBackground(c)
            hairCandidate[i] = inHead && !skinLike && (dark || gold)
            // Local texture selects the independent top-head colour seeds.
            // A matching, connected core texel need not itself contain a full
            // stripe period: that would erase all evidence at a material edge.
            if hairCandidate[i], textured, q.y < -frame.chin * 0.25 { hairSeeds.append(i) }
        } }

        // A single source-dark filament can cross otherwise palette-compatible
        // skin without carrying the top-head texture. Prove a narrow valley
        // with skin on BOTH transverse sides, then require sustained source
        // coherence. A one-sided shadow edge or a broad patch cannot qualify.
        let ridgeWidth = max(4, min(12, Int(ceil(frame.span * 0.012))))
        let ridgeHalfLength = max(4, min(16, Int(ceil(frame.span * 0.015))))
        let ridgeContrast = max(6, palette.color.luma * 0.06)
        let normals = (0..<8).map { i in SIMD2(cos(Double(i) * .pi / 8), sin(Double(i) * .pi / 8)) }
        var ridgeMasks = [UInt8](repeating: 0, count: count)
        func section(_ i: Int, orientation: Int) -> (before: Int, after: Int)? {
            let center = SIMD2(Double(i % width) + 0.5, Double(i / width) + 0.5), n = normals[orientation]
            let value = color(i).luma
            guard value <= palette.color.luma - ridgeContrast else { return nil }
            func endpoint(_ sign: Double) -> (step: Int, distance: Double, color: Color)? {
                for step in 1...(ridgeWidth + 1) {
                    var samples = [Color](), firstIndex: Int?
                    for plateau in 0..<3 {
                        let p = center + n * (sign * Double(step + plateau))
                        guard let j = index(p) else { break }
                        let c = color(j)
                        guard palette.admits(c), c.luma - value >= ridgeContrast else { break }
                        if firstIndex == nil { firstIndex = j }
                        samples.append(c)
                    }
                    guard samples.count == 3, let j = firstIndex else { continue }
                    let first = samples[0]
                    guard samples.allSatisfy({ abs($0.luma - first.luma) <= max(8, palette.color.luma * 0.05)
                        && hypot($0.chroma.x - first.chroma.x, $0.chroma.y - first.chroma.y) <= 0.018 }) else { continue }
                    let p = SIMD2(Double(j % width) + 0.5, Double(j / width) + 0.5)
                    return (step, hypot(p.x - center.x, p.y - center.y), first)
                }
                return nil
            }
            guard let before = endpoint(-1), let after = endpoint(1),
                  before.distance + after.distance - 1 <= Double(ridgeWidth),
                  abs(before.color.luma - after.color.luma) <= max(12, palette.color.luma * 0.10),
                  hypot(before.color.chroma.x - after.color.chroma.x, before.color.chroma.y - after.color.chroma.y) <= 0.025 else { return nil }
            return (before.step, after.step)
        }
        for i in sweep.indices where sweep[i] && interior[i] && !attachmentReserve[i] && owners[i] == Material.unknown.rawValue {
            guard color(i).luma <= palette.color.luma - ridgeContrast else { continue }
            for orientation in normals.indices where section(i, orientation: orientation) != nil {
                ridgeMasks[i] |= UInt8(1 << orientation)
            }
        }
        var ridgeAccepted = [Bool](repeating: false, count: count), ridgeQueue = [Int]()
        var ridgeSeedCount = 0
        for i in ridgeMasks.indices where ridgeMasks[i] != 0 {
            let p = SIMD2(Double(i % width) + 0.5, Double(i / width) + 0.5)
            for orientation in normals.indices where ridgeMasks[i] & UInt8(1 << orientation) != 0 {
                let n = normals[orientation], tangent = SIMD2(-n.y, n.x), bit = UInt8(1 << orientation)
                let coherent = [-ridgeHalfLength, -ridgeHalfLength / 2, 0, ridgeHalfLength / 2, ridgeHalfLength].allSatisfy { step in
                    guard let j = index(p + tangent * Double(step)) else { return false }
                    return ridgeMasks[j] & bit != 0
                }
                if coherent { ridgeAccepted[i] = true; ridgeQueue.append(i); ridgeSeedCount += 1; break }
            }
        }
        var ridgeHead = 0
        while ridgeHead < ridgeQueue.count {
            let i = ridgeQueue[ridgeHead]; ridgeHead += 1
            let x = i % width, y = i / width
            for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                let xx = x + dx, yy = y + dy
                guard xx >= 0, yy >= 0, xx < width, yy < height else { continue }
                let j = yy * width + xx
                if !ridgeAccepted[j], ridgeMasks[j] & ridgeMasks[i] != 0 { ridgeAccepted[j] = true; ridgeQueue.append(j) }
            } }
        }
        func reserveRidgeTexel(_ i: Int) {
            let x = i % width, y = i / width
            // The coherent section owns its whole narrow width plus a single
            // native texel collar for the original antialias footprint.
            for yy in max(0, y - 1)...min(height - 1, y + 1) {
                for xx in max(0, x - 1)...min(width - 1, x + 1) {
                    let j = yy * width + xx
                    if owners[j] != Material.protectedFeature.rawValue { owners[j] = Material.protectedSourceRidge.rawValue }
                    skinCandidate[j] = false; hairCandidate[j] = false; externalCandidate[j] = false
                }
            }
        }
        for i in ridgeAccepted.indices where ridgeAccepted[i] {
            let p = SIMD2(Double(i % width) + 0.5, Double(i / width) + 0.5)
            for orientation in normals.indices where ridgeMasks[i] & UInt8(1 << orientation) != 0 {
                guard let endpoints = section(i, orientation: orientation) else { continue }
                for step in (-endpoints.before + 1)..<endpoints.after {
                    if let j = index(p + normals[orientation] * Double(step)) { reserveRidgeTexel(j) }
                }
            }
        }
        func connected(_ candidates: [Bool], seeds: [Int]) -> [Bool] {
            var accepted = [Bool](repeating: false, count: count), queue = [Int]()
            for i in seeds where i >= 0 && i < count && candidates[i] && !accepted[i] {
                accepted[i] = true; queue.append(i)
            }
            var head = 0
            while head < queue.count {
                let i = queue[head]; head += 1
                let x = i % width, y = i / width
                for j in [x > 0 ? i - 1 : -1, x + 1 < width ? i + 1 : -1,
                          y > 0 ? i - width : -1, y + 1 < height ? i + width : -1] {
                    if j >= 0, candidates[j], !accepted[j] { accepted[j] = true; queue.append(j) }
                }
            }
            return accepted
        }
        // Independently sampled top-head texture supplies the hair colour
        // family. Connected antialias pixels that merely lie between skin and
        // that family do not inherit a high-confidence core by connectivity.
        var provedHairSeeds = [Int]()
        if hairSeeds.count >= 9 {
            let colors = hairSeeds.map(color)
            let redGreen = median(colors.map { $0.r - $0.g }), greenBlue = median(colors.map { $0.g - $0.b })
            let luma = median(colors.map(\.luma))
            let rgTolerance = max(3, 4 * median(colors.map { abs(($0.r - $0.g) - redGreen) }))
            let gbTolerance = max(3, 4 * median(colors.map { abs(($0.g - $0.b) - greenBlue) }))
            let lumaTolerance = max(12, 4 * median(colors.map { abs($0.luma - luma) }))
            for i in hairCandidate.indices where hairCandidate[i] {
                let c = color(i)
                hairCandidate[i] = abs((c.r - c.g) - redGreen) <= rgTolerance
                    && abs((c.g - c.b) - greenBlue) <= gbTolerance && abs(c.luma - luma) <= lumaTolerance
            }
            provedHairSeeds = hairSeeds.filter { hairCandidate[$0] }
        } else { hairCandidate = [Bool](repeating: false, count: count) }
        let skin = connected(skinCandidate, seeds: seeds), hair = connected(hairCandidate, seeds: provedHairSeeds)
        var borderSeeds = [Int]()
        for x in 0..<width { borderSeeds.append(x); borderSeeds.append((height - 1) * width + x) }
        for y in 1..<(height - 1) { borderSeeds.append(y * width); borderSeeds.append(y * width + width - 1) }
        let background = connected(externalCandidate, seeds: borderSeeds)
        let skinCount = skin.filter { $0 }.count
        var aggregates = seedDiagnostics
        aggregates["qualifiedSeedFamilies"] = seedFamilies
        aggregates["connectedSkinPixels"] = skinCount
        aggregates["borderPaletteFamilies"] = borderPalettes.count
        aggregates["sourceTextureHairSeedPixels"] = hairSeeds.count
        aggregates["provedHairSeedPixels"] = provedHairSeeds.count
        aggregates["geometricAttachmentPixels"] = geometricAttachmentPixels
        aggregates["ridgeCandidatePixels"] = ridgeMasks.filter { $0 != 0 }.count
        aggregates["ridgeCoherentSeedPixels"] = ridgeSeedCount
        guard skinCount >= max(32, Int(frame.span * frame.span * 0.01)) else { return refused(.disconnectedSkin, aggregates) }
        // A bounded local search supplies positive evidence for a mixed
        // boundary. It cannot turn an arbitrary non-skin pixel into hair.
        let transitionReach = max(2, min(6, Int(ceil(frame.span * 0.008))))
        var editable = [Bool](repeating: false, count: count)
        for y in 0..<height { for x in 0..<width {
            let i = y * width + x
            if owners[i] == Material.protectedFeature.rawValue || owners[i] == Material.protectedSourceRidge.rawValue { continue }
            // Independent core proof wins over any nearby mixture hypothesis.
            // A pure hair/background texel is never relabelled editable merely
            // because a face-connected skin neighbour happens to be nearby.
            if hair[i] { owners[i] = Material.highConfidenceHair.rawValue; continue }
            if background[i] { owners[i] = Material.highConfidenceBackground.rawValue; continue }
            var hasSkinNeighbor = false, externalNeighbor: Color?
            if sweep[i] {
                for dy in -transitionReach...transitionReach { for dx in -transitionReach...transitionReach {
                    let xx = x + dx, yy = y + dy
                    guard xx >= 0, yy >= 0, xx < width, yy < height else { continue }
                    let j = yy * width + xx
                    if skin[j] { hasSkinNeighbor = true }
                    if (hair[j] || background[j]), externalNeighbor == nil { externalNeighbor = color(j) }
                } }
            }
            var mixed = false
            if hasSkinNeighbor, let e = externalNeighbor {
                // The cheek palette is independent of this boundary. Using a
                // nearby antialias pixel as the skin endpoint could explain
                // away a real mixture as unchanged skin.
                let s = palette.color
                let v = e.vector - s.vector, q = color(i).vector - s.vector
                let energy = v.x * v.x + v.y * v.y + v.z * v.z
                if energy >= 32 * 32 {
                    let t = (q.x * v.x + q.y * v.y + q.z * v.z) / energy
                    let residual = q - v * min(1, max(0, t))
                    mixed = t >= 0.05 && t <= 0.95 && sqrt((residual.x * residual.x + residual.y * residual.y + residual.z * residual.z) / 3) <= 5
                }
            }
            // Read-only material evidence does not grant an edit right in a
            // same-colour ear/face attachment. Its geometric reserve remains
            // fixed for destination, source footprint and distance taper.
            if mixed { owners[i] = Material.mixedTransition.rawValue; editable[i] = !attachmentReserve[i] }
            else if skin[i] { owners[i] = Material.connectedSkin.rawValue; editable[i] = sweep[i] && !attachmentReserve[i] }
        } }
        for m in Material.allCases { aggregates[String(describing: m) + "Pixels"] = owners.filter { $0 == m.rawValue }.count }
        aggregates["editablePixels"] = editable.filter { $0 }.count
        aggregates["reservedPixels"] = count - aggregates["editablePixels", default: 0]
        aggregates["reservedMixedTransitionPixels"] = owners.indices.filter {
            owners[$0] == Material.mixedTransition.rawValue && !editable[$0]
        }.count
        aggregates["editableMixedTransitionPixels"] = owners.indices.filter {
            owners[$0] == Material.mixedTransition.rawValue && editable[$0]
        }.count
        guard aggregates["highConfidenceHairPixels", default: 0] + aggregates["highConfidenceBackgroundPixels", default: 0] >= 16 else {
            return refused(.externalMaterialUnproved, aggregates)
        }
        guard aggregates["editablePixels", default: 0] >= 16 else { return refused(.emptyEditableRegion, aggregates) }
        let distance = distanceTransform(editable: editable, width: width, height: height)
        return Qualification(evidence: Evidence(width: width, height: height, owners: owners, editable: editable,
            reserveDistance: distance, aggregates: aggregates), refusal: nil, aggregates: aggregates)
    }

    private static func makeFrame(face: FaceGeometry, width: Int, height: Int) -> Frame? {
        guard face.freshness == .fresh, let support = face.observedFaceSupport,
              let brows = face.observedEyebrowSupport, let leftBrow = brows.left, let rightBrow = brows.right,
              let nose = face.observedNoseSupport, let mouth = face.observedOuterLips,
              (7...32).contains(support.contour.count), face.leftEye.count >= 4, face.rightEye.count >= 4,
              leftBrow.points.count >= 2, rightBrow.points.count >= 2, mouth.count >= 4,
              nose.crest.count >= 3, nose.contour.count >= 3 else { return nil }
        let leftEye = face.leftEyeSupport?.contour ?? face.leftEye
        let rightEye = face.rightEyeSupport?.contour ?? face.rightEye
        // A present malformed support must refuse, not fall back to legacy
        // points or reach an empty feature envelope's extrema below.
        guard leftEye.count >= 4, rightEye.count >= 4 else { return nil }
        let nasal = (nose.crest + nose.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        var paths = [leftEye, rightEye, leftBrow.points, rightBrow.points, mouth, nasal]
        if let dense = face.denseSupport {
            paths[2] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.leftBrowEnvelope)
            paths[3] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.rightBrowEnvelope)
            paths[5] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseCrest)
                + BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseContour)
        }
        let all = support.contour + paths.flatMap { $0 }
        guard all.allSatisfy({ $0.x.isFinite && $0.y.isFinite && $0.x >= 0 && $0.x <= 1 && $0.y >= 0 && $0.y <= 1 }),
              leftBrow.side == .left, rightBrow.side == .right,
              Set(support.contour).count >= 7, Set(nasal).count >= 3 else { return nil }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height)) }
        func mean(_ p: [SIMD2<Float>]) -> SIMD2<Double> { p.map(pixel).reduce(.zero, +) / Double(p.count) }
        let left = mean(face.leftEye), right = mean(face.rightEye), d = right - left
        let eyeDistance = hypot(d.x, d.y)
        guard eyeDistance >= 4 else { return nil }
        let axisX = d / eyeDistance, axisY = SIMD2(-axisX.y, axisX.x), origin = (left + right) * 0.5
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let q = p - origin
            return SIMD2(q.x * axisX.x + q.y * axisX.y, q.x * axisY.x + q.y * axisY.y)
        }
        var contour = support.contour.map { local(pixel($0)) }
        let span = (contour.map(\.x).max() ?? 0) - (contour.map(\.x).min() ?? 0)
        let chin = contour.map(\.y).max() ?? 0
        guard span >= 24, span > eyeDistance * 1.1, span < eyeDistance * 4, chin > eyeDistance * 0.4 else { return nil }
        if contour[0].x > contour.last!.x { contour.reverse() }
        let first = contour[0], last = contour.last!
        let curve = [SIMD2(first.x * 0.96, -chin * 0.32), SIMD2(first.x, -chin * 0.12)]
            + contour + [SIMD2(last.x, -chin * 0.12), SIMD2(last.x * 0.96, -chin * 0.32)]
        let collars = [0.055, 0.055, 0.045, 0.045, 0.08, 0.008]
        let features = zip(paths, collars).map { path, collar -> Box in
            let p = path.map(pixel), padding = max(2, span * collar)
            return Box(minX: p.map(\.x).min()! - padding, maxX: p.map(\.x).max()! + padding,
                       minY: p.map(\.y).min()! - padding, maxY: p.map(\.y).max()! + padding)
        }
        let nasalBottom = paths[5].map { local(pixel($0)).y }.max() ?? 0
        let attachmentTop = -span * 0.04, attachmentBottom = min(chin * 0.48, max(0, nasalBottom) + span * 0.04)
        var attachments = [Box]()
        if attachmentBottom > attachmentTop {
            for (endpoint, side) in [(first, -1.0), (last, 1.0)] {
                let inner = endpoint.x - side * span * 0.08, outer = endpoint.x + side * span * 0.24
                attachments.append(Box(minX: min(inner, outer), maxX: max(inner, outer),
                    minY: attachmentTop, maxY: attachmentBottom))
            }
        }
        return Frame(origin: origin, axisX: axisX, axisY: axisY, span: span, chin: chin,
                     curve: curve, polygon: curve, features: features, attachments: attachments)
    }

    private static func distanceTransform(editable: [Bool], width: Int, height: Int) -> [UInt16] {
        var result = [UInt16](repeating: .max, count: editable.count)
        var queue = [Int](); queue.reserveCapacity(editable.count)
        for i in editable.indices where !editable[i] { result[i] = 0; queue.append(i) }
        var head = 0
        while head < queue.count {
            let i = queue[head]; head += 1
            let x = i % width, y = i / width, next = result[i] == .max ? UInt16.max : result[i] + 1
            for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                let xx = x + dx, yy = y + dy
                guard xx >= 0, yy >= 0, xx < width, yy < height else { continue }
                let j = yy * width + xx
                if next < result[j] { result[j] = next; queue.append(j) }
            } }
        }
        return result
    }
}

extension BeautyFaceSourceOwnership.Evidence: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyFaceSourceOwnership.Evidence(aggregates: \(aggregates))" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["aggregates": aggregates]) }
}

extension BeautyFaceSourceOwnership.Qualification: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyFaceSourceOwnership.Qualification(refusal: \(refusal?.rawValue ?? "none"), aggregates: \(aggregates))" }
    var debugDescription: String { description }
    var customMirror: Mirror {
        let fields: KeyValuePairs<String, Any> = ["refusal": refusal?.rawValue ?? "none", "aggregates": aggregates]
        return Mirror(self, children: fields)
    }
}
