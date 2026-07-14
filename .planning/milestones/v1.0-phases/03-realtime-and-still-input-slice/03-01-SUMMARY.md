---
phase: "03-realtime-and-still-input-slice"
plan: "03-01"
subsystem: "ui"
tags: ["swiftui", "avfoundation", "camera-permission", "xctest"]
requires:
  - phase: "02-demo-integration-shell"
    provides: "EditorShellView, mode rail, parameter panel, deterministic Demo fixtures, and focused view-state tests"
provides:
  - "Enabled Camera and Photo mode switches in the existing editor shell"
  - "Demo-owned camera permission client and app-layer permission states"
  - "AVFoundation capture shell configured for BGRA CVPixelBuffer frames"
  - "Live preview layer bridge contained inside the existing preview card"
  - "Generated camera and photo purpose strings in Debug and Release Info.plist settings"
affects: ["03-02", "03-03", "03-04", "camera", "photo-input", "pipeline"]
tech-stack:
  added: ["AVFoundation", "CoreVideo", "CoreMedia", "ImageIO"]
  patterns: ["injectable protected-resource client", "Demo-owned capture session controller", "preview-card-only input states"]
key-files:
  created:
    - "BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift"
    - "BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift"
    - "BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift"
    - "BeautyDemo/BeautyDemo/Camera/CameraPreviewLayerView.swift"
    - "BeautyDemo/BeautyDemoTests/CameraPermissionStateTests.swift"
    - "BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift"
  modified:
    - "BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj"
    - "BeautyDemo/BeautyDemo/Editor/EditorShellView.swift"
    - "BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift"
    - "BeautyDemo/BeautyDemo/Support/DemoFixtures.swift"
    - "BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift"
    - "BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift"
key-decisions:
  - "Camera permission remains Demo-owned and injectable; the SDK does not own protected-resource access."
  - "Camera and Photo are enabled value-state switches, preserving the existing shell while swapping only preview content."
  - "Camera frames use BGRA CVPixelBuffer metadata now; SDK processing is intentionally deferred to later Phase 3 plans."
patterns-established:
  - "Protected resources are requested only from explicit user intent paths."
  - "Unavailable and denied camera states render inside the preview card with retry/fallback actions."
requirements-completed: ["PIPE-01", "PIPE-08", "DEMO-01"]
duration: "25min"
completed: "2026-06-12"
---

# Plan 03-01 Summary

**Camera and Photo are active editor input modes with explicit camera permission flow and a BGRA AVFoundation capture shell.**

## Performance

- **Duration:** 25 min
- **Started:** 2026-06-12T15:00:24+0800
- **Completed:** 2026-06-12T15:25:49+0800
- **Tasks:** 3
- **Files modified:** 12

## Accomplishments

- Replaced disabled Camera/Photo fixture entries with enabled mode switches and selected accessibility state.
- Added `CameraPermissionClient`, `CameraPermissionState`, and production AVFoundation-backed permission mapping so camera access is requested only after the Camera tap path.
- Added a Demo-owned `CameraSessionController` and `CameraPreviewLayerView` that keep live preview contained in the existing preview card and emit BGRA `CVPixelBuffer` frame models for later pipeline work.
- Added Debug/Release purpose strings for camera and photo protected-resource use before any access path runs.
- Added focused XCTest coverage for permission states, no-launch permission behavior, disabled/restricted/unavailable preview states, BGRA output settings, and shell preservation.

## Task Commits

1. **Wave 0, permission modes, and capture shell** - `fbc78d2` (feat)

The three 03-01 tasks were committed together because the enabled mode UI, permission client, and capture shell are wired through `EditorShellView`; splitting the implementation would have left intermediate commits with unresolved symbols.

## Files Created/Modified

- `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift` - Permission state model plus injectable system client.
- `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` - Camera frame and session state models.
- `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift` - AVFoundation session setup, BGRA video output, frame emission, and failure mapping.
- `BeautyDemo/BeautyDemo/Camera/CameraPreviewLayerView.swift` - SwiftUI/UIKit preview layer bridge.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - Mode selection, permission flow, live preview, retry/settings/photo fallback actions.
- `BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift` - Enabled button-style mode entries with selected state.
- `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` - Camera/Photo input mode fixtures.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` - Generated Info.plist purpose strings.
- `BeautyDemo/BeautyDemoTests/CameraPermissionStateTests.swift` - Permission and preview-state tests.
- `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` - Capture output and frame metadata tests.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Existing editor shell expectations updated for enabled input modes.
- `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` - Fixture import-boundary expectations updated for enabled input modes.

## Decisions Made

Camera access stays in the Demo layer. The SDK will consume frame-like values later, but it does not request permission or own `AVCaptureSession`.

Camera and Photo use enum-backed editor state instead of disabled fixture rows. This keeps the top mode row, category rail, and parameter panel stable while only the preview card changes.

## Deviations from Plan

Implementation tasks were committed as one buildable feature commit instead of separate task commits because their symbols are mutually referenced through `EditorShellView`. Scope stayed within the 03-01 file list and acceptance criteria.

## Issues Encountered

The first focused XCTest run hit sandbox/CoreSimulator access limits. The same command was rerun with approved Xcode permissions and passed.

## Verification

- `xcrun simctl list devices available`
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraPermissionStateTests -only-testing:BeautyDemoTests/CameraSessionControllerTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test`
- `rg -n "INFOPLIST_KEY_NSCameraUsageDescription|INFOPLIST_KEY_NSPhotoLibraryUsageDescription" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`
- `rg -n "UIImage" BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor 2>/dev/null`
- `git diff --cached --check`

Result: focused XCTest passed with 17 tests. The Info.plist scan found both purpose strings in Debug and Release. The `UIImage` scan returned no matches.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

03-02 can consume `CameraPreviewFrame`, `CameraSessionState`, and the enabled input mode seam to add PhotoPicker/still-image input without changing permission ownership or SDK boundaries.

---
*Phase: 03-realtime-and-still-input-slice*
*Completed: 2026-06-12*
