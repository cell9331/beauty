import BeautyCore
import Foundation

/// An internal, request-local source-geometry candidate. This tube does not
/// identify ears, hair or background. Its caller must independently establish
/// permanent semantic exclusions and must not enable it as a default route.
struct BeautyContourTransitionScope: Sendable {
    let width: Int
    let height: Int
    let radius: Double
    /// Total tube width divided by the supplied source face span.
    let normalizedWidth: Double

    private struct Segment: Hashable, Sendable {
        let start: SIMD2<Double>
        let end: SIMD2<Double>
    }
    private let contour: [SIMD2<Double>]
    private let eligibleSegments: [Segment]

    init?(width: Int, height: Int, contour: [SIMD2<Double>],
          origin: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>,
          span: Double, chin: Double, lowerBound: Double) {
        func finite(_ p: SIMD2<Double>) -> Bool { p.x.isFinite && p.y.isFinite }
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              (7...32).contains(contour.count), Set(contour).count == contour.count,
              contour.allSatisfy({ finite($0) && $0.x >= 0 && $0.y >= 0 &&
                  $0.x <= Double(width) && $0.y <= Double(height) }),
              finite(origin), origin.x >= 0, origin.y >= 0,
              origin.x <= Double(width), origin.y <= Double(height),
              finite(axisX), finite(axisY),
              abs(hypot(axisX.x, axisX.y) - 1) <= 0.000_001,
              abs(hypot(axisY.x, axisY.y) - 1) <= 0.000_001,
              abs(axisX.x * axisY.x + axisX.y * axisY.y) <= 0.000_001,
              axisX.x * axisY.y - axisX.y * axisY.x > 0,
              span.isFinite, span > 0, span <= Double(max(width, height)) * 1.5,
              chin.isFinite, chin > 0, chin <= Double(max(width, height)) * 1.5,
              lowerBound.isFinite else { return nil }
        let upperBound = 0.70 * chin
        let radius = min(0.06 * span, 48 * Double(max(width, height)) / 1920)
        guard radius > 3, upperBound > lowerBound else { return nil }
        func localY(_ p: SIMD2<Double>) -> Double {
            let q = p - origin
            return q.x * axisY.x + q.y * axisY.y
        }
        var eligible = [Segment](), seen = Set<Segment>()
        // Clip EACH original segment independently. Flattening the resulting
        // points would incorrectly bridge the two sides across the cut jaw.
        for (a, b) in zip(contour, contour.dropFirst()) {
            let ya = localY(a), yb = localY(b), dy = yb - ya
            var start = 0.0, end = 1.0
            if dy == 0 {
                guard ya >= lowerBound, ya <= upperBound else { continue }
            } else {
                let first = (lowerBound - ya) / dy, last = (upperBound - ya) / dy
                start = max(0, min(first, last)); end = min(1, max(first, last))
            }
            guard start.isFinite, end.isFinite, end > start else { continue }
            let p = a + (b - a) * start, q = a + (b - a) * end
            guard finite(p), finite(q), p != q else { return nil }
            let forward = p.x < q.x || (p.x == q.x && p.y < q.y)
            let segment = Segment(start: forward ? p : q, end: forward ? q : p)
            guard seen.insert(segment).inserted else { return nil }
            eligible.append(segment)
        }
        guard !eligible.isEmpty else { return nil }
        self.width = width; self.height = height; self.radius = radius
        normalizedWidth = 2 * radius / span
        self.contour = contour; eligibleSegments = eligible
    }

    /// Exact source identity only; other frame parameters remain the caller's
    /// request-local construction responsibility.
    func matches(width: Int, height: Int, contour: [SIMD2<Double>]) -> Bool {
        self.width == width && self.height == height && self.contour == contour
    }

    /// Upright pixel indices. The centre must retain the whole conservative
    /// three-pixel source collar, not merely lie in the mathematical tube.
    func allowsDestination(x: Int, y: Int) -> Bool {
        guard x >= 0, y >= 0, x < width, y < height else { return false }
        return distanceToFixed(x: Double(x) + 0.5, y: Double(y) + 0.5) > 0
    }

    /// Source pixel centres are n + .5. Require all four interpolation texels,
    /// including zero-weight neighbours, without clamping a footprint inward.
    func allowsSourceFootprint(x: Double, y: Double) -> Bool {
        guard x.isFinite, y.isFinite else { return false }
        let px = x - 0.5, py = y - 0.5
        guard px >= 0, py >= 0, px < Double(width - 1), py < Double(height - 1) else { return false }
        let ix = Int(floor(px)), iy = Int(floor(py))
        return allowsDestination(x: ix, y: iy) && allowsDestination(x: ix + 1, y: iy)
            && allowsDestination(x: ix, y: iy + 1) && allowsDestination(x: ix + 1, y: iy + 1)
    }

    /// Conservative distance to the fixed tube/canvas material. Arc endpoints
    /// have natural round caps; the source clipping slab is not a query cut.
    /// The caller applies its C1 attenuation BEFORE constraining the final
    /// displacement gradient and sampling.
    func distanceToFixed(x: Double, y: Double) -> Double {
        guard x.isFinite, y.isFinite, x >= 0, y >= 0,
              x <= Double(width), y <= Double(height) else { return 0 }
        let p = SIMD2(x, y)
        let canvasMargin = min(x, y, Double(width) - x, Double(height) - y)
        guard canvasMargin > 3 else { return 0 }
        var squared = Double.infinity
        for segment in eligibleSegments {
            let a = segment.start, b = segment.end
            let d = b - a, q = p - a, length = d.x * d.x + d.y * d.y
            let t = length > 0 ? min(1, max(0, (q.x * d.x + q.y * d.y) / length)) : 0
            let residual = q - d * t
            squared = min(squared, residual.x * residual.x + residual.y * residual.y)
        }
        return max(0, min(radius - sqrt(squared), canvasMargin) - 3)
    }
}

extension BeautyContourTransitionScope: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String {
        "BeautyContourTransitionScope(width: \(width), height: \(height), pointCount: \(contour.count), radius: \(radius), normalizedWidth: \(normalizedWidth))"
    }
    var debugDescription: String { description }
    var customMirror: Mirror {
        let fields: KeyValuePairs<String, Any> = ["width": width, "height": height,
            "pointCount": contour.count, "radius": radius, "normalizedWidth": normalizedWidth]
        return Mirror(self, children: fields)
    }
}
