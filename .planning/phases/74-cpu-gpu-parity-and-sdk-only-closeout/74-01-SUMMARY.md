---
phase: 74-cpu-gpu-parity-and-sdk-only-closeout
plan: 01
subsystem: generated-backend-parity
tags: [swiftpm, cpu, metal, parity, rgba8]
dependency_graph:
  requires: [phase-70-cpu-reference, phase-71-metal-runtime, phase-72-metal-passes, phase-73-backend-configuration]
  provides: [generated-parity-fixtures, structural-parity-matrix]
  affects: [74-02, 74-03, 74-04]
tech_stack:
  added: []
  patterns: [request-local-generated-fixtures, aggregate-only-observations, pinned-active-tolerances]
key_files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityTests.swift
  modified: []
decisions:
  - "Reuse CPUReferenceFixtureFactory values and keep all raster bytes transient to one test invocation."
  - "Neutral and no-face cases require exact bytes; active cases use max-channel <= 8 and mean-RGB < 5.0."
metrics:
  duration: "~10m"
  completed: 2026-08-17
---

# Phase 74 Plan 01: Generated CPU/GPU Parity Summary

Generated request-local RGBA8 fixtures and a CPU-versus-available-Metal parity
matrix for neutral, active color/geometry, no-face, pixel-buffer, and translated
still-image requests. The helper exposes only bounded aggregate observations;
raw bytes remain transient.

## Completed Tasks

| Task | Description | Commit |
| --- | --- | --- |
| 1 | Generated parity fixture factory and aggregate observation helpers | `7bd6e10` |
| 2 | Structural/numeric CPU-Metal parity matrix | `5b3e58d` |

## Verification

- `swift test --package-path BeautySDK --filter 'BeautyEffectsTests.BeautyBackendParityTests'` — 4/4 passed on the available Metal host.
- `git diff --check` — passed.

## Deviations from Plan

None. The no-face exact-byte case uses a still-image request because the existing
package pixel-buffer readback path is intentionally tested separately; the
contract and no-face semantics remain the same.

## Self-Check: PASSED

- Both created test files exist.
- Commits `7bd6e10` and `5b3e58d` exist in git history.
