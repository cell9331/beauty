# Project Research Summary

**Project:** Beauty
**Domain:** Modular iOS beauty SDK with rich SwiftUI Demo app
**Researched:** 2026-06-10
**Confidence:** HIGH for foundation and Apple-platform architecture; MEDIUM for advanced feature staging

## Executive Summary

Beauty should be planned as a reusable iOS SDK first and a rich Demo app second. The Demo can feel like a Meitu/Xingtu-style editor, but it should exercise SDK capabilities through the public `BeautySDK` facade rather than becoming the place where algorithms live.

The recommended approach is a staged native Apple stack: Swift Package targets for SDK modules, SwiftUI for the Demo, AVFoundation for camera frames, Vision for face landmarks and later segmentation, Metal for realtime effects, Core Image where it helps still-image/filter workflows, and XCTest from the first SDK foundation phase. The most important roadmap constraint is order: package/facade/value models -> no-op processing -> camera/still image flow -> detection/coordinates -> render graph/resources -> visible effects -> rich Demo expansion.

The biggest risks are scope explosion, realtime performance debt, coordinate/mirroring drift, fake-looking overpowered effects, unsafe resource loading, and late privacy work. Each of these needs explicit phase success criteria, not just implementation tasks.

## Key Findings

### Recommended Stack

Use native Apple frameworks and keep third-party dependencies out of the core pipeline by default. The current repo already targets Xcode 26.5 and a SwiftUI iOS Demo shell, so the lowest-risk foundation is a local Swift Package named `BeautySDK` with internal targets and a public facade.

**Core technologies:**
- Swift / Swift Package Manager: SDK modules and public API surface.
- SwiftUI / Observation: Demo state and category UI.
- AVFoundation / CoreVideo / CoreMedia: realtime camera frame input and timing.
- Vision: face landmarks now, person segmentation later.
- Metal / Core Image: realtime render graph, color/filter paths, and still-image processing.
- XCTest / xcodebuild: package, facade, and Demo verification.

### Expected Features

**Must have (table stakes):**
- Public `BeautySDK` facade with `BeautyEngine`, configuration, parameters, presets, result, and typed errors.
- Modular SDK targets for core, detection, render, effects, resources, and facade.
- No-op frame/image processing path before visible effects.
- Realtime camera preview and still-image processing through SDK.
- 1.0 parameter model, built-in presets, skin/color/filter MVP, and first face/eye/nose/mouth controls.
- Demo categories, sliders, compare/reset, disabled states, diagnostics, and error/degradation UI.

**Should have (competitive):**
- Meitu/Xingtu-style Demo polish with rich categories and preset-first flow.
- Naturalness safety caps and fixture checks.
- Resource manifest validation for presets, LUTs, makeup packs, and future stickers.
- Makeup, segmentation/background, and multi-face tuning after foundation quality is proven.

**Defer (v2+):**
- Body shaping, AI style generation, AR stickers, background replacement at production quality, video export, and commercial SDK distribution hardening.

### Architecture Approach

Keep the SDK boundary strict. Demo and host apps import only `BeautySDK`; internals are split by responsibility. Use immutable parameter snapshots per process call, a canonical image-normalized coordinate model, a centralized RenderGraph, and validated resource manifests.

**Major components:**
1. `BeautyDemo` — SwiftUI UX, permissions, input selection, sliders, compare, debug overlay.
2. `BeautySDK` facade — public host-facing API and stable error/result mapping.
3. `BeautyCore` — parameters, configuration, validation, diagnostics, metrics.
4. `BeautyDetection` — Vision detection, landmarks, tracking, coordinate mapping.
5. `BeautyRender` — Metal/Core Image contexts, texture caches, pixel buffer pools, render passes.
6. `BeautyEffects` — skin, color, filter, warp, feature effect construction.
7. `BeautyResources` — presets, LUTs, makeup/sticker manifests and validators.

### Critical Pitfalls

1. **Building effects before foundation** — prevent with package/facade/no-op/tests as first phases.
2. **Realtime `UIImage` conversion** — keep camera pipeline on sample buffers, pixel buffers, and textures.
3. **Coordinate and mirroring drift** — add canonical coordinate model and fixtures before geometry effects.
4. **Naturalness treated as polish** — build caps, presets, and visual checks into effect contracts.
5. **Unsafe resource loading** — version and validate all presets/LUTs/makeup/sticker resources.
6. **Late privacy work** — permission strings, redacted logging, and privacy manifest review must appear before relevant features are complete.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: SDK Foundation and Public Facade
**Rationale:** Everything depends on package shape, public API, validation, and tests.
**Delivers:** `BeautySDK` package targets, value models, typed errors, no-op `BeautyEngine`, initial tests.
**Addresses:** SDK facade, modular package, default no-op.
**Avoids:** Demo-only algorithms and untestable foundation.

### Phase 2: Demo Integration Shell
**Rationale:** The Demo must prove host-app integration without internal imports.
**Delivers:** SwiftUI shell organized into camera/image/parameters/presets/diagnostics areas; imports only `BeautySDK`.
**Addresses:** Rich Demo direction and integration realism.
**Avoids:** UI-first SDK coupling.

### Phase 3: Camera and Still-Image Processing Flow
**Rationale:** Realtime and still-image pipelines are table stakes and expose performance/privacy issues early.
**Delivers:** Camera permission UI, frame input, bounded processing, still-image input, orientation handling, compare/loading/error states.
**Uses:** AVFoundation, CoreVideo, CoreMedia, SwiftUI, SDK facade.

### Phase 4: Detection and Coordinate Foundation
**Rationale:** Geometry effects cannot be reliable without landmarks and coordinate contracts.
**Delivers:** Vision detection abstraction, face observations, landmarks, orientation/mirroring mappers, fixture tests.
**Implements:** `BeautyDetection` plus core coordinate models.

### Phase 5: RenderGraph, Resources, Filters, and Presets
**Rationale:** Visible effects need ordered rendering and validated resources.
**Delivers:** Metal/Core Image render foundation, color/filter controls, LUT/preset resource validation, built-in presets.
**Avoids:** Per-effect rendering islands and untrusted resources.

### Phase 6: Core Beauty Effects
**Rationale:** After detection/render/resources exist, implement the MVP value users expect.
**Delivers:** Skin smoothing/whitening/rosy/sharpen, face shape, eyes, nose, mouth, naturalness caps, no-face degradation.
**Addresses:** Product MVP from `PRODUCT_SENSE.md`.

### Phase 7: Rich Demo Experience and QA Surface
**Rationale:** The SDK needs a convincing Meitu/Xingtu-style validation surface.
**Delivers:** Bottom categories, sliders, preset-first flow, reset, compare, debug overlay, fixture-driven QA, disabled/unavailable states.
**Uses:** SDK facade only.

### Phase 8: Advanced Modules
**Rationale:** Advanced feature breadth should follow the stable MVP.
**Delivers:** Makeup, background/segmentation, multi-face, LUT packs, parameter import/export, and later video/body/stickers.
**Research flag:** Each advanced module should receive phase-level research before planning.

### Phase Ordering Rationale

- The order follows technical dependencies: package/API before integration, integration before input pipelines, input before detection, detection before geometry, render/resources before rich effects.
- The order prevents the most expensive reversals: coordinate rewrites, realtime pipeline rewrites, and public API churn.
- The Demo grows alongside the SDK but remains a consumer of public APIs, which keeps integration tests honest.

### Research Flags

Phases likely needing deeper research during planning:
- **Camera and Still-Image Processing:** AVFoundation frame delivery, orientation, and backpressure details.
- **Detection and Coordinates:** Vision landmarks, mirroring, fixture strategy.
- **RenderGraph and Effects:** Metal pass design, texture reuse, effect ordering.
- **Resources and Advanced Modules:** Manifest formats, LUT dimensions, makeup attachment, segmentation masks.
- **Video Export / Commercial Distribution:** Export pipeline, privacy manifests, packaging, and compatibility.

Phases with standard patterns:
- **SDK Foundation:** Swift Package, facade, value models, typed errors, no-op tests.
- **Demo Integration Shell:** SwiftUI app organization and public-facade import checks.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified against current repo facts and Apple platform docs. |
| Features | MEDIUM/HIGH | MVP is strongly defined by local docs; broader competitor parity should be validated per advanced module. |
| Architecture | HIGH | Root contracts and platform constraints align. |
| Pitfalls | HIGH | Pitfalls map directly to known iOS media, Vision, Metal, privacy, and SDK-boundary risks. |

**Overall confidence:** HIGH for roadmap foundation; MEDIUM for later advanced feature ordering.

### Gaps to Address

- **Visual quality benchmarks:** Need fixture images and acceptance thresholds during effect phases.
- **Device compatibility:** Current repo targets iOS 26.5; any lower target requires availability review.
- **Advanced makeup/body/style modules:** Need dedicated research before implementation.
- **Commercial SDK distribution:** Needs privacy manifest, package/binary strategy, and integration documentation later.

## Sources

### Primary (HIGH confidence)
- Apple Developer Documentation, `AVCaptureVideoDataOutput`: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput
- Apple Technical Note TN2445, Handling Frame Drops with `AVCaptureVideoDataOutput`: https://developer.apple.com/library/archive/technotes/tn2445/_index.html
- Apple Developer Documentation, `VNDetectFaceLandmarksRequest`: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest
- Apple Developer Documentation, Metal: https://developer.apple.com/documentation/metal
- Apple Developer Documentation, `CIColorCube`: https://developer.apple.com/documentation/coreimage/cicolorcube
- Apple Developer Documentation, PackageDescription / Swift Package Manager: https://developer.apple.com/documentation/PackageDescription
- Apple Developer Documentation, Observation: https://developer.apple.com/documentation/observation
- Apple Developer Documentation, privacy manifests for apps and third-party SDKs: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk
- Local root contracts: `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`.

### Secondary (MEDIUM confidence)
- Local `docs/01_product_feature_plan.md` and `docs/02_development_stages_full_plan.md` — broad feature and phase ambition.
- Local `.planning/codebase/*.md` — current brownfield implementation facts.

### Tertiary (LOW confidence)
- None used for core recommendations.

---
*Research completed: 2026-06-10*
*Ready for roadmap: yes*
