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
| **Quick run command** | `python3 scripts/verify-phase90-face01-stop.py --help && git diff --check` |
| **Full focused command** | `swift test --package-path BeautySDK --filter 'FaceContourSmoothRepairTests|ChinTaperRepairTests|BeautyEngineFaceContourSmoothRepairTests|BeautyEngineChinTaperRepairTests|FaceShapeWarpProviderTests|BeautyEffectResolverTests|GeometryConflictResolverTests|CombinedEffectSafetyTests|BeautyMetalGeometryPassTests|MissingLandmarkDegradationTests'` |
| **Estimated runtime** | immediate smoke commands below: no more than 30 seconds on the warm incremental workspace; full focused/archive closeout: approximately 180 seconds |

---

## Sampling Rate

- **During every task, after each meaningful edit:** Run the task's immediate smoke command from the table below; target latency is no more than 30 seconds.
- **Before every task commit:** Run that task's exact `<automated>` completion command. This may be longer than the immediate sampling command and does not replace it.
- **After Wave 1:** Run both FACE-01 and FACE-02 focused provider/CPU/facade filters.
- **After Wave 2:** Run the exact-section DESIGN, taxonomy, and product checks from Plan 90-03.
- **After Wave 3 / before phase verification:** Run Plan 90-04's focused repair, compatibility, comparator self-test/preflight, archive, SDK-only boundary, and exact-section commands.
- **Max immediate feedback latency:** 30 seconds. The one-shot frozen FACE-01 candidate oracle and the complete compatibility/archive closeout are completion or wave gates, not edit-loop sampling.

### Immediate Task Smoke Map

| Task | Immediate smoke command (warm incremental workspace) | Target |
| --- | --- | --- |
| 90-01-01 | `swift test --package-path BeautySDK --filter 'FaceContourSmoothRepairTests/testFACE01D1V18'` | <=30s; pre-render D1-v18 methods only, never the frozen candidate oracle |
| 90-01-02 | `swift test --package-path BeautySDK --filter 'FaceShapeWarpProviderTests/testFACE01'` | <=30s |
| 90-01-03 | `swift test --package-path BeautySDK --filter 'BeautyEngineFaceContourSmoothRepairTests/testFACE01'` | <=30s |
| 90-02-01 / 90-02-02 | already GREEN; rerun the narrow named ChinTaper test method being edited if reopened | <=30s |
| 90-03-01 / 90-03-02 | run the task's exact-section Python assertion without the trailing wave command | <=5s |
| 90-04-01 | run the task's SECURITY/RELIABILITY exact-section Python assertion without the trailing wave command | <=5s |
| 90-04-02 | `python3 scripts/verify-phase90-face01-stop.py --help && git diff --check` after evidence edits | <=5s; the long focused/compatibility/archive chain remains the Wave 3 completion gate |

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 90-01-01 | 01 | 1 | FACE-01 | T-90-01 through T-90-06 | Sole D1-v18 construction passes all pre-render gates before exactly one candidate oracle, or rolls back byte-exact with a tenth aggregate suffix | focused unit + generated CPU integration + rollback verifier | Plan 90-01 Task 01 exact two-stage Swift filter; on a miss, its retained verifier invocation | ✅ | ❌ red |
| 90-01-02 | 01 | 1 | FACE-01 | T-90-02 through T-90-05 | Source clip, exact linkage, topology, inverse, proxy, strength, and budget adversaries fail FACE-01 closed | unit / mutation | `swift test --package-path BeautySDK --filter 'FaceContourSmoothRepairTests|FaceShapeWarpProviderTests|CombinedEffectSafetyTests|BeautyMetalGeometryPassTests'` | ✅ | ⬜ pending |
| 90-01-03 | 01 | 1 | FACE-01 | T-90-06 / T-90-07 | Generated owner-local facade proves bounded pixels/metadata/recovery/privacy without public or backend expansion | generated integration + compatibility | Plan 90-01 Task 03 exact repair and compatibility filters | ❌ W0 | ⬜ pending |
| 90-02-01 | 02 | 1 | FACE-02 | T-90-08 | Centerline-owned chin field passes provider and exact cap/neutral/fail-closed contracts | unit + generated CPU integration | `swift test --package-path BeautySDK --filter 'ChinTaperRepairTests|FaceShapeWarpProviderTests'` | ✅ | ✅ green |
| 90-02-02 | 02 | 1 | FACE-02 | T-90-08 / T-90-09 | Public facade retains chin locality, sibling distinction, recovery, and source safety | generated integration | Plan 90-02 Task 02 exact facade/degradation filter | ✅ | ✅ green |
| 90-03-01 | 03 | 2 | FACE-01 / FACE-02 | T-90-10 through T-90-13 | Exact DESIGN and taxonomy sections consume GREEN summaries only | deterministic document contract | Plan 90-03 Task 01 exact-section Python check plus `git diff --check` | ✅ | ⬜ pending |
| 90-03-02 | 03 | 2 | FACE-01 / FACE-02 | T-90-10 through T-90-13 | Owner journey preserves evidence, privacy, later-phase, and external-claim limits | deterministic document contract | Plan 90-03 Task 02 exact-section Python check plus `git diff --check` | ✅ | ⬜ pending |
| 90-04-01 | 04 | 3 | FACE-01 / FACE-02 | T-90-16 through T-90-20 | Security and reliability promote only measured request-local GREEN behavior | deterministic owner-contract check | Plan 90-04 Task 01 exact-section Python check plus `git diff --check` | ✅ | ⬜ pending |
| 90-04-02 | 04 | 3 | FACE-01 / FACE-02 | T-90-17 through T-90-20 | Evidence sections are complete and schema-safe before the mandatory phase closeout | deterministic document/verifier smoke | Plan 90-04 Task 02 exact-section/verifier-help command | ✅ | ⬜ pending |

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
  fail-closed gate; no diagnostic-only revision 19 is authorized by this
  validation record.

---

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineFaceContourSmoothRepairTests.swift` — generated public-facade coverage created only after Task 90-01-01 is GREEN; Task 90-01-03 owns it.
- [ ] Add the new D1-v18 focused method names to existing `FaceContourSmoothRepairTests.swift` before Task 90-01-01's pre-render filter runs.
- [ ] Confirm `scripts/verify-phase90-face01-stop.py --help` before the first edit; the retained verifier itself already exists and remains read-only.

No framework installation, dependency, private fixture, model, weight, network,
UI, renderer, backend, or `Warp.metal` work is required.

## Phase Completion Gate

After Wave 3 tasks pass their <=30-second task-level `<automated>` checks, run
the complete mandatory command declared in Plan 90-04 `<verification>`. It
includes focused FACE-01/FACE-02 and compatibility suites, Phase 89 comparator
self-test/preflight, archive verification, SDK-only boundary enforcement,
exact-section evidence checks, and diff hygiene. Its approximately 180-second
runtime is a phase completion gate, not task-level sampling; Phase 90 cannot
complete without it.

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
