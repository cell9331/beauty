# Beauty

## What This Is

`beauty` is a modular local-first iOS beauty SDK with a rich SwiftUI Demo app that exercises the SDK through public APIs. The SDK owns image/frame processing, parameters, detection, rendering, effects, resources, diagnostics, and the host-facing `BeautySDK` facade. The Demo app validates these capabilities through a Meitu/Xingtu-style editing surface with camera preview, still-image editing, presets, sliders, before/after compare, debug overlay state, disabled future categories, and parameter JSON import/export.

This is not a standalone consumer App Store product as the primary product. The Demo is complete enough to validate SDK behavior, while reusable SDK boundaries remain the product center.

## Core Value

An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## Current State

**Shipped version:** v1.0 MVP on 2026-06-23.

**Implementation state:** v1.0 includes a Swift Package SDK, public facade models and engine, realtime camera and still-image Demo paths, orientation/mirroring metadata, face detection/degradation summaries, resource-backed filters/presets, visible MVP skin/color/face/eye/nose/mouth effects, deterministic tests, copy/paste parameter JSON, compare state, and redacted debug overlay evidence.

**Verification state:** The v1.0 milestone audit passed with 33/33 v1 requirements satisfied, 7/7 phase verification files present, 4/4 integration checks, 4/4 E2E flows, and 7/7 Nyquist-compliant validation files.

**Code size:** `BeautySDK` and `BeautyDemo` contain about 13,266 Swift lines at v1.0 close.

## Requirements

### Validated

- SDK package and public facade boundaries - v1.0.
- Public SDK value models, 31 normalized parameters, typed errors, clamping, preset validation, and no-op defaults - v1.0.
- Direct pixel-buffer and still-image processing paths with SDK-created outputs and default no-op behavior - v1.0.
- Demo-only protected-resource UX with camera and photo purpose strings - v1.0.
- Realtime camera path with BGRA frames, bounded in-flight work, stale-frame replacement, and no realtime `UIImage` conversion - v1.0.
- Still-image input, loading/error preservation, and before/after compare state - v1.0.
- Orientation, mirroring, detection summaries, no-face/partial-face degradation, and privacy-safe metadata - v1.0.
- Bundled resource catalog, five built-in presets, metadata-only filters, and public resource validation facade - v1.0.
- MVP beauty effects for skin, color/filter, face shape, eyes, nose, mouth, and lip color with conservative caps and degradation - v1.0.
- Rich Demo QA surface with preset/reset/source semantics, parameter JSON import/export, read-only debug overlay, disabled future categories, and final UAT evidence - v1.0.

### Active

- [ ] Define the next milestone with `$gsd-new-milestone`.
- [ ] Decide whether next work prioritizes release hardening, advanced beauty modules, creative modules, or distribution readiness.

### Out of Scope

- Standalone consumer App Store product - still out of scope; Demo remains an SDK validation app.
- Demo direct imports of `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` - still out of scope; Demo must stay facade-only.
- Cloud upload or network processing by default - still out of scope; privacy posture remains local-first.
- Full Meitu/Xingtu feature parity in v1 - validated as deferred to future milestones.
- Treating ignored `.worktrees/` content as shipped main-worktree implementation - still out of scope.
- Third-party beauty SDK as the core implementation - still out of scope unless explicitly approved later.
- Camera/photo permission prompts from SDK internals - still out of scope; host app or Demo owns protected-resource UX.

## Next Milestone Goals

No next milestone has been selected yet. Strong candidates:

- **Release Hardening:** physical iPhone camera/Vision QA, front-camera mirroring smoke, screenshot/UI automation, 720p timing budget, long-run memory/thermal checks, production render regression, and privacy manifest review.
- **Advanced Beauty:** makeup templates/components, skin repair, eyebrows/teeth/hairline/forehead, multi-face handling, and richer preset/resource packs.
- **Distribution:** SDK packaging, compatibility matrix, binary distribution, resource-pack trust model, and commercial integration docs.

## Context

Root contracts remain authoritative for current behavior and future boundaries:

- `ARCHITECTURE.md` owns package/module boundaries and dependency direction.
- `DESIGN.md` owns parameters, presets, metadata, detection summaries, effect planning, and state-machine contracts.
- `FRONTEND.md` owns SwiftUI Demo behavior and app-side state.
- `SECURITY.md` owns local-first privacy, input/resource trust, and redaction.
- `RELIABILITY.md` owns typed errors, degradation, metrics, backpressure, and performance risk.
- `PRODUCT_SENSE.md` owns user journeys and acceptance criteria.
- `QUALITY_SCORE.md` owns coverage and quality scoring.

Historical milestone detail is archived in:

- `.planning/milestones/v1.0-ROADMAP.md`
- `.planning/milestones/v1.0-REQUIREMENTS.md`
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md`

## Constraints

- **SDK boundary:** SDK targets must not contain SwiftUI or UIKit pages; UI stays in `BeautyDemo` or host apps.
- **Demo dependency:** Demo uses `BeautySDK` public APIs and must not import internal SDK targets.
- **Implementation order:** New advanced effects should build on existing detection/render/resource/degradation seams rather than bypassing them.
- **Naturalness:** Effects prioritize plausible output over maximum intensity; safety caps remain part of the product contract.
- **Realtime performance:** Camera processing must avoid unbounded queues and avoid realtime `UIImage` conversion.
- **Privacy:** Default behavior is no upload, no raw-frame persistence, no landmark persistence, and no sensitive path logging.
- **Permissions:** Camera/photo prompts are app-owned; SDK APIs must not trigger protected-resource prompts by themselves.
- **Resource trust:** Presets, LUTs, makeup packs, stickers, and future resource bundles are untrusted unless bundled, versioned, and validated.
- **Toolchain:** Current observed environment is Xcode 26.5 with explicit iOS Simulator destinations required for reliable `xcodebuild` evidence.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Product remains an SDK, not a standalone consumer app. | The user chose SDK plus complete Demo; v1 shipped reusable SDK boundaries and a validation Demo. | Good |
| Demo should become a rich Meitu/Xingtu-style showcase. | v1 validated a broad Demo surface without making the Demo the primary product. | Good |
| Demo uses modules only through the `BeautySDK` facade. | Facade-only Demo imports keep host integration realistic and are covered by tests/scans. | Good |
| MVP starts with foundation, camera/still-image flow, presets, filters, and core face/skin controls. | This sequence let tests and privacy/reliability contracts grow before richer effects. | Good |
| Advanced makeup, segmentation, body shaping, stickers, AI style, and video export are staged later. | v1 shipped the core pipeline and left higher-breadth features as explicit future milestone candidates. | Good |
| Release-like claims require separate hardware, visual, performance, and long-run evidence. | v1 automation proves correctness and safety, not production naturalness or device endurance. | Revisit in next milestone |

## Evolution

This document evolves at phase transitions and milestone boundaries.

---
*Last updated: 2026-06-23 after v1.0 milestone*
