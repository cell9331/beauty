# Phase 06 - Pattern Map

**Mapped:** 2026-06-21
**Scope:** Core beauty effects, safety caps, engine routing, fixture-visible output, degradation, and focused Demo feedback

## Source Inputs

- `.planning/phases/06-core-beauty-effects/06-CONTEXT.md`
- `.planning/phases/06-core-beauty-effects/06-RESEARCH.md`
- `.planning/phases/06-core-beauty-effects/06-VALIDATION.md`
- `BeautySDK/Sources`
- `BeautySDK/Tests`
- `BeautyDemo/BeautyDemo`
- `BeautyDemo/BeautyDemoTests`

## Implementation Pattern Map

| New / Changed Area | Closest Existing Analog | Pattern to Preserve |
| --- | --- | --- |
| `BeautyEffectsTests` target | `BeautyDetectionTests`, `BeautyRenderTests`, `BeautyResourcesTests` in `BeautySDK/Package.swift` | Add a focused internal-domain test target; do not force Demo or public facade tests to import internal effect targets. |
| Safety cap constants | `BeautyParameters` clamping and Phase 5 resource identifier validation | Keep public range normalization separate from algorithm-level effective caps; test exact constants from docs. |
| Effect resolver and plan values | `BeautyResourceCatalog` and `BeautyPreset` value-model style | Prefer small `struct`/`enum` values that are `Equatable` and `Sendable`; keep side effects out of resolver tests. |
| Warning and metrics evidence | `BeautyResult` and `BeautyValidationWarning` | Use stable warning codes and numeric counts/strengths; do not expose face geometry, raw framework errors, or local paths. |
| Pixel-buffer fixture output | `BeautyEngineTests.PixelBufferFixtures` and `CopyRenderPassTests` | Reuse deterministic BGRA byte fixtures and exact/threshold comparisons; default parameters stay copy/no-op. |
| CI image fixture output | `BeautyEngineTests.rgbaBytes(from:)` | Render tiny `CIImage` fixtures through `CIContext` for deterministic still-image assertions. |
| Engine routing | `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` and `processResult(image:metadata:parameters:)` | Capture a normalized parameter snapshot once, validate inputs/resources before work, and return `BeautyResult` metadata. |
| Resource-backed filters | `BeautySDKResources.validate(parameters:)` and Phase 5 metadata filters | Keep known IDs `soft_clean` and `warm_light`; make them visible through internal transforms without adding `.cube`, thumbnails, or swatches. |
| Face/landmark degradation | `BeautyDetectionSummary`, `DetectionStatusPresentation`, `BeautyFaceObservation` tests | Keep public summaries geometry-free; use internal/test fixtures for landmark group availability. |
| Demo parameter feedback | `BeautyParameterStore.status` and `BeautyDemoViewStateTests` | Keep store-owned short status copy; remove stale pending-Phase-6 copy without adding cap banners or per-slider warnings. |
| Demo panel smoke | `BeautyPanelView.viewState(...)`, `BeautyControlDescriptor`, `BeautyCategoryModels` | Verify expected labels/control IDs through value-state tests; preserve top-level category and subcategory order. |
| Import/privacy scans | `BeautyDemoImportBoundaryTests` and `InputPipelinePrivacyTests` | Keep Demo on `BeautySDK` facade only; scan public/Demo surfaces for raw geometry/path/framework leakage. |

## Concrete Existing Details

### SDK Package

- `BeautySDK/Package.swift` already defines `BeautyEffects`, but there is no `BeautyEffectsTests` target.
- `BeautyEffects` depends on `BeautyCore`, `BeautyDetection`, `BeautyRender`, and `BeautyResources`, so it is the correct owner for combining parameters, detection context, render instructions, and resources.
- `BeautySDK` facade depends on all internal targets; Demo must still import only `BeautySDK`.

### Public Models

- `BeautyParameters` has the full Phase 6 31-field model and clamps non-finite values to zero.
- `BeautyResult` already carries `warnings`, `metrics`, and `detectionSummary`.
- `BeautyValidationWarning` has only `code` and `message`, which is enough for cap/degradation evidence.
- `BeautyDetectionSummary` exposes only availability, reason codes, counts, and timings.

### Render and Fixture Seams

- `BeautyEngineTests` has `PixelBufferFixtures.makeBGRA`, `bytes(from:)`, and `rgbaBytes(from:)`.
- `CopyRenderPassTests` has a `RecordingPass` pattern for RenderGraph sequencing.
- `RenderGraph` currently accepts `[any RenderPass]` and skips passes whose `isEnabled(parameters:)` returns false.
- `Warp.metal` is a placeholder copy kernel; Phase 6 can add provider/cap tests before relying on production GPU warp quality.

### Detection and Coordinate Seams

- `BeautyFaceObservation` and `BeautyFaceLandmarks` are internal to `BeautyDetection`.
- Available groups are limited to `faceContour`, `leftEye`, `rightEye`, `nose`, and `outerLips`.
- `CoordinateMapper` owns conversion to image-normalized coordinates; effects should not reimplement Vision coordinate math.

### Demo State

- `BeautyParameterStore` owns normalized snapshots and status text.
- Existing stale copy is exactly `Visual update pending Phase 6`.
- `BeautyControlDescriptor` already exposes all Phase 6 controls.
- `BeautyPanelView.viewState(...)` is the existing deterministic seam for panel tests.
- `DetectionStatusPresentation` is already the correct UI path for no-face, partial, low-confidence, and stale states.

## Planned File Ownership

| Plan | Primary Files | Notes |
| --- | --- | --- |
| `06-01` | `BeautySDK/Package.swift`, new `BeautyEffects` effect model/safety/color files, `BeautyEngine.swift`, `BeautyEffectsTests`, `BeautyEngineTests` | Establish effect plan, caps, skin/color/filter visible output, and replace Phase 5 no-op color/filter assertions. |
| `06-02` | `BeautyEffects` warp shared types, face-shape/chin providers, `Warp.metal` or CPU warp seam, `BeautyEffectsTests`, optional `BeautyRenderTests` | Build face-shape provider/cap infrastructure before eye/nose/mouth providers depend on it. |
| `06-03` | `BeautyEffects` eye/nose providers and tests, internal detection fixture helpers | Prove coordinate-derived provider output and missing-eye/nose degradation. |
| `06-04` | `BeautyEffects` mouth provider, lip-color effect, engine fixture tests | Add mouth/lip behavior and missing-mouth degradation. |
| `06-05` | `BeautyEngine.swift`, Demo `BeautyParameterStore`, Demo tests, root docs, `QUALITY_SCORE.md`, `PLANS.md` | Close combined safety, no-face/stale metadata, Demo copy/smoke, docs, final verification. |

## Landmines

- Do not add new public `BeautyParameters` fields or Demo controls.
- Do not clamp public slider values down to safety caps; caps are internal effective strengths only.
- Do not expose `WarpControlPoint`, landmarks, bounding boxes, or face rects through `BeautySDK` public API or Demo UI.
- Do not make Demo import `BeautyEffects`, `BeautyRender`, `BeautyDetection`, `BeautyCore`, or `BeautyResources`.
- Do not keep the Phase 5 `Visual update pending Phase 6` copy after visible effects are implemented.
- Do not leave Phase 5 engine tests asserting non-zero color/filter parameters are no-op.
- Do not add `.cube` LUT assets, thumbnails, or swatches unless resource-security tests are also added; deterministic internal transforms are enough for Phase 6.
- Do not claim release-grade naturalness from pixel delta tests alone; record manual or simulator smoke separately when performed.
