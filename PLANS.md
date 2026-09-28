# PLANS.md

> `beauty` 的当前执行入口。先读本页，再按链接读取当前计划或相关历史记录。
> 本页与 `plans/active/`、`plans/debt/current.md` 共同拥有当前计划和技术债；`plans/history/` 是历史快照。

当前图片效果验收政策见 [IMAGE_EFFECT_ACCEPTANCE.md](docs/IMAGE_EFFECT_ACCEPTANCE.md)。有权使用的生成肖像可作正负例；真人图片和真实设备是可选补充。历史记录中相反的要求不约束新工作。

## 1. 阅读路径与更新规则

1. 每次工作先读本页；涉及现行任务，再读对应的 [Active 计划](plans/active/A-2026-09-27-remaining-effect-qualification.md)和[当前技术债](plans/debt/current.md)。
2. 查询已完成事项时，先读[历史索引](plans/history/README.md)，再打开匹配分片。可用 `rg -l '记录 ID 或关键词' plans/history` 定位，不必加载整个历史账本。
3. 开始工作前确认已有匹配计划，优先更新现有计划；每完成可验证步骤更新 checklist。
4. 阻塞需记录原因、尝试及下一步；完成后记录验证证据与剩余风险，移入 Completed。
5. 发现范围外问题写入当前技术债；契约变化同步更新对应根级 owner。未验证要写明原因。
6. 新 Active 计划各用一个 `plans/active/<ID>.md`；完成时将其全文移至 `plans/history/YYYY-MM/<ID>.md`，并更新本页与历史索引。2026-09-28 前的旧记录保存在索引所列分片中。

状态词：`planned` 待开始；`active` 推进中；`blocked` 等待条件；`verifying` 验证中；`completed` 已验证；`canceled` 明确取消并留原因。

## 2. 当前边界

- 产品面是所有者自用的 SDK-only SwiftPM library 与 SDK-owned 验证；本账本不授予设备、商业视觉质量或外部分发资格。
- 真实设备反馈可成为后续发现，不是当前自动化完成门禁。效果方向、保护区、重复性、元数据及 typed failure 以实际输入/输出为准。
- 历史分片保留当时的状态与证据，现行 taxonomy 以 [SDK_EFFECT_TAXONOMY.md](docs/SDK_EFFECT_TAXONOMY.md) 为准。

## 3. Active

### [A-2026-09-27-remaining-effect-qualification](plans/active/A-2026-09-27-remaining-effect-qualification.md)

- Status: `active`。15 项 `partial` 的语义验收和 provisional `去脂` 的弱效果仍待完成；已完成的保护区修复及 2026-09-28 全量门禁记录在计划正文。
- 当前缺口：发际线缺少可靠语义支撑；`去脂` 的两组自然风格正负源未安全入选。不要把二维示意图或变化像素数记作自然肖像效果合格。

## 3A. Historical Lifecycle Ledger（历史脚本锚点）

### A-2026-09-10-phase-93-registration-disposition（历史脚本查找锚点）

原记录已在[历史索引](plans/history/README.md)对应的 completed 分片。Phase 93 的 owner-local `93-CHECKS.json` 与 Phase 95 independent review 属于历史证据，不是当前 Active 计划。

## 4. Completed

### C-2026-09-28-progressive-planning-ledger

- Status: `completed`。将原 250 条 completed / lifecycle 记录、当前 Active 正文、当前与历史技术债、模板和历史附录拆分；本页保留当前状态与导航。原声明与状态不变，24 个相对链接改为指向原仓库文件的新路径。
- Verification: 与拆分前 `PLANS.md` 对照，35 条 completed、215 条 lifecycle 记录、Active、技术债、模板和附录均完整；迁移后的 Markdown 链接全部可解析。`git diff --check` 和 post-archive SDK-only boundary 通过；Phase 93 自测 `108/0/0`、Phase 94 自测 `16/0/0`；`bash scripts/run-no-skip-swiftpm.sh` 返回 0，8 个 opt-in 全执行、0 skip。历史回执未修改或重签。

最近已完成事项从[历史索引](plans/history/README.md)进入；2026-09-27 的 SDK 效果和风险记录在 [completed-01](plans/history/completed-01.md)。归档材料和旧回执不因本次移动而重新签发。

## 5. Tech Debt

- [当前技术债](plans/debt/current.md)：发际线语义、不足的泛化和皮肤语义边界；已完成或有界处理事项在正文按原记录说明。
- [历史技术债](plans/debt/historical.md)：Phase 95 当时发现及 TD-001 至 TD-024 状态快照。历史状态不能直接用作当前缺陷清单。

## 6. 模板与验证

新计划、完成记录和验证日志格式见 [TEMPLATES.md](plans/TEMPLATES.md)。仅文档调整也须记录差异校验和对应文档门禁；SwiftPM 全量门禁只有运行成功时才能写为通过。

## Phase94 Historical Final Owner Snapshot（历史脚本查找锚点）

此锚点复述当时封存条件，原文在[历史验证附录](plans/history/legacy-verification-appendix.md)。
Status: verifying (snapshot before independent goal decision).
MOUTH-01 的 Phase94 current41/41 验收绑定 CHECKS SHA256 `fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`；Phase95 与 full no-skip 是独立门禁。
当时 `94-REMAINING-COMPLETE.json` 缺失、过期或失败均意味着 incomplete；该历史条件不改变当前计划状态。
