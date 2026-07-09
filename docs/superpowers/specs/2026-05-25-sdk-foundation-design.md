# SDK Foundation Design

> Superpowers spec for the first executable `beauty` development phase.

## Goal

Create the first usable BeautySDK foundation: a Swift Package with stable target boundaries, core public models, a minimal `BeautyEngine`, and a no-effect render path that future beauty effects can build on.

This phase turns the repository from a documentation-heavy prototype into a codebase with a compilable SDK skeleton and testable contracts. It does not attempt to deliver visual beauty effects.

## Source Context

Authoritative inputs:

- `AGENTS.md`
- `PLANS.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `FRONTEND.md`
- `SECURITY.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `QUALITY_SCORE.md`
- `docs/02_development_stages_full_plan.md`
- `docs/03_architecture_spm_skeleton.md`
- `docs/04_development_spec.md`
- `docs/05_public_api_design.md`
- `docs/08_metal_render_pipeline_design.md`
- `docs/10_document_audit_report.md`

Current repository state observed on 2026-05-25:

- `BeautyDemo/` exists as an Xcode SwiftUI Demo app.
- `BeautyDemo/BeautyDemo/ContentView.swift` is still a default template-level UI.
- `BeautySDK/Package.swift` does not exist.
- `PLANS.md` lists no active plan before this planning work.
- `QUALITY_SCORE.md` identifies the current top repair queue as SDK package skeleton, core models, minimal render pipeline, Demo shell, and validation tests.
- Local `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` fails because the active developer directory is CommandLineTools, not full Xcode.

Environment recheck on 2026-06-10:

- The active developer directory is now full Xcode at `/Applications/Xcode.app/Contents/Developer`.
- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` succeeds and lists the `BeautyDemo` target / scheme.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` succeeds for the current Demo shell.
- The historical CommandLineTools failure above is retained as original planning context, not as the current environment state.

## Scope

In scope:

- Add a root-level `BeautySDK/` Swift Package.
- Add the internal targets `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and facade target `BeautySDK`.
- Add test targets for the foundation contracts.
- Implement the minimum public API surface needed for compilation and integration checks:
  - `BeautyEngine`
  - `BeautyConfiguration`
  - `BeautyRenderQuality`
  - `BeautyParameters`
  - `BeautyPreset`
  - `BeautyError`
  - `BeautyLogLevel`
- Implement the minimum render foundation:
  - `MetalContext`
  - `TextureCache`
  - `PixelBufferPool`
  - `RenderPass`
  - `RenderGraph`
  - `CopyRenderPass`
- Add a placeholder shader resource layout with `Warp.metal` reserved as the canonical warp shader name.
- Keep Demo app dependency direction clean: Demo may import `BeautySDK`, not internal targets.
- Add tests that prove defaults, validation, target visibility, and no-effect semantics.
- Record the plan and verification evidence in `PLANS.md`.

Out of scope:

- Real skin smoothing, whitening, rosy, sharpening, or texture enhancement.
- Face geometry effects such as face slim, eye size, nose slim, mouth shape, or smile.
- Vision face detection implementation beyond protocols or placeholders required for target compilation.
- LUT decoding, preset bundle resources, makeup resources, segmentation, body shape, video export, or commercial packaging.
- Full SwiftUI camera UI replacement.
- Network, upload, telemetry backend, dynamic resource download, or license checks.

## Architecture

Use one root Swift Package named `BeautySDK`, with multiple targets inside the package and one public library product named `BeautySDK`.

Target dependency direction:

```text
BeautyCore
    ↑
    ├── BeautyResources
    ├── BeautyDetection
    └── BeautyRender
             ↑
BeautyEffects ──────── uses detection models and render primitives
    ↑
BeautySDK
    ↑
BeautyDemo
```

The facade target `BeautySDK` re-exports or wraps the public surface needed by host apps. Host apps should not import `BeautyCore`, `BeautyRender`, `BeautyDetection`, `BeautyEffects`, or `BeautyResources` directly.

This phase should prefer small files that match the root documents and long-form docs:

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautyCore/
│   │   ├── Engine/
│   │   ├── Models/
│   │   └── Diagnostics/
│   ├── BeautyDetection/
│   ├── BeautyRender/
│   │   └── Shaders/
│   ├── BeautyEffects/
│   ├── BeautyResources/
│   └── BeautySDK/
└── Tests/
    ├── BeautyCoreTests/
    ├── BeautyRenderTests/
    ├── BeautyDetectionTests/
    ├── BeautyEffectsTests/
    └── BeautyResourcesTests/
```

## Core Model Design

`BeautyConfiguration` is immutable engine configuration. It contains runtime policy, not per-frame image state:

- `preferredProcessingSize: CGSize?`
- `maximumFaceCount: Int`
- `enableFaceTracking: Bool`
- `detectionFrameInterval: Int`
- `renderQuality: BeautyRenderQuality`
- `enablePerformanceLog: Bool`
- `enableDebugMode: Bool`
- `logLevel: BeautyLogLevel`

`BeautyParameters` is the stable public parameter snapshot. Numeric values are clamped at construction or mutation boundaries. Defaults represent no effect.

The 1.0 model keeps the 31 fields documented in `DESIGN.md` and `docs/06_beauty_parameters_spec.md`:

- Skin: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`
- Color: `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`
- Face shape: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`
- Eyes: `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`
- Nose: `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`
- Mouth: `mouthSize`, `mouthWidth`, `smile`, `lipColor`
- Filter: `filterId`, `filterIntensity`

`BeautyEngine` owns transient processing state. First implementation requirements:

- `init(configuration:) throws`
- `process(pixelBuffer:orientation:parameters:) throws -> CVPixelBuffer`
- `reset()`

For this phase, `process` may return a safe no-effect output that preserves the input image content. If GPU output allocation is not yet complete on all environments, implementation must make the limitation explicit through typed `BeautyError`, not a crash.

## Render Foundation Design

`BeautyRender` owns Metal setup and render scheduling. The first render path is a copy or no-op path whose value is architectural, not visual.

Required render units:

- `MetalContext`: creates `MTLDevice`, `MTLCommandQueue`, and shared render resources.
- `TextureCache`: wraps `CVMetalTextureCache` and maps supported pixel buffers to textures.
- `PixelBufferPool`: creates reusable BGRA output buffers.
- `RenderPass`: protocol for pass execution with declared input, output, and failure behavior.
- `RenderGraph`: owns ordered pass execution and skip rules.
- `CopyRenderPass`: first pass, preserving input pixels.

The first version must avoid per-feature render passes. Future geometry effects will generate control points and flow into `FaceWarpPass`, not separate eye, nose, mouth, and face shader passes.

`Warp.metal` is the canonical shader filename for future geometry work. This phase can create the resource location without implementing full face warp.

## Detection, Effects, And Resources

`BeautyDetection` may start with protocols and lightweight models needed to preserve target boundaries:

- `FaceDetecting`
- `BeautyFaceObservation`
- `BeautyFaceLandmarks`
- `CoordinateMapper`

Vision-specific implementation can be deferred until the face detection phase.

`BeautyEffects` may start with effect protocols and no-op composition types. It must not contain UI and must not implement real visual effects in this phase.

`BeautyResources` may start with resource bundle and preset loader shells only where needed for compilation. External resource registration remains disabled until a later security-reviewed resource plan.

## Demo Integration Design

The Demo remains outside the package. The only allowed SDK import in Demo code is:

```swift
import BeautySDK
```

This phase should add the package dependency to the Xcode project only when it can be done without destabilizing the existing project file. If Xcode project mutation is too noisy, the implementation plan should first verify SDK compilation through `swift test` and record Demo integration as a follow-up task in the same phase.

The Demo should not import internal targets or call Metal, Vision, render passes, or effect providers directly.

## Data Flow

Realtime target data flow for this foundation:

```text
BeautyDemo capture adapter
→ BeautyEngine.process(pixelBuffer:orientation:parameters:)
→ input validation
→ RenderGraph with CopyRenderPass
→ output CVPixelBuffer or typed error
→ BeautyDemo preview fallback or display path
```

Still image and real camera UI are not the main deliverable in this phase. The design keeps their future API space open.

## Error Handling

All public failures cross the API as `BeautyError`.

Minimum error surface:

```swift
public enum BeautyError: Error, Equatable, Sendable {
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

Rules:

- No `fatalError`, `try!`, or forced casts in release paths.
- Error associated values must be short and redacted.
- Unsupported pixel buffers return `.unsupportedPixelFormat` or `.invalidInput`.
- Metal setup failures return `.metalUnavailable` or `.commandQueueCreationFailed`.
- Missing shader functions return `.shaderFunctionNotFound`.

## Security And Privacy

This phase preserves the local-only posture:

- Do not add network behavior.
- Do not upload, persist, or log image pixels.
- Do not log landmarks, bounding boxes, file paths, raw JSON, or user identifiers.
- Do not trigger camera or photo permission prompts from SDK internals.
- Do not enable external resources.
- Validate public parameters and pixel buffer characteristics before expensive work.

Privacy manifest work remains tracked as existing tech debt until the SDK package has concrete required-reason API usage or collection behavior to declare.

## Reliability And Performance

First-phase reliability is about recoverable setup and bounded no-op processing:

- `BeautyEngine.init` throws typed errors instead of crashing.
- `reset()` clears transient state and is safe to call repeatedly.
- Empty or zero-strength effects are skipped.
- Realtime callers must not invoke processing on the main actor in future Demo camera paths.
- The copy/no-op path should avoid unbounded allocation and should prepare for reusable buffers.

The original 2026-05-25 local environment had CommandLineTools selected instead of full Xcode. A 2026-06-10 recheck found full Xcode selected and the Demo shell build succeeds when an explicit iOS Simulator destination is passed. Implementation verification must still record the exact command and result from the current machine.

## Testing Strategy

Minimum tests for the implementation plan:

- `BeautyParameters` defaults are no-effect.
- Numeric parameter initialization or mutation clamps non-finite and out-of-range values.
- `BeautyParameters` is `Codable`, `Equatable`, and `Sendable`.
- `BeautyConfiguration.default` has safe defaults, including release-suitable log level.
- `BeautyEngine` initialization succeeds or fails with typed `BeautyError`.
- `reset()` is idempotent.
- `RenderGraph` skips empty work and preserves pass order.
- `CopyRenderPass` preserves image content or reports a typed render error in unsupported environments.
- Demo import scans show no internal target import.
- Architecture scans from `QUALITY_SCORE.md` pass for newly added SDK paths.

Verification commands for the implementation phase:

```bash
swift test --package-path BeautySDK
```

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo
```

```bash
rg -n "fatalError|try!|as!" BeautySDK/Sources BeautyDemo/BeautyDemo
```

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

The final command may fail locally if full Xcode is not selected. A failure with the active developer directory set to CommandLineTools is an environment blocker, not proof that the project is invalid. A default-destination build may also fail by selecting an incompatible `My Mac`; pass an explicit iOS Simulator destination for compile evidence.

## Acceptance Criteria

This phase is complete when:

- `BeautySDK/Package.swift` exists and declares the agreed product and targets.
- `swift test --package-path BeautySDK` passes in an environment with the required Apple SDK toolchain.
- `BeautyCore` exposes the minimum public models and `BeautyEngine`.
- `BeautyRender` contains a minimal RenderGraph and copy/no-op path.
- `BeautySDK` facade is the only module Demo should depend on.
- Demo code does not import internal package targets.
- No release-path `fatalError`, `try!`, or forced casts are introduced.
- `PLANS.md` records verification evidence and any environment limitations.
- `QUALITY_SCORE.md` can be updated after implementation to raise SDK Package, Core, Render, and Tests from zero only where evidence exists.

## Open Decisions

Decision for implementation plan:

- If Xcode project package integration is noisy, prioritize `swift test --package-path BeautySDK` and use a separate task for Xcode project wiring. This keeps the package foundation independently verifiable.

No product behavior decisions are deferred by this spec. Visual beauty behavior remains intentionally out of scope for this phase.

## Self-Review

Placeholder scan:

- No unresolved placeholder terms are intentionally present.

Consistency check:

- Target names match `ARCHITECTURE.md`.
- The shader filename uses `Warp.metal`, matching the current audit conclusion.
- `BeautyConfiguration.logLevel` is part of the main configuration, not a separate configuration type.
- Direction and mirroring remain per-frame inputs, not global configuration.
- The first render path is copy/no-op only, matching the selected first-phase scope.

Scope check:

- This spec is focused on one implementation phase: SDK skeleton plus no-effect render foundation.
- Later visual effects, Vision detection, LUT, presets, makeup, segmentation, body shape, and video export are excluded.
