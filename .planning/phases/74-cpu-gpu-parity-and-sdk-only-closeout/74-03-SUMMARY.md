---
phase: 74-cpu-gpu-parity-and-sdk-only-closeout
plan: 03
subsystem: determinism-and-selection
tags: [swiftpm, concurrency, determinism, availability]
dependency_graph:
  requires: [74-01]
  provides: [determinism-parity, request-local-selection-parity]
  affects: [74-04, 74-05]
tech_stack:
  added: []
  patterns: [bounded-task-group, request-id-baselines, typed-unavailable-separation]
key_files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyBackendDeterminismParityTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyBackendSelectionConcurrencyTests.swift
  modified: []
decisions:
  - "Each concurrent request is compared to its own serial CPU baseline; no process-wide backend state is introduced."
  - "Metal unavailable is asserted as typed terminal failure and is excluded from any parity success count."
metrics:
  duration: "~8m"
  completed: 2026-08-17
---

# Phase 74 Plan 03: Determinism and Selection Summary

Added bounded repeated/concurrent backend coverage and public request-local
selection tests. CPU remains the oracle; available Metal requests are compared
by request ID, while unavailable Metal is kept as a typed non-success branch.

## Completed Tasks

| Task | Description | Commit |
| --- | --- | --- |
| 1 | Repeated and bounded concurrent CPU/Metal determinism | `1eb13b7` |
| 2 | Immutable public selection and unavailable separation | `1b008b7` |

## Verification

- Combined focused filter — 4/4 passed.
- Runtime resource counter self-check — active resources `0`, created equals released.
- `git diff --check` — passed.

## Deviations from Plan

None. The test matrix is bounded to six public-engine requests and four backend
requests; no sleeps, global caches, durable payloads, or testing API changes were added.

## Self-Check: PASSED

- Both created test files exist.
- Commits `1eb13b7` and `1b008b7` exist in git history.
