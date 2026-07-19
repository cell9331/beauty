---
phase: 08-meitu-home-rebuild
verified: 2026-06-24
status: verified
requirements: [HOME-01, HOME-02, HOME-03, HOME-04, HOME-05, HOME-06]
---

# Phase 8: Meitu Home Rebuild Verification

**Goal:** Replace the Demo first screen with a Meitu Xiuxiu-style Home matching `meituxiuxiu/HOME_MAP.md`.

## Evidence

| Requirement | Status | Evidence |
| --- | --- | --- |
| HOME-01 | Verified | `MeituHomeView` is the first screen through `ContentView`; visual screenshot `home-first-screen.png` shows dark Home, film hero, search/brand/VIP chrome, `拍一拍`, and no SDK-dashboard copy. |
| HOME-02 | Verified | `MeituHomeViewState.reference.primaryActions` preserves `图片美化`, `修视频`, `人像美容`, `拼图`, `相机`, `视频美容` hierarchy; `BeautyDemoViewStateTests.testV11HomeViewStateMatchesMeituReferenceHierarchy` passed. |
| HOME-03 | Verified | Home data contains three tool pages with [8, 12, 1] items and a visible page indicator; view-state test passed. |
| HOME-04 | Verified | Recommendation rails include `欧美闪光滤镜`, `不能错过热门玩法`, `欧美曲线塑形`, and `欧美美容常态`; view-state test passed. |
| HOME-05 | Verified | Floating bottom tab model exposes `首页`, `图库`, `AI 修图`, `我`; `首页` is selected and `我` shows the dot; view-state test passed. |
| HOME-06 | Verified | Sticky shortcut rail is implemented and captured in `.planning/evidence/v1.1/home-sticky-state.png` through the launch-only `--beauty-demo-home-sticky` route. |

## Commands

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test`

## Notes

- Home uses SwiftUI-drawn visuals, SF Symbols, and local gradient/card placeholders rather than copying commercial Meitu assets.
- Unsupported Home actions remain disabled/static and are verified in Phase 10.
