# ARCHITECTURE.md

> `beauty` 的系统蓝图。本文定义域、包、依赖方向和跨界限制。
> 业务细节写入 `PRODUCT_SENSE.md`，数据结构与状态机写入 `DESIGN.md`。

## 1. 架构目标

`beauty` 的目标是形成可嵌入 iOS App 的美颜 SDK：App 负责 UI 与业务编排，SDK 负责图像输入、参数模型、检测、渲染、效果、资源加载和对外 API。

当前仓库状态：

- 已存在 `BeautyDemo/` Xcode Demo App。
- 已存在 `BeautySDK/` Swift Package，包含 `BeautyCore`、`BeautyDetection`、`BeautyRender`、`BeautyEffects`、`BeautyResources` 和 public `BeautySDK` facade。
- v1.13 当前 public 参数模型是精确 59 stored fields；`BeautyEffects` 拥有颜色/皮肤处理、44-field provider-eligible 几何解析、统一冲突弱化和内部几何输出，Demo 仍只通过 public `BeautySDK` facade 集成。
- public still-image facade 仅在参数需要几何时运行 `VisionFaceDetector`，把一个 package-only selected observation 路由到 `BeautyEffects`；public API 只暴露 redacted `BeautyDetectionSummary`、warnings 和 aggregate metrics。
- public pixel-buffer facade 当前不运行人脸检测或几何 provider。它校验 BGRA 输入、解析无需人脸的有效效果并通过 `BeautyColorEffectPipeline` 产生新的 `CVPixelBuffer`；实时几何、检测降频和 Metal warp 仍是未实现边界，不得由架构图暗示为现状。
- still-image 几何通过内部 `BeautyGeometryEffectPipeline` 的局部 CIImage warp 合并输出；`BeautyRender.RenderGraph`、`CopyRenderPass`、`PixelBufferFactory` 和 placeholder `Warp.metal` 是已编译基础件，但当前 `BeautyEngine` 处理入口尚未调度 `RenderGraph` 或真实 Metal warp。
- `BeautyExampleRenderer` 只 import `BeautySDK`，递归读取 committed fixtures，并把生成 PNG 保持为 ignored、untracked 的本地证据。
- `docs/` 下存在历史规划资料，迁移后的根级文档优先级更高。

## 2. 顶层不变量

| ID | 不变量 | 说明 |
| --- | --- | --- |
| A1 | SDK 不包含 UI 页面 | SDK 内禁止 SwiftUI View、UIKit 页面、按钮、滑杆、相册页。 |
| A2 | App 不访问 SDK 内部实现 | Demo App 只能依赖 `BeautySDK` 对外门面。 |
| A3 | 实时处理链路不经过 `UIImage` | 当前 Camera adapter 传递 `CMSampleBuffer` / `CVPixelBuffer`，SDK 返回新的 BGRA `CVPixelBuffer`；未来 Metal 化也不得引入 `UIImage` 中转。 |
| A4 | 检测与渲染解耦 | Vision/Core ML 只产出内部检测模型，不直接编码 Metal pass。 |
| A5 | 几何形变统一合并 | 脸、下巴、眼、眉、鼻、嘴的控制点只进入现有内部 `BeautyGeometryEffectPipeline`；禁止按功能建立第二条 warp 路径。 |
| A6 | 参数模型统一归一化 | 对外强度使用稳定范围，内部算法不得各自发明公共参数格式。 |
| A7 | 资源加载集中管理 | LUT、妆容贴图、模型文件、shader 资源由资源层统一定位和校验。 |
| A8 | 依赖只能向内层流动 | 任何 Target 不得反向 import 上层 Target。 |
| A9 | Diagnostics 随核心模型下沉 | 第一版日志、错误上下文、metrics 事件放在 `BeautyCore/Diagnostics`，不单独拆 Package。 |

## 3. 推荐包结构

第一版采用一个 Swift Package：`BeautySDK`，内部用多个 Target 拆分职责。

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautyCore/
│   │   └── Diagnostics/
│   ├── BeautyDetection/
│   ├── BeautyRender/
│   │   └── Shaders/
│   ├── BeautyEffects/
│   ├── BeautyResources/
│   └── BeautySDK/
└── Tests/
    ├── BeautyCoreTests/
    ├── BeautyDetectionTests/
    ├── BeautyRenderTests/
    ├── BeautyEffectsTests/
    └── BeautyResourcesTests/
```

`BeautyDemo/` 作为集成示例 App 存在于 Package 外部。

## 4. 依赖方向

```text
BeautyCore
    ↑
    ├── BeautyResources
    ├── BeautyDetection
    └── BeautyRender
             ↑
BeautyEffects ──────── uses detection models and render primitives
    ↑
BeautySDK
    ↑
BeautyDemo
```

允许依赖表：

| Target | 可以依赖 | 禁止依赖 |
| --- | --- | --- |
| `BeautyCore` | Foundation、CoreGraphics、CoreVideo、Core Image、ImageIO、OSLog 等基础公共输入库 | SwiftUI、UIKit 页面、Vision、Metal、App 代码 |
| `BeautyResources` | `BeautyCore`、Foundation | SwiftUI、App 代码、业务 UI 状态 |
| `BeautyDetection` | `BeautyCore`、Vision、Core ML 可选 | SwiftUI、Metal pass、App 代码 |
| `BeautyRender` | `BeautyCore`、Metal、Core Image、MPS 可选 | SwiftUI、Vision 实现、App 代码 |
| `BeautyEffects` | `BeautyCore`、`BeautyDetection`、`BeautyRender`、`BeautyResources` | SwiftUI、App 代码、独立相机 UI |
| `BeautySDK` | 全部内部 Target | SwiftUI View、UIKit 页面、Demo 状态 |
| `BeautyDemo` | `BeautySDK`、SwiftUI、AVFoundation | 内部 Target 直接 import |

禁止形成循环依赖。若某个类型被两个 Target 共同需要，优先下沉到 `BeautyCore`。

## 5. 领域划分

| Domain | 所属 Target | 职责 | 非职责 |
| --- | --- | --- | --- |
| Public SDK Facade | `BeautySDK` | `BeautyEngine`、对外配置、图片/视频/实时帧入口 | UI、具体页面状态 |
| Core Types | `BeautyCore` | 参数、错误、输入 metadata、结果/检测摘要、帧模型、warnings 和共享值类型 | Vision/Metal 具体实现、Engine 门面 |
| Diagnostics | `BeautyCore/Diagnostics` | 错误上下文与 validation warning 值类型 | 尚未存在的 logger/sink、上传、业务埋点 |
| Detection | `BeautyDetection` | Vision 人脸检测、关键点解析、坐标映射、多人脸选择、package-only observed support | 渲染 pass、UI 绘制、尚未实现的实时检测降频/平滑 |
| Render | `BeautyRender` | `RenderGraph` / `RenderPass` 基础件、copy pass、pixel-buffer factory、placeholder shader 资源 | 当前 Engine 效果调度、检测算法、SwiftUI 状态 |
| Effects | `BeautyEffects` | 美颜、滤镜、五官形变、妆容、分割效果的组合逻辑 | 独立 Package、UI 面板 |
| Resources | `BeautyResources` | LUT、shader、妆容包、模型、资源版本与校验 | 业务下载策略、页面展示 |
| Demo App | `BeautyDemo` | 相机页、预览、滑杆、预设面板、调试可视化 | SDK 内部实现 |

## 6. Target 责任

### 6.1 BeautyCore

稳定内核。只放跨模块共享的轻量类型：

- `BeautyParameters`
- `BeautyConfiguration`
- `BeautyError`
- `BeautyFrame`
- `BeautyInputMetadata`
- `BeautyDetectionSummary`
- `BeautyResult`
- 渲染质量、日志等级、warnings 和错误上下文等跨模块值类型

规则：

- 优先 `struct`、`enum`、`protocol`。
- 可跨并发域传递的类型必须显式满足 `Sendable`。
- 不持有 `MTLDevice`、`VNRequest`、SwiftUI 状态。
- Diagnostics 默认只提供本地实现；上传、远端诊断和业务埋点必须经过 `SECURITY.md` 的网络与隐私设计。

### 6.2 BeautyDetection

检测域。负责把平台检测结果转换为 SDK 内部模型：

- `VisionFaceDetector`
- `CoordinateMapper`
- `FaceSelectionPolicy`
- package-only `BeautyFaceObservation`、landmark group 与 observed-support values

规则：

- public 输出只能是 `BeautyCore` 中的模型；package-only 观察值由 `BeautyDetection` 自己拥有。
- 不直接触发 render pass。
- 不把 Vision 坐标泄漏到 `BeautySDK` 对外 API。
- `VisionFaceDetector`、`CoordinateMapper`、`BeautyFaceObservation`、landmark groups 和 Vision bounding boxes 都停留在 `BeautyDetection` 内部。
- 对外只通过 `BeautySDK` facade 暴露 `BeautyInputMetadata` 与 geometry-free 的 `BeautyDetectionSummary`。
- Phase 26 允许 `BeautySDK` 通过 package-only seam 调用 `VisionFaceDetector` 并选择一个 usable face；该 seam 不允许 Demo 或 public API 访问 raw observation、bounding box、landmark、Vision object 或 provider internals。
- 坐标映射的规范出口是 image-normalized SDK 模型；preview / mirrored preview 只属于 App 展示层。

### 6.3 BeautyRender

渲染域。当前提供 pass 抽象、copy 基础件、buffer factory 与 shader resource：

- `RenderGraph`
- `RenderPass`
- `CopyRenderPass`
- `PixelBufferFactory`
- `Shaders/Warp.metal`

当前 `Warp.metal` 是 copy placeholder，`RenderGraph` 尚未接入 public engine
processing path。真实 Metal context、texture cache、pipeline state 和 warp pass
只能在后续明确范围内加入，不能从文件名推断已经存在。

规则：

- 实时链路禁止 `UIImage` 中转。
- 未来 Metal 资源必须由渲染层统一创建、复用和释放。
- Render pass 必须明确输入纹理、输出纹理、参数和失败模式。
- 核心几何 shader 文件名统一为 `Warp.metal`。

### 6.4 BeautyEffects

效果域。负责把参数、检测结果和资源组合为可执行效果：

- 基础颜色与滤镜
- 磨皮、美白、红润
- 眼、鼻、嘴、脸型的 `WarpControlPointProvider`
- 妆容、分割、身体美型的后续扩展入口
- Phase 6 当前实现：`BeautyEffectResolver`、`BeautySafetyCaps`、脸型/眼/鼻/嘴 provider、合并几何弱化、唇色 mouth-region 输出、颜色/滤镜 MVP 输出、warning/metric 证据。

规则：

- 五官功能是 `BeautyEffects` 内部模块，不拆成独立 Package。
- 多个几何效果只产出控制点，统一交给当前内部 `BeautyGeometryEffectPipeline`。
- 新效果必须声明依赖：是否需要人脸点、资源、额外模型、额外 pass。
- 算法级安全 cap、combined weakening、missing-landmark skip 和 stale/reused 降级只改变内部 effective strength，不收窄 public `BeautyParameters` 范围。
- `BeautyEffects` 可以使用内部 `FaceGeometry`/`WarpControlPoint` 适配层，但不得把控制点、bounding box、landmark 或 provider 类型暴露给 `BeautySDK` public facade 或 Demo。
- Phase 26 的 `BeautyFaceGeometryAdapter` 只把 selected package observation 转成内部 `FaceGeometry` planning input；它不是 public geometry export，也不是 renderer saved-output evidence。
- Phase 27 的 still-image geometry render output 只通过内部 `BeautyColorEffectPipeline` selected-face overload 和 `BeautyGeometryEffectPipeline` CIImage local warp 证明 foundation evidence；它不是新的 public raw geometry surface，也不是 Demo UI behavior。
- Phase 28 的 per-tool face-shape evidence 只覆盖 existing public parameters `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`；`下颌线` 仍是 `jawSlim` alias，不新增单独 provider 或 public parameter。
- Phase 35 保持 `FaceGeometry.nose` 为四个既有鼻部 helper 的 legacy proxy；新增的 package-internal、default-empty `noseRoot` / `noseTip` explicit supports 只供 `noseRootNarrowing` / `noseTipLift` helper 使用，禁止回退借用 legacy proxy，也绝不跨越 public `BeautySDK` facade。该边界由 `35-VERIFICATION.md` 的 public/SPI 与 redacted diagnostics 扫描负责验证。
- Phase 37 closes the exact six-field SDK-core nose branch while preserving the same facade and package boundary: `noseRootNarrowing` and `noseTipLift` remain public scalars, their explicit root/tip geometry remains package-internal, all six nose providers feed the existing unified warp path, and no raw support or control point crosses the public `BeautySDK` facade.
- Phase 38 preserves that boundary for the five remaining mouth-geometry scalars. The shipped eight-point `outerLips` proxy remains unchanged; package-internal, default-empty `upperLips`, `lowerLips`, and `innerLips` supports feed only `MouthWarpProvider`, and all eight mouth geometry fields continue through the existing resolver, unified warp path, and aggregate-only public facade.

### 6.5 BeautyResources

资源域。负责 SDK 自带资源的定位、版本和校验：

- LUT
- Metal shader 资源
- 妆容贴图与配置
- Core ML 模型或分割模型
- 默认预设
- Phase 5 当前实现：`manifest.json`、五个内置 preset JSON、两个 metadata-only filter 定义。
- 内置 filters 只声明稳定 ID 与展示名；Phase 5 不包含 `.cube`、缩略图、色卡或真实 LUT 资产。

规则：

- 资源路径不得散落在效果或 UI 层。
- 外部导入资源必须经过 `SECURITY.md` 定义的校验。
- 资源版本变化需要记录兼容性影响。
- Bundle 资源由 `BeautyResourceCatalog` 解析；资源 ID 必须先通过保守 identifier 校验，不能被解释为路径。

### 6.6 BeautySDK

聚合门面。App 侧只 import 这一层：

```swift
import BeautySDK
```

职责：

- 暴露 `BeautyEngine`。
- 暴露稳定的配置、参数、错误和处理入口。
- 暴露逐帧 `BeautyInputMetadata` 与不含人脸几何的 `BeautyDetectionSummary`。
- 暴露 `BeautySDKResources`，让 App 获取内置 filters、presets，并在提交参数前验证 filter 引用。
- 隐藏 Vision、Metal、Core Image、Target 拆分细节。
- 把内部错误映射为稳定 SDK 错误。
- Phase 26 的 still-image `BeautyEngine.processResult(image:metadata:parameters:)` 在 face-shape、eye、nose、mouth 或 `lipColor` 参数需要几何时触发检测；no-op/color/filter/basic-skin 路径保留 `.notRun`，disabled tracking 保留 `.disabled`。
- Phase 27 的 still-image `BeautyEngine.processResult(image:metadata:parameters:)` 在 usable selected face 存在时把几何意图传入内部 image render path；public result 仍只包含 output image、redacted summary、warnings 和 aggregate metrics。

### 6.7 BeautyDemo

示例 App。用于验证 SDK 集成体验：

- SwiftUI 页面
- 相机输入
- Metal 预览容器
- 参数滑杆
- 预设面板
- Debug overlay

规则：

- Demo 不直接 import `BeautyCore`、`BeautyRender`、`BeautyDetection`、`BeautyEffects`。
- Demo 不实现 SDK 私有算法。
- Demo 对检测状态的展示只读取 `BeautyDetectionSummary`，不得读取 Vision observation、bounding box 或 landmark 坐标。
- Demo 中发现的通用能力必须回流到 SDK，而不是停留在 UI 层。

## 7. 数据流

实时预览路径：

```text
Camera CMSampleBuffer
→ BeautyDemo adapter
→ BeautyEngine.processResult(pixelBuffer:metadata:parameters:)
→ validate BGRA input and filter reference
→ BeautyEffects resolves face-independent work without selected geometry
→ BeautyColorEffectPipeline creates a processed CVPixelBuffer
→ BeautyDemo preview
```

当前实时路径不会调用 `VisionFaceDetector`、`RenderGraph` 或 Metal warp；需要
人脸几何的字段会按无 geometry 上下文降级。上述能力若要进入实时路径，必须先
建立独立的检测 freshness、backpressure、render ownership 和设备证据契约。

离线图片路径：

```text
Image input
→ BeautyEngine.processResult(image:metadata:parameters:)
→ validate finite non-empty CIImage extent and filter reference
→ optional Vision detection only when parameters require face geometry
→ BeautyEffects resolve + color/lip processing
→ one internal local CIImage geometry pipeline when a selected face is usable
→ output CIImage with redacted result metadata
```

参数路径：

```text
BeautyDemo sliders / presets
→ BeautyParameters
→ BeautyEngine.process(..., parameters:)
→ Effects read immutable snapshot
→ current color/geometry pipeline receives normalized effective strengths
```

## 8. 跨界限制

| 边界 | 允许 | 禁止 |
| --- | --- | --- |
| App → SDK | 调用 `BeautyEngine`、传入参数、接收结果 | 直接访问内部 Target、操作 `MTLCommandBuffer` |
| SDK → App | 回调稳定结果、错误、指标 | 持有 ViewModel、调用 SwiftUI/UIKit 页面 |
| Detection → Effects | 通过 package-only `BeautyFaceObservation` 间接协作 | 检测层创建 effect provider 或 render pass |
| Effects → Render | 提供 pass 配置、控制点、uniform | 效果层私自管理全局 Metal 设备 |
| Resources → Effects | 提供已校验资源句柄 | 效果层硬编码 bundle 路径 |
| Core → Any | 定义共享类型 | 依赖上层实现 |

## 9. 扩展规则

新增能力时先判断归属：

| 新能力 | 默认归属 |
| --- | --- |
| 新公共参数 | `BeautyCore`，并同步 `DESIGN.md` |
| 新人脸/人体检测实现 | `BeautyDetection` |
| 新 shader 或 render pass | `BeautyRender` |
| 新美颜、五官、妆容、滤镜效果 | `BeautyEffects` |
| 新 LUT、模型、妆容包 | `BeautyResources` |
| 新滑杆、面板、调试视图 | `BeautyDemo` 与 `FRONTEND.md` |

只有当某一领域出现独立发布、独立版本、独立团队维护需求时，才考虑拆成新的 Package。第一版禁止按眼、鼻、嘴、脸型拆 Package。

## 10. 验证要求

架构相关改动必须至少完成一种验证：

- 依赖改动：检查 `Package.swift` 或 Xcode target 依赖无反向引用。
- 公共 API 改动：新增或更新编译验证与接口说明。
- 渲染链路改动：证明实时路径未引入 `UIImage` 中转。
- 检测链路改动：证明输出仍为 `BeautyCore` 模型，且 public/Demo 表面不暴露 point、rect、bounding box、landmark、raw Vision object、raw framework error 或本地路径。
- Demo 集成改动：证明 Demo 只依赖 `BeautySDK` 门面。

无法运行验证时，必须在 `PLANS.md` 记录原因、风险和下一步。

## 11. 决策记录

### v1.10 Phase 40 Mouth Geometry Closeout

- The public facade remains the sole host boundary for the exact 38 stored `BeautyParameters` fields, including `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump`.
- Upper/lower/inner lip supports remain package-internal to `BeautyDetection` and `BeautyEffects`; neither the Demo nor example renderer imports them, and diagnostics expose only aggregate redacted state.
- One provider-eligible retained geometry set feeds conflict scaling and final emission, with at most fourteen nose/mouth removals. Phase 40 changes no target dependency direction, public raw-geometry surface, network path, commercial path, or Demo UI.

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-24 | 第一版采用一个 `BeautySDK` Swift Package，内部多 Target。 | 共享检测、坐标、Metal 上下文和形变系统，避免多 Package 重复依赖。 |
| 2026-05-24 | UI 完全放在 `BeautyDemo` 或宿主 App。 | SDK 作为可集成能力，不绑定业务页面和交互样式。 |
| 2026-05-24 | 五官几何形变统一进入一个形变 pass。 | 降低纹理读写次数，减少参数冲突，提高实时性能。 |
| 2026-07-13 | v1.7 鼻子 slice 继续复用统一 geometry pass 与 public `BeautySDK` facade，不拆 Package、不新增 public geometry。 | 四个既有 nose 参数可在现有 provider/resolver/render seams 内完成；保持 Demo facade-only 与 raw-geometry 边界。 |

### v1.11 Phase 44 Eye Geometry Closeout

- The 48-field scalar `BeautyParameters` contract remains behind the public `BeautySDK` facade; request-scoped observed support stays package-internal to detection/effects and the unified warp.
- The local-first dependency direction is unchanged: no external dependency, package target, network/cloud, commercial path, public raw geometry, or new source owner was added.
- The example renderer and no Demo code import internal SDK modules. Phase 44 is an SDK-core safety/status closeout with no Demo feature change.

### Phase 46 Independent Contour and Chin Geometry

- `BeautyEffects` owns exactly seven package-internal face emissions and two chin emissions. Each shipped or new scalar has one named array and field-local eligibility; the five shipped face/chin arrays preserve their prior compatibility-proxy vectors.
- `BeautyEffectResolver` keeps one provider-eligible retained baseline across face, chin, eye, nose, and mouth. At most 37 monotone removal passes precede one final provider-array accounting step; the existing `BeautyGeometryEffectPipeline` remains the only warp path.
- Detection supplies request-scoped observed contour/median evidence through the existing mapper and adapter. `BeautySDK` exposes only the established result, warnings, and aggregate metrics; no new public geometry type, facade method, target, dependency direction, render pass, or Demo import was introduced.
- Fresh evidence passes 17 provider, 21 resolver, 13 conflict, 14 combined, 2 pipeline, 43 degradation, and 15 facade tests; full SwiftPM passes 368 tests with three explicit Apple Vision opt-in skips. Phase 47 owns decoded-output evidence, while Phase 48 owns final calibration, exhaustive matrices, and promotion.

### Phase 48 Face Safety Architecture Closeout

- Phase 48 preserves the public `BeautySDK` facade and the local-first dependency direction: `BeautyDetection` maps request evidence, package-internal `BeautyEffects` providers resolve nine face/chin fields, and the existing `BeautyRender` unified warp remains the only delivery path.
- The exact active-source inventory is eight classified files. Observed support remains package-internal; no public geometry carrier, package target, external dependency, resource/model, network/cloud path, render pass, or new source owner exists.
- The renderer imports only `BeautySDK`, and there is no Demo source or behavior change. Four blueprint rows are implemented while three semantic-region rows and branch `脸型` remain future/partial.

### Phase 49 Eyebrow Observation Package Boundary

- `BeautyDetection` owns the single-request seam: `VisionFaceDetector` reads the selected observation's actual `leftEyebrow` and `rightEyebrow`, independently preflights them, copies coordinate values, derives face-local axes through the same request-local `CoordinateMapper`, maps each accepted eyebrow point exactly once, then stably orders the mapped sample multiset by the face-right projection required by the provider's inner-to-outer trace contract. It emits package-only `BeautyObservedEyebrowSupport`, retains no Vision region object, and performs no second request, retry, cache, or remap.
- `BeautyEffects` owns the target-internal semantic seam: `BeautyFaceGeometryAdapter` validates each mapped open path and attaches optional `BeautyEyebrowSemanticSupport` beside existing `FaceGeometry` siblings. The dependency remains `BeautyEffects -> BeautyDetection -> BeautyCore`; no public/SPI support type is moved into `BeautyCore`, and `BeautyDetection` never imports or calls an effects provider or render pass.
- Both carriers are immutable and request-scoped. They have no persistence, network, resource/model, shared actor/global state, or cross-request owner. Invalid left/right regions fail locally; existing face, eye, nose, and mouth geometry remains structurally separate.
- Phase 49 has no consumer beyond validation and attachment: no eyebrow provider, resolver/conflict/facade route, renderer/gallery case, Demo/UI import, feature-ledger promotion, dependency, target, model, or resource change exists. Phase 50 may add consumers while preserving this direction; Phases 51-52 remain responsible for output and safety/promotion evidence.

### Phase 50 Eyebrow Provider and Pipeline Boundary

- `BeautyEffects` now owns one package-internal `EyebrowWarpProvider` with seven named emissions. Its only eyebrow geometry input is the immutable canonical support established by Phase 49; it does not import Vision objects, synthesize support, or move support into `BeautyCore` or the public/SPI surface.
- One resolver-owned retained mask covers exactly 44 provider-eligible names. The existing unified warp consumes the final arrays once in stable Face → Chin → Eye → Eyebrow → Nose → Mouth order; there is no eyebrow-specific facade, renderer, pre-warp pass, or second dispatch.
- Dependency direction remains `BeautySDK` facade → `BeautyEffects` planning/provider → `BeautyDetection` support → `BeautyCore`, with `BeautyRender` remaining the unified delivery owner. `Package.swift`, targets, external dependencies, resources/models, privacy manifest, network policy, and Demo imports are unchanged.
- Fresh Phase 50 evidence passes the fixture/checker gates, 243 BeautyEffects tests with one opt-in skip, and 433 full SwiftPM tests with three opt-in skips. This proves compiled provider/routing only: Phase 51 owns decoded output/gallery evidence; Phase 52 owns final caps, exhaustive safety, and promotion. v1.14-v1.16, UI/device/commercial/performance/packaging/shipping/release claims remain out of scope.

### Phase 51 Public-Facade Eyebrow Output Boundary

- Phase 51 adds thirteen isolated eyebrow cases inside the existing 72-case renderer inventory. Every case enters through the public `BeautySDK` facade, uses the one `BeautyEngine.processResult` call, and reaches the existing package-internal one-warp route; the renderer neither imports an internal target nor creates an eyebrow-specific render path.
- The evidence matrix is one active portrait across all 72 cases plus a separate no-face fixture, yielding 144 disposable output/gallery files. Gallery grouping changes presentation only and creates no new package, dependency, model, resource, Demo owner, or runtime route.
- Decoded visibility, direction, locality, family distinction, gallery containment, and actual-image review close output evidence only. Phase 52 retains final caps, exhaustive safety, seven row and `眉毛` branch promotion, and every Demo/device/commercial/performance/packaging/shipping/release decision.

### Phase 52 Eyebrow Safety Architecture Closeout

- The existing local dependency direction remains unchanged: public `BeautySDK` intent reaches `BeautyEffects`, which consumes only actual immutable request-local eyebrow evidence mapped by `BeautyDetection`; `BeautyRender` remains the single unified delivery owner.
- `BeautySafetyCaps` is the sole maximum authority for all seven eyebrow evaluations. One package-internal eyebrow provider retains seven named emissions, and one resolver-owned 44-field inventory supplies final accounting without a second route or support substitute.
- Final arrays enter the existing warp exactly once in stable Face → Chin → Eye → Eyebrow → Nose → Mouth order. No public geometry carrier, target, dependency, model, resource, render pass, facade method, source owner, or Demo import was added.
- Phase 52 therefore closes the seven-field SDK-core architecture only. It adds no Demo or UI behavior and establishes no device, commercial, performance, packaging, shipping, release, audit, archive, tag, or cleanup state.

### Phase 53 Canonical Still-Image Request Architecture

- The public boundary remains the two existing `BeautyEngine` CIImage entries. `BeautyEffects` owns one feature-neutral exact-empty admission value; production has no candidate name, public parameter, preset key, provider, or renderer case. An opaque Testing SPI may inject only a demand count and aggregate counters so the existing facade route is executable before any feature is admitted.
- An admitted still request follows one dependency path: `BeautySDK` validates resources and canonicalizes once, `BeautyDetection` performs the existing single Vision request and request-local mapping against normalized `.up` metadata, and `BeautySDK` creates one stack-local `BeautyStillImageRequestContext` that owns the canonical carrier plus selected mapped observation until rendering returns. No request context, canonical raster, or support is retained on the engine.
- The inactive production route remains the pre-Phase-53 legacy path. The pixel-buffer overload and `reset()` neither construct nor invoke the canonicalizer, request context, mapped local support, or a local provider. Realtime/Demo, Phase 55 original-pixel composition, candidate transforms, masks, and overlap ownership remain structurally outside this phase.
- Dependency direction remains `BeautySDK` facade → `BeautyEffects` admission/planning and `BeautyDetection` support → `BeautyCore` carrier. No target, dependency, resource/model, network path, public facade, or Demo import is added.
