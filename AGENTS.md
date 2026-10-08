# AGENTS.md

Spend time on thinking; you do not need to use the commentary channel to report progress to me.

> `beauty` 仓库的唯一入口。当前仓库是 SDK-only Swift Package；历史 UI/Demo
> 只能从已验证归档中恢复到仓库外的临时目录。
>
> 当前 `BeautySDK` 只供项目所有者在自己控制的本地 App、工具和验证程序中
> 使用，不面向第三方用户，也不计划发布、售卖或分发 SDK、模型或权重。

## 1. 核心原则

- 仓库文本、代码与测试是记录系统；不存在的事实不得默认存在。
- 当前产品面是 `BeautySDK` SwiftPM library 与 SDK-owned command-line validation。
- 原应用/UI 只属于 `archives/legacy-ui/` 历史材料，不是构建、测试或需求输入。
- 具体约束由专项文档承载；每次改动记录改了什么、为什么、如何验证。

## 2. 阅读顺序

1. 先读 `AGENTS.md` 与 `PLANS.md`。
2. 按任务类型读取对应根级 owner；`PLANS.md` 是渐进式入口，现行计划与技术债按其中链接继续读取。
3. 再读相关代码、SwiftPM 测试与 `docs/` 背景资料；`docs/history/` 只保留历史证据，不产生当前任务。
4. 算法/control taxonomy 以 `docs/SDK_EFFECT_TAXONOMY.md` 为当前 authority。
5. 图片效果验收输入与声明以 `docs/IMAGE_EFFECT_ACCEPTANCE.md` 为当前 authority。
6. 若契约变化，同步更新拥有该契约的文档，替换失效的当前声明；不要持续叠加互相覆盖的补丁说明。接口兼容、工程安全与效果资格分别记录。

冲突优先级：代码与测试 > `PLANS.md` 及其链接的现行计划/技术债 > 根级专项文档 > 历史分片与 `docs/` 历史资料。

## 3. 仓库地图

```text
BeautySDK/                       Swift Package、library、renderer 与 tests
scripts/                         SDK-owned archive/boundary/test gates
archives/legacy-ui/              verified historical UI/Demo ZIP artifacts
PLANS.md                         当前计划入口和按需加载导航
plans/                           现行计划、技术债与历史记录分片
docs/SDK_EFFECT_TAXONOMY.md      current effect/control taxonomy
docs/                            background and historical long-form material
.planning/                       active GSD state plus archived milestone evidence
```

## 4. 任务路由

| 任务类型 | 必读 / 必改 |
| --- | --- |
| 包、Target、依赖方向 | `ARCHITECTURE.md` |
| 参数、渲染状态、核心状态机 | `DESIGN.md` |
| 历史 UI/Demo 查询或恢复 | `FRONTEND.md`, `archives/legacy-ui/README.md` |
| 隐私、输入、资源、归档信任边界 | `SECURITY.md` |
| 错误、日志、性能、恢复 | `RELIABILITY.md` |
| SDK 使用旅程与验收 | `PRODUCT_SENSE.md` |
| 计划与技术债 | `PLANS.md`，再按链接读取 `plans/active/` 与 `plans/debt/current.md` |
| 测试与质量门禁 | `QUALITY_SCORE.md` |
| effect/control status | `docs/SDK_EFFECT_TAXONOMY.md` |

- Local-retouch/privacy/fixture work also follows `Skill("spike-findings-beauty")`.

## 5. 当前边界

- **所有者自用**：仓库内的 `public` 仅表示 Swift 访问级别和所有者本地宿主的
  可调用面，不表示第三方产品、公共包、二进制 SDK、模型权重、App Store、
  客户交付或任何发布承诺。
- 不向仓库或所有者控制环境以外分发源码包、二进制、Core ML 资源、训练权重、
  私有夹具或派生数据。若未来要改变这一边界，必须先新建明确授权的里程碑，
  重新审核许可证、安全、隐私、API 兼容和产品声明。
- 不新增或恢复应用源、UI 行为、application lifecycle 或 UI automation。
- 不把归档内容解压回仓库；恢复只进入新建临时目录，并先运行归档验证。
- 不把 raw masks、landmarks、pixels、private fixture locators 或 child transcripts 写入持久证据。
- v1.16 不修改 retained `Warp.metal`、不新增 Metal/GPU API/backend 或新算法。
- `去脂` 当前为 `suspended`：有界上睑亮度修正不等于脂肪/形态识别，自然外观
  效果未合格；2026-10-01 默认隐藏。保留 `upperEyelidFullnessReduction` 的字段、
  默认零值、Codable、显式调用、`BeautyExperimentalUpperEyelid*` 内部实现和安全
  测试；默认 renderer 清单/批量与常用示例不推荐或启用它。
- 2026-10-03 所有者重开并降低初版标准后，EYE光影与SEG同色贴片自动分支各自
  2方法×2版本均未合格。按所有者最新“连续执行、到能力边界即停止、本里程碑
  结束旧问题”的指示，以 `closed_with_unmet_objectives` 结束v1.25，详见
  [最终处置](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)与
  [R3终局范围](docs/RETOUCH_TERMINAL_SCOPE_2026-10-03.md)。未交付不冒充实现；
  同色物体/完整唇部保护仅保留现有host显式蒙版能力，自动保护缺口公开记录。
  两条失败路线不再列为active、下一轮G0或默认后续任务。一般“继续/下一步”
  不恢复研发；重开须所有者明确新范围与新假设/信息/资源，不能重置本轮预算。
  历史provisional接受、R1/R2研究和原待办不覆盖终局处置。没有预授权模型下载、
  训练、微调、数据采集或分发；未执行模型不能被写成已经失败。

- 数据、模型和权重的许可证必须覆盖实际的所有者内部用途；“自用、不分发”
  不自动等于“允许商业使用”。research-only 数据及派生模型只能进入隔离的
  非商业研究/评估路径。device、SDK 商业化、monetization、packaging、shipping、
  launch、外部分发与 release readiness 均不属于当前目标。

## 6. 项目级自动化验证政策

- 真实 iPhone 测试是 SDK 完成后由用户执行的可选验收与反馈，不是当前或未来
  里程碑的默认硬门禁、依赖或计划推进 blocker；只有用户在后续里程碑中明确
  提升为强制要求时，才可成为完成条件。
- SDK 里程碑以可重复的 SwiftPM 测试和 SDK-owned 脚本为主要证据。涉及图片
  效果时，测试必须通过实际输入/输出像素与元数据断言判断结果，覆盖适用的
  尺寸/extent、方向/镜像、色彩空间、alpha、neutral identity、目标区域变化、
  保护区域不变、容差、确定性与 typed failure；不能用“脚本运行成功”代替结果
  正确性。
- 图片效果验收可使用有权本地使用的代码生成图或 AI 生成肖像，正例、负例和
  保护区均可由生成输入提供；生成来源本身不降低验收等级。真人肖像和真实
  设备均为可选补充，不得因缺少真人图像而阻塞里程碑、taxonomy 提升或后续
  计划。效果方向、负例、不恶化、保护区、重复性、元数据和 typed failure 仍
  须用实际输入/输出验证；仅有变化像素数不够。具体规则见
  `docs/IMAGE_EFFECT_ACCEPTANCE.md`。raw pixels、masks、landmarks、私有路径和
  生成图片不得进入持久证据。
- SDK 完成后的真实设备反馈作为补充发现记录到 `PLANS.md`，必要时进入后续
  修复计划；它不追溯否定当时已通过的自动化里程碑，除非暴露出可复现的契约
  缺陷。
- 没有真实设备证据时，仍不得宣称设备性能、温升、耗电、长稳、商业视觉质量、
  packaging、shipping、launch 或 release readiness；这是声明边界，不是计划
  blocker。

## 7. 工作流

1. **Orient**：读取计划、owner、相关 source/test。
2. **Scope**：确认最小改动与 SwiftPM/SDK-owned 验证。
3. **Edit**：遵循现有 Target 边界、命名与抽象层级。
4. **Verify**：运行最窄但有意义的 SwiftPM test 或 SDK-owned script。
5. **Record**：更新 `PLANS.md` 与被改动契约 owner。

不要依赖聊天记忆；长期决定必须沉淀到仓库文本。

## 8. 操作约束

- 不扩大任务边界；额外问题写入 `PLANS.md`。
- 不覆盖用户未要求修改的本地变更。
- 新增 owner-local Swift `public` 行为补 `PRODUCT_SENSE.md`；新架构补 `ARCHITECTURE.md`。
- 新风险补 `SECURITY.md`；新错误、日志或性能行为补 `RELIABILITY.md`。
- 历史归档与 archived milestone evidence 保持只读。
- 清理构建缓存时先核对 ignored/未跟踪身份及冻结源引用；`BeautySDK/.build`
  含保留的冻结夹具和回执，不能按纯缓存整体删除。仅移除已确认可重建的
  编译/索引产物与工作副本，保留 Serena 项目状态、源码与历史证据。

## 9. 基础命令

```bash
rg --files
swift build --package-path BeautySDK
swift test --package-path BeautySDK
swift run --package-path BeautySDK BeautyExampleRenderer --help
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/run-no-skip-swiftpm.sh
```

完整 owner-local 里程碑 closeout 使用最后一个命令；它必须先验证历史归档和
SDK-only boundary，再执行 all-opt-ins、zero-failure、zero-skip、nonzero-test
的 SwiftPM gate。该结果不构成任何外部发布或分发批准。

## 10. 示例图存储限制

- `example-images/` 总计最多 **128 MiB / 160 张图片**，单张最多 **16 MiB**；
  `input/` 最多 **16 张 / 32 MiB**。新增或生成图片后运行
  `python3 -B scripts/manage-example-images.py check`；全量测试入口也强制检查。
- 日常展示图通过 `manage-example-images.py preview <source> --name <opaque-id>`
  写入 ignored `previews/`：最多 **32 张**、每张 **512 KiB**、长边 **1600 px**，
  使用 JPEG 压缩并移除源元数据。不要为展示永久保留全量 PNG 和多轮副本。
- 验收原图、固定哈希夹具和蒙版保持原字节；压缩预览不作为像素验收输入。
  全量原尺寸输出在临时目录评估，用完删除，只留下聚合回执。
- `manage-example-images.py clean` 仅删除已登记的可重建缓存；保留输入、停用
  兼容夹具、两个当前验收包的清单资产与文本证据。未分类文件不自动删除。
  具体规则和用法见 [example-images/README.md](example-images/README.md)。
