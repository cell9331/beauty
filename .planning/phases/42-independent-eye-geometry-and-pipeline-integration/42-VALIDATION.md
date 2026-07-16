---
phase: 42
slug: independent-eye-geometry-and-pipeline-integration
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-16
---

# Phase 42 — Validation Strategy

## Test Infrastructure

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM |
| Quick provider command | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` |
| Quick resolver command | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` |
| Degradation command | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` |
| Full suite | `swift test --package-path BeautySDK` |

## Planned Verification Map

| Task | Wave | Requirements | Verification |
|---|---:|---|---|
| 42-01-01 | 1 | EYE-08, EYE-09, EYE-10, EYE-11 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` (9/9) |
| 42-01-02 | 1 | EYE-12, EYE-13, EYE-14 | Named provider test covers pupil evidence gating; 9/9 provider tests |
| 42-02-01 | 2 | EYE-08..EYE-15 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` (18/18) |
| 42-02-02 | 2 | EYE-15 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` (37/37) |
| 42-03-01 | 3 | EYE-15 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` (10/10) |
| 42-03-02 | 3 | EYE-08..EYE-15 | Combined + resolver/degradation suites pass; aggregate/redaction assertions green |
| 42-04-01 | 4 | EYE-08..EYE-15 | `swift test --package-path BeautySDK` (295/295) and `git diff --check` |

## Wave 0 Requirements

- [x] Semantic-support fixtures include both complete eyes, optional pupils,
  measured center/span/tilt asymmetry, neutral gaze, malformed support, and
  reused/stale/no-face states.
- [x] Provider tests isolate every one of the fourteen named emissions and
  compare each new field with its nearest shipped/new neighbor.
- [x] Resolver tests assert final-empty fields are zero before active domains,
  totals, warnings, metrics, and geometry-point counts.

## Requirement Evidence Targets

- **EYE-08:** eyeHeight and eyeLength arrays use distinct lid/corner source
  subsets, preserve centers, and differ from radial size/distance.
- **EYE-09:** upper/lower lid arrays move only their named lid and differ from
  eyeYPosition, eyeHeight, and tailLift.
- **EYE-10:** signed tilt arrays rotate around stable centers with opposite
  tangential directions and bounded radius error.
- **EYE-11:** side-aware inner/outer corner arrays are independent and local.
- **EYE-12:** pupilSize arrays are pupil-local and absent without a valid pupil.
- **EYE-13:** gazeCorrection monotonically reduces observed offset, no-ops in a
  neutral dead zone, and accepts no manual direction.
- **EYE-14:** symmetry moves only measured pair differences toward midpoint and
  no-ops for neutral/implausible pairs without mirroring identity.
- **EYE-15:** all fourteen named emissions route through provider/resolver/
  facade; field-local preflight/final empties are excluded from all accounting
  while valid siblings remain active.

## Sign-Off (to complete after execution)

- [x] Every task has focused automated evidence.
- [x] No three consecutive tasks lack automated verification.
- [x] Full SwiftPM suite passes with zero failures.
- [x] `git diff --check` passes.
- [x] Output/gallery and final cap/promotion non-claims remain explicit.
- [x] `nyquist_compliant: true` and `wave_0_complete: true` only after measured evidence.

## Measured gate

Executed on 2026-07-16: provider 9/9, resolver 18/18, degradation 37/37, combined 10/10, and full SwiftPM 295/295. No generated output, Demo, manifest, dependency, or public geometry surface changed.
