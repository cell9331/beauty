---
phase: 21-baseline-audit-and-quality-ledger-refresh
status: draft
updated: 2026-06-30
requirements:
  - AUD-01
  - AUD-02
  - AUD-03
  - AUD-04
---

# Phase 21 Baseline Audit

## Scope

This artifact records the current v1.4 quality, verification, and technical-debt baseline before implementation changes. It distinguishes current command evidence from archived v1.3 evidence, local tooling blockers, not-attempted checks, and later-phase deferred work.

Phase 21 does not add Swift source, public `BeautyParameters`, SwiftUI routes, renderer cases, privacy manifests, network/cloud behavior, broad UI redesign, or refreshed `.planning/codebase/*` maps.

Status values:

- `passed`: command or scan ran now and passed.
- `failed`: command ran now and failed because of repo code, tests, or docs.
- `blocked`: command could not produce meaningful repo evidence because local tooling or hardware is missing.
- `not attempted`: intentionally not run in Phase 21.
- `deferred`: check belongs to a later v1.4 phase.
- `archived`: prior phase evidence cited as history, not current proof.

## Environment and Command Inventory

| Area | Status | Exact command | Evidence summary | Requirement / debt | Next step |
| --- | --- | --- | --- | --- | --- |
| Swift toolchain | passed | `swift --version` | Apple Swift 6.3.3, swift-driver 1.148.6, target `arm64-apple-macosx26.0`. | AUD-02 | Use current SwiftPM evidence for SDK commands. |
| Xcode toolchain | passed | `xcodebuild -version` | Xcode 26.6, build 17F113. | AUD-02 | Include this environment in Demo simulator blockers. |
| SDK test inventory | passed | `swift test --package-path BeautySDK --list-tests` | Succeeded and listed 141 XCTest entries. Command emitted the expected deprecation warning for `--list-tests`; full test command was run separately in the SDK baseline. | AUD-02 | Prefer full `swift test --package-path BeautySDK` for pass/fail evidence. |
| Xcode project inventory | passed | `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` | Resolved local `BeautySDK` package; listed targets `BeautyDemo`, `BeautyDemoTests`; listed schemes `BeautyDemo`, `BeautyExampleRenderer`, `BeautySDK`. | AUD-02 | Project/scheme discovery is available, but this alone is not Demo build/test proof. |
| Simulator inventory | passed | `xcrun simctl list devices available` | Listed iOS 26.5 simulator devices including `iPhone 17`, `iPhone 17 Pro`, `iPhone 17 Pro Max`, iPads, and watchOS devices. No CoreSimulator version mismatch appeared in this run. | AUD-02 | Explicit iOS Simulator destinations can be selected for Demo commands. |
| Demo simulator build | blocked | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` | Command selected an explicit iPhone 17 / iOS 26.5 simulator and reached target build. It failed while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`: `cannot execute tool 'metal' due to missing Metal Toolchain; use: xcodebuild -downloadComponent MetalToolchain`. | AUD-02, TD-008 | Install the Xcode Metal Toolchain component, then rerun explicit-destination Demo build and test in Phase 22 or during local toolchain repair. |
| Demo simulator tests | blocked | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` | Not run after the explicit build failed on the missing local Metal Toolchain. Treating tests as blocked avoids reporting duplicate build prerequisite failure as test evidence. | AUD-02, TD-008, TD-009 | After Metal Toolchain is installed, rerun explicit-destination Demo tests and screenshot/layout checks in Phase 22. |

### Tooling Blocker Detail

Blocked gate: Demo simulator build/test evidence.

- Command attempted: `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`
- Selected destination: iPhone 17, iOS 26.5 simulator.
- Environment: Xcode 26.6 build 17F113; Swift 6.3.3.
- Failure summary: `metal` tool could not execute because the local Xcode Metal Toolchain component is missing.
- Impact: Phase 21 cannot claim current Demo simulator build/test pass. SwiftPM SDK and renderer command evidence remain meaningful because they passed through SwiftPM.
- Next step: run `xcodebuild -downloadComponent MetalToolchain` outside Phase 21 audit scope, then rerun Demo build/test in Phase 22 screenshot/QA work.

## SDK and Renderer Baseline

| Area | Status | Exact command | Evidence summary | Requirement / debt | Next step |
| --- | --- | --- | --- | --- | --- |
| Full SDK tests | passed | `swift test --package-path BeautySDK` | Built successfully and executed 141 XCTest cases with 0 failures and 0 unexpected failures. The Swift Testing runner then reported 0 tests in 0 suites, also passed. | AUD-02 | Use as current SDK automated baseline. |
| Renderer build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully for debugging. | AUD-02, RENDER-01 | Phase 24 can promote renderer evidence into regression gates. |
| Renderer all-cases run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 45 PNG outputs: 5 input fixtures times 9 current renderer cases. | AUD-02, RENDER-01, RENDER-03 | Keep generated PNGs local/ignored; Phase 24 should add tolerance/regression checks. |
| Input fixture count | passed | `find example-images/input -maxdepth 1 -type f | sort` | Found `e1.png`, `e2.png`, `e3.png`, `e4.png`, and `e5.png`. | AUD-02 | Fixture set is current baseline input set. |
| Output count | passed | `find example-images/out -maxdepth 1 -type f -name '*.png' | wc -l` | Counted 45 generated PNG outputs. | AUD-02, RENDER-03 | Matches current 5 x 9 renderer matrix. |
| Ignored-output policy | passed | `git check-ignore example-images/out/e1__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e5__skinCombo_0p50.png` | Representative outputs are ignored by git. `git status --short -- example-images/out` returned no tracked/untracked output. | AUD-02 | Do not commit generated renderer PNGs. |
| Non-empty output check | passed | `find example-images/out -maxdepth 1 -type f -name '*.png' -size 0 -print` | Returned no zero-byte PNG files. | AUD-02, RENDER-03 | Phase 24 should convert this into a repeatable all-output gate. |
| Representative dimensions | passed | `sips -g pixelWidth -g pixelHeight <input/output files>` | `e1` input and `e1__skinSmoothing_0p50` both 1728 x 2304; `e2` input and `e2__skinWhitening_0p50` both 576 x 1024; `e5` input and `e5__skinCombo_0p50` both 1440 x 2560. | AUD-02, RENDER-03 | Phase 24 should check all output dimensions and no-op tolerance. |
| Archived Phase 20 renderer evidence | archived | `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` | Phase 20 also recorded 141 SDK tests, renderer build/run, 45 ignored outputs, non-empty files, all-output dimension checks, and visual notes. This is historical support, not a substitute for the current Phase 21 run above. | AUD-01, AUD-02 | Keep archived evidence separate from current evidence. |

Current renderer case IDs from `BeautySDK/Sources/BeautyExampleRenderer/main.swift`:

| Case ID | Status | Notes |
| --- | --- | --- |
| `skinSmoothing_0p50` | passed | Current skin case. |
| `skinWhitening_0p50` | passed | Current skin case. |
| `skinRosy_0p40` | passed | Current skin case. |
| `skinSharpen_0p40` | passed | Current skin case. |
| `brightness_plus0p25` | passed | Current color case. |
| `contrast_plus0p25` | passed | Current color case. |
| `filter_softClean_0p50` | passed | Current metadata filter case. |
| `filter_warmLight_0p50` | passed | Current metadata filter case. |
| `skinCombo_0p50` | passed | Current combined skin case. |

Renderer scope notes:

- Current output evidence is for public-facade skin, color, and filter saved-image cases only.
- The renderer does not contain geometry-heavy saved-image cases for face, eye, nose, mouth, lip, chin, jaw, proportion, 3D sculpt, or brow branches.
- Geometry-heavy branches remain `partial`, `blocked-by-geometry-output`, or `future` until public facade detection plus geometry rendering can produce same-dimension, watermarked saved outputs.

