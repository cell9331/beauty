# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 - MVP

**Shipped:** 2026-06-23
**Phases:** 7 | **Plans:** 28 | **Recorded tasks:** 62

### What Was Built

- Modular `BeautySDK` Swift Package with internal targets and a public facade.
- SwiftUI Demo validation app with camera mode, still-image mode, compare controls, presets, filters, sliders, disabled future states, parameter JSON, and redacted debug overlay.
- Local-first input, detection, metadata, effect, resource, privacy, and reliability paths with automated SDK and Demo tests.
- Milestone traceability covering 33/33 v1 requirements and 7/7 phase verification files.

### What Worked

- Vertical phase slices kept the SDK facade, Demo behavior, tests, and docs moving together.
- Facade-only scans caught boundary regressions cheaply.
- Fixture-based tests made effect and degradation behavior repeatable before relying on manual visual judgment.
- Keeping release-like claims separate from automated evidence prevented overclaiming visual, hardware, or performance readiness.

### What Was Inefficient

- Some early phase verification and validation artifacts were not committed or backfilled at close, which caused a documentation-only audit failure.
- Several planning artifacts remained untracked in the worktree, making milestone closeout noisier than necessary.
- Phase 5/6/7 validation files needed retroactive status cleanup even though implementation tests had already passed.

### Patterns Established

- Public facade imports are enforced by static scans and Demo tests.
- Every phase should close with `*-VERIFICATION.md`, `*-VALIDATION.md`, summary frontmatter `requirements-completed`, and exact command evidence.
- Manual release risks should be tracked as tech debt, not treated as passed automation.

### Key Lessons

1. Verification artifacts are part of the deliverable; missing docs can block a milestone even when code and tests are green.
2. Validation frontmatter and task tables need closeout updates at phase completion, not only at milestone audit time.
3. For user-facing SDK demos, keep three evidence classes separate: automated state tests, human-visible UAT, and hardware/performance release QA.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.0.
- Notable: Retroactive audit repair was more expensive than writing phase verification artifacts during each phase.

---

## Milestone: v1.3 - Meitu Core Beauty Module Design and Implementation

**Shipped:** 2026-06-30
**Phases:** 5 | **Plans:** 14 | **Recorded tasks:** 35

### What Was Built

- Public-facade `BeautyExampleRenderer` evidence path for ignored, watermarked, same-dimension example-image outputs.
- Current authority core beauty blueprint covering branch taxonomy, module ownership, branch status, future parameter needs, Demo-vs-SDK boundaries, and deferred Meitu product areas.
- Promoted Basic skin behavior with focused tests, renderer cases, output checks, and factual visual observations.
- Beauty-shaping provider/resolver/degradation/redaction evidence for existing public shaping fields without public API expansion or geometry renderer cases.
- Editor-shell closeout docs proving app-side Demo ownership for routing, preview chrome, bottom panel, commit flow, rails, sliders, compare/debug, cancel/confirm, and parameter snapshots.

### What Worked

- The no-new-UI boundary kept the milestone focused on SDK behavior, docs, tests, and renderer evidence instead of reopening SwiftUI scope.
- The branch status vocabulary (`implemented`, `partial`, `blocked-by-geometry-output`, `future`) prevented geometry-output overclaims while still recording real provider/resolver progress.
- Example-image output checks gave visible evidence for skin/color/filter cases while keeping generated PNGs ignored and out of git.
- Final scope scans caught the important integration boundaries: facade-only Demo, UI-free SDK internals, unchanged public parameters, and no renderer geometry-case drift.

### What Was Inefficient

- Phase 18 validation frontmatter kept `wave_0_complete: false` after execution because the test file was intentionally created during the phase; the audit had to interpret that note against later evidence.
- Broad sensitive-token scans over geometry implementation code produced expected false positives, so later plans had to narrow the privacy check to emitted warning/metric/debug strings.
- The live roadmap needed manual collapse after the archive primitive because old phase directories remained in place for lookup.

### Patterns Established

- Closeout docs should cite concrete test names, commands, static scans, and renderer evidence instead of broad capability claims.
- Geometry-heavy branches need an explicit evidence ladder: provider/resolver evidence is useful but does not count as saved-image completion.
- Milestone archival should be path-scoped when the repository has unrelated local documentation changes.

### Key Lessons

1. Keep accepted limitations in the same authority docs as completion claims, so future agents do not promote deferred geometry or release-hardening work by accident.
2. When validation depends on files created during execution, update the validation metadata or record a closeout note before milestone audit.
3. Example-image evidence is strongest when it combines build/run output, same-dimension checks, ignored-artifact checks, and narrow factual visual observations.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.3.
- Notable: The archive itself was cheap after Phase 20 because most evidence had already been captured in phase verification files.

---

## Milestone: v1.4 - Stability, QA, and Debt Cleanup

**Shipped:** 2026-07-03
**Phases:** 5 | **Plans:** 15 | **Recorded tasks:** 34

### What Was Built

- Current-evidence quality baseline covering SDK tests, renderer commands, Demo simulator blocker status, debt routing, and stale-map disposition.
- Demo QA evidence ledger that preserves exact build/test commands, no-PNG screenshot status, blocked per-state review notes, and disabled-route honesty without claiming screenshot success.
- Performance and reliability gates for 720p SDK timing, backpressure, dropped-frame accounting, reset, quality-mode, degradation, safety caps, redacted metrics, and focused Demo camera behavior.
- Renderer regression coverage through a public-facade matrix test, exact pre-watermark no-op fixture checks, a 45-output invariant helper, and durable example-image validation docs.
- Privacy, active-source security, bundled-resource trust, and traceability closeout with explicit future triggers for manifest, external packages, hardware, long-run, and commercial packaging work.

### What Worked

- Treating blocker-honest evidence as first-class output kept the milestone truthful without stalling on local screenshot tooling or physical-device availability.
- Focused tests and scoped scans gave strong gates for Demo backpressure, SDK degradation, renderer output, product-scope tokens, and resource trust without changing public API.
- The final audit made validation-document drift visible before archival, and the follow-up cleanup closed it without inventing new evidence.
- Archiving ROADMAP/REQUIREMENTS/AUDIT before deleting active requirements preserved traceability while keeping the next milestone context small.

### What Was Inefficient

- Phase 21 and Phase 22 validation files still needed retroactive final-status cleanup after the milestone audit.
- Phase 22 screenshot evidence stayed blocked even after Phase 23 focused Demo camera tests passed; the screenshot protocol needs its own rerun instead of inheriting later build evidence.
- Several no-overclaim scans had to be tuned around self-matching documentation strings, which added planning overhead.
- The working tree had unrelated documentation and asset changes, so final archive commits required strict file scoping.

### Patterns Established

- Current-evidence milestones can pass with accepted blocker paths when commands, environment, impact, non-claims, and rerun protocols are explicit.
- Renderer evidence should combine source-owned case inventory, exact no-op fixture checks, generated-output invariants, ignored-artifact checks, and no geometry overclaim.
- Privacy/resource closeout should separate active SDK/Demo behavior, tests/fixtures, example CLI behavior, policy docs, and future distribution triggers.
- Phase archival is optional; keeping phase directories in place is acceptable when historical path stability matters more than aggressive cleanup.

### Key Lessons

1. Validation metadata must be closed during phase execution; audit-time repair is avoidable documentation debt.
2. A passed build/test in one later scope does not erase an earlier screenshot blocker; each evidence lane needs its own command-backed rerun.
3. Future release-hardening work should split device, screenshot, long-run, optimized profiling, packaging, and external-resource integrity into explicit scoped phases.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.4 plus one archival session.
- Notable: The milestone close was smooth after validation debt was cleared, but unrelated local changes made path-scoped staging mandatory.

---

## Milestone: v1.5 - SDK Geometry Output Foundation and Face Shape Slice

**Shipped:** 2026-07-08
**Phases:** 3 | **Plans:** 12 | **Recorded tasks:** 22

### What Was Built

- Public still-image facade geometry activation through `BeautyEngine.processResult(...)`, with package-internal selected-face routing into geometry planning.
- Deterministic SDK-only saved-output geometry evidence through `BeautyExampleRenderer`, `geometryBaseline_noop`, `faceShapeCombo_0p35`, a no-face fixture, and the Phase 27 helper.
- Per-tool face-shape renderer evidence for `faceSlim`, `faceSmall`, signed `chinLength`, `faceVShape`, and `jawSlim`, with 102 ignored outputs, 30/30 top-region comparisons, and a post-ship correction from global proxy output to local control-point warp.
- Focused safety/degradation/redaction tests for caps, no-face/missing-contour behavior, signed `chinLength`, combined weakening, and `jawSlim` alias evidence.
- Scoped blueprint and planning ledger promotion for exactly six second-level `脸型` rows while keeping branch-level `脸型` partial.

### What Worked

- Splitting v1.5 into facade routing, renderer foundation, and per-tool status promotion prevented premature ledger changes.
- Renderer evidence stayed command-backed and ignored-output based, avoiding committed PNG baselines while still proving dimensions and visible geometry deltas.
- Alias handling for `下颌线` stayed conservative: shared `jawSlim` evidence, no new parameter, no Demo behavior, and no distinct algorithm.
- The milestone audit was cheap because Phase 26-28 verification, validation, summary frontmatter, and requirement traceability were already synchronized.

### What Was Inefficient

- The final archive still needed manual live-doc cleanup because the archive primitive did not collapse `ROADMAP.md` or evolve `PROJECT.md` fully.
- Local Swift LOC counting included build-derived `.build` files; future closeout stats should use an explicit source-only path filter when precision matters.
- The working tree still contains unrelated historical documentation and asset changes, requiring strict path-scoped commits.

### Patterns Established

- Geometry-heavy feature completion requires facade-visible saved-output evidence before `implemented` status.
- Generated-output helpers should report counts, dimensions, fixture/case IDs, and comparison counts without hashes, raw pixels, or raw geometry payloads.
- Top-region pixel comparisons are not sufficient by themselves for geometry completion; face-shape evidence also needs a spatial assertion that control points move local pixels while unaffected pixels remain unchanged.
- Branch-level status can remain partial while scoped second-level rows become implemented from evidence.

### Key Lessons

1. Do not promote feature-ledger status from provider/resolver evidence alone; require public-facade saved-output evidence for geometry-heavy rows.
2. Alias-backed features need explicit non-claims so future work does not accidentally split API, renderer, or algorithm behavior.
3. Milestone archive tooling is useful for canonical files, but PROJECT/ROADMAP/RETROSPECTIVE still need human review.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.5 plus audit/archive sessions.
- Notable: The v1.5 closeout benefited from prior v1.4 blocker-honest evidence patterns and required no new Swift verification during archive.

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v1.0 | multiple | 7 | Established GSD phase execution, facade-boundary scans, Nyquist validation, and milestone archive flow. |
| v1.3 | multiple | 5 | Added example-image renderer evidence and strict branch-status taxonomy for partial geometry work. |
| v1.4 | multiple | 5 | Added blocker-honest hardening gates, renderer output regression, active-source privacy/security scans, and archive-before-delete closeout. |
| v1.5 | multiple | 3 | Added public-facade geometry output evidence and scoped face-shape ledger promotion. |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v1.0 | 119 SDK tests plus Demo simulator XCTest suite | Requirement traceability 33/33 | No new third-party runtime dependency recorded for v1 Demo QA surface. |
| v1.3 | 141 SDK tests plus renderer matrix evidence | Requirement traceability 20/20 | No new third-party runtime dependency recorded for core beauty closeout. |
| v1.4 | 150 SDK tests, focused Demo privacy/import tests, renderer invariant helper, and milestone audit | Requirement traceability 24/24 | No new third-party runtime dependency recorded for hardening closeout. |
| v1.5 | 171 SDK tests, geometry and face-shape renderer helpers, and milestone audit | Requirement traceability 13/13 | No new third-party runtime dependency recorded for geometry closeout. |

### Top Lessons (Verified Across Milestones)

1. Keep facade-boundary and privacy scans cheap enough to run at every phase close.
2. Archive-ready planning artifacts need the same rigor as code and tests.
3. Separate provider/resolver evidence, saved-image evidence, and release-hardening evidence to avoid overclaiming shipped scope.
4. Blocker-honest evidence is useful only when paired with exact rerun commands and clear non-claims.
5. Geometry-heavy status promotion should be staged: routing, saved-output foundation, then per-tool ledger promotion.
