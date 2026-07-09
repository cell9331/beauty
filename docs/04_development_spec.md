# iOS Beauty SDK Development Spec

## 1. 文档定位

本文档是 iOS 美颜 SDK 的开发规范与工程约束，用于指导后续代码落地。

适用范围：

- Swift Package Manager 工程组织
- SDK 模块边界
- Swift 代码规范
- Metal 渲染规范
- Vision / Core ML 检测规范
- Core Image / LUT 处理规范
- SwiftUI Demo App 接入规范
- 并发与线程安全规范
- 性能规范
- 资源管理规范
- 测试规范
- 版本交付规范

核心原则：

```text
SDK 只做核心能力。
App 只做 UI 和业务编排。
渲染链路不走 UIImage。
几何形变统一合并。
检测和渲染解耦。
参数统一管理。
资源统一加载。
性能优先，效果其次，功能最后扩展。
```

---

# 2. 总体技术栈

## 2.1 必选技术

```text
Swift
Swift Package Manager
AVFoundation
Vision
Core Image
Metal
Metal Performance Shaders，可选
Core ML，可选但预留
Swift Concurrency
XCTest
```

## 2.2 App Demo 技术

```text
SwiftUI
AVFoundation
MTKView / CAMetalLayer 包装
ObservableObject / @Observable
Swift Concurrency
```

## 2.3 不建议依赖

第一版不建议引入：

```text
第三方美颜 SDK
大型图像处理框架
OpenGL ES
GPUImage 作为核心管线
UIKit-heavy UI 框架
强依赖 Objective-C Runtime 的模块
```

可以参考第三方实现思路，但核心 SDK 应尽量自控。

---

# 3. 工程总体边界

## 3.1 SDK 应该包含什么

SDK 内部只包含：

```text
图像输入模型
参数模型
预设模型
人脸检测
关键点解析
坐标转换
点位平滑
Metal 渲染管线
Core Image / LUT 处理
几何形变
皮肤美颜
妆容渲染
资源加载
错误码
日志
性能统计
图片处理 API
视频帧处理 API
```

## 3.2 SDK 不应该包含什么

SDK 不应该包含：

```text
SwiftUI 页面
UIKit 页面
按钮
滑杆
Tab 菜单
相册选择页面
拍照按钮
业务登录
付费页面
服务端接口
用户账号体系
广告逻辑
具体 App 业务状态
```

## 3.3 App 侧应该包含什么

App 侧负责：

```text
相机页面
图片编辑页面
参数滑杆
美颜分类面板
预设入口
前后对比
保存按钮
导出逻辑入口
权限弹窗
用户交互状态
SwiftUI / UIKit UI
```

App 侧只调用 SDK API，不进入 SDK 内部渲染细节。

---

# 4. SPM 工程规范

## 4.1 Package 组织原则

第一版采用：

```text
一个 Swift Package
多个内部 Target
一个对外 Product
```

不采用：

```text
EyeBeautySDK 独立 Package
NoseBeautySDK 独立 Package
MouthBeautySDK 独立 Package
FaceBeautySDK 独立 Package
```

原因：

```text
眼睛、鼻子、嘴巴、脸型共享检测、点位、坐标、Metal 上下文、纹理缓存、形变系统。
拆成多个 Package 会导致依赖复杂、重复代码、版本管理困难。
```

## 4.2 推荐目录结构

```text
BeautySDK/
├── Package.swift
├── README.md
├── CHANGELOG.md
├── Docs/
│   ├── Architecture.md
│   ├── API.md
│   ├── Parameters.md
│   ├── Performance.md
│   ├── ResourceSpec.md
│   └── IntegrationGuide.md
│
├── Sources/
│   ├── BeautySDK/
│   │   └── BeautySDK.swift
│   │
│   ├── BeautyCore/
│   │   ├── Engine/
│   │   │   ├── BeautyEngine.swift
│   │   │   ├── BeautyImageProcessor.swift
│   │   │   ├── BeautyVideoFrameProcessor.swift
│   │   │   └── BeautyProcessingPipeline.swift
│   │   │
│   │   ├── Models/
│   │   │   ├── BeautyParameters.swift
│   │   │   ├── BeautyConfiguration.swift
│   │   │   ├── BeautyPreset.swift
│   │   │   ├── BeautyFrame.swift
│   │   │   ├── BeautyResult.swift
│   │   │   └── BeautyError.swift
│   │   │
│   │   ├── Diagnostics/
│   │   │   ├── BeautyLogger.swift
│   │   │   ├── BeautyLogEvent.swift
│   │   │   ├── BeautyLogSink.swift
│   │   │   ├── BeautyOSLogSink.swift
│   │   │   ├── BeautyFileLogSink.swift
│   │   │   ├── BeautyLogStore.swift
│   │   │   └── BeautyErrorContext.swift
│   │   │
│   │   └── Utils/
│   │       ├── Clamp.swift
│   │       └── PerformanceTimer.swift
│   │
│   ├── BeautyDetection/
│   │   ├── FaceDetecting.swift
│   │   ├── VisionFaceDetector.swift
│   │   ├── FaceObservation.swift
│   │   ├── FaceLandmarks.swift
│   │   ├── CoordinateMapper.swift
│   │   ├── LandmarkSmoother.swift
│   │   ├── FaceTrackingState.swift
│   │   └── DetectionScheduler.swift
│   │
│   ├── BeautyRender/
│   │   ├── MetalContext.swift
│   │   ├── TextureCache.swift
│   │   ├── PixelBufferPool.swift
│   │   ├── RenderGraph.swift
│   │   ├── RenderPass.swift
│   │   ├── RenderTarget.swift
│   │   ├── ShaderLibrary.swift
│   │   └── Shaders/
│   │       ├── Copy.metal
│   │       ├── Warp.metal
│   │       ├── Skin.metal
│   │       ├── Color.metal
│   │       ├── LUT.metal
│   │       ├── Blend.metal
│   │       └── Mask.metal
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
│   │   │   ├── SkinSharpenEffect.swift
│   │   │   └── SkinMaskEffect.swift
│   │   │
│   │   ├── Color/
│   │   │   ├── ColorAdjustmentEffect.swift
│   │   │   ├── LUTFilterEffect.swift
│   │   │   └── FilterBlendEffect.swift
│   │   │
│   │   ├── Makeup/
│   │   │   ├── LipstickEffect.swift
│   │   │   ├── BlushEffect.swift
│   │   │   ├── EyeLightEffect.swift
│   │   │   ├── EyeshadowEffect.swift
│   │   │   └── MakeupBlendEffect.swift
│   │   │
│   │   └── Background/
│   │       ├── PortraitSegmentationEffect.swift
│   │       ├── BackgroundBlurEffect.swift
│   │       └── BackgroundReplaceEffect.swift
│   │
│   └── BeautyResources/
│       ├── ResourceBundle.swift
│       ├── LUTLoader.swift
│       ├── CubeLUTParser.swift
│       ├── PresetLoader.swift
│       ├── MakeupResourceLoader.swift
│       └── Resources/
│           ├── LUTs/
│           ├── Presets/
│           └── Makeup/
│
└── Tests/
    ├── BeautyCoreTests/
    ├── BeautyDetectionTests/
    ├── BeautyRenderTests/
    ├── BeautyEffectsTests/
    └── BeautyResourcesTests/
```

## 4.3 Package.swift 规范

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
            name: "BeautyCore"
        ),

        .target(
            name: "BeautyDetection",
            dependencies: ["BeautyCore"]
        ),

        .target(
            name: "BeautyRender",
            dependencies: ["BeautyCore"],
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
            dependencies: ["BeautyCore"],
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
            name: "BeautyRenderTests",
            dependencies: ["BeautyRender"]
        ),

        .testTarget(
            name: "BeautyEffectsTests",
            dependencies: ["BeautyEffects"]
        ),

        .testTarget(
            name: "BeautyResourcesTests",
            dependencies: ["BeautyResources"]
        )
    ]
)
```

## 4.4 Target 依赖规则

允许：

```text
BeautySDK -> BeautyCore / BeautyDetection / BeautyRender / BeautyEffects / BeautyResources
BeautyDetection -> BeautyCore
BeautyRender -> BeautyCore
BeautyEffects -> BeautyCore / BeautyDetection / BeautyRender
BeautyResources -> BeautyCore
```

禁止：

```text
BeautyCore -> BeautyRender
BeautyCore -> BeautyDetection
BeautyCore -> BeautyEffects
BeautyCore -> BeautyResources
BeautyRender -> BeautyEffects
BeautyDetection -> BeautyEffects
BeautyResources -> BeautyEffects
```

核心原则：

```text
BeautyCore 必须保持最底层、最稳定。
BeautyEffects 可以依赖检测和渲染。
BeautyRender 不应该知道具体美颜功能。
BeautyDetection 不应该知道具体美颜功能。
BeautyResources 不应该驱动渲染逻辑。
```

---

# 5. 模块职责规范

## 5.1 BeautyCore

负责：

```text
BeautyEngine
BeautyParameters
BeautyConfiguration
BeautyPreset
BeautyError
BeautyFrame
BeautyResult
Logger
基础工具函数
```

不得出现：

```text
MTLDevice
MTLTexture
VNFaceObservation
SwiftUI
UIView
UIImageView
AVCaptureSession 页面逻辑
```

说明：

BeautyCore 是 SDK 的稳定核心，尽量不依赖重量级框架。

## 5.2 BeautyDetection

负责：

```text
Vision 人脸检测
Vision 人脸关键点
未来 Core ML 人脸点位模型
坐标转换
检测降频
点位平滑
人脸跟踪状态
多人脸策略
```

不得出现：

```text
SwiftUI View
具体美颜参数计算
Metal shader 代码
滤镜资源加载
```

## 5.3 BeautyRender

负责：

```text
MetalContext
TextureCache
RenderGraph
RenderPass
ShaderLibrary
PixelBufferPool
MTLCommandBuffer 调度
中间纹理复用
```

不得出现：

```text
眼睛、鼻子、嘴巴业务逻辑
瘦脸参数算法
Vision 检测实现
SwiftUI UI
```

## 5.4 BeautyEffects

负责：

```text
大眼
瘦脸
瘦鼻
嘴角
下巴
磨皮
美白
红润
LUT 滤镜
妆容
背景虚化
身体美型，后期
```

规范：

```text
所有几何形变功能必须优先生成 WarpControlPoint。
所有颜色调整尽量合并到 ColorAdjustmentEffect。
所有美颜效果必须支持 intensity 为 0 时无副作用。
每个 Effect 必须可独立关闭。
```

## 5.5 BeautyResources

负责：

```text
LUT 加载
.cube 解析
Preset JSON 加载
妆容资源加载
资源包版本管理
Bundle.module 访问
```

不得出现：

```text
相机逻辑
渲染调度逻辑
SwiftUI 页面
业务网络请求
```

---

# 6. 对外 API 规范

## 6.1 主入口只暴露 BeautyEngine

App 侧标准使用：

```swift
import BeautySDK

let engine = try BeautyEngine(configuration: .default)

let output = try engine.process(
    pixelBuffer: inputPixelBuffer,
    orientation: .right,
    parameters: parameters
)
```

## 6.2 对外 API 设计原则

必须满足：

```text
简单
稳定
可测试
可扩展
不暴露内部实现
不泄漏 Metal / Vision 细节，除非必要
```

## 6.3 BeautyEngine 规范

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

规则：

```text
process 不允许阻塞主线程。
process 不允许内部创建 UIImage。
process 不允许修改外部传入的 BeautyParameters。
process 在参数全为 0 时应该尽可能走快速路径。
reset 必须清理检测状态、点位平滑状态和缓存状态。
```

## 6.4 BeautyParameters 规范

参数统一使用 Float。

SDK 内部范围：

```text
0.0 ... 1.0：增强型参数
-1.0 ... 1.0：双向调整参数
```

App UI 可以显示：

```text
0 ... 100
-100 ... 100
```

但进入 SDK 前必须归一化。

示例：

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float

    public var brightness: Float
    public var contrast: Float
    public var saturation: Float
    public var temperature: Float
    public var tint: Float
    public var exposure: Float
    public var highlight: Float
    public var shadow: Float

    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float

    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float

    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float

    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float

    public var filterId: String?
    public var filterIntensity: Float
}
```

## 6.5 参数命名规范

使用英文语义命名，不使用拼音。

正确：

```swift
faceSlim
eyeSize
noseWingSlim
mouthWidth
skinSmoothing
filterIntensity
```

错误：

```swift
shoulian
dayan
meibai
mouthBigValue
noseValue1
```

## 6.6 参数默认值规范

所有参数默认必须是无效果状态：

```text
Float 参数默认 0
String? 默认 nil
Bool 默认 false，除非明确表示默认启用
```

---

# 7. Swift 代码规范

## 7.1 命名规范

类型：大驼峰。

```swift
BeautyEngine
FaceWarpEffect
VisionFaceDetector
```

变量 / 方法：小驼峰。

```swift
processFrame
makeControlPoints
inputTexture
```

协议命名：

```text
能力型协议用 -ing
对象型协议用名词
```

示例：

```swift
FaceDetecting
LandmarkSmoothing
BeautyRendering
```

## 7.2 文件命名规范

一个主要类型一个文件。

```text
BeautyEngine.swift
BeautyParameters.swift
VisionFaceDetector.swift
FaceWarpEffect.swift
```

同一类小工具可以合并：

```text
MathUtils.swift
Clamp.swift
```

## 7.3 访问控制规范

默认使用 `internal`。

只对 App 开放的 API 使用 `public`。

禁止滥用 `open`。

```swift
public final class BeautyEngine {}
internal final class VisionFaceDetector {}
private struct InternalState {}
```

规则：

```text
对外 API 越少越好。
内部实现不要 public。
Effect 具体实现一般 internal。
模型如果需要 App 构造则 public。
```

## 7.4 类型设计规范

值类型优先：

```text
参数
配置
点位
结果
错误上下文
```

使用 struct。

引用类型用于：

```text
Engine
Renderer
Detector
Cache
Pool
State Manager
```

使用 final class。

## 7.5 可并发传递类型规范

跨线程、跨 Task 的模型必须尽量满足 `Sendable`：

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {}
public struct BeautyConfiguration: Sendable {}
public struct BeautyFaceObservation: Sendable {}
```

包含不可 Sendable 对象时，不要强行滥用 `@unchecked Sendable`。

只有满足以下条件才允许：

```text
内部状态受串行队列保护
对象只读
对象生命周期明确
没有跨线程可变共享状态
```

## 7.6 错误处理规范

SDK 内部使用 throws，不用 fatalError 处理可恢复错误。

允许 fatalError 的场景：

```text
测试 Stub
明确不可达代码
开发期临时占位，但提交前必须移除
```

错误定义：

```swift
public enum BeautyError: Error, Sendable {
    case metalUnavailable
    case commandQueueCreationFailed
    case textureCreationFailed
    case pixelBufferCreationFailed
    case shaderFunctionNotFound(String)
    case invalidInput
    case unsupportedPixelFormat
    case resourceNotFound(String)
    case presetDecodeFailed(String)
    case lutDecodeFailed(String)
    case renderFailed(String)
    case detectionFailed(String)
}
```

## 7.7 日志规范

SDK 必须有可关闭日志。

```swift
public enum BeautyLogLevel: Int, Sendable {
    case none
    case error
    case warning
    case info
    case debug
}
```

日志不得泄露：

```text
用户图片路径
用户隐私信息
完整设备唯一标识
业务 token
```

## 7.8 统一诊断规范

第一版不单独创建新的 Swift Package。日志、错误上下文和本地诊断存储放在现有 SPM 内的 `BeautyCore/Diagnostics` 目录，后续如果 App 和 SDK 需要跨产品复用，再拆成独立 target 或 package。

核心类型：

```swift
public struct BeautyLogEvent: Sendable {
    public let timestamp: Date
    public let level: BeautyLogLevel
    public let category: String
    public let message: String
    public let errorCode: String?
    public let metadata: [String: String]
}

public protocol BeautyLogSink: Sendable {
    func write(_ event: BeautyLogEvent)
}

public final class BeautyLogger: Sendable {
    public func log(_ event: BeautyLogEvent)
}

public struct BeautyErrorContext: Sendable {
    public let code: String
    public let stage: String
    public let recoverable: Bool
    public let metadata: [String: String]
}
```

内置 sink：

```text
BeautyOSLogSink：写入 os.Logger。
BeautyFileLogSink：按日期写入本地文件。
BeautyLogStore：管理日志目录、导出、清理和保留周期。
```

本地日志规则：

```text
默认关闭文件日志。
Debug 或 App 显式开启后才写本地文件。
按日期滚动，例如 beauty-2026-05-25.log。
默认保留 7 天。
单文件默认最大 5 MB。
所有 metadata 必须脱敏。
App 与 SDK 共用同一个 BeautyLogger 配置。
```

---

# 8. Swift Concurrency 与线程规范

## 8.1 基本原则

```text
UI 在 MainActor。
相机采集在 capture queue。
人脸检测在 detection queue。
Metal 编码在 render queue。
资源加载在 background queue。
```

## 8.2 禁止事项

禁止在主线程做：

```text
Vision 检测
Metal 同步等待
视频帧逐帧处理
大图滤镜处理
LUT 解析
妆容资源解码
```

## 8.3 推荐线程模型

```text
MainActor
    SwiftUI 状态、按钮、滑杆

CaptureQueue
    AVCaptureVideoDataOutput 回调

DetectionQueue
    Vision / Core ML 检测

RenderQueue
    Metal command buffer 编码

ResourceQueue
    LUT / Preset / Makeup 资源加载
```

## 8.4 检测与渲染解耦

禁止每帧强制等待检测结果。

正确流程：

```text
相机帧进入
    ↓
渲染使用最近一次稳定人脸点位
    ↓
检测按间隔异步更新点位
    ↓
点位平滑后进入共享状态
```

## 8.5 CMSampleBuffer 注意事项

实时链路中不要把 `CMSampleBuffer` 随意跨并发域长期持有。

推荐：

```text
在 capture 回调中立即取出 CVPixelBuffer。
必要时 retain pixelBuffer。
不要把 sampleBuffer 丢进多个 Task 长时间处理。
```

## 8.6 状态隔离规范

检测状态、点位状态、缓存状态不得由多个线程直接读写。

推荐方案：

```text
串行队列
actor
锁保护
单线程 render owner
```

第一版建议优先使用串行队列，避免引入过多 actor 与实时渲染调度复杂度。

---

# 9. Metal 渲染规范

## 9.1 实时链路禁止 UIImage

实时相机链路必须是：

```text
CMSampleBuffer
→ CVPixelBuffer
→ CVMetalTexture
→ MTLTexture
→ Metal Render Pass
→ MTLTexture / CVPixelBuffer
→ Display / Encode
```

禁止：

```text
CMSampleBuffer → UIImage → CIImage → CGImage → UIImage
```

## 9.2 MetalContext 规范

`MetalContext` 负责统一管理：

```text
MTLDevice
MTLCommandQueue
CVMetalTextureCache
CIContext，可选
MTLLibrary
```

示例：

```swift
public final class MetalContext {
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let textureCache: CVMetalTextureCache

    public init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw BeautyError.metalUnavailable
        }

        guard let commandQueue = device.makeCommandQueue() else {
            throw BeautyError.commandQueueCreationFailed
        }

        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)

        guard let textureCache = cache else {
            throw BeautyError.textureCreationFailed
        }

        self.device = device
        self.commandQueue = commandQueue
        self.textureCache = textureCache
    }
}
```

## 9.3 Render Pass 合并规范

禁止每个功能一个 Pass。

错误：

```text
EyePass
NosePass
MouthPass
FaceSlimPass
ChinPass
SkinWhitenPass
RosyPass
FilterPass
```

正确：

```text
FaceWarpPass
    大眼
    眼距
    瘦脸
    小脸
    V 脸
    下巴
    瘦鼻
    嘴角

SkinPass
    磨皮
    美白
    红润

ColorPass
    亮度
    对比度
    饱和度
    色温
    锐化

LUTPass
    滤镜
```

## 9.4 推荐渲染顺序

```text
1. Input Texture
2. FaceWarpPass
3. SkinPass
4. MakeupPass
5. ColorAdjustmentPass
6. LUTPass
7. Sharpen / OutputPass
```

第一版可以简化为：

```text
1. Input Texture
2. FaceWarpPass
3. SkinPass
4. Color/LUTPass
5. Output
```

## 9.5 中间纹理规范

使用 ping-pong texture。

```text
textureA -> pass1 -> textureB
textureB -> pass2 -> textureA
textureA -> pass3 -> textureB
```

禁止每帧无节制创建新纹理。

必须有：

```text
TexturePool
PixelBufferPool
RenderTarget 复用
```

## 9.6 Command Buffer 规范

每帧通常只创建一个 `MTLCommandBuffer`。

规则：

```text
同一帧内尽量合并 command encoder。
不要在每个小功能里 commit。
不要频繁 waitUntilCompleted。
只有截图、导出、同步读取时才允许等待。
```

## 9.7 MTLBuffer 规范

控制点、参数等小数据：

```text
可使用 ring buffer / triple buffer
避免 GPU 使用时 CPU 覆盖
```

禁止：

```text
每帧大量创建临时 MTLBuffer
每个 control point 单独一个 buffer
```

正确：

```text
所有 WarpControlPoint 打包成一个 buffer
所有参数打包成一个 uniform buffer
```

## 9.8 Shader 命名规范

Metal 文件：

```text
Warp.metal
Skin.metal
Color.metal
LUT.metal
Blend.metal
Mask.metal
```

函数命名：

```text
beautyWarpKernel
skinSmoothKernel
colorAdjustKernel
lutFilterKernel
blendMakeupKernel
```

结构体命名：

```metal
struct BeautyUniforms
struct WarpControlPointGPU
struct SkinUniforms
```

## 9.9 Metal Shader 参数规范

CPU 与 GPU 共享结构必须明确内存布局。

Swift：

```swift
struct WarpControlPointGPU {
    var source: SIMD2<Float>
    var target: SIMD2<Float>
    var radius: Float
    var strength: Float
    var falloff: Float
    var padding: Float = 0
}
```

Metal：

```metal
struct WarpControlPointGPU {
    float2 source;
    float2 target;
    float radius;
    float strength;
    float falloff;
    float padding;
};
```

规则：

```text
Swift 和 Metal 结构字段顺序必须一致。
必须考虑 16-byte alignment。
新增字段必须同步修改两边。
```

---

# 10. 几何形变规范

## 10.1 统一形变原则

所有五官形变统一转换为：

```swift
[WarpControlPoint]
```

然后由一个 `FaceWarpEffect` 一次性执行。

禁止：

```text
大眼单独 shader
瘦脸单独 shader
瘦鼻单独 shader
嘴角单独 shader
```

## 10.2 WarpControlPoint 规范

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
```

字段含义：

```text
source：原始控制点位置
target：目标控制点位置
radius：影响半径
strength：强度
falloff：衰减曲线
```

## 10.3 Provider 规范

每类功能提供一个 Provider：

```swift
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
```

推荐 Provider：

```text
EyeWarpProvider
NoseWarpProvider
MouthWarpProvider
ChinWarpProvider
FaceShapeWarpProvider
EyebrowWarpProvider
```

## 10.4 眼睛功能规范

第一版支持：

```text
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
```

后续扩展：

```text
eyeWidth
eyeHeight
leftEyeSize
rightEyeSize
innerEyeCorner
outerEyeCorner
```

规则：

```text
大眼影响半径必须限制在眼眶周围。
眼距调整不能明显拉歪鼻梁。
眼尾上扬不能导致眉毛明显错位。
左右眼独立调整必须有同步开关。
```

## 10.5 脸型功能规范

第一版支持：

```text
faceSlim
faceSmall
faceVShape
jawSlim
chinLength
```

规则：

```text
瘦脸以脸颊点向中心移动为主。
小脸以轮廓整体缩小为主。
V 脸以下颌和下巴共同变化为主。
下巴调整不能导致嘴巴严重变形。
背景拉伸必须控制在可接受范围。
```

## 10.6 鼻子功能规范

第一版支持：

```text
noseSlim
noseWingSlim
noseTipSize
noseBridge
```

规则：

```text
瘦鼻优先移动鼻翼点。
鼻头缩小必须限制半径。
鼻梁增强优先用光影，不只靠几何。
鼻子功能强度上限应低于脸型功能。
```

## 10.7 嘴巴功能规范

第一版支持：

```text
mouthSize
mouthWidth
smile
lipColor
```

规则：

```text
嘴角上扬只影响嘴角附近。
嘴巴大小不能导致牙齿区域严重拉伸。
唇色增强不应覆盖唇纹。
后续口红必须基于 lip mask，而不是矩形贴图。
```

---

# 11. 人脸检测与坐标规范

## 11.1 检测抽象规范

必须通过协议抽象：

```swift
public protocol FaceDetecting {
    func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]

    func reset()
}
```

第一版实现：

```text
VisionFaceDetector
```

后续可替换：

```text
CoreMLFaceDetector
DenseLandmarkDetector
FaceMeshDetector
```

## 11.2 FaceObservation 规范

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

## 11.3 坐标系统规范

必须明确以下坐标：

```text
Vision normalized coordinate
Image pixel coordinate
Texture coordinate
Preview coordinate
Mirrored preview coordinate
```

禁止在业务代码里随手转换坐标。

所有转换必须经过：

```swift
CoordinateMapper
```

## 11.4 方向处理规范

必须测试：

```text
前置摄像头竖屏
后置摄像头竖屏
前置摄像头横屏左
前置摄像头横屏右
后置摄像头横屏左
后置摄像头横屏右
相册图片 EXIF 方向
视频帧方向
```

## 11.5 点位平滑规范

必须有：

```text
LandmarkSmoother
```

第一版算法：

```text
EMA exponential moving average
```

后续可扩展：

```text
Kalman Filter
One Euro Filter
```

规则：

```text
检测失败 1~3 帧内可以复用旧点位。
连续失败超过阈值必须清空状态。
低置信度人脸不得进入强形变。
```

## 11.6 检测降频规范

实时相机不允许每一帧都强制完整检测。

推荐：

```text
30fps 渲染
10~15fps 检测
```

配置项：

```swift
public var detectionFrameInterval: Int
```

---

# 12. Core Image 与 LUT 规范

## 12.1 Core Image 使用边界

可以用于：

```text
离线图片滤镜
LUT ColorCube
基础颜色调整
部分非实时处理
```

实时核心链路优先使用 Metal。

## 12.2 CIContext 规范

禁止每帧创建 `CIContext`。

必须由 `MetalContext` 或 Renderer 统一持有并复用。

## 12.3 LUT 规范

支持格式：

```text
.cube
内部二进制 LUT，可选
PNG LUT，可选
```

第一版优先 `.cube`。

LUT 解析规则：

```text
支持 LUT_3D_SIZE
忽略注释行
RGB 转 RGBA
alpha 固定为 1.0
校验数据数量
```

## 12.4 滤镜强度规范

滤镜必须支持强度混合：

```text
output = mix(original, filtered, intensity)
```

`intensity = 0` 必须等于原图。

`intensity = 1` 才是完整滤镜。

---

# 13. 皮肤美颜规范

## 13.1 基础美颜顺序

推荐：

```text
磨皮
美白
红润
锐化
```

不要先锐化再磨皮。

## 13.2 磨皮规范

禁止简单全图高斯模糊作为正式磨皮。

第一版可以使用：

```text
边缘保护模糊
低频平滑
高频细节回加
```

后续升级：

```text
Bilateral Filter
Guided Filter
Frequency Separation
Skin Mask
```

## 13.3 皮肤区域规范

第一版可先全图弱处理。

从 2.0 开始必须支持：

```text
skinMask
featureProtectionMask
```

保护区域：

```text
眼睛
眉毛
嘴巴
牙齿
鼻孔
头发边缘
```

## 13.4 强度规范

高强度参数必须有上限保护。

```text
磨皮不能完全抹掉皮肤纹理。
美白不能让高光溢出。
红润不能让整张脸发红。
```

---

# 14. 妆容系统规范

## 14.1 妆容资源结构

```text
MakeupPackage/
├── config.json
├── preview.png
├── lipstick.png
├── blush.png
├── eyeshadow.png
├── eyeliner.png
├── eyebrow.png
├── highlight.png
└── contour.png
```

## 14.2 config.json 规范

```json
{
  "id": "daily_clean_01",
  "name": "日常清透",
  "version": "1.0.0",
  "items": [
    {
      "type": "lipstick",
      "resource": "lipstick.png",
      "blendMode": "softLight",
      "defaultIntensity": 0.45
    },
    {
      "type": "blush",
      "resource": "blush.png",
      "blendMode": "overlay",
      "defaultIntensity": 0.3
    }
  ]
}
```

## 14.3 Blend Mode 规范

必须支持：

```text
normal
multiply
screen
overlay
softLight
color
```

## 14.4 妆容贴合规范

妆容必须基于关键点或 mask 贴合。

禁止：

```text
固定屏幕位置贴图
固定脸框比例贴图但不跟随旋转
```

---

# 15. SwiftUI Demo App 规范

## 15.1 App 目录建议

```text
BeautyDemoApp/
├── App/
│   └── BeautyDemoApp.swift
│
├── Camera/
│   ├── CameraView.swift
│   ├── CameraViewModel.swift
│   ├── CameraSessionController.swift
│   ├── MetalPreviewView.swift
│   └── CameraBeautyPipeline.swift
│
├── Editor/
│   ├── ImageEditorView.swift
│   ├── ImageEditorViewModel.swift
│   └── CompareView.swift
│
├── Panel/
│   ├── BeautyPanelView.swift
│   ├── BeautyCategoryView.swift
│   ├── BeautySliderView.swift
│   └── BeautyPresetView.swift
│
├── State/
│   ├── BeautyParameterStore.swift
│   └── BeautyPresetStore.swift
│
└── Debug/
    ├── LandmarkDebugOverlay.swift
    └── PerformanceOverlay.swift
```

## 15.2 SwiftUI 边界规范

SwiftUI View 不直接操作 Metal 内部对象。

正确：

```text
View -> ViewModel -> CameraBeautyPipeline -> BeautyEngine
```

错误：

```text
View -> MTLCommandBuffer
View -> FaceWarpEffect
View -> VisionFaceDetector
```

## 15.3 ViewModel 规范

ViewModel 可以持有：

```text
BeautyParameters
当前分类
当前预设
相机状态
处理状态
```

ViewModel 不应该实现：

```text
Metal shader 编码
Vision 检测
滤镜算法
```

## 15.4 参数滑杆规范

UI 显示范围：

```text
0...100
-100...100
```

进入 SDK 前转换：

```swift
let sdkValue = uiValue / 100.0
```

所有滑杆必须支持：

```text
重置
默认值
实时预览
前后对比
```

---

# 16. 性能规范

## 16.1 实时预览目标

第一版目标：

```text
720p：稳定 30fps
1080p：中高端设备稳定 30fps
4K：不作为实时预览目标
```

## 16.2 导出目标

图片导出：

```text
支持原图尺寸处理
大图可以离线处理
允许耗时但不能崩溃
```

视频导出：

```text
逐帧处理
支持进度回调
支持取消
保留音频
保留方向
```

## 16.3 设备分级

```swift
public enum BeautyRenderQuality: Sendable {
    case performance
    case balanced
    case quality
}
```

建议策略：

```text
performance：低分辨率、低检测频率、关闭高级妆容和背景分割
balanced：默认策略
quality：更高分辨率、更高质量磨皮、更多人脸支持
```

## 16.4 性能禁止项

禁止实时链路中：

```text
每帧创建 CIContext
每帧创建 MTLDevice
每帧创建 MTLCommandQueue
每帧 UIImage 转换
每个功能单独 commit command buffer
每帧解析 LUT 文件
每帧加载妆容 PNG
每帧创建大量临时数组
```

## 16.5 性能监控指标

必须记录：

```text
每帧总耗时
检测耗时
渲染耗时
各 Pass 耗时
当前 FPS
丢帧数量
内存峰值
纹理数量
```

---

# 17. 资源管理规范

## 17.1 资源类型

```text
LUT
Preset JSON
Makeup Package
Sticker Texture
Background Texture
Model File
```

## 17.2 SPM 资源访问

SPM 内资源统一通过：

```swift
Bundle.module
```

不得硬编码路径。

## 17.3 资源加载策略

```text
LUT 按需加载并缓存
Preset 启动时可加载
妆容资源按包加载
大贴图延迟加载
未使用资源可释放
```

## 17.4 资源版本规范

资源包必须包含：

```text
id
name
version
minimumSDKVersion
items
```

---

# 18. 测试规范

## 18.1 单元测试

必须覆盖：

```text
BeautyParameters 默认值
参数归一化
LUT 解析
Preset 解析
CoordinateMapper
LandmarkSmoother
资源加载
错误处理
```

## 18.2 渲染测试

建议建立固定测试图集。

测试内容：

```text
大眼
瘦脸
瘦鼻
嘴角
磨皮
美白
滤镜
组合参数
```

## 18.3 坐标测试

必须测试：

```text
前置摄像头镜像
后置摄像头
竖屏
横屏
相册图片 EXIF
视频帧方向
```

## 18.4 性能测试

必须测试：

```text
低端设备
中端设备
高端设备
720p
1080p
长时间运行 10 分钟
多人脸
高强度参数
```

## 18.5 回归测试

建议：

```text
固定图片 + 固定参数
输出图片做差异比较
记录渲染耗时
记录内存峰值
```

---

# 19. Git 与代码提交规范

## 19.1 分支规范

```text
main：稳定发布分支
develop：开发集成分支
feature/*：功能分支
fix/*：修复分支
release/*：发布准备分支
```

## 19.2 Commit 规范

格式：

```text
type(scope): message
```

示例：

```text
feat(render): add MetalContext
feat(warp): add FaceWarpEffect
fix(detection): correct mirrored coordinate mapping
perf(render): reuse intermediate textures
refactor(core): split BeautyParameters
```

类型：

```text
feat
fix
perf
refactor
test
docs
chore
```

## 19.3 PR 规范

PR 必须说明：

```text
做了什么
影响哪些模块
如何测试
是否影响性能
是否影响 API
是否需要更新文档
```

---

# 20. 文档规范

每个核心模块必须有 README 或文档说明。

必须维护：

```text
Architecture.md
API.md
Parameters.md
ResourceSpec.md
Performance.md
IntegrationGuide.md
CHANGELOG.md
```

## 20.1 参数文档规范

每个参数必须说明：

```text
名称
类型
范围
默认值
作用区域
是否双向
是否依赖人脸点位
是否实时支持
性能影响
```

示例：

```text
参数：eyeSize
类型：Float
范围：-1.0 ... 1.0
默认值：0
作用：调整眼睛大小
依赖：人脸关键点 leftEye / rightEye
实时：支持
性能：低
```

---

# 21. 版本规划规范

## 21.1 版本号

使用语义化版本：

```text
MAJOR.MINOR.PATCH
```

示例：

```text
1.0.0
1.1.0
1.1.1
2.0.0
```

## 21.2 版本含义

```text
PATCH：bug fix，不改 API
MINOR：新增兼容功能
MAJOR：破坏性 API 变更
```

## 21.3 推荐版本路线

```text
0.1.0 技术 Demo
0.2.0 SPM 骨架
0.3.0 基础滤镜
0.4.0 人脸关键点
0.5.0 基础形变
1.0.0 第一版美颜 SDK
1.5.0 完整五官精修
2.0.0 高级皮肤与妆容
2.5.0 背景与人像分割
3.0.0 商业化完整 SDK
```

---

# 22. 第一阶段开发任务 Spec

## 22.1 目标

完成无效果的 SDK 闭环。

```text
输入 CVPixelBuffer
    ↓
BeautyEngine
    ↓
Metal RenderGraph
    ↓
CopyRenderPass
    ↓
输出 CVPixelBuffer
```

## 22.2 必做文件

```text
Package.swift
BeautyEngine.swift
BeautyConfiguration.swift
BeautyParameters.swift
BeautyError.swift
MetalContext.swift
TextureCache.swift
PixelBufferPool.swift
RenderGraph.swift
RenderPass.swift
CopyRenderPass.swift
BeautySDK.swift
```

## 22.3 验收标准

```text
App 可以 import BeautySDK
BeautyEngine 可以初始化
输入 CVPixelBuffer 可以输出 CVPixelBuffer
相机实时画面能经过 SDK 再显示
没有 UIImage 中转
没有 UI 代码进入 SDK
没有明显内存泄漏
```

---

# 23. 第二阶段开发任务 Spec

## 23.1 目标

实现基础颜色和 LUT 滤镜。

## 23.2 必做功能

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
filterId
filterIntensity
.cube parsing
LUT loading
```

## 23.3 验收标准

```text
滑杆调整实时生效
滤镜强度为 0 时等于原图
滤镜强度为 1 时为完整滤镜
LUT 不重复解析
图片和相机都可用
```

---

# 24. 第三阶段开发任务 Spec

## 24.1 目标

完成人脸检测、关键点和坐标系统。

## 24.2 必做功能

```text
VisionFaceDetector
BeautyFaceObservation
BeautyFaceLandmarks
CoordinateMapper
LandmarkSmoother
DetectionScheduler
Debug Landmark Overlay
```

## 24.3 验收标准

```text
关键点准确画在脸上
前置摄像头镜像正确
横竖屏正确
检测降频可配置
点位抖动可接受
```

---

# 25. 第四阶段开发任务 Spec

## 25.1 目标

完成统一 FaceWarpEffect。

## 25.2 必做功能

```text
WarpControlPoint
WarpControlPointProvider
FaceWarpEffect
EyeWarpProvider 基础版
FaceShapeWarpProvider 基础版
Warp.metal
```

## 25.3 验收标准

```text
大眼和瘦脸共用同一个 Pass
多个 control points 可以同时生效
强度为 0 等于原图
形变边缘平滑
背景拉伸可控
```

---

# 26. 第五阶段开发任务 Spec

## 26.1 目标

完成 1.0 MVP 核心功能。

## 26.2 必做功能

```text
磨皮基础版
美白
红润
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
预设 JSON
```

## 26.3 验收标准

```text
SDK 可演示
相机实时可用
图片处理可用
参数可保存
预设可应用
效果组合稳定
```

---

# 27. 代码审查 Checklist

每次提交前检查：

```text
是否把 UI 代码放进 SDK 了？
是否在实时链路用了 UIImage？
是否每帧创建了昂贵对象？
是否破坏了 Target 依赖方向？
是否把 internal 写成 public 了？
是否缺少错误处理？
是否缺少参数默认值？
是否影响主线程？
是否增加了 Render Pass？是否必要？
是否有测试？
是否更新文档？
```

---

# 28. 最终落地原则

本项目最重要的工程判断：

```text
1. 先搭底座，不先堆功能。
2. 先做无效果渲染闭环。
3. 再做滤镜。
4. 再做人脸关键点。
5. 再做统一几何形变。
6. 再实现大眼、瘦脸、瘦鼻、嘴角。
7. UI 永远留在 App 层。
8. SDK 永远保持核心、干净、可复用。
9. 性能问题要在架构阶段解决，不要等功能堆完再补救。
10. 所有高级功能都必须建立在稳定的 BeautyEngine + RenderGraph + FaceWarpEffect 之上。
```

一句话总结：

```text
这个 SDK 不是一堆滤镜和滑杆，而是一套实时人像图像处理引擎。
```
