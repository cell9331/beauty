# Beauty SDK Metal Render Pipeline Design

## 1. 文档目标

本文档定义 BeautySDK 的 Metal 渲染管线设计。

目标：

```text
1. 跑通实时相机帧处理链路。
2. 避免 UIImage / CGImage 中转导致性能问题。
3. 统一管理 Metal 上下文、纹理、CommandBuffer、Render Pass。
4. 支持大眼、瘦脸、瘦鼻、嘴角等几何形变。
5. 支持磨皮、美白、红润、滤镜、妆容等图像效果。
6. 支持实时预览、图片处理、后续视频导出。
7. 保证高性能、可扩展、可测试、可降级。
```

核心原则：

```text
CVPixelBuffer → MTLTexture → Metal Passes → MTLTexture → CVPixelBuffer
```

实时链路禁止：

```text
CMSampleBuffer → UIImage → CIImage → CGImage → UIImage
```

---

# 2. 总体渲染链路

## 2.1 实时相机链路

```text
AVCaptureVideoDataOutput
        ↓
CMSampleBuffer
        ↓
CVPixelBuffer
        ↓
CVMetalTextureCache
        ↓
Input MTLTexture
        ↓
RenderGraph
        ↓
FaceWarpPass
        ↓
SkinPass
        ↓
MakeupPass，可选
        ↓
ColorPass
        ↓
LUTPass
        ↓
OutputPass
        ↓
Output CVPixelBuffer / MTLTexture
        ↓
Preview / Encode / Export
```

## 2.2 图片处理链路

```text
CIImage / CGImage / Image File
        ↓
App 或 SDK 转为 CVPixelBuffer / MTLTexture
        ↓
RenderGraph
        ↓
Effects
        ↓
Output MTLTexture / CIImage / CVPixelBuffer
        ↓
App 导出 JPEG / PNG / HEIF
```

第一版建议核心 SDK 优先统一到：

```text
CVPixelBuffer / MTLTexture
```

图片处理可以内部转成纹理后走同一套 RenderGraph。

## 2.3 视频导出链路，后续版本

```text
AVAssetReader
        ↓
CMSampleBuffer / CVPixelBuffer
        ↓
BeautyEngine.process(pixelBuffer:)
        ↓
Processed CVPixelBuffer
        ↓
AVAssetWriterInputPixelBufferAdaptor
        ↓
AVAssetWriter
```

要求：

```text
保留时间戳
保留音频轨
处理方向
支持取消
支持进度回调
```

---

# 3. 核心模块划分

Metal 渲染相关代码位于：

```text
Sources/BeautyRender/
```

推荐结构：

```text
BeautyRender/
├── MetalContext.swift
├── TextureCache.swift
├── PixelBufferPool.swift
├── RenderGraph.swift
├── RenderPass.swift
├── RenderTarget.swift
├── ShaderLibrary.swift
├── PipelineStateCache.swift
├── BufferPool.swift
└── Shaders/
    ├── Copy.metal
    ├── Warp.metal
    ├── Skin.metal
    ├── Color.metal
    ├── LUT.metal
    ├── Blend.metal
    └── Mask.metal
```

职责：

```text
MetalContext：管理 MTLDevice / MTLCommandQueue / CVMetalTextureCache / CIContext
TextureCache：CVPixelBuffer 和 MTLTexture 互转
PixelBufferPool：复用输出 CVPixelBuffer
RenderGraph：组织每一帧的渲染流程
RenderPass：单个渲染阶段抽象
RenderTarget：中间纹理封装
ShaderLibrary：加载 Metal shader
PipelineStateCache：缓存 pipeline state
BufferPool：复用 MTLBuffer
```

---

# 4. MetalContext 设计

## 4.1 职责

`MetalContext` 是整个渲染系统的底层依赖。

负责持有：

```text
MTLDevice
MTLCommandQueue
CVMetalTextureCache
CIContext，可选
MTLLibrary
```

## 4.2 API 示例

```swift
public final class MetalContext {

    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let textureCache: CVMetalTextureCache
    public let ciContext: CIContext
    public let shaderLibrary: ShaderLibrary

    public init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw BeautyError.metalUnavailable
        }

        guard let commandQueue = device.makeCommandQueue() else {
            throw BeautyError.commandQueueCreationFailed
        }

        var cache: CVMetalTextureCache?
        let status = CVMetalTextureCacheCreate(
            kCFAllocatorDefault,
            nil,
            device,
            nil,
            &cache
        )

        guard status == kCVReturnSuccess, let textureCache = cache else {
            throw BeautyError.textureCreationFailed
        }

        self.device = device
        self.commandQueue = commandQueue
        self.textureCache = textureCache
        self.ciContext = CIContext(mtlDevice: device)
        self.shaderLibrary = try ShaderLibrary(device: device)
    }
}
```

## 4.3 规范

必须：

```text
1. 一个 BeautyEngine 内复用同一个 MetalContext。
2. 不允许每帧创建 MTLDevice。
3. 不允许每帧创建 MTLCommandQueue。
4. 不允许每帧创建 CIContext。
5. textureCache 必须复用。
```

---

# 5. TextureCache 设计

## 5.1 职责

`TextureCache` 负责：

```text
CVPixelBuffer -> MTLTexture
MTLTexture -> CVPixelBuffer，配合 PixelBufferPool
创建中间 MTLTexture
管理纹理格式
处理纹理尺寸
```

## 5.2 CVPixelBuffer 转 MTLTexture

第一版优先支持：

```text
kCVPixelFormatType_32BGRA
```

Metal 格式：

```text
.bgra8Unorm
```

示例：

```swift
public final class TextureCache {

    private let context: MetalContext

    public init(context: MetalContext) {
        self.context = context
    }

    public func makeTexture(
        from pixelBuffer: CVPixelBuffer,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws -> MTLTexture {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        var cvTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            context.textureCache,
            pixelBuffer,
            nil,
            pixelFormat,
            width,
            height,
            0,
            &cvTexture
        )

        guard status == kCVReturnSuccess,
              let cvTexture,
              let texture = CVMetalTextureGetTexture(cvTexture) else {
            throw BeautyError.textureCreationFailed
        }

        return texture
    }
}
```

## 5.3 注意事项

```text
1. CVMetalTexture 必须在 MTLTexture 使用期间保持生命周期。
2. 如果只返回 MTLTexture，需要内部持有 CVMetalTexture 或设计 TextureWrapper。
3. 不同 pixel format 需要不同转换策略。
4. YUV 输入后续需要单独设计 Y / UV plane 纹理。
```

推荐封装：

```swift
public struct MetalTextureWrapper {
    public let texture: MTLTexture
    internal let cvTexture: CVMetalTexture?
}
```

---

# 6. PixelBufferPool 设计

## 6.1 职责

`PixelBufferPool` 用于复用输出 `CVPixelBuffer`。

避免每帧频繁创建 PixelBuffer。

## 6.2 输出格式

第一版输出：

```text
kCVPixelFormatType_32BGRA
```

要求：

```text
kCVPixelBufferMetalCompatibilityKey = true
kCVPixelBufferIOSurfacePropertiesKey = [:]
```

## 6.3 API 示例

```swift
public final class PixelBufferPool {

    private var pool: CVPixelBufferPool?
    private let width: Int
    private let height: Int
    private let pixelFormat: OSType

    public init(
        width: Int,
        height: Int,
        pixelFormat: OSType = kCVPixelFormatType_32BGRA,
        minimumBufferCount: Int = 3
    ) throws {
        self.width = width
        self.height = height
        self.pixelFormat = pixelFormat

        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        let poolAttributes: [String: Any] = [
            kCVPixelBufferPoolMinimumBufferCountKey as String: minimumBufferCount
        ]

        var pool: CVPixelBufferPool?
        let status = CVPixelBufferPoolCreate(
            kCFAllocatorDefault,
            poolAttributes as CFDictionary,
            attributes as CFDictionary,
            &pool
        )

        guard status == kCVReturnSuccess, let pool else {
            throw BeautyError.pixelBufferCreationFailed
        }

        self.pool = pool
    }

    public func makePixelBuffer() throws -> CVPixelBuffer {
        guard let pool else {
            throw BeautyError.pixelBufferCreationFailed
        }

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(
            kCFAllocatorDefault,
            pool,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }
}
```

## 6.4 Pool 重建策略

当输入尺寸变化时，需要重建 pool。

场景：

```text
切换前后摄像头
切换分辨率
横竖屏导致尺寸变化
处理图片尺寸变化
视频导出尺寸变化
```

---

# 7. RenderTarget 设计

## 7.1 职责

`RenderTarget` 封装一张中间纹理。

```swift
public struct RenderTarget {
    public let texture: MTLTexture
    public let width: Int
    public let height: Int
    public let pixelFormat: MTLPixelFormat
}
```

## 7.2 中间纹理创建

中间纹理 usage 必须包含：

```text
.shaderRead
.shaderWrite
.renderTarget，可选
```

如果使用 compute kernel：

```swift
descriptor.usage = [.shaderRead, .shaderWrite]
```

如果使用 render pipeline：

```swift
descriptor.usage = [.shaderRead, .renderTarget]
```

第一版建议几何和图像效果使用 compute pipeline 起步，接口更统一。

## 7.3 Ping-Pong 纹理

RenderGraph 使用两张中间纹理复用：

```text
inputTexture
    ↓ pass1
textureA
    ↓ pass2
textureB
    ↓ pass3
textureA
    ↓ pass4
textureB
```

优点：

```text
减少中间纹理数量
降低内存峰值
统一 Pass 调度
```

---

# 8. RenderPass 抽象

## 8.1 职责

一个 `RenderPass` 表示一个渲染阶段。

例如：

```text
CopyPass
FaceWarpPass
SkinPass
ColorPass
LUTPass
MakeupPass
OutputPass
```

## 8.2 协议设计

```swift
public protocol RenderPass {
    var name: String { get }

    func isEnabled(context: RenderContext) -> Bool

    func encode(
        input: MTLTexture,
        output: MTLTexture,
        context: RenderContext
    ) throws
}
```

## 8.3 RenderContext

```swift
public struct RenderContext {
    public let metalContext: MetalContext
    public let commandBuffer: MTLCommandBuffer
    public let parameters: BeautyParameters
    public let faces: [BeautyFaceObservation]
    public let inputSize: CGSize
    public let outputSize: CGSize
    public let frameIndex: Int
    public let timestamp: CMTime?
}
```

## 8.4 Pass 规范

每个 Pass 必须满足：

```text
1. intensity 为 0 时不产生副作用。
2. isEnabled 返回 false 时 RenderGraph 跳过该 Pass。
3. 不允许在 Pass 内 commit commandBuffer。
4. 不允许在 Pass 内 waitUntilCompleted。
5. 不允许在 Pass 内创建新的 MTLDevice / CommandQueue。
6. PipelineState 必须缓存。
```

---

# 9. RenderGraph 设计

## 9.1 职责

`RenderGraph` 负责组织一帧图像的所有 Pass。

职责：

```text
1. 按顺序执行 Pass。
2. 管理 ping-pong 中间纹理。
3. 跳过未启用 Pass。
4. 管理 CommandBuffer 生命周期。
5. 输出最终纹理或 PixelBuffer。
6. 记录性能数据。
```

## 9.2 第一版 Pass 顺序

```text
1. FaceWarpPass
2. SkinPass
3. ColorPass
4. LUTPass
5. OutputPass / CopyPass
```

## 9.3 后续完整 Pass 顺序

```text
1. InputNormalizePass，可选
2. FaceWarpPass
3. SkinPass
4. MakeupPass
5. BackgroundPass，可选
6. ColorPass
7. LUTPass
8. SharpenPass，可合并
9. OutputPass
```

## 9.4 API 示例

```swift
public final class RenderGraph {

    private let passes: [RenderPass]
    private let texturePool: TexturePool

    public init(
        passes: [RenderPass],
        texturePool: TexturePool
    ) {
        self.passes = passes
        self.texturePool = texturePool
    }

    public func render(
        inputTexture: MTLTexture,
        outputTexture: MTLTexture,
        context: RenderContext
    ) throws {
        var readTexture = inputTexture
        var writeTextureA = try texturePool.makeTexture(
            width: inputTexture.width,
            height: inputTexture.height,
            pixelFormat: inputTexture.pixelFormat
        )
        var writeTextureB = try texturePool.makeTexture(
            width: inputTexture.width,
            height: inputTexture.height,
            pixelFormat: inputTexture.pixelFormat
        )

        var useA = true
        var executedPassCount = 0

        for pass in passes {
            guard pass.isEnabled(context: context) else {
                continue
            }

            let isLastEnabledPass = false // 实际实现需要提前计算
            let writeTexture = isLastEnabledPass
                ? outputTexture
                : (useA ? writeTextureA : writeTextureB)

            try pass.encode(
                input: readTexture,
                output: writeTexture,
                context: context
            )

            readTexture = writeTexture
            useA.toggle()
            executedPassCount += 1
        }

        if executedPassCount == 0 || readTexture !== outputTexture {
            // 如果没有 Pass 或最终结果不在 outputTexture，需要 copy
        }
    }
}
```

## 9.5 实现注意

实际实现时需要先计算 enabledPasses：

```swift
let enabledPasses = passes.filter { $0.isEnabled(context: context) }
```

这样可以知道最后一个 Pass，直接写到 outputTexture，减少一次 copy。

---

# 10. CommandBuffer 管线规范

## 10.1 每帧一个 CommandBuffer

推荐：

```text
每一帧创建一个 MTLCommandBuffer
所有 Pass encode 到同一个 CommandBuffer
最后统一 commit
```

禁止：

```text
每个 Pass 单独 commit
每个功能单独 commandBuffer
实时链路频繁 waitUntilCompleted
```

## 10.2 示例

```swift
let commandBuffer = context.commandQueue.makeCommandBuffer()

let renderContext = RenderContext(
    metalContext: context,
    commandBuffer: commandBuffer,
    parameters: parameters,
    faces: faces,
    inputSize: inputSize,
    outputSize: outputSize,
    frameIndex: frameIndex,
    timestamp: timestamp
)

try renderGraph.render(
    inputTexture: inputTexture,
    outputTexture: outputTexture,
    context: renderContext
)

commandBuffer.commit()
```

## 10.3 同步策略

实时预览：

```text
尽量异步 commit。
避免 waitUntilCompleted。
```

图片导出：

```text
可以在必要时 waitUntilCompleted。
```

视频导出：

```text
根据编码器需求控制同步。
避免无限制排队导致内存上涨。
```

---

# 11. Compute Pipeline 与 Render Pipeline 选择

## 11.1 Compute Pipeline 适合

```text
滤镜
颜色调整
LUT
磨皮
mask 处理
局部形变，第一版可用 compute 实现
```

优点：

```text
输入输出纹理明确
便于多 Pass
便于控制线程组
不用处理 vertex / fragment pipeline
```

## 11.2 Render Pipeline 适合

```text
mesh warp
妆容贴图变形
AR 贴纸
背景图合成
最终显示
```

## 11.3 第一版建议

第一版优先：

```text
Compute Pipeline 为主
必要时 Output / Preview 使用 Render Pipeline
```

几何形变第一版可以用 compute displacement warp。

后续如果需要更高质量的人脸 mesh warp，再引入 render pipeline + triangle mesh。

---

# 12. FaceWarpPass 设计

## 12.1 职责

`FaceWarpPass` 统一处理所有几何形变。

包括：

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

## 12.2 输入

```text
inputTexture
faces
BeautyParameters
WarpControlPointProviders
```

## 12.3 输出

```text
warpedTexture
```

## 12.4 控制点生成流程

```text
BeautyParameters
        ↓
EyeWarpProvider
NoseWarpProvider
MouthWarpProvider
ChinWarpProvider
FaceShapeWarpProvider
        ↓
[WarpControlPoint]
        ↓
Upload to MTLBuffer
        ↓
Warp.metal
```

## 12.5 CPU 侧结构

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
```

GPU 侧结构：

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

## 12.6 Shader 逻辑概念

对每个输出像素：

```text
1. 当前输出位置 p。
2. 遍历 control points。
3. 计算 p 到 controlPoint.source 的距离 d。
4. 如果 d < radius，计算权重 w。
5. 根据 source -> target 计算反向采样偏移。
6. 从 inputTexture 的变换后坐标采样。
7. 写入 outputTexture。
```

概念公式：

```text
offset = (target - source) * weight * strength
samplePosition = p - offset
```

注意使用反向采样，避免空洞。

## 12.7 强度限制

`FaceWarpPass` 内部必须对每类参数做安全映射：

```text
faceSlim 最大实际强度：0.6
eyeSize 最大实际强度：0.45
noseSlim 最大实际强度：0.35
smile 最大实际强度：0.5
```

不要直接把 UI 强度线性作为最终位移。

---

# 13. SkinPass 设计

## 13.1 职责

`SkinPass` 处理基础皮肤美颜。

第一版包括：

```text
磨皮
美白
红润
```

## 13.2 输入

```text
warpedTexture
BeautyParameters.skinSmoothing
BeautyParameters.skinWhitening
BeautyParameters.skinRosy
```

## 13.3 输出

```text
skinProcessedTexture
```

## 13.4 第一版算法策略

```text
1. 对图像做边缘保护平滑。
2. 根据 skinSmoothing 混合原图和平滑图。
3. 根据 skinWhitening 做肤色亮度提升。
4. 根据 skinRosy 做轻微红润处理。
```

第一版如果没有 skin mask，需要保守处理。

后续升级：

```text
skin mask
feature protection mask
bilateral filter
guided filter
frequency separation
```

## 13.5 Pass 拆分建议

为了性能，第一版可以简化：

```text
SkinSmoothPass
SkinColorPass
```

或合并：

```text
SkinPass
```

如果磨皮需要多次采样，可能必须多 Pass：

```text
BlurHorizontal
BlurVertical
BlendSkin
```

但对外仍然由 `SkinPass` 或 `SkinEffect` 管理，不让 RenderGraph 变得过碎。

---

# 14. ColorPass 设计

## 14.1 职责

`ColorPass` 处理基础颜色调整。

第一版：

```text
清晰 / 锐化
亮度，可选
对比度，可选
饱和度，可选
色温，可选
```

MVP 必做：

```text
skinSharpen
```

## 14.2 设计原则

所有简单颜色调整应尽量合并在一个 shader 中。

禁止：

```text
BrightnessPass
ContrastPass
SaturationPass
TemperaturePass
```

正确：

```text
ColorAdjustmentPass
```

## 14.3 Uniform 示例

```metal
struct ColorUniforms {
    float brightness;
    float contrast;
    float saturation;
    float temperature;
    float tint;
    float sharpen;
};
```

---

# 15. LUTPass 设计

## 15.1 职责

`LUTPass` 处理滤镜。

输入：

```text
inputTexture
lutTexture
filterIntensity
```

输出：

```text
filteredTexture
```

## 15.2 规则

```text
filterId == nil：跳过 LUTPass。
filterIntensity == 0：跳过 LUTPass 或直接 copy。
filterId 找不到：降级为无滤镜或抛出资源错误。
```

## 15.3 混合公式

```text
output = mix(original, filtered, filterIntensity)
```

## 15.4 LUT 资源

第一版支持：

```text
.cube -> 3D LUT Texture
```

也可以用 Core Image `CIColorCube` 作为图片处理路径，但实时 Metal 管线建议使用 Metal 3D Texture。

---

# 16. MakeupPass 设计，后续版本

## 16.1 职责

`MakeupPass` 处理妆容贴合与融合。

包括：

```text
口红
腮红
眼影
眼线
眉毛
修容
高光
眼神光
```

## 16.2 依赖

```text
人脸关键点
局部 mask
妆容资源 texture
blend mode
```

## 16.3 设计原则

```text
不要把每个妆容都做成独立完整 pass。
按资源和 blend mode 合理合并。
口红可以独立 pass。
腮红 / 修容 / 高光可合并。
眼妆根据复杂度决定。
```

---

# 17. OutputPass 设计

## 17.1 职责

`OutputPass` 负责把最终纹理写入输出纹理或输出 PixelBuffer 关联纹理。

## 17.2 输出目标

实时预览可能需要：

```text
MTLTexture -> MTKView Drawable
```

SDK API 返回可能需要：

```text
MTLTexture -> CVPixelBuffer-backed MTLTexture
```

图片处理可能需要：

```text
MTLTexture -> CIImage / CGImage / Data
```

第一版 SDK 标准输出：

```text
CVPixelBuffer
```

## 17.3 Copy Pass

如果最终 Pass 没有直接写入 outputTexture，需要使用 `CopyPass`。

CopyPass 应尽量轻量。

---

# 18. ShaderLibrary 与 PipelineStateCache

## 18.1 ShaderLibrary

负责加载 `.metal` 函数。

```swift
public final class ShaderLibrary {

    private let library: MTLLibrary

    public init(device: MTLDevice) throws {
        let bundle = Bundle.module
        self.library = try device.makeDefaultLibrary(bundle: bundle)
    }

    public func function(named name: String) throws -> MTLFunction {
        guard let function = library.makeFunction(name: name) else {
            throw BeautyError.shaderFunctionNotFound(name)
        }
        return function
    }
}
```

## 18.2 PipelineStateCache

PipelineState 必须缓存。

禁止：

```text
每帧 makeComputePipelineState
每帧 makeRenderPipelineState
```

示例：

```swift
public final class PipelineStateCache {

    private let device: MTLDevice
    private var computeStates: [String: MTLComputePipelineState] = [:]
    private let lock = NSLock()

    public init(device: MTLDevice) {
        self.device = device
    }

    public func computeState(
        functionName: String,
        library: ShaderLibrary
    ) throws -> MTLComputePipelineState {
        lock.lock()
        defer { lock.unlock() }

        if let state = computeStates[functionName] {
            return state
        }

        let function = try library.function(named: functionName)
        let state = try device.makeComputePipelineState(function: function)
        computeStates[functionName] = state
        return state
    }
}
```

---

# 19. Buffer 管理规范

## 19.1 Uniform Buffer

每帧需要传递：

```text
BeautyParameters uniforms
image size
face count
warp point count
LUT info
```

建议：

```text
每帧创建少量 uniform buffer 可以接受。
高频小 buffer 建议使用 BufferPool 或 ring buffer。
```

## 19.2 WarpControlPoint Buffer

所有控制点合并到一个 Buffer。

```text
[WarpControlPointGPU]
```

禁止：

```text
每个五官一个 buffer
每个点一个 buffer
```

## 19.3 Triple Buffering

为了避免 CPU 写入 GPU 正在读取的 buffer，后续可以使用：

```text
triple buffering
```

第一版可以先简单实现，性能优化阶段再升级。

---

# 20. 坐标与纹理方向规范

## 20.1 坐标系统

Metal 纹理采样通常使用：

```text
texture coordinate: 0...1
pixel coordinate: 0...width / 0...height
```

Vision 关键点需要经过 `CoordinateMapper` 转换成纹理坐标。

## 20.2 统一要求

进入 `FaceWarpPass` 的 landmarks 必须已经是：

```text
texture normalized coordinates
x: 0...1
y: 0...1
方向与 inputTexture 一致
```

`FaceWarpPass` 不应该再处理 Vision 坐标。

## 20.3 前置摄像头镜像

镜像必须在检测坐标映射阶段处理清楚。

禁止在多个地方重复 mirror。

建议策略：

```text
Detection 输出统一坐标
Render 只消费统一坐标
Preview 决定显示是否镜像
Export 决定导出是否镜像
```

---

# 21. Pixel Format 设计

## 21.1 第一版支持

```text
Input:  kCVPixelFormatType_32BGRA
Metal:  .bgra8Unorm
Output: kCVPixelFormatType_32BGRA
```

## 21.2 后续支持

```text
YUV 420 Full Range
YUV 420 Video Range
10-bit HDR，可选
```

## 21.3 YUV 支持策略，后续

YUV 输入需要：

```text
Y plane texture
UV plane texture
YUV -> RGB conversion pass
RGB processing
RGB -> YUV，可选，如果编码器需要
```

第一版不建议直接做 YUV 全链路，先稳定 BGRA。

---

# 22. 实时预览输出策略

## 22.1 SDK 返回 CVPixelBuffer

标准 API：

```swift
let output = try engine.process(pixelBuffer: input, orientation: .right, parameters: parameters)
```

优点：

```text
通用
可预览
可编码
可导出
与 AVFoundation 兼容
```

## 22.2 App 显示策略

App 可以：

```text
CVPixelBuffer -> MTLTexture -> MTKView
```

也可以让 SDK 后续提供可选 Preview Renderer。

第一版建议：

```text
SDK 只返回 CVPixelBuffer。
Demo App 自己显示。
```

## 22.3 低延迟优化，后续

为了降低延迟，可以支持：

```text
processToTexture
processToDrawable
```

但第一版不建议暴露，避免 API 复杂。

---

# 23. 同步与异步设计

## 23.1 第一版同步 API

第一版对外 API 是同步返回：

```swift
func process(...) throws -> CVPixelBuffer
```

这意味着返回时 outputBuffer 必须已经可读，但不意味着实时链路可以无条件每帧阻塞等待 GPU。

实时链路中如果使用同步 API，必须满足：

```text
运行在非主线程的相机处理队列。
限制 in-flight frame 数量。
超过帧预算时丢帧或返回原始帧。
不要在每个 Pass 内等待。
不要把 waitUntilCompleted 作为长期实时实现。
```

## 23.2 异步优化方向

后续可以提供：

```swift
func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters,
    completion: @escaping (Result<CVPixelBuffer, Error>) -> Void
)
```

或：

```swift
func processAsync(...) async throws -> CVPixelBuffer
```

## 23.3 建议

第一版为了 API 简洁，可以保留同步 API。

同步 API 的定位：

```text
图片处理。
离线视频帧处理。
调试和最小闭环验证。
由 App 明确放到后台队列的实时预览处理。
```

但内部架构要预留异步：

```text
CommandBuffer completion handler
output buffer 生命周期管理
frame dropping
in-flight frame limit
```

---

# 24. In-flight Frame 控制

## 24.1 问题

如果实时相机帧不断进入，但 GPU 处理不过来，会出现：

```text
延迟增加
内存上涨
纹理堆积
预览滞后
```

## 24.2 策略

需要限制最大 in-flight frame：

```text
maximumInFlightFrames = 2 或 3
```

超过后：

```text
丢弃新帧
或者返回原始帧
或者复用上一帧结果
```

## 24.3 第一版建议

App 侧 AVCaptureVideoDataOutput 设置：

```swift
videoOutput.videoSettings = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
]
videoOutput.alwaysDiscardsLateVideoFrames = true
```

SDK 内部后续增加：

```text
InFlightFrameLimiter
```

---

# 25. 性能目标

## 25.1 实时目标

```text
720p：稳定 30fps
1080p：中高端设备稳定 30fps
4K：不作为实时预览目标
```

## 25.2 Pass 耗时目标，参考

```text
FaceWarpPass：1.0 ~ 3.0 ms
SkinPass：2.0 ~ 6.0 ms
ColorPass：0.3 ~ 1.0 ms
LUTPass：0.5 ~ 1.5 ms
Total Render：5 ~ 12 ms
Detection：异步，10~15fps
```

实际以设备为准。

## 25.3 优化方向

```text
减少 Pass 数量
降低检测频率
降低处理分辨率
复用纹理
复用 buffer
合并颜色 shader
限制最大人脸数
低端设备关闭高级效果
```

---

# 26. 性能统计设计

## 26.1 指标

需要统计：

```text
totalFrameTime
renderTime
detectionTime
faceWarpTime
skinTime
colorTime
lutTime
outputTime
faceCount
inputResolution
outputResolution
frameIndex
```

## 26.2 实现方式

第一版可以用 CPU 时间粗略统计。

后续可以用：

```text
GPU timestamp
MTLCounterSampleBuffer，可选
```

## 26.3 对外策略

普通集成方不一定需要看到全部指标。

Debug 模式可通过：

```text
日志
PerformanceOverlay
performanceHandler
```

---

# 27. 内存管理规范

## 27.1 必须复用

```text
MTLDevice
MTLCommandQueue
CIContext
CVMetalTextureCache
PipelineState
LUT Texture
Makeup Texture
Intermediate Texture
CVPixelBufferPool
MTLBuffer，可优化
```

## 27.2 禁止

```text
每帧创建大量纹理
每帧解析 LUT
每帧加载 PNG
每帧创建 CIContext
每帧创建 PipelineState
实时链路 UIImage 转换
无上限缓存资源
```

## 27.3 内存峰值控制

策略：

```text
使用 ping-pong texture
按需创建 texture pool
页面退出释放大资源
低端设备降低分辨率
多人脸限制最大数量
```

---

# 28. RenderGraph 第一版实现路线

## 28.1 第一步：CopyRenderPass

目标：

```text
输入纹理原样输出
```

验收：

```text
相机帧经过 SDK 后显示正常
颜色不变
方向不乱
无明显延迟
```

## 28.2 第二步：ColorPass

目标：

```text
实现亮度 / 对比度 / 饱和度 / 锐化基础能力
```

验收：

```text
滑杆调节实时生效
参数为 0 时输出等于原图
```

## 28.3 第三步：LUTPass

目标：

```text
实现滤镜 LUT
支持 filterIntensity
```

验收：

```text
filterIntensity 0 = 原图
filterIntensity 1 = 完整滤镜
LUT 不重复加载
```

## 28.4 第四步：FaceWarpPass

目标：

```text
实现大眼和瘦脸
```

验收：

```text
大眼和瘦脸共用一个 Pass
形变平滑
背景拉伸可控
```

## 28.5 第五步：SkinPass

目标：

```text
磨皮、美白、红润
```

验收：

```text
效果自然
不过曝
不塑料脸
```

---

# 29. 第一版 RenderGraph 配置

```swift
let renderGraph = RenderGraph(passes: [
    FaceWarpPass(providers: [
        EyeWarpProvider(),
        FaceShapeWarpProvider(),
        ChinWarpProvider(),
        NoseWarpProvider(),
        MouthWarpProvider()
    ]),
    SkinPass(),
    ColorPass(),
    LUTPass(),
    CopyPass()
])
```

注意：

```text
CopyPass 不一定总执行。
如果最后一个有效 Pass 已经写入 outputTexture，则跳过 CopyPass。
```

---

# 30. 错误处理

## 30.1 可能错误

```text
Metal 不可用
CommandBuffer 创建失败
纹理创建失败
输出 PixelBuffer 创建失败
Shader 找不到
PipelineState 创建失败
LUT 资源不存在
Unsupported pixel format
```

## 30.2 处理策略

实时链路：

```text
出错时 App 可以显示原始帧。
SDK 返回明确 BeautyError。
不要 crash。
```

图片处理：

```text
抛出错误给 App。
App 显示失败原因。
```

内部开发错误：

```text
Debug 断言。
Release 返回错误。
```

---

# 31. 测试策略

## 31.1 CopyPass 测试

```text
输入输出尺寸一致
输入输出颜色接近一致
不同分辨率正常
前后摄像头方向正常
```

## 31.2 ColorPass 测试

```text
参数为 0 输出不变
亮度调整正确
饱和度调整正确
锐化不崩溃
```

## 31.3 LUTPass 测试

```text
filterId nil 输出不变
filterIntensity 0 输出不变
filterIntensity 1 输出完整 LUT
LUT 文件解析失败有错误
```

## 31.4 FaceWarpPass 测试

```text
没有人脸时输出不变
参数为 0 输出不变
大眼可见
瘦脸可见
多 control points 不崩溃
强度过高有 clamp
```

## 31.5 性能测试

```text
720p 30fps
1080p 30fps，中高端设备
连续运行 10 分钟
内存无持续上涨
切换摄像头后恢复正常
```

---

# 32. 与 BeautyEngine 的关系

`BeautyEngine` 调用流程：

```text
process(pixelBuffer:)
        ↓
参数归一化
        ↓
检测调度，异步或降频
        ↓
获取最近稳定 faces
        ↓
input pixelBuffer -> inputTexture
        ↓
创建 output pixelBuffer
        ↓
output pixelBuffer -> outputTexture
        ↓
RenderGraph.render
        ↓
commandBuffer commit / sync if needed
        ↓
返回 output pixelBuffer
```

伪代码：

```swift
public func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CVPixelBuffer {
    let normalized = parameterNormalizer.normalize(parameters)

    let faces = try detectionScheduler.currentFaces(
        pixelBuffer: pixelBuffer,
        orientation: orientation
    )

    let inputTexture = try textureCache.makeTexture(from: pixelBuffer).texture
    let outputPixelBuffer = try pixelBufferPool.makePixelBuffer(
        matching: pixelBuffer
    )
    let outputTexture = try textureCache.makeTexture(from: outputPixelBuffer).texture

    guard let commandBuffer = metalContext.commandQueue.makeCommandBuffer() else {
        throw BeautyError.renderFailed("Failed to create command buffer")
    }

    let renderContext = RenderContext(
        metalContext: metalContext,
        commandBuffer: commandBuffer,
        parameters: normalized,
        faces: faces,
        inputSize: CGSize(width: inputTexture.width, height: inputTexture.height),
        outputSize: CGSize(width: outputTexture.width, height: outputTexture.height),
        frameIndex: frameIndex,
        timestamp: nil
    )

    try renderGraph.render(
        inputTexture: inputTexture,
        outputTexture: outputTexture,
        context: renderContext
    )

    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()

    return outputPixelBuffer
}
```

注意：

```text
上面 waitUntilCompleted 只表示最小闭环同步示例。
实时高频路径必须改为 completion handler、shared event、in-flight 控制或明确的丢帧策略。
```

---

# 33. 第一版同步 API 的风险与解决

## 33.1 风险

```text
waitUntilCompleted 会阻塞调用线程。
如果在 capture queue 中耗时过长，会掉帧。
```

## 33.2 初期可接受原因

```text
离线图片和调试路径 API 简单。
开发早期容易跑通架构。
实时路径已明确要求非主线程、in-flight 限制和丢帧策略。
```

## 33.3 后续优化

```text
processAsync
CommandBuffer completionHandler
输出 buffer 生命周期池
in-flight frame limiter
preview 直接输出 drawable
```

---

# 34. 设备降级策略

## 34.1 performance 模式

```text
处理尺寸降低到 720p
检测间隔 3~5 帧
最大人脸 1
关闭高级磨皮
关闭妆容
关闭背景分割
```

## 34.2 balanced 模式

```text
默认 720p / 1080p
检测间隔 3 帧
最大人脸 1~3
基础磨皮
基础五官
LUT
```

## 34.3 quality 模式

```text
更高分辨率
检测间隔 1~2 帧
高级磨皮
更复杂效果
适合图片和导出
```

---

# 35. 关键开发原则

```text
1. 所有 Pass 必须可跳过。
2. 所有 PipelineState 必须缓存。
3. 所有纹理尽量复用。
4. 所有几何形变合并到 FaceWarpPass。
5. 所有简单颜色调整合并到 ColorPass。
6. 实时链路不使用 UIImage。
7. 检测和渲染解耦。
8. 不在 Pass 内 commit commandBuffer。
9. 不在实时链路频繁 waitUntilCompleted。
10. 输出格式第一版固定 BGRA，后续再支持 YUV。
```

---

# 36. 一句话结论

Metal 渲染管线的核心不是“写很多滤镜”，而是建立一个稳定、高性能、可组合的实时图像处理流水线。

第一版必须先跑通：

```text
CVPixelBuffer
→ MTLTexture
→ RenderGraph
→ CopyPass / ColorPass / LUTPass
→ CVPixelBuffer
```

然后再逐步加入：

```text
FaceWarpPass
SkinPass
MakeupPass
BackgroundPass
Video Export
```

只要 `MetalContext + TextureCache + PixelBufferPool + RenderGraph` 稳定，后面的美颜效果都可以作为 Pass 或 Provider 持续扩展。
