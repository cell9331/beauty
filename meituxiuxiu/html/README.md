# Meitu HTML Reference Baselines

Phase 11 creates local static HTML references before any SwiftUI tuning.

## Files

- `home.html` - Home reference for first screen, tool-grid pages, recommendation rails, bottom tabs, and sticky shortcut state.
- `editor.html` - Editor reference for preview chrome and the `美型 / 五官` bottom tool panel.
- `styles.css` - Shared visual tokens and component styles.

## Source References

Home sources:

- `meituxiuxiu/HOME_MAP.md`
- `meituxiuxiu/home/IMG_0871.PNG`
- `meituxiuxiu/home/IMG_0872.PNG`
- `meituxiuxiu/home/IMG_0873.PNG`
- `meituxiuxiu/home/IMG_0874.PNG`

Editor sources:

- `meituxiuxiu/FUNCTION_MAP.md`
- `meituxiuxiu/IMG_0856.PNG` through `meituxiuxiu/IMG_0870.PNG`

The rendered pages are reconstructed, inspectable DOM/CSS references. Do not use the source screenshots as full-screen screenshot backgrounds. Source PNGs are comparison inputs only.

## Offline Policy

The HTML references must stay deterministic and local:

- No remote fonts.
- No remote images.
- No CDN scripts.
- No tracking beacons.
- No send-file forms.
- No hidden runtime services.
- No network calls.

Badges such as `限免`, `Pro`, and `OFF` are static visual states only. They do not imply entitlement, AI, file transfer, payment, or service behavior. In Chinese: `限免` / `Pro` / `OFF` 徽标只是静态视觉状态，不代表会员、AI、文件传输、付费或服务能力已经实现。

## Viewport and Evidence

Use a `390x844` CSS-pixel viewport unless the local browser requires an equivalent documented size.

Evidence output directory:

- `.planning/evidence/v1.2/`

Expected screenshots:

- `.planning/evidence/v1.2/home-html-first-screen.png`
- `.planning/evidence/v1.2/home-html-sticky-state.png`
- `.planning/evidence/v1.2/editor-html-tool-panel.png`

Capture targets:

- Home first screen: `home.html#home-first-screen`
- Home sticky state: `home.html#home-sticky-state`
- Editor tool panel: `editor.html#editor-tool-panel`

## Repeatable Capture Commands

The exact command used during execution should be recorded here and in `.planning/evidence/v1.2/VISUAL-EVIDENCE.md`.

Commands used during Phase 11 execution:

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
rg -n "复古胶片相机|拍一拍|图片美化|智能抠图|欧美闪光滤镜|home-sticky-state" meituxiuxiu/html/home.html meituxiuxiu/html/styles.css
rg -n "背景保护|整体|3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛|限免|Pro|OFF" meituxiuxiu/html/editor.html meituxiuxiu/html/styles.css
node meituxiuxiu/html/offline-check.mjs
```

## Accepted Limits

- These pages recreate structure, hierarchy, spacing, and state vocabulary; they do not copy commercial production assets.
- CSS-drawn image cards and portrait placeholders stand in for commercial photos.
- Home and editor interactions are static capture states in Phase 11. SwiftUI behavior remains unchanged until later phases.
