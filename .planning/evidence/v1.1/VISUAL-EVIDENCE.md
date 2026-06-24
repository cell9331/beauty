# v1.1 Meitu UI Visual Evidence

**Captured:** 2026-06-24
**Simulator:** iPhone 17, iOS 26.5
**App:** `com.yakang.BeautyDemo`

## Screenshots

| File | Coverage |
| --- | --- |
| `home-first-screen.png` | Home first screen: dark background, retro film hero, search/brand/VIP chrome, `拍一拍`, primary action cards, paged tool grid, recommendations, floating bottom tab. |
| `home-sticky-state.png` | Home scrolled state: sticky shortcut rail, recommendation sections moved upward, bottom tab fixed. Captured with `--beauty-demo-home-sticky` because this environment does not allow Simulator gesture automation through Accessibility. |
| `editor-tool-panel.png` | Editor tool panel: black preview area, centered brand capsule, white bottom panel, background protection toggle, shared slider, `整体`, second-level tool rail, first-level category rail, cancel/confirm controls. Captured with `--beauty-demo-route editor-beauty`. |

## Commands

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj \
  -scheme BeautyDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl launch <simulator-id> com.yakang.BeautyDemo

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl launch <simulator-id> com.yakang.BeautyDemo --beauty-demo-home-sticky

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl launch <simulator-id> com.yakang.BeautyDemo --beauty-demo-route editor-beauty
```

## Notes

- XcodeBuildMCP simulator listing failed in this environment because its tool PATH could not find `simctl`; shell verification used the same explicit `DEVELOPER_DIR` path as prior milestone verification.
- `--beauty-demo-home-sticky` and `--beauty-demo-route` are launch-only verification routes. Normal launch still starts at the Home screen.
