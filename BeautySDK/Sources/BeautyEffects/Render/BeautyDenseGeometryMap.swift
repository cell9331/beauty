import BeautyCore
import BeautyDetection
import Foundation

/// A full-canvas inverse sampling lattice for dense observations. Connectivity
/// is fixed (two triangles per cell); all 478 positions inform axis density.
/// Output triangles cover the entire rectangle, including its boundary. No
/// projected 3-D face triangle is assumed to cover background/eyes/mouth.
struct BeautyDenseGeometryMap: Sendable, CustomStringConvertible, CustomReflectable {
    let xs: [Double]
    let ys: [Double]
    let offsets: [SIMD2<Double>]
    let width: Int
    let height: Int
    let appliedScale: Double
    let maximumDisplacement: Double
    let maximumGradient: Double

    init?(width: Int, height: Int, face: FaceGeometry, points: [WarpControlPoint]) {
        guard width > 1, height > 1, width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
            let dense = face.denseSupport,
            face.freshness == .fresh, dense.geometryScale > 0,
            !points.isEmpty, points.count <= 2048,
            points.allSatisfy(Self.valid)
        else { return nil }
        // Quantiles preserve overall density, but small iris structures must
        // never disappear between them. Keep all ten iris positions as knots.
        let iris = [468, 473] + MediaPipeFaceTopology.leftIris + MediaPipeFaceTopology.rightIris
        let xs = Self.axis(
            dense.mesh.points.map { Double($0.x) },
            required: iris.map { Double(dense.mesh.points[$0].x) })
        let cutoffs = Set(
            points.compactMap { $0.exclusiveMaximumY }.map {
                floor(Double($0) * Double(height)) / Double(height)
            })
        guard cutoffs.count <= 64 else { return nil }
        let ys = Self.axis(
            dense.mesh.points.map { Double($0.y) },
            required: Array(cutoffs) + iris.map { Double(dense.mesh.points[$0].y) })
        let w = Double(width)
        let h = Double(height)
        let faceSpan = min(Double(face.bounds.width) * w, Double(face.bounds.height) * h)
        guard faceSpan.isFinite, faceSpan >= 4 else { return nil }
        self.xs = xs
        self.ys = ys
        self.width = width
        self.height = height
        var deltas = [SIMD2<Double>]()
        deltas.reserveCapacity(xs.count * ys.count)
        var maximum = 0.0
        for y in ys {
            for x in xs {
                var delta = SIMD2<Double>.zero
                for point in points {
                    if let cutoff = point.exclusiveMaximumY,
                        y * h >= floor(Double(cutoff) * h)
                    {
                        continue
                    }
                    let target = SIMD2<Double>(Double(point.target.x) * w, Double(point.target.y) * h)
                    let dx = x * w - target.x
                    let dy = y * h - target.y
                    let radius = Double(point.radius) * w  // radius is a horizontal normalized span
                    let distance = hypot(dx, dy)
                    guard distance < radius else { continue }
                    let weight = pow(1 - distance / radius, Double(Int(point.falloff.rounded())))
                    delta +=
                        SIMD2<Double>(
                            Double(point.target.x - point.source.x) * w,
                            Double(point.target.y - point.source.y) * h) * weight
                }
                // A pinned canvas border avoids motion beyond the admitted
                // domain. Its derivative participates in the same safety bound.
                if x == 0 || x == 1 || y == 0 || y == 1 { delta = .zero }
                deltas.append(delta)
                maximum = max(maximum, hypot(delta.x, delta.y))
            }
        }
        var gradient = 0.0
        for row in 0..<(ys.count - 1) {
            for col in 0..<(xs.count - 1) {
                let i = row * xs.count + col
                let tl = deltas[i]
                let tr = deltas[i + 1]
                let bl = deltas[i + xs.count]
                let br = deltas[i + xs.count + 1]
                let dx = (xs[col + 1] - xs[col]) * w
                let dy = (ys[row + 1] - ys[row]) * h
                for (gx, gy) in [((tr - tl) / dx, (br - tr) / dy), ((br - bl) / dx, (bl - tl) / dy)] {
                    gradient = max(gradient, sqrt(gx.x * gx.x + gx.y * gx.y + gy.x * gy.x + gy.y * gy.y))
                }
            }
        }
        guard maximum.isFinite, gradient.isFinite, maximum > 0 else { return nil }
        // A global scalar preserves the direction/relative combination of all
        // fields. ||grad d||2 <= ||grad d||F <= .45 on EVERY triangle implies
        // singular values of I-grad d >= .55 and positive orientation. This
        // continuous piecewise-affine bound needs no binary-search assumption.
        let scale =
            min(1, faceSpan * 0.06 / maximum, gradient > 0 ? 0.45 / gradient : 1)
            * Double(dense.geometryScale)
        guard scale.isFinite, scale > 0 else { return nil }
        appliedScale = scale
        maximumDisplacement = maximum * scale
        maximumGradient = gradient * scale
        offsets = deltas.map { $0 * scale }
    }

    private static func axis(_ values: [Double], required: [Double] = []) -> [Double] {
        let sorted = values.sorted()
        var candidates = (0...16).map { Double($0) / 16 }
        for i in 0...32 { candidates.append(sorted[i * (sorted.count - 1) / 32]) }
        candidates.sort()
        var result = [0.0]
        for value in candidates where value > 0 && value < 1 {
            if value - result.last! >= 1.0 / 1024, 1 - value >= 1.0 / 1024 { result.append(value) }
        }
        result.append(1)
        // Row boundaries are contractual, never quantile-dropped/rounded.
        return Array(Set(result + required.filter { $0 > 0 && $0 < 1 })).sorted()
    }

    private static func valid(_ p: WarpControlPoint) -> Bool {
        [p.source.x, p.source.y, p.target.x, p.target.y, p.radius, p.strength, p.falloff].allSatisfy(
            \.isFinite) && (0...1).contains(p.source.x) && (0...1).contains(p.source.y)
            && (0...1).contains(p.target.x) && (0...1).contains(p.target.y) && p.radius > 0.0001
            && p.radius <= 1 && abs(p.strength) <= 1 && (1...3).contains(p.falloff)
            && (p.exclusiveMaximumY.map { $0.isFinite && (0...1).contains($0) } ?? true)
    }

    func displacement(at point: SIMD2<Double>) -> SIMD2<Double> {
        func cell(_ value: Double, _ axis: [Double]) -> Int {
            var lo = 0
            var hi = axis.count - 1
            while hi - lo > 1 {
                let mid = (lo + hi) / 2
                if value < axis[mid] { hi = mid } else { lo = mid }
            }
            return min(lo, axis.count - 2)
        }
        let col = cell(point.x, xs)
        let row = cell(point.y, ys)
        let i = row * xs.count + col
        let u = (point.x - xs[col]) / (xs[col + 1] - xs[col])
        let v = (point.y - ys[row]) / (ys[row + 1] - ys[row])
        let tl = offsets[i]
        let tr = offsets[i + 1]
        let bl = offsets[i + xs.count]
        let br = offsets[i + xs.count + 1]
        return u >= v ? tl * (1 - u) + tr * (u - v) + br * v : tl * (1 - v) + bl * (v - u) + br * u
    }

    var description: String { "BeautyDenseGeometryMap(columnCount: \(xs.count), rowCount: \(ys.count))" }
    var customMirror: Mirror { Mirror(self, children: ["columnCount": xs.count, "rowCount": ys.count]) }

    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        guard source.count == width * height * 4 else { return source }
        var output = source
        for y in 0..<height {
            for x in 0..<width {
                let point = SIMD2<Double>(
                    (Double(x) + 0.5) / Double(width), (Double(y) + 0.5) / Double(height))
                let delta = displacement(at: point)
                guard abs(delta.x) + abs(delta.y) > 1e-10 else { continue }
                let sx = min(Double(width - 1), max(0, Double(x) - delta.x))
                let sy = min(Double(height - 1), max(0, Double(y) - delta.y))
                let x0 = Int(floor(sx))
                let y0 = Int(floor(sy))
                let x1 = min(x0 + 1, width - 1)
                let y1 = min(y0 + 1, height - 1)
                let fx = sx - Double(x0)
                let fy = sy - Double(y0)
                for channel in 0..<4 {
                    let a = Double(source[(y0 * width + x0) * 4 + channel])
                    let b = Double(source[(y0 * width + x1) * 4 + channel])
                    let c = Double(source[(y1 * width + x0) * 4 + channel])
                    let d = Double(source[(y1 * width + x1) * 4 + channel])
                    let value = (a + (b - a) * fx) * (1 - fy) + (c + (d - c) * fx) * fy
                    output[(y * width + x) * 4 + channel] = UInt8(min(255, max(0, Int(value.rounded()))))
                }
            }
        }
        return output
    }
}
