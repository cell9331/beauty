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
