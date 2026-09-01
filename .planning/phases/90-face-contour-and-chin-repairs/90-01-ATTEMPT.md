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

## 2026-08-31 FACE-01 complete-chain D1-v12 revision-12 retry stop

- implementation: D1-v12 complete bilateral twelve-slot chain only; executed once with actual-Float slot/extremum construction and no fallback, tuning, solver, fit, or output selection
- gate_bitmask: bits oracle-hash=0x01,canonical-branches=0x02,slot-extremum-zones=0x04,exact-float-lattice=0x08,geometry-overlap-safety=0x10,branch-chain-proxy=0x20,frozen-oracle=0x40; D1-v12=0x07
- first_failure: cap-target-first-lattice-exact-identities
- canonical_branch_counts: left=7,right=7
- slot_counts: left=12,right=12
- extremum_slot_indices: left=4,right=4
- zone_slot_counts: left=[4,4,4],right=[4,4,4]
- adjacent_overlap_counts: not evaluated because the first mandatory lattice pair was not admitted
- forbidden_swept_disks: not evaluated because the first mandatory lattice pair was not admitted
- max_lipschitz_q16: 0 because no field was admitted
- inverse_lower_bound_q16: 0 because no field was admitted
- branch_chain_proxy_delta_q16: 0 because no field was admitted
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[16,3],strengthening-siblings=[4,0,12]; candidate oracle not invoked after the pre-render lattice stop
- admitted_point_count: 0
- lattice_rejection_count: 25 at the first mandatory left shoulder slot; every fixed 5x5 neighbor failed the exact cap/half source-target identities
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts unchanged or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED

## 2026-09-01 FACE-01 complete-chain D1-v13 revision-13 retry stop

- implementation: D1-v13 complete bilateral twelve-slot chain with endpoint-inclusive residual indexing only; executed once with no fallback, tuning, solver, fit, or output selection
- gate_bitmask: bits oracle-hash=0x01,canonical-branches=0x02,slot-extremum-zones=0x04,residual-indexing=0x08,residual-validity=0x10,exact-float-lattice=0x20,geometry-overlap-safety=0x40,branch-chain-proxy=0x80,frozen-oracle=0x100; D1-v13=0x0f
- first_failure: zero-or-invalid-local-residual-at-slot-7
- canonical_branch_counts: left=7,right=7
- slot_counts: left=12,right=12
- extremum_slot_indices: left=4,right=4
- zone_slot_counts: left=[4,4,4],right=[4,4,4]
- residual_progress_pairs: evaluated=7-of-12-on-left; each used endpoint-inclusive ordered pair; no shifted neighbor
- residual_boundary_assertions: slot1-minus-Q0=passed,slot12-plus-Q1=not-reached
- residual_indexing_status: endpoint-inclusive-Q((i-1)/13)-Q((i+1)/13); first zero residual at evaluated left slot 7
- adjacent_overlap_counts: not evaluated because residual validity failed first
- forbidden_swept_disks: not evaluated because residual validity failed first
- max_lipschitz_q16: 0 because no field was admitted
- inverse_lower_bound_q16: 0 because no field was admitted
- branch_chain_proxy_delta_q16: 0 because no field was admitted
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[16,3],strengthening-siblings=[4,0,12]; candidate oracle not invoked after the pre-render residual stop
- admitted_point_count: 0
- lattice_rejection_count: 0 because residual validity failed before lattice admission
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts unchanged or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED

## 2026-09-01 FACE-01 complete-chain D1-v14 revision-14 retry stop

- implementation: D1-v14 complete bilateral twelve-slot chain with finite-zero reference-only complete-pair omission; executed once with no fallback, tuning, solver, fit, or output selection
- gate_bitmask: bits oracle-hash=0x01,canonical-branches=0x02,slot-extremum-zones=0x04,residual-indexing=0x08,residual-validity=0x10,zero-pair-omission=0x20,exact-float-lattice=0x40,geometry-overlap-safety=0x80,branch-chain-proxy=0x100,frozen-oracle=0x200; D1-v14=0x07
- first_failure: owner-positive-slack-after-complete-bilateral-zero-residual-omission
- canonical_branch_counts: left=7,right=7
- slot_counts: left=12,right=12
- extremum_slot_indices: left=4,right=4
- zone_slot_counts: left=[4,4,4],right=[4,4,4]
- residual_progress_pairs: evaluated=12-of-12-on-left-and-right; ordered endpoint-inclusive pairs
- residual_boundary_assertions: slot1-minus-Q0=passed,slot12-plus-Q1=passed
- residual_indexing_status: endpoint-inclusive-Q((i-1)/13)-Q((i+1)/13); no shifted neighbor
- residual_zero_counts: left=2,right=2
- omitted_pair_counts: left=2,right=2; complete bilateral pairs only; no unilateral omission
- adjacent_overlap_counts: not evaluated because owner positive slack failed first
- forbidden_swept_disks: not evaluated because owner positive slack failed first
- max_lipschitz_q16: 0 because no field was admitted
- inverse_lower_bound_q16: 0 because no field was admitted
- branch_chain_proxy_delta_q16: 0 because no field was admitted
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[16,3],strengthening-siblings=[4,0,12]; candidate oracle not invoked after pre-render owner stop
- admitted_point_count: 0
- lattice_rejection_count: 0
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts unchanged or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED

## 2026-09-01 FACE-01 complete-chain D1-v15 revision-15 retry stop

- implementation: D1-v15 complete bilateral twelve-slot chain with actual Float owner/unit/expanded-support gate; executed once with no fallback, tuning, solver, fit, or output selection
- gate_bitmask: bits oracle-hash=0x01,canonical-branches=0x02,slot-extremum-zones=0x04,residual-indexing=0x08,residual-validity=0x10,zero-pair-omission=0x20,exact-float-lattice=0x40,owner-gate=0x80,geometry-overlap-safety=0x100,branch-chain-proxy=0x200,frozen-oracle=0x400; D1-v15=0x7f
- first_failure: owner-positive-slack-at-retained-slot-index-4-zero-based-bilateral; slack-failed-counts=5,5
- canonical_branch_counts: left=7,right=7
- slot_counts: left=12,right=12
- extremum_slot_indices: left=4,right=4
- zone_slot_counts: left=[4,4,4],right=[4,4,4]
- residual_progress_pairs: evaluated=12-of-12-on-left-and-right; ordered endpoint-inclusive pairs
- residual_boundary_assertions: slot1-minus-Q0=passed,slot12-plus-Q1=passed
- residual_indexing_status: endpoint-inclusive-Q((i-1)/13)-Q((i+1)/13); no shifted neighbor
- residual_zero_counts: left=2,right=2
- omitted_pair_counts: left=2,right=2; complete bilateral pairs only; no unilateral omission
- adjacent_overlap_counts: not evaluated because owner positive slack failed first
- forbidden_swept_disks: not evaluated because owner positive slack failed first
- max_lipschitz_q16: 0 because no field was admitted
- inverse_lower_bound_q16: 0 because no field was admitted
- branch_chain_proxy_delta_q16: 0 because no field was admitted
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[16,3],strengthening-siblings=[4,0,12]; candidate oracle not invoked after pre-render owner stop
- admitted_point_count: 0
- lattice_rejection_count: 0
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts unchanged or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED

## 2026-09-01 FACE-01 branch-balanced-radius D1-v17 revision-17 retry stop

- implementation: D1-v17 complete bilateral twelve-slot branch-balanced-radius chain only; executed once with no alternate radius, tuning, mandatory-pair omission, fallback, solver, fit, interval experiment, or rendered-output selection
- gate_bitmask: bits oracle-hash=0x01,canonical-branches=0x02,slot-extremum-zones=0x04,residual-indexing=0x08,zero-pair-omission=0x10,exact-float-lattice=0x20,branch-min-owner-slack-expanded=0x40,overlap-no-triple=0x80,single-adjacent-lipschitz-inverse=0x100,branch-chain-proxy=0x200,frozen-oracle=0x400; D1-v17=0xff
- first_failure: single-normalized-displacement-radius-bound-before-global-lipschitz-and-inverse
- canonical_branch_counts: left=7,right=7
- slot_counts: left=12,right=12
- extremum_slot_indices: left=4,right=4
- zone_slot_counts: left=[4,4,4],right=[4,4,4]
- residual_progress_pairs: evaluated=12-of-12-on-left-and-right; ordered endpoint-inclusive pairs
- residual_boundary_assertions: slot1-minus-Q0=passed,slot12-plus-Q1=passed
- residual_indexing_status: endpoint-inclusive-Q((i-1)/13)-Q((i+1)/13); no shifted neighbor
- residual_zero_counts: left=2,right=2
- omitted_pair_counts: left=2,right=2; complete bilateral zero pairs only; no unilateral or nonzero mandatory omission
- branch_min_clearance_status: actual Float H_i materialized after final retention; independent left/right H_branch minima finite-positive; uniform branch R=.75H_branch and B=.08R assigned
- owner_slack_proof_status: analytical .93H_branch<=.93H_i<.94H_i passed; actual Float inequality passed for every retained point
- actual_float_gate_counts: owner-failures=[0,0],unit-failures=[0,0],slack-failures=[0,0],expanded-containment-failures=[0,0]
- adjacent_overlap_counts: passed with at least one original-index adjacent overlap on each branch before the single-bound stop
- forbidden_swept_disks: zero forbidden same-side non-adjacent or opposite-side overlaps; no triple admitted
- max_lipschitz_q16: not certified because the first actual single 2*norm(d)/R exceeded 13107 Q16
- inverse_lower_bound_q16: not certified because the single normalized bound failed before global Lip(F)
- branch_chain_proxy_delta_q16: not evaluated because the single normalized bound failed first
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[4,9],strengthening-siblings=[16,12,0]; candidate oracle not invoked after pre-render safety stop
- admitted_point_count: 0
- lattice_rejection_count: 0
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact; later-task artifacts unchanged or absent; STATE.md and PLANS.md preserved byte-exact; FACE01_STOP_VERIFIED

## 2026-09-01 FACE-01 source-clearance-clipped D1-v18 revision-18 retry stop

- implementation: sole D1-v18 source-clearance-clipped exact-lattice construction; no alternative, tuning, sweep, fallback, mandatory-pair omission, or rendered-output selection
- gate_bitmask: bits immutable-baseline=0x01,normalized-revision-17-scaffold=0x02,compiled-D1-v18=0x04,focused-pre-render=0x08,frozen-oracle=0x10; D1-v18=0x07
- first_failure: focused-pre-render-D1-v18-whole-field-empty-before-candidate-oracle
- canonical_branch_counts: frozen input left=7,right=7; emitted branch counts not certified after whole-field pre-render abstention
- slot_counts: analytical left=12,right=12 by construction; retained emitted counts not certified after whole-field pre-render abstention
- extremum_slot_indices: planned frozen left=4,right=4; emitted extremum topology not certified
- zone_slot_counts: analytical left=[4,4,4],right=[4,4,4]; emitted zone topology not certified
- residual_progress_pairs: planned endpoint-inclusive 12-of-12 bilateral; no retained aggregate certified after the pre-render miss
- residual_boundary_assertions: slot1-minus-Q0 and slot12-plus-Q1 implemented; no retained aggregate certified after the pre-render miss
- residual_indexing_status: endpoint-inclusive Q((i-1)/13)-Q((i+1)/13) scaffold hash matched; emitted field failed closed
- residual_zero_counts: not certified because no field passed focused pre-render admission
- omitted_pair_counts: not certified; no nonzero mandatory omission or reselection was attempted
- raw_lattice_status: fixed g=2^-24 and raw-q17 sign/reference scaffold compiled; no emitted raw-lattice aggregate certified
- source_clearance_clip_status: sole Hsrc_branch/(64g) q18 block compiled; provider returned the whole field empty at the focused pre-render gate
- clipped_coefficient_counts: not certified because no field passed focused pre-render admission
- exact_linkage_failure_counts: not certified because no field passed focused pre-render admission
- branch_min_source_clearance_status: not certified because the whole D1-v18 field abstained before pre-render acceptance
- branch_min_target_clearance_status: not certified because the whole D1-v18 field abstained before pre-render acceptance
- owner_slack_proof_status: analytical 8/45,16/45,29/45 and .93H_branch<.94H_i scaffold retained; actual emitted proof not certified
- actual_float_gate_counts: not certified because the focused pre-render field was empty
- adjacent_overlap_counts: not evaluated after whole-field pre-render abstention
- forbidden_swept_disks: not evaluated after whole-field pre-render abstention
- max_single_q16: not certified because no field was admitted
- max_adjacent_q16: not certified because no field was admitted
- max_lipschitz_q16: not certified because no field was admitted
- inverse_lower_bound_q16: not certified because no field was admitted
- branch_chain_proxy_delta_q40: not evaluated because the focused pre-render field was empty
- strength_finalization_status: exact cap and half both emitted zero points at the focused pre-render gate; no partial topology emitted
- q16_signal_counts: source=0,neutral=0,frozen-siblings=[16,3],strengthening-siblings=[4,0,12]; candidate oracle was not invoked
- admitted_point_count: 0
- lattice_rejection_count: not certified because the provider failed closed before aggregate admission
- oracle_sha256: 7fa653475f4a13831ec0a75c263cfaf717c48b3d6094c2ff3e95ecb64076981d
- rollback_status: provider and complete repair test restored byte-exact with apply_patch; later-task artifacts restored or absent; STATE.md and PLANS.md preserved byte-exact


## 2026-09-01 FACE-01 revision-22 execution of D1-v19 diagnostic-only classification

- diagnostic_contract: documented-d1-v18-reconstruction-not-byte-identical
- classification: prior_stop_not_reproduced
- first_failure: none
- construction_invocation_count: 1
- canonical_branch_counts: left=7,right=7,total=14
- analytical_slot_counts: left=12,right=12,total=24
- retained_branch_counts: left=10,right=10,total=20
- clipped_branch_counts: left=10,right=10,total=20
- cap_template_count: 20
- provider_cap_admitted_count: 20
- provider_half_admitted_count: 20
- reference_cap_admitted_count: 20
- reference_half_admitted_count: 20
- final_point_count: 20
- first_failure_margin: not_needed
- render_invocation_count: 0
- oracle_invocation_count: 0
- rollback_status: provider_and_complete_test_byte_exact;temporary_swift_symbols_absent
- static_verifier_status: FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED
