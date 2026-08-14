# AGENTS.md

Spend time on thinking; you do not need to use the commentary channel to report progress to me.

> `beauty` 仓库的唯一入口。当前仓库是 SDK-only Swift Package；历史 UI/Demo
> 只能从已验证归档中恢复到仓库外的临时目录。

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

- 不新增或恢复应用源、UI 行为、application lifecycle 或 UI automation。
- 不把归档内容解压回仓库；恢复只进入新建临时目录，并先运行归档验证。
- 不把 raw masks、landmarks、pixels、private fixture locators 或 child transcripts 写入持久证据。
- v1.16 不修改 retained `Warp.metal`、不新增 Metal/GPU API/backend 或新算法。
- device、commercial、packaging、shipping、launch 与 release readiness 均不属于当前结论。

## 6. 工作流

1. **Orient**：读取计划、owner、相关 source/test。
2. **Scope**：确认最小改动与 SwiftPM/SDK-owned 验证。
3. **Edit**：遵循现有 Target 边界、命名与抽象层级。
4. **Verify**：运行最窄但有意义的 SwiftPM test 或 SDK-owned script。
5. **Record**：更新 `PLANS.md` 与被改动契约 owner。

不要依赖聊天记忆；长期决定必须沉淀到仓库文本。

## 7. 操作约束

- 不扩大任务边界；额外问题写入 `PLANS.md`。
- 不覆盖用户未要求修改的本地变更。
- 新公开行为补 `PRODUCT_SENSE.md`；新架构补 `ARCHITECTURE.md`。
- 新风险补 `SECURITY.md`；新错误、日志或性能行为补 `RELIABILITY.md`。
- 历史归档与 archived milestone evidence 保持只读。

## 8. 基础命令

```bash
rg --files
swift build --package-path BeautySDK
swift test --package-path BeautySDK
swift run --package-path BeautySDK BeautyExampleRenderer --help
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/run-no-skip-swiftpm.sh
```

完整 closeout 使用最后一个命令；它必须先验证历史归档和 SDK-only boundary，
再执行 all-opt-ins、zero-failure、zero-skip、nonzero-test 的 SwiftPM gate。
