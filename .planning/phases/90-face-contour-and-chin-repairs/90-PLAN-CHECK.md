# Phase 90 Plan Check

**Phase:** Face Contour and Chin Repairs
**Plans verified:** 4
**Status:** EXECUTION AUTHORIZED
**Revision gate:** revision 17 independently verified after the owner-authorized branch-balanced-radius contract change
**Issues:** 0 blockers, 0 warnings

> Revision 8 addendum (2026-08-30): the owner selected `Fix and retry`. The
> historical revision-7 stop record below remains evidence of the disconfirmed
> design space, but no longer controls execution. The rewritten 90-01 plan and
> synchronized 90-03/04 contracts passed independent goal-backward review.

## Revision 17 verification verdict

Revision 15 measured valid actual Float owner/unit membership and expanded
containment but failed the fixed positive-slack gate for five retained slots
per branch. Revision 16 found no legal construction while the per-point radius
definition remained frozen. The owner then instructed autonomous continuation
and authorized one internal contract change: derive a uniform radius from the
minimum actual-target clearance on each final retained branch.

Revision 17 passed independent goal-backward review after three downstream
documentation blockers were corrected. The sole changed definition is:
compute actual Float `H_i` after final retention, set
`H_branch=min(H_i)`, use uniform branch `R=.75H_branch` and `B=.08R`,
and set `adjB=B` only for a retained original-index neighbor (otherwise zero).
The analytical proof is
`R+2B+adjB<=1.24*.75H_branch=.93H_branch<=.93H_i<.94H_i`;
execution must separately recompute and require the actual Float inequality,
strict owner/unit/expanded containment, overlap/no-triple, `0.20/0.40`,
Lipschitz/inverse, proxy, strength, budget, and frozen rendered oracle gates.
No alternate radius, threshold tuning, nonzero mandatory omission, or
rendered-output selection is permitted.

The attempt ledger contains exactly eight aggregate retry sections
(bounded-2D and revisions 9–15). A miss may append exactly one ninth
revision-17 schema suffix after that byte-exact prefix, must restore provider
and tests, emit `FACE01_STOP_VERIFIED`, create no summary, and keep downstream
plans blocked. Plans 90-03/04 consume only a GREEN D1-v17 summary, require the
exact branch-minimum formula/proof and actual Float evidence, and mark D1-v15
and revision 16 historical. Public/API/backend/Warp.metal, 62/5/75, safety
threshold, frozen oracle, privacy, SDK-only, and non-distribution boundaries
remain unchanged.

## Revision 15 verification verdict

Revision 14 stopped because its temporary execution scaffold returned an
owner-slack failure without calculating owner geometry. The owner selected
`Fix and retry`; read-only diagnosis classified this as an evidence
implementation defect, not a measured geometric miss. Revision 15 keeps all
v14 residual, zero-pair, slot, lattice, geometry, safety, proxy, and oracle
contracts unchanged and adds only the missing owner-gate computation.

Revision 15 passed independent goal-backward review with no blockers or
warnings. Execution must materialize actual Float source/target values, check
strict owner/unit membership, compute target clearance `H` to all four owner
boundaries, set fixed `R=.75H` and `B=.08R`, derive original-index `adjB` (or
zero), require `R+2B+adjB<=.94H` with positive slack, and verify expanded
support containment before overlap/proxy/oracle gates. It must record the first
actual aggregate failure rather than a placeholder.

The current attempt ledger contains exactly seven aggregate retry sections
(bounded-2D and revisions 9–14); a miss appends exactly one eighth revision-15
section after that byte-exact prefix. No threshold, public/API/backend,
privacy, or later-plan boundary changes.

## Revision 14 verification verdict

Revision 13 proved the endpoint-inclusive residual indexing and stopped at the
first genuine zero-curvature slot. The slot was valid reference geometry, not
malformed support: a piecewise-linear branch can have an exactly zero local
second difference. The owner selected `Fix and retry` again. Revision 14 keeps
the complete D1-v13 chain, exact lattice, geometry, safety, proxy, and frozen
oracle unchanged, and changes only zero-residual admission.

Revision 14 passed independent goal-backward review with no blockers or
warnings. It retains twelve analytical slots per branch, treats finite zero
residual slots as reference-only, and permits only complete bilateral omission
of nonmandatory zero pairs before lattice admission. The extrema-containing
slot and both original slot neighbors remain mandatory and must be nonzero;
after omission, original-index adjacency is recomputed without bridging,
minimum pair/all-zone coverage and every actual Float/overlap/no-triple,
containment, Lipschitz/inverse, branch-chain proxy, and frozen-output gate
remain mandatory.

The current attempt ledger contains exactly six aggregate retry sections
(bounded-2D and revisions 9–13); a miss appends exactly one seventh revision
14 section after that byte-exact prefix. No source/test or oracle threshold is
relaxed, and Plans 90-03/04 consume only a future GREEN D1-v14 summary.

## Revision 12 verification verdict

Revision 11 stopped before rendering because its D1 cap-target-first
subtraction identities were not constructible from arbitrary Float anchors.
The owner selected `Fix and retry`. A Float audit proved that a shared dyadic
`g = Float(1.0 / 16_777_216.0)` lattice with `g.bitPattern == 0x33800000`
constructs all cap/half additions and subtractions exactly; however, a second
audit found that merely repairing D1 would still fail actual containment on
three of ten carriers and made the complete-row proxy worse. D1 was therefore
retired before another execution.

Revision 12 passed independent goal-backward review with no blockers or
warnings. It is one materially distinct D1-v12 construction: a complete
bilateral chain of twelve fixed normalized arc slots per strict branch, with
the unique interior actual-Float-X extremum inserted into its nearest slot,
endpoints non-emitting, local `Delta=1/13` second-difference residuals, and
`d0=0.18*v`. Every source anchor is derived from the actual Float slot by
Binary64 ties-to-even integer indexing; every target, cap displacement, and
half displacement is materialized through the fixed `g` lattice with checked
Int64 ranges, fixed 5x5 offsets, and all exact identities asserted. Analytical
slots are distinguished from retained emitters; the frozen chain retains all
24 points, while only richer inputs may omit complete bilateral nonmandatory
pairs without bridging adjacency.

The plan uses `k=2`, strict corridor × endpoint-Y owners, actual `H/R/B/adjB`
with positive `0.94H` slack, adjacent-only overlaps/no triples, forbidden
swept-disk separation, single normalized derivative at most `0.20`, adjacent
sum at most `0.40`, global Lipschitz at most `0.40`, inverse lower bound at
least `0.60`, and a strict positive-slack branch-chain proxy before rendering.
The proxy is explicitly not an exact forward-image location; the unchanged
frozen rendered oracle is the semantic authority. Zone occupancy is computed
from actual normalized slot progress under the fixed four/four/four chain
zones, eliminating the obsolete `2/1/2` aggregate discrepancy.

The frozen oracle/hash, all semantic/locality/protection/sibling thresholds,
public/product/API/backend/Warp.metal boundaries, privacy rules, exact 62/5/75
inventory, and 30/256 point budgets remain unchanged. Structural provider tests
and `DESIGN.md` change only after GREEN. On a miss, the provider/test bytes
are restored, the current five-section attempt prefix remains byte-exact, one
revision-12 aggregate-only suffix is appended, `FACE01_STOP_VERIFIED` must
pass, no summary is created, and Plans 90-03/04 remain blocked.

## Revision 11 verification verdict

Revision 10 proved that the frozen seven-point-per-side support can satisfy the
exact Float, locality, containment, and inverse-map gates, but its four-pair C1
field improved source/neutral continuity by only `+1/+1 Q16`. The owner selected
`Fix and retry` again. Two read-only architecture audits identified the highest
leverage degree of freedom that earlier families had pinned to zero: the unique
interior horizontal extremum on each branch. They also found and removed an
infeasible medial-carrier formula before execution.

Revision 11 passed independent goal-backward review with no blockers or
warnings. D1 is the sole finite construction. The left unique interior
actual-Float-X argmin and right argmax must occupy the same paired class; their
original immediately preceding shoulder class is fixed before output. The
cap-target anchors use the fixed `0.80/0.20` blend, direct class-secant
horizontal residuals, cap-target-first exact-half Float lattice, and original
six-class adjacency. No rendered result can choose a class, carrier, constant,
radius, overlap edge, fallback, or second candidate.

The plan derives `H/C/G/R/B` from actual Float cap targets, requires one fixed
adjacent overlap per side, strictly separates all forbidden swept target disks,
prevents omission from creating bridge adjacency, and proves at most two active
supports. The actual emitted field has a global Lipschitz bound at most `0.40`
and inverse lower-distance bound at least `0.60`; `0.96H` containment, positive
representative support, a predeclared provider-side field-energy proxy decrease,
exact renderer L1 admission, and every positive-strength final-set gate are
checked before the unchanged frozen oracle runs once.

The unique extremum emission changes only an internal provider structural
contract. The frozen oracle, public API/product meaning, cap, renderer/backend,
`Warp.metal`, privacy boundary, exact 62/5/75 inventory, and point limits remain
unchanged. Structural provider tests and `DESIGN.md` change only after GREEN.
On a miss, source/test bytes are restored, the complete current four-record
attempt prefix remains byte-exact, one revision-11 aggregate-only suffix is
appended, `FACE01_STOP_VERIFIED` must pass, no summary is created, and Plans
90-03/04 remain blocked.

## Revision 10 verification verdict

Revision 9 stopped before algorithm execution because the frozen strict
corridor branches contain seven points per side while the plan required eight.
The owner selected `Fix and retry`; a read-only support audit confirmed three
distinct non-emitting anchors and four eligible knots per side. C1 can retain
four corresponding pairs with upper/middle/lower reachability `1/1/2`, while
C2's five-pair minimum is arithmetically impossible.

Revision 10 passed independent review with no issues. It corrects the minimum
to seven, requires the three anchor roles to remain distinct, retains only C1
with its previously verified formulas/classes/constants, and removes C2 rather
than weakening its topology or emitting/reusing protected sources. The frozen
four-pair topology fails on any pair miss; only richer generated contours may
continue after paired omission while at least four balanced pairs and all
three zones survive.

The exact renderer L1 predicate, half-first Float lattice, bilateral energy,
fixed-cell containment, global `0.90` Lipschitz / `0.10` inverse-distance
proof, frozen oracle, point budgets, and SDK-only boundaries remain unchanged.
The revision-10 stop path preserves the complete three-section attempt prefix
and may append only one singular-C1 aggregate section after verified rollback.

## Historical revision 9 verification verdict

The owner selected `Fix and retry` again after revision 8 safely stopped. The
new plan is execution-ready and passed an independent checker with no issues.
It replaces the A4-derived candidate family with two materially distinct,
paired clearance-cell integrations: clipped-secant residuals and
centroid-neighbor baselines.

The plan now defines canonical branch ordering, arc progress, exact
piecewise-linear integration, outward normals, source-class tie-breaking,
half-first 25-state Float construction, exact renderer L1 admission, checked
bilateral fairing energy, paired local omission without promotion, and exact
upper/middle/lower final-set invariants. Renderer-effective radius,
fixed-cell containment, falloff-1 Lipschitz `0.90`, and the resulting global
inverse lower-distance `0.10` are certified before output.

The revision-9 stop path preserves both prior attempt sections byte-exact,
exports every captured hash/RED/verifier value into one command environment,
and permits a third aggregate-only suffix only after provider/test rollback and
`FACE01_STOP_VERIFIED`. Plans 90-03/04 consume only a GREEN summary and remain
blocked on a miss.

## Historical revision 8 verification verdict

Execution may resume. The rewritten plan preserves the byte-frozen FACE-01
oracle and its original SHA-256, bounds selection to seven predeclared
two-dimensional provider-local candidates, and keeps the public inventory,
renderer, backend, shader, model/data, UI, privacy, and owner-local boundaries
unchanged.

The actual CPU map is certified with its renderer-effective radius and moving
target centres for every accepted strength from identity through `0.25`.
Strict continuous swept-support separation, expanded-disk containment, and a
cap-max analytical Lipschitz bound establish the global `0.05` lower-distance
and injectivity contract; cap/half and finite Jacobian probes are supplemental.

The retry also owns a retained read-only stop verifier with a literal command
contract. A seven-candidate miss must restore the provider and frozen test
bytes, preserve the oracle hash and exact RED aggregate, append one
aggregate-only attempt section, prove later artifacts absent/restored, and
exit with `FACE01_STOP_VERIFIED` before returning a typed blocker. Every
repository write, candidate switch, append, and rollback uses `apply_patch`.

Plans 90-03/04 now consume only a completed 90-01 summary for the selected
family, measured count, renderer-effective certificate, and canonical payload
evidence. They no longer carry the disconfirmed sampled-ribbon/60-point claim.

## Historical revision 7 record

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

## Historical revision 7 recommendation

Historical only: at revision 7, the recommendation was not to resume Plan
90-01 automatically. Preserve the retained RED and unchanged
production provider, keep Plans 90-03 and 90-04 blocked, and route through the
autonomous blocker decision. That recommendation was superseded by later
owner-selected retries and does not control revision-17 execution.
