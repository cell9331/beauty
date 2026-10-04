# Requirements: Beauty v1.25 terminal disposition

Revision R3, 2026-10-03. **Status: closed_with_unmet_objectives**.

所有者最新要求连续执行、从简单方法开始，到实际能力边界停止，并在本里程碑
结束旧问题。[R3终局范围](../docs/RETOUCH_TERMINAL_SCOPE_2026-10-03.md)因此允许
“未交付并关闭”，没有把失败改成通过或把辅助蒙版替代自动功能。
[最终结果](../docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)记录实际实验与工程核对。

原[R2需求快照](V1.25-R2-REQUIREMENTS.md)及[验收契约](../docs/RETOUCH_MVP_REQUIREMENTS.md)
保持原阈值、输入要求和旧失败含义。下表是终局账本，不是新一轮待办。
`verified` 表示原条目有对应证据；`closed_unmet` 表示要求未达成且本轮停止。
共16项：5项verified、11项closed_unmet、0项待执行；两个自动效果交付数为0。

## Final traceability

| Requirement | 原阶段 | 终局状态 | 证据或未交付原因 |
| --- | --- | --- | --- |
| RSC25-01 | 100 | closed_unmet | SEG30例G0冻结；EYE简单诊断失败后停止，未制作完整30例G0。 |
| RSC25-02 | 101 | verified | 两分支方法/版本/预算与执行条件已登记；[行业来源复核](../docs/RETOUCH_INDUSTRY_DECISION_2026-10-03.md)明确采用条件，无第三方资产采用、模型执行或训练。 |
| SEG25-01 | 101 | closed_unmet | [四版开发比较](../docs/SEG_DEVELOPMENT_2026-10-03.md)已执行，但无法联合选出合格候选。 |
| SEG25-02 | 102 | closed_unmet | 无开发候选可进入G2，候选留出评估为零。 |
| SEG25-03 | 102 | closed_unmet | 开发负例有误保护/漏保护；未签自动拒绝集与状态资格。已有host能力不替代本项。 |
| LIP25-01 | 102 | closed_unmet | 旧低对比完整唇自动保护缺口仍在；[正确host并集](../docs/HOST_TEXTURE_PROTECTION.md)仅是保留的辅助路径。 |
| EYE25-01 | 100 | closed_unmet | 独立小规模参考/正确错误控制存在，但不完成原要求的完整G0。 |
| EYE25-02 | 103 | closed_unmet | [EYE最后三版](../scripts/experiments/retouch-terminal/README.md)与原E1-v1均拒绝；未通过G2。 |
| EYE25-03 | 103 | verified | 原字段、零值、Codable、显式调用及默认隐藏保留；生产/旧测试摘要未改，最新完整SDK门禁复核兼容。未借用眼高/提睑。 |
| INT25-01 | 104 | closed_unmet | 没有达到G2的自动分支，未进行生产集成。 |
| INT25-02 | 104 | closed_unmet | 未交付新分支，不能拿旧路径错误恢复或实验运行器覆盖冒充新分支资格。 |
| BAT25-01 | 104 | verified | [当前批量工具](../docs/CURRENT_BATCH_VALIDATION.md)独立核对98默认/99注册库存，旧wrapper只读。 |
| BAT25-02 | 104 | verified | 工具17/0/0；实际双次98输出与缺oracle控制区分通过、退出、失败、错误、未验证。 |
| VFY25-01 | 105 | closed_unmet | 没有交付分支可签G3；不将工程安全检查当图片效果验收。 |
| VFY25-02 | 105 | closed_unmet | 当前仓库另做了最新完整SDK门禁，但没有原条目要求的“接入代码”，所以不声称分支集成门禁完成。 |
| DOC25-01 | 105 | verified | 当前owner、taxonomy、PLANS、GSD和库存入口统一：两个自动目标未交付且关闭，辅助能力和批量工具保留。 |

## Closure boundary

里程碑已结清，但原R2“两个分支G3、16项全完成”的目标**没有实现**；不标记
`completed`，也不把六个阶段全勾选完成。当前执行队列为空，无下一轮G0、第五版
或隐式训练任务。高质量去脂、通用物体识别及低对比唇自动修复均为公开能力限制，
不自动迁入下个里程碑。重开需要所有者明确新范围与新假设/信息/资源。

## Preserved history

[R1需求](V1.25-R1-REQUIREMENTS.md)、[R2需求](V1.25-R2-REQUIREMENTS.md)、
[更早需求](PRE-V1.25-REQUIREMENTS.md)保持原文；旧失败不因关闭或工程测试通过而改签。
生成肖像仍可作完整效果验收输入；没有用缺真人、缺设备作为停止理由。
