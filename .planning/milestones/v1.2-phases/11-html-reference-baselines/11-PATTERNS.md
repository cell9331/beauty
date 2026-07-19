# Phase 11 - Pattern Map

**Mapped:** 2026-06-25
**Scope:** Static local HTML baselines for Home and Editor reference surfaces.

## Source Inputs

- `.planning/phases/11-html-reference-baselines/11-CONTEXT.md`
- `.planning/phases/11-html-reference-baselines/11-RESEARCH.md`
- `.planning/REQUIREMENTS.md`
- `.planning/ROADMAP.md`
- `meituxiuxiu/HOME_MAP.md`
- `meituxiuxiu/FUNCTION_MAP.md`
- `BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift`
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift`
- `.planning/evidence/v1.1/VISUAL-EVIDENCE.md`

## Implementation Pattern Map

| New / Changed Area | Closest Existing Analog | Pattern to Preserve |
| --- | --- | --- |
| HTML reference package | `meituxiuxiu/HOME_MAP.md`, `meituxiuxiu/FUNCTION_MAP.md` | Keep reference docs as source-of-truth and create inspectable static pages under `meituxiuxiu/html/`. |
| Home content inventory | `MeituHomeViewState.reference` | Reuse labels, route/static capability map, tool pages, recommendations, and tabs as static HTML content. |
| Editor content inventory | `MeituEditorCategory.all` | Reuse category order, tool labels, badge states, and supported/static distinction as static HTML content. |
| Visual evidence | `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` | Record exact browser/screenshot commands and store v1.2 evidence under `.planning/evidence/v1.2/`. |
| Privacy/offline scan | `InputPipelinePrivacyTests` scan style | Use explicit token scans for network, upload, analytics, remote font/image, and raw screenshot wrapper risks. |
| Future comparison seam | launch-only v1.1 screenshot routes | Give HTML states stable IDs and documented capture targets so Phase 12 can compare repeatably. |

## Planned File Ownership

| Plan | Primary Files | Notes |
| --- | --- | --- |
| `11-01` | `meituxiuxiu/html/README.md`, `meituxiuxiu/html/styles.css`, `.planning/evidence/v1.2/` | Establish package structure, shared CSS tokens, local-only policy, and capture contract. |
| `11-02` | `meituxiuxiu/html/home.html`, `meituxiuxiu/html/styles.css`, `meituxiuxiu/html/README.md` | Build Home first-screen, tool pages, recommendation rails, bottom tabs, and sticky state. |
| `11-03` | `meituxiuxiu/html/editor.html`, `meituxiuxiu/html/styles.css`, `meituxiuxiu/html/README.md` | Build Editor preview chrome and `美型 / 五官` tool panel. |
| `11-04` | `.planning/evidence/v1.2/*`, `meituxiuxiu/html/README.md` | Capture browser screenshots and run offline/static verification. |

## Landmines

- Do not modify `BeautyDemo` SwiftUI or `BeautySDK` in Phase 11.
- Do not use source screenshots as the rendered full-page background.
- Do not add CDN fonts, remote icon libraries, remote images, analytics, forms, upload inputs, or network scripts.
- Do not imply VIP, AI, Pro, video, upload, or membership behavior works; badges are visual/static only.
- Do not claim SwiftUI fidelity improvement before Phase 13 or Phase 14.
- Do not store generated screenshots outside `.planning/evidence/v1.2/`.
