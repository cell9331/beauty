---
phase: 91-independent-gaze-correction
plan: "03"
implementation_attempt: 1
subsystem: renderer-semantic-validation
tags: [swift, renderer-report, gaze-correction, comparator, cleanup]
requires:
  - phase: 91-independent-gaze-correction
    plan: "02"
    provides: Final post-conflict six-key gaze aggregate and generated actual-pixel proof
  - phase: 89-semantic-validation-baseline
    provides: Frozen target, sibling, locality, protection, and preflight contracts
provides:
  - Identity-bound optional six-field gaze aggregate on the exact successful renderer unit
  - Aggregate-plus-actual-pixel comparator admission with 576 mutation probes
  - Consume-before-cleanup lifecycle for both temporary attempt reports
affects: [91-04-phase-verification, EYE-01]
tech-stack:
  added: []
  patterns: [strict renderer-unit admission, hybrid semantic evidence, descriptor-safe temporary cleanup]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift
    - BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift
    - scripts/compare-face-feature-batches.swift
    - scripts/run-face-feature-batches.sh
    - scripts/test-face-feature-batch-boundaries.py
key-decisions:
  - "Bind aggregate evidence to the exact inputID, caseID, outputID, schema, backend, and successful renderer unit before semantic use."
  - "Use aggregate evidence only for own-center direction; retain source/neutral target signal, sibling distinction, locality, and every protected-region pixel gate."
  - "Retain renderer reports through both attempt comparisons and final reconciliation, then remove and verify both trees before publication."
requirements-completed: [EYE-01]
completed: 2026-09-05
---

# Phase 91 Plan 03: Renderer-Bound Gaze Evidence Summary

**The exact successful gaze output now carries one privacy-safe aggregate, the comparator admits it only with unchanged actual-pixel gates, and both attempt reports are consumed and removed before durable publication.**

## Accomplishments

- Added an optional six-field aggregate to `RendererOutputUnit`, populated only from the same successful `gazeCorrection_0p25` result. Neutral, sibling, failed, skipped, and non-gaze units carry no aggregate.
- Added strict renderer report admission for schema v1, CPU backend, reconciled counts, stable input/case/output identity, unique units, exact fields, integral bounded values, and aggregate algebra.
- Replaced the unsupported gaze direction branch with the same-request aggregate only for own-center direction. Actual source/neutral target signal, sibling signal, outside locality, contour, brow, background, and watermark pixel gates remain mandatory.
- Preserved all prior comparator probes and expanded the self-test from 554 to **576 mutations**, including proxy, hidden one-eye regression, malformed/nonfinite/duplicate data, replay, identity, schema, sibling, alias, stale, path, symlink, and privacy cases.
- Retained renderer reports until both attempt comparisons and final reconciliation consumed them, then removed and verified all 66 expected reports from both fresh attempt trees before publication. Forced cleanup, symlink, path mismatch, or leftover reports fail as infrastructure errors.

## Task Commits

1. **Task 1 RED: renderer gaze aggregate contract** — `e175cb5`
2. **Task 1 GREEN: exact successful-unit binding** — `51e6d99`
3. **Task 2 RED: comparator/report admission probes** — `101c81c`
4. **Task 2 GREEN: hybrid admission and verified cleanup** — `f742a54`

The Task 2 GREEN commit was completed by the orchestrator after the executor service hit its account-usage window. This resumed the same dirty worktree and the same implementation attempt; no code was reverted, reimplemented from scratch, or counted as attempt two.

## Renderer Aggregate Contract

The nested aggregate has exactly these fields: `eligibleCount`, `correctedCount`, `rejectedCount`, `allReduced`, `abstained`, and `minimumReductionQ16`.

- Counts are integral and each lies in 0...2; `correctedCount + rejectedCount == eligibleCount`.
- `abstained` is true exactly when corrected count is zero.
- `allReduced` is true only when at least one eye is eligible, every eligible eye is corrected, none is rejected, and minimum reduction is positive.
- `minimumReductionQ16` is zero when not all-reduced and otherwise lies in 1...65,536.
- Missing, extra, duplicate, fractional, nonfinite, negative, overflow, contradictory, wrong-unit, replayed, aliased, stale, or symlinked data is rejected rather than coerced.

## Verification

- `BeautyExampleRendererProcessTests`: **8 tests executed, 0 failures**. Repeated report bytes, successful/abstaining gaze units, nil sibling/failure aggregates, v1 compatibility, ordering, and privacy passed.
- Comparator self-test: `semantic_validation_self_test=PASS mutations=576 inventories=5/65/8`.
- Python boundary suite: `runner_boundary_self_test=PASS`, including `report_cleanup=6`, `preflight_faults=3`, unchanged preflight, stale/alias/symlink/path and cleanup-failure coverage.
- Shell syntax: `bash -n scripts/run-face-feature-batches.sh` passed.
- SDK preflight: `preflight=PASS live=75 selected=65 semantic=8`.
- `git diff --check` passed.

## Recovery Deviation

The first self-test after recovering the interrupted Task 2 GREEN work exposed one fail-closed parser defect: a syntactically nonfinite JSON number caused `JSONSerialization` to propagate an implementation error instead of returning the comparator's sanitized admission failure. The admission guard now uses a non-throwing parse and maps invalid JSON to `SemanticContractError.admission`. The original nonfinite mutation then passed, and all 576 probes remained green. No evidence threshold or acceptance rule changed.

## Security, Privacy, and Scope

- HIGH threats T-91-10 through T-91-14 are mitigated by exact output identity, strict aggregate algebra, unchanged pixel gates, no-follow ownership checks, temporary-only reports, and verified cleanup.
- Stable payloads contain no renderer unit rows, raw/per-side pupil or contour geometry, radii, masks, pixels, media, private locators, paths, or transcripts.
- No live authorized portrait batch ran, no 65-output result was published, and the Phase-95 full no-skip closeout did not run.
- No public parameter, preset, renderer case, 62/5/75 inventory, manifest threshold, facade, backend, shader, retained `Warp.metal`, UI/Demo, realtime/video, model, data, weight, dependency, or network behavior changed.
- This package-host evidence makes no device, visual-naturalness, population-quality, commercial, packaging, shipping, launch, release, or distribution claim.

## Files Modified

- `RendererCLIContract.swift` — optional private report aggregate schema.
- `RendererExecution.swift` — exact same-result aggregate validation and unit binding.
- `BeautyExampleRendererProcessTests.swift` — compiled renderer determinism, abstention, nil sibling/failure, algebra, and privacy proof.
- `compare-face-feature-batches.swift` — report inventory/admission, hybrid gaze measurement, and mutation suite.
- `run-face-feature-batches.sh` — consume-before-cleanup ownership and verified removal.
- `test-face-feature-batch-boundaries.py` — runner cleanup, replay, path, and failure-envelope boundary coverage.

## Known Stubs

None.

## User Setup Required

None. No external service, model, package, fixture media, credential, or persistent renderer report is required.

## Next Phase Readiness

- Plan 91-04 can run the final package-host compatibility/security gate and synchronize the verified outcome into all owner documents.
- Phase 95 remains the sole owner of authorized-portrait rerun, clean 65-output publication, and milestone no-skip closeout.

## Self-Check: PASSED

- All six declared source/test/script files exist and commits `e175cb5`, `51e6d99`, `101c81c`, and `f742a54` exist in history.
- This summary contains exactly one `implementation_attempt: 1` line and matches Plans 91-01 and 91-02.
- Comparator mutations total 576, preflight remains 75/65/8, runner boundaries pass, and no renderer report or media was added to the repository.
- `git diff --check` passes.

---
*Phase: 91-independent-gaze-correction*
*Completed: 2026-09-05*
