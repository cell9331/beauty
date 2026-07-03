# Roadmap: Beauty

## Overview

Beauty v1.4 has shipped and is archived. The active roadmap is intentionally kept short so the next milestone can start from fresh requirements without carrying the full v1.4 phase body in the working context.

Current product direction remains a modular local-first iOS `BeautySDK` plus a SwiftUI Demo validation app. Future work should start with `$gsd-new-milestone` and promote only the next scoped milestone requirements.

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.2 HTML Reference Fidelity** - Phase 11 completed 2026-06-25; Phases 12-15 canceled 2026-06-26. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** - Phases 16-20 shipped 2026-06-30. See `.planning/milestones/v1.3-ROADMAP.md`.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** - Phases 21-25 shipped 2026-07-03. See `.planning/milestones/v1.4-ROADMAP.md`, `.planning/milestones/v1.4-REQUIREMENTS.md`, and `.planning/milestones/v1.4-MILESTONE-AUDIT.md`.

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

## Progress

| Milestone | Phases | Plans | Requirements | Status | Completed |
| --- | ---: | ---: | ---: | --- | --- |
| v1.0 MVP | 7 | 28 | 33/33 | Shipped | 2026-06-23 |
| v1.1 Meitu UI | 3 | 11 | 4/4 | Implemented and verified | 2026-06-24 |
| v1.2 HTML Reference Fidelity | 1 completed, 4 canceled | 4 completed | Reduced scope | Completed | 2026-06-26 |
| v1.3 Meitu Core Beauty Module Design and Implementation | 5 | 14 | 20/20 | Shipped | 2026-06-30 |
| v1.4 Stability, QA, and Debt Cleanup | 5 | 15 | 24/24 | Shipped | 2026-07-03 |

## Next

No active milestone is defined. Start the next milestone with:

```bash
$gsd-new-milestone
```

## Backlog

Future milestone candidates after v1.4:

- Public facade geometry saved-image output for geometry-heavy beauty shaping branches.
- Home/discovery feature system planning.
- Filters, makeup, stickers, templates, and resource-pack planning.
- AI retouch, background segmentation, cutout, and eraser planning.
- Video beauty, body shaping, and export pipeline planning.
- Gallery, account, search, premium access, commerce, and account authorization planning.
- SDK packaging, compatibility matrix, binary distribution, resource-pack trust model, and commercial integration docs.
