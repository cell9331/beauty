# PLANS.md

> `beauty` 的执行追踪账本。任何 Agent 在改代码或改文档前必须读本文件。
> 本文件记录 Active、Completed、Tech Debt，并要求每次工作留下可追踪状态。

## 1. Update Rules

- 开始工作前：确认是否已有匹配 Active plan；优先更新既有计划，不重复创建。
- 工作过程中：每完成一个可验证步骤，就更新对应 checklist 状态。
- 遇到阻塞：记录 blocker、已尝试动作、下一步，而不是只写“失败”。
- 完成工作后：把计划移入 Completed，并记录验证证据。
- 发现非当前范围问题：写入 Tech Debt，不顺手扩大范围。
- 改变架构、设计、安全、可靠性或产品契约时，同步更新对应根级文档。
- 未运行验证时，必须写明“未验证”和原因。

## 2. Status Vocabulary

| Status | Meaning |
| --- | --- |
| `planned` | 已确认要做，但尚未开始。 |
| `active` | 当前正在推进。 |
| `blocked` | 因缺少信息、环境或决策而暂停。 |
| `verifying` | 实现或文档已写完，正在验证。 |
| `completed` | 已完成并记录验证。 |
| `canceled` | 明确取消，保留原因。 |

## 3. Active

No active plans.

## 4. Completed

### C-2026-06-10-gsd-codebase-remap

| Field | Value |
| --- | --- |
| Completed | 2026-06-10 |
| Scope | 重新运行 `$gsd-map-codebase`，为后续 `$gsd-new-project` brownfield 初始化生成当前 `.planning/codebase/`。 |
| Files | `.planning/codebase/STACK.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`, `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/TESTING.md`, `.planning/codebase/CONCERNS.md`, `PLANS.md` |
| Verification | `gsd-tools query init.map-codebase` 返回 `has_maps: false`、`codebase_dir_exists: false`、`date: 2026-06-10`；`wc -l .planning/codebase/*.md` 输出 145、136、117、99、97、151、169 行，合计 914 行；常见 secret/token `grep -E` 扫描输出 `SECRETS_FOUND=false`；未填模板标记扫描只命中 `CONVENTIONS.md` 中“当前源码没有 TODO/FIXME”的说明；`git diff --check -- .planning/codebase PLANS.md` 无输出。 |
| Build | 未运行；原因是本次只生成 GSD codebase map 文档并更新计划账本，未改 Swift / Xcode 工程。 |

Outcome:

- `.planning/codebase/` 已重新包含 GSD 要求的 7 个映射文档。
- 映射记录当前真实代码面：仓库内只有 `BeautyDemo` SwiftUI Demo 壳，目标 SDK package、测试 target、CI 与 privacy manifest 尚未落地。
- 当前 runtime 无专用 `Agent` 工具；按 `$gsd-map-codebase` fallback 以顺序 inline mapping 完成。
- 后续可继续重新运行 `$gsd-new-project`，进入 brownfield 项目初始化。

### C-2026-05-25-root-git-initialized

| Field | Value |
| --- | --- |
| Completed | 2026-05-25 |
| Scope | 将 `/Users/yakangwang/codes/beauty` 初始化为 Git 仓库根，并让根级文档与 Demo App 位于同一仓库可追踪范围内。 |
| Files | `.gitignore`, `PLANS.md`, Git metadata |
| Verification | `git status --short --branch` 在初始提交后显示干净的 `main` 分支；`git log --oneline --decorate -n 1` 显示最新提交为 `Initial repository setup`；`find . -maxdepth 3 -name .git -type d -print` 只返回 `./.git`；`git bundle verify .codex-backups/BeautyDemo_git_before_root_init_20260525_190709/BeautyDemo.bundle` 确认原 `BeautyDemo` Git 历史已完整备份。 |
| Build | 未运行；原因是只调整 Git 仓库元数据与追踪配置，未改 Swift / Xcode 工程。 |

Outcome:

- 根目录已成为唯一 Git 仓库入口。
- 原 `BeautyDemo/.git` 已移动到 `.codex-backups/BeautyDemo_git_before_root_init_20260525_190709/BeautyDemo.git`，并额外生成 `BeautyDemo.bundle` 作为完整历史备份。
- `.gitignore` 忽略 `.DS_Store`、`.codex-backups/` 与 `*.xcuserstate`，避免系统文件、本地备份和 Xcode UI 状态进入版本库。

### C-2026-05-25-root-docs-through-product-sense

| Field | Value |
| --- | --- |
| Completed | 2026-05-25 |
| Scope | 已生成从 The Map 到 Product Sense 的根级文档。 |
| Files | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md` |
| Verification | 对每个文件执行 `wc -l`、标题树检查、未填内容标记扫描、关键路径存在性检查。 |
| Build | 未运行；原因是只新增 Markdown 文档，未改 Swift / Xcode 工程。 |

Key Outcomes:

- `AGENTS.md` 成为 Agent 唯一入口。
- `ARCHITECTURE.md` 固化单 Package、多 Target、UI 外置的架构方向。
- `DESIGN.md` 固化参数模型、状态机、坐标与 RenderGraph 设计。
- `FRONTEND.md` 固化 SwiftUI Demo 层边界。
- `SECURITY.md` 固化隐私、权限、资源和日志安全。
- `RELIABILITY.md` 固化错误、降级、性能和可观测性。
- `PRODUCT_SENSE.md` 固化用户旅程与 Agent 可验证验收标准。

### C-2026-05-25-agent-first-doc-system

| Field | Value |
| --- | --- |
| Completed | 2026-05-25 |
| Scope | 完成 `beauty` 根级 Agent-First 文档体系。 |
| Files | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `PLANS.md`, `QUALITY_SCORE.md` |
| Verification | 全部根级文档存在；总计 2898 行；执行标题树检查和未填内容标记扫描。 |
| Build | 未运行；原因是只新增和更新 Markdown 文档，未改 Swift / Xcode 工程。 |

Outcome:

- 9 个根级文档已形成完整 Agent-First 知识库。
- `PLANS.md` 保留下一阶段技术债入口。
- `QUALITY_SCORE.md` 给出当前真实质量基线与修复队列。

## 5. Tech Debt

| ID | Area | Debt | Impact | Suggested Next Step | Status |
| --- | --- | --- | --- | --- | --- |
| TD-001 | Project Structure | 根目录不是 Git 仓库，`.git` 位于 `BeautyDemo/` 下。 | 根级文档变更不一定被当前 Git 仓库追踪。 | 已将 `/Users/yakangwang/codes/beauty` 初始化为仓库根；原 `BeautyDemo` Git 历史已备份到 `.codex-backups/BeautyDemo_git_before_root_init_20260525_190709/`。 | `completed` |
| TD-002 | SDK Package | `BeautySDK` Swift Package 尚未创建。 | 根级架构文档已定义目标结构，但代码仍只有 Demo 模板。 | 按 `ARCHITECTURE.md` 创建 SPM 和 Target 骨架。 | `open` |
| TD-003 | Demo UI | `BeautyDemo` 仍是默认 `Hello, world!` SwiftUI 模板。 | 无法验证产品旅程、参数面板、相机预览。 | 按 `FRONTEND.md` 建立 Demo App 目录与最小页面。 | `open` |
| TD-004 | Tests | 尚无 SDK 单元测试、渲染测试、UI 测试。 | 质量评分和发布门禁暂只能靠文档检查。 | 创建 `BeautyCoreTests` 等测试 Target 后补齐 `QUALITY_SCORE.md` 指标。 | `open` |
| TD-005 | Privacy Manifest | 尚未创建 `PrivacyInfo.xcprivacy`。 | 未来分发 SDK 或使用 required-reason APIs 时会成为合规风险。 | SDK target 创建后按 `SECURITY.md` 评估并添加。 | `open` |
| TD-006 | Historical Docs | `docs/` 下历史长文档与根级文档存在重叠。 | Agent 可能读取到旧结论。 | 在 `QUALITY_SCORE.md` 中加入重复/冲突扫描规则。 | `open` |

## 6. Plan Template

Create a new plan by copying this structure and filling every field before implementation starts.

```markdown
### P-YYYY-MM-DD-short-slug

| Field | Value |
| --- | --- |
| Status | `planned` |
| Owner | Agent or human owner |
| Started | YYYY-MM-DD |
| Scope | One sentence describing the bounded task. |
| Source Request | User request, issue, or triggering document. |
| Current Step | First concrete step. |
| Verification Policy | Commands or checks required before completion. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Define scope | `planned` | Evidence will be added when complete. |
| Implement or edit | `planned` | Evidence will be added when complete. |
| Verify | `planned` | Evidence will be added when complete. |
| Record outcome | `planned` | Evidence will be added when complete. |

Open Questions:

| Question | Current Decision |
| --- | --- |
| Decision needed | Decision owner and current state. |
```

## 7. Completion Template

When moving a plan to Completed, include:

```markdown
### C-YYYY-MM-DD-short-slug

| Field | Value |
| --- | --- |
| Completed | YYYY-MM-DD |
| Scope | What changed. |
| Files | Files created or modified. |
| Verification | Commands or checks run, with result. |
| Build | Build/test status, or explicit reason not run. |

Outcome:

- Observable result.
- Remaining risk, if any.
```

## 8. Verification Log Rules

Verification records must include:

- Command or inspection performed.
- Result observed.
- Scope of confidence.
- Any skipped checks and reason.

Acceptable examples:

| Claim | Required Evidence |
| --- | --- |
| Markdown file generated | `wc -l`, heading scan, placeholder scan. |
| Swift code compiles | Exact `xcodebuild` or `swift test` command with exit status. |
| UI flow works | Simulator or UI test evidence. |
| Performance target met | Device/simulator, resolution, duration, metric result. |
| Security constraint met | Specific validation/logging/resource test. |

不要把未经验证的主观判断写成验证结论。
