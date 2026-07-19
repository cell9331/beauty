---
phase: 42-independent-eye-geometry-and-pipeline-integration
review: 42-REVIEW.md
status: fixed
fixed: 2026-07-16
---

# Phase 42 Review Fixes

## Fixed findings

1. **Field-local conflict sanitization** — `BeautyEffectResolver.resolveGeometryConflict` now carries the eye-sanitized retained baseline into the nose pass, then carries that result into the mouth pass. Unsupported eye fields cannot be reintroduced while valid non-eye siblings converge. `MissingLandmarkDegradationTests.testUnsupportedEyeFieldIsNotReintroducedIntoConflictBaselineWithValidSiblings` compares the malformed-eye request against an eye-omitted baseline and proves sibling strengths remain identical.
2. **Measured symmetry span/tilt** — `EyeWarpProvider.symmetryPoints` now validates finite/plausible semantic supports, moves centers toward the pair midpoint, scales each measured contour toward the paired span midpoint, and rotates contour offsets toward the paired tilt midpoint with a bounded blend. `EyeWarpProviderTests` covers span and tilt convergence, non-zero vectors, and implausible-span fail-closed behavior.
3. **Malformed symmetry contour fail-closed** — `symmetryPoints` now requires the semantic center and every contour point to be finite and within the image-normalized unit square before emitting center or contour work. An adversarial provider test proves fabricated finite scalar metadata cannot bypass malformed contour rejection.

4. **Behavioral evidence gaps** — Provider tests now assert distinct height/length/lid/corner source and direction semantics, opposite signed tilt vectors, pupil-local radial expansion, monotonic gaze correction and neutral dead-zone behavior. Degradation tests prove pupil-dependent fields zero locally while contour siblings remain accounted.

## Verification

- `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` — 14/14 passed.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` — 18/18 passed.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` — 39/39 passed.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` — 10/10 passed.
- `swift test --package-path BeautySDK` — 303/303 passed.
- `git diff --check` — passed.

The symmetry and resolver changes are logic fixes backed by focused regression tests; the phase verifier should re-run its independent semantic review before closing the review gate.
