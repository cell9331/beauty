struct WarpControlPoint: Equatable, Sendable {
    let source: SIMD2<Float>
    let target: SIMD2<Float>
    let radius: Float
    let strength: Float
    let falloff: Float
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
    let leftEye: [SIMD2<Float>]
    let rightEye: [SIMD2<Float>]
    let nose: [SIMD2<Float>]
    let noseRoot: [SIMD2<Float>]
    let noseTip: [SIMD2<Float>]
    let outerLips: [SIMD2<Float>]
    let upperLips: [SIMD2<Float>]
    let lowerLips: [SIMD2<Float>]
    let innerLips: [SIMD2<Float>]
    let freshness: LandmarkGeometryFreshness

    init(
        bounds: FaceBounds,
        faceContour: [SIMD2<Float>],
        leftEye: [SIMD2<Float>] = [],
        rightEye: [SIMD2<Float>] = [],
        nose: [SIMD2<Float>] = [],
        noseRoot: [SIMD2<Float>] = [],
        noseTip: [SIMD2<Float>] = [],
        outerLips: [SIMD2<Float>] = [],
        upperLips: [SIMD2<Float>] = [],
        lowerLips: [SIMD2<Float>] = [],
        innerLips: [SIMD2<Float>] = [],
        freshness: LandmarkGeometryFreshness = .fresh
    ) {
        self.bounds = bounds
        self.faceContour = faceContour
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.nose = nose
        self.noseRoot = noseRoot
        self.noseTip = noseTip
        self.outerLips = outerLips
        self.upperLips = upperLips
        self.lowerLips = lowerLips
        self.innerLips = innerLips
        self.freshness = freshness
    }

    var center: SIMD2<Float> {
        LandmarkGeometryHelper.center(of: faceContour) ?? bounds.center
    }
}
