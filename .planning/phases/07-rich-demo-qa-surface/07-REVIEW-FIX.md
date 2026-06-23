---
phase: 07-rich-demo-qa-surface
source_review: .planning/phases/07-rich-demo-qa-surface/07-REVIEW.md
fixed_at: 2026-06-23T01:44:09Z
status: fixed
fix_commits:
  - 609f869
  - 9c1fe27
findings_fixed:
  critical: 4
  warning: 1
  info: 0
  total: 5
---

# Phase 07 Code Review Fix Report

Fixed the three findings from the standard Phase 07 code review.

## Fixes

### Round 1

1. **CR-01: Stale photo completion idle handling**
   - Updated `ImageEditorPipeline.finish(_:, result:)` so stale completions still run the idle-continuation resume check.
   - Added `ImageEditorPipelineTests.testD14StalePhotoCompletionDoesNotBlockIdleWaitForLatestWork`.

2. **CR-02: Same photo retry after slow load/failure**
   - Moved `selectedPhotoItem = nil` before the async `PhotosPickerItem.loadTransferable` task in `EditorShellView.handlePhotoSelection(_:)`.
   - Added `InputPipelinePrivacyTests.testDEMO07PhotoPickerSelectionClearsBeforeAsyncLoadForRetry` as a source-order regression guard.

3. **WR-01: Imported no-filter intensity display**
   - Normalized imported/preset display state so `filterIntensity` displays `0` whenever `filterId` is `nil`.
   - Added `BeautyParameterStoreTests.testDEMO06ApplyingImportedParametersWithoutFilterClearsVisibleIntensity`.

### Round 2

4. **CR-01: Stale PhotosPicker async loads**
   - Added `PhotoSelectionGeneration` to ignore older `PhotosPickerItem.loadTransferable` success/failure completions after a newer photo selection starts.
   - Kept immediate `selectedPhotoItem` clearing for same-item retry.
   - Added `InputPipelinePrivacyTests.testDEMO07PhotoPickerSelectionIgnoresStaleAsyncLoads`.

5. **CR-02: Stale parameter JSON preview candidate**
   - Added `previewedImportText` tracking so Apply is enabled only when visible pasted text still matches the text that produced the preview candidate.
   - Editing the import `TextEditor` resets preview state and disables Apply until the edited text is previewed again.
   - Added `BeautyDemoViewStateTests.testDEMO06ApplyIsUnavailableUntilPreviewCandidateExists` coverage for stale-preview disablement.

## Verification

- PASS: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests`
- PASS: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests`
- PASS: `git diff --check -- BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift BeautyDemo/BeautyDemo/Editor/EditorShellView.swift BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests`

## Notes

XcodeBuildMCP was checked first, but its environment could not locate `xcrun`, `simctl`, or `xcodebuild`; verification used the repository's explicit shell command with `DEVELOPER_DIR`.
