---
phase: 04-detection-and-coordinate-safety
plan: 04-03
subsystem: sdk-detection
tags: [swift, beautysdk, coordinates, mirroring, vision, mapping]
requires:
  - phase: 04-01
    provides: BeautyInputMetadata and public detection summary/reason contracts.
  - phase: 04-02
    provides: Internal face observations, selection policy, and injectable Vision detector.
provides:
  - Internal CoordinateSpace enum for visionNormalized, imageNormalized, imagePixel, textureUV, preview, and mirroredPreview.
  - CoordinateMapper with orientation, input mirroring, preview mirroring, extent validation, and typed mapping errors.
  - VisionFaceDetector observation mapping from Vision-style bounds to internal image-normalized bounds.
  - Mapping failure degradation through DetectionDegradationReason.mappingFailed.
affects: [BeautyDetection, Phase 04 Demo metadata propagation, Phase 06 face-dependent effects]
tech-stack:
  added: []
  patterns: [canonical image-normalized coordinate model, explicit mapper spaces, mapping failure degradation, internal geometry only]
key-files:
  created:
    - BeautySDK/Sources/BeautyDetection/CoordinateSpace.swift
    - BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift
    - BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
key-decisions:
  - "ImageNormalized is the internal top-left canonical coordinate model; VisionNormalized is flipped and orientation/input-mirror adjusted before selection."
  - "Preview mirroring only affects Preview/MirroredPreview conversion and does not mutate SDK input interpretation."
  - "Mapped bounds remain internal to BeautyDetection and never appear in BeautyCore or BeautySDK public result types."
patterns-established:
  - "CoordinateMapper requires explicit source and destination spaces plus image/preview extents."
  - "Detector mapping failures reset selection state and return .partial summaries with mappingFailed."
requirements-completed: [PIPE-05, PIPE-07]
duration: 17 min
completed: 2026-06-18
---

# Phase 04 Plan 04-03: Coordinate Spaces and Mirroring Mappers Summary

**Canonical image-normalized coordinate mapping with separate input and preview mirroring plus safe detector mapping failure metadata**

## Performance

- **Duration:** 17 min
- **Started:** 2026-06-18T07:09:30Z
- **Completed:** 2026-06-18T07:26:53Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added internal `CoordinateSpace`, `CoordinatePoint`, and `CoordinateRect` values inside `BeautyDetection`.
- Implemented `CoordinateMapper` conversions from VisionNormalized to ImageNormalized and from ImageNormalized to ImagePixel, TextureUV, Preview, and MirroredPreview.
- Covered `.up`, `.right`, `.left`, `.down`, input mirroring, preview mirroring, invalid extents, and Vision rect/point conversion in tests.
- Extended internal face observations with optional image-normalized bounds while preserving public geometry privacy.
- Wired `VisionFaceDetector` to map Vision-style observation bounds before selection and return `mappingFailed` summaries for mapper errors.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add coordinate spaces and mapper matrix tests** - `2ecde40` (`feat(04-03): add coordinate mapper`)
2. **Task 2: Normalize detector observations through the mapper** - `80cb400` (`feat(04-03): map detector observations`)

**Plan metadata:** this summary commit.

## Files Created/Modified

- `BeautySDK/Sources/BeautyDetection/CoordinateSpace.swift` - Internal coordinate spaces and point/rect values.
- `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` - Explicit coordinate conversion utility and mapping errors.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` - Internal optional image-normalized bounds.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` - Vision-style bounds mapping and `mappingFailed` degradation.
- `BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift` - Coordinate matrix, mirroring, preview, texture, and invalid extent coverage.
- `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` - Detector observation mapping and failure degradation coverage.

## Decisions Made

- `TextureUV` currently matches image-normalized top-left values because the SDK render path has not introduced a different shader UV convention yet.
- `mirroredPreview` applies `isPreviewMirrored`; plain `preview` does not, so input interpretation and preview display remain separate.
- Unsupported reverse conversion to VisionNormalized is rejected by mapper error instead of adding unneeded inverse transforms.

## Deviations from Plan

None - plan executed as written.

## Issues Encountered

None.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter CoordinateMapperTests` passed with 9 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter FaceObservationMappingTests` passed with 4 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter VisionFaceDetectorTests` passed with 6 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 55 tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

04-04 can propagate `BeautyInputMetadata` and `BeautyDetectionSummary` through Demo camera/photo snapshots and status models. The SDK now has internal geometry and mapper failure handling, but `BeautyEngine` still reports `.notRun` until Demo/detector integration is wired.

---
*Phase: 04-detection-and-coordinate-safety*
*Completed: 2026-06-18*
