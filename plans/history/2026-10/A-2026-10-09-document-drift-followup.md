# A-2026-10-09-document-drift-followup

| Field | Value |
| --- | --- |
| Status | `completed` |
| Started | 2026-10-09 |
| Source Request | 更新目录整理后的相关文档，修复文档漂移。 |
| Scope | 修复当前目录/权威导航、已实施与候选边界、组合预算和所有者诊断说明；不改代码、效果资格、冻结契约或历史验收结果。 |
| Current Step | 七类漂移已修复，导航、冻结绑定与文档门禁通过。 |
| Verification Policy | 当前 Markdown 链接/锚点、声明与源码核对；原文件摘要与冻结绑定；archive/boundary/wrapper 控制及 diff 检查。 |

## Findings and decisions

| ID | Drift | Repair |
| --- | --- | --- |
| D01 | AGENTS 的 docs 地图仍只写背景/历史；分类和固定路径规则未进入 owner；项目 skill 仍引用迁移前路径。 | 明确分类/兼容入口，QUALITY 统一维护；skill 与四份 reference 改用规范路径，标准诊断与既有 owner SPI 边界同步。 |
| D02 | 七份 dated codebase map 把 2026-10-01 审计称为最新库存；CONCERNS 又称这些快照是当前契约。 | 入口改指 QUALITY/当前 owner，保留 dated 正文与旧计数的历史语境。 |
| D03 | 学习手册仍笼统称 GeometryConflictResolver 限制所有参数总强度。 | 按源码区分 dense mapped 独立 cap、九个源字段保守预算及 legacy 总预算；最终地图负责实际组合安全。 |
| D04 | 关键点/工程手册及安全表未限定“没有原始点诊断”，遗漏已有 OwnerDiagnostics SPI。 | 标准结果保持聚合；所有者 SPI 仅瞬时 x/y，reflection 脱敏，禁止持久原始证据。 |
| D05 | 静图固定网格与双边细节仍被称为候选；原材料已读范围被泛化为全部后续导入内容。 | 同步已实施基线与真正未交付项；保留四份骨架静态评审的实际范围，不执行导入提示词。 |
| D06 | v1.25 1076/0/0 与“没有模型运行”等关闭快照容易被当成当前全项目状态。 | 限定至 2026-10-03 EYE/SEG 分支，当前平台/库存/验证从 owner 读取，不改关闭结果或 state metadata。 |
| D07 | 手册矩阵未明确按本次改动选取；taxonomy 的 Phase 91–94 历史叙述缺少一致标签。 | 明确最小充分验证与历史章节边界，不恢复旧计划或重签证据。 |

## Checklist

| Step | Status | Evidence |
| --- | --- | --- |
| 盘点及源码核对 | completed | 2,572 份文件摘要基线；93 源/24,371 行、147 测试/54,872 行与 QUALITY 一致；Serena 核对组合 resolver 与诊断 SPI。 |
| 修复相关说明 | completed | owner、目录/快照导航、五篇学习手册及五份 skill 文档同步；仅分类与现行声明，并行静图重构计划保留独立状态。 |
| 窄范围验证 | completed | 当前链接/锚点无新增失败，3 份 G0 绑定和 2,077 份原有历史/冻结/试验/测试文件摘要有效；archive/boundary/wrapper 控制/storage/diff 通过。 |
| 结项 | completed | 更新 PLANS 和月度索引；本任务未编辑 SDK 源码/测试，未运行 SwiftPM、设备或图片实验。 |

## Outcome and actual verification

- AGENTS 与 QUALITY 明确当前分类、固定 authority、compatibility 页与只读历史的维护边界。七份 codebase map 保留原分析日期/正文语境，导航改指当前库存与执行证据；CONCERNS 不再把旧 map 当现行契约。
- 学习手册、架构与安全说明按实际源码区分 dense mapped 独立 cap、九字段源预算和 legacy 总预算；标准结果与已授权 OwnerDiagnostics 瞬时 x/y 分开。仅说明现有能力，不新增诊断权限、算法、UI、模型或效果资格。
- 静图网格/双边细节/资源复用从“候选”改为已实施基线，视频/TPS/语义 mesh/GPU 原生/多尺度仍未交付。四份原始骨架的静态评审不被扩大为后续全部导入内容已读/执行；原始手册和提示词没有执行或修改。
- v1.25 的 1076/0/0 与未运行 learned EYE/SEG candidate 明确限定为 2026-10-03 终局域；当前平台与独立任务从 owner 进入。taxonomy 历史章节统一限定旧库存、旧队列与 signed 像素结果，保留旧锚点和数值。
- 初始库存核对为 93 源 / 147 测试。共享工作树在本任务期间另有 playbook SDK 重构：四份既有生产文件和一份 parity 脚本变化，另有新 stage/test；这些不是本任务编辑，不回退、不计为本任务实现。QUALITY 在 **2026-10-09 21:27:37 +08:00** 独立采样为 **94 源 / 24,297 行、148 测试 / 55,005 行**，包含未提交工作，绝非执行测试分母或新 checkpoint。
- 当前本地 Markdown 链接/锚点相对本轮基线无新增失败；86 条既有历史失效链接保持原范围。当前声明与源码/现行 owner 核对，旧路径/错误断言扫描无残留；只读历史与原始材料不批量改写。
- 2,077 份基线历史/冻结/实验/既有测试文件原字节有效；SEG G0 三份规范按原路径精确匹配原 SHA-256。原始 `.codex/skills/.../sources/`、历史验收和先前目录迁移记录未修改。
- `python3 -B scripts/archive-legacy-ui.py verify --output archives/legacy-ui`：两个 ZIP 身份通过。
- `bash scripts/check-sdk-only-boundary.sh --post-archive` 和 `--self-test`：退出 0。
- `bash scripts/run-no-skip-swiftpm.sh --self-test`：退出 0，14 checks / 14 mutation rejections；仅控制自测，不是完整 SwiftPM。
- `python3 -B scripts/manage-example-images.py check`：退出 0，27 图 / 8 输入 / 1 预览，30,637,971 bytes；本任务未改媒体。
- `git diff --check`：通过。没有本任务的 SDK 编译/SwiftPM、App、设备、像素或模型新执行，也没有重新签发任何旧工程门禁或泛化声明。并行重构的验证与完成状态仍由它自己的计划负责。
