# Phase 6: Core Beauty Effects - Research

**Researched:** 2026-06-21
**Status:** Complete

## Research Goal

Answer what the planner needs to know to implement Phase 6 safely: how to turn the existing 31-field `BeautyParameters` model into conservative visible MVP output for skin, color, filters, face shape, eyes, nose, mouth, lip color, and built-in presets while preserving SDK boundaries, naturalness caps, and safe degradation.

## Source Inputs

- `.planning/phases/06-core-beauty-effects/06-CONTEXT.md`
- `.planning/phases/03-realtime-and-still-input-slice/03-CONTEXT.md`
- `.planning/phases/04-detection-and-coordinate-safety/04-CONTEXT.md`
- `.planning/phases/05-filters-presets-and-resource-flow/05-CONTEXT.md`
- `.planning/phases/05-filters-presets-and-resource-flow/05-PATTERNS.md`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `AGENTS.md`
- `PLANS.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `FRONTEND.md`
- `SECURITY.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `QUALITY_SCORE.md`
- `docs/06_beauty_parameters_spec.md`
- `docs/08_metal_render_pipeline_design.md`
- `docs/09_algorithm_effects_implementation.md`
- Current `BeautySDK/Sources`, `BeautySDK/Tests`, `BeautyDemo/BeautyDemo`, and `BeautyDemo/BeautyDemoTests`

## Phase Scope Findings

Phase 6 covers exactly these requirements:

- `EFFECT-01`: Skin smoothing, skin whitening, rosy tone, and sharpen controls produce SDK-backed visible output.
- `EFFECT-04`: Face slim, small face, V shape, jaw, and chin controls produce SDK-backed effect plans and visible/safety evidence.
- `EFFECT-05`: Eye size, eye distance, eye vertical position, and eye tail lift produce SDK-backed effect plans and coordinate evidence.
- `EFFECT-06`: Nose slim, nose wing, nose tip, and nose bridge produce SDK-backed effect plans and coordinate evidence.
- `EFFECT-07`: Mouth size, mouth width, smile, and lip color produce SDK-backed effect plans and visible/safety evidence.
- `EFFECT-09`: Defaults are no-op, presets are conservative, high intensity values are safety-capped, and face-dependent effects degrade safely when faces or landmarks are unavailable.

The user decisions in `06-CONTEXT.md` narrow the implementation:

- Output must be fixture-visible but conservative across skin/color, face shape, eyes, nose, mouth, lip color, filters, and presets.
- No public `BeautyParameters` fields, Demo categories, or new slider controls should be added.
- Safety caps start from `docs/06_beauty_parameters_spec.md` and must be encoded as tested SDK constants.
- Combined geometry controls must weaken compound strength.
- Cap/degradation evidence belongs in `BeautyResult.warnings` and `metrics`, not normal UI banners.
- No-face frames keep non-face color/filter effects but skip face-dependent skin, geometry, mouth, and lip behavior.
- Missing landmark groups skip only affected domains.
- Camera and Photo processing should both route through the same effect resolution behavior.

## Current Codebase Findings

### Public Parameters and Presets

`BeautyParameters` already contains all Phase 6 fields and clamps them:

- Skin: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`
- Color: `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`
- Face shape: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`
- Eyes: `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`
- Nose: `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`
- Mouth: `mouthSize`, `mouthWidth`, `smile`, `lipColor`
- Filter: `filterId`, `filterIntensity`

Planning implication:

- Do not add public fields.
- Add algorithm-level caps and effect-plan values in `BeautyEffects`, not by narrowing public parameter ranges.
- Add tests that prove high UI values remain accepted at the public model while effective strengths are capped internally.

The five Phase 5 presets already include conservative non-zero values:

- `natural`
- `clear`
- `refined`
- `male-natural`
- `id-photo-natural`

Planning implication:

- Phase 6 should make existing preset parameter bundles visibly effective.
- Preset tests should assert visible pixel deltas for non-zero presets and no-op output for identity-like preset values such as `id-photo-natural` where appropriate.

### Engine and Render State

`BeautyEngine` currently:

- Normalizes parameters.
- Validates BGRA pixel buffers.
- Returns copied BGRA output for `process(pixelBuffer:metadata:parameters:)`.
- Returns cropped identity `CIImage` for `process(image:metadata:parameters:)`.
- Emits `.notRun` or `.disabled` detection summaries.

`BeautyRender` currently:

- Has a simple `RenderGraph` that applies `RenderPass` values in order.
- Has `CopyRenderPass` and `PixelBufferFactory`.
- Has a placeholder `Warp.metal` copy kernel.

`BeautyEffects` currently:

- Is only a module marker.
- Has no effect planner, safety caps, provider layer, visible effect pass, or tests.

Planning implication:

- Phase 6 must add a real `BeautyEffects` model before engine routing.
- The safest MVP route is to introduce deterministic CPU/Core Image-capable effect output and effect-plan tests first, then leave full Metal optimization for later unless needed by existing test/build constraints.
- For pixel-buffer tests, a small BGRA fixture path can prove visible deltas without requiring a live simulator camera or GPU-only implementation.
- `RenderGraph` and `CopyRenderPass` can remain the low-level render seam while Phase 6 adds `BeautyEffectPipeline` or equivalent composition.

### Detection and Landmarks

`BeautyDetection` currently has internal face observation and landmark groups:

- `BeautyFaceObservation`
- `BeautyFaceLandmarks`
- `BeautyLandmarkGroup`
- `CoordinateMapper`
- Face selection and Vision adapter seams

Current landmark groups are minimal:

- `faceContour`
- `leftEye`
- `rightEye`
- `nose`
- `outerLips`

Planning implication:

- Phase 6 can implement MVP provider tests with existing groups and estimated positions from bounds/landmark availability.
- Detailed control point geometry can be validated through plan/provider output before high-quality mesh warp exists.
- Missing group behavior should be tested by constructing internal observations with only selected groups.
- If internal types need to be shared with `BeautyEffects`, either make a narrow internal-public SPI inside the package or add facade-free internal types in `BeautyEffects`; do not expose face geometry through public `BeautySDK`.

### Warnings and Metrics

`BeautyResult` already supports:

- `warnings: [BeautyValidationWarning]`
- `metrics: [String: Double]`
- `detectionSummary: BeautyDetectionSummary?`

`BeautyValidationWarning` is a small public value with `code` and `message`.

Planning implication:

- Use stable warning codes such as `face_effects_skipped_no_face`, `geometry_strength_capped`, `combined_geometry_weakened`, `missing_eye_landmarks`, `missing_nose_landmarks`, and `missing_mouth_landmarks`.
- Use metrics keys that are counts or effective strengths, not face geometry: for example `beauty.effects.activeCount`, `beauty.effects.geometryPointCount`, `beauty.effects.cappedCount`, `beauty.effects.skippedFaceDomains`.
- Do not include bounding boxes, landmarks, raw Vision errors, file paths, or image bytes in warnings or metrics.

### Demo State

`BeautyParameterStore` currently shows:

- Primary text: `Parameters applied`
- Secondary text: `Visual update pending Phase 6`

The existing category and control structure already includes all Phase 6 controls:

- Beauty panel: skin plus color controls.
- Face Shape panel: all face-shape controls.
- Facial Features subcategories: Eyes, Nose, Mouth available; Eyebrows, Teeth, Hairline disabled.
- Filters panel: `None`, `Soft Clean`, `Warm Light`, `Filter Intensity`.
- Preset chips: five built-in presets.

Planning implication:

- Remove or replace only the stale secondary copy. Do not add cap banners, per-slider disablement, or per-domain warning rows.
- View-state tests should prove the stale `Visual update pending Phase 6` string is gone and controls/category structure remains unchanged.
- Focused Demo smoke can remain value-driven XCTest plus optional simulator/manual smoke; Phase 7 owns full QA/debug workflow polish.

## Recommended Implementation Shape

### Core Effect Model

Add a small internal effect planning layer in `BeautyEffects`.

Recommended types:

- `BeautyEffectDomain`
  - `skin`
  - `color`
  - `filter`
  - `faceShape`
  - `eyes`
  - `nose`
  - `mouth`
  - `lipColor`
- `BeautyEffectRequirement`
  - no face required
  - requires face contour
  - requires eyes
  - requires nose
  - requires mouth
- `BeautyEffectPlan`
  - active domains
  - capped parameter strengths
  - skipped domains
  - warnings
  - metrics
  - render instructions
- `BeautySafetyCaps`
  - constants copied from `docs/06_beauty_parameters_spec.md`
  - compound weakening policy for geometry domains
- `BeautyEffectResolver`
  - input: `BeautyParameters`, optional face/degradation context, resource/filter validation result
  - output: `BeautyEffectPlan`

Keep this layer pure and testable. It should not allocate Metal resources or read Demo state.

### Safety Cap Constants

Initial cap values from `docs/06_beauty_parameters_spec.md`:

| Parameter | Cap |
| --- | ---: |
| `skinSmoothing` | 0.60 |
| `skinWhitening` | 0.50 |
| `skinRosy` | 0.40 |
| `faceSlim` | 0.60 |
| `faceSmall` | 0.45 |
| `faceVShape` | 0.50 |
| `chinLength` | 0.35 |
| `eyeSize` | 0.45 |
| `eyeDistance` | 0.30 |
| `eyeYPosition` | 0.25 |
| `eyeTailLift` | 0.30 |
| `noseSlim` | 0.35 |
| `noseWingSlim` | 0.35 |
| `noseTipSize` | 0.30 |
| `mouthSize` | 0.35 |
| `mouthWidth` | 0.35 |
| `smile` | 0.50 |
| `lipColor` | 0.50 |

The spec does not list explicit caps for these fields, so planning should set conservative first-version constants and document them in tests:

- `skinSharpen`: 0.40, from algorithm doc guidance.
- `noseBridge`: 0.30, because it is partly light/shadow and should not become pure geometric distortion.
- Color fields: use conservative uniform scales that preserve no-op defaults and avoid overexposure.
- Filter intensity: keep public `0...1`, but Phase 5 metadata filters should have conservative style transforms and no raw LUT assets.

Compound geometry policy:

- Face shape total effective displacement should weaken when `faceSlim + faceSmall + faceVShape + jawSlim + abs(chinLength)` is high.
- Eye compound strength should weaken when `abs(eyeSize) + abs(eyeDistance) + abs(eyeYPosition) + abs(eyeTailLift)` is high.
- Nose compound strength should weaken when `noseSlim + noseWingSlim + abs(noseTipSize) + noseBridge` is high.
- Mouth compound strength should weaken when `abs(mouthSize) + abs(mouthWidth) + smile` is high.
- Cross-domain compound strength should weaken when multiple high-impact geometry domains are active together.

Recommended test evidence:

- Max public values remain in `BeautyParameters`.
- Effective strengths never exceed cap constants.
- Compound plans produce a `combined_geometry_weakened` warning and lower total effective strength than the independent cap sum.

### Visible MVP Rendering

For Phase 6, the research recommendation is pragmatic visible output:

1. Implement a CPU/Core Image or byte-buffer backed MVP effect pipeline that can process:
   - small BGRA fixtures for SDK tests
   - `CIImage` still image paths
   - copied BGRA camera pixel-buffer paths
2. Keep the effect model and cap policy in `BeautyEffects`.
3. Keep `BeautyEngine` as the public routing owner.
4. Leave full `FaceWarpPass` GPU optimization as an internal implementation detail that can follow the same effect plan.

This is acceptable because Phase 6 decisions allow pragmatic CPU/Core Image/Metal scaffolding as long as boundaries are preserved.

Minimum visible behavior:

- Skin/color/filter:
  - `skinWhitening`, `skinRosy`, brightness, contrast, saturation, temperature, tint, exposure, highlight, shadow, and filter IDs can use deterministic color transforms.
  - `skinSmoothing` and `skinSharpen` can use simple fixture-visible smoothing/sharpen approximations.
  - Defaults produce exact or near-copy output.
- Lip color:
  - Uses mouth/lip context when available.
  - For MVP tests, a region-limited color enhancement is acceptable if it is derived from mouth landmarks or a fixture face context.
- Geometry:
  - Provider tests must generate plausible control points for face, eyes, nose, and mouth.
  - Pixel-visible geometry can start with conservative local displacement in test fixtures.
  - If full pixel warp is too large for one phase, plans should still make `EFFECT-04` through `EFFECT-07` verifiable through provider/control-point output, cap warnings, and at least one visible geometry fixture.

### Filter Strategy

Phase 5 filters are metadata-only:

- `soft_clean`
- `warm_light`

Phase 6 can make them visible without adding `.cube` LUT assets by mapping IDs to internal deterministic style transforms:

- `soft_clean`: mild brightness/skin-clean, low contrast, slightly softened saturation.
- `warm_light`: mild warm temperature, small exposure lift, protected highlights.

No `.cube` parser, thumbnails, swatches, or external LUT package should be introduced in Phase 6 unless plans explicitly add resource-security tests.

### Engine Routing

`BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` should:

1. Normalize parameters.
2. Validate filter resources through `BeautySDKResources` or the lower internal resource catalog without making Demo import internals.
3. Build a `BeautyEffectContext`.
4. Resolve effect plan, caps, warnings, and metrics.
5. Render or apply the MVP effect output.
6. Return `BeautyResult(output:warnings:metrics:detectionSummary:)`.

`BeautyEngine.processResult(image:metadata:parameters:)` should use the same effect resolver and equivalent CI/image effect path.

Planning should avoid adding camera-specific special cases inside the Demo.

### Detection and Degradation

Because the current engine does not yet run a real detector in `BeautyEngine`, Phase 6 needs a deterministic test seam.

Recommended approach:

- Add an internal effect-context type that can represent:
  - no face
  - usable full landmarks
  - missing eyes
  - missing nose
  - missing mouth
  - stale/reused face
- Keep it internal to SDK targets or testing SPI.
- Engine can default to `.notRun`/no-face compatible behavior until the detector is integrated, but tests can inject contexts through SPI or lower-level `BeautyEffects` tests.

Degradation rules to test:

- No face:
  - color/filter continue
  - skin face-dependent behavior, geometry, mouth, lip color skip or weaken
  - warning code appears
- Missing eyes:
  - only eyes skip
  - face/nose/mouth/color can continue
- Missing nose:
  - only nose skips
- Missing mouth:
  - mouth geometry and lip color skip
- Stale:
  - strong geometry disabled or weakened
  - warning code appears

### Demo Work

Keep Demo work small:

- Replace `Visual update pending Phase 6` with quiet/applied copy that does not imply future visual work.
- Preserve all existing category/control structures.
- Keep detection status presentation as the no-face/partial/stale UI path.
- Add view-state tests for:
  - Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets panel paths remain visible and non-clipping by model state.
  - The stale Phase 6 pending copy no longer appears.
  - Internal import scans remain clean.

## Validation Architecture

Phase 6 needs tests at three layers.

### Layer 1: Pure effect planning tests

Recommended target:

- Add `BeautyEffectsTests` to `BeautySDK/Package.swift`.

Recommended test files:

- `BeautySafetyCapsTests.swift`
- `BeautyEffectResolverTests.swift`
- `WarpProviderTests.swift`

Required assertions:

- Every Phase 6 parameter maps to either a visible effect domain or a geometry provider.
- Default parameters produce an empty/no-op plan.
- High parameters are capped to documented effective strengths.
- Compound geometry produces weakening warnings.
- No-face and missing-landmark contexts skip only affected domains.
- Warnings and metrics contain only stable codes/counts, not geometry or raw framework strings.

### Layer 2: Render/engine fixture tests

Recommended target:

- Existing `BeautyCoreTests` or `BeautySDKTests` for public engine behavior.
- Existing `BeautyRenderTests` if a render pass is added.

Required assertions:

- `BeautyEngine.process(pixelBuffer:orientation:parameters:)` with default parameters preserves BGRA bytes within no-op tolerance.
- Pixel-buffer output with skin/color/filter non-zero parameters has deterministic pixel deltas.
- `BeautyEngine.process(image:orientation:parameters:)` with equivalent parameters changes rendered CI pixels.
- All five built-in presets produce either expected visible deltas or tested identity-preserving no-op where their values are intentionally zero.
- Unknown filter IDs still fail with `BeautyError.resourceNotFound`.
- High-strength geometry plans return cap warnings through `BeautyResult.warnings` or metrics.

### Layer 3: Demo state and focused smoke tests

Recommended target:

- Existing `BeautyDemoTests`.

Required assertions:

- The stale string `Visual update pending Phase 6` is absent.
- Applying a slider or preset still surfaces short applied/degraded feedback only when useful.
- Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets panel paths still expose expected controls.
- Demo source/tests still import only `BeautySDK`.

Manual/simulator smoke:

- If available, launch Demo on an explicit simulator and open Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets enough to confirm no clipping/regression.
- If simulator UI smoke cannot be run, record the exact environment reason and keep the deterministic view-state tests as the automated gate.

## Recommended Plan Decomposition

The roadmap already proposes five plans. Research confirms this should stay:

1. `06-01`: Add the effect planning foundation plus skin, color, filter, and pixel/image fixture output.
2. `06-02`: Add face-shape provider/caps and at least one visible conservative geometry path.
3. `06-03`: Add eye and nose providers, missing-landmark behavior, and coordinate fixture tests.
4. `06-04`: Add mouth and lip color providers/output with missing-mouth degradation.
5. `06-05`: Integrate combined safety, no-face/stale degradation, Demo copy/smoke, docs, and final verification.

Dependency rationale:

- Skin/color/filter output should land before geometry because it proves the engine can produce visible output without face dependency.
- Face-shape foundation should create shared geometry/cap infrastructure used by eyes, nose, and mouth.
- Eye/nose and mouth/lip can build on the same provider/cap infrastructure.
- Combined-effect safety and Demo/doc closure should run last because it depends on all domains existing.

## Risks and Landmines

| Risk | Why It Matters | Planning Mitigation |
| --- | --- | --- |
| Overbuilding Metal before visible tests | Full GPU warp/skin pipeline is expensive and may hide failures behind simulator/device constraints. | Start with deterministic effect planning and fixture-visible output; keep Metal contracts but avoid making full shader quality the only proof path. |
| Treating safety caps as public range clamps | UI must still expose full `100` display range. | Test public parameters at max values and separate effective strength caps in `BeautyEffects`. |
| Geometry internals leaking through facade | Face landmarks and control points are sensitive and internal. | Keep geometry types internal or testing SPI; public result only gets warnings/metrics/detection summary. |
| No real detector in current engine path | Without a seam, missing-landmark behavior is untestable. | Add internal effect-context/provider tests and use testing SPI where needed; do not expose geometry to Demo. |
| Demo status copy becoming noisy | User decisions reject per-slider warnings and cap banners. | Keep UI quiet; use existing detection status/debug surfaces and result metadata. |
| Phase 5 no-op tests conflicting with visible output | Existing `EFFECT02...Noop` engine tests assert non-zero color/filter still no-op. | Replace those Phase 5-specific assertions with Phase 6 visible-output assertions while preserving default no-op tests. |
| Filter implementation scope creep | Real LUT assets require resource-security and decode tests. | Use deterministic internal transforms for `soft_clean` and `warm_light`; no `.cube` assets in Phase 6 unless separately planned. |
| Manual visual QA debt remains | View-state tests cannot prove final visual layout or naturalness. | Record deterministic fixture evidence in Phase 6 and leave broader manual/device QA as Phase 7 or tech debt if not completed. |

## Research Conclusion

Phase 6 should be planned as an implementation of a conservative, test-first effect pipeline, not as a full production-grade beauty renderer. The executable plans should make `BeautyEffects` the owner of caps, provider logic, effect resolution, warnings, and metrics; route both pixel-buffer and image engine paths through the effect pipeline; keep Demo category/control structure unchanged; and verify every scoped requirement through deterministic fixture, provider, degradation, and focused Demo tests.

## RESEARCH COMPLETE
