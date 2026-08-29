# Phase 90 Plan Check

**Phase:** Face Contour and Chin Repairs
**Plans verified:** 4
**Status:** EXECUTION STOP CONDITION REACHED
**Revision gate:** revision 7 bounded fallback executed and disconfirmed
**Issues:** 1 implementation blocker, 0 warnings

> Execution addendum (2026-08-29): the revision-6 plan check below is retained
> as planning history. Revision 6 was disconfirmed for cost and incorrect
> inverse-map modeling; revision 7 then exhausted its finite safe candidates.
> See `90-01-ATTEMPT.md`. This file no longer authorizes execution to resume
> without an explicit blocker decision.

## Goal-backward verdict

Plan 90-02 is already complete. Plan 90-01 retains the valid generated RED and
the exact frozen Phase 89 contract, but execution disconfirmed the first sparse
provider-local replan. Architecture revision 4 replaces only that sparse
topology with a bounded provider-derived sampled ribbon, adds the missing
256-point Metal payload proof, and preserves the fixture-aligned public-facade
corroboration without making production position-dependent. A focused,
code-grounded checker confirmed the revision-4 construction order, density,
locality, and canonical point-budget claims were executable. Exact execution
then exposed a renderer-specific inverse-map folding defect, so revision 5 adds
a corrected target curve and explicit monotonicity guard before execution may
resume. The focused revision-5 review passed after envelope-preserving
centering removed nonzero endpoint coefficients and horizontal extrema were
clarified as non-emitting reference knots that may receive composite influence.

## Execution-time disconfirmation and resolution

The retained generated oracle reported:

- source and neutral signed continuity margin `12 < 16`;
- frozen sibling margins `faceSmall = 16` and `faceSlim = 3 < 16`;
- outside signal `2724/284565 > 500/1500`;
- central-anatomy signal `909/138177 > 128/512`;
- target floors passed and background/watermark remained byte-exact.

Independent audit confirmed these failures were not caused by coordinate
orientation, PPM rasterization, target/complement math, RGB tolerance, metric
sign, or neutral handling. It also separated the frozen sibling set
(`faceSmall`, `faceSlim`) from the Phase 90 strengthening comparisons
(`faceVShape`, `jawSlim`, repaired `chinTaper`).

The first revised implementation path attempted to remove the actual causes:

- face-relative outer-30%-width contiguous runs supply original-adjacency
  anchors while outer-20%-width corridors owned emissions and influence;
- endpoints, contour-global horizontal extrema, central transitions, and
  out-of-corridor anchors do not emit;
- branch-local raw deltas are centered once across the combined bilateral set
  and use one representable scale, with separate left/right/whole roughness
  guards;
- radii used the exact `min(0.015 * width, 0.8 * minimumEdgeDistance)` rule and
  preserved strict source/target corridor containment without changing sibling
  validators;
- Task 1 remains the exact Phase 89 ROI/threshold authority, while Task 2 uses
  a predeclared `.usableFace`-aligned envelope as public-route corroboration.

That sparse path was implemented exactly and then disconfirmed:

- eight local points achieved `2609/357081` target signal and exact `0/0`
  outside/central signal;
- source/neutral continuity improved only `+1 Q16`, frozen siblings were
  `[5, 8]`, and strengthening siblings were `[15, 11, 1]`;
- a diagnostic radius near `0.039` improved continuity only to `+2 Q16`.

Revision 4 therefore derives a dense-but-bounded continuous ribbon from the
same observed branches and remains in the ordinary `WarpControlPoint`
abstraction. The outer-17.5%-width owning corridors map exactly to the Task 1
frozen inner X boundaries. Accepted topology uses exactly 30 equal-arc samples
per side between first and last eligible knots; source-only radii break the
radius/displacement cycle; source-Euclidean overlap normalization, one
cap-strength mean/scale, and request-strength multiplication preserve exact
reused scaling. A finite, explicitly defined composite-field probe guards the
stored result. A diagnostic all-44 count measured 195 points from the other 43
fields, so the actual canonical combined regression stays at no more than 255
and is tested against the backend's hard 256-point limit without claiming a
global maximum for every possible accepted topology.

Exact revision-4 execution still failed the semantic oracle: 60 points produced
`11763/2512008` target signal and exact-zero protected/outside signal, but only
`-51 -> -50` (`+1 Q16`) continuity and frozen sibling margins `[5, 8]`. The
maximum coefficient/radius ratio was about `0.667`, beyond the falloff-2
inverse-map monotonicity boundary, while the amplitude-only probe remained
green. The curve also pinned the highest-leverage horizontal extrema to zero.
Revision 5 replaces the interpolated neighbor-knot curve with a compactly
tapered side-chord residual, bounds each coefficient to `0.40r`, and adds finite
same-row Jacobian probes requiring inverse derivative above `0.05`. The 60/256,
17.5%-corridor, source-only-radius, exact scaling, and no-pipeline-change
boundaries remain unchanged.

Exact revision-5 execution still yielded only `+1 Q16`; provider probes showed
that the approximate overlap-normalized coefficients delivered only
`0.0001...0.0030` displacement at observed knots despite `0.0088136` maximum
field displacement elsewhere. Extending the samples over the complete anchor
run improved the frozen metric to `+5`, proving direction but not fit. Revision
6 replaces the local normalization with a deterministic bounded compact-RBF
QP against the exact target-centred CPU basis, with 118 geometry-relative
observations, 60 variables, five equalities, source/target containment boxes,
fixed-point convergence, fit/roughness/Jacobian gates, and exact request scaling.

## Coverage summary

| Requirement | Plans | Executable evidence | Status |
| --- | --- | --- | --- |
| FACE-01 | 90-01, 90-03, 90-04 | Retained RED and aggregate terminal-attempt evidence; no compliant GREEN | BLOCKED |
| FACE-02 | 90-02, 90-03, 90-04 | Executed provider, exact generated/public pixels, sibling distinction, lifecycle and owner gates | COVERED |

## Dimension results

| Dimension | Result |
| --- | --- |
| Requirement Coverage | BLOCKED — FACE-02 is green; FACE-01 has a valid RED but no compliant implementation |
| Task Completeness | PASS — revision-6 QP/KKT, fixed-point initialization/convergence, fit, midpoint quantization, scaling, and failure rules are explicit |
| Dependency Correctness | PASS — completed 90-02 and revised 90-01 converge before serialized owner updates |
| Key Links Planned | PASS — face-relative provider output reaches the existing CPU and `.usableFace` public route |
| Scope Sanity | PASS — production change remains in one provider; no API, backend, shader, renderer, model, data, or UI expansion |
| Verification Derivation | PASS — frozen exact proof, public-route corroboration, and combined point-budget proof are explicitly separated |
| Context Compliance | PASS — 62/5/75, exact caps, request-local ownership, privacy, Phase 91/95, and nonrelease boundaries remain intact |
| Cross-Plan Data Contracts | PASS — Plan 90-02 evidence is preserved and both summaries feed Plans 90-03/04 |
| AGENTS.md Compliance | PASS — generated/in-memory evidence is primary and no private portrait detail persists |
| Pattern Compliance | PASS — provider-local named emissions, unified CPU warp, field-local degradation, and owner documents follow existing analogs |

## Structured issues

```yaml
issues:
  - severity: blocker
    requirement: FACE-01
    description: >-
      No executed provider-only candidate satisfies the frozen +16 Q16,
      sibling-distinction, locality, protection, point-budget, exact-scaling,
      and inverse-map safety contract together.
    evidence: 90-01-ATTEMPT.md
    next_step: explicit autonomous blocker decision
```

Plans 90-03/04 were synchronized with revision 4: owner documents must name
the bounded sampled ribbon and canonical 60/256 regression without making a
global topology claim, and closeout must record the retained RED, sparse
disconfirmation, actual bounded-ribbon GREEN, and Metal boundary test rather
than the superseded characterization-only narrative.

## Recommendation

Do not resume Plan 90-01 automatically. Preserve the retained RED and unchanged
production provider, keep Plans 90-03 and 90-04 blocked, and route through the
autonomous blocker decision. A retry requires a newly authorized bounded replan;
skipping leaves FACE-01 explicitly unresolved and cannot promote Phase 90.
