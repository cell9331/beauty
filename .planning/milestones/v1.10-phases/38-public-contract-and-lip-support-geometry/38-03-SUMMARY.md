---
phase: 38-public-contract-and-lip-support-geometry
plan: "03"
subsystem: mouth-warp-provider
tags: [swift, geometry, warp, validation, fail-closed]

requires:
  - phase: 38-public-contract-and-lip-support-geometry
    plan: "01"
    provides: Five independent effective mouth strengths and provisional cap symbols
  - phase: 38-public-contract-and-lip-support-geometry
    plan: "02"
    provides: Explicit package-only whole, upper, lower, and inner lip supports
provides:
  - Eight independently eligible and sanitizable mouth geometry emissions
  - Signed whole-mouth Y translation, clockwise image-space tilt, and X translation
  - Explicit upper-plus-inner peak shaping and upper/lower/inner plump shaping
  - Strict field-local support, scalar, displacement, target, and output validation
affects: [38-04, phase-39, phase-40]

tech-stack:
  added: []
  patterns: [provider-owned field emissions, pre-clamp geometry validation, field-local fail-closed sanitization]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift

key-decisions:
  - "Aggregate emissions in canonical shipped-first order: size, width, smile, Y position, tilt, X position, peak, then plump."
  - "In top-to-bottom normalized image coordinates, positive Y moves downward, positive X moves rightward, and positive tilt rotates visually clockwise."
  - "Peak emits sorted upper-lip flanks upward and its center toward the opening; plump emits sorted upper then lower surfaces radially away from the inner-opening center."
  - "Retain the established just-above-threshold size/width pre-conflict contract with a minimal renderable displacement while rejecting post-scale and new-field displacement-empty work."

patterns-established:
  - "Each requested effective field is sanitized independently from its own final emission, so aggregate sibling output cannot conceal provider-empty work."
  - "Support and targets must be finite, normalized, face-bounded, distinct, structurally sufficient, and nonzero before final clamping constructs a control point."

requirements-completed:
  - MOUTH-05
  - MOUTH-06
  - MOUTH-07
  - MOUTH-08

duration: 10min
completed: 2026-07-14
---

# Phase 38 Plan 03: Eight-Field Provider Geometry Summary

**The mouth warp provider now owns eight independently validated emissions with distinct signed whole-mouth transforms, local peak/plump vectors, and field-local fail-closed sanitization.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-07-14T07:39:43Z
- **Completed:** 2026-07-14T07:49:53Z
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments

- Expanded `MouthWarpFieldEmissions` from three to eight arrays with deterministic canonical aggregation and eight independent sanitization branches.
- Removed the provider-global outer-center guard; each shipped, whole-transform, peak, and plump helper now evaluates only its own prerequisites.
- Added bounded signed vertical translation, horizontal translation, and center rotation with exact axis/radius/sign evidence.
- Added local three-point cupid-bow peak shaping from upper plus inner support and six-point upper/lower plump shaping away from the inner opening.
- Added strict finite/bounds/distinctness/cardinality/degeneracy/scalar/displacement/target checks before output construction and a fixed redacted aggregate-empty skip reason.
- Preserved exact normal-strength shipped size, width, and smile arrays and passed the complete 252-test SwiftPM suite.

## Task Commits

Each task was committed atomically:

1. **Task 38-03-01: Implement strict eight-field mouth emissions and independent geometry** - `676eb20` (feat)

**Plan metadata:** committed with this summary.

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` - Owns eight emissions, field-local validators, five new geometry helpers, canonical ordering, and sanitization.
- `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` - Provides exact shipped regression, direct vector, sign, local-support, non-alias, safety, malformed, sibling, and skip-reason evidence.

## Decisions Made

- Whole-mouth transforms preserve the input outer-lip source order; peak and plump sort each explicit local surface left-to-right, with plump aggregating upper before lower.
- Positive tilt uses the standard rotation formula in downward-growing image coordinates, making the visible direction clockwise while preserving source radius.
- Peak uses symmetric upward flanks with a smaller center motion toward the opening; plump uses the normalized vector from the inner-opening center to each upper/lower source.
- Size and width retain their prior just-above-threshold pre-conflict eligibility through a minimal nonzero displacement, while all final outputs still require renderable source-to-target distance.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first full-suite run exposed an established conflict-convergence contract where just-above-threshold `mouthSize` and `mouthWidth` must emit before weakening. Their private displacement calculation now applies a minimal renderable floor only in that legacy threshold case; normal-strength arrays remain exact and the focused 30-test degradation suite plus full suite pass.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 38-04 can enumerate all five new fields through resolver activation, reuse, conflict convergence, diagnostics, facade routing, and final emission/effective-strength agreement.
- Saved-output/ROI evidence, final cap calibration, exhaustive transition safety, and row promotion remain deliberately deferred to Phases 39 and 40.

## Self-Check: PASSED

- The task commit changes exactly the provider and its direct test file.
- Task commit `676eb20` exists and contains all eight emission, validator, helper, and test changes atomically.
- `MouthWarpProviderTests` passed 16/16 twice; the focused degradation regression passed 30/30 after compatibility hardening; the full SwiftPM suite passed 252/252.
- Eight-field structure/order/sanitization, raw diagnostic leak, public/SPI, scope, stub, ASVS L1 high-finding, and diff-hygiene scans pass.

---
*Phase: 38-public-contract-and-lip-support-geometry*
*Completed: 2026-07-14*
