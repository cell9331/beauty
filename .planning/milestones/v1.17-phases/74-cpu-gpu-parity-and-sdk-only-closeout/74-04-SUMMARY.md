---
phase: 74-cpu-gpu-parity-and-sdk-only-closeout
plan: 04
subsystem: sdk-gates
tags: [swiftpm, mutation, archive-first, no-skip]
dependency_graph:
  requires: [74-01, 74-02, 74-03]
  provides: [backend-parity-preflight, archive-first-parity-closeout]
  affects: [74-05]
tech_stack:
  added: []
  patterns: [bounded-static-validation, mutation-tested-gates, separate-availability-accounting]
key_files:
  created:
    - scripts/check-backend-parity.sh
  modified:
    - scripts/run-no-skip-swiftpm.sh
    - scripts/check-sdk-only-boundary.sh
decisions:
  - "Parity runs exactly once after configuration and before consumer, CPU-oracle, opt-in, and full SwiftPM stages."
  - "Metal availability is emitted as separate metal_available and metal_unavailable aggregate markers; unavailable is never parity success."
metrics:
  duration: "~45m"
  completed: 2026-08-17
---

# Phase 74 Plan 04: SDK Gate Summary

Added a mutation-tested SDK-owned backend parity preflight and integrated it into
the archive-first no-skip wrapper. The gate validates CPU/GPU structural and
safety assertions, pinned tolerances, request-local determinism, availability
separation, privacy/scope boundaries, and nonzero focused accounting.

## Completed Tasks

| Task | Description | Commit |
| --- | --- | --- |
| 1 | Mutation-tested backend parity preflight | `ae3122f` |
| 2 | Archive-first wrapper integration | `cc68c06` |
| 3 | SDK-only allowlist for request-level selection test | `a417aa6` |
| 4 | Separate availability classification hardening | `34027df` |

## Verification

- `bash scripts/check-backend-parity.sh --self-test` — passed all oracle, tolerance, safety, and raw-output mutations.
- `bash scripts/check-backend-parity.sh` — focused `12/0/0`; `metal_available=1`; `metal_unavailable=0`.
- `bash scripts/run-no-skip-swiftpm.sh --self-test` — passed.
- `bash scripts/run-no-skip-swiftpm.sh` — full SwiftPM `765/0/0`, eight opt-ins exactly once, zero skips, archive-first boundary and all prerequisite gates passed.
- `bash scripts/check-sdk-only-boundary.sh --post-archive` — passed.
- Parity invocation count in `run-no-skip-swiftpm.sh` — exactly `1`.
- `git diff --check` — passed.

## Deviations from Plan

**1. [Rule 2 - Blocking boundary] Allowed the new request-level backend selection test in the SDK-only boundary scanner.**

- **Found during:** Task 2 verification
- **Issue:** The existing current-source scanner rejected the planned package test because it intentionally references the public `.cpu`/`.gpu` configuration contract.
- **Fix:** Added only that test path to the existing backend-policy allowlist; all other unowned GPU references remain rejected.
- **Files modified:** `scripts/check-sdk-only-boundary.sh`
- **Commit:** `a417aa6`

## Self-Check: PASSED

- Gate script, wrapper integration, and summaries exist.
- Commits `ae3122f`, `cc68c06`, `a417aa6`, and `34027df` exist in git history.
