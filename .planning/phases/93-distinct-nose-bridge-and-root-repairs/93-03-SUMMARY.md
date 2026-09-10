---
phase: 93-distinct-nose-bridge-and-root-repairs
plan: "03"
subsystem: effects
tags: [swiftpm, nose, scaling, field-safety, conservative-reconstruction]
status: complete
accepted_or_stopped: accepted
tasks_completed: 2
tasks_total: 2
implementation_attempt: 2
attempt_status: same_candidate_revalidated
failure_category: none
historical_ledger_failure_category: child_timeout
attempts_exhausted: true
rollback: retained_after_reviewed_infrastructure_recovery
independent_review: passed
independent_goal_verification: pending
requires:
  - phase: 93-02
    provides: Frozen registration and both original-provider semantic baseline_pass verdicts
provides:
  - Immutable 22-method provider RED and independent sibling-vector digests
  - Preserved fixed candidate 1 and terminal field-safety failure
  - Hash-verified rollback of owned adapter and provider
  - Reviewed reconstruction-safe candidate 2 with all 36 core gate methods passing
  - Historical frozen bridge/root pixel passes at the evaluated candidate-2 identity
  - Post-acceptance compatibility timeout and exact dual-production rollback
affects: [93-04, 93-05]
tech-stack:
  added: []
  patterns: [aggregate-only assertions, frozen regression tests, exact rollback, directed rounding]
key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-PROVIDER-RED.json
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPT2-AUTHORIZATION.md
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPT2-DERIVATION.md
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPT2-REVIEW.md
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPT2.json
    - scripts/check-phase93-attempt2.py
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift
    - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPTS.md
    - PLANS.md
    - .planning/STATE.md
key-decisions:
  - Both semantic baseline_pass directions remain historical facts; only independently failing scaling and safety regressions justified candidate 1.
  - Dense low-strength fields may abstain when strict renderer admission cannot fit the scaled field budget.
  - Candidate 1 remains failed; its source, safety failure and exact terminal rollback are preserved.
  - Owner D-10 authorized the remaining second attempt after the safety stop, without resetting the two-attempt ceiling.
  - Preserve candidate-1 radii and replace empirical Float slack with conservative Double allocation and inward endpoint quantization.
  - Historical compatibility child_timeout revoked the first acceptance without establishing an arithmetic, pixel or assertion failure; identical candidate 2 is now freshly revalidated.
  - Preserve finish 33, timeout 39 and rollback 40; infrastructure resume 41 and revalidation 47 introduce no third candidate.
requirements-completed: []
requirements-addressed: [NOSE-01, NOSE-02]
duration: 17min initial execution; 68s attempt-2 begin-to-finish, excluding intervening review
completed: 2026-09-10
coverage:
  - id: D1
    description: Exact independent provider baseline RED
    verification:
      - kind: unit
        ref: python3 scripts/check-phase93-nose-repair.py provider --expect baseline-red
        status: pass
    human_judgment: false
  - id: D2
    description: Historical candidate 2 complete-field safety pass
    verification:
      - kind: unit
        ref: NoseRepairFieldTests/testFinalFloatFieldBudgetAndDenseMap
        status: pass
    human_judgment: false
  - id: D3
    description: Exact terminal production rollback
    verification:
      - kind: other
        ref: Ledger sequence 26 and independent original SHA-256 comparison
        status: pass
    human_judgment: false
  - id: D4
    description: Candidate 2 complete provider, registration, metric, pixel and lifecycle conjunction
    verification:
      - kind: integration
        ref: Ledger sequences 28-33 through scripts/check-phase93-attempt2.py
        status: pass
    human_judgment: false
---

# Phase 93 Plan 03: Reconstruction-Safe Candidate Revalidated

**The identical candidate-2 provider is restored and freshly revalidated: 36 discovered, 36 passed, zero failures/skips at the reviewed timeout-recovery runner identity. Plan 93-03 is complete; compatibility, independent phase review and owner synchronization remain pending.**

`35899899` corrects only infrastructure scheduling and recovery, and `2194e04c` restores exactly the reviewed production bytes. Ledger 41 resumes infrastructure without a third begin/candidate; fresh receipts 42–46 and revalidation 47 bind the same provider/adapter plus new runner. Original failure 39 and rollback 40 remain immutable. No test, radius, semantic threshold or public API changed. Both NOSE requirements remain active until independent goal verification.

The evidence below preserves prior RED, attempts, timeout and rollback checkpoints. Their statements about the then-current checkout describe those historical checkpoints; current status is the revalidation above.

## Task results

| Task | Result | Commit |
|---|---|---|
| 93-03-01 — freeze six field tests and three centered expectations | Complete; 22 discovered, 17 passed, 5 expected-failing methods, zero skips | `811734f2` |
| 93-03-02 — fixed candidate 1, historical | Failed; 22 discovered, 18 passed, 1 failed, zero skips; three methods unexecuted | `e4e89680` |
| Attempt-1 terminal rollback, historical | Completed and hash-verified; task 2 was still unsuccessful at that checkpoint | `5392e9d1` |
| D-10 recovery admission and independent pre-evaluation review | Complete; final review clean, zero blockers/warnings; runner self-test 133/0/0 | `c41ed2e6` |
| 93-03-02 — reconstruction-safe candidate 2, historical core acceptance | Core conjunction 36/0/0 and authorities passed; finish 33 retained as historical proof, acceptance subsequently revoked | `851d1d5f` |
| Current terminal disposition | Compatibility timeout 39; 67 passes, 1 timeout, 161 unexecuted; dual-production rollback 40 | Parent-owned ledger/rollback |

The baseline receipt at sequence 24 has exactly seven assertion IDs: the three centered-bridge IDs and `P93_BRIDGE_SCALING`, `P93_FIELD_BUDGET`, `P93_RENDERER_CUTOFF`, `P93_REUSED_SCALING`. The other original invariants and two new non-regression methods passed. All 22 methods were discovered exactly once. The gate created immutable `93-PROVIDER-RED.json` before provider edits; tests were not changed afterward.

Six new methods exercise actual displacement scaling, root ownership and pair atomicity, complete Float budgets, dense quadratic inverse maps, renderer cutoffs, malformed bounds/support, exact reuse and combined strengths, and frozen sibling vectors. Exactly three dependent legacy expectations changed; all other original test bytes remain intact under the gate's scoped comparison. Fifteen sibling-vector digests were captured from the original provider before the production edit and then frozen as literal assertions.

Dense 2/4/16/64 upper traces use low/half/cap strengths, a 129-by-129 support-union grid, circle-boundary and midline samples. The 64-point half/quarter cases explicitly require abstention: the strict per-point L1 cutoff cannot fit the scaled budget at either prescribed radius. Applicable cap traces require a nonempty denominator. No cutoff, budget, numeric tolerance or source law was relaxed. Fixed bridge/root combinations with all five signed sibling cases are included; no arbitrary mixed-field injectivity claim is made.

## Candidate 1 and stop — preserved history

This section and the following rollback section describe the terminal state at sequence 26, before owner D-10 reopened the remaining attempt. Their failed verdicts and evidence are not reclassified by candidate 2's success.

The already-open shared attempt 1 continued without another begin event. Candidate 1 used only the two permitted provider bodies and their new private `phase93` helpers, with unchanged dispatch/order, root validator, shared point helper, sibling bodies and renderer. It implemented the predeclared radius factors 0.08/0.07, cap-scaled X displacement, deterministic Double cap budget, 0.45 ceiling, 64-Float-ulp slack, source/cap-target disk admission, final Float budget check and whole-field renderer-cutoff abstention.

Sanitized `swift build --package-path BeautySDK --build-tests` passed. The frozen authority/source-scope gate passed before provider execution. Provider GREEN then stopped at sequence 25:

- Method: `BeautyEffectsTests.NoseRepairFieldTests/testFinalFloatFieldBudgetAndDenseMap`.
- Assertion: `P93_FIELD_BUDGET`.
- Gate category: `assertion_failure`; this is a blocking safety conjunction, not `semantic_signal`.
- Counts: 22 discovered / 18 passed / 1 failed / 0 skipped; three remaining field methods were not executed.
- All 16 original methods, new bridge scaling and root pair/independence passed on candidate 1 before the safety stop.

The single Boolean safety assertion combines final budgets, dense/mixed sampling, containment and density/cutoff eligibility. Its failure proves that conjunction was not satisfied; retained aggregate evidence does not isolate an individual subpredicate. No diagnostic rerun or numerical correction followed evaluation. The failed source is preserved in `e4e89680` for authorized future inspection.

Candidate registration, metric, semantic pixel and lifecycle reruns did not execute because the first required provider gate failed. Both candidate directions are **untested**, not accepted or proven impossible. The frozen original-provider bridge baseline remains 858 changed / 56232 RGB / +563 Q8, and root remains 964 / 92187 / +133 Q16, with all protection maxima 0/0. These earlier `baseline_pass` results are not credit for candidate 1 or the rolled-back adapter.

No candidate 2 is permitted for this failure category. No source correction, radius alternative, efficacy tuning, threshold change, third attempt, plan 93-04/05 or requirement/phase completion occurred.

## Attempt-1 rollback and immutable proof — historical checkpoint

`finish --attempt 1 --status failed` appended sequence 26 with status `failed`, category `assertion_failure`, rollback `production_restored`. Its command-level `pass` means the failed-attempt finish and rollback succeeded; it does not mean candidate acceptance. The ledger now has exactly one begin and one finish. Historical failures 15/18 and their reviewed amendments remain untouched; all other failures remain blocking.

| Artifact | SHA-256 |
|---|---|
| Evaluated candidate provider, preserved in `e4e89680` | dd6da052ce300b1b18608ee57d8b067e43c9fabe20fba173d8acb8092da51fe3 |
| Restored original provider | 0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8 |
| Restored original adapter | 7b3ca8d3dafad4068a49ee6fae963183601e59d10bb5eb40b0fdd8ee7f3e515d |
| Candidate corrected adapter before rollback | cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9 |
| 93-PROVIDER-RED.json | 650e48e51a4701fa653bfb53e24955dc239e46b420f12decb841bb91adb09138 |
| Frozen new field tests | a55f48e4c99157eb7f142a624a3030248e86712c4fa9f633cb1fc603217445e8 |
| Frozen scoped original provider tests | 69bb20ae06a2aa339c07331a21aedbbe160effc215561b9bbb1e62202b8ba837 |
| Original semantic RED binding | 571a87141a7ffcf77e2d5c42c7a9e43edd2ac3510a07751775ef4d09ef234f84 |
| Effective reviewed gate | 873dba5aac09040ff6927dfc8aef90c466f87a297f807cf4d8b34f0ad2c4897e |

Both production SHA-256 values were independently compared with the admitted baseline originals after rollback. Registration, semantic RED, original baseline and all three amendment JSON/reviews remain byte-identical. The corrected root regression and frozen provider regressions deliberately remain failing historical proof against restored production. A live authority invocation now would reject the restored adapter against the frozen corrected-adapter binding; do not rewrite that binding or manufacture current GREEN receipts. No further tests were run after the terminal stop.

## D-10 recovery and historical candidate-2 core acceptance

This section records the real native passes before the later compatibility timeout. It does not describe current production or current acceptance; the terminal disposition below controls the handoff.

The owner explicitly reopened the remaining second attempt after `93-FAILURE-ANALYSIS.md` identified reconstructed budget `0.45000014551914536` in the existing 16-support cap case. D-10 superseded the earlier semantic-only admission restriction without erasing attempt 1, authorizing a third candidate, changing frozen predicates or expanding radii.

`c41ed2e6` records the authorization, derivation, exact manifest and independent pre-evaluation review. The final review is clean with zero active blockers/warnings; its three historical runner findings remain preserved as resolved. The final runner self-test passed 133/0/0. The wrapper delegates effect verdicts to the unchanged original gate, pins its 26-event historical prefix, rejects replay/acceptance after an attempt-2 failure and preserves owned rollback. This pre-evaluation review is distinct from the subsequent phase review still pending in the finish record.

Begin sequence 27 admitted attempt 2 from the original rollback identities and restored the approved D-09 adapter. `851d1d5f` applied the exact reviewed provider. Relative to `e4e89680`, only `phase93Field` changed: upward-rounded Double cap terms/sums, downward scale and per-point allocation, and at most one Float endpoint neighbor toward its own source. Explicit actual-displacement magnitude/sign checks prevent overspend and reversal. The final 0.45 budget check, strict renderer cutoff, field/pair-atomic rejection, exact caps, source/cap-target/target containment, root ownership and legacy helpers remain. Radii stay 0.08/0.07; no rounding-loss redistribution, efficacy radius expansion or numerical sweep occurred.

### Evaluated candidate-2 identity — historical

| Artifact | SHA-256 |
|---|---|
| Evaluated provider, `851d1d5f` | `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45` |
| Evaluated D-09 adapter | `cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9` |
| Reviewed recovery runner | `4b07195cf2855911d1c5a0d840274f2f26d9e0260f6fe76efd3da041d462f7c3` |
| Recovery manifest | `85411d57f9121dba19d58123082558c23d72fb90ec6714db31d10c05859379fb` |
| Independent pre-evaluation review | `adcd47ce0b5e139f7aad5480d3b7002a4800bf1396b30b2e3d54efbd2765c504` |
| Preserved original 26-event ledger prefix | `2692dfdf94f9280856886034997bad5822b58d829254ad59e392b3215dd761ee` |

Original gate/baseline/registration/RED/amendment bindings, generated recipe, SPI and frozen tests retain their pins. This table identifies the evaluated production bytes before rollback, not the current checkout.

### Native core conjunction

Commands use `python3 scripts/check-phase93-attempt2.py`. Counts are discovered/passed/failed/skipped from the ledger, not source-only probes.

| Command | Sequence | Counts |
|---|---:|---:|
| `provider --expect green` | 28 | 22 / 22 / 0 / 0 |
| `registration --expect green` | 29 | 4 / 4 / 0 / 0 |
| `metrics` | 30 | 4 / 4 / 0 / 0 |
| `pixels` | 31 | 2 / 2 / 0 / 0 |
| `lifecycle` | 32 | 4 / 4 / 0 / 0 |
| `finish --attempt 2 --status passed` | 33 | 36 / 36 / 0 / 0 |

All five receipts share the same provider/adapter/runner/test identities and have empty assertion lists. Authorities passed; current authority admission also guards successful finish. Sequence 33 records `status: passed`, `category: passed`, `rollback: retained`, and `independent_review: pending`. Begin-to-finish is 68 seconds, ending 2026-09-10T09:04:01Z; derivation/review time is excluded. Through this acceptance there are exactly two begins and two finishes, with no attempt-2 failure or third attempt.

### Frozen actual-pixel results

Sequence 31 records these values identically against source and neutral:

| Direction | Changed target pixels | Target RGB delta | Signed margin | Minimum sibling margin | Comparisons | Verdict |
|---|---:|---:|---:|---:|---:|---|
| Bridge | 611 | 29460 | +383 Q8 | 373 Q8 | 6 | pass |
| Root | 1043 | 43917 | +24 Q16 | 24 Q16 | 5 | pass |

For both directions, outside, protected nose groups, background and watermark are each exactly 0 changed pixels / 0 RGB delta; repeated-byte status is 1. The five retained sibling output digests agree between bridge and root and with the original semantic baseline. All frozen source/neutral/sibling thresholds passed unchanged. Root +24 Q16 and bridge +383 Q8 do not replace the historical baseline values. Candidate 1 remains semantically untested; current results apply only to candidate 2 with the corrected D-09 adapter.

Provider GREEN includes the formerly failing safety conjunction, fixed dense/mixed sampling, applicable-cap nonempty denominators and all three methods left unexecuted after candidate 1's stop: cutoff/malformed admission, reuse/combined scaling and frozen sibling vectors. Registration, independent metrics and all four lifecycle methods also passed. These are native frozen generated-host regressions, not arbitrary mixed-field/GPU/raster injectivity or device/visual qualification.

## Current terminal disposition: compatibility timeout and rollback

The parent's compatibility invocation first repeated the five core gates at sequences 34–38: provider 22/0/0, registration 4/0/0, metrics 4/0/0, pixels 2/0/0 and lifecycle 4/0/0. Pixel aggregates were identical to sequence 31. Those additional passes remain historical evidence and did not authorize ignoring the subsequent timeout.

Sequence 39 records `event: failure`, `kind: compatibility`, `category: child_timeout`, and exact method `BeautyCoreTests.BeautyExampleRendererProcessTests/testCompiledRendererBindsOnlyExactSuccessfulGazeAggregate`. Its ledger counts are **229 discovered, 67 passed, 0 failed, 0 skipped**, with an empty assertion list: **67 passes + 1 timeout + 161 unexecuted**. The top-level CLI displayed `failed=1` for the timeout; that is not a recorded test assertion failure. No negative pixel, provider-arithmetic or folding result is established, and no cause of the timeout is inferred here.

The parent invoked failed cleanup after acceptance. Sequence 40 is a separate `recovery_rollback` receipt with category `attempt_failed` and `rollback: production_restored`; it does not rewrite successful finish 33 or append a replacement finish. Both production files now match the pinned originals exactly:

| Restored current production | SHA-256 |
|---|---|
| Provider | `0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8` |
| Adapter | `7b3ca8d3dafad4068a49ee6fae963183601e59d10bb5eb40b0fdd8ee7f3e515d` |

The recovery failure latch revokes current acceptance. Candidate 2 is preserved at `851d1d5f`; candidate 1 remains preserved at `e4e89680`. Two attempts are exhausted, with no current accepted candidate, third attempt, rerun, negative efficacy claim or downstream advancement. The corrected root regression and frozen field tests remain as proof against restored production. Parent owns the fixed-method timeout diagnosis; this handoff does not execute it.

## Deviations and workflow notes

- **[Rule 3 — compile-only test authoring]** The initial new reuse test used an unavailable resolver initializer/context. The sanitized build identified the error before gate execution; the test was corrected to the existing `BeautyEffectResolver.resolve(parameters:faceGeometry:)` API. No behavior or production change was made by this compile correction. Subsequent test and candidate builds passed.
- Before freezing, a copied sibling hash literal was corrected to the captured digest. This was authoring, with no failed gate event or changed production candidate.
- The parent orchestrator's mathematical-consistency note on density was incorporated before RED freezing, preserving strict cutoff and scaled-budget mathematics rather than inventing impossible nonempty expectations. This was not a new user decision.
- Serena was unavailable; repository source/rg tracing and the mandatory spike-findings-beauty privacy guidance were used. No external package or new research pass was needed.
- At the historical attempt-1 checkpoint, only a scoped STATE task note was added. This completion update owns only this summary and the existing PLANS entry; parent-owned ledger, STATE, ROADMAP, config/state.json, runtime, lock, production and tests remain untouched and unstaged by this update.
- **Owner-authorized D-10 deviation:** the original plan's semantic-only second-candidate admission and radius expansion are superseded for this reconstruction repair after a safety stop. Candidate-1 radii and every frozen verdict remain; independent candidate/runner review preceded evaluation. This consumes attempt 2 without a budget reset or free retry.

## Historical timeout handoff

Core truth passed historically, but current candidate acceptance is revoked by compatibility timeout 39 and exact rollback 40. Both NOSE requirements remain active; plan 93-03 is halted/compatibility-blocked and plans 93-04/05 must not advance. Parent continues the authorized infrastructure-only correction and independent review for possible revalidation of the exact same `bafa9d2a...` provider. That is not a new production candidate or reclassification of failure 39. This handoff runs no Swift, edits no runner and adds no approval prerequisite; it does not expand the two-attempt ceiling or edit state/roadmap/requirements.

## TDD gate compliance

RED `811734f2` precedes failed candidate `e4e89680` and rollback `5392e9d1`. Candidate `851d1d5f` earned historical provider/core GREEN before compatibility revoked acceptance. Its conventional type is `fix`, not `feat`, because it repairs existing behavior. Neither those real passes nor the later timeout is relabeled as an arithmetic failure or current plan completion. No frozen test was weakened.

## Privacy and limits

Durable evidence contains counts, fixed statuses, hashes and aggregate prior semantic metrics only. Child build/test transcripts stayed in bounded memory. No raw pixels, geometry, masks, generated images, private locators or transcripts were persisted as evidence. Test data arrays are populated request-locally; no placeholder or success-returning stub remains. No new network/authentication/resource trust boundary was introduced. This is owner-local generated SDK evidence with no device, naturalness, commercial or distribution qualification.

## Historical attempt-1 self-check: PASSED

Verified the new test, immutable provider RED and summary exist; all three task/candidate/rollback commits resolve. Nine original binding/amendment/review artifacts are byte-identical to the incoming commit. Both frozen test hashes agree with PROVIDER-RED. Independent rollback comparison matches both baseline originals; the ledger retains one begin and one failed finish. Stub/debug-output scan and diff hygiene passed. This self-check verifies the retained halted outcome, not plan completion.

## Historical timeout self-check: PASSED

Read-only checks confirmed the five referenced test/candidate/rollback/recovery commits, all 17 frozen manifest pins, the byte-exact original 26-event ledger prefix, both historical core conjunctions and identical sequence-31/37 pixel aggregates. Sequence 39 has the exact 229/67/0/0 counts and no assertions; sequence 40 records recovery rollback, and both current production hashes independently match its pinned originals. Summary existence and scoped `git diff --check` passed. Only SUMMARY/PLANS were authored; no Swift, renderer, gate, ledger, production, test, state, roadmap or runner mutation was performed by this documentation update. This verifies the halted compatibility-timeout handoff, not current acceptance or completion.

## Current revalidation self-check

The parent executed provider 22, registration 4, metrics 4, pixels 2 and lifecycle 4 through `check-phase93-timeout-recovery.py`, all passing without skips, followed by its strict `accept` command. The candidate provider remains `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`; adapter remains `cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9`; runner is `eb7ccc0f4dda224d8ad78080bf64bed95cb6bee7b1f608dd821c927dc54da116`. Independent timeout review is clean with zero blockers; retained/new selftests pass 133/27. The complete compatibility command is running separately and receives no completion credit here. Historical failures and rollback hashes remain unchanged.
