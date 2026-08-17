---
gsd_state_version: 1.0
milestone: v1.17
milestone_name: Dual CPU/GPU Metal Rendering
current_phase: 74
current_phase_name: CPU/GPU Parity and SDK-Only Closeout
status: planning
stopped_at: Completed 73-04-PLAN.md
last_updated: "2026-08-17T02:31:08.691Z"
last_activity: 2026-08-17
last_activity_desc: Phase 73 complete, transitioned to Phase 74
progress:
  total_phases: 5
  completed_phases: 4
  total_plans: 14
  completed_plans: 14
  percent: 80
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-15)

**Core value:** An iOS app can integrate `BeautySDK` and get natural,
controllable, real-time and still-image beauty processing through a stable
modular facade.
**Current focus:** Phase 74 — CPU/GPU parity and SDK-only closeout

## Current Position

Phase: 74 — CPU/GPU Parity and SDK-Only Closeout
Plan: Not started
Status: Ready to plan
Last activity: 2026-08-17 — Phase 73 complete, transitioned to Phase 74

Progress: [██████████████░░░░] 80%

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
| Phase 71 P04 | ~15min | 2 tasks | 6 files |
| Phase 72 P01 | 25min | 2 tasks | 8 files |
| Phase 72 P02 | 15 | 2 tasks | 6 files |
| Phase 72 P03 | ~25min | 2 tasks | 13 files |
| Phase 72 P04 | ~20min | 2 tasks | 4 files |
| Phase 73 P01 | ~20min | 2 tasks | 4 files |
| Phase 73 P02 | ~25min | 2 tasks | 5 files |
| Phase 73 P03 | ~15min | 2 tasks | 6 files |
| Phase 73 P04 | ~30min | 2 tasks | 14 files |

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
- [Phase 71]: METAL-01 closes only after archive-first runtime/preflight and full no-skip evidence: focused 26/0/0, full 728/0/0, eight opt-ins exactly once, and separate metal_available=1 / metal_unavailable=0 accounting.
- [Phase 71]: The runtime closeout is package-only aggregate evidence; Phase 72 owns feature passes, Phase 73 owns public .cpu/.gpu configuration, and Phase 74 owns parity/SDK-only closeout.
- [Phase 71]: METAL-01 closes only after archive-first runtime/preflight and full no-skip evidence with focused 26/0/0, full 728/0/0, eight opt-ins exactly once, and separate Metal availability classifications.
- [Phase 71]: Phase 71 remains package-only aggregate runtime evidence; CPU stays the reference while Phase 72 owns feature passes, Phase 73 owns public .cpu/.gpu configuration, and Phase 74 owns parity and SDK-only closeout.
- [Phase 72]: Phase 72 Plan 01 uses finite package-only Metal pass carriers and an ordered private-texture ping-pong graph; color/skin uniforms mirror retained CPU coefficients.
- [Phase 72]: Metal color bridges BGRA pixel buffers through request-local RGBA bytes, preserves alpha, and materializes still-image output with named sRGB metadata; geometry/local-retouch semantics remain with their owning plans.
- [Phase 72]: Plan 72-02 keeps BeautyGeometryEffectPipeline.controlPoints as the sole package-internal Metal geometry source and preserves composition collision ownership.
- [Phase 72]: Plan 72-02 uses finite bounded point/count payloads with CPU-compatible inverse displacement, clamped bilinear sampling, alpha, extent, locality, and no-face degradation.
- [Phase 72]: Plan 03 keeps BeautyLocalRetouchCompositionOwner as the sole proposal/source-binding/collision owner; Metal receives only the canonical RGBA8 carrier and six aggregate counters.
- [Phase 72]: Plan 03 dispatches composed-retouch before color and geometry so local-retouch-only bytes remain owner-produced and mixed work starts from immutable composition.
- [Phase 72]: The archive-first wrapper invokes check-metal-feature-passes.sh exactly once after runtime authorization and before consumer, CPU-oracle, opt-in, and full-child stages.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- Phase 71 is complete for package-owned runtime mechanics. Phase 72 feature
  semantics and Phase 73 public configuration/fail-closed policy are complete;
  generated parity tolerances, milestone closeout, and release/device evidence
  remain unverified until Phase 74 executes.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Algorithm breadth | `去脂`, hairline/semantic masking, double-chin, and new beauty features | Future | v1.16 scope |
| Product/release | Device/commercial validation, performance budgets, packaging, distribution, shipping, launch, and release readiness | Future | v1.16 scope |

## Session Continuity

Last session: 2026-08-17T10:00:00.000Z
Stopped at: Completed 73-04-PLAN.md
Resume file: None
Next action: Plan Phase 74 generated CPU/GPU parity and SDK-only closeout;
preserve the CPU reference and the v1.17 SDK/Metal-only boundary.
