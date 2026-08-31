---
gsd_state_version: 1.0
milestone: v1.22
milestone_name: Non-Local Facial Effect Repairs
current_phase: 90
current_phase_name: Face Contour and Chin Repairs
status: executing
stopped_at: Revision 11 D1 plan independently verified; ready for bounded execution
last_updated: "2026-08-31T07:42:01Z"
last_activity: 2026-08-31
last_activity_desc: Revision 11 extremum-inclusive overlap-path D1 plan passed independent review
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

Phase: 90 (Face Contour and Chin Repairs) — EXECUTING
Plan: 1 of 4
Status: Revision 11 D1 ready for bounded execution
Last activity: 2026-08-31 — Independent revision-11 plan check passed with zero issues

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

- [Phase 90]: The owner selected `Fix and retry` again after revision 8. Six
  candidates first failed the single-field Lipschitz budget and one failed
  exact cap/half Float representability; effective-radius clamping and corridor
  containment were not the first blockers. Revision 9 must allocate safety and
  representability budgets before displacement construction.

- [Phase 90]: Revision 9 execution tried C1 then C2 exactly. Both failed the
  shared canonical support gate: the frozen contour supplies seven, not eight,
  points per strict corridor branch. No displacement/lattice state was admitted;
  exact rollback and retained `FACE01_STOP_VERIFIED` evidence passed.

- [Phase 90]: The revision-10 support audit confirmed seven canonical points,
  three distinct non-emitting anchor roles, and four eligible knots per side.
  C1's four-pair three-zone invariant is reachable; C2's five-pair invariant is
  arithmetically impossible. The next retry must retain C1 only and must not
  emit anchors, reuse sources, expand corridors, or tune rendered output.

- [Phase 90]: Revision 10 retains only the reachable C1 clipped-secant field,
  requires seven points, three distinct anchors, and four paired eligible
  classes across all zones, and independently passed plan review without
  changing any semantic or safety gate.

- [Phase 90]: Revision 10 executed the singular C1 path after proving 7/7
  branches, 3/3 distinct anchors, 4/4 eligible knots, per-side occupancy
  `[1,0,0,1,1,1]`, four corresponding pairs, and zone reachability `1/1/2`.
  Eight points passed budget/lattice/global-safety admission, but the unchanged
  oracle measured only `+1/+1 Q16` with frozen sibling margins `[5,8]` and
  strengthening margins `[15,11,1]`. Provider/test bytes were restored exactly
  and the retained verifier emitted `FACE01_STOP_VERIFIED`.

- [Phase 90]: The owner selected `Fix and retry` after revision 10 proved C1
  safe but semantically weak. Revision 11 must change the controllable degrees
  of freedom—such as certified extremum participation or overlap-aware support—
  rather than retune C1/C2 constants or weaken the frozen oracle.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- [Phase 90] FACE-01 remains unresolved while the independently verified,
  owner-authorized revision 11 D1 extremum-inclusive overlap-path field awaits
  bounded execution. Plans 90-03/04 remain blocked until a compliant GREEN
  summary exists.

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

Last session: 2026-08-31T15:42:01+08:00
Stopped at: Revision 11 D1 plan independently verified; ready for bounded execution
Resume file: `.planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md`
