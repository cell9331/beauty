---
phase: 42-independent-eye-geometry-and-pipeline-integration
plan: "01"
subsystem: eye-warp-provider
tags: [eye, geometry, provider, provisional-caps]
requires: [41-public-contract-and-observed-eye-support]
provides: [fourteen-named-eye-emissions]
affects: [BeautyEffectResolver, GeometryConflictResolver]
requirements-completed: [EYE-08, EYE-09, EYE-10, EYE-11, EYE-12, EYE-13, EYE-14]
status: complete
---

# Phase 42 Plan 01: Independent Eye Provider Summary

Added ten provisional Phase 42 caps and the fourteen-field `EyeWarpFieldEmissions` surface. Contour-local height, length, lid, tilt, and corner vectors use validated semantic supports; pupil size and gaze require a validated pupil; symmetry is evidence-gated and neutral-pair safe. Legacy nil observed support continues to use the shipped coarse fixture path.

## Commits and verification

- `84c1428` — provisional caps, effective strengths, and fourteen provider emissions.
- `719346f` — focused named-emission/evidence-gating coverage (added during validation).
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` — 9/9 passed.

## Deferred boundaries

This plan does not claim renderer output/gallery evidence (Phase 43), final natural cap calibration, promotion, or owner-contract synchronization (Phase 44).

## Self-Check: PASSED

Provider source compiles, focused tests pass, and no public support/result or new target/dependency was introduced.
