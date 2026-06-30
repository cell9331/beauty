# Phase 20: Core Module Closeout - Research

**Researched:** 2026-06-30
**Domain:** v1.3 editor-shell closeout, visible-effect renderer evidence, and planning ledger consistency
**Confidence:** HIGH for local docs/code/test inventory; MEDIUM for simulator execution because local CoreSimulator is out of date.

<user_constraints>
## User Constraints From CONTEXT.md

Phase 20 is a verification, documentation, and ledger-consistency phase for `EDITOR-01`, `EDITOR-02`, `EDITOR-03`, `MOD-02`, `MOD-03`, and `MOD-04`.

Locked constraints:

- D-01/D-02/D-03: Tighten editor-shell blueprint docs and root acceptance wording only where needed. Treat editor-shell support as existing app-side behavior. Do not add SwiftUI screens, Demo routes, tool-panel behavior, or app-state behavior.
- D-04/D-05/D-06: Keep a hard Demo-vs-SDK ownership boundary. Demo owns routing, preview chrome, rails, sliders, compare/debug, cancel/confirm, and parameter snapshots. SDK owns public `BeautyParameters`, processing, warnings/metrics, resources through the public facade, and product-neutral core effect logic. Do not require broad Demo simulator verification unless closeout changes make it necessary.
- D-07/D-08/D-09/D-10/D-11: Closeout visible-effect evidence requires `swift test --package-path BeautySDK`, all current `BeautyExampleRenderer` built-in cases, same-dimension outputs, ignored `example-images/out/`, readable bottom watermarks, and factual visual notes. Do not add renderer cases.
- D-12/D-13: Shaping provider/resolver evidence remains `partial` or `blocked-by-geometry-output`; public facade detection plus geometry render integration is required before geometry branches can claim saved-image completion.
- D-14/D-15/D-16/D-17/D-18: Run a traceability closeout sweep across planning ledgers and current blueprint docs, touch root contracts only where needed, mark requirements complete only after evidence passes, do not normalize historical docs unless they misroute current agents, and include full tests, renderer matrix, scans, requirement traceability, and state/roadmap consistency.
</user_constraints>

## Summary

Phase 20 should plan two sequential closeout waves:

1. Documentation and contract tightening for editor-shell support, delivery boundaries, and minimal root acceptance wording.
2. Evidence and ledger closeout after full SwiftPM tests, all current renderer cases, dimension/watermark checks, static scope scans, requirement traceability, and state/roadmap checks pass.

The phase should not implement behavior. The strongest implementation insight is that current Demo editor support is already app-owned in `BeautyDemo/BeautyDemo/Editor` and `BeautyDemo/BeautyDemo/State`, while visible SDK evidence currently exists through skin/color/filter renderer cases only. Geometry-heavy shaping output remains deferred until the public facade can provide detection plus geometry rendering to `BeautyExampleRenderer`.

## Project Constraints

| Directive | Planning Impact |
| --- | --- |
| `AGENTS.md` requires `PLANS.md` before edits and contract updates in the owning document. | Plans must update blueprint/root contracts only where Phase 20 closeout changes current authority. |
| Existing dirty worktree contains unrelated documentation/source-tracking changes. | Execution must keep file scopes explicit and avoid reverting user changes. |
| v1.3 is no-new-UI core module work. | Plans cannot add SwiftUI screens, Demo routes, public parameters, renderer cases, or geometry saved-image output. |
| Verification claims must include exact commands and observed results. | Plan 20-02 must create `20-VERIFICATION.md` and copy concrete evidence into ledgers only after commands pass or failures are recorded. |
| `request_user_input` was unavailable in this Codex mode. | This plan-phase ran in text-mode for the research gate; no workflow artifacts were written before the user chose research first. |

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
| --- | --- | --- |
| EDITOR-01 | Minimal editor shell support is documented for input routing, preview chrome, bottom panel, and commit flow. | `docs/meitu-function-blueprint/features/editor-shell/**` already describes these branches as app-owned and implemented; Plan 20-01 should tighten evidence wording. |
| EDITOR-02 | Editor shell documentation clarifies Demo ownership versus SDK ownership for core beauty tools. | `MODULES.md`, editor-shell docs, `ARCHITECTURE.md`, and `FRONTEND.md` already separate Demo and SDK ownership; Plan 20-01 should reconcile wording where closeout needs explicit acceptance. |
| EDITOR-03 | Cancel/confirm, compare/debug, slider, category rail, and parameter snapshot semantics remain app-side support logic, not SDK algorithm logic. | `BeautyParameterStore`, `EditorShellView`, `MeituEditorToolPanelView`, `CompareStateTests`, and `BeautyDemoViewStateTests` provide existing app-side evidence. |
| MOD-02 | Roadmap decomposes v1.3 into preparation, contracts, skin, shaping, and closeout phases with 100% requirement traceability. | `.planning/ROADMAP.md` has Phases 16-20 and `.planning/REQUIREMENTS.md` maps 20/20 v1.3 requirements. Plan 20-02 should verify this before completion. |
| MOD-03 | `PLANS.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` describe v1.3 as no-new-UI core module work. | Current state and roadmap already say this; closeout should verify and update ledgers only after evidence passes. |
| MOD-04 | Promoted visible effects must provide unit/integration evidence and example-image output evidence before being considered complete. | Basic skin is implemented and renderer-visible; shaping branches stay partial/blocked until geometry saved-image output exists. Plan 20-02 should rerun full SDK tests plus all current renderer cases and preserve limitation wording. |
</phase_requirements>

## Standard Stack

| Tool / Target | Purpose | Availability |
| --- | --- | --- |
| SwiftPM / `BeautySDK` | Full SDK test suite, executable renderer build/run. | `swift --version` reports Apple Swift 6.3.3; `swift test --package-path BeautySDK --list-tests` completed and listed current tests. |
| `BeautyExampleRenderer` | Public-facade saved-image evidence for current visible cases. | Existing cases: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `brightness_plus0p25`, `contrast_plus0p25`, `filter_softClean_0p50`, `filter_warmLight_0p50`, `skinCombo_0p50`. |
| Xcode / `xcodebuild` | Optional Demo scheme listing or simulator tests. | `xcodebuild -list` resolved targets/schemes but reported CoreSimulator out-of-date; Phase 20 should not depend on broad simulator UI verification. |
| `rg`, `find`, `file`, `stat`, `git check-ignore` | Static scans and mechanical renderer output checks. | Available from local command use. |
| GSD tools | State/roadmap/traceability checks. | `init.plan-phase 20`, `roadmap.get-phase 20`, and `phase.mvp-mode 20` completed. |

No external package install is needed.

## Architecture and Ownership Patterns

### Editor Shell Is App-Owned

`docs/meitu-function-blueprint/features/editor-shell/README.md` and child branch docs identify:

- Input routing owner: `BeautyDemo/Editor`
- Preview chrome owner: `BeautyDemo/Editor`
- Bottom panel owner: `BeautyDemo/Panel`
- Commit flow owner: `BeautyDemo/State`

The implementation analogs are:

- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` for input mode, preview content, compare/debug toolbar, cancel, and confirm.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` for category/tool taxonomy and supported/unsupported mapping.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` for category rail, tool rail, slider state, cancel, and confirm controls.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` for parameter snapshots, sources, reset, preset/import/custom state, and rollback/apply semantics.
- Existing tests in `BeautyDemoViewStateTests`, `BeautyParameterStoreTests`, `CompareStateTests`, `InputPipelinePrivacyTests`, and `BeautyDemoImportBoundaryTests`.

Plan 20 should document and scan these existing facts; it should not change them.

### SDK Facade and Renderer Evidence

`BeautySDK/Sources/BeautySDK/BeautyEngine.swift` resolves public `BeautyParameters` through `BeautyEffectResolver.resolve(parameters:)` without a public face-geometry path for saved-image output. `BeautySDK/Sources/BeautyExampleRenderer/main.swift` imports only `BeautySDK`, builds `RenderCase` values for current skin/color/filter cases, calls `BeautyEngine.processResult(image:metadata:parameters:)`, and writes watermarked PNGs under `example-images/out/`.

This makes the renderer an appropriate evidence gate for Basic skin, color, and filter outputs, not for face/eye/nose/mouth geometry saved-image completion.

### Root Contract Touch Points

Root documents already contain the major boundaries:

- `ARCHITECTURE.md`: SDK has no UI; Demo imports only `BeautySDK`; no public geometry/control-point leakage.
- `DESIGN.md`: `BeautyParameters` owns host-facing parameters; future parameter expansion needs contract updates.
- `FRONTEND.md`: Demo owns editor state, rails, sliders, compare/debug, and cancel/confirm.
- `SECURITY.md`: no uploads; warnings/metrics/debug surfaces stay redacted.
- `RELIABILITY.md`: degradation warnings/metrics, no-face behavior, and release-risk caveats.
- `PRODUCT_SENSE.md`: user journeys and acceptance evidence; manual/hardware release risks remain separate.
- `QUALITY_SCORE.md`: current coverage and remaining release-hardening gaps.

Plan 20-01 should only add Phase 20 acceptance/evidence wording where current authority is ambiguous.

## Common Pitfalls

| Pitfall | Why It Matters | Avoidance |
| --- | --- | --- |
| Treating editor-shell closeout as a UI implementation phase. | Violates D-03 and v1.3 no-new-UI scope. | Use docs/tests/scans only; if a behavior gap appears, record future work. |
| Marking shaping branches implemented from provider tests. | Violates D-12/D-13 and the evidence ladder. | Keep face-shape, eyes, nose, mouth, and proportion `partial`; keep `3D塑颜` `blocked-by-geometry-output`; keep eyebrows `future`. |
| Adding renderer geometry cases to force visual evidence. | Violates D-09 and bypasses the missing public facade geometry integration. | Run only current built-in cases from `main.swift`. |
| Depending on simulator UI tests for Phase 20. | Local CoreSimulator is out of date and D-06 says broad Demo simulator verification is not required unless changes need it. | Prefer existing test-source evidence and static scans; record simulator availability honestly if checked. |
| Closing ledgers before evidence. | Would mark pending requirements complete without proof. | Plan 20-02 creates `20-VERIFICATION.md` first, then updates `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`. |
| Normalizing historical docs. | Phase 20 explicitly avoids broad historical-doc cleanup. | Touch only current authority docs unless stale historical text misroutes agents. |

## Validation Architecture

### Test Framework

| Property | Value |
| --- | --- |
| Framework | SwiftPM XCTest plus shell static scans and renderer file checks |
| Config file | `BeautySDK/Package.swift` |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyEffectsTests` |
| Full suite command | `swift test --package-path BeautySDK` |
| Renderer command | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` |
| Demo simulator command | Optional only; local `xcodebuild -list` reports CoreSimulator out-of-date |

### Requirement to Verification Map

| Req ID | Behavior | Verification Type | Command / Check |
| --- | --- | --- | --- |
| EDITOR-01 | Editor-shell branch docs cover input routing, preview chrome, bottom panel, commit flow. | Static docs scan | `rg -n "Input routing|Preview chrome|Bottom panel|Commit flow|implemented" docs/meitu-function-blueprint/features/editor-shell docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/MODULES.md` |
| EDITOR-02 | Demo-vs-SDK ownership is explicit. | Static docs/root scan | `rg -n "Demo|SDK|BeautyDemo/Editor|BeautyDemo/Panel|BeautyDemo/State|BeautySDK facade" docs/meitu-function-blueprint/features/editor-shell docs/meitu-function-blueprint/MODULES.md FRONTEND.md PRODUCT_SENSE.md` |
| EDITOR-03 | Cancel/confirm, compare/debug, sliders, rails, snapshots are app-side. | Source/test scan | `rg -n "cancel|confirm|Compare|Debug|Slider|category|snapshot|BeautyParameterStore" BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/State BeautyDemo/BeautyDemoTests` |
| MOD-02 | v1.3 roadmap and traceability are complete. | GSD + static scan | `node "$HOME/.codex/get-shit-done/bin/gsd-tools.cjs" query roadmap.analyze` plus requirement traceability scan. |
| MOD-03 | Planning ledgers describe no-new-UI v1.3 core module work. | Static planning scan | `rg -n "no-new-UI|core beauty|Phase 20|v1.3" .planning/PROJECT.md .planning/ROADMAP.md .planning/STATE.md PLANS.md` |
| MOD-04 | Promoted visible effects have tests plus renderer outputs; geometry limitations remain explicit. | SwiftPM + renderer + static scan | `swift test --package-path BeautySDK`, renderer all-cases run, dimension/watermark checks, and geometry-overclaim scans. |

### Sampling Rate

- After Plan 20-01 docs edits: run static scans for editor ownership, no new UI/source changes, and `git diff --check`.
- After Plan 20-02 evidence generation: run `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, all renderer cases, dimension/output checks, no-new-API/UI/import/renderer-geometry/redaction scans, and GSD state/roadmap checks.
- Before marking Phase 20 requirements complete: verify `20-VERIFICATION.md` records concrete command outputs and failures, then update ledgers.

### Manual or Human-Observed Checks

| Behavior | Reason | Instruction |
| --- | --- | --- |
| Renderer watermark readability and visible natural changes | Mechanical dimension checks cannot prove visual placement/readability. | Inspect representative outputs and record factual observations only: non-empty output, same dimensions, readable bottom label, label below face, visible natural change where expected. Do not claim release-grade quality. |
| Real-device camera/Vision parity and production naturalness | Deferred release-hardening scope. | Keep as `PLANS.md` tech debt or release-risk caveat; do not block Phase 20 closeout. |

## Environment Availability

| Dependency | Required By | Available | Notes |
| --- | --- | --- | --- |
| SwiftPM / Swift | SDK tests and renderer | yes | `swift --version` reports Apple Swift 6.3.3. |
| Xcode developer tools | Apple SDKs and optional Demo project listing | partial | `xcodebuild -version` reports Xcode 26.6; simulator support reports CoreSimulator out-of-date. |
| `rg` | Static scans | yes | Used throughout repository workflow. |
| Image fixtures | Renderer | assumed available | Plans should fail fast if `example-images/input/` is missing or empty. |
| Local skills | Project-local extra instructions | none found | `find .codex/skills .agents/skills -maxdepth 2 -name SKILL.md` returned no files. |

## Open Questions

1. Should Phase 20 update historical docs under `docs/`?
   - Resolved: No, unless stale historical wording misroutes current agents. Phase 20 uses current authority docs and ledgers.
2. Should Phase 20 run Demo simulator tests?
   - Resolved: Not as a required gate. Existing Demo tests and static scans are practical evidence; broad simulator verification is not required by D-06 and local CoreSimulator is currently out of date.
3. Should Phase 20 add renderer cases for geometry?
   - Resolved: No. Renderer cases remain exactly the current built-in skin/color/filter matrix.

## Sources

Primary local sources:

- `AGENTS.md`, `PLANS.md`
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`
- `.planning/phases/20-core-module-closeout/20-CONTEXT.md`
- `.planning/phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md`
- `.planning/phases/18-skin-retouch-core-modules/18-CONTEXT.md`
- `.planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md`
- `docs/meitu-function-blueprint/**`
- `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`
- `BeautyDemo/BeautyDemo/Editor/**`, `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`
- `BeautyDemo/BeautyDemoTests/**`, `BeautySDK/Tests/**`

Command evidence gathered during research:

- `swift --version`
- `xcodebuild -version`
- `swift test --package-path BeautySDK --list-tests`
- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`
- `rg -n 'RenderCase\(|id: "' BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `find .codex/skills .agents/skills -maxdepth 2 -name SKILL.md`

## Metadata

**Confidence breakdown:**

- Phase scope: HIGH - locked by Phase 20 context and roadmap.
- SDK/renderer evidence path: HIGH - verified in local source and SwiftPM test listing.
- Demo simulator availability: MEDIUM - project list resolves, but simulator support is currently degraded by CoreSimulator version mismatch.
- Visual naturalness: LOW for release-grade claims - Phase 20 explicitly limits notes to factual observations.

**Valid until:** 2026-07-30 or until Phase 20 source/docs change.
