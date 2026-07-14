---
phase: 04-detection-and-coordinate-safety
plan: 04-01
subsystem: sdk-core
tags: [swift, beautysdk, metadata, detection-summary, result-api]
requires:
  - phase: 03-realtime-and-still-input-slice
    provides: Camera and Photo input paths that call the public BeautySDK facade.
provides:
  - Public BeautyInputMetadata and BeautyInputSource contracts.
  - Public geometry-free BeautyDetectionSummary, DetectionAvailability, and DetectionDegradationReason contracts.
  - BeautyResult detectionSummary metadata.
  - Metadata-aware BeautyEngine result overloads for CVPixelBuffer and CIImage.
affects: [BeautyCore, BeautySDK, BeautyDemo, Phase 04 detection, Phase 04 coordinate mapping]
tech-stack:
  added: []
  patterns: [additive public API overloads, geometry-free public detection summaries, SwiftPM XCTest facade checks]
key-files:
  created:
    - BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyInputMetadataTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyResultDetectionSummaryTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift
    - BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift
    - BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift
key-decisions:
  - "BeautyResult now supports non-Sendable output types through unchecked Sendable conformance so BeautyResult<CVPixelBuffer> can compile under Swift 6."
  - "Initial detection summaries are .disabled when face tracking is off and .notRun until detector execution is wired in later plans."
patterns-established:
  - "Old output-only BeautyEngine APIs delegate through default non-mirrored BeautyInputMetadata."
  - "Public detection metadata contains only availability, reason codes, counts, and optional timings."
requirements-completed: [PIPE-05, PIPE-07]
duration: 24 min
completed: 2026-06-18
---

# Phase 04 Plan 04-01: Public Metadata and Result Contracts Summary

**Public input metadata and geometry-free detection summaries with metadata-aware BeautyEngine result overloads**

## Performance

- **Duration:** 24 min
- **Started:** 2026-06-18T06:33:00Z
- **Completed:** 2026-06-18T06:57:08Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Added public `BeautyInputMetadata` and `BeautyInputSource` for orientation, input mirroring, preview mirroring, source, and timestamp.
- Added public `BeautyDetectionSummary`, `DetectionAvailability`, and `DetectionDegradationReason` without exposing geometry, Vision objects, raw errors, or paths.
- Extended `BeautyResult` with optional `detectionSummary` while preserving `BeautyResult(output:)` source compatibility.
- Added `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` and `processResult(image:metadata:parameters:)`, with old orientation-only APIs delegating through default non-mirrored metadata.
- Verified the full SwiftPM package test suite after the API changes.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add public metadata and detection summary values** - `19a11fd` (`feat(04-01): add public detection metadata contracts`)
2. **Task 2: Add metadata-aware BeautyEngine result overloads** - `b27367b` (`feat(04-01): add metadata-aware engine results`)

**Plan metadata:** this summary commit.

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift` - Public input metadata and source enum.
- `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` - Public availability, reason, count, and timing summary model.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` - Optional detection summary and unchecked Sendable result envelope.
- `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` - Metadata-aware result overloads and old API delegation.
- `BeautySDK/Tests/BeautyCoreTests/BeautyInputMetadataTests.swift` - Codable, Sendable, and enum case coverage.
- `BeautySDK/Tests/BeautyCoreTests/BeautyResultDetectionSummaryTests.swift` - Geometry-free summary and source-compatible result coverage.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift` - Old/new API compatibility and initial summary states.
- `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift` - Public facade visibility for new SDK contracts.

## Decisions Made

- `BeautyInputMetadata` encodes `CGImagePropertyOrientation` by raw value for stable Codable round-trips.
- `BeautyDetectionSummary` clamps negative face counts and caps `usedFaceCount` at `faceCount`.
- `BeautyResult<Output>` dropped its `Output: Sendable` generic constraint and uses unchecked Sendable conformance because Swift 6 marks `CVPixelBuffer` as non-Sendable, while Phase 4 requires `BeautyResult<CVPixelBuffer>`.
- Detection execution is not run in this plan; result metadata intentionally reports `.notRun` or `.disabled`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Adjusted BeautyResult Sendable contract for CVPixelBuffer**
- **Found during:** Task 2 (Add metadata-aware BeautyEngine result overloads)
- **Issue:** Swift 6 rejected `BeautyResult<CVPixelBuffer>` because `CVPixelBuffer` is explicitly non-Sendable.
- **Fix:** Removed the `Output: Sendable` generic constraint and made `BeautyResult` an unchecked Sendable envelope.
- **Files modified:** `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`
- **Verification:** `swift test --package-path BeautySDK --filter BeautyEngineMetadataCompatibilityTests` and full `swift test --package-path BeautySDK` passed.
- **Committed in:** `b27367b`

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Required to satisfy the planned `BeautyResult<CVPixelBuffer>` API under Swift 6. No scope expansion.

## Issues Encountered

- SwiftPM initially failed under the filesystem sandbox because manifest compilation attempted to write under `~/.cache/clang/ModuleCache`. Verification was rerun with `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache`, matching the repository's existing SwiftPM verification pattern.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyInputMetadataTests` passed with 2 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyResultDetectionSummaryTests` passed with 4 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautySDKFacadeTests` passed with 2 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineMetadataCompatibilityTests` passed with 4 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests` passed with 4 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 30 tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

04-02 can build internal detection models, face selection, and Vision adapter seams on top of the public metadata/result contracts. `BeautyEngine` currently returns `.notRun` or `.disabled`; later plans own detector execution and coordinate mapping.

---
*Phase: 04-detection-and-coordinate-safety*
*Completed: 2026-06-18*
