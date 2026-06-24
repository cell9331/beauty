# Requirements: Beauty

**Defined:** 2026-06-24
**Milestone:** v1.2 HTML Reference Fidelity
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.2 Requirements

Requirements for the HTML-reference-first fidelity pass. Each requirement maps to exactly one roadmap phase.

### HTML Reference Pages

- [ ] **HTML-01**: User or agent can open a static Home HTML reference page generated from `meituxiuxiu/home/` screenshots and `meituxiuxiu/HOME_MAP.md`.
- [ ] **HTML-02**: User or agent can open a static Editor HTML reference page generated from the editor screenshots `IMG_0856.PNG` through `IMG_0870.PNG` and `meituxiuxiu/FUNCTION_MAP.md`.
- [ ] **HTML-03**: The Home HTML covers first screen, tool-grid paging, recommendation rails, bottom tabs, and sticky shortcut state; the Editor HTML covers preview chrome, bottom tool panel, first-level categories, second-level rails, badges, slider, cancel, and confirm controls.
- [ ] **HTML-04**: HTML references are local, deterministic, and offline: no network fonts, no remote images, no analytics, no upload, and no hidden runtime service.
- [ ] **HTML-05**: Browser screenshots are captured for the Home HTML first screen, Home HTML sticky state, and Editor HTML tool panel as v1.2 baseline evidence.

### HTML-to-SwiftUI Design Contract

- [ ] **AUDIT-01**: Current SwiftUI Home and Editor screenshots are captured using the same simulator/device framing as the HTML references.
- [ ] **AUDIT-02**: A visual delta report compares HTML baselines against current SwiftUI, covering layout, spacing, typography, color, card proportions, toolbar placement, category rails, badges, and sticky behavior.
- [ ] **AUDIT-03**: A design-token and component contract maps HTML measurements and states to SwiftUI files/components before SwiftUI edits begin.

### Home SwiftUI Fidelity Pass

- [ ] **HSWIFT-01**: SwiftUI Home is updated from the approved Home HTML reference for hero composition, search/brand/VIP chrome, `拍一拍`, primary action cards, tool grid, recommendation rails, and bottom tabs.
- [ ] **HSWIFT-02**: SwiftUI Home sticky shortcut behavior and page/grid states match the Home HTML reference while preserving supported local routes and disabled/static unsupported actions.
- [ ] **HSWIFT-03**: Home view-state tests and screenshot evidence prove the optimized SwiftUI Home matches the HTML reference closely enough for v1.2 acceptance.

### Editor SwiftUI Fidelity Pass

- [ ] **ESWIFT-01**: SwiftUI Editor preview chrome and white bottom panel are updated from the approved Editor HTML reference.
- [ ] **ESWIFT-02**: SwiftUI Editor category rails, tool icons, labels, `限免` / `Pro` / `OFF` badges, shared slider, `整体`, `背景保护`, cancel, and confirm controls match the Editor HTML reference.
- [ ] **ESWIFT-03**: Editor parameter binding, camera/photo processing, compare/debug/JSON behavior, cancel/confirm semantics, and unavailable-state honesty remain unchanged while visual fidelity improves.

### Verification and Closeout

- [ ] **VQA-01**: Automated tests cover the HTML contract assumptions, Home/Editor view-state structure, supported routes, parameter mappings, disabled states, and launch-only screenshot hooks.
- [ ] **VQA-02**: Full Demo simulator tests, full SDK SwiftPM tests, facade import scans, offline/no-network HTML scans, and `git diff --check` pass after SwiftUI optimization.
- [ ] **VQA-03**: v1.2 final evidence records HTML baselines, before/after SwiftUI screenshots, the delta report, unresolved visual gaps, and explicit out-of-scope items.

## Future Requirements

Deferred to later releases. These are valuable but not in this milestone unless explicitly promoted.

### Advanced Visual Automation

- **FUT-01**: Pixel-diff or perceptual-diff tooling automatically compares HTML and SwiftUI screenshots with thresholds.
- **FUT-02**: Multi-device visual sweeps cover compact, regular, Dynamic Type, landscape, and dark/light variations.
- **FUT-03**: HTML references are expanded into a full clickable prototype for `图库`, `AI 修图`, `我`, search, VIP, and recommendation details.

### Product Expansion

- **FUT-04**: Real AI tools, video editing, VIP entitlement behavior, and tab-specific screens become functional flows.
- **FUT-05**: New SDK algorithm families support advanced 3D/Pro shaping, makeup, segmentation/background, body shaping, stickers, AR masks, style effects, and video export.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Full commercial Meitu/Xingtu product parity | v1.2 is a fidelity workflow correction, not full feature parity. |
| Copying commercial assets as production assets | Local screenshots are references; implementation must recreate structure and feel with owned/local code and assets. |
| Network AI generation or upload flows | Current privacy posture remains local-first and no-upload by default. |
| Real video editing pipeline | `修视频` and `视频美容` can remain static/disabled until a dedicated video milestone. |
| VIP/paywall entitlement logic | `VIP`, `Pro`, and `限免` remain visual/static states unless promoted later. |
| New SDK algorithm families | v1.2 optimizes the Demo UI using existing SDK parameters and pipelines. |
| Hardware/performance release hardening | Real-device camera/Vision parity, 720p timing, long-run thermal/memory, and production render quality are separate release-hardening scope. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| HTML-01 | Phase 11 | Pending |
| HTML-02 | Phase 11 | Pending |
| HTML-03 | Phase 11 | Pending |
| HTML-04 | Phase 11 | Pending |
| HTML-05 | Phase 11 | Pending |
| AUDIT-01 | Phase 12 | Pending |
| AUDIT-02 | Phase 12 | Pending |
| AUDIT-03 | Phase 12 | Pending |
| HSWIFT-01 | Phase 13 | Pending |
| HSWIFT-02 | Phase 13 | Pending |
| HSWIFT-03 | Phase 13 | Pending |
| ESWIFT-01 | Phase 14 | Pending |
| ESWIFT-02 | Phase 14 | Pending |
| ESWIFT-03 | Phase 14 | Pending |
| VQA-01 | Phase 15 | Pending |
| VQA-02 | Phase 15 | Pending |
| VQA-03 | Phase 15 | Pending |

**Coverage:**
- v1.2 requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0

---
*Requirements defined: 2026-06-24*
*Last updated: 2026-06-24 after v1.2 milestone planning*
