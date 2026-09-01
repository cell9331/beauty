---
phase: 90
slug: face-contour-and-chin-repairs
status: draft
nyquist_compliant: false
wave_0_complete: true
created: 2026-09-01
---

# Phase 90 — Validation Strategy

> Per-phase Nyquist contract for the independently gated FACE-01 and FACE-02
> repairs. This draft is an execution sampling plan, not a claim that Phase 90
> has passed.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Swift Testing/XCTest through SwiftPM, plus SDK-owned Python, Swift, and Bash gates |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `python3 scripts/verify-phase90-face01-diagnostic.py self-test` plus the Plan 90-01 read-only revision-20 status-policy mutation harness, both verifier help commands, and `git diff --check` |
| **Diagnostic build command** | `swift build --package-path BeautySDK --target BeautyEffects` |
| **Single diagnostic test command** | `swift test --package-path BeautySDK --filter 'FaceContourSmoothRepairTests/testFACE01D1V19DiagnosticOnlyClassification'` — retained D1V19 implementation vocabulary under revision-20 execution authorization; at most once, only after the sole static preflight |
| **Estimated runtime** | static verifier sampling: no more than 5 seconds; target build and the one uniquely filtered diagnostic test: no more than 30 seconds each on the warm incremental workspace |

---

## Sampling Rate

- **During every task, after each meaningful edit:** Run the task's immediate smoke command from the table below; target latency is no more than 30 seconds.
- **Before every task commit:** Run that task's exact `<automated>` completion command. This may be longer than the immediate sampling command and does not replace it.
- **After revision-20 Wave 1:** Revision 20 is separately authorized after
  revision 19 stopped before XCTest. It is dispatched only with
  `$gsd-execute-phase 90 --wave 1`; completed 90-02 is skipped, so only 90-01
  runs. Stop after zero-diff Swift rollback, the optional ATTEMPT-only final
  rollback, and `git diff --check`; do not run phase-wide execution or
  FACE-01/FACE-02 provider/CPU/facade filters.
- **After Wave 2:** Run the exact-section DESIGN, taxonomy, and product checks from Plan 90-03.
- **After Wave 3 / before phase verification:** Not reachable from revision 20;
  Plans 90-03/04 remain blocked without a GREEN `90-01-SUMMARY.md`.
- **Max immediate feedback latency:** 30 seconds. Revision 20 has no render,
  candidate-oracle, full-suite, archive, or milestone closeout gate.

### Immediate Task Smoke Map

| Task | Immediate smoke command (warm incremental workspace) | Target |
| --- | --- | --- |
| 90-01-D20 | Retained verifier self-test plus read-only status-policy mutations; after temporary Swift edits, exactly one `preflight` with provider and complete repair-test as the only allowed paths and ATTEMPT forbidden | <=5s static sampling; then one target build and at most one uniquely filtered diagnostic XCTest |
| 90-02-01 / 90-02-02 | already GREEN; rerun the narrow named ChinTaper test method being edited if reopened | <=30s |
| 90-03-01 / 90-03-02 | first require `FACE01_GREEN_SUMMARY_VERIFIED`, then run the task's exact-section Python assertion | <=5s; current revision-20 diagnostic state fails closed before edits |
| 90-04-01 | first require `FACE01_GREEN_SUMMARY_VERIFIED` for 90-01/02/03 summaries, then run the SECURITY/RELIABILITY assertion | <=5s; current revision-20 diagnostic state fails closed before edits |
| 90-04-02 | blocked until a separately authorized GREEN FACE-01 repair creates `90-01-SUMMARY.md` | not executable during revision 20 |

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 90-01-D20 | 01 | 1 | FACE-01 | T-90-D20-01 through T-90-D20-06 | The retained verifier self-tests before Swift; one shared request-local documented reconstruction yields one four-way aggregate classification; preflight allows exactly the two temporary Swift paths, the first rollback allows no diff, and only a valid started-XCTest marker permits ATTEMPT as the sole final diff | retained Python self/mutation tests + one target build + at most one preflight + at most one narrow diagnostic XCTest + two-stage static rollback | Plan 90-01 Task D20 exact status-policy mutation matrix, captured-hash preflight, unique XCTest filter, zero-diff rollback, and conditional ATTEMPT-only rollback | ✅ verifier retained; temporary Swift symbols absent until execution | ⬜ pending |
| 90-02-01 | 02 | 1 | FACE-02 | T-90-08 | Centerline-owned chin field passes provider and exact cap/neutral/fail-closed contracts | unit + generated CPU integration | `swift test --package-path BeautySDK --filter 'ChinTaperRepairTests|FaceShapeWarpProviderTests'` | ✅ | ✅ green |
| 90-02-02 | 02 | 1 | FACE-02 | T-90-08 / T-90-09 | Public facade retains chin locality, sibling distinction, recovery, and source safety | generated integration | Plan 90-02 Task 02 exact facade/degradation filter | ✅ | ✅ green |
| 90-03-01 | 03 | 2 | FACE-01 / FACE-02 | T-90-10 through T-90-13 | Static preflight rejects diagnostic/stopped evidence before DESIGN/taxonomy consume GREEN summaries | GREEN-summary preflight + deterministic document contract | Plan 90-03 Task 01 `green-summary` gate, exact-section Python check, and `git diff --check` | ✅ | ⬜ pending |
| 90-03-02 | 03 | 2 | FACE-01 / FACE-02 | T-90-10 through T-90-13 | Static preflight rejects diagnostic/stopped evidence before owner-journey edits | GREEN-summary preflight + deterministic document contract | Plan 90-03 Task 02 `green-summary` gate, exact-section Python check, and `git diff --check` | ✅ | ⬜ pending |
| 90-04-01 | 04 | 3 | FACE-01 / FACE-02 | T-90-16 through T-90-20 | Static preflight requires GREEN 90-01 plus completed 90-02/03 before trust-owner edits | GREEN-summary preflight + deterministic owner-contract check | Plan 90-04 Task 01 `green-summary` gate, exact-section Python check, and `git diff --check` | ✅ | ⬜ pending |
| 90-04-02 | 04 | 3 | FACE-01 / FACE-02 | T-90-17 through T-90-20 | Static preflight requires GREEN 90-01 plus completed 90-02/03 before evidence/closeout commands | GREEN-summary preflight + deterministic document/verifier smoke | Plan 90-04 Task 02 `green-summary` gate and exact-section/verifier-help command | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

### Revision 18 Execution Reconciliation

- Task `90-01-01` is RED. The temporary D1-v18 provider compiled, but the
  focused pre-render check observed zero emitted points at both cap and half
  (`0/20`) and stopped at
  `focused-pre-render-D1-v18-whole-field-empty-before-candidate-oracle`.
- The frozen candidate oracle was not invoked. Provider and repair-test bytes
  were restored exactly, the tenth aggregate-only stop record was retained,
  and `python3 scripts/verify-phase90-face01-stop.py` returned
  `FACE01_STOP_VERIFIED`.
- Commit `36d2ec5` records the sanitized stop. The cause remains indeterminate
  because the retained evidence does not identify the earliest internal
  fail-closed gate. The owner subsequently authorized diagnostic-only revision
  19; the replacement Plan 90-01 may classify that gate once but cannot repair,
  render, invoke the oracle, create a summary, or unblock downstream plans.

### Revision 19 Harness Reconciliation

- The target-only `BeautyEffects` build passed. The sole revision-19 preflight
  then failed before XCTest with
  `FACE01_DIAGNOSTIC_ERROR:status_allowlist_violation`: Git status contained
  exactly the temporary provider and complete repair-test paths while the
  caller allowed ATTEMPT alone.
- XCTest did not start, so revision 19 produced no diagnostic marker,
  classification, counts, or ATTEMPT suffix. Provider/test bytes were restored
  byte-exact with apply_patch, `FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED` passed,
  render/oracle counts remained zero, and the final worktree was clean.
- The static verifier is retained in commits `f3cf3b2` and `03bfada`; revision
  20 self-tests it without recreating Wave 0. The separately authorized retry
  changes only status policy: preflight accepts the two temporary Swift paths,
  the first rollback accepts no diff, and only a started XCTest with one valid
  marker permits ATTEMPT as the sole final diff.
- `90-01-SUMMARY.md`, `90-03-SUMMARY.md`, and `90-04-SUMMARY.md` remain absent.
  Plans 90-03/04 stay machine-blocked by `FACE01_GREEN_SUMMARY_VERIFIED`.

---

## Wave 0 Requirements

- [x] `scripts/verify-phase90-face01-diagnostic.py` — retained static verifier
  with `self-test`, `preflight`, `rollback`, and fail-closed `green-summary`
  modes plus deterministic mutation coverage; commits `f3cf3b2` and `03bfada`
  own it. Revision 20 reads and self-tests it but does not modify or recreate it.
- [ ] `FaceContourSmoothRepairTests.testFACE01D1V19DiagnosticOnlyClassification`
  and provider `D1V19*`/`d1V19*` symbols — retained implementation vocabulary,
  temporary only for Task `90-01-D20`; remove byte-exact after the single run.
- [ ] Immediately capture provider, complete repair-test, frozen-oracle,
  verifier, ATTEMPT ten-heading prefix, later-artifact, PLANS, STATE, and
  ROADMAP hashes/states before temporary Swift edits.
- [ ] Before Swift, mutation-test the exact provider+repair-test preflight,
  zero-diff rollback, omission, ATTEMPT inclusion, extra, alias, duplicate, and
  post-rollback temporary-diff status cases against the retained verifier.
- [x] Confirm `scripts/verify-phase90-face01-stop.py --help`; normal execution
  is prohibited because it launches the frozen oracle.

No framework installation, dependency, private fixture, model, weight, network,
UI, renderer, backend, or `Warp.metal` work is required.

## Phase Completion Gate

Revision 20 has no Phase Completion Gate and must run only through the Wave 1
filter. It terminates after classification, byte-exact Swift rollback, the
mandatory zero-diff rollback, the optional aggregate-only revision-20 suffix,
the conditional ATTEMPT-only final rollback, and `git diff --check`. The Plan 90-04 completion gate
remains machine-blocked by `green-summary` because no GREEN
`90-01-SUMMARY.md` exists.

During revision 20 do not run
`testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract`, the
normal `scripts/verify-phase90-face01-stop.py`,
`scripts/check-cpu-reference-oracles.sh`, unfiltered/full `swift test`,
`scripts/run-no-skip-swiftpm.sh`, any renderer command, Tasks 90-01-02/03, or
Plans 90-03/04.

---

## Manual-Only Verifications

All Phase 90 milestone gates are automated. Optional real-device observation
is owner feedback after SDK completion and is not a Phase 90 completion gate.

---

## Validation Sign-Off

- [x] Every planned task has an `<automated>` command or an explicit Wave 0 dependency.
- [x] Sampling continuity has no three consecutive tasks without automated verification.
- [x] Wave 0 names every missing test artifact or method owned by the plans.
- [x] No command uses watch mode.
- [x] Immediate edit-loop feedback latency target is at most 30 seconds; longer completion/wave gates remain mandatory.
- [x] Wave 0 completed in retained verifier commits; revision 20 does not recreate it.
- [ ] Every pending task is green.
- [ ] `status: validated` and `nyquist_compliant: true` set after implementation reconciliation.

**Approval:** pending execution and post-implementation validation
