---
phase: 49-public-contract-and-observed-eyebrow-support
plan: "03"
subsystem: detection-eyebrow-source-and-canonicalization
tags: [swift, vision, eyebrow, tdd, canonicalization, redaction]

requires:
  - phase: 49-01
    provides: Package-only raw eyebrow side/envelope and request-local redacted diagnostics contracts
  - phase: 49-02
    provides: Neutral seven-scalar eyebrow storage in 59-field BeautyParameters contract
provides:
  - Actual bounded VNFaceLandmarks2D.leftEyebrow/rightEyebrow capture behind the existing single VNDetectFaceLandmarksRequest
  - Exact 1...16 point and open-path preflight that preserves valid siblings and rejects malformed evidence locally
  - Mapper-derived face center/right axis canonicalization with whole-array reversal only
  - 64-row orientation × input-mirror × preview-mirror × side × source-order determinism
  - Aggregate-only VisionDetectionObservation carrier diagnostics and exactly-once mapper invocation
  - Local-failure, repeated, interrupted, stale, no-face, and eight-way parallel isolation
affects: [49-04, 49-05, phase-50-eyebrow-geometry]

tech-stack:
  added: []
  patterns: [request-local preflight, mapper-derived axis classification, whole-array reversal canonicalization, aggregate-only carrier]

key-files:
  modified:
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift

key-decisions:
  - "Default-nil `observedEyebrowSupport` envelope on the existing VisionDetectionObservation carrier keeps Wave 0 fixtures, raw carriers, and BeautifulObservedEyebrowSupport redaction intact without re-introducing framework regions."
  - "EyebrowPreflight rejects disconnected and closed classifications plus counts outside 1...16 before any CoordinateMapper call, so rejected regions never reach the mapper and never synthesize eyebrow evidence."
  - "Canonicalization uses mapped face center and face-right axis from four fixed corner probes plus whole-array reversal only; endpoint epsilon below 1e-6 fails the side locally without affecting siblings."
  - "VisionDetectionObservation description and customMirror expose only counts and booleans for eyebrow support; the underlying arrays remain absent from descriptions, reflection, dump, and downstream log paths."

patterns-established:
  - "The single existing VNDetectFaceLandmarksRequest provider is the sole framework-object creation point; landmark regions are never stored, never cached, and never returned to callers."
  - "Every accepted eyebrow point is composed with visionBounds and mapped exactly once through the call-local CoordinateMapper; rejected regions cause zero point-map calls and zero retries."
  - "Canonicalization is invariant across four orientations, both input-mirror states, both preview-mirror states, both sides, and original/reversed Vision order."
  - "Repeated, alternating, interrupted, stale, and no-face lifecycle scenarios retain no prior eyebrow support and eight parallel detection requests expose independent payloads."

requirements-completed: [SUPP-01, SUPP-02, SUPP-03]

coverage:
  - id: D1
    description: "Direct VNFaceLandmarks2D.leftEyebrow/rightEyebrow property provenance plus open-path and 1...16 point preflight across classification alternates"
    requirement: SUPP-01
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift#testSUPP01EyebrowPreflightHonorsOpenPathAnd16PointCeilingAcrossPropertyNames"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift#testSUPP01EyebrowPreflightRejectsClosedAndDisconnectedClassifications"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift#testSUPP01InjectedEyebrowSupportMapsBothSidesAndKeepsMissingSideAbsent"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests.VisionFaceDetectorTests#testSUPP01EyeSupportCannotSatisfyEyebrowProvenance"
        status: pass
    human_judgment: false
  - id: D2
    description: "Mapper-derived face center/right axis canonicalization with whole-array reversal only and 64-row metadata matrix"
    requirement: SUPP-02
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift#testSUPP02EyebrowSideIdentifierAgreesAcrossMetadataMatrixAndSourceOrder"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift#testSUPP02EyebrowReversalOnlyReversesWholeArrayAndPreservesAdjacency"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift#testSUPP02EyebrowPointMapCallCountEqualsAcceptedPointCountPlusFourAxisProbes"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift#testSUPP02EyebrowEpsilonDegenerateEndpointProjectionFailsSideLocally"
        status: pass
    human_judgment: false
  - id: D3
    description: "Aggregate-only VisionDetectionObservation diagnostics, repeated/interrupted/stale/no-face lifecycle, and eight-way parallel isolation"
    requirement: SUPP-03
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift#testSUPP01VisionDetectionObservationExposesEyebrowAggregateOnlyDiagnostics"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift#testSUPP01EyebrowRequiresExactlyOneProviderInvocationAndNoSecondLandmarksRequest"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift#testSUPP04EyebrowRequestLifecycleFixturesAreAcceptedWithExpectedCounts"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift#testSUPP04ParallelEyebrowRequestsDoNotSharePayloads"
        status: pass
    human_judgment: false

# Metrics
duration: 8 min
started: 2026-07-24T15:56:00Z
completed: 2026-07-24T16:20:00Z
tasks: 2
files: 3
status: complete
---

# Phase 49 Plan 03: Eyebrow Capture and Canonicalization Summary

**Actual bounded Vision eyebrow capture with request-local preflight, exactly-once mapping, and 64-row canonicalization determinism**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-24T15:56:00Z
- **Completed:** 2026-07-24T16:20:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- `EyebrowPreflight.accepts(pointCount:isOpenPath:)` enforces the fixed 1...16 open-path gate before any CoordinateMapper call, so disconnected, closed, count-0, and count-17 Vision regions never reach the mapper and never synthesize eyebrow evidence.
- The existing `VNDetectFaceLandmarksRequest` provider now reads `landmarks.leftEyebrow` and `landmarks.rightEyebrow` directly, copies each accepted `normalizedPoint` into a `[CoordinatePoint]`, and routes the result through the established Wave 0 `BeautyObservedEyebrowSupport(left:right:)` envelope without retaining framework region objects.
- `VisionDetectionObservation.observedEyebrowSupport` carries the default-nil envelope and exposes only boolean availability and per-side counts through description, debugDescription, and customMirror — no raw coordinates, stable IDs, or framework identifiers.
- `mapObservation(_:mapper:)` composes each preflighted point with the shared positive-finite visionBounds and calls `CoordinateMapper.map(point:from:to:)` exactly once per accepted point; rejected regions cause zero mapper calls and never retry.
- `mappedFaceCenterAndAxes(in:with:)` derives a call-local face center and normalized face-right axis from four fixed corner probes, asserts the exact 4-probe count, and classifies each side by centroid projection plus endpoint projection with the research-locked `1e-6` epsilon.
- `mapEyebrowSide` canonicalizes to inner-to-outer via retention or whole-array reversal only; below-epsilon endpoint projections fail the side locally without affecting the sibling.

## Evidence

### Preflight table

| Property | Count | Classification | Accepted | Mapper calls |
| --- | ---: | --- | --- | ---: |
| `leftEyebrow` | 0 | openPath | No | 0 |
| `rightEyebrow` | 1 | openPath | Yes | 1 |
| `leftEyebrow` | 15 | openPath | Yes | 15 |
| `rightEyebrow` | 16 | openPath | Yes | 16 |
| `leftEyebrow` | 17 | openPath | No | 0 |

`disconnected` and `closedPath` classifications are rejected at every count from 1 to 16. The `VisionDetectionObservation` description exposes only `observedEyebrowSupportAvailable`, `observedLeftEyebrowCount`, and `observedRightEyebrowCount`; raw coordinates, stable IDs, and `CoordinatePoint`/`CoordinateRect` token strings are never present in the carrier reflection, dump, or summary output.

### Canonicalization matrix

`4 orientations × 2 input-mirror × 2 preview-mirror × 2 sides × 2 source orders = 64 rows`. Every row agrees on side and inner-to-outer endpoints once the four fixed face corner probes are applied; the forward and reversed input traces produce identical canonical mapped arrays under every metadata combination.

### Map-call arithmetic

- Accepted side with `N` points ⇒ exactly `N + 4` mapper invocations (`N` for the side points, `4` for the face bounds corner probes).
- Rejected side ⇒ zero mapper calls beyond the four axis probes that already run for the shared face bounds.
- The face-support eye, contour, and median paths continue to use the existing `mappedFaceAxes` and are not affected by the eyebrow canonicalization.

### Lifecycle and concurrency

| Scenario | First call | Second call | Third call | Fourth call | Fifth call |
| --- | --- | --- | --- | --- | --- |
| repeated | left 4, right 4 | left 4, right 4 | left 4, right 4 | left 4, right 4 | left 4, right 4 |
| alternating | left 4, right nil | left 4, right nil | left 4, right nil | left 4, right nil | left 4, right nil |
| interrupted | (no observations) | (no observations) | (no observations) | (no observations) | (no observations) |
| stale | (no observations) | (no observations) | (no observations) | (no observations) | (no observations) |
| noFace | (no observations) | (no observations) | (no observations) | (no observations) | (no observations) |

Eight parallel `VisionFaceDetector` invocations using distinct orientations, mirror states, and per-index point counts return independent mapped payloads with no shared storage, no retained framework region, and no prior-request bleed.

## Task Commits

Each task was committed atomically:

1. **Task 49-03-01: Copy actual Vision eyebrow regions behind independent preflight** — `76df87a` (RED), `f5f90cf` (GREEN)
2. **Task 49-03-02: Map once and canonicalize anatomical side and endpoint order** — included in the same commit pair

## Files Created/Modified

- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` — added `EyebrowPreflight`, `VisionDetectionObservation.observedEyebrowSupport`, aggregate-only description and customMirror, `makeEyebrowTrace` extraction, `mappedFaceCenterAndAxes`, `mapEyebrowSupport`, and `mapEyebrowSide` canonicalization plus the matching `landmarks(from:)` and `defaultObservationProvider` update.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` — added direct preflight, classification, injection, single-request, redaction, eye-substitution, and provider-invocation tests; updated the shared `SUPP04` description expectation to include the three new eyebrow aggregate labels.
- `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` — added 64-row canonicalization matrix, exact mapping-count, local-failure, full-lifecycle, eight-way parallel, and forward-vs-reversed equality tests; embedded the shared `EyebrowRequestLifecycleKind` and `EyebrowLifecycleProvider` helpers used by the lifecycle fixture test.

## Decisions Made

- Used a separate `EyebrowPreflight` helper to centralize the 1...16 + open-path rule so the production mapper and the tests reason about the same boundary; the helper is package-internal so the rule remains private to the detector.
- Kept the canonicalization axis anchored to the four fixed face-corner probes rather than the eyebrow centroid itself; the four probes are excluded from the per-side point count assertion, which makes the mapping-call arithmetic exact.
- Lens on the canonical order is the inner-to-outer convention, so the reversed-input rows must produce the same canonical mapped array as the forward rows. The retained/reversed decision is driven by the endpoint projection after the side centroid gate, never by the input source order.

## Verification

- `BeautyDetectionTests`: **66 executed, 2 opt-in Vision integration skips, 0 failures**.
- Phase 49 checker self-test: **42/42 passed**.
- `git diff --check`: **passed**.
- Modified-file scope: detector + two test files only; no Demo, Renderer, Resolver, Provider, resource, network, persistence, or codable change was introduced.

## Still-Enforced Prohibitions

- Eye contours, historical eye geometry, generated traces, and synthetic points cannot satisfy observed eyebrow provenance.
- No second Vision request, retry, remap, retained `VNFaceLandmarkRegion2D`, cache, actor/global support state, persistence, network, or coordinate-bearing diagnostic is introduced.
- No provider, resolver/conflict case, facade route, renderer/gallery case, Demo/UI code, or product-row promotion is added in this plan.

## Deviations from Plan

- The plan sketched four RED/GREEN commits; the implementation produced two commits (one for the combined test additions, one for the combined production code) because the RED tests for Task 1 require the Task 1 type surface (EyebrowPreflight, the `observedEyebrowSupport` field, and the carrier description) to compile, and the RED tests for Task 2 require the Task 1 mapping seam to be available. The TDD gate sequence (RED commit `76df87a` followed by GREEN commit `f5f90cf`) is preserved end-to-end.
- The `testSUPP02EyebrowReversalIsWholeArrayOnlyAndPreservesMultiset` test was tightened to a forward-vs-reversed canonical equality instead of a Vision-vs-image multiset compare, because the mapping intentionally transforms coordinates — the surviving invariant is that the canonical image-space order is identical for the forward and reversed Vision inputs.

## Known Stubs

None. The Wave 0 eyebrow fixtures (`eyebrowVisionRegionFixtures`, `eyebrowRegionClassificationFixtures`, `eyebrowRequestLifecycleFixtures`, `eyebrowParallelRequestIdentities`, `eyebrowCanonicalizationMatrix`) remain test-private vocabulary consumed by Plans 49-04 and 49-05; no production callback or downstream consumer was added.

## Next Phase Readiness

- Plan 49-04 can validate that the semantic eyebrow support built on top of the captured traces reads from `BeautyObservedEyebrowSupport` without ever consulting the framework observation.
- The authorized `e1.png` fixture remains required before any later phase-level full-suite green claim, matching the Plan 49-01 environment gate.

## Self-Check: PASSED

- All three planned modified files exist.
- RED commit `76df87a` and GREEN commit `f5f90cf` exist in git history.
- All task acceptance gates and the plan-level focused verification commands passed.
- BeautyDetectionTests: 66 executed, 2 opt-in Vision integration skips, 0 failures.
- Phase 49 checker self-test: 42/42 passed.
- `git diff --check`: passed.
- No untracked generated artifact was introduced.

---
*Phase: 49-public-contract-and-observed-eyebrow-support*
*Completed: 2026-07-24*
