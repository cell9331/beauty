# Phase 20: Core Module Closeout - Context

**Gathered:** 2026-06-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 20 closes the v1.3 Meitu Core Beauty Module Design and Implementation milestone for `EDITOR-01`, `EDITOR-02`, `EDITOR-03`, `MOD-02`, `MOD-03`, and `MOD-04`.

This is a verification, documentation, and ledger-consistency phase. It finalizes editor-support contracts as app-side behavior, verifies promoted visible effects with full SDK tests plus current example-image renderer output, and updates current authority docs and planning ledgers to reflect actual implemented behavior and remaining limitations.

Phase 20 must not add SwiftUI screens, redesign Demo interactions, add public `BeautyParameters`, add renderer cases, implement geometry saved-image output, normalize historical docs, or promote deferred Meitu product areas.

</domain>

<decisions>
## Implementation Decisions

### Editor-Shell Closeout
- **D-01:** Tighten `docs/meitu-function-blueprint/features/editor-shell/**` as the primary editor-support contract, then reconcile `FRONTEND.md` and `PRODUCT_SENSE.md` only where Phase 20 needs explicit acceptance or evidence wording.
- **D-02:** Treat editor-shell support as already implemented app-side behavior to document and verify. Phase 20 should cite existing Demo code/tests and fix only documentation or clear inconsistencies.
- **D-03:** Do not add new SwiftUI screens, Demo routes, tool-panel behavior, or app-state behavior in Phase 20. If a real editor behavior gap appears, record it as future work instead of patching it in closeout.
- **D-04:** Use a hard Demo-vs-SDK ownership boundary: editor shell owns routing, preview chrome, category/tool rails, sliders, compare/debug, cancel/confirm, and parameter snapshots; SDK owns public `BeautyParameters`, processing, result warnings/metrics, resources through the public facade, and product-neutral core effect logic.
- **D-05:** Editor-shell evidence should use existing tests plus scope scans where practical. Preferred evidence includes Demo view-state/state/import-boundary/privacy tests and scans proving no new SwiftUI screens, no Demo imports of internal SDK targets, and no SDK ownership creep.
- **D-06:** Do not require a broad Demo simulator verification sweep for Phase 20 unless closeout changes make it necessary.

### Visible Evidence Threshold
- **D-07:** Phase 20 visible-effect closeout requires `swift test --package-path BeautySDK`.
- **D-08:** Phase 20 should build and run `BeautyExampleRenderer` for all current built-in cases exposed by `BeautySDK/Sources/BeautyExampleRenderer/main.swift`: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `brightness_plus0p25`, `contrast_plus0p25`, `filter_softClean_0p50`, `filter_warmLight_0p50`, and `skinCombo_0p50`.
- **D-09:** Do not add new renderer cases in Phase 20. In particular, do not add geometry renderer cases unless a later phase explicitly designs public facade detection plus geometry render output.
- **D-10:** Verify renderer outputs mechanically: files are written under ignored `example-images/out/`, output dimensions match source dimensions, and watermarks remain readable and below the face.
- **D-11:** Renderer visual notes must stay factual: non-empty output, readable watermark, watermark does not cover the face, same dimensions, and visible natural changes where the current case is supposed to visibly affect output. Do not claim production render quality, market-grade naturalness, or release readiness.
- **D-12:** Shaping branches with provider/resolver evidence remain explicitly `partial` or `blocked-by-geometry-output` as already decided. Provider, resolver, cap, degradation, and redaction tests are not saved-image visual completion.
- **D-13:** Public facade detection plus geometry render integration must produce same-dimension, watermarked saved outputs before face-shape, eye, nose, mouth geometry, eyebrow, proportion, or 3D sculpt branches can claim visible image-output completion.

### Ledger and Root-Contract Sync
- **D-14:** Run a traceability closeout sweep across `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and current blueprint docs.
- **D-15:** Touch root contracts only where needed to record Phase 20 editor acceptance, evidence thresholds, or limitation wording. Do not perform a broad root-doc rewrite.
- **D-16:** Mark satisfied v1.3 requirements complete only after evidence passes, while preserving explicit limitations/deferred tables for geometry saved output, future parameters, release QA, and deferred Meitu product areas.
- **D-17:** Do not normalize historical docs under `docs/` during Phase 20. If stale historical-doc wording does not misroute current agents, record it as deferred/tech debt instead of editing it.
- **D-18:** Final closeout verification should include evidence, scans, and ledger checks: full SDK tests, current renderer matrix, dimension/watermark/factual visual notes, Demo editor contract tests/scans where practical, no-new-UI/API/import scans, requirement traceability, and state/roadmap consistency.

### the agent's Discretion
The planner may choose exact plan split, scan commands, test filters, and wording updates as long as the decisions above remain intact. Keep the phase conservative: close the milestone honestly, do not expand behavior, and record limitations where evidence does not support completion claims.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Work ledger, update rules, current v1.3 state, and dirty-worktree caution.
- `.planning/PROJECT.md` — Defines v1.3 as no-new-UI core beauty module work and lists Phase 20 as closeout.
- `.planning/REQUIREMENTS.md` — Defines `EDITOR-01`, `EDITOR-02`, `EDITOR-03`, `MOD-02`, `MOD-03`, and `MOD-04`.
- `.planning/ROADMAP.md` — Defines Phase 20 goal, success criteria, and planned slots `20-01` and `20-02`.
- `.planning/STATE.md` — Records current milestone state and Phase 20 as current focus.
- `.planning/phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md` — Locks the status taxonomy, evidence ladder, Demo-vs-SDK ownership, and no-new-UI boundary.
- `.planning/phases/18-skin-retouch-core-modules/18-CONTEXT.md` — Locks Basic skin visible evidence, future-branch boundaries, and factual visual-observation rules.
- `.planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md` — Locks shaping partial/blocked status, no new parameters/UI, and geometry-output limitation.

### Blueprint Contracts
- `docs/meitu-function-blueprint/README.md` — Blueprint entry point and active family set.
- `docs/meitu-function-blueprint/MINDMAP.md` — Core beauty taxonomy including editor-shell branches.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Branch status matrix and evidence expectations.
- `docs/meitu-function-blueprint/MODULES.md` — Module ownership, Demo-vs-SDK boundaries, and renderer role.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` — v1.3 inclusion/exclusion and delivery boundaries.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Renderer command/output rules, current built-in cases, and geometry-output limitation.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` — Evidence ladder and branch documentation checklist.
- `docs/meitu-function-blueprint/features/editor-shell/README.md` — Editor-shell branch table and app-side ownership.
- `docs/meitu-function-blueprint/features/editor-shell/input-routing/README.md` — Input routing ownership and verification expectations.
- `docs/meitu-function-blueprint/features/editor-shell/preview-chrome/README.md` — Preview chrome, compare/debug, and public-result dependency.
- `docs/meitu-function-blueprint/features/editor-shell/bottom-panel/README.md` — Category/tool rail, slider, label, and badge ownership.
- `docs/meitu-function-blueprint/features/editor-shell/commit-flow/README.md` — Cancel/confirm and parameter snapshot ownership.
- `docs/meitu-function-blueprint/features/skin-retouch/README.md` — Skin-retouch family status and future branch boundaries.
- `docs/meitu-function-blueprint/features/skin-retouch/skin-basic/README.md` — Current Basic skin visible branch behavior.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — Beauty-shaping family status and geometry saved-output limitation.

### Root Contracts
- `ARCHITECTURE.md` — SDK target boundaries, facade-only Demo invariant, dependency direction, and no public geometry/control-point leakage.
- `DESIGN.md` — Public `BeautyParameters`, effect planning, detection/render/effect contracts, and parameter-extension rules.
- `FRONTEND.md` — Demo ownership of SwiftUI state, editor shell, parameter mapping, compare/debug, and cancel/confirm behavior.
- `SECURITY.md` — Local-first privacy, validation, no upload, and redacted warning/metric constraints.
- `RELIABILITY.md` — Degradation, warnings, metrics, test evidence, and performance-risk framing.
- `PRODUCT_SENSE.md` — User journeys, natural-first acceptance, Demo editor acceptance, and release-quality caveats.
- `QUALITY_SCORE.md` — Current quality score, test coverage state, and remaining release-hardening gaps.

### Current Code and Test Evidence
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Current built-in renderer cases and facade-only renderer behavior.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public image processing facade used by renderer/tests.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Current public parameter model; Phase 20 must not expand it.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` — Current Demo editor shell surface.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` — Current Demo taxonomy and supported/disabled tool mapping.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` — Current bottom panel surface.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` — App-side parameter snapshot, source, reset, cancel/confirm support.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` — Existing editor taxonomy, slider mapping, cancel restore, toolbar, disabled honesty, and panel view-state evidence.
- `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` — Existing facade-only Demo import evidence.
- `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` — Existing parameter source/reset/snapshot evidence.
- `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` — Existing compare/debug preservation and redaction evidence.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` — Existing privacy, facade-only, debug redaction, and no sensitive geometry-surface evidence.
- `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` — Current Basic skin behavior evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — Current resolver, cap, warning/metric, and redaction evidence.
- `BeautySDK/Tests/BeautyEffectsTests/*WarpProviderTests.swift` — Current shaping provider evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — Current missing-landmark, stale, and reused geometry degradation evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` — Current facade-level image output evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer` already exposes all Phase 20 renderer cases and imports only public `BeautySDK`.
- Existing `BeautyDemo` tests cover editor taxonomy, tool mappings, cancel restore, parameter snapshots, compare/debug state, disabled honesty, privacy scans, and facade-only imports.
- Existing `BeautySDK` tests cover Basic skin, color/filter output through the facade, effect resolver behavior, shaping providers, caps, missing-landmark degradation, and redaction.
- Current blueprint docs already separate `editor-shell`, `skin-retouch`, and `beauty-shaping`; Phase 20 should tighten rather than replace them.

### Established Patterns
- Demo and renderer validation stay facade-only; they must not import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` directly.
- Generated PNG outputs remain ignored local artifacts under `example-images/out/`.
- Current authority docs own current contracts; historical long-form docs under `docs/` are background unless they are explicitly listed as current authority.
- Branch statuses must remain honest: `implemented`, `partial`, `blocked-by-geometry-output`, or `future`.

### Integration Points
- `20-01` should finalize editor-shell docs, delivery boundaries, and any necessary root acceptance wording without changing Demo behavior.
- `20-02` should run closeout evidence: full SDK tests, renderer matrix, dimension/watermark checks, factual visual observations, no-new-UI/API/import scans, requirement traceability, and planning ledger consistency checks.

</code_context>

<specifics>
## Specific Ideas

- Keep Phase 20 as a closeout phase, not a feature phase.
- Make the editor-shell contract hard-edged: app owns interaction state and presentation; SDK owns public processing contracts.
- Use all current renderer cases exactly as they exist today and do not invent geometry visual evidence.
- Close the milestone with explicit limitations rather than diluted completion claims.

</specifics>

<deferred>
## Deferred Ideas

- Public facade geometry saved-image output remains deferred until face detection plus geometry render integration can produce same-dimension, watermarked renderer outputs.
- New public beauty parameters for advanced shaping, skin repair, teeth/hairline, eyebrow, 3D sculpt, and other Meitu subtools remain deferred.
- Release-readiness QA, hardware camera/Vision parity, production naturalness evaluation, performance budgets, long-run reliability, automated visual diffing, and multi-device screenshot sweeps remain future scope.
- Home/discovery, style resources, AI/background, video/body, gallery/account, search, VIP, payment, and entitlement planning remain deferred outside v1.3.
- Historical docs cleanup remains out of Phase 20 unless stale wording misroutes current agents.

</deferred>

---

*Phase: 20-Core Module Closeout*
*Context gathered: 2026-06-30*
