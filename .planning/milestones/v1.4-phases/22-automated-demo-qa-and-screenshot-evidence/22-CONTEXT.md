# Phase 22: Automated Demo QA and Screenshot Evidence - Context

**Gathered:** 2026-06-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 22 adds repeatable Demo visual/layout evidence for the current Home and Editor surfaces. It covers `QA-01`, `QA-02`, `QA-03`, and `QA-04`.

This is a QA automation and evidence phase. It should capture or document current Home first screen, Home sticky state, and editor beauty/photo tool-panel evidence with explicit simulator destinations, exact commands, and factual review notes. It should also prove unsupported/future Meitu-style areas remain visibly honest and inactive.

Phase 22 must not redesign Home or Editor, add new product routes, add public `BeautyParameters`, change SDK algorithms, implement physical-device parity, claim production naturalness, or treat archived screenshots as current v1.4 pass evidence.

</domain>

<decisions>
## Implementation Decisions

### Screenshot Capture Path
- **D-01:** Use existing launch arguments plus `simctl` screenshots as the primary capture path. Existing hooks include `--beauty-demo-home-sticky` and `--beauty-demo-route editor-photo|editor-camera|editor-beauty`.
- **D-02:** Start with existing routes. Add only minimal launch-only QA hooks if the planner finds a deterministic capture gap for required evidence.
- **D-03:** Required captured states are Home first screen, Home sticky state, and the editor beauty/photo tool panel.
- **D-04:** Editor camera route evidence is optional only if it is cheap, reliable, and not blocked by permission or camera-session handling.
- **D-05:** Phase 22 must leave an evidence README under `.planning/evidence/v1.4/` with exact build, test, install, launch, screenshot, simulator destination, launch-argument, output-path, and review-note details.
- **D-06:** A reusable screenshot script is optional only if it stays small and does not become a new QA framework.

### Target Simulator Matrix
- **D-07:** Required simulator destination is `platform=iOS Simulator,name=iPhone 17,OS=26.5`, matching the Phase 21 Demo build blocker command and available simulator inventory.
- **D-08:** The planner may add one optional compact or large iPhone-class smoke screenshot/check if it is cheap after the required iPhone 17 path passes.
- **D-09:** Physical iPhone evidence is not required for Phase 22 completion. Phase 22 should record a manual protocol and mark physical-device camera/Vision parity blocked until hardware evidence exists.

### Evidence Acceptance Bar
- **D-10:** Each required screenshot needs a factual review note with the exact command, file path, framing, and observations about clipping, overlap, disabled honesty, and route scope.
- **D-11:** Phase 22 should run explicit Demo build and Demo tests if the Metal Toolchain is fixed. If the toolchain remains missing, record the exact blocker instead of claiming a pass.
- **D-12:** Use current Demo model/view-state tests plus human-readable screenshot review notes. Add narrow route or view-state tests only if needed for QA-04 or deterministic launch evidence.
- **D-13:** Avoid brittle pixel-perfect assertions and screenshot diff baselines in Phase 22 unless they are already cheap. A broader visual-diff framework belongs to a later explicit phase.
- **D-14:** Review notes must explicitly check that controls, labels, badges, and panels do not clip or overlap; disabled/future areas stay visibly inactive; and no new UI route is accidentally enabled.

### Blocker and Honesty Policy
- **D-15:** If the local Metal Toolchain is still missing, Phase 22 may complete only by reproducing the blocker and writing a rerun/manual protocol. It must not claim current screenshot pass evidence.
- **D-16:** Blocker records must include exact command, simulator/device destination, relevant environment, concise failure summary, impact, and next step.
- **D-17:** Archived v1.1 and v1.2 screenshots are background comparison only. They are not current v1.4 pass evidence.
- **D-18:** QA-04 should use route/model tests plus screenshot review notes, with scans if needed, to prove disabled future areas stay inactive and no new route is enabled.
- **D-19:** Production naturalness, effect quality, physical-device camera/Vision parity, and long-run hardware evidence remain outside Phase 22 layout evidence unless they are recorded as blocked/manual protocols.

### the agent's Discretion
The planner may choose exact screenshot filenames, whether to add a tiny helper script, exact install/boot command ordering, and whether to add one optional non-baseline phone smoke check. Keep the work evidence-first and conservative: prefer current launch hooks, current tests, exact commands, and honest blockers over broad new UI automation infrastructure.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger, update rules, current next step, and technical-debt routing.
- `.planning/PROJECT.md` - Defines v1.4 as stability, QA, performance, security, and debt cleanup without product-feature expansion.
- `.planning/REQUIREMENTS.md` - Defines `QA-01`, `QA-02`, `QA-03`, and `QA-04`.
- `.planning/ROADMAP.md` - Defines Phase 22 goal, success criteria, dependency, and planned status.
- `.planning/STATE.md` - Records current v1.4 state and Phase 22 as the current position.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md` - Locks current-evidence policy, stale codebase-map handling, and reproducible blocker rules.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` - Records the current Demo simulator build/test blocker, available simulator inventory, and routed Phase 22 visual QA debt.

### Root Contracts
- `FRONTEND.md` - Demo UI ownership, launch-only visual hooks, Home/Editor current state, and no-new-UI release-hardening boundary.
- `PRODUCT_SENSE.md` - Product acceptance criteria and release-hardening caveats for visual evidence, control, and disabled honesty.
- `QUALITY_SCORE.md` - Current v1.4 quality snapshot, Phase 21 blocker evidence, and Phase 22 next move for Demo QA.

### Visual Reference and Prior Evidence
- `meituxiuxiu/HOME_MAP.md` - Home first screen and sticky-state reference structure.
- `meituxiuxiu/FUNCTION_MAP.md` - Editor tool-panel taxonomy, bottom-panel structure, disabled/pro badge behavior, and category ordering.
- `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` - Archived v1.1 SwiftUI visual evidence; background comparison only for Phase 22.
- `.planning/evidence/v1.2/VISUAL-EVIDENCE.md` - Archived v1.2 HTML reference visual evidence; background comparison only for Phase 22.

### Current Demo Code Surfaces
- `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` - App entry and launch-time wiring for initial route and sticky Home preview.
- `BeautyDemo/BeautyDemo/ContentView.swift` - Existing launch arguments and Home-to-Editor route mapping.
- `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift` - Current Home first screen, sticky shortcut rail, bottom tab, and disabled tool presentation.
- `BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift` - Home route model, enabled/disabled route truth, and reference view state.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - Current editor preview shell, toolbar, photo/camera modes, and bottom-panel integration.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` - Current editor tool panel, slider row, tool rail, badges, disabled state, and bottom actions.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Existing route/model/view-state tests that Phase 22 can extend narrowly if needed.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` - Xcode project and scheme surface for explicit Demo build/test commands.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ContentView.initialRouteTarget(arguments:)` already supports `--beauty-demo-route editor-photo|editor-camera|editor-beauty`.
- `ContentView.initialHomeStickyPreview(arguments:)` already supports `--beauty-demo-home-sticky`.
- `MeituHomeView` has a first-screen state and an initial sticky preview path that scrolls to recommendations.
- `MeituHomeModels` encodes enabled routes and disabled future tools through `.disabled`.
- `MeituEditorToolPanelView` exposes tool/category labels, supported tool state, badges, disabled `OFF` treatment, and bottom cancel/confirm controls.
- `BeautyDemoViewStateTests` already tests Home route mapping, disabled route honesty, editor taxonomy, supported tool mappings, and launch arguments.

### Established Patterns
- Evidence claims must use exact commands, file paths, destinations, and pass/fail/blocker status.
- Demo and UI work stays app-side and facade-only; Phase 22 should not touch SDK internals except through build/test dependencies.
- Current source/root docs and `.planning` ledgers override stale `.planning/codebase/*` maps.
- Archived screenshots are useful comparison context, not current evidence.
- Hardware/tooling blockers are acceptable only when reproduced and recorded with command, environment, impact, and next step.

### Integration Points
- Phase 22 evidence should live under `.planning/evidence/v1.4/`.
- Required command evidence should include explicit `xcodebuild` build/test where local tooling permits and `simctl` boot/install/launch/screenshot commands for the selected simulator.
- If build still fails on the missing Metal Toolchain, the evidence artifact should record the blocker and rerun protocol instead of producing a false pass.
- QA-04 can connect current model/route tests to screenshot notes and optional scans to prove future areas remain inactive.

</code_context>

<specifics>
## Specific Ideas

- Optimize for a small, repeatable screenshot path rather than a new UI automation framework.
- Required state coverage is intentionally narrow: Home first screen, Home sticky state, and editor beauty/photo tool panel.
- Required simulator is iPhone 17 / iOS 26.5; broader simulator coverage is optional only after the baseline path works.
- Evidence notes should say what was checked, not make broad visual fidelity or naturalness claims.

</specifics>

<deferred>
## Deferred Ideas

- Full XCUITest screenshot harness is deferred unless planning finds it cheaper than `simctl` screenshots.
- Pixel-perfect screenshot diffing and screenshot-regression baselines are deferred to a later explicit visual-regression phase.
- Editor camera route screenshot evidence is optional; permission/session complexity should not block required Phase 22 evidence.
- Physical iPhone camera/Vision parity remains blocked until hardware is available.
- Production naturalness and effect-quality review remain outside Phase 22 layout evidence.
- iPad/tablet layout evidence is out of Phase 22 unless separately promoted.

</deferred>

---

*Phase: 22-Automated Demo QA and Screenshot Evidence*
*Context gathered: 2026-06-30*
