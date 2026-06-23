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

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v1.0 | multiple | 7 | Established GSD phase execution, facade-boundary scans, Nyquist validation, and milestone archive flow. |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v1.0 | 119 SDK tests plus Demo simulator XCTest suite | Requirement traceability 33/33 | No new third-party runtime dependency recorded for v1 Demo QA surface. |

### Top Lessons (Verified Across Milestones)

1. Keep facade-boundary and privacy scans cheap enough to run at every phase close.
2. Archive-ready planning artifacts need the same rigor as code and tests.
