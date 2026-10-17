import BeautyCore
import CryptoKit
import Foundation

/// Research-only pixel coordinates. Integer coordinates are source pixel centers;
/// x grows rightward and y downward. These are not detector-normalized points.
package struct BeautyIrisFollowingPoint: Sendable, Equatable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    package let x: Double
    package let y: Double
    package init(x: Double, y: Double) { self.x = x; self.y = y }
    package var description: String { "BeautyIrisFollowingPoint(redacted)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [:]) }
}

package enum BeautyIrisFollowingSide: Sendable, Hashable { case left, right }

/// Explicit source ownership/protection, supplied by the calibration owner.
/// Neither an eye aperture nor a detector bounding box is inferred here.
package enum BeautyIrisFollowingRegion: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    case rectangle(minX: Double, minY: Double, maxX: Double, maxY: Double)
    case ellipse(center: BeautyIrisFollowingPoint, radiusX: Double, radiusY: Double)

    package var description: String { "BeautyIrisFollowingRegion(redacted)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [:]) }
}

/// All parameters are explicit, request-local hypotheses. There is intentionally
/// no detector conversion, neutral, endpoint split, default gain, or default support.
package struct BeautyIrisFollowingEyeCalibration: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    package let side: BeautyIrisFollowingSide
    package let center: BeautyIrisFollowingPoint
    package let axisX: BeautyIrisFollowingPoint
    package let axisY: BeautyIrisFollowingPoint
    package let supportRadiusX: Double
    package let supportRadiusY: Double
    package let forwardGainX: Double
    package let forwardGainY: Double
    package let ownedSourceDomain: BeautyIrisFollowingRegion
    package let protectedRegions: [BeautyIrisFollowingRegion]

    package init(side: BeautyIrisFollowingSide, center: BeautyIrisFollowingPoint,
                 axisX: BeautyIrisFollowingPoint, axisY: BeautyIrisFollowingPoint,
                 supportRadiusX: Double, supportRadiusY: Double,
                 forwardGainX: Double, forwardGainY: Double,
                 ownedSourceDomain: BeautyIrisFollowingRegion,
                 protectedRegions: [BeautyIrisFollowingRegion]) {
        self.side = side; self.center = center; self.axisX = axisX; self.axisY = axisY
        self.supportRadiusX = supportRadiusX; self.supportRadiusY = supportRadiusY
        self.forwardGainX = forwardGainX; self.forwardGainY = forwardGainY
        self.ownedSourceDomain = ownedSourceDomain; self.protectedRegions = protectedRegions
    }
    package var description: String { "BeautyIrisFollowingEyeCalibration(redacted)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [:]) }
}

/// Mathematical solver policy, not a feature response or reference calibration.
package struct BeautyIrisFollowingSolverPolicy: Sendable {
    package let maximumIterations: Int
    package let residualTolerancePixels: Double
    package init(maximumIterations: Int, residualTolerancePixels: Double) {
        self.maximumIterations = maximumIterations
        self.residualTolerancePixels = residualTolerancePixels
    }
}

/// Strong in-memory binding. No digest is exposed, logged, or persisted.
package struct BeautyIrisFollowingSourceBinding: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    fileprivate let width: Int
    fileprivate let height: Int
    fileprivate let digest: SHA256.Digest

    package static func bind(sourceRGBA: [UInt8], width: Int, height: Int) -> Self {
        Self(width: width, height: height, digest: SHA256.hash(data: Data(sourceRGBA)))
    }
    package var description: String { "BeautyIrisFollowingSourceBinding(redacted)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [:]) }
}

/// Explicit observed-left endpoint -> observed-right endpoint progress in [0,1].
/// An invalid request remains a request and returns a refusal; it never becomes
/// absence of a request and must never restore the legacy fixed-lid route.
package struct BeautyIrisFollowingRequest: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    package let sourceRGBA: [UInt8]
    package let width: Int
    package let height: Int
    package let sourceBinding: BeautyIrisFollowingSourceBinding
    package let eyes: [BeautyIrisFollowingEyeCalibration]
    package let progress: Double
    package let solverPolicy: BeautyIrisFollowingSolverPolicy

    package init(sourceRGBA: [UInt8], width: Int, height: Int,
                 sourceBinding: BeautyIrisFollowingSourceBinding,
                 eyes: [BeautyIrisFollowingEyeCalibration], progress: Double,
                 solverPolicy: BeautyIrisFollowingSolverPolicy) {
        self.sourceRGBA = sourceRGBA; self.width = width; self.height = height
        self.sourceBinding = sourceBinding; self.eyes = eyes
        self.progress = progress; self.solverPolicy = solverPolicy
    }
    package var description: String { "BeautyIrisFollowingRequest(redacted)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [:]) }
}

package enum BeautyIrisFollowingRefusalReason: String, Sendable, Hashable {
    case invalidImage, sourceMismatch, invalidProgress, invalidSolverPolicy
    case invalidEyeCount, duplicateSide, invalidCalibration, unsafeContraction
    case overlappingSupport, protectedSupport, emptySupport
    case unownedSource, nonOpaqueSource, sourceFootprintOutOfBounds, inverseDidNotConverge
    case unsupportedStageCombination
    case missingObservedEyeSupport
}

package enum BeautyIrisFollowingStatus: Sendable, Equatable {
    case unchanged, applied, refused, partiallyApplied
}

package struct BeautyIrisFollowingResult: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    package let rgba: [UInt8]
    package let status: BeautyIrisFollowingStatus
    package let appliedEyeCount: Int
    package let refusedEyeCount: Int
    package let refusalCounts: [BeautyIrisFollowingRefusalReason: Int]
    package init(rgba: [UInt8], status: BeautyIrisFollowingStatus, appliedEyeCount: Int,
                 refusedEyeCount: Int, refusalCounts: [BeautyIrisFollowingRefusalReason: Int]) {
        self.rgba = rgba; self.status = status; self.appliedEyeCount = appliedEyeCount
        self.refusedEyeCount = refusedEyeCount; self.refusalCounts = refusalCounts
    }
    package var description: String {
        "BeautyIrisFollowingResult(status: \(status), applied: \(appliedEyeCount), refused: \(refusedEyeCount))"
    }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [:]) }
}

/// A compact polynomial candidate, NOT a recovered reference mechanism:
/// s=(localX/rx)^2+(localY/ry)^2, w=(1-s)^2 for s<1, otherwise zero.
/// D(p)=progress * R diag(gainX,gainY) R^T (p-center) * w.
/// It moves iris, lid and sclera texture together wherever the explicit support
/// allows it; no eye-aperture mask or stationary/displaced RGB blend is used.
package enum BeautyIrisFollowingMap {
    package struct Derivative: Sendable {
        package let xx: Double
        package let xy: Double
        package let yx: Double
        package let yy: Double
    }

    private struct Box {
        let minX: Double, minY: Double, maxX: Double, maxY: Double
        func intersects(_ other: Self) -> Bool {
            minX <= other.maxX && other.minX <= maxX && minY <= other.maxY && other.minY <= maxY
        }
    }
    private typealias Point = BeautyIrisFollowingPoint
    private typealias Eye = BeautyIrisFollowingEyeCalibration
    private typealias Reason = BeautyIrisFollowingRefusalReason

    /// Analytic global operator-norm certificate including the envelope derivative.
    /// C=(aspect+1/aspect)/2 and max_s[(1-s)^2+4Cs(1-s)]
    /// =4C^2/(4C-1). Strict bound <1 guarantees global invertibility and fixed-point
    /// convergence. Numerically supplied axes are retained exactly: the world
    /// derivative is R Jlocal R^T, so the certificate also includes an outward-
    /// rounded upper bound on ||R||^2. The bound is sufficient and conservative,
    /// not a fitted cap or an assumption that near-orthonormal means orthonormal.
    package static func contractionBound(eye: BeautyIrisFollowingEyeCalibration,
                                         progress: Double) -> Double? {
        guard validGeometry(eye), progress.isFinite, (0...1).contains(progress) else { return nil }
        let gain = max(abs(eye.forwardGainX), abs(eye.forwardGainY))
        if progress == 0 || gain == 0 { return 0 }
        guard let basisNormSquared = basisNormSquaredUpperBound(eye) else { return nil }
        let aspect = upperDivide(max(eye.supportRadiusX, eye.supportRadiusY),
                                 min(eye.supportRadiusX, eye.supportRadiusY))
        // C(a) and C/(1-.25/C) are increasing for a>=1 and C>=1.
        let c = upperMultiply(upperAdd(aspect, upperDivide(1, aspect)), 0.5)
        let denominatorLower = (1 - upperDivide(0.25, c)).nextDown
        guard c.isFinite, denominatorLower > 0 else { return nil }
        let coefficient = upperDivide(c, denominatorLower)
        let bound = upperMultiply(upperMultiply(upperMultiply(progress, gain), coefficient), basisNormSquared)
        return bound.isFinite ? bound : nil
    }

    package static func forwardPoint(_ source: BeautyIrisFollowingPoint,
                                     eye: BeautyIrisFollowingEyeCalibration,
                                     progress: Double) -> BeautyIrisFollowingPoint? {
        guard validPoint(source), validGeometry(eye), progress.isFinite,
              (0...1).contains(progress) else { return nil }
        let d = displacement(source, eye: eye, progress: progress)
        let p = Point(x: source.x + d.x, y: source.y + d.y)
        return validPoint(p) ? p : nil
    }

    /// Full derivative of D, including dw/dx and dw/dy in the rotated frame.
    package static func displacementDerivative(at source: BeautyIrisFollowingPoint,
                                               eye: BeautyIrisFollowingEyeCalibration,
                                               progress: Double) -> Derivative? {
        guard validPoint(source), validGeometry(eye), progress.isFinite,
              (0...1).contains(progress) else { return nil }
        let v = local(source, eye), nx = v.x / eye.supportRadiusX, ny = v.y / eye.supportRadiusY
        let s = nx * nx + ny * ny
        guard s < 1 else { return Derivative(xx: 0, xy: 0, yx: 0, yy: 0) }
        let w = (1 - s) * (1 - s)
        let wx = -4 * (1 - s) * nx / eye.supportRadiusX
        let wy = -4 * (1 - s) * ny / eye.supportRadiusY
        let a = progress * eye.forwardGainX * (w + v.x * wx)
        let b = progress * eye.forwardGainX * v.x * wy
        let c = progress * eye.forwardGainY * v.y * wx
        let d = progress * eye.forwardGainY * (w + v.y * wy)
        let x = eye.axisX, y = eye.axisY
        return Derivative(
            xx: x.x * (a * x.x + b * y.x) + y.x * (c * x.x + d * y.x),
            xy: x.x * (a * x.y + b * y.y) + y.x * (c * x.y + d * y.y),
            yx: x.y * (a * x.x + b * y.x) + y.y * (c * x.x + d * y.x),
            yy: x.y * (a * x.y + b * y.y) + y.y * (c * x.y + d * y.y))
    }

    package static func inversePoint(_ target: BeautyIrisFollowingPoint,
                                     eye: BeautyIrisFollowingEyeCalibration,
                                     progress: Double,
                                     solverPolicy: BeautyIrisFollowingSolverPolicy) -> BeautyIrisFollowingPoint? {
        guard validPoint(target), validPolicy(solverPolicy),
              let bound = contractionBound(eye: eye, progress: progress), bound < 1 else { return nil }
        return inverse(target, eye: eye, progress: progress, policy: solverPolicy)
    }

    package static func render(_ request: BeautyIrisFollowingRequest) -> BeautyIrisFollowingResult {
        render(request, sourceRGBA: request.sourceRGBA, width: request.width, height: request.height)
    }

    /// Stage integrations must pass their ACTUAL immutable source here. A stale
    /// request cannot replace the current frame with its retained older raster.
    package static func render(_ request: BeautyIrisFollowingRequest, sourceRGBA source: [UInt8],
                               width: Int, height: Int,
                               availableObservedSides: Set<BeautyIrisFollowingSide>? = nil) -> BeautyIrisFollowingResult {
        func globalRefusal(_ reason: Reason) -> BeautyIrisFollowingResult {
            let count = max(1, request.eyes.count)
            return BeautyIrisFollowingResult(rgba: source, status: .refused,
                appliedEyeCount: 0, refusedEyeCount: count, refusalCounts: [reason: count])
        }
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              width * height <= Int.max / 4, source.count == width * height * 4
        else { return globalRefusal(.invalidImage) }
        guard request.width == width, request.height == height,
              request.sourceBinding.width == width, request.sourceBinding.height == height,
              request.sourceBinding.digest == SHA256.hash(data: Data(source))
        else { return globalRefusal(.sourceMismatch) }
        guard request.progress.isFinite, (0...1).contains(request.progress)
        else { return globalRefusal(.invalidProgress) }
        guard validPolicy(request.solverPolicy) else { return globalRefusal(.invalidSolverPolicy) }
        guard (1...2).contains(request.eyes.count) else { return globalRefusal(.invalidEyeCount) }

        var reasons = [Int: Reason]()
        var boxes = [Int: Box]()
        for (index, eye) in request.eyes.enumerated() {
            guard validGeometry(eye), let box = supportBox(eye),
                  regionBox(eye.ownedSourceDomain) != nil,
                  eye.protectedRegions.allSatisfy({ regionBox($0) != nil })
            else { reasons[index] = .invalidCalibration; continue }
            guard let bound = contractionBound(eye: eye, progress: request.progress), bound < 1
            else { reasons[index] = .unsafeContraction; continue }
            boxes[index] = box
            if eye.protectedRegions.contains(where: { box.intersects(regionBox($0)!) }) {
                reasons[index] = .protectedSupport
            }
        }
        if request.eyes.count == 2 {
            if request.eyes[0].side == request.eyes[1].side {
                reasons[0] = .duplicateSide; reasons[1] = .duplicateSide
            } else if let a = boxes[0], let b = boxes[1], a.intersects(b) {
                // Disjoint source supports are required; no uncertified sum of fields.
                reasons[0] = .overlappingSupport; reasons[1] = .overlappingSupport
            }
        }
        if let availableObservedSides {
            for (index, eye) in request.eyes.enumerated()
                where reasons[index] == nil && !availableObservedSides.contains(eye.side) {
                reasons[index] = .missingObservedEyeSupport
            }
        }
        var output = source
        var applied = 0
        for (index, eye) in request.eyes.enumerated() where reasons[index] == nil {
            guard let box = boxes[index], box.maxX >= 0, box.maxY >= 0,
                  box.minX <= Double(width - 1), box.minY <= Double(height - 1)
            else { reasons[index] = .emptySupport; continue }
            if request.progress == 0 || (eye.forwardGainX == 0 && eye.forwardGainY == 0) { continue }
            let minX = Int(max(0, box.minX).rounded(.up))
            let maxX = Int(min(Double(width - 1), box.maxX).rounded(.down))
            let minY = Int(max(0, box.minY).rounded(.up))
            let maxY = Int(min(Double(height - 1), box.maxY).rounded(.down))
            guard minX <= maxX, minY <= maxY else { reasons[index] = .emptySupport; continue }
            // One transactional eye image: any bad footprint discards ALL of
            // this eye. A previously accepted, disjoint peer remains untouched.
            var candidate = output
            var moved = false
            scan: for y in minY...maxY { for x in minX...maxX {
                let q = Point(x: Double(x), y: Double(y))
                let d = displacement(q, eye: eye, progress: request.progress)
                if d.x == 0 && d.y == 0 { continue }
                let offset = (y * width + x) * 4
                guard contains(q, eye.ownedSourceDomain) else { reasons[index] = .unownedSource; break scan }
                guard source[offset + 3] == 255 else { reasons[index] = .nonOpaqueSource; break scan }
                guard let p = inverse(q, eye: eye, progress: request.progress, policy: request.solverPolicy)
                else { reasons[index] = .inverseDidNotConverge; break scan }
                guard p.x >= 0, p.y >= 0, p.x < Double(width - 1), p.y < Double(height - 1)
                else { reasons[index] = .sourceFootprintOutOfBounds; break scan }
                let sx = Int(floor(p.x)), sy = Int(floor(p.y))
                let taps = [Point(x: Double(sx), y: Double(sy)), Point(x: Double(sx + 1), y: Double(sy)),
                            Point(x: Double(sx), y: Double(sy + 1)), Point(x: Double(sx + 1), y: Double(sy + 1))]
                guard taps.allSatisfy({ contains($0, eye.ownedSourceDomain) })
                else { reasons[index] = .unownedSource; break scan }
                let indices = [(sy * width + sx) * 4, (sy * width + sx + 1) * 4,
                               ((sy + 1) * width + sx) * 4, ((sy + 1) * width + sx + 1) * 4]
                // All coordinates/ownership are checked before any tap is read.
                guard indices.allSatisfy({ source[$0 + 3] == 255 })
                else { reasons[index] = .nonOpaqueSource; break scan }
                let fx = p.x - Double(sx), fy = p.y - Double(sy)
                for channel in 0..<3 {
                    let a = Double(source[indices[0] + channel]) * (1 - fx)
                        + Double(source[indices[1] + channel]) * fx
                    let b = Double(source[indices[2] + channel]) * (1 - fx)
                        + Double(source[indices[3] + channel]) * fx
                    candidate[offset + channel] = UInt8(max(0, min(255, (a * (1 - fy) + b * fy).rounded())))
                }
                candidate[offset + 3] = 255
                moved = true
            } }
            if reasons[index] == nil, moved { output = candidate; applied += 1 }
        }
        var counts = [Reason: Int]()
        for reason in reasons.values { counts[reason, default: 0] += 1 }
        let status: BeautyIrisFollowingStatus = applied > 0
            ? (reasons.isEmpty ? .applied : .partiallyApplied)
            : (reasons.isEmpty ? .unchanged : .refused)
        return BeautyIrisFollowingResult(rgba: output, status: status, appliedEyeCount: applied,
            refusedEyeCount: reasons.count, refusalCounts: counts)
    }

    private static func validPoint(_ p: Point) -> Bool { p.x.isFinite && p.y.isFinite }
    private static func validPolicy(_ p: BeautyIrisFollowingSolverPolicy) -> Bool {
        // Resource limit only; does not specify a reference fit or visual response.
        (1...4096).contains(p.maximumIterations) && p.residualTolerancePixels.isFinite
            && p.residualTolerancePixels > 0
    }
    private static func validGeometry(_ e: Eye) -> Bool {
        guard validPoint(e.center), validPoint(e.axisX), validPoint(e.axisY),
              e.supportRadiusX.isFinite, e.supportRadiusY.isFinite,
              e.supportRadiusX > 0, e.supportRadiusY > 0,
              e.forwardGainX.isFinite, e.forwardGainY.isFinite else { return false }
        // Input admission tolerance only. The actual R is retained throughout
        // the field, derivative, certificate and support; its deviation from an
        // exact orthonormal frame is never discarded by the safety proof.
        return abs(hypot(e.axisX.x, e.axisX.y) - 1) <= 1e-8
            && abs(hypot(e.axisY.x, e.axisY.y) - 1) <= 1e-8
            && abs(e.axisX.x * e.axisY.x + e.axisX.y * e.axisY.y) <= 1e-8
            && abs(e.axisX.x * e.axisY.y - e.axisX.y * e.axisY.x - 1) <= 1e-8
    }
    private static func local(_ p: Point, _ e: Eye) -> Point {
        let x = p.x - e.center.x, y = p.y - e.center.y
        return Point(x: x * e.axisX.x + y * e.axisX.y, y: x * e.axisY.x + y * e.axisY.y)
    }
    private static func displacement(_ p: Point, eye e: Eye, progress: Double) -> Point {
        let v = local(p, e), x = v.x / e.supportRadiusX, y = v.y / e.supportRadiusY
        let s = x * x + y * y
        guard s < 1, progress != 0 else { return Point(x: 0, y: 0) }
        let w = (1 - s) * (1 - s) * progress
        let dx = e.forwardGainX * v.x * w, dy = e.forwardGainY * v.y * w
        return Point(x: e.axisX.x * dx + e.axisY.x * dy, y: e.axisX.y * dx + e.axisY.y * dy)
    }
    private static func inverse(_ q: Point, eye: Eye, progress: Double,
                                policy: BeautyIrisFollowingSolverPolicy) -> Point? {
        var p = q
        for _ in 0..<policy.maximumIterations {
            let d = displacement(p, eye: eye, progress: progress)
            p = Point(x: q.x - d.x, y: q.y - d.y)
            guard validPoint(p) else { return nil }
            let check = displacement(p, eye: eye, progress: progress)
            let residual = hypot(p.x + check.x - q.x, p.y + check.y - q.y)
            if residual.isFinite, residual <= policy.residualTolerancePixels { return p }
        }
        return nil
    }
    private static func supportBox(_ e: Eye) -> Box? {
        // local=R^T(p-c), so the actual source support is
        // c + R^(-T) diag(rx,ry) unitDisk, even for an admitted near-orthonormal
        // frame. R itself would produce an incorrect bounding box in that case.
        let ad = productBounds(e.axisX.x, e.axisY.y)
        let bc = productBounds(e.axisY.x, e.axisX.y)
        let determinantLower = (ad.lower - bc.upper).nextDown
        guard determinantLower > 0, determinantLower.isFinite else { return nil }
        let dx = upperNorm(
            upperDivide(upperMultiply(e.supportRadiusX, abs(e.axisY.y)), determinantLower),
            upperDivide(upperMultiply(e.supportRadiusY, abs(e.axisX.y)), determinantLower))
        let dy = upperNorm(
            upperDivide(upperMultiply(e.supportRadiusX, abs(e.axisY.x)), determinantLower),
            upperDivide(upperMultiply(e.supportRadiusY, abs(e.axisX.x)), determinantLower))
        let b = Box(minX: (e.center.x - dx).nextDown, minY: (e.center.y - dy).nextDown,
                    maxX: (e.center.x + dx).nextUp, maxY: (e.center.y + dy).nextUp)
        return [b.minX, b.minY, b.maxX, b.maxY].allSatisfy(\.isFinite) ? b : nil
    }
    /// Directed upper arithmetic for nonnegative quantities. Overflow refuses
    /// the configuration rather than weakening its certificate or coverage.
    private static func upperMultiply(_ a: Double, _ b: Double) -> Double {
        if a == 0 || b == 0 { return 0 }
        return (a * b).nextUp
    }
    private static func upperAdd(_ a: Double, _ b: Double) -> Double {
        if a == 0 && b == 0 { return 0 }
        return (a + b).nextUp
    }
    private static func upperDivide(_ a: Double, _ b: Double) -> Double {
        if a == 0 { return 0 }
        return (a / b).nextUp
    }
    private static func productBounds(_ a: Double, _ b: Double) -> (lower: Double, upper: Double) {
        if a == 0 || b == 0 { return (0, 0) }
        let p = a * b
        return (p.nextDown, p.nextUp)
    }
    private static func basisNormSquaredUpperBound(_ e: Eye) -> Double? {
        let x = e.axisX, y = e.axisY
        let a = productBounds(x.x, y.x), b = productBounds(x.y, y.y)
        let dotLower = (a.lower + b.lower).nextDown
        let dotUpper = (a.upper + b.upper).nextUp
        let offDiagonal = max(abs(dotLower), abs(dotUpper))
        // Maximum absolute row sum of the symmetric Gram matrix bounds its
        // largest eigenvalue = ||R||^2, without discarding dot-product cancellation.
        let rowX = upperAdd(upperAdd(upperMultiply(abs(x.x), abs(x.x)),
                                    upperMultiply(abs(x.y), abs(x.y))), offDiagonal)
        let rowY = upperAdd(upperAdd(upperMultiply(abs(y.x), abs(y.x)),
                                    upperMultiply(abs(y.y), abs(y.y))), offDiagonal)
        let bound = max(rowX, rowY)
        return bound.isFinite ? bound : nil
    }
    private static func upperNorm(_ a: Double, _ b: Double) -> Double {
        let scale = max(a, b)
        if scale == 0 { return 0 }
        guard scale.isFinite else { return .infinity }
        let x = upperDivide(a, scale), y = upperDivide(b, scale)
        let square = upperAdd(upperMultiply(x, x), upperMultiply(y, y))
        return upperMultiply(scale, square.squareRoot().nextUp)
    }
    private static func regionBox(_ r: BeautyIrisFollowingRegion) -> Box? {
        switch r {
        case let .rectangle(minX, minY, maxX, maxY):
            guard [minX, minY, maxX, maxY].allSatisfy(\.isFinite), minX <= maxX, minY <= maxY else { return nil }
            return Box(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        case let .ellipse(c, rx, ry):
            guard validPoint(c), rx.isFinite, ry.isFinite, rx > 0, ry > 0 else { return nil }
            let b = Box(minX: c.x - rx, minY: c.y - ry, maxX: c.x + rx, maxY: c.y + ry)
            return [b.minX, b.minY, b.maxX, b.maxY].allSatisfy(\.isFinite) ? b : nil
        }
    }
    private static func contains(_ p: Point, _ r: BeautyIrisFollowingRegion) -> Bool {
        switch r {
        case let .rectangle(minX, minY, maxX, maxY):
            return p.x >= minX && p.y >= minY && p.x <= maxX && p.y <= maxY
        case let .ellipse(c, rx, ry):
            let x = (p.x - c.x) / rx, y = (p.y - c.y) / ry
            return x * x + y * y <= 1
        }
    }
}
