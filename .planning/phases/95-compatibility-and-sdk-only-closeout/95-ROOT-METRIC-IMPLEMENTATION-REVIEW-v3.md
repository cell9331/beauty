---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-14T03:30:29Z
reviewer: "Codex / GPT-6，当前独立复审 agent；非主实现者；inline gsd-code-reviewer"
depth: standard
review_scope: generated-only-draft2-math-and-prior-four-findings
base_commit: a74b8c33d5dfe83daa6fd44f0c0743a286b62165
files_reviewed: 3
files_reviewed_list:
  - scripts/phase95-root-edge-metric.swift
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md
  - BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift
source_sha256: 7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
freeze_disposition: approve_exact_generic_generated_prototype_only
metric_identifier: rootStructuralEdgeSpanQ16_v2_draft2
portrait_registration_approved: false
portrait_scoring_approved: false
source_measurability_established: false
final_phase95_review: false
---

# Phase 95 generated-only 数学 prototype 独立复审 v3

## Narrative Findings (AI reviewer)

**批准下列精确字节的 draft 2 作为通用 generated 数学定义冻结。** 前审三个 BLOCKER 与一个 WARNING 均已修复；本次限定复审没有发现新的可证实 correctness/security/测试可靠性缺陷。结论来自实现与公式核对、实际回归及有限独立组合探针，不以“测试通过”代替数学模型核对，也不声称穷举任意图像。

这里的“通用”指冻结 source-independent 的注册、forward sampling、nuisance、拒绝、commitment 与区间公式；不是保证所有 source 都可测，更不是解剖对应或真实效果结论。原 ROI、threshold、source、注册 v1 与失败历史不变。SPEC 中 pending review 是本报告之前的状态，本 reviewer 未改写该历史。

## 前审 finding disposition

| 前审 finding / 原分类 | 本次 disposition | 当前实现证据 |
| --- | --- | --- |
| CR-01 / BLOCKER：组合亚像素位移与 blur 漏真值 | **Resolved** | `scripts/phase95-root-edge-metric.swift:116` 直接读取 candidate 整数样本；P 的 cell envelope 同时包含位移半格及连续 radius-two blur。旧反例进入 self-test；新增独立非网格中心组合检查没有漏真值。 |
| CR-02 / BLOCKER：six-pixel hull 少一个 tick | **Resolved** | 同文件 `:169` 对完整 cell hull 使用 `last-first+1 <= 96`，并在减法前限制内部 tick 范围；`:544` 覆盖 95/96 个中心间隔，保留真实 ramp 的 bound-or-abstain 回归。 |
| CR-03 / BLOCKER：invalidROI 溢出 | **Resolved** | 同文件 `:177` 先验证两轴 `0 <= min < max <= dimension`，再减法、midpoint 与 row-bin。八种极端/反序/空 ROI 现在实际调用 register 并要求 typed invalidInput；受限尺寸足以界定后续整数运算。 |
| WR-01 / WARNING：阈值相等时越段 oracle 太窄 | **Resolved** | `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift:159` 对固定 half-strip 的全部线段求 ±0.5 envelope 与阈值的交集 hull，包含水平阈值段与相邻缓坡；`:180` 检查两种极性、两种舍入方向及 strict-endpoint rejection。 |

以上定位相对于 `/Users/yakangwang/codes/beauty/`，均为本报告 SHA 对应的行号。没有将历史已解决 finding 计为当前 unresolved finding。

## 数学、stencil、舍入与身份核对

1. **Forward 定义与源支持一致。** `position` 是原 anchor 加位移，P 的坐标相对于原 anchor；所以 `P(k-position+s)` 与规范以全局源坐标表述的 `P(k-displacement+s)` 一致。十三个 candidate 样本的 k 由 cell 中心的 floor 固定。对 cell 内任意真位移，扩展 ±1/32 后再并入连续 blur 支持，端点和所有整数 knot 的 extrema 包含 piecewise-linear P 的全部可能值；没有 candidate 二次插值。跨整数的 cell 也保持这个固定 stencil，不会漏掉该 cell 中的模型内解释。

2. **21-sample profile 足够且被冻结。** 源轮廓为 offsets -10...10。考虑 floor 相位、±6 candidate offsets、±2 blur、±1/32 cell，所有 profile 求值仍严格位于该范围内，且 guard 十像素比所需 candidate stencil 更宽。source profile、固定行、anchor/search window、ROI、排序 exclusions 与 source digest 进入 commitment；profile 数量在评分入口固定验证为 21。输出不重选 anchor 或 row，不把遗漏行算作成功。

3. **Gain/offset projection 正确且保守。** 对每个样本的源范围 `[l_i,h_i]`、输出误差范围 `[L_i,U_i]`，共享 offset 存在的条件是所有 `g*(l_j-h_i) <= U_j-L_i`。当前正系数收紧 gain 上界、负系数收紧下界，与 `[0.5,2]` 相交，符号正确。每个样本独立 envelope 可能保留不可同时实现的解释；这会扩大区间或触发 abstention，不会因择优核而丢失一个模型内解释。

4. **舍入与最终区间方向正确。** 有限 Q8/256 与二进制 tick/半格使 profile 插值和局部差分系数可精确表示；除法边界向外一 ULP。locate 保留全部兼容 cell，拒绝分裂集合与搜索边界，六像素针对数学 hull，随后仅作浮点包围。宽度的左右界相减、逐行累加、正 scale 和 full-image-width Q16 归一化方向均向外。signed 同时取 source/neutral 的保守差；distinct 对三个 sibling 求最小区间距离，未发现端点或符号错误。

5. **模型与可测性承诺没有混用。** 连续解析 stripe 重新做 area rasterization，与平移冻结离散 source 的 PL 曲线不是同一个采样过程。SPEC 明示差别，保留原 size/phase 的 bound-or-abstain 检查，并额外要求每个 case 的 forward contraction 可测。三个原 strong/low-contrast positive 仍必须可测且满足原差值门槛。扩展窗口及其早期失败记录保留；本次没有读取 portrait 来选择常量。模型只覆盖已声明的凸 blur、gain/offset、总误差和非饱和样本，不外推到 sharpening、任意纹理或任意 renderer。

6. **Identity 的内外边界明确。** width 先验证结构和值域，再将重算 commitment 与独立 expected commitment 比较；修改 profile 的现有攻击被拒绝。固定字节序、域分离和完整 source digest 得以保留。原 schema 的外部身份问题与未来 amendment/report 集成不是当前 standalone prototype 已实现能力，本报告不重复作为 prototype bug，也不为其签字。

## Reviewer 实际验证

环境：Apple Swift 6.3.3，arm64 macOS。子进程 stdout/stderr 仅内存捕获后筛选，未落盘 transcript、像素、geometry 或图片。

| 检查 | 本次结果 |
| --- | --- |
| `swift -O scripts/phase95-root-edge-metric.swift --self-test` | exit 0；346 checks；portrait scoring disabled；stderr 0 行。 |
| `swift test --package-path BeautySDK --filter 'PortraitNoseRegistrationTests\|RootMetricCounterexampleTests\|HorizontalInwardWarpSafetyTests'` | exit 0；7+2+2=11 XCTest，0 failures，0 skips。仅选 generated suites。 |
| 独立 forward/cell 组合探针，经 `swift -O -` 内存输入 | 486 次真实位置所在 cell 的 compatibility 检查；54 次额外 locate 中 52 次返回、2 次 typed abstention；总 containment failures 0，exit 0。 |
| 三个 scoped 文件 `git diff --check` | exit 0；其中 untracked 文件不被 git diff 覆盖，该项不替代内容审阅。 |
| source/spec/test SHA 前后复核；前审与 `a74b8c33` 比对 | 三个输入 SHA 不变；前审当前字节与该 commit 完全相同。 |

独立探针与脚本 self-test 分开编写，只复用被审实现定义部分。有限矩阵为三种对比度、九个正负位移相位（含半 cell 边界与相邻整数两侧）、三个 gain、两个极端单点核及一个含非整数支持的凸核，叠加确定性 ±1.5 扰动后量化。每项直接要求最近 cell 保留独立已知位移；选定组合再要求 locate 返回包含真值或 typed abstention。只持久化上述计数与固定测试定义，不保存生成样本或定位结果。

未复跑 comparator、全套 SwiftPM、no-skip、任何 portrait/private output、diagnostic 或 clean65；没有把主实现者的历史计数冒充本次执行。

## 精确审查身份与冻结范围

工作树 HEAD 为 `a74b8c33d5dfe83daa6fd44f0c0743a286b62165`；冻结针对下面的工作树 SHA-256，不代表 HEAD 已包含这些未提交实现。

| 审查文件 | SHA-256 |
| --- | --- |
| `scripts/phase95-root-edge-metric.swift` | `7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md` | `168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b` |
| `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift` | `9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4` |
| 只读前审 `95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v2.md` | `6c859b66b4a0ec443bef641f88bc863135a25125f06f8b4e0d4c8d14cf0196c8` |

已读 AGENTS、PLANS Active、当前 DESIGN/SECURITY/RELIABILITY/QUALITY Phase95 owner 段及两项指定技能。gsd-code-review 用于限定范围、独立 finding disposition 与身份报告；spike-findings-beauty 将本次结论限于 generated mechanics 和 request-local 隐私边界。Serena 不可用，采用本地读取；项目技能目录仅发现该 spike 技能，agent-skills 查询未增加技能。三个目标未被 gitignore 排除，未发现 `.codexignore`。

**后续仍须独立审查：** live adapter 的 canonical luma/metadata/input 检查；版本化 amendment 绑定原注册、spec/source/test/review/环境身份；同一 canonical source 的双眼 exclusions 与两次 source-only registration commitment；output 读取前后 identity 验证；report/reconciliation/classifier/gates。source 注册仍可能合法地 unavailable。本报告只批准 exact generic prototype，不批准 live 计分、不声明 source 已可测、不签 Phase95 完成或任何效果/外部分发结论。

## 交回主实现者

唯一持久交付为本 v3 报告，通过 apply_patch 新建。没有修改源码、spec、tests、owner、前审或其他既有 dirty 内容；没有 commit，没有创建 `95-INDEPENDENT-REPAIR-REVIEW.json`。本 reviewer 启动的 self-test、focused SwiftPM 和独立探针均已结束，**无仍在运行的检查**。主实现者可按已有授权恢复后续工作，不能将本次 prototype approval 当作后续集成或 Phase95 closeout approval。
