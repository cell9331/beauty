# Phase 21: Baseline Audit and Quality Ledger Refresh - Context

**Gathered:** 2026-06-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 21 establishes the true v1.4 quality, verification, and technical-debt baseline before implementation changes. It covers `AUD-01`, `AUD-02`, `AUD-03`, and `AUD-04`.

This is an audit and planning-cleanup phase. It must inventory and, where feasible, run the baseline verification commands for current SDK tests, Demo build/test availability, renderer build/run, import-boundary scans, privacy scans, current quality scores, and technical debt routing. It must record pass/fail/blocker status honestly.

Phase 21 must not fix downstream debt early, refresh broad codebase maps, add product features, add public `BeautyParameters`, add SwiftUI redesigns, introduce network/cloud behavior, or claim release readiness. Its output should tell Phases 22-25 exactly what evidence exists, what failed, what is blocked by local tooling/hardware, and how TD-005, TD-008, TD-009, and TD-010 are routed.

</domain>

<decisions>
## Implementation Decisions

### Baseline Evidence Bar
- **D-01:** Phase 21 must run the full available baseline sweep rather than only listing commands. The sweep should include SDK tests, Demo `xcodebuild` availability/build/test checks where local simulator tooling allows, `BeautyExampleRenderer` build/run, import-boundary scans, privacy/security scans, renderer command inventory, and root/planning consistency checks.
- **D-02:** A failing baseline command does not automatically fail the phase if the failure is classified and recorded. The required record is exact command, relevant environment, concise failure output summary, affected requirement/debt area, blocker classification, and recommended next step.
- **D-03:** Phase 21 evidence must distinguish command results that passed now, existing archived evidence from v1.3, checks not attempted, checks blocked by toolchain/hardware, and checks intentionally deferred to later v1.4 phases.
- **D-04:** Phase 21 should not make performance, visual, hardware, privacy, or release-readiness claims beyond the evidence it actually runs or cites.

### Debt Triage Policy
- **D-05:** Phase 21 triages and routes TD-005, TD-008, TD-009, and TD-010; it does not preemptively fix them.
- **D-06:** Each debt item must be assigned one of: routed to a later v1.4 phase, explicitly deferred beyond v1.4, or blocked with reproducible evidence.
- **D-07:** TD-005 Privacy Manifest should normally route toward Phase 25 unless Phase 21 discovers that the manifest status is already resolved or blocked by missing Apple-required-reason API information.
- **D-08:** TD-008 Manual Device QA should normally route toward Phase 22 or Phase 23 depending on whether the needed evidence is visual/camera UI or performance/long-run, but may be blocked if no physical iPhone is available.
- **D-09:** TD-009 Manual Visual QA should normally route toward Phase 22, because Phase 22 owns deterministic Demo visual/layout evidence.
- **D-10:** TD-010 Phase 6 Visual and Hardware QA should be split into the relevant later phases rather than handled as one blob: visual/layout to Phase 22, performance/long-run to Phase 23, renderer output to Phase 24, and privacy/security implications to Phase 25.

### Stale Codebase Maps
- **D-11:** `.planning/codebase/*` maps are stale for current v1.4 planning. Phase 21 may cite this as a baseline issue, but downstream agents must not treat those maps as current source of truth.
- **D-12:** Phase 21 should not refresh `.planning/codebase/TESTING.md`, `.planning/codebase/CONCERNS.md`, `.planning/codebase/CONVENTIONS.md`, or other codebase maps. Formal remapping is deferred to an explicit later task or Phase 25 closeout candidate.
- **D-13:** When stale codebase maps conflict with actual source, root docs, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, current tests, or v1.3 archives, the current source and current planning/root contracts win.
- **D-14:** Phase 21 should record stale maps in `PLANS.md` or `QUALITY_SCORE.md` as a risk/debt item, and planning should use actual source/test scans plus current root docs instead.

### Hardware and Tooling Blocker Rules
- **D-15:** Hardware/tooling blockers are acceptable only when reproducible. Records must include the exact command attempted, selected simulator/device destination or hardware assumption, environment detail that matters, concise failure summary, impact, and next step.
- **D-16:** Do not write vague blockers such as "local machine unavailable" or "simulator failed" without the command and failure evidence.
- **D-17:** Missing physical iPhone, incompatible CoreSimulator, unavailable simulator destination, or long-run memory tooling limitations should not silently block all of v1.4. They should be classified and routed so later phases can proceed with simulator/SwiftPM evidence while preserving manual/hardware gaps.
- **D-18:** If an evidence gate requires hardware that is not present, Phase 21 should write a manual protocol and mark the gate blocked or deferred rather than claiming it passed.

### the agent's Discretion
The planner may choose exact command ordering, output file names, and whether to group evidence into one audit document or several small sections, as long as the four decision groups above remain intact. Prefer narrow, reproducible command evidence over broad prose. Keep file scopes explicit because the worktree has unrelated uncommitted changes outside this phase.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger, update rules, v1.4 milestone-start record, and technical debt table.
- `.planning/PROJECT.md` — Defines v1.4 as stability, QA, performance, security, and debt cleanup without product-feature expansion.
- `.planning/REQUIREMENTS.md` — Defines `AUD-01`, `AUD-02`, `AUD-03`, and `AUD-04` and maps them to Phase 21.
- `.planning/ROADMAP.md` — Defines Phase 21 goal, success criteria, and dependency on v1.3 archive plus v1.4 research.
- `.planning/STATE.md` — Records v1.4 current focus and Phase 21 as the next step.
- `.planning/research/SUMMARY.md` — Research summary for v1.4 evidence-first hardening, phase ordering, and pitfalls.
- `.planning/research/FEATURES.md` — v1.4 table-stakes features and anti-features.
- `.planning/research/PITFALLS.md` — v1.4 pitfalls including optimizing without baseline, flaky screenshots, simulator-only claims, privacy drift, and scope creep.

### Prior Phase Decisions
- `.planning/phases/18-skin-retouch-core-modules/18-CONTEXT.md` — Locks factual renderer evidence, conservative implementation, and future-branch negative scan patterns.
- `.planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md` — Locks no-new-UI/API, honest partial/blocked geometry status, and negative-scan expectations.
- `.planning/phases/20-core-module-closeout/20-CONTEXT.md` — Locks v1.3 closeout evidence threshold, current renderer matrix, no broad simulator sweep unless needed, and no historical-doc normalization by default.

### Root Contracts
- `QUALITY_SCORE.md` — Current quality scorecard, test coverage gaps, documentation gardening checks, repair queue, and score update rules.
- `RELIABILITY.md` — Performance budgets, long-run gate, backpressure rules, metrics redaction, and release readiness gates.
- `SECURITY.md` — Privacy manifest rule, local-first posture, no-upload/no-network expectations, resource trust, and logging/metric redaction.
- `PRODUCT_SENSE.md` — Product acceptance, release-hardening caveats, and visual/naturalness evidence requirements.
- `ARCHITECTURE.md` — SDK/Demo boundary, public facade rule, no UI in SDK, and target dependency direction.
- `DESIGN.md` — Public model and parameter contracts; no public parameter expansion by default.
- `FRONTEND.md` — Demo ownership, UI state, visual evidence hooks, and release-hardening risks.

### Current Evidence and Code Surfaces
- `BeautySDK/Package.swift` — SwiftPM package definition for SDK test/build commands.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Current public-facade renderer matrix and output path.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public facade path used by renderer and SDK tests.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Current public parameter inventory; Phase 21 must not expand it.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` — Demo scheme, generated Info.plist settings, and simulator build/test surface.
- `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` — Existing facade-only Demo import evidence.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` — Existing purpose string, no-network/no-upload, no raw path/error copy, no realtime `UIImage`, and debug/privacy scan evidence.
- `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` — Existing `alwaysDiscardsLateVideoFrames` evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` — Existing facade-level result and warning/metric evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — Existing resolver, cap, warning/metric, and redaction evidence.

### Known Stale Context
- `.planning/codebase/TESTING.md` — Early codebase map that currently conflicts with the implemented SDK/tests state.
- `.planning/codebase/CONCERNS.md` — Early codebase map that currently conflicts with v1.3 completion.
- `.planning/codebase/CONVENTIONS.md` — Early codebase map that may still contain useful naming/style notes, but must not override current source/root docs.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `swift test --package-path BeautySDK` is the full SDK test command used in v1.3 closeout evidence.
- `BeautyExampleRenderer` already builds and runs current skin/color/filter output cases through the public `BeautySDK` facade.
- `BeautyDemo` has existing XCTest files for view state, import boundary, input privacy, camera session behavior, parameter store behavior, compare/debug behavior, and JSON import/export behavior.
- `QUALITY_SCORE.md` already contains repeatable architecture, documentation, security, reliability, and build scan commands that Phase 21 can reuse.
- `PLANS.md` already lists TD-005, TD-008, TD-009, and TD-010, but some older debt statuses such as TD-003 and TD-004 appear stale and should be audited carefully.

### Established Patterns
- Evidence claims are strongest when tied to exact commands, scoped scan outputs, committed verification files, or archived phase artifacts.
- Demo and renderer validation must stay facade-only.
- Generated example-image outputs remain local ignored artifacts under `example-images/out/`.
- Root contracts and current `.planning` files are authoritative over historical docs and stale codebase maps.
- Hardware/simulator failures are recorded as reproducible blockers, not hand-waved.

### Integration Points
- Phase 21 should likely produce a phase audit artifact under `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/` in addition to updating current ledgers.
- Phase 21 should update `QUALITY_SCORE.md` only where the audit produces current evidence; score increases require actual code, tests, command output, or recorded manual checks.
- Phase 21 should update `PLANS.md` to route TD-005, TD-008, TD-009, and TD-010 without implementing those debts.
- Phase 21 should update `.planning/STATE.md` and `.planning/ROADMAP.md` only through GSD handlers where handlers exist, or with tightly scoped planning edits when no handler exists.

</code_context>

<specifics>
## Specific Ideas

- Baseline should be evidence-first, not inventory-only.
- Debt routing should keep Phase 21 as an audit baseline and leave fixes to later phases.
- Stale codebase maps should be flagged clearly so downstream agents do not treat them as current.
- Hardware and tooling blockers should be reproducible records with commands and impact, not vague notes.

</specifics>

<deferred>
## Deferred Ideas

- Formal refresh of `.planning/codebase/*` maps is deferred to an explicit remap task or Phase 25 closeout candidate.
- Fixing TD-005, TD-008, TD-009, or TD-010 is deferred to routed later phases unless Phase 21 only records their status.
- Automated Demo visual evidence belongs to Phase 22.
- Performance and long-run reliability implementation belongs to Phase 23.
- Renderer output regression hardening belongs to Phase 24.
- Privacy manifest changes, resource trust closeout, and final security scans belong to Phase 25.

</deferred>

---

*Phase: 21-Baseline Audit and Quality Ledger Refresh*
*Context gathered: 2026-06-30*
