---
phase: 02
slug: demo-integration-shell
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-11
audited: 2026-06-23
---

# Phase 02 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Xcode for Demo tests; XCTest via Swift Package Manager for SDK health |
| **Config file** | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautySDK/Package.swift` |
| **Quick run command** | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` |
| **Full suite command** | `swift test --package-path BeautySDK` plus Demo build/test and static scans listed below |
| **Estimated runtime** | ~120 seconds after the Demo test target exists |

Full suite commands:

```bash
swift test --package-path BeautySDK
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test
rg -n "import BeautyCore|import BeautyDetection|import BeautyRender|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests
rg -n "Hello, world!" BeautyDemo/BeautyDemo
```

The internal-import scan and `Hello, world!` scan must return no matches.

---

## Sampling Rate

- **After every task commit:** Run the Demo build command once package wiring exists; run targeted view-state tests once `BeautyDemoTests` exists.
- **After every plan wave:** Run the full suite command above.
- **Before `$gsd-verify-work`:** Full suite must be green or exact environment failures must be recorded.
- **Max feedback latency:** 120 seconds for build/test feedback after infrastructure exists.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 02-01 | 1 | SDK-08 | T-02-01 / N/A | Demo imports the public facade only and does not gain internal SDK target imports. | build + static | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` plus internal-import scan | yes | green |
| 02-01-02 | 02-01 | 1 | DEMO-08 | T-02-02 / N/A | Demo view-state tests can run without camera/photo/private media access. | xcode test | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` | yes | green |
| 02-02-01 | 02-02 | 1 | DEMO-02, DEMO-03, DEMO-04, DEMO-05 | T-02-03 / N/A | Disabled controls do not invoke unavailable resource/camera/filter behavior. | unit | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` | yes | green |
| 02-03-01 | 02-03 | 2 | SDK-08, DEMO-02, DEMO-03, DEMO-04, DEMO-05, DEMO-08 | T-02-04 / N/A | Final shell exposes only honest app-side state and remains local/no-network/no-photo-input. | full suite | full suite command above | yes | green |

All task rows are green after the 2026-06-23 validation audit.

---

## Wave 0 Requirements

- [x] `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` — local `BeautySDK` package product wired to the app target.
- [x] `BeautyDemo/BeautyDemoTests/` — Demo unit test directory and test target.
- [x] `BeautyDemo/BeautyDemo/Panel/` — category, subcategory, availability, and control descriptors.
- [x] `BeautyDemo/BeautyDemo/State/` — parameter display state, normalization, and reset behavior.
- [x] `BeautyDemo/BeautyDemo/Editor/` — static editor shell entry point replacing the template.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Editor-shell visual density and first-screen composition | DEMO-02, DEMO-03 | Phase 2 can automate taxonomy/state but not subjective layout quality without a UI-SPEC and visual audit. | Launch the Demo after build; confirm the first screen presents a static editor preview, disabled Camera/Photo entries, Beauty selected by default, and visible disabled future categories with short badges. |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all previously absent references.
- [x] No watch-mode flags.
- [x] Feedback latency < 120s after infrastructure exists.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-23 after milestone audit cleanup

## Validation Audit 2026-06-23

| Metric | Count |
|--------|-------|
| Task rows audited | 4 |
| Green rows | 4 |
| Wave 0 items complete | 5 |
| Escalated manual-only items | 0 |

Evidence:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed during the v1.0 milestone audit run.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `02-VERIFICATION.md` records `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08` as passed.
