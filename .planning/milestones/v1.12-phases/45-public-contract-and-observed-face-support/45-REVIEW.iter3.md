---
phase: 45-public-contract-and-observed-face-support
reviewed: 2026-07-23T06:37:43Z
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
  critical: 2
  warning: 1
  info: 0
  total: 3
status: issues_found
---

# Phase 45: Code Review Report

**Reviewed:** 2026-07-23T06:37:43Z
**Depth:** standard
**Files Reviewed:** 16
**Status:** issues_found

## Summary

Iteration 1 resolves CR-01 (exact observed bounds), CR-02 (signed canonical direction), the contour half of CR-03, and WR-01 (opt-in live Vision smoke). It does not fully close the review: the equivalent median-line trust boundary still accepts self-intersecting ordered geometry, and CR-04's new string/debug descriptions do not redact Swift's `dump`/`Mirror` reflection path. The authoritative closeout records also retain pre-fix test and checker counts.

Verification performed:

- `BeautyFaceGeometryAdapterTests` — PASS, 30 executed, 1 opt-in integration skip, 0 failures.
- `VisionFaceDetectorTests` — PASS, 20 executed, 2 opt-in integration skips, 0 failures.
- Face-support boundary checker — PASS, 36/36 self-tests and 13/13 live checks.
- `git diff --check` — PASS.
- A standalone Swift reflection probe confirmed that `CustomStringConvertible` plus `CustomDebugStringConvertible` still causes `dump` to enumerate and print stored fields unless the type also controls its mirror.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: Self-intersecting median paths can still become centerline-eligible

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift:443-466`

**Issue:** Commit `b7ba5e0` added `facePathHasNonAdjacentIntersections` to `validatedFaceContour`, but `validatedFaceMedianLine` still checks only count, point validity/uniqueness, and signed endpoint displacement. A five-point bow-tie such as `(0.50,0.20) → (0.20,0.80) → (0.80,0.80) → (0.20,0.50) → (0.50,0.80)` is unique, finite, closed-unit, and has a valid `0.60` net-down projection, so it passes median validation despite multiple non-adjacent segment crossings. With the last point near a valid contour apex it can also satisfy the chord-position, apex-distance, and interior-index predicates and become `centerlineEligible`. This leaves the same malformed ordered-geometry risk identified by the original CR-03 on the independently optional median path that Phase 46 will consume.

**Fix:** Apply the bounded non-adjacent intersection rejection to median paths as well, and add a regression that proves an otherwise-valid crossing median preserves contour-only eligibility but cannot become centerline-eligible.

```swift
guard (minimumFaceMedianPointCount...maximumFaceMedianPointCount).contains(input.count),
      faceInputIsValid(input),
      !facePathHasNonAdjacentIntersections(input),
      let local = faceRelativePoints(input, bounds: bounds)
else {
    return nil
}
```

### CR-02: Reflection still exposes raw support coordinates despite redacted descriptions

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift:56-109`

**Issue:** Commit `136c1d9` makes `String(describing:)`, interpolation, and `String(reflecting:)` redacted, but `CustomStringConvertible` and `CustomDebugStringConvertible` do not control structural reflection. Swift's `dump` prints the redacted heading and then recursively enumerates stored properties through `Mirror`; for `BeautyObservedFaceSupport`, `BeautyFaceObservation`, and `VisionDetectionObservation`, that exposes the `CoordinatePoint` arrays, bounds, stable ID, and confidence. A direct probe produced `redacted` for both string APIs but still printed the stored `secret` field under `dump`. The new test at `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift:344-395` checks only string conversion, so it locks a narrower guarantee than `SECURITY.md:133`, which forbids raw coordinates in descriptions, diagnostics, snapshots, and logs. The original CR-04 is therefore not fully resolved.

**Fix:** Also conform each carrier to `CustomReflectable` with a fixed aggregate-only mirror (or redesign the diagnostic wrapper so sensitive carriers are never structurally reflected), and add `dump`/`Mirror` regressions that scan for sentinel coordinates, stable IDs, bounds, and `CoordinatePoint`/`CoordinateRect`.

```swift
extension BeautyObservedFaceSupport: CustomReflectable {
    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "contourCount": contour?.count ?? 0,
                "medianLineCount": medianLine?.count ?? 0,
            ],
            displayStyle: .struct
        )
    }
}
```

## Warnings

### WR-01: Authoritative closeout evidence still reports pre-fix verification counts

**Classification:** WARNING

**File:** `PLANS.md:41-42`

**Issue:** The Phase 45 closeout still says the face carriers are “non-diagnostic” and records the pre-fix 34/34 checker, 27 adapter tests, 18 detector tests, and 347 full-suite tests. The current implementation intentionally exposes redacted aggregate diagnostic descriptions, while the fix report and fresh checks report 36/36, 30 adapter tests, 20 detector tests, and 352 full-suite tests. `SECURITY.md:135` likewise claims 34 self-tests. These are authoritative owner/ledger files in the persisted review scope, so leaving them stale makes the repository's verification record contradict the code it is meant to govern.

**Fix:** Update the Phase 45 entries in `PLANS.md` and `SECURITY.md` to distinguish “no raw diagnostic payload” from the approved aggregate descriptions and record the post-fix counts, including opt-in integration skips where relevant.

---

_Reviewed: 2026-07-23T06:37:43Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
