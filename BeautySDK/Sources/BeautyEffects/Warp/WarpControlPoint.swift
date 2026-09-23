import BeautyDetection

struct WarpControlPoint: Equatable, Sendable {
    let source: SIMD2<Float>
    let target: SIMD2<Float>
    let radius: Float
    let strength: Float
    let falloff: Float
    var pixelCenterSampling: Bool = false
    // Optional anatomy-owned raster cutoff. The cut row belongs to the next
    // region: row < floor(exclusiveMaximumY * imageHeight). No public surface.
    var exclusiveMaximumY: Float? = nil
}

/// Sufficient no-fold bound for the inverse map (x - u(x,y), y).
/// For ordered inward linear cones, between the two sides every du/dx is
/// non-positive. To the left/right, its positive part is bounded by that
/// side's sum(|deltaX|/radius). Thus det(J) >= 1 - maximumSlope > 0,
/// even when same-side disks overlap. This is not a radial 2-D norm bound.
enum HorizontalInwardWarpSafety {
    static func admitted(_ points: [WarpControlPoint], maximumSlope: Double) -> [WarpControlPoint] {
        guard accepts(points, maximumSlope: maximumSlope) else { return [] }
        return points.map { point in
            var canonical = point
            canonical.pixelCenterSampling = true
            return canonical
        }
    }
    static func accepts(_ points: [WarpControlPoint], maximumSlope: Double) -> Bool {
        guard !points.isEmpty, points.count <= 64,
              maximumSlope.isFinite, maximumSlope > 0, maximumSlope < 1 else { return false }
        var leftEdge = -Double.infinity, rightEdge = Double.infinity
        var leftSlope = 0.0, rightSlope = 0.0
        for point in points {
            guard point.source.x.isFinite, point.source.y.isFinite,
                  point.target.x.isFinite, point.target.y.isFinite,
                  (0...1).contains(point.source.x), (0...1).contains(point.source.y),
                  (0...1).contains(point.target.x), (0...1).contains(point.target.y),
                  point.target.y == point.source.y,
                  point.radius.isFinite, (0.001...1).contains(point.radius),
                  point.strength.isFinite, point.strength > 0, point.falloff == 1 else { return false }
            let delta = Double(point.target.x) - Double(point.source.x)
            guard abs(delta) > 0.0001 else { return false }
            if delta > 0 {
                leftEdge = max(leftEdge, Double(point.target.x))
                leftSlope += delta / Double(point.radius)
            } else {
                rightEdge = min(rightEdge, Double(point.target.x))
                rightSlope -= delta / Double(point.radius)
            }
        }
        return leftSlope > 0 && rightSlope > 0 && leftEdge < rightEdge
            && leftSlope <= maximumSlope && rightSlope <= maximumSlope
    }
}

/// Validated, request-scoped semantic evidence for one observed eye.
///
/// This type deliberately remains target-internal: observed biometric-adjacent
/// coordinates must never become part of the public or Codable surface.
struct BeautyEyeSemanticSupport: Equatable, Sendable {
    let side: BeautyObservedEyeSide
    let contour: [SIMD2<Float>]
    let upper: [SIMD2<Float>]
    let lower: [SIMD2<Float>]
    let inner: [SIMD2<Float>]
    let outer: [SIMD2<Float>]
    let corners: [SIMD2<Float>]
    let center: SIMD2<Float>
    /// Pair-compatible pupil value retained for the existing `pupilSize`
    /// contract. Pair-ratio validation may clear this value.
    let pupil: SIMD2<Float>?
    /// Independently validated pupil owned by this observed side for gaze
    /// correction only. It remains request-local and target-internal.
    let gazePupil: SIMD2<Float>?
    /// Image-normalized bounding span `(width, height)` derived from the
    /// canonical contour. This is semantic evidence, not a visual cap.
    let span: SIMD2<Float>
    /// Signed canonical inner-to-outer tilt in `[-1, 1]`.
    let tilt: Float

    var contourEligible: Bool { !contour.isEmpty }
    var pupilEligible: Bool { pupil != nil }
    var pupilSizeEligible: Bool { pupilEligible }
    var gazeCorrectionEligible: Bool { gazePupil != nil }

    /// Compatibility initializer for existing target-internal callers. Direct
    /// constructions historically supplied one pupil meaning, so that value
    /// remains eligible for both pupil-size and gaze semantics.
    init(
        side: BeautyObservedEyeSide,
        contour: [SIMD2<Float>],
        upper: [SIMD2<Float>],
        lower: [SIMD2<Float>],
        inner: [SIMD2<Float>],
        outer: [SIMD2<Float>],
        corners: [SIMD2<Float>],
        center: SIMD2<Float>,
        pupil: SIMD2<Float>?,
        span: SIMD2<Float>,
        tilt: Float
    ) {
        self.init(
            side: side,
            contour: contour,
            upper: upper,
            lower: lower,
            inner: inner,
            outer: outer,
            corners: corners,
            center: center,
            pupil: pupil,
            gazePupil: pupil,
            span: span,
            tilt: tilt
        )
    }

    /// Adapter-owned initializer that keeps paired pupil-size compatibility
    /// separate from this side's independently validated gaze pupil.
    init(
        side: BeautyObservedEyeSide,
        contour: [SIMD2<Float>],
        upper: [SIMD2<Float>],
        lower: [SIMD2<Float>],
        inner: [SIMD2<Float>],
        outer: [SIMD2<Float>],
        corners: [SIMD2<Float>],
        center: SIMD2<Float>,
        pupil: SIMD2<Float>?,
        gazePupil: SIMD2<Float>?,
        span: SIMD2<Float>,
        tilt: Float
    ) {
        self.side = side
        self.contour = contour
        self.upper = upper
        self.lower = lower
        self.inner = inner
        self.outer = outer
        self.corners = corners
        self.center = center
        self.pupil = pupil
        self.gazePupil = gazePupil
        self.span = span
        self.tilt = tilt
    }

    // Semantic aliases keep downstream field naming explicit without exposing
    // additional storage or changing the request-scoped representation.
    var upperEyelid: [SIMD2<Float>] { upper }
    var lowerEyelid: [SIMD2<Float>] { lower }
    var innerCorner: [SIMD2<Float>] { inner }
    var outerCorner: [SIMD2<Float>] { outer }
}

/// Validated, request-scoped observed contour evidence for face semantics.
///
/// This stays separate from `FaceGeometry.faceContour`, whose seven synthetic
/// points remain the compatibility path for shipped face controls.
struct BeautyFaceSemanticSupport: Equatable, Sendable {
    let contour: [SIMD2<Float>]
    let medianLine: [SIMD2<Float>]?
    let apexIndex: Int?

    var contourEligible: Bool {
        !contour.isEmpty
    }

    var centerlineEligible: Bool {
        guard contourEligible,
              let medianLine,
              !medianLine.isEmpty,
              let apexIndex
        else {
            return false
        }
        return contour.indices.contains(apexIndex)
    }
}

extension BeautyFaceSemanticSupport: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String {
        "BeautyFaceSemanticSupport("
            + "contourCount: \(contour.count), "
            + "medianLineCount: \(medianLine?.count ?? 0), "
            + "centerlineEligible: \(centerlineEligible))"
    }

    var debugDescription: String {
        description
    }

    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "contourCount": contour.count,
                "medianLineCount": medianLine?.count ?? 0,
                "centerlineEligible": centerlineEligible,
            ],
            displayStyle: .struct
        )
    }
}

struct BeautyEyebrowSemanticTrace: Equatable, Sendable {
    let side: BeautyObservedEyebrowSide
    let points: [SIMD2<Float>]
    let innerEndpoint: SIMD2<Float>
    let outerEndpoint: SIMD2<Float>
    let center: SIMD2<Float>
    let apexIndex: Int?
}

extension BeautyEyebrowSemanticTrace: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String {
        "BeautyEyebrowSemanticTrace(side: \(side == .left ? "left" : "right"), pointCount: \(points.count), apexAvailable: \(apexIndex != nil))"
    }

    var debugDescription: String { description }

    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "isLeft": side == .left,
                "pointCount": points.count,
                "apexAvailable": apexIndex != nil,
            ],
            displayStyle: .struct
        )
    }
}

struct BeautyEyebrowSemanticSupport: Equatable, Sendable {
    let left: BeautyEyebrowSemanticTrace?
    let right: BeautyEyebrowSemanticTrace?

    var pairedEligible: Bool {
        guard let left, let right else { return false }
        return left.side != right.side
    }
}

extension BeautyEyebrowSemanticSupport: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String {
        "BeautyEyebrowSemanticSupport(leftCount: \(left?.points.count ?? 0), rightCount: \(right?.points.count ?? 0), pairedEligible: \(pairedEligible))"
    }

    var debugDescription: String { description }

    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "leftCount": left?.points.count ?? 0,
                "rightCount": right?.points.count ?? 0,
                "pairedEligible": pairedEligible,
            ],
            displayStyle: .struct
        )
    }
}

struct FaceBounds: Equatable, Sendable {
    let x: Float
    let y: Float
    let width: Float
    let height: Float

    var minX: Float { x }
    var maxX: Float { x + width }
    var minY: Float { y }
    var maxY: Float { y + height }
    var midX: Float { x + width / 2 }
    var midY: Float { y + height / 2 }
    var center: SIMD2<Float> { SIMD2<Float>(midX, midY) }
}

enum LandmarkGeometryFreshness: Equatable, Sendable {
    case fresh
    case reused
    case stale
}

struct FaceGeometry: Equatable, Sendable {
    let bounds: FaceBounds
    let faceContour: [SIMD2<Float>]
    let observedFaceSupport: BeautyFaceSemanticSupport?
    let leftEye: [SIMD2<Float>]
    let rightEye: [SIMD2<Float>]
    let nose: [SIMD2<Float>]
    let noseRoot: [SIMD2<Float>]
    let noseTip: [SIMD2<Float>]
    let outerLips: [SIMD2<Float>]
    let upperLips: [SIMD2<Float>]
    let lowerLips: [SIMD2<Float>]
    let innerLips: [SIMD2<Float>]
    let leftEyeSupport: BeautyEyeSemanticSupport?
    let rightEyeSupport: BeautyEyeSemanticSupport?
    let freshness: LandmarkGeometryFreshness
    let observedEyebrowSupport: BeautyEyebrowSemanticSupport?
    /// Negative width owns observed outer-lip support independently of legacy
    /// mouth siblings. nil retains the legacy fixture contract; empty rejects.
    let observedOuterLips: [SIMD2<Float>]?
    let observedNoseSupport: BeautyObservedNoseSupport?

    var leftEyeSemanticSupport: BeautyEyeSemanticSupport? { leftEyeSupport }
    var rightEyeSemanticSupport: BeautyEyeSemanticSupport? { rightEyeSupport }

    init(
        bounds: FaceBounds,
        faceContour: [SIMD2<Float>],
        observedFaceSupport: BeautyFaceSemanticSupport? = nil,
        leftEye: [SIMD2<Float>] = [],
        rightEye: [SIMD2<Float>] = [],
        nose: [SIMD2<Float>] = [],
        noseRoot: [SIMD2<Float>] = [],
        noseTip: [SIMD2<Float>] = [],
        outerLips: [SIMD2<Float>] = [],
        upperLips: [SIMD2<Float>] = [],
        lowerLips: [SIMD2<Float>] = [],
        innerLips: [SIMD2<Float>] = [],
        leftEyeSupport: BeautyEyeSemanticSupport? = nil,
        rightEyeSupport: BeautyEyeSemanticSupport? = nil,
        freshness: LandmarkGeometryFreshness = .fresh,
        observedEyebrowSupport: BeautyEyebrowSemanticSupport? = nil,
        observedOuterLips: [SIMD2<Float>]? = nil,
        observedNoseSupport: BeautyObservedNoseSupport? = nil
    ) {
        self.bounds = bounds
        self.faceContour = faceContour
        self.observedFaceSupport = observedFaceSupport
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.nose = nose
        self.noseRoot = noseRoot
        self.noseTip = noseTip
        self.outerLips = outerLips
        self.upperLips = upperLips
        self.lowerLips = lowerLips
        self.innerLips = innerLips
        self.leftEyeSupport = leftEyeSupport
        self.rightEyeSupport = rightEyeSupport
        self.freshness = freshness
        self.observedEyebrowSupport = observedEyebrowSupport
        self.observedOuterLips = observedOuterLips
        self.observedNoseSupport = observedNoseSupport
    }

    var center: SIMD2<Float> {
        LandmarkGeometryHelper.center(of: faceContour) ?? bounds.center
    }
}

extension FaceGeometry: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    private var landmarkPointCount: Int {
        faceContour.count
            + leftEye.count
            + rightEye.count
            + nose.count
            + noseRoot.count
            + noseTip.count
            + outerLips.count
            + upperLips.count
            + lowerLips.count
            + innerLips.count
    }

    private var observedEyeSupportCount: Int {
        [leftEyeSupport, rightEyeSupport].compactMap { $0 }.count
    }

    var description: String {
        "FaceGeometry("
            + "landmarkPointCount: \(landmarkPointCount), "
            + "observedEyeSupportCount: \(observedEyeSupportCount), "
            + "observedFaceSupportAvailable: \(observedFaceSupport != nil), "
            + "observedFaceContourCount: \(observedFaceSupport?.contour.count ?? 0), "
            + "observedFaceMedianLineCount: \(observedFaceSupport?.medianLine?.count ?? 0), "
            + "observedEyebrowSupportAvailable: \(observedEyebrowSupport != nil), "
            + "observedLeftEyebrowCount: \(observedEyebrowSupport?.left?.points.count ?? 0), "
            + "observedRightEyebrowCount: \(observedEyebrowSupport?.right?.points.count ?? 0), "
            + "observedEyebrowPairedEligible: \(observedEyebrowSupport?.pairedEligible ?? false))"
    }

    var debugDescription: String {
        description
    }

    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "landmarkPointCount": landmarkPointCount,
                "observedEyeSupportCount": observedEyeSupportCount,
                "observedFaceSupportAvailable": observedFaceSupport != nil,
                "observedFaceContourCount": observedFaceSupport?.contour.count ?? 0,
                "observedFaceMedianLineCount": observedFaceSupport?.medianLine?.count ?? 0,
                "observedEyebrowSupportAvailable": observedEyebrowSupport != nil,
                "observedLeftEyebrowCount": observedEyebrowSupport?.left?.points.count ?? 0,
                "observedRightEyebrowCount": observedEyebrowSupport?.right?.points.count ?? 0,
                "observedEyebrowPairedEligible": observedEyebrowSupport?.pairedEligible ?? false,
            ],
            displayStyle: .struct
        )
    }
}
