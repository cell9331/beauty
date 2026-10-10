// Landmark478.swift
// MediaPipe Face Landmarker 478 点索引常量 + 人脸局部坐标系 + 状态量。
//
// 约定：
//  - "right/R" = 被摄者的右侧 = 未镜像图像的左侧；"left/L" 反之。
//  - 输入点必须是【像素坐标】(x*width, y*height)，不要在归一化坐标里算距离（宽高比会拉伸）。
//  - 标注 [官方] 的数组，来自 mediapipe 0.10.33 FaceLandmarksConnections 连接表（已提取校验）。
//  - 标注 [经验] 的数组，来自社区常用点位，未对规范几何模型做过校验，
//    必须用 tools/draw_indices.py 叠加到真实人脸上确认后再使用。
import simd

enum LM {

    // MARK: - 脸部轮廓 [官方]（36 点，闭合；10 在额头上缘中点，152 为下巴尖）
    static let faceOval: [Int] = [10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288,
                                  397, 365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136,
                                  172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109]
    /// 右侧(图像左)轮廓，从下巴到额头上缘 [官方]
    static let contourR: [Int] = [152, 148, 176, 149, 150, 136, 172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109, 10]
    /// 左侧(图像右)轮廓，与 contourR 逐项镜像对应 [官方]
    static let contourL: [Int] = [152, 377, 400, 378, 379, 365, 397, 288, 361, 323, 454, 356, 389, 251, 284, 332, 297, 338, 10]

    // MARK: - 眼睛 [官方]（均为 外眼角 → 内眼角）
    static let eyeUpperR: [Int] = [33, 246, 161, 160, 159, 158, 157, 173, 133]
    static let eyeLowerR: [Int] = [33, 7, 163, 144, 145, 153, 154, 155, 133]
    static let eyeUpperL: [Int] = [263, 466, 388, 387, 386, 385, 384, 398, 362]
    static let eyeLowerL: [Int] = [263, 249, 390, 373, 374, 380, 381, 382, 362]
    static let eyeOuterR = 33,  eyeInnerR = 133
    static let eyeOuterL = 263, eyeInnerL = 362
    /// 虹膜：中心 + 环（中心不在官方连接表内，468/473 为 478 点模型的虹膜中心）
    static let irisCenterR = 468, irisRingR: [Int] = [469, 470, 471, 472]
    static let irisCenterL = 473, irisRingL: [Int] = [474, 475, 476, 477]
    /// 上/下眼睑中点 [官方链中的中间点]
    static let lidMidUpperR = 159, lidMidLowerR = 145
    static let lidMidUpperL = 386, lidMidLowerL = 374
    /// EAR 六点：[p1 角, p2, p3, p4 角, p5, p6]
    static let earR: [Int] = [33, 160, 158, 133, 153, 144]
    static let earL: [Int] = [362, 385, 387, 263, 373, 380]

    // MARK: - 眉毛 [官方]（均为 外端 → 内端）
    static let browUpperR: [Int] = [70, 63, 105, 66, 107]
    static let browLowerR: [Int] = [46, 53, 52, 65, 55]
    static let browUpperL: [Int] = [300, 293, 334, 296, 336]
    static let browLowerL: [Int] = [276, 283, 282, 295, 285]
    /// 眉峰近似（上缘链中段）[经验]
    static let browPeakR = 105, browPeakL = 334

    // MARK: - 鼻子
    /// 中线：山根 → 鼻尖 → 鼻底 [官方]
    static let noseMidline: [Int] = [168, 6, 197, 195, 5, 4, 1, 19, 94, 2]
    static let noseTip = 1
    static let noseBase = 2          // 鼻小柱底(鼻下点)
    static let noseRoot = 168        // 山根（两眼之间）
    /// 鼻翼外轮廓，从鼻梁侧到鼻翼底 [官方]
    static let noseWingR: [Int] = [220, 115, 48, 64, 98]
    static let noseWingL: [Int] = [440, 344, 278, 294, 327]
    /// 鼻底（鼻孔下缘）[官方]
    static let noseBottomR: [Int] = [98, 97, 2]
    static let noseBottomL: [Int] = [327, 326, 2]

    // MARK: - 嘴唇 [官方]
    static let lipOuterUpper: [Int] = [61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291]
    static let lipOuterLower: [Int] = [61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291]
    static let lipInnerUpper: [Int] = [78, 191, 80, 81, 82, 13, 312, 311, 310, 415, 308]
    static let lipInnerLower: [Int] = [78, 95, 88, 178, 87, 14, 317, 402, 318, 324, 308]
    static let mouthCornerR = 61, mouthCornerL = 291
    static let mouthInnerCornerR = 78, mouthInnerCornerL = 308
    static let upperLipTop = 0, lowerLipBottom = 17
    static let innerUpperMid = 13, innerLowerMid = 14
    /// 唇珠/唇峰（M 唇用）[经验]
    static let cupidPeakR = 37, cupidPeakL = 267
    /// 内唇闭合多边形（牙齿 mask 的外边界）[官方链拼接]
    static let innerMouthPolygon: [Int] = [78, 191, 80, 81, 82, 13, 312, 311, 310, 415, 308,
                                           324, 318, 402, 317, 14, 87, 178, 88, 95]

    // MARK: - 面中线 / 三庭关键点
    /// 额头上缘 → 眉间 → 山根 → 鼻 → 唇 → 下巴 [经验，nose 部分官方]
    static let forehead = 10          // 额头上缘中点（不是真实发际线）
    static let forehead2 = 151        // [经验]
    static let glabella = 9           // 眉间 [经验]
    static let philtrumTop = 164      // 人中上端(鼻下) [经验]
    static let chinMid: [Int] = [17, 18, 200, 199, 175, 152]   // 下唇下缘 → 下巴尖 [经验]
    static let chin = 152

    // MARK: - 区域种子点（需叠加验证）[经验]
    static let cheekboneR: [Int] = [116, 117, 118, 123]
    static let cheekboneL: [Int] = [345, 346, 347, 352]
    static let templeR: [Int] = [21, 54, 71, 68, 139]
    static let templeL: [Int] = [251, 284, 301, 298, 368]
    static let jawAngleR: [Int] = [58, 172]
    static let jawAngleL: [Int] = [288, 397]
}

// MARK: - 人脸局部坐标系

struct FaceFrame478 {
    var origin: SIMD2<Float>
    var axisX: SIMD2<Float>      // 单位向量，右眼外角 → 左眼外角
    var axisY: SIMD2<Float>      // 单位向量，指向下巴（图像 y 向下时与 axisX 右手配套）
    var scale: Float             // 外眼角距离(像素)。不用瞳距：虹膜点随视线变化，会让尺度抖动

    /// points：478 个像素坐标点（左上原点、未镜像）
    init(points p: [SIMD2<Float>]) {
        origin = (p[LM.eyeOuterR] + p[LM.eyeOuterL] + p[LM.eyeInnerR] + p[LM.eyeInnerL]) / 4
        let d = p[LM.eyeOuterL] - p[LM.eyeOuterR]
        scale = max(simd_length(d), 1e-3)
        axisX = d / scale
        axisY = SIMD2<Float>(-axisX.y, axisX.x)
    }

    func toLocal(_ v: SIMD2<Float>) -> SIMD2<Float> {
        let d = v - origin
        return SIMD2<Float>(simd_dot(d, axisX), simd_dot(d, axisY)) / scale
    }
    func toImage(_ l: SIMD2<Float>) -> SIMD2<Float> {
        origin + (axisX * l.x + axisY * l.y) * scale
    }
    /// 局部向量(以 scale 为单位) → 像素向量（只旋转缩放，不平移）
    func vectorToImage(_ l: SIMD2<Float>) -> SIMD2<Float> {
        (axisX * l.x + axisY * l.y) * scale
    }
}

// MARK: - 状态量

enum FaceMetrics478 {
    /// 眼睛开合度 EAR：(|p2-p6| + |p3-p5|) / (2|p1-p4|)
    static func ear(_ p: [SIMD2<Float>], indices e: [Int]) -> Float {
        let v = simd_distance(p[e[1]], p[e[5]]) + simd_distance(p[e[2]], p[e[4]])
        let h = simd_distance(p[e[0]], p[e[3]])
        return v / max(2 * h, 1e-4)
    }
    /// 张嘴度：内唇上下距离 / 嘴宽
    static func mouthOpen(_ p: [SIMD2<Float>]) -> Float {
        simd_distance(p[LM.innerUpperMid], p[LM.innerLowerMid])
            / max(simd_distance(p[LM.mouthCornerR], p[LM.mouthCornerL]), 1e-4)
    }
    /// 虹膜半径(像素)：环上 4 点到中心的平均距离
    static func irisRadius(_ p: [SIMD2<Float>], center: Int, ring: [Int]) -> Float {
        ring.map { simd_distance(p[$0], p[center]) }.reduce(0, +) / Float(ring.count)
    }
    /// 由面部变换矩阵取朝向角（弧度）。矩阵列为旋转后的基向量，第 3 列为脸朝向。
    /// 注意：符号与轴约定因平台/镜像而异，必须用真人转头实测标定。
    static func yawPitch(from m: simd_float4x4) -> (yaw: Float, pitch: Float) {
        let f = m.columns.2
        let yaw = atan2(f.x, f.z)
        let pitch = asin(max(-1, min(1, -f.y)))
        return (yaw, pitch)
    }
}
