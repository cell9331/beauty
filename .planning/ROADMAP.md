# Roadmap: Beauty

## Overview

Beauty has completed v1.5 and is awaiting the next milestone cycle. The shipped product remains a modular, local-first iOS beauty SDK with a rich SwiftUI Demo validation app that uses only the public `BeautySDK` facade.

For the full archived v1.5 scope, see:

- `.planning/milestones/v1.5-ROADMAP.md`
- `.planning/milestones/v1.5-REQUIREMENTS.md`
- `.planning/milestones/v1.5-MILESTONE-AUDIT.md`

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.2 HTML Reference Fidelity** - Phase 11 completed 2026-06-25; Phases 12-15 canceled 2026-06-26. Summary is in `.planning/MILESTONES.md`.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** - Phases 16-20 shipped 2026-06-30. See `.planning/milestones/v1.3-ROADMAP.md`.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** - Phases 21-25 shipped 2026-07-03. See `.planning/milestones/v1.4-ROADMAP.md`, `.planning/milestones/v1.4-REQUIREMENTS.md`, and `.planning/milestones/v1.4-MILESTONE-AUDIT.md`.
- ✅ **v1.5 SDK Geometry Output Foundation and Face Shape Slice** - Phases 26-28 shipped 2026-07-08. See `.planning/milestones/v1.5-ROADMAP.md`, `.planning/milestones/v1.5-REQUIREMENTS.md`, and `.planning/milestones/v1.5-MILESTONE-AUDIT.md`.

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

</details>

<details>
<summary>✅ v1.5 SDK Geometry Output Foundation and Face Shape Slice (Phases 26-28) - SHIPPED 2026-07-08</summary>

- [x] Phase 26: Geometry Facade and Landmark Routing Foundation (4/4 plans) - completed 2026-07-06.
- [x] Phase 27: Geometry Render Output and Verification Harness (4/4 plans) - completed 2026-07-07.
- [x] Phase 28: Face Shape Slice Completion and Documentation Closeout (4/4 plans) - completed 2026-07-08.

Archive files:

- `.planning/milestones/v1.5-ROADMAP.md`
- `.planning/milestones/v1.5-REQUIREMENTS.md`
- `.planning/milestones/v1.5-MILESTONE-AUDIT.md`

Accepted limitations remain future or setup-specific work: broader `美型 / 五官` slices, Demo UI work, physical-device parity, commercial visual review, screenshot reruns, optimized profiling, packaging review, and launch-readiness evidence.

</details>

## Progress

| Milestone | Phases | Plans | Requirements | Status | Completed |
| --- | ---: | ---: | ---: | --- | --- |
| v1.0 MVP | 7 | 28 | 33/33 | Shipped | 2026-06-23 |
| v1.1 Meitu UI | 3 | 11 | 4/4 | Implemented and verified | 2026-06-24 |
| v1.2 HTML Reference Fidelity | 1 completed, 4 canceled | 4 completed | Reduced scope | Completed | 2026-06-26 |
| v1.3 Meitu Core Beauty Module Design and Implementation | 5 | 14 | 20/20 | Shipped | 2026-06-30 |
| v1.4 Stability, QA, and Debt Cleanup | 5 | 15 | 24/24 | Shipped | 2026-07-03 |
| v1.5 SDK Geometry Output Foundation and Face Shape Slice | 3 | 12 | 13/13 | Shipped | 2026-07-08 |

## Next

Start the next milestone:

```bash
$gsd-new-milestone
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
