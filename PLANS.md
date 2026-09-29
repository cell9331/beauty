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

- Status: `active`。**原 15 项 `partial` 的整组验收已完成**：逐项生成肖像正负例、方向、保护、重复、元数据与失效退出通过，taxonomy 为 15/15 限定范围 `implemented`。2026-09-28 完整 `bash scripts/run-no-skip-swiftpm.sh` 返回 0：1058 tests、0 failures、8 opt-in、0 skipped，archive-first 与 SDK 边界检查通过。本计划仍 active 仅承载另外两项质量缺口。
- 2026-09-29 当前工作树内容复核：`BeautyParameters` 为 77 个 stored fields，renderer 为 99 cases；已校正根级 owner 与 taxonomy 中误称旧库存为“当前”的句子。完整 archive-first no-skip 门禁再次返回 0，8 opt-in、0 skip；`去脂` 视觉质量改进和同肤色非皮肤物体保护仍未完成。
- 2026-09-29 后续修正：所有者提供正确的请求局部二值排除蒙版时，同肤色物体可在皮肤平滑/锐化阶段精确保护，公开生成图与 CPU/Metal-selected 对照通过；无蒙版的自动语义识别仍开放。又一张新生成 `去脂` 正例在效果输出之前双眼语义准入失败，未降低阈值或声称视觉质量改进。最新 archive-first no-skip 完整门禁返回 0，8 opt-in、0 skip，后端 parity 固定计数更新为 14；计划保持 active。
- 2026-09-29 提交前复核补齐编码 PNG 蒙版保护和错误网格后的同一 engine 恢复；完整 archive-first no-skip 门禁为 SwiftPM `1062/0/0`、8 opt-in、0 skip。该结果只确认当前 SDK 工作树；`去脂` 视觉质量和无蒙版自动同肤色物体识别仍开放。
- 2026-09-29 后续 `去脂` 受控生成肖像实验：双眼数值变化、负例和目标外保护均通过，但原尺寸输出在双侧上睑出现明显椭圆环纹，视觉不恶化失败。另一个视觉更饱满的自然风格编辑候选检测到 1 张脸、双眼语义准入均拒绝，源亮度凸起分数还低于编辑前，未进入效果输出。不计为视觉质量改进，不改生产阈值或效果；详情见 Active 计划，状态保持 `active`。
- 2026-09-29 [上睑与同肤色物体原始资料复核](docs/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md)已完成：现有 Apple 2D 点位与人物/前景蒙版不提供相应语义保证，现行上睑亮度残差不等于组织体积；受控输出环纹仍是视觉红灯。已修正当前验收政策与 owner 文档的表述；两项质量缺口继续开放，未据论文直接调整生产算法。
- 同日一次性环纹诊断将负残差提亮置零，现有聚焦数值测试通过但原尺寸暗环未消失；候选已撤回，未修改当前生产代码。详情见 Active 计划。
- 2026-09-30 新生成单眼正/负源对在 live Vision 下分别准入 1/0 眼；公开输出探索性检查发现正例目标内变化、负例源图一致，但首次 ROI 坐标按输出修正，且视觉变化轻、旧受控环纹仍存在，故不计为事前冻结的视觉质量验收。详见 [研究记录](docs/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md)与 Active 计划；生产效果未改，两项质量缺口仍开放。
- 当前整组验收范围：所有者本地生成图二维效果。去双下巴仅覆盖连续外轮廓隆起，不识别内部脂肪；头发与人中准入均不等于一般语义分割。`去脂` 仍是已接受的 provisional 弱效果，皮肤同色非皮肤物体仍是独立质量缺口，不计入 15 项；真人图、真机及商业质量均未作声明。

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
