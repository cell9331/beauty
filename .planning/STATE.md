---
gsd_state_version: 1.0
milestone: v1.22
milestone_name: Non-Local Facial Effect Repairs
current_phase: 95
current_phase_name: Compatibility and SDK-only Closeout
status: completed
stopped_at: v1.22 historical snapshot complete; mapping follow-up current-tree qualification complete in append-only receipt
last_updated: "2026-09-23T16:50:32+08:00"
last_activity: 2026-09-23
last_activity_desc: Mapping follow-up verified COMPLETE at current identity; 65/65 twice, seven effective and one deferred, SwiftPM 938/0/0
state_head: 0bc58b4af3201c6767a1a6da2ba313bfda9a3a45
progress:
  total_phases: 7
  completed_phases: 7
  total_plans: 33
  completed_plans: 33
  percent: 100
---

# Project State

The frontmatter above is the completed v1.22 GSD snapshot. The separately
authorized [v1.23 FACE-01 follow-up](V1.23-FACE01-CURRENT.md) is currently
active in `PLANS.md`; its bounded generated candidate has not earned portrait
effectiveness or taxonomy promotion. No historical Phase 90/95 receipt is
reopened by that work.

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-09-23)

**Core value:** The project owner's local iOS host can integrate `BeautySDK`
and get natural, controllable real-time and still-image beauty processing
without distributing the SDK, model, or weights.
**Current focus:** [v1.22 current execution contract](V1.22-CURRENT.md).

## Current Position

The original v1.22 completion below is historical for its signed digest.
The later face-mapping repair changed normative files, so the old
`verify-complete` returns `review_missing_or_stale` on the current tree.
The separately scoped [append-only follow-up](qualifications/v1.22-mapping-followup/)
has now verified the current code under the same in-scope Phase95 acceptance:
65/65 outputs twice, seven effective and one deferred, safety 1/0/0,
compatibility 4/0/0 and archive-first SwiftPM 938/0/0 with eight opt-ins and
zero skips. Its distinct independent reviews and new COMPLETE bind current
input digest `0debce887ab95a49a4970f78dbb53f3500aca75d67861e4d493f011a176204af`.
This does not reopen or rewrite the historical milestone; use the new
`check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266`
for the current-tree claim.

Phase: 95 (Compatibility and SDK-only Closeout) — COMPLETE
Plans: 95-01 safety,95-02 compatibility,95-03 actual65/full regression,95-04 independent goal/finalization all complete.
Last activity: 2026-09-23 — v1.22 completed 2026-09-23: 7/7 phases, 33/33 plans, 11/11 active requirements; [verified COMPLETE](phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json).

Actual portrait: 65/65 outputs, 2 reconciled runs, seven effective directions and one deferred/partial direction. Current safety 1/0/0, compatibility 4/0/0, archive-first full SwiftPM 937/0/0; all 8 opt-ins accounted for.
Root: 31 fixed source pairs; source interval [260, 373] Q16, neutral interval [260, 373] Q16; all three sibling intervals pass; outside 0 pixels / 0 absolute RGB delta; all root protected-region changes are zero.
FACE-01/faceContourSmooth remains explicitly deferred/partial under FUTURE-04, without effectiveness credit. The repaired observed paired-eye root uses CPU; retained Metal rejects its unsupported private raster cutoff with typed invalidInput before submission and recovers for later supported requests. This is owner-local SDK validation, with no device, population, commercial quality, packaging, shipping, launch, release-readiness or distribution claim. No owner annotation or device action remains. Phase96 is absorbed into95-03, and no next milestone is started.
COMPLETE SHA256: `33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4`; normative input digest: `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`.

## Performance Metrics

**Current milestone:**

- Authored plans with summaries: 33/33; all seven milestone phases complete. Historical failures retain their original outcomes.
- Average documented duration: 13 min across 11 timed summaries
- Total documented execution time: 144 min plus the untimed FACE-01 terminal record

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
| Phase 90 P04 | 6min | 2 tasks | 4 files |
| Phase 91 P01 | 10min | 2 tasks | 5 files |
| Phase 91 P02 | 16min | 2 tasks | 4 files |
| Phase 91 P03 | 12 min | 2 tasks | 6 files |
| Phase 91 P04 | 22min | 3 tasks | 10 files |

## Accumulated Context

### Decisions

Current authorization and next steps are in V1.22-CURRENT.md. The dated records below
retain historical context; their superseded next-step/approval language is not a new blocker.

### Roadmap Evolution

- 2026-09-22: Phase96 draft absorbed into95-03; its old dependency on95 is retired. Preserve historical logs; no separate execution or retry loop.

- [Phase 93, 2026-09-10]: Owner explicitly approved root adapter positioning and corresponding regression/registration tests (D-09). Frozen ROI/thresholds/public interfaces remain unchanged; existing research reused and implementation budget remains two attempts. Approval clears the scope decision, not the technical registration gate.

- [Phase 92]: R5 passed independent 10/10 goal verification, focused 23/0/0 and frozen +48/-22 Q16 pixels. The per-side 0.9 summed displacement budget resolves dense-trace folding; historical failures remain unchanged. Phase 93 is next; Phase 95 retains portraits/no-skip.

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
- [Phase 91]: Attach gaze evidence only after conflict convergence and final eye-emission recomputation, using the exact effective strength and exact final points. — Pre-conflict intent or summed improvement cannot earn credit.
- [Phase 91]: Collapse any inconsistent or out-of-range six-key gaze aggregate to the fixed abstaining form. — Partial field repair cannot manufacture semantic credit.
- [Phase 91]: Prove gaze direction with independently declared chromatic marker identities and own-center plus peer-center checks. — Darkness and production-owned anatomy cannot serve as a circular oracle.
- [Phase 91]: Close EYE-01 in implementation attempt 1 with exact 840-test current-authority, 107-test compatibility, 576-mutation comparator, 75/65/8 preflight, backend-neutral, archive, and SDK-only evidence. — The single discovered Phase-90-deferred FACE-01 effectiveness oracle remains intentionally RED and receives no GREEN claim.
- [Phase 91]: Bind gaze semantic direction to the exact successful renderer output while preserving every actual-pixel target, sibling, locality, and protection gate, then verify temporary report cleanup. — Aggregate evidence cannot replace pixels or survive the request lifecycle.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

No unresolved blocker remains within the completed v1.22 scope. FACE-01/faceContourSmooth remains explicitly deferred/partial under FUTURE-04, without effectiveness credit. The repaired observed paired-eye root uses CPU; retained Metal rejects its unsupported private raster cutoff with typed invalidInput before submission and recovers for later supported requests. This is owner-local SDK validation, with no device, population, commercial quality, packaging, shipping, launch, release-readiness or distribution claim. No owner annotation or device action remains. Phase96 is absorbed into95-03, and no next milestone is started.
Authorized portraits and detailed outputs remain owner-local and outside durable evidence.

### Historical blocker notes — superseded current status, not pending instructions


- [Phase 90] The former FACE-01 implementation blocker is resolved by scope,
  not by repair: revision 22 remains consumed diagnostic evidence and no GREEN
  claim is permitted. Further repair requires a separately authorized
  FUTURE-04 milestone.

- [Phase 89] Phase 95 must complete the clean 65/65 rerun with seven active
  directions effective and `faceContourSmooth` explicitly deferred/partial;
  Phase 91 now makes gaze creditable, but does not run or publish that final
  owner-local portrait batch.

- Authorized portrait media and detailed outputs remain local and ignored;
  durable evidence must stay aggregate and privacy-safe.

- [Historical, resolved by reviewed gate amendment] Phase 93 plan 93-01 checkpoint: Task 1 complete; Task 2 has exact old-root RED 3 discovered / 2 passed / 1 expected failure / 0 skips. begin 1 stopped before admission because the frozen gate replaces root literals across unrelated regression fixtures. Attempts started 0/2; adapter/provider remain baseline exact. Gate and baseline binding amendment requires orchestrator disposition; no later plan or pixel scoring ran.

## Deferred Items

### Historical Phase 93 plan 02 checkpoint — 2026-09-10

Task 93-02-01 is complete (`1c9ffd27`): four independent metric methods pass 4/0/0. Task 93-02-02 is blocked; its six compiled public tests and failure receipt are retained in `2ed83f1a`, with checkpoint summary `e451eb08`. The frozen `red` command passed registration 4/0/0 and metrics 4/0/0, then stopped in the first lifecycle method at the named-sRGB assertion (4 discovered, 0 passed, 1 failed, 0 skipped; three unexecuted). One bounded diagnostic rerun found 24 failures only at that assertion. The retained raw CPU geometry route uses device RGB; parent disposition is required before reconciling the plan's named-sRGB requirement. No assertion, provider, fixture, SPI, gate, authority or registration change was made. Both semantic directions remain unmeasured; no `93-RED.json` exists and no plan 93-03 work ran. Shared attempt 1 remains open with one begin and zero finish; do not repeat begin 1. Both NOSE requirements remain active. This scoped checkpoint supplements preserved parent state and historical entries; it does not advance the plan counter.

### Historical Phase 93 plan 02 complete — 2026-09-10

Plan 93-02 is complete, 2/2 tasks. Fresh current-gate registration 4/0/0, metrics 4/0/0, lifecycle 4/0/0 and semantics 2/0/0 passed; freeze event 23 created immutable 93-RED.json (`571a87141a7ffcf77e2d5c42c7a9e43edd2ac3510a07751775ef4d09ef234f84`). Both directions are baseline_pass with the original provider: bridge 858 changed / 56232 RGB / +563 Q8 / minimum sibling 553; root 964 / 92187 / +133 Q16 / minimum sibling 133. Source/neutral results match; all protection maxima are 0/0 and repeated-byte status is 1/1. Final evidence is committed in `6af5d87f`; complete summary in `16d77c50`. Historical failures 15/18 remain preserved under exact reviewed authoring dispositions. Shared attempt 1 remains open (one begin / zero finish). Parent coordinates plan 93-03: only independently demonstrated safety/scaling regressions may be changed, never efficacy tuning to manufacture RED. Both NOSE requirements remain active pending later phase work. No plan 93-03 execution, rollback, budget reset or broad parent-state resynchronization occurred.

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Face geometry | Further `faceContourSmooth` repair | Future separate milestone; current public field remains unchanged/partial | v1.22 Phase 90 contraction |
| Local retouch | Further teeth, sclera, and upper-eyelid optimization | Future separate milestone | v1.22 scope |
| Runtime/input breadth | Realtime/video, transparent/HDR, and device performance | Future | v1.22 scope |
| External use | Commercialization, packaging, shipping, launch, release readiness, and distribution | Prohibited until explicitly reopened | owner-local contract |

## Session Continuity

### Current completion handoff — 2026-09-23

Last session: 2026-09-23
Stopped at: v1.22 completed; no active next milestone or unresolved root diagnosis
Resume file: .planning/phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json (read-only verification, no diagnostic continuation)

v1.22 completed 2026-09-23: 7/7 phases, 33/33 plans, 11/11 active requirements; [verified COMPLETE](phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json).
No resumption of historical Phase95 diagnosis, manual annotation, or retired Phase96 scripts is pending.
Use `python3 scripts/check-phase95-closeout.py verify-complete` for read-only receipt validation.
COMPLETE SHA256: `33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4`; normative input digest: `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`.

### Historical session records — not current instructions

### Historical Phase 93 plan 03 terminal checkpoint — 2026-09-10

Plan 93-03 is halted, 1/2 tasks complete. Task 1 committed `811734f2`: unchanged-provider RED discovered 22 methods, 17 passed, 5 expected-failing methods, zero skips; exactly three centered IDs plus four named scaling/budget/cutoff IDs are frozen in PROVIDER-RED (`650e48e51a4701fa653bfb53e24955dc239e46b420f12decb841bb91adb09138`). Fixed candidate 1 compiled and passed authorities, then failed `testFinalFloatFieldBudgetAndDenseMap` / `P93_FIELD_BUDGET` at ledger sequence 25 (22 discovered, 18 passed, 1 failed, zero skips; three unexecuted). Candidate source is preserved in `e4e89680`. This is a blocking safety conjunction; no second candidate, post-evaluation correction or semantic rerun occurred. Both candidate directions remain untested; prior bridge/root baseline_pass evidence remains historical.

Sequence 26 finishes shared attempt 1 as failed/assertion_failure/production_restored; rollback commit `5392e9d1` restores the exact pinned original adapter and provider. The ledger contains one begin and one finish. All immutable bindings and corrected root/new provider tests remain as failing historical proof. Both NOSE requirements remain active; no phase completion or 93-04/05 work. See 93-03-SUMMARY.md. Parent repair/defer/stop disposition is required; no retry budget is reset. Parent frontmatter, position, config/state.json/runtime/lock and unrelated state entries remain preserved.

> Last session: 2026-09-14
> Stopped at: Resumed Phase95 Plan03; diagnosing the precise automatic registration failure without altering frozen predicates
> Resume file: .planning/debug/phase95-semantic-repair.md

### Historical Phase 93 completion handoff

Independent verification passed18/18, both NOSE requirements and D-01–D-10 satisfied. Current candidate2 is retained: core36, compatibility229, commands8, deterministic regression106, design3 and owners7 passed. The ledger preserves candidate1 failure, timeout39/rollback40 and supplemental selection failure55 with their reviewed dispositions. Phase94 is next to plan, not started. Administrative tracking was updated in scoped Markdown files to preserve pre-existing config/state.json/runtime/lock changes.

### Historical Phase94 prerequisite handoff — 2026-09-11

94-01 is complete, 3/3 prerequisite tasks. Fresh `check-phase94-metadata-recovery.py baseline` passed 9/0/0 and read-only status revalidated the receipt. `94-METADATA-BASELINE.json` SHA256 `5a8b3d22d8378b8b0746877c62f4c3d0c97f9bd220ca501d38737bb8d3711c64` binds positive/protection evidence, all 14 retained rows and source digest. Actual source/adapter registration passed; the canonical 0/2 source calculation remains a separate control. Original preparation failure and retained-row failure remain immutable under two exact independently reviewed test/infrastructure corrections.

Next: execute94-02 (negative oracle/public baseline), then94-03..06. Five remaining plans/eleven tasks passed independent review after two integrity/order fixes;8/8 decisions and1/1 requirement are covered. Same checked Phase94 plan set covers candidate/safety/lifecycle/compatibility/goal/owners. One research pass, one checked plan set, attempts0/2; negative pixels unmeasured and MOUTH-01 incomplete. No Phase95 advancement. Bound planning input documents stay unchanged; current execution status lives in SUMMARY and receipts. Scoped Markdown tracking preserves pre-existing config/state-cache/runtime/lock bytes.

### Historical Phase94 negative baseline handoff

94-02 completed3/3 tasks. Its independently reviewed and frozen original-provider baseline executed13 methods:12 passed,1 semantic failure,0 skipped/unexecuted. Negative contraction and all three sibling margins pass, but height/outside protection each measures506 changed pixels/79962 RGB. Four fixed protection assertions fail in one method;14 retained output hashes remain exact. The runner authoring corrections and initial evidence are preserved under the separate exact disposition. Current runner self-tests16/16,72 attacks; oracle author-build exit0 and zero tests before review/freeze.

Continue94-03: author/build the four actual Float field methods and four signed lifecycle methods, obtain independent review, freeze safety, then full-baseline41. Do not modify frozen tests/runner/source/thresholds or begin a production attempt before full baseline selection. Research1, checked plan sets1, attempts0/2. MOUTH-01 remains incomplete; Phase95 excluded.

### Historical Phase94 full baseline handoff

94-03 completed2/2 tasks. Full baseline41 executed/39 passed/2 failed/0 skipped/unexecuted preserves the four negative height/outside failures and two actual-field crossing/interior-reversal markers. All lifecycle/other field/retained-provider/degradation checks pass;14 row hashes remain exact. Receipt hash10a867678984aba6a543834560ba6775c047c0eb40306b501799966e998356c6. Selection choosesA, attempts0/2 until counted begin. Continue94-04 compile/review/seal before fresh acceptance. Frozen inputs and limits unchanged; no Phase95.

### Historical Phase94 policyB acceptance handoff

94-04 complete2/2 tasks. A failed only source/neutral changed count392<500, with all protections/field/lifecycle/retained rows passing. Preserve commit3230d016 and rollback event; begin2 allowed only the predeclared gap/7 change. B compiled, independently reviewed, sealed and accepted41/41 with zero skips/failures. CHECKS fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4; provider7c3218d0586704cb078b4c7e2004805e182341c37b371567f204094be59153c8. Each source/neutral target520/73743/−24Q16; all protections0/0. Attempts2/2, research1, same checked plan set.

Continue94-05 independent implementation/security review then owners;94-06 final owner hash binding and independent goal report before receipt-only finalize. No frozen code/test/runner edits, no old live authority replay, no Phase95. PLANS must reach its required conditional snapshot before final owner binding and remain unchanged after binding.

### Historical Phase94 final-owner handoff

94-05 complete2/2; fresh independent implementation/security review passed with0 blockers/high findings. All seven final owner files were validated and bound by the latest qualification event. PLANS contains its required conditional snapshot and MUST NOT be edited after this binding.94-06 Task1 is complete; independent goal verification is running. Only a matching goal PASS and receipt-only finalize can close MOUTH-01. Parent may update administrative STATE/ROADMAP/REQUIREMENTS after completion, never sealed owners in this handoff.

### Phase94 completed handoff — 2026-09-11

All six plans complete. MOUTH-01 is complete under current CHECKS41/41 and independent goal28/28. COMPLETE SHA256 fbfa022b732c0a6ba4e633d98e996620badf1a5e1daa2213a270c8e165acdeeb was atomically published and read-only status revalidated phase_complete:true. Source/neutral520 changed/73743 RGB/−24Q16, all negative protections0/0 and14 retained row hashes exact; actual-field/lifecycle/degradation checks pass. Research1, checked plan sets1, attempts2/2; original and policyA failures/rollback remain immutable.

No owner file changed after final qualification binding. PLANS intentionally remains its sealed conditional verifying snapshot, with current completion determined by the valid receipt. Phase95 is the remaining milestone phase and has not started: private portraits/final65/full no-skip and device/commercial/distribution claims are not credited here. User config/state-cache/runtime/lock changes remain untouched.

<!-- beauty-v122-complete-sha256: 33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4 -->
