---
phase: 91-independent-gaze-correction
plan: "01"
implementation_attempt: 1
subsystem: geometry
tags: [swift, gaze-correction, request-local-anatomy, fixed-point-evidence]
requires:
  - phase: 89-semantic-validation-baseline
    provides: Frozen gaze semantic thresholds and the requirement for independently owned pupil-to-own-eye anatomy
  - phase: 41-public-eye-contract
    provides: Request-local observed eye contour and pupil validation
provides:
  - Independent per-eye gaze-pupil eligibility without changing paired pupil-size compatibility
  - Deterministic zero/one/two-side gaze selection with no legacy or peer fallback
  - Strict simple-aperture source/target containment and frozen half-clearance radius
  - Six-field aggregate primitive reconciled to exact final admitted gaze points
affects: [91-02-final-gaze-metrics, 91-03-renderer-comparator-binding, EYE-01]
tech-stack:
  added: []
  patterns: [field-specific semantic eligibility, closed-polygon admission, aggregate-only final-state evidence]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift
key-decisions:
  - "Preserve BeautyEyeSemanticSupport.pupil as the paired pupil-size channel and store the locally validated gaze pupil separately."
  - "Admit gaze points only when source and target are strictly inside one finite simple closed aperture, with radius min(5% face width, half the smaller clearance)."
  - "Count correction only when an exact expected gaze point survives final admission; publish no per-eye or geometry payload."
patterns-established:
  - "Gaze-specific selection: stable anatomical left-then-right compact-map over independently eligible observed supports, never legacy support."
  - "Final-admission evidence: exact point matching with one-to-one consumption prevents summed improvement or duplicate evidence from hiding rejection."
requirements-completed: [EYE-01]
duration: 10min
completed: 2026-09-05
---

# Phase 91 Plan 01: Independent Gaze Geometry Summary

**Per-eye request-local gaze support now produces deterministic own-center control points bounded by each eye aperture, with paired pupil-size compatibility intact and only aggregate final-admission evidence exposed.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-09-04T22:34:56Z
- **Completed:** 2026-09-04T22:44:29Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Split the target-internal pupil representation so pair-ratio failure can continue clearing both `pupilSize` channels while each locally valid gaze pupil remains independently eligible.
- Replaced gaze's bilateral/common selector and fixed face-width radius with stable zero/one/two-side observed selection, strict simple-polygon admission, source/target containment, and the frozen `0.5` clearance factor.
- Replaced summed gaze evidence with six aggregate fields: eligible/corrected/rejected counts, all-reduced, abstained, and bounded minimum-reduction Q16, reconciled against exact final admitted points.

## Task Commits

Each TDD task was committed as a failing-test gate followed by its implementation:

1. **Task 1 RED: independent adapter eligibility mutations** — `d856b92`
2. **Task 1 GREEN: split paired and gaze pupil channels** — `949d6a5`
3. **Task 2 RED: aperture, cardinality, and aggregate mutations** — `c05e2c1`
4. **Task 2 GREEN: bounded gaze field and aggregate implementation** — `f07845d`

## Exact Behavior Evidence

- Adapter focused gate: 48 tests executed, 46 passed, 2 existing opt-in Vision tests skipped, 0 failures.
- Combined provider/adapter gate: 68 tests executed, 66 passed, 2 existing opt-in Vision tests skipped, 0 failures; `git diff --check` passed.
- Gaze cardinality is deterministically `0/1/2` for zero/one/two independently eligible observed sides, in anatomical left-then-right order. Equal side geometry remains two distinct candidates and never merges.
- A missing, nil, multiple, nonfinite, outside, ellipse-invalid, ratio-implausible, degenerate, self-intersecting, boundary-touching, or outside-target side fails locally while a valid peer remains active.
- Displacement `0.002` is neutral and the next representable `Float` value is active. At strength `0.25`, movement is exactly 35% toward that pupil's own center; half strength is monotone and over-cap input has the same target as the cap.
- Every admitted radius is finite and positive and is no greater than `min(faceWidth * 0.05, sourceClearance * 0.5, targetClearance * 0.5)`.
- Paired pupil-size behavior is unchanged: the existing peer width/height ratio failure still clears both `pupil` values while independent gaze eligibility survives on each locally valid side.

## Aggregate Allowlist

`GazeCorrectionAggregateEvidence` contains exactly:

- `eligibleEyeCount`
- `correctedEyeCount`
- `rejectedEyeCount`
- `allReduced`
- `abstained`
- `minimumReductionQ16`

It carries no side label, pupil/contour coordinate, source/target point, radius, mask, pixel, locator, path, or transcript. Full credit requires a nonempty exact one-to-one admission, every eligible eye corrected, zero rejection, and a checked Q16 value in `1...65536`; otherwise minimum Q16 is zero.

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` — separate internal paired pupil and gaze-pupil channels with a source-compatible initializer.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` — pass locally validated pupil separately from pair-compatible pupil result.
- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` — independent gaze selector, frozen sample law, strict aperture/clearance admission, and exact final-admission aggregate.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` — peer mutation, ratio compatibility, cardinality, ordering, and recovery coverage.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` — dead-zone/cap, own-center, zero/one/two-side, equality, clearance, topology, boundary, and hidden-regression aggregate coverage.

## Decisions Made

- Kept all non-gaze eye fields on the existing `semanticSupports(in:)` path; only positive gaze uses the new observed-only selector.
- Bypassed the generic minimum-radius clamp for gaze because a `0.035` lower clamp can exceed the eye aperture; the gaze point is constructed only after the stricter frozen clearance proof.
- Used exact `WarpControlPoint` equality with one-to-one removal when reconciling final admissions, so duplicates cannot count twice and a target/radius/strength mutation cannot earn correction credit.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Test defect] Separated exact threshold proof from floating-point coordinate cancellation**
- **Found during:** Task 2 GREEN verification
- **Issue:** Constructing `center + Float(0.002)` near normalized coordinate `0.4` subtracts back as `0.002000004`, so the original test row did not actually exercise the exact `0.002` value.
- **Fix:** Added and used the pure internal displacement predicate for exact `0.002` and `.nextUp` checks, while keeping the existing rendered sample just-above row at `0.002001`.
- **Files modified:** `EyeWarpProvider.swift`, `EyeWarpProviderTests.swift`
- **Verification:** Combined 68-test focused command passed with the literal threshold unchanged.
- **Committed in:** `f07845d`

---

**Total deviations:** 1 auto-fixed bug in test construction.
**Impact on plan:** No threshold, radius factor, peer ownership, public surface, or acceptance boundary changed.

## Issues Encountered

- The exact-threshold fixture initially encoded a slightly larger displacement after Float subtraction; resolved as documented above without altering production constants.

## Security and Scope

- HIGH threats T-91-01 through T-91-03 are mitigated by observed-side ownership, strict aperture admission, target-internal non-Codable geometry, and aggregate-only evidence. T-91-04 malformed arithmetic/topology cases fail closed without traps.
- No raw/per-side anatomy is serialized, logged, diagnosed, or persisted.
- No public symbol, parameter, preset, renderer case, product inventory, UI/Demo path, network/model/data/weight path, backend, or retained `Warp.metal` source changed.
- This is generated/package-host mechanics evidence only. It does not run authorized portraits or establish Phase-95 publication, device, naturalness, population, commercial, packaging, shipping, launch, release, or distribution readiness.

## Known Stubs

None.

## User Setup Required

None - no external service, package, model, fixture, or credential is required.

## Next Phase Readiness

- Plan 91-02 can call the aggregate helper after final conflict resolution with the exact final gaze strength and `finalEyeEmissions.gazeCorrection`.
- No implementation blocker remains for the generated public-facade pixel oracle or the later renderer/comparator binding.

## Self-Check: PASSED

- All five declared source/test files and this summary exist.
- Commits `d856b92`, `949d6a5`, `c05e2c1`, and `f07845d` exist in repository history.
- The summary contains exactly one `implementation_attempt: 1` line and `git diff --check` passes.

---
*Phase: 91-independent-gaze-correction*
*Completed: 2026-09-05*
