# Beauty SDK Public API Design

## 1. 文档目标

本文档定义 BeautySDK 对 App 集成方暴露的公开 API。

目标：

```text
1. App 集成简单。
2. API 稳定、清晰、可测试。
3. 不暴露内部 Metal / Vision / Core ML 细节。
4. 支持实时相机、图片处理、后续视频导出。
5. 支持参数预设、资源加载、错误处理、性能配置。
6. SDK 不包含 UI，SwiftUI / UIKit UI 由 App 自己实现。
```

核心原则：

```text
App 只需要关心：输入图像 + 参数 + 输出结果。
SDK 内部负责：检测、坐标、渲染、资源、算法、性能调度。
```

---

# 2. 对外模块

App 侧只需要：

```swift
import BeautySDK
```

不建议 App 直接 import 内部 Target：

```swift
import BeautyCore
import BeautyRender
import BeautyDetection
import BeautyEffects
import BeautyResources
```

内部 Target 可以存在，但对外通过 `BeautySDK` 聚合。

---

# 3. API 总览

第一版对外 API 分为以下几类：

```text
1. Engine 主入口
2. Configuration 配置
3. Parameters 参数
4. Preset 预设
5. Resource 资源加载
6. Image Processing 图片处理
7. Realtime Frame Processing 实时帧处理
8. Video Processing 视频处理，后续版本
9. Error 错误处理
10. Logging / Performance 调试与性能
```

第一版 MVP 重点暴露：

```text
BeautyEngine
BeautyConfiguration
BeautyParameters
BeautyPreset
BeautyPresetLoader
BeautyError
BeautyProcessingResult
```

---

# 4. BeautyEngine

## 4.1 定位

`BeautyEngine` 是 SDK 的唯一核心处理入口。

负责：

```text
1. 初始化渲染管线。
2. 初始化检测模块。
3. 接收输入图像。
4. 接收参数。
5. 调度检测、渲染、效果处理。
6. 输出处理结果。
7. 管理内部状态。
```

不负责：

```text
1. 相机 Session 创建。
2. SwiftUI 页面。
3. 参数滑杆。
4. 拍照按钮。
5. 相册选择。
6. App 业务状态。
```

---

## 4.2 API 定义

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

---

## 4.3 初始化

```swift
let configuration = BeautyConfiguration.default
let engine = try BeautyEngine(configuration: configuration)
```

初始化可能失败的情况：

```text
Metal 不可用
CommandQueue 创建失败
Shader 加载失败
PixelBufferPool 创建失败
资源初始化失败
```

因此初始化使用 `throws`。

---

## 4.4 实时帧处理

```swift
let outputPixelBuffer = try engine.process(
    pixelBuffer: inputPixelBuffer,
    orientation: .right,
    parameters: parameters
)
```

使用场景：

```text
相机实时预览
实时录制前处理
视频通话帧处理
直播推流帧处理
```

规则：

```text
1. 不要在主线程调用高频实时处理。
2. 不要把 CMSampleBuffer 长时间传入 SDK。
3. App 侧应从 CMSampleBuffer 中取出 CVPixelBuffer 后传入。
4. SDK 返回新的 CVPixelBuffer 或内部复用池中的 CVPixelBuffer。
5. App 不应修改返回的 PixelBuffer 内容。
6. 第一版同步 API 必须运行在 App 提供的相机处理队列或 SDK 内部实时处理器队列中。
7. 实时链路必须设置 in-flight 上限；超过预算时应丢帧、复用上一帧或返回原始帧。
8. `waitUntilCompleted()` 只允许作为离线处理或第一版调试路径，不能成为实时高频路径的长期实现。
```

---

## 4.5 图片处理

```swift
let outputImage = try engine.process(
    image: inputCIImage,
    orientation: .up,
    parameters: parameters
)
```

使用场景：

```text
相册图片编辑
拍照后精修
头像生成
批量图片处理
```

规则：

```text
1. 图片处理允许比实时帧更高质量。
2. 图片处理可以使用 quality 模式。
3. 大图处理不能阻塞主线程。
4. App 侧负责最终导出 JPEG / PNG / HEIF。
```

---

## 4.6 reset

```swift
engine.reset()
```

作用：

```text
清空人脸跟踪状态
清空点位平滑状态
清空检测缓存
清空临时渲染状态
重置内部帧计数
```

调用场景：

```text
切换前后摄像头
切换视频源
重新进入相机页面
图片切换
用户关闭编辑页面
检测状态异常
```

---

# 5. BeautyConfiguration

## 5.1 定位

`BeautyConfiguration` 用于控制 SDK 的运行策略。

它不是美颜参数，而是处理配置。

例如：

```text
最大人脸数
检测频率
处理质量
是否启用人脸跟踪
偏好处理尺寸
是否输出性能统计
```

---

## 5.2 API 定义

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

    public static let `default`: BeautyConfiguration

    public init(
        preferredProcessingSize: CGSize? = nil,
        maximumFaceCount: Int = 1,
        enableFaceTracking: Bool = true,
        detectionFrameInterval: Int = 3,
        renderQuality: BeautyRenderQuality = .balanced,
        enablePerformanceLog: Bool = false,
        enableDebugMode: Bool = false,
        logLevel: BeautyLogLevel = .error
    )
}
```

---

## 5.3 BeautyRenderQuality

```swift
public enum BeautyRenderQuality: String, Codable, Sendable {
    case performance
    case balanced
    case quality
}
```

### performance

适合：

```text
低端设备
直播
视频通话
长时间运行
```

策略：

```text
较低处理分辨率
较低检测频率
关闭高级效果
限制最大人脸数
```

### balanced

适合：

```text
默认相机预览
普通自拍
短视频录制
```

策略：

```text
质量和性能平衡
默认推荐
```

### quality

适合：

```text
图片编辑
拍照后处理
高端设备
离线视频导出
```

策略：

```text
更高处理分辨率
更高质量磨皮
允许更复杂效果
```

---

## 5.4 配置示例

### 默认配置

```swift
let engine = try BeautyEngine(configuration: .default)
```

### 实时相机性能优先

```swift
let configuration = BeautyConfiguration(
    preferredProcessingSize: CGSize(width: 720, height: 1280),
    maximumFaceCount: 1,
    enableFaceTracking: true,
    detectionFrameInterval: 3,
    renderQuality: .performance,
    enablePerformanceLog: false,
    enableDebugMode: false,
    logLevel: .error
)

let engine = try BeautyEngine(configuration: configuration)
```

### 图片编辑质量优先

```swift
let configuration = BeautyConfiguration(
    preferredProcessingSize: nil,
    maximumFaceCount: 1,
    enableFaceTracking: false,
    detectionFrameInterval: 1,
    renderQuality: .quality,
    enablePerformanceLog: true,
    enableDebugMode: false,
    logLevel: .info
)

let engine = try BeautyEngine(configuration: configuration)
```

---

# 6. BeautyParameters

## 6.1 定位

`BeautyParameters` 表示当前美颜效果参数。

它应该：

```text
Codable
Equatable
Sendable
默认无效果
可以保存
可以从 preset 加载
可以实时修改
```

---

## 6.2 API 定义

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {

    // Skin
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float

    // Color
    public var brightness: Float
    public var contrast: Float
    public var saturation: Float
    public var temperature: Float
    public var tint: Float
    public var exposure: Float
    public var highlight: Float
    public var shadow: Float

    // Face Shape
    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float

    // Eyes
    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float

    // Nose
    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float

    // Mouth
    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float

    // Filter
    public var filterId: String?
    public var filterIntensity: Float

    public init(...)
}
```

---

## 6.3 默认参数

```swift
let parameters = BeautyParameters()
```

默认状态：

```text
所有 Float 参数为 0
filterId 为 nil
filterIntensity 为 0
```

这意味着：

```text
无美颜
无形变
无滤镜
输出应接近原图
```

---

## 6.4 参数范围

```text
增强型参数：0.0 ... 1.0
双向参数：-1.0 ... 1.0
```

SDK 内部会做二次 clamp。

App 侧也应保证传入合法范围。

---

## 6.5 参数更新方式

App 侧推荐使用值类型状态：

```swift
@Published var parameters = BeautyParameters()
```

或 SwiftUI Observation：

```swift
@Observable
final class BeautyParameterStore {
    var parameters = BeautyParameters()
}
```

滑杆更新：

```swift
parameters.eyeSize = sliderValue / 100.0
```

---

# 7. BeautyPreset

## 7.1 定位

`BeautyPreset` 表示一组美颜参数配置。

用于：

```text
自然
清透
精致
男生自然
证件照自然
甜美
```

---

## 7.2 API 定义

```swift
public struct BeautyPreset: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let version: String
    public let parameters: BeautyParameters

    public init(
        id: String,
        name: String,
        version: String,
        parameters: BeautyParameters
    )
}
```

---

## 7.3 JSON 示例

```json
{
  "id": "natural_01",
  "name": "自然",
  "version": "1.0.0",
  "parameters": {
    "skinSmoothing": 0.22,
    "skinWhitening": 0.12,
    "skinRosy": 0.08,
    "skinSharpen": 0.08,
    "faceSlim": 0.08,
    "faceSmall": 0.04,
    "faceVShape": 0.04,
    "jawSlim": 0.02,
    "chinLength": 0,
    "eyeSize": 0.06,
    "eyeDistance": 0,
    "eyeYPosition": 0,
    "eyeTailLift": 0.02,
    "noseSlim": 0.04,
    "noseWingSlim": 0.02,
    "noseTipSize": 0,
    "noseBridge": 0.03,
    "mouthSize": 0,
    "mouthWidth": 0,
    "smile": 0.03,
    "lipColor": 0.08,
    "filterId": "clean_01",
    "filterIntensity": 0.2
  }
}
```

---

# 8. BeautyPresetLoader

## 8.1 定位

`BeautyPresetLoader` 负责加载 SDK 内置或 App 自定义的预设 JSON。

---

## 8.2 API 定义

```swift
public struct BeautyPresetLoader {

    public init()

    public func loadBuiltInPresets() throws -> [BeautyPreset]

    public func loadPreset(from url: URL) throws -> BeautyPreset

    public func loadPresets(from directoryURL: URL) throws -> [BeautyPreset]

    public func decodePreset(from data: Data) throws -> BeautyPreset
}
```

---

## 8.3 使用示例

```swift
let loader = BeautyPresetLoader()
let presets = try loader.loadBuiltInPresets()

let natural = presets.first { $0.id == "natural_01" }
parameters = natural?.parameters ?? BeautyParameters()
```

---

# 9. Resource API

## 9.1 第一版资源范围

第一版资源主要包括：

```text
LUT 滤镜
Preset JSON
```

后续扩展：

```text
Makeup Package
Background Resource
Sticker Resource
Core ML Model
```

---

## 9.2 BeautyResourceManager

第一版可以不暴露复杂资源管理器，内部自动加载资源。

如果需要 App 自定义资源，可以提供：

```swift
public final class BeautyResourceManager {

    public func registerLUT(
        id: String,
        url: URL
    ) throws

    public func unregisterLUT(id: String)

    public func containsLUT(id: String) -> Bool
}
```

建议：

```text
1.0 可以先不公开 BeautyResourceManager。
1.5 或 2.0 再开放自定义资源注册。
```

---

# 10. 图片处理 API

## 10.1 基础 API

```swift
public func process(
    image: CIImage,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CIImage
```

---

## 10.2 UIImage 扩展是否提供

SDK 核心不建议依赖 UIKit。

但如果为了接入方便，可以单独提供可选扩展 Target：

```text
BeautyUIKitSupport
```

其中提供：

```swift
public extension BeautyEngine {
    func process(
        uiImage: UIImage,
        parameters: BeautyParameters
    ) throws -> UIImage
}
```

第一版建议：

```text
核心 SDK 不提供 UIImage API。
Demo App 自己做 UIImage <-> CIImage 转换。
```

原因：

```text
保持核心 SDK 干净。
避免实时链路误用 UIImage。
```

---

# 11. 实时相机接入 API

## 11.1 SDK 不创建 AVCaptureSession

SDK 不负责创建相机。

App 侧负责：

```text
AVCaptureSession
AVCaptureDeviceInput
AVCaptureVideoDataOutput
权限申请
前后摄像头切换
拍照按钮
录制按钮
```

SDK 只负责处理 App 传入的 `CVPixelBuffer`。

---

## 11.2 App 侧典型接入

第一版 SDK 固定优先支持 BGRA，App 侧相机输出必须显式设置：

```swift
videoOutput.videoSettings = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
]
videoOutput.alwaysDiscardsLateVideoFrames = true
```

```swift
final class CameraBeautyPipeline: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let engine: BeautyEngine
    private var parameters = BeautyParameters()

    init(engine: BeautyEngine) {
        self.engine = engine
    }

    func update(parameters: BeautyParameters) {
        self.parameters = parameters
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        do {
            let outputBuffer = try engine.process(
                pixelBuffer: pixelBuffer,
                orientation: .right,
                parameters: parameters
            )

            // App 侧负责把 outputBuffer 显示到 MetalPreviewView 或送入编码器
        } catch {
            // App 侧决定降级策略，例如显示原始帧
        }
    }
}
```

---

## 11.3 实时接入规则

```text
1. 不在主线程处理视频帧。
2. 不把 CMSampleBuffer 长时间持有。
3. 不在 captureOutput 中做 UIImage 转换。
4. parameters 更新要线程安全。
5. 处理失败时 App 可以显示原始帧。
6. 切换摄像头时调用 engine.reset()。
```

---

# 12. 输出结果设计

## 12.1 第一版直接返回输出对象

第一版 API 可以简单返回：

```swift
CVPixelBuffer
CIImage
```

优点：

```text
简单
易用
符合 MVP
```

---

## 12.2 后续可扩展 BeautyProcessingResult

为了返回更多信息，后续可以引入：

```swift
public struct BeautyProcessingResult<Output>: Sendable {
    public let output: Output
    public let faces: [BeautyFaceInfo]
    public let performance: BeautyPerformanceMetrics?
    public let warnings: [BeautyWarning]
}
```

### BeautyFaceInfo

对外可暴露脱敏后的简单人脸信息：

```swift
public struct BeautyFaceInfo: Sendable {
    public let boundingBox: CGRect
    public let confidence: Float
}
```

不建议对外暴露完整内部 landmarks，除非提供 Debug API。

---

# 13. 错误处理 API

## 13.1 BeautyError

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

---

## 13.2 错误处理建议

App 侧实时处理：

```swift
do {
    let output = try engine.process(
        pixelBuffer: pixelBuffer,
        orientation: orientation,
        parameters: parameters
    )
    display(output)
} catch {
    display(pixelBuffer) // 降级显示原始帧
}
```

图片处理：

```swift
do {
    let output = try engine.process(
        image: image,
        orientation: orientation,
        parameters: parameters
    )
    save(output)
} catch {
    showError(error)
}
```

---

# 14. 日志 API

## 14.1 BeautyLogLevel

```swift
public enum BeautyLogLevel: Int, Codable, Sendable {
    case none
    case error
    case warning
    case info
    case debug
}
```

## 14.2 配置方式

`BeautyConfiguration` includes `logLevel`; do not define a second configuration type only for logging.

默认：

```text
release：error
debug：warning 或 info
```

日志规则：

```text
不要输出用户隐私。
不要输出图片路径。
不要每帧输出大量日志。
性能日志必须可关闭。
```

## 14.3 统一 Logger

SDK 和 App Demo 使用同一套 logger 配置。第一版不暴露独立 SPM，只在 `BeautyCore/Diagnostics` 中提供默认实现。

```swift
public struct BeautyDiagnosticsConfiguration: Sendable {
    public var logLevel: BeautyLogLevel
    public var enableOSLog: Bool
    public var enableFileLog: Bool
    public var fileRetentionDays: Int
    public var maxFileSizeBytes: Int
}

public protocol BeautyLogSink: Sendable {
    func write(_ event: BeautyLogEvent)
}

public struct BeautyLogEvent: Sendable {
    public let timestamp: Date
    public let level: BeautyLogLevel
    public let category: String
    public let message: String
    public let errorCode: String?
    public let metadata: [String: String]
}
```

落盘规则：

```text
默认不写本地文件。
App 显式开启后，日志按日期写入本地 sandbox。
默认保留 7 天。
单文件默认最大 5 MB。
导出日志时必须先脱敏。
```

---

# 15. 性能统计 API

## 15.1 BeautyPerformanceMetrics

后续版本可以开放：

```swift
public struct BeautyPerformanceMetrics: Sendable {
    public let totalFrameTime: TimeInterval
    public let detectionTime: TimeInterval
    public let renderTime: TimeInterval
    public let faceCount: Int
    public let frameIndex: Int
}
```

## 15.2 获取方式

第一版建议通过 debug 回调或日志，不作为主 API 强依赖。

后续可提供：

```swift
public var performanceHandler: ((BeautyPerformanceMetrics) -> Void)?
```

或：

```swift
public func processWithResult(...) throws -> BeautyProcessingResult<CVPixelBuffer>
```

---

# 16. Debug API

## 16.1 Debug 能力

Debug 模式可以支持：

```text
返回人脸框
返回关键点
返回当前 FPS
返回各 Pass 耗时
输出中间纹理，仅内部工具
```

## 16.2 第一版建议

第一版不把完整 Debug API 公开给普通集成方。

可以提供内部开关：

```swift
public var enableDebugMode: Bool
```

App Demo 可以通过内部模块或 Debug Target 绘制 landmarks。

---

# 17. 线程与生命周期规范

## 17.1 BeautyEngine 生命周期

建议：

```text
相机页面创建一个 BeautyEngine。
图片编辑页面可以创建独立 BeautyEngine。
不要每帧创建 BeautyEngine。
页面销毁时释放 BeautyEngine。
切换输入源时 reset。
```

## 17.2 线程规则

```text
BeautyEngine 初始化可以在后台线程，也可以在页面准备阶段完成。
process(pixelBuffer:) 不应在主线程高频调用。
process(image:) 不应在主线程处理大图。
parameters 是值类型，更新时 App 侧需保证线程安全。
```

## 17.3 多实例规则

允许多个 `BeautyEngine` 实例，但不建议滥用。

场景：

```text
一个实时相机 engine
一个图片导出 engine
```

注意：

```text
多个实例会占用更多 Metal / texture / resource 资源。
```

---

# 18. Pixel Format 规范

## 18.1 推荐输入格式

实时相机优先支持：

```text
kCVPixelFormatType_32BGRA
```

后续可支持：

```text
kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
```

## 18.2 第一版建议

第一版优先支持：

```text
BGRA
```

原因：

```text
接入简单
Metal 处理直接
减少 YUV 转换复杂度
```

后续如果做直播 / 编码性能优化，再支持 YUV 管线。

---

# 19. API 使用完整示例

## 19.1 实时相机示例

```swift
import BeautySDK
import AVFoundation

let videoOutput = AVCaptureVideoDataOutput()
videoOutput.videoSettings = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
]
videoOutput.alwaysDiscardsLateVideoFrames = true

final class CameraBeautyPipeline: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let engine: BeautyEngine
    private let queue = DispatchQueue(label: "com.demo.beauty.camera")

    private var currentParameters = BeautyParameters(
        skinSmoothing: 0.25,
        skinWhitening: 0.15,
        skinRosy: 0.08,
        faceSlim: 0.12,
        eyeSize: 0.1,
        filterId: "clean_01",
        filterIntensity: 0.25
    )

    override init() {
        self.engine = try! BeautyEngine(configuration: .default)
        super.init()
    }

    func updateParameters(_ parameters: BeautyParameters) {
        queue.async {
            self.currentParameters = parameters
        }
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let parameters = currentParameters

        do {
            let processedBuffer = try engine.process(
                pixelBuffer: pixelBuffer,
                orientation: .right,
                parameters: parameters
            )

            // display processedBuffer
        } catch {
            // fallback: display original pixelBuffer
        }
    }
}
```

---

## 19.2 图片处理示例

```swift
import BeautySDK
import CoreImage

let engine = try BeautyEngine(
    configuration: BeautyConfiguration(renderQuality: .quality)
)

let parameters = BeautyParameters(
    skinSmoothing: 0.35,
    skinWhitening: 0.2,
    faceSlim: 0.15,
    eyeSize: 0.12,
    filterId: "clean_01",
    filterIntensity: 0.3
)

let outputImage = try engine.process(
    image: inputImage,
    orientation: .up,
    parameters: parameters
)
```

---

## 19.3 预设使用示例

```swift
let presetLoader = BeautyPresetLoader()
let presets = try presetLoader.loadBuiltInPresets()

if let preset = presets.first(where: { $0.id == "natural_01" }) {
    parameters = preset.parameters
}
```

---

# 20. 第一版 API 最小集合

## 20.1 必须公开

```text
BeautyEngine
BeautyConfiguration
BeautyRenderQuality
BeautyParameters
BeautyPreset
BeautyPresetLoader
BeautyError
BeautyLogLevel
```

## 20.2 暂不公开

```text
VisionFaceDetector
FaceWarpEffect
WarpControlPoint
RenderGraph
MetalContext
TextureCache
SkinSmoothEffect
LUTFilterEffect
CoordinateMapper
LandmarkSmoother
```

这些属于内部实现，不应该让 App 依赖。

---

# 21. API 稳定性规则

## 21.1 public API 修改规则

任何 public API 修改都必须记录到 CHANGELOG。

破坏性修改必须升级 major version。

## 21.2 参数新增规则

新增参数必须：

```text
默认值无效果
Codable 兼容旧 JSON
不改变旧 preset 效果
写入参数文档
增加测试
```

## 21.3 参数废弃规则

不直接删除。

使用：

```swift
@available(*, deprecated, message: "Use newParameter instead")
```

至少保留一个 major 版本。

---

# 22. 不推荐的 API 设计

## 22.1 不推荐每个功能一个方法

错误：

```swift
engine.setEyeSize(0.3)
engine.setFaceSlim(0.2)
engine.setNoseSlim(0.1)
engine.enableWhitening(true)
```

原因：

```text
状态分散
线程不安全
难保存
难做预设
难做回滚
难做测试
```

正确：

```swift
var parameters = BeautyParameters()
parameters.eyeSize = 0.3
parameters.faceSlim = 0.2

let output = try engine.process(
    pixelBuffer: pixelBuffer,
    orientation: orientation,
    parameters: parameters
)
```

---

## 22.2 不推荐 SDK 内持有 UI 状态

错误：

```swift
engine.currentCategory = .eyes
engine.selectedSlider = .eyeSize
engine.showBeforeAfter = true
```

正确：

```text
UI 状态由 App 持有。
SDK 只接收最终 BeautyParameters。
```

---

## 22.3 不推荐暴露内部 Metal 对象

错误：

```swift
engine.currentTexture
engine.commandBuffer
engine.renderGraph
```

正确：

```text
普通集成方只拿 CVPixelBuffer / CIImage 输出。
内部调试工具可以通过单独 Debug API 获取更多信息。
```

---

# 23. 后续 API 扩展规划

## 23.1 视频文件处理 API

未来版本可增加：

```swift
public final class BeautyVideoProcessor {

    public init(engine: BeautyEngine)

    public func export(
        inputURL: URL,
        outputURL: URL,
        parameters: BeautyParameters,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws

    public func cancel()
}
```

支持：

```text
AVAssetReader
AVAssetWriter
音频保留
方向保留
进度回调
取消导出
```

---

## 23.2 图片批处理 API

```swift
public final class BeautyBatchImageProcessor {

    public init(engine: BeautyEngine)

    public func process(
        images: [CIImage],
        parameters: BeautyParameters
    ) async throws -> [CIImage]
}
```

---

## 23.3 自定义资源 API

```swift
public final class BeautyResourceManager {
    public func registerLUT(id: String, url: URL) throws
    public func registerMakeupPackage(url: URL) throws
    public func unregisterResource(id: String)
}
```

---

## 23.4 Debug Result API

```swift
public func processWithResult(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> BeautyProcessingResult<CVPixelBuffer>
```

---

# 24. 第一版 API 验收标准

第一版 API 必须满足：

```text
1. App 只需要 import BeautySDK。
2. BeautyEngine 初始化简单。
3. 实时帧可以通过 process(pixelBuffer:) 处理。
4. 图片可以通过 process(image:) 处理。
5. 参数可以 Codable 保存和恢复。
6. 预设可以 JSON 加载。
7. 所有默认参数都是无效果。
8. 出错时有明确 BeautyError。
9. SDK 不暴露 UI。
10. SDK 不要求 App 理解 Metal 内部细节。
11. 切换输入源时可以 reset。
12. 未来视频导出和资源扩展有 API 空间。
```

---

# 25. 一句话结论

BeautySDK 对外 API 应该保持非常简单：

```text
创建 Engine
设置 Configuration
传入 Image / PixelBuffer
传入 BeautyParameters
得到处理结果
```

App 不应该知道 SDK 内部如何做人脸检测、如何做 Metal 渲染、如何生成 WarpControlPoint。

最终集成方最常用的代码应该只有这几行：

```swift
let engine = try BeautyEngine(configuration: .default)
let parameters = BeautyParameters(skinSmoothing: 0.3, faceSlim: 0.2, eyeSize: 0.15)
let output = try engine.process(pixelBuffer: input, orientation: .right, parameters: parameters)
```
