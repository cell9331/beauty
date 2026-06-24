# Roadmap: Beauty

## Overview

Beauty v1.2 corrects the Meitu UI workflow: convert the two local Meitu reference surfaces into static HTML baselines first, verify those HTML baselines in a browser, then optimize SwiftUI against the approved HTML rather than tuning directly from screenshots.

Visual reference contracts:

- Home screenshots and map: `meituxiuxiu/home/`, `meituxiuxiu/HOME_MAP.md`
- Editor screenshots and map: `meituxiuxiu/IMG_0856.PNG` through `IMG_0870.PNG`, `meituxiuxiu/FUNCTION_MAP.md`
- Planned HTML outputs: `meituxiuxiu/html/home.html`, `meituxiuxiu/html/editor.html`, `meituxiuxiu/html/README.md`
- Planned v1.2 evidence: `.planning/evidence/v1.2/`

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24.
- 🚧 **v1.2 HTML Reference Fidelity** - Phases 11-15, planned 2026-06-24.

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

<details>
<summary>v1.1 Meitu UI (Phases 8-10) - implemented 2026-06-24</summary>

- [x] Phase 8: Meitu Home Rebuild (4/4 plans) - completed 2026-06-24
- [x] Phase 9: Meitu Editor Tool Panel (4/4 plans) - completed 2026-06-24
- [x] Phase 10: Home-to-Editor Flow and v1.1 QA (3/3 plans) - completed 2026-06-24

</details>

## 🚧 v1.2 HTML Reference Fidelity (Phases 11-15)

### Phase 11: HTML Reference Baselines

**Goal:** Build local static HTML baselines for the two reference surfaces before touching SwiftUI.
**Mode:** mvp
**Depends on:** v1.1 screenshots, `meituxiuxiu/HOME_MAP.md`, `meituxiuxiu/FUNCTION_MAP.md`
**Requirements:** HTML-01, HTML-02, HTML-03, HTML-04, HTML-05
**Success Criteria** (what must be TRUE):

1. `meituxiuxiu/html/home.html` opens locally and represents Home first screen, paged grid, recommendation rails, bottom tabs, and sticky shortcut state.
2. `meituxiuxiu/html/editor.html` opens locally and represents the editor preview chrome, white bottom panel, category rails, badges, slider, cancel, and confirm controls.
3. HTML references are deterministic and offline with no network requests, upload paths, analytics, or remote assets.
4. Browser screenshots for both HTML pages are captured under `.planning/evidence/v1.2/`.

**Plans:** 0/4 plans complete
Plans:

**Wave 1**

- [ ] 11-01: Create `meituxiuxiu/html/` structure, reference README, shared CSS tokens, and local-only asset policy.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 11-02: Implement the Home HTML baseline from `HOME_MAP.md` and `meituxiuxiu/home/`.
- [ ] 11-03: Implement the Editor HTML baseline from `FUNCTION_MAP.md` and editor screenshots.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 11-04: Capture browser screenshots and verify HTML local/offline behavior.

### Phase 12: HTML-to-SwiftUI Delta Contract

**Goal:** Convert HTML baselines into a measurable SwiftUI design contract before implementation.
**Mode:** mvp
**Depends on:** Phase 11
**Requirements:** AUDIT-01, AUDIT-02, AUDIT-03
**Success Criteria** (what must be TRUE):

1. Current SwiftUI Home and Editor screenshots are captured in the same simulator framing used for v1.1 evidence.
2. A delta report identifies concrete differences between HTML and SwiftUI: dimensions, colors, typography, spacing, hierarchy, scroll/sticky states, badges, and rails.
3. A component/token mapping names the SwiftUI files and subviews that own each delta.

**Plans:** 0/3 plans complete
Plans:

**Wave 1**

- [ ] 12-01: Capture current SwiftUI screenshots for Home first screen, Home sticky state, and Editor tool panel.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 12-02: Write `meituxiuxiu/html/SWIFTUI_DELTA.md` comparing HTML baselines to SwiftUI screenshots.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 12-03: Write the SwiftUI token/component mapping and phase acceptance matrix.

### Phase 13: Home SwiftUI Fidelity Pass

**Goal:** Update SwiftUI Home using the approved Home HTML baseline and delta contract.
**Mode:** mvp
**Depends on:** Phase 12
**Requirements:** HSWIFT-01, HSWIFT-02, HSWIFT-03
**Success Criteria** (what must be TRUE):

1. Home hero, search/brand/VIP chrome, `拍一拍`, action cards, grid, recommendations, and bottom tabs align with the Home HTML baseline.
2. Sticky shortcut and grid/page states match the Home HTML baseline while preserving existing supported routes and disabled/static unsupported actions.
3. Focused tests and screenshot evidence show Home no longer depends on ad hoc visual guesses.

**Plans:** 0/3 plans complete
Plans:

**Wave 1**

- [ ] 13-01: Apply Home HTML tokens to SwiftUI Home layout, typography, colors, cards, and rails.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 13-02: Tune Home sticky/page states and supported/disabled route affordances.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 13-03: Update Home tests and capture optimized Home screenshots.

### Phase 14: Editor SwiftUI Fidelity Pass

**Goal:** Update SwiftUI Editor using the approved Editor HTML baseline and delta contract.
**Mode:** mvp
**Depends on:** Phase 13
**Requirements:** ESWIFT-01, ESWIFT-02, ESWIFT-03
**Success Criteria** (what must be TRUE):

1. Editor preview chrome and bottom panel match the Editor HTML baseline more closely than v1.1 evidence.
2. Category rails, second-level tools, icon sizing, label spacing, badges, slider, `整体`, `背景保护`, cancel, and confirm controls align with the HTML baseline.
3. Existing parameter bindings, camera/photo paths, compare/debug/JSON behavior, and cancel/confirm semantics remain intact.

**Plans:** 0/3 plans complete
Plans:

**Wave 1**

- [ ] 14-01: Apply Editor HTML tokens to `EditorShellView` preview chrome and bottom-panel container.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 14-02: Tune `MeituEditorToolPanelView` category rails, tool items, badges, slider, and actions.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 14-03: Preserve editor behavior with focused tests and capture optimized Editor screenshots.

### Phase 15: v1.2 Visual QA and Closeout

**Goal:** Verify the HTML-first workflow end to end and document remaining gaps honestly.
**Mode:** mvp
**Depends on:** Phase 14
**Requirements:** VQA-01, VQA-02, VQA-03
**Success Criteria** (what must be TRUE):

1. Automated tests cover HTML assumptions, Home/Editor view-state contracts, supported routes, parameter mappings, disabled states, and launch-only screenshot hooks.
2. Full Demo simulator tests, SDK SwiftPM tests, facade scans, offline HTML scans, and whitespace checks pass.
3. Final evidence records HTML baselines, SwiftUI before/after screenshots, the delta report, accepted gaps, and future work.

**Plans:** 0/3 plans complete
Plans:

**Wave 1**

- [ ] 15-01: Add or update contract tests and scans for HTML-first assumptions.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 15-02: Run full Demo/SDK verification, facade scans, offline HTML scans, and visual evidence capture.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 15-03: Update root docs, quality score, requirements, roadmap, state, and PLANS closeout for v1.2.

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
| 8. Meitu Home Rebuild | v1.1 | 4/4 | Complete | 2026-06-24 |
| 9. Meitu Editor Tool Panel | v1.1 | 4/4 | Complete | 2026-06-24 |
| 10. Home-to-Editor Flow and v1.1 QA | v1.1 | 3/3 | Complete | 2026-06-24 |
| 11. HTML Reference Baselines | v1.2 | 0/4 | Planned | - |
| 12. HTML-to-SwiftUI Delta Contract | v1.2 | 0/3 | Planned | - |
| 13. Home SwiftUI Fidelity Pass | v1.2 | 0/3 | Planned | - |
| 14. Editor SwiftUI Fidelity Pass | v1.2 | 0/3 | Planned | - |
| 15. v1.2 Visual QA and Closeout | v1.2 | 0/3 | Planned | - |

## Backlog

Future milestone candidates:

- Automated screenshot diffing and multi-device visual sweeps.
- Full `图库`, `AI 修图`, and `我` tab implementation.
- Real AI Home tools, template details, search, VIP, and recommendation-card flows.
- New SDK algorithm families for 3D/Pro shaping, makeup, segmentation/background, body shaping, stickers, AR masks, style effects, and video export.
- Release hardening: real-device camera/Vision parity, production render quality, performance budgets, long-run hardware checks, privacy manifest, and distribution readiness.
