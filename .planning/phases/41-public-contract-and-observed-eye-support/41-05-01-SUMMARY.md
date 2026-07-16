---
phase: 41-public-contract-and-observed-eye-support
plan: "05-01"
subsystem: observed-eye-support
tags: [swift, vision, coordinate-mapping, geometry-validation, boundary-tests]
requires:
  - phase: 41-public-contract-and-observed-eye-support
    provides: request-scoped mapped eye contours and fail-closed contour/pupil validation
provides:
  - Private image-normalized eye span and signed winding-independent tilt
  - Production-derived anatomical side-order result with orientation/mirror support
  - Pure threshold predicates and exhaustive EYE-06 boundary fixtures
affects: [phase-42-eye-geometry]
tech-stack:
  added: []
  patterns:
    - CoordinateMapper-derived anatomical axis for side-order validation
    - Package-internal pure predicates for exact threshold evidence
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
key-decisions:
  - "An explicit observed payload requires a detector-derived canonical side-order result; nil or invalid order fails closed in the adapter."
  - "Span is the raw image-normalized contour bounding span and tilt is signed atan2(inner.y-outer.y, abs(inner.x-outer.x))/(pi/2), bounded to [-1,1]."
  - "Pure validation predicates remain package-internal and are reused by composed validation so exact/inside/outside fixtures exercise production thresholds."
requirements-completed: [EYE-06]
coverage:
  - id: D1
    description: "Canonical span/tilt is deterministic across winding and signed tilt directions."
    requirement: EYE-06
    verification:
      - kind: unit
        ref: "BeautyFaceGeometryAdapterTests.testSpanAndSignedTiltAreWindingIndependentAndDeterministic"
        status: pass
    human_judgment: false
  - id: D2
    description: "Production Vision mapping derives anatomical side order across all orientations/mirror and rejects swapped or duplicate sides."
    requirement: EYE-06
    verification:
      - kind: integration
        ref: "FaceObservationMappingTests EYE-06 production-derived order matrix"
        status: pass
    human_judgment: false
  - id: D3
    description: "Locked contour, pupil, paired-ratio predicates and composed pupil degradation have exact boundary evidence."
    requirement: EYE-06
    verification:
      - kind: unit
        ref: "BeautyFaceGeometryAdapterTests.testLockedPurePredicatesCoverExactInsideAndOutsideBoundaries"
        status: pass
      - kind: unit
        ref: "swift test --package-path BeautySDK (291/291)"
        status: pass
    human_judgment: false
duration: 12min
completed: 2026-07-16
status: complete
---

# Phase 41 Plan 05-01: EYE-06 Semantic Support Summary

**Private eye support now carries deterministic span/tilt evidence, rejects side-inverted observations through the production mapping metadata, and executes the locked threshold matrix without exposing geometry.**

## Accomplishments

- Added package-internal `BeautyObservedEyeOrder` and detector-side anatomical order derivation. Exactly one left and right contour is required; mapped centroid separation must project positively onto the face-local horizontal basis transformed by `CoordinateMapper`, preserving `.up/.right/.left/.down` and input-mirrored labels.
- Added image-normalized `span` and signed bounded `tilt` to `BeautyEyeSemanticSupport`; canonical contour ordering, side-aware inner/outer selection, and repeated calls make the values independent of winding or cyclic point order.
- Extracted production-reused pure contour dimension/area, pupil containment/ellipse-offset, and paired-ratio predicates. Added exact, just-inside, and just-outside tests, side inversion/duplicate/missing fixtures, and pupil-local paired-ratio degradation evidence.
- Kept explicit observed payloads fail-closed when order is nil/invalid, while preserving the existing nil-observation legacy proxy compatibility path.

## Task Commits

1. **Task 41-05-01: Implement and exhaustively test EYE-06 gap closure** — `9f08f24`

## Verification

- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` — 13 tests passed.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` — 8 tests passed.
- `swift test --package-path BeautySDK` — 295 tests passed, 0 failures before the final boundary-matrix-only test commit; the focused 13-test adapter suite passes after that commit.
- `git diff --check` — passed before commit.

## Deviations from Plan

None. Plan scope stayed within private EYE-06 support, mapping, validation, and tests; no provider vectors, caps, resolver behavior, facade output, or Phase 42 implementation was added.

## Next Phase Readiness

Task 41-05-01 is complete. Task 41-05-02 still owns the Phase 41 validation ledger and DESIGN/SECURITY/PLANS synchronization; Phase 42 remains the owner of eye transforms and visual caps.

---
*Phase: 41-public-contract-and-observed-eye-support*
*Plan: 05-01*
*Completed: 2026-07-16*
