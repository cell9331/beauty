# Phase 11: HTML Reference Baselines - Context

**Gathered:** 2026-06-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 11 delivers local, static HTML reference baselines for the two Meitu reference surfaces before any SwiftUI visual tuning happens. The outputs are `meituxiuxiu/html/home.html`, `meituxiuxiu/html/editor.html`, and supporting local documentation/assets/CSS needed to open and screenshot them offline.

This phase does not change `BeautyDemo` SwiftUI implementation, SDK behavior, routes, image processing, permissions, or product capability claims. SwiftUI optimization starts only after Phase 12 writes the HTML-to-SwiftUI delta contract.

</domain>

<decisions>
## Implementation Decisions

### HTML Reconstruction Policy
- **D-01:** Build reconstructed HTML/CSS reference pages, not pages that simply use the source screenshots as full-screen backgrounds.
- **D-02:** Source screenshots may be referenced in `README.md` or comparison evidence, but the actual reference UI should be inspectable DOM/CSS with local-only assets.
- **D-03:** Prefer shared CSS tokens for colors, spacing, radii, typography scale, rails, badges, and phone viewport framing so Phase 12 can map measurements into SwiftUI.

### Home Baseline
- **D-04:** `home.html` must cover the Home first screen from `meituxiuxiu/home/IMG_0871.PNG`, the horizontal tool-grid pages represented by `IMG_0872.PNG` and `IMG_0873.PNG`, and the scrolled sticky shortcut state from `IMG_0874.PNG`.
- **D-05:** The Home baseline should preserve the reference hierarchy: black content flow, green/black retro film hero, search/brand/VIP chrome, orange `拍一拍` CTA, brown primary action cards, paged tool grid, recommendation rails, floating bottom tab, and sticky shortcut rail.
- **D-06:** The sticky state should be deterministic for screenshot capture. A normal scrollable page is acceptable, but the implementation should provide a clear capture target or documented scroll position for the sticky screenshot.

### Editor Baseline
- **D-07:** `editor.html` must cover the editor framework from `meituxiuxiu/IMG_0856.PNG` through `IMG_0870.PNG`: black top chrome, full preview region, `背景保护`, compare/preview affordance, white bottom panel, slider, `整体`, second-level tool rail, first-level category rail, badges, cancel, and confirm.
- **D-08:** The editor category taxonomy comes from `meituxiuxiu/FUNCTION_MAP.md`: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`. The HTML may show a default selected category plus enough rail content to represent horizontal overflow.
- **D-09:** `限免`, `Pro`, and `OFF` are visual badges only in Phase 11. No membership, AI, upload, or server behavior should be implied.

### Offline and Evidence
- **D-10:** HTML references must be deterministic and offline: no remote fonts, remote images, analytics, upload forms, CDN scripts, or hidden service calls.
- **D-11:** Browser evidence should be captured under `.planning/evidence/v1.2/` for Home first screen, Home sticky state, and Editor tool panel.
- **D-12:** The screenshot viewport should be documented and kept consistent for Phase 12 when comparing HTML against current SwiftUI evidence.

### the agent's Discretion
The agent may choose exact CSS implementation details, file split, and capture mechanics as long as the pages remain local, inspectable, deterministic, and aligned to the Meitu reference maps. Reasonable supporting files include `meituxiuxiu/html/styles.css`, local placeholder assets, and `meituxiuxiu/html/README.md`.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and Phase Contracts
- `.planning/PROJECT.md` — Defines v1.2 as an HTML-reference-first fidelity milestone and preserves the SDK-first product boundary.
- `.planning/REQUIREMENTS.md` — Defines HTML-01 through HTML-05 for Phase 11 and the downstream AUDIT/SwiftUI requirements.
- `.planning/ROADMAP.md` — Defines Phase 11 plan sequence 11-01 through 11-04 and its dependency on v1.1 evidence.
- `PLANS.md` — Tracks the active v1.2 work ledger and repository-level verification expectations.

### Meitu Reference Inputs
- `meituxiuxiu/HOME_MAP.md` — Owns the Home reference structure, page states, sticky behavior, and 1:1 restoration notes.
- `meituxiuxiu/FUNCTION_MAP.md` — Owns the editor `美型 / 五官` taxonomy, panel structure, badges, and de-duplicated function list.
- `meituxiuxiu/home/IMG_0871.PNG` — Home first-screen primary reference.
- `meituxiuxiu/home/IMG_0872.PNG` — Home tool-grid page 2 reference.
- `meituxiuxiu/home/IMG_0873.PNG` — Home tool-grid page 3 reference.
- `meituxiuxiu/home/IMG_0874.PNG` — Home scrolled sticky-state reference.
- `meituxiuxiu/IMG_0856.PNG` through `meituxiuxiu/IMG_0870.PNG` — Editor category and horizontal rail references.

### Existing SwiftUI and Evidence
- `BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift` — Current Home data model and route/static capability map.
- `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift` — Current SwiftUI Home implementation that later phases will compare against HTML.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` — Current editor category/tool taxonomy and supported/unsupported mapping.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` — Current SwiftUI editor bottom panel implementation.
- `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` — Current SwiftUI screenshot evidence and launch routes for comparison.

### Codebase Contracts
- `FRONTEND.md` — Owns SwiftUI Demo behavior and app-side state; Phase 11 should not change this unless documenting the HTML-first workflow.
- `PRODUCT_SENSE.md` — Owns acceptance criteria and user-facing behavior claims.
- `QUALITY_SCORE.md` — Owns quality evidence and recurring scans.
- `.planning/codebase/CONVENTIONS.md` — Naming, import, and documentation conventions.
- `.planning/codebase/STRUCTURE.md` — Repository paths and where new UI/planning artifacts belong.
- `.planning/codebase/STACK.md` — Toolchain and explicit simulator destination constraints.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MeituHomeViewState.reference`: already captures the Home text, primary actions, tool pages, recommendation sections, and tabs that can inform HTML content structure.
- `MeituEditorCategory.all`: already captures the de-duplicated editor category/tool taxonomy and supported/unsupported status that can inform editor HTML rails.
- `.planning/evidence/v1.1/*.png`: existing SwiftUI screenshots provide the later comparison target, not the Phase 11 visual source of truth.

### Established Patterns
- Demo capabilities must stay honest: unsupported Meitu-like features are disabled/static, not fake working flows.
- Demo imports must stay behind the public `BeautySDK` facade. Phase 11 does not touch Swift import boundaries.
- Xcode visual evidence uses explicit simulator destinations and launch-only verification flags; HTML evidence should similarly record exact commands/viewport.

### Integration Points
- `meituxiuxiu/html/README.md` should explain how to open/capture `home.html` and `editor.html`, list source screenshots, and document the offline policy.
- `.planning/evidence/v1.2/` should receive the HTML baseline screenshots required by HTML-05.
- Phase 12 should read the HTML files and evidence before writing any SwiftUI delta report.

</code_context>

<specifics>
## Specific Ideas

- The user explicitly corrected the workflow: convert the two Meitu pages to HTML first, then reference that HTML to optimize SwiftUI.
- The Home HTML should model both visible Home states, not just one static first screen.
- The editor HTML should focus on the `美型 / 五官` tool panel, not unrelated modules such as filters, stickers, export, VIP, AI processing, or gallery tabs.
- HTML should be useful as a measurement artifact: token names and DOM sections should make it practical to compare layout and spacing in Phase 12.

</specifics>

<deferred>
## Deferred Ideas

- SwiftUI Home fidelity fixes are deferred to Phase 13.
- SwiftUI editor panel fidelity fixes are deferred to Phase 14.
- Pixel/perceptual diff automation beyond captured evidence is deferred to Phase 15 or a future Automated Visual QA milestone.
- Full Meitu feature parity, membership logic, AI/network tools, video editing, export/share flows, and production commercial assets remain out of scope.

</deferred>

---

*Phase: 11-HTML Reference Baselines*
*Context gathered: 2026-06-25*
