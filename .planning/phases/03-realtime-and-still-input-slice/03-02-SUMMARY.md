---
phase: "03-realtime-and-still-input-slice"
plan: "03-02"
subsystem: "ui"
tags: ["swiftui", "avfoundation", "beautysdk", "pixel-buffer", "backpressure", "xctest"]
requires:
  - phase: "03-01"
    provides: "CameraPreviewFrame, CameraSessionController, live preview card, and enabled Camera mode"
provides:
  - "Demo-owned bounded realtime camera pipeline"
  - "Direct public BeautySDK pixel-buffer processing path with no UIImage conversion"
  - "Backpressure accounting with latest pending frame replacement"
  - "Camera processing snapshots for later compare display"
  - "Friendly recoverable camera processing status copy"
affects: ["03-03", "03-04", "camera", "compare", "pipeline"]
tech-stack:
  added: []
  patterns: ["main-actor UI state with off-main serial processing", "bounded in-flight frame processing", "friendly error/status mapping"]
key-files:
  created:
    - "BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift"
    - "BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift"
  modified:
    - "BeautyDemo/BeautyDemo/Editor/EditorShellView.swift"
    - "BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift"
key-decisions:
  - "Realtime camera processing uses the public BeautySDK facade and the pixel-buffer API only."
  - "The pipeline keeps one active frame by default and replaces pending work with the newest frame when busy."
  - "PIPE-06 remains pending for 03-03; 03-02 only provides camera input/output snapshots needed by shared compare."
patterns-established:
  - "Camera processing state preserves the last usable snapshot on recoverable failure."
  - "SwiftUI receives status state on the main actor while synchronous SDK work runs on a serial queue."
requirements-completed: ["PIPE-02", "PIPE-03"]
duration: "12min"
completed: "2026-06-12"
---

# Plan 03-02 Summary

**Realtime camera frames now flow through the public BeautySDK pixel-buffer API with bounded freshness-first backpressure.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-06-12T15:27:00+0800
- **Completed:** 2026-06-12T15:39:04+0800
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- Added `CameraBeautyPipeline` with an injectable `CameraFrameProcessor` and default `BeautyEngine.process(pixelBuffer:orientation:parameters:)` processor.
- Bounded realtime work to one active frame by default; when busy, the pipeline keeps only the newest pending frame and records `.backpressure` drops.
- Captured immutable camera input/output snapshots containing pixel buffers, orientation, timestamp, extent, and the parameter snapshot used for processing.
- Wired `EditorShellView` camera frame callbacks to the pipeline using `BeautyParameterStore.parametersSnapshot` for each handoff.
- Added preview-card status text for recoverable camera processing failures using `Processing paused. Showing the last usable preview.`.
- Added deterministic XCTest coverage for pixel-buffer invocation, in-flight bounds, stale frame replacement, latest parameter snapshots, and friendly status mapping.

## Task Commits

1. **Wave 0, bounded pipeline, and editor wiring** - `f083041` (feat)

The tests and implementation were committed together because the new pipeline type, editor wiring, and view-state copy compile as one connected seam.

## Files Created/Modified

- `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` - Demo-owned realtime processor, processing snapshots, state, backpressure, and friendly status mapping.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - Connects camera frames to the pipeline and shows status inside the existing preview card.
- `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` - Verifies direct CVPixelBuffer processing, in-flight bounds, stale drops, latest parameters, and friendly recoverable status.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Verifies camera processing status copy remains friendly.

## Decisions Made

No SDK internals were imported or changed. Demo uses only `BeautySDK` and the public `BeautyEngine` pixel-buffer method.

`PIPE-06` was not marked complete here because 03-03 owns the shared before/after compare toggle. 03-02 provides the camera-side snapshot pair that 03-03 can consume.

## Deviations from Plan

`CameraPreviewModels.swift` and `CameraSessionController.swift` did not need changes after 03-01; the new pipeline could consume the existing `CameraPreviewFrame` and session callback directly.

## Issues Encountered

The first compile surfaced a pattern-match type error and a Swift concurrency warning around capturing `Result<CVPixelBuffer, Error>`. The implementation was adjusted to use explicit snapshot matching and a small `CameraProcessingResult` value.

Two additional MainActor-isolation warnings came from the project default isolation applying to pure processor helper types. Those helpers were made `nonisolated`, and the final focused test run passed.

## Verification

- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test`
- `rg -n "UIImage" BeautyDemo/BeautyDemo/Camera BeautySDK/Sources`
- `rg -n "import Beauty(Core|Render|Detection|Effects|Resources)" BeautyDemo BeautyDemo/BeautyDemoTests`
- `rg -n "Processing paused\\. Showing the last usable preview\\." BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests`
- `git diff --check -- BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor/EditorShellView.swift BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift`

Result: focused XCTest passed with 13 tests. The `UIImage` and internal SDK import scans returned no matches. The required friendly processing copy was present in source and tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

03-03 can use `CameraProcessingSnapshot` as the camera-side before/after pair while adding Photo input, still-image processing, and the shared compare state that closes PIPE-06.

---
*Phase: 03-realtime-and-still-input-slice*
*Completed: 2026-06-12*
