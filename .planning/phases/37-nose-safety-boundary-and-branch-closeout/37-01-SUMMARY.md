---
phase: 37-nose-safety-boundary-and-branch-closeout
plan: "01"
subsystem: testing
tags: [swiftpm, xctest, nose-geometry, safety-caps, degradation, redaction]

requires:
  - phase: 35-public-contract-and-independent-geometry
    provides: independent public nose fields and package-internal root/tip provider paths
  - phase: 36-public-facade-output-evidence
    provides: isolated public-facade output evidence supporting the final conservative cap
provides:
  - exact 0.25 normalization, effective-cap, count, warning, and metric evidence for both remaining nose fields
  - exhaustive six-field zero, no-face, missing/provider-empty, stale, reused, and transition evidence
  - all-six public no-face facade extent, safe-domain, aggregate-diagnostic, and redaction evidence
affects: [37-02-combined-convergence, 37-03-security-boundaries, 37-04-promotion]

tech-stack:
  added: []
  patterns: [typed key-path test descriptors, per-field emission eligibility assertions, independent sequential result comparison]

key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift

key-decisions:
  - "Keep both remaining nose caps at exactly 0.25; the locked matrix passed without production changes."
  - "Treat each field's own provider emission array as the eligibility boundary while allowing supported siblings to continue."
  - "Prove transition safety by comparing independently returned plans and emissions; add no cache or state machine."

patterns-established:
  - "Requirement-named cap tables assert public normalized values, final effective values, warning multiplicity, and exact metric keys."
  - "Six-field safety tables use writable/key-path descriptors to cover both signed tip directions without aggregate-emission shortcuts."

requirements-completed: [NOSE-10, NOSE-11]

duration: 9 min
completed: 2026-07-14
---

# Phase 37 Plan 01: Exact Caps and Exhaustive Six-Field Safety Summary

**Exact 0.25 cap evidence and field-complete fail-closed nose safety matrices now cover every public nose field, both signed tip directions, transitions, and the public no-face facade.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-07-14T02:29:42Z
- **Completed:** 2026-07-14T02:38:00Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments

- Locked both remaining positive-only nose fields at exact public/effective `0.25` behavior across zero, exact cap, overflow, negative, NaN, and both infinities, including exact aggregate count/warning/metric behavior.
- Added typed six-field provider and resolver matrices covering zero, no-face, narrow missing support, provider-empty emission, stale, exact reused values (`0.175`, `0.175`, signed `±0.15`, `0.15`, `0.125`, `0.125`), supported siblings, and fresh/reused/stale plus valid/unavailable transitions.
- Expanded the public no-face facade request to all six fields while preserving extent, two safe independent domains, zero geometry dispatch, exact detection counts, aggregate diagnostics, and redaction.
- Confirmed the stronger characterization tests require no resolver or provider production-code repair.

## Task Commits

Each task was committed atomically:

1. **Task 37-01-01: Lock exact 0.25 cap semantics and aggregate evidence** - `c5531f2` (test)
2. **Task 37-01-02: Add exhaustive per-field degradation, emission, and transition coverage** - `a07c636` (test)
3. **Task 37-01-03: Close the all-six public no-face facade seam** - `df65485` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` - Requirement-named exact constant evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Two-field finite/non-finite cap, count, warning, and metric table.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` - Six-field own-emission and sibling-isolation descriptor.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Exhaustive degradation/reuse and sequential transition matrices with expanded redaction guards.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Shared narrow legacy-nose fixtures that preserve explicit root/tip siblings.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` - All-six public no-face facade evidence.

## Verification Evidence

- `swift test --package-path BeautySDK --filter BeautySafetyCapsTests` — 2 tests, 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectResolverTests` — 15 tests, 0 failures.
- `swift test --package-path BeautySDK --filter NoseWarpProviderTests` — 16 tests, 0 failures.
- `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` — 28 tests, 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests` — 11 tests, 0 failures.
- Final affected-suite gate: 72 tests, 0 failures.
- Additional changed-fixture regression: `FaceShapeWarpProviderTests` — 9 tests, 0 failures.
- `swift test --package-path BeautySDK` — 225 tests, 0 failures.
- `git diff --check` — passed.

## Decisions Made

- Exact `0.25` remains the conservative SDK safety cap for `noseRootNarrowing` and `noseTipLift`; this plan makes no subjective naturalness, device, commercial, or production-quality claim.
- Provider eligibility is asserted per field through `NoseWarpFieldEmissions`, never inferred from aggregate nose points.
- Existing monotonic removal and stateless resolution behavior is sufficient; no production source changed.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- One test compile attempt exposed Swift initializer argument ordering in a new transition row. The row was reordered, then every required focused and full regression gate passed. No product behavior changed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for Plan 37-02 exact combined-geometry convergence evidence.
- Promotion remains explicitly pending Plans 37-03 and 37-04; no product ledger or owning contract was promoted here.

## Self-Check: PASSED

- All six key test files exist and are committed.
- `git log --oneline --all --grep="37-01"` contains all three task commits.
- Every task acceptance criterion and the plan-level focused verification commands pass.
- Full SwiftPM regression passes 225/225.

---
*Phase: 37-nose-safety-boundary-and-branch-closeout*
*Completed: 2026-07-14*
