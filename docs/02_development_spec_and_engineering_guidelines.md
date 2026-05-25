# 02. iOS Beauty SDK Development Spec and Engineering Guidelines

## 1. Document positioning

This document is the development specifications and engineering constraints of the iOS Beauty SDK and is used to guide subsequent code implementation.

Scope of application:

- Swift Package Manager Engineering Organization
- SDK module boundaries
- Swift coding standards
- Metal rendering specification
- Vision/Core ML detection specifications
- Core Image / LUT processing specifications
- SwiftUI Demo App access specification
- Concurrency and thread safety specifications
- Performance specifications
- Resource management practices
- Test specifications
- Version delivery specifications

Core principles:

```text
The SDK only provides core capabilities.
App only does UI and business orchestration.
The rendering link does not use UIImage.
Geometric deformations are unified and merged.
Decoupling detection and rendering.
Unified management of parameters.
Resources are loaded uniformly.
Performance comes first, effect comes second, and functionality is expanded last.
```

---

# 2. Overall technology stack

## 2.1 Required technologies

```text
Swift
Swift Package Manager
AVFoundation
Vision
Core Image
Metal
Metal Performance Shaders, optional
Core ML, optional but reserved
Swift Concurrency
XCTest
```

## 2.2 App Demo technology

```text
SwiftUI
AVFoundation
MTKView/CAMetalLayer wrapper
ObservableObject / @Observable
Swift Concurrency
```

## 2.3 It is not recommended to rely on

It is not recommended to introduce in the first version:

```text
Third-party beauty SDK
Large image processing framework
OpenGL ES
GPUImage as core pipeline
UIKit-heavy UI framework
Modules that strongly depend on Objective-C Runtime
```

You can refer to third-party implementation ideas, but the core SDK should be controlled as much as possible.

---

# 3. Overall project boundary

## 3.1 What should the SDK contain?

The SDK only contains:

```text
Image input model
parametric model
Default model
Face detection
Key point analysis
Coordinate transformation
Point smoothing
Metal rendering pipeline
Core Image / LUT processing
Geometric deformation
skin beauty
makeup rendering
Resource loading
error code
Log
Performance statistics
Image processing API
Video frame processing API
```

## 3.2 What the SDK should not include

The SDK should not contain:

```text
SwiftUI page
UIKit pages
button
Slider
Tab menu
Album selection page
photo button
Business login
Paid page
Server interface
User account system
advertising logic
Specific App business status
```

## 3.3 What should be included on the App side?

The App side is responsible for:

```text
camera page
Picture editing page
Parameter slider
Beauty category panel
Default entry
Before and after comparison
save button
Export logical entry
Permission pop-up window
User interaction status
SwiftUI / UIKit UI
```

The App side only calls the SDK API and does not enter the internal rendering details of the SDK.

---

# 4. SPM Engineering Specifications

## 4.1 Package Organizational Principles

The first version adopts:

```text
A Swift Package
Multiple internal Targets
An external Product
```

Not used:

```text
EyeBeautySDK Standalone Package
NoseBeautySDK Standalone Package
MouthBeautySDK Standalone Package
FaceBeautySDK Standalone Package
```

Reason:

```text
Eyes, nose, mouth, face shape sharing detection, point position, coordinates, Metal context, texture cache, deformation system.
Splitting it into multiple packages will lead to complex dependencies, duplicate code, and difficulty in version management.
```

## 4.2 Recommended directory structure

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
│   │   └── Utils/
│   │       ├── Clamp.swift
│   │       ├── Logger.swift
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
│   │       ├── Copy.Metal
│   │       ├── Warp.Metal
│   │       ├── Skin.Metal
│   │       ├── Color.Metal
│   │       ├── LUT.Metal
│   │       ├── Blend.Metal
│   │       └── Mask.Metal
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

## 4.3 Package.swift Specification

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

## 4.4 Target dependency rules

Allowed:

```text
BeautySDK -> BeautyCore / BeautyDetection / BeautyRender / BeautyEffects / BeautyResources
BeautyDetection -> BeautyCore
BeautyRender -> BeautyCore
BeautyEffects -> BeautyCore / BeautyDetection / BeautyRender
BeautyResources -> BeautyCore
```

Prohibited:

```text
BeautyCore -> BeautyRender
BeautyCore -> BeautyDetection
BeautyCore -> BeautyEffects
BeautyCore -> BeautyResources
BeautyRender -> BeautyEffects
BeautyDetection -> BeautyEffects
BeautyResources -> BeautyEffects
```

Core principles:

```text
BeautyCore must remain the bottom layer and the most stable.
BeautyEffects can rely on detection and rendering.
BeautyRender should not know the specific beauty function.
BeautyDetection should not know the specific beauty function.
BeautyResources should not drive rendering logic.
```

---

# 5. Module responsibility specification

## 5.1 BeautyCore

Responsible for:

```text
BeautyEngine
BeautyParameters
BeautyConfiguration
BeautyPreset
BeautyError
BeautyFrame
BeautyResult
Logger
Basic tool functions
```

Shall not appear:

```text
MTLDevice
MTLTexture
VNFaceObservation
SwiftUI
UIView
UIImageView
AVCaptureSession page logic
```

Description:

BeautyCore is the stable core of the SDK and tries not to rely on heavyweight frameworks.

## 5.2 BeautyDetection

Responsible for:

```text
Vision face detection
Vision face key points
Future Core ML face point model
Coordinate transformation
Detect throttling
Point smoothing
Face tracking status
Multi-face strategy
```

Shall not appear:

```text
SwiftUI View
Calculation of specific beauty parameters
Metal shader code
Filter resource loading
```

## 5.3 BeautyRender

Responsible for:

```text
MetalContext
TextureCache
RenderGraph
RenderPass
ShaderLibrary
PixelBufferPool
MTLCommandBuffer dispatch
Intermediate texture reuse
```

Shall not appear:

```text
Eyes, nose, mouth business logic
Face slimming parameter algorithm
Vision detection implementation
SwiftUI UI
```

## 5.4 BeautyEffects

Responsible for:

```text
big eyes
face slimming
thin nose
corner of mouth
chin
Microdermabrasion
Whitening
ruddy
LUT filter
makeup
Bokeh
Body beauty, post-production
```

Specifications:

```text
All geometry deformation functions must first generate a WarpControlPoint.
All color adjustments are merged into ColorAdjustmentEffect whenever possible.
All beauty effects must support an intensity of 0 with no side effects.
Each Effect must be able to be turned off independently.
```

## 5.5 BeautyResources

Responsible for:

```text
LUT loading
.cube parsing
Preset JSON loading
Makeup resource loading
Resource package version management
Bundle.module access
```

Shall not appear:

```text
camera logic
Rendering scheduling logic
SwiftUI page
Business network request
```

---

# 6. External API specifications

## 6.1 The main entrance only exposes BeautyEngine

Standard usage on App side:

```swift
import BeautySDK

let engine = try BeautyEngine(configuration: .default)

let output = try engine.process(
    pixelBuffer: inputPixelBuffer,
    orientation: .right,
    parameters: parameters
)
```

## 6.2 External API design principles

Must meet:

```text
simple
stable
testable
Expandable
Do not expose internal implementation
Don't leak Metal / Vision details unless necessary
```

## 6.3 BeautyEngine Specification

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

Rules:

```text
process is not allowed to block the main thread.
process does not allow internal creation of UIImage.
process does not allow modification of externally passed BeautyParameters.
process should take the fast path whenever possible when the parameters are all 0.
reset must clear the detection status, point smoothing status and cache status.
```

## 6.4 BeautyParameters Specification

Parameters uniformly use Float.

SDK internal scope:

```text
0.0 ... 1.0: enhanced parameters
-1.0 ... 1.0: Bidirectional adjustment parameters
```

The App UI can display:

```text
0 ... 100
-100 ... 100
```

But it must be normalized before entering the SDK.

Example:

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float

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

## 6.5 Parameter naming convention

Use English semantic naming instead of pinyin.

Correct:

```swift
faceSlim
eyeSize
noseWingSlim
mouthWidth
skinSmoothing
filterIntensity
```

Error:

```swift
shoulian
dayan
meibai
mouthBigValue
noseValue1
```

## 6.6 Parameter default value specifications

All parameters must be inactive by default:

```text
Float parameter defaults to 0
String? Default nil
Bool defaults to false unless explicitly enabled by default
```

---

# 7. Swift coding standards

## 7.1 Naming convention

Type: Large Hump.

```swift
BeautyEngine
FaceWarpEffect
VisionFaceDetector
```

Variables/Methods: Camelback.

```swift
processFrame
makeControlPoints
inputTexture
```

Protocol naming:

```text
Capability-based protocols use -ing
Object type protocol noun
```

Example:

```swift
FaceDetecting
LandmarkSmoothing
BeautyRendering
```

## 7.2 File naming convention

One file per main type.

```text
BeautyEngine.swift
BeautyParameters.swift
VisionFaceDetector.swift
FaceWarpEffect.swift
```

Gadgets of the same type can be merged:

```text
MathUtils.swift
Clamp.swift
```

## 7.3 Access control specifications

The default is `internal`.

Only use `public` for APIs open to the App.

Misuse of `open` is prohibited.

```swift
public final class BeautyEngine {}
internal final class VisionFaceDetector {}
private struct InternalState {}
```

Rules:

```text
The fewer external APIs, the better.
Internal implementations should not be made public.
The specific implementation of Effect is generally internal.
The model is public if it requires App construction.
```

## 7.4 Type design specifications

Value type takes precedence:

```text
parameters
Configuration
point
result
error context
```

Use struct.

Reference types are used for:

```text
Engine
Renderer
Detector
Cache
Pool
State Manager
```

Use final class.

## 7.5 Concurrently Deliverable Type Specifications

Cross-thread and cross-Task models must satisfy `Sendable` as much as possible:

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {}
public struct BeautyConfiguration: Sendable {}
public struct BeautyFaceObservation: Sendable {}
```

Do not forcefully abuse `@unchecked Sendable` when including non-sendable objects.

Only allowed if the following conditions are met:

```text
Internal state is protected by serial queue
Object read only
Object life cycle is clear
No cross-thread mutable shared state
```

## 7.6 Error handling specifications

The SDK uses throws internally and does not use fatalError to handle recoverable errors.

Scenarios where fatalError is allowed:

```text
Test Stub
Explicitly unreachable code
Temporary placeholder during development period, but must be removed before submission
```

Error definition:

```swift
public enum BeautyError: Error, Sendable {
    case metalUnavailable
    case textureCreationFailed
    case pixelBufferCreationFailed
    case shaderFunctionNotFound(String)
    case invalidInput
    case unsupportedPixelFormat
    case resourceNotFound(String)
    case renderFailed(String)
    case detectionFailed(String)
}
```

## 7.7 Log specifications

The SDK must have logs that can be turned off.

```swift
public enum BeautyLogLevel: Int, Sendable {
    case none
    case error
    case warning
    case info
    case debug
}
```

Logs must not be leaked:

```text
User picture path
User privacy information
Complete device unique identifier
business token
```

---

# 8. Swift Concurrency and Threading Specifications

## 8.1 Basic principles

```text
UI in MainActor.
The camera captures in the capture queue.
Face detection is in the detection queue.
Metal is encoded in the render queue.
Resources are loaded in the background queue.
```

## 8.2 Prohibited matters

It is forbidden to do the following in the main thread:

```text
Vision detection
Metal sync wait
Video frame-by-frame processing
Large image filter processing
LUT parsing
Makeup resource decoding
```

## 8.3 Recommended thread model

```text
MainActor
    SwiftUI states, buttons, sliders

CaptureQueue
    AVCaptureVideoDataOutput callback

DetectionQueue
    Vision / Core ML detection

RenderQueue
    Metal command buffer encoding

ResourceQueue
    LUT / Preset / Makeup resource loading
```

## 8.4 Decoupling detection and rendering

It is forbidden to wait for the detection result for each frame.

Correct process:

```text
camera frame in
    ↓
Rendering uses the latest stable face point
    ↓
Detection of asynchronously updated points at intervals
    ↓
After the point is smoothed, it enters the shared state.
```

## 8.5 CMSampleBuffer Notes

In real-time links, do not hold `CMSampleBuffer` across concurrent domains for a long time.

Recommended:

```text
Immediately retrieve the CVPixelBuffer in the capture callback.
Retain pixelBuffer if necessary.
Don't throw sampleBuffer into multiple Tasks for long processing.
```

## 8.6 State isolation specification

Detection status, point status, and cache status must not be directly read or written by multiple threads.

Recommended solution:

```text
serial queue
actor
lock protection
single thread render owner
```

The first version recommends using serial queues first to avoid introducing too many actors and real-time rendering scheduling complexity.

---

# 9. Metal rendering specification

## 9.1 Real-time link ban UIImage

The live camera link must be:

```text
CMSampleBuffer
→ CVPixelBuffer
→ CVMetalTexture
→ MTLTexture
→ Metal Render Pass
→ MTLTexture / CVPixelBuffer
→ Display / Encode
```

Prohibited:

```text
CMSampleBuffer → UIImage → CIImage → CGImage → UIImage
```

## 9.2 MetalContext Specification

`MetalContext` is responsible for unified management:

```text
MTLDevice
MTLCommandQueue
CVMetalTextureCache
CIContext, optional
MTLLibrary
```

Example:

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
            throw BeautyError.renderFailed("Failed to create command queue")
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

## 9.3 Render Pass merge specification

Disable one Pass per feature.

Error:

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

Correct:

```text
FaceWarpPass
    big eyes
    eye distance
    face slimming
    small face
    V face
    chin
    thin nose
    corner of mouth

SkinPass
    Microdermabrasion
    Whitening
    ruddy

ColorPass
    brightness
    Contrast
    saturation
    color temperature
    sharpen

LUTPass
    filter
```

## 9.4 Recommended rendering order

```text
1. Input Texture
2. FaceWarpPass
3. SkinPass
4. MakeupPass
5. ColorAdjustmentPass
6. LUTPass
7. Sharpen / OutputPass
```

The first version can be simplified to:

```text
1. Input Texture
2. FaceWarpPass
3. SkinPass
4. Color/LUTPass
5. Output
```

## 9.5 Intermediate Texture Specification

Use ping-pong texture.

```text
textureA -> pass1 -> textureB
textureB -> pass2 -> textureA
textureA -> pass3 -> textureB
```

Disables uncontrolled creation of new textures every frame.

Must have:

```text
TexturePool
PixelBufferPool
RenderTarget reuse
```

## 9.6 Command Buffer Specification

Typically only one `MTLCommandBuffer` is created per frame.

Rules:

```text
Try to merge command encoders in the same frame.
Don't commit every small feature.
Don't waitUntilCompleted frequently.
Waiting is only allowed when taking screenshots, exporting, and synchronous reading.
```

## 9.7 MTLBuffer specification

Small data such as control points and parameters:

```text
Ring buffer / triple buffer can be used
Avoid CPU override when GPU is in use
```

Prohibited:

```text
Massively create temporary MTLBuffers every frame
Each control point has a separate buffer
```

Correct:

```text
All WarpControlPoints are packed into a buffer
All parameters are packed into a uniform buffer
```

## 9.8 Shader naming convention

Metal files:

```text
Warp.Metal
Skin.Metal
Color.Metal
LUT.Metal
Blend.Metal
Mask.Metal
```

Function naming:

```text
beautyWarpKernel
skinSmoothKernel
colorAdjustKernel
lutFilterKernel
blendMakeupKernel
```

Structure naming:

```Metal
struct BeautyUniforms
struct WarpControlPointGPU
struct SkinUniforms
```

## 9.9 Metal Shader parameter specifications

The CPU and GPU shared structures must have an explicit memory layout.

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

```Metal
struct WarpControlPointGPU {
    float2 source;
    float2 target;
    float radius;
    float strength;
    float falloff;
    float padding;
};
```

Rules:

```text
Swift and Metal structure field order must be consistent.
16-byte alignment must be considered.
New fields must be modified simultaneously on both sides.
```

---

# 10. Geometric deformation specifications

## 10.1 Unified deformation principle

All facial deformations are uniformly converted to:

```swift
[WarpControlPoint]
```

Then executed once by a `FaceWarpEffect`.

Prohibited:

```text
big eye separate shader
Face slimming separate shader
Slim nose separate shader
Separate shader for corners of mouth
```

## 10.2 WarpControlPoint Specification

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
```

Field meaning:

```text
source: original control point position
target: target control point position
radius: radius of influence
strength: strength
falloff: attenuation curve
```

## 10.3 Provider Specification

Each type of function provides a Provider:

```swift
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
```

Recommended Provider:

```text
EyeWarpProvider
NoseWarpProvider
MouthWarpProvider
ChinWarpProvider
FaceShapeWarpProvider
EyebrowWarpProvider
```

## 10.4 Eye Function Specifications

The first version supports:

```text
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
```

Subsequent expansion:

```text
eyeWidth
eyeHeight
leftEyeSize
rightEyeSize
innerEyeCorner
outerEyeCorner
```

Rules:

```text
The radius of influence of large eyes must be limited to the periorbital area.
Adjusting the distance between the eyes should not significantly distort the bridge of the nose.
Raising the ends of the eyes should not cause obvious misalignment of the eyebrows.
There must be a synchronous switch for independent adjustment of the left and right eyes.
```

## 10.5 Face function specifications

The first version supports:

```text
faceSlim
faceSmall
faceVShape
jawSlim
chinLength
```

Rules:

```text
Face slimming mainly moves the cheek points towards the center.
For small faces, the overall outline is mainly reduced.
V-face mainly involves changes in the jaw and chin.
Chin adjustments should not cause severe deformation of the mouth.
Background stretching must be within acceptable limits.
```

## 10.6 Nose functional specifications

The first version supports:

```text
noseSlim
noseWingSlim
noseTipSize
noseBridge
```

Rules:

```text
For thin noses, the nose points should be moved first.
The radius of nose reduction must be limited.
To enhance the bridge of the nose, priority is given to light and shadow, not just geometry.
The upper limit of the nose function strength should be lower than the face function.
```

## 10.7 Mouth Function Specifications

The first version supports:

```text
mouthSize
mouthWidth
smile
lipColor
```

Rules:

```text
The raised corners of the mouth only affect the area around the corners of the mouth.
The size of the mouth should not cause severe stretching of the dental area.
Lip color enhancement should not cover lip lines.
Subsequent lipstick must be based on the lip mask, not the rectangular map.
```

---

# 11. Face detection and coordinate specifications

## 11.1 Detecting abstract specifications

Must be abstracted through protocols:

```swift
public protocol FaceDetecting {
    func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]

    func reset()
}
```

First version implementation:

```text
VisionFaceDetector
```

Can be replaced later:

```text
CoreMLFaceDetector
DenseLandmarkDetector
FaceMeshDetector
```

## 11.2 FaceObservation Specification

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

## 11.3 Coordinate system specifications

The following coordinates must be specified:

```text
Vision normalized coordinate
Image pixel coordinate
Texture coordinate
Preview coordinate
Mirrored preview coordinate
```

It is forbidden to convert coordinates casually in the business code.

All conversions must go through:

```swift
CoordinateMapper
```

## 11.4 Direction processing specifications

Must test:

```text
Front camera vertical screen
Rear camera vertical screen
Front camera horizontal screen left
Front camera horizontal screen right
Rear camera horizontal screen left
Rear camera horizontal screen right
Album Picture EXIF Direction
Video frame direction
```

## 11.5 Point Smoothing Specification

Must have:

```text
LandmarkSmoother
```

The first version of the algorithm:

```text
EMA exponential moving average
```

Can be expanded later:

```text
Kalman Filter
One Euro Filter
```

Rules:

```text
If the detection fails, the old points can be reused within 1~3 frames.
Continuous failures exceeding the threshold must clear the status.
Low-confidence faces must not enter strong deformation.
```

## 11.6 Detect frequency reduction specifications

Live cameras do not allow for forced full detection every frame.

Recommended:

```text
30fps rendering
10~15fps detection
```

Configuration items:

```swift
public var detectionFrameInterval: Int
```

---

# 12. Core Image and LUT specifications

## 12.1 Core Image uses boundaries

Can be used for:

```text
Offline picture filters
LUT ColorCube
Basic color adjustment
Some non-real-time processing
```

Real-time core links preferentially use Metal.

## 12.2 CIContext Specification

Disable creation of `CIContext` per frame.

Must be held and reused by `MetalContext` or Renderer.

## 12.3 LUT Specification

Supported formats:

```text
.cube
Internal binary LUT, optional
PNG LUT, optional
```

First version first `.cube`.

LUT parsing rules:

```text
Support LUT_3D_SIZE
Ignore comment lines
RGB to RGBA
alpha is fixed at 1.0
Check data quantity
```

## 12.4 Filter strength specification

The filter must support intensity blending:

```text
output = mix(original, filtered, intensity)
```

`intensity = 0` must be equal to the original image.

`intensity = 1` is the complete filter.

---

# 13. Skin Beauty Code

## 13.1 Basic beauty sequence

Recommended:

```text
Microdermabrasion
Whitening
ruddy
sharpen
```

Do not sharpen before grinding.

## 13.2 Microdermabrasion specifications

Disallow simple full-image Gaussian blur as formal skin resurfacing.

The first version is available for:

```text
Edge protection blur
Low frequency smoothing
High frequency details added back
```

Subsequent upgrades:

```text
Bilateral Filter
Guided Filter
Frequency Separation
Skin Mask
```

## 13.3 Skin area specifications

The first version can be weakly processed first.

Starting from 2.0 must support:

```text
skinMask
featureProtectionMask
```

Protected area:

```text
eyes
eyebrows
mouth
Teeth
nostrils
hair edges
```

## 13.4 Strength Specifications

High-intensity parameters must be protected by upper limits.

```text
Microdermabrasion cannot completely erase skin texture.
Whitening should not allow the highlights to overflow.
The rosiness should not make the whole face red.
```

---

# 14. Makeup System Specifications

## 14.1 Makeup resource structure

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

## 14.2 config.json specification

```json
{
  "id": "daily_clean_01",
  "name": "Daily Sheer",
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

## 14.3 Blend Mode Specification

Must support:

```text
normal
multiply
screen
overlay
softLight
color
```

## 14.4 Makeup application standards

Makeup must be based on key points or mask fit.

Prohibited:

```text
Fixed screen position map
Fixed face frame ratio map but does not follow rotation
```

---

# 15. SwiftUI Demo App Specification

## 15.1 App directory suggestions

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

## 15.2 SwiftUI Boundary Specification

SwiftUI View does not directly manipulate Metal internal objects.

Correct:

```text
View -> ViewModel -> CameraBeautyPipeline -> BeautyEngine
```

Error:

```text
View -> MTLCommandBuffer
View -> FaceWarpEffect
View -> VisionFaceDetector
```

## 15.3 ViewModel Specification

ViewModel can hold:

```text
BeautyParameters
Current category
Current default
camera status
Processing status
```

ViewModel should not implement:

```text
Metal shader encoding
Vision detection
filter algorithm
```

## 15.4 Parameter slider specifications

UI display range:

```text
0...100
-100...100
```

Convert before entering SDK:

```swift
let sdkValue = uiValue / 100.0
```

All sliders must support:

```text
reset
Default value
Live preview
Before and after comparison
```

---

# 16. Performance specifications

## 16.1 Real-time preview of target

First edition goals:

```text
720p: Stable 30fps
1080p: Stable 30fps on mid- to high-end devices
4K: Not targeted as a live preview
```

## 16.2 Export target

Image export:

```text
Support original image size processing
Large images can be processed offline
Allow time consuming but not crash
```

Video export:

```text
frame by frame processing
Support progress callback
Support cancellation
keep audio
Preserve direction
```

## 16.3 Equipment Classification

```swift
public enum BeautyRenderQuality: Sendable {
    case performance
    case balanced
    case quality
}
```

Suggested strategies:

```text
Performance: low resolution, low detection frequency, turn off advanced makeup and background segmentation
balanced: default strategy
quality: higher resolution, higher quality skin resurfacing, more face support
```

## 16.4 Performance prohibitions

Disable real-time links:

```text
Create CIContext every frame
Create MTLDevice every frame
Create MTLCommandQueue every frame
UIImage conversion per frame
Separate commit command buffer for each function
Parse LUT files per frame
Loading makeup PNGs every frame
Create a large number of temporary arrays every frame
```

## 16.5 Performance monitoring indicators

Must record:

```text
Total time spent per frame
Detection time-consuming
Rendering takes time
Time taken by each Pass
Current FPS
Number of dropped frames
memory peak
Number of textures
```

---

# 17. Resource Management Practices

## 17.1 Resource Type

```text
LUT
Preset JSON
Makeup Package
Sticker Texture
Background Texture
Model File
```

## 17.2 SPM resource access

Resources within SPM are uniformly passed:

```swift
Bundle.module
```

Paths must not be hardcoded.

## 17.3 Resource loading strategy

```text
LUTs are loaded and cached on demand
Preset can be loaded at startup
Makeup resources are loaded by package
Lazy loading of large textures
Unused resources can be released
```

## 17.4 Resource version specification

Resource bundles must contain:

```text
id
name
version
minimumSDKVersion
items
```

---

# 18. Test specifications

## 18.1 Unit Testing

Must cover:

```text
BeautyParameters default value
Parameter normalization
LUT parsing
Preset analysis
CoordinateMapper
LandmarkSmoother
Resource loading
Error handling
```

## 18.2 Rendering test

It is recommended to establish a fixed test image set.

Test content:

```text
big eyes
face slimming
thin nose
corner of mouth
Microdermabrasion
Whitening
filter
Combination parameters
```

## 18.3 Coordinate test

Must test:

```text
Front camera mirror
rear camera
Vertical screen
Horizontal screen
Album pictures EXIF
Video frame direction
```

## 18.4 Performance Test

Must test:

```text
low-end devices
mid-range device
High-end equipment
720p
1080p
Long run 10 minutes
multiple faces
High intensity parameters
```

## 18.5 Regression testing

Suggestions:

```text
Fixed picture + fixed parameters
Output pictures for difference comparison
Record rendering time
Record memory peak
```

---

# 19. Git and code submission specifications

## 19.1 Branch specification

```text
main: stable release branch
develop: develop integration branch
feature/*: feature branch
fix/*: fix branch
release/*: release preparation branch
```

## 19.2 Commit specification

Format:

```text
type(scope): message
```

Example:

```text
feat(render): add MetalContext
feat(warp): add FaceWarpEffect
fix(detection): correct mirrored coordinate mapping
perf(render): reuse intermediate textures
refactor(core): split BeautyParameters
```

Type:

```text
feat
fix
perf
refactor
test
docs
chore
```

## 19.3 PR Specifications

PR must state:

```text
what did
Which modules are affected
How to test
Does it affect performance?
Does it affect API
Do you need to update the documentation?
```

---

# 20. Documentation specifications

Each core module must have a README or documentation.

Must maintain:

```text
Architecture.md
API.md
Parameters.md
ResourceSpec.md
Performance.md
IntegrationGuide.md
CHANGELOG.md
```

## 20.1 Parameter document specifications

Each parameter must be specified:

```text
Name
Type
range
Default value
Action area
Whether bidirectional
Whether to rely on facial positioning
Is it supported in real time?
Performance impact
```

Example:

```text
Parameter: eyeSize
Type: Float
Range: -1.0 ... 1.0
Default value: 0
Function: Adjust eye size
Dependence: face key points leftEye / rightEye
Real time: support
Performance: low
```

---

# 21. Version planning specifications

## 21.1 version number

Use semantic versioning:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.0.0
1.1.0
1.1.1
2.0.0
```

## 21.2 version meaning

```text
PATCH: bug fix, no API changes
MINOR: Added new compatibility features
MAJOR: Breaking API changes
```

## 21.3 Recommended version route

```text
0.1.0 Technology Demo
0.2.0 SPM skeleton
0.3.0 Basic Filter
0.4.0 Face key points
0.5.0 Basic deformation
1.0.0 The first version of beauty SDK
1.5.0 Complete facial features refinement
2.0.0 Advanced Skin and Makeup
2.5.0 Background and portrait segmentation
3.0.0 Commercial complete SDK
```

---

# 22. First phase development tasks Spec

## 22.1 Goals

Complete the ineffective SDK closed loop.

```text
Input CVPixelBuffer
    ↓
BeautyEngine
    ↓
Metal RenderGraph
    ↓
CopyRenderPass
    ↓
Output CVPixelBuffer
```

## 22.2 Required documents

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

## 22.3 Acceptance Criteria

```text
App can import BeautySDK
BeautyEngine can be initialized
Input CVPixelBuffer can output CVPixelBuffer
The camera real-time image can be displayed again through the SDK
No UIImage relay
No UI code goes into the SDK
No obvious memory leaks
```

---

# 23. Second phase development tasks Spec

## 23.1 Goals

Implement base color and LUT filters.

## 23.2 Must-do functions

```text
brightness
contrast
saturation
temperature
sharpness
filterId
filterIntensity
.cube parsing
LUT loading
```

## 23.3 Acceptance Criteria

```text
Slider adjustment takes effect in real time
When the filter intensity is 0, it is equal to the original image.
A filter strength of 1 is a full filter
LUT does not repeat parsing
Pictures and cameras are available
```

---

# 24. The third phase of development tasks Spec

## 24.1 Goals

Complete face detection, key points and coordinate system.

## 24.2 Must-do functions

```text
VisionFaceDetector
BeautyFaceObservation
BeautyFaceLandmarks
CoordinateMapper
LandmarkSmoother
DetectionScheduler
Debug Landmark Overlay
```

## 24.3 Acceptance Criteria

```text
Key points are accurately drawn on the face
Front camera mirroring is correct
Correct horizontal and vertical screens
Detection of frequency reduction is configurable
Point jitter is acceptable
```

---

# 25. The fourth phase of development tasks Spec

## 25.1 Goals

Completed unified FaceWarpEffect.

## 25.2 Must-do functions

```text
WarpControlPoint
WarpControlPointProvider
FaceWarpEffect
EyeWarpProvider Basic Edition
FaceShapeWarpProvider Basic
Warp.Metal
```

## 25.3 Acceptance Criteria

```text
Big eyes and thin face share the same Pass
Multiple control points can take effect at the same time
An intensity of 0 is equal to the original image
Deformation edge smoothing
Controllable background stretching
```

---

# 26. The fifth phase of development tasks Spec

## 26.1 Goals

Completed 1.0 MVP core functionality.

## 26.2 Must-do functions

```text
Microdermabrasion basic version
Whitening
ruddy
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
lip color enhancement
Default JSON
```

## 26.3 Acceptance Criteria

```text
SDK available for demonstration
Camera available in real time
Image processing available
Parameters can be saved
Default available
Stable combination of effects
```

---

# 27. Code Review Checklist

Check before each commit:

```text
Have you put the UI code into the SDK?
Are UIImage used in real-time links?
Are expensive objects created every frame?
Is it breaking the Target dependency direction?
Did you write internal as public?
Is error handling missing?
Are parameter defaults missing?
Does it affect the main thread?
Is a Render Pass added? Is it necessary?
Is there testing?
Update documentation?
```

---

# 28. Final implementation principle

The most important engineering judgments for this project:

```text
1. Build the base first, not the functions first.
2. First do a closed loop of rendering without effects.
3. Do the filter again.
4. Make the key points of the face again.
5. Do unified geometric deformation again.
6. Then achieve big eyes, slim face, thin nose and mouth corners.
7. The UI always stays at the App layer.
8. The SDK always remains core, clean, and reusable.
9. Performance issues should be resolved during the architecture phase, rather than waiting for the functions to be completed before remediating them.
10. All advanced features must be built on the stable BeautyEngine + RenderGraph + FaceWarpEffect.
```

One sentence summary:

```text
This SDK is not a bunch of filters and sliders, but a real-time portrait image processing engine.
```
