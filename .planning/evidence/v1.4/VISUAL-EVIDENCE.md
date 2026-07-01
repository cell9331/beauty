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

Screenshot capture status: blocked

| Field | Evidence |
| --- | --- |
| Blocking prerequisite | `Demo simulator build: blocked` |
| Build command | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` |
| Destination | `platform=iOS Simulator,name=iPhone 17,OS=26.5` |
| Environment | Xcode `26.6` build `17F113`; Apple Swift `6.3.3`; iPhone 17 iOS 26.5 simulator `8E200128-9A69-462E-9507-047F5AB54FC3`. |
| Failure summary | Build exits `65` while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`; Xcode cannot execute tool `metal` because the Metal Toolchain is missing. |
| Impact | The app cannot be installed or launched for current `simctl io screenshot` capture, so no current v1.4 PNG evidence is created. |
| Rerun protocol | Install the Metal Toolchain with `xcodebuild -downloadComponent MetalToolchain`, rerun the exact build and focused test commands, then run the documented `simctl` boot/install/launch/screenshot sequence. |

## Required states

| State | Required path | Current status |
| --- | --- | --- |
| Home first screen | `.planning/evidence/v1.4/home-first-screen.png` | Not captured; blocked by Demo build prerequisite. |
| Home sticky state | `.planning/evidence/v1.4/home-sticky-state.png` | Not captured; blocked by Demo build prerequisite. |
| Editor beauty/photo tool panel | `.planning/evidence/v1.4/editor-tool-panel.png` | Not captured; blocked by Demo build prerequisite. |

## Per-state review notes

### Home first screen

| Field | Evidence |
| --- | --- |
| Screenshot path | `not captured` |
| Command | Normal launch after successful build/install would use `xcrun simctl launch "$DEVICE_UDID" com.yakang.BeautyDemo`, then `xcrun simctl io "$DEVICE_UDID" screenshot .planning/evidence/v1.4/home-first-screen.png`. |
| Framing | blocked; expected focal point is `Hero camera module and 拍一拍 CTA`. |
| Clipping / overlap | blocked by Metal Toolchain prerequisite; rerun after `xcodebuild -downloadComponent MetalToolchain`. |
| Disabled honesty | blocked for screenshot review; Plan 22-01 route/model scans show unsupported future routes remain inactive. |
| Route scope | blocked for screenshot review; normal launch should stay on current Home first screen with no new product route. |
| Non-claims | no production naturalness claim, no effect quality claim, no physical-device parity claim, no screenshot-diff claim, and no current v1.4 pass evidence from archived screenshots. |

### Home sticky state

| Field | Evidence |
| --- | --- |
| Screenshot path | `not captured` |
| Command | Sticky launch after successful build/install would use `xcrun simctl launch "$DEVICE_UDID" com.yakang.BeautyDemo --beauty-demo-home-sticky`, then `xcrun simctl io "$DEVICE_UDID" screenshot .planning/evidence/v1.4/home-sticky-state.png`. |
| Framing | blocked; expected focal point is `Sticky shortcut rail pinned near the top`. |
| Clipping / overlap | blocked by Metal Toolchain prerequisite; rerun after `xcodebuild -downloadComponent MetalToolchain`. |
| Disabled honesty | blocked for screenshot review; Plan 22-01 route/model scans show disabled future Home tools remain inactive. |
| Route scope | blocked for screenshot review; `--beauty-demo-home-sticky` is launch-only evidence routing and does not add a product route. |
| Non-claims | no production naturalness claim, no effect quality claim, no physical-device parity claim, no screenshot-diff claim, and no current v1.4 pass evidence from archived screenshots. |

### Editor beauty/photo tool panel

| Field | Evidence |
| --- | --- |
| Screenshot path | `not captured` |
| Command | Editor launch after successful build/install would use `xcrun simctl launch "$DEVICE_UDID" com.yakang.BeautyDemo --beauty-demo-route editor-beauty`, then `xcrun simctl io "$DEVICE_UDID" screenshot .planning/evidence/v1.4/editor-tool-panel.png`. |
| Framing | blocked; expected focal point is `White bottom tool panel with selected tool ring, selected category underline, and slider row`. |
| Clipping / overlap | blocked by Metal Toolchain prerequisite; rerun after `xcodebuild -downloadComponent MetalToolchain`. |
| Disabled honesty | blocked for screenshot review; Plan 22-01 route/model scans show unsupported editor tools keep disabled copy, `controlID: nil`, or visible `限免` / `Pro` / `OFF` treatment. |
| Route scope | blocked for screenshot review; `--beauty-demo-route editor-beauty` is the existing required editor evidence route and does not enable new Meitu product areas. |
| Non-claims | no production naturalness claim, no effect quality claim, no physical-device parity claim, no screenshot-diff claim, and no current v1.4 pass evidence from archived screenshots. |

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

## Archived comparison only

`.planning/evidence/v1.1/` and `.planning/evidence/v1.2/` are archived background comparison inputs only. They are not current v1.4 pass evidence and must not be copied or cited as fresh Phase 22 screenshots.

## Physical iPhone manual protocol

Status: `blocked`.

Physical-device camera/Vision parity is outside the required Phase 22 completion path unless actual hardware evidence exists. No physical iPhone evidence was collected in this run. To complete this manually in a later phase, use a real iPhone, run the camera route through the Demo app, record preview/crop/status observations, and keep user photos, raw image bytes, face geometry, raw JSON, local paths, and raw framework errors out of persistent evidence.

## Rerun protocol

Because `Demo simulator build: blocked`, install the missing local Metal Toolchain and rerun the exact commands before claiming current screenshots:

1. Run `xcodebuild -downloadComponent MetalToolchain`.
2. Rerun `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`.
3. Rerun `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests`.
4. If both prerequisite commands pass, continue with Plan 22-02 screenshot capture using the existing `simctl` launch routes.

## Explicit non-claims

- `no production naturalness claim`: Phase 22 does not claim production naturalness passed.
- `no effect quality claim`: Phase 22 does not claim effect quality passed.
- `no physical-device parity claim`: Phase 22 does not claim physical-device camera/Vision parity passed.
- `no screenshot-diff claim`: Phase 22 does not claim screenshot-diff baselines passed.
- Phase 22 does not claim exact commercial Meitu parity, new product routes, hidden network/cloud behavior, public `BeautyParameters` expansion, or current screenshots while the Metal Toolchain blocker remains.
