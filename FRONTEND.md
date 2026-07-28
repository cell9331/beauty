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
| F8 | 已停止或已切换模式的相机会话不能被迟到的异步配置结果重新启动。 | session start 使用可失效 lifecycle generation；stop 必须同步撤销未完成 start。 |

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
- Color controls are visible in the Beauty panel and map to public `BeautyParameters`; Phase 6 routes them through visible SDK output.
- Filters is an enabled top-level panel with `None`, `Soft Clean`, `Warm Light`, and `Filter Intensity`.
- Preset and filter data comes through `BeautySDKResources`; Demo source and tests must not import internal SDK targets.
- Resource failures use fixed friendly copy and must not show raw paths, `NSError`, bundle details, or internal target names.

Phase 6 current state:

- Normal slider, filter, preset, single-reset, and reset-all changes keep `BeautyParameterStore.status` at `.idle`; the old pending-visual Phase 6 copy is not active product copy.
- Detection and degradation feedback remains centralized in `DetectionStatusPresentation`; no cap banners, per-slider warning rows, or internal provider details are shown in normal UI.
- Focused view-state tests cover Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets paths without changing category or subcategory ordering.

Phase 7 current state:

- The preview toolbar includes `Show Before` / `Show After`, `Show Debug Details` / `Hide Debug Details`, and `Parameter JSON` without changing compare labels.
- `Parameter JSON` opens a copy/paste-only sheet with Import and Export modes. Import previews a schemaVersion 1 payload before Apply; failed previews leave current settings unchanged. Export copies a deterministic `schemaVersion` plus `parameters` payload.
- `BeautyParameterStore` tracks custom, preset, and imported source state. Single reset returns one control to SDK default, reset all returns to `BeautyParameters()`, and manual slider/filter edits clear applied preset/import source.
- `PreviewDebugOverlayView` is read-only and displays only safe value rows from public detection summaries, warning counts, redacted recoverable error codes, and friendly status copy.
- Future categories and facial-feature subcategories remain visible, disabled, ordered, and marked `Not in v1`; no extra info route or active future-domain controls were added.

Phase v1.1 Meitu UI current state:

- `ContentView` launches into `MeituHomeView` by default. The previous editor shell remains reachable through Home actions and launch-only verification arguments.
- Home is organized around `meituxiuxiu/HOME_MAP.md`: dark background, retro film hero, search/brand/VIP chrome, `拍一拍`, brown primary action hierarchy, paged tool grid, recommendation rails, floating bottom tabs, and sticky shortcut rail.
- Supported Home routes are limited to existing local flows: `图片美化` opens photo mode, `相机` and `拍一拍` open camera mode, and `人像美容` opens the photo-backed beauty editor. `修视频`, `拼图`, `视频美容`, AI, VIP, and tab/detail flows are static or disabled in v1.1.
- `EditorShellView` uses a Meitu-style black preview area plus white `MeituEditorToolPanelView` bottom sheet while preserving existing camera/photo processing, compare, debug, and Parameter JSON state.
- The editor tool taxonomy follows `meituxiuxiu/FUNCTION_MAP.md` in first-level order: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`. Supported tools map to existing `BeautyControlID`; unsupported tools remain visible with disabled/static `限免`, `Pro`, or `OFF` treatment.
- Cancel restores the last confirmed `BeautyParameters` snapshot through `BeautyParameterStore.restoreCustomParameters(_:)`; confirm updates the snapshot without resetting preview, compare state, or input mode.
- Launch-only visual evidence hooks are `--beauty-demo-route editor-photo|editor-camera|editor-beauty` and `--beauty-demo-home-sticky`; normal launch still starts at Home.

Phase 20 editor-shell closeout current state:

- Existing Demo editor support owns app-side interaction state for input routing, preview chrome, category rail, tool rail, sliders, compare/debug, cancel/confirm, and parameter snapshot behavior.
- Demo imports only the public `BeautySDK` facade. Editor state may construct `BeautyParameters` snapshots and read public result/debug summaries, but it must not import SDK internal targets or own SDK algorithm state.
- Normal Phase 20 closeout does not add new SwiftUI screens, routes, tool-panel behavior, app-state behavior, public parameters, renderer cases, export flow, or media transfer behavior.
- Release-like visual naturalness, real-device Vision parity, simulator screenshot/UI automation, performance budgets, and long-run checks remain release-hardening risks, not Phase 20 editor acceptance gates.

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

Phase 6 Demo feedback evidence recorded 2026-06-22:

- `BeautyParameterStoreTests` verifies normal parameter changes no longer surface pending-Phase-6 copy.
- `BeautyDemoViewStateTests` verifies existing category order plus Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets panel paths.
- `InputPipelinePrivacyTests` scans active Demo panel/state source for stale Phase 6 pending copy and raw resource/privacy tokens.

Phase 7 Demo QA evidence recorded 2026-06-23:

- Focused `xcodebuild` coverage for `BeautyParameterStoreTests`, `ParameterJSONCodingTests`, `BeautyDemoViewStateTests`, `CompareStateTests`, `InputPipelinePrivacyTests`, and `BeautyDemoImportBoundaryTests` passed on iPhone 17 iOS 26.5.
- Full Demo simulator tests passed on iPhone 17 iOS 26.5 after updating stale unavailable-copy test expectations to the Phase 7 `Not in v1` contract.
- `InputPipelinePrivacyTests` and active-surface `rg` scans cover copy/paste JSON, preview-before-apply, raw JSON non-echo, debug redaction, facade-only imports, and no file/network JSON scope creep.
- Simulator screenshot/UI automation was not run; visual layout, Dynamic Type overlap, and manual naturalness remain release-risk checks rather than pass evidence.

Phase v1.1 Meitu UI evidence recorded 2026-06-24:

- `BeautyDemoViewStateTests` covers Home hierarchy, supported/disabled Home routes, launch-only screenshot arguments, editor taxonomy, supported tool-to-parameter mappings, disabled tool honesty, shared slider state, and cancel restore behavior.
- Full Demo simulator tests passed on iPhone 17 iOS 26.5 after the Home/editor rewrite, and the full SDK SwiftPM suite still passed with 119 tests.
- Facade boundary scan `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- Screenshot-backed visual evidence is stored in `.planning/evidence/v1.1/home-first-screen.png`, `.planning/evidence/v1.1/home-sticky-state.png`, and `.planning/evidence/v1.1/editor-tool-panel.png`.
- v1.1 does not claim full commercial Meitu feature parity, exact commercial assets, real video editing, network AI generation, VIP entitlement logic, or new SDK algorithm families.

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
