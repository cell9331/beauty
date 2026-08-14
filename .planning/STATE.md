---
gsd_state_version: 1.0
milestone: v1.16
milestone_name: SDK-Only Foundation and CPU Reference
status: planning
last_updated: "2026-08-14T09:10:53+08:00"
last_activity: 2026-08-14
progress:
  total_phases: 4
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-14)

**Core value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.
**Current focus:** Phase 66 — Legacy UI/Demo Archive and SDK-Only Boundary

## Current Position

Phase: 66 of 69 (Legacy UI/Demo Archive and SDK-Only Boundary)
Plan: 0 of TBD in current phase
Status: Ready to plan
Last activity: 2026-08-14 — Created the four-phase v1.16 roadmap with 19/19 requirements mapped; milestone research intentionally skipped by user direction.

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Current milestone:**

- Total plans completed: 0
- Average duration: —
- Total execution time: —

Historical milestone metrics remain in `.planning/MILESTONES.md` and archived roadmaps.

## Accumulated Context

### Decisions

- [v1.16]: The active project is SDK/algorithm-only; SwiftPM tests and SDK-owned CLI validation replace Demo/Xcode/simulator/device gates.
- [Phase 66]: Legacy Demo/UI originals may be removed only after ZIP scope, deterministic listing, extraction, and SHA-256/content agreement are verified.
- [Phases 67-68]: Mandatory validation uses Swift code that imports the public `BeautySDK` SPM product and checks generated input/output; private real fixtures are optional gates and cannot lend success through skips.
- [Phase 69]: `BeautyResult<Output>` gains conditional `Sendable` conformance only when `Output: Sendable`, preserving ordinary source use without an unchecked generic promise.
- [v1.17 queued]: Preserve CPU permanently; expose `.cpu`/`.gpu` only through `BeautyConfiguration` after Metal coverage, default to CPU, and fail explicit unavailable GPU without fallback.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- Phase 66 deletion is gated on successful, reproducible archive verification; archive failure must leave originals intact.
- Metal source, GPU API, backend parity implementation, and any UI/Demo development are outside v1.16 even when adjacent code or historical documents mention them.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Render backend | CPU/GPU backend-neutral contract, Metal passes, and public `BeautyConfiguration.renderBackend` | Queued for v1.17 | v1.16 roadmap |
| Algorithm breadth | `去脂`, hairline/semantic masking, double-chin, and new beauty features | Future | v1.16 scope |
| Product/release | Device/commercial validation, performance budgets, packaging, distribution, shipping, launch, and release readiness | Future | v1.16 scope |

## Session Continuity

Last session: 2026-08-14
Stopped at: v1.16 roadmap created; Phase 66 is ready for planning.
Resume file: None
Next action: `$gsd-plan-phase 66 --auto`
