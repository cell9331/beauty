---
phase: 53-canonical-still-image-contract-and-private-request-foundatio
plan: "03"
subsystem: still-image-detection
tags: [swift, vision, face-landmarks, request-local-support, privacy]
requires:
  - phase: 53-02
    provides: one canonical request-owned still raster and fail-before-Vision input boundary
provides:
  - package-only immutable actual outer/inner lip support
  - independent fixed-bound preflight and one-mapper conversion per accepted lip region
  - aggregate-only lip diagnostics and request-value isolation evidence
affects: [53-04, 53-05, 53-06, 54, 55, 56, still-image, local-retouch]
tech-stack:
  added: []
  patterns: [actual Vision provenance, per-region fail-closed mapping, aggregate-only private support]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PLANS.md
key-decisions:
  - "Actual outer and inner lip support extends the existing Detection observation values in place; no second Vision request, mapper, target, or proxy is introduced."
  - "Each lip region independently accepts 1...32 finite closed-unit samples before one mapping pass, so malformed sibling support cannot erase valid evidence or the selected face."
  - "Diagnostics expose only outer/inner counts; raw support remains package-only, immutable, non-Codable, request-local, and absent from public/SPI surfaces."
patterns-established:
  - "Lip provenance: copy Vision outerLips/innerLips once, preflight independently, map accepted arrays once."
  - "Lip failure isolation: empty or malformed support becomes nil only for that region."
requirements-completed: [PATH-04]
coverage:
  - id: D1
    description: Actual outer and inner Vision lip regions flow through the existing single request and mapper into private request-local support
    requirement: PATH-04
    verification:
      - kind: unit
        ref: "swift test --package-path BeautySDK --filter 'StillImageRequestSupportTests|VisionFaceDetectorTests|FaceObservationMappingTests'"
        status: pass
      - kind: other
        ref: "rg -n 'VNDetectFaceLandmarksRequest' BeautySDK/Sources"
        status: pass
    human_judgment: false
  - id: D2
    description: Lip regions preflight and fail independently while valid siblings, selected-face order, and request values remain intact
    requirement: PATH-04
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift#boundary/empty/precision/malformed-sibling/order/recovery/parallel-value cases"
        status: pass
    human_judgment: false
  - id: D3
    description: Observed lip diagnostics reveal aggregate counts only and add no public/SPI raw geometry or candidate route
    requirement: PATH-04
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift#testDescriptionsDebugDumpsAndMirrorsExposeCountsOnly"
        status: pass
      - kind: other
        ref: "public/SPI/Codable and candidate-route source scans"
        status: pass
    human_judgment: false
duration: 9min
completed: 2026-07-30
status: complete
---

# Phase 53 Plan 03: Actual Request-Local Lip Support Summary

**Actual Vision outer/inner lip samples now share the existing selected-face request and mapper with independent preflight, local failure, and aggregate-only diagnostics**

## Performance

- **Duration:** 9 min
- **Started:** 2026-07-30T09:35:24Z
- **Completed:** 2026-07-30T09:43:58Z
- **Tasks:** 1
- **Files modified:** 8

## Accomplishments

- Added package-only immutable non-Codable `BeautyObservedLipSupport` to the existing Vision and mapped face observations without adding a target, dependency, request, mapper, provider, renderer route, public/SPI geometry, or stored engine state.
- Copied actual `outerLips` and `innerLips` samples from the existing `VNDetectFaceLandmarksRequest`, preflighted each region independently at 1...32 finite closed-unit points, and mapped each accepted array once through the existing `CoordinateMapper`.
- Proved empty, oversized, non-finite, out-of-unit, and malformed-sibling behavior; selected-face tie order, valid-invalid-valid recovery, and independent detector values stay intact while diagnostics expose counts only.
- Preserved synthesized legacy mouth geometry and all candidate, API, renderer, realtime/pixel-buffer, concurrency/cancellation, device, performance, commercial, packaging, and release nonclaims.

## Task Commits

Each task was committed atomically:

1. **Task 1: Capture and map actual lip support in the existing Vision request** - `09111a7` (feat)

## Files Created/Modified

- `BeautyFaceObservation.swift` - Package-only lip carrier plus aggregate-only mapped-observation diagnostics.
- `VisionFaceDetector.swift` - Fixed lip preflight, independent mapper attachment, and actual Vision outer/inner extraction through the existing request.
- `StillImageRequestSupportTests.swift` - Production-backed PATH04 boundary, empty, precision, sibling-isolation, ordering, recovery, privacy, and independent-value coverage.
- `VisionFaceDetectorTests.swift` - Updated diagnostic aggregate contracts for the appended lip counts.
- `DESIGN.md` - D-09 through D-12/D-17 ownership and mapping design.
- `SECURITY.md` - T-53-04/T-53-05 privacy, validation, and no-new-surface mitigations.
- `RELIABILITY.md` - Per-region degradation, recovery, request isolation, and concurrency nonclaim.
- `PLANS.md` - Wave 2 implementation and command-backed boundary evidence.

## Decisions Made

- Extended `VisionDetectionObservation` and `BeautyFaceObservation` in place because they already own the single selected-face mapping boundary; a separate lip request or carrier target would violate D-17.
- Kept outer and inner support as independent optionals and made invalid shared face bounds degrade lip support locally, while global coordinate-mapper failure retains the existing observation-level behavior.
- Kept `PATH04-CONCURRENCY` flagged under TD-013. Independent detector values are proven; same-engine concurrency and cooperative cancellation are not claimed.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- SwiftPM's nested manifest sandbox returned `sandbox_apply: Operation not permitted`; the required focused command was rerun outside that nested sandbox with the repository's established `/private/tmp/beauty-clang-module-cache` convention and passed.
- Three pre-existing opt-in live Vision smoke tests skipped because `BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS` was not enabled. They are not used for the T-53-04/T-53-05 mitigations; all Plan 53-03 boundary, privacy, isolation, and mapping tests ran and passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 53-04 can assemble one selected-face private request context from the canonical raster and this actual lip support while leaving inactive and pixel-buffer paths at zero local work.
- Phase 56 can later consume honest lip provenance only if its independent evidence gate admits teeth whitening; no candidate is admitted by this plan.
- Same-engine concurrency/cancellation, live Vision fixture evidence, transparent/HDR input, realtime, device performance, commercial naturalness, packaging, and release readiness remain explicitly outside this result.

## Self-Check: PASSED

- `BeautyFaceObservation.swift` and `VisionFaceDetector.swift` exist and contain `BeautyObservedLipSupport`, `LipRegionPreflight`, and `observedLipSupport` wiring.
- Task commit `09111a7` exists in history and contains no tracked file deletions.
- Focused Detection verification passed 61 tests with zero failures; the three skipped cases are pre-existing opt-in live Vision smokes and are not Plan 53-03 HIGH mitigations.
- Production source contains exactly one `VNDetectFaceLandmarksRequest` occurrence.
- Source scans find no public/SPI/Codable lip carrier, candidate field, provider, renderer route, second request, synthetic lip proxy, or realtime/pixel-buffer activation.
- `git diff --check` passed.

---
*Phase: 53-canonical-still-image-contract-and-private-request-foundatio*
*Completed: 2026-07-30*
