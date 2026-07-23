---
phase: 45-public-contract-and-observed-face-support
plan: "03"
subsystem: detection-mapping
tags: [swift, vision, face-contour, coordinate-mapping, privacy, tdd]

requires:
  - phase: 45-public-contract-and-observed-face-support
    provides: Plan 45-01 package-only observed face envelope and fixed region ceilings
provides:
  - actual Vision faceContour and medianLine capture in the existing landmarks request
  - bounded independent face-region mapping through one request-local CoordinateMapper
  - reversal-only canonical paths across orientation and input mirroring
  - consecutive and parallel request-lifecycle isolation with aggregate-only fixture evidence
affects: [45-04, 45-05, phase-46-face-providers]

tech-stack:
  added: []
  patterns:
    - preflight untrusted optional regions before bounded point mapping
    - derive semantic path axes through the same mapper metadata used for points
    - preserve open-path adjacency through whole-array reversal only

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
    - PLANS.md

key-decisions:
  - "Keep actual contour and median capture in the single existing VNDetectFaceLandmarksRequest and copy only CoordinatePoint values out of Vision regions."
  - "Preflight contour and median independently at 32-point and 16-point ceilings, preserving a valid sibling and selected face when one optional region fails."
  - "Canonicalize with mapper-derived face-local right/down axes and whole-array reversal only; never sort or infer anatomical labels."

patterns-established:
  - "Observed face mapping: validate shared bounds once, preflight each optional raw region, map accepted points once, and retain an envelope only when at least one region survives."
  - "Canonical open paths: project last-minus-first onto mapped right/down axes, reject projection magnitude at or below 0.000001, and otherwise retain or reverse the entire array."

requirements-completed: [SUPP-01, SUPP-02, SUPP-04]

duration: 11 min
completed: 2026-07-23
---

# Phase 45 Plan 03: Actual Vision Face-Support Mapping Summary

**Actual Vision contour and median evidence now crosses one bounded request-local mapper with region-local failure isolation and adjacency-preserving canonical direction across all supported orientation/mirror metadata**

## Performance

- **Duration:** 11 min
- **Started:** 2026-07-23T05:07:17Z
- **Completed:** 2026-07-23T05:18:58Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Extended `VisionDetectionObservation` with a defaulted package-only face-support carrier, and copied actual `VNFaceLandmarks2D.faceContour` / `medianLine` points immediately from the existing single landmarks request.
- Added independent non-empty, finite, closed-unit, maximum-count preflight before mapping. Accepted face-local points are composed with the shared Vision bounds and mapped exactly once; malformed contour and median failures remain local.
- Derived face-local right and down axes through the same call-local mapper and canonicalized only by whole-array reversal. Forward/reversed inputs converge without sorting or adjacency loss.
- Locked all eight orientation/input-mirror combinations, preview-mirror invariance, exact 0/1 edges, just-outside/non-finite/oversized/degenerate rejection, consecutive opposite metadata, and eight-way parallel detector isolation.
- Evaluated all six committed portrait fixtures through aggregate availability/count assertions only, with no coordinate, bounds, sample, framework-object, or region-description output.

## Task Commits

Each TDD task was committed through RED then GREEN:

1. **Task 45-03-01: Capture and map actual face contour and median line once**
   - `bcdca6a` — RED: failing independent capture, mapping, malformed-region, lifecycle, and aggregate fixture tests
   - `923c37b` — GREEN: actual Vision region copy plus bounded request-local mapping
2. **Task 45-03-02: Lock canonical direction across winding, orientation, and mirroring**
   - `6d09143` — RED: failing 4×2 metadata, reversal, adjacency, edge, degeneracy, and isolation matrix
   - `aec982b` — GREEN: mapper-axis direction projection and whole-array reversal

No separate refactor commit was needed; the GREEN implementation remained focused in the existing detector seam.

## Files Created/Modified

- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` — defaulted injected/source carrier, actual Vision face-region copy, independent bounded mapping, and canonical direction helpers.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` — exact injected mapping, contour/median isolation, oversize/malformed/shared-bounds behavior, one-provider-call lifecycle, and six-fixture aggregate evidence.
- `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` — forward/reverse 4×2 matrix, adjacency, preview invariance, exact edges, invalid/degenerate isolation, sequential state, and parallel payload isolation.
- `PLANS.md` — repository execution ledger and verification evidence.

## Verification

- `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` — **PASS, 15/15**.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` — **PASS, 18/18** with Apple Vision host access.
- Focused total — **PASS, 33/33**.
- `swift test --package-path BeautySDK` — **PASS, 338/338** with Apple framework host access.
- Orientation/input-mirror matrix — **PASS, 8/8 metadata combinations**, each for forward and reversed contour plus median paths.
- Parallel isolation matrix — **PASS, 8/8 independently sized request payloads**.
- Static scope checks — exactly one `VNDetectFaceLandmarksRequest`, no sort, cache, persistence, network, logging, public/Codable surface, dependency, target, model, resource, renderer, facade, or Demo addition.
- `git diff --check dc56e13..HEAD` — **PASS**.

## Decisions Made

- Kept shared-bounds invalidity at the existing whole-observation `.mappingFailed` boundary, while optional contour/median input and mapping errors degrade only the affected region.
- Treated face contour and median direction as face-local basis semantics transformed by `CoordinateMapper`, not final image X/Y assumptions or anatomical labels.
- Collapsed an empty mapped envelope to nil, but preserved an explicit envelope whenever either valid sibling survives.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The restricted sandbox could compile and pass all injected mapping tests but denied Apple Vision host services, causing the two default-provider cases to report `detectorUnavailable`. Re-running the exact focused suite outside the sandbox passed 18/18; the full outside-sandbox SwiftPM suite passed 338/338.

## Known Stubs

None. Adapter topology validation and provider consumption are intentionally owned by Plans 45-04 and Phase 46 rather than stubbed here.

## Threat Flags

None. Oversized/malformed input, canonical inversion, raw data disclosure, repeated mapping/retention, and alternate detector/model paths are all registered in the plan threat model and directly mitigated by implementation/tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 45-04 can consume independently mapped canonical contour/median evidence at the adapter trust boundary without reopening Vision acquisition or orientation semantics.
- Plan 45-05 can run the live privacy/scope checker and synchronize current-owner contracts.
- No provider, resolver, facade, renderer, cap, output, row-promotion, Demo, device, commercial, packaging, shipping, or launch-readiness claim is made.

## Self-Check: PASSED

- The three plan-owned implementation/test artifacts and this summary exist.
- RED/GREEN commits `bcdca6a`, `923c37b`, `6d09143`, and `aec982b` exist in repository history in the required order.
- Focused suites pass 33/33, the full SwiftPM suite passes 338/338, the eight-combination metadata matrix and eight-way parallel isolation matrix pass, and diff hygiene is clean.

---
*Phase: 45-public-contract-and-observed-face-support*
*Completed: 2026-07-23*
