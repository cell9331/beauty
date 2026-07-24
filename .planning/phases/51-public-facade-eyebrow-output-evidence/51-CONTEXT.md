# Phase 51: Public-Facade Eyebrow Output Evidence - Context

**Gathered:** 2026-07-24
**Status:** Ready for planning
**Mode:** Autonomous recommendations accepted via `--auto`

<domain>
## Phase Boundary

Add public-facade saved-image evidence for the seven Phase 49/50 eyebrow controls. This phase owns thirteen isolated renderer cases, one active portrait matrix based only on `e6.jpg`, bounded decoded-image checks for visibility/direction/locality/distinction, representative degradation/no-face evidence, disposable output/gallery publication, and actual representative-image review. Final caps, exhaustive transitions, row promotion, and branch closeout remain Phase 52.

</domain>

<decisions>
## Implementation Decisions

### Active Fixture and Matrix
- **D-01:** `example-images/input/portraits/e6.jpg` is the sole active portrait fixture; `e1.png` through `e5.png` stay parked outside `input/` and must not be restored or counted.
- **D-02:** Add exactly thirteen isolated eyebrow cases: positive and negative cases for the six signed controls plus one positive peak-definition case, expanding the renderer from 59 to 72 cases.
- **D-03:** The strict portrait matrix is exactly 72 decoded outputs for `e6.jpg`. `no-face-gradient.png` remains separate negative safety evidence and is not counted in the 72 portrait outputs.
- **D-04:** Fixture discovery, tests, helpers, and documentation must derive or lock this single-portrait contract consistently and fail closed on unexpected active portraits.

### Pixel Evidence and Semantics
- **D-05:** Use a fixed, bounded, watermark-safe eyebrow-local ROI derived from the observed face placement on `e6.jpg`, with protected eye, forehead/hair, background, and watermark regions outside the accepted effect footprint.
- **D-06:** Prove each new case differs from `geometryBaseline_noop` inside the eyebrow ROI while remaining below frozen change budgets in protected regions.
- **D-07:** Prove direct positive-versus-negative direction for all six signed controls and distinguish all seven semantic families, especially whole spacing versus head spacing and thickness versus peak.
- **D-08:** Thresholds must be calibrated from measured decoded pixels and then frozen in the helper; source/cardinality checks alone are insufficient visual evidence.

### Renderer, Facade, and Degradation
- **D-09:** Every case must use exactly one same-named public `BeautyParameters` field and the existing single `BeautySDK` facade/warp path; no test-only renderer bypass or eyebrow-special rendering path is allowed.
- **D-10:** Preserve representative no-face, missing, malformed, and partial-support behavior: dependent eyebrow work no-ops locally while safe siblings and output extent remain intact.
- **D-11:** Keep public diagnostics aggregate-only and preserve Phase 49/50 request-scoped raw-geometry and no-substitution boundaries.
- **D-12:** Do not finalize caps or promote product rows in this phase; renderer values remain provisional until Phase 52.

### Artifacts and Visual Review
- **D-13:** Clean or isolate stale ignored output before the strict run so old `e1`-`e5` files cannot satisfy inventory checks accidentally.
- **D-14:** Output and gallery inventories must be exact, duplicate-free, ignored, untracked, unstaged, regular, and disposable; the gallery groups all thirteen cases under an eyebrow family.
- **D-15:** Automated decoded-image checks are required, but the phase must also open and inspect representative `e6` eyebrow outputs before claiming that visual results match the intended semantics.
- **D-16:** If representative images show reversed direction, spill outside the brow, imperceptible motion, or collapsed semantic families, treat that as a real gap and adjust implementation/evidence rather than overriding it with source-level tests.

### the agent's Discretion
- Exact case IDs, ROI coordinates, pixel-difference metrics, frozen thresholds, helper decomposition, and representative-image montage layout may follow the established Phase 43/47 renderer-evidence patterns, provided all exact counts and semantic/protected-region requirements above remain satisfied.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` already owns the 59-case public-facade renderer and flat `{fixtureStem}__{caseId}.png` naming.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` locks renderer inventory, public parameter isolation, facade behavior, and active fixture paths.
- Historical strict output helpers and `example-images/generate_gallery.py` provide bounded decoding, ROI comparison, descriptor-safe publication, inventory bijection, and self-test patterns.

### Established Patterns
- Output phases add isolated provisional cases, focused regression tests, a self-tested strict Python helper, a clean render, exact ignored gallery publication, and owner evidence without product promotion.
- Generated images remain local ignored artifacts; only source fixtures and textual evidence are durable repository records.
- Geometry evidence uses public `BeautyEngine.processResult`, same-dimension decode, fixed regions, baseline comparisons, signed pairs, family distinctions, and no-face no-ops.

### Integration Points
- Extend the renderer case array and expected inventory in `BeautyRendererOutputRegressionTests`.
- Add a Phase 51 strict output helper and evidence record under this phase directory.
- Extend gallery grouping for the thirteen eyebrow case IDs and synchronize current planning/product/reliability/security documentation as contracts change.

</code_context>

<specifics>
## Specific Ideas

The user explicitly rejected the prior 504-image, seven-fixture matrix. Use only `e6.jpg`, actually inspect the generated eyebrow images, and do not equate passing provider/pipeline tests with correct visible output.

</specifics>

<deferred>
## Deferred Ideas

Final cap calibration, exhaustive lifecycle/safety closure, exact seven-row promotion, branch `眉毛` status, milestone audit, and release nonclaims remain Phase 52 or lifecycle work.

</deferred>
