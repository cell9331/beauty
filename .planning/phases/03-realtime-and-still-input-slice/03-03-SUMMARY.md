---
phase: "03-realtime-and-still-input-slice"
plan: "03-03"
subsystem: "ui"
tags: ["swiftui", "photosui", "coreimage", "beautysdk", "compare", "xctest"]
requires:
  - phase: "03-01"
    provides: "Enabled Photo mode and local-first photo purpose string"
  - phase: "03-02"
    provides: "CameraProcessingSnapshot for camera-side compare"
provides:
  - "PhotosUI user path for local still-image selection"
  - "Deterministic fixture input path for tests and previews"
  - "Demo-owned still-image pipeline through BeautyEngine.process(image:orientation:parameters:)"
  - "Photo loading, cancellation, stale-result, and friendly failure states"
  - "Shared display-only CompareState for Camera and Photo before/after selection"
affects: ["03-04", "photo-input", "compare", "privacy", "pipeline"]
tech-stack:
  added: ["PhotosUI", "CoreImage"]
  patterns: ["fixture and PhotosUI inputs share one pipeline", "generation-based stale result ignore", "display-only compare state"]
key-files:
  created:
    - "BeautyDemo/BeautyDemo/Editor/CompareState.swift"
    - "BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift"
    - "BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift"
    - "BeautyDemo/BeautyDemoTests/CompareStateTests.swift"
    - "BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift"
  modified:
    - "BeautyDemo/BeautyDemo/Editor/EditorShellView.swift"
    - "BeautyDemo/BeautyDemo/Support/DemoFixtures.swift"
    - "BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift"
key-decisions:
  - "PhotosUI is the user-facing picker; fixture input is reserved for deterministic tests and previews."
  - "CompareState is display-only and does not mutate mode, category, subcategory, parameters, crop, or orientation."
  - "Photo decode and process failures use the same friendly UI-SPEC copy and preserve previous visuals."
patterns-established:
  - "Still-image processing uses generation tokens to ignore stale async work."
  - "Photo preview states stay inside the existing preview card and keep editor controls visible."
requirements-completed: ["PIPE-04", "PIPE-06"]
duration: "35min"
completed: "2026-06-12"
---

# Plan 03-03 Summary

**Photo mode now selects local images through PhotosUI, processes them through BeautySDK, and shares a before/after compare state with Camera.**

## Performance

- **Duration:** 35 min
- **Started:** 2026-06-12T15:40:30+0800
- **Completed:** 2026-06-12T16:15:36+0800
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Added `ImageInputSource`, `PhotoProcessingState`, and `ImageProcessingSnapshot` for fixture, PhotosUI-loaded, cancellation, loading, loaded, and failed still-image states.
- Added `ImageEditorPipeline` that decodes/loads input off the UI path, calls `BeautyEngine.process(image:orientation:parameters:)`, renders displayable `CGImage` values, and ignores stale generations.
- Added `CompareState` for shared Camera/Photo before-after display selection with `Show After` and `Show Before` labels.
- Wired `EditorShellView` to `PhotosPicker`, Photo loading/failure/loaded preview states, replacement selection, and shared compare controls.
- Added deterministic XCTest coverage for fixture input, PhotosUI data seam, cancellation no-op, decode failure preservation, loading overlay behavior, stale photo work, and compare preservation.

## Task Commits

1. **Wave 0, still-image pipeline, and compare UI** - `97194eb` (feat)

Tests and implementation were committed together because the view-state tests reference the new Photo and compare models directly.

## Files Created/Modified

- `BeautyDemo/BeautyDemo/Editor/CompareState.swift` - Display-only before/after state for Camera and Photo.
- `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` - Photo input, processing snapshot, and processing state models.
- `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` - Demo-owned still-image SDK pipeline with stale-result handling.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - PhotosPicker user path, Photo preview states, and compare controls.
- `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` - Deterministic CIImage fixture for tests/previews.
- `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` - Compare labels, Camera/Photo selection, and editor-state preservation tests.
- `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` - Still-image pipeline and failure/loading/stale tests.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Photo and compare copy assertions.

## Decisions Made

Still-image selection uses `PhotosPicker` and `PhotosPickerItem.loadTransferable(type: Data.self)` for the real user path. Tests use injected decoder/processor seams and fixture input to avoid photo-library automation.

The Photo pipeline uses `CIImage` and `CGImage` for still-image display. Realtime Camera remains free of `UIImage`; no internal SDK target imports were introduced.

## Deviations from Plan

None. Scope stayed within Photo input, still-image processing, compare state, preview-card UI, fixtures, and focused tests.

## Issues Encountered

The first test compile hit default MainActor isolation on pure test helpers. The helpers were marked `nonisolated`, and the focused XCTest run passed.

## Verification

- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/ImageEditorPipelineTests -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test`
- `rg -n "PhotosPicker|Choose Photo|Show After|Show Before|Processing photo\\.\\.\\.|Could not read that photo\\. Choose another image\\." BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests`
- `rg -n "import Beauty(Core|Render|Detection|Effects|Resources)" BeautyDemo BeautyDemo/BeautyDemoTests`
- `git diff --check -- BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/Support/DemoFixtures.swift BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift BeautyDemo/BeautyDemoTests/CompareStateTests.swift BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift`

Result: focused XCTest passed with 20 tests. The UI copy/PhotosPicker scan found the required strings. The internal SDK import scan returned no matches.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

03-04 can audit and document the completed Camera/Photo input slice, local-first boundaries, purpose strings, no-internal-import rule, and remaining manual UAT for real camera/photo picker round trips.

---
*Phase: 03-realtime-and-still-input-slice*
*Completed: 2026-06-12*
