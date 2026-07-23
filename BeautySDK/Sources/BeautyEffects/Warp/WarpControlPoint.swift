import BeautyDetection

struct WarpControlPoint: Equatable, Sendable {
    let source: SIMD2<Float>
    let target: SIMD2<Float>
    let radius: Float
    let strength: Float
    let falloff: Float
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
    let pupil: SIMD2<Float>?
    /// Image-normalized bounding span `(width, height)` derived from the
    /// canonical contour. This is semantic evidence, not a visual cap.
    let span: SIMD2<Float>
    /// Signed canonical inner-to-outer tilt in `[-1, 1]`.
    let tilt: Float

    var contourEligible: Bool { !contour.isEmpty }
    var pupilEligible: Bool { pupil != nil }
    var pupilSizeEligible: Bool { pupilEligible }
    var gazeCorrectionEligible: Bool { pupilEligible }

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
        freshness: LandmarkGeometryFreshness = .fresh
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
            + "observedFaceMedianLineCount: \(observedFaceSupport?.medianLine?.count ?? 0))"
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
            ],
            displayStyle: .struct
        )
    }
}
