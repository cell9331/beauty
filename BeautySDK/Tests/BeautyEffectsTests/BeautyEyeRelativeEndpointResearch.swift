import BeautyCore
import CryptoKit
import Foundation

/// Test-target comparator for two existing, admitted backward maps. Coordinates
/// are array indices: the first pixel center is (0, 0), not (0.5, 0.5).
/// This helper supplies no eye model, anatomical owner, or photo calibration.
enum BeautyEyeRelativeEndpointResearch {
    typealias Point = SIMD2<Double>

    enum Refusal: String, Equatable {
        case invalidImage
        case invalidPolicy
        case invalidActiveBounds
        case unsafeGradientBound
        case nonFinitePoint
        case pointOutsideImage
        case unavailableOrClippedMap
        case nonFiniteMapPoint
        case mappedPointOutsideImage
        case iterationLimit
        case numericalStagnation
        case unresolvedIdentity
        case sourceMismatch
        case nonOpaqueSource
        case sourceFootprintOutOfBounds
    }

    struct Endpoint: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let displacementLipschitzBound: Double
        fileprivate let backward: (Point) -> Point?

        /// `backward` MUST return the unclipped B(q), or nil when its evaluator
        /// refuses/clips. A black-box callback cannot reveal an undisclosed
        /// clamp or prove its global bound. The caller owns that certificate.
        init(displacementLipschitzBound: Double,
             backward: @escaping (Point) -> Point?) {
            self.displacementLipschitzBound = displacementLipschitzBound
            self.backward = backward
        }

        var description: String { "EyeEndpoint(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }

    struct Policy: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let width: Int
        let height: Int
        let maximumIterations: Int
        let residualTolerance: Double

        init(width: Int, height: Int, maximumIterations: Int, residualTolerance: Double) {
            self.width = width
            self.height = height
            self.maximumIterations = maximumIterations
            self.residualTolerance = residualTolerance
        }

        var description: String { "EyeEndpointPolicy(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }

    /// Inclusive raster evaluation window. Outside it, render deliberately
    /// retains the input; this is an explicit research ROI, not a tissue mask
    /// or a claim that the mathematical relative map is identity there.
    struct Bounds: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let minX: Int
        let minY: Int
        let maxX: Int
        let maxY: Int

        init(minX: Int, minY: Int, maxX: Int, maxY: Int) {
            self.minX = minX
            self.minY = minY
            self.maxX = maxX
            self.maxY = maxY
        }

        var description: String { "EyeEndpointBounds(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }

    struct SourceBinding: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        fileprivate let width: Int
        fileprivate let height: Int
        fileprivate let digest: SHA256.Digest

        static func bind(sourceRGBA: [UInt8], width: Int, height: Int) -> Self {
            Self(width: width, height: height, digest: SHA256.hash(data: Data(sourceRGBA)))
        }

        var description: String { "EyeEndpointSourceBinding(redacted)" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: [:]) }
    }

    struct Request: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let sourceRGBA: [UInt8]
        let width: Int
        let height: Int
        let sourceBinding: SourceBinding
        let policy: Policy
        let activeBounds: Bounds?

        init(sourceRGBA: [UInt8], width: Int, height: Int, sourceBinding: SourceBinding,
             policy: Policy, activeBounds: Bounds? = nil) {
            self.sourceRGBA = sourceRGBA
            self.width = width
            self.height = height
            self.sourceBinding = sourceBinding
            self.policy = policy
            self.activeBounds = activeBounds
        }

        var description: String { "EyeEndpointRequest(byteCount: \(sourceRGBA.count))" }
        var debugDescription: String { description }
        var customMirror: Mirror { Mirror(self, children: ["byteCount": sourceRGBA.count]) }
    }

    struct PointResult: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let point: Point?
        let refusal: Refusal?
        let iterations: Int
        let residual: Double?

        var description: String {
            "EyeEndpointPointResult(refusal: \(refusal?.rawValue ?? "none"), iterations: \(iterations))"
        }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["refused": refusal != nil, "iterations": iterations])
        }
    }

    enum RasterStatus: String, Equatable { case applied, unchanged, refused }

    struct RasterResult: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let rgba: [UInt8]
        let status: RasterStatus
        let refusal: Refusal?
        let changedPixelCount: Int
        /// Work completed before either commit or rollback, not accepted output.
        let sampledPixelCount: Int
        let maximumIterationsUsed: Int
        let maximumResidual: Double

        var description: String {
            "EyeEndpointRasterResult(status: \(status.rawValue), refusal: \(refusal?.rawValue ?? "none"), changedPixelCount: \(changedPixelCount), sampledPixelCount: \(sampledPixelCount))"
        }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["status": status.rawValue,
                                    "changedPixelCount": changedPixelCount,
                                    "sampledPixelCount": sampledPixelCount])
        }
    }

    // Reuse the production resource ceiling without a duplicate numeric budget.
    // This is not an input-specific scale or a fitting parameter.
    private static let maximumPixelCount = BeautyConfiguration.defaultMaximumInputPixelCount
    private static let maximumIterationBudget = 10_000

    /// H(r) = B_high^-1(B_low(r)). The solver checks the actual B_high residual.
    static func relativeForward(point: Point, low: Endpoint, high: Endpoint,
                                policy: Policy) -> PointResult {
        relative(point: point, from: low, to: high, policy: policy)
    }

    /// H^-1(q) = B_low^-1(B_high(q)). Used for one-source raster sampling.
    static func relativeInverse(point: Point, low: Endpoint, high: Endpoint,
                                policy: Policy) -> PointResult {
        relative(point: point, from: high, to: low, policy: policy)
    }

    static func render(_ request: Request, low: Endpoint, high: Endpoint) -> RasterResult {
        let source = request.sourceRGBA
        var sampled = 0
        var maximumIterationsUsed = 0
        var maximumResidual = 0.0
        func refused(_ reason: Refusal) -> RasterResult {
            RasterResult(rgba: source, status: .refused, refusal: reason,
                         changedPixelCount: 0, sampledPixelCount: sampled,
                         maximumIterationsUsed: maximumIterationsUsed,
                         maximumResidual: maximumResidual)
        }
        guard validImage(width: request.width, height: request.height),
              source.count == request.width * request.height * 4
        else { return refused(.invalidImage) }
        guard request.policy.width == request.width, request.policy.height == request.height,
              validPolicy(request.policy) else { return refused(.invalidPolicy) }
        guard validBound(low), validBound(high) else { return refused(.unsafeGradientBound) }
        guard request.sourceBinding.width == request.width,
              request.sourceBinding.height == request.height,
              request.sourceBinding.digest == SHA256.hash(data: Data(source))
        else { return refused(.sourceMismatch) }
        guard stride(from: 3, to: source.count, by: 4).allSatisfy({ source[$0] == 255 })
        else { return refused(.nonOpaqueSource) }

        let bounds = request.activeBounds ?? Bounds(minX: 0, minY: 0,
                                                     maxX: request.width - 1, maxY: request.height - 1)
        guard bounds.minX >= 0, bounds.minY >= 0,
              bounds.maxX >= bounds.minX, bounds.maxY >= bounds.minY,
              bounds.maxX < request.width, bounds.maxY < request.height
        else { return refused(.invalidActiveBounds) }

        var candidate = source
        var changed = 0
        for row in bounds.minY...bounds.maxY {
            for column in bounds.minX...bounds.maxX {
                let q = Point(Double(column), Double(row))
                let inverse = relativeInverse(point: q, low: low, high: high, policy: request.policy)
                maximumIterationsUsed = max(maximumIterationsUsed, inverse.iterations)
                if let residual = inverse.residual { maximumResidual = max(maximumResidual, residual) }
                if let reason = inverse.refusal { return refused(reason) }
                guard let p = inverse.point else { return refused(.unavailableOrClippedMap) }
                // Only exact equality of the two actual endpoint evaluations
                // can authorize this identity shortcut, including image edges.
                if p == q { continue }
                guard p.x >= 0, p.y >= 0,
                      p.x < Double(request.width - 1), p.y < Double(request.height - 1)
                else { return refused(.sourceFootprintOutOfBounds) }
                let x = Int(floor(p.x)), y = Int(floor(p.y))
                let taps = [(y * request.width + x) * 4,
                            (y * request.width + x + 1) * 4,
                            ((y + 1) * request.width + x) * 4,
                            ((y + 1) * request.width + x + 1) * 4]
                // Full geometric footprint is checked before any tap is read.
                guard taps.allSatisfy({ $0 >= 0 && $0 + 3 < source.count })
                else { return refused(.sourceFootprintOutOfBounds) }
                guard taps.allSatisfy({ source[$0 + 3] == 255 })
                else { return refused(.nonOpaqueSource) }
                let fx = p.x - Double(x), fy = p.y - Double(y)
                let weights = [(1 - fx) * (1 - fy), fx * (1 - fy),
                               (1 - fx) * fy, fx * fy]
                let output = (row * request.width + column) * 4
                for channel in 0..<3 {
                    var value = 0.0
                    for tap in taps.indices { value += Double(source[taps[tap] + channel]) * weights[tap] }
                    candidate[output + channel] = UInt8(min(255, max(0, value.rounded())))
                }
                // Alpha is copied from immutable source, never resampled.
                candidate[output + 3] = source[output + 3]
                sampled += 1
                if (0..<3).contains(where: { candidate[output + $0] != source[output + $0] }) {
                    changed += 1
                }
            }
        }
        return RasterResult(rgba: candidate, status: changed > 0 ? .applied : .unchanged,
                            refusal: nil, changedPixelCount: changed,
                            sampledPixelCount: sampled, maximumIterationsUsed: maximumIterationsUsed,
                            maximumResidual: maximumResidual)
    }

    private static func relative(point: Point, from: Endpoint, to: Endpoint,
                                 policy: Policy) -> PointResult {
        guard validPolicy(policy) else { return failure(.invalidPolicy) }
        guard validBound(from), validBound(to) else { return failure(.unsafeGradientBound) }
        guard finite(point) else { return failure(.nonFinitePoint) }
        guard inside(point, policy: policy) else { return failure(.pointOutsideImage) }
        switch evaluate(from, at: point, policy: policy) {
        case .failure(let reason): return failure(reason)
        case .success(let material):
            switch evaluate(to, at: point, policy: policy) {
            case .failure(let reason): return failure(reason)
            case .success(let otherMaterial):
                if material == otherMaterial {
                    return PointResult(point: point, refusal: nil, iterations: 0, residual: 0)
                }
            }
            let solved = invert(material, map: to, policy: policy)
            // A toleranced solve must not masquerade as exact relative identity.
            if solved.refusal == nil, solved.point == point { return failure(.unresolvedIdentity) }
            return solved
        }
    }

    /// B(q)=q-d(q); solve B(q)=p with q_next=p+d(q). No clamping,
    /// approximate one-subtraction fallback, or partial-iteration publication.
    private static func invert(_ material: Point, map: Endpoint, policy: Policy) -> PointResult {
        var q = material
        for iteration in 0...policy.maximumIterations {
            let backward: Point
            switch evaluate(map, at: q, policy: policy) {
            case .failure(let reason): return failure(reason, iterations: iteration)
            case .success(let point): backward = point
            }
            let residual = hypot(backward.x - material.x, backward.y - material.y)
            guard residual.isFinite else { return failure(.nonFiniteMapPoint, iterations: iteration) }
            if residual == 0 || (iteration > 0 && residual <= policy.residualTolerance) {
                return PointResult(point: q, refusal: nil, iterations: iteration, residual: residual)
            }
            guard iteration < policy.maximumIterations else {
                return failure(.iterationLimit, iterations: iteration, residual: residual)
            }
            let next = material + (q - backward)
            guard finite(next) else { return failure(.nonFinitePoint, iterations: iteration, residual: residual) }
            guard inside(next, policy: policy) else {
                return failure(.pointOutsideImage, iterations: iteration, residual: residual)
            }
            guard next != q else {
                return failure(.numericalStagnation, iterations: iteration, residual: residual)
            }
            q = next
        }
        return failure(.iterationLimit, iterations: policy.maximumIterations)
    }

    private enum Evaluation { case success(Point), failure(Refusal) }

    private static func evaluate(_ map: Endpoint, at point: Point, policy: Policy) -> Evaluation {
        guard finite(point) else { return .failure(.nonFinitePoint) }
        guard inside(point, policy: policy) else { return .failure(.pointOutsideImage) }
        guard let mapped = map.backward(point) else { return .failure(.unavailableOrClippedMap) }
        guard finite(mapped) else { return .failure(.nonFiniteMapPoint) }
        guard inside(mapped, policy: policy) else { return .failure(.mappedPointOutsideImage) }
        return .success(mapped)
    }

    private static func validImage(width: Int, height: Int) -> Bool {
        width > 1 && height > 1 && width <= maximumPixelCount / height
    }

    private static func validPolicy(_ policy: Policy) -> Bool {
        validImage(width: policy.width, height: policy.height)
            && (1...maximumIterationBudget).contains(policy.maximumIterations)
            && policy.residualTolerance.isFinite && policy.residualTolerance > 0
    }

    private static func validBound(_ map: Endpoint) -> Bool {
        map.displacementLipschitzBound.isFinite
            && map.displacementLipschitzBound >= 0 && map.displacementLipschitzBound < 1
    }

    private static func finite(_ point: Point) -> Bool { point.x.isFinite && point.y.isFinite }

    private static func inside(_ point: Point, policy: Policy) -> Bool {
        point.x >= 0 && point.y >= 0
            && point.x <= Double(policy.width - 1) && point.y <= Double(policy.height - 1)
    }

    private static func failure(_ reason: Refusal, iterations: Int = 0,
                                residual: Double? = nil) -> PointResult {
        PointResult(point: nil, refusal: reason, iterations: iterations, residual: residual)
    }
}
