# iOS Beauty SDK Architecture SPM Skeleton

## 1. 结论

第一版不要把眼睛、鼻子、嘴巴、脸型分别拆成独立 Swift Package。

推荐方案：

```text
一个 BeautySDK Swift Package
├── 多个 Target
│   ├── BeautyCore
│   ├── BeautyDetection
│   ├── BeautyRender
│   ├── BeautyEffects
│   ├── BeautyResources
│   └── BeautySDK
└── App 侧只负责 UI、滑杆、预设面板、相机页面展示
```

也就是说：

- 不要做多个独立 SPM：`BeautyEyeSDK`、`BeautyNoseSDK`、`BeautyMouthSDK`。
- 应该做一个大的 `BeautySDK` Package。
- Package 内部用多个 Target 拆分职责。
- 眼睛、鼻子、嘴巴、脸型作为 `BeautyEffects` 内部的 Effect / Provider，而不是独立 Package。
- UI 不放进 SDK，不放进 SPM，UI 放 App 层，用 SwiftUI 或 UIKit 自己实现。

---

# 2. 为什么不建议按五官拆成多个 SPM

## 2.1 五官功能不是彼此独立的

大眼、瘦鼻、嘴角、瘦脸、下巴这些功能表面上属于不同区域，但底层依赖高度相同：

```text
人脸检测
人脸关键点
坐标系转换
点位平滑
Metal 渲染上下文
纹理缓存
形变算法
Render Pass 调度
参数归一化
多人脸策略
```

如果把它们拆成多个独立 SPM，会出现大量重复依赖：

```text
BeautyEyeSDK 依赖 FaceDetection
BeautyNoseSDK 依赖 FaceDetection
BeautyMouthSDK 依赖 FaceDetection
BeautyFaceSDK 依赖 FaceDetection
```

最后会变成：

```text
很多 Package 都在引用同一批基础模块
版本管理复杂
接口边界不稳定
编译配置复杂
调试成本上升
```

第一阶段没有必要这么拆。

## 2.2 几何形变应该统一处理

眼睛、鼻子、嘴巴、脸型，本质上都是局部几何形变。

它们不应该各自写一套 Metal Shader。

正确方式是：

```text
眼睛功能生成 eye control points
鼻子功能生成 nose control points
嘴巴功能生成 mouth control points
脸型功能生成 face control points
        ↓
统一合并成 [WarpControlPoint]
        ↓
统一进入一个 FaceWarpPass
        ↓
Metal 一次性完成形变
```

这样性能最好，也最容易维护。

如果拆成多个独立 SPM，很容易变成：

```text
EyeWarpPass
NoseWarpPass
MouthWarpPass
FaceSlimWarpPass
ChinWarpPass
```

这会导致同一帧反复读写纹理，性能浪费很大。

## 2.3 第一版核心是跑通渲染链路，不是功能拆太细

第一版最重要的是：

```text
相机帧输入
Metal 渲染
Vision 人脸关键点
统一坐标系统
统一形变系统
基础美颜
滤镜
参数系统
```

只要这套底座稳定，后续五官功能都是继续添加 Provider，而不是重新设计架构。

---

# 3. 推荐 SPM 拆分方式

## 3.1 Package 结构

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautySDK/
│   │   └── BeautySDK.swift
│   │
│   ├── BeautyCore/
│   │   ├── BeautyEngine.swift
│   │   ├── BeautyConfiguration.swift
│   │   ├── BeautyParameters.swift
│   │   ├── BeautyPreset.swift
│   │   ├── BeautyError.swift
│   │   ├── BeautyFrame.swift
│   │   ├── BeautyResult.swift
│   │   └── Diagnostics/
│   │       ├── BeautyLogger.swift
│   │       ├── BeautyLogEvent.swift
│   │       ├── BeautyLogSink.swift
│   │       ├── BeautyOSLogSink.swift
│   │       ├── BeautyFileLogSink.swift
│   │       ├── BeautyLogStore.swift
│   │       └── BeautyErrorContext.swift
│   │
│   ├── BeautyDetection/
│   │   ├── FaceDetecting.swift
│   │   ├── VisionFaceDetector.swift
│   │   ├── FaceObservation.swift
│   │   ├── FaceLandmarks.swift
│   │   ├── LandmarkSmoother.swift
│   │   ├── FaceTrackingState.swift
│   │   └── CoordinateMapper.swift
│   │
│   ├── BeautyRender/
│   │   ├── MetalContext.swift
│   │   ├── TextureCache.swift
│   │   ├── PixelBufferPool.swift
│   │   ├── RenderGraph.swift
│   │   ├── RenderPass.swift
│   │   ├── RenderTarget.swift
│   │   └── Shaders/
│   │       ├── Warp.metal
│   │       ├── BeautySkin.metal
│   │       ├── BeautyColor.metal
│   │       ├── BeautyLUT.metal
│   │       └── BeautyBlend.metal
│   │
│   ├── BeautyEffects/
│   │   ├── BeautyEffect.swift
│   │   ├── EffectContext.swift
│   │   │
│   │   ├── Warp/
│   │   │   ├── WarpControlPoint.swift
│   │   │   ├── WarpControlPointProvider.swift
│   │   │   ├── FaceWarpEffect.swift
│   │   │   ├── EyeWarpProvider.swift
│   │   │   ├── NoseWarpProvider.swift
│   │   │   ├── MouthWarpProvider.swift
│   │   │   ├── ChinWarpProvider.swift
│   │   │   └── FaceShapeWarpProvider.swift
│   │   │
│   │   ├── Skin/
│   │   │   ├── SkinSmoothEffect.swift
│   │   │   ├── SkinWhitenEffect.swift
│   │   │   ├── SkinRosyEffect.swift
│   │   │   └── SkinSharpenEffect.swift
│   │   │
│   │   ├── Color/
│   │   │   ├── ColorAdjustmentEffect.swift
│   │   │   ├── LUTFilterEffect.swift
│   │   │   └── FilterBlendEffect.swift
│   │   │
│   │   └── Makeup/
│   │       ├── LipstickEffect.swift
│   │       ├── BlushEffect.swift
│   │       ├── EyeLightEffect.swift
│   │       └── MakeupBlendEffect.swift
│   │
│   └── BeautyResources/
│       ├── LUTLoader.swift
│       ├── CubeLUTParser.swift
│       ├── PresetLoader.swift
│       ├── MakeupResourceLoader.swift
│       └── ResourceBundle.swift
│
└── Tests/
    ├── BeautyCoreTests/
    ├── BeautyDetectionTests/
    ├── BeautyEffectsTests/
    └── BeautyResourcesTests/
```

---

# 4. Target 职责划分

## 4.1 BeautyCore

核心模型和主入口。

负责：

- `BeautyEngine`
- 参数模型
- 预设模型
- 错误类型
- 配置模型
- 处理结果模型
- 日志、错误上下文和本地诊断存储
- 对外 API 定义

不负责：

- UI
- 相机页面
- SwiftUI View
- UIKit 控件
- 参数面板

## 4.2 BeautyDetection

负责人脸检测、关键点、坐标系统。

负责：

- Vision 人脸检测
- 人脸关键点解析
- 多人脸结果管理
- 坐标系转换
- 前置摄像头镜像处理
- 点位平滑
- 检测降频策略

## 4.3 BeautyRender

负责 Metal / Core Image 渲染底座。

负责：

- `MTLDevice`
- `MTLCommandQueue`
- `CVMetalTextureCache`
- `CVPixelBufferPool`
- Metal shader 管理
- Render Graph
- 中间纹理复用
- Render Pass 调度

## 4.4 BeautyEffects

负责所有美颜算法效果。

包括：

- 几何形变
- 眼睛调整
- 鼻子调整
- 嘴巴调整
- 脸型调整
- 磨皮
- 美白
- 红润
- LUT 滤镜
- 妆容混合

注意：

眼睛、鼻子、嘴巴不是独立 Target，而是 `BeautyEffects` 里面的子目录。

## 4.5 BeautyResources

负责资源加载。

负责：

- LUT 资源加载
- `.cube` 解析
- 预设 JSON 加载
- 妆容资源加载
- 图片贴图资源加载
- Bundle 管理

## 4.6 BeautySDK

聚合 Target。

对外只暴露一个模块：

```swift
import BeautySDK
```

App 不需要分别 import：

```swift
import BeautyCore
import BeautyRender
import BeautyEffects
```

除非你未来希望给内部调试工具暴露更多模块。

---

# 5. Package.swift 示例

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BeautySDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BeautySDK",
            targets: ["BeautySDK"]
        )
    ],
    targets: [
        .target(
            name: "BeautySDK",
            dependencies: [
                "BeautyCore",
                "BeautyDetection",
                "BeautyRender",
                "BeautyEffects",
                "BeautyResources"
            ]
        ),

        .target(
            name: "BeautyCore",
            dependencies: []
        ),

        .target(
            name: "BeautyDetection",
            dependencies: [
                "BeautyCore"
            ]
        ),

        .target(
            name: "BeautyRender",
            dependencies: [
                "BeautyCore"
            ],
            resources: [
                .process("Shaders")
            ]
        ),

        .target(
            name: "BeautyEffects",
            dependencies: [
                "BeautyCore",
                "BeautyDetection",
                "BeautyRender"
            ]
        ),

        .target(
            name: "BeautyResources",
            dependencies: [
                "BeautyCore"
            ],
            resources: [
                .process("Resources")
            ]
        ),

        .testTarget(
            name: "BeautyCoreTests",
            dependencies: ["BeautyCore"]
        ),

        .testTarget(
            name: "BeautyDetectionTests",
            dependencies: ["BeautyDetection"]
        ),

        .testTarget(
            name: "BeautyEffectsTests",
            dependencies: ["BeautyEffects"]
        )
    ]
)
```

---

# 6. App 侧应该放什么

App 侧负责 UI 和业务编排。

例如：

```text
BeautyDemoApp/
├── Camera/
│   ├── CameraView.swift
│   ├── CameraViewModel.swift
│   ├── CameraSessionController.swift
│   └── MetalPreviewView.swift
│
├── Editor/
│   ├── ImageEditorView.swift
│   ├── ImageEditorViewModel.swift
│   └── CompareView.swift
│
├── BeautyPanel/
│   ├── BeautyPanelView.swift
│   ├── BeautySliderView.swift
│   ├── BeautyCategoryView.swift
│   └── BeautyPresetView.swift
│
└── AppState/
    ├── BeautyParameterStore.swift
    └── BeautyPresetStore.swift
```

App 侧可以用 SwiftUI。

SDK 不关心：

- 按钮怎么排
- 滑杆长什么样
- 一级分类怎么显示
- 预设入口在哪里
- 是否用 SwiftUI
- 是否用 UIKit

SDK 只关心：

```text
给我输入图像
给我参数
我输出处理后的图像
```

---

# 7. 第一版是否包含所有功能

不建议第一版包含全部功能。

第一版应该包含“架构闭环 + 最核心效果”，而不是把产品规划里的几十个功能全部实现。

## 7.1 第一版必须包含的能力

第一版建议包含：

```text
基础链路：
1. 图片输入处理
2. 相机实时帧处理
3. Metal 渲染输出
4. 参数系统
5. 预设系统基础版
6. LUT 滤镜基础版

检测能力：
7. Vision 人脸检测
8. Vision 人脸关键点
9. 坐标系转换
10. 点位平滑

基础美颜：
11. 磨皮基础版
12. 美白
13. 红润
14. 清晰度 / 锐化

几何形变：
15. 大眼
16. 瘦脸
17. 小脸
18. V 脸基础版
19. 下巴基础版
20. 瘦鼻基础版
21. 嘴角微笑基础版
```

这已经是一个完整 MVP。

## 7.2 第一版不建议包含的能力

这些不建议第一版做：

```text
1. 完整妆容系统
2. 复杂眼影
3. 眼线
4. 睫毛
5. 美瞳
6. 发际线
7. 法令纹精修
8. 自动祛痘
9. 高精度牙齿美白
10. 高级鼻基底
11. 身体美型
12. 背景替换
13. AI 风格化
14. 多人脸独立调参
15. 复杂局部修复笔
```

这些应该放到第二阶段或第三阶段。

---

# 8. 第一版功能边界

## 8.1 眼睛第一版

第一版做：

```text
大眼
眼距
眼睛上下位置
眼尾轻微上扬
```

不做：

```text
复杂眼型切换
猫眼 / 桃花眼 / 丹凤眼
眼线
睫毛
美瞳
复杂卧蚕
```

## 8.2 鼻子第一版

第一版做：

```text
瘦鼻
鼻翼收窄
鼻头缩小
鼻梁轻微增强
```

不做：

```text
鼻孔精细调整
鼻基底
复杂鼻影
鼻梁真实 3D 重建
```

## 8.3 嘴巴第一版

第一版做：

```text
嘴巴大小
嘴巴宽度
嘴角微笑
基础唇色增强
```

不做：

```text
完整口红贴合
唇釉
M 唇
唇峰重塑
牙齿精修
```

## 8.4 脸型第一版

第一版做：

```text
瘦脸
小脸
V 脸
下巴长度
下颌线轻微收紧
```

不做：

```text
颧骨精细调整
左右脸手动独立调整
面部对称重建
中庭 / 下庭比例高级调整
```

---

# 9. 对外 API 第一版设计

## 9.1 BeautyEngine

```swift
public final class BeautyEngine {

    public init(configuration: BeautyConfiguration = .default) throws

    public func process(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer

    public func process(
        image: CIImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CIImage

    public func reset()
}
```

## 9.2 BeautyConfiguration

```swift
public struct BeautyConfiguration: Sendable {
    public var preferredProcessingSize: CGSize?
    public var maximumFaceCount: Int
    public var enableFaceTracking: Bool
    public var detectionFrameInterval: Int
    public var renderQuality: BeautyRenderQuality
    public var enablePerformanceLog: Bool
    public var enableDebugMode: Bool
    public var logLevel: BeautyLogLevel

    public static let `default` = BeautyConfiguration(
        preferredProcessingSize: nil,
        maximumFaceCount: 1,
        enableFaceTracking: true,
        detectionFrameInterval: 3,
        renderQuality: .balanced,
        enablePerformanceLog: false,
        enableDebugMode: false,
        logLevel: .error
    )
}

public enum BeautyLogLevel: Int, Sendable {
    case none
    case error
    case warning
    case info
    case debug
}

public enum BeautyRenderQuality: Sendable {
    case performance
    case balanced
    case quality
}
```

## 9.3 BeautyParameters

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {

    // MARK: - Skin
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float

    // MARK: - Color
    public var brightness: Float
    public var contrast: Float
    public var saturation: Float
    public var temperature: Float
    public var tint: Float
    public var exposure: Float
    public var highlight: Float
    public var shadow: Float

    // MARK: - Face Shape
    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float

    // MARK: - Eyes
    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float

    // MARK: - Nose
    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float

    // MARK: - Mouth
    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float

    // MARK: - Filter
    public var filterId: String?
    public var filterIntensity: Float

    public init(
        skinSmoothing: Float = 0,
        skinWhitening: Float = 0,
        skinRosy: Float = 0,
        skinSharpen: Float = 0,
        brightness: Float = 0,
        contrast: Float = 0,
        saturation: Float = 0,
        temperature: Float = 0,
        tint: Float = 0,
        exposure: Float = 0,
        highlight: Float = 0,
        shadow: Float = 0,
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0,
        lipColor: Float = 0,
        filterId: String? = nil,
        filterIntensity: Float = 0
    ) {
        self.skinSmoothing = skinSmoothing
        self.skinWhitening = skinWhitening
        self.skinRosy = skinRosy
        self.skinSharpen = skinSharpen
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.temperature = temperature
        self.tint = tint
        self.exposure = exposure
        self.highlight = highlight
        self.shadow = shadow
        self.faceSlim = faceSlim
        self.faceSmall = faceSmall
        self.faceVShape = faceVShape
        self.jawSlim = jawSlim
        self.chinLength = chinLength
        self.eyeSize = eyeSize
        self.eyeDistance = eyeDistance
        self.eyeYPosition = eyeYPosition
        self.eyeTailLift = eyeTailLift
        self.noseSlim = noseSlim
        self.noseWingSlim = noseWingSlim
        self.noseTipSize = noseTipSize
        self.noseBridge = noseBridge
        self.mouthSize = mouthSize
        self.mouthWidth = mouthWidth
        self.smile = smile
        self.lipColor = lipColor
        self.filterId = filterId
        self.filterIntensity = filterIntensity
    }
}
```

---

# 10. 内部核心模型

## 10.1 FaceObservation

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

## 10.2 FaceLandmarks

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

## 10.3 WarpControlPoint

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float

    public init(
        source: SIMD2<Float>,
        target: SIMD2<Float>,
        radius: Float,
        strength: Float,
        falloff: Float = 1
    ) {
        self.source = source
        self.target = target
        self.radius = radius
        self.strength = strength
        self.falloff = falloff
    }
}
```

---

# 11. Effect 设计

## 11.1 BeautyEffect 协议

```swift
public protocol BeautyEffect {
    var isEnabled: Bool { get }

    func encode(
        input: MTLTexture,
        output: MTLTexture,
        context: BeautyRenderContext
    ) throws
}
```

## 11.2 BeautyRenderContext

```swift
public struct BeautyRenderContext {
    public let device: MTLDevice
    public let commandBuffer: MTLCommandBuffer
    public let parameters: BeautyParameters
    public let faces: [BeautyFaceObservation]
    public let inputSize: CGSize
    public let outputSize: CGSize
}
```

---

# 12. 统一形变系统

## 12.1 WarpControlPointProvider

```swift
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
```

## 12.2 EyeWarpProvider

```swift
public final class EyeWarpProvider: WarpControlPointProvider {

    public init() {}

    public func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint] {
        var points: [WarpControlPoint] = []

        if parameters.eyeSize != 0 {
            points += makeEyeSizePoints(
                landmarks: face.landmarks,
                strength: parameters.eyeSize
            )
        }

        if parameters.eyeDistance != 0 {
            points += makeEyeDistancePoints(
                landmarks: face.landmarks,
                strength: parameters.eyeDistance
            )
        }

        if parameters.eyeYPosition != 0 {
            points += makeEyeYPositionPoints(
                landmarks: face.landmarks,
                strength: parameters.eyeYPosition
            )
        }

        if parameters.eyeTailLift != 0 {
            points += makeEyeTailLiftPoints(
                landmarks: face.landmarks,
                strength: parameters.eyeTailLift
            )
        }

        return points
    }

    private func makeEyeSizePoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        // 第一版先计算左右眼中心点和半径
        // 后续再增加更复杂的眼角、眼尾、眼高控制点
        return []
    }

    private func makeEyeDistancePoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }

    private func makeEyeYPositionPoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }

    private func makeEyeTailLiftPoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }
}
```

## 12.3 NoseWarpProvider

```swift
public final class NoseWarpProvider: WarpControlPointProvider {

    public init() {}

    public func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint] {
        var points: [WarpControlPoint] = []

        if parameters.noseSlim != 0 {
            points += makeNoseSlimPoints(
                landmarks: face.landmarks,
                strength: parameters.noseSlim
            )
        }

        if parameters.noseWingSlim != 0 {
            points += makeNoseWingSlimPoints(
                landmarks: face.landmarks,
                strength: parameters.noseWingSlim
            )
        }

        if parameters.noseTipSize != 0 {
            points += makeNoseTipSizePoints(
                landmarks: face.landmarks,
                strength: parameters.noseTipSize
            )
        }

        return points
    }

    private func makeNoseSlimPoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }

    private func makeNoseWingSlimPoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }

    private func makeNoseTipSizePoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }
}
```

## 12.4 MouthWarpProvider

```swift
public final class MouthWarpProvider: WarpControlPointProvider {

    public init() {}

    public func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint] {
        var points: [WarpControlPoint] = []

        if parameters.mouthSize != 0 {
            points += makeMouthSizePoints(
                landmarks: face.landmarks,
                strength: parameters.mouthSize
            )
        }

        if parameters.mouthWidth != 0 {
            points += makeMouthWidthPoints(
                landmarks: face.landmarks,
                strength: parameters.mouthWidth
            )
        }

        if parameters.smile != 0 {
            points += makeSmilePoints(
                landmarks: face.landmarks,
                strength: parameters.smile
            )
        }

        return points
    }

    private func makeMouthSizePoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }

    private func makeMouthWidthPoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }

    private func makeSmilePoints(
        landmarks: BeautyFaceLandmarks,
        strength: Float
    ) -> [WarpControlPoint] {
        return []
    }
}
```

## 12.5 FaceWarpEffect

```swift
public final class FaceWarpEffect: BeautyEffect {

    public var isEnabled: Bool {
        true
    }

    private let providers: [WarpControlPointProvider]

    public init(providers: [WarpControlPointProvider]) {
        self.providers = providers
    }

    public func encode(
        input: MTLTexture,
        output: MTLTexture,
        context: BeautyRenderContext
    ) throws {
        var allPoints: [WarpControlPoint] = []

        for face in context.faces {
            for provider in providers {
                allPoints += provider.makeControlPoints(
                    face: face,
                    parameters: context.parameters,
                    imageSize: context.inputSize
                )
            }
        }

        guard !allPoints.isEmpty else {
            // copy input to output
            return
        }

        // 这里把 allPoints 上传到 Metal Buffer
        // 然后通过统一的 Warp.metal 做一次性形变
    }
}
```

---

# 13. BeautyEngine 第一版骨架

```swift
public final class BeautyEngine {

    private let configuration: BeautyConfiguration
    private let detector: FaceDetecting
    private let smoother: LandmarkSmoother
    private let renderer: BeautyRenderer

    public init(configuration: BeautyConfiguration = .default) throws {
        self.configuration = configuration
        self.detector = VisionFaceDetector(configuration: configuration)
        self.smoother = LandmarkSmoother()
        self.renderer = try BeautyRenderer(configuration: configuration)
    }

    public func process(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer {
        let faces = try detector.detectIfNeeded(
            pixelBuffer: pixelBuffer,
            orientation: orientation
        )

        let stableFaces = smoother.smooth(faces)

        return try renderer.render(
            pixelBuffer: pixelBuffer,
            faces: stableFaces,
            parameters: parameters
        )
    }

    public func process(
        image: CIImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CIImage {
        try renderer.render(
            image: image,
            orientation: orientation,
            parameters: parameters
        )
    }

    public func reset() {
        smoother.reset()
        detector.reset()
    }
}
```

---

# 14. RenderGraph 第一版设计

第一版不要每个功能一个 Pass。

推荐：

```text
Pass 1：FaceWarpPass
    大眼
    眼距
    眼睛上下
    眼尾上扬
    瘦脸
    小脸
    V 脸
    下巴
    瘦鼻
    嘴角

Pass 2：SkinPass
    磨皮
    美白
    红润

Pass 3：ColorPass
    亮度
    对比度
    饱和度
    锐化

Pass 4：LUTPass
    滤镜
```

伪代码：

```swift
final class BeautyRenderer {

    private let renderGraph: RenderGraph

    init(configuration: BeautyConfiguration) throws {
        self.renderGraph = RenderGraph(effects: [
            FaceWarpEffect(providers: [
                EyeWarpProvider(),
                FaceShapeWarpProvider(),
                ChinWarpProvider(),
                NoseWarpProvider(),
                MouthWarpProvider()
            ]),
            SkinBeautyEffect(),
            ColorAdjustmentEffect(),
            LUTFilterEffect()
        ])
    }

    func render(
        pixelBuffer: CVPixelBuffer,
        faces: [BeautyFaceObservation],
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer {
        // 1. CVPixelBuffer -> MTLTexture
        // 2. RenderGraph encode
        // 3. MTLTexture -> CVPixelBuffer
        // 4. return
        throw BeautyError.renderFailed("Renderer skeleton is not implemented")
    }
}
```

---

# 15. 开发顺序

## 阶段 1：搭底座

目标：不做美颜，只跑通图像管线。

任务：

```text
1. 创建 BeautySDK SPM
2. 创建 BeautyCore / BeautyRender / BeautyDetection / BeautyEffects / BeautyResources Targets
3. 实现 BeautyParameters
4. 实现 BeautyEngine 空流程
5. 实现 CVPixelBuffer -> MTLTexture
6. 实现 MTLTexture -> 屏幕显示或输出 CVPixelBuffer
7. App 侧用 SwiftUI 做一个简单 Demo 页面
```

验收标准：

```text
相机画面可以通过 SDK 处理后显示
即使没有任何美颜，也能稳定 30fps
没有 UIImage 中转
```

## 阶段 2：滤镜和颜色

任务：

```text
1. 实现亮度 / 对比度 / 饱和度
2. 实现 LUT 加载
3. 实现 filterIntensity 混合
4. 实现美白基础版
5. 实现红润基础版
```

验收标准：

```text
图片和实时相机都能加滤镜
滑杆实时变化
参数可以保存和恢复
```

## 阶段 3：Vision 人脸关键点

任务：

```text
1. 实现 VisionFaceDetector
2. 解析 faceContour / leftEye / rightEye / nose / lips
3. 实现 CoordinateMapper
4. App 侧 Debug 模式绘制关键点
5. 实现 LandmarkSmoother
```

验收标准：

```text
前置摄像头点位不反
横竖屏点位正确
点位基本稳定
```

## 阶段 4：统一形变系统

任务：

```text
1. 定义 WarpControlPoint
2. 定义 WarpControlPointProvider
3. 实现 FaceWarpEffect
4. 实现 Warp.metal
5. 实现大眼
6. 实现瘦脸
```

验收标准：

```text
大眼、瘦脸能实时运行
形变区域平滑
背景变形不明显
```

## 阶段 5：补齐 MVP 五官功能

任务：

```text
1. 眼距
2. 眼睛上下
3. 眼尾上扬
4. 小脸
5. V 脸
6. 下巴
7. 瘦鼻
8. 鼻翼
9. 嘴巴大小
10. 嘴角微笑
```

验收标准：

```text
所有功能共用一个 FaceWarpPass
不是每个功能一个 Pass
参数组合后没有明显冲突
```

## 阶段 6：磨皮

任务：

```text
1. 实现基础磨皮
2. 增加边缘保护
3. 增加五官保护
4. 增加强度控制
```

验收标准：

```text
皮肤变平滑
眼睛眉毛嘴巴不糊
不要出现塑料脸
```

## 阶段 7：预设系统

任务：

```text
1. BeautyPreset Codable
2. JSON 预设加载
3. 默认自然美颜
4. 清透
5. 精致
6. 男生自然
```

验收标准：

```text
App 侧选择预设后直接得到 BeautyParameters
SDK 不关心 UI 入口
```

---

# 16. 第一版完成后的能力

第一版完成后，SDK 应该可以做到：

```text
import BeautySDK

let engine = try BeautyEngine()
let parameters = BeautyParameters(
    skinSmoothing: 0.35,
    skinWhitening: 0.25,
    skinRosy: 0.15,
    faceSlim: 0.25,
    eyeSize: 0.2,
    noseSlim: 0.15,
    smile: 0.1,
    filterId: "clean_01",
    filterIntensity: 0.4
)

let output = try engine.process(
    pixelBuffer: inputPixelBuffer,
    orientation: .right,
    parameters: parameters
)
```

App 侧只需要把滑杆的值映射到 `BeautyParameters`。

---

# 17. 后续扩展方式

后续增加新功能时，不需要改 SDK 大结构。

例如增加卧蚕：

```text
BeautyEffects/Makeup/EyeBagEffect.swift
```

例如增加牙齿美白：

```text
BeautyEffects/Makeup/TeethWhitenEffect.swift
```

例如增加高级鼻子：

```text
BeautyEffects/Warp/NoseAdvancedWarpProvider.swift
```

例如增加身体美型：

可以考虑新增：

```text
BeautyBodyEffects
```

或者先放在：

```text
BeautyEffects/Body/
```

如果未来身体美型变得很复杂，再拆独立 Target。

---

# 18. 最终建议

第一版推荐架构：

```text
一个 SPM Package
多个内部 Target
一个对外 BeautySDK 产品
UI 完全放 App
五官功能作为 BeautyEffects 内部模块
所有几何形变合并到一个 FaceWarpPass
所有颜色调整尽量合并到一个 ColorPass
检测和渲染分离
参数模型统一管理
```

不要第一版就追求全部功能。

第一版的目标应该是：

```text
跑通架构
跑通实时渲染
跑通 Vision 关键点
跑通统一形变
跑通基础美颜
跑通 LUT 滤镜
做出大眼、瘦脸、瘦鼻、嘴角这些标志性效果
```

这比一次性铺开几十个功能更靠谱。
