---
phase: 35-public-contract-and-independent-geometry
reviewed: 2026-07-13T07:10:48Z
depth: standard
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

# Phase 35: Code Review Report

**Reviewed:** 2026-07-13T07:10:48Z
**Depth:** standard
**Files Reviewed:** 24
**Status:** issues_found

## Summary

The public model, Codable compatibility, independent root/tip vectors, private geometry boundary, and redacted facade surface are internally consistent. Two fail-closed ordering defects remain in mixed-geometry cases: unsupported new support can influence conflict weakening before it is zeroed, and valid new support can conceal missing legacy nose output while leaving legacy effective strengths nonzero.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: Unsupported root/tip strengths participate in conflict weakening before support validation

**File:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift:197-200`

**Issue:** The face-shape branch runs `GeometryConflictResolver` before the nose branch checks `supportAvailability` at lines 266-273. An unsupported `noseRootNarrowing` or `noseTipLift` therefore contributes to the total, weakened count, warning, and scale applied to otherwise valid geometry, and is only zeroed afterward. For example, capped `faceSlim = 0.60`, `faceSmall = 0.45`, and an invalid capped root request `= 0.25` produce scale `1 / 1.30`; after the root is discarded, the valid face fields remain over-weakened compared with the `1 / 1.05` scale their usable work warrants. This contradicts the documented field-specific fail-closed contract and makes aggregate conflict metrics describe work that cannot render.

**Fix:** Validate and sanitize new nose supports once, before either conflict-resolution call can observe the strengths (after freshness handling and only when usable geometry exists). Reuse that availability result in the nose branch. Add a regression test combining malformed root/tip support with enough valid face-shape fields to cross the threshold, asserting that the invalid field is excluded from the scale and weakened count.

### CR-02: Valid new support can mask missing legacy nose inputs and preserve non-rendering legacy strengths

**File:** `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:18-47`

**Issue:** When legacy nose work is requested but `face.nose` has no center, the provider silently emits no legacy points. If a new root or tip request has valid explicit support, its points make the aggregate result nonempty, so the resolver marks `.nose` active and retains legacy strengths such as `noseBridge` or `noseTipSize`. Rendering calls the provider again and still produces only the new-field points. This regresses the prior missing-legacy behavior and returns effective strengths for effects that did not render; the aggregate `points.isEmpty` check in `BeautyEffectResolver.swift:274-282` cannot detect the partial failure.

**Fix:** Expose legacy-support availability (or per-field emission status) alongside root/tip availability and sanitize requested legacy strengths when their legacy proxy is unavailable, while preserving valid independent root/tip work. Add a mixed regression case with empty `face.nose`, valid explicit root/tip support, and both legacy plus new requests; assert the new field remains active but all unsupported legacy strengths are zero and contribute no false effective state or conflict accounting.

---

_Reviewed: 2026-07-13T07:10:48Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
