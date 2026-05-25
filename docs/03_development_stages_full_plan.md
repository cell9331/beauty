# 03. iOS Beauty SDK Full Development Stage Plan

## 1. Documentation target

This document is used to plan the development stage of iOS Beauty SDK from 0 to a complete commercial version.

The goal is not to pile up all the functions at once, but to gradually advance according to technical dependencies:

```text
Bottom rendering link
    ↓
basic image processing
    ↓
Face detection and key points
    ↓
Geometric deformation
    ↓
skin beauty
    ↓
Refining facial features
    ↓
makeup system
    ↓
Background and portrait segmentation
    ↓
body beauty
    ↓
Video Export and Commercialization SDK
```

Core principles:

- The SDK only contains core logic, algorithms, detection, rendering, and resource loading.
- Don't put SwiftUI / UIKit UI into SDK.
- The App side is responsible for pages, sliders, category panels, default entrances, and camera pages.
- SDK provides unified parameter model and image processing capabilities.
- The first version gives priority to running through the closed loop, and the complete functions will be expanded in the future.

---

# 2. Overall stage division

It is recommended to break it down into 12 stages:

```text
Stage 0: Technical pre-research and architecture verification
Phase 1: SPM project skeleton and empty render link
Stage 2: Basic Image Processing and LUT Filters
Stage 3: Face detection, key points, coordinate system
Stage 4: Unified geometric deformation system
Stage 5: First Edition Core Beauty MVP
Stage 6: Complete facial refinement
Stage 7: Advanced Skin Beautification and Spot Repair
Stage 8: Makeup System
Stage 9: Background, portrait segmentation and atmosphere effects
Stage 10: Body Beautification
Stage 11: Video export, performance optimization and commercial SDK delivery
```

Among them:

- Stage 0 ~ 5: Complete the first available version of the beauty SDK.
- Stages 6 ~ 8: Close to the core portrait refinement experience of beautiful pictures/awake pictures/light face cameras.
- Stage 9 ~ 10: Expand background, body, stylization capabilities.
- Stage 11: Make a commercial SDK that is truly deliverable, integrable, and maintainable.

---

# 3. Phase 0: Technical pre-research and architecture verification

## 3.1 Stage Goals

Verify whether the key technical routes for implementing the Beauty SDK on iOS are feasible.

This stage does not pursue a complete architecture, nor does it pursue good-looking effects. It only verifies core technical points:

```text
Can camera frames enter Metal in real time?
Whether Vision face key points are available
Can Metal be capable of local deformation?
Can Core Image/Metal be used as a filter?
Is the real-time frame rate acceptable?
```

## 3.2 Main tasks

### Task 1: Camera real-time frame verification

- Use AVFoundation to get camera frames.
- Get CMSampleBuffer through AVCaptureVideoDataOutput.
- Get CVPixelBuffer from CMSampleBuffer.
- Enter the rendering link directly without going through UIImage.

### Task 2: Metal display verification

- Create MTLDevice.
- Create MTLCommandQueue.
- Create CVMetalTextureCache.
- Convert CVPixelBuffer to MTLTexture.
- Display with MTKView or CAMetalLayer.

### Task 3: Vision face key point verification

- Use Vision to detect faces.
- Obtain key points such as eyes, nose, mouth, face contours, etc.
- Draw key points on the debug layer.
- Verify that the front camera, horizontal and vertical screens, and mirroring directions are correct.

### Task 4: Basic deformation verification

- Use fixed points to implement a simple big eye demo.
- Implement a simple face slimming demo using cheek key points.
- Verify the feasibility of Metal shader to perform local deformation.

### Task 5: Basic filter verification

- Achieve brightness, contrast, saturation adjustment.
- Implement LUT filter loading.
- Verify adjusting intensity in real time.

## 3.3 Stage products

```text
CameraMetalDemo
VisionLandmarkDemo
FaceWarpDemo
LUTFilterDemo
Technical verification record documentation
```

## 3.4 Acceptance Criteria

- Camera live view can be displayed via Metal.
- Don't use UIImage as live link intermediate format.
- Vision keypoints are correctly mapped to screen coordinates.
- The basic effect can be seen in the Big Eye/Slim Face Demo.
- Basic filters can be adjusted in real time.

---

# 4. Phase 1: SPM project skeleton and empty rendering link

## 4.1 Stage Goals

Create a formal SDK project structure and run through the minimum processing closed loop.

The first stage is not to do the beautification effect, but to allow the SDK to complete:

```text
Input CVPixelBuffer
    ↓
BeautyEngine
    ↓
Metal RenderGraph
    ↓
Output CVPixelBuffer
```

## 4.2 Package structure

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

## 4.3 Target Responsibilities

### BeautyCore

Responsible for:

- `BeautyEngine`
- `BeautyParameters`
- `BeautyConfiguration`
- `BeautyPreset`
- `BeautyError`
- `BeautyResult`

### BeautyDetection

Responsible for:

- Face detection interface
- Vision detection implementation
- Key point model
- Coordinate conversion
- Point smoothing

### BeautyRender

Responsible for:

- MetalContext
- TextureCache
- RenderGraph
- RenderPass
- PixelBufferPool
- Shader loading

### BeautyEffects

Responsible for:

- All effects modules
- Geometric deformation
- Microdermabrasion
- Whitening
- filters
- Makeup

### BeautyResources

Responsible for:

- LUT loading
- `.cube` parsing
- Default JSON
- Makeup resources
- Bundle management

### BeautySDK

Responsible for:

- External aggregation export
-On the App side, you only need `import BeautySDK`

## 4.4 Main tasks

### Task 1: Create SPM

- Create `Package.swift`.
- Create multiple Targets.
- Configure the minimum system version of iOS.
- Configure Metal shader resources.

### Task 2: Implement BeautyEngine empty process

- Initial configuration.
- Receive CVPixelBuffer.
- Call Renderer.
- Return CVPixelBuffer.

### Task 3: Implement MetalContext

- Manage MTLDevice.
- Manage MTLCommandQueue.
- Manage CIContext.
- Manage CVMetalTextureCache.

### Task 4: Implement TextureCache

- CVPixelBuffer to MTLTexture.
- Create output CVPixelBuffer.
- Create intermediate MTLTexture.

### Task 5: Implement CopyRenderPass

- Only original copies of the first edition will be made.
- Verify that RenderGraph can be scheduled normally.

## 4.5 Stage Products

```text
BeautySDK SPM Project
BeautyEngine First Edition
BeautyParameters First Edition
MetalContext
TextureCache
RenderGraph
CopyRenderPass
Demo App access example
```

## 4.6 Acceptance Criteria

- App can introduce `BeautySDK` through SPM.
- `BeautyEngine` can be initialized.
- CVPixelBuffer can be output after inputting CVPixelBuffer.
- Live camera preview is stable.
- The SDK does not rely on SwiftUI UI.
- The SDK does not rely on UIKit page components.

---

# 5. Stage 2: Basic image processing and LUT filters

## 5.1 Stage Goals

Achieve basic image processing capabilities that do not rely on facial key points.

These functions are the basis for all subsequent beautification effects.

## 5.2 Function scope

### Basic color adjustment

- brightness
- Contrast
- saturation
- color temperature
- Hue
- exposure
- Highlights
- shadow
- sharpen

### LUT filter

- Built-in LUT filters
- `.cube` file parsing
- Filter intensity adjustment
- Mix original image and filter image
- Multi-filter resource management

### Basic beauty colors

- Whitening basic version
- Ruddy Basic Edition
- Adjust skin tone to cool or warm
- Basic version for even skin tone

## 5.3 Main tasks

### Task 1: ColorAdjustmentEffect

Implementation:

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

### Task 2: LUTFilterEffect

Implementation:

```text
filterId
filterIntensity
LUT texture loading
original / filtered blend
```

### Mission 3: CubeLUTParser

Implement `.cube` file parsing:

- Parse LUT_3D_SIZE.
- Parse RGB data.
- Generate RGBA data.
- Upload as 3D LUT Texture or Core Image ColorCube data.

### Task 4: Basic skin tone adjustment

Implementation:

- Whitening.
-Ruddy.
- Correction of yellowish skin tone.
- Correction of darker skin tone.

In the first version, the entire image can be processed first, and the skin mask can be added in subsequent stages.

## 5.4 Stage products

```text
ColorAdjustmentEffect
LUTFilterEffect
CubeLUTParser
LUTLoader
BeautyParameters color parameters
Basic filter resource pack
```

## 5.5 Acceptance Criteria

- Filters can be used for both image processing and camera real-time processing.
- Filter intensity can be adjusted in real time.
- Basic color parameters can be adjusted in real time.
- No obvious lagging.
- LUT resources can be loaded through Bundle.

---

# 6. Stage 3: Face detection, key points, coordinate system

## 6.1 Stage Goals

Establish a base of facial capabilities to prepare for big eyes, face slimming, nose slimming, makeup, and skin masking.

The focus of this stage is:

```text
Accurate detection
The coordinates are correct
correct direction
Point is stable
Multi-face strategy is clear
```

## 6.2 Function scope

- Face detection
- Key points of human face
- Face frame
- Eye key points
- Key points of the nose
- Key points of the mouth
- Key points of eyebrows
- Facial contour points
- Point smoothing
- Detect throttling
- Coordinate system conversion
- Front camera mirroring processing
- Basic support for multiple faces

## 6.3 Main tasks

### Task 1: FaceDetecting Protocol

Define detection interface:

```swift
public protocol FaceDetecting {
    func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]
}
```

### Task 2: VisionFaceDetector

Implement the first version using Vision:

- VNDetectFaceLandmarksRequest
- Parse VNFaceObservation
- Parse VNFaceLandmarks2D
- Convert to SDK internal model

### Task 3: BeautyFaceObservation

Define the internal face structure:

```text
faceId
boundingBox
landmarks
roll
yaw
confidence
```

### Mission 4: BeautyFaceLandmarks

Define keypoint structure:

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

### Task 5: CoordinateMapper

Unified coordinate system:

```text
Vision normalized coordinates
image coordinates
texture coordinates
preview coordinates
mirrored coordinates
```

### Mission 6: LandmarkSmoother

To achieve point smoothing:

- EMA smoothing.
- Low confidence filtering.
- Face ID matching.
- Avoid jittering of facial features.

### Task 7: Detect frequency reduction strategies

Implementation:

- Detect every N frames.
- The intermediate frame reuses the previous point.
- Retain the old point for a short time when the detection fails.
- Clear face status after long-term failure.

## 6.4 Stage products

```text
FaceDetecting
VisionFaceDetector
BeautyFaceObservation
BeautyFaceLandmarks
CoordinateMapper
LandmarkSmoother
FaceTrackingState
Debug landmark overlay example
```

## 6.5 Acceptance Criteria

- Key points of the face can be accurately drawn on the face.
- The front camera is not reversed.
- Horizontal and vertical screen orientations are correct.
- Point jitter is acceptable.
- The detection can still maintain real-time stability after frequency reduction.
- Supports at least 1 main face.
- Extensible to multiple faces.

---

# 7. Stage 4: Unified geometric deformation system

## 7.1 Stage Goals

Create a geometric deformation base common to all facial features and facial features.

This stage is very critical.

Instead of writing a separate shader for the eyes, nose, mouth, chin, and face shape, they should be unified into:

```text
Each function generates WarpControlPoint
        ↓
Merge all Control Points
        ↓
FaceWarpEffect is executed once
        ↓
Metal Warp Pass Output
```

## 7.2 Function scope

- WarpControlPoint
- WarpControlPointProvider
- FaceWarpEffect
- EyeWarpProvider
- FaceShapeWarpProvider
- ChinWarpProvider
- NoseWarpProvider
- MouthWarpProvider
- Metal warp shader
- control points uploaded to GPU
- Multi-point influence radius and falloff

## 7.3 Main tasks

### Task 1: Define WarpControlPoint

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
```

### Task 2: Define the Provider protocol

```swift
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
```

### Task 3: Implement FaceWarpEffect

Responsibilities:

- Collect points generated by all Providers.
- Merge all face points.
- Upload to MTLBuffer.
- Call the Metal shader.
- Complete all geometric deformations at once.

### Task 4: Implement Metal Warp Shader

Function:

- Calculate sampling offset for each pixel based on control points.
- Support radius falloff.
- Supports overlay of multiple control points.
- Avoid boundary sampling out of bounds.
- Keep deformations smooth.

### Task 5: Implement minimal functional verification

First just implement:

- big eyes
- face slimming

Verify that the unified deformation system is available.

## 7.4 Stage products

```text
WarpControlPoint
WarpControlPointProvider
FaceWarpEffect
EyeWarpProvider Basic Edition
FaceShapeWarpProvider Basic
BeautyWarp.Metal
```

## 7.5 Acceptance Criteria

- Big eyes and slim faces share the same Warp Pass.
- The picture changes in real time when adjusting the intensity.
- Deformed areas are naturally smooth.
- Background stretching is not noticeable.
- There will be no serious conflict when multiple parameters are turned on at the same time.

---

# 8. Stage 5: First Edition Core Beauty MVP

## 8.1 Stage Goals

Forming the first version of beauty SDK that can be demonstrated, integrated, and experienced.

After this stage is completed, the SDK should already have the prototype of a commercial demo.

## 8.2 Function scope

### Basic Beauty

- Microdermabrasion basic version
- Whitening
- ruddy
- Clarity/Sharpening

### Face shape

- face slimming
- small face
- V face basic version
- Chin basic version

### Eyes

- big eyes
- eye distance
- The upper and lower position of the eyes
- Basic version of raised eyelids

### nose

- Slim nose basic version
-Basic version of nose narrowing
-Basic version of nose reduction

### Mouth

- Mouth size
- Mouth width
- Mouth smile basic version
- Lip Color Enhancement Basic

### Filter

- LUT filters
- Filter strength
- Basic color adjustment

### Parameter system

- BeautyParameters
- BeautyPreset
- JSON default
- Parameter normalization

## 8.3 Main tasks

### Task 1: Perfect BeautyParameters

Define all tunable parameters of the first version:

```text
skinSmoothing
skinWhitening
skinRosy
skinSharpen
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

### Task 2: Implement MVP geometry functionality

Provider：

```text
EyeWarpProvider
FaceShapeWarpProvider
ChinWarpProvider
NoseWarpProvider
MouthWarpProvider
```

Function:

```text
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
```

### Task 3: Implement basic microdermabrasion

The first version of microdermabrasion does not pursue advanced skin segmentation. First do:

```text
Edge protection blur
Low frequency smoothing
High frequency details added back
Intensity control
```

### Task 4: Implement the default system

Default:

```text
natural
clear
Exquisite
Boys are natural
Natural ID photo
```

### Task 5: Implement Demo App access

Implemented using SwiftUI on the App side:

- Camera preview.
- Picture selection.
- Parameter slider.
- Functional classification.
- Before and after comparison.
- Preset selection.

Note: These UIs are not part of the SDK, just the Demo App.

## 8.4 Stage products

```text
Beauty SDK MVP
BeautyParameters full MVP version
Basic default JSON
Basic LUT resource pack
Demo App
Basic access documentation
```

## 8.5 Acceptance Criteria

- BeautySDK can be imported on the App side.
- Camera live preview available.
- Image processing available.
- Big eye, face slimming, whitening, skin resurfacing and filter effects are visible.
- The core facial features parameters of the first version are adjustable.
- Presets can be applied with one click.
- Real-time processing without lag.
- There is no UI code within the SDK.

---

# 9. Stage 6: Complete facial refinement

## 9.1 Stage Goals

Complete the ability to refine the complete facial features such as eyes, nose, mouth, eyebrows, forehead, chin, and face shape.

The goal of this stage is to upgrade from "basic beauty" to "refined portrait".

## 9.2 Eye function

### Basic adjustments

- big eyes / small eyes
- Eye width
- Eye height
- eye distance
- Adjust left eye individually
- Adjust right eye individually
- Eye synchronization switch

### Position adjustment

- Move eyes up/down
- Move left eye up/down
- Move the right eye up/down
- Whole eye rotation

### Eye shape adjustment

- The tail of the eyes is raised
- Press down the end of the eye
- Eye head adjustment
- Eye end adjustment
- Open the inner corner of the eye
- Open the outer corners of the eyes
- round eyes
- Almond eyes
- Cat Eye Basic Edition
- Basic version for droopy eyes

### Eye enhancement

- Eye light
- Brighten the whites of the eyes
- Remove yellowish whites of eyes
- Slightly dilated pupils
-Basic version of WoSi
- Dark circles lightening basic version

## 9.3 Nose function

### Geometry adjustment

- thin nose
- Narrowing of the bridge of the nose
- Narrowing of the nose
- Reduction of nose tip
- Upturned nose
- Press down the tip of the nose
- Move the nose up/down as a whole
- Overall nose scaling
- Nostril narrowing basic version

### Light and shadow enhancement

- Highlight on the bridge of nose
- Shadow on the side of nose
- Nose highlight
- Nose shadow
- Three-dimensional nose

## 9.4 Mouth function

### Geometry adjustment

- Mouth size
- Mouth width
- Mouth height
- Move mouth up/down
- Mouth rotation correction
- Upper lip thickness
- Lower lip thickness
- Lip peak enhancement
- Lip enhancement
- M lip basic version
- Corners of mouth raised
- Adjust the left corner of the mouth individually
- Adjust the right corner of the mouth individually

### Color enhancement

- Lip color enhancement
- Lip saturation
- Lip gloss
- Lip wrinkle lightening basic version

### Teeth

- Teeth Whitening Basic Edition
-Basic version of tooth yellow removal
- Teeth brightness

## 9.5 Eyebrow function

- Move eyebrows up/down
- Left eyebrow can be adjusted individually
- The right eyebrow can be adjusted individually
- brow distance
- thickening eyebrows
- Eyebrows become thinner
- The tail of the eyebrow is lengthened
- Eyebrow color adjustment
- Flat eyebrow basic version
- Curved eyebrow basic version
- Wild Eyebrow Basic Edition

## 9.6 Face shape function

- Overall face slimming
- Face slimming on the left side of the face
- Face slimming on the right side of the face
- small face
- Narrow face
- V face
- Jawline tightening
- Cheek reduction
- Zygoma adduction
- Chin becomes pointed
- Shortening of the chin
- Chin becomes longer
- Forehead becomes higher/lower
- Temple plump basic version
- Atrium shortened / lengthened basic version
- Shortened/lengthened lower court basic version
- Basic version of left and right face symmetry

## 9.7 Main tasks

### Task 1: Extend BeautyParameters

Add complete facial features parameters.

### Task 2: Extend Warp Providers

New or enhanced:

```text
EyeAdvancedWarpProvider
NoseAdvancedWarpProvider
MouthAdvancedWarpProvider
EyebrowWarpProvider
FaceContourWarpProvider
ForeheadWarpProvider
SymmetryWarpProvider
```

### Task 3: Local independent adjustment

Support:

- Left eye/right eye independent.
- Left/right face independent.
- Left mouth corner/right mouth corner independent.
- Left eyebrow/right eyebrow independent.

### Task 4: Parameter combination protection

Handle conflicts when multiple parameters take effect at the same time:

- Large eyes + distance between eyes.
- Face slimming + V face + chin.
- Mouth corners + mouth size.
- Wing of nose + tip of nose + bridge of nose.

### Task 5: Multi-face basic enhancement

Support:

- Unified beauty for all.
- Main face is given priority.
- Up to 3 faces.
- Multi-face performance degradation strategy.

## 9.8 Stage Products

```text
Complete facial features parameter model
Complete geometric deformation Provider
Facial features refining effect set
Multi-face basic support
Conflict resolution strategy for facial features parameters
```

## 9.9 Acceptance Criteria

- The main parameters of eyes, nose, mouth, and face shape are all available.
- The effect is natural when combined with multiple facial features parameters.
- No obvious local tears.
- The point position is stable when the face is slightly rotated.
- There will be no serious frame drops in multi-face scenes.

---

# 10. Stage 7: Advanced Skin Beautification and Spot Repair

## 10.1 Stage Goals

Upgrade basic skin resurfacing and whitening to more natural portrait skin refining capabilities.

The point is to avoid a plastic face and preserve skin texture.

## 10.2 Function scope

### Skin Beauty

- Advanced microdermabrasion
- Preserve skin texture
- Even skin tone
- Whitening enhancement
- Ruddy enhancement
- Edge protection of facial features
- Hair edge protection
- Highlight protection
- Shadow protection

### Partial repair

- Acne removal basic version
- Freckle removal basic version
- Lighten dark circles
- Tear trough lightening
- Fading nasolabial folds
- Reduce forehead lines
- Reduce fine lines around the eyes

### Skin area recognition

- Skin Mask Basic Edition
- Skin color range identification
- Core ML skin segmentation reserved
- Skin/facial features/hair protection area

## 10.3 Main tasks

### Task 1: Advanced dermabrasion algorithm

Implement or optimize:

```text
Bilateral Filter
Guided Filter
Surface Blur
Frequency Separation
```

Choose the right solution based on performance.

### Mission 2: SkinMaskEffect

Implement skin area mask:

First edition:

```text
Based on YCrCb/HSV skin tone range estimation
```

Premium version:

```text
Core ML skin segmentation model
```

### Task 3: Protection of facial features

Generate protection areas based on landmarks:

```text
eyes
eyebrows
lips
Teeth
nostrils
hair edges
```

### Task 4: Local texture repair

Basic plan:

- Local blur + texture addback.
- Detection of small defect areas.
- Blends with surrounding skin color.

Premium plan reserved:

- inpainting。
- Core ML bug fixes.

### Task 5: Dark circles/nasolabial folds

Adjust by area mask + light and dark:

- Brightens the under eye area.
- Balance the brightness in the nasolabial fold area.
- Preserve natural shadows.

## 10.4 Stage products

```text
AdvancedSkinSmoothEffect
SkinMaskEffect
BlemishRemovalEffect
DarkCircleRemovalEffect
WrinkleReductionEffect
FeatureProtectionMask
```

## 10.5 Acceptance Criteria

- Skin becomes clear but not plastic.
- Eyes, eyebrows, and mouth will not be scratched.
- Dark circles fade naturally.
-Nasolabial folds will not completely disappear into a fake face.
- Still controllable under high intensity parameters.

---

# 11. Stage 8: Makeup System

## 11.1 Stage Goals

Implement a complete makeup system, including overall makeup templates and partial makeup components.

This stage relies on:

- Stable key points.
- Stable mask.
- Good blend mode.
- Makeup resource specifications.

## 11.2 Function scope

### Overall makeup template

- Daily makeup
- Commuting makeup
- Clear makeup
- Sweet girl makeup
- Pure lust makeup
- Korean makeup
- Hong Kong style makeup
- Retro makeup
- ID photo makeup
- Natural makeup for boys

### Base makeup

- Foundation
- Concealer
- brighten
- Contouring
- Highlights

### Eye makeup

- eye shadow
- Eyeliner
- eyelashes
- Wocan
- Color contact lenses
- Eye light

### Eyebrow makeup

- Eyebrow shape
- Eyebrow color
- Eyebrow density

### Lip makeup

- lipstick
- lip gloss
- matte lips
- Hydrating lips
- Gradient lip
- Lip highlighter

### Blush

- Apple cheek blush
- Blush under eyes
- Tip of nose blush
- Contouring blush

### Contouring / Highlighting

- Nose shadow
- Highlight on the bridge of nose
- Cheekbone shading
- Jaw shadow
- Forehead highlight

## 11.3 Main tasks

### Task 1: Makeup Resource Specification

Define makeup bag structure:

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

### Task 2: MakeupPackage configuration

Configuration content:

```text
Makeup ID
Makeup name
Resource file
Applicable area
Color
Transparency
blend mode
Key point binding method
Strength default
```

### Task 3: Local mask generation

Generated based on landmarks:

```text
lipMask
eyeShadowMask
eyelinerPath
blushMask
eyebrowMask
noseHighlightMask
contourMask
```

### Task 4: Makeup texture deformation

Implementation:

- The texture is deformed by key points.
- Follow the face rotation.
- Zoom to follow people's faces.
- Supports left and right faces.
-Support transparency adjustment.

### Mission 5: Blend Mode

Support:

```text
normal
multiply
screen
overlay
softLight
color
linearBurn
```

### Task 6: Single makeup effect

Implementation:

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

## 11.4 Stage products

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
Complete makeup resource specification document
```

## 11.5 Acceptance Criteria

- The lipstick fits the lips naturally.
- Blush stays in place.
- Eyeshadow does not drift noticeably.
- Makeup can be adjusted overall in intensity.
-Single makeup items can be switched on and off independently.
- Makeup will follow stably when the face is slightly rotated.

---

# 12. Stage 9: Background, portrait segmentation and atmosphere effects

## 12.1 Stage Goals

Expand the capabilities related to portraits and backgrounds, supporting functions such as background blur, background replacement, character strokes, and ambient lighting effects.

## 12.2 Function scope

### Portrait segmentation

- character mask
- background mask
- Edge feathering
- mask smooth
- mask upsampling

### Background effect

- Background blur
- Background replacement
- background darkening
- Background coloring
- Background transparency
- Depth of field effect
- Spot blur

### Portrait effect

- Portrait strokes
- Character edge light
- Portrait soft light
- Portrait shadows

### Atmosphere effect

- Soft light
- Backlight
- Starlight
- light spot
- rim light
- Vignetting
- Film grain

## 12.3 Main tasks

### Task 1: PersonSegmentationProvider

The first version can use the system's portrait segmentation capabilities.

It can be replaced with the Core ML segmentation model later.

### Task 2: Mask post-processing

Implementation:

- mask blur。
- mask feather。
- mask edge refine。
- temporal smoothing。
- Low-resolution mask upsampling.

### Task 3: Background Blur

Implementation:

- Gaussian blur.
- Depth of field range.
- Basic version of spot blur.
- Character edge protection.

### Task 4: Background Replacement

Implementation:

- Picture background.
- Solid color background.
- Gradient background.
- Video background reservation.

### Task 5: Portrait Stroke and Rim Light

Implementation:

- mask edge detect。
- outline color。
- outline width。
- edge glow。

## 12.4 Stage products

```text
PersonSegmentationProvider
PortraitMaskEffect
BackgroundBlurEffect
BackgroundReplaceEffect
PortraitOutlineEffect
AtmosphereLightEffect
MaskPostProcessor
```

## 12.5 Acceptance Criteria

- The background blur has natural edges.
- There is no obvious hard edge at the edge of the hair.
- Background replacement is stable.
- Portrait strokes fit closely with the edges of characters.
- Can be downgraded according to the device in real-time scenarios.

---

# 13. Stage 10: Body Beautification

## 13.1 Stage Goals

Supports body proportion adjustment in half-body and full-body scenes.

Body beautification is not recommended in the early stage because it relies on key points of the human body, body segmentation, and global deformation control.

## 13.2 Function scope

### Long legs

- Leg elongation
- Lengthened calves
- Thigh elongation
- Height proportion adjustment

### Slimming

- Narrow the waist
- Shoulder width adjustment
- arms become thinner
-Thighs become thinner
- thinning of calves
- Crotch adjustment

### Head to body ratio

- Reduced head size
- Optimized shoulder-neck ratio
- Upper body proportion adjustment

### Basic posture correction

- Slight body straightening
- Shoulder level correction
-Standing proportion optimization

## 13.3 Main tasks

### Task 1: Human body key point detection

Need to introduce:

- Vision body pose。
- or Core ML human keypoint model.

### Task 2: Human body segmentation

Need to get:

```text
head
upper body
arm
waist
legs
background
```

### Task 3: Body Morphing System

Body deformation cannot directly reuse facial deformation and needs to be designed separately:

```text
BodyWarpControlPoint
BodyWarpProvider
BodyWarpEffect
```

### Task 4: Long-Legged Algorithm

Implementation:

- Longitudinal stretching of the leg area.
- Upper body area protection.
- Background transition fix.

### Task 5: Slimming Algorithm

Implementation:

- Both sides of the waist are deformed inwards.
- Partial contraction of the arm.
- Partial contraction of the legs.
- Area of effect decay.

## 13.4 Stage products

```text
BodyPoseDetector
BodySegmentationProvider
BodyWarpEffect
LegLengthEffect
BodySlimEffect
ShoulderAdjustEffect
HeadBodyRatioEffect
```

## 13.5 Acceptance Criteria

- The leg-lengthening effect is natural.
- Background stretching is not noticeable.
- Losing weight does not cause body proportion deformity.
- Half-body/full-body scenes have reasonable downgrades.
- Does not affect facial beauty pipeline.

---

# 14. Stage 11: Video export, performance optimization and commercial SDK delivery

## 14.1 Stage Goals

Upgrade the SDK from demo level to commercially deliverable level.

Key points:

```text
video processing
Stable performance
Memory stable
Interface stable
Complete documentation
Test complete
distributable
Authorizable
Diagnosable
```

## 14.2 Video capabilities

### Video file processing

- AVAssetReader reads video frames.
- BeautyEngine processing frame by frame.
- AVAssetWriter writes out videos.
- Audio tracks preserved.
- Video orientation preserved.
- Timestamp synchronization.
- Progress callback.
- Cancel processing.

### Real-time recording

- Camera real-time beautification.
- Video recording after beautification.
- The recording frame and the preview frame are consistent.
- Audio and video synchronization.

### Image processing

- UIImage / CGImage / CIImage input.
- CVPixelBuffer input.
- Export at original image resolution.
- Batch image processing.

## 14.3 Performance optimization

### Rendering optimization

- Reduce the number of Render Passes.
- Incorporate Color Pass.
- Incorporated Geometry Warp Pass.
- Intermediate texture reuse.
- Avoid frequent creation of MTLBuffer.
- Avoid creating CIContext every frame.
- Avoid UIImage transit.

### Detection optimization

- Face detection reduced frequency.
- Point cache.
- Point smoothing.
- Main face is given priority.
- Limit on the number of multiple faces.
- Detect resolution downsampling.

### Equipment Classification

Define quality levels:

```text
performance
balanced
quality
```

Determined based on equipment performance:

- Handle resolution.
- Detection frequency.
- Skin grinding algorithm level.
- Whether to enable makeup.
- Whether to enable background segmentation.
- Maximum number of faces.

### Memory optimization

- CVPixelBufferPool。
- Texture pool。
- MTLBuffer reuse.
- Resources are loaded on demand.
- Makeup resource cache is eliminated.
- LUT resource cache.

## 14.4 Commercial SDK capabilities

### Distribution method

- Swift Package source version.
- XCFramework binary version.
- Demo App。
- Sample project.

### Interface documentation

- Quick access to documents.
- Parameter description document.
- Camera access to documents in real time.
- Image processing documentation.
- Video export document.
- Resource pack documentation.
- FAQ document.

### Stability

- Error code.
- Logging system.
- Performance monitoring.
- Memory monitoring.
- Crash location information.
- Debug overlay。

### Authorization reservation

If commercialized in the future, it can be reserved:

- license verification.
- Function module switch.
- Resource pack permissions.
- Trial period configuration.
- Watermark strategy.

## 14.5 Test system

### Unit testing

- Parameter normalization.
- LUT parsing.
- Coordinate transformation.
- Presets loaded.
- Resource loading.

### Effect test

- Different face shapes.
- Different genders.
- Different skin colors.
- Different lighting.
- Wear glasses.
- Profile.
- Multiple faces.
- Occlusion.

### Performance testing

- Low-end devices.
- Mid-range devices.
- High-end equipment.
- 720p。
- 1080p。
- 4K pictures.
- Long running time.
- Video export.

### Regression testing

- Fixed test image set.
- Fixed parameter set.
- Output graph hash/difference comparison.
- Frame rate statistics.
- Memory peak statistics.

## 14.6 Stage products

```text
VideoBeautyProcessor
ImageBeautyProcessor
CameraRealtimeProcessor
PerformanceProfiler
DeviceCapabilityManager
SDK Logger
ErrorCode Documentation
Access document
Demo App
XCFramework
SPM Release
test report
```

## 14.7 Acceptance Criteria

- SDK can stably connect to real apps.
- Camera real-time processing is stable.
- Image export is stable.
- Video export available.
- Documentation is complete.
- The sample project is executable.
- There are reasonable downgrades for different devices.
- No obvious memory leaks during long-term operation.

---

# 15. Complete function coverage relationship

## 15.1 First version of MVP coverage

```text
basic link
Basic filter
Basic whitening
Basic rosy
Basic microdermabrasion
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
Default system
```

## 15.2 Second stage of refinement coverage

```text
Independent adjustment for left and right eyes
Complex eye shape
Open your eyes
lying silkworm
Eye light
dark circles
Complete nose adjustment
lip thickness
M lip
teeth whitening
eyebrow adjustment
Complete face shape
Left and right faces are symmetrical
cheekbones
forehead
temple
```

## 15.3 The third stage of advanced portrait coverage

```text
Advanced microdermabrasion
Even skin tone
Skin texture preserved
Remove acne
Freckle removal
Nasal pattern
tear trough
forehead lines
full makeup
lipstick
blush
eye shadow
Eyeliner
eyelashes
Contact lenses
Contour
Highlights
```

## 15.4 The fourth phase expansion capability coverage

```text
Bokeh
background replacement
portrait stroke
ambient light
stylized filter
body beauty
long legs
lose weight
Head to body ratio
Video export
Commercial SDK distribution
```

---

# 16. Recommended milestone version

## Version 0.1: Technical Demo

Contains:

```text
camera frame input
Metal display
Vision key points
simple filter
Simple big eyes/face slimming Demo
```

## Version 0.2: SDK skeleton

Contains:

```text
SPM
BeautyEngine
BeautyParameters
RenderGraph
TextureCache
CopyRenderPass
Demo App access
```

## Version 0.3: Basic filter version

Contains:

```text
brightness
Contrast
saturation
color temperature
LUT
Whitening
ruddy
sharpen
```

## Version 0.4: Face detection version

Contains:

```text
VisionFaceDetector
FaceLandmarks
CoordinateMapper
LandmarkSmoother
Debug points
```

## Version 0.5: Basic deformation version

Contains:

```text
FaceWarpEffect
big eyes
face slimming
small face
chin
```

## Version 1.0: The first version of beauty SDK

Contains:

```text
Basic beauty
LUT filter
big eyes
eye distance
face slimming
small face
V face
chin
thin nose
Nose
mouth size
smile
Default system
Camera real-time processing
Image processing
Demo App
Access document
```

## Version 1.5: Complete facial features refinement

Contains:

```text
Complete eye adjustment
Complete nose adjustment
Complete mouth adjustment
Complete brow adjustment
Complete face adjustment
Multi-face basic support
```

## Version 2.0: Advanced Skin and Makeup

Contains:

```text
Advanced microdermabrasion
skin mask
Remove acne
dark circles
Nasal pattern
Complete makeup system
lipstick
blush
eye makeup
eyebrow makeup
Contour and Highlight
```

## Version 2.5: Background and atmosphere

Contains:

```text
Portrait segmentation
Bokeh
background replacement
portrait stroke
rim light
Ambient lighting effect
```

## Version 3.0: Complete commercial SDK

Contains:

```text
body beauty
Video file processing
Real-time recording processing
Performance rating
Device downgrade
XCFramework
Full documentation
Full test report
Commercial authorization reserved
```

---

# 17. Suggestions on staff division of labor

If it is developed by multiple people, it is recommended to divide the labor like this:

## iOS SDK Architecture Engineer

Responsible for:

- SPM architecture.
- BeautyEngine。
- API design.
- Module boundaries.
- SDK distribution.

## Metal Rendering Engineer

Responsible for:

- MetalContext。
- RenderGraph。
- TextureCache。
- Shader。
- Geometric deformation.
- Performance optimization.

## Algorithm/Image Processing Engineer

Responsible for:

- Microdermabrasion.
- Whitening.
- Skin mask.
- Partial repairs.
- Makeup blend.
- LUT。

## Face Detection / Core ML Engineer

Responsible for:

- Vision detection.
- Key point model.
- Coordinate transformation.
- Point smoothing.
- Segmentation model.

## App Demo Engineer

Responsible for:

- SwiftUI Demo。
- Camera page.
- Parameter panel.
- Picture editing page.
- Before and after comparison.

## Testing / QA

Responsible for:

- Test gallery.
- Performance testing.
- Compatibility testing.
- Regression testing.
- Effect acceptance.

---

# 18. Risk points and response strategies

## 18.1 Vision points are not precise enough

Risks:

```text
The fit of advanced effects such as nose, lips, eye makeup, etc. is not stable enough.
```

Response:

```text
First version with Vision.
The second version reserves the Core ML high-density keypoint model interface.
FaceDetecting uses protocol abstraction to facilitate replacement of detection implementations.
```

## 18.2 Insufficient real-time performance

Risks:

```text
Frame drops after multiple effects are superimposed.
```

Response:

```text
Merge Render Pass.
Detect frequency reduction.
Intermediate texture reuse.
Equipment classification.
Low-end devices turn off advanced effects.
```

## 18.3 The coordinate system is complex

Risks:

```text
Front camera mirroring, horizontal and vertical screens, and picture EXIF orientation cause point misalignment.
```

Response:

```text
In the early days, we specialized in CoordinateMapper.
Create a coordinate conversion unit test.
Debug overlay must be retained.
```

## 18.4 The effect is unnatural

Risks:

```text
The face is thinned and the background is stretched, the eyes are deformed, the skin is plasticized, and the makeup is drifting.
```

Response:

```text
Each parameter sets the maximum security strength.
Increase the naturalness curve.
Add facial protection mask.
Increase preset parameter limits.
```

## 18.5 Too many functions lead to out-of-control development

Risks:

```text
At the beginning, dozens of functions were implemented, but each result was unstable.
```

Response:

```text
Advance strictly in stages.
Only acceptable functions are performed at each stage.
Complete the MVP first, then expand advanced features.
```

---

# 19. The most recommended actual execution order

Don't just start with the full functionality.

Practical implementation suggestions:

```text
Step 1: First make the SPM skeleton and empty rendering link
Step 2: Make LUT and Base Color
Step 3: Do Vision keypoints and coordinate transformations
Step 4: Make Unified FaceWarpEffect
Step 5: Only make the eyes bigger and face slimmer
Step 6: Fill in small face, V face, chin, thin nose, mouth corners
Step 7: Basic microdermabrasion, whitening, and rosiness
Step 8: Make a default system
Step 9: Organize into 1.0 SDK
Step 10: Do a complete facial refinement
Step 11: Advanced Skin and Makeup
Step 12: Finale background, body, video export and commercialization
```

The most important point:

```text
First stabilize BeautyEngine + Metal RenderGraph + FaceWarpEffect.
```

As long as these three things are stable, adding eyes, nose, mouth, face shape, whitening, skin resurfacing, and filters will all be expanded on this base.

---

# 20. List of development tasks to be done immediately in the first phase

If you start work immediately, it is recommended to only do these in the first week:

```text
1. Create BeautySDK SPM
2. Create BeautyCore / BeautyRender / BeautyDetection / BeautyEffects / BeautyResources
3. Implement Package.swift
4. Implement BeautyConfiguration
5. Implement BeautyParameters empty parameter model
6. Implement BeautyEngine
7. Implement MetalContext
8. Implement TextureCache
9. Implement RenderGraph
10. Implement CopyRenderPass
11. Demo App access SDK
12. Camera frame input SDK
13. SDK output screen as it is
```

Acceptance goals for the first week:

```text
There is no beautification effect, but the SDK can already process camera frames in real time.
```

This is the most important first step of the entire project.

