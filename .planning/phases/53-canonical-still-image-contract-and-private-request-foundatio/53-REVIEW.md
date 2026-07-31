---
phase: 53-canonical-still-image-contract-and-private-request-foundatio
reviewed: 2026-07-31T07:33:32Z
depth: standard
files_reviewed: 19
files_reviewed_list:
  - BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift
  - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
  - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
  - BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift
  - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
  - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
  - BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift
  - BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
  - BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift
  - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
  - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
findings:
  critical: 2
  warning: 2
  info: 0
  total: 4
status: issues_found
---

# Phase 53: Code Review Report

**Reviewed:** 2026-07-31T07:33:32Z
**Depth:** standard
**Files Reviewed:** 19
**Status:** issues_found

## Summary

The canonical still-image and request-local foundation contains two correctness defects at its central trust/support boundaries. Near-opaque input can be quantized to fully opaque and admitted despite the declared reject-all-transparency policy, and the new local-support route still applies the legacy all-geometry landmark gate before region-local support can be mapped. Two additional lifecycle/test-oracle defects undermine the documented context-reuse and exactly-once/request-isolation evidence.

The focused command `swift test --package-path BeautySDK --filter 'BeautyCanonicalStillImageTests|BeautyEngineLocalRetouchFoundationTests|StillImageRequestSupportTests'` passed 27/27. That result does not cover the fractional-alpha input or partial-landmark local-support cases below, and several of its lifecycle counters are synthesized rather than observed.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: RGBA8 quantization admits slightly transparent input as opaque

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift:119-145`

**Issue:** The canonicalizer renders the source directly to 8-bit RGBA and only then relies on `BeautyCanonicalStillImage` to check whether every alpha byte equals 255. Alpha values sufficiently close to 1 are rounded to 255 during this render, so a genuinely transparent source is silently forced opaque and reaches Vision. A direct Core Image reproduction with source alpha `0.999` produced `[255, 0, 0, 255]` in `.RGBA8`. This violates the Phase 53 contract that any transparent pixel fails closed and makes the validation result depend on quantization rather than source opacity.

**Fix:** Validate minimum source alpha before the lossy RGBA8 render, using a float/half-float alpha reduction over the normalized extent, then construct the canonical carrier only after exact opacity has been established. Keep the final byte scan as defense in depth and add cases immediately below 1:

```swift
let minimumAlphaImage = normalized.applyingFilter(
    "CIAreaMinimumAlpha",
    parameters: [kCIInputExtentKey: CIVector(cgRect: normalized.extent)]
)
let minimumAlpha = try renderMinimumAlphaAsFloat(minimumAlphaImage, context: context)
guard minimumAlpha == 1 else {
    throw BeautyError.invalidInput
}

// Only now perform the canonical .RGBA8 render.
```

Add regression inputs with floating alpha such as `0.999`, `nextDown(1)`, and a mixed image containing one near-opaque pixel; each must fail before detector/support invocation.

### CR-02: The local-support path discards valid region support behind the legacy geometry gate

**Classification:** BLOCKER

**File:** `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift:223-225`

**Issue:** `BeautyEngineGeometryDetection` now calls the detector when `requiresLocalSupport` is true, but `VisionFaceDetector.summarize` still filters every observation through `landmarks.hasRequiredGeometry`. That predicate requires face contour, both eyes, nose, and outer lips. Consequently, a high-confidence face with valid outer/inner lip support but a missing nose or eye is discarded before `mapLipRegion` runs, and the request context receives no valid lip support. This contradicts the region-local failure contract: teeth support requires actual lip regions, not unrelated full geometry, and an unrelated missing landmark must not globally erase valid support.

**Fix:** Make detector eligibility explicit for the request purpose. Preserve the existing full-geometry predicate for legacy geometry-only calls, but let admitted local-support calls map/select high-confidence observations and validate each demanded support region independently:

```swift
enum DetectionPurpose {
    case geometry
    case localSupport
    case geometryAndLocalSupport
}

let confidenceEligible = detections.filter { $0.confidence >= minimumConfidence }
let candidates: [VisionDetectionObservation]
switch purpose {
case .geometry:
    candidates = confidenceEligible.filter(\.landmarks.hasRequiredGeometry)
case .localSupport, .geometryAndLocalSupport:
    candidates = confidenceEligible
}
```

The geometry resolver can still zero geometry domains when required groups are missing, while the selected request observation retains independently valid lip/eye/brow support. Add a facade-level test with valid outer/inner lips and each unrelated required geometry group missing in turn.

## Warnings

### WR-01: The engine recreates the canonicalizer and its CIContext for every admitted request

**Classification:** WARNING

**File:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift:119`

**Issue:** `BeautyStillImageCanonicalizer()` is constructed inline for each admitted request. Its initializer creates a new `CIContext`, so the context is not reused across requests even though the canonicalizer and the Phase 53 reliability contract explicitly describe a reused context. This is a lifecycle/ownership mismatch and makes future admitted work pay repeated heavyweight setup while the tests only exercise reuse inside a standalone harness-owned canonicalizer.

**Fix:** Store one canonicalizer on `BeautyEngine`, initialize it in both engine initializers, and reuse it for every admitted still request:

```swift
private let stillImageCanonicalizer: BeautyStillImageCanonicalizer

// in both initializers
self.stillImageCanonicalizer = BeautyStillImageCanonicalizer()

// in processResult
let canonical = try stillImageCanonicalizer.canonicalize(
    image: image,
    metadata: metadata,
    maximumPixelCount: configuration.maximumInputPixelCount
)
```

Add a testing hook that records canonicalizer/context identity across two sequential admitted requests rather than merely asserting per-request output.

### WR-02: Lip mapping and lifecycle tests report synthesized counters instead of observing production work

**Classification:** WARNING

**File:** `BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift:125-168`

**Issue:** The harness hardcodes `retainedSupportCount = 0`, creates a fresh `VisionFaceDetector` inside every `mapOneRequest`, and calculates `mappingInvocationCount` from the number of nonempty output arrays. Those values cannot detect retained state in one detector, duplicate mapping calls, or extra allocations. A production regression that maps a region twice would still report one invocation, and a detector that retained support would be destroyed before the next request. The passing valid-invalid-valid and exactly-once tests therefore do not prove the behavior named by their assertions.

**Fix:** Keep one detector as harness state for the whole fixture sequence and instrument the actual mapping boundary with a counted test collaborator or callback. Return observed mapper calls/allocated point counts from that seam, and determine retained support from the detector/request owner after each request rather than a constant:

```swift
private var detector: VisionFaceDetector
private let mappingProbe: MappingProbe

func mapOneRequest() -> SDKTestingLipResult {
    mappingProbe.resetForRequest()
    let result = detector.detect(metadata: metadata())
    return SDKTestingLipResult(
        mappingInvocationCount: mappingProbe.invocationCount,
        allocatedPointCount: mappingProbe.mappedPointCount,
        retainedSupportCount: detector.testingRetainedSupportCount
    )
}
```

Use the same observed-counter approach for carrier consumer identities instead of assigning detector/render identities from the carrier value itself.

---

_Reviewed: 2026-07-31T07:33:32Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
