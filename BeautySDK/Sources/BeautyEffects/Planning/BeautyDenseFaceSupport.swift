import BeautyDetection
import Foundation

/// Request-local use of the 478-point carrier; no guessed confidence/depth.
struct BeautyDenseFaceSupport: Equatable, Sendable, CustomStringConvertible, CustomReflectable {
    let mesh: BeautyFaceMesh
    let oval: [SIMD2<Float>]
    let protectionBounds: [FaceBounds]
    let geometryScale: Float

    init(mesh: BeautyFaceMesh) {
        self.mesh = mesh
        let observedOval = Self.path(mesh, MediaPipeFaceTopology.oval)
        oval = Self.simplePolygon(observedOval) ? observedOval : []
        let paths = [
            MediaPipeFaceTopology.leftEye, MediaPipeFaceTopology.rightEye,
            MediaPipeFaceTopology.leftBrowEnvelope, MediaPipeFaceTopology.rightBrowEnvelope,
            MediaPipeFaceTopology.outerLip, MediaPipeFaceTopology.innerLip,
        ]
        protectionBounds = paths.compactMap { Self.bounds(Self.path(mesh, $0)) }
        geometryScale = Self.poseScale(mesh.facialTransformation) ?? 1
    }

    /// Normalize a positive near-uniform scale, then require an orthogonal
    /// right-handed rotation. A merely invertible/sheared 4x4 is not a pose.
    /// Facing cosine is invariant to roll and proper mirror convention; it
    /// deliberately does not infer a visible side, occlusion or metric depth.
    static func poseScale(_ matrix: [Float]?) -> Float? {
        guard let matrix, matrix.count == 16, matrix.allSatisfy(\.isFinite) else { return nil }
        let columns = (0..<3).map { SIMD3<Float>(matrix[$0], matrix[4 + $0], matrix[8 + $0]) }
        let lengths = columns.map { sqrt($0.x * $0.x + $0.y * $0.y + $0.z * $0.z) }
        guard lengths.allSatisfy({ $0.isFinite && $0 > 0.0001 }),
            lengths.max()! / lengths.min()! <= 1.02
        else { return nil }
        let r = zip(columns, lengths).map { $0 / $1 }
        func dot(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float { a.x * b.x + a.y * b.y + a.z * b.z }
        guard abs(dot(r[0], r[1])) <= 0.02, abs(dot(r[0], r[2])) <= 0.02,
            abs(dot(r[1], r[2])) <= 0.02
        else { return nil }
        let cross = SIMD3<Float>(
            r[0].y * r[1].z - r[0].z * r[1].y,
            r[0].z * r[1].x - r[0].x * r[1].z,
            r[0].x * r[1].y - r[0].y * r[1].x)
        guard dot(cross, r[2]) > 0.98 else { return nil }
        let t = min(1, max(0, (r[2].z - 0.35) / (0.92 - 0.35)))
        return t * t * (3 - 2 * t)
    }

    func iris(side: BeautyObservedEyeSide, eye: BeautyEyeSemanticSupport) -> [SIMD2<Float>]? {
        let indices = side == .left ? MediaPipeFaceTopology.leftIris : MediaPipeFaceTopology.rightIris
        let centerIndex = side == .left ? 468 : 473
        let ring = Self.path(mesh, indices)
        let center = Self.path(mesh, [centerIndex])[0]
        guard let bounds = Self.bounds(ring), let eyeBounds = Self.bounds(eye.contour),
            bounds.width >= eyeBounds.width * 0.04, bounds.width <= eyeBounds.width * 0.65,
            bounds.height >= eyeBounds.height * 0.08, bounds.height <= eyeBounds.height * 4,
            center.x > bounds.minX, center.x < bounds.maxX,
            center.y > bounds.minY, center.y < bounds.maxY,
            Self.contains(center, in: eye.contour)
        else { return nil }
        // MediaPipe describes the complete projected iris, including portions
        // behind a lid. Only observed ring points INSIDE the eyelid polygon
        // authorize deformation. Require both horizontal sides and a minimum
        // aperture; a hidden top/bottom point is never promoted to visible.
        let visible = ring.filter { Self.contains($0, in: eye.contour) }
        guard visible.count >= 2, visible.contains(where: { $0.x < center.x }),
            visible.contains(where: { $0.x > center.x })
        else { return nil }
        return visible
    }

    /// Conservative geometric exclusion in pixel-center coordinates, unioned
    /// with existing coarse guards and host masks. It is not segmentation.
    func admitsTexture(x: Int, y: Int, width: Int, height: Int, radius: Int) -> Bool {
        let point = SIMD2<Float>((Float(x) + 0.5) / Float(width), (Float(y) + 0.5) / Float(height))
        guard Self.contains(point, in: oval) else { return false }
        let paddingX = Float(radius + 1) / Float(width)
        let paddingY = Float(radius + 1) / Float(height)
        return !protectionBounds.contains { bounds in
            point.x >= bounds.minX - paddingX && point.x <= bounds.maxX + paddingX
                && point.y >= bounds.minY - paddingY && point.y <= bounds.maxY + paddingY
        }
    }

    static func path(_ mesh: BeautyFaceMesh, _ indices: [Int]) -> [SIMD2<Float>] {
        indices.map { SIMD2<Float>(mesh.points[$0].x, mesh.points[$0].y) }
    }
    static func bounds(_ points: [SIMD2<Float>]) -> FaceBounds? {
        guard let x0 = points.map(\.x).min(), let x1 = points.map(\.x).max(),
            let y0 = points.map(\.y).min(), let y1 = points.map(\.y).max(),
            x1 > x0, y1 > y0
        else { return nil }
        return FaceBounds(x: x0, y: y0, width: x1 - x0, height: y1 - y0)
    }
    static func simplePolygon(_ points: [SIMD2<Float>]) -> Bool {
        guard points.count >= 3, Set(points).count == points.count else { return false }
        func cross(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ c: SIMD2<Float>) -> Double {
            (Double(b.x) - Double(a.x)) * (Double(c.y) - Double(a.y)) - (Double(b.y) - Double(a.y))
                * (Double(c.x) - Double(a.x))
        }
        func onSegment(_ p: SIMD2<Float>, _ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Bool {
            abs(cross(a, b, p)) <= 1e-10 && p.x >= min(a.x, b.x) && p.x <= max(a.x, b.x)
                && p.y >= min(a.y, b.y) && p.y <= max(a.y, b.y)
        }
        var area = 0.0
        for i in points.indices {
            let a = points[i]
            let b = points[(i + 1) % points.count]
            area += Double(a.x) * Double(b.y) - Double(a.y) * Double(b.x)
            for j in (i + 1)..<points.count {
                if j == i + 1 || (i == 0 && j == points.count - 1) { continue }
                let c = points[j]
                let d = points[(j + 1) % points.count]
                let abC = cross(a, b, c)
                let abD = cross(a, b, d)
                let cdA = cross(c, d, a)
                let cdB = cross(c, d, b)
                if (abC * abD < 0 && cdA * cdB < 0) || onSegment(c, a, b) || onSegment(d, a, b)
                    || onSegment(a, c, d) || onSegment(b, c, d)
                {
                    return false
                }
            }
        }
        return abs(area) > 1e-6
    }

    static func contains(_ point: SIMD2<Float>, in polygon: [SIMD2<Float>]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        for i in polygon.indices {
            let a = polygon[i]
            let b = polygon[(i + 1) % polygon.count]
            if (a.y > point.y) != (b.y > point.y),
                point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
            {
                inside.toggle()
            }
        }
        return inside
    }
    var description: String {
        "BeautyDenseFaceSupport(pointCount: 478, protectionCount: \(protectionBounds.count))"
    }
    var customMirror: Mirror {
        Mirror(self, children: ["pointCount": 478, "protectionCount": protectionBounds.count])
    }
}
