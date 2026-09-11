---
phase: 94-negative-mouth-width-repair
plan: "01"
subsystem: testing
tags: [swiftpm, registration, prerequisites, terminal-hold]
completion_scope: prerequisites_only
status: checkpoint
phase_complete: false
requirements-completed: []
tasks_completed: 1
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
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
key-decisions:
  - Preserve terminal hold without rerunning or changing frozen inputs.
  - Native preparation failure does not establish a registration assertion failure.
actuals:
  tasks: 1
  commits: 0
recorded: 2026-09-11
---

# Phase 94 Plan 01: Mouth Prerequisites Summary

**Fixed portrait and prerequisite runner passed 12 self-tests and locked; the sole registration invocation stopped during native preparation with `child_failure`, before any selected test executed.**

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

## Self-Check: PASSED

Read-only checks confirmed all seven touched files exist; both future baseline test files and the baseline receipt are absent; all four events, exact binding/event hashes, measured input identities and terminal counts remain intact. Stub-token scan and `git diff --check` passed. No child process was invoked by the self-check. This verifies the handoff's factual claims, not native prerequisite success. No commit-existence claim applies because commits remain parent-owned.
