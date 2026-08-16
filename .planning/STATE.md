---
gsd_state_version: 1.0
milestone: v1.17
milestone_name: Dual CPU/GPU Metal Rendering
status: executing
stopped_at: Completed 71-03-PLAN.md
last_updated: "2026-08-16T08:31:28.085Z"
last_activity: 2026-08-16 -- Phase 71 execution started
progress:
  total_phases: 5
  completed_phases: 1
  total_plans: 6
  completed_plans: 5
  percent: 20
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-15)

**Core value:** An iOS app can integrate `BeautySDK` and get natural,
controllable, real-time and still-image beauty processing through a stable
modular facade.
**Current focus:** Phase 71 — SDK-Owned Metal Runtime

## Current Position

Phase: 71 (SDK-Owned Metal Runtime) — EXECUTING
Plan: 4 of 4
Status: Ready to execute
Last activity: 2026-08-16 -- Phase 71 execution started

Progress: [██████████] 100% (phase 70)

## Performance Metrics

**Current milestone:**

- Total plans completed: 0
- Average duration: —
- Total execution time: 0 min

Historical v1.16 metrics remain in `.planning/MILESTONES.md` and archived
roadmaps.
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 70 P01 | 20min | 2 tasks | 9 files |
| Phase 70 P02 | ~40min | 2 tasks | 9 files |
| Phase 71 P01 | ~35min | 2 tasks | 2 files |
| Phase 71 P02 | ~2h25m | 2 tasks | 3 files |
| Phase 71 P03 | 40min | 2 tasks | 11 files |

## Accumulated Context

### Decisions

- v1.16 established SDK/algorithm-only ownership, SwiftPM/SDK-owned gates,
  generated CPU reference oracles, and conditional `BeautyResult` sendability.

- v1.17 preserves CPU permanently; backend selection is execution policy outside
  `BeautyParameters` and presets, with `.cpu` as default and legacy fallback.

- Phase 70 owns the shared backend-neutral contract and CPU reference; Phase 71
  owns Metal resources; Phase 72 owns the three shipped Metal pass families.

- Phase 73 owns public `.cpu`/`.gpu` configuration and typed
  `.metalUnavailable`; Phase 74 owns generated parity and closeout evidence.

- No new algorithms, UI/Demo behavior, device evidence, commercial approval,
  packaging, shipping, or release-readiness claim is in this milestone.

- [Phase 70]: Phase 70 Plan 01 freezes a package-only backend-neutral request/result boundary with .cpu as the sole policy; public backend selection remains deferred.
- [Phase 70]: Backend requests reuse canonical input, normalized effect plans, transient support, and bounded aggregate diagnostics; typed executor errors have no retry or fallback.
- [Phase 70]: The retained CPU implementation is the sole package executor, and both facade process families dispatch exactly once without changing public schema or algorithm inventory.
- [Phase 70]: Backend-neutral static/mutation gates run before consumer and CPU-oracle stages; only aggregate pass/fail counts are retained in the ledger.
- [Phase 71]: Plan 01 keeps one package-only Metal runtime instance responsible for device, queue, and pipeline ownership without a global cache or host lifecycle dependency.
- [Phase 71]: Private RGBA8 textures use request-local shared staging/readback buffers, and every tracked request resource is released on success and failure.
- [Phase 71]: Phase 71 Plan 02 keeps .metal package-only and routes one bounded identity transaction through the shared backend contract.
- [Phase 71]: BeautyMetalBackend uses named ExecutionHooks for exactly-one invocation and terminal error accounting without a CPU execution path.
- [Phase 71]: Plan 03 keeps Metal validation package-owned and aggregate-only; host availability is explicit and never GPU success.
- [Phase 71]: The archive-first wrapper runs the Metal preflight once after Phase-70 authorization and before consumer, CPU-oracle, opt-in, and full-child stages.
- [Phase 71]: CPU remains the reference; public backend selection and generated parity stay owned by Phases 73 and 74.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- Phase 70 is complete. Metal availability, resource behavior, parity
  tolerances, and public configuration remain unverified until their owning
  phases execute.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Algorithm breadth | `去脂`, hairline/semantic masking, double-chin, and new beauty features | Future | v1.16 scope |
| Product/release | Device/commercial validation, performance budgets, packaging, distribution, shipping, launch, and release readiness | Future | v1.16 scope |

## Session Continuity

Last session: 2026-08-16T08:31:28.078Z
Stopped at: Completed 71-03-PLAN.md
Resume file: None
Next action: Plan Phase 71; preserve the CPU reference and the v1.17
SDK/Metal-only boundary.
