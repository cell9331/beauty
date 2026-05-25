# AGENTS.md

> `beauty` 仓库的 Agent 唯一入口。本文只做导航，不承载业务细节。
> 若需要解释、规则或决策，请写入下方对应文档。

## 1. 核心原则

- 仓库就是记录系统；仓库文本中不存在的事实，Agent 不得默认存在。
- `AGENTS.md` 保持约 100 行，只提供工作流、索引和路由规则。
- 具体约束由专项文档承载，避免在多个文件重复维护同一规则。
- 优先写不变量、边界和验收标准，少写过程性说明。
- 每次改动都必须让下一个 Agent 能追踪：改了什么、为什么、如何验证。

## 2. 阅读顺序

1. 先读 `AGENTS.md`。
2. 改动前读 `PLANS.md`，确认当前活跃计划与技术债。
3. 按任务类型读取对应专项文档。
4. 再读取相关代码、测试和 `docs/` 下的历史资料。
5. 若代码契约变化，同步更新拥有该契约的文档。

冲突优先级：代码与测试 > `PLANS.md` > 专项文档 > `docs/` 历史资料。

## 3. 仓库地图

```text
BeautyDemo/                       iOS Demo App 与 Xcode 工程
BeautyDemo/BeautyDemo/            当前 SwiftUI Demo 源码
docs/                             既有长文档与历史规划资料
AGENTS.md                         Agent 入口与全局路由
ARCHITECTURE.md                   系统域、包边界、依赖方向
DESIGN.md                         核心设计、数据结构、状态机
FRONTEND.md                       SwiftUI Demo、UI 状态、并发规则
SECURITY.md                       隐私、输入校验、资源信任边界
RELIABILITY.md                    错误处理、日志指标、性能与恢复
PRODUCT_SENSE.md                  用户旅程与可验证验收标准
PLANS.md                          Active / Completed / Tech Debt
QUALITY_SCORE.md                  覆盖率、质量分与文档巡检规则
```

## 4. 任务路由

| 任务类型 | 必读 / 必改 |
| --- | --- |
| 包拆分、模块职责、依赖方向 | `ARCHITECTURE.md` |
| 参数模型、渲染管线状态、核心状态机 | `DESIGN.md` |
| SwiftUI 页面、Demo 交互、App 侧状态 | `FRONTEND.md` |
| 隐私数据、输入校验、不可信资源 | `SECURITY.md` |
| 错误码、日志、指标、性能预算、恢复策略 | `RELIABILITY.md` |
| 用户体验、SDK 使用旅程、验收条件 | `PRODUCT_SENSE.md` |
| 计划推进、完成记录、技术债 | `PLANS.md` |
| 测试覆盖、质量扫描、自动修复目标 | `QUALITY_SCORE.md` |

## 5. 历史资料

在新的根级文档完成前，可参考：

- `docs/00_index.md`
- `docs/01_product_feature_plan.md`
- `docs/02_development_spec_and_engineering_guidelines.md`
- `docs/03_development_stages_full_plan.md`
- `docs/04_architecture_spm_skeleton.md`

匹配的根级文档建立后，以上文件降级为背景资料，不再作为当前契约。

## 6. Agent 工作流

1. **Orient**：读取计划、任务文档、相关代码。
2. **Scope**：确认最小改动范围与验证方式。
3. **Edit**：遵循既有命名、目录和抽象层级，做聚焦改动。
4. **Verify**：运行最窄但有意义的构建、测试或静态检查。
5. **Record**：更新 `PLANS.md` 与被改动契约所属文档。

不要依赖聊天记忆。所有长期有效的决定必须沉淀到仓库文本。

## 7. 操作约束

- 不把深层业务规则写进 `AGENTS.md`。
- 不在多个文档复制同一段事实；只保留一个权威位置。
- 不扩大任务边界；发现额外问题时记录到 `PLANS.md`。
- 不覆盖用户未要求修改的本地变更。
- 新增公开行为时，补 `PRODUCT_SENSE.md` 的验收标准。
- 新增架构边界时，补 `ARCHITECTURE.md` 的不变量。
- 新增风险边界时，补 `SECURITY.md` 的校验或禁止项。
- 新增性能、日志或错误处理时，补 `RELIABILITY.md`。

## 8. 基础命令

发现文件：

```bash
rg --files
```

查看 Xcode 工程配置：

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

构建前先确认本机可用 scheme 与模拟器，再运行：

```bash
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo build
```

若命令因本机 Xcode 配置失败，记录可复现的失败原因，不要伪造验证结果。
