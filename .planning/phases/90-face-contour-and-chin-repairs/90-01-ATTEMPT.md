---
phase: 90
plan: "01"
requirement: FACE-01
status: implementation-blocked
promotion_eligible: false
recorded: 2026-08-29
---

# FACE-01 Implementation Attempt

Plan 90-01 reached its explicit stop condition. The frozen generated CPU oracle
remains RED, and no attempted provider-local field simultaneously met the
`+16 Q16` continuity floor, sibling distinction, target locality, protected
regions, point budget, exact scaling, and inverse-map safety requirements.

## Frozen baseline

The committed RED measured the existing production behavior at exact cap:

- source/neutral continuity margin `+12 Q16`, below the required `+16`;
- frozen sibling margins `[16, 3]`, with `faceSlim` below `16`;
- outside signal `2724/284565`, above `500/1500`;
- central signal `909/138177`, above `128/512`;
- target signal passed, and background/watermark remained byte-exact.

The contract, generated fixture, Phase 89 comparator, regions, siblings, signs,
and thresholds were not changed.

## Bounded attempts

| Attempt | Aggregate result | Disposition |
| --- | --- | --- |
| Sparse owned-kink field | `+1 Q16`; target `2609/357081`; outside and central `0/0` | Local but semantically insufficient. |
| 60-point sampled ribbon | `+1 Q16`; target `11763/2512008`; outside and central `0/0` | Dense signal did not improve row-wise continuity. |
| Tapered complete-run ribbon | Best safe result `+5 Q16` | Direction confirmed, acceptance not met. |
| Compact-RBF/QP revision | `+1 Q16` under diagnostic bypass; provider path took roughly `52...122 s` | Rejected for fit/roughness/Jacobian failures and denial-of-service cost. |
| O(n) chord-kink carriers | Finite planned scales could not satisfy the frozen oracle and safety gates together | Rejected under the plan's stop rule. |
| Target-centred collocation diagnostic | Best safe result `+5 Q16`; higher amplitudes failed displacement/radius or Jacobian gates | Diagnostic only; forbidden from becoming another retained solver. |

For the final diagnostic, the `0.40` scale reached a maximum sampled derivative
of about `0.9991`, leaving only about `0.0009` inverse-map Jacobian margin
against the required `>0.05`. The `0.50` scale exceeded unity at about `1.2488`.
The `0.65` and `0.80` scales also exceeded their field-to-radius bound at an
owned target. Relaxing these checks would admit folding or support escape and
is not an acceptable GREEN.

Wider support could raise the semantic margin to `+9 Q16`, but it changed
`1443` outside pixels with `38835` absolute RGB delta. Boundary-cancellation
variants restored protection but fell back to `+2...+4 Q16`. This rules out
support expansion as a compliant fix within the current provider abstraction.

## Preserved state

- Failed production experiments and temporary aggregate diagnostics were
  removed from the worktree.
- The committed generated RED remains the executable reproduction.
- `FaceShapeWarpProvider` remains at the pre-attempt production behavior.
- No renderer, pipeline, Metal shader, backend, public API, parameter, preset,
  renderer case, dependency, model, network, UI, or private-media surface was
  changed.
- No raw pixels, landmarks, contour coordinates, masks, media paths, or
  per-fixture private reports are retained here.

## Blocker

FACE-01 cannot be completed under Plan 90-01's frozen contract and bounded
provider-only design space. Per the plan, execution stops instead of adding a
new solver or weakening the contract. Phase 90 Plans 90-03 and 90-04 remain
blocked because they require both Wave 1 summaries.

User direction is required to choose one of the autonomous blocker routes:
authorize a new bounded replan, skip Phase 90 with FACE-01 unresolved, or stop
the autonomous run.

## 2026-08-30 FACE-01 bounded-2D retry stop

- candidates: A1,A2,A3,A4,B1,B2,B3 in the frozen order; all seven completed
- gate_bitmasks: bits oracle-hash=0x01,safety=0x02,frozen-oracle=0x04; A1=0x01,A2=0x01,A3=0x01,A4=0x01,B1=0x01,B2=0x01,B3=0x01
- q16_signal_counts: every candidate source=0,neutral=0,frozen-siblings=[4,9],strengthening-siblings=[16,12,0]
- point_counts: A1=0,A2=0,A3=0,A4=0,B1=0,B2=0,B3=0 after renderer-effective analytical admission
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts restored or absent; FACE01_STOP_VERIFIED

## 2026-08-30 FACE-01 budget-first revision-9 retry stop

- candidates: C1,C2 in the frozen order; both completed
- gate_bitmasks: bits oracle-hash=0x01,canonical-support=0x02,budget-lattice-global-safety=0x04,frozen-oracle=0x08; C1=0x01,C2=0x01
- first_failures: C1=canonical-branch-count,C2=canonical-branch-count
- q16_signal_counts: every candidate source=0,neutral=0,frozen-siblings=[4,9],strengthening-siblings=[16,12,0]
- admitted_point_counts: C1=0,C2=0
- lattice_rejection_counts: C1=0,C2=0 because the shared canonical support gate failed first
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts restored or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED

## 2026-08-31 FACE-01 support-corrected revision-10 retry stop

- implementation: C1 clipped-secant integrated-residual only; completed once with no selector or fallback family
- gate_bitmask: bits oracle-hash=0x01,canonical-support=0x02,budget-lattice-global-safety=0x04,frozen-oracle=0x08; C1=0x07
- first_failure: frozen-oracle-semantic-margin
- canonical_branch_counts: left=7,right=7
- anchor_role_counts: left=3,right=3
- eligible_knot_counts: left=4,right=4
- class_occupancy: left=[1,0,0,1,1,1],right=[1,0,0,1,1,1]
- preselected_pair_count: 4
- reachable_zone_counts: upper=1,middle=1,lower=2
- q16_signal_counts: source=1,neutral=1,frozen-siblings=[5,8],strengthening-siblings=[15,11,1]
- admitted_point_count: 8
- lattice_rejection_count: 0
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts restored or absent; STATE.md and PLANS.md preserved byte-exact

## 2026-08-31 FACE-01 extremum-overlap revision-11 retry stop

- implementation: D1 extremum-inclusive direct-secant field only; executed once without retuning, fallback, interval search, or rendered-output selection
- gate_bitmask: bits oracle-hash=0x01,canonical-support=0x02,extremum-pair-topology=0x04,direct-secant-owner=0x08,cap-target-first-lattice=0x10,analytical-safety-energy=0x20,frozen-oracle=0x40; D1=0x0f
- first_failure: cap-target-first-lattice-exact-subtraction-identity
- canonical_branch_counts: left=7,right=7
- extremum_class_pair: left=1,right=1
- preselected_pair_count: 5
- reachable_zone_counts: upper=2,middle=1,lower=2
- emitted_pair_count: 0
- adjacent_overlap_counts: not evaluated because the first mandatory lattice pair was not admitted
- forbidden_swept_disks: not evaluated because the first mandatory lattice pair was not admitted
- max_lipschitz_q16: 0 because no field was admitted
- field_energy_proxy_delta_q16: 0 because no field was admitted
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[4,9],strengthening-siblings=[16,12,0]; candidate oracle not invoked after the pre-render lattice stop
- admitted_point_count: 0
- lattice_rejection_count: 5 at the first mandatory shoulder carrier; every fixed neighbor failed both required exact Float subtraction identities
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts unchanged or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED
