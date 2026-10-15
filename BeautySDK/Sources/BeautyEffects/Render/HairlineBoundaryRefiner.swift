import Foundation
import BeautyDetection

/// Conservative source-pixel hair/skin boundary shift for still images.
/// A coherent dark cap above lighter forehead skin is required; ambiguous
/// inputs remain exact. The bytes and detected rows are request-local.
enum HairlineBoundaryRefiner {
    static func combinedStrength(hairline: Float, forehead: Float) -> Float {
        let value = hairline - forehead * BeautySafetyCaps.hairlineHeight /
            BeautySafetyCaps.foreheadHeight
        return min(BeautySafetyCaps.hairlineHeight,
                   max(-BeautySafetyCaps.hairlineHeight, value))
    }

    private struct Boundary {
        let left: Int
        let right: Int
        let rows: [Int]
        let high: Int
        var soft: Bool = false
        var coherentCurve: Bool = false
    }

    static func hasCoherentHairCap(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Bool {
        // Head-wrap keeps its existing hard-edge qualification; admitting a
        // soft forehead boundary does not qualify a whole-head point warp.
        detectBoundary(source, width: width, height: height, face: face).map { !$0.soft } ?? false
    }

    static func apply(
        _ source: [UInt8], width: Int, height: Int,
        face: FaceGeometry, strength: Float
    ) -> [UInt8] {
        guard strength.isFinite, abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.hairlineHeight,
              let detected = detectBoundary(
                  source, width: width, height: height, face: face
              )
        else { return source }

        let bounds = face.bounds
        let left = detected.left
        let right = detected.right
        let boundary = detected.rows
        let high = detected.high
        let shift = bounds.height * Float(height) * 0.018 *
            strength / BeautySafetyCaps.hairlineHeight
        let browSamples = (face.observedEyebrowSupport?.left?.points ?? []) +
            (face.observedEyebrowSupport?.right?.points ?? [])
        guard browSamples.allSatisfy({ point in
            point.x.isFinite && point.y.isFinite &&
                (0...1).contains(point.x) && (0...1).contains(point.y)
        }) else { return source }
        let browTop = browSamples.map { Int($0.y * Float(height)) }.min()
        var sourceSpan = bounds.width
        if detected.coherentCurve {
            let sourceContour = face.observedFaceSupport?.contour ?? face.faceContour
            guard sourceContour.allSatisfy({ $0.x.isFinite && $0.y.isFinite &&
                (0...1).contains($0.x) && (0...1).contains($0.y) }) else { return source }
            sourceSpan = min(bounds.width,
                (sourceContour.map(\.x).max() ?? 0) - (sourceContour.map(\.x).min() ?? 0))
            guard sourceSpan > 0 else { return source }
        }
        let radius = detected.coherentCurve
            ? min(max(6, Int(sourceSpan * Float(width) * 0.06)),
                  max(1, Int(Float((browTop ?? height) - high - 3) * 0.7)))
            : detected.soft
            ? min(max(20, Int(bounds.height * Float(height) * 0.08)),
                  max(1, Int(Float((browTop ?? height) - high - 3) * 0.7)))
            : max(6, min(11, Int(bounds.height * Float(height) * 0.032)))
        guard detected.coherentCurve ? radius >= 12 : (!detected.soft || radius >= 20) else { return source }
        // Soft boundaries use a cap-shape bound for a continuously monotone
        // inverse map; increasing the slider never moves the kernel center.
        let admittedShift = detected.coherentCurve
            ? min(Float(radius) * 0.29, bounds.height * Float(height) * 0.018) *
                strength / BeautySafetyCaps.hairlineHeight
            : detected.soft
            ? min(Float(radius) * 0.25, bounds.height * Float(height) * 0.018) *
                strength / BeautySafetyCaps.hairlineHeight : shift
        let lowerReach = high + Int(ceil(max(0, shift))) + radius
        if let brows = face.observedEyebrowSupport {
            let samples = (brows.left?.points ?? []) + (brows.right?.points ?? [])
            guard !samples.isEmpty,
                  samples.allSatisfy({ point in
                      point.x.isFinite && point.y.isFinite &&
                          (0...1).contains(point.x) && (0...1).contains(point.y)
                  }),
                  let browTop = samples.map({ Int($0.y * Float(height)) }).min(),
                  lowerReach < browTop - 2
            else { return source }
        }

        if detected.coherentCurve {
            let fraction = abs(strength) / BeautySafetyCaps.hairlineHeight
            let capShift = admittedShift / fraction
            return applyProtectedCoherentCurve(source, width: width, height: height,
                face: face, boundary: detected, radius: radius, shift: capShift, fraction: fraction)
        }

        var output = source
        let taper = min(20, (right - left) / 4)
        for x in left...right {
            let xWeight = min(1, Float(x - left) / Float(taper),
                              Float(right - x) / Float(taper))
            guard xWeight > 0 else { continue }
            let edge = boundary[x - left]
            for y in max(1, edge - radius)..<min(height - 1, edge + radius + 1) {
                let distance = abs(y - edge)
                let yWeight: Float = detected.soft
                    ? pow(max(0, 1 - pow(Float(distance) / Float(radius), 2)), 2)
                    : (distance <= radius / 2 ? 1 :
                       max(0, Float(radius - distance) / Float(radius - radius / 2)))
                let sampleY = Float(y) - admittedShift * xWeight * yWeight
                guard sampleY >= 0, sampleY < Float(height - 1) else { continue }
                let y0 = Int(floor(sampleY))
                let fraction = sampleY - Float(y0)
                let dst = (y * width + x) * 4
                let src0 = (y0 * width + x) * 4
                let src1 = ((y0 + 1) * width + x) * 4
                guard source[dst + 3] == 255,
                      source[src0 + 3] == 255, source[src1 + 3] == 255
                else { continue }
                for channel in 0..<3 {
                    let a = Float(source[src0 + channel])
                    let b = Float(source[src1 + channel])
                    output[dst + channel] = UInt8(min(255, max(0,
                        Int((a + (b - a) * fraction).rounded()))))
                }
            }
        }
        return output
    }

    private struct CoherentProtection {
        let left: Int
        let top: Int
        let width: Int
        let height: Int
        let hard: [Bool]
        let distance: [Float]
        func index(_ x: Int, _ y: Int) -> Int? {
            guard x >= left, y >= top, x < left + width, y < top + height else { return nil }
            return (y - top) * width + x - left
        }
        func protects(_ x: Int, _ y: Int) -> Bool { index(x, y).map { hard[$0] } ?? false }
    }

    /// A narrow source-dark branch needs brighter warm support on both sides
    /// along at least one of four cross-sections. The broad cap/skin edge has
    /// only one bright side and cannot qualify as a protected branch. This is
    /// conservative photometric protection, not semantic strand inference.
    private static func coherentBranchProtection(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        boundary: Boundary, radius: Int, shift: Float
    ) -> CoherentProtection? {
        // Branch evidence is still read at native resolution. Express its
        // cross-section and AA core in the same bounded physical unit as the
        // new coherent field; no upsampling creates additional evidence.
        let unit = min(1, Float(512) / Float(max(width, height)))
        let physicalWidth = max(2, min(8, Int(face.bounds.width * Float(width) * unit * 0.012)))
        let maximumWidth = max(2, Int(ceil(Float(physicalWidth) / unit)))
        let coreRadius = max(1, Int(ceil(1 / unit)))
        let margin = maximumWidth + Int(ceil(abs(shift))) + coreRadius + 1
        let left = max(0, boundary.left - margin), right = min(width - 1, boundary.right + margin)
        let top = max(0, (boundary.rows.min() ?? 0) - radius - margin)
        let bottom = min(height - 1, boundary.high + radius + margin)
        let w = right - left + 1, h = bottom - top + 1
        var core = [Bool](repeating: false, count: w * h)
        func light(_ x: Int, _ y: Int) -> Float {
            let i = (y * width + x) * 4
            return (Float(source[i]) + 2 * Float(source[i + 1]) + Float(source[i + 2])) / 4
        }
        func brightWarm(_ x: Int, _ y: Int, relativeTo value: Float) -> Bool {
            guard x >= 0, y >= 0, x < width, y < height else { return false }
            let i = (y * width + x) * 4
            return source[i + 3] == 255 && source[i] >= 90 &&
                Int(source[i]) - Int(source[i + 2]) >= 10 && source[i + 1] >= source[i + 2] &&
                light(x, y) - value >= 32
        }
        let directions = [(1, 0), (0, 1), (1, 1), (1, -1)]
        for y in top...bottom { for x in left...right {
            guard source[(y * width + x) * 4 + 3] == 255 else { continue }
            let value = light(x, y)
            for (dx, dy) in directions {
                var before: Int?, after: Int?
                for step in 1...(maximumWidth + 1) {
                    if before == nil, brightWarm(x - dx * step, y - dy * step, relativeTo: value) { before = step }
                    if after == nil, brightWarm(x + dx * step, y + dy * step, relativeTo: value) { after = step }
                }
                if let before, let after, before + after - 1 <= maximumWidth,
                   abs(light(x - dx * before, y - dy * before) - light(x + dx * after, y + dy * after)) <= 32 {
                    core[(y - top) * w + x - left] = true
                    break
                }
            }
        } }
        guard core.contains(true) else { return nil }
        var hard = core
        for y in 0..<h { for x in 0..<w where core[y * w + x] {
            for yy in max(0, y - coreRadius)...min(h - 1, y + coreRadius) {
                for xx in max(0, x - coreRadius)...min(w - 1, x + coreRadius) { hard[yy * w + xx] = true }
            }
        } }
        return CoherentProtection(left: left, top: top, width: w, height: h,
            hard: hard, distance: coherentDistances(hard, width: w, height: h))
    }

    private static func coherentDistances(_ hard: [Bool], width w: Int, height h: Int) -> [Float] {
        var distance = hard.map { $0 ? Float.zero : Float.infinity }
        let diagonal = Float(2).squareRoot()
        for y in 0..<h { for x in 0..<w {
            let i = y * w + x
            if x > 0 { distance[i] = min(distance[i], distance[i - 1] + 1) }
            if y > 0 {
                distance[i] = min(distance[i], distance[i - w] + 1)
                if x > 0 { distance[i] = min(distance[i], distance[i - w - 1] + diagonal) }
                if x + 1 < w { distance[i] = min(distance[i], distance[i - w + 1] + diagonal) }
            }
        } }
        for y in (0..<h).reversed() { for x in (0..<w).reversed() {
            let i = y * w + x
            if x + 1 < w { distance[i] = min(distance[i], distance[i + 1] + 1) }
            if y + 1 < h {
                distance[i] = min(distance[i], distance[i + w] + 1)
                if x > 0 { distance[i] = min(distance[i], distance[i + w - 1] + diagonal) }
                if x + 1 < w { distance[i] = min(distance[i], distance[i + w + 1] + diagonal) }
            }
        } }
        return distance
    }

    /// A C1 ramp with a small flat core uses the existing radius and amplitude.
    /// Its maximum normalized slope is 1/.67; .29 of the radius remains below
    /// .45 before the final source-fixed field constraint.
    private static func coherentRamp(_ distance: Float) -> Float {
        if distance <= 0.23 { return 1 }
        if distance >= 1 { return 0 }
        if distance < 0.33 { return 1 - pow(distance - 0.23, 2) / 0.134 }
        if distance <= 0.9 { return max(0, 1 - (distance - 0.28) / 0.67) }
        return pow(1 - distance, 2) / 0.134
    }

    private static func applyProtectedCoherentCurve(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        boundary: Boundary, radius: Int, shift: Float, fraction: Float
    ) -> [UInt8] {
        let unit = min(1, Double(512) / Double(max(width, height)))
        let aw = max(2, Int(floor(Double(width) * unit)))
        let ah = max(2, Int(floor(Double(height) * unit)))
        let rx = Float(aw) / Float(width), ry = Float(ah) / Float(height)
        let left = max(0, Int(ceil((Float(boundary.left) + 0.5) * rx - 0.5)))
        let right = min(aw - 1, Int(floor((Float(boundary.right) + 0.5) * rx - 0.5)))
        let sourceTop = max(1, (boundary.rows.min() ?? 0) - radius)
        let sourceBottom = min(height - 2, boundary.high + radius)
        let top = max(0, Int(floor((Float(sourceTop) + 0.5) * ry - 0.5)))
        let bottom = min(ah - 1, Int(ceil((Float(sourceBottom) + 0.5) * ry - 0.5)))
        let w = right - left + 1, h = bottom - top + 1
        guard h > 1, w > 1 else { return source }
        let nativeProtection = coherentBranchProtection(source, width: width, height: height,
            face: face, boundary: boundary, radius: radius, shift: shift)
        // Conservative coverage projection preserves every native branch and
        // every nonopaque source footprint. It projects evidence, not colors.
        var hard = [Bool](repeating: false, count: w * h)
        for y in top...bottom { for x in left...right {
            let x0 = max(0, Int(floor(Float(x) / rx)))
            let x1 = min(width - 1, Int(ceil(Float(x + 1) / rx)) - 1)
            let y0 = max(0, Int(floor(Float(y) / ry)))
            let y1 = min(height - 1, Int(ceil(Float(y + 1) / ry)) - 1)
            for yy in y0...y1 { for xx in x0...x1 {
                if source[(yy * width + xx) * 4 + 3] != 255 || nativeProtection?.protects(xx, yy) == true {
                    hard[(y - top) * w + x - left] = true
                }
            } }
        } }
        let protection = CoherentProtection(left: left, top: top, width: w, height: h,
            hard: hard, distance: coherentDistances(hard, width: w, height: h))
        let taper = max(1, min(20, (right - left) / 4))
        var field = [Float](repeating: 0, count: w * h)
        let direction: Float = shift < 0 ? -1 : 1
        // The derivative peak lies inside a mixed source transition. Reserve
        // two physical field texels on its skin side so the lower tail cannot
        // use a smooth skin illumination gradient as additional target area.
        // The upper support and amplitude are unchanged; the final vector
        // constraint still only reduces this source-fixed C1 field.
        let lowerRadius = max(1 / ry, Float(radius) - 2 / ry)
        for x in left...right {
            let t = min(1, Float(x - left) / Float(taper), Float(right - x) / Float(taper))
            let xWeight = t * t * (3 - 2 * t)
            let sourceX = (Float(x) + 0.5) / rx - 0.5
            let q = min(Float(boundary.rows.count - 1), max(0, sourceX - Float(boundary.left)))
            let a = Int(floor(q)), b = min(boundary.rows.count - 1, a + 1), f = q - Float(a)
            let sourceEdge = Float(boundary.rows[a]) * (1 - f) + Float(boundary.rows[b]) * f
            let edge = (sourceEdge + 0.5) * ry - 0.5
            // A nonzero analysis node contributes to the adjacent bilinear
            // cells. Its whole native basis must stay inside the unchanged
            // per-column source radius; guarding only its center would leak
            // a texel of displacement outside a curved source band.
            let basisLeft = max(boundary.left, Int(floor(sourceX - 1 / rx)))
            let basisRight = min(boundary.right, Int(ceil(sourceX + 1 / rx)))
            var minimumEdge = Float.infinity, maximumEdge = -Float.infinity
            for column in basisLeft...basisRight {
                let row = Float(boundary.rows[column - boundary.left])
                minimumEdge = min(minimumEdge, row); maximumEdge = max(maximumEdge, row)
            }
            for y in top...bottom {
                guard !protection.protects(x, y), abs(Float(y) - edge) <= Float(radius) * ry else { continue }
                let sourceY = (Float(y) + 0.5) / ry - 0.5
                let basisLow = sourceY - 1 / ry, basisHigh = sourceY + 1 / ry
                let sourceDepth = min(basisLow - (maximumEdge - Float(radius)),
                    minimumEdge + lowerRadius - basisHigh)
                guard sourceDepth > 0 else { continue }
                let sourceT = min(1, sourceDepth * ry)
                let sourceFade = sourceT * sourceT * (3 - 2 * sourceT)
                let localRadius = Float(y) <= edge ? Float(radius) : lowerRadius
                var amount = abs(shift) * ry * xWeight * coherentRamp(abs(Float(y) - edge) / (localRadius * ry))
                amount *= sourceFade
                if let i = protection.index(x, y), protection.distance[i].isFinite {
                    let d = protection.distance[i]
                    let limit = 0.42 * (sqrt(d * d + 1) - 1)
                    if limit <= 0 { continue }
                    // Smooth minimum: nonnegative C1 near the protected core,
                    // approaching the unprotected field away from the core.
                    let low = min(amount, limit), high = max(amount, limit)
                    if high > 0 { amount = low / pow(1 + pow(low / high, 16), 0.0625) }
                }
                let sample = Float(y) - direction * amount
                guard sample >= Float(top), sample < Float(bottom) else { continue }
                let y0 = Int(floor(sample)), y1 = y0 + 1
                guard !protection.protects(x, y0), !protection.protects(x, y1) else { continue }
                guard (min(y, y0)...max(y, y1)).allSatisfy({
                    !protection.protects(x, $0)
                }) else { continue }
                field[(y - top) * w + x - left] = amount
            }
        }
        // Only reduce source-fixed displacements while enforcing the actual
        // finite-difference vector bound. Protected zeros cannot be revived.
        let gradientLimit = Float(0.45) * min(rx / ry, ry / rx)
        func constrain(_ i: Int, _ a: Int, _ b: Int) {
            let dx = field[a] - field[i], dy = field[b] - field[i]
            let gradient = hypot(dx, dy)
            guard gradient > gradientLimit else { return }
            let scale = gradientLimit / gradient
            if dx > 0 { field[a] = min(field[a], field[i] + dx * scale) }
            else { field[i] = min(field[i], field[a] - dx * scale) }
            if dy > 0 { field[b] = min(field[b], field[i] + dy * scale) }
            else { field[i] = min(field[i], field[b] - dy * scale) }
        }
        for _ in 0..<64 {
            for y in 0..<h { for x in 0..<w {
                let i = y * w + x
                if x + 1 < w, y + 1 < h {
                    let a = i + 1, b = i + w, c = b + 1
                    constrain(i, a, b); constrain(a, i, c)
                    constrain(b, c, i); constrain(c, b, a)
                }
            } }
            for y in (0..<h).reversed() { for x in (0..<w).reversed() {
                let i = y * w + x
                if x + 1 < w, y + 1 < h {
                    let a = i + 1, b = i + w, c = b + 1
                    constrain(c, b, a); constrain(b, c, i)
                    constrain(a, i, c); constrain(i, a, b)
                }
            } }
        }
        var maximumGradient: Float = 0
        for y in 0..<(h - 1) { for x in 0..<(w - 1) {
            let i = y * w + x
            let topDx = field[i + 1] - field[i]
            let bottomDx = field[i + w + 1] - field[i + w]
            let leftDy = field[i + w] - field[i]
            let rightDy = field[i + w + 1] - field[i + 1]
            // All four corners bound the derivative of the bilinear field,
            // including after mapping its physical unit back to native size.
            maximumGradient = max(maximumGradient, hypot(topDx, leftDy),
                hypot(topDx, rightDy), hypot(bottomDx, leftDy), hypot(bottomDx, rightDy))
        } }
        if maximumGradient > gradientLimit {
            let scale = gradientLimit / maximumGradient
            field = field.map { $0 * scale }
        }
        func capAmount(_ x: Int, _ y: Int) -> Float {
            let xx = (Float(x) + 0.5) * rx - 0.5 - Float(left)
            let yy = (Float(y) + 0.5) * ry - 0.5 - Float(top)
            guard xx >= 0, yy >= 0, xx < Float(w - 1), yy < Float(h - 1) else { return 0 }
            let x0 = Int(floor(xx)), y0 = Int(floor(yy)), fx = xx - Float(x0), fy = yy - Float(y0)
            let a = field[y0 * w + x0] * (1 - fx) + field[y0 * w + x0 + 1] * fx
            let b = field[(y0 + 1) * w + x0] * (1 - fx) + field[(y0 + 1) * w + x0 + 1] * fx
            return min(abs(shift), (a * (1 - fy) + b * fy) / ry)
        }
        var output = source
        for y in sourceTop...sourceBottom { for x in boundary.left...boundary.right {
            let cap = capAmount(x, y), amount = cap * fraction
            guard amount > Float.ulpOfOne else { continue }
            let capSample = Float(y) - direction * cap, c0 = Int(floor(capSample)), c1 = c0 + 1
            guard c0 >= 0, c1 < height,
                  (min(y, c0)...max(y, c1)).allSatisfy({
                    source[($0 * width + x) * 4 + 3] == 255 && nativeProtection?.protects(x, $0) != true
                  }) else { continue }
            let sample = Float(y) - direction * amount, y0 = Int(floor(sample)), y1 = y0 + 1
            let dst = (y * width + x) * 4, a = (y0 * width + x) * 4, b = (y1 * width + x) * 4
            guard nativeProtection?.protects(x, y) != true,
                  nativeProtection?.protects(x, y0) != true, nativeProtection?.protects(x, y1) != true,
                  source[dst + 3] == 255, source[a + 3] == 255, source[b + 3] == 255 else { continue }
            let fraction = sample - Float(y0)
            for c in 0..<3 {
                output[dst + c] = UInt8(min(255, max(0, Int((Float(source[a + c]) +
                    (Float(source[b + c]) - Float(source[a + c])) * fraction).rounded()))))
            }
        } }
        return output
    }

    private static func detectBoundary(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Boundary? {
        let pixels = width.multipliedReportingOverflow(by: height)
        let bytes = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard width >= 128, height >= 128,
              !pixels.overflow, !bytes.overflow,
              source.count == bytes.partialValue,
              face.bounds.minX.isFinite, face.bounds.minY.isFinite,
              face.bounds.maxX.isFinite, face.bounds.maxY.isFinite,
              (0...1).contains(face.bounds.minX),
              (0...1).contains(face.bounds.minY),
              (0...1).contains(face.bounds.maxX),
              (0...1).contains(face.bounds.maxY),
              face.bounds.width > 0, face.bounds.height > 0,
              !face.faceContour.isEmpty,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return nil }

        let bounds = face.bounds
        let left = max(12, Int((bounds.midX - bounds.width * 0.25) * Float(width)))
        let right = min(width - 13, Int((bounds.midX + bounds.width * 0.25) * Float(width)))
        // A dark background-to-face edge at the crown is not a hairline.
        let firstRow = max(16, Int((bounds.minY + bounds.height * 0.02) * Float(height)))
        let lastRow = min(height - 17, Int((bounds.minY + bounds.height * 0.35) * Float(height)))
        guard right - left >= 40, lastRow - firstRow >= 20 else { return nil }

        var boundary = [Int]()
        boundary.reserveCapacity(right - left + 1)
        for x in left...right {
            guard let row = hairToSkinRow(
                source, width: width, x: x, from: firstRow, through: lastRow
            ) else {
                return detectSoftOrCoherentBoundary(source, width: width, height: height, face: face)
            }
            boundary.append(row)
        }
        guard let low = boundary.min(), let high = boundary.max(),
              high - low <= max(3, Int(bounds.height * Float(height) * 0.05))
        else { return detectSoftOrCoherentBoundary(source, width: width, height: height, face: face) }
        return Boundary(left: left, right: right, rows: boundary, high: high)
    }

    /// Distributed hair/skin transitions on an exposed arched forehead. A
    /// bangs-like center dip, sparse decoration, chromatic background, opaque
    /// alpha failure or incompatible brows abstains. This does not synthesize
    /// missing hair/skin or infer a segmented hair mask.
    private static func detectSoftBoundary(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Boundary? {
        let b = face.bounds
        let left = max(16, Int((b.midX - b.width * 0.25) * Float(width)))
        let right = min(width - 17, Int((b.midX + b.width * 0.25) * Float(width)))
        let brows = (face.observedEyebrowSupport?.left?.points ?? []) +
            (face.observedEyebrowSupport?.right?.points ?? [])
        guard brows.allSatisfy({ point in
            point.x.isFinite && point.y.isFinite &&
                (0...1).contains(point.x) && (0...1).contains(point.y)
        }), let browTop = brows.map({ Int($0.y * Float(height)) }).min(),
              right - left >= 40 else { return nil }
        let first = max(40, Int((b.minY - b.height * 0.28) * Float(height)))
        let last = min(height - 40, browTop - max(30, Int(b.height * Float(height) * 0.10)))
        guard last > first else { return nil }
        var rows = [Int]()
        for x in left...right {
            var found: Int?
            for y in first...last {
                func mean(_ range: Range<Int>, _ channel: Int) -> Double {
                    range.reduce(0.0) { $0 + Double(source[($1 * width + x) * 4 + channel]) } / Double(range.count)
                }
                let dark = mean((y-20)..<(y-5), 0)
                let light = mean((y+5)..<(y+20), 0)
                guard dark < 150, light - dark >= 32,
                      mean((y-36)..<(y-20), 0) < light - 26,
                      light > 90,
                      light - mean((y+5)..<(y+20), 2) >= 10,
                      mean((y+5)..<(y+20), 1) >= mean((y+5)..<(y+20), 2),
                      (y-36..<y+28).allSatisfy({ source[($0*width+x)*4+3] == 255 })
                else { continue }
                let upperBlue = mean((y-20)..<(y-5), 2)
                let upperGreen = mean((y-20)..<(y-5), 1)
                guard upperBlue < dark + 12, upperGreen < dark + 12 else { continue }
                // Select the maximum derivative of the distributed transition,
                // not its first threshold crossing. The source fixes this row.
                let candidates = max(first,y-4)...min(last,y+12)
                found = candidates.max { a,c in
                    mean((a+1)..<(a+5),0)-mean((a-4)..<a,0) <
                        mean((c+1)..<(c+5),0)-mean((c-4)..<c,0)
                }
                break
            }
            guard let found else { return nil }
            rows.append(found)
        }
        guard let low = rows.min(), let high = rows.max(),
              high-low <= Int(b.height * Float(height) * 0.22),
              zip(rows,rows.dropFirst()).allSatisfy({ abs($0-$1) <= 4 }) else { return nil }
        let n=rows.count, margin=max(3,n/8)
        let center=Array(rows[(n/2-margin)...(n/2+margin)])
        let sides=Array(rows.prefix(margin))+Array(rows.suffix(margin))
        let centerMean=Double(center.reduce(0,+))/Double(center.count)
        let sideMean=Double(sides.reduce(0,+))/Double(sides.count)
        guard centerMean <= sideMean + Double(b.height * Float(height) * 0.01),
              high+20 < browTop else { return nil }
        return Boundary(left:left,right:right,rows:rows,high:high,soft:true)
    }

    /// A fixed, independently sampled lower-forehead illumination field.
    /// Its source cores never depend on an edge, a graph frontier or an output.
    /// Extrapolation cannot learn a new material by accumulating local steps.
    private struct SourceIlluminationField {
        let originX: Double
        let originY: Double
        let span: Double
        let tone: SIMD3<Double>
        let dx: SIMD3<Double>
        let dy: SIMD3<Double>
        let prototype: SIMD3<Double>
        let tolerance: SIMD3<Double>
        let luminance: Double

        func prediction(_ x: Int, _ y: Int) -> SIMD3<Double> {
            tone + dx * ((Double(x) - originX) / span) +
                dy * ((Double(y) - originY) / span)
        }

        func owns(_ r: Double, _ g: Double, _ b: Double, x: Int, y: Int) -> Bool {
            let value = SIMD3(r, g, b), sum = r + g + b
            let light = (r + 2 * g + b) / 4
            guard sum > 0, r - b >= 10, g >= b, r >= g - 4,
                  light >= luminance * 0.55, light <= luminance * 1.45 else { return false }
            let color = value / sum
            // Retain the original global cold-side contradiction veto. A
            // local prediction is never permission for blue/cold material.
            guard color.x >= prototype.x - tolerance.x,
                  color.z <= prototype.z + tolerance.z else { return false }
            let expected = prediction(x, y), total = expected.x + expected.y + expected.z
            guard min(expected.x, expected.y, expected.z) > 0,
                  max(expected.x, expected.y, expected.z) <= 255, total > 0,
                  expected.x - expected.z >= 10, expected.y >= expected.z,
                  expected.x >= expected.y - 4 else { return false }
            let expectedLight = (expected.x + 2 * expected.y + expected.z) / 4
            guard expectedLight >= luminance * 0.55, expectedLight <= luminance * 1.45,
                  abs(light - expectedLight) <= max(12, expectedLight * 0.12) else { return false }
            let expectedColor = expected / total
            return abs(color.x - expectedColor.x) <= tolerance.x &&
                abs(color.y - expectedColor.y) <= tolerance.y && abs(color.z - expectedColor.z) <= tolerance.z
        }

        func residual(_ color: SIMD3<Double>, x: Int, y: Int) -> SIMD3<Double> {
            let expected = prediction(x, y)
            return color - expected / (expected.x + expected.y + expected.z)
        }
    }

    private struct ForeheadSkinSupport {
        let left: Int
        let top: Int
        let width: Int
        let height: Int
        let connected: [Bool]
        let independentlyConnected: [Bool]
        let materialEligible: [Bool]
        let graphCounts: [String: Int]
        let prototype: SIMD3<Double>
        let tolerance: SIMD3<Double>
        let luminance: Double
        let seedTone: SIMD3<Double>
        let palette: [SIMD3<Double>]
        let illumination: SourceIlluminationField?

        func ownsPhotometry(_ r: Double, _ g: Double, _ b: Double) -> Bool {
            let light = (r + 2 * g + b) / 4
            return r + g + b > 0 && r - b >= 10 && g >= b && r >= g - 4 &&
                light >= luminance * 0.55 && light <= luminance * 1.45
        }

        func belongs(_ r: Double, _ g: Double, _ b: Double) -> Bool {
            let sum = r + g + b
            guard ownsPhotometry(r, g, b) else { return false }
            let c = SIMD3(r, g, b) / sum
            return abs(c.x - prototype.x) <= tolerance.x &&
                abs(c.y - prototype.y) <= tolerance.y && abs(c.z - prototype.z) <= tolerance.z
        }

        /// A spatial shade cannot acquire a new material by repeatedly
        /// stepping through adjacent palette boxes. Keep the original cold
        /// side of the seed family, and admit a warmer deviation only when
        /// all three source channels attenuate together. A blue-only loss in
        /// golden hair is not explained by this source shading model.
        func belongsToSourceMaterial(_ r: Double, _ g: Double, _ b: Double) -> Bool {
            if belongs(r, g, b) { return true }
            guard ownsPhotometry(r, g, b) else { return false }
            let c = SIMD3(r, g, b) / (r + g + b)
            guard c.x >= prototype.x - tolerance.x,
                  c.z <= prototype.z + tolerance.z else { return false }
            let light = (r + 2 * g + b) / 4
            let scale = light / luminance
            let minimumSeed = min(seedTone.x, seedTone.y, seedTone.z)
            guard minimumSeed > 0 else { return false }
            let quantum = 2 / minimumSeed
            let ratios = SIMD3(r / seedTone.x, g / seedTone.y, b / seedTone.z)
            return scale <= 1 && max(ratios.x, ratios.y, ratios.z) <= 1 + quantum &&
                max(ratios.x, ratios.y, ratios.z) - min(ratios.x, ratios.y, ratios.z) <= 1 - scale + quantum
        }

        func reaches(_ x: Int, _ y: Int) -> Bool {
            guard x >= left, y >= top, x < left + width, y < top + height else { return false }
            return connected[(y - top) * width + x - left]
        }

        func independentlyReaches(_ x: Int, _ y: Int) -> Bool {
            guard x >= left, y >= top, x < left + width, y < top + height else { return false }
            return independentlyConnected[(y - top) * width + x - left]
        }

        func ownsMaterial(_ x: Int, _ y: Int) -> Bool {
            guard x >= left, y >= top, x < left + width, y < top + height else { return false }
            return materialEligible[(y - top) * width + x - left]
        }
    }

    /// Relative source color is anchored below the search at fresh paired
    /// brows, rather than learned from any prospective hairline. A nasal
    /// observation, when supplied, independently corroborates that prototype.
    /// The temporary graph contains source pixels only and expires here.
    private static func foreheadSkinSupport(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        left: Int, right: Int, first: Int, browTop: Int,
        onRejection: ((String) -> Void)? = nil
    ) -> ForeheadSkinSupport? {
        func reject(_ reason: String) -> ForeheadSkinSupport? { onRejection?(reason); return nil }
        guard face.freshness == .fresh,
              let leftBrow = face.observedEyebrowSupport?.left,
              let rightBrow = face.observedEyebrowSupport?.right else { return reject("faceSkinMissingFreshSupport") }
        func valid(_ p: SIMD2<Float>) -> Bool {
            p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y)
        }
        guard valid(leftBrow.innerEndpoint), valid(rightBrow.innerEndpoint),
              rightBrow.innerEndpoint.x - leftBrow.innerEndpoint.x >= face.bounds.width * 0.08 else {
            return reject("faceSkinFrameRejected")
        }
        let span = Double(face.bounds.width) * Double(width)
        let radius = max(2, Int(ceil(span * 0.012)))
        let seedY = browTop - max(radius * 2 + 1, Int(ceil(span * 0.055)))
        let innerLeft = Double(leftBrow.innerEndpoint.x) * Double(width)
        let innerRight = Double(rightBrow.innerEndpoint.x) * Double(width)
        let centers = [0.25, 0.5, 0.75].map { Int((innerLeft + (innerRight - innerLeft) * $0).rounded()) }
        let bottom = seedY + radius
        guard seedY - radius > first, bottom < browTop - 2,
              centers.allSatisfy({ $0 - radius >= left && $0 + radius <= right }) else {
            return reject("faceSkinProjectionBoundaryRejected")
        }
        var sampleRejection: String?
        func patch(_ x: Int, _ y: Int) -> [SIMD3<Double>]? {
            guard x - radius >= 0, x + radius < width, y - radius >= 0, y + radius < height else {
                sampleRejection = "faceSkinSampleBoundaryRejected"; return nil
            }
            var values = [SIMD3<Double>]()
            for yy in (y - radius)...(y + radius) { for xx in (x - radius)...(x + radius) {
                let i = (yy * width + xx) * 4
                guard source[i + 3] == 255 else { sampleRejection = "faceSkinSampleAlphaRejected"; return nil }
                values.append(SIMD3(Double(source[i]), Double(source[i + 1]), Double(source[i + 2])))
            } }
            return values
        }
        var seeds = [SIMD3<Double>]()
        for center in centers {
            guard let values = patch(center, seedY) else { return reject(sampleRejection ?? "faceSkinSampleBoundaryRejected") }
            seeds += values
        }
        func median(_ values: [Double]) -> Double { values.sorted()[values.count / 2] }
        let lights = seeds.map { ($0.x + 2 * $0.y + $0.z) / 4 }
        let luminance = median(lights)
        guard luminance >= 35, median(lights.map { abs($0 - luminance) }) <= max(12, luminance * 0.12),
              seeds.allSatisfy({ $0.x - $0.z >= 10 && $0.y >= $0.z && $0.x >= $0.y - 4 }) else {
            return reject("faceSkinSampleFamilyOrLuminanceRejected")
        }
        let colors = seeds.map { $0 / ($0.x + $0.y + $0.z) }
        let prototype = SIMD3(median(colors.map(\.x)), median(colors.map(\.y)), median(colors.map(\.z)))
        let variance = SIMD3(median(colors.map { abs($0.x - prototype.x) }),
                             median(colors.map { abs($0.y - prototype.y) }),
                             median(colors.map { abs($0.z - prototype.z) }))
        guard max(variance.x, variance.y, variance.z) <= 0.012 else { return reject("faceSkinSampleFamilyVariabilityRejected") }
        let tolerance = SIMD3(max(0.025, min(0.05, variance.x * 4 + 0.01)),
                              max(0.025, min(0.05, variance.y * 4 + 0.01)),
                              max(0.025, min(0.05, variance.z * 4 + 0.01)))
        let seedTone = SIMD3(median(seeds.map(\.x)), median(seeds.map(\.y)), median(seeds.map(\.z)))
        let provisional = ForeheadSkinSupport(left: left, top: first, width: right - left + 1,
            height: bottom - first + 1, connected: [], independentlyConnected: [], materialEligible: [], graphCounts: [:], prototype: prototype,
            tolerance: tolerance, luminance: luminance, seedTone: seedTone, palette: [prototype], illumination: nil)
        guard seeds.allSatisfy({ provisional.belongs($0.x, $0.y, $0.z) }) else { return reject("faceSkinSampleFamilyConsistencyRejected") }
        if let nasal = face.observedNoseSupport {
            guard (3...32).contains(nasal.crest.count), (3...32).contains(nasal.contour.count),
                  (nasal.crest + nasal.contour).allSatisfy({
                      $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
                  }) else { return reject("faceSkinNasalSupportRejected") }
            let upper = nasal.crest.sorted { $0.y < $1.y }[nasal.crest.count / 3]
            guard let nasalPixels = patch(Int((upper.x * Double(width)).rounded()),
                                         Int((upper.y * Double(height)).rounded())) else {
                return reject(sampleRejection ?? "faceSkinSampleBoundaryRejected")
            }
            let nasalTone = SIMD3(median(nasalPixels.map(\.x)), median(nasalPixels.map(\.y)),
                                  median(nasalPixels.map(\.z)))
            // Source-only diagnostic bins distinguish an unreliable nasal
            // patch from a clear, genuinely contradictory color family. No
            // bin relaxes the original corroboration predicate below.
            let nasalLight = (nasalTone.x + 2 * nasalTone.y + nasalTone.z) / 4
            if nasalTone.x - nasalTone.z < 10 || nasalTone.y < nasalTone.z || nasalTone.x < nasalTone.y - 4 {
                onRejection?("faceSkinNasalMedianBasicFamilyConflict")
            }
            if nasalLight < luminance * 0.55 { onRejection?("faceSkinNasalMedianTooDark") }
            if nasalLight > luminance * 1.45 { onRejection?("faceSkinNasalMedianTooBright") }
            let nasalSum = nasalTone.x + nasalTone.y + nasalTone.z
            if nasalSum > 0 {
                let nasalColor = nasalTone / nasalSum
                if abs(nasalColor.x - prototype.x) > tolerance.x { onRejection?("faceSkinNasalRedFamilyConflict") }
                if abs(nasalColor.y - prototype.y) > tolerance.y { onRejection?("faceSkinNasalGreenFamilyConflict") }
                if abs(nasalColor.z - prototype.z) > tolerance.z { onRejection?("faceSkinNasalBlueFamilyConflict") }
            }
            let nasalLights = nasalPixels.map { ($0.x + 2 * $0.y + $0.z) / 4 }
            if median(nasalLights.map { abs($0 - nasalLight) }) > max(12, nasalLight * 0.12) {
                onRejection?("faceSkinNasalLuminanceVariability")
            }
            for light in nasalLights {
                if light < luminance * 0.55 { onRejection?("faceSkinNasalDarkContributorPixels") }
                if light > luminance * 1.45 { onRejection?("faceSkinNasalHighlightContributorPixels") }
            }
            let nasalColors = nasalPixels.filter { $0.x + $0.y + $0.z > 0 }.map { $0 / ($0.x + $0.y + $0.z) }
            if !nasalColors.isEmpty {
                let center = SIMD3(median(nasalColors.map(\.x)), median(nasalColors.map(\.y)), median(nasalColors.map(\.z)))
                let spread = SIMD3(median(nasalColors.map { abs($0.x - center.x) }),
                                   median(nasalColors.map { abs($0.y - center.y) }),
                                   median(nasalColors.map { abs($0.z - center.z) }))
                if max(spread.x, spread.y, spread.z) > 0.012 { onRejection?("faceSkinNasalRelativeColorVariability") }
            }
            if nasal.contour.contains(where: {
                let dx = ($0.x - upper.x) * Double(width), dy = ($0.y - upper.y) * Double(height)
                return dx * dx + dy * dy <= Double(radius * radius * 2)
            }) { onRejection?("faceSkinNasalPatchNearObservedContour") }
            let firstCrest = nasal.crest.min { $0.y < $1.y }!
            let glabella = SIMD2((Double(leftBrow.innerEndpoint.x) + Double(rightBrow.innerEndpoint.x)) * Double(width) / 2,
                (Double(leftBrow.innerEndpoint.y) + Double(rightBrow.innerEndpoint.y)) * Double(height) / 2 + span * 0.018)
            let bridge = SIMD2(firstCrest.x * Double(width), firstCrest.y * Double(height))
            for p in [glabella, bridge, (glabella + bridge) / 2] {
                guard let values = patch(Int(p.x.rounded()), Int(p.y.rounded())) else {
                    onRejection?("faceSkinKnownBridgeSampleUnavailable")
                    return reject(sampleRejection ?? "faceSkinSampleBoundaryRejected")
                }
                let tone = SIMD3(median(values.map(\.x)), median(values.map(\.y)), median(values.map(\.z)))
                guard provisional.belongs(tone.x, tone.y, tone.z) else {
                    onRejection?("faceSkinKnownBridgeConflictingPatchCount")
                    return reject("faceSkinKnownBridgeContradictionRejected")
                }
                let light = (tone.x + 2 * tone.y + tone.z) / 4
                let localLights = values.map { ($0.x + 2 * $0.y + $0.z) / 4 }
                guard median(localLights.map { abs($0 - light) }) <= max(12, light * 0.12) else {
                    return reject("faceSkinKnownBridgeLuminanceVariabilityRejected")
                }
                let localColors = values.filter { $0.x + $0.y + $0.z > 0 }.map { $0 / ($0.x + $0.y + $0.z) }
                guard localColors.count == values.count else { return reject("faceSkinKnownBridgeContradictionRejected") }
                let localCenter = SIMD3(median(localColors.map(\.x)), median(localColors.map(\.y)), median(localColors.map(\.z)))
                let spread = SIMD3(median(localColors.map { abs($0.x - localCenter.x) }),
                                   median(localColors.map { abs($0.y - localCenter.y) }),
                                   median(localColors.map { abs($0.z - localCenter.z) }))
                guard max(spread.x, spread.y, spread.z) <= 0.012 else {
                    return reject("faceSkinKnownBridgeColorVariabilityRejected")
                }
                onRejection?("faceSkinKnownBridgeCompatiblePatchCount")
            }
            // The arbitrary single crest location may contain its own shadow
            // or highlight. It cannot override three stable, predeclared skin
            // patches that independently agree with the forehead. Retain the
            // old disagreement as a diagnostic, not new ownership evidence.
            if !provisional.belongs(nasalTone.x, nasalTone.y, nasalTone.z) {
                onRejection?("faceSkinLegacySingleNasalPatchConflict")
            }
        }
        // Additional color anchors are confined to the registered lower
        // forehead. They never come from a candidate edge or a frozen mask.
        // Each of three independent patches must be stable and agree with
        // its preceding row under the unchanged chromaticity tolerance.
        struct Anchor { let x: Int; let y: Int; let color: SIMD3<Double> }
        var anchors = [Anchor]()
        var preceding = [SIMD3<Double>]()
        for center in centers {
            let values = patch(center, seedY)!
            let tone = SIMD3(median(values.map(\.x)), median(values.map(\.y)), median(values.map(\.z)))
            preceding.append(tone)
            anchors.append(Anchor(x: center, y: seedY, color: tone / (tone.x + tone.y + tone.z)))
        }
        let ceiling = max(first + radius, Int(ceil(Double(browTop) - span * 0.18)))
        let rowStep = max(2, Int(ceil(span * 0.02)))
        var registeredRows = Array(stride(from: seedY - rowStep, through: ceiling, by: -rowStep))
        if ceiling < seedY, registeredRows.last != ceiling { registeredRows.append(ceiling) }
        for y in registeredRows {
            var rowAnchors = [Anchor](), tones = [SIMD3<Double>]()
            for (n, center) in centers.enumerated() {
                guard let values = patch(center, y) else { break }
                let tone = SIMD3(median(values.map(\.x)), median(values.map(\.y)), median(values.map(\.z)))
                guard provisional.belongsToSourceMaterial(tone.x, tone.y, tone.z) else {
                    onRejection?("faceSkinRegisteredShadeContradiction"); break
                }
                let c = tone / (tone.x + tone.y + tone.z)
                let previous = preceding[n] / (preceding[n].x + preceding[n].y + preceding[n].z)
                guard abs(c.x - previous.x) <= tolerance.x, abs(c.y - previous.y) <= tolerance.y,
                      abs(c.z - previous.z) <= tolerance.z else { break }
                let light = (tone.x + 2 * tone.y + tone.z) / 4
                let oldLight = (preceding[n].x + 2 * preceding[n].y + preceding[n].z) / 4
                guard abs(light - oldLight) <= max(12, oldLight * 0.12) else { break }
                let lights = values.map { ($0.x + 2 * $0.y + $0.z) / 4 }
                guard median(lights.map { abs($0 - light) }) <= max(12, light * 0.12) else { break }
                let normalized = values.filter { $0.x + $0.y + $0.z > 0 }.map { $0 / ($0.x + $0.y + $0.z) }
                guard normalized.count == values.count else { break }
                let spread = SIMD3(median(normalized.map { abs($0.x - c.x) }),
                                   median(normalized.map { abs($0.y - c.y) }), median(normalized.map { abs($0.z - c.z) }))
                guard max(spread.x, spread.y, spread.z) <= 0.012 else { break }
                rowAnchors.append(Anchor(x: center, y: y, color: c)); tones.append(tone)
            }
            guard rowAnchors.count == centers.count else { break }
            anchors += rowAnchors; preceding = tones
        }
        // New local shade edges need a cumulative, seed-referenced family.
        // The fixed geometry below is the same registered lower forehead;
        // three independent stable source cores corroborate every added row.
        // Cores use half the existing patch radius to measure illumination
        // within a textured patch, with unchanged alpha/family/variance gates.
        // They never depend on a prospective edge or on graph reachability.
        let coreRadius = max(1, radius / 2)
        // Cover the same fixed registered interval continuously. Reusing the
        // wider patch's row stride left gaps between these smaller cores at
        // some physical scales; a narrow legitimate shade could fall in one.
        // Centers retain the old interval; whole patch footprints stay
        // within the previous sampling envelope.
        var cumulativeRows = Array(stride(from: seedY, through: ceiling, by: -coreRadius))
        if cumulativeRows.last != ceiling { cumulativeRows.append(ceiling) }
        let cumulativeCoverageGapCount = (ceiling...seedY).filter { y in
            !cumulativeRows.contains(where: { abs($0 - y) <= coreRadius })
        }.count
        // Separate illumination proof: the same fixed ROI supplies robust
        // source-core medians. A thin protected strand may be an outlier, but
        // any stable golden/cold core invalidates this entire new route.
        // Unlike a graph-grown palette, none of these samples is chosen by a
        // prospective boundary or by successful source connectivity.
        struct IlluminationAnchor { let x: Int; let y: Int; let tone: SIMD3<Double> }
        var illuminationAnchors = [IlluminationAnchor]()
        var illuminationSupportComplete = true
        for y in cumulativeRows { for center in centers {
            guard let values = patch(center, y) else { illuminationSupportComplete = false; continue }
            var core = [SIMD3<Double>]()
            for yy in -coreRadius...coreRadius { for xx in -coreRadius...coreRadius {
                core.append(values[(yy + radius) * (radius * 2 + 1) + xx + radius])
            } }
            let tone = SIMD3(median(core.map(\.x)), median(core.map(\.y)), median(core.map(\.z)))
            let light = (tone.x + 2 * tone.y + tone.z) / 4
            guard provisional.belongsToSourceMaterial(tone.x, tone.y, tone.z),
                  median(core.map { abs(($0.x + 2 * $0.y + $0.z) / 4 - light) }) <= max(12, light * 0.12)
            else { illuminationSupportComplete = false; continue }
            let color = tone / (tone.x + tone.y + tone.z)
            let normalized = core.map { $0 / ($0.x + $0.y + $0.z) }
            let spread = SIMD3(median(normalized.map { abs($0.x - color.x) }),
                median(normalized.map { abs($0.y - color.y) }), median(normalized.map { abs($0.z - color.z) }))
            guard max(spread.x, spread.y, spread.z) <= 0.012 else {
                illuminationSupportComplete = false; continue
            }
            illuminationAnchors.append(IlluminationAnchor(x: center, y: y, tone: tone))
        } }
        func independentIllumination() -> SourceIlluminationField? {
            guard illuminationSupportComplete, illuminationAnchors.count == cumulativeRows.count * centers.count,
                  cumulativeRows.count >= 3, let low = cumulativeRows.min(), let high = cumulativeRows.max(),
                  high - low >= radius * 2 else { return nil }
            let originX = Double(centers[1]), originY = Double(seedY)
            var matrix = [[Double]](repeating: [Double](repeating: 0, count: 3), count: 3)
            var rhs = [SIMD3<Double>](repeating: .zero, count: 3)
            for anchor in illuminationAnchors {
                let q = [1.0, (Double(anchor.x) - originX) / span, (Double(anchor.y) - originY) / span]
                for i in 0..<3 {
                    rhs[i] += anchor.tone * q[i]
                    for j in 0..<3 { matrix[i][j] += q[i] * q[j] }
                }
            }
            // Three source-coordinate coefficients per RGB channel. Singular
            // or nonfinite source support never becomes a color prediction.
            for i in 0..<3 {
                guard let pivot = (i..<3).max(by: { abs(matrix[$0][i]) < abs(matrix[$1][i]) }),
                      matrix[pivot][i].isFinite, abs(matrix[pivot][i]) > 1e-10 else { return nil }
                if pivot != i { matrix.swapAt(i, pivot); rhs.swapAt(i, pivot) }
                let divisor = matrix[i][i]
                for j in i..<3 { matrix[i][j] /= divisor }; rhs[i] /= divisor
                for row in 0..<3 where row != i {
                    let amount = matrix[row][i]
                    for j in i..<3 { matrix[row][j] -= amount * matrix[i][j] }
                    rhs[row] -= rhs[i] * amount
                }
            }
            guard rhs.allSatisfy({ $0.x.isFinite && $0.y.isFinite && $0.z.isFinite }) else { return nil }
            let field = SourceIlluminationField(originX: originX, originY: originY, span: span,
                tone: rhs[0], dx: rhs[1], dy: rhs[2], prototype: prototype,
                tolerance: tolerance, luminance: luminance)
            for anchor in illuminationAnchors {
                let predicted = field.prediction(anchor.x, anchor.y), actual = anchor.tone
                guard min(predicted.x, predicted.y, predicted.z) > 0 else { return nil }
                let a = actual / (actual.x + actual.y + actual.z)
                let b = predicted / (predicted.x + predicted.y + predicted.z)
                let light = (actual.x + 2 * actual.y + actual.z) / 4
                let expectedLight = (predicted.x + 2 * predicted.y + predicted.z) / 4
                guard max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z)) <= 0.012,
                      abs(light - expectedLight) <= max(12, expectedLight * 0.12) else { return nil }
            }
            return field
        }
        let illumination = independentIllumination()
        onRejection?(illumination == nil ? "faceSkinIndependentIlluminationRejected" : "faceSkinIndependentIlluminationQualified")
        var cumulativeFamilies = [SIMD3<Double>.zero]
        for y in cumulativeRows {
            var rowColors = [SIMD3<Double>]()
            for center in centers {
                guard let values = patch(center, y) else { break }
                var core = [SIMD3<Double>]()
                for yy in -coreRadius...coreRadius { for xx in -coreRadius...coreRadius {
                    core.append(values[(yy + radius) * (radius * 2 + 1) + xx + radius])
                } }
                guard core.allSatisfy({ provisional.belongsToSourceMaterial($0.x, $0.y, $0.z) }) else { break }
                let tone = SIMD3(median(core.map(\.x)), median(core.map(\.y)), median(core.map(\.z)))
                let light = (tone.x + 2 * tone.y + tone.z) / 4
                let coreLights = core.map { ($0.x + 2 * $0.y + $0.z) / 4 }
                guard median(coreLights.map { abs($0 - light) }) <= max(12, light * 0.12) else { break }
                let c = tone / (tone.x + tone.y + tone.z)
                let normalized = core.map { $0 / ($0.x + $0.y + $0.z) }
                let spread = SIMD3(median(normalized.map { abs($0.x - c.x) }),
                    median(normalized.map { abs($0.y - c.y) }), median(normalized.map { abs($0.z - c.z) }))
                guard max(spread.x, spread.y, spread.z) <= 0.012 else { break }
                rowColors.append(c)
            }
            guard rowColors.count == centers.count else { continue }
            let center = SIMD3(median(rowColors.map(\.x)), median(rowColors.map(\.y)), median(rowColors.map(\.z)))
            guard rowColors.allSatisfy({ abs($0.x - center.x) <= tolerance.x &&
                abs($0.y - center.y) <= tolerance.y && abs($0.z - center.z) <= tolerance.z }) else { continue }
            for color in rowColors {
                let deviation = color - prototype
                if !cumulativeFamilies.contains(deviation) { cumulativeFamilies.append(deviation) }
            }
        }
        // Calibrate local chromaticity from the original source seed pixels.
        // The two-byte quantization floor stays physical; the existing .012
        // stability cap bounds a large local jump at either analysis scale.
        var seedSteps = [Double]()
        for center in centers { for y in (seedY - radius)...(seedY + radius) {
            for x in (center - radius)...(center + radius) {
                let i = (y * width + x) * 4
                let a = SIMD3(Double(source[i]), Double(source[i + 1]), Double(source[i + 2]))
                let ac = a / (a.x + a.y + a.z)
                for (xx, yy) in [(x + 1, y), (x, y + 1)] where xx <= center + radius && yy <= seedY + radius {
                    let j = (yy * width + xx) * 4
                    let b = SIMD3(Double(source[j]), Double(source[j + 1]), Double(source[j + 2]))
                    let bc = b / (b.x + b.y + b.z)
                    seedSteps.append(max(abs(ac.x - bc.x), abs(ac.y - bc.y), abs(ac.z - bc.z)))
                }
            }
        } }
        let unit = min(1, Double(512) / Double(max(width, height)))
        let quantization = 2 / median(seeds.map { $0.x + $0.y + $0.z })
        let localColorLimit = max(quantization, min(0.012 * unit, median(seedSteps) * 4 + quantization))
        let localLightLimit = max(2 / luminance, 0.12 * unit)
        let graphBottom = browTop - 2, w = right - left + 1, h = graphBottom - first + 1
        var sourceColors = [SIMD3<Double>](repeating: .zero, count: w * h)
        var sourceLights = [Double](repeating: 0, count: w * h), sourceEligible = [Bool](repeating: false, count: w * h)
        var independentlyEligible = [Bool](repeating: false, count: w * h)
        for y in first...graphBottom { for x in left...right {
            let i = (y * width + x) * 4, p = (y - first) * w + x - left
            let c = SIMD3(Double(source[i]), Double(source[i + 1]), Double(source[i + 2]))
            sourceEligible[p] = source[i + 3] == 255 && provisional.belongsToSourceMaterial(c.x, c.y, c.z)
            independentlyEligible[p] = source[i + 3] == 255 &&
                illumination?.owns(c.x, c.y, c.z, x: x, y: y) == true
            if c.x + c.y + c.z > 0 { sourceColors[p] = c / (c.x + c.y + c.z) }
            sourceLights[p] = (c.x + 2 * c.y + c.z) / 4
        } }
        var sourceGraphCounts = ["faceSkinLocallyCoupledShadeEdgeCount": 0,
            "faceSkinSourceMaterialPixelCount": sourceEligible.filter { $0 }.count,
            "faceSkinConnectedMaterialPixelCount": 0,
            "faceSkinCumulativeShadeFamilyCount": cumulativeFamilies.count,
            "faceSkinCumulativeSamplingCoverageGapCount": cumulativeCoverageGapCount,
            "faceSkinCumulativeShadeRejectedEdgeCount": 0,
            "faceSkinIndependentIlluminationEdgeCount": 0,
            "faceSkinIndependentIlluminationAnchorCount": illumination == nil ? 0 : illuminationAnchors.count,
            "faceSkinIndependentIlluminationMaterialPixelCount": independentlyEligible.filter { $0 }.count,
            "faceSkinIndependentIlluminationConnectedPixelCount": 0]
        func hasCumulativeSupport(_ i: Int, _ n: Int) -> Bool {
            for p in [i, n] {
                let deviation = sourceColors[p] - prototype
                guard cumulativeFamilies.contains(where: {
                    abs(deviation.x - $0.x) <= tolerance.x && abs(deviation.y - $0.y) <= tolerance.y &&
                        abs(deviation.z - $0.z) <= tolerance.z
                }) else { return false }
            }
            return true
        }
        func locallyCoupledShade(_ i: Int, _ n: Int) -> Bool {
            func tone(_ p: Int) -> SIMD3<Double> {
                let offset = (((p / w) + first) * width + (p % w) + left) * 4
                return SIMD3(Double(source[offset]), Double(source[offset + 1]), Double(source[offset + 2]))
            }
            let a = tone(i), b = tone(n)
            let brighter = sourceLights[i] >= sourceLights[n] ? a : b
            let darker = sourceLights[i] >= sourceLights[n] ? b : a
            let minimumChannel = min(brighter.x, brighter.y, brighter.z)
            guard minimumChannel > 0 else { return false }
            let quantum = 2 / minimumChannel
            let ratios = darker / brighter
            let lightScale = min(sourceLights[i], sourceLights[n]) / max(sourceLights[i], sourceLights[n])
            // A larger local chromaticity step needs a signed source-light
            // explanation. All channels must darken together up to the same
            // two-byte quantum used by the seed model. Equal-light opposed
            // color changes cannot bridge a disconnected source component.
            return max(ratios.x, ratios.y, ratios.z) <= 1 + quantum &&
                max(ratios.x, ratios.y, ratios.z) - min(ratios.x, ratios.y, ratios.z) <= 1 - lightScale + quantum
        }
        func graph(independent: Bool = false) -> [Bool] {
            // Proofs do not lend each other connectivity. In particular a
            // plane-supported source bridge must never connect an otherwise
            // disconnected old-family warm-brown island. Every pixel in the
            // independent path must remain owned by that same fixed plane.
            let eligible = independent ? independentlyEligible : sourceEligible
            var connected = [Bool](repeating: false, count: w * h), queue = [Int]()
            for center in centers { for y in (seedY - radius)...(seedY + radius) {
                for x in (center - radius)...(center + radius) {
                    let i = (y - first) * w + x - left
                    if eligible[i], !connected[i] { connected[i] = true; queue.append(i) }
                }
            } }
            var head = 0
            while head < queue.count {
                let i = queue[head], x = i % w, y = i / w; head += 1
                for (xx, yy) in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)] {
                    guard xx >= 0, yy >= 0, xx < w, yy < h else { continue }
                    let n = yy * w + xx
                    guard eligible[n], !connected[n] else { continue }
                    let a = sourceColors[i], b = sourceColors[n]
                    guard abs(sourceLights[i] - sourceLights[n]) <= max(sourceLights[i], sourceLights[n]) * localLightLimit else { continue }
                    if independent {
                        guard let illumination else { continue }
                        let ix = i % w + left, iy = i / w + first
                        let nx = n % w + left, ny = n / w + first
                        let ir = illumination.residual(a, x: ix, y: iy)
                        let nr = illumination.residual(b, x: nx, y: ny)
                        guard max(abs(ir.x - nr.x), abs(ir.y - nr.y), abs(ir.z - nr.z)) <= localColorLimit else { continue }
                        sourceGraphCounts["faceSkinIndependentIlluminationEdgeCount", default: 0] += 1
                    } else {
                        // The source-reference bound applies to small steps
                        // too. Area sampling can put a material transition
                        // below the two-byte local quantum; that is not a
                        // new permission to accumulate unsupported color.
                        guard hasCumulativeSupport(i, n) else {
                            sourceGraphCounts["faceSkinCumulativeShadeRejectedEdgeCount", default: 0] += 1
                            continue
                        }
                        if max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z)) > localColorLimit {
                            guard locallyCoupledShade(i, n) else { continue }
                            sourceGraphCounts["faceSkinLocallyCoupledShadeEdgeCount", default: 0] += 1
                        }
                    }
                    connected[n] = true; queue.append(n)
                }
            }
            return connected
        }
        func palette(_ anchors: [Anchor]) -> [SIMD3<Double>] {
            var result = [prototype]
            for anchor in anchors where !result.contains(anchor.color) { result.append(anchor.color) }
            return result
        }
        var registeredPalette = palette(anchors)
        let connected = graph()
        let independentlyConnected = illumination == nil
            ? [Bool](repeating: false, count: w * h) : graph(independent: true)
        sourceGraphCounts["faceSkinIndependentIlluminationConnectedPixelCount"] = independentlyConnected.filter { $0 }.count
        sourceGraphCounts["faceSkinConnectedMaterialPixelCount"] = connected.filter { $0 }.count
        while true {
            let retained = anchors.filter { anchor in
                var count = 0
                for y in (anchor.y - radius)...(anchor.y + radius) { for x in (anchor.x - radius)...(anchor.x + radius) {
                    if connected[(y - first) * w + x - left] { count += 1 }
                } }
                return count > (radius * 2 + 1) * (radius * 2 + 1) / 2
            }
            guard retained.count != anchors.count else { break }
            onRejection?("faceSkinDisconnectedRegisteredPalettePruned")
            anchors = retained; registeredPalette = palette(anchors)
        }
        for _ in registeredPalette { onRejection?("faceSkinRegisteredPaletteColorCount") }
        return ForeheadSkinSupport(left: left, top: first, width: w, height: h, connected: connected, independentlyConnected: independentlyConnected,
            materialEligible: sourceEligible, graphCounts: sourceGraphCounts,
            prototype: prototype, tolerance: tolerance, luminance: luminance,
            seedTone: seedTone, palette: registeredPalette, illumination: illumination)
    }

    /// Independent fallback: a complete source-supported curve selected from
    /// the unchanged soft photometric predicates. Sparse first crossings may
    /// be misleading, but missing columns, a competing full curve and a bangs
    /// dip never authorize interpolation or inferred hair. Head-wrap continues
    /// to reject this soft admission. All candidates expire with the request.
    private static func detectCoherentCurve(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        hasCompetingCurve: inout Bool, protectingNarrowBranches: Bool = false,
        requiringFaceSkin: Bool = false,
        onSourceCandidate: ((Int, Int, Bool, Bool, Bool) -> Void)? = nil,
        onQualification: (([String: Int]) -> Void)? = nil
    ) -> Boundary? {
        var columns = 0, missingColor = 0, missingPeak = 0, connected = 0, complete = 0, admitted = 0
        var skinPrototype = 0, skinFamilyRejected = 0, skinConnectionRejected = 0
        var seedRejections = [String: Int]()
        defer {
            var counts = ["columns": columns, "missingColorColumns": missingColor,
            "missingUnprotectedPeakColumns": missingPeak, "connectedColumns": connected,
            "completePath": complete, "admittedCurve": admitted,
            "faceSkinPrototype": skinPrototype, "faceSkinFamilyRejectedCandidates": skinFamilyRejected,
            "faceSkinConnectionRejectedCandidates": skinConnectionRejected,
            "competitionVeto": hasCompetingCurve ? 1 : 0]
            counts.merge(seedRejections, uniquingKeysWith: +)
            onQualification?(counts)
        }
        let b = face.bounds
        guard let brows = face.observedEyebrowSupport,
              let leftBrow = brows.left, let rightBrow = brows.right,
              leftBrow.side == .left, rightBrow.side == .right,
              leftBrow.points.count >= 2, rightBrow.points.count >= 2 else { return nil }
        let browSamples = leftBrow.points + rightBrow.points
        guard browSamples.allSatisfy({ $0.x.isFinite && $0.y.isFinite &&
            (0...1).contains($0.x) && (0...1).contains($0.y) }),
              let browTop = browSamples.map({ Int($0.y * Float(height)) }).min() else { return nil }
        let left = max(16, Int((b.midX - b.width * 0.25) * Float(width)))
        let right = min(width - 17, Int((b.midX + b.width * 0.25) * Float(width)))
        let first = max(40, Int((b.minY - b.height * 0.28) * Float(height)))
        let last = min(height - 40, browTop - max(30, Int(b.height * Float(height) * 0.10)))
        guard right - left >= 40, last > first else { return nil }
        columns = right - left + 1
        let skinSupport: ForeheadSkinSupport?
        if requiringFaceSkin {
            // A new ownership proof must not turn an old complete competing
            // source into permission. Preserve that original 85% veto first.
            var oldCompetition = false
            _ = detectCoherentCurve(source, width: width, height: height, face: face,
                hasCompetingCurve: &oldCompetition, protectingNarrowBranches: protectingNarrowBranches)
            if oldCompetition { hasCompetingCurve = true; return nil }
            guard let support = foreheadSkinSupport(source, width: width, height: height,
                face: face, left: left, right: right, first: first, browTop: browTop,
                onRejection: { seedRejections[$0, default: 0] += 1 }) else { return nil }
            skinSupport = support; skinPrototype = 1
            seedRejections.merge(support.graphCounts, uniquingKeysWith: +)
        } else { skinSupport = nil }
        let branchProtection = protectingNarrowBranches ? coherentBranchProtection(source, width: width,
            height: height, face: face, boundary: Boundary(left: left, right: right,
                rows: [first, last], high: last, soft: true, coherentCurve: true), radius: 0, shift: 0) : nil
        let rowCount = last - first + 1
        var scores = [[Double]]()
        scores.reserveCapacity(right - left + 1)
        for x in left...right {
            var sums = [[Double]](repeating: [Double](repeating: 0, count: height + 1), count: 3)
            var nonopaque = [Int](repeating: 0, count: height + 1)
            for y in 0..<height {
                let offset = (y * width + x) * 4
                for c in 0..<3 { sums[c][y + 1] = sums[c][y] + Double(source[offset + c]) }
                nonopaque[y + 1] = nonopaque[y] + (source[offset + 3] == 255 ? 0 : 1)
            }
            func mean(_ start: Int, _ end: Int, _ c: Int) -> Double {
                (sums[c][end] - sums[c][start]) / Double(end - start)
            }
            func gradient(_ row: Int) -> Double {
                mean(row + 1, row + 5, 0) - mean(row - 4, row, 0)
            }
            var column = [Double](repeating: -.infinity, count: rowCount)
            var colorCandidates = 0
            for y in first...last {
                // A narrow foreground branch cannot supply the gradient peak
                // for the underlying cap/skin curve. Every retained candidate
                // still satisfies all unchanged source color/alpha predicates.
                let dark = mean(y - 20, y - 5, 0), light = mean(y + 5, y + 20, 0)
                // These are exactly the old soft color/alpha conditions. The
                // new hypothesis changes curve selection, not their thresholds.
                guard dark < 150, light - dark >= 32,
                      mean(y - 36, y - 20, 0) < light - 26, light > 90,
                      light - mean(y + 5, y + 20, 2) >= 10,
                      mean(y + 5, y + 20, 1) >= mean(y + 5, y + 20, 2),
                      nonopaque[y + 28] == nonopaque[y - 36],
                      mean(y - 20, y - 5, 2) < dark + 12,
                      mean(y - 20, y - 5, 1) < dark + 12 else { continue }
                colorCandidates += 1
                let g = gradient(y)
                let localPeak = ((y - 2)...(y + 2)).map(gradient).max() ?? 0
                guard g >= max(1, (light - dark) * 0.05), g >= localPeak * 0.75 else { continue }
                let branchRejected = (y - 4..<y + 5).contains(where: { branchProtection?.protects(x, $0) == true })
                var family = true, connection = true
                if let skinSupport {
                    let green = mean(y + 5, y + 20, 1), blue = mean(y + 5, y + 20, 2)
                    let legacyFamily = skinSupport.belongsToSourceMaterial(light, green, blue)
                    let independentFamily = skinSupport.illumination?.owns(light, green, blue, x: x, y: y + 12) == true
                    if !legacyFamily { seedRejections["faceSkinLegacyFamilyRejectedCandidates", default: 0] += 1 }
                    family = legacyFamily || independentFamily
                    if independentFamily && !legacyFamily {
                        seedRejections["faceSkinIndependentIlluminationCandidateCount", default: 0] += 1
                    }
                    var skinPixels = 0, continuous = true
                    var independentPixels = 0, independentlyContinuous = true
                    for yy in (y + 5)..<(y + 20) {
                        if branchProtection?.protects(x, yy) == true { continue }
                        if skinSupport.reaches(x, yy) { skinPixels += 1 }
                        else if continuous {
                            let reason = skinSupport.ownsMaterial(x, yy)
                                ? "faceSkinBelowWindowDisconnectedMaterialCount"
                                : "faceSkinBelowWindowUnsupportedMaterialCount"
                            seedRejections[reason, default: 0] += 1
                            continuous = false
                        }
                        if skinSupport.independentlyReaches(x, yy) { independentPixels += 1 }
                        else { independentlyContinuous = false }
                    }
                    let legacyConnection = continuous && skinPixels >= 3
                    let independentConnection = independentlyContinuous && independentPixels >= 3
                    connection = (legacyFamily && legacyConnection) || (independentFamily && independentConnection)
                    if independentFamily && independentConnection {
                        seedRejections["faceSkinIndependentIlluminationConnectedCandidateCount", default: 0] += 1
                    }
                }
                // Request-local source diagnostics observe each independent
                // rejection predicate before their unchanged guard order.
                // No frozen annotation or proposed output enters this path.
                onSourceCandidate?(x, y, branchRejected, family, connection)
                if branchRejected { continue }
                if !family { skinFamilyRejected += 1; continue }
                if !connection { skinConnectionRejected += 1; continue }
                column[y - first] = g
            }
            guard let maximum = column.filter(\.isFinite).max(), maximum > 0 else {
                if colorCandidates == 0 { missingColor += 1 } else { missingPeak += 1 }
                // Keep examining columns only for an aggregate diagnostic;
                // the unchanged complete-source path can never accept a gap.
                if onQualification != nil { scores.append(column); continue }
                return nil
            }
            scores.append(column.map { $0.isFinite ? $0 / maximum : -.infinity })
        }
        struct Path {
            let rows: [Int]
            let score: Double
        }
        let separation = max(10, Int(b.height * Float(height) * 0.025))
        func select(excluding: [Int]? = nil) -> Path? {
            var previous = [Double](repeating: -.infinity, count: rowCount)
            var predecessors = [[Int]](repeating: [Int](repeating: -1, count: rowCount), count: scores.count)
            for column in scores.indices {
                var next = [Double](repeating: -.infinity, count: rowCount)
                for row in 0..<rowCount where scores[column][row].isFinite {
                    if let excluding, abs(row + first - excluding[column]) <= separation { continue }
                    if column == 0 { next[row] = scores[column][row]; continue }
                    for before in max(0, row - 4)...min(rowCount - 1, row + 4) where previous[before].isFinite {
                        let candidate = previous[before] + scores[column][row] - Double(abs(row - before)) * 0.06
                        if candidate > next[row] {
                            next[row] = candidate; predecessors[column][row] = before
                        }
                    }
                }
                guard next.contains(where: \.isFinite) else { return nil }
                if excluding == nil { connected = column + 1 }
                previous = next
            }
            guard let end = previous.indices.max(by: { previous[$0] < previous[$1] }),
                  previous[end].isFinite else { return nil }
            var selected = [Int](repeating: 0, count: scores.count), row = end
            for column in scores.indices.reversed() {
                selected[column] = row + first
                if column > 0 {
                    row = predecessors[column][row]
                    guard row >= 0 else { return nil }
                }
            }
            return Path(rows: selected, score: previous[end])
        }
        guard let selected = select() else { return nil }
        complete = 1
        guard selected.score >= Double(scores.count) * 0.55,
              let low = selected.rows.min(), let high = selected.rows.max(),
              high - low <= Int(b.height * Float(height) * 0.22), high + 20 < browTop,
              zip(selected.rows, selected.rows.dropFirst()).allSatisfy({ abs($0 - $1) <= 4 }) else { return nil }
        if let competitor = select(excluding: selected.rows), competitor.score >= selected.score * 0.85 {
            hasCompetingCurve = true
            return nil
        }
        let n = selected.rows.count, margin = max(3, n / 8)
        let center = selected.rows[(n / 2 - margin)...(n / 2 + margin)]
        let sides = Array(selected.rows.prefix(margin)) + Array(selected.rows.suffix(margin))
        let centerMean = Double(center.reduce(0, +)) / Double(center.count)
        let sideMean = Double(sides.reduce(0, +)) / Double(sides.count)
        guard centerMean <= sideMean + Double(b.height * Float(height) * 0.01) else { return nil }
        admitted = 1
        return Boundary(left: left, right: right, rows: selected.rows, high: high, soft: true, coherentCurve: true)
    }

    /// Aggregate-only diagnostic of the actual new-curve predicates. It keeps
    /// inspecting missing columns for counts but never repairs or admits them.
    static func coherentSourceQualificationCounts(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        onSourceCandidate: ((Int, Int, Bool, Bool, Bool) -> Void)? = nil
    ) -> [String: Int] {
        let pixels = width.multipliedReportingOverflow(by: height)
        let bytes = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard width >= 128, height >= 128, !pixels.overflow, !bytes.overflow,
              source.count == bytes.partialValue else { return ["invalidSource": 1] }
        let ratio = min(1, Double(960) / Double(max(width, height)))
        let aw = Int(floor(Double(width) * ratio)), ah = Int(floor(Double(height) * ratio))
        let input = ratio < 1 ? opaqueAreaAnalysis(source, width: width, height: height,
            analysisWidth: aw, analysisHeight: ah) : source
        var competing = false, counts = [String: Int]()
        _ = detectCoherentCurve(input, width: aw, height: ah, face: face,
            hasCompetingCurve: &competing, protectingNarrowBranches: true,
            requiringFaceSkin: true,
            onSourceCandidate: { x, y, branch, family, connection in
                let sx = min(width - 1, Int((Double(x) + 0.5) * Double(width) / Double(aw)))
                let sy = min(height - 1, Int((Double(y) + 0.5) * Double(height) / Double(ah)))
                onSourceCandidate?(sx, sy, branch, family, connection)
            },
            onQualification: { counts = $0 })
        counts["sourceLongEdge"] = max(width, height)
        counts["curveAnalysisLongEdge"] = max(aw, ah)
        counts["protectionFieldLongEdge"] = min(512, max(width, height))
        return counts
    }

    /// Diagnostic only. The immutable, predeclared source mask is used to
    /// measure the existing source curve and geometric planning support; it
    /// cannot participate in admission, field construction or output sampling.
    static func sourceBandPlanningAggregates(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        frozenSourceBand: [Bool]
    ) -> [String: Double] {
        let pixels = width.multipliedReportingOverflow(by: height)
        guard width > 1, height > 1, !pixels.overflow,
              frozenSourceBand.count == pixels.partialValue,
              let boundary = detectBoundary(source, width: width, height: height, face: face)
        else { return ["sourceCurveFound": 0] }
        let contour = face.observedFaceSupport?.contour ?? face.faceContour
        guard contour.allSatisfy({ $0.x.isFinite && $0.y.isFinite &&
            (0...1).contains($0.x) && (0...1).contains($0.y) }) else { return ["sourceCurveFound": 0] }
        let span = min(face.bounds.width,
            (contour.map(\.x).max() ?? 0) - (contour.map(\.x).min() ?? 0))
        let brows = (face.observedEyebrowSupport?.left?.points ?? []) +
            (face.observedEyebrowSupport?.right?.points ?? [])
        let browTop = brows.map { Int($0.y * Float(height)) }.min() ?? height
        let radius: Int
        if boundary.coherentCurve {
            radius = min(max(6, Int(span * Float(width) * 0.06)),
                max(1, Int(Float(browTop - boundary.high - 3) * 0.7)))
        } else if boundary.soft {
            radius = min(max(20, Int(face.bounds.height * Float(height) * 0.08)),
                max(1, Int(Float(browTop - boundary.high - 3) * 0.7)))
        } else { radius = max(6, min(11, Int(face.bounds.height * Float(height) * 0.032))) }
        var inside = 0, covered = 0, planning = 0, exterior = 0
        var offsetSum = 0.0, absoluteSum = 0.0, maximumOffset = 0.0
        var halfWidthSum = 0.0, upperExcessSum = 0.0, lowerExcessSum = 0.0
        for x in boundary.left...boundary.right {
            let row = boundary.rows[x - boundary.left]
            if frozenSourceBand[row * width + x] { inside += 1 }
            // Choose the largest contiguous mask interval solely from the
            // frozen source annotation, independently of the source curve.
            var first: Int?, longestFirst = 0, longestLast = -1
            for y in 0...height {
                let present = y < height && frozenSourceBand[y * width + x]
                if present { if first == nil { first = y } }
                else if let start = first {
                    if y - start > longestLast - longestFirst + 1 {
                        longestFirst = start; longestLast = y - 1
                    }
                    first = nil
                }
            }
            if longestLast >= longestFirst {
                covered += 1
                let center = Double(longestFirst + longestLast) / 2
                let halfWidth = Double(longestLast - longestFirst) / 2
                let offset = Double(row) - center
                offsetSum += offset; absoluteSum += abs(offset)
                maximumOffset = max(maximumOffset, abs(offset)); halfWidthSum += halfWidth
                upperExcessSum += max(0, Double(radius) - offset - halfWidth)
                lowerExcessSum += max(0, Double(radius) + offset - halfWidth)
            }
            for y in max(1, row - radius)...min(height - 2, row + radius) {
                planning += 1
                if !frozenSourceBand[y * width + x] { exterior += 1 }
            }
        }
        let columns = boundary.right - boundary.left + 1, count = Double(max(1, covered))
        return ["sourceCurveFound": 1, "sourceCurveIsCoherent": boundary.coherentCurve ? 1 : 0,
            "sourceCurveColumnCount": Double(columns), "sourceCurvePointsInsideFrozenBand": Double(inside),
            "sourceCurveInsideFrozenBandFraction": Double(inside) / Double(columns),
            "frozenBandCoveredSourceColumnCount": Double(covered),
            "sourceCurveMeanSignedOffsetFromFrozenBandCenterPixels": offsetSum / count,
            "sourceCurveMeanAbsoluteOffsetFromFrozenBandCenterPixels": absoluteSum / count,
            "sourceCurveMaximumAbsoluteOffsetFromFrozenBandCenterPixels": maximumOffset,
            "sourceBoundsWidthPixels": Double(face.bounds.width * Float(width)),
            "sourceContourSpanUsedPixels": Double(span * Float(width)), "productionSupportRadiusPixels": Double(radius),
            "frozenBandMeanHalfWidthPixels": halfWidthSum / count,
            "sourcePlanningSupportPixelCount": Double(planning), "sourcePlanningSupportOutsideFrozenBandPixels": Double(exterior),
            "sourcePlanningMeanUpperExcessPixels": upperExcessSum / count,
            "sourcePlanningMeanLowerExcessPixels": lowerExcessSum / count]
    }

    private static func detectSoftOrCoherentBoundary(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Boundary? {
        let legacy = detectSoftBoundary(source, width: width, height: height, face: face)
        var competing = false
        if let legacy {
            // Preserve the old soft route, including H2's original-resolution
            // competition veto. Bounded analysis never replaces its source rows.
            _ = detectCoherentCurve(source, width: width, height: height,
                face: face, hasCompetingCurve: &competing)
            return competing ? nil : legacy
        }
        let coherent = detectBoundedCoherentCurve(source, width: width, height: height,
            face: face, hasCompetingCurve: &competing)
        // A successful first-hit soft path is still ambiguous when a second
        // equally credible full source curve exists. This veto changes no old
        // color, alpha, slope or bangs threshold, nor the hard/head-wrap route.
        return competing ? nil : (legacy ?? coherent)
    }

    /// The new curve hypothesis has one bounded physical analysis scale. Its
    /// existing color, local-peak, adjacent-step and competition gates remain
    /// unchanged; native pixels are used only to recover the admitted source
    /// curve and sample the final bounded field. No analysis raster survives
    /// this request. Hard and successful legacy-soft paths never enter here.
    private static func detectBoundedCoherentCurve(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        hasCompetingCurve: inout Bool
    ) -> Boundary? {
        let longest = max(width, height)
        guard longest > 960 else {
            return detectCoherentCurve(source, width: width, height: height,
                face: face, hasCompetingCurve: &hasCompetingCurve, protectingNarrowBranches: true,
                requiringFaceSkin: true)
        }
        let scale = 960.0 / Double(longest)
        let analysisWidth = Int(floor(Double(width) * scale))
        let analysisHeight = Int(floor(Double(height) * scale))
        guard analysisWidth >= 128, analysisHeight >= 128 else { return nil }
        let analysis = opaqueAreaAnalysis(source, width: width, height: height,
            analysisWidth: analysisWidth, analysisHeight: analysisHeight)
        guard let curve = detectCoherentCurve(analysis, width: analysisWidth,
            height: analysisHeight, face: face, hasCompetingCurve: &hasCompetingCurve, protectingNarrowBranches: true,
            requiringFaceSkin: true)
        else { return nil }
        let ratioX = Double(width) / Double(analysisWidth)
        let ratioY = Double(height) / Double(analysisHeight)
        let left = max(0, Int(ceil((Double(curve.left) + 0.5) * ratioX - 0.5)))
        let right = min(width - 1, Int(floor((Double(curve.right) + 0.5) * ratioX - 0.5)))
        guard right > left else { return nil }
        let rows = (left...right).map { x -> Int in
            let q = (Double(x) + 0.5) / ratioX - 0.5 - Double(curve.left)
            let a = min(curve.rows.count - 1, max(0, Int(floor(q))))
            let b = min(curve.rows.count - 1, a + 1)
            let fraction = min(1, max(0, q - Double(a)))
            let row = Double(curve.rows[a]) * (1 - fraction) + Double(curve.rows[b]) * fraction
            return min(height - 1, max(0, Int(((row + 0.5) * ratioY - 0.5).rounded())))
        }
        guard let high = rows.max() else { return nil }
        return Boundary(left: left, right: right, rows: rows, high: high,
            soft: true, coherentCurve: true)
    }

    /// RGB uses the whole source footprint with exact area weights. A single
    /// nonopaque contributor makes the analysis texel nonopaque, even when
    /// its fractional weight is small; transparency can never average into
    /// an opaque candidate or become an invented hair/skin observation.
    private static func opaqueAreaAnalysis(
        _ source: [UInt8], width: Int, height: Int,
        analysisWidth: Int, analysisHeight: Int
    ) -> [UInt8] {
        let ratioX = Double(width) / Double(analysisWidth)
        let ratioY = Double(height) / Double(analysisHeight)
        var analysis = [UInt8](repeating: 0, count: analysisWidth * analysisHeight * 4)
        for y in 0..<analysisHeight {
            let lowY = Double(y) * ratioY, highY = Double(y + 1) * ratioY
            let firstY = max(0, Int(floor(lowY))), lastY = min(height, Int(ceil(highY)))
            for x in 0..<analysisWidth {
                let lowX = Double(x) * ratioX, highX = Double(x + 1) * ratioX
                let firstX = max(0, Int(floor(lowX))), lastX = min(width, Int(ceil(highX)))
                var sums = [Double](repeating: 0, count: 3), weight = 0.0, opaque = true
                for sy in firstY..<lastY {
                    let yWeight = max(0, min(highY, Double(sy + 1)) - max(lowY, Double(sy)))
                    for sx in firstX..<lastX {
                        let xWeight = max(0, min(highX, Double(sx + 1)) - max(lowX, Double(sx)))
                        let area = xWeight * yWeight
                        guard area > 0 else { continue }
                        let i = (sy * width + sx) * 4
                        opaque = opaque && source[i + 3] == 255
                        weight += area
                        for c in 0..<3 { sums[c] += Double(source[i + c]) * area }
                    }
                }
                guard opaque, weight > 0 else { continue }
                let i = (y * analysisWidth + x) * 4
                for c in 0..<3 { analysis[i + c] = UInt8(min(255, max(0, Int((sums[c] / weight).rounded())))) }
                analysis[i + 3] = 255
            }
        }
        return analysis
    }

    private static func hairToSkinRow(
        _ bytes: [UInt8], width: Int, x: Int, from first: Int, through last: Int
    ) -> Int? {
        for y in first...last {
            let before = red(bytes, width: width, x: x, y: y - 1)
            let after = red(bytes, width: width, x: x, y: y)
            guard after - before >= 35 else { continue }
            let darkRun = (y - 10)..<y
            let lightRun = y..<(y + 6)
            guard darkRun.allSatisfy({ red(bytes, width: width, x: x, y: $0) <= before + 16 }),
                  lightRun.allSatisfy({ red(bytes, width: width, x: x, y: $0) >= after - 16 }),
                  (y - 10..<(y + 6)).allSatisfy({
                      bytes[($0 * width + x) * 4 + 3] == 255
                  })
            else { continue }
            return y
        }
        return nil
    }

    private static func red(_ bytes: [UInt8], width: Int, x: Int, y: Int) -> Int {
        Int(bytes[(y * width + x) * 4])
    }
}
