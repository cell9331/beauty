// OneEuroFilter.swift
// 设计骨架：未在真机联调。用于说明 One Euro + 人脸局部坐标系滤波的数据流。
import simd

/// 单通道 One Euro Filter（Casiez et al., 2012）
final class OneEuroFilter {
    var minCutoff: Float      // 静止时的截止频率(Hz)，越小越稳
    var beta: Float           // 速度系数，越大越"跟手"，拖影越小
    var dCutoff: Float        // 速度估计的截止频率(Hz)

    private var xPrev: Float?
    private var dxPrev: Float = 0

    init(minCutoff: Float = 1.0, beta: Float = 0.0, dCutoff: Float = 1.0) {
        self.minCutoff = minCutoff
        self.beta = beta
        self.dCutoff = dCutoff
    }

    func reset() { xPrev = nil; dxPrev = 0 }

    private func alpha(cutoff: Float, dt: Float) -> Float {
        let tau = 1.0 / (2.0 * Float.pi * cutoff)
        return 1.0 / (1.0 + tau / dt)
    }

    func filter(_ x: Float, dt: Float) -> Float {
        guard let xp = xPrev, dt > 1e-4 else { xPrev = x; return x }
        let dx = (x - xp) / dt
        let dxHat = dxPrev + alpha(cutoff: dCutoff, dt: dt) * (dx - dxPrev)
        let cutoff = minCutoff + beta * abs(dxHat)
        let xHat = xp + alpha(cutoff: cutoff, dt: dt) * (x - xp)
        xPrev = xHat
        dxPrev = dxHat
        return xHat
    }
}

/// 在"标准脸坐标系"里对每个关键点的 x/y 分别滤波。
/// 流程：当前点 → 相似变换对齐到标准脸 → One Euro → 逆变换回图像坐标。
final class FaceLandmarkSmoother {
    private var filtersX: [OneEuroFilter]
    private var filtersY: [OneEuroFilter]
    private let canonical: [SIMD2<Float>]   // 标准脸点位(瞳距归一化)
    private var lastTimestamp: Double?

    init(canonical: [SIMD2<Float>], minCutoff: Float, beta: Float) {
        self.canonical = canonical
        self.filtersX = canonical.map { _ in OneEuroFilter(minCutoff: minCutoff, beta: beta) }
        self.filtersY = canonical.map { _ in OneEuroFilter(minCutoff: minCutoff, beta: beta) }
    }

    func reset() {
        filtersX.forEach { $0.reset() }
        filtersY.forEach { $0.reset() }
        lastTimestamp = nil
    }

    /// points：图像像素坐标；返回滤波后的点（图像像素坐标）
    func smooth(points: [SIMD2<Float>], timestamp: Double) -> [SIMD2<Float>] {
        precondition(points.count == canonical.count)
        let dt = Float(lastTimestamp.map { timestamp - $0 } ?? (1.0 / 30.0))
        lastTimestamp = timestamp

        // 1. 估计相似变换：canonical -> image  (scale s, rotation R, translation t)
        let (s, rot, t) = Self.estimateSimilarity(from: canonical, to: points)

        // 2. 图像 -> 标准脸：p_c = R^T (p - t) / s
        var out = [SIMD2<Float>](repeating: .zero, count: points.count)
        for i in 0..<points.count {
            let local = rot.transpose * (points[i] - t) / s
            let fx = filtersX[i].filter(local.x, dt: dt)
            let fy = filtersY[i].filter(local.y, dt: dt)
            // 3. 标准脸 -> 图像
            out[i] = rot * SIMD2<Float>(fx, fy) * s + t
        }
        return out
    }

    /// 最小二乘相似变换（2D Procrustes/Umeyama，无反射）
    static func estimateSimilarity(from src: [SIMD2<Float>],
                                   to dst: [SIMD2<Float>]) -> (Float, float2x2, SIMD2<Float>) {
        let n = Float(src.count)
        let mS = src.reduce(.zero, +) / n
        let mD = dst.reduce(.zero, +) / n
        var a: Float = 0, b: Float = 0, varS: Float = 0
        for i in 0..<src.count {
            let p = src[i] - mS, q = dst[i] - mD
            a += p.x * q.x + p.y * q.y        // sum dot
            b += p.x * q.y - p.y * q.x        // sum cross
            varS += p.x * p.x + p.y * p.y
        }
        let norm = max((a * a + b * b).squareRoot(), 1e-6)
        let cosT = a / norm, sinT = b / norm
        let s = norm / max(varS, 1e-6)
        // 列主序：columns = (cos, sin), (-sin, cos)
        let R = float2x2(columns: (SIMD2<Float>(cosT, sinT), SIMD2<Float>(-sinT, cosT)))
        let t = mD - (R * mS) * s
        return (s, R, t)
    }
}

// 调参提示：
// 1) beta = 0，调 minCutoff 到静止不抖；
// 2) 再增大 beta，直到快速转头不拖影；
// 3) 坐标用瞳距归一化后调，换分辨率不必重调。
