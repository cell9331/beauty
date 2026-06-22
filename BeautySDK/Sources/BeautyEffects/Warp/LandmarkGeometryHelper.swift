enum LandmarkGeometryHelper {
    static func center(of points: [SIMD2<Float>]) -> SIMD2<Float>? {
        guard !points.isEmpty else {
            return nil
        }

        let sum = points.reduce(SIMD2<Float>(0, 0)) { partial, point in
            partial + point
        }
        return sum / Float(points.count)
    }

    static func distance(_ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Float {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return (dx * dx + dy * dy).squareRoot()
    }

    static func move(_ point: SIMD2<Float>, toward target: SIMD2<Float>, by amount: Float) -> SIMD2<Float> {
        let vector = target - point
        let length = distance(point, target)
        guard length > Float.ulpOfOne else {
            return point
        }

        return clamp(point + vector / length * amount)
    }

    static func clamp(_ point: SIMD2<Float>) -> SIMD2<Float> {
        SIMD2<Float>(
            min(max(point.x, 0), 1),
            min(max(point.y, 0), 1)
        )
    }
}
