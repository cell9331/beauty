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
