# Beauty

## What This Is

`beauty` is a modular local-first iOS beauty SDK with a rich SwiftUI Demo app that exercises the SDK through public APIs. The SDK owns image/frame processing, parameters, detection, rendering, effects, resources, diagnostics, and the host-facing `BeautySDK` facade. The Demo app validates these capabilities through a Meitu/Xingtu-style editing surface with camera preview, still-image editing, presets, sliders, before/after compare, debug overlay state, disabled future categories, and parameter JSON import/export.

This is not a standalone consumer App Store product as the primary product. The Demo is complete enough to validate SDK behavior, while reusable SDK boundaries remain the product center.

## Core Value

An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## Current State

**Shipped version:** v1.5 SDK Geometry Output Foundation and Face Shape Slice on 2026-07-08.
**Latest completed UI milestone:** v1.1 Meitu UI on 2026-06-24.
**Current milestone:** v1.6 Broader `美型 / 五官` SDK Slice - Eyes.

**Implementation state:** v1.5 completes SDK-only geometry output foundation and the first verified `脸型` existing-parameter slice. Public still-image processing can activate geometry-triggered detection through `BeautyEngine.processResult(...)`, route one selected face into package-internal geometry planning, produce deterministic saved-output geometry evidence through `BeautyExampleRenderer`, and verify scoped face-shape tools through existing public parameters. Current SDK/Demo behavior remains local-first, facade-only from the Demo, and no-network by default.

**Verification state:** The v1.5 milestone audit passed with 13/13 requirements, 3/3 phases, 4/4 integration checks, 4/4 flows, and 3/3 Nyquist validation files. Phase 28 closeout evidence includes full `swift test --package-path BeautySDK` with 171 tests, `BeautyExampleRenderer` build/run evidence with 102 ignored outputs, `check_face_shape_renderer_outputs.py` passing with 102/102 outputs and 30/30 top-region comparisons, plus public/import boundary, hidden-surface, raw-leak, overclaim, ledger, and Demo import scans.

**Archived v1.5 baseline:** Phase 26 records public facade geometry activation and privacy-safe routing; Phase 27 records deterministic saved-output geometry evidence and degradation verification; Phase 28 records scoped `脸型` per-tool renderer evidence, safety/degradation/redaction tests, and ledger/documentation closeout. Remaining broader `美型 / 五官` slices, screenshot reruns, physical iPhone checks, 600-second preview, optimized profiling, packaging review, commercial visual review, and launch readiness stay future or setup-specific work, not v1.5 blockers. Stale `.planning/codebase/*` maps are background only until a formal remap is scoped.

**Code size:** `BeautySDK` and `BeautyDemo` contain 17,794 Swift lines in the local closeout count, including build-derived `.build` files observed during v1.5 archive.

## Current Milestone: v1.6 Broader `美型 / 五官` SDK Slice - Eyes

**Goal:** Extend the v1.5 geometry-output foundation to complete the existing-parameter `眼睛` SDK slice through public-facade saved-output evidence, safety/degradation tests, and scoped ledger promotion.

**Target features:**

- Eye renderer evidence: `BeautyExampleRenderer` should add public-facade cases for existing public eye parameters `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift`.
- Eye output helper evidence: generated outputs should stay same-dimension, remain ignored, and differ from `geometryBaseline_noop` above the watermark band on usable portrait fixtures.
- Eye safety evidence: focused tests should cover caps, no-face and missing-eye-landmark degradation, combined weakening, redacted summaries/metrics, and no raw geometry leakage.
- Scoped documentation closeout: promote only the mapped `眼睛` ledger rows backed by existing public parameters, keep branch-level `眼睛` partial, and avoid Demo UI, public API expansion, commercial/device/release-readiness, or broad Meitu parity claims.

**Key context:** v1.6 is SDK-core only and continues the Phase 26-28 architecture. It should not add SwiftUI screens, new public parameters, new account/commercial behavior, remote processing, hidden network behavior, or unscoped `眼睛` tools such as eye height, length, pupil, gaze, lid, redness, corners, or symmetry.

## Last Completed Milestone: v1.5 SDK Geometry Output Foundation and Face Shape Slice

**Status:** Shipped and archived as of 2026-07-08.

**Goal:** Make the existing `BeautySDK` public facade capable of producing verifiable SDK-only geometry output, then complete the first `美型 / 五官` slice for the `脸型` tools that already have public parameters.

**Target features:**

- Public-facade geometry output foundation: `BeautyEngine.processResult(...)`, detection/landmark routing, geometry render integration, and `BeautyExampleRenderer` or equivalent SDK-only saved-output evidence work together for geometry effects.
- `脸型` SDK slice: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and `下颌线` are implemented only when their existing product-neutral parameters have tests, safety/degradation coverage, and facade-visible output evidence.
- Documentation-led completion: `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, the beauty-shaping branch README, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, and phase verification evidence are updated when completion status changes.

**Key context:** v1.5 is SDK-core only. It does not add SwiftUI screens, Demo tool-panel work, new account/commercial behavior, remote processing, hidden network behavior, commercial visual approval, packaging readiness, or broad Meitu feature parity. `眼睛`, `嘴唇`, `鼻子`, `比例`, `3D塑颜`, and `眉毛` remain future/partial unless explicitly promoted by a later milestone or phase.

## Previous Completed Milestone: v1.4 Stability, QA, and Debt Cleanup

**Status:** Shipped and archived as of 2026-07-03.

**Goal:** Convert known post-v1.3 release-hardening risks into measurable quality gates, fix high-value technical debt, and improve existing reliability without expanding product scope.

**Delivered:**

- Baseline audit of quality scores, root contracts, `.planning` state, and open technical debt.
- Automated Demo QA evidence through simulator UI/screenshot checks, layout sweeps, or documented equivalent evidence. Phase 22 completed the documented-equivalent blocker path on 2026-07-01.
- Performance and long-run reliability gates for realtime 720p timing, dropped-frame behavior, quality modes, memory growth, and reset/degradation paths. Phase 23 completed the evidence-gate path on 2026-07-02 while keeping 600-second preview and physical iPhone checks explicit as blocked or not run.
- Renderer and example-output regression coverage for no-op tolerance, visible output, dimension/watermark stability, and geometry-output boundaries.
- Security and distribution cleanup for privacy manifest assessment, log/metric redaction, resource trust checks, and current documentation sync. Phase 25 completed this as current-evidence closeout without adding product scope or packaging claims.

**Key context:** v1.4 is archived as a current-evidence hardening milestone. It did not add product-family breadth, public parameter fields, Meitu surface breadth, remote-processing behavior, paid-account flows, or broad UI redesign. Phase directories remain in `.planning/phases/` by operator choice; milestone archives live under `.planning/milestones/`.

## Previous Completed Milestone: v1.3 Meitu Core Beauty Module Design and Implementation

**Status:** Shipped and archived as of 2026-06-30.

**Goal:** Reference the Meitu Xiuxiu beauty editor, clarify the core beauty module system, and implement SDK-level core beauty logic without adding new SwiftUI screens.

**Target features:**

- Local mind map and feature matrix for core Meitu-style beauty functions.
- A code-level example-image validation harness that loads `example-images/input/`, runs the public `BeautySDK` facade, and saves watermarked outputs to `example-images/out/`.
- Branch folders for `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`, basic skin, skin repair, and teeth/hairline.
- Minimal editor support documentation for input routing, preview chrome, bottom panel, and commit flow.
- Module boundary documentation mapping each core beauty branch to Demo and SDK ownership.
- Implementation and tests for promoted core beauty branches, with explicit status for visible image-output coverage.
- Explicit exclusions for Home/discovery, filters/makeup/stickers/templates, AI/background, video/body, gallery/account, search, premium access, commerce, and account authorization surfaces.

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

### Completed in v1.1

- [x] Rebuild the Demo first screen to match `meituxiuxiu/HOME_MAP.md`.
- [x] Rebuild the Demo edit surface to match `meituxiuxiu/FUNCTION_MAP.md`.
- [x] Connect supported Home and Editor interactions to existing local-first camera, photo, compare, parameter, and SDK processing behavior.
- [x] Keep unavailable Meitu reference capabilities honest through disabled/static states instead of fake working features.

### Completed in v1.2

- [x] Create local static HTML references for the Home and Editor surfaces before changing SwiftUI.
- [x] Capture browser screenshots of the HTML references under documented `390x844` framing.

### Canceled in v1.2

- [x] Canceled: capture current SwiftUI comparison screenshots for the HTML delta workflow.
- [x] Canceled: write a visual delta report and SwiftUI token/component mapping.
- [x] Canceled: optimize SwiftUI Home and Editor from the approved HTML baselines.
- [x] Canceled: run the v1.2 SwiftUI fidelity closeout; existing Phase 11 HTML offline evidence remains valid.

### Completed in v1.3

- [x] Prepare the code-level example-image validation harness before starting feature implementation.
- [x] Document and keep current the core beauty taxonomy and mind map under `docs/meitu-function-blueprint/`.
- [x] Design and implement promoted beauty-shaping branch module logic behind SDK boundaries.
- [x] Design and implement promoted skin-retouch branch module logic behind SDK boundaries.
- [x] Verify promoted branches through unit/integration tests and saved example-image outputs when visible rendering is available.

Phase 20 closeout evidence is recorded in `.planning/phases/20-core-module-closeout/20-VERIFICATION.md`: `swift test --package-path BeautySDK` passed with 141 tests, `BeautyExampleRenderer` built and ran all current skin/color/filter cases, 45 ignored outputs were non-empty and same-dimension, Demo imports remained facade-only, SDK non-UI targets remained SwiftUI/UIKit-free, and the public `BeautyParameters` inventory stayed at the existing 31 fields.

v1.3 remains a no-new-UI core module milestone. Phase 20 added no new SwiftUI screens, public parameters, renderer cases, or geometry saved-image output. Geometry-heavy branches remain partial or `blocked-by-geometry-output`; geometry saved-image output is deferred until public facade detection plus geometry rendering can produce watermarked same-dimension saved outputs. Release-hardening QA remains future work.

### Completed in v1.4

- [x] Baseline audit and quality ledger refresh - Phase 21.
- [x] Automated Demo QA and screenshot evidence through blocker-honest records - Phase 22.
- [x] Performance and reliability gates with SDK timing, Demo backpressure, reset/degradation, redaction, evidence ledger, and validation closeout - Phase 23.
- [x] Renderer output regression hardening with current matrix, no-op fixture checks, generated-output invariants, and geometry boundary honesty - Phase 24.
- [x] Security, distribution review, and closeout with privacy manifest disposition, active security scans, bundled-resource trust evidence, and 100% v1.4 traceability - Phase 25.

### Completed in v1.5

- [x] Build SDK-only geometry saved-output support through the public `BeautySDK` facade.
- [x] Complete the `脸型` existing-parameter slice without adding UI scope.
- [x] Keep the `美型 / 五官` ledger as the authority for second-level status changes.

### Active in v1.6

- [ ] Complete the existing-parameter `眼睛` SDK slice without adding UI scope or public parameters.
- [ ] Add public-facade saved-output renderer/helper evidence for `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift`.
- [ ] Add focused safety, degradation, redaction, and boundary evidence for the `眼睛` slice.
- [ ] Promote only evidence-backed second-level `眼睛` rows in `SHAPE_FEATURE_LEDGER.md`; keep branch-level `眼睛` partial.

### Out of Scope

- Standalone consumer App Store product - still out of scope; Demo remains an SDK validation app.
- Demo direct imports of `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` - still out of scope; Demo must stay facade-only.
- Cloud upload or network processing by default - still out of scope; privacy posture remains local-first.
- Full Meitu/Xingtu feature parity in v1 - validated as deferred to future milestones.
- Home/discovery, filters/makeup/stickers/templates, AI/background, video/body, gallery/account, search, premium access, commerce, and account authorization planning - out of v1.3 because the user narrowed this milestone to core beauty only.
- Treating ignored `.worktrees/` content as shipped main-worktree implementation - still out of scope.
- Third-party beauty SDK as the core implementation - still out of scope unless explicitly approved later.
- Camera/photo permission prompts from SDK internals - still out of scope; host app or Demo owns protected-resource UX.

## Next Milestone Goals

Future milestone candidates after v1.6:

- **Broader `美型 / 五官` slices:** `鼻子`, `嘴唇`, `比例`, `3D塑颜`, and `眉毛` remain future or partial until explicitly scoped.
- **Remaining `眼睛` tools:** eye height, eye length, pupil/gaze, lid, redness, corner, and symmetry features need separate parameter/resource design before implementation.
- **Deferred Meitu Product Areas:** Home/discovery, style resources, AI/background, video/body, gallery/account, search, premium access, commerce, and account authorization planning.
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
- `.planning/milestones/v1.3-ROADMAP.md`
- `.planning/milestones/v1.3-REQUIREMENTS.md`
- `.planning/milestones/v1.3-MILESTONE-AUDIT.md`
- `.planning/milestones/v1.4-ROADMAP.md`
- `.planning/milestones/v1.4-REQUIREMENTS.md`
- `.planning/milestones/v1.4-MILESTONE-AUDIT.md`
- `.planning/milestones/v1.5-ROADMAP.md`
- `.planning/milestones/v1.5-REQUIREMENTS.md`
- `.planning/milestones/v1.5-MILESTONE-AUDIT.md`

Current visual reference contracts:

- `meituxiuxiu/HOME_MAP.md` owns the Home screen reference structure and scroll behavior.
- `meituxiuxiu/FUNCTION_MAP.md` owns the Editor `美型 / 五官` tool-panel taxonomy and visual behavior.
- v1.2 HTML baselines live under `meituxiuxiu/html/` as retained reference artifacts.
- v1.2 evidence lives under `.planning/evidence/v1.2/` and currently covers the retained HTML baselines only.
- v1.3 core beauty module plan lives under `docs/meitu-function-blueprint/`.
- v1.3 example-image validation is documented in `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` and implemented by the `BeautyExampleRenderer` SwiftPM executable.

## Constraints

- **SDK boundary:** SDK targets must not contain SwiftUI or UIKit pages; UI stays in `BeautyDemo` or host apps.
- **Demo dependency:** Demo uses `BeautySDK` public APIs and must not import internal SDK targets.
- **Implementation order:** New advanced effects should build on existing detection/render/resource/degradation seams rather than bypassing them.
- **Naturalness:** Effects prioritize plausible output over maximum intensity; safety caps remain part of the product contract.
- **Realtime performance:** Camera processing must avoid unbounded queues and avoid realtime `UIImage` conversion.
- **Privacy:** Default behavior is no upload, no raw-frame persistence, no landmark persistence, and no sensitive path logging.
- **Permissions:** Camera/photo prompts are app-owned; SDK APIs must not trigger protected-resource prompts by themselves.
- **Resource trust:** Presets, LUTs, makeup packs, stickers, and future resource bundles are untrusted unless bundled, versioned, and validated.
- **Toolchain:** Phase 21 observed Xcode 26.6 and Swift 6.3.3. Explicit iOS Simulator destinations are required for reliable `xcodebuild` evidence. Phase 23 focused Demo camera tests pass in the current environment, while Phase 22 screenshot evidence still needs the screenshot protocol rerun before a current visual pass can be claimed.
- **HTML reference workflow:** v1.2 built and verified static local HTML references. If SwiftUI visual tuning is re-promoted later, it should cite a new explicit contract rather than raw screenshots alone.
- **Offline reference safety:** HTML references must use local code/assets only; no network fonts, remote media, analytics, upload, or hidden service calls.
- **v1.3 scope boundary:** v1.3 designs and implements core beauty modules only; no new SwiftUI screens, Home/discovery, style resources, AI/background, video/body, gallery/account, search, premium access, commerce, or account authorization work.
- **v1.5 scope boundary:** v1.5 starts from `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` and promotes only SDK-core geometry output plus the `脸型` existing-parameter slice; UI and non-face-shape groups stay out of scope unless the roadmap explicitly changes.
- **v1.6 scope boundary:** v1.6 starts from the same ledger and promotes only existing public-parameter `眼睛` rows after public-facade saved-output and safety/degradation evidence exists; no UI, public API, commercial, device, release, or unscoped `眼睛` claim is included.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Product remains an SDK, not a standalone consumer app. | The user chose SDK plus complete Demo; v1 shipped reusable SDK boundaries and a validation Demo. | Good |
| Demo should become a rich Meitu/Xingtu-style showcase. | v1 validated a broad Demo surface without making the Demo the primary product. | Good |
| Demo uses modules only through the `BeautySDK` facade. | Facade-only Demo imports keep host integration realistic and are covered by tests/scans. | Good |
| MVP starts with foundation, camera/still-image flow, presets, filters, and core face/skin controls. | This sequence let tests and privacy/reliability contracts grow before richer effects. | Good |
| Advanced makeup, segmentation, body shaping, stickers, AI style, and video export are staged later. | v1 shipped the core pipeline and left higher-breadth features as explicit future milestone candidates. | Good |
| Release-like claims require separate hardware, visual, performance, and long-run evidence. | v1 automation proves correctness and safety, not commercial visual quality or device endurance. | Revisit in next milestone |
| v1.1 prioritizes Meitu-style Demo fidelity over new SDK algorithms. | The user rejected the prior Demo surface as not matching the `meituxiuxiu` references; visual/navigation fidelity had to be fixed before claiming a rich Demo. | Completed in v1.1 |
| v1.2 retains HTML references but cancels SwiftUI tuning. | The user decided on 2026-06-26 to keep the Phase 11 HTML baseline outputs and cancel Phases 12-15 because the subsequent planning direction was not useful. | Reduced-scope complete |
| v1.3 focuses only on core beauty modules, not UI. | The user clarified that resources, AI, video, account, and gallery should not be planned now, and that this milestone should do core module design, encapsulation, implementation, and direct code-level image validation before any new UI work. | Completed in Phase 20 |
| v1.4 prioritizes hardening and debt cleanup over feature breadth. | The user selected a first-principles optimization milestone to consolidate existing functionality, fix issues, improve performance, and clean historical debt before adding new product areas. | Completed and archived in v1.4 |
| Phase 21 is the v1.4 evidence baseline, not a fix phase. | Current SDK/renderer evidence passed, Demo simulator evidence has a reproducible local toolchain blocker, and stale codebase maps were found. | Routes debt to Phases 22-25 without source changes |
| Phase 23 completes performance/reliability as evidence and blocker records, not optimization. | Current 720p SDK timings remain over budget in SwiftPM debug XCTest, while backpressure/reset/degradation/redaction evidence passes and missing long-run/device checks are explicit. | Completed in Phase 23 |
| Phase 25 completes privacy/resource/security closeout as current evidence, not packaging approval. | Current SDK/Demo behavior supports explicit manifest deferral and bundled-resource trust only; external packages, long-run, screenshot, hardware, optimized profiling, and commercial packaging remain future or blocked/not-run checks. | Completed in Phase 25 |
| v1.6 targets the `眼睛` existing-parameter slice next. | `眼睛` already has public SDK parameters and provider/resolver evidence, and v1.5 created the public-facade geometry output harness needed for visual completion evidence. | Active in v1.6 |
| v1.5 starts with geometry output foundation plus `脸型`, not all `美型 / 五官` groups. | The user chose the smallest first-principles slice: prove facade-visible geometry output first, then mark only the existing face-shape tools complete when evidence exists. | Completed and archived in v1.5 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

---
*Last updated: 2026-07-09 after v1.6 milestone initialization*
