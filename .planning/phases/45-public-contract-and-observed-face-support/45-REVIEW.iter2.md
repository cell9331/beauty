---
phase: 45-public-contract-and-observed-face-support
reviewed: 2026-07-23T06:02:02Z
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
  critical: 4
  warning: 1
  info: 0
  total: 5
status: issues_found
---

# Phase 45: Code Review Report

**Reviewed:** 2026-07-23T06:02:02Z
**Depth:** standard
**Files Reviewed:** 16
**Status:** issues_found

## Summary

The public 52-field lifecycle is wired consistently, and the focused adapter suite passes 27/27. The observed-face support path is not ready to ship, however: legitimate small faces can be rejected against inflated bounds, reversed and self-intersecting paths can be promoted as valid semantic evidence, and raw coordinate payloads still have an implicit reflective diagnostic representation. The real-Vision aggregate tests also make the normal regression gate dependent on host services and framework output.

Verification performed:

- `BeautyFaceGeometryAdapterTests` — PASS, 27/27, after rerunning outside the managed sandbox required by SwiftPM/Apple Vision.
- `git diff --check 71f7252^..HEAD` over the exact review scope — PASS.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: Small real faces are validated against inflated synthetic bounds

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift:40-46`

**Issue:** `makeGeometry` passes `makeBounds(from:)` into observed-support validation, but `makeBounds` clamps every width and height to at least `0.05` at lines 635-645 and 762-764. The detector accepts any finite positive face bounds. For a legitimate face with width `0.02` and a contour spanning 80% of that box, validation divides the real `0.016` contour span by the inflated `0.05` width and obtains `0.32`, incorrectly failing the documented `0.50` minimum. Height and cross-support distances are distorted the same way. This silently removes valid observed support for small/distant faces even though detection selected the face.

**Fix:** Keep the clamped bounds only for the legacy synthetic proxy. Derive a separate exact positive `FaceBounds` from `observation.imageBounds` for observed contour/median validation, without the `0.05` floor, and add tests with face boxes below `0.05` in each dimension.

```swift
let proxyBounds = makeBounds(from: observation)
let validationBounds = observation.imageBounds.flatMap(exactPositiveBounds)
let observedFaceSupport = validationBounds.flatMap {
    validatedFaceSupport(observation.observedFaceSupport, bounds: $0)
}
```

### CR-02: Adapter direction checks accept reversed noncanonical paths

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift:409-420`

**Issue:** Contour validation uses `abs(chordX)`, and median validation uses `abs(deltaY)` at lines 450-457. Consequently, right-to-left contours and bottom-to-top medians pass the same predicates as canonical paths. The test at `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift:570-600` explicitly locks that reversed paths are accepted unchanged. This contradicts the canonical right/down and “net-down” contracts in `DESIGN.md:147-148` and permits incorrect apex/centerline semantics when any package-internal observation bypasses or regresses detector canonicalization. A reversed median with a sufficiently dense contour can still satisfy chord position, apex distance, and interior-index checks and become `centerlineEligible`.

**Fix:** Enforce signed canonical projections at the adapter trust boundary (`chordX >= minimumFaceEndpointSeparation` and `deltaY >= minimumFaceMedianDown`), or canonicalize there before returning the stored semantic arrays. Replace the reversed-adapter acceptance test with rejection/canonical-output assertions; retain detector tests proving source winding convergence.

### CR-03: Envelope checks accept self-intersecting face contours as eligible

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift:390-435`

**Issue:** The claimed topology validation checks only count, exact-bit uniqueness, global unit bounds, bounding span, endpoint separation, and maximum distance from the endpoint chord. `faceInputIsValid` at lines 554-563 performs no segment-intersection or traversal-consistency check. A seven-point zigzag can be unique, span the required box, have sufficient curvature and endpoint separation, yet cross itself repeatedly and be returned as `contourEligible`. That malformed evidence will be consumed as ordered control geometry in Phase 46 and can generate incorrect or unsafe warps.

**Fix:** Reject intersections between non-adjacent open-path segments (the 32-point ceiling keeps this bounded), and add adversarial bow-tie/zigzag fixtures. If the intended contract also requires left-to-right traversal, enforce a tolerance-bounded monotonic projection after canonical direction is established.

### CR-04: Raw support coordinates remain printable through Swift reflection

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift:38-64`

**Issue:** The comments and `SECURITY.md:130-133` claim no diagnostic/raw-description surface, but ordinary Swift structs receive a reflective fallback representation. `String(describing:)`, string interpolation, XCTest failure output, and generic logging of `BeautyObservedFaceSupport`, `BeautyFaceObservation`, or `VisionDetectionObservation` can therefore include the full `CoordinatePoint` arrays even without `CustomStringConvertible`. Package access reduces exposure but does not prevent an internal log/error path from leaking biometric-adjacent coordinates.

**Fix:** Give the support and enclosing observation carriers explicit redacted `CustomStringConvertible` and `CustomDebugStringConvertible` implementations that expose only approved availability/count aggregates, and add tests covering interpolation and debug descriptions. Extend the boundary checker to reject unapproved interpolation/logging of these carrier types.

## Warnings

### WR-01: Required regression tests depend on live Vision behavior and repository-local fixture layout

**Classification:** WARNING

**File:** `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift:383-415`

**Issue:** This test and `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift:603-661` make the standard suite depend on Apple Vision host services, the current framework revision's landmark availability, and six files found by walking upward from `#filePath`. The phase summaries already record sandbox/host-service failures. A clean checkout on another supported Xcode/macOS revision can fail because Vision returns different optional median data, not because the deterministic mapping/validation contract regressed.

**Fix:** Move live portrait detection to a clearly marked opt-in integration suite. Keep the required unit gate deterministic by checking captured/injected package-only contour/median fixtures across the same six cases and metadata matrix; run the live Vision smoke separately on the pinned Apple host configuration.

---

_Reviewed: 2026-07-23T06:02:02Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
