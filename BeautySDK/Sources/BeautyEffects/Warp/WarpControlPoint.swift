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

struct FaceGeometry: Equatable, Sendable {
    let bounds: FaceBounds
    let faceContour: [SIMD2<Float>]

    var center: SIMD2<Float> {
        LandmarkGeometryHelper.center(of: faceContour) ?? bounds.center
    }
}
