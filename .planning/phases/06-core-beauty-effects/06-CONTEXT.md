# Phase 6: Core Beauty Effects - Context

**Gathered:** 2026-06-20T06:40:03Z
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase makes the existing v1 `BeautyParameters` produce real MVP visual output for skin, color-adjacent effects, face shape, eyes, nose, mouth, lip color, filters, and built-in presets through the SDK and Demo. It covers `EFFECT-01`, `EFFECT-04`, `EFFECT-05`, `EFFECT-06`, `EFFECT-07`, and `EFFECT-09`.

Phase 6 is an implementation and verification phase for core beauty effects, not a category expansion phase. It must not add new public parameter fields, new Demo categories, advanced makeup, segmentation, body shaping, stickers, AI style, video export, per-face UI, or the final Phase 7 QA/debug workflow.

</domain>

<decisions>
## Implementation Decisions

### Visible Effect Baseline
- **D-01:** Phase 6 must prove fixture-visible MVP output across all scoped domains: skin/color, face shape, eyes, nose, mouth, and lip color. Each domain should produce deterministic visible differences in tests or fixtures while staying conservative.
- **D-02:** First visible results should be plainly visible but conservative. They must be strong enough for fixture tests and human smoke checks, but must not chase maximum beauty strength or identity-changing output.
- **D-03:** Visual proof requires automated fixture evidence plus focused Demo smoke. SDK tests should prove deterministic output changes; Demo simulator or manual smoke should confirm controls visibly update.
- **D-04:** Both Camera and Photo paths must show effects, or equivalent tested output behavior, for realtime `CVPixelBuffer` and still `CIImage`/image processing.

### Naturalness Caps
- **D-05:** UI sliders may still expose the full documented display range, including `100`, but effective face, eye, nose, and mouth geometry must be safety-capped by algorithm rules before rendering.
- **D-06:** First cap values should start from `docs/06_beauty_parameters_spec.md` cap guidance, then be encoded as tested SDK constants. The spec is the source of truth for initial cap intent.
- **D-07:** Combined geometry controls must reduce compound strength when high-impact controls overlap. Individual controls keep their caps, but overlapping or compounding face, eye, nose, and mouth edits must be weakened to stay plausible.
- **D-08:** Internal cap or weakening events should appear in debug-style result metadata through `BeautyResult.warnings` or metrics. Normal UI should stay clean unless there is a real detection/resource/degradation status to show.

### Missing Landmark Behavior
- **D-09:** When no usable face is available, only non-face effects such as color and filters should continue. Face-dependent skin, face geometry, eye, nose, mouth, and lip effects should skip or no-op with warning metadata.
- **D-10:** Partial landmark failures should skip only affected domains. Missing eyes skip eye effects, missing nose skips nose effects, and missing mouth skips mouth/lip effects. Unrelated safe effects continue.
- **D-11:** Reused landmarks may drive reduced geometry briefly within the allowed reuse window. Stale landmarks disable strong geometry and emit warning metadata.
- **D-12:** Normal Demo UI should keep sliders enabled and reuse the existing short detection status/debug model. Do not add per-slider disablement, cap banners, or per-domain warning rows in Phase 6.

### Preset and Demo Feedback
- **D-13:** All five built-in presets from Phase 5 must become visibly effective in Phase 6: Natural, Clear, Refined, Male Natural, and ID Photo Natural. Output remains conservative and natural.
- **D-14:** Replace the current "Visual update pending Phase 6" copy with short transient applied/degraded feedback only when useful. Normal UI should otherwise stay quiet.
- **D-15:** Do not add new Demo controls or change category structure. Existing skin, color, face shape, eyes, nose, mouth, filters, and preset controls become visually effective behind the current UI.
- **D-16:** Focused Demo smoke should cover the panel paths for Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets enough to confirm visible updates and no clipping or regression.

### the agent's Discretion
- **D-17:** The planner and executor may choose the concrete internal effect protocols, provider names, pass names, fixture images, pixel-difference thresholds, metrics keys, and transient status copy, as long as they satisfy the decisions above and root contracts.
- **D-18:** The implementation may use pragmatic CPU/Core Image/Metal scaffolding where appropriate for deterministic MVP evidence, but it must preserve the intended `BeautyEffects` + `BeautyRender` ownership boundaries and avoid UI dependencies inside SDK targets.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Work ledger, completed Phase 1-5 evidence, and current tech debt.
- `.planning/PROJECT.md` — SDK-centered product direction, local-first privacy posture, and Demo validation role.
- `.planning/REQUIREMENTS.md` — Phase 6 covers `EFFECT-01`, `EFFECT-04`, `EFFECT-05`, `EFFECT-06`, `EFFECT-07`, and `EFFECT-09`.
- `.planning/ROADMAP.md` — Phase 6 goal, success criteria, and planned slots `06-01` through `06-05`.
- `.planning/STATE.md` — Current focus, session continuity, and known concerns.

### Prior Phase Context
- `.planning/phases/03-realtime-and-still-input-slice/03-CONTEXT.md` — Locks Camera/Photo entry flow, compare behavior, bounded realtime processing, and previous-visual preservation.
- `.planning/phases/04-detection-and-coordinate-safety/04-CONTEXT.md` — Locks metadata/result summaries, geometry-free public detection state, no-face/partial/stale degradation, and slider-enabled behavior.
- `.planning/phases/05-filters-presets-and-resource-flow/05-CONTEXT.md` — Locks color/filter/preset parameter flow, built-in preset names, filter resource validation, and the fact that visible color/filter output is Phase 6 scope.

### Root Contracts
- `ARCHITECTURE.md` — `BeautyEffects` ownership, `BeautyRender` ownership, unified `FaceWarpPass`, `Warp.metal`, and Demo facade-only invariant.
- `DESIGN.md` — 31-field `BeautyParameters`, `WarpControlPoint`, provider rules, effect model, render order, detection state machine, and degradation rules.
- `FRONTEND.md` — Existing Demo category/control structure, slider ranges, panel ownership, and debug/status boundaries.
- `SECURITY.md` — Parameter validation, algorithm-level safety caps, local-first boundary, and sensitive face/landmark handling.
- `RELIABILITY.md` — Render pass failure modes, degradation matrix, metrics/warnings expectations, and realtime constraints.
- `PRODUCT_SENSE.md` — MVP acceptance, naturalness criteria, missing-face behavior, preset expectations, and visible-effect anti-goals.
- `QUALITY_SCORE.md` — Current gaps for skin, face shape, eyes, nose, mouth, `BeautyEffects`, render fixtures, and Demo smoke.

### Historical Specs and Design References
- `docs/06_beauty_parameters_spec.md` — Initial safety cap guidance, parameter semantics, provider naming, and sample preset values.
- `docs/08_metal_render_pipeline_design.md` — Render pipeline background and pass ordering context.
- `docs/09_algorithm_effects_implementation.md` — Algorithm background for skin, color, face, eye, nose, and mouth effects.

### Current Code
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Existing public 31-field parameter model.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` — Existing result envelope with warnings, metrics, and detection summary.
- `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` — Public geometry-free detection/degradation summary.
- `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` — Current metadata-aware no-op/copy engine to replace or route through real effects.
- `BeautySDK/Sources/BeautyRender/RenderGraph.swift` — Existing pass sequencing and zero-strength skip seam.
- `BeautySDK/Sources/BeautyRender/RenderPass.swift` — Existing render pass protocol.
- `BeautySDK/Sources/BeautyRender/CopyRenderPass.swift` — Current copy pass and BGRA fixture baseline.
- `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` — Placeholder unified geometry shader file.
- `BeautySDK/Sources/BeautyEffects/BeautyEffects.swift` — Current placeholder target that Phase 6 expands.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` — Internal face/landmark model for effect-provider inputs.
- `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` — Existing coordinate mapping seam for landmark-driven effects.
- `BeautySDK/Sources/BeautySDK/BeautySDK.swift` — Public facade and testing SPI for render seams.
- `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift` — Public resource facade and filter validation.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` — App-side parameter snapshot owner and current pending-visual status copy.
- `BeautyDemo/BeautyDemo/Panel/BeautyControlDescriptor.swift` — Existing enabled controls for all Phase 6 parameters.
- `BeautyDemo/BeautyDemo/Panel/BeautyCategoryModels.swift` — Current category and facial-feature subcategory structure to preserve.
- `BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift` — Existing preset/filter/control panel composition and status row.
- `BeautyDemo/BeautyDemo/Editor/DetectionStatusPresentation.swift` — Existing short detection status and debug summary model.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already contains all Phase 6 fields; no new public parameters are needed.
- `BeautyControlDescriptor`, `BeautyCategoryModels`, and `BeautyParameterStore` already expose and normalize the Phase 6 controls in Demo.
- `BeautyResult` already has `warnings` and `metrics`, which can carry cap/degradation evidence without adding normal UI noise.
- `BeautyDetectionSummary` and `DetectionStatusPresentation` already support short no-face/partial/stale UI and debug data.
- `RenderGraph`, `RenderPass`, `CopyRenderPass`, and `PixelBufferFactory` provide the current render-test seam and pass-order baseline.
- `BeautyFaceObservation`, landmark groups, and `CoordinateMapper` provide internal detection inputs for geometry providers.

### Established Patterns
- Demo source and tests import only `BeautySDK`; this invariant must remain part of Phase 6 verification.
- Demo view state and parameter behavior are tested through deterministic XCTest rather than broad UI automation.
- User-facing copy stays short and avoids raw paths, raw framework errors, raw landmarks, and implementation details.
- SDK model validation clamps public ranges, while algorithm-level safety caps are separate internal visual-safety controls.
- Resources and presets are validated through public facade APIs; Phase 6 should not bypass Phase 5 resource contracts.

### Integration Points
- Expand `BeautyEffects` with internal effect planning, safety caps, and providers for skin/color, face shape, eyes, nose, mouth, and lip color.
- Route `BeautyEngine.processResult(...)` through validated parameters, resource validation, detection/degradation state, effect resolution, and render output while preserving compatible public APIs.
- Extend `BeautyRender` with the minimum passes needed for fixture-visible MVP evidence and zero-strength/no-face skip behavior.
- Add SDK fixture tests for default no-op, medium visible output, high-strength cap behavior, combined geometry weakening, missing landmark skips, reused/stale degradation, and preset-visible output.
- Update Demo state/status behavior to remove pending Phase 6 copy and keep existing controls/category structure.
- Add focused Demo view-state or smoke evidence for Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets panel paths.

</code_context>

<specifics>
## Specific Ideas

- Phase 6 visible output should be plainly visible but conservative, not subtle to the point of untestable and not exaggerated for demo spectacle.
- Safety caps should begin from the existing cap table in `docs/06_beauty_parameters_spec.md`.
- Built-in presets should become conservative visible presets, not just parameter bundles.
- Normal Demo UI should stay quiet most of the time; detection/degradation debug evidence belongs in result metadata and existing debug/status surfaces.
- Panel-path smoke should include no clipping/regression checks because Phase 5 still has a tracked manual visual QA debt for panel layout.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 6 scope.

</deferred>

---

*Phase: 6-Core Beauty Effects*
*Context gathered: 2026-06-20T06:40:03Z*
