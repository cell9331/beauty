# Phase 90 FACE-01 Revision 18 - Displacement/Target Feasibility Research

**Researched:** 2026-09-01  
**Domain:** deterministic target-centred contour warp construction  
**Confidence:** HIGH for analytical safety and frozen-geometry pre-output feasibility; LOW for the uninvoked rendered semantic oracle

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Preserve exactly 62 public parameter fields, five presets, 75 renderer cases,
  both public still-image facade signatures, and the current CPU/GPU contract.
- Do not change retained `Warp.metal`, add a Metal/GPU API/backend, add public
  controls, restore UI/Demo code, or introduce models, weights, datasets,
  network paths, realtime/video work, or device/commercial claims.
- Keep the exact established safety caps, neutral identity, request-local
  support ownership, per-control degradation, privacy-safe diagnostics, and
  source-safe collision behavior.
- Do not weaken Phase 89 semantic thresholds to make a repair pass and do not
  borrow another control's semantic support or behavior as a proxy.

### the agent's Discretion
All implementation choices are at the agent's discretion — discuss phase was
skipped per user setting. Use the ROADMAP success criteria, the frozen Phase 89
semantic contracts, `DESIGN.md`, `ARCHITECTURE.md`, `RELIABILITY.md`,
`SECURITY.md`, `QUALITY_SCORE.md`, and existing provider/resolver conventions.

### Deferred Ideas (OUT OF SCOPE)
Independent gaze, eyebrow-head spacing, nose, mouth-width, the final complete
eight-direction portrait rerun, local-retouch optimization, and all external or
device evidence remain assigned to Phases 91-95 or future milestones.
</user_constraints>

The text above is copied from `90-CONTEXT.md`; the locked-boundary bullets are the `Locked Boundaries` subsection of its decisions. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-CONTEXT.md]

<phase_requirements>
## Phase Requirements

| ID | Description | Research support |
|---|---|---|
| FACE-01 | Positive `faceContourSmooth` must produce detectable contour-local continuity, remain distinct from the named siblings, and preserve bounded protected regions. | This report proves one displacement-only construction can reach every unchanged pre-output safety gate on the frozen geometry; it deliberately leaves the frozen rendered semantic verdict unknown until a separately planned one-shot execution. [CITED: .planning/REQUIREMENTS.md] |
</phase_requirements>

## Project Constraints (from AGENTS.md)

- The repository remains an SDK-only Swift package; historical UI/Demo material is not a build, test, or requirements input. [CITED: AGENTS.md]
- The work must preserve owner-local use, non-distribution, the existing renderer/backend, and retained `Warp.metal`; no new algorithm family, model, weight, data, network, UI, realtime route, device gate, or commercial/release claim is authorized. [CITED: AGENTS.md]
- Geometry evidence must use deterministic SwiftPM/SDK-owned checks, actual output only at the authorized execution gate, typed failure, deterministic recovery, and privacy-safe aggregate persistence. [CITED: AGENTS.md]
- Durable evidence must not contain anatomical coordinates, raster content, support maps, private fixture locators, or subprocess transcripts. [CITED: AGENTS.md]
- `DESIGN.md` owns the current effect state machine, `docs/SDK_EFFECT_TAXONOMY.md` owns the 62-field taxonomy, and code/tests outrank planning and historical prose. [CITED: AGENTS.md]
- The project skill reinforces request-local support, fail-closed ownership, original-input composition, and the rule that mechanics evidence does not establish product or device quality. [CITED: .codex/skills/spike-findings-beauty/SKILL.md]

## Summary

Revision 18 has one pre-output-feasible construction under the unchanged revision-17 topology, radius/owner law, and safety thresholds: **source-clearance-clipped exact-lattice residuals**. Keep the revision-17 raw lattice state only as the deterministic sign and residual reference, but clip each emitted integer displacement coefficient by one branch-global limit derived from the final actual-Float lattice sources. [VERIFIED: codebase plan/history audit]

Let `g = 2^-24`, let `q17_i` be the exact signed revision-17 lattice coefficient, let `Hsrc_branch` be the minimum actual-Float source clearance to the same four owner boundaries over the final retained branch, and define:

```text
qLimit_branch = floor(Hsrc_branch / (64 * g))
q18_i         = sign(q17_i) * min(abs(q17_i), qLimit_branch)
d18_i         = 4 * q18_i * g
half18_i      = 2 * q18_i * g
target18_i    = source_i + d18_i
```

The constant is fixed: `1/16` of branch-minimum source clearance, expressed as `Hsrc/(64g)` because cap displacement is `4qg`. No candidate set, interval, tuning loop, rendered selection, or oracle call is part of the construction. [VERIFIED: deterministic binary32 feasibility audit]

This construction analytically bounds each single contribution by `8/45`, any allowed adjacent pair and the resulting no-triple global Lipschitz certificate by `16/45`, and the inverse lower distance by `29/45`. Those values satisfy the frozen `0.20`, `0.40`, `Lip<=0.40`, and inverse `>=0.60` gates with positive slack. [VERIFIED: algebra below]

The frozen-geometry actual binary32 audit also preserves the required adjacent overlap, forbidden-pair separation, exact cap/half linkage, positive owner slack, and strict branch-chain proxy decrease. The rendered semantic oracle was not invoked, so semantic acceptance remains unknown and must not be predicted as GREEN. [VERIFIED: deterministic pre-output audit]

**Primary recommendation:** write one independently reviewed revision-18 plan for this construction only, then execute it once; any pre-output or rendered miss must restore source/tests byte-exact and append exactly one tenth aggregate-only stop suffix. [VERIFIED: revision-17 rollback contract plus owner authorization commit `a9b6acc`]

## Architectural Responsibility Map

| Capability | Primary tier | Secondary tier | Rationale |
|---|---|---|---|
| Canonical branch, slots, paired zero omission | `BeautyEffects` provider | generated provider tests | Request-local geometry is package-internal and must fail only FACE-01 closed. [CITED: ARCHITECTURE.md] |
| Exact displacement/target construction | `BeautyEffects` provider | generated Float proof | `WarpControlPoint` stores binary32 source/target/radius and is the only authorized revision-18 seam. [CITED: BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift] |
| Radius and inverse safety | `BeautyEffects` provider admission | CPU reference tests | Revision 17 fixes actual-target `H_branch`, `R=.75H_branch`, `B=.08R`; revision 18 may not change it. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md] |
| Rendering and semantic verdict | unchanged CPU renderer and frozen oracle | public facade tests | The renderer ignores `WarpControlPoint.strength`, uses target-centred additive sampling, and rejects L1 displacement at or below `0.0001`. [CITED: BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift] |
| Public inventory and backend contract | existing resolver/facades | compatibility tests | The exact 62/5/75 inventory and CPU/GPU contract are frozen. [CITED: docs/SDK_EFFECT_TAXONOMY.md] |

## Evidence from Revisions 11-17

| Revision | First proven stop | Consequence for revision 18 |
|---|---|---|
| 11 | Arbitrary source/target Float subtraction did not preserve the required exact cap/half identities. [CITED: commit `9386405`] | Keep one integer `g=2^-24` lattice and materialize every linked value from integers. |
| 12 | The complete twelve-slot design initially stopped at lattice construction. [CITED: commit `1277238`] | Retain the later corrected lattice; do not return to free Float target arithmetic. |
| 13 | Correct endpoint-inclusive residual indexing reached valid zero residuals. [CITED: commit `63e3e6c`] | Keep all analytical slots and treat only complete bilateral nonmandatory zero pairs as reference-only. |
| 14 | The owner gate was not actually computed. [CITED: commit `392a987`] | Every revision-18 result must be measured from final actual binary32 source/target values. |
| 15 | Per-point owner slack failed because neighboring radii differed. [CITED: commits `913fbea`, `6ac783f`] | Preserve the revision-17 uniform branch radius; do not alter owner thresholds. |
| 16 | No legal carrier-only correction existed under the per-point radius contract. [CITED: commit `53a6748`] | The owner-authorized displacement seam, not another slot selection, is the remaining degree of freedom. |
| 17 | Branch-minimum owner/slack/containment and overlap gates passed; the first miss was the single normalized displacement bound. [CITED: commits `48fc3de`, `3ea91d7`] | Reduce displacement before output while preserving the complete retained topology and exact radius law. |

## Sole Construction: Source-Clearance-Clipped Exact Lattice

### Frozen inputs and order

1. Reuse revision 17's canonical branches, twelve analytical slots per branch, extrema placement, endpoint-inclusive residual evaluation, bilateral zero-pair omission, mandatory extremum-and-neighbor topology, zone coverage, original-index adjacency, and final retained order without modification. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]
2. Run the existing exact `g=2^-24` raw lattice construction against `d0=.18v` only to obtain each nonzero signed `q17_i` and exact source integer `a_i`; this is a deterministic residual/sign reference, not an emitted target and not a candidate. [VERIFIED: revision-17 plan contract]
3. After the final bilateral retained set is known, compute actual-Float source clearance `Hsrc_i` to the unchanged owner rectangle and `Hsrc_branch=min(Hsrc_i)`. Require it finite and positive. [VERIFIED: analytical construction]
4. Compute `qLimit_branch=floor(Double(Hsrc_branch)/(64*Double(g)))` once with checked finite/range conversion. A zero limit, a sign loss, a mandatory zero, or any overflow fails the whole FACE-01 field closed. [VERIFIED: analytical construction]
5. Emit only `q18_i=sign(q17_i)*min(abs(q17_i),qLimit_branch)`. Rebuild cap, half, and target from `a_i`, `q18_i`, and the one materialized `g`; do not subtract arbitrary Float anchors. [VERIFIED: exact-lattice construction]
6. Recompute actual-target `H_i`, `H_branch`, uniform `R=.75H_branch`, uniform `B=.08R`, original-neighbor `adjB`, owner/unit/expanded containment, overlap/no-triple, single/adjacent/Lipschitz/inverse, proxy, strength, and budget gates in the unchanged revision-17 order. Any miss returns the entire named field empty. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]

### Exact representation obligations

For each retained coefficient, the implementation must prove all of these equalities from the integer construction: `d=half+half`, `d*.5=half`, `target-source=d`, `source+d=target`, `halfTarget-source=half`, and `source+half=halfTarget`. [VERIFIED: revision-17 exact-lattice contract]

The cap and exact half must retain identical bilateral sources, order, radii, falloff, and count; both must pass the unchanged strict renderer L1 predicate. [CITED: BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift]

## Analytical Necessary and Sufficient Inequalities

### Exact per-point and adjacent tests

With `d_i=4q_i g` and uniform branch radius `R`, the unchanged single gate is exactly equivalent to `8*abs(q_i)*g <= .20R`. [VERIFIED: algebra]

For an allowed original-adjacent pair, the unchanged pair gate is exactly equivalent to `8g*(abs(q_i)+abs(q_j)) <= .40R`. [VERIFIED: algebra]

The exact half renderer admission is `2*abs(q_i)*g > .0001`; equality is rejected. [CITED: BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift]

These scalar inequalities are necessary and sufficient for their named gates, but not sufficient for the whole field: final actual-Float owner containment, permitted-overlap topology, global Lipschitz, inverse, proxy, budget, and frozen rendered semantics remain independent conjunction members. [VERIFIED: revision-17 plan contract]

### Construction-wide sufficient proof

Let `Hs=Hsrc_branch` and `D=max_i(abs(d18_i))`. The fixed clip gives `D<=Hs/16`. [VERIFIED: construction]

Clearance to a fixed rectangle boundary is 1-Lipschitz under horizontal displacement, so every final target has clearance at least its source clearance minus `D`; therefore `H_branch>=Hs-D>=15Hs/16`. [VERIFIED: elementary distance inequality]

The unchanged radius law then gives `R=.75H_branch>=45Hs/64`. [VERIFIED: algebra]

Therefore:

```text
single <= 2*(Hs/16)/(45Hs/64) = 8/45  = 0.177777...
adjacent/global Lip <= 2*(8/45)       = 16/45 = 0.355555...
inverse lower bound >= 1 - 16/45      = 29/45 = 0.644444...
```

The global Lipschitz implication additionally requires the already-frozen fact that only one original-adjacent pair can be active and no triple or forbidden overlap exists; execution must recompute that topology rather than assume it. [VERIFIED: revision-17 topology contract]

The revision-17 owner proof is unchanged: `R+2B+adjB<=.93H_branch<.94H_i`; the construction must also recompute the actual binary32 inequality and strict expanded containment. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]

## Deterministic Actual-Float Pre-Output Measurements

The audit used the frozen generated geometry and the exact documented operation order, materializing every arithmetic state as IEEE-754 binary32 before each subsequent gate. It did not render, invoke the frozen oracle, inspect output, sweep a coefficient, or select among candidates. [VERIFIED: local deterministic audit]

| Aggregate per branch | Left | Right | Required result |
|---|---:|---:|---|
| Retained emitters | 10 | 10 | Retain revision-17 paired zero omission and mandatory topology. [VERIFIED: binary32 audit] |
| Coefficients clipped | 7 | 7 | Descriptive only; no pair was omitted or reselected. [VERIFIED: binary32 audit] |
| `Hsrc_branch` in Q24 units | 352866 | 352866 | Finite and positive. [VERIFIED: binary32 audit] |
| `qLimit` integer | 5513 | 5513 | Exactly `floor(Hsrc/(64g))`. [VERIFIED: binary32 audit] |
| Final actual-target `H_branch` in Q24 units | 374918 | 374918 | Finite and positive. [VERIFIED: binary32 audit] |
| Final `R` in Q24 units | 281188 | 281188 | Exact unchanged `.75H_branch` Float result. [VERIFIED: binary32 audit] |
| Maximum single ratio, Q16 | 10279 | 10279 | Pass; threshold 13107, sanitized margin 2828. [VERIFIED: binary32 audit] |
| Maximum adjacent/Lipschitz ceiling, Q16 | 20558 | 20558 | Pass; threshold 26214, sanitized margin 5656. [VERIFIED: binary32 audit] |
| Inverse lower bound, Q16 | 44978 | 44978 | Pass; threshold 39322, sanitized margin 5656. [VERIFIED: binary32 audit] |
| Required adjacent overlap count | 1 | 1 | Pass; original-index adjacency only. [VERIFIED: binary32 audit] |
| Minimum forbidden-separation margin, Q24 | 536843 | 536844 | Strictly positive. [VERIFIED: binary32 audit] |
| Minimum cap/half displacement, Q24 | 3524 / 1762 | 3524 / 1762 | Both strictly pass the renderer L1 floor. [VERIFIED: binary32 audit] |
| Minimum owner-slack margin, Q24 | 3749 | 3749 | Strictly positive. [VERIFIED: binary32 audit] |
| Exact cap/half linkage failures | 0 | 0 | Pass. [VERIFIED: binary32 audit] |
| Proxy before/after, Q40 | 1615658268 / 1454804210 | 1615656039 / 1454802266 | Strict decrease with positive deltas 160854058 / 160853773. [VERIFIED: binary32 audit] |

The frozen geometry therefore has positive pre-output margins at every gate reached by revision 17 and at every unchanged downstream analytical gate, including the proxy. This is feasibility evidence for one execution, not rendered semantic evidence. [VERIFIED: binary32 audit]

## Arbitrary Positive Strength Boundary

Under the unchanged revision-17 finalization, `m_s=round(2*alpha*q18)` and `d_s=2*m_s*g`. For sufficiently small positive `alpha`, finite integer rounding yields `m_s=0`; before that, the unchanged renderer also rejects any nonzero L1 displacement at or below `0.0001`. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md; BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift]

This is a pre-existing renderer/strength-quantization fact, not a revision-18 defect. Revision 17 explicitly allowed another positive strength to fail closed while requiring cap and exact half topology to match. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]

Consequently, no displacement-only revision can emit a meaningful nonzero field for **every arbitrarily small positive representable strength** while also preserving the strict renderer L1 predicate, neutral identity, current strength law, and unchanged renderer. That literal requirement is impossible under the authorized seam. [VERIFIED: integer-rounding and admission contradiction]

The sole construction is feasible only under the unchanged revision-17 interpretation: cap and exact half are meaningful and nonzero; every other accepted positive strength is recertified, and the whole FACE-01 field fails closed if quantization or any final-set gate cannot admit it. [VERIFIED: revision-17 contract]

## Predicted Gate Margins and Unknowns

| Gate | Prediction before execution | Confidence |
|---|---|---|
| Exact cap/half/linkage | Pass with zero observed identity failures. [VERIFIED: binary32 audit] | HIGH |
| Owner/unit/slack/expanded containment | Pass on frozen geometry with positive sanitized slack. [VERIFIED: binary32 audit] | HIGH |
| Adjacent-only overlap/no triple | Pass on frozen geometry; one required overlap remains on each branch and forbidden separation is positive. [VERIFIED: binary32 audit] | HIGH |
| Single `0.20` | Pass at 10279 Q16, margin 2828. [VERIFIED: binary32 audit] | HIGH |
| Adjacent/global `0.40` | Pass at 20558 Q16, margin 5656. [VERIFIED: binary32 audit] | HIGH |
| Inverse `0.60` | Pass at 44978 Q16, margin 5656. [VERIFIED: binary32 audit] | HIGH |
| Fixed branch-chain proxy | Pass with about ten percent aggregate squared-error reduction on both branches. [VERIFIED: binary32 audit] | HIGH |
| Frozen rendered semantics and protections | Unknown; the oracle was intentionally not invoked and the proxy is not an output oracle. [VERIFIED: research boundary] | LOW |

## Don't Hand-Roll or Reopen

| Problem | Prohibited response | Required mechanism |
|---|---|---|
| Exact Float linkage | Arbitrary source/target subtraction | The retained integer `g=2^-24` construction. [VERIFIED: revision 11-12 history] |
| Safety after clipping | Copying analytical bounds as runtime evidence | Recompute every final actual-Float gate and fail the whole named field closed. [VERIFIED: revision 14-17 history] |
| Semantic uncertainty | Parameter sweep, proxy substitution, or threshold change | One frozen-oracle invocation only after all pre-output gates. [CITED: 90-CONTEXT.md] |
| Small-strength quantization | Renderer change, new dead zone, minimum forced displacement, or partial topology | Preserve revision-17 all-strength fail-closed semantics; escalate only if the owner explicitly reopens a different contract. [VERIFIED: scope analysis] |
| More signal | Radius/owner change, mandatory omission, slot reselection, or backend/shader work | No legal fallback in revision 18. [CITED: owner authorization commit `a9b6acc`] |

## Common Pitfalls

### Using final-target clearance to set the clip

That creates a target/radius/displacement cycle. Use final source clearance for the deterministic clip, then recompute the unchanged actual-target radius law. [VERIFIED: construction analysis]

### Claiming the analytical `8/45` bound proves the whole field

It proves the single bound; the adjacent/global proof also depends on actual permitted-overlap/no-triple topology, and the frozen semantic verdict remains separate. [VERIFIED: revision-17 contract]

### Letting clipping omit or reselect a mandatory pair

Clipping changes only coefficient magnitude. Any coefficient that becomes zero or misses cap/half admission fails the complete field; it never triggers pair omission, promotion, or a second construction. [VERIFIED: revision-18 construction]

### Treating the proxy as the rendered result

The proxy is a deterministic pre-output monotonicity check. It cannot authorize threshold changes or predict the frozen rendered semantic gate. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]

## Validation Architecture

| Requirement | Test type | Required automated evidence |
|---|---|---|
| Construction determinism | unit | Reversal, repeated construction, fixed source-clearance limit, fixed q clipping, and aggregate equality. [VERIFIED: planned test design] |
| Exact representation | unit | Cap/half/source/target identities, bit-pattern `g`, checked integer ranges, strict L1 at cap and half. [VERIFIED: planned test design] |
| Analytical safety | unit | Mutation tests around `1/16`, the `8/45`, `16/45`, `29/45` bounds, and actual-Float recomputation. [VERIFIED: planned test design] |
| Topology and proxy | unit | Retained twelve-slot/zero-pair/mandatory inventory, original adjacency only, overlap/no-triple, strict proxy decrease. [VERIFIED: planned test design] |
| Frozen semantic contract | generated CPU integration | Existing pinned method/hash, invoked once only after every pre-output gate. [CITED: FaceContourSmoothRepairTests.swift] |
| Public compatibility | integration | Existing public facade, exact 62/5/75, point budget, backend and metadata suites. [CITED: QUALITY_SCORE.md] |

**Quick pre-output command:** focused FACE-01 provider tests only; the planner must name the new revision-18 methods without editing the frozen oracle. [VERIFIED: repository test layout]

**Execution gate:** run the frozen generated oracle once only after focused pre-output tests pass. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]

## Tenth-Retry Execution and Rollback Evidence Schema

Before any edit, capture byte counts and SHA-256 values for the provider, complete repair test, current nine-section attempt prefix, later owned tests/docs, `STATE.md`, `PLANS.md`, stop verifier, and frozen method slice. Require the revision-17 stop heading present exactly once and no revision-18 heading or summary. [VERIFIED: revision-17 rollback pattern]

On a miss, append exactly one suffix with this heading:

```text
## 2026-09-01 FACE-01 source-clearance-clipped D1-v18 revision-18 retry stop
```

Use these fields in this exact order, with aggregate/fixed-point values only: [VERIFIED: recommended schema]

```text
implementation
gate_bitmask
first_failure
canonical_branch_counts
slot_counts
extremum_slot_indices
zone_slot_counts
residual_progress_pairs
residual_boundary_assertions
residual_indexing_status
residual_zero_counts
omitted_pair_counts
raw_lattice_status
source_clearance_clip_status
clipped_coefficient_counts
exact_linkage_failure_counts
branch_min_source_clearance_status
branch_min_target_clearance_status
owner_slack_proof_status
actual_float_gate_counts
adjacent_overlap_counts
forbidden_swept_disks
max_single_q16
max_adjacent_q16
max_lipschitz_q16
inverse_lower_bound_q16
branch_chain_proxy_delta_q40
strength_finalization_status
q16_signal_counts
admitted_point_count
lattice_rejection_count
oracle_sha256
rollback_status
```

The verifier must require the complete current nine-section prefix byte-exact, exactly one tenth suffix, exact provider/repair-test restoration through `apply_patch`, all later artifacts restored or absent, no summary, preserved orchestrator-owned ledgers, only the attempt file as an allowed diff, and terminal `FACE01_STOP_VERIFIED`. [VERIFIED: revision-17 verifier contract adapted to suffix ten]

On GREEN, create the normal summary only after the frozen oracle and public/compatibility gates pass; do not append a stop suffix. [VERIFIED: existing plan convention]

## Risks and Stop Conditions

- Seven of ten retained coefficients per branch are clipped on the frozen geometry, so rendered semantic strength is the principal unresolved risk even though the proxy remains positive. [VERIFIED: binary32 audit]
- Exact half admission has a positive but comparatively narrow integer margin at the smallest retained coefficient; any operation-order change can invalidate it. [VERIFIED: binary32 audit]
- A different valid contour can have a smaller source-clearance limit, lose required half admission or overlap, or miss the proxy; the correct outcome is whole-field fail-closed, not a new limit. [VERIFIED: construction analysis]
- The actual global Lipschitz implementation must be recomputed; the adjacent sum is a sufficient certificate only while the unchanged adjacent-only/no-triple topology passes. [VERIFIED: analytical proof]
- If the frozen oracle is RED, no parameter change, second coefficient, threshold relaxation, or output-guided retry is authorized. Restore and stop. [CITED: owner authorization commit `a9b6acc`]
- If “arbitrary positive strength” is interpreted as mandatory nonzero renderer emission for every positive Float, revision 18 is terminally impossible for the existing renderer reason documented above. [VERIFIED: scope contradiction]

## Security Domain

| ASVS category | Applies | Control |
|---|---|---|
| V2 Authentication | no | No identity or authentication seam changes. [CITED: SECURITY.md] |
| V3 Session Management | no | The provider is request-local and stateless. [CITED: ARCHITECTURE.md] |
| V4 Access Control | yes, package boundary | Keep support and construction package-internal; expose no new public or diagnostic surface. [CITED: ARCHITECTURE.md] |
| V5 Input Validation | yes | Finite/range/uniqueness/topology/integer/Float/owner checks fail the named field closed. [VERIFIED: construction] |
| V6 Cryptography | no runtime crypto | SHA-256 is evidence integrity only; no new cryptographic behavior is introduced. [VERIFIED: plan history] |

No external package, dependency, service, model, or network path is introduced; therefore no package legitimacy audit is required. [VERIFIED: construction inventory]

## Open Questions (RESOLVED)

1. **RESOLVED — Will the frozen rendered oracle pass?**
   - Known: every pre-output gate has a positive frozen-geometry margin. [VERIFIED: binary32 audit]
   - Unknown: whether the clipped field reaches the unchanged semantic floor and sibling margins while preserving all protections. [VERIFIED: oracle intentionally not invoked]
   - Recommendation: answer only through one independently planned execution after all pre-output tests pass. [VERIFIED: research boundary]

2. **RESOLVED — How should “arbitrary positive strength” be read?**
   - Known: revision 17 allows a non-cap/non-half positive strength to fail closed, and the renderer has a fixed displacement floor. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md; BeautyGeometryEffectPipeline.swift]
   - Recommendation: preserve that existing meaning. If nonzero emission for every positive Float is newly mandatory, record terminal impossibility instead of changing the renderer or neutral contract. [VERIFIED: scope analysis]

## Sources

### Primary (HIGH confidence)

- `AGENTS.md`, `PLANS.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`. [VERIFIED: codebase read]
- Phase 90 context, current plan, attempt ledger, and plan check. [VERIFIED: codebase read]
- `FaceShapeWarpProvider.swift`, `WarpControlPoint.swift`, `BeautyGeometryEffectPipeline.swift`, and `FaceContourSmoothRepairTests.swift`. [VERIFIED: codebase read]
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and the taxonomy. [VERIFIED: codebase grep/read]
- Git history from revision 11 through owner authorization `a9b6acc`. [VERIFIED: git history]
- Deterministic no-render IEEE-754 binary32 construction audit. [VERIFIED: local computation]

### Secondary / tertiary

None. This is a codebase-only feasibility question; no external package or current web fact is needed. [VERIFIED: research scope]

## Assumptions Log

| # | Claim | Risk if wrong |
|---|---|---|
| A1 | The phrase “arbitrary positive strength” retains revision 17's fail-closed semantics rather than requiring nonzero renderer admission for every positive Float. [ASSUMED] | If false, no legal revision-18 construction exists under the unchanged renderer and neutral contract. |

## Metadata

**Confidence breakdown:**

- Construction algebra: HIGH — closed-form inequalities with fixed constants. [VERIFIED: algebra]
- Exact representation: HIGH — integer lattice and binary32 identities measured. [VERIFIED: local computation]
- Frozen-geometry safety/topology/proxy: HIGH — deterministic pre-output measurements only. [VERIFIED: local computation]
- Rendered semantic result: LOW — intentionally not invoked. [VERIFIED: research boundary]

**Research date:** 2026-09-01  
**Valid until:** the next FACE-01 provider/renderer/topology contract change
