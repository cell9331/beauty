# v1.4 Demo Visual Evidence

## Scope and non-claims

This file records current Phase 22 evidence for `QA-01`, `QA-02`, `QA-03`, and `QA-04`.

Phase 22 covers the current Demo Home first screen, Home sticky state, and editor beauty/photo tool-panel evidence path. It does not redesign Home or Editor, add new product routes, add public `BeautyParameters`, add hidden network/cloud behavior, create screenshot-diff baselines, or claim production naturalness, effect quality, physical-device parity, long-run hardware stability, or exact commercial Meitu parity.

## Environment

| Item | Value |
| --- | --- |
| Evidence run date | `2026-07-01 14:40:45 +0800` |
| Swift | `swift-driver version: 1.148.6 Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)` |
| Swift target | `arm64-apple-macosx26.0` |
| Xcode | `Xcode 26.6`, build `17F113` |
| Required simulator destination | `platform=iOS Simulator,name=iPhone 17,OS=26.5` |
| Resolved iPhone 17 simulator | `8E200128-9A69-462E-9507-047F5AB54FC3` (`Shutdown` during inventory) |
| Project inventory command | `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` |
| Project inventory result | Targets `BeautyDemo`, `BeautyDemoTests`; schemes `BeautyDemo`, `BeautyExampleRenderer`, `BeautySDK`; local `BeautySDK` package resolved. |
| Simulator inventory command | `xcrun simctl list devices available` |
| Simulator inventory result | iOS 26.5 includes `iPhone 17` with UDID `8E200128-9A69-462E-9507-047F5AB54FC3`. |

## Build/test command results

Demo simulator build: blocked

| Field | Evidence |
| --- | --- |
| Command | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` |
| Exit code | `65` |
| Destination | `platform=iOS Simulator,name=iPhone 17,OS=26.5` |
| Failure summary | Build reached `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` and failed because Xcode cannot execute tool `metal` due to the missing Metal Toolchain. |
| Impact | Current v1.4 Demo screenshots cannot be honestly captured or claimed until the local Metal Toolchain is installed and the explicit iPhone 17 build succeeds. |
| Next step | Run `xcodebuild -downloadComponent MetalToolchain`, then rerun the exact build command above. |

## Screenshot inventory or blocker status

No current v1.4 screenshots captured in Plan 22-01.

Screenshot capture pending Plan 22-02. Plan 22-02 may create `.planning/evidence/v1.4/home-first-screen.png`, `.planning/evidence/v1.4/home-sticky-state.png`, and `.planning/evidence/v1.4/editor-tool-panel.png` only after the Demo app builds, installs, launches, and `xcrun simctl io` screenshot commands succeed.

## Required states

| State | Required path | Current status |
| --- | --- | --- |
| Home first screen | `.planning/evidence/v1.4/home-first-screen.png` | Not captured; blocked by Demo build prerequisite. |
| Home sticky state | `.planning/evidence/v1.4/home-sticky-state.png` | Not captured; blocked by Demo build prerequisite. |
| Editor beauty/photo tool panel | `.planning/evidence/v1.4/editor-tool-panel.png` | Not captured; blocked by Demo build prerequisite. |

## Route/model disabled-honesty checks

Demo focused view-state test: blocked

| Field | Evidence |
| --- | --- |
| Requirement coverage | `QA-04`, `D-12`, `D-18` |
| Command | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests` |
| Exit code | `65` |
| Result | Blocked by the same Metal Toolchain build prerequisite while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`; not recorded as a test pass or source failure. |
| Static fallback | Current route/model scans below provide source-backed disabled-honesty evidence until the Metal Toolchain is installed and `BeautyDemoViewStateTests` can run again. |

Static scan command:

```bash
rg -n 'editor-photo|editor-camera|editor-beauty|--beauty-demo-home-sticky|case \.disabled:|return nil' BeautyDemo/BeautyDemo/ContentView.swift
```

Observed lines: `ContentView.swift:57` has `case .disabled:`, `65` and `76` return `nil`, `69` maps `editor-photo`, `71` maps `editor-camera`, `73` maps `editor-beauty`, and `81` checks `--beauty-demo-home-sticky`.

Static scan command:

```bash
rg -n 'route: \.disabled|修视频|拼图|视频美容|AI 修图' BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift
```

Observed lines: `MeituHomeModels.swift:111-142` keeps `修视频`, `拼图`, and `视频美容` on `.disabled`; `147-171` keeps additional future Meitu-style tools on `.disabled`; `216` keeps the `AI 修图` tab inactive.

Static scan command:

```bash
rg -n 'unavailableReason: "v1.1 暂未实现该美图参考功能"|controlID: nil|case free = "限免"|case pro = "Pro"|case off = "OFF"' BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift
```

Observed lines: `MeituEditorToolModels.swift:14-16` defines visible `限免`, `Pro`, and `OFF` badges; `191-192` keeps unsupported editor tools without `controlID` and with `v1.1 暂未实现该美图参考功能`.

Static scan command:

```bash
rg -n 'testV11HomeRoutesOnlySupportedLocalFlows|testV11EditorSupportedToolMappingsAndDisabledHonesty|testDEMO07FutureCategoriesStayVisibleDisabled|testDEMO07FutureSubcategoriesStayVisibleDisabled' BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift
```

Observed lines: `BeautyDemoViewStateTests.swift:30`, `62`, `521`, and `543` retain the route/model tests for local-only routes, editor supported-tool mappings, and future categories/subcategories staying visible and disabled.

Conclusion: unsupported future routes remain inactive; `--beauty-demo-route editor-beauty` remains the required existing editor evidence route; unknown or disabled routes are not recorded as active.
