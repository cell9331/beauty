# Phase 28: Face Shape Slice Completion and Documentation Closeout - Context

**Gathered:** 2026-07-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 28 completes the v1.5 `脸型` existing-parameter slice after Phase 26 proved public-facade geometry activation and Phase 27 proved shared saved-output geometry foundation. It covers `FACE-01` through `FACE-06` and `DOC-01` through `DOC-03`.

This is a per-tool SDK evidence and documentation closeout phase. It should add or verify one renderer case per distinct existing face-shape SDK parameter, record focused safety/degradation evidence, promote only evidence-backed `脸型` ledger rows, and synchronize the status ledgers and root/planning docs.

Phase 28 must not add SwiftUI or Demo UI work, new public `BeautyParameters`, new geometry groups, a distinct `下颌线` algorithm, entitlement/pro behavior, public raw geometry APIs, network/cloud behavior, committed generated PNG baselines, commercial quality claims, device parity claims, broad Meitu parity claims, release-readiness claims, or whole-branch `脸型` completion claims.

</domain>

<decisions>
## Implementation Decisions

### Jawline Alias Handling
- **D-01:** `下颌线` remains a v1.5 alias of the existing product-neutral `jawSlim` SDK behavior. Phase 28 should not add a new public parameter or a distinct implementation for it.
- **D-02:** `下颌线` and `下颌角` share `jawSlim` tests, renderer output evidence, safety/degradation evidence, and verification records.
- **D-03:** `SHAPE_FEATURE_LEDGER.md`, the face-shape branch README, and Phase 28 verification must explicitly label `下颌线` as alias-backed by `jawSlim`.
- **D-04:** If `jawSlim` evidence passes, both `下颌角` and alias-backed `下颌线` should be promoted to `implemented`.
- **D-05:** Phase 28 must not add separate `下颌线` Demo behavior, entitlement/pro handling, or an algorithm split.

### Per-Tool Evidence Bar
- **D-06:** Require one renderer case per distinct existing SDK face-shape parameter: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`. `下颌线` shares the `jawSlim` renderer evidence.
- **D-07:** Each per-parameter renderer case must preserve input dimensions and show a geometry-vs-`geometryBaseline_noop` delta above the watermark band on usable portrait fixtures.
- **D-08:** `chinLength` needs both positive and negative output/test evidence because `下巴长短` is bidirectional.
- **D-09:** Degradation and safety evidence should use focused XCTest/scans rather than renderer output for every degradation variant. Required coverage includes caps, missing contour or no-face degradation, signed `chinLength`, combined weakening, redaction, and no raw geometry leakage.
- **D-10:** Renderer output does not need separate no-face, missing-landmark, stale, or reused cases for every Phase 28 tool. Phase 27 already owns shared no-face and degradation foundation evidence; Phase 28 should add only the per-tool evidence needed to support status promotion.

### Status and Documentation Closeout
- **D-11:** If all five distinct SDK parameters pass evidence, promote only the six scoped `脸型` rows: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`.
- **D-12:** Keep unscoped `脸型` tools such as `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, and `发际线` at their existing future/partial status unless direct evidence exists in this phase.
- **D-13:** Keep branch-level `脸型` status in `FEATURE_MATRIX.md` as `partial`, with a scoped completion note for the six implemented rows. Do not promote the entire `脸型` branch to `implemented`.
- **D-14:** After evidence passes, do full scoped synchronization across `SHAPE_FEATURE_LEDGER.md`, the face-shape branch README, branch-level `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, root docs/quality ledger, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`.
- **D-15:** Phase 28 wording must avoid claims about Demo UI completion, commercial visual quality, device parity, broad Meitu parity, new geometry groups, or release readiness.

### the agent's Discretion
The planner may choose exact renderer case IDs, moderate strengths, helper filenames, per-tool delta thresholds, test filenames, scan command shapes, evidence document names, and final wording. Keep those choices consistent with Phase 27's public-facade renderer pattern, ignored generated-output policy, redaction constraints, and no-overclaim rules.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger and requirement to record verifiable changes.
- `.planning/PROJECT.md` - Defines v1.5 as SDK geometry output foundation plus the `脸型` existing-parameter slice, with no UI/product breadth expansion.
- `.planning/REQUIREMENTS.md` - Defines `FACE-01` through `FACE-06` and `DOC-01` through `DOC-03` for Phase 28.
- `.planning/ROADMAP.md` - Defines Phase 28 goal, dependency on Phase 27, success criteria, and boundary against UI/commercial/parity claims.
- `.planning/STATE.md` - Records current focus as Phase 28 after Phase 27 completion.
- `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md` - Locks public still-image geometry activation, selected-face routing, raw-geometry privacy, and no Phase 26 status promotion.
- `.planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md` - Locks the public-facade renderer proof path, ignored generated PNG policy, geometry-vs-baseline evidence bar, and Phase 28 ownership for per-tool `脸型` completion.

### Root Contracts
- `ARCHITECTURE.md` - Owns package boundaries, public `BeautySDK` facade, internal detection/effects/render responsibilities, `BeautyExampleRenderer` facade-only boundary, and no UI in SDK targets.
- `DESIGN.md` - Owns `BeautyParameters`, including existing face-shape fields `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`, plus public-model update rules.
- `SECURITY.md` - Owns local-first privacy, face landmark/bounding box sensitivity, public summary privacy, logging/metric redaction, and no raw geometry leakage.
- `RELIABILITY.md` - Owns degrade-before-fail behavior, no-face/missing-landmark/stale/reused geometry degradation, metrics/log redaction, and saved-output geometry reliability evidence.
- `PRODUCT_SENSE.md` - Owns still-image geometry acceptance and anti-overclaim constraints.
- `QUALITY_SCORE.md` - Identifies Phase 28 as the current top repair queue item after Phase 27 shared geometry-output evidence.

### Blueprint and Evidence Contracts
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` - Owns second-level `美型 / 五官` tool statuses and the rule that tools become `implemented` only after SDK behavior, tests, safety/degradation evidence, and facade-visible output evidence exist.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Defines `BeautyExampleRenderer` commands, ignored output policy, current geometry cases, helper behavior, and Phase 27 evidence summary.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - Owns branch-level status semantics and should keep `脸型` as `partial` after scoped Phase 28 completion.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` - Owns beauty-shaping branch contracts and evidence expectations.
- `docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md` - Owns face-shape branch business logic, current public parameter coverage, future parameter needs, and evidence expectation.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` - Defines SDK-core/no-UI principles and the evidence ladder.

### Current Code and Test Surfaces
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Public-facade renderer executable, case matrix, output naming, watermarking, and ignored output path.
- `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` - Current `faceSlim`, `faceSmall`, `faceVShape`, and `jawSlim` control-point behavior.
- `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` - Current signed `chinLength` behavior.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Current face-shape activation, effective strengths, caps, no-face/missing/stale/reused degradation, and redacted metrics.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` - Current safety caps for face-shape parameters.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Existing provider evidence for face-shape and chin behavior.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` - Existing combined weakening and cap evidence.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` - Existing face-shape conflict and weakening evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Current renderer inventory, facade-only import, no-face summary, and Phase 27 face-shape-only scope evidence.
- `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` - Existing geometry-output helper pattern to extend or mirror for per-tool Phase 28 checks.
- `example-images/input/` - Current fixture directory with portrait and no-face inputs for renderer evidence.
- `example-images/out/` - Ignored local output directory for generated renderer PNGs.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer` already runs `BeautyEngine.processResult(image:metadata:parameters:)` through the public `BeautySDK` facade, writes watermarked PNGs, and imports no internal SDK targets.
- `geometryBaseline_noop` and `faceShapeCombo_0p35` already establish the Phase 27 geometry-output foundation and comparison pattern.
- `BeautyRendererOutputRegressionTests` already verifies renderer case inventory, public-facade import boundaries, no-face summary behavior, and face-shape-only scope.
- `FaceShapeWarpProviderTests` already has focused provider coverage for `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, missing contour, and signed `chinLength`.
- Phase 27's `check_geometry_renderer_outputs.py` already verifies output count, same dimensions, geometry-vs-baseline top-region deltas, and no-face output presence.

### Established Patterns
- Generated PNGs stay ignored under `example-images/out/`; Markdown evidence records commands, counts, dimensions, helper results, and factual observations.
- Geometry status promotion is evidence-led: provider/resolver evidence alone is partial; facade-visible saved output is required for `implemented`.
- Public/SPI surfaces must not expose raw `BeautyFaceObservation`, `FaceGeometry`, landmarks, bounding boxes, control points, Vision objects, local paths, image bytes, raw framework errors, or raw JSON.
- Current source, root contracts, and `.planning` ledgers override stale `.planning/codebase/*` maps.
- Evidence wording should remain conservative and current-environment based.

### Integration Points
- Add or verify per-tool face-shape renderer cases in `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.
- Update renderer inventory tests and geometry-output helper coverage for the new Phase 28 cases.
- Add or extend focused tests for per-tool activation, caps, bidirectional `chinLength`, no-face/missing contour degradation, combined weakening, and redaction.
- Update durable evidence docs and status ledgers only after command-backed evidence exists.

</code_context>

<specifics>
## Specific Ideas

- Use one renderer case per distinct SDK parameter: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and both positive and negative `chinLength`.
- Treat `下颌线` as alias-backed by the `jawSlim` case rather than creating a separate parameter, renderer case, or algorithm.
- Preserve Phase 27's geometry-vs-baseline comparison above the watermark band for Phase 28 per-tool output evidence.
- Keep the branch-level `脸型` matrix status as `partial` even when the six scoped rows become `implemented`.

</specifics>

<deferred>
## Deferred Ideas

- A distinct `下颌线` SDK behavior or product-neutral parameter can be considered in a future phase after v1.5.
- Whole-branch `脸型` completion remains future because unscoped tools such as smooth face contour, temple, cheekbone, double-chin removal, pointed chin, and hairline still need separate design/evidence.
- Demo UI work, commercial quality review, device parity, broad Meitu parity, new geometry groups, and release-readiness claims remain out of scope.

</deferred>

---

*Phase: 28-Face Shape Slice Completion and Documentation Closeout*
*Context gathered: 2026-07-07*
