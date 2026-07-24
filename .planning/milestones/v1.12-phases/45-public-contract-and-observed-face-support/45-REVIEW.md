---
phase: 45-public-contract-and-observed-face-support
reviewed: 2026-07-23T07:02:05Z
depth: standard
files_reviewed: 16
files_reviewed_list:
  - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
  - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
  - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
  - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
  - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
  - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift
  - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
  - DESIGN.md
  - PLANS.md
  - PRODUCT_SENSE.md
  - RELIABILITY.md
  - SECURITY.md
findings:
  critical: 1
  warning: 1
  info: 0
  total: 2
status: issues_found
---

# Phase 45: Code Review Report

**Reviewed:** 2026-07-23T07:02:05Z
**Depth:** standard
**Files Reviewed:** 16
**Status:** issues_found

## Summary

The iteration-3 median-intersection fix and aggregate-only mirrors on the three detection-layer carriers are present and covered by focused regressions. The review is not clean: the adapter copies the protected observations into effects-layer semantic carriers that still use Swift's default structural reflection, reopening the same raw-coordinate disclosure through `Mirror` and `dump`. Two authoritative owner documents also retain obsolete Phase 41 inventory and pre-fix Phase 45 verification counts.

Verification performed:

- `BeautyFaceGeometryAdapterTests` — PASS, 31 executed, 1 opt-in integration skip, 0 failures.
- `VisionFaceDetectorTests` — PASS, 20 executed, 2 opt-in integration skips, 0 failures.
- Face-support boundary checker — PASS, 36/36 self-tests and 13/13 live checks.
- `git diff --check` — PASS.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: Effects-layer semantic carriers reopen raw-coordinate reflection

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift:48-67`, `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift:90-142`

**Issue:** Commit `49ff737` adds aggregate-only `CustomReflectable` implementations to `BeautyObservedFaceSupport`, `BeautyFaceObservation`, and `VisionDetectionObservation`, but the adapter then copies the same biometric-adjacent values into `BeautyFaceSemanticSupport`. That type stores the raw contour, optional median, and apex index without controlling either its textual or structural representation. Its enclosing `FaceGeometry` also uses default reflection and stores `observedFaceSupport`, bounds, and multiple coordinate arrays. Consequently, `Mirror(reflecting:)` or `dump` on either effects-layer value recursively exposes raw derived coordinates, bounds, and semantic indices. The new reflection regressions cover only the three detection-layer carriers, so they do not exercise this downstream representation. This contradicts `SECURITY.md:130-133` and the Phase 45 closeout assertion that descriptions, structural reflection, and dumps expose aggregate counts only.

**Fix:** Give every sensitive effects-layer carrier, including `BeautyFaceSemanticSupport` and `FaceGeometry`, fixed aggregate-only `CustomStringConvertible`, `CustomDebugStringConvertible`, and `CustomReflectable` representations (or introduce a non-reflectable diagnostic wrapper and prevent these values from entering generic diagnostics). Do not include bounds, indices, coordinates, or nested coordinate-bearing values among mirror children. Add effects tests that call `String(describing:)`, `String(reflecting:)`, `Mirror(reflecting:)`, and `dump` on sentinel-filled `BeautyFaceSemanticSupport` and complete `FaceGeometry` values and assert that no sentinel coordinate, `SIMD2`, bounds value, or apex index appears.

```swift
extension BeautyFaceSemanticSupport: CustomReflectable {
    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "contourCount": contour.count,
                "medianLineCount": medianLine?.count ?? 0,
                "centerlineEligible": centerlineEligible,
            ],
            displayStyle: .struct
        )
    }
}
```

Apply the same aggregate-only boundary to `FaceGeometry`; protecting only the nested support value is insufficient because its other stored geometry is also coordinate-bearing.

## Warnings

### WR-01: Authoritative design and reliability records still contradict the final implementation

**Classification:** WARNING

**File:** `DESIGN.md:71`, `RELIABILITY.md:209`

**Issue:** `DESIGN.md` still calls the Phase 41 inventory the “current” model and specifies 48 stored fields, even though Phase 45 makes the current contract exactly 52 stored fields. `RELIABILITY.md` still records pre-fix evidence—34/34 checker self-tests, 18/18 detector tests, 27/27 adapter tests, 48/48 complete detection tests, and 347/347 full-suite tests—while the final closeout evidence is 36/36, detector 20 executed with 2 skips, adapter 31 executed with 1 skip, complete detection 50 executed with 2 skips, and full suite 353 executed with 3 skips. Commit `1c269a8` updates `PLANS.md` and `SECURITY.md` but leaves these two owner documents internally inconsistent with the code and the final ledger.

**Fix:** Change `DESIGN.md:71` to either identify 48 fields explicitly as a historical Phase 41 snapshot or state the current 52-field inventory (51 numeric plus `filterId`). Replace the Phase 45 evidence in `RELIABILITY.md:209` with the exact final execution/skip counts used by `PLANS.md:42`, preserving the distinction between executed tests, opt-in skips, and failures.

---

_Reviewed: 2026-07-23T07:02:05Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
