# ARCHITECTURE.md

> `beauty` 的系统蓝图。本文定义域、包、依赖方向和跨界限制。
> 业务细节写入 `PRODUCT_SENSE.md`，数据结构与状态机写入 `DESIGN.md`。

## 1. 架构目标

`beauty` 的目标是形成可嵌入 iOS App 的美颜 SDK：App 负责 UI 与业务编排，SDK 负责图像输入、参数模型、检测、渲染、效果、资源加载和对外 API。

当前仓库状态：

- 已存在 `BeautyDemo/` Xcode Demo App。
- 已存在 `BeautySDK/` Swift Package，包含 `BeautyCore`、`BeautyDetection`、`BeautyRender`、`BeautyEffects`、`BeautyResources` 和 public `BeautySDK` facade。
- Phase 6 当前实现已让 `BeautyEffects` 承担效果解析、安全 cap、几何 provider、MVP 颜色/几何输出与降级 metadata；Demo 仍只通过 public `BeautySDK` facade 集成。
- Phase 26 当前实现已让 public `BeautySDK` still-image facade 在几何参数需要时触发检测，并通过 package-only 检测观察值把一个 selected face 路由到 `BeautyEffects` 内部 `FaceGeometry` planning；public API 仍只暴露 redacted `BeautyDetectionSummary`、warnings 和 aggregate metrics。
- Phase 27 当前实现已让 public still-image facade 通过内部 selected-face route 产生 same-dimension geometry saved-output evidence；2026-07-08 验证修正后，该 still-image 路径使用控制点驱动的局部 CIImage warp，而不是全局色偏代理；`BeautyExampleRenderer` 仍只 import `BeautySDK`，递归读取 committed `example-images/input/portraits/` 与 `input/negatives/` fixtures，generated PNGs 保持在 ignored flat `example-images/output/`，人工浏览视图保持在 ignored `example-images/gallery/`。
- Phase 28 当前实现已为 scoped `脸型` existing-parameter slice 提供 SDK-only saved-output evidence 和空间形变回归测试；`BeautyExampleRenderer` 仍只通过 public `BeautySDK` facade 生成 ignored local outputs，未新增 Demo UI、public raw geometry surface 或新的 geometry group。
- `docs/` 下存在历史规划资料，迁移后的根级文档优先级更高。

## 2. 顶层不变量

| ID | 不变量 | 说明 |
| --- | --- | --- |
| A1 | SDK 不包含 UI 页面 | SDK 内禁止 SwiftUI View、UIKit 页面、按钮、滑杆、相册页。 |
| A2 | App 不访问 SDK 内部实现 | Demo App 只能依赖 `BeautySDK` 对外门面。 |
| A3 | 实时渲染链路不经过 `UIImage` | 相机/视频帧必须走 `CMSampleBuffer`、`CVPixelBuffer`、`CVMetalTexture`、Metal。 |
| A4 | 检测与渲染解耦 | Vision/Core ML 只产出内部检测模型，不直接编码 Metal pass。 |
| A5 | 几何形变统一合并 | 眼、鼻、嘴、脸型生成控制点后进入统一 `FaceWarpPass`。 |
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
| Core Types | `BeautyCore` | 参数、错误、坐标、帧模型、Phase 1 no-op `BeautyEngine`、协议、Sendable 值类型 | Vision/Metal 具体实现 |
| Diagnostics | `BeautyCore/Diagnostics` | `BeautyLogger`、`BeautyLogEvent`、sink、错误上下文、可关闭本地诊断 | 独立后端服务、上传、业务埋点 |
| Detection | `BeautyDetection` | 人脸检测、关键点解析、方向处理、点位平滑、检测降频 | 渲染 pass、UI 绘制 |
| Render | `BeautyRender` | Metal 上下文、纹理缓存、RenderGraph、shader pass、LUT/CI 桥接 | 检测算法、SwiftUI 状态 |
| Effects | `BeautyEffects` | 美颜、滤镜、五官形变、妆容、分割效果的组合逻辑 | 独立 Package、UI 面板 |
| Resources | `BeautyResources` | LUT、shader、妆容包、模型、资源版本与校验 | 业务下载策略、页面展示 |
| Demo App | `BeautyDemo` | 相机页、预览、滑杆、预设面板、调试可视化 | SDK 内部实现 |

## 6. Target 责任

### 6.1 BeautyCore

稳定内核。只放跨模块共享的轻量类型：

- `BeautyParameters`
- `BeautyConfiguration`
- `BeautyError`
- `BeautyEngine` Phase 1 no-op foundation
- `BeautyFrame`
- `FaceObservation`
- `FaceLandmarks`
- `WarpControlPoint`
- 坐标系、方向、质量等级、日志事件、错误上下文的值类型

规则：

- 优先 `struct`、`enum`、`protocol`。
- 可跨并发域传递的类型必须显式满足 `Sendable`。
- 不持有 `MTLDevice`、`VNRequest`、SwiftUI 状态。
- Diagnostics 默认只提供本地实现；上传、远端诊断和业务埋点必须经过 `SECURITY.md` 的网络与隐私设计。

### 6.2 BeautyDetection

检测域。负责把平台检测结果转换为 SDK 内部模型：

- `FaceDetecting`
- `VisionFaceDetector`
- `CoordinateMapper`
- `LandmarkSmoother`
- 检测降频与多人脸排序策略

规则：

- 输出只能是 `BeautyCore` 中的模型。
- 不直接触发 render pass。
- 不把 Vision 坐标泄漏到 `BeautySDK` 对外 API。
- `VisionFaceDetector`、`CoordinateMapper`、`BeautyFaceObservation`、landmark groups 和 Vision bounding boxes 都停留在 `BeautyDetection` 内部。
- 对外只通过 `BeautySDK` facade 暴露 `BeautyInputMetadata` 与 geometry-free 的 `BeautyDetectionSummary`。
- Phase 26 允许 `BeautySDK` 通过 package-only seam 调用 `VisionFaceDetector` 并选择一个 usable face；该 seam 不允许 Demo 或 public API 访问 raw observation、bounding box、landmark、Vision object 或 provider internals。
- 坐标映射的规范出口是 image-normalized SDK 模型；preview / mirrored preview 只属于 App 展示层。

### 6.3 BeautyRender

渲染域。负责 GPU 上下文与 pass 调度：

- `MetalContext`
- `TextureCache`
- `RenderGraph`
- `RenderPass`
- `CopyRenderPass`
- `FaceWarpPass`
- `Shaders/Warp.metal`
- LUT / Core Image 桥接

规则：

- 实时链路禁止 `UIImage` 中转。
- Metal 资源由渲染层统一创建、复用和释放。
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
- 多个几何效果只产出控制点，统一交给 `FaceWarpPass`。
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
→ BeautyDetection produces FaceObservation
→ BeautyEffects resolves active effects
→ BeautyRender executes RenderGraph
→ processed texture / pixel buffer
→ BeautyDemo preview
```

离线图片路径：

```text
Image input
→ BeautyEngine.processResult(image:metadata:parameters:)
→ normalize to SDK frame model
→ optional detection
→ effects and render graph
→ output image / pixel buffer
```

参数路径：

```text
BeautyDemo sliders / presets
→ BeautyParameters
→ BeautyEngine.process(..., parameters:)
→ Effects read immutable snapshot
→ RenderGraph receives normalized uniforms
```

## 8. 跨界限制

| 边界 | 允许 | 禁止 |
| --- | --- | --- |
| App → SDK | 调用 `BeautyEngine`、传入参数、接收结果 | 直接访问内部 Target、操作 `MTLCommandBuffer` |
| SDK → App | 回调稳定结果、错误、指标 | 持有 ViewModel、调用 SwiftUI/UIKit 页面 |
| Detection → Render | 通过 `FaceObservation` 间接协作 | 检测层创建 render pass |
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
