---
gsd_state_version: 1.0
milestone: v1.22
milestone_name: Non-Local Facial Effect Repairs
current_phase: 90
current_phase_name: Face Contour and Chin Repairs
status: blocked
stopped_at: FACE-01 bounded-2D retry exhausted; typed implementation blocker
last_updated: "2026-08-30T02:13:30.000Z"
last_activity: 2026-08-30
last_activity_desc: FACE-01 revision-8 retry stopped after seven candidate misses
progress:
  total_phases: 7
  completed_phases: 1
  total_plans: 9
  completed_plans: 5
  percent: 14
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-26)

**Core value:** The project owner's local iOS host can integrate `BeautySDK`
and get natural, controllable real-time and still-image beauty processing
without distributing the SDK, model, or weights.
**Current focus:** Phase 90 — Face Contour and Chin Repairs

## Current Position

Phase: 90 (Face Contour and Chin Repairs) — BLOCKED
Plan: 1 of 4
Status: Blocked on FACE-01 implementation
Last activity: 2026-08-30 — Revision-8 A1–A4/B1–B3 retry exhausted and rollback verified

Progress: [█░░░░░░░░░] 14%

## Performance Metrics

**Current milestone:**

- Total plans completed: 5
- Average duration: 14 min
- Total execution time: 72 min

Historical milestone metrics remain in `.planning/MILESTONES.md` and archived
roadmaps.
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 89 P01 | 13min | 2 tasks | 2 files |
| Phase 89 P02 | 19min | 2 tasks | 1 files |
| Phase 89 P03 | 21min | 2 tasks | 1 files |
| Phase 89 P04 | 6min | 2 tasks | 6 files |
| Phase 90 P02 | 13min | 2 tasks | 3 files |

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

- [Phase 89]: Semantic acceptance freezes source, neutral, and documented sibling comparisons before live portrait evaluation. — Prevents live outcomes from selecting their own comparator.
- [Phase 89]: Semantic regions and verdict boundaries use checked integer PPM/Q16 arithmetic with byte-exact background and watermark protection. — Makes equality and one-unit boundary behavior deterministic and privacy-safe.
- [Phase 89]: Semantic verdicts require one conjunction of source signal, neutral signal, signed direction, locality, sibling distinction, and every protected-region ceiling. — Mechanical changed-pixel summaries remain descriptive and cannot accept a direction.
- [Phase 89]: Canonical semantic payloads exclude volatile timestamps and attempt IDs from their stable digest. — Equivalent admitted inputs remain byte-identical while reports retain run metadata outside the compared payload.
- [Phase 89]: The batch runner maps complete semantic failure to exit 3 and infrastructure failure to exit 2 with sanitized current report replacement.
- [Phase 89]: Two fresh CPU attempts reconcile only canonical stable payload bytes and digests; volatile attempt metadata and child output remain temporary.
- [Phase 89]: Retained attempts contain only parameter-watermarked portrait PNGs; renderer reports, repeat media, comparator reports, and transcripts are removed.
- [Phase 89]: Phase 89 completion certifies the shared semantic validation machinery; seven failing directions remain owned by Phases 90–94. — Preserves honest repair ownership and prevents validation completion from promoting behavior.
- [Phase 89]: Exit 3 is creditable complete semantic measurement, not infrastructure success or repaired-control acceptance. — Keeps complete semantic failure distinct from uncreditable runner faults.
- [Phase 90]: `chinTaper` exact-cap output uses three request-local bilateral
  contour pairs while compatible sub-cap requests retain the two-point topology.
  — Makes the frozen centerline target visible without borrowing sibling geometry.

- [Phase 90]: FACE-01 keeps the frozen `+16 Q16`, sibling, locality, and
  protection contract after all bounded provider-only candidates failed to
  satisfy it together. — Prevents a threshold reduction, unsafe inverse map,
  wider support leak, or another retained solver from masquerading as GREEN.

- [Phase 90]: On the autonomous blocker prompt, the owner selected
  `Fix and retry`; the retry may redesign FACE-01 internals but does not relax
  the frozen semantic/safety contract or current product boundary.

- [Phase 90]: Revision 8 uses a bounded seven-candidate two-dimensional
  provider-local search, renderer-effective full-strength swept-support and
  global injectivity certificates, an immutable frozen-oracle hash, and a
  retained read-only stop verifier. Independent plan review passed.

- [Phase 90]: Revision 8 execution exhausted A1–A4 and B1–B3 without one
  renderer-effective analytically admissible field; every candidate emitted
  zero admitted points and the frozen oracle stayed RED. Provider/test bytes
  were restored exactly and the retained verifier returned
  `FACE01_STOP_VERIFIED`; Tasks 90-01-02/03 and Plans 90-03/04 did not run.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- [Phase 90] FACE-01 is implementation-blocked after revision 8. All seven
  frozen bounded-2D candidates failed renderer-effective analytical admission,
  emitted zero points, and left the frozen method at its original hash with
  source/neutral Q16 `0/0`. Exact rollback plus the append-only aggregate stop
  record passed `FACE01_STOP_VERIFIED`; no success summary exists and Tasks
  90-01-02/03 plus Plans 90-03/04 remain blocked.

- [Phase 89] Independent pupil-to-own-eye support is intentionally absent and
  must be implemented in Phase 91 before gaze can receive semantic credit.

- [Phase 89] Phase 95 must complete the clean 65/65, eight-direction rerun;
  current unsupported gaze correctly publishes only a sanitized exit-2 envelope.

- Authorized portrait media and detailed outputs remain local and ignored;
  durable evidence must stay aggregate and privacy-safe.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Local retouch | Further teeth, sclera, and upper-eyelid optimization | Future separate milestone | v1.22 scope |
| Runtime/input breadth | Realtime/video, transparent/HDR, and device performance | Future | v1.22 scope |
| External use | Commercialization, packaging, shipping, launch, release readiness, and distribution | Prohibited until explicitly reopened | owner-local contract |

## Session Continuity

Last session: 2026-08-30T10:13:30+08:00
Stopped at: FACE-01 bounded-2D retry exhausted; typed implementation blocker
Resume file: `.planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md`
