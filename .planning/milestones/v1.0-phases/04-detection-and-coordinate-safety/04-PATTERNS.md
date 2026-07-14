# Phase 4: Detection and Coordinate Safety - Pattern Map

**Mapped:** 2026-06-18
**Files analyzed:** 21
**Analogs found:** 21 / 21

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift` | model | transform | `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift` | exact |
| `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` | model | transform | `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` | role-match |
| `BeautySDK/Sources/BeautyCore/Models/DetectionAvailability.swift` | model | transform | `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` | role-match |
| `BeautySDK/Sources/BeautyCore/Models/DetectionDegradationReason.swift` | model | transform | `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` | role-match |
| `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` | model | transform | `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` | exact |
| `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` | service | transform | `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` | exact |
| `BeautySDK/Sources/BeautyCore/Models/FaceSelectionPolicy.swift` | utility | transform | `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` | role-match |
| `BeautySDK/Sources/BeautyDetection/BeautyDetection.swift` | module facade | transform | `BeautySDK/Sources/BeautyDetection/BeautyDetection.swift` | exact |
| `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` | utility | transform | `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` | role-match |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | service | transform | `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` | role-match |
| `BeautySDK/Package.swift` | config | build graph | `BeautySDK/Package.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyInputMetadataTests.swift` | test | assertion | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyResultDetectionSummaryTests.swift` | test | assertion | `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift` | role-match |
| `BeautySDK/Tests/BeautyCoreTests/FaceSelectionPolicyTests.swift` | test | assertion | `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` | role-match |
| `BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift` | test | assertion | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | role-match |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | test | assertion | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | role-match |
| `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` | model | streaming | `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` | exact |
| `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` | service/model | streaming | `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` | exact |
| `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` | model | file-I/O | `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` | exact |
| `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` | service/model | file-I/O | `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` | exact |
| `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` | SwiftUI component | event-driven | `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` | exact |
| `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` | test | assertion | `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` | exact |
| `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` | test | assertion | `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` | exact |
| `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | test/static scan | batch | `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | exact |

## Pattern Assignments

### `BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift` (model, transform)

**Analog:** `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift`

**Imports and shape pattern** (lines 1-21):
```swift
import CoreGraphics
import CoreVideo
import Foundation
import ImageIO

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

**Initializer pattern** (lines 23-42): default mirroring flags, optional timestamp, source required, extent derived only when the type owns a buffer. `BeautyInputMetadata` should keep the same public memberwise clarity without exposing `CVPixelBuffer`.

### Detection summary and result models (model, transform)

**Analogs:** `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`, `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift`

**Result envelope pattern** (BeautyResult lines 1-14):
```swift
public struct BeautyResult<Output: Sendable>: Sendable {
    public let output: Output
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]

    public init(
        output: Output,
        warnings: [BeautyValidationWarning] = [],
        metrics: [String: Double] = [:]
    ) {
```

**Enum/redaction pattern** (BeautyError lines 3-16, 50-76, 79-89): public enums are `Equatable`, `Sendable`, expose stable codes, and redact string payloads. Detection availability/reason models should avoid raw string parsing and not include geometry payloads.

### `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`

**Existing output-only API pattern** (lines 15-39): public `process(pixelBuffer:orientation:parameters:)` and `process(image:orientation:parameters:)` validate input, normalize parameters, and return copied/no-op output. New result-returning overloads must wrap this behavior instead of breaking compatibility.

**Pixel-buffer validation/copy pattern** (lines 49-88): pixel buffers are validated for non-empty BGRA input, then copied to SDK-owned output. Detection metadata work must preserve the typed error behavior for invalid inputs.

### `BeautySDK/Sources/BeautyDetection/BeautyDetection.swift` and `BeautySDK/Package.swift` (module/config)

**Analogs:** `BeautySDK/Sources/BeautyDetection/BeautyDetection.swift`, `BeautySDK/Package.swift`

**Detection target pattern** (BeautyDetection lines 1-5): the target already imports `BeautyCore` and exposes a tiny module facade. Add detection services and mappers in this target without importing SwiftUI or Demo code.

**Package target pattern** (Package lines 14-33): `BeautyDetection` already depends on `BeautyCore`; add `BeautyDetectionTests` as a new test target depending on `BeautyCore` and `BeautyDetection`, matching existing test target declarations.

### SDK tests (test, assertion)

**Analogs:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`, `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift`

**Facade visibility pattern** (BeautySDKFacadeTests lines 10-33): tests import `BeautySDK` and assert public facade exposure through host-visible types.

**Pixel fixture pattern** (BeautyEngineTests lines 59-139): shared fixture helpers create BGRA pixel buffers and read deterministic bytes.

**Config assertion pattern** (BeautyConfigurationTests lines 6-29): tests assert defaults and clamping explicitly.

### Demo Camera metadata and processing state (model/service, streaming)

**Analogs:** `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift`, `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`, `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`

**Frame model pattern** (CameraPreviewModels lines 6-38): `CameraPreviewFrame` is a `nonisolated` value type with source enum, pixel buffer, orientation, timestamp, source, extent, and pixel format helper.

**Frame creation pattern** (CameraSessionController lines 99-126): static factory methods default orientation to `.right`, extract timestamp from sample buffers, and return a frame. Phase 4 should add explicit metadata defaults here: input not mirrored, preview mirrored for front-camera Demo behavior.

**Pipeline injection and state pattern** (CameraBeautyPipeline lines 45-107): processing state carries latest snapshot, drop count, and warning; `CameraFrameProcessor` is injectable and wraps `BeautyEngine`.

**Snapshot update pattern** (CameraBeautyPipeline lines 194-220): `finish` creates a snapshot on success, preserves latest snapshot on failure, and emits friendly copy.

### Demo Photo metadata and processing state (model/service, file-I/O)

**Analogs:** `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift`, `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`

**Input/snapshot pattern** (ImageInputModels lines 7-89): image source and snapshot are nonisolated values, currently preserving source kind/id, input/output images, orientation, and parameters.

**Processor injection pattern** (ImageEditorPipeline lines 8-54): decoder and processor are injectable, with `StillImageProcessor.beautyEngine()` wrapping `BeautyEngine`.

**Async processing pattern** (ImageEditorPipeline lines 96-190): processing captures generation, preserves previous snapshot during loading, ignores stale work, and emits friendly failures.

### Demo status UI and privacy tests

**Analogs:** `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`, `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`

**Status capsule pattern** (EditorShellView lines 193-205): detection status should reuse 13px semibold text, `#202F4D` text color, horizontal 12px / vertical 8px padding, white 92% capsule, and accessibility label.

**Static privacy scan pattern** (InputPipelinePrivacyTests lines 18-37, 49-67, 69-84): privacy tests enumerate Swift files, scan forbidden tokens, enforce facade-only imports, and assert user-facing copy avoids raw errors and paths.

### Demo pipeline tests

**Analogs:** `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`, `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift`, `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift`

**Camera processor seam pattern** (CameraBeautyPipelineTests lines 9-39): inject a `CameraFrameProcessor`, record frame fields, enqueue, wait idle, and assert snapshot propagation.

**Camera failure continuity pattern** (CameraBeautyPipelineTests lines 99-121): failure keeps last usable preview and redacts raw error strings.

**Photo processor seam pattern** (ImageEditorPipelineTests lines 29-54): inject decoder and processor, process source, wait idle, and assert source/snapshot propagation.

**Camera metadata factory test pattern** (CameraSessionControllerTests lines 19-35): construct a frame through `makeFrame`, then assert pixel format, extent, orientation, timestamp, and source.

## Shared Patterns

### Public API compatibility
**Source:** `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` lines 15-39.
**Apply to:** `BeautyEngine` overloads and SDK tests.
Old orientation-only APIs stay intact and delegate through default non-mirrored metadata. New APIs are additive.

### Privacy and redaction
**Source:** `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` lines 79-89; `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` lines 18-84.
**Apply to:** public detection summaries, Demo debug summary, status copy, and tests.
Do not expose landmark coordinates, bounding boxes, raw Vision objects, raw framework errors, file paths, or source image identifiers.

### Injectable processing seams
**Source:** `CameraFrameProcessor` in `CameraBeautyPipeline.swift` lines 89-107; `StillImageProcessor` in `ImageEditorPipeline.swift` lines 33-54.
**Apply to:** Demo tests proving metadata/result propagation without importing internal SDK targets.

### Bounded async continuity
**Source:** `CameraBeautyPipeline.finish` lines 194-230 and `ImageEditorPipeline.finish` lines 172-190.
**Apply to:** no-face/partial-face degradation state; keep last usable visual output and avoid treating detection degradation as fatal.

## No Analog Found

All planned files have a usable analog. `VisionFaceDetector` has no Vision-specific analog in the current codebase, so planner/executor should use the `BeautyDetection` target boundary, `BeautyError` redaction pattern, and RESEARCH.md guidance for injected Vision adapter tests.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`
**Files scanned:** 21
**Pattern extraction date:** 2026-06-18
