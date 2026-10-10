# iOS Beauty SDK Development Stages Full Plan

## 1. 文档目标

本文档用于规划 iOS 美颜 SDK 从 0 到完整商业化版本的开发阶段。

目标不是一次性把所有功能堆出来，而是按技术依赖关系逐步推进：

```text
底层渲染链路
    ↓
基础图像处理
    ↓
人脸检测与关键点
    ↓
几何形变
    ↓
皮肤美颜
    ↓
五官精修
    ↓
妆容系统
    ↓
背景与人像分割
    ↓
身体美型
    ↓
视频导出与商业化 SDK
```

核心原则：

- SDK 只包含核心逻辑、算法、检测、渲染、资源加载。
- 不把 SwiftUI / UIKit UI 放进 SDK。
- App 侧负责页面、滑杆、分类面板、预设入口、相机页面。
- SDK 提供统一参数模型和图像处理能力。
- 第一版优先跑通闭环，后续再扩展完整功能。

---

# 2. 总体阶段划分

建议拆成 12 个阶段：

```text
阶段 0：技术预研与架构验证
阶段 1：SPM 工程骨架与空渲染链路
阶段 2：基础图像处理与 LUT 滤镜
阶段 3：人脸检测、关键点、坐标系统
阶段 4：统一几何形变系统
阶段 5：第一版核心美颜 MVP
阶段 6：完整五官精修
阶段 7：高级皮肤美颜与局部修复
阶段 8：妆容系统
阶段 9：背景、人像分割与氛围效果
阶段 10：身体美型
阶段 11：视频导出、性能优化与商业化 SDK 交付
```

其中：

- 阶段 0 ~ 5：完成可用的第一版美颜 SDK。
- 阶段 6 ~ 8：接近美图秀秀 / 醒图 / 轻颜相机的核心人像精修体验。
- 阶段 9 ~ 10：扩展背景、身体、风格化能力。
- 阶段 11：做成真正可交付、可集成、可维护的商业 SDK。

---

# 3. 阶段 0：技术预研与架构验证

## 3.1 阶段目标

验证 iOS 上实现美颜 SDK 的关键技术路线是否可行。

本阶段不追求完整架构，也不追求效果好看，只验证核心技术点：

```text
相机帧能否实时进入 Metal
Vision 人脸关键点是否可用
Metal 是否能做局部形变
Core Image / Metal 是否能做滤镜
实时帧率是否可接受
```

## 3.2 主要任务

### 任务 1：相机实时帧验证

- 使用 AVFoundation 获取相机帧。
- 通过 AVCaptureVideoDataOutput 拿到 CMSampleBuffer。
- 从 CMSampleBuffer 获取 CVPixelBuffer。
- 不经过 UIImage，直接进入渲染链路。

### 任务 2：Metal 显示验证

- 创建 MTLDevice。
- 创建 MTLCommandQueue。
- 创建 CVMetalTextureCache。
- 将 CVPixelBuffer 转成 MTLTexture。
- 用 MTKView 或 CAMetalLayer 显示。

### 任务 3：Vision 人脸关键点验证

- 使用 Vision 检测人脸。
- 获取眼睛、鼻子、嘴巴、脸轮廓等关键点。
- 在调试层绘制关键点。
- 验证前置摄像头、横竖屏、镜像方向是否正确。

### 任务 4：基础形变验证

- 用固定点实现一个简单大眼 Demo。
- 用脸颊关键点实现一个简单瘦脸 Demo。
- 验证 Metal shader 做局部形变的可行性。

### 任务 5：基础滤镜验证

- 实现亮度、对比度、饱和度调整。
- 实现 LUT 滤镜加载。
- 验证实时调节强度。

## 3.3 阶段产物

```text
CameraMetalDemo
VisionLandmarkDemo
FaceWarpDemo
LUTFilterDemo
技术验证记录文档
```

## 3.4 验收标准

- 相机实时画面可以通过 Metal 显示。
- 不使用 UIImage 作为实时链路中间格式。
- Vision 关键点能正确映射到画面坐标。
- 大眼 / 瘦脸 Demo 能看到基本效果。
- 基础滤镜可以实时调节。

---

# 4. 阶段 1：SPM 工程骨架与空渲染链路

## 4.1 阶段目标

创建正式 SDK 工程结构，跑通最小处理闭环。

第一阶段不是做美颜效果，而是让 SDK 能完成：

```text
输入 CVPixelBuffer
    ↓
BeautyEngine
    ↓
Metal RenderGraph
    ↓
输出 CVPixelBuffer
```

## 4.2 Package 结构

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautySDK/
│   ├── BeautyCore/
│   ├── BeautyDetection/
│   ├── BeautyRender/
│   ├── BeautyEffects/
│   └── BeautyResources/
└── Tests/
```

## 4.3 Target 职责

### BeautyCore

负责：

- `BeautyEngine`
- `BeautyParameters`
- `BeautyConfiguration`
- `BeautyPreset`
- `BeautyError`
- `BeautyResult`

### BeautyDetection

负责：

- 人脸检测接口
- Vision 检测实现
- 关键点模型
- 坐标转换
- 点位平滑

### BeautyRender

负责：

- MetalContext
- TextureCache
- RenderGraph
- RenderPass
- PixelBufferPool
- Shader 加载

### BeautyEffects

负责：

- 所有效果模块
- 几何形变
- 磨皮
- 美白
- 滤镜
- 妆容

### BeautyResources

负责：

- LUT 加载
- `.cube` 解析
- 预设 JSON
- 妆容资源
- Bundle 管理

### BeautySDK

负责：

- 对外聚合导出
- App 侧只需要 `import BeautySDK`

## 4.4 主要任务

### 任务 1：创建 SPM

- 创建 `Package.swift`。
- 创建多个 Target。
- 配置 iOS 最低系统版本。
- 配置 Metal shader 资源。

### 任务 2：实现 BeautyEngine 空流程

- 初始化配置。
- 接收 CVPixelBuffer。
- 调用 Renderer。
- 返回 CVPixelBuffer。

### 任务 3：实现 MetalContext

- 管理 MTLDevice。
- 管理 MTLCommandQueue。
- 管理 CIContext。
- 管理 CVMetalTextureCache。

### 任务 4：实现 TextureCache

- CVPixelBuffer 转 MTLTexture。
- 创建输出 CVPixelBuffer。
- 创建中间 MTLTexture。

### 任务 5：实现 CopyRenderPass

- 第一版只做原样拷贝。
- 验证 RenderGraph 可以正常调度。

## 4.5 阶段产物

```text
BeautySDK SPM 工程
BeautyEngine 初版
BeautyParameters 初版
MetalContext
TextureCache
RenderGraph
CopyRenderPass
Demo App 接入示例
```

## 4.6 验收标准

- App 可以通过 SPM 引入 `BeautySDK`。
- `BeautyEngine` 可以初始化。
- 输入 CVPixelBuffer 后能输出 CVPixelBuffer。
- 实时相机预览稳定。
- SDK 内不依赖 SwiftUI UI。
- SDK 内不依赖 UIKit 页面组件。

---

# 5. 阶段 2：基础图像处理与 LUT 滤镜

## 5.1 阶段目标

实现不依赖人脸关键点的基础图像处理能力。

这些功能是后续所有美颜效果的基础。

## 5.2 功能范围

### 基础颜色调整

- 亮度
- 对比度
- 饱和度
- 色温
- 色调
- 曝光
- 高光
- 阴影
- 锐化

### LUT 滤镜

- 内置 LUT 滤镜
- `.cube` 文件解析
- 滤镜强度调节
- 原图与滤镜图混合
- 多滤镜资源管理

### 基础美颜色彩

- 美白基础版
- 红润基础版
- 肤色冷暖调整
- 肤色均匀基础版

## 5.3 主要任务

### 任务 1：ColorAdjustmentEffect

实现：

```text
brightness
contrast
saturation
temperature
tint
exposure
highlight
shadow
sharpness
```

### 任务 2：LUTFilterEffect

实现：

```text
filterId
filterIntensity
LUT texture loading
original / filtered blend
```

### 任务 3：CubeLUTParser

实现 `.cube` 文件解析：

- 解析 LUT_3D_SIZE。
- 解析 RGB 数据。
- 生成 RGBA 数据。
- 上传为 3D LUT Texture 或 Core Image ColorCube 数据。

### 任务 4：基础肤色调整

实现：

- 美白。
- 红润。
- 肤色偏黄修正。
- 肤色偏暗修正。

第一版可以先全图处理，后续阶段再加入 skin mask。

## 5.4 阶段产物

```text
ColorAdjustmentEffect
LUTFilterEffect
CubeLUTParser
LUTLoader
BeautyParameters 色彩参数
基础滤镜资源包
```

## 5.5 验收标准

- 图片处理和相机实时处理都能使用滤镜。
- 滤镜强度可以实时调节。
- 基础颜色参数可以实时调节。
- 不出现明显卡顿。
- LUT 资源可以通过 Bundle 加载。

---

# 6. 阶段 3：人脸检测、关键点、坐标系统

## 6.1 阶段目标

建立人脸能力底座，为大眼、瘦脸、瘦鼻、妆容、皮肤 mask 做准备。

本阶段重点是：

```text
检测准确
坐标正确
方向正确
点位稳定
多人脸策略清晰
```

## 6.2 功能范围

- 人脸检测
- 人脸关键点
- 人脸框
- 眼睛关键点
- 鼻子关键点
- 嘴巴关键点
- 眉毛关键点
- 脸部轮廓点
- 点位平滑
- 检测降频
- 坐标系转换
- 前置摄像头镜像处理
- 多人脸基础支持

## 6.3 主要任务

### 任务 1：FaceDetecting 协议

定义检测接口：

```swift
public protocol FaceDetecting {
    func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]
}
```

### 任务 2：VisionFaceDetector

使用 Vision 实现第一版：

- VNDetectFaceLandmarksRequest
- 解析 VNFaceObservation
- 解析 VNFaceLandmarks2D
- 转成 SDK 内部模型

### 任务 3：BeautyFaceObservation

定义内部人脸结构：

```text
faceId
boundingBox
landmarks
roll
yaw
confidence
```

### 任务 4：BeautyFaceLandmarks

定义关键点结构：

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
leftPupil
rightPupil
```

### 任务 5：CoordinateMapper

统一坐标系统：

```text
Vision normalized coordinates
image coordinates
texture coordinates
preview coordinates
mirrored coordinates
```

### 任务 6：LandmarkSmoother

实现点位平滑：

- EMA 平滑。
- 低置信度过滤。
- 人脸 ID 匹配。
- 避免五官抖动。

### 任务 7：检测降频策略

实现：

- 每 N 帧检测一次。
- 中间帧复用上一次点位。
- 检测失败时短时间保留旧点位。
- 长时间失败后清空人脸状态。

## 6.4 阶段产物

```text
FaceDetecting
VisionFaceDetector
BeautyFaceObservation
BeautyFaceLandmarks
CoordinateMapper
LandmarkSmoother
FaceTrackingState
Debug landmark overlay 示例
```

## 6.5 验收标准

- 人脸关键点能准确画在脸上。
- 前置摄像头不反。
- 横屏竖屏方向正确。
- 点位抖动可接受。
- 检测降频后仍能保持实时稳定。
- 至少支持 1 张主脸。
- 可扩展到多人脸。

---

# 7. 阶段 4：统一几何形变系统

## 7.1 阶段目标

建立所有五官和脸型功能共用的几何形变底座。

这个阶段非常关键。

眼睛、鼻子、嘴巴、下巴、脸型不要各自写一套 shader，而应该统一成：

```text
各功能生成 WarpControlPoint
        ↓
合并所有 Control Points
        ↓
FaceWarpEffect 一次性执行
        ↓
Metal Warp Pass 输出
```

## 7.2 功能范围

- WarpControlPoint
- WarpControlPointProvider
- FaceWarpEffect
- EyeWarpProvider
- FaceShapeWarpProvider
- ChinWarpProvider
- NoseWarpProvider
- MouthWarpProvider
- Metal warp shader
- control points 上传到 GPU
- 多点影响半径和衰减

## 7.3 主要任务

### 任务 1：定义 WarpControlPoint

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
```

### 任务 2：定义 Provider 协议

```swift
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
```

### 任务 3：实现 FaceWarpEffect

职责：

- 收集所有 Provider 生成的点。
- 合并所有人脸点位。
- 上传到 MTLBuffer。
- 调用 Metal shader。
- 一次性完成所有几何形变。

### 任务 4：实现 Metal Warp Shader

功能：

- 根据控制点计算每个像素的采样偏移。
- 支持半径衰减。
- 支持多个控制点叠加。
- 避免边界采样越界。
- 保持形变平滑。

### 任务 5：实现最小功能验证

先只实现：

- 大眼
- 瘦脸

验证统一形变系统是否可用。

## 7.4 阶段产物

```text
WarpControlPoint
WarpControlPointProvider
FaceWarpEffect
EyeWarpProvider 基础版
FaceShapeWarpProvider 基础版
Warp.metal
```

## 7.5 验收标准

- 大眼和瘦脸共用同一个 Warp Pass。
- 调节强度时画面实时变化。
- 形变区域自然平滑。
- 背景拉伸不明显。
- 多个参数同时开启时不会严重冲突。

---

# 8. 阶段 5：第一版核心美颜 MVP

## 8.1 阶段目标

形成第一版可演示、可集成、可体验的美颜 SDK。

这个阶段完成后，SDK 应该已经具备商业 Demo 的雏形。

## 8.2 功能范围

### 基础美颜

- 磨皮基础版
- 美白
- 红润
- 清晰度 / 锐化

### 脸型

- 瘦脸
- 小脸
- V 脸基础版
- 下巴基础版

### 眼睛

- 大眼
- 眼距
- 眼睛上下位置
- 眼尾上扬基础版

### 鼻子

- 瘦鼻基础版
- 鼻翼收窄基础版
- 鼻头缩小基础版

### 嘴巴

- 嘴巴大小
- 嘴巴宽度
- 嘴角微笑基础版
- 唇色增强基础版

### 滤镜

- LUT 滤镜
- 滤镜强度
- 基础色彩调整

### 参数系统

- BeautyParameters
- BeautyPreset
- JSON 预设
- 参数归一化

## 8.3 主要任务

### 任务 1：完善 BeautyParameters

定义第一版所有可调参数：

```text
skinSmoothing
skinWhitening
skinRosy
skinSharpen
brightness
contrast
saturation
temperature
tint
exposure
highlight
shadow
faceSlim
faceSmall
faceVShape
jawSlim
chinLength
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
noseSlim
noseWingSlim
noseTipSize
noseBridge
mouthSize
mouthWidth
smile
lipColor
filterId
filterIntensity
```

### 任务 2：实现 MVP 几何功能

Provider：

```text
EyeWarpProvider
FaceShapeWarpProvider
ChinWarpProvider
NoseWarpProvider
MouthWarpProvider
```

功能：

```text
大眼
眼距
眼睛上下
眼尾上扬
瘦脸
小脸
V 脸
下巴
瘦鼻
鼻翼
鼻头
嘴巴大小
嘴角微笑
```

### 任务 3：实现基础磨皮

第一版磨皮不追求高级皮肤分割，先做：

```text
边缘保护模糊
低频平滑
高频细节回加
强度控制
```

### 任务 4：实现预设系统

预设：

```text
自然
清透
精致
男生自然
证件照自然
```

### 任务 5：实现 Demo App 接入

App 侧用 SwiftUI 实现：

- 相机预览。
- 图片选择。
- 参数滑杆。
- 功能分类。
- 前后对比。
- 预设选择。

注意：这些 UI 不属于 SDK，只是 Demo App。

## 8.4 阶段产物

```text
Beauty SDK MVP
BeautyParameters 完整 MVP 版
基础预设 JSON
基础 LUT 资源包
Demo App
基础接入文档
```

## 8.5 验收标准

- App 侧可以 import BeautySDK。
- 相机实时预览可用。
- 图片处理可用。
- 大眼、瘦脸、美白、磨皮、滤镜效果可见。
- 第一版核心五官参数可调。
- 预设可以一键应用。
- 实时处理不卡顿。
- SDK 内没有 UI 代码。

---

# 9. 阶段 6：完整五官精修

## 9.1 阶段目标

补齐眼睛、鼻子、嘴巴、眉毛、额头、下巴、脸型等完整五官精修能力。

这一阶段的目标是从“基础美颜”升级到“精修人像”。

## 9.2 眼睛功能

### 基础调整

- 大眼 / 小眼
- 眼宽
- 眼高
- 眼距
- 左眼单独调整
- 右眼单独调整
- 双眼同步开关

### 位置调整

- 双眼上移 / 下移
- 左眼上移 / 下移
- 右眼上移 / 下移
- 眼睛整体旋转

### 眼型调整

- 眼尾上扬
- 眼尾下压
- 眼头调整
- 眼尾调整
- 开内眼角
- 开外眼角
- 圆眼
- 杏眼
- 猫眼基础版
- 下垂眼基础版

### 眼部增强

- 眼神光
- 眼白提亮
- 眼白去黄
- 瞳孔轻微放大
- 卧蚕基础版
- 黑眼圈淡化基础版

## 9.3 鼻子功能

### 几何调整

- 瘦鼻
- 鼻梁变窄
- 鼻翼收窄
- 鼻头缩小
- 鼻头上翘
- 鼻头下压
- 鼻子整体上移 / 下移
- 鼻子整体缩放
- 鼻孔收窄基础版

### 光影增强

- 鼻梁高光
- 鼻侧阴影
- 鼻头高光
- 鼻翼阴影
- 鼻子立体感

## 9.4 嘴巴功能

### 几何调整

- 嘴巴大小
- 嘴巴宽度
- 嘴巴高度
- 嘴巴上移 / 下移
- 嘴巴旋转修正
- 上唇厚度
- 下唇厚度
- 唇峰增强
- 唇珠增强
- M 唇基础版
- 嘴角上扬
- 左嘴角单独调整
- 右嘴角单独调整

### 颜色增强

- 唇色增强
- 唇部饱和度
- 唇部光泽
- 唇纹淡化基础版

### 牙齿

- 牙齿美白基础版
- 牙齿去黄基础版
- 牙齿亮度

## 9.5 眉毛功能

- 眉毛上移 / 下移
- 左眉单独调整
- 右眉单独调整
- 眉间距
- 眉毛加粗
- 眉毛变细
- 眉尾拉长
- 眉色调整
- 平眉基础版
- 弯眉基础版
- 野生眉基础版

## 9.6 脸型功能

- 整体瘦脸
- 左脸瘦脸
- 右脸瘦脸
- 小脸
- 窄脸
- V 脸
- 下颌线收紧
- 腮帮缩小
- 颧骨内收
- 下巴变尖
- 下巴变短
- 下巴变长
- 额头变高 / 变低
- 太阳穴饱满基础版
- 中庭缩短 / 拉长基础版
- 下庭缩短 / 拉长基础版
- 左右脸对称基础版

## 9.7 主要任务

### 任务 1：扩展 BeautyParameters

增加完整五官参数。

### 任务 2：扩展 Warp Providers

新增或增强：

```text
EyeAdvancedWarpProvider
NoseAdvancedWarpProvider
MouthAdvancedWarpProvider
EyebrowWarpProvider
FaceContourWarpProvider
ForeheadWarpProvider
SymmetryWarpProvider
```

### 任务 3：局部独立调节

支持：

- 左眼 / 右眼独立。
- 左脸 / 右脸独立。
- 左嘴角 / 右嘴角独立。
- 左眉 / 右眉独立。

### 任务 4：参数组合保护

处理多个参数同时生效时的冲突：

- 大眼 + 眼距。
- 瘦脸 + V 脸 + 下巴。
- 嘴角 + 嘴巴大小。
- 鼻翼 + 鼻头 + 鼻梁。

### 任务 5：多人脸基础增强

支持：

- 所有人统一美颜。
- 主脸优先。
- 最多 3 张脸。
- 多人脸性能降级策略。

## 9.8 阶段产物

```text
完整五官参数模型
完整几何形变 Provider
五官精修效果集
多人脸基础支持
五官参数冲突处理策略
```

## 9.9 验收标准

- 眼睛、鼻子、嘴巴、脸型主要参数都可用。
- 多个五官参数组合时效果自然。
- 没有明显局部撕裂。
- 人脸轻微转动时点位稳定。
- 多人脸场景不会严重掉帧。

---

# 10. 阶段 7：高级皮肤美颜与局部修复

## 10.1 阶段目标

把基础磨皮、美白升级成更自然的人像皮肤精修能力。

重点是避免塑料脸，保留皮肤质感。

## 10.2 功能范围

### 皮肤美颜

- 高级磨皮
- 保留皮肤纹理
- 肤色均匀
- 美白增强
- 红润增强
- 五官边缘保护
- 头发边缘保护
- 高光保护
- 阴影保护

### 局部修复

- 祛痘基础版
- 祛斑基础版
- 黑眼圈淡化
- 泪沟淡化
- 法令纹淡化
- 额头纹淡化
- 眼周细纹淡化

### 皮肤区域识别

- Skin Mask 基础版
- 皮肤色彩范围识别
- Core ML 皮肤分割预留
- 皮肤 / 五官 / 头发保护区域

## 10.3 主要任务

### 任务 1：高级磨皮算法

实现或优化：

```text
Bilateral Filter
Guided Filter
Surface Blur
Frequency Separation
```

根据性能选择合适方案。

### 任务 2：SkinMaskEffect

实现皮肤区域 mask：

第一版：

```text
基于 YCrCb / HSV 肤色范围估计
```

高级版：

```text
Core ML 皮肤分割模型
```

### 任务 3：五官保护

根据 landmarks 生成保护区域：

```text
眼睛
眉毛
嘴唇
牙齿
鼻孔
头发边缘
```

### 任务 4：局部纹理修复

基础方案：

- 局部模糊 + 纹理回加。
- 小瑕疵区域检测。
- 与周围皮肤颜色融合。

高级方案预留：

- inpainting。
- Core ML 瑕疵修复。

### 任务 5：黑眼圈 / 法令纹

通过区域 mask + 明暗调整：

- 眼下区域提亮。
- 法令纹区域亮度平衡。
- 保留自然阴影。

## 10.4 阶段产物

```text
AdvancedSkinSmoothEffect
SkinMaskEffect
BlemishRemovalEffect
DarkCircleRemovalEffect
WrinkleReductionEffect
FeatureProtectionMask
```

## 10.5 验收标准

- 皮肤变干净但不塑料。
- 眼睛、眉毛、嘴巴不被磨糊。
- 黑眼圈淡化自然。
- 法令纹不会完全消失成假脸。
- 高强度参数下仍然可控。

---

# 11. 阶段 8：妆容系统

## 11.1 阶段目标

实现完整妆容系统，包括整体妆容模板和局部妆容组件。

这一阶段依赖：

- 稳定关键点。
- 稳定 mask。
- 良好的 blend mode。
- 妆容资源规范。

## 11.2 功能范围

### 整体妆容模板

- 日常妆
- 通勤妆
- 清透妆
- 甜妹妆
- 纯欲妆
- 韩系妆
- 港风妆
- 复古妆
- 证件照妆
- 男生自然妆

### 底妆

- 粉底
- 遮瑕
- 提亮
- 修容
- 高光

### 眼妆

- 眼影
- 眼线
- 睫毛
- 卧蚕
- 美瞳
- 眼神光

### 眉妆

- 眉形
- 眉色
- 眉毛浓度

### 唇妆

- 口红
- 唇釉
- 哑光唇
- 水光唇
- 渐变唇
- 唇部高光

### 腮红

- 苹果肌腮红
- 眼下腮红
- 鼻尖腮红
- 修容腮红

### 修容 / 高光

- 鼻影
- 鼻梁高光
- 颧骨阴影
- 下颌阴影
- 额头高光

## 11.3 主要任务

### 任务 1：妆容资源规范

定义妆容包结构：

```text
MakeupPackage/
├── config.json
├── preview.png
├── lipstick.png
├── blush.png
├── eyeshadow.png
├── eyeliner.png
├── eyebrow.png
└── highlight.png
```

### 任务 2：MakeupPackage 配置

配置内容：

```text
妆容 ID
妆容名称
资源文件
适用区域
颜色
透明度
blend mode
关键点绑定方式
强度默认值
```

### 任务 3：局部 mask 生成

根据 landmarks 生成：

```text
lipMask
eyeShadowMask
eyelinerPath
blushMask
eyebrowMask
noseHighlightMask
contourMask
```

### 任务 4：妆容贴图变形

实现：

- 贴图按关键点变形。
- 跟随人脸旋转。
- 跟随人脸缩放。
- 支持左右脸。
- 支持透明度调节。

### 任务 5：Blend Mode

支持：

```text
normal
multiply
screen
overlay
softLight
color
linearBurn
```

### 任务 6：单项妆容效果

实现：

```text
LipstickEffect
BlushEffect
EyeshadowEffect
EyelinerEffect
EyelashEffect
EyebrowMakeupEffect
EyeLightEffect
HighlightContourEffect
```

## 11.4 阶段产物

```text
MakeupResourceLoader
MakeupPackage
MakeupEffect
LipstickEffect
BlushEffect
EyeshadowEffect
EyelineEffect
EyebrowMakeupEffect
HighlightContourEffect
完整妆容资源规范文档
```

## 11.5 验收标准

- 口红贴合嘴唇自然。
- 腮红位置稳定。
- 眼影不会明显漂移。
- 妆容可以整体调节强度。
- 单项妆容可以独立开关。
- 人脸轻微转动时妆容跟随稳定。

---

# 12. 阶段 9：背景、人像分割与氛围效果

## 12.1 阶段目标

扩展人像与背景相关能力，支持背景虚化、背景替换、人物描边、氛围光效等功能。

## 12.2 功能范围

### 人像分割

- 人物 mask
- 背景 mask
- 边缘羽化
- mask 平滑
- mask 上采样

### 背景效果

- 背景虚化
- 背景替换
- 背景变暗
- 背景调色
- 背景透明化
- 景深效果
- 光斑虚化

### 人像效果

- 人像描边
- 人物边缘光
- 人像柔光
- 人像阴影

### 氛围效果

- 柔光
- 逆光
- 星光
- 光斑
- 边缘光
- 暗角
- 胶片颗粒

## 12.3 主要任务

### 任务 1：PersonSegmentationProvider

第一版可以使用系统人像分割能力。

后续可以替换为 Core ML 分割模型。

### 任务 2：Mask 后处理

实现：

- mask blur。
- mask feather。
- mask edge refine。
- temporal smoothing。
- 低分辨率 mask 上采样。

### 任务 3：背景虚化

实现：

- 高斯虚化。
- 景深范围。
- 光斑虚化基础版。
- 人物边缘保护。

### 任务 4：背景替换

实现：

- 图片背景。
- 纯色背景。
- 渐变背景。
- 视频背景预留。

### 任务 5：人像描边和边缘光

实现：

- mask edge detect。
- outline color。
- outline width。
- edge glow。

## 12.4 阶段产物

```text
PersonSegmentationProvider
PortraitMaskEffect
BackgroundBlurEffect
BackgroundReplaceEffect
PortraitOutlineEffect
AtmosphereLightEffect
MaskPostProcessor
```

## 12.5 验收标准

- 背景虚化边缘自然。
- 头发边缘不出现明显硬边。
- 背景替换稳定。
- 人像描边与人物边缘贴合。
- 实时场景下可根据设备降级。

---

# 13. 阶段 10：身体美型

## 13.1 阶段目标

支持半身、全身场景下的身体比例调整。

身体美型不建议早期做，因为它依赖人体关键点、人体分割、全局形变控制。

## 13.2 功能范围

### 长腿

- 腿部拉长
- 小腿拉长
- 大腿拉长
- 身高比例调整

### 瘦身

- 腰部收窄
- 肩宽调整
- 手臂变细
- 大腿变细
- 小腿变细
- 胯部调整

### 头身比

- 头部缩小
- 肩颈比例优化
- 上半身比例调整

### 姿态基础修正

- 轻微体态拉直
- 肩膀水平修正
- 站姿比例优化

## 13.3 主要任务

### 任务 1：人体关键点检测

需要引入：

- Vision body pose。
- 或 Core ML 人体关键点模型。

### 任务 2：人体分割

需要得到：

```text
头部
上半身
手臂
腰部
腿部
背景
```

### 任务 3：身体形变系统

身体形变不能直接复用脸部形变，需要单独设计：

```text
BodyWarpControlPoint
BodyWarpProvider
BodyWarpEffect
```

### 任务 4：长腿算法

实现：

- 腿部区域纵向拉伸。
- 上半身区域保护。
- 背景过渡修复。

### 任务 5：瘦身算法

实现：

- 腰部两侧向内形变。
- 手臂局部收缩。
- 腿部局部收缩。
- 影响范围衰减。

## 13.4 阶段产物

```text
BodyPoseDetector
BodySegmentationProvider
BodyWarpEffect
LegLengthEffect
BodySlimEffect
ShoulderAdjustEffect
HeadBodyRatioEffect
```

## 13.5 验收标准

- 长腿效果自然。
- 背景拉伸不明显。
- 瘦身不会导致身体比例畸形。
- 半身 / 全身场景都有合理降级。
- 不影响脸部美颜管线。

---

# 14. 阶段 11：视频导出、性能优化与商业化 SDK 交付

## 14.1 阶段目标

将 SDK 从 Demo 级别升级到可商业交付级别。

重点：

```text
视频处理
性能稳定
内存稳定
接口稳定
文档完整
测试完整
可分发
可授权
可诊断
```

## 14.2 视频能力

### 视频文件处理

- AVAssetReader 读取视频帧。
- BeautyEngine 逐帧处理。
- AVAssetWriter 写出视频。
- 音频轨保留。
- 视频方向保留。
- 时间戳同步。
- 进度回调。
- 取消处理。

### 实时录制

- 相机实时美颜。
- 美颜后视频录制。
- 录制帧和预览帧一致。
- 音视频同步。

### 图片处理

- UIImage / CGImage / CIImage 输入。
- CVPixelBuffer 输入。
- 原图分辨率导出。
- 批量图片处理。

## 14.3 性能优化

### 渲染优化

- 减少 Render Pass 数量。
- 合并 Color Pass。
- 合并 Geometry Warp Pass。
- 中间纹理复用。
- 避免频繁创建 MTLBuffer。
- 避免每帧创建 CIContext。
- 避免 UIImage 中转。

### 检测优化

- 人脸检测降频。
- 点位缓存。
- 点位平滑。
- 主脸优先。
- 多人脸数量限制。
- 检测分辨率降采样。

### 设备分级

定义质量等级：

```text
performance
balanced
quality
```

根据设备性能决定：

- 处理分辨率。
- 检测频率。
- 磨皮算法等级。
- 是否启用妆容。
- 是否启用背景分割。
- 最大人脸数量。

### 内存优化

- CVPixelBufferPool。
- Texture pool。
- MTLBuffer 复用。
- 资源按需加载。
- 妆容资源缓存淘汰。
- LUT 资源缓存。

## 14.4 商业化 SDK 能力

### 分发方式

- Swift Package 源码版。
- XCFramework 二进制版。
- Demo App。
- 示例工程。

### 接口文档

- 快速接入文档。
- 参数说明文档。
- 相机实时接入文档。
- 图片处理文档。
- 视频导出文档。
- 资源包文档。
- 常见问题文档。

### 稳定性

- 错误码。
- 日志系统。
- 性能监控。
- 内存监控。
- 崩溃定位信息。
- Debug overlay。

### 授权预留

如果未来商业化，可以预留：

- license 校验。
- 功能模块开关。
- 资源包权限。
- 试用期配置。
- 水印策略。

## 14.5 测试体系

### 单元测试

- 参数归一化。
- LUT 解析。
- 坐标转换。
- 预设加载。
- 资源加载。

### 效果测试

- 不同脸型。
- 不同性别。
- 不同肤色。
- 不同光照。
- 戴眼镜。
- 侧脸。
- 多人脸。
- 遮挡。

### 性能测试

- 低端设备。
- 中端设备。
- 高端设备。
- 720p。
- 1080p。
- 4K 图片。
- 长时间运行。
- 视频导出。

### 回归测试

- 固定测试图集。
- 固定参数组。
- 输出图 hash / 差异对比。
- 帧率统计。
- 内存峰值统计。

## 14.6 阶段产物

```text
VideoBeautyProcessor
ImageBeautyProcessor
CameraRealtimeProcessor
PerformanceProfiler
DeviceCapabilityManager
BeautyCore/Diagnostics
BeautyLogger
BeautyErrorCode / BeautyErrorContext 文档
接入文档
Demo App
XCFramework
SPM Release
测试报告
```

## 14.7 验收标准

- SDK 可以稳定接入真实 App。
- 相机实时处理稳定。
- 图片导出稳定。
- 视频导出可用。
- 文档完整。
- 示例工程可运行。
- 不同设备有合理降级。
- 长时间运行无明显内存泄漏。

---

# 15. 完整功能覆盖关系

## 15.1 第一版 MVP 覆盖

```text
基础链路
基础滤镜
基础美白
基础红润
基础磨皮
大眼
眼距
眼睛上下
眼尾上扬
瘦脸
小脸
V 脸
下巴
瘦鼻
鼻翼
鼻头
嘴巴大小
嘴角微笑
唇色增强
预设系统
```

## 15.2 第二阶段精修覆盖

```text
左右眼独立调整
复杂眼型
开眼角
卧蚕
眼神光
黑眼圈
完整鼻子调整
嘴唇厚度
M 唇
牙齿美白
眉毛调整
完整脸型
左右脸对称
颧骨
额头
太阳穴
```

## 15.3 第三阶段高级人像覆盖

```text
高级磨皮
肤色均匀
皮肤纹理保留
祛痘
祛斑
法令纹
泪沟
额头纹
完整妆容
口红
腮红
眼影
眼线
睫毛
美瞳
修容
高光
```

## 15.4 第四阶段扩展能力覆盖

```text
背景虚化
背景替换
人像描边
氛围光
风格化滤镜
身体美型
长腿
瘦身
头身比
视频导出
商业 SDK 分发
```

---

# 16. 推荐里程碑版本

## Version 0.1：技术 Demo

包含：

```text
相机帧输入
Metal 显示
Vision 关键点
简单滤镜
简单大眼 / 瘦脸 Demo
```

## Version 0.2：SDK 骨架

包含：

```text
SPM
BeautyEngine
BeautyParameters
RenderGraph
TextureCache
CopyRenderPass
Demo App 接入
```

## Version 0.3：基础滤镜版

包含：

```text
亮度
对比度
饱和度
色温
LUT
美白
红润
锐化
```

## Version 0.4：人脸检测版

包含：

```text
VisionFaceDetector
FaceLandmarks
CoordinateMapper
LandmarkSmoother
Debug points
```

## Version 0.5：基础形变版

包含：

```text
FaceWarpEffect
大眼
瘦脸
小脸
下巴
```

## Version 1.0：第一版美颜 SDK

包含：

```text
基础美颜
LUT 滤镜
大眼
眼距
瘦脸
小脸
V 脸
下巴
瘦鼻
鼻翼
嘴巴大小
嘴角微笑
预设系统
相机实时处理
图片处理
Demo App
接入文档
```

## Version 1.5：完整五官精修

包含：

```text
完整眼睛调整
完整鼻子调整
完整嘴巴调整
完整眉毛调整
完整脸型调整
多人脸基础支持
```

## Version 2.0：高级皮肤与妆容

包含：

```text
高级磨皮
皮肤 mask
祛痘
黑眼圈
法令纹
完整妆容系统
口红
腮红
眼妆
眉妆
修容高光
```

## Version 2.5：背景与氛围

包含：

```text
人像分割
背景虚化
背景替换
人像描边
边缘光
氛围光效
```

## Version 3.0：完整商业 SDK

包含：

```text
身体美型
视频文件处理
实时录制处理
性能分级
设备降级
XCFramework
完整文档
完整测试报告
商业授权预留
```

---

# 17. 人员分工建议

如果是多人开发，建议这样分工：

## iOS SDK 架构工程师

负责：

- SPM 架构。
- BeautyEngine。
- API 设计。
- 模块边界。
- SDK 分发。

## Metal 渲染工程师

负责：

- MetalContext。
- RenderGraph。
- TextureCache。
- Shader。
- 几何形变。
- 性能优化。

## 算法 / 图像处理工程师

负责：

- 磨皮。
- 美白。
- 皮肤 mask。
- 局部修复。
- 妆容 blend。
- LUT。

## 人脸检测 / Core ML 工程师

负责：

- Vision 检测。
- 关键点模型。
- 坐标转换。
- 点位平滑。
- 分割模型。

## App Demo 工程师

负责：

- SwiftUI Demo。
- 相机页面。
- 参数面板。
- 图片编辑页面。
- 前后对比。

## 测试 / QA

负责：

- 测试图集。
- 性能测试。
- 兼容性测试。
- 回归测试。
- 效果验收。

---

# 18. 风险点与应对策略

## 18.1 Vision 点位不够精细

风险：

```text
鼻子、嘴唇、眼妆等高级效果贴合不够稳定。
```

应对：

```text
第一版用 Vision。
第二版预留 Core ML 高密度关键点模型接口。
FaceDetecting 使用协议抽象，方便替换检测实现。
```

## 18.2 实时性能不足

风险：

```text
多个效果叠加后掉帧。
```

应对：

```text
合并 Render Pass。
检测降频。
中间纹理复用。
设备分级。
低端设备关闭高级效果。
```

## 18.3 坐标系统复杂

风险：

```text
前置摄像头镜像、横竖屏、图片 EXIF 方向导致点位错位。
```

应对：

```text
早期专门做 CoordinateMapper。
建立坐标转换单元测试。
Debug overlay 必须保留。
```

## 18.4 效果不自然

风险：

```text
瘦脸拉背景、大眼变形、磨皮塑料感、妆容漂移。
```

应对：

```text
每个参数设置最大安全强度。
增加自然度曲线。
增加五官保护 mask。
增加预设参数限制。
```

## 18.5 功能过多导致开发失控

风险：

```text
一开始做几十个功能，结果每个都不稳定。
```

应对：

```text
严格按阶段推进。
每阶段只做可验收功能。
先完成 MVP，再扩展高级功能。
```

---

# 19. 最推荐的实际执行顺序

不要直接从完整功能开始做。

实际执行建议：

```text
第 1 步：先做 SPM 骨架和空渲染链路
第 2 步：做 LUT 和基础颜色
第 3 步：做 Vision 关键点和坐标转换
第 4 步：做统一 FaceWarpEffect
第 5 步：只做大眼和瘦脸
第 6 步：补小脸、V 脸、下巴、瘦鼻、嘴角
第 7 步：做基础磨皮、美白、红润
第 8 步：做预设系统
第 9 步：整理成 1.0 SDK
第 10 步：再做完整五官精修
第 11 步：再做高级皮肤和妆容
第 12 步：最后做背景、身体、视频导出和商业化
```

最重要的一点：

```text
先把 BeautyEngine + Metal RenderGraph + FaceWarpEffect 做稳定。
```

只要这三个东西稳定，后面增加眼睛、鼻子、嘴巴、脸型、美白、磨皮、滤镜，都是在这个底座上扩展。

---

# 20. 第一阶段马上要做的开发任务清单

如果现在马上开工，建议第一周只做这些：

```text
1. 创建 BeautySDK SPM
2. 创建 BeautyCore / BeautyRender / BeautyDetection / BeautyEffects / BeautyResources
3. 实现 Package.swift
4. 实现 BeautyConfiguration
5. 实现 BeautyParameters 空参数模型
6. 实现 BeautyEngine
7. 实现 MetalContext
8. 实现 TextureCache
9. 实现 RenderGraph
10. 实现 CopyRenderPass
11. Demo App 接入 SDK
12. 相机帧输入 SDK
13. SDK 原样输出画面
```

第一周验收目标：

```text
没有任何美颜效果，但 SDK 已经能实时处理相机帧。
```

这是整个项目最重要的第一步。
