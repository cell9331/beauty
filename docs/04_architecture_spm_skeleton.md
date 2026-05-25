# 04. iOS Beauty SDK Technical Architecture: SPM Structure and First-Version Code Skeleton

## 1. Conclusion

In the first version, do not split the eyes, nose, mouth, and face shape into independent Swift Packages.

Recommended solution:

```text
A BeautySDK Swift Package
├── Multiple Targets
│   ├── BeautyCore
│   ├── BeautyDetection
│   ├── BeautyRender
│   ├── BeautyEffects
│   ├── BeautyResources
│   └── BeautySDK
└── The App side is only responsible for the UI, slider, default panel, and camera page display
```

That is to say:

- Do not make multiple independent SPMs: `BeautyEyeSDK`, `BeautyNoseSDK`, `BeautyMouthSDK`.
- A big `BeautySDK` Package should be made.
- Package uses multiple Targets internally to split responsibilities.
- Eyes, nose, mouth, and face shape are used as Effect/Provider inside `BeautyEffects` instead of independent Package.
- The UI is not put into the SDK or SPM. The UI is put into the App layer and implemented by yourself using SwiftUI or UIKit.

---

# 2. Why is it not recommended to split it into multiple SPMs based on facial features?

## 2.1 The functions of the facial features are not independent of each other

Functions such as big eyes, thin nose, mouth corners, face slimming, and chin belong to different areas on the surface, but the underlying dependencies are highly the same:

```text
Face detection
Face key points
Coordinate system conversion
Point smoothing
Metal rendering context
texture cache
Deformation algorithm
Render Pass Scheduling
Parameter normalization
Multi-face strategy
```

If you split them into multiple independent SPMs, there will be a lot of duplicate dependencies:

```text
BeautyEyeSDK depends on FaceDetection
BeautyNoseSDK depends on FaceDetection
BeautyMouthSDK depends on FaceDetection
BeautyFaceSDK depends on FaceDetection
```

It will finally become:

```text
Many packages reference the same basic modules
Version management is complicated
Interface boundaries are unstable
Compilation configuration is complicated
Debugging costs rise
```

There is no need to dismantle it like this in the first stage.

## 2.2 Geometric deformation should be handled uniformly

Eyes, nose, mouth, and face shape are essentially local geometric deformations.

They should not each write a Metal Shader.

The correct way is:

```text
Eye function generation eye control points
The nose function generates nose control points
Mouth function generates mouth control points
Face shape function generates face control points
        ↓
Unified into [WarpControlPoint]
        ↓
Unify into one FaceWarpPass
        ↓
Metal completes deformation in one go
```

This provides the best performance and is easiest to maintain.

If split into multiple independent SPMs, it can easily become:

```text
EyeWarpPass
NoseWarpPass
MouthWarpPass
FaceSlimWarpPass
ChinWarpPass
```

This will cause the same frame to read and write textures repeatedly, which wastes a lot of performance.

## 2.3 The core of the first version is to run through the rendering link, not to break down the functions too finely.

The most important thing about the first edition is:

```text
camera frame input
Metal rendering
Vision face key points
unified coordinate system
Unified deformation system
Basic beauty
filter
parameter system
```

As long as this base is stable, subsequent functions will continue to add providers instead of redesigning the architecture.

---

# 3. Recommended SPM splitting method

## 3.1 Package structure

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
│   │   └── BeautyResult.swift
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
│   │       ├── BeautyWarp.Metal
│   │       ├── BeautySkin.Metal
│   │       ├── BeautyColor.Metal
│   │       ├── BeautyLUT.Metal
│   │       └── BeautyBlend.Metal
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

# 4. Target division of responsibilities

## 4.1 BeautyCore

Core model and main entrance.

Responsible for:

- `BeautyEngine`
- Parametric model
- Preset models
- error type
- Configure the model
- Process the result model
- External API definition

Not responsible for:

- UI
- Camera page
- SwiftUI View
- UIKit controls
- Parameter panel

## 4.2 BeautyDetection

Responsible for face detection, key points, and coordinate systems.

Responsible for:

- Vision face detection
- Face key point analysis
- Multi-face result management
- Coordinate system conversion
- Front camera mirroring processing
- Point smoothing
- Detect frequency reduction strategies

## 4.3 BeautyRender

Responsible for Metal / Core Image rendering base.

Responsible for:

- `MTLDevice`
- `MTLCommandQueue`
- `CVMetalTextureCache`
- `CVPixelBufferPool`
- Metal shader management
- Render Graph
- Intermediate texture reuse
- Render Pass Scheduling

## 4.4 BeautyEffects

Responsible for all beautification algorithm effects.

Includes:

- Geometric deformation
- Eyes adjustment
- Nose adjustment
- Mouth adjustment
- Face shape adjustment
- Microdermabrasion
- Whitening
- ruddy
- LUT filters
- Makeup blending

Note:

Eyes, nose, and mouth are not independent Targets, but subdirectories within `BeautyEffects`.

## 4.5 BeautyResources

Responsible for resource loading.

Responsible for:

- LUT resource loading
- `.cube` parsing
- Default JSON loading
- Loading makeup resources
- Loading picture and texture resources
- Bundle management

## 4.6 BeautySDK

Aggregate Target.

Only one module is exposed to the outside world:

```swift
import BeautySDK
```

App does not need to import separately:

```swift
import BeautyCore
import BeautyRender
import BeautyEffects
```

Unless you want to expose more modules to internal debugging tools in the future.

---

# 5. Package.swift example

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

# 6. What should be placed on the App side?

The App side is responsible for UI and business orchestration.

For example:

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

SwiftUI can be used on the App side.

The SDK doesn't care about:

- How to arrange the buttons
- What does the slider look like?
- How to display the first-level classification
- Where is the default entrance?
- Whether to use SwiftUI
- Whether to use UIKit

The SDK only cares about:

```text
Give me input image
give me parameters
I output the processed image
```

---

# 7. Does the first version contain all functions?

It is not recommended that the first version include all features.

The first version should include "architectural closed loop + core effects" rather than implementing all the dozens of functions in the product plan.

## 7.1 Capabilities that must be included in the first version

The first version of the recommendations includes:

```text
Basic link:
1. Image input processing
2. Camera real-time frame processing
3. Metal rendering output
4. Parameter system
5. Default system basic version
6. LUT filter basic version

Detection capabilities:
7. Vision face detection
8. Vision face key points
9. Coordinate system conversion
10. Point smoothing

Basic beauty:
11. Microdermabrasion basic version
12. Whitening
13. ruddy
14. Clarity / Sharpening

Geometric deformation:
15. Big eyes
16. Face slimming
17. Small face
18. V face basic version
19. Chin Basic Edition
20. Slim nose basic version
21. Mouth Smile Basic Version
```

This is already a complete MVP.

## 7.2 Capabilities not recommended for inclusion in the first version

These are not recommended for the first version:

```text
1. Complete makeup system
2. Complex eye shadow
3. Eyeliner
4. Eyelashes
5. Color contact lenses
6. Hairline
7. Refinement of nasolabial folds
8. Automatically remove acne
9. High-precision teeth whitening
10. Advanced nasal base
11. Body beauty
12. Background replacement
13. AI stylization
14. Independent parameter adjustment for multiple faces
15. Complex local repair pen
```

These should be moved to stage two or stage three.

---

# 8. First version functional boundaries

## 8.1 Eyes First Edition

The first version does:

```text
big eyes
eye distance
eye up and down position
Eye tail slightly raised
```

Don’t do:

```text
Complex eye shape switching
Cat’s Eye / Peach Blossom Eye / Danfeng Eye
Eyeliner
eyelashes
Contact lenses
Complex lying silkworm
```

## 8.2 Nose first version

The first version does:

```text
thin nose
Narrowing of nose
Reduction of nose tip
Slightly enhanced nose bridge
```

Don’t do:

```text
Fine adjustment of nostrils
nasal base
Complex nose shadow
Realistic 3D reconstruction of nose bridge
```

## 8.3 Mouth First Edition

The first version does:

```text
mouth size
mouth width
smile
Basic lip color enhancement
```

Don’t do:

```text
full lipstick fit
lip gloss
M lip
Lip peak reshaping
Teeth finishing
```

## 8.4 Face shape version 1

The first version does:

```text
face slimming
small face
V face
chin length
Jawline slightly tightened
```

Don’t do:

```text
Fine adjustment of cheekbones
Left and right faces can be manually adjusted independently
facial symmetry reconstruction
Advanced adjustment of atrium / lower court ratio
```

---

# 9. The first version of the external API design

## 9.1 BeautyEngine

```swift
public final class BeautyEngine {

    public init(configuration: BeautyConfiguration = .default)

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

    public static let `default` = BeautyConfiguration(
        preferredProcessingSize: nil,
        maximumFaceCount: 1,
        enableFaceTracking: true,
        detectionFrameInterval: 3,
        renderQuality: .balanced
    )
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

# 10. Internal core model

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

# 11. Effect Design

## 11.1 BeautyEffect Agreement

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

# 12. Unified deformation system

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
        // The first version first calculates the center point and radius of the left and right eyes.
        // More complex eye corner, eye end, and eye height control points will be added later.
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

        // Upload allPoints to Metal Buffer here
        // Then do a one-time deformation through unified BeautyWarp.Metal
    }
}
```

---

# 13. BeautyEngine first version skeleton

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

# 14. RenderGraph first version design

The first version does not require a Pass for each feature.

Recommended:

```text
Pass 1：FaceWarpPass
    big eyes
    eye distance
    eyes up and down
    Eye tail raised
    face slimming
    small face
    V face
    chin
    thin nose
    corner of mouth

Pass 2：SkinPass
    Microdermabrasion
    Whitening
    ruddy

Pass 3：ColorPass
    brightness
    Contrast
    saturation
    sharpen

Pass 4：LUTPass
    filter
```

Pseudo code:

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
        fatalError("TODO")
    }
}
```

---

# 15. Development sequence

## Stage 1: Building the base

Goal: Not doing beautification, just running through the image pipeline.

Task:

```text
1. Create BeautySDK SPM
2. Create BeautyCore / BeautyRender / BeautyDetection / BeautyEffects / BeautyResources Targets
3. Implement BeautyParameters
4. Implement the BeautyEngine empty process
5. Implement CVPixelBuffer -> MTLTexture
6. Implement MTLTexture -> screen display or output CVPixelBuffer
7. Use SwiftUI to create a simple Demo page on the App side
```

Acceptance criteria:

```text
Camera images can be displayed after processing through SDK
Stable 30fps even without any beautification
No UIImage relay
```

## Stage 2: Filters and Colors

Task:

```text
1. Implement brightness/contrast/saturation
2. Implement LUT loading
3. Implement filterIntensity mixing
4. Realize the basic version of whitening
5. Implement the ruddy basic version
```

Acceptance criteria:

```text
Filters can be added to pictures and live cameras
Slider changes in real time
Parameters can be saved and restored
```

## Stage 3: Vision face key points

Task:

```text
1. Implement VisionFaceDetector
2. Parse faceContour / leftEye / rightEye / nose / lips
3. Implement CoordinateMapper
4. Draw key points in Debug mode on the App side
5. Implement LandmarkSmoother
```

Acceptance criteria:

```text
The front camera point is not reversed
The horizontal and vertical screen points are correct
Points are basically stable
```

## Phase 4: Unified Morphing System

Task:

```text
1. Define WarpControlPoint
2. Define WarpControlPointProvider
3. Implement FaceWarpEffect
4. Implement BeautyWarp.Metal
5. Realize big eyes
6. Achieve face slimming
```

Acceptance criteria:

```text
Big eyes and face slimming can be run in real time
Deformation area smoothing
Background deformation is not obvious
```

## Stage 5: Complete MVP facial features

Task:

```text
1. Eye distance
2. Eyes up and down
3. Raise the tail of the eyes
4. Small face
5. V face
6. Chin
7. Slim nose
8. Nose
9. Mouth size
10. Smile
```

Acceptance criteria:

```text
All functions share one FaceWarpPass
Not one Pass for each function
There is no obvious conflict after parameter combination
```

## Stage 6: Microdermabrasion

Task:

```text
1. Achieve basic microdermabrasion
2. Increase edge protection
3. Increase facial features protection
4. Increase intensity control
```

Acceptance criteria:

```text
Skin smoothens
Eyes, eyebrows, mouth are not blurry
Don’t show a plastic face
```

## Stage 7: Default System

Task:

```text
1. BeautyPreset Codable
2. JSON default loading
3. Default natural beauty
4. Clear
5. Exquisite
6. Boys are natural
```

Acceptance criteria:

```text
After selecting the preset on the App side, you can directly get the BeautyParameters
SDK doesn't care about UI entry
```

---

# 16. Abilities after the first version is completed

After the first version is completed, the SDK should be able to:

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

The App side only needs to map the value of the slider to `BeautyParameters`.

---

# 17. Subsequent expansion methods

When new functions are added in the future, there is no need to change the overall structure of the SDK.

For example, add lying silkworm:

```text
BeautyEffects/Makeup/EyeBagEffect.swift
```

For example, adding teeth whitening:

```text
BeautyEffects/Makeup/TeethWhitenEffect.swift
```

For example, add an advanced nose:

```text
BeautyEffects/Warp/NoseAdvancedWarpProvider.swift
```

For example, to increase body beauty:

Consider adding:

```text
BeautyBodyEffects
```

Or put it first:

```text
BeautyEffects/Body/
```

If body beauty becomes very complicated in the future, then separate Target will be dismantled.

---

# 18. Final Recommendations

Recommended architecture for the first version:

```text
An SPM Package
Multiple internal Targets
An external BeautySDK product
The UI is completely placed in the App
Facial features function as an internal module of BeautyEffects
All geometric deformations merged into one FaceWarpPass
Try to combine all color adjustments into one ColorPass
Separation of detection and rendering
Unified management of parameter models
```

Don’t pursue all the features in the first version.

The goals of the first edition should be:

```text
Run-through architecture
Run through real-time rendering
Key points for running through Vision
Run through unified deformation
Get through basic beauty
Runthrough LUT filter
Create iconic effects such as big eyes, slim face, thin nose, and corners of the mouth
```

This is more reliable than rolling out dozens of functions at once.

