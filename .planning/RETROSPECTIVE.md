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

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v1.0 | multiple | 7 | Established GSD phase execution, facade-boundary scans, Nyquist validation, and milestone archive flow. |
| v1.3 | multiple | 5 | Added example-image renderer evidence and strict branch-status taxonomy for partial geometry work. |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v1.0 | 119 SDK tests plus Demo simulator XCTest suite | Requirement traceability 33/33 | No new third-party runtime dependency recorded for v1 Demo QA surface. |
| v1.3 | 141 SDK tests plus renderer matrix evidence | Requirement traceability 20/20 | No new third-party runtime dependency recorded for core beauty closeout. |

### Top Lessons (Verified Across Milestones)

1. Keep facade-boundary and privacy scans cheap enough to run at every phase close.
2. Archive-ready planning artifacts need the same rigor as code and tests.
3. Separate provider/resolver evidence, saved-image evidence, and release-hardening evidence to avoid overclaiming shipped scope.
