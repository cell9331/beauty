# Phase 3: Realtime and Still Input Slice - Research

**Researched:** 2026-06-12 [VERIFIED: system date]
**Domain:** iOS SwiftUI Demo input pipelines, AVFoundation realtime capture, PhotosUI still-image input, BeautySDK facade integration [VERIFIED: .planning/ROADMAP.md]
**Confidence:** HIGH for repo contracts and local SDK API shapes; MEDIUM for Apple documentation prose because developer.apple.com pages were JavaScript shells in this session, with local Xcode SDK headers used for exact API detail [VERIFIED: codebase grep] [VERIFIED: Xcode SDK headers] [CITED: developer.apple.com]

<user_constraints>
## User Constraints (from CONTEXT.md)

Source for this entire section: `.planning/phases/03-realtime-and-still-input-slice/03-CONTEXT.md` [VERIFIED: codebase grep]

### Locked Decisions

## Implementation Decisions

### Camera and Photo Entry Flow
- **D-01:** Keep the current editor shell as the first screen. Do not launch directly into Camera and do not request camera permission on app launch.
- **D-02:** Turn the Phase 2 disabled Camera and Photo entries into clickable mode switches.
- **D-03:** Camera permission is requested only after the user taps Camera.
- **D-04:** The Camera mode replaces the existing shell preview fixture area with live camera preview while keeping the top Camera/Photo entries, bottom category rail, and parameter panel visible.
- **D-05:** The Photo mode supports the system Photo picker for the real user path and a deterministic test fixture path for tests and previews.

### Permission and Unavailable States
- **D-06:** If Camera permission is denied or restricted, keep the editor shell visible, leave Camera selected, and show a permission explanation plus a Settings action in the preview area. Photo remains available.
- **D-07:** If Camera is unavailable or session setup fails, show the unavailable state in the preview area and keep Photo as the fallback path.
- **D-08:** Photo picker cancellation is not an error. Reading or decoding failures show a non-blocking message and preserve the current image or fixture.
- **D-09:** Info.plist purpose strings should use short product copy that explains camera/photo access for local or on-device preview and editing. Do not imply upload or remote processing.

### Compare, Loading, and Error Behavior
- **D-10:** Camera and Photo share the same before/after compare toggle. It switches between input and output without resetting parameters or changing crop/orientation.
- **D-11:** While Photo processing is loading, keep the previous image or fixture visible and overlay a loading state in the preview area. On success, replace the processed output. On failure, keep the previous result.
- **D-12:** Camera and Photo share a lightweight error banner/status surface. Preserve the last usable visual state: Camera keeps the last successful frame or current live input, and Photo keeps the previous result or fixture.
- **D-13:** Internal error mapping may use `BeautyError.code`, but UI copy must be user-friendly and must not expose raw framework errors or sensitive paths.
- **D-14:** Slider values update immediately while processing is active. The pipeline uses the latest parameter snapshot: Camera drops stale frames/snapshots, and Photo cancels or marks stale work before reprocessing.

### the agent's Discretion
No areas were delegated to the agent. Follow the decisions above and the canonical references below.

### Deferred Ideas (OUT OF SCOPE)

## Deferred Ideas

None — discussion stayed within Phase 3 scope. Detection overlays and no-face/partial-face handling remain Phase 4, filters and presets remain Phase 5, real beauty effects remain Phase 6, and richer debug/export/demo QA flows remain Phase 7.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PIPE-01 | Demo can request camera permission and receive realtime camera frames through AVFoundation. [VERIFIED: .planning/REQUIREMENTS.md] | Use Demo-owned `CameraSessionController`, `AVCaptureDevice.authorizationStatus(for: .video)`, `requestAccess(for: .video)`, and `AVCaptureVideoDataOutput` sample-buffer delegate delivery. [VERIFIED: SECURITY.md] [VERIFIED: Xcode SDK headers] |
| PIPE-02 | Realtime camera processing avoids `UIImage` as an intermediate format and passes sample-buffer, pixel-buffer, or texture-backed input to SDK code. [VERIFIED: .planning/REQUIREMENTS.md] | Current `BeautyEngine.process(pixelBuffer:orientation:parameters:)` accepts `CVPixelBuffer`, and architecture/reliability contracts prohibit realtime `UIImage`. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: ARCHITECTURE.md] |
| PIPE-03 | Realtime processing uses bounded in-flight work and drops stale frames instead of allowing unbounded queue growth. [VERIFIED: .planning/REQUIREMENTS.md] | Use `alwaysDiscardsLateVideoFrames`, a serial delegate queue, `inFlight <= 1 or 2`, and latest-frame-wins state in the Demo pipeline. [VERIFIED: Xcode SDK headers] [VERIFIED: RELIABILITY.md] |
| PIPE-04 | Demo can select or provide a still image and process it through the SDK image path. [VERIFIED: .planning/REQUIREMENTS.md] | Use `PhotosPicker` for user path, fixture injection for tests/previews, decode to `CIImage`, then call `BeautyEngine.process(image:orientation:parameters:)`. [VERIFIED: Xcode SDK swiftinterface] [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: 03-CONTEXT.md] |
| PIPE-06 | Demo provides before/after comparison for camera or still-image output without resetting parameters or shifting crop/orientation. [VERIFIED: .planning/REQUIREMENTS.md] | Preserve input/output pairs and keep compare as display-only state outside `BeautyParameterStore`. [VERIFIED: 03-CONTEXT.md] [VERIFIED: FRONTEND.md] |
| PIPE-08 | Camera/photo features include required Info.plist purpose strings and conform to the local-first privacy boundary. [VERIFIED: .planning/REQUIREMENTS.md] | Add generated Info.plist keys before protected-resource use and keep copy local-first: camera and photo pixels stay in memory and are not uploaded or logged. [VERIFIED: SECURITY.md] [VERIFIED: BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj] |
| DEMO-01 | Demo main flow offers camera mode and still-image editing mode. [VERIFIED: .planning/REQUIREMENTS.md] | Convert existing disabled Camera/Photo entries into enabled mode switches in the current `EditorShellView` first screen. [VERIFIED: 03-CONTEXT.md] [VERIFIED: BeautyDemo/BeautyDemo/Editor/EditorShellView.swift] |
</phase_requirements>

## Summary

Phase 3 is primarily a Demo-app integration slice, not an SDK algorithm slice: the Demo owns protected-resource permission UX, camera session lifecycle, PhotosUI selection, pipeline backpressure, loading/error/compare state, and calls only the public `BeautySDK` facade. [VERIFIED: 03-CONTEXT.md] [VERIFIED: ARCHITECTURE.md] The SDK already exposes synchronous no-op `CVPixelBuffer` and `CIImage` processing APIs, so the plan should focus on app-side orchestration, bounded invocation, and tests rather than changing internal SDK target boundaries. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift]

The current codebase is still the Phase 2 editor shell: `EditorShellView` owns the first screen, Camera/Photo are disabled `DisabledMode` entries, the preview area is a deterministic fixture, and existing Demo tests validate view-state rather than simulator UI automation. [VERIFIED: BeautyDemo/BeautyDemo/Editor/EditorShellView.swift] [VERIFIED: BeautyDemo/BeautyDemo/Support/DemoFixtures.swift] [VERIFIED: BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift] The planner should therefore split work into state/model/pipeline layers first, then attach UI and protected-resource integration after purpose strings and injectable seams exist. [VERIFIED: FRONTEND.md] [VERIFIED: SECURITY.md]

**Primary recommendation:** Implement a facade-only Demo input architecture with `EditorShellView` mode state, a `CameraSessionController` that emits BGRA `CVPixelBuffer` frames, a bounded `CameraBeautyPipeline` that invokes `BeautyEngine.process(pixelBuffer:)` off the main actor, and an `ImageEditorPipeline` that uses `PhotosPicker` plus fixture injection to call `BeautyEngine.process(image:)`. [VERIFIED: FRONTEND.md] [VERIFIED: RELIABILITY.md] [VERIFIED: Xcode SDK headers]

## Project Constraints (from AGENTS.md)

| Directive | Planning Impact |
|-----------|-----------------|
| Read `AGENTS.md`, then `PLANS.md`, task docs, related code/tests, and docs history before changes. [VERIFIED: AGENTS.md] | Phase plans should start with orientation tasks and avoid implementation detached from repo contracts. [VERIFIED: AGENTS.md] |
| Code and tests outrank `PLANS.md`, specialized docs, and historical docs when conflicts exist. [VERIFIED: AGENTS.md] | Planner should verify current Swift/Xcode shape before relying on older `.planning/codebase` maps. [VERIFIED: AGENTS.md] |
| Do not write deep business rules into `AGENTS.md`; update the owning root doc when contracts change. [VERIFIED: AGENTS.md] | Phase 3 changes touching UI, privacy, reliability, or architecture need `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, or `ARCHITECTURE.md` updates, not `AGENTS.md` edits. [VERIFIED: AGENTS.md] |
| Do not broaden task scope; record extra issues in `PLANS.md`. [VERIFIED: AGENTS.md] | Detection overlays, no-face handling, real effects, filters, presets, export, and debug QA remain later phases. [VERIFIED: 03-CONTEXT.md] |
| Do not overwrite unrelated local changes. [VERIFIED: AGENTS.md] | Planner should scope file edits explicitly and avoid broad formatting or generated-project churn. [VERIFIED: AGENTS.md] |
| New public behavior requires `PRODUCT_SENSE.md` acceptance criteria. [VERIFIED: AGENTS.md] | Camera/photo mode behavior and compare acceptance may need doc sync if implementation adds contract details. [VERIFIED: AGENTS.md] |
| New risk boundaries require `SECURITY.md`; new performance/logging/error behavior requires `RELIABILITY.md`. [VERIFIED: AGENTS.md] | Purpose strings, local-first copy boundaries, stale-frame drops, and friendly error mapping must be documented if changed. [VERIFIED: AGENTS.md] |
| Xcode builds must use an explicit available iOS Simulator destination. [VERIFIED: AGENTS.md] | Validation tasks should first discover simulators, then run `xcodebuild ... -destination 'platform=iOS Simulator,name=...,OS=...'`. [VERIFIED: AGENTS.md] |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Mode switching between Camera and Photo | Browser / Client equivalent: SwiftUI Demo app | API / Backend equivalent: BeautySDK facade | SwiftUI owns UI mode state; SDK only processes media after Demo supplies input. [VERIFIED: FRONTEND.md] [VERIFIED: ARCHITECTURE.md] |
| Camera permission request | Browser / Client equivalent: SwiftUI Demo app | OS protected-resource framework | Permission prompts are initiated by `BeautyDemo`, not SDK internals; AVFoundation provides authorization APIs. [VERIFIED: SECURITY.md] [VERIFIED: Xcode SDK headers] |
| Realtime frame capture | Browser / Client equivalent: Demo camera layer | OS media framework | `CameraSessionController` owns `AVCaptureSession`; `AVCaptureVideoDataOutput` vends captured buffers on a delegate queue. [VERIFIED: FRONTEND.md] [VERIFIED: Xcode SDK headers] |
| Realtime SDK invocation/backpressure | Browser / Client equivalent: Demo pipeline | API / Backend equivalent: `BeautyEngine` | The public SDK call is synchronous today, so Demo must run it off-main with bounded in-flight work. [VERIFIED: DESIGN.md] [VERIFIED: RELIABILITY.md] |
| Still-image picking and fixture input | Browser / Client equivalent: Demo editor layer | OS PhotosUI framework | Photo mode needs the system picker for users and deterministic fixture path for tests/previews. [VERIFIED: 03-CONTEXT.md] [VERIFIED: Xcode SDK swiftinterface] |
| Still-image processing | Browser / Client equivalent: Demo editor pipeline | API / Backend equivalent: `BeautyEngine` | Demo decodes/loads selected media and calls `process(image:orientation:parameters:)` through `BeautySDK`. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: ARCHITECTURE.md] |
| Before/after compare display | Browser / Client equivalent: SwiftUI preview state | API / Backend equivalent: no-op output storage | Compare is display-only and must not mutate parameters, crop, orientation, mode, category, or subcategory. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md] |
| Local-first privacy boundary | Browser / Client equivalent: Demo app + SDK contract | OS plist/privacy framework | Protected-resource access needs purpose strings; pixels and face-adjacent data must not upload, persist, or log by default. [VERIFIED: SECURITY.md] |

## Standard Stack

### Core

| Library / Framework | Version | Purpose | Why Standard |
|---------------------|---------|---------|--------------|
| SwiftUI | iOS target 26.5 project setting; Swift language mode 5.0 in Xcode build settings [VERIFIED: BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj] | Editor shell, mode buttons, preview states, panel, compare controls. [VERIFIED: FRONTEND.md] | Existing Demo is SwiftUI and UI contract requires native SwiftUI system components. [VERIFIED: 03-UI-SPEC.md] |
| AVFoundation | iOS SDK 26.5 installed with Xcode 26.5 [VERIFIED: xcodebuild -version] | Camera permission, capture session, sample-buffer/pixel-buffer capture. [VERIFIED: Xcode SDK headers] | Repo contracts assign realtime camera preview to AVFoundation and prohibit SDK-owned permission prompts. [VERIFIED: FRONTEND.md] [VERIFIED: SECURITY.md] |
| PhotosUI `PhotosPicker` | Available in installed iOS SDK; `PhotosPicker` is available from iOS 16 in swiftinterface. [VERIFIED: Xcode SDK swiftinterface] | User-facing still-image selection. [VERIFIED: 03-CONTEXT.md] | Locked decision D-05 requires the system Photo picker; `PhotosPickerItem.loadTransferable` provides async selected-item loading. [VERIFIED: 03-CONTEXT.md] [VERIFIED: Xcode SDK swiftinterface] |
| CoreTransferable | Available in installed iOS SDK through `PhotosPickerItem.loadTransferable`. [VERIFIED: Xcode SDK swiftinterface] | Load selected photo data/transferable values from PhotosUI. [VERIFIED: Xcode SDK swiftinterface] | Avoids custom picker file access and gives a standard PhotosUI loading path. [VERIFIED: Xcode SDK swiftinterface] |
| CoreImage `CIImage` | Existing `BeautyEngine.process(image:)` public API input. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] | Still-image SDK input and no-op output display backing. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] | Current SDK image path is `CIImage`, and large image processing must happen off main thread. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: FRONTEND.md] |
| CoreVideo `CVPixelBuffer` | Existing `BeautyEngine.process(pixelBuffer:)` public API input and output. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] | Realtime no-`UIImage` camera input and output. [VERIFIED: ARCHITECTURE.md] | Current SDK validates BGRA `CVPixelBuffer` and copies to SDK-owned output. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] |
| Local `BeautySDK` facade | Local Swift Package, `swift-tools-version: 6.0`, supports iOS 17 and macOS 14. [VERIFIED: BeautySDK/Package.swift] | Public `BeautyEngine`, `BeautyParameters`, `BeautyError`, and no-op processing paths. [VERIFIED: BeautySDK/Package.swift] [VERIFIED: BeautySDK/Sources/BeautySDK/BeautySDK.swift] | Demo must import only `BeautySDK`, not internal targets. [VERIFIED: ARCHITECTURE.md] [VERIFIED: .planning/REQUIREMENTS.md] |

### Supporting

| Library / Framework | Version | Purpose | When to Use |
|---------------------|---------|---------|-------------|
| ImageIO `CGImagePropertyOrientation` | Imported by current SDK engine and frame models. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift] | Pass explicit orientation metadata to both realtime and still paths. [VERIFIED: DESIGN.md] | Required for current `BeautyEngine.process` signatures, even though full orientation preservation is Phase 4. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: .planning/REQUIREMENTS.md] |
| XCTest | Existing Demo and SDK tests use XCTest. [VERIFIED: BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift] [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift] | View-state, pipeline, permission-state, import-boundary, and SDK facade tests. [VERIFIED: FRONTEND.md] | Phase 2 used deterministic XCTest view-state tests, and Phase 3 should continue that style for injectable state. [VERIFIED: 03-CONTEXT.md] |
| SF Symbols | UI contract specifies SF Symbols. [VERIFIED: 03-UI-SPEC.md] | Camera/photo icons and compact actions. [VERIFIED: 03-UI-SPEC.md] | Existing `BeautyModeEntryView` already uses `camera` and `photo` system images. [VERIFIED: BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `PhotosPicker` | `PHPickerViewController` wrapper | `PhotosPicker` matches SwiftUI and installed SDK availability; use UIKit wrapper only if SwiftUI picker cannot satisfy tests or target constraints. [VERIFIED: Xcode SDK swiftinterface] [VERIFIED: 03-UI-SPEC.md] |
| `CVPixelBuffer` direct SDK path | `UIImage` conversion | Realtime `UIImage` conversion is explicitly prohibited by architecture, requirements, reliability, and quality checks. [VERIFIED: ARCHITECTURE.md] [VERIFIED: .planning/REQUIREMENTS.md] [VERIFIED: RELIABILITY.md] |
| Bounded latest-frame-wins pipeline | Unbounded operation queue | Unbounded frame queues violate Phase 3 requirement PIPE-03 and AVFoundation header warnings about memory growth. [VERIFIED: .planning/REQUIREMENTS.md] [VERIFIED: Xcode SDK headers] |
| View-state XCTest with injected controllers | Permission-heavy UI-only testing | Existing Demo tests are deterministic XCTest view-state tests; protected-resource UI checks can be minimized to simulator smoke where available. [VERIFIED: 03-CONTEXT.md] [VERIFIED: BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift] |

**Installation:**

```bash
# No external packages for Phase 3. Use Apple frameworks and the local BeautySDK package. [VERIFIED: SECURITY.md] [VERIFIED: BeautySDK/Package.swift]
```

**Version verification:**

```bash
xcodebuild -version
# Xcode 26.5, Build version 17F42 in this session. [VERIFIED: command output]

swift --version
# Apple Swift version 6.3.2 in this session. [VERIFIED: command output]
```

## Package Legitimacy Audit

Phase 3 should install no external packages. [VERIFIED: 03-CONTEXT.md] The package legitimacy gate is therefore not applicable; `slopcheck` was not present in PATH, but no npm/PyPI/crates package is recommended or required. [VERIFIED: command output]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| None | N/A | N/A | N/A | N/A | N/A | Approved: no external package install. [VERIFIED: BeautySDK/Package.swift] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: no external packages recommended]
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: no external packages recommended]

## Architecture Patterns

### System Architecture Diagram

```text
User taps Camera
  -> EditorShellView mode state selects Camera
  -> CameraPermissionClient reads AVCaptureDevice.authorizationStatus(for: .video)
  -> notDetermined? requestAccess(for: .video)
  -> authorized?
      yes -> CameraSessionController configures AVCaptureSession + AVCaptureVideoDataOutput
           -> serial sample-buffer queue emits CMSampleBuffer/CVPixelBuffer
           -> CameraBeautyPipeline checks in-flight <= 1 or 2
           -> latest BeautyParameterStore.parametersSnapshot
           -> BeautyEngine.process(pixelBuffer:orientation:parameters:)
           -> preview state stores input/output pair
           -> Compare toggle chooses input or output display
      no  -> preview area shows permission or unavailable state

User taps Photo
  -> EditorShellView mode state selects Photo
  -> PhotosPicker selection or deterministic fixture input
  -> ImageEditorPipeline loads/decodes selected input off main thread
  -> latest BeautyParameterStore.parametersSnapshot
  -> BeautyEngine.process(image:orientation:parameters:)
  -> preview state stores input/output pair
  -> loading/error overlays preserve previous visual
  -> Compare toggle chooses input or output display
```

Diagram sources: Phase 3 decisions, `FRONTEND.md` flow, `RELIABILITY.md` backpressure policy, and current `BeautyEngine` APIs. [VERIFIED: 03-CONTEXT.md] [VERIFIED: FRONTEND.md] [VERIFIED: RELIABILITY.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift]

### Recommended Project Structure

```text
BeautyDemo/BeautyDemo/
├── Camera/
│   ├── CameraPermissionClient.swift      # authorization status/request wrapper; injectable for tests [VERIFIED: SECURITY.md]
│   ├── CameraSessionController.swift     # AVCaptureSession setup/output lifecycle [VERIFIED: FRONTEND.md]
│   ├── CameraBeautyPipeline.swift        # bounded off-main BeautyEngine invocation [VERIFIED: RELIABILITY.md]
│   └── CameraPreviewModels.swift         # UI state values, no SDK internals [VERIFIED: FRONTEND.md]
├── Editor/
│   ├── EditorShellView.swift             # current first screen, mode state, preview card [VERIFIED: current code]
│   ├── ImageEditorPipeline.swift         # still-image processing and stale-result cancellation [VERIFIED: 03-CONTEXT.md]
│   ├── ImageInputModels.swift            # fixture/user input models [VERIFIED: 03-CONTEXT.md]
│   └── CompareState.swift                # shared display-only compare state [VERIFIED: 03-UI-SPEC.md]
├── State/
│   └── BeautyParameterStore.swift        # current parameter snapshot owner [VERIFIED: current code]
└── Support/
    └── DemoFixtures.swift                # deterministic image/mode/test fixtures [VERIFIED: current code]
```

### Pattern 1: App-Owned Permission State

**What:** Wrap AVFoundation authorization in an injectable app-layer client, mapping system states to Demo states `notDetermined`, `requesting`, `authorized`, `denied`, `restricted`, and `unavailable`. [VERIFIED: SECURITY.md] [VERIFIED: Xcode SDK headers]

**When to use:** Use when Camera mode is selected and before creating capture inputs; do not request on app launch. [VERIFIED: 03-CONTEXT.md] [VERIFIED: SECURITY.md]

**Example:**

```swift
// Source: AVFoundation AVCaptureDevice.h in Xcode 26.5 SDK and SECURITY.md.
let status = AVCaptureDevice.authorizationStatus(for: .video)
if status == .notDetermined {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        Task { @MainActor in
            // Update Demo permission state; do not expose raw framework errors.
        }
    }
}
```

### Pattern 2: Serial Sample Queue + Latest Frame Wins

**What:** Configure `AVCaptureVideoDataOutput` with BGRA output, set a serial delegate queue, keep `alwaysDiscardsLateVideoFrames` enabled, and add a Demo-side in-flight guard around synchronous SDK work. [VERIFIED: FRONTEND.md] [VERIFIED: RELIABILITY.md] [VERIFIED: Xcode SDK headers]

**When to use:** Use for all realtime camera frames in Phase 3, because freshness is more important than processing every frame. [VERIFIED: RELIABILITY.md]

**Example:**

```swift
// Source: AVCaptureVideoDataOutput.h in Xcode 26.5 SDK and RELIABILITY.md.
let output = AVCaptureVideoDataOutput()
output.videoSettings = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
]
output.alwaysDiscardsLateVideoFrames = true
output.setSampleBufferDelegate(delegate, queue: sampleQueue)
```

### Pattern 3: Synchronous SDK Call Behind an Off-Main Pipeline

**What:** Read `BeautyParameterStore.parametersSnapshot` on the main actor, pass that immutable value to a processing queue/task, and invoke `BeautyEngine.process` outside SwiftUI `body`. [VERIFIED: DESIGN.md] [VERIFIED: FRONTEND.md] [VERIFIED: BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift]

**When to use:** Use for both camera and photo processing because current SDK `process` APIs are synchronous. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: RELIABILITY.md]

**Example:**

```swift
// Source: BeautyEngine.swift and BeautyParameterStore.swift.
let snapshot = await MainActor.run { parameterStore.parametersSnapshot }
let output = try engine.process(
    pixelBuffer: pixelBuffer,
    orientation: orientation,
    parameters: snapshot
)
```

### Pattern 4: Still Image Selection With Fixture Injection

**What:** Use `PhotosPicker` for real selection and a deterministic fixture input path for tests/previews; both should feed the same image pipeline. [VERIFIED: 03-CONTEXT.md] [VERIFIED: Xcode SDK swiftinterface]

**When to use:** Use whenever Photo mode is active; treat cancellation as no-op and decoding failures as non-blocking errors. [VERIFIED: 03-CONTEXT.md]

**Example:**

```swift
// Source: _PhotosUI_SwiftUI.swiftinterface in Xcode 26.5 SDK.
PhotosPicker("Choose Photo", selection: $selectedItem, matching: .images)

// PhotosPickerItem exposes:
// public func loadTransferable<T>(type: T.Type) async throws -> sending T? where T : Transferable
```

### Pattern 5: Compare as Display State, Not Processing State

**What:** Keep input and output references in preview state and let compare only decide which one is displayed. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md]

**When to use:** Use for both Camera and Photo modes to satisfy shared compare behavior without resetting parameters, crop, orientation, selected mode, category, or subcategory. [VERIFIED: 03-UI-SPEC.md]

**Example:**

```swift
// Source: 03-UI-SPEC.md compare contract.
enum CompareDisplayMode: Equatable {
    case after
    case before
}
```

### Anti-Patterns to Avoid

- **Requesting camera permission during app launch:** Violates D-01 and D-03 and creates protected-resource access before user intent. [VERIFIED: 03-CONTEXT.md] [VERIFIED: SECURITY.md]
- **Letting `BeautyModeEntryView` remain disabled or own business logic:** Phase 3 needs enabled mode switches, but shell state should own the selected mode. [VERIFIED: 03-CONTEXT.md] [VERIFIED: current code]
- **Creating unbounded frame queues:** Violates PIPE-03 and AVFoundation header guidance that queued frames can increase memory usage. [VERIFIED: .planning/REQUIREMENTS.md] [VERIFIED: Xcode SDK headers]
- **Converting realtime frames through `UIImage`:** Violates A3, PIPE-02, and reliability forbidden-path rules. [VERIFIED: ARCHITECTURE.md] [VERIFIED: .planning/REQUIREMENTS.md] [VERIFIED: RELIABILITY.md]
- **Using raw `BeautyError.description` or `NSError` in UI copy:** Violates D-13 and security/reliability redaction rules. [VERIFIED: 03-CONTEXT.md] [VERIFIED: SECURITY.md] [VERIFIED: RELIABILITY.md]
- **Clearing the preview during photo loading or failure:** Violates D-11 and the UI contract loading/error behavior. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md]
- **Routing still-image state through camera-only state:** Violates `FRONTEND.md` image editor rules and makes Photo mode harder to test. [VERIFIED: FRONTEND.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Photo library selection UI | Custom asset browser or file-path picker | SwiftUI `PhotosPicker` | D-05 locks system Photo picker, and PhotosUI provides selected-item loading APIs. [VERIFIED: 03-CONTEXT.md] [VERIFIED: Xcode SDK swiftinterface] |
| Camera permission state | Local persisted boolean or custom permission cache | `AVCaptureDevice.authorizationStatus(for:)` and `requestAccess(for:)` | AVFoundation owns hardware authorization; invalid media types throw, and `notDetermined` can prompt. [VERIFIED: Xcode SDK headers] |
| Realtime frame throttling | Homegrown unbounded queue with delayed processing | `alwaysDiscardsLateVideoFrames` plus explicit in-flight guard | AVFoundation supports late-frame discard, and repo reliability contract requires bounded latest-frame-wins behavior. [VERIFIED: Xcode SDK headers] [VERIFIED: RELIABILITY.md] |
| Public media processing API | Direct imports of `BeautyCore`/`BeautyRender` or private render passes | Public `BeautySDK.BeautyEngine` facade | Demo must behave like a host app and import only `BeautySDK`. [VERIFIED: ARCHITECTURE.md] [VERIFIED: .planning/REQUIREMENTS.md] |
| Error presentation | Raw framework error strings or file paths | Friendly mapped UI states keyed by `BeautyError.code` when needed | D-13 allows internal codes but forbids raw framework errors and sensitive paths in UI. [VERIFIED: 03-CONTEXT.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyError.swift] |
| Compare behavior | Reprocess/reset parameters on compare toggle | Store input/output pair and switch display | Compare must not reset parameters or change crop/orientation. [VERIFIED: 03-CONTEXT.md] |

**Key insight:** Phase 3 complexity is lifecycle and state orchestration, not image algorithms; hand-rolling OS permissions, picker UI, queues, or private SDK access would add risk without advancing the no-op input slice. [VERIFIED: 03-CONTEXT.md] [VERIFIED: FRONTEND.md] [VERIFIED: RELIABILITY.md]

## Common Pitfalls

### Pitfall 1: Protected Resource Access Before Purpose Strings

**What goes wrong:** Camera or photo access can occur before `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` are configured in the generated Info.plist settings. [VERIFIED: SECURITY.md] [VERIFIED: BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj]

**Why it happens:** The current project uses `GENERATE_INFOPLIST_FILE = YES`, and grep found no camera/photo usage-description keys in `project.pbxproj`. [VERIFIED: codebase grep]

**How to avoid:** Add `INFOPLIST_KEY_NSCameraUsageDescription = "Use the camera to preview beauty processing on this device.";` and `INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "Select photos to preview beauty processing on this device.";` to app Debug and Release build settings before adding capture/picker code. [VERIFIED: 03-UI-SPEC.md] [VERIFIED: BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj]

**Warning signs:** Build settings still only show scene/launch/orientation Info.plist keys and no camera/photo usage strings. [VERIFIED: codebase grep]

### Pitfall 2: Main-Thread Camera or Photo Processing

**What goes wrong:** The UI freezes because synchronous `BeautyEngine.process` work runs in SwiftUI `body`, an action closure, or the main actor. [VERIFIED: FRONTEND.md] [VERIFIED: RELIABILITY.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift]

**Why it happens:** Current SDK processing APIs are synchronous, so the caller must choose an off-main execution context. [VERIFIED: DESIGN.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift]

**How to avoid:** Pipeline objects own processing; UI only updates state on the main actor after completion. [VERIFIED: FRONTEND.md]

**Warning signs:** `engine.process(` appears directly in SwiftUI `body` or in broad view code rather than pipeline/controller files. [VERIFIED: FRONTEND.md]

### Pitfall 3: Backpressure Only at AVFoundation Layer

**What goes wrong:** Frames are dropped by AVFoundation, but SDK processing tasks still queue unboundedly after the delegate callback. [VERIFIED: Xcode SDK headers] [VERIFIED: RELIABILITY.md]

**Why it happens:** Migrating work to another queue makes the app responsible for preventing unbounded memory growth. [VERIFIED: Xcode SDK headers]

**How to avoid:** Combine `alwaysDiscardsLateVideoFrames = true` with Demo-owned in-flight counters and latest-frame-wins cancellation/ignore semantics. [VERIFIED: Xcode SDK headers] [VERIFIED: RELIABILITY.md]

**Warning signs:** Use of `OperationQueue` or `Task.detached` per frame without max concurrency or generation tokens. [VERIFIED: RELIABILITY.md]

### Pitfall 4: Photo Cancellation Treated as Failure

**What goes wrong:** User cancels the system picker and receives an error banner or cleared preview. [VERIFIED: 03-CONTEXT.md]

**Why it happens:** Picker selection changes are conflated with decode errors. [VERIFIED: 03-CONTEXT.md]

**How to avoid:** Model `nil` or unchanged picker selection as no-op; only decode/read exceptions map to the required non-blocking copy. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md]

**Warning signs:** Tests expect an error after cancellation or preview state becomes empty after cancellation. [VERIFIED: 03-CONTEXT.md]

### Pitfall 5: Compare Mutates Processing Inputs

**What goes wrong:** Compare resets parameters, reprocesses with different snapshots, changes orientation, or changes crop. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md]

**Why it happens:** Compare state is stored with parameter or pipeline input state instead of display state. [VERIFIED: FRONTEND.md]

**How to avoid:** Keep compare as a small enum/boolean in the preview display model and preserve both before and after references. [VERIFIED: 03-UI-SPEC.md]

**Warning signs:** Compare toggle calls `reset`, changes `BeautyParameterStore`, recreates the selected image, or restarts camera mode. [VERIFIED: 03-CONTEXT.md]

### Pitfall 6: Raw Error and Path Leakage

**What goes wrong:** User-facing UI exposes `NSError`, raw `BeautyError.description`, file paths, or framework domains. [VERIFIED: SECURITY.md] [VERIFIED: RELIABILITY.md]

**Why it happens:** Implementation directly renders thrown error descriptions. [VERIFIED: 03-CONTEXT.md]

**How to avoid:** Map failures to UI copy from `03-UI-SPEC.md`; tests may assert `BeautyError.code`, not raw displayed errors. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyError.swift]

**Warning signs:** UI tests assert strings like `unsupported_pixel_format`, path prefixes, or `AVFoundationErrorDomain`. [VERIFIED: SECURITY.md]

## Code Examples

Verified patterns from local contracts and installed SDK headers:

### Camera Authorization Wrapper

```swift
// Source: SECURITY.md and AVFoundation AVCaptureDevice.h in Xcode 26.5 SDK.
protocol CameraPermissionProviding {
    func authorizationStatus() -> AVAuthorizationStatus
    func requestAccess() async -> Bool
}

struct AVCaptureCameraPermissionProvider: CameraPermissionProviding {
    func authorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
```

### Realtime Frame Delegate Extraction

```swift
// Source: FRONTEND.md, RELIABILITY.md, and AVCaptureVideoDataOutput.h.
func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        return
    }

    pipeline.processLatest(
        pixelBuffer: pixelBuffer,
        orientation: .right,
        timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    )
}
```

### Bounded Pipeline Generation Token

```swift
// Source: RELIABILITY.md latest-frame-wins policy and current synchronous BeautyEngine API.
final class CameraBeautyPipeline {
    private let queue = DispatchQueue(label: "beauty.camera.pipeline")
    private var isProcessing = false
    private var pendingFrame: FrameInput?
    private var droppedFrames = 0

    func processLatest(_ frame: FrameInput) {
        queue.async {
            if self.isProcessing {
                self.pendingFrame = frame
                self.droppedFrames += 1
                return
            }
            self.process(frame)
        }
    }
}
```

### Photo Picker Loading Path

```swift
// Source: _PhotosUI_SwiftUI.swiftinterface in Xcode 26.5 SDK and 03-CONTEXT.md.
@State private var selectedPhotoItem: PhotosPickerItem?

PhotosPicker("Choose Photo", selection: $selectedPhotoItem, matching: .images)
    .onChange(of: selectedPhotoItem) { _, item in
        guard let item else { return } // cancellation / no selection is not an error
        Task {
            let data = try await item.loadTransferable(type: Data.self)
            // Decode off main thread and call BeautyEngine.process(image:orientation:parameters:).
        }
    }
```

### Still Image Processing

```swift
// Source: BeautyEngine.swift and 03-CONTEXT.md.
let processed = try engine.process(
    image: inputCIImage,
    orientation: orientation,
    parameters: parametersSnapshot
)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `UIImagePickerController`/custom picker for basic photo selection | SwiftUI `PhotosPicker` with `PhotosPickerItem.loadTransferable` | `PhotosPicker` is available from iOS 16 per installed SDK swiftinterface. [VERIFIED: Xcode SDK swiftinterface] | Planner can use native SwiftUI picker and fixture injection instead of UIKit wrapper unless a concrete gap appears. [VERIFIED: 03-UI-SPEC.md] |
| Processing every camera frame in order | Realtime latest-frame-wins with late-frame discards and bounded in-flight work | Current repo reliability contract dated before Phase 3; AVFoundation header supports late-frame discard. [VERIFIED: RELIABILITY.md] [VERIFIED: Xcode SDK headers] | Planner must include explicit stale-frame drop tests and no unbounded queue. [VERIFIED: .planning/REQUIREMENTS.md] |
| Direct `UIImage` intermediate for both camera and photo | `CVPixelBuffer` for realtime, `CIImage` for current still-image SDK path | Current `BeautyEngine` public signatures already use `CVPixelBuffer` and `CIImage`. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] | Realtime no-`UIImage` scan is a gate; still-image boundary use must be explicit if introduced for UI display only. [VERIFIED: QUALITY_SCORE.md] |
| Permission prompts as incidental side effects of capture input creation | User-intent permission request after Camera tap | Locked by Phase 3 D-01/D-03 and security contract. [VERIFIED: 03-CONTEXT.md] [VERIFIED: SECURITY.md] | Planner must order Info.plist and permission state work before capture session startup. [VERIFIED: SECURITY.md] |

**Deprecated/outdated:**

- `AVCaptureVideoDataOutput.minFrameDuration` is deprecated in the installed iOS SDK header, which says to use `AVCaptureConnection.videoMinFrameDuration` instead. [VERIFIED: Xcode SDK headers]
- Realtime `UIImage` conversion is prohibited in current repo contracts and should not be used as a bridge for Phase 3 camera processing. [VERIFIED: ARCHITECTURE.md] [VERIFIED: RELIABILITY.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Camera simulator behavior may require manual/device verification beyond deterministic tests because CoreSimulatorService was unavailable in this session. [ASSUMED] | Environment Availability / Validation Architecture | Planner may overestimate automated simulator coverage if the environment is repaired later or if camera simulation is limited. |

All package names and APIs recommended for implementation are Apple frameworks or local repository modules verified from the installed SDK or repo files, not third-party package discoveries. [VERIFIED: Xcode SDK headers] [VERIFIED: BeautySDK/Package.swift]

## Open Questions (RESOLVED)

1. **RESOLVED: What exact preview renderer should Phase 3 use for live `CVPixelBuffer` output?**
   - What we know: `FRONTEND.md` lists `MetalPreviewView`, but Phase 3 only needs the no-op path and stable live preview behavior. [VERIFIED: FRONTEND.md]
   - What's unclear: The repo has no existing `MetalPreviewView`, and building a real Metal display bridge may be more than the no-op input slice needs. [VERIFIED: rg --files BeautyDemo]
   - Recommendation: Plan a narrow preview adapter that can display current live input/output and can later be replaced by `MetalPreviewView`; avoid private SDK render internals. [VERIFIED: ARCHITECTURE.md]
   - Resolution: Phase 3 will plan `CameraPreviewLayerView` or an equivalent thin AVFoundation-backed preview adapter inside `BeautyDemo`, scoped to the existing preview card. It must not create SDK-internal render dependencies; full Metal preview evolution remains later implementation discretion or Phase 4+ work. [VERIFIED: 03-01-PLAN.md]

2. **RESOLVED: Should the still-image user path request `NSPhotoLibraryUsageDescription` when using `PhotosPicker`?**
   - What we know: Phase decisions and UI spec explicitly require a photo purpose string, and security docs require one if Demo reads from the photo library. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md] [VERIFIED: SECURITY.md]
   - What's unclear: Apple PhotosUI picker flows can reduce direct photo-library permission needs, but the phase contract still locks the purpose string. [CITED: https://developer.apple.com/documentation/photosui/photospicker] [VERIFIED: 03-CONTEXT.md]
   - Recommendation: Honor the locked contract and add `NSPhotoLibraryUsageDescription`; do not rely on picker privacy semantics to skip it. [VERIFIED: 03-CONTEXT.md]
   - Resolution: Phase 3 will add `INFOPLIST_KEY_NSPhotoLibraryUsageDescription = Select photos to preview beauty processing on this device.` in both app build configurations, alongside the camera purpose string, because D-09 and the UI contract require it. [VERIFIED: 03-04-PLAN.md]

3. **RESOLVED: Will full EXIF orientation preservation be implemented now or deferred?**
   - What we know: Phase 3 requires compare not to shift crop/orientation, but PIPE-05 full orientation/mirroring preservation is mapped to Phase 4. [VERIFIED: .planning/REQUIREMENTS.md] [VERIFIED: .planning/ROADMAP.md]
   - What's unclear: Still-image decoding may need enough orientation handling to avoid obvious compare shifts even before Phase 4. [VERIFIED: 03-CONTEXT.md]
   - Recommendation: Pass explicit `CGImagePropertyOrientation` through current SDK APIs and keep input/output display geometry identical; defer generalized orientation/mirroring mapper work to Phase 4. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] [VERIFIED: .planning/ROADMAP.md]
   - Resolution: Phase 3 will preserve input/output display geometry and pass explicit `CGImagePropertyOrientation` through the existing public SDK calls, but will not implement generalized orientation/mirroring mapping or face-coordinate preview transforms; those stay in Phase 4. [VERIFIED: 03-03-PLAN.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Xcode | Build, iOS SDK headers, simulator test/build | yes [VERIFIED: command output] | Xcode 26.5, Build 17F42 [VERIFIED: command output] | None needed for compile research. [VERIFIED: command output] |
| Swift toolchain | Swift package tests and source compile | yes [VERIFIED: command output] | Apple Swift 6.3.2 [VERIFIED: command output] | Use Xcode build/test if SwiftPM sandbox blocks. [VERIFIED: command output] |
| Node | GSD graph tooling | yes [VERIFIED: command output] | v26.0.0 [VERIFIED: command output] | Not required for implementation. [VERIFIED: .planning/config.json] |
| CoreSimulatorService | Simulator discovery/build/test | no in this sandboxed command session [VERIFIED: command output] | Error Code 61 connection refused [VERIFIED: command output] | Planner should include simulator discovery as first validation step and record failure honestly. [VERIFIED: AGENTS.md] |
| `ctx7` CLI | Documentation fallback | no [VERIFIED: command output] | N/A | Use official Apple URLs and installed Xcode SDK headers. [VERIFIED: command output] |
| `slopcheck` | Package legitimacy gate | no [VERIFIED: command output] | N/A | Not needed because no external packages are recommended. [VERIFIED: BeautySDK/Package.swift] |

**Missing dependencies with no fallback:**

- None that blocks writing the plan. [VERIFIED: environment audit]

**Missing dependencies with fallback:**

- CoreSimulatorService was unavailable; fallback is deterministic XCTest planning plus explicit simulator discovery/build/test tasks during execution. [VERIFIED: command output] [VERIFIED: AGENTS.md]
- `ctx7` was unavailable; fallback is official Apple documentation URLs plus local Xcode SDK headers/swiftinterfaces. [VERIFIED: command output] [VERIFIED: Xcode SDK headers]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest through Xcode project for Demo tests and SwiftPM XCTest for SDK tests. [VERIFIED: BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift] [VERIFIED: BeautySDK/Package.swift] |
| Config file | Xcode project `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`; SwiftPM `BeautySDK/Package.swift`. [VERIFIED: codebase grep] |
| Quick run command | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=<Simulator Name>,OS=<OS Version>' test` after simulator discovery. [VERIFIED: AGENTS.md] |
| Full suite command | `swift test --package-path BeautySDK` plus Demo simulator `xcodebuild ... test` plus static scans from `QUALITY_SCORE.md`. [VERIFIED: QUALITY_SCORE.md] |

Note: In this session, `swift test --package-path BeautySDK --list-tests` failed under sandbox due SwiftPM cache/sandbox issues, and `xcrun simctl list devices available` failed because CoreSimulatorService was unavailable. [VERIFIED: command output]

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| PIPE-01 | Permission state maps `notDetermined`, request result, denied/restricted, unavailable, and authorized running. [VERIFIED: SECURITY.md] | unit/view-state with injectable permission client | `xcodebuild ... -only-testing:BeautyDemoTests/CameraPermissionStateTests test` | No, Wave 0 gap. [VERIFIED: rg --files BeautyDemo/BeautyDemoTests] |
| PIPE-01 | `AVCaptureVideoDataOutput` delegate receives sample buffers and extracts `CVPixelBuffer`. [VERIFIED: Xcode SDK headers] | integration/unit with fake frame source where possible | `xcodebuild ... -only-testing:BeautyDemoTests/CameraSessionControllerTests test` | No, Wave 0 gap. [VERIFIED: rg --files BeautyDemo/BeautyDemoTests] |
| PIPE-02 | Realtime pipeline calls `BeautyEngine.process(pixelBuffer:)` without `UIImage`. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] | unit/static scan | `rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo` | Static scan exists in QUALITY_SCORE, test file gap. [VERIFIED: QUALITY_SCORE.md] |
| PIPE-03 | In-flight frame count is bounded and stale frames are dropped/counted. [VERIFIED: RELIABILITY.md] | unit | `xcodebuild ... -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | No, Wave 0 gap. [VERIFIED: rg --files BeautyDemo/BeautyDemoTests] |
| PIPE-04 | Photo fixture and picker-loaded image call `BeautyEngine.process(image:)`; cancellation is no-op; decode failure preserves previous visual. [VERIFIED: 03-CONTEXT.md] | unit/view-state | `xcodebuild ... -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` | No, Wave 0 gap. [VERIFIED: rg --files BeautyDemo/BeautyDemoTests] |
| PIPE-06 | Shared compare toggles input/output only and preserves parameters/mode/category/subcategory. [VERIFIED: 03-UI-SPEC.md] | view-state | `xcodebuild ... -only-testing:BeautyDemoTests/CompareStateTests test` | No, Wave 0 gap. [VERIFIED: rg --files BeautyDemo/BeautyDemoTests] |
| PIPE-08 | Generated Info.plist contains camera/photo purpose strings and user copy is local-first. [VERIFIED: SECURITY.md] | project-file unit/static scan | `rg -n "NSCameraUsageDescription|NSPhotoLibraryUsageDescription" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | No test file; static scan currently fails to find keys. [VERIFIED: command output] |
| DEMO-01 | First screen offers enabled Camera and Photo modes. [VERIFIED: .planning/REQUIREMENTS.md] | view-state | `xcodebuild ... -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test` | Existing file must be updated. [VERIFIED: BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift] |

### Sampling Rate

- **Per task commit:** Run focused Demo XCTest for changed state/pipeline plus static `UIImage` and internal-import scans. [VERIFIED: QUALITY_SCORE.md]
- **Per wave merge:** Run Demo simulator `xcodebuild ... test` with explicit destination and `swift test --package-path BeautySDK` if SwiftPM environment permits. [VERIFIED: AGENTS.md] [VERIFIED: QUALITY_SCORE.md]
- **Phase gate:** Full suite green before `$gsd-verify-work`, or exact simulator/SwiftPM environment failure recorded in `PLANS.md`. [VERIFIED: AGENTS.md] [VERIFIED: PLANS.md]

### Wave 0 Gaps

- [ ] `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift` and tests for permission mapping. [VERIFIED: no current Camera directory]
- [ ] `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift` with injectable capture output/frame source seams. [VERIFIED: FRONTEND.md]
- [ ] `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` with bounded in-flight and stale-frame drop tests. [VERIFIED: RELIABILITY.md]
- [ ] `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` with fixture, loading, cancellation, stale-result, and decode-failure tests. [VERIFIED: 03-CONTEXT.md]
- [ ] `BeautyDemo/BeautyDemo/Editor/CompareState.swift` or equivalent shared preview display state tests. [VERIFIED: 03-UI-SPEC.md]
- [ ] Info.plist project-file purpose string test or static scan. [VERIFIED: SECURITY.md]

## Security Domain

Security enforcement is enabled in `.planning/config.json`. [VERIFIED: .planning/config.json]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no [VERIFIED: .planning/ROADMAP.md] | No accounts or authentication in Phase 3. [VERIFIED: .planning/ROADMAP.md] |
| V3 Session Management | no [VERIFIED: .planning/ROADMAP.md] | No server/session state in Phase 3. [VERIFIED: SECURITY.md] |
| V4 Access Control | yes [VERIFIED: SECURITY.md] | Use iOS protected-resource authorization and do not access camera before user intent. [VERIFIED: SECURITY.md] |
| V5 Input Validation | yes [VERIFIED: SECURITY.md] | Validate pixel buffers/images through SDK API; reject unsupported pixel formats and invalid image extents. [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] |
| V6 Cryptography | no [VERIFIED: .planning/ROADMAP.md] | No cryptography or network transfer in Phase 3. [VERIFIED: SECURITY.md] |
| V8 Data Protection | yes [VERIFIED: SECURITY.md] | Do not upload, persist, or log camera/photo pixels or face-adjacent data by default. [VERIFIED: SECURITY.md] |
| V9 Communications | no [VERIFIED: SECURITY.md] | SDK and Demo have no network dependency by default. [VERIFIED: SECURITY.md] |
| V14 Configuration | yes [VERIFIED: SECURITY.md] | Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` before protected-resource access. [VERIFIED: SECURITY.md] |

### Known Threat Patterns for iOS Media Input

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Unauthorized camera activation | Information Disclosure | Request camera only after Camera tap and handle denied/restricted without capture. [VERIFIED: 03-CONTEXT.md] [VERIFIED: SECURITY.md] |
| Sensitive image/path leakage in logs/UI | Information Disclosure | Use friendly UI copy and redacted `BeautyError.code` mapping; never log paths, pixels, or face geometry. [VERIFIED: SECURITY.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyError.swift] |
| Unbounded frame queue memory growth | Denial of Service | `alwaysDiscardsLateVideoFrames`, serial delegate queue, and bounded in-flight processing. [VERIFIED: Xcode SDK headers] [VERIFIED: RELIABILITY.md] |
| Unsupported pixel format passed to SDK | Tampering / DoS | Request BGRA output and rely on SDK `unsupportedPixelFormat` validation. [VERIFIED: FRONTEND.md] [VERIFIED: BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift] |
| Still-image decode failure clears user state | Reliability / Integrity | Treat cancellation as no-op and preserve previous visual on decode/process failure. [VERIFIED: 03-CONTEXT.md] |
| Permission-copy misrepresentation | Spoofing / Privacy UX | Purpose strings must mention local/on-device preview and must not imply upload or remote processing. [VERIFIED: 03-CONTEXT.md] [VERIFIED: 03-UI-SPEC.md] |

## Sources

### Primary (HIGH Confidence)

- `.planning/phases/03-realtime-and-still-input-slice/03-CONTEXT.md` - locked Phase 3 implementation decisions and scope. [VERIFIED: codebase grep]
- `.planning/phases/03-realtime-and-still-input-slice/03-UI-SPEC.md` - approved UI design/copy/state/accessibility contract. [VERIFIED: codebase grep]
- `.planning/REQUIREMENTS.md` - Phase 3 requirement IDs and traceability. [VERIFIED: codebase grep]
- `.planning/ROADMAP.md` - Phase 3 goal, success criteria, plan slots, and later-phase boundaries. [VERIFIED: codebase grep]
- `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` - repo workflow and domain contracts. [VERIFIED: codebase grep]
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`, `Support/DemoFixtures.swift`, `Panel/BeautyModeEntryView.swift`, `State/BeautyParameterStore.swift` - current Demo shell and state. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`, `Models/BeautyFrame.swift`, `Models/BeautyError.swift`, `BeautySDK/Package.swift` - current public no-op processing APIs and local package structure. [VERIFIED: codebase grep]
- Xcode 26.5 iOS SDK headers/swiftinterfaces: `AVCaptureDevice.h`, `AVCaptureVideoDataOutput.h`, `_PhotosUI_SwiftUI.swiftinterface`. [VERIFIED: Xcode SDK headers]

### Secondary (MEDIUM Confidence)

- Apple Developer Documentation `AVCaptureDevice.requestAccess(for:completionHandler:)` - official API URL checked; page content required JavaScript in browser tool. [CITED: https://developer.apple.com/documentation/avfoundation/avcapturedevice/requestaccess%28for%3Acompletionhandler%3A%29]
- Apple Developer Documentation `AVCaptureDevice.authorizationStatus(for:)` - official API URL checked; page content required JavaScript in browser tool. [CITED: https://developer.apple.com/documentation/avfoundation/avcapturedevice/authorizationstatus%28for%3A%29]
- Apple Developer Documentation `AVCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames` - official API URL checked; page content required JavaScript in browser tool. [CITED: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput/alwaysdiscardslatevideoframes]
- Apple Developer Documentation `PhotosPicker` - official API URL checked; page content required JavaScript in browser tool. [CITED: https://developer.apple.com/documentation/photosui/photospicker]
- Apple Developer Documentation `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` - official API URLs checked; page content required JavaScript in browser tool. [CITED: https://developer.apple.com/documentation/bundleresources/information-property-list/nscamerausagedescription] [CITED: https://developer.apple.com/documentation/bundleresources/information-property-list/nsphotolibraryusagedescription]

### Tertiary (LOW Confidence)

- Simulator/camera runtime behavior in the current machine state because CoreSimulatorService was unavailable during research. [ASSUMED]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH - Apple frameworks and local `BeautySDK` APIs were verified from repo files and installed Xcode SDK headers. [VERIFIED: Xcode SDK headers] [VERIFIED: BeautySDK/Package.swift]
- Architecture: HIGH - Phase decisions, root docs, and current source agree that Demo owns input orchestration and SDK internals stay UI-free. [VERIFIED: 03-CONTEXT.md] [VERIFIED: ARCHITECTURE.md]
- Pitfalls: HIGH for repo-specific pitfalls; MEDIUM for Apple prose because online docs were JS shells and exact details came from installed SDK headers. [VERIFIED: codebase grep] [VERIFIED: Xcode SDK headers] [CITED: developer.apple.com]
- Validation: MEDIUM - existing XCTest style is clear, but simulator and SwiftPM commands hit sandbox/service issues in this session. [VERIFIED: command output]

**Research date:** 2026-06-12 [VERIFIED: system date]
**Valid until:** 2026-07-12 for repo contracts if Phase 3 planning starts immediately; re-check Apple SDK docs and simulator availability if Xcode or deployment target changes. [ASSUMED]
