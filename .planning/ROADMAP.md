# Roadmap: Beauty v1.6 Broader `美型 / 五官` SDK Slice - Eyes

## Overview

v1.6 extends the shipped v1.5 geometry-output foundation to the existing public `眼睛` SDK parameters. The milestone remains SDK-core only: it adds public-facade renderer evidence, focused safety/degradation tests, and scoped ledger promotion for evidence-backed eye tools without adding Demo UI, public API fields, commercial behavior, network/cloud behavior, or release-readiness claims.

For completed prior scope, see:

- `.planning/milestones/v1.5-ROADMAP.md`
- `.planning/milestones/v1.5-REQUIREMENTS.md`
- `.planning/milestones/v1.5-MILESTONE-AUDIT.md`

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24.
- ✅ **v1.2 HTML Reference Fidelity** - Phase 11 completed 2026-06-25; Phases 12-15 canceled 2026-06-26.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** - Phases 16-20 shipped 2026-06-30.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** - Phases 21-25 shipped 2026-07-03.
- ✅ **v1.5 SDK Geometry Output Foundation and Face Shape Slice** - Phases 26-28 shipped 2026-07-08.
- ◆ **v1.6 Broader `美型 / 五官` SDK Slice - Eyes** - Phases 29-30 planned 2026-07-09.

## Phases

| Phase | Name | Goal | Requirements | Success Criteria |
| ---: | --- | --- | --- | --- |
| 29 | Eye Renderer Output Evidence | Add eye-specific public-facade renderer cases and helper evidence using existing public parameters only. | EYE-01, EYE-02, EYE-03 | 4 |
| 30 | Eye Safety, Ledger, and Closeout | Prove safety/degradation/redaction boundaries, promote only scoped `眼睛` rows, and synchronize docs. | EYE-04, EYE-05, EYE-06, EYE-07, EYE-08, DOC-01 | 5 |

### Phase 29: Eye Renderer Output Evidence

**Goal:** Extend `BeautyExampleRenderer` and verification helpers so existing public eye parameters produce verifiable saved-output evidence through the public `BeautySDK` facade.

**Requirements:** EYE-01, EYE-02, EYE-03

**Plans:** 3/4 plans executed

**Success criteria:**

1. `BeautyExampleRenderer` includes one case per existing eye behavior needed for evidence: `eyeSize`, positive and negative `eyeDistance`, positive and negative `eyeYPosition`, and `eyeTailLift`.
2. A Phase 29 helper validates all expected renderer outputs across committed input fixtures, including same dimensions and non-empty generated PNGs.
3. Usable portrait fixture eye outputs differ from `geometryBaseline_noop` above the watermark band; no-face fixture output is present and safely degraded.
4. Generated output/gallery files remain ignored, flat output names remain deterministic, and no generated PNG baseline is committed.

**Notes:**

- Reuse the Phase 27/28 helper pattern and the current nested `example-images/input/` fixture layout.
- Do not add Demo UI, public parameters, public raw geometry, entitlement/commercial strings, or non-eye renderer cases.

Plans:

- [x] `29-01-PLAN.md` — Add locked eye renderer cases, inventory tests, and the Phase 29 output helper.
- [x] `29-02-PLAN.md` — Add ignored `eyes/` gallery support and update example-image validation docs.
- [x] `29-03-PLAN.md` — Record command-backed eye renderer evidence, verification, and validation.
- [ ] `29-04-PLAN.md` — Synchronize Phase 29 planning ledgers and quality evidence without eye status promotion.

### Phase 30: Eye Safety, Ledger, and Closeout

**Goal:** Close the `眼睛` existing-parameter slice with focused safety/degradation/redaction evidence and scoped documentation promotion.

**Requirements:** EYE-04, EYE-05, EYE-06, EYE-07, EYE-08, DOC-01

**Success criteria:**

1. Focused XCTest coverage proves eye caps, no-face behavior, missing-eye-landmark skips, no stale/reused eye geometry, and combined-geometry weakening.
2. Boundary scans pass for public raw geometry leakage, Demo internal SDK imports, renderer internal imports, network/cloud behavior, and commercial entitlement paths.
3. `SHAPE_FEATURE_LEDGER.md` promotes exactly `眼睛` rows backed by existing public parameters: `大小`, `上下`, `眼距`, and `眼尾上扬`.
4. `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, root contracts, `QUALITY_SCORE.md`, `PLANS.md`, and phase verification artifacts record the evidence and limitations.
5. Branch-level `眼睛` remains `partial`, and future eye tools without public parameter/resource design remain future.

**Notes:**

- The phase should not claim commercial visual quality, device parity, launch readiness, full Meitu parity, or whole-branch `眼睛` completion.
- If renderer evidence from Phase 29 reveals a fixture-specific weakness, record the limitation and keep promotion scoped to command-backed evidence.

## Progress

| Milestone | Phases | Plans | Requirements | Status | Completed |
| --- | ---: | ---: | ---: | --- | --- |
| v1.0 MVP | 7 | 28 | 33/33 | Shipped | 2026-06-23 |
| v1.1 Meitu UI | 3 | 11 | 4/4 | Implemented and verified | 2026-06-24 |
| v1.2 HTML Reference Fidelity | 1 completed, 4 canceled | 4 completed | Reduced scope | Completed | 2026-06-26 |
| v1.3 Meitu Core Beauty Module Design and Implementation | 5 | 14 | 20/20 | Shipped | 2026-06-30 |
| v1.4 Stability, QA, and Debt Cleanup | 5 | 15 | 24/24 | Shipped | 2026-07-03 |
| v1.5 SDK Geometry Output Foundation and Face Shape Slice | 3 | 12 | 13/13 | Shipped | 2026-07-08 |
| v1.6 Broader `美型 / 五官` SDK Slice - Eyes | 2 | 4 | 3/9 | In Progress | — |

## Next

Execute Phase 29:

```bash
$gsd-execute-phase 29
```

## Backlog

Future milestone candidates after v1.6:

- Broader `美型 / 五官` slices: `鼻子`, `嘴唇`, `比例`, `3D塑颜`, and `眉毛`.
- Remaining unscoped `眼睛` tools that need new parameter/resource design.
- Home/discovery feature system planning.
- Filters, makeup, stickers, templates, and resource-pack planning.
- AI retouch, background segmentation, cutout, and eraser planning.
- Video beauty, body shaping, and export pipeline planning.
- Gallery, account, search, premium access, commerce, and account authorization planning.
- SDK packaging, compatibility matrix, binary distribution, resource-pack trust model, and commercial integration docs.
