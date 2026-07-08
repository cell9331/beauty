# Milestones

## v1.5 SDK Geometry Output Foundation and Face Shape Slice (Shipped: 2026-07-08)

**Delivered:** SDK-only geometry output foundation plus the first verified `脸型` existing-parameter slice through public-facade renderer evidence, safety/degradation tests, and scoped blueprint ledger promotion.

**Post-ship validation correction (2026-07-08):** User visual verification found the original saved-output evidence could pass from a global geometry proxy without visible face-shape deformation. The still-image CIImage path now performs local control-point warp, and `BeautyGeometryEffectPipelineTests/testCIImageGeometryWarpMovesLocalPixelsWithoutGlobalColorBias` rejects global color-only evidence by checking local pixel movement and unchanged unaffected pixels.

**Phases completed:** 26-28 (3 phases, 12 plans, 22 recorded tasks)

**Key accomplishments:**

- Added package-internal selected-face observation routing from public still-image facade detection into existing internal geometry planning while keeping raw landmarks and control points private.
- Produced deterministic saved-output geometry evidence through `BeautyExampleRenderer`, including `geometryBaseline_noop`, `faceShapeCombo_0p35`, a no-face fixture, 66 ignored PNG outputs, and the Phase 27 helper.
- Completed per-tool public-facade renderer evidence for `faceSlim`, `faceSmall`, signed `chinLength`, `faceVShape`, and `jawSlim`, with 102 ignored outputs, 30/30 top-region comparisons, and post-ship spatial-warp regression coverage.
- Strengthened focused safety/degradation/redaction tests for caps, no-face/missing-contour behavior, signed `chinLength`, combined weakening, raw-geometry leak prevention, and `jawSlim` alias evidence.
- Promoted exactly six scoped `脸型` rows in `SHAPE_FEATURE_LEDGER.md`: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`.
- Passed the v1.5 milestone audit with 13/13 requirements, 3/3 phases, 4/4 integration checks, 4/4 end-to-end flows, and 3/3 Nyquist validation files.

**Stats:**

- 3 phases, 12 plans, 22 recorded tasks
- 13/13 v1.5 requirements complete
- `BeautySDK` and `BeautyDemo` contain 17,794 Swift lines in the local count, including build-derived `.build` files observed during closeout

**Verification:**

- Milestone audit passed: 13/13 requirements, 3/3 phases, 4/4 integration checks, 4/4 flows, and 3/3 Nyquist validation files.
- Phase 28 full SDK suite passed with 171 tests.
- Post-correction full SDK suite passed with 172 tests, including the spatial-warp regression.
- `BeautyExampleRenderer` built and wrote 102 ignored PNG outputs across 6 fixtures and 17 cases.
- Phase 28 helper passed with 102/102 outputs and 30/30 portrait top-region comparisons.

**Known limitations:** v1.5 is SDK-core only. It does not claim Demo UI work, physical-device parity, commercial visual review, screenshot reruns, optimized profiling, packaging readiness, launch readiness, broader `美型 / 五官` branch completion, full Meitu parity, or whole-branch `脸型` completion.

**Archives:**

- `.planning/milestones/v1.5-ROADMAP.md`
- `.planning/milestones/v1.5-REQUIREMENTS.md`
- `.planning/milestones/v1.5-MILESTONE-AUDIT.md`

**What's next:** Start a fresh milestone with `$gsd-new-milestone`.

---

## v1.4 Stability, QA, and Debt Cleanup (Shipped: 2026-07-03)

**Delivered:** A hardening and debt-cleanup milestone that turned post-v1.3 release risks into evidence-backed gates for baseline quality, Demo visual QA, performance/reliability, renderer output regression, privacy/resource trust, and traceability closeout.

**Phases completed:** 21-25 (5 phases, 15 plans, 34 recorded tasks)

**Key accomplishments:**

- Established a current v1.4 quality baseline with passing SDK/renderer checks, explicit Demo screenshot/tooling blockers, debt routing, and synchronized quality ledgers.
- Preserved Demo QA honesty by recording exact iPhone 17 build/test commands, no-PNG screenshot status, blocked per-state review notes, and route/model disabled-honesty evidence.
- Added performance and reliability evidence for 720p timing, backpressure, reset, degradation, quality mode, safety caps, redacted metrics, and focused Demo camera pipeline behavior.
- Hardened renderer output regression with a public-facade case inventory test, exact pre-watermark no-op fixture checks, a 45-output invariant helper, and durable example-image validation docs.
- Completed privacy, active-source security, and bundled-resource trust review while keeping `PrivacyInfo.xcprivacy`, external packages, hardware, long-run, and commercial packaging claims scoped to future triggers.
- Passed the v1.4 milestone audit with 24/24 requirements, 5/5 phases, 5/5 integration checks, 5/5 end-to-end flows, and 5/5 Nyquist validation files.

**Stats:**

- 5 phases, 15 plans, 34 recorded tasks
- About 15,844 Swift source/test LOC across `BeautySDK` and `BeautyDemo`
- 93 commits from `v1.3` to the Phase 25 closeout head before archival
- Git range before archival: `v1.3` -> `a1017d4`

**Verification:**

- Milestone audit passed: 24/24 requirements, 5/5 phases, 5/5 integration checks, 5/5 flows, and 5/5 Nyquist validation files.
- `swift test --package-path BeautySDK` passed with 150 tests during Phase 24/25 closeout evidence.
- Focused Demo privacy/import simulator tests passed with 17 tests on `platform=iOS Simulator,name=iPhone 17,OS=26.5` during Phase 25 closeout.
- `BeautyExampleRenderer` built and regenerated 45 ignored same-dimension skin/color/filter outputs; the Phase 24 helper verified all 45 outputs.

**Known limitations:** v1.4 is a current-evidence hardening milestone, not commercial release approval. Current screenshot PNG capture, physical-device parity, 600-second preview endurance, optimized profiling, geometry saved-output completion, external package integrity, live Apple required-reason documentation review, and commercial packaging checks remain future or setup-specific work.

**Archives:**

- `.planning/milestones/v1.4-ROADMAP.md`
- `.planning/milestones/v1.4-REQUIREMENTS.md`
- `.planning/milestones/v1.4-MILESTONE-AUDIT.md`

**What's next:** Start a fresh milestone with `$gsd-new-milestone`.

---

## v1.3 Meitu Core Beauty Module Design and Implementation (Shipped: 2026-06-30)

**Delivered:** A no-new-UI core beauty module milestone: executable example-image validation, normalized core beauty module contracts, Basic skin evidence, beauty-shaping provider/resolver evidence, and editor-shell ownership closeout behind the public `BeautySDK` facade.

**Phases completed:** 16-20 (5 phases, 14 plans, 35 recorded tasks)

**Key accomplishments:**

- Added and verified `BeautyExampleRenderer` as a public-facade validation harness that writes same-dimension, watermarked, ignored local outputs from `example-images/input/`.
- Normalized `docs/meitu-function-blueprint/` into the current authority for core beauty status, module ownership, Demo-vs-SDK boundaries, and deferred product areas.
- Improved and verified Basic skin behavior through focused tests, renderer output cases, dimension checks, and factual visual observations.
- Hardened beauty-shaping provider/resolver/degradation/redaction evidence for the existing public shaping fields without adding public parameters or renderer geometry cases.
- Closed editor-shell support as Demo-owned app-side behavior and recorded no-new-UI, facade-only, public-parameter, renderer-scope, and sensitive-string scans.
- Preserved geometry-heavy saved-image output and release-hardening QA as explicit future limitations.

**Verification:**

- Milestone audit passed: 20/20 requirements, 5/5 phases, 6/6 integration checks, 4/4 flows, and 5/5 validation files.
- `swift test --package-path BeautySDK` passed with 141 tests and 0 failures during Phase 20 closeout.
- `BeautyExampleRenderer` built and ran all nine current skin/color/filter cases, producing 45 ignored same-dimension PNG outputs.
- Demo/renderer facade-only scans, SDK non-UI SwiftUI/UIKit scans, public `BeautyParameters` 31-field inventory checks, and renderer geometry-case negative scans passed.

**Known limitations:** Geometry-heavy saved-image output remains deferred until public facade detection plus geometry rendering produces watermarked same-dimension outputs. Release-hardening QA, real-device camera/Vision parity, production naturalness review, screenshot/UI automation, performance budgets, memory/thermal checks, privacy manifest review, and automated visual diffs remain future scope.

**Archives:**

- `.planning/milestones/v1.3-ROADMAP.md`
- `.planning/milestones/v1.3-REQUIREMENTS.md`
- `.planning/milestones/v1.3-MILESTONE-AUDIT.md`

**What's next:** Start a fresh milestone with `$gsd-new-milestone`.

---

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
