---
phase: 27-geometry-render-output-and-verification-harness
plan: "01"
subsystem: detection
tags: [vision, still-image, geometry, redaction, facade]
requires:
  - phase: 26-geometry-facade-and-landmark-routing-foundation
    provides: public still-image geometry gating and package-only selected-face routing
provides:
  - Package-only CIImage-backed Vision still-image detection input seam.
  - Public-facade fixture probe for Phase 27 face-shape geometry parameters.
  - Redacted no-face, usable-face, and facade metadata tests for real fixture detection.
affects: [phase-27, phase-28, geometry-render-output]
tech-stack:
  added: []
  patterns: [package-only Vision input seam, public-facade fixture probe]
key-files:
  created:
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-01-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
key-decisions:
  - "Kept the new Vision input seam package-only and retained the metadata-only detect overload for compatibility."
  - "Threaded the still image through the existing public still-image facade route instead of adding any public raw geometry API."
patterns-established:
  - "Real fixture probes iterate existing e1 through e5 inputs and pass when at least one fixture produces usable redacted detection."
  - "Detection evidence is asserted through public summaries, warning codes, reason codes, and aggregate metrics only."
requirements-completed: [GEO-03, GEO-04]
duration: 15 min
completed: 2026-07-07
---

# Phase 27 Plan 01: Real Still-Image Detection Input Seam Summary

**CIImage-backed Vision detection now feeds the public still-image facade path while preserving redacted detection summaries.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-07-07T06:48:00Z
- **Completed:** 2026-07-07T07:03:42Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Added package-only `VisionFaceDetectionInput` with optional still-image data and an image-aware `VisionFaceDetector.detect(...)` overload.
- Implemented default still-image detection with `VNDetectFaceLandmarksRequest`, mapping only confidence, normalized bounds for internal mapping, and landmark-group availability.
- Added focused tests proving CIImage no-face degradation, usable real portrait fixture detection, public-facade fixture probing, and redacted metadata.

## Task Commits

1. **Task 27-01-01: Add the still-image Vision input seam for real fixture detection** - `2355587` (feat)
2. **Task 27-01-02: Prove existing portrait fixtures are tried through the public facade** - `cd21ba3` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` - Adds package-only detection input, image-aware detect overload, and CIImage-backed Vision mapping.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Passes the still image into geometry detection from the existing public still-image facade.
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` - Accepts optional still-image data and forwards it to detection.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` - Covers default no-face and usable real fixture detection with redacted summaries.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` - Covers real public-facade fixture probing and redacted metadata for the Phase 27 face-shape combination.

## Decisions Made

- Kept the old metadata-only detection overload so existing SPI fixture tests and compatibility paths continue to work.
- Used existing `example-images/input/e1.png` through `e5.png` as the real-facade portrait probe instead of adding a fallback verifier in this plan.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Threaded CIImage through `BeautyEngine.swift`**
- **Found during:** Task 27-01-01
- **Issue:** The plan required the public facade to try real still-image detection, but the declared file list omitted the still-image facade call site that must pass the `CIImage`.
- **Fix:** Updated `BeautyEngine.processResult(image:metadata:parameters:)` to pass the existing image into `resolveStillImageGeometry(...)`.
- **Files modified:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`
- **Verification:** `BeautyEngineGeometryFacadeTests/testExistingExampleImageFixtureProducesUsableFaceForGeometryCase` passes through default `BeautyEngine(configuration: .default)`.
- **Committed in:** `2355587`

---

**Total deviations:** 1 auto-fixed (1 missing critical).
**Impact on plan:** The change is necessary for the planned real-facade proof path and does not expand public API, Demo behavior, or raw geometry exposure.

## Issues Encountered

None.

## Verification

- `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` passed with 8 tests.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 6 tests.
- Public/SPI raw geometry export scan over `BeautySDK/Sources/BeautySDK`, `BeautySDK/Sources/BeautyDetection`, and `BeautySDK/Sources/BeautyEffects` returned no matches.
- `git diff --check` passed for the Plan 27-01 source and test files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 27-02 to carry the selected-face observation into still-image rendering and prove geometry output differs from a no-geometry baseline.

---
*Phase: 27-geometry-render-output-and-verification-harness*
*Completed: 2026-07-07*
