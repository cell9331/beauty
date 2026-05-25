# 08. iOS Beauty SDK Metal Rendering Pipeline Design

iOS Beauty SDK Metal Rendering Pipeline Design Document

1. Documentation goals

This document defines the Metal rendering pipeline design of BeautySDK.

Goal:

1. Run through the real-time camera frame processing link.
2. Avoid performance problems caused by UIImage / CGImage transfer.
3. Unified management of Metal context, texture, CommandBuffer, and Render Pass.
4. Supports geometric deformations such as big eyes, face slimming, nose slimming, mouth corners, etc.
5. Supports image effects such as skin resurfacing, whitening, rosy, filters, makeup, etc.
6. Support real-time preview, image processing, and subsequent video export.
7. Ensure high performance, scalability, testability, and downgradeability.

Core principles:

CVPixelBuffer → MTLTexture → Metal Passes → MTLTexture → CVPixelBuffer

Live link ban:

CMSampleBuffer → UIImage → CIImage → CGImage → UIImage

⸻

2. Overall rendering link

2.1 Live camera link

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
MakeupPass, optional
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

2.2 Image processing link

CIImage / CGImage / Image File
        ↓
App or SDK converted to CVPixelBuffer / MTLTexture
        ↓
RenderGraph
        ↓
Effects
        ↓
Output MTLTexture / CIImage / CVPixelBuffer
        ↓
App export JPEG / PNG / HEIF

The first version recommends that the core SDK be unified to:

CVPixelBuffer / MTLTexture

Image processing can be converted into texture internally and then run through the same RenderGraph.

2.3 Video export link, subsequent versions

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

Requirements:

Keep timestamp
Keep audio track
processing direction
Support cancellation
Support progress callback

⸻

3. Division of core modules

Metal rendering related code is located at:

Sources/BeautyRender/

Recommended structure:

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
    ├── Copy.Metal
    ├── Warp.Metal
    ├── Skin.Metal
    ├── Color.Metal
    ├── LUT.Metal
    ├── Blend.Metal
    └── Mask.Metal

Responsibilities:

MetalContext: Manage MTLDevice/MTLCommandQueue/CVMetalTextureCache/CIContext
TextureCache: CVPixelBuffer and MTLTexture conversion
PixelBufferPool: multiplexed output CVPixelBuffer
RenderGraph: organizes the rendering process of each frame
RenderPass: Single render pass abstraction
RenderTarget: intermediate texture encapsulation
ShaderLibrary: Load Metal shader
PipelineStateCache: cache pipeline state
BufferPool: reuse MTLBuffer

⸻

4. MetalContext design

4.1 Responsibilities

MetalContext is the underlying dependency of the entire rendering system.

Responsible for holding:

MTLDevice
MTLCommandQueue
CVMetalTextureCache
CIContext, optional
MTLLibrary

4.2 API examples

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

4.3 Specifications

Must:

1. Reuse the same MetalContext within a BeautyEngine.
2. MTLDevice creation per frame is not allowed.
3. Do not allow creation of MTLCommandQueue per frame.
4. CIContext creation per frame is not allowed.
5. textureCache must be reused.

⸻

5. TextureCache design

5.1 Responsibilities

TextureCache is responsible for:

CVPixelBuffer -> MTLTexture
MTLTexture -> CVPixelBuffer, with PixelBufferPool
Create intermediate MTLTexture
Manage texture formats
Handling texture dimensions

5.2 CVPixelBuffer to MTLTexture

The first version gives priority to support:

kCVPixelFormatType_32BGRA

Metal format:

.bgra8Unorm

Example:

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

5.3 Precautions

1. CVMetalTexture must maintain lifecycle during use of MTLTexture.
2. If you only return MTLTexture, you need to hold CVMetalTexture internally or design TextureWrapper.
3. Different pixel formats require different conversion strategies.
4. After YUV input, the Y / UV plane texture needs to be designed separately.

Recommended package:

public struct MetalTextureWrapper {
    public let texture: MTLTexture
    internal let cvTexture: CVMetalTexture?
}

⸻

6. PixelBufferPool design

6.1 Responsibilities

PixelBufferPool is used to multiplex output CVPixelBuffer.

Avoid creating PixelBuffer frequently every frame.

6.2 Output format

First version output:

kCVPixelFormatType_32BGRA

Requirements:

kCVPixelBufferMetalCompatibilityKey = true
kCVPixelBufferIOSurfacePropertiesKey = [:]

6.3 API examples

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

6.4 Pool reconstruction strategy

When the input size changes, the pool needs to be rebuilt.

Scenario:

Switch front and rear cameras
Switch resolution
Horizontal and vertical screens cause size changes
Handling image size changes
Video export size changes

⸻

7. RenderTarget design

7.1 Responsibilities

RenderTarget encapsulates an intermediate texture.

public struct RenderTarget {
    public let texture: MTLTexture
    public let width: Int
    public let height: Int
    public let pixelFormat: MTLPixelFormat
}

7.2 Intermediate texture creation

Intermediate texture usage must contain:

.shaderRead
.shaderWrite
.renderTarget, optional

If using compute kernel:

descriptor.usage = [.shaderRead, .shaderWrite]

If using render pipeline:

descriptor.usage = [.shaderRead, .renderTarget]

The first version recommends starting with the compute pipeline for geometry and image effects, with a more unified interface.

7.3 Ping-Pong texture

RenderGraph uses two intermediate texture reuses:

inputTexture
    ↓ pass1
textureA
    ↓ pass2
textureB
    ↓ pass3
textureA
    ↓ pass4
textureB

Advantages:

Reduce the number of intermediate textures
Reduce memory peaks
Unified Pass Scheduling

⸻

8. RenderPass abstraction

8.1 Responsibilities

A RenderPass represents a rendering pass.

For example:

CopyPass
FaceWarpPass
SkinPass
ColorPass
LUTPass
MakeupPass
OutputPass

8.2 Protocol design

public protocol RenderPass {
    var name: String { get }
    func isEnabled(context: RenderContext) -> Bool
    func encode(
        input: MTLTexture,
        output: MTLTexture,
        context: RenderContext
    ) throws
}

8.3 RenderContext

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

8.4 Pass specifications

Each Pass must meet:

1. When intensity is 0, no side effects occur.
2. RenderGraph skips the Pass when isEnabled returns false.
3. Commit commandBuffer is not allowed in Pass.
4. WaitUntilCompleted is not allowed in Pass.
5. It is not allowed to create new MTLDevice / CommandQueue in Pass.
6. PipelineState must be cached.

⸻

9. RenderGraph design

9.1 Responsibilities

RenderGraph is responsible for organizing all passes of a frame of image.

Responsibilities:

1. Execute Pass in sequence.
2. Manage ping-pong intermediate textures.
3. Skip the Pass that is not enabled.
4. Manage the CommandBuffer life cycle.
5. Output the final texture or PixelBuffer.
6. Record performance data.

9.2 First Edition Pass Order

1. FaceWarpPass
2. SkinPass
3. ColorPass
4. LUTPass
5. OutputPass / CopyPass

9.3 Subsequent complete Pass sequence

1. InputNormalizePass, optional
2. FaceWarpPass
3. SkinPass
4. MakeupPass
5. BackgroundPass, optional
6. ColorPass
7. LUTPass
8. SharpenPass, can be merged
9. OutputPass

9.4 API examples

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
            let isLastEnabledPass = false // Actual implementation needs to be calculated in advance
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
            // If there is no Pass or the final result is not in the outputTexture, copy is required
        }
    }
}

9.5 Implementation Notes

In actual implementation, enabledPasses need to be calculated first:

let enabledPasses = passes.filter { $0.isEnabled(context: context) }

In this way, you can know the last Pass and write it directly to the outputTexture, reducing one copy.

⸻

10. CommandBuffer pipeline specification

10.1 One CommandBuffer per frame

Recommended:

Create an MTLCommandBuffer every frame
All Pass encode to the same CommandBuffer
Finally unified commit

Prohibited:

Commit each Pass individually
Separate commandBuffer for each function
Real-time link frequently waitUntilCompleted

10.2 Example

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

10.3 Synchronization strategy

Live preview:

Try to commit asynchronously.
Avoid waitUntilCompleted.

Image export:

Can waitUntilCompleted if necessary.

Video export:

Control synchronization based on encoder needs.
Avoid unlimited queuing causing memory growth.

⸻

11. Compute Pipeline and Render Pipeline selection

11.1 Compute Pipeline suitable for

filter
Color adjustment
LUT
Microdermabrasion
mask processing
Local deformation, the first version can be implemented using compute

Advantages:

Input and output textures are clear
Convenient for multiple passes
Facilitate control of thread groups
No need to deal with vertex / fragment pipeline

11.2 Render Pipeline suitable for

mesh warp
Makeup map deformation
AR stickers
Background image synthesis
final display

11.3 First Edition Recommendations

First version first:

Compute Pipeline mainly
Output / Preview using Render Pipeline when necessary

The first version of geometric deformation can be computed displacement warp.

If higher quality face mesh warp is needed later, render pipeline + triangle mesh will be introduced.

⸻

12. FaceWarpPass Design

12.1 Responsibilities

FaceWarpPass handles all geometric deformations uniformly.

Includes:

big eyes
eye distance
eyes up and down
Eye tail raised
face slimming
small face
V face
chin
thin nose
Nose
Nose
mouth size
smile

12.2 Input

inputTexture
faces
BeautyParameters
WarpControlPointProviders

12.3 Output

warpedTexture

12.4 Control point generation process

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
Warp.Metal

12.5 CPU side structure

public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}

GPU side structure:

struct WarpControlPointGPU {
    float2 source;
    float2 target;
    float radius;
    float strength;
    float falloff;
    float padding;
};

12.6 Shader logical concepts

For each output pixel:

1. Current output position p.
2. Traverse control points.
3. Calculate the distance d from p to controlPoint.source.
4. If d < radius, calculate the weight w.
5. Calculate the reverse sampling offset according to source -> target.
6. Sample from the transformed coordinates of inputTexture.
7. Write outputTexture.

Concept formula:

offset = (target - source) * weight * strength
samplePosition = p - offset

Be careful to use reverse sampling to avoid holes.

12.7 Intensity Limitations

FaceWarpPass must perform security mapping for each type of parameters internally:

faceSlim maximum actual strength: 0.6
eyeSize Maximum actual strength: 0.45
noseSlim Maximum actual strength: 0.35
smile Maximum actual intensity: 0.5

Don't directly linearize the UI intensity as the final displacement.

⸻

13. SkinPass Design

13.1 Responsibilities

SkinPass handles basic skin beautification.

The first edition includes:

Microdermabrasion
Whitening
ruddy

13.2 Input

warpedTexture
BeautyParameters.skinSmoothing
BeautyParameters.skinWhitening
BeautyParameters.skinRosy

13.3 Output

skinProcessedTexture

13.4 First Edition Algorithm Strategy

1. Protect and smooth the edges of the image.
2. Mix the original image and the smoothed image according to skinSmoothing.
3. Use skinWhitening to improve skin tone brightness.
4. Apply slight rosiness according to skinRosy.

If the first version does not have a skin mask, it needs to be handled conservatively.

Subsequent upgrades:

skin mask
feature protection mask
bilateral filter
guided filter
frequency separation

13.5 Pass split proposal

For performance, the first version can be simplified:

SkinSmoothPass
SkinColorPass

or merge:

SkinPass

If skin resurfacing requires multiple samplings, multiple passes may be required:

BlurHorizontal
BlurVertical
BlendSkin

But externally it is still managed by SkinPass or SkinEffect to prevent RenderGraph from becoming too fragmented.

⸻

14. ColorPass Design

14.1 Responsibilities

ColorPass handles basic color adjustments.

First edition:

clear / sharpen
brightness, optional
Contrast, optional
Saturation, optional
Color temperature, optional

MVP must do:

skinSharpen

14.2 Design principles

All simple color adjustments should be combined into one shader whenever possible.

Prohibited:

BrightnessPass
ContrastPass
SaturationPass
TemperaturePass

Correct:

ColorAdjustmentPass

14.3 Uniform example

struct ColorUniforms {
    float brightness;
    float contrast;
    float saturation;
    float temperature;
    float tint;
    float sharpen;
};

⸻

15. LUTPass design

15.1 Responsibilities

LUTPass processing filters.

Input:

inputTexture
lutTexture
filterIntensity

Output:

filteredTexture

15.2 Rules

filterId == nil: skip LUTPass.
filterIntensity == 0: Skip LUTPass or copy directly.
filterId not found: downgrade to no filter or throw resource error.

15.3 Mixing formulas

output = mix(original, filtered, filterIntensity)

15.4 LUT resources

The first version supports:

.cube -> 3D LUT Texture

Core Image CIColorCube can also be used as the image processing path, but it is recommended to use Metal 3D Texture for real-time Metal pipeline.

⸻

16. MakeupPass design, subsequent versions

16.1 Responsibilities

MakeupPass handles makeup application and blending.

Includes:

lipstick
blush
eye shadow
Eyeliner
eyebrows
Contour
Highlights
Eye light

16.2 Dependencies

Face key points
local mask
Makeup resources texture
blend mode

16.3 Design principles

Don’t make each makeup look a separate complete pass.
Reasonable merging by resource and blend mode.
Lipstick can be passed independently.
Blush/Contour/Highlight can be combined.
Eye makeup is determined by complexity.

⸻

17. OutputPass design

17.1 Responsibilities

OutputPass is responsible for writing the final texture to the output texture or output PixelBuffer associated texture.

17.2 Output target

Live preview may require:

MTLTexture -> MTKView Drawable

SDK API returns may require:

MTLTexture -> CVPixelBuffer-backed MTLTexture

Image processing may require:

MTLTexture -> CIImage / CGImage / Data

First version SDK standard output:

CVPixelBuffer

17.3 Copy Pass

If the final Pass is not written directly to the outputTexture, CopyPass needs to be used.

CopyPass should be as lightweight as possible.

⸻

18. ShaderLibrary and PipelineStateCache

18.1 ShaderLibrary

Responsible for loading the .Metal function.

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

18.2 PipelineStateCache

PipelineState must be cached.

Prohibited:

makeComputePipelineState per frame
makeRenderPipelineState per frame

Example:

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

⸻

19. Buffer management specifications

19.1 Uniform Buffer

Each frame needs to be passed:

BeautyParameters uniforms
image size
face count
warp point count
LUT info

Suggestions:

Creating a small amount of uniform buffer per frame is acceptable.
For high-frequency small buffers, it is recommended to use BufferPool or ring buffer.

19.2 WarpControlPoint Buffer

All control points are merged into one Buffer.

[WarpControlPointGPU]

Prohibited:

One buffer for each facial feature
One buffer for each point

19.3 Triple Buffering

In order to avoid the CPU writing to the buffer that the GPU is reading, you can use:

triple buffering

The first version can be implemented simply first, and then upgraded during the performance optimization stage.

⸻

20. Coordinates and texture direction specifications

20.1 Coordinate system

Metal texture sampling is typically used:

texture coordinate: 0...1
pixel coordinate: 0...width / 0...height

Vision key points need to be converted into texture coordinates by CoordinateMapper.

20.2 Uniform requirements

The landmarks entering FaceWarpPass must already be:

texture normalized coordinates
x: 0...1
y: 0...1
The direction is consistent with inputTexture

FaceWarpPass should no longer handle Vision coordinates.

20.3 Front camera mirroring

Mirroring must be handled clearly during the detection coordinate mapping phase.

Duplicate mirrors in multiple places are prohibited.

Suggested strategies:

Detection outputs unified coordinates
Render only consumes unified coordinates
Preview determines whether to display the mirror
Export determines whether the export is mirrored

⸻

21. Pixel Format Design

21.1 First version support

Input:  kCVPixelFormatType_32BGRA
Metal:  .bgra8Unorm
Output: kCVPixelFormatType_32BGRA

21.2 Follow-up support

YUV 420 Full Range
YUV 420 Video Range
10-bit HDR, optional

21.3 YUV support strategy, follow-up

YUV input requires:

Y plane texture
UV plane texture
YUV -> RGB conversion pass
RGB processing
RGB -> YUV, optional if required by encoder

In the first version, it is not recommended to directly implement YUV full link. Stabilize BGRA first.

⸻

22. Real-time preview of output strategy

22.1 SDK returns CVPixelBuffer

Standard API:

let output = try engine.process(pixelBuffer: input, orientation: .right, parameters: parameters)

Advantages:

Universal
Preview available
Encodable
Exportable
Compatible with AVFoundation

22.2 App display strategy

Apps can:

CVPixelBuffer -> MTLTexture -> MTKView

You can also let the SDK provide an optional Preview Renderer later.

First edition suggestions:

The SDK only returns CVPixelBuffer.
Demo App displays itself.

22.3 Low latency optimization, follow-up

To reduce latency, you can support:

processToTexture
processToDrawable

However, it is not recommended to expose it in the first version to avoid API complexity.

⸻

23. Synchronous and asynchronous design

23.1 First version of synchronization API

The first version of the external API returns synchronously:

func process(...) throws -> CVPixelBuffer

This means that internally it needs to ensure that the outputBuffer is available before returning.

If synchronous waiting is used in real-time links, costs need to be controlled.

23.2 Asynchronous optimization direction

In the future, we can provide:

func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters,
    completion: @escaping (Result<CVPixelBuffer, Error>) -> Void
)

or:

func processAsync(...) async throws -> CVPixelBuffer

23.3 Recommendations

The first version can be synchronized for the simplicity of the API.

But the internal architecture must reserve asynchronous:

CommandBuffer completion handler
output buffer life cycle management
frame dropping
in-flight frame limit

⸻

24. In-flight Frame control

24.1 Question

If real-time camera frames keep coming in but the GPU can't handle them, you'll see:

Increased latency
memory rise
texture accumulation
Preview lags

24.2 Strategy

Need to limit the maximum in-flight frame:

maximumInFlightFrames = 2 or 3

After exceeding:

discard new frames
Or return the original frame
Or reuse the previous frame result

24.3 First Edition Recommendations

App side AVCaptureVideoDataOutput settings:

videoOutput.alwaysDiscardsLateVideoFrames = true

Subsequent additions within the SDK:

InFlightFrameLimiter

⸻

25. Performance goals

25.1 Real-time targets

720p: Stable 30fps
1080p: Stable 30fps on mid- to high-end devices
4K: Not targeted as a live preview

25.2 Pass time-consuming target, reference

FaceWarpPass：1.0 ~ 3.0 ms
SkinPass：2.0 ~ 6.0 ms
ColorPass：0.3 ~ 1.0 ms
LUTPass：0.5 ~ 1.5 ms
Total Render：5 ~ 12 ms
Detection: asynchronous, 10~15fps

The actual situation depends on the equipment.

25.3 Optimization direction

Reduce the number of passes
Reduce detection frequency
Reduce processing resolution
Reuse textures
Reuse buffer
Merge color shaders
Limit the maximum number of faces
Low-end devices turn off advanced effects

⸻

26. Performance statistical design

26.1 Indicators

Statistics needed:

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

26.2 Implementation

The first version can be roughly calculated using CPU time.

You can use it later:

GPU timestamp
MTLCounterSampleBuffer, optional

26.3 External strategy

Ordinary integrators do not necessarily need to see all indicators.

Debug mode is available via:

Log
PerformanceOverlay
performanceHandler

⸻

27. Memory management specifications

27.1 Must be reused

MTLDevice
MTLCommandQueue
CIContext
CVMetalTextureCache
PipelineState
LUT Texture
Makeup Texture
Intermediate Texture
CVPixelBufferPool
MTLBuffer, can be optimized

27.2 Prohibited

Create a large number of textures per frame
Parsing LUTs per frame
Load PNG every frame
Create CIContext every frame
Create PipelineState every frame
Live link UIImage conversion
Unlimited cache resources

27.3 Memory peak control

Strategy:

Use ping-pong texture
Create texture pool on demand
Page exit releases large resources
Low-end devices reduce resolution
Maximum number of multiple faces

⸻

28. RenderGraph first version implementation route

28.1 Step One: CopyRenderPass

Goal:

Output the input texture as is

Acceptance:

Camera frames display normally after passing through the SDK
Color remains unchanged
The direction is not chaotic
No noticeable delay

28.2 Step 2: ColorPass

Goal:

Achieve basic capabilities of brightness/contrast/saturation/sharpening

Acceptance:

Slider adjustment takes effect in real time
When the parameter is 0, the output is equal to the original image.

28.3 Step 3: LUTPass

Goal:

Implement a filter LUT
Support filterIntensity

Acceptance:

filterIntensity 0 = original image
filterIntensity 1 = full filter
LUT is not loaded repeatedly

28.4 Step 4: FaceWarpPass

Goal:

Achieve big eyes and slim face

Acceptance:

Big eyes and thin face share the same Pass
Deformation smooth
Controllable background stretching

28.5 Step 5: SkinPass

Goal:

Skin resurfacing, whitening, rosy

Acceptance:

Natural effect
Not exposed
No plastic face

⸻

29. First version of RenderGraph configuration

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

Note:

CopyPass may not always be executed.
If the last valid Pass has already been written to the outputTexture, CopyPass is skipped.

⸻

30. Error handling

30.1 Possible errors

Metal is not available
CommandBuffer creation failed
Texture creation failed
Output PixelBuffer creation failed
Shader not found
PipelineState creation failed
LUT resource does not exist
Unsupported pixel format

30.2 Processing strategies

Live link:

The app can display the original frame when an error occurs.
The SDK returns an explicit BeautyError.
Don't crash.

Image processing:

Throw an error to the app.
The app displays the failure reason.

Internal development error:

Debug assertion.
Release returns an error.

⸻

31. Testing strategy

31.1 CopyPass test

Input and output sizes are consistent
Input and output colors are nearly consistent
Different resolutions are normal
The front and rear camera directions are normal

31.2 ColorPass test

If the parameter is 0, the output remains unchanged.
Brightness adjusted correctly
Saturation adjusted correctly
Sharpen without crashing

31.3 LUTPass test

filterId nil output unchanged
filterIntensity 0 output unchanged
filterIntensity 1 outputs complete LUT
LUT file parsing failed with errors

31.4 FaceWarpPass test

The output remains unchanged when there is no face
If the parameter is 0, the output remains unchanged.
Visible to the big eye
Face slimming visible
Multiple control points without crashing
If the strength is too high, there will be a clamp

31.5 Performance testing

720p 30fps
1080p 30fps, mid-to-high-end devices
Run continuously for 10 minutes
Memory does not continue to increase
Return to normal after switching camera

⸻

32. Relationship with BeautyEngine

BeautyEngine calling process:

process(pixelBuffer:)
        ↓
Parameter normalization
        ↓
Detect scheduling, asynchronous or downclocking
        ↓
Get the latest stable faces
        ↓
input pixelBuffer -> inputTexture
        ↓
Create output pixelBuffer
        ↓
output pixelBuffer -> outputTexture
        ↓
RenderGraph.render
        ↓
commandBuffer commit / sync if needed
        ↓
Return output pixelBuffer

Pseudo code:

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

Note:

The waitUntilCompleted above is a simple implementation of the first version of the synchronization API.
The real-time high-performance version should subsequently be changed to asynchronous or in-flight control.

⸻

33. Risks and solutions of the first version of the synchronization API

33.1 Risks

waitUntilCompleted blocks the calling thread.
If it takes too long in the capture queue, frames will drop.

33.2 Initial acceptable reasons

The API is simple.
Easy to develop and debug.
Run through the architecture first.

33.3 Subsequent optimization

processAsync
CommandBuffer completionHandler
Output buffer life cycle pool
in-flight frame limiter
preview directly outputs the drawable

⸻

34. Device downgrade strategy

34.1 performance mode

Processing size reduced to 720p
Detection interval 3~5 frames
Largest face 1
Close Advanced Microdermabrasion
Close makeup
Turn off background segmentation

34.2 balanced mode

Default 720p / 1080p
Detection interval 3 frames
Largest face 1~3
Basic microdermabrasion
Basic facial features
LUT

34.3 quality mode

higher resolution
Detection interval 1~2 frames
Advanced microdermabrasion
More complex effects
Good for pictures and exporting

⸻

35. Key Development Principles

1. All Passes must be skippable.
2. All PipelineState must be cached.
3. Reuse all textures as much as possible.
4. All geometric deformations are merged into FaceWarpPass.
5. All simple color adjustments are merged into ColorPass.
6. Live links do not use UIImage.
7. Decoupling detection and rendering.
8. Commit commandBuffer without Pass.
9. Do not waitUntilCompleted frequently on real-time links.
10. The output format is fixed to BGRA in the first version, and will support YUV in the future.

⸻

36. One sentence conclusion

The core of the Metal rendering pipeline is not to "write a lot of filters", but to establish a stable, high-performance, combinable real-time image processing pipeline.

The first version must be run through:

CVPixelBuffer
→ MTLTexture
→ RenderGraph
→ CopyPass / ColorPass / LUTPass
→ CVPixelBuffer

Then add it step by step:

FaceWarpPass
SkinPass
MakeupPass
BackgroundPass
Video Export

As long as MetalContext + TextureCache + PixelBufferPool + RenderGraph are stable, subsequent beauty effects can be continuously expanded as Pass or Provider.