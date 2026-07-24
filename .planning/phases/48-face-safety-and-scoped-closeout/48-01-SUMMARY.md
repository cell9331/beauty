---
phase: 48-face-safety-and-scoped-closeout
plan: "01"
subsystem: face-safety
tags: [swift, face-geometry, caps, degradation, redaction]
requires: [phase-45-face-support, phase-46-face-pipeline, phase-47-output-evidence]
provides: [final-four-face-caps, nine-field-face-transitions, exact-neutral-boundary]
affects: [48-02, 48-03, 48-04]
tech-stack:
  added: []
  patterns: [table-driven-cap-matrix, field-local-provider-sanitization, stateless-freshness-transitions]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
key-decisions:
  - "The four Phase 46 cap values are final at exactly 0.25; zero and Float.ulpOfOne remain inert without a new product dead zone."
  - "The five shipped face/chin fields retain their compatibility support and existing skipped-domain policy while the four additions fail at their observed-support dependency."
requirements-completed: [SAFE-01]
coverage:
  - deliverable: "Four exact final caps and complete positive-only input-class accounting"
    verification:
      - kind: test
        ref: "BeautySafetyCapsTests#testSAFE01FinalContourAndChinCapsAreExactlyPointTwoFive"
        status: pass
      - kind: test
        ref: "BeautyEffectResolverTests#testSAFE01FinalFaceCapInputClassesAreExactAndRedacted"
        status: pass
    human_judgment: false
  - deliverable: "Nine-field support, freshness, malformed, provider-empty, transition, and redaction evidence"
    verification:
      - kind: test
        ref: "MissingLandmarkDegradationTests#testSAFE01CompleteNineFieldFaceTransitionsAreFieldLocalAndStateless"
        status: pass
      - kind: test
        ref: "BeautyEngineGeometryFacadeTests#testOUT03MissingAndMalformedObservedContourRemoveNewWorkWhileShippedSiblingContinues"
        status: pass
    human_judgment: false
duration: 8 min
completed: 2026-07-24
status: complete
---

# Phase 48 Plan 01: Final Face Caps and Exhaustive Safety Summary

The four contour/chin controls now have final exact `0.25` cap and neutral-boundary contracts, and the complete nine-field face/chin inventory has executable field-local support and freshness transitions.

## Accomplishments

- Finalized the four `0.25` constants and covered zero, `Float.ulpOfOne`, exact cap, overflow, negative, NaN, and both infinities with exact capped counts, warnings, metrics, emissions, domains, and redaction.
- Added one nine-unique-field descriptor matrix across the five shipped and four new face/chin controls.
- Proved exact reused `0.5`, stale/no-face final skip, missing/malformed observed contour, missing/malformed centerline, proxy isolation, valid sibling continuation, and stateless return to fresh work.
- Preserved every shipped cap/vector and the Phase 47 public facade/output contract.

## Task Commit

- `d07d86d` — `test(48-01): freeze face safety transitions`

## Verification

- `BeautySafetyCapsTests` — 5/5 passed.
- `BeautyEffectResolverTests` — 22/22 passed.
- `FaceShapeWarpProviderTests` — 17/17 passed.
- `MissingLandmarkDegradationTests` — 44/44 passed.
- `BeautyEngineGeometryFacadeTests` — 16/16 passed.
- Full `swift test --package-path BeautySDK` — 374 executed, 3 opt-in Apple Vision skips, 0 failures.
- `git diff --check` passed.

## Deviations from Plan

None. Production geometry behavior did not change; only the cap ownership comment changed after exact tests passed.

## Security and Scope

- Observed contour/median data remains package-only, request-scoped, non-Codable, non-persistent, and absent from public diagnostics.
- No public API, Demo, dependency, renderer, resource, generated-media, commercial, or lifecycle surface changed.
- Exact convergence, active-source boundary evidence, promotion, and owner synchronization remain Plans 48-02 through 48-06.

## Self-Check: PASSED

All modified files exist, the implementation commit is present, every focused/full verification passed, and Plan 48-02 is unblocked.
