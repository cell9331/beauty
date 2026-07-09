# Phase 07 - Pattern Map

**Mapped:** 2026-06-22
**Scope:** Demo parameter JSON workflows, source/reset semantics, preview debug overlay, unavailable-state polish, final QA evidence, and v1 traceability closeout.

## Source Inputs

- `.planning/phases/07-rich-demo-qa-surface/07-CONTEXT.md`
- `.planning/phases/07-rich-demo-qa-surface/07-RESEARCH.md`
- `.planning/phases/07-rich-demo-qa-surface/07-VALIDATION.md`
- `.planning/phases/07-rich-demo-qa-surface/07-UI-SPEC.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `FRONTEND.md`
- `SECURITY.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `QUALITY_SCORE.md`
- `BeautyDemo/BeautyDemo`
- `BeautyDemo/BeautyDemoTests`
- `BeautySDK/Sources/BeautyCore/Models`
- `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift`

## Implementation Pattern Map

| New / Changed Area | Closest Existing Analog | Pattern to Preserve |
| --- | --- | --- |
| Parameter JSON envelope | `BeautyPreset.decode(from:availableFilterIds:)` and `BeautyParameters: Codable` | Keep schema probing explicit, use `schemaVersion: 1`, wrap `BeautyParameters`, validate filter IDs before apply, and keep errors redacted. |
| Import preview state | `PhotoProcessingState` and `EditorPreviewViewState` | Use enum-driven value state with preview/failed states; failed import must not mutate current store values. |
| Deterministic JSON export | `BeautyParameters` Codable tests and `BeautySDKResources.validate(parameters:)` | Export only `schemaVersion` and `parameters`; use stable encoder output; do not add timestamps, labels, diagnostics, source names, paths, or debug metrics. |
| Parameter source semantics | `BeautyParameterStore.selectedPresetId`, `selectedFilterId`, `applyPreset(_:)`, `reset(_:)`, `resetAll()` | Store owns source state; preset/import/custom transitions are tested through value state, not hidden UI side effects. |
| Preview toolbar and sheet | `EditorShellView.previewSurface`, `compareButton`, and `.onChange` state ownership | Keep preview-surface tools compact, use one enum-driven sheet state, and keep compare labels unchanged. |
| Debug overlay value model | `DetectionStatusPresentation` and `DetectionDebugSummary` | Reuse public `BeautyDetectionSummary`; expose only availability, reason codes, counts, timings, warning count, frame status, and redacted error/status copy. |
| Debug overlay UI | `cameraStatusBanner(_:)`, `BeautyPanelView` compact text/chip styling | Use 13 px rows, 8 px gaps, white/accent surfaces, no geometry drawing, no full-screen modal, and no new palette. |
| Camera/photo debug inputs | `CameraProcessingSnapshot`, `CameraProcessingState`, `ImageProcessingSnapshot`, `PhotoProcessingState` | Preserve snapshots as value records; add only redacted warning/error counts or codes needed by the overlay. |
| Compare preservation | `CompareState.preservingEditorState(...)` and `CompareStateTests` | Compare and debug toggles are display-only and cannot mutate parameters, category selection, detection summaries, or SDK output. |
| Unavailable-state polish | `BeautyCategoryModels`, `BeautyCategoryRailView`, `BeautyPanelView.viewState(...)` | Preserve top-level and facial-feature ordering; future items stay disabled and visible with short reason copy. |
| Privacy and facade scans | `InputPipelinePrivacyTests` and `BeautyDemoImportBoundaryTests` | Keep Demo and tests importing only `BeautySDK`; scan active JSON/debug code for internal targets, geometry tokens, raw framework errors, paths, network/upload, and raw JSON dumps. |
| Final closeout docs | Phase 6 `06-05-SUMMARY.md`, root docs, and `QUALITY_SCORE.md` | Update owning root contracts only after tests pass; keep manual naturalness/hardware risks explicit. |

## Concrete Existing Details

### Demo State and UI

- `BeautyParameterStore` currently owns `displayValues`, `selectedFilterId`, `selectedPresetId`, `status`, `parametersSnapshot`, `applyPreset(_:)`, `reset(_:)`, and `resetAll()`.
- `setDisplayValue(_:for:)`, `selectFilter(id:)`, `reset(_:)`, and `resetAll()` already clear selected presets and keep normal status idle.
- `resetAll()` already restores all available controls to default display value, clears `selectedFilterId`, clears `selectedPresetId`, and returns `parametersSnapshot` to `BeautyParameters()`.
- `EditorShellView` owns preview surface state, compare button placement, Camera/Photo branch rendering, selected mode, and the single `BeautyParameterStore`.
- `BeautyPanelView.viewState(...)` is the established deterministic seam for panel/category tests.
- `BeautyCategory.all` order is `Beauty`, `Face Shape`, `Facial Features`, `Makeup`, `Filters`, `Stickers`, `Background`, `Style`.
- `FacialFeatureSubcategory.all` order is `Eyes`, `Nose`, `Mouth`, `Eyebrows`, `Teeth`, `Hairline`.

### SDK and Resource Facade

- `BeautyParameters` already conforms to `Codable`, `Equatable`, and `Sendable`.
- `BeautyParameters` decoding defaults missing numeric fields to zero and the initializer clamps non-finite or out-of-range numeric values.
- `BeautySDKResources.validate(parameters:)` normalizes parameters and rejects invalid or unknown `filterId` through the public facade.
- Demo source and tests must not import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources`.

### Debug and Detection

- `DetectionStatusPresentation` maps `BeautyDetectionSummary` into safe status copy and `DetectionDebugSummary`.
- `DetectionDebugSummary` currently exposes only availability, reason codes, face counts, used-face counts, detection duration, and mapping duration.
- `CameraProcessingSnapshot` and `ImageProcessingSnapshot` already carry `BeautyDetectionSummary?`.
- `CameraProcessingState.statusText` and `PhotoProcessingState.statusText` already surface friendly recoverable status copy.
- Recoverable camera failure currently shows `Processing paused. Showing the last usable preview.`
- Photo decode failure currently shows `Could not read that photo. Choose another image.`

### Test Seams

- `BeautyParameterStoreTests` covers normalization, filter selection, preset application, reset one, reset all, and quiet status.
- `BeautyDemoViewStateTests` covers category order, disabled states, preview state, preset/filter picker state, reset surface, and panel paths.
- `CompareStateTests` covers before/after labels, camera/photo source selection, and state preservation.
- `InputPipelinePrivacyTests` owns source scans for local-first input, facade-only imports, raw path/error copy, geometry/raw framework leakage, and resource/UI privacy.
- The Xcode project uses `PBXFileSystemSynchronizedRootGroup`, so adding Swift files under `BeautyDemo/BeautyDemo` or `BeautyDemo/BeautyDemoTests` does not require manual `project.pbxproj` file entries unless target membership exceptions are introduced.

## Planned File Ownership

| Plan | Primary Files | Notes |
| --- | --- | --- |
| `07-01` | `BeautyParameterStore.swift`, new Demo-side JSON coding/state files, `EditorShellView.swift`, store/JSON/view-state tests | Adds copy/paste parameter JSON, preview-before-apply, deterministic export, imported/custom/preset source semantics, and JSON sheet wiring. |
| `07-02` | `EditorShellView.swift`, `DetectionStatusPresentation.swift`, new debug overlay files, camera/photo snapshot state, compare/view-state/privacy tests | Adds one read-only debug overlay near compare and preserves disabled/future category copy. |
| `07-03` | Demo tests, static scans, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, root docs, `QUALITY_SCORE.md`, `PLANS.md` | Runs final QA/readiness gates and closes Phase 7 traceability only after implementation verification passes. |

## Landmines

- Do not add local file import/export, document pickers, share sheets, saved custom presets, or parameter persistence.
- Do not add public `BeautyParameters` fields, new beauty domains, per-face UI, or new SDK targets.
- Do not resolve JSON `filterId` values as paths or URLs.
- Do not display raw pasted JSON outside the explicit JSON sheet field.
- Do not log raw JSON payloads, local paths, raw framework errors, Vision objects, image bytes, bounding boxes, landmarks, control points, `CGPoint`, or `CGRect`.
- Do not let failed import mutate parameters, selected filter, selected preset, sliders, compare state, or processing snapshots.
- Do not let debug overlay mutate compare, parameters, detection summaries, SDK output, or processing snapshots.
- Do not hide future categories or reorder top-level categories or facial-feature subcategories.
- Do not claim release-grade naturalness, real-device front-camera parity, real Vision quality, production render quality, or long-run hardware readiness without manual proof.

