---
phase: 07-rich-demo-qa-surface
plan: 07-02
subsystem: ios-demo
tags: [swiftui, xctest, debug-overlay, compare, privacy, unavailable-states]

requires:
  - phase: 07-rich-demo-qa-surface
    provides: 07-01 parameter JSON toolbar and enum-driven sheet
provides:
  - Read-only preview debug overlay for camera and photo paths
  - Redacted debug value state for detection summaries, warning counts, and recoverable error codes
  - Final v1 unavailable-state copy for future categories and subcategories
affects: [07-rich-demo-qa-surface, demo-qa, privacy-scans, preview-toolbar]

tech-stack:
  added: []
  patterns:
    - Pure value-state debug rows sourced from public BeautyDetectionSummary only
    - Preview toolbar actions keep compare, debug, and Parameter JSON display-only except explicit JSON apply
    - Future Demo domains remain visible and disabled with short v1 copy

key-files:
  created:
    - BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayState.swift
    - BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayView.swift
  modified:
    - BeautyDemo/BeautyDemo/Editor/EditorShellView.swift
    - BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift
    - BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift
    - BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift
    - BeautyDemo/BeautyDemo/Panel/BeautyCategoryModels.swift
    - BeautyDemo/BeautyDemoTests/CompareStateTests.swift
    - BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift
    - BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift

key-decisions:
  - "Preview debug state is a Demo-only value model; it stores counts, public summary strings, and stable redacted codes, never raw errors or face geometry."
  - "The debug toggle is local SwiftUI display state and preserves compare, parameter, mode, category, subcategory, and processing snapshots."
  - "Future unavailable copy now says Not in v1 instead of referring to Phase 2 or future resource support."

patterns-established:
  - "PreviewDebugOverlayState.camera/photo map processing states into stable redacted rows."
  - "PreviewDebugVisibilityState provides exact debug button title/accessibility copy and preservation tests."
  - "Disabled category tests assert both order and absence of future-domain active controls."

requirements-completed: [DEMO-07]

duration: 11m 30s
completed: 2026-06-23
---

# Phase 07 Plan 07-02: Add Final Compare, Debug Overlay, and Unavailable-State Polish Summary

**Read-only preview debug overlay with redacted camera/photo diagnostics and final v1 unavailable-state copy.**

## Performance

- **Duration:** 11m 30s
- **Started:** 2026-06-23T01:04:54Z
- **Completed:** 2026-06-23T01:16:24Z
- **Tasks:** 3
- **Files modified:** 10

## Accomplishments

- Added `PreviewDebugOverlayState` and `PreviewDebugOverlayView` for compact, redacted debug rows over the preview surface.
- Preserved `BeautyResult.warnings.count` in camera and photo snapshots, and mapped recoverable failures to `processing_paused` and `photo_decode_failed`.
- Wired `Show Debug Details` / `Hide Debug Details` beside compare and `Parameter JSON` without mutating compare, parameter, mode, category, subcategory, or processing state.
- Replaced old future-domain copy with concise `Not in v1` unavailable copy while preserving all category/subcategory order and disabled visibility.

## Task Commits

1. **Task 1 RED:** `2816d5d` test(07-02): add failing preview debug state coverage
2. **Task 1 GREEN:** `e9d0a4f` feat(07-02): add redacted preview debug state
3. **Task 2 RED:** `d9c29bd` test(07-02): add failing debug toolbar coverage
4. **Task 2 GREEN:** `53e600e` feat(07-02): wire read-only preview debug overlay
5. **Task 3 RED:** `5a11064` test(07-02): add failing unavailable state coverage
6. **Task 3 GREEN:** `1655977` feat(07-02): polish future category unavailable copy

## Files Created/Modified

- `BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayState.swift` - Debug visibility state plus redacted camera/photo debug row model.
- `BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayView.swift` - Compact SwiftUI overlay and empty-state copy.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - Preview toolbar debug button and overlay placement for camera/photo paths.
- `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` - Warning count preserved in camera snapshots.
- `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` - Warning count preserved in photo snapshots.
- `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` - Photo processing warning count sourced from `BeautyResult`.
- `BeautyDemo/BeautyDemo/Panel/BeautyCategoryModels.swift` - Final v1 unavailable copy.
- `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` - Debug row, recoverable error, and read-only preservation coverage.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Toolbar copy, empty overlay copy, and unavailable-state order/copy coverage.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Debug and unavailable-state privacy/static scans.

## Decisions Made

- Debug rows intentionally show warning counts only, not warning messages, because warnings can originate from internal effect/degradation paths.
- Camera idle returns no debug state; photo empty can produce a safe `photo empty` state, and the overlay view still owns the exact unavailable copy for nil state.
- Per the run instruction, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and `PLANS.md` were not updated by this plan.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The exact broad raw-token scan reports expected XCTest guard literals and pre-existing still-image `CGRect` usage in `ImageInputModels.swift` / test helpers. Scoped active-surface scans over the new debug overlay/state, camera pipeline, image editor pipeline, and panel files returned no matches.
- Xcode emitted a pre-existing actor-isolation warning in `BeautyResourcePickerModels.swift` and once reported a diagnostic collection warning for missing `simctl`; focused tests still executed and passed.
- `gsd-tools` was not on shell `PATH`; the local Node shim exists, but this run did not update GSD state files per user instruction.

## Verification

- PASS: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests`
- PASS: `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- PASS with expected guard matches: broad raw-token scan returned existing XCTest guard strings and pre-existing `CGRect` still-image model/test helper uses.
- PASS: scoped active debug/panel scan over `PreviewDebugOverlayState.swift`, `PreviewDebugOverlayView.swift`, `DetectionStatusPresentation.swift`, `CameraBeautyPipeline.swift`, `ImageEditorPipeline.swift`, and `BeautyDemo/BeautyDemo/Panel` returned no matches.
- PASS: `rg -n "Show Debug Details|Hide Debug Details|Debug details unavailable|Debug details are unavailable for this preview|Show Before|Show After" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` found expected copy.
- PASS: `git diff --check --` for all 07-02 touched production/test files returned no output.

## Known Stubs

None. Stub-pattern scan matched legitimate optional `nil` defaults, reset-to-nil state clearing, empty local arrays in tests, and continuation buffers only.

## Threat Flags

None. No new network endpoints, auth paths, file access paths, schema migrations, or SDK trust-boundary expansion were introduced.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for `07-03` final QA/readiness closeout. Remaining release-like risks stay manual: visual naturalness, real-device camera/Vision parity, long-run hardware behavior, and production render quality.

## Self-Check: PASSED

- Found created files: `BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayState.swift`, `BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayView.swift`.
- Found modified key files: `EditorShellView.swift`, `BeautyCategoryModels.swift`, `CompareStateTests.swift`, `BeautyDemoViewStateTests.swift`, `InputPipelinePrivacyTests.swift`.
- Found commits: `2816d5d`, `e9d0a4f`, `d9c29bd`, `53e600e`, `5a11064`, `1655977`.
- No unexpected tracked-file deletions in 07-02 commits.
- Summary created at `.planning/phases/07-rich-demo-qa-surface/07-02-SUMMARY.md`.

---
*Phase: 07-rich-demo-qa-surface*
*Completed: 2026-06-23*
