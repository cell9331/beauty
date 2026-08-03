# PRODUCT_SENSE.md

> `beauty` 的产品体验契约。本文把用户旅程、体验原则和验收标准写成 Agent 可验证的清单。
> 技术边界看 `ARCHITECTURE.md`，参数和状态机看 `DESIGN.md`。

## 1. Product Position

`beauty` 是运行在 iOS 中的美颜 SDK。它面向宿主 App，而不是最终用户独立 App。

Core promise:

- 宿主 App 可以用少量 API 接入实时相机美颜和离线图片处理。
- 默认效果自然，不让用户一眼看出“假脸”或过度滤镜。
- 参数可控，预设可一键应用，高级用户可以细调。
- 实时链路稳定，低端设备可降级。
- SDK 能持续扩展到视频导出、直播流、妆容、分割和身体美型。

## 2. Product Principles

| Principle | Product Meaning | Agent-Checkable Rule |
| --- | --- | --- |
| Natural first | 效果先自然，再追求强度。 | 默认预设和中等强度参数不得产生明显塑料脸、锥子脸、假笑或过饱和。 |
| Realtime confidence | 用户调节时必须立即理解变化。 | 实时预览中滑杆变化能在下一批处理帧内反映，不卡住 UI。 |
| Safe defaults | 新接入 SDK 不需要先调一堆参数。 | 默认 `BeautyParameters` 是无效果；基础预设可直接应用。 |
| Progressive control | 普通用户用预设，高级用户细调。 | Demo 同时提供预设入口和参数滑杆。 |
| Host-app friendly | SDK 不绑 UI 或业务流程。 | 宿主 App 只需传入图像和参数，不需要依赖 SDK 内部模块。 |
| Degrade visibly | 降级不可偷偷产生坏图。 | 检测失败、资源缺失、低端模式都要有可诊断 warning 或指标。 |
| Respect user content | 人像和照片是敏感内容。 | 不上传、不记录路径、不持久化原始帧，除非产品明确新增。 |

## 3. Product Domains

| Domain | MVP Status | Product Goal | Owner Doc |
| --- | --- | --- | --- |
| SDK Integration | Required | App 能快速初始化、传入参数、处理帧和图片。 | `ARCHITECTURE.md`, `DESIGN.md` |
| Realtime Camera | Required | 相机预览可实时美颜、可调参、可降级。 | `FRONTEND.md`, `RELIABILITY.md` |
| Still Image Editing | Required | 图片可高质量处理、可预览、可对比。 | `FRONTEND.md`, `RELIABILITY.md` |
| Presets | Required | 一键自然美颜，降低调参成本。 | `DESIGN.md` |
| Skin Beauty | MVP | 磨皮、美白、红润、锐化，避免塑料感。 | `DESIGN.md` |
| Face Shape | MVP | 轻度瘦脸、小脸、V 脸、下巴，避免畸形。 | `DESIGN.md` |
| Eyes | MVP | 大眼、眼距、眼位、眼尾，保持眼睛自然。 | `DESIGN.md` |
| Nose | MVP | 轻度瘦鼻、鼻翼、鼻头、鼻梁，避免鼻部变形。 | `DESIGN.md` |
| Mouth | MVP | 嘴型、嘴宽、微笑、唇色，避免牙齿和嘴角拉伸。 | `DESIGN.md` |
| Filters | MVP | 控制整体风格，强度可调。 | `DESIGN.md` |
| Makeup | Later | 贴合五官、风格自然、资源可扩展。 | `ARCHITECTURE.md` |
| Background / Segmentation | Later | 虚化、替换、氛围效果，边缘自然。 | `ARCHITECTURE.md` |
| Body Shape | Later | 半身/全身比例调整，有严格降级。 | `ARCHITECTURE.md` |
| Video Export | Later | 保留方向、音频、进度、取消。 | `RELIABILITY.md` |

## 4. Primary Users

| User | Needs | Product Success |
| --- | --- | --- |
| Host App Developer | 快速接入、稳定 API、清晰错误、可控性能。 | 只 import `BeautySDK` 就能完成相机和图片处理闭环。 |
| App Product Designer | 自然预设、可调效果、可做场景化体验。 | Demo 能展示预设、滑杆、前后对比和降级状态。 |
| End User of Host App | 看起来更精神、更自然，不费力调参。 | 默认或基础预设效果自然，调参不会破坏五官比例。 |
| QA / Integration Tester | 可复现、可验证、可定位问题。 | 固定图、固定参数、固定预设能产生稳定结果和指标。 |
| Future SDK Maintainer | 可扩展、可裁剪、文档可路由。 | 新能力能落入已有 Domain，不破坏核心旅程。 |

## 5. User Journeys

### 5.1 Host App Integrates SDK

Journey:

```text
developer adds BeautySDK
→ initializes BeautyEngine
→ creates BeautyParameters
→ processes camera frame or image with explicit orientation
→ handles output or BeautyError
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| Import | App only imports `BeautySDK`, not internal Targets. |
| Init | `BeautyEngine` initializes with `.default` configuration or returns typed error. |
| Defaults | Default parameters produce no visible beauty effect beyond copy/render tolerance. |
| Error | Unsupported input returns `BeautyError`, not crash or raw framework error. |
| Reset | `reset()` clears transient state without deleting user parameters. |

### 5.2 Realtime Camera Preview

Journey:

```text
user grants camera permission
→ preview starts
→ user applies preset
→ user drags slider
→ preview updates
→ device pressure triggers downgrade if needed
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| Permission | Denied permission shows non-crashing UI fallback. |
| Preview | Camera frames reach SDK without realtime `UIImage` conversion. |
| Pixel Format | First-version camera path can provide BGRA pixel buffers. |
| Orientation | App passes correct `CGImagePropertyOrientation`; preview owns visual mirroring. |
| Responsiveness | UI remains responsive while frames process. |
| Slider | UI value maps to expected normalized SDK parameter. |
| Compare | Before/after compare toggles display without resetting parameters. |
| Backpressure | Under load, stale frames are dropped rather than queued unbounded. |
| Degradation | Downgrade reason is visible in debug metrics or warning. |

### 5.3 Still Image Editing

Journey:

```text
user selects or provides image
→ SDK normalizes orientation
→ user applies preset or parameters
→ processed image displays
→ user compares before/after
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| Orientation | EXIF-oriented images process with correct face alignment. |
| Quality | Image mode can use quality configuration independent from realtime preview. |
| Loading | Large image processing shows loading state and does not block UI indefinitely. |
| Error | Invalid or configured-over-limit image input returns a typed SDK error; the Demo preserves the previous output, shows friendly recoverable copy, and accepts a later valid image. |
| Compare | Before/after uses same crop/orientation and does not shift unexpectedly. |
| Geometry intent | Geometry-triggering still-image parameters can activate detection through the public facade, with redacted degradation when no usable face exists. |
| Geometry saved output | The SDK-only renderer can save same-dimension geometry foundation outputs through the public facade, with a no-geometry baseline, no-face evidence, and redacted degradation summaries. |

### 5.4 One-Tap Preset

Journey:

```text
user opens preset panel
→ selects Natural / Clear / Refined / Male Natural / ID Photo Natural
→ parameters update
→ preview changes
→ user can reset or fine tune
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| Preset parse | Built-in preset JSON decodes with schema version. |
| Determinism | Applying same preset returns same `BeautyParameters`. |
| Safety | Preset values stay within SDK ranges and algorithm safety caps. |
| UI sync | Sliders reflect applied preset values. |
| Reset | Reset returns to default or previous selected baseline by explicit action. |
| Missing resource | Preset with unavailable resource disables that effect or returns typed error. |

### 5.5 Manual Fine Tuning

Journey:

```text
user starts from default or preset
→ opens category
→ adjusts skin / face / eyes / nose / mouth / filter
→ sees immediate result
→ resets one parameter or all parameters
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| Category | Every visible control maps to a documented `BeautyParameters` field. |
| Range | Enhancement controls use 0...100 UI; bidirectional controls use -100...100 UI. |
| Natural cap | High UI value still respects algorithm-level safety cap. |
| Reset one | Single parameter reset does not reset unrelated categories. |
| Reset all | All numeric parameters return to zero-effect defaults. |
| Missing face | Face-dependent controls are disabled, degraded, or no-op with debug warning. |

### 5.6 Degraded Device Experience

Journey:

```text
device is low-end or under pressure
→ SDK lowers quality mode
→ optional effects reduce or disable
→ user still sees stable preview
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| Mode | `performance` mode caps resolution and effect set according to `RELIABILITY.md`. |
| Honesty | UI does not show disabled effects as actively applied. |
| Stability | Preview remains usable instead of freezing. |
| Recovery | Quality can restore when pressure is gone if automatic downgrade is used. |

### 5.7 No Face / Partial Face

Journey:

```text
frame has no face, small face, side face, occlusion, or missing landmarks
→ SDK applies only safe effects
→ face-dependent effects skip or weaken
```

Acceptance:

| Check | Pass Criteria |
| --- | --- |
| No face | Color and LUT can still apply; geometry skips. |
| Missing eyes | Eye effects skip without breaking other effects. |
| Missing mouth | Mouth and lip effects skip without breaking skin/filter. |
| Side face | Face, nose, and mouth geometry weaken or disable. |
| Debug | Debug result records skipped or weakened reason. |

## 6. MVP Experience Contract

MVP must demonstrate:

| Capability | Required Evidence |
| --- | --- |
| SDK import | Demo imports only `BeautySDK`. |
| Realtime preview | Camera frames can process through SDK and display. |
| Image processing | Still image can process through SDK and display. |
| Default no-op | Default parameters visually preserve input. |
| Skin controls | Smoothing, whitening, rosy, sharpen are adjustable. |
| Color controls | Brightness, contrast, saturation, temperature, tint, exposure, highlight, shadow are adjustable or explicitly hidden until implemented. |
| Face controls | Face slim, small face, V shape, chin are adjustable. |
| Eye controls | Eye size and at least one additional eye parameter are adjustable. |
| Nose controls | Nose slim and at least one additional nose parameter are adjustable. |
| Mouth controls | Smile and at least one additional mouth/lip parameter are adjustable. |
| Mouth evidence boundary | `大小`, `宽度`, and `微笑` have facade-output plus safety evidence; `lipColor` is color only and does not prove `丰唇`. |
| Filter controls | Filter ID and intensity are adjustable. |
| Presets | At least five built-in presets can apply. |
| Compare | Before/after compare works in Demo. |
| Degradation | No-face and missing-resource scenarios do not crash. |

## 7. Product Acceptance Criteria

### 7.1 Naturalness

Agent-verifiable checks:

- Default parameters produce no visible beauty effect beyond copy tolerance.
- `Natural` preset uses conservative non-zero values.
- Algorithm caps prevent full UI range from becoming full geometric distortion.
- Combined eye parameters do not move eyes outside plausible facial bounds.
- Combined face parameters do not create sharp chin or warped background in fixture images.
- Skin smoothing does not erase eyes, eyebrows, lips, or nose edges in fixture images.

Manual review checks:

- Skin retains some texture.
- Facial proportions remain plausible.
- Lip and rosy color do not appear painted at medium strength.
- Filter does not hide face detail at default intensity.

### 7.2 Control

Agent-verifiable checks:

- Every visible control maps to exactly one or documented group of SDK parameters.
- Reset behavior is explicit and tested.
- Preset application updates parameter store and visible controls.
- Parameter JSON round-trips through Codable without changing values.
- Unknown future parameter fields do not break compatible preset decoding when allowed by schema.

### 7.3 Performance

Agent-verifiable checks:

- Realtime path does not use `UIImage` as intermediate format.
- Slider changes do not create new `BeautyEngine` instances.
- Performance mode reduces resolution/effects according to `RELIABILITY.md`.
- Frame drops are counted under backpressure.
- 720p preview target and long-run checks are recorded before release-like claims.

### 7.4 Integration

Agent-verifiable checks:

- App integration uses `BeautyEngine`, `BeautyConfiguration`, `BeautyParameters`, and `BeautyError`.
- SDK does not require host App to know Vision, Metal pass, or internal Target types.
- Errors are typed and actionable.
- Permission prompts are App-owned, not SDK-owned.
- SDK has no network requirement by default.

### 7.5 Phase 3 Input Evidence

Recorded 2026-06-12:

- Realtime Camera journey now has automated evidence for permission fallback, BGRA frame metadata, public `BeautyEngine.process(pixelBuffer:orientation:parameters:)` processing, no realtime `UIImage`, and bounded backpressure.
- Still Image journey now has automated evidence for fixture input, PhotosPicker-data seam, loading state, decode failure preservation, stale-work handling, and before/after compare.
- TD-012 adds exact-limit/one-over-limit evidence for PhotosPicker bytes, decoded image extents, and SDK pixel-buffer/image inputs; this is input hardening only and does not add a new product feature or claim pre-transfer PhotosPicker allocation control.
- Respect-user-content acceptance is backed by purpose-string tests and static no-upload/no-network/raw-path scans in `InputPipelinePrivacyTests`.
- Full Demo simulator suite passed with 55 XCTest cases for `platform=iOS Simulator,name=iPhone 17,OS=26.5`.

### 7.6 Phase 4 Detection and Coordinate Acceptance

Agent-verifiable checks:

- Camera and Photo inputs preserve orientation and mirroring through `BeautyInputMetadata`.
- Detector output is normalized to canonical `ImageNormalized` coordinates before it can influence effects.
- No-face, partial-face, low-confidence, stale, skipped, reused, disabled, and not-run detection states keep output safe and non-crashing.
- User-facing detection status copy matches `04-UI-SPEC.md` and does not expose geometry or raw framework details.
- Demo and tests import only the public `BeautySDK` facade.

Manual checks still required before release-like claims:

- Real front-camera preview on device: confirm mirror behavior matches user expectation while processed output/crop stays stable.
- Real Vision quality smoke: verify no-face, partial-face, and low-light faces produce the expected status copy and no crash.

### 7.7 Phase 6 Core Beauty Effects Acceptance

Agent-verifiable checks:

- Default pixel-buffer and image paths preserve input within copy/render tolerance.
- Skin, color, filter, face shape, eyes, nose, mouth, and lip controls have deterministic visible or provider-level output evidence.
- All five built-in presets produce conservative non-zero output and remain under safety caps.
- High-strength combined geometry is capped and weakened with redacted warning/metric evidence.
- No usable face skips face-dependent domains while color and filter continue.
- Missing eye, nose, and mouth landmarks skip only affected domains.
- Demo normal parameter changes stay quiet; existing detection status copy handles no-face, partial, low-confidence, and stale states.
- Demo panel smoke coverage includes Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets without category reordering.

Manual checks still required before release-like claims:

- Human visual review of fixed fixtures or simulator preview for naturalness, especially skin texture, face shape plausibility, lip/rosy color, and filter strength.
- Hardware smoke for real camera/photo parity and real Vision quality under front camera, side face, and low light.

### 7.8 Phase 7 Rich Demo QA Acceptance

Agent-verifiable checks recorded 2026-06-23:

- Parameter JSON round-trip, exact top-level keys, deterministic export, 64 KB size rejection, unsupported schema rejection, malformed JSON non-echo, unknown filter rejection, and facade validation are covered by `ParameterJSONCodingTests`.
- Preset/import/custom source transitions, imported apply, single reset, reset all, manual slider clearing, and manual filter clearing are covered by `BeautyParameterStoreTests`.
- The preview toolbar, `Parameter JSON` sheet copy, preview-before-apply gating, invalid-copy language, debug empty state, category order, and `Not in v1` unavailable copy are covered by `BeautyDemoViewStateTests` and `BeautyCategoryModelTests`.
- Before/after compare and debug visibility preserve editor selection, parameters, and compare display; debug rows expose only redacted summaries and friendly recoverable status through `CompareStateTests`.
- `InputPipelinePrivacyTests`, `BeautyDemoImportBoundaryTests`, and static scans verify facade-only imports, local-first JSON/debug surfaces, no file/network JSON scope creep, no raw JSON status/debug echo, and no geometry debug overlay.

Manual checks still required before release-like claims:

- Visual naturalness review of fixtures or simulator preview.
- Real-device front-camera parity, real Vision behavior, low-light/side-face smoke, production render quality, performance budgets, simulator screenshot/UI automation, and long-run hardware stability.

### 7.9 v1.1 Meitu UI Acceptance

Agent-verifiable checks recorded 2026-06-24:

- Home first screen is no longer the SDK-dashboard/editor shell. `ContentView` starts at `MeituHomeView`, and `BeautyDemoViewStateTests.testV11HomeViewStateMatchesMeituReferenceHierarchy` verifies the Meitu-style hero, `拍一拍`, primary actions, paged tool counts, recommendation rails, and bottom tabs.
- Supported Home routes stay local-first: `图片美化` opens photo mode, `相机` and `拍一拍` open camera mode, and `人像美容` opens the beauty editor path. Unsupported actions are disabled/static and do not add upload, network AI, video, VIP, or entitlement behavior.
- Editor first-level taxonomy matches the deduplicated local reference order: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`.
- Supported Meitu reference tools write existing SDK-backed `BeautyControlID` values through `BeautyParameterStore`; unsupported tools remain visible with honest unavailable copy instead of fake support.
- Cancel/confirm behavior preserves the local preview flow: cancel restores the last confirmed parameter snapshot, and confirm records the current snapshot without resetting input mode or compare/debug state.
- Screenshot evidence exists for Home first screen, Home sticky state, and editor tool panel in `.planning/evidence/v1.1/`.

Manual checks still required before stronger product claims:

- Pixel-level 1:1 comparison against every local Meitu screenshot across multiple device sizes.
- Exact commercial asset parity, VIP/paywall behavior, AI feature flows, video editing, `图库` / `AI 修图` / `我` tab content, and recommendation detail pages.
- Release hardening still requires real-device camera/Vision parity, performance budgets, long-run stability, and naturalness review for SDK effects.

### 7.10 Phase 20 Core Module Closeout Acceptance

Agent-verifiable checks:

- Editor-shell support is documented as existing app-side behavior: input routing, preview chrome, category rail, tool rail, sliders, compare/debug, cancel/confirm, and parameter snapshot ownership stay in `BeautyDemo`.
- Demo integration remains facade-only: Demo source and tests import the public `BeautySDK` facade, not internal SDK targets.
- Phase 20 closeout does not add new SwiftUI screens, Demo routes, public parameters, renderer cases, or geometry saved-image output.
- Visible promoted effects require `swift test --package-path BeautySDK`, all current `BeautyExampleRenderer` cases, ignored same-dimension outputs, readable bottom watermarks, and factual visual observations.
- Geometry-heavy shaping branches remain `partial` or `blocked-by-geometry-output` until public facade detection plus geometry rendering can produce saved example-image outputs.

Manual or future release-hardening checks still required before stronger product claims:

- Release-like naturalness review, real-device Vision parity, simulator screenshot/UI automation, performance budgets, and long-run hardware stability.
- Production render quality, commercial asset parity, and exact Meitu/Xingtu feature parity.

### 7.11 Phase 26 Geometry Facade Acceptance

Agent-verifiable checks recorded 2026-07-06:

- `BeautyEngineGeometryFacadeTests` proves public still-image processing runs detection only for geometry-triggering parameters and routes one selected usable face into internal geometry planning.
- No-op, color, filter, and basic-skin still-image requests preserve `.notRun`; disabled tracking preserves `.disabled`.
- No-face, low-confidence, missing-landmark, detector-unavailable, and timeout states degrade without crashing, keep safe face-agnostic work active, and expose only redacted summaries, warnings, and aggregate metrics.
- Public/SPI export scans and active-source scans prove no raw landmark, bounding-box, control-point, Vision observation, raw framework error, local path, raw JSON, or image-byte payload is exposed.

Manual or future checks still required before stronger product claims:

- Phase 26 does not add Demo UI behavior, saved-output renderer cases, generated PNG evidence, commercial quality evidence, full Meitu parity, or `SHAPE_FEATURE_LEDGER.md` implementation status.
- Phase 27 owns deterministic saved-output geometry rendering evidence; Phase 28 owns verified `脸型` tool completion and ledger promotion.

### 7.12 Phase 27 Geometry Saved-Output Acceptance

Agent-verifiable checks recorded 2026-07-07:

- `BeautyExampleRenderer` builds and runs through the public `BeautySDK` facade with 6 fixtures and 11 cases, including `geometryBaseline_noop` and `faceShapeCombo_0p35`.
- The Phase 27 helper verifies 66/66 ignored PNG outputs, same dimensions, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face output presence.
- `BeautyEngineGeometryFacadeTests` proves real fixture detection, selected-face geometry output delta, no-face degradation, and redacted metadata.
- Focused missing-landmark, stale/reused, combined-strength, and face-shape conflict tests pass with redacted summaries and aggregate metrics.
- Renderer scope scans prove Phase 27 did not add eye, nose, mouth, lip, proportion, 3D, or brow saved-output cases.

Correction recorded 2026-07-08:

- User visual verification found that top-region pixel comparisons alone could pass from a global image change without visible face-shape deformation. The still-image geometry path now performs local control-point warp, and regression coverage checks local pixel movement plus unchanged unaffected pixels.

Manual or future checks still required before stronger product claims:

- Phase 28 owns per-tool `脸型` completion and `SHAPE_FEATURE_LEDGER.md` status promotion.
- Broader geometry-domain output, real-device camera/Vision parity, long-run preview evidence, and visual review remain separate scoped work.

### 7.13 Phase 28 Face-Shape Slice Acceptance

Agent-verifiable checks recorded 2026-07-08:

- `BeautyExampleRenderer` builds and runs through the public `BeautySDK` facade with 6 fixtures and 17 cases, including `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, and `jawSlim_0p35`.
- The Phase 28 helper verifies 102/102 ignored outputs, same dimensions, 30/30 portrait face-shape-vs-baseline top-region comparisons, and no-face face-shape output presence.
- Focused renderer, provider, combined-safety, conflict-resolver, and spatial-warp tests pass with cap, no-face, signed-chin, weakening, redaction, local pixel displacement, unaffected-pixel stability, and `jawSlim` alias coverage.
- `SHAPE_FEATURE_LEDGER.md` marks exactly `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` as implemented; `FEATURE_MATRIX.md` keeps branch-level `脸型` partial.

Manual or future checks still required before stronger product claims:

- Unscoped `脸型` rows, broader `美型 / 五官` branches, Demo UI changes, physical-device parity, screenshot reruns, commercial visual review, optimized profiling, packaging review, and launch-readiness review remain separate scoped work.

### 7.14 Phase 30 Eye Slice Acceptance

- Exactly four second-level eye subtools are implemented from existing public parameters: `大小`, `上下`, `眼距`, and `眼尾上扬`.
- Acceptance requires positive-only size/tail behavior, signed distance/position behavior, exact caps, either-eye missing degradation, reused/stale eye skips, combined weakening, redacted aggregate diagnostics, public-facade output, and active-source boundary evidence.
- Branch-level `眼睛` remains `partial`. Eye height, length, pupil, gaze, lid, redness, corners, symmetry, eye-fat, and other future tools require separate product-neutral design and evidence.
- `30-EYE-SAFETY-EVIDENCE.md` is the command-backed acceptance source for this scoped slice.
- This acceptance does not claim whole-branch completion, physical-device parity, commercial review, broad reference parity, final visual quality, packaging, shipping, or launch readiness.

### 7.15 Phase 32 Nose Slice Acceptance

- Exactly four second-level nose subtools are implemented from existing public parameters: `大小`, `鼻翼`, `鼻梁`, and signed `鼻尖`.
- Acceptance requires 196/196 public-facade outputs, 30/30 portrait comparisons, distinct signed tip output, exact caps, missing/stale fail-closed zeroing, reused `0.5` scaling, safe no-face continuation, all-field combined weakening, redacted diagnostics, and active-source boundary evidence.
- `山根` does not borrow `noseBridge` evidence; it remains partial pending an explicit alias or independent parameter decision. `提升` remains future, and branch-level `鼻子` remains `partial`.
- `31-NOSE-RENDERER-EVIDENCE.md` and `32-NOSE-SAFETY-EVIDENCE.md` are the command-backed acceptance sources.
- This acceptance does not claim whole-branch completion, device parity, commercial review, broad reference parity, packaging, shipping, or launch readiness.

### 7.16 Phase 35 Independent Nose Contract Acceptance

- The prior unresolved alias decision is closed at the SDK contract level: `山根` maps to independent public `noseRootNarrowing`, and `提升` maps to independent public `noseTipLift`; neither borrows `noseBridge` or signed `noseTipSize` behavior.
- Acceptance requires an exact 33 stored-field model (32 numeric plus `filterId`), positive-only `0...1` values, default/non-finite zero, legacy JSON/preset/source-call compatibility, provisional `0.25` caps, and isolated facade routing with redacted evidence.
- Root narrowing must move only an explicit upper-root pair horizontally inward and tip lift must move only an explicit lower-tip subset vertically upward. Missing or malformed explicit support fails closed without legacy fallback; reused eligible geometry keeps exact `0.5`.
- `35-VERIFICATION.md` records fresh 106/106 focused and 219/219 full XCTest evidence, a clean final 24-file code review, and passing public/SPI, privacy, dependency, artifact, archive, and scope scans.
- `山根`, `提升`, and branch-level `鼻子` remain unpromoted/partial. Phase 36 still owns renderer/helper/gallery/ROI output evidence, and Phase 37 owns cap calibration, exhaustive six-field/once-only safety, boundary closeout, ledger promotion, and SDK-core branch completion.
- This acceptance does not claim renderer/gallery completion, calibrated caps, device parity, commercial review, packaging, shipping, or launch readiness. No Demo build was required because Phase 35 changed no Demo source.

### 7.17 Phase 37 Exact Nose SDK-Core Branch Acceptance

- Phase 37 promotes exactly `山根` → independent `noseRootNarrowing` and `提升` → independent `noseTipLift`; neither borrows `noseBridge` or signed `noseTipSize` evidence. Together with the four legacy rows, the exact six-row SDK-core `鼻子` branch is implemented.
- Acceptance requires final exact `0.25` caps, all-six zero/no-face/missing/provider-empty/stale/reused/transition behavior, exactly-once combined convergence, redacted diagnostics, and active-source boundaries.
- Fresh evidence passes 103/103 focused and 228/228 full SwiftPM tests. The unchanged public-facade output gate passes 252/252 outputs, 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons with ignored/untracked artifacts and `threats_open: 0`.
- SDK-core branch completion does not claim Demo UI, physical-device parity, subjective or commercial naturalness, optimized performance, packaging, shipping, launch readiness, broad reference-product parity, or a passed milestone audit.

### 7.18 Phase 38 Remaining Mouth Geometry Contract Acceptance

- The frozen independent host controls are signed `mouthYPosition`/`mouthTilt`/`mouthXPosition` and positive-only `lipPeakDefinition`/`lipPlump`; none aliases shipped size, width, smile, or lip color behavior.
- Acceptance requires exact 38-field compatibility, optional package-only inner-lip availability, deterministic private supports, distinct whole/peak/plump vectors, provisional `0.25` caps, exact reused `0.5`, eight-field provider eligibility, fourteen-removal convergence, isolated facade routing, redacted diagnostics, and a clean review.
- `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and branch-level `嘴唇` remain unpromoted pending Phase 39 output evidence and Phase 40 final safety/boundary closeout. `白牙` remains future.
- This acceptance does not claim saved-output/ROI/gallery evidence, final artistic caps, exhaustive transitions, device/commercial naturalness, performance certification, packaging, shipping, launch readiness, or milestone completion. No Demo build was required because Phase 38 changed no Demo source.

### 7.19 v1.10 Phase 40 Exact Mouth Geometry Acceptance

- Phase 40 promotes exactly `上下` → signed `mouthYPosition`, `倾斜` → signed `mouthTilt`, `左右` → signed `mouthXPosition`, `M唇` → positive-only `lipPeakDefinition`, and true `丰唇` → positive-only geometry `lipPlump` after independent contract, support, facade-output, safety, degradation, privacy, and boundary evidence.
- The exact `0.25` caps, exact reused `0.5`, selective missing-support behavior, and one provider-eligible combined retained set are automated acceptance criteria. `lipColor` remains color-only and supplies no true plump evidence.
- `白牙` remains future teeth-region segmentation/color retouch, so branch-level `嘴唇` remains `partial`. This closeout adds no Demo UI and makes no device, commercial visual, performance, packaging, shipping, or launch-readiness claim.

### 7.20 Phase 41 Public Eye Contract and Observed-Support Acceptance

- A host can set ten independent, default-zero controls without changing legacy behavior: positive-only `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry`, plus signed `eyeTilt`. Acceptance locks exact 48-field Codable/source compatibility and neutral legacy 38-key payloads.
- SDK-core acceptance requires one coordinate conversion for package-only request-scoped left/right contours and optional pupils, deterministic side/winding semantics, contour bounds of 6...16 points / 4 unique points / relative width `0.04...0.50` / height `0.01...0.30` / area above `0.0004`, plus pupil containment/offset/paired-ratio validation. These support ceilings are not visual-strength caps.
- Missing or invalid pupils make only `pupilSize` and `gazeCorrection` ineligible. Explicit missing or invalid contour sides do not borrow proxies and preserve the whole-eye fail-closed skip while unrelated domains remain safe. Diagnostics are fixed and aggregate-only.
- Automated acceptance is the full SwiftPM suite, 24/24 adversarial boundary self-tests, and 10/10 live checks with unchanged `f1c28fa` manifest/Demo baseline, clean active-source privacy/network/commercial scans, and ignored/untracked/unstaged output/gallery/staging/quarantine roots.
- This phase establishes scalar and private-support readiness only. It does not claim provider transforms, visual output, final caps, row or branch promotion, Demo UI, physical-device behavior, commercial naturalness, optimized performance, packaging, shipping, launch readiness, or full `眼睛` completion; those remain Phase 42-44 or later work.

### 7.21 Phase 45 Public Face Contract and Observed-Support Acceptance

- An SDK integrator can construct, normalize, encode, and decode independent positive-only `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` values. Acceptance requires exact 52-field storage, zero defaults, non-finite-to-zero behavior, neutral legacy 48-key decoding, independent unequal-value round trips, and unchanged bundled preset bytes.
- Honest support availability requires actual Vision face contour and median-line evidence from the existing request, one coordinate-mapping boundary, stable orientation/mirror direction, face-specific bounded open-path validation, and independent contour-only versus contour-plus-centerline eligibility. The synthetic seven-point face-box proxy is not observed evidence.
- Missing or malformed observed support must leave the selected face, shipped face controls, eligible eye/nose/lip siblings, and face-agnostic work intact. Automated acceptance covers the exact topology boundaries, six committed portraits through aggregate-only evidence, repeated and parallel request isolation, public/privacy/dependency/scope checks, and the complete SwiftPM regression suite.
- The four controls are intentionally neutral in Phase 45 even when set nonzero: they do not trigger detection, provider work, effective strengths, facade routing, rendering, saved output, Demo behavior, or product-row promotion. Phase 46 owns provider behavior, Phase 47 owns public output evidence, and Phase 48 owns final caps, exhaustive safety, and promotion.
- `去双下巴`, `去双下巴 Pro`, and `发际线` remain future pending an approved local semantic-region implementation and reproducible fixtures. This acceptance makes no Demo, physical-device, commercial-naturalness, optimized-performance, packaging, shipping, launch-readiness, or whole-`脸型` completion claim.

### 7.22 Phase 49 Public Eyebrow Contract and Observed-Support Acceptance

- An SDK integrator can construct, normalize, compare, reset, encode, and decode seven independent neutral fields: signed `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, and `eyebrowTilt`, plus positive-only `eyebrowPeakDefinition`. Acceptance requires exact 59 stored/58 numeric inventory, zero defaults, non-finite-to-zero behavior, independent unequal round trips, real legacy 52-key neutrality, and unchanged five-preset bytes.
- Honest support availability requires actual Apple Vision left/right eyebrow paths from the existing selected-face request, independent bounded preflight and open-path validation, exactly-once mapping, mapper-axis anatomical side, and stable face-right projection ordering into the provider's inner-to-outer trace. This handles a live Vision outline whose two raw endpoints can occupy the same anatomical end without using screen axes or synthetic points. Missing or malformed support fails locally: a valid sibling survives and existing face/eye/nose/mouth work is unchanged. Eye or synthetic proxy substitution is never acceptable.
- Automated acceptance requires focused parameter/resource/resolver/detection/adapter suites, 42/42 adversarial checker self-tests, a classified live checker, clean owner/source review, zero unresolved ASVS L1 HIGH findings, and full SwiftPM only after the sole active portrait fixture `example-images/input/portraits/p1.jpg` passes readable non-empty regular-file preflight. The fixture is rights-approved for long-term local internal evaluation, metadata-sanitized, and opaque-named; its exposed smile supports teeth containment/over-whitening review, but permission and visible teeth do not automatically establish feature polarity or commercial naturalness. Fixture absence is a visible environment blocker, not a waived test.
- All seven fields remain deliberately runtime-inert in Phase 49. This acceptance makes no claim for provider eligibility, effective caps/strengths, resolver/conflict/facade routing, visible output, renderer/gallery evidence, safety calibration, product-row or branch promotion, Demo/UI, device parity, commercial naturalness, optimized performance, packaging, shipping, or release readiness. Phase 50 owns geometry/pipeline behavior, Phase 51 output evidence, and Phase 52 safety/promotion.

### 7.23 Phase 50 SDK-Core Eyebrow Provider and Facade Acceptance

- An SDK integrator can submit seven independent eyebrow intents through the existing public facade. Vertical, thickness, length, whole spacing, head spacing, tilt, and peak reach distinct same-named provider vectors; none aliases an eye/face control or adds a special public/render route.
- Acceptance requires actual Phase 49 eyebrow support, field-local side/pair/chord/apex eligibility, provider-empty removal, fresh/full and reused exact `0.5` behavior, stale/no-face zeroing, request isolation, one exact 44-name convergence mask, and one unified Face→Chin→Eye→Eyebrow→Nose→Mouth dispatch. Representative missing/malformed inputs remove dependent work while safe siblings continue with fixed aggregate diagnostics.
- Fresh automated acceptance is provider 11/11, resolver 26/26, conflict 14/14, combined 15/15, degradation 48/48, pipeline 3/3, facade 18/18, BeautyEffects 243 with one opt-in skip, full SwiftPM 433 with three opt-in skips, plus fixture/checker/privacy/scope/artifact/diff gates.
- The `0.25` caps and all vector/radius/falloff choices are provisional. Phase 50 does not prove decoded visibility, ROI, direction, locality, distinction, final naturalness, final caps, exhaustive transitions, renderer/gallery inventory expansion, product-row/branch promotion, Demo/device/commercial/performance/packaging/shipping, or release readiness. Phase 51 owns output/gallery; Phase 52 owns final safety/promotion; v1.14-v1.16 remain future.

### 7.24 Phase 51 Public-Facade Eyebrow Output Acceptance

- An SDK integrator can exercise all thirteen isolated public eyebrow cases through the ordinary facade: positive and negative vertical position, thickness, length, whole spacing, head spacing, and tilt, plus positive peak definition. On the committed `e6` fixture every case is visibly brow-local, every signed pair moves in the intended opposite direction, and all seven families remain distinct; whole spacing does not collapse into head spacing and thickness does not collapse into peak.
- Acceptance requires exactly 72 decoded `e6` portrait outputs, thirteen separately reported no-face comparisons, and a 144-file disposable output/gallery bijection. Representative missing, malformed, partial, and no-face public-facade paths remain safe with aggregate-only diagnostics.
- Pixel checks do not substitute for product observation. The baseline and all thirteen actual `e6__eyebrow*.png` images were opened individually at original detail; the evidence table records one observation for each file and passes only because it agrees with fixed brow/protected-region, direction, and distinction gates. A future contradiction from actual-image review must reopen the gap even if automated thresholds pass.
- The visible provisional extremes are evidence fixtures, not a commercial-naturalness approval or final strength recommendation. Phase 52 still owns exact caps/dead zones, exhaustive lifecycle and convergence safety, the seven product-row statuses, branch `眉毛`, and privacy/promotion closeout. No Demo/UI, physical-device, optimized-performance, packaging, shipping, launch-readiness, v1.14-v1.16, or broader release claim follows.

### 7.25 Phase 53 Canonical Still-Image Boundary Acceptance

- An eventual independently admitted v1.14 still request has one deterministic input contract: finite integral decoded extent within the configured ceiling, valid orientation, known standard-range RGB, one up-oriented/not-mirrored zero-origin sRGB RGBA8 render, and fully opaque pixels before Vision. Exact-ceiling input succeeds; malformed orientation, unsupported color/range, overflow, one-over, and any transparent pixel return an existing typed payload-free error.
- Acceptance requires the same request-owned carrier backing to supply downstream image views, while the inactive 59-field facade remains unchanged and no candidate field, provider, renderer case, preset key, feature route, Demo/UI behavior, or realtime/pixel-buffer path is added. Package-only synthetic summaries prove the boundary without exporting raw bytes or creating new SPI.
- Automated evidence is 6/6 `BeautyCanonicalStillImageTests`, 6/6 checker self-tests with exact `16 = 13 automated + 3 flagged`, and clean diff hygiene. This does not prove encoded-byte/container or gain-map inspection from `CIImage`, HDR/transparent support, Vision/mask behavior, same-engine concurrency/cancellation, optimized performance, device/commercial quality, packaging, shipping, or release readiness.
- Before an independently evidence-gated feature is admitted, production local-retouch admission remains exactly empty. The ordinary CIImage facade has one private request foundation that can share a canonical raster and selected mapped support across future admitted work, but Phase 53 adds no visible feature, parameter, preset, provider, mask, transform, renderer case, Demo control, or realtime behavior.
- Acceptance for the request foundation is exact `canonicalize → detect/map → context → render` ordering for one or many opaque demands, safe color continuation when face/support is absent, fail-closed invalid input, valid-invalid-valid recovery, zero retained context, and zero pixel-buffer/reset local work. All 11 foundation tests pass; the three same-engine concurrency/cancellation rows remain flagged nonclaims under TD-013.
- Final acceptance is repository evidence, not feature promotion: the exact compatibility, privacy, boundary, focused, and 495-test full SwiftPM gates are green, while rights-approved positives/negatives and original-detail naturalness review remain Phase 54+ gates. No user-visible `白牙`, `祛红血丝`, or `去脂` behavior is admitted by Phase 53.

### 7.26 Phase 54 Evidence Eligibility Acceptance

- EVID-01 through EVID-05 and LID-01 implement D-01/D-04/D-09 through D-16 as an offline, one-feature-at-a-time evidence decision boundary. A feature becomes eligible only from a complete genuine positive/negative original-mask-after bundle whose manifest assertions resolve against a separately tracked grant bound to rights record, fixture, feature, polarity, trusted expected-target policy, permitted use, evidence classification, and the exact three asset keys and SHA-256 byte digests computed before selection, and whose frozen review set is accepted at original detail. The registry is intentionally empty until such a complete triple is independently pinned; invented/reused grants, rekeyed/substituted/swapped media, manifest-controlled target policy, and mechanics, synthetic, AI-generated, historical, parked, disabled, incomplete, or rejected rows have zero product weight.
- Current decisions are derived from the explicit empty eligible/review inventory and independently closed: teeth and sclera each record `missing_genuine_positive` plus `missing_genuine_negative`; upper-eyelid fullness records both missing polarities plus `non_warp_design_unqualified`. Each row has zero eligible/reviewed/accepted/rejected counts and zero naturalness weight. Authorization or possible negative context alone discharges no prerequisite; one sibling can open later without promoting another.
- A closed decision is successful fail-closed product behavior, not a placeholder. Exact absence remains the acceptance result: no product field, provider, renderer case, preset, admission route, inert fallback, Demo control, or realtime behavior is created, and Phase 53 production local-retouch admission stays exactly empty.
- D-02/D-03/D-05 through D-08 freeze structural validation, evidence qualification, immutable review, reducer independence, and the positive-allowlist durable export; D-13/D-14 keep upper-eyelid work conjunctive on genuine evidence and a reviewed credible non-warp design. Phase 54 evidence gates provide no device, population, calibration, commercial-naturalness, performance, packaging, shipping, or release-readiness credit.

### 7.24 Phase 46 Independent Contour and Chin Geometry Acceptance

- An SDK integrator can now send four independent intents through the existing public still-image facade: local contour continuity, upper-lateral temple fullness, mid-lateral cheekbone slimming, and apex-adjacent chin taper. Each request triggers one detection route and reaches its own package-internal provider vector rather than aliasing the five shipped face/chin controls.
- Acceptance requires actual observed contour support for all four controls and complete centerline/apex support for taper. Missing or malformed evidence disables only dependent work; no-face and stale input zero new work, eligible reuse is exact `0.5`, and valid shipped or independent siblings continue.
- The existing single geometry warp remains the delivery path. Provider-empty fields are absent from final strengths, domains, conflict totals/counts/scales, warnings, metrics, point counts, and dispatch; public results expose only preserved extent, existing summaries, generic warnings, and aggregate metrics.
- Automated acceptance is 17/17 provider, 21/21 resolver, 13/13 conflict, 14/14 combined, 2/2 pipeline, 43/43 degradation, 15/15 facade, 368-test full SwiftPM with three opt-in Apple Vision skips, and 24/24 self plus 14/14 live boundary checks.
- The `0.25` caps and geometric constants remain provisional. This phase does not prove decoded pixel visibility, ROI locality, subjective/commercial naturalness, final caps, exhaustive nine-face/37-field safety, gallery publication, product-row or branch promotion, Demo/device behavior, optimized performance, packaging, shipping, or launch readiness. Phase 47 owns decoded output and Phase 48 owns final safety/promotion.
- `去双下巴`, `去双下巴 Pro`, `发际线`, and whole-`脸型` completion remain future or partial; no entitlement interpretation or semantic proxy is introduced.

## 8. Preset Product Contract

MVP built-in presets:

| Preset | Intent | Constraints |
| --- | --- | --- |
| Natural | Slightly cleaner and more energetic, still recognizably original. | Conservative skin, face, eyes, and filter values. |
| Clear | Brighter and cleaner skin tone. | Avoid overexposure and fake-white skin. |
| Refined | More polished for photos. | Balanced face and eye adjustments; no aggressive geometry. |
| Male Natural | Cleaner and sharper with minimal reshaping. | Avoid heavy makeup and strong face thinning. |
| ID Photo Natural | Clean, neutral, restrained. | No strong filter, no dramatic face change, preserve identity. |

Preset rules:

- Presets are parameter bundles, not hidden algorithms.
- Presets must pass parameter validation and safety caps.
- Presets must be deterministic.
- Presets must be named with stable IDs for tests.
- Product copy must not promise identity-changing results.

Phase 5 automated evidence:

- `BeautySDKResources.builtInPresets()` exposes five built-in presets through the public facade only.
- `BeautySDKResources.availableFilters()` exposes `soft_clean` / `Soft Clean` and `warm_light` / `Warm Light` as metadata-only filters.
- Demo preset chips apply full parameter snapshots and synchronize visible skin, color, filter, and intensity controls.
- Demo Filters panel supports `None`, `Soft Clean`, `Warm Light`, and `Filter Intensity`; missing resource copy is friendly and redacted.
- Phase 6 now makes presets, color, filters, skin, face shape, eyes, nose, mouth, and lip color visibly effective through deterministic MVP output; final artistic quality remains a manual visual QA gate.

## 9. Scenario Matrix

| Scenario | MVP | Later |
| --- | --- | --- |
| Selfie camera preview | Required | Higher-quality makeup and segmentation. |
| Album image edit | Required | Batch processing and export presets. |
| Short video record preview | Frame API ready | Recording pipeline and audio sync. |
| Live streaming / video call | Frame API ready | Latency-specific optimization. |
| ID photo | Basic natural preset | Dedicated background, attire, stricter identity preservation. |
| Group photo | Deterministic subset or limited faces | Per-face parameters and manual face selection. |
| Low light selfie | Basic color and skin controls | Scene-aware enhancement. |
| Children | Not MVP preset unless designed | Protective mode with strong restrictions. |

## 10. Anti-Goals

Current anti-goals:

- Do not build a standalone consumer editing app.
- Do not put SwiftUI or UIKit UI inside SDK targets.
- Do not promise 4K realtime preview in first version.
- Do not add cloud processing or uploads by default.
- Do not implement all product-plan features before MVP is stable.
- Do not split eye/nose/mouth/face into separate packages.
- Do not expose debug internals as normal public API.
- Do not chase maximum beauty strength at the cost of naturalness.

## 11. Product Regression Checklist

Before merging product-facing changes, verify:

- The change maps to a documented journey or adds a new one here.
- New public behavior has an acceptance criterion.
- New parameter has a default no-effect state unless explicitly justified.
- New preset passes validation and UI sync.
- New effect declares whether it works with no face, missing landmarks, and low-confidence faces.
- New UI control has reset, default, disabled, and accessibility behavior.
- New resource-backed feature defines missing-resource behavior.
- Performance and reliability impact is recorded in `RELIABILITY.md` if user-visible.
- Security/privacy impact is recorded in `SECURITY.md` if data boundary changes.

## 12. Product Decision Log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | MVP prioritizes realtime preview, still image processing, parameters, presets, and natural core face/skin controls. | This proves SDK integration value before advanced effects. |
| 2026-05-25 | Naturalness is a product invariant, not a style preference. | Beauty SDK trust depends on avoiding obvious distortion. |
| 2026-05-25 | Presets are complete parameter bundles. | Keeps one-tap UX deterministic and testable. |
| 2026-05-25 | Later domains stay visible but not blocking: makeup, segmentation, body, video export. | Prevents scope creep while preserving architecture direction. |
| 2026-07-06 | Phase 26 proves public still-image geometry intent without claiming visible geometry output. | Host apps can exercise detection-backed planning through `BeautyEngine.processResult(...)`, while saved-output quality and `脸型` completion remain later evidence gates. |
| 2026-07-07 | Phase 27 proves SDK-only saved-output geometry foundation without promoting per-tool face-shape status. | The renderer/helper path now verifies same-dimension geometry outputs and degradation evidence, while Phase 28 remains the owner for `脸型` tool completion. |
| 2026-07-08 | Phase 28 promotes only the scoped existing-parameter `脸型` rows after per-tool saved-output evidence passes. | `下颌线` stays a `jawSlim` alias, branch-level `脸型` remains partial, and broader UI/device/commercial claims stay out of scope. |
| 2026-07-16 | Phase 41 accepts ten compatible public eye scalars only with validated private observed support and fail-closed privacy/scope evidence. | Honest pupil/gaze/symmetry readiness requires request-scoped observed evidence; provider semantics, visual caps, output, and promotion remain downstream. |

### v1.11 Phase 44 Eye Geometry Acceptance

- Automated SDK evidence independently implements exactly `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称`.
- `去脂` and `祛红血丝` remain future retouch/color work, so branch `眼睛` remains `partial`.
- Acceptance is limited to contract, provider, saved-output, exact safety/degradation, privacy, boundary, and owner evidence. It is not device parity, subjective/commercial approval, optimized performance, packaging, shipping, or launch readiness.

### v1.12 Phase 48 Face Safety Acceptance

- An SDK integrator can independently request `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` through the existing public still-image facade, with exact final caps, field-local degradation, saved-output visibility/locality, and redacted aggregate evidence.
- `去双下巴`, `去双下巴 Pro`, and `发际线` remain future until approved local semantic-region/segmentation implementations and reproducible clean-clone fixtures exist. Branch `脸型` remains `partial`.
- Acceptance is automated at the SDK/source/output boundary only. It is not physical-device parity, subjective or commercial naturalness approval, optimized performance, Demo completion, packaging, shipping, launch readiness, or milestone lifecycle evidence.

### v1.13 Phase 52 Eyebrow Safety Acceptance

- An SDK integrator can independently request exactly seven implemented SDK-core controls through the existing public facade: `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`. Signed controls preserve both directions, whole spacing remains distinct from head spacing, and thickness remains distinct from peak definition.
- User-verifiable acceptance requires final exact caps, request-local support, local degradation, complete combined-safety behavior, facade-visible direction/locality/distinction, fourteen-file original-detail review, and redacted aggregate diagnostics. Branch `眉毛` is implemented only at this SDK-core boundary.
- v1.14-v1.16 remain future milestones. No SwiftUI or Demo UI, physical-device parity, commercial naturalness approval, optimized performance, packaging, shipping, launch or release readiness, independent milestone audit, archive, tag, or cleanup follows from Phase 52.

### v1.14 Phase 55 Feature-Neutral Composition Acceptance

- Phase 55 accepts deterministic original-pixel composition mechanics only: exact canonical-source binding, hard-reclipped ownership, collision-to-source, smallest-unit failure isolation, request recovery, and aggregate-only facade evidence are automated.
- All three Phase 54 product decisions remain closed with exact absence and zero product weight. Production admission is empty, so no visible teeth whitening, sclera redness reduction, eyelid fullness, candidate field, provider, renderer case, preset, Demo control, or realtime behavior is available.
- The tiny opaque fixture results do not establish feature effectiveness, naturalness, device quality, optimized performance, commercial suitability, packaging, shipping, launch, or release readiness. Future feature slices must independently satisfy their evidence and product gates before admission.
