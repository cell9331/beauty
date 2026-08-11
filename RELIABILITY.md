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
| R11 | Evidence-gallery publication is atomic and fail-closed; acquisition failures release descriptors, each source copy has a 16 MiB work ceiling and stable-file check, and an incomplete staging slot or preserved prior-gallery quarantine blocks retry instead of being recursively cleaned. | Gallery self-test covers repeated acquisition failures, bounded mutation/growth rejection, publication, ancestor swap, non-traversal, and repeated-run behavior. |

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

### Phase 35 Nose and Mouth Conflict-Emission Reliability Contract

- The complete nose set is `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, and `noseTipLift`. Missing face/nose input or stale geometry zeros all six; reused geometry preserves every eligible direction at exact `0.5`.
- The new provisional cap is `0.25` per field, so reused capped `noseRootNarrowing` or `noseTipLift` is exactly `0.125` before any independent combined-geometry weakening.
- Fresh nose and mouth work uses provider-owned per-field emission contracts both before conflict accounting and after conflict scaling. Each non-emitting helper is zeroed independently. If scaling crosses a strength or displacement threshold, a bounded monotonic loop removes that field from the retained baseline and recomputes conflict total, weakened count, and scale; at most nine nose/mouth mask changes are possible, preserving the six-field nose bound within the combined set. Final effective strengths exactly match final per-field emissions while emitting siblings and safe face-agnostic domains continue.
- Diagnostics remain stable and redacted: category warnings such as `nose_inputs_missing` and `mouth_inputs_missing`, aggregate skipped-domain counts, geometry-point counts, capped counts, and reuse scale are allowed; raw support points, coordinates, bounds, provider types, and paths are forbidden. A threshold-crossing mouth request with no emitting sibling remains an explicit skipped mouth domain; an emitting sibling keeps `.mouth` active without a missing-input warning.
- `35-VERIFICATION.md` records fresh 106/106 focused and 219/219 full XCTest evidence, including bounded nose/mouth conflict-emission convergence and a clean final code review. Phase 36 output and Phase 37 cap calibration/exhaustive exactly-once safety remain later gates.
- No-face public requests preserve extent and permit safe color/filter domains to continue.
- Combined geometry reduces magnitude without flipping signed tip direction; all four fields have focused evidence in `32-NOSE-SAFETY-EVIDENCE.md`.

### Phase 37 Final Six-Field Nose Reliability Contract

- The two new exact effective caps are `0.25`; reused eligible `noseRootNarrowing` and `noseTipLift` are therefore exactly `0.125` before independent combined weakening. The complete six-field nose set preserves signed `noseTipSize` in both directions.
- Zero input is inert. No-face, missing aggregate nose input, and stale geometry zero all six fields; reused geometry scales each eligible field by exact `0.5`. Missing field-specific support and provider-empty output remove only that field while supported siblings and safe independent color/filter domains continue.
- Fresh-to-reused-to-stale and valid-to-missing/provider-empty transition evidence proves no prior strength or vector survives. Provider-empty work is excluded from active domains, conflict totals, weakened counts, scale, warnings, final strengths, and dispatch.
- One monotonic provider-eligible convergence recomputes the retained nose/mouth baseline until final effective strengths equal final emissions. Phase 37 passed 103/103 focused and 228/228 full tests plus the unchanged 252/252 renderer gate; diagnostics remain category/aggregate-only.

### Phase 38 Eight-Field Mouth Reliability Contract

- Whole-mouth Y/tilt/X work depends only on validated outer-lip support; peak depends on valid upper plus inner support, and plump depends on valid upper, lower, and inner support. Missing, non-finite, duplicate-only, displacement-empty, or final-scale-empty inputs zero only dependent fields while eligible siblings and safe color/filter domains continue.
- Reused eligible mouth geometry applies exact `0.5` after the provisional cap and preserves signed direction. Missing outer support, no face, or stale geometry zeros all eight mouth geometry fields; `lipColor` retains its independent color-domain policy.
- Provider preflight and final conflict-scaled emissions use one retained baseline with at most fourteen nose/mouth removals. Unsupported work contributes nothing to active domains, totals, weakened counts, scale, warnings, final strengths, or dispatch. Phase 40 retains ownership of the exhaustive eight-field transition matrix.
- Phase 38 passed 152/152 focused and 259/259 full SwiftPM tests; public diagnostics remain category/aggregate-only and the standard code review is clean.

### Phase 41 Compatible Eye-Support Reliability Contract

- The current 48-field contract adds positive-only `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry`, plus signed `eyeTilt`. All ten default to zero, decode missing legacy 38-key values as zero, and normalize non-finite values to zero without changing the four shipped eye outputs.
- One Vision request carries package-only left/right contours and optional pupils through `CoordinateMapper` exactly once. Support is request-scoped and deterministic; malformed or absent evidence cannot trigger a second request, synthesized pupil, persistence, or network fallback.
- Contours accept 6...16 points, at least 4 unique points, relative width `0.04...0.50`, height `0.01...0.30`, and bounding area above `0.0004`. Pupils use 10% expanded containment, normalized ellipse offset at most `0.70`, and paired width/height ratios `0.50...2.00`. These fixed support-validation ceilings are not provider caps.
- Invalid/missing pupils zero only `pupilSize` and `gazeCorrection` eligibility. An explicit missing/invalid contour side stays empty without proxy fallback and activates the existing complete-eye skip; safe sibling domains continue. Only a nil observed payload uses the legacy proxy path for shipped zero-default compatibility.
- Failures remain observable only as fixed category codes and aggregate counts. No raw side label, point, contour, pupil, box, offset, file path, or framework object is logged or measured. Provider transforms, final caps, facade/renderer output, promotion, Demo, device, commercial, packaging, shipping, and launch-readiness evidence remain downstream.

### Phase 45 Compatible Face-Support Reliability Contract

- One processing request uses the existing single Vision landmarks request and one request-local `CoordinateMapper`. Contour and median are copied immediately, independently bounded before mapping, and converted at most once per accepted point. There is no retry, second detector request, cache, persistence, network fallback, or shared mutable support state.
- Invalid optional contour or median data fails only that region; a surviving sibling and the selected face continue. Invalid shared face bounds retain the established observation-level mapping failure. At the adapter boundary, invalid contour removes observed semantic eligibility, while invalid median or contour/median inconsistency preserves valid contour-only eligibility. The exact seven-point compatibility proxy and existing face/eye/nose/lip siblings remain unchanged.
- Canonical direction is deterministic across `.up`, `.right`, `.left`, `.down`, input-mirror true/false, forward/reversed paths, and preview-mirror changes because points and face-local right/down axes use the same mapper metadata and canonicalization performs whole-array reversal only.
- Support lifetime is the current call. Cancellation or interruption persists nothing, and consecutive opposite-metadata plus parallel requests cannot reuse or overwrite another request's contour/median payload. Valid→invalid→valid adapter calls recompute eligibility without stale carryover.
- Observable failure evidence is limited to fixed redacted reason categories and aggregate counts/ranges. No coordinate, bounds, side label, sample, framework-region object, raw error, or local path is logged or measured. The authoritative privacy prohibitions are in `SECURITY.md`.
- Completion requires the fail-closed checker self-test/live modes and every focused/full test command to pass. Post-review Phase 45 evidence is 36/36 checker self-tests and 13/13 live checks; focused suites pass 32/32 parameter, 9/9 resource, 20/20 resolver, and 15/15 mapping tests, while detector executes 20 tests with 2 opt-in integration skips, adapter executes 32 tests with 1 opt-in integration skip, and complete detection executes 50 tests with 2 opt-in integration skips, all with 0 failures. Full SwiftPM executes 354 tests with 3 opt-in integration skips and 0 failures. The four new inputs remain deliberately unrouted until Phase 46.

### Phase 49 Compatible Eyebrow-Support Reliability Contract

- The existing selected-face Vision request preflights left/right eyebrow regions independently at 1...16 points before copy/map. An accepted point is mapped exactly once; rejected regions map zero eyebrow points. Four fixed mapper-axis probes are bounded separately and do not count as eyebrow points. There is no second request, retry, cache, remap, persistence, network fallback, or shared support state.
- Orientation, input mirroring, preview mirroring, and provider sample order are deterministic because both anatomical side classification and stable inner-to-outer ordering use mapper-derived face-local axes. Phase 51 live integration replaces the insufficient raw-endpoint reversal assumption with face-right projection ordering while retaining the exact mapped sample multiset and input order for projection ties. Adapter validation then accepts 4...16 exact-bit-unique finite closed-unit points, chord 0.08...0.50, vertical span at most 0.25, no non-adjacent intersections, and projection epsilon 0.000001.
- Left/right failure is local. A valid sibling remains attached; both invalid yields nil support; `pairEligible` requires two distinct valid sides. Existing face/eye/nose/lip siblings survive malformed eyebrow support, including the invalid-eye-order construction path.
- Support is rebuilt per call. Alternating valid/invalid, repeated, interrupted, stale-landmark, no-face, opposite-metadata, and eight-way parallel requests retain no previous coordinate payload or identity. Observable results are fixed availability/reason labels, booleans, and aggregate counts only.
- Evidence is fail-closed: a skipped command, tool error, unclassified checker match, failed test, unresolved ASVS L1 HIGH finding, or missing/unreadable/empty/non-regular sole active portrait `example-images/input/portraits/p1.jpg` is not success. Full SwiftPM may be called green only after fixture preflight succeeds. The active inventory rejects parked `e1`–`e6`, and metadata validation rejects any reintroduced GPS/device/time payload. Provider/output/cap/promotion, Demo/device, commercial, performance, packaging, shipping, and release-readiness evidence remains Phase 50-52 or later work.

### Phase 50 Eyebrow Geometry Reliability Contract

- Vertical, thickness, and length fail per side; whole spacing alone requires a valid distinct pair; head spacing survives per side; tilt requires a finite chord; peak requires the stored eligible apex. Missing/malformed side, pair, chord, or apex and provider-empty pre/post-scale work remove only dependent named emissions while safe siblings continue.
- Fresh eligible support keeps full provisional strength. Reused eligible support applies exact non-eye scale `0.5` once before conflict; stale and no-face input zero eyebrow work. Valid→invalid→valid sequences and concurrent facade/provider fixtures rebuild request-local work without stale carryover or cross-request identity.
- Sanitization is monotone before the first conflict total and after each scale. Exactly 44 retained names form the ceiling; removed fields cannot re-enter or double-scale. The provisional total is `13.45`, and at threshold one final shared scale `1 / 13.45` is applied consistently.
- Final named emissions are the accounting oracle: effective strengths, active/skipped domains, fixed `eyebrow_inputs_missing` warning, aggregate `skippedEyebrowDomains`, weakened/capped counts, geometry point count, and the one Face→Chin→Eye→Eyebrow→Nose→Mouth dispatch agree. Diagnostics disclose no side, support, coordinate, chord, apex, or provider detail.
- Fresh evidence passes provider 11/11, resolver 26/26, conflict 14/14, combined 15/15, degradation 48/48, pipeline 3/3, facade 18/18, BeautyEffects 243 with one opt-in skip, full SwiftPM 433 with three opt-in skips, and all fixture/checker/scope/diff gates. This proves compiled reliability only; Phase 51 owns decoded output and Phase 52 final caps/exhaustive safety/promotion. v1.14-v1.16 and UI/device/commercial/performance/packaging/shipping/release claims remain excluded.

### Phase 51 Eyebrow Output Reliability Contract

- A render gate must resolve the exact ignored output root before deleting descendants. Measurement and strict acceptance are separate guarded clean renders: measurement may derive provisional margins once, while strict mode accepts only the subsequently frozen calibration and may not rewrite it.
- Denominators stay explicit: 72 `e6` portrait outputs, thirteen separate no-face eyebrow comparisons, and 144 total two-fixture output/gallery files. The strict gate also requires 13/13 visibility, 6/6 signed direction, 21/21 family distinctions, 40/40 portrait direct comparisons, and 13/13 no-face no-ops.
- Fixture and publication checks fail closed on missing, empty, non-regular, symlinked, unexpected, or retired `e1`–`e5` inputs; exact output/gallery inventories and their reconstructed 144-name bijection must agree. Generated roots must remain ignored, untracked, unstaged, and contained.
- Automated thresholds cannot overrule actual-image evidence. If original-detail review contradicts visibility, signed direction, brow locality, family distinction, or protected-region claims, validation records a gap and Phase 51 remains incomplete even when strict pixel gates pass.
- Fresh closeout passes 438 SwiftPM tests with six opt-in skips after correcting a zero-extent projection regression, then passes the final clean render, frozen strict helper, gallery, containment, privacy/scope, and diff gates. Phase 52 still owns final caps, exhaustive safety, naturalness, promotion, and broader release claims.

### Phase 46 Face/Chin Provider Reliability Contract

- Complete contour support permits smooth, temple, and cheekbone work; taper additionally requires an eligible median and interior apex. Missing/malformed centerline removes taper only, and proxy-only support removes all four while shipped face/chin siblings continue unchanged.
- No-face and stale input zero the four new effective strengths. Eligible reused input applies exact non-eye `0.5` before provider eligibility, so a provisional capped value becomes `0.125`. Fresh→reused→stale→fresh evidence is stateless and restores no prior vector by carryover.
- Provider-empty work is removed before the first conflict total and after every shared scale. The retained baseline is a monotone subset across exactly `0..<37` possible removals; removed work cannot re-enter or be scaled twice.
- The complete provisional ledger totals exactly `11.70` over 37 fields. Final strengths, total, count, scale, weakened count, active/skipped domains, generic warnings, aggregate metrics, geometry point count, and unified dispatch all derive from the same final face/chin/eye/nose/mouth named emissions.
- Valid provider-empty new work contributes zero active/skipped evidence by itself; unavailable/stale face input remains observable through the existing generic face-dependent degradation. An emitting shipped or independent sibling keeps its domain active.
- Diagnostics remain fixed and aggregate-only. Fresh focused evidence passes 17 provider, 21 resolver, 13 conflict, 14 combined, 2 pipeline, 43 degradation, and 15 facade tests; `BeautyEffectsTests` passes 205 with one opt-in skip, full SwiftPM passes 368 with three opt-in skips, and boundary evidence passes 24/24 self-tests plus 14/14 live checks.
- These gates prove provider/routing reliability, not decoded visibility, naturalness, final calibration, exhaustive safety, device parity, performance, packaging, shipping, or launch readiness. Phase 47 owns output evidence and Phase 48 owns final safety/promotion.

### Phase 53 Canonical Still-Image Reliability Contract

- D-18 retains the existing stable caller actions: malformed extent/orientation, over-ceiling or overflow-shaped dimensions, and nonopaque pixels throw payload-free `.invalidInput`; unknown, non-RGB, non-output-capable, or extended-range color semantics throw payload-free `.unsupportedPixelFormat`. No additive error case or framework payload is required.
- Validation order is deterministic: decoded extent and ceiling, typed orientation, color/range allowlist, one orientation/mirror normalization, rechecked integral dimensions and checked allocation, one explicit-sRGB RGBA8 render, then opacity scan. Every rejection occurs before any Vision/support work; exact-ceiling input succeeds and a later valid request succeeds after invalid input because canonical pixels are request values rather than cached engine/static state.
- The `CIContext` is reused by the canonicalizer while every returned pixel allocation remains request-owned. This is an ownership/recovery result only: it sets no latency, memory, device, cancellation, parallel-engine, or release budget. Encoded bytes, container metadata, gain maps, HDR, and transparent composite policy remain unobservable or unsupported nonclaims at the already-decoded facade.
- Focused evidence is `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` (6/6), the Phase 53 checker self-test (6/6; `16 = 13 automated + 3 flagged`), and `git diff --check`.
- D-09 through D-12 use the existing one Vision landmarks request, selected-face policy, and request-local mapper. Outer and inner lip regions independently accept only `1...32` finite closed-unit samples before mapping; each accepted array is mapped once and a rejected array performs no lip mapping or allocation in the production observation.
- Missing/no-face, malformed sibling, boundary/precision, stable tie order, valid-invalid-valid, and independent task-group values degrade locally and recover on the next request without retry, cache, stale fallback, or shared support. A valid sibling region and selected face remain available when the other lip region rejects.
- Evidence for this layer is `swift test --package-path BeautySDK --filter 'StillImageRequestSupportTests|VisionFaceDetectorTests|FaceObservationMappingTests'` plus `git diff --check`. It proves independent request values, not same-engine concurrency or cooperative cancellation; `PATH04-CONCURRENCY` remains flagged under TD-013. No latency, memory, realtime, device, commercial, packaging, or release claim follows.
- The feature-neutral admitted route is deterministic `canonicalize → detect/map → context → render` exactly once for any positive opaque testing demand. Zero demand retains the legacy route; missing/no-face support preserves unrelated color output; invalid canonical or malformed injected support performs no context/render work; valid-invalid-valid and independent-engine sequences recover without retained request state.
- Pixel-buffer processing and `reset()` perform zero local-foundation calls and preserve the existing `.notRun` summary behavior. The focused `BeautyEngineLocalRetouchFoundationTests|BeautyEngineMetadataCompatibilityTests|BeautyEngineGeometryFacadeTests` gate executes 35 tests with all 11 foundation tests green and one unrelated opt-in Apple Vision integration skip. `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY` remain flagged; no cancellation, same-engine parallelism, latency, memory, realtime, device, or release guarantee is inferred.
- D-05/D-08 carrier evidence records only aggregate booleans while proving one canonical backing reaches the request owner/render handoff and the detector receives the exact canonical `CIImage` object. The admitted geometry raster uses sRGB explicitly for CIContext working/output space, bitmap rendering, and reconstructed output; the legacy geometry overload retains its existing device-RGB path and is untouched by production's exact-empty admission.
- D-13 inactive compatibility is executable rather than inferred: the two active fixture inputs retain dimensions and rendered RGBA bytes, warnings remain empty, metrics remain exactly `activeCount == 0` and `cappedCount == 0`, and detection summary remains `.notRun`. The focused `BeautyEngineLocalRetouchFoundationTests|BeautyRendererOutputRegressionTests` command passes 30/30 with all 12 foundation and 18 renderer tests green; the live boundary checker and `git diff --check` pass. No skipped HIGH mitigation, mask/provider/overlap ownership, realtime path, performance budget, device result, or release claim is introduced.
- Phase 53 final evidence passes the exact named five-suite gate at 83/83, the renderer regression at 18/18, and full SwiftPM at 495 executed with six documented opt-in skips and zero failures. The checker proves `16 = 13 automated + 3 flagged`; `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY` remain flagged under TD-013 rather than being converted into same-engine reliability claims.

### Phase 54 Evidence-Gate Reliability Contract

- EVID-01/EVID-02 distinguish invalid input from valid-but-closed evidence. Structural, identity, path, budget, enum, or completeness violations produce fixed redacted validation reasons; a structurally valid bundle that lacks qualifying genuine evidence produces a deterministic closed feature reason such as `missing_genuine_positive`, `incomplete_asset_triple`, or `non_warp_design_unqualified`.
- EVID-03/EVID-04 and D-09 through D-14 freeze one immutable review set per load and recompute only from that snapshot. Replacement, reset, and reload revoke prior object URLs and clear stale decisions. File slicing, header/full-byte reads, object-URL creation, and image construction/decode failures collapse to one fixed redacted local-read result; asset acceptance clears partial state and re-enables both inputs in `finally`, so a later valid replacement starts clean. Reducers are order-independent, one feature cannot unlock a sibling, and upper-eyelid fullness requires both accepted evidence and an independently reviewed credible non-warp method.
- EVID-05/LID-01 treat a stable closed ledger as successful execution. The current explicit empty eligible/review inventory deterministically yields both `missing_genuine_positive` and `missing_genuine_negative` for every feature, plus `non_warp_design_unqualified` for upper-eyelid fullness. No retries, authorization-only context, inferred polarity, stale session recovery, or empty runtime stub converts missing evidence into eligibility; only a new fully validated local bundle and completed review may change a later decision.
- Focused core and offline-review regressions are dependency-free and deterministic; Plan 54-05 owns final Phase 54 numeric closeout. These gates do not establish SDK behavior, device/runtime reliability, latency, memory, commercial quality, packaging, shipping, or release readiness, and Phase 53 production admission remains exactly empty.

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

Phase 41 observed eye contours, pupils, semantic supports, side identity, boxes, and offsets are never log fields; only fixed redacted reason codes and aggregate skip/count metrics are permitted.

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
- The 2026-07-28 consolidation regressions invalidate an asynchronous camera start synchronously on stop, reject late authorized permission completion after the user leaves Camera mode, and map a current PhotosPicker `nil` transfer to the existing recoverable photo failure while ignoring stale completions.

TD-012 production input-bound evidence recorded 2026-07-28:

- Over-limit `CIImage` and `CVPixelBuffer` inputs return the existing typed `BeautyError.invalidInput` before resource validation or allocation-heavy processing; exact-limit and prior valid-input behavior remain green.
- The Demo rejects oversized encoded bytes before decode and oversized decoded extents before processing/display render, preserves the previous snapshot with `Could not read that photo. Choose another image.`, and settles `waitUntilIdle`.
- Generation checks remain authoritative: stale oversized work cannot replace a newer valid success, and a valid selection after either limit failure replaces the recoverable failure normally.
- Focused evidence passes 23 SDK configuration/engine tests and 12 Demo pipeline tests; full regressions pass 457 SwiftPM tests with six expected skips and 118 Demo simulator tests with zero failures.

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

### v1.10 Phase 40 Mouth Geometry Closeout

- All eight mouth geometry fields share exact no-face, missing-support, provider-empty, stale, reused, and transition coverage. Reused eligible geometry scales once by exact `0.5`; `lipPlump` and peak definition are removed when their required local support is unavailable while safe siblings and color/filter domains continue.
- Exact `0.25` caps, capped counts, warnings, totals, retained counts, conflict scale, effective strengths, and final emissions are asserted from the same provider-eligible baseline.
- The full SwiftPM suite passes 265/265; strict renderer evidence remains 308/308 decoded same-dimension outputs. These deterministic gates do not replace physical-device, subjective visual, optimized performance, or long-run preview evidence.

### v1.11 Phase 41 Eye Support Closeout

- Full SwiftPM plus 24 adversarial helper self-tests and 10 live checks are the Phase 41 reliability gate. A scan/tool error, missing path/baseline, unclassified active-source match, Demo/manifest drift, or generated-artifact mutation blocks completion.
- Phase 41 locks support availability and degradation inputs only. Field vectors, visual caps, conflict convergence, public-facade output, renderer matrices, gallery evidence, and exact-row promotion remain Phase 42-44 work.

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | Realtime errors fall back at App level to original frame where safe. | Preview continuity matters more than applying every effect. |
| 2026-05-25 | First-version target is 720p stable 30 fps, with 1080p for mid/high-end devices. | Matches existing planning notes and avoids overpromising 4K realtime. |
| 2026-05-25 | Detection cadence can be lower than render cadence. | Face landmarks do not need full frame-rate detection for stable preview. |
| 2026-05-25 | Metrics are internal/debug-first before becoming a public API. | Avoid locking an immature observability contract too early. |
| 2026-07-06 | Still-image geometry detection is gated by parameter need and degrades through summaries instead of public errors. | Host apps keep no-geometry compatibility, disabled tracking remains non-error, and unusable detection skips only face-dependent work. |

### v1.11 Phase 44 Eye Geometry Reliability Closeout

- All 14 eye strengths are recomputed per request. A fresh valid support emits eligible work; provider-empty work is removed from totals/domains/dispatch; missing pupil removes only pupil/gaze; reused, stale, and no-face complete-eye states zero eye strengths without stale-vector carryover.
- Safe face/nose/mouth/color/filter siblings continue under mixed masks. Warnings and metrics remain aggregate/redacted.
- One exact retained baseline converges monotonically through at most 28 eye/nose/mouth removals. A removed field cannot re-enter or be scaled twice.

### Phase 48 Face Safety Reliability Closeout

- All nine face/chin fields are recomputed per request. Eligible fresh support emits field-local work; eligible reused support applies exact `0.5`; stale and no-face states emit none and retain no prior vector, warning, metric, or active-domain state.
- Missing or malformed contour and centerline evidence disables only dependent fields. `provider-empty` work is removed before totals, domains, warnings, metrics, point counts, and dispatch while valid siblings continue.
- Exact 37-field convergence is monotone: each unsupported field can be removed once, no field re-enters, and no retained field is scaled twice. Safe color/filter and supported geometry siblings continue under degraded masks.
- Fresh focused/full and strict-output gates pass without changing error, recovery, or performance claims.

### Phase 52 Eyebrow Safety Reliability Closeout

- All seven eyebrow results are stateless and recomputed per request. Shared fixtures traverse `BeautyFaceGeometryAdapter` with canonical inner/outer ordering and production-valid bounds. Eligible fresh support emits field-local work, eligible reused support applies exact `0.5` once, and stale or no-face input emits none without retaining a prior vector, warning, metric, or domain state.
- Any missing or malformed side evidence disables only dependent side/pair/chord/apex fields; `provider-empty` work is removed from every final aggregate. Valid eyebrow siblings and unrelated face, eye, nose, mouth, color, and filter work continue safely.
- Both-direction valid-invalid-valid sequences recover on the final valid request. Sequential and concurrent completion-order calls preserve request identity. Separate request-local signals prove that an interrupted caller reaches both the real resolver and provider work before cancellation. Cancelling an already-entered synchronous call does not abort it; one intact request-local value completes while host code owns any later asynchronous generation/publication decision. Twenty-eight parallel and seven subsequent requests remain isolated.
- The complete geometry set converges from one exact `13.45`/44-field retained baseline. A redacted observation seam records every retained-mask transition in the real bounded `0..<44` loop: each tested eyebrow row begins with a strictly nonzero scaled value, is removed once, never re-enters, remains absent from final accounting/dispatch, and repeats to the identical fixed point. Retained work cannot be scaled twice, and final totals, counts, names, points, and dispatch agree.
- Diagnostics expose only fixed reasons and aggregate counts/scales. Command errors, interruption, partial evidence, residue, or an unclassified subprocess result fail closed; recovery requires a clean bounded rerun rather than inferring success from prior output.
- Exact commands and source anchors are recorded in `52-EYEBROW-SAFETY-EVIDENCE.md`; the ASVS L1 boundary is recorded in `52-SECURITY.md`; the independent post-fix `52-REVIEW.md` is clean 0/0/0/0; independent Phase 52 re-verification passes 16/16 with no remaining gap.
- These gates establish verified SDK-core phase completion and deterministic failure/recovery behavior, not UI/Demo behavior, optimized-performance, device, long-run, commercial, packaging, shipping, launch, release, milestone-audit, archive, tag, or cleanup readiness.

### Phase 55 Composition Reliability Closeout

- Checked dimensions, row layout, total counts, offsets, issuance caps, and bounded claim frequency reject malformed work before allocation or ownership reduction. Proposal validation occurs before slot/token consumption, so repeated malformed/effective-empty attempts cannot starve a later valid sibling. A bad unit abstains locally; accepted siblings and unrelated shipped color/filter work continue.
- Composition is stateless per request. Empty, valid-invalid-valid, thrown-call cleanup, both CIImage entries, no-face/missing-support continuation, and pixel-buffer/reset zero-work behavior are executable and green.
- The post-review checker passes a 27-case self-test, including 14 executable live-Swift fixture mutations; the earlier 44-case synthetic count is historical only. Current focused/full regression counts are recorded in the Phase 55 evidence artifact. No HIGH mitigation is skipped.
- These results establish bounded deterministic mechanics and recovery only. They set no realtime, latency, memory, device-quality, optimized-performance, naturalness, commercial, packaging, shipping, or release-readiness guarantee.

### Phase 56 Closed Teeth Reliability Closeout

- Closed-gate evaluation is deterministic and fail-closed: malformed, missing, renamed, duplicated, competing, nonzero, parse-failed, scanner-failed, or unclassified authority/source inputs cannot become a pass.
- Both existing still-image entries, exact no-admission bytes/warnings/metrics/detection summary, unrelated shipped effects, valid-invalid-valid recovery, and pixel-buffer/reset zero local-retouch work remain unchanged. Production admission is literal `.none`.
- The final gate passes 96 focused SDK tests, the post-verification 111-case checker with per-threat totals `38 / 32 / 22 / 23 / 31 / 19 / 24`, 539 full SwiftPM tests with six opt-in Vision skips, and 119/119 explicit Simulator tests. The checker scans the complete production Swift source boundary and rejects a neutrally named enamel/dentition provider alias. These results establish closed-route stability only, not a tooth algorithm, output, device/performance, naturalness, commercial, shipping, or release guarantee.

### Phase 57 Closed Eye-Retouch Reliability Closeout

- Authority, fixture, parser, scanner, and evidence lifecycle handling is deterministic and fail closed. Missing, malformed, duplicated, competing, renamed, nonzero, unreadable, parse-failed, scanner-failed, or unclassified inputs cannot become a pass; one independent gate cannot borrow another feature, shipped proxy, or mechanics result.
- Both still-image facade entries, literal `.none`, exact 59/5/72 inventories, feature-neutral Phase 53/55 request and composition behavior, valid-invalid-valid recovery, unrelated shipped effects, and pixel-buffer/reset zero local work remain unchanged. The two disabled Demo rows and future/future/partial ledgers remain exact.
- The final gate passes 141 focused SwiftPM tests, the 519-case checker with per-threat totals `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42`, 544 full SwiftPM tests with six opt-in Vision skips, and 120/120 explicit Simulator tests. Verification-gap hardening adds complete 44-sclera/74-upper-eyelid camelCase, snake_case, dotted Demo-ID, and owned Chinese identity coverage plus one neutral-file proxy-relation mutation for every identity; prior fixed-output exception classification, exact finalized-evidence schemas, recursive Demo routes, and exact owner synchronization remain intact. These results establish closed-route, privacy, compatibility, and recovery reliability only, not sclera or eyelid algorithms, outputs, device/performance, naturalness, commercial, shipping, or release guarantees.

### Phase 58 Combined Facade Reliability Closeout

- Request-local repeated, parallel, serialized, valid-invalid-valid, no-face, malformed, thrown-recovery, unrelated-continuation, and caller-publication-discard cases retain zero support owners and publish only fixed aggregate counters/reasons; no cooperative-abort or TD-013 claim is introduced.
- Final execution is green across focused and full SDK, exact opt-in Vision `6/0/0`, and full Demo `120/0/0`; canonical/no-op behavior retains dimensions, alpha/color/orientation contracts, typed payload-free errors, and safe-domain continuation with exact `59/5/72` compatibility.
- The remaining lifecycle is external code review/fix followed by independent verification and milestone audit. These automated reliability results do not establish visible effect quality, naturalness, device, performance, commercial, packaging, shipping, launch, or release readiness.

### v1.15 Phase 59 Open Intent Reliability

- The Phase 54 serializer deterministically reproduces the exact open teeth row and two structured reviews from the privately resolved pair. Missing, malformed, incomplete, ambiguous, substituted, parse-failed, or rejected evidence fails closed; mechanics-only or sibling input cannot alter the decision.
- Runtime admission is binary and request-local: the trailing default-zero, finite-normalized `teethWhitening` scalar is the 60th stored/CodingKey/initializer field, and only its normalized positive value creates exactly one opaque demand. Missing legacy input, zero, negatives, non-finite values, aliases, global/lip/geometry/Testing inputs, sclera, and `去脂` remain neutral; valid-invalid-valid requests retain no demand state.
- Compatibility recovery remains exact: five byte-stable presets decode the missing key as zero, the renderer remains 72 cases with no teeth output case, and the three local-retouch Demo rows remain disabled with nil mappings. Scanner/tool errors, unknown HIGH modes, missing owners, unknown output fields, or privacy-runner ambiguity block instead of being classified clean.
- Phase 59 has no provider, mask/transform, renderer/output behavior, Demo activation, realtime/pixel-buffer route, model/network route, sclera surface, or `去脂` surface. Phase 60 must establish provider recovery/safety and Phase 61 must establish public output and closeout; current evidence makes no population, device, performance, commercial, shipping, or release claim.

Command-level evidence is recorded in the [Phase 59 validation strategy](.planning/milestones/v1.15-phases/59-teeth-evidence-and-admission-contract/59-VALIDATION.md) and [exact-open boundary summary](.planning/milestones/v1.15-phases/59-teeth-evidence-and-admission-contract/59-07-SUMMARY.md).

### v1.15 Phase 60 Teeth Provider Reliability

- Every direct positive still-image request attempts the provider exactly once
  after the existing canonicalize/detect/map/context sequence and composes once,
  even when no unit is issued. No-face, missing/partial support, malformed or
  implausible geometry, unsafe area, no accepted seed, protected color, and
  already-light input are teeth-local abstentions; unrelated eligible render
  work continues.
- The provider is stateless and every owner, mask, proposal, result, and summary
  is stack/request-local. Valid-malformed-valid, success-zero-intent, repeated,
  reset, pixel-buffer, and sixteen independent parallel-engine cases prove that
  prior provider observations are cleared and no support or ownership crosses a
  request boundary.
- Production admission takes precedence over Testing-only opaque demand. Hooks
  cannot activate or suppress direct teeth work; when both are present, all
  units share one owner and one deterministic composition transaction.
- Full SwiftPM passes 581 tests with zero failures and seven documented explicit
  opt-in skips. The unchanged Demo builds on iPhone 17e / iOS 26.5 and passes
  121/121 tests. These results establish bounded still-image recovery only, not
  realtime, device endurance, optimized performance, commercial naturalness,
  packaging, shipping, launch, or release readiness.

Command-level evidence is recorded in [Phase 60 verification](.planning/milestones/v1.15-phases/60-teeth-provider-and-production-integration/60-VERIFICATION.md).

### v1.15 Phase 61 Teeth Output Reliability Closeout

- The public renderer now has exactly 73 unique cases with one baseline and one
  direct `teethWhitening_1p00` intent. Strict output uses the same public facade
  as integrations; its comparison-only watermark suppression does not alter the
  default renderer route.
- Fresh positive, negative, and no-face baseline/active outputs decode as six
  regular PNGs with exact dimensions and alpha. Positive tooth-local change is
  nonzero and bounded, the already-light negative remains inside frozen no-op
  limits, no-face is exactly unchanged, reviewed-mask exterior change is zero,
  and texture remains within the frozen interval.
- Color-independent/recolored protection, malformed-support abstention,
  valid-invalid-valid recovery, repeated and parallel isolation, and unrelated
  color continuation preserve the Phase 60 request-local reliability contract.
  No required private, visual, regression, or HIGH gate is skipped.
- Compatibility is exactly 60 public fields, five neutral presets, and 73
  renderer cases. The unchanged Demo retains three disabled local-retouch rows
  and 121 tests. These results establish bounded still-image SDK-core output and
  recovery only, not realtime, device endurance, performance budgets,
  population coverage, commercial naturalness, packaging, shipping, launch, or
  release readiness.

Command-level evidence is recorded in [Phase 61 output evidence](.planning/milestones/v1.15-phases/61-teeth-output-safety-and-independent-closeout/61-TEETH-OUTPUT-EVIDENCE.md) and [original-detail review](.planning/milestones/v1.15-phases/61-teeth-output-safety-and-independent-closeout/61-REVIEW.md).

### v1.15 Phase 62 Sclera Intent Reliability Closeout

- The exact serializer-open row is re-derived through required private
  execution after runtime changes. Missing, ambiguous, malformed, substituted,
  rejected or byte-divergent evidence fails closed without changing teeth or
  upper-eyelid state.
- Sclera intent is default-zero, finite-normalized and request-local. None,
  teeth-only, sclera-only and combined requests produce exact demand counts
  `0/1/1/2`, while every nonempty count shares one canonical request rather
  than multiplying Vision or request-owner work.
- Sclera-only requests perform canonical foundation work but issue no provider
  or composition unit and preserve source output. Combined intent produces the
  same teeth output as teeth-only; generic no-face, malformed, valid-invalid-
  valid, repeated, parallel, reset and pixel-buffer boundaries remain intact.
- Compatibility remains 61 fields, five byte-stable neutral presets, 73
  renderer cases and three disabled Demo rows. Full SwiftPM executes 590 tests
  with zero failures and seven documented non-required opt-in skips; explicit
  iPhone 17e / iOS 26.5 Demo tests pass 121/121.
- These results establish evidence and intent-admission reliability only, not
  sclera provider effectiveness, visible output, realtime/device endurance,
  performance budgets, population coverage, commercial approval, packaging,
  shipping, launch or release readiness.

Command-level evidence is recorded in [Phase 62 verification](.planning/milestones/v1.15-phases/62-sclera-evidence-and-admission-contract/62-VERIFICATION.md).

### v1.15 Phase 63 Per-Eye Sclera Reliability Closeout

- One direct sclera intent invokes one provider after the existing canonical
  request context. Zero, one or two accepted eye units join the same one-pass
  immutable-source composition used by teeth without another canonicalizer,
  Vision request or output feedback loop.
- Missing/no-face support, blink or closure, severe gaze, glare, occlusion,
  malformed contour/pupil, empty envelope and empty material score preserve
  source pixels for only the affected eye. A valid peer and unrelated eligible
  teeth/color work continue independently.
- Valid-invalid-valid, thrown canonical requests, reset, pixel-buffer calls,
  repeated requests and independent parallel engines retain no prior contour,
  pupil, mask, proposal, target, output or summary. Fixed aggregate observations
  are cleared at every call boundary.
- The required native-Vision positive/negative gate, 20 focused provider and
  integration tests, eight isolated HIGH modes, full 612-test SwiftPM suite and
  explicit 121-test Demo suite pass with zero failures. Eight existing
  non-required SwiftPM host/private opt-ins remain documented skips.
- These results establish still-image request recovery and bounded per-eye
  provider behavior only. They do not establish strict public output, realtime
  endurance, target-device performance budgets, population coverage,
  commercial approval, packaging, shipping, launch or release readiness.

Command-level evidence is recorded in [Phase 63 verification](.planning/milestones/v1.15-phases/63-guarded-per-eye-sclera-production-integration/63-VERIFICATION.md).

### v1.15 Phase 64 Standalone Sclera Output Reliability Closeout

- The public renderer advances from 73 to exactly 74 cases through one direct
  `scleraRednessReduction_1p00` case. Public fields remain 61 and neutral
  presets remain five.
- Six fresh positive/negative/no-face baseline and active outputs pass strict
  decoding. The positive improves at least one eye within frozen red-excess,
  luminance, channel, alpha, texture and containment bounds; the normal
  negative stays within frozen no-op/naturalness limits; no-face is byte exact.
- Five adversarial tests cover color-independent protected truth,
  recolored-protected final output, malformed peer support,
  valid-invalid-valid recovery and parallel request isolation. Provider 11/11
  and facade integration 9/9 preserve affected-eye-only failure and unrelated
  work continuation.
- The repaired one-child no-skip SwiftPM gate executes exactly 637 tests with
  zero failures, zero skips, and all eight opt-ins exactly once. The exact
  identities are
  `VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture`,
  `VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload`,
  `VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload`,
  `BeautyEngineGeometryFacadeTests.testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade`,
  `BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope`,
  `BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope`,
  `BeautyTeethWhiteningRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds`,
  and `BeautyScleraRednessRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds`.
  The unchanged Demo builds and passes 121/121 on iPhone 17e / iOS 26.5 with
  zero failures and zero skips.
- `64-no-skip-swiftpm-runner.js` rejects malformed/duplicate XCTest identity,
  missing or ambiguous all-tests summaries, nonzero failure, any skip, zero
  execution, missing/duplicate/failed opt-ins, nonzero child exit and oversized
  output. Every such condition yields only the fixed fail-closed aggregate;
  raw child output is never durable authority.
- Affected-eye-only abstention, peer continuation, valid-invalid-valid and
  concurrent recovery, full-conjunction invalidation after relevant change,
  and execution-discovered simulator validation now form one fresh exact
  terminal R2 conjunction. It authorizes the bounded SDK-core still-image
  `祛红血丝` row in promotion-pending state; `眼睛` remains `partial`, `去脂`
  remains `future`, final validation remains open, and Phase 65 is blocked.
  DeviceRGB/named-sRGB remains Phase 65 SAFE-06-only; no
  realtime endurance, target-device budget, population, commercial, packaging,
  shipping, launch, or release-readiness claim follows.

This state is promotion pending terminal candidate/final verification;
canonical `64-VERIFICATION.md` remains `gaps_found`. Fresh authority is recorded
in [terminal R2 output evidence](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-SCLERA-OUTPUT-EVIDENCE.md), [original-detail review](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-REVIEW.md), [code review](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-CODE-REVIEW.md), [review-fix disposition](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-REVIEW-FIX.md), [ASVS L1 security audit](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-SECURITY.md), and [independent eligibility](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-PRE-PROMOTION-VERIFICATION.md).

### v1.15 Phase 65 Archived Closeout

<!-- PHASE65_FINAL_OWNER_BEGIN -->
owner: RELIABILITY
phase: 65
milestone: v1.15
public_fields: 61
neutral_presets: 5
renderer_cases: 74
disabled_demo_rows: 3
teeth: implemented
mouth: implemented
sclera_redness: implemented
eyes: partial
eye_fat: future
safe_06: closed
lifecycle: archived
release: non-release
<!-- PHASE65_FINAL_OWNER_END -->

- Combined teeth+sclera output byte-matches independently merged standalone
  output for disjoint ownership; collisions preserve source. Injected teeth,
  whole-sclera and individual-eye failures retain every unaffected byte-level
  contribution.
- Valid-invalid-valid, thrown-middle, no-face, malformed, repeated,
  independent-engine parallel, publication-discard cancellation, reset and
  pixel-buffer boundary tests recover without retained request state. Typed
  errors are payload-free and neutral/no-op behavior is deterministic.
- Named-sRGB facade carriers and actual saved PNGs preserve dimensions, up
  orientation and opaque alpha. Both strict feature decoders fail closed when
  the explicit `sRGB` declaration is missing.
- Full SwiftPM passes 638/638 with zero failures or skips and executes all eight
  opt-in Vision/private identities exactly once. Teeth and sclera standalone
  saved-output matrices each pass 6/6. The explicit iPhone 17e / iOS 26.5 Demo
  build and tests pass 121/121 with zero skips.
- This is bounded still-image SDK-core reliability only. It establishes no
  realtime endurance, target-device performance budget, population coverage,
  commercial approval, packaging, shipping, launch or release readiness.

Command-level evidence is recorded in [Phase 65 closeout evidence](.planning/milestones/v1.15-phases/65-combined-facade-privacy-and-milestone-closeout/65-CLOSEOUT-EVIDENCE.md) and [verification](.planning/milestones/v1.15-phases/65-combined-facade-privacy-and-milestone-closeout/65-VERIFICATION.md).

### Post-v1.15 Review Remediation Reliability

- Per-eye mapping converts each support independently and derives order only
  from survivors. Malformed-left/valid-right and valid-left/malformed-right
  requests retain the peer and mapped lips without stale state or raw-value
  diagnostics.
- Teeth output uses the fixed inner-aperture baseline only. Adaptive strong
  count is deterministically zero, final strong count equals fixed strong count,
  and post-blur clipping cannot claim former outer-lip lookalikes. Bright
  material-yellow inputs at source luminance `>= 0.90` are exact no-ops.
- Polygon relationship validation includes edge/boundary intersections, so a
  concave outer polygon cannot admit an inner edge that exits and re-enters it.
- Both private real-fixture suites validate mask extent, origin, dimensions,
  and orientation before allocation-backed rendering or aggregate measurement;
  wrong-size, translated, non-finite, and rotated metadata cases reject.
- Focused mapping/provider/adversarial/mask tests pass `45/45`; combined,
  teeth/sclera integration, renderer, and real-fixture-host tests pass `59/59`
  with only the two expected private opt-in skips; full SwiftPM passes `641/641`
  with eight documented opt-in skips and zero failures.
