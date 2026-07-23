---
phase: 45-public-contract-and-observed-face-support
plan: "04"
subsystem: effects-planning
tags: [swift, face-contour, topology-validation, privacy, tdd]

requires:
  - phase: 45-public-contract-and-observed-face-support
    provides: Plan 45-01 private observed/semantic face seams and Plan 45-03 canonical mapped contour/median paths
provides:
  - face-specific bounded open-contour and median validation
  - independent contour-only and contour-plus-centerline semantic eligibility
  - cross-support chord, apex-distance, and interior-side consistency
  - exact legacy face/eye/nose/lip sibling and request-isolation evidence
affects: [45-05, phase-46-face-providers]

tech-stack:
  added: []
  patterns:
    - validate untrusted observed paths before SIMD conversion
    - preserve mapped open-path adjacency without sorting or polygon closure
    - attach optional semantic evidence independently from compatibility geometry

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift

key-decisions:
  - "Keep the complete A1 face-support envelope unchanged after all six committed portraits passed aggregate validation."
  - "Preserve contour-only semantic eligibility when median validation or cross-support consistency fails."
  - "Attach observed semantic support beside every existing geometry sibling, including the invalid-eye-order path, without adding a provider consumer."

patterns-established:
  - "Face open-path validation: fixed counts, exact-bit uniqueness, finite closed-unit input, face-relative chord/curvature/direction math, then SIMD conversion."
  - "Cross-support degradation: invalid contour removes observed support; invalid median or contour/median inconsistency removes only centerline eligibility."

requirements-completed: [SUPP-01, SUPP-02, SUPP-04]

duration: 16 min
completed: 2026-07-23
---

# Phase 45 Plan 04: Face Topology Validation and Eligibility Summary

**Bounded face-specific open-path validation now attaches honest contour-only or contour-plus-centerline evidence beside the unchanged seven-point compatibility geometry**

## Performance

- **Duration:** 16 min
- **Started:** 2026-07-23T05:22:21Z
- **Completed:** 2026-07-23T05:39:15Z
- **Tasks:** 2
- **Files modified:** 2 implementation/test files plus planning metadata

## Accomplishments

- Added face-only contour and median validators with fixed cardinality, finite closed-unit input, exact-bit uniqueness, face-relative span, chord, curvature, and direction checks. Validation preserves Plan 03 ordering and never calls the eye predicates, `stablePointOrder`, angular sorting, or `polygonArea`.
- Added conservative cross-support validation: median-bottom chord projection must be `0.15...0.85`, nearest-apex distance must be at most `0.40`, and the selected apex must leave at least two contour points on each side.
- Attached exactly one optional `BeautyFaceSemanticSupport` without changing the exact seven-point proxy or any eye, nose, root, tip, outer-lip, upper-lip, lower-lip, inner-lip, bounds, or freshness value.
- Proved region-local and stateless behavior across absent, neither-region, contour-only, median-only, complete, malformed, cross-inconsistent, invalid-eye-order, and valid→invalid→valid requests.

## Final Support Constants

| Predicate | Final bound | Semantics |
| --- | ---: | --- |
| Contour count | `7...32` | Inclusive |
| Median count | `3...16` | Inclusive |
| Contour relative width | `0.50...1.00` | Inclusive |
| Contour relative height | `0.20...1.00` | Inclusive |
| Endpoint horizontal separation | `>= 0.35` | Inclusive |
| Maximum chord-perpendicular curvature | `>= 0.10` | Inclusive |
| Median net-down projection | `>= 0.25` | Inclusive |
| Direction magnitude | `>= 0.000001` | Inclusive |
| Median-bottom chord position | `0.15...0.85` | Inclusive |
| Nearest-apex distance | `<= 0.40` | Inclusive |
| Contour points on each apex side | `>= 2` | Inclusive |

No A1 value changed. All six committed portraits were evaluated; every complete observed support that appeared passed contour, median, and cross-support validation, so no evidence-led relaxation was needed.

## Exact Test Matrices

- Cardinality: six contour probes (`6/7/8/31/32/33`) and six median probes (`2/3/4/15/16/17`).
- Topology boundaries: 36 Wave 0 probes across twelve named rules, each with inside/exact/outside evidence.
- Cross-support boundaries: thirteen direct assertions covering both chord-position edges, apex distance, and before/after interior point counts.
- Presence/isolation: five envelope states (absent, neither, contour-only, median-only, complete), four malformed/cross-inconsistent median cases, invalid contour with valid median, invalid eye order, complete legacy/sibling equality, and alternating valid→invalid→valid calls.
- Aggregate evidence: six committed portraits pass without coordinate, bounds, point-sample, or framework-region output.

## Task Commits

Each TDD task was committed through RED then GREEN:

1. **Task 45-04-01: Lock face-specific open-path topology validation**
   - `d313b09` — RED: failing count, topology, numeric-boundary, malformed, and adjacency specification
   - `5115256` — GREEN: face-specific bounded validators plus six-portrait aggregate evidence
2. **Task 45-04-02: Attach independent eligibility and prove legacy/sibling isolation**
   - `0299123` — RED: failing presence, cross-support, sibling-equality, and statelessness specification
   - `1e7210a` — GREEN: semantic attachment, cross-support apex validation, and field-local degradation

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` — separate face constants/predicates, open-path validators, cross-support apex selection, and independent semantic attachment.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` — exact matrices, malformed topology, portrait aggregate, presence combinations, legacy/sibling equality, and alternating-call isolation.

## Verification

- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` — **PASS, 27/27**.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests` — **PASS, 48/48**.
- `swift test --package-path BeautySDK` — **PASS, 347/347**.
- `git diff --check` — **PASS**.
- Scope diff — exactly the adapter and its test changed in production/test commits; no provider, resolver, conflict, cap, facade, renderer, manifest, resource, dependency, or Demo file changed.
- Consumer scan — `observedFaceSupport` remains limited to detection transport, the internal geometry value, and this adapter; no downstream provider consumes it yet.

## Decisions Made

- Retained the A1 thresholds exactly because the current six-portrait aggregate produced no validation mismatch.
- Used face-relative coordinates only for plausibility and cross-support math; the stored semantic arrays remain the mapped image-normalized values in their existing order.
- Cross-support inconsistency degrades to contour-only evidence instead of discarding a valid contour. A malformed contour still yields nil observed semantic support even when the median is valid.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- SwiftPM's nested sandbox was denied by the managed environment during the first RED run. The required focused and full commands were rerun with the repository's private module-cache path outside that nested sandbox; all final suites passed with Apple Vision host access.

## Known Stubs

None. Provider/resolver/facade consumption is intentionally absent and owned by Phase 46, not stubbed in Phase 45.

## Threat Flags

None. The changed files introduce no network endpoint, authentication path, persistence/file-access path, schema boundary, or unregistered trust surface. All new input and disclosure risks are already covered by T-45-13 through T-45-17 and T-45-SC.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 45-05 can synchronize the owning contracts and run the live fail-closed boundary checker against the completed 52-field, mapping, and adapter implementation.
- Phase 46 can consume `contourEligible` and `centerlineEligible` explicitly without borrowing the seven-point proxy.
- No provider, resolver, cap, facade, renderer, output, row-promotion, Demo, device, commercial, packaging, shipping, or launch-readiness claim is made.

## Self-Check: PASSED

- Both modified implementation/test files and this summary exist.
- RED/GREEN commits `d313b09`, `5115256`, `0299123`, and `1e7210a` exist in repository history in the required order.
- Focused adapter passes 27/27, BeautyDetection passes 48/48, full SwiftPM passes 347/347, the six-portrait aggregate passes, and diff hygiene is clean.

---
*Phase: 45-public-contract-and-observed-face-support*
*Completed: 2026-07-23*
