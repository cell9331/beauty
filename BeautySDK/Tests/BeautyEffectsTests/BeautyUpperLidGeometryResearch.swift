import BeautyCore
import CryptoKit
import Foundation

/// TEST TARGET ONLY. Exact straight-source-frame special case of the proposed
/// superior bump. No curved projection, automatic tissue owner, neutral/slider
/// mapping, production calibration or effect qualification is supplied here.
enum BeautyUpperLidGeometryResearch {
    struct Point: Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let x: Double, y: Double
        var description: String { "UpperLidResearch.Point(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }
    enum Side: Sendable, Hashable { case left, right }
    enum Region: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        case rectangle(minX: Double, minY: Double, maxX: Double, maxY: Double)
        case ellipse(center: Point, radiusX: Double, radiusY: Double)
        var description: String { "UpperLidResearch.Region(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }
    struct Calibration: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let side: Side
        let center: Point
        let axisX: Point
        /// Explicit SOURCE superior direction, not an assumed negative screen-y.
        let superiorAxis: Point
        let supportRadiusX: Double, supportRadiusY: Double
        let amplitudePixels: Double
        let ownedSourceDomain: Region
        let protectedRegions: [Region]
        var description: String { "UpperLidResearch.Calibration(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }
    struct SolverPolicy: Sendable {
        let maximumIterations: Int
        let residualTolerancePixels: Double
    }
    struct SourceBinding: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        fileprivate let width: Int, height: Int
        fileprivate let digest: SHA256.Digest
        static func bind(sourceRGBA: [UInt8], width: Int, height: Int) -> Self {
            Self(width: width, height: height, digest: SHA256.hash(data: Data(sourceRGBA)))
        }
        var description: String { "UpperLidResearch.SourceBinding(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }
    /// Pixel centers are integer-indexed, with x rightward and y downward.
    /// progress is from the supplied source toward this candidate, in [0,1].
    /// Every calibration and solver quantity is explicit; there are no defaults.
    struct Request: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let sourceRGBA: [UInt8]
        let width: Int, height: Int
        let sourceBinding: SourceBinding
        let calibrations: [Calibration]
        let progress: Double
        let solverPolicy: SolverPolicy
        var description: String { "UpperLidResearch.Request(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }
    enum RefusalReason: String, Sendable, Hashable {
        case invalidImage, sourceMismatch, nonOpaqueInput, invalidProgress, invalidSolverPolicy, invalidCount
        case invalidCalibration, unsafeContraction, duplicateSide, overlappingSupport, protectedSupport
        case emptySupport, unownedSource, nonOpaqueSource, sourceFootprintOutOfBounds, inverseDidNotConverge
    }
    enum Status: Sendable, Equatable { case unchanged, applied, refused, partiallyApplied }
    struct Result: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let rgba: [UInt8]
        let status: Status
        let appliedRegionCount: Int, refusedRegionCount: Int
        let refusalCounts: [RefusalReason: Int]
        var description: String { "UpperLidResearch.Result(status: \(status), applied: \(appliedRegionCount), refused: \(refusedRegionCount))" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }
    struct Derivative { let xx: Double, xy: Double, yx: Double, yy: Double }
    private struct Box {
        let minX: Double, minY: Double, maxX: Double, maxY: Double
        func intersects(_ b: Box) -> Bool {
            minX <= b.maxX && b.minX <= maxX && minY <= b.maxY && b.minY <= maxY
        }
    }

    // B and B' vanish at their compact boundary. The constant source normal has
    // ∇n=0 only in this straight-frame special case. Protection is a whole-support
    // admission constraint, never an unaccounted spatial multiplier of the field.
    private static func bump(_ t: Double) -> (value: Double, derivative: Double) {
        guard abs(t) < 1 else { return (0, 0) }
        let k = 1 - t * t
        return (k * k, -4 * t * k)
    }
    private static func local(_ p: Point, _ c: Calibration) -> Point {
        let x = p.x - c.center.x, y = p.y - c.center.y
        return Point(x: x * c.axisX.x + y * c.axisX.y,
                     y: x * c.superiorAxis.x + y * c.superiorAxis.y)
    }
    private static func displacement(_ p: Point, _ c: Calibration, _ progress: Double) -> Point {
        let v = local(p, c)
        let w = bump(v.x / c.supportRadiusX).value * bump(v.y / c.supportRadiusY).value
        let a = progress * c.amplitudePixels * w
        return Point(x: a * c.superiorAxis.x, y: a * c.superiorAxis.y)
    }
    static func forwardPoint(_ p: Point, calibration c: Calibration, progress: Double) -> Point? {
        guard validPoint(p), validCalibration(c), validProgress(progress) else { return nil }
        let d = displacement(p, c, progress), q = Point(x: p.x + d.x, y: p.y + d.y)
        return validPoint(q) ? q : nil
    }
    static func displacementDerivative(at p: Point, calibration c: Calibration, progress: Double) -> Derivative? {
        guard validPoint(p), validCalibration(c), validProgress(progress) else { return nil }
        let v = local(p, c), bx = bump(v.x / c.supportRadiusX), by = bump(v.y / c.supportRadiusY)
        let gx = bx.derivative * by.value / c.supportRadiusX
        let gy = bx.value * by.derivative / c.supportRadiusY
        let wx = gx * c.axisX.x + gy * c.superiorAxis.x
        let wy = gx * c.axisX.y + gy * c.superiorAxis.y
        let a = progress * c.amplitudePixels
        return Derivative(xx: a * c.superiorAxis.x * wx, xy: a * c.superiorAxis.x * wy,
                          yx: a * c.superiorAxis.y * wx, yy: a * c.superiorAxis.y * wy)
    }
    /// Sufficient GLOBAL bound: a*t*||superior||*M*
    /// (||axisX||/rx+||superior||/ry), M=max|B'|=8/(3sqrt(3)).
    /// Exact supplied axes are retained, including admitted numerical deviations.
    /// Every positive operation is rounded outward; strict bound<1 certifies a
    /// global contraction inverse. This bound is not a measured feature cap.
    static func contractionBound(calibration c: Calibration, progress: Double) -> Double? {
        guard validCalibration(c), validProgress(progress) else { return nil }
        if progress == 0 || c.amplitudePixels == 0 { return 0 }
        let nx = upperNorm(abs(c.axisX.x), abs(c.axisX.y))
        let ns = upperNorm(abs(c.superiorAxis.x), abs(c.superiorAxis.y))
        let sqrt3Lower = 3.0.squareRoot().nextDown
        let denominatorLower = (3 * sqrt3Lower).nextDown
        let m = upperDivide(8, denominatorLower)
        let spatial = upperAdd(upperDivide(nx, c.supportRadiusX), upperDivide(ns, c.supportRadiusY))
        let bound = upperMultiply(upperMultiply(upperMultiply(upperMultiply(c.amplitudePixels, progress), ns), m), spatial)
        return bound.isFinite ? bound : nil
    }
    static func inversePoint(_ q: Point, calibration c: Calibration, progress: Double, solverPolicy: SolverPolicy) -> Point? {
        guard validPoint(q), validPolicy(solverPolicy),
              let bound = contractionBound(calibration: c, progress: progress), bound < 1 else { return nil }
        return inverse(q, c, progress, solverPolicy)
    }
    private static func inverse(_ q: Point, _ c: Calibration, _ progress: Double, _ policy: SolverPolicy) -> Point? {
        var p = q
        for _ in 0..<policy.maximumIterations {
            let d = displacement(p, c, progress)
            p = Point(x: q.x - d.x, y: q.y - d.y)
            guard validPoint(p) else { return nil }
            let check = displacement(p, c, progress)
            let residual = hypot(p.x + check.x - q.x, p.y + check.y - q.y)
            if residual.isFinite && residual <= policy.residualTolerancePixels { return p }
        }
        return nil
    }
    static func render(_ request: Request) -> Result {
        render(request, sourceRGBA: request.sourceRGBA, width: request.width, height: request.height)
    }
    /// Always validate the actual raster. A stale request returns that actual
    /// raster unchanged with refusal, never its retained older source image.
    static func render(_ r: Request, sourceRGBA source: [UInt8], width: Int, height: Int) -> Result {
        func refuse(_ reason: RefusalReason) -> Result {
            let count = max(1, r.calibrations.count)
            return Result(rgba: source, status: .refused, appliedRegionCount: 0,
                          refusedRegionCount: count, refusalCounts: [reason: count])
        }
        guard width > 1, height > 1, width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              width * height <= Int.max / 4, source.count == width * height * 4 else { return refuse(.invalidImage) }
        guard r.width == width, r.height == height, r.sourceBinding.width == width, r.sourceBinding.height == height,
              r.sourceBinding.digest == SHA256.hash(data: Data(source)) else { return refuse(.sourceMismatch) }
        // Preserve the retained direct-retouch input FORMAT contract: the entire
        // input must be exactly opaque. Transparency is a whole-request refusal,
        // including zero progress, never flattening or a successful no-op.
        guard stride(from: 3, to: source.count, by: 4).allSatisfy({ source[$0] == 255 })
        else { return refuse(.nonOpaqueInput) }
        guard validProgress(r.progress) else { return refuse(.invalidProgress) }
        guard validPolicy(r.solverPolicy) else { return refuse(.invalidSolverPolicy) }
        guard (1...2).contains(r.calibrations.count) else { return refuse(.invalidCount) }
        var reasons = [Int: RefusalReason](), boxes = [Int: Box]()
        for (index, c) in r.calibrations.enumerated() {
            guard validCalibration(c), let box = supportBox(c), regionBox(c.ownedSourceDomain) != nil,
                  c.protectedRegions.allSatisfy({ regionBox($0) != nil }) else { reasons[index] = .invalidCalibration; continue }
            guard let bound = contractionBound(calibration: c, progress: r.progress), bound < 1
            else { reasons[index] = .unsafeContraction; continue }
            boxes[index] = box
            if c.protectedRegions.contains(where: { box.intersects(regionBox($0)!) }) { reasons[index] = .protectedSupport }
        }
        if r.calibrations.count == 2 {
            if r.calibrations[0].side == r.calibrations[1].side { reasons[0] = .duplicateSide; reasons[1] = .duplicateSide }
            else if let a = boxes[0], let b = boxes[1], a.intersects(b) {
                reasons[0] = .overlappingSupport; reasons[1] = .overlappingSupport
            }
        }
        var output = source, applied = 0
        for (index, c) in r.calibrations.enumerated() where reasons[index] == nil {
            guard let box = boxes[index], box.maxX >= 0, box.maxY >= 0,
                  box.minX <= Double(width - 1), box.minY <= Double(height - 1) else { reasons[index] = .emptySupport; continue }
            if r.progress == 0 || c.amplitudePixels == 0 { continue }
            let minX = Int(max(0, box.minX).rounded(.up)), maxX = Int(min(Double(width - 1), box.maxX).rounded(.down))
            let minY = Int(max(0, box.minY).rounded(.up)), maxY = Int(min(Double(height - 1), box.maxY).rounded(.down))
            guard minX <= maxX, minY <= maxY else { reasons[index] = .emptySupport; continue }
            var candidate = output, moved = false
            scan: for y in minY...maxY { for x in minX...maxX {
                let q = Point(x: Double(x), y: Double(y)), d = displacement(q, c, r.progress)
                if d.x == 0 && d.y == 0 { continue }
                let destination = (y * width + x) * 4
                guard contains(q, c.ownedSourceDomain) else { reasons[index] = .unownedSource; break scan }
                guard source[destination + 3] == 255 else { reasons[index] = .nonOpaqueSource; break scan }
                guard let p = inverse(q, c, r.progress, r.solverPolicy) else { reasons[index] = .inverseDidNotConverge; break scan }
                guard p.x >= 0, p.y >= 0, p.x < Double(width - 1), p.y < Double(height - 1)
                else { reasons[index] = .sourceFootprintOutOfBounds; break scan }
                let sx = Int(floor(p.x)), sy = Int(floor(p.y))
                let taps = [Point(x: Double(sx), y: Double(sy)), Point(x: Double(sx + 1), y: Double(sy)),
                            Point(x: Double(sx), y: Double(sy + 1)), Point(x: Double(sx + 1), y: Double(sy + 1))]
                guard taps.allSatisfy({ contains($0, c.ownedSourceDomain) }) else { reasons[index] = .unownedSource; break scan }
                let offsets = [(sy * width + sx) * 4, (sy * width + sx + 1) * 4,
                               ((sy + 1) * width + sx) * 4, ((sy + 1) * width + sx + 1) * 4]
                // Validate ALL source locations, ownership and alpha BEFORE RGB.
                guard offsets.allSatisfy({ source[$0 + 3] == 255 }) else { reasons[index] = .nonOpaqueSource; break scan }
                let fx = p.x - Double(sx), fy = p.y - Double(sy)
                for channel in 0..<3 {
                    let a = Double(source[offsets[0] + channel]) * (1 - fx) + Double(source[offsets[1] + channel]) * fx
                    let b = Double(source[offsets[2] + channel]) * (1 - fx) + Double(source[offsets[3] + channel]) * fx
                    candidate[destination + channel] = UInt8(max(0, min(255, (a * (1 - fy) + b * fy).rounded())))
                }
                candidate[destination + 3] = 255; moved = true
            } }
            if reasons[index] == nil && moved { output = candidate; applied += 1 }
        }
        var counts = [RefusalReason: Int]()
        for reason in reasons.values { counts[reason, default: 0] += 1 }
        let status: Status = applied > 0 ? (reasons.isEmpty ? .applied : .partiallyApplied) : (reasons.isEmpty ? .unchanged : .refused)
        return Result(rgba: output, status: status, appliedRegionCount: applied, refusedRegionCount: reasons.count, refusalCounts: counts)
    }

    private static func validPoint(_ p: Point) -> Bool { p.x.isFinite && p.y.isFinite }
    private static func validProgress(_ p: Double) -> Bool { p.isFinite && (0...1).contains(p) }
    private static func validPolicy(_ p: SolverPolicy) -> Bool {
        (1...4096).contains(p.maximumIterations) && p.residualTolerancePixels.isFinite && p.residualTolerancePixels > 0
    }
    private static func validCalibration(_ c: Calibration) -> Bool {
        guard validPoint(c.center), validPoint(c.axisX), validPoint(c.superiorAxis),
              c.supportRadiusX.isFinite, c.supportRadiusY.isFinite, c.supportRadiusX > 0, c.supportRadiusY > 0,
              c.amplitudePixels.isFinite, c.amplitudePixels >= 0 else { return false }
        let x = c.axisX, s = c.superiorAxis
        // Representation admission only: the actual frame remains in ALL math.
        // Both handednesses are valid because superior is explicitly supplied.
        return abs(hypot(x.x, x.y) - 1) <= 1e-8 && abs(hypot(s.x, s.y) - 1) <= 1e-8
            && abs(x.x * s.x + x.y * s.y) <= 1e-8 && abs(abs(x.x * s.y - x.y * s.x) - 1) <= 1e-8
    }
    private static func supportBox(_ c: Calibration) -> Box? {
        let ad = productBounds(c.axisX.x, c.superiorAxis.y), bc = productBounds(c.superiorAxis.x, c.axisX.y)
        let lower = (ad.lower - bc.upper).nextDown, upper = (ad.upper - bc.lower).nextUp
        let absDetLower = lower > 0 ? lower : (upper < 0 ? -upper : 0)
        guard absDetLower > 0 else { return nil }
        // Source support is R^(-T) times a RECTANGLE, not R times an ellipse.
        let dx = upperDivide(upperAdd(upperMultiply(c.supportRadiusX, abs(c.superiorAxis.y)),
                                     upperMultiply(c.supportRadiusY, abs(c.axisX.y))), absDetLower)
        let dy = upperDivide(upperAdd(upperMultiply(c.supportRadiusX, abs(c.superiorAxis.x)),
                                     upperMultiply(c.supportRadiusY, abs(c.axisX.x))), absDetLower)
        let b = Box(minX: (c.center.x - dx).nextDown, minY: (c.center.y - dy).nextDown,
                    maxX: (c.center.x + dx).nextUp, maxY: (c.center.y + dy).nextUp)
        return [b.minX, b.minY, b.maxX, b.maxY].allSatisfy(\.isFinite) ? b : nil
    }
    private static func regionBox(_ r: Region) -> Box? {
        switch r {
        case let .rectangle(x0, y0, x1, y1):
            guard [x0, y0, x1, y1].allSatisfy(\.isFinite), x0 <= x1, y0 <= y1 else { return nil }
            return Box(minX: x0, minY: y0, maxX: x1, maxY: y1)
        case let .ellipse(p, rx, ry):
            guard validPoint(p), rx.isFinite, ry.isFinite, rx > 0, ry > 0 else { return nil }
            let b = Box(minX: (p.x - rx).nextDown, minY: (p.y - ry).nextDown,
                        maxX: (p.x + rx).nextUp, maxY: (p.y + ry).nextUp)
            return [b.minX, b.minY, b.maxX, b.maxY].allSatisfy(\.isFinite) ? b : nil
        }
    }
    private static func contains(_ p: Point, _ r: Region) -> Bool {
        switch r {
        case let .rectangle(x0, y0, x1, y1): return p.x >= x0 && p.y >= y0 && p.x <= x1 && p.y <= y1
        case let .ellipse(c, rx, ry): let x = (p.x - c.x) / rx, y = (p.y - c.y) / ry; return x * x + y * y <= 1
        }
    }
    private static func upperMultiply(_ a: Double, _ b: Double) -> Double { a == 0 || b == 0 ? 0 : (a * b).nextUp }
    private static func upperAdd(_ a: Double, _ b: Double) -> Double { a == 0 && b == 0 ? 0 : (a + b).nextUp }
    private static func upperDivide(_ a: Double, _ b: Double) -> Double { a == 0 ? 0 : (a / b).nextUp }
    private static func productBounds(_ a: Double, _ b: Double) -> (lower: Double, upper: Double) {
        if a == 0 || b == 0 { return (0, 0) }; let p = a * b; return (p.nextDown, p.nextUp)
    }
    private static func upperNorm(_ a: Double, _ b: Double) -> Double {
        let scale = max(a, b); if scale == 0 { return 0 }; guard scale.isFinite else { return .infinity }
        let x = upperDivide(a, scale), y = upperDivide(b, scale)
        return upperMultiply(scale, upperAdd(upperMultiply(x, x), upperMultiply(y, y)).squareRoot().nextUp)
    }
}
