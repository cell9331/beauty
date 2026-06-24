# Milestones

## v1.0 MVP (Shipped: 2026-06-23)

**Delivered:** A modular local-first iOS `BeautySDK` plus a SwiftUI Demo validation app covering public facade integration, camera/still-image input, safe detection/degradation, resource-backed presets/filters, MVP beauty effects, and final Demo QA workflows.

**Phases completed:** 1-7 (28 plans, 62 recorded tasks)

**Key accomplishments:**

- Created a buildable Swift Package SDK with internal modules and a public `BeautySDK` facade used by host-style tests and the Demo.
- Implemented public parameters, typed errors, no-op defaults, direct pixel-buffer/image processing, orientation/mirroring metadata, and privacy-safe detection summaries.
- Added realtime camera and still-image Demo paths with bounded processing, local-first purpose strings, before/after compare, and facade-only import guardrails.
- Added bundled presets/resources, safe filter validation, MVP skin/color/face/eye/nose/mouth/lip behavior, conservative safety caps, and degradation evidence.
- Closed the rich Demo QA surface with preset/reset/source semantics, copy/paste parameter JSON, redacted debug overlay, disabled future states, full automated verification, and human UAT.

**Stats:**

- 7 phases, 28 plans, 62 recorded tasks
- About 13,266 Swift LOC across `BeautySDK` and `BeautyDemo`
- 232 tracked files changed since repository setup, 31,058 insertions, 105 deletions
- Timeline: 2026-05-25 to 2026-06-23

**Verification:**

- Milestone audit passed: 33/33 requirements, 7/7 phase verification files, 4/4 integration checks, 4/4 E2E flows, and 7/7 Nyquist-compliant validation files.
- SDK SwiftPM suite passed with 119 tests during milestone audit.
- Demo simulator XCTest suite passed on `iPhone 17, OS=26.5` during milestone audit.
- Phase 7 human UAT passed 4/4 visible SwiftUI checks.

**Known deferred items:** Release-like visual naturalness, real-device camera/Vision parity, screenshot/UI automation, performance budgets, long-run hardware readiness, and v2 advanced feature breadth are tracked in `PLANS.md` tech debt.

**Git range:** `da9f9e6` -> `v1.0`

**What's next:** Start a fresh milestone with `$gsd-new-milestone` and choose between release hardening, advanced beauty modules, creative modules, or distribution readiness.

---

## v1.1 Meitu UI (Implemented: 2026-06-24)

**Delivered:** A Meitu-style SwiftUI Demo shell with Home first screen, Home-to-editor routing, and a Meitu-style editor tool panel while preserving the existing local-first `BeautySDK` facade, camera/photo pipelines, compare/debug/JSON behavior, and honest unavailable states.

**Phases completed:** 8-10 (11 plans)

**Key accomplishments:**

- Added the dark Meitu-style Home first screen with film hero, search/brand/VIP chrome, `拍一拍`, primary actions, paged tool grid, recommendation rails, floating bottom tabs, and sticky shortcut rail.
- Added the Meitu-style editor panel with black preview area, white bottom panel, `背景保护`, shared intensity slider, `整体`, cancel/confirm, first-level category order, second-level tool rails, and static `限免` / `Pro` / `OFF` badge treatment.
- Routed `图片美化`, `相机`, `拍一拍`, and `人像美容` into the existing local photo/camera/editor paths.
- Kept unsupported Meitu/VIP/AI/Pro/video/body/makeup-like capabilities disabled/static rather than fake-functional.
- Captured screenshot evidence for Home first screen, Home sticky state, and editor tool panel under `.planning/evidence/v1.1/`.

**Verification:**

- Focused `BeautyDemoViewStateTests` passed.
- Full Demo simulator tests passed on `iPhone 17, OS=26.5`.
- Full SDK SwiftPM suite passed with 119 tests.
- Demo facade import scan returned no internal SDK target imports.

**Known deferred items:** Exact commercial asset parity, full `图库` / `AI 修图` / `我` tabs, network AI tools, real video editing, new SDK algorithm families, hardware QA, performance budgets, and long-run release-hardening remain future scope.

**Git commit:** `8274754`

**What's next:** v1.2 should create static HTML references for the two Meitu surfaces before further SwiftUI fidelity tuning.

---
