# Beauty SDK Face Landmarks Coordinate System

## 1. 文档目标

本文档定义 BeautySDK 中人脸检测、关键点解析、坐标转换、方向处理、前置镜像、点位平滑、调试绘制的统一规范。

该文档解决的问题：

```text
Vision 坐标怎么转成图像坐标？
图像坐标怎么转成 Metal Texture 坐标？
前置摄像头镜像应该在哪里处理？
横竖屏方向怎么统一？
相册图片 EXIF Orientation 怎么处理？
大眼、瘦脸、瘦鼻拿到的点位应该是什么坐标？
Debug Overlay 怎么保证画点不偏？
```

核心原则：

```text
1. 坐标转换必须集中在 CoordinateMapper。
2. 算法模块不得直接处理 Vision 原始坐标。
3. 进入 FaceWarpPass 的关键点必须已经是 Texture Normalized 坐标。
4. Detection 层负责统一关键点坐标。
5. Render 层只消费统一后的坐标，不再关心 Vision / UIKit / EXIF。
6. Debug Overlay 使用单独的 Preview 坐标映射，不污染渲染坐标。
```

---

# 2. 坐标系统总览

美颜 SDK 中至少存在 5 套坐标系统：

```text
1. Vision Normalized 坐标
2. Image Pixel 坐标
3. Texture Normalized 坐标
4. Metal Pixel 坐标
5. Preview / SwiftUI 坐标
```

此外还涉及：

```text
EXIF Orientation
AVCaptureVideoOrientation / videoRotationAngle
前置摄像头镜像
视频帧方向
图片方向
预览层 aspectFill / aspectFit 裁切
```

如果不统一处理，会导致：

```text
关键点上下颠倒
左右眼反了
前置摄像头镜像错误
大眼作用到脸外
瘦脸拉错方向
鼻子嘴巴错位
Debug 点位看起来对，但实际渲染错
```

---

# 3. 各坐标系统定义

## 3.1 Vision Normalized 坐标

Vision 返回的人脸框和关键点通常是归一化坐标。

特点：

```text
x: 0 ... 1
y: 0 ... 1
原点通常在左下角
相对于图像区域归一化
```

注意：

```text
VNFaceObservation.boundingBox 是相对于整张图的 normalized rect。
VNFaceLandmarkRegion2D.normalizedPoints 是相对于 face boundingBox 的 normalized points。
```

也就是说，landmark 点不是直接相对于整张图，而是相对于人脸框。

转换时必须先：

```text
landmark point in face box
        ↓
image normalized point
        ↓
image pixel / texture point
```

---

## 3.2 Image Normalized 坐标

SDK 内部可使用一套图像归一化坐标：

```text
x: 0 ... 1
y: 0 ... 1
原点：左上角，建议
方向：与输入图像显示方向一致
```

为什么建议左上角：

```text
更接近 UIKit / CoreGraphics / 屏幕坐标习惯。
方便 Debug Overlay。
```

但进入 Metal shader 时，也可以统一成 Texture Normalized 坐标。

---

## 3.3 Image Pixel 坐标

图像像素坐标：

```text
x: 0 ... imageWidth
y: 0 ... imageHeight
原点：左上角，建议
单位：像素
```

用于：

```text
计算关键点间距离
计算影响半径
生成调试路径
计算人脸大小
根据图像尺寸确定参数强度
```

---

## 3.4 Texture Normalized 坐标

进入 `FaceWarpPass` 的点位推荐使用：

```text
x: 0 ... 1
y: 0 ... 1
原点：与 inputTexture 采样坐标一致
方向：与 inputTexture 内容方向一致
```

这是几何形变 Provider 和 Metal shader 的主坐标。

要求：

```text
EyeWarpProvider
NoseWarpProvider
MouthWarpProvider
FaceShapeWarpProvider
```

拿到的 `BeautyFaceLandmarks` 必须已经是 Texture Normalized 坐标。

它们不应该再知道 Vision 坐标，也不应该再处理镜像。

---

## 3.5 Metal Pixel 坐标

Metal compute shader 中线程 id 通常是像素坐标：

```metal
uint2 gid
```

对应：

```text
gid.x: 0 ... texture.width
gid.y: 0 ... texture.height
```

shader 中经常需要转成 normalized coordinate：

```metal
float2 uv = float2(gid) / float2(width, height);
```

然后根据 control points 做采样变换。

---

## 3.6 Preview / SwiftUI 坐标

Preview 坐标是屏幕显示坐标：

```text
x: 0 ... viewWidth
y: 0 ... viewHeight
原点：左上角
```

它会受以下因素影响：

```text
aspectFit
aspectFill
裁切区域
SafeArea
SwiftUI layout
前置摄像头是否预览镜像
```

注意：

```text
Preview 坐标只用于 Debug Overlay / UI 交互。
不要把 Preview 坐标传给算法或 Metal shader。
```

---

# 4. SDK 内部统一坐标选择

## 4.1 Detection 输出坐标

`BeautyDetection` 输出的 `BeautyFaceObservation` 应该包含统一后的点位。

建议：

```text
BeautyFaceObservation.boundingBox: Texture Normalized 坐标
BeautyFaceLandmarks: Texture Normalized 坐标
```

也可以额外保留：

```text
imagePixelBoundingBox
imagePixelLandmarks
```

但 MVP 第一版建议只对内部算法暴露 Texture Normalized 坐标。

---

## 4.2 统一后的数据结构

```swift
public struct BeautyFaceObservation: Sendable {
    public let id: UUID
    public let boundingBox: CGRect
    public let landmarks: BeautyFaceLandmarks
    public let roll: Float?
    public let yaw: Float?
    public let confidence: Float
}
```

约定：

```text
boundingBox 使用 Texture Normalized 坐标。
landmarks 里的所有点使用 Texture Normalized 坐标。
```

```swift
public struct BeautyFaceLandmarks: Sendable {
    public var faceContour: [SIMD2<Float>]
    public var leftEye: [SIMD2<Float>]
    public var rightEye: [SIMD2<Float>]
    public var leftEyebrow: [SIMD2<Float>]
    public var rightEyebrow: [SIMD2<Float>]
    public var nose: [SIMD2<Float>]
    public var noseCrest: [SIMD2<Float>]
    public var outerLips: [SIMD2<Float>]
    public var innerLips: [SIMD2<Float>]
    public var leftPupil: SIMD2<Float>?
    public var rightPupil: SIMD2<Float>?
}
```

---

# 5. Vision 关键点转换流程

## 5.1 原始输入

Vision 返回：

```text
VNFaceObservation.boundingBox
VNFaceLandmarks2D
VNFaceLandmarkRegion2D.normalizedPoints
```

其中：

```text
boundingBox：相对整张图的 normalized rect
landmark normalizedPoints：相对 face boundingBox 的 normalized points
```

---

## 5.2 landmark 转 image normalized

对于 landmark 点：

```text
p.x = landmarkPoint.x
p.y = landmarkPoint.y
```

face bounding box：

```text
box.origin.x
box.origin.y
box.width
box.height
```

转换为整图 normalized：

```text
imageX = box.origin.x + p.x * box.width
imageY = box.origin.y + p.y * box.height
```

此时还是 Vision normalized 坐标，通常原点在左下角。

---

## 5.3 Vision 左下角转左上角

如果 SDK 内部采用左上角坐标：

```text
normalizedX = imageX
normalizedY = 1.0 - imageY
```

如果后续直接转 Metal texture，需要确认 texture 内容方向。

统一建议：

```text
CoordinateMapper 统一输出 Texture Normalized 坐标。
```

---

## 5.4 转换伪代码

```swift
func convertVisionLandmarkPoint(
    _ point: CGPoint,
    faceBoundingBox: CGRect
) -> SIMD2<Float> {
    let imageX = faceBoundingBox.origin.x + point.x * faceBoundingBox.width
    let imageY = faceBoundingBox.origin.y + point.y * faceBoundingBox.height

    // Vision bottom-left -> top-left normalized
    let topLeftX = imageX
    let topLeftY = 1.0 - imageY

    return SIMD2(Float(topLeftX), Float(topLeftY))
}
```

注意：

```text
这只是基础转换。
实际还必须结合 orientation 和 mirror。
```

---

# 6. Orientation 方向处理

## 6.1 为什么方向复杂

输入来源不同，方向信息不同：

```text
相机实时帧：CVPixelBuffer 本身通常没有“已旋正”的概念。
相册图片：可能带 EXIF orientation。
视频文件：可能有 track transform。
前置摄像头：预览通常镜像，但采集数据不一定镜像。
Metal texture：只是像素内存，不知道用户想怎么看。
```

如果方向处理不统一，Vision 检测和 Metal 渲染会不一致。

---

## 6.2 SDK API 的 orientation

对外 API：

```swift
public func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CVPixelBuffer
```

这里的 `orientation` 表示：

```text
告诉 Vision / Detection 当前 pixelBuffer 应该如何解释为正向图像。
```

它不一定表示输出图像要旋转。

---

## 6.3 推荐策略

第一版推荐：

```text
1. App 侧传入正确 CGImagePropertyOrientation。
2. Vision 使用该 orientation 做检测。
3. CoordinateMapper 根据 orientation 把点位映射到 inputTexture 对应坐标。
4. RenderGraph 不负责旋转画面。
5. Preview 层决定怎么显示。
```

即：

```text
Detection 负责理解方向。
Render 负责按 texture 坐标处理。
Preview 负责视觉呈现。
```

---

## 6.4 常见相机方向参考

以下需要在 Demo 中实测，不能死记。

通常前置竖屏可能使用：

```swift
.rightMirrored
```

后置竖屏可能使用：

```swift
.right
```

但实际取决于：

```text
AVCaptureConnection.videoOrientation / videoRotationAngle
是否设置 isVideoMirrored
buffer 原始方向
预览层显示方式
```

因此必须通过 Debug Landmark Overlay 验证。

---

# 7. 前置摄像头镜像处理

## 7.1 镜像的三个层面

前置摄像头可能涉及三种镜像：

```text
1. 采集数据是否镜像
2. 预览画面是否镜像
3. 导出结果是否镜像
```

这三个不能混在一起。

---

## 7.2 推荐原则

```text
SDK 内部只处理输入纹理真实内容上的关键点。
Preview 是否镜像由 App 显示层决定。
Export 是否镜像由 App 导出策略决定。
```

也就是说：

```text
如果 inputTexture 是镜像的，landmarks 也必须对应镜像 texture。
如果 inputTexture 不是镜像的，landmarks 也必须对应非镜像 texture。
```

---

## 7.3 禁止重复镜像

禁止：

```text
Vision orientation 已经 mirrored
CoordinateMapper 又 mirror 一次
Preview overlay 又 mirror 一次
FaceWarpPass 再 mirror 一次
```

否则会出现：

```text
左眼右眼反
瘦脸方向错
点位看起来偏移
```

---

## 7.4 建议配置

方向和镜像是逐帧输入状态，不建议放进全局 `BeautyConfiguration`。

```swift
public struct BeautyFrameOrientation: Sendable {
    public let imageOrientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
    public let isPreviewMirrored: Bool
}
```

第一版如果暂时不公开 `BeautyFrameOrientation`，也必须由 App 明确传入正确 `CGImagePropertyOrientation`，并在内部保留镜像扩展点。

---

# 8. CoordinateMapper 设计

## 8.1 职责

`CoordinateMapper` 是唯一负责坐标转换的模块。

负责：

```text
Vision face box -> SDK boundingBox
Vision landmark -> Texture Normalized point
Texture point -> Preview point，Debug 用
Image point -> Texture point
处理 orientation
处理 mirror
处理 aspectFit / aspectFill
```

---

## 8.2 API 设计

```swift
public struct CoordinateMapper: Sendable {

    public let imageSize: CGSize
    public let textureSize: CGSize
    public let orientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool

    public init(
        imageSize: CGSize,
        textureSize: CGSize,
        orientation: CGImagePropertyOrientation,
        isInputMirrored: Bool
    )

    public func mapFaceBoundingBox(
        _ boundingBox: CGRect
    ) -> CGRect

    public func mapLandmarkPoint(
        _ point: CGPoint,
        in faceBoundingBox: CGRect
    ) -> SIMD2<Float>
}
```

---

## 8.3 Preview 映射 API

Debug Overlay 需要：

```swift
public struct PreviewCoordinateMapper: Sendable {

    public let textureSize: CGSize
    public let previewSize: CGSize
    public let contentMode: BeautyPreviewContentMode
    public let isPreviewMirrored: Bool

    public func mapTexturePointToPreview(
        _ point: SIMD2<Float>
    ) -> CGPoint
}

public enum BeautyPreviewContentMode: Sendable {
    case aspectFit
    case aspectFill
}
```

注意：

```text
PreviewCoordinateMapper 只用于 UI 和 Debug。
不要让算法依赖它。
```

---

# 9. AspectFit / AspectFill 预览映射

## 9.1 为什么需要

相机预览通常不是刚好等于图像比例。

例如：

```text
图像：1080 x 1920
View：393 x 852
```

如果使用 aspectFill，会有裁切。

Debug 点位绘制必须考虑裁切，否则看起来偏移。

---

## 9.2 AspectFit

计算缩放：

```text
scale = min(viewWidth / imageWidth, viewHeight / imageHeight)
scaledWidth = imageWidth * scale
scaledHeight = imageHeight * scale
offsetX = (viewWidth - scaledWidth) / 2
offsetY = (viewHeight - scaledHeight) / 2
```

映射：

```text
previewX = normalizedX * scaledWidth + offsetX
previewY = normalizedY * scaledHeight + offsetY
```

---

## 9.3 AspectFill

计算缩放：

```text
scale = max(viewWidth / imageWidth, viewHeight / imageHeight)
scaledWidth = imageWidth * scale
scaledHeight = imageHeight * scale
offsetX = (viewWidth - scaledWidth) / 2
offsetY = (viewHeight - scaledHeight) / 2
```

映射：

```text
previewX = normalizedX * scaledWidth + offsetX
previewY = normalizedY * scaledHeight + offsetY
```

注意：

```text
offset 可能是负数，表示内容被裁切。
```

---

## 9.4 镜像预览

如果预览镜像：

```text
previewX = viewWidth - previewX
```

注意：

```text
只在 PreviewCoordinateMapper 做。
不要影响 Texture Normalized 点位。
```

---

# 10. 人脸关键点模型

## 10.1 第一版关键点来源

第一版使用 Vision：

```text
VNDetectFaceLandmarksRequest
VNFaceObservation
VNFaceLandmarks2D
```

可获取区域：

```text
faceContour
leftEye
rightEye
leftEyebrow
rightEyebrow
nose
noseCrest
outerLips
innerLips
leftPupil，可用性视系统和输入而定
rightPupil，可用性视系统和输入而定
```

---

## 10.2 内部关键点结构

```swift
public struct BeautyFaceLandmarks: Sendable {
    public var faceContour: [SIMD2<Float>]
    public var leftEye: [SIMD2<Float>]
    public var rightEye: [SIMD2<Float>]
    public var leftEyebrow: [SIMD2<Float>]
    public var rightEyebrow: [SIMD2<Float>]
    public var nose: [SIMD2<Float>]
    public var noseCrest: [SIMD2<Float>]
    public var outerLips: [SIMD2<Float>]
    public var innerLips: [SIMD2<Float>]
    public var leftPupil: SIMD2<Float>?
    public var rightPupil: SIMD2<Float>?
}
```

---

## 10.3 关键点可用性规则

不是每一帧、每一张脸都能拿到所有点。

因此算法模块必须容错：

```text
没有眼睛点：跳过 eye 参数。
没有鼻子点：跳过 nose 参数。
没有嘴巴点：跳过 mouth 参数。
没有脸轮廓：跳过 face shape 参数。
confidence 太低：跳过强形变。
```

不要强行 unwrap。

---

# 11. 人脸选择策略

## 11.1 第一版主脸策略

第一版建议只处理主脸。

主脸选择优先级：

```text
1. 面积最大的人脸
2. 距离画面中心最近的人脸
3. 上一帧已跟踪的人脸
```

MVP 简化：

```text
选择面积最大的人脸。
```

---

## 11.2 多人脸策略

后续支持多人脸时：

```text
maximumFaceCount
```

限制最大处理数量。

多人脸排序：

```text
主脸优先
面积排序
中心距离排序
```

策略：

```text
performance：最多 1 张脸
balanced：最多 1~3 张脸
quality：最多 3~5 张脸
```

---

# 12. FaceTrackingState 设计

## 12.1 为什么需要跟踪

Vision 每帧返回的人脸没有稳定 ID。

如果直接使用，会导致：

```text
多人脸时身份跳变
点位平滑错配
美颜参数作用对象跳变
```

因此需要 `FaceTrackingState`。

---

## 12.2 第一版简化实现

第一版可以只处理主脸，无需复杂 ID。

状态：

```swift
public struct FaceTrackingState {
    public var lastFace: BeautyFaceObservation?
    public var missingFrameCount: Int
}
```

规则：

```text
检测到主脸：更新 lastFace。
连续 1~3 帧丢失：继续使用 lastFace，但降低 confidence。
超过阈值：清空 lastFace。
```

---

## 12.3 后续多人脸匹配

可以用：

```text
boundingBox IoU
中心点距离
人脸面积
landmark 距离
```

给每张脸分配临时 ID。

---

# 13. LandmarkSmoother 设计

## 13.1 目标

减少关键点抖动。

没有平滑时会出现：

```text
眼睛忽大忽小
瘦脸边缘抖动
鼻子变形漂移
口红漂移
嘴角微笑抖动
```

---

## 13.2 第一版算法：EMA

指数滑动平均：

```text
smoothed = previous * (1 - alpha) + current * alpha
```

建议：

```text
alpha = 0.35 ~ 0.6
```

alpha 越大：

```text
响应快，但抖动更明显
```

alpha 越小：

```text
更稳定，但延迟更明显
```

---

## 13.3 API 设计

```swift
public final class LandmarkSmoother {

    private var previousFace: BeautyFaceObservation?
    private let alpha: Float

    public init(alpha: Float = 0.45)

    public func smooth(
        _ faces: [BeautyFaceObservation]
    ) -> [BeautyFaceObservation]

    public func reset()
}
```

---

## 13.4 平滑规则

```text
同一类关键点数量一致：逐点平滑。
数量不一致：使用当前点，不做平滑。
缺失点：保留可用点。
confidence 低：降低 alpha 或跳过强形变。
人脸变化太大：重置平滑状态。
```

---

# 14. DetectionScheduler 设计

## 14.1 目标

检测不应该每帧强制运行。

推荐：

```text
渲染 30fps
检测 10~15fps
```

即：

```text
每 2~3 帧检测一次
中间帧复用平滑后的关键点
```

---

## 14.2 API 设计

```swift
public final class DetectionScheduler {

    private let detector: FaceDetecting
    private let smoother: LandmarkSmoother
    private let frameInterval: Int
    private var frameIndex: Int = 0
    private var lastFaces: [BeautyFaceObservation] = []

    public init(
        detector: FaceDetecting,
        smoother: LandmarkSmoother,
        frameInterval: Int
    )

    public func currentFaces(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]

    public func reset()
}
```

---

## 14.3 调度规则

```text
frameIndex % frameInterval == 0：运行检测。
否则：返回 lastFaces。
检测失败：短时间返回 lastFaces。
连续失败超过阈值：返回空数组。
```

---

# 15. FaceDetecting 协议

## 15.1 设计目标

检测实现必须可替换。

第一版：

```text
VisionFaceDetector
```

后续：

```text
CoreMLFaceDetector
DenseLandmarkDetector
FaceMeshDetector
```

---

## 15.2 API

```swift
public protocol FaceDetecting {
    func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]

    func reset()
}
```

---

# 16. VisionFaceDetector 设计

## 16.1 职责

```text
创建 VNDetectFaceLandmarksRequest
执行 VNImageRequestHandler
解析 VNFaceObservation
解析 landmarks
调用 CoordinateMapper
输出 BeautyFaceObservation
```

---

## 16.2 伪代码

```swift
public final class VisionFaceDetector: FaceDetecting {

    private let configuration: BeautyConfiguration

    public init(configuration: BeautyConfiguration) {
        self.configuration = configuration
    }

    public func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation] {
        let request = VNDetectFaceLandmarksRequest()

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: orientation,
            options: [:]
        )

        try handler.perform([request])

        guard let observations = request.results else {
            return []
        }

        let mapper = CoordinateMapper(
            imageSize: CGSize(
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer)
            ),
            textureSize: CGSize(
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer)
            ),
            orientation: orientation,
            isInputMirrored: false
        )

        return observations
            .sorted(by: { $0.boundingBox.width * $0.boundingBox.height > $1.boundingBox.width * $1.boundingBox.height })
            .prefix(configuration.maximumFaceCount)
            .compactMap { observation in
                mapObservation(observation, mapper: mapper)
            }
    }

    public func reset() {}
}
```

---

# 17. 关键点解析规范

## 17.1 安全解析

Vision 的 landmark region 可能为空。

必须安全处理：

```swift
let leftEye = landmarks.leftEye?.normalizedPoints ?? []
```

不要强制解包。

---

## 17.2 点位顺序

Vision 返回的点位顺序不一定满足某些算法需要。

如果算法依赖：

```text
左眼眼头
左眼眼尾
嘴角
下巴点
鼻翼点
```

需要建立独立的 landmark helper：

```swift
public struct LandmarkGeometryHelper {
    public static func center(of points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func leftMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func rightMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func topMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func bottomMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
}
```

不要在 Provider 里反复写散乱逻辑。

---

# 18. LandmarkGeometryHelper

## 18.1 常用几何计算

```swift
public enum LandmarkGeometryHelper {

    public static func center(
        of points: [SIMD2<Float>]
    ) -> SIMD2<Float>? {
        guard !points.isEmpty else { return nil }
        let sum = points.reduce(SIMD2<Float>(0, 0), +)
        return sum / Float(points.count)
    }

    public static func distance(
        _ a: SIMD2<Float>,
        _ b: SIMD2<Float>
    ) -> Float {
        simd_distance(a, b)
    }

    public static func boundingRect(
        of points: [SIMD2<Float>]
    ) -> CGRect? {
        guard let first = points.first else { return nil }
        var minX = first.x
        var maxX = first.x
        var minY = first.y
        var maxY = first.y

        for p in points.dropFirst() {
            minX = min(minX, p.x)
            maxX = max(maxX, p.x)
            minY = min(minY, p.y)
            maxY = max(maxY, p.y)
        }

        return CGRect(
            x: CGFloat(minX),
            y: CGFloat(minY),
            width: CGFloat(maxX - minX),
            height: CGFloat(maxY - minY)
        )
    }
}
```

---

# 19. 各算法依赖关键点

## 19.1 眼睛功能

### eyeSize

依赖：

```text
leftEye
rightEye
```

可选：

```text
leftPupil
rightPupil
```

需要计算：

```text
眼睛中心
眼睛宽度
眼睛高度
影响半径
```

---

### eyeDistance

依赖：

```text
leftEye center
rightEye center
face center
```

---

### eyeYPosition

依赖：

```text
leftEye
rightEye
face boundingBox
```

---

### eyeTailLift

依赖：

```text
leftEye outer corner
rightEye outer corner
```

Vision 点位不足时，可以用：

```text
leftEye 最左 / 最右点
rightEye 最左 / 最右点
```

结合左右脸方向判断眼头眼尾。

---

## 19.2 脸型功能

### faceSlim

依赖：

```text
faceContour
face center
```

需要估计：

```text
左脸颊点
右脸颊点
下颌点
```

---

### faceSmall

依赖：

```text
faceContour
boundingBox
face center
```

---

### faceVShape

依赖：

```text
faceContour
chin point
jaw contour
```

---

### chinLength

依赖：

```text
faceContour bottom point
outerLips
face center
```

---

## 19.3 鼻子功能

### noseSlim

依赖：

```text
nose
noseCrest
```

需要估计：

```text
鼻梁中心线
鼻翼左右边界
鼻头区域
```

---

### noseWingSlim

依赖：

```text
nose lower points
noseCrest
```

注意：

```text
Vision 鼻翼点不够密。
第一版只做基础效果。
```

---

### noseTipSize

依赖：

```text
nose bottom area
nose center
```

---

## 19.4 嘴巴功能

### mouthSize

依赖：

```text
outerLips
innerLips
```

---

### mouthWidth

依赖：

```text
outerLips left corner
outerLips right corner
mouth center
```

---

### smile

依赖：

```text
left mouth corner
right mouth corner
outerLips
```

---

### lipColor

依赖：

```text
outerLips
innerLips
```

后续需要：

```text
lip mask
```

---

# 20. Debug Overlay 规范

## 20.1 目的

Debug Overlay 用于验证：

```text
检测是否准确
坐标转换是否正确
前置镜像是否正确
横竖屏是否正确
Preview 裁切是否处理正确
```

---

## 20.2 绘制内容

建议绘制：

```text
face boundingBox
faceContour
leftEye
rightEye
nose
noseCrest
outerLips
innerLips
关键中心点
control points，可选
```

---

## 20.3 颜色建议

```text
faceContour：绿色
leftEye / rightEye：蓝色
nose：黄色
mouth：红色
control points source：白色
control points target：紫色
```

具体颜色由 Demo App 决定，不属于 SDK 核心。

---

## 20.4 Debug 坐标流程

```text
Texture Normalized Landmark
        ↓
PreviewCoordinateMapper
        ↓
SwiftUI / UIKit Overlay Point
        ↓
绘制
```

不要：

```text
Vision 原始点直接画到 SwiftUI
```

---

# 21. 坐标测试用例

必须建立测试图和测试场景。

## 21.1 相机方向测试

```text
前置竖屏
后置竖屏
前置横屏左
前置横屏右
后置横屏左
后置横屏右
```

验收：

```text
点位准确覆盖五官。
左右眼不反。
嘴巴鼻子不偏。
```

---

## 21.2 图片方向测试

测试 EXIF：

```text
up
down
left
right
upMirrored
downMirrored
leftMirrored
rightMirrored
```

验收：

```text
检测结果和图片视觉方向一致。
```

---

## 21.3 Preview ContentMode 测试

```text
aspectFit
aspectFill
不同 view 尺寸
不同图片比例
```

验收：

```text
Debug 点位与预览内容对齐。
```

---

## 21.4 算法坐标测试

```text
大眼作用于眼睛区域
瘦脸作用于脸颊区域
瘦鼻作用于鼻子区域
嘴角作用于嘴角区域
```

验收：

```text
形变没有明显错位。
```

---

# 22. 常见错误与排查

## 22.1 点位上下颠倒

可能原因：

```text
Vision bottom-left 没有转 top-left
orientation 传错
input texture 方向和 detection 方向不一致
```

排查：

```text
先画 face boundingBox
再画 eyes
确认 y 是否需要 1 - y
```

---

## 22.2 左右眼反了

可能原因：

```text
前置镜像处理重复
orientation 使用 mirrored，但又手动 mirror
Preview mirror 和 detection mirror 混淆
```

排查：

```text
用一张左右特征明显的人脸测试。
分别关闭 Preview mirror 和 Coordinate mirror。
```

---

## 22.3 Debug 点位对，但美颜错

可能原因：

```text
Debug 用 Preview 坐标，算法用 Texture 坐标，两者转换不同。
FaceWarpPass 内部又做了额外坐标变换。
inputTexture 实际方向与 landmarks 不一致。
```

排查：

```text
直接把 Texture Normalized 点绘制到一张中间纹理。
确认 Render 层看到的点和 Debug Overlay 一致。
```

---

## 22.4 竖屏对，横屏错

可能原因：

```text
orientation 没有随设备变化更新
texture width / height 使用错误
CoordinateMapper 没有处理旋转
Preview aspectFill 裁切没处理
```

---

## 22.5 前置预览对，导出错

可能原因：

```text
预览做了镜像，但导出没有
或导出也做了一次镜像
```

建议：

```text
明确 previewMirror 和 exportMirror 是两个策略。
```

---

# 23. 与 FaceWarpPass 的关系

`FaceWarpPass` 只接收统一后的 landmarks。

它假设：

```text
1. 所有点都是 Texture Normalized 坐标。
2. 点位方向和 inputTexture 一致。
3. x/y 范围在 0...1。
4. mirror 已处理。
5. orientation 已处理。
```

因此 `FaceWarpPass` 不应该出现：

```text
CGImagePropertyOrientation
Vision boundingBox
Preview size
SwiftUI view size
isVideoMirrored
```

如果 FaceWarpPass 需要这些，说明坐标系统边界错了。

---

# 24. 与 SwiftUI Demo 的关系

SwiftUI Demo 可以有：

```text
LandmarkDebugOverlay
ControlPointDebugOverlay
PerformanceOverlay
```

但这些属于 App 层。

Demo 获取 debug 数据的方式可以是：

```text
SDK debug result
内部 debug callback
或 Demo 内部直接使用 detection debug target
```

第一版建议：

```text
先在 Demo App 中通过 SDK Debug Mode 获取 BeautyFaceObservation。
再用 PreviewCoordinateMapper 绘制。
```

不要让 SwiftUI View 直接调用 Vision。

---

# 25. 第一版实现任务

## 25.1 必做文件

```text
FaceDetecting.swift
VisionFaceDetector.swift
BeautyFaceObservation.swift
BeautyFaceLandmarks.swift
CoordinateMapper.swift
PreviewCoordinateMapper.swift
LandmarkGeometryHelper.swift
LandmarkSmoother.swift
DetectionScheduler.swift
FaceTrackingState.swift
```

---

## 25.2 必做功能

```text
Vision 人脸检测
Vision landmarks 解析
Vision point -> Texture Normalized point
主脸选择
检测降频
点位平滑
Debug Overlay 坐标转换
前置 / 后置竖屏测试
相册图片方向测试
```

---

## 25.3 验收标准

```text
1. 正脸关键点准确覆盖五官。
2. 前置摄像头左右不反。
3. 后置摄像头方向正确。
4. 横竖屏至少有明确处理策略。
5. Debug Overlay 与预览对齐。
6. FaceWarpPass 使用点位后，大眼作用在眼睛区域。
7. 没有人脸时所有形变效果自动跳过。
8. 点位抖动在可接受范围内。
```

---

# 26. 后续升级方向

## 26.1 Core ML 高密度关键点

Vision 点位不够精细时，引入：

```text
DenseLandmarkDetector
FaceMeshDetector
```

通过同一个协议替换：

```swift
FaceDetecting
```

不影响上层 FaceWarpProvider。

---

## 26.2 Face Mesh

高级功能需要：

```text
更密集脸部轮廓
鼻翼 / 鼻孔点
唇线更密
眉毛区域
发际线
脸部 mesh triangulation
```

用于：

```text
高级瘦鼻
完整口红
眼影眼线
发际线
高级脸型
```

---

## 26.3 3D Pose

后续可以增强：

```text
yaw
pitch
roll
face angle
```

用于：

```text
侧脸降级
妆容透视校正
贴纸姿态
防止大角度人脸强形变
```

---

# 27. 一句话结论

人脸关键点系统最重要的不是“能不能检测到脸”，而是：

```text
所有算法看到的点，必须与当前 inputTexture 完全对齐。
```

因此第一版必须先做好：

```text
VisionFaceDetector
CoordinateMapper
LandmarkSmoother
PreviewCoordinateMapper
Debug Overlay
```

只要坐标系统稳定，大眼、瘦脸、瘦鼻、嘴角、妆容才能继续稳定扩展。
