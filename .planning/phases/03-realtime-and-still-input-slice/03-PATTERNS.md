# Phase 03: Realtime and Still Input Slice - Pattern Map

**Mapped:** 2026-06-12
**Files analyzed:** 22 new/modified files inferred from `03-CONTEXT.md`, `03-RESEARCH.md`, and `03-*-PLAN.md`
**Analogs found:** 22 / 22

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | config | request-response | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | exact |
| `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` | component | event-driven | `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` | exact |
| `BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift` | component | event-driven | `BeautyDemo/BeautyDemo/Panel/BeautyCategoryRailView.swift` | role-match |
| `BeautyDemo/BeautyDemo/Editor/CompareState.swift` | model | transform | `BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift` | role-match |
| `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` | model | file-I/O | `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift` | role-match |
| `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` | service | file-I/O | `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` | data-flow-match |
| `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift` | service | request-response | `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` | partial |
| `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift` | service | streaming | `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift` | data-flow-match |
| `BeautyDemo/BeautyDemo/Camera/CameraPreviewLayerView.swift` | component | streaming | `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` | role-match |
| `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` | service | streaming | `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` | data-flow-match |
| `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` | model | streaming | `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift` | role-match |
| `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` | store | transform | `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` | exact |
| `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` | utility | transform | `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` | exact |
| `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` | test | transform | `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` | exact |
| `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` | test | transform | `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` | exact |
| `BeautyDemo/BeautyDemoTests/CameraPermissionStateTests.swift` | test | request-response | `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` | role-match |
| `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` | test | streaming | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | role-match |
| `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` | test | streaming | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | role-match |
| `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` | test | transform | `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` | role-match |
| `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` | test | file-I/O | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | role-match |
| `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` | test | transform | `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` | exact |
| `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | test | transform | `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` | role-match |

## Pattern Assignments

## Additional Exact File Analogs

The planner references four files that were added after the initial pattern-map pass. Their execution patterns are:

| File | Apply This Analog |
|------|-------------------|
| `BeautyDemo/BeautyDemo/Camera/CameraPreviewLayerView.swift` | Follow `EditorShellView` preview-surface constraints: keep the white rounded preview card as the containing surface, expose SwiftUI accessibility at the shell level, and keep UIKit/AVFoundation bridge code thin and Demo-owned. |
| `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` | Follow `BeautyEngineTests` media-fixture style for pixel-buffer assertions and `BeautyDemoViewStateTests` deterministic state style; do not require real camera hardware for unit coverage. |
| `BeautyDemo/BeautyDemoTests/CompareStateTests.swift` | Follow `BeautyParameterStoreTests` value-state assertions: deterministic inputs, no simulator UI automation, and explicit preservation checks for parameters and selection state. |
| `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | Follow `BeautyDemoImportBoundaryTests` source-scan pattern: inspect repository files for forbidden imports/copy/network tokens and exact purpose-string evidence. |

### `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` (config, request-response)

**Analog:** `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`

**Generated Info.plist build setting pattern** (lines 336-347 and 367-378):
```text
GENERATE_INFOPLIST_FILE = YES;
INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
INFOPLIST_KEY_UILaunchScreen_Generation = YES;
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "...";
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "...";
```

**Apply for Phase 3:** add `INFOPLIST_KEY_NSCameraUsageDescription` and `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` beside the existing generated Info.plist keys in both Debug and Release. Copy strings from `03-UI-SPEC.md`: `Use the camera to preview beauty processing on this device.` and `Select photos to preview beauty processing on this device.`

---

### `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` (component, event-driven)

**Analog:** `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`

**Imports and ownership pattern** (lines 1-8):
```swift
import BeautySDK
import SwiftUI

struct EditorShellView: View {
    @StateObject private var parameterStore = BeautyParameterStore()
    @State private var selectedCategoryID: BeautyCategoryID = .beauty
    @State private var selectedSubcategoryID: FacialFeatureSubcategoryID = .eyes
```

**Shell composition pattern** (lines 9-23):
```swift
VStack(spacing: 16) {
    modeHeader
    previewFixture
    BeautyPanelView(
        selectedCategoryID: selectedCategoryID,
        selectedSubcategoryID: $selectedSubcategoryID,
        parameterStore: parameterStore
    )
    BeautyCategoryRailView(selectedCategoryID: $selectedCategoryID)
}
.padding(16)
.frame(maxWidth: .infinity, maxHeight: .infinity)
```

**Preview surface pattern** (lines 33-55):
```swift
ZStack {
    RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    ...
}
.frame(maxWidth: .infinity)
.frame(minHeight: 320)
.accessibilityElement(children: .combine)
```

**Apply for Phase 3:** keep the shell as the first screen; replace `previewFixture` with enum-driven preview state for initial, camera permission, camera live/unavailable, photo empty/loading/loaded/failed, and compare. Do not reset `selectedCategoryID`, `selectedSubcategoryID`, or `parameterStore` on mode changes.

---

### `BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift` (component, event-driven)

**Analog:** `BeautyDemo/BeautyDemo/Panel/BeautyCategoryRailView.swift`

**Binding-driven selection pattern** (lines 10-20 and 31-45):
```swift
struct BeautyCategoryRailView: View {
    private let categories: [BeautyCategory]
    @Binding private var selectedCategoryID: BeautyCategoryID
    ...
    Button {
        selectedCategoryID = item.id
    } label: {
        Text(item.title)
            .font(.system(size: 13, weight: item.isSelected ? .semibold : .regular))
            .foregroundStyle(foregroundColor(for: item))
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(backgroundColor(for: item))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(item.title)
    .accessibilityHint(item.availability.badge ?? "")
    .accessibilityAddTraits(item.isSelected ? .isSelected : [])
```

**Current mode-entry shape to evolve** (lines 3-24):
```swift
struct BeautyModeEntryView: View {
    let mode: DisabledMode

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 8) {
                Image(systemName: mode.title == "Camera" ? "camera" : "photo")
                ...
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .disabled(true)
        .accessibilityLabel(mode.title)
        .accessibilityHint(mode.badge)
    }
}
```

**Apply for Phase 3:** replace `DisabledMode` input with enabled mode item state containing `id`, title, icon, selected state, and optional status. Keep 44pt minimum target and selected accessibility trait. The action should update shell mode; camera permission request remains shell/controller-owned, not owned by this component.

---

### `BeautyDemo/BeautyDemo/Editor/CompareState.swift` (model, transform)

**Analog:** `BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift`

**Value view-state pattern** (lines 10-18 and 65-69):
```swift
struct BeautyPanelViewState: Equatable {
    let category: BeautyCategory
    let activeAvailability: BeautyAvailability
    let subcategories: [BeautySubcategoryRailItem]
    let controls: [BeautyControlDescriptor]
    let disabledControls: [BeautyControlDescriptor]
    let showsResetAll: Bool
    let status: BeautyParameterStatus
}

static func viewState(
    categoryID: BeautyCategoryID,
    selectedSubcategoryID: FacialFeatureSubcategoryID,
    status: BeautyParameterStatus
) -> BeautyPanelViewState {
```

**Apply for Phase 3:** model compare as a small `Equatable` value (`after` / `before` or boolean wrapper). It should be display-only and should not depend on or mutate `BeautyParameterStore`, category, subcategory, orientation, crop, or selected media.

---

### `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` (model, file-I/O)

**Analog:** `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift`

**Public media metadata pattern** (lines 6-21):
```swift
public struct BeautyFrame {
    public enum Source: String, Codable, Equatable, Sendable {
        case camera
        case photo
        case video
        case export
        case testFixture
    }

    public let pixelBuffer: CVPixelBuffer
    public let orientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
    public let isPreviewMirrored: Bool
    public let timestamp: TimeInterval?
    public let source: Source
    public let extent: CGSize
```

**Initializer defaulting pattern** (lines 23-41):
```swift
public init(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    isInputMirrored: Bool = false,
    isPreviewMirrored: Bool = false,
    timestamp: TimeInterval? = nil,
    source: Source,
    extent: CGSize? = nil
) {
    ...
    self.extent = extent ?? CGSize(
        width: CVPixelBufferGetWidth(pixelBuffer),
        height: CVPixelBufferGetHeight(pixelBuffer)
    )
}
```

**Apply for Phase 3:** use explicit source cases for photo picker and deterministic fixture. Keep orientation explicit and keep input/output references paired so compare can switch display without reprocessing.

---

### `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` (service, file-I/O)

**Analog:** `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`

**Still-image process contract** (lines 27-39):
```swift
public func process(
    image: CIImage,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CIImage {
    _ = orientation
    _ = parameters.normalized()
    guard image.extent.isFiniteAndNonEmpty else {
        throw BeautyError.invalidInput
    }
    return image.cropped(to: image.extent)
}
```

**Parameter snapshot source** (`BeautyParameterStore.swift`, lines 37-47):
```swift
var parametersSnapshot: BeautyParameters {
    var parameters = BeautyParameters()

    for descriptor in descriptors where descriptor.availability.isEnabled {
        guard let key = descriptor.parameterKey else {
            continue
        }

        let normalizedValue = descriptor.displayRange.normalizedValue(displayValue(for: descriptor))
```

**Apply for Phase 3:** load/decode selected photo data off main actor, create `CIImage`, read the latest `parametersSnapshot`, call `BeautyEngine.process(image:orientation:parameters:)`, and publish success/failure back to UI state. Picker cancellation is a no-op; decode/process failure preserves previous input/output and maps to friendly copy.

---

### `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift` (service, request-response)

**Analog:** `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`

**Main-actor observable state pattern** (lines 20-35):
```swift
@MainActor
final class BeautyParameterStore: ObservableObject {
    @Published private(set) var displayValues: [BeautyControlID: Double]
    @Published private(set) var status: BeautyParameterStatus

    private let descriptors: [BeautyControlDescriptor]

    init(descriptors: [BeautyControlDescriptor]? = nil) {
        ...
        self.status = .idle
    }
}
```

**Apply for Phase 3:** expose permission as injectable app-layer state (`notDetermined`, `requesting`, `authorized`, `denied`, `restricted`, `unavailable`). UI updates after `AVCaptureDevice.requestAccess` must return to the main actor. Do not let the SDK request protected-resource access.

---

### `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift` (service, streaming)

**Analog:** `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift`

**Frame metadata fields** (lines 15-21):
```swift
public let pixelBuffer: CVPixelBuffer
public let orientation: CGImagePropertyOrientation
public let isInputMirrored: Bool
public let isPreviewMirrored: Bool
public let timestamp: TimeInterval?
public let source: Source
public let extent: CGSize
```

**Apply for Phase 3:** configure `AVCaptureSession` and `AVCaptureVideoDataOutput` in a controller, emit BGRA `CVPixelBuffer` plus explicit orientation/timestamp/source metadata to the pipeline. Keep capture setup errors typed at the Demo layer and mapped to preview unavailable copy.

---

### `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` (service, streaming)

**Analog:** `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`

**Realtime SDK call pattern** (lines 15-25):
```swift
public func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CVPixelBuffer {
    _ = orientation
    _ = parameters.normalized()
    try Self.validate(pixelBuffer: pixelBuffer)
    return try Self.makeCopiedBGRAOutput(from: pixelBuffer)
}
```

**Pixel-buffer validation and typed error pattern** (lines 49-57):
```swift
private static func validate(pixelBuffer: CVPixelBuffer) throws {
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    guard width > 0, height > 0 else {
        throw BeautyError.invalidInput
    }
    guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
        throw BeautyError.unsupportedPixelFormat
    }
}
```

**Apply for Phase 3:** keep processing outside SwiftUI `body`, use a serial queue or isolated worker, bound in-flight frames to 1 or 2, drop/replace stale pending frames, and use latest parameter snapshots. Tests should assert stale frame drops and no `UIImage` usage.

---

### `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` (model, streaming)

**Analog:** `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift`

**Source enum and metadata pattern** (lines 6-13 and 15-21):
```swift
public enum Source: String, Codable, Equatable, Sendable {
    case camera
    case photo
    case video
    case export
    case testFixture
}

public let pixelBuffer: CVPixelBuffer
public let orientation: CGImagePropertyOrientation
public let isInputMirrored: Bool
public let isPreviewMirrored: Bool
public let timestamp: TimeInterval?
public let source: Source
public let extent: CGSize
```

**Apply for Phase 3:** preview models should keep input/output buffers and status separately from mode/category/parameter state. Error states should preserve the last usable visual and carry friendly UI copy, not raw errors.

---

### `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` (store, transform)

**Analog:** `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`

**Snapshot transform pattern** (lines 37-47 and 90-95):
```swift
var parametersSnapshot: BeautyParameters {
    var parameters = BeautyParameters()

    for descriptor in descriptors where descriptor.availability.isEnabled {
        guard let key = descriptor.parameterKey else {
            continue
        }
        let normalizedValue = descriptor.displayRange.normalizedValue(displayValue(for: descriptor))
        ...
        case .filterId, .filterIntensity:
            break
        }
    }

    return parameters
}
```

**Mutation/status pattern** (lines 110-117):
```swift
func setDisplayValue(_ value: Double, for descriptor: BeautyControlDescriptor) {
    guard descriptor.availability.isEnabled else {
        return
    }

    displayValues[descriptor.id] = descriptor.displayRange.clampedDisplayValue(value)
    status = .appliedPendingVisual
}
```

**Apply for Phase 3:** pipelines read snapshots; they should not mutate display values. If the visual-pending status changes for realtime/photo, keep it as a lightweight status surface and preserve immediate slider display updates.

---

### `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` (utility, transform)

**Analog:** `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift`

**Fixture constant pattern** (lines 3-12):
```swift
enum DemoFixtures {
    static let previewTitle = "Preview fixture ready"
    static let previewBody = "Adjust a Beauty slider to update the SDK parameter snapshot. Visual effects arrive in later phases."
    static let activeCategoryTitle = "Beauty"
    static let visualPendingStatus = "Visual update pending Phase 6"

    static let disabledModes: [DisabledMode] = [
        DisabledMode(title: "Camera", badge: "Coming in Phase 3"),
        DisabledMode(title: "Photo", badge: "Coming in Phase 3")
    ]
}
```

**Apply for Phase 3:** update fixtures to deterministic initial/photo states and mode entries. Keep fixtures simple value data that tests can assert without launching protected resources.

---

### Demo XCTest files (test, transform/request-response/streaming/file-I/O)

**Analogs:** `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift`, `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`

**View-state XCTest style** (`BeautyDemoViewStateTests.swift`, lines 4-14):
```swift
final class BeautyDemoViewStateTests: XCTestCase {
    func testInitialCategoryRailViewStateCoversSDK08AndDEMO02() {
        let items = BeautyCategoryRailView.viewState(selectedCategoryID: .beauty)

        // SDK-08 DEMO-02
        XCTAssertEqual(
            items.map(\.title),
            ["Beauty", "Face Shape", "Facial Features", "Makeup", "Filters", "Stickers", "Background", "Style"]
        )
        XCTAssertEqual(items.filter(\.isSelected).map(\.title), ["Beauty"])
    }
}
```

**MainActor store test style** (`BeautyParameterStoreTests.swift`, lines 5-14):
```swift
@MainActor
final class BeautyParameterStoreTests: XCTestCase {
    func testEnhancementDisplayValueNormalizesIntoSDKSnapshot() {
        let store = BeautyParameterStore()

        store.setDisplayValue(75, for: .skinSmoothing)

        XCTAssertEqual(store.displayValue(for: .skinSmoothing), 75)
        XCTAssertEqual(store.parametersSnapshot.skinSmoothing, 0.75, accuracy: 0.0001)
    }
}
```

**Facade-only import-boundary style** (`BeautyDemoImportBoundaryTests.swift`, lines 1-11):
```swift
import XCTest
@testable import BeautyDemo

final class BeautyDemoImportBoundaryTests: XCTestCase {
    func testDemoTestTargetCanLoadEditorShellState() {
        XCTAssertEqual(DemoFixtures.activeCategoryTitle, "Beauty")
        XCTAssertEqual(
            DemoFixtures.disabledModes.map(\.badge),
            ["Coming in Phase 3", "Coming in Phase 3"]
        )
    }
}
```

**Pixel-buffer fixture and SDK assertion style** (`BeautyEngineTests.swift`, lines 9-21 and 59-76):
```swift
func testSDK04PixelBufferNoopPreservesPixelsInNewOutputBuffer() throws {
    let input = try PixelBufferFixtures.makeBGRA(width: 2, height: 2, bytes: [
        10, 20, 30, 255,
        40, 50, 60, 255,
        70, 80, 90, 255,
        100, 110, 120, 255
    ])
    let engine = try BeautyEngine(configuration: .default)

    let output = try engine.process(pixelBuffer: input, orientation: .up, parameters: .init())

    XCTAssertFalse(input === output)
    XCTAssertEqual(try PixelBufferFixtures.bytes(from: output), try PixelBufferFixtures.bytes(from: input))
}

enum PixelBufferFixtures {
    static func makePixelBuffer(width: Int, height: Int, pixelFormat: OSType) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
```

**Apply for Phase 3:** add focused tests for permission mapping, session/controller seams, bounded camera pipeline, photo cancellation/failure/stale behavior, compare display state, Info.plist purpose strings, and static import boundary. Demo tests should import `BeautyDemo` and only the public `BeautySDK` facade when SDK types are needed.

## Shared Patterns

### Facade-Only SDK Access
**Source:** `BeautySDK/Sources/BeautySDK/BeautySDK.swift` lines 1-10
**Apply to:** all `BeautyDemo` source and Demo tests
```swift
@_exported import BeautyCore
import BeautyRender

public enum BeautySDKModule {
    public static let name = "BeautySDK"
}
```

Demo code imports `BeautySDK`; it must not import `BeautyCore`, `BeautyRender`, `BeautyDetection`, `BeautyEffects`, or `BeautyResources` directly.

### Friendly Error Mapping
**Source:** `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` lines 17-50 and 79-89
**Apply to:** camera pipeline, photo pipeline, preview/status UI, tests
```swift
public var description: String {
    switch self {
    case .shaderFunctionNotFound(let name):
        "shaderFunctionNotFound(\(Self.redacted(name)))"
    ...
    }
}

public var errorDescription: String? {
    description
}

private static func redacted(_ value: String) -> String {
    let allowed = value.unicodeScalars.filter { scalar in
        CharacterSet.alphanumerics.contains(scalar) ||
            scalar == "." || scalar == "_" || scalar == "-"
    }
    ...
}
```

Use `BeautyError.code` or typed cases for internal assertions, but render only copy from `03-UI-SPEC.md` in the UI. Do not display raw `NSError`, file paths, framework domains, or `BeautyError.description`.

### Main-Actor UI State, Off-Main Processing
**Source:** `BeautyParameterStore.swift` lines 20-23 and `BeautyEngine.swift` lines 16-20 / 28-32
**Apply to:** camera/photo pipelines and shell state
```swift
@MainActor
final class BeautyParameterStore: ObservableObject {
    @Published private(set) var displayValues: [BeautyControlID: Double]
    @Published private(set) var status: BeautyParameterStatus
}

public func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CVPixelBuffer
```

Keep SwiftUI state on the main actor. Do synchronous SDK processing from pipeline/controller code, not in a `View.body` or broad action closure.

### Preview/Card Styling
**Source:** `EditorShellView.swift` lines 33-55
**Apply to:** initial, permission, unavailable, loading, error, photo, and live preview states
```swift
RoundedRectangle(cornerRadius: 8)
    .fill(Color.white)
    .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
...
.frame(maxWidth: .infinity)
.frame(minHeight: 320)
.accessibilityElement(children: .combine)
```

All Phase 3 preview states should reuse this single card surface so the existing editor shell stays stable.

### Bounded Realtime Pixel Format
**Source:** `PixelBufferFactory.swift` lines 5-19 and `CopyRenderPass.swift` lines 13-20
**Apply to:** camera session output and camera pipeline tests
```swift
public static let supportedPixelFormat = kCVPixelFormatType_32BGRA

let attributes: [String: Any] = [
    kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height,
    kCVPixelBufferIOSurfacePropertiesKey as String: [:]
]

guard CVPixelBufferGetPixelFormatType(pixelBuffer) == PixelBufferFactory.supportedPixelFormat else {
    throw BeautyError.unsupportedPixelFormat
}
```

Camera output should request BGRA, and tests should include unsupported-format failure assertions through the public facade or Demo seams.

## No Analog Found

All inferred files have at least a partial analog. The weakest matches are AVFoundation/PhotosUI wrappers because the repo has no current Camera directory or photo picker pipeline; planner should use `03-RESEARCH.md` code examples for exact Apple framework calls.

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| None | N/A | N/A | N/A |

## Metadata

**Analog search scope:** `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`, `BeautySDK/Sources`, `BeautySDK/Tests`, root contract docs, `03-CONTEXT.md`, `03-RESEARCH.md`, `03-UI-SPEC.md`
**Files scanned:** 39 Swift/source/project files plus phase/root docs
**Pattern extraction date:** 2026-06-12
