---
gsd_state_version: 1.0
milestone: v1.22
milestone_name: Non-Local Facial Effect Repairs
current_phase: 91
current_phase_name: Independent Gaze Correction
status: executing
stopped_at: Completed 91-01-PLAN.md
last_updated: "2026-09-04T22:49:01Z"
last_activity: 2026-09-05
last_activity_desc: Phase 91 Plan 01 complete; advancing to Plan 02
state_head: 9653248d1f8f2d57c639b603b01682f2bd43e39b
progress:
  total_phases: 7
  completed_phases: 2
  total_plans: 12
  completed_plans: 9
  percent: 29
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-09-04)

**Core value:** The project owner's local iOS host can integrate `BeautySDK`
and get natural, controllable real-time and still-image beauty processing
without distributing the SDK, model, or weights.
**Current focus:** Phase 91 — Independent Gaze Correction

## Current Position

Phase: 91 (Independent Gaze Correction) — EXECUTING
Plan: 2 of 4
Status: Executing Phase 91
Last activity: 2026-09-05 — Plan 91-01 complete; advancing to Plan 91-02

Progress: [███████████████░░░░░] 9/12 plans (75%)

## Performance Metrics

**Current milestone:**

- Total plans completed: 9
- Average documented duration: 12 min across 8 timed summaries
- Total documented execution time: 94 min plus the untimed FACE-01 terminal record

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
| Phase 90 P03 | 6min | 2 tasks | 5 files |
| Phase 91 P01 | 10min | 2 tasks | 5 files |

## Accumulated Context

### Decisions

- [Phase 90]: Goal verification passed 25/25 after fresh focused `142/0/0`,
  compatibility `154/0/1`, comparator 554-mutation, preflight `75/65/8`,
  archive, boundary, and Phase 88/89 regression gates. FACE-02 is the sole
  completed requirement; FACE-01 remains `completed-deferred`, partial, and
  non-GREEN under FUTURE-04.

- [v1.22]: On 2026-09-02 the owner approved a bounded scope contraction: no
  FACE-01 revision 23; `faceContourSmooth` moves out of active v1.22
  requirements to FUTURE-04, remains unchanged and `partial`, and Phase 90
  closes as the completed FACE-02 chin repair plus evidence-backed FACE-01
  deferral. Phase 95 requires seven effective directions plus one explicit
  deferred/partial direction across the unchanged 65-output inventory.

- [v1.22]: Phases 91–94 are timeboxed to one research pass, one independently
  checked plan, and at most two implementation attempts before an explicit
  owner decision to repair, defer, or stop.

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

- [Phase 90]: Revision 11 executed only the fixed D1 extremum-overlap design.
  Its 7/7 canonical branches, common extremum class, five paired classes, and
  three-zone support passed, but all five Float states for the first mandatory
  shoulder carrier failed the exact cap/half subtraction identities. No field
  or rendered candidate was admitted; provider/test bytes were restored and
  the retained verifier emitted `FACE01_STOP_VERIFIED`.

- [Phase 90]: The owner selected `Fix and retry` after revision 11. Revision
  12 may replace the failed cap-target-first Float lattice only after a
  read-only proof that exact cap/half arithmetic is constructible and that the
  fixed D1 geometry has no known pre-render impossibility; it may not widen the
  rendered-output search or weaken any frozen/safety contract.

- [Phase 90]: Revision 12 research retired D1 before execution: a shared
  `g=Float(1.0 / 16_777_216.0)` lattice is construction-level exact, but the
  fixed D1 field fails actual containment on three of ten carriers and makes
  the complete-row proxy worse. The new bounded D1-v12 plan uses a complete
  twelve-slot-per-branch `k=2` chain with actual Float source anchoring,
  positive containment slack, adjacent-only overlap, and a pre-render chain
  proxy; its independent review passed with zero issues.

- [Phase 90]: Revision 12 execution exposed an implementation-only residual
  indexing defect: slot 1 used selected-slot neighbors instead of `Q(0)` and
  `Q(2/13)`, forcing all 25 exact-lattice states below the half-L1 floor.
  Revision 13 changes only this indexing block, adds a normalized v12 scaffold
  diff guard, preserves the exact five-section aggregate prefix, and keeps all
  geometry, safety, Float, oracle, and product contracts unchanged.

- [Phase 90]: Revision 13 executed the corrected endpoint-inclusive residual
  block and reached the first genuine zero-curvature slot. Revision 14 treats
  finite zero residuals as reference-only and allows only complete bilateral
  omission of nonmandatory zero pairs; mandatory extremum/neighbor slots,
  original non-bridging adjacency, coverage, all safety gates, and the frozen
  oracle remain unchanged.

- [Phase 90]: Revision 14 reached the zero-residual omission path, then its
  temporary scaffold returned an owner-slack placeholder without evaluating
  `H/R/B/adjB` or containment. Revision 15 adds only that actual Float owner
  gate and first-failure evidence, with every residual, lattice, geometry,
  safety, proxy, oracle, and frozen threshold contract unchanged.

- [Phase 90]: Revision 15 measured the actual Float owner gate: strict
  owner/unit membership and expanded-support containment passed on both
  branches, but the fixed positive-slack condition failed for five retained
  slots per side, first at zero-based slot 4. With `R=.75H` and `B=.08R`,
  the condition is equivalent to each original-adjacent retained clearance
  satisfying `H_neighbor/H_i <= 7/6`; the current contour violates that ratio.
  Nonzero mandatory pairs cannot be omitted, and `m_s` scaling occurs after
  admission, so no legal v15 implementation correction exists. Provider/test
  bytes were restored, the eighth aggregate suffix and `FACE01_STOP_VERIFIED`
  were verified, and no frozen oracle candidate was invoked.

- [Phase 90]: Revision 16 research is limited to a predeclared
  owner-balanced slot/carrier construction that proves the `7/6` clearance
  ratio before execution while preserving every v15 residual, exact Float
  lattice, geometry/safety, proxy, frozen-oracle, threshold, public, and
  privacy contract. No threshold tuning, mandatory-pair omission, or
  output-guided selection is permitted.

- [Phase 90]: Revision-16 feasibility audit found no provable construction
  within that contract. The source is rolled back and no revision-16 plan was
  written: changing owner clearance definitions or thresholds, omitting
  nonzero mandatory pairs, changing residual/lattice linkage, or selecting by
  rendered output would all be contract changes. FACE-01 therefore remains a
  verified terminal stop pending an explicit owner-authorized new contract or
  new evidence that enables a compliant construction.

- [Phase 90]: The owner then instructed the autonomous workflow to continue,
  authorizing revision 17 as one bounded internal contract change. For each
  branch, compute `H_branch` as the minimum actual-target owner clearance over
  retained slots and use the same fixed coefficients for every retained point:
  `R=.75H_branch`, `B=.08R`. With equal branch-local B, the existing positive
  slack left side is `.93H_branch`, strictly below `.94H_i` for every retained
  point. This changes no public API, inventory, renderer/backend/Warp.metal,
  frozen pixel oracle, safety threshold, privacy, SDK-only, or distribution
  boundary. All remaining actual Float overlap, no-triple, inverse, proxy,
  semantic, protection, and rollback gates remain mandatory.

- [Phase 90]: Revision 17 planning passed independent goal-backward review
  with zero blockers and zero warnings. The executable contract verifies the
  branch-minimum radius relations in their exact owner-document sections,
  requires the existing eight retry headings as an immutable prefix, and
  permits exactly one ninth aggregate-only suffix on rollback. The bounded
  execution may now run once; no alternative candidate, tuning, or
  rendered-output selection is authorized.

- [Phase 90]: Revision 17 executed exactly once. Canonical branches, all
  twelve analytical slots, extrema/zones, endpoint-inclusive residuals,
  paired zero omissions, exact lattice, branch-minimum owner proof,
  owner/unit/slack/expanded containment, forbidden-overlap checks, and
  bilateral adjacent-overlap presence passed. The first actual failure was
  the unchanged single-point `2*norm(d)/R <= 0.20` gate, so global
  Lipschitz/inverse/proxy and the frozen oracle were not reached. Provider and
  repair-test bytes were restored exactly; the ninth aggregate-only suffix
  and `FACE01_STOP_VERIFIED` were committed in `48fc3de`. No summary or
  downstream execution exists.

- [Phase 90]: Read-only post-stop feasibility diagnosis found no
  implementation-only correction under the frozen revision-17 contract. The
  maximum actual `2*norm(d)/R` was approximately `0.421763` against `0.20`;
  the maximum original-adjacent normalized sum was approximately `0.48149`
  against `0.40`, implying an inverse lower bound of approximately `0.51851`
  against the required `0.60`. A future retry must explicitly reopen at least
  one coupled contract dimension—displacement construction, radius/owner
  clearance, retained mandatory topology, or the `0.20/0.40` Lipschitz/inverse
  safety family—and still has no evidence that proxy or frozen-oracle gates
  would pass.

- [Phase 90]: The owner then instructed the autonomous workflow to continue,
  authorizing revision 18 to reopen only the internal displacement/target
  construction. Research may replace the fixed `d0=.18v`, its exact lattice
  linkage, or cap-target construction, but must preserve revision-17 retained
  topology and radius/owner clearance, the `0.20/0.40`, `Lip<=0.40`, and
  inverse `>=0.60` safety family, the frozen rendered oracle, all public/API,
  renderer/backend/Warp.metal, privacy, SDK-only, and non-distribution
  boundaries. No output-guided selection, oracle invocation, threshold
  relaxation, or execution is authorized before a deterministic construction
  is proved feasible and independently planned.

- [Phase 90]: Revision 18 research found one sole pre-output-feasible
  construction. Retain each revision-17 raw exact-lattice coefficient only as
  sign/reference, compute branch-minimum actual-Float source clearance, clip
  the emitted integer coefficient by `floor(Hsrc_branch/(64g))`, and rebuild
  cap/half/target from the same `g=2^-24` lattice. The construction proves
  single `<=8/45`, adjacent/global Lipschitz `<=16/45`, and inverse
  `>=29/45`; deterministic binary32 checks also retained required overlap,
  positive forbidden separation and owner slack, exact linkage, and strict
  proxy decrease. The frozen rendered oracle remains uninvoked and unknown.

- [Phase 90]: Revision 18 planning passed independent goal-backward review
  with zero blockers and zero warnings. The plan binds execution to the sole
  `Hsrc/16` construction, exactly one candidate-oracle invocation after every
  pre-render gate, and exact nine-prefix/tenth-suffix rollback. Research open
  questions are explicitly resolved; `90-VALIDATION.md` covers all nine Phase
  90 tasks with <=30-second task sampling while retaining the long focused,
  compatibility, comparator, archive, and SDK-boundary chain as a mandatory
  phase completion gate.

- [Phase 90]: Revision 18 executed exactly once. The temporary provider
  compiled, but the focused pre-render check observed an empty whole FACE-01
  field at both cap and half (`0/20`). The frozen candidate oracle was never
  invoked. Provider and repair-test bytes were restored exactly; the tenth
  aggregate-only suffix and retained `FACE01_STOP_VERIFIED` evidence were
  committed in `36d2ec5`. No `90-01-SUMMARY.md` or downstream execution
  exists.

- [Phase 90]: Read-only post-stop diagnosis classifies the revision-18 cause
  as indeterminate due to insufficient instrumentation. The durable evidence
  proves only the final whole-field abstention, not the earliest internal
  guard. Any future revision 19 must first receive explicit owner
  authorization and remain diagnostic-only: request-local sanitized
  first-failure categories plus aggregate template, retained-branch, and
  cap/half admission counts, with fixed-point aggregate margins only if
  necessary. It may persist no coordinates, geometry, pixels, private paths,
  or transcripts, and may not invoke the frozen oracle.

- [Phase 90]: The owner then instructed the `--auto` workflow to continue and
  complete the milestone, explicitly crossing the previously declared
  diagnostic authorization boundary for revision 19 only. Revision 19 may
  reconstruct the frozen revision-18 provider path solely to collect one
  request-local sanitized earliest-gate result and aggregate template,
  retained-branch, cap, and half counts. It must independently compare provider
  and reference finalization from the same in-memory template; return exactly
  `implementation_defect`, `genuine_construction_miss`,
  `prior_stop_not_reproduced`, or `diagnostic_invalid`; use a new static
  verifier because the existing stop verifier invokes the frozen RED oracle in
  normal mode; restore provider/tests byte-exact; preserve the exact ten-heading
  ATTEMPT prefix with at most one aggregate-only eleventh suffix; and stop
  without rendering, oracle invocation, construction/threshold change, or
  downstream execution.

- [Phase 90]: Revision 22 executed exactly once before this session and was
  committed in `fe2e8c2`. Its sole sanitized classification was
  `prior_stop_not_reproduced`: one request-local construction produced equal
  provider/reference cap and half admissions of 20/20 with 20 final points.
  Render and oracle invocation counts remained zero; provider/test returned
  byte-exact, temporary diagnostic symbols were absent, and the retained
  rollback verifier passed. This diagnostic result consumes revision 22 but
  does not repair FACE-01 or create GREEN evidence. The later owner scope
  decision authorizes only a terminal deferred summary and bounded closeout;
  it does not reinterpret revision 22 as a repair.

- [Phase 90]: Only measured Plan 90-02 facts are implemented FACE-02 evidence; source-defined one-step, cap-adjacent, quantization-adjacent, and tie cases remain Phase 95 direct-test residuals.
- [Phase 90]: FACE-01 remains callable, source-unchanged, fail-closed, partial, and non-GREEN; revision 22 is diagnostic-only and future repair requires separately authorized FUTURE-04.
- [Phase 91]: Preserve the existing paired pupil-size channel while retaining a separate request-local per-eye gaze pupil. — A peer ratio failure remains compatible for pupilSize without suppressing valid gaze anatomy.
- [Phase 91]: Require strict simple-aperture source and target containment with radius bounded by half the smaller clearance. — The generic minimum-radius clamp can exceed a small eye aperture.
- [Phase 91]: Count only exact final admitted gaze points in the six-field aggregate. — One-eye improvement or duplicate evidence cannot hide a rejected peer.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- [Phase 90] The former FACE-01 implementation blocker is resolved by scope,
  not by repair: revision 22 remains consumed diagnostic evidence and no GREEN
  claim is permitted. Further repair requires a separately authorized
  FUTURE-04 milestone.

- [Phase 89] Independent pupil-to-own-eye support is intentionally absent and
  must be implemented in Phase 91 before gaze can receive semantic credit.

- [Phase 89] Phase 95 must complete the clean 65/65 rerun with seven active
  directions effective and `faceContourSmooth` explicitly deferred/partial;
  current unsupported gaze correctly publishes only a sanitized exit-2 envelope.

- Authorized portrait media and detailed outputs remain local and ignored;
  durable evidence must stay aggregate and privacy-safe.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Face geometry | Further `faceContourSmooth` repair | Future separate milestone; current public field remains unchanged/partial | v1.22 Phase 90 contraction |
| Local retouch | Further teeth, sclera, and upper-eyelid optimization | Future separate milestone | v1.22 scope |
| Runtime/input breadth | Realtime/video, transparent/HDR, and device performance | Future | v1.22 scope |
| External use | Commercialization, packaging, shipping, launch, release readiness, and distribution | Prohibited until explicitly reopened | owner-local contract |

## Session Continuity

Last session: 2026-09-04T22:46:37.428Z
Stopped at: Completed 91-01-PLAN.md
Resume file: None
