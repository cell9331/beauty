# Phase 4: Detection and Coordinate Safety - Context

**Gathered:** 2026-06-18T01:53:10Z
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase makes the SDK and Demo preserve orientation and mirroring metadata, reason about usable face state, convert detector coordinates into a canonical image-normalized model, and degrade safely for no-face or partial-face inputs.

Phase 4 covers `PIPE-05` and `PIPE-07`. It does not implement real beauty effects, filters, presets, per-face parameters, multi-face UI, overlay boxes/points, final QA debug surfaces, export, stickers, makeup, segmentation, or video output.

</domain>

<decisions>
## Implementation Decisions

### Orientation and Mirroring API Boundary
- **D-01:** Preserve the existing orientation-only `BeautyEngine.process(...)` APIs and add new metadata-aware overloads. Old APIs must remain compatible.
- **D-02:** Introduce a lightweight public `BeautyInputMetadata` value instead of exposing internal `BeautyFrame` as the long-term host API.
- **D-03:** Use one shared `BeautyInputMetadata` shape for realtime `CVPixelBuffer` and still `CIImage` processing paths.
- **D-04:** Keep `isInputMirrored` and `isPreviewMirrored` as separate concepts. `isInputMirrored` affects SDK coordinate interpretation; `isPreviewMirrored` is for preview, overlay, and future debug display.
- **D-05:** The old orientation-only APIs delegate to the metadata-aware path with default non-mirrored metadata.
- **D-06:** Metadata includes a stable `source` enum and optional `timestamp`. Camera supplies frame time; still-image processing usually uses `nil`; fixtures use `testFixture`.
- **D-07:** Demo front-camera defaults are `isInputMirrored = false` and `isPreviewMirrored = true`, matching the current direct sample-buffer input path and normal mirrored preview expectations.
- **D-08:** `CameraProcessingSnapshot` and `ImageProcessingSnapshot` should retain full `BeautyInputMetadata`, not only orientation, so compare/debug/tests can verify metadata propagation.

### Detection State Exposure
- **D-09:** Detection and degradation state must be exposed through public `BeautyResult` metadata so both host apps and Demo can read stable summaries.
- **D-10:** Add result-returning overloads such as `BeautyResult<CVPixelBuffer>` and `BeautyResult<CIImage>` while keeping output-only APIs compatible.
- **D-11:** Public metadata exposes stable summaries only. It must not expose bounding boxes, landmark coordinates, raw Vision objects, or internal face observations.
- **D-12:** Use structured enum reason codes for degradation and detection states; do not require string parsing and do not mix detection reasons into generic parameter validation warnings.
- **D-13:** Add an explicit top-level `DetectionAvailability` state such as `notRun`, `noFace`, `usable`, `partial`, `lowConfidence`, `stale`, and `disabled`.
- **D-14:** Distinguish `disabled`, `notRun`, `skipped/reused`, and `stale` instead of collapsing them into one empty state.
- **D-15:** Public metadata may include privacy-safe counts and timing summaries, such as `faceCount`, `usedFaceCount`, `detectionDurationMs`, and `mappingDurationMs`.
- **D-16:** Detector and mapping failures should map to structured public degradation reasons, such as `detectorUnavailable`, `detectionTimedOut`, or `mappingFailed`; raw framework details stay in redacted diagnostics only.

### Demo Degradation Behavior
- **D-17:** In normal UI, no-face and partial-face results keep the current visual output and show a short non-blocking status message. Do not show a modal, clear the preview, or switch modes.
- **D-18:** Do not disable face-dependent sliders during no-face or partial-face states. Users can keep editing parameter snapshots while metadata explains that face-dependent effects are paused, weakened, or waiting for a usable face.
- **D-19:** Normal UI copy varies by main state, such as no-face, partial, or low-confidence, but must stay short and avoid landmark or internal Vision details.
- **D-20:** Demo debug mode may show `DetectionAvailability`, reason codes, `faceCount`, `usedFaceCount`, and timing summaries. It must not show landmark coordinates, bounding boxes, or raw framework errors in Phase 4.
- **D-21:** Camera detection status updates should debounce or briefly hold state to avoid per-frame flicker. Planner should align concrete thresholds with the detection reuse window.
- **D-22:** Photo-mode detection status belongs to the current processed result and remains visible until reprocessing or changing the image.
- **D-23:** Phase 4 implements normal status rows and a lightweight debug data model only. Overlay boxes/points and the final QA debug surface remain Phase 7 scope.
- **D-24:** When detection metadata is unavailable, normal UI stays quiet while debug state reports unavailable, disabled, or not-run causes.

### Test and Fixture Scope
- **D-25:** Use synthetic model and coordinate fixtures as the primary test strategy. Add narrow deterministic image fixtures or injectable Vision stubs only where they improve adapter coverage.
- **D-26:** Coordinate tests cover core orientation and mirroring combinations: back/front, portrait/landscape, major EXIF orientations, input mirrored versus preview mirrored, and VisionNormalized to ImageNormalized to Preview/MirroredPreview conversions.
- **D-27:** No-face and partial-face tests must cover both SDK result metadata and Demo state.
- **D-28:** Vision adapter tests should use injectable detector/stub seams as the main evidence. Real Vision images are allowed only as narrow smoke tests that do not assert exact landmarks or boxes.
- **D-29:** Add compatibility tests proving old orientation-only APIs and new metadata-aware APIs produce equivalent output behavior under default non-mirrored metadata. Also verify Demo uses the new metadata path.
- **D-30:** Metadata and debug model tests must prove no landmark coordinates, bounding boxes, raw framework errors, or image paths leak through public result/debug surfaces.
- **D-31:** Verification must include both `swift test --package-path BeautySDK` and Demo simulator XCTest with an explicit iOS Simulator destination.
- **D-32:** Real-device front-camera mirroring and real Vision quality are remaining risks/manual QA items, not required Phase 4 completion gates.

### Single-Face and Multi-Face Boundary
- **D-33:** v1 executes single-face behavior, using the largest/most stable face, while internal models and tests support deterministic ordering for future multi-face expansion.
- **D-34:** Public metadata reports `faceCount`, `usedFaceCount`, and a `faceLimitApplied` reason code when the detected face count exceeds the configured budget. It must not expose individual face positions.
- **D-35:** Primary face selection chooses the largest face first and uses stable ID when sizes are close enough to avoid Camera jitter. Planner should define the concrete tie threshold in tests.
- **D-36:** `BeautyConfiguration.maximumFaceCount` should be effective in the SDK and tested for `1` and values greater than `1`; Demo default remains `1` and no multi-face settings UI is added.
- **D-37:** Non-used faces never participate in effects in Phase 4. They are represented only through summary metadata.
- **D-38:** Tracking IDs are stable only within the current engine lifecycle. They do not persist across app launches, images, or `reset()`, and `reset()` clears tracking state.
- **D-39:** Camera and Photo use the same face ordering rules, but Photo processing is independent and must not reuse tracking state across images.
- **D-40:** Do not add public per-face parameter APIs in Phase 4. Keep only internal model extensibility and public summary metadata.

### the agent's Discretion
No areas were delegated to the agent. Follow the decisions above and the canonical references below.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Active ledger, completed Phase 1-3 evidence, and current tech debt.
- `.planning/PROJECT.md` — SDK-centered product direction, local-first privacy posture, and Demo validation role.
- `.planning/REQUIREMENTS.md` — Phase 4 covers `PIPE-05` and `PIPE-07`.
- `.planning/ROADMAP.md` — Phase 4 goal, success criteria, and four planned plan slots.
- `.planning/STATE.md` — Current focus and session continuity.
- `.planning/phases/01-sdk-foundation-and-public-facade/01-CONTEXT.md` — Public facade, no-op output, typed errors, and immutable parameter decisions.
- `.planning/phases/02-demo-integration-shell/02-CONTEXT.md` — Demo shell, slider, category, and disabled-state decisions.
- `.planning/phases/03-realtime-and-still-input-slice/03-CONTEXT.md` — Camera/Photo entry flow, processing continuity, compare, loading, and friendly error decisions.

### Root Contracts
- `ARCHITECTURE.md` — SDK target boundaries, `BeautyDetection`, `BeautyCore`, `BeautySDK`, Demo facade-only import invariant, and no Vision leakage to public API.
- `DESIGN.md` — `BeautyFrame`, `BeautyResult`, face observation model, landmark groups, `DetectionAvailability`-adjacent state machine, coordinate spaces, and degradation invariants.
- `FRONTEND.md` — Demo state ownership, Camera/Photo pipeline boundaries, status UI, fixture rules, and debug mode constraints.
- `SECURITY.md` — Orientation validation, face geometry sensitivity, log redaction, local-first boundary, and no sensitive metadata leakage.
- `RELIABILITY.md` — Detection failure policy, degradation matrix, diagnostics layers, metrics limits, and detection reliability rules.
- `PRODUCT_SENSE.md` — No-face/partial-face user journey, debug acceptance, naturalness constraints, and safe degradation expectations.
- `QUALITY_SCORE.md` — Coordinate, detection, degradation, privacy, SDK, and Demo test gaps relevant to Phase 4.

### Codebase Maps
- `.planning/codebase/ARCHITECTURE.md` — Historical architecture map; partially stale after Phase 1-3 but useful for target and layer context.
- `.planning/codebase/TESTING.md` — Historical testing map and command conventions; verify against current Phase 1-3 tests.
- `.planning/codebase/CONCERNS.md` — Historical risk map, including Xcode destination fragility and privacy/test gaps.

### Current Code
- `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift` — Existing internal frame metadata with `orientation`, `isInputMirrored`, `isPreviewMirrored`, `source`, `timestamp`, and `extent`.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` — Existing generic result envelope to extend with detection/degradation metadata.
- `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` — Existing `maximumFaceCount`, `enableFaceTracking`, `detectionFrameInterval`, and debug/performance settings.
- `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` — Existing typed and redacted errors, including `.detectionFailed`.
- `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` — Current output-only orientation APIs that Phase 4 must keep compatible while adding metadata/result overloads.
- `BeautySDK/Sources/BeautyDetection/BeautyDetection.swift` — Placeholder detection target; Phase 4 expands this target with detector, mapper, and model foundations.
- `BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift` — Current camera frame model with orientation, timestamp, source, and extent.
- `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift` — Current camera sample-buffer to `CameraPreviewFrame` creation point; currently defaults orientation to `.right`.
- `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` — Current realtime processing state, processor seam, snapshot, and friendly failure behavior.
- `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift` — Current still-image source and snapshot models with orientation only.
- `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` — Current still-image processor seam, loading/failure continuity, and SDK image path.
- `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` — Current realtime pipeline tests to extend for metadata propagation, result metadata, and degradation state.
- `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` — Current still-image pipeline tests to extend for metadata propagation and persistent Photo detection state.
- `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` — Current camera frame metadata tests to extend for mirroring defaults.
- `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` — Existing configuration tests to extend for detection/face-count behavior.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyFrame` already models orientation, input mirroring, preview mirroring, source, timestamp, and extent. Phase 4 should align `BeautyInputMetadata` with this shape without making internal frame backing public.
- `BeautyResult<Output>` already exists and can be extended into the result envelope for public detection/degradation summaries.
- `BeautyConfiguration` already contains `maximumFaceCount`, `enableFaceTracking`, and `detectionFrameInterval`, which should become real Phase 4 behavior instead of dormant fields.
- `CameraFrameProcessor` and `StillImageProcessor` are injectable seams that can verify Demo uses metadata-aware result paths without direct internal SDK imports.
- Existing Demo pipeline state already preserves last usable visuals on failures; Phase 4 can add detection/degradation status without changing the continuity model.

### Established Patterns
- Demo imports only `BeautySDK`, never internal SDK targets.
- Demo processing state is enum/value driven and covered by XCTest view-state or pipeline tests rather than simulator UI automation.
- User-facing Demo errors use short friendly copy and must not include raw framework errors, paths, or internal codes.
- Realtime work is bounded; Phase 4 detection must not reintroduce unbounded queues or main-thread blocking.
- Root contracts treat face landmarks, bounding boxes, and raw Vision payloads as sensitive. Public result/debug summaries must stay geometry-free.

### Integration Points
- Add public metadata/result types under `BeautyCore` and expose them through the `BeautySDK` facade.
- Add `BeautyEngine` metadata-aware and result-returning overloads while routing old APIs through compatible defaults.
- Build face observation, landmark, availability, reason-code, and coordinate models in `BeautyCore` or `BeautyDetection` according to dependency rules.
- Implement Vision-backed detection and coordinate mapping in `BeautyDetection`, returning only `BeautyCore` models.
- Update `CameraPreviewFrame`, `CameraProcessingSnapshot`, `ImageInputSource`, and `ImageProcessingSnapshot` to carry `BeautyInputMetadata`.
- Add Demo status/debug data models around existing Camera and Photo pipeline state without building full overlay UI.
- Add SwiftPM tests for SDK metadata, coordinate mapping, detection state, face selection, privacy/redaction, and old/new API compatibility.
- Add Demo simulator XCTest for metadata propagation, no-face/partial-face status, Camera debounce, Photo persistent result status, and facade-only imports.

</code_context>

<specifics>
## Specific Ideas

- Front-camera Demo defaults should be modeled as preview mirrored but input not mirrored.
- Normal Demo no-face copy should be short and state-based, for example "No face detected. Face adjustments are paused." Exact copy can be refined during planning.
- Photo detection state belongs to the processed image result, not a transient toast.
- Camera detection status should avoid per-frame flicker by debouncing or holding state briefly.
- Public metadata should be useful to host apps without requiring them to understand Vision, landmarks, bounding boxes, or SDK internals.

</specifics>

<deferred>
## Deferred Ideas

- Overlay boxes/points, coordinate drawing, and final debug QA surface remain Phase 7 scope.
- Public per-face parameters, manual main-face selection, multi-face UI, and true multi-face effects remain future/v2+ scope.
- Real-device front-camera mirroring and real Vision quality are manual QA risks to record after Phase 4 verification, not required completion gates.

</deferred>

---

*Phase: 4-Detection and Coordinate Safety*
*Context gathered: 2026-06-18T01:53:10Z*
