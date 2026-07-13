---
phase: 35-public-contract-and-independent-geometry
reviewed: 2026-07-13T07:35:39Z
iteration: 3
depth: standard
head: 0130e3d
fix_commits_reviewed:
  - 8f8bda7
  - 05209b3
files_reviewed: 24
files_reviewed_list:
  - ARCHITECTURE.md
  - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
  - BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift
  - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
  - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift
  - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
  - DESIGN.md
  - PLANS.md
  - PRODUCT_SENSE.md
  - RELIABILITY.md
  - SECURITY.md
findings:
  critical: 1
  warning: 0
  info: 0
  total: 1
status: issues_found
---

# Phase 35: Code Review Report — Iteration 3

**Reviewed:** 2026-07-13T07:35:39Z
**Depth:** standard
**Files Reviewed:** 24
**Status:** issues_found

## Summary

The iteration-2 fixes correctly replace coarse structural availability with a provider-owned six-field emission result. At the strengths passed to the initial resolver preflight, one-point legacy support, near-center root support, tiny tip displacement, invalid independent support, and mixed supported siblings are now sanitized per field. The new regressions also correctly prove exclusion from the first conflict total, weakened count, and scale for fields that are already non-emitting at preflight time. Public model compatibility, facade redaction, privacy, dependency boundaries, and Phase 36/37 non-claims remain intact.

The contract is not identical between pre-conflict sanitization and final provider dispatch, however, because the resolver calls the same provider function with different strengths. Conflict weakening can move a field from emitting to non-emitting after the only sanitization pass. An emitting sibling then masks the dropped field in the aggregate provider result, leaving the non-rendering strength in the plan and its pre-conflict contribution in conflict metrics.

## Critical Issues

### CR-05: Conflict weakening can invalidate a preflight emission without final per-field sanitization

**Files:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift:154-165,205-214,266-282`; `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:18-38,43-86,138-207`; `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift:16-55`; `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift:273-381`; `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift:257-329`; `DESIGN.md:117`; `RELIABILITY.md:173`; `PLANS.md:45-54`

**Issue:** The resolver computes `fieldEmissions` once at lines 163-165 and sanitizes the capped/reuse-adjusted strengths. When face-shape work is present, `GeometryConflictResolver` then scales every geometry field at lines 211-214. Final nose dispatch at lines 272-273 recomputes `fieldEmissions` from these smaller strengths, but only checks whether the aggregate point array is empty. `noseTipSize`, `noseRootNarrowing`, and `noseTipLift` all have strength/displacement thresholds, so a field can emit during preflight and become empty after scaling. If `noseSlim`, another legacy helper, or an independent sibling still emits, the aggregate nose result is nonempty: the nose domain remains active, no `nose_inputs_missing` warning is produced, and the now non-rendering field remains nonzero in `effectiveStrengths`. Its original value also remains in the conflict total and `weakenedCount`, so supported siblings are over-weakened and the scale/count metrics describe work that final dispatch did not emit.

This is a concrete fixture path. With the existing `.fixture`, request all five face-shape fields at `1`, `noseSlim: 1`, and `noseRootNarrowing: 0.000004`. The root preflight displacement is `1.6000001e-07`, above `Float.ulpOfOne` (`1.1920929e-07`), so root is retained. The conflict total is `2.7000039`, scale is `0.37036985`, and weakened count is `7`. Final root strength is `1.4814794e-06`, whose displacement is `5.9259182e-08`, so final root emission is empty. `noseSlim` still emits, masking the root failure; the plan retains the root strength and the seven-field conflict evidence even though only the sibling nose field dispatches. The same threshold-crossing class is reachable for tiny `noseTipLift` and signed `noseTipSize`.

The current tests cover fields that are non-emitting before conflict and ordinary capped fields that remain well above the thresholds after conflict. They do not compare each preflight field emission with each final field emission across a threshold-crossing scale. Consequently, the current statements in `DESIGN.md`, `RELIABILITY.md`, and the iteration-2 completion entry in `PLANS.md` overstate that non-emitting work cannot affect totals, scale, or weakened count.

**Fix:** Make final emission eligibility and conflict accounting converge on the same six-field set. For example, preserve the sanitized pre-conflict baseline, resolve conflicts, recompute provider emissions at the resulting strengths, zero any newly non-emitting fields, and recompute conflict totals/count/scale from the baseline without those fields; repeat with a strict six-field bound until no emission mask changes. Alternatively, make provider emission eligibility invariant under conflict scaling while preserving safe output semantics. Add root, tip-lift, and signed-tip threshold-crossing mixed-sibling regressions that assert the final field is zero, the emitting sibling remains active, conflict total/count/scale exclude the dropped field, warning/metric behavior is intentional and redacted, and final per-field emissions exactly match retained effective strengths.

## Prior Finding Disposition

- CR-03 is fixed for legacy fields that are non-emitting at the initial preflight strength, including the one-point `noseSlim` mixed case.
- CR-04 is fixed for root/tip fields that are non-emitting at the initial preflight strength, including near-center root and tiny tip cases.
- CR-05 is a remaining post-preflight execution path: conflict scaling changes the strength before final provider dispatch, so the shared function alone does not guarantee a shared per-field result.

## Verification

- PASS: affected focused aggregate (`NoseWarpProviderTests`, `MissingLandmarkDegradationTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests`, `BeautyEffectResolverTests`) — 68/68 XCTest cases.
- PASS: `swift test --package-path BeautySDK` — command exited successfully with the current 214-test suite.
- PASS: `git diff --check`.
- PASS: exact public inventory remains 33 stored fields; bundled presets still contain neither new key.
- PASS: both independent fields remain present in all public/effective/cap/resolver/provider/conflict seams; each appears once in conflict scaling, total, and count.
- PASS: scoped public/SPI raw-geometry, active-source privacy, dependency, network/cloud/commercial, Demo/renderer, and archive-drift checks found no new exposure or execution path.
- PASS: direct Swift arithmetic reproduced the CR-05 fixture thresholds: preflight emits (`1.6000001e-07`), post-conflict dispatch does not (`5.9259182e-08`).

The green test suite does not exercise the post-conflict emission-mask transition described above.

---

_Reviewer: fresh independent GSD code review, iteration 3_
_Depth: standard_
