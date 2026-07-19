---
phase: 41-public-contract-and-observed-eye-support
plan: "03"
subsystem: effects-geometry
tags: [swift, eye-support, validation, degradation, privacy]
requirements-completed: [EYE-06, EYE-07]

# Phase 41 Plan 03: Observed Eye Support Summary

## Outcome

`BeautyFaceGeometryAdapter` now validates request-scoped observed eye contours
and pupils, canonicalizes semantic support independently of input winding, and
attaches package-internal `BeautyEyeSemanticSupport` values to `FaceGeometry`.
Explicit malformed or missing observed sides fail closed without synthetic eye
proxies; a nil observed payload retains only the legacy proxy path needed for
shipped zero-default compatibility. Pupil failures remain local to pupil
eligibility, while the resolver's complete-eye gate skips the eye domain when
either contour side is unavailable.

## Task commits

1. `c21b004` — validate and canonicalize observed eye semantic support.
2. `a265922` — prove pupil-local degradation, complete-eye gating, and neutral
   provider behavior.

## Verification

- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` — 4 tests passed.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` — 37 tests passed.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` — 8 tests passed.
- `swift test --package-path BeautySDK` — 283 tests passed, 0 failures.
- `git diff --check` — clean.

## Locked support-validation bounds

Contours accept 6...16 input points, at least 4 unique finite mapped points,
closed-unit coordinates, face-relative width 0.04...0.50, height 0.01...0.30,
and strictly positive relative bounding area above 0.0004. Pupils require one
finite unique point, 10% expanded containment, normalized ellipse offset <=
0.70, and paired contour width/height ratios 0.50...2.00. These are
support-validation ceilings, not final visual-effect caps.

## Scope and privacy

Support remains package-internal, request-scoped, non-Codable, and absent from
diagnostics. No provider transforms, final caps, fourteen emissions, facade
routing, boundary helper, promotion, or Demo work was implemented; those remain
downstream Phase 41-04 / Phase 42-44 scope.

## Self-Check: PASSED

- Both task commits exist and focused plus full SwiftPM tests are green.
- No raw geometry or side-specific payload is emitted in resolver warnings or
  metrics.
