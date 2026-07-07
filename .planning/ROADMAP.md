# Roadmap: Beauty

## Overview

Beauty v1.5 is active. This milestone starts from `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` and implements the smallest first-principles slice needed to turn geometry-heavy `美型 / 五官` work from provider-only evidence into SDK-verifiable output.

The milestone remains SDK-core only: no new SwiftUI screens, no Demo UI rebuild, no remote processing, no account/commercial behavior, and no broad Meitu parity claim. The first implemented feature slice is `脸型` with existing public parameters after the public facade can produce saved geometry output.

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.2 HTML Reference Fidelity** - Phase 11 completed 2026-06-25; Phases 12-15 canceled 2026-06-26. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** - Phases 16-20 shipped 2026-06-30. See `.planning/milestones/v1.3-ROADMAP.md`.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** - Phases 21-25 shipped 2026-07-03. See `.planning/milestones/v1.4-ROADMAP.md`, `.planning/milestones/v1.4-REQUIREMENTS.md`, and `.planning/milestones/v1.4-MILESTONE-AUDIT.md`.
- 🔄 **v1.5 SDK Geometry Output Foundation and Face Shape Slice** - Phases 26-28, active.

## Phases

<details>
<summary>✅ v1.4 Stability, QA, and Debt Cleanup (Phases 21-25) - SHIPPED 2026-07-03</summary>

- [x] Phase 21: Baseline Audit and Quality Ledger Refresh (2/2 plans) - completed 2026-06-30.
- [x] Phase 22: Automated Demo QA and Screenshot Evidence (2/2 plans) - completed 2026-07-01.
- [x] Phase 23: Performance and Reliability Gates (5/5 plans) - completed 2026-07-02.
- [x] Phase 24: Renderer Output Regression Hardening (3/3 plans) - completed 2026-07-02.
- [x] Phase 25: Security, Distribution Review, and Closeout (3/3 plans) - completed 2026-07-03.

Archive files:

- `.planning/milestones/v1.4-ROADMAP.md`
- `.planning/milestones/v1.4-REQUIREMENTS.md`
- `.planning/milestones/v1.4-MILESTONE-AUDIT.md`

Accepted limitations remain future or setup-specific work: current screenshot PNG capture, physical iPhone parity, 600-second preview endurance, optimized profiling, geometry saved-output completion, external package integrity, and commercial packaging approval.

</details>

### Phase 26: Geometry Facade and Landmark Routing Foundation

**Status:** Complete - completed 2026-07-06
**Goal:** Make public `BeautySDK` still-image processing capable of activating geometry render intent from detection and landmarks without exposing raw geometry data.
**Requirements:** GEO-01, GEO-02
**Dependencies:** None
**Plans:** 4/4 plans complete
Plans:
**Wave 1**

- [x] 26-01-PLAN.md — Package-only selected-face geometry adapter and resolver routing.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 26-02-PLAN.md — Public still-image facade detection gating and selected-face routing.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 26-03-PLAN.md — Verification and validation evidence closeout.

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 26-04-PLAN.md — Root-doc and planning ledger synchronization.

**Cross-cutting constraints:**

- `SHAPE_FEATURE_LEDGER.md` `implemented` statuses remain unchanged in Phase 26, per D-12.

**Success Criteria:**

1. `BeautyEngine.processResult(...)` can exercise geometry-enabled still-image processing through the public facade.
2. Detection and landmark data can feed geometry render planning without Demo/internal-target imports.
3. Diagnostics, summaries, metrics, and errors remain redacted and do not expose raw landmark payloads or sensitive paths.
4. Existing no-UI and local-first boundaries remain intact.

**Evidence:** `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md` records focused facade, metadata compatibility, detector, resolver, and degradation tests plus full `swift test --package-path BeautySDK` passing with 159 tests. Static scans passed for public/SPI raw geometry export, active-source raw geometry/error/path/image-byte leakage, renderer geometry-case exclusion, and `SHAPE_FEATURE_LEDGER.md` implemented-status guard.

**Boundary:** Phase 26 proves facade geometry intent and package-internal routing only. Phase 27 remains the owner for deterministic saved-output geometry evidence; Phase 28 remains the owner for `脸型` implementation-status promotion.

### Phase 27: Geometry Render Output and Verification Harness

**Status:** Pending
**Goal:** Produce deterministic SDK-only saved-output evidence for geometry rendering and degradation behavior.
**Requirements:** GEO-03, GEO-04
**Dependencies:** Phase 26
**Plans:** 1/4 plans executed
Plans:
**Wave 1**

- [x] 27-01-PLAN.md — Real still-image detection input seam and public-facade fixture probe.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 27-02-PLAN.md — Selected-face geometry still-image render output path.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 27-03-PLAN.md — Renderer matrix, baseline comparison helper, and no-face saved-output evidence path.

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 27-04-PLAN.md — Final evidence, validation, root docs, and planning ledger synchronization.

**Success Criteria:**

1. Geometry render output preserves input dimensions for representative still-image fixtures.
2. `BeautyExampleRenderer` or an equivalent SDK-only path saves deterministic geometry output evidence.
3. Verification covers no-face, missing-landmark, stale/reused-landmark, and combined-strength degradation behavior.
4. Renderer evidence avoids commercial quality, UI, device parity, and full Meitu parity claims.

### Phase 28: Face Shape Slice Completion and Documentation Closeout

**Status:** Pending
**Goal:** Complete the `脸型` existing-parameter slice and update status ledgers only where facade-visible evidence exists.
**Requirements:** FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03
**Dependencies:** Phase 27

**Success Criteria:**

1. `脸宽`, `小脸`, `下巴长短`, `V脸`, and `下颌角` have SDK tests, safety/degradation evidence, and saved-output evidence through existing parameters.
2. `下颌线` is documented as a `jawSlim` alias or split into a future distinct SDK behavior decision.
3. `SHAPE_FEATURE_LEDGER.md` marks only verified `脸型` rows as `implemented`.
4. Beauty-shaping branch docs, `FEATURE_MATRIX.md`, and `EXAMPLE_IMAGE_VALIDATION.md` match the final evidence.
5. Phase verification records exact test, renderer, scan, and blocker evidence without claiming UI, commercial readiness, or full reference-app parity.

## Progress

| Milestone | Phases | Plans | Requirements | Status | Completed |
| --- | ---: | ---: | ---: | --- | --- |
| v1.0 MVP | 7 | 28 | 33/33 | Shipped | 2026-06-23 |
| v1.1 Meitu UI | 3 | 11 | 4/4 | Implemented and verified | 2026-06-24 |
| v1.2 HTML Reference Fidelity | 1 completed, 4 canceled | 4 completed | Reduced scope | Completed | 2026-06-26 |
| v1.3 Meitu Core Beauty Module Design and Implementation | 5 | 14 | 20/20 | Shipped | 2026-06-30 |
| v1.4 Stability, QA, and Debt Cleanup | 5 | 15 | 24/24 | Shipped | 2026-07-03 |
| v1.5 SDK Geometry Output Foundation and Face Shape Slice | 3 | 4 Phase 26 plans executed | 2/13 | Active - Phase 26 complete | - |

## Next

Execute Phase 27 saved-output geometry evidence:

```bash
$gsd-execute-phase 27
```

## Backlog

Future milestone candidates after v1.5:

- Broader `美型 / 五官` slices: `眼睛`, `鼻子`, `嘴唇`, `比例`, `3D塑颜`, and `眉毛`.
- Home/discovery feature system planning.
- Filters, makeup, stickers, templates, and resource-pack planning.
- AI retouch, background segmentation, cutout, and eraser planning.
- Video beauty, body shaping, and export pipeline planning.
- Gallery, account, search, premium access, commerce, and account authorization planning.
- SDK packaging, compatibility matrix, binary distribution, resource-pack trust model, and commercial integration docs.
