import BeautyCore
import BeautyDetection
import Foundation

/// Dense still-image nasal geometry. Anatomy, displacement and sampling remain
/// request-local; both selected backends execute this same inverse map.
struct BeautyContinuousNoseMap {
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] { [
        \.noseSlim, \.noseWingSlim, \.noseTipSize, \.noseBridge,
        \.noseRootNarrowing, \.noseTipLift
    ] }

    /// A dense carrier owns this route even when its regional evidence rejects.
    /// Missing protection must never restore the old circular point pulls.
    static func replacesLegacy(for face: FaceGeometry) -> Bool { face.denseSupport != nil }

    static func isEligible(face: FaceGeometry) -> Bool {
        guard face.freshness == .fresh, let dense = face.denseSupport,
              dense.geometryScale.isFinite, dense.geometryScale > 0,
              let nose = face.observedNoseSupport,
              let left = face.leftEyeSupport, let right = face.rightEyeSupport,
              left.side == .left, right.side == .right,
              let brows = face.observedEyebrowSupport,
              let leftBrow = brows.left, let rightBrow = brows.right,
              brows.pairedEligible, let lips = face.observedOuterLips,
              (3...32).contains(nose.crest.count), (3...32).contains(nose.contour.count),
              (4...32).contains(left.contour.count), (4...32).contains(right.contour.count),
              (4...32).contains(lips.count),
              (3...16).contains(leftBrow.points.count), (3...16).contains(rightBrow.points.count),
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0 else { return false }
        let nasal = (nose.crest + nose.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        let regions = [nasal, left.contour, right.contour, lips, leftBrow.points, rightBrow.points]
        guard regions.allSatisfy({ region in
            region.allSatisfy(valid) && Set(region).count >= 3
        }), let bounds = BeautyDenseFaceSupport.bounds(nasal),
              bounds.width > 0.002, bounds.height > 0.002,
              bounds.width < face.bounds.width * 0.8,
              bounds.height < face.bounds.height * 0.8,
              nasal.allSatisfy({ p in
                  p.x >= face.bounds.minX && p.x <= face.bounds.maxX &&
                  p.y >= face.bounds.minY && p.y <= face.bounds.maxY
              }) else { return false }
        // Protect complete dense envelopes, including the lower brow boundary.
        return protectionPaths(dense).allSatisfy {
            $0.allSatisfy(valid) && BeautyDenseFaceSupport.bounds($0) != nil && Set($0).count >= 4
        }
    }

    private let xs: [Double]
    private let ys: [Double]
    private let offsets: [SIMD2<Double>]
    private let protection: [Box]
    let width: Int
    let height: Int
    let maximumGradient: Double
    let maximumDisplacement: Double

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              Self.isEligible(face: face),
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite }),
              Self.keys.contains(where: { abs(strengths[keyPath: $0]) > Float.ulpOfOne }),
              let dense = face.denseSupport, let nose = face.observedNoseSupport,
              let left = face.leftEyeSupport, let right = face.rightEyeSupport else { return nil }
        let w = Double(width), h = Double(height)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * w, Double(p.y) * h) }
        func mean(_ points: [SIMD2<Float>]) -> SIMD2<Double> {
            points.map(pixel).reduce(.zero, +) / Double(points.count)
        }
        let leftCenter = mean(left.contour), rightCenter = mean(right.contour)
        let eyeVector = rightCenter - leftCenter
        let eyeDistance = hypot(eyeVector.x, eyeVector.y)
        guard eyeDistance >= 4 else { return nil }
        let axisX = eyeVector / eyeDistance, axisY = SIMD2(-axisX.y, axisX.x)
        let origin = (leftCenter + rightCenter) * 0.5
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let q = p - origin
            return SIMD2(q.x * axisX.x + q.y * axisX.y, q.x * axisY.x + q.y * axisY.y)
        }
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
        let crest = nose.crest.map { local(SIMD2($0.x * w, $0.y * h)) }.sorted { $0.y < $1.y }
        let contour = nose.contour.map { local(SIMD2($0.x * w, $0.y * h)) }
        let all = crest + contour
        let x0 = all.map(\.x).min()!, x1 = all.map(\.x).max()!
        let rootY = crest[0].y, baseY = all.map(\.y).max()!
        let nasalWidth = x1 - x0, length = baseY - rootY
        let tip = local(pixel(SIMD2(dense.mesh.points[1].x, dense.mesh.points[1].y)))
        guard nasalWidth >= 4, length >= 4, length / nasalWidth > 0.25,
              length / nasalWidth < 5,
              tip.y > rootY + length * 0.35, tip.y <= baseY + length * 0.1,
              tip.x >= x0, tip.x <= x1,
              local(mean(face.observedOuterLips!)).y > baseY else { return nil }
        let faceSpan = min(Double(face.bounds.width) * w, Double(face.bounds.height) * h)
        guard faceSpan.isFinite, faceSpan >= 4 else { return nil }
        let boxes = Self.protectionPaths(dense).map { Box(points: $0.map(pixel), padding: 2) }
        let half = nasalWidth * 0.5
        func centerX(_ y: Double) -> Double {
            if y <= crest[0].y { return crest[0].x }
            for i in 1..<crest.count where y <= crest[i].y {
                let a = crest[i - 1], b = crest[i], gap = b.y - a.y
                return gap > 1e-9 ? a.x + (b.x - a.x) * (y - a.y) / gap : b.x
            }
            return crest.last!.x
        }
        let corners = [SIMD2(x0 - nasalWidth * 0.8, rootY - length * 0.25),
                       SIMD2(x1 + nasalWidth * 0.8, rootY - length * 0.25),
                       SIMD2(x0 - nasalWidth * 0.8, baseY + length * 0.40),
                       SIMD2(x1 + nasalWidth * 0.8, baseY + length * 0.40)].map(image)
        let minX = max(0, corners.map(\.x).min()!), maxX = min(w, corners.map(\.x).max()!)
        let minY = max(0, corners.map(\.y).min()!), maxY = min(h, corners.map(\.y).max()!)
        guard minX < maxX, minY < maxY else { return nil }
        func axis(_ lo: Double, _ hi: Double, edges: [Double]) -> [Double] {
            Array(Set((0...80).map { lo + (hi - lo) * Double($0) / 80 } +
                edges.filter { $0 > lo && $0 < hi })).sorted()
        }
        let xs = axis(minX, maxX, edges: boxes.flatMap { [$0.minX, $0.maxX] })
        let ys = axis(minY, maxY, edges: boxes.flatMap { [$0.minY, $0.maxY] })
        let caps: [Float] = [BeautySafetyCaps.noseSlim, BeautySafetyCaps.noseWingSlim,
                            BeautySafetyCaps.noseTipSize, BeautySafetyCaps.noseBridge,
                            BeautySafetyCaps.noseRootNarrowing, BeautySafetyCaps.noseTipLift]
        let values = zip(Self.keys, caps).map { min(1.0, max(-1.0, Double(strengths[keyPath: $0.0] / $0.1))) }
        func ramp(_ value: Double, _ lo: Double, _ hi: Double) -> Double {
            Self.smooth((value - lo) / (hi - lo))
        }
        // Coefficients specify source-fixed inverse coordinates. The local
        // scaling conversion makes both signs agree with their image width.
        func widthCoefficient(_ amount: Double, positive: Double, negative: Double) -> Double {
            let factor = amount >= 0 ? 1 - positive * amount : 1 - negative * amount
            return 1 - 1 / factor
        }
        func coefficients(_ values: [Double]) -> [Double] {
            [widthCoefficient(values[0], positive: 0.08, negative: 0.08),
             widthCoefficient(values[1], positive: 0.045, negative: 0.045),
             widthCoefficient(values[2], positive: 0.36, negative: 0.33),
             widthCoefficient(values[3], positive: 0.105, negative: 0.105),
             widthCoefficient(values[4], positive: 0.11, negative: 0.11),
             values[5] >= 0 ? -length * 0.038 * values[5] : -length * 0.028 * values[5],
             values[2] >= 0 ? -length * 0.004 * values[2] : -length * 0.003 * values[2]]
        }
        let actualCoefficients = coefficients(values)
        let capCoefficients = coefficients(values.map { $0 == 0 ? 0 : ($0 > 0 ? 1 : -1) })
        func field(_ p: SIMD2<Double>, coefficients c: [Double]) -> SIMD2<Double> {
            let y = (p.y - rootY) / length, x = p.x - centerX(p.y)
            let lateral = 1 - ramp(abs(x), half * 1.15, half * 2.5)
            let bottom = 1 - ramp(y, 1.02, 1.38)
            let top = ramp(y, -0.20, 0.12)
            // Size keeps the middle dorsum's response, with broader lower
            // width change. Its extra support ends before the philtrum.
            let sizeBand = ramp(y, 0.02, 0.40) * (1 + 0.75 * ramp(y, 0.40, 0.72)) *
                (1 - ramp(y, 1.0, 1.22))
            var dx = x * c[0] * sizeBand
            dx += x * c[1] * ramp(y, 0.48, 0.79)
            // Widening retains a little more of the low inner dorsum. The
            // continuation fades across the nostril-to-alar transition, so the
            // already admitted outer-wing response is not amplified with it.
            let bridgeInner = 1 - ramp(abs(x), half * 0.50, half * 0.95)
            let bridgeFade = c[3] > 0 ? 0.60 - 0.24 * bridgeInner : 0.60
            let bridgeBand = ramp(y, 0.12, 0.44) * (1 - bridgeFade * ramp(y, 0.75, 1.0))
            // Reduce lower outer-side coupling without removing the narrower
            // central/nostril continuation of the bridge.
            let bridgeSides = 1 - 0.55 * ramp(y, 0.40, 0.75) *
                ramp(abs(x), half * 0.50, half)
            dx += x * c[3] * bridgeBand * bridgeSides
            let rootBand = (1 - ramp(y, 0.12, 0.30)) *
                exp(-pow(x / (nasalWidth * 0.45), 4))
            dx += x * c[4] * rootBand
            var dy = c[5] * ramp(y, 0.05, 0.70) * (1 - 0.18 * ramp(y, 0.87, 1.03))
            // The bulb is above the nostril/base: strong local width control
            // fades laterally before the outer alae and gently below the tip.
            let bulbY = tip.y - length * 0.09
            let bx = p.x - tip.x
            let by = (p.y - bulbY) / length
            // The bulb and nostril transitions have different signed spans.
            // A softer positive lateral shoulder avoids spending its gradient
            // budget on an abrupt reversal at the edge of the bulb. Its wider
            // support starts fading lower down slightly earlier to keep the
            // stronger bulb change from amplifying the nostril displacement.
            let tipWidth = c[2] < 0 ? 0.33 : 0.285
            var horizontal = exp(-pow(abs(bx) / (nasalWidth * tipWidth), c[2] < 0 ? 3 : 4))
            if c[2] < 0 {
                // Taper only the lower outside shoulder. The bulb's core and
                // upper span retain their wider support, while the tail does
                // not pull the alar edge along with the tip.
                horizontal *= 1 - 0.90 * ramp(abs(bx), nasalWidth * 0.35, nasalWidth * 0.50) *
                    ramp(by, -0.10, 0.02)
                // Shape the upper bulb's shoulders without increasing its
                // central slope or extending the field into the nostrils.
                horizontal *= 1 + 0.12 * ramp(abs(bx), nasalWidth * 0.075, nasalWidth * 0.20) *
                    (1 - ramp(abs(bx), nasalWidth * 0.28, nasalWidth * 0.42)) *
                    (1 - ramp(by, -0.15, -0.05))
            }
            let tipBottom = c[2] < 0 ? 1 - ramp(by, -0.06, 0.12) : 1 - ramp(by, -0.02, 0.16)
            let vertical = ramp(by, -0.45, -0.22) * tipBottom
            dx += bx * c[2] * horizontal * vertical
            dy += c[6] * exp(-pow(bx / (nasalWidth * 0.25), 4)) * ramp(y, 0.65, 0.90)
            return (axisX * dx + axisY * dy) * (lateral * bottom * top)
        }
        var offsets = [SIMD2<Double>](), ceiling = [SIMD2<Double>]()
        var locations = [SIMD2<Double>](), weights = [Double]()
        offsets.reserveCapacity(xs.count * ys.count)
        ceiling.reserveCapacity(xs.count * ys.count)
        locations.reserveCapacity(xs.count * ys.count)
        weights.reserveCapacity(xs.count * ys.count)
        for y in ys { for x in xs {
            var weight = 1.0
            for b in boxes { weight *= Self.smooth(b.distance(x: x, y: y) / (nasalWidth * 0.10)) }
            if x == minX || x == maxX || y == minY || y == maxY { weight = 0 }
            let point = local(SIMD2(x, y))
            locations.append(point); weights.append(weight)
            offsets.append(field(point, coefficients: actualCoefficients) * weight)
            ceiling.append(field(point, coefficients: capCoefficients) * weight)
        } }
        var gradient = Self.gradient(offsets, xs: xs, ys: ys)
        var magnitude = offsets.map { hypot($0.x, $0.y) }.max() ?? 0
        let capGradient = Self.gradient(ceiling, xs: xs, ys: ys)
        let capMagnitude = ceiling.map { hypot($0.x, $0.y) }.max() ?? 0
        guard gradient.isFinite, magnitude.isFinite, capGradient.isFinite,
              capMagnitude.isFinite, magnitude > 0 else { return nil }
        // Reserve the active signs' full-strength shape before scaling. A
        // changing gradient quota would otherwise flatten the slider's upper
        // half. Actual combined geometry is still checked independently.
        let admittedGradient = max(gradient, capGradient)
        var scale = min(1, admittedGradient > 0 ? 0.45 / admittedGradient : 1,
                        faceSpan * 0.06 / max(magnitude, capMagnitude)) * Double(dense.geometryScale)
        let active = values.indices.filter { values[$0] != 0 }
        if active.count > 1 {
            // Reserve each field's cap independently before composing actual
            // strengths. A newly nonzero sibling must not suddenly reserve its
            // full cap against every field already on screen.
            var combined = [SIMD2<Double>](repeating: .zero, count: offsets.count)
            for index in active {
                var isolated = [Double](repeating: 0, count: values.count)
                isolated[index] = values[index]
                let actual = coefficients(isolated)
                isolated[index] = values[index] > 0 ? 1 : -1
                let cap = coefficients(isolated)
                var a = [SIMD2<Double>](), b = [SIMD2<Double>]()
                a.reserveCapacity(locations.count); b.reserveCapacity(locations.count)
                for i in locations.indices {
                    a.append(field(locations[i], coefficients: actual) * weights[i])
                    b.append(field(locations[i], coefficients: cap) * weights[i])
                }
                let g = max(Self.gradient(a, xs: xs, ys: ys), Self.gradient(b, xs: xs, ys: ys))
                let m = max(a.map { hypot($0.x, $0.y) }.max() ?? 0,
                            b.map { hypot($0.x, $0.y) }.max() ?? 0)
                guard g.isFinite, m.isFinite else { return nil }
                let fieldScale = min(1, g > 0 ? 0.45 / g : 1, m > 0 ? faceSpan * 0.06 / m : 1)
                for i in combined.indices { combined[i] += a[i] * fieldScale }
            }
            offsets = combined
            gradient = Self.gradient(offsets, xs: xs, ys: ys)
            magnitude = offsets.map { hypot($0.x, $0.y) }.max() ?? 0
            guard gradient.isFinite, magnitude.isFinite else { return nil }
            scale = min(1, gradient > 0 ? 0.45 / gradient : 1,
                        magnitude > 0 ? faceSpan * 0.06 / magnitude : 1) * Double(dense.geometryScale)
        }
        guard scale.isFinite, scale > 0 else { return nil }
        self.xs = xs; self.ys = ys; self.width = width; self.height = height
        self.protection = boxes
        self.offsets = offsets.map { $0 * scale }
        maximumGradient = gradient * scale
        maximumDisplacement = magnitude * scale
    }

    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        guard source.count == width * height * 4 else { return source }
        var output = source
        var row = 0
        for y in max(0, Int(ys[0]))..<min(height, Int(ceil(ys.last!))) {
            let py = Double(y) + 0.5
            guard py >= ys[0], py < ys.last! else { continue }
            while row + 1 < ys.count - 1 && py >= ys[row + 1] { row += 1 }
            let fy = (py - ys[row]) / (ys[row + 1] - ys[row])
            var col = 0
            for x in max(0, Int(xs[0]))..<min(width, Int(ceil(xs.last!))) {
                let px = Double(x) + 0.5
                guard px >= xs[0], px < xs.last!, !protection.contains(where: { $0.contains(x: px, y: py) }) else { continue }
                while col + 1 < xs.count - 1 && px >= xs[col + 1] { col += 1 }
                let fx = (px - xs[col]) / (xs[col + 1] - xs[col]), i = row * xs.count + col
                let top = offsets[i] * (1 - fx) + offsets[i + 1] * fx
                let bottom = offsets[i + xs.count] * (1 - fx) + offsets[i + xs.count + 1] * fx
                let d = top * (1 - fy) + bottom * fy
                guard abs(d.x) + abs(d.y) > 1e-10 else { continue }
                let sx = min(Double(width - 1), max(0, Double(x) - d.x))
                let sy = min(Double(height - 1), max(0, Double(y) - d.y))
                let x0 = Int(floor(sx)), y0 = Int(floor(sy)), x1 = min(x0 + 1, width - 1), y1 = min(y0 + 1, height - 1)
                let indices = [(y0 * width + x0) * 4, (y0 * width + x1) * 4,
                               (y1 * width + x0) * 4, (y1 * width + x1) * 4]
                let dst = (y * width + x) * 4, alpha = source[dst + 3]
                guard indices.allSatisfy({ source[$0 + 3] == alpha }) else { continue }
                let ax = sx - Double(x0), ay = sy - Double(y0)
                for channel in 0..<3 {
                    let a = Double(source[indices[0] + channel]), b = Double(source[indices[1] + channel])
                    let c = Double(source[indices[2] + channel]), e = Double(source[indices[3] + channel])
                    let value = (a + (b - a) * ax) * (1 - ay) + (c + (e - c) * ax) * ay
                    output[dst + channel] = UInt8(min(255, max(0, Int(value.rounded()))))
                }
            }
        }
        return output
    }

    private static func valid(_ p: SIMD2<Float>) -> Bool {
        p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y)
    }
    private static func smooth(_ value: Double) -> Double {
        let v = min(1, max(0, value)); return v * v * (3 - 2 * v)
    }
    private static func protectionPaths(_ dense: BeautyDenseFaceSupport) -> [[SIMD2<Float>]] {
        [MediaPipeFaceTopology.leftEye, MediaPipeFaceTopology.rightEye,
         MediaPipeFaceTopology.leftBrowEnvelope, MediaPipeFaceTopology.rightBrowEnvelope,
         MediaPipeFaceTopology.outerLip].map { BeautyDenseFaceSupport.path(dense.mesh, $0) }
    }
    private static func gradient(_ deltas: [SIMD2<Double>], xs: [Double], ys: [Double]) -> Double {
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
    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        init(points: [SIMD2<Double>], padding: Double) {
            minX = points.map(\.x).min()! - padding; maxX = points.map(\.x).max()! + padding
            minY = points.map(\.y).min()! - padding; maxY = points.map(\.y).max()! + padding
        }
        func contains(x: Double, y: Double) -> Bool { x >= minX && x <= maxX && y >= minY && y <= maxY }
        func distance(x: Double, y: Double) -> Double { hypot(max(minX - x, 0, x - maxX), max(minY - y, 0, y - maxY)) }
    }
}

extension BeautyContinuousNoseMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyContinuousNoseMap(width: \(width), height: \(height), nodeCount: \(offsets.count))" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["width": width, "height": height, "nodeCount": offsets.count]) }
}
