---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-14T02:18:36Z
depth: standard
review_scope: root-metric-diagnosis-and-definition-only
files_reviewed: 6
files_reviewed_list:
  - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
  - BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/RootMetricCounterexampleTests.swift
  - scripts/compare-face-feature-batches.swift
  - scripts/face-feature-batch-manifest.json
  - scripts/run-clean-65-portrait.sh
findings:
  critical: 2
  warning: 1
  info: 0
  total: 3
status: issues_found
metric_defect: confirmed
replacement_readiness: not_ready_for_portrait_scoring
final_phase95_review: false
---

# Phase 95 山根测量定义独立评审

## Narrative Findings (AI reviewer)

结论：确认 `rootWidthContraction` / `darkHalfCentroidSpanQ16` 的测量缺陷。它既可把真实生成结构收缩判成扩张，也可把完全没有结构收缩的亮度变化判为 root 行通过。不能据此推断当前人像几何有效。简单的 gradient-edge span 也不能直接接替：本次另行构造的微小噪声反例可骗过“左右半区绝对梯度重心间距”。

本评审建议后续只推进 **source-anchored edge correspondence 的保守宽度区间方案**。下文给出单位、比较方式、注册与绑定契约，以及进入实现前仍须明确的参数。该方案目前**不具备冻结为人像验收指标的条件**；本报告没有批准新指标给人像打分，也不是最终 Phase 95 completion review。

### CR-01 — BLOCKER：暗度重心不是结构宽度，存在相反方向与完整 root 行假阳性

**File:** `/Users/yakangwang/codes/beauty/scripts/compare-face-feature-batches.swift:766-800,890-912,1037-1050,1074-1098`

**相关契约:** `/Users/yakangwang/codes/beauty/scripts/face-feature-batch-manifest.json:205-217`

**Issue:** `darknessMoment` 把 ROI 内所有非纯白像素按 `255*256-lumaQ8` 计权；`darkHalfCentroidSpanQ16` 计算两个固定半区的暗度重心间距。背景暗度、结构占空比和半区边界均改变重心，结构边界并不是被跟踪的量。`rootWidthContraction` 再取负号，故验收 margin 等于参考 span 减去 candidate span。改变曝光会改变这个比值，甚至翻转方向。

独立验证直接将当前 comparator 顶层命令入口之前的源码送入 Swift 标准输入，只调用其原始数学函数和内存内生成数据；没有调用图片解码、Vision、注册、renderer、报告写入或人像评分入口。另以 JavaScript `BigInt` 独立整数实现复算诊断数值。

| 生成诊断 | 原 comparator 的结果 | 结论 |
| --- | --- | --- |
| 固定低对比度条带，已知宽度 246→204 | span 10312→10480；margin **-168** | 结构缩窄被判为错误方向 |
| 上一对输入同时增加 30 亮度，结构与对比度保持不变 | span 17696→16352；margin **+1344** | 仅共同亮度基线变化就翻转同一几何变换的判定 |
| 另一生成条带保持几何、对比度不动；只在原 manifest 的 root target 内统一调暗 30；source、neutral、三个 sibling 均为原图 | source/neutral/sibling margin 均 **159**；target changed pixels **33620**；outside **0/0**；全部 protection **0/0**；原 `semanticMeasurement.semanticPass == true` | 纯光度代理通过 root 行的全部现有谓词 |

第三项使用未修改的 manifest root 契约、原阈值与原 watermark 排除算法；生成输入为不透明等通道图像。它只证明 root 行可被欺骗，不是 65-case 或人像通过。目标变化量与保护区检查不能补救一个有假阳性的方向指标。

**Fix:** 将旧指标保留为明确的 legacy 定义；新增经独立评审、生成反例验证和预注册冻结的结构对应指标。不得通过翻转符号、调整白点、减背景、乘系数、改 ROI、降低 `>=16`，或按候选输出选择亮/暗极性来修补。亮度平移下重心比值改变，单纯换符号无法同时修复上述两种错误。

### CR-02 — BLOCKER：root 报告行的 metric 身份没有被验证，现有 contractID 也不足以承载公式修订

**File:** `/Users/yakangwang/codes/beauty/scripts/compare-face-feature-batches.swift:1964-1974,2009-2033,3543-3544,3771-3774`

**相关绑定入口:** `/Users/yakangwang/codes/beauty/scripts/run-clean-65-portrait.sh:15-35`

**Issue:** `validateStablePayload` 核对 case inventory、fixtureCount、数值谓词和 verdict，却不核对 `direction.metric == contract.metric`。本次用纯生成 payload 将 `noseRootNarrowing_0p25` 行的 metric 改为 `bridgeDefinitionGain`，保留所有其他字段，直接调用原 `validateStablePayload`，结果仍获接受。这里没有生成或持久化 passing closeout receipt。

此外，当前 `contractID` 选取 `BEAUTY_PHASE95_ROI_DIGEST`。这个值实际是序列化 `SemanticContract` 的摘要，**并非仅矩形摘要**：它包含 metric 名称、sign、threshold、comparison 和 region；但不包含 metric 实现版本、边缘注册算法、预处理或不确定性规则。若保留 `rootWidthContraction` 名称而换公式，并仅更新外层 comparator hash，同一 contractID 下的新旧数值将无法区分。

当前 driver 对原 comparator/manifest 的 SHA-256 检查确实会拒绝未经更新的实现；不能把本问题描述成现有 driver 已允许任意代码替换。缺陷在于行身份校验确实缺失，以及现有链条不能直接承担此次 measurement revision。报告内容摘要能证明字节一致，不能证明它由哪一版数学定义算出。

**Fix:** 补全 case→metric 身份核对，并按下文新增版本化 amendment、measurement identity 和 source-registration identity。新验收路径必须拒绝旧 schema、旧 measurement identity、metric 缺失/错配及仅改 digest 的旧报告。原 registration v1、manifest、历史失败与历史摘要保持原样，不把“更新 comparator hash”当成重新计分授权。

### WR-01 — WARNING：声称验证生成结构收缩的测试仍使用同一缺陷代理

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift:97-139`

**Issue:** `checkRootStructure(bright:)` 在已知生成条带上用 `255-red` 的两半重心差和 `>=16` 判断收缩，而没有独立测量实际结构边缘移动。增加 bright/dark 两种极性并未解除这个循环；CR-01 已证明该类量不是一般的结构宽度。保护像素和 alpha 断言有价值，但不能让方向断言成为独立结构证明。

新增 `RootMetricCounterexampleTests` 正确标注为 diagnostic，不能反过来弥补这里的有效性 oracle。其当前固定样本的数学复制没有发现等价性错误；也不能因为这两条诊断通过就授予 provider acceptance。

**Fix:** 保留旧诊断和历史测试身份。为后继定义增加独立的生成结构真值：由生成器指定可解析边界/几何变换，用实际 output 中的对应边界与定位误差区间核对；加入仅光度、blur、noise、translation 的负例。保护、alpha、extent、确定性检查继续独立存在。需要变更本测试的 acceptance 断言时，使用显式测试修订绑定，不能重用旧测试 receipt。

## 等价性与证据边界

`RootMetricCounterexampleTests.swift:17-29` 在本次固定样本域内与 comparator 数学精确等价：

1. 等通道输入满足 `lumaQ8 = (77+150+29)*v = 256*v`，故 weight 恰为 `256*(255-v)`。
2. 诊断采用相同的半开区间和向下取整 split，包含同样的奇数列分配；横向坐标为 `2*x+1`，分母为 `2*image.width`。
3. 两个 centroid 各自先做正整数除法，再相减；不能改为先减有理数后统一取整。重复相同行会同时乘 numerator/denominator，不改变商；原函数在本次生成尺寸下没有溢出。
4. `rootWidthContraction` 的负号加上 `candidateValue-sourceValue`，恰好得到测试的 `span(before)-span(after)`。共同 +30 的高亮样本没有数值截断；零权重仍按原实现处理，两个半区的总权重均非零。

等价范围是已规范化、等通道、固定生成数据的该原语；不是任意彩色/透明输入、真实 ROI 注册、完整保护与 sibling 验收的等价证明。诊断里的生成 ROI 也不是替换原 manifest 或人像 ROI 的建议。

本次有界执行结果：原 Swift comparator 精确复现两项诊断，独立 `BigInt` 复算一致；原 root 行全谓词的纯光度假阳性、错误 root metric 身份接受，以及简单梯度重心的噪声反例均已复现。没有运行 SwiftPM 全套或 provider 图片测试。曾尝试用独立 Swift stdin 直接启动原 XCTest 文件，但该入口没有正确加载 XCTest Swift 测试运行支持；两次启动均在编译阶段失败，未形成 XCTest 通过计数。这不是对项目 SwiftPM 测试可编译性的判断。

当前人像结果只引用 owner 提供且本次已读的 `PLANS.md` Active Phase95 与 `95-INTERNAL-CONTRACT-REVISION.md`：candidate 10 单例旧指标 **-12，失败**；candidate 6 完整结果 **6/7**，root **-2**，outside/protection 为零。未读取相关图片或原始运行记录，未重新验证这些人像数值。指标缺陷不改变其历史失败身份，也不证明某个新定义下会通过。

## 替代定义评估与当前选择

### 为什么不能直接使用简单 gradient-edge span

对无遮挡、孤立、非截断的理想边缘，梯度位置确实比相对白色的暗度重心更接近结构宽度。在 `I'=a*I+b, a>0` 且没有 clipping/量化歧义时，归一化梯度形状不受共同 offset/gain 影响；左右边缘同量平移也不应改变 span。

但这些性质不足以支持直接替换：

- 半区全部 `abs(gradient)` 的重心仍会被纹理/噪声质量拉动。本次生成条带主边缘不动，仅两个内部亮度 +1 的扰动，使该简单定义报告约 **1674.67 Q16** 收缩。
- `argmax`/最强峰遇到双边缘、阴影、毛发、眼部结构时会换目标；微小增益差或噪声即可改变选中峰。亚像素形变也不能用整数峰位置可靠覆盖 `16 Q16`。
- 固定半区会让平移跨 split 改变成员；动态重分半区或每张输出重新找峰又会发生 correspondence switching。
- blur 可以移动非对称边缘峰、合并边缘或改变阈值交点。对称理想条带的成功测试不能证明一般 blur 不产生假收缩。
- 仅因 source 有一对强边就称其为鼻根壁也不成立；它可能是另一种纹理或光照边界。没有足够结构证据时应 abstain，不能从 provider 的控制点或 candidate 的变化区补出答案。

因此拒绝“全 ROI 梯度重心”“每半区最强峰”“自动挑最有利极性/行/平滑尺度”作为立即冻结的替代方案。

### 选定的后续路线：source-anchored 对应边缘宽度区间

这里的 source-independent 指**算法与参数不按本张 source、fixture 或输出进行校准，且不依赖 provider 的控制点/位移**；并不意味着不使用 source 作为对应关系的锚点。若完全不固定 source correspondence，不能可靠防止输出把另一对结构拿来计分。

建议名称为 `rootStructuralEdgeSpanQ16_v2`，先作为设计草案。其核心计算契约可以确定如下；其 admissibility 仍未达到 implementation-ready，见后文。

1. 维持现有 orientation/sRGB/opaque canonical carrier 与原 target/protected ROI、watermark 规则。边缘计算 stencil 必须完整位于可比较 target 内，不可从保护区借采样。固定全图宽度 `W` 为归一化分母。
2. 仅 source 注册阶段确定边缘 pair、行集合 `Y`、极性、对应模板、搜索窗及定位误差模型。它们是 measurement definition 的显式组成部分；不得伪装成 ROI 未变就无需评审的隐藏子 ROI。source/neutral/candidate/全部 sibling 共用这一套注册，不根据各图重新选“最好”的行或边。
3. 在每个注册行上，输出同一左右结构的位置区间 `[Llo,Lhi]`、`[Rlo,Rhi]`。有效宽度区间为 `[Rlo-Lhi, Rhi-Llo]`。先以有理数/有界定点求和，按冻结的等行权重聚合，最后乘 `65536/(W*|Y|)`；下界向下、上界向上取整，使用 checked arithmetic。禁止按 candidate 梯度幅值重新加权，禁止 ROI-width 归一化或经验放大系数。
4. 对无定位歧义的理想输入，标量是 `floor(65536*mean(R-L)/W)`，收缩分数为其相反数。实际判定用保守区间：`sourceMargin = sourceWidth.lo - candidateWidth.hi`，`neutralMargin = neutralWidth.lo - candidateWidth.hi`；两者分别 `>=16`，最终 margin 取 min。不能用区间中点代替下界。`16` 仍代表全图宽度的 `1/4096`，不是 16 像素。
5. 对每个原有 sibling，取 candidate 与 sibling 的宽度区间距离 `max(0, sibling.lo-candidate.hi, candidate.lo-sibling.hi)`；所有 sibling 的最小距离仍须 `>=16`。保留原绝对 distinctness 语义，不偷换成“candidate 必须比所有 sibling 更窄”。复制 source/neutral/candidate-sibling 必须得零有效差距。
6. target changed pixels、absolute RGB delta、outside、protected 的所有原阈值、比较对象和 conjunction 保持不变；结构区间不产生 protection 豁免。任一 required reference 无结构、对应失配、超搜索窗或不确定性过大，返回 typed `metric_unavailable`/`ambiguous_structure`，不给零宽度、默认成功或删掉该项。

边缘定位可用固定源边缘模板的受限平移匹配，而非全半区梯度重心。匹配应允许正 affine 光度 nuisance；候选需要保留**全部**与已冻结误差模型相容的位置，不只最佳点。若“没有移动＋亮度/对比度变化”仍可解释输出，零位移必须留在可行集合中，保守 margin 就不能获得收缩信用。纯共同平移也不能得到宽度缩小。丢失、合并或翻转的边缘不能触发自动重新注册。

### 为什么当前仍不准冻结为验收指标

上述核心算式尚不足以成为实现规范。至少下列定义缺口必须先在**纯生成数据**上形成数值明确、可复现的方案并独立复核：

- 如何从 source 唯一识别左右同一结构、哪些行可用、最低覆盖率、跨行连贯性与缺失行如何处理。不能在看到人像结果后缩小 `Y`，也不能靠最强峰自动认定解剖语义。
- 梯度/模板 stencil、平滑核、模板与搜索窗宽度、亚像素模型、插值与取整、边界处理、光度增益范围、clipping 条件及唯一性判据。当前没有足以直接冻结这些常数的生成证据。
- 明确 bounded noise 与 blur 的可允许类，以及它们造成的定位误差上界。现有 RGB tolerance `2` 是 changed-pixel 分类容差，**不能直接被当成新的定位误差模型**。低对比度时误差可能已超过 `16 Q16` 对应的位移，正确行为是不可测，不是调宽容差。
- blur-only 必须在零位移 nuisance 中被覆盖，或被可靠地拒绝；只要求“template residual 足够小”可能把亚像素 blur 偏移当成有效收缩。需要对所有相容解释取保守界，而不是增加一个未经证明的 blur 阈值。

仅由图像也无法在所有情况下区分“真实结构被移动”与“精确画出相同输出的局部明暗编辑”。因此只能声明：在预注册结构和经过验证的干扰模型内，检测到可对应图像结构的变窄；不能声称证明解剖形变、自然度或商业视觉质量。这个限制也不能通过读取 provider 位移作为 oracle 来绕过。

这些缺口是**本次设计判断**，不是等待用户重新批准既有授权，也不是技能要求暂停。下一步可在现有授权内完成 generated-only 规范与实现评审；本报告不把一个尚未确定的方案标成 ready。

## 输出评分之前必须完成的冻结顺序

1. **先冻结通用定义。** 在不读取人像或 candidate 输出的条件下，明确上节全部规则、常数、typed failures、舍入和生成测试，记录规范/实现/test digests，进行独立复核。不能将“先看 source 再决定采用哪种指标”称为 source-independent 设计。
2. **再注册同一个授权 source。** 后续获准执行的 source-only 注册入口重算原 v1 ROI 并核对原摘要，按已冻结通用定义生成 source correspondence。该阶段接口不接受 candidate/neutral/sibling 或 output root；source 不可测则结束为不可测，不换 fixture、不调 ROI 或阈值。
3. **冻结 source registration commitment。** 将原 registration v1 文件摘要、相同授权 source digest、规范身份、实际算法身份、规范化环境/版本、行/边对应关系与模板的确定性编码摘要绑定。几何/模板只在内存中参与摘要，持久文件只存 hash、版本、计数和枚举状态。重算不一致必须拒绝，禁止盲用一次不确定的 Vision 结果。source digest 单独已有原始字节身份，但 canonical normalization/environment 仍须明确。
4. **最后才开放评分。** scorer 在读任何待评估输出前验证 amendment 和全部身份；重算 source 注册并核对 commitment；同一注册应用于所有五个 reference/candidate 角色。评分后重检输入和实现身份。已有 candidate 输出如将来获准重新测量，也必须记为新 metric 版本下的独立新事件，原失败原封保留；不能重命名旧 receipt。

本次没有执行第 2–4 步，也没有访问任何人像。原 registration v1 文件 SHA-256 实读为 `ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d`。

## 最小具体绑定改动

以下是后续实现范围建议，本次未编辑这些文件或创建这些绑定：

| 位置 | 必需改动 |
| --- | --- |
| 新的 `95-ROOT-METRIC-AMENDMENT-v2.json` | 引用原 registration v1 的文件摘要及原 source/manifest/contracts 身份；新增 `measurement_schema`、`metric_id`、spec/implementation/test/review digests、source-registration commitment、授权范围及不可重计历史的标记。原 v1 JSON 不覆写。 |
| comparator 的 measurement dispatch | 明确 legacy 与 amended 两条路径；default 继续执行原 enum/公式/manifest 语义。只有通过 amendment admission 的 Phase95 root 使用新定义；其他方向全部继承。不得改全局 expected manifest digest 来顺带放开契约。 |
| report、canonical payload、reconciliation 与 classifier | amended schema 的 `contractID` 改为完整 measurement identity 的域分离摘要；另存原 ROI/contract 身份供核对。root 行必须绑定实际 `metric_id`/version，逐行验证 case、metric、单位、状态。source/neutral/sibling 的未知或缺失测量拒绝；旧 schema 不得默认映射为 v2。 |
| `run-clean-65-portrait.sh:load_registration` | 显式选择并验证 successor amendment 的 hash 链与 current comparator 身份，而不是修改 v1 的 `comparator_sha256`。向测量与 classify 传同一个 measurement identity；缺失 amendment、stale implementation 或 registry drift 均 fail closed。 |

`measurementIdentity` 至少承诺：域/版本、原 v1 registration 摘要、原 manifest 和 ROI-contract 摘要、完整新定义 digest、实际执行 comparator digest、source/canonical registration commitment、原 threshold/sign/comparison 集合以及规范化版本。不能只存自然语言 metric 名或 source hash。承诺的 deterministic encoding、排序和字段缺失行为须在实现规范中写死，避免循环摘要。

新测试必须证明：仅 metric version/implementation/registration 之一变化而 ROI 不变，也会使旧报告失效；旧报告即使重算 payload digest，也不能取得新身份。摘要本身不是授权，应由独立评审绑定的预冻结 amendment 作为 expected identity。下游最终 gate 消费者需要同步传递和核对该身份，但不属于本次六文件之外的全面审查，也不代表其最终 closeout 已被批准。

## 必要的 generated adversarial suite

所有样本必须由源码确定性生成，真值不调用待评测 provider 或新 metric。先检查数值和 typed failure，再检查完整 root conjunction；不能只检查程序 exit 0。

| 类别 | 必须覆盖的输入与判据 |
| --- | --- |
| 原缺陷保留 | 当前两项原语反例、纯光度完整 root 假阳性保持 legacy 诊断；新定义不能将这些 no-warp 光度变化判为收缩。 |
| 几何真值 | bright/dark 两极性、不同宽度/尺寸/非整数 ROI、对称和单侧收缩、扩张、零变化；独立解析几何与最终输出一致。跨 `15/16/17 Q16` 及亚像素舍入边界，避免先舍入制造通过。 |
| 光度 | source 与 candidate 共同/各自 offset 和正 gain；低对比度、接近全白/全黑、饱和/clipping、局部明暗/渐变、RGB 不同但 luma 相同。几何不动不得通过，无法定位应 typed failure。 |
| blur / noise | 多尺度对称及非对称 blur、锐化/halo、量化、正负 bounded noise、脉冲/条纹/相关噪声；包括本次两个 +1 噪点反例。测试假收缩、边缘合并及定位界是否覆盖真值。 |
| translation | 左右共同横移、纵移、跨 split、接近 ROI 边界、逐行不同平移；常宽纯平移得零或不可测。不得因裁切失去边缘而自动缩短宽度。 |
| 结构歧义 | 常量场、仅一个边、重复/等强多峰、弱边被更强假边替换、不同极性、遮挡、边缘进入/离开 stencil、source 无结构但 candidate 新增结构；不得按输出重新找 pair/行或回退 legacy。 |
| 引用作弊 | candidate 复制 source、复制 neutral、逐一复制任意 sibling；neutral 自身改变宽度、sibling 无结构或错配；所有角色共用 source registration，不能省略 source 或 neutral 之一。 |
| 局部性与元数据 | 原 target signal、outside/protected 上下界分别做单单位 mutation；opaque/alpha、extent、orientation/mirror、sRGB 与重复确定性；结构成功也不能掩盖保护失败。 |
| 身份与隐私 | wrong case/metric/version、missing/duplicate fields、stale spec/comparator/source/registration、旧 receipt 换摘要、候选改变已注册行集；分类必须拒绝。日志只输出固定原因与计数，禁止模板/坐标/像素/private locator。 |

## 六个实际审阅文件的 SHA-256

下列身份在源码读取后复核一致；包括工作树未提交内容，不把 HEAD 当成本次审阅对象。`WarpControlPoint.swift` 中的 `HorizontalInwardWarpSafety` 另作被调用函数上下文核对，不扩张六个主要审阅文件清单。

| 文件 | SHA-256 |
| --- | --- |
| `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | `05979c7597965ddd89f2becec31c0db2233dd50a0a6ffe145eb9e2141a3a27cc` |
| `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift` | `aa7ad198e8b675325289a728f4c7f91e82ab3c3ed8f97cfa008d4a2ca5c72966` |
| `BeautySDK/Tests/BeautyEffectsTests/RootMetricCounterexampleTests.swift` | `77eb746aba43ca72585dcfd2952638ba102633317211a5a8d9f6796aeb5bcdd7` |
| `scripts/compare-face-feature-batches.swift` | `6a9b90e7eabfbfa82df65dfe493493d014c87ea1e63c091d1fa7adbb698d1ebe` |
| `scripts/face-feature-batch-manifest.json` | `5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e` |
| `scripts/run-clean-65-portrait.sh` | `b203248e6efc2288b109db705b3181877c1b3b1befb6c8b35ed1fd6dd45009ff` |

上下文已读 `AGENTS.md`、`PLANS.md` Active Phase95、`DESIGN.md`/`SECURITY.md` 当前段落、指定 internal revision 与 registration，另读质量/可靠性当前段落。按 `gsd-code-review` 分类，并采用 `spike-findings-beauty` 关于先定义验收、生成证据不代替人像效果、私有媒体/几何不持久化的边界；没有引入该技能其他特效的夹具或产品门槛。Serena 当前无可调用工具，使用源码和精确函数核对。六文件未被 git ignore；不存在 `.codexignore`。

本次没有证明 `observedRootRows` 存在额外的必然正确性/安全失败；读到了其 eye-box 行分割、target disk containment、逐行 slope admission 与分离条件，但未执行 provider 生成图片回归，不能据此认证 candidate 10 正确。未对其他 SDK 或 Phase95 gate 脚本做整体结论。

交付范围仅此报告：无 production/test/comparator 修改，无 commit，无 ROI/threshold/fixture/history 修改，无新 metric 人像评分，无 `95-INDEPENDENT-REPAIR-REVIEW.json` 或 passing closeout receipt。
