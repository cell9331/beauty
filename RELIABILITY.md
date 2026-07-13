# RELIABILITY.md

> `beauty` 的可靠性、错误处理、可观测性、性能预算和恢复策略。
> 安全与隐私看 `SECURITY.md`，核心状态机看 `DESIGN.md`。

## 1. Reliability Posture

`beauty` 优先保证实时链路稳定、可降级、可诊断。效果质量不能以崩溃、卡主线程、内存持续上涨或隐性数据泄露为代价。

Core rules:

- 可恢复错误使用 `throws` 或 typed result，不使用 `fatalError`。
- Release 构建不得因资源缺失、检测失败、渲染失败而 crash。
- 实时相机链路失败时优先返回明确错误，由 App 显示原始帧或降级结果。
- 图片与导出链路失败时返回明确错误，不能静默输出错误图像。
- 每个 render pass、resource loader、detector 都必须声明失败模式。
- 性能问题必须在架构和验收阶段暴露，不在功能堆完后补救。

## 2. Reliability Invariants

| ID | Invariant | Verification |
| --- | --- | --- |
| R1 | Realtime path never blocks the main thread. | Inspect call sites and run UI responsiveness checks. |
| R2 | Realtime failure can fall back to original frame. | Simulate render error and verify preview survives. |
| R3 | Public errors are typed as `BeautyError`. | API compile review and error mapping tests. |
| R4 | Recoverable errors do not crash release builds. | Fault injection and release-mode smoke test. |
| R5 | Logs and metrics are optional and can be disabled. | Config test for `BeautyLogLevel.none`. |
| R6 | Performance metrics contain no image or face geometry payload. | Log/metrics redaction review. |
| R7 | Caches are bounded and resettable. | Long-run memory test and `reset()` test. |
| R8 | Empty or zero-strength passes are skipped. | RenderGraph unit test. |
| R9 | Device quality mode changes degrade predictably. | Mode matrix test. |
| R10 | `reset()` clears detection, smoothing, transient textures, and resource transient state. | State machine test. |

## 3. Service-Level Targets

Initial targets are engineering budgets, not marketing claims.

| Scenario | Target |
| --- | --- |
| Realtime 720p preview | Stable 30 fps on supported devices. |
| Realtime 1080p preview | Stable 30 fps on mid/high-end devices. |
| Realtime 4K preview | Not a first-version target. |
| Detection cadence | Async or throttled, around 10 to 15 detections per second when needed. |
| Render total | Typical first-version budget 5 to 12 ms per processed frame, device-dependent. |
| App launch impact | SDK initialization must not perform heavy resource decode on main thread. |
| Long-run preview | 10 minutes without steady memory growth. |
| Image processing | Large images may be slower, but must not crash or block main thread indefinitely. |

Pass-level reference budgets:

| Pass | Reference Budget |
| --- | --- |
| `FaceWarpPass` | 1.0 to 3.0 ms |
| `SkinPass` | 2.0 to 6.0 ms |
| `ColorPass` | 0.3 to 1.0 ms |
| `LUTPass` | 0.5 to 1.5 ms |

If a device cannot meet the target, the pipeline must degrade by mode rather than silently dropping into unstable behavior.

## 4. Error Taxonomy

Public errors should converge on a stable `BeautyError` surface:

```swift
public enum BeautyError: Error, Sendable {
    case metalUnavailable
    case commandQueueCreationFailed
    case textureCreationFailed
    case pixelBufferCreationFailed
    case shaderFunctionNotFound(String)
    case invalidInput
    case unsupportedPixelFormat
    case resourceNotFound(String)
    case presetDecodeFailed(String)
    case lutDecodeFailed(String)
    case renderFailed(String)
    case detectionFailed(String)
}
```

Rules:

- Internal framework errors are mapped to `BeautyError` before crossing the public API.
- Error cases must be stable enough for host Apps to switch on them.
- Error associated values must be short, redacted, and non-sensitive.
- Do not expose raw `NSError`, `VNError`, `MTLCommandBuffer` internals, file paths, or image metadata in public errors.
- Add a new error case only when callers can respond differently.

## 5. Error Handling Policy

| Failure | Realtime Policy | Image / Export Policy | Notes |
| --- | --- | --- | --- |
| Invalid input | Return typed error; App may show original frame. | Throw typed error. | Validate before work. |
| Metal unavailable | Engine init fails. | Engine init fails. | No silent CPU fallback unless designed. |
| Command queue creation failed | Engine init fails. | Engine init fails. | Recover only via reinit/reset if possible. |
| Texture creation failed | Return typed render error; App fallback. | Throw typed error. | Track count in metrics. |
| Pixel buffer creation failed | Return typed render error; App fallback. | Throw typed error. | Do not leak partial output. |
| Shader function missing | Return typed error in release, assert in debug if developer mistake. | Same. | Build/test should catch. |
| Pipeline state creation failed | Return typed render error. | Throw typed error. | Pipeline states must be cached after success. |
| Detection failed transiently | Reuse recent landmarks or skip face effects. | Retry once or skip face effects. | Follow detection state machine. |
| Low-confidence face | Disable strong geometry. | Disable strong geometry. | Return warning if debug result is enabled. |
| Missing optional LUT | Disable filter and continue. | Disable filter or throw based on API contract. | Prefer visible disabled UI in Demo. |
| Unknown filter ID | Reject parameters with `resourceNotFound`. | Throw typed resource error. | Do not silently apply a missing filter. |
| Preset decode failed | Keep current parameters. | Throw typed preset error. | Never apply partial invalid preset silently. |
| Resource package invalid | Reject resource and clear cache entry. | Throw typed resource error. | See `SECURITY.md`. |

## 6. Degradation Matrix

Degradation is expected behavior, not a hidden failure.

| Condition | Required Degradation |
| --- | --- |
| No face detected | Skip face geometry and face-dependent makeup; keep color and LUT effects. |
| Detection disabled | Return output with `.disabled` summary; do not treat as an error. |
| Detection not run | Return output with `.notRun` summary for compatibility/no-op paths. |
| Detection skipped for throttling | Reuse recent landmarks within allowed reuse window. |
| Detection failed 1 to 3 frames | Reuse recent landmarks with caution. |
| Detection stale | Disable strong geometry; allow weak non-geometric effects. |
| Detection mapping failed | Return `.partial` with `.mappingFailed` and skip face-dependent work for that frame. |
| Low-confidence face | Return `.lowConfidence`; disable strong geometry and keep safe color/LUT output. |
| Landmark group missing | Skip only effects requiring that group. |
| Face too small | Lower geometry strength and skip high-detail effects. |
| Large yaw / side face | Lower face, nose, and mouth geometry strength. |
| Multiple faces exceed budget | Process deterministic subset, usually largest faces first. |
| GPU overload | Drop frames, lower resolution, skip optional passes. |
| Memory pressure | Clear optional caches and lower quality mode. |
| Thermal pressure | Lower resolution, detection cadence, and optional effects. |

Every degradation path that affects visible output should be visible in debug metrics or result warnings.

Phase 6 current implementation treats skin, face shape, eyes, nose, mouth, and lip color as face-dependent when the resolver is given an explicit no-face context. Color adjustment and metadata filters remain face-agnostic and continue when their parameters are non-zero. Missing landmark groups skip only their dependent domains; current freshness behavior is owned by the domain-specific contracts below.

Phase 26 still-image facade behavior:

- `BeautyEngine.processResult(image:metadata:parameters:)` runs detection only when face-shape, eye, nose, mouth, or `lipColor` parameters require geometry.
- No-op, color, filter, and basic-skin paths preserve `.notRun` detection-summary compatibility.
- Disabled tracking preserves `.disabled` and avoids detector work.
- No face, low confidence, missing landmark groups, detector unavailable, and detector timeout degrade through redacted summaries/warnings/metrics while safe face-agnostic work can continue.

Phase 27 saved-output geometry behavior:

- `BeautyEngine.processResult(image:metadata:parameters:)` can return same-dimension still-image geometry output when a usable selected face is available.
- The still-image geometry path now uses bounded local CIImage resampling from internal `WarpControlPoint` source/target pairs; unaffected pixels outside point radii remain unchanged, preventing global color-only output from counting as geometry.
- The dedicated no-face renderer fixture preserves output dimensions and records redacted no-face degradation evidence.
- Focused missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict-cap tests pass, so geometry degradation remains deterministic and aggregate-only.
- `BeautyExampleRenderer` and `check_geometry_renderer_outputs.py` provide rerunnable saved-output evidence without requiring committed generated PNG baselines.

Phase 28 scoped face-shape behavior:

- Per-tool saved-output evidence exists for `faceSlim`, `faceSmall`, signed `chinLength`, `faceVShape`, and `jawSlim` through existing public parameters.
- `jawSlim` covers both `下颌角` and alias-backed `下颌线`; no separate degradation path is introduced for `下颌线`.
- Focused provider, combined-safety, conflict-resolver, and spatial-warp tests pass for caps, missing contour/no-face degradation, signed `chinLength`, combined weakening, redacted warning/metric evidence, and local pixel displacement.
- `BeautyExampleRenderer` and `check_face_shape_renderer_outputs.py` provide rerunnable scoped face-shape saved-output evidence without requiring committed generated PNG baselines.

### Phase 30 Eye Freshness Contract

- Missing either eye group skips and zeros the complete eye domain with category code `eye_inputs_missing`.
- Reused eye geometry skips and zeros the complete eye domain with `eye_geometry_reused_skipped`; stale eye geometry does the same with `eye_geometry_stale_skipped`.
- The stricter reused/stale policy applies only to eyes. Reused face shape, nose, and mouth geometry retain the established `0.5` effective-strength reduction and generic reduction evidence.
- Mouth freshness is domain-specific: reused mouth geometry uses exact `0.5` sign-preserving scaling; stale mouth geometry is exact-zero. `lipColor` remains unscaled for reused/stale geometry when outer lips exist, but skips and zeros for no-face or missing outer lips.
- Warnings expose only fixed category messages. Metrics remain aggregate counts/scales; they do not contain eye side, geometry, image, or local-path payloads.
- Focused resolver/provider/facade evidence and exact warning/metric assertions are recorded in `30-EYE-SAFETY-EVIDENCE.md`.

### Phase 32 Nose Freshness Contract

- Missing nose landmarks and stale geometry skip the complete nose domain, zero `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge`, and emit only category-level or aggregate evidence.
- Reused nose geometry intentionally differs from the eye rule: it remains active at the established non-eye `0.5` scale, including signed negative `noseTipSize`.

### Phase 35 Six-Field Nose Reliability Contract

- The complete nose set is `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, and `noseTipLift`. Missing face/nose input or stale geometry zeros all six; reused geometry preserves every eligible direction at exact `0.5`.
- The new provisional cap is `0.25` per field, so reused capped `noseRootNarrowing` or `noseTipLift` is exactly `0.125` before any independent combined-geometry weakening.
- Fresh nose work uses the provider's per-field emission contract both before conflict accounting and after conflict scaling. Each non-emitting helper is zeroed independently. If scaling crosses a strength or displacement threshold, a bounded monotonic loop removes that field from the retained baseline and recomputes conflict total, weakened count, and scale; at most six nose-field mask changes are possible. Final effective strengths exactly match final per-field emissions while emitting sibling nose work and safe face-agnostic domains continue.
- Diagnostics remain stable and redacted: category warnings such as `nose_inputs_missing`, aggregate skipped-domain counts, geometry-point counts, capped counts, and reuse scale are allowed; raw support points, coordinates, bounds, provider types, and paths are forbidden.
- `35-VERIFICATION.md` records 94/94 focused and 207/207 full XCTest evidence. Phase 36 output and Phase 37 cap calibration/exhaustive exactly-once safety remain later gates.
- No-face public requests preserve extent and permit safe color/filter domains to continue.
- Combined geometry reduces magnitude without flipping signed tip direction; all four fields have focused evidence in `32-NOSE-SAFETY-EVIDENCE.md`.

## 7. Observability Model

First-version diagnostics live in `BeautyCore/Diagnostics`; do not create a separate diagnostics package until another product actually shares it. Use three layers:

| Layer | Purpose | Tooling |
| --- | --- | --- |
| Logs | Discrete operational events and errors. | Swift `Logger` / OSLog. |
| Signposts | Timing critical regions while profiling. | `OSSignposter` or os signposts. |
| Metrics | Frame-level counters and performance summaries. | Internal `BeautyPerformanceMetrics`, optional MetricKit for app-level reports. |

Required local types:

| Type | Purpose |
| --- | --- |
| `BeautyLogger` | Single SDK logger facade shared by SDK and Demo. |
| `BeautyLogEvent` | Redacted event shape with timestamp, level, category, message, optional error code, and string metadata. |
| `BeautyLogSink` | Pluggable sink protocol for OSLog or file output. |
| `BeautyErrorContext` | Redacted internal context attached before public error mapping. |

Official references:

- [Logger](https://developer.apple.com/documentation/os/logger)
- [OSSignposter](https://developer.apple.com/documentation/os/ossignposter)
- [MetricKit](https://developer.apple.com/documentation/metrickit)

Rules:

- Observability is configurable and low overhead by default.
- Release default log level is `error`.
- Debug default can be `warning` or `info`.
- Per-frame logging is disabled by default.
- `BeautyConfiguration.logLevel` is the public log-level entry; do not define another top-level configuration type just for logging.
- Signposts are allowed for profiling but must be easy to disable.
- Metrics must be sampled, aggregated, or pulled through debug result APIs.
- No logs or metrics include image bytes, file paths, landmarks, bounding boxes, user IDs, tokens, or raw JSON.

## 8. Required Metrics

Frame metrics:

| Metric | Meaning |
| --- | --- |
| `totalFrameTime` | End-to-end processing time. |
| `detectionTime` | Detection and landmark mapping time. |
| `renderTime` | RenderGraph execution time. |
| `faceWarpTime` | Face geometry pass time. |
| `skinTime` | Skin pass time. |
| `colorTime` | Color adjustment pass time. |
| `lutTime` | LUT pass time. |
| `outputTime` | Output conversion or presentation handoff time. |
| `faceCount` | Faces used in this frame. |
| `inputResolution` | Input size bucket, not user file path. |
| `outputResolution` | Output size bucket. |
| `frameIndex` | Session-local counter. |
| `droppedFrames` | Frames dropped by backpressure. |
| `qualityMode` | `performance`, `balanced`, or `quality`. |

Memory metrics:

- Texture pool count.
- Pixel buffer pool count.
- Resource cache size.
- Current and peak memory if available.
- Cache evictions.

Error metrics:

- Error code count.
- Degradation reason count.
- Consecutive render failures.
- Consecutive detection failures.

## 9. Logging Policy

Log levels:

```text
none
error
warning
info
debug
```

Allowed logs:

```text
beauty.engine.init_failed code=metalUnavailable
beauty.render.failed code=textureCreationFailed
beauty.frame.dropped reason=backpressure
beauty.resource.missing id=clean_01
beauty.quality.changed from=balanced to=performance reason=thermal
```

Forbidden logs:

```text
imagePath=/private/var/mobile/Containers/...
landmarks=[...]
boundingBox=(...)
rawPresetJson={...}
userToken=...
```

Rules:

- Logs must be event-shaped: subsystem, category, event, code, redacted context.
- Avoid free-form multiline logs in frame processing.
- Error logs must include a typed error code.
- Warnings are for visible degradation or repeated recoverable failures.
- Info logs are for lifecycle and configuration.
- Debug logs are for development and must still obey `SECURITY.md`.
- Local file logging is off by default. If an App explicitly enables it, files stay inside the App sandbox, rotate by date, default to 7-day retention and 5 MB per file, and must be redacted before export.

## 10. Performance Modes

```swift
public enum BeautyRenderQuality: Sendable {
    case performance
    case balanced
    case quality
}
```

Mode matrix:

| Mode | Resolution | Detection Cadence | Max Faces | Effects |
| --- | --- | --- | --- | --- |
| `performance` | Downscale to 720p target | Every 3 to 5 frames | 1 | Basic color, LUT, light geometry, no advanced makeup/background. |
| `balanced` | 720p or 1080p by device | Around every 3 frames | 1 to 3 | MVP skin, face, facial features, LUT. |
| `quality` | Higher resolution when safe | Every 1 to 2 frames | More only if budget allows | Higher-quality skin and more complex effects, suited to image/export. |

Rules:

- Mode changes must be explicit in metrics.
- Automatic downgrade must be reversible when pressure ends.
- Demo UI must not present disabled effects as active.
- Export can use `quality` without inheriting realtime preview limits.

## 11. Backpressure and Frame Dropping

Realtime camera must prefer freshness over processing every frame.

Rules:

- Maintain a bounded in-flight frame count.
- If GPU or detection falls behind, drop incoming frames before queues grow unbounded.
- Do not process stale frames after newer frames are available for preview.
- Completion handlers must release frame resources promptly.
- Dropped frames increment `droppedFrames` metrics.
- Backpressure must not mutate parameter snapshots out of order.

Recommended first-version policy:

```text
inFlightRenderFrames <= 1 or 2
latestFrameWins = true
dropReason = backpressure
```

The first public `process(pixelBuffer:) throws -> CVPixelBuffer` API may be synchronous, but realtime callers must run it off the main thread and combine it with in-flight limiting, `AVCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames`, or an equivalent drop/fallback policy.

## 12. Memory Management

Must reuse:

- `MTLDevice`
- `MTLCommandQueue`
- `CIContext`
- `CVMetalTextureCache`
- Pipeline states
- LUT textures
- Makeup textures
- Intermediate textures
- `CVPixelBufferPool`
- `MTLBuffer` where practical

Forbidden in realtime paths:

- Creating `MTLDevice` per frame.
- Creating `MTLCommandQueue` per frame.
- Creating `CIContext` per frame.
- Creating pipeline state per frame.
- Parsing LUT per frame.
- Loading PNG resources per frame.
- Converting realtime frames through `UIImage`.
- Creating unbounded arrays, textures, buffers, or resource caches.

Memory pressure policy:

1. Release optional resource caches.
2. Reduce quality mode.
3. Lower processing resolution.
4. Limit face count.
5. Disable optional passes.
6. Return typed error if required resources cannot be allocated.

## 13. Render Pipeline Reliability

Rules:

- Usually one command buffer per processed frame.
- Encode all active passes into the frame command buffer when possible.
- Pipeline states are created up front or lazily once, then cached.
- Intermediate textures use ping-pong reuse.
- Passes declare whether they are required or optional.
- Optional pass failure degrades output if safe.
- Required pass failure returns typed render error.
- Command buffer completion updates metrics and releases transient resources.
- RenderGraph skips zero-strength or unsupported passes.
- Realtime paths must not use `waitUntilCompleted()` as the steady-state synchronization strategy; reserve blocking waits for minimal closed-loop demos, screenshots, exports, or other documented non-realtime reads.

Required pass contract:

| Field | Required |
| --- | --- |
| `id` | Stable pass identifier. |
| `inputs` | Texture and uniforms required. |
| `outputs` | Output texture or buffer contract. |
| `requirements` | Face, resources, pixel format, quality mode. |
| `failureMode` | skip, degrade, or fail. |
| `metricsKey` | Name used in performance metrics. |

## 14. Detection Reliability

Rules:

- Detection must not block render every frame.
- Detection can run at lower frequency than render.
- Detection output is normalized before effects consume it.
- A transient detection failure can reuse recent landmarks only inside the allowed window.
- Consecutive failure beyond the threshold clears face state.
- Low confidence faces disable strong geometry.
- Missing landmark groups disable only dependent effects.
- Detection errors are counted separately from render errors.
- Public `BeautyDetectionSummary` exposes only availability, redacted reason codes, counts, and timings.
- Camera UI status is debounced for three processed frames; photo UI status persists with the processed image until the next image result.
- `noFace`, `partial`, `lowConfidence`, `stale`, `skipped`, and `reused` are non-fatal states unless a required render dependency fails separately.
- Phase 26 public still-image detection follows this non-fatal policy: unusable detection skips face-dependent geometry domains, keeps safe non-geometry domains, and never exposes raw detector errors in public results.

First-version thresholds:

```text
reuseWindowFrames: 1...3
staleAfterFrames: > 3
lostAfterFrames: implementation-defined but must be deterministic
```

## 15. Resource Reliability

Rules:

- Required bundled resources fail fast at engine init or first use with typed error.
- Optional resources fail soft by disabling their effect.
- Resource cache has size and eviction rules.
- Resource IDs are resolved through `BeautyResources`, not hardcoded paths.
- LUT decode failures are typed as `lutDecodeFailed` or resource errors.
- Preset decode failures keep current parameters unchanged.
- Resource version incompatibility returns a typed error.
- `BeautySDKResources.validate(parameters:)` normalizes numeric values and rejects unknown filter IDs before render work starts.
- Phase 5 metadata-only filters do not create LUT decode work; real filter assets must add missing/decode degradation tests when introduced.

Cache reset:

`reset()` clears transient resource state. It does not delete valid bundled resources or user-selected persistent presets.

## 16. Reset and Recovery

`BeautyEngine.reset()` must clear:

- Detection state.
- Landmark smoothing state.
- Face tracking state.
- Consecutive failure counters.
- Transient render resources.
- In-flight frame bookkeeping after safe cancellation.
- Optional debug metric windows.

`reset()` must not clear:

- Immutable configuration.
- Valid compiled pipeline states unless memory pressure requires it.
- User-owned `BeautyParameters`.
- Persistent preset data.

Recovery flow:

```text
error observed
→ classify as recoverable or unrecoverable
→ degrade or return typed error
→ record metric
→ reset affected state if needed
→ continue or require engine reinitialization
```

## 17. Crash Policy

Allowed debug assertions:

- Test stubs.
- Truly unreachable code during active development.
- Internal invariant violation that must be fixed before release.

Forbidden in submitted code:

- `fatalError` for missing resource.
- `fatalError` for invalid user input.
- `fatalError` for unsupported pixel format.
- Force unwraps on Metal, Vision, Core Image, JSON, or file loading paths.
- Crashing because camera permission is denied.

Release policy:

- Return typed errors for recoverable or environmental failures.
- Use assertions only for developer mistakes that tests should catch.
- Never continue with corrupted output after required render failure.

## 18. Reliability Test Matrix

Minimum tests or manual checks:

| Area | Check |
| --- | --- |
| Engine init | Metal unavailable or command queue failure maps to typed error. |
| Pixel formats | Unsupported format returns `unsupportedPixelFormat`. |
| Render | Texture and pixel buffer creation failure return typed error. |
| Detection | 1 to 3 failed detections reuse landmarks, then clear state. |
| No face | Color and LUT still work; face effects skip. |
| Missing landmarks | Only dependent effects skip. |
| Missing LUT | Filter disables or typed resource error per contract. |
| Invalid preset | Current parameters remain unchanged. |
| Backpressure | In-flight queue remains bounded and dropped frames count increments. |
| Long run | 10 minutes preview has no steady memory growth. |
| Reset | Detection, smoothing, and transient caches clear. |
| Logs | `none` emits nothing; `debug` still redacts sensitive data. |
| Quality modes | `performance`, `balanced`, `quality` change budgets predictably. |

If automation does not exist yet, record the manual result in `PLANS.md`.

Phase 3 input-pipeline evidence recorded 2026-06-12:

- `CameraBeautyPipelineTests` verifies direct `CVPixelBuffer` processing, bounded in-flight work, stale pending-frame drops, latest parameter snapshots, and friendly pause copy.
- `ImageEditorPipelineTests` verifies fixture and PhotosPicker-data processing, cancellation no-op, loading over the previous visual, decode failure preservation, and stale photo work ignored in favor of latest parameters.
- `InputPipelinePrivacyTests` verifies realtime Camera source has no `UIImage` conversion and no raw input/error copy in Phase 3 input paths.

Phase 4 detection/coordinate evidence recorded 2026-06-18:

- `BeautyDetectionTests` covers face selection, Vision adapter seams, unavailable detector degradation, coordinate mapping, and observation mapping failures.
- `CameraBeautyPipelineTests` covers result-backed detection summaries and debounced camera warning replacement.
- `ImageEditorPipelineTests` covers result-backed photo detection summaries and persisted no-face status copy.
- `InputPipelinePrivacyTests` covers public detection summary/debug leakage scans.

Phase 6 effect-degradation evidence recorded 2026-06-22:

- Resolver and engine tests cover default no-op, visible all-domain output, conservative built-in presets, high-strength caps, combined geometry weakening, no-face skips, missing eye/nose/mouth skips, reused geometry reduction, and stale geometry skips.
- `BeautyResult.warnings` and `metrics` carry cap, skip, point-count, active-domain, and weakened-domain evidence without requiring normal UI banners.
- Demo focused tests verify normal parameter changes are quiet and existing panel paths remain enabled while degradation status stays in `DetectionStatusPresentation`.

Phase 7 Demo reliability evidence recorded 2026-06-23:

- `PreviewDebugOverlayState` maps recoverable camera pause to `processing_paused` with `Processing paused. Showing the last usable preview.` and photo decode failure to `photo_decode_failed` with `Could not read that photo. Choose another image.`
- Compare and debug toggles are display-only; tests prove they preserve selected mode, category, subcategory, `BeautyParameters`, and compare display.
- Parameter JSON import is recoverable: invalid JSON, unsupported schema, oversized payload, invalid values, and unknown filters keep the current parameter snapshot unchanged until explicit Apply succeeds.
- Full Demo simulator tests and full SDK SwiftPM tests passed as final closeout evidence.

Phase 26 geometry-facade reliability evidence recorded 2026-07-06:

- `BeautyEngineGeometryFacadeTests` covers detector-call gating, selected-face routing, no-geometry `.notRun`, disabled-tracking `.disabled`, no-face, low-confidence, missing-landmark, detector-unavailable, timeout, safe-domain continuation, and redacted public evidence.
- `BeautyDetectionTests.VisionFaceDetectorTests`, `BeautyEffectResolverTests`, and `MissingLandmarkDegradationTests` cover detector seams, selected-face resolver routing, and group-specific degradation.
- Full `swift test --package-path BeautySDK` passed with 159 tests; raw-leak and public/SPI export scans passed as recorded in `26-VERIFICATION.md`.

Phase 28 face-shape reliability evidence recorded 2026-07-08:

- `BeautyRendererOutputRegressionTests` passed with 6 tests and covers the 17-case renderer matrix, public-facade import boundary, scoped Phase 28 case IDs, and `jawSlim` alias sharing.
- `FaceShapeWarpProviderTests`, `CombinedEffectSafetyTests`, `GeometryConflictResolverTests`, and `BeautyGeometryEffectPipelineTests` passed with focused cap, no-face, signed-chin, weakening, redaction, and local-warp coverage.
- Full post-correction `swift test --package-path BeautySDK` passed with 172 tests.
- `BeautyExampleRenderer` built and wrote 102 ignored outputs; `check_face_shape_renderer_outputs.py` passed with 102/102 outputs and 30/30 top-region comparisons.

Remaining manual reliability checks:

- Real-device camera/Vision smoke still needs hardware verification for mirror/crop behavior, low-light detection quality, and long-run realtime stability.
- Automated pixel deltas prove deterministic output changes, not final visual naturalness; release-like claims still need simulator screenshot or human fixture review.
- Performance budgets, simulator screenshot/UI automation, and 10-minute long-run hardware checks were not run in Phase 7 and remain release-risk gates.

## 19. Release Readiness Gates

Before a release-like build:

- Xcode build succeeds for `BeautyDemo`.
- Default parameters produce near-copy output within render tolerance.
- Realtime 720p preview meets target on at least one supported simulator/device setup.
- Realtime path does not contain `UIImage` conversion.
- Logs are redacted and release default is `error`.
- Long-run preview does not show continuous memory growth.
- All public errors map to documented `BeautyError` cases.
- Missing optional resources degrade without crash.
- Missing required resources return typed errors.
- `reset()` behavior is verified.

## 20. Reliability Decision Log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | Realtime errors fall back at App level to original frame where safe. | Preview continuity matters more than applying every effect. |
| 2026-05-25 | First-version target is 720p stable 30 fps, with 1080p for mid/high-end devices. | Matches existing planning notes and avoids overpromising 4K realtime. |
| 2026-05-25 | Detection cadence can be lower than render cadence. | Face landmarks do not need full frame-rate detection for stable preview. |
| 2026-05-25 | Metrics are internal/debug-first before becoming a public API. | Avoid locking an immature observability contract too early. |
| 2026-07-06 | Still-image geometry detection is gated by parameter need and degrades through summaries instead of public errors. | Host apps keep no-geometry compatibility, disabled tracking remains non-error, and unusable detection skips only face-dependent work. |
