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

