# Roadmap: Beauty

## Overview

Beauty v1.4 is a stability, QA, and technical-debt cleanup milestone. It converts known post-v1.3 release-hardening risks into measurable gates: baseline audit, automated Demo visual QA, performance/reliability evidence, renderer output regression, privacy/resource review, and documentation/traceability cleanup.

This milestone does not add Meitu product-surface breadth, public parameter fields, remote-processing behavior, paid-account flows, or broad UI redesign. Phase numbering continues from Phase 21, and existing `.planning/phases/` history directories remain in place.

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.2 HTML Reference Fidelity** - Phase 11 completed 2026-06-25; Phases 12-15 canceled 2026-06-26. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** - Phases 16-20 shipped 2026-06-30. See `.planning/milestones/v1.3-ROADMAP.md`, `.planning/milestones/v1.3-REQUIREMENTS.md`, and `.planning/milestones/v1.3-MILESTONE-AUDIT.md`.
- 🟡 **v1.4 Stability, QA, and Debt Cleanup** - Phase 21 complete; Phases 22-25 planned.

## v1.4 Stability, QA, and Debt Cleanup

### Phase 21: Baseline Audit and Quality Ledger Refresh

**Goal:** Establish the true v1.4 quality, verification, and technical-debt baseline before implementation changes.
**Mode:** audit / planning cleanup
**Depends on:** v1.3 archive and v1.4 research package
**Requirements:** AUD-01, AUD-02, AUD-03, AUD-04

**Success Criteria:**

1. `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, and `.planning/STATE.md` agree on the current v1.4 scope, open debt, and known blockers.
2. Existing SDK, Demo, renderer, import-boundary, and privacy verification commands are inventoried with pass/fail/blocker status.
3. TD-005, TD-008, TD-009, and TD-010 are triaged into v1.4 phases, explicitly deferred, or marked blocked with evidence.
4. No product-feature or public-API expansion enters the baseline phase.

**Plans:** 2/2 plans complete

- **Wave 1:** `21-01` Baseline verification sweep and evidence ledger - complete in `21-BASELINE-AUDIT.md`.
- **Wave 2:** `21-02` Quality score, debt routing, and planning ledger refresh - complete in `21-VERIFICATION.md`. Depends on `21-01`.

**Current evidence:** Phase 21 `swift test --package-path BeautySDK` passed with 141 XCTest cases, `BeautyExampleRenderer` built and wrote 45 ignored outputs, boundary/privacy scans passed, and explicit Demo simulator build/test evidence is blocked by the missing local Metal Toolchain. TD-005 routes to Phase 25; TD-008 splits to Phase 22/Phase 23 with physical iPhone checks blocked until hardware evidence exists; TD-009 routes to Phase 22; TD-010 splits across Phases 22, 23, 24, and 25. Stale `.planning/codebase/*` maps are deferred background.

**Next command:** `$gsd-discuss-phase 22`

### Phase 22: Automated Demo QA and Screenshot Evidence

**Goal:** Add repeatable Demo visual/layout evidence for current Home and Editor surfaces.
**Mode:** QA automation
**Depends on:** Phase 21
**Requirements:** QA-01, QA-02, QA-03, QA-04

**Success Criteria:**

1. Stable launch routes and explicit simulator destinations capture or verify Home first screen, Home sticky state, and editor tool-panel evidence.
2. Selected target simulator sizes verify that current controls, labels, badges, and panels do not clip or overlap.
3. `.planning/evidence/v1.4/` records screenshots or documented local blockers with commands, framing, and review notes.
4. Unsupported/future product areas stay inactive and honest; no new UI route is accidentally enabled.

**Plans:** 2 plans ready

- **Wave 1:** `22-01` Demo build/test prerequisite sweep, Metal Toolchain blocker/pass evidence, and route/model disabled-honesty checks.
- **Wave 2:** `22-02` Simulator screenshot capture or blocker-preserving rerun protocol with factual review notes. Depends on `22-01`.

**Next command:** `$gsd-execute-phase 22`

### Phase 23: Performance and Reliability Gates

**Goal:** Turn reliability budgets into repeatable timing, backpressure, long-run, reset, quality-mode, and redaction checks.
**Mode:** reliability / performance
**Depends on:** Phase 21
**Requirements:** PERF-01, PERF-02, PERF-03, PERF-04, PERF-05

**Success Criteria:**

1. Current 720p or fixture-based processing paths have a repeatable timing command or test and compare results to `RELIABILITY.md` budgets.
2. Backpressure, dropped-frame accounting, and latest-frame-wins behavior remain covered by tests or a reproducible harness.
3. Quality mode, reset, degradation, and safety-cap behavior are verified so optimization does not bypass recovery rules.
4. Long-run memory/preview stability has automated evidence, manual evidence, or a documented hardware/tooling blocker.
5. Logs, warnings, metrics, and performance artifacts stay optional and redacted.

**Plans:** Not planned yet
**Next command:** `$gsd-discuss-phase 23` after Phase 21 completes

### Phase 24: Renderer Output Regression Hardening

**Goal:** Promote `BeautyExampleRenderer` from closeout evidence to a stable output-regression gate.
**Mode:** regression / renderer QA
**Depends on:** Phase 21
**Requirements:** RENDER-01, RENDER-02, RENDER-03, RENDER-04

**Success Criteria:**

1. The renderer matrix documents all current visible skin/color/filter cases and runs through the public `BeautySDK` facade.
2. Default/no-op processing has a near-copy regression check with an explicit tolerance.
3. Visible-output cases verify non-empty output, same dimensions, readable watermarks, and factual visible changes.
4. Geometry-heavy branches keep honest `partial`, `blocked-by-geometry-output`, or `future` status unless public facade geometry output exists.

**Plans:** Not planned yet
**Next command:** `$gsd-discuss-phase 24` after Phase 21 completes

### Phase 25: Security, Distribution Review, and Closeout

**Goal:** Close v1.4 with privacy/resource/log review, final negative scans, score updates, and traceability consistency.
**Mode:** security / closeout
**Depends on:** Phases 21-24
**Requirements:** SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03

**Success Criteria:**

1. Privacy manifest status is assessed against actual SDK/Demo behavior and Apple required-reason API usage.
2. No-network, no-upload, raw-path, raw-framework-error, face-geometry, raw-JSON, third-party SDK, and hidden-product-scope scans pass.
3. Resource trust boundaries match `SECURITY.md`, including bundled presets, metadata filters, resource identifiers, and missing-resource behavior.
4. `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` are synchronized with v1.4 evidence.
5. The milestone is ready for audit without unmapped requirements.

**Plans:** Not planned yet
**Next command:** `$gsd-discuss-phase 25` after Phase 24 completes

## Progress

| Phase | Milestone | Requirements | Plans Complete | Status |
| --- | --- | --- | ---: | --- |
| 21. Baseline Audit and Quality Ledger Refresh | v1.4 | AUD-01, AUD-02, AUD-03, AUD-04 | 2/2 | Complete |
| 22. Automated Demo QA and Screenshot Evidence | v1.4 | QA-01, QA-02, QA-03, QA-04 | 0/2 | Planned |
| 23. Performance and Reliability Gates | v1.4 | PERF-01, PERF-02, PERF-03, PERF-04, PERF-05 | 0/0 | Planned |
| 24. Renderer Output Regression Hardening | v1.4 | RENDER-01, RENDER-02, RENDER-03, RENDER-04 | 0/0 | Planned |
| 25. Security, Distribution Review, and Closeout | v1.4 | SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 | 0/0 | Planned |

**Coverage:**

- v1.4 requirements: 24 total
- Mapped to phases: 24
- Unmapped: 0

## Backlog

Future milestone candidates after v1.4:

- Public facade geometry saved-image output for geometry-heavy beauty shaping branches.
- Home/discovery feature system planning.
- Filters, makeup, stickers, templates, and resource-pack planning.
- AI retouch, background segmentation, cutout, and eraser planning.
- Video beauty, body shaping, and export pipeline planning.
- Gallery, account, search, premium access, commerce, and account authorization planning.
- SDK packaging, compatibility matrix, binary distribution, resource-pack trust model, and commercial integration docs.
