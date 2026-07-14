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

## Static Boundary and Privacy Scans

| Area | Status | Exact command | Evidence summary | Requirement / debt | Next step |
| --- | --- | --- | --- | --- | --- |
| Demo internal imports | passed | `rg -n 'import Beauty(Core|Detection|Effects|Render|Resources)' BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests || true` | No matches. Demo source and tests remain facade-only from the scan perspective. | AUD-02, SEC-02 | Keep as Phase 25 final security scan. |
| SDK non-UI imports | passed | `rg -n 'SwiftUI|UIKit' BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyEffects 2>/dev/null || true` | No matches. Non-UI SDK targets remain SwiftUI/UIKit-free. | AUD-02, AUD-03 | Keep as architecture/security boundary scan. |
| Active Demo local-first tokens | passed | `rg -n 'URLSession|http://|https://|upload|/private/var|NSError|AVError' BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/Support 2>/dev/null || true` | No matches in active Camera, Editor, and Support input paths. | AUD-02, SEC-02 | Phase 25 should rerun with final privacy/resource review. |
| Public sensitive geometry/raw leakage | passed | `rg -n 'VNFaceObservation|NSError|/private/var|rawPresetJson|image bytes|boundingBox|landmark' BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor 2>/dev/null || true` | No matches. A broader geometry helper scan found only `CGRect` helpers in Demo image extent and a private `CGRect` extension in `BeautyEngine`; no face geometry, raw framework, path, raw JSON, or image-byte leakage was found. | AUD-02, SEC-02 | Keep broad raw-token scans scoped so non-sensitive geometry helpers do not create false failures. |
| Public `BeautyParameters` inventory | passed | `rg -n '^    public var ' BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift && rg '^    public var ' ... | wc -l` | Found 31 public stored fields: skin, color, face-shape, eyes, nose, mouth, lip, `filterId`, and `filterIntensity`. No Phase 21 public parameter expansion occurred. | AUD-03 | Public API remains the existing v1.3/v1.4 baseline. |
| Renderer geometry-case exclusion | passed | `rg -n 'id: "(face|eye|nose|mouth|lip|chin|jaw|proportion|3d|brow)|BeautyParameters\([^)]*(faceSlim|faceSmall|faceVShape|jawSlim|chinLength|eyeSize|eyeDistance|eyeYPosition|eyeTailLift|noseSlim|noseWingSlim|noseTipSize|noseBridge|mouthSize|mouthWidth|smile|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift` | No renderer geometry cases. | AUD-03, RENDER-04 | Geometry output remains routed to future facade geometry work, not Phase 21. |
| Privacy manifest inventory | passed | `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` | No privacy manifest file exists. This confirms TD-005 is still open; Phase 21 does not create a manifest. | AUD-04, TD-005, SEC-01 | Route privacy manifest assessment to Phase 25. |
| Root placeholder scan | passed | `rg -n 'TODO|TBD|FIXME|待定|占位|Lorem' AGENTS.md ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md` | Only historical `PLANS.md` verification prose mentioning prior placeholder/TODO scans was found. No current unresolved placeholder was identified in the root contracts. | AUD-01, AUD-03 | Preserve root-doc scan in final closeout. |

## Planning and Root Consistency

| Area | Status | Evidence summary | Requirement / debt | Next step |
| --- | --- | --- | --- | --- |
| Current milestone scope | passed | `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` describe v1.4 as stability, QA, performance, security, and technical-debt cleanup without product-feature expansion. | AUD-01, AUD-03 | Plan 21-02 should synchronize ledgers after this audit. |
| Requirement mapping | passed | `.planning/REQUIREMENTS.md` defines 24 v1.4 requirements and maps AUD-01 through AUD-04 to Phase 21. Roadmap coverage reports 24 mapped, 0 unmapped. | AUD-01, AUD-04 | Mark AUD-01 through AUD-04 complete only after Plan 21-02 closeout verification. |
| Roadmap state | passed | `gsd-tools query roadmap.analyze` reports Phase 21 has 2 plans, 0 summaries, context/research present, and Phase 22 as next phase. | AUD-01 | Plan 21-02 should update progress after summaries exist. |
| Source edit scope | passed | `git diff --name-only -- BeautySDK BeautyDemo` returned no output during this plan. | AUD-03 | Keep Phase 21 audit-only. |
| Current root scorecard | passed | `QUALITY_SCORE.md` still contains older 2026-06-23 snapshot values and v1.3-era evidence; it also records privacy manifest, performance, long-run, screenshot/UI automation, and visual naturalness gaps. | AUD-01 | Plan 21-02 should refresh only evidence-backed claims from this audit. |

## Stale Codebase Maps

Phase 21 decisions D-11, D-12, and D-13 classify `.planning/codebase/*` as stale for current v1.4 planning. The files were read as required input and not edited.

| Map | Status | Current issue | Disposition |
| --- | --- | --- | --- |
| `.planning/codebase/TESTING.md` | stale | Still says no test runner, no XCTest target, no Swift Package tests, and `BeautySDK/Package.swift` cannot run. Current source has a Swift package and 141 passing SwiftPM XCTest cases. | Do not rely on as current test authority; defer formal remap. |
| `.planning/codebase/CONCERNS.md` | stale | Still says SDK package, Demo integration, tests, and planning files are missing. Current source and planning ledgers contradict that. | Treat as stale-risk record only; current source/root/planning docs win. |
| `.planning/codebase/CONVENTIONS.md` | stale | Contains early naming/style notes from the template-era app. Some naming guidance remains harmless, but it does not reflect current SDK/test structure. | Use only as background; do not override current source. |
| Other maps | stale | `.planning/codebase/ARCHITECTURE.md`, `INTEGRATIONS.md`, `STACK.md`, and `STRUCTURE.md` are from the same early map set. | Record deferred formal remap candidate; do not refresh in Phase 21. |

## Debt Routing Inputs

| Debt | Current status from audit | Phase 21 disposition | Routed next step |
| --- | --- | --- | --- |
| TD-005 Privacy Manifest | Open. `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` returned no manifest. `SECURITY.md` says a distributed SDK target must include `PrivacyInfo.xcprivacy` when SDK behavior or required-reason APIs require it. | Route only; not fixed in Phase 21. | Phase 25 should assess SDK/Demo behavior and Apple required-reason API usage, then add or explicitly defer `PrivacyInfo.xcprivacy`. |
| TD-008 Manual Device QA | Open. Current simulator inventory exists, but no physical iPhone evidence was collected. Demo simulator build/test is also blocked by missing local Metal Toolchain. | Split and block hardware-only evidence where hardware/tooling is missing. | Phase 22 for camera/UI visual simulator evidence after Metal Toolchain repair; Phase 23 for performance/long-run evidence; physical iPhone checks remain blocked until hardware is available. |
| TD-009 Manual Visual QA | Open. Phase 21 did not capture new screenshots or perform human visual smoke/naturalness review. | Route only; not fixed in Phase 21. | Phase 22 should produce deterministic Demo visual/layout evidence under `.planning/evidence/v1.4/`. |
| TD-010 Phase 6 Visual and Hardware QA | Open. Current SDK and renderer evidence passed, but release-like naturalness, production GPU quality, real camera parity, automated screenshot diffing, 720p timing, and long-run memory checks remain unproved. | Split across later v1.4 phases. | Phase 22 visual/layout, Phase 23 performance/long-run, Phase 24 renderer output regression/no-op tolerance, Phase 25 privacy/security closeout. |

## Manual and Hardware Protocols

| Gate | Status | Hardware/tooling assumption | Protocol | Routed next step |
| --- | --- | --- | --- | --- |
| Physical iPhone camera/Vision parity | blocked | No physical iPhone run was performed in Phase 21; current automation used simulator and SwiftPM commands only. | On a physical iPhone, run Demo front-camera preview; confirm mirrored preview and stable processed crop; run no-face, partial-face, and low-light checks; record expected status copy and no crash. | Phase 22 for visual/camera evidence and Phase 23 for long-run/performance evidence. |
| Human visual naturalness | deferred | Automated fixture and renderer evidence does not prove market-grade naturalness. | Capture or inspect fixed Demo/renderer outputs with parameter labels; record factual observations, reviewer, date, inputs, and limitations; do not claim production naturalness without this record. | Phase 22 for Demo screenshots/manual visual smoke; Phase 24 for renderer output regression evidence. |
| Demo simulator screenshot/layout evidence | blocked | Explicit Demo build currently fails before install because local Xcode lacks the Metal Toolchain component. | Install Metal Toolchain, rerun explicit-destination build/test, then capture Home first screen, Home sticky state, and editor tool-panel evidence. | Phase 22. |

## Phase 21 Decision Coverage

- D-01 through D-04: Current command evidence was run where local tooling allowed; unsupported Demo simulator build/test is classified as blocked with exact command, destination, environment, impact, and next step.
- D-05 through D-10: TD-005, TD-008, TD-009, and TD-010 are inventoried and prepared for routing only; no downstream debt was fixed in Plan 21-01.
- D-11 through D-14: Stale `.planning/codebase/*` maps are recorded as stale risk and were not refreshed.
- D-15 through D-18: Hardware/tooling gaps are recorded with reproducible command or hardware assumptions, impact, and next step.

