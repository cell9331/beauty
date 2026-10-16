// DisplacementSolver.swift
// 设计骨架：未在真机联调。展示"参数 → 目标点 → 联合限幅 → 翻转保护"的数据流。
import simd

/// 人脸局部坐标系：原点=两眼中点，x=两眼连线方向，y=垂直 x 指向下巴，scale=瞳距(像素)
struct FaceFrame {
    var origin: SIMD2<Float>
    var axisX: SIMD2<Float>      // 单位向量
    var axisY: SIMD2<Float>      // 单位向量
    var scale: Float             // 瞳距(像素)

    /// 局部向量(以 scale 为单位) -> 图像像素向量
    func toImage(_ v: SIMD2<Float>) -> SIMD2<Float> {
        (axisX * v.x + axisY * v.y) * scale
    }
}

struct BeautyParams {
    var thinFace: Float = 0        // 0...1
    var bigEye: Float = 0
    var thinNose: Float = 0
    // ... 其他参数
}

struct FaceState {
    var yaw: Float                 // 弧度
    var leftEAR: Float             // 眼睛开合度，闭眼≈0
    var rightEAR: Float
    var mouthOpen: Float
    var gate: Float                // 丢脸渐隐/渐入 0...1
}

/// 每个顶点在三角网格中的信息
struct MeshVertex {
    var source: SIMD2<Float>       // 源位置(像素)
    var fixed: Bool                // 外环/边界锚点：位移恒 0
}

final class DisplacementSolver {

    /// 联合限幅：单顶点总位移不超过 maxRatio * 脸宽
    static func clampDisplacement(_ d: SIMD2<Float>, maxLen: Float) -> SIMD2<Float> {
        let len = simd_length(d)
        return len > maxLen ? d * (maxLen / len) : d
    }

    @inline(__always)
    static func smoothstep(_ e0: Float, _ e1: Float, _ x: Float) -> Float {
        let t = min(max((x - e0) / (e1 - e0), 0), 1)
        return t * t * (3 - 2 * t)
    }

    /// 姿态权重：偏航角越大，远离镜头一侧强度越低。
    /// side：+1 表示脸右侧(图像右)，-1 表示左侧；yaw>0 视为头向图像右转(示意，需按实际符号校准)
    static func poseWeight(yaw: Float, side: Float) -> Float {
        let farSide = (yaw * side) < 0                // 是否为远离镜头一侧
        let a = abs(yaw)
        let w = max(cos(a), 0)
        // >60° 几何形变关闭；45°~60° 线性过渡
        let fade = 1 - smoothstep(Float.pi * 45 / 180, Float.pi * 60 / 180, a)
        return farSide ? w * fade : 1.0 * fade.squareRoot()
    }

    // MARK: - 示例：大眼（径向缩放，正向形式，作用于所有顶点）

    func applyBigEye(vertices: [MeshVertex],
                     eyeCenter: SIMD2<Float>,
                     eyeWidthPx: Float,
                     strength: Float,           // 0...1
                     ear: Float,
                     into displacements: inout [SIMD2<Float>]) {
        // 闭眼衰减：EAR 低于 0.12 时强度趋近 0，0.12~0.25 之间线性恢复(阈值需按模型标定)
        let earW = Self.smoothstep(0.12, 0.25, ear)
        let a = min(strength, 1) * 0.5 * earW      // 实用上限 a <= 0.5，理论单调上限 1.25
        guard a > 1e-4 else { return }
        let R = eyeWidthPx * 1.8
        for (i, v) in vertices.enumerated() where !v.fixed {
            let d = v.source - eyeCenter
            let r = simd_length(d)
            if r >= R { continue }
            let t = r / R
            let g = 1 + a * pow(1 - t * t, 2)
            displacements[i] += d * (g - 1)        // dst = C + d*g  →  位移 = d*(g-1)
        }
    }

    // MARK: - 示例：瘦脸（轮廓点沿指向脸中心方向内收，钟形权重）

    func applyThinFace(vertices: [MeshVertex],
                       contourIndices: [Int],      // 轮廓点在顶点数组中的下标，按 0...16 顺序
                       faceCenter: SIMD2<Float>,
                       faceWidthPx: Float,
                       strength: Float,
                       state: FaceState,
                       into displacements: inout [SIMD2<Float>]) {
        let n = contourIndices.count               // 17
        let maxShift = 0.07 * faceWidthPx          // 单点限幅：脸宽 7%（起始参考值）
        for (k, idx) in contourIndices.enumerated() {
            // 钟形权重：k 在 2...14 之间，颧骨下至下颌角最大，近耳/下巴尖衰减
            let u = Float(k) / Float(n - 1)        // 0...1
            let bell = pow(sin(u * .pi), 1.5)
            let chinFalloff = 1 - 0.6 * exp(-pow((u - 0.5) / 0.08, 2))   // 下巴尖附近衰减
            let side: Float = u < 0.5 ? -1 : 1
            let pose = Self.poseWeight(yaw: state.yaw, side: side)
            let dir = simd_normalize(faceCenter - vertices[idx].source)
            let mag = strength * bell * chinFalloff * pose * maxShift
            displacements[idx] += dir * mag
        }
        // 轮廓点之外的加密顶点：通过 TPS/RBF 插值得到（此处省略，见 docs/02 第 6 节）
    }

    // MARK: - 联合限幅 + 翻转保护

    func finalize(vertices: [MeshVertex],
                  displacements: [SIMD2<Float>],
                  triangles: [(Int, Int, Int)],
                  faceWidthPx: Float,
                  gate: Float) -> [SIMD2<Float>] {
        let maxLen = 0.08 * faceWidthPx

        func build(_ t: Float) -> [SIMD2<Float>] {
            vertices.enumerated().map { i, v in
                v.fixed ? v.source
                        : v.source + Self.clampDisplacement(displacements[i] * (t * gate), maxLen: maxLen)
            }
        }

        // 二分搜索最大无翻转强度 t ∈ [0,1]
        var best = build(1)
        if !hasFoldover(src: vertices.map { $0.source }, dst: best, triangles: triangles) { return best }
        var lo: Float = 0, hi: Float = 1
        best = vertices.map { $0.source }                    // t=0 一定安全
        for _ in 0..<8 {
            let mid = (lo + hi) / 2
            let cand = build(mid)
            if hasFoldover(src: vertices.map { $0.source }, dst: cand, triangles: triangles) {
                hi = mid
            } else {
                lo = mid; best = cand
            }
        }
        return best
    }

    private func signedArea(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ c: SIMD2<Float>) -> Float {
        0.5 * ((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y))
    }

    func hasFoldover(src: [SIMD2<Float>], dst: [SIMD2<Float>],
                     triangles: [(Int, Int, Int)], minRatio: Float = 0.1) -> Bool {
        for (i, j, k) in triangles {
            let a0 = signedArea(src[i], src[j], src[k])
            let a1 = signedArea(dst[i], dst[j], dst[k])
            if a0 == 0 { continue }
            if a1 / a0 < minRatio { return true }       // 符号翻转或被压到过小
        }
        return false
    }
}
