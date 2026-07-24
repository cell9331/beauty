---
phase: 48-face-safety-and-scoped-closeout
plan: "02"
subsystem: geometry-convergence
tags: [swift, convergence, provider-sanitization, dispatch, redaction]
requires: [48-01]
provides: [exact-37-field-baseline, provider-final-strength-agreement, bounded-removal-loop]
affects: [48-03, 48-04, 48-06]
tech-stack:
  added: []
  patterns: [ordered-domain-subtotals, provider-eligible-all-field-fixture, named-emission-sanitization]
key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
key-decisions:
  - "The exact 37-field independent baseline is 11.70: face/chin 3.35, eyes 4.10, nose 1.80, and mouth 2.45."
  - "Provider-empty removal remains field-local and monotone; the exact loop ceiling is 37 and removed fields never re-enter or receive a second scale."
requirements-completed: [SAFE-02]
coverage:
  - deliverable: "Exact one-baseline arithmetic for all 37 geometry fields"
    verification:
      - kind: test
        ref: "GeometryConflictResolverTests#testSAFE02AllThirtySevenFieldsShareExactElevenPointSevenBaseline"
        status: pass
    human_judgment: false
  - deliverable: "Final strengths agree with named provider emissions and unified dispatch"
    verification:
      - kind: test
        ref: "CombinedEffectSafetyTests#testSAFE02AllThirtySevenFinalStrengthsMatchNamedProviderEmissionsAndDispatch"
        status: pass
      - kind: test
        ref: "CombinedEffectSafetyTests#testSAFE02ConvergenceLoopHasExactThirtySevenRemovalCeiling"
        status: pass
    human_judgment: false
duration: 10 min
completed: 2026-07-24
status: complete
---

# Phase 48 Plan 02: Exact 37-Field Convergence Summary

All geometry domains now have one executable exact-baseline contract, and a fully provider-eligible fixture proves that every retained final strength owns named provider work and reaches the unified dispatcher unchanged.

## Accomplishments

- Locked the ordered 37-field inventory and exact domain subtotals: `3.35 + 4.10 + 1.80 + 2.45 = 11.70`.
- Proved exact one-time weakening by `1 / 11.70`, a weakened count of 37, and one redacted combined warning.
- Added a complete observed-support fixture in which all 37 fields remain provider-eligible after scaling.
- Proved sequential named-emission sanitization equals the final strength vector and unified dispatch equals the exact provider point concatenation.
- Retained existing provider-empty precedents and the exact 37-removal convergence ceiling, with no re-entry or double scaling.

## Task Commit

- `0a727b9` — `test(48-02): lock exact 37-field convergence`

## Verification

- `GeometryConflictResolverTests` — 13/13 passed.
- `CombinedEffectSafetyTests` — 15/15 passed.
- `MissingLandmarkDegradationTests` — 44/44 passed.
- Full `swift test --package-path BeautySDK` — 375 executed, 3 opt-in Apple Vision skips, 0 failures.
- `git diff --check` passed.

## Deviations from Plan

None. Production geometry behavior did not change.

## Security and Scope

- The new fixture is test-only and uses package-internal, request-scoped support carriers.
- Diagnostics remain aggregate-only and redacted.
- No public API, Demo, renderer, dependency, resource, generated-media, product-row, or lifecycle surface changed.

## Self-Check: PASSED

Both exact convergence tests and every focused/full verification passed. Plan 48-03 can now bind this runtime evidence to fail-closed source and privacy boundaries.
