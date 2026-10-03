# 去脂技术历史摘要（截至 2026-10-01）

本页保留从技术 owner 正文移出的旧实现、实验数字和未实施方案。它不是当前
研发计划，也不为后续数据、训练、模型或替代算法提供授权。当前状态是
`suspended`：自然图效果未合格，默认隐藏，保留显式兼容；完整现行边界见
[AGENTS.md](../../AGENTS.md)、[DESIGN.md](../../DESIGN.md) 和
[taxonomy](../SDK_EFFECT_TAXONOMY.md)。

## v1.18：机制与当时的未公开决定

- Phase 76 引入独立逐眼支持，请求复用已映射的 Vision 观察；坐标、支持、蒙版
  与像素保持请求局部，失效眼不影响另一眼。该所有权边界仍保留。
- Phase 77 当时的编辑器使用 3×3 低频盒均值和有界同量 RGB 修正；它只是机制
  候选。历史聚焦结果为 `7/0/0`，边界 mutation `8/8` 拒绝，archive-first
  全量 `797/0/0`。这不是当前编辑公式或自然效果证明。
- Phase 78 将 Phase 75 evaluator 作为证据准入权威；缺失或 metadata-only
  bundle 得到 `mechanics-only-not-promotion`。当时可选的 additive-map comparator
  没有获准。历史 decision tests 为 `6/0/0`，evaluator self-test 为 12 checks、
  8 mutation rejections，boundary checker 为 `8/8` 拒绝。
- Phase 79 保留当时 `61 fields / 5 presets / 74 renderer cases` 的未公开分支；
  全量门禁 `797/0/0`、8 opt-in、0 skip。该库存不约束后来新增的显式 API。
  当前 `check-v1-18-decision-binding.py` 只验证归档决定和其历史库存。

原记录：[Phase 76](../../.planning/milestones/v1.18-phases/76-per-eye-semantic-support-ownership/76-VERIFICATION.md)、
[Phase 77](../../.planning/milestones/v1.18-phases/77-deterministic-fullness-editor/77-VERIFICATION.md)、
[Phase 78](../../.planning/milestones/v1.18-phases/78-genuine-evaluation-and-candidate-decision/78-VERIFICATION.md)、
[Phase 79](../../.planning/milestones/v1.18-phases/79-conditional-productization-and-sdk-only-closeout/79-VERIFICATION.md)。

## v1.19：被否决的编辑候选

- v1 的全权重矩形被曲线 feather 和更窄的眉眼间隙支持取代；这个支持修正保留。
- v2 的生成测试通过，但首次历史图像自动验收只过 `14/19` 行，邻接修正最大
  跳变为 30，对照上限为 5，纹理保留未达到冻结界；没有进入人工效果复核。
  该阶段曾记录聚焦 `24/0/0`、普通 SwiftPM `803/0/8`；普通运行的 skip
  不是完整 closeout。
- v3 使用每眼单一非正 RGB 修正，满档中心至多 `-10`，仍受绝对 `16` 和全眼
  channel headroom 限制，再做 Q16 feather。生成保护、相邻连续性和纹理
  `>=0.98` 检查不足以证明效果；历史正例复核未发现可感知消减。
- v4 使用支持局部盒滤波、边界仿射平面及中央 residual 准入，初始修正为
  `-1.5 × residual × strength`，受 `±16`、RGB headroom 和 Q16 限制。
  当时生成测试用同模型 source score 的 `55%` 比率评价效果；该自评分不能
  代替独立目标。聚焦曾为 `30/0/0`、普通全量 `805/0/8`，后续冻结历史
  自动验收仍在 applicability、boundary continuity、minimum relief 上失败。

这些失败只否决实际测试过的候选；它们既不证明所有无模型方案都不可能，也不
证明训练模型必然有效。旧章节中的“不得再试启发式、唯一 learned 路线”不再是
当前技术约束。

## 2026-08-25：未实施的 learned hybrid 与显式兼容接受

Plan 80-19 曾提出单眼固定形状的 applicability/uncertainty、soft alpha、
两通道局部 flow 和一通道低频 log-luminance 输出，并规划 Core ML 转换比对、
授权数据与冻结效果验收。它没有成为当前架构或自动续作任务。Plan 80-20 只
留下无默认实现的 package prediction 协议及独立验证器；Plans 80-21/22 的
数据、训练、资源和激活工作在当日取消。

历史 validator evidence 为 `8/0/0`，所有上睑组 `23/0/0`，普通全量
`813/0/8`。这些结果证明失效退出和边界验证，没有模型、训练结果或效果资格。
旧方案的固定 tensor、四输出、资源加载、转换比对和私有 review 流程可查
[原设计](../../.planning/milestones/v1.19-phases/80-genuine-evidence-and-qualification-gate/80-LEARNED-HYBRID-DECISION.md)及
[80-20 实施摘要](../../.planning/milestones/v1.19-phases/80-genuine-evidence-and-qualification-gate/80-20-SUMMARY.md)；
引用这些归档不恢复其中的未来命令。真实 retained validator 的安全约束见当前
[DESIGN.md](../../DESIGN.md)。

v1.21 随后按所有者当时的决定公开 `upperEyelidFullnessReduction`，接受效果
偏弱的 provisional 本地调用。该阶段 archive-first 记录为 `816/0/0`、
8 opt-in、0 skip。2026-10-01 的暂停决定取代了这一产品状态，但保留字段、
零值、Codable 和显式调用兼容。

## 2026-09-24：gain 调整记录

v1.24 曾把 gain 从 `1.5` 改为 `1.8`，保持原支持、`3.5` 准入、`±16`、
Q16 及 immutable-source composition。固定生成源半档的同模型中央比率从
`0.4537424` 到 `0.3422654`；这一自评分改善没有证明自然图有效或无环。
这不是当前修正公式，原记录见
[v1.24 冻结文本](../../.planning/V1.24-UPPER-EYELID-CURRENT.md)。

## 2026-10-01：保留的修复与暂停决定

后续用独立匹配源 oracle 修复了受控源的过压/羽化环纹、低档量化损失，并补齐
32 种方向/镜像及 typed recovery 验收。程序校准源经过 live Vision 与公开
SDK 的通过只证明已知亮度目标，不证明原貌自然肖像效果。

固定自然挑战仍暴露准入和有效消减缺口。背景拟合、放松重建及颜色解释量候选
没有同时满足固定效果与不恶化界，均撤回。现行 model/editor 保留安全版本；
暂停不是把这些失败重标为通过。具体聚合结果保留在
[计划记录](../../plans/active/A-2026-09-27-remaining-effect-qualification.md)、
[质量记录](../../QUALITY_SCORE.md)及
[独立挑战复现器](../../scripts/experiments/upper-eyelid-natural-challenge/README.md)。

最终处置保留 77 个参数字段和 99 个 renderer 注册项，默认清单/批量为 98 项；
新增真实 CLI 验收确认隐藏与显式旧名兼容。处置 closeout 为 `1072/0/0`、
9 opt-in、0 skip；它没有授予自然图质量、设备、商业或外部分发资格。
