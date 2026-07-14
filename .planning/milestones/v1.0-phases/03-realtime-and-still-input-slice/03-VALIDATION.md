---
phase: 03
slug: realtime-and-still-input-slice
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-12
audited: 2026-06-23
---

# Phase 03 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest through `BeautyDemo/BeautyDemo.xcodeproj` for Demo state/pipeline tests; SwiftPM XCTest through `BeautySDK/Package.swift` for SDK facade regression tests. |
| **Config file** | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`; `BeautySDK/Package.swift`. |
| **Quick run command** | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=<Simulator Name>,OS=<OS Version>' test` after simulator discovery. |
| **Full suite command** | `swift test --package-path BeautySDK` plus Demo simulator `xcodebuild ... test` plus static scans from `QUALITY_SCORE.md`. |
| **Estimated runtime** | Unknown until simulator availability is restored; target focused XCTest feedback under 120 seconds when CoreSimulatorService is available. |

---

## Sampling Rate

- **After every task commit:** Run the focused Demo XCTest target for the changed state or pipeline, plus relevant static scans.
- **After every plan wave:** Run Demo simulator `xcodebuild ... test` with an explicit destination and `swift test --package-path BeautySDK` when SwiftPM cache access permits.
- **Before `$gsd-verify-work`:** Full suite and static scans must be green, or exact simulator/SwiftPM environment failures must be recorded.
- **Max feedback latency:** 120 seconds for focused tests when simulator services are available.

Required static scans:

```bash
rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
rg -n "import Beauty(Core|Render|Detection|Effects|Resources)" BeautyDemo BeautyDemo/BeautyDemoTests 2>/dev/null
rg -n "NSCameraUsageDescription|NSPhotoLibraryUsageDescription" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj
```

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-W0 | 03-01 | 0 | PIPE-01, DEMO-01 | T-03-01 | Camera permission state is injectable and does not request access on launch. | unit/view-state | `xcodebuild ... -only-testing:BeautyDemoTests/CameraPermissionStateTests test` | yes | green |
| 03-01-01 | 03-01 | 1 | PIPE-01, DEMO-01 | T-03-01 | Denied/restricted/unavailable camera states preserve the shell and keep Photo available. | unit/view-state | `xcodebuild ... -only-testing:BeautyDemoTests/CameraPermissionStateTests test` | yes | green |
| 03-01-02 | 03-01 | 1 | PIPE-01 | T-03-02 | `AVCaptureVideoDataOutput` emits sample-buffer backed `CVPixelBuffer` frames without exposing raw framework errors. | unit/integration seam | `xcodebuild ... -only-testing:BeautyDemoTests/CameraSessionControllerTests test` | yes | green |
| 03-02-W0 | 03-02 | 0 | PIPE-02, PIPE-03 | T-03-03 | Realtime processing uses direct pixel buffers and bounded in-flight work. | unit/static | `xcodebuild ... -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | yes | green |
| 03-02-01 | 03-02 | 1 | PIPE-02 | T-03-03 | Realtime camera path calls `BeautyEngine.process(pixelBuffer:orientation:parameters:)` and does not use `UIImage`. | unit/static | `rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null` | yes | green |
| 03-02-02 | 03-02 | 1 | PIPE-03 | T-03-04 | Stale frames are dropped or replaced; unbounded queues are not introduced. | unit | `xcodebuild ... -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | yes | green |
| 03-03-W0 | 03-03 | 0 | PIPE-04, PIPE-06 | T-03-05 | Photo and compare state can be tested without real photo-library access. | unit/view-state | `xcodebuild ... -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` | yes | green |
| 03-03-01 | 03-03 | 1 | PIPE-04 | T-03-05 | Photo cancellation is a no-op; decode/process failures preserve prior visual state and use friendly copy. | unit/view-state | `xcodebuild ... -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` | yes | green |
| 03-03-02 | 03-03 | 1 | PIPE-06 | T-03-06 | Compare toggles input/output display only and does not reset parameters, mode, category, subcategory, crop, or orientation. | unit/view-state | `xcodebuild ... -only-testing:BeautyDemoTests/CompareStateTests test` | yes | green |
| 03-04-W0 | 03-04 | 0 | PIPE-08, DEMO-01 | T-03-07 | Purpose strings and facade-only imports are verified before protected-resource behavior ships. | static/unit | `rg -n "NSCameraUsageDescription|NSPhotoLibraryUsageDescription" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | yes | green |
| 03-04-01 | 03-04 | 1 | PIPE-08 | T-03-07 | Purpose strings are local-first and do not imply upload or remote processing. | static | `rg -n "Use the camera to preview beauty processing on this device|Select photos to preview beauty processing on this device" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | yes | green |
| 03-04-02 | 03-04 | 1 | DEMO-01, PIPE-02 | T-03-08 | Demo and Demo tests import only `BeautySDK`, never internal SDK targets. | static/unit | `rg -n "import Beauty(Core|Render|Detection|Effects|Resources)" BeautyDemo BeautyDemo/BeautyDemoTests 2>/dev/null` | yes | green |

All task rows are green after the 2026-06-23 validation audit.

---

## Wave 0 Requirements

- [x] `BeautyDemo/BeautyDemoTests/CameraPermissionStateTests.swift` - permission mapping, no launch prompt, denied/restricted UI state, Settings action availability, Photo fallback.
- [x] `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` - injectable camera session/frame source behavior, sample-buffer to pixel-buffer extraction, unavailable/setup failure mapping.
- [x] `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` - direct `CVPixelBuffer` processing, bounded in-flight work, stale-frame drops, latest parameter snapshot usage.
- [x] `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` - fixture input, PhotosPicker-load seam, cancellation no-op, decode failure, stale photo work, previous visual preservation.
- [x] `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` - shared before/after state for Camera and Photo without parameter or selection resets.
- [x] Update `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Camera and Photo entries are enabled mode switches and existing categories/panels remain visible.
- [x] Add static or XCTest coverage for generated Info.plist camera/photo purpose strings.

The planner must link every absent or Wave 0 test file reference in `<verify><automated>` to a Wave 0 task that creates the same test file path before dependent implementation tasks.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real hardware camera preview starts and remains responsive | PIPE-01, PIPE-03 | CoreSimulatorService was unavailable during research, and simulators may not provide full camera hardware behavior. | On an iOS device or simulator with camera support, tap Camera, grant permission, verify live preview appears, sliders remain responsive, and no preview clearing occurs during processing. |
| iOS Settings round-trip after denied camera permission | PIPE-01, PIPE-08 | Permission denial state depends on OS Settings state and is brittle as pure unit automation. | Deny Camera, relaunch if needed, tap Camera, verify permission copy and `Open Settings`; change permission in Settings and return to app. |
| System Photos picker user path | PIPE-04 | PhotosUI privacy flow and real library selection are OS-owned. Unit tests should cover the loading seam, while manual smoke verifies the real picker. | Tap Photo, choose an image, verify loading overlay preserves previous visual and processed output replaces it only on success. Cancel picker and verify no error banner appears. |

Automated tests remain required for the underlying state transitions and pipeline behavior; manual checks are only smoke coverage for OS-owned UI and hardware integration.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify commands or Wave 0 dependencies.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all previously absent references.
- [x] No watch-mode flags.
- [x] Feedback latency target is under 120 seconds for focused tests when simulator services are available.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-12

## Validation Audit 2026-06-23

| Metric | Count |
|--------|-------|
| Task rows audited | 12 |
| Green rows | 12 |
| Wave 0 items complete | 7 |
| Escalated manual-only items | 0 |

Evidence:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed during the v1.0 milestone audit run.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `03-VERIFICATION.md` records `PIPE-01`, `PIPE-02`, `PIPE-03`, `PIPE-04`, `PIPE-06`, `PIPE-08`, and `DEMO-01` as passed.
