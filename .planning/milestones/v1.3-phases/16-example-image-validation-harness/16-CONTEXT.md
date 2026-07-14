# Phase 16: Example Image Validation Harness - Context

**Gathered:** 2026-06-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 16 formalizes the already-prepared no-UI example-image validation harness for v1.3 core beauty module work. It records and verifies that `BeautyExampleRenderer` can be built as a SwiftPM executable, load the current portrait fixtures from `example-images/input/`, process them only through the public `BeautySDK` facade, and write parameter-labeled, watermarked PNG outputs under the ignored `example-images/out/` directory.

This phase does not add new SwiftUI screens, does not expand Home or Editor behavior, does not implement new beauty algorithms, and does not claim geometry-heavy branches are visually complete. It is a preparation and evidence-formalization phase for `PREP-01` through `PREP-04`; core module contracts and implementation continue in Phases 17-20.

</domain>

<decisions>
## Implementation Decisions

### Phase 16 收口口径
- **D-01:** Phase 16 should record the current renderer preparation as formal GSD phase work. It should not expand the implementation scope beyond the already-prepared `BeautyExampleRenderer` path.
- **D-02:** Planning should keep the roadmap's two-part structure: `16-01` verifies the renderer executable/output path, and `16-02` closes documentation and planning-ledger evidence.
- **D-03:** Product code changes are allowed only for build/run blockers. The planner and executor should not proactively add new renderer capabilities, new cases, or new output formats in this phase.
- **D-04:** `PREP-01` through `PREP-04` completion must be based on commands rerun during Phase 16 execution, not only on prior `PLANS.md` evidence.

### 验证证据标准
- **D-05:** The required verification set is intentionally minimal: build `BeautyExampleRenderer`, run one renderer case, and use `file` to prove input/output dimensions match.
- **D-06:** The default representative case is `skinWhitening_0p50`, matching the current documentation and existing example output naming.
- **D-07:** Visual inspection should be short and factual: output is non-empty, watermark is readable, and the bottom watermark does not cover the face. Do not make subjective beauty-quality or production-naturalness claims in Phase 16.
- **D-08:** Build, renderer run, or `file` dimension-check failure blocks Phase 16 completion. Fix blocking issues before marking `PREP-*` requirements complete.

### 输出证据保存策略
- **D-09:** `example-images/out/` remains a local temporary validation-output directory and must stay ignored by git.
- **D-10:** Phase 16 should not add PNG outputs to `.planning/evidence/v1.3/` or to the repository. The evidence record should be command output, file metadata, and brief human observation text.
- **D-11:** Existing same-name files in `example-images/out/` may be overwritten by rerunning the renderer. No timestamped output directory is required.
- **D-12:** The Phase 16 summary should name a representative output, specifically `e2__skinWhitening_0p50.png`, and record that its dimensions match `example-images/input/e2.png`.

### 几何输出限制写法
- **D-13:** Geometry-heavy branches do not count as visually complete in Phase 16. This phase records the limitation and leaves saved-image geometry output to later implementation phases.
- **D-14:** The limitation should be described as blocked by integration: existing providers/tests may exist, but saved image output still needs face detection plus geometry render image-output integration.
- **D-15:** Phase 19, Beauty Shaping Core Modules, owns geometry saved-output status and verification for face/facial-feature shaping branches.
- **D-16:** Future image-output evidence for geometry branches counts only when the public `BeautySDK` facade can process `example-images/input/` fixtures and produce same-dimension, watermarked PNGs through the same local renderer path.

### Fixture 输入规则
- **D-17:** Phase 16 uses the current five inputs under `example-images/input/` and does not expand fixture coverage.
- **D-18:** Input images are the project validation entry point and may remain part of the repository; generated outputs remain ignored.
- **D-19:** Fixture naming is lightly locked for Phase 16: current files `e1.png` through `e5.png` are acceptable, and future additions should use short stable IDs.
- **D-20:** Any later phase that adds renderer cases or fixture inputs must update `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`.

### Agent 自由裁量
No user decisions were delegated to the agent. The planner may choose exact wording in `PLAN.md` and `SUMMARY.md` as long as the decisions above remain intact.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger, v1.3 preparation evidence, verification requirements, and dirty-worktree warning context.
- `.planning/PROJECT.md` — Defines v1.3 as no-new-UI core beauty module work and identifies `BeautyExampleRenderer` as the example-image validation path.
- `.planning/REQUIREMENTS.md` — Defines `PREP-01` through `PREP-04` and maps them to Phase 16.
- `.planning/ROADMAP.md` — Defines Phase 16 goal, success criteria, and planned slots `16-01` and `16-02`.
- `.planning/STATE.md` — Records current v1.3 session state, next steps, and the geometry-output concern.

### Renderer and Validation Inputs
- `BeautySDK/Package.swift` — Declares the `BeautyExampleRenderer` SwiftPM executable product and its dependency on public `BeautySDK`.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Current renderer implementation, CLI flags, built-in render cases, facade processing call, PNG writing, and watermark drawing.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Authoritative command/output rules, built-in case list, and geometry limitation for example-image validation.
- `.gitignore` — Confirms `example-images/out/` is ignored.
- `example-images/input/e1.png` — Current Phase 16 input fixture.
- `example-images/input/e2.png` — Current Phase 16 input fixture and representative dimension-check source.
- `example-images/input/e3.png` — Current Phase 16 input fixture.
- `example-images/input/e4.png` — Current Phase 16 input fixture.
- `example-images/input/e5.png` — Current Phase 16 input fixture.

### Module Boundary and Milestone Scope
- `docs/meitu-function-blueprint/README.md` — Reading order and v1.3 core beauty module planning entry.
- `docs/meitu-function-blueprint/MODULES.md` — Module ownership, facade-only renderer rule, and example-image verification ownership.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` — Milestone inclusion/exclusion boundaries and acceptance signals.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Current implemented/static/partial/future status for core beauty branches.
- `ARCHITECTURE.md` — SDK target boundaries, facade-only Demo invariant, and geometry provider/render ownership.
- `DESIGN.md` — Public parameter/result model, detection/render/effect contracts, and state-machine rules.
- `SECURITY.md` — Local-first, validation, redaction, and resource trust boundaries.
- `RELIABILITY.md` — Error/degradation/metrics/performance risk framing.
- `PRODUCT_SENSE.md` — User journey and acceptance criteria owner.
- `QUALITY_SCORE.md` — Current quality snapshot and test/verification score evidence.

### Current SDK Evidence
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public image/pixel-buffer processing entry points used by the renderer.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` — Existing SDK evidence for visible image/pixel-buffer output, resource validation, warnings, and metrics.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — Existing evidence for caps, no-face skips, combined geometry weakening, and the current gap between provider evidence and saved geometry image output.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer` already accepts `--input`, `--output`, and `--case`, defaults to `example-images/input` and `example-images/out`, enumerates PNG/JPEG inputs, and writes deterministic `source__case.png` output names.
- Built-in renderer cases already cover currently visible image-output domains: skin smoothing, whitening, rosy, sharpen, brightness, contrast, `soft_clean`, `warm_light`, and a basic skin combo.
- `BeautyEngine.processResult(image:metadata:parameters:)` is the public facade path used by the renderer. This keeps Phase 16 aligned with host-app integration boundaries.
- The watermark helper draws a bottom band with monospaced text containing the selected parameter/case display name.

### Established Patterns
- Generated images belong under ignored local output directories unless a phase explicitly creates evidence artifacts.
- Demo and renderer validation should stay facade-only; internal SDK targets, raw landmarks, and Demo SwiftUI state are not renderer dependencies.
- Existing SDK tests prove skin/color/filter output and resolver warnings/metrics. Phase 16 should verify the local CLI path, not duplicate all SDK unit coverage.
- Historical `.planning/codebase/*.md` maps are stale for current SDK existence. Current source files and root contracts take precedence.

### Integration Points
- `16-01-PLAN.md` should rerun the minimal command set and block on build/run/file failures.
- `16-02-PLAN.md` should update planning evidence and requirement status without expanding renderer behavior.
- Future Phase 19 work should extend this renderer path only after geometry output is available through the public facade.

</code_context>

<specifics>
## Specific Ideas

- The preferred completion path is formalization, not reinvention: the renderer already exists and should be recorded with fresh proof.
- `skinWhitening_0p50` is the default representative case for Phase 16 evidence.
- `example-images/out/e2__skinWhitening_0p50.png` is the representative output to cite in the summary dimension check.
- Phase 16 evidence should avoid subjective aesthetic claims and release-like visual quality claims.

</specifics>

<deferred>
## Deferred Ideas

- Expanding fixture coverage beyond the current five images is deferred to later phases.
- Adding new renderer cases is deferred unless a later phase changes the underlying visible module behavior and updates `EXAMPLE_IMAGE_VALIDATION.md`.
- Saved-image geometry output for face shape, eyes, nose, mouth, eyebrows, proportion, and 3D sculpt is deferred to Phase 19.
- Long-term visual QA, perceptual diffing, production render quality, hardware parity, and release-like naturalness remain outside Phase 16.

</deferred>

---

*Phase: 16-Example Image Validation Harness*
*Context gathered: 2026-06-26*
