# Phase 22: Automated Demo QA and Screenshot Evidence - Research

**Researched:** 2026-07-01
**Status:** Complete
**Question:** What must be known to plan Phase 22 well?

## Research Summary

Phase 22 should stay a narrow QA-evidence phase. The current Demo already has launch-only hooks for the three required states, and the strongest plan is to turn those hooks into repeatable simulator commands plus an evidence README. The plan should not redesign Home or Editor, create a broad screenshot framework, add product routes, add SDK parameters, or claim visual naturalness.

The current local blocker from Phase 21 is still present: the explicit iPhone 17 simulator build reaches `Warp.metal` and fails because the local Xcode Metal Toolchain component is missing. Plans therefore need two paths:

1. Reproduce and record the blocker honestly when the toolchain is still missing.
2. Define exact rerun/build/install/launch/screenshot commands that produce evidence after `xcodebuild -downloadComponent MetalToolchain` repairs the local environment.

## Phase Boundary Findings

- `22-CONTEXT.md` locks required states: Home first screen, Home sticky state, and editor beauty/photo tool panel.
- Required destination is `platform=iOS Simulator,name=iPhone 17,OS=26.5`.
- Existing launch hooks are preferred over new code:
  - `--beauty-demo-home-sticky`
  - `--beauty-demo-route editor-photo`
  - `--beauty-demo-route editor-camera`
  - `--beauty-demo-route editor-beauty`
- Phase 22 may add only minimal launch-only QA hooks if the required evidence cannot be captured deterministically without them.
- Archived v1.1/v1.2 screenshots are background comparison only, not current v1.4 pass evidence.
- Physical iPhone camera/Vision parity, production naturalness, effect quality, screenshot-diff baselines, and broad visual-regression infrastructure remain outside Phase 22.

## Current Local Probe Results

These probes are discovery evidence for planning. Execution plans must rerun relevant commands and record current pass/fail/blocker status in the evidence artifact.

| Probe | Observed result | Planning implication |
| --- | --- | --- |
| `xcodebuild -version` | Xcode 26.6, build `17F113`. | Evidence and blockers should record this environment. |
| `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` | Listed targets `BeautyDemo`, `BeautyDemoTests`; schemes `BeautyDemo`, `BeautyExampleRenderer`, and `BeautySDK`; resolved local `BeautySDK`. | Project discovery works. Build/test proof still requires explicit destination commands. |
| `xcrun simctl list devices available` | Listed iOS 26.5 devices including `iPhone 17`; the iPhone 17 UDID observed during research was `8E200128-9A69-462E-9507-047F5AB54FC3`. | Plans can use destination by name and may record the resolved UDID in evidence. |
| `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` | Exit 65. Build failed compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`: `cannot execute tool 'metal' due to missing Metal Toolchain; use: xcodebuild -downloadComponent MetalToolchain`. | Phase 22 must not claim current screenshot pass evidence until the toolchain is repaired. It can complete blocker evidence if it records exact command, environment, impact, and rerun protocol. |
| `find .planning/evidence -maxdepth 3 -type f` | v1.1 screenshot evidence and v1.2 HTML evidence exist. | Cite only as archived comparison context; v1.4 evidence must live under `.planning/evidence/v1.4/`. |
| `rg -n "PRODUCT_BUNDLE_IDENTIFIER" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | App bundle identifier is `com.yakang.BeautyDemo`. | Simulator launch commands can use `com.yakang.BeautyDemo`. |

## Existing Launch and View-State Surface

`BeautyDemo/BeautyDemo/ContentView.swift` already owns launch-state routing:

- No route argument launches `MeituHomeView`, which is the Home first screen state.
- `--beauty-demo-home-sticky` launches Home with the sticky shortcut preview active and scrolls to the recommendation area.
- `--beauty-demo-route editor-photo` and `--beauty-demo-route editor-beauty` both start `EditorShellView` in photo mode; `editor-beauty` is the closest required editor beauty/photo tool-panel route.
- `--beauty-demo-route editor-camera` starts camera mode, but permission/session behavior can make it less reliable and optional for Phase 22.

`BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift` encodes enabled and disabled Home routes. `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift` renders:

- Meitu-style Hero with `复古胶片相机` and `拍一拍`.
- Supported primary actions for photo, camera, and portrait beauty.
- Disabled/static future tool grid entries and inactive bottom tabs.
- Sticky shortcut rail when `initialStickyPreview` is true.

`BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` and `MeituEditorToolPanelView.swift` encode the editor panel:

- Category order `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`.
- Supported tools mapped to current `BeautyControlID` values.
- Unsupported tools remain visible with `限免`, `Pro`, `OFF`, or `v1.1 暂未实现该美图参考功能` honesty.
- Bottom cancel/confirm actions and the slider row are fixed inside the panel.

`BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` already covers the route/model truth needed by QA-04:

- Home hierarchy and supported/disabled route mapping.
- Launch argument parsing for `--beauty-demo-route editor-beauty`.
- `--beauty-demo-home-sticky` parsing.
- Editor taxonomy order.
- Supported tool mappings and unsupported-tool honesty.
- Slider writes only for supported tools.

Phase 22 can reuse these tests and add narrow tests only if planning identifies a specific QA-04 gap.

## Screenshot Capture Architecture

The simplest repeatable path after the Metal Toolchain is repaired is:

1. Build or test with explicit simulator destination.
2. Boot the required simulator.
3. Install the built app.
4. Launch with the required launch arguments.
5. Wait briefly for SwiftUI layout and scroll hooks.
6. Capture screenshots with `xcrun simctl io <device> screenshot <path>`.
7. Terminate the app between states.
8. Write `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` with exact commands, output paths, simulator framing, and factual review notes.

Recommended screenshot files:

- `.planning/evidence/v1.4/home-first-screen.png`
- `.planning/evidence/v1.4/home-sticky-state.png`
- `.planning/evidence/v1.4/editor-tool-panel.png`
- Optional: `.planning/evidence/v1.4/editor-camera-route.png` only if cheap and reliable.

Recommended review-note checks for each required screenshot:

- Controls, labels, badges, and panels do not visibly clip or overlap.
- Required state is actually shown: first Home, sticky Home, or editor beauty/photo panel.
- Disabled/future areas are visibly inactive and not represented as working.
- Route scope is factual and narrow; no product naturalness, hardware parity, or production quality claim is made.
- If screenshot capture cannot run, the blocker note includes exact command, destination, environment, failure summary, impact, and next step.

## Evidence README Shape

The Phase 22 evidence artifact should be a Markdown file under `.planning/evidence/v1.4/`, most likely `VISUAL-EVIDENCE.md`.

Recommended sections:

1. Scope and non-claims.
2. Environment: date, Xcode version, selected destination, resolved simulator UDID if used.
3. Build/test command results.
4. Screenshot command log or blocker record.
5. Screenshot inventory table.
6. Per-state review notes.
7. Disabled-honesty and route-scope checks.
8. Physical-device manual protocol and blocker status.
9. Rerun protocol.

When Metal Toolchain is still missing, the file should explicitly say current v1.4 screenshots were not captured and list the rerun steps. That is acceptable Phase 22 evidence only if all blocker metadata is present and no screenshot pass claim is made.

## Minimal Code-Change Options

No Swift code change is required to plan the baseline path. Potential small changes are conditional:

| Need | Minimal option | Avoid |
| --- | --- | --- |
| Screenshot state is not deterministic after build repair. | Add one launch-only QA argument near `ContentView.initialRouteTarget` / `initialHomeStickyPreview`. | A general UI automation framework. |
| QA-04 route scope lacks test coverage. | Add focused `BeautyDemoViewStateTests` assertions around disabled routes or launch arguments. | Pixel-perfect UI assertions. |
| Evidence capture command is repeated manually. | Add a tiny shell script under a planning or tooling path only if it remains simple and evidence-local. | A long-lived screenshot framework or broad snapshot baseline system. |

## Validation Architecture

Phase 22 validation should sample both automated truth and evidence completeness:

- Build/test gate: `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`; if it fails on missing Metal Toolchain, record blocker evidence and skip false screenshot claims.
- Demo route/model tests: focused `xcodebuild ... test` for `BeautyDemoViewStateTests` when the build prerequisite passes.
- Simulator screenshot gate: `xcrun simctl boot`, `xcrun simctl install`, `xcrun simctl launch`, and `xcrun simctl io ... screenshot` for the three required states when the built app exists.
- Evidence artifact gate: scan `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` for exact filenames, required state labels, destination, command strings, blocker strings when applicable, and non-claim language.
- Static honesty gate: rerun the existing route/model tests or narrow scans to prove unsupported future routes remain disabled.
- Manual-only gate: physical iPhone camera/Vision parity stays blocked unless actual hardware evidence is recorded.

## Planning Recommendation

Create two plans:

1. `22-01`: Demo build/test blocker or capture prerequisite sweep plus view-state route honesty checks. Produces the initial `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` shell with command evidence and blocker/pass status.
2. `22-02`: Simulator screenshot capture and factual review notes. Depends on `22-01`; it either captures the three required screenshots after the Metal Toolchain is repaired or records the exact blocker/rerun protocol without claiming screenshot pass evidence.

If the UI safety gate requires `22-UI-SPEC.md`, run `$gsd-ui-phase 22` before creating the executable plans. The UI-SPEC should be a QA/evidence contract, not a redesign contract.

## Research Complete

The planner should use:

- `.planning/phases/22-automated-demo-qa-and-screenshot-evidence/22-CONTEXT.md`
- this `22-RESEARCH.md`
- `FRONTEND.md`, `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md`
- current Home/Editor Demo files and `BeautyDemoViewStateTests`
- Phase 21 `21-BASELINE-AUDIT.md` blocker evidence

Plans must keep Phase 22 evidence-first and conservative.
