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
| Error | Invalid image returns typed error and preserves previous output. |
| Compare | Before/after uses same crop/orientation and does not shift unexpectedly. |

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
