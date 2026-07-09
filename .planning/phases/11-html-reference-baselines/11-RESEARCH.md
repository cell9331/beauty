---
phase: 11
slug: html-reference-baselines
status: complete
created: 2026-06-25
---

# Phase 11 - Research: HTML Reference Baselines

## RESEARCH COMPLETE

Question: What is needed to plan Phase 11 well?

## Scope Answer

Phase 11 should create local, inspectable HTML/CSS references for the Meitu Home and Editor surfaces. It should not modify SwiftUI, `BeautySDK`, routes, camera/photo behavior, or product claims. The output is an HTML reference package plus browser evidence that later phases can compare against SwiftUI.

## Inputs That Matter

- `meituxiuxiu/HOME_MAP.md` defines the Home first screen, horizontal tool-grid pages, recommendations, bottom tabs, and sticky shortcut state.
- `meituxiuxiu/FUNCTION_MAP.md` defines the editor preview chrome and `美型 / 五官` bottom-panel taxonomy.
- `meituxiuxiu/home/IMG_0871.PNG` through `IMG_0874.PNG` are Home visual references.
- `meituxiuxiu/IMG_0856.PNG` through `IMG_0870.PNG` are Editor visual references.
- `BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift` and `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` already contain deduplicated route/tool/category data that can be mirrored as static HTML content, but Phase 11 should treat the reference maps and screenshots as the visual source of truth.
- `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` records current SwiftUI screenshots and launch routes for later comparison, not as the Phase 11 target.

## Recommended Implementation Shape

Create `meituxiuxiu/html/` with:

- `README.md` - source list, offline policy, viewport/capture instructions, and accepted limitations.
- `styles.css` - shared tokens for phone frame, dark Home surface, white editor panel, badges, rails, tabs, and capture states.
- `home.html` - one deterministic page with sections for first screen, tool pages, recommendations, floating bottom tab, and sticky shortcut capture.
- `editor.html` - one deterministic page for the editor preview chrome, black preview region, white bottom panel, slider, `整体`, `背景保护`, category rails, badges, cancel, and confirm.

Use CSS gradients, geometric placeholders, inline text, and local code instead of full-screen screenshot backgrounds. If small decorative assets are needed, keep them local and document them in `README.md`.

## Validation Architecture

Phase 11 can be verified without building the iOS app:

- Static file checks prove required files exist.
- Offline scans prove no `http://`, `https://`, `@import`, `url(http`, CDN references, analytics, upload forms, or network scripts exist.
- DOM/text scans prove required Chinese labels and reference states exist.
- Browser screenshot capture proves pages render under a documented viewport.
- Optional local `python3 -m http.server` is acceptable for browser capture, but pages must also open by `file://`.

Suggested browser evidence:

- `.planning/evidence/v1.2/home-html-first-screen.png`
- `.planning/evidence/v1.2/home-html-sticky-state.png`
- `.planning/evidence/v1.2/editor-html-tool-panel.png`

Document exact commands, viewport, browser, and any scroll target in `meituxiuxiu/html/README.md`.

## Pattern Notes

- Existing Demo view-state files are useful as content inventory, especially Home tool pages and Editor category/tool lists.
- Do not create a build pipeline or dependency manager for static HTML; plain files keep the reference inspectable and offline.
- Avoid copying commercial images into the rendered HTML as production-like assets. Source screenshots can stay in `meituxiuxiu/` as references and be linked in documentation.
- Use stable element IDs such as `home-first-screen`, `home-sticky-state`, and `editor-tool-panel` so Phase 12 can screenshot or inspect the same states.

## Risks and Mitigations

- Risk: HTML becomes a screenshot wrapper. Mitigation: ban full-screen screenshot backgrounds in the plan and verify DOM labels/classes.
- Risk: External fonts/icons creep in. Mitigation: static scan for network URLs, imports, and script references.
- Risk: Sticky state is hard to capture consistently. Mitigation: provide a deterministic `#home-sticky-state` section or documented scroll position.
- Risk: HTML diverges from current SwiftUI content. Mitigation: mirror labels and taxonomy from `HOME_MAP.md`, `FUNCTION_MAP.md`, and existing Demo model files, then let Phase 12 handle deltas.

## Research Gaps

No blocker. Exact CSS dimensions, colors, and capture mechanics can be chosen during execution as long as the outputs remain local, deterministic, inspectable, and documented.
