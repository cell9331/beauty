---
phase: 44-eye-geometry-safety-and-ledger-closeout
plan: "01"
subsystem: eye-safety
tags: [swift, eye-geometry, caps, degradation, redaction]
requires: [phase-41-eye-support, phase-42-eye-pipeline, phase-43-output-evidence]
provides: [final-ten-eye-caps, fourteen-field-degradation, exact-eye-dead-zones]
affects: [44-02, 44-03, 44-04]
tech-stack:
  added: []
  patterns: [table-driven-cap-matrix, field-local-provider-sanitization, stateless-freshness-transitions]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
key-decisions:
  - "The ten Phase 42 cap values are final and retain their existing public normalization semantics."
  - "Only actual no-face internal planning zeros all fourteen eye strengths; scalar-only public resolution retains its compatibility contract."
requirements-completed: [EYE-19, EYE-20]
coverage:
  - deliverable: "Ten exact final caps with positive-only, signed, overflow, and non-finite accounting"
    verification:
      - kind: test
        ref: "BeautySafetyCapsTests#testEYE19FinalRemainingEyeCapsMatchExactContract"
        status: pass
      - kind: test
        ref: "BeautyEffectResolverTests#testEYE19FinalEyeCapNormalizationWarningAndMetricMatrix"
        status: pass
    human_judgment: false
  - deliverable: "Exact gaze and symmetry dead zones with fixed maximum correction/blend fractions"
    verification:
      - kind: test
        ref: "EyeWarpProviderTests#testEYE19GazeDeadZoneAndMaximumCorrectionFractionAreExact"
        status: pass
      - kind: test
        ref: "EyeWarpProviderTests#testEYE19SymmetryDeadZoneAndMaximumMidpointBlendAreExact"
        status: pass
    human_judgment: false
  - deliverable: "Fourteen-field provider eligibility, complete-eye degradation, transitions, and facade redaction"
    verification:
      - kind: test
        ref: "EyeWarpProviderTests#testPhase42FourteenNamedEmissionsAreIndependentAndEvidenceGated"
        status: pass
      - kind: test
        ref: "MissingLandmarkDegradationTests#testEYE20AllFourteenFieldsFreshnessTransitionsAreStateless"
        status: pass
      - kind: test
        ref: "BeautyEngineGeometryFacadeTests#testEyeNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata"
        status: pass
    human_judgment: false
duration: 8 min
completed: 2026-07-19
status: complete
---

# Phase 44 Plan 01: Final Eye Caps and Exhaustive Degradation Summary

The ten remaining eye controls now have final exact cap/dead-zone contracts, and all fourteen eye fields fail closed at their narrowest support and freshness dependency without leaking geometry or suppressing safe siblings.

## Accomplishments

- Locked the ten exact cap constants and exhaustive zero/exact/overflow/negative/non-finite accounting matrix, including both signed tilt directions.
- Proved gaze `0.002` and symmetry `0.0001` neutral boundaries plus the existing `0.35` correction and `0.30` midpoint-blend ceilings.
- Expanded named provider evidence to all fourteen fields, pupil-local removal, idempotent final sanitization, and complete-eye zeroing.
- Added stateless fresh/reused/stale/no-face transitions and strengthened public no-face facade counts, extent, and redaction evidence.

## Task Commits

- `49d14ac` — `test(44-01): lock final eye cap matrix`
- `7b2511a` — `test(44-01): prove eye algorithm dead zones`
- `2584744` — `test(44-01): lock fourteen-field eye eligibility`
- `6e14290` — `fix(44-01): zero no-face eye strengths`

## Verification

- `BeautySafetyCapsTests` — 4/4 passed.
- `BeautyEffectResolverTests` — 19/19 passed.
- `EyeWarpProviderTests` — 16/16 passed.
- `MissingLandmarkDegradationTests` — 40/40 passed.
- `BeautyEngineGeometryFacadeTests` — 13/13 passed.
- Full `swift test --package-path BeautySDK` — 310/310 passed.
- `BeautyDemo`, `BeautySDK/Package.swift`, and public `BeautyCore` source remained unchanged; `git diff --check` passed.

## Deviations from Plan

**[Rule 1 - Bug] No-face eye strengths remained nonzero** — Found during Task 44-01-04. The resolver marked `.eyes` skipped for an actual missing face but retained all fourteen effective strengths. The no-face branch now zeros them while preserving scalar-only public resolver compatibility. Verified by focused resolver/degradation/facade suites and the 310-test full suite. Commit: `6e14290`.

**Total deviations:** 1 auto-fixed bug. **Impact:** stronger fail-closed accounting with no public API or output-contract change.

## Security and Scope

- Observed contours/pupils remain package-only, request-scoped, non-Codable, and absent from diagnostics.
- No Demo, package, dependency, renderer, generated-media, commercial, performance, or lifecycle surface changed.
- Convergence, boundary/security evidence, promotion, owner synchronization, and independent audit remain Plans 44-02 through 44-06.

## Self-Check: PASSED

- All seven modified files exist and four task commits are present.
- Every plan-level focused/full verification and scope gate passed.
- Ready for Plan 44-02 exact retained-set convergence.
