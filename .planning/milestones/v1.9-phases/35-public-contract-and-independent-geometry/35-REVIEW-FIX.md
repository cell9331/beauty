---
phase: 35-public-contract-and-independent-geometry
source_review: .planning/phases/35-public-contract-and-independent-geometry/35-REVIEW.md
fixed_at: 2026-07-13T07:58:25Z
status: all_fixed
iteration: 4
fix_scope: critical_warning
findings_in_scope: 1
fixed: 1
skipped: 0
fix_commits:
  - f6f9172
findings_fixed:
  critical: 1
  warning: 0
  info: 0
  total: 1
---

# Phase 35 Code Review Fix Report — Iteration 4

The iteration-4 critical finding CR-06 is fixed.

## Fix

### CR-06: Pre-dispatch conflict scaling could strand non-emitting mouth work

- Added a provider-owned `MouthWarpFieldEmissions` contract for `mouthSize`, `mouthWidth`, and `smile`; initial fresh-geometry preflight, conflict convergence, and final dispatch now use the same per-field output eligibility.
- Extended the existing monotonic retained-baseline convergence from the six nose fields to the combined nine nose/mouth fields. A changing pass only removes work, so the loop remains deterministic and bounded while preserving the already-correct six-field nose behavior.
- A mouth field that emits before weakening but crosses below its provider threshold after scaling is now exact zero. The resolver recomputes the conflict total, weakened count, scale, warning, and final strengths without that field.
- Preserved the pre-conflict mouth-request flag for final domain classification. When no mouth sibling remains, `.mouth` is skipped with one redacted `mouth_inputs_missing` warning and aggregate skipped-domain metric; an emitting sibling instead keeps `.mouth` active without the missing-input warning.
- Updated `DESIGN.md`, `RELIABILITY.md`, and `PLANS.md` with the shared final-emission invariant and degradation behavior.
- Commit: `f6f9172` (`fix(35): converge mouth conflict emissions`).

## Regression Evidence

- Signed `mouthSize`: both `+2 * Float.ulpOfOne` and `-2 * Float.ulpOfOne` emit before conflict weakening, cross below the provider threshold under the valid all-eye/all-nose fixture, become zero, and are excluded from final conflict evidence.
- Signed `mouthWidth`: both directions use the same reachable threshold-crossing proof.
- No-sibling cases assert final zero, empty field emission, provider sanitization equality, active eye/nose domains, skipped mouth domain, one `mouth_inputs_missing`, one `combined_geometry_weakened`, final weakened count `10`, and exact scale `1 / 3.10`.
- Mixed cases retain the other supported signed mouth field. They assert its exact cap-scaled effective strength and non-empty emission, active eye/nose/mouth domains, no skipped mouth domain or missing-input warning, one combined warning, final weakened count `11`, and exact scale `1 / 3.45`.
- Every case runs the existing redaction assertion; no raw geometry, field values, provider types, or paths were added to warnings or metrics.
- Existing root, tip-lift, and signed tip-size convergence regressions remain green.

## Verification

- PASS: `MouthWarpProviderTests` — 6/6 XCTest cases.
- PASS: `NoseWarpProviderTests` — 15/15 XCTest cases.
- PASS: `MissingLandmarkDegradationTests` — 26/26 XCTest cases.
- PASS: `GeometryConflictResolverTests` — 8/8 XCTest cases.
- PASS: `CombinedEffectSafetyTests` — 10/10 XCTest cases.
- PASS: `BeautyEffectResolverTests` — 14/14 XCTest cases.
- PASS: affected focused aggregate — 79/79 XCTest cases.
- PASS: `swift test --package-path BeautySDK` — 219/219 XCTest cases, zero failures.
- PASS: `git diff --check` before the fix commit and after the final regression assertion update.
- PASS: scoped added-line privacy scan and public/package surface scan found no new raw diagnostic payload or exported mouth-provider contract.

## Status

All iteration-4 critical and warning findings are fixed. Public raw geometry/privacy boundaries, established warning/metric semantics, the bounded nose convergence, and Phase 36/37 non-claims remain unchanged. This report is intentionally left uncommitted for the orchestrator.
