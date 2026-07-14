# Phase 19: Beauty Shaping Core Modules - Context

**Gathered:** 2026-06-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 19 implements or prepares promoted beauty-shaping module logic behind existing `BeautySDK` boundaries for `BSHAPE-01`, `BSHAPE-02`, and `BSHAPE-03`.

This phase is SDK-only core module work. It does not add SwiftUI screens, does not change Demo UI, does not expand public `BeautyParameters`, and does not attempt to wire public facade face detection plus geometry render output into saved example-image renderer cases. Current face/facial-feature shaping work should strengthen existing provider, resolver, degradation, tests, and blueprint evidence while keeping geometry saved-image output status honest.

The active branch scope is `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛`. Existing face-shape, eye, nose, mouth, proportion, and lip-color coverage remains partial unless public facade saved-image output exists. `3D塑颜` remains blocked by geometry output. `眉毛` remains future.

</domain>

<decisions>
## Implementation Decisions

### SDK-Only Scope
- **D-01:** Phase 19 is limited to `BeautySDK` core module logic, SDK tests, and blueprint/planning documentation. Do not add or redesign SwiftUI screens, Demo routes, category rails, tool panel UI, or app-side interaction state.
- **D-02:** Demo and editor-shell behavior remains app-owned and out of Phase 19 except for static docs that describe existing ownership. Any UI work belongs to another explicit phase.
- **D-03:** Automated verification can run directly against `BeautySDK` with SwiftPM. Phase 19 completion should not depend on launching Demo UI or simulator UI tests.

### Geometry Output Status
- **D-04:** Do not attempt to wire public facade geometry saved-image output in Phase 19. The phase should not make `BeautyEngine.processResult(image:)` feed face detection plus geometry render integration into `BeautyExampleRenderer`.
- **D-05:** Geometry-heavy branches must keep honest status. Provider/unit/control-point/MVP proxy evidence can support `partial`, but does not count as public facade saved-image visual completion.
- **D-06:** The blocker must be explicit in docs and summaries: public facade detection plus geometry render integration must produce same-dimension, watermarked renderer outputs before face-shape, eye, nose, mouth, eyebrow, proportion, or 3D sculpt branches can claim visible completion.

### Public Parameter Boundary
- **D-07:** Do not add public `BeautyParameters` fields in Phase 19. Use only existing public fields:
  `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`,
  `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`,
  `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`,
  `mouthSize`, `mouthWidth`, `smile`, and `lipColor`.
- **D-08:** Advanced subtools such as forehead, mid-face, philtrum, cheekbone, double chin, eye height/length, pupil/gaze, nose lift/root split, M-lip, teeth, and eyebrow controls remain future parameter needs.
- **D-09:** Any future public parameter expansion requires updates to `DESIGN.md`, product acceptance criteria, compatibility tests, and Demo mapping before implementation can claim support.

### Branch Status and Promotion Scope
- **D-10:** `脸型` remains `partial`. Phase 19 may strengthen face/chin provider evidence, resolver behavior, degradation behavior, docs, and tests for existing parameters only.
- **D-11:** `眼睛` remains `partial`. Phase 19 may strengthen eye provider, missing-eye, stale/reused, cap, and redaction evidence for existing parameters only.
- **D-12:** `鼻子` remains `partial`. Phase 19 may strengthen nose provider, missing-nose, stale/reused, cap, and redaction evidence for existing parameters only.
- **D-13:** `嘴唇` remains `partial`. Mouth geometry remains partial; `lipColor` may continue to be described as existing visible color evidence, but it does not make the full lips branch implemented.
- **D-14:** `比例` remains `partial`. Only `faceSmall` indirect coverage may be claimed; advanced proportion controls remain future needs.
- **D-15:** `3D塑颜` remains `blocked-by-geometry-output`. Do not implement pose-aware 3D sculpt, symmetry, vertical, horizontal, or tilt controls in Phase 19.
- **D-16:** `眉毛` remains `future`. Do not implement eyebrow geometry, texture synthesis, makeup/resource overlays, or public eyebrow parameters in Phase 19.

### Verification Threshold
- **D-17:** Phase 19 completion requires `swift test --package-path BeautySDK`.
- **D-18:** Focused verification should include shaping-related tests: `FaceShapeWarpProviderTests`, `EyeWarpProviderTests`, `NoseWarpProviderTests`, `MouthWarpProviderTests`, `GeometryConflictResolverTests`, `MissingLandmarkDegradationTests`, and `BeautyEffectResolverTests`.
- **D-19:** Plans must include scans proving branch docs did not overclaim `implemented`, no public parameters were added, no UI/SwiftUI work was added, no renderer geometry cases or fake saved-image claims were added, and warnings/metrics do not expose landmarks, control points, bounding boxes, raw Vision objects, local paths, or image bytes.
- **D-20:** Renderer build or current skin/color/filter renderer cases may be run as optional regression evidence, but they are not required Phase 19 gates because this phase deliberately does not promote geometry saved-image output.

### the agent's Discretion
The planner may choose the exact plan split, test grouping, scan commands, and wording updates as long as the decisions above remain intact. Implementation should be conservative: strengthen existing SDK/provider behavior and evidence without expanding public API or pretending geometry output is visually complete.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Work ledger, update rules, current v1.3 next-step state, and dirty-worktree caution.
- `.planning/PROJECT.md` — Defines v1.3 as no-new-UI core beauty module work.
- `.planning/REQUIREMENTS.md` — Defines `BSHAPE-01`, `BSHAPE-02`, and `BSHAPE-03` and maps them to Phase 19.
- `.planning/ROADMAP.md` — Defines Phase 19 goal, success criteria, and planned slots `19-01` through `19-03`.
- `.planning/STATE.md` — Records current milestone state and Phase 19 as current focus.
- `.planning/phases/16-example-image-validation-harness/16-CONTEXT.md` — Locks renderer evidence rules, ignored output policy, and geometry-output limitation.
- `.planning/phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md` — Locks status taxonomy, evidence ladder, Demo-vs-SDK ownership, and parameter expansion rules.
- `.planning/phases/18-skin-retouch-core-modules/18-CONTEXT.md` — Locks no-new-public-parameter precedent, honest renderer evidence, and future-branch negative scan pattern.

### Blueprint Contracts
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — Beauty shaping family status, ownership, parameter coverage, future parameter needs, and branch evidence expectations.
- `docs/meitu-function-blueprint/features/beauty-shaping/3d-sculpt/README.md` — `3D塑颜` blocked-by-geometry-output boundary.
- `docs/meitu-function-blueprint/features/beauty-shaping/proportion/README.md` — `比例` partial coverage and future ratio controls.
- `docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md` — `脸型` existing parameter coverage and future face-shape needs.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` — `眼睛` existing parameter coverage and future eye needs.
- `docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md` — `嘴唇` mouth/lip-color coverage and future mouth/teeth handoff.
- `docs/meitu-function-blueprint/features/beauty-shaping/nose/README.md` — `鼻子` existing parameter coverage and future nose controls.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyebrows/README.md` — `眉毛` future boundary.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Branch status matrix and evidence ladder wording.
- `docs/meitu-function-blueprint/MODULES.md` — Module ownership and public facade renderer ownership.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Renderer command/output rules and geometry-output limitation.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` — Evidence ladder and branch documentation checklist.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` — v1.3 inclusion/exclusion and no-new-UI boundary.

### Root Contracts
- `ARCHITECTURE.md` — SDK target boundaries, `BeautyEffects` ownership, facade-only Demo invariant, and no public geometry/control-point leakage.
- `DESIGN.md` — Public `BeautyParameters`, detection/render/effect contracts, face geometry control-point model, and public parameter-extension rules.
- `SECURITY.md` — Local-first privacy, no upload, parameter validation, safety caps, and redacted warning/metric constraints.
- `RELIABILITY.md` — Degradation, stale/reused geometry behavior, warnings, metrics, and performance-risk framing.
- `PRODUCT_SENSE.md` — Natural-first acceptance, face/eye/nose/mouth expectations, and release-quality caveats.
- `QUALITY_SCORE.md` — Current SDK/test quality state and recurring scan expectations.

### Current SDK Evidence
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Current public shaping, mouth, and lip-color parameters.
- `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` — Face tracking configuration and defaults.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public facade path; currently resolves effects without facade-visible face geometry for saved image output.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — Current domain activation, caps, warnings, metrics, no-face, stale/reused, missing-landmark behavior, and geometry point count evidence.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — Existing effective strength caps.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` — Active/skipped domains, warnings, metrics, and effective strengths.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` — Current control-point aggregation and MVP proxy evidence surface.
- `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` — Existing face-shape provider logic.
- `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` — Existing chin provider logic.
- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` — Existing eye provider logic.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` — Existing nose provider logic.
- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` — Existing mouth provider logic.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` — Combined geometry weakening policy.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Current facade-only renderer cases; currently no geometry cases.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` — Existing face-shape/chin provider evidence.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` — Existing eye provider evidence.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` — Existing nose provider evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` — Existing mouth provider evidence.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` — Existing combined weakening and MVP proxy evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — Existing missing eye/nose/mouth/lip, stale, and reused degradation evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — Current resolver baseline and redaction evidence.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — Combined cap/weakening and redaction evidence.
- `BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift` — Lip-color visible output evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already exposes all public shaping fields Phase 19 may use. There is no need to add fields for Phase 19.
- `BeautyEffectResolver` already resolves face-shape, eyes, nose, mouth, and lip-color domains when internal `FaceGeometry` exists, and skips or weakens face-dependent domains when face geometry is missing, stale, or reused.
- `FaceShapeWarpProvider`, `ChinWarpProvider`, `EyeWarpProvider`, `NoseWarpProvider`, and `MouthWarpProvider` already generate control points for existing public parameters.
- `GeometryConflictResolver` already weakens high combined geometry strength and emits redacted warning/metric evidence.
- `BeautyGeometryEffectPipeline` already aggregates control points and has deterministic MVP proxy byte evidence, but this is provider/internal evidence, not public facade saved-image completion.
- `BeautyExampleRenderer` is facade-only and currently covers visible skin/color/filter cases. It has no geometry cases and should stay that way in Phase 19 unless a later phase wires public facade geometry output.

### Established Patterns
- Public facade and renderer validation import only `BeautySDK`; internal SDK targets remain hidden from hosts and Demo.
- Safety caps change effective strengths only. Public parameter ranges remain stable.
- Warnings and metrics may report stable domain names, counts, cap totals, geometry point counts, and redacted reason codes, but not raw geometry data.
- Unsupported Meitu subtools remain documented as future needs rather than fake-functional implementation.
- Generated image outputs remain ignored under `example-images/out/`.

### Integration Points
- `19-01` should audit current shaping docs, current public parameters, existing providers/tests, and the geometry saved-output gap.
- `19-02` should strengthen only existing SDK/provider/resolver/degradation/doc evidence without adding public parameters or UI.
- `19-03` should run `swift test --package-path BeautySDK`, focused shaping tests, branch-status scans, no-new-parameter scans, no-UI scans, no-renderer-geometry-case scans, and redaction scans.

</code_context>

<specifics>
## Specific Ideas

- Keep Phase 19 boring and honest: strengthen current SDK evidence instead of stretching the status model.
- Do not let provider evidence become a visual completion claim.
- Treat `lipColor` as existing visible color evidence inside the wider `嘴唇` branch, while keeping mouth geometry partial.
- Keep advanced Meitu subtools visible in branch docs only as future needs unless public parameters and render output are explicitly designed later.

</specifics>

<deferred>
## Deferred Ideas

- Public facade geometry saved-image output is deferred until face detection plus geometry render integration can produce same-dimension, watermarked renderer outputs through `BeautyExampleRenderer`.
- New public shaping parameters for advanced proportion, 3D sculpt, eyebrow, detailed eye, detailed nose, M-lip, teeth, and advanced face-shape controls are deferred.
- Production-grade Metal warp, dense mesh/pose-aware 3D sculpt, eyebrow resource/texture synthesis, teeth whitening, hairline adjustment, and release-readiness visual naturalness QA are deferred.

</deferred>

---

*Phase: 19-Beauty Shaping Core Modules*
*Context gathered: 2026-06-29*
