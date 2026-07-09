# 文档审计报告

审计日期：2026-05-25

处理状态：已按本报告完成一轮文档修订。

后续复核：2026-06-10

复核状态：已修复当前可验证的文档漂移。

2026-06-10 处理项：

```text
R1 PLANS.md 已同步：.planning/PROJECT.md 已存在，当前 GSD gate 是 workflow preferences，STATE / ROADMAP 仍未生成。
R2 docs/README.md 已从单纯链接列表扩展为长文档入口，补充权威层级、当前仓库状态和历史规划边界。
R3 QUALITY_SCORE.md 已刷新到 2026-06-10 snapshot，并新增 .planning 状态、README 链接、显式 simulator build 巡检。
R4 AGENTS.md 的基础构建命令已改为显式 iOS Simulator destination，避免默认选择不兼容的 My Mac。
R5 docs/superpowers/ 下 2026-05-25 规划已补环境复核注记：当前本机为 full Xcode，xcodebuild -list 和指定 iOS Simulator build 均可验证。
```

已处理项：

```text
P0-1 README 链接与阅读顺序已更新。
P0-2 同步 API / 实时链路约束已补充，waitUntilCompleted 仅保留为最小闭环示例。
P1-3 BeautyError 已统一补齐 commandQueueCreationFailed、presetDecodeFailed、lutDecodeFailed。
P1-4 BeautyConfiguration 已统一纳入 logLevel，方向和镜像改为逐帧输入状态。
P1-5 基础颜色参数已纳入 1.0 BeautyParameters。
P1-6 shader 文件名已统一为 Warp.metal。
P1-7 已补充 BeautyCore/Diagnostics、BeautyLogger、本地日志和错误上下文设计。
P2-8 参数数量已修正为 31 个字段。
P2-9 fatalError("TODO") 已替换为可恢复错误示例。
P2-10 BGRA videoSettings 示例已补充。
P2-11 BeautyEngine.init 已统一为 throws。
P2-12 docs_total.json 已移动到 docs/_source/。
```

以下内容保留为原始审计记录，便于追踪这轮修订的来源。

审计范围：

```text
docs/01_product_feature_plan.md
docs/02_development_stages_full_plan.md
docs/03_architecture_spm_skeleton.md
docs/04_development_spec.md
docs/05_public_api_design.md
docs/06_beauty_parameters_spec.md
docs/07_face_landmarks_coordinate_system.md
docs/08_metal_render_pipeline_design.md
docs/09_algorithm_effects_implementation.md
docs/README.md
```

## 原始审计结论

本轮修订前，文档已经覆盖产品、阶段计划、架构、开发规范、API、参数、坐标、Metal 管线和算法效果，但存在一些会影响落地的冲突：

1. README 链接已经失效，文档入口不可用。
2. 实时同步 API 与渲染管线的 `waitUntilCompleted()` 风险描述互相冲突，容易导致实时相机掉帧。
3. `BeautyError`、`BeautyConfiguration`、颜色参数、shader 文件名等核心契约在多份文档中不一致。
4. 日志、错误码、诊断体系只有零散描述，没有形成可实现的统一设计。
5. 部分文档仍保留 `fatalError("TODO")` 作为骨架示例，需要明确是占位还是禁止进入实现分支。

## 原始 P0：必须先修

### 1. README 链接全部指向旧文件名

证据：

- `docs/README.md:3` 指向 `01_beauty_sdk_algorithm_effects_implementation.md`
- `docs/README.md:4` 指向 `02_beauty_sdk_face_landmarks_coordinate_system.md`
- `docs/README.md:5` 指向 `03_beauty_sdk_metal_render_pipeline_design.md`
- `docs/README.md:6` 指向 `04_beauty_sdk_public_api_design.md`
- `docs/README.md:7` 指向 `05_beauty_parameters_spec.md`
- `docs/README.md:8` 指向 `06_ios_beauty_sdk_development_spec.md`
- `docs/README.md:9` 指向 `07_ios_beauty_sdk_development_stages_full_plan.md`
- `docs/README.md:10` 指向 `08_ios_beauty_sdk_architecture_spm_skeleton.md`
- `docs/README.md:11` 指向 `09_beauty_sdk_product_feature_plan.md`

实际文件已经改成：

```text
01_product_feature_plan.md
02_development_stages_full_plan.md
03_architecture_spm_skeleton.md
04_development_spec.md
05_public_api_design.md
06_beauty_parameters_spec.md
07_face_landmarks_coordinate_system.md
08_metal_render_pipeline_design.md
09_algorithm_effects_implementation.md
```

影响：

- 文档入口失效。
- 新成员或 Agent 通过 README 读文档时会直接打开不存在的文件。

建议：

- 立即更新 README 链接。
- README 顺序应保持当前开发落地顺序：产品 → 阶段计划 → 架构 → 工程规范 → API → 参数 → 坐标 → 渲染 → 算法。

### 2. 实时同步 API 与性能约束冲突

证据：

- `docs/04_development_spec.md:619` 要求 `process` 不允许阻塞主线程。
- `docs/05_public_api_design.md:1055` 到 `docs/05_public_api_design.md:1057` 要求初始化和处理不要在主线程高频执行。
- `docs/08_metal_render_pipeline_design.md:1423` 到 `docs/08_metal_render_pipeline_design.md:1456` 建议第一版 API 可以同步。
- `docs/08_metal_render_pipeline_design.md:1914` 到 `docs/08_metal_render_pipeline_design.md:1915` 在示例中 `commit()` 后直接 `waitUntilCompleted()`。
- `docs/08_metal_render_pipeline_design.md:1935` 到 `docs/08_metal_render_pipeline_design.md:1936` 明确说明 `waitUntilCompleted` 会阻塞调用线程并可能掉帧。
- `docs/08_metal_render_pipeline_design.md:2006` 又要求实时链路不要频繁 `waitUntilCompleted()`。

问题：

同步 API 本身不是错误，但文档没有明确区分“离线同步处理”和“实时相机处理”的调用模型。现在读起来像第一版实时链路也可以每帧同步等待 GPU 完成，这和性能目标冲突。

影响：

- 实现者可能在 capture queue 中每帧 `waitUntilCompleted()`，造成掉帧和延迟堆积。
- App 接入方无法判断 `process(pixelBuffer:)` 是否适合实时高频调用。

建议：

- 明确 `process(pixelBuffer:) throws -> CVPixelBuffer` 只保证 API 同步返回，不代表必须在主线程或实时链路阻塞等待。
- 第一版如果保留同步 API，应补充 in-flight 限制、丢帧策略、最大等待预算和推荐队列。
- 最好在 API 文档中增加实时版接口或处理器，例如 `CameraRealtimeProcessor` / `processAsync`，把实时调用和离线处理分开。

## 原始 P1：应尽快统一

### 3. `BeautyError` 定义不一致

证据：

- `docs/04_development_spec.md:857` 到 `docs/04_development_spec.md:867` 定义的 `BeautyError` 不包含 `commandQueueCreationFailed`、`presetDecodeFailed`、`lutDecodeFailed`。
- `docs/05_public_api_design.md:884` 到 `docs/05_public_api_design.md:897` 包含 `commandQueueCreationFailed`、`presetDecodeFailed`、`lutDecodeFailed`。
- `docs/08_metal_render_pipeline_design.md:198` 到 `docs/08_metal_render_pipeline_design.md:199` 直接使用 `BeautyError.commandQueueCreationFailed`。
- `docs/04_development_spec.md:1032` 创建 command queue 失败时使用的是 `renderFailed("Failed to create command queue")`。

问题：

同一个错误场景在不同文档中有两个表达方式：一个是专用错误码，一个是通用 `renderFailed`。

影响：

- 实现时无法确定 `BeautyError` 的真实枚举。
- App 侧错误处理和日志聚合无法稳定匹配错误类型。

建议：

- 建立单一错误契约，建议放在开发规范或单独的 Diagnostics 文档。
- 保留结构化错误码，例如 `BeautyErrorCode.commandQueueCreationFailed`，并通过上下文附加底层信息。
- 所有示例统一使用同一套错误定义。

### 4. `BeautyConfiguration` 被拆成多份不兼容定义

证据：

- `docs/05_public_api_design.md:271` 到 `docs/05_public_api_design.md:281` 定义了包含 `preferredProcessingSize`、`maximumFaceCount`、`enablePerformanceLog`、`enableDebugMode` 等字段的完整配置。
- `docs/05_public_api_design.md:953` 到 `docs/05_public_api_design.md:955` 又单独定义了只包含 `logLevel` 的 `BeautyConfiguration`。
- `docs/07_face_landmarks_coordinate_system.md:541` 到 `docs/07_face_landmarks_coordinate_system.md:544` 建议在 `BeautyConfiguration` 增加 `isInputMirrored`、`isPreviewMirrored`。
- `docs/04_development_spec.md:827` 只有空结构示例 `public struct BeautyConfiguration: Sendable {}`。
- `docs/03_architecture_spm_skeleton.md:650` 附近也有另一份配置定义。

问题：

配置字段分散在 API、坐标、开发规范和架构文档中，没有一个最终版本。

影响：

- 后续写 `BeautyConfiguration.swift` 时容易遗漏日志、镜像、处理尺寸或调试字段。
- orientation / mirror 到底是配置项还是逐帧输入，目前边界不清。

建议：

- 只保留一份正式 `BeautyConfiguration` 定义。
- 逐帧变化的方向、镜像、时间戳建议放入 `BeautyFrame` / `BeautyFrameOrientation`，不要全部塞入全局 configuration。
- 日志配置应归入统一 Diagnostics 设计。

### 5. 颜色参数范围和阶段目标不一致

证据：

- `docs/02_development_stages_full_plan.md:337` 到 `docs/02_development_stages_full_plan.md:346` 要求阶段 2 实现 `brightness`、`contrast`、`saturation`、`temperature`、`tint`、`exposure`、`highlight`、`shadow`、`sharpness`。
- `docs/04_development_spec.md:2237` 到 `docs/04_development_spec.md:2245` 第二阶段只列出 `brightness`、`contrast`、`saturation`、`temperature`、`sharpness`、`filterId`、`filterIntensity`。
- `docs/06_beauty_parameters_spec.md:1123` 到 `docs/06_beauty_parameters_spec.md:1134` 把 `brightness`、`contrast`、`saturation`、`temperature`、`tint`、`exposure`、`highlight`、`shadow` 放到“后续可扩展”。
- `docs/06_beauty_parameters_spec.md:1388` 到 `docs/06_beauty_parameters_spec.md:1418` 的 1.0 最终参数列表不包含这些颜色参数，只包含 `skinSharpen`、`filterId`、`filterIntensity` 等。

问题：

阶段计划要求早期实现完整基础颜色调整，但参数表没有把这些参数纳入 1.0 正式模型。

影响：

- 阶段 2 无法验收：实现了颜色效果却没有正式参数入口。
- App UI 和 preset JSON 不知道是否可以暴露这些字段。

建议：

- 二选一：
  1. 将基础颜色参数纳入 1.0 `BeautyParameters`。
  2. 将阶段 2 scope 收窄为 `skinSharpen + LUT`，其他颜色参数标记为 1.1 / 1.5。
- 参数表应作为最终参数契约，阶段计划和开发规范向它对齐。

### 6. Shader 文件名不一致

证据：

- `docs/03_architecture_spm_skeleton.md:162` 使用 `BeautyWarp.metal`。
- `docs/03_architecture_spm_skeleton.md:1320` 任务也写 `BeautyWarp.metal`。
- `docs/02_development_stages_full_plan.md:640` 使用 `BeautyWarp.metal`。
- `docs/04_development_spec.md:237` 使用 `Warp.metal`。
- `docs/08_metal_render_pipeline_design.md:142` 使用 `Warp.metal`。
- `docs/09_algorithm_effects_implementation.md:81` 使用 `Warp.metal`。

问题：

同一个核心 warp shader 有两个命名体系。

影响：

- Package skeleton、任务计划和实现文档对不上。
- 生成文件或手工创建文件时容易出现重复 shader。

建议：

- 统一为一个命名。若项目中所有 shader 都带 `Beauty` 前缀，就统一 `BeautyWarp.metal`；若偏简洁，则统一 `Warp.metal`。
- 推荐同步修改目录结构、阶段产物、算法说明和 Metal 管线文档。

### 7. 日志、错误码、诊断体系还没有形成统一设计

证据：

- `docs/04_development_spec.md:101` 到 `docs/04_development_spec.md:103` 把错误码、日志、性能统计列为 SDK 范围。
- `docs/04_development_spec.md:442` 把 `Logger` 放进 `BeautyCore`。
- `docs/04_development_spec.md:870` 到 `docs/04_development_spec.md:891` 只定义了 `BeautyLogLevel` 和隐私限制。
- `docs/05_public_api_design.md:936` 到 `docs/05_public_api_design.md:971` 定义了日志 API 和规则。
- `docs/02_development_stages_full_plan.md:1684` 到 `docs/02_development_stages_full_plan.md:1686` 要求错误码、日志系统、性能监控。
- `docs/02_development_stages_full_plan.md:1749` 到 `docs/02_development_stages_full_plan.md:1750` 把 `SDK Logger` 和 `ErrorCode 文档` 作为阶段产物。

问题：

日志和错误只停留在枚举和原则，没有定义统一模块、sink、文件落盘、保留周期、导出、脱敏、错误上下文等。

影响：

- SPM 和 App 侧日志难以统一管理。
- 本地日志、错误追踪和性能指标会在实现时各写一套。

建议：

- 增加 `BeautyDiagnostics` target 或 `BeautyCore/Diagnostics` 章节。
- 定义 `BeautyLogger`、`BeautyLogEvent`、`BeautyLogSink`、`OSLogSink`、`FileLogSink`、`BeautyErrorCode`、`BeautyErrorContext`。
- 明确 App 与 SDK 共享同一套 diagnostics 配置。
- 明确本地日志按日期滚动、大小上限、保留天数、脱敏规则和导出格式。

## 原始 P2：建议清理

### 8. 参数数量描述错误

证据：

- `docs/06_beauty_parameters_spec.md:1388` 写“最终建议 1.0 包含 22 个参数”。
- `docs/06_beauty_parameters_spec.md:1390` 到 `docs/06_beauty_parameters_spec.md:1418` 实际列出了 23 项，包括 `filterId` 和 `filterIntensity`。
- `docs/02_development_stages_full_plan.md:716` 到 `docs/02_development_stages_full_plan.md:739` 的阶段 5 参数列表同样是 23 项。

问题：

数字和列表不一致。

影响：

- 自动生成参数表、UI 分组或验收 checklist 时会产生混淆。

建议：

- 改为“23 个字段”，或明确 `filterId` 不是强度参数，所以“22 个数值参数 + 1 个 filterId”。

### 9. 架构文档中存在 `fatalError("TODO")` 占位

证据：

- `docs/03_architecture_spm_skeleton.md:1235` 到 `docs/03_architecture_spm_skeleton.md:1239` 的 `BeautyRenderer.render` 骨架以 `fatalError("TODO")` 结束。
- `docs/04_development_spec.md:846` 到 `docs/04_development_spec.md:852` 说明开发期临时占位提交前必须移除。

问题：

作为架构骨架示例可以存在，但没有标注“示例占位，不得进入实现分支”。

影响：

- 如果直接按骨架复制实现，运行时会崩溃。

建议：

- 将示例改为 `throw BeautyError.renderFailed("Not implemented")`，或加醒目标注。
- 开发规范中补一条：文档示例里的 `fatalError("TODO")` 只能作为伪代码，不允许进入源码。

### 10. BGRA 第一版要求与 App 接入示例不完整

证据：

- `docs/05_public_api_design.md:1084` 到 `docs/05_public_api_design.md:1102` 要求实时相机优先支持 `kCVPixelFormatType_32BGRA` / `BGRA`。
- `docs/08_metal_render_pipeline_design.md:257`、`docs/08_metal_render_pipeline_design.md:341`、`docs/08_metal_render_pipeline_design.md:1342` 到 `docs/08_metal_render_pipeline_design.md:1344` 多处固定 BGRA 输入输出。
- `docs/08_metal_render_pipeline_design.md:1500` 到 `docs/08_metal_render_pipeline_design.md:1504` 的 App 侧 `AVCaptureVideoDataOutput` 示例只设置了 `alwaysDiscardsLateVideoFrames`，没有设置 `videoSettings`。
- `docs/05_public_api_design.md:777` 到 `docs/05_public_api_design.md:813` 和 `docs/05_public_api_design.md:1125` 到 `docs/05_public_api_design.md:1174` 的相机接入示例也没有展示 BGRA `videoSettings`。

问题：

文档要求第一版只稳定 BGRA，但接入示例没有告诉 App 如何拿到 BGRA pixel buffer。

影响：

- App 默认可能拿到 YUV，导致 SDK 报 `unsupportedPixelFormat` 或渲染路径不匹配。

建议：

- 在 App 接入示例中补充：

```swift
videoOutput.videoSettings = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
]
```

### 11. `BeautyEngine.init` 的 `throws` 标记在架构文档前后不一致

证据：

- `docs/03_architecture_spm_skeleton.md:629` 的 API 摘要里 `public init(configuration: BeautyConfiguration = .default)` 没有 `throws`。
- `docs/03_architecture_spm_skeleton.md:1127` 的骨架实现里 `public init(configuration: BeautyConfiguration = .default) throws` 有 `throws`。
- `docs/04_development_spec.md:598` 和 `docs/05_public_api_design.md:116` 都要求 `init` 是 `throws`。

问题：

架构文档同一份内前后不一致。

影响：

- 集成方和实现者对初始化失败处理不明确。

建议：

- 统一为 `public init(configuration: BeautyConfiguration = .default) throws`。

## 其他观察

### 12. `docs_total.json` 仍留在 `docs/` 目录

当前 `docs/` 同时包含生成后的 Markdown 和原始聚合 JSON。

影响：

- 如果工具递归读取 `docs/`，可能把 JSON 和拆分后的 Markdown 当成两套重复资料。

建议：

- 如果 `docs_total.json` 只是导入源，建议移到 `docs/_source/` 或归档目录。
- 如果仍要保留在 `docs/`，建议 README 明确说明它是生成源，不是阅读入口。

## 建议处理顺序

1. 更新 README 链接和文档顺序。
2. 统一 API 同步/异步策略，明确实时链路不应每帧阻塞等待 GPU。
3. 统一 `BeautyError` 和 `BeautyConfiguration`。
4. 统一 1.0 参数范围，尤其是基础颜色参数。
5. 统一 shader 文件名。
6. 增加 Diagnostics / Logging / ErrorCode 章节。
7. 修正参数数量、`fatalError("TODO")`、BGRA 接入示例和 `init throws` 小问题。

## 审计命令记录

本次主要使用以下检查：

```sh
find docs -maxdepth 1 -type f -name '*.md' -print | sort
wc -l docs/*.md
rg -n "TODO|TBD|FIXME|待定|占位|未完成|后续|暂不|暂未" docs/*.md
rg -n "BeautyError|BeautyConfiguration|BeautyEngine|process\\(|waitUntilCompleted|BGRA|videoSettings|ColorAdjustment|brightness|contrast|saturation|temperature|tint|exposure|highlight|shadow|BeautyWarp\\.metal|Warp\\.metal|22 个|23" docs/*.md
rg -n "日志|log|Logger|BeautyLog|diagnostic|Diagnostics|错误码|ErrorCode|本地" docs/*.md
```
