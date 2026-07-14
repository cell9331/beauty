# Phase 7: Rich Demo QA Surface - Research

**Researched:** 2026-06-22
**Status:** Complete

## Research Goal

Answer what the planner needs to know to implement Phase 7 safely: how to add Demo-side copy/paste parameter JSON, reset/source semantics, read-only debug overlay, unavailable-state polish, and final QA evidence without changing SDK public parameters, importing internal SDK targets, leaking face/debug data, or overstating release readiness.

## Source Inputs

- `.planning/phases/07-rich-demo-qa-surface/07-CONTEXT.md`
- `.planning/phases/04-detection-and-coordinate-safety/04-CONTEXT.md`
- `.planning/phases/05-filters-presets-and-resource-flow/05-CONTEXT.md`
- `.planning/phases/06-core-beauty-effects/06-CONTEXT.md`
- `.planning/phases/06-core-beauty-effects/06-PATTERNS.md`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `AGENTS.md`
- `PLANS.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `FRONTEND.md`
- `SECURITY.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `QUALITY_SCORE.md`
- Current `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`, `BeautySDK/Sources`, and `BeautySDK/Tests`

## Phase Scope Findings

Phase 7 covers exactly these requirements:

- `DEMO-06`: Demo supports preset selection, single-parameter reset, reset-all, and basic parameter JSON import/export.
- `DEMO-07`: Demo provides before/after compare and debug overlay states for detection, degradation, and recoverable errors.

The user decisions in `07-CONTEXT.md` narrow the implementation:

- JSON import/export is a copy/paste sheet, not local file import/export.
- JSON uses `schemaVersion` plus `parameters`, where `parameters` is based on `BeautyParameters: Codable`.
- Import decodes into preview state first and applies only through an explicit Apply action.
- Failed import leaves current parameters, selected filter, selected preset, and visible sliders unchanged.
- Export output is minimal and deterministic: no timestamps, app/build metadata, preset labels, detection summaries, or debug metrics.
- Single reset and reset all restore SDK zero defaults, not selected-preset or imported baselines.
- Imported JSON is a custom parameter snapshot and deselects preset chips.
- Manual slider or filter changes clear applied-source state.
- Debug overlay is a single read-only preview-surface toggle near compare, shared by Camera and Photo paths.
- Debug overlay shows redacted summaries only and must not draw face boxes, landmarks, control points, geometry overlays, raw framework strings, paths, stack traces, `NSError`, Vision objects, or image bytes.
- Final traceability and docs update only after implementation tests pass.

## Current Codebase Findings

### Parameter Store and Source Semantics

`BeautyParameterStore` already owns:

- `displayValues: [BeautyControlID: Double]`
- `selectedFilterId: String?`
- `selectedPresetId: String?`
- `status: BeautyParameterStatus`
- `parametersSnapshot: BeautyParameters`
- `applyPreset(_:)`
- `reset(_:)`
- `resetAll()`

Current behavior already matches part of Phase 7:

- `setDisplayValue(_:for:)` clears `selectedPresetId` and keeps `status` idle.
- `selectFilter(id:)` clears `selectedPresetId`; selecting `nil` resets filter intensity.
- `reset(_:)` resets only one display value and clears `selectedPresetId`.
- `resetAll()` resets every available control, clears `selectedFilterId`, clears `selectedPresetId`, and returns `parametersSnapshot` to `BeautyParameters()`.
- Applying a preset calls private `apply(parameters:)`, then sets `selectedPresetId`.

Planning implication:

- Add only the minimum state needed to distinguish custom/imported/preset source for tests and UI affordances.
- Avoid a preset-like imported chip or persistence system.
- Expose a Demo-side method such as `applyImportedParameters(_:)` or equivalent so JSON import uses the same display-value synchronization as presets while clearing `selectedPresetId`.
- Be careful with the current private `apply(parameters:)`: it calls public setter methods that clear `selectedPresetId` repeatedly before `applyPreset(_:)` sets it. That is acceptable today but should not accidentally set imported source to custom while applying the imported snapshot.

### Parameter JSON Envelope

`BeautyParameters` is already `Codable`, `Equatable`, and `Sendable` and has custom decoding that defaults missing numeric fields to zero and clamps non-finite/out-of-range values in `init`.

`BeautyPreset.decode(from:availableFilterIds:)` already demonstrates the closest schema pattern:

- Probe `schemaVersion`.
- Reject unsupported schema with a short redacted code.
- Decode a versioned envelope.
- Validate identifiers and referenced filter resources.
- Map decode failures to typed/redacted public errors.

`BeautySDKResources.validate(parameters:)` is the correct public facade for Demo validation:

- It normalizes `BeautyParameters`.
- It rejects invalid or unknown `filterId` via `BeautyError.resourceNotFound`.
- Demo can import only `BeautySDK` and still validate filter references.

Planning implication:

- Put the copy/paste JSON model in Demo, likely under `BeautyDemo/BeautyDemo/State` or a small new `ImportExport`/`Support` file.
- Keep the envelope shape simple:
  - `schemaVersion: 1`
  - `parameters: BeautyParameters`
- Keep `schemaVersion` exact-match for v1; unsupported versions should produce friendly redacted copy such as `Unsupported parameter JSON version.` while tests assert a stable internal reason code if a model has one.
- Validate decoded parameters through `BeautySDKResources.validate(parameters:)` before presenting the Apply preview.
- Unknown extra fields can be ignored by `Codable` as long as the `parameters` object decodes; tests should prove this only if the executor explicitly supports forward-compatible unknowns.
- Add a size limit before decoding so pasted JSON cannot be arbitrarily large. A concrete limit such as 64 KB is enough for 31 parameters and matches the local QA utility scope.

### JSON Sheet and UI Placement

`EditorShellView` currently owns the preview surface, compare button, Camera/Photo branching, and `BeautyParameterStore` instance. `BeautyPanelView` owns preset/filter controls and reset-all.

Phase 7 context says import/export should be a QA utility and compare/debug live near the preview surface. The existing design contracts also say enum-driven sheet state should avoid parallel booleans.

Planning implication:

- Add a single sheet enum owned by `EditorShellView`, for example cases for parameter JSON import/export.
- Put JSON actions close to the preview/tool surface or a compact toolbar, not as hidden per-control actions.
- The sheet should have explicit Import and Export modes or a segmented state, but the exported payload must be generated from `parameterStore.parametersSnapshot`.
- Import should decode into a preview model first. The Apply action then updates `BeautyParameterStore`; Cancel/dismiss leaves the store unchanged.
- Tests can validate all state transitions through pure models instead of UI automation.

### Compare and Debug Overlay

`CompareState` is already a pure value model:

- Starts on `.after`.
- Toggles between `.before` and `.after`.
- Selects photo `inputCGImage` or `outputCGImage`.
- Selects camera `inputPixelBuffer` or `outputPixelBuffer`.
- `preservingEditorState(...)` proves compare toggles without changing mode/category/subcategory/parameters.

`DetectionStatusPresentation` already provides the redacted detection path:

- Status text for no-face, partial, low-confidence, and stale summaries.
- `DetectionDebugSummary` with availability, reason codes, face counts, used-face counts, detection duration, and mapping duration.

Camera and Photo snapshots already carry `detectionSummary`:

- `CameraProcessingSnapshot.detectionSummary`
- `ImageProcessingSnapshot.detectionSummary`

`BeautyResult` carries `warnings`, `metrics`, and `detectionSummary`, but the Demo snapshots currently retain only detection summary plus parameters/output. Recoverable processor failures collapse to friendly pause/decode text.

Planning implication:

- Add a new read-only Demo-side debug overlay model near `DetectionStatusPresentation`, for example `PreviewDebugOverlayState`.
- Source the overlay from the latest camera or photo snapshot plus pipeline status:
  - detection availability
  - reason codes
  - face count and used face count
  - detection/mapping durations
  - warning count, if the pipeline starts preserving warnings
  - key frame status such as `cameraRunning`, `photoLoaded`, `photoLoading`, `photoFailed`, or `processingPaused`
  - last redacted error code/friendly status if a recoverable failure occurred
- If warning arrays are needed, plan a narrow snapshot extension in Camera/Photo pipeline models rather than exposing raw internals in the UI.
- Debug overlay must not mutate `CompareState`, `BeautyParameterStore`, processing snapshots, or detection state.
- Tests should scan rendered/debug summary strings for forbidden tokens, matching `InputPipelinePrivacyTests`.

### Existing Test Strategy

Current Demo tests provide useful seams:

- `BeautyParameterStoreTests`: parameter normalization, filter selection, preset application, single reset, reset all, quiet status.
- `BeautyDemoViewStateTests`: category order, disabled states, mode and preview state, filter/preset picker state, reset surface, panel paths.
- `CompareStateTests`: before/after toggles and state preservation.
- `InputPipelinePrivacyTests`: purpose strings, local-first scans, no realtime `UIImage`, facade-only imports, raw path/error scans, detection debug redaction.
- `BeautyDemoImportBoundaryTests`: Demo facade-only import boundary.

Planning implication:

- Prefer deterministic XCTest and static scans as Phase 7 hard gates.
- Add a focused JSON import/export test file or extend `BeautyParameterStoreTests`.
- Extend `CompareStateTests` or add a debug overlay test file for debug/compare coexistence.
- Extend `InputPipelinePrivacyTests` to scan JSON/debug code for raw JSON dumps, internal target imports, geometry tokens, raw framework errors, local paths, and network/upload calls.
- Full simulator UI automation remains optional; it must not be a hard Phase 7 completion gate unless the executor can run it cheaply and reliably.

## Recommended Implementation Shape

### JSON Import/Export Model

Recommended Demo-side types:

- `ParameterJSONEnvelope`
  - `schemaVersion: Int`
  - `parameters: BeautyParameters`
- `ParameterJSONImportState`
  - idle/editing/preview/failed states, or equivalent enum
  - stores candidate `BeautyParameters` only after decode and facade validation
  - stores short redacted error copy for invalid JSON, unsupported schema, invalid values, or unknown filter IDs
- `ParameterJSONCoding`
  - deterministic encoder with sorted keys if available through `JSONEncoder.outputFormatting`
  - size limit before decoding
  - validates through `BeautySDKResources.validate(parameters:)`

Concrete behavior to plan:

- Export from current `parameterStore.parametersSnapshot`.
- Export contains only `schemaVersion` and `parameters`.
- Import Apply calls a store method that synchronizes all display values, filter selection, and source state from the validated `BeautyParameters`.
- Failed import never calls a store mutation method.
- Unknown filter IDs fail before preview/apply, and current selected filter remains unchanged.

### Parameter Source Tracking

Recommended store addition:

- A small enum such as `BeautyParameterSource: Equatable, Sendable`
  - `custom`
  - `preset(id: String)`
  - `imported`

Concrete behavior to plan:

- Initial state is `.custom`.
- Applying a preset sets `.preset(id:)` and `selectedPresetId`.
- Applying imported JSON sets `.imported` and clears `selectedPresetId`.
- Any manual slider change sets `.custom` and clears `selectedPresetId`.
- Any filter selection sets `.custom` and clears `selectedPresetId`.
- Single reset sets `.custom`.
- Reset all sets `.custom`, clears `selectedFilterId`, clears `selectedPresetId`, and returns `parametersSnapshot == BeautyParameters()`.

The UI does not need to surface this enum prominently; tests need it to prove source semantics.

### Preview Debug Overlay

Recommended Demo-side types:

- `PreviewDebugOverlayState`
  - `isVisible: Bool`
  - `inputMode: EditorInputMode?`
  - `frameStatus: String`
  - `detection: DetectionDebugSummary?`
  - `warningCount: Int`
  - `lastErrorCode: String?`
  - `friendlyStatus: String?`
- `PreviewDebugOverlayView`
  - read-only SwiftUI overlay
  - no geometry drawing
  - compact rows with stable labels

Concrete behavior to plan:

- One preview-surface debug button near compare toggles visibility.
- Button can be available in Camera and Photo preview paths.
- Toggle changes only overlay visibility.
- Overlay reads latest camera/photo snapshot detection summary where available.
- Overlay can display friendly status text already used by preview state.
- Overlay never uses `CGPoint`, `CGRect`, `VNFaceObservation`, raw error strings, raw local paths, or image bytes.

### Final Docs and Traceability

Final implementation should update docs only after tests pass:

- `.planning/REQUIREMENTS.md`: mark `DEMO-06` and `DEMO-07` complete.
- `.planning/ROADMAP.md`: mark Phase 7 plans complete during execution summaries and close Phase 7 only after verification.
- `FRONTEND.md`: record JSON sheet, debug overlay, compare/source semantics, and tests.
- `PRODUCT_SENSE.md`: record Phase 7 acceptance evidence for JSON/reset/debug/compare workflows.
- `QUALITY_SCORE.md`: update current snapshot and Phase 7 final verification evidence.
- `PLANS.md`: completion evidence and remaining release risks.

Do not claim release-grade naturalness, real-device front-camera parity, real Vision quality, production render quality, or long-run hardware readiness without manual proof.

## Validation Architecture

Phase 7 should use XCTest plus static scans.

Recommended quick commands:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests`
- `rg -n "import Beauty(Core|Render|Detection|Effects|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests`
- `rg -n "VNFaceObservation|boundingBox|landmark|CGPoint|CGRect|NSError|/private/var|rawPresetJson|URLSession|http://|https://|upload" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests`

Recommended full closeout commands:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test`
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK`
- `git diff --check -- BeautyDemo BeautySDK ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning`

Manual-only checks should remain release-risk evidence, not Phase 7 blockers:

- Naturalness review of fixtures or simulator preview.
- Real-device front-camera and real Vision parity.
- Long-run hardware/memory checks.
- Production render-quality claims.

## UI Contract Gate

Phase 7 is clearly a Demo/UX phase: the roadmap and context include JSON sheets, compare controls, debug overlay, unavailable-state polish, and QA-facing UI. The GSD `workflow.ui_safety_gate` setting is enabled, and no `07-UI-SPEC.md` exists at research time.

Planning implication:

- Research can complete.
- PLAN.md generation should stop until `$gsd-ui-phase 7` creates an approved UI design contract, or the operator explicitly reruns planning with `--skip-ui`.

## Landmines

- Do not add local file import/export, file pickers, document persistence, or saved custom preset management.
- Do not add public `BeautyParameters` fields or new beauty domains.
- Do not make Demo import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources`.
- Do not resolve JSON filter IDs as paths or URLs.
- Do not log or display raw pasted JSON, raw framework errors, local paths, image bytes, Vision objects, bounding boxes, landmarks, control points, or stack traces.
- Do not let failed import mutate `BeautyParameterStore`.
- Do not let debug overlay mutate compare, parameters, detection, or SDK output.
- Do not change current top-level category order or facial-feature subcategory order.
- Do not turn optional screenshot/UI automation into a hard Phase 7 gate unless it is actually run and stable.
- Do not close `DEMO-06` or `DEMO-07` before implementation tests pass.

## RESEARCH COMPLETE

Phase 7 research is complete. The planner should not generate PLAN.md files until the missing UI design contract gate is resolved or planning is explicitly rerun with `--skip-ui`.
