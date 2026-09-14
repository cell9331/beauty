---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-14T03:09:46Z
reviewer: "Codex / GPT-6，独立 gsd-code-reviewer；非主实现者"
depth: standard
review_scope: generated-only-root-metric-prototype-and-two-prior-fixes
base_commit: 7d3d336bbc5988ab03805019fe0b6cd037194446
files_reviewed: 5
files_reviewed_list:
  - scripts/phase95-root-edge-metric.swift
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md
  - scripts/compare-face-feature-batches.swift
  - BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/RootMetricCounterexampleTests.swift
findings:
  critical: 3
  warning: 1
  info: 0
  total: 4
status: issues_found
freeze_disposition: not_ready_to_freeze_generic_prototype
portrait_registration_approved: false
portrait_scoring_approved: false
final_phase95_review: false
---

# Phase 95 新鼻根测量定义实施独立审查 v2

## Narrative Findings (AI reviewer)

**结论：当前 generated-only draft 不可冻结。** 数值规则已明显具体化，case→metric 校验与独立生成边界 oracle 也已有实质修复；但组合干扰下的定位区间不保守，六像素拒绝条件存在确定的差一格错误，非法 ROI 的校验顺序还可触发整数溢出。下面给出有限复现和修复建议，不要求穷举任意图片或无限证明。

本结论针对下列工作树字节，不是仅针对 HEAD，也不是 Phase95 完成签字。保持原 ROI、threshold、fixture、注册 v1 和历史结果。没有访问或运行任何 private portrait/output、诊断脚本或 clean65，没有用新 metric 给人像计分。

### CR-01 — BLOCKER：组合亚像素平移与允许的 blur 后，返回区间排除真实位置

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-root-edge-metric.swift:105-108,116-129,144-156`

**相关规范:** `/Users/yakangwang/codes/beauty/.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md:60-87`

**Issue:** source 模板只保存整数采样的 ±2 min/max；定位时却对已经栅格化的 candidate 再做线性插值。亚像素平移的第一次采样与定位的第二次插值组合后，相对于 source 的有效采样支持可超过模板的整数 ±2。当前 grid-cell 端点/中心计算正确包住了 **candidate 插值曲线**，却没有补上这个 **source nuisance envelope** 缺口。两者不能混为一项保守性证明。

**最小生成复现：** 复用脚本 `stripe(half: 0.12)` 的默认 source 和既有生成 ROI，仅构造内存 candidate：令 `P` 为该 source 行的分段线性插值，取共同亚像素平移 `d`，生成 `C[k] = P(k - d + s)`。`s=-2` 或 `s=2` 就是规范允许的极端单点凸核；另测左半 `s=-2`、右半 `s=2`，属于规范明确允许的空间变化核。无 noise、gain=1、offset=0、无 clipping，生成值满足 1/256 量化。source 注册始终不变，真实 anchor 位置是原 anchor 加共同平移，潜在结构宽度保持不变。

独立 Swift stdin 探针调用原 `register/locate/width/margins`，对五个固定相位 `1/8、1/4、1/2、3/4、7/8` 和上述三种核作检查：

- 30 次左右定位全部返回区间，其中 **24 次排除真实位置**；没有 typed abstention。
- 左右向内核的 5 次完整宽度计算全部返回，其中 **3 次宽度区间排除不变的真实宽度**。
- 该组完整 signed/distinct conjunction 的假通过次数是 **0**。不得把本发现写成已经复现完整 root gate 假阳性；已经复现的是“保守定位/宽度区间”这一核心契约失效。

另一个独立高对比度生成阶跃复核得到 20/20 定位排除真值、5/5 宽度排除真值，同样没有完整 margin 假通过。原 250 checks 将 blur/noise 与亚像素几何主要分开测试，因此通过并不覆盖此组合。

**Fix:** 先明确离散采样与 blur、平移、量化的操作顺序，再让每个候选位移单元的 source 包络覆盖该顺序。例如直接以 candidate **整数样本**对照按候选位移区间前向采样的 source 凸核包络，避免反向重插值漏算；或实现包含两次采样的相位相关包络。新增上述有限组合回归，要求返回区间包含真值，或明确返回 typed unavailable/ambiguous；同时保留原正例的可测性。不要仅把模板半径无条件增加到 3：这会扩大 source 自匹配集合，与六像素上限发生新的可测性冲突。模板/stencil 改变须同步 SPEC 和 commitment 内容，再作 generated-only 复核。

### CR-02 — BLOCKER：六像素判断遗漏两端半格，接受 6.0625 像素 hull

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-root-edge-metric.swift:152-156`

**相关规范:** `/Users/yakangwang/codes/beauty/.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md:84-87`

**Issue:** 代码判断 `last-first <= 6*16`，但返回的是首末中心各外扩 1/32 的 cell hull。其精确宽度是 `(last-first+1)/16`，不是 `(last-first)/16`；后续 nextDown/nextUp 还会略向外扩。中心跨度恰为 96 ticks 时，实际 hull 已是 97/16，即 6.0625 像素，仍被接受。

**生成复现：** 在分离且远离窗口边界的双阶跃 fixture 上，把两处过渡改为每像素 8、总对比度 40 的五步单调 ramp，左右极性相反，重复相同行。source 注册成功；原 `locate` 返回的两个 anchor hull 均超过六像素，且均为 97 ticks 加浮点外扩。独立有限扫描确认了这一实际可达边界，不只是公式推测。

**Fix:** 用整数 ticks 判断完整 cell hull：`last-first+1 <= 6*16`。规范应明确六像素上限针对数学 hull，端点随后仅为浮点表示向外舍入；若要求最终 Double 区间也不超过六像素，则还须对最终宽度检查。补上恰好 95/96 个中心间隔的拒绝边界测试，不提高六像素上限或原 16 Q16 验收阈值。

### CR-03 — BLOCKER：ROI 端点未先验证顺序，invalidInput 路径可以整数溢出

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-root-edge-metric.swift:159-163`

**Issue:** guard 在检查 `maxX-minX` / `maxY-minY` 前，只限制下端非负和上端不超过尺寸，没有先检查上端非负、端点顺序或下端不超过尺寸。一个正的 minX 与 `Int.min` 的 maxX 能通过前四个条件，在宽度减法处溢出，无法返回承诺的 typed `invalidInput`。Y 同理。

**验证：** 对合法生成 plane 和上述非法 ROI，独立探针确认前置条件为 true，随后用 `subtractingReportingOverflow` 确认 overflow=true；未实际触发进程 trap 或生成 crash transcript。这是可确定的 Swift checked-arithmetic 错误。当前 CLI 没有图片或 ROI 输入入口，因此本报告不把它夸大为已暴露的外部攻击入口。

**Fix:** 先验证 `0 <= minX < maxX <= width` 和 `0 <= minY < maxY <= height`，通过后再相减、求 midpoint 和 row-bin。已限定图像最大尺寸，按此顺序后后续整数运算有直接上界。增加极端负上端、极端正下端、反序、零宽高的 typed rejection 测试即可。

### WR-01 — WARNING：新 provider oracle 的舍入区间缺少阈值恰落采样点的处理

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift:125-143`

**Issue:** 新 oracle 已摆脱旧 dark-centroid，真正读取生成输出的边界。其 ±0.5 误差换算在真实 crossing 确定留在当前线段时成立；但 `value > 130` / `< 130` 选段后，某个端点可以恰等于 130。量化前 crossing 此时可能位于相邻线段，代码却继续以当前线段斜率向外推算。如果相邻段更缓，这个位置界过窄。

独立单调三点探针验证：中间样本量化后恰为阈值、量化前略低于阈值，前段较缓、后段较陡；所有样本满足 ±0.5 舍入契约，真实 crossing 却落在公式返回区间之外。该探针只保留固定失败计数，没有持久化样本或位置。本次六个 provider XCTest 均通过，**没有证据证明当前两张固定 fixture 已因此误通过**；这是该测试辅助 oracle 的边界可靠性缺口。

**Fix:** 在计算单段 crossing 前确认两个端点的完整 ±0.5 误差区间严格夹住阈值；不满足时，对相邻线段求可行 crossing 的 hull，或让该测试明确失败并要求消歧，不能外推成过窄置信区间。补一个阈值端点相等、相邻斜率不同的确定性单调样本，覆盖正反两种极性。

## 已核对的数学与身份边界

- **gain/offset：** pairwise projection 本身没有发现方向错误。令 source 范围为 `[l_i,h_i]`、candidate/noise 范围为 `[L_i,U_i]`，共享 offset 可行当且仅当对所有 i、j 有 `g*(l_j-h_i) <= U_j-L_i`；与 `0.5 <= g <= 2` 相交，正系数更新上界、负系数更新下界，正是当前实现。offset 无限制是明示规则。该判断是区间过近似，不宣称各位置样本的独立选择一定可同时实现。
- **舍入：** Q8/256 输入、二进制网格使当前局部加减和插值系数精确；除法 nextUp/nextDown、宽度累加和全图宽归一化向外舍入方向正确。CR-01 是采样模型漏项，CR-02 是完整 hull 宽度漏项，不是 gain 不等式符号问题。
- **source anchor：** 先固定 source 的最强局部差分、远峰拒绝、相反极性、跨行连续性和窗口，输出不重选 anchor。SPEC 已明确这是图像边缘假设，不能承诺鼻根解剖对应；无需为了这个有界 prototype 索取人像或更多人口证据。
- **固定 rows / eye exclusions：** source-only 选取、至少 12/16、输出任何已注册行失配就失败；眼盒行采用半开范围，stencil 受对应半区和排除边界限制。独立补测确认 12 行可注册、11 行拒绝、输出失去已注册行拒绝。未来 live registrar 必须提供同一 source 的双眼盒，当前默认空 exclusions 仅是 generated API 能力，不能冒充真人注册。
- **SHA：** 域分离、固定大端字、source plane、ROI、排序 exclusions、行/窗/模板进入 commitment。独立 expected commitment 与重算比较有效；补测 sourceDigest、ROI、行集合、exclusions mutation 均被拒绝，exclusion 输入顺序不同仍同摘要。内层摘要没有绑定实现字节，这是 SPEC 明确留给后续 amendment 的职责，本次不把“未集成”重复报成新漏洞。
- **防假收缩：** 保留全部兼容 cell、拒绝分裂集合及搜索边界、宽度区间下/上界分别用于 signed 与三个 sibling 距离，source/neutral 均不可省略；这些计算未发现另一个代数错误。其可信度以定位区间真能包住模型内位置为前提，CR-01 破坏了该前提。不得用现有 aggregate 未假通过来豁免区间缺陷。

## 上次 CR02 / WR01 disposition

| 上次问题 | 本次结论 |
| --- | --- |
| CR02：case→metric 漏检 | **该具体漏洞已修复。** 相对 `7d3d336b`，公共 `validateStablePayload` 增加 metric 等值 guard；八次 mutation 经 `runnerData` 重算摘要，再进入实际 `phase95Classification`，不是只测摘要不匹配。597 self-tests 通过。 |
| CR02：版本化 measurement identity / successor 链 | **仍是后续集成义务。** 本次没有接入新 metric，不能将内层 commitment 或此次 review 当成 amendment/report/classifier/gate 已通过。 |
| WR01：provider 测试复用旧 metric | **循环依赖已解除。** 已改为生成 40/220 结构的实际边界 crossing，无 provider 位移或新 metric 输出参与期望值；新舍入辅助公式仍有本次 WR-01 的边界问题。 |
| 历史诊断 | `RootMetricCounterexampleTests.swift` SHA 与上次一致，两条诊断通过；只说明旧数学反例，不计 provider 或新定义验收通过。 |

## 本次 generated 验证

环境：Apple Swift 6.3.3，arm64 macOS。以下为本 reviewer 实际运行；child 输出在内存中筛选，仅记录固定原因和计数。

| 验证 | 结果 |
| --- | --- |
| `swift scripts/phase95-root-edge-metric.swift --self-test` | exit 0；250 checks；portrait scoring disabled |
| `swift scripts/compare-face-feature-batches.swift --self-test` | exit 0；597 mutations；inventories 5/65/8 |
| SwiftPM filter `PortraitNoseRegistrationTests\|RootMetricCounterexampleTests` | exit 0；6+2=8 tests，0 failures，0 skips |
| 原 source 阶跃上的组合平移/blur 独立探针 | 30 个定位返回，24 个漏真值；5 个宽度返回，3 个漏真值；完整 margin 假通过 0，abstention 0 |
| 六像素 hull 边界 | 可注册 ramp 的两个 anchor 均错误接受 97/16 像素 hull |
| 固定行/identity 补测 | 8 checks，0 failures |
| 非法 ROI 运算 | 前置 guard 接受、后续减法 overflow；未执行 trap |
| provider crossing 端点探针 | 1 个确定性区间漏真值；满足声明的舍入误差条件 |

独立探针把原 prototype 定义部分送入 `swift -O -`，附加的生成与断言只在内存中；没有修改、落盘或替换源码/test/spec。没有运行全套 SwiftPM、no-skip、portrait 或其他 gate。用户提供的 focused 10 和普通全套 913/0/8 是 main 的历史运行，不冒充本次执行；本次只选中了五文件范围内的八个 XCTest。

## 精确审查身份

HEAD / comparator 对照基线：`7d3d336bbc5988ab03805019fe0b6cd037194446`。以下 SHA-256 在阅读及验证前后保持一致；comparator 只审 CR02 guard、对应 self-test diff 和必要调用上下文。

| 文件 | SHA-256 |
| --- | --- |
| `scripts/phase95-root-edge-metric.swift` | `38585eb0124def3f8ebf39fb11a04839259d6533365ec9ec0ee7ce506381ffcd` |
| `95-ROOT-METRIC-SPEC-v2.md` | `39f81db9e7b4bb26addf0f7520006a21a461819c6aaf1ff7ad43eab0659f0fa2` |
| `scripts/compare-face-feature-batches.swift` | `d7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26` |
| `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift` | `c1d7976eb3238d908367829d52221a9f55ed81094025b4b28f248f13d3a5c8e9` |
| `BeautySDK/Tests/BeautyEffectsTests/RootMetricCounterexampleTests.swift` | `77eb746aba43ca72585dcfd2952638ba102633317211a5a8d9f6796aeb5bcdd7` |

前审只读基线：commit `2eb0dee04199f4c3e77f23e159db133db5fd5f0d` 的 `95-ROOT-METRIC-REVIEW.md`；历史版本与当前该文件 SHA-256 均为 `ea95ea2cd4a71fad51461fa761bee6161c01ce6c4033683c8c66c6b2f2cce64d`。

已读 AGENTS、PLANS Active 顶段、DESIGN/SECURITY/RELIABILITY/QUALITY 当前 Phase95 段。使用 gsd-code-review 的限定范围/证据/分级规则和 spike-findings-beauty 的 generated mechanics、先定义验收及隐私边界；未引入技能中的其他特效或真实夹具门槛。Serena 无可调用工具，采用 rg/本地读取。五文件均未被 gitignore 排除，项目无 `.codexignore`。必要生产调用上下文仅用于理解 provider 测试与插值，不作全库/provider 实施认证。

## Freeze disposition 与交回 main

**不批准当前 draft 的 generic prototype freeze，也不进入 source 注册或 portrait score。** main 可在既有授权内按 CR-01/02/03 修复及补有限回归，并修正 WR-01 的测试误差界；不需要重新向用户索取同类修复权限。修订实现/规范/测试身份后再进行限定范围复审，期间原 ROI、threshold、fixture、历史和注册 v1 保持。

即使后续数学 prototype 获准冻结，批准也只覆盖 prototype；live adapter、versioned amendment、source-only 双次注册 commitment、report/reconciliation/classifier/gates 仍须单独审查。不能由本报告代签 Phase95 完成、效果成功或任何外部分发资格。

本 reviewer 的唯一持久交付为本报告；没有修改 production/test/spec/owner/history，没有 commit，没有生成 `95-INDEPENDENT-REPAIR-REVIEW.json` 或任何 passing closeout。已结束全部审查测试，main 可据此恢复修复工作。
