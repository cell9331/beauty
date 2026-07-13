---
phase: 35-public-contract-and-independent-geometry
source_review: .planning/phases/35-public-contract-and-independent-geometry/35-REVIEW.md
fixed_at: 2026-07-13T07:42:49Z
status: all_fixed
iteration: 3
fix_scope: critical_warning
findings_in_scope: 1
fixed: 1
skipped: 0
fix_commits:
  - 33665e6
findings_fixed:
  critical: 1
  warning: 0
  info: 0
  total: 1
---

# Phase 35 Code Review Fix Report — Iteration 3

The iteration-3 critical finding CR-05 is fixed.

## Fix

### CR-05: Conflict weakening could invalidate a preflight emission without final per-field sanitization

- Moved valid fresh-geometry conflict resolution ahead of face, eye, nose, and mouth provider dispatch so every downstream domain consumes the same final effective strengths.
- Added a deterministic monotonic convergence loop around the existing conflict resolver and provider-owned `NoseWarpFieldEmissions` contract.
- Each mask-changing pass removes newly non-emitting nose fields from the unscaled retained baseline, then recomputes conflict total, weakened count, scale, warnings, and final strengths. A pass can only remove work, and exactly six nose fields exist, so the implementation permits at most six mask changes and cannot loop indefinitely.
- Threshold-crossing `noseRootNarrowing`, `noseTipLift`, and both signed directions of `noseTipSize` now become exact zero. Their contribution is excluded from the recomputed conflict evidence, supported `noseSlim` work remains active, and final provider emissions exactly match the retained effective nose strengths.
- Warning behavior remains category-only: one `combined_geometry_weakened` warning remains, no `nose_inputs_missing` warning is emitted while a supported sibling continues, and aggregate scale/count metrics contain no raw geometry or field payload.
- Updated `DESIGN.md`, `RELIABILITY.md`, and `PLANS.md` with the bounded convergence and final-emission invariant.
- Commit: `33665e6` (`fix(35): converge nose conflict emissions`).

## Regression Evidence

- Root fixture: requested `0.000004` emits before weakening, crosses its displacement threshold after the initial scale, becomes zero, and is excluded from the final six-field conflict count/scale.
- Tip-lift fixture: requested `0.000003` follows the same displacement-threshold crossing and exclusion behavior.
- Signed tip-size fixture: both `+2 * Float.ulpOfOne` and `-2 * Float.ulpOfOne` emit before weakening, cross the provider strength threshold after scaling, and become zero without changing the retained sibling or diagnostic privacy.
- All three mixed-sibling regressions assert final `noseSlim` emission, exact final scale `1 / 2.70`, weakened count `6`, one combined warning, no nose-missing warning, active face-shape/nose domains, and equality between retained effective strengths and provider sanitization at final values.

## Verification

- PASS: `NoseWarpProviderTests` — 15/15 XCTest cases.
- PASS: `MissingLandmarkDegradationTests` — 24/24 XCTest cases.
- PASS: `GeometryConflictResolverTests` — 8/8 XCTest cases.
- PASS: `CombinedEffectSafetyTests` — 10/10 XCTest cases.
- PASS: `BeautyEffectResolverTests` — 14/14 XCTest cases.
- PASS: affected focused aggregate — 71/71 XCTest cases.
- PASS: `swift test --package-path BeautySDK` — 217/217 XCTest cases, zero failures.
- PASS: `git diff --check` before the fix commit.

## Status

All iteration-3 critical and warning findings are fixed. Public raw geometry/privacy boundaries, established warning/metric semantics, and Phase 36/37 non-claims remain unchanged. This report is intentionally left uncommitted for the orchestrator.
