---
phase: 90
slug: face-contour-and-chin-repairs
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| **Quick run command** | `python3 scripts/verify-phase90-face01-diagnostic.py self-test && python3 scripts/verify-phase90-face01-stop.py --help && git diff --check` |
| **Diagnostic build command** | `swift build --package-path BeautySDK --target BeautyEffects` |
| **Single diagnostic test command** | `swift test --package-path BeautySDK --filter 'FaceContourSmoothRepairTests/testFACE01D1V19DiagnosticOnlyClassification'` — at most once, only after static preflight |
| **Estimated runtime** | static verifier sampling: no more than 5 seconds; target build and the one uniquely filtered diagnostic test: no more than 30 seconds each on the warm incremental workspace |

---

## Sampling Rate

- **During every task, after each meaningful edit:** Run the task's immediate smoke command from the table below; target latency is no more than 30 seconds.
- **Before every task commit:** Run that task's exact `<automated>` completion command. This may be longer than the immediate sampling command and does not replace it.
- **After revision-19 Wave 1:** Revision 19 is dispatched only with
  `$gsd-execute-phase 90 --wave 1`; completed 90-02 is skipped, so only 90-01
  runs. Stop after static rollback verification and `git diff --check`; do not
  run phase-wide execution or FACE-01/FACE-02 provider/CPU/facade filters.
- **After Wave 2:** Run the exact-section DESIGN, taxonomy, and product checks from Plan 90-03.
- **After Wave 3 / before phase verification:** Not reachable from revision 19;
  Plans 90-03/04 remain blocked without a GREEN `90-01-SUMMARY.md`.
- **Max immediate feedback latency:** 30 seconds. Revision 19 has no render,
  candidate-oracle, full-suite, archive, or milestone closeout gate.

### Immediate Task Smoke Map

| Task | Immediate smoke command (warm incremental workspace) | Target |
| --- | --- | --- |
| 90-01-W0 | `python3 scripts/verify-phase90-face01-diagnostic.py self-test` | <=5s; static/read-only, no child process or Swift |
| 90-01-D19 | `git status --porcelain --untracked-files=all \| python3 scripts/verify-phase90-face01-diagnostic.py preflight --oracle-status not-invoked ...captured live hashes/states...` | <=5s; then exactly one uniquely filtered diagnostic XCTest |
| 90-02-01 / 90-02-02 | already GREEN; rerun the narrow named ChinTaper test method being edited if reopened | <=30s |
| 90-03-01 / 90-03-02 | first require `FACE01_GREEN_SUMMARY_VERIFIED`, then run the task's exact-section Python assertion | <=5s; current revision-19 state fails closed before edits |
| 90-04-01 | first require `FACE01_GREEN_SUMMARY_VERIFIED` for 90-01/02/03 summaries, then run the SECURITY/RELIABILITY assertion | <=5s; current revision-19 state fails closed before edits |
| 90-04-02 | blocked until a separately authorized GREEN FACE-01 repair creates `90-01-SUMMARY.md` | not executable during revision 19 |

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 90-01-W0 | 01 | 0 | FACE-01 | T-90-D19-02 through T-90-D19-05 | Retained verifier is static/read-only, mutation-tested, and unable to invoke Swift/render/oracle/network or write repository data | Python in-memory mutation/self-test | `python3 scripts/verify-phase90-face01-diagnostic.py self-test && python3 scripts/verify-phase90-face01-diagnostic.py --help && python3 scripts/verify-phase90-face01-stop.py --help && git diff --check` | ❌ W0 | ⬜ pending |
| 90-01-D19 | 01 | 1 | FACE-01 | T-90-D19-01 through T-90-D19-06 | One shared request-local documented reconstruction yields one four-way aggregate classification, then provider/test rollback and ten-prefix/optional-eleventh evidence are static-verified | target build + one narrow diagnostic XCTest + static rollback | Plan 90-01 Task D19 captured-hash preflight, exactly one unique XCTest filter, and final rollback command | ❌ W0 temporary | ⬜ pending |
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

---

## Wave 0 Requirements

- [ ] `scripts/verify-phase90-face01-diagnostic.py` — retained static verifier
  with `self-test`, `preflight`, `rollback`, and fail-closed `green-summary`
  modes plus deterministic mutation coverage; Task `90-01-W0` owns it before
  any provider/test edit.
- [ ] `FaceContourSmoothRepairTests.testFACE01D1V19DiagnosticOnlyClassification`
  and provider `D1V19*`/`d1V19*` symbols — temporary only for Task
  `90-01-D19`; remove byte-exact after the single run.
- [ ] Immediately capture provider, complete repair-test, frozen-oracle,
  verifier, ATTEMPT ten-heading prefix, later-artifact, PLANS, STATE, and
  ROADMAP hashes/states before temporary Swift edits.
- [ ] Confirm `scripts/verify-phase90-face01-stop.py --help`; normal execution
  is prohibited because it launches the frozen oracle.

No framework installation, dependency, private fixture, model, weight, network,
UI, renderer, backend, or `Warp.metal` work is required.

## Phase Completion Gate

Revision 19 has no Phase Completion Gate and must run only through the Wave 1
filter. It terminates after classification,
byte-exact Swift rollback, the optional aggregate-only eleventh suffix, static
rollback verification, and `git diff --check`. The Plan 90-04 completion gate
remains machine-blocked by `green-summary` because no GREEN
`90-01-SUMMARY.md` exists.

During revision 19 do not run
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
- [ ] Wave 0 completed.
- [ ] Every pending task is green.
- [ ] `status: validated` and `nyquist_compliant: true` set after implementation reconciliation.

**Approval:** pending execution and post-implementation validation
