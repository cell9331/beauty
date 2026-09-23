import Foundation
import BeautyDetection

struct EyeWarpFieldEmissions: Equatable, Sendable {
    let eyeSize: [WarpControlPoint]
    let eyeDistance: [WarpControlPoint]
    let eyeYPosition: [WarpControlPoint]
    let eyeTailLift: [WarpControlPoint]
    let eyeHeight: [WarpControlPoint]
    let eyeLength: [WarpControlPoint]
    let upperEyelidLift: [WarpControlPoint]
    let pupilSize: [WarpControlPoint]
    let gazeCorrection: [WarpControlPoint]
    let lowerEyelidDrop: [WarpControlPoint]
    let eyeTilt: [WarpControlPoint]
    let innerCornerOpen: [WarpControlPoint]
    let outerCornerOpen: [WarpControlPoint]
    let eyeSymmetry: [WarpControlPoint]

    var points: [WarpControlPoint] {
        eyeSize + eyeDistance + eyeYPosition + eyeTailLift + eyeHeight + eyeLength +
            upperEyelidLift + pupilSize + gazeCorrection + lowerEyelidDrop + eyeTilt +
            innerCornerOpen + outerCornerOpen + eyeSymmetry
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.eyeSize != 0, eyeSize.isEmpty { sanitized.eyeSize = 0 }
        if strengths.eyeDistance != 0, eyeDistance.isEmpty { sanitized.eyeDistance = 0 }
        if strengths.eyeYPosition != 0, eyeYPosition.isEmpty { sanitized.eyeYPosition = 0 }
        if strengths.eyeTailLift != 0, eyeTailLift.isEmpty { sanitized.eyeTailLift = 0 }
        if strengths.eyeHeight != 0, eyeHeight.isEmpty { sanitized.eyeHeight = 0 }
        if strengths.eyeLength != 0, eyeLength.isEmpty { sanitized.eyeLength = 0 }
        if strengths.upperEyelidLift != 0, upperEyelidLift.isEmpty { sanitized.upperEyelidLift = 0 }
        if strengths.pupilSize != 0, pupilSize.isEmpty { sanitized.pupilSize = 0 }
        if strengths.gazeCorrection != 0, gazeCorrection.isEmpty { sanitized.gazeCorrection = 0 }
        if strengths.lowerEyelidDrop != 0, lowerEyelidDrop.isEmpty { sanitized.lowerEyelidDrop = 0 }
        if strengths.eyeTilt != 0, eyeTilt.isEmpty { sanitized.eyeTilt = 0 }
        if strengths.innerCornerOpen != 0, innerCornerOpen.isEmpty { sanitized.innerCornerOpen = 0 }
        if strengths.outerCornerOpen != 0, outerCornerOpen.isEmpty { sanitized.outerCornerOpen = 0 }
        if strengths.eyeSymmetry != 0, eyeSymmetry.isEmpty { sanitized.eyeSymmetry = 0 }
        return sanitized
    }
}

/// Package-internal aggregate proof that automatic gaze correction moves
/// validated pupils toward their own observed eye centers.  This deliberately
/// carries no points, side labels, or per-eye payload and is never surfaced by
/// the public facade or diagnostics.
struct GazeCorrectionAggregateEvidence: Equatable, Sendable {
    let eligibleEyeCount: Int
    let correctedEyeCount: Int
    let rejectedEyeCount: Int
    let allReduced: Bool
    let abstained: Bool
    let minimumReductionQ16: Int
}

struct EyeWarpProvider: WarpControlPointProvider {
    func makeControlPoints(face: FaceGeometry, strengths: BeautyEffectiveStrengths) -> WarpControlPointResult {
        let emissions = fieldEmissions(face: face, strengths: strengths)
        let requestedWork = [
            strengths.eyeSize, strengths.eyeDistance, strengths.eyeYPosition, strengths.eyeTailLift,
            strengths.eyeHeight, strengths.eyeLength, strengths.upperEyelidLift, strengths.pupilSize,
            strengths.gazeCorrection, strengths.lowerEyelidDrop, strengths.eyeTilt,
            strengths.innerCornerOpen, strengths.outerCornerOpen, strengths.eyeSymmetry
        ].contains { abs($0) > Float.ulpOfOne }
        return WarpControlPointResult(
            points: emissions.points,
            skipReason: requestedWork && emissions.points.isEmpty ? "eye_inputs_missing" : nil
        )
    }

    func fieldEmissions(face: FaceGeometry, strengths: BeautyEffectiveStrengths) -> EyeWarpFieldEmissions {
        let supports = semanticSupports(in: face)
        let gazeSupports = gazeSupports(in: face)
        let centers = supports.map(\.center)
        let leftCenter = supports.first(where: { $0.side == .left })?.center
        let rightCenter = supports.first(where: { $0.side == .right })?.center
        return EyeWarpFieldEmissions(
            eyeSize: strengths.eyeSize > 0 ? sizePoints(centers: centers, face: face, strength: strengths.eyeSize) : [],
            eyeDistance: abs(strengths.eyeDistance) > Float.ulpOfOne
                ? distancePoints(leftCenter: leftCenter, rightCenter: rightCenter, face: face, strength: strengths.eyeDistance) : [],
            eyeYPosition: abs(strengths.eyeYPosition) > Float.ulpOfOne
                ? verticalPoints(centers: centers, face: face, strength: strengths.eyeYPosition) : [],
            eyeTailLift: strengths.eyeTailLift > 0 ? tailLiftPoints(face: face, strength: strengths.eyeTailLift) : [],
            eyeHeight: strengths.eyeHeight > 0 ? supports.flatMap { heightPoints(support: $0, face: face, strength: strengths.eyeHeight) } : [],
            eyeLength: strengths.eyeLength > 0 ? supports.flatMap { lengthPoints(support: $0, face: face, strength: strengths.eyeLength) } : [],
            upperEyelidLift: strengths.upperEyelidLift > 0 ? supports.flatMap { lidPoints(support: $0.upper, center: $0.center, face: face, strength: strengths.upperEyelidLift, upward: true, cap: BeautySafetyCaps.upperEyelidLift) } : [],
            pupilSize: strengths.pupilSize > 0 ? supports.flatMap { pupilSizePoints(support: $0, face: face, strength: strengths.pupilSize) } : [],
            gazeCorrection: strengths.gazeCorrection > 0 ? gazeSupports.compactMap { gazeCandidate(support: $0, face: face, strength: strengths.gazeCorrection)?.point } : [],
            lowerEyelidDrop: strengths.lowerEyelidDrop > 0 ? supports.flatMap { lidPoints(support: $0.lower, center: $0.center, face: face, strength: strengths.lowerEyelidDrop, upward: false, cap: BeautySafetyCaps.lowerEyelidDrop) } : [],
            eyeTilt: abs(strengths.eyeTilt) > Float.ulpOfOne ? supports.flatMap { tiltPoints(support: $0, face: face, strength: strengths.eyeTilt) } : [],
            innerCornerOpen: strengths.innerCornerOpen > 0 ? supports.flatMap { cornerPoints(support: $0.innerCorner, center: $0.center, face: face, strength: strengths.innerCornerOpen, cap: BeautySafetyCaps.innerCornerOpen) } : [],
            outerCornerOpen: strengths.outerCornerOpen > 0 ? supports.flatMap { cornerPoints(support: $0.outerCorner, center: $0.center, face: face, strength: strengths.outerCornerOpen, cap: BeautySafetyCaps.outerCornerOpen) } : [],
            eyeSymmetry: strengths.eyeSymmetry > 0 ? symmetryPoints(supports: supports, face: face, strength: strengths.eyeSymmetry) : []
        )
    }

    /// Returns aggregate-only evidence reconciled against the exact final gaze
    /// points admitted after conflict resolution. Geometry and side identity
    /// remain in memory and never cross this helper's fixed six-field result.
    func gazeCorrectionEvidence(
        face: FaceGeometry,
        strength: Float,
        admittedPoints: [WarpControlPoint]
    ) -> GazeCorrectionAggregateEvidence {
        guard strength.isFinite, strength > 0 else {
            return emptyGazeEvidence
        }
        let candidates = gazeSupports(in: face).compactMap {
            gazeCandidate(support: $0, face: face, strength: strength)
        }
        var unmatched = admittedPoints
        var reductions = [Float]()
        for candidate in candidates {
            guard let index = unmatched.firstIndex(of: candidate.point) else {
                continue
            }
            unmatched.remove(at: index)
            reductions.append(candidate.sample.baselineOffset - candidate.sample.correctedOffset)
        }
        let correctedCount = reductions.filter { $0.isFinite && $0 > 0 }.count
        let rejectedCount = candidates.count - correctedCount
        let allReduced = !candidates.isEmpty
            && correctedCount == candidates.count
            && rejectedCount == 0
        let minimumReductionQ16 = allReduced
            ? checkedGazeReductionQ16(reductions.min() ?? 0)
            : 0
        let creditable = allReduced && minimumReductionQ16 > 0
        return GazeCorrectionAggregateEvidence(
            eligibleEyeCount: candidates.count,
            correctedEyeCount: correctedCount,
            rejectedEyeCount: rejectedCount,
            allReduced: creditable,
            abstained: correctedCount == 0,
            minimumReductionQ16: creditable ? minimumReductionQ16 : 0
        )
    }

    private var emptyGazeEvidence: GazeCorrectionAggregateEvidence {
        GazeCorrectionAggregateEvidence(
            eligibleEyeCount: 0,
            correctedEyeCount: 0,
            rejectedEyeCount: 0,
            allReduced: false,
            abstained: true,
            minimumReductionQ16: 0
        )
    }

    private func checkedGazeReductionQ16(_ reduction: Float) -> Int {
        guard reduction.isFinite, reduction > 0 else { return 0 }
        let scaled = Double(reduction) * 65_536
        guard scaled.isFinite, scaled >= 1, scaled <= 65_536 else { return 0 }
        let rounded = scaled.rounded(.toNearestOrAwayFromZero)
        guard rounded >= 1, rounded <= 65_536 else { return 0 }
        return Int(rounded)
    }

    private func semanticSupports(in face: FaceGeometry) -> [BeautyEyeSemanticSupport] {
        if let left = face.leftEyeSupport, let right = face.rightEyeSupport {
            return [left, right]
        }
        // Nil observed support is the compatibility fixture path from Phase 41.
        guard face.leftEyeSupport == nil, face.rightEyeSupport == nil,
              let left = legacySupport(face.leftEye, side: .left),
              let right = legacySupport(face.rightEye, side: .right)
        else { return [] }
        return [left, right]
    }

    /// Positive gaze correction accepts only independently eligible observed
    /// sides. Unlike the compatibility selector above, this path never creates
    /// legacy support and never requires or borrows the peer eye.
    private func gazeSupports(in face: FaceGeometry) -> [BeautyEyeSemanticSupport] {
        [face.leftEyeSupport, face.rightEyeSupport]
            .compactMap { $0 }
            .filter(\.gazeCorrectionEligible)
    }

    private func legacySupport(_ points: [SIMD2<Float>], side: BeautyObservedEyeSide) -> BeautyEyeSemanticSupport? {
        guard points.count >= 2, let center = LandmarkGeometryHelper.center(of: points),
              points.allSatisfy(isFinitePoint) else { return nil }
        let upper = points.filter { $0.y <= center.y }
        let lower = points.filter { $0.y >= center.y }
        let outer = side == .left ? points.min { $0.x < $1.x } : points.max { $0.x < $1.x }
        let inner = side == .left ? points.max { $0.x < $1.x } : points.min { $0.x < $1.x }
        guard let outer, let inner else { return nil }
        return BeautyEyeSemanticSupport(
            side: side, contour: points, upper: upper.isEmpty ? [outer] : upper,
            lower: lower.isEmpty ? [inner] : lower, inner: [inner], outer: [outer], corners: [outer, inner],
            center: center, pupil: nil,
            span: SIMD2<Float>(points.map(\.x).max()! - points.map(\.x).min()!, points.map(\.y).max()! - points.map(\.y).min()!), tilt: 0
        )
    }

    private func heightPoints(support: BeautyEyeSemanticSupport, face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard support.contourEligible else { return [] }
        let d = face.bounds.height * 0.025 * strength / BeautySafetyCaps.eyeHeight
        return lidPoints(support: support.upper, center: support.center, face: face, strength: strength, upward: true, cap: BeautySafetyCaps.eyeHeight, displacement: d) +
            lidPoints(support: support.lower, center: support.center, face: face, strength: strength, upward: false, cap: BeautySafetyCaps.eyeHeight, displacement: d)
    }

    private func lengthPoints(support: BeautyEyeSemanticSupport, face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard support.contourEligible, let inner = support.inner.first, let outer = support.outer.first else { return [] }
        let d = face.bounds.width * 0.025 * strength / BeautySafetyCaps.eyeLength
        let innerDirection: Float = inner.x >= support.center.x ? 1 : -1
        let outerDirection = -innerDirection
        return makePoints(sources: [inner, outer], targets: [SIMD2<Float>(inner.x + d * innerDirection, inner.y), SIMD2<Float>(outer.x + d * outerDirection, outer.y)], face: face, radius: face.bounds.width * 0.08, strength: strength)
    }

    private func lidPoints(support: [SIMD2<Float>], center: SIMD2<Float>, face: FaceGeometry, strength: Float, upward: Bool, cap: Float, displacement: Float? = nil) -> [WarpControlPoint] {
        guard !support.isEmpty else { return [] }
        let d = displacement ?? face.bounds.height * 0.025 * strength / cap
        return makePoints(sources: support, targets: support.map { SIMD2<Float>($0.x, $0.y + (upward ? -d : d)) }, face: face, radius: face.bounds.width * 0.07, strength: strength)
    }

    private func pupilSizePoints(support: BeautyEyeSemanticSupport, face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let pupil = support.pupil, support.contourEligible else { return [] }
        let d = face.bounds.width * 0.012 * strength / BeautySafetyCaps.pupilSize
        let offsets = [SIMD2<Float>(-d, 0), SIMD2<Float>(d, 0), SIMD2<Float>(0, -d), SIMD2<Float>(0, d)]
        return makePoints(sources: offsets.map { pupil + $0 }, targets: offsets.map { pupil + $0 * 1.8 }, face: face, radius: face.bounds.width * 0.045, strength: strength)
    }

    private struct GazeSample {
        let pupil: SIMD2<Float>
        let target: SIMD2<Float>
        let baselineOffset: Float
        let correctedOffset: Float
    }

    private struct GazeCandidate {
        let sample: GazeSample
        let point: WarpControlPoint
    }

    private func gazeSample(support: BeautyEyeSemanticSupport, strength: Float) -> GazeSample? {
        guard let pupil = support.gazePupil, support.contourEligible else { return nil }
        let delta = support.center - pupil
        let length = sqrt(delta.x * delta.x + delta.y * delta.y)
        guard Self.gazeDisplacementIsActive(length), strength.isFinite, strength > 0 else { return nil }
        let blend = min(0.35, 0.35 * strength / BeautySafetyCaps.gazeCorrection)
        let target = pupil + delta * blend
        let corrected = sqrt((support.center.x - target.x) * (support.center.x - target.x) +
            (support.center.y - target.y) * (support.center.y - target.y))
        guard target.x.isFinite, target.y.isFinite, corrected.isFinite else { return nil }
        return GazeSample(pupil: pupil, target: target, baselineOffset: length, correctedOffset: corrected)
    }

    static func gazeDisplacementIsActive(_ length: Float) -> Bool {
        length.isFinite && length > 0.002
    }

    private func gazeCandidate(
        support: BeautyEyeSemanticSupport,
        face: FaceGeometry,
        strength: Float
    ) -> GazeCandidate? {
        guard let sample = gazeSample(support: support, strength: strength),
              apertureIsSimple(support.contour),
              pointIsStrictlyInside(sample.pupil, contour: support.contour),
              pointIsStrictlyInside(sample.target, contour: support.contour),
              let sourceClearance = minimumClosedSegmentDistance(
                  from: sample.pupil,
                  contour: support.contour
              ),
              let targetClearance = minimumClosedSegmentDistance(
                  from: sample.target,
                  contour: support.contour
              )
        else { return nil }
        let radius = min(
            face.bounds.width * 0.05,
            min(sourceClearance, targetClearance) * 0.5
        )
        guard radius.isFinite, radius > 0,
              isFinitePoint(sample.pupil), isFinitePoint(sample.target),
              (0...1).contains(sample.pupil.x), (0...1).contains(sample.pupil.y),
              (0...1).contains(sample.target.x), (0...1).contains(sample.target.y)
        else { return nil }
        let point = WarpControlPoint(
            source: sample.pupil,
            target: sample.target,
            radius: radius,
            strength: strength,
            // A linear cone retains the same strict aperture support and
            // endpoint motion, without quadratically suppressing most of the
            // already small pupil field. Its maximum spatial slope is lower.
            falloff: 1
        )
        return GazeCandidate(sample: sample, point: point)
    }

    private func apertureIsSimple(_ contour: [SIMD2<Float>]) -> Bool {
        guard contour.count >= 3,
              contour.allSatisfy({ point in
                  isFinitePoint(point)
                      && (0...1).contains(point.x)
                      && (0...1).contains(point.y)
              }),
              Set(contour.map(PointBits.init)).count == contour.count,
              abs(signedPolygonArea(contour)) > Float.ulpOfOne
        else { return false }

        for first in contour.indices {
            let firstNext = (first + 1) % contour.count
            for second in contour.indices where second > first {
                let secondNext = (second + 1) % contour.count
                if firstNext == second || secondNext == first {
                    continue
                }
                if segmentsIntersect(
                    contour[first], contour[firstNext],
                    contour[second], contour[secondNext]
                ) {
                    return false
                }
            }
        }
        return true
    }

    private func signedPolygonArea(_ contour: [SIMD2<Float>]) -> Float {
        contour.indices.reduce(0) { result, index in
            let next = contour[(index + 1) % contour.count]
            return result + contour[index].x * next.y - next.x * contour[index].y
        } * 0.5
    }

    private func pointIsStrictlyInside(
        _ point: SIMD2<Float>,
        contour: [SIMD2<Float>]
    ) -> Bool {
        guard isFinitePoint(point), apertureIsSimple(contour) else { return false }
        if contour.indices.contains(where: { index in
            pointLiesOnSegment(
                point,
                start: contour[index],
                end: contour[(index + 1) % contour.count]
            )
        }) {
            return false
        }
        var inside = false
        for index in contour.indices {
            let start = contour[index]
            let end = contour[(index + 1) % contour.count]
            let crosses = (start.y > point.y) != (end.y > point.y)
            if crosses {
                let intersectionX = (end.x - start.x) * (point.y - start.y)
                    / (end.y - start.y) + start.x
                if point.x < intersectionX {
                    inside.toggle()
                }
            }
        }
        return inside
    }

    private func minimumClosedSegmentDistance(
        from point: SIMD2<Float>,
        contour: [SIMD2<Float>]
    ) -> Float? {
        guard isFinitePoint(point), apertureIsSimple(contour) else { return nil }
        var minimum = Float.infinity
        for index in contour.indices {
            let start = contour[index]
            let end = contour[(index + 1) % contour.count]
            let segment = end - start
            let lengthSquared = segment.x * segment.x + segment.y * segment.y
            guard lengthSquared.isFinite, lengthSquared > 0 else { return nil }
            let offset = point - start
            let projection = (offset.x * segment.x + offset.y * segment.y) / lengthSquared
            let t = min(max(projection, 0), 1)
            let nearest = start + segment * t
            let delta = point - nearest
            let distance = sqrt(delta.x * delta.x + delta.y * delta.y)
            guard distance.isFinite else { return nil }
            minimum = min(minimum, distance)
        }
        return minimum.isFinite ? minimum : nil
    }

    private func segmentsIntersect(
        _ firstStart: SIMD2<Float>,
        _ firstEnd: SIMD2<Float>,
        _ secondStart: SIMD2<Float>,
        _ secondEnd: SIMD2<Float>
    ) -> Bool {
        let firstStartSide = orientation(firstStart, firstEnd, secondStart)
        let firstEndSide = orientation(firstStart, firstEnd, secondEnd)
        let secondStartSide = orientation(secondStart, secondEnd, firstStart)
        let secondEndSide = orientation(secondStart, secondEnd, firstEnd)
        if signsAreOpposite(firstStartSide, firstEndSide),
           signsAreOpposite(secondStartSide, secondEndSide) {
            return true
        }
        return (firstStartSide == 0 && pointLiesOnSegment(secondStart, start: firstStart, end: firstEnd))
            || (firstEndSide == 0 && pointLiesOnSegment(secondEnd, start: firstStart, end: firstEnd))
            || (secondStartSide == 0 && pointLiesOnSegment(firstStart, start: secondStart, end: secondEnd))
            || (secondEndSide == 0 && pointLiesOnSegment(firstEnd, start: secondStart, end: secondEnd))
    }

    private func orientation(
        _ start: SIMD2<Float>,
        _ end: SIMD2<Float>,
        _ point: SIMD2<Float>
    ) -> Float {
        (end.x - start.x) * (point.y - start.y)
            - (end.y - start.y) * (point.x - start.x)
    }

    private func signsAreOpposite(_ lhs: Float, _ rhs: Float) -> Bool {
        (lhs > 0 && rhs < 0) || (lhs < 0 && rhs > 0)
    }

    private func pointLiesOnSegment(
        _ point: SIMD2<Float>,
        start: SIMD2<Float>,
        end: SIMD2<Float>
    ) -> Bool {
        orientation(start, end, point) == 0
            && (min(start.x, end.x)...max(start.x, end.x)).contains(point.x)
            && (min(start.y, end.y)...max(start.y, end.y)).contains(point.y)
    }

    private struct PointBits: Hashable {
        let x: UInt32
        let y: UInt32

        init(_ point: SIMD2<Float>) {
            x = point.x.bitPattern
            y = point.y.bitPattern
        }
    }

    private func tiltPoints(support: BeautyEyeSemanticSupport, face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        let angle = 0.18 * strength / BeautySafetyCaps.eyeTilt
        let c = cos(angle), s = sin(angle)
        let targets = support.contour.map { point in
            let d = point - support.center
            return support.center + SIMD2<Float>(d.x * c - d.y * s, d.x * s + d.y * c)
        }
        return makePoints(sources: support.contour, targets: targets, face: face, radius: face.bounds.width * 0.09, strength: abs(strength))
    }

    private func cornerPoints(support: [SIMD2<Float>], center: SIMD2<Float>, face: FaceGeometry, strength: Float, cap: Float) -> [WarpControlPoint] {
        guard let point = support.first else { return [] }
        let direction: Float = point.x >= center.x ? 1 : -1
        let d = face.bounds.width * 0.020 * strength / cap
        return makePoints(sources: [point], targets: [SIMD2<Float>(point.x + direction * d, point.y)], face: face, radius: face.bounds.width * 0.06, strength: strength)
    }

    private func symmetryPoints(supports: [BeautyEyeSemanticSupport], face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard supports.count == 2,
              let left = supports.first(where: { $0.side == .left }),
              let right = supports.first(where: { $0.side == .right })
        else { return [] }
        let midpoint = (left.center + right.center) / 2
        let spanX = (left.span.x + right.span.x) / 2
        let spanY = (left.span.y + right.span.y) / 2
        let centerDelta = (right.center.x - left.center.x).isFinite ? abs(right.center.x - left.center.x) : .infinity
        let spanDelta = abs(left.span.x - right.span.x) + abs(left.span.y - right.span.y)
        func normalizedPoint(_ point: SIMD2<Float>) -> Bool {
            point.x.isFinite && point.y.isFinite &&
                (0...1).contains(point.x) && (0...1).contains(point.y)
        }
        func plausible(_ support: BeautyEyeSemanticSupport) -> Bool {
            normalizedPoint(support.center) &&
                support.span.x.isFinite && support.span.y.isFinite &&
                support.span.x > 0 && support.span.y > 0 &&
                support.span.x <= 1 && support.span.y <= 1 &&
                support.tilt.isFinite && abs(support.tilt) <= 1 &&
                !support.contour.isEmpty && support.contour.allSatisfy(normalizedPoint)
        }
        guard plausible(left), plausible(right),
              centerDelta.isFinite, centerDelta > 0,
              spanX.isFinite, spanY.isFinite, spanX > 0, spanY > 0,
              spanDelta > 0.0001 || abs(left.tilt - right.tilt) > 0.0001
        else { return [] }
        let blend = min(max(0.30 * strength / BeautySafetyCaps.eyeSymmetry, 0), 0.30)
        guard blend > Float.ulpOfOne else { return [] }
        let targetTilt = (left.tilt + right.tilt) / 2
        var points: [WarpControlPoint] = []
        for support in [left, right] {
            let targetCenter = support.center + (midpoint - support.center) * blend
            points += makePoints(
                sources: [support.center],
                targets: [targetCenter],
                face: face,
                radius: face.bounds.width * 0.08,
                strength: strength
            )

            // Scale each measured contour toward the paired midpoint span,
            // then rotate the offset toward the paired midpoint tilt. Using
            // the real contour points keeps the emitted side identity while
            // making the span/tilt effect observable in the warp vectors.
            let scaleX = 1 + ((spanX / support.span.x) - 1) * blend
            let scaleY = 1 + ((spanY / support.span.y) - 1) * blend
            let angle = (targetTilt - support.tilt) * (Float.pi / 2) * blend
            let cosine = cos(angle)
            let sine = sin(angle)
            let targets = support.contour.map { point -> SIMD2<Float> in
                let offset = point - support.center
                let scaled = SIMD2<Float>(offset.x * scaleX, offset.y * scaleY)
                let rotated = SIMD2<Float>(
                    scaled.x * cosine - scaled.y * sine,
                    scaled.x * sine + scaled.y * cosine
                )
                return targetCenter + rotated
            }
            points += makePoints(
                sources: support.contour,
                targets: targets,
                face: face,
                radius: face.bounds.width * 0.06,
                strength: strength
            )
        }
        return points
    }

    private func sizePoints(centers: [SIMD2<Float>], face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        let displacement = face.bounds.height * 0.025 * strength / BeautySafetyCaps.eyeSize
        return centers.flatMap { center in
            makePoints(sources: [SIMD2<Float>(center.x, center.y - displacement), SIMD2<Float>(center.x, center.y + displacement)], targets: [SIMD2<Float>(center.x, center.y - displacement * 1.8), SIMD2<Float>(center.x, center.y + displacement * 1.8)], face: face, radius: face.bounds.width * 0.12, strength: strength)
        }
    }

    private func distancePoints(leftCenter: SIMD2<Float>?, rightCenter: SIMD2<Float>?, face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let leftCenter, let rightCenter else { return [] }
        let displacement = face.bounds.width * 0.045 * abs(strength) / BeautySafetyCaps.eyeDistance
        let direction: Float = strength < 0 ? -1 : 1
        return makePoints(sources: [leftCenter, rightCenter], targets: [SIMD2<Float>(leftCenter.x - displacement * direction, leftCenter.y), SIMD2<Float>(rightCenter.x + displacement * direction, rightCenter.y)], face: face, radius: face.bounds.width * 0.14, strength: abs(strength))
    }

    private func verticalPoints(centers: [SIMD2<Float>], face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        let displacement = face.bounds.height * 0.035 * abs(strength) / BeautySafetyCaps.eyeYPosition
        let direction: Float = strength < 0 ? -1 : 1
        return makePoints(sources: centers, targets: centers.map { SIMD2<Float>($0.x, $0.y + displacement * direction) }, face: face, radius: face.bounds.width * 0.14, strength: abs(strength))
    }

    private func tailLiftPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let leftTail = face.leftEye.min(by: { $0.x < $1.x }), let rightTail = face.rightEye.max(by: { $0.x < $1.x }) else { return [] }
        let displacement = face.bounds.height * 0.035 * strength / BeautySafetyCaps.eyeTailLift
        return makePoints(sources: [leftTail, rightTail], targets: [SIMD2<Float>(leftTail.x, leftTail.y - displacement), SIMD2<Float>(rightTail.x, rightTail.y - displacement)], face: face, radius: face.bounds.width * 0.10, strength: strength)
    }

    private func makePoints(sources: [SIMD2<Float>], targets: [SIMD2<Float>], face: FaceGeometry, radius: Float, strength: Float) -> [WarpControlPoint] {
        guard sources.count == targets.count, strength.isFinite, strength > Float.ulpOfOne,
              sources.indices.allSatisfy({ isFinitePoint(sources[$0]) && isFinitePoint(targets[$0]) }) else { return [] }
        return zip(sources, targets).map { makePoint(source: $0.0, target: $0.1, radius: radius, strength: strength) }
    }

    private func makePoint(source: SIMD2<Float>, target: SIMD2<Float>, radius: Float, strength: Float) -> WarpControlPoint {
        WarpControlPoint(source: LandmarkGeometryHelper.clamp(source), target: LandmarkGeometryHelper.clamp(target), radius: min(max(radius, 0.035), 0.24), strength: strength, falloff: 2)
    }

    private func isFinitePoint(_ point: SIMD2<Float>) -> Bool { point.x.isFinite && point.y.isFinite }
}
