# Architecture Research

**Domain:** Modular iOS beauty SDK with rich SwiftUI Demo app
**Researched:** 2026-06-10
**Confidence:** HIGH

## Standard Architecture

### System Overview

```text
Host App / BeautyDemo
  - SwiftUI screens
  - Camera and photo permission UX
  - Sliders, presets, compare, debug overlay
  - Imports BeautySDK only
        |
        v
BeautySDK public facade
  - BeautyEngine
  - BeautyConfiguration
  - BeautyParameters
  - BeautyPreset
  - BeautyResult
  - BeautyError
        |
        v
Internal SDK targets
  BeautyCore        -> value models, validation, diagnostics
  BeautyDetection   -> Vision detection, landmarks, tracking state
  BeautyRender      -> Metal/Core Image contexts, RenderGraph, passes
  BeautyEffects     -> skin, color, warp, feature, filter effect mapping
  BeautyResources   -> presets, LUTs, makeup/sticker manifests, validation
        |
        v
Apple frameworks
  AVFoundation, Vision, Metal, Core Image, CoreVideo, CoreMedia, OSLog
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `BeautyDemo` | UX, permissions, input selection, preview, sliders, compare, debug state | SwiftUI app with app-side stores and adapter objects. |
| `BeautySDK` facade | Stable host-facing API and error/result mapping | Public Swift target that hides internal modules. |
| `BeautyCore` | Parameters, configuration, errors, validation, logging, metrics | Foundation/CoreGraphics/CoreMedia-only target. |
| `BeautyDetection` | Face observations, landmarks, coordinate mapping, smoothing | Vision-backed implementation behind SDK abstractions. |
| `BeautyRender` | Metal context, texture cache, pixel-buffer pools, render graph | Metal/Core Image target with no UI pages. |
| `BeautyEffects` | Converts parameters into render passes/uniforms/resources | Effect registry and pass builders. |
| `BeautyResources` | Preset/LUT/makeup/sticker resource manifests and validation | Swift package resources and schema validators. |
| Tests | Contract and regression evidence | Swift package tests, Demo mapping tests, future UI tests. |

## Recommended Project Structure

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautyCore/
│   ├── BeautyDetection/
│   ├── BeautyRender/
│   ├── BeautyEffects/
│   ├── BeautyResources/
│   └── BeautySDK/
├── Resources/
│   ├── Presets/
│   ├── LUTs/
│   └── Manifests/
└── Tests/
    ├── BeautyCoreTests/
    ├── BeautyDetectionTests/
    ├── BeautyRenderTests/
    ├── BeautyEffectsTests/
    ├── BeautyResourcesTests/
    └── BeautySDKTests/

BeautyDemo/
└── BeautyDemo/
    ├── App/
    ├── Features/
    │   ├── Camera/
    │   ├── ImageEditor/
    │   ├── Parameters/
    │   ├── Presets/
    │   └── Diagnostics/
    ├── Shared/
    └── Resources/
```

### Structure Rationale

- **`BeautySDK/Sources/BeautyCore`:** Keeps public model semantics independent from Vision, Metal, and UI.
- **`BeautySDK/Sources/BeautySDK`:** Gives host apps one import path and one stable facade.
- **`BeautySDK/Sources/BeautyResources`:** Prevents presets/LUTs/makeup from becoming ad hoc files.
- **`BeautyDemo/Features`:** Allows rich app UX while preserving SDK boundaries.
- **`Tests`:** Keeps module contracts verifiable as modules grow.

## Architectural Patterns

### Pattern 1: Facade Over Internal Targets

**What:** Host apps import only `BeautySDK`; the facade delegates to internal targets.
**When to use:** Always for Demo and host integrations.
**Trade-offs:** More wrapper code, but much safer API stability and easier distribution.

```swift
import BeautySDK

let engine = try BeautyEngine(configuration: .default)
let result = try engine.process(input, parameters: parameters)
```

### Pattern 2: Immutable Parameter Snapshot Per Frame

**What:** Demo owns mutable slider state; SDK receives a value snapshot for each process call.
**When to use:** Realtime and still-image processing.
**Trade-offs:** Requires explicit store-to-parameter mapping, but prevents cross-thread shared mutable state.

```swift
let parameters = parameterStore.snapshot()
let result = try engine.process(frame, parameters: parameters)
```

### Pattern 3: RenderGraph Pass Ordering

**What:** Effects contribute pass descriptors or uniforms; a centralized graph controls order.
**When to use:** As soon as more than one color/skin/warp/filter operation exists.
**Trade-offs:** More upfront structure, but prevents arbitrary pass ordering and conflicting effects.

### Pattern 4: Resource Manifests

**What:** Presets, LUTs, makeup packs, stickers, and future assets carry ids, versions, compatibility, and validation metadata.
**When to use:** Before any resource-backed effect becomes user-visible.
**Trade-offs:** Adds schema work, but avoids unsafe or inconsistent asset loading.

## Data Flow

### Realtime Camera Flow

```text
Camera permission granted by Demo
    -> AVFoundation capture session
        -> AVCaptureVideoDataOutput sample buffer
            -> CVPixelBuffer / frame metadata
                -> BeautySDK facade
                    -> validate input and parameter snapshot
                        -> Vision detection or tracked landmarks
                            -> RenderGraph processing
                                -> output pixel buffer / texture
                                    -> Demo preview
```

### Still Image Flow

```text
Photo selected by Demo
    -> orientation and extent captured
        -> BeautySDK image processing entry
            -> normalize orientation / prepare backing
                -> detection if needed
                    -> quality-mode render graph
                        -> result image
                            -> Demo before/after compare
```

### Resource Flow

```text
Bundled or imported resource
    -> BeautyResources manifest decode
        -> compatibility and path validation
            -> typed resource model
                -> preset/filter/makeup effect
                    -> RenderGraph pass inputs
```

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Demo shell / foundation | No-op process, public facade, tests, no heavy resources | 
| MVP beauty SDK | Add detection, render graph, color/filter, skin, face effects, bounded camera pipeline |
| Rich SDK showcase | Add makeup, segmentation, multi-face, resource packs, advanced Demo UX |
| Commercial SDK | Add privacy manifests, binary/package distribution checks, integration docs, compatibility matrix |

### Scaling Priorities

1. **First bottleneck:** Camera latency and memory churn. Fix with pixel-buffer/texture reuse and frame dropping.
2. **Second bottleneck:** Coordinate/landmark correctness. Fix with explicit orientation/mirroring contracts and fixtures.
3. **Third bottleneck:** Effect conflict. Fix with centralized parameter validation and render graph ordering.
4. **Fourth bottleneck:** Resource drift. Fix with manifests and schema tests.

## Anti-Patterns

### Anti-Pattern 1: UI-First SDK

**What people do:** Put sliders, pages, and UIKit/SwiftUI state inside the SDK.
**Why it's wrong:** The SDK becomes tied to one app's UX and cannot serve host apps cleanly.
**Do this instead:** Keep UI in Demo; expose parameters, presets, and result/error models from SDK.

### Anti-Pattern 2: Per-Effect Rendering Islands

**What people do:** Each effect creates its own Metal/Core Image path.
**Why it's wrong:** Ordering, resource use, and performance become unpredictable.
**Do this instead:** Centralize pass construction through `BeautyRender` and `RenderGraph`.

### Anti-Pattern 3: Landmark Coordinates as UI Coordinates

**What people do:** Use Vision points directly in preview or Metal space.
**Why it's wrong:** Orientation, mirroring, crop, and texture coordinate differences produce wrong effects.
**Do this instead:** Use a canonical image-normalized SDK coordinate model and explicit mappers.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| None by default | Local-only SDK | Network upload is out of scope unless future requirements explicitly add it. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Demo -> `BeautySDK` | Public Swift APIs | Demo imports only facade. |
| `BeautySDK` -> internals | Target dependencies | Facade maps public calls to internal services. |
| Detection -> Render | SDK landmark/observation models | Never leak raw Vision coordinate assumptions to render passes. |
| Effects -> Render | Pass descriptors/uniforms/resources | Effects do not own global render scheduling. |
| Resources -> Effects | Validated resource handles | Effects do not open arbitrary files directly. |

## Sources

- Apple Developer Documentation, `AVCaptureVideoDataOutput`: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput
- Apple Technical Note TN2445, Handling Frame Drops with `AVCaptureVideoDataOutput`: https://developer.apple.com/library/archive/technotes/tn2445/_index.html
- Apple Developer Documentation, `VNDetectFaceLandmarksRequest`: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest
- Apple Developer Documentation, Metal: https://developer.apple.com/documentation/metal
- Apple Developer Documentation, `CIColorCube`: https://developer.apple.com/documentation/coreimage/cicolorcube
- Apple Developer Documentation, PackageDescription / Swift Package Manager: https://developer.apple.com/documentation/PackageDescription
- Apple Developer Documentation, privacy manifests for apps and third-party SDKs: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk
- Local `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `.planning/PROJECT.md`.

---
*Architecture research for: modular iOS beauty SDK*
*Researched: 2026-06-10*
