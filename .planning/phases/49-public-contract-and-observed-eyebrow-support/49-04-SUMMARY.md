---
phase: 49-public-contract-and-observed-eyebrow-support
plan: "04"
subsystem: detection-eyebrow-validator-and-geometry-attachment
tags: [swift, eyebrow, tdd, open-path, validator, privacy, redaction, lifecycle]

requires:
  - phase: 49-01
    provides: Fail-closed boundary checker, request-local raw and semantic eyebrow contracts, default-nil observed eyebrow support types
  - phase: 49-03
    provides: Plan-49-03-anatomically canonicalised mapped BeautyObservedEyebrowSupport.left/right arrays
provides:
  - Brow-specific pure open-path validator (count 4..16, chord 0.08..0.50 face-width, vertical span <= 0.25 face-height, 1e-6 projection epsilon)
  - Independent per-side BeautyEyebrowSemanticTrace conversion preserving exact canonical points, innerEndpoint, outerEndpoint, arithmetic center, and optional unique interior apex
  - BeautyEyebrowSemanticSupport envelope attached beside FaceGeometry siblings with local-failure and stateless lifecycle
  - Re-applied eye-shape, contour-bound, median-bound, and pure-predicate boundaries unchanged
affects: [49-05, phase-50-eyebrow-geometry]

tech-stack:
  added: []
  patterns: [brow-named constants, exact-bit uniqueness, non-adjacent open-path intersection check, face-up perpendicular apex, independent optional side attachment, aggregate-only diagnostics]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift

key-decisions:
  - "Use brow-named constants (minimumBrowPointCount 4, maximumBrowPointCount 16, minimumBrowChord 0.08, maximumBrowChord 0.50, maximumBrowVerticalSpan 0.25, minimumBrowProjectionMagnitude 1e-6) instead of reusing closed-eye or face-contour bounds."
  - "Derive innerEndpoint and outerEndpoint directly from input array endpoints and never reuse sort, screen-axis recanonicalization, polygon area/winding, hull, last-to-first closure, or eye-topology rules."
  - "Treat the apex as optional private evidence only: a unique interior point with the greatest face-up perpendicular projection above 1e-6, nil otherwise. The apex is never used for provider eligibility."
  - "When either side survives validation keep its semantic trace; return nil only when both sides fail. pairEligible remains true exactly for two distinct valid sides."
  - "Wire validatedBrowSupport beside the existing observedFaceSupport pipeline and pass the result into both FaceGeometry construction paths so invalid-eye-order early-return still attaches valid brow support without touching shipped siblings."

patterns-established:
  - "Brow validator accepts the exact canonical adjacency from Plan 49-03 with no sort, no closure, no polygon area/winding/hull, no eye-topology reuse; reverse ordering is accepted but only its points are retained, never its polarised endpoints."
  - "The captured FaceGeometry keeps bounds, faceContour, observedFaceSupport, left/right eye arrays and support, nose/root/tip, outer/upper/lower/inner lips, freshness, and the new observedEyebrowSupport strictly separated; malformed sides never erase a valid sibling."
  - "makeGeometry remains per-call and stateless across repeating, alternating, interrupted, stale, and no-face lifecycle; eight-way parallel makeGeometry calls do not share eyebrow payloads."

requirements-completed: [SUPP-02, SUPP-03]

coverage:
  - id: D1
    description: "Brow open-path pure predicates and 4..16 cardinality with exact-bit uniqueness, finite/unit, chord 0.08..0.50, vertical span 0.25 inclusive"
    requirement: SUPP-02
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowOpenPathPurePredicatesLockInclusiveNumericBoundaries"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowOpenPathCardinalityUniquenessAndUnitRangeRejectMalformedInput"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowOpenPathChordAndVerticalSpanBoundariesLockEqualAndExclusiveRows"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowRejectsNonAdjacentOpenPathSegmentIntersections"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowOpenPathValidationPreservesCanonicalAdjacencyAndRejectsReverseInnerToOuter"
        status: pass
    human_judgment: false
  - id: D2
    description: "Four presence combinations, independent per-side validation, sibling preservation, alternating lifecycle, and parallel stateless construction"
    requirement: SUPP-03
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowSupportAttachmentPreservesFourPresenceCombinationsAndPairedEligibility"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowMalformedLocalFailureNeverAffectsShippedGeometrySiblings"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowAlternatingLifecycleRetainsNoPriorSupport"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift#testBrowIndependentParallelGeometryConstructionsAreStateless"
        status: pass
    human_judgment: false

# Metrics
duration: 8 min
completed: 2026-07-24
---

# Phase 49 Plan 04: Eyebrow Open-Path Validation and Private Attachment Summary

**Brow-specific open-path validator plus independent private semantic attachment with aggregate-only diagnostics and per-call stateless lifecycle**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-24T08:35:00Z
- **Completed:** 2026-07-24T08:41:38Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `BeautyFaceGeometryAdapter.browChordIsValid`, `browVerticalSpanIsValid`, and `browProjectionMagnitudeIsValid` lock the locked 4...16 / 0.08...0.50 / <=0.25 / 1e-6 envelopes as pure predicates with full NaN/Inf/-epsilon coverage.
- `BeautyFaceGeometryAdapter.validatedBrowTrace(_:side:bounds:)` consumes the Plan 49-03 canonical mapped arrays without sorting, screen-axis recanonicalization, last-to-first closure, polygon area/winding/hull, or closed-eye/face topology reuse. It validates count, finite unit range, exact-bit uniqueness, bounded face-relative chord and vertical span, and absence of non-adjacent segment intersections, then derives `points` (exact input order), `innerEndpoint`, `outerEndpoint`, arithmetic `center`, and an optional unique interior apex from the greatest face-up perpendicular projection above 1e-6.
- `BeautyFaceGeometryAdapter.validatedBrowSupport(_:bounds:)` validates both sides independently; a valid side always survives even when its sibling is malformed; the envelope returns nil only when both sides fail. `pairedEligible` remains true exactly for two distinct valid sides through the existing `BeautyEyebrowSemanticSupport` contract.
- `BeautyFaceGeometryAdapter.makeGeometry(from:)` now calls `validatedBrowSupport` beside the existing `validatedFaceSupport` pipeline and passes `observedEyebrowSupport` into both `FaceGeometry` construction paths, so invalid-eye-order early-return still retains valid brow attachment without touching bounds, face contour, observed face support, eye arrays / support, nose / root / tip, outer / upper / lower / inner lips, or freshness.
- The adapter stays per-call and stateless across alternating valid / invalid / repeated / stale-landmark / no-face lifecycle, and parallel `makeGeometry` calls do not share any eyebrow payload.

## Task Commits

Each task was committed atomically with its own RED then GREEN pair:

1. **Task 49-04-01: Lock independent eyebrow open-path validation** — `217966c` (RED), `fdb396e` (GREEN)
2. **Task 49-04-02: Attach semantic support with local failure, redaction, and stateless lifetime** — `8dda5f0` (RED), `d8e117d` (GREEN)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` — added eyebrow constants and pure predicates (`minimumBrowPointCount`, `maximumBrowPointCount`, `minimumBrowChord`, `maximumBrowChord`, `maximumBrowVerticalSpan`, `minimumBrowProjectionMagnitude`, `browChordIsValid`, `browVerticalSpanIsValid`, `browProjectionMagnitudeIsValid`), the pure `validatedBrowTrace` validator with `browInputIsValid`, `browPathHasNonAdjacentIntersections`, `browApexIndex`, and `BrowPointKey` helpers, the `validatedBrowSupport` envelope that retains the valid sibling trace, and the `makeGeometry(from:)` wiring into both `FaceGeometry` initializations.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` — added the `browOpenTrace(count:side:)` and `browInvalidPoints(side:)` helpers, five boundary tests (pure-predicate locks, cardinality/uniqueness/unit range, canonical preservation, chord/span at exactly 0.08 and 0.50 and 0.25 with exclusive surrounds, non-adjacent intersection rejection), four attachment tests (four presence combinations, sibling preservation, alternating lifecycle, parallel stateless construction).

## Decisions Made

- Brow validation owns new brow-named constants instead of reusing eye-contour or face-contour bounds; closed-eye topology constants, polygon area, endpoint closure, sort, and hull helpers are never called.
- The apex index is computed from the unique interior point with the greatest signed face-up perpendicular projection above 1e-6; ties or sub-epsilon displacements resolve to nil, so Phase 50 providers never read a fabricated apex as eligibility evidence.
- The reverse-ordered input passes validation but is preserved verbatim; the validator never re-pairs `first` / `last` to canonical `inner` / `outer`, leaving the Plan 49-03 canonicalization seam authoritative.
- `validatedBrowSupport` retains any valid side instead of producing a symmetric envelope, mirroring the Phase 45 face support pattern where local failure must not erase a sibling region.
- `makeGeometry` calls `validatedBrowSupport` before computing the observed-eye path so that `observedEyebrowSupport` is populated even when the eye order is invalid; the integration adds the parameter to both `FaceGeometry(...)` initializers without altering any other field.

## Verification

- `BeautyFaceGeometryAdapterTests`: **45 executed, 1 opt-in Vision integration skip, 0 failures** (up from 36 / 1 / 0).
- `BeautyEffectsTests`: **223 executed, 1 opt-in Vision integration skip, 0 failures** (up from 214 / 1 / 0).
- `BeautyDetectionTests`: **66 executed, 2 opt-in Vision integration skips, 0 failures** (unchanged).
- Full `swift test --package-path BeautySDK`: **411 executed, 3 skipped, 3 failures**, all three failures are the pre-existing environment gate for `example-images/input/portraits/e1.png` documented in Plan 49-01 and unrelated to this plan.
- Phase 49 checker self-test: **42/42 passed**.
- `git diff --check`: passed.
- Modified-file scope: adapter + its owning test file only; no Demo, Renderer, Resolver, Provider, resource, network, persistence, codable, or new public/SPI surface change was introduced.
- Six brows `BeautyObservedEyebrowSide` / `BeautyObservedEyebrowSupport` / `BeautyFaceObservation.observedEyebrowSupport` / `BeautyEyebrowSemanticTrace` / `BeautyEyebrowSemanticSupport` / `FaceGeometry.observedEyebrowSupport` continue to expose only counts, booleans, and availability labels through description, debugDescription, customMirror, and dump.

## Still-Enforced Prohibitions

- Eye contours, historical eye geometry, generated traces, and synthetic points cannot satisfy observed eyebrow provenance.
- Reverse canonicalisation, screen-axis sort, polygon area/winding, hull, last-to-first closure, and closed-eye topology constants are never invoked.
- Raw or derived coordinates, endpoints, apex indices, CGPoint/SIMD values, hashes, stable signatures, and biometric/profile-like values remain absent from descriptions, reflection, dump, warnings, metrics, and committed evidence.
- No provider, resolver/conflict case, facade route, renderer/gallery case, Demo/UI code, product-row promotion, dependency, model, resource, network, persistence, cache, or codable path is added in this plan.

## Deviations from Plan

- RED Task 49-04-01 originally drafted a collinear-trace rejection test row. The validator never required non-zero vertical span (the plan keeps span `<= 0.25` inclusive of zero) so the row was removed in the GREEN commit to keep the boundary table honest; the chord / span tests were also rewritten to operate in face-relative units (multiplied by `bounds.width` / `bounds.height`) so 0.075 face-relative fails the minimum and exactly 0.25 face-relative passes.

## Issues Encountered

- None. The pre-existing environment gate for `example-images/input/portraits/e1.png` is documented as expected nonzero and is unchanged by Plan 49-04.

## Known Stubs

None. The brow validator and attachment are complete and per-call stateless; Plan 49-05 and Phase 50 retain the apex evidence as private metadata only and never expand it into provider eligibility or saved output.

## Next Phase Readiness

- Plan 49-05 can attach any provider-eligibility, resolver, conflict, or facade routing without re-canonicalizing the captured traces because the adapter owns the exact input adjacency, plus the per-side enum and per-side optional envelope.
- Phase 50 eyebrow geometry wiring can consume `BeautyFaceGeometryAdapter.validatedBrowTrace` directly through the same test-private fixtures used in this plan, and read `FaceGeometry.observedEyebrowSupport` without depending on the unmapped `BeautyFaceObservation.observedEyebrowSupport`.
- The authorized `e1.png` fixture remains required before any later phase-level full-suite green claim, matching the Plan 49-01 environment gate.

## Self-Check: PASSED

- All four task / TDD commits (`217966c`, `fdb396e`, `8dda5f0`, `d8e117d`) exist in git history with the expected RED and GREEN ordering.
- `BeautyFaceGeometryAdapter.swift` and `BeautyFaceGeometryAdapterTests.swift` are both present and contain the expected eyebrow validator plus the nine new tests.
- `swift test --package-path BeautySDK --filter BeautyFaceGeometryAdapterTests` and `--filter BeautyEffectsTests` both pass with 0 unexpected failures.
- Phase 49 checker self-test remains green at 42/42.

---
*Phase: 49-public-contract-and-observed-eyebrow-support*
*Completed: 2026-07-24*
