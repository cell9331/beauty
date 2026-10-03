# 项目进度与文档漂移审计（2026-10-01）

> 2026-10-03 后续状态：[有限可行性验证](TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)已拒绝唯一自动候选；通用无蒙版同肤色物体辨认仍未完成，现暂停续作。新增低对比唇缘保护限制留在技术债，未修复。下文保留 2026-10-01 盘点当时的状态；现行下一步以 PLANS 为准。


2026-10-03 主机显式保护集成后库存：Swift 源文件 85 个 / 23,489 行；Swift 测试文件 140 个 / 53,897 行。仅新增主机并集蒙版回归，生产源码库存不变。下方数量保留 2026-10-01 盘点快照。

## 结论与范围

当前 SDK 的主要实现、参数库存和现行 taxonomy 基本对齐。原 15 项二维控制已按各自限定输入域完成验收；去脂暂停，显式兼容保留；无排除蒙版时同肤色非皮肤物体的自动辨认仍未完成。

**审计发现的 6 组文档漂移已修复。** 原发现为 D01–D03、D05–D07，集中在旧任务指向、过期效果状态、已变更的处理契约和重复库存；下方保留修复前观察，并在修复表记录处置。D04 已排除为当前漂移，仅保留历史正文整理建议。修复统一了现行入口和声明，没有重新打开已完成阶段、修改历史回执或恢复去脂研发。

审计对象是 `main`、HEAD `a305d1a1` 上的未提交工作树，包含此前实现与文档修改。依据为实际 Swift 源码、现有 XCTest 断言、SDK-owned 脚本、现行计划及文档；不以聊天记忆作为完成凭据。漂移清单中的行号是修复前审计位置，修复后请按文件章节定位。

## 当前进度

| 范围 | 核实状态 | 证据与边界 |
| --- | --- | --- |
| 产品与构建面 | SDK-only SwiftPM library + CLI | [Package.swift](../BeautySDK/Package.swift)：2 products，6 regular targets、1 executable target、6 test targets。没有活跃 App/UI。 |
| 公共参数与资源 | 77 个参数字段，11 个 configuration 字段，5 个预设、2 个 filter | 参数、CodingKeys、taxonomy 名称集相同；[参数实现](../BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift)、[配置实现](../BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift)、[资源清单](../BeautySDK/Sources/BeautyResources/Resources/manifest.json)。字段数不是独立效果数。 |
| 现行分类 | 63 行：62 implemented + 1 suspended | [taxonomy](SDK_EFFECT_TAXONOMY.md)。各行受自己的二维/像素/输入范围约束，含别名映射，不能换算成通用视觉质量完成率。 |
| 原 15 项二维控制 | 限定生成输入域验收完成 | [当前计划最终表](../plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)、[像素测试](../BeautySDK/Tests/BeautyCoreTests/RemainingEffectSemanticCandidateTests.swift)和[对称/轮廓测试](../BeautySDK/Tests/BeautyCoreTests/GeneratedContourPublicOracleTests.swift)。不声明通用头发分割、三维形态或内部脂肪识别。 |
| 面部流畅 | 后续源边界实现已有方向/负例/保护测试 | [GeneratedContourPublicOracleTests.swift](../BeautySDK/Tests/BeautyCoreTests/GeneratedContourPublicOracleTests.swift) 的粗糙度改善与平滑负例检查。Phase 90 当时的 partial 不代表当前实现未完成。 |
| 去脂 | suspended，默认隐藏，旧名显式兼容 | [renderer 注册](../BeautySDK/Sources/BeautyExampleRenderer/main.swift)、[实际 CLI 进程测试](../BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift)。自然外观效果未合格；本轮不重启实验。 |
| CLI | 99 个注册案例、98 个默认案例 | 源码与当前编译 CLI 的 `--list-cases` 相符；去脂是唯一默认隐藏项；没有 `--all` 参数。此次只读 CLI 清单/帮助，没有重新渲染或重建二进制。 |
| 同肤色物体保护 | 显式蒙版路径完成；通用自动辨认未完成 | [BeautySkinTextureDecorationTests.swift:72](../BeautySDK/Tests/BeautyCoreTests/BeautySkinTextureDecorationTests.swift) 验证无蒙版会改动同色物体、有蒙版精确保留且对侧脸颊仍处理；[当前计划](../plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)准确保留自动语义缺口。 |
| 当前源码规模 | 85 个 Swift 源文件、139 个 Swift 测试文件 | 排除 `.build`，分别 23,489 / 53,549 行；包含当前工作树尚未提交的 Swift 文件。这是盘点数据，不是质量指标。 |

## 修复前文档漂移清单

### D01 — 当前规划入口仍把已完成控制与暂停功能列作后续工作

- 文档：[PROJECT.md:15–20](../.planning/PROJECT.md)、[REQUIREMENTS.md:14–15](../.planning/REQUIREMENTS.md)仍称 15 行 `partial`；PROJECT 的 Next Milestone Goals（837–846）仍称去脂为 current provisional，将发际线、双下巴、比例/3D 控制列作未来，并把 distribution 放进后续顺序。
- 对照：当前 taxonomy 的 62/1 状态、现有 77 字段及上述像素测试；[AGENTS.md](../AGENTS.md)和[PLANS.md](../PLANS.md)明确去脂暂停、所有者自用及不分发边界。
- 影响：后续规划会重复已完成工作，误解暂停状态，或扩大当前范围。
- 修正方向：重写 `.planning` 当前摘要与后续目标，只保留现行缺口和指向根级计划的链接；旧阶段目标归历史，不改签旧证据。

### D02 — 当前会话交接仍指向旧回执

- 文档：[STATE.md:436–445](../.planning/STATE.md)的 Current completion handoff 仍停在 v1.22，推荐旧 Phase 95 验证；[PROJECT.md:289](../.planning/PROJECT.md)仍写 v1.22 active、Phase 92 next。
- 对照：[V1.22-CURRENT.md:5–15](../.planning/V1.22-CURRENT.md)已说明旧验证命令对后续代码返回 `review_missing_or_stale`；STATE:49–52 自己又记录 Phase 99 完成。现行开放事项在根级 PLANS，而不在这些旧恢复位置。
- 影响：恢复任务时可能得到旧回执的预期 stale，误当成新失败并重复诊断。
- 修正方向：保留旧回执原义，统一当前恢复入口、最后活动和下一步指向。

### D03 — 产品正文仍称已验收控制为 partial

- 文档：[PRODUCT_SENSE.md:157、175、184、197、206、282](../PRODUCT_SENSE.md)仍用“remain partial / pending broader portrait evidence”。部分旧段已混入后来的 source-boundary 路由，不能视作完整冻结快照。
- 对照：文件顶部后续合格范围、taxonomy 对应行及 [RemainingEffectSemanticCandidateTests.swift](../BeautySDK/Tests/BeautyCoreTests/RemainingEffectSemanticCandidateTests.swift) 的头部、发际线、双下巴、人中、刚性平移等像素检查。
- 影响：把限定范围内已完成的工作重新列为待办，或要求补证从未声明的头骨/脂肪等能力。
- 修正方向：现行正文只描述最终范围；中间阶段的 partial 和失败保留在明确的历史记录中。

### D04 — 已排除：纹理旧行为已有明确替代说明

- 旧文：[DESIGN.md:409–411](../DESIGN.md)称纹理无需人脸检测、脸外低对比纹理也会改变；但同文件 771–784 已描述现行静图与 pixel-buffer 的人脸支持要求，并明确将旧无脸描述限定为修复前行为。
- 对照：[BeautySkinTexturePipeline.swift:34、96](../BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift)要求合法 faceBounds；[GeneratedSkinTexturePublicOracleTests.swift:186](../BeautySDK/Tests/BeautyCoreTests/GeneratedSkinTexturePublicOracleTests.swift)断言背景保护和 no-face 源图不变。现行说明与实现一致。
- 结论：不计入 6 组确认漂移，不是未解决的实现或契约缺陷。可将相距较远的旧段归入历史区，改善检索和阅读；这只是整理建议。

### D05 — 整脸上下移动仍记成单点方案

- 文档：[RELIABILITY.md:211–215](../RELIABILITY.md)称最多生成一个点。
- 对照：[FaceShapeWarpProvider.swift:283](../BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift)的 provider 返回中心、两特征点、两边缘点；[BeautyGeometryEffectPipeline.swift:222](../BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift)在静图路径抑制这些点，改用已准入整头刚性平移。
- 影响：错误描述当前处理路径与点数预算。
- 修正方向：分别说明 provider 与静图源边界路径；原单点说明仅保留为历史。

### D06 — 重复库存表过期

- 文档：[ARCHITECTURE.md:293–300](../ARCHITECTURE.md)的 Current inventory 仍写 79 源文件、118 测试文件及旧行数；[codebase/STRUCTURE.md:40、59](../.planning/codebase/STRUCTURE.md)和[codebase/TESTING.md:47、73](../.planning/codebase/TESTING.md)仍写 72/74 文件、75 CLI cases。
- 对照：当前工作树为 85/139 文件、99 注册/98 默认；参数与 CLI 的当前核心库存本身已经对齐。
- 影响：现行架构摘要和被索引引用的旧代码地图传递不同项目规模与清单。
- 修正方向：将动态库存收敛到一个可复算入口；代码地图明确分析日期与失效范围，不再把旧数量作为当前契约。

### D07 — mandatory gate 混淆测试身份数与环境变量数

- 文档：[RELIABILITY.md:675–686](../RELIABILITY.md)写 all eight opt-in environment variables。
- 对照：[run-no-skip-swiftpm.sh:13](../scripts/run-no-skip-swiftpm.sh)锁定 9 个 opt-in 测试身份，子进程处设置 5 个环境变量（3 个开关、2 个 bundle）；[check-no-skip-wrapper.py](../scripts/check-no-skip-wrapper.py)分别校验两者。
- 影响：接入/维护门禁时可能按错误对象或数量排查。
- 修正方向：写明 9 个测试必须各执行一次；环境输入与测试分母分别说明，引用脚本作为身份清单。

## 已知限制与历史排除

- [旧批量脚本](../scripts/run-face-feature-batches.sh)在第 673 行仍强制 `--list-cases` 为 75 项，与当前库存不兼容。这已在[当前技术债](../plans/debt/current.md)登记，不是本轮新发现，也不是当前完整门禁入口；本轮不改冻结清单或历史证据。
- Phase 97–99 已在 [v1.24 记录](../.planning/V1.24-UPPER-EYELID-CURRENT.md)与 STATE 中记为 inline 完成，不应重复启动。
- QUALITY_SCORE 的统一历史区、taxonomy 的历史 Phase 90/v1.23 说明、已降为 historical 的 blueprint，以及 archived milestone evidence 中的旧状态，不单独算当前漂移。日期明确的旧测试结果不需要改成今天的分母。
- 当前未完成的能力是根级计划列明的同肤色物体自动辨认；去脂是暂停缺口。发际线泛化、人口/设备性能等仍受各自声明范围约束，不能由这些限定测试推成一般质量承诺。

## 本轮验证及局限

- 实际重跑：两个 legacy UI 归档验证、post-archive SDK-only boundary，均通过。
- 静态复算：Package/API/配置/资源/CLI 库存；关键控制的实际 source 路由与现有像素断言；脚本的测试身份与环境输入。
- 当前编译 CLI 的只读 `--list-cases` 实测 98 项且无去脂，帮助无 `--all`。本轮未重新证明该二进制的构建身份；源码清单与实际输出相符。
- 最近完整代码检查点为 **1072 tests / 0 failures / 0 skips，9 opt-in**。已核对该执行结果，并与前次基线比较 2,188 个代码/既有历史文件，哈希未变。本轮没有把旧日志冒充新跑的 SwiftPM，也没有重新做 62 行效果的独立视觉验收。
- 上述为首次审计的验证，未在当时执行文档修复。后续处置及验证如下；代码/测试与既有历史回执均未修改。

## 修复结果（2026-10-01）

| 发现 | 处置 | 当前定位 |
| --- | --- | --- |
| D01 | 当前摘要明确 15 项限定二维验收完成、去脂暂停和唯一活跃能力缺口；删除失效的后续交付顺序，旧阶段目标明确为历史。 | [PROJECT](../.planning/PROJECT.md)、[REQUIREMENTS](../.planning/REQUIREMENTS.md)、[ROADMAP](../.planning/ROADMAP.md)的当前摘要/执行路由。 |
| D02 | 当前交接统一恢复到根级 PLANS；旧 Phase95 回执交接标成历史；v1.24 frontmatter 的完成比例明确仅指历史里程碑。 | [STATE](../.planning/STATE.md)的 Current position 和 Current handoff。 |
| D03 | 将重复、中途 partial 描述收敛为 15 项最终适用域；原叙述另存新历史摘录。 | [PRODUCT_SENSE](../PRODUCT_SENSE.md)的 Current qualified 2D shape controls；[原叙述](history/product-effect-qualification-snapshot-2026-10-01.md)。 |
| D05 | 区分 provider 的零或五点与静图抑制平移点后进行源准入刚性平移的路径。 | [RELIABILITY](../RELIABILITY.md)的 Current whole-face vertical bounds and recovery。 |
| D06 | 删除根级重复动态库存，引用本报告日期快照并提供复算命令；七份旧代码地图明确整体为 dated analysis，文档索引不再把它们当作当前契约。 | [ARCHITECTURE](../ARCHITECTURE.md)、[代码地图](../.planning/codebase/STRUCTURE.md)、[文档索引](README.md)。 |
| D07 | 明确九个预期 opt-in 测试身份与五个显式环境输入（三个开关、两个 bundle）分别校验。 | [RELIABILITY](../RELIABILITY.md)的 Mandatory No-Skip Gate。 |

归档验证、post-archive SDK-only boundary、`git diff --check` 和 mandatory wrapper
自测通过（13 checks / 13 mutation rejections）。代码、脚本和既有历史证据的
2,144 个保护文件逐文件哈希未变。修复只改文档；没有重跑完整 SwiftPM 或图片效果
验收，也没有把此前 `1072/0/0` 重新签为本轮测试。19 份文档的 171 个本地链接
（含 2 个锚点）及 1 个入站锚点引用通过；15 项控制、taxonomy、77 字段、99/98
清单、脚本身份/环境输入的对应关系静态核对通过，结果记录于
[PLANS 的文档漂移修复项](../PLANS.md#c-2026-10-01-current-document-drift-repair)。
