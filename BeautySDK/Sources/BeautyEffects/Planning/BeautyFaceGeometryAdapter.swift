import BeautyDetection
import Foundation

enum BeautyFaceGeometryAdapter {
    // These are support-validation ceilings only. They are not visual-effect
    // caps; Phase 44 owns final effect calibration.
    static let minimumContourPointCount = 6
    static let maximumContourPointCount = 16
    static let minimumUniqueContourPointCount = 4
    static let minimumRelativeContourWidth: Float = 0.04
    static let maximumRelativeContourWidth: Float = 0.50
    static let minimumRelativeContourHeight: Float = 0.01
    static let maximumRelativeContourHeight: Float = 0.30
    static let minimumRelativeContourArea: Float = 0.0004
    static let pupilContainmentExpansion: Float = 0.10
    static let maximumPupilEllipseOffset: Float = 0.70
    static let minimumPairedPupilRatio: Float = 0.50
    static let maximumPairedPupilRatio: Float = 2.00

    static func makeGeometry(from observation: BeautyFaceObservation) -> FaceGeometry {
        let bounds = makeBounds(from: observation)
        let landmarks = observation.landmarks.availableGroups

        let observedSupports = observation.observedEyeSupport
        let supportsBySide = observedSupports.map { supports in
            supports.reduce(into: [BeautyObservedEyeSide: BeautyObservedEyeSupport]()) { result, support in
                // Keep the first side sample deterministically; malformed
                // duplicate-side payloads are rejected by the resulting
                // side-specific validation rather than trapping construction.
                if result[support.side] == nil {
                    result[support.side] = support
                }
            }
        }
        let leftObserved = supportsBySide?[.left].flatMap {
            validatedSupport($0, bounds: bounds)
        }
        let rightObserved = supportsBySide?[.right].flatMap {
            validatedSupport($0, bounds: bounds)
        }
        let paired = validatePairedPupils(left: leftObserved, right: rightObserved)
        let leftSupport = leftObserved.map { support in
            support.withPupil(paired.left)
        }
        let rightSupport = rightObserved.map { support in
            support.withPupil(paired.right)
        }

        // A nil observed payload is the legacy coarse-observation path. It is
        // retained solely for shipped zero-default compatibility. Once an
        // observed payload exists, absent or malformed sides fail closed and
        // never fall back to synthetic eye proxies.
        let leftEyePoints: [SIMD2<Float>]
        let rightEyePoints: [SIMD2<Float>]
        if observedSupports == nil {
            leftEyePoints = landmarks.contains(.leftEye) ? leftEye(in: bounds) : []
            rightEyePoints = landmarks.contains(.rightEye) ? rightEye(in: bounds) : []
        } else {
            leftEyePoints = leftSupport?.contour ?? []
            rightEyePoints = rightSupport?.contour ?? []
        }

        return FaceGeometry(
            bounds: bounds,
            faceContour: landmarks.contains(.faceContour) ? faceContour(in: bounds) : [],
            leftEye: landmarks.contains(.leftEye) ? leftEyePoints : [],
            rightEye: landmarks.contains(.rightEye) ? rightEyePoints : [],
            nose: landmarks.contains(.nose) ? nose(in: bounds) : [],
            noseRoot: landmarks.contains(.nose) ? noseRoot(in: bounds) : [],
            noseTip: landmarks.contains(.nose) ? noseTip(in: bounds) : [],
            outerLips: landmarks.contains(.outerLips) ? outerLips(in: bounds) : [],
            upperLips: landmarks.contains(.outerLips) ? upperLips(in: bounds) : [],
            lowerLips: landmarks.contains(.outerLips) ? lowerLips(in: bounds) : [],
            innerLips: landmarks.contains(.innerLips) ? innerLips(in: bounds) : [],
            leftEyeSupport: leftSupport,
            rightEyeSupport: rightSupport
        )
    }

    private struct ValidatedSupport {
        let side: BeautyObservedEyeSide
        let contour: [SIMD2<Float>]
        let upper: [SIMD2<Float>]
        let lower: [SIMD2<Float>]
        let inner: [SIMD2<Float>]
        let outer: [SIMD2<Float>]
        let corners: [SIMD2<Float>]
        let center: SIMD2<Float>
        let pupil: SIMD2<Float>?

        var contourWidth: Float {
            (contour.map(\.x).max() ?? 0) - (contour.map(\.x).min() ?? 0)
        }
        var contourHeight: Float {
            (contour.map(\.y).max() ?? 0) - (contour.map(\.y).min() ?? 0)
        }

        func withPupil(_ pupil: SIMD2<Float>?) -> BeautyEyeSemanticSupport {
            BeautyEyeSemanticSupport(
                side: side,
                contour: contour,
                upper: upper,
                lower: lower,
                inner: inner,
                outer: outer,
                corners: corners,
                center: center,
                pupil: pupil
            )
        }
    }

    private static func validatedSupport(
        _ observed: BeautyObservedEyeSupport,
        bounds: FaceBounds
    ) -> ValidatedSupport? {
        let input = observed.contour
        guard (minimumContourPointCount...maximumContourPointCount).contains(input.count) else {
            return nil
        }
        guard input.allSatisfy({ point in
            point.isFinite && (0...1).contains(point.x) && (0...1).contains(point.y)
        }) else {
            return nil
        }

        let points = input.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        let unique = Set(points.map { PointKey($0) })
        guard unique.count >= minimumUniqueContourPointCount else {
            return nil
        }
        guard let minX = points.map(\.x).min(),
              let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(),
              let maxY = points.map(\.y).max(),
              bounds.width > 0,
              bounds.height > 0
        else {
            return nil
        }
        let relativeWidth = (maxX - minX) / bounds.width
        let relativeHeight = (maxY - minY) / bounds.height
        let relativeArea = relativeWidth * relativeHeight
        guard (minimumRelativeContourWidth...maximumRelativeContourWidth).contains(relativeWidth),
              (minimumRelativeContourHeight...maximumRelativeContourHeight).contains(relativeHeight),
              relativeArea > minimumRelativeContourArea,
              polygonArea(points) > 0.000001
        else {
            return nil
        }

        let center = points.reduce(.zero, +) / Float(points.count)
        let canonical = points.sorted { lhs, rhs in
            let leftAngle = atan2(lhs.y - center.y, lhs.x - center.x)
            let rightAngle = atan2(rhs.y - center.y, rhs.x - center.x)
            if leftAngle != rightAngle { return leftAngle < rightAngle }
            if lhs.x != rhs.x { return lhs.x < rhs.x }
            return lhs.y < rhs.y
        }
        let upper = points.filter { $0.y <= center.y }.sorted(by: stablePointOrder)
        let lower = points.filter { $0.y >= center.y }.sorted(by: stablePointOrder)
        let outerPoint = points.min { lhs, rhs in
            observed.side == .left ? stablePointOrder(lhs, rhs) : stablePointOrder(rhs, lhs)
        }!
        let innerPoint = points.max { lhs, rhs in
            observed.side == .left ? stablePointOrder(lhs, rhs) : stablePointOrder(rhs, lhs)
        }!
        let provisional = ValidatedSupport(
            side: observed.side,
            contour: canonical,
            upper: upper.isEmpty ? [points.min(by: stablePointOrder)!] : upper,
            lower: lower.isEmpty ? [points.max(by: stablePointOrder)!] : lower,
            inner: [innerPoint],
            outer: [outerPoint],
            corners: [outerPoint, innerPoint].sorted(by: stablePointOrder),
            center: center,
            pupil: nil
        )
        return ValidatedSupport(
            side: provisional.side,
            contour: provisional.contour,
            upper: provisional.upper,
            lower: provisional.lower,
            inner: provisional.inner,
            outer: provisional.outer,
            corners: provisional.corners,
            center: provisional.center,
            pupil: validatePupil(observed.pupil, support: provisional)
        )
    }

    private static func validatePairedPupils(
        left: ValidatedSupport?,
        right: ValidatedSupport?
    ) -> (left: SIMD2<Float>?, right: SIMD2<Float>?) {
        let leftPupil = left?.pupil
        let rightPupil = right?.pupil
        guard let left, let right, let leftPupil, let rightPupil else {
            return (leftPupil, rightPupil)
        }
        let widthRatio = (left.contourWidth / right.contourWidth)
        let heightRatio = (left.contourHeight / right.contourHeight)
        guard (minimumPairedPupilRatio...maximumPairedPupilRatio).contains(widthRatio),
              (minimumPairedPupilRatio...maximumPairedPupilRatio).contains(heightRatio)
        else {
            return (nil, nil)
        }
        return (leftPupil, rightPupil)
    }

    private static func validatePupil(
        _ points: [CoordinatePoint]?,
        support: ValidatedSupport
    ) -> SIMD2<Float>? {
        guard let points, points.count == 1,
              let candidate = points.first,
              candidate.isFinite,
              (0...1).contains(candidate.x),
              (0...1).contains(candidate.y)
        else {
            return nil
        }
        let point = SIMD2<Float>(Float(candidate.x), Float(candidate.y))
        let minX = support.contour.map(\.x).min()!
        let maxX = support.contour.map(\.x).max()!
        let minY = support.contour.map(\.y).min()!
        let maxY = support.contour.map(\.y).max()!
        let width = maxX - minX
        let height = maxY - minY
        guard width > 0, height > 0,
              point.x >= minX - width * pupilContainmentExpansion,
              point.x <= maxX + width * pupilContainmentExpansion,
              point.y >= minY - height * pupilContainmentExpansion,
              point.y <= maxY + height * pupilContainmentExpansion
        else { return nil }
        let dx = (point.x - (minX + maxX) / 2) / (width / 2)
        let dy = (point.y - (minY + maxY) / 2) / (height / 2)
        guard sqrt(dx * dx + dy * dy) <= maximumPupilEllipseOffset else { return nil }
        return point
    }

    private static func polygonArea(_ points: [SIMD2<Float>]) -> Float {
        guard points.count > 2 else { return 0 }
        var sum: Float = 0
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            sum += points[index].x * next.y - next.x * points[index].y
        }
        return abs(sum) * 0.5
    }

    private static func stablePointOrder(_ lhs: SIMD2<Float>, _ rhs: SIMD2<Float>) -> Bool {
        lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
    }

    private struct PointKey: Hashable {
        let x: UInt32
        let y: UInt32
        init(_ point: SIMD2<Float>) {
            x = point.x.bitPattern
            y = point.y.bitPattern
        }
    }

    private static func makeBounds(from observation: BeautyFaceObservation) -> FaceBounds {
        if let rect = observation.imageBounds,
           rect.isFinite,
           rect.width > 0,
           rect.height > 0 {
            return FaceBounds(
                x: clamped(Float(rect.x)),
                y: clamped(Float(rect.y)),
                width: clampedSize(Float(rect.width)),
                height: clampedSize(Float(rect.height))
            )
        }

        let fallbackArea = clampedArea(Float(observation.normalizedArea))
        let width = sqrt(fallbackArea * 2 / 3)
        let height = fallbackArea / width
        return FaceBounds(
            x: (1 - width) / 2,
            y: (1 - height) / 2,
            width: width,
            height: height
        )
    }

    private static func faceContour(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.05, y: 0.30),
            point(bounds, x: 0.12, y: 0.58),
            point(bounds, x: 0.28, y: 0.84),
            point(bounds, x: 0.50, y: 0.94),
            point(bounds, x: 0.72, y: 0.84),
            point(bounds, x: 0.88, y: 0.58),
            point(bounds, x: 0.95, y: 0.30)
        ]
    }

    private static func leftEye(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.25, y: 0.34),
            point(bounds, x: 0.34, y: 0.31),
            point(bounds, x: 0.42, y: 0.34)
        ]
    }

    private static func rightEye(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.58, y: 0.34),
            point(bounds, x: 0.66, y: 0.31),
            point(bounds, x: 0.75, y: 0.34)
        ]
    }

    private static func nose(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.46, y: 0.43),
            point(bounds, x: 0.50, y: 0.55),
            point(bounds, x: 0.40, y: 0.64),
            point(bounds, x: 0.60, y: 0.64)
        ]
    }

    private static func noseRoot(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.44, y: 0.48),
            point(bounds, x: 0.56, y: 0.48)
        ]
    }

    private static func noseTip(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.44, y: 0.62),
            point(bounds, x: 0.50, y: 0.66),
            point(bounds, x: 0.56, y: 0.62)
        ]
    }

    private static func outerLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.30, y: 0.76),
            point(bounds, x: 0.40, y: 0.70),
            point(bounds, x: 0.50, y: 0.68),
            point(bounds, x: 0.60, y: 0.70),
            point(bounds, x: 0.70, y: 0.76),
            point(bounds, x: 0.60, y: 0.82),
            point(bounds, x: 0.50, y: 0.84),
            point(bounds, x: 0.40, y: 0.82)
        ]
    }

    private static func upperLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.40, y: 0.70),
            point(bounds, x: 0.50, y: 0.68),
            point(bounds, x: 0.60, y: 0.70)
        ]
    }

    private static func lowerLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.40, y: 0.82),
            point(bounds, x: 0.50, y: 0.84),
            point(bounds, x: 0.60, y: 0.82)
        ]
    }

    private static func innerLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.40, y: 0.76),
            point(bounds, x: 0.45, y: 0.73),
            point(bounds, x: 0.55, y: 0.73),
            point(bounds, x: 0.60, y: 0.76),
            point(bounds, x: 0.55, y: 0.79),
            point(bounds, x: 0.45, y: 0.79)
        ]
    }

    private static func point(_ bounds: FaceBounds, x: Float, y: Float) -> SIMD2<Float> {
        SIMD2<Float>(
            clamped(bounds.x + bounds.width * x),
            clamped(bounds.y + bounds.height * y)
        )
    }

    private static func clamped(_ value: Float) -> Float {
        min(max(value, 0), 1)
    }

    private static func clampedSize(_ value: Float) -> Float {
        min(max(value, 0.05), 1)
    }

    private static func clampedArea(_ value: Float) -> Float {
        guard value.isFinite, value > 0 else {
            return 0.24
        }
        return min(max(value, 0.04), 0.64)
    }
}
