---
phase: 94-negative-mouth-width-repair
plan: "01"
subsystem: testing
tags: [swiftpm, registration, prerequisites, terminal-hold]
completion_scope: prerequisites_only
status: checkpoint
phase_complete: false
requirements-completed: []
tasks_completed: 2
tasks_total: 3
research_passes: 1
checked_plan_sets: 1
implementation_attempts: 0
implementation_attempt_limit: 2
requires:
  - phase: 94-planning
    provides: c91f3ccb independently reviewed prerequisite plan
provides:
  - Fixed portrait and runner with 12 passing admission self-tests
  - Immutable source binding and terminal native-preparation failure history
  - Reviewed compile-only recovery with actual registration GREEN
  - Passing positive prerequisite method and preserved retained-row failure
affects: [94-negative-mouth-width-repair]
tech-stack:
  added: []
  patterns: [memory-only child capture, fixed-source registration, append-only prerequisite history]
key-files:
  created:
    - scripts/check-phase94-mouth-repair.py
    - BeautySDK/Tests/BeautyCoreTests/MouthRepairFixture.swift
    - BeautySDK/Tests/BeautyCoreTests/MouthFixtureRegistrationTests.swift
    - .planning/phases/94-negative-mouth-width-repair/94-PREREQUISITE-BINDING.json
    - .planning/phases/94-negative-mouth-width-repair/94-PREREQUISITE-EVENTS.jsonl
    - BeautySDK/Tests/BeautyCoreTests/MouthBaselineOracleTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthBaselineTests.swift
    - .planning/phases/94-negative-mouth-width-repair/94-COMPILE-EVENTS.jsonl
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
key-decisions:
  - Preserve terminal hold without rerunning or changing frozen inputs.
  - Native preparation failure does not establish a registration assertion failure.
actuals:
  tasks: 2
  commits: 0
recorded: 2026-09-11
---

# Phase 94 Plan 01: Mouth Prerequisites Summary

**Registration and the positive expansion/protection method passed after reviewed compile recovery; the sole baseline lane stopped at the retained-row method with `assertion_failure`. No baseline receipt exists.**

## Current checkpoint — Task 3

| Task | Current status | Evidence |
| --- | --- | --- |
| 1 — Freeze portrait and runner | Complete | Original 12/0/0 self-tests and immutable source lock. |
| 2 — Actual registration | Complete | Parent's reviewed successor invocation passed 3/0/0; the baseline lane freshly repeated the same three methods successfully. |
| 3 — Positive baseline | Blocked | Both test files compiled before freeze. Sole baseline lane: 9 discovered, 7 executed, 6 passed, 1 failed, 0 skipped, 2 unexecuted. |

The failed method is `BeautyCoreTests.BeautyEngineMouthBaselineTests/testRetainedMouthRowsHaveDeterministicDigests`, seventh in the frozen lane order. The first six methods passed: three registration methods, two independent oracle methods and `testPositiveExpansionAndProtectionBaseline`. Neither existing provider method ran. The lane stopped with `stage=test`, `category=assertion_failure`, `exit_code=1`. No full retained-row digest set or baseline acceptance is claimed. Both `94-BASELINE.json` and `94-COMPILE-BASELINE.json` remain absent.

The two new test files implement the literal checked-integer oracle, source/neutral positive comparison, signed-size distinction, full and clipped protection policies, explicit named-sRGB pixel extraction, and repeated public-wrapper row checks. The final retained-row method remains failed; authored coverage is not passing coverage.

## Compile recovery and baseline execution

The parent diagnosed the original build failure as a type-check timeout at registration line 19, column 9, exit 1. Its authorized replacement changes only the channel predicate's `allSatisfy` expression to an equivalent short-circuit Boolean loop. The parent reported a bounded diagnostic-only post-patch build at exit 0 with zero errors and no tests executed. Amendment `94-COMPILE-AMENDMENT.json` and successor `scripts/check-phase94-compile-recovery.py` preserve the original failure history and bind the exact before/after registration hashes. Independent compile recovery review passed 35/0/0; parent commit `80e15ce9` records that correction. No original binding/event/runner bytes were rewritten.

The parent then ran the sole successor registration: discovered/executed/passed 3, failed/skipped 0. Its event-file hash before baseline was `e4a2147d393822872bcd4a5f030cb4024dbad69cf8c034c55b6f48aa1ed85d68`.

During Task 3 authoring, one permitted compile-only `swift build --package-path BeautySDK --build-tests` ran through the frozen runner's 600-second memory-only child capture. Result: exit 0, zero errors, zero tests executed. No native tests or pixels were measured before the successor froze the two baseline inputs.

`python3 scripts/check-phase94-compile-recovery.py baseline` then ran exactly once and exited 1 with the counts above. `python3 scripts/check-phase94-compile-recovery.py status` independently reported the same terminal hold without children. The successor history now contains four events: `registration_started`, `registration_green`, `baseline_started`, `terminal_hold`. No acceptance retry or test correction followed measurement.

## Review finding received after measurement

The parent's review message arrived after the sole baseline invocation had completed. It identified a test-contract defect: the public helper uses detector activity to require Device RGB for every non-neutral row, including `lipColor_0p50`. Read-only source inspection supports separating that color-only path from geometry emission: `BeautyColorEffectPipeline.applyLipColor` returns a filtered/composited/cropped image, while `BeautyGeometryEffectPipeline.applyMVPProxy` returns without creating a Device-RGB bitmap when there are no renderable control points. The color-only result therefore has no source-established Device-RGB bitmap guarantee. The exact color-only `CIImage.colorSpace` expectation still requires a reviewed, source-supported disposition; no guessed replacement expectation is recorded here.

This review finding is not a recovered runtime diagnostic. The failed child's transcript and aggregate output stayed memory-only and were discarded by the frozen runner. Its durable result identifies the method and failure class, not the individual assertion, row, completed output count or measured metric values. Consequently this summary does not assert that the review finding was the sole executed failure. Both test files remain unchanged at their measured hashes, as the parent's conditional instruction required. A metadata correction, new binding or rerun requires explicit successor disposition preserving this failure.

## Current frozen identities

| Artifact | SHA-256 |
| --- | --- |
| `MouthBaselineOracleTests.swift` | `5d5b2a9f98a427ed189c2625951e23961c31e794a5875367fac61e9c91622d0c` |
| `BeautyEngineMouthBaselineTests.swift` | `74ba99d798cf3f05808f065a677dda3c816b757b6bdf69f88ebeec04110b1c77` |
| `94-COMPILE-EVENTS.jsonl` after baseline hold | `12034279d402cd4e6fc8b790a8c3a6e14ec588d2877d13da8d52ea189fcd1eba` |
| `94-COMPILE-AMENDMENT.json` | `0b4e5e4926aa0fff96bc8be13e5cf2b7a5e165642154f706c0c7b0973abe527a` |
| `check-phase94-compile-recovery.py` | `eb91c3560fdd2b48f92b426934610528e2a1042f17572fce23d81895806b395e` |
| Corrected `MouthFixtureRegistrationTests.swift` | `f707e60fa2246d1cd589c9d9e8b932093f251fa0d47b1708f271a5f2cf1a14c3` |

Task 3 touched only the two new baseline Swift test files, successor events and this summary. No baseline artifact was created. No fixture, registration, SPI, runner, provider, threshold, owner, PLANS, state, configuration or runtime file was changed by this continuation; concurrent parent changes were preserved. The executor made no commit. Attempts remain 0/2, research passes 1, checked plan sets 1. MOUTH-01 and Phase 94 remain incomplete; no negative-width candidate, Phase 95 or full no-skip execution occurred.

## Historical initial checkpoint — preserved from 900bb7ad

The following sections describe the initial checkpoint before the parent's compile diagnosis and recovery. Their original hashes, counts, unavailable-diagnostic statement and then-unstarted Task 3 status are historical, not the current status above.

**At that checkpoint, the fixed portrait and prerequisite runner had passed 12 self-tests and locked; the sole original registration invocation stopped during native preparation with `child_failure`, before any selected test executed.**

## Task status

| Task | Status | Evidence |
| --- | --- | --- |
| 1 — Freeze portrait and runner | Complete | Admission authoring RED observed before implementation; self-test 12/12; source lock succeeded without Swift execution. |
| 2 — Actual registration | Blocked | Two additive SPI cases and three registration methods authored and frozen; native preparation returned `child_failure`; no registration assertion result. |
| 3 — Positive baseline | Not started | Neither baseline test file nor baseline receipt exists; no public pixel baseline, negative render or candidate attempted. |

MOUTH-01 and Phase 94 remain incomplete. This summary is a partial prerequisites-only checkpoint, not plan acceptance. Attempts remain 0/2; research passes 1 and checked plan sets 1.

## Commands and counts

| Command | Observed outcome |
| --- | --- |
| `python3 scripts/check-phase94-mouth-repair.py self-test` | Exit 0; exactly 12 discovered/executed/passed, 0 failed/skipped/unexecuted. Python admission controls only. |
| `python3 scripts/check-phase94-mouth-repair.py lock-source` | Exit 0; binding and initial event created exclusively. No native evidence. |
| Static binding/SPI identity check | Passed before registration; stripping exactly the two declarations and fixed switch block matched the original SPI authority. |
| `python3 scripts/check-phase94-mouth-repair.py registration` | Exit 1; `terminal_hold`, category `child_failure`; discovered 0, executed 0, passed 0, failed 0, skipped 0, unexecuted 3. |
| `git diff --check` | Passed after the terminal hold. |

The native preparation sequence in the frozen runner is `swift build --package-path BeautySDK --build-tests`, then, only if successful, `swift test --package-path BeautySDK list`. The recorded failure occurred before selected-method discovery. The durable record and exposed runner result do not identify which of those commands failed, its exact exit code, or its diagnostic. Captured child output remained memory-only and was discarded by the runner; the executor has no retained compiler message to report. It would be inaccurate to assert a specific compiler cause, successful compilation, successful discovery, or a failed registration predicate. No second native invocation or diagnostic rerun occurred.

The single invocation wrote four sequential events: `source_locked`, `registration_inputs`, `failure`, `terminal_hold`. There is no `registration_green`, `baseline_inputs`, or baseline receipt. Failure and terminal-hold events retain the frozen SPI/test input hashes and all six counts.

## Exact identities

| File | SHA-256 |
| --- | --- |
| `94-PREREQUISITE-BINDING.json` | `37e3ac69512a93b757a3984f1d68b732860528515a0f5b48e91f6f3107dcef0c` |
| `94-PREREQUISITE-EVENTS.jsonl` after hold | `544875bf1082b4336bb49f9e6f4843cf7162bc7271ce38bdb15fc0ac025ddafb` |
| `scripts/check-phase94-mouth-repair.py` | `9135d44c7dc9012429f79f30e2ae0e0825ec2011a89814d6ff70b00481385afc` |
| `BeautySDK/Tests/BeautyCoreTests/MouthRepairFixture.swift` | `8a9f4c6331a58826208c5fa336cac0fc8cc90a4cc7afc635a5dc418465dfdf7d` |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` | `415545e2c085b5e5bf1b3aee1468d08fc0cf8e33d5420fc51062156310b0d6d2` |
| `BeautySDK/Tests/BeautyCoreTests/MouthFixtureRegistrationTests.swift` | `1252b414807e7a6a67b8dfec23b41d9a7d12b4c4f9cb48b3b1070d541886d335` |

The source-locked initial event-file hash was `3eaf62b0d866bf565e42bc5a9a1aacc8e5e1268d0bbb8cf12a4d747c3cd48909`. Appended events preserve its prefix. The original SPI authority remains `834153e717956c63c3f3b62c0ff11af6ad5bd02655486a8e684286d6db51bec8` after exact additive normalization.

## Scope and preservation

Authored four of the six planned source/test/script files: the runner, source fixture, registration tests and additive SPI. Created two of the three planned evidence artifacts: binding and events. This separately authorized summary is the seventh touched file. `MouthBaselineOracleTests.swift`, `BeautyEngineMouthBaselineTests.swift`, and `94-BASELINE.json` were not created because Task 2 did not pass.

No provider, adapter, sampler, existing test, package, dependency, owner document, PLANS, STATE, ROADMAP, REQUIREMENTS, configuration or parent runtime/lock file was edited by this executor. Pre-existing `.planning/config.json`, `.planning/state.json`, `.gsd/`, and `.planning/milestone.lock` changes were preserved. No commits or new worktree were created; the parent owns review and atomic commits. No Phase 95 or full no-skip command ran.

No raw image, support payload, geometry, private locator or native transcript was persisted by the runner or summary. Source drawing constants are authored recipe constants, not captured runtime geometry.

## Deviations and deferred issues

- Referenced GSD workflow/reference files had moved from `~/.codex/get-shit-done` to `~/.codex/gsd-core`; current counterparts were located and read. No runtime files were changed.
- Native preparation failed. Per the fixed plan, the failure was preserved without automatic repair, rerun, amendment, source change or threshold change. The record's lack of preparation-stage/exit-code detail limits diagnosis; no missing fact has been inferred.
- Task 1 RED was an in-memory missing-admission-implementation authoring check, not semantic RED. TDD commits were not made because this prerequisite plan and parent reserve all commits for parent review.
- No functional stubs were added. Unstarted Task 3 files are absent rather than placeholder implementations. Runtime correctness of the authored Swift remains unestablished.

## Mandatory checkpoint

Await parent D-06 repair/defer/stop disposition. The terminal hold remains active. No routine continuation, source/assertion tuning, further measurement or negative candidate admission is authorized by this result. Any diagnosis must preserve the immutable binding and complete event history. Neither this failure nor later prerequisite GREEN completes MOUTH-01.

## Historical initial Self-Check: PASSED

Read-only checks confirmed all seven touched files exist; both future baseline test files and the baseline receipt are absent; all four events, exact binding/event hashes, measured input identities and terminal counts remain intact. Stub-token scan and `git diff --check` passed. No child process was invoked by the self-check. This verifies the handoff's factual claims, not native prerequisite success. No commit-existence claim applies because commits remain parent-owned.

## Current Self-Check: PASSED

The read-only successor snapshot confirmed the original immutable authorities, corrected registration hash, both measured baseline test hashes and all four successor events. The first two successor events still hash to the parent's registration-GREEN prefix. Current counts are exactly 9 discovered / 7 executed / 6 passed / 1 failed / 0 skipped / 2 unexecuted, with `assertion_failure` and no baseline receipt. The summary exists and `git diff --check` passes. No native child was invoked by this check. This validates the checkpoint record, not Task 3 acceptance.
