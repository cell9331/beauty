# Beauty

## What This Is

`beauty` is a modular local-first iOS beauty SDK with a rich SwiftUI Demo app that exercises the SDK through public APIs. The SDK owns image/frame processing, parameters, detection, rendering, effects, resources, diagnostics, and the host-facing `BeautySDK` facade. The Demo app validates these capabilities through a Meitu/Xingtu-style editing surface with camera preview, still-image editing, presets, sliders, before/after compare, debug overlay state, disabled future categories, and parameter JSON import/export.

This is not a standalone consumer App Store product as the primary product. The Demo is complete enough to validate SDK behavior, while reusable SDK boundaries remain the product center.

## Core Value

An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## Current State

**Shipped version:** v1.14 Local Facial Retouch on 2026-08-05 (SDK-core still-image safety and exact-absence closeout; no visible feature promotion).
**Latest completed UI milestone:** v1.1 Meitu UI on 2026-06-24.
**Current milestone:** v1.14 Local Facial Retouch — shipped and archived after 41/41 requirements, 6/6 phases, 9/9 integration seams, and 5/5 end-to-end flows passed.

**Implementation state:** v1.13 is shipped and archived. v1.14 now owns one compatible canonical still-image request foundation, a feature-neutral original-pixel composition core, and validated exact-absence teeth, sclera, and upper-eyelid slices. Strong request-local identity, checked pre-issuance validation, deterministic Q16 blending, post-filter hard containment, collision-to-source behavior, aggregate-only diagnostics, and opaque Testing-only facade adjacency remain feature-neutral. `BeautyParameters` remains exactly 59 stored fields (58 numeric plus `filterId`), production local-retouch admission remains literal empty, and no teeth, sclera, or upper-eyelid candidate surface exists because all three independent Phase 54 evidence gates are closed.

**Verification state:** Phase 57 independently passes 12/12 must-haves and all 10 conditional requirements after seven review fixes and a separate identity-classification verification-gap closure. The hardened checker passes 519/519 with per-threat totals `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42`. Phase 58 automated execution passes exact 7/7 rows, 20/20 decisions, 8/8 HIGH identities, full SwiftPM `553/0/6`, opt-in Vision `6/0/0`, Demo `120/0/0`, adversarial review/fix is clean, and independent verification passes `12/12`; the milestone audit passes `41/41` requirements, `9/9` integration seams, and `5/5` flows. Production admission and promotion remain exactly empty; device/commercial/performance/packaging/shipping/launch/release-readiness remain separate scopes.

**Next milestone goals:** None selected. Start `$gsd-new-milestone` to define the next scope; preserve the exact-empty v1.14 boundary until new evidence and requirements are approved.

**Archived v1.5 baseline:** Phase 26 records public facade geometry activation and privacy-safe routing; Phase 27 records deterministic saved-output geometry evidence and degradation verification; Phase 28 records scoped `脸型` per-tool renderer evidence, safety/degradation/redaction tests, and ledger/documentation closeout. Remaining broader `美型 / 五官` slices, screenshot reruns, physical iPhone checks, 600-second preview, optimized profiling, packaging review, commercial visual review, and launch readiness stay future or setup-specific work, not v1.5 blockers. Stale `.planning/codebase/*` maps are background only until a formal remap is scoped.

**Code size:** the annotated v1.13 close contains 36,649 tracked Swift source/test lines across `BeautySDK` and `BeautyDemo`, excluding `.build`; the consolidation audit raises the current working total to 36,722 after three focused Demo lifecycle/input fixes.

## Current Milestone: v1.14 Local Facial Retouch

**Goal:** Add a reusable, local-first still-image mask and color-retouch path that can deliver conservative teeth whitening and guarded sclera redness reduction, while allowing upper-eyelid fullness reduction to advance only after its independent real-positive gate passes.

**Target features:**

- Add compatibility-safe public controls for `白牙`, `祛红血丝`, and conditionally `去脂`, without aliasing shipped color or eye-geometry fields.
- Normalize accepted still inputs once, run one selected-face Vision request, keep masks request-local, derive accepted edits from original pixels, and fail closed per region, eye, or ownership collision.
- Prove teeth containment/naturalness and sclera iris/highlight protection through rights-approved positive/negative bundles, aggregate-only diagnostics, bounded saved-output evidence, and original-detail review.
- Admit `去脂` only from genuine upper-eyelid-fullness positives with an independent non-warp implementation; if that gate fails, ship the validated teeth/redness slice and keep `去脂` plus branch `眼睛` partial.

**Key context:** v1.14 is SDK-core and still-image only. Transparent input is rejected until a separately declared composite policy exists. It adds no realtime/pixel-buffer local-retouch path, SwiftUI/Demo UI, network/cloud behavior, third-party beauty SDK, unapproved model or weights, public raw landmarks/masks, tracked fixture media, commercial/device/performance/packaging/shipping/launch claim, or proxy eye-height/lift/warp behavior.

## Last Completed Milestone: v1.13 Eyebrow Geometry Controls

**Status:** Shipped, independently audited, archived, cleaned up, and tagged as of 2026-07-28.

**Goal:** Complete the exact seven-row SDK-core `眉毛` branch through compatibility-safe public controls, request-scoped observed eyebrow support, independent geometry behavior, public-facade output evidence, and conservative safety closeout.

**Target features:**

- Add independent product-neutral controls for eyebrow vertical position, thickness, length, overall spacing, inner-head spacing, tilt, and peak definition without aliasing eye or face-shape controls.
- Capture and validate left/right Apple Vision eyebrow landmarks through the existing request-local mapping boundary while exposing no raw geometry through public API, persistence, or diagnostics.
- Route all seven controls through provider-owned eligibility, resolver/conflict accounting, the unified warp, and the public `BeautySDK` facade with field-local missing/malformed/reused/stale degradation.
- Add isolated renderer/helper/gallery evidence, exact caps and directionality, aggregate-only diagnostics, active-source/privacy gates, and exact seven-row ledger promotion.

**Key context:** v1.13 changes only the `BeautySDK` Swift Package and its SDK-owned tests, renderer, evidence, and contract documentation. It adds no SwiftUI or Demo UI, network/cloud processing, account/payment/VIP/entitlement behavior, remote model download, or tracked generated image baseline. Existing 52-field source/JSON/preset compatibility and all shipped face/eye/nose/mouth behavior must remain neutral.

## Planned Facial-Feature Milestone Sequence

1. **v1.13 Eyebrow Geometry Controls** — implement all seven `眉毛` rows.
2. **v1.14 Local Facial Retouch** — implement `去脂`, `祛红血丝`, and `白牙` through a reusable local mask/color-retouch path, closing `眼睛` and `嘴唇`.
3. **v1.15 Hairline and Semantic Masking** — establish an approved local semantic-region foundation and implement `发际线`.
4. **v1.16 Double-Chin and Facial-Feature Closeout** — implement `去双下巴` and `去双下巴 Pro`, then close the narrow 51-row facial-feature taxonomy.

For v1.15-v1.16, any bundled Core ML resource must be local-only, redistributable, versioned, checksum-pinned, size-reviewed, and packaged inside SPM. If no compliant resource exists, the relevant milestone must fail closed at its feasibility gate rather than substituting proxy behavior.

## Last Completed Milestone: v1.12 Face Shape Remaining Capabilities

**Status:** Shipped, independently audited, and archived as of 2026-07-24.

**Goal:** Complete the four unresolved contour-driven SDK-core `脸型` capabilities through independent product-neutral contracts, validated observed geometry, public-facade output, and conservative evidence-backed promotion.

**Target features:**

- Add independent controls for `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴`, backed by observed face-contour/centerline evidence rather than the existing synthetic face-box proxy or aliases to shipped face fields.
- Preserve source/JSON/preset compatibility, keep raw observed contour support request-scoped and package-internal, and fail closed per unsupported field without suppressing eligible sibling or face-agnostic effects.
- Add isolated public-facade renderer/helper and ignored-gallery evidence for all four rows, safe no-face/missing-contour cases, exact caps, combined weakening, redacted diagnostics, and exact four-row promotion.
- Keep `去双下巴`, `去双下巴 Pro`, and `发际线` future until a licensed, reproducible local semantic-region implementation and clean-clone fixtures exist; branch-level `脸型` remains `partial` in v1.12.

**Key context:** v1.12 is SDK-core only. On 2026-07-21 the user selected the blocker-honest reduced scope rather than authorizing a third-party semantic model. It adds no SwiftUI Demo UI, semantic model, third-party beauty SDK, network/cloud processing, account/payment/VIP/entitlement path, or tracked generated image baseline. Device parity, commercial visual approval, optimized performance, packaging, shipping, and launch readiness remain separate evidence scopes.

## Last Completed Milestone: v1.11 Eye Remaining Geometry Controls

**Status:** Shipped, independently audited, archived, and tagged as of 2026-07-19.

**Goal:** Complete the ten unresolved SDK-core eye geometry controls through compatibility-safe public semantics, private contour/pupil support, facade-visible output, conservative degradation, and evidence-backed ledger promotion while keeping eye-fat and redness retouch outside the geometry slice.

**Target features:**

- Add independent product-neutral controls for eye height, length, upper-lid lift, pupil size, gaze correction, lower-lid drop, tilt, inner-corner opening, outer-corner opening, and symmetry without aliasing the four shipped eye fields.
- Replace symmetric proxy-only assumptions for the new advanced controls with validated package-internal, frame-scoped eye-contour and pupil support derived from Apple Vision, while preserving the public/raw-geometry boundary and existing zero-default behavior.
- Add isolated public-facade renderer/helper and ignored-gallery evidence that distinguishes all ten controls, both directions where signed behavior is required, automatic correction behavior, and safe no-face/pupil-missing cases.
- Lock exact caps, contour/pupil eligibility, blink/malformed/missing/reused/stale degradation, provider-eligible combined weakening, redacted diagnostics, artifact boundaries, and exact ten-row promotion.

**Closeout:** The v1.11 audit passed 24/24 requirements, 4/4 phases, 10/10 integration seams, and 6/6 end-to-end flows. It is SDK-core only: `去脂` and `祛红血丝` remain separate retouch/color work; no SwiftUI Demo UI, third-party dependency, network/cloud behavior, account/payment/VIP/entitlement/commercial path, tracked generated image baseline, device, commercial, performance, packaging, shipping, or launch-readiness claim is made.

## Last Completed Milestone: v1.10 Mouth Remaining Geometry Controls

**Status:** Shipped, independently audited, and archived as of 2026-07-14.

**Goal:** Complete the five unresolved SDK-core mouth geometry controls through independent public semantics, explicit lip-support geometry, facade-visible output, conservative safety behavior, and evidence-backed ledger promotion while keeping teeth whitening outside the geometry slice.

**Target features:**

- Add product-neutral public controls for mouth vertical position, tilt, horizontal position, M-lip peak definition, and true lip plumping, with defaulted source/JSON compatibility and no aliasing to `mouthSize`, `mouthWidth`, `smile`, or `lipColor`.
- Extend package-internal mouth geometry with explicit outer/inner and upper/lower lip support sufficient to keep whole-mouth transforms distinct from local lip-shape transforms and to fail closed per unsupported field.
- Add isolated public-facade renderer/helper and ignored-gallery evidence for all five controls across the established seven-fixture matrix, including both directions for the three signed transforms and distinct M-lip/plump output.
- Lock exact caps, directionality, no-face and missing/reused/stale degradation, provider-eligible combined weakening, redacted diagnostics, artifact boundaries, and exact five-row promotion.

**Key context:** v1.10 is SDK-core only. It expands the stable public parameter inventory only for the five remaining mouth geometry rows; adds no SwiftUI Demo UI, third-party dependency, network/cloud behavior, account/payment/VIP/entitlement/commercial path, or tracked generated PNG baseline. `白牙` remains future because it requires teeth-region segmentation and color/retouch ownership, so branch-level `嘴唇` remains partial even when the geometry subset is complete. Device parity, commercial visual approval, packaging, shipping, and launch readiness are not claimed.

**Closeout:** Eleven plans are complete. Exact caps, all-eight degradation/transitions, combined face/eye/six-nose/eight-mouth convergence, privacy and active-source boundaries, exact five-row promotion, and the independent 17/17 milestone audit pass.

## Last Completed Milestone: v1.9 Nose Remaining Tools and Branch Closeout

**Status:** Shipped, independently audited, and archived as of 2026-07-14.

**Goal:** Complete the remaining `鼻子` tools by resolving and implementing `山根` and `提升`, then close the branch through public-facade evidence, conservative safety behavior, and synchronized owning documentation.

**Target features:**

- Define explicit product-neutral public parameter semantics for `山根` and `提升` without borrowing the existing `noseBridge` evidence path.
- Add public-facade renderer/helper and ignored-gallery evidence for both remaining nose tools across the established fixture matrix.
- Lock normalization, natural caps, directionality, missing/reused/stale geometry degradation, combined-effect weakening, redacted diagnostics, and safe-domain continuation.
- Promote `山根`, `提升`, and branch-level `鼻子` only when code, tests, generated-output evidence, security scans, and all owning ledgers agree.

**Key context:** v1.9 is SDK-core only and intentionally expands the stable public parameter inventory for the two remaining nose tools. It adds no SwiftUI Demo UI, dependency, network/cloud behavior, account/payment/VIP/entitlement/commercial path, or tracked generated PNG baseline. It does not claim device parity, commercial visual approval, broad Meitu parity, packaging readiness, or launch readiness.

## Last Completed Milestone: v1.8 Broader `美型 / 五官` SDK Slice - Mouth

**Goal:** Complete the SDK-only existing-parameter `嘴唇` slice through public-facade output evidence, signed-safe geometry behavior, lip-color containment, conservative degradation, and exact evidence-backed ledger promotion.

**Target features:**

- Add public-facade renderer cases for signed `mouthSize`, signed `mouthWidth`, `smile`, and `lipColor`, with ignored output/gallery evidence across the established fixture matrix.
- Lock exact caps, signed direction, missing/reused/stale mouth-geometry degradation, combined weakening, warning/metric redaction, and safe-domain continuation.
- Verify `lipColor` as a color-domain capability distinct from geometry shaping and prevent it from being mislabeled as true `丰唇` geometry evidence.
- Promote exactly the evidence-backed `大小`, `宽度`, and `微笑` rows while keeping `上下`, `倾斜`, `左右`, `M唇`, `丰唇`, `白牙`, and branch-level `嘴唇` partial/future.

**Key context:** v1.8 is SDK-core only and uses the existing 31-field public inventory. It adds no SwiftUI Demo UI, public fields, dependency, network/cloud behavior, account/payment/VIP/entitlement/commercial path, or tracked generated PNG baseline. It does not claim device parity, commercial visual approval, broad Meitu parity, packaging readiness, launch readiness, whole-branch completion, or true plump-lip geometry from `lipColor`.

**Status:** Shipped, audited, archived, and ready for the next milestone cycle as of 2026-07-13.

## Last Completed Milestone: v1.7 Broader `美型 / 五官` SDK Slice - Nose

**Goal:** Complete the SDK-only existing-parameter `鼻子` slice through public-facade renderer evidence, signed-safe normalization and degradation behavior, and exact four-row ledger promotion.

**Target features:**

- Add five public-facade renderer cases for `noseSlim`, `noseWingSlim`, signed `noseTipSize`, and `noseBridge`, expanding the matrix from 23 to 28 cases across seven fixtures.
- Add ignored nose output/gallery evidence proving 196/196 outputs, 30/30 portrait central-face comparisons, signed tip-direction differences, and representative no-face extent preservation.
- Lock exact caps, signed semantics, missing/reused/stale geometry degradation, combined weakening, warning/metric redaction, and safe-domain continuation.
- Promote exactly `大小`, `鼻翼`, `鼻梁`, and `鼻尖` while keeping `山根`, `提升`, and branch-level `鼻子` partial/future.

**Status:** Shipped, audited, and archived as of 2026-07-13.

**Key context:** v1.7 is SDK-core only and uses the existing 31-field public inventory. It adds no SwiftUI Demo UI, public fields, dependency, network/cloud behavior, account/payment/VIP/entitlement/commercial path, or tracked generated PNG baseline. It does not claim device parity, commercial visual approval, broad Meitu parity, packaging readiness, launch readiness, or whole-branch completion.

## Last Completed Milestone: v1.6 Broader `美型 / 五官` SDK Slice - Eyes

**Status:** Shipped and audited as of 2026-07-13.

**Goal:** Extend the v1.5 geometry-output foundation to complete the existing-parameter `眼睛` SDK slice through public-facade saved-output evidence, safety/degradation tests, and scoped ledger promotion.

**Target features:**

- Eye renderer evidence: `BeautyExampleRenderer` includes public-facade cases for existing public eye parameters `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift`.
- Eye output helper evidence: generated outputs preserve dimensions, remain ignored, and differ from `geometryBaseline_noop` above the watermark band on usable portrait fixtures.
- Eye safety evidence: focused tests cover caps, no-face and missing/reused/stale-eye degradation, combined weakening, redacted summaries/metrics, and no raw geometry leakage.
- Scoped documentation closeout: only the mapped `眼睛` rows backed by existing public parameters are implemented; branch-level `眼睛` remains partial, with no Demo UI, public API expansion, commercial/device/release-readiness, or broad Meitu parity claim.

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

### Active (next milestone — not yet selected)

No new milestone requirements are active. The v1.14 requirements below are
recorded as validated outcomes, including exact-absence outcomes where a
feature gate remained closed.

- [x] Establish one canonical still-image input and request-local local-retouch composition boundary behind the public facade — v1.14, exact-empty admission.
- [x] Add conservative teeth whitening with adaptive inner-lip containment, protected-tissue leakage gates, and rights-approved review evidence — v1.14 gate closed, no promotion.
- [x] Add guarded per-eye sclera redness reduction with iris/highlight protection, local failure isolation, and rights-approved review evidence — v1.14 gate closed, no promotion.
- [x] Gate upper-eyelid fullness reduction on genuine positive fixtures and an independent non-warp implementation; fail closed without either — v1.14 gate closed, no promotion.
- [x] Preserve source/JSON/preset compatibility, default neutrality, shipped geometry/color output, local-only privacy, and aggregate-only diagnostics — v1.14 validated.
- [x] Keep v1.14 SDK-SPM-only and still-image-only; exclude SwiftUI/Demo, realtime/pixel-buffer, external model, cloud, and release-readiness scope — v1.14 validated.
- [x] Require public-facade output, adversarial safety, original-detail human review, full regression, synchronized owner ledgers, and an independent milestone audit before promotion — v1.14 validated with zero promotion.

### Validated

- Phase 53 establishes one opaque canonical still-image carrier, normalize-once validation, one selected-face request/mapping boundary, request-local private lip support, exact legacy compatibility, and exact-empty production admission with no realtime/Demo expansion.
- Phase 54 establishes an independently auditable fail-closed eligibility system: trusted grant/media bindings, zero-weight mechanics fixtures, frozen blinded structured review, exact allowlisted export, three independent closed feature decisions, Nyquist validation, ASVS HIGH `8/8`, and independent verification `19/19`.
- Phase 58 closes the combined zero-admission branch: automated gates, adversarial review/fix, and independent verification pass `12/12` with full SwiftPM `553/0/6`, opt-in Vision `6/0/0`, Demo `120/0/0`, post-review checker `703/0/0`, and zero ledger promotion; the separate milestone audit remains pending.
- Seven independent eyebrow controls have exact final `0.25` caps, exhaustive request-local degradation/transitions, exact 44-field/13.45 one-scale convergence, strict public-facade output, aggregate-only evidence, and exact seven-row plus branch `眉毛` SDK-core promotion - Phase 52.
- SAFE-01, SAFE-02, SAFE-03, and DOC-01 are independently verified at 16/16 from fresh production-path evidence, a clean 28-file current review, exact 23-task Nyquist coverage, ASVS L1 `threats_open: 0`, simulator regression, strict output, synchronized owners, and preserved nonclaims - Phase 52.
- v1.13 independently passes 21/21 requirements, 4/4 canonical phase verifications, 12/12 integrations, 6/6 flows, and 4/4 Nyquist ledgers after closing all prior audit debt.
- Four contour-driven `脸型` controls have independent product-neutral public semantics, private request-scoped support, named providers, strict public-facade output, exact final caps, exhaustive field-local transitions, exact 37-field convergence, four-row promotion, and an 18/18 independent v1.12 audit - Phases 45-48.
- `去双下巴`, `去双下巴 Pro`, and `发际线` remain future, branch `脸型` remains partial, and Demo/device/commercial/performance/packaging/shipping/launch claims remain excluded - v1.12 phase verification.
- Ten independent eye geometry controls with 48-field source/JSON compatibility, private validated contour/pupil support, fourteen named emissions, strict 385-output facade evidence, conservative degradation, exact ten-row promotion, and a 24/24 independent v1.11 audit - v1.11.
- Eye-fat/redness retouch, Demo UI, external dependencies, network/cloud, and release-readiness claims remain explicitly outside the shipped v1.11 scope.
- Exact v1.10 five-row mouth geometry slice, 38-field compatibility, final `0.25` caps, explicit private lip supports, 265/265 full tests, 308/308 output evidence, 17/17 audit, clean ASVS L1 boundaries, and conservative non-claims - Phases 38-40.
- Exact v1.9 six-row SDK-core `鼻子` branch, independent `山根`/`提升` semantics, final `0.25` caps, 228/228 full tests, unchanged 252/252 output, clean ASVS L1 boundaries, and conservative non-claims - Phase 37.
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

### Completed in v1.6

- [x] Validated in Phase 29: add public-facade saved-output renderer/helper evidence for `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift` without adding UI scope or public parameters.

#### Phase 30 Eye Safety, Ledger, and Closeout

The verified v1.6 SDK-only existing-parameter slice maps `eyeSize`, `eyeDistance`, `eyeYPosition`, and `eyeTailLift` to exactly four implemented rows: `大小`, `眼距`, `上下`, and `眼尾上扬`. Command-backed details are recorded in `30-EYE-SAFETY-EVIDENCE.md`, with the verified boundary audit in `30-SECURITY.md`.

Branch-level `眼睛` remains `partial`. Eye height, length, pupil/gaze, lid, redness, corners, symmetry, and other tools remain future work. This slice adds no new public fields or Demo UI, remains local-first with no network/cloud processing or commercial entitlement path, and commits no generated image baseline. It does not claim device evidence, commercial visual approval, broad reference parity, launch readiness, or whole-branch completion.

### Completed in v1.7

- [x] Add public-facade nose renderer/output/gallery evidence for the four existing nose parameters.
- [x] Preserve signed `noseTipSize` end to end and lock exact effective caps for all four fields.
- [x] Verify fail-closed missing/stale geometry, reduced reused geometry, combined weakening, redaction, and safe-domain continuation.
- [x] Promote exactly four evidence-backed nose rows while preserving the partial branch and future rows.

### Completed in v1.8

- [x] Add public-facade mouth/lip renderer, output-helper, and ignored-gallery evidence for the four existing public parameters.
- [x] Preserve signed `mouthSize` and `mouthWidth` behavior and lock exact effective caps for all four fields.
- [x] Verify fail-closed missing/stale mouth geometry, reduced reused geometry, combined weakening, redaction, lip-color containment, and safe-domain continuation.
- [x] Promote exactly the evidence-backed mouth rows while preserving the partial branch and future rows, including the explicit `lipColor` versus `丰唇` distinction.

#### Phase 34 Mouth Safety, Degradation, and Ledger Closeout

The verified SDK-only slice implements exactly `大小`, `宽度`, and `微笑`. `lipColor` is separately verified color behavior, not true `丰唇`. Branch-level `嘴唇` remains partial; no new public field, UI, dependency, network/commercial path, or tracked generated image was added.

### Out of Scope

- Standalone consumer App Store product - still out of scope; Demo remains an SDK validation app.
- Demo direct imports of `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` - still out of scope; Demo must stay facade-only.
- Cloud upload or network processing by default - still out of scope; privacy posture remains local-first.
- Full Meitu/Xingtu feature parity in v1 - validated as deferred to future milestones.
- Home/discovery, filters/makeup/stickers/templates, AI/background, video/body, gallery/account, search, premium access, commerce, and account authorization planning - out of v1.3 because the user narrowed this milestone to core beauty only.
- Treating ignored `.worktrees/` content as shipped main-worktree implementation - still out of scope.
- Third-party beauty SDK as the core implementation - still out of scope unless explicitly approved later.
- Camera/photo permission prompts from SDK internals - still out of scope; host app or Demo owns protected-resource UX.
- Realtime or pixel-buffer `去脂`/`祛红血丝`/`白牙` processing in v1.14 - the spike evidence and ownership design cover still images only.
- Treating `eyeHeight`, `upperEyelidLift`, brow motion, global smoothing, or any eye warp as `去脂` - these are semantically different effects and remain forbidden proxies.
- Shipping `去脂` without rights-approved upper-eyelid-fullness positives and a non-warp independent implementation - the field and branch must remain future/partial when the gate is not met.
- Persisting or exposing teeth masks, sclera masks, vein-like descriptors, pupil positions, or raw face geometry - all local support remains private and request-scoped.
- Transparent-input local retouch, HDR/gain-map support, new silent multi-face selection, third-party/Core ML weights, and tracked portrait/output media - each needs separately approved ownership, policy, licensing, and evidence.

## Next Milestone Goals

Future milestone candidates after v1.12:

- **v1.14 Local Facial Retouch:** `去脂`, `祛红血丝`, and `白牙`.
- **v1.15 Hairline and Semantic Masking:** approved local semantic-region foundation plus `发际线`.
- **v1.16 Double-Chin and Facial-Feature Closeout:** `去双下巴`, `去双下巴 Pro`, and final narrow five-feature audit.
- **Other shaping groups:** `比例` and `3D塑颜` remain outside this narrow facial-feature sequence.
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
- `.planning/milestones/v1.6-ROADMAP.md`
- `.planning/milestones/v1.6-REQUIREMENTS.md`
- `.planning/milestones/v1.6-MILESTONE-AUDIT.md`
- `.planning/milestones/v1.7-ROADMAP.md`
- `.planning/milestones/v1.7-REQUIREMENTS.md`
- `.planning/milestones/v1.7-MILESTONE-AUDIT.md`
- `.planning/milestones/v1.8-ROADMAP.md`
- `.planning/milestones/v1.8-REQUIREMENTS.md`
- `.planning/milestones/v1.8-MILESTONE-AUDIT.md`
- `.planning/milestones/v1.8-phases/`

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
- **v1.7 scope boundary:** v1.7 promotes only the four existing public-parameter `鼻子` rows after public-facade output, signed-direction, safety, degradation, and boundary evidence exists; `山根`, `提升`, and branch-level `鼻子` remain partial/future.
- **v1.8 scope boundary:** v1.8 promotes only `大小`, `宽度`, and `微笑` after facade output, signed-direction, degradation, and boundary evidence; `lipColor` remains color-only, true `丰唇` is not claimed, and branch-level `嘴唇` remains partial.
- **v1.9 scope boundary:** v1.9 adds only the two product-neutral public fields needed for `山根` and `提升`, then promotes those rows and branch-level `鼻子` only after facade output, safety, degradation, redaction, compatibility, and documentation evidence; Demo UI and release-readiness work remain excluded.
- **v1.10 scope boundary:** v1.10 adds only the five product-neutral public fields and package-internal lip supports needed for `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇`; `lipColor` remains color-only, `白牙` remains a separate segmentation/retouch concern, and Demo/device/commercial/packaging/shipping/launch work remains excluded.
- **v1.11 scope boundary:** v1.11 adds only the ten product-neutral public fields and private contour/pupil support needed for `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称`; `去脂` and `祛红血丝` remain separate retouch/color concerns, and Demo/device/commercial/performance/packaging/shipping/launch work remains excluded.
- **v1.12 scope boundary:** v1.12 adds only the four product-neutral public controls and private observed-contour/centerline support needed for `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴`; `去双下巴`, `去双下巴 Pro`, and `发际线` remain future pending an approved semantic-region implementation, and Demo/network/account/device/commercial/performance/packaging/shipping/launch work remains excluded.
- **v1.13 scope boundary:** v1.13 adds only seven product-neutral eyebrow controls plus private request-scoped observed eyebrow support inside `BeautySDK`; no SwiftUI/Demo UI, remote processing, commercial path, or semantic-region model is included.
- **v1.14 scope boundary:** v1.14 adds only a still-image local-retouch foundation plus evidence-qualified `白牙`, `祛红血丝`, and conditionally `去脂`; canonical input is shared by Vision and rendering, local masks never escape the request, transparent input fails closed, and no realtime/Demo/cloud/model/commercial/release scope is implied.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| v1.14 uses a staged local-retouch milestone: teeth and sclera may ship independently, while upper-eyelid fullness remains gated. | Teeth and guarded sclera mechanics have distinct bounded paths; the tested eyelid warp is invalid and no real positive bundle yet supports promotion. | Verified through Phase 54 — all three gates are independently closed and later phases must preserve exact absence unless independently qualified |
| v1.14 rejects transparent still inputs until an explicit composite policy is approved. | Preserving alpha bytes does not stabilize Vision landmarks when canvas/background changes; fail-closed rejection is the safest bounded default. | Verified in Phase 53 — rejection occurs before Vision/local-mask work and remains outside Phase 54 evidence admission |
| Phase 52 acceptance requires production-path proofs plus an independent post-gap verifier, not executor readiness alone. | The first verification exposed adapter-invalid fixtures, pre-work cancellation, manual convergence approximation, and owner disagreement despite earlier green executor evidence. | Verified in Phase 52; all four gaps closed and independent re-verification passes 16/16 |
| Phase 49 freezes seven neutral eyebrow fields and accepts only actual request-scoped Apple Vision eyebrow traces. | Geometry phases need a compatibility-safe public contract and honest support provenance before providers, resolver routing, or output evidence can activate. | Verified in Phase 49; 411-test suite and boundary gates pass |
| Phase 51 accepts eyebrow output only through a separately rendered frozen strict gate plus actual-image review. | Generated labels or self-selected thresholds cannot prove brow-local direction and semantic distinction; the sole active portrait and no-face negative need distinct denominators. | Verified in Phase 51; 72/72 portrait outputs, thirteen no-face no-ops, fourteen opened images, and exact 144-file containment pass |
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
| v1.6 targets the existing-public-parameter `眼睛` slice. | `眼睛` already had public SDK parameters and provider/resolver evidence, and v1.5 created the public-facade geometry output harness needed for visual completion evidence. | Completed in Phase 30; milestone audit passed |
| v1.7 targets the existing-public-parameter `鼻子` slice without collapsing signed tip direction. | The renderer foundation exists, and the four public nose fields can be completed without adding API or UI breadth; `noseTipSize` must retain positive/negative semantics end to end. | Completed in Phase 32; milestone audit passed |
| v1.8 targets the existing-public-parameter `嘴唇` slice while separating geometry from lip color. | The existing public fields support signed mouth geometry plus color containment without adding API/UI breadth or mislabeling `lipColor` as true `丰唇`. | Completed in Phase 34; milestone audit passed |
| v1.9 closes the remaining `鼻子` branch with independent `山根` and `提升` semantics. | v1.7 deliberately left both tools unresolved; branch completion requires explicit public parameters and evidence rather than aliasing `山根` to `noseBridge` or borrowing prior outputs. | Completed in Phase 37; milestone audit passed |
| v1.10 completes the remaining mouth geometry controls without absorbing teeth whitening. | The five unresolved geometry rows share the existing mouth warp/facade evidence path, while `白牙` needs a different teeth-region segmentation and retouch contract. | Completed in Phase 40; milestone audit passed |
| v1.11 completes the remaining eye geometry controls without absorbing eye-fat or redness retouch. | Ten unresolved geometry rows can build on the eye warp/facade path, but pupil/gaze/symmetry require private observed support and field-local fail-closed behavior; `去脂` and `祛红血丝` need different retouch/color ownership. | Completed and archived in v1.11 |
| v1.12 completes four contour-driven unresolved `脸型` rows and defers semantic-region rows rather than faking support. | The existing five face parameters cannot prove smooth-contour, temple, cheekbone, or pointed-chin behavior, while no approved semantic model/fixtures exist for double chin or hairline; the user selected reduced scope on 2026-07-21. | Completed in Phase 48; milestone audit passed and archived |
| Complete the remaining narrow facial-feature taxonomy across v1.13-v1.16, beginning with eyebrows. | Eyebrow controls reuse Apple Vision landmark and unified-warp infrastructure; local retouch follows next, while hairline/double-chin work remains gated on an approved local semantic-region resource. | v1.14 completed with exact-empty local-retouch admission; v1.15-v1.16 remain unstarted |
| v1.5 starts with geometry output foundation plus `脸型`, not all `美型 / 五官` groups. | The user chose the smallest first-principles slice: prove facade-visible geometry output first, then mark only the existing face-shape tools complete when evidence exists. | Completed and archived in v1.5 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

---
*Last updated: 2026-08-05 after v1.14 milestone completion*
