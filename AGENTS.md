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
2. 按任务类型读取对应根级 owner。
3. 再读相关代码、SwiftPM 测试与 `docs/` 背景资料。
4. 算法/control taxonomy 以 `docs/SDK_EFFECT_TAXONOMY.md` 为当前 authority。
5. 若契约变化，同步更新拥有该契约的文档。

冲突优先级：代码与测试 > `PLANS.md` > 根级专项文档 > `docs/` 历史资料。

## 3. 仓库地图

```text
BeautySDK/                       Swift Package、library、renderer 与 tests
scripts/                         SDK-owned archive/boundary/test gates
archives/legacy-ui/              verified historical UI/Demo ZIP artifacts
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
| 计划与技术债 | `PLANS.md` |
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
- 强制图片夹具优先使用代码生成、内存内、确定性的输入；某个算法的 owner
  若要求 rights-approved 本地正/负样本，仍通过自动化脚本执行并可作为该算法
  的独立门禁，但这不等于真实设备测试。raw pixels、masks、landmarks、私有
  路径和生成图片不得进入持久证据。
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
