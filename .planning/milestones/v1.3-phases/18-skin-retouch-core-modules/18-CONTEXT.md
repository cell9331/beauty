# Phase 18: Skin Retouch Core Modules - Context

**Gathered:** 2026-06-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 18 implements and verifies promoted skin-retouch module logic behind existing SDK boundaries for `SKIN-01`, `SKIN-02`, and `SKIN-03`.

The implementation scope is Basic skin only. Phase 18 may improve the existing Basic skin output formula while keeping the public parameter model unchanged: `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`. It must not add new SwiftUI screens, new public skin-repair parameters, teeth/hairline behavior, segmentation/AI/upload flows, resource/style ownership, or release-readiness visual quality claims.

Skin repair and teeth/hairline remain documented future branches in this phase. Their boundaries should be tightened enough that downstream agents do not accidentally implement or claim them.

</domain>

<decisions>
## Implementation Decisions

### Basic Skin Ambition
- **D-01:** Phase 18 should improve Basic skin output formulas, not merely add evidence. The work stays behind existing SDK boundaries and uses the current public skin parameters only.
- **D-02:** Do not add public skin parameters in Phase 18. Any future public parameter expansion for blemish, pore, texture, teeth, or hairline requires root contract updates before implementation.
- **D-03:** Medium strengths around `0.4...0.6` should be naturally conservative: cleaner and slightly brighter, while preserving skin texture and facial-feature edges. Renderer visibility is not allowed to override naturalness.
- **D-04:** Implementation depth is limited to the existing pipeline surface: `BeautyColorEffectPipeline`, resolver behavior, tests, renderer evidence, and related docs. Do not add a new target, do not introduce a separate render pass, and do not start a production `SkinPass` redesign in this phase.
- **D-05:** `skinSmoothing` remains a lightweight softening proxy. It must not become true blemish removal, local repair, region inpainting, segmentation, or aggressive texture removal.

### Face and No-Face Skin Behavior
- **D-06:** Public facade and renderer paths should keep Basic skin visibly effective when detection has not run or facade-visible face geometry is unavailable. In that context, Basic skin is a lightweight full-frame skin-tone improvement.
- **D-07:** Document the layering clearly: public facade no-detection paths can apply Basic skin full-frame, while explicit internal no-face resolver contexts may skip face-dependent skin for future detection-integrated flows.
- **D-08:** If a later implementation has face-quality information, low-confidence, side-face, or too-small-face states may conservatively weaken Basic skin rather than silently applying full strength. The weakening must emit redacted `BeautyResult.warnings` and/or `metrics`.
- **D-09:** Skin degradation evidence belongs in result metadata only. Do not add ordinary UI copy, new Demo banners, public geometry payloads, bounding boxes, landmarks, or raw detector details.

### Future Branch Promotion
- **D-10:** Do not promote Skin repair in Phase 18. It remains `future`; Phase 18 may clarify boundaries but must not implement blemish, pore, texture, or localized cleanup.
- **D-11:** Do not promote Teeth/hairline in Phase 18. It remains `future`; do not implement teeth whitening, hairline adjustment, segmentation, mouth-region teeth logic, or optional resource ownership.
- **D-12:** Phase 18 plans must include negative checks that prevent accidental future-branch implementation. Checks should confirm no new public parameters/API, no new skin-repair or teeth/hairline renderer cases, no resource ownership promotion, no segmentation/AI/upload dependency, and no completion claim for those future branches.
- **D-13:** Future branch docs should be explicit: Phase 18 does not implement these branches and must not claim completion. A later promotion requires independent design plus updates to the owning architecture, design, security, reliability, and product contracts as applicable.

### Verification Threshold
- **D-14:** Phase 18 completion requires focused XCTest coverage for skin parameter/resolver/engine behavior, `BeautyExampleRenderer` build/run evidence for Basic skin, same-dimension output checks, factual visual inspection, and future-branch negative scans.
- **D-15:** Renderer evidence should run all current skin cases: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50`.
- **D-16:** Visual observations must stay factual: output is non-empty, watermark is readable, watermark does not cover the face, dimensions match, and skin cases show visible but natural changes. Do not claim market-grade naturalness, production render quality, or release-readiness visual QA.
- **D-17:** Full `swift test --package-path BeautySDK` is not a fixed Phase 18 completion gate. Executors may run it as extra evidence, but the required gate is focused tests plus skin renderer cases, dimension checks, factual visual review, and negative scans.

### the agent's Discretion
The planner may choose exact plan split, test file names, formula constants, warning/metric key names, and scan command details as long as the decisions above remain intact. Formula changes should be conservative, localized, and testable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger and requirement to record every phase transition.
- `.planning/PROJECT.md` — Defines v1.3 as no-new-UI core beauty module implementation work.
- `.planning/REQUIREMENTS.md` — Defines `SKIN-01`, `SKIN-02`, and `SKIN-03` and maps them to Phase 18.
- `.planning/ROADMAP.md` — Defines Phase 18 goal, success criteria, and planned slots `18-01` through `18-03`.
- `.planning/STATE.md` — Records current milestone state and pending Phase 18 planning.
- `.planning/phases/16-example-image-validation-harness/16-CONTEXT.md` — Locks local renderer evidence rules and ignored output policy.
- `.planning/phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md` — Locks status taxonomy, evidence ladder, Demo-vs-SDK ownership, and future branch handling.

### Blueprint Contracts
- `docs/meitu-function-blueprint/features/skin-retouch/README.md` — Skin-retouch family status, ownership, current parameter coverage, and future branch boundaries.
- `docs/meitu-function-blueprint/features/skin-retouch/skin-basic/README.md` — Basic skin branch behavior, owner, dependency, and evidence expectation.
- `docs/meitu-function-blueprint/features/skin-retouch/skin-repair/README.md` — Future Skin repair branch boundary.
- `docs/meitu-function-blueprint/features/skin-retouch/teeth-hairline/README.md` — Future Teeth/hairline branch boundary.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Branch status matrix and `implemented` / `future` evidence expectations.
- `docs/meitu-function-blueprint/MODULES.md` — Module ownership and public facade renderer ownership.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Renderer commands, built-in skin cases, output naming, watermark, and dimension rules.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` — Evidence ladder and implementation principles.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` — Milestone inclusion/exclusion and no-new-UI boundary.

### Root Contracts
- `ARCHITECTURE.md` — SDK target boundaries, `BeautyEffects` ownership, and facade-only Demo invariant.
- `DESIGN.md` — Public `BeautyParameters`, effect model, no-op defaults, and parameter-extension rules.
- `SECURITY.md` — Local-first posture, parameter validation, no upload, redacted warning/metric constraints.
- `RELIABILITY.md` — Degradation, warnings, metrics, performance budgets, and recoverability policy.
- `PRODUCT_SENSE.md` — Natural-first product acceptance and skin-output expectations.
- `QUALITY_SCORE.md` — Existing SDK/test quality state and recurring scan expectations.

### Current SDK Evidence
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Current public skin parameters and clamping behavior.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — Current domain activation, caps, warnings, metrics, and no-face resolver behavior.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — Existing effective strength caps for skin and other domains.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` — Effective strengths, warnings, metrics, active/skipped domain surface.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` — Current visible Basic skin output formula surface.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public facade image and pixel-buffer processing paths used by renderer/tests.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Current renderer cases and output writing path.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — Current skin cap/domain/redaction resolver tests.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` — Current safety cap assertions.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — Current no-face skin skip behavior in explicit resolver context and combined effect evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` — Current facade-level visible skin/color/filter output evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already exposes the full Phase 18 Basic skin parameter set: `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`.
- `BeautyEffectResolver` already caps skin strengths, activates `.skin`, records warning/metric evidence, and distinguishes facade-style no-geometry resolution from explicit no-face resolver testing.
- `BeautyColorEffectPipeline` is the narrow implementation surface for Phase 18 formula improvements. It currently applies skin whitening, rosy, sharpen, and smoothing as lightweight color/contrast/luminance operations.
- `BeautyExampleRenderer` already has all required Basic skin cases and writes same-dimension, watermarked PNGs under `example-images/out/`.

### Established Patterns
- Public facade and renderer validation import only `BeautySDK`; they must not reach into internal targets.
- Generated image outputs remain local ignored artifacts unless a later phase explicitly promotes evidence images.
- Degradation metadata must stay redacted and result-scoped; warnings/metrics should not contain image bytes, file paths, landmarks, bounding boxes, or raw framework errors.
- Unsupported Meitu branches remain documented as future instead of fake-functional.

### Integration Points
- `18-01` should audit current Basic skin controls, docs, code, renderer cases, and future-branch exclusions before implementation.
- `18-02` should make any conservative formula/resolver/test/doc updates behind SDK boundaries.
- `18-03` should run focused XCTest, renderer skin cases, dimension checks, factual visual observations, facade-only/import scans, and negative scans for Skin repair and Teeth/hairline.

</code_context>

<specifics>
## Specific Ideas

- Keep Basic skin natural and conservative at medium strength.
- Improve current output through localized formula changes only; do not introduce a production `SkinPass` design or new pass architecture.
- Treat facade-visible no-detection skin output as a valid lightweight full-frame skin-tone improvement, while preserving explicit no-face resolver semantics for future detection-integrated behavior.
- Skin repair and teeth/hairline should be harder to implement accidentally after Phase 18, not easier.

</specifics>

<deferred>
## Deferred Ideas

- True skin repair, blemish cleanup, pore/texture repair, inpainting, region masks, or segmentation are deferred to a later independently designed phase.
- Teeth whitening and hairline adjustment are deferred to a later phase that can define mouth/teeth or hair/forehead confidence, privacy, reliability, resource, and parameter contracts.
- A production `SkinPass`, dense face mesh, segmentation-aware skin processing, market-grade naturalness QA, and release-readiness visual validation remain outside Phase 18.

</deferred>

---

*Phase: 18-Skin Retouch Core Modules*
*Context gathered: 2026-06-27*
