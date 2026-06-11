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

No active plan.

## 4. Completed

### C-2026-06-11-gsd-phase-2-demo-integration-shell

| Field | Value |
| --- | --- |
| Completed | 2026-06-11 |
| Scope | Executed GSD Phase 2: wired `BeautyDemo` through the public `BeautySDK` facade, rendered the editor shell/category skeleton, and added deterministic Demo view-state tests. |
| Files | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`, `BeautyDemo/BeautyDemo/Panel/*.swift`, `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`, `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift`, `BeautyDemo/BeautyDemoTests/*.swift`, `.planning/phases/02-demo-integration-shell/*-SUMMARY.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK` passed with 20 XCTest cases; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` listed targets `BeautyDemo`, `BeautyDemoTests` and schemes `BeautyDemo`, `BeautySDK`; simulator `xcodebuild build` and `xcodebuild test` passed for `platform=iOS Simulator,name=iPhone 17,OS=26.5` with 22 Demo XCTest cases; forbidden internal import scan returned no matches; `Hello, world!` scan returned no matches; media/network scan returned no matches; requirement trace scan found `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08`; `git diff --check` exited 0. |
| Build | SDK package tests and Demo simulator build/test passed. |

Outcome:

- Demo app/test target imports the public `BeautySDK` facade and no internal SDK targets.
- Editor shell now uses feature directories for App, Editor, Panel, State, and Support.
- Demo first screen renders a static preview fixture, disabled Camera/Photo entries, descriptor-driven category rail, active panel, sliders, reset controls, and honest disabled/future availability states.
- Top-level categories and Facial Features subcategories are represented through deterministic descriptors and covered by tests.
- App-side parameter display values clamp and normalize into public `BeautyParameters` snapshots, including single-reset and reset-all behavior.
- Phase 2 requirement IDs `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08` are complete in `.planning/REQUIREMENTS.md`.

### C-2026-06-11-gsd-phase-1-sdk-foundation

| Field | Value |
| --- | --- |
| Completed | 2026-06-11 |
| Scope | Executed GSD Phase 1: created the local `BeautySDK` Swift Package foundation, facade-accessible public models, preset validation, no-op engine/copy path, and foundation XCTest coverage. |
| Files | `BeautySDK/Package.swift`, `BeautySDK/Sources/**`, `BeautySDK/Tests/**`, `.planning/phases/01-sdk-foundation-and-public-facade/*-SUMMARY.md`, `ARCHITECTURE.md`, `SECURITY.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK` passed with 20 XCTest cases; forbidden internal import scan over `BeautyDemo BeautySDK/Tests` returned no matches; SDK SwiftUI/UIKit scan returned no matches; release-path crash shortcut scan returned no matches; `processFrame/processImage/updateParameters` scan returned no matches; requirement trace scan found `SDK-01` through `SDK-07` in `BeautySDK/Tests`; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` exited 0 and listed scheme `BeautyDemo`; `git diff --check -- .planning PLANS.md BeautySDK QUALITY_SCORE.md ARCHITECTURE.md DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md` exited 0. |
| Build | Package tests passed. Demo simulator build was not run because Phase 1 did not wire the package into the Xcode project; Demo integration remains Phase 2 scope. |

Outcome:

- Host-style tests import only `BeautySDK` and can access `BeautyEngine`, `BeautyConfiguration`, `BeautyParameters`, `BeautyPreset`, `BeautyResult`, and `BeautyError`.
- `BeautyParameters` has the 31-field 1.0 model with no-op defaults, Codable/Equatable/Sendable behavior, clamping, and non-finite reset to zero.
- `BeautyPreset.decode(from:)` ignores unknown JSON fields, rejects invalid IDs, and rejects unknown Phase 1 filter resources with typed errors.
- `BeautyEngine` exposes direct media `process(pixelBuffer:orientation:parameters:)` and `process(image:orientation:parameters:)` APIs, returns SDK-created no-op outputs, maps unsupported BGRA inputs to typed errors, and has idempotent `reset()`.
- `BeautyRender` contains foundation `RenderGraph`, `RenderPass`, `CopyRenderPass`, `PixelBufferFactory`, and `Shaders/Warp.metal` placeholder; render internals are available to tests through `BeautySDK` testing SPI, not normal host imports.

### C-2026-06-10-gsd-new-project-init

| Field | Value |
| --- | --- |
| Completed | 2026-06-10 |
| Scope | 完成 `$gsd-new-project` brownfield 初始化：project context、workflow config、research、requirements、roadmap、state。 |
| Files | `.planning/PROJECT.md`, `.planning/config.json`, `.planning/research/STACK.md`, `.planning/research/FEATURES.md`, `.planning/research/ARCHITECTURE.md`, `.planning/research/PITFALLS.md`, `.planning/research/SUMMARY.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `.planning/PROJECT.md` 103 行并提交 `0b3cc88`；`.planning/config.json` JSON parse 通过并提交 `af2bb73`；research 5 文件合计 920 行并提交 `39a0d34`；`.planning/REQUIREMENTS.md` 133 行、v1 33 条并提交 `c77745d`；roadmap/state/requirements traceability 提交 `d1e78d3`；`roadmap.get-phase 1` 返回 `found: true`、`mode: mvp`；coverage script 输出 `v1_ids: 33`、`traceability_rows: 33`、`roadmap_refs: 33`、无 missing / duplicate；secret scans 输出 `SECRETS_FOUND=false`；`git diff --check` 对 GSD artifacts 无输出。 |
| Build | 未运行；原因是本次只生成 GSD planning artifacts，未改 Swift / Xcode 工程源码。 |

Outcome:

- 项目方向已固定为模块化 iOS 美颜 SDK，Demo 通过 `BeautySDK` public facade 展示类似美图秀秀/醒图的丰富能力。
- v1 requirements 共 33 条，覆盖 SDK foundation、input pipelines、MVP effects 和 rich Demo；advanced makeup / segmentation / body / stickers / AI style / video export 已延后到 v2+。
- Roadmap 共 7 个 `mvp` phase、27 个计划槽位；Phase 1 是 `SDK Foundation and Public Facade`。
- `AGENTS.md` 未由 `generate-claude-md` 覆盖：预览会生成 284 行 GSD 内容，且当前 `AGENTS.md` 已有仓库定制与未提交变更；直接覆盖会违反本仓库入口文件约束。

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

### C-2026-06-10-gsd-new-project-residue-cleanup

| Field | Value |
| --- | --- |
| Completed | 2026-06-10 |
| Scope | 删除未完成 `$gsd-new-project` 初始化留下的 `.planning` 残留文件，清空对应 Active plan。 |
| Files | Deleted `.planning/PROJECT.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/CONCERNS.md`, `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/STACK.md`, `.planning/codebase/STRUCTURE.md`, `.planning/codebase/TESTING.md`; updated `PLANS.md` |
| Verification | `[ -e .planning ]` 检查输出 `planning_exists=no`；`find .planning -maxdepth 3 -type f 2>/dev/null` 无输出；`gsd-tools query init.new-project` 返回 `project_exists: false`、`has_codebase_map: false`、`planning_exists: false`、`needs_codebase_map: true`。 |
| Build | 未运行；原因是只删除 GSD planning 残留并更新计划账本，未改 Swift / Xcode 工程。 |

Outcome:

- `$gsd-new-project` 之前停在 workflow preferences gate 的残留 project context、codebase map 与空 `.planning` 目录已移除。
- 旧的 `P-2026-06-03-gsd-new-project` 不再作为 Active plan 继续追踪。
- 后续重新运行 `$gsd-new-project` 会按 brownfield 分支重新检测现有代码并询问是否先 map codebase。

### C-2026-06-10-doc-drift-repair

| Field | Value |
| --- | --- |
| Completed | 2026-06-10 |
| Scope | 全面修复当前可验证的文档漂移：计划账本、文档入口、质量巡检、历史环境注记和 GSD project context。 |
| Files | `AGENTS.md`, `PLANS.md`, `QUALITY_SCORE.md`, `.planning/PROJECT.md`, `docs/README.md`, `docs/10_document_audit_report.md`, `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md`, `docs/superpowers/plans/2026-05-25-sdk-foundation.md` |
| Verification | `rg` 未填标记扫描对根级契约、`docs/README.md`、`.planning/PROJECT.md` 无命中；`rg` 旧 docs 文件名扫描对根级契约、`docs/README.md`、`.planning/PROJECT.md` 无命中；README 链接检查输出 `README links OK: 10`；`.planning` 状态检查输出 `planning-state-ok`；`docs_total.json` 引用检查输出 `docs_total references OK`；常见 secret/token `grep -E` 扫描输出 `secrets-scan-ok`；`git diff --check -- ...` 无输出；`xcode-select -p` 输出 `/Applications/Xcode.app/Contents/Developer`；`xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` 退出 0 并列出 target / scheme `BeautyDemo`；`xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` 退出 0 并输出 `** BUILD SUCCEEDED **`。 |
| Build | 已运行；只验证现有 Demo 壳，未新增 Swift / Xcode 工程源码。 |

Outcome:

- `PLANS.md` 已同步 `.planning/PROJECT.md` 当前事实：project context 已写入，workflow preferences / requirements / roadmap 仍待生成。
- `docs/README.md` 已成为更完整的长文档入口，包含权威层级、当前仓库状态、历史规划边界和当前 Xcode 验证状态。
- `QUALITY_SCORE.md` 已刷新到 2026-06-10，并新增 `.planning` 状态、README 链接、显式 simulator build 等 doc-gardening 检查。
- 2026-05-25 superpowers 规划保留原始 CommandLineTools 环境记录，同时补充 2026-06-10 full Xcode 复核，避免后续 Agent 复用过时失败原因。

### C-2026-06-03-gsd-codebase-map

| Field | Value |
| --- | --- |
| Completed | 2026-06-03 |
| Scope | 为 `$gsd-new-project` 的 brownfield 初始化分支生成 `.planning/codebase/` 代码库地图。 |
| Files | `.planning/codebase/STACK.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`, `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/TESTING.md`, `.planning/codebase/CONCERNS.md`, `PLANS.md` |
| Verification | `gsd-tools query init.map-codebase` 返回 `has_maps: false`、`codebase_dir: .planning/codebase`、`date: 2026-06-03`；`xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` 退出 0 并确认 target / scheme 为 `BeautyDemo`，但输出 CoreSimulatorService 与 cache/log permission warnings；`ls -la .planning/codebase` 确认 7 个文档存在；`wc -l .planning/codebase/*.md` 输出 127、110、105、87、92、115、103 行，合计 739 行；常见 secret/token `grep -E` 扫描无命中；未填内容标记 `rg` 扫描无命中；`git diff --check -- .planning/codebase PLANS.md` 无输出。 |
| Build | 未运行；原因是本次只新增 GSD codebase map 文档并更新计划账本，未改 Swift / Xcode 工程。 |

Outcome:

- `.planning/codebase/` 已包含 GSD 要求的 7 个映射文档。
- 映射明确区分主工作区当前实现、根级契约中的目标架构、以及被 `.gitignore` 忽略的 `.worktrees/sdk-foundation` 辅助 worktree。
- 因当前用户未显式要求 sub-agents，按 Codex runtime 约束采用 workflow 的顺序 inline fallback；未使用 subagent。

### C-2026-05-25-sdk-foundation-planning

| Field | Value |
| --- | --- |
| Completed | 2026-05-25 |
| Scope | 结合 `docs/` 长文档与根级契约，用 Superpowers 规划第一阶段 SDK 骨架与空渲染链路开发文档。 |
| Files | `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md`, `docs/superpowers/plans/2026-05-25-sdk-foundation.md`, `PLANS.md` |
| Verification | `wc -l` 输出 spec 344 行、plan 2051 行；`rg -n "^#{1,6} "` 已扫描 spec 与 plan 标题树；`rg` 未完成标记扫描对 spec、plan、`PLANS.md` 无命中；路径存在性检查输出 `superpowers planning paths OK`。 |
| Build | 未运行；原因是本次只新增 Superpowers 规划文档，未改 Swift / Xcode 工程。 |

Outcome:

- 已写入第一阶段设计 spec：`docs/superpowers/specs/2026-05-25-sdk-foundation-design.md`。
- 已写入可执行 implementation plan：`docs/superpowers/plans/2026-05-25-sdk-foundation.md`。
- implementation plan 按任务拆分 SDK SPM 骨架、Core 模型、Diagnostics、无效果 Engine、RenderGraph、Metal 资源、shell targets、Demo facade wiring、质量记录和最终验证。
- Xcode 工程接入在计划内排到 package tests 之后；若本机仍只有 CommandLineTools，计划要求记录真实 `xcodebuild` 环境失败原因。

### C-2026-05-25-refresh-root-docs-from-updated-docs

| Field | Value |
| --- | --- |
| Completed | 2026-05-25 |
| Scope | 根据更新后的 `docs/` 长文档与审计报告，同步刷新根级 Agent 契约文档。 |
| Files | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`, `docs/06_beauty_parameters_spec.md` |
| Verification | `rg` 旧文件名扫描在根级文档中无命中；`rg` 未填标记扫描在根级文档中无命中；`rg` 旧 shader / 旧参数数量 / 镜像配置扫描在当前文档中无命中；`node -e` README 链接检查输出 `README links OK: 10`；`rg` 确认 `docs/06_beauty_parameters_spec.md` 包含 `brightness` 字段、JSON 示例和“31 个字段”结论；`rg` 标题树检查完成；`git diff --check` 无输出。 |
| Build | 未运行；原因是只更新 Markdown 文档和文档巡检规则，未改 Swift / Xcode 工程。 |

Outcome:

- `AGENTS.md` 已指向新的 `docs/README.md` 长文档入口和 01-10 文件名。
- 根级契约已同步 Diagnostics、`BeautyConfiguration.logLevel`、1.0 的 31 个参数、`Warp.metal`、实时同步限制、BGRA 相机输出和日志落盘规则。
- `docs/06_beauty_parameters_spec.md` 的结构示例与 JSON 示例已补齐基础颜色字段，和 31 字段结论保持一致。
- `QUALITY_SCORE.md` 新增 docs 入口、旧文件名、source import JSON、关键术语一致性的巡检规则。

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
| TD-002 | SDK Package | `BeautySDK` Swift Package 尚未创建。 | 根级架构文档已定义目标结构，但代码仍只有 Demo 模板。 | Phase 1 已创建 SPM 与 facade / internal targets；后续按 roadmap 扩展真实检测、资源、效果和 Demo 集成。 | `completed` |
| TD-003 | Demo UI | `BeautyDemo` 仍是默认 `Hello, world!` SwiftUI 模板。 | 无法验证产品旅程、参数面板、相机预览。 | 按 `FRONTEND.md` 建立 Demo App 目录与最小页面。 | `open` |
| TD-004 | Tests | 尚无 SDK 单元测试、渲染测试、UI 测试。 | 质量评分和发布门禁暂只能靠文档检查。 | Phase 1 已创建 facade/core/render foundation XCTest；Detection、Resources、Effects、Demo UI、性能和长跑测试仍按后续阶段补齐。 | `partial` |
| TD-005 | Privacy Manifest | 尚未创建 `PrivacyInfo.xcprivacy`。 | 未来分发 SDK 或使用 required-reason APIs 时会成为合规风险。 | SDK target 创建后按 `SECURITY.md` 评估并添加。 | `open` |
| TD-006 | Historical Docs | `docs/` 下历史长文档与根级文档存在重叠。 | Agent 可能读取到旧结论。 | 已将 `docs/README.md` 设为长文档入口，并在 `QUALITY_SCORE.md` 中加入旧文件名、source import JSON、关键术语一致性扫描规则。 | `completed` |
| TD-007 | GSD Traceability | v2 `ADV-01` through `ADV-10` appear in `.planning/REQUIREMENTS.md` body but not its Traceability table; `phase.complete` warns about them. | GSD audits may continue surfacing deferred v2 IDs even though v1 SDK traceability is complete. | Decide whether deferred v2 requirements should be added to Traceability as Deferred or moved to a separate backlog table. | `open` |

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
