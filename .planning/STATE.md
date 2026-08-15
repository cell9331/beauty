---
gsd_state_version: 1.0
milestone: v1.17
milestone_name: Dual CPU/GPU Metal Rendering
status: planning
last_updated: "2026-08-15T04:03:12Z"
last_activity: 2026-08-15
progress:
  total_phases: 5
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-15)

**Core value:** An iOS app can integrate `BeautySDK` and get natural,
controllable, real-time and still-image beauty processing through a stable
modular facade.
**Current focus:** Phase 70 — Backend-Neutral Contract and CPU Reference

## Current Position

Phase: 70 of 5 — Backend-Neutral Contract and CPU Reference
Plan: —
Status: Ready to plan
Last activity: 2026-08-15 — v1.17 roadmap created with 13/13 requirements mapped

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Current milestone:**

- Total plans completed: 0
- Average duration: —
- Total execution time: 0 min

Historical v1.16 metrics remain in `.planning/MILESTONES.md` and archived
roadmaps.

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

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- v1.17 phase work is planned but not implemented; Metal availability,
  resource behavior, parity tolerances, and public configuration remain
  unverified until their owning phases execute.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Algorithm breadth | `去脂`, hairline/semantic masking, double-chin, and new beauty features | Future | v1.16 scope |
| Product/release | Device/commercial validation, performance budgets, packaging, distribution, shipping, launch, and release readiness | Future | v1.16 scope |

## Session Continuity

Last session: 2026-08-15T12:03:12+08:00
Stopped at: Created v1.17 roadmap and exact requirements traceability
Resume file: None
Next action: Plan Phase 70; preserve the CPU reference and the v1.17
SDK/Metal-only boundary.
