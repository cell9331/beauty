# v1.2 HTML Reference Visual Evidence

**Captured:** 2026-06-25
**Browser/tool:** Playwright CLI with Chromium
**Viewport:** 390x844 CSS pixels
**Source:** local `file://` HTML pages under `meituxiuxiu/html/`

## Screenshots

| File | Coverage |
| --- | --- |
| `home-html-first-screen.png` | Home first screen with hero, search/brand/VIP chrome, `拍一拍`, primary action cards, first tool grid, recommendation rail, and bottom tabs. |
| `home-html-sticky-state.png` | Home scrolled/sticky state with shortcut rail, recommendation sections, and fixed bottom tabs. |
| `editor-html-tool-panel.png` | Editor preview chrome and white bottom panel with `背景保护`, compare, slider, `整体`, second-level tool rail, category rail, badges, cancel, and confirm. |

## Commands

```bash
ROOT=$(pwd)
npx --yes playwright screenshot --viewport-size=390,844 --wait-for-selector '#home-first-screen' "file://$ROOT/meituxiuxiu/html/home.html#home-first-screen" .planning/evidence/v1.2/home-html-first-screen.png
npx --yes playwright screenshot --viewport-size=390,844 --wait-for-selector '#home-sticky-state' "file://$ROOT/meituxiuxiu/html/home.html#home-sticky-state" .planning/evidence/v1.2/home-html-sticky-state.png
npx --yes playwright screenshot --viewport-size=390,844 --wait-for-selector '#editor-tool-panel' "file://$ROOT/meituxiuxiu/html/editor.html#editor-tool-panel" .planning/evidence/v1.2/editor-html-tool-panel.png
```

## Static Verification

```bash
test -f meituxiuxiu/html/home.html
test -f meituxiuxiu/html/editor.html
test -f meituxiuxiu/html/styles.css
node meituxiuxiu/html/offline-check.mjs
```

Result: offline policy scan passed.

## Screenshot File Checks

All three screenshots are non-empty PNG files at 390x844:

- `.planning/evidence/v1.2/home-html-first-screen.png`
- `.planning/evidence/v1.2/home-html-sticky-state.png`
- `.planning/evidence/v1.2/editor-html-tool-panel.png`

## Accepted Gaps

- The HTML pages use CSS-drawn placeholders instead of copying commercial image assets.
- The Home and Editor pages are static capture references, not functional web prototypes.
- SwiftUI comparison and delta reporting are deferred to Phase 12.
