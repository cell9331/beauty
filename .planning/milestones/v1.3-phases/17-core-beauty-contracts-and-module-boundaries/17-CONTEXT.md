# Phase 17: Core Beauty Contracts and Module Boundaries - Context

**Gathered:** 2026-06-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 17 finalizes the v1.3 core beauty contract layer before implementation phases start. It normalizes the Meitu core beauty taxonomy, branch status model, module ownership, Demo-vs-SDK boundaries, deferred-family exclusions, and verification evidence gates for `CBT-01`, `CBT-02`, `CBT-03`, and `MOD-01`.

This phase edits planning and contract documentation only. It does not implement new beauty algorithms, does not add new SwiftUI screens, does not add new renderer cases or fixtures, and does not claim geometry-heavy branches are visually complete. Phases 18 and 19 own implementation; Phase 20 owns closeout and editor-support consistency.

</domain>

<decisions>
## Implementation Decisions

### Taxonomy and Status Labels
- **D-01:** Phase 17 must replace mixed status labels such as `static/future` or `partial/future` with a strict four-state model: `implemented`, `partial`, `blocked-by-geometry-output`, or `future`.
- **D-02:** The status matrix should stay branch-level, with subtool notes. Example: `眼睛` can be `partial` because existing public parameters cover size, distance, Y position, and tail lift, while unsupported subtools such as redness remain future notes.
- **D-03:** Normalize the existing `docs/meitu-function-blueprint/` documents in place. Do not rebuild the directory structure or create a separate replacement contract when targeted edits to the current blueprint docs are enough.
- **D-04:** Each branch status note must separate current public `BeautyParameters` coverage from future parameter needs. Any later new public parameter requires updates to `DESIGN.md` and the owning acceptance contract before implementation can claim it.

### Demo-vs-SDK Ownership Boundaries
- **D-05:** Meitu-style Chinese branch names such as `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛` belong in blueprint docs and Demo taxonomy. SDK-facing concepts should stay product-neutral, such as `faceShape`, `eyes`, `nose`, `mouth`, and `skin`.
- **D-06:** Phase 17 docs must explicitly enumerate Demo ownership: category rails, labels, badges, slider mapping, compare/debug affordances, cancel/confirm, input routing, and parameter snapshot state are app-side responsibilities.
- **D-07:** SDK module ownership for each branch should use one primary owner plus dependency notes. Example: beauty shaping is primarily `BeautyEffects`, depends on `BeautyDetection` landmarks and `BeautyRender` unified warp output, and may reference `BeautyResources` only when a branch truly needs resources later.
- **D-08:** `BeautyResources` should appear only as a dependency or future owner where needed. Resource/style systems such as filters, makeup, stickers, templates, downloads, VIP, and entitlement behavior remain excluded from v1.3 core beauty contracts.

### Verification and Evidence Gates
- **D-09:** Phase 17 itself verifies documentation and boundaries only: blueprint/root-contract consistency, branch/status normalization, facade-only Demo and renderer imports, no new SwiftUI screens, and no Demo imports of internal SDK targets. Algorithm output is not a Phase 17 requirement.
- **D-10:** Later implementation phases should use an evidence ladder by capability type. `implemented` requires tests plus example-image output when the public facade can produce visible output; `partial` may have provider/unit evidence but missing facade-visible output; `blocked-by-geometry-output` requires an explicit detection/render integration blocker; `future` makes no v1.3 implementation claim.
- **D-11:** Existing geometry provider and resolver tests count as provider evidence for `partial`, not visual completion. Geometry branches are not visually complete until `BeautyEngine.processResult(...)` can feed face detection and geometry render integration through the public `BeautySDK` facade to produce same-dimension saved outputs via the local renderer path.
- **D-12:** Root contracts such as `ARCHITECTURE.md`, `DESIGN.md`, and `FRONTEND.md` should be updated only if Phase 17 changes a real contract. If Phase 17 only clarifies already-existing no-new-UI and core-module boundaries, root docs may remain unchanged.

### the agent's Discretion
The planner may choose exact wording, table layout, and cross-reference placement for the Phase 17 contract edits, as long as the decisions above remain intact and every changed contract stays traceable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger, v1.3 Phase 16 evidence, and record/update rules.
- `.planning/PROJECT.md` — Defines v1.3 as no-new-UI core beauty module work and records Phase 17 as the next contract step.
- `.planning/REQUIREMENTS.md` — Defines `CBT-01`, `CBT-02`, `CBT-03`, and `MOD-01` as Phase 17 requirements.
- `.planning/ROADMAP.md` — Defines Phase 17 goal, success criteria, planned slots `17-01` and `17-02`, and dependency on Phase 16.
- `.planning/STATE.md` — Records current v1.3 session state, pending Phase 17 contract work, and geometry-output concern.
- `.planning/phases/16-example-image-validation-harness/16-CONTEXT.md` — Locks no-UI renderer validation policy, ignored output directory, and geometry-output limitation inherited by Phase 17.

### Blueprint Contracts
- `docs/meitu-function-blueprint/README.md` — Blueprint entry, reading order, feature-family folders, and excluded families.
- `docs/meitu-function-blueprint/MINDMAP.md` — Core beauty taxonomy and branch/subtool tree to normalize.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Current branch status table that Phase 17 should tighten to the four-state model.
- `docs/meitu-function-blueprint/MODULES.md` — Current module ownership and dependency boundary map.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` — Milestone inclusion/exclusion boundaries and acceptance signals.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` — Shared business and technical principles for branch docs.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — Beauty shaping family contract to update with branch status and dependency notes.
- `docs/meitu-function-blueprint/features/skin-retouch/README.md` — Skin retouch family contract to update with branch status and dependency notes.
- `docs/meitu-function-blueprint/features/editor-shell/README.md` — Editor shell family contract to keep app-side and no-algorithm.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Renderer command/output rules and geometry-output limitation.

### Root Contracts
- `ARCHITECTURE.md` — SDK target boundaries, facade-only Demo invariant, dependency direction, and geometry provider/render ownership.
- `DESIGN.md` — Public `BeautyParameters`, detection/render/effect contracts, and rules for adding public parameters.
- `FRONTEND.md` — Demo ownership of SwiftUI state, category/tool rails, parameter mapping, compare/debug, and cancel/confirm behavior.
- `SECURITY.md` — Local-first, validation, resource trust, and redaction boundaries that contract changes must preserve.
- `RELIABILITY.md` — Degradation, warning, metrics, and performance-risk framing for future implementation evidence.
- `PRODUCT_SENSE.md` — Acceptance criteria owner when public behavior changes.
- `QUALITY_SCORE.md` — Quality and verification score evidence owner.

### Current SDK Evidence
- `BeautySDK/Package.swift` — Declares package targets and the `BeautyExampleRenderer` facade-only executable dependency.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Current public parameter coverage that branch notes must distinguish from future parameter needs.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectDomain.swift` — Current product-neutral SDK effect domains.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` — Current active/skipped domain, warnings, metrics, and effective strength surface.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — Current resolver behavior, safety caps, geometry-domain skip/degradation logic, and provider evidence entry point.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Current public facade processing path; image/pixel-buffer processing currently resolves effects without facade-visible face geometry.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — Existing provider/resolver evidence for caps, no-face skips, and geometry provider behavior; counts as partial evidence for geometry branches.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` — Existing facade-level visible-output evidence for skin/color/filter domains.

### Demo and Reference Taxonomy
- `meituxiuxiu/FUNCTION_MAP.md` — Editor `美型 / 五官` taxonomy and first-level branch ordering that Demo docs may reference.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` — Current Demo taxonomy and supported/unsupported tool mapping.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` — Current Demo bottom panel surface that remains app-side.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` — Current app-side parameter snapshot and cancel/confirm support state.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already covers basic skin, color, face shape, eyes, nose, mouth, lip color, and filter controls. Phase 17 should map each branch to current parameter coverage and future parameter gaps.
- `BeautyEffectDomain`, `BeautyEffectPlan`, and `BeautyEffectResolver` already express product-neutral SDK domains, active/skipped domains, safety caps, warnings, metrics, and geometry degradation.
- `BeautyEngine.processResult(image:metadata:parameters:)` is the public facade path used by `BeautyExampleRenderer`; it currently produces facade-visible output for skin/color/filter-style processing but does not yet feed facade-visible face geometry into saved image output.
- Existing `BeautyEffects` tests can prove provider/resolver behavior, but Phase 17 should distinguish that evidence from public renderer output.

### Established Patterns
- Demo and renderer validation stay facade-only: `BeautyDemo` and `BeautyExampleRenderer` import `BeautySDK`, not internal SDK targets.
- Meitu/Xingtu-style labels are product taxonomy, not SDK API names.
- Unsupported or future capabilities remain visible/static/documented only when needed for taxonomy fidelity; they must not pretend to work.
- Generated example outputs remain under ignored `example-images/out/` unless a later phase explicitly promotes evidence artifacts.

### Integration Points
- `17-01-PLAN.md` should normalize blueprint docs in place: status labels, branch notes, current parameter coverage, future parameter needs, explicit exclusions, and ownership/dependency tables.
- `17-02-PLAN.md` should verify the normalized contracts against root documents and current SDK/Demo boundaries, including facade-only import scans and no-new-SwiftUI-screen scans.
- Phases 18 and 19 should consume the evidence ladder before claiming skin or shaping branches are complete.

</code_context>

<specifics>
## Specific Ideas

- Phase 17 should make downstream planning mechanically clear: every branch has one status, one primary owner, dependency notes, current parameter coverage, future parameter needs, and an evidence expectation.
- Existing docs should be tightened rather than replaced.
- The highest-risk ambiguity is geometry: provider tests are meaningful, but visible saved-output completion must wait for public facade detection plus geometry render integration.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 17 scope.

</deferred>

---

*Phase: 17-Core Beauty Contracts and Module Boundaries*
*Context gathered: 2026-06-26*
