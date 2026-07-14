---
phase: 04-detection-and-coordinate-safety
plan: 04-02
subsystem: sdk-detection
tags: [swift, beautysdk, vision, face-selection, detection-summary]
requires:
  - phase: 04-01
    provides: Public BeautyInputMetadata and geometry-free BeautyDetectionSummary contracts.
provides:
  - Internal BeautyFaceObservation and BeautyFaceLandmarks models.
  - FaceSelectionPolicy with deterministic largest-face ordering, stable-ID tie behavior, and maximumFaceCount support.
  - Internal VisionFaceDetector with deterministic injectable observation provider.
  - BeautyDetectionTests target covering selection, detector degradation, and availability summaries.
affects: [BeautyDetection, BeautyCore, Phase 04 coordinate mapping, Phase 04 Demo metadata propagation]
tech-stack:
  added: []
  patterns: [internal detection models, injectable Vision adapter, geometry-free degradation summaries, deterministic face selection]
key-files:
  created:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceSelectionPolicyTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/DetectionAvailabilityTests.swift
  modified:
    - BeautySDK/Package.swift
key-decisions:
  - "Face selection remains internal to BeautyDetection and exposes only faceCount, usedFaceCount, and reason codes through BeautyDetectionSummary."
  - "VisionFaceDetector uses an injectable observation provider for deterministic tests; the default provider establishes the Vision boundary and degrades safely until real frame input is wired."
patterns-established:
  - "Selection state is lifecycle-local and resettable through FaceSelectionPolicy and VisionFaceDetector."
  - "Recoverable detector failures map to .skipped summaries with structured detectorUnavailable or detectionTimedOut reasons."
requirements-completed: [PIPE-07]
duration: 11 min
completed: 2026-06-18
---

# Phase 04 Plan 04-02: Detection Models and Vision Adapter Summary

**Internal face selection and injectable Vision detection seams with geometry-free public degradation summaries**

## Performance

- **Duration:** 11 min
- **Started:** 2026-06-18T06:58:30Z
- **Completed:** 2026-06-18T07:09:30Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Added `BeautyDetectionTests` as a SwiftPM test target depending on `BeautyCore` and `BeautyDetection`.
- Added internal face observation and landmark availability models that do not cross the public `BeautySDK` facade.
- Implemented `FaceSelectionPolicy` with largest-face ordering, 0.05 normalized-area stable-ID tie behavior, `maximumFaceCount`, `faceLimitApplied`, and reset semantics.
- Added `VisionFaceDetector` with deterministic injected observations for no-face, low-confidence, partial, usable, and recoverable failure states.
- Covered public detection availability states without exposing Vision objects, bounding boxes, landmark coordinates, raw errors, or file paths.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add internal face models and deterministic selection policy** - `6268464` (`feat(04-02): add face selection policy`)
2. **Task 2: Add Vision detector adapter with injectable fixture seams** - `044ad96` (`feat(04-02): add injectable Vision detector`)

**Plan metadata:** this summary commit.

## Files Created/Modified

- `BeautySDK/Package.swift` - Adds `BeautyDetectionTests`.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` - Internal face observation and coarse landmark availability model.
- `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift` - Deterministic face selection and summary count/reason generation.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` - Internal Vision-boundary detector adapter with injectable observation provider.
- `BeautySDK/Tests/BeautyDetectionTests/FaceSelectionPolicyTests.swift` - Face budget, stable-ID tie, reset, and `faceLimitApplied` coverage.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` - Deterministic no-face, partial, low-confidence, usable, and failure coverage.
- `BeautySDK/Tests/BeautyDetectionTests/DetectionAvailabilityTests.swift` - Public detection availability state coverage and count clamping.

## Decisions Made

- `VisionFaceDetector` is internal and intentionally not exported through `BeautySDK`.
- Detector failures use `DetectionAvailability.skipped` plus structured reasons, rather than surfacing raw Vision errors or throwing for recoverable degradation states.
- Low-confidence detections and missing required landmark groups produce safe summaries with `usedFaceCount == 0`.
- The default Vision provider creates the Vision request boundary and degrades with `detectorUnavailable`; real image/request execution remains for later integration work.

## Deviations from Plan

None - plan executed as written.

## Issues Encountered

None.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter FaceSelectionPolicyTests` passed with 4 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter VisionFaceDetectorTests` passed with 6 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter DetectionAvailabilityTests` passed with 2 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 42 tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

04-03 can build canonical coordinate mapping on top of internal `BeautyFaceObservation` values and public `BeautyInputMetadata`. Detection is still not wired into `BeautyEngine`; later Phase 4 plans own coordinate mapping and Demo propagation.

---
*Phase: 04-detection-and-coordinate-safety*
*Completed: 2026-06-18*
