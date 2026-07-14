---
phase: 37-nose-safety-boundary-and-branch-closeout
plan: "02"
subsystem: testing
tags: [swiftpm, xctest, geometry-conflict, provider-eligibility, convergence]

requires:
  - phase: 37-nose-safety-boundary-and-branch-closeout
    plan: "01"
    provides: exact caps and exhaustive six-field degradation/emission fixtures
provides:
  - exact once-only face/eye/mouth/nose conflict arithmetic for all seven nose direction rows
  - exact all-18-field lower-level total, count, scale, warning, and sign evidence
  - integrated provider-empty removal with supported-sibling and no-sibling domain convergence
affects: [37-03-runtime-security-boundaries, 37-04-promotion]

tech-stack:
  added: []
  patterns: [test-local retained-total mirrors, provider-effective equality, signed absolute-magnitude totals]

key-files:
  created:
    - .planning/phases/37-nose-safety-boundary-and-branch-closeout/37-02-SUMMARY.md
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift

key-decisions:
  - "Keep the existing production convergence unchanged; every stronger exact assertion passed without resolver or provider repair."
  - "Prove private geometry totals test-locally and retain only weakened-count and scale as aggregate production metrics."
  - "Use provider-empty root support to prove both supported-sibling and no-sibling convergence across both signed tip directions."

patterns-established:
  - "Direction rows compute exact retained totals from capped unscaled values, then assert each final effective value against the single resulting scale."
  - "Integrated convergence compares final per-field provider emissions with final effective strengths and asserts removed work is absent from count, scale, domains, and dispatch."

requirements-completed: [NOSE-11, NOSE-12]

duration: 8 min
completed: 2026-07-14
---

# Phase 37 Plan 02: Exact Combined Convergence Summary

**Exact once-only multi-domain weakening now converges on one provider-eligible retained set across the complete six-field nose inventory and both signed tip directions.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-14T02:39:00Z
- **Completed:** 2026-07-14T02:46:42Z
- **Tasks:** 2
- **Files modified:** 3 test files plus this summary

## Accomplishments

- Replaced the seven relational nose checks with exact face/eye/mouth/nose arithmetic: retained totals are `1.75`, `1.70`, or `1.65` by field cap, scales are respectively `1 / total`, weakened count is exactly `4`, signs are preserved, and exactly one combined warning is emitted.
- Locked the complete lower-level 18-field geometry inventory at exact unscaled total `6.65`, weakened count `18`, scale `1 / 6.65`, one warning, and individually scaled signed/positive effective strengths.
- Added an all-six requested-nose integrated fixture where provider-empty root work contributes zero times while five nose siblings, representative face/eye/mouth work, and both signed tip directions remain active and emit.
- Added the corresponding no-nose-sibling case: retained total `1.40`, count `3`, scale `1 / 1.40`, `.nose` skipped once, and the removed root absent from final dispatch and conflict evidence.
- Confirmed no production resolver/provider change was needed and no public geometry-total metric was introduced.

## Task Commits

Each task was committed atomically:

1. **Task 37-02-01: Replace relational combined checks with exact direction-complete arithmetic** - `3998ecc` (test)
2. **Task 37-02-02: Prove integrated provider-empty convergence and regress shared geometry** - `67542da` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` - Seven exact nose-direction rows with one retained face/eye/mouth scale.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` - Exact all-18-field total/count/scale/sign seam and complete test-local geometry total.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Integrated provider-empty all-six, supported-sibling, no-sibling, final-emission, and domain convergence evidence.
- `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-02-SUMMARY.md` - Plan outcome, exact arithmetic, verification, and handoff.

## Exact Arithmetic Observed

- Seven direction rows: `faceSlim 0.60 + eyeSize 0.45 + mouthSize 0.35 + nose field magnitude`; totals `1.75` for slim/wing, `1.70` for signed tip/bridge, and `1.65` for root/lift; count `4`; scale exactly `1 / total`; one combined warning per row.
- Complete lower seam: total `6.65`; count `18`; scale `1 / 6.65` (`~0.15037594`); signed chin, eye-distance, nose-tip, and mouth-size values preserve direction.
- Provider-empty root with five emitting nose siblings: retained total `2.95`; count `8`; scale `1 / 2.95` (`~0.33898305`); root effective strength/emission are zero; all other selected domain providers emit; one combined warning.
- Provider-empty root without a nose sibling: retained total `1.40`; count `3`; scale `1 / 1.40` (`~0.71428573`); `.nose` is skipped with one redacted `nose_inputs_missing`; face, eye, and mouth stay active; one combined warning.

## Verification Evidence

- `NoseWarpProviderTests` - 16 tests, 0 failures.
- `MouthWarpProviderTests` - 6 tests, 0 failures.
- `MissingLandmarkDegradationTests` - 30 tests, 0 failures.
- `BeautyEffectResolverTests` - 15 tests, 0 failures.
- `CombinedEffectSafetyTests` - 10 tests, 0 failures.
- `GeometryConflictResolverTests` - 9 tests, 0 failures.
- Plan-focused aggregate - 86 tests, 0 failures.
- Full `swift test --package-path BeautySDK` - 228 tests, 0 failures.
- `git diff --check` - passed after each task and after the full regression.

## Decisions Made

- The bounded monotonic at-most-nine-removal resolver remains the sole convergence implementation. Exact retained-set assertions found no production divergence.
- Provider eligibility is evaluated per field; aggregate nose points are never used as evidence that a specific field emits.
- Private total arithmetic stays test-local. Public evidence remains the existing aggregate weakened count, scale, warnings, effective strengths, domains, and final provider emissions.

## Deviations from Plan

None - plan executed exactly as written. Conditional production and shared provider-test edits were unnecessary because all locked assertions passed against the existing implementation.

## Issues Encountered

- Two exact decimal-total assertions initially used a tolerance smaller than one Float rounding step (`6.65 -> 0.9999999` after scaling and `2.95 -> 2.9499998` during summation). The assertions retain exact expected arithmetic while using `0.000001` only for those aggregate Float sums; all individual values and scale metrics remain checked at `0.0000001`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for Plan 37-03 command-backed full runtime, unchanged Phase 36 output, ASVS/security, active-source, artifact, and boundary gates.
- `山根`, `提升`, and branch-level `鼻子` remain unpromoted. No product ledger, current-owner contract, audit artifact, archive, tag, or cleanup work was started.

## Self-Check: PASSED

- All declared test artifacts exist; no conditional production file changed.
- `git log --oneline --all --grep="37-02"` contains both atomic task commits.
- Every task acceptance criterion and plan-level focused command passed with nonzero test counts.
- Final provider sanitization equals final effective strengths; provider-empty work contributes zero times and supported siblings remain active.
- Full SwiftPM passes 228/228 and `git diff --check` passes.

---
*Phase: 37-nose-safety-boundary-and-branch-closeout*
*Completed: 2026-07-14*
