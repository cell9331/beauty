---
phase: 35-public-contract-and-independent-geometry
source_review: .planning/phases/35-public-contract-and-independent-geometry/35-REVIEW.md
fixed_at: 2026-07-13T07:29:02Z
status: all_fixed
iteration: 2
fix_scope: critical_warning
findings_in_scope: 2
fixed: 2
skipped: 0
fix_commits:
  - 8f8bda7
  - 05209b3
findings_fixed:
  critical: 2
  warning: 0
  info: 0
  total: 2
---

# Phase 35 Code Review Fix Report — Iteration 2

Both critical findings from the iteration-2 Phase 35 review are fixed.

## Fixes

1. **CR-03: Aggregate legacy availability allowed non-rendering fields to survive mixed requests**
   - Replaced the aggregate legacy availability bit with `NoseWarpFieldEmissions`, a provider-owned result containing actual control-point output for each of the six nose fields.
   - Both resolver preflight and final provider dispatch consume that same per-field emission contract.
   - Legacy sanitization now zeros only the requested helper whose actual emission is empty; emitting legacy and independent siblings remain active.
   - Added a one-point legacy mixed regression proving `noseSlim == 0`, supported root work stays active, conflict scale is exactly `1 / (0.60 + 0.45 + 0.25)`, and weakened count is exactly `3`.
   - Commit: `8f8bda7` (`fix(35): sanitize legacy nose fields by emission`).

2. **CR-04: Structural root/tip availability did not reflect requested-strength emission**
   - Removed resolver-only structural root/tip availability checks.
   - Root/tip preflight now uses the provider's actual field emission, including strength thresholds, computed displacement, remaining centerline room, target validation, and support validation.
   - Added provider and resolver regressions for a structurally valid near-center root pair with non-emitting displacement and a positive tip request whose displacement is below the emission threshold.
   - Mixed tests prove the failed field is zero before conflict accounting, its supported sibling remains active, scale is exactly `1 / (0.60 + 0.45 + 0.25)`, and weakened count is exactly `3`.
   - Commit: `05209b3` (`fix(35): exclude non-emitting independent nose work`).

## Verification

- PASS: `NoseWarpProviderTests` — 15/15 XCTest cases.
- PASS: `MissingLandmarkDegradationTests` — 21/21 XCTest cases.
- PASS: `GeometryConflictResolverTests` — 8/8 XCTest cases.
- PASS: `CombinedEffectSafetyTests` — 10/10 XCTest cases.
- PASS: `BeautyEffectResolverTests` — 14/14 XCTest cases.
- PASS: affected focused aggregate — 68/68 XCTest cases.
- PASS: `swift test --package-path BeautySDK` — 214/214 XCTest cases, zero failures.
- PASS: `git diff --check` before both fix commits.

## Status

All iteration-2 critical and warning findings are fixed. Public raw geometry/privacy boundaries, package dependencies, and Phase 36/37 non-claims remain unchanged. This report is intentionally left uncommitted for the orchestrator.
