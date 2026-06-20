# FRONTEND.md

> `beauty` 的 iOS Demo / App 层开发规约。本文只约束 SwiftUI、预览、交互状态与 App 侧编排。
> SDK 包边界看 `ARCHITECTURE.md`，核心模型看 `DESIGN.md`。

## 1. Scope

`BeautyDemo` 是 SDK 集成体验的验证 App，不是 SDK 本体。

Demo App 负责：

- 相机预览与相册入口。
- 参数滑杆、分类面板、预设面板。
- 前后对比、调试 overlay、性能信息展示。
- 把 UI 状态转换为 `BeautyParameters`。
- 调用 `BeautyEngine` 并展示结果。

Demo App 不负责：

- Metal shader 编码。
- Vision / Core ML 检测实现。
- 美颜、滤镜、五官形变算法。
- SDK 资源包解析与校验。
- 直接访问 SDK 内部 Target。

## 2. UI Invariants

| ID | Invariant | Check |
| --- | --- | --- |
| F1 | View 不直接操作 Metal、Vision 或 Effect 内部对象。 | 搜索 View 文件中是否出现 `MTL`, `VN`, `FaceWarp`, `RenderPass`。 |
| F2 | Demo 只 import `BeautySDK`，不 import 内部 Target。 | 搜索 `import BeautyCore` 等内部模块。 |
| F3 | UI 显示值与 SDK 参数值明确分层。 | 滑杆显示 0...100 或 -100...100，进入 SDK 前归一化。 |
| F4 | 相机和渲染工作不阻塞主线程。 | View 只驱动状态，耗时工作在 pipeline / engine。 |
| F5 | 互斥页面状态用 enum，不用多个 Boolean。 | sheet、panel、mode 使用单一来源状态。 |
| F6 | 每个交互控件有默认值、重置和可测试标识。 | UI 测试或预览可定位。 |
| F7 | Debug UI 不能改变 SDK 输出结果。 | overlay 只读状态和指标。 |

## 3. Recommended Directory

当前仓库只有最小 SwiftUI 模板。Demo 扩展时使用以下目录：

```text
BeautyDemo/BeautyDemo/
├── App/
│   └── BeautyDemoApp.swift
├── Camera/
│   ├── CameraView.swift
│   ├── CameraViewModel.swift
│   ├── CameraSessionController.swift
│   ├── MetalPreviewView.swift
│   └── CameraBeautyPipeline.swift
├── Editor/
│   ├── ImageEditorView.swift
│   ├── ImageEditorViewModel.swift
│   └── CompareView.swift
├── Panel/
│   ├── BeautyPanelView.swift
│   ├── BeautyCategoryView.swift
│   ├── BeautySliderView.swift
│   └── BeautyPresetView.swift
├── State/
│   ├── BeautyParameterStore.swift
│   └── BeautyPresetStore.swift
├── Debug/
│   ├── LandmarkDebugOverlay.swift
│   └── PerformanceOverlay.swift
└── Support/
    ├── DemoFixtures.swift
    └── PreviewMocks.swift
```

Rules:

- `App/` owns app shell and dependency wiring.
- `Camera/` owns realtime preview and camera session lifecycle.
- `Editor/` owns still image editing.
- `Panel/` owns controls only; it does not know camera internals.
- `State/` owns app-side value state and stores.
- `Debug/` owns read-only overlays.
- `Support/` owns preview and test fixtures.

## 4. Boundary Flow

Allowed flow:

```text
SwiftUI View
→ ViewModel or local @State
→ CameraBeautyPipeline / ImageEditorPipeline
→ BeautyEngine
→ Rendered output
→ Preview / Editor display
```

Forbidden flow:

```text
SwiftUI View → MTLCommandBuffer
SwiftUI View → VisionFaceDetector
SwiftUI View → FaceWarpEffect
BeautyPanelView → CameraSessionController internals
DebugOverlay → mutate BeautyParameters
```

## 5. State Ownership

Use the narrowest state tool that matches ownership.

| State | Owner | Preferred SwiftUI Pattern |
| --- | --- | --- |
| Selected tab or mode | App shell | `@State` enum |
| Active panel category | Panel parent | `@State` enum + `@Binding` to children |
| Slider drag value | Slider row | local `@State` during drag, commit to binding |
| Current SDK parameters | `BeautyParameterStore` | `@Observable` on iOS 17+, `ObservableObject` fallback |
| Selected preset | `BeautyPresetStore` | value ID + resolved preset |
| Camera permission | `CameraViewModel` | async state enum |
| Camera running state | `CameraSessionController` | isolated controller, surfaced as read-only UI state |
| Processing state | Pipeline / ViewModel | enum: idle, warmingUp, running, paused, failed |
| Debug metrics | Pipeline metrics collector | read-only observed model |

Rules:

- Prefer value state for UI choices.
- Do not introduce a reference ViewModel when local `@State` and bindings are enough.
- Shared services belong in environment or explicit initializer injection.
- `@EnvironmentObject` is only for genuinely app-wide state.
- For iOS 16 support, use `ObservableObject` with `@StateObject` at the ownership root.

## 6. Navigation and Presentation

Demo App modes:

```swift
enum DemoMode: Hashable {
    case camera
    case editor
    case settings
}
```

Panels:

```swift
enum BeautyPanel: Identifiable {
    case skin
    case face
    case eyes
    case nose
    case mouth
    case filter
    case preset
}
```

Rules:

- Use enum-driven state for sheets, dialogs, panels, and alerts.
- Prefer `.sheet(item:)` when the sheet represents a selected item.
- Avoid parallel Boolean flags such as `isSkinOpen`, `isFilterOpen`, `isPresetOpen`.
- Navigation should not reset camera or parameter state unless the user explicitly resets.
- A modal must own its dismiss action via SwiftUI `dismiss()` when possible.

## 7. Parameter UI

UI ranges:

| SDK Parameter Type | UI Range | SDK Range |
| --- | --- | --- |
| Enhancement | `0...100` | `0.0...1.0` |
| Bidirectional | `-100...100` | `-1.0...1.0` |
| Toggle | on/off | `Bool` |
| Resource | selected label | resource ID |

Conversion:

```swift
let sdkValue = uiValue / 100.0
```

Rules:

- Slider rows must display label, current value, reset control, and default state.
- Slider drag updates should be debounced only when needed for performance.
- Final committed value must be clamped before creating `BeautyParameters`.
- The UI cannot invent parameters not present in `DESIGN.md`.
- Category ordering should match product flow, not internal Target order.
- Preset application replaces or merges a full `BeautyParameters` snapshot deterministically.

## 8. Required Controls

First useful Demo should include:

| Area | Required Controls |
| --- | --- |
| Camera | start/stop, front/back camera, permission state, preview |
| Preview | before/after compare, debug overlay toggle |
| Skin | smoothing, whitening, rosy, sharpen |
| Color | brightness, contrast, saturation, temperature, tint, exposure, highlight, shadow |
| Face | slim face, small face, V shape, chin |
| Eyes | eye size, distance, vertical position, tail lift |
| Nose | nose slim, wing slim, tip size, bridge |
| Mouth | size, width, smile, lip color |
| Filter | filter selection, intensity |
| Preset | natural, clear, refined, male natural, ID photo natural |

The list defines Demo expectations, not SDK implementation order. If a control maps to an unimplemented SDK parameter, it must be visibly disabled or hidden.

Phase 5 current state:

- Beauty panel exposes compact preset chips for `Natural`, `Clear`, `Refined`, `Male Natural`, and `ID Photo Natural`.
- Color controls are visible in the Beauty panel and map to public `BeautyParameters`; Phase 5 remains no-op visually until render passes are implemented.
- Filters is an enabled top-level panel with `None`, `Soft Clean`, `Warm Light`, and `Filter Intensity`.
- Preset and filter data comes through `BeautySDKResources`; Demo source and tests must not import internal SDK targets.
- Resource failures use fixed friendly copy and must not show raw paths, `NSError`, bundle details, or internal target names.

## 9. Camera Preview

Camera preview responsibilities:

- Request camera permission.
- Configure session inputs and outputs.
- Feed frames into `CameraBeautyPipeline`.
- Display processed output in `MetalPreviewView` or equivalent.
- Surface recoverable errors to the UI.
- Provide the correct `CGImagePropertyOrientation` for each frame.

Rules:

- `CameraView` does not own `AVCaptureSession` details directly.
- `CameraSessionController` owns capture session setup and teardown.
- First version camera output should request `kCVPixelFormatType_32BGRA`.
- `CameraBeautyPipeline` owns SDK invocation and frame backpressure policy.
- `MetalPreviewView` is a thin platform bridge for display only.
- Dropping frames is acceptable under load; blocking the main thread is not.
- `AVCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames` or an equivalent policy should be enabled for realtime preview.
- Camera lifecycle must respond to app foreground/background transitions.
- `CameraPreviewFrame` carries `BeautyInputMetadata`; camera defaults are source `.camera`, orientation `.right`, input mirrored false, and preview mirrored true for front-camera display.
- `CameraProcessingSnapshot` carries `BeautyDetectionSummary?` from `BeautyResult`, not Vision observations or face geometry.
- `DetectionStatusDebouncer` owns transient camera status copy and holds warning text for three processed frames before clearing or replacing it.

## 10. Image Editor

Still image editor responsibilities:

- Import image from fixture, photo picker, or test asset.
- Normalize orientation before sending to SDK.
- Apply parameter snapshots.
- Support before/after compare.
- Export or display processed result.

Rules:

- Do not route still image editing through camera-only state.
- Editor state is independent from camera session state.
- Large image processing must show loading or progress state.
- `ImageProcessingSnapshot` carries `BeautyInputMetadata` and `BeautyDetectionSummary?`; photo input defaults to source `.photo` and no mirroring unless the import path explicitly says otherwise.
- Photo detection status persists with the processed image until the next successful image result replaces it.
- Export behavior belongs to product and reliability docs before implementation.

## 11. Async and Concurrency

Use explicit async UI states:

```swift
enum AsyncViewState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}
```

Rules:

- Use `.task` or `.task(id:)` for lifecycle-bound async work.
- Cancel in-flight work when inputs change and stale output would be misleading.
- Permission checks, session start, resource loading, and image processing need explicit loading/error states.
- View `body` must not create long-running work.
- UI state updates happen on the main actor.
- Pipeline and SDK work happen outside main actor unless the API explicitly requires main actor.
- If the SDK call is synchronous, `CameraBeautyPipeline` still runs it on the capture/processing queue with bounded in-flight frames.

## 12. Performance Rules

| Concern | Rule |
| --- | --- |
| Slider spam | Coalesce updates if realtime render cannot keep up. |
| View invalidation | Keep frequently changing metrics out of broad parent views. |
| Preview | Avoid rebuilding Metal bridge on every slider change. |
| Lists and panels | Use stable IDs and small subviews. |
| Debug overlay | Refresh at a capped rate. |
| Large images | Process off main thread and surface progress. |

The UI may reduce update frequency under load, but must not silently desync displayed values from the active parameter snapshot.

## 13. Accessibility

Rules:

- Every interactive control has an accessibility label.
- Sliders expose meaningful value text, not only raw percentages.
- Compare mode must be reachable without gesture-only interaction.
- Disabled controls explain unavailable state with label or hint.
- Debug-only controls can be hidden from accessibility when not useful to users.
- Dynamic Type should not cause controls to overlap or truncate critical values.

## 14. Preview and Fixtures

Every non-trivial view should have previews for:

- Default state.
- Loading state.
- Error state.
- Disabled/unimplemented SDK state.
- High intensity parameter state.

Fixture rules:

- Do not use live camera in previews.
- Use deterministic image and parameter fixtures.
- Mock `BeautyEngine` or pipeline interfaces for previews.
- Preview fixtures live under `Support/` or test support files.

## 15. Error UI

UI error categories:

| Error | UI Behavior |
| --- | --- |
| Camera permission denied | Show actionable permission state. |
| Camera unavailable | Show non-camera editor path when possible. |
| SDK initialization failed | Show retry/reset and diagnostic detail in debug mode. |
| Processing failed for frame | Keep preview alive if possible and show non-blocking warning. |
| No face detected | Keep controls enabled and show `No face detected. Face adjustments are paused.` |
| Partial or low-confidence face | Keep output alive and show softened-adjustment copy. |
| Stale face reading | Keep last usable preview and show waiting-for-fresh-reading copy. |
| Resource missing | Disable affected preset/filter and show fallback. |

Rules:

- Never crash the Demo for recoverable SDK errors.
- Do not expose raw internal stack traces in user-facing UI.
- Debug mode may show diagnostic details from `RELIABILITY.md`.
- Detection debug UI may show availability, reason codes, counts, and timings only; it must not show bounding boxes, landmarks, raw Vision objects, raw errors, or local paths.

## 16. UI Testing Contracts

Minimum testable contracts:

| Contract | Verification |
| --- | --- |
| Demo launches into a stable initial mode. | UI test or snapshot smoke test. |
| Slider value maps to expected SDK value. | Unit test for conversion. |
| Reset returns controls to default parameter values. | Unit or UI test. |
| Preset application updates all relevant controls. | Store test. |
| Before/after compare toggles output source without resetting parameters. | UI test. |
| Unavailable SDK features are disabled or hidden. | View state test. |
| Camera permission denied state is visible and non-crashing. | Mocked UI test. |

If UI tests are not yet available, keep these as acceptance checks in `PLANS.md`.

Phase 3 input evidence recorded 2026-06-12:

- `EditorShellView` remains the first screen and exposes enabled Camera / Photo mode switches.
- Camera state covers not-determined, requesting, denied/restricted, unavailable, and running preview states without hiding the parameter shell.
- Photo state covers empty, loading, loaded, failed, and cancellation paths; loading and recoverable failures preserve the previous visual state.
- Camera and Photo share display-only before/after compare labels: `Show After` and `Show Before`.
- XCTest coverage: `BeautyDemoViewStateTests.testPhase3InputStateMatrixCoversPIPE01PIPE04PIPE06PIPE08AndDEMO01`, `CompareStateTests`, and `InputPipelinePrivacyTests`.

Phase 4 detection/metadata evidence recorded 2026-06-18:

- Camera and Photo snapshots pass `BeautyInputMetadata` through the public `BeautySDK` facade into metadata-aware `BeautyEngine.processResult(...)` calls.
- Demo status copy is centralized in `DetectionStatusPresentation`; sliders remain enabled while face-dependent output degrades.
- `InputPipelinePrivacyTests` scans Demo code and detection status/debug summaries for internal Target imports, raw Vision objects, public geometry, raw framework errors, and local paths.

## 17. Implementation Checklist

Before merging a Demo UI change:

- The changed view has a clear state owner.
- No View directly imports or manipulates SDK internals.
- Long-running work is outside `body`.
- Sliders clamp and normalize values.
- Loading, error, and disabled states are represented.
- Previews or fixtures cover the main states.
- Accessibility labels exist for new controls.
- Build or equivalent compile verification is recorded.
