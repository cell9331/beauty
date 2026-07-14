---
phase: 04-detection-and-coordinate-safety
plan: 04-04
subsystem: demo-pipeline
tags: [swiftui, beautydemo, metadata, detection-status, privacy]
requires:
  - phase: 04-01
    provides: BeautyInputMetadata, BeautyResult detectionSummary, and public detection summaries.
  - phase: 04-02
    provides: Safe detection availability and reason contracts.
  - phase: 04-03
    provides: Internal coordinate safety and mapping failure reasons.
provides:
  - CameraPreviewFrame and Demo snapshots carrying public BeautyInputMetadata.
  - Camera and photo processors consuming BeautyEngine.processResult overloads.
  - DetectionStatusPresentation, DetectionDebugSummary, and DetectionStatusDebouncer.
  - Demo tests for camera/photo metadata, no-face/partial/low-confidence/stale status, and privacy-safe debug output.
affects: [BeautyDemo, Phase 04 final verification, Phase 07 QA surface]
tech-stack:
  added: []
  patterns: [public-facade metadata flow, result-backed demo snapshots, fixed detection status copy, debug-safe summary values]
key-files:
  created:
    - BeautyDemo/BeautyDemo/Editor/DetectionStatusPresentation.swift
  modified:
    - BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift
    - BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift
    - BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift
    - BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift
    - BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift
    - BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift
    - BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift
    - BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift
key-decisions:
  - "Camera defaults are source .camera, orientation .right, input not mirrored, and preview mirrored."
  - "Photo metadata uses source .photo, no input mirroring, no preview mirroring, and no path-like identifier in public metadata."
  - "Demo status continues through the existing statusText surface while debug summaries remain fixed privacy-safe values."
patterns-established:
  - "CameraFrameProcessor and StillImageProcessor now return BeautyResult-backed outputs."
  - "DetectionStatusDebouncer holds camera detection status for three processed frames before clearing or replacing it."
requirements-completed: [PIPE-05, PIPE-07]
duration: 41 min
completed: 2026-06-18
---

# Phase 04 Plan 04-04: Demo Metadata Flow and Safe Detection Status Summary

**Demo camera and photo pipelines now carry public metadata and show safe nonblocking detection status/debug summaries**

## Performance

- **Duration:** 41 min
- **Started:** 2026-06-18T07:26:53Z
- **Completed:** 2026-06-18T08:07:51Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- Added `BeautyInputMetadata` to camera frames and camera/photo processing snapshots using only the public `BeautySDK` facade.
- Updated camera and still-image processors to consume `BeautyEngine.processResult(...)` and retain `detectionSummary` with processed output.
- Preserved existing preview output and failure continuity behavior for camera and photo paths.
- Added fixed status copy for no-face, partial, low-confidence, and stale detection states.
- Added privacy-safe debug summaries exposing only availability, reason codes, counts, and timings.
- Added camera debounce tests and photo status persistence tests.

## Task Commits

Each task was committed atomically:

1. **Task 1: Propagate metadata through camera and photo processing** - `ae1e320` (`feat(04-04): propagate demo metadata`)
2. **Task 2: Add safe detection status and debug summaries** - `9ab3ca0` (`feat(04-04): add safe detection status`)

**Plan metadata:** this summary commit.

## Files Created/Modified

- `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` - Camera frame metadata with source, orientation, input mirroring, preview mirroring, and timestamp.
- `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` - Result-backed camera snapshots and debounced detection status.
- `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` - Photo input/snapshot metadata and loaded-state detection status/debug accessors.
- `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` - Result-backed still-image processing through metadata-aware SDK APIs.
- `BeautyDemo/BeautyDemo/Editor/DetectionStatusPresentation.swift` - Fixed status copy, debug summary, and camera debouncer values.
- `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` - Camera metadata defaults.
- `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` - Metadata propagation, result summaries, and debounce coverage.
- `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` - Photo metadata and status persistence coverage.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Detection status/debug privacy and UI-SPEC copy coverage.

## Decisions Made

- Existing `orientation` and `timestamp` properties remain computed accessors so older Demo code and tests stay source-compatible.
- `DetectionStatusPresentation` returns no normal status for `.notRun`, `.disabled`, `.usable`, `.skipped`, or `.reused`; those states are not blocking user workflow.
- Camera status debouncing is implemented in the pipeline state layer, not the SwiftUI view layer, so tests can verify behavior without UI timing.

## Deviations from Plan

None - plan executed as written.

## Issues Encountered

- The 04-04-02 xcodebuild verification was manually interrupted once and rerun from a clean process check. The rerun completed successfully.

## Verification

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraSessionControllerTests -only-testing:BeautyDemoTests/CameraBeautyPipelineTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` passed with 14 targeted tests.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests test` passed with 19 targeted tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

04-05 can perform root contract/documentation updates, privacy scans, and final Phase 4 verification. Demo now carries metadata and safe detection summaries but still does not add overlay boxes, landmark points, coordinate readouts, or per-face controls.

---
*Phase: 04-detection-and-coordinate-safety*
*Completed: 2026-06-18*
