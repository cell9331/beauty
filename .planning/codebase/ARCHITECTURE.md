<!-- refreshed: 2026-08-13 -->
# Architecture

**Analysis Date:** 2026-08-13

## System Overview

```text
┌────────────────────────────────────────────────────────────┐
│              Host surfaces / executable entry points             │
├───────────────────┼───────────────────┼─────────────────────┤
│ SwiftUI Demo App  │ Public SDK facade │ Example renderer    │
│ `BeautyDemo/`     │ `.../BeautySDK/`  │ `.../BeautyExample-` │
│                   │                   │ `Renderer/main.swift`│
└────────╥──────────┴─────────╥─────────────────────┘
         │ imports only                  │ orchestrates
         └───────────────────────────────────▼
┌────────────────────────────────────────────────────────────┐
│ BeautySDK facade: validation, routing, request ownership        │
│ `BeautySDK/Sources/BeautySDK/`                                 │
└────────╥───────────────────────────────────────────────────┘
         │
         ▼
┌───────────────────┼───────────────────┼─────────────────────┤
│ Detection         │ Effects           │ Resources           │
│ `.../BeautyDetec-`│ `.../BeautyEffects/`│ `.../BeautyResources/`│
└────────╥──────────┴──────────╥─────────────────────┘
         │                         │
         └────────────┬────────────┘
                      ▼
┌───────────────────┼───────────────────┼─────────────────────┤
│ Core shared models│ Render primitives │ Apple frameworks    │
│ `.../BeautyCore/` │ `.../BeautyRender/`│ Vision/CoreImage/etc │
└───────────────────┴───────────────────┴─────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| `BeautyDemo` | Own SwiftUI navigation, camera/photo acquisition, app state, backpressure, and presentation; import only the public facade. | `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` |
| `BeautySDK` | Validate public inputs, validate resources, choose legacy or canonical still-image flow, own request lifetime, and return redacted results. | `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` |
| `BeautyCore` | Own stable public models, typed errors, canonical raster carrier, diagnostics values, presets, frames, and results. | `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` |
| `BeautyDetection` | Run Vision, map platform coordinates to package-only semantic observations, and select usable faces. | `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` |
| `BeautyEffects` | Normalize/cap parameters, resolve an effect plan, generate unified geometry, apply color effects, and own local-retouch providers/composition. | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` |
| `BeautyRender` | Provide render-pass abstractions, copy pass, pixel-buffer allocation, and the placeholder Metal shader resource. | `BeautySDK/Sources/BeautyRender/RenderGraph.swift` |
| `BeautyResources` | Parse bundled manifest/presets and validate stable resource identifiers. | `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift` |
| `BeautyExampleRenderer` | Exercise the public facade against committed fixtures and write local PNG evidence. | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` |

## Pattern Overview

**Overall:** Layered, package-modular iOS SDK with a public facade, immutable value snapshots, optional detection, a plan-and-pipeline effects core, and a request-scoped canonical local-retouch path.

**Key Characteristics:**
- Dependency direction is encoded in `BeautySDK/Package.swift`: `BeautyCore` is the shared base; `BeautyDetection`, `BeautyRender`, and `BeautyResources` depend inward; `BeautyEffects` composes them; `BeautySDK` is the public aggregation target.
- Host code must import `BeautySDK`, as demonstrated in `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` and `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`; internal target imports do not belong in the Demo.
- Processing consumes a `BeautyParameters` snapshot and creates a `BeautyEffectPlan`; algorithms do not read SwiftUI state (`BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`).
- Still images use two branches in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`: legacy Core Image processing when local retouch admission is empty, and canonical request-local RGBA composition when teeth or sclera intent is admitted.
- Pixel-buffer processing is face-independent today: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` resolves a plan without detection and calls `BeautyColorEffectPipeline`; it does not dispatch `RenderGraph` or realtime geometry.

## Layers

**Host/Application Layer:**
- Purpose: Acquire camera/photo input, own user interaction and view state, and display SDK output.
- Location: `BeautyDemo/BeautyDemo/`
- Contains: `App/`, `Home/`, `Editor/`, `Camera/`, `Panel/`, `State/`, and `Support/`.
- Depends on: Public `BeautySDK`, SwiftUI, AVFoundation, PhotosUI, UIKit, Combine.
- Used by: The iOS app target configured in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.

**Public Facade and Request-Orchestration Layer:**
- Purpose: Present `BeautyEngine`, validate inputs/resources, route detection and effects, and hide internal observations/masks.
- Location: `BeautySDK/Sources/BeautySDK/`
- Contains: `BeautyEngine`, geometry routing, canonicalizer, request context, resource facade, and package-only testing seams.
- Depends on: All internal package targets, declared in `BeautySDK/Package.swift`.
- Used by: `BeautyDemo`, `BeautyExampleRenderer`, and SDK consumers.

**Effects Planning and Execution Layer:**
- Purpose: Convert normalized parameters plus optional semantic face support into an executable plan and output.
- Location: `BeautySDK/Sources/BeautyEffects/`
- Contains: `Planning/`, `Warp/`, `Render/`, and `LocalRetouch/`.
- Depends on: `BeautyCore`, `BeautyDetection`, `BeautyRender`, and `BeautyResources` through `BeautySDK/Package.swift`.
- Used by: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.

**Detection Layer:**
- Purpose: Translate Vision observations into package-only, image-normalized semantic support and redacted summaries.
- Location: `BeautySDK/Sources/BeautyDetection/`
- Contains: `VisionFaceDetector`, `CoordinateMapper`, `FaceSelectionPolicy`, and `BeautyFaceObservation`.
- Depends on: `BeautyCore` and Apple Vision/Core Image frameworks.
- Used by: `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` and `BeautyEffects` geometry adapters/providers.

**Shared Model Layer:**
- Purpose: Supply stable public value types and the package-internal canonical still carrier.
- Location: `BeautySDK/Sources/BeautyCore/`
- Contains: `Models/` and `Diagnostics/`.
- Depends on: Foundation and foundational Apple media/image frameworks only.
- Used by: Every Swift Package target through the dependencies in `BeautySDK/Package.swift`.

**Render Primitive Layer:**
- Purpose: Supply reusable pixel-buffer/render abstractions while the current effects implementation uses Core Image pipelines.
- Location: `BeautySDK/Sources/BeautyRender/`
- Contains: `RenderPass`, `RenderGraph`, `CopyRenderPass`, `PixelBufferFactory`, and `Shaders/Warp.metal`.
- Depends on: `BeautyCore`.
- Used by: `BeautyEffects`; the public engine does not currently schedule `RenderGraph` (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift`).

**Resource Layer:**
- Purpose: Own bundled presets and manifest lookup/validation.
- Location: `BeautySDK/Sources/BeautyResources/`
- Contains: `Resources/manifest.json`, `Resources/Presets/*.json`, catalog, and manifest types.
- Depends on: `BeautyCore`.
- Used by: `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift` and `BeautyEffects`.

## Data Flow

### Canonical Local-Retouch Still-Image Path

1. The host calls `BeautyEngine.processResult(image:metadata:parameters:)` (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:96`).
2. The facade validates extent/pixel budget and resource references, then checks teeth/sclera admission (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:103`).
3. `BeautyStillImageCanonicalizer` normalizes EXIF orientation and input mirroring, requires bounded opaque RGB input, and renders one zero-origin named-sRGB RGBA8 carrier (`BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift:33`).
4. `resolveStillImageGeometry` chooses a Vision purpose and returns one selected package-only observation plus a redacted summary (`BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift:14`).
5. `BeautyStillImageRequestContext` binds the canonical raster and selected support to the stack-local request (`BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift:10`).
6. Teeth and/or sclera providers create proposals owned by one `BeautyLocalRetouchCompositionOwner`; per-eye failure remains local (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:157`).
7. The composition owner preflights ownership/capacity, rejects unexpected overlap, and blends every accepted proposal from original pixels (`BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift:143`).
8. `BeautyColorEffectPipeline` applies the remaining plan to the composed canonical carrier and returns `BeautyResult<CIImage>` with warnings, aggregate metrics, and redacted detection (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:213`).

### Legacy Still-Image Path

1. Empty local-retouch admission routes to `legacyStillImageResult` (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:118`).
2. Geometry detection runs only when `BeautyEffectResolver.requiresFaceGeometry` is true (`BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift:21`).
3. `BeautyEffectResolver` normalizes/caps requested strengths and combines package-only control points into an effect plan (`BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift:111`).
4. `BeautyColorEffectPipeline` applies color/filter/lip effects and delegates the selected-face warp to the unified geometry pipeline (`BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift:7`).
5. The facade returns output plus only redacted summaries, warnings, and aggregate metrics (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:245`).

### Camera Pixel-Buffer Path

1. `CameraSessionController` publishes `CMSampleBuffer`-derived preview frames (`BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`).
2. `CameraBeautyPipeline.enqueue` retains one in-flight work item and one newest pending item; superseded pending frames count as backpressure drops (`BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift:181`).
3. A dedicated queue calls `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` (`BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift:318`).
4. The engine validates dimensions/BGRA format, validates resources, resolves face-independent effects, and creates a new output pixel buffer (`BeautySDK/Sources/BeautySDK/BeautyEngine.swift:56`).
5. `CameraBeautyPipeline` publishes the latest snapshot on `@MainActor`, ignores stale generations, and processes the pending newest frame (`BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift:239`).

**State Management:**
- Use immutable `BeautyParameters` snapshots across the SDK boundary (`BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`).
- Keep mutable UI state in `@MainActor` `ObservableObject` owners such as `BeautyParameterStore`, `CameraBeautyPipeline`, and `ImageEditorPipeline` (`BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`).
- Use generation counters to discard stale asynchronous camera/photo results (`BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift:169`, `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift:91`).
- Keep masks, canonical pixels, landmarks, and provider ownership request-local; do not store them in public result types (`BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift`).

## Key Abstractions

**`BeautyEngine`:**
- Purpose: Stable synchronous public processing facade.
- Examples: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`.
- Pattern: Thin orchestrator over validation, resource lookup, detection, planning, composition, and rendering.

**`BeautyEffectPlan`:**
- Purpose: Immutable resolved work description containing active/skipped domains, warnings, metrics, and effective strengths.
- Examples: `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`.
- Pattern: Plan first, execute in shared pipelines.

**`BeautyFaceObservation`:**
- Purpose: Package-only semantic observation with face, eye, eyebrow, lip, and landmark support.
- Examples: `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`.
- Pattern: Anti-corruption boundary around Vision; never export raw platform geometry.

**`WarpControlPointProvider`:**
- Purpose: Convert one feature family's semantic support and effective strength into bounded control points.
- Examples: `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPointProvider.swift`, `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift`.
- Pattern: Strategy providers combined through one geometry pipeline.

**`BeautyCanonicalStillImage`:**
- Purpose: Immutable normalized RGBA8, zero-origin, named-sRGB carrier for admitted local-retouch requests.
- Examples: `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift`, `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`.
- Pattern: Canonicalize once, then detect/compose/render against one owned source.

**`BeautyLocalRetouchCompositionOwner`:**
- Purpose: Enforce mask ownership, capacity budgets, collision-to-source behavior, and original-pixel blending.
- Examples: `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- Pattern: One request-local composition authority; providers propose but do not mutate output independently.

## Entry Points

**Demo App:**
- Location: `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`
- Triggers: iOS app launch.
- Responsibilities: Create `ContentView`, which routes between `MeituHomeView` and `EditorShellView` in `BeautyDemo/BeautyDemo/ContentView.swift`.

**Public SDK Processing:**
- Location: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`
- Triggers: Host calls image or pixel-buffer `process`/`processResult` overloads.
- Responsibilities: Validate, route, process, and redact internal details.

**Resource Facade:**
- Location: `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift`
- Triggers: Host queries bundled presets/filters or engine validates parameters.
- Responsibilities: Prevent host access to the internal resource target.

**Example Renderer:**
- Location: `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- Triggers: `swift run BeautyExampleRenderer` from `BeautySDK/`.
- Responsibilities: Render public-facade output cases for local regression evidence.

## Architectural Constraints

- **Threading:** Public engine calls are synchronous; Demo moves work to private serial queues and publishes UI state on `@MainActor` (`BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`, `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`).
- **Global state:** Production image processing uses engine-owned detector/canonicalizer state in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`; request-local carriers and masks must not become module-level caches.
- **Circular imports:** None are permitted; target dependencies are acyclic in `BeautySDK/Package.swift`. Move shared values inward to `BeautyCore` instead of importing the facade from an internal target.
- **Public boundary:** Demo and executable clients must import only `BeautySDK`; package-only Vision observations, masks, control points, and canonical bytes stay inside `BeautySDK/Sources/`.
- **Realtime boundary:** Pixel-buffer processing is BGRA, face-independent, and geometry-free in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`; do not claim or add realtime detection/warp through the still-image path.
- **Render ownership:** Existing geometry effects share `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`; local color proposals share `BeautyLocalRetouchCompositionOwner`. Do not create per-feature output pipelines.
- **Resource ownership:** Add SDK resources only under `BeautySDK/Sources/BeautyResources/Resources/` and expose them through `BeautySDKResources`.

## Anti-Patterns

### Internal Target Imports in the Demo

**What happens:** App code imports `BeautyCore`, `BeautyDetection`, `BeautyEffects`, or `BeautyRender` directly.
**Why it's wrong:** It bypasses the stable facade and leaks package implementation into host UI.
**Do this instead:** Import `BeautySDK` and use public models/facades as in `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`.

### Per-Feature Rendering or Persisted Local Masks

**What happens:** A teeth/sclera provider directly mutates output, caches masks, or composes from another feature's already-edited pixels.
**Why it's wrong:** It breaks collision-to-source behavior, request isolation, and protected-region ownership.
**Do this instead:** Emit `BeautyLocalRetouchUnit` proposals and compose them once through `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`.

### Treating `RenderGraph` as the Active Engine Pipeline

**What happens:** New work assumes `BeautySDK/Sources/BeautyRender/RenderGraph.swift` or `Shaders/Warp.metal` already drives public processing.
**Why it's wrong:** The current facade calls `BeautyColorEffectPipeline`; `Warp.metal` remains a placeholder foundation.
**Do this instead:** Extend the current plan/pipeline path in `BeautySDK/Sources/BeautyEffects/Render/` unless a scoped architecture change explicitly wires `RenderGraph`.

## Error Handling

**Strategy:** Validate at public and trust boundaries, throw stable `BeautyError` for request-wide failure, and degrade/skip individual detection/effect regions while returning aggregate warnings.

**Patterns:**
- Reject invalid extent, pixel budget, unsupported pixel formats, malformed orientation/color semantics, transparency, and invalid filter IDs through `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautyStillImageCanonicalizer.swift`, and `BeautySDKResources.swift`.
- Return package-independent errors from `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`; do not expose Vision/Core Image errors directly.
- Express nonfatal missing/stale geometry as skipped domains, `BeautyValidationWarning`, and `BeautyDetectionSummary` in `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`.
- Fail local retouch closed per eye/region/provider and preserve unrelated valid units in `BeautySDK/Sources/BeautyEffects/LocalRetouch/` and `BeautyLocalRetouchComposition.swift`.
- Demo pipelines map processing failures to stable paused/failed UI states without retaining stale work (`BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`, `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`).

## Cross-Cutting Concerns

**Logging:** Public results expose aggregate metrics/warnings from `BeautyEffectPlan`; privacy-safe diagnostic value types live in `BeautySDK/Sources/BeautyCore/Diagnostics/`. Do not log raw pixels, paths, landmarks, masks, or stable face identifiers.
**Validation:** Normalize public parameters in `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`; validate image/resource boundaries in the facade; validate semantic geometry again inside each provider.
**Authentication:** Not applicable; the SDK and Demo contain no account/identity layer.

---

*Architecture analysis: 2026-08-13*
