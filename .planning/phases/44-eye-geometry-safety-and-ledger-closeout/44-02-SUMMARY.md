---
phase: 44-eye-geometry-safety-and-ledger-closeout
plan: "02"
subsystem: geometry-safety
tags: [swift, geometry-conflict, convergence, provider-integrity]
requires: [44-01]
provides: [exact-retained-baseline, bounded-provider-removals, mixed-mask-continuation]
affects: [44-03, 44-04]
tech-stack:
  added: []
  patterns: [exact-field-inventory-fixture, table-driven-removal-mask, source-bound-convergence-guard]
key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
key-decisions:
  - "The fully eligible retained geometry set is one exact 10.70 baseline across 33 fields, with aggregate-only weakening diagnostics."
  - "Provider-empty sanitization is field-local and monotonic, with an executable ceiling of 28 possible removals and no re-entry."
requirements-completed: [EYE-20, EYE-21]
coverage:
  - deliverable: "Exact five-face, fourteen-eye, six-nose, and eight-mouth retained arithmetic"
    verification:
      - kind: test
        ref: "GeometryConflictResolverTests#testEYE21AllThirtyThreeGeometryFieldsShareExactTenPointSevenBaseline"
        status: pass
    human_judgment: false
  - deliverable: "All 28 provider-empty removals fail closed without re-entry or double scaling"
    verification:
      - kind: test
        ref: "CombinedEffectSafetyTests#testEYE21AllTwentyEightProviderFieldsFailClosedWithoutReentry"
        status: pass
      - kind: test
        ref: "CombinedEffectSafetyTests#testEYE21ConvergenceLoopHasExactTwentyEightRemovalCeiling"
        status: pass
    human_judgment: false
  - deliverable: "Mixed eye masks preserve safe siblings, signed direction, extent, and metadata redaction"
    verification:
      - kind: test
        ref: "CombinedEffectSafetyTests#testEYE21MixedEyeMasksPreserveSafeDomainsAndSignedDirection"
        status: pass
      - kind: test
        ref: "BeautyEngineGeometryFacadeTests#testEyeNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata"
        status: pass
    human_judgment: false
duration: 10 min
completed: 2026-07-19
status: complete
---

# Phase 44 Plan 02: Exact Retained Baseline and Bounded Convergence Summary

The resolver now has executable evidence for one retained 33-field baseline and a monotonic provider-removal convergence bound. Mixed eye masks continue safe sibling domains without leaking stale geometry or changing the scalar-only facade contract.

## Accomplishments

- Locked the exact five-face + fourteen-eye + six-nose + eight-mouth inventory at total `10.70`, count `33`, and scale `1/10.70`, including aggregate warning/count semantics and signed directions.
- Covered all 28 provider-removal paths in one adversarial table, with provider-empty fields excluded from accounting and no re-entry or double scaling.
- Added a source-bound executable guard for the exact 28-pass convergence ceiling and monotonic removal contract.
- Regressed fresh missing-pupil, reused/stale eye, and no-face mixed masks so safe face/non-eye/color/filter domains continue while eye geometry stays fail-closed and metadata redacted.

## Task Commits

- `6cf440a` — `test(44-02): lock exact thirty-three-field baseline`
- `ff9ede3` — `test(44-02): prove bounded provider removal convergence`
- `9c9c8e5` — `test(44-02): preserve mixed-mask safe domains`

## Verification

- `GeometryConflictResolverTests` — 12/12 passed.
- `CombinedEffectSafetyTests` — 13/13 passed.
- `MissingLandmarkDegradationTests` — 40/40 passed.
- `BeautyEngineGeometryFacadeTests` — 13/13 passed.
- Full `swift test --package-path BeautySDK` — 314/314 passed.
- `git diff --check` and source/Demo/`BeautySDK/Package.swift` drift gates passed.

## Deviations from Plan

None. No production, public API, package, renderer, or generated artifact was changed.

## Security and Scope

- Provider-empty fields are excluded from retained arithmetic and cannot re-enter after final sanitization.
- Signed eye/nose/mouth directions remain signed through conflict scaling; safe sibling domains remain active under mixed masks.
- Boundary/promotion/owner synchronization and independent audit remain Plans 44-03 through 44-06.

## Self-Check: PASSED

- All modified test files exist and three task commits are present.
- Focused and full verification passed with exact field inventory and no source drift.
- Ready for Plan 44-03 boundary, security, and evidence gates.
