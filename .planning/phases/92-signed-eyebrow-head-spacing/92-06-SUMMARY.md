---
phase: 92-signed-eyebrow-head-spacing
plan: 06
repair_cycle: 1
implementation_attempt: 7
code_review_status: passed
provider_candidate_blob: 7aa6f74bc70457d63e69cb003e9ffe8c939b018c
provider_test_post_blob: 25ed3479e469ed4fff1ffca516123740ff3cd0fb
testing_spi_post_blob: ba5270907ff7136eef1de8187c8932eb98116bf9
registration_test_post_blob: 103c78bb38e96bb84e6f81dcc34e4d10b75a2b71
repair_test_post_blob: 101a3ff34e8e746bf4fe6e99232ea5f02b5b45a0
semantic_status: passed
closeout_status: pending
---

# Phase 92 Repair Evidence

Current accepted candidate R5: `470ae0d`, independently reviewed before and after implementation. R4 `c14719b` passed the sparse oracle but later review found dense-trace folding. Independent plan check passed before
production editing. Historical rejected attempts remain immutable; R1–R3
repair outcomes and rollback commits are in `92-06-ATTEMPTS.md`.

The provider keeps each side independent, selects the cumulative inner half,
and tapers nominal magnitude W*0.020*abs(u)*w. Target centers are fixed at
observed + axis*0.5r; linear falloff uses magnitude <=0.8r and reconstructed
actual displacement <=0.81r. Radius retains W*0.045, clearance limits and
conservative Float slack. No shared renderer or whole-brow control changed.

## Executed gates

Provider 18/18 passed, followed by immutable actual-pixel suite 3/3 and
independent fixture registration/exact-peer suite 2/2: 23 tests, no failures
or skips. Signed Q16 +48/-22; opposite 70; whole-brow distinctions
26/35/96/35. Target changed pixels 699/720; RGB delta 61174/45676.
All protected-region changed/RGB maxima zero. Unilateral and recovery,
metadata, extent, alpha and deterministic assertions passed. Full fixed
aggregates are recorded in the attempts ledger.

Freshness/resolver/combined suite: 97 discovered, zero failures, two skips.
The skipped adapter methods explicitly require live authorized portrait
integration; they remain Phase 95 work, not Phase 92 pass credit. The other
95 methods executed successfully. No live portraits were accessed.

## Accepted Git blobs

- EyebrowWarpProvider.swift: `7aa6f74bc70457d63e69cb003e9ffe8c939b018c`
- EyebrowWarpProviderTests.swift: `25ed3479e469ed4fff1ffca516123740ff3cd0fb`
- BeautyEngineTestingSupport.swift: `ba5270907ff7136eef1de8187c8932eb98116bf9`
- BeautyEyebrowFixtureRegistrationTests.swift: `103c78bb38e96bb84e6f81dcc34e4d10b75a2b71`

Frozen oracle `101a3ff34e8e746bf4fe6e99232ea5f02b5b45a0`, manifest
`8cfa6673a0d8647db79355b36dfa1d48be7024e1`, comparator
`a2924de0100f4d32fbf7b5decd981b3decef7316` were rechecked unchanged.
`git diff --check` passed before acceptance commit.

## Remaining closeout

Reconcile unexecuted 92-03/04 plans with these accepted bindings and nine BROW methods; complete remaining script
gates, owner-document synchronization and phase verification. This summary
does not claim phase or milestone completion, device qualification, external
distribution readiness or commercial visual quality.

## R5 review correction and fresh evidence

CR-01 is resolved by a fixed 0.9 per-side sum of actual displacement norm/radius.
Only over-budget sides have their displacements scaled, with conservative Float
slack and final representable-source/budget revalidation. Sparse fields remain
byte-exact. This bounds each side's summed inverse field before image clamping;
it does not certify arbitrary cross-side or sibling-field injectivity.

The dense regression first failed on R4 in `4a92373`: one method, 12 intended
assertion failures, zero unexpected failures. R5 passed all 18 provider methods
and the unchanged three public pixels plus two registration/peer methods.
All frozen pixel aggregates above remain exact. Compatibility plus freshness/
resolver/combined selection passed 217 discovered, zero failures, two existing
portrait opt-in skips (215 executed successfully). Required compatibility classes
account for 120/0/0; freshness selection accounts for 97/0/2. No live portraits
were accessed. Independent implementation re-review passed with no remaining
source/test findings. See `92-REVIEW.md`; phase closeout remains pending.

## Deviations from Plan

[Rule 1 — Bug] Independent review found dense same-side support summation could
fold the sampling map despite per-point bounds. Added a RED regression and the
independently reviewed provider-local R5 budget correction. No shared renderer,
frozen fixture/oracle, support radius, public API or acceptance threshold changed.
