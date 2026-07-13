---
phase: 35-public-contract-and-independent-geometry
reviewed: 2026-07-13T07:20:32Z
iteration: 2
depth: standard
head: 6bb48d5
fix_commits_reviewed:
  - 3cf59de
  - bfd7375
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
  critical: 2
  warning: 0
  info: 0
  total: 2
status: issues_found
---

# Phase 35: Code Review Report — Iteration 2

**Reviewed:** 2026-07-13T07:20:32Z
**Depth:** standard
**Files Reviewed:** 24
**Status:** issues_found

## Summary

The two fix commits improve the ordering substantially: validator-rejected root/tip requests are now removed before conflict resolution, and a completely absent legacy nose proxy no longer survives beside valid independent support. Public model compatibility, aggregate redaction, private support visibility, and the documented Phase 36/37 boundaries remain intact.

The fixes do not yet close the underlying mixed-output problem. Sanitization still uses availability flags that are coarser than the provider's actual per-field emission behavior. Consequently, one legacy field or one independent field can emit no control points while a sibling field makes the aggregate provider result nonempty; the non-rendering field then remains in effective strengths and may participate in conflict totals, counts, and scaling.

## Critical Issues

### CR-03: One aggregate legacy availability bit still lets non-rendering legacy fields survive mixed requests

**Files:** `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:13-35,52-57`; `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift:154-174,274-290`

**Issue:** Commit `bfd7375` defines `supportAvailability.legacy` as only `center(of: face.nose) != nil` and then zeros all four legacy fields only when that single bit is false. A nonempty legacy proxy is not sufficient for every legacy helper. For example, with a one-point `face.nose`, `legacy` is true, but `slimPoints` emits nothing because its left and right extrema are identical. If explicit root support is valid and `noseRootNarrowing` is also requested, the root points make the aggregate provider result nonempty. The resolver therefore marks `.nose` active and retains `noseSlim`; with face-shape or mouth work present, that non-rendering value also remains eligible for conflict accounting. This is the same mixed legacy/new masking class as the original CR-02, narrowed from an empty proxy to a per-field-insufficient proxy.

**Fix:** Replace the single legacy bit with per-field emission availability (at least `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge`), derived from the same prerequisites used by each helper, or return a per-field emission result from the provider. Sanitize each requested field before either conflict call. Add mixed regressions in which one legacy helper cannot emit while root or tip support can, and assert the unsupported legacy strength is zero and absent from weakened count/scale while the supported sibling remains active.

### CR-04: Root/tip support availability can be true even when the requested field cannot emit points

**Files:** `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:52-57,110-123,151-169`; `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift:163-173,219-222,280-290`

**Issue:** `supportAvailability(for:)` checks only structural root/tip support. Actual point generation has additional strength- and displacement-dependent failure guards. A structurally valid near-center root pair can pass `validatedRootPair`, yet `room - 0.0001` can be at or below `Float.ulpOfOne`, causing `rootNarrowingPoints` to return empty. Likewise, a valid fixture plus a positive public root/tip value just above `Float.ulpOfOne` can pass the resolver's nonzero test while its computed displacement fails the provider's `> Float.ulpOfOne` guard. If any legacy or sibling field emits points, the aggregate result is nonempty, so the failed independent strength survives. If face-shape work runs first, it can also affect conflict total/count/scale before the provider reveals that it emitted nothing. Thus the original CR-01 ordering defect remains for availability/output mismatches, and the root contracts' field-specific fail-closed claim is not fully true.

**Fix:** Make the pre-conflict check reflect actual requested-strength emission, not structural support alone. One robust approach is to generate or validate each requested field independently before conflict resolution, zero fields whose individual result is empty, then perform conflict resolution and final aggregate dispatch. Add regression cases for valid-but-non-emitting displacement and a mixed supported sibling, asserting exact exclusion from effective strengths and conflict metrics.

## Prior Finding Disposition

- Original CR-01 is fixed for root/tip supports rejected by the structural validators, but CR-04 shows the ordering contract is still incomplete when structural availability and actual emission disagree.
- Original CR-02 is fixed for an entirely empty `face.nose`, but CR-03 shows the replacement `legacy` flag is not sufficiently field-specific for partially usable legacy geometry.

## Verification

- PASS: `swift test --package-path BeautySDK --filter NoseWarpProviderTests` — 13/13.
- PASS: `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` — 18/18.
- PASS: `swift test --package-path BeautySDK --filter GeometryConflictResolverTests` — 8/8.
- PASS: `git diff --check 3cf59de^..bfd7375`.
- PASS: both independent fields still appear exactly three times in `GeometryConflictResolver` (scale, total, count).
- PASS: scoped public/SPI raw-geometry and network/commercial scans found no new exposure or dependency path.

The green focused tests do not cover either partial-emission mixed case described above.

---

_Reviewer: fresh independent GSD code review, iteration 2_
_Depth: standard_
