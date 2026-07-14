# Phase 29: Eye Renderer Output Evidence - Context

**Gathered:** 2026-07-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 29 extends the shipped v1.5 geometry-output foundation to the existing public `眼睛` SDK parameters. It covers `EYE-01`, `EYE-02`, and `EYE-03`.

This is a public-facade renderer evidence phase. It should add deterministic `BeautyExampleRenderer` cases for existing public eye parameters, add a Phase 29 helper that verifies generated output invariants and eye-vs-baseline deltas, keep generated artifacts ignored, and record command-backed evidence.

Phase 29 must not add SwiftUI or Demo UI work, new public `BeautyParameters`, new eye tools, public raw geometry APIs, commercial entitlement paths, network/cloud behavior, committed generated PNG baselines, safety/ledger closeout claims, branch-level `眼睛` completion, device parity, commercial visual quality, launch readiness, or broad Meitu parity claims. Phase 30 owns eye safety/degradation/redaction evidence and status promotion.

</domain>

<decisions>
## Implementation Decisions

### Eye Renderer Case Matrix
- **D-01:** Add exactly one public-facade renderer case per existing visible eye behavior needed for Phase 29 evidence. Do not make an eye combo case a Phase 29 requirement.
- **D-02:** Use deterministic moderate-strength case IDs: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- **D-03:** Require both signed directions for `eyeDistance` and `eyeYPosition`.
- **D-04:** Do not require negative `eyeTailLift` evidence in Phase 29. Current provider behavior treats `eyeTailLift` as positive-only output behavior; signed/cap safety belongs to Phase 30 tests.
- **D-05:** Require one representative no-face eye output presence check, likely `no-face-gradient__eyeSize_0p35.png`, to prove renderer execution and safe degradation without multiplying every eye case by degradation variants.

### Helper Evidence Gate
- **D-06:** The Phase 29 helper should validate the full renderer matrix plus eye-specific checks. Every expected renderer output must exist, be non-empty, and preserve the source fixture dimensions.
- **D-07:** After the full-matrix checks, the helper must compare each Phase 29 eye case against `geometryBaseline_noop` above the watermark band for every usable portrait fixture.
- **D-08:** Required portrait evidence is 6 portrait fixtures x 6 eye cases = 36 eye-vs-baseline top-region comparisons.
- **D-09:** If any required eye-vs-baseline comparison fails, Phase 29 should fail and be fixed before completion. The planner/executor may adjust implementation, strength, or fixture handling, but must not claim Phase 29 complete with missing required comparisons.
- **D-10:** `example-images/output/` is the canonical generated output path for Phase 29 helper/docs. Older docs or commands that still say `example-images/out/` should be updated when touched.

### Output, Gallery, and Documentation Boundary
- **D-11:** Add an `eyes/` gallery group for the new eye cases in `example-images/generate_gallery.py` and docs. Generated gallery files remain ignored under `example-images/gallery/`.
- **D-12:** Phase 29 may update renderer evidence docs only: `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `example-images/README.md`, `QUALITY_SCORE.md`, phase evidence, and planning ledgers. Do not promote `SHAPE_FEATURE_LEDGER.md` eye row statuses in Phase 29.
- **D-13:** Create a dedicated `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` artifact with exact build/run/helper commands, output counts, dimension buckets, 36/36 eye-vs-baseline comparison results, representative no-face output presence, ignored-output checks, and factual limitations.
- **D-14:** Phase 29 status wording should be: public-facade renderer evidence exists for the existing eye parameters, but the `眼睛` rows and branch remain `partial` until Phase 30 safety/degradation/ledger closeout passes.

### the agent's Discretion
The planner may choose the exact helper filename, test method names, evidence-command formatting, scan command shapes, and whether to extend or mirror the Phase 28 helper. Keep choices consistent with the locked case IDs, `example-images/output/` path, full-matrix helper requirement, ignored generated-output policy, public-facade renderer boundary, and no-overclaim rules.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger and requirement to record verifiable changes.
- `.planning/PROJECT.md` - Defines v1.6 as the SDK-only existing-parameter `眼睛` slice, with no UI/product/API breadth expansion.
- `.planning/REQUIREMENTS.md` - Defines `EYE-01`, `EYE-02`, and `EYE-03` for Phase 29 and reserves safety/ledger closeout for Phase 30.
- `.planning/ROADMAP.md` - Defines Phase 29 goal, success criteria, and boundary against Demo UI, public parameters, commercial behavior, and non-eye renderer scope.
- `.planning/STATE.md` - Records current focus as Phase 29 after v1.6 initialization.
- `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md` - Locks public still-image geometry activation, selected-face routing, and raw-geometry privacy.
- `.planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md` - Locks the public-facade renderer proof path, ignored generated PNG policy, and geometry-vs-baseline evidence bar.
- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md` - Locks the per-tool saved-output evidence pattern, full helper matrix, and scoped status-promotion boundary.

### Root Contracts
- `ARCHITECTURE.md` - Owns package boundaries, public `BeautySDK` facade, internal detection/effects/render responsibilities, `BeautyExampleRenderer` facade-only boundary, and no UI in SDK targets.
- `DESIGN.md` - Owns `BeautyParameters`, including existing eye fields `eyeSize`, `eyeDistance`, `eyeYPosition`, and `eyeTailLift`, plus signed/normalized public-model behavior.
- `SECURITY.md` - Owns local-first privacy, face/landmark sensitivity, public summary privacy, generated-output trust boundary, and no raw geometry leakage.
- `RELIABILITY.md` - Owns degrade-before-fail behavior, no-face/missing-landmark/stale/reused degradation, metrics/log redaction, and saved-output geometry evidence rules.
- `PRODUCT_SENSE.md` - Owns eye-control acceptance, visible promoted-effect evidence expectations, and anti-overclaim constraints.
- `QUALITY_SCORE.md` - Records current renderer evidence and identifies the eye slice as the current v1.6 repair queue.

### Blueprint and Evidence Contracts
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` - Owns second-level `美型 / 五官` statuses; Phase 29 must not promote `眼睛` rows.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Defines current `BeautyExampleRenderer` evidence path, helper expectations, current case matrix, and generated-output rules; update touched stale `out` paths to `output`.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - Owns branch-level status semantics and keeps `眼睛` partial until Phase 30 closeout.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` - Owns beauty-shaping branch principles and evidence expectations.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` - Owns current eye branch scope, existing public parameter coverage, future parameter needs, and privacy boundary.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` - Defines SDK-core/no-UI principles and the evidence ladder.
- `example-images/README.md` - Owns fixture/output/gallery directory contract and generated artifact policy.

### Current Code and Test Surfaces
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Public-facade renderer executable, case matrix, output naming, recursive fixture discovery, watermarking, and default `example-images/output` path.
- `example-images/generate_gallery.py` - Current generated gallery grouping; Phase 29 should add an `eyes/` group for eye cases.
- `.gitignore` - Confirms `example-images/output/` and `example-images/gallery/` are ignored generated artifacts.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - Public model and normalization for existing eye fields.
- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` - Current eye control-point behavior for size, distance, vertical position, and tail lift.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Current eye-domain activation, skipped-domain behavior, redacted warnings, metrics, and effective strengths.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` - Current eye safety caps.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` - Current still-image geometry MVP proxy and control-point aggregation used by public-facade saved outputs.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Current renderer inventory, fixture list, public-facade import boundary, no-face summary pattern, and Phase 28 scope tests.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` - Existing provider evidence for eye size, signed distance, signed vertical position, tail lift, clamping, determinism, and missing eye inputs.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` - Existing combined-geometry weakening and redacted metric patterns.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Existing no-face, missing-eye, stale, reused, and group-specific degradation patterns.
- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py` - Best current helper pattern to mirror for full-matrix checks and top-region geometry-vs-baseline comparisons.
- `example-images/input/` - Current committed fixture directory with six portrait fixtures and one no-face negative fixture.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer` already imports only `BeautySDK`, recursively reads PNG/JPEG fixtures from `example-images/input/`, calls `BeautyEngine.processResult(image:metadata:parameters:)`, writes flat `{fixtureStem}__{caseId}.png` outputs, and defaults to `example-images/output/`.
- `geometryBaseline_noop` already exists and is the required no-geometry comparison baseline.
- `check_face_shape_renderer_outputs.py` already implements the needed standard-library PNG/JPEG dimension parsing, watermark-band exclusion, top-region byte comparison, and full output inventory pattern.
- `EyeWarpProvider` already has current behavior for `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and positive `eyeTailLift`.
- `EyeWarpProviderTests`, `CombinedEffectSafetyTests`, and `MissingLandmarkDegradationTests` already cover provider/safety/degradation patterns that Phase 30 can extend; Phase 29 should not duplicate full safety closeout.
- `example-images/generate_gallery.py` already groups generated outputs by feature family and can add an `eyes` group using the new case IDs.

### Established Patterns
- Generated renderer outputs and galleries are local artifacts, ignored under `example-images/output/` and `example-images/gallery/`.
- Public-facade saved-output evidence is required before a second-level geometry tool can be promoted, but saved-output evidence alone is not enough for Phase 29 status promotion.
- Helper evidence should compare geometry outputs against `geometryBaseline_noop`, not only against source input images.
- Evidence docs record commands, counts, dimension buckets, helper results, and factual limitations; they avoid commercial quality, device parity, broad Meitu parity, or release-readiness claims.
- Current source, root contracts, and `.planning` ledgers override stale `.planning/codebase/*` maps.

### Integration Points
- Add six eye cases to `BeautySDK/Sources/BeautyExampleRenderer/main.swift` after the Phase 28 face-shape cases or in the existing geometry case block.
- Update `BeautyRendererOutputRegressionTests` to include the new eye case IDs, assert public-facade-only imports, and guard against new public/API/commercial/network scope.
- Add a Phase 29 helper under `.planning/phases/29-eye-renderer-output-evidence/` that mirrors the Phase 28 helper and uses the locked eye case IDs.
- Update `example-images/generate_gallery.py` and `example-images/README.md` so the generated review gallery has an `eyes/` group.
- Record command-backed evidence in `29-EYE-RENDERER-EVIDENCE.md` and final verification artifacts before Phase 30 considers ledger promotion.

</code_context>

<specifics>
## Specific Ideas

- Locked Phase 29 case IDs and strengths: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, `eyeTailLift_0p25`.
- Required portrait comparison count: 36/36 eye-vs-`geometryBaseline_noop` top-region comparisons.
- Representative no-face output presence should use one eye case, preferably `eyeSize_0p35`.
- `example-images/output/` is the canonical output path. Update touched stale `example-images/out/` command text to `example-images/output/`.

</specifics>

<deferred>
## Deferred Ideas

- Eye combo renderer output is not required for Phase 29 and can be considered later only if a future phase needs combined-eye visual review.
- Status promotion for `大小`, `上下`, `眼距`, and `眼尾上扬` belongs to Phase 30 after safety/degradation/redaction evidence passes.
- Whole-branch `眼睛` completion remains future because eye height, length, pupil/gaze, lid, redness, corners, symmetry, and eye-fat controls still need separate parameter/resource design.
- Demo UI work, new public parameters, commercial quality review, device parity, broad Meitu parity, generated PNG baselines, network/cloud behavior, and launch-readiness claims remain out of scope.

</deferred>

---

*Phase: 29-Eye Renderer Output Evidence*
*Context gathered: 2026-07-09*
