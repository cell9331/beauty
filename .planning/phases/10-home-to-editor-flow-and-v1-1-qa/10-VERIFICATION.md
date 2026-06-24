---
phase: 10-home-to-editor-flow-and-v1-1-qa
verified: 2026-06-24
status: verified
requirements: [FLOW-01, FLOW-02, FLOW-03, FLOW-04, FLOW-05, FLOW-06]
---

# Phase 10: Home-to-Editor Flow and v1.1 QA Verification

**Goal:** Connect Home actions to existing camera/photo/editor processing paths and close v1.1 verification without overclaiming unsupported reference features.

## Evidence

| Requirement | Status | Evidence |
| --- | --- | --- |
| FLOW-01 | Verified | `ContentView.routeTarget(for: .photoEditor)` opens `EditorShellView(initialMode: .photo)` and preserves the existing photo pipeline. |
| FLOW-02 | Verified | `ContentView.routeTarget(for: .cameraEditor)` opens `EditorShellView(initialMode: .camera)`; `拍一拍` uses the same local camera route. |
| FLOW-03 | Verified | `ContentView.routeTarget(for: .beautyEditor)` opens the editor with the Meitu beauty panel and public `BeautySDK` parameter model. |
| FLOW-04 | Verified | Unsupported Home actions return `.disabled` and no route target; unsupported editor tools are disabled/static with unavailable copy. |
| FLOW-05 | Verified | `BeautyDemoViewStateTests` covers Home hierarchy, routes, editor taxonomy, supported mapping, disabled honesty, launch-only arguments, and cancel restore; facade import scan returned no matches. |
| FLOW-06 | Verified | Screenshot-backed evidence exists for Home first screen, Home sticky state, and editor tool panel in `.planning/evidence/v1.1/`. |

## Commands

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test`
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK`
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests`

## Visual Evidence

- `.planning/evidence/v1.1/home-first-screen.png`
- `.planning/evidence/v1.1/home-sticky-state.png`
- `.planning/evidence/v1.1/editor-tool-panel.png`
- `.planning/evidence/v1.1/VISUAL-EVIDENCE.md`

## Notes

- `--beauty-demo-route` and `--beauty-demo-home-sticky` are launch-only verification hooks.
- XcodeBuildMCP simulator listing could not find `simctl` in its tool PATH, so screenshot capture used shell `xcrun simctl` with explicit `DEVELOPER_DIR`.
- Full `图库`, `AI 修图`, `我`, AI generation, video editing, and new SDK algorithm families remain future milestone scope.
