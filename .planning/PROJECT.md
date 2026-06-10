# Beauty

## What This Is

`beauty` is a modular iOS beauty SDK with a rich Demo app that exercises the SDK through public APIs. The SDK owns image/frame processing, parameters, detection, rendering, effects, resources, diagnostics, and the host-facing facade; the Demo app shows these capabilities in a Meitu/Xingtu-style editing experience with camera preview, still-image editing, presets, sliders, compare states, and feature categories.

This is not a standalone consumer app as the primary product. The Demo should feel complete enough to validate the modules, but reusable SDK boundaries are the product center.

## Core Value

An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## Requirements

### Validated

- ✓ The repository has a buildable iOS app target and scheme named `BeautyDemo` — existing.
- ✓ `BeautyDemo` currently launches a minimal SwiftUI app shell — existing.
- ✓ The codebase has root contracts for architecture, design, frontend, security, reliability, product sense, and quality scoring — existing.
- ✓ The codebase has a current GSD codebase map in `.planning/codebase/` — existing.
- ✓ Historical product docs already describe a Meitu/Xingtu-style beauty capability set covering skin, face shape, facial features, makeup, filters, segmentation, presets, and video-oriented expansion — existing.

### Active

- [ ] Create a modular `BeautySDK` Swift Package with internal targets for core models, detection, rendering, effects, resources, diagnostics, and the public facade.
- [ ] Provide public SDK APIs through `BeautySDK` only, including `BeautyEngine`, `BeautyConfiguration`, `BeautyParameters`, `BeautyPreset`, `BeautyResult`, and `BeautyError`.
- [ ] Build the no-op processing foundation first so camera frames and still images can flow through the SDK without changing visual output.
- [ ] Add real-time camera preview support with explicit orientation, bounded frame processing, responsive UI, and no real-time `UIImage` conversion.
- [ ] Add still-image processing support with orientation normalization, quality mode, loading/error states, and before/after compare behavior.
- [ ] Implement the MVP effect domains: skin beauty, face shape, eyes, nose, mouth, filters, and presets.
- [ ] Grow the Demo into a complete SDK showcase with bottom categories for beauty, face shape, facial features, makeup, filters, stickers, background, and style.
- [ ] Keep Demo usage routed through the public `BeautySDK` facade; Demo must not import internal SDK targets.
- [ ] Add automated tests for value models, normalization, validation, presets, no-op processing, public facade imports, and Demo mapping behavior.
- [ ] Add privacy, permission, diagnostics, error, and degradation behavior before camera/photo features are treated as complete.

### Out of Scope

- A separate consumer App Store product is out of scope for this initialization — the Demo is an SDK validation app, not the primary product.
- Demo direct imports of `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` are out of scope — this preserves SDK integration realism.
- Cloud upload of images, video, landmarks, presets, metrics, or diagnostics is out of scope by default — privacy posture is local-first.
- Building every Meitu/Xingtu-class feature before the SDK foundation is stable is out of scope — advanced makeup, segmentation, body shaping, stickers, AI style, and video export come after the core pipeline.
- Treating ignored `.worktrees/` content as shipped main-worktree implementation is out of scope — only tracked main-worktree code counts as delivered.
- Third-party beauty SDKs as the core implementation are out of scope unless explicitly approved later — default direction is Apple frameworks plus local Swift/Metal code.

## Context

Current main-worktree code is much smaller than the product vision. `BeautyDemo` contains the only buildable target, and its SwiftUI view still shows the default template content. There is no `BeautySDK/Package.swift`, no SDK source targets, no tests, no camera pipeline, no Metal render pipeline, no Vision integration code, and no privacy manifest yet.

The root contract documents define the intended shape of the system:

- `ARCHITECTURE.md` defines a modular Swift Package named `BeautySDK` with internal targets and a public facade.
- `DESIGN.md` defines the future parameter, preset, frame, result, detection, coordinate, render graph, and state-machine contracts.
- `FRONTEND.md` defines the Demo app as an integration and validation surface, not SDK internals.
- `SECURITY.md` defines local-first processing, protected-resource permission requirements, untrusted resource validation, and log redaction.
- `RELIABILITY.md` defines typed errors, degradation, backpressure, metrics, and performance expectations.
- `PRODUCT_SENSE.md` defines the MVP experience: realtime camera, still-image editing, presets, skin, face, eyes, nose, mouth, filters, compare behavior, and safe degradation.

`docs/01_product_feature_plan.md` contains the broad product ambition: a beauty SDK whose Demo or host UI can resemble Meitu Xiuxiu, Qingyan Camera, or Xingtu. It covers skin smoothing, whitening, rosy tone, blemish repair, face reshaping, eyes, nose, mouth, eyebrows, hairline, makeup, filters, body shaping, portrait segmentation, background effects, stickers, style effects, presets, multi-face handling, parameter import/export, realtime video, and still-image processing.

The user's direction for initialization is: keep the product as an SDK, split it into modules, and use those modules from the Demo app to demonstrate the rich feature set.

## Constraints

- **SDK boundary**: SDK targets must not contain SwiftUI or UIKit pages; UI stays in `BeautyDemo` or host apps.
- **Demo dependency**: Demo uses `BeautySDK` public APIs and must not import internal SDK targets.
- **Implementation order**: Build the foundation and no-op processing path before piling on advanced effects.
- **Naturalness**: Effects should prioritize plausible output over maximum intensity; safety caps are part of the product contract.
- **Realtime performance**: Camera processing must avoid unbounded queues and avoid realtime `UIImage` conversion.
- **Privacy**: Default behavior is no upload, no raw-frame persistence, no landmark persistence, and no sensitive path logging.
- **Permissions**: Camera/photo prompts are App-owned; SDK APIs must not trigger protected-resource prompts by themselves.
- **Resource trust**: Presets, LUTs, makeup packs, stickers, and future resource bundles are untrusted unless bundled, versioned, and validated.
- **Toolchain**: Current observed environment is Xcode 26.5 with an iOS deployment target of 26.5; explicit iOS Simulator destinations are required for reliable `xcodebuild` evidence.
- **Current state**: Existing source is a Demo shell; future plans must not assume SDK implementation already exists.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Product remains an SDK, not a standalone consumer app. | The user chose `SDK + complete Demo`; root contracts already define SDK boundaries. | — Pending |
| Demo should become a rich Meitu/Xingtu-style showcase. | The existing product docs already describe the rich feature set, and the Demo is the right place to validate user-facing controls. | — Pending |
| Demo uses modules only through the `BeautySDK` facade. | Direct internal imports would make the Demo unrealistic as a host-app integration example. | — Pending |
| MVP starts with foundation, camera/still-image flow, presets, filters, and core face/skin controls. | Full feature breadth depends on detection, rendering, resource, privacy, reliability, and test foundations. | — Pending |
| Advanced makeup, segmentation, body shaping, stickers, AI style, and video export are staged later. | These features are valuable but would destabilize the first SDK milestone if treated as foundation work. | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-10 after initialization*
