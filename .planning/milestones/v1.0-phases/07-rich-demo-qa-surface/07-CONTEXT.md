# Phase 7: Rich Demo QA Surface - Context

**Gathered:** 2026-06-22T09:37:41Z
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 7 finishes the Demo as a complete SDK validation surface for `DEMO-06` and `DEMO-07`. It covers preset/reset/parameter JSON workflows, before/after compare and read-only debug overlay states, unavailable-state polish, final automated Demo evidence, and v1 traceability closeout.

This phase is Demo and QA-surface work. It must not add new beauty domains, new public `BeautyParameters` fields, new SDK internal imports from Demo, geometry drawing overlays, cloud/network sharing, advanced makeup, stickers, segmentation, body shaping, AI style, video export, per-face UI, or release-grade naturalness/hardware claims without separate manual proof.

</domain>

<decisions>
## Implementation Decisions

### Parameter JSON Workflow
- **D-01:** Phase 7 JSON import/export should use a copy/paste JSON sheet, not local file import/export. This keeps the workflow small, deterministic, and suitable for SDK QA.
- **D-02:** JSON uses a versioned parameter envelope with `schemaVersion` and `parameters`. The `parameters` payload is based on `BeautyParameters: Codable`.
- **D-03:** Import must decode into a preview state first, show redacted friendly errors for invalid JSON, unsupported schema, invalid values, or unknown filter IDs, and require an explicit Apply action before changing current parameters.
- **D-04:** Failed import leaves the current parameter snapshot, selected filter, selected preset, and visible slider state unchanged.
- **D-05:** Export should emit a minimal deterministic payload: `schemaVersion` plus `parameters`. Stable round-trip behavior is the priority; timestamps, app/build metadata, preset labels, detection summaries, and debug metrics are not part of the exported payload.

### Preset and Reset Semantics
- **D-06:** Single-parameter reset always resets the control to the SDK zero/default value, not a selected preset baseline.
- **D-07:** Reset All always restores SDK zero defaults and clears selected preset/import state, including filter selection.
- **D-08:** Imported JSON applies as a custom parameter snapshot. Preset chips are deselected after import.
- **D-09:** Any manual slider or filter change after applying a preset or imported JSON clears applied-source state; the current snapshot becomes custom.
- **D-10:** Phase 7 may keep the existing reset labels and behavior where they already match these semantics, but must add coverage proving JSON import follows the same source-clearing and reset rules.

### Debug Overlay Surface
- **D-11:** The final debug overlay is toggled by one preview-surface debug button near compare. It is read-only and shared by camera and photo preview paths.
- **D-12:** The overlay shows a safe diagnostic summary: detection availability, reason codes, face/used counts, detection/mapping timings, warning count, and key frame status.
- **D-13:** Phase 7 must not draw face boxes, landmarks, control points, or any geometry overlay. Use redacted summaries only.
- **D-14:** Recoverable errors in the overlay should show the last redacted error code plus friendly status. Do not show raw framework strings, paths, stack traces, `NSError`, Vision objects, landmarks, bounding boxes, or image bytes.
- **D-15:** Debug UI must not mutate SDK output, parameter state, detection state, or compare state.

### Final Demo Readiness Polish
- **D-16:** Keep the current top-level category order and facial-feature subcategory order. Implemented paths stay active; future categories stay disabled with clear short labels and reasons.
- **D-17:** Do not hide future categories for v1 and do not add tappable info pages for later domains in this phase.
- **D-18:** Phase 7 readiness requires focused view-state/pipeline tests plus privacy/import scans, extending the current XCTest style for JSON, reset, compare/debug, unavailable states, facade-only imports, and privacy/redaction boundaries.
- **D-19:** Simulator UI automation or screenshot smoke may be added if cheap, but it is not the required Phase 7 gate.
- **D-20:** Manual visual naturalness and hardware QA risks must be recorded as explicit remaining release risks. Phase 7 must not claim release-grade naturalness, real-device front-camera parity, real Vision quality, or long-run hardware readiness without proof.
- **D-21:** Final traceability closes only after implementation tests pass: mark `DEMO-06` and `DEMO-07` complete, then update `PRODUCT_SENSE.md`, `FRONTEND.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/REQUIREMENTS.md`, and `.planning/ROADMAP.md` with evidence.

### the agent's Discretion
- **D-22:** The planner and executor may choose concrete Swift type names for the JSON envelope, sheet state models, preview state names, debug overlay view model names, accessibility labels, and exact short UI copy, as long as the decisions above and root contract privacy/reliability rules are satisfied.
- **D-23:** The planner and executor may organize tests across existing Demo test files or add focused new test files. Preferred evidence remains deterministic XCTest/view-state tests and static scans, not broad brittle UI automation.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger, completed Phase 6 evidence, update rules, and current tech debt.
- `.planning/PROJECT.md` - SDK-centered product direction, Demo validation role, and local-first privacy posture.
- `.planning/REQUIREMENTS.md` - Phase 7 owns pending `DEMO-06` and `DEMO-07`.
- `.planning/ROADMAP.md` - Phase 7 goal, success criteria, and planned slots `07-01` through `07-03`.
- `.planning/STATE.md` - Current focus, session continuity, and known concerns.

### Prior Phase Context
- `.planning/phases/04-detection-and-coordinate-safety/04-CONTEXT.md` - Locks geometry-free detection summaries, safe status/debug boundaries, and no overlay boxes/points in Phase 4.
- `.planning/phases/05-filters-presets-and-resource-flow/05-CONTEXT.md` - Locks built-in preset names, preset-as-parameter-bundle behavior, resource validation, and defers dedicated JSON/preset workflows to Phase 7.
- `.planning/phases/06-core-beauty-effects/06-CONTEXT.md` - Locks quiet normal UI, existing detection status/debug surfaces, no cap banners, no new controls/category changes, and final QA/debug workflow as Phase 7 scope.

### Root Contracts
- `ARCHITECTURE.md` - Demo facade-only invariant, SDK target boundaries, and debug/UI ownership separation.
- `DESIGN.md` - `BeautyParameters: Codable`, deterministic presets, `BeautyResult`, `BeautyDetectionSummary`, and no public geometry leakage.
- `FRONTEND.md` - Demo state ownership, parameter UI ranges, reset/accessibility rules, compare/debug responsibilities, error UI, and UI testing contracts.
- `SECURITY.md` - JSON/preset validation, local-first boundary, redacted diagnostics, debug privacy, and forbidden raw paths/framework/geometry payloads.
- `RELIABILITY.md` - Recoverable error policy, degradation matrix, warning/metric boundaries, debug diagnostics, and performance/long-run risk framing.
- `PRODUCT_SENSE.md` - `DEMO-06`/`DEMO-07` user journeys, reset/control acceptance, parameter JSON round-trip acceptance, debug/degradation acceptance, and manual release-risk honesty.
- `QUALITY_SCORE.md` - Current quality snapshot, Phase 6 final verification, UI/test/security gaps, and Phase 7 top repair priorities.

### Current Demo Code
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` - Current parameter snapshot owner, preset application, filter selection, single reset, reset all, and selected preset clearing behavior.
- `BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift` - Current preset/filter picker, reset all button, status row, and panel view-state composition.
- `BeautyDemo/BeautyDemo/Panel/BeautyControlDescriptor.swift` - Control identifiers, reset labels, display ranges, and available control lists.
- `BeautyDemo/BeautyDemo/Panel/BeautyResourcePickerModels.swift` - Current preset/filter picker item models and resource failure copy.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - Current preview surface, compare button placement, camera/photo preview branching, and status banner display.
- `BeautyDemo/BeautyDemo/Editor/CompareState.swift` - Current before/after compare state and preservation tests.
- `BeautyDemo/BeautyDemo/Editor/DetectionStatusPresentation.swift` - Current status copy, `DetectionDebugSummary`, and camera status debouncer.

### Current SDK Code
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - Codable parameter model for JSON import/export and deterministic round-trip.
- `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift` - Versioned preset decode pattern and filter ID validation reference.
- `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` - Allowed redacted detection/debug summary fields.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` - Existing warnings and metrics surface for debug summary inputs.
- `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift` - Public facade for built-in preset/filter availability.

### Current Tests
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Existing view-state coverage for category order, presets, filters, reset surface, status copy, and panel paths.
- `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` - Existing parameter normalization, preset application, reset, filter, and quiet-status coverage to extend for JSON source semantics.
- `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` - Existing before/after compare behavior and state-preservation coverage.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Existing facade-only, no raw path/error, no geometry/raw framework, and detection debug privacy scans to extend for JSON/debug overlay.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameterStore` already owns all visible display values, selected filter ID, selected preset ID, parameter snapshots, preset application, single reset, and reset all.
- `BeautyParameters` already conforms to `Codable`, `Equatable`, and `Sendable`; JSON import/export should wrap it rather than inventing another parameter model.
- `BeautyPreset.decode(...)` already demonstrates schema probing, version rejection, identifier validation, and filter resource validation patterns that can inform the JSON envelope.
- `BeautyPanelView` already exposes preset chips, filter selection, reset all, and view-state generation suitable for deterministic tests.
- `CompareState` already toggles before/after display without mutating editor selection or parameters.
- `DetectionStatusPresentation` already maps `BeautyDetectionSummary` into safe status and debug fields without geometry.
- `InputPipelinePrivacyTests` already has file-scan helpers for facade-only imports and raw token/privacy scans.

### Established Patterns
- Demo source and tests import only `BeautySDK`; this remains a Phase 7 verification gate.
- Demo workflows are primarily tested through value/view-state XCTest and focused pipeline tests.
- Normal UI copy is short and friendly; raw framework errors, file paths, internal target names, raw JSON, landmarks, bounding boxes, and Vision objects do not appear in user-facing UI.
- Reset and preset behavior currently treats manual edits as custom snapshots. Phase 7 should preserve this semantic model for imported JSON.
- Compare and debug are preview-surface concerns, not parameter panel responsibilities.

### Integration Points
- Add a Demo-side JSON envelope and import/export state around `BeautyParameterStore.parametersSnapshot`.
- Add copy/paste JSON sheet presentation from the Demo UI without creating file importer/exporter scope.
- Add an explicit preview/apply state for valid imported JSON and friendly redacted failure state for invalid JSON.
- Add imported/custom source clearing to `BeautyParameterStore` only as needed to express decisions; do not create a preset-like imported chip.
- Add a read-only debug overlay model near `EditorShellView`/preview state that combines detection summary, warning count, key frame status, and last redacted error code.
- Extend Demo tests for JSON round-trip, invalid import non-mutation, unknown filter ID handling, reset/source clearing, debug overlay redaction, compare/debug coexistence, disabled/future copy, and final import/privacy scans.
- Close traceability in `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `PLANS.md` only after implementation verification passes.

</code_context>

<specifics>
## Specific Ideas

- The JSON entry should feel like a QA utility for developers and testers, not a full end-user file management feature.
- JSON export should be stable enough for exact string or normalized JSON round-trip tests.
- Imported JSON is a custom parameter snapshot, not a built-in preset and not a saved custom preset feature.
- Debug overlay should be useful for QA screenshots and failure reports while staying privacy-safe and read-only.
- Future categories remain visible as product direction but inactive for v1.

</specifics>

<deferred>
## Deferred Ideas

- Local file import/export for parameter JSON.
- Preset-like saved custom looks with IDs, display names, versions, and persistence.
- Revert-to-preset/import-baseline actions.
- Geometry overlays such as face boxes, landmarks, or control points.
- Simulator screenshot/UI automation as a hard Phase 7 completion gate.
- Release-grade naturalness, real-device front-camera parity, real Vision quality, long-run hardware checks, and production render-quality claims without manual proof.

</deferred>

---

*Phase: 7-Rich Demo QA Surface*
*Context gathered: 2026-06-22T09:37:41Z*
