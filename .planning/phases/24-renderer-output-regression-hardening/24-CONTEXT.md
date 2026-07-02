# Phase 24: Renderer Output Regression Hardening - Context

**Gathered:** 2026-07-02
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 24 promotes `BeautyExampleRenderer` from closeout evidence into a stable renderer output regression gate. It covers `RENDER-01`, `RENDER-02`, `RENDER-03`, and `RENDER-04`.

This is a renderer QA and evidence-hardening phase. It should protect the current public-facade visible-output matrix, add no-op near-copy regression evidence for current example fixtures, verify generated visible outputs through mechanical invariants plus factual observations, and preserve honest geometry-heavy branch status.

Phase 24 must not add product-feature breadth, public `BeautyParameters`, Demo UI, new product routes, commercial visual-quality claims, Meitu parity claims, or geometry saved-output implementation. Generated PNGs remain ignored local artifacts unless a later phase explicitly changes the evidence policy.

</domain>

<decisions>
## Implementation Decisions

### Renderer Matrix Source
- **D-01:** `BeautyExampleRenderer` code is the primary source of truth for the renderer case matrix. The current case list in `BeautySDK/Sources/BeautyExampleRenderer/main.swift` is canonical; docs, tests, and evidence must mirror and verify it.
- **D-02:** Phase 24 should add or record a focused static inventory check for the current 9 case IDs. The check should catch added, removed, or renamed cases unless docs/evidence are updated intentionally.
- **D-03:** The durable public-facade renderer matrix should live in `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, with Phase 24 command results and regression evidence recorded under `.planning/phases/24-renderer-output-regression-hardening/`.
- **D-04:** Do not add renderer cases by default. The current 9 visible skin/color/filter cases remain the gate. Any added case must be justified as coverage for existing behavior, not new feature scope.

### No-op Tolerance
- **D-05:** The no-op regression check should target facade output before watermarking. Use `BeautyEngine.processResult(image:metadata:parameters:)` with default `BeautyParameters` against fixture images, then compare rendered output before any `BeautyExampleRenderer` watermark is drawn.
- **D-06:** Use exact rendered-pixel equality where the current CIImage no-op path is deterministic. A small fallback tolerance is allowed only if implementation records a specific platform color-management reason and documents the tolerance used.
- **D-07:** Cover all current example fixtures: `example-images/input/e1.png` through `example-images/input/e5.png`.
- **D-08:** Deterministic no-op pixel drift is a hard failure. The only acceptable non-fail path is a documented platform color-management reason plus the explicit fallback tolerance from D-06.

### Visible Output Checks
- **D-09:** For the current 45 generated visible-output PNGs, automatically verify mechanical invariants plus a change signal: output files exist, are non-empty, match input dimensions, and differ from the corresponding input for visible cases.
- **D-10:** Watermark readability should be handled by recorded factual inspection, not OCR or brittle pixel heuristics. Evidence should include representative notes that the bottom watermark is readable and does not cover the face.
- **D-11:** Store visible-output evidence in Phase 24 Markdown only. Generated PNGs stay ignored under `example-images/out/`; do not commit selected PNGs and do not introduce another generated-output location by default.
- **D-12:** Describe visible changes with factual non-quality wording only. Acceptable wording: output differs for the current case, dimensions match, watermark is readable. Forbidden wording: commercial quality, production naturalness, release readiness, all-device parity, or Meitu parity.

### Geometry Status Guard
- **D-13:** Phase 24 should guard geometry-heavy branch status only. Do not implement geometry saved-output, and do not add a geometry probe unless planning finds a narrow static scan is needed.
- **D-14:** Preserve the current strict status model: `3D塑颜` remains `blocked-by-geometry-output`; shaping branches such as `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` remain `partial`; `眉毛` and unpromoted branches remain `future` unless real public-facade output evidence exists.
- **D-15:** A future geometry branch may move to `implemented` only after public facade detection plus geometry rendering produces same-dimension, watermarked saved outputs through `BeautyExampleRenderer`.
- **D-16:** Phase 24 should include static overclaim scans plus explicit non-claim text in evidence/docs so geometry provider/resolver tests are not mistaken for saved-image visual completion.

### the agent's Discretion
The planner may choose exact test/helper names, scan commands, case-inventory assertion shape, image-difference implementation, evidence artifact filenames, and representative images for factual watermark inspection. Keep the phase conservative: no new feature scope, no committed PNGs, no brittle OCR, no quality overclaims, and no geometry implementation.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger, update rules, v1.4 technical-debt routing, and current top repair queue.
- `.planning/PROJECT.md` - Defines v1.4 as stability, QA, performance, security, and debt cleanup without product-feature expansion.
- `.planning/REQUIREMENTS.md` - Defines `RENDER-01`, `RENDER-02`, `RENDER-03`, and `RENDER-04`.
- `.planning/ROADMAP.md` - Defines Phase 24 goal, dependency, success criteria, and no existing plans.
- `.planning/STATE.md` - Records current focus as Phase 24 after Phase 23 completion.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md` - Locks evidence-first baseline behavior, stale codebase-map handling, and blocker honesty rules.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` - Records the current renderer build/run baseline: 45 ignored outputs across 5 fixtures and 9 visible cases.
- `.planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md` - Defers renderer output regression to Phase 24 and preserves non-claim rules from performance evidence.

### Root Contracts
- `QUALITY_SCORE.md` - Identifies Phase 24 renderer regression as the top repair queue item and requires evidence-backed score changes only.
- `ARCHITECTURE.md` - Owns SDK/Demo boundary, public facade rule, and no UI in SDK targets.
- `DESIGN.md` - Owns public model/parameter contracts and no public parameter expansion by default.
- `RELIABILITY.md` - Owns regression evidence, no-op expectations, release-readiness caveats, and non-overclaim framing.
- `SECURITY.md` - Owns local-first privacy and redaction boundaries that renderer evidence must not violate.
- `PRODUCT_SENSE.md` - Owns acceptance criteria and release-hardening caveats around visual evidence and product claims.

### Renderer and Blueprint Contracts
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Durable renderer matrix, output rules, commands, watermark expectations, and geometry limitation.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - Strict branch status model and current geometry-heavy branch classifications.
- `docs/meitu-function-blueprint/MODULES.md` - Example-image verification ownership and public-facade renderer boundary.
- `.planning/phases/16-example-image-validation-harness/16-RESEARCH.md` - Original renderer harness behavior, commands, output naming, ignored output policy, and no-overclaim rules.
- `.planning/phases/20-core-module-closeout/20-RESEARCH.md` - Current 9-case renderer matrix, all-case evidence bar, and geometry saved-output limitation.
- `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` - v1.3 closeout evidence for full SDK tests, renderer build/run, same-dimension outputs, and geometry limitations.

### Current Code Surfaces
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Canonical code-owned case list, public `BeautySDK` facade use, output naming, and watermark drawing.
- `BeautySDK/Package.swift` - Declares `BeautyExampleRenderer` as a SwiftPM executable depending only on `BeautySDK`.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Public facade image path for no-op and visible-output regression checks.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Current color/skin/filter path that returns cropped no-op output when no visible color output exists.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - Existing facade no-op, visible-output, warning/metric, redaction, and reset evidence patterns.
- `example-images/input/e1.png` - Current fixture set member for no-op and renderer-output checks.
- `example-images/input/e2.png` - Current fixture set member for no-op and renderer-output checks.
- `example-images/input/e3.png` - Current fixture set member for no-op and renderer-output checks.
- `example-images/input/e4.png` - Current fixture set member for no-op and renderer-output checks.
- `example-images/input/e5.png` - Current fixture set member for no-op and renderer-output checks.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer` already accepts `--input`, `--output`, and optional `--case`, loads PNG/JPEG fixtures, runs `BeautyEngine.processResult(image:metadata:parameters:)`, writes `{source}__{case}.png`, and prints `wrote ...` lines.
- The current renderer case list contains 9 visible cases: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `brightness_plus0p25`, `contrast_plus0p25`, `filter_softClean_0p50`, `filter_warmLight_0p50`, and `skinCombo_0p50`.
- `example-images/input/` currently contains 5 fixture PNGs, producing the current 45-output matrix when all renderer cases run.
- `BeautyEngine.processResult(image:metadata:parameters:)` and `BeautyColorEffectPipeline.apply(to:plan:)` support a no-op check before renderer watermarking.
- `BeautyEngineTests` already contains pixel-equality no-op patterns and visible-output `XCTAssertNotEqual` patterns that Phase 24 can adapt or extend.

### Established Patterns
- Generated renderer outputs stay under ignored `example-images/out/`.
- Renderer validation must go through the public `BeautySDK` facade and must not import internal SDK targets or SwiftUI/UIKit.
- Evidence claims must include exact commands, output counts, dimensions, pass/fail/blocker status, and no-overclaim wording.
- Current source, root docs, and `.planning` ledgers override stale `.planning/codebase/*` maps.
- Provider/resolver geometry tests are useful partial evidence, not saved-image visual completion.

### Integration Points
- Phase 24 evidence should live under `.planning/phases/24-renderer-output-regression-hardening/`, likely as a focused renderer evidence Markdown file plus plan summaries after execution.
- Durable matrix documentation should update `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` only where Phase 24 produces verified facts.
- Static scans should cover `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, blueprint docs, root docs touched by the phase, and Phase 24 evidence artifacts.
- Verification should include `swift build --package-path BeautySDK --product BeautyExampleRenderer`, the all-case renderer run, no-op fixture regression, generated-output invariant checks, facade-only import scans, and geometry overclaim scans.

</code_context>

<specifics>
## Specific Ideas

- Treat the renderer case list as code-owned, not a doc-owned matrix.
- Keep Phase 24 focused on current visible skin/color/filter output and regression evidence.
- Test no-op behavior before watermarking so the watermark does not pollute the comparison.
- Use factual observations for watermark readability and visible change; avoid OCR, subjective quality review, and committed binaries.

</specifics>

<deferred>
## Deferred Ideas

- Geometry saved-image output implementation is deferred until public facade detection plus geometry rendering can produce same-dimension, watermarked outputs through `BeautyExampleRenderer`.
- New renderer cases are deferred unless a later plan justifies them as existing-behavior coverage.
- Commercial visual quality, production naturalness, release readiness, all-device parity, and Meitu parity claims remain outside Phase 24.
- Committed PNG baselines, OCR-based watermark checks, and broader visual-diff infrastructure are deferred to a future explicit visual-regression phase.

</deferred>

---

*Phase: 24-Renderer Output Regression Hardening*
*Context gathered: 2026-07-02*
