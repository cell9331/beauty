---
gsd_state_version: 1.0
milestone: v1.22
milestone_name: Non-Local Facial Effect Repairs
status: planning
last_updated: "2026-08-26"
last_activity: 2026-08-26
progress:
  total_phases: 7
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-25)

**Core value:** The project owner's local iOS host can integrate `BeautySDK`
and get natural, controllable real-time and still-image beauty processing
without distributing the SDK, model, or weights.
**Current focus:** Phase 89 — Semantic Validation Baseline

## Current Position

Phase: 89 of 95 (first of 7 milestone phases)
Plan: Not planned
Status: Ready to plan
Last activity: 2026-08-26 — v1.22 roadmap created with 12/12 requirements mapped

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Current milestone:**

- Total plans completed: 0
- Average duration: —
- Total execution time: 0h

Historical milestone metrics remain in `.planning/MILESTONES.md` and archived
roadmaps.

## Accumulated Context

### Decisions

- [v1.22]: Phase 89 owns the shared 65-case semantic acceptance baseline;
  Phases 90–94 repair the five natural control families; Phase 95 owns safety,
  compatibility, and milestone closeout.
- [v1.22]: Acceptance requires direction-specific ROI, polarity, locality,
  minimum-signal, and protected-region evidence; arbitrary pixel differences
  and threshold-only pass tuning are insufficient.
- [v1.22]: Repairs preserve exactly 62 parameter fields, five presets, 75
  renderer cases, the public still-image facades, and the CPU/GPU contract.
- [Project]: Swift `public` remains owner-local access only. No SDK, model,
  weight, fixture, output, or derived-data distribution is authorized.
- [Project]: Teeth, sclera, and upper-eyelid local retouch plus UI/Demo,
  realtime/video, model/data/network, device/commercial, packaging, shipping,
  launch, release, and distribution work are outside v1.22.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

None. Authorized portrait media and detailed outputs remain local and ignored;
durable evidence must stay aggregate and privacy-safe.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Local retouch | Further teeth, sclera, and upper-eyelid optimization | Future separate milestone | v1.22 scope |
| Runtime/input breadth | Realtime/video, transparent/HDR, and device performance | Future | v1.22 scope |
| External use | Commercialization, packaging, shipping, launch, release readiness, and distribution | Prohibited until explicitly reopened | owner-local contract |

## Session Continuity

Last session: 2026-08-26
Stopped at: v1.22 roadmap created; Phase 89 is ready for planning
Resume file: None
