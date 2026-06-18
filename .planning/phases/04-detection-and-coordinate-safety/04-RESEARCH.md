# Phase 4: Detection and Coordinate Safety - Research

**Researched:** 2026-06-18
**Phase:** 4 - Detection and Coordinate Safety
**Requirements:** PIPE-05, PIPE-07
**Status:** Ready for planning

## Research Question

What needs to be understood before planning Phase 4 so the SDK and Demo can preserve orientation/mirroring metadata, map detector coordinates safely, and expose no-face/partial-face degradation without crashes or sensitive data leaks?

## Current Implementation Facts

### SDK Surface and Package

- `BeautySDK/Package.swift` already has `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and public `BeautySDK` facade targets.
- `BeautyDetection` currently only contains `BeautyDetectionModule.name`; Phase 4 is the first real detection implementation.
- `BeautySDK/Sources/BeautySDK/BeautySDK.swift` re-exports `BeautyCore` through `@_exported import BeautyCore`, so new public core types become host-visible through `BeautySDK`.
- `BeautyEngine` currently exposes output-only APIs:
  - `process(pixelBuffer:orientation:parameters:) -> CVPixelBuffer`
  - `process(image:orientation:parameters:) -> CIImage`
- `BeautyResult<Output>` exists but only has `output`, `warnings`, and `metrics`.
- `BeautyConfiguration` already has `maximumFaceCount`, `enableFaceTracking`, `detectionFrameInterval`, `enablePerformanceLog`, and `enableDebugMode`; Phase 4 should make the face/detection fields meaningful.
- `BeautyFrame` already stores `orientation`, `isInputMirrored`, `isPreviewMirrored`, `timestamp`, `source`, and `extent`, but it currently wraps `CVPixelBuffer` and is not the right long-term public host API for both frame and image paths.

### Demo Camera Pipeline

- `CameraPreviewFrame` currently carries `pixelBuffer`, `orientation`, `timestamp`, `source`, and `extent`; it does not carry input/preview mirroring metadata.
- `CameraSessionController.makeFrame(...)` defaults orientation to `.right`, source to `.camera`, and requests BGRA frames through `AVCaptureVideoDataOutput`.
- `CameraBeautyPipeline` uses an injectable `CameraFrameProcessor` seam and currently returns only `CVPixelBuffer`.
- `CameraProcessingSnapshot` currently stores `orientation`, `timestamp`, `parameters`, and `extent`; it should evolve to retain full `BeautyInputMetadata`.
- Camera failure handling already preserves the last usable snapshot and shows a friendly non-blocking message. Phase 4 should extend this state model instead of replacing it.

### Demo Still Image Pipeline

- `ImageInputSource`, `DecodedImageInput`, and `ImageProcessingSnapshot` currently carry `orientation` only.
- `StillImageProcessor` is injectable and currently returns only `CIImage`.
- `ImageEditorPipeline` preserves previous visuals on loading/failure and ignores stale work by generation. Detection/degradation state can be attached to `ImageProcessingSnapshot`.
- Photo state should persist no-face/partial-face metadata with the current result until reprocessing or image change.

### Existing Tests to Extend

- SDK tests:
  - `BeautyEngineTests` covers no-op output, unsupported BGRA error mapping, and reset behavior.
  - `BeautySDKFacadeTests` verifies public facade visibility for foundation types.
  - `BeautyConfigurationTests` covers default and clamped configuration fields.
- Demo tests:
  - `CameraBeautyPipelineTests` already has processor injection, stale frame/drop behavior, friendly status, and last-usable snapshot assertions.
  - `ImageEditorPipelineTests` already has decoder/processor injection, loading continuity, decode failure preservation, and stale-work handling.
  - `InputPipelinePrivacyTests` scans for raw error/path leakage, network/upload tokens, realtime `UIImage`, and facade-only imports.
  - `CameraSessionControllerTests` validates BGRA output and frame metadata.

## Recommended Technical Direction

### 1. Add Public Metadata and Result Contracts First

Plan the first slice around public and internal value contracts before Vision code:

- `BeautyInputMetadata`
  - `orientation: CGImagePropertyOrientation`
  - `isInputMirrored: Bool`
  - `isPreviewMirrored: Bool`
  - `source: BeautyInputSource`
  - `timestamp: TimeInterval?`
- `BeautyInputSource`
  - `camera`
  - `photo`
  - `video`
  - `export`
  - `testFixture`
- `DetectionAvailability`
  - `notRun`
  - `disabled`
  - `noFace`
  - `usable`
  - `partial`
  - `lowConfidence`
  - `skipped`
  - `reused`
  - `stale`
- `DetectionDegradationReason`
  - `noFaceDetected`
  - `lowConfidenceFace`
  - `missingLandmarks`
  - `staleDetection`
  - `faceLimitApplied`
  - `detectorUnavailable`
  - `detectionTimedOut`
  - `mappingFailed`
  - `orientationMetadataMissing`
- `BeautyDetectionSummary`
  - `availability`
  - `reasons`
  - `faceCount`
  - `usedFaceCount`
  - `detectionDurationMs`
  - `mappingDurationMs`

Keep the public summary geometry-free. Do not expose bounding boxes, landmark coordinates, raw Vision objects, file paths, or raw framework errors.

`BeautyResult<Output>` should gain optional detection metadata. Result-returning overloads should be additive:

- `processResult(pixelBuffer:metadata:parameters:) -> BeautyResult<CVPixelBuffer>`
- `processResult(image:metadata:parameters:) -> BeautyResult<CIImage>`

The exact method names can be refined during planning, but the plan must preserve the old output-only APIs and route them through result-producing logic using default non-mirrored metadata.

### 2. Keep Face Geometry Internal

Internal face models should live where dependency rules allow:

- Core/shared value types with no Vision dependency can live under `BeautyCore`.
- Vision-specific adapters must live under `BeautyDetection`.
- `VNFaceObservation` and Vision coordinate conventions must not cross the `BeautyDetection` boundary.

Useful internal model set:

- `BeautyFaceObservation`
- `BeautyFaceLandmarks`
- `BeautyLandmarkRegion`
- `FaceTrackingState`
- `FaceSelectionPolicy`
- `CoordinateMapper`
- `CoordinateSpace`

The public API should not expose these internal observations unless a later phase explicitly commits to public overlay/per-face APIs.

### 3. Use Synthetic Fixtures for Most Coordinate and Detection Tests

Vision output is valuable for smoke coverage but should not be the main assertion surface because landmark and box details can vary across OS/runtime versions. Phase 4 tests should mainly use synthetic observations and landmark groups.

Recommended test split:

- `BeautyCoreTests`
  - `BeautyInputMetadataTests`
  - `BeautyResultDetectionSummaryTests`
  - `BeautyEngineMetadataCompatibilityTests`
  - `FaceSelectionPolicyTests`
- `BeautyDetectionTests`
  - `CoordinateMapperTests`
  - `FaceObservationMappingTests`
  - `VisionFaceDetectorTests` with injectable/stubbed detector results
- `BeautyDemoTests`
  - extend camera/photo pipeline tests for metadata propagation and result summaries
  - add status/debug model tests for no-face/partial-face
  - extend privacy scans for public/debug metadata leaks

If `BeautyDetectionTests` is added, `BeautySDK/Package.swift` must add a `BeautyDetectionTests` target depending on `BeautyCore` and `BeautyDetection`.

### 4. Coordinate Mapping Strategy

Canonical internal coordinate space remains:

```text
ImageNormalized
origin: top-left
x: 0.0 left, 1.0 right
y: 0.0 top, 1.0 bottom
```

The planner should make coordinate mapping explicit rather than ad hoc:

- VisionNormalized -> ImageNormalized
- ImageNormalized -> ImagePixel
- ImageNormalized -> TextureUV
- ImageNormalized -> Preview
- ImageNormalized -> MirroredPreview

Every conversion needs:

- source coordinate space
- destination coordinate space
- image extent
- `CGImagePropertyOrientation`
- `isInputMirrored`
- `isPreviewMirrored`

Recommended initial matrix:

- camera-style `.right` with `isPreviewMirrored = true`, `isInputMirrored = false`
- photo `.up`
- portrait/landscape representative orientations: `.up`, `.right`, `.left`, `.down`
- input mirrored versus preview mirrored distinctions
- VisionNormalized to ImageNormalized top-left origin conversion

Avoid exhaustive EXIF plus all mirroring permutations unless the first matrix exposes ambiguity.

### 5. Detection Execution Strategy

Phase 4 can safely keep visual output no-op while adding detection/result metadata:

- If `enableFaceTracking == false`, result metadata reports `disabled`.
- If the current process path does not run detection yet, result metadata reports `notRun`.
- If detection finds no usable face, result metadata reports `noFace` and output remains safe.
- If landmarks are incomplete, result metadata reports `partial` and reasons include the missing groups at a coarse enum level.
- If detector/mapping fails recoverably, return output with structured degradation reasons where possible; only invalid inputs and real processing failures should throw typed errors.
- `reset()` must clear any tracking/smoothing state.

The first version should keep detection cadence and reuse state simple:

- default `detectionFrameInterval = 3`
- reuse within 1 to 3 frames according to root reliability contracts
- `stale` disables strong geometry and is observable in metadata

### 6. Single-Face and Multi-Face Boundary

Phase 4 should implement single-face behavior for v1 while ensuring deterministic ordering:

- Sort detected faces by area first.
- Preserve stable tracking ID when face areas are close to avoid camera jitter.
- Honor `maximumFaceCount` in SDK selection logic and tests.
- Demo remains default `maximumFaceCount = 1`.
- Public metadata reports `faceCount`, `usedFaceCount`, and `faceLimitApplied` when applicable.
- Non-used faces do not participate in effects.
- Tracking IDs are lifecycle-local and cleared by `reset()`.

Do not add public per-face parameters or Demo multi-face settings in Phase 4.

### 7. Demo Degradation State Strategy

Demo should not treat no-face or partial-face as fatal:

- Camera keeps live/last usable preview and shows short non-blocking status.
- Photo keeps the current processed image and attaches detection state to the snapshot until reprocess/change.
- Sliders stay enabled even when face-dependent effects are paused or weakened.
- Normal copy is state-based and non-technical.
- Debug data model can expose availability, reasons, counts, and timings.
- Phase 4 should not draw overlay boxes or points.

Potential Demo value types:

- `DetectionStatusPresentation`
- `DetectionDebugSummary`
- `DetectionStatusDebouncer`

These can be pure value types and unit-tested without UI automation.

## Planning Implications

Recommended plan sequence:

1. Core public contracts and metadata/result compatibility.
2. Detection and coordinate model foundations with synthetic tests.
3. Vision adapter and coordinate mapper implementation with injectable seams.
4. Demo propagation/degradation state and full fixture/privacy verification.

This matches roadmap plan slots and keeps public API compatibility first so Demo and detector work can build on stable types.

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Public API churn around result overload names | Host-facing API can become awkward or unstable | Keep old APIs; add additive overloads; write facade tests. |
| Vision output instability across OS versions | Flaky tests | Use synthetic fixtures/stubs for assertions; real Vision only as smoke. |
| Coordinate mapping ambiguity around mirroring | Incorrect face/effect alignment | Separate input vs preview mirroring; test canonical matrices. |
| Sensitive face geometry leakage | Privacy/security violation | Public summaries only; privacy scan tests for no landmarks/boxes/raw errors/paths. |
| Demo status flicker in realtime camera | Poor UX | Add debounced/held status model around detection availability. |
| Phase creep into overlays or per-face UI | Schedule and scope risk | Keep Phase 4 to metadata/status data; defer overlay and per-face APIs. |
| Real-device front camera differs from simulator fixtures | Unverified hardware behavior | Record manual QA risk; do not make real device a required gate. |

## Validation Architecture

Phase 4 validation should prove four dimensions:

1. **Metadata propagation:** SDK and Demo carry `orientation`, `isInputMirrored`, `isPreviewMirrored`, `source`, `timestamp`, and extent through frame and image paths.
2. **Coordinate correctness:** `CoordinateMapper` converts representative Vision/Image/Preview spaces into canonical `ImageNormalized` output under orientation and mirroring cases.
3. **Safe degradation:** no-face, low-confidence, stale, missing-landmark, disabled, not-run, and detector/mapping failure states produce safe outputs plus structured metadata, not crashes or raw framework errors.
4. **Privacy boundaries:** public result/debug metadata never contains landmark coordinates, bounding boxes, raw Vision payloads, raw framework errors, or image paths.

Required commands after implementation:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test
```

Additional static scans should verify:

- Demo and Demo tests import `BeautySDK` only.
- Camera path still does not use `UIImage`.
- Detection/debug public output does not contain strings or fields for landmarks, bounding boxes, raw Vision objects, raw framework errors, or filesystem paths.

## Open Planning Questions

No user-facing decisions remain open. Planner discretion is limited to concrete type/method names, file grouping, exact debounce thresholds, and whether `BeautyInputMetadata` lives beside `BeautyFrame` or in a separate model file.

## RESEARCH COMPLETE

Phase 4 is ready for planning once the UI-SPEC gate is satisfied or explicitly skipped.
