---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
plan: "07"
subsystem: sclera-safety
tags: [sclera, adversarial-safety, containment-envelope, contour-validation, per-eye-recovery]
requires:
  - phase: 64-06
    provides: bilateral full-resolution protected truth and request-local proposal evidence
provides:
  - exact historical right-eye leak regression with a frozen 3x3x3 calibrated boundary
  - production pupil-center plausibility guard that rejects the leaking tuple locally
  - inclusive scale-bounded contour validity with bilateral sequential and parallel recovery proof
affects: [64-08, 64-09, 64-10, 64-11, 65]
tech-stack:
  added: []
  patterns: [literal-counterexample-regression, monotone-containment-envelope, inclusive-segment-validity, per-eye-fail-closed]
key-files:
  created:
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-07-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift
key-decisions:
  - "The literal right-eye +0.004 center / -0.006 pupil / +0.003 skew tuple is locally rejected by a 0.025 normalized horizontal pupil-center plausibility limit; the smaller +0.003/-0.005 neighborhood remains safely accepted."
  - "Contour admission treats proper crossings, collinear overlap, on-segment points, endpoint touches, zero-length edges, and adjacent retraces as invalid while allowing only the intended adjacent shared endpoint."
  - "Intersection tolerances derive from contour extent and remain capped, so near-collinear separated contours stay deterministic without widening actual-overlap acceptance."
patterns-established:
  - "Known adversarial geometry is frozen as literal values plus an explicit ordered outcome table, never retuned to implementation behavior."
  - "Malformed contour admission fails closed before rasterization for only the affected eye, with stateless sequential and concurrent recovery."
requirements-completed: [SCLERA-14, SCLERA-15]
coverage:
  - id: D9-D10
    description: "The exact historical tuple and all 27 neighboring combinations execute through independent protected truth and final byte checks."
    verification:
      - kind: test
        ref: "BeautyScleraRednessAdversarialCloseoutTests 6/6"
        status: pass
      - kind: other
        ref: "Frozen boundary: 3 accepted, 24 locally rejected; exact tuple locally rejected"
        status: pass
    human_judgment: false
  - id: D12
    description: "Every local rejection retains a nonempty peer and valid-invalid-valid plus parallel requests recover without stale work."
    verification:
      - kind: test
        ref: "BeautyScleraRednessProviderTests 15/15 and BeautyEngineScleraRednessIntegrationTests 9/9"
        status: pass
    human_judgment: false
  - id: D16
    description: "The production containment and contour-validation changes supersede earlier review authority without editing review or promotion artifacts."
    verification:
      - kind: other
        ref: "Only provider and focused test owners changed before this summary"
        status: pass
    human_judgment: false
duration: 15min
completed: 2026-08-09
status: complete
---

# Phase 64 Plan 07: Historical Leak Containment and Inclusive Contour Safety Summary

**The exact asymmetric right-eye leak now fails closed inside a frozen accepted/rejected boundary, and inclusive contour admission rejects every touching, overlapping, retraced, or degenerate edge before rasterization.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-08-09T06:43:05Z
- **Completed:** 2026-08-09T06:57:53Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Restored the literal historical right-eye tuple at center `+0.004`, pupil `-0.006`, and skew `+0.003`, plus an explicitly ordered 3x3x3 neighborhood with three safe accepted samples and 24 local rejections.
- Added a production 0.025 normalized horizontal pupil-center plausibility limit. The exact leaking tuple emits no right-eye unit while the unchanged left peer remains active; the smaller accepted boundary retains nonempty proposals and exact protected/outside RGBA bytes.
- Replaced strict-crossing-only contour checks with inclusive proper-crossing, on-segment, collinear-overlap, endpoint-touch, zero-length, adjacent-retrace, and closure-overlap rejection using bounded scale-aware tolerances.
- Proved both-eye local failure, intended adjacent endpoint acceptance, near-collinear separated acceptance, valid-invalid-valid recovery, and 24 concurrent independent valid/invalid invocations.

## Task Commits

Each TDD task was committed at its RED and GREEN gates:

1. **Task 1 RED: Restore exact historical tuple and calibrated boundary regression** — `54937b0`
2. **Task 1 GREEN: Fail closed around the historical leak** — `7308d77`
3. **Task 2 RED: Add inclusive contour validity and recovery regressions** — `006a081`
4. **Task 2 GREEN: Enforce inclusive contour validity** — `8e54feb`

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift` — adds the narrow pupil-center plausibility guard and inclusive, precision-bounded contour validation.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift` — freezes the exact historical tuple, all 27 ordered boundary outcomes, monotonicity, peer continuation, protected intersection, and final-byte identity.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift` — covers inclusive contact/overlap and degeneracy classes across both eyes, valid controls, and sequential/parallel recovery.
- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-07-SUMMARY.md` — records execution evidence and the serial handoff.

## Decisions Made

- Rejected the historical tuple at the production geometry boundary instead of weakening the fixture, protected truth, colors, transform, or perturbation magnitudes.
- Kept three `center=0.003/pupil=-0.005` samples accepted across all skew values, proving the calibrated envelope is not an all-reject shortcut.
- Allowed adjacent edges to share exactly their intended vertex; any additional contact or overlap is invalid, including the first-last closure pair.
- Kept all new validation before score/rasterization and local to one eye. Guard-before-score, feather-then-hard-reclip, original-source composition, and aggregate-only diagnostics remain unchanged.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Verification Evidence

- `BeautyScleraRednessProviderTests`: 15/15 passed.
- `BeautyScleraRednessAdversarialCloseoutTests`: 6/6 passed.
- `BeautyEngineScleraRednessIntegrationTests`: 9/9 passed.
- Frozen boundary: exact named historical tuple executed unchanged; 27 unique ordered outcomes yielded three accepted and 24 locally rejected samples with a monotone boundary.
- Adversarial aggregate remained green at 27 scenarios, 744 proposals, 1,632 bilateral protected truth pixels, zero protected intersections, and zero protected/outside byte mismatches.
- Source scans found the exact tuple literals, inclusive `segmentsIntersect`/`onSegment` predicates, and the production pupil-center limit; `git diff --check` passed.

## Known Stubs

None.

## Threat Flags

None. The changed production surface is the mapped-eye-geometry admission boundary already covered by the plan threat model; no network, authentication, file-access, schema, public API, or durable evidence surface was introduced.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 64-08 can regenerate fresh evidence against the corrected exact-tuple and inclusive-contour baseline.
- Earlier review authority remains invalidated; promotion and final verification stay serially blocked on Plans 64-08 through 64-11.
- DeviceRGB/named-sRGB behavior remains untouched for exclusive Phase 65 ownership.

## Self-Check: PASSED

- All three implementation/test files and this summary exist.
- Task commits `54937b0`, `7308d77`, `006a081`, and `8e54feb` exist in repository history.
- All plan-prescribed focused suites, exact-literal/predicate scans, peer/recovery checks, and diff hygiene checks passed.

---
*Phase: 64-sclera-output-adversarial-safety-and-independent-closeout*
*Completed: 2026-08-09*
