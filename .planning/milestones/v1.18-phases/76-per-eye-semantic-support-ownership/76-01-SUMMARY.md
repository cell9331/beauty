---
phase: 76-per-eye-semantic-support-ownership
plan: "01"
subsystem: per-eye-support
tags: [semantic-owner, request-local, fail-closed, privacy]

# Dependency graph
requires:
  - phase: 75-semantics-and-genuine-evidence-contract
    provides: Frozen cosmetic authority, prohibited-proxy taxonomy, and exact-absence boundary.
provides:
  - Package-only independent left/right semantic support ownership.
  - Typed finite hard-contained support or source-exact no-op outcomes.
  - Aggregate-only descriptions and request-local support carriers.
affects: [phase 77 deterministic editor, phase 78 genuine evaluation, phase 79 closeout]

requirements-completed: [SUP-01, SUP-02]

# Metrics
duration: ~25min
completed: 2026-08-22
---

# Phase 76 Plan 01: Per-Eye Semantic Support Summary

## Accomplishments

- Added package-only request, approval, eye-outcome, and resolution carriers.
- Required an injected `@Sendable` semantic owner before any eye can become
  editable; landmarks only provide mapped envelopes and guard context.
- Validated finite image dimensions, confidence bounds, hard containment,
  unique in-bounds pixel indices, malformed envelopes, ambiguity, and typed
  rejection reasons.
- Kept left and right resolution paths independent and exposed only aggregate
  status/count diagnostics; no raw support is Codable or persistent.

## Verification

- `swift test --package-path BeautySDK --filter BeautyDetectionTests.UpperEyelidSemanticSupportTests`: 10/10 passed.
- Tests cover missing owner, missing/malformed landmarks, peer isolation,
  approval rejection, low confidence, non-finite data, duplicate/out-of-bounds
  pixels, hard-envelope violations, deterministic observation reuse, and
  aggregate-only diagnostics.
- `swift build --package-path BeautySDK` and `git diff --check`: passed.

## Scope boundary

The owner performs no coordinate conversion, stores no request support between
calls, and adds no public parameter, route, renderer case, preset, resource,
provider dependency, or Testing SPI. Orientation/mirror mapping remains owned
by the existing `CoordinateMapper` boundary and composition is verified by
Plan 02.
