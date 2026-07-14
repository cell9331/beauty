# Phase 27: Geometry Render Output and Verification Harness - Context

**Gathered:** 2026-07-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 27 produces deterministic SDK-only saved-output evidence for geometry rendering and degradation behavior through the public `BeautySDK` still-image facade. It covers `GEO-03` and `GEO-04`.

This is a geometry output foundation and verification-harness phase. It should extend the existing public-facade renderer evidence so geometry-triggering still-image parameters can produce same-dimension saved outputs, and it should verify required degradation paths with redacted metrics, warnings, helper checks, and command-backed evidence.

Phase 27 must not add SwiftUI or Demo UI work, new public `BeautyParameters`, public raw geometry APIs, raw landmark/bounding/control-point output, network/cloud behavior, committed generated PNG baselines, commercial quality claims, full Meitu parity claims, release-readiness claims, or `SHAPE_FEATURE_LEDGER.md` implementation-status promotion. Phase 28 remains the owner for per-tool `脸型` completion evidence and ledger promotion.

</domain>

<decisions>
## Implementation Decisions

### Saved-output Path
- **D-01:** Phase 27 should use a renderer-first hybrid. Add geometry cases to `BeautyExampleRenderer`, add focused tests and helper checks around that path, and create a separate SDK-only verifier only if the existing renderer cannot support a required degradation case.
- **D-02:** Geometry cases should be appended to the existing `BeautyExampleRenderer` matrix. Keep one executable and one ignored output directory, and expand docs/helper checks to include geometry cases.
- **D-03:** Try existing `example-images/input` fixtures with real public-facade detection first. This is the primary proof path because `GEO-03` is about public-facade saved-output evidence.
- **D-04:** If real fixture detection is not reliable enough for all required geometry/degradation cases, keep `BeautyExampleRenderer` real-facade-first and add a narrow fallback verifier only for unstable cases. Do not replace the main renderer proof with SPI-only evidence.

### First Geometry Scope
- **D-05:** Saved-output scope is face-shape first, with only supporting degradation needed to unblock Phase 28. Do not broaden saved-output claims to all geometry domains in Phase 27.
- **D-06:** Add one combined face-shape renderer case using existing `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength` at moderate strengths.
- **D-07:** Do not add lip, eye, nose, or mouth saved-output cases unless required for degradation evidence. Shared route behavior for those domains can remain test/helper evidence in Phase 27.
- **D-08:** Phase 27 is foundation only. Phase 28 still owns per-tool `脸型` saved-output evidence and any `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.

### Evidence Bar
- **D-09:** A Phase 27 saved-output pass means same input/output dimensions, non-identical geometry output, and redacted geometry metrics. Do not require brittle pixel-stable hashes.
- **D-10:** Compare geometry output against a no-geometry baseline, not only against the input image, so geometry-specific output changes cannot be masked by color/filter effects.
- **D-11:** Generated PNGs stay ignored under `example-images/out/`. Record commands, output counts, dimensions, helper results, and representative evidence in Markdown instead of committing PNGs or hashes.
- **D-12:** Evidence documents may include representative factual visual notes only, such as dimensions, watermark readability, and that a geometry case changed output. They must not claim commercial quality, naturalness, device parity, release readiness, or Meitu parity.

### Degradation Matrix
- **D-13:** Phase 27 must cover no-face, missing-landmark, stale/reused, and combined-strength degradation paths for `GEO-04`.
- **D-14:** Produce renderer PNG evidence for the happy path and no-face path. Missing-landmark, stale/reused, and combined-strength degradation may use focused XCTest plus helper/evidence Markdown summaries rather than PNGs for every path.
- **D-15:** For no-face saved-output evidence, use a dedicated no-face fixture or the narrow fallback verifier. Do not depend on current portrait fixtures naturally producing no-face behavior.
- **D-16:** Missing-landmark, stale/reused, and combined-strength evidence should include focused XCTest plus helper/evidence summaries that assert redacted metrics/warnings and record exact cases.
- **D-17:** Degradation evidence must forbid raw geometry leakage and overclaim wording: no coordinates, landmarks, bounding boxes, control points, raw Vision/framework errors, local paths, image bytes, quality claims, parity claims, or release-readiness claims.

### the agent's Discretion
The planner may choose exact geometry case IDs, moderate strengths, helper filenames, test filenames, command shapes, evidence document names, and whether the fallback verifier is needed. Keep the fallback verifier narrow and explicitly labeled as fallback evidence. Preserve the public-facade renderer as the primary proof path.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger and requirement to record verifiable changes.
- `.planning/PROJECT.md` - Defines v1.5 as SDK geometry output foundation plus the `脸型` existing-parameter slice, with no UI/product breadth expansion.
- `.planning/REQUIREMENTS.md` - Defines `GEO-03` and `GEO-04` for Phase 27 and reserves `FACE-*`/`DOC-*` completion work for Phase 28.
- `.planning/ROADMAP.md` - Defines Phase 27 goal, dependency on Phase 26, success criteria, and Phase 28 ownership.
- `.planning/STATE.md` - Records current focus as Phase 27 after Phase 26 completion.
- `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md` - Locks public still-image geometry activation, selected-face routing, raw-geometry privacy, and Phase 27 ownership for saved-output evidence.
- `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md` - Locks renderer matrix ownership, ignored generated-output policy, invariant-helper pattern, and no-overclaim rules.
- `.planning/phases/25-security-distribution-review-and-closeout/25-CONTEXT.md` - Locks active-source privacy/security scan boundaries and conservative evidence wording.

### Root Contracts
- `ARCHITECTURE.md` - Owns package boundaries, public `BeautySDK` facade, internal detection/effects/render responsibilities, and no UI in SDK targets.
- `DESIGN.md` - Owns `BeautyParameters`, `BeautyInputMetadata`, `BeautyDetectionSummary`, internal detection/geometry models, coordinate model, and degradation contracts.
- `SECURITY.md` - Owns local-first privacy, face landmark/bounding box sensitivity, public summary privacy, logging/metric redaction, and no raw geometry leakage.
- `RELIABILITY.md` - Owns typed errors, degrade-before-fail behavior, detection degradation matrix, metrics/log redaction, and reset/recovery rules.
- `PRODUCT_SENSE.md` - Owns still-image geometry-intent acceptance, no-face/partial-face acceptance, and anti-overclaim constraints.
- `QUALITY_SCORE.md` - Records Phase 26 geometry facade evidence and identifies Phase 27 saved-output geometry evidence as the next move.

### Blueprint and Evidence Contracts
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Defines current `BeautyExampleRenderer` commands, ignored output policy, output naming, watermark expectations, Phase 24 helper command, and the geometry limitation Phase 27 addresses.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - Defines branch-level statuses and prevents treating provider/resolver evidence as visible completion.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` - Owns second-level `美型 / 五官` tool status and prevents marking `脸型` rows implemented before Phase 28 evidence.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` - Defines the evidence ladder and SDK-core/no-UI principles for beauty-shaping work.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` - Defines geometry branch ownership, dependencies, and facade-visible output expectation.

### Current Code and Test Surfaces
- `BeautySDK/Package.swift` - Declares internal target dependencies and `BeautyExampleRenderer` as a SwiftPM executable depending on the public facade.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Existing public-facade renderer executable, case matrix, output naming, watermark drawing, and ignored output path.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Public still-image facade path that validates parameters, resolves geometry route, and currently applies the image color pipeline.
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` - Current still-image geometry routing, detection summary, selected-face route, and redacted detection metrics.
- `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` - Existing SPI test detector seam; useful for focused tests and fallback verifier decisions, not the primary renderer proof.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Existing active/skipped domains, geometry metrics, caps, no-face, stale/reused, and group-specific degradation behavior.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` - Current package-only selected-face to internal `FaceGeometry` adapter.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Existing image/pixel-buffer output path, internal `face` overloads, lip-color mask support, and public no-face/no-geometry behavior.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` - Existing geometry control-point aggregation and MVP fixture proxy helper.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` - Internal `FaceGeometry`, bounds, freshness, and control-point model that must stay private.
- `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` - Current placeholder warp shader; planning may decide whether Phase 27 remains CI/proxy-based or touches render implementation.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` - Existing public-facade geometry activation, detection degradation, metrics, and redaction tests.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Existing renderer matrix inventory, public-facade import, and no-op fixture regression tests.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Existing no-face, missing-landmark, stale/reused, geometry proxy, and redaction evidence.
- `.planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py` - Existing generated PNG invariant helper to expand or mirror for geometry cases.
- `example-images/input/` - Current fixture directory with `e1.png` through `e5.png` for real-facade renderer evidence.
- `example-images/out/` - Ignored local output directory for generated renderer PNGs.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer` already reads portrait fixtures, runs `BeautyEngine.processResult(image:metadata:parameters:)`, draws a bottom watermark, writes `{source}__{case}.png`, and imports only `BeautySDK`.
- `BeautyRendererOutputRegressionTests` already asserts renderer case inventory and no-op fixture pixel stability before watermarking.
- `check_renderer_outputs.py` already verifies generated PNG existence, non-empty files, same dimensions, and input/output byte difference for the current 45-output matrix.
- `BeautyEngineGeometryFacadeTests` already provides deterministic public-facade tests for usable face, no face, low confidence, missing landmarks, detector unavailable, timeout, disabled tracking, and raw-leak redaction.
- `BeautyColorEffectPipeline` already has internal `face` overloads and lip-color face masking, but the current public still-image engine path calls the public image pipeline without passing geometry into rendering.
- `BeautyGeometryEffectPipeline` already aggregates geometry control-point intent and has an MVP fixture proxy helper that can inform tests or a narrow fallback verifier.

### Established Patterns
- Renderer evidence goes through the public `BeautySDK` facade and keeps generated outputs ignored under `example-images/out/`.
- Public/SPI surfaces must not expose raw `BeautyFaceObservation`, `FaceGeometry`, landmarks, bounding boxes, control points, Vision objects, local paths, image bytes, raw framework errors, or raw JSON.
- Geometry provider/resolver/routing evidence is foundation evidence, not tool implementation completion.
- Evidence wording uses current-environment command facts, counts, dimensions, redacted metrics, warnings, helper results, and blocker/fallback notes rather than quality or parity claims.
- Current source, root contracts, and `.planning` ledgers override stale `.planning/codebase/*` maps.

### Integration Points
- Add the first geometry renderer case in `BeautySDK/Sources/BeautyExampleRenderer/main.swift` while preserving the executable as public-facade-only.
- Wire public still-image processing so geometry route output can change saved image output for the combined face-shape case without exposing internal geometry.
- Expand or add helper checks under Phase 27 to compare geometry output against a no-geometry baseline and verify dimensions, non-identical output, and redacted metrics.
- Add focused tests for renderer case inventory, geometry saved-output behavior, no-face output behavior, missing-landmark/stale/reused/combined-strength degradation, redaction, and no-overclaim scans.
- Update durable evidence docs only after command-backed evidence exists.

</code_context>

<specifics>
## Specific Ideas

- Start with one combined face-shape case rather than per-tool renderer cases: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength` at moderate strengths.
- The primary geometry output proof should be real-facade-first using existing `example-images/input` fixtures.
- If real fixture detection is unstable, fallback evidence must be narrow, explicit, and subordinate to the renderer proof.
- Use a no-geometry baseline comparison so the helper proves geometry-specific output changed.
- Use a dedicated no-face fixture or fallback verifier for no-face saved-output evidence.

</specifics>

<deferred>
## Deferred Ideas

- Per-tool `脸型` saved-output evidence and `SHAPE_FEATURE_LEDGER.md` implementation-status promotion belong to Phase 28.
- Eye, nose, mouth, and lip saved-output cases remain out of Phase 27 unless needed for degradation evidence.
- A separate SDK-only verifier is not a first-class parallel path; it is allowed only as a narrow fallback if the real-facade renderer cannot cover a required degradation case reliably.
- Committed generated PNG baselines, hash manifests, subjective visual-quality review, commercial readiness, broad device parity, and Meitu parity claims remain out of scope.

</deferred>

---

*Phase: 27-Geometry Render Output and Verification Harness*
*Context gathered: 2026-07-07*
