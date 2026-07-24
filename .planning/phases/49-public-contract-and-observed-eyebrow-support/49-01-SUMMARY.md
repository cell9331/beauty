---
phase: 49-public-contract-and-observed-eyebrow-support
plan: "01"
subsystem: detection-and-geometry-contracts
tags: [swift, vision, privacy, tdd, boundary-checker, fixtures]

requires:
  - phase: 45-public-contract-and-observed-face-support
    provides: fail-closed boundary checker and request-local observed-support patterns
provides:
  - Fail-closed Phase 49 checker with 42 deterministic adversarial self-tests
  - Package-only raw eyebrow side/envelope and internal semantic trace/support contracts
  - Compiled Vision preflight, canonicalization, lifecycle, and topology fixture matrices
affects: [49-02, 49-03, 49-04, 49-05, phase-50-eyebrow-geometry]

tech-stack:
  added: []
  patterns: [request-local immutable support, aggregate-only reflection, independent side absence, fail-closed fixture preflight]

key-files:
  created:
    - .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift

key-decisions:
  - "Keep raw eyebrow sides in a distinct package-only enum and independently optional envelope rather than reusing eye support."
  - "Expose only fixed side labels, booleans, and aggregate point counts through descriptions, reflection, and dump."
  - "Treat the missing e1.png fixture as an expected nonzero environment gate; never convert it into full-suite pass evidence."

patterns-established:
  - "Eyebrow support defaults nil on both BeautyFaceObservation and FaceGeometry, preserving all legacy initializer call sites."
  - "The Wave 0 canonicalization vocabulary enumerates 32 orientation/mirror/reversal rows per anatomical side."

requirements-completed: [SUPP-02, SUPP-03]

coverage:
  - id: D1
    description: "Fail-closed live, self-test, and exact e1.png fixture-preflight boundary checker"
    requirement: SUPP-03
    verification:
      - kind: other
        ref: "python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py --self-test"
        status: pass
    human_judgment: false
  - id: D2
    description: "Immutable package/internal raw and semantic eyebrow support with aggregate-only diagnostics"
    requirement: SUPP-03
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testEyebrowSupportContractsPreserveIndependentAbsenceAndPairedEligibility"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testEyebrowSupportDiagnosticsExposeOnlyCountsAndBooleans"
        status: pass
    human_judgment: false
  - id: D3
    description: "Compiled actual-region preflight, 64-row canonicalization, topology, lifecycle, and sibling-isolation fixture vocabulary"
    requirement: SUPP-02
    verification:
      - kind: unit
        ref: "swift test --package-path BeautySDK --filter BeautyDetectionTests"
        status: pass
      - kind: unit
        ref: "swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests"
        status: pass
    human_judgment: false

# Metrics
duration: 8 min
completed: 2026-07-24
status: complete
---

# Phase 49 Plan 01: Safeguards and Private Eyebrow Support Summary

**Fail-closed eyebrow boundary enforcement, request-local redacted support contracts, and exact compiled Wave 0 matrices for later capture and validation plans**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-24T07:32:35Z
- **Completed:** 2026-07-24T07:41:32Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments

- Created a fail-closed Phase 49 checker whose 42/42 deterministic self-tests cover subprocess classification, missing/escaping paths, manifest/Demo/resource/preset/artifact drift, public/Codable/persistence/network/model/import leaks, actual eyebrow provenance, synthetic/eye substitution, downstream activation, and fixture preflight.
- Added `BeautyObservedEyebrowSide`, `BeautyObservedEyebrowSupport`, `BeautyFaceObservation.observedEyebrowSupport`, `BeautyEyebrowSemanticTrace`, `BeautyEyebrowSemanticSupport`, and `FaceGeometry.observedEyebrowSupport` as immutable default-nil request-lifetime seams.
- Added exact 0/1/15/16/17 Vision preflight rows, disconnected/open/closed classification controls, 32 orientation × input-mirror × preview-mirror × reversal rows per side, 3/4/5/15/16/17 semantic rows, named malformed topology cases, repeated/alternating/interrupted/stale/no-face lifecycle fixtures, and eight parallel request identities.

## Task Commits

Each task was committed atomically:

1. **Task 49-01-01: Build the fail-closed eyebrow boundary checker** — `0324355` (RED), `472ea6e` (GREEN)
2. **Task 49-01-02: Define private raw and semantic eyebrow contracts** — `c8f2120` (RED), `ea301ab` (GREEN)
3. **Task 49-01-03: Add Wave 0 fixture builders and exact matrices** — `d8c9ab3`

## Files Created/Modified

- `.planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py` — classified fail-closed checker, adversarial fixtures, live gates, and exact fixture preflight.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` — package-only raw eyebrow side/envelope and redacted observation carrier.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` — internal semantic trace/support, paired eligibility, default-nil geometry seam, and redacted parent diagnostics.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` — actual Vision property-name, count/classification, lifecycle, and parallel identity fixtures.
- `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` — counting mapper and exact 64-row canonicalization matrix.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` — contract/privacy tests and exact semantic/topology/local-sibling fixtures.

## Decisions Made

- Used a brow-specific anatomical side enum instead of reusing eye-side identity, keeping source provenance and open-path semantics distinct.
- Kept both raw and derived carriers non-Codable and immutable, with explicit parent redaction so `dump` cannot traverse stored coordinate arrays.
- Kept the live checker intentionally deferred until Plans 49-02 through 49-04 add all required production markers; Wave 0 completion relies on checker self-tests and focused compiled suites.

## Verification

- Checker self-test: **42/42 passed**.
- `BeautyDetectionTests`: **52 executed, 2 opt-in Vision skips, 0 failures**.
- `BeautyFaceGeometryAdapterTests`: **36 executed, 1 opt-in Vision skip, 0 failures**.
- Fixture preflight: **expected nonzero failure** because `example-images/input/portraits/e1.png` is absent; full suite was not run or reported green.
- `git diff --check`: **passed**.

## Still-Enforced Prohibitions

- Eye contours, historical eye geometry, generated traces, and synthetic points cannot satisfy observed eyebrow provenance.
- No provider, resolver, facade, renderer/gallery, Demo/UI, row promotion, dependency, model, resource, network, persistence, or generated-evidence expansion is introduced.
- Coordinates, arrays, SIMD/CGPoint values, hashes, stable geometry signatures, and biometric/profile-like values remain absent from descriptions, reflection, dump, warnings, metrics, logs, and committed evidence.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The required local fixture `example-images/input/portraits/e1.png` is absent. The new preflight exits 1 with a fixed aggregate classification and does not run the full suite, exactly preserving the planned environment prerequisite.

## Known Stubs

None. Fixture rows are intentionally test-private Wave 0 vocabulary consumed by Plans 49-03 and 49-04; production capture/validation is explicitly downstream rather than stubbed behavior.

## Next Phase Readiness

- Plan 49-02 can add the exact neutral 59-field public model while the checker pins preset/scope boundaries.
- Plans 49-03 and 49-04 can consume the raw/semantic seams and compiled matrices for actual Vision mapping and open-path validation.
- The authorized `e1.png` fixture remains required before any later full-suite green claim.

## Self-Check: PASSED

- Created checker exists at the planned path.
- All five task/TDD commits exist in git history.
- All three task acceptance gates and plan-level focused verification commands passed.

---
*Phase: 49-public-contract-and-observed-eyebrow-support*
*Completed: 2026-07-24*
