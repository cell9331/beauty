---
phase: 04
slug: detection-and-coordinate-safety
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-18
---

# Phase 04 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest through SwiftPM and Xcode simulator test runner |
| **Config file** | `BeautySDK/Package.swift`; `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` |
| **Quick run command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` |
| **Full suite command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` |
| **Estimated runtime** | SwiftPM ~10-30 seconds; Demo XCTest ~60-180 seconds |

---

## Sampling Rate

- **After every SDK model/detection/coordinate task commit:** Run `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK`.
- **After every Demo pipeline/status task commit:** Run the focused affected `xcodebuild ... -only-testing:BeautyDemoTests/<TestClass>` command, then the full Demo XCTest suite before phase close.
- **After every plan wave:** Run both SwiftPM package tests and Demo simulator XCTest if that wave touched both SDK and Demo; otherwise run the touched side plus static import/privacy scans.
- **Before `$gsd-verify-work`:** SwiftPM package tests and full Demo simulator XCTest must be green, or failures must be recorded with exact command and reason.
- **Max feedback latency:** 180 seconds for the routine full suite path on the configured simulator.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 04-01 | 1 | PIPE-05, PIPE-07 | T-04-01 | Public metadata exposes summaries only, not face geometry | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyInputMetadataTests` | no | pending |
| 04-01-02 | 04-01 | 1 | PIPE-07 | T-04-02 | Detection availability and reasons are structured and redacted | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyResultDetectionSummaryTests` | no | pending |
| 04-02-01 | 04-02 | 2 | PIPE-07 | T-04-03 | Vision adapter returns internal models without leaking Vision objects | unit/smoke | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyDetectionTests` | no | pending |
| 04-02-02 | 04-02 | 2 | PIPE-07 | T-04-04 | No-face, partial-face, disabled, and not-run states do not crash | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter DetectionAvailabilityTests` | no | pending |
| 04-03-01 | 04-03 | 3 | PIPE-05 | T-04-05 | Orientation and mirroring conversions stay explicit | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter CoordinateMapperTests` | no | pending |
| 04-03-02 | 04-03 | 3 | PIPE-05 | T-04-06 | Old orientation API is equivalent to default non-mirrored metadata API | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineMetadataCompatibilityTests` | no | pending |
| 04-04-01 | 04-04 | 4 | PIPE-05, PIPE-07 | T-04-07 | Demo Camera and Photo snapshots carry full metadata through public facade only | simulator XCTest | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` | yes | pending |
| 04-04-02 | 04-04 | 4 | PIPE-07 | T-04-08 | Demo status/debug data shows safe summaries and no sensitive geometry/path/raw errors | simulator XCTest/static scan | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/InputPipelinePrivacyTests test` | yes | pending |
| 04-04-03 | 04-04 | 4 | PIPE-05, PIPE-07 | T-04-09 | Full SDK and Demo integration remains green | full suite | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` | yes | pending |

*Status: pending, green, red, flaky.*

---

## Wave 0 Requirements

Existing infrastructure covers the phase requirements:

- `BeautySDK/Package.swift` exists and already runs XCTest through SwiftPM.
- `BeautyDemo/BeautyDemo.xcodeproj` includes `BeautyDemoTests`.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` already provides import/privacy/static scan infrastructure.
- New `BeautyDetectionTests` and focused model/mapper test files can be added as normal task work; no separate test framework install is needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real front-camera mirroring | PIPE-05 | Simulator fixtures do not prove physical front-camera preview behavior | On a real device, start Camera mode, confirm preview mirroring matches user expectation, and record any mismatch as follow-up risk. |
| Real Vision face quality across lighting/poses | PIPE-07 | Synthetic fixtures and smoke tests do not prove production image quality | Try one clear face, one no-face scene, and one partial/side face; verify no crash and safe status. |

---

## Validation Sign-Off

- [x] All planned task areas have automated verification commands or existing test infrastructure.
- [x] Sampling continuity avoids three consecutive implementation tasks without automated verification.
- [x] Wave 0 is satisfied by existing SwiftPM and Demo XCTest infrastructure.
- [x] No watch-mode flags are used.
- [x] Feedback latency target is under 180 seconds for routine full-suite verification.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-18 for planning input
