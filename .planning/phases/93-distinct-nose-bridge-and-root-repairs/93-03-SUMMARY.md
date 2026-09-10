---
phase: 93-distinct-nose-bridge-and-root-repairs
plan: "03"
subsystem: testing
tags: [swiftpm, nose, scaling, field-safety, terminal-rollback]
status: halted
accepted_or_stopped: stopped
tasks_completed: 1
tasks_total: 2
implementation_attempt: 1
attempt_status: failed
failure_category: assertion_failure
rollback: production_restored
requires:
  - phase: 93-02
    provides: Frozen registration and both original-provider semantic baseline_pass verdicts
provides:
  - Immutable 22-method provider RED and independent sibling-vector digests
  - Preserved fixed candidate 1 and terminal field-safety failure
  - Hash-verified rollback of owned adapter and provider
affects: [93-04, 93-05]
tech-stack:
  added: []
  patterns: [aggregate-only assertions, frozen regression tests, exact rollback]
key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-PROVIDER-RED.json
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
  - Candidate 1 failed the frozen field-safety conjunction; no second candidate or post-evaluation correction is authorized.
  - Preserve failed candidate source and immutable tests, restore both owned production files, and block downstream plans.
requirements-completed: []
requirements-addressed: [NOSE-01, NOSE-02]
duration: approximately 17min
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
    description: Candidate complete-field safety
    verification:
      - kind: unit
        ref: NoseRepairFieldTests/testFinalFloatFieldBudgetAndDenseMap
        status: fail
    human_judgment: false
  - id: D3
    description: Exact terminal production rollback
    verification:
      - kind: other
        ref: Ledger sequence 26 and independent original SHA-256 comparison
        status: pass
    human_judgment: false
---

# Phase 93 Plan 03: Nose Field Regression and Terminal Rollback Summary

**The original provider failed independent scaling/admission/safety regressions; fixed candidate 1 failed the frozen field-safety conjunction and both owned production files were restored exactly.**

## Task results

| Task | Result | Commit |
|---|---|---|
| 93-03-01 — freeze six field tests and three centered expectations | Complete; 22 discovered, 17 passed, 5 expected-failing methods, zero skips | `811734f2` |
| 93-03-02 — fixed candidate 1 | Failed; 22 discovered, 18 passed, 1 failed, zero skips; three methods unexecuted | `e4e89680` |
| Terminal rollback required by task 2 | Completed and hash-verified; task 2 remains unsuccessful | `5392e9d1` |

The baseline receipt at sequence 24 has exactly seven assertion IDs: the three centered-bridge IDs and `P93_BRIDGE_SCALING`, `P93_FIELD_BUDGET`, `P93_RENDERER_CUTOFF`, `P93_REUSED_SCALING`. The other original invariants and two new non-regression methods passed. All 22 methods were discovered exactly once. The gate created immutable `93-PROVIDER-RED.json` before provider edits; tests were not changed afterward.

Six new methods exercise actual displacement scaling, root ownership and pair atomicity, complete Float budgets, dense quadratic inverse maps, renderer cutoffs, malformed bounds/support, exact reuse and combined strengths, and frozen sibling vectors. Exactly three dependent legacy expectations changed; all other original test bytes remain intact under the gate's scoped comparison. Fifteen sibling-vector digests were captured from the original provider before the production edit and then frozen as literal assertions.

Dense 2/4/16/64 upper traces use low/half/cap strengths, a 129-by-129 support-union grid, circle-boundary and midline samples. The 64-point half/quarter cases explicitly require abstention: the strict per-point L1 cutoff cannot fit the scaled budget at either prescribed radius. Applicable cap traces require a nonempty denominator. No cutoff, budget, numeric tolerance or source law was relaxed. Fixed bridge/root combinations with all five signed sibling cases are included; no arbitrary mixed-field injectivity claim is made.

## Candidate and stop

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

## Rollback and immutable proof

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

## Deviations and workflow notes

- **[Rule 3 — compile-only test authoring]** The initial new reuse test used an unavailable resolver initializer/context. The sanitized build identified the error before gate execution; the test was corrected to the existing `BeautyEffectResolver.resolve(parameters:faceGeometry:)` API. No behavior or production change was made by this compile correction. Subsequent test and candidate builds passed.
- Before freezing, a copied sibling hash literal was corrected to the captured digest. This was authoring, with no failed gate event or changed production candidate.
- The owner's density clarification was incorporated before RED freezing, preserving strict cutoff and scaled-budget mathematics rather than inventing impossible nonempty expectations.
- Serena was unavailable; repository source/rg tracing and the mandatory spike-findings-beauty privacy guidance were used. No external package or new research pass was needed.
- Parent-owned config, state.json, runtime directory, milestone lock and STATE frontmatter/position remain preserved and unstaged. Only a scoped STATE task note is added. Broad state/roadmap/requirements resynchronization is intentionally omitted because it would overwrite parent-owned work and falsely advance a halted plan.

## Deferred issues and handoff

Task 2's missing truth is a candidate satisfying the complete provider safety conjunction and all current registration/metric/pixel/lifecycle gates at one hash. Both NOSE requirements remain active. Plans 93-04/05 are blocked by this halted summary. Parent/owner repair, defer or stop disposition is required before further implementation or execution; no budget is reset by this record.

## TDD gate compliance

The independently failing test commit precedes the candidate commit. No GREEN feature commit exists because the production candidate failed; there is no claimed RED/GREEN completion. Expected RED and terminal rollback are preserved separately.

## Privacy and limits

Durable evidence contains counts, fixed statuses, hashes and aggregate prior semantic metrics only. Child build/test transcripts stayed in bounded memory. No raw pixels, geometry, masks, generated images, private locators or transcripts were persisted as evidence. Test data arrays are populated request-locally; no placeholder or success-returning stub remains. No new network/authentication/resource trust boundary was introduced. This is owner-local generated SDK evidence with no device, naturalness, commercial or distribution qualification.

## Self-Check: PASSED

Verified the new test, immutable provider RED and summary exist; all three task/candidate/rollback commits resolve. Nine original binding/amendment/review artifacts are byte-identical to the incoming commit. Both frozen test hashes agree with PROVIDER-RED. Independent rollback comparison matches both baseline originals; the ledger retains one begin and one failed finish. Stub/debug-output scan and diff hygiene passed. This self-check verifies the retained halted outcome, not plan completion.
