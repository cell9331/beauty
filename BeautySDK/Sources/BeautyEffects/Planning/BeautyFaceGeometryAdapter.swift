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

    // Face support is an open contour plus an independently optional median
    // path. These fixed plausibility bounds are deliberately separate from
    // the closed eye-contour topology above and are not visual-effect caps.
    static let minimumFaceContourPointCount = 7
    static let maximumFaceContourPointCount = 32
    static let minimumFaceMedianPointCount = 3
    static let maximumFaceMedianPointCount = 16
    static let minimumRelativeFaceContourWidth: Float = 0.50
    static let maximumRelativeFaceContourWidth: Float = 1.00
    static let minimumRelativeFaceContourHeight: Float = 0.20
    static let maximumRelativeFaceContourHeight: Float = 1.00
    static let minimumFaceEndpointSeparation: Float = 0.35
    static let minimumFaceCurvature: Float = 0.10
    static let minimumFaceMedianDown: Float = 0.25
    static let minimumFaceDirectionMagnitude: Float = 0.000_001
    static let minimumFaceMedianChordPosition: Float = 0.15
    static let maximumFaceMedianChordPosition: Float = 0.85
    static let maximumFaceApexDistance: Float = 0.40
    static let minimumFaceApexInteriorPointCount = 2

    static func makeGeometry(from observation: BeautyFaceObservation) -> FaceGeometry {
        let bounds = makeBounds(from: observation)
        let landmarks = observation.landmarks.availableGroups
        let observedFaceSupport = observation.imageBounds
            .flatMap(exactPositiveBounds)
            .flatMap {
                validatedFaceSupport(
                    observation.observedFaceSupport,
                    bounds: $0
                )
            }

        let observedSupports = observation.observedEyeSupport
        if observedSupports != nil, observation.observedEyeOrder != .canonical {
            return FaceGeometry(
                bounds: bounds,
                faceContour: landmarks.contains(.faceContour) ? faceContour(in: bounds) : [],
                observedFaceSupport: observedFaceSupport,
                leftEye: [],
                rightEye: [],
                nose: landmarks.contains(.nose) ? nose(in: bounds) : [],
                noseRoot: landmarks.contains(.nose) ? noseRoot(in: bounds) : [],
                noseTip: landmarks.contains(.nose) ? noseTip(in: bounds) : [],
                outerLips: landmarks.contains(.outerLips) ? outerLips(in: bounds) : [],
                upperLips: landmarks.contains(.outerLips) ? upperLips(in: bounds) : [],
                lowerLips: landmarks.contains(.outerLips) ? lowerLips(in: bounds) : [],
                innerLips: landmarks.contains(.innerLips) ? innerLips(in: bounds) : [],
                leftEyeSupport: nil,
                rightEyeSupport: nil
            )
        }
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
            observedFaceSupport: observedFaceSupport,
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
                pupil: pupil,
                span: span,
                tilt: tilt
            )
        }

        var span: SIMD2<Float> {
            SIMD2<Float>(contourWidth, contourHeight)
        }

        var tilt: Float {
            guard let inner = inner.first, let outer = outer.first,
                  inner.x.isFinite, inner.y.isFinite,
                  outer.x.isFinite, outer.y.isFinite
            else { return 0 }
            let value = atan2(inner.y - outer.y, abs(inner.x - outer.x)) / (.pi / 2)
            guard value.isFinite else { return 0 }
            return min(max(value, -1), 1)
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
        guard contourWidthIsValid(relativeWidth),
              contourHeightIsValid(relativeHeight),
              contourAreaIsValid(relativeArea),
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
        guard pairedRatioIsValid(widthRatio),
              pairedRatioIsValid(heightRatio)
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
              pupilContainmentIsValid(
                  point,
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY
              )
        else { return nil }
        let dx = (point.x - (minX + maxX) / 2) / (width / 2)
        let dy = (point.y - (minY + maxY) / 2) / (height / 2)
        guard pupilEllipseOffsetIsValid(sqrt(dx * dx + dy * dy)) else { return nil }
        return point
    }

    // MARK: - Pure locked predicates

    static func contourWidthIsValid(_ value: Float) -> Bool {
        value.isFinite && (minimumRelativeContourWidth...maximumRelativeContourWidth).contains(value)
    }

    static func contourHeightIsValid(_ value: Float) -> Bool {
        value.isFinite && (minimumRelativeContourHeight...maximumRelativeContourHeight).contains(value)
    }

    static func contourAreaIsValid(_ value: Float) -> Bool {
        value.isFinite && value > minimumRelativeContourArea
    }

    static func pupilContainmentIsValid(
        _ point: SIMD2<Float>,
        minX: Float,
        maxX: Float,
        minY: Float,
        maxY: Float
    ) -> Bool {
        guard point.x.isFinite, point.y.isFinite,
              minX.isFinite, maxX.isFinite, minY.isFinite, maxY.isFinite
        else { return false }
        let width = maxX - minX
        let height = maxY - minY
        guard width > 0, height > 0 else { return false }
        return point.x >= minX - width * pupilContainmentExpansion &&
            point.x <= maxX + width * pupilContainmentExpansion &&
            point.y >= minY - height * pupilContainmentExpansion &&
            point.y <= maxY + height * pupilContainmentExpansion
    }

    static func pupilEllipseOffsetIsValid(_ value: Float) -> Bool {
        value.isFinite && value <= maximumPupilEllipseOffset
    }

    static func pairedRatioIsValid(_ value: Float) -> Bool {
        value.isFinite && (minimumPairedPupilRatio...maximumPairedPupilRatio).contains(value)
    }

    // MARK: - Face-specific open-path validation

    static func faceContourWidthIsValid(_ value: Float) -> Bool {
        value.isFinite
            && (minimumRelativeFaceContourWidth...maximumRelativeFaceContourWidth).contains(value)
    }

    static func faceContourHeightIsValid(_ value: Float) -> Bool {
        value.isFinite
            && (minimumRelativeFaceContourHeight...maximumRelativeFaceContourHeight).contains(value)
    }

    static func faceEndpointSeparationIsValid(_ value: Float) -> Bool {
        value.isFinite && value >= minimumFaceEndpointSeparation
    }

    static func faceCurvatureIsValid(_ value: Float) -> Bool {
        value.isFinite && value >= minimumFaceCurvature
    }

    static func faceMedianDownIsValid(_ value: Float) -> Bool {
        value.isFinite && value >= minimumFaceMedianDown
    }

    static func faceDirectionMagnitudeIsValid(_ value: Float) -> Bool {
        value.isFinite && value >= minimumFaceDirectionMagnitude
    }

    static func faceMedianChordPositionIsValid(_ value: Float) -> Bool {
        value.isFinite
            && (minimumFaceMedianChordPosition...maximumFaceMedianChordPosition).contains(value)
    }

    static func faceApexDistanceIsValid(_ value: Float) -> Bool {
        value.isFinite && value <= maximumFaceApexDistance
    }

    static func faceApexInteriorPointsAreValid(
        before: Int,
        after: Int
    ) -> Bool {
        before >= minimumFaceApexInteriorPointCount
            && after >= minimumFaceApexInteriorPointCount
    }

    static func validatedFaceContour(
        _ input: [CoordinatePoint],
        bounds: FaceBounds
    ) -> [SIMD2<Float>]? {
        guard (minimumFaceContourPointCount...maximumFaceContourPointCount).contains(input.count),
              faceInputIsValid(input),
              !facePathHasNonAdjacentIntersections(input),
              let local = faceRelativePoints(input, bounds: bounds),
              let first = local.first,
              let last = local.last,
              let minX = local.map(\.x).min(),
              let maxX = local.map(\.x).max(),
              let minY = local.map(\.y).min(),
              let maxY = local.map(\.y).max()
        else {
            return nil
        }

        let width = maxX - minX
        let height = maxY - minY
        let chordX = last.x - first.x
        let chordY = last.y - first.y
        let rightProjection = chordX
        let chordLength = hypot(chordX, chordY)
        guard width.isFinite,
              height.isFinite,
              rightProjection.isFinite,
              chordLength.isFinite,
              faceContourWidthIsValid(Float(width)),
              faceContourHeightIsValid(Float(height)),
              faceDirectionMagnitudeIsValid(Float(chordLength)),
              faceEndpointSeparationIsValid(Float(rightProjection))
        else {
            return nil
        }

        let maximumDepth = local.reduce(0.0) { current, point in
            let cross = chordX * (point.y - first.y) - chordY * (point.x - first.x)
            let depth = abs(cross) / chordLength
            return max(current, depth)
        }
        guard maximumDepth.isFinite,
              faceCurvatureIsValid(Float(maximumDepth))
        else {
            return nil
        }
        return finiteSIMDPoints(input)
    }

    static func validatedFaceMedianLine(
        _ input: [CoordinatePoint],
        bounds: FaceBounds
    ) -> [SIMD2<Float>]? {
        guard (minimumFaceMedianPointCount...maximumFaceMedianPointCount).contains(input.count),
              faceInputIsValid(input),
              let local = faceRelativePoints(input, bounds: bounds),
              let first = local.first,
              let last = local.last
        else {
            return nil
        }
        let deltaX = last.x - first.x
        let deltaY = last.y - first.y
        let directionMagnitude = hypot(deltaX, deltaY)
        let downProjection = deltaY
        guard directionMagnitude.isFinite,
              downProjection.isFinite,
              faceDirectionMagnitudeIsValid(Float(directionMagnitude)),
              faceMedianDownIsValid(Float(downProjection))
        else {
            return nil
        }
        return finiteSIMDPoints(input)
    }

    private static func validatedFaceSupport(
        _ observed: BeautyObservedFaceSupport?,
        bounds: FaceBounds
    ) -> BeautyFaceSemanticSupport? {
        guard let observed,
              let contourInput = observed.contour,
              let contour = validatedFaceContour(contourInput, bounds: bounds)
        else {
            return nil
        }
        guard let medianInput = observed.medianLine,
              let medianLine = validatedFaceMedianLine(medianInput, bounds: bounds),
              let apexIndex = validatedFaceApexIndex(
                  contour: contourInput,
                  medianLine: medianInput,
                  bounds: bounds
              )
        else {
            return BeautyFaceSemanticSupport(
                contour: contour,
                medianLine: nil,
                apexIndex: nil
            )
        }
        return BeautyFaceSemanticSupport(
            contour: contour,
            medianLine: medianLine,
            apexIndex: apexIndex
        )
    }

    private static func validatedFaceApexIndex(
        contour: [CoordinatePoint],
        medianLine: [CoordinatePoint],
        bounds: FaceBounds
    ) -> Int? {
        guard let localContour = faceRelativePoints(contour, bounds: bounds),
              let localMedian = faceRelativePoints(medianLine, bounds: bounds),
              let first = localContour.first,
              let last = localContour.last,
              let medianBottom = localMedian.last
        else {
            return nil
        }
        let chordX = last.x - first.x
        let chordY = last.y - first.y
        let chordLengthSquared = chordX * chordX + chordY * chordY
        guard chordLengthSquared.isFinite,
              chordLengthSquared > 0
        else {
            return nil
        }
        let fromFirstX = medianBottom.x - first.x
        let fromFirstY = medianBottom.y - first.y
        let chordPosition = (
            fromFirstX * chordX + fromFirstY * chordY
        ) / chordLengthSquared
        guard chordPosition.isFinite,
              faceMedianChordPositionIsValid(Float(chordPosition))
        else {
            return nil
        }

        var nearestIndex: Int?
        var nearestDistance = Double.infinity
        for (index, point) in localContour.enumerated() {
            let distance = hypot(
                point.x - medianBottom.x,
                point.y - medianBottom.y
            )
            guard distance.isFinite else {
                return nil
            }
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }
        }
        guard let nearestIndex,
              faceApexDistanceIsValid(Float(nearestDistance)),
              faceApexInteriorPointsAreValid(
                  before: nearestIndex,
                  after: localContour.count - nearestIndex - 1
              )
        else {
            return nil
        }
        return nearestIndex
    }

    private static func faceInputIsValid(_ points: [CoordinatePoint]) -> Bool {
        guard points.allSatisfy({
            $0.isFinite
                && (0...1).contains($0.x)
                && (0...1).contains($0.y)
        }) else {
            return false
        }
        return Set(points.map(FacePointKey.init)).count == points.count
    }

    private static func facePathHasNonAdjacentIntersections(
        _ points: [CoordinatePoint]
    ) -> Bool {
        let segmentCount = points.count - 1
        guard segmentCount >= 3 else {
            return false
        }
        for firstIndex in 0..<segmentCount {
            let secondStart = firstIndex + 2
            guard secondStart < segmentCount else {
                continue
            }
            for secondIndex in secondStart..<segmentCount {
                if faceSegmentsIntersect(
                    points[firstIndex],
                    points[firstIndex + 1],
                    points[secondIndex],
                    points[secondIndex + 1]
                ) {
                    return true
                }
            }
        }
        return false
    }

    private static func faceSegmentsIntersect(
        _ firstStart: CoordinatePoint,
        _ firstEnd: CoordinatePoint,
        _ secondStart: CoordinatePoint,
        _ secondEnd: CoordinatePoint
    ) -> Bool {
        let firstStartSide = faceOrientation(firstStart, firstEnd, secondStart)
        let firstEndSide = faceOrientation(firstStart, firstEnd, secondEnd)
        let secondStartSide = faceOrientation(secondStart, secondEnd, firstStart)
        let secondEndSide = faceOrientation(secondStart, secondEnd, firstEnd)

        if faceSignsAreOpposite(firstStartSide, firstEndSide),
           faceSignsAreOpposite(secondStartSide, secondEndSide) {
            return true
        }
        return (firstStartSide == 0
            && facePoint(secondStart, liesOnSegmentFrom: firstStart, to: firstEnd))
            || (firstEndSide == 0
                && facePoint(secondEnd, liesOnSegmentFrom: firstStart, to: firstEnd))
            || (secondStartSide == 0
                && facePoint(firstStart, liesOnSegmentFrom: secondStart, to: secondEnd))
            || (secondEndSide == 0
                && facePoint(firstEnd, liesOnSegmentFrom: secondStart, to: secondEnd))
    }

    private static func faceOrientation(
        _ start: CoordinatePoint,
        _ end: CoordinatePoint,
        _ point: CoordinatePoint
    ) -> Double {
        (end.x - start.x) * (point.y - start.y)
            - (end.y - start.y) * (point.x - start.x)
    }

    private static func faceSignsAreOpposite(_ lhs: Double, _ rhs: Double) -> Bool {
        (lhs > 0 && rhs < 0) || (lhs < 0 && rhs > 0)
    }

    private static func facePoint(
        _ point: CoordinatePoint,
        liesOnSegmentFrom start: CoordinatePoint,
        to end: CoordinatePoint
    ) -> Bool {
        (min(start.x, end.x)...max(start.x, end.x)).contains(point.x)
            && (min(start.y, end.y)...max(start.y, end.y)).contains(point.y)
    }

    private static func faceRelativePoints(
        _ points: [CoordinatePoint],
        bounds: FaceBounds
    ) -> [(x: Double, y: Double)]? {
        guard bounds.x.isFinite,
              bounds.y.isFinite,
              bounds.width.isFinite,
              bounds.height.isFinite,
              bounds.width > 0,
              bounds.height > 0
        else {
            return nil
        }
        let originX = Double(bounds.x)
        let originY = Double(bounds.y)
        let width = Double(bounds.width)
        let height = Double(bounds.height)
        let local = points.map { point in
            (
                x: (point.x - originX) / width,
                y: (point.y - originY) / height
            )
        }
        return local.allSatisfy { $0.x.isFinite && $0.y.isFinite } ? local : nil
    }

    private static func finiteSIMDPoints(
        _ points: [CoordinatePoint]
    ) -> [SIMD2<Float>]? {
        let converted = points.map {
            SIMD2<Float>(Float($0.x), Float($0.y))
        }
        return converted.allSatisfy { $0.x.isFinite && $0.y.isFinite }
            ? converted
            : nil
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

    private struct FacePointKey: Hashable {
        let x: UInt64
        let y: UInt64

        init(_ point: CoordinatePoint) {
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

    private static func exactPositiveBounds(from rect: CoordinateRect) -> FaceBounds? {
        let x = Float(rect.x)
        let y = Float(rect.y)
        let width = Float(rect.width)
        let height = Float(rect.height)
        guard x.isFinite,
              y.isFinite,
              width.isFinite,
              height.isFinite,
              width > 0,
              height > 0
        else {
            return nil
        }
        return FaceBounds(x: x, y: y, width: width, height: height)
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
