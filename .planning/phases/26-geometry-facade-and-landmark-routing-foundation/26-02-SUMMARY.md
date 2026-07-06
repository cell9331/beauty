---
phase: 26-geometry-facade-and-landmark-routing-foundation
plan: "02"
subsystem: sdk-facade-geometry-detection
tags: [swift, beautysdk, beautydetection, spi-testing, geometry-routing]
requires:
  - phase: 26-01
    provides: Package-internal selected-face resolver route
provides:
  - Still-image geometry detection gate in BeautyEngine.processResult(image:metadata:parameters:)
  - SPI-only deterministic face-detection fixtures for facade tests
  - Redacted public facade evidence for usable, no-face, low-confidence, missing-landmark, and detector-failure states
affects: [BeautySDK, BeautyDetection, Phase 26 Plan 03]
tech-stack:
  added: []
  patterns:
    - SPI fixture API exposes detector state names and invocation counts only
    - public still-image facade gates detection on geometry-triggering parameters
key-files:
  created:
    - BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
  modified:
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift
key-decisions:
  - "Routed only still-image processResult through geometry detection in Phase 26; pixel-buffer behavior remains unchanged."
  - "Testing SPI accepts fixture states through BeautySDK without exposing VisionDetectionObservation, BeautyFaceObservation, FaceGeometry, bounds, or landmarks."
patterns-established:
  - "Validate image extent and resources before detection, then detect only for geometry-triggering parameters."
  - "Detector failures and unusable faces degrade to BeautyDetectionSummary reason codes while resolver skips face-dependent domains."
requirements-completed: [GEO-01, GEO-02]
duration: 29 min
completed: 2026-07-06
---

# Phase 26 Plan 02: Still-Image Facade Geometry Detection Summary

**Public still-image processing now detects only for geometry-triggering parameters and routes one selected face into the internal resolver path.**

## Performance

- **Duration:** 29 min
- **Started:** 2026-07-06T04:08:00Z
- **Completed:** 2026-07-06T04:37:20Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Promoted the narrow Vision detector seam to `package` access so `BeautySDK` can call it while public APIs remain unchanged.
- Added `BeautyEngineGeometryDetection.swift` to gate still-image detection on `BeautyEffectResolver.requiresFaceGeometry(parameters:)`.
- Added SPI-only `SDKTestingFaceDetectionFixture` and `SDKTestingFaceDetectionProvider` for deterministic facade tests through `@_spi(Testing) import BeautySDK`.
- Updated `BeautyEngine.processResult(image:metadata:parameters:)` so no-op/color/filter/basic-skin paths preserve `.notRun`, disabled tracking preserves `.disabled`, and geometry-triggering requests degrade safely when detection is unusable.
- Added facade tests for usable selected-face routing, detector-call counts, disabled tracking, no-face, low-confidence, missing-landmark, detector-unavailable, timeout, and redacted public evidence.

## Task Commits

1. **Task 26-02-01: Add the SPI-only facade detector seam** - `3308a67` (`feat(26-02): route still-image geometry detection`)
2. **Task 26-02-02: Gate still-image detection and route selected faces through BeautyEngine** - `3a15fbc` (`test(26-02): cover facade geometry routing`)

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 4 tests.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` passed with 6 tests.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineMetadataCompatibilityTests` passed with 4 tests.
- `rg -n "public .*VisionDetectionObservation|public .*VisionFaceDetector|public .*BeautyFaceObservation|@_spi\(Testing\).*VisionDetectionObservation|@_spi\(Testing\).*BeautyFaceObservation|@_spi\(Testing\).*FaceGeometry" BeautySDK/Sources/BeautySDK BeautySDK/Sources/BeautyDetection; test $? -eq 1` passed with zero matches.
- `rg -n "VNFaceObservation|boundingBox|controlPoint|/private/var|NSError|AVError|rawPresetJson|raw JSON|image bytes|SIMD|landmarks=|landmarkCoordinates|rawLandmark" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK; test $? -eq 1` passed with zero matches.
- `git diff --check` passed for the Wave 2 source and test files.

## Files Created/Modified

- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` - Still-image geometry detection gate and resolver routing helper.
- `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` - SPI-only deterministic detector fixtures and counted provider.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Face detector ownership, still-image route integration, and reset tracking reset.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` - Package access for the facade-owned detector seam.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` - Public facade geometry activation/degradation/redaction tests.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift` - Compatibility test name updated for current no-geometry behavior.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The new routing helper initially could not read `initialDetectionSummary` while it was `private`; the property was reduced to module-internal access without adding public API.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plans 26-01 and 26-02 now provide command-backed code/test evidence for `26-03`: public still-image detection activation, selected-face resolver routing, safe degradation, no-geometry compatibility, disabled tracking compatibility, and raw-geometry export protection.

---
*Phase: 26-geometry-facade-and-landmark-routing-foundation*
*Completed: 2026-07-06*
