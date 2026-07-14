---
phase: 38-public-contract-and-lip-support-geometry
plan: "02"
subsystem: detection-geometry
tags: [swift, vision, lip-supports, geometry, privacy]

requires:
  - phase: 37-nose-safety-boundary-and-branch-closeout
    provides: Established private face-geometry adapter, availability, and fixture patterns
provides:
  - Independent package-only inner-lip availability without changing global required geometry
  - Default-empty private upper, lower, and inner lip support arrays
  - Deterministic availability-gated adapter proxies with exact legacy outer-lip preservation
  - Shared valid, missing, insufficient, duplicate, non-finite, reused, and stale support fixtures
affects: [38-03, 38-04, phase-39, phase-40]

tech-stack:
  added: []
  patterns: [optional coarse landmark availability, default-empty private geometry, availability-gated deterministic proxies]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift

key-decisions:
  - "Keep innerLips optional in the global required-geometry contract so outer-only faces remain usable."
  - "Preserve the existing eight outer-lip proxy points and their order exactly."
  - "Gate upper and lower supports on outer-lip availability while gating inner support independently on inner-lip availability."

patterns-established:
  - "Vision landmark regions cross into detection state only as coarse presence groups, never as raw points or framework payloads."
  - "New package-only geometry supports use default-empty initializer arguments for source compatibility and fail-closed consumers."

requirements-completed:
  - MOUTH-04

duration: 7min
completed: 2026-07-14
---

# Phase 38 Plan 02: Inner Availability and Explicit Lip Supports Summary

**Inner-lip availability is now independently recorded and converted with outer availability into deterministic private lip supports while legacy outer-lip geometry and global face usability remain unchanged.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-07-14T07:31:04Z
- **Completed:** 2026-07-14T07:37:44Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added package-only `.innerLips` presence mapping without adding it to `requiredGeometryGroups`; injected tests prove missing inner remains usable and selected while missing outer remains partial.
- Added default-empty `upperLips`, `lowerLips`, and `innerLips` arrays to `FaceGeometry` without changing older source-style construction.
- Added exact, deterministic, finite, normalized, face-bounded, duplicate-free support builders with upper/lower gated by outer availability and inner gated independently.
- Preserved the exact eight legacy outer-lip coordinates and order, and extended shared valid/malformed/freshness fixtures for the next provider and resolver plans.
- Passed the complete SwiftPM suite with 242 tests and no failures.

## Task Commits

Each task was committed atomically:

1. **Task 38-02-01: Record inner-lip availability without making it globally required** - `72a67b8` (feat)
2. **Task 38-02-02: Add deterministic default-empty upper/lower/inner supports and fixtures** - `bde861d` (feat)

**Plan metadata:** committed with this summary.

## Files Created/Modified

- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` - Adds optional package-only inner-lip availability while preserving the required group set.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` - Maps positive Vision inner-lip point count to coarse availability only.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` - Adds default-empty private upper, lower, and inner support storage.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` - Builds deterministic group-gated supports without changing the legacy outer proxy.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` - Locks optional-inner usability, required-outer failure, selection, and redaction behavior.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Locks exact adapter outputs, invariants, source compatibility, freshness forwarding, and malformed support fixtures.

## Decisions Made

- Independent inner availability is useful to local effects but is not a prerequisite for shipped whole-mouth behavior or face usability.
- Upper and lower proxy supports intentionally reuse stable outer-surface locations; the inner proxy uses a distinct nondegenerate six-point opening.
- Support data remains package-internal and diagnostics remain coarse, preserving the raw-landmark privacy boundary.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 38-03 can consume explicit whole, upper, lower, and inner support seams with named valid and malformed fixtures.
- Provider vectors, resolver degradation, facade output, final cap calibration, exhaustive safety, and promotion remain deliberately unclaimed.

## Self-Check: PASSED

- All six implementation/test files exist and the Plan 38-02 diff contains exactly those files.
- Task commits `72a67b8` and `bde861d` exist and are atomic.
- `VisionFaceDetectorTests` passed 10/10, `FaceShapeWarpProviderTests` passed 12/12, and the full SwiftPM suite passed 242/242.
- Required-set, exact outer-proxy, structural/default-array, public/SPI privacy, scope, stub, and diff-hygiene scans pass.

---
*Phase: 38-public-contract-and-lip-support-geometry*
*Completed: 2026-07-14*
