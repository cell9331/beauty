# Phase 76 Plan Review

**Status: PASS — revised plans satisfy the revision gate**

**Reviewed:** 2026-08-22
**Plans:** `76-01-PLAN.md`, `76-02-PLAN.md`

The revised plans provide an executable trace from the Phase-76 goal and
SUP-01/SUP-02 through the request-local support owner, existing detector
boundary, and source-owned composition oracle. No blocker remains.

## Required contract confirmations

1. **Exact detector signature and call path — covered.** Plan `76-02`, Task
   `76-02-01`, names the package-only seam exactly:

   `VisionFaceDetector.detectWithUpperEyelidSupport(image:metadata:imageExtent:previewExtent:configuration:semanticOwner:)`

   It requires the existing `detect(...)` exactly once, selects
   `detection.observations.first` as the immutable observation, calls
   `BeautyUpperEyelidSemanticSupportOwner.resolve(...)` once, and returns
   `VisionFaceDetectionWithUpperEyelidSupportResult`. Focused tests own provider
   invocation count, selected-observation identity, peer survival, and
   request-state release.

2. **Provider request/approval types — covered.** Plan `76-01`, Task
   `76-01-01`, defines package-only `BeautyUpperEyelidSemanticRequest`,
   `BeautyUpperEyelidSemanticApproval`, `BeautyUpperEyelidEyeOutcome`, and
   `BeautyUpperEyelidSupportResolution`. The injected owner seam is exactly:

   `@Sendable ([BeautyUpperEyelidSemanticRequest]) -> [BeautyUpperEyelidSemanticApproval]`

   Requests use the selected immutable observation and already mapped
   image-normalized coordinates; approval is provider-owned and mandatory.
   Rejection produces typed `.sourceExactNoOp` outcomes.

3. **CoordinateMapper-only conversion — covered.** Conversion is prohibited
   in the semantic owner. `CoordinateMapper` is the sole conversion boundary;
   the owner validates mapped image-normalized coordinates, finite values,
   image bounds, and hard containment. Plan `76-02`, Task `76-02-01`, requires
   `.up`, `.down`, `.left`, `.right` crossed with input mirror `false` and
   `true`, including independent peer preservation.

4. **Composition oracle — covered explicitly.** Plan `76-02`, Task
   `76-02-01`, creates `BeautyUpperEyelidSupportCompositionTests.swift` and
   routes accepted indices through `BeautyLocalPixelProposal` and the existing
   `BeautyLocalRetouchCompositionOwner`. It requires byte-level proof that a
   rejected eye remains source-exact beside an accepted peer, overlap returns
   immutable source bytes and increments `collisionPixelCount`, and alpha,
   extent, orientation/mirror metadata, and pixels outside the union remain
   exact.

5. **Concrete T-76-01..08 ownership — covered.** Plan `76-02`, Task
   `76-02-02`, assigns the checker and `76-VALIDATION.md` ownership:

   | Threat | Validation ownership |
   |---|---|
   | T-76-01 | shared-observation reuse / one detector invocation |
   | T-76-02 | left/right side coupling |
   | T-76-03 | semantic approval bypass |
   | T-76-04 | typed source-exact no-op fallback |
   | T-76-05 | finite and hard-containment bypass |
   | T-76-06 | orientation/mirror conversion duplication |
   | T-76-07 | overlap-to-source composition |
   | T-76-08 | privacy/raw-support diagnostic leakage |

   The task also requires focused commands, pass rules, mutation results,
   privacy scan, compatibility inventory, and full SDK-gate results.

## Coverage summary

| Requirement | Plans | Status |
|---|---|---|
| SUP-01 | 76-01, 76-02 | Covered: one observation, landmark envelopes/guards only, approved semantic owner, mapped-coordinate boundary |
| SUP-02 | 76-01, 76-02 | Covered: independent typed outcomes, source-exact rejection, peer isolation, byte-level composition evidence |

## Gate checks

- Every autonomous task has files, concrete action, automated verification,
  and measurable done criteria.
- Dependencies are valid and acyclic: `76-01` is Wave 1; `76-02` depends on
  it and is Wave 2.
- Key links are explicit from support owner to immutable observation, detector
  seam to one invocation, and outcomes to source-owned composition.
- Scope is reasonable: two plans with two tasks each and bounded file sets.
- Public absence, request locality, aggregate-only diagnostics, and no-device /
  no-commercial claims align with `76-CONTEXT.md` and `AGENTS.md`.
- No `RESEARCH.md`, `PATTERNS.md`, or architectural responsibility map exists
  for Phase 76, so those optional dimensions are not applicable.
- No Phase-76 `VALIDATION.md` exists yet; it is an explicitly planned output
  of `76-02-02`, with creation and closeout verification assigned there, so it
  is not a pre-execution blocker.

Two wording issues are non-blocking: Plan `76-01` Task 2's done text mentions
orientation/mirror evidence while assigning those end-to-end checks to Plan
`76-02`, and Task `76-02-02` says “before closeout” while listing the artifact
in its own files. The actions and verification ownership are unambiguous.

**Recommendation:** proceed to `$gsd-execute-phase 76`.
