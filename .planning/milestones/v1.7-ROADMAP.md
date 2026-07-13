# Roadmap: Beauty

## Milestones

- ✅ **v1.0 MVP** — Phases 1-7, shipped 2026-06-23.
- ✅ **v1.1 Meitu UI** — Phases 8-10, implemented and verified 2026-06-24.
- ✅ **v1.2 HTML Reference Fidelity** — Phase 11 completed and Phases 12-15 canceled, 2026-06-26.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** — Phases 16-20, shipped 2026-06-30.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** — Phases 21-25, shipped 2026-07-03.
- ✅ **v1.5 SDK Geometry Output Foundation and Face Shape Slice** — Phases 26-28, shipped 2026-07-08.
- ✅ **[v1.6 Broader `美型 / 五官` SDK Slice - Eyes](milestones/v1.6-ROADMAP.md)** — Phases 29-30, shipped 2026-07-13.
- 🚧 **v1.7 Broader `美型 / 五官` SDK Slice - Nose** — Phases 31-32.

## Current Milestone: v1.7 Broader `美型 / 五官` SDK Slice - Nose

### Phase 31: Nose Renderer Output Evidence

**Goal:** Produce deterministic public-facade renderer and ignored-gallery evidence for all four existing nose parameters, including both signed nose-tip directions.

**Requirements:** NOSE-01, NOSE-02, NOSE-03

**Status:** Complete - completed 2026-07-13

**Plans:** 4/4 plans complete

**Success Criteria:**

1. The renderer matrix contains 28 cases across seven fixtures and writes 196 ignored outputs.
2. All five locked nose cases set exactly one public parameter and compare against `geometryBaseline_noop` above the watermark band in the central-face region.
3. The helper passes 196/196 output invariants and 30/30 portrait comparisons, and positive/negative tip outputs differ from each other and baseline.
4. A representative no-face output exists at the original dimensions, gallery routing works, and no generated output/gallery file is tracked.

### Phase 32: Nose Safety, Ledger, and Closeout

**Goal:** Lock the nose slice's exact caps, signed semantics, degradation and combined-effect safety, boundary scans, exact four-row promotion, and milestone-closeout documentation.

**Requirements:** NOSE-04, NOSE-05, NOSE-06, NOSE-07, NOSE-08, DOC-01

**Status:** Complete - completed 2026-07-13

**Plans:** 7/7 plans complete

**Success Criteria:**

1. Focused tests lock exact caps, signed `noseTipSize`, missing/stale fail-closed behavior, reused `0.5` scaling, redacted diagnostics, and safe-domain continuation.
2. Combined weakening covers all four fields and preserves positive and negative tip direction alongside face/eye/mouth geometry.
3. Full SDK, renderer/helper, security, public-inventory, import, dependency, commercial, and artifact-containment gates pass with `threats_open: 0` and Nyquist compliance.
4. Exactly four nose rows are promoted while `山根`, `提升`, and branch-level `鼻子` remain partial/future, and all current-owner documentation agrees.

## Progress

- [x] Phase 31: Nose Renderer Output Evidence
- [x] Phase 32: Nose Safety, Ledger, and Closeout

| Phase | Plans Complete | Status | Completed |
| --- | --- | --- | --- |
| 31. Nose Renderer Output Evidence | 4/4 | Complete    | 2026-07-13 |
| 32. Nose Safety, Ledger, and Closeout | 7/7 | Complete    | 2026-07-13 |

## Backlog

- Remaining `鼻子` tools: resolve `山根` alias/parameter semantics and design `提升` independently.
- `嘴唇`, `比例`, `3D塑颜`, and `眉毛` remain future or partial slices.
- Device, commercial visual, packaging, performance, and launch-readiness evidence remains separately scoped.

---
*Roadmap created: 2026-07-13*
*Last updated: 2026-07-13 after Phase 32 verification passed*
