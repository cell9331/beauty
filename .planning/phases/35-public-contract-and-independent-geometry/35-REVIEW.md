---
phase: 35-public-contract-and-independent-geometry
reviewed: 2026-07-13T07:48:07Z
iteration: 4
depth: standard
head: 4790f87
fix_commits_reviewed:
  - 8f8bda7
  - 05209b3
  - 33665e6
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

# Phase 35: Code Review Report — Final Fresh Review

**Reviewed:** 2026-07-13T07:48:07Z
**Depth:** standard
**Files Reviewed:** 24
**Status:** issues_found

## Summary

Commit `33665e6` correctly closes CR-05 for all six nose fields. Its retained-baseline loop is monotonic, can remove only nose fields, and terminates within the six-pass bound. Root, tip-lift, and both signed tip-size threshold crossings are removed before the final conflict total, weakened count, and scale are emitted; supported nose siblings continue; final nose provider eligibility agrees with retained effective nose strengths. Public model compatibility, package-only geometry, diagnostics redaction, dependency boundaries, and Phase 36/37 non-claims remain intact.

The fix also moved mouth-triggered conflict resolution ahead of mouth dispatch. That exposes the same threshold-crossing mismatch outside the six-field nose mask: a mouth value can participate in conflict evidence, scale below the resolver/provider eligibility threshold, and then bypass the mouth block without being zeroed or reported as skipped. This is a concrete regression from the pre-fix call placement.

## Critical Issues

### CR-06: Pre-dispatch conflict scaling can strand non-emitting mouth work in the final plan

**Files:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift:204-220,307-334,401-426`; `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift:16-55,74-99`; `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift:12-24`; `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift`; `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`

**Issue:** `hasMouthGeometryValues` is computed before conflict scaling and permits the new shared conflict pass to run. After scaling, however, line 307 recomputes `anyNonZero` and enters the mouth provider only when a mouth value remains above `Float.ulpOfOne`. Signed `mouthSize` and `mouthWidth` use that same threshold in `MouthWarpProvider`. If conflict scaling crosses it, the mouth dispatch block is skipped entirely: the scaled nonzero mouth strength remains in `effectiveStrengths`, `.mouth` is neither active nor skipped, `mouth_inputs_missing` is absent, and `weakenedCount` still includes the pre-scale mouth value. Thus the final plan describes weakened work which emits no mouth control points and provides no degradation evidence.

This path is reachable with valid fresh geometry. Request all four eye fields and all six nose fields at `1`, plus `mouthSize = 2 * Float.ulpOfOne`. The capped geometry total is approximately `3.1`, so the conflict scale is `0.32258064`. Final `mouthSize` becomes `7.690922e-08`, below `Float.ulpOfOne` (`1.1920929e-07`). A direct package-internal probe against the reviewed build produced:

- final `mouthSize = 7.690922e-08`;
- active domains only `eyes` and `nose`;
- no skipped domains and no `mouth_inputs_missing` warning;
- `combined_geometry_weakened`, scale `0.32258064`, and weakened count `11`, including the mouth value that final dispatch omitted.

Before `33665e6`, a mouth-only trigger entered the mouth block before its local conflict pass, then the empty provider result zeroed all mouth strengths, marked `.mouth` skipped, and emitted `mouth_inputs_missing`. Moving conflict ahead of dispatch changed that behavior. It also contradicts the repository's degradation contract that disabled face-dependent work must be represented honestly rather than left as an effective nonzero no-op.

**Fix:** Preserve the pre-conflict mouth-request flag through final dispatch, or add provider-owned per-field mouth emission sanitization/convergence analogous to the nose contract. After conflict, every retained mouth field must be eligible to emit; otherwise zero it before final metrics and domain classification, recompute conflict evidence if it contributed to total/count/scale, and emit the established aggregate mouth degradation signal when no supported mouth sibling remains. Add signed `mouthSize` and `mouthWidth` threshold-crossing regressions, including a supported sibling case, and assert final per-field provider eligibility, effective strengths, domains, warning count, scale, and weakened count agree.

## Confirmed Correct After Iteration 3

- The nose convergence loop removes at least one retained nose field on every changing pass, never re-adds a field, and returns a final resolution after at most six mask changes.
- Initial and post-conflict nose eligibility share `NoseWarpProvider.fieldEmissions`; invalid legacy/root/tip inputs and threshold-crossing root, tip-lift, and signed tip-size work cannot remain in final nose conflict evidence.
- Supported nose siblings remain active, and aggregate `combined_geometry_weakened` / `nose_inputs_missing` behavior stays category-only and redacted.
- `BeautyParameters` remains exactly 33 stored fields (32 numeric plus `filterId`); missing-key JSON and bundled presets remain neutral; both new values remain independent positive-only fields with provisional `0.25` caps.
- Explicit root/tip supports remain package-internal, validated before emission, non-aliasing, deterministic, finite, bounded, and fail-closed without legacy fallback.
- No public/SPI raw geometry, dependency, network/cloud/commercial, renderer/Demo, generated-artifact, archive, or product-promotion drift was found in the reviewed scope.

## Verification

- PASS: affected focused aggregate (`NoseWarpProviderTests`, `MissingLandmarkDegradationTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests`, `BeautyEffectResolverTests`) — 71/71 XCTest cases.
- PASS: `swift test --package-path BeautySDK` — 217/217 XCTest cases, zero failures.
- PASS: `git diff --check` before writing this report.
- PASS: direct package-internal probe reproduced CR-06 with valid fresh supports and the exact final values recorded above.

The green suite covers the corrected nose threshold crossings but has no mouth threshold-crossing case after the shared conflict pass.

---

_Reviewer: fresh independent GSD code review after iteration-3 fix_
_Depth: standard_
