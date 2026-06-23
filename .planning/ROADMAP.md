# Roadmap: Beauty

## Overview

Beauty v1.1 rebuilds the SwiftUI Demo around the local `meituxiuxiu` references. The goal is to replace the prior SDK-dashboard-like first screen with a Meitu Xiuxiu-style Home experience and a Meitu-style editor surface while preserving the existing local-first `BeautySDK` facade, camera/photo pipelines, parameter store, compare behavior, and privacy boundaries.

Visual reference contracts:

- Home: `meituxiuxiu/HOME_MAP.md`
- Editor: `meituxiuxiu/FUNCTION_MAP.md`

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- 🚧 **v1.1 Meitu UI** - Phases 8-10, in planning/execution.

## Phases

<details>
<summary>v1.0 MVP (Phases 1-7) - shipped 2026-06-23</summary>

- [x] Phase 1: SDK Foundation and Public Facade (4/4 plans) - completed 2026-06-11
- [x] Phase 2: Demo Integration Shell (3/3 plans) - completed 2026-06-11
- [x] Phase 3: Realtime and Still Input Slice (4/4 plans) - completed 2026-06-12
- [x] Phase 4: Detection and Coordinate Safety (5/5 plans) - completed 2026-06-18
- [x] Phase 5: Filters, Presets, and Resource Flow (4/4 plans) - completed 2026-06-19
- [x] Phase 6: Core Beauty Effects (5/5 plans) - completed 2026-06-22
- [x] Phase 7: Rich Demo QA Surface (3/3 plans) - completed 2026-06-23

</details>

## 🚧 v1.1 Meitu UI (Phases 8-10)

### Phase 8: Meitu Home Rebuild

**Goal:** Replace the Demo first screen with a Meitu Xiuxiu-style Home matching `meituxiuxiu/HOME_MAP.md`.
**Mode:** mvp
**Depends on:** v1.0 Demo shell and reference docs
**Requirements:** HOME-01, HOME-02, HOME-03, HOME-04, HOME-05, HOME-06
**Success Criteria** (what must be TRUE):

1. The first visible Demo screen uses the reference-style dark Home, not SDK-dashboard copy.
2. The retro film hero, search/VIP/brand chrome, `拍一拍` CTA, and brown primary action hierarchy are present.
3. The tool grid supports the three reference paging states with a visible page indicator.
4. Recommendation image rails and the floating bottom tab bar match the reference structure.
5. Scrolling produces a sticky horizontal shortcut rail like `IMG_0874.PNG`.

**Plans:** 0/4 plans complete
Plans:

**Wave 1**

- [ ] 08-01: Add Home data models, visual constants, local image/reference assets, and deterministic view-state tests.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 08-02: Implement the Home hero, primary action cards, paged tool grid, recommendation rails, and bottom tab bar.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 08-03: Implement Home scroll behavior and sticky shortcut rail.

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 08-04: Verify Home layout through focused tests and screenshot/manual evidence against `HOME_MAP.md`.

### Phase 9: Meitu Editor Tool Panel

**Goal:** Rebuild the editor surface around the Meitu-style full-screen preview and bottom `美型 / 五官` tool panel from `meituxiuxiu/FUNCTION_MAP.md`.
**Mode:** mvp
**Depends on:** Phase 8
**Requirements:** EDIT-01, EDIT-02, EDIT-03, EDIT-04, EDIT-05, EDIT-06, EDIT-07
**Success Criteria** (what must be TRUE):

1. The editor displays a full-screen camera/photo preview above a white tool panel instead of a form-like control surface.
2. The editor chrome includes brand capsule, `背景保护`, compare affordance, shared slider, `整体`, cancel, and confirm controls.
3. The first-level categories and second-level tools match the deduplicated `FUNCTION_MAP.md` taxonomy.
4. Supported tools update existing `BeautyParameterStore` parameters through the shared slider.
5. Unsupported reference tools are visible but disabled/static with honest badge/state treatment.
6. Cancel and confirm preserve the preview, compare state, selected input mode, and local-first behavior.

**Plans:** 0/4 plans complete
Plans:

**Wave 1**

- [ ] 09-01: Add editor taxonomy models for first-level categories, second-level tools, badges, support status, and parameter mappings.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 09-02: Implement the full-screen editor layout and bottom Meitu tool panel.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 09-03: Wire supported tool selection and slider edits into `BeautyParameterStore` while preserving compare/debug/JSON behavior.

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 09-04: Verify editor taxonomy, disabled tools, parameter mapping, and visual reference behavior.

### Phase 10: Home-to-Editor Flow and v1.1 QA

**Goal:** Connect Home actions to existing camera/photo/editor processing paths and close v1.1 verification without overclaiming unsupported reference features.
**Mode:** mvp
**Depends on:** Phase 9
**Requirements:** FLOW-01, FLOW-02, FLOW-03, FLOW-04, FLOW-05, FLOW-06
**Success Criteria** (what must be TRUE):

1. `图片美化` opens the local photo editing path and preserves existing PhotosPicker/still-image processing behavior.
2. `相机` and `拍一拍` open the local camera path and preserve permission, realtime processing, and privacy behavior.
3. `人像美容` opens the editor focused on the Meitu-style beauty panel.
4. Unsupported Home and Editor actions are visibly disabled/static without network/upload behavior or fake success states.
5. Automated tests cover Home structure, editor taxonomy, route targets, parameter mapping, disabled states, and facade-only imports.
6. v1.1 has recorded screenshot/manual evidence for Home first screen, Home scrolled state, and Editor tool panel against the local references.

**Plans:** 0/3 plans complete
Plans:

**Wave 1**

- [ ] 10-01: Add Home action routing into photo, camera, and editor-focused flows while keeping unsupported actions disabled.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 10-02: Add focused view-state, flow, privacy, and import-boundary tests for v1.1 behavior.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 10-03: Run full Demo/SDK verification, capture visual evidence, and update root docs/quality score for v1.1.

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
| --- | --- | ---: | --- | --- |
| 1. SDK Foundation and Public Facade | v1.0 | 4/4 | Complete | 2026-06-11 |
| 2. Demo Integration Shell | v1.0 | 3/3 | Complete | 2026-06-11 |
| 3. Realtime and Still Input Slice | v1.0 | 4/4 | Complete | 2026-06-12 |
| 4. Detection and Coordinate Safety | v1.0 | 5/5 | Complete | 2026-06-18 |
| 5. Filters, Presets, and Resource Flow | v1.0 | 4/4 | Complete | 2026-06-19 |
| 6. Core Beauty Effects | v1.0 | 5/5 | Complete | 2026-06-22 |
| 7. Rich Demo QA Surface | v1.0 | 3/3 | Complete | 2026-06-23 |
| 8. Meitu Home Rebuild | v1.1 | 0/4 | Planned | - |
| 9. Meitu Editor Tool Panel | v1.1 | 0/4 | Planned | - |
| 10. Home-to-Editor Flow and v1.1 QA | v1.1 | 0/3 | Planned | - |

## Backlog

Future milestone candidates:

- Full `图库`, `AI 修图`, and `我` tab implementation.
- Real AI Home tools, template details, search, VIP, and recommendation-card flows.
- New SDK algorithm families for 3D/Pro shaping, makeup, segmentation/background, body shaping, stickers, AR masks, style effects, and video export.
- Distribution readiness: privacy manifest, resource-pack strategy, binary packaging, compatibility matrix, and commercial SDK documentation.
