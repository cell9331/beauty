# Phase 42 — Existing Patterns

## Provider Field-Emission Pattern

`NoseWarpFieldEmissions` and `MouthWarpFieldEmissions` are the canonical
patterns. They expose one immutable array per named field, concatenate arrays in
`points`, and provide `sanitizing(_:)` that clears only strengths whose own
emission is empty. `EyeWarpProvider` should follow this shape for fourteen
fields, with no aggregate fallback that hides field-local eligibility.

## Local Support Validation

`BeautyFaceGeometryAdapter` validates support once and stores semantic subsets on
`FaceGeometry`. Providers should consume `leftEyeSupport` and
`rightEyeSupport`, not re-run Vision coordinate math or inspect raw Vision
objects. The existing `FaceGeometry` scalar arrays remain a compatibility
fallback only when the observed payload is nil.

## Resolver Ordering

`BeautyEffectResolver.resolve` normalizes/caps first, applies reused/stale
policy, runs provider preflight before conflict convergence, then computes
active/skipped domains and metrics. New eye fields must enter the same ordering:
preflight sanitization before totals, conflict recomputation from one retained
baseline, final provider sanitization before domain/metric accounting.

## Conflict Convergence

`GeometryConflictResolver` uses one total threshold and scales fields together.
The resolver's iterative recomputation of nose/mouth emissions is monotone and
bounded. Extend the exact same mask-and-recompute pattern to eye emissions and
bound the combined eye/nose/mouth removal count; do not introduce a second
conflict baseline or per-provider scale pass.

## Redacted Diagnostics

Warnings and metrics in `BeautyEffectResolver` contain only stable reason codes,
aggregate domain/count values, and scales. Do not add support coordinates,
side-specific labels, pupil offsets, or contour-derived values to
`BeautyEffectPlan`, diagnostics, or the public `BeautySDK` facade.

## Test Fixture Pattern

Existing provider tests use `@testable import BeautyEffects`, `FaceGeometry`
fixtures, and direct `WarpControlPoint` assertions. Existing degradation tests
exercise missing sides and redaction through `BeautyEffectResolver.resolve`.
Phase 42 should add synthetic semantic-support fixtures and table-driven
field-isolation assertions, then run the focused suites and full SwiftPM suite.

