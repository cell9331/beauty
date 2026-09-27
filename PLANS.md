# PLANS.md

> `beauty` 的执行追踪账本。任何 Agent 在改代码或改文档前必须读本文件。
> 本文件记录 Active、Completed、Tech Debt，并要求每次工作留下可追踪状态。

当前生效的图片验收政策见
[`docs/IMAGE_EFFECT_ACCEPTANCE.md`](docs/IMAGE_EFFECT_ACCEPTANCE.md)：有权使用的
生成肖像可完成效果正/负例验收；真人图片不是硬门禁或进度 blocker。下方已完成
计划中有关“必须真人”的句子只记录当时范围与证据，不再约束新工作。

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

### A-2026-09-26-remaining-sdk-effects-and-risks

- Status: active。所有者要求在现有 owner-local SDK 边界内逐项完成本账本剩余效果、配置与条件性风险。每项先固定独立语义、正负例、目标/保护区、元数据、确定性和 typed failure 验收，再修改实现；完成一项即记录对应验证，不以其他项的通过代替。历史回执与归档只读。
- [x] 校正 `.planning/STATE.md` 的现行 FACE-01 描述，保留 v1.23 签名快照的历史含义。未跟踪的 `.gsd/dispatch-isolation-sentinel.json`、`.planning/milestone.lock` 和旧 Phase 96 计划/尝试日志属于工作流材料；当前任务不删除或覆盖。`git diff --check` 通过。
- [x] FUTURE-04：扩充 FACE-01 发丝/耳侧、复杂光照、更多肤色和多样生成肖像的方向与保护区验收；不把有限输入结果写成人口泛化或商业质量。
  - 2026-09-26 完成追加验收：冻结的第二组自然风格生成正负例在不改源身份、ROI 或阈值下通过公开 CPU oracle。正例右侧粗糙度 `5.150→4.206`（至少改善 10%），平滑负例 `3.194→3.194`；正例目标/总变化 `7802/7802`，两图发丝及保护区变化均为 0，neutral、repeat、alpha 通过。按肤色、相反明暗背景、短及持续发丝遮挡补充的内存生成测试覆盖整侧安全退出和未遮挡侧继续处理；CPU 与 Metal 共用遮挡侧控制点筛选。FACE-01 相关聚焦 `23/0/0`，完整 archive-first no-skip 命令返回 0、8 opt-in 全执行、0 skip，SDK-owned 前置检查通过。只授予这些生成输入的 owner-local 效果证据，不推断群体、设备或商业视觉质量。
  - 进行中：新增深/中/浅三组代码生成肤色粗糙正例和平滑负例、左右相反明暗背景及上耳保护、短段深色发丝跨边界保护。发丝例首次复现 90 个受保护行变化像素；竞争边缘阈值由 75% 收紧到 40%，使该行退出且相邻脸颊仍变化。局部测试类 `11/0/0`，公开 facade 方向/镜像/错误恢复 `2/0/0`；原冻结生成肖像公开 CPU oracle 在相同输入与阈值下仍通过（粗糙正例双侧 `6.106/6.731 → 4.000/5.044`，平滑负例 `2.806/2.638 → 2.431/2.331`，保护区 0、neutral/repeat/alpha 通过）。当前树完整 no-skip `977/0/0`、8 opt-in、0 skip；更多自然风格肖像仍待验收。
  - 新自然风格生成正负例在同一虚构成人的深肤色、斜光和发丝条件下，先经源图预检入选（右侧粗糙度 `5.150/3.194`）；修复前公开 CPU 探针失败：正例右侧仍为 `5.150`，左侧暗发丝保护区变化 62 像素。neutral/repeat/alpha 通过，负例未恶化。源身份、ROI 与阈值固定在 `scripts/check-face01-diversity-effect.swift`，图片只保留在忽略的本地输入目录。下一步修复复杂光照方向判断和发丝行回退，不用旧肖像通过替代新失败。
  - 曾试验按邻域色度区分深发丝与脸侧的候选，旧 FACE-01 聚焦测试虽通过 `11/0/0`，新自然风格肖像右侧仍无改善且发丝变化扩大至 507 像素；候选已完全撤回，冻结失败输入和阈值保留。此失败不计为 FUTURE-04 完成。
- [ ] 去脂：保持 provisional 安全边界，固定生成正负例及原尺寸视觉/像素目标，改进 `upperEyelidFullnessReduction` 实际效果。
- [x] FUTURE-05：逐字段定义并实现七项配置的调用语义和可重复测试；为 `maximumInputByteCount` 新增明确的内存编码单帧入口，不虚构文件解码路径。
  - `maximumInputByteCount` 已新增仅接收内存编码单帧图像的公开入口：先按编码字节和图像声明尺寸拒绝超限，再解码、复核实际像素尺寸并交给原静态图路径。已解码 CIImage 与 CVPixelBuffer 入口仍只受像素上限约束；不读取文件。32×32 内存 PNG 的恰好上限、超限、像素超限、畸形输入、恢复、输出像素/extent/alpha/重复性和配置变更聚焦 `12/0/0`。该次完整 archive-first no-skip `979/0/0`、8 opt-in、0 skip。
  - `enablePerformanceLog` 候选契约：开启时仅在成功的公开 `processResult` 的 `metrics` 中附加同步 facade 耗时 `beauty.performance.facadeElapsedMilliseconds`（单调时钟、有限且非负）；延迟 CIImage 像素求值不在测量内。不写系统日志、不保留输入或诊断内容。关闭时不增加此键；同一像素请求前后输出仍相同。编码入口耗时从字节检查起算，已解码静态图和像素缓冲区入口从其各自前置检查起算；失败仍返回原 typed error，无成功结果。先用公开入口测试固定此行为。
  - 上述性能字段已在三类 `processResult` 入口实现：先固定的两项测试因缺失指标出现四条失败断言；实现后聚焦 `2/0/0`、Engine/配置/路由组合 `39/0/0`，含源/输出像素一致、失败恢复。名称在红灯后明确为同步 facade 范围，避免把延迟 CIImage 求值计入。完整 archive-first no-skip `986/0/0`、8 opt-in、0 skip；其余五字段仍未实现。
  - `logLevel` 与 `enableDebugMode` 候选契约：成功的 `processResult` 附带只含固定代码与级别的内存诊断事件，不写系统或持久日志。`.none` 与 `.error` 对成功结果无事件；`.warning` 仅在原 warning 非空时给一项聚合事件；`.info` 再给请求完成事件；`.debug` 且 `enableDebugMode=true` 再给后端执行阶段事件。关闭 debug 时不产生 debug 级事件。失败仍是 typed throw，无成功结果；事件不含输入内容、参数值、像素、支持区或路径。三类公开入口、级别过滤、像素不变、确定性和失败恢复先用测试固定。
  - 这两项已接入 `BeautyResult.diagnostics` 固定枚举与公开三入口。先固定的验收因事件类型不存在按预期编译失败；实现后级别矩阵、warning 聚合、debug 门、事件顺序、重复、CIImage/编码/像素缓冲区输出、typed failure/recovery 与 Sendable 聚焦 `7/0/0`，含 facade/配置组合 `43/0/0`。完整 archive-first no-skip `988/0/0`、8 opt-in、0 skip；剩余 `preferredProcessingSize`、`detectionFrameInterval`、`renderQuality` 三项。
  - `renderQuality` 候选契约：只影响已启用 `skinSmoothing`/`skinSharpen` 时的空间纹理邻域，不改无纹理请求、其他参数或后端选择。`.performance` 用 3×3、`.balanced` 保留当前 5×5、`.quality` 用 7×7 对称归一化权重；同一源图高频脸颊平滑的偏差应按 performance > balanced > quality 排序，平坦/硬边/透明保护区不变，alpha、extent、方向/镜像、重复性和 typed failure 不变。CPU 与 Metal 选择路径必须用同一 request-local 质量值和像素算法；不宣称设备性能或商业视觉质量。先固定生成像素正负例与保护区，再改实现。
  - `renderQuality` 已按上述闭合三模式接入后端请求与同一 CPU 空间纹理实现。预实现公开测试重现模式输出相同的失败；修正 Core Image 基准及硬边保护区 ROI 后，生成 80×80 像素正负例、严格强度排序、neutral/重复/alpha、typed pixel-limit 恢复及可用 Metal 对齐聚焦 `2/0/0`。旧 SDK-only 静态白名单先拦下测试中的现有 `.gpu` 选择器，已按测试内容 SHA-256 精确登记；随后质量单项树完整 archive-first no-skip `990/0/0`、8 opt-in、0 skip。后续 `preferredProcessingSize` 更改另需最终门禁；`detectionFrameInterval` 尚未实现。
  - `preferredProcessingSize` 候选契约：仅限制发生人脸检测时送入 Vision 的 sRGB 栅格最大宽高；保持纵横比、不放大、不改变原始输入的像素上限校验、最终输出尺寸、方向或镜像元数据。值经既有有限正数校验后低于 1 像素时向上夹到 1 像素。没有检测需求或未设置时保留原路径；只用公开配置快照驱动。先固定生成色块的 Vision 输入尺寸、方向/镜像、平移 extent、无放大、无效值回退及配置传递，再改实现。不声称速度收益。
  - `preferredProcessingSize` 已在原图像素入界后接入 Vision sRGB 检测栅格；预实现测试因输入字段不存在按预期编译失败，生成色块 12×8→6×4、平移 extent、方向/镜像、无放大、1×1 夹限、配置传递聚焦 `1/0/0`；Vision 专项 `36/0/3 skipped`（未开启 opt-in）。最终证据见下方当前树完整门禁；较早的 `990/0/0` 门禁仅覆盖质量模式。
  - `detectionFrameInterval` 候选契约：只在新增显式 `frameIndex ≥ 0`、source 为 camera/video 的 CIImage 连续帧入口生效。`frameIndex % interval == 0` 的人脸意图运行正常检测，其余帧不请求检测、不复用旧人脸，受影响的人脸效果安全退出并报固定 `.detectionInterval` 原因；不需要人脸的色彩/纹理请求照常执行。无帧序号的现有静态入口始终逐次检测；interval 非正初始化/解码/变更归一化为 1，不根据 Engine 调用次数隐式推断序列。先固定检测调用数、结果摘要、源图保护/输出尺寸、neutral、方向/镜像、typed 无效序号/来源和恢复，再实现。此行为不声称平滑跨帧视觉质量。
  - `detectionFrameInterval` 已接入显式 frameIndex 静态 CIImage 入口；7 帧 interval=3 的生成渐变像素与注入检测器验证 0/3/6 检测、其余帧无检测且全图与 neutral 一致，固定 skip 摘要、legacy 不受影响、无脸色彩正常执行、错误序号/来源 typed failure 及恢复。首次测试因复用只采样左上 1 像素的旧 helper 误判效果未变，改为完整 96×96 sRGB 像素比较后新测试 `2/0/0`，联合 preferred 聚焦 `3/0/0`；最终完整门禁见下行。
  - 配置综合聚焦测试 `50/0/3 skipped`（普通运行未启用三项 opt-in）；随后当前七字段代码树完整 archive-first no-skip `993/0/0`、8 opt-in、0 skip，全部 SDK-owned 前置检查通过。生成测试与固定枚举诊断不授予设备性能、画质泛化或外部分发声明。
- [x] FUTURE-07：公开 still-image 的可达 16 点双眉及 46 项几何组合实际产生 288 点，超过 Metal 256 点上限。已在 facade 对完整点集做 request-local 容量预检；无行限制点的超限组合一次性走现有 CPU reference backend，保留全部几何及公开固定容量指标，直接 Metal 和行限制点仍 typed failure。公开 CPU/GPU 生成像素完全一致，后续普通 GPU 请求恢复；相关聚焦 `20/0/0`，backend-neutral、Metal feature/runtime、SDK-only 静态门禁及 self-test 通过。完整 archive-first no-skip `1004/0/0`、8 opt-in、0 skip；不宣称所有脸型点数均小于 256 或设备性能。
- [ ] FUTURE-08：纹理滤镜已新增代码生成的冷色低对比非面部负例，旧实现每个控制在保护区改变 132 像素；窄色彩保护后深浅肤色目标仍变化、冷色背景 0 变化，生成纹理 suite `8/0/0`。活跃纹理请求另设 8,388,608 像素上限，编码声明前置、解码/像素缓冲区和 backend request 复核，超限 typed `invalidInput`、随后小图恢复；生成的大尺寸编码 PNG 声明预检及恢复通过，backend/encoded/texture 聚焦 `24/0/0`。完整 archive-first no-skip `1008/0/0`、8 opt-in、0 skip。CPU 静态图纹理步骤拥有的三个 RGBA8 buffer 合计至多 96 MiB，Core Image/系统、Metal 附加 buffer 峰值及设备性能未测。暖色等非面部低对比纹理仍可能变化，需继续引入可信局部语义或更完整负例，故保留未完成。
- [ ] 比例「小头」：定义独立于现有 `faceSmall` 的中性比例语义和像素验收，达到后再调整 taxonomy 的 `partial` 状态。
- [ ] 3D 塑颜：分别定义并实现「对称」「上下」「左右」「倾斜」四项中性整体几何控制。
  - 「倾斜」候选契约：新增 `wholeFaceTilt` 签名字段，零值源图一致；正值在规范图像坐标中局部顺时针，负值逆时针。以脸框中心和四个有界局部锚点构成二维图像平面旋转，不宣称三维头部姿态或深度。先固定顶部与左侧两个不同颜色生成标记的正反移动、远背景/alpha/extent、重复、缺脸退出和 Codable 中性兼容，再接入 resolver、冲突缩放与 CPU/Metal 共享几何。此公开验收在未实现字段时按预期编译失败；更多肖像证据前 taxonomy 至多 `partial`。
  - 「倾斜」当前进度：新字段、解析/冲突缩放、四点有界旋转、renderer 正负案例和当前清单已接入。公开生成标记方向、方向/镜像、neutral、repeat、外部/alpha、无脸和 typed failure/recovery `3/0/0`，provider `21/0/0`，Metal 47 行点预算 `7/0/0`，renderer/去脂集成过滤 `53/0/0`。首次完整门禁发现一个旧 64 字段断言并已更新为 65；最终完整 archive-first no-skip `1001/0/0`、8 opt-in、0 skip，各专项与 SDK-only 边界通过。当前 taxonomy 仅记二维 `partial`，不认定 3D 姿态或广泛肖像效果。
  - 首项「上下」候选契约：公开 `wholeFaceYPosition` 签名强度，零值源图一致；正值在图像坐标中向下、负值向上。使用已选人脸的有界局部像素变形，不宣称深度/三维网格。生成脸部标记正反方向须沿期望方向移动至少 1 像素，图像远背景与 alpha 保持，缺失/无效人脸按现有 face-shape 规则退出；方向镜像、元数据、重复性、组合和 typed failure 按公开 SDK 路径验收。若所有者要求真正三维效果，替换此候选契约，不用二维结果冒充。
  - 进行中：`wholeFaceYPosition` 已接入公开参数、解析、冲突缩放和 face-shape 点，正负两项 renderer case。公开生成标记 `4/0/0`，含参数/Codable、正反方向、四方向×输入镜像、neutral、repeat、extent、远背景/alpha、无脸和 typed failure/recovery；provider `19/0/0`、Metal 几何 `7/0/0` 覆盖有界点及当前 45 行组合；post-archive SDK 边界通过。首次完整 no-skip 发现九项旧 62/75 当前清单断言，已保留 Phase 95 冻结投影并修正当前清单，相关聚焦 `55/0/0`；最终完整 no-skip `977/0/0`、8 opt-in、0 skip，archive-first 及所有专项通过。当前只对这组二维像素授予方向证据，taxonomy 标为 `partial`；更多肖像仍待验收。
  - 「左右」候选契约：`wholeFaceXPosition` 为独立签名强度，零值源图一致；正值在图像坐标中向右、负值向左。仅对已选人脸执行有界二维局部位移，不能称为深度或三维网格。先固定生成标记的正反方向至少 1 像素、远背景/alpha/extent、四方向和输入镜像、neutral/repeat、无脸退出及 typed failure/recovery；参数、Codable、冲突缩放、Metal 点预算和 renderer inventory 均须回归。更多肖像验收前 taxonomy 最多 `partial`。
  - 进行中：新增公开字段、解析/冲突缩放、face-shape 有界水平点与正负 renderer case。实现前公开测试因字段不存在按预期编译失败；实现后新公开像素 `4/0/0`。当前清单的 40 条失败均来自旧 63 字段或 77 renderer case 数量断言，已按 64/79 现行数量修正并保留 Phase 95 的 62 字段冻结投影；参数、renderer、资源、provider 和当前 Metal 点组合聚焦 `137/0/0`，post-archive SDK boundary 通过。首次完整门禁在遗漏的配置测试旧 63 字段断言停止，补正后配置专项 `20/0/0`；最终完整 archive-first no-skip `984/0/0`、8 opt-in、0 skip。taxonomy 保留 `partial`，更多肖像仍待验收。
- [ ] 比例：分别定义并实现「头包脸」「颅顶」「额头」「中庭」「人中」「下庭」「短脸」七项控制。
  - 「短脸」候选契约：独立正向 `faceShortening`，零值逐像素保留；对足够纵长的已选脸框，上额与下巴两个源区沿图像纵轴相向移动，中心参考区和远背景保持，整体可测上下标记距离缩短。以有界二维 Warp 点实现，不能称为头骨缩短或三维形变。先用内存生成标记固定方向/负例/保护区、方向镜像、重复、无脸、alpha/extent 与 typed failure，再接参数解析、冲突缩放和 CPU/Metal 同源点；更广肖像证据前 taxonomy 至多 `partial`。
  - 「短脸」已接入独立公开字段、有效强度上限 `0.30`、脸框纵横比保护、两点相向局部变形及 CPU/Metal 共享点源。生成公开像素、参数/Codable、方向镜像、neutral/repeat、中心/远背景/alpha/extent、无脸与 typed failure/recovery `3/0/0`，当前参数/资源/renderer/provider/Metal 清单聚焦 `90/0/0`。完整 archive-first no-skip `1012/0/0`、8 opt-in、0 skip；taxonomy 仅升至二维 `partial`，仍需自然肖像覆盖。
  - 「额头」「中庭」候选契约：独立签名 `foreheadHeight` 与 `midfaceLength`，零值源图一致；前者正值将脸框上部中央局部区域上移，负值下移，后者正值将眉眼与鼻部之间的中段局部区域下移，负值上移。仅在已选有效脸框与 contour 内发出各自有界二维控制点，不声称头骨结构或三维比例。先用三色内存生成图锁定两处标记的正反方向、互不串扰的保护标记、远背景/alpha/extent、方向镜像、重复、缺脸、Codable 与 typed failure，然后接入 resolver、冲突缩放、CPU/Metal 共享点和当前清单。更广肖像验收前 taxonomy 至多 `partial`。
  - 「额头」「中庭」已接入独立公开签名字段、`±0.30` 有效上限和共享 CPU/Metal 点源。预实现公开测试按预期因字段缺失失败，接入后两处标记的正反方向、互相保护、远背景/alpha/extent、四方向×镜像、neutral/repeat、缺脸、Codable 与 typed failure/recovery `4/0/0`。当前清单/renderer/provider/Metal 聚焦组合 152 项仅有一条旧 66 字段断言失败，修正后去脂集成 `5/0/0`，SDK-only post-archive 边界通过；完整 archive-first no-skip `1017/0/0`、8 opt-in、0 skip。taxonomy 仅记二维 `partial`，尚无自然肖像泛化证据。
- [ ] 脸型：分别定义并实现「去双下巴」「去双下巴 Pro」「发际线」三项局部效果，先确认合用的 request-local 语义支撑与资源授权。
- [ ] 每项效果经公开输入/输出像素与元数据验收后更新 taxonomy、产品/设计/安全/可靠性 owner；最终运行 archive-first 完整 no-skip SwiftPM 门禁。

## 4. Completed

### C-2026-09-26-future06-skin-texture

- Status: completed；不改公开字段、cap、preset、75-case inventory 或历史回执，将 `skinSmoothing` 与 `skinSharpen` 的饱和度/对比度代理改为共享的有界空间纹理操作。CPU still-image/pixel-buffer 与 Metal 选择路径均在现有色彩/几何处理前运行同一 CPU-owned、源图驱动的 5×5 亮度细节步骤；强边、非不透明 footprint 和边框保持源图，不新增 shader、模型或皮肤分割。
- 先于实现固定 `64×64` 纹理/软边正例、平坦/硬边/半透明负例、目标与保护区：平滑中心偏差低于源图 65%，锐化中间梯度大于源图 120%，RGB 单通道变化不超过 16。旧代理在首次 4 项公开测试全部失败（纹理偏差仍 10、软边梯度仅 25、保护区/平坦受影响）；一条测试把合法半像素平移误判为非法输入，已在实现前改为现有的 typed 像素上限契约。随后固定生成肖像脸颊、发眼唇保护区、方向/镜像、Display P3 及 CPU/Metal 容差；均只使用测试内生成像素。
- 最终公开生成图测试 `6/0/0`，Metal color `7/0/0`，新增 buffer/still parity 对两个控制及组合色彩在可用 Metal 主机通过 `max RGB ≤2`、`mean <0.75`，含 neutral、repeat、extent、alpha、sRGB/P3 与 typed failure/recovery。旧代理方向断言已改为对应的平坦负例或从全局色彩矩阵移除。完整 `bash scripts/run-no-skip-swiftpm.sh` 返回 0：archive-first 与 SDK-owned 专项通过，8 项 opt-in 全执行、0 skip；`git diff --check` 通过。首次沙箱运行因 SwiftPM 用户模块缓存不可写停在 backend-neutral 子脚本；正常缓存权限下又由两个专项脚本的旧 `smoothing` 静态标记拦截，更新标记并分别复测后完整门禁通过。这些前置停止都不是效果断言失败。
- 同步 `ARCHITECTURE.md`、`DESIGN.md`、`PRODUCT_SENSE.md`、`RELIABILITY.md`、`SECURITY.md`、`QUALITY_SCORE.md` 和 taxonomy。只授予这些生成输入的 owner-local 纹理方向信用，不推断真人/人口、设备性能或商业视觉质量。

### C-2026-09-26-face-contour-edge-robustness

- Status: completed；承接 FUTURE-04 后续覆盖，用内存生成的深色背景、低对比、短局部遮挡和交替明暗输入验证脸侧预处理。不改公开参数、已冻结的自然风格肖像 oracle 或历史证据。
- 预先固定深色背景粗糙正例双侧各改善至少 10%；低对比输入粗糙度不得增加超过 10%、重复一致；16 行双外缘遮挡行源图一致、未遮挡下脸侧仍有变化；同侧明暗方向冲突须源图一致。三者及适用的安全例均检查中心/远背景和 alpha。测量用双侧 72 行、10 行间隔二阶差分，按红通道源图中点判别边缘；生成像素只在测试中存在。
- 初次 7 项中深色正例没有改善，深色/低对比保护区有 139/85 个变化像素；遮挡通过。另固定的方向冲突例先复现 339 个变化像素。生产代码现接受一致的双向明暗边界，弱边缘或方向冲突整侧退出，短遮挡行局部跳过，且排除不同方向邻行参与平滑。新增 4 项连同先前 4 项 `8/0/0`；旧 FACE-01 过滤 `8/0/0`，含公开 facade、方向镜像、错误恢复和 CPU/Metal 测试。
- 最终源码重渲染原自然风格生成正负例及重复输出，冻结 oracle 再次通过，正例左右 `6.106/6.731 → 4.000/5.050`、负例 `2.806/2.638 → 2.431/2.356`、保护区 0，全部聚合值与上一修复相同。完整 `bash scripts/run-no-skip-swiftpm.sh` 返回 0，archive-first 与 SDK-owned 专项通过，8 项 opt-in 全执行、0 skip；`git diff --check` 通过。更新设计、产品、可靠性、安全、质量和 taxonomy 说明；整理提交时将 taxonomy 的 v1.23 FACE-01 段落明确标为历史快照，不改历史回执。未宣称复杂发丝、更多肤色、人口泛化或设备/商业资格。

### C-2026-09-26-face-contour-generated-portrait-repair

- Status: completed；保持 2026-09-25 生成正负例、源身份、测量区域与效果阈值不变，修复 FACE-01 在公开 CPU 路径上脸侧边界几乎不动的问题。冻结 oracle SHA-256 `dbe66d760f9b5969b24b516739d86aa0dac25029457cf93ad4572e3298a3d6fe`。
- Vision 观测轮廓与源图边界在正例双侧 200 行平均绝对差约 12.16/5.36 像素、最大约 38.31/25.02；旧强边缘仅搜索中心附近四对像素。新预处理在下脸侧有界搜索源外缘、按行平滑并限制位移；耳/太阳穴排除在宽修正外，双外缘歧义整侧退出，透明采样保持不动。一次旧夹具回归发现宽搜索误判跨中心纹理，收紧为同侧、相距至少 8 像素的竞争外缘；不改公开参数、冻结门槛或 `Warp.metal`。
- 最终源码的公开 CPU neutral/candidate/repeat 在两张冻结生成肖像上通过原效果 oracle：正例左右粗糙度 `6.106/6.731 → 4.000/5.050`，负例 `2.806/2.638 → 2.431/2.356`；正负例目标/总变化像素 `15821/15821`、`9069/9069`，保护区 `0/0`，neutral、重复、alpha、有界性均通过。原尺寸检查未见明显耳侧破损；只对这些生成输入与固定 ROI 授予 owner-local 效果信用，不推断人口泛化或商业视觉质量。
- 新增内存生成的粗糙正例、平滑负例、竞争边缘和透明行 4 项回归 `4/0/0`；保留旧 FACE-01 方向、保护、alpha、确定性、方向镜像、CPU/Metal 和错误恢复 8 项测试 `8/0/0`。完整 `bash scripts/run-no-skip-swiftpm.sh` 返回 0，archive-first 边界及全部专项检查通过，8 项 opt-in 全执行、0 skip；`git diff --check` 通过。生成图留在本地忽略输入目录，持久文本仅存聚合量。根据当前生成图片验收政策，taxonomy `面部流畅` 提升为 `implemented`；历史 v1.23/2026-09-25 失败证据不改。

### C-2026-09-25-face-contour-generated-portrait-effect-probe

- Status: completed（效果验收失败，FUTURE-04 继续开放）。在看候选输出前生成并目视筛选同一虚构成人的自然风格粗糙脸侧正例/平滑负例，固定两张本地忽略输入的 SHA-256、`1254×1254`、双侧 `y=700..<900` 的源图边缘估计与 20 行间隔二阶差分、源图入选门槛、目标/保护区、正例至少 10% 改善及负例至多 10% 恶化门槛。`scripts/check-face01-generated-effect.swift` 的验收逻辑在首个效果输出前冻结；图片不写入版本库或持久证据。
- 源图入选通过：正例左/右粗糙度 `6.106/6.731`，负例 `2.806/2.638` 像素。公开 CPU `BeautyExampleRenderer` 分别运行 neutral、FACE-01 与重复 FACE-01；neutral 源图一致、重复一致、alpha 一致。效果输出正例 `6.106/6.838`，没有达到双侧 `≤0.90×源值`；负例 `2.837/2.700`，满足不超过 `1.10×源值`。正例目标变化 `10315/11142` 总变化像素、负例 `8820/10037`，均低于预定的 95% 目标覆盖；中心与远背景保护区均为 0。固定 oracle 正确返回 fail，不授予效果信用。
- 源边缘诊断（输出后，仅解释失败，不修改 oracle）：正例 200 行中左/右分别仅 20/33 行的测得边界移动，且每行主要只移动 1 像素；负例反而为 51/57 行。当前控制点来自 Vision 观测轮廓、水平位移上限仅面宽 `0.004`，亚像素强边缘搜索只查看观测中心附近四对像素。推断当前支撑/边界对齐与本例实际脸侧起伏不匹配；尚未证明具体哪一级造成全部失败。未改生产算法或旧阈值，taxonomy 维持 `partial`。
- 验证：源图入选脚本 pass；公开 CPU 三次渲染各 2/2 成功；固定效果脚本 fail 且输出聚合诊断；SDK-only post-archive boundary 与 `git diff --check` 通过。首次渲染被会话沙箱中的 macOS 图像/Vision 服务限制为 `render_failed`，获得正常本地服务权限后的三次重跑均成功；它不是本次效果失败的产品原因。因效果首关未通过，未运行本次完整 no-skip，也未签发/推广效果；历史 `951/0/0` 与此前聚焦测试不充当本次效果证明。下一步应先设计源边界到 Vision 支撑的局部对齐及安全门，再用同一冻结输入/阈值回归；若更改验收契约，须另立独立理由与新输入，不能基于本次输出调低门槛。

### C-2026-09-25-face-contour-stylized-public-oracle

- Status: completed（仅扩充公开路径的代码生成边界证据，FUTURE-04 效果信用仍开放）。在查看候选输出前，固定 `1000×1000` named-sRGB opaque 的折线脸侧正例与直线脸侧负例、左右 `y=0.40...0.68` 强边缘二阶差分粗糙度、中央与远背景保护区、正例源值 `>0.5` 且候选 `<源值/2`、负例 `≤源值+0.05` 的门槛。通过测试专用检测支撑走公开 `BeautyEngine.processResult`；未修改生产算法。
- 正例边缘粗糙度约 `0.651→0.173` 像素，目标发生变化，neutral/source 一致、重复输出一致，中央/背景及目标外 RGB 不变，alpha、extent、现行 legacy CI DeviceRGB 输出契约和脱敏诊断通过。平滑负例源粗糙度 `<0.1`，候选源图完全一致；原有 malformed-support/recovery 与方向镜像测试继续覆盖 typed recovery。输入是人工绘制的简化脸形，视觉检查仍呈卡通折线轮廓，亚像素指标下降不足以证明自然肖像视觉上“面部流畅”；taxonomy 保留 `partial`。
- 新测试独立放在 `GeneratedContourPublicOracleTests`，历史 `FaceContourSmooth` 过滤仍为原 8 项，避免改动 v1.23 冻结 runner 的计数/回执。聚焦新测试 `2/0/0`，原 8 项与新 2 项合跑 `10/0/0`；其中原冻结生成夹具单项约 9.5 分钟。SDK-only post-archive boundary 与 `git diff --check` 通过。未运行 archive-first 完整 no-skip；生成图仅在测试内构造，未写入仓库证据。

### C-2026-09-25-metal-combination-budget-reproduction

- Status: completed（条件性风险已缩小，未复现公开组合超限）。43 个当前 GPU 可用几何公开控件（排除既有 raster cutoff 明确要求 CPU 的 `noseRootNarrowing`）同向启用时，现有完整生成面部支撑产生 115 点、单控件点数和为 119；普通完整观测支撑产生 102 点、单控件点数和为 102。双向参数正负取值均在 256 点内，几何 pass 保留全部点。
- 新增组合回归，除预算外还在可用 Metal 上检查公开参数组合经后端输出非原图、重复输出一致和 alpha 保持；保留合成 257 点的 typed rejection 测试。因这两种支撑均未触达上限，没有改动生产几何算法或 Metal API。
- 验证：`BeautyMetalGeometryPassTests` 7/0/0；SDK-owned `check-metal-feature-passes.sh` 在正常 SwiftPM 缓存权限下通过，Metal available、37/0/0、0 skip；`git diff --check` 通过。首次专项门禁在会话沙箱内因 SwiftPM manifest/module cache 子进程权限中止，未计为产品测试失败。未运行完整 no-skip 门禁，当前结果不扩展到未枚举的观测支撑或真实设备表现。

### C-2026-09-25-audit-checklist-reconciliation

- Status: completed；逐项核对旧审计清单与当前源码。2026-09-24 的审计修复已覆盖静态图高光/阴影、EXIF 非法值、像素硬上限、非整数 extent 前置拒绝、Metal 超 256 点显式失败、过期 Phase 96 脚本和 taxonomy 状态。
- 本次补正遗漏的 `maximumInputByteCount` 声明：当前公开 SDK 仅接收已解码图像或像素缓冲区，此字段不限制编码文件大小；源码注释及设计、产品、安全、可靠性文档明确预留语义，编码文件读取方须在解码前自行限流。
- 剩余效果与风险仍按 FUTURE-04/05/06/07、`upperEyelidFullnessReduction` provisional 状态和 taxonomy 的 partial/future 行记录，不把回归测试通过解释为真人像、设备或商业视觉质量签发。
- 验证：聚焦 SwiftPM 五个测试类 `32/0/0`（含当前 Metal 可用路径），另跑 Engine 与静态图皮肤/色调两个测试类 `25/0/0`；过期 Phase 96 脚本调用返回 `phase96_superseded` / exit 2；`git diff --check` 通过。本次改动仅为源码注释和文档，未重跑完整 no-skip 门禁；此前 `951/0/0` 为 2026-09-24 已记录的独立结果。

### C-2026-09-24-generated-fixture-gate

- Status: completed；现行 Vision 人像和牙齿/眼白完整门禁可选择受控的生成输入，不再把默认真人夹具当作唯一合格来源。
- [x] 检查所有现行固定人像路径和门禁夹具变量；Vision/facade/renderer 测试改用同一 `BEAUTYSDK_VISION_PORTRAIT_FIXTURE` 文件名，默认仍为原 `p1.jpg`；根目录发现不再依赖该文件存在。
- [x] Vision 单文件拒绝路径片段和符号链接；证据包使用 `PHASE59_TEETH_BUNDLE` / `PHASE62_SCLERA_BUNDLE` 可覆盖的忽略目录，保留原测试的权利、掩码、像素与安全断言。同步当前验收、示例图、产品、安全、可靠性及质量文档，历史回执未改。
- [x] 验证：wrapper mutation self-test `11/11`、renderer 回归 `24/0/0`；临时替代文件名下 Vision/facade/renderer 聚焦 `5/0/0`；路径穿越输入被通用缺失夹具错误拒绝；完整 archive-first no-skip 门禁通过、8 opt-in、0 skip；`bash -n`、`git diff --check` 通过。替代文件名验证只证明路径可替换，不把原有图片的别名冒充生成图效果验收。

### C-2026-09-24-generated-portrait-acceptance

- Status: completed；所有者明确要求生成肖像可用于完整效果验收，真人图片不再是硬门禁或进度 blocker。
- 新建 [`docs/IMAGE_EFFECT_ACCEPTANCE.md`](docs/IMAGE_EFFECT_ACCEPTANCE.md) 作为统一政策；同步 `AGENTS.md`、根级 owner、taxonomy、当前 GSD project/requirements/roadmap/state 与 v1.23/v1.24 当前说明、示例图与授权说明、blueprint 入口和项目级 local-retouch skill。历史签发回执、归档和已完成阶段证据保持原貌。
- 生成正/负例仍须源图先行目标/保护区、效果方向、负例与不恶化、真实输出像素/元数据、确定性和错误恢复；原 v1.23 两图回执因未测试这些效果谓词继续保持有界机械结论，不能仅凭换政策追认。
- 验证：当前规范性用语扫描、14 个关键政策文档的存在与引用检查、`git diff --check` 通过。纯文档/skill 文本修改，未运行 SwiftPM；此前代码修复的 `951/0/0` 门禁仍是独立历史验证，不冒充本次验证。

### C-2026-09-24-audit-repair

- Status: completed；用户将 `fix all` 限定为本次审计的代码、测试、文档和脚本问题，14 项 future 功能及真人像效果另立范围。
- 修复 still-image 高光/阴影空操作、EXIF 非法枚举回落、像素上限与后端硬限不一致、无效尺寸晚拒绝、Metal 组合点数超限静默跳过；配置未执行字段与 skin 色彩代理改为真实声明，更新 taxonomy 的 v1.23 状态。
- 过期 Phase 96 本地续跑脚本在任何写入或批处理前返回 `phase96_superseded` / exit 2；更新三个专项门禁的旧静态断言与测试数。
- 验证：archive-first no-skip 完整门禁 `951/0/0`、8 opt-in、0 skip；最终加强的 parity 测试再由 13 项专项门禁确认；`bash -n`、过期脚本 fail-closed 检查、`git diff --check` 通过。详见 `QUALITY_SCORE.md`。
- 未纳入本轮：FUTURE-04 真人像效果、FUTURE-05 保留配置字段行为、FUTURE-06 真实空间纹理算法及 taxonomy 其余 future 项。

### C-2026-09-24-v1.24-upper-eyelid-effect-improvement

- Status: completed（有界生成输入机制改进）；[冻结目标、源码身份与聚合证据](.planning/V1.24-UPPER-EYELID-CURRENT.md)。全强度旧夹具比值 `0.1068` 接近地板，改以半强度旧比值 `0.4537424`，固定目标 `≤0.35` 且多改善至少 10 个百分点；新比值 `0.3422654`，改善 `0.1114770`。
- [x] Phase 97：冻结旧实现 commit/editor hash；固定目标测试在旧实现上失败。复审指出统一变暗反例缺口，补半强度非均匀修正、公开保护像素与双眼独立性 oracle。
- [x] Phase 98：只将 `BeautyExperimentalUpperEyelidReliefEditor` 内部 gain `1.5 → 1.8`，公开参数、双 still-image 入口、62/5/75 兼容及 fail-closed 边界不变；聚焦编辑器/公开测试 `12/0/0`。
- [x] Phase 99：初次 `945/0/0` 是复审补测前的中间门禁；最终源码重跑 archive-first no-skip 完整 SDK 门禁，归档、SDK-only、后端/Metal、consumer、CPU-reference、8 项 opt-in 均通过，非零 SwiftPM 测试、0 失败、0 skip。二次[独立只读复审](.planning/V1.24-INDEPENDENT-REVIEW.md)无剩余 Swift 问题；`git diff --check` 通过。
- 边界：只签发生成输入像素机制改进，不能宣称真实人像视觉有效或商业质量；去脂仍为效果偏弱的 provisional owner-local API。`faceContourSmooth` 真实人像效果继续留在 FUTURE-04；历史 Phase 96 草稿与签发回执未改。

### C-2026-09-24-face-contour-synthetic-mechanics

- Status: completed（2026-09-24，`synthetic-mechanics-only`）；所有者接受两张生成图作为有界机制验收输入。v1.22 原快照和映射修复追加式验收各自保留，不回写历史 Phase90/95 回执。
- [x] 核对现行 taxonomy、FUTURE-04、Phase89 manifest、portrait comparator、SwiftPM 冻结测试及当前 provider：数值契约一致，但逐行整数像素重心的二阶差分大量计入几何直线段的栅格阶梯；五个仅按轮廓曲率构造的候选均未通过。
- [x] 独立生成输入的亚像素机制改善原冻结指标并守住目标与保护区；探索值和正式 SwiftPM 验收已分开记录，见 [v1.23 当前契约与证据](.planning/V1.23-FACE01-CURRENT.md)。
- [x] 在现有 SDK/后端内接入双侧外轮廓的有界候选，保留原 `+16 Q16` 八项阈值；生成 SwiftPM、公开 facade 像素/恢复、CPU/Metal still-image 对比、尺寸/alpha 通过。稀疏轮廓使 44 字段合并测试漏掉 FACE-01，已修正并通过该 17 项测试类。
- [x] 补充独立生成剪影边界测试，不复用条纹重心指标：已知轮廓就近取整的粗糙正例平均边缘二阶差分约 `0.709 → 0.172`，平直轮廓负例保持原图，重复输出和中央/背景保护通过。原候选对内收取整边缘从约 `0.706` 恶化到 `1.213`，因此新增只在单一强边缘可辨时使用源像素边界的有界对齐；当前正例两种取整方式都降至源粗糙度一半以下，原冻结八谓词不变且 8 项 FACE-01 聚焦测试通过。仍不能替代真人像效果验收，详情见 [v1.23 当前契约与证据](.planning/V1.23-FACE01-CURRENT.md)。
- 原始效果目标延期：在真实人像预注册的轮廓与图像边界上确认像素对齐不会使粗糙度恶化；生成两种对齐方式已通过，但没有粗糙真人像正例，不能签发效果信用。
- [x] 识别真实人像验收契约问题：历史 comparator 未给 FACE-01 登记人像 ROI，65/65 双次输出中其他七方向仍通过，FACE-01 的 5,647 个变化像素被旧固定区全部误计在中央；源图先行的临时 ROI 探针将它们归入脸侧目标且区外为 0，但连续性与 sibling 均为 `0 Q16`，未达到原门槛。该诊断批次早于后续仅影响稀疏轮廓的修正，不是最终源码身份的签发回执；临时探针已移除，历史比较器/回执不改。
- 原始效果目标延期：用权利明确且确有粗糙脸侧轮廓的正例和平滑负例，预注册源图目标与保护区，验证真实边缘/纹理的可见改善及方向；在此之前 taxonomy 维持 `partial`，不以生成夹具或像素信号代替效果信用。
- [x] 最终源码重跑 archive-first no-skip 完整门禁：源边缘对齐修复后 SwiftPM `944/0/0`，8 项 opt-in 全执行、0 skip，归档、SDK-only、后端/Metal/consumer/CPU-reference 各门禁通过；`git diff --check` 通过。已同步 `DESIGN.md`、`ARCHITECTURE.md`、`PRODUCT_SENSE.md`、`SECURITY.md`、`RELIABILITY.md`、`QUALITY_SCORE.md`、taxonomy、v1.23 当前契约和本账本；未满足的真人像效果边界仍明确保留。
- [x] 最终源码另运行一次隔离输出的 65 案例机械诊断，但该直接 runner 未加载 Phase95 源注册环境，聚合 `semantic_fail` 不可与此前已注册的七方向通过批次对比，也不用于签发；FACE-01 旧固定 ROI 下仍为 `5,647/126,841` 像素/RGB 变化。该次生成输出与临时报告已清理。
- [x] 2026-09-24 使用 Phase95 源注册环境、隔离临时输出重跑当前树 65 案例双轮诊断：七个既有方向均 `semantic_pass`，FACE-01 仍因旧固定 ROI 的目标信号、方向、保护区、区外及 sibling 检查为 `semantic_fail`；该批次只作诊断，临时图像与报告已清理。当前树 archive-first no-skip 全门禁再次通过，8 项 opt-in、0 skip；此门禁不授予缺失的真人像效果信用。
- [x] 为机制探针生成两张虚构肖像，放在忽略的本地输入目录；CPU 公共 renderer 的 FACE-01 与 neutral 均能输出，候选对两张都有像素变化。生成器没有可靠地造出可测的粗糙真人像正例，故这些图不能进入权利批准的实际人像正负证据，也不能用变化像素数替代边缘改善。
- 原始效果目标延期：取得权利明确的真实粗糙脸侧正例和平滑负例，在输出前完成源图轮廓/边缘及目标和保护区登记；同一最终代码身份上运行方向、不恶化、确定性及完整 SDK 验收，并经独立复审后签发单独的真人像效果回执。当前本地正式输入只有一张原有肖像，缺少正负成对授权记录；所有者已将本次验收限定为生成输入机制。不得凭生成图或本轮诊断将 taxonomy 从 `partial` 提升。

- [x] 所有者指定的两张虚构生成图在最终源码身份 `ec2589298925422dc6c3dfc65a68285caea4b6bdd913dffb3c0821673c6d3319` 下完成公开 CPU neutral/candidate/repeat 像素检查；8 项 FACE-01 聚焦测试通过，注册 65 案例双轮保留七个既有方向，FACE-01 旧 ROI 判定按失败记录，archive-first SwiftPM `944/0/0`、8 opt-in、零 skip。独立复审无未解决问题；[追加式 COMPLETE](.planning/qualifications/v1.23-synthetic/attempt-20260924T045750Z-9429627d/COMPLETE.json) 签发并只读 verify 通过。此回执仅为合成机制，不授予真实人像效果信用；taxonomy 维持 `partial`。

### C-2026-09-23-face-contour-roughness-localization

- Status: completed（2026-09-23）；对未改动的 FACE-01 生成源夹具做只读分区统计，见 [方法、聚合量与边界](.planning/FACE-CONTOUR-ROUGHNESS-LOCALIZATION-2026-09-23.md)。Swift `Float`/整数列复现源连续性 `-51 Q16`；总粗糙度55508，脸侧41217、下巴过渡14291；脸侧点间窗口38547，占脸侧93.5%，采样点邻域2670。
- 原门槛 `+16` 要求粗糙度至少减少16773；只消除过渡段至多得到 `+13`。该指标在几何直线段上也主要计入像素列阶梯，故继续仅按采样点曲率选择目标缺少依据；这不是证明原门槛不可能或生产算法正确。已核对 Phase89 manifest、portrait comparator、SwiftPM 冻结测试、taxonomy 与 FUTURE-04：现行数值门槛一致，仍缺少指标与“面部流畅”视觉意图的一致性证明；旧冻结测试、历史回执及 `partial` 状态不变。
- 本步骤没有生产代码或测试改动，也没有运行实际 SDK 输出/人像；只读临时脚本未落盘，输出仅为聚合数字。验证：源指标复现 `-51 Q16` 的断言通过；`git diff --check` 通过；映射修复追加式回执 `verify` 仍返回 `phase_complete=true`。

### C-2026-09-23-face-contour-absolute-curvature-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；用七点/侧 contour 的绝对相邻斜率变化构造凸目标，并沿固定保序行映射做生成机械首关。[方法和聚合结果](.planning/FACE-CONTOUR-ABSOLUTE-CURVATURE-FEASIBILITY-2026-09-23.md)。
- 首次 ADMM 20000轮未收敛且未输出候选；未见效果输出前改用五自由变量的穷举顶点法求同一目标，每侧32个可行顶点。原图连续性-51，候选-53，改善-2低于+16；目标15985/4015479，全部保护区0/0且重复一致。该候选停止，不能从几何绝对曲率优化推断像素连续性通过。
- 生产源码、冻结测试及旧回执未改；临时实验脚本删除。下一步是只读定位原夹具的语义粗糙度来源，不开始 v1.23 效果实现或签发。

### C-2026-09-23-face-contour-curvature-target-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；用 contour 行位置的平方二阶差分最小化构造唯一目标曲线，再以左右侧分段保序逆映射生成一次机械结果。[方法和聚合结果](.planning/FACE-CONTOUR-CURVATURE-TARGET-FEASIBILITY-2026-09-23.md)。
- 首次预注册坐标下降在2000轮内未收敛且无图像输出；未看候选结果前改用同一凸目标的加速投影求解，15584轮达到 `<=1e-9` 残差。原图/候选连续性均 `-51 Q16`，改善0低于+16；目标 `15049/2974476`，所有保护区0/0、重复一致。平方曲率目标不等于冻结绝对曲率指标，不得据此调整输出门槛或声称效果通过。
- 生产 Swift、冻结测试和历史证据未改；仓库外临时脚本删除。当前未启动 v1.23、未运行 sibling/实际SDK/人像/完整 no-skip，因为首关失败。

### C-2026-09-23-face-contour-monotone-map-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；第三个预注册生成机械候选保留前次七点/侧支撑与二次曲线，仅以保持顺序的分段行逆映射替代三角权重位移场。[方法和聚合结果](.planning/FACE-CONTOUR-MONOTONE-MAP-FEASIBILITY-2026-09-23.md)。
- 原图连续性 `-51 Q16`，候选 `-53 Q16`，改善 `-2 Q16 < +16`；目标 `17506/5767164`，outside/central/background/watermark 全部 `0/0`，重复一致。局部性安全不能替代语义效果；该二次拟合目标和分段映射组合停止，不改源码或原测试。
- 仓库外临时脚本已删除；需先找到有独立依据的轮廓连续性目标，才值得做下一个固定候选。当前无 FACE-01 效果通过信用、v1.23 正式里程碑或新 SDK 验收声明。

### C-2026-09-23-face-contour-lateral-fit-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；继续 FACE-01 可行性研究，先按 contour 自身的左右外侧连续链排除中央下巴弧，再用一个预注册二次拟合窄带映射做仓库外生成探针。[方法与聚合结果](.planning/FACE-CONTOUR-LATERAL-FIT-FEASIBILITY-2026-09-23.md)。没有修改生产 Swift、冻结测试或历史回执。
- 初次 scratch 执行误将下巴弧也从源夹具剔除，source continuity 为 -38 而非原 -51，判为无效；修正输入生成后，同一映射参数和门槛下得到 source -51、candidate -44、改善 `+7 Q16 < +16`。目标 `15419/5168211` 达下限，outside/central/background/watermark 均 `0/0`，重复一致。首关因语义强度不足停止；没有 sibling、SDK、真实人像或完成信用。
- 临时探针删除，当前无 v1.23 正式里程碑；要继续需提出与这两个失败窄带构造不同且预先固定的新机制，不能从保护区通过推导效果通过。
- 验证：修正夹具输入后的临时脚本退出0并仅输出聚合量，已删除；`git diff --check` 通过，`python3 scripts/check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266` 仍为 `phase_complete=true`。未运行完整 SwiftPM 或真实65人像，因为机械首关未达到原语义门槛且 SDK 源码未改。

### C-2026-09-23-face-contour-strip-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；所有者要求继续 FACE-01 的受控可行性验证。预先固定的单个双侧窄带映射在仓库外临时 Swift 生成夹具中执行一次；没有修改 SDK 生产代码、冻结测试或历史回执。[完整聚合记录](.planning/FACE-CONTOUR-STRIP-FEASIBILITY-2026-09-23.md)。
- 结果：连续性 `+6 Q16 < +16`；目标 `15581/4654212` 达信号下限，但 outside `1684/428172` 与 central `1583/385749` 均超原保护上限；背景/水印为0/0，重复一致。预设的“窄带均在目标 ROI 内”推论遗漏了下巴端点，已在记录中更正。该候选停用，不按输出调参或冒充原 SwiftPM 冻结 oracle 通过。
- 后续问题只限于先确定排除中央下巴弧的轮廓侧支撑所有权，再提出独立的新候选；尚无 v1.23 里程碑或 FACE-01 效果通过信用。
- 验证：临时原型退出0并仅输出聚合量，执行后已删除；`git diff --check` 通过，`python3 scripts/check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266` 仍为 `phase_complete=true`。未运行完整 SwiftPM 或真实65人像，因为首关已失败且 SDK 源码未改。

### C-2026-09-23-face-contour-smooth-feasibility-assessment

- Status: completed（2026-09-23）；按所有者要求评估 `faceContourSmooth` 的下一步，不启动新里程碑或修改生产代码。结论与证据见 [FACE-CONTOUR-SMOOTH-ASSESSMENT-2026-09-23.md](.planning/FACE-CONTOUR-SMOOTH-ASSESSMENT-2026-09-23.md)。
- 当前 provider 和生成测试表明字段可调用、失效时 fail-closed，但八组冻结语义/保护谓词仍未满足；Phase 90 的既有点场尝试未同时达到连续性与局部性。建议先界定不同于旧圆形点场的双侧窄带映射可行性，并以原冻结生成验收为 go/no-go；未证明可行前不写生产修复或声称 FACE-01 完成。
- 验证：`swift test --package-path BeautySDK --filter FaceContourSmoothRepairTests` 3/0/0；其中输出测试明确要求仍为 deferred，不能把通过计作效果通过。原 v1.22 与映射修复追加式验收回执保持不变。

### C-2026-09-23-v1-22-mapping-followup-qualification

- Status: completed（2026-09-23）；所有者授权为映射修复后的当前代码新增追加式验收。新契约、执行工具、生成测试及全部回执在 [.planning/qualifications/v1.22-mapping-followup/](.planning/qualifications/v1.22-mapping-followup/)；历史 Phase95 文件未覆盖或移动。
- 当前身份 `0debce887ab95a49a4970f78dbb53f3500aca75d67861e4d493f011a176204af`。独立实现/安全审查与不同审查者的目标复核均为0未解决发现；当前真实65/65输出、双次一致、七有效一延期，山根31对及五组 [260,373] Q16，目标10774像素/RGB217300，outside与全部保护区变化0。安全1/0/0、兼容4/0/0；完整archive-first SwiftPM 938/0/0、8项 opt-in、零skip。
- 生成回执测试2/2、自测8项拒绝控制、临时目录实际预检75/65/8通过；`python3 scripts/check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266` 通过。[新 COMPLETE](.planning/qualifications/v1.22-mapping-followup/attempt-20260923T083240Z-16509266/COMPLETE.json) SHA256 `0fc220c8863f7063bd32b27034191f7d48d8b4b6ea3f90c9759c18647230a7c2`；旧 COMPLETE 保持 `33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4`，旧 portrait/BINDING/CHECKS 哈希逐一不变。
- 完成声明仅为当前代码在同一范围内的所有者本地 SDK 验收；不补发 `faceContourSmooth` 效果信用，也不产生设备、商业视觉质量、发布或外部分发资格。旧 `verify-complete` 仍按原一次性快照返回 `review_missing_or_stale`，不是新回执失败。

### C-2026-09-23-v1-22-post-closeout-document-audit

- Status: completed（2026-09-23）；在继续 Phase95 重签前核对当前状态文档、一次性签发代码和旧回执，见 [后续文档与工具核对](.planning/V1.22-POST-CLOSEOUT-DOC-AUDIT-2026-09-23.md)。
- 结论：原 v1.22 完成对签发时快照有效，`verify-complete` 对改动后代码返回 `review_missing_or_stale`；两者可以并存，不自动重开已完成里程碑。现有 `full-closeout` 拒绝已有 CHECKS/BINDING，分类器写原 portrait 路径，`finalize` 排他发布，不能在保留旧证据时直接重签。此前“先重跑旧 Phase95 再选下一里程碑”的建议不成立。
- 后续核对将 `.planning/V1.22-CURRENT.md` 中原验收段落明确标为历史快照，并把旧 `verify-complete` 的适用范围和当前追加式只读复核入口写清；不改动任何签发回执。
- 下一步入口核对发现 `.planning/PROJECT.md` 的旧“Current State”仍停在 Phase 91；已在其前写明 v1.22 完成及当前代码追加式验收，并将旧段落标为历史进度记录。当前无新里程碑或 active plan。
- 仅修正行政状态、质量口径和本账本；未修改旧 Phase95 契约、回执、source/test 或私有图像。验证：只读脚本/回执检查、当前与旧规范身份对照、`verify-complete` 失败原因、`git diff --check`；未运行新 SwiftPM 或人像批次，因为本次无生产代码改动且旧收尾入口不可追加签发。

### C-2026-09-23-multiface-audit-remediation

- Status: completed（2026-09-23）；用户要求先辨别文档与实现，再修复复审问题。原始代码及 Phase04 测试确认 `maximumFaceCount` 是检测选入上限，公开效果只消费主脸；TD-023 为文档过度承诺，已修 `DESIGN.md`、`PRODUCT_SENSE.md`，未新增多脸渲染。
- TD-024 为真实代码问题：`VisionFaceDetector` 现在逐脸隔离映射失败，保留独立有效脸并以 `.partial`/`.mappingFailed` 和汇总计数报告；新增双人脸顺序及 geometry/combined-purpose 确定性测试，原全部失败仍源安全。
- 验证：`swift test --package-path BeautySDK --disable-sandbox --filter VisionFaceDetectorTests` 35项、0失败（常规3项 opt-in 跳过）；完整 `bash scripts/run-no-skip-swiftpm.sh` 938/0/0、8项 opt-in、零skip，archive-first、SDK-only、backend/Metal/parity及consumer全部通过；`git diff --check` 通过。
- 身份边界：旧 Phase95 COMPLETE 为其原规范快照有效；变更后 `verify-complete` 返回 `review_missing_or_stale`。本次修复的自动化门禁通过，但没有重新签发独立审核/真实65绑定的完成回执；各当前 owner 已同步这一点。历史归档及未跟踪 Phase96 草案保持不变。

### C-2026-09-23-historical-milestone-code-reaudit

- Status: completed（2026-09-23）；对 v1.0–v1.22 历史里程碑账本、v1.22 当前回执与现行多脸检测/渲染调用链进行复核，记录于 [历史里程碑代码复审](.planning/HISTORICAL-MILESTONE-REAUDIT-2026-09-23.md)。
- 结论：当前 v1.22 `verify-complete` 有效且完整 archive-first no-skip gate 本次通过；v1.18 独立复审仍有 EVID-01/02 partial 与 QUAL-01/02 unsatisfied、v1.19 已取消、v1.22 的 FACE-01 已明确延期，均不能被“所有原始目标完成”概括。
- 当时记录 TD-023/TD-024 两项多脸问题；后续复核将 TD-023 纠正为文档过度承诺、TD-024 定位为源码缺陷并修复（见上方完成记录）。本次原审计未修改生产代码或历史归档，也未将静态路径证明冒充新增人像效果验收。
- 本次门禁最初在受限执行环境内因 SwiftPM 编译器模块缓存写入被拒而停下；使用获准的文件系统权限重跑同一命令通过，8项 opt-in、零skip。

### C-2026-09-23-v1-22-root-repair-and-sdk-closeout

- Status: completed（2026-09-23）；7/7 阶段、33/33 计划、11/11 当前需求。FACE-01 按已批准范围延期到 FUTURE-04。
- 根因修复：内侧鼻背 source 定位、root/bridge 像素行保护、默认 Vision named-sRGB CGImage 与原 ROI 检测入口一致；保留 source/ROI/阈值和公开字段。文档已移除错误的外基底边界认证和人工确认前置要求。
- 真实验收：65/65 输出两次一致，七个有效方向与一项明确延期；山根固定31对、五组区间 [260, 373] Q16，目标 10774 像素/RGB217300，outside 与 bridge/tip/background/watermark 全部0。
- 同身份门禁：安全1/0/0、兼容4/0/0；archive-first、SDK-only 和完整 SwiftPM 937/0/0，全部8项 opt-in 各一次。首次因 Metal 专项旧计数34停止，修正为实际35后重新执行最终完整门禁；未改效果门槛。
- 独立实现/安全审核与不同作者的目标审核通过；`finalize` 和 `verify-complete` 已验证有效 [95-COMPLETE.json](.planning/phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json)。规范身份 `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`。
- 默认 CPU 支持修复后的 observed root；显式 Metal 对不能表示的新保护边界 typed invalidInput 并可恢复。62字段、5预设、75 renderer cases及后端选择策略保留，不宣称该新效果CPU/GPU等价。
- 完成范围为所有者本地 SDK 验证；无需用户标注或真机操作。归档和历史失败记录保留，不涉及设备表现或外部分发结论。
- 当前入口：[v1.22完成记录](.planning/V1.22-CURRENT.md)。行政同步后再次 verify-complete；后续规范代码/契约变更须对应重新验证。

#### 历史执行记录：以下为原 A-2026-09-11 计划的各次状态，已由上方完成记录收尾

#### 生产根因修复（2026-09-23，最新）

- Metal计数修正后archive-first完整预检已937/0/0、8opt-in且规范快照一致。下一次正式closeout在portrait prepare偶发失败；独立复现定位到新增执行器取消自测的就绪消息观察竞态（25次中3次），实际取消与后代清理25/25正确、0残留。现只修该自测的同步，保留真实SIGTERM、原deadline/退出检查；之后须刷新当前实现与测量身份审查、重跑完整closeout和独立goal，不能用预检或首次65代替最终COMPLETE。
- 真实完整65已双次核对通过，七有效一批准延期；山根五组区间仍[260,373] Q16且全部outside/protection为0。首次full-closeout在随后的Metal专项旧计数34处停止：新增拒绝/恢复用例后实际测试35，全部用例通过但计数器未同步。现将固定计数改为35，保持精确计数、零失败/零skip，先执行完整no-skip预检再由独立review刷新当前身份；未签发CHECKS或COMPLETE。
- candidate12原图双次完全一致并通过全部山根谓词：31对保留，五组区间均为[260,373] Q16；目标10774像素/RGB217300，outside、bridge、tip、background、watermark全部0。见95-ROOT-SURFACE-PORTRAIT-CANDIDATE12.json；这是真实独立山根验证，尚非完整65或里程碑完成。
- 默认Vision已统一named-sRGB CGImage入口，原metadata orientation/mapper/渲染输出契约保留；调用方尺寸与raster必须一致，分配遵守配置预算。Vision34/0/0（包含既有授权opt-ins）通过，独立原ROI与生产首个bridge行一致。
- 真实65新接入已合入，生成Swift612/Python11 normal/-O通过；独立审查发现并正在修复childgroup收尾，另消费方已补original contract digest强绑定，19生成证据测试通过。下一步为最终实现review/测量准入、实际65与完整no-skip，不再重复旧外边界诊断。

- candidate11原图双次一致：31对保留，24对确认正收缩；source/neutral/三siblings区间均为[239,351] Q16，宽度条件通过。bridge38/RGB752、outside38/RGB752仍超保护限值，整体未通过；见不可覆写的95-ROOT-SURFACE-PORTRAIT-CANDIDATE11.json。
- source-only边界对照发现SDK cutoff比原注册bridge首行低5行：SDK直接CIImage Vision，comparator先named-sRGB CGImage Vision。两种输入产生不同检测，不是Float/PPM舍入误差。正在统一默认Vision检测raster，保留orientation/mapper/renderer，禁止按本图加减5像素或修改阈值。
- generated实际SDK校准6/6、432/432、72移动点全部包含，0不可用；41初始定向测试通过。新增非空128/.99分界反例和Metal明确拒绝/恢复，联合8/0/0通过。Metal uniform不支持私有cutoff，已显式typed invalidInput；修复observed root要求CPU。

- 新测量对原图两次结果一致：31对全部比较区间[-51,65] Q16，0对具有确认正收缩；outside109/RGB1895，bridge100/RGB1631。见95-ROOT-SURFACE-PORTRAIT-CANDIDATE10.json，保留失败事实。
- 定位根因：原source/target源点由eye clearance外边反推，生成脸各支撑最内缘仍在.05198..11118faceW，公开内背.03336..04949faceW落入中央空白。
- 已修paired-eye root定位：sourceSpan=min(.04faceW,.35observedContourWidth)，clearance仅限制半径；添加私有exclusiveMaximumY，CPU按pixel row保护root/bridge分界，不靠相对尺寸留白猜半像素。
- 新增独立内背材质像素测试；原宽外侧条带保留为不应误领收缩信用的负例。正在聚焦回归、当前身份采样校准及原图后继验证，尚无新效果通过。

#### 根因修复执行（2026-09-22）

- 所有者要求本次彻底修复并查阅公开最佳实践；此前“仅审核、暂停实现”已由此继续指令结束。
- 公开原始研究及独立复核确认：山根顶部与外侧基底是不同宽度对象。NOSE-02没有要求物理骨宽或外基底必须移动；此前将最外边界认证作为硬门禁是文档解释过度。
- 新操作定义见95-ROOT-SURFACE-MARKER-DEFINITION.md：source固定双侧背部表面带，实际RGB二维对应，所有注册对等权并完整参与，原source/ROI/16Q16/siblings/保护条件不变。
- 已实现原型和隔离pipe，14项生成测量测试normal/-O通过；独立复核另48项光度反例0假通过。修复了纯曝光坡面被LK误认为收窄的漏洞，保留零运动竞争解释。
- 普通LK与局部仿射ECC未通过真实SDK非线性校准，已停止用于验收。后继采用实际RGB全候选区间与单调forward传播；不使用经验误差底线，siblings必须另有实际采样资格或完整ROI identity证明。
- 精确水平方法12测试、worker6测试normal/-O通过，聚合协议11反例检查通过。最终实际SDK生成校准6/6、432/432点及60移动点真值全部包含、0不可用，前后规范身份一致；见95-ROOT-SURFACE-CALIBRATION-OBSERVATION.json。
- 原图source-only已得到31对/31唯一固定表面标记，未读取效果输出；此前双侧可见边界不可用不再是当前对象注册阻塞。正在独立审查后的原图候选效果验证。
- 尚无新portrait通过或里程碑COMPLETE；929/0/0为此前快照，不代表新增脚本已完成全量验收。
- 当前无用户标注/真机/额外操作待办。下述早期设计和诊断按时间保留，不能覆盖本节最新对象定义。


#### 文档路线审核（2026-09-22，当前优先）

- 用户要求先核对文档，暂停新算法/原图试验；[审核报告](.planning/V1.22-DOCUMENT-AUDIT.md)确认6项文档/执行对齐问题。
- 收回“跨行模型是下一必做路线”的表述：它仅为未验证候选；固定16行权重也非产品硬要求。
- 当前真正缺口是宽度语义与完整测量接入。v3行数/实现名单写死、producer仍v2，必须在选定方法后一起版本化；不靠重复现有诊断推进。
- 当前已完成18包runtime/12生成检查/两次source诊断/929全量回归，后文安装失败等均是历史记录。
- 本轮只审核及修正行政说明；未改代码、冻结测量规范或验收阈值，不新增通过信用。

#### 审核后最小设计（2026-09-22）

- 已完成[最小测量修订设计](.planning/V1.22-MEASUREMENT-DESIGN.md)：明确宽度变化的量、原阈值/比较、可复用组件假设和六环节同步接入。
- 新确认：除v3准入外，correlated-change聚合函数也写死12..16行；水平RGB对应不能无条件覆盖所有sibling。后继不能仅改文档/报告版本号。
- 当前尚无证据选定合格的自然图像宽度标记，因此没有开始跨行模型或新原图试跑。下一问题限于该语义依据，不是补下载、覆盖计数或全量测试。
- 设计没有授予注册/效果通过；代码和历史凭证保持不变。本轮仅做设计及文档一致性验证。

#### 当前执行状态（2026-09-22）

- Status: active；95-03人像准入blocked，95-04工具准备可继续；里程碑未完成。
- 唯一当前执行细则：[v1.22当前口径](.planning/V1.22-CURRENT.md)。
- Phase89–94保留历史完成；Phase96草案并入95-03，不等待95完成再修复。
- 最新完整人像为旧指标candidate6的6/7，非当前工作树证明；山根旧指标缺陷已确认，
  新方法仍缺有效source注册和人像评分。914/0/0是历史独立回归，非当前closeout。
- 已有内部契约修订、测量修复及提前评审授权继续有效；见执行细则的范围表述。
- 下一步：山根需可靠双侧可见结构或有依据的宽度标记注册及后继comparator/driver接入，再独立review、完整验收和finalize；不能用旧指标继续调参。
- v3工具已实现finalize/verify-complete与规范快照；PLANS/QUALITY正常记账不再令验收失效，规范/代码变化仍需重新验证。
- 本轮修复：证据数值语义、精确测试身份与执行顺序、原子签发；安全恢复新增实际像素变化正控制；山根新增固定行集保守结构聚合。
- 验证：证据16项与结构9项通过；日志15类/review6类拒绝及子进程3项通过；实际安全/兼容SwiftPM共5/0/0，SDK-only boundary通过。
- 16行原生山根实验失败并撤除，不计通过；其后独立全量no-skip已925/0/0（见下），仍无新原图注册、完整人像评分或COMPLETE。
- 详细实现及限制：95-CLOSEOUT-CONTRACT-v3.md、95-ROOT-COHORT-INTEGRATION.md；独立工具复审单独记录，不替代算法准入。
- 独立工具复审v3：0 blocker/0 warning；核验Darwin/dotted身份，12个正控制接受、32个名称后缀反例拒绝。报告为95-CLOSEOUT-V3-CODE-REVIEW-v3.md，不是实际准入review凭证。
- 修复后真实分lane解析：safety1/0/0、compatibility4/0/0；finalize与full-closeout均在root_measurement_not_admitted拒绝，未启动人像或生成完成文件。41份既存JSON/JSONL证据字节保持不变。

#### 继续完成请求后的推进（2026-09-22）

- 最新：18/18依赖全部取得、官方hash/CRC通过，独立核验2587安装payload；
  新隔离runtime离线安装完成。禁网CPU生成烟测实际12/0无误检、输入不变，
  见95-ROOT-MESH-RUNTIME-OBSERVATION.json；不代表正脸或肖像效果通过。
- 新可见结构注册原型7测试normal/-O通过，修复独立审查发现的异极性外候选
  配对被删问题；保留曲面背景/强内纹理/遮挡/真收缩/固定外形反例。
  原图适用性诊断已实现、Swift compile-only及5协议测试normal/-O通过，
  最终独立审查0未解决问题；已执行原source双观察，未准入测量。

- 原图双观察已完成：mesh先验15/16行，局部可见双侧6/16行、539候选对，
  10行不可用，两次统计一致。见95-ROOT-MESH-SOURCE-OBSERVATION.json。
  当前局部模型不足以接入12..16行测量，也未证明候选宽度语义；不调整旧门槛
  或将诊断结果包装成通过。独立审查修复运行目录/pyc闭包和半像素映射问题。

- 最新完整SDK回归929/0/0、8opt-in各精确一次，archive-first与SDK-only门禁通过；
  执行前后规范快照一致，见95-CURRENT-REGRESSION-OBSERVATION.json。
  这是当前工作树回归观察，未替代缺失的山根/65输出验收或CLOSEOUT-CHECKS。
- 本轮收敛结论：不可由6/16推断只是噪声过大，不继续按该图调局部拟合阈值。
  当时建议的备选是跨行双侧结构模型，现已降为未验证候选，非必做路线；
  若采用，需论证缺失行区间和聚合权重；先用独立生成真值验证连续内纹理、弯曲背景、遮挡和错误先验。
  跨行连续性本身仍不是山根语义证明。实际采样对应的1-byte误差不随结构拟合放宽；
  逐个核对siblings采样模型适用性，noseTipLift不能未经区域证明就视作水平采样。
  该后继尚未实现，不能记作已完成。没有所有者标注/操作待办。

- 新独立范围复核见95-ROOT-MINIMUM-ACCEPTANCE-REVIEW.md：逐张照片的certified
  worst-case detector error不是NOSE-02硬门禁；模型适用性与条件化误差必须有证据，
  但不要求绝对真值证书。当前口径已明确纠正，原阈值/ROI/完整比较/保护条件不变。

- 剩余实际工作按4块追踪：山根自动测量可靠性 → 新测量接入/65输出验收 →
  同身份安全兼容及完整回归 → 独立最终验收/签发。详见当前口径“剩余工作盘点”；
  6/7阶段、29/33计划是历史计数，不能当作剩余工时百分比。
- 依赖恢复续进：系统TLS uv仍限时失败；官方JSON路径成功取得absl-py2.3.1，
  135811字节/官方SHA匹配、CRC与Apache-2.0元数据通过。随后pip dry-run成功解析
  18包，版本/哈希已记录95-ROOT-MESH-DEPENDENCY-RESOLUTION.json，生成临时hash lock；
  当前解析阻塞已解除，剩余依赖文件获取、许可核查、隔离安装与CPU验证，尚未安装或推理。

- 最新进展：限时续传已取得完整官方wheel（19386286字节，官方SHA256匹配）、
  模型包（3758596字节，4成员CRC通过）及完整7页模型卡。见
  95-ROOT-MESH-ACQUISITION.md；下述下载失败是此前尝试，不再表示主资产缺失。
  模型包468顶点按float32逐点/索引匹配固定OBJ、898三角形集合匹配；
  固定版本源码明确从478输出截取前468点；95-ROOT-MESH-INDEX-REVIEW.md独立
  复核通过，另确认完整有向三角形顺序一致。依赖安装、运行验证和山根语义
  /实例误差仍未准入；未安装、未推理、未读私图。
  新依赖锁解析在官方PyPI absl-py接口超时（exit2），无有效lock；下次复用已校验主资产。

- 新方向是隔离的MediaPipe dense-mesh公开资产研究，见95-ROOT-MESH-FEASIBILITY.md；
  不改SDK依赖、不读私图。固定版本公开canonical OBJ完整、468点/898面，
  两组候选内/外链具备真实邻边、严格同侧、镜像与Y单调性；6测试normal/-O通过。
  这仅是公共模板先验，不是原图山根身份或检测误差保证。
- 运行环境获取未完成：官方wheel连续下载截断/网络错误，模型卡PDF不完整，
  隔离uv解析未完成后已终止所属进程；offline核验mediapipe不在缓存。只创建了
  临时venv，未安装模型/依赖、未执行推理。没有向外发送任何私图或派生数据。
  下一步需先取得完整且可校验的runtime/model，再做无网络生成输入及独立review，
  不把下载成功或公开模板拓扑误当人像准入。当前不是等待所有者标注。

- 独立公开资产审查已完成（95-ROOT-MESH-FEASIBILITY-REVIEW.md），0个未解决实现问题；另验证43项输入拒绝、6项资产拒绝和2项边界正控制。语义缺口仍包括路径身份、候选完备性、468/478索引映射及实例定位误差；下载恢复本身不能解除山根验收阻塞。

- 已完成拓扑之后的同侧支撑诊断，见95-ROOT-CONTOUR-SIDES-SPEC.md。
  所有边统一要求两个端点严格在对应半区，跨/触及中线片段不供应侧壁；同点标签
  冲突不能挑有利边，与last-to-first索引无关。34生成检查通过，独立review无问题，
  另30交点冲突检查通过，37协议/8审查稳定性反例拒绝。
- 审查后原图双运行一致：closed，paired3，side_supported0，cap_dependent3，
  unsupported13，见95-ROOT-CONTOUR-SIDES-OBSERVATION.json。这3行虽有几何交点，
  都不满足此独立侧支撑充分条件；不能凭正确闭合就宣称山根侧宽可测。
- 既有Vision轮廓在这套通用规则下无法直接构成山根宽度cohort；停止对此路线
  重复同图诊断，不调低行数、不改ROI或放宽侧支撑规则以获得通过。下一实质缺口
  是新的、独立验证的自动山根侧结构识别能力；不是优化区间运算或继续索取所有者
  标注。原生产实现、效果阈值、public面与历史失败均保持，v1.22仍未完成。

- 新核对发现既有轮廓诊断没有读取Vision的pointsClassification，固定按openPath
  解释。SDK声明closedPath时缺少首尾边可能低估支撑；仅按系统声明连接不能
  与任意闭合开放曲线混为一谈。新增独立topology successor，保留原代码和观察，
  只对closedPath加入last-to-first；open保持，disconnected/unknown拒绝。
  23个生成检查通过；独立review无未解决问题，25协议与8审查/稳定性反例拒绝。
  经自动权限审查，在已确认可用的Vision环境实际双运行一致：nose_topology=closed，
  paired_rows=3、ambiguous_rows=0、unsupported_rows=13。见95-ROOT-CONTOUR-TOPOLOGY-OBSERVATION.json。
  原open0是该约定下的低估，不是完整闭合轮廓无支撑。3对交点尚未证明山根语义
  或测量准入；随后同侧支撑检查全部未准入（见上），不能直接把12降成3。

- 新增同一source标记的相关不确定性传播，见95-ROOT-CORRELATED-CHANGE.md。
  旧绝对宽度区间分别扩张再相减会丢失共享位置关系，可能保守地误报不可测；
  新方法直接界定f_reference(s)-f_candidate(s)，保留完整source区间和所有cell，
  再求双侧宽度变化。固定全图Q16/16阈值与原source/neutral/3siblings不变。
- 新12项Python测试normal/-O通过；实际canonical像素新增正/负2项SwiftPM通过2/0/0，
  两侧固定±0.5px不确定范围，不选择有利位置。完整相关测试组在PYTHONOPTIMIZE=1
  下通过9/0/0。SDK-only boundary通过，未运行新的原图诊断。独立报告95-ROOT-CORRELATED-CHANGE-REVIEW.md
  无未解决问题；额外720位置区间、720宽度区间与200汇总oracle核验通过，
  4审查文件及3依赖hash一致。此项不替代自动source结构注册。
- 系统Vision默认已经是revision3/76点，已通过不读图片的API查询确认；
  因此“改用76点”不是一个尚未尝试的实际扩展，不重复读取原图。

- 新增既有Vision鼻轮廓支撑诊断：只使用相邻实际折线与原16行/ROI，
  不补闭合边、不外推、不读取效果图；10个生成检查实际通过。独立审查绑定15文件，
  19协议反例与7审查/稳定性反例拒绝，无未解决问题。
- 首次沙箱调用失败，未生成源图观察；纯生成Vision对照在沙箱中code9、沙箱外成功，
  定位为执行环境限制。独立execution addendum允许环境修复后的单次双运行，
  自动权限审查通过后实际完成：两次结果一致，paired_rows=0、ambiguous_rows=0、
  unsupported_rows=16，见95-ROOT-CONTOUR-SUPPORT-OBSERVATION.json。
  首次失败保留，不算图像不可测；后两次不含效果图读取或评分。
- 此结果进一步说明既有nose折线不能直接供应当前定义的双侧横截面；
  既有3/16垂直覆盖不是双侧支撑。几何可行性诊断不证明照片没有山根，也不允许
  自动扩大ROI、闭合/外推轮廓或改成任意内部点。仍无所有者标注待办。

- 最新指令：所有者无需标注或执行步骤，继续自动路线。人工边界确认不是默认
  完成依赖，也不再作为待用户处理项；当前由代理完善自动二维可见结构测量。
- 已诊断的有限后继方案见95-ROOT-AUTOMATIC-MODEL.md：外侧仿射背景及集合值折点，
  保留无结构null解释；实际canonical水平采样使用精确RGB可行区间，移除该路径
  未执行的任意gain/offset/blur自由度。原效果阈值、原图、ROI、siblings不变。
- 已执行：采样器6项测试正常/优化通过，含505个解析亚像素真值；新原生正/负
  边界测试2/0/0，完整Phase95RootImageFormationTests随后7/0/0；源模型6项测试正常/优化通过，含72种斜率/极性/相位/过渡宽度
  强正例。物理support跨度修正曾让弱边界负例不可测，现明确允许该负例安全弃权，
  不允许内部强纹理接管；强正例仍必须返回包含独立真值的边界区间。
- 后继模型独立审查通过，23个输入文件哈希绑定、无未解决问题；随后实际执行
  两次源图诊断且结果一致。全部16行完成扫描，null_rows=0、paired_candidate_rows=0，
  返回metric_unavailable / affine_visible_coverage。见95-ROOT-AUTOMATIC-MODEL-OBSERVATION.json。
  分段仿射模型不适用于该原图；不能解释成全图无结构，也不授予效果失败或通过。
- 独立语义复核确认：NOSE-02不要求绝对解剖外边界，已有forward评审明确允许
  有依据且定义宽度的可见标记。已修正文档过度规定，详见95-ROOT-SEMANTIC-CLARIFICATION.md。
  保留固定外部形态/内部纹理运动等反例；不能把任意ROI内点作为宽度。
- 下一实现优先核对既有detector真实鼻部结构；不把3/16垂直覆盖视为双侧注册，
  不外推未观测行。新识别器仅做过可行性研究，未安装模型或改变SDK依赖。
  当前仍缺通过独立验证的source注册，语义澄清本身不授予人像通过。
- 所有者再次要求继续完成v1.22；按该指令推进必要的测量实现，不再把泛化的
  “是否允许继续开发”当blocker。人工确认事实、效果通过、延期与阈值变更不能代填。
- 独立全量回归实际通过925/0/0，8项opt-in精确一次，archive-first顺序由严格
  parser核验；记录95-RESUMED-REGRESSION-2026-09-22.json。运行未捕获执行前后
  规范snapshot，故这是实际回归观察，不伪装成v3绑定或完整收尾凭证。
- 山根聚合新增全候选解释conjunction：任何固定外边界解释、缺失对应或复制
  sibling阻止通过。14测试正常/优化均通过，独立review无blocker/warning；
  它不证明候选集合完备或解剖身份。
- 新source-visible候选原型保留所有符合固定plateau规则的轨迹，不按最大梯度
  选择；8生成测试通过，包含低于噪声的外边界不能从图片识别的明确反例。
  原型仅诊断，不能签发山根准入；具体见95-ROOT-SOURCE-CANDIDATES-SPEC.md。
- 独立诊断review无未解决问题。限定许可下实际执行两次原图诊断，结果一致：
  metric_unavailable / visible_coverage，未形成满足覆盖要求的边界行集合。
  95-ROOT-SOURCE-CANDIDATES-OBSERVATION.json中的candidate_rows=0表示未返回
  合格集合，不是对单行潜在过渡数量的统计。未读取效果图或签发测量准入。
- 此结果只说明有限plateau模型未覆盖当前source，不证明所有自动方法不可能，
  也不证明效果失败。剩余缺口是可信的source-visible双侧结构对应，非继续开发许可。
  按最新指令继续自动方案，不安排所有者标注；更广自动方案仍须独立真值验证。
- NOSE-02与最终CLOSE-01仍未完成；不生成COMPLETE、不自动延期山根、不修改
  原图、ROI或16Q16效果门槛。41份既存JSON/JSONL证据保持不变。

#### 历史执行检查点（截至2026-09-15，非并列待办）

以下“current/latest/next/awaiting”均指各条记录当时状态。已被后续授权或实现
取代的限制不再触发重复审批；原始失败和证据含义保留。

- Source-anatomy coverage checkpoint (2026-09-15): independently approved
  source-only diagnostic actually ran twice on the original source/contracts;
  complete records agree. Of16 frozen row bins, crest vertical extent covers11
  and nose-contour extent covers3. These are necessary coverage counts, NOT
  bilateral boundary labels or anatomical qualification. Unextrapolated current
  contour observations cannot support the frozen minimum12 registered rows.
  No successful source registration or new portrait score. Do not reduce12 to3,
  invent root sides, select favorable edges or retune effect strength. Owner
  input requested: source-only local anatomical boundary confirmation, or an
  explicit extension into a separately validated automatic boundary recognizer.
  See95-ROOT-ANATOMY-COVERAGE-OBSERVATION.json; full portrait still6/7, incomplete.

- Forward structural localization (2026-09-15): independent semantic review
  rejected interior displacement as root width (fixed boundaries can accompany
  interior contraction). Exact forward helper now follows the SAME source
  structures;328 generated checks, independent13500 interval systems and243
  monotone maps are clean. Actual canonical generated positive and unchanged-
  boundary negative tests pass. Review-found JSON type/duplicate bypass,
  unbounded cleanup and insufficient cleanup assertions were repaired; v3
  detects KILL-omitted/leader-only mutations and confirms no stranded processes.
  These repairs are test/measurement infrastructure, not production or portrait
  acceptance. Final optimized related SwiftPM29/0/0, post-archive SDK boundary
  and diff checks pass. Details:95-ROOT-FORWARD-INTEGRATION.md and coverage
  reviews v1-v3. No fresh full no-skip/closeout receipt is claimed.

- Nonlinear measurement checkpoint (2026-09-15): generated-only exact RGB
  correspondence now admits independent signed displacement per sample, shared
  gain/offset and all search cells, without affine-motion assumptions. Final
  self-test contains38 true shifts;32/1024Q16 each pass2/2, while-32/0/15/16/17/20
  pass0/2; two ambiguity controls pass. Actual root integration passes3/0/0
  with PYTHONOPTIMIZE=1. Independent mathematical review found no discrepancy;
  its WR-01 test-assert optimization bypass was fixed and independently cleared
  with exclusion mutations and positive controls in both optimization modes.
  See95-ROOT-NONLINEAR-MODEL.md and95-ROOT-NONLINEAR-REVIEW-v1/v2.md. No production,
  portrait, ROI, threshold or frozen metric changed. This is not a portrait
  gate: source-only anatomical registration, format/model admission, reviewed
  metric integration and full seven-active/one-deferred acceptance remain.
  Final focused related SwiftPM23/0/0, post-archive SDK boundary and diff checks
  pass. Latest full portrait remains6/7; Phase95 and v1.22 are NOT complete.

- Actual-root model applicability (2026-09-15): new generated SwiftPM tests
  exercise the current paired-eye root provider, canonical renderer and memory
  PNG at256/512 pixels, neutral/half/full strength. Actual bytes match the
  unrounded Double sampling reference within one byte; neutral, alpha, extent,
  outside-field pixels and PNG round trips pass. Both tests pass2/0/0.
  Critically, the actual generated root field exceeds the affine prototype's
  +/-1 pixel search, and some five-sample patches have a mathematically necessary
  affine residual >0.05px. The affine prototype is therefore NOT suitable for
  direct root scoring even though its own generated cases pass. No production,
  source, ROI, threshold or historic evidence changed. Next: a measurement model
  covering larger non-affine motion with independently validated uncertainty;
  do not retune effect intensity or promote the affine model. Anatomy registration,
  real portrait scoring and final closeout remain. Details:95-ROOT-APPLICABILITY.md.

- Signed affine-motion correction (2026-09-15): the initial one-channel,
  inward-only draft returned0/2 at32Q16 and used an arbitrary ambiguity cutoff;
  it was not accepted. Main implementation now searches both directions and
  sign-crossing linear motion, jointly fits all RGB channels with gain/offset,
  and retains exact feasible hulls without that cutoff. Generated self-test:
  42 paired cases/84 true-motion containments; at unchanged16Q16 floor,
  32Q16 passes6/6 and20Q16 passes5/6, while-32/0/15/16/17 pass0/6 each.
  Truth is known analytic fixture parameters, NOT an independent production
  pixel oracle. No source/ROI/threshold/production changes or portrait scores.
  Independent review is clean:22 polytopes/97 exhaustive clipping comparisons,
  1172 active-set checks, no findings. Final self-test additionally passes two
  ambiguity controls, one zero-crossing, one error-widening and three invalid
  input controls. See95-ROOT-AFFINE-MODEL.md and NEW95-ROOT-AFFINE-REVIEW-v1.md.
  This closes the generated joint-model defect only. Next: actual non-affine
  root/image-formation validation, source-only anatomical registration and
  genuine portrait acceptance before final independent closeout.

- Subpixel model implementation checkpoint (2026-09-15): generated-only exact rational translation intervals now exercise the actual SHA-pinned CPU interpolation body;126/126 sampler/reference matches and truth containments, seven negative controls. At the unchanged16Q16 floor,17/20/32 pass9/9 with the narrow sampler budget; with a full one-byte experimental budget,17 passes3/9 and20/32 pass9/9, while all <=16 and negative cases remain unpromoted. New canonical geometry/memory-PNG tests pass2/0/0, strengthened to compare against UNROUNDED Double values within one byte on the selected grids. Independent review v1 reports0 findings and118/118 independent math agreements; v2 clears the strengthened-reference delta. Final related SwiftPM selection passes21/0/0. Source scripts/tests and details: `95-ROOT-SUBPIXEL-MODEL.md`, `95-ROOT-SUBPIXEL-REVIEW-v1.md`, `95-ROOT-SUBPIXEL-REVIEW-v2.md`. No production/ROI/threshold/source change or new portrait scoring. Next: source-identifiability/photometric-safe and spatially varying correspondence model, then reviewed source registration and full portrait acceptance. Current prototype is deliberately not promoted; Phase95 remains incomplete.

- First-principles repair investigation (2026-09-15): owner requested research before further tuning. Primary OpenCV/Google documentation and an exact frozen-metric generated probe expose a second problem beyond registration: the allowed spatially varying +/-2 blur contains shifts, so known 112→108 pixel contraction (512 Q16) retains zero-motion explanations and yields conservative margin -594. Independent review reproduced the full pixel-equivalent nuisance construction. A probe truth-oracle warning was fixed and independently cleared; identity/expansion substitutions now reject. Minimal local integer correspondence passes18 cases and rejects3 ambiguous/flat controls, but is not an anatomical/subpixel/portrait gate. See `95-ROOT-FIRST-PRINCIPLES.md`, `95-REVIEW.md` and `95-ROOT-IDENTIFIABILITY-REVIEW-v2.md`. Next: validate actual CPU image-formation uncertainty and near-threshold end-to-end measurement power before any versioned successor/source registration. Manual boundary confirmation is not the only next action and would not resolve this ambiguity alone. Original frozen metric, ROI, thresholds, portrait and history remain unchanged; Phase95 incomplete.

- Resumed verification (2026-09-14): genuine archive-first `bash scripts/run-no-skip-swiftpm.sh` completed with 914 tests, zero failures, zero skips and all eight opt-ins. Archive, SDK boundary and actual Metal parity checks passed. The complete gate snapshot matched before/after (`7e5fef4b275485b13ef414a9cae2fc0f78c7dd7c8d23a2c298bef78181be0002`). This is standalone pre-closeout regression, not a Phase95 completion receipt. A bounded source-only label diagnostic, with zero predicate changes, located the registrar rejection at `remote_competing_edge`; zero source registrations or new-metric scores were credited. See `95-RESUMED-REGRESSION-2026-09-14.json`. Source registration disposition, amended portrait acceptance and final independent closeout remain outstanding.

- Current terminal checkpoint (2026-09-14): generic measurement defects, identity validation, independent generated oracle and registrar transport are repaired/reviewed. Frozen math 346 checks, focused SwiftPM 11/0/0, comparator597, registrar8/22/7 pass. Corrected, independently approved v3 registrar (4a71c8c8) actually returns exit2 `ambiguous_structure` on the same authorized source. Zero successful source registrations and zero new-metric portrait scores. Phase95 Plan03 remains blocked, latest complete effect result still6/7. See `95-ROOT-SOURCE-ATTEMPTS-v2.json` and current95-03 summary. Continuing requires an explicit alternative registration disposition (such as owner-confirmed source structure), not weakening frozen ambiguity/ROI/threshold rules or retuning after observing this source failure. Existing reviews approve exact automatic methods only; no manual-registration contract or final completion is authorized/claimed.

- Source-only attempt (2026-09-14): reviewed registrar v2 (2a96d8f4) was executed and rejected `child_invalid_output`. A separately identity-admitted source-only diagnostic found exactly one typed `ambiguous_structure` rejection plus one native nonrecord line; exit2, all frozen/environment identities unchanged. No registration, second-success attempt, candidate score or new portrait effect credit was issued. Transport v3 separates strict JSON stdout from drained stderr while retaining a combined byte limit and failure exit codes; generated transport checks are running before independent review. The structural ambiguity itself is not waived or solved by this transport change. ROI/threshold/source/frozen math remain unchanged.

- Latest (2026-09-14): independent v3 implementation review approves exact generic draft2 freeze (a205d973), all prior findings resolved; no source measurability or effect credit. New `phase95-root-registration.py` and Swift adapter reuse original ROI/canonicalization, verify pinned identities and permit only source-only double registration after a separate reviewer receipt. Generated adapter 8 checks and admission 22 checks pass. Next: review adapter/binding, execute two source-only registrations, then integrate/review successor scoring identity if source is measurable. No new metric has touched portrait outputs; v1 remains unchanged and fails closed.

- Current generated repair (2026-09-14): independent implementation review `95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v2.md` (`a74b8c33`) rejected draft 1 for combined sampling uncertainty, complete-cell hull boundary and invalid ROI arithmetic; it also identified a threshold-equal oracle edge case. Draft 2 fixes these using forward source sampling, complete-cell tick bounds, ordered input validation and an all-adjacent-segment generated oracle. Current prototype: 346 generated checks pass; focused SwiftPM 11/0/0; diff check passes. Intermediate failed tests remain described in the spec repair history. Draft 2 is pending independent re-review; no source registration or portrait score has used either new draft, no original ROI/threshold/source/history changed, and the latest complete portrait remains candidate6 6/7.

- Latest verified checkpoint (2026-09-14): independent review `95-ROOT-METRIC-REVIEW.md` (commit `2eb0dee0`) confirmed legacy metric false direction/photometric false positives and missing case-to-metric identity validation. The latter is fixed (597 comparator self-tests); the generated provider oracle now measures actual known edge crossings. Ordinary full SwiftPM after root cleanup: 913 tests, zero failures, eight opt-in skips (not no-skip). A generated-only versioned edge-interval prototype passes 250 checks, including independent subpixel geometry, bounded asymmetric blur/noise and identity attacks. It has no portrait-scoring entry point. Next: independent draft implementation review, then reviewed versioned amendment/source-only registration before any new portrait scoring. Original registration/comparator retained in `7d3d336b`; v1 driver correctly rejects the changed comparator. No new effect or completion credit.

- Latest authority/checkpoint (2026-09-14): after a deterministic metric counterexample (actual stripe width 246→204 but dark-centroid margin -168; unchanged geometry/contrast with +30 brightness gives +1344), the owner permits early independent review and measurement-definition repair if confirmed. Preserve ROI/threshold/source/history; independently review and freeze the replacement before scoring portrait outputs. Candidate 10 remains a failed single-case diagnostic (-12); current focused 10/0/0 is not effect acceptance. No new metric has evaluated the portrait.

- Current 2026-09-14 repair checkpoint: candidate 6 complete portrait passes 6/7 active directions (chin now 23), root -2 still fails, all outside/protected changes zero. Candidate 7's disjoint-row root field passes 8 focused tests and a bounded single-case diagnostic improves root to 2, still below unchanged 16. Continuing anatomical support diagnosis; no full candidate-7/no-skip/independent-review credit. Independent review is authorized after all effect acceptance passes. Details: `95-INTERNAL-CONTRACT-REVISION.md`.

- 2026-09-14 authority: owner explicitly answered “允许” to revising internal chin/root deformation contracts while preserving registered ROI, all acceptance thresholds, public parameter caps and the authorized portrait. Resuming implementation and generated safety verification under that scope; no success or independent review is implied.

- Status: active (2026-09-13 owner requested further repair after the two-candidate checkpoint, including the proposed FACE-01 deferred test disposition).
- 2026-09-14 checkpoint: candidate 5 completed two reconciled 65-case attempts, still 5/7 active passes; chin/root 14/0, negative mouth -32, all outside/protected pixels/RGB zero. Current focused 23/0/0, boundary and diff checks pass. No final no-skip or CLOSE-01 credit. Proposed next scope is an explicit internal chin displacement/support and root-field contract revision, preserving ROI/thresholds/public caps/fixture; awaiting owner decision rather than silently increasing those internal bounds. Full measurements and hashes: `95-REPAIR-RESUMPTION.md`.
- Latest checkpoint: candidate 4's two portrait attempts still fail chin/root at 14/0, with five active passes and zero protected/outside deltas. Candidate 5 reallocates unused chin budget within the existing 0.8 bound and centers root fields between crest and canthi; its focused 23/0/0 passes, and a frozen-source portrait run is pending. No threshold, fixture or ROI change; no completion is claimed.
- Resumed evidence: candidate 3 passed 106 focused methods and ordinary full SwiftPM 906/0 with eight opt-in skips; boundary self-test/actual pass after exact-hash CPU-only fixture admission and stronger compatibility backend hashing. Portrait candidate 3 remains failed: five active passes, chin/root 14/0, mouth -32, all protected/outside deltas zero. Candidate 4 fixes independently reproduced pixel-center Y resampling only for homogeneous admitted observed inward fields; fresh focused 22/0/0 passed and full-suite/portrait verification is running. ROI/thresholds/legacy receipts remain frozen; original review bindings are not overwritten or credited for changed tests. See `95-REPAIR-RESUMPTION.md`.
- Diagnosis: The owner-local receipt is a complete `semantic_fail`: 65/65 cases and 8/8 semantic directions evaluated, zero missing outputs. Renderer case definitions bind the seven active IDs to the intended fields/signs, and `RendererExecution` forwards them to CPU `processResult`; manifest/comparator inventory and frozen ROI admission pass.
- Exact blocker: gaze target signal 0/0 with 198 outside pixels; chin taper margin -11 Q16 with 59,114 outside pixels; eyebrow head spacing +4/-5 Q16; nose bridge +9 Q16; nose root +2 Q16 with 881 protected bridge pixels; negative mouth width 0 Q16 with 6,478 protected mouth-height pixels. `faceContourSmooth` is the expected zero-signal deferred direction.
- Disposition: genuine repaired-control behavior on the authorized portrait under the frozen ROI/parameter contract. Do not relax thresholds, alter ROIs, change fixture selection, retune parameters, or fabricate a pass. Stop pending owner decision; no bounded rerun was performed after diagnosis.
- 2026-09-12 successor disposition: owner requested resolution and explicitly approved revising ROI registration using the same authorized portrait's actual anatomical support, preserving thresholds and historical failures, freezing/validating regions before scoring outputs. The previous admission check proved rectangle validity, not anatomical registration: source-only Vision inspection found 0/12 eye contour samples, 0/2 pupils, 0/7 lower-chin samples and 0/2 mouth corners in their corresponding frozen target regions; both eye aperture bounds are disjoint from the gaze target. A Y reflection does not register chin or mouth. No raw anatomy/media/locators were persisted.
- Repair in progress: restore gaze pixel-signal/locality conjunction (two new adversarial probes reproduce and reject the pre-existing bypass); correct clean-65 classification to inspect seven active directions plus the explicitly deferred contour, preserving measured protection values. Source-only ROI registration v1 is being validated before its first output evaluation; original manifest and Phase 90–94 evidence remain unchanged. This is not completion or permission to relax semantic thresholds.
- Registered evaluation: source-only v1 is now frozen in `95-ROI-REGISTRATION.json`; two baseline attempts were identical and still failed (both brow directions passed). Candidate 1 connects observed mouth/nose anatomy, bounds chin support below actual lips and preserves gaze aperture/motion while changing its falloff. See `95-ROI-AMENDMENT.md` for baseline hashes and pre-run source identities. Candidate portrait evaluation is running; no pass or no-skip closeout is claimed. Generated selection passed 47/0/0 plus two nose mapping/redaction methods. A broader selection crashed in the existing incremental build but passed after a fresh independent scratch build; repeat verification is pending, so the crash is not silently discounted.
- Subsequent evidence (2026-09-13): fresh generated selection passed 106/0/0 twice for candidate 1 and 117/0/0 for candidate 2. Candidate 1's two registered portrait attempts passed gaze, both eyebrow signs and bridge; chin/root/negative mouth failed. Candidate 2 is now frozen and running. Ordinary full SwiftPM on candidate 2 executed 904 methods, with eight opt-in skips and eight assertion failures in the one FACE-01 positive-acceptance method. This is not a passing full gate. FACE-01 is already deferred, but changing its positive test into explicit negative/deferred coverage requires owner disposition; requested separately. The unchanged HEAD baseline is being tested independently to establish whether this failure predates this repair.
- Terminal checkpoint: candidate 2 completed 65/65 twice identically. Four active passes: gaze, eyebrow positive/negative, bridge. Chin/root/negative mouth still fail direction/distinctness with margins 5/0/-7 respectively (unchanged ±16 floor); all seven target signals and every outside/protected 0/0 check pass. Full SwiftPM's FACE-01 failures were independently reproduced unchanged at HEAD `24ac1f0db7ddf70982525eb926df68790fe43571`. No third candidate, weakened threshold, final no-skip or CLOSE-01 completion is claimed. Next decision: explicit further algorithm-repair scope for these three fields, deferred FACE-01 test disposition, and reviewed compatibility boundary/evidence-chain correction. See `95-ROI-AMENDMENT.md` and the updated `95-03-SUMMARY.md`; historical checkpoints above are retained, not current success claims.

### C-2026-09-22-v1-22-document-reconciliation

- Scope: 统一状态、合并Phase96草案、修正当前执行入口与收尾实现缺口，区分历史快照与当前验收。
- Why: 旧接口、循环依赖、混用历史/当前哈希及过时授权导致重复阻塞。
- Files: `.planning/V1.22-CURRENT.md`、当前状态/路线图/需求/项目说明、95计划入口、96草案、PLANS、QUALITY_SCORE。
- Verification: 文档一致性、目标文件存在、CLI帮助、历史JSON/JSONL字节和diff检查；详见当前执行细则。
- Build: 未运行SwiftPM/人像；仅文档修复，不授予效果或里程碑完成信用。

### C-2026-09-11-phase-94-negative-mouth-width

- Status: completed（2026-09-11历史完成）；94-06及COMPLETE记录保留，非当前代码复验。
- Completion authority: Current Phase94 completion is determined solely by a valid current `94-REMAINING-COMPLETE.json`; absent, stale or failed evidence means incomplete. This static owner snapshot is not edited after final owner binding.
- Scope: MOUTH-01 negative mouth-width contraction with positive/sibling preservation in the registered owner-local generated-source CPU contract. No new API, backend, model/data or UI work.
- Change: Private negative policyB uses radius clamp(gap/7,0.035,0.20) and cap min(faceWidth*0.040,radius/5,gap/4), preserves Y and checks final Float inward/noncrossing points plus the0.8 negative-pair bound. Original positive body/shared helpers, adapter, renderer and frozen tests/source/thresholds remain unchanged.
- Validation: Current acceptance41/41,0 failures/skips/unexecuted. Source/neutral each520 changed pixels/73743 RGB/−24Q16; positive/size-plus/size-minus margins200/181/37Q16; all negative protection maxima0/0. Actual field/lifecycle/degradation checks and14 original row hashes pass at one identity.
- Preserved failures: Prerequisite compiler/metadata authoring corrections; original negative baseline13/12/1 and full baseline41/39/2; policyA41/40/1 (only392 changed pixels), source commit3230d016 and owned rollback. PolicyB is the declared second attempt; research1, checked plan sets1, attempts2/2, no additional attempt.
- Reviews: Runner authoring16/16 with72 attack rejections; both test freezes and both candidate compile/review/seal chains preserved. Fresh independent implementation/security review reports0 correctness blockers/0 high-security findings. Seven owners are finalized before the independent goal decision.
- Evidence: `.planning/phases/94-negative-mouth-width-repair/94-REMAINING-CHECKS.json` SHA256 `fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`, append-only events,94-01..05 summaries and exact reviews/dispositions. Accepted provider SHA256 `7c3218d0586704cb078b4c7e2004805e182341c37b371567f204094be59153c8`; code/evidence commit4200858a and behavior-owner commit56ecd84d.
- Scope limits: Phase95 private portraits/final65/full no-skip and all population/device/commercial/distribution claims remain separate. Pre-existing config/state-cache/runtime/lock changes are preserved.


### A-2026-09-10-phase-93-registration-disposition

- Status: `completed`; all five plans and independent goal verification passed 18/18 with zero blockers on 2026-09-10.
- Scope: NOSE-01 and NOSE-02 are complete for the frozen owner-local generated SDK contract. The same second candidate passed core36, compatibility229, boundary commands8, deterministic regression106 and all seven owner checks. Public inventory, tests and semantic thresholds remain unchanged.
- Final evidence: [93-VERIFICATION.md](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VERIFICATION.md), the current 93-CHECKS.json and append-only 93-ATTEMPTS.md. All historical failures and reviewed infrastructure dispositions remain intact. Phase 94 is next to plan; Phase 95 obligations remain separate.

#### Historical execution checkpoints

- Finding: neither canonical root support center registers in the frozen root ROI (0/2). Common translation/scaling does not resolve the existing research candidate's support/containment conditions. This is not proof that every provider alternative is impossible and is not a rendered-pixel failure.
- Authorized next step: extend Phase 93 to the adapter's internal `noseRoot(in:)` positioning contract, corresponding regression/independent registration tests, and affected owners. The owner explicitly approved this on 2026-09-10 (CONTEXT D-09). Establish source-side anatomical justification first; preserve frozen ROI/thresholds, public inventory, renderer/backend, legacy nose/tip siblings and the existing two-attempt ceiling. Resume executable planning and independent review.
- Evidence: `.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VALIDATION.md` records aggregate findings, source hashes and the checkpoint. Initial checkpoint had zero executable plans. Current checked plan set: 5 plans / 11 tasks / 5 sequential waves; two initial review blockers were corrected and independently cleared. New research passes: 0; implementation attempts: 0/2. No production/test edits or SwiftPM/render runs; source-only analysis is not runtime validation. `git diff --check` passed.
- Resumed-planning baseline: `swift test --package-path BeautySDK --filter NoseWarpProviderTests` passed 16/0/0 on 2026-09-10. This verifies the unchanged provider baseline only, not registration or frozen NOSE semantic effectiveness.
- 93-01 task 1: bounded gate, immutable baseline bindings, independent memory-only source recipe and two additive Testing SPI cases implemented. Gate self-test passed 50/0/0; SwiftPM test build passed. Registration and rendered-pixel effectiveness remain unmeasured; adapter/provider unchanged and implementation attempts remain 0/2. Existing state/config/runtime changes are preserved.
- 93-01 task 2 RED: three methods discovered exactly once, 2 passed / 1 expected failure / 0 skips; the sole admitted failure is `P93_ROOT_PLACEMENT`. Source anatomy, both planned envelope alternatives, literal floor/floor exclusive raster bounds and the missing/canonical controls pass. Test authoring corrected a compiler expression issue and explicitly tested the existing geometry-purpose rejection of a missing nose separately from combined-purpose partial mapping. No production attempt consumed yet; no rendered-pixel scoring.
- 93-01 execution checkpoint: `begin --attempt 1` rejected `source_scope` before appending a begin event. The frozen gate's regression comparison globally replaces matching root literals, incorrectly expecting six additional changes in unrelated shared/malformed fixtures. The actual change is limited to the named adapter regression as required. Gate/baseline bytes remain frozen; no unrelated fixture changes were made. Task 1 is complete, Task 2 is blocked after verified RED, Task 3 has not run. Attempts started: 0/2; adapter and provider match their pinned original SHA-256 exactly, so no production rollback is needed. Orchestrator disposition must authorize a narrowly scoped gate/binding amendment before continuation; D-09 itself remains approved. No `93-REGISTRATION.json`, semantic RED, provider amplitude change, pixel score, or later-plan execution exists.

- Infrastructure correction (2026-09-10): corrected the gate's whole-file regression replacement to the single approved adapter regression. Original baseline and ledger remain immutable; a narrow hash-linked GATE-AMENDMENT selects the corrected gate identity only. Self-tests 66/0/0 include unrelated-fixture/partial-change and amendment-tamper rejection. No begin event or production edit; repeat old-root RED and independently review before continuation.
- CR-01 follow-up (2026-09-10): begin-1 admission now requires the RED receipt's gate identity to equal the effective baseline gate. The in-memory admission regression reproduced the superseded-receipt bypass before the fix, then accepted current-gate evidence and rejected superseded evidence without writing a begin event. Self-tests passed 69/0/0; authorities passed; fresh old-root registration discovered exactly three methods with 2 passes, 1 expected `P93_ROOT_PLACEMENT` failure and 0 skips. Only the amendment's current gate digest changed; original baseline, prior ledger prefix and production bytes remain unchanged. Ready for independent reviewer recheck; no attempt admission or production continuation performed.
- 93-01 task 2 GREEN (2026-09-10): independent amendment recheck resolved CR-01 with zero findings (`8ececea9`). Fresh corrected-gate RED admitted shared attempt 1 before the sole approved adapter root-Y correction. The three independent registration tests plus the named adapter regression passed 4/0/0, each discovered exactly once. Legacy/tip templates, shared/malformed fixtures, provider, gate and source recipe remain unchanged. Attempt 1 stays open across subsequent plans; no pixel efficacy is claimed.
- 93-01 task 3 complete (2026-09-10): freeze-registration freshly repeated all four GREEN methods and created immutable `93-REGISTRATION.json`, bound to the original baseline, reviewed effective gate, fixture/SPI, registration test, corrected adapter and scoped regression hashes. Authorities and diff checks passed. Plan 93-01 is complete, 3/3 tasks; shared attempt 1/2 remains open with no finish event. Both NOSE requirements remain active pending frozen actual-pixel evidence and the later repair/review plans. Plan 93-02 has not started; earlier failed infrastructure records are retained without reclassification.

- 93-02 task 1 (2026-09-10): independent checked-Int64 bridge-Q8/root-Q16 oracle and complete frozen comparison/protection conjunction implemented. `python3 scripts/check-phase93-nose-repair.py metrics` passed four uniquely discovered methods, 4/0/0. Literal nonintegral floor/floor exclusive bounds, thirds/halves, denominator/overflow/dimension rejection, exact thresholds, all sibling aliases, positive handcrafted controls and proxy/protection mutations pass. Handcrafted arrays establish oracle mechanics only; no public output scoring or provider change. Shared attempt 1 remains open; existing dirty state/config/runtime files preserved.
- 93-02 task 2 checkpoint (2026-09-10): six public tests compile; `red` repeated registration 4/0/0 and metrics 4/0/0 as mandated prerequisites, then stopped at the first lifecycle method with `assertion_failure` (4 discovered, 0 passed, 1 failed, 0 skipped; remaining three not executed). One bounded diagnostic rerun confirmed 24 failures solely at the unchanged named-sRGB assertion; raw child text remained memory-only. The raw nose CPU route uses the retained device-RGB geometry overload, while the plan requires named-sRGB output. Neutral identity, cap/repeat, extent/alpha, rotation/mirror round-trip and old/new facade equality assertions in that method did not fail. This is a metadata prerequisite mismatch, not admitted semantic RED or proof of impossibility. Both semantic methods remain unexecuted and no `93-RED.json` exists. Preserve the tests and stop for parent disposition; no assertion relaxation, production/fixture/SPI/gate/authority/registration edit, provider tuning, attempt finish or plan 93-03 execution. Attempt 1 remains open (one begin / zero finish).

- 93-02 metadata disposition (2026-09-10): code and DESIGN explicitly retain Device RGB for emitting raw-image geometry; the plan incorrectly assumed canonical-carrier named-sRGB output. Parent selected a test-contract correction within existing D-04/D-06 scope, preserving production/rendering, explicit named-sRGB pixel extraction and all frozen semantic/protection thresholds. A hash-linked amendment preserves original binding files and ledger failure 15, permits only this exact pre-semantic authoring mismatch to be excluded from later candidate eligibility, and rejects repeated/other failures. Gate self-tests 90/0/0 and authorities pass; corrected Swift test build passed and independent amendment review passed with zero blockers/warnings. Attempt 1 remains open, no new begin or provider edit.

- 93-02 typed-reason correction (2026-09-10): fresh registration/metrics each passed 4/0/0 and the metadata lifecycle method passed. The missing-support method hit only three scanner assertions because the public `missingLandmarks` enum contains `landmark`; failure 18 is retained at `580cbc8d`. Tests now require exact fixture-specific typed reason arrays while retaining free-text warning/metric privacy checks. The successor redaction amendment binds only this failure and preserves all previous bindings/failed records; gate self-tests 108/0/0 and authorities pass. Corrected Swift test build and independent review passed (zero blockers/warnings); no semantic execution, RED binding, provider edit or budget reset.

- 93-02 task 2 complete (2026-09-10): fresh amended-gate `red` passed current registration 4/0/0, metrics 4/0/0, lifecycle 4/0/0 and both semantic methods 2/0/0; `freeze-red` created immutable `93-RED.json` (SHA-256 `571a87141a7ffcf77e2d5c42c7a9e43edd2ac3510a07751775ef4d09ef234f84`). Both directions honestly remain `baseline_pass` with the original provider and corrected adapter. Bridge source/neutral target 858 pixels / 56232 RGB, margin +563 Q8, minimum sibling difference 553; root 964 / 92187, margin +133 Q16, minimum sibling difference 133. Comparison counts 6/5; outside, protected nose groups, background and watermark maxima are all 0/0; repeated-byte status 1/1 and all five retained sibling digests agree. Historical authoring failures 15/18 remain unchanged under their precise reviewed dispositions. Plan 93-02 is complete, 2/2 tasks; attempt 1 remains open (one begin / zero finish). No efficacy tuning is warranted by this baseline; 93-03 may address only independently demonstrated safety/scaling regressions. No 93-03 execution or requirement/phase closeout is claimed.

- 93-03 task 1 complete (2026-09-10): six field methods and exactly three authorized centered-bridge expectations frozen after unchanged-provider RED: 22 discovered, 17 passed, 5 expected-failing methods, zero skips. All seven fixed assertion IDs occurred exactly once; all remaining original invariants passed. Independent actual-displacement scaling, strict renderer admission, whole-field/dense-map regressions fail on the original provider; this is not manufactured semantic RED. Fifteen sibling-vector digests were captured before production changes. Dense 64-point half/quarter fields explicitly abstain when the cutoff cannot fit the scaled budget; applicable cap fields require nonempty denominators. Sanitized SwiftPM test build and authorities passed. Shared attempt 1 remains open; no additional begin, source change, threshold change or later-plan work.

- 93-03 task 2 terminal safety stop (2026-09-10): fixed candidate 1 compiled and passed source/authority admission, then provider GREEN stopped at `testFinalFloatFieldBudgetAndDenseMap` / `P93_FIELD_BUDGET`: 22 discovered, 18 passed, 1 failed, zero skips, three unexecuted. No post-evaluation correction, candidate 2, pixel rerun or later-plan work is authorized. Candidate semantics are untested; both prior original-provider semantic baselines remain historical `baseline_pass`, not acceptance of the repaired candidate. Preserve evaluated candidate/test hashes and failing proof, finish shared attempt 1 as failed, and restore only owned adapter/provider bytes to the pinned originals. Both NOSE requirements remain active; parent repair/defer/stop disposition is required.

- 93-03 rollback verified (2026-09-10): failed candidate preserved in `e4e89680`; ledger sequence 26 finishes attempt 1 as `failed` / `assertion_failure` / `production_restored`. Adapter and provider match their pinned original SHA-256 values exactly; one begin and one finish remain, with no candidate 2. Frozen registration/RED/amendment files and tests remain unchanged. The corrected root regression and new provider regressions are intentionally retained as failing proof after rollback. Do not run plan 93-04/05 or treat the finish command's successful rollback status as candidate acceptance.

- 93-03 read-only failure analysis (2026-09-10): source inspection and explicit binary32 arithmetic reconstruction identify the existing 16-support cap case at budget 0.45000014551914536, above 0.45. The final guard returns an empty field, conflicting with its frozen applicable-cap nonempty assertion. This identifies a concrete failing subpredicate, not emitted folding or proof that all other predicates pass; no post-stop Swift/render rerun or candidate change occurred. See `93-FAILURE-ANALYSIS.md`. Any reconstruction-aware substantive correction is the remaining second attempt and needs a new repair disposition after this safety stop; no budget reset or automatic retry. State/roadmap now show 2/5 plans complete and 93-03 halted; both NOSE requirements remain active.

- Phase 93 D-10 (2026-09-10): owner requested first-principles diagnosis and repair after the second-attempt proposal. Reopen plan 93-03 for the remaining second attempt, retaining the 0.45 ceiling, all frozen tests/pixel thresholds and candidate-1 radii. Derive quantization toward the source rather than increasing empirical Float slack. Exact prior rollback and failed history remain; candidate and recovery runner require independent review before execution. No third attempt or budget reset.

- 93-03 historical core acceptance under D-10 (2026-09-10): reviewed recovery wrapper/manifest and clean pre-evaluation review committed in `c41ed2e6` (self-test 133/0/0); exact reconstruction-safe candidate `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45` applied in `851d1d5f` with the approved D-09 adapter and unchanged R1 radii 0.08/0.07. Ledger 27 begins attempt 2; receipts 28–32 pass provider 22/0/0, registration 4/0/0, metrics 4/0/0, pixels 2/0/0 and lifecycle 4/0/0 at one identity; authorities pass. Sequence 33 finishes attempt 2 `passed` / `retained`, total 36/0/0, with subsequent independent review still `pending`. Bridge source/neutral target 611 pixels / 29460 RGB, +383 Q8 and minimum sibling margin 373; root 1043 / 43917, +24 Q16 and minimum sibling margin 24. Comparison counts 6/5, repeated-byte status 1/1, all outside/protected/background/watermark maxima 0/0, and all five retained sibling digests agree with baseline. This was provisional core acceptance at sequence 33; the later terminal disposition below controls current status; candidate 1, its failure and exact rollback remain historical facts. Original gate/bindings/tests/thresholds remain frozen; two attempts consumed, no third attempt or reset. Both NOSE requirements remain active pending subsequent phase work. This handoff updates only SUMMARY/PLANS and performs no tests, production/ledger/state/roadmap edits or 93-04/05 execution.

- 93-03 compatibility-blocked after core acceptance (2026-09-10): parent compatibility execution repeated all 36 core methods at sequences 34–38 with identical pixel aggregates, then sequence 39 recorded `child_timeout` in `BeautyCoreTests.BeautyExampleRendererProcessTests/testCompiledRendererBindsOnlyExactSuccessfulGazeAggregate`. Exact ledger counts: 229 discovered / 67 passed / 0 failed / 0 skipped, empty assertions; 67 passes + 1 timeout + 161 unexecuted. CLI `failed=1` represents the timeout, not an established assertion failure. No negative pixel, provider-arithmetic or folding claim follows. Sequence 40 preserves successful finish 33 and appends `recovery_rollback` / `attempt_failed` / `production_restored`; current provider SHA-256 `0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8` and adapter `7b3ca8d3dafad4068a49ee6fae963183601e59d10bb5eb40b0fdd8ee7f3e515d` match pinned originals. Plan 93-03 is halted/compatibility-blocked, 1/2 tasks complete, both implementation attempts consumed, no current accepted candidate and no downstream-plan advancement. The 36 core passes and both failed-attempt histories remain intact. Parent continues the authorized infrastructure-only correction/review and possible revalidation of the exact same `bafa9d2a...` candidate; that is not a new production candidate or reclassification of failure 39. This handoff edits only SUMMARY/PLANS and runs no Swift or new runner.

- Phase 93 same-candidate revalidation: the ongoing owner repair/continue request covers the independently reviewed outer/inner timeout correction (`35899899`). The exact `851d1d5f` candidate was restored at `2194e04c`, without a third numerical candidate or test/threshold changes. Resume 41, fresh core receipts 42–46 and revalidation 47 pass 36/0/0 under the new runner. Timeout 39 and rollback 40 remain immutable. Plan 93-03 is complete again; full compatibility, code/goal review and owner synchronization remain pending.

- Phase 93 owner synchronization / plan 93-05 (2026-09-10): implementation verified at exact candidate 2 `bafa9d2a...` / D-09 adapter `cf191001...`, independent code review `ee6d55f9` clean. [93-CHECKS.json](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-CHECKS.json) together with `93-ATTEMPTS.md` and `93-REGRESSION-DISPOSITION.json` preserves per-gate provenance: core 36/0/0 is ledger receipt 47, pinned by the regression disposition; CHECKS directly contains compatibility 229/0/0 (53), eight SDK-owned commands 8/0/0 (54) and fresh deterministic regression 106/0/0 (56), plus subsequent owner receipts when recorded. The reviewed entrypoint chain `4b07195c...` → `eb7ccc0f...` → `7ff1598b...` and timeout/regression dispositions retain the unchanged original gate/frozen bindings and distinguish reused receipts from fresh execution. One original research pass, one independently checked plan set and two substantive implementation attempts remain; candidate-1 failure, timeout 39/rollback 40 and extra-scope portrait selection failure 55 are not erased or relabeled. Scope correction `07664fa5` excludes only the two Phase 95 portrait opt-ins; no test relaxation or third candidate occurred. Canonical source/neutral pixels: bridge 611/29460, +383 Q8, minimum sibling 373; root 1043/43917, +24 Q16, minimum sibling 24; comparisons 6/5, repeats 1/1 and all outside/protected/background/watermark maxima 0/0. Eight-orientation evidence covers bridge raw-facade agreement only. Seven owner-local documents now describe the bounded anatomy/field contract and evidence; owner checks passed at receipts 57/58 and independent goal verification subsequently passed 18/18; Phase 93 is completed. Phase 95 retains private portraits, final clean 65-output evidence, precision residuals and full no-skip closeout. ARCHITECTURE.md is unchanged because no target/dependency/API/backend changed.



### C-2026-09-08-phase-92-signed-eyebrow-head-spacing

| Field | Value |
| --- | --- |
| Status | `completed`; independent phase verification passed 10/10 (`e2768cf`). |
| Scope | Existing signed inner-head spacing in the owner-local still-image SDK; independent per-side support, unchanged frozen actual-pixel authority. |
| Planning | One initial research pass and checked plans; owner explicitly reopened repair on 2026-09-08 beyond the original two-attempt ceiling. Every substantive R1–R5 candidate was independently reviewed. Original failures remain historical failures. |
| Implementation | R4 `c14719b` passed sparse pixels but independent review found dense same-side folding. RED `4a92373` reproduced it; R5 `470ae0d` resolved it; evidence `af85fdb`, authority/compatibility `4b8f372`, design/journey/reliability `3d3322f`. Repair cycle 1, cumulative attempt 7. |
| Contract | Per-side cumulative inner-half taper, 0.020 nominal displacement coefficient, fixed target centers, linear falloff, generic 4.5% radius ceiling, source/target clearance, public 0.25 cap and exact dead zone remain. R5 caps each side's actual summed displacement norm/radius at 0.9 with conservative Float reconstruction; no arbitrary combined-field injectivity claim. |
| Evidence | Nine BROW methods; full focused 23/0/0. Source/neutral signs +48/-22 Q16, opposite 70, siblings 26/35/96/35; target 699/720, RGB 61174/45676; all protected maxima 0/0; peer 0/0; recovery and metadata assertions passed. |
| Closeout | Post-R5 compatibility/freshness 217/0/2 with only two existing portrait opt-in skips (required compatibility 120/0/0). Comparator 576 mutations/5/65/8, cleanup 6, preflight 75/65/8, backend-neutral 24+41, archive hashes, SDK-only and diff gates passed. Independent implementation review clean. |
| Compatibility | Exactly 62 fields, five presets, 75 renderer cases, both still-image facades, CPU/GPU policy and retained Warp.metal remain unchanged. |
| Privacy and failure boundary | Request-local geometry/media remain absent from durable evidence; only counts, hashes, statuses and fixed aggregates persist. Invalid per-side support or reconstructed budget fails closed without peer borrowing. |
| Handoff | Phase 93 is next after passed final phase verification. Phase 95 retains portrait evaluation, final 65-output evidence and the full no-skip closeout. No device, naturalness, commercial, launch or external-distribution claim. |


### C-2026-09-06-phase-91-independent-gaze-correction

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Repair existing positive `gazeCorrection` so every independently eligible observed pupil moves toward its own eye center without peer borrowing, aperture escape, public-inventory change, or raw-anatomy persistence. |
| Planning | One bounded research pass produced `91-RESEARCH.md`; one four-plan set was independently checked to zero blockers after its finite revisions. Plans 91-01 through 91-03 and this closeout all share `implementation_attempt: 1`; no second attempt was needed. |
| Implementation | Plan 91-01 split paired pupil-size compatibility from per-eye gaze eligibility and added simple-aperture/half-clearance admission (`d856b92`, `949d6a5`, `c05e2c1`, `f07845d`). Plan 91-02 attached the final post-conflict six-key aggregate and generated public-facade pixel proof (`56636d0`, `3a38bd9`, `de5a63d`, `7675721`). Plan 91-03 bound the aggregate to the exact renderer output and comparator cleanup lifecycle (`e175cb5`, `51e6d99`, `101c81c`, `f742a54`). |
| Contract | Exact displacement `0.002` is neutral; positive work caps at `0.25` and moves at most 35% toward that eye's own center. The gaze radius is no greater than the least of 5% face width and half the source/target aperture clearances. Missing, malformed, centered, outside, stale, or otherwise ineligible support fails closed per eye; paired `pupilSize` behavior is unchanged. |
| Evidence | Generated 512×512 public-facade evidence measured own-center reductions `201/203 Q16`, target signal `1316/51731`, and outside/contour/brow/background/watermark `0/0`. The final aggregate is exactly eligible/corrected/rejected counts, all-reduced, abstained, and minimum-reduction Q16; bilateral/single/abstain rows are `2/2/0/1/0/688`, `1/1/0/1/0/688`, and `0/0/0/0/1/0`. |
| Closeout | The Phase-90-deferred frozen FACE-01 effectiveness oracle remains discovered exactly once and intentionally non-GREEN; the remaining current-authority SwiftPM suite passed `840/0/8`, and focused compatibility passed `107/0/0`. Comparator self-test passed `576` mutations with `5/65/8`; runner boundaries passed with `report_cleanup=6`; preflight passed exact `75/65/8`; backend-neutral passed `24` focused and `41` CPU-reference tests; both archive hashes and the post-archive SDK-only boundary passed. Task 91-04 moved only the CPU-reference inventory's two target-internal gaze samples from aperture-boundary to deterministic interior positions (`5f4ee81`), without changing assertions or production behavior. |
| Compatibility | Exactly 62 stored fields, five presets, 75 renderer cases, both still-image facades, CPU reference, selectable `.cpu`/`.gpu`, terminal `.metalUnavailable`, and retained `Warp.metal` remain unchanged. |
| Privacy and failure boundary | Gaze anatomy, pixels, masks, radii, private locators, temporary reports, paths, and transcripts remain request-local or test-local and absent from durable evidence. Invalid algebra, identity mismatch, replay, proxy-only evidence, report residue, or cleanup failure earns no semantic credit. |
| Handoff | EYE-01 is complete at owner-local package-host scope. Phase 92 is next. Phase 95 alone owns the authorized portrait rerun, final clean 65-output publication, precision residuals, and `scripts/run-no-skip-swiftpm.sh`; Phase 91 ran none of those and makes no device, population, naturalness, commercial, packaging, shipping, launch, release, or distribution claim. |

### C-2026-09-02-phase-90-chin-repair-and-contour-deferral

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Close Phase 90 as the completed FACE-02 `chinTaper` repair plus an evidence-backed FACE-01 `faceContourSmooth` deferral; do not change production source, public inventory, renderer, backend, fixtures, frozen thresholds, or the meaning of prior diagnostic evidence. |
| Completed sibling | Phase 90 Plan 90-02 repaired FACE-02 `chinTaper`; its production and test commits remain complete. |
| Prior blocker | Plan 90-01 exhausted its earlier finite safe provider-only candidates. The best local and monotone result was `+5 Q16` versus the frozen `+16`; wider support reached `+9` but violated outside protection. |
| Preserved state | Failed production experiments and temporary diagnostics were removed. The committed generated RED and pre-attempt provider behavior remain. |
| Evidence | `.planning/phases/90-face-contour-and-chin-repairs/90-01-ATTEMPT.md` retains exactly eleven aggregate-only stop records. Revision 18 compiled and stopped with an empty cap/half field before oracle. Revisions 19-21 ended at bounded harness/source gates without a marker or suffix. Revision 22 then executed exactly once and committed its sole suffix at `fe2e8c2`: `prior_stop_not_reproduced`, one construction, `20/20` provider and reference cap/half admissions, 20 final points, zero render/oracle invocations, byte-exact provider/test rollback, temporary symbols absent, and `FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED`. The post-decision `90-01-SUMMARY.md` is a `completed-deferred`, promotion-ineligible terminal record with no completed requirement. Plan 90-03 completed owner synchronization in `236e0c6`, `5bd52af`, and `2b04302`; Plan 90-04 Task 1 recorded the exact boundary expectation synchronization and fresh bounded evidence in `4c0970e`. |
| Owner decision | On 2026-09-02 the owner prohibited revision 23, removed FACE-01 from active v1.22 requirements, retained the existing public field/current safe implementation unchanged, and required taxonomy status `partial`. On 2026-09-04 the owner authorized the minimal boundary-checker expectation synchronization from `implemented` to `partial`; no other script, algorithm, test, threshold, or gate relaxation is authorized. |
| Remaining milestone budget | Phases 91–94 receive one research pass, one independently checked plan, and at most two implementation attempts before an explicit owner repair/defer/stop decision. |
| Completion | FACE-02 is the sole completed active requirement. FACE-01 remains `completed-deferred`, FUTURE-04, non-GREEN, and taxonomy/boundary `partial`; no frozen effectiveness credit is inferred from its safe/current tests. |
| Verification | Fresh focused `142/0/0`; compatibility `154/0/1` with one existing Vision opt-in skip; comparator self-test `PASS` with 554 mutations and `5/65/8`; preflight-only `75/65/8`; both archive hashes verified; post-archive SDK-only boundary passed; exact one-tuple diff passed; zero `BeautySDK` and other-script drift. The 62 fields, five presets, 75 cases, both facades, CPU/GPU policy, and retained `Warp.metal` remain unchanged. |
| Handoff | Phase 91 is next under one research pass, one independently checked plan, and at most two implementation attempts before an owner repair/defer/stop decision. Phase 95 owns the clean 65-output rerun, seven effective directions plus one deferred direction, complete all-opt-ins no-skip closeout, and direct `chinTaper` one-step, cap-adjacent, quantization, and tie tests. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Freeze FACE-01 RED | `completed` | Exact generated CPU oracle retains Phase 89 regions, signs, siblings, thresholds, and protection bounds. |
| Explore bounded provider-local candidates | `completed-blocked` | Six topology/solver families were disconfirmed without weakening the oracle or safety gates. |
| Remove failed production diagnostics | `completed` | Production/test worktree restored to the committed state; only planning evidence remains modified. |
| Replan FACE-01 | `completed` | Independent plan review passed the bounded seven-candidate, full-strength safety design. |
| Diagnose revision-8 stop | `completed` | Six candidates first failed single-field Lipschitz admission; B1 first failed exact cap/half Float representability. Radius clamping and corridor containment were not first blockers. |
| Replan FACE-01 revision 9 | `completed` | Independent review passed the exact L1, paired cell, half-first lattice, energy, global injectivity, and stop-verifier contracts. |
| Execute FACE-01 revision 9 | `completed-blocked` | C1 and C2 each admitted zero points after the frozen contour produced seven points per strict corridor branch against the required minimum of eight; oracle hash remained pinned and sanitized Q16 aggregates were identical. |
| Audit revision-9 support | `completed` | Each side has seven canonical points, three distinct anchor roles, four eligible knots; C1 can retain four pairs across all zones, while C2's five-pair minimum is impossible. |
| Replan FACE-01 revision 10 | `completed` | Independent review passed the corrected seven-point, three-anchor, four-pair C1-only plan and revision-10 rollback contract. |
| Execute FACE-01 revision 10 | `completed-blocked` | C1 passed corrected support and analytical admission with eight points but failed the unchanged frozen oracle at `+1/+1 Q16`; exact rollback and `FACE01_STOP_VERIFIED` passed. |
| Research FACE-01 revision 11 | `completed` | Two read-only audits selected a single fixed extremum-inclusive direct-secant field with one predetermined adjacent overlap per side; an infeasible medial-carrier draft was rejected before execution. |
| Independently check FACE-01 revision 11 | `completed` | Goal-backward review passed with zero blockers and zero warnings after deterministic extremum, empty-neighbor containment, arbitrary-strength Float scaling, and honest proxy-energy wording were made executable. |
| Execute FACE-01 revision 11 | `completed-blocked` | D1 stopped at the first mandatory cap-target-first Float lattice: five fixed states failed exact target/source and half/source subtraction identities; no field or oracle candidate was admitted, exact rollback and `FACE01_STOP_VERIFIED` passed, and no summary exists. |
| Research FACE-01 revision 12 | `completed` | Proved the exact dyadic Float lattice and found that the failed D1 geometry also had independent containment and row-proxy defects; no rendered output was used for selection. |
| Independently check FACE-01 revision 12 | `completed` | The complete-chain D1-v12 plan passed with zero blockers and warnings after explicit source anchoring, target linkage, exact Float order/types, analytical-vs-retained slot semantics, and compile-valid `g` construction. |
| Research FACE-01 revision 13 | `completed` | Diagnosed revision-12's implementation-only residual-neighbor indexing defect; revision 13 changes only that block and adds a scaffold diff guard. |
| Independently check FACE-01 revision 13 | `completed` | Plan review passed with zero blockers and warnings, including endpoint-inclusive `Q(0)`/`Q(1)` residual mapping and five-section prefix accounting. |
| Execute FACE-01 revision 13 | `completed-blocked` | Endpoint-inclusive indexing passed; execution stopped at a valid zero-curvature slot with no field admitted, exact rollback and `FACE01_STOP_VERIFIED` passed. |
| Research FACE-01 revision 14 | `completed` | Confirmed finite zero local residual is valid reference geometry; bounded paired omission is the only new degree of freedom, with mandatory extrema/neighbor slots and all safety/oracle gates unchanged. |
| Independently check FACE-01 revision 14 | `completed` | Plan review passed with zero blockers and warnings, including zero-residual admission, six-section prefix accounting, and no-bridging final-set rules. |
| Execute FACE-01 revision 14 | `completed-blocked` | D1-v14 omitted the two zero-residual pairs and passed lattice, then stopped because the scaffold returned an unconditional owner-success placeholder without computing actual Float H/R/B/adjB or containment; exact rollback and `FACE01_STOP_VERIFIED` passed. |
| Research FACE-01 revision 15 | `completed` | Isolated the v14 implementation/evidence defect and constrained v15 to actual Float source/target owner/unit membership, H/R/B/adjB positive 0.94H slack, expanded-support containment, and first-failure recording; every other v14 contract is frozen. |
| Independently check FACE-01 revision 15 | `completed` | Plan review passed with zero blockers and warnings, including eighth-section prefix accounting and no tuning, fallback, or oracle weakening. |
| Execute FACE-01 revision 15 | `completed-blocked` | Actual Float owner/unit and expanded-support membership passed, but the fixed positive-slack gate failed at retained zero-based slot 4 on both sides (5/5); exact rollback, aggregate-only suffix, and `FACE01_STOP_VERIFIED` passed, with no oracle invocation or summary. |
| Research FACE-01 revision 16 | `completed-blocked` | Read-only feasibility audit found no provable legal owner-balanced slot/carrier construction: the fixed v15 contour violates `H_neighbor/H_i <= 7/6`, while every apparent escape changes a frozen threshold/definition, omits a nonzero mandatory pair, changes lattice linkage, or uses output-guided selection. No plan files or source were changed. |
| Independently check FACE-01 revision 16 | `blocked` | No concrete revision-16 plan exists to review; a checker cannot approve an unproved construction. |
| Execute FACE-01 revision 16 | `blocked` | Not authorized without a concrete independently checked plan; v15 provider/test state and frozen oracle remain unchanged. |
| Authorize FACE-01 revision 17 contract | `completed` | After the terminal v16 report, the owner instructed the autonomous workflow to continue. Scope is limited to an internal branch-balanced radius construction; public API, 62/5/75 inventories, renderer/backend/Warp.metal, safety thresholds, frozen oracle, privacy, SDK-only, and non-distribution boundaries remain unchanged. |
| Research and plan FACE-01 revision 17 | `completed` | The executable plan uses one deterministic branch-global minimum-clearance radius: `H_branch=min(retained actual-target H_i)`, `R_i=.75H_branch`, `B_i=.08R_i`; this proves owner slack because `R+2B+adjB=.93H_branch<.94H_i`. No alternative radius candidate or rendered-output selection is allowed. |
| Independently check FACE-01 revision 17 | `completed` | Goal-backward review passed with zero blockers and zero warnings after exact-section verification was added for the analytical owner proof, actual Float gates, downstream contracts, eight-prefix/ninth-suffix evidence, and unchanged product boundary. |
| Execute FACE-01 revision 17 | `completed-blocked` | The branch-minimum radius proof and all owner/unit/slack/expanded gates passed, then the fixed single normalized-displacement bound failed before global Lipschitz/inverse/proxy and the frozen oracle. Provider/test bytes were restored byte-exact, exactly one ninth aggregate suffix was appended, and `FACE01_STOP_VERIFIED` passed. |
| Authorize FACE-01 revision 18 contract | `completed` | After the revision-17 terminal report and recommendation, the owner instructed the autonomous workflow to continue. Revision 18 may redesign only the internal displacement/target construction (including its `d0`, lattice linkage, or cap-target law); revision-17 retained topology, radius/owner clearance system, `0.20/0.40`, Lipschitz/inverse, frozen oracle, public/API/backend/Warp.metal, privacy, SDK-only, and non-distribution boundaries remain fixed. |
| Research FACE-01 revision 18 | `completed` | `90-01-REV18-RESEARCH.md` proves one sole construction: retain the raw revision-17 lattice only as sign/reference, clip emitted `q` by `floor(Hsrc_branch/(64g))`, and rebuild exact cap/half/target linkage. Analytical bounds are `8/45`, `16/45`, and inverse `29/45`; actual binary32 pre-output gates, overlap, owner slack, linkage, and proxy passed with positive margins. The frozen oracle was not invoked. |
| Independently plan/check FACE-01 revision 18 | `completed` | Independent goal-backward review passed with zero blockers and zero warnings after explicit research resolutions, a complete Phase 90 Nyquist strategy, and <=30-second task sampling with the long focused/archive chain retained as the mandatory Phase Completion Gate. |
| Execute FACE-01 revision 18 | `completed-blocked` | D1-v18 compiled, but the focused pre-render check returned an empty whole field at cap and half (`0/20`). The frozen candidate oracle was never invoked; provider/tests were restored byte-exact, exactly one tenth aggregate-only suffix was appended, and `FACE01_STOP_VERIFIED` passed in commit `36d2ec5`. |
| Diagnose revision-18 whole-field stop | `completed-blocked` | Read-only diagnosis is classification C: insufficient instrumentation. Durable evidence proves the final empty field but cannot identify the earliest failing raw-lattice, source-clip, linkage, clearance/owner, overlap/safety/proxy, strength-finalization, or budget gate. The minimum future diagnostic contract is sanitized, test-only, request-local first-failure categories and aggregate retained/admitted counts, without coordinates, geometry, pixels, private paths, transcripts, or oracle invocation. |
| Authorize FACE-01 revision 19 diagnostic contract | `completed` | After the revision-18 terminal report, the owner instructed the autonomous workflow to continue and complete the milestone with `--auto`. Under the previously declared authorization boundary, revision 19 is limited to diagnostic instrumentation: no construction, threshold, renderer/backend/Warp.metal, public inventory, privacy, or frozen-oracle change/attempt. |
| Research FACE-01 revision 19 diagnostic | `completed` | `90-01-REV19-DIAGNOSTIC-RESEARCH.md` specifies one shared request-local reconstructed template, provider/reference cap-and-half finalization comparison, fixed earliest-gate enums and minimum counts, a new non-executing static verifier, exact rollback, and an exact ten-heading prefix with at most one aggregate-only eleventh suffix. Outcomes are limited to `implementation_defect`, `genuine_construction_miss`, `prior_stop_not_reproduced`, or `diagnostic_invalid`; every outcome stops without render/oracle execution. |
| Plan and execute FACE-01 revision 19 diagnostic | `completed-blocked` | The retained verifier was committed in `f3cf3b2` and hardened in `03bfada`; target build passed, but the sole preflight failed closed on the wrong status allowlist before XCTest. No marker/counts/suffix exists. Provider/test rollback, zero render/oracle, clean worktree, and absent 90-01/03/04 summaries were verified. |
| Authorize FACE-01 revision 20 diagnostic execution | `completed` | The continuing `$gsd-autonomous --auto` instruction separately authorizes one new diagnostic execution. It preserves the D1-v18 reconstruction and D1V19 implementation vocabulary; only the preflight/rollback diff allowlists change. |
| Plan and execute FACE-01 revision 20 diagnostic | `completed-blocked` | D20-A committed policy at `a4f9688`; D20-B's sole target build failed on predicate-style suffix and unavailable bare floor/round before live preflight/XCTest. Exact rollback and ten-heading/no-suffix state passed; this is compile-only `diagnostic_invalid`. |
| Authorize FACE-01 revision 21 diagnostic execution | `completed` | The continuing owner authorization creates a separate execution limited to compile-safe spelling of the same three temporary operations; it is not a revision-20 retry or construction change. |
| Plan and execute FACE-01 revision 21 diagnostic | `completed-blocked` | D21-A committed verifier `c8c34b6` and every fixed self-test/hash passed. D21-B's sole source gate rejected the two raw subscripts because each appeared twice; no build/preflight/XCTest/marker/count/classification/suffix occurred, byte-exact rollback passed, and summaries remain absent. |
| Authorize FACE-01 revision 22 diagnostic execution | `completed` | The continuing owner authorization creates a separate execution limited to exactly-once bindings for the same no-triple predicate. The complete verifier, qLimit, both m_s forms, construction, gates, status policy, and product boundaries are frozen. |
| Plan and execute FACE-01 revision 22 diagnostic | `completed-blocked` | D22 executed exactly once and committed aggregate-only evidence at `fe2e8c2`. The single request-local reconstruction classified `prior_stop_not_reproduced`: provider/reference cap and half each admitted 20/20 points, final count was 20, render/oracle counts remained zero, provider/test restored byte-exact, temporary symbols were absent, and the retained verifier reported `FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED`. Per the frozen contract, no summary or downstream execution was created. |
| Complete FACE-01 | `completed-deferred` | Revision 18 remains the terminal verified construction stop and revision 22 remains diagnostic-only. The owner moved the effectiveness requirement to FUTURE-04; no revision 23, production change, threshold change, oracle retry, or GREEN claim is authorized. |
| Reconcile terminal FACE-01 artifact | `completed` | `90-01-SUMMARY.md` records the owner-approved completed-deferred/non-GREEN disposition with `promotion_eligible: false` and no completed requirement. |
| Replan and independently check Phase 90 Wave 2/3 | `completed` | Rewritten 90-03/04 close one completed FACE-02 repair plus one deferred/partial field. After the first independent recheck blocked incomplete exact-diff wording, commit `4c50d1c` repaired it and final independent checker commit `9238b08` authorized execution with zero blockers and warnings. |
| Execute Phase 90 Wave 2/3 | `completed` | 90-03 completed. Fresh 90-04 execution passed predecessors; focused `142/0/0`; compatibility `154/0/1` with one existing Vision opt-in skip; comparator self-test with 554 mutations and `5/65/8`; preflight-only `75/65/8`; both archive verifications; and the post-archive boundary scan after the exact owner-authorized `faceContourSmooth` expectation update to `partial`. No live portrait, frozen FACE-01 effectiveness, or complete no-skip command ran. |

The v1.21 entry below is complete and retained for session continuity.

### C-2026-08-25-v1-21-provisional-upper-eyelid-public-activation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Keep `去脂`, add owner-local public `upperEyelidFullnessReduction`, route it through retained bounded v4 mechanics, record weak visual quality as future debt, and close v1.21. |
| Owner Acceptance | The owner directs that manual checks be treated as accepted. This is recorded as a supplied product decision; no new blinded review run or transcript is claimed. |
| Privacy | Per-eye support, masks, pixels, proposals, paths, and experimental summaries remain request-local/package-only; durable evidence is aggregate and code/test based. |
| Distribution | Swift `public` remains owner-local access only; no SDK, binary, model, weight, fixture, output, or derived data is distributed. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Add public scalar and admission | `completed` | `BeautyParameters` trailing default-zero/Codable/clamped field plus `BeautyEffectResolver.localRetouchAdmission`. |
| Route retained mechanics through public still-image facade | `completed` | One selected observation resolves existing per-eye semantic support/editor units into immutable-source composition. |
| Add public output and compatibility coverage | `completed` | New facade test passes 4/4, including paired/one-eye/malformed/no-face support; parameter/resource/renderer inventories updated to 62/5/75. |
| Synchronize owner contracts and GSD archive | `completed` | Taxonomy, root owners, v1.21 requirements/roadmap/phase archive, project/state/milestone ledgers. |
| Run complete SDK-only closeout | `completed` | Focused public upper-eyelid 4/4; parameter/renderer/process/resource/resolver/foundation suites 50/50, 24/24, 7/7, 15/15, 29/29, 25/25; final archive-first no-skip SwiftPM 817/0/0 with eight opt-ins exactly once and zero skips. |

Known quality debt: the current source-derived effect is conservative and
visually weak. Future optimization must use a new explicit milestone, preserve
the public neutral/Codable/fail-closed contract, and cannot infer device,
commercial, or distribution authority.

### C-2026-08-25-v1-20-owner-local-retouch-acceptance

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Start v1.20 to document and validate direct owner-local still-image use of `白牙` and `祛红血丝`; do not reopen or modify `去脂`. |
| Completed | 2026-08-25 |
| Verification Policy | Focused public-facade tests; `BeautyExampleRenderer` one-case-per-effect batch; aggregate report reconciliation; archive/boundary/binding/no-skip/full SwiftPM gates. |
| Privacy | Authorized portraits and rendered outputs stay in temporary owner-controlled directories; only aggregate counts and command shape enter durable evidence. |
| Distribution | Swift `public` remains owner-local access only; no package, binary, model, weight, private fixture, or derived data is distributed. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Define v1.20 scope and requirements | `completed` | `.planning/REQUIREMENTS.md` maps API-01/API-02/VAL-01/VAL-02/BOUND-01/CLOSE-01 to Phases 85–87. |
| Create roadmap and archive canceled v1.19 | `completed` | `.planning/ROADMAP.md`; immutable v1.19 roadmap/requirements and phase artifacts under `.planning/milestones/v1.19-*`. |
| Document direct owner-local Swift usage | `completed` | `PRODUCT_SENSE.md` section 2.1 names both public calls, fields, metadata, defaults, opaque-input and fail-closed boundaries. |
| Batch `teethWhitening_1p00` on authorized local portraits | `completed` | Temporary `BeautyExampleRenderer` run: 11 requested, 11 succeeded, 0 failed, 0 skipped. No raw output retained in repo. |
| Batch `scleraRednessReduction_1p00` on authorized local portraits | `completed` | Temporary `BeautyExampleRenderer` run: 11 requested, 11 succeeded, 0 failed, 0 skipped. No raw output retained in repo. |
| Run focused and full SDK-only closeout gates | `completed` | Focused 34/34 and 74/74; archive/boundary/binding checks pass; full no-skip SwiftPM 813/0/0 with eight opt-ins exactly once and zero skips; no production Swift source changed. |

### P-2026-08-24-phase-80-genuine-qualification

| Field | Value |
| --- | --- |
| Status | `canceled` |
| Scope | Replace the failed hand-authored route with an actual-use-authorized owner-local learned hybrid, qualify it on unseen genuine evidence, then continue the internal milestone only from a verified pass. SDK and learned resources remain non-distributed. |
| Current Step | Canceled by the project owner on 2026-08-25. Plans 80-21 and 80-22 will not run; no dataset download, target authoring, training, model conversion, qualification, or public activation is authorized. |
| Constraint | The 2026-08-25 Hugging Face audit found no ready-made exact upper-eyelid-fullness pair set. PPR10K and FFHQR may be considered only for license-compatible non-commercial local research/pretraining; neither supplies the target labels. MirrorPPR47M remains inadmissible because no usable license grant was found. |
| Privacy | Only aggregate counts and normalized reasons may enter repository evidence; media, masks, locators, rights details, and per-fixture rows remain external. |
| Distribution | Swift `public` is owner-local access only. No SDK package, binary, model, compiled weight, private fixture, or derived data leaves the owner-controlled environment; a future scope change requires a new full license/security/product audit. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Confirm genuine origin and internal-evaluation authorization | `completed` | Data owner supplied the authorization fact out of band; no rights record or subject data was persisted. |
| Prepare and structurally admit the private bundle | `completed` | Two deterministic admissions: 8 fixtures, 24 assets, 19 metric rows, zero structural/rights/category failures. |
| Terminate candidate v1 without retuning | `completed` | Aggregate automated texture failure plus the first 100%-detail positive review's weak-effect/block-artifact failure make v1 non-promotable; remaining v1 review was intentionally stopped. |
| Implement and verify candidate v2 mechanics | `completed` | Commit `4cf736c`; focused 24/0/0, full SwiftPM 803/0/8, texture `>=0.98`, post-archive boundary and diff hygiene pass. |
| Freeze candidate v2 qualification contract | `completed` | Plan 80-08 binds the new source/test baseline, 15 Node tests, 13 independent checker probes, boundary-jump `<=5`, feather-to-zero, and a fixed boundary-artifact review field before any v2 private output. |
| Run candidate v2 automation and preserve the decision stop | `completed` | 8 fixtures/24 assets/19 rows; 14 rows passed, adjacent jump and texture failed, review was not opened, deterministic decision remained non-promotion with exact 61/5/74 absence. |
| Implement candidate v3 mechanics | `completed` | Commit `94400c0`; one clipping-safe non-positive contour per eye, existing curved Q16 feather, focused 25/0/0. |
| Freeze candidate v3 qualification | `completed` | 15 Node tests and 15 independent probes bind source/tests/helpers, polarity-correct applicability, the fixed boundary rubric, and exact 61/5/74 absence. |
| Rebuild private v3 bundle and complete blinded review | `completed` | Fresh external run passed 19/19 automated rows twice, but the first positive human checkpoint found no clearly perceptible target reduction. Review stopped and v3 is terminal. |
| Preserve the v3 decision stop | `completed` | No canonical promotion artifact was written; Phase 81 remains ineligible with exact 61/5/74 absence. |
| Implement candidate v4 relief-flattening semantics | `completed` | Plan 80-15 replaces uniform darkening with a smooth boundary-anchored low-frequency convexity correction; focused 30/0/0, full plain SwiftPM 805/0/8, build/boundary/diff gates pass. |
| Freeze candidate v4 qualification | `completed` | Plan 80-16 binds the v4 source/evidence commit, rejects v1-v3 borrowing, freezes contrast-shape and visibility metrics, passes 20 evaluator tests and 18 independent checks, and preserves exact 61/5/74 absence. |
| Terminate candidate v4 at automation | `completed` | Two identical private evaluator runs failed applicability, boundary continuity, and minimum-relief checks; two negatives changed, a positive over-corrected, review never opened, and no promotion artifact exists. |
| Select an implementable learned path before code | `completed` | Plan 80-19 and `80-LEARNED-HYBRID-DECISION.md` reject v5 threshold tuning and freeze the owned-data per-eye applicability/support/flow/tone design, Core ML route, data/license contract, qualification gates, and stop rules. No algorithm source changed. |
| Repair the old code boundary | `completed` | Plan 80-20 quarantines v1-v4 under `BeautyExperimentalUpperEyelid*`, adds the strict package-only prediction validator, passes 8/0/0 learned, 23/0/0 upper-eyelid, plain 813/0/8, archive/boundary/diff checks, and preserves exact 61/5/74 absence. |
| Audit Hugging Face training-data candidates | `completed` | `80-HUGGINGFACE-DATASET-AUDIT.md` finds no ready-made exact target set; it preserves MirrorPPR47M/unknown-license rejection and identifies official PPR10K/FFHQR as research-only pretraining candidates under upstream terms. No third-party portraits were downloaded. |
| Train and qualify the learned path | `canceled` | The owner chose not to continue `去脂`. Plans 80-21 and 80-22 are retained as unexecuted historical proposals; the experimental code and fail-closed prediction seam remain package-only, and exact 61/5/74 public absence is preserved. |

### P-2026-08-14-phase-66-sdk-only-boundary

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Preserve two verified legacy archives, retire exact originals, synchronize current owners to SDK-only SwiftPM, and bind archive/static checks into the mandatory no-skip gate. |
| Current Step | All Phase 66 review findings are remediated and the mandatory integrated gate is green; independent phase verification is next. |
| Verification Policy | Archive/self-test, artifact-only reproduction, post-archive scanner/self-test, bounded transcript self-test, diff hygiene, then one all-opt-ins SwiftPM child with exact XCTest/Swift Testing accounting. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Preserve taxonomy and archive tooling | `completed` | Phase 66 Plan 01 summary and commits. |
| Materialize archives and retire exact originals | `completed` | Phase 66 Plan 02 summary and commits. |
| Synchronize current SDK-only owners/maps | `completed` | Root/current maps plus `docs/README.md` are SDK-only; scanner covers all current owner/map classes and rejects file/directory symlinks. |
| Bind and run full closeout | `completed` | Archive/boundary/transcript self-tests pass; the bounded all-opt-ins child executes 650 tests with zero failures/skips. |
| Remediate Phase 66 code review | `completed` | CR-01..CR-07 and WR-01..WR-03 closed with independent anchors, frozen retirement, safe restore, bounded ZIP/transcript handling, exact runner accounting, symlink rejection, current-map coverage, and mutation tests. |

## 3A. Historical Lifecycle Ledger

> 以下记录均为已完成或已被后续权威取代的执行历史，不是 Active plan。

### C-2026-08-25-defer-upper-eyelid-fullness

| Field | Value |
| --- | --- |
| Status | `canceled` |
| Canceled | 2026-08-25 |
| Decision | Stop all `去脂` data, training, qualification, and activation work. Keep the existing experimental mechanics and fail-closed learned boundary unchanged for possible future research. |
| Public surface | No `upperEyelidFullnessReduction` field, provider, resource, renderer case, or facade route exists. `去脂` remains `future`, aggregate `眼睛` remains `partial`, and the public inventory remains exactly 61 fields / five presets / 74 renderer cases. |
| Preserved capabilities | `teethWhitening` and `scleraRednessReduction` remain independently implemented, directly callable opaque `CIImage` still-image controls; this cancellation does not change their code or contracts. |
| Verification | Teeth/sclera/combined public-facade integration passes 34/34; parameter and public renderer-contract tests pass 74/74; the v1.18 absence binding is rebound to the already-landed Plan-80-20 experimental source/test baseline and passes 15/15 mutation checks plus 13/13 focused tests; the archive-first all-opt-in gate passes 813/0/0 with eight opt-ins exactly once and zero skips. No Swift production source is modified. |

### C-2026-08-25-owner-only-non-distributed-sdk-contract

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-25 |
| Scope | Synchronize every current owner, codebase map, active v1.19 contract, Phase-80 learned/data plan, and local-fixture policy to the user's owner-only, non-distributed SDK decision without rewriting historical attempts, summaries, or archives. |
| Public meaning | Swift `public` remains the callable/compatibility surface for Apps and tools controlled by the owner; it is not a third-party SDK, package registry, binary/customer/App Store, model, or weight release contract. |
| License effect | Actual-use licensing replaces compiled-weight redistribution as the current admission rule. Research-only datasets and their derived models may enter only a separated owner-local non-commercial research lane; internal commercial use still requires an explicit compatible grant. |
| Phase-80 effect | Historical at completion and superseded by `C-2026-08-25-defer-upper-eyelid-fullness`: the Hugging Face audit admitted official PPR10K/FFHQR only as research candidates under upstream terms and kept MirrorPPR47M rejected. Plan 80-21 was subsequently canceled before any source admission, target authoring, training, ablation, or Core ML conversion. |
| Verification | Archive verification passed for both pinned UI ZIPs; `check-sdk-only-boundary.sh --post-archive` passed; `git diff --check` passed; current-owner terminology, stale commercial/redistribution blocker, binary/model diff, and common-secret-pattern scans passed. No Swift source, test, media, model, or historical evidence changed. |

Outcome:

- The project is explicitly private-use and non-distributed while retaining its
  tested Swift access surface for the owner's local host.
- The stricter effect-quality, privacy, exact-target, model-parity, genuine-
  evidence, and blinded-review gates remain intact; only the irrelevant model-
  redistribution gate was removed.

### C-2026-08-22-v1-18-reaudit-remediation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-22 |
| Scope | Closed every actionable v1.18 post-archive re-audit finding while preserving immutable archives, exact public absence, fail-closed genuine-evidence gates, and SDK-only ownership. |
| Findings | F-02 machine decision binding `b45fe59`; F-03 detector-to-composer package integration `2d0f83b`; F-04 source/evidence/test baseline binding `876499a`; F-05 archive-aware exact-once closeout integration `a89e475`. |
| Requirement disposition | F-01 cannot be synthesized: EVID-01/02 remain partial and QUAL-01/02 remain unsatisfied until a complete rights-approved private bundle and blinded review exist under a new authorized scope. Generated fixtures remain mechanics-only. |
| Verification | Decision/baseline gate rejects 15/15 mutations plus seven artifact faults; package integration passes 3/3 and all upper-eyelid tests pass 25/25; wrapper rejects 10/10 order/count/concurrency mutations; parity passes 13/0/0; full archive-first gate passes 800/0/0 with all eight opt-ins exactly once and zero skips. |
| Re-audit | Current score is 14/18 requirements, 5/5 phase artifacts, 6/6 integration, 3/3 flows, and 41/41 threats closed. The safe result remains `mechanics-only-not-promotion` with exact 61/5/74 public absence. |

Outcome:

- All code- and gate-actionable findings are repaired and independently bound.
- The current ledger no longer treats absent genuine evidence as completed.
- No archived milestone artifact, production public API, package dependency,
  backend, resource, or retained `Warp.metal` implementation changed.

### C-2026-08-19-project-automated-validation-policy

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-19 |
| Scope | Established deterministic SDK-owned script/code image input-output validation as the standing milestone authority and made physical-iPhone testing optional post-SDK user feedback that cannot block plan progression. |
| Requirements | `PROJECT-VALIDATION-01` through `PROJECT-VALIDATION-07` now govern current and future SDK milestones without changing historical v1.17 traceability. |
| Contract | Image-producing work validates applicable pixels, dimensions/extent, orientation/mirroring, color/alpha metadata, neutral identity, intended/protected regions, bounded tolerances, determinism, and typed failures. Rights-approved private fixtures remain script-driven when an algorithm owner requires them. |
| Device policy | Missing or delayed physical-iPhone access/user feedback is not a failure, skip, gate, dependency, or blocker. Reproducible post-SDK feedback becomes a follow-up automated regression where possible. |
| Nonclaims | Without separately authorized hardware/product evidence, completion does not claim device performance, thermals, battery, endurance, commercial visual quality, packaging, shipping, launch, or release readiness. |
| Verification | SDK-only boundary self-test and post-archive scan passed; archive-first `run-no-skip-swiftpm.sh` passed `776/0/0`, all eight opt-ins exactly once, with `skipped_tests=0`; policy consistency and diff-hygiene scans passed. |

Outcome:

- Project instructions, requirements, product, quality, reliability, security,
  roadmap/state, and testing guidance now carry one automation-first contract.
- No production code, scripts, fixtures, or archived milestone evidence changed.

### C-2026-08-22-phase-75-semantics-and-genuine-evidence-contract

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-22 |
| Scope | Freeze the cosmetic upper-eyelid fullness semantics, independent prohibited-proxy rejection, rights/category manifest admission, frozen metric/review rubric, privacy-safe aggregate evaluator, and exact public absence before support/editor work. |
| Plans | `75-01-PLAN.md` owns semantic records plus the exact-absence/threat checker; `75-02-PLAN.md` owns the rights/evidence contract, metadata-only evaluator, and evidence tests. |
| Requirements | SEM-01 and SEM-02 are complete. The historical phase record marked EVID-01/02 complete as contract mechanics, but the current post-archive re-audit follows Plan 75's explicit no-bundle pending rule and classifies both partial until a complete rights-approved bundle exists. |
| Verification | Semantic/evidence Node suites pass `8/8`; evaluator self-test passes `10` checks with `7` mutation rejections; evaluator validate/aggregate/export pass on a temporary metadata-only manifest; missing bundle returns typed `evidence.missing-bundle`; exact absence and T-75-01..08/T-75-SC all pass; `git diff --check` passes. |
| Boundary | No production Swift, public field, renderer case, preset, resource, package dependency, route, provider, or Testing SPI changed. No genuine efficacy/naturalness/device/commercial/release claim is made. |

Outcome:

- Phase 75 establishes the auditable semantic and evidence authority for later
  support/editor/evaluation phases while preserving exact 61/5/74 absence.
- No rights-approved genuine bundle is present in the workspace; metadata-only
  checks prove mechanics only and cannot authorize promotion or tuning.

### C-2026-08-22-phase-76-per-eye-semantic-support-ownership

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-22 |
| Scope | Add package-only independent per-eye semantic support ownership from one shared mapped observation, source-exact composition handoff tests, and mutation/privacy/compatibility closeout gates. |
| Plans | `76-01-PLAN.md` owns typed support outcomes and adversarial isolation; `76-02-PLAN.md` owns single-observation routing, composition handoff, and Phase-76 checker. |
| Requirements | SUP-01 and SUP-02 are complete for the internal fail-closed support contract. |
| Verification | Focused suite `52/0` with 3 existing opt-in skips; semantic suite `10/0`; checker self-test `8/8` mutation rejections; live checker passed; full archive-first no-skip gate `790/0/0`; `git diff --check` passed. |
| Boundary | No public field, route, renderer case, preset, resource, package dependency, provider, or Testing SPI was added. No genuine efficacy/naturalness/device/commercial/release claim is made. |

Outcome:

- Each eye now has independent typed support or source-exact no-op from one
  request-local observation, and overlap is returned to immutable source bytes.
- The exact 61-field/5-preset/74-renderer public surface remains absent until
  the Phase-78 evidence decision and Phase-79 branch.

### C-2026-08-22-phase-77-deterministic-fullness-editor

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-22 |
| Scope | Add a package-only bounded source-derived low-frequency editor with original high-frequency residual carry, then prove source-owned composition and protected-region safety. |
| Plans | `77-01-PLAN.md` owns the deterministic editor and pixel equation; `77-02-PLAN.md` owns composition safety, mutation/privacy checks, and no-skip closeout. |
| Requirements | ALG-01, SAFE-01, and SAFE-02 are complete for generated mechanics and source-owned safety only. |
| Verification | Editor/safety focused suite `7/0`; checker self-test `8/8` mutation rejections; live checker passed; full archive-first no-skip gate `797/0/0`; `git diff --check` passed. |
| Boundary | No public field, route, renderer case, preset, resource, Metal/API/backend, provider, or Testing SPI was added. No genuine efficacy/naturalness/device/commercial/release claim is made. |

Outcome:

- The deterministic candidate produces bounded proposals only for approved
  per-eye support; rejected/exterior/protected/overlap pixels remain owned by
  immutable source composition.
- Phase 78 remains the genuine-evidence and candidate-decision gate; absence of
  a rights-approved bundle cannot be replaced by generated mechanics evidence.

### C-2026-08-17-phase-74-cpu-gpu-parity-and-sdk-only-closeout

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-17 |
| Scope | Close generated CPU/GPU parity, safety, determinism, request-local selection, explicit Metal availability classification, and the SDK-only archive-first no-skip milestone gate while retaining CPU as the reference. |
| Plans | `74-01-PLAN.md` owns generated structural/numeric parity; `74-02-PLAN.md` owns safety and failure isolation; `74-03-PLAN.md` owns determinism, concurrency, and unavailable-host separation; `74-04-PLAN.md` owns the mutation-tested parity gate and no-skip integration; `74-05-PLAN.md` owns current owners and milestone ledgers. |
| Requirements | PARITY-01, PARITY-02, PARITY-03, CLOSE-01, and CLOSE-02 are complete. |
| Contract | Generated fixtures enforce exact neutral bytes/dimensions, bounded active tolerances, alpha/metadata/extent, outside-region and containment safety, collision/no-face/degraded/failure isolation, repeated determinism, request-local CPU/GPU policy, and typed `.metalUnavailable` separation. |
| Verification | Focused parity passes `12/0/0` with `metal_available=1` and `metal_unavailable=0`; archive-first `run-no-skip-swiftpm.sh` passes `765/0/0`, executes all eight opt-ins exactly once, and reports zero skips/failures; archive, SDK-only boundary, mutation self-tests, and diff hygiene pass. |
| Handoff | v1.17 SDK-only parity closeout is complete. Future work remains separately scoped for new algorithms, UI/Demo, simulator/device, performance, commercial, packaging, shipping, launch, and release readiness. |
| Nonclaims | No device, physical-host, performance-budget, commercial visual approval, packaging, distribution, shipping, launch, or release-readiness claim follows from these package-host tests. |

Outcome:

- All five Phase-74 requirements are closed against generated SwiftPM evidence and
  current-owner documentation.
- The retained CPU implementation remains the compatibility oracle; GPU
  availability is explicit and never borrows CPU success.

### C-2026-08-17-phase-73-public-backend-configuration-and-fail-closed-availability

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-17 |
| Scope | Expose the public `.cpu`/`.gpu` execution policy, preserve CPU and legacy Codable defaults, route requests through an immutable package factory, and fail closed with typed `.metalUnavailable` without CPU fallback. |
| Plans | `73-01-PLAN.md` owns the 11-field configuration contract; `73-02-PLAN.md` owns public engine routing and unavailable-GPU integration; `73-03-PLAN.md` owns mutation/static configuration gates and archive-first no-skip integration; `73-04-PLAN.md` owns current owner and ledger synchronization. |
| Requirements | CONFIG-01 and CONFIG-02 are complete against the public configuration/routing tests and the full SDK-owned gate. |
| Contract | `BeautyConfiguration.renderBackend` has exactly `.cpu` and `.gpu`; new and missing legacy keys decode to `.cpu`; `BeautyBackendFactory` selects one immutable policy per request; explicit unavailable GPU returns terminal `.metalUnavailable` and never silently executes CPU. |
| Verification | Configuration focused gate passes `16/0/0`; Metal runtime focused gate passes `34/0/0`; static/self-tests and SDK-only boundary pass; full `bash scripts/run-no-skip-swiftpm.sh` executes `753/0/0`, all eight opt-ins exactly once, with `metal_available=1` and `metal_unavailable=0`. |
| Handoff | Phase 74 owns generated CPU/GPU parity, deterministic/tolerance evidence, and final SDK-only closeout; no parity or release claim follows from configuration evidence alone. |
| Nonclaims | No new algorithm, UI/Demo behavior, simulator or physical-device validation, performance, commercial approval, packaging, shipping, launch, or release-readiness claim. |

Outcome:

- CONFIG-01/02 are closed and all current owners describe the retained CPU
  reference plus selectable GPU and typed fail-closed availability policy.
- Phase 74 subsequently closed generated CPU/GPU parity and milestone closeout;
  this historical record does not carry a current active-work claim.

### C-2026-08-16-phase-72-plan-01-metal-color-passes

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-16 |
| Scope | Add the package-only bounded Metal pass graph and implement the shipped color/skin family using retained CPU semantics. |
| Requirements | `METAL-02` completed; geometry and local-retouch semantics remain with Plans 72-02 and 72-03. |
| Implementation | `BeautyMetalPass` carries finite primitive color/warp/composed-retouch data; `BeautyMetalRuntime` encodes ordered private-texture ping-pong; `BeautyMetalBackend` maps CPU coefficients and bridges BGRA/RGBA. |
| Verification | Color/CPU/backend/runtime focused coverage passes `27/0/0`; feature-pass preflight passes `22/0/0`; full SwiftPM passes `735/0/8`; Metal available/unavailable is classified separately. |
| Nonclaims | No public backend selector, new parameter/preset/algorithm, UI/Demo behavior, device/performance, commercial, packaging, shipping, launch, or release-readiness claim. |

Outcome:

- METAL-02 is implemented and independently gated. Plans 72-02 and 72-03 can consume the bounded geometry and composed-retouch contracts without changing public schemas or runtime ownership.

### C-2026-08-16-phase-71-sdk-owned-metal-runtime

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-16 |
| Scope | Close METAL-01 for package-owned bounded Metal runtime mechanics while preserving the CPU reference and deferring feature passes, public configuration, and parity. |
| Plans | `71-01-PLAN.md` owns the runtime transaction; `71-02-PLAN.md` owns the internal executor boundary; `71-03-PLAN.md` owns the mutation-tested preflight and synchronized owners; `71-04-PLAN.md` owns measured closeout and ledgers. |
| Requirement | METAL-01, owned exactly by the four Phase-71 plans above. |
| Runtime ownership | `BeautyRender` owns package-only device, command queue, pipeline, request-local RGBA8 textures/buffers, command synchronization, terminal status, and deterministic cleanup. `BeautyEffects` owns one internal `.metal` boundary invocation with no CPU alternate path. |
| Availability | Final preflight records `metal_available=1` and `metal_unavailable=0` as separate aggregate classifications; unavailable execution remains an explicit fail-closed outcome and is not success or parity evidence. |
| Verification | `check-metal-runtime.sh --self-test` and live preflight pass with focused `26/0/0`; post-archive SDK-only boundary and no-skip self-test pass; `run-no-skip-swiftpm.sh` executes `728/0/0`, with eight opt-ins exactly once and no skips. Runtime cleanup and terminal-error paths are represented by bounded aggregate counters/status only. |
| Source audit | GOAL is covered by Plans 71-01..04; REQ `METAL-01` is covered by all four plan frontmatters and this completion ledger; RESEARCH is excluded because research is disabled by configuration and no research artifact exists; CONTEXT is excluded because no phase context artifact exists and there are no locked decisions or deferred ideas to implement. |
| Handoff | Phase 72 owns Metal feature passes; Phase 73 owns public `.cpu`/`.gpu` configuration and typed availability policy; Phase 74 owns generated parity and SDK-only closeout. |
| Nonclaims | This record adds no public `.gpu` selector, feature-pass parity, new algorithm, UI/Demo lifecycle, simulator or physical-device validation, performance, commercial approval, packaging, shipping, launch, or release-readiness claim. |

Outcome:

- The archive-first evidence closes the package-only runtime ownership requirement and transitions the active milestone to Phase 72.
- CPU remains the reference. Device/performance/release evidence and all later-phase behavior remain explicitly outside this closeout.

### C-2026-08-15-phase-70-backend-neutral-contract-and-cpu-reference

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-15 |
| Scope | Route the retained CPU implementation through one package-only backend-neutral request/result boundary; preserve public schemas, presets, algorithms, and SDK-only ownership. |
| Plans | 70-01 defined the validated contract and synchronized owners; 70-02 added the stateless CPU executor, one-dispatch facade routing, focused regression coverage, and the mutation-tested archive-first gate. |
| Verification | Backend preflight self-test/live scan pass; focused contract/CPU/routing coverage is 11/0/0; generated CPU preflight is 41/0/0; the archive-first no-skip wrapper completes with 8 opt-ins, 0 skips, and 0 failures. |
| Compatibility | The gate confirms 61 parameter fields, five preset IDs, 74 renderer cases, unchanged public configuration, and retained deterministic CPU semantics. |
| Nonclaims | No public GPU selection, Metal execution, UI/Demo, device, performance, commercial, packaging, shipping, launch, or release-readiness claim follows from Phase 70. |

### C-2026-08-13-adversarial-sclera-review-remediation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Trigger | 对 `v1.15..HEAD` 的对抗式复核发现：Full Sclera 的两点红色准入可放大为整眼孔径编辑、composition owner 的单元预算在大数组分配后才拒绝、真实素材编辑面积使用了较宽松上限、根级契约仍混用 Focal 与 Full 的 mask-escape 语义。 |
| Implementation | 最终提案同时受几何和颜色资格约束：饱和度 `<= 0.48`、巩膜 likelihood `>= 0.20`，权重乘以 likelihood，blur 后重新硬裁剪；material gate 改为 `max(3, ceil(0.5% * qualifiedPixelCount))` 且至少有一个 3 像素 8-连通片。Transform 重复饱和度门禁。 |
| Resource bound | Composition owner 提供无分配 capacity preflight；Full Sclera 在 raster/mask 数组创建前用整个眼部 grid 作为 proposal 上界，超预算的有效支持按眼拒绝。 |
| Evidence repair | 新增两点放大、已准入眼内彩色物、超大有效工作区、绝对/相对面积上限四个回归；真实正例总编辑门禁使用 `min(12_000, 1%)`。Focal 的 zero-mask-escape 与 Full 的 anchor-expansion 契约已在 Design/Security/Reliability/Product/Quality owner 中分开。 |
| Verification | Full provider 7/7、composition 23/23、Full adversarial 6/6、Engine sclera integration 9/9、retained Focal 15/15；授权正/负素材 2/2；默认完整 SwiftPM 650 tests、8 个文档化 opt-in skips、0 failures；`scripts/run-no-skip-swiftpm.sh` 在 pinned Apple Vision host 执行同一 650 tests、8/8 opt-in、0 skips、0 failures。`git diff --check` 与最终隐私/调试扫描通过。 |
| Supersedes | 本记录取代 `C-2026-08-11-full-sclera-redness` 中“两像素准入”和仅写作“最多 1%”的当前权威；旧行保留为实现当日的历史证据。 |
| Boundary | 仅修复 still-image SDK core 的既有 Full Sclera 行为；不扩展 Demo、实时、pixel buffer、模型、网络或发布范围。 |

### C-2026-08-11-full-sclera-redness

| Field | Value |
| --- | --- |
| Status | `completed` |
| Trigger | User review found that the focal redness mask changed only small islands and did not cover the full visible U-shaped sclera; the medial tear duct/caruncle must remain excluded. |
| Strategy split | Commit `4271ddc` preserves the prior behavior as `BeautyFocalScleraRednessProvider` / `Transform` and its 15-test suite. The stable facade now routes to the separate `BeautyFullScleraRednessProvider` / `Transform`; the public parameter is unchanged. |
| Implementation | Full Sclera validates per eye, builds the eye aperture, subtracts pupil/iris, native dark iris, highlights, a boundary-only lash band, exterior/lid margin, and a medial caruncle guard, then uses material redness only for admission. An accepted eye receives a `0.56` broad geometry mask plus redness boost, hard re-clipping, bounded `0.76 / 0.08 / 0.13` correction, and `0.028` maximum luminance lift. |
| Admission and negative | At least two geometry-safe pixels must score `>= 0.50` on the weighted-red smoothstep. The authorized normal negative and caruncle-only synthetic input remain exact no-ops. The former reviewed mask is retained as a Focal anchor; intentional Full Sclera expansion beyond it is bounded to at most 1% of image pixels and protected by the full anatomy oracle. |
| Output evidence | Fresh public no-watermark output changes 4,599 visible pixels versus the prior Focal evidence's 203, split 2,387/2,212 across image halves. Maximum channel delta is 36/255 and mean weighted red excess on changed pixels falls 76.46%. Ignored input/output/mask/overlay artifacts live under `example-images/local-retouch-review/full-sclera-remediation-20260811/`. |
| Safety evidence | The bilateral recolored oracle adds caruncle to iris, pupil, highlight, lash, skin, and aperture-exterior families. Across 1,648 protected pixels it records zero proposal intersection and zero RGBA mismatch; caruncle alone cannot admit the eye. |
| Research rationale | Ocular-redness literature treats visible ocular-surface segmentation and iris segmentation as separate ROI owners, then measures redness globally or regionally inside the remaining conjunctival ROI. This supports aperture-minus-iris geometry for extent and redness for admission/strength rather than using red islands as the whole mask. |
| Verification | Focal/Full/provider/integration/adversarial/private tests pass 35/35; combined teeth+sclera closeout passes 13/13; opted-in authorized positive/negative passes 1/1; full SwiftPM passes 645 tests with eight documented opt-in skips and zero failures. `git diff --check` and privacy/debug scans pass. |
| Boundary | Post-archive work on `codex/full-sclera-redness`; archived `v1.15` remains immutable. Still-image SDK core only, with no Demo/realtime/pixel-buffer/model/network, population/device/commercial, packaging, shipping, launch, or release-readiness claim. |

### H-2026-08-11-sclera-visible-effect-remediation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Trigger | A fresh exact-`v1.15` rerender and user screenshot proved the archived positive changed only 33 pixels on one image half with maximum channel delta 2/255, so the prior nonzero gate did not establish a visible result. |
| Implementation | Current `main` uses weighted conjunctival redness `R - 0.83G - 0.17B`, one provider-owned material gate, bounded soft-mask gain, `0.76 / 0.08 / 0.13` channel correction, and a local luminance lift capped at `0.018`. The native-Vision pupil support fraction is `0.035`; newly admitted offsets receive one extra pixel of lid erosion while the calibrated iris/pupil exclusion remains unchanged. The natural negative calibrates the edit floor to `0.045` and is exact. |
| Output evidence | Fresh public-facade positive output changes 203/1506 reviewed-mask pixels (`13.479%`), split 136/67 across image halves, with zero outside-mask changes, maximum channel delta 34/255, mean changed-pixel absolute RGB delta 8.494 bytes, weighted redness reduced `38.46%`, and reviewed-mask mean luminance delta `0.001069`. The authorized negative has zero proposals/output changes. Ignored local input/output/mask/change overlays live under `example-images/local-retouch-review/sclera-visible-remediation-20260811/`. |
| Regression contract | The private positive now requires at least `max(100, 8%)` reviewed-mask changes, at least 20 per image half, maximum channel delta `20...44`, at least 20% weighted-red reduction, bounded luminance/texture/alpha, and zero RGB mask escape. The private negative requires exact output. The transform unit test has a minimum material-red movement so byte-noise cannot satisfy the gate. |
| Verification | `BeautyScleraRednessProviderTests` passed 15/15, `BeautyEngineScleraRednessIntegrationTests` 9/9, `BeautyScleraRednessAdversarialCloseoutTests` 6/6 with zero protected intersection/mismatch, the opted-in private real-fixture gate 1/1, and full SwiftPM 641 tests with zero failures and eight documented opt-in skips. The renderer rebuilt/reran the public `scleraRednessReduction_1p00` case; `git diff --check` and ignored-artifact checks passed. |
| Boundary | This is post-archive remediation on current `main`; the `v1.15` tag/archive is unchanged. No Demo/realtime/pixel-buffer/model/network expansion or population/device/commercial/release-readiness claim is added. |

<!-- PHASE65_FINAL_OWNER_BEGIN -->
owner: PLANS_ARCHIVED
phase: 65
milestone: v1.15
public_fields: 61
neutral_presets: 5
renderer_cases: 74
disabled_demo_rows: 3
teeth: implemented
mouth: implemented
sclera_redness: implemented
eyes: partial
eye_fat: future
safe_06: closed
lifecycle: archived
release: non-release
<!-- PHASE65_FINAL_OWNER_END -->

This is the final historical Phase 65 disposition. Archive/tag lifecycle does
not imply distribution, shipping, launch, commercial approval, or release
readiness.

### H-2026-08-08-v1-15-phase-64-terminal-r2-closeout

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Canonically close Phase 64 through the exact-six terminal transition while preserving the bounded SDK-core sclera scope. |
| Finding | The immutable Plan 64-12/13 and Plan 64-18/19 candidate/failure sequences remain historical evidence. Plan 64-20 repaired the terminal contract and issued the distinct source-bound R2 candidate; Plan 64-21 authenticated all fifteen owners, nineteen sources, six authority artifacts, fifteen probes, and eight threats before changing every one and only the six mutable final owners. |
| Affected requirements | SCLERA-14 through SCLERA-18 and OUT-05 are canonically verified. Product/root owners remain byte-identical to the candidate; Phase 65 is unblocked/current only for fresh verification and audit. |
| Fresh passing evidence | Focused 74/74; strict helper 14/14; private output 6/6 plus four opaque review items; checker/no-skip self-tests; exact full SwiftPM 637/0/0/8; Demo build and 121/0/0; exact 19-source review; zero-HIGH code review; ASVS L1 8/8. Green aggregates do not self-authorize canonical success. |
| Warning | The earlier renderer DeviceRGB evidence gap was not Phase 64 credit; Phase 65 now replaces that path with named-sRGB saved output and strict PNG metadata rejection. |
| Next | Phase 65 fresh verification and the formal 40/40 milestone audit passed; v1.15 was later archived after both audit debts closed. |
| Lifecycle | Phase 64 is canonically `passed` and complete. Phase 65 and OUT-09 are freshly verified through the bound audit. |
| Inventory | Exact authority is 21 serial plans / 38 ordered and accounted task IDs. Historical `64-13-01` and `64-19-01` remain failed/superseded evidence rather than current failures; `64-21-01` is final passed. |
| Boundary | No archive, tag, cleanup, shipping, or milestone-completion claim is authorized by the Phase 64 transaction. Product-facing `祛红血丝` is bounded SDK-core implemented, `眼睛` remains `partial`, and `去脂` remains `future`. Phase 65 independently closes named-sRGB; Demo activation/realtime/model/network/device/performance/commercial/packaging/shipping/launch/release scope remains excluded. |

<!-- PHASE64_TERMINAL_LIFECYCLE_BEGIN -->
Phase 64 terminal lifecycle: canonical final passed through the exact-six
mutable-owner transition; 21 plans and 38 ordered task IDs are accounted.
Fresh Phase 65 verification follows this authority and independently closes
SAFE-06 with named-sRGB facade and saved-PNG evidence. The separate bound
milestone audit closes OUT-09 at 40/40.
<!-- PHASE64_TERMINAL_LIFECYCLE_END -->

Phase 65 is freshly re-verified and independently audited. v1.15 is archived;
distribution, shipping, launch and release-readiness remain separate scopes.

Exact ordered Phase 64 task authority is: `64-01-01`, `64-01-02`,
`64-02-01`, `64-02-02`, `64-03-01`, `64-03-02`, `64-04-01`, `64-04-02`,
`64-05-01`, `64-05-02`, `64-06-01`, `64-06-02`, `64-07-01`, `64-07-02`,
`64-08-01`, `64-08-02`, `64-09-01`, `64-09-02`, `64-10-01`, `64-10-02`,
`64-11-01`, `64-11-02`, `64-12-01`, `64-13-01`, `64-14-01`, `64-14-02`,
`64-15-01`, `64-15-02`, `64-16-01`, `64-16-02`, `64-17-01`, `64-17-02`,
`64-18-01`, `64-19-01`, `64-20-01`, `64-20-02`, `64-20-03`,
`64-21-01`. Waves 1 through 21 are strictly serial.

### H-2026-08-05-v1-15-independent-teeth-sclera-retouch

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Historical implementation execution record for bounded still-image SDK-core `白牙` then `祛红血丝`; its Phase 64/65 product and lifecycle conclusions are superseded by the later terminal R2 closeout and fresh Phase 65 authority above. |
| Evidence | Separate genuine teeth and sclera pairs, standalone 6/6 output matrices, private native-Vision gates, original-detail reviews and exact product promotions pass without borrowed sibling credit. |
| Combined | Both public facade entries pass independent standalone merge, collision-to-source, four failure units, no-stale recovery and unrelated-work preservation. |
| Verification | Historical result: full SwiftPM 630/0/8; Demo build plus 121/0/0; focused 94/94; checker HIGH 8/8; separate audit 40/40 requirements, 12/12 seams and 7/7 flows. The result is stale for current authority. |
| Product | Historical snapshot only: `白牙` and aggregate `嘴唇` were implemented while `祛红血丝` still awaited terminal proof. Current product authority is the Phase 65 owner block, not this row. |
| Boundary | Historical blocked state only. The later terminal R2 and Phase 65 records resolved it; no Demo activation, realtime/pixel-buffer, population/device/performance/commercial approval, model/network, packaging, shipping, launch, archive, tag or release claim came from this record. |

### H-2026-07-30-v1-14-local-facial-retouch

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Milestone v1.14 establishes an SDK-SPM still-image local-retouch boundary and independently qualifies `白牙`, `祛红血丝`, and conditional `去脂` without adding SwiftUI/Demo, realtime/pixel-buffer, cloud, external-model, tracked-media, or release-readiness scope. |
| Requirements | 41/41 requirements are uniquely mapped across canonical input/compatibility, rights-approved evidence, original-pixel composition, teeth, sclera, conditional upper-eyelid fullness, privacy/safety, public output, and exact promotion. |
| Roadmap | Phase 53 canonical request foundation → Phase 54 evidence/eligibility decisions → Phase 55 composition core → Phase 56 independent teeth slice → Phase 57 guarded sclera plus conditional eyelid work → Phase 58 combined facade/safety/ledger/audit closeout. |
| Feature gates | Teeth and sclera are independent peer slices. `去脂` requires genuine rights-approved positives/negatives plus a credible non-warp method; a closed gate adds no field, provider, renderer case, or inert route and keeps branch `眼睛` partial. |
| Current evidence | The long-term authorized `p1.jpg` is usable for teeth containment and over-whitening review but is not a yellow-teeth, sclera-redness, or upper-eyelid-fullness positive. Feature promotion requires complete feature-specific positive/negative bundles and original-detail review. |
| Next | Completed: the separate v1.14 milestone audit passed and the milestone was archived and tagged `v1.14`; no visible product promotion was inferred. |
| Phase 57 discussion | Auto-discuss resolves both independent Phase 54 rows to exact conditional false branches: `scleraRednessReduction` and `upperEyelidFullnessReduction` remain absent; SCLERA-02..05 plus LID-03/LID-05 are `not_applicable_closed_gate`; SCLERA-06 is `no_promotion`; LID-04 actively rejects coupling to `eyeHeight`, `upperEyelidLift`, brow/warp, smoothing, eye-bag, or dark-circle proxies. The exact disabled `祛红血丝`/`去脂` Demo rows, both future ledger rows, and branch `眼睛 = partial` remain unchanged. No file selection, browser/image review, human checkpoint, or production/inert route is authorized. |
| Phase 57 Wave 0 exact absence | Plan 57-01 extends the existing SDK/Demo owners without changing production: focused SwiftPM passes 101/101 with exact 59 fields, five presets, 72 renderer cases, literal `.none`, both still entries, shipped proxy-only behavior, and zero pixel-buffer/reset local work; focused iPhone 17e/iOS 26.5 Demo passes 29/29 while preserving the exact disabled `eyes.fat`/`去脂` and `eyes.redness`/`祛红血丝` rows with nil active mappings. The configurable whole-source checker compiles, accepts clean and legitimate proxy-only fixtures, passes nine representative aggregate mutation/scanner cases, and every T-57-01…08 HIGH identity passes independently with fixed rule-only output. Production source, Phase 54 authority, ledgers, evidence status, media, browser/file review, and requirement owners remain unchanged. |
| Phase 57 Wave 1 authority and sclera closure | Plan 57-02 enforces the immutable full Phase 54 ledger while selecting the independently closed sclera/upper-eyelid rows by exact identity: T-57-01 passes 65 live malformed/shape/type/reason/zero/aggregate/competing/borrowing/input/scanner cases. Whole-production T-57-02 passes 32 public/Codable/Testing/admission/provider/renderer/preset/resource/package/network/storage/Demo/realtime/pixel-buffer/reset plus eight synonym-family and eight alias-target mutations. The aggregate checker passes 104 cases and clean live mode passes. `57-CLOSED-EYE-GATES-EVIDENCE.md` remains explicitly draft with later HIGH/final gates pending; production, Demo behavior, Phase 54 authority, ledgers, validation, requirement owners, media, browser/file review, and root contract owners remain unchanged. |
| Phase 57 Wave 2 complete eye-gate matrices | Plan 57-03 completes T-57-03 through T-57-08 with per-threat totals `27 / 19 / 19 / 33 / 7 / 18`; the whole checker passes 220 aggregate cases and live mode. Upper-eyelid canonical/fullness/fat/defatting routes fail across complete production and supplemental surfaces, and candidate-to-`eyeHeight`/`upperEyelidLift`/brow/aperture/warp/smoothing/dark-circle/eye-bag/sibling/teeth/opaque-mechanics relations fail while proxy-only source remains green. Focused SwiftPM passes 101/101 and focused iPhone 17e/iOS 26.5 Demo passes 29/29. Evidence is structurally complete but remains draft; Plan 57-04 still exclusively owns full regression, GSD, traceability, validation, requirements, and root-owner promotion. No production, ledger, media, browser/file/image review, or human checkpoint was added. |
| Phase 57 final closed eye-gate closeout | Plan 57-04 validates 7/7 task rows, 10/10 exact conditional dispositions, D-57-01..20 20/20, and T-57-01..08 8/8. Final focused SwiftPM passes 141/141; after independent verification-gap hardening the checker passes 519 aggregate cases with per-threat totals `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42` plus clean decision/live modes. The 44 sclera and 74 upper-eyelid identities cover camelCase, snake_case, dotted Demo IDs, and owned Chinese labels, and all 118 identities receive a neutral-file proxy-relation mutation. Full SwiftPM passes 544 executed with six opt-in Vision skips; explicit iPhone 17e/iOS 26.5 Demo build passes and tests pass 120/120. Schema/UI/decision/post-plan/diff gates pass; codebase drift is only the historical `PRODUCT_SENSE.md`, `example-images`, and `meituxiuxiu` warning set. Production remains literal `.none` with exact 59/5/72, both still facades, two disabled Demo rows, future/future/partial ledgers, and LID-04 proxy rejection. No production feature, browser/file/image review, algorithm, effectiveness/naturalness, device/performance, commercial, packaging, shipping, launch, or release claim is added. Independent review and verification remain the phase lifecycle owners before Phase 58. |
| Phase 57 independent verification | Canonical re-verification passes 12/12 must-haves and 10/10 conditional requirements after the neutral-file identity gap was closed. All previously accepted snake-case, Chinese, dotted-ID, and candidate-to-proxy mutations now fail closed; exact 44+74 identity inventories agree across the checker and four Swift owners, aggregate 519/519 and per-threat `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42` are green, and no human/image verification is required. Phase 57 is complete; Phase 58 owns only combined facade, safety, ledger, and audit closeout without reopening any closed feature gate. |
| Phase 58 discussion | Autonomous smart-discuss locks D-58-01..20: the admitted visible feature set is empty; OUT-01/OUT-02 are exact not-applicable absence proofs; SAFE-01..03, OUT-03, and OUT-04 remain affirmative automated obligations; opt-in Vision must execute all six existing tests; product promotion is zero rows; Phase 57's frozen checker stays unchanged while a new strict completed-state audit validates the Phase 58 lifecycle. No file/browser/image/human review, production feature route, TD-013, or release claim is authorized. |
| Phase 58 Plans 58-01/58-02 | Wave 0 froze the zero-admission boundary and eight-HIGH inventory; Wave 1 completed request-local lifecycle/publication-discard coverage plus exact T-58-01..06 authority, privacy, compatibility, output-absence, and zero-promotion matrices. Focused lifecycle SDK passes 60/60; closeout checker self-test passes 251/251 with live/decision modes green. Demo build and full simulator test pass on iPhone 17e/iOS 26.5; the historical codebase-drift warning remains nonblocking. Full SwiftPM, opt-in Vision, final owner evidence, review, verifier, and milestone audit remain Plan 58-03/58-04 scope. |
| Phase 58 Plan 58-03 | The strict adapter preserves the frozen Phase 57 checker at revision `4125b75`, requires current green modes plus exact `R57-COMPAT`, and reproduces the verified pre-transition 519-case/per-threat fixture. Phase 58 audit self-test passes 276 aggregate cases with per-threat `80 / 33 / 37 / 34 / 28 / 31 / 25 / 8`; decision, lifecycle, live, eight HIGH modes, fixed Vision-summary classifier, byte equality, and evidence gates pass. Evidence was draft at that point; full SwiftPM, opt-in Vision, final Demo/owner/review/verifier, phase transition, and milestone audit remained Plan 58-04/external lifecycle scope. |
| Phase 58 Plan 58-04 | Final automated closeout passes focused/full SDK, exact opt-in Vision `6/0/0`, full iPhone 17e/iOS 26.5 Demo `120/0/0`, Phase 53–58 checkers, eight HIGH modes, GSD schema/UI/decision/traceability/diff, owner equality, and exact historical codebase-drift classification. Evidence/validation are validated with zero admission/promotion; adversarial code review/fix is clean after the checker hardening (`703/0/0` targeted recheck, per-HIGH `288 / 42 / 38 / 34 / 233 / 31 / 29 / 8`); independent verification passes `12/12`; the separate milestone audit remains the only lifecycle owner. |
| Phase 56 discussion | Auto-discuss resolves the independently closed teeth decision as the only valid Phase 56 branch: `teethWhitening` stays absent, TEETH-02…05 are explicitly not-applicable rather than claimed implemented, TEETH-06 records unanimous no-promotion, `白牙` remains a disabled future taxonomy row, and branch `嘴唇` remains partial. No file selection, human image review, provider/transform/renderer/preset/Demo activation, or inert route is authorized. |
| Phase 56 planning | Three serial plans contain five exact task/validation owners: Wave 0 freezes SDK/facade/59-5-72 exact absence plus the disabled Demo row and seven-row HIGH checker inventory; Wave 1 enforces the immutable Phase 54 closed teeth row and complete real-fixture activation/alias/Demo/ledger/privacy mutations; Wave 2 alone runs full SwiftPM, explicit Demo, GSD, traceability, evidence, validation, and owner closeout. TEETH-01..06, D-56-01..16, and T-56-01..07 are fully mapped; TEETH-02..05 remain `not_applicable_closed_gate`, TEETH-06 remains `no_promotion`, and no browser/file/human review or production teeth route is planned. |
| Phase 56 Wave 0 exact absence | Plan 56-01 extends the existing SDK/Demo owners without changing production: focused SwiftPM passes 96/96 with exact 59 fields, five presets, 72 renderer cases, literal `.none`, both still entries, unrelated color continuation, and zero pixel-buffer/reset local work; focused iPhone 17e/iOS 26.5 Demo passes 28/28 while preserving the exact disabled `lips.teeth` / `白牙` row and nil active mapping. The Phase 56 checker compiles, accepts live fixtures, passes 21 aggregate self-test cases, and each T-56-01…07 representative mutation passes independently with fixed rule-only output; missing fixtures and unclassified scanner outcomes fail closed. No production source, evidence status, product ledger, media, browser/file review, or requirement owner was promoted. |
| Phase 56 final closed-gate closeout | Plan 56-03 validates all 5/5 task rows, TEETH-01..06 6/6 conditional dispositions, D-56-01..16 16/16 decisions, and T-56-01..07 7/7 HIGH mitigations. After review fixes `0f411b5`, `89cf570`, and `5235f0c` plus verification fix `8cf422f`, focused SwiftPM passes 96/96, focused Demo passes 28/28, and the structurally hardened checker passes 111 aggregate cases with per-threat totals `38 / 32 / 22 / 23 / 31 / 19 / 24` plus live 59/5/72. T-56-02/T-56-03 now scan every production Swift file and reject a neutrally named enamel/dentition provider alias. Full SwiftPM passes 539 executed with six opt-in Vision skips; explicit iPhone 17e/iOS 26.5 Demo build passes and tests pass 119/119. Schema/UI/diff/traceability gates are green; codebase drift is only the historical `PRODUCT_SENSE.md`, `example-images`, and `meituxiuxiu` warning set. Production admission remains literal `.none`, 59/5/72 and both still facades remain exact, `白牙` stays disabled/future, and `嘴唇` stays partial. TEETH-02..05 are not-applicable closed; no algorithm, containment, effectiveness, naturalness, saved-output, image-review, device/performance, commercial, shipping, or release claim is made. |
| Phase 56 independent verification | Canonical re-verification passes 10/10 after closing both initial gaps: neutral-file `enamelWhitening` and `dentitionWhitening` mutations now fail with `R56-PUBLIC` plus `R56-ALIAS`, and every root owner agrees on the 111-case denominator and exact per-threat totals. The five task rows, six conditional requirement dispositions, sixteen decisions, and seven HIGH identities are exact; no human verification is required. Phase 56 is complete and Phase 57 remains independently closed by its own evidence inputs. |
| Phase 55 discussion | `55-CONTEXT.md` locks a feature-neutral package core, exact-empty production admission, canonical-source-bound proposals, post-feather hard re-clipping, duplicate rejection, collision-to-source, smallest-unit abstention, aggregate-only diagnostics, and mechanics-only byte oracles. It adds no candidate field/provider/renderer/Demo/realtime route or product evidence. |
| Phase 55 planning | Five serial plans contain nine exact validation-task owners: Wave 0 RED specifications/checker, exact-source binding and preflight, deterministic Q16 composition/failure isolation, opaque Testing-only facade adjacency/lifecycle, and final-only regression/evidence/owner synchronization. COMP-01..05 are covered, CONTEXT decisions pass 20/20 plan coverage, and every plan declares OWASP ASVS Level 1 with T-55-01…07 HIGH blocking. Production admission remains exact-empty and full SwiftPM/Demo regression is reserved for 55-05-01. |
| Phase 55 Wave 0 RED | Plan 55-01 freezes twelve compile-clean mechanics tests with literal/independent RGBA8 oracles and nine compile-clean facade-adjacent tests with opaque aggregate-only observations. The mechanics suite executes 12 tests and fails only once at `RED_MISSING_ARTIFACT:BeautyLocalRetouchComposition.swift`; the facade suite executes nine tests and fails only at the two named opaque scenario/result seams. The boundary checker compiles, parses the exact ordered T-55-01…07 HIGH inventory, passes 31 mutation cases, and accepts exactly W55-01…03 in `--expect-wave0-red`; default live mode fails only for the intentionally absent production composer. No production, candidate, Demo, realtime, dependency, model, resource, or admission surface was added. |
| Phase 55 Wave 1 source binding | Plan 55-02 established canonical storage authorization and one package-only request-local owner with min(8,pixelCount) unit issuance, bounded sparse claim counts, and checked source/owner/token/raw-index/offset preflight. Post-review hardening replaces address-only identity storage with strong lifetime-retained opaque source/owner objects and compares them by object identity; a 2,048-iteration stale-unit churn regression passes. Duplicate tokens remain scoped by owner identity, foreign byte-equal carriers and invalid/over-budget work abstain locally, and valid siblings remain accepted. The three feature gates and production admission remain exact-empty with no public/SPI/digest/candidate/Demo/realtime/dependency route. |
| Phase 55 Wave 2 deterministic composition | Plan 55-03 completes canonical-source-only UInt64 Q16 round-half-up RGB composition with post-filter hard re-clipping, exact alpha/outside-union preservation, deterministic sorted ownership, exact no-change carrier reuse, and two-or-more-owner collision-to-source counted once per pixel. Invalid, foreign, duplicate, and effective-empty proposals are rejected before consuming issuance capacity; the 128-attempt starvation regression proves a later valid sibling still issues and composes. The production-backed suite passes 21/21. Checker composition/privacy modes pass all T-55-01…07 HIGH gates, and the current 27-case self-test includes 14 executable live-Swift mutations, superseding the historical synthetic 44-case denominator. The exact six-count package summary adds no public/SPI/Codable/digest/anatomy surface. |
| Phase 55 Wave 3 facade composition | Plan 55-04 wires exactly one package composer invocation from `BeautyStillImageRequestContext.canonicalImage` only when an optional opaque Testing scenario is active, then forwards the returned canonical carrier into the existing color/render handoff. The retained Sendable Testing harness now serializes complete request/reset transactions, and a 32-request same-harness parallel regression passes. Combined facade/foundation coverage passes 29/29; exact 59-field/5-preset/72-renderer compatibility passes 74/74. Testing SPI exposes only dimensions, a source-match Boolean, one invocation count, and the exact six aggregates—no output digest or mechanics. Checker facade/live/privacy modes pass T-55-01…07 and the live-fixture self-test; production admission remains literal `.none`. |
| Phase 55 Wave 4 validation closeout | Plan 55-05 and its review-fix re-verification validate all 9/9 task rows, COMP-01..05 5/5, paired decisions D-01/D-55-01…D-20/D-55-20 20/20, and T-55-01…07 7/7. Fresh independent verification at `fc109e1` passes composition 21/21, facade/foundation 29/29, compatibility 74/74 with exact 59/5/72 inventories, checker 27-case self-test plus all live modes, full SwiftPM 534 executed with six opt-in Vision skips, and explicit iPhone 17e/iOS 26.5 Demo 118/118. The standard review is clean after fixes `e02f2ed`, `3f52edd`, `34733ef`, `34bdd7d`, and `61ee39e`; canonical `55-VERIFICATION.md` passes 29/29 must-haves with no human gaps. Production admission stays literal `.none`, with no candidate/public/SPI mechanics/provider/renderer/preset/Demo/realtime/dependency activation or product/performance claim. |
| Wave 0 RED | Plan 53-01 Task 1 authors D-05/D-06/D-07/D-08/D-16 deterministic canonical-input and source-boundary specifications. `python3 .planning/milestones/v1.14-phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py --self-test` passed with six clean/mutation cases and the exact `16 = 13 automated + 3 flagged` manifest. `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` built successfully, executed six tests, and exited nonzero only through the test-local `Phase53MissingCanonicalSeam.absent` oracle that Plans 53-02 replaces with production behavior. |
| Wave 0 facade RED | Plan 53-01 Task 2 authors D-01/D-02/D-03/D-04/D-09/D-10/D-11/D-12 and EDGE-PATH-01/04/05 through opaque counters. The exact trace is `canonicalize,detectAndMap,makeRequestContext,render`; zero/one/multiple demand, no-face/missing support, valid-invalid-valid recovery, both existing CIImage entries, and pixel-buffer/reset zero-work are executable. `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests` built successfully, executed eleven tests, and exited nonzero with seven `Phase53MissingLocalFoundationSeam.absent` failures while the empty-admission, exact-trace mutation, and nonclaim assertions passed. `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY` remain flagged assumptions under TD-013 rather than passed same-engine claims. |
| Wave 0 support/compatibility | Plan 53-01 Task 3 authors D-09/D-10/D-11/D-12 observed-lip request-local RED coverage and D-13/D-14/D-15 green baseline coverage. PATH04 boundary/empty/precision and malformed-sibling/order/value-isolation cases use actual-lip provenance with no face-box authorization. `StillImageRequestSupportTests` built and executed eight tests, failing only through ten `Phase53MissingObservedLipSeam.absent` assertions. `BeautyParametersTests` passed 43/43, `BeautyResourceCatalogTests` passed 11/11, and `BeautyRendererOutputRegressionTests` passed 18/18. PATH06/PATH07 lock exact 59 stored fields (58 numeric plus `filterId`), five presets, zero/missing neutrality, append-only admission, no candidate/provider/renderer inventory, and unchanged no-local renderer cases. |
| Wave 1 canonical carrier | Plan 53-02 Task 1 implements D-05/D-17 as exactly one package-only immutable `BeautyCanonicalStillImage` file in `BeautyCore`, with checked exact row/total byte arithmetic, normalized `.up`/not-mirrored metadata, one opaque owned RGBA8 backing, and a zero-origin explicit-sRGB `.RGBA8` CIImage view over that backing. It adds no target, dependency, Codable/diagnostic representation, or exported/SPI bytes. `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` passes 6/6 and `git diff --check` passes; Task 2 still owns the production rejection/canonicalization boundary. |
| Wave 1 canonical rejection boundary | Plan 53-02 Task 2 implements D-06/D-07/D-08/D-16/D-18 in one package-internal `BeautyStillImageCanonicalizer`: decoded extent/ceiling, raw orientation, known output-capable standard-range RGB, oriented dimensions, and checked allocation precede one explicit-sRGB `.RGBA8` render; any alpha other than 255 rejects before Vision/support. Errors remain payload-free `.invalidInput` / `.unsupportedPixelFormat`, the CIContext is reused while pixel allocations remain request-owned, and no candidate field/provider/renderer/facade/realtime route or SPI is added. `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` passes 6/6, checker self-test passes 6/6 with exact `16 = 13 automated + 3 flagged`, and `git diff --check` passes. Encoded-byte/container/gain-map inspection, HDR/transparent support, same-engine concurrency/cancellation, and performance/device/release claims remain explicitly unmade. |
| Wave 2 observed lip support | Plan 53-03 implements D-09/D-10/D-11/D-12/D-17 as package-only immutable non-Codable `BeautyObservedLipSupport` attached in place to the existing Vision and mapped observation carriers. Actual `outerLips`/`innerLips` values come from the one existing `VNDetectFaceLandmarksRequest`, independently accept only 1...32 finite closed-unit points, and map once through the existing request-local mapper. Malformed, empty, oversized, non-finite, or out-of-unit regions fail locally without erasing a valid sibling or selected face; diagnostics expose counts only. The focused `StillImageRequestSupportTests|VisionFaceDetectorTests|FaceObservationMappingTests` command passes, source/diff scans retain one request and no proxy/provider/renderer/public/SPI/realtime surface, and `PATH04-CONCURRENCY` remains flagged under TD-013 rather than claimed. |
| Wave 3 feature-neutral request route | Plan 53-04 implements D-01 through D-04, D-09 through D-12, D-17, and D-19 behind the two existing CIImage facade entries. Production admission is the exact empty `BeautyLocalRetouchAdmission`; opaque testing demand `0/1/many` proves that an admitted request canonicalizes once, invokes the existing detector/mapper once with `.up`/not-mirrored metadata, creates one stack-local `BeautyStillImageRequestContext`, and renders once. No-face or missing lip support preserves unrelated color work; malformed canonical/support fixtures fail closed and later valid requests recover without retained context. Pixel-buffer and `reset()` paths construct or invoke no canonicalizer, request context, local provider, or local-support route. The focused facade/metadata/geometry command passes 35 tests with one unrelated opt-in Apple Vision integration skip; all 11 foundation tests pass and `git diff --check` is clean. `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY` remain flagged under TD-013. |
| Wave 4 canonical render handoff | Plan 53-05 implements D-05/D-08/D-13 by passing the package-only canonical carrier into an admitted-only color/geometry overload, proving the detector receives the exact canonical CIImage view and the renderer receives the same backing, and naming sRGB for admitted geometry working/output/bitmap/reconstruction space. The unchanged no-admission route preserves exact fixture dimensions/RGBA bytes, empty warnings, exact zero active/capped metrics, and `.notRun` summary. The focused foundation/renderer command passes 30/30 (12 + 18), the live boundary checker and `git diff --check` pass, and no candidate, field, provider, mask, overlap resolver, original-pixel transform, renderer case, realtime route, dependency, target, or performance/device/release claim is added. Phase 55 retains composition and overlap ownership. |
| Phase 53 closeout | Plan 53-06 locks D-13/D-14/D-15 with exact 59 stored/CodingKey fields (58 numeric plus `filterId`), neutral defaults/missing-key and legacy source-call behavior, five preset IDs and SHA-256 source hashes, unchanged 72 renderer cases, and exact no-admission output. Checker self/live modes pass with `16 = 13 automated + 3 flagged`; the named five-suite gate passes 83/83, renderer regression passes 18/18, and full SwiftPM passes 495 tests with six documented opt-in skips and zero failures. All ASVS Level 1 HIGH mitigations are green. Production admission remains exact-empty; no candidate/public API/provider/renderer/realtime/Demo expansion or licensed-evidence/device/performance/release claim is made. |
| Phase 54 Wave 0 RED | Plan 54-01 freezes D-01 through D-16, EVID-01 through EVID-05, and LID-01 in dependency-free Node contracts: 23 core behaviors, exactly `27 = 8 UI considerations + 19 acceptance criteria`, 112 adversarial checker cases, and an exact missing-artifact RED set. Scope, privacy, and ASVS Level 1 HIGH gates prevent malformed RED, tracked evidence, SDK/Demo imports, and accidental promotion. |
| Phase 54 Wave 1 evidence core | Plan 54-02 implements the strict manifest schema and immutable pure review/reducer/export core. The core suite, JSON/JavaScript syntax, checker `--core`, and canonical eight-ID HIGH inventory pass; mechanics/synthetic/AI/historical rows remain zero-weight and no production surface is touched. |
| Phase 54 Wave 2 offline reviewer | Plan 54-03 implements the static local-only reviewer with local directory selection, ephemeral object URLs, safe DOM updates, fixed redacted reasons, replacement/reset recovery, deterministic export, and no network/storage. The reviewer contract and focused core/UI gates pass without adding SDK/Demo behavior or tracked media. |
| Phase 54 Wave 3 eligibility ledger | Plan 54-04's ledger is corrected to derive all reasons from the explicit empty eligible/review inventory: teeth and sclera each record `missing_genuine_positive` plus `missing_genuine_negative`; upper-eyelid fullness records both missing polarities plus `non_warp_design_unqualified`. All aggregate counts and naturalness weights are zero, reviews are absent by construction, and authorization-only context discharges no evidence prerequisite. `example-images/local-retouch-review/` remains ignored/untracked; no SDK target/model, public field/provider/renderer/preset/admission route, Demo UI, or nonempty Phase 53 production admission is added. |
| Phase 54 closeout | Three review-fix passes bind grants to trusted expected-target policy and exact original/mask/after keys plus SHA-256 byte digests, recover every local-read/display-URL failure transactionally, and independently pin T-54-01…T-54-08. Final standard review is clean. Current automation passes 33/33 core, 38/38 reviewer, 119/119 checker, named live `8/8`, 500 SwiftPM tests with six documented skips, explicit iPhone 17e/iOS 26.5 Demo build and 118/118 tests, schema/UI/diff gates. The fresh user-confirmed direct-`file://` smoke and independently parsed 1,640-byte allowlisted export pass. The three-feature ledger remains closed with zero review/product weight and no SDK/Demo/realtime/media/release admission; Phase 54 validation is complete. |

### C-2026-08-26-phase-89-semantic-validation-baseline

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Close VAL-01/VAL-02 at the shared validation-gate level: exact 75-case live renderer discovery, five-batch/65-case execution, and eight frozen direction-specific semantic contracts. Phases 90–94 still own the actual repairs. |
| Generated Gate | Iteration-2 review remediation `swift scripts/compare-face-feature-batches.swift --self-test` passes 554 generated mutations across metric, boundary, ownership, admission, ordering, arithmetic, report, privacy, and verdict categories, including byte-preserving report aliases. |
| Preflight | `bash scripts/run-face-feature-batches.sh --preflight-only` passed exact `75/65/8` admission without rendering or mutating output/report. |
| Live Baseline | Historical pre-review execution completed two 65/65 attempts and reported `1/8 semantic_pass`, `7/8 semantic_fail`, but code review revoked that aggregate as creditable evidence because gaze lacked independent pupil/own-eye anatomy. Current execution fails closed as sanitized exit-2 `infrastructure_failure`; no eight-direction result is published. |
| Measurement | Each direction is grounded in source plus neutral comparisons and requires target signal, signed polarity, minimum signal, outside locality, sibling distinction, and every protection ceiling. The 202 parameter-watermark rows are retained visually but excluded from measurement. |
| Privacy | The ignored report is `example-images/local-test-records/face-feature-batch-report.json`; the retained first attempt is an ignored unique child of `example-images/output/face-feature-batches/` with 66 watermarked PNGs only. Successful semantic publication requires verified removal of repeat media, temporary renderer/comparator reports, workspaces, and child transcripts; `cleanup_failure` blocks credit and requires owner-local containment/remediation because deletion could not be verified. Durable evidence contains aggregate counts/fixed reasons only—no source identity or path, report row, raw media/pixel, mask, landmark, support/ROI geometry, or child output. |
| Compatibility | The focused 107-test selection passed 107/0/0 and preserves exactly 62 public parameter fields, five presets, 75 renderer cases, the `process`/`processResult` still-image facades, CPU authority, public `.cpu`/`.gpu` selection, and terminal `.metalUnavailable` without fallback. Archive verification passed before the post-archive SDK-only boundary scanner. |
| Review Remediation | The complete contract value set is independently pinned. Missing metric evidence propagates as infrastructure failure, and the unsound gaze dark-pixel proxy is retired as `unsupported_metric` until separately authorized request-local anatomy exists. Generated adversarial fixtures provide mechanics-only rejection evidence; no model, data, network, UI, public API, or product-readiness scope was added. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Freeze and mutation-test semantic contracts | `completed` | Plans 89-01/02 bind the five batches, 65 mechanical cases, eight semantic directions, source/neutral/sibling comparators, integer regions, fixed thresholds, privacy-safe schema `beauty.face-feature-batch-report.semantic.1`, and 554 iteration-2 review mutations. |
| Reconcile owner-local portrait execution | `completed-bounded` | Plan 89-03 historically ran two never-reused CPU attempts and reconciled stable payload bytes/digests. Review invalidated its gaze measurement; current execution publishes only sanitized exit-2 `infrastructure_failure` until independent anatomy exists. |
| Synchronize command, quality, trust, and recovery owners | `completed` | `example-images/README.md`, `QUALITY_SCORE.md`, `SECURITY.md`, and `RELIABILITY.md` agree on 75/65/8, two-attempt equality, report allowlist, ignored retention, cleanup, atomic publication, and distinct semantic/infrastructure statuses. |
| Re-run focused closeout | `completed` | Post-review comparator self-test 554; path-helper/cleanup parent-swap self-test passed; stale/alias, space/Unicode, 120/121/255-byte component, and three preflight-infrastructure boundary probes passed without unintended report/output mutation; preflight 75/65/8 passed with the owner-local ignored input; renderer build, Swift type-check, shell syntax, and `git diff --check` passed. |

Phase 89 closes the predecessor record below only at the semantic-contract and
repeatable-validation level. Every observed failing direction remains honest
input to its assigned Phase 90–94 repair; arbitrary pixel differences or
weakened pass-only thresholds cannot promote it. A passing validator does not
establish naturalness, physical-device or population quality, performance,
commercial use, packaging, shipping, launch, release readiness, or
distribution. Teeth, sclera, and upper-eyelid local retouch remain excluded.

### C-2026-08-25-face-feature-batch-pixel-validation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Scope | Run the live public-facade facial-feature cases in five deterministic batches, render parameter watermarks, compare output against the authorized portrait input and neutral control, and persist only aggregate local metrics. |
| Batches | `face-shape`, `eyes`, `eyebrows`, `nose`, `mouth` |
| Privacy | The comparator persists opaque fixture IDs and aggregate pixel metrics only; source paths, raw pixels, masks, landmarks, and per-feature private geometry are not written to the report. Generated PNGs/logs remain ignored owner-local artifacts. |
| Interpretation | `changed_vs_neutral` is mechanical pixel-change evidence, not semantic correctness, naturalness, device parity, commercial quality, or release readiness. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Freeze batch inventory | `completed` | `scripts/face-feature-batch-manifest.json` binds 65 live renderer cases plus `geometryBaseline_noop` control. |
| Render watermarked outputs | `completed` | `bash scripts/run-face-feature-batches.sh` produced 65/65 cases for the one authorized portrait; each case also rendered the existing no-face safety fixture. |
| Compare input and neutral control | `completed` | `scripts/compare-face-feature-batches.swift` decodes sRGB pixels, excludes the watermark band, checks dimensions, and records changed-pixel/mean/max RGB deltas with tolerance 2. |
| Record local result | `completed` | `example-images/local-test-records/face-feature-batch-report.json` reports 65/65 complete, 0 missing outputs, neutral control input delta 0, and batch effect detections: face-shape 9/11, eyes 16/19, eyebrows 11/13, nose 5/7, mouth 13/15. |
| Document rerun path | `completed` | `example-images/README.md` documents the command, inventory, ignored artifact locations, and evidence boundary. |

Known follow-up: cases with `no_detectable_change` require semantic/ROI-specific review before any claim that the feature is ineffective; this batch is an automated mechanical screen, not a product-quality gate.

### P-2026-08-18-v1-17-manual-contract-resolution

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-08-18 |
| Completed | 2026-08-18 |
| Scope | Execute the user-approved resolutions for F-02/F-04/F-05/F-10 without adding genuine GPU local-retouch composition, transparent-input support, new public API, UI/Demo, device, or release scope. |
| Source Request | User approved the recommended audit decisions: narrow local-retouch ownership, retain fail-closed transparency, align Metal still-image math to CPU, and require caller serialization for one engine/runtime instance. |
| Current Step | All four contracts, owner/map synchronization, mutation gates, and archive-first no-skip closeout are complete. |
| Verification Policy | Finding-focused SwiftPM tests and mutation self-tests after each change, atomic finding-ID commits, then archive/boundary/preflight/full no-skip closeout. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Resolve F-02 local-retouch ownership claim | `completed` | CPU owns immutable-original/Q16 composition and collision-to-source; the Metal pass is identity transport with a single ownership marker and cannot carry proposals, masks, support, or a second composition path. Focused `6/0/0`; feature preflight `33/0/0`; two ownership mutations fail closed. |
| Resolve F-04 opaque/sRGB GPU still-image policy | `completed` | `.gpu` preflights exact opacity and bounded non-extended RGB before resolver/admission/Vision/backend work; transparent input is `.invalidInput`, unsupported color spaces are `.unsupportedPixelFormat`, Display-P3 raw metadata/extent are forwarded, and Metal output is named sRGB. Focused `21/0/0`; configuration `19/0/0`; feature `33/0/0`; parity `12/0/0`; mutations fail closed. |
| Resolve F-05 Metal still-image math | `completed` | Metal keeps pixel-buffer math unchanged and uses an explicit still-image mode matching the CPU/Core Image coefficients, Rec.709 saturation, no-extra highlight/shadow/smoothing behavior, and lip rectangle/Y/inset/coverage/color-matrix semantics. Generated parity is max channel delta `<=2`, mean RGB delta `<0.75`; focused `20/0/0`, parity `13/0/0`, feature `34/0/0`, shader-pin and mutation gates pass. |
| Resolve F-10 shared-instance concurrency contract | `completed` | `BeautyEngine` is publicly documented and mutation-gated as intentionally non-`Sendable`; callers serialize `process`/`processResult`/`reset` per instance, while the only positive concurrency evidence remains six independent engines. Focused `27/0/0`, parity `13/0/0`, and SDK-boundary self/live gates pass. |
| Synchronize owners and closeout | `completed` | Current owners/maps and the 72/16,824 source plus 74/33,569 test inventory are refreshed. Backend-neutral `24/0/0`, Metal runtime `42/0/0`, Metal feature `34/0/0`, configuration `19/0/0`, CPU reference `41/0/0`, available parity `13/0/0`, archive/boundary/self-tests, and full XCTest `776/0/0` pass; all eight opt-ins run exactly once with zero skips. |

Decision boundaries:

- F-02 does not add proposals, masks, landmarks, or support to Metal and does not claim genuine GPU local-retouch composition.
- F-04 does not add background compositing or alpha restoration; non-opaque still images remain unsupported before Vision/local-retouch work.
- F-05 preserves CPU as the compatibility oracle; it does not redefine CPU output to match Metal.
- F-10 does not add `Sendable` conformance or claim shared-instance parallel safety.

### P-2026-08-18-v1-17-audit-followup

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-08-18 |
| Completed | 2026-08-18 |
| Scope | Repair the remaining auto-fixable F-09 parity-oracle provenance defect, preserve the completed bounded closeout, and surface manual architectural findings without silently choosing product semantics. |
| Source Request | User asked to continue after the bounded v1.17 post-archive remediation review. |
| Current Step | F-09 and its mutation-tested gate were completed; the four decisions presented here were subsequently approved and implemented by `P-2026-08-18-v1-17-manual-contract-resolution`. |
| Verification Policy | Focused safety/parity tests, mutation-tested parity preflight, `git diff --check`, and the archive-first no-skip wrapper. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Classify remaining findings | `completed` | F-09 was auto-fixable and test-local; F-02/F-04/F-05/F-10 remain manual-only because they establish architecture, compatibility, or public concurrency semantics. |
| Fix F-09 parity observation provenance | `completed` | One immutable `sharedFaceObservation` now derives geometry, plan, control points, locality envelope, and `selectedFaceSupport`; request equality plus two mutation checks fail closed. Safety parity passes `4/0/0`; live parity passes `12/0/0`. |
| Verify and record | `completed` | Parity self/live gates pass and the archive-first wrapper executes XCTest `771/0/0`, all eight opt-ins exactly once, with `skipped_tests=0`. |
| Present manual decisions | `completed` | The handoff recommended an honestly narrowed CPU-owned local-retouch contract, continued fail-closed transparent-input rejection, CPU-oracle math alignment, and explicit shared-instance serialization semantics; the user subsequently authorized and the current resolution plan implemented them. |

Resolved decision queue (authorization and implementation are recorded in the current resolution plan):

| Finding | Reason |
| --- | --- |
| F-02 local-retouch GPU ownership | Approved CPU-owned composition with identity Metal transport; no genuine GPU-composition claim. |
| F-04 transparent/color-profile input | Approved exact-opaque bounded non-extended RGB input with named-sRGB output; transparency remains unsupported. |
| F-05 CPU/Metal still-image math | Approved CPU-oracle coefficient/lip-math alignment with tight generated tolerances. |
| F-10 shared-instance concurrency | Approved caller serialization for each intentionally non-`Sendable` engine; only independent-engine concurrency is supported. |

### P-2026-08-17-v1-17-audit-remediation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-08-17 |
| Completed | 2026-08-18 |
| Scope | Remediate the bounded auto-fixable findings from the post-archive v1.17 code/document audit without modifying archived milestone evidence or expanding algorithm/product scope. |
| Source Request | User requested review of the latest milestone, then asked to continue after the audit reported gaps. |
| Current Step | Five automatic fixes and their archive-first closeout were completed; F-09 and the four decision-bound findings were subsequently resolved by the two 2026-08-18 follow-up plans. |
| Verification Policy | Finding-focused SwiftPM tests, mutation-tested backend preflights, `git diff --check`, and the complete `bash scripts/run-no-skip-swiftpm.sh` closeout gate. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Classify findings | `completed` | F-01/F-03/F-06/F-07/F-08 were auto-fixable; F-02/F-04/F-05/F-10 require design decisions; F-09 was beyond this plan's default five-finding cap and was subsequently repaired by `P-2026-08-18-v1-17-audit-followup`. |
| Fix F-01 public metadata compatibility | `completed` | Raw pixel-buffer and ordinary still-image requests accept public orientation/mirror metadata; canonical carriers remain strictly `.up` and non-mirrored. Focused coverage passes `25/0/0`; the mutation-tested configuration preflight passes `17/0/0`. |
| Fix F-03 unavailable-host parity accounting | `completed` | Metal is probed first. Available hosts require 10 named Metal case sentinels within `12/0/0`; unavailable hosts run only 2 typed selection tests, report `parity_executed=0`, and emit no parity-success marker. |
| Fix F-06 Metal geometry binding bound | `completed` | Geometry points use one request-local shared `MTLBuffer`; 146-point/4088-byte, 147-point/4116-byte, and 256-point/7168-byte cases plus allocation failure are resource-clean. Feature-pass `32/0/0` and mutation-tested runtime `40/0/0` preflights pass. |
| Fix F-07 current owner drift | `completed` | Current owners distinguish historical `afb04b4`/`765/0/0` evidence from the current audit, record all remaining gaps, and keep archived milestone evidence immutable. SDK boundary self-test and post-archive scan pass. |
| Fix F-08 backend result invariants | `completed` | Result publication rejects false alpha/extent flags and same-size still-image origin drift while accepting unchanged translated extents; contract/CPU/Metal/routing coverage passes `31/0/0`, and the mutation-tested backend-neutral preflight passes `22/0/0`. |
| Complete closeout verification | `completed` | On 2026-08-18 the available parity branch reports `metal_available=1`, `metal_unavailable=0`, `parity_executed=1`, `focused_tests=12`, `unavailable_tests=0`; the archive-first wrapper passes XCTest `771/0/0`, all eight opt-ins exactly once, and `skipped_tests=0`. |

Open Questions:

| Question | Current Decision |
| --- | --- |
| F-02 local-retouch GPU ownership | Subsequently resolved as CPU-owned composition with identity Metal transport; no end-to-end GPU claim. |
| F-04/F-05 still-image compatibility | Subsequently resolved as exact-opaque bounded RGB/named-sRGB policy plus CPU-oracle Metal math with tight generated tolerance. |
| F-09 geometry safety provenance | Resolved in follow-up commit `a577dd1`: the locality envelope and rendered request now derive from one immutable observation, with mutation-tested provenance checks. |
| F-10 shared-instance concurrency | Subsequently resolved as an intentionally non-`Sendable`, caller-serialized per-instance contract; independent instances may run concurrently. |

### C-2026-08-14-phase-69-public-concurrency-repair-and-sdk-only-closeout

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-15 |
| Scope | Repair the public generic result concurrency contract and record the SDK-only v1.16 closeout without adding Metal/GPU, UI/Demo, device, performance, commercial, packaging, shipping, launch, or release-readiness scope. |
| Plans | 69-01 conditional `BeautyResult` sendability; 69-02 mutation-tested boundary and archive-first no-skip ordering; 69-03 current owner synchronization; 69-04 aggregate ledger/state closeout. |
| Contract | `BeautyResult<Output>` is conditionally `Sendable` only when `Output: Sendable`; public compile/runtime coverage preserves all result fields and existing ordinary source use, while the boundary self-test rejects the historical unconditional generic declaration. |
| Focused evidence | Public concurrency suite passes 3 tests; archive verification, boundary self-test/live scan, public consumer, generated CPU oracle, and `git diff --check` pass. |
| Final aggregate | `bash scripts/run-no-skip-swiftpm.sh` passes archive → boundary self-test/live → consumer → generated CPU oracle → all eight optional fixtures → one SwiftPM child with 702 executed tests, zero failures, and zero skips. |
| Inventory | Active tree: 66 Swift source files / 14,952 source lines and 61 SwiftPM test files / 29,995 test lines. |
| Requirements | CONC-01, CONC-02, CLOSE-01, and CLOSE-02 are marked complete against the focused/static/full evidence. |
| Nonclaims | CPU/Core Image remains the current reference. v1.17 Metal/GPU backend work remains queued; no UI/Demo, simulator/device, performance, commercial, packaging, shipping, launch, or release-readiness claim follows. |
| Lifecycle | Independent verification passed 4/4 and the canonical lifecycle completion command completed on 2026-08-15. |

### C-2026-08-14-phase-68-cpu-algorithm-reference-oracles

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-14 |
| Scope | Freeze the current CPU/Core Image behavior through generated in-memory Swift RGBA8/sRGB fixtures, semantic geometry/color metrics, local-retouch safety/composition oracles, deterministic recovery, and a generated-only preflight. |
| Plans | 68-01 fixture/metric foundations; 68-02 geometry/color semantics; 68-03 local-retouch safety and determinism; 68-04 preflight/owner closeout. |
| CPU requirements | CPU-01..CPU-05 are covered by generated fixture contracts, exact neutral/alpha/extent checks, feature-family metrics, collision/source ownership, sibling isolation, recovery, and optional-fixture separation. |
| Focused aggregate | Generated preflight passes fixture/facade `15`, geometry/color `10`, and local-retouch/determinism `16` tests with zero generated skips. |
| Final aggregate | `bash scripts/run-no-skip-swiftpm.sh` passes archive verification, SDK-only boundary, public consumer, generated CPU preflight, all eight opt-ins, and one SwiftPM child with `699` executed tests, zero failures, zero skips, and a nonzero denominator. |
| Documentation | ARCHITECTURE, SECURITY, RELIABILITY, QUALITY_SCORE, `.planning/codebase/TESTING.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` synchronize the generated-only CPU reference boundary and measured inventory. |
| Nonclaims | No production algorithm, public backend, Metal/GPU, UI/Demo, device, performance, tracked portrait media, raw fixture evidence, packaging, shipping, launch, or release-readiness claim is made. |

### C-2026-08-14-phase-67-swiftpm-consumer-and-cli-validation-contract

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-14 |
| Scope | Synchronized current owners/maps and closed the public-only SwiftPM consumer plus deterministic CPU CLI validation contract. |
| Contract | The external local-path consumer imports only public `BeautySDK`, generates a neutral RGBA input, and asserts real public-facade bytes/dimensions. `BeautyExampleRenderer` preserves 61 public fields, five neutral presets, the retained shader digest, CPU/Core Image behavior, and the exact 74-case catalog; it requires an existing output directory, accepts only `--backend cpu`, and writes versioned privacy-safe JSON after persisted PNG reopen/dimension validation. |
| Evidence | SPM-01/SPM-02: clean consumer checker and generated neutral output pass. CLI-01/CLI-02: 24/24 renderer regression and deterministic report/output/failure behavior pass. CLI-03: compiled Foundation `Process` matrix passes 7/7, including invalid matrix, collision, artifact replacement, control-character escaping, and independent render/encode failures. |
| Focused commands | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui`; `bash scripts/check-sdk-only-boundary.sh --post-archive`; `bash scripts/check-swiftpm-consumer.sh`; `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests`. |
| Final aggregate | `bash scripts/run-no-skip-swiftpm.sh` passed archive verification, post-archive boundary, consumer preflight, all eight opt-ins, one SwiftPM child with 658 executed tests, zero failures, zero skips, and a nonzero denominator. |
| Documentation | ARCHITECTURE, SECURITY, RELIABILITY, PRODUCT_SENSE, QUALITY_SCORE, `.planning/PROJECT.md`, and current codebase maps now describe public-only consumer ownership, typed failures, bounded temporary outputs, and archive → boundary → consumer → no-skip ordering. |
| Nonclaims | No public backend selector, GPU/Metal execution, UI/Demo, simulator/device, private-fixture product evidence, performance approval, commercial approval, packaging, shipping, launch, or release-readiness claim is made. Raw child output, paths, environment values, pixels, masks, and fixture metadata remain non-durable. |

### C-2026-08-13-sdk-first-two-milestone-plan

| Field | Value |
| --- | --- |
| Completed | 2026-08-13 |
| Scope | Split the remaining repository/pipeline work into two ordered SDK-only milestones instead of mixing cleanup, API repair, CPU baselining, and Metal implementation in one cycle. |
| v1.16 | `SDK-Only Foundation and CPU Reference`, planned as Phases 66-69: verified legacy UI/Demo ZIP archival and source removal; SwiftPM-only consumer/CLI validation; deterministic CPU algorithm/output oracles; conditional `BeautyResult` sendability; SDK-only debt closeout. Metal source, GPU API, simulator, UI, and device work are excluded. |
| v1.17 | `Dual CPU/GPU Metal Rendering`, queued as Phases 70-74: internal backend-neutral render contract and bounded Metal runtime; Metal color/skin passes; control-point geometry warp; request-local local-retouch composition; public backend selection and parity closeout. |
| Backend decision | Preserve the CPU implementation permanently as the reference backend. Add `BeautyConfiguration.renderBackend: BeautyRenderBackend` only after GPU coverage is complete, with `.cpu` and `.gpu`; default and legacy decode use `.cpu`. Explicit `.gpu` selection fails with `.metalUnavailable` when unavailable and never silently falls back. The execution choice does not enter `BeautyParameters` or preset JSON. |
| Shared semantics | CPU and GPU consume the same validated parameters, resolver plan, observed support, control points, request-local masks, original-pixel ownership, hard containment, failure isolation, and collision-to-source rules. Vision/support discovery may remain CPU; the switch owns rendering/composition execution. |
| Verification plan | v1.16 uses only SwiftPM, `scripts/run-no-skip-swiftpm.sh`, an SDK-only consumer fixture, and `BeautyExampleRenderer` structured input/output reports. v1.17 runs the same cases through both backends; exact gates own no-op/alpha/extent/outside-region/containment/collision/failure behavior, with explicit affected-pixel tolerances plus direction/locality/monotonicity gates for floating-point Metal output. No Xcode Demo, simulator, UI automation, or physical-device gate is required. |
| Deferred | `去脂`, hairline/semantic masking, double-chin, new models, commercial visual approval, packaging, shipping, and launch readiness remain separate future milestones. CPU/GPU infrastructure cannot promote proxy algorithms. |
| Records | `.planning/ROADMAP.md`, `.planning/PROJECT.md`, and `.planning/STATE.md` record the queued sequence. Neither milestone is active until v1.16 is initialized through the milestone workflow. |

### C-2026-08-13-document-state-drift-repair

| Field | Value |
| --- | --- |
| Completed | 2026-08-13 |
| Scope | Repaired documentation and planning-state drift against the live post-v1.15 repository without changing SDK or Demo behavior. |
| Maps | Regenerated all seven `.planning/codebase/*` maps from current source and tests: 1,162 lines covering stack, architecture, structure, conventions, testing, integrations, and concerns. TD-011 is closed. |
| Current state | Root owners, `.planning/PROJECT.md`, `.planning/STATE.md`, quality scorecards, feature matrices, module/feature READMEs, and the example-image validation inventory now agree on 61 public fields, five presets, 74 renderer cases, 650-test current no-skip evidence, bounded SDK-core teeth/sclera implementation, completed mouth, and eyes partial solely because `去脂` remains future. Historical phase snapshots are explicitly time-bounded. |
| Path repair | Repointed active documentation commands and evidence references from archived, nonexistent numbered `.planning/phases/*` locations to their real `.planning/milestones/v1.x-phases/*` locations. Remaining numbered `.planning/phases/*` mentions outside archives are historical lifecycle prose only. |
| Verification | `scripts/run-no-skip-swiftpm.sh` passed 650/650 with all eight opt-ins executed, zero skips, and zero failures. Renderer source and `Current Built-In Cases` both contain exactly 74 IDs. All seven maps are non-empty and total 1,162 lines. Every newly referenced archived phase directory exists. Current-claim and dead-active-phase scans found no unresolved current drift; secret-pattern scan and `git diff --check` passed. |
| Boundary | Documentation and planning-state accuracy only; no SDK, Demo, archived milestone, tag, distribution, shipping, launch, commercial, or release-readiness behavior changed. |

### C-2026-08-11-v1-15-review-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Remediated all five findings from the fresh `v1.14..v1.15` review without moving or reinterpreting the archived `v1.15` tag. |
| Production | Malformed observed-eye support now fails per eye while valid peers and lips continue. Teeth ownership is fixed-inner-aperture only, adaptive outer-lip growth is removed, source luminance `>= 0.90` is an exact no-op, and concave/boundary-crossing polygon relationships fail closed. |
| Fixture evidence | Shared reviewed-mask validation rejects non-finite, translated, wrong-size, and non-up-orientation masks before output rendering or measurement in both private real-fixture suites. |
| Verification | Focused mapping/provider/adversarial/mask tests pass 45/45; broader combined/integration/renderer/private-host tests pass 59/59 with two expected private opt-in skips; full SwiftPM passes 641/641 with eight documented opt-in skips and zero failures; `git diff --check` and fresh post-fix review pass. |
| Contracts | `DESIGN.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, and the teeth-whitening spike reference record the narrowed fixed-only claim and new fail-closed boundaries. |
| Historical boundary | The archived Phase 60 adaptive-growth checker is historical after this safety correction. The `v1.15` tag and milestone archive remain unchanged; no Demo, realtime, release, shipping, or commercial scope is added. |

### C-2026-08-11-v1-15-milestone-archive

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Archived the passed v1.15 roadmap, 40/40 requirements, formal audit and all Phase 59-65 execution artifacts after closing both audit debts. |
| Inventory | 7 phases, 51 plans and 97 task IDs; 40/40 requirements, 12/12 integration seams and 7/7 flows. |
| Records | `.planning/milestones/v1.15-ROADMAP.md`, `v1.15-REQUIREMENTS.md`, `v1.15-MILESTONE-AUDIT.md`, `v1.15-PHASE65-BOUND-AUDIT.md`, and `v1.15-phases/`. |
| Boundary | Internal SDK milestone lifecycle only. Archive/tag state does not claim product distribution, shipping, launch, commercial approval or release readiness. |

### C-2026-08-11-v1-15-audit-tech-debt-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Closed both nonblocking findings from the formal v1.15 milestone audit without changing product behavior or requirement scope. |
| Phase 64 checker | Added `--post-downstream`: exact canonical Phase 64 fields, SHA-256-bound chronological Phase 65 verification, and the current Phase 65 final gate replace the inapplicable candidate-era source/owner equality for downstream revalidation. The immutable terminal candidate contract remains unchanged. |
| Lifecycle ledger | Active now contains only the current Phase 65 owner disposition. Completed and superseded Phase 64 records are explicitly labeled under Historical Lifecycle Ledger with `H-*` identifiers and no stale current-authority wording. |
| Verification | Python compile; Phase 64 self-test including 6/6 downstream-binding and 8/8 strict child-payload mutations; aggregate `--post-downstream`; isolated T-64-01 through T-64-08; Phase 65 final; diff hygiene. |
| Boundary | Documentation/checker lifecycle maintenance only. No SDK/Demo behavior, public API, product promotion, archive, tag, cleanup, shipping, launch or release-readiness action/claim. |

### C-2026-08-11-v1-15-fully-automated-phase65-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Closed the five user-specified contracts with deterministic code/image gates and a fresh authority chain. |
| Implementation | `BeautyExampleRenderer` now renders and encodes named sRGB instead of DeviceRGB; presentation-free and watermarked paths preserve the CGImage color space. Teeth and sclera strict PNG decoders reject output without an explicit `sRGB` declaration. |
| Automated evidence | Renderer 23/23; actual PNG profile `sRGB IEC61966-2.1`, no EXIF orientation, unchanged dimensions and opaque output; teeth helper 20/20 plus 6/6; sclera helper 15/15 plus 6/6; Phase 65 checker 34/34 and final mode; SwiftPM 638/0/0 with all eight opt-ins; Demo 121/0/0. |
| Contracts | Combined bytes/collision/four failure units, request recovery, production privacy, 61/5/74/3 compatibility and product boundaries pass. The bound milestone audit passes 40/40 requirements, 7/7 phases, 12/12 seams and 7/7 flows. |
| Product | Bounded SDK-core opaque still-image `白牙` and `祛红血丝` are implemented; `嘴唇` is implemented; `眼睛` remains partial solely because `去脂` remains future; all three Demo rows remain disabled and nil-mapped. |
| Boundary | Completion-ready only. No Demo activation, realtime/pixel-buffer, model/network, population/device/performance/commercial, packaging, shipping, launch, archive, tag or release-readiness claim/action. |
| Preserve | The pre-existing uncommitted Phase 65 review and review-fix reports were preserved and not overwritten. |

### C-2026-08-08-v1-15-phase-63-verification-refresh

| Field | Value |
| --- | --- |
| Completed | 2026-08-08 |
| Scope | Refreshed Phase 63 canonical verification after its final summary had a newer filesystem timestamp than the already-passed report. No implementation plan or production behavior was re-executed or changed. |
| Human gate | Conversational UAT passed 8/8, including confirmation that the pre-frozen per-eye guard, reclip and immutable-source contracts were not weakened. |
| Fresh evidence | Standard 10-file review clean; focused provider/integration/mapping 44/44; required private native-Vision pair passed; full current SwiftPM 630/0/8; `git diff --check` passed. |
| Threat transition | T-63-01 through T-63-07 remain green. Historical T-63-08 now observes Phase 64's authorized renderer/promotion; the Phase 64 post-promotion and Phase 65 final checkers pass, so this is not a regression or override. |
| Result | `63-VERIFICATION.md` is fresh against `63-04-SUMMARY.md` and remains `status: passed` with all 11/11 must-haves and five requirements verified. |

### C-2026-08-08-v1-15-combined-audited-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-08 |
| Scope | Closed Phase 65 and audited v1.15 after independently completing teeth, then sclera, then their combined public still-image facade behavior. |
| Integration | Combined output matches an independent standalone merge; collisions preserve source; teeth, whole-sclera, left-eye and right-eye failure retain unaffected work; lifecycle recovery reuses no prior state. |
| Verification | Combined 13/13; focused 94/94; private output 6/6 per feature; two private native-Vision suites; opt-in suites 95/95; full SwiftPM 630/0/8; Demo build and 121/0/0; HIGH 8/8. |
| Audit | 40/40 requirements, 7/7 phases, 12/12 cross-phase seams and 7/7 end-to-end flows pass with no blocker, orphan or open HIGH. |
| Product | Exact 61/5/74/3 compatibility; `白牙` and `祛红血丝` implemented; `嘴唇` implemented; `眼睛` partial solely because `去脂` is future. |
| Boundary | The milestone is completion-ready but is not archived, tagged, cleaned up, shipped or release-ready. |

### C-2026-08-08-v1-15-phase-64-sclera-output-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-08 |
| Scope | Closed the bounded still-image SDK-core sclera slice through one exact public renderer case, strict decoded saved output, adversarial protected-anatomy safety, fresh original-detail review, exact product promotion and separate post-promotion verification. |
| Product delta | Promoted only `眼睛 | 祛红血丝` to `implemented`. Aggregate `眼睛` remains `partial` solely because `去脂` is future; all three local-retouch Demo rows remain disabled with nil mappings. |
| Evidence | Required positive/negative/no-face baseline/active matrix 6/6; renderer 21/21; helper 14/14; adversarial/provider/facade 5/11/9; actual Vision private pair; four-item visual review; checker 8/8 mutations and all eight isolated HIGH modes pass. |
| Verification | Post-promotion full SwiftPM 617/0/8; explicit iPhone 17e / iOS 26.5 Demo build and 121/0/0 tests; tracked/staged privacy scans 1,424 files; exact 61 fields, five presets and 74 renderer cases; syntax, JSON and diff gates pass. |
| Requirements | SCLERA-14 through SCLERA-18 and OUT-05 verified. Phase 65 may start combined teeth+sclera closeout but may not borrow either standalone feature's evidence or relax its guards. |
| Boundary | No population sufficiency, realtime/pixel-buffer, target-device quality/performance, commercial approval, Demo activation, external model/network, packaging, shipping, launch or release readiness is claimed. |
| Re-verification | Superseded on 2026-08-08: fresh canonical verification is `gaps_found` at 3/6. SCLERA-14/15 and therefore SCLERA-18/product promotion remain open until a complete bilateral adversarial oracle and independent rerun pass. |

### C-2026-08-07-v1-15-phase-63-sclera-provider-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Implemented the package-only stateless zero-to-two-unit sclera provider, actual current per-eye ownership, pre-score hard guard, bounded immutable-source redness transform and one-request Engine integration without activating Demo, realtime, model or network surfaces. |
| Safety | Finite simple contour and actual pupil validation, 12% contour erosion, conservative circular pupil/iris exclusion, expanded highlight/lash guards, score-inside-only, radius-one hard reclip, Q16-once composition, collision-to-source and affected-eye-only abstention are enforced. |
| Evidence | The final authorized positive/negative native-Vision gate passes with zero reviewed-mask escape. Provider/integration 20/20, checker mutations 8/8, live 8/8 and all eight isolated HIGH modes pass. |
| Verification | Full SwiftPM 612/0/8; explicit iPhone 17e / iOS 26.5 Demo build and 121/0/0 tests; decisions 16/16, requirements 5/5, tasks 8/8, threats 8/8, plans 4/4; tracked/staged privacy, syntax, JSON, inventory and diff gates pass. |
| Requirements | SCLERA-09 through SCLERA-13 verified. Phase 64 alone owns strict public output, adversarial final-output safety, new original-detail review and exact `祛红血丝` promotion. |
| Boundary | This is bounded provider integration, not final visible product acceptance, population sufficiency, realtime/device/performance readiness, commercial quality, packaging, shipping, launch or release readiness. `去脂` remains future. |

### C-2026-08-07-v1-15-phase-61-teeth-output-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Closed the bounded still-image SDK-core teeth slice through one exact public renderer case, strict decoded saved output, adversarial final-output safety, original-detail review, exact product promotion, and separate post-promotion verification. |
| Product delta | Promoted only `嘴唇 | 白牙` and aggregate branch `嘴唇` to `implemented`. `眼睛` remains `partial`; `祛红血丝` and `去脂` remain `future`; all three local-retouch Demo rows remain disabled with nil mappings. |
| Evidence | Required positive/negative/no-face baseline/active matrix passes 6/6; renderer 21/21, provider 12/12, integration 10/10, adversarial 6/6, helper 18/18, checker mutations 8/8, live post assertions 64, and all eight isolated HIGH modes pass. |
| Verification | Post-promotion full SwiftPM 587/0/7; explicit iPhone 17e / iOS 26.5 Demo build and 121/121 tests; Phase 60 retained checker 8 mutations/99 live; tracked/staged privacy 1,357 files; syntax, JSON, artifact, owner, and diff gates pass. |
| Requirements | TEETH-15 and TEETH-16 verified. Phase 62 may start independent sclera evidence/admission work but may not borrow teeth evidence or begin production sclera implementation before its own decision opens. |
| Boundary | No population sufficiency, realtime/pixel-buffer, target-device quality/performance, commercial approval, packaging, shipping, launch, release readiness, production sclera, or upper-eyelid result is claimed. |

### C-2026-08-07-v1-15-phase-60-teeth-provider-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Implemented the package-only stateless teeth selector, bounded immutable-source transform, and direct-intent still-image Engine integration without activating Demo, realtime, sibling, model, or network surfaces. |
| Safety | Complete actual mapped lips, simple/nested/plausible geometry, fixed `1.5%...94%` baseline, seed-connected growth, post-filter hard re-clip, protected-color no-ops, source-only targets, one Q16 mask owner, collision-to-source, and request-local recovery are enforced. |
| Evidence | The authorized genuine positive/negative pair passes fixed-output aggregate bounds. Provider 12/12, provider+composition 33/33, integration 10/10, focused facade/foundation/composition 49/49, and compatibility 59 tests with one existing opt-in skip pass. |
| Verification | Full SwiftPM 581/0/7; Demo build and 121/0/0 tests on iPhone 17e / iOS 26.5; checker 8/8 mutations, live 99, eight isolated HIGH modes; decisions 16/16; tracked/staged privacy, syntax, inventory, and diff hygiene passed. |
| Requirements | TEETH-09 through TEETH-14 verified. Phase 61 alone owns strict public output, adversarial final review, and exact `白牙` promotion; Phase 62 and production sclera remain blocked. |
| Boundary | This is a bounded provider result, not final product promotion, population sufficiency, realtime/device/performance readiness, commercial quality, packaging, shipping, launch, or release readiness. |

### C-2026-08-07-v1-15-phase-59-open-intent-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Closed Phase 59 on the exact serializer-open teeth intent branch while preserving provider/output, sclera, `去脂`, Demo, realtime, model, and network absence. |
| Decision | The canonical teeth row is open at `2/2/2/0/2`; exactly one trailing default-zero normalized scalar and one opaque request-local demand are admitted. Sclera redness and upper-eyelid fullness remain independently closed. |
| Compatibility | Exact 60 stored/CodingKey/initializer fields, five byte-stable neutral presets, 72 renderer cases, and three disabled Demo rows with nil mappings. |
| Verification | Phase 54 33/33; private Phase 59 contract 9/9; mechanics self-test 24/24 as corroboration only; focused SDK 147/147; full SwiftPM 558/0/6; Demo build and 121/0/0 tests; checker 235/235; decisions 16/16; eight HIGH threats; tracked/staged privacy and diff hygiene passed. |
| Requirements | EVID-07 and TEETH-07/08 verified. SEQ-01 remains enforced by routing only to Phase 60 and blocking Phase 62/production sclera until Phase 61 closes teeth. |
| Boundary | This is intent admission, not visible whitening, provider safety, product promotion, population sufficiency, device/performance readiness, commercial quality, packaging, shipping, launch, or release readiness. |

### C-2026-08-05-local-retouch-candidate-image

| Field | Value |
| --- | --- |
| Completed | 2026-08-05 |
| Scope | Registered the user-supplied portrait as one local-only, AI-generated positive-target mechanics candidate for independent white-teeth and sclera-redness experiments. |
| Files | `example-images/local-retouch-review/candidates/portrait_002/original.png` (ignored local media), `example-images/FIXTURE_AUTHORIZATION.md` |
| Boundary | The candidate stays outside `example-images/input/`, does not alter the exact renderer fixture inventory, and does not enable `白牙` or `祛红血丝`. The shared original does not couple the feature decisions; each feature still requires its own mask, after image, manifest row, review, negative peer, and promotion result. |
| Verification | Original-detail intake inspection, `file`, `sips`, PNG chunk/provenance inspection, `git check-ignore`, `git diff --check`, and focused `BeautyRendererOutputRegressionTests` (21/21) passed. The retained local C2PA block declares `trainedAlgorithmicMedia`; production source and active renderer inputs were unchanged. |

Outcome:

- `portrait_002` is available at the ignored local review path for both `teeth_whitening` and `sclera_redness` mechanics work, with zero genuine-evidence weight.
- Existing active `p1`/negative fixture contracts and the closed v1.14 production boundary remain unchanged.

### C-2026-07-30-authorized-smile-fixture-replacement

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Permanently replaced the opaque local `portrait_001` pixels with the newly supplied smiling portrait, deleted the prior project-local `p1` copy instead of parking it, preserved the active `p1.jpg` path, re-sanitized image metadata, and updated the authorization, dimension, product, quality, and test contracts. Disabled `e1`–`e6` fixtures remain outside active discovery. |
| Local asset | `example-images/input/portraits/p1.jpg` is now a 2628×1778, 1,587,765-byte Display P3 JPEG. It remains local and Git-ignored. The source download remains user-owned and is not copied into tracked history. |
| Rights and privacy | Rights record `user_authorization_20260730_002` records the user's explicit copyright, portrait/likeness, derivative, long-term local-test, and no-planned-replacement authorization without naming the subject or source file. Re-encoding removed GPS, TIFF, orientation, capture/device, author/copyright, and screenshot/user-comment metadata. |
| SDK verification | Fixture/gallery self-tests pass with exactly `p1` plus `no-face-gradient` active and `e1`–`e6` rejected. `BeautyRendererOutputRegressionTests` passes 17/17; opt-in Vision/detection/facade/adapter coverage passes 95/95; full SwiftPM passes 458 tests with six documented opt-in skips. A public renderer smoke run writes only the p1 and no-face `geometryBaseline_noop` outputs, preserving 2628×1778 and 64×64 extents. |
| Local-retouch evidence | Apple Vision provides one usable face with inner/outer lips. Adaptive teeth support contains 13,709 strong pixels versus 9,320 for the fixed baseline with zero outside-mask changes. Guarded fused composition contains 16,639 mask pixels with zero outside, iris, or highlight changes and zero fused/sequential or fail-closed mismatches. Original-detail review found the whitening restrained and the overlay confined to visible teeth without obvious lip or gum spill. Sclera support is weak/asymmetric on this portrait (left rejected, right 640 pixels), so no redness-positive claim is made. |
| Boundary | The exposed smile makes this a durable rights-approved teeth-containment and over-whitening fixture. Its already-light teeth are not a yellow/dark-teeth positive; its eyes and eyelids are not established redness or upper-eyelid-fullness positives. Product feasibility still requires additional rights-approved feature-specific positives/negatives and human original-detail review. |

Outcome:

- Future local tests may keep using this exact opaque `p1.jpg` fixture without another authorization round unless its use expands beyond the recorded internal-evaluation scope.
- The prior project-local neutral portrait is gone and is not an alternate input or parked fallback.
- This replacement materially improves white-teeth containment review while leaving the v1.14 activation and population/calibration gates closed.

### C-2026-07-30-authorized-portrait-fixture-cutover

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Replaced the sole active local portrait fixture with the user-authorized real portrait supplied on 2026-07-30. Stored a metadata-sanitized copy as opaque `p1.jpg`; moved `e6.jpg` beside the already parked `e1`–`e5`; moved the prior 660 MB `e6` output/gallery snapshot outside active paths; updated active tests, gallery discovery, privacy/reliability/product/quality contracts, and a non-identifying authorization record. |
| Local assets | `example-images/input/portraits/p1.jpg` is a 2316×3088, 2,484,953-byte local/Git-ignored JPEG. `example-images/parked-portraits/` contains exactly `e1.png`–`e5.png` plus `e6.jpg`. Prior output/gallery trees are retained under `example-images/parked-generated/2026-07-30-e6/`. Binary assets are not committed. |
| Privacy | The supplied source contained precise GPS plus capture-time/device metadata. The active copy was re-encoded without GPS, TIFF device/time, author, copyright, or orientation fields. Tracked text contains no original download path, coordinates, subject name, or image hash. `example-images/FIXTURE_AUTHORIZATION.md` records only opaque fixture/right IDs, the user's permission statement, local-use scope, retention, and evidence limits. |
| Verification | Active discovery reports exactly `no-face-gradient` and `p1`; `e1`–`e6` rejection and symlink/size/publication self-tests pass; local-ignore, source-path/GPS-leak, metadata, inventory, and diff checks pass. `BeautyRendererOutputRegressionTests` passes 17/17; opt-in Vision/facade/adapter integration passes 95/95; the renamed local-authorized integration tests pass 3/3; full SwiftPM passes 458 tests with six documented opt-in skips; a public renderer smoke run writes only `p1__geometryBaseline_noop.png` and the no-face peer, preserving p1 at 2316×3088. |
| Boundary | Authorization permits future local testing and derivative review, but this single neutral/closed-mouth portrait is not automatically a teeth, sclera-redness, or upper-eyelid positive/negative. It does not establish population coverage, calibration, commercial naturalness, device performance, or v1.14 activation. Feature-specific before/mask/after review and additional positives/negatives remain required. |

Outcome:

- Future active SDK and gallery discovery uses only `p1.jpg`; all `e1`–`e6` portraits are disabled and retained only for historical reference outside `input/`.
- The user's broad permission is now durable as a privacy-minimized text contract while the actual portrait and derivatives remain local and ignored.
- The real portrait is proven usable by Apple Vision for face, contour, eye, pupil, lip, and eyebrow integration, but its neutral expression means it is primarily a general/negative fixture until feature-specific polarity is reviewed.

### C-2026-07-30-spike-013-wrap-up

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Appended completed Spike 013 to the project-local `spike-findings-beauty` implementation blueprint without changing production source, public API, feature inventory, milestone scope, or runtime behavior. |
| Outputs | Added exact 013 README/review sources; refreshed the exact shared Swift harness; updated the still-image integration recipe with one EXIF/color owner, explicit RGB rejection, transparent-input policy ownership, fixed-anchor sensitivity isolation, and bounded cross-profile acceptance; refreshed the skill trigger/index, processed inventory, and wrap-up summary. |
| Knowledge shape | The skill now covers thirteen processed spikes across the same five feature areas. All eight lossless EXIF orientations are exact after one canonical render, while equivalent color-profile and background variants require bounded detector/output stability rather than topology identity. Transparent input remains a product composite-or-reject decision. |
| Verification | Four owner/copy sources compare byte-for-byte; the copied Swift package builds in release and passes 23/23 self-tests; the retained Spike 006 review core passes 9/9; copied 013 review JavaScript parses; manifest, skill, and summary inventories are 13/13/13; all five references contain required blueprint sections; skill validation, AGENTS route count, runtime-network, generated-directory, media/model/binary, production-boundary, and diff-hygiene checks pass. |
| Boundary | No fixture media, aggregate run artifact, model/weight, build output, product code, public contract, realtime claim, device budget, licensed-evidence claim, transparent-input policy, HDR/gain-map support, or v1.14 activation was packaged. AI fixtures remain mechanics-only and licensed real review remains mandatory. |

Outcome:

- Future still-image local-retouch planning will auto-load the normalize-once contract and the fixed-anchor oracle that separates Vision drift from color-score/transform drift.
- Exact cross-profile mask topology is preserved as an invalidated acceptance assumption; product criteria must instead bound containment, landmark/output stability, and naturalness on rights-approved inputs.
- `CONVENTIONS.md` remains unchanged because canonical input normalization appears in only Spike 013. The existing AGENTS route remains the single project entry for the skill.

### C-2026-07-30-spike-013-normalized-input-local-retouch

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Added an isolated ImageIO/Core Image canonical input boundary and exercised adaptive-teeth plus guarded-sclera composition across all eight EXIF rotation/mirror values, an 8-bit Display-P3 round trip, transparent borders, invalid orientation, non-RGB input, and no-face behavior. Production normalization and public contracts remain unchanged. |
| Verdict | `PARTIAL`: all lossless EXIF variants normalize to byte-identical input, Vision anchors, masks, alpha, and output; alpha/outside-mask preservation and invalid/non-RGB/no-face failure pass. The stricter cross-profile topology requirement fails because one-byte P3 round-trip differences move Vision anchors and mask edges. |
| Orientation result | Across e6/e2/e3, all 24 encoded EXIF/mirror runs report zero input/output/alpha/topology mismatch and zero anchor delta after canonical up-oriented sRGB RGBA8 normalization. |
| Sensitivity result | P3 round trips stay within 1 input byte but fresh Vision anchors move 0.53–1.56 px, causing 8/15/76 strong-mask topology differences and 9/4/13 maximum output-byte deltas on e2/e3/e6. Holding canonical anchors fixed reduces topology differences to 3/0/11 and output maxima to 2/1/2, isolating detector sensitivity as the larger contributor. Transparent borders preserve alpha/outside pixels but move anchors 0.77–4.89 px; fixed anchors restore zero topology difference. |
| Verification | Official Apple research recorded; release build and 23/23 self-tests pass; e6/e2/e3 metric assertions and exact event allowlists pass; invalid orientation/non-RGB reject before Vision; no-face exits 1; review JavaScript/assets pass; canonical/oriented/P3/alpha outputs were visually inspected; JSON/privacy/network/production-boundary/diff-hygiene checks pass. |
| Evidence | `.planning/spikes/013-normalized-input-local-retouch/`, aggregate comparison/events JSON, local ignored visual artifacts, updated shared isolated harness, manifest verdict, and this ledger. |
| Boundary | AI fixtures and synthetic profile/alpha variants prove mechanics only. Production must retain one orientation/color owner but still needs a transparent-input policy, HDR/gain-map work, licensed real stability/naturalness review, optimized memory, target-device profiling, and explicit bounded—not byte-identical—cross-profile acceptance. |

Outcome:

- Future still-image local-retouch work must normalize once before both Vision and rendering; passing orientation independently to only one side is not an acceptable ownership model.
- Do not promise identical masks for equivalent 8-bit color-profile encodings. Use containment and bounded output/stability criteria, and evaluate detector drift on rights-approved real inputs.
- Transparent canvas/background handling is a product input decision: either composite against a declared background before detection or reject unsupported alpha semantics. This spike does not choose or implement that production policy.
- No new convention is added because canonical input normalization is established by the production security/design contract but appears in only this one spike session.

### C-2026-07-30-spike-012-wrap-up

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Appended completed Spike 012 to the project-local `spike-findings-beauty` implementation blueprint without changing production source, public API, feature inventory, milestone scope, or runtime behavior. |
| Outputs | Added exact 012 README/review sources; refreshed the exact shared Swift harness; updated the still-image integration recipe with original-pixel ownership, byte-level composition/failure oracles, fail-closed overlap handling, and the CPU performance nonclaim; refreshed the skill trigger/index, processed inventory, and wrap-up summary. |
| Knowledge shape | The skill now covers twelve processed spikes across the same five feature areas. Accepted local color edits derive from the original pixel under one explicit mask owner; unexpected teeth/sclera overlap retains the source pixel. This validates ownership mechanics only, not optimized execution. |
| Verification | Four owner/copy sources compare byte-for-byte; the copied Swift package builds in release and passes 19/19 self-tests; the retained Spike 006 review core passes 9/9; the copied 012 review JavaScript parses; manifest, skill, and summary inventories are 12/12/12; all five references contain required blueprint sections; skill validation, AGENTS route count, runtime-network, generated-directory, media/model/binary, production-boundary, and diff-hygiene checks pass. |
| Boundary | No fixture media, aggregate run artifact, model/weight, build output, product code, public contract, realtime claim, device budget, licensed-evidence claim, or v1.14 activation was packaged. AI fixtures remain mechanics-only and licensed real review remains mandatory. |

Outcome:

- Future local-retouch planning will auto-load the exact composition rule and will not infer that “one fused loop” is a performance win; the tested CPU path was 2.6–3.1× slower than sparse sequential loops.
- The existing `CONVENTIONS.md` already records the recurring original-pixel/explicit-owner/fail-closed-overlap rule established by Spikes 004 and 012, so wrap-up added no duplicate convention or AGENTS route.
- The next evidence-bearing action remains rights-approved real teeth/sclera positive/negative review through Spike 006; frontier exploration remains optional and does not activate v1.14.

### C-2026-07-30-spike-012-guarded-local-retouch-composition

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Integrated Spike 009 adaptive teeth selection and Spike 011 guarded per-eye sclera selection behind one original-image color loop in the isolated Swift harness. Added independent standalone and sequential byte oracles, four local failure injections, and explicit fail-closed mask-overlap handling without changing production source or API. |
| Verdict | Narrowly `VALIDATED`: one Vision request supplies both selectors; disjoint fused output exactly matches both oracles; rejected teeth, whole sclera, left eye, and right eye preserve every unaffected output; unexpected overlap keeps the original pixel. Product coverage, naturalness, and performance are not validated. |
| Safety result | e6/e2/e3 have zero baseline cross-mask overlap, zero oracle mismatch, zero outside-union change, zero protected-iris/highlight change, and zero failure-isolation mismatch. e6/e2 each suppress exactly one injected overlap with zero changed collision pixels; e3 naturally has zero teeth candidates while retaining 56 + 88 sclera candidates. |
| Performance result | The release CPU fused prototype measures 6.634 / 0.774 / 0.789 ms on e6/e2/e3 versus 2.570 / 0.290 / 0.255 ms for the sparse sequential loops. One-owner composition semantics pass, but ROI/Metal optimization and device budgets remain required before product planning. |
| Verification | Release build and 19/19 self-tests pass; all three aggregate metric assertions and exact event allowlists pass; review JavaScript and asset references pass; no-face exits 1 with the expected message; masks and outputs were inspected including e6 at original detail; JSON/privacy/network/production-boundary/diff-hygiene scans pass. |
| Evidence | `.planning/spikes/012-guarded-local-retouch-composition/`, aggregate e6/e2/e3 comparison/events JSON, local ignored visual artifacts, updated shared harness and manifest, and the recurring original-pixel/explicit-owner/fail-closed-overlap convention established by Spikes 004 and 012. |
| Boundary | AI-generated fixtures prove mechanics only. Licensed real teeth/sclera positives and negatives, original-detail blind review, optimized ROI/Metal implementation, device profiling, realtime design, public ownership, v1.14 activation, and `去脂` remain outside this result. |

Outcome:

- Adaptive white-teeth and guarded sclera-redness can share a request-local still-image composition path without hidden ordering semantics or cross-region failure coupling.
- The product gate remains unchanged: acquire rights-approved real evidence through Spike 006 before proposing white-teeth/redness scope; do not activate v1.14 from mechanics fixtures.
- If this spike is wrapped into `spike-findings-beauty`, preserve the performance nonclaim and the explicit rule that unexpected mask overlap leaves the source pixel unchanged.

### C-2026-07-30-spike-011-wrap-up

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Appended completed Spike 011 to the project-local `spike-findings-beauty` implementation blueprint without changing production source, public API, feature inventory, milestone scope, or runtime behavior. |
| Outputs | Updated the existing sclera-redness and still-image-integration references with guard-before-score, post-feather hard re-clipping, per-eye failure independence, and complementary geometry/adversarial final-output oracles; added exact 011 README/review sources; refreshed the exact shared Swift harness; updated the processed inventory and wrap-up summary. |
| Knowledge shape | The skill now covers eleven processed spikes across the same five feature areas. Guarded sclera mechanics require validate-per-eye → hard envelope → local score → feather → hard re-clip → one bounded transform; the 0.30/0.14 values and useful coverage remain real-data calibration questions. |
| Verification | Four copied sources compare byte-for-byte with their owners; the copied Swift package builds in release and passes 16/16 self-tests; processed and summary inventories are 11/11; all five references contain the required blueprint sections; the 011 review JavaScript parses; the retained 006 review core still passes 9/9; AGENTS routing count remains one; runtime-network, generated-directory, media/model/binary, pending-verdict, production-boundary, and diff-hygiene checks pass. |
| Boundary | No fixture media, challenge image, mask, heatmap, model/weight, build artifact, product code, public contract, realtime claim, device budget, or v1.14 activation was packaged. AI fixtures remain mechanics-only and licensed real evaluation remains mandatory. |

Outcome:

- Future sclera implementation planning will auto-load the proven final-mask ordering and will not mistake native dark-iris color rejection for geometric safety.
- `CONVENTIONS.md` already contains the cross-feature post-filter hard-clip rule established by Spikes 009 and 011, so no duplicate convention or AGENTS route was added during wrap-up.
- The next evidence-bearing action remains acquiring rights-approved real sclera positives/negatives for the Spike 006 local blind-review gate; frontier exploration is optional and does not activate v1.14.

### C-2026-07-29-spike-011-guarded-sclera-color-integration

| Field | Value |
| --- | --- |
| Completed | 2026-07-29 |
| Scope | Integrated Spike 010's per-eye hard guard with Spike 003/004's redness score, feathering, and byte-level bounded transform inside the isolated Swift harness; added native and locally color-adversarial grid evaluation without changing production source or API. |
| Verdict | Narrowly `VALIDATED`: score only inside the hard envelope, feather locally, and then re-clip to the same envelope before compositing. The 0.30/0.14 guard remains a calibration seed, not a product constant. |
| Safety result | Guarded final output changes 0 protected iris and 0 highlight pixels across 360 native plus 360 adversarial eye-scenarios. The legacy adversarial path changes protected pixels in 356/360 scenarios; e6 also exposes 9/120 native legacy leak scenarios. |
| Coverage result | Guarded baselines retain nonzero mask/change candidates in both eyes on e6/e2/e3, with 1,868 / 223 / 144 candidate pixels and 38.2% / 24.6% / 28.8% legacy retention. The stress grid fails closed in 270/360 eye-scenarios. |
| Verification | Release build and 16/16 self-tests pass; all aggregate JSON and metric assertions pass; no-face exits 1; all three event logs match exact allowlists and sensitive-key scan is clear; review JavaScript parses; e6/e2/e3 native masks and adversarial heatmaps were inspected at original detail; runtime network, production-boundary, and diff-hygiene checks pass. |
| Evidence | `.planning/spikes/011-guarded-sclera-color-integration/`, updated shared harness, manifest verdict, aggregate events/metrics, local ignored visual artifacts, and the recurring post-feather hard-clip convention established by Spikes 009 and 011. |
| Boundary | AI-generated fixtures prove mechanics only. Licensed real redness positives/negatives, original-detail blind review, threshold calibration, device performance, product ownership, realtime design, v1.14 activation, and public API remain unclaimed. |

Outcome:

- The original Spike 003 mask must not be promoted unchanged: native color can hide unsafe geometry, and the adversarial oracle demonstrates final-transform leakage rather than only envelope overlap.
- A future still-image implementation may reuse the guarded ordering as a blueprint: validate per eye, build hard support, score color inside it, feather, re-clip, transform once, and persist aggregate diagnostics only.
- The next durable action is wrapping Spike 011 into `spike-findings-beauty`; the next product-evidence action remains acquiring rights-approved real fixtures through Spike 006, not activating v1.14.

### C-2026-07-29-local-retouch-frontier-wrap-up-006-009-010

| Field | Value |
| --- | --- |
| Completed | 2026-07-29 |
| Scope | Appended completed Spikes 006, 009, and 010 to the project-local `spike-findings-beauty` implementation blueprint without changing production source, API, feature inventory, milestone scope, or runtime behavior. |
| Outputs | Added the licensed-fixture evaluation reference and exact 006 source; updated teeth and sclera references with adaptive growth, rejected full-envelope leakage, jitter safety, fail-closed calibration, and exact 009/010 sources; refreshed the exact shared Swift harness, skill index, wrap-up summary, and recurring conventions. |
| Knowledge shape | The skill now covers ten processed spikes across five feature areas. Deterministic adaptive teeth may proceed to licensed review; the original sclera circle is an explicit landmine; the 0.30/0.14 guard is a calibration seed; mechanics and rights-approved evidence use separate gates. |
| Verification | Twelve copied core files compare byte-for-byte with their spike owners; the copied Swift package builds in release using an external scratch path and passes 13/13 self-tests; the copied review core passes 9/9; copied JavaScript/JSON parse; processed inventory is 10/10; five references contain all blueprint sections; AGENTS route count is one; runtime network, generated-directory, media/model/binary, production-boundary, skill-frontmatter, source-path, and diff-hygiene checks pass. |
| Boundary | No raw fixture media, review output, model/weight, build artifact, product code, public contract, realtime claim, or v1.14 activation was packaged. |

Outcome:

- Future teeth, sclera, local-mask, or fixture-evaluation planning will auto-load the updated project skill and see both the proven mechanics and rejected candidates.
- `去脂` remains future; white-teeth and sclera-redness product planning remains gated on rights-approved positive/negative original-detail review.
- The next material action is acquiring and documenting licensed real fixtures, not adding another algorithm or activating a milestone.

### C-2026-07-29-local-retouch-frontier-006-009-010

| Field | Value |
| --- | --- |
| Completed | 2026-07-29 |
| Scope | Completed selected frontier Spikes 006, 009, and 010: an offline rights/asset/review/export gate, adaptive deterministic teeth-mask comparison, and color-independent sclera landmark-jitter safety grid. All changes remain under `.planning/spikes/` plus this ledger. |
| Verdicts | Spike 006 is `PARTIAL`: the local gate works but no licensed real fixtures were supplied. Spike 009 is `PARTIAL`: adaptive seeded growth beats the fixed mask on mechanics fixtures but lacks licensed protected-tissue review. Spike 010 is narrowly `VALIDATED`: its guarded deterministic grid has zero iris/highlight leakage, while thresholds and useful coverage remain unvalidated for users. |
| Teeth result | e6 strong coverage rises 4,711 → 7,396 (+57.0%) and e2 rises 462 → 805 (+74.2%), with zero dropped strong pixels, zero outside-mask changes, e3 closed-mouth zero, and no-face exit 1. |
| Sclera result | The existing geometric envelope leaks into the unperturbed protected iris in 118/120 scenarios on each of e6/e2/e3. The guarded envelope leaks in 0/360 combined scenarios and has zero highlight leaks, but fails closed in 270/360 stress scenarios and retains only 28.6%–32.2% of baseline geometric eligibility. |
| Product decision | Do not activate v1.14 or change production. The adaptive teeth path may enter licensed review; the unguarded Spike 003 sclera geometry must not be promoted unchanged; the conservative 0.30 aspect/0.14 width guard is a calibration starting point, not a production constant. `去脂` remains future. |
| Verification | Rights/review core passes 9/9; isolated Swift release build and 13/13 self-tests pass; all retained JSON parses; 009/010 metric assertions pass; three review pages and JavaScript parse; runtime network, event allowlist, model/weight, production-boundary, and diff-hygiene scans pass; both no-face modes exit 1. |
| Evidence | `.planning/spikes/006-licensed-fixture-review-gate/`, `.planning/spikes/009-adaptive-teeth-mask/`, `.planning/spikes/010-sclera-jitter-envelope/`, the shared isolated harness, manifest verdicts, local visual artifacts, and commits `75d6bbf`, `e549aea`, and `92624f2`. |

Outcome:

- The next evidence step is fixture acquisition, not another production algorithm: obtain licensed real positive/negative teeth and sclera cases with complete rights metadata, then use Spike 006 for original-detail blind review.
- Teeth review must measure side-tooth gain against lip/tongue/gum/braces/occlusion leakage. Sclera review must calibrate openness and uncertainty guards across partial closure, gaze, glasses/contacts, iris color, pose, redness, and demographic/illumination variation.
- No repeated cross-spike implementation pattern required a `CONVENTIONS.md` change; per-feature decisions and rejected intermediate candidates are recorded in their authoritative Spike 009/010 READMEs.
- No `BeautySDK`, `BeautyDemo`, public API, feature ledger, milestone, camera/pixel-buffer path, or product behavior changed.

### C-2026-07-29-local-retouch-spike-wrap-up

| Field | Value |
| --- | --- |
| Completed | 2026-07-29 |
| Scope | Packaged all seven unprocessed local-retouch spikes into the project-local `spike-findings-beauty` implementation-blueprint skill without changing production source, public API, feature ledgers, milestone scope, or runtime behavior. |
| Outputs | `.codex/skills/spike-findings-beauty/SKILL.md`; four feature-area references; exact copies of seven spike READMEs, the Core ML provenance audit, the visual-review source, and the shared Swift package; `.planning/spikes/WRAP-UP-SUMMARY.md`; and one AGENTS auto-load route. |
| Knowledge shape | Upper-eyelid tone and invalidated warp are grouped as one constrained area; deterministic/learned teeth masks as one license-gated area; sclera masking as one privacy-sensitive area; local color and request integration as the validated still-image foundation. |
| Conventions | Re-read all spike source and findings; the existing Swift 6, Apple-framework, release-metric, request-local-mask, aggregate-log, real-fixture, and external-model rules remain current with no contradictory newer pattern. |
| Verification | All preserved sources compare byte-for-byte with their spike originals; every reference contains Requirements/How to Build/What to Avoid/Constraints/Origin; processed-spike count is 7; AGENTS route count is 1; no pending verdict, model/weight, or build artifact is packaged; copied review JavaScript parses; copied Swift package builds in release and self-tests pass 7/7; `git diff --check` passes. |

Outcome:

- Future implementation conversations can auto-load the exact non-negotiable gates, proven formulas, rejected warp, privacy rules, measured baselines, and preserved source without re-spiking.
- The generated blueprint explicitly keeps `去脂` future, the EasyPortrait port research-only, real licensed fixtures mandatory, and all current evidence within the still-image boundary.
- No milestone is active; frontier exploration, implementation planning, fixture acquisition, and model/legal approval remain separate explicit next actions.

### C-2026-07-29-v1-14-local-retouch-feasibility-spikes

| Field | Value |
| --- | --- |
| Completed | 2026-07-29 |
| Scope | Completed seven isolated, non-product spikes for proposed `去脂`, `祛红血丝`, and `白牙` directions without changing `BeautySDK`, `BeautyDemo`, public API, feature ledgers, or the live pixel-buffer path. |
| Verdicts | Upper-lid tone is `PARTIAL` and the comparison winner; boundary-fixed upper-lid warp is `INVALIDATED`; deterministic teeth, research Core ML teeth, sclera mask, and combined color are `PARTIAL`; the isolated still-image harness is `VALIDATED`. |
| Product decision | Do not activate `去脂` or a v1.14 milestone. White-teeth and redness color transforms are technically viable, but production work remains gated on licensed real positive/negative fixtures plus either a legally approved pinned segmenter or an owned/evaluated mask provider. |
| Verification | Swift debug and release builds pass; shared self-tests pass 7/7; all 15 retained artifact runs parse as valid JSON and report zero outside-mask changes; event-schema and sensitive-key scans pass; no Core ML model/weights are present in the repository; no-face input exits 1; review-page JavaScript syntax and `git diff --check` pass. |
| Evidence | `.planning/spikes/MANIFEST.md`, seven per-spike READMEs, aggregate events/metrics, visual masks/overlays, a local comparison page, conventions, and an external-model provenance/hash audit. |

Outcome:

- Current `去脂` formulations do not demonstrate independent product semantics; the warp loses 7%–8% texture energy and is rejected rather than aliased to eye geometry.
- Teeth segmentation is the main white-teeth blocker: Vision/color is fail-closed but incomplete, while EasyPortrait improves coverage and remains research-only because the conversion/license chain is not approved and cold load is material.
- Landmark/pupil-protected sclera selection and both bounded color transforms remain promising, but AI-generated fixtures prove mechanics only; real positive/negative human review is the next gate.
- No milestone is active; packaging these findings or acquiring approved fixtures/models requires a separate explicit next action.

### C-2026-07-28-td-012-production-image-input-bounds

| Field | Value |
| --- | --- |
| Completed | 2026-07-28 |
| Scope | Closed TD-012 with additive public production input ceilings and fail-fast SDK/Demo enforcement; no product feature, image resizing, dependency, milestone, or readiness scope was added. |
| Contract | `maximumInputByteCount` defaults to `33_554_432`; `maximumInputPixelCount` defaults to `50_000_000`. Both are trailing defaulted initializer arguments, non-positive values normalize to defaults, and legacy JSON without either key decodes compatibly. |
| Enforcement | The SDK rejects over-limit `CIImage` and `CVPixelBuffer` dimensions as `BeautyError.invalidInput` before resource/detection/copy/render work. The Demo rejects PhotosPicker bytes before decode and decoded extents before SDK processing/display render while preserving snapshot, friendly recovery, and stale-generation behavior. |
| Verification | Focused SDK command passes 23/23; focused `ImageEditorPipelineTests` passes 12/12 on iPhone 17e / iOS 26.5; full SwiftPM passes 457 tests with six expected skips; full Demo simulator tests pass 118/118; owner scans and diff hygiene pass. |
| Residual | `loadTransferable(Data.self)` materializes Data before size is observable, so this closes post-transfer decode/render amplification without claiming pre-transfer allocation control. |

Outcome:

- Security evidence now supports score 4 for the configured image-input boundary.
- TD-013, historical milestone archives, product inventory, and device/commercial/performance/packaging/release nonclaims remain unchanged.
- No milestone is active; the repository still awaits an explicitly scoped next milestone.

### C-2026-07-28-current-state-consolidation-audit

| Field | Value |
| --- | --- |
| Completed | 2026-07-28 |
| Scope | Froze feature expansion; audited current production code, tests, root contracts, live planning owners, dependencies, privacy/reliability boundaries, and build paths from first principles. |
| Classification | Seven medium-or-higher findings: F-01 through F-05 auto-fixable and fixed; F-06/F-07 require public design/API decisions and are recorded as TD-012/TD-013. |
| Code fixes | Invalidated stale asynchronous camera starts; blocked late permission completion outside Camera mode; mapped current nil PhotosPicker transfers to the existing recoverable failure while ignoring stale completions. |
| Document fixes | Corrected actual pixel-buffer/still-image/Render ownership, v1.13/current inventories, GSD requirement lifecycle, scores, repair queue, LOC, historical metrics labeling, stale tech-debt states, and the one intentional UIKit force-cast classification. |
| Verification | Full SwiftPM executes 450/450 successfully; full `BeautyDemo` simulator tests succeed on iPhone 17e / iOS 26.5; focused camera-session tests pass 6/6, permission tests 7/7, and privacy/input tests 15/15; architecture/import/crash-classification/current-state/link/JSON/LOC/plan-inventory/diff-hygiene gates pass. |

Outcome:

- Five auto-fixable findings are closed in five atomic F-ID commits.
- Realtime Camera and Security quality scores are conservatively reduced to 3 where current compiled behavior or input-limit enforcement does not satisfy the target contract.
- TD-012 owns production image bounds; TD-013 owns the public generic result sendability migration.
- No historical archive, public feature inventory, v1.14 scope, device/commercial claim, packaging, or release-readiness status was changed.

### C-2026-07-28-v1-13-milestone-completion

| Field | Value |
| --- | --- |
| Completed | 2026-07-28 |
| Scope | Completed the v1.13 lifecycle after the passing independent audit: archived ROADMAP, REQUIREMENTS, audit, and all Phase 49-52 artifacts; collapsed the live roadmap; evolved PROJECT/STATE/MILESTONES; recorded the retrospective; cleaned the active phase directory; and prepared the final commit for the annotated `v1.13` tag. |
| Archive | `.planning/milestones/v1.13-ROADMAP.md`, `v1.13-REQUIREMENTS.md`, `v1.13-MILESTONE-AUDIT.md`, and `v1.13-phases/` preserve four phases, 26 plans, 26 summaries, 54 tasks, and the full evidence history. |
| Verification | Open-artifact audit is clear; archived requirements are checked 21/21; milestone audit passes 4/4 phases, 12/12 integration seams, and 6/6 flows; all four Nyquist ledgers are compliant; cleanup moved exactly four phase directories and 86 files; `git diff --check` passes. |
| Lifecycle result | The live roadmap points to the v1.13 archive, `.planning/phases/` has no active milestone directory, the milestone-scoped root `REQUIREMENTS.md` is removed for fresh next-cycle definition, the annotated `v1.13` tag identifies the final lifecycle commit, and current owners report “awaiting next milestone.” |

Outcome:

- v1.13 ships exactly seven eyebrow rows and branch `眉毛` at SDK-core scope.
- No Demo/device/commercial/performance/packaging/shipping/launch-readiness claim was added.
- The next workflow is `$gsd-new-milestone`; no future scope is inferred.

### C-2026-07-28-v1-13-milestone-audit-passed

| Field | Value |
| --- | --- |
| Completed | 2026-07-28 |
| Scope | Independently re-audited all Phase 49-52 canonical verifications, three-source requirement coverage, runtime/artifact seams, end-to-end flows, review/security evidence, Nyquist classification, and closure of all prior audit debt. |
| Verification | 21/21 requirements, 4/4 phase verifications, 12/12 integration seams, 6/6 flows, 4/4 validation ledgers and 54/54 task rows pass; checker gates pass 4/4, 130/130, and pre-audit 35/35; review is clean 0/0/0/0 and security has zero open threats. |
| Status | `passed`; zero blocker, zero warning, zero residual milestone tech debt. |
| Boundary | The audit authorizes milestone lifecycle closeout only; physical-device/commercial/performance/packaging/shipping/launch/release-readiness remain separate evidence scopes. |

Outcome:

- All three findings from the prior `tech_debt` audit are closed and the old verdict is superseded.
- The complete public-contract → Vision support → provider/resolver → public output → safety/promotion chain is wired with no orphaned export.
- Archive, tag, cleanup, and push are now the remaining user-authorized actions.

### C-2026-07-28-v1-13-audit-tech-debt-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-07-28 |
| Scope | Resolved the prior audit's two governance findings without changing SDK runtime behavior: dispositioned Phase 50's three human judgments and normalized Phase 50/52 validation lifecycle status. Fixed the two documentation review warnings and reran the independent Phase 52 review. |
| Verification | Phase 50 human review passes 3/3; Phase 50 boundary self-test passes 4/4 and live mode passes; Phase 50 verification is `passed`; Phase 50/52 validation is `validated`; current Phase 52 review is clean across 28 files with 0/0/0/0 findings and 154 focused tests pass with one documented skip; checker self-test and live readiness pass 130/130 and 35/35. |
| Status | Remediation completed; the subsequent independent v1.13 milestone audit rerun passed. |
| Boundary | No audit override, archive, tag, cleanup, UI/device/commercial/performance/packaging/shipping/launch/release claim is made by remediation. |

Outcome:

- Eyebrow support has no identity/recognition/authentication/profiling use, no synthetic/generated/eye-derived production substitute, and no Phase 50 downstream-scope overclaim.
- The validation vocabulary now agrees with current lifecycle tooling while preserving historical execution evidence.
- The prior `tech_debt` audit remains historical until the independent rerun replaces its verdict.

### C-2026-07-27-v1-13-milestone-audit-tech-debt

| Field | Value |
| --- | --- |
| Completed | 2026-07-27 |
| Scope | Independently aggregated all four phase verifications, all 26 summaries, 21 requirement traceability rows, cross-phase source wiring, six end-to-end flows, and Nyquist discovery. |
| Verification | Requirements 21/21, integration seams 12/12, and flows 6/6 are satisfied with zero critical gap. The integration checker reports complete runtime wiring and no orphaned export. |
| Status | Historical `tech_debt` verdict, superseded on 2026-07-28 after all three items were remediated and the independent audit rerun passed. |
| Boundary | No audit override, archive, tag, cleanup, UI/device/commercial/performance/packaging/shipping/launch/release claim is made. An explicit accept-or-remediate decision is required before milestone closeout. |

Outcome:

- The complete public-contract → observed-support → provider/resolver → facade → strict-output → safety/promotion chain is wired.
- All 21 v1.13 requirements are satisfied; the remaining items are governance/validation status debt rather than product gaps.
- `.planning/v1.13-MILESTONE-AUDIT.md` is authoritative for the decision gate.

### C-2026-07-27-phase-52-ten-plan-independent-verification

| Field | Value |
| --- | --- |
| Completed | 2026-07-27 |
| Scope | Completed all ten Phase 52 plans, including production-path proof repairs, fresh evidence, independent clean review, routed/planning owner synchronization, and final independent re-verification. |
| Verification | Independent `gsd-verifier` passes 16/16 must-haves. Fresh evidence includes 450 SwiftPM tests with six conditional skips, eight focused suites, strict 72/72 portrait output plus thirteen separate no-face comparisons, 130/130 checker self-tests, 23/23 green Nyquist, a clean 28-file current review, simulator build/test, no `BeautyDemo` change, and diff hygiene. |
| Requirements | SAFE-01, SAFE-02, SAFE-03, and DOC-01 are satisfied. |
| Boundary | Phase 52 completion is SDK-core-only and does not claim milestone audit, archive, tag, cleanup, UI/device/commercial/performance/packaging/shipping/launch/release readiness. Next action: independent v1.13 milestone audit. |

Outcome:

- Exactly seven eyebrow rows and branch `眉毛` are implemented through private request-scoped support, aggregate-only diagnostics, exact final caps, one 44-field fixed point, and stable unified dispatch.
- All prior verification gaps are closed through executable production-path evidence rather than planning assertions.
- Phase 52 is accepted; milestone lifecycle remains a separate gated workflow.

### C-2026-07-27-phase-52-six-plan-closeout-superseded

| Field | Value |
| --- | --- |
| Completed | 2026-07-27 |
| Scope | Historical Plans `52-01` through `52-06` completed exact final eyebrow caps, lifecycle/local-failure evidence, exact 44-field convergence, initial fail-closed gates, and seven-row/branch SDK-core promotion. This checkpoint was later superseded by the ten-plan gap-closeout workflow. |
| Verification | Historical focused/full/output/gallery/image/security evidence remains valid for that checkpoint. Its clean-review and fourteen-task Nyquist claims are superseded by the current ten-plan record, exact 23-task ledger, and fresh independent review. |
| Requirements | SAFE-01, SAFE-02, SAFE-03, and DOC-01 were recorded complete at the six-plan checkpoint; the later ten-plan independent verification now supplies final Phase 52 acceptance. |
| Boundary | This is a superseded historical checkpoint, not the final Phase 52 verdict. The current ten-plan verification passes; milestone audit, archive, tag, cleanup, UI/device/commercial/performance/packaging/shipping/launch/release readiness remain separate and unclaimed. |

Outcome:

- Seven exact final `0.25` caps and the complete request-local degradation and transition matrix agree with bounded provider formulas and aggregate-only diagnostics.
- One 44-field retained mask totals `13.45`, scales once, removes monotonically, and agrees with final named emissions and stable unified dispatch.
- Exactly seven eyebrow rows and branch `眉毛` are implemented at SDK-core scope across all owners; generated evidence remains ignored, untracked, unstaged, and disposable.

### C-2026-07-27-phase-51-public-facade-eyebrow-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-27 |
| Scope | Five plans completed exact public renderer cases, bounded strict decoded evidence, mandatory actual-image review, descriptor-safe gallery publication, and owner/requirement closeout. |
| Verification | Renderer 16/16; facade 18 pass plus one opt-in skip; provider 12/12; full SwiftPM 438 with six opt-in skips; strict 72/72 portrait, 13/13 visibility, 6/6 direction, 21/21 distinctions, 40/40 direct, 13/13 no-face; gallery 144/144; containment/privacy/scope/diff gates pass. |
| Requirements | OUT-01, OUT-02, and OUT-03 complete. |
| Boundary | Phase 52 remains the unstarted owner of final caps, exhaustive safety, seven-row and `眉毛` branch promotion, SAFE-01..03, and DOC-01. |

Outcome:

- All thirteen provisional eyebrow cases are visible, brow-local, signed as intended, and semantically distinct on the one authorized portrait through the existing public-facade/one-warp route.
- The fourteen-file original-detail review agrees with frozen pixel evidence; exact count vocabulary keeps 72 portrait outputs separate from thirteen no-face comparisons and the 144-file two-fixture total.
- Generated evidence is disposable and contained. No public raw geometry, internal-renderer bypass, dependency/model/resource/network/cloud/Demo behavior, product promotion, or release claim was introduced.

### C-2026-07-24-phase-50-independent-eyebrow-geometry-and-pipeline

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Six plans across five waves completed GEOM-01..GEOM-07 and PIPE-01/PIPE-02 at compiled SDK-core provider/routing scope. |
| Decisions | Adopted A1 dedicated `.eyebrows`; A2 provisional seven `0.25` caps and `13.45` total; A3 provisional geometry constants; A4 image-Y/tilt sign; A5 endpoint/apex weights; A6 reused exact `0.5`; A7 phase-local checker. |
| Verification | Fixture preflight; checker 4/4 self/live; focused 11/26/14/15/48/3/18; BeautyEffects 243 with one opt-in skip; full SwiftPM 433 with three opt-in skips; privacy/scope/artifact/ledger/diff gates pass. Post-review CR-01 regression passes the expanded provider suite 12/12; a fresh full SwiftPM attempt executed 434 with three opt-in skips and eight failures because `example-images/input/portraits/e1.png` is absent from the isolated worktree. |
| Requirements | GEOM-01, GEOM-02, GEOM-03, GEOM-04, GEOM-05, GEOM-06, GEOM-07, PIPE-01, and PIPE-02 complete. |
| Boundary | Phase 51 retains decoded output/gallery ownership; Phase 52 retains final caps, exhaustive safety, seven-row/branch promotion, and QUALITY_SCORE/feature-ledger ownership. No phase transition is performed here. |

Outcome:

- Seven distinct canonical-trace providers converge through one exact 44-name monotone mask and one stable Face→Chin→Eye→Eyebrow→Nose→Mouth dispatch; final arrays, aggregate metrics, and facade routing agree.
- Review CR-01 is fixed: a degenerate local thickness tangent now omits only its balanced sample pair, and finite pairs from the same eyebrow side remain eligible.
- Side/pair/chord/apex, provider-empty, freshness, sequential, and concurrent evidence is field-local and request-isolated. Raw geometry remains package-only; public evidence remains aggregate and redacted.
- The renderer/gallery inventory remains 59 and all seven eyebrow product rows remain `future`. v1.14-v1.16, Demo/UI, device, commercial, performance, packaging, shipping, and release readiness remain unclaimed.
- Makeup/texture synthesis, synthetic or eye-derived substitution, and ethical/scope prohibitions were retained as unverified at the original Phase 50 closeout. They were subsequently dispositioned 3/3 in `50-HUMAN-REVIEW.md` without adding commercial-naturalness or release-readiness claims.

### C-2026-07-24-phase-50-plan-05-combined-safety-and-unified-dispatch

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Completed exact 44-field final-mask/provider agreement, representative eyebrow degradation, exactly-once unified dispatch, and seven redacted public-facade routes. |
| Commits | RED convergence `768af68`; Task 01 completion `a91b9e3`; unified dispatch `b9e7d89`; facade routing `ea02f7d`. |
| Verification | Combined 15/15, degradation 48/48, pipeline 3/3, facade 18/18, live boundary checker, and diff hygiene pass. |
| Boundary | Full SwiftPM, owner synchronization, review, and Phase 50 closeout remain Plan 50-06; decoded output remains Phase 51 and final calibration/promotion remains Phase 52. |

Outcome:

- Exact final emissions, point count, and dispatch use stable Face→Chin→Eye→Eyebrow→Nose→Mouth order with one eyebrow provider call.
- Side/pair/chord/apex, freshness, provider-empty, sequential, and concurrent evidence removes only dependent eyebrow work while safe siblings continue.
- All seven public intents trigger one request-local detector/facade/pipeline route and expose only existing aggregate metrics and redacted degradation.

### C-2026-07-24-phase-50-plan-04-exact-eyebrow-conflict-ledger

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Added all seven eyebrow strengths exactly once to the shared scale, absolute-total, and retained-count inventories in stable eye→eyebrow→nose order. |
| Commits | RED inventory evidence `b59f16d`; GREEN conflict integration `8eba1b7`; exact arithmetic evidence `80e6de8`. |
| Verification | Focused conflict suite passes 14/14; source cardinality passes 7 scale and 14 total/count references; `git diff --check` passes. |
| Boundary | The 0.25 eyebrow caps and 13.45 total remain provisional; provider/dispatch agreement, facade evidence, decoded output, final calibration, promotion, Demo/UI, and release claims remain later work. |

Outcome:

- The exact provider-eligible ledger is face/chin 3.35 + eye 4.10 + eyebrow 1.75 + nose 1.80 + mouth 2.45 = 13.45 across 44 distinct names.
- Threshold 1.0 yields one shared scale of `1 / 13.45`, weakened count 44, final absolute total 1.0, and preserved polarity for all signed eyebrow values.
- Seven one-field removals prove each absent/provider-ineligible eyebrow name contributes zero without changing unrelated signs or adding a brow-specific weakening path.

### C-2026-07-24-phase-50-plan-03-eyebrow-resolver-integration

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Routed seven eyebrow intents through provisional caps, exact reuse scaling, provider preflight, exact 44-pass convergence, and aggregate-only final resolver evidence. |
| Commits | TDD routing `e5141d5` / `8574e02`; TDD lifecycle `5c57fcf` / `15f9c70`. |
| Verification | Resolver suite passes 26/26; provider suite passes 11/11; boundary self-test passes 4/4; source locks and `git diff --check` pass. |
| Boundary | Conflict arithmetic, unified dispatch/facade evidence, decoded output, final calibration, exhaustive closure, promotion, Demo/UI, dependency/resource/model/network, and release claims remain later-plan work. |

Outcome:

- All seven normalized eyebrow fields reach same-named provisional `0.25` effective strengths and aggregate `.eyebrows` activity without aliasing `.eyes` or `.faceShape`.
- Fresh work stays full, reused work scales once by exact `0.5`, stale/no-face work zeros, and provider-empty fields are removed locally before final evidence.
- Fixed `eyebrow_inputs_missing`, aggregate `beauty.effects.skippedEyebrowDomains`, and total geometry point count disclose no side, support, coordinate, or provider detail.

### C-2026-07-24-phase-50-plan-02-independent-eyebrow-provider

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Added seven effective eyebrow strength names plus direct canonical-trace vertical, thickness, length, pair spacing, head spacing, tilt, and stored-apex named emissions with field-local sanitization. |
| Commits | Core provider `43d09d4`; remaining geometry and checker transition `739160d`. |
| Verification | Focused provider suite passes 11/11; three Task 01 named filters pass independently; Phase 50 checker self-test passes 4/4; `git diff --check` passes. |
| Boundary | Constants/cap remain provisional; no resolver, conflict, unified dispatch, facade, renderer/gallery, final safety, promotion, Demo/UI, dependency/resource/model/network, or release claim was added. |

Outcome:

- GEOM-01 through GEOM-07 now have distinct provider-owned work sourced only from sealed canonical eyebrow traces; only whole spacing requires both sides.
- PIPE-01 has exact named emission arrays and field-local provider-empty sanitization, while resolver/facade integration remains Plan 50-03 and later work.
- Invalid input fails closed before control-point creation and shipped face/chin/eye/nose/mouth provider arrays remain unchanged for eyebrow-only strengths.

### C-2026-07-24-phase-50-plan-01-eyebrow-geometry-wave-zero

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Established the Phase 50 fail-closed pre-implementation boundary, seven deliberately RED named eyebrow-emission contract families, seventeen edge-category predicates, and request-local paired/partial/missing/malformed facade fixtures. |
| Commits | Checker `0df267d`; RED contracts `cec2c4b`; request-local fixtures `511ab27`; RED diagnostic isolation `5b8b9f2`; summary `5ffc979`. |
| Verification | Checker self-test 4/4 and pre-implementation mode pass; focused provider compilation is expected RED only on the absent eyebrow provider/effective-strength surface; the production `BeautySDK` target builds; diff hygiene passes. |
| Boundary | No production provider, resolver/conflict/pipeline implementation, output/gallery evidence, final caps, promotion, dependency/resource/model/network behavior, or UI/device/commercial/release scope was added. |

Outcome:

- Plan 50-02 can implement the named provider and effective-strength surface against the committed RED contract.
- GEOM-01 through GEOM-07 and PIPE-01 through PIPE-02 remain milestone requirements pending production implementation and later Phase 50 evidence; Plan 50-01 completes their Wave 0 contract work only.
- Because SwiftPM compiles the whole test target before filtering, unrelated XCTest filters remain blocked by the intentional RED file until Plan 50-02 supplies the missing production surface; no facade-suite green claim is made.

### C-2026-07-24-phase-49-plan-02-neutral-public-eyebrow-contract

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Expanded `BeautyParameters` to exactly 59 stored fields (58 numeric plus `filterId`) with six signed eyebrow values, one positive-only peak value, and zero-default finite normalization while keeping all seven values runtime-inert. |
| TDD | Public contract RED/GREEN `91d8a4b`/`a36b99f`; compatibility, preset, and inertness evidence `41e3ff4`. |
| Compatibility | Complete unequal 59-key JSON round-trips exactly; removing all seven eyebrow keys produces a real legacy 52-key payload that decodes seven zeros; historical 31/33/38/48/52 fixture meanings remain distinct. |
| Verification | `BeautyParametersTests` 37/37, `BeautyResourceCatalogTests` 10/10, and `BeautyEffectResolverTests` 23/23 pass; checker self-tests pass 42/42; five pinned preset hashes are unchanged; `git diff --check` passes. |
| Environment gate | Full SwiftPM remains not run under the inherited missing `example-images/input/portraits/e1.png` preflight; no full-suite green claim is made. |

Outcome:

- `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, and `eyebrowTilt` are independent signed `-1...1` values; `eyebrowPeakDefinition` is independent `0...1`; all non-finite values become zero.
- Exactly five bundled presets remain byte-identical, omit every eyebrow key, and decode seven zeros.
- Nonzero eyebrow values do not trigger face geometry or alter effective strengths, domains, warnings, metrics, named emissions, or unified control points.
- Provider/resolver production, facade, renderer/gallery, Demo/UI, resource, network, persistence, dependency, and product-promotion scope remains unchanged for Phase 50 and later.

### C-2026-07-24-phase-49-plan-01-eyebrow-wave-zero-safeguards

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Created the Phase 49 fail-closed boundary checker, immutable request-local raw/semantic eyebrow seams, and compiled Wave 0 preflight/canonicalization/topology/lifecycle fixture vocabulary without activating production mapping or providers. |
| TDD | Checker RED/GREEN `0324355`/`472ea6e`; contract RED/GREEN `c8f2120`/`ea301ab`; fixture commit `d8c9ab3`. |
| Verification | Checker self-tests pass 42/42; BeautyDetection executes 52 with 2 opt-in skips and 0 failures; adapter executes 36 with 1 opt-in skip and 0 failures; `git diff --check` passes. |
| Environment gate | `example-images/input/portraits/e1.png` remains absent; exact fixture preflight exits nonzero and never reports the full suite green. |

Outcome:

- `BeautyObservedEyebrowSide`, `BeautyObservedEyebrowSupport`, `BeautyEyebrowSemanticTrace`, and `BeautyEyebrowSemanticSupport` are private, immutable, default-nil, and aggregate-only in diagnostics.
- Exact 0/1/15/16/17 preflight rows, 32 canonicalization rows per side, 3/4/5/15/16/17 semantic rows, malformed topology categories, lifecycle cases, and eight parallel identities compile for Plans 49-03/49-04.
- Provider/resolver/facade/renderer/Demo/promotion/dependency/model/resource/network/persistence and generated-artifact scope remains prohibited.

### C-2026-07-24-v1-12-milestone-completion

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Completed the autonomous v1.12 lifecycle after the passed independent audit: archived ROADMAP, REQUIREMENTS, audit, and all Phase 45-48 artifacts; collapsed the live roadmap; evolved PROJECT/STATE; and recorded the milestone retrospective. |
| Archive | `.planning/milestones/v1.12-ROADMAP.md`, `v1.12-REQUIREMENTS.md`, `v1.12-MILESTONE-AUDIT.md`, and `v1.12-phases/` preserve 4 phases, 20 plans, 20 summaries, and the full evidence history. |
| Verification | The open-artifact audit is clear; archived requirements are checked 18/18; the milestone audit passes 4/4 phases, 11/11 integration seams, and 6/6 flows; all four Nyquist ledgers are compliant; `git diff --check` passes. |
| Lifecycle result | The live roadmap now points to the v1.12 archive, `.planning/phases/` has no active milestone directory, the milestone-scoped root `REQUIREMENTS.md` is removed for fresh next-cycle definition, and root owners consistently report “awaiting next milestone.” |

Outcome:

- v1.12 ships exactly four contour-driven face rows; three semantic-region rows remain future and branch `脸型` remains partial.
- No Demo/device/commercial/performance/packaging/shipping/launch-readiness claim was added.
- The next authorized workflow is `$gsd-new-milestone`; no next scope is inferred.

### C-2026-07-24-v1-12-independent-milestone-audit

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Independently audited the reduced-scope v1.12 result across original intent, 18 requirements, four phases, 20 plans/summaries, source/privacy boundaries, runtime, strict output, integration seams, flows, owners, and nonclaims. |
| Requirements | FACE-07..09, FACE-12, SUPP-01..02, SUPP-04, GEOM-01..04, OUT-01..03, SAFE-01..03, and DOC-01 pass 18/18. |
| Integration and flows | 11/11 cross-phase seams and 6/6 end-to-end flows pass with no critical gap, broken flow, orphaned requirement, or milestone-specific technical debt. |
| Fresh evidence | Full SwiftPM passes 375 with three opt-in skips; live support boundary passes 13/13; Phase 48 self-test passes 70/70; strict output passes 413/413, 18/18, 49/49, 6/6, and 4/4. |
| Result | `.planning/v1.12-MILESTONE-AUDIT.md` records `status: passed`. DOC-01 is complete; the milestone is eligible for archive/tag/cleanup lifecycle work. |

Outcome:

- Exactly four contour-driven rows remain implemented; three semantic-region rows remain future and branch `脸型` remains partial.
- The audit normalized only two ROADMAP requirement-count cells; runtime and product scope did not change.
- Archive, tag, cleanup, shipping, and launch actions are not claimed until their workflows succeed.

### C-2026-07-24-phase-48-face-safety-and-scoped-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Completed Phase 48 across Plans `48-01` through `48-06`: final exact caps, complete nine-field transitions, exact 37-field convergence, fail-closed boundaries, fresh immutable output evidence, exact four-row promotion, owner synchronization, and goal-backward verification. |
| Safety | The four additions have exact final `0.25` caps. All nine face/chin fields have stateless fresh/reused/stale/no-face and field-local missing/malformed/provider-empty evidence; reused non-eye geometry scales by exact `0.5` and diagnostics remain aggregate/redacted. |
| Convergence | The exact retained inventory is 37 fields at total `11.70` with one scale `1/11.70`, at most 37 monotone removals, no re-entry/double scaling, and exact final named-provider/dispatch agreement. |
| Output and status | The unchanged strict gate passes 413/413 decoded outputs, 18/18 visibility/locality, 49/49 fixed-neighbor, 6/6 ineligible, and 4/4 no-face comparisons. Exactly `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` are implemented; three semantic-region rows remain future and branch `脸型` remains partial. |
| Verification | Focused suites pass 132/132; full SwiftPM executes 375 with three opt-in Apple Vision skips and zero failures. The boundary checker passes 70/70 self-tests, 17/17 pre-promotion, 18/18 promotion, and 24/24 owner gates. Review is clean; ASVS L1 records `threats_open: 0`; generated output/gallery remain ignored, untracked, and unstaged. |

Outcome:

- SAFE-01, SAFE-02, and SAFE-03 are complete with one-to-one runtime/static/output evidence.
- DOC-01 implementation is complete; independent milestone-audit confirmation remains pending.
- `去双下巴`, `去双下巴 Pro`, `发际线`, and whole-`脸型` completion remain future or partial.
- No Demo/device/commercial/performance/packaging/shipping/launch-readiness, audit, archive, or tag completion is claimed by Phase 48.

### C-2026-07-24-phase-47-public-facade-face-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-24 |
| Scope | Completed Phase 47 across Plans `47-01` through `47-03`: exact isolated public cases, representative facade degradation, bounded decoded output evidence, and descriptor-safe ignored gallery publication. |
| Public output | Four provisional `0.25` cases extend the renderer from 55 to exactly 59 while retaining one public `BeautyEngine.processResult` call. The strict helper accepts 413/413 decoded same-dimension PNGs across seven fixtures. |
| Semantics | Fixed shared face regions pass 18/18 eligible visibility/locality checks with no outside signal; eleven constant comparator families pass 49/49 distinctions. Six ineligible portrait pairs and all four no-face cases are exact safe no-ops. |
| Degradation and artifacts | Missing/malformed observed contour removes all four new fields through the public facade while an eligible shipped sibling continues with aggregate-only diagnostics. Gallery publication is an exact 413-file renderer/output/gallery bijection; generated files are ignored, untracked, unstaged, and disposable. |
| Verification | Focused suites pass 15 renderer and 16 facade tests. Full SwiftPM executes 371 with three opt-in Apple Vision skips and zero failures. Helper and gallery self-tests, final clean strict render, package/predecessor hashes, privacy/scope/no-promotion scans, artifact containment, and phase-range/working-tree diff hygiene pass. Standard review is clean; goal verification passes 16/16; Nyquist reports zero gaps; ASVS L1 closes all 14 threats plus three repository governance inputs with `threats_open: 0`. |

Outcome:

- OUT-01, OUT-02, and OUT-03 are complete with aggregate committed evidence in `47-FACE-OUTPUT-EVIDENCE.md`.
- SAFE-01 through SAFE-03 and DOC-01 remain Phase 48. Final caps/dead zones, exhaustive transitions/convergence, exact four-row promotion, root owner synchronization, and branch-level `脸型` status are unchanged.
- `去双下巴`, `去双下巴 Pro`, `发际线`, Demo/device/commercial/performance/packaging/shipping/readiness work, and whole-`脸型` completion remain future or partial.

### C-2026-07-23-phase-46-independent-contour-and-chin-geometry

| Field | Value |
| --- | --- |
| Completed | 2026-07-23 |
| Scope | Completed Phase 46 across Plans `46-01` through `46-06`: RED-first named-emission contracts, four local providers, provisional effective caps, complete resolver/conflict lifecycle, deterministic observed-support facade routing, full evidence, and owner synchronization. |
| Geometry | `faceContourSmooth` uses centered neighbor-chord continuity; `templeFullness` uses upper-lateral outward bands; `cheekboneSlim` uses disjoint mid-lateral inward bands; `chinTaper` uses centerline-gated apex neighbors with X-only movement. Five shipped face/chin arrays remain unchanged. |
| Accounting | Four provisional caps are exact `0.25`; eligible reuse is exact `0.5`. Seven face plus two chin named emissions join the existing eye/nose/mouth providers through one retained baseline, exact 37-field/11.70 arithmetic, at most 37 monotone removals, no re-entry, and exactly-once final point accounting. |
| Degradation and privacy | Missing contour removes all four new fields; missing/malformed centerline removes taper only; no-face/stale zero new work; provider-empty work contributes no final evidence; safe siblings continue. Observed support remains package-only, request-scoped, non-Codable, non-persistent, non-networked, and aggregate-only in diagnostics. |
| Verification | Focused suites pass 17 provider, 21 resolver, 13 conflict, 14 combined, 2 pipeline, 43 degradation, and 15 facade tests. `BeautyEffectsTests` executes 205 with one opt-in Apple Vision skip; full SwiftPM executes 368 with three opt-in skips; all have zero failures. Boundary self-test/live pass 24/24 and 14/14; pinned hashes, artifact containment, and `git diff --check` pass. |

Outcome:

- GEOM-01, GEOM-02, GEOM-03, and GEOM-04 are complete for provider ownership, resolver/conflict accounting, representative degradation, unified dispatch, deterministic public-facade routing, and redacted aggregate evidence.
- Phase 47 exclusively owns decoded output, ROI/locality visibility, renderer cases, and gallery evidence. Phase 48 exclusively owns final caps/dead zones, exhaustive nine-face/37-field matrices, safety closeout, exact row promotion, and branch status.
- `去双下巴`, `去双下巴 Pro`, `发际线`, Demo/device/commercial/performance/packaging/shipping/readiness work, and whole-`脸型` completion remain future or partial.
- Three repository-specific governance inputs were carried explicitly into `$gsd-secure-phase`: observed support must not become biometric profiling data; the seven-point proxy must not be represented as observed support; deferred semantic rows must not be silently activated. `46-SECURITY.md` verifies all three for the current repository scope and records `threats_open: 0`.

### C-2026-07-23-phase-45-public-contract-and-observed-face-support

| Field | Value |
| --- | --- |
| Completed | 2026-07-23 |
| Scope | Completed Phase 45 across Plans `45-01` through `45-05`: exact 52-field public compatibility, actual request-local Vision face contour/median mapping, bounded face-specific validation, independent semantic eligibility, authoritative owner synchronization, and fail-closed closeout. |
| Public contract | `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` are independent positive-only default-zero scalars; legacy 48-key payloads and all five byte-identical bundled presets remain neutral, while signed `chinLength` and shipped resolver output remain unchanged. |
| Support boundary | Actual contour and median values are copied from the existing single Vision request, independently preflighted at 32/16 points, mapped once through request-local metadata, canonicalized by whole-path reversal, and validated without substituting the exact seven-point compatibility proxy. |
| Isolation | Contour-only and contour-plus-centerline eligibility remain distinct; malformed optional regions fail locally, interruption persists nothing, and repeated/parallel requests share no support state. Raw coordinates remain private, ephemeral, non-Codable, non-persistent, and absent from diagnostic payloads; approved descriptions and structural reflection expose aggregate counts only, outside identity/biometric-profiling claims. |
| Verification | Boundary checker passes 36/36 self-tests and 13/13 live checks; focused suites pass 32/32 parameters, 9/9 resources, and 20/20 resolver tests, while detector executes 20 tests with 2 opt-in integration skips, mapping passes 15/15, adapter executes 32 tests with 1 opt-in integration skip, and complete detection executes 50 tests with 2 opt-in integration skips, all with 0 failures. Full SwiftPM executes 354 tests with 3 opt-in integration skips and 0 failures; `git diff --check` passes. |

Outcome:

- FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, and SUPP-04 are closed without dependency, model, resource, network, provider, resolver, facade, renderer, Demo, or generated-artifact expansion.
- Phase 46 still owns providers, effective strengths, caps, routing, and consumption; Phase 47 owns public saved-output evidence; Phase 48 owns final safety and row promotion.
- `去双下巴`, `去双下巴 Pro`, `发际线`, and branch-level `脸型` remain future or partial. No device, commercial, performance, packaging, shipping, launch-readiness, or milestone-completion claim is made.

### C-2026-07-23-phase-45-plan-04-face-topology-validation

| Field | Value |
| --- | --- |
| Completed | 2026-07-23 |
| Scope | Completed Phase 45 Plan `45-04`: face-specific open-contour and median validation, independent contour/centerline eligibility, cross-support apex consistency, and legacy/sibling isolation. |
| Topology | Contour accepts 7...32 points and median accepts 3...16; every point is finite, closed-unit, exact-bit unique, and validated through face-relative width, height, endpoint chord, curvature, direction, median chord-position, apex-distance, and interior-side predicates without eye constants, sorting, or polygon area. |
| Isolation | Missing or malformed contour produces no observed semantic support; invalid/missing median preserves contour-only eligibility. The exact seven-point compatibility proxy plus all eye, nose, root, tip, and lip siblings remain unchanged, including alternating valid-invalid-valid requests. |
| Verification | Focused adapter tests pass 27/27, all BeautyDetection tests pass 48/48, full SwiftPM passes 347/347, all six committed portraits satisfy the locked aggregate validation gate, and `git diff --check` passes. |

Outcome:

- `FaceGeometry.observedFaceSupport` now distinguishes legacy-only, contour-only, and contour-plus-centerline evidence without routing any new field to a provider, resolver, facade, renderer, or metric.
- The A1 bounds remain unchanged: contour 7...32, median 3...16, width 0.50...1.00, height 0.20...1.00, endpoint separation at least 0.35, curvature at least 0.10, median down at least 0.25, chord position 0.15...0.85, apex distance at most 0.40, and two contour points on each apex side.
- Phase 45 Plan `45-05` remains responsible for owner-contract synchronization and live boundary closeout; Phase 46 owns provider consumption.

### C-2026-07-23-phase-45-plan-03-observed-face-mapping

| Field | Value |
| --- | --- |
| Completed | 2026-07-23 |
| Scope | Completed Phase 45 Plan `45-03`: actual Vision `faceContour` and `medianLine` capture in the existing request, bounded independent mapping, mapper-axis canonical direction, and request/concurrency isolation. |
| Mapping | Raw face-local regions are copied immediately, preflighted independently at fixed ceilings of 32 contour and 16 median points, composed into Vision image space, and mapped exactly once per accepted point. Invalid optional regions become nil without erasing the selected face or valid sibling region; invalid shared bounds retain the existing observation-level mapping failure. |
| Canonicalization | The 4-orientation × 2-input-mirror matrix passes for forward/reversed contour and median inputs. Canonical direction uses mapper-derived face-local right/down axes and whole-array reversal only; preview mirroring is invariant and adjacency is preserved. |
| Lifecycle | Consecutive opposite-metadata calls and eight parallel detector values preserve independent payloads with no retry, cache, persistence, framework-region retention, or raw diagnostic output. Six committed portraits are evaluated through aggregate availability/count gates only. |
| Verification | Focused mapping tests pass 15/15, focused detector tests pass 18/18 with Apple Vision host access, full SwiftPM passes 338/338, and `git diff --check` passes. |

Outcome:

- `VisionDetectionObservation` now carries optional face support beside existing eye support without changing the public surface, detector request count, selection contract, or shipped seven-point proxy.
- Exact closed-unit edges are accepted; outside, non-finite, oversized, and direction-degenerate regions fail independently and deterministically.
- Phase 45 Plan `45-04` can validate mapped open-path topology at the adapter boundary; providers, routing, output, final caps, and promotion remain downstream.

### C-2026-07-23-phase-45-plan-02-public-face-contract

| Field | Value |
| --- | --- |
| Completed | 2026-07-23 |
| Scope | Completed Phase 45 Plan `45-02`: exact 48-to-52 public `BeautyParameters` compatibility for `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`, without activating provider or resolver routing. |
| Contract | The model is exactly 52 stored fields (51 numeric plus `filterId`); all four additions are independent positive-only values, default/missing/non-finite inputs become zero, and `normalized()` returns a clamped copy without mutating the source. |
| Compatibility | Unequal 52-key JSON round-trips independently; legacy 48-key JSON and the reconstructed 38-key payload decode the four fields as zero; historical literal 31/33 counts remain unchanged; all five bundled preset hashes remain byte-identical and decode four zeros. |
| Verification | Focused suites pass 32/32 parameter, 9/9 resource, and 20/20 resolver tests; `git diff --check` passes. The full SwiftPM probe executed 325 tests and reproduced the prior host-environment-only 86 CoreImage/CoreVideo/Vision failures while all changed focused suites remained green. |

Outcome:

- Explicit zero additions preserve the complete shipped face/eye/nose/mouth resolver plan, and nonzero additions do not yet require face geometry or enter any provider path.
- Phase 46 remains the sole owner of provider eligibility, effective strengths, caps, emissions, and routing for the four new intents.
- No preset JSON, package manifest, provider, resolver production, renderer, facade, or Demo source changed.

### C-2026-07-23-phase-45-plan-01-face-support-safeguards

| Field | Value |
| --- | --- |
| Completed | 2026-07-23 |
| Scope | Completed Phase 45 Plan `45-01`: a fail-closed face-support boundary checker, private request-local observed contour/median contracts, face-specific topology matrices, and preserved seven-point proxy compatibility. |
| Requirements | SUPP-02 and SUPP-04 complete. Raw and derived face support remains package-only, non-Codable, non-persistent, non-diagnostic, non-networked, and unavailable to Demo imports. |
| TDD | RED commits `e8c5f14` and `78146c6`; GREEN commits `d870693` and `30164fc`. |
| Verification | Boundary checker self-tests pass 34/34; focused `BeautyFaceGeometryAdapterTests` pass 18/18 with SwiftPM sandbox disabled; `git diff --check` passes. The optional full suite built and ran 319 tests but reported 86 host-environment CoreImage/CoreVideo/Vision failures, while the changed suite remained 18/18. |

Outcome:

- `BeautyObservedFaceSupport` carries contour and median-line evidence independently and only for the current request; `BeautyFaceSemanticSupport` derives eligibility without exposing public or persisted state.
- The shipped seven-point `FaceGeometry` proxy remains a separate optional compatibility path and is not relabeled as observed support.
- Double-chin, double-chin Pro, hairline, provider behavior, public parameters, and live boundary closeout remain owned by later plans or future scope.

### C-2026-07-21-gsd-plan-phase-45-public-contract-observed-face-support

| Field | Value |
| --- | --- |
| Completed | 2026-07-21 |
| Scope | Planned Phase 45 `Public Contract and Observed Face Support` as five executable plans in four dependency waves: Wave 0 safeguards/contracts, exact public compatibility, actual Vision capture/canonical mapping, topology validation/isolation, and final owner/boundary closeout. |
| Requirements | FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, and SUPP-04 are covered across all five plans; D-01 through D-20 are cited directly in implementation actions and the final multi-source audit. |
| Source/Probe Audit | ROADMAP goal, all seven requirement IDs, research constraints, and all locked context decisions are covered with no missing item. The specless edge probe resolves request-local immutability, exactly-once mapping, interruption/no persistence, malformed-region isolation, and shared-state concurrency; three bespoke prohibitions remain descriptor-less `flagged-unverified` inputs to the fail-closed checker rather than fabricated checks. |
| Validation | `45-VALIDATION.md` maps ten tasks to focused automated commands. Plan `45-01` owns Wave 0 creation of the self-tested boundary checker plus face-specific topology fixtures; Plan `45-05` owns live checker/full SwiftPM closeout. Frontmatter, structure, requirement, decision, wave/file-ownership, source-audit, and diff-hygiene checks are planning gates. |
| Build | Not run because this workflow creates planning and validation documents only; every implementation task specifies a narrow automated command and the final plan requires the full SwiftPM suite. |

Outcome:

- `45-01` runs alone in Wave 1; `45-02` and `45-03` run concurrently in Wave 2 with disjoint file ownership; `45-04` runs in Wave 3; `45-05` closes in Wave 4.
- Exact 48→52 compatibility and actual private contour/median support are planned without providers, resolver routing, facade output, render passes, Demo UI, dependencies, targets, resources, models, network, or persistence.
- The shipped seven-point proxy remains a separate compatibility path; deferred double-chin, hairline, and semantic-region work remains future and cannot be claimed by Phase 45.

### C-2026-07-21-v1-12-milestone-initialization

| Field | Value |
| --- | --- |
| Completed | 2026-07-21 |
| Scope | Initialized v1.12 `Face Shape Remaining Capabilities` through `--auto`: project/state switch, repository and Apple-framework research, 25 testable requirements, five-phase roadmap, and continued numbering from Phase 45. |
| Requirements | FACE-07 through FACE-13, SUPP-01 through SUPP-04, GEOM-01 through GEOM-04, REGN-01 through REGN-03, OUT-01 through OUT-03, SAFE-01 through SAFE-03, and DOC-01 are mapped exactly once with 25/25 coverage. |
| Research | `.planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS,SUMMARY}.md` records actual Vision contour/median-line use, the synthetic-proxy prohibition, local semantic-resource feasibility gate, seven independent controls, and local-first failure modes. |
| Verification | `verify-summary` passes; `roadmap.analyze` parses Phases 45-49; a direct ID audit reports 25 requirements, 25 mappings, zero missing, zero duplicate, and zero extra IDs; `git diff --check` passes. |
| Build | Not run because this workflow changed planning Markdown/state only and did not modify Swift, resources, or Xcode configuration. |

Outcome:

- v1.12 targets exactly `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, and `发际线`, with independent product-neutral semantics and no entitlement interpretation of `Pro`.
- Phase 45 must prove an approved bundled local semantic support implementation before mask-dependent rows can proceed; person/background matte or a synthetic face-box region is not accepted as hairline/submental evidence.
- Demo UI, network/cloud, account/payment, device/commercial/performance/packaging/shipping/launch claims remain outside this milestone; next action is Phase 45 discussion or planning.

### C-2026-07-21-v1-12-semantic-resource-rescope

| Field | Value |
| --- | --- |
| Completed | 2026-07-21 |
| Scope | Rescoped v1.12 after autonomous Phase 45 scouting found no approved local semantic model/resource metadata or clean-clone annotated fixture evidence. |
| Decision | User selected option 2: implement only `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴`; defer `去双下巴`, `去双下巴 Pro`, and `发际线`. |
| Requirements | Reduced from 25 to 18 requirements and from Phases 45-49 to Phases 45-48; all 18 map exactly once. |
| Boundary | No third-party semantic model, person-matte proxy, face-box semantic proxy, Demo UI, network/cloud, entitlement, or readiness expansion. Branch-level `脸型` remains `partial`. |

### C-2026-07-19-phase-44-eye-geometry-safety-ledger-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-19 |
| Scope | Completed Plans `44-01` through `44-06`: final caps/dead zones, fourteen-field degradation, exact retained convergence, fail-closed boundary/security/review, ten-row promotion, and current-owner synchronization. |
| Runtime | Focused suites pass 4/4 caps, 19/19 resolver, 16/16 provider, 40/40 degradation, 12/12 conflict, 13/13 combined, and 13/13 facade; full SwiftPM passes 314/314. |
| Geometry | One baseline is total 10.70, count 33, scale 1/10.70; all 28 potential provider removals are monotonic, field-local, sign-preserving, and excluded when empty. |
| Output | Strict evidence passes 385/385, 66/66 visibility, 6/6 tilt, 60/60 semantic, 132/132 portrait, and 11/11 no-face comparisons; artifacts remain ignored/untracked. |
| Quality | Boundary self-test 57/57; pre/promotion/aggregate-owner modes 13/13, 14/14, 20/20; review clean; ASVS L1 `threats_open: 0`. |
| Status | EYE-19 through EYE-23 pass. DOC-01 is `pending-independent-audit`; the separate milestone audit does not yet exist or pass. |

Outcome:

- Ten remaining geometry rows are promoted; with four prior rows, fourteen eye geometry rows are implemented.
- `去脂`/`祛红血丝` remain future and branch `眼睛` remains partial.
- No Demo/device/commercial/performance/packaging/shipping/launch/audit/archive/tag claim. Next action: `$gsd-audit-milestone`.

### C-2026-07-16-phase-43-public-facade-eye-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-16 |
| Scope | Completed Phase 43 Plans `43-01` through `43-03`: exact public renderer inventory, representative no-face facade contract, bounded strict PNG/JPEG matrix helper, frozen eye-local output families, eligibility-aware gaze/symmetry evidence, and ignored gallery containment. |
| Matrix | Exactly 55 duplicate-free public cases × seven committed fixtures = 385/385 regular, non-empty, fully decoded, same-dimension PNG outputs; the eleven new cases are nine positive-only `0.25` cases plus `eyeTilt` `+0.25`/`-0.25`. |
| Geometry Evidence | One stored-row ROI `x=.10-.90/y=.55-.82` uses fixed 500 changed-pixel and 1,000 RGB-delta floors. Strict evidence passes 66/66 new-case visibility, 6/6 direct signed-tilt, and 60/60 fixed semantic comparisons. Fixed tilt polarity and package-internal aggregate pupil-to-own-center gaze reduction pass without raw support disclosure; the prior RGB mirror score is retired as unsound. |
| Eligibility | Contour, pupil/gaze, and measured-pair symmetry eligibility each cover 6/6 portraits. The committed inventory has no neutral/ineligible portrait; the explicit 64×64 no-face fixture is excluded from portrait denominators and passes 11/11 watermark-safe no-ops plus focused extent/redaction assertions. |
| Verification | Focused `BeautyRendererOutputRegressionTests` pass 13/13; full SwiftPM passes 305/305; helper self-tests and compilation pass; strict helper passes 385/385; descriptor-safe gallery publication produces exactly 385 ignored, untracked regular files; tracked/staged/non-ignored-untracked generated artifacts remain zero; `git diff --check` passes. |
| Boundary | EYE-16 through EYE-18 close only. Exact final caps, exhaustive degradation/transitions, 28-field convergence, active-source boundary closeout, ten-row promotion, DOC-01 synchronization, and branch-level `眼睛` remain Phase 44. No Demo/device/commercial/optimized-performance/packaging/shipping/launch claim. |

Outcome:

- Every Phase 41/42 eye control has isolated public-facade saved-output evidence with signed/semantic distinctions.
- Generated PNGs remain disposable ignored local artifacts; only aggregate facts enter repository history.
- Phase 44 can lock final safety and promotion without reopening the Phase 43 renderer/output contract.

### C-2026-07-16-phase-41-public-contract-observed-eye-support

| Field | Value |
| --- | --- |
| Completed | 2026-07-16 |
| Scope | Completed Phase 41 Plans `41-01` through `41-05`: ten compatible public eye scalars, one-mapper package-only observed contour/pupil evidence, deterministic span/tilt semantics, production-derived side-order validation, pupil-local degradation, complete-eye fail-closed wiring, boundary gate, and owner synchronization. |
| Contract | Exact 48 stored fields = 47 numeric + `filterId`; positive-only `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`, `eyeSymmetry`; signed `eyeTilt`; all default/missing/non-finite values zero and legacy 38-key payloads neutral. |
| Support | Contours are request-scoped and package-only after one `CoordinateMapper` conversion; locked support ceilings are 6...16 points, 4 unique points, width `0.04...0.50`, height `0.01...0.30`, area above `0.0004`; pupils use 10% containment expansion, offset at most `0.70`, and paired ratios `0.50...2.00`. Package-private span is the image-normalized contour bounding width/height and tilt is signed canonical inner-to-outer angle normalized to `-1...1`; neither changes with winding. These are not visual caps. |
| Degradation | Production mapping requires exactly one left/right pair and a finite mapped center separation above `0.000001` on a `CoordinateMapper`-derived anatomical axis. Missing, duplicate, coincident, side-inverted, or non-finite order fails closed; valid orientation/mirror cases retain their labels. Invalid/absent pupil disables only `pupilSize` and `gazeCorrection`; invalid contour/order reaches the resolver complete-eye skip with no proxy fallback. Nil observed support preserves only shipped zero-default compatibility. Diagnostics use fixed reasons and aggregate counts. |
| Verification | Fresh full SwiftPM passes 295/295. The focused adapter suite passes 13/13 and mapping suite passes 8/8, including winding-independent span/tilt, production-derived orientation/mirror order, swapped/duplicate rejection, and the exact/inside/outside contour/pupil/ratio matrix. `check_eye_support_boundaries.py --self-test` passes 24/24 and live mode passes 10/10 against baseline `f1c28fa`; active SDK public/Codable/persistence/diagnostic/network/commercial/import scans have zero unclassified matches; output/gallery/staging/quarantine roots are tracked=0, staged=0, non-ignored-untracked=0 and representative paths remain ignored. `git diff --check` passes. |
| Boundary | No provider transforms, final caps, facade output, renderer/gallery evidence, ledger promotion, Demo change, device/commercial evidence, optimized performance, packaging, shipping, launch, or whole-branch `眼睛` claim. Phase 42 owns provider behavior. |

Outcome:

- EYE-01 through EYE-07 have compatible scalar, mapping, validation, degradation-input, privacy, and fail-closed boundary evidence.
- Raw/derived contour and pupil data remains ephemeral, non-Codable, non-persistent, non-diagnostic, and absent from public/SPI and Demo surfaces.
- Phase 42 can implement independent field vectors and provisional caps without reopening the Phase 41 public/support contract.

### C-2026-07-16-v1-11-milestone-initialization

| Field | Value |
| --- | --- |
| Completed | 2026-07-16 |
| Scope | Initialized v1.11 `Eye Remaining Geometry Controls` through `--auto`: project context, focused Apple Vision/repository research, 24 testable requirements, four-phase roadmap, state reset, and atomic documentation commits. |
| Requirements | EYE-01 through EYE-23 and DOC-01 defined and mapped exactly once across Phases 41-44; 24/24 coverage. |
| Research | `.planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS,SUMMARY}.md` records the no-new-dependency stack, private observed contour/pupil seam, ten-row geometry scope, and failure modes. |
| Verification | `roadmap.analyze` parses four phases with 24 mapped requirements and no duplicate IDs; `verify-summary` passes; `git diff --check` passes; no Swift/Xcode build run because this workflow changed planning documents only. |
| Boundary | `去脂` and `祛红血丝` remain future retouch/color work; no Demo/device/commercial/performance/packaging/shipping/launch claim is made. |

Outcome:

- Phase 41 `Public Contract and Observed Eye Support` is next.
- Pupil, gaze, and symmetry are explicitly gated on private, frame-scoped observed support rather than symmetric proxy-only evidence.
- Historical v1.1/v1.2 phase directories remain preserved as repository history; they are not v1.10 leftovers and were not deleted during this milestone switch.

### C-2026-07-14-v1-10-autonomous-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Executed v1.10 Phases 38-40 autonomously from smart discussion through planning, implementation, review, verification, independent milestone audit, archive, tag, and cleanup. |
| Requirements | MOUTH-01 through MOUTH-16 and DOC-01 pass 17/17; integration passes 8/8 and end-to-end flows pass 5/5. |
| Verification | Fresh SwiftPM passes 265/265; strict output passes 308/308 with 96/96 portrait and 8/8 no-face pairs; boundary gate passes 63/63 self-tests and 13/13 live checks. |
| Lifecycle | Roadmap, requirements, audit, and Phases 38-40 are archived under `.planning/milestones/`; the annotated local `v1.10` tag records final closeout. |

Outcome:

- Independent signed Y/tilt/X controls plus local peak/plump geometry are complete through public, provider, facade-output, safety, degradation, integration, and boundary evidence.
- Exactly `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇` are implemented; `白牙` remains future and branch-level `嘴唇` remains partial.
- No Demo/device/commercial/performance/packaging/shipping/launch-readiness claim is made; the next action is `$gsd-new-milestone`.

### C-2026-07-14-phase-40-mouth-geometry-safety-ledger-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Completed Phase 40 Plans `40-01` through `40-04`: exact caps, all-eight degradation/transitions, provider-eligible combined convergence, fail-closed boundaries, exact five-row promotion, and owner synchronization. |
| Requirements | MOUTH-12 through MOUTH-16 and DOC-01 pass 6/6; all 17 v1.10 requirements now map to complete phases. |
| Runtime | Fresh 106 requirement-focused and 265/265 full SwiftPM tests passed; unchanged strict helper accepted 308/308 decoded same-dimension outputs. |
| Quality | Promotion checker passed 63/63 mutation self-tests and all live checks; standard review is clean; ASVS L1 records `threats_open: 0`; generated artifacts remain ignored and untracked. |

Outcome:

- Exactly `上下`, `倾斜`, `左右`, `M唇`, and true geometry `丰唇` are implemented through independent public/provider/output/safety evidence.
- `白牙` remains future and branch-level `嘴唇` remains partial; no Demo/device/commercial/performance/packaging/shipping/launch claim is made.
- Phase execution is complete; the separately owned milestone audit and lifecycle steps remain next.

### C-2026-07-14-phase-39-public-facade-mouth-geometry-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Completed Phase 39 Plans `39-01` through `39-03`: exact public renderer cases, strict decoded ROI/direction/independence evidence, safe no-face behavior, ignored gallery, review, security, and verification. |
| Requirements | MOUTH-09 through MOUTH-11 pass 3/3; MOUTH-12 through MOUTH-16 and DOC-01 remain Phase 40. |
| Runtime | Fresh 11/11 focused and 260/260 full SwiftPM tests passed; strict helper accepted 308/308 outputs, 96/96 portrait pairs, and 8/8 no-face no-ops. |
| Quality | Standard review is clean after one JPEG dimension-bound fix; ASVS L1 records `threats_open: 0`; exact 308-file gallery is ignored and untracked. |

Outcome:

- Every new control is visible and directly distinguishable through isolated public-facade saved output in one fixed mouth ROI.
- `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and branch-level `嘴唇` remain unpromoted until Phase 40 final-cap, exhaustive-safety, boundary, and atomic-promotion evidence passes.
- No Demo/device/commercial naturalness, optimized-performance, packaging, shipping, launch, audit, or milestone-completion claim is made.

### C-2026-07-14-phase-38-public-contract-and-lip-support-geometry

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Completed Phase 38 Plans `38-01` through `38-04`: five compatibility-safe public controls, optional package-only lip support, eight-field mouth provider ownership, resolver/conflict/facade routing, review, and verification. |
| Requirements | MOUTH-01 through MOUTH-08 pass 8/8; MOUTH-09 onward and DOC-01 remain assigned to Phases 39-40. |
| Runtime | Fresh 152/152 focused and 259/259 full SwiftPM tests passed with zero failures. |
| Quality | Standard review is clean across 21 Swift files; ASVS L1 and public/SPI, dependency/network/commercial, scope, artifact, no-promotion, and diff gates pass with `threats_open: 0`. |
| Contract | Exact 38 stored fields = 37 numeric + `filterId`; provisional new-field cap `0.25`; reused eligible geometry exact `0.5`; eight mouth emissions; fourteen-removal convergence. |

Outcome:

- Signed Y/tilt/X transforms and local peak/plump geometry are independent, bounded, provider-eligible, and facade-routed without exposing raw supports or control points.
- `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and branch-level `嘴唇` remain unpromoted until Phase 39 output and Phase 40 final-safety/boundary evidence pass.
- No renderer/gallery, final-cap, exhaustive transition, Demo/device/commercial, packaging, shipping, launch, or milestone-completion claim is made.

### C-2026-07-14-gsd-new-milestone-v1-10-mouth-remaining-geometry

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Initialized v1.10 `Mouth Remaining Geometry Controls` through auto-mode scope resolution, focused project/platform research, testable requirements, and a continued three-phase roadmap. |
| Files | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS,SUMMARY}.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `PLANS.md` |
| Requirements | Defined 17 requirements: MOUTH-01 through MOUTH-16 and DOC-01, mapped exactly once across Phases 38-40. |
| Roadmap | Phase 38 `Public Contract and Lip-Support Geometry`; Phase 39 `Public-Facade Mouth Geometry Output Evidence`; Phase 40 `Mouth Geometry Safety and Ledger Closeout`. |
| Verification | `state.milestone-switch` reports v1.10; `roadmap.analyze` parses 3 phases with no missing details; requirement/roadmap checks report 17 mapped, 17 unique, 0 unmapped, 0 duplicates; 15 success criteria; `init.new-milestone` reports v1.10 and Phase 38 next; Markdown placeholder and `git diff --check` scans pass. |
| Build | Not run because this workflow changed planning Markdown only and no Swift/Xcode source or project configuration. |

Outcome:

- Auto-mode scope includes exactly the five remaining geometry rows: `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇`; `白牙` remains a future segmentation/color-retouch slice and branch-level `嘴唇` remains partial.
- The public-contract baseline proposes signed `mouthYPosition`, `mouthTilt`, and `mouthXPosition` plus positive-only `lipPeakDefinition` and `lipPlump`, with exact 33-to-38 stored-field compatibility requirements.
- Research retains the existing Swift/Vision/unified-warp/facade stack, adds no dependency or UI scope, and records Apple Vision outer/inner-lip support as the package-internal geometry seam.
- The workflow used inline research and roadmapping because the request did not authorize sub-agent delegation; `--auto` approved the scoped requirements and roadmap gates.

### C-2026-07-14-repository-media-exclusion

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Added repository-wide ignore rules for binary image, design, video, audio, font, 3D, and LUT assets while retaining text-based project manifests. |
| History | Removed matching media blobs from the unpushed local Git history so the initial remote push does not carry obsolete binary payloads; local ignored source materials remain available in the working tree. |
| Verification | Confirmed no matching media path is tracked or reachable from rewritten branches/tags, ignore checks cover existing local images, and repository object size was measured after garbage collection. |

Outcome:

- Image and creative media files remain local by default and cannot be accidentally added without an explicit force-add.
- `Assets.xcassets/Contents.json` and other text manifests stay tracked so the Xcode project structure remains reproducible.

### C-2026-07-14-v1-9-autonomous-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Executed v1.9 Phases 35-37 autonomously, completed the independent milestone audit, archived milestone planning artifacts, and cleaned configured completed-phase directories. |
| Requirements | NOSE-01 through NOSE-14 and DOC-01 pass 15/15; integration passes 12/12 and end-to-end flows pass 5/5. |
| Verification | Final SwiftPM passes 228/228; strict renderer/helper evidence passes 252/252; Phase 37 boundary checker passes 33/33; scoped review is clean and `threats_open: 0`. |
| Lifecycle | Archived roadmap, requirements, audit, and Phase 35-37 directories under `.planning/milestones/`; the annotated local `v1.9` tag is the final closeout action. |

Outcome:

- Independent `noseRootNarrowing` and `noseTipLift` contracts, exact caps, degradation convergence, fail-closed boundaries, and the exact six-row SDK-core `鼻子` branch are complete.
- Exactly `山根` and `提升` were newly promoted from independent evidence without expanding Demo/device/commercial/packaging/shipping/launch claims.
- The repository has no active execution plan and is ready for `$gsd-new-milestone`.

### C-2026-07-14-phase-37-nose-safety-boundary-branch-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Completed Phase 37 Plans `37-01` through `37-04`: exact caps, exhaustive six-field degradation/transitions, once-only converged conflicts, fail-closed boundaries, exact promotion, and current-owner synchronization. |
| Requirements | NOSE-10 through NOSE-14 and DOC-01 pass 6/6; the independent milestone audit remains next. |
| Runtime | Fresh 103/103 focused and 228/228 full SwiftPM; unchanged renderer/helper evidence passes 252/252, 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face. |
| Security | Scoped review is clean; ASVS L1 and active-source/artifact gates pass with `threats_open: 0`. |
| Promotion | Exactly `山根` and `提升` are newly implemented from their independent fields, then the exact six-row SDK-core `鼻子` branch is implemented. |

Outcome:

- Final root/lift caps are exact `0.25`; reused eligible work is exact `0.5`, and unsupported/provider-empty/stale work cannot survive into totals, warnings, metrics, or dispatch.
- All current owners preserve explicit Demo/device/commercial/packaging/shipping/launch non-claims and do not claim a passed milestone audit.
- Next lifecycle action is `$gsd-audit-milestone`; archive, tag, and cleanup remain gated on its independent result.

### C-2026-07-14-phase-36-code-review-iteration-4-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-07-14 |
| Scope | Closed Phase 36 iteration-4 warnings WR-04/WR-05/WR-06 without changing renderer cases or Phase 37 promotion owners. |
| Security | Gallery acquisition registers descriptor ownership immediately, rejects source files above 16 MiB before destination creation, bounds copy reads, and rejects same-inode mutation through identity/size/mtime/ctime snapshot drift. |
| Reliability | Repeated missing-output and post-open identity failures have stable descriptor counts; deterministic same-size torn-copy, sparse oversize, and post-open ceiling-growth races fail before publication. |
| Verification | Gallery/helper self-tests, Python compilation, live 252-output helper, focused 10/10 renderer XCTest, and full 220/220 SwiftPM evidence are recorded in `36-REVIEW-FIX.md`. |

Outcome:

- Source acquisition and copy work are bounded to the strict helper's 16 MiB compressed-file ceiling.
- Neither acquisition exceptions nor post-open identity failures leak descriptors across repeated library invocations.
- A source or staged file must retain its descriptor identity, size, nanosecond modification time, and change time through atomic publication.

### C-2026-07-13-phase-36-code-review-iteration-3-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Redesigned Phase 36 gallery publication for CR-03/CR-04 and closed WR-03 bounded PNG acquisition without changing renderer cases or Phase 37 promotion owners. |
| Security | Fresh descriptor-anchored staging uses exclusive no-follow destination opens and atomic descriptor-relative publication; preexisting galleries are moved intact into one ignored quarantine slot and are never traversed or recursively deleted. |
| Reliability | Existing staging/quarantine state fails closed and blocks repeated publication until explicit operator handling; the PNG helper opens once, bounds retained reads to the file ceiling plus one byte, and rejects growth/excess. |
| Verification | Gallery and helper self-tests cover post-recreation ancestor swap, mount-like non-traversal instrumentation, external sentinel survival, bounded repeated-run behavior, and PNG replacement/growth races; final runtime counts are recorded in `36-REVIEW-FIX.md`. |

Outcome:

- Gallery destination writes remain descriptor-relative from fresh staging population through atomic publication.
- Old gallery contents, including nested mounts or links, are preserved without enumeration under a bounded ignored quarantine and are not described as cleaned.
- PNG/JPEG acquisition no longer uses a pathname stat/read split or an unbounded whole-file read.

### C-2026-07-13-phase-36-public-facade-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Completed Phase 36 Plans `36-01` through `36-03`: isolated public-facade cases, strict output decoder/ROI evidence, exact ignored gallery, ASVS L1 review, Nyquist finalization, and planning closeout without product promotion. |
| Requirements | NOSE-07, NOSE-08, and NOSE-09 complete; NOSE-10 through NOSE-14 and DOC-01 remain Phase 37. |
| Runtime | Fresh 10/10 focused renderer XCTest and 220/220 full SwiftPM; guarded clean 36 × 7 renderer/helper and gallery each passed exactly 252 files. |
| Evidence | 252/252 decoded same-dimension outputs; 12/12 baseline, 6/6 root/bridge, and 12/12 lift/signed-tip ROI comparisons; representative 2/2 no-face extent/no-op; ignored/untracked containment; `threats_open: 0`. |
| Boundaries | `0.25` remains provisional; `山根`, `提升`, and branch-level `鼻子` remain unpromoted; caps/providers/resolvers/product ledgers/PROJECT/QUALITY_SCORE/Demo/Package.swift remain untouched. |

Outcome:

- Gallery routing is an exact duplicate-free bijection with discovered renderer cases and writes 252 disposable local PNGs.
- Verification closes only NOSE-07 through NOSE-09 with observed public-facade output evidence and conservative non-claims.
- Phase 37 remains the next unstarted owner for final caps, exhaustive six-field safety, active-source boundary closeout, and atomic promotion.

### C-2026-07-13-phase-35-code-review-iteration-4-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Closed Phase 35 iteration-4 finding CR-06 by converging shared conflict weakening with provider eligibility for all retained nose and mouth fields. |
| Behavior | Provider-owned mouth field emissions now sanitize preflight and final scaled work; signed `mouthSize` / `mouthWidth` threshold crossings are zeroed and excluded before conflict evidence is finalized, while supported mouth siblings remain active. |
| Verification | Focused provider/resolver/degradation/conflict/combined suites and full `swift test --package-path BeautySDK` recorded in `35-REVIEW-FIX.md`; exact domain, warning, scale, count, effective-strength, and final-emission regressions cover both signed directions with and without supported siblings. |

Outcome:

- Every retained mouth geometry field is provider-eligible at its final conflict-scaled strength.
- A threshold-crossing mouth request with no retained sibling preserves `.mouth` skipped-domain and redacted `mouth_inputs_missing` evidence; a supported sibling keeps `.mouth` active.
- The established bounded nose convergence, aggregate diagnostic privacy, and Phase 36/37 non-claims remain unchanged.

### C-2026-07-13-phase-35-code-review-iteration-3-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Closed Phase 35 iteration-3 finding CR-05 by converging conflict weakening and provider emission eligibility on one retained six-field nose set. |
| Behavior | A deterministic monotonic loop permits at most six nose-field mask changes; threshold-crossing root, tip-lift, and signed tip-size work is removed from the unscaled baseline before conflict total, weakened count, and scale are recomputed, while emitting siblings remain active. |
| Verification | Focused resolver/provider/degradation/conflict/combined suites and full `swift test --package-path BeautySDK` recorded in `35-REVIEW-FIX.md`; final per-field emissions exactly match retained effective strengths in explicit mixed-sibling regressions. |

Outcome:

- Final effective nose strengths and final provider emissions now use the same per-field eligibility at conflict-scaled values.
- `combined_geometry_weakened` warning and aggregate metrics exclude threshold-crossing work without adding raw geometry or field-level diagnostic payloads.
- Public geometry/privacy boundaries and Phase 36/37 non-claims are unchanged.

### C-2026-07-13-phase-35-code-review-iteration-2-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Closed Phase 35 iteration-2 review findings CR-03 and CR-04 with one provider-owned per-field emission contract shared by resolver preflight and final dispatch. |
| Behavior | Non-emitting legacy/root/tip fields are zeroed independently before conflict accounting; emitting siblings remain active and conflict totals, scale, and weakened count exclude unsupported work. |
| Verification | Focused resolver/provider/degradation/conflict/combined suites passed 68/68 XCTest cases; full `swift test --package-path BeautySDK` passed 214/214; `git diff --check` passed. |

Outcome:

- One-point legacy geometry can no longer let a non-emitting `noseSlim` survive beside valid root work.
- Structurally valid but displacement-blocked root work and tiny non-emitting tip work are excluded before conflicts with exact mixed-case scale/count regressions.
- Public geometry/privacy boundaries and Phase 36/37 non-claims are unchanged.

### C-2026-07-13-phase-35-public-contract-independent-geometry

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Completed Phase 35 Plans `35-01` through `35-04`: exact public-model compatibility, independent package-only root/tip geometry, resolver/conflict/facade routing, ASVS L1 review, and current-owner synchronization. |
| Requirements | NOSE-01 through NOSE-06 complete; NOSE-07 onward and DOC-01 remain pending. |
| Files | Public/effective model and geometry code/tests from Plans 35-01 through 35-03; `ARCHITECTURE.md`, `DESIGN.md`, `RELIABILITY.md`, `SECURITY.md`, `PRODUCT_SENSE.md`, current GSD ledgers, and Phase 35 verification/security/validation evidence in Plan 35-04. |
| Verification | `35-VERIFICATION.md`: fresh 106/106 focused and 219/219 full XCTest cases; clean final 24-file code review; exact 33 = 32 numeric + `filterId`; provisional `0.25`; reused exact `0.5`; explicit `noseRoot`/`noseTip`; bounded nose/mouth conflict-emission convergence; public/SPI, diagnostics, dependency, network/commercial, renderer/Demo, artifact, archive, no-promotion, and diff-hygiene gates. |
| Build | Full SwiftPM suite passed. No Demo build was required because Demo source was unchanged. |

Outcome:

- `noseRootNarrowing` and `noseTipLift` are independent positive-only public contracts with fail-closed package-internal supports and redacted facade routing.
- `山根`, `提升`, and branch-level `鼻子` remain unpromoted/partial; Phase 36 owns renderer/helper/gallery/ROI output and Phase 37 owns cap calibration, exhaustive exactly-once safety, boundaries, and promotion.
- No renderer/output, final-cap, device/commercial, packaging, shipping, or launch-readiness claim was made.

### C-2026-07-13-gsd-new-milestone-v1-9-nose-remaining-tools

**Status:** Completed

**Why:**

- Resolve the two nose rows deliberately deferred by v1.7 instead of borrowing `noseBridge` or `noseTipSize` evidence.
- Close branch-level `鼻子` only after compatibility, geometry, facade-output, safety, privacy, artifact, and documentation gates agree.

**Delivered:**

- Initialized v1.9 `Nose Remaining Tools and Branch Closeout` in `.planning/PROJECT.md` and reset `.planning/STATE.md` through the GSD milestone-switch handler.
- Added stack, feature, architecture, and pitfall research plus a reconciled summary that freezes positive-only `noseRootNarrowing` and `noseTipLift` as the roadmap baseline.
- Defined 15 testable requirements covering the 31-to-33 stored-field contract, independent root/tip geometry, facade output, six-field degradation/conflict behavior, fail-closed boundaries, and atomic SDK-core branch promotion.
- Created Phase 35 `Public Contract and Independent Geometry`, Phase 36 `Public-Facade Output Evidence`, and Phase 37 `Nose Safety, Boundary, and Branch Closeout`, with all 15 requirements mapped exactly once.

**Verification:**

- `git diff --check` passed before each milestone artifact commit.
- Requirement traceability reports 15 total, 15 mapped, 0 unmapped, 0 duplicates, and 100% coverage.
- Phase numbering continues after v1.8 Phase 34 as required; historical phase directories and archived v1.7 evidence remain intact.

### C-2026-07-13-v1-8-mouth-sdk-slice-lifecycle

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Delivered, independently audited, archived, and cleaned up v1.8 Broader `美型 / 五官` SDK Slice - Mouth. |
| Requirements | MOUTH-01 through MOUTH-10 and DOC-01: 11/11 satisfied. |
| Runtime | Fresh 190-test full SDK suite; 238/238 outputs; 30/30 geometry comparisons; 12/12 signed comparisons; 6/6 lip-color containment checks. |
| Audit | 2/2 phases, 11/11 integration checks, 5/5 flows, both phases Nyquist compliant, `threats_open: 0`, no accepted debt. |
| Archive | `v1.8-ROADMAP.md`, `v1.8-REQUIREMENTS.md`, `v1.8-MILESTONE-AUDIT.md`, and `v1.8-phases/`; annotated tag `v1.8`. |
| Boundaries | Exactly `大小`, `宽度`, and `微笑` implemented; `lipColor` remains color-only; all named future rows and branch-level `嘴唇` remain partial/future. |

Outcome:

- Phase 33/34 execution history is archived under `.planning/milestones/v1.8-phases/`; unrelated historical phase directories remain in place.
- Live `REQUIREMENTS.md` is removed after its safety archive, and live ROADMAP has no active milestone while preserving the backlog.
- Generated output/gallery files remain ignored and untracked; no push was performed.

### C-2026-07-13-gsd-audit-milestone-v1-8-final-pass

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Ran a fresh independent v1.8 audit after the single autonomous DOC-01 current-owner remediation. |
| Requirements | MOUTH-01 through MOUTH-10 and DOC-01 satisfied: 11/11. |
| Files | `.planning/v1.8-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | Independent integration passed 11/11 checks and 5/5 E2E flows; both phases and both Nyquist validations pass; security has `threats_open: 0`. Fresh full SwiftPM passed 190/190, and the helper passed 238/238 outputs, 30/30 geometry comparisons, 12/12 signed comparisons, and 6/6 lip-color checks. Exact promotion, future boundaries, public inventory, import/dependency/network/commercial/raw-geometry scans, and ignored/untracked artifact gates passed. |

Outcome:

- v1.8 audit status is `passed` with no blocker or unaccepted milestone debt.
- Historical failed audits and remediations remain below as chronology and are superseded by this final verdict.
- Milestone completion, archival, annotated tag creation, and Phase 33-34 cleanup may proceed.

### C-2026-07-13-v1-8-doc-01-current-owner-remediation

**Status:** Completed

**Delivered:** Synchronized `.planning/PROJECT.md` and `QUALITY_SCORE.md` current-state owners with completed Phase 33-34 mouth evidence, replacing stale v1.7/Phase 32 lifecycle routing while preserving the exact three-row promotion, color-only `lipColor` boundary, partial `嘴唇` branch, and all device/commercial/packaging/launch non-claims.

**Verification:** Current-owner scans find Phase 34, 190/190 full SDK tests, 238/238 outputs, 30/30 geometry comparisons, 12/12 signed comparisons, 6/6 lip-color checks, exact `大小`/`宽度`/`微笑` promotion, partial `嘴唇`, and audit-gated lifecycle routing. `git diff --check` passed. Runtime behavior is unchanged.

### C-2026-07-13-gsd-audit-milestone-v1-8-third-run

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Re-audited v1.8 independently after commit `6bd3f04` corrected the Phase 33 handoff. |
| Requirements | MOUTH-01 through MOUTH-10 satisfied; DOC-01 remains unsatisfied. Effective score: 10/11. |
| Files | `.planning/v1.8-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | Fresh full SwiftPM passed 190/190. Renderer/helper evidence passed 238/238 outputs, 30/30 geometry comparisons, 12/12 signed comparisons, and 6/6 lip-color checks. Integration scored 10/11, flows 4/5, Nyquist 2/2, and security passed with `threats_open: 0`. The Phase 33 handoff fix is correct, but PROJECT and QUALITY_SCORE still present v1.7/Phase 32 as current. |

Outcome:

- Audit remains `gaps_found`; no gap or debt is accepted.
- Completion, annotated tag creation, requirements/roadmap archival, and Phase 33-34 cleanup did not run.
- Required next repair is to synchronize the PROJECT and QUALITY_SCORE current snapshots with v1.8, followed by another independent audit.

### C-2026-07-13-gsd-audit-milestone-v1-8-second-run

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Re-audited v1.8 independently after the one permitted autonomous metadata remediation attempt. |
| Requirements | MOUTH-01 through MOUTH-10 satisfied; DOC-01 remains unsatisfied. Effective score: 10/11. |
| Files | `.planning/v1.8-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | The prior STATE/footer/summary/Nyquist gaps are closed. Fresh focused Swift tests passed 47/47, inventory/artifact/boundary scans passed, integration scored 10/11, and flows scored 4/5. One stale sentence in `33-VERIFICATION.md` still says completed Phase 34 gates remain pending. |

Outcome:

- Audit remains `gaps_found`; the allowed autonomous closure attempt is exhausted.
- Completion, annotated tag creation, requirements/roadmap archival, and Phase 33-34 cleanup did not run.
- Required next repair is the stale Phase 33 verification handoff sentence, followed by another independent audit.

### C-2026-07-13-v1-8-audit-metadata-remediation

**Status:** Completed

**Delivered:** Synchronized v1.8 STATE progress/history/todos/continuity, ROADMAP and REQUIREMENTS closeout footers, explicit Phase 33 Nyquist metadata, and Phase 33/34 summary requirement frontmatter for a clean three-source audit rerun.

**Verification:** Exact stale-state scans, 11/11 summary requirement extraction, 2/2 explicit Nyquist declarations, `roadmap.analyze` 100% completion, and `git diff --check` passed. Runtime behavior is unchanged; the first audit's fresh 190-test suite remains the implementation baseline until the independent rerun.

### C-2026-07-13-gsd-audit-milestone-v1-8-first-run

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Audited v1.8 after Phases 33-34, including three-source coverage, Nyquist discovery, security state, and independent cross-phase/E2E verification. |
| Requirements | MOUTH-01 through MOUTH-10 satisfied; DOC-01 unsatisfied. Effective score: 10/11. |
| Files | `.planning/v1.8-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | Fresh full SwiftPM suite passed 190/190. Integration passed 10/11 checks and 4/5 flows; runtime mouth behavior and `threats_open: 0` are sound. Current STATE/REQUIREMENTS/ROADMAP ownership contradicts Phase 34's DOC-01 claim, and Phase 33 Nyquist plus Phase 33/34 requirement-summary metadata is incomplete. |

Outcome:

- Audit status is `gaps_found`; completion, tag creation, and cleanup did not run.
- Required repair: synchronize STATE, closeout footers, Phase 33 Nyquist metadata, and summary requirement metadata, then rerun an independent audit.
- No audit gap or technical debt was silently accepted.

### C-2026-07-13-phase-33-mouth-renderer-evidence

**Status:** Completed

**Delivered:** Six isolated public-facade mouth/lip cases, exact inventory tests, decoded 238-output helper, geometry/signed/color ROI evidence, and ignored mouth gallery routing.

**Verification:** Focused renderer tests passed 9/9; full SDK suite passed; renderer helper passed 238/238 outputs, 30/30 geometry comparisons, 12/12 signed comparisons, and 6/6 lip-color containment checks; generated gallery wrote 238 ignored files and zero output/gallery files are tracked.

**Boundary:** `lipColor` remains color-only evidence; Phase 34 owns safety, degradation, and exact row promotion.

### C-2026-07-13-gsd-new-milestone-v1-8-mouth-sdk-slice

**Status:** Completed

**Why:**

- Start the next evidence-led `美型 / 五官` SDK slice after v1.7 nose closeout.
- Scope existing mouth/lip parameters without expanding the stable public inventory or overstating `lipColor` as true `丰唇` geometry.

**Delivered:**

- Initialized v1.8 `Broader 美型 / 五官 SDK Slice - Mouth` in `.planning/PROJECT.md` and reset `.planning/STATE.md` through the GSD milestone-switch handler.
- Added milestone research for stack, features, architecture, and pitfalls, with a synthesized two-phase recommendation.
- Defined 11 testable requirements covering public-facade output, signed mouth geometry, lip-color containment, degradation, combined weakening, boundaries, exact ledger promotion, and documentation closeout.
- Created Phase 33 `Mouth Renderer Output Evidence` and Phase 34 `Mouth Safety, Degradation, and Ledger Closeout`, with 11/11 requirements mapped exactly once.

**Verification:**

- `git diff --check` passed for the roadmap artifacts before commit.
- Requirement traceability reports 11 total, 11 mapped, and 0 unmapped.
- Phase numbering continues after v1.7 Phase 32 as required.

### C-2026-07-13-v1-7-nose-sdk-slice

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Delivered, audited, archived, tagged, and cleaned up v1.7 Broader `美型 / 五官` SDK Slice - Nose. |
| Requirements | NOSE-01 through NOSE-08 and DOC-01: 9/9 satisfied. |
| Runtime | 186-test full SDK suite; 196/196 outputs; 30/30 portrait comparisons; 6/6 signed comparisons. |
| Audit | 2/2 phases, 9/9 integration checks, 5/5 flows, both phases Nyquist compliant, `threats_open: 0`. |
| Archive | `v1.7-ROADMAP.md`, `v1.7-REQUIREMENTS.md`, `v1.7-MILESTONE-AUDIT.md`, and `v1.7-phases/`; annotated tag `v1.7`. |
| Boundaries | Exactly four rows implemented; `山根`, `提升`, and branch-level `鼻子` remain partial/future; all readiness/parity exclusions preserved. |

Outcome:

- Phase 31/32 history is archived under `.planning/milestones/v1.7-phases/`.
- Live `REQUIREMENTS.md` is removed and live ROADMAP has no active milestone.
- Generated output/gallery files remain ignored and untracked.

### C-2026-07-13-gsd-complete-milestone-v1-6

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Archived the audited v1.6 milestone, preserved Phase 29/30 directories in place by user choice, evolved current planning owners, and prepared the repository for a fresh milestone. |
| Requirements | Archived EYE-01 through EYE-08 and DOC-01 as 9/9 complete. |
| Files | `.planning/milestones/v1.6-ROADMAP.md`, `.planning/milestones/v1.6-REQUIREMENTS.md`, `.planning/milestones/v1.6-MILESTONE-AUDIT.md`, `.planning/MILESTONES.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/RETROSPECTIVE.md`, `QUALITY_SCORE.md`, `PLANS.md`; active `.planning/REQUIREMENTS.md` removed after the safety commit. |
| Verification | Open artifact audit was clear; roadmap analysis reported 2/2 phases, 11/11 summaries, and 100% progress; final milestone audit passed 9/9 requirements, 9/9 integration checks, and 5/5 flows; fresh SDK suite passed 178 tests; archive/link/table/artifact and `git diff --check` guards passed. |
| Build | Fresh full SwiftPM suite passed 178 tests before archival. No Demo build was required because milestone-close changes are documentation/planning only. |

Outcome:

- v1.6 is archived and ready to tag.
- Phase directories remain under `.planning/phases/`; `$gsd-cleanup` can archive them later.
- The live roadmap has no active milestone and preserves the backlog.
- Next step after tag: `$gsd-new-milestone`.

### C-2026-07-13-gsd-audit-milestone-v1-6-final-pass

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Ran the final comprehensive v1.6 milestone audit after the batch DOC-01 remediation and synchronized current milestone-closeout owners to the passed verdict. |
| Requirements | EYE-01 through EYE-08 and DOC-01 satisfied: 9/9. |
| Files | `.planning/v1.6-MILESTONE-AUDIT.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Independent integration checker passed 9/9 integration checks and 5/5 E2E flows, confirmed 2/2 phase verifications and both Nyquist validations, and found no blockers or milestone debt. Fresh `swift test --package-path BeautySDK` passed 178 tests with zero failures in 30.485 seconds. Current-owner link, stale-state, exact four-row, partial-branch, table-shape, ignored/untracked artifact, and `git diff --check` gates passed. |
| Build | Fresh full SwiftPM test suite passed with 178 tests; no Demo build was required because the final remediation changed documentation only and Demo source remains unchanged. |

Outcome:

- v1.6 milestone audit status is `passed` with requirements 9/9, phases 2/2, integration 9/9, and flows 5/5.
- No blocker or in-scope milestone technical debt remains.
- Historical failed audits and repairs remain below as an explicit chronology; this final independent pass supersedes their verdicts.
- Next step: `$gsd-complete-milestone v1.6`.

### C-2026-07-13-v1-6-audit-comprehensive-batch-repair

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Performed a comprehensive current-owner defect scan, then repaired the complete discovered DOC-01 set in one batch rather than iterating one finding at a time. |
| Requirements | DOC-01 remediation; EYE-01 through EYE-08 runtime behavior is unchanged. |
| Files | `docs/meitu-function-blueprint/features/beauty-shaping/README.md`, `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md`, `.planning/STATE.md`, `.planning/v1.6-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | Current-owner stale Phase 30/output scans found no obsolete eye claim that facade-visible output is still required. Exact positive guards found the four implemented rows and partial-branch boundary in both shaping READMEs, FEATURE_MATRIX, the ledger, project/roadmap/state/quality owners, and Phase 29/30 evidence links. STATE now has separate three-column phase and four-column plan-performance tables. All relative Markdown links resolve, generated output/gallery roots contain zero tracked files, and `git diff --check` passed. |
| Build | Not run; this batch changes documentation only. Runtime evidence remains the Phase 30 178-test full suite. |

Outcome:

- Both parent and eye-specific blueprint contracts now distinguish four completed existing-parameter subtools from the still-partial branch.
- STATE phase and plan metrics render as separate structurally valid tables.
- The audit report now records the full three-defect batch and preserves `gaps_found` until an independent re-audit.
- The earlier fourth-audit PLANS entry remains as historical chronology and is superseded by this comprehensive scan.
- Next step: run `$gsd-audit-milestone` once for the final independent verdict.

### C-2026-07-13-gsd-audit-milestone-v1-6-fourth-run

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Re-ran the complete v1.6 milestone audit after the STATE remediation, including three-source coverage, Nyquist discovery, and a fourth independent integration/E2E check. |
| Requirements | EYE-01 through EYE-08 satisfied; DOC-01 remains unsatisfied. Effective score remains 8/9. |
| Files | `.planning/v1.6-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | The checker confirmed all previously reported planning/state defects are closed, then found one remaining live contradiction in `docs/meitu-function-blueprint/features/beauty-shaping/README.md`: the eye Branch Contracts row still says facade-visible geometry output is required despite the same file's Phase 30 evidence section. Integration remains 8/9 and E2E flows 4/5; both phases are Nyquist compliant. `git diff --check` passed. |
| Build | No new build was run for this documentation audit. Runtime evidence remains the Phase 30 178-test full suite. |

Outcome:

- The milestone remains `gaps_found` solely because one current blueprint contract cell contradicts completed Phase 29/30 eye evidence.
- No runtime blocker or new non-critical debt was found.
- Next step: repair the beauty-shaping eye contract row, scan equivalent blueprint tables, and rerun `$gsd-audit-milestone`.

### C-2026-07-13-v1-6-audit-doc-sync-repair-3

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Closed the remaining DOC-01 contradictions in `.planning/STATE.md` found by the third milestone audit. |
| Requirements | DOC-01 remediation; no runtime or product-scope change. |
| Files | `.planning/STATE.md`, `PLANS.md` |
| Verification | Full-file stale-state scans found no outdated PROJECT date, Phase 30 current focus, `Plan: Not started`, pending Phase 30 promotion, planning-only Phase 30 outcome, or instruction to execute Phase 30. Positive guards confirm 2/2 phases, 11/11 plans, Phase 30's 7/7 row, 178 tests, exactly four implemented eye rows, branch-level `眼睛` partial, and milestone-audit/archive routing. `git diff --check` passed. |
| Build | Not run; this repair changes documentation only. Runtime evidence remains the Phase 30 178-test full suite. |

Outcome:

- STATE now points to the current PROJECT date and identifies milestone closeout as the current position.
- The phase table and velocity count include completed Phase 30.
- Accumulated context records Phase 29 as followed by completed Phase 30 rather than leaving promotion pending.
- Pending work now routes to audit/archive rather than Phase 30 execution.
- Next step: rerun `$gsd-audit-milestone` for a fresh final verdict.

### C-2026-07-13-gsd-audit-milestone-v1-6-third-run

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Re-ran the complete v1.6 milestone audit after the second DOC-01 remediation, including three-source requirement coverage, Nyquist discovery, and a third independent cross-phase/E2E check. |
| Requirements | EYE-01 through EYE-08 satisfied; DOC-01 remains unsatisfied. Effective score remains 8/9. |
| Files | `.planning/v1.6-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | The checker confirmed all earlier defects in EXAMPLE_IMAGE_VALIDATION, PROJECT, QUALITY_SCORE, ROADMAP, and REQUIREMENTS are closed, then found internally stale current focus, position, context, and pending-todo state in `.planning/STATE.md`. Integration remains 8/9 and E2E flows 4/5. Both phases are Nyquist compliant; no runtime/source blocker or non-critical debt was found. `git diff --check` passed. |
| Build | No new build was run for this documentation audit. Runtime evidence remains the Phase 30 178-test full suite. |

Outcome:

- The milestone remains `gaps_found` solely because STATE contradicts its own completed frontmatter and Phase 30 result section.
- The second repair record's claim that STATE scans were clean was overbroad and is superseded by this fresh independent finding.
- Next step: repair STATE and rerun `$gsd-audit-milestone`.

### C-2026-07-13-v1-6-audit-doc-sync-repair-2

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Closed the remaining DOC-01 current-state contradictions found by the second v1.6 milestone audit and expanded the repair scan to the requirement footer. |
| Requirements | DOC-01 remediation; runtime behavior and the four-row/partial-branch boundary are unchanged. |
| Files | `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `PLANS.md` |
| Verification | Current-state scans found no remaining Phase 30-planned, v1.6-next/active, Phase-29-only current verification, obsolete current 173-test, or stale last-updated claims across PROJECT, ROADMAP, REQUIREMENTS, STATE, QUALITY_SCORE, and EXAMPLE_IMAGE_VALIDATION. ROADMAP's two phase rows have five cells matching the five declared columns. Positive guards confirm Phase 30/178 tests, all nine requirement IDs, exactly four implemented eye rows, and branch-level partial wording. `git diff --check` passed. |
| Build | Not run; this repair changes documentation only. Runtime evidence remains the Phase 30 178-test full suite. |

Outcome:

- PROJECT now records v1.6 implementation and verification through Phase 30, marks the eye-slice decision completed, and carries the current closeout date.
- ROADMAP now marks both phases complete and restores a structurally valid Phase 30 row with goal, requirement IDs, and five success criteria.
- REQUIREMENTS now carries the Phase 30/remediation update date.
- Next step: rerun `$gsd-audit-milestone` for a fresh final verdict.

### C-2026-07-13-gsd-audit-milestone-v1-6-rerun

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Re-ran the complete v1.6 milestone audit after the first DOC-01 remediation, including the three-source requirement cross-check, both phase validations, and a fresh independent integration/E2E check. |
| Requirements | EYE-01 through EYE-08 satisfied; DOC-01 remains unsatisfied. Effective milestone score remains 8/9. |
| Files | `.planning/v1.6-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | The integration checker confirmed that the first three defects were fixed, then found remaining current-state contradictions in `.planning/PROJECT.md` and `.planning/ROADMAP.md`. Integration remains 8/9 and E2E flows 4/5. Both phases remain Nyquist compliant; no runtime/source integration gap or non-critical debt was found. `git diff --check` passed. |
| Build | No new build was run for this documentation re-audit. Current runtime evidence remains the Phase 30 178-test full suite and the previous audit checker's fresh 48-test pass. |

Outcome:

- The milestone remains `gaps_found`; the first remediation was necessary but incomplete.
- PROJECT's Current State and decision/footer text still stop at Phase 29 or call v1.6 active, while ROADMAP still calls Phase 30 planned and has a malformed Phase 30 summary row.
- Next step: repair those PROJECT/ROADMAP surfaces and rerun `$gsd-audit-milestone`.

### C-2026-07-13-v1-6-audit-doc-sync-repair

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Closed the DOC-01 contradictions found by the v1.6 milestone audit without changing runtime behavior or broadening the eye slice. |
| Requirements | DOC-01 remediation; exactly four eye rows remain implemented and branch-level `眼睛` remains `partial`. |
| Files | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `.planning/PROJECT.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Focused stale-state scans found no remaining claims that Phase 30 is pending, no unchecked `Active in v1.6` block, and no current-snapshot references to the obsolete 173-test state. Positive guards found the Phase 30 evidence links, 178-test count, four implemented row names, and partial-branch boundary. `git diff --check` passed. |
| Build | Not run; this repair changes documentation only. Runtime evidence remains the Phase 30 178-test full suite and the audit integration checker's fresh 48-test pass. |

Outcome:

- `EXAMPLE_IMAGE_VALIDATION.md` now records the completed Phase 30 safety/status evidence and distinguishes four implemented rows from the partial eye branch.
- `.planning/PROJECT.md` no longer presents completed Phase 30 objectives as active unchecked work.
- `QUALITY_SCORE.md` Current Snapshot now reflects Phase 30 completion, 178 tests, current safety/degradation evidence, and future-only boundaries.
- Next step: rerun `$gsd-audit-milestone` to replace the pre-repair `gaps_found` verdict with a fresh audit result.

### C-2026-07-13-gsd-audit-milestone-v1-6

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Audited the v1.6 milestone across both phase verifications, all summary requirement metadata, REQUIREMENTS traceability, Nyquist validation, cross-phase wiring, and end-to-end flows. |
| Requirements | EYE-01 through EYE-08 satisfied; DOC-01 unsatisfied by current-document contradictions. Effective milestone score: 8/9. |
| Files | `.planning/v1.6-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | Both phase verification files pass and both validation files are Nyquist compliant. The integration checker found 8/9 integration checks wired and 4/5 E2E flows passing; its fresh targeted Swift selection passed 48 tests with zero failures. Direct inspection confirmed stale completion state in `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `.planning/PROJECT.md`, and the `QUALITY_SCORE.md` Current Snapshot. |
| Build | No full build was rerun for this documentation audit. The integration checker ran 48 targeted tests successfully. |

Outcome:

- Milestone status is `gaps_found`, not passed, because DOC-01's claimed synchronization is contradicted by three current owner surfaces.
- Runtime integration for the four existing public eye parameters is complete; EYE-01 through EYE-08 have no scoped cross-phase blocker.
- Both Phases 29 and 30 are Nyquist compliant, with no missing validation artifact.
- Next step: repair the three stale documentation surfaces in a scoped closure and rerun `$gsd-audit-milestone`.

### C-2026-07-13-gsd-execute-phase-30-eye-safety-ledger-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-13 |
| Scope | Ran `gsd-execute-phase-30` across seven sequential plans: public eye normalization/caps; missing/reused/stale degradation; combined weakening; command-backed renderer/security evidence; atomic four-row promotion; blueprint/root/quality/project synchronization; and final GSD/work-ledger closeout. |
| Requirements | EYE-04, EYE-05, EYE-06, EYE-07, EYE-08, DOC-01 |
| Files | Plan 30-01: `BeautyParameters.swift`, `BeautyEffectResolver.swift`, and two focused test files. Plan 30-02: resolver plus five degradation/facade/combined test files. Plan 30-03: `30-EYE-SAFETY-EVIDENCE.md`, `30-REVIEW.md`, `30-SECURITY.md`, `30-VERIFICATION.md`, `30-VALIDATION.md`. Plan 30-04: five blueprint owners. Plan 30-05: `DESIGN.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, phase security. Plan 30-06: `QUALITY_SCORE.md`, `.planning/PROJECT.md`. Plan 30-07: requirements, roadmap, state, this work ledger, verification, and validation. Each plan also records its summary. |
| Build | Seven focused suites passed with observed results: `BeautyParametersTests` 7, `BeautyEffectResolverTests` 12, `EyeWarpProviderTests` 6, `MissingLandmarkDegradationTests` 13, `CombinedEffectSafetyTests` 7, `BeautyEngineGeometryFacadeTests` 9, and `BeautyRendererOutputRegressionTests` 7. The full SDK suite, `BeautyExampleRenderer` build/run, and helper passed. No Demo build was required because Demo source was unchanged. |
| Commits | Plan task commits: `8bba092`, `4cf58a6`, `bcb504d`, `0d989f7`, `cd9848b`, `b5d985c`, `1257ce4`, `a9d3ea7`, `56187ac`, `7fc9da1`, `ecfe87e`, `6b0e2c3`, `74537ac`, plus Plan 30-07 closeout commits. |

#### Phase 30 Execution Evidence

The `gsd-execute-phase-30` transaction is backed by detailed command evidence in `30-EYE-SAFETY-EVIDENCE.md`.

full_suite_tests: 178

- EYE-04 observed tests prove positive-only size/tail normalization, signed distance/Y behavior, non-finite zeroing, exact caps, warnings, and aggregate cap counts.
- EYE-05 observed tests prove either-eye missing, reused, and stale eye geometry skip and zero the domain while reusable face shape, nose, and mouth remain scaled by 0.5; public no-face output preserves extent and safe domains.
- EYE-06 observed tests cover six visible signed/directional weakening cases and one all-eye multi-domain case with exactly six weakened fields.
- The renderer built and ran 23 cases across 7 fixtures, writing 161 ignored outputs; the unchanged helper passed 161/161 outputs and 36/36 portrait comparisons.
- No Demo build was required because Demo source was unchanged; Demo boundaries were covered by the import, network, and commercial scans.
- EYE-07 classifications passed: zero public/SPI raw-geometry candidates across asserted roots, zero forbidden Demo/renderer imports, zero network/cloud and commercial/StoreKit/entitlement execution paths, unchanged 31-field public inventory, no tracked generated artifacts, exact static allowlists `VIP-COMMERCIAL-ALLOW-01` and `VIP-COMMERCIAL-ALLOW-02`, and `unclassified_matches: 0`.
- `30-REVIEW.md` is clean; `30-SECURITY.md` is verified with `threats_open: 0`; decision coverage passed 21/21.
- EYE-08 atomically promoted exactly `大小`, `上下`, `眼距`, and `眼尾上扬`. Branch-level `眼睛` remains `partial`; future eye tools, device evidence, commercial visual review, broader parity, packaging, and readiness remain separate work.
- DOC-01 synchronized every blueprint, root, quality, project, requirement, roadmap, state, verification, validation, and work-ledger owner through independent bounded checks.
- Next step: run `$gsd-audit-milestone` for v1.6; milestone audit/archive is not claimed by Phase 30 execution.

### C-2026-07-11-gsd-plan-phase-30-eye-safety-ledger-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-11 |
| Scope | Created Phase 30 executable plans for Eye Safety, Ledger, and Closeout from the locked Phase 30 context, repository-grounded research, Nyquist validation strategy, and current code/test/document patterns. Checker feedback expanded the initial four-plan outline into seven bounded sequential waves with fail-closed security scans and evidence-before-promotion ordering. |
| Requirements | EYE-04, EYE-05, EYE-06, EYE-07, EYE-08, DOC-01 |
| Files | `.planning/milestones/v1.6-phases/30-eye-safety-ledger-and-closeout/30-RESEARCH.md`, `30-VALIDATION.md`, `30-PATTERNS.md`, `30-01-PLAN.md` through `30-07-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | User selected research-first. Research created `30-RESEARCH.md`; its focused six-suite baseline passed 49 tests. `30-VALIDATION.md` and `30-PATTERNS.md` were generated. Initial checker pass found six blockers covering premature evidence status, incomplete raw-geometry scans, tautological VIP classification, eye-side redaction, closeout scope, and aggregate doc scans. Revision reduced the next checker pass to two blockers: fail-open `rg` status handling and historical-text false positives. The second revision added explicit `rg` 0/1/>1 handling, bounded Phase 30 section/row checks, stale-contract negative guards, explicit evidence links, and canonical `full_suite_tests` equality. The final checker spawn failed because the sub-agent usage limit was reached; the user explicitly chose to accept the revised plans. Deterministic gates then passed: `phase-plan-index 30` reported seven plans in seven sequential waves with no checkpoints; all six Phase 30 requirement IDs were found in plan frontmatter; `check.decision-coverage-plan` passed 21/21 decisions; every one of 15 tasks has matching `read_first`, `action`, and `acceptance_criteria`; every plan has one threat model and one `Artifacts this phase produces` section; `roadmap.annotate-dependencies 30` recorded seven waves; scoped `git diff --check` passed. |
| Build | No implementation build was run because this workflow changed planning/documentation artifacts only. The research-time focused SDK baseline passed 49 tests; execution plans require focused and full SDK tests, `BeautyExampleRenderer` build/run, the Phase 29 161/161 and 36/36 helper regression, active-source security scans, and atomic ledger guards. |
| Commit | Research `62861ee`, validation `3365ec6`, pattern map `c833789`; the final planning/state/roadmap/ledger commit records the checker-driven revisions and seven plans. |

Outcome:

- `30-01-PLAN.md` locks positive-only `eyeSize`/`eyeTailLift`, signed `eyeDistance`/`eyeYPosition`, exact caps, abnormal-input behavior, warnings, and aggregate cap metrics.
- `30-02-PLAN.md` adds missing/reused/stale eye-domain zeroing and category-only redacted reasons while preserving non-eye reuse reduction, plus six per-behavior and one aggregate combined-weakening case.
- `30-03-PLAN.md` runs focused/full SDK evidence, the unchanged Phase 29 renderer regression, fail-closed EYE-07 boundary scans, review/security closeout, and promotion-ready evidence before any ledger edit.
- `30-04-PLAN.md` atomically promotes exactly `大小`, `上下`, `眼距`, and `眼尾上扬` while keeping branch-level `眼睛` partial and synchronizing the five blueprint evidence owners.
- `30-05-PLAN.md` through `30-07-PLAN.md` separately synchronize owning root contracts, quality/project state, and final GSD/work ledgers using per-file Phase 30 evidence-link and no-overclaim guards.
- Phase 30 is ready for `$gsd-execute-phase 30`; final plan-checker approval was not obtained because of the recorded sub-agent quota failure and was explicitly overridden by the user.

### C-2026-07-10-gsd-discuss-phase-30-eye-safety-ledger-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-10 |
| Scope | Ran `$gsd-discuss-phase 30` for Eye Safety, Ledger, and Closeout. Captured implementation decisions for positive-only eye input semantics, eye-specific stale/reused degradation, layered safety evidence, combined-geometry weakening, active-source boundary enforcement, atomic four-row ledger promotion, and targeted contract synchronization. |
| Requirements | Planning context for EYE-04, EYE-05, EYE-06, EYE-07, EYE-08, DOC-01 |
| Files | `.planning/milestones/v1.6-phases/30-eye-safety-ledger-and-closeout/30-CONTEXT.md`, `.planning/milestones/v1.6-phases/30-eye-safety-ledger-and-closeout/30-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 30` reported Phase 30 exists with no prior context, research, plans, verification, or phase directory. `todo.match-phase 30` returned zero matches. Project/requirements/state, Phases 27-29 context, current root/blueprint contracts, eye parameter/resolver/provider code, focused tests, Phase 29 evidence, and the stale codebase maps were reviewed. The user selected all four gray areas and explicitly chose all 16 recommended decisions. Context/log placeholder scans, canonical-reference existence checks, checkpoint JSON validation, and `git diff --check` passed. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 30 planning must include focused eye safety/degradation/combined tests, full `swift test --package-path BeautySDK`, `BeautyExampleRenderer` build/run, the 161/161 and 36/36 Phase 29 helper regression, active-source boundary scans, and atomic ledger-promotion guards. |
| Commit | `fe6b0f5` captured Phase 30 context/log; `4693b16` recorded the Phase 30 context session; the final ledger commit records this `PLANS.md` entry. |

Outcome:

- `eyeSize` and `eyeTailLift` are positive-only and normalize negative input to zero; `eyeDistance` and `eyeYPosition` remain signed. All four fields require exact cap/direction, warning/metric, finite-overflow, and non-finite input evidence.
- Reused and stale geometry both skip the eye domain completely, while other geometry domains retain established reused-strength reduction. Missing either eye group skips the entire eye domain.
- EYE-05 uses public-facade plus resolver/provider evidence; EYE-06 uses six per-behavior combined cases plus one all-eye/multi-domain case; Phase 29 visible-output evidence is rerun before closeout.
- Active-source EYE-07 violations are hard promotion blockers. `大小`, `上下`, `眼距`, and `眼尾上扬` promote atomically only after every gate passes, while branch-level `眼睛` remains `partial`.

Next step: `$gsd-plan-phase 30`.

### C-2026-07-09-gsd-execute-phase-29-eye-renderer-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-10 |
| Scope | Ran `$gsd-execute-phase 29` for Eye Renderer Output Evidence. Added public-facade eye renderer cases and helper evidence for existing public eye parameters, generated ignored gallery routing, command-backed evidence artifacts, final validation, review/security closeout, and planning/quality ledger closeout. |
| Requirements | EYE-01, EYE-02, EYE-03 |
| Files | `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py`, `29-EYE-RENDERER-EVIDENCE.md`, `29-VERIFICATION.md`, `29-VALIDATION.md`, `29-SECURITY.md`, `29-REVIEW.md`, `29-01-SUMMARY.md`, `29-02-SUMMARY.md`, `29-03-SUMMARY.md`, `29-04-SUMMARY.md`, `example-images/generate_gallery.py`, `example-images/README.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 7 tests. `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` passed with 6 tests. `swift test --package-path BeautySDK` passed with 173 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` wrote 161 ignored PNG outputs. `python3 .planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` passed with 161/161 outputs and 36/36 comparisons. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 161 ignored gallery PNGs. Unsafe gallery-root guard failed safely before deletion. `29-REVIEW.md` is `status: clean`; `29-SECURITY.md` is `status: verified` with `threats_open: 0`. Representative `git check-ignore` checks passed, `git ls-files example-images/output example-images/gallery` returned 0 tracked generated files, and raw-leak/no-overclaim/public-boundary/internal-import scans plus 14/14 GSD decision coverage passed. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because Phase 29 changed no Demo source or UI behavior; Demo boundary was covered by static import scans. |

Outcome:

- `BeautyExampleRenderer` now includes exactly six Phase 29 eye cases: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- `check_eye_renderer_outputs.py` verifies the 23-case by 7-fixture matrix, same dimensions, non-empty output files, 36/36 portrait eye-vs-baseline top-region comparisons, and representative no-face output `no-face-gradient__eyeSize_0p35.png`.
- `example-images/generate_gallery.py` routes the six eye cases into ignored `example-images/gallery/eyes/{caseId}/{fixtureStem}.png` review paths.
- Generated output and gallery PNGs remain ignored local artifacts; no generated PNG baseline is committed.
- Review/security closeout is clean: gallery deletion is constrained to `example-images/gallery/`, renderer output labels are path-redacted, every generated PNG is fully decoded by the helper, and all 23 plan-time threats are closed.
- Phase 29 records public-facade renderer evidence for existing public eye parameters only. `眼睛` rows and branch remain `partial` until Phase 30 safety, degradation, boundary, and scoped ledger closeout passes.
- Phase 29 does not add Demo UI, new public parameters, public raw geometry APIs, network/cloud behavior, commercial entitlement paths, generated PNG baselines, device parity, broad reference-app parity, launch readiness, or whole-branch eye completion.

Next step: `$gsd-discuss-phase 30`.

### C-2026-07-09-gsd-plan-phase-29-eye-renderer-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Created Phase 29 executable plans for Eye Renderer Output Evidence from Phase 29 context, research, validation strategy, and pattern map artifacts. |
| Requirements | EYE-01, EYE-02, EYE-03 |
| Files | `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/29-RESEARCH.md`, `29-VALIDATION.md`, `29-PATTERNS.md`, `29-01-PLAN.md`, `29-02-PLAN.md`, `29-03-PLAN.md`, `29-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | User selected research-first. Researcher created `29-RESEARCH.md` and commit `90435c4`. Validation strategy commit `1a9ab03` created `29-VALIDATION.md`; pattern map commit `e521c77` created `29-PATTERNS.md`; planner created four plan files in commit `3a387aa`. Checker pass 1 found unresolved research questions and a missing Phase 28 evidence analog reference; commit `3bc2433` resolved both. Final plan-checker returned `VERIFICATION PASSED` for 4 plans. Requirement scan confirmed EYE-01, EYE-02, and EYE-03 are covered. `check.decision-coverage-plan` passed with `14/14` decisions covered. `phase-plan-index 29` reports waves 1-4: `29-01`, `29-02 -> 29-01`, `29-03 -> 29-01/29-02`, and `29-04 -> 29-03`. Scoped `git diff --check` passed for Phase 29 planning artifacts, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 29 execution plans require focused SDK tests, full `swift test --package-path BeautySDK`, `BeautyExampleRenderer` build/run, Phase 29 helper checks, generated gallery checks, ignored-output checks, raw-leak/no-overclaim scans, and GSD decision coverage. |

Outcome:

- `29-01-PLAN.md` adds exactly six public-facade eye renderer cases plus renderer inventory tests and `check_eye_renderer_outputs.py` for 161/161 outputs and 36/36 eye-vs-baseline comparisons.
- `29-02-PLAN.md` adds ignored generated `eyes/` gallery support and updates example-image validation docs without committing generated PNG baselines.
- `29-03-PLAN.md` records command-backed renderer/helper/gallery/ignore evidence and final validation, mirroring the Phase 28 evidence artifact structure.
- `29-04-PLAN.md` synchronizes requirements, roadmap, state, quality, and ledger notes while keeping `眼睛` rows and branch status partial until Phase 30.
- Phase 29 is ready for `$gsd-execute-phase 29`.

### C-2026-07-09-gsd-discuss-phase-29-eye-renderer-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Ran `$gsd-discuss-phase 29` for Eye Renderer Output Evidence. Captured Phase 29 implementation decisions for public-facade eye renderer case matrix, helper evidence gates, generated output/gallery routing, and documentation/status boundaries. |
| Requirements | EYE-01, EYE-02, EYE-03 |
| Files | `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/29-CONTEXT.md`, `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/29-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 29` reported Phase 29 exists with no prior context, research, plans, verification, or phase directory. `todo.match-phase 29` returned zero matches. Prior context from Phases 26, 27, and 28 plus root contracts, blueprint docs, current renderer/eye code, tests, helper, gallery, and ignore policy were read. User selected all three gray areas and chose the recommended option for each detailed question. Scoped `git diff --check` passed for Phase 29 context/log, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 29 planning should include renderer inventory tests, helper verification, `BeautyExampleRenderer` build/run, ignored-output/gallery checks, and no-overclaim/status scans. |

Outcome:

- Phase 29 should add exactly six eye renderer cases: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- The Phase 29 helper should validate the full renderer matrix plus 36/36 portrait eye-vs-`geometryBaseline_noop` top-region comparisons, and fail/fix before completion if any comparison fails.
- `example-images/output/` is the canonical generated output path, and generated gallery support should add an ignored `eyes/` group.
- Phase 29 may record renderer evidence but must keep `眼睛` rows and branch status `partial` until Phase 30 safety/degradation/ledger closeout passes.

Next step: `$gsd-plan-phase 29`.

### C-2026-07-09-v1-6-milestone-initialization

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Started v1.6 as the Broader `美型 / 五官` SDK Slice - Eyes milestone after converging the dirty worktree. Defined requirements and roadmap for the existing-parameter `眼睛` slice without adding UI, public API, commercial, network, device, release-readiness, or unscoped eye-tool scope. |
| Files | `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `state.milestone-switch --milestone "v1.6" --name "Broader 美型 / 五官 SDK Slice - Eyes"` initialized milestone state. Scoped scans verified v1.6 references, Phase 29/30 routing, and EYE-01 through EYE-08 plus DOC-01 traceability across `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`. `git diff --check` passed. |
| Build | Not run; this was a planning/documentation initialization with no Swift source changes. |

Outcome:

- v1.6 is now the active milestone.
- Phase 29 owns public-facade eye renderer/helper output evidence for `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift`.
- Phase 30 owns eye caps/degradation/redaction/boundary tests and scoped ledger/documentation closeout.
- Branch-level `眼睛` remains partial until evidence-backed rows are promoted.

Next step: `$gsd-discuss-phase 29`.

### C-2026-07-09-example-input-e6-portrait-fixture

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Added user-supplied `e6.jpg` as a sixth committed portrait fixture while preserving the nested example-image contract and generated-output ignore policy. |
| Files | `example-images/input/portraits/e6.jpg`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `example-images/README.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `e6.jpg` is 1728x2304 and 591,802 bytes. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 119 ignored flat outputs. `python3 .planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/output` passed with 77/77 outputs and 6/6 portrait geometry-vs-baseline top-region comparisons. `python3 .planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output` passed with 119/119 outputs and 36/36 portrait face-shape-vs-baseline top-region comparisons. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 119 ignored gallery PNGs. Focused fixture-path tests passed: `BeautyCoreTests.BeautyRendererOutputRegressionTests` 6 tests, `BeautyCoreTests.BeautyEngineGeometryFacadeTests` 8 tests, and `BeautyDetectionTests.VisionFaceDetectorTests` 8 tests. |
| Build | Focused SDK tests, renderer run, Phase 27 helper, Phase 28 helper, and gallery generation passed. Full SDK suite was not rerun because this only added one source fixture and synchronized fixture path inventories/docs. |

Outcome:

- `example-images/input/portraits/` now has six portrait fixtures: `e1.png` through `e5.png` plus `e6.jpg`.
- The Python helpers support PNG and JPEG input fixture dimensions while still requiring generated outputs to be PNG.
- Generated output and gallery artifacts remain ignored.

### C-2026-07-09-example-input-fixture-compression

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Reduced committed `example-images/input` source fixture dimensions and file sizes so every original input image is below 1 MB while preserving renderer/test usefulness. |
| Files | `example-images/input/portraits/e1.png`, `example-images/input/portraits/e2.png`, `example-images/input/portraits/e3.png`, `example-images/input/portraits/e4.png`, `example-images/input/portraits/e5.png`, `example-images/input/negatives/no-face-gradient.png`, `example-images/README.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Size/dimension inspection confirmed `e1.png` is 675x900 and 929,129 bytes; `e2.png`, `e3.png`, `e4.png`, and `e5.png` are 506x900 and 650,316/680,540/731,951/717,292 bytes; `no-face-gradient.png` is 64x64 and 381 bytes. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 102 ignored flat outputs from compressed inputs. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 102 ignored gallery PNGs. Focused fixture-path tests passed: `BeautyCoreTests.BeautyRendererOutputRegressionTests` 6 tests, `BeautyCoreTests.BeautyEngineGeometryFacadeTests` 8 tests, and `BeautyDetectionTests.VisionFaceDetectorTests` 8 tests. Phase 27 helper passed with 66/66 outputs and 5/5 portrait geometry-vs-baseline top-region comparisons. Phase 28 helper passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. `find` counted 102 output PNGs and 102 gallery PNGs. `git check-ignore` confirmed representative output and gallery PNGs are ignored. |
| Build | Focused SDK tests and renderer run passed. Full SDK suite was not rerun because this changed only committed example image fixtures, ignored regenerated artifacts, and docs. |

Outcome:

- Portrait source fixtures now use a 900 px maximum edge.
- The no-face negative fixture is now a 64x64 generated gradient.
- Every committed input PNG is under 1 MB.

### C-2026-07-08-example-images-structured-layout

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Finished the example-image directory design with committed nested input fixtures, ignored flat generated output, ignored generated gallery view, and synchronized renderer/test/helper/docs paths. |
| Files | `example-images/input/`, `example-images/README.md`, `example-images/generate_gallery.py`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`, `.gitignore`, `ARCHITECTURE.md`, `SECURITY.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. Focused fixture-path tests passed: `BeautyCoreTests.BeautyRendererOutputRegressionTests` 6 tests, `BeautyCoreTests.BeautyEngineGeometryFacadeTests` 8 tests, and `BeautyDetectionTests.VisionFaceDetectorTests` 8 tests. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 102 flat ignored PNG outputs from nested fixtures. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 102 ignored gallery PNGs. Phase 27 helper passed with 66/66 outputs and 5/5 portrait geometry-vs-baseline top-region comparisons. Phase 28 helper passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. `find` counted 102 output PNGs and 102 gallery PNGs. `git check-ignore` confirmed representative output and gallery PNGs are ignored. A scoped scan found no active references to the legacy `example-images/out/` path or the old flat `example-images/input/e*.png` and `example-images/input/no-face-gradient.png` fixture paths. |
| Build | SDK renderer build and focused SDK tests passed. Full SDK suite was not rerun because this changed example fixture organization, renderer fixture discovery, helper scripts, ignored generated artifacts, and docs only. |

Outcome:

- Source fixtures are now committed under `example-images/input/portraits/` and `example-images/input/negatives/`.
- `BeautyExampleRenderer` recursively reads nested input fixtures and keeps generated PNG names flat under ignored `example-images/output/`.
- `example-images/gallery/` is an ignored generated review view grouped by feature family and case ID.

### C-2026-07-08-example-images-output-directory-rename

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Renamed the current generated example-image directory contract from `example-images/out` to `example-images/output` while keeping `example-images/input` as the source fixture directory. |
| Files | `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `.gitignore`, `example-images/README.md`, `ARCHITECTURE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input` used the new default and wrote 102 ignored PNG outputs under `example-images/output`. `python3 .planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output` passed with 102/102 outputs and 30/30 portrait face-shape comparisons. `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 6 tests. `git check-ignore` confirmed representative `example-images/output/*.png` files are ignored. A scoped scan found no legacy `example-images/out/` path in active renderer source, the example-image README, root contract docs, current quality snapshot, or SDK tests; older Completed ledger/history entries still preserve their original command text. |
| Build | SDK renderer build and focused renderer tests passed. Full SDK suite was not rerun because this changed the renderer default output path, ignore policy, local generated artifact directory, and docs only. |

Outcome:

- `example-images/input/` remains the committed fixture source directory.
- `example-images/output/` is now the ignored generated-output directory.
- Local generated PNGs were moved from `out/` to `output/`; the legacy `example-images/out/` directory was removed.

### C-2026-07-08-v1-5-face-shape-visual-warp-validation

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Corrected the v1.5 face-shape validation gap where saved renderer outputs changed pixels through a global geometry proxy but did not visibly deform face shape. |
| Requirements | GEO-03, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05 |
| Files | `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, `.planning/MILESTONES.md`, `.planning/RETROSPECTIVE.md`, `ARCHITECTURE.md`, `DESIGN.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Confirmed the original CIImage path only applied `CIColorMatrix` global color bias after control-point generation. Replaced that path with control-point-driven local CIImage resampling that preserves unaffected pixels. Added `BeautyGeometryEffectPipelineTests/testCIImageGeometryWarpMovesLocalPixelsWithoutGlobalColorBias`. Focused tests passed: new spatial-warp test, `BeautyEffectsTests.GeometryConflictResolverTests`, `BeautyEffectsTests.FaceShapeWarpProviderTests`, and `BeautyCoreTests.BeautyEngineGeometryFacadeTests`. Full `swift test --package-path BeautySDK` passed with 172 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` regenerated 102 ignored PNG outputs. Phase 28 helper passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because the correction changed SDK still-image internals, SDK tests, ignored renderer outputs, and documentation only; no Demo source/UI behavior changed. |

Outcome:

- User-reported validation issue is confirmed and fixed for the still-image public-facade path.
- v1.5 face-shape evidence now includes a spatial regression that rejects global color-only output as geometry evidence.
- Public API, Demo UI, raw geometry exposure, `jawSlim` alias handling, and scoped `脸型` ledger boundaries remain unchanged.

### C-2026-07-08-gsd-complete-milestone-v1-5

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Archived v1.5 SDK Geometry Output Foundation and Face Shape Slice after the milestone audit passed. |
| Requirements | GEO-01, GEO-02, GEO-03, GEO-04, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-ROADMAP.md`, `.planning/milestones/v1.5-REQUIREMENTS.md`, `.planning/milestones/v1.5-MILESTONE-AUDIT.md`, `.planning/MILESTONES.md`, `.planning/ROADMAP.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/RETROSPECTIVE.md`, `PLANS.md` |
| Verification | `audit-open` reported all artifact types clear. `roadmap.analyze` reported Phases 26-28 complete with 12/12 plans summarized and 100% progress. `.planning/milestones/v1.5-MILESTONE-AUDIT.md` has `status: passed`. `milestone.complete v1.5 --name "SDK Geometry Output Foundation and Face Shape Slice"` archived roadmap, requirements, and audit files and updated `MILESTONES.md`/`STATE.md`. Follow-up scans verified live roadmap/project/state references route to `$gsd-new-milestone`; archive files exist under `.planning/milestones/`; scoped whitespace/diff checks passed. |
| Build | Not run; this was a milestone archive/documentation workflow. No Swift source changed. |

Outcome:

- v1.5 is archived under `.planning/milestones/`.
- Live `.planning/ROADMAP.md` is constant-size and points to `$gsd-new-milestone`.
- `.planning/PROJECT.md` records v1.5 as the shipped version and moves v1.5 requirements into completed history.
- Phase directories remain in `.planning/phases/` for path-stable execution history, matching the prior v1.4 operator choice.

Next step: `$gsd-new-milestone`.

### C-2026-07-08-gsd-audit-milestone-v1-5

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Ran the v1.5 milestone audit preflight after `$gsd-progress --next` found Phases 26-28 complete and no incomplete execution work. |
| Requirements | GEO-01, GEO-02, GEO-03, GEO-04, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-MILESTONE-AUDIT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `PLANS.md` |
| Verification | Read GSD progress/next/audit workflow instructions, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and Phase 26-28 verification/validation/summary artifacts. `gsd-tools.cjs query state.json`, `roadmap.analyze`, `phases.list`, and `init.milestone-op` showed v1.5 at 3/3 phases and 12/12 plans complete. Safety checks found no `.planning/.continue-here.md`, no error/failed state, no Phase 28 `FAIL` markers, and no plans without summaries. Requirement, verification, summary-frontmatter, and Nyquist scans confirmed 13/13 v1.5 requirements satisfied, Phase 26/27/28 verifications passed, and all three validation files are `nyquist_compliant: true`. |
| Build | Not run; this was a milestone audit/documentation workflow aggregating existing command-backed phase evidence. No Swift source changed. |

Outcome:

- `.planning/milestones/v1.5-MILESTONE-AUDIT.md` records `status: passed` with 13/13 requirements, 3/3 phases, 4/4 integration checks, and 4/4 E2E flows satisfied.
- No critical requirement, integration, flow, orphan, or Nyquist gaps were found.
- Deferred broader `美型 / 五官`, device, commercial, screenshot, profiling, packaging, and launch-readiness work remains outside v1.5 scope.

Next step completed by `C-2026-07-08-gsd-complete-milestone-v1-5`.

### C-2026-07-08-gsd-execute-phase-28-face-shape-slice-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Ran `$gsd-execute-phase 28` for Face Shape Slice Completion and Documentation Closeout. Completed per-tool face-shape renderer cases/helper evidence, focused safety/degradation/redaction tests, command-backed evidence capture, scoped ledger promotion, final verification, root docs, and planning ledgers. |
| Requirements | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift`, `CombinedEffectSafetyTests.swift`, `GeometryConflictResolverTests.swift`, `BeautyEffectResolverTests.swift`, `MissingLandmarkDegradationTests.swift`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`, `28-FACE-SHAPE-RENDERER-EVIDENCE.md`, `28-VERIFICATION.md`, `28-VALIDATION.md`, `28-01-SUMMARY.md`, `28-02-SUMMARY.md`, `28-03-SUMMARY.md`, blueprint docs, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Focused SDK tests passed: `BeautyRendererOutputRegressionTests` 6 tests, `FaceShapeWarpProviderTests` 8 tests, `CombinedEffectSafetyTests` 5 tests, `GeometryConflictResolverTests` 7 tests, `BeautyEffectResolverTests` 10 tests, and `MissingLandmarkDegradationTests` 14 tests. Full `swift test --package-path BeautySDK` passed with 171 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 102 ignored PNG outputs. `check_face_shape_renderer_outputs.py` passed with 102/102 outputs and 30/30 top-region comparisons. Representative `git check-ignore`, public/import boundary scans, hidden public-surface scans, evidence redaction scans, no-overclaim scans, ledger guards, Demo internal-import scan, GSD decision coverage, and scoped `git diff --check` passed. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because Phase 28 changed no Demo source/UI behavior; Demo boundary was covered by static import scans. |
| Commit | Task commits include `4cb9eed`, `2b0bc95`, `c74970c`, `16a2822`, `eb2a419`, `a54d471`, `841ef5a`, `d4c6391`, `685b73e`, `161370f`, and `7d6d1c9`. Post-closeout metadata/review commits: `e707d42`, `9b1562c`, and `b7a7995`; this ledger update records the final commit list. |

Outcome:

- FACE-01 through FACE-05 are complete through existing public parameters `faceSlim`, `faceSmall`, signed `chinLength`, `faceVShape`, and `jawSlim`.
- FACE-06 is complete as a documented `jawSlim` alias for `下颌线`; no separate parameter, renderer case, Demo behavior, commercial gate, or algorithm split was added.
- `SHAPE_FEATURE_LEDGER.md` marks exactly `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` as implemented.
- `FEATURE_MATRIX.md` keeps branch-level `脸型` partial; unscoped `脸型` rows and broader `美型 / 五官` branches remain future or partial according to their existing evidence.
- Phase 28 records no Demo UI completion, device parity, commercial visual review, broad reference-app parity, new geometry group, launch-readiness, generated PNG baseline, public raw geometry API, or whole-branch `脸型` completion claim.

Next step: run the v1.5 milestone audit/closeout flow.

### C-2026-07-08-gsd-plan-phase-28-face-shape-slice-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Created Phase 28 executable plans for Face Shape Slice Completion and Documentation Closeout from Phase 28 context, research, validation strategy, and pattern map artifacts. |
| Requirements | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/28-RESEARCH.md`, `28-VALIDATION.md`, `28-PATTERNS.md`, `28-01-PLAN.md`, `28-02-PLAN.md`, `28-03-PLAN.md`, `28-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 28` reported Phase 28 pending with `has_context: true`, `has_research: false`, `has_plans: false`, `phase_req_ids: FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03`, `research_enabled: true`, `plan_checker_enabled: true`, `nyquist_validation_enabled: true`, and `commit_docs: true`. User selected research-first. Researcher created `28-RESEARCH.md` and commit `f3dee08`. Validation strategy commit `6df5e40` created `28-VALIDATION.md`; pattern map commit `0f3b640` created `28-PATTERNS.md`; planner created four plan files in commit `80f0705`. Checker pass 1 found unresolved research questions, a false-positive bare `pro` scan, and a stale validation map; commit `a628981` fixed them. Checker pass 2 found shell command-substitution risk in `28-04`; commit `0e3e513` fixed it. Checker pass 3 found missing watermark-only false-positive mitigation in `28-02`/`28-04`; commit `9d1ec34` fixed it. Final plan-checker returned `VERIFICATION PASSED` for 4 plans. `phase-plan-index 28` reports waves 1-3 with `28-01` and `28-02` parallel in Wave 1, `28-03 -> 28-01/28-02`, and `28-04 -> 28-03`. `check.decision-coverage-plan` passed with `15/15` decisions covered. Requirement scan confirmed all nine Phase 28 FACE/DOC IDs are covered. Post-planning gap analysis showed all Phase 28 FACE/DOC IDs and D-01 through D-15 covered; uncovered GEO-01 through GEO-04 rows belong to prior v1.5 phases, not Phase 28 scope. Scoped `git diff --check` passed for Phase 28 planning artifacts, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 28 execution plans require focused SDK tests, full `swift test --package-path BeautySDK`, `BeautyExampleRenderer` build/run, Phase 28 helper checks, ignored-output checks, raw-leak scans, no-overclaim scans, ledger guards, and GSD decision coverage. |
| Commit | Planning commits: `f3dee08`, `6df5e40`, `0f3b640`, `80f0705`, `a628981`, `0e3e513`, `9d1ec34`; final state/ledger commit records this entry. |

Outcome:

- `28-01-PLAN.md` adds per-tool public-facade renderer cases for `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, positive `chinLength`, and negative `chinLength`, plus a Phase 28 top-region helper.
- `28-02-PLAN.md` closes focused safety/degradation/redaction evidence for caps, no-face/missing contour, signed `chinLength`, combined weakening, and raw-geometry leak prevention.
- `28-03-PLAN.md` records command-backed renderer/helper/test evidence before any status promotion.
- `28-04-PLAN.md` promotes only the six scoped `脸型` rows after evidence passes, keeps branch-level `脸型` partial, and synchronizes blueprint/root/planning ledgers without Demo UI, public API, parity, commercial quality, device parity, or release-readiness claims.
- Phase 28 is ready for `$gsd-execute-phase 28`.

### C-2026-07-07-gsd-discuss-phase-28-face-shape-slice-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Ran `$gsd-progress --next`, which passed safety gates after Phase 27 completion and routed to `$gsd-discuss-phase 28` for Face Shape Slice Completion and Documentation Closeout. Captured decisions for `下颌线` alias handling, per-tool renderer/test evidence, and scoped status/document closeout. |
| Requirements | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/28-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `$gsd-progress --next` found no unresolved `.planning/.continue-here.md`, no error/failed state, no unresolved Phase 27 verification failures, and no Phase 26/27 plans without summaries. `init.phase-op 28` reported Phase 28 exists in the roadmap with no context, research, plans, verification, or phase directory. `todo.match-phase 28` returned zero matches. Prior context from Phases 27, 26, and 25 plus root contracts, blueprint docs, and relevant renderer/face-shape code/tests were read. User selected all three gray areas and chose the recommended option for each detailed question. Scoped `git diff --check` passed for Phase 28 context/log, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 28 planning should include per-parameter renderer cases, geometry-vs-baseline helper evidence, focused SDK tests for safety/degradation/redaction, full SDK tests where local tooling allows, and scoped ledger/doc synchronization after evidence exists. |
| Commit | Included in the Phase 28 context/session ledger commits. |

Outcome:

- `下颌线` is locked as an alias-backed `jawSlim` behavior for v1.5; Phase 28 must not add a separate public parameter, Demo behavior, entitlement/pro path, or distinct algorithm.
- Phase 28 evidence should include one renderer case per distinct face-shape SDK parameter: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and both positive and negative `chinLength`; `下颌线` shares `jawSlim`.
- Each renderer case must preserve dimensions and show a geometry-vs-`geometryBaseline_noop` delta above the watermark band on usable portrait fixtures.
- Focused XCTest/scans should cover caps, missing contour/no-face degradation, signed `chinLength`, combined weakening, redaction, and raw-geometry leak prevention.
- If evidence passes, promote only `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`; keep branch-level `脸型` as `partial` and avoid UI, commercial quality, device parity, broad Meitu parity, new geometry group, or release-readiness claims.

Next step: `$gsd-plan-phase 28`.

### C-2026-07-07-gsd-execute-phase-27-geometry-render-output-harness

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Ran `$gsd-execute-phase 27` for Geometry Render Output and Verification Harness. Completed four dependent waves: real still-image Vision input seam, selected-face still-image geometry output routing, renderer matrix/helper/no-face fixture, and final evidence plus root/planning ledger synchronization. |
| Requirements | GEO-03, GEO-04 |
| Files | `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`, `BeautyGeometryEffectPipeline.swift`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, focused SDK tests, `example-images/input/no-face-gradient.png`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`, `27-GEOMETRY-RENDERER-EVIDENCE.md`, `27-VERIFICATION.md`, `27-VALIDATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 8 tests; `BeautyRendererOutputRegressionTests` passed with 4 tests; focused missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict-cap tests each passed; full `swift test --package-path BeautySDK` passed with 167 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 66 ignored PNG outputs. `check_geometry_renderer_outputs.py` passed with 66/66 outputs, same dimensions, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face output presence. Public/SPI raw geometry export scans, active-source redaction scans, renderer public-import scans, renderer scope scans, Demo internal-import scans, evidence raw-leak scans, overclaim scans, face-shape ledger guard, GSD decision coverage, and scoped `git diff --check` passed. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because Phase 27 changed no Demo source/UI behavior; Demo boundary was covered by static import scans. |
| Commit | Task commits include `2355587`, `cd21ba3`, `5ae3bbe`, `3a3e0fd`, `21639fd`, `761283d`, `14ec1f5`, `160702a`, `acbf066`, and `3d8f9e2`; final docs/ledger synchronization and review/fix are committed with this entry. |

Outcome:

- GEO-03 is complete: `BeautyExampleRenderer` now emits `geometryBaseline_noop` and `faceShapeCombo_0p35`, and the helper verifies same-dimension saved-output geometry evidence without hashes or committed PNG baselines.
- GEO-04 is complete: no-face saved-output evidence plus missing-landmark, stale/reused, combined-strength, and face-shape conflict-cap tests pass with redacted summaries and aggregate metrics.
- Phase 27 remains SDK-only: no Demo UI work, no public raw geometry API, no eye/nose/mouth/lip saved-output expansion, no generated PNG baselines, no quality/parity/launch claims, and no `SHAPE_FEATURE_LEDGER.md` implemented-status promotion.
- Phase 28 is the next owner for per-tool `脸型` completion, `下颌线` alias handling, and status ledger promotion.

Next step: `$gsd-discuss-phase 28`.

### C-2026-07-07-gsd-plan-phase-27-geometry-render-output-harness

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Created Phase 27 executable plans for Geometry Render Output and Verification Harness from existing Phase 27 context, research, validation, and pattern-map artifacts. |
| Requirements | GEO-03, GEO-04 |
| Files | `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-01-PLAN.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-02-PLAN.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-03-PLAN.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 27` reported Phase 27 pending with context present, no research, no plans, `phase_req_ids: GEO-03, GEO-04`, `research_enabled: true`, `plan_checker_enabled: true`, `nyquist_validation_enabled: true`, and `commit_docs: true`. User selected research-first. Researcher created `27-RESEARCH.md` and commit `b1f2596`. Validation strategy commit `f3aa8e4` created `27-VALIDATION.md`. Pattern mapper created `27-PATTERNS.md` and commit `de2928e`. Planner created four plan files in commit `5e12547`. The `gsd-plan-checker` subagent was spawned but did not return after the wait windows and was closed; inline checker pass found invalid negative scan semantics in `27-03` and `27-04`, fixed in commit `70084fa`. `phase-plan-index 27` reports four plans across waves 1-4 with dependencies `27-02 -> 27-01`, `27-03 -> 27-02`, and `27-04 -> 27-03`. `check.decision-coverage-plan` passed with 17/17 Phase 27 decisions covered. Requirement scan confirmed GEO-03 and GEO-04 appear in all four plan files. Threat-model, Artifacts, read-first, and acceptance-criteria scans passed across all four plans. Post-planning gap analysis showed GEO-03/GEO-04 and D-01 through D-17 covered; uncovered DOC/FACE/GEO-01/GEO-02 rows belong to other v1.5 phases, not Phase 27 scope. Scoped `git diff --check` passed for Phase 27 planning artifacts, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 27 execution plans require focused SDK tests, full `swift test --package-path BeautySDK`, renderer build/run, Phase 27 helper checks, ignored-output checks, raw-leak scans, no-overclaim scans, and ledger-status guards. |
| Commit | Planning commits: `b1f2596`, `f3aa8e4`, `de2928e`, `5e12547`, `70084fa`; final state/ledger commit records planning completion. |

Outcome:

- `27-01-PLAN.md` creates the real still-image detection input seam and public-facade fixture probe.
- `27-02-PLAN.md` carries selected-face geometry into the internal still-image render path and proves pre-watermark geometry output differs from a no-geometry baseline.
- `27-03-PLAN.md` appends the renderer baseline and combined face-shape case, adds a dedicated no-face input fixture, and creates the Phase 27 geometry output helper.
- `27-04-PLAN.md` records final renderer/degradation evidence and synchronizes root docs and planning ledgers without promoting Phase 28 `脸型` status.
- Phase 27 remains SDK-only: no Demo UI work, no public raw geometry API, no committed generated PNG baselines, no quality/parity/release claims, and no `SHAPE_FEATURE_LEDGER.md` `implemented` promotion.

Next step: `$gsd-execute-phase 27`.

### C-2026-07-07-gsd-discuss-phase-27-geometry-output-harness

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Ran `$gsd-progress --next`, which passed safety gates after Phase 26 completion and routed to `$gsd-discuss-phase 27` for Geometry Render Output and Verification Harness. Captured user decisions for renderer-first geometry saved-output evidence, face-shape-first scope, mechanical evidence bar, degradation evidence split, and no-overclaim/privacy boundaries before planning. |
| Requirements | GEO-03, GEO-04 |
| Files | `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `$gsd-progress --next` found no unresolved `.planning/.continue-here.md`, no error/failed state, no unresolved Phase 26 verification failures, and no prior plans without summaries. `init.phase-op 27` reported Phase 27 exists in the roadmap with no context, research, plans, verification, or phase directory. `todo.match-phase 27` returned zero matches. Prior contexts from Phases 26, 25, and 24 plus root contracts and relevant renderer/geometry code were read. User selected all four gray areas, then selected the recommended option for each detailed question and selected finish context. The temporary `27-DISCUSS-CHECKPOINT.json` parsed successfully while in use and was removed after canonical context/log creation. `state.record-session --stopped-at "Phase 27 context gathered" --resume-file ".planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md"` reported `recorded: true`; `state.update "Status" "Ready for Phase 27 planning"` reported `updated: true`. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 27 planning should include renderer/helper tests, real-facade `BeautyExampleRenderer` build/run evidence, geometry-output helper checks, focused degradation/redaction tests, no-overclaim scans, and full SDK tests where local tooling allows. |
| Commit | Included in the Phase 27 context/session ledger commits. |

Outcome:

- Phase 27 should use a renderer-first hybrid: append geometry cases to `BeautyExampleRenderer`, back them with focused tests/helper checks, and add a narrow fallback verifier only if real-facade fixture detection cannot cover a required degradation case.
- Saved-output scope is face-shape first with one combined moderate-strength case for existing `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`; Phase 28 still owns per-tool `脸型` evidence and ledger promotion.
- A saved-output pass means same dimensions, non-identical geometry output against a no-geometry baseline, redacted geometry metrics, ignored generated PNGs under `example-images/out/`, and representative factual notes only.
- GEO-04 evidence must cover no-face, missing-landmark, stale/reused, and combined-strength paths; renderer PNGs are required for happy path and no-face, while the remaining paths may use focused XCTest plus helper/evidence Markdown summaries.
- Phase 27 must not add Demo UI work, public raw geometry APIs, committed PNG baselines, subjective quality claims, commercial/release readiness claims, full Meitu parity claims, or `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.

### C-2026-07-06-gsd-execute-phase-26-geometry-facade-routing

| Field | Value |
| --- | --- |
| Completed | 2026-07-06 |
| Scope | Ran `$gsd-execute-phase 26` for Geometry Facade and Landmark Routing Foundation. Completed four dependent waves: package-only selected-face geometry resolver routing, public still-image facade detection gating, final verification/validation evidence, and root/planning ledger synchronization. |
| Requirements | GEO-01, GEO-02 |
| Files | `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `CoordinateSpace.swift`, `VisionFaceDetector.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautyEffectResolver.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, `BeautyEngineTestingSupport.swift`, focused SDK tests, `.planning/milestones/v1.5-phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md`, `26-VALIDATION.md`, `26-REVIEW.md`, `26-01-SUMMARY.md`, `26-02-SUMMARY.md`, `26-03-SUMMARY.md`, `26-04-SUMMARY.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 4 tests; `BeautyEngineMetadataCompatibilityTests` passed with 4 tests; `BeautyDetectionTests.VisionFaceDetectorTests` passed with 6 tests; `BeautyEffectsTests.BeautyEffectResolverTests` passed with 10 tests; `BeautyEffectsTests.MissingLandmarkDegradationTests` passed with 14 tests; full `swift test --package-path BeautySDK` passed with 159 tests. Public/SPI raw geometry export scans, active-source raw-leak scans, Demo internal-import scan, renderer geometry-case exclusion scan, `SHAPE_FEATURE_LEDGER.md` implemented-status guard, D-01 through D-16 traceability scan, root/planning evidence scan, scoped `git diff --check`, and Phase 26 code review passed. |
| Build | SDK SwiftPM tests passed. No Demo build/test was run in Phase 26 because no Demo source/UI behavior changed; Demo boundary was covered by static import and active-source redaction scans. |
| Commit | Task commits include `82ef988`, `04c033b`, `9e8dc18`, `3308a67`, `3a15fbc`, `b3cc91b`, `958527d`, `bfd1d17`, and `3809f6a`; final review commit records `26-REVIEW.md` and this ledger update. |

Outcome:

- GEO-01 is complete: public still-image `BeautyEngine.processResult(image:metadata:parameters:)` now detects only for geometry-triggering face-shape, eye, nose, mouth, or `lipColor` parameters, while no-op/color/filter/basic-skin paths preserve `.notRun` and disabled tracking preserves `.disabled`.
- GEO-02 is complete: selected package-only detection observations can feed internal `FaceGeometry` planning through `BeautyEffectResolver` without public raw landmark, bounding-box, control-point, Vision object, raw framework error, local path, raw JSON, or image-byte exposure.
- Phase 26 intentionally adds no Demo UI behavior, no `BeautyExampleRenderer` geometry case, no saved-output PNG evidence claim, no public raw geometry API, no commercial quality/full parity/release-readiness claim, and no `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.
- Phase 27 is the next owner for deterministic saved-output geometry rendering evidence; Phase 28 remains the owner for verified `脸型` tool completion and ledger promotion.

### C-2026-07-06-gsd-plan-phase-26-geometry-facade-routing

| Field | Value |
| --- | --- |
| Completed | 2026-07-06 |
| Scope | Ran `$gsd-plan-phase 26` for Phase 26 Geometry Facade and Landmark Routing Foundation. Completed research-first planning, validation strategy, pattern mapping, four executable plans across four dependent waves, checker-driven revisions, roadmap dependency annotation, state routing, and final planning ledger synchronization. |
| Requirements | GEO-01, GEO-02 |
| Files | `.planning/milestones/v1.5-phases/26-geometry-facade-and-landmark-routing-foundation/26-RESEARCH.md`, `26-VALIDATION.md`, `26-PATTERNS.md`, `26-01-PLAN.md`, `26-02-PLAN.md`, `26-03-PLAN.md`, `26-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 26` reported Phase 26 pending with `has_context: true`, `has_research: false`, `has_plans: false`, `phase_req_ids: GEO-01, GEO-02`, `research_enabled: true`, `plan_checker_enabled: true`, `nyquist_validation_enabled: true`, and `commit_docs: true`. User selected research-first. Researcher created `26-RESEARCH.md` and commit `44f80b1`; validation strategy commit `ca6dd1c`; pattern map commit `1e87eba`; initial plan commit `9f7514a`. First checker pass found 3 blockers and 1 warning; revision commit `a61693f` resolved the research heading, fail-closed scan semantics, active-source raw-leak scan scope, and closeout scan verification. Second checker pass had no blockers and 2 warnings; closeout split commit `48718e0` corrected validation wave rows and split `26-03`/`26-04`. Final plan-checker returned `VERIFICATION PASSED` for 4 plans. `phase-plan-index 26` reports waves 1-4 with dependencies `26-02 -> 26-01`, `26-03 -> 26-01/26-02`, and `26-04 -> 26-03`. `check.decision-coverage-plan` passed with `16/16` decisions covered. Requirement scan confirmed GEO-01 and GEO-02 are covered. `roadmap.annotate-dependencies 26` reported `updated: true`, `waves: 4`, `cross_cutting_constraints: 1`. Post-planning gap analysis showed GEO-01/GEO-02 and D-01 through D-16 covered; uncovered DOC/FACE/GEO-03/GEO-04 rows belong to later v1.5 phases, not Phase 26 scope. Scoped `git diff --check` passed for Phase 26 planning artifacts, `.planning/ROADMAP.md`, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 26 execution plans require focused SDK facade/effects/detection tests, full `swift test --package-path BeautySDK`, active-source raw-leak scans, public/SPI export scans, renderer-case exclusion scans, and ledger overclaim scans. |
| Commit | Planning commits: `44f80b1`, `ca6dd1c`, `1e87eba`, `9f7514a`, `a61693f`, `48718e0`; final state/roadmap/ledger commit records this entry. |

Outcome:

- `26-01-PLAN.md` builds the package-only selected-face geometry adapter and resolver routing foundation for GEO-02.
- `26-02-PLAN.md` wires public still-image facade detection gating and selected-face routing for GEO-01/GEO-02.
- `26-03-PLAN.md` captures verification and validation evidence after implementation.
- `26-04-PLAN.md` synchronizes root docs and planning ledgers only after evidence exists.
- Plans preserve Phase 26 boundaries: no public raw geometry API, no Demo UI work, no saved-output renderer cases, no generated PNG evidence claim, and no `SHAPE_FEATURE_LEDGER.md` `implemented` status promotion.
- Phase 26 is ready for `$gsd-execute-phase 26`.

### C-2026-07-06-gsd-discuss-phase-26-geometry-facade-routing

| Field | Value |
| --- | --- |
| Completed | 2026-07-06 |
| Scope | Ran `$gsd-discuss-phase 26` for Phase 26 Geometry Facade and Landmark Routing Foundation. Captured implementation decisions for geometry-triggered detection, selected-face landmark-to-geometry routing, Phase 26 proof boundaries, and diagnostics/redaction before planning. |
| Requirements | GEO-01, GEO-02 |
| Files | `.planning/milestones/v1.5-phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md`, `.planning/milestones/v1.5-phases/26-geometry-facade-and-landmark-routing-foundation/26-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 26` reported Phase 26 exists with no existing context, research, plans, verification, or phase directory. No `*-SPEC.md`, existing context, or checkpoint was present. `todo.match-phase 26` returned zero matches. Recent prior contexts from Phases 25, 24, and 23 were read; stale `.planning/codebase/*` maps were checked but treated as background because current source/root docs supersede them. User selected all four gray areas, then chose the recommended option for every detailed question and selected finish context. `26-DISCUSS-CHECKPOINT.json` was written incrementally and removed after `26-CONTEXT.md` and `26-DISCUSSION-LOG.md` were created. `state.record-session --stopped-at "Phase 26 context gathered" --resume-file ".planning/milestones/v1.5-phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md"` reported `recorded: true`; `state.update "Status" "Ready for Phase 26 planning"` reported `updated: true`. Scoped `git diff --check` passed for Phase 26 context/log, `.planning/STATE.md`, and this ledger. Placeholder/checkpoint scan over the new Phase 26 artifacts and state returned no matches. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 26 planning should include focused SDK facade tests, existing detector/resolver/provider tests, active-source raw leak scans, and full SDK tests where local tooling allows. |
| Commit | `ebcedf8` captured Phase 26 context/log and ledger; `b339b76` recorded the Phase 26 context session in state. |

Outcome:

- Detection should run only for geometry-triggering still-image parameters; no-op/color/filter/basic-skin paths preserve current `.notRun` or `.disabled` behavior.
- Unusable detection degrades and continues with safe face-agnostic work, redacted summaries, warnings, and numeric metrics.
- Landmark routing starts with one selected face, uses internal `FaceGeometry` only, and preserves group-specific no-face/missing/stale/reused degradation.
- Phase 26 proves geometry intent/routing through focused SDK facade tests and supporting internal tests; saved-output renderer evidence remains Phase 27.
- `BeautyExampleRenderer` cases and `SHAPE_FEATURE_LEDGER.md` implementation statuses remain unchanged until later phases produce saved-output/tool-specific evidence.

### C-2026-07-04-gsd-new-milestone-v1-5

| Field | Value |
| --- | --- |
| Completed | 2026-07-04 |
| Scope | Started v1.5 as an SDK-core milestone for geometry saved-output foundation plus the `脸型` existing-parameter slice from `美型 / 五官`. Preserved the no-UI, local-first, facade-visible evidence, and ledger-update boundaries. |
| Requirements | GEO-01, GEO-02, GEO-03, GEO-04, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `PLANS.md` |
| Verification | User selected the recommended first slice and then selected skip research. `git diff --check` passed for `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md`. Requirement scans confirmed all 13 v1.5 IDs are present and mapped to Phase 26, 27, or 28. `gsd-tools roadmap analyze` recognized 3 phases, 0 completed phases, and `next_phase: 26`. Pending todo scan found no `.planning/todos/pending/*.md` files to tag. |
| Build | Not run; this was a planning/documentation workflow with no Swift source changes. |
| Commit | `63fd133`, `d7f3e70`, `7d7b963`, `2f41d1f`, `f97e63e` plus the final `PLANS.md` completion commit. |

Outcome:

- v1.5 current milestone is recorded in `.planning/PROJECT.md` and `.planning/STATE.md`.
- `.planning/REQUIREMENTS.md` defines 13 requirements across geometry output foundation, `脸型` completion, and documentation/evidence.
- `.planning/ROADMAP.md` defines Phase 26 through Phase 28 and routes the next step to `$gsd-discuss-phase 26`.
- `phases clear --confirm` was intentionally not run because it would delete 21 preserved historical phase directories; v1.5 continues phase numbering instead.

### C-2026-07-04-meitu-shape-feature-ledger

| Field | Value |
| --- | --- |
| Completed | 2026-07-04 |
| Scope | Created a local 1:1 de-duplicated SDK-core ledger for Meitu Xiuxiu editor `美型 / 五官` first-level and second-level functions. Captured the first-principles boundary: no UI work, no Demo rebuild, no remote processing, SDK product-neutral names, and completion only through SDK behavior plus tests/output evidence. |
| Requirements | Documentation contract only; no active milestone requirements file exists after v1.4 archival. |
| Files | `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `docs/meitu-function-blueprint/README.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `docs/meitu-function-blueprint/features/beauty-shaping/README.md`, `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md`, `PLANS.md` |
| Verification | `git diff --check` passed for touched docs. Scans confirmed the ledger contains all 7 first-level groups (`3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`) and all referenced second-level tools from `meituxiuxiu/FUNCTION_MAP.md`. Linkage scans confirmed `README.md`, `FEATURE_MATRIX.md`, beauty-shaping README, and shared implementation principles point to `SHAPE_FEATURE_LEDGER.md` and preserve SDK-core/no-UI boundaries. |
| Build | Not run; documentation-only contract update with no Swift source changes. |
| Commit | Included in the shape feature ledger documentation commit. |

Outcome:

- `SHAPE_FEATURE_LEDGER.md` is now the second-level `美型 / 五官` status authority.
- `FEATURE_MATRIX.md` remains branch-level and points to the new ledger instead of duplicating every second-level tool.
- Completion rules require updating the ledger, branch README, branch-level matrix when applicable, example-image validation evidence, and phase verification artifacts after SDK-core work completes.

### C-2026-07-04-gsd-complete-milestone-v1-4

| Field | Value |
| --- | --- |
| Completed | 2026-07-04 |
| Scope | Ran `$gsd-complete-milestone v1.4` after the v1.4 audit passed and Phase 21/22 validation-document debt was cleaned. Archived the v1.4 roadmap, requirements, and milestone audit; collapsed the active roadmap; updated project/state/milestone/retrospective ledgers; preserved Phase 21-25 directories in place by user choice; and prepared the repository for the next milestone. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04, QA-01, QA-02, QA-03, QA-04, PERF-01, PERF-02, PERF-03, PERF-04, PERF-05, RENDER-01, RENDER-02, RENDER-03, RENDER-04, SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.4-ROADMAP.md`, `.planning/milestones/v1.4-REQUIREMENTS.md`, `.planning/milestones/v1.4-MILESTONE-AUDIT.md`, `.planning/MILESTONES.md`, `.planning/ROADMAP.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/RETROSPECTIVE.md`, `.planning/REQUIREMENTS.md`, `PLANS.md` |
| Verification | `gsd_run query audit-open` reported all artifact types clear. `gsd_run query roadmap.analyze` reported v1.4 has 5/5 completed phases, 15/15 plans, 15/15 summaries, and 100% progress. `.planning/REQUIREMENTS.md` had 24/24 v1.4 requirements checked complete before archival. `.planning/milestones/v1.4-*` archive files were created. Phase-directory archival was skipped by explicit user choice, preserving `.planning/phases/21-*` through `.planning/phases/25-*` paths. |
| Build | Not run; this was milestone archival and documentation closeout using existing Phase 21-25 command-backed evidence. No Swift source or behavior changed during archival. |
| Commit | Included in the v1.4 milestone archival commits. |

Outcome:

- `.planning/milestones/v1.4-ROADMAP.md`, `.planning/milestones/v1.4-REQUIREMENTS.md`, and `.planning/milestones/v1.4-MILESTONE-AUDIT.md` preserve the shipped v1.4 scope and evidence.
- `.planning/ROADMAP.md` now keeps v1.4 as a collapsed shipped milestone and preserves the Backlog section for future planning.
- `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/MILESTONES.md`, and `.planning/RETROSPECTIVE.md` now describe v1.4 as archived and route the operator to `$gsd-new-milestone`.
- `.planning/REQUIREMENTS.md` is removed after archive creation so the next milestone starts from fresh requirements.

### C-2026-07-03-gsd-validate-phase-21-22-cleanup

| Field | Value |
| --- | --- |
| Completed | 2026-07-03 |
| Scope | Ran the `$gsd-validate-phase` cleanup path for Phase 21 and Phase 22 validation-document debt after the v1.4 milestone audit reported `tech_debt`. Closed stale `draft`/`pending` validation rows using existing passed phase verification and blocker-honest evidence; no new source, test, screenshot, or product behavior was added. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04, QA-01, QA-02, QA-03, QA-04 |
| Files | `.planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-VALIDATION.md`, `.planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-VALIDATION.md`, `.planning/v1.4-MILESTONE-AUDIT.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `phase-plan-index 21` and `phase-plan-index 22` reported all plans have summaries and no incomplete plans. Phase 21 evidence scan confirmed `21-VERIFICATION.md` has `status: passed`, AUD-01 through AUD-04, `21-BASELINE-AUDIT.md`, and TD-005/TD-008/TD-009/TD-010 routing evidence. Phase 22 evidence scan confirmed `Demo simulator build: blocked`, `Demo focused view-state test: blocked`, `Screenshot capture status: blocked`, required-state review notes, and route/model disabled-honesty evidence in `VISUAL-EVIDENCE.md`/`22-VERIFICATION.md`. No `.planning/evidence/v1.4/*.png` files exist under the blocker path, and the scoped overclaim scan over `VISUAL-EVIDENCE.md` passed. Final stale-state scan over Phase 21/22 validation docs passed, and scoped `git diff --check` passed for validation/audit/state/plan files. |
| Build | Not run; this was a validation-document cleanup using existing Phase 21/22 command-backed evidence. No new tests or screenshots were generated. |
| Commit | Not committed in this step. |

Outcome:

- `21-VALIDATION.md` is now `status: final`; all Phase 21 task rows are marked `passed`, and a `Validation Audit 2026-07-03` trail explains the cleanup.
- `22-VALIDATION.md` is now `status: final`; task rows are marked `passed` or `passed-blocker-path`, preserving the accepted no-PNG Metal Toolchain blocker path and adding a validation audit trail.
- `.planning/v1.4-MILESTONE-AUDIT.md` now records `status: passed`, with 24/24 requirements, 5/5 phases, 5/5 integration checks, 5/5 flows, and 5/5 Nyquist validation files.
- `.planning/STATE.md` now routes to `$gsd-complete-milestone v1.4`.

### C-2026-07-03-gsd-audit-milestone-v1-4

| Field | Value |
| --- | --- |
| Completed | 2026-07-03 |
| Scope | Ran `$gsd-progress --next`, which passed safety gates, found Phase 25 and all v1.4 phases complete, hit the `$gsd-complete-milestone` pre-flight audit gate, and routed to `$gsd-audit-milestone v1.4`. Completed the milestone audit inline because subagent spawning was not explicitly requested. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04, QA-01, QA-02, QA-03, QA-04, PERF-01, PERF-02, PERF-03, PERF-04, PERF-05, RENDER-01, RENDER-02, RENDER-03, RENDER-04, SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/v1.4-MILESTONE-AUDIT.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `$gsd-progress --next` safety checks passed: no `.planning/.continue-here.md`, no error/failed state, no Phase 25 verification failures, and Phases 21-25 all have matching PLAN/SUMMARY counts. `init.milestone-op` reported `milestone_version: v1.4`, `completed_phases: 5`, and `all_phases_complete: true`. `.planning/REQUIREMENTS.md` reports 24/24 v1.4 requirements complete and 0 unmapped. Summary extraction found all 24 requirement IDs in Phase 21-25 SUMMARY frontmatter. Phase 21-25 VERIFICATION files all report `status: passed`. `audit-open` reported all artifact types clear. Nyquist scan found validation files for all five phases; Phases 23-25 are final/compliant, while Phases 21-22 remain draft/pending validation artifacts despite passed verification, so audit status is `tech_debt`. |
| Build | Not run; this was a planning/audit workflow with no source changes. It reused existing command-backed Phase 21-25 evidence. |
| Commit | Not committed in this step. |

Outcome:

- v1.4 milestone requirements are satisfied: 24/24 requirements, 5/5 phases, 5/5 integration checks, and 5/5 flows passed audit review.
- The audit is intentionally `tech_debt`, not `passed`, because `21-VALIDATION.md` and `22-VALIDATION.md` still contain draft/pending task rows even though their phase verification files passed.
- Remaining accepted limitations are documented: no current v1.4 screenshot PNG pass, no physical iPhone parity, no 600-second preview endurance, no geometry saved-output completion, no external package capability, no commercial packaging approval, and no unsupported release-readiness claim.
- Next step is either `$gsd-complete-milestone v1.4` to archive while accepting the audit's tech-debt status, or `$gsd-validate-phase 21` plus `$gsd-validate-phase 22` to clean validation artifacts before archival.

### C-2026-07-03-gsd-execute-phase-25-security-distribution-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-03 |
| Scope | Ran `$gsd-execute-phase 25` for Phase 25 Security, Distribution Review, and Closeout. Completed all three plans across two waves: privacy manifest assessment and active security scans, bundled-resource trust review, final security/quality/planning ledger synchronization, blocker/deferred tables, requirement traceability, and conservative closeout wording. |
| Requirements | SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 |
| Files | `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift`, `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`, `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift`, `.planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md`, `25-RESOURCE-TRUST-EVIDENCE.md`, `25-VALIDATION.md`, `25-REVIEW.md`, `25-VERIFICATION.md`, `25-01-SUMMARY.md`, `25-02-SUMMARY.md`, `25-03-SUMMARY.md`, `SECURITY.md`, `QUALITY_SCORE.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` found no manifests; required-reason seed scans found no active SDK facade or Demo app seed hits beyond the classified example-renderer local `FileManager.default` use; active no-network/no-upload/raw-path/raw-error/geometry/raw-diagnostic scans passed; third-party/product-scope scans passed after replacing unsupported Demo `VIP` copy with `v1`; `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests` passed with 4 tests; `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` passed with 6 tests; `swift test --package-path BeautySDK --filter BeautySDKTests.BeautySDKFacadeTests` passed with 5 tests; `swift test --package-path BeautySDK` passed with 150 tests; focused Demo privacy/import `xcodebuild` passed with 17 tests on `platform=iOS Simulator,name=iPhone 17,OS=26.5`; Phase 25 requirement, decision-coverage, claim-control, traceability, and scoped `git diff --check` gates passed; `25-REVIEW.md` is clean; schema drift reported `drift_detected: false`; codebase drift reported a warning-only stale-map refresh suggestion already covered by deferred map work. |
| Build | SDK SwiftPM tests passed. Focused Demo privacy/import simulator tests passed. No `PrivacyInfo.xcprivacy` was added because current SDK/Demo behavior supports explicit deferral; `plutil` remains a rerun step if a manifest becomes required. |
| Commit | Task commits include `4fa6832`, `9c81f9a`, `ce11b66`, `3bf162e`, `bb5171f`, `b9d455b`, and `3eab830`; final closeout commit records Plan 25-03 summary, PLANS/project/roadmap/state synchronization, and verification status. |

Outcome:

- SEC-01 is complete: privacy manifest status is documented, `PrivacyInfo.xcprivacy` is explicitly deferred for current source behavior, and rerun triggers are recorded.
- SEC-02 is complete: active SDK/Demo surfaces pass no-network, no-upload, no raw path/error, no face-geometry payload, no raw JSON, and no image-byte leakage checks.
- SEC-03 is complete: current bundled resources are covered by manifest/preset/filter/identifier/missing-resource tests and scans, while external resource packages remain disabled.
- SEC-04 is complete: no hidden third-party SDK, analytics, remote config, cloud, dynamic download, payment, VIP, or entitlement behavior remains in active scanned sources after the narrow Demo copy fix.
- DOC-01 through DOC-03 are complete: `SECURITY.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` agree on Phase 25 evidence and next-step routing.
- TD-005 is closed for current v1.4 evidence through explicit manifest deferral. TD-010 keeps screenshot, physical iPhone, 600-second preview, optimized profiling, external package-integrity, and commercial packaging checks as future or blocked/not-run evidence.
- Phase 25 adds no product-feature breadth, public API expansion, network/cloud behavior, analytics, payment/entitlement flow, external resource package implementation, screenshot pass evidence, hardware evidence, or commercial packaging claim.
- Next step is `$gsd-progress --next` for v1.4 milestone audit or archival routing.

### C-2026-07-03-gsd-plan-phase-25-security-distribution-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-03 |
| Scope | Ran `$gsd-plan-phase 25` for Phase 25 Security, Distribution Review, and Closeout. Completed research-first planning, created validation and pattern-map artifacts, generated three executable plans across two waves, resolved plan-checker blockers, passed independent plan-checker verification, and marked Phase 25 ready for execution. |
| Requirements | SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout/25-RESEARCH.md`, `25-VALIDATION.md`, `25-PATTERNS.md`, `25-01-PLAN.md`, `25-02-PLAN.md`, `25-03-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 25` reported `phase_status: Pending`, `has_context: true`, `has_research: false`, `has_plans: false`, `phase_req_ids: SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03`, `commit_docs: true`, and `nyquist_validation_enabled: true`; `request_user_input` was unavailable in Default mode, so the workflow used text-mode fallback and the user selected research-first. Researcher created `25-RESEARCH.md` and committed `7f46edb`; `25-VALIDATION.md` was created and scoped `git diff --check` plus placeholder scans passed before commit `2a69a66`; UI gate did not apply (`HAS_UI_EXIT=1`); schema scan found no database schema files; pattern mapper created `25-PATTERNS.md` and committed `8fab92f`; planner created three PLAN files and updated roadmap in `12ea890`; first checker pass found one research-resolution blocker, resolved in `d0a0f84`; second checker pass found two verification-gate blockers, resolved in `1544ef3`; third checker pass returned `VERIFICATION PASSED`; `phase-plan-index 25` reported three plans across waves 1 and 2 with `25-03` depending on `25-01` and `25-02`; `check.decision-coverage-plan .planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout .planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout/25-CONTEXT.md` passed with `16/16` decisions covered; phase-scoped requirement scans confirmed SEC-01 through SEC-04 and DOC-01 through DOC-03 are present in plans; `state.planned-phase --phase 25 --name security-distribution-review-and-closeout --plans 3` updated state timestamp, then `.planning/STATE.md` was narrowly corrected to point to `$gsd-execute-phase 25`; `roadmap.annotate-dependencies 25` reported `updated: false`, `waves: 2`; post-planning gap analysis showed Phase 25 SEC/DOC requirements and D-01 through D-16 covered, with uncovered rows belonging to earlier v1.4 phase requirements outside Phase 25 scope. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 25 execution plans require full `swift test --package-path BeautySDK`, focused resource/security tests, active-source scans, manifest lint if a manifest is added, and focused Demo privacy/import `xcodebuild` pass or exact blocker protocol. |
| Commit | `7f46edb` research; `2a69a66` validation strategy; `8fab92f` pattern map; `12ea890` initial three PLAN files and roadmap; `d0a0f84` research-resolution revision; `1544ef3` plan verification-gate revision; final scoped closeout commit records `.planning/STATE.md` and this ledger entry. |

Outcome:

- `25-01-PLAN.md` covers privacy manifest assessment, active no-network/no-upload/raw-leak/third-party scans, required-reason classification, and conditional smallest manifest disposition for SEC-01, SEC-02, and SEC-04.
- `25-02-PLAN.md` covers current bundled-resource trust evidence, focused resource tests, resource-source scans, and external resource boundary preservation for SEC-03.
- `25-03-PLAN.md` covers final `SECURITY.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` synchronization for DOC-01 through DOC-03.
- Checker-driven revisions fixed unresolved research questions, invalid negative `rg` pass/fail semantics, and the skipped decision-coverage helper by adding a deterministic D-01 through D-16 coverage loop over `25-CONTEXT.md`, plans, and evidence.
- Phase 25 remains evidence-first and conservative: no product-feature breadth, no public API expansion, no hidden network/cloud behavior, no external resource-package prototype, no broad historical-doc rewrite, and no unsupported readiness claims.
- Phase 25 is ready for `$gsd-execute-phase 25`.

### C-2026-07-03-gsd-discuss-phase-25-security-distribution-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-03 |
| Scope | Ran `$gsd-progress --next`, which passed safety gates and routed to `$gsd-discuss-phase 25` for Phase 25 Security, Distribution Review, and Closeout. Captured user decisions for privacy manifest disposition, active-surface security scan boundaries, resource trust review, and final closeout traceability before planning. |
| Requirements | SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout/25-CONTEXT.md`, `.planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout/25-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `$gsd-progress --next` state checks passed: no `.planning/.continue-here.md`, no `status: error` or `status: failed`, no Phase 25 verification failures, no prior Phase 21-24 plans without summaries, no prior unresolved verification failures, and no context-without-plan prior phases. `request_user_input` was unavailable in Default mode, so the discussion used text-mode numbered questions. User selected all four gray areas and then selected ready-for-context. Scoped `git diff --check` passed for the Phase 25 context/log artifacts. `state.record-session --stopped-at "Phase 25 context gathered" --resume-file ".planning/milestones/v1.4-phases/25-security-distribution-review-and-closeout/25-CONTEXT.md"` reported `recorded: true`; `state.update "Status" "Ready for Phase 25 planning"` reported `updated: true`; `state.update "Operator Next Steps" "Run $gsd-plan-phase 25"` reported `updated: false` because that section is not a supported field, so the correct next command is recorded here and in final output. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 25 planning should include privacy manifest assessment, active-surface security scans, resource trust tests/scans, full available SDK tests, relevant focused tests, Demo commands where local tooling allows, and blocker-honest rerun protocols for unavailable checks. |
| Commit | `a7e92df` captured Phase 25 context/log; `a24c980` recorded the Phase 25 context session; `bced4ce` marked Phase 25 ready for planning; final ledger commit records this `PLANS.md` update. |

Outcome:

- Phase 25 privacy manifest work is evidence-driven: assess actual SDK/Demo behavior, data collection/persistence/upload, required-reason API usage, and distribution risk before adding or deferring `PrivacyInfo.xcprivacy`.
- Active SDK/Demo security leaks are hard failures; test guard literals, fixtures, and docs examples must be classified rather than blindly rewritten.
- Resource trust review covers current bundled presets, metadata filters, identifiers, traversal-like IDs, unknown filter/preset behavior, and missing-resource typed errors while keeping external resource packages future-only.
- Phase 25 completion requires traceability across `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md`, with unrun checks recorded as blockers/deferred items rather than pass evidence.
- Next step is `$gsd-plan-phase 25`.

### C-2026-07-02-gsd-execute-phase-24-renderer-output-regression-hardening

| Field | Value |
| --- | --- |
| Completed | 2026-07-02 |
| Scope | Ran `$gsd-execute-phase 24` for Phase 24 Renderer Output Regression Hardening. Completed all three plans across two waves: focused renderer matrix/no-op fixture regression tests, generated-output invariant helper and evidence, durable example-image validation docs, final geometry/no-overclaim verification, and root/planning ledger synchronization. |
| Requirements | RENDER-01, RENDER-02, RENDER-03, RENDER-04 |
| Files | `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `.planning/milestones/v1.4-phases/24-renderer-output-regression-hardening/check_renderer_outputs.py`, `24-RENDERER-EVIDENCE.md`, `24-VALIDATION.md`, `24-VERIFICATION.md`, `24-01-SUMMARY.md`, `24-02-SUMMARY.md`, `24-03-SUMMARY.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 2 tests; `swift test --package-path BeautySDK` passed with 150 tests; `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` regenerated 45 PNG outputs under ignored `example-images/out/`; `python3 .planning/milestones/v1.4-phases/24-renderer-output-regression-hardening/check_renderer_outputs.py --input example-images/input --output example-images/out` passed for 45/45 outputs; representative `git check-ignore` passed; public-facade import scan, renderer geometry-case exclusion scan, geometry status scan, no-overclaim scan, decision-coverage check, ledger coverage scans, and scoped `git diff --check` passed. |
| Build | SDK SwiftPM tests passed. `BeautyExampleRenderer` built and regenerated the current 5-fixture by 9-case skin/color/filter output matrix. Generated PNGs remain ignored local artifacts and are not committed baselines. |
| Commit | Task commits include `459dc05`, `7b748f8`, `7d6be4c`, `2d485cb`, and `cee2025`; plan-summary and ledger commits record the final closeout. |

Outcome:

- RENDER-01 is complete through a focused test that locks the current 9-case `BeautyExampleRenderer` matrix and public `BeautySDK` facade import boundary.
- RENDER-02 is complete through exact pre-watermark rendered-pixel equality checks for `e1.png` through `e5.png` with default `BeautyParameters`; no tolerance fallback was needed.
- RENDER-03 is complete through renderer build/run evidence, the 45-output invariant helper, ignored-output policy checks, and factual representative watermark notes.
- RENDER-04 is complete through status-guard evidence: geometry saved-output remains future work, and `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛` keep their existing guarded statuses.
- Phase 24 adds no product-feature breadth, public parameters, Demo UI, service-transfer behavior, committed PNG baselines, reference-app parity evidence, broad device evidence, or market visual-quality evidence.
- Next step is `$gsd-discuss-phase 25`.

### C-2026-07-02-gsd-plan-phase-24-renderer-output-regression-hardening

| Field | Value |
| --- | --- |
| Completed | 2026-07-02 |
| Scope | Ran `$gsd-plan-phase 24` for Phase 24 Renderer Output Regression Hardening. Completed research-first planning, created validation and pattern-map artifacts, generated three executable plans across two waves, resolved the checker research-resolution blocker, passed independent plan-checker verification, and marked Phase 24 ready for execution. |
| Requirements | RENDER-01, RENDER-02, RENDER-03, RENDER-04 |
| Files | `.planning/milestones/v1.4-phases/24-renderer-output-regression-hardening/24-RESEARCH.md`, `24-VALIDATION.md`, `24-PATTERNS.md`, `24-01-PLAN.md`, `24-02-PLAN.md`, `24-03-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 24` reported `phase_status: Pending`, `has_context: true`, `has_research: false`, `has_plans: false`, `phase_req_ids: RENDER-01, RENDER-02, RENDER-03, RENDER-04`, `commit_docs: true`, and `nyquist_validation_enabled: true`; `request_user_input` was unavailable in Default mode, so the workflow used text-mode fallback and the user selected research-first; researcher created `24-RESEARCH.md` and committed `5e9944b`; `24-VALIDATION.md` was created from the validation template and scoped `git diff --check` passed before commit `2a5be82`; UI helper was unavailable locally, so the UI gate was classified manually as skipped because Phase 24 is SDK renderer/CLI evidence with no SwiftUI/frontend scope; schema scan found no database patterns; pattern mapper created `24-PATTERNS.md` and scoped `git diff --check` passed before commit `390b412`; planner created three PLAN files and updated roadmap in commit `004d1f1`; first checker pass found one blocker because `24-RESEARCH.md` still had an unresolved Open Questions section; research was revised to `## Open Questions (RESOLVED)` with an execution-time exact-equality/tolerance decision and committed as `d12a706`; second checker pass returned `VERIFICATION PASSED`; `phase-plan-index 24` reported three plans across waves 1 and 2 with `24-03` depending on `24-01` and `24-02`; requirement coverage showed RENDER-01 through RENDER-04 covered; `check.decision-coverage-plan` passed with `16/16` decisions covered; `state.planned-phase --phase 24 --name renderer-output-regression-hardening --plans 3` updated state metadata; `roadmap.annotate-dependencies 24` reported `updated: false`, `waves: 2`; post-planning gap analysis showed RENDER-01 through RENDER-04 and D-01 through D-16 covered, with uncovered rows belonging to other v1.4 phases; scoped `git diff --check` passed. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 24 execution plans require `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`, full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, all-case renderer run, generated PNG invariant checks, facade-only import scans, geometry status scans, and no-overclaim scans. |
| Commit | `5e9944b` research; `2a5be82` validation strategy; `390b412` pattern map; `004d1f1` three PLAN files and roadmap; `d12a706` research-resolution revision; final scoped closeout commit records `.planning/STATE.md` and this ledger entry. |

Outcome:

- `24-01-PLAN.md` covers focused SwiftPM renderer case-inventory and pre-watermark no-op fixture regression tests for the current 9 renderer cases and all five current fixtures.
- `24-02-PLAN.md` covers renderer build/run evidence, a generated-output invariant helper, 45-output evidence, representative factual watermark notes, and `EXAMPLE_IMAGE_VALIDATION.md` synchronization.
- `24-03-PLAN.md` covers geometry status honesty, no-overclaim scans, validation status closeout, and root/planning ledger synchronization after Wave 1 evidence exists.
- Plans preserve the Phase 24 boundaries: no product-feature breadth, no public parameter expansion, no Demo UI, no OCR, no committed PNG baselines, no commercial/Meitu/device-parity claims, and no geometry saved-output implementation.
- Phase 24 is ready for `$gsd-execute-phase 24`.

### C-2026-07-02-gsd-discuss-phase-24-renderer-output-regression

| Field | Value |
| --- | --- |
| Completed | 2026-07-02 |
| Scope | Ran `$gsd-discuss-phase 24` for Phase 24 Renderer Output Regression Hardening. Captured user decisions for the code-owned renderer matrix, no-op fixture tolerance, visible-output regression checks, and geometry status guards before Phase 24 planning. |
| Requirements | RENDER-01, RENDER-02, RENDER-03, RENDER-04 |
| Files | `.planning/milestones/v1.4-phases/24-renderer-output-regression-hardening/24-CONTEXT.md`, `.planning/milestones/v1.4-phases/24-renderer-output-regression-hardening/24-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 24` reported `phase_found: true`, expected phase dir `.planning/milestones/v1.4-phases/24-renderer-output-regression-hardening`, no existing context/research/plans/verification, and `plan_count: 0`; no `*-SPEC.md`, existing context, or checkpoint was found; `todo.match-phase 24` reported zero matches; `request_user_input` was unavailable in Default mode, so the workflow used text-mode fallback; user selected all four gray areas and then selected context creation; `24-DISCUSS-CHECKPOINT.json` was created incrementally and removed after context/log creation; `state.record-session --stopped-at "Phase 24 context gathered" --resume-file ".planning/milestones/v1.4-phases/24-renderer-output-regression-hardening/24-CONTEXT.md"` reported `recorded: true`; `state.update "Status" "Ready for planning"` reported `updated: true`; placeholder scan over `24-CONTEXT.md`, `24-DISCUSSION-LOG.md`, and `.planning/STATE.md` returned no matches; `wc -l` reported 143 lines for `24-CONTEXT.md` and 219 lines for `24-DISCUSSION-LOG.md`; scoped `git diff --check` passed. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 24 planning should include `swift build --package-path BeautySDK --product BeautyExampleRenderer`, renderer all-case run, no-op fixture regression, generated-output invariant checks, facade-only import scans, and geometry overclaim scans. |
| Commit | Final scoped closeout commit records the Phase 24 context/log, state session update, and this ledger entry. |

Outcome:

- Phase 24 renderer matrix is code-owned: the current `BeautyExampleRenderer` case list is canonical, with a focused static inventory check and durable documentation in `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`.
- No-op regression should test facade output before watermarking, use exact rendered-pixel equality where deterministic, cover all five current example fixtures, and hard-fail deterministic drift unless a documented platform color-management tolerance is needed.
- Visible-output evidence should automatically verify the current 45 PNG outputs for existence, non-empty content, same dimensions, and a change signal; generated PNGs remain ignored and evidence is recorded in Markdown.
- Watermark readability is a factual representative inspection, not OCR; visible-change wording must avoid commercial quality, naturalness, release-readiness, all-device parity, and Meitu parity claims.
- Geometry-heavy branches are guarded only: current `partial`, `blocked-by-geometry-output`, and `future` statuses remain unless public facade detection plus geometry rendering produces same-dimension, watermarked `BeautyExampleRenderer` outputs.
- Next step is `$gsd-plan-phase 24`.

### C-2026-07-02-gsd-execute-phase-23-performance-reliability

| Field | Value |
| --- | --- |
| Completed | 2026-07-02 |
| Scope | Ran `$gsd-execute-phase 23` for Phase 23 Performance and Reliability Gates. Completed all five plans across three waves: SDK timing/memory/redaction evidence, Demo backpressure/reset/recovery regressions, SDK quality/degradation/cap regressions, final evidence and validation ledgers, and root/planning ledger synchronization. |
| Requirements | PERF-01, PERF-02, PERF-03, PERF-04, PERF-05 |
| Files | `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`, `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`, `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift`, `.planning/milestones/v1.4-phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md`, `23-VALIDATION.md`, `23-REVIEW.md`, `23-VERIFICATION.md`, `23-01-SUMMARY.md`, `23-02-SUMMARY.md`, `23-03-SUMMARY.md`, `23-04-SUMMARY.md`, `23-05-SUMMARY.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` passed with 3 tests; final `swift test --package-path BeautySDK` passed with 148 tests; focused SDK quality/degradation filters passed; final focused Demo camera xcodebuild passed with 7 camera tests on `platform=iOS Simulator,name=iPhone 17,OS=26.5`; required evidence scans, redaction scans, no-overclaim scans, validation status scans, schema drift, code review, verification, and scoped `git diff --check` commands passed for Phase 23 artifacts and ledgers. |
| Build | SDK SwiftPM tests passed. Focused Demo camera xcodebuild passed in the current environment. Current 720p timings remain over-budget baseline evidence, the memory sampler is unavailable for the short fixture loop, and physical iPhone plus 600-second preview evidence remains blocked or not run. |
| Commit | Task commits include `b4fa168`, `385d4fa`, `d3c9690`, `25e72e9`, `87e3d93`, `20ca19e`, `73b15f2`, `f0e7c20`, and Phase 23 plan-summary/ledger commits through this closeout entry. |

Outcome:

- PERF-01 is complete through repeatable `1280x720` SDK timing evidence and `RELIABILITY.md` budget comparison.
- PERF-02 is complete through Demo camera backpressure/latest-frame-wins tests and focused xcodebuild pass evidence.
- PERF-03 is complete through SDK quality-mode, reset, degradation, safety-cap, Demo reset, and still-image recovery regressions.
- PERF-04 is complete through the allowed evidence/blocker path: short SDK fixture-loop evidence, 600-second rerun protocol, focused Demo pass evidence, and explicit physical iPhone/long-run blockers.
- PERF-05 is complete through allowlisted evidence fields, optional/off-by-default logging, redaction tests, and artifact scans.
- TD-008 remains partially blocked for physical iPhone evidence; TD-010 is partially reduced by Phase 23 performance evidence but still routes renderer, screenshot, long-run, and device work to later phases.
- Phase 23 verification passed in `23-VERIFICATION.md`; next step is `$gsd-discuss-phase 24`.

### C-2026-07-02-gsd-plan-phase-23-performance-reliability

| Field | Value |
| --- | --- |
| Completed | 2026-07-02 |
| Scope | Ran `$gsd-plan-phase 23` for Phase 23 Performance and Reliability Gates. Completed research-first planning, created validation and pattern-map artifacts, generated five executable plans across three waves, passed independent plan-checker verification, and marked Phase 23 ready for execution. |
| Requirements | PERF-01, PERF-02, PERF-03, PERF-04, PERF-05 |
| Files | `.planning/milestones/v1.4-phases/23-performance-and-reliability-gates/23-RESEARCH.md`, `23-VALIDATION.md`, `23-PATTERNS.md`, `23-01-PLAN.md`, `23-02-PLAN.md`, `23-03-PLAN.md`, `23-04-PLAN.md`, `23-05-PLAN.md`, `.planning/ROADMAP.md`, `PLANS.md` |
| Verification | `init.plan-phase 23` reported `phase_status: Pending`, `has_context: true`, `has_research: false`, `has_plans: false`, `phase_req_ids: PERF-01, PERF-02, PERF-03, PERF-04, PERF-05`, `commit_docs: true`, and `nyquist_validation_enabled: true`; `request_user_input` was unavailable in Default mode, so the workflow used text-mode fallback and the user selected research-first; researcher created `23-RESEARCH.md` with `## Validation Architecture` and committed `82f3d73`; `23-VALIDATION.md` was created from the validation template and `git diff --check` passed; pattern mapper created `23-PATTERNS.md` and `git diff --check` passed; planner created five PLAN files and committed `60fbf53`; plan-checker returned `VERIFICATION PASSED`; `phase-plan-index 23` reported five plans across waves 1, 2, and 3 with `23-04` depending on `23-01`/`23-02`/`23-03` and `23-05` depending on `23-04`; multiline frontmatter scan showed PERF-01 through PERF-05 covered; `check.decision-coverage-plan` passed with `16/16` decisions covered; post-planning gap analysis showed PERF-01 through PERF-05 and D-01 through D-16 covered, with uncovered rows belonging to other v1.4 phases; `roadmap.annotate-dependencies 23` returned `updated: true` but produced a malformed `5 plansPlans:` line, so Phase 23 wave notes were corrected manually and scoped `git diff --check` passed. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 23 execution plans require `swift test --package-path BeautySDK`, focused SwiftPM filters, blocker-honest Demo `xcodebuild` commands, and scoped redaction/no-overclaim scans. |
| Commit | `82f3d73` research; `d21beee` validation strategy; `18a0349` pattern map; `60fbf53` five PLAN files; `4a4ff3e` roadmap wave annotation; final scoped closeout commit records this ledger entry. |

Outcome:

- `23-01-PLAN.md` covers SDK 720p synthetic `CVPixelBuffer` timing, short fixture-loop memory baseline, initial redacted performance evidence, and PERF-01/PERF-04/PERF-05.
- `23-02-PLAN.md` covers Demo backpressure/latest-frame-wins stress, Demo reset, still-image recovery, and blocker-honest focused `xcodebuild` evidence.
- `23-03-PLAN.md` covers SDK quality-mode contract, engine reset, degradation, safety-cap, and redaction regressions without public API/UI expansion.
- `23-04-PLAN.md` consolidates timing, memory, backpressure, reset, degradation, blocker, redaction, and non-claim evidence into `23-PERFORMANCE-EVIDENCE.md`.
- `23-05-PLAN.md` synchronizes Phase 23 evidence into requirements, roadmap, state, quality-score, and planning ledgers after evidence exists.
- Phase 23 remains evidence-first: over-budget results must be classified honestly, logs stay optional/off by default, and readiness/device-parity/commercial visual-quality claims remain forbidden without actual evidence.
- Next step is `$gsd-execute-phase 23`.

### C-2026-07-01-gsd-discuss-phase-23-performance-reliability

| Field | Value |
| --- | --- |
| Completed | 2026-07-01 |
| Scope | Ran `$gsd-discuss-phase 23` for Phase 23 Performance and Reliability Gates. Captured user decisions for SDK 720p timing evidence, automated long-run fixture evidence, quality/reset/degradation scope, and structured redacted performance artifacts before Phase 23 planning. |
| Requirements | PERF-01, PERF-02, PERF-03, PERF-04, PERF-05 |
| Files | `.planning/milestones/v1.4-phases/23-performance-and-reliability-gates/23-CONTEXT.md`, `.planning/milestones/v1.4-phases/23-performance-and-reliability-gates/23-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 23` reported `phase_found: true`, expected phase dir `.planning/milestones/v1.4-phases/23-performance-and-reliability-gates`, no existing context/research/plans/verification, and `plan_count: 0`; `todo.match-phase 23` reported zero matches; user selected all four gray areas in text mode; `23-DISCUSS-CHECKPOINT.json` was created incrementally and removed after context/log creation; `state.record-session --stopped-at "Phase 23 context gathered" --resume-file ".planning/milestones/v1.4-phases/23-performance-and-reliability-gates/23-CONTEXT.md"` reported `recorded: true`; `state.update "Status" "Ready for planning"` reported `updated: true`; `state.update "Operator Next Steps"` reported `updated: false` because that section is not a supported field, so the correct next command is recorded here and in final output; placeholder scan over `23-CONTEXT.md`, `23-DISCUSSION-LOG.md`, and `.planning/STATE.md` returned no matches; `wc -l` reported 144 lines for `23-CONTEXT.md` and 110 lines for `23-DISCUSSION-LOG.md`; scoped `git diff --check` passed. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 23 planning should include `swift test --package-path BeautySDK` and any new timing/long-run helper commands it introduces. |
| Commit | Final scoped closeout commit records the Phase 23 context/log, state session update, and this ledger entry. |

Outcome:

- Phase 23 timing should use an SDK 720p synthetic `CVPixelBuffer` loop through `BeautyEngine`, with representative no-op, skin/color/filter, and high-but-capped cases.
- Timing evidence is record-and-compare against `RELIABILITY.md` budgets, not a hard first-pass optimization gate.
- Long-run evidence should start with an automated fixture loop and trend-based memory baseline; Demo simulator and physical iPhone checks are secondary evidence or blocker records.
- Quality-mode work may add only minimal internal/test behavior if needed; no public API, Demo UI, product route, or broad strategy expansion is allowed.
- Reset/degradation evidence should cover SDK engine and Demo pipelines while preserving caps, warnings, metrics, no-face, stale/reused, missing-landmark, and recovery behavior.
- Performance evidence must be structured and redacted, logs stay optional/off by default, and Phase 23 must not claim shipped frame-rate readiness, commercial visual quality, real-device parity, or multi-device frame-rate readiness without actual evidence.
- Next step is `$gsd-plan-phase 23`.

### C-2026-07-01-gsd-execute-phase-22-demo-qa-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-01 |
| Scope | Ran `$gsd-execute-phase 22` for Phase 22 Automated Demo QA and Screenshot Evidence. Executed both planned waves, reproduced the current Demo Metal Toolchain blocker, recorded blocker-honest visual evidence under `.planning/evidence/v1.4/`, preserved route/model disabled-honesty evidence, and verified QA-01 through QA-04 without claiming current screenshot pass evidence. |
| Requirements | QA-01, QA-02, QA-03, QA-04 |
| Files | `.planning/evidence/v1.4/VISUAL-EVIDENCE.md`, `.planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-01-SUMMARY.md`, `22-02-SUMMARY.md`, `22-VERIFICATION.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` exited 65 while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` because the local Metal Toolchain is missing; focused `BeautyDemoViewStateTests` exited 65 for the same prerequisite; static route/model scans found the existing editor launch routes, disabled Home routes, unsupported editor `controlID: nil` and unavailable copy, and future category tests; no `.planning/evidence/v1.4/*.png` files exist; final overclaim scan passed; `swift test --package-path BeautySDK` passed with 141 tests; code review gate skipped because no source files changed after planning artifacts were filtered; `verify.schema-drift 22` reported `drift_detected: false`; codebase drift emitted a non-blocking stale-map warning; `22-VERIFICATION.md` reports `status: passed` and score `4/4 must-haves verified`; scoped `git diff --check` passed. |
| Build | SDK SwiftPM tests passed. Demo simulator build/test remains blocked by missing local Metal Toolchain and is documented with exact command, environment, failure summary, impact, next step, and rerun protocol. |
| Commit | `020a923`, `eac5430`, `ca8df13`, and `db2fb22` completed Plan 22-01; `7fdcc13`, `7fb3fc5`, `f32dad1`, and `353bfaf` completed Plan 22-02; final closeout commits record verification and ledger updates. |

Outcome:

- QA-01 through QA-04 are complete through the Phase 22 blocker-honest evidence path allowed by `22-CONTEXT.md`.
- `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` is the current v1.4 Demo QA evidence ledger and explicitly states no current screenshot PNGs were captured.
- Required Home first screen, Home sticky state, and editor tool-panel review notes are present in blocked form with exact rerun commands and UI-SPEC focal points.
- Unsupported/future Meitu-style routes remain inactive by source scans and existing test coverage, while focused XCTest remains blocked by the Metal Toolchain prerequisite.
- Next step is `$gsd-discuss-phase 23`.

### C-2026-07-01-gsd-plan-phase-22-demo-qa-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-01 |
| Scope | Ran `$gsd-plan-phase 22` for Phase 22 Automated Demo QA and Screenshot Evidence. Reused existing context, research, validation, and approved UI-SPEC; created a pattern map; generated two executable plans across two waves; fixed one checker blocker in verification predicates; and marked Phase 22 ready for execution. |
| Requirements | QA-01, QA-02, QA-03, QA-04 |
| Files | `.planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-PATTERNS.md`, `22-01-PLAN.md`, `22-02-PLAN.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `PLANS.md` |
| Verification | `init.plan-phase 22` reported `phase_status: Pending`, `has_context: true`, `has_research: true`, `has_plans: false`, `phase_req_ids: QA-01, QA-02, QA-03, QA-04`, `commit_docs: true`, and `text_mode: false`; pattern mapper created `22-PATTERNS.md` and `git diff --check -- 22-PATTERNS.md` passed; planner created `22-01-PLAN.md` and `22-02-PLAN.md`; first plan-checker pass found one blocker because Plan 22-02 branched on generic `Metal Toolchain` text; revision changed the plans to explicit `Demo simulator build: passed|blocked`, `Demo focused view-state test: passed|blocked`, and `Screenshot capture status: passed|blocked` markers; second plan-checker pass reported `VERIFICATION PASSED`; `phase-plan-index 22` reported two plans across two waves with `22-02` depending on `22-01`; `check.decision-coverage-plan` passed with `19/19` decisions covered; post-planning gap analysis showed QA-01 through QA-04 and D-01 through D-19 covered, with uncovered items belonging to other v1.4 phases; `roadmap.annotate-dependencies 22` detected two waves and required no automatic edit; scoped `git diff --check` passed. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 22 execution plans require exact Demo build/test/screenshot commands or reproducible Metal Toolchain blocker records. |
| Commit | `c7c1457` created the initial two PLAN files; this final scoped closeout commit records the pattern map, checker-driven plan revision, state/roadmap updates, and this ledger entry. |

Outcome:

- `22-01-PLAN.md` covers Demo build/test prerequisite evidence, exact Metal Toolchain blocker/pass handling, and route/model disabled-honesty checks.
- `22-02-PLAN.md` covers current v1.4 simulator screenshot capture or blocker-preserving rerun protocol for Home first screen, Home sticky state, and editor beauty/photo tool panel.
- Both plans preserve blocker honesty: screenshots are created only after build/install/launch/screenshot commands pass; blocked execution must not create or claim current screenshot pass evidence.
- Phase 22 remains scoped to QA evidence and explicitly forbids broad UI automation, screenshot-diff baselines, product-route expansion, new public parameters, real-device parity pass claims, and commercial visual-quality/effect-quality claims.
- Next step is `$gsd-execute-phase 22`.

### C-2026-07-01-gsd-ui-phase-22-demo-qa-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-01 |
| Scope | Ran `$gsd-ui-phase 22` for Phase 22 Automated Demo QA and Screenshot Evidence. Created the native SwiftUI UI design contract for Home first screen, Home sticky state, and editor beauty/photo tool-panel screenshot evidence; locked visual hierarchy, spacing, typography, color, copywriting, registry-safety, route-scope, and blocker-honesty expectations before executable planning. |
| Requirements | QA-01, QA-02, QA-03, QA-04 |
| Files | `.planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-UI-SPEC.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 22` reported `phase_found: true`, `has_context: true`, `has_research: true`, `has_plans: false`, `commit_docs: true`, and `text_mode: false`; `workflow.ui_phase` and `workflow.ui_safety_gate` were both `true`; no pre-existing `22-UI-SPEC.md` was found; gsd-ui-researcher created the UI-SPEC and `git diff --check` passed for that artifact; first gsd-ui-checker pass approved with one non-blocking Visuals recommendation; the UI-SPEC was refined with explicit focal points for Home first screen, Home sticky state, and editor tool panel; second gsd-ui-checker pass reported PASS for all six dimensions with no recommendations; `state.record-session --stopped-at "Phase 22 UI-SPEC approved" --resume-file ".planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-UI-SPEC.md"` reported `recorded: true`; final `git diff --check -- .planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-UI-SPEC.md .planning/STATE.md PLANS.md` passed. |
| Build | Not run; this was a GSD UI design-contract documentation workflow with no Swift source changes. Demo simulator build/test remains governed by the existing local Metal Toolchain blocker and must be handled during Phase 22 planning/execution. |
| Commit | `657de6f` created the initial UI-SPEC; final scoped commit records approved metadata, focal-point refinement, state update, and this ledger entry. |

Outcome:

- Phase 22 now has an approved `22-UI-SPEC.md` for native SwiftUI Demo QA and screenshot evidence planning.
- Required visual evidence states are Home first screen, Home sticky state, and editor beauty/photo tool panel.
- The UI contract explicitly forbids redesign, product-route expansion, new public parameters, web/shadcn registries, and unsupported claims.
- Next step is `$gsd-plan-phase 22`.

### C-2026-06-30-gsd-discuss-phase-22-demo-qa-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-discuss-phase 22` for Phase 22 Automated Demo QA and Screenshot Evidence. Captured user decisions for the current Demo screenshot capture path, target simulator matrix, evidence acceptance bar, and blocker/honesty policy before Phase 22 planning. |
| Requirements | QA-01, QA-02, QA-03, QA-04 |
| Files | `.planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-CONTEXT.md`, `.planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 22` reported `phase_found: true`, `phase_dir: .planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence`, `has_context: true`, `has_plans: false`, and `plan_count: 0`; `todo.match-phase 22` reported zero matches; `request_user_input` was unavailable, so the workflow used text-mode numbered questions and the user selected all four gray areas; the temporary `22-DISCUSS-CHECKPOINT.json` was removed after context/log creation; placeholder scan over `22-CONTEXT.md`, `22-DISCUSSION-LOG.md`, and `.planning/STATE.md` returned no matches; `git diff --check` passed for the new context/log and state update; `state.record-session --stopped-at "Phase 22 context gathered" --resume-file ".planning/milestones/v1.4-phases/22-automated-demo-qa-and-screenshot-evidence/22-CONTEXT.md"` reported `recorded: true`. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 22 planning is expected to include explicit Demo build/test commands when local Metal Toolchain availability allows and exact blocker records otherwise. |
| Commit | `7a52cf9` captured Phase 22 context/log; `7a2ec64` recorded the state session; final ledger commit records this `PLANS.md` update. |

Outcome:

- Phase 22 planning should use current launch arguments plus `simctl` screenshots as the primary evidence path.
- Required evidence states are Home first screen, Home sticky state, and the editor beauty/photo tool panel.
- Required simulator destination is `platform=iOS Simulator,name=iPhone 17,OS=26.5`; one extra phone smoke check is optional if cheap after baseline passes.
- Each required screenshot needs exact commands, file path, framing, and factual review notes for clipping, overlap, disabled honesty, and route scope.
- If the Metal Toolchain remains missing, Phase 22 must reproduce and document the blocker and rerun protocol rather than claiming current screenshot pass evidence.
- Archived v1.1/v1.2 screenshots are background comparison only, not current v1.4 pass evidence.
- Next step is `$gsd-plan-phase 22`.

### C-2026-06-30-gsd-execute-phase-21-baseline-audit

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-execute-phase 21` for Phase 21 Baseline Audit and Quality Ledger Refresh. Captured current SDK, renderer, Demo, import/privacy, privacy-manifest, root-doc, and planning-ledger baseline evidence; refreshed `QUALITY_SCORE.md`; routed TD-005, TD-008, TD-009, and TD-010; added TD-011 for stale codebase maps; and closed AUD-01 through AUD-04 without source changes. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04 |
| Files | `.planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`, `21-REVIEW.md`, `21-VERIFICATION.md`, `21-01-SUMMARY.md`, `21-02-SUMMARY.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md` |
| Verification | `swift test --package-path BeautySDK` passed with 141 XCTest cases; `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 45 ignored PNG outputs; output checks found no zero-byte PNGs and representative same-dimension outputs; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` and `xcrun simctl list devices available` succeeded; explicit Demo build on `platform=iOS Simulator,name=iPhone 17,OS=26.5` is blocked by missing local Metal Toolchain while compiling `Warp.metal`, so Demo tests were not rerun; Demo internal import, SDK non-UI import, active Demo local-first, sensitive raw/geometry, public parameter inventory, renderer geometry-case exclusion, privacy manifest inventory, and root placeholder scans were run or classified in `21-BASELINE-AUDIT.md`; source review scope returned no `BeautySDK` or `BeautyDemo` changes and `21-REVIEW.md` records `status: clean`; `verify.schema-drift 21` reported `drift_detected: false`; active `.planning` scope scan returned no product/API/UI expansion matches; `git diff --check` passed for Phase 21 ledgers. |
| Build | SwiftPM SDK tests and `BeautyExampleRenderer` build/run passed. Demo simulator build/test remains blocked by missing local Metal Toolchain and is routed to Phase 22. |
| Commit | `5f3ba69`, `221a8b4`, `0edfc21`, and `4e7fd87` completed Plan 21-01; `c1af498` refreshed `QUALITY_SCORE.md`; `a53a001` routed the baseline debt ledgers; final closeout commits record `21-VERIFICATION.md`, `21-02-SUMMARY.md`, and this ledger entry. |

Outcome:

- AUD-01 through AUD-04 are complete.
- Current SDK and renderer evidence passes; Demo simulator build/test pass is not claimed.
- TD-005 is routed to Phase 25.
- TD-008 is split between Phase 22/23 with physical iPhone evidence blocked until hardware exists.
- TD-009 is routed to Phase 22.
- TD-010 is split across Phases 22, 23, 24, and 25.
- TD-011 records stale `.planning/codebase/*` maps as deferred background.
- Next step is `$gsd-discuss-phase 22`.

### C-2026-06-30-gsd-plan-phase-21-baseline-audit

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-plan-phase 21` for Phase 21 Baseline Audit and Quality Ledger Refresh after the required research gate selected research-first. Created research, validation, pattern map, and two executable plans across two waves for evidence capture, debt routing, quality-score refresh, and planning-ledger closeout. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04 |
| Files | `.planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-RESEARCH.md`, `21-VALIDATION.md`, `21-PATTERNS.md`, `21-01-PLAN.md`, `21-02-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | User selected research-first in text-mode fallback because `request_user_input` was unavailable; `swift --version` reported Apple Swift 6.3.3; `xcodebuild -version` reported Xcode 26.6; `swift test --package-path BeautySDK --list-tests` succeeded and listed 141 XCTest entries; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` listed `BeautyDemo`, `BeautyDemoTests`, and schemes while reporting CoreSimulator current `1051.54.0` older than required `1051.55.0`; `xcrun simctl list devices available` listed iOS 26.5 devices after a stale-service warning; renderer inventory found 5 input fixtures and 45 existing local PNG outputs; `git diff --check -- .planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh` passed; structural plan scan found required frontmatter, `<objective>`, artifacts, `<tasks>`, `<read_first>`, `<action>`, `<acceptance_criteria>`, `<threat_model>`, `<verification>`, and `<success_criteria>` in both plans; requirement scan found AUD-01, AUD-02, AUD-03, and AUD-04 covered; `check.decision-coverage-plan .planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh .planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md` passed with 18/18 decisions covered; `phase-plan-index 21` reported two plans across two waves; `state.planned-phase --phase 21 --name baseline-audit-and-quality-ledger-refresh --plans 2` updated state; `roadmap.annotate-dependencies 21` detected two waves and required no automatic roadmap edit, so the Phase 21 roadmap plan list was updated manually. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Research verified SwiftPM test inventory only; execution Plan 21-01 requires the full baseline sweep and exact pass/fail/blocker records. |
| Commit | Final planning commit records the Phase 21 plan artifacts, roadmap/state updates, and this ledger entry. |

Outcome:

- Phase 21 now has `21-01-PLAN.md` for the baseline command sweep and `21-BASELINE-AUDIT.md` evidence ledger.
- Phase 21 now has `21-02-PLAN.md` for `QUALITY_SCORE.md`, `PLANS.md`, `.planning` ledger synchronization, TD-005/TD-008/TD-009/TD-010 routing, and closeout verification.
- `21-RESEARCH.md` records local toolchain discovery, including the CoreSimulator version mismatch that execution must classify if still present.
- `21-VALIDATION.md` sets the audit validation strategy and manual-only blocker protocol for physical iPhone and visual naturalness checks.
- All 18 Phase 21 context decisions are covered by the plans.
- Next step is `$gsd-execute-phase 21`.

### C-2026-06-30-gsd-discuss-phase-21-baseline-audit

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-discuss-phase 21` for Phase 21 Baseline Audit and Quality Ledger Refresh. Captured user decisions for full baseline evidence, debt triage routing, stale codebase map handling, and reproducible hardware/tooling blocker rules before Phase 21 planning. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04 |
| Files | `.planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md`, `.planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init phase-op 21` reported `phase_found: true`, no existing context, no plans, no verification, and expected phase directory `.planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh`; `todo.match-phase 21` reported zero matches; no Phase 21 SPEC, context, or checkpoint existed; user selected all four gray areas in text mode; `git diff --check` passed for the new Phase 21 context/log; placeholder scan over `21-CONTEXT.md` and `21-DISCUSSION-LOG.md` returned no matches; `state record-session --stopped-at "Phase 21 context gathered" --resume-file ".planning/milestones/v1.4-phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md"` reported `recorded: true`. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. |
| Commit | `7fbde95` captured Phase 21 context/log; `0e9c087` recorded the state session; final ledger commit records this `PLANS.md` update. |

Outcome:

- Phase 21 planning must run the full available baseline sweep and record exact pass/fail/blocker evidence.
- TD-005, TD-008, TD-009, and TD-010 are to be triaged/routed, not fixed early in Phase 21.
- `.planning/codebase/*` maps are stale and should be flagged/deferred rather than refreshed in Phase 21.
- Hardware/tooling blockers must be reproducible with exact command, environment, failure summary, impact, and next step.
- Next step is `$gsd-plan-phase 21`.

### C-2026-06-30-gsd-new-milestone-v1-4

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-new-milestone` for v1.4 after user selected research-first and then confirmed the proposed hardening scope. Started v1.4 as a stability, QA, and technical-debt cleanup milestone, wrote the current research package, updated project/state context, created requirements and roadmap artifacts, and kept phase numbering continuing from Phase 21 while preserving existing `.planning/phases/` history directories. |
| Requirements | AUD-01, AUD-02, AUD-03, AUD-04, QA-01, QA-02, QA-03, QA-04, PERF-01, PERF-02, PERF-03, PERF-04, PERF-05, RENDER-01, RENDER-02, RENDER-03, RENDER-04, SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/research/STACK.md`, `.planning/research/FEATURES.md`, `.planning/research/ARCHITECTURE.md`, `.planning/research/PITFALLS.md`, `.planning/research/SUMMARY.md`, `PLANS.md` |
| Verification | `state.milestone-switch --milestone "v1.4" --name "Stability, QA, and Debt Cleanup"` returned `switched: true` and `status: planning`; `roadmap analyze` parsed 5 v1.4 phases with `next_phase: "21"`; custom REQ-ID check reported 24 requirements, 24 trace rows, 24 phase-mapped IDs, and no missing or extra mappings; placeholder scan over `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/research/` returned no matches; `git diff --check` passed for scoped v1.4 planning files and `PLANS.md`. |
| Build | Not run; this was a GSD planning/research/documentation workflow with no Swift source changes. |
| Commit | Final scoped milestone-start commit records these artifacts. |

Outcome:

- v1.4 is now the active milestone: `Stability, QA, and Debt Cleanup`.
- `.planning/REQUIREMENTS.md` defines 24 hardening requirements with full traceability.
- `.planning/ROADMAP.md` defines Phase 21 through Phase 25.
- `.planning/STATE.md` points to Phase 21 as the next step.
- Existing `.planning/phases/` history directories were intentionally left in place.
- Next step is `$gsd-discuss-phase 21`.

### C-2026-06-30-gsd-complete-milestone-v1-3

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-complete-milestone v1.3` from `$gsd-progress --next` after the v1.3 audit passed. Archived the v1.3 roadmap, requirements, and milestone audit, updated milestone/state/project summaries, collapsed the live roadmap to the next-milestone handoff, and intentionally kept Phase 16-20 directories in `.planning/phases/` after user selected `Skip` for phase-directory archival. |
| Requirements | PREP-01, PREP-02, PREP-03, PREP-04, CBT-01, CBT-02, CBT-03, MOD-01, SKIN-01, SKIN-02, SKIN-03, BSHAPE-01, BSHAPE-02, BSHAPE-03, EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, MOD-04 |
| Files | `.planning/milestones/v1.3-ROADMAP.md`, `.planning/milestones/v1.3-REQUIREMENTS.md`, `.planning/milestones/v1.3-MILESTONE-AUDIT.md`, `.planning/MILESTONES.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/PROJECT.md`, `.planning/RETROSPECTIVE.md`, `.planning/REQUIREMENTS.md` (removed), `PLANS.md` |
| Verification | `milestone.complete v1.3 --name "Meitu Core Beauty Module Design and Implementation"` returned `archived.roadmap: true`, `archived.requirements: true`, `archived.audit: true`, `phases: 5`, `plans: 14`, and `tasks: 35`; phase directories were not moved because the user selected `Skip`; live `ROADMAP.md` now has no active phases and routes to `$gsd-new-milestone`; `PROJECT.md` records v1.3 as the shipped version and references the v1.3 archives; `MILESTONES.md` includes the v1.3 shipped summary and verification evidence; `.planning/REQUIREMENTS.md` was removed after the archive commit; `.planning/RETROSPECTIVE.md` now records v1.3 lessons and cross-milestone trend updates. |
| Build | Not run; this was a planning archival workflow. The archived audit and Phase 20 verification preserve the full SDK test and renderer evidence. |
| Commit | `2e78e77` archived v1.3 milestone files; `89ea209` removed the live requirements file; final scoped retrospective/ledger commit records the retrospective update. |

Outcome:

- v1.3 is archived under `.planning/milestones/`.
- `.planning/ROADMAP.md` is ready for the next milestone cycle.
- `.planning/phases/16-*` through `.planning/phases/20-*` remain in place as raw execution history.
- Next step is `$gsd-new-milestone`.

### C-2026-06-30-gsd-audit-milestone-v1-3

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran the milestone-audit preflight required by `$gsd-progress --next` before v1.3 archival. Audited Phase 16 through Phase 20 summaries, verification files, requirement traceability, integration boundaries, Nyquist validation metadata, and accepted limitations. |
| Requirements | PREP-01, PREP-02, PREP-03, PREP-04, CBT-01, CBT-02, CBT-03, MOD-01, SKIN-01, SKIN-02, SKIN-03, BSHAPE-01, BSHAPE-02, BSHAPE-03, EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, MOD-04 |
| Files | `.planning/milestones/v1.3-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | `roadmap.analyze` reported 5 completed phases, 14 plans, 14 summaries, and 100% progress; `phase-plan-index` reported no incomplete plans for phases 16-20; all 20 v1.3 requirements were checked complete in `.planning/REQUIREMENTS.md`, present in summary frontmatter, and covered by passed phase verification files; inline integration checks found no Demo/renderer internal SDK imports, no SwiftUI/UIKit imports in non-UI SDK targets, no renderer geometry cases, zero source/image diffs under `BeautyDemo`, `BeautySDK`, and `example-images`, and the expected 31 public `BeautyParameters` fields; validation files exist for phases 16-20 with Phase 18's `wave_0_complete: false` recorded as a non-blocking note because the created test and execution gates passed; `git diff --check -- .planning/v1.3-MILESTONE-AUDIT.md` passed before the complete-milestone workflow moved the audit into `.planning/milestones/`. |
| Build | Not run; this was an audit/documentation workflow over existing phase evidence. Phase 20 already records the passing full `swift test --package-path BeautySDK` and renderer matrix evidence. |
| Commit | Not created in this step; next archival command is `$gsd-complete-milestone v1.3`. |

Outcome:

- `.planning/milestones/v1.3-MILESTONE-AUDIT.md` records `status: passed`.
- No unsatisfied or orphaned v1.3 requirements were found.
- Geometry-heavy saved-image output and release-hardening QA remain accepted future-scope limitations, not v1.3 blockers.
- Next step is `$gsd-complete-milestone v1.3`.

### C-2026-06-30-gsd-execute-phase-20-core-module-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-execute-phase 20` for Phase 20 Core Module Closeout. Completed editor-shell/current-authority contract closeout, SDK/renderer evidence, scope scans, planning-ledger closeout, and v1.3 milestone completion without adding UI, public parameters, renderer cases, or geometry saved-image output. |
| Requirements | EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, MOD-04 |
| Files | `.planning/milestones/v1.3-phases/20-core-module-closeout/20-VERIFICATION.md`, `20-REVIEW.md`, `20-01-SUMMARY.md`, `20-02-SUMMARY.md`, docs under `docs/meitu-function-blueprint/features/editor-shell/`, `docs/meitu-function-blueprint/MODULES.md`, `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/PROJECT.md`, `PLANS.md` |
| Verification | Plan 20-01 doc scans confirmed editor-shell input routing, preview chrome, bottom panel, commit flow, Demo-owned state semantics, and no `BeautyDemo` source diff; `swift test --package-path BeautySDK` passed with 141 tests and 0 failures; `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 45 ignored PNG outputs across the current nine cases; representative outputs were ignored by git, non-empty, same-dimension, and visually inspected for readable bottom watermarks and factual visible changes; exact public `BeautyParameters` inventory remained the existing 31 fields; `BeautyExampleRenderer` geometry-case negative scan passed; Demo internal import scan returned no matches; SDK non-UI SwiftUI/UIKit scan returned no matches; `git diff --name-only -- BeautyDemo` returned no output; shaping overclaim scan returned no matches; scoped emitted sensitive-string scan passed; `20-REVIEW.md` records `status: clean`; `roadmap.analyze`, `phase-plan-index 20`, and `verify.schema-drift 20` passed; `git diff --check` passed for changed Phase 20 docs and ledgers. |
| Build | Full SwiftPM SDK test suite and `BeautyExampleRenderer` build/run passed. Broad Demo simulator verification was not run because Phase 20 made no Demo source changes and the Phase 20 context kept broad simulator verification non-required; earlier planning also recorded local CoreSimulator mismatch. |
| Commit | `02b0d5b`, `b2fb010`, and `fa041c9` completed Plan 20-01; `c7c59bf` and `c67ed1d` recorded Plan 20-02 SDK/renderer/output/scope evidence; final closeout commit records ledgers, `20-02-SUMMARY.md`, and verification status. |

Outcome:

- `EDITOR-01`, `EDITOR-02`, `EDITOR-03`, `MOD-02`, `MOD-03`, and `MOD-04` are complete.
- v1.3 is complete as a no-new-UI core module design/implementation milestone.
- Current authority docs record editor-shell support as Demo-owned app-side behavior using the public `BeautySDK` facade.
- `BeautyExampleRenderer` evidence covers current skin/color/filter saved-image cases only.
- Geometry-heavy saved-image output remains deferred; shaping branches remain partial or `blocked-by-geometry-output` until public facade detection plus geometry rendering produces same-dimension, watermarked saved outputs.
- Release-hardening QA, hardware camera/Vision parity, commercial visual-quality evaluation, performance budgets, long-run reliability, automated visual diffing, and multi-device sweeps remain future scope.

### C-2026-06-30-gsd-plan-phase-20-core-module-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-plan-phase 20` for Phase 20 Core Module Closeout. Created research, validation, pattern map, and two executable plans across two waves for editor-shell contract/root wording closeout, full SDK/renderer evidence, negative scans, and planning-ledger completion. |
| Requirements | EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, MOD-04 |
| Files | `.planning/milestones/v1.3-phases/20-core-module-closeout/20-RESEARCH.md`, `20-VALIDATION.md`, `20-PATTERNS.md`, `20-01-PLAN.md`, `20-02-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 20` reported `phase_status: Planned`, `has_research: true`, `has_context: true`, `has_plans: true`, `plan_count: 2`, and `patterns_path: .planning/milestones/v1.3-phases/20-core-module-closeout/20-PATTERNS.md`; user selected research-first after `request_user_input` was unavailable and the workflow fell back to text-mode; `swift --version` reported Apple Swift 6.3.3 and `xcodebuild -version` reported Xcode 26.6; `swift test --package-path BeautySDK --list-tests` completed and listed the current SDK test inventory; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` resolved targets/schemes but reported local CoreSimulator out-of-date, so Phase 20 plans keep broad simulator verification non-required per D-06; renderer case scan found the required nine current cases in `BeautyExampleRenderer/main.swift`; `git diff --check -- .planning/milestones/v1.3-phases/20-core-module-closeout` passed; placeholder scan returned no matches; structural plan scan found required frontmatter, `<objective>`, artifacts, `<threat_model>`, `<tasks>`, `<read_first>`, `<action>`, and `<acceptance_criteria>` in both plans; local requirement coverage found EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, and MOD-04 covered; `check.decision-coverage-plan .planning/milestones/v1.3-phases/20-core-module-closeout .planning/milestones/v1.3-phases/20-core-module-closeout/20-CONTEXT.md` passed with 18/18 decisions covered; `state.planned-phase --phase 20 --name core-module-closeout --plans 2` updated state; `roadmap.annotate-dependencies 20` added two waves; post-planning gap analysis reported Phase 20 requirements and D-01 through D-18 covered while older completed v1.3 requirement IDs were not covered by Phase 20 plans, which is expected non-blocking scope noise. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Research verified the SDK test inventory with `swift test --package-path BeautySDK --list-tests`; execution Plan 20-02 requires full `swift test --package-path BeautySDK`, renderer build/run, output checks, negative scans, and ledger checks. |
| Commit | Final planning commit records the Phase 20 plan artifacts, roadmap/state updates, and this ledger entry. |

Outcome:

- Phase 20 now has `20-01-PLAN.md` for editor-shell blueprint, delivery-boundary, and minimal root contract acceptance wording. It explicitly forbids new SwiftUI screens, Demo routes, tool-panel behavior, app-state behavior, public parameters, renderer cases, and historical-doc normalization.
- Phase 20 now has `20-02-PLAN.md` for full SDK tests, all nine current `BeautyExampleRenderer` cases, output dimension/watermark/factual visual notes, no-new-UI/API/import/renderer/redaction scans, requirement traceability, roadmap/state consistency, and final ledger closeout.
- `20-RESEARCH.md` records the local CoreSimulator mismatch from `xcodebuild -list`; broad simulator verification remains non-required unless execution changes app behavior.
- All 18 Phase 20 context decisions are covered by the plans.
- Next step is `$gsd-execute-phase 20`.

### C-2026-06-30-gsd-discuss-phase-20-core-module-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-06-30 |
| Scope | Ran `$gsd-discuss-phase 20` for Phase 20 Core Module Closeout. Captured user decisions for editor-shell closeout strictness, visible evidence thresholds, and ledger/root-contract sync depth before Phase 20 planning. |
| Requirements | EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, MOD-04 |
| Files | `.planning/milestones/v1.3-phases/20-core-module-closeout/20-CONTEXT.md`, `.planning/milestones/v1.3-phases/20-core-module-closeout/20-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 20` reported `phase_found: true`, `phase_dir: null`, `expected_phase_dir: .planning/milestones/v1.3-phases/20-core-module-closeout`, `has_context: false`, `has_plans: false`, and `plan_count: 0`; no Phase 20 `.continue-here.md`, `*-SPEC.md`, existing context, existing checkpoint, existing plans, or matching TODOs were found; user selected all three gray areas and chose the recommended closeout decisions in text-mode fallback after `request_user_input` was unavailable; `git diff --check` passed for `20-CONTEXT.md` and `20-DISCUSSION-LOG.md`; the interim `20-DISCUSS-CHECKPOINT.json` was removed after context/log creation; `state.record-session --stopped-at "Phase 20 context gathered" --resume-file ".planning/milestones/v1.3-phases/20-core-module-closeout/20-CONTEXT.md"` reported `recorded: true`. |
| Build | Not run; this was a GSD context/documentation workflow with no Swift source changes. Phase 20 planning is expected to include full SDK tests, current renderer matrix, editor evidence scans/tests where practical, and ledger checks. |
| Commit | `17decb1` captured Phase 20 context/log; `2b17c5e` recorded the state session; final ledger commit records this `PLANS.md` update. |

Outcome:

- Phase 20 planning should tighten editor-shell blueprint docs and reconcile `FRONTEND.md` / `PRODUCT_SENSE.md` only where closeout needs explicit acceptance or evidence wording.
- Editor-shell support is existing app-side behavior to document and verify; Phase 20 must not add SwiftUI screens, Demo interaction rewrites, public parameters, renderer cases, or SDK ownership creep.
- Visible closeout requires `swift test --package-path BeautySDK`, all current `BeautyExampleRenderer` cases, dimension/watermark checks, and factual visual observations without production-quality claims.
- Shaping branches remain `partial` or `blocked-by-geometry-output`; provider/resolver evidence is not saved-image visual completion.
- Closeout should update current authority docs and planning ledgers, preserve explicit limitation/deferred tables, and avoid normalizing historical docs unless stale wording misroutes current agents.
- Next step is `$gsd-plan-phase 20`.

### C-2026-06-29-gsd-execute-phase-19-beauty-shaping-core-modules

| Field | Value |
| --- | --- |
| Completed | 2026-06-29 |
| Scope | Ran `$gsd-execute-phase 19` for Phase 19 Beauty Shaping Core Modules. Added shaping audit evidence, hardened provider/resolver/degradation/redaction XCTest coverage for existing SDK fields, updated blueprint/example-image docs with honest geometry-output status, ran final negative scans, and closed BSHAPE traceability. |
| Requirements | BSHAPE-01, BSHAPE-02, BSHAPE-03 |
| Files | `.planning/milestones/v1.3-phases/19-beauty-shaping-core-modules/19-SHAPING-AUDIT.md`, `19-01-SUMMARY.md`, `19-02-SUMMARY.md`, `19-03-SUMMARY.md`, `19-04-SUMMARY.md`, `19-05-SUMMARY.md`, `19-REVIEW.md`, `19-VERIFICATION.md`, `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift`, `GeometryConflictResolverTests.swift`, `EyeWarpProviderTests.swift`, `NoseWarpProviderTests.swift`, `MouthWarpProviderTests.swift`, `LipColorEffectTests.swift`, `MissingLandmarkDegradationTests.swift`, `BeautyEffectResolverTests.swift`, `docs/meitu-function-blueprint/features/beauty-shaping/README.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `docs/meitu-function-blueprint/MODULES.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | Focused shaping suites passed: `FaceShapeWarpProviderTests` 7/0, `EyeWarpProviderTests` 6/0, `NoseWarpProviderTests` 6/0, `MouthWarpProviderTests` 6/0, `GeometryConflictResolverTests` 6/0, `MissingLandmarkDegradationTests` 11/0, and `BeautyEffectResolverTests` 7/0; `swift test --package-path BeautySDK --filter BeautyEffectsTests` passed with 65 tests and 0 failures; final `swift test --package-path BeautySDK` passed with 141 tests and 0 failures; exact public `BeautyParameters` field inventory passed for the pre-existing 31 fields; `git diff --quiet -- BeautyDemo` passed; `BeautyExampleRenderer/main.swift` negative scans found no shaping/lip renderer parameters or geometry case IDs; branch status overclaim scan passed; scoped emitted warning/metric string scan passed; `phase-plan-index 19` reported all five summaries present and no incomplete plans; `verify.schema-drift 19` reported `drift_detected: false`; `19-REVIEW.md` records `status: clean`; `19-VERIFICATION.md` records `status: passed`; `phase.complete 19` reported `plans_executed: 5/5`, `requirements_updated: true`, `roadmap_updated: true`, and `state_updated: true`. |
| Build | Full SwiftPM test suite passed with `swift test --package-path BeautySDK` (141 tests, 0 failures). |
| Commit | `c706ba4` audited shaping branch evidence; `1f8bad5`, `9fcd805`, `3a91ff8`, and `39722d2` hardened XCTest evidence; `86ff51f` and `3007290` recorded verification/docs; `2682f9f` recorded final negative scans; `188a4ca` added the clean review report; final closeout commit records ledgers and plan summary. |

Outcome:

- `BSHAPE-01`, `BSHAPE-02`, and `BSHAPE-03` are complete.
- `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` remain `partial`; `3D塑颜` remains `blocked-by-geometry-output`; `眉毛` remains `future`.
- Phase 19 added no public `BeautyParameters` fields, SwiftUI/Demo changes, renderer geometry cases, public facade geometry saved-image output, 3D sculpt implementation, or eyebrow implementation.
- Public facade saved-image geometry output remains deferred until face detection plus geometry render integration exists.
- Next step is `$gsd-discuss-phase 20`.

### C-2026-06-29-gsd-plan-phase-19-beauty-shaping-core-modules

| Field | Value |
| --- | --- |
| Completed | 2026-06-29 |
| Scope | Ran `$gsd-plan-phase 19` for Phase 19 Beauty Shaping Core Modules. Created research, validation, pattern map, and five executable plans across four waves for shaping audit, split provider/test hardening, honest status verification, final negative scans, and ledger closeout. |
| Requirements | BSHAPE-01, BSHAPE-02, BSHAPE-03 |
| Files | `.planning/milestones/v1.3-phases/19-beauty-shaping-core-modules/19-RESEARCH.md`, `19-VALIDATION.md`, `19-PATTERNS.md`, `19-01-PLAN.md`, `19-02-PLAN.md`, `19-03-PLAN.md`, `19-04-PLAN.md`, `19-05-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 19` reported `phase_status: Planned`, `has_research: true`, `has_context: true`, `has_plans: true`, and `plan_count: 5`; research-first gate selected by user; validation file exists, `git diff --check` passed, and no template placeholders remained; pattern mapper classified 19 files and found analogs for 19/19; plan-checker passed structure, requirements, dependencies, threat models, task fields, and context constraints, then user accepted the remaining checker caveat that Plans 19-03/19-05 should scope redaction checks to emitted warning/metric strings instead of all implementation identifiers and that Plans 19-02/19-03/19-04 should name analog patterns more explicitly; requirement scan found BSHAPE-01, BSHAPE-02, and BSHAPE-03 covered across plan frontmatter; `check.decision-coverage-plan .planning/milestones/v1.3-phases/19-beauty-shaping-core-modules .planning/milestones/v1.3-phases/19-beauty-shaping-core-modules/19-CONTEXT.md` passed with 20/20 decisions covered; `state.planned-phase --phase 19 --name beauty-shaping-core-modules --plans 5` ran; `roadmap.annotate-dependencies 19` reported 4 waves and no new update needed; post-planning gap analysis reported BSHAPE-01 through BSHAPE-03 and D-01 through D-20 covered while unrelated milestone requirements remained outside Phase 19. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Researcher ran `swift test --package-path BeautySDK --list-tests` successfully as research environment evidence. |
| Commit | `a711743` researched Phase 19; `b7f28ed` added validation strategy; `96b9707` created the initial plans; `0fef0de` split/revised plans after checker blockers; `14a35b7` fixed plan checker gates. |

Outcome:

- Phase 19 now has five executable plans: `19-01` audit, `19-02` face/eye/nose/conflict hardening, `19-03` mouth/lip/resolver/degradation hardening, `19-04` test/status verification, and `19-05` final negative scans plus ledger closeout.
- The plans preserve the locked scope: SDK-only/no UI, no new public `BeautyParameters`, no public facade geometry saved-image output, no geometry renderer cases, `3D塑颜` remains `blocked-by-geometry-output`, and `眉毛` remains `future`.
- The accepted planning caveat is explicit for execution: redaction verification should inspect emitted warning/metric strings or add XCTest assertions instead of failing on legitimate implementation identifiers such as `controlPoint`; task actions should lean on the concrete analogs in `19-PATTERNS.md`.
- Next step is `$gsd-execute-phase 19`.

### C-2026-06-29-gsd-discuss-phase-19-beauty-shaping-core-modules

| Field | Value |
| --- | --- |
| Completed | 2026-06-29 |
| Scope | Ran `$gsd-discuss-phase 19` for Phase 19 Beauty Shaping Core Modules. Captured user decisions that Phase 19 is SDK-only/no-UI, does not add public `BeautyParameters`, does not attempt public facade geometry saved-image output, keeps existing shaping branches partial where appropriate, leaves `3D塑颜` blocked by geometry output, leaves `眉毛` future, and verifies with BeautySDK tests plus status/API/UI/renderer/redaction scans. |
| Requirements | BSHAPE-01, BSHAPE-02, BSHAPE-03 |
| Files | `.planning/milestones/v1.3-phases/19-beauty-shaping-core-modules/19-CONTEXT.md`, `.planning/milestones/v1.3-phases/19-beauty-shaping-core-modules/19-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 19` reported `phase_found: true`, `phase_dir: null`, `expected_phase_dir: .planning/milestones/v1.3-phases/19-beauty-shaping-core-modules`, `has_context: false`, `has_plans: false`, and `plan_count: 0`; `swift test --package-path BeautySDK --list-tests` succeeded after approved SwiftPM cache access and listed current SDK tests; `swift test --package-path BeautySDK` passed with 129 tests and 0 failures; `state.record-session --stopped-at "Phase 19 context gathered" --resume-file ".planning/milestones/v1.3-phases/19-beauty-shaping-core-modules/19-CONTEXT.md"` reported `recorded: true`; the discussion checkpoint was removed after context/log creation. |
| Build | SwiftPM `BeautySDK` test build passed as part of `swift test --package-path BeautySDK`. |

Outcome:

- Phase 19 planning must stay within `BeautySDK` core module logic, SDK tests, and blueprint/planning docs.
- Face-shape, eyes, nose, mouth/lip, and proportion branches stay `partial` unless a later phase wires public facade geometry saved-image output.
- `3D塑颜` remains `blocked-by-geometry-output`; `眉毛` remains `future`.
- No new public shaping parameters, no UI/SwiftUI work, and no geometry renderer cases are allowed in Phase 19 plans.
- Next step is `$gsd-plan-phase 19`.

### C-2026-06-27-gsd-execute-phase-18-skin-retouch-core-modules

| Field | Value |
| --- | --- |
| Completed | 2026-06-27 |
| Scope | Ran `$gsd-execute-phase 18` for Phase 18 Skin Retouch Core Modules. Audited branch contracts, improved conservative Basic skin formula behavior inside the existing color pipeline, added focused tests, protected redacted resolver/facade metadata, generated all current Basic skin renderer outputs, and closed SKIN traceability. |
| Requirements | SKIN-01, SKIN-02, SKIN-03 |
| Files | `docs/meitu-function-blueprint/features/skin-retouch/skin-basic/README.md`, `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`, `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift`, `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift`, `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift`, `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`, `.planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-01-SUMMARY.md`, `18-02-SUMMARY.md`, `18-03-SUMMARY.md`, `18-REVIEW.md`, `18-VERIFICATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `SkinBasicEffectTests` passed with 6 tests; `BeautyEffectResolverTests` passed with 6 tests; `BeautyEngineTests` passed with 11 tests; `BeautyExampleRenderer` built; renderer runs for `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50` each wrote `e1` through `e5` ignored PNG outputs; `file` confirmed `example-images/input/e2.png` and all five representative `e2__skin*.png` outputs are 576 x 1024; `git check-ignore` confirmed representative outputs are ignored; `stat` confirmed representative outputs are non-empty; thumbnail inspection recorded readable bottom labels below the face and visible restrained changes; future parameter, renderer case, implementation/resource, network/upload/AI, internal import, and completion-overclaim scans passed; `18-REVIEW.md` records `status: clean`; `phase.complete 18` reported `plans_executed: 3/3`, `requirements_updated: true`, `roadmap_updated: true`, and `state_updated: true`. |
| Build | SwiftPM focused tests, renderer build, and five renderer runs passed. Full `swift test --package-path BeautySDK` was not run because Phase 18 fixed the required gate as focused tests plus renderer evidence and negative scans. |
| Commit | `8214bf5` tightened the branch contract; `e206af9` completed Plan 18-01 tracking; `c4c8a02` added Basic skin formula regressions; `6545f81` improved Basic skin smoothing behavior; `4d5d36c` protected resolver metadata; `b5080f2` completed Plan 18-02 tracking; final closeout commit records verification, review, and ledgers. |

Outcome:

- `SKIN-01`, `SKIN-02`, and `SKIN-03` are complete.
- Basic skin remains the only promoted Phase 18 skin-retouch branch, using existing public parameters: `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`.
- Public no-detection facade paths keep Basic skin visible, while explicit internal no-face resolver contexts can skip face-dependent skin with redacted metadata.
- Skin repair and Teeth/hairline remain future branches with no new public parameters, renderer cases, resources, segmentation, network/upload/AI dependency, or completion claim.
- Generated PNGs remain ignored local artifacts under `example-images/out/`.
- Next step is `$gsd-discuss-phase 19`.

### C-2026-06-27-gsd-plan-phase-18-skin-retouch-core-modules

| Field | Value |
| --- | --- |
| Completed | 2026-06-27 |
| Scope | Ran `$gsd-plan-phase 18` for Phase 18 Skin Retouch Core Modules. Created research, validation, pattern-map, and three executable plans for branch audit, conservative Basic skin implementation/tests, and renderer/ledger verification. |
| Requirements | SKIN-01, SKIN-02, SKIN-03 |
| Files | `.planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-RESEARCH.md`, `18-VALIDATION.md`, `18-PATTERNS.md`, `18-01-PLAN.md`, `18-02-PLAN.md`, `18-03-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 18` reported `has_research: true`, `has_context: true`, `has_plans: true`, `plan_count: 3`, and `phase_status: Planned`; plan-checker initially found two blockers, then passed after `18-RESEARCH.md` open questions were resolved and `18-03-PLAN.md` grouped generated PNG outputs; local requirement scan reported `SKIN-01=covered`, `SKIN-02=covered`, and `SKIN-03=covered`; `check.decision-coverage-plan .planning/milestones/v1.3-phases/18-skin-retouch-core-modules .planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-CONTEXT.md` passed with 17/17 decisions covered; `state.planned-phase --phase 18 --name skin-retouch-core-modules --plans 3` ran; `roadmap.annotate-dependencies 18` added three wave headers; post-planning gap analysis reported SKIN-01 through SKIN-03 and D-01 through D-17 covered while unrelated milestone requirements remained outside Phase 18; `git diff --check -- .planning/milestones/v1.3-phases/18-skin-retouch-core-modules PLANS.md .planning/ROADMAP.md .planning/STATE.md` passed. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. |

Outcome:

- Phase 18 now has `18-01-PLAN.md` to audit Basic skin, Skin repair, and Teeth/hairline branch contracts before implementation.
- Phase 18 now has `18-02-PLAN.md` to improve Basic skin formulas inside `BeautyColorEffectPipeline`, add focused `SkinBasicEffectTests`, and protect facade/no-face behavior with resolver and engine tests.
- Phase 18 now has `18-03-PLAN.md` to run focused XCTest, build/run all five current Basic skin renderer cases, check dimensions, record factual visual observations, run future-branch negative scans, and close ledgers only after evidence passes.
- Skin repair and Teeth/hairline remain explicitly future-only; the plans include negative scans for no public parameter/API expansion, no future renderer cases, no resource/segmentation/AI/upload dependency, and no completion overclaim.
- Next step is `$gsd-execute-phase 18`.

### C-2026-06-27-gsd-discuss-phase-18-skin-retouch-core-modules

| Field | Value |
| --- | --- |
| Completed | 2026-06-27 |
| Scope | Ran `$gsd-discuss-phase 18` for Phase 18 Skin Retouch Core Modules. Captured user decisions for Basic skin formula ambition, facade-visible no-detection behavior, future branch exclusions, and Phase 18 verification gates before planning. |
| Requirements | SKIN-01, SKIN-02, SKIN-03 |
| Files | `.planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-CONTEXT.md`, `.planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 18` reported `phase_found: true`, `phase_dir: .planning/milestones/v1.3-phases/18-skin-retouch-core-modules`, `has_context: true`, `has_plans: false`, and `context_path: .planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-CONTEXT.md`; `test ! -e .planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-DISCUSS-CHECKPOINT.json` passed; targeted scan found `改进公式`, `保持 facade 可见`, `Skin repair`, `Teeth/hairline`, `skinSmoothing_0p50`, `skinCombo_0p50`, `Phase 18 context gathered`, and `18-CONTEXT` across the context/log/state files; `git diff --check -- .planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-CONTEXT.md .planning/milestones/v1.3-phases/18-skin-retouch-core-modules/18-DISCUSSION-LOG.md .planning/STATE.md` passed before this ledger update. |
| Build | Not run; this was a GSD context/documentation workflow with no Swift source changes. |

Outcome:

- Phase 18 context allows conservative Basic skin formula improvements inside the existing pipeline without adding public parameters, targets, or new render passes.
- Basic skin remains facade-visible in no-detection renderer/public paths as lightweight full-frame skin-tone improvement, while explicit internal no-face resolver semantics may still skip face-dependent skin for future detection-integrated flows.
- Skin repair and Teeth/hairline stay `future`; Phase 18 planning must add negative scans to prevent accidental implementation or completion claims.
- Required Phase 18 evidence is focused XCTest plus all current skin renderer cases, dimension checks, factual visual observations, and negative scans. Full `swift test --package-path BeautySDK` is optional extra evidence, not the fixed gate.
- Next step is `$gsd-plan-phase 18`.

### C-2026-06-26-gsd-execute-phase-17-core-beauty-contracts-and-module-boundaries

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Ran `$gsd-execute-phase 17` for Phase 17 Core Beauty Contracts and Module Boundaries. Normalized the Meitu core beauty blueprint status taxonomy, active family scope, branch detail docs, Demo-vs-SDK ownership, module dependency boundaries, public parameter coverage, future parameter needs, deferred-family exclusions, and Phase 17 evidence gates. |
| Requirements | CBT-01, CBT-02, CBT-03, MOD-01 |
| Files | `docs/meitu-function-blueprint/README.md`, `docs/meitu-function-blueprint/MINDMAP.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `docs/meitu-function-blueprint/MODULES.md`, `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md`, `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md`, `docs/meitu-function-blueprint/features/**/README.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-01-SUMMARY.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-02-SUMMARY.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-REVIEW.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-VERIFICATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.execute-phase 17` reported `incomplete_count: 0`; `phase-plan-index 17` reported both `17-01` and `17-02` with `has_summary: true`; `phase.complete 17` marked Phase 17 complete with `plans_executed: 2/2`; `verify.schema-drift 17` reported no drift; old status scan `! rg -n "static/future|partial/future|static/unavailable|planned-doc" docs/meitu-function-blueprint` passed; allowed status and parameter scans passed across matrix, family docs, and branch docs; top-level family directory check returned exactly `beauty-shaping`, `editor-shell`, and `skin-retouch`; deferred-family scan found Home/discovery, resource/style, AI/background, video/body, gallery/account, search, VIP, payment, and entitlement exclusions; `BeautyResources` deferred-owner negative scan passed; root-doc diff check returned no changes; Demo/renderer internal-import scan passed; renderer SwiftUI/UIKit scan passed; `git diff --name-only -- BeautyDemo BeautySDK/Sources example-images` returned empty; later SKIN, BSHAPE, EDITOR, MOD-02, MOD-03, and MOD-04 requirements remained pending; current STATE/ROADMAP ledgers no longer describe Phase 17 as planned or next to execute; `17-REVIEW.md` records `status: clean`; `17-VERIFICATION.md` records `status: passed`; `git diff --check -- docs/meitu-function-blueprint .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md PLANS.md` passed. |
| Build | Not run; Phase 17 was a documentation and boundary contract phase with no Swift source, SwiftUI screen, renderer case, fixture, or generated image output changes. |
| Commit | `d11a3bf` normalized the main blueprint contracts; `aa56c18` completed the first plan summary/tracking; `10d9fbe` normalized branch detail contracts; `68cb512` added the clean code review report; final ledger/verification commit records closeout artifacts. |

Outcome:

- The active blueprint now uses only `implemented`, `partial`, `blocked-by-geometry-output`, and `future` as branch statuses.
- Feature and branch docs separate current public `BeautyParameters` coverage from future parameter needs.
- Demo-owned rails, labels, badges, slider mapping, compare/debug, cancel/confirm, input routing, and parameter snapshots are explicitly app-side.
- SDK ownership stays product-neutral: `BeautyEffects` owns promoted effect logic with `BeautyDetection` and `BeautyRender` dependencies; `BeautyResources` remains dependency/future-only where needed.
- `CBT-01`, `CBT-02`, `CBT-03`, and `MOD-01` are complete; later skin, shaping, editor-support, and closeout requirements remain pending.
- Geometry-heavy saved-image output remains a later-phase limitation until public facade detection plus geometry render integration produces saved outputs.

### C-2026-06-26-gsd-plan-phase-17-core-beauty-contracts-and-module-boundaries

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Ran `$gsd-plan-phase 17` for Phase 17 Core Beauty Contracts and Module Boundaries. Created research, validation, pattern-map, and two executable plans to normalize the core beauty blueprint status taxonomy, module ownership, Demo-vs-SDK boundaries, deferred-family exclusions, and Phase 17 verification gates. |
| Requirements | CBT-01, CBT-02, CBT-03, MOD-01 |
| Files | `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-RESEARCH.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-VALIDATION.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-PATTERNS.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-01-PLAN.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-02-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `node "$HOME/.codex/get-shit-done/bin/gsd-tools.cjs" query init.plan-phase 17` reported `phase_status: Planned`, `has_research: true`, `has_context: true`, `has_plans: true`, `plan_count: 2`, and a Phase 17 `patterns_path`; structural scan found required plan sections including `<objective>`, `## Artifacts this phase produces`, `<threat_model>`, `<tasks>`, `<read_first>`, `<action>`, and `<acceptance_criteria>`; requirement scan found CBT-01, CBT-02, CBT-03, and MOD-01 across the research, validation, pattern, and plan files; explicit decision scan found D-01 through D-12 in the generated plans after `check.decision-coverage-plan` skipped because the current context markdown exposed no tool-trackable decisions; `17-VALIDATION.md` records `status: approved`, `nyquist_compliant: true`, and `wave_0_complete: true`; placeholder/template-token scan returned no matches; `state.planned-phase --phase 17 --name core-beauty-contracts-and-module-boundaries --plans 2` and `roadmap.annotate-dependencies 17` ran; `git diff --check -- .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries .planning/ROADMAP.md .planning/STATE.md PLANS.md` passed. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift or Xcode source changes. |

Outcome:

- Phase 17 now has `17-01-PLAN.md` for in-place blueprint normalization: strict branch statuses, feature matrix, module ownership, family docs, and deferred exclusions.
- Phase 17 now has `17-02-PLAN.md` for root-contract consistency, facade-only import scans, no-code/no-new-UI checks, and planning-ledger closeout after evidence passes.
- `17-VALIDATION.md` records the Nyquist validation strategy for static documentation scans and boundary checks.
- Geometry-heavy saved-image output remains deferred; provider/resolver evidence can support `partial` status only until public facade detection plus geometry render output exists.
- Next step is `$gsd-execute-phase 17`.

### C-2026-06-26-gsd-discuss-phase-17-core-beauty-contracts-and-module-boundaries

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Ran `$gsd-discuss-phase 17` for Phase 17 Core Beauty Contracts and Module Boundaries. Captured user decisions for branch status taxonomy, Demo-vs-SDK ownership, module dependency mapping, and verification/evidence gates before Phase 17 planning. |
| Requirements | CBT-01, CBT-02, CBT-03, MOD-01 |
| Files | `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md`, `.planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `node "$HOME/.codex/get-shit-done/bin/gsd-tools.cjs" query init.phase-op 17` reported `phase_found: true`, `phase_dir: .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries`, `has_context: true`, `has_plans: false`, and `context_path: .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md`; `test ! -e .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-DISCUSS-CHECKPOINT.json` passed; targeted context term scan found `blocked-by-geometry-output` and `BeautyParameters` in both Phase 17 context/log files; `rg` confirmed `.planning/STATE.md` now points to `Phase 17 context gathered` and `17-CONTEXT.md`; `git diff --check -- .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md .planning/milestones/v1.3-phases/17-core-beauty-contracts-and-module-boundaries/17-DISCUSSION-LOG.md .planning/STATE.md PLANS.md` passed. |
| Build | Not run; this was a GSD context/documentation workflow with no source changes. |

Outcome:

- Phase 17 context locks a strict four-state feature status model: `implemented`, `partial`, `blocked-by-geometry-output`, and `future`.
- Branch status stays branch-level with subtool notes and explicit current `BeautyParameters` coverage versus future parameter needs.
- Meitu-style branch names remain in blueprint docs and Demo taxonomy; SDK names stay product-neutral.
- Demo ownership is explicit for rails, labels, badges, slider mapping, compare/debug, cancel/confirm, input routing, and parameter snapshots.
- Future implementation phases use an evidence ladder; geometry provider tests count as partial evidence until public facade saved-image geometry output exists.
- Root contracts are updated only when Phase 17 changes a real contract.

### C-2026-06-26-gsd-execute-phase-16-example-image-validation-harness

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Ran `$gsd-execute-phase 16` for Phase 16 Example Image Validation Harness. Verified the existing `BeautyExampleRenderer` executable/output path, kept `EXAMPLE_IMAGE_VALIDATION.md` unchanged because it already contained the required contract, and closed PREP traceability from fresh command evidence without committing generated PNG outputs. |
| Requirements | PREP-01, PREP-02, PREP-03, PREP-04 |
| Files | `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-01-SUMMARY.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-02-SUMMARY.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-REVIEW.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-VERIFICATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer` passed; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50` wrote `e1` through `e5` outputs; `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png` confirmed both are `576 x 1024`; `git check-ignore example-images/out/e2__skinWhitening_0p50.png` passed; facade-only import scan returned no matches for internal SDK targets, SwiftUI, or UIKit; validation-doc scan found the build/run commands, `skinWhitening_0p50`, `example-images/out/`, `e2__skinWhitening_0p50.png`, `Geometry Limitation`, and `face detection plus geometry rendering integration`; visual inspection recorded only: output is non-empty; watermark is readable; bottom watermark does not cover the face; `16-VERIFICATION.md` records `status: passed`; code review records `status: clean` for the Phase 16 source/support commit. |
| Build | SwiftPM executable build and representative renderer run passed. Full SDK test suite was not rerun for Phase 16 because the phase verification contract is the renderer build/run/dimension path. |
| Commit | `be1d960` adds the renderer support files and Phase 16 plans; `3a9423e`, `a63963c`, `88f4f09`, `8f4220e`, and `3fd3d38` record summaries, ledgers, review/verification, canonical completion state, and project context. |

Outcome:

- `PREP-01` through `PREP-04` are complete from fresh Phase 16 command evidence.
- `example-images/out/e2__skinWhitening_0p50.png` is the representative ignored local output and matches `example-images/input/e2.png` dimensions.
- Generated PNG outputs remain under ignored `example-images/out/`; no `.planning/evidence/v1.3/*.png` artifact was added.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` remains the authority for command/output/case rules and needed no content change.
- geometry-heavy saved-image output remains deferred to Phase 19.

### C-2026-06-26-gsd-plan-phase-16-example-image-validation-harness

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Ran `$gsd-plan-phase 16` for Phase 16 Example Image Validation Harness. Created research, validation, pattern-map, and two executable plans that formalize the existing `BeautyExampleRenderer` path without adding UI, new renderer cases, new fixtures, or new algorithms. |
| Requirements | PREP-01, PREP-02, PREP-03, PREP-04 |
| Files | `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-RESEARCH.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-VALIDATION.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-PATTERNS.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-01-PLAN.md`, `.planning/milestones/v1.3-phases/16-example-image-validation-harness/16-02-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 16` reports `has_research: true`, `has_context: true`, `has_plans: true`, and `plan_count: 2`; plan structure scan passed for frontmatter, objectives, tasks, `read_first`, `action`, `acceptance_criteria`, `threat_model`, and artifacts sections; requirement scan covered `PREP-01` through `PREP-04`; `check.decision-coverage-plan` passed with 20/20 CONTEXT decisions covered; placeholder/stale-token scan returned no matches; `git diff --check -- .planning/milestones/v1.3-phases/16-example-image-validation-harness` passed. |
| Build | Not run; this was a GSD planning/documentation workflow. The generated plans require Phase 16 execution to run `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer`, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50`, and `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png`. |
| Commit | Not created because the worktree already contained unrelated modified and untracked files, including pre-existing changes in `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md`, and documentation files. |

Outcome:

- Phase 16 now has `16-01-PLAN.md` for fresh SwiftPM build/run/dimension/ignored-output/facade-only verification.
- Phase 16 now has `16-02-PLAN.md` for documentation and planning-ledger closeout after fresh evidence exists.
- `16-VALIDATION.md` records the Nyquist validation strategy and blocks on build, renderer run, missing representative output, ignored-output failure, or dimension mismatch.
- `16-PATTERNS.md` captures the local renderer, output-directory, documentation, and requirement-closeout patterns for executors.
- Geometry-heavy saved-image output remains deferred to Phase 19 and must not be marked visually complete by Phase 16.

### C-2026-06-26-v1-3-core-module-prep

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Prepared v1.3 Meitu Core Beauty Module Design and Implementation: kept scope to core beauty only, added a no-UI example-image validation harness, documented how to run code modules against `example-images/input/`, saved parameter-labeled outputs to `example-images/out/`, and updated planning docs so later work implements SDK core modules rather than new UI. |
| Requirements | PREP-01 through PREP-04, CBT-01 through CBT-03, BSHAPE-01 through BSHAPE-03, SKIN-01 through SKIN-03, EDITOR-01 through EDITOR-03, MOD-01 through MOD-04 |
| Files | `BeautySDK/Package.swift`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `.gitignore`, `docs/meitu-function-blueprint/README.md`, `docs/meitu-function-blueprint/MINDMAP.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `docs/meitu-function-blueprint/MODULES.md`, `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md`, `docs/meitu-function-blueprint/features/beauty-shaping/**`, `docs/meitu-function-blueprint/features/skin-retouch/**`, `docs/meitu-function-blueprint/features/editor-shell/**`, `docs/README.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer` passed; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50` wrote five PNGs; `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png` confirmed both are `576 x 1024`; output visual inspection confirmed the bottom watermark is readable and does not cover the face; `swift test --package-path BeautySDK` passed with 119 tests; stale-scope scan found no current v1.3 docs-only claims outside historical Completed entries; `git diff --check` passed for touched files. |
| Build | SwiftPM executable build and full SDK SwiftPM tests passed. |

Outcome:

- `BeautyExampleRenderer` now provides a no-UI validation path from `example-images/input/` to ignored `example-images/out/`.
- Output files include source image, parameter, and strength in the filename and a readable bottom watermark on the image.
- v1.3 planning now starts from code-level module verification rather than UI work or docs-only planning.
- Geometry-heavy branches still need face detection plus geometry rendering output before saved-image visual completion can be claimed.

### C-2026-06-26-v1-2-html-reference-baselines-retained

| Field | Value |
| --- | --- |
| Completed | 2026-06-26 |
| Scope | Closed v1.2 as reduced-scope complete: retained Phase 11 local static HTML baselines and browser evidence, canceled Phase 12 HTML-to-SwiftUI Delta Contract, Phase 13 Home SwiftUI Fidelity Pass, Phase 14 Editor SwiftUI Fidelity Pass, and Phase 15 v1.2 Visual QA and Closeout by user decision. |
| Requirements | HTML-01 through HTML-05 complete; AUDIT-01 through AUDIT-03, HSWIFT-01 through HSWIFT-03, ESWIFT-01 through ESWIFT-03, and VQA-01 through VQA-03 canceled. |
| Files | `.planning/milestones/v1.2-REQUIREMENTS.md`, `.planning/milestones/v1.2-ROADMAP.md`, `.planning/milestones/v1.2-MILESTONE-AUDIT.md`, `.planning/milestones/v1.2-phases/11-html-reference-baselines/`, `archives/legacy-ui/`, `.planning/evidence/v1.2/`, `.planning/PROJECT.md`, `.planning/MILESTONES.md`, and `PLANS.md` |
| Verification | The verified `meituxiuxiu` archive restores to a new temporary directory; its local `offline-check.mjs` and required-label scans pass; the three retained 390x844 PNGs are present. The replay path is archive-first and never assumes an active `meituxiuxiu/html` tree. Historical visual debt is recorded in the v1.2 re-verification artifact. |
| Build | Not run for the cancellation cleanup; only planning Markdown files changed after Phase 11. |

Outcome:

- Phase 11 HTML reference outputs remain available in the verified `meituxiuxiu`
  ZIP under `archives/legacy-ui/` and `.planning/evidence/v1.2/`; restore the
  ZIP only to a new temporary directory for inspection.
- Phase 12-15 planning and execution are intentionally canceled, not open blockers.
- Future SwiftUI visual tuning must be promoted as a new milestone or phase instead of resuming canceled v1.2 work by default.

### C-2026-06-24-v1-1-meitu-ui-implementation

| Field | Value |
| --- | --- |
| Completed | 2026-06-24 |
| Scope | Implemented v1.1 Meitu-style Home, Meitu-style editor tool panel, and Home-to-editor routing while preserving the existing local `BeautySDK` facade, camera/photo pipelines, compare/debug/JSON behavior, and honest unavailable states. |
| Requirements | HOME-01 through HOME-06, EDIT-01 through EDIT-07, FLOW-01 through FLOW-06 |
| Files | `BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift`, `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift`, `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift`, `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift`, `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`, `BeautyDemo/BeautyDemo/ContentView.swift`, `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`, `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift`, `.planning/evidence/v1.1/VISUAL-EVIDENCE.md`, `.planning/milestones/v1.1-phases/08-meitu-home-rebuild/08-VERIFICATION.md`, `.planning/milestones/v1.1-phases/09-meitu-editor-tool-panel/09-VERIFICATION.md`, `.planning/milestones/v1.1-phases/10-home-to-editor-flow-and-v1-1-qa/10-VERIFICATION.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Focused `BeautyDemoViewStateTests`, full `BeautyDemo` simulator tests, full `BeautySDK` SwiftPM tests, facade import scan, and screenshot-backed visual evidence passed. |
| Build | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` passed; full Demo simulator test and SDK SwiftPM test passed. |

Outcome:

- `ContentView` now launches into `MeituHomeView` by default instead of the old SDK-dashboard shell.
- Home implements the dark Meitu-style first screen with film hero, search/brand/VIP chrome, `拍一拍`, primary action hierarchy, paged tool grid, recommendation rails, floating bottom tab bar, and sticky shortcut rail.
- Editor implements the referenced black preview plus white bottom panel with `背景保护`, compare/debug affordances, shared intensity slider, `整体`, cancel/confirm, and first-level category order `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`.
- Supported reference tools write existing `BeautyParameterStore` controls; unsupported Meitu/VIP/AI/Pro/video/body/makeup-like capabilities remain visible but disabled/static instead of fake-functional.
- `图片美化`, `相机`, `拍一拍`, and `人像美容` route into the existing local photo/camera/editor paths; launch-only screenshot routes are documented as verification hooks, not product features.
- Screenshot evidence is stored in `.planning/evidence/v1.1/home-first-screen.png`, `.planning/evidence/v1.1/home-sticky-state.png`, and `.planning/evidence/v1.1/editor-tool-panel.png`.
- Remaining non-v1.1 work: exact commercial asset parity, full `图库` / `AI 修图` / `我` tabs, network AI tools, real video editing, new SDK algorithm families, hardware QA, performance budgets, and long-run release-hardening.

### C-2026-06-23-meituxiuxiu-home-map

| Field | Value |
| --- | --- |
| Completed | 2026-06-23 |
| Scope | Reviewed the 4 homepage PNG screenshots under `meituxiuxiu/home/`, classified first-screen, tool-grid pagination, recommendation feed, sticky shortcut, and bottom-tab behavior, and documented how the homepage reference relates to the existing editor tool-panel reference. |
| Files | `meituxiuxiu/HOME_MAP.md`, `meituxiuxiu/FUNCTION_MAP.md`, `PLANS.md` |
| Verification | Visual inspection covered `IMG_0871.PNG` through `IMG_0874.PNG`; `HOME_MAP.md` maps all four screenshots to deduplicated UI states and records the homepage/editor split; `git diff --check -- meituxiuxiu/HOME_MAP.md meituxiuxiu/FUNCTION_MAP.md PLANS.md` passed. |
| Build | Not run; this was a reference documentation task with no Swift/Xcode source changes. |

Outcome:

- `meituxiuxiu/HOME_MAP.md` now captures homepage structure, main actions, paged tool grid, recommendation feed, sticky scrolled state, bottom tabs, and 1:1 restoration notes.
- `meituxiuxiu/FUNCTION_MAP.md` now points readers to the separate homepage reference so editor screenshots are not mistaken for home screenshots.

### C-2026-06-23-meituxiuxiu-reference-map

| Field | Value |
| --- | --- |
| Completed | 2026-06-23 |
| Scope | Reviewed all 15 PNG screenshots under `meituxiuxiu/`, classified them by unique Meitu Xiuxiu editor function category, merged duplicate horizontal-scroll screenshots into functional groups, and documented the reference UI structure without deleting any source images. |
| Files | `meituxiuxiu/FUNCTION_MAP.md`, `PLANS.md` |
| Verification | Visual inspection covered `IMG_0856.PNG` through `IMG_0870.PNG`; the document records 7 unique first-level function groups and maps every screenshot to a deduplicated role; `git diff --check -- meituxiuxiu/FUNCTION_MAP.md PLANS.md` passed. |
| Build | Not run; this was a reference documentation task with no Swift/Xcode source changes. |

Outcome:

- `meituxiuxiu/FUNCTION_MAP.md` now captures the shared editor layout, unique function taxonomy, per-image classification, duplicate handling, and uncovered scope.
- The reference folder was identified as editor-panel evidence, not App-home evidence.

### C-2026-06-23-gsd-complete-milestone-v1

| Field | Value |
| --- | --- |
| Completed | 2026-06-23 |
| Scope | Completed `$gsd-complete-milestone v1.0` for the MVP milestone: archived roadmap, requirements, and milestone audit files; collapsed living PROJECT/ROADMAP/STATE context for the next milestone; wrote milestone summary and retrospective; kept `.planning/phases/` in place per user option `2`; and removed root `.planning/REQUIREMENTS.md` so the next milestone starts with fresh requirements. |
| Files | `.planning/milestones/v1.0-ROADMAP.md`, `.planning/milestones/v1.0-REQUIREMENTS.md`, `.planning/milestones/v1.0-MILESTONE-AUDIT.md`, `.planning/MILESTONES.md`, `.planning/RETROSPECTIVE.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `PLANS.md` |
| Verification | Pre-close checks had passed before archival: `gsd-tools.cjs query audit-open` reported all clear; `gsd-tools.cjs query roadmap.analyze` reported 7/7 phases, 28/28 plans, 100%; requirements audit showed 33/33 v1 requirements complete; archive safety commit `ada0596` was created before deleting `.planning/REQUIREMENTS.md`; `git diff --check` over milestone archive files passed; final staged diff check passed before commit. |
| Build | Not run for this closeout step; only GSD planning/archive Markdown files changed. Full SDK SwiftPM tests and Demo simulator tests had passed earlier in the same v1.0 audit run and are cited in `.planning/milestones/v1.0-MILESTONE-AUDIT.md`. |

Outcome:

- v1.0 MVP now has historical archive files under `.planning/milestones/`.
- Living `.planning/ROADMAP.md`, `.planning/PROJECT.md`, and `.planning/STATE.md` point to next-milestone planning instead of carrying the full v1.0 working set.
- `.planning/REQUIREMENTS.md` was removed after the archive safety commit; `$gsd-new-milestone` should recreate fresh active requirements.
- `.planning/phases/` remains in place as raw execution history because the user chose not to move phase directories.

### C-2026-06-23-gsd-audit-gap-closure-v1

| Field | Value |
| --- | --- |
| Completed | 2026-06-23 |
| Scope | Closed the v1.0 milestone audit documentation gaps by adding missing phase verification reports, backfilling validation audit status across all phases, rechecking 33/33 requirement traceability, and updating `.planning/v1.0-MILESTONE-AUDIT.md` from `gaps_found` to `passed`. |
| Files | `.planning/v1.0-MILESTONE-AUDIT.md`, `.planning/milestones/v1.0-phases/01-sdk-foundation-and-public-facade/01-VALIDATION.md`, `.planning/milestones/v1.0-phases/02-demo-integration-shell/02-01-SUMMARY.md`, `.planning/milestones/v1.0-phases/02-demo-integration-shell/02-02-SUMMARY.md`, `.planning/milestones/v1.0-phases/02-demo-integration-shell/02-03-SUMMARY.md`, `.planning/milestones/v1.0-phases/02-demo-integration-shell/02-VALIDATION.md`, `.planning/milestones/v1.0-phases/02-demo-integration-shell/02-VERIFICATION.md`, `.planning/milestones/v1.0-phases/03-realtime-and-still-input-slice/03-VALIDATION.md`, `.planning/milestones/v1.0-phases/03-realtime-and-still-input-slice/03-VERIFICATION.md`, `.planning/milestones/v1.0-phases/04-detection-and-coordinate-safety/04-VALIDATION.md`, `.planning/milestones/v1.0-phases/04-detection-and-coordinate-safety/04-VERIFICATION.md`, `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-VALIDATION.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-VALIDATION.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-VERIFICATION.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-VALIDATION.md`, `PLANS.md` |
| Verification | `gsd-tools.cjs query audit-open --json` returned 0 open items; `gsd-tools.cjs query roadmap.analyze` reported 7/7 phases, 28/28 plans, 100%; requirement cross-check script reported 33 requirements, 33 verification IDs, 33 summary IDs, with no missing/extra IDs; Nyquist scan reported compliant phases `01` through `07`, no partial/missing phases; stale validation status scan for `draft`, `pending`, incomplete Wave 0, and missing/planned task rows returned no matches; audit-report stale-gap scan returned no matches; `git diff --check -- <touched audit/validation/verification files>` exited 0. |
| Build | No code changes in this cleanup. Full SDK SwiftPM tests and full Demo simulator tests had passed earlier in the same 2026-06-23 milestone audit run and are cited in the updated audit report. |

Outcome:

- `.planning/v1.0-MILESTONE-AUDIT.md` now records `status: passed`, 33/33 requirements satisfied, 7/7 phase verification files present, 4/4 integration checks, 4/4 flows, and 7/7 Nyquist-compliant phases.
- Missing Phase 2, 3, 4, and 6 verification artifacts are now present with requirement evidence and no blocking gaps.
- All seven validation files have approved frontmatter, `nyquist_compliant: true`, `wave_0_complete: true`, and green task rows.
- Remaining risks are non-blocking release/manual QA debt already tracked as `TD-007` through `TD-010`.

### C-2026-06-23-gsd-audit-milestone-v1

| Field | Value |
| --- | --- |
| Completed | 2026-06-23 |
| Scope | Ran `$gsd-audit-milestone v1.0` preflight before milestone archival, aggregating phase verification coverage, requirements traceability, current SDK/Demo integration checks, UAT status, and Nyquist validation-document coverage. |
| Files | `.planning/v1.0-MILESTONE-AUDIT.md`, `PLANS.md` |
| Verification | `gsd-tools.cjs query audit-open --json` returned 0 open items before audit; `gsd-tools.cjs query roadmap.analyze` reported 7/7 phases, 28/28 plans, 100%; `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 tests; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed; Demo internal facade-boundary scan returned no matches; active local-first/privacy scan returned no matches. |
| Build | Full SDK SwiftPM tests and full Demo simulator tests passed. |

Outcome:

- Milestone audit status is `gaps_found`, not `passed`.
- Current implementation/integration evidence is green, but the GSD audit gate found 21 orphaned requirements because Phases 2, 3, 4, and 6 lack phase-level `*-VERIFICATION.md` files.
- All seven phases have `*-VALIDATION.md`, but strict Nyquist audit classification remains partial because validation task tables still contain draft/pending state.
- Next options are to regenerate missing phase verification reports and rerun audit, or explicitly proceed with `$gsd-complete-milestone v1.0` while accepting these documentation gaps as known debt.

### C-2026-06-23-gsd-execute-phase-7-rich-demo-qa-surface

| Field | Value |
| --- | --- |
| Completed | 2026-06-23 |
| Scope | Executed GSD Phase 7 final wave 07-03 after 07-01 and 07-02: ran focused Demo QA, full Demo simulator tests, full SDK SwiftPM tests, facade/privacy scans, fixed stale unavailable-copy test coverage, closed DEMO-06/DEMO-07 traceability, and updated root docs/quality evidence for v1 Demo readiness. |
| Requirements | DEMO-06, DEMO-07 |
| Files | `BeautyDemo/BeautyDemoTests/BeautyCategoryModelTests.swift`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-03-SUMMARY.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-VERIFICATION.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-HUMAN-UAT.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-SECURITY.md` |
| Verification | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/ParameterJSONCodingTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests` passed; first full Demo suite run exposed stale `BeautyCategoryModelTests.testFutureFacialFeatureSubcategoriesAreDisabled` expectation for old future-resource badge, then `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyCategoryModelTests` passed and the full Demo suite passed; `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 XCTest cases; `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches; exact broad JSON/debug privacy scan returned expected XCTest guard literals and non-debug `CGRect` image helpers, while scoped active JSON/debug surface scan returned no matches; `git diff --check -- BeautyDemo BeautySDK FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning` exited 0. |
| Build | Focused Demo tests, full Demo simulator tests, and full SDK SwiftPM tests passed. |

Outcome:

- `DEMO-06` is complete with deterministic parameter JSON export/import preview, failed-import non-mutation, source/reset semantics, and copy/paste-only privacy evidence.
- `DEMO-07` is complete with before/after compare preservation, read-only redacted debug overlay states, recoverable error codes, and v1 unavailable-state honesty.
- Phase 7 does not claim manual visual naturalness, real-device camera/Vision parity, production render quality, simulator screenshot/UI automation, performance budgets, or long-run hardware readiness; those remain release risks until separately proven.
- GSD verifier recorded 5/5 must-haves verified with no implementation gaps; subsequent human UAT passed all four visible SwiftUI checks in `07-HUMAN-UAT.md`.
- GSD security gate recorded `threats_open: 0` for 14 plan-time threats; accepted supply-chain risks are documented as native SwiftUI/no-new-dependency decisions in `07-SECURITY.md`.

### C-2026-06-22-gsd-plan-phase-7-rich-demo-qa-surface

| Field | Value |
| --- | --- |
| Completed | 2026-06-22 |
| Scope | Ran `$gsd-plan-phase 7` after research, validation, and UI-SPEC gates were already satisfied; produced a Phase 7 pattern map and three executable plans for parameter JSON/source semantics, preview debug/unavailable-state polish, and final QA/readiness closeout. |
| Requirements | DEMO-06, DEMO-07 |
| Files | `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-PATTERNS.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-01-PLAN.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-02-PLAN.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-03-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 7` reports `phase_status: Planned`, `has_research: true`, `has_context: true`, `has_plans: true`, `plan_count: 3`, and `patterns_path` set; frontmatter/task scan passed for all three plans with required keys, `read_first`, `action`, `acceptance_criteria`, artifacts, and threat models; requirement scan covered `DEMO-06` and `DEMO-07`; `check.decision-coverage-plan` passed with 23/23 CONTEXT decisions covered; placeholder scan over `07-PATTERNS.md` and `07-0*-PLAN.md` returned no matches; `state.planned-phase --phase 07 --name rich-demo-qa-surface --plans 3` and `roadmap.annotate-dependencies 07` ran; post-planning gap analysis covered `DEMO-06`, `DEMO-07`, and `D-01` through `D-23`, with only non-Phase-7 requirements reported as not covered; `git diff --check -- .planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-PATTERNS.md .planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-0*-PLAN.md` exited 0. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift or Xcode source changes. |
| Commit | Not created because the worktree already contains unrelated modified/untracked files and `PLANS.md` / `.planning/STATE.md` had pre-existing local changes outside this plan generation. |

Outcome:

- Phase 7 now has `07-PATTERNS.md` and three executable plans in waves 1 through 3.
- `07-01` adds copy/paste parameter JSON, deterministic export, preview-before-apply validation, imported/preset/custom source state, and reset semantics for `DEMO-06`.
- `07-02` adds the read-only preview debug overlay, compare/debug preservation, redacted camera/photo debug state, and disabled/future category polish for `DEMO-07`.
- `07-03` closes final focused/full QA, privacy/import scans, requirements traceability, root docs, quality score, and manual release-risk recording for `DEMO-06` and `DEMO-07`.
- `.planning/ROADMAP.md` records Phase 7 wave dependencies, and `.planning/STATE.md` points resume to `07-01-PLAN.md` for execution.
- Planning was performed inline because this Codex runtime did not expose direct sub-agent execution in the current tool set; the GSD planner/checker gates were applied through local artifacts and deterministic checks.

### C-2026-06-22-gsd-ui-phase-7-rich-demo-qa-surface

| Field | Value |
| --- | --- |
| Completed | 2026-06-22 |
| Scope | Ran `$gsd-ui-phase 7` for Phase 7 and produced an approved SwiftUI UI design contract covering copy/paste parameter JSON, preview-before-apply import, source/reset semantics, preview-surface debug overlay, unavailable-state polish, accessibility, privacy boundaries, and verification expectations. |
| Requirements | DEMO-06, DEMO-07 |
| Files | `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-UI-SPEC.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `wc -l` reported 333 lines for `07-UI-SPEC.md`; frontmatter/sign-off scan found `status: approved`, `reviewed_at`, and six checked PASS dimensions; inline gsd-ui-checker gate approved Copywriting, Visuals, Color, Typography, Spacing, and Registry Safety; placeholder/generic-copy scan over `07-UI-SPEC.md` and `.planning/STATE.md` returned no matches; `init.plan-phase 7` reports `has_research: true`, `has_context: true`, `has_plans: false`, and `plan_count: 0`; `workflow.ui_phase` and `workflow.ui_safety_gate` are both `true`; `git diff --check -- .planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-UI-SPEC.md .planning/STATE.md PLANS.md` exited 0. |
| Build | Not run; this was a GSD UI contract/documentation workflow with no Swift or Xcode source changes. |
| Commit | Not created because the worktree already contains unrelated modified/untracked files and `PLANS.md` / `.planning/STATE.md` had pre-existing local changes outside this UI-SPEC write. |

Outcome:

- Phase 7 now has an approved `07-UI-SPEC.md` for native SwiftUI implementation planning.
- The contract preserves the existing 4/8/16/24/32/48/64 spacing scale, four-size/two-weight typography, existing palette, SF Symbols, and no web registry.
- Planner can proceed with `$gsd-plan-phase 7` using the UI contract as design context.
- Sub-agent work was executed inline because this Codex runtime exposes sub-agents under an explicit delegation rule; the researcher/checker instructions and gates were still applied.

### C-2026-06-22-gsd-discuss-phase-7-rich-demo-qa-surface

| Field | Value |
| --- | --- |
| Completed | 2026-06-22 |
| Scope | Ran `$gsd-discuss-phase 7` in text mode and captured Phase 7 implementation decisions for copy/paste parameter JSON, reset/source semantics, read-only debug overlay, final Demo readiness evidence, manual release-risk handling, and v1 traceability closure. |
| Requirements | DEMO-06, DEMO-07 |
| Files | `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-CONTEXT.md`, `.planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `wc -l` reported 160 lines for `07-CONTEXT.md` and 234 lines for `07-DISCUSSION-LOG.md`; placeholder scan for `[X]`, `[Name]`, `[date]`, `{PHASE`, `TODO`, `TBD`, `FIXME`, `Lorem`, `占位`, and `待定` returned no matches; `init.phase-op 7` reports `has_context: true`, `has_plans: false`, and `context_path: .planning/milestones/v1.0-phases/07-rich-demo-qa-surface/07-CONTEXT.md`; checkpoint removal check printed `checkpoint_removed=yes`; `.planning/STATE.md` records `Stopped at: Phase 7 context gathered` and the Phase 7 context resume file; `git diff --check -- .planning/milestones/v1.0-phases/07-rich-demo-qa-surface .planning/STATE.md PLANS.md` exited 0. |
| Build | Not run; this was a GSD discussion/context documentation workflow with no Swift or Xcode source changes. |

Outcome:

- Phase 7 is ready for planning with locked decisions for a copy/paste JSON sheet using a versioned `schemaVersion` + `parameters` envelope, preview-before-apply validation, unchanged parameters on failed import, and minimal deterministic export payloads.
- Reset semantics stay simple and current-behavior aligned: single reset and reset all return to SDK zero defaults, imported JSON is a custom snapshot, and manual edits clear applied-source state.
- Debug overlay scope is read-only and privacy-safe: one preview-surface toggle, redacted diagnostic summary fields, last redacted error code plus friendly status, and no face boxes, landmarks, control points, raw framework strings, paths, or stack traces.
- Final Demo readiness requires focused XCTest/view-state/pipeline evidence plus privacy/import scans, while manual visual naturalness, real-device camera/Vision parity, long-run hardware checks, and readiness claims remain explicit release risks until proven.

### C-2026-06-22-gsd-execute-phase-6-core-beauty-effects

| Field | Value |
| --- | --- |
| Completed | 2026-06-22 |
| Scope | Executed GSD Phase 6 core beauty effects plans 06-01 through 06-05 in wave order, closing MVP skin, color/filter, face-shape, eyes, nose, mouth, lip color, combined safety, Demo feedback, docs, and final verification. |
| Requirements | EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07, EFFECT-09 |
| Files | `BeautySDK/Sources/BeautyEffects/**`, `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautySDK/Tests/BeautyEffectsTests/**`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`, `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`, `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift`, `BeautyDemo/BeautyDemoTests/*.swift`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/*-SUMMARY.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` passed with 4 tests; `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` passed with 10 tests; `swift test --package-path BeautySDK --filter BeautyEngineTests` passed with 9 tests; `swift test --package-path BeautySDK --filter BeautyEffectsTests` passed with 45 tests; focused Demo `xcodebuild` for `BeautyParameterStoreTests`, `BeautyDemoViewStateTests`, `BeautyDemoImportBoundaryTests`, and `InputPipelinePrivacyTests` passed; full `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 67 Demo XCTest cases; full `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 XCTest cases; Demo internal import scan returned no matches; exact stale pending-copy scan returned no matches; public geometry/raw framework/path scan returned no matches; `git diff --check -- BeautySDK BeautyDemo ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning` exited 0. |
| Build | SDK SwiftPM tests and Demo simulator tests passed. XcodeBuildMCP `test_sim` could not find `simctl` in its tool environment, so verification used the planned shell `xcodebuild` commands with explicit `DEVELOPER_DIR`. |

Outcome:

- `BeautyEffects` now owns tested effect resolution, safety caps, skin/color/filter output, face/eye/nose/mouth providers, lip color, combined geometry weakening, no-face skips, missing-landmark degradation, reused/stale behavior, and redacted warning/metric evidence.
- Public `BeautyEngine` paths preserve default no-op behavior while applying deterministic MVP visual output for scoped domains and conservative built-in presets.
- Demo normal parameter, filter, preset, and reset interactions stay quiet instead of showing stale pending-copy feedback; detection/degradation copy remains in the existing status path.
- Root docs and quality score now reflect completed Phase 6 behavior and the remaining manual risks: visual naturalness review, production render quality, simulator screenshot/UI automation, real-device camera/Vision smoke, performance budgets, and long-run reliability.

### C-2026-06-21-gsd-plan-phase-6-core-beauty-effects

| Field | Value |
| --- | --- |
| Completed | 2026-06-21 |
| Scope | Ran `$gsd-plan-phase 6` with research-first flow and produced Phase 6 research, validation, pattern, and five executable plans for core beauty effects. |
| Requirements | EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07, EFFECT-09 |
| Files | `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-RESEARCH.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-VALIDATION.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-PATTERNS.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-01-PLAN.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-02-PLAN.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-03-PLAN.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-04-PLAN.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-05-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 6` reports `phase_status: Planned`, `has_research: true`, `has_plans: true`, and `plan_count: 5`; frontmatter scan passed for all five plans with required keys; requirement scan covered `EFFECT-01`, `EFFECT-04`, `EFFECT-05`, `EFFECT-06`, `EFFECT-07`, and `EFFECT-09`; `check.decision-coverage-plan` passed with 18/18 CONTEXT decisions covered; placeholder scan for `[X]`, `[Name]`, `[date]`, `{PHASE`, `TODO`, `TBD`, and `FIXME` returned no matches; `06-RESEARCH.md` contains `RESEARCH COMPLETE`; `state.planned-phase --phase 06 --name core-beauty-effects --plans 5` updated Phase 6 state; `roadmap.annotate-dependencies 06` annotated five waves and three cross-cutting constraints; gap analysis covered all Phase 6 requirements and D-01 through D-18, with only other-phase requirements reported as out of scope; `git diff --check -- .planning/milestones/v1.0-phases/06-core-beauty-effects .planning/ROADMAP.md .planning/STATE.md PLANS.md` exited 0. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift or Xcode source changes. |
| Commit | Not created because the repository has unrelated modified and untracked files outside this Phase 6 planning scope. |

Outcome:

- Phase 6 now has `06-RESEARCH.md`, `06-VALIDATION.md`, `06-PATTERNS.md`, and five executable plans in waves 1 through 5.
- `06-01` establishes effect planning, safety caps, and visible skin/color/filter/preset output.
- `06-02` adds face-shape and chin warp providers with naturalness caps and compound weakening.
- `06-03` adds eye and nose providers with targeted missing-landmark degradation.
- `06-04` adds mouth and lip behavior with safe missing-mouth degradation.
- `06-05` closes combined-effect safety, no-face/stale behavior, Demo status/smoke tests, root docs, and final verification.
- `.planning/ROADMAP.md` records Phase 6 wave dependencies, and `.planning/STATE.md` points resume to `06-01-PLAN.md` for execution.

### C-2026-06-20-gsd-discuss-phase-6-core-beauty-effects

| Field | Value |
| --- | --- |
| Completed | 2026-06-20 |
| Scope | Ran `$gsd-discuss-phase 6` in text mode and captured Phase 6 implementation decisions for visible MVP output, naturalness caps, missing-landmark degradation, preset behavior, Demo feedback, canonical refs, and code context. |
| Requirements | EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07, EFFECT-09 |
| Files | `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-CONTEXT.md`, `.planning/milestones/v1.0-phases/06-core-beauty-effects/06-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `wc -l` reported 151 lines for `06-CONTEXT.md` and 227 lines for `06-DISCUSSION-LOG.md`; heading scan found the expected context/log structure; placeholder scan for `[X]`, `[Name]`, `[date]`, `{PHASE`, `TODO`, `TBD`, and `FIXME` returned no matches; checkpoint removal check printed `checkpoint_removed=yes`; `init.phase-op 6` returned `has_context: true` and `context_path: .planning/milestones/v1.0-phases/06-core-beauty-effects/06-CONTEXT.md`; `.planning/STATE.md` records `Stopped at: Phase 6 context gathered` and the Phase 6 context resume file; `git diff --check -- .planning/milestones/v1.0-phases/06-core-beauty-effects .planning/STATE.md` exited 0. |
| Build | Not run; this was a GSD discussion/context documentation workflow with no Swift or Xcode source changes. |

Outcome:

- Phase 6 is ready for planning with locked decisions for fixture-visible but conservative output across skin/color, face shape, eyes, nose, mouth, lip color, filters, and presets.
- Safety caps start from `docs/06_beauty_parameters_spec.md`, combined geometry strength must be weakened when controls compound, and cap events should be visible through result metadata rather than normal UI copy.
- No-face and missing-landmark behavior is targeted and conservative: non-face effects may continue, affected face-dependent domains skip or weaken, and existing Demo detection status/debug surfaces remain the UI path.
- Existing controls and categories stay unchanged; all five built-in presets should become conservative visible presets; focused Demo smoke must cover Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets panel paths.

### C-2026-06-19-gsd-execute-phase-5-filters-presets-resource-flow

| Field | Value |
| --- | --- |
| Completed | 2026-06-19 |
| Scope | Executed GSD Phase 5: added bundled resource manifest/preset JSON, public resource facade APIs, schema-versioned preset decoding, metadata-only filters, color/filter parameter validation, Demo preset/filter chips, eight color controls, focused source guardrails, root contract docs, and Phase 5 evidence. |
| Requirements | EFFECT-02, EFFECT-03, EFFECT-08 |
| Files | `BeautySDK/Package.swift`, `BeautySDK/Sources/BeautyCore/Models/*`, `BeautySDK/Sources/BeautyResources/**`, `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift`, `BeautySDK/Tests/**/*.swift`, `BeautyDemo/BeautyDemo/Panel/*.swift`, `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`, `BeautyDemo/BeautyDemoTests/*.swift`, `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/*-SUMMARY.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK` passed with 71 XCTest cases; `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 66 Demo XCTest cases; Demo internal import scan returned no matches; LUT/asset scope scan returned no matches; raw resource/path scan returned one intentional internal facade import at `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift:2`, while Demo source/tests remained facade-only. |
| Build | SDK SwiftPM tests and Demo simulator tests passed. |

Outcome:

- `BeautyResources` now loads a schema-versioned bundled manifest, five built-in preset JSON files, and two metadata-only filters: `soft_clean` and `warm_light`.
- `BeautySDKResources` exposes filters, built-in presets, preset lookup, and parameter validation through the public `BeautySDK` facade.
- Demo Beauty panel now includes five preset chips, eight color controls, enabled Filters with `None`, `Soft Clean`, `Warm Light`, and `Filter Intensity`, plus redacted friendly resource failure copy.
- Source guardrails cover Demo facade-only imports, Demo panel/state resource leakage, resource traversal-like IDs, and accidental LUT/thumbnail/swatch scope creep.
- Remaining product risk: Phase 5 proves parameter flow and resource contracts only; real visual quality for color/filter effects remains Phase 6+ render scope.

### C-2026-06-19-gsd-plan-phase-5-filters-presets-resource-flow

| Field | Value |
| --- | --- |
| Completed | 2026-06-19 |
| Scope | Ran `$gsd-plan-phase 5` inline for Phase 5 and produced the Phase 5 pattern map plus four executable plans covering resource manifest/preset resources, facade resource validation/no-op color contracts, Demo preset/filter/color UI wiring, and final verification/docs. |
| Requirements | EFFECT-02, EFFECT-03, EFFECT-08 |
| Files | `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-PATTERNS.md`, `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-01-PLAN.md`, `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-02-PLAN.md`, `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-03-PLAN.md`, `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 5` reports `phase_status: Planned`, `has_plans: true`, `plan_count: 4`, and `patterns_path` set; frontmatter scan passed for all four plans; requirement scan covered `EFFECT-02`, `EFFECT-03`, and `EFFECT-08`; `check.decision-coverage-plan` passed with 25/25 CONTEXT decisions covered; placeholder scan over Phase 5 pattern/plan files returned no matches; `git diff --check -- .planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow .planning/ROADMAP.md .planning/STATE.md PLANS.md` exited 0. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift or Xcode source changes. |

Outcome:

- Phase 5 now has `05-PATTERNS.md` and four executable plans in waves 1 through 4.
- `.planning/ROADMAP.md` now annotates Phase 5 wave dependencies.
- `.planning/STATE.md` marks Phase 5 as planned and ready to execute.
- Planning was performed inline because sub-agent spawning is available only when explicitly requested by the user in this Codex runtime.

### C-2026-06-19-gsd-ui-phase-5-filters-presets-resource-flow

| Field | Value |
| --- | --- |
| Completed | 2026-06-19 |
| Scope | Ran `$gsd-ui-phase 5` for Phase 5 and produced an approved SwiftUI UI design contract covering compact preset chips, color sliders, enabled Filters panel behavior, resource failure copy, spacing, typography, color, accessibility, and verification expectations. |
| Requirements | EFFECT-02, EFFECT-03, EFFECT-08 |
| Files | `.planning/milestones/v1.0-phases/05-filters-presets-and-resource-flow/05-UI-SPEC.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `gsd-ui-checker` approved all six dimensions: Copywriting, Visuals, Color, Typography, Spacing, and Registry Safety. |
| Build | Not run; this was a GSD UI contract/documentation workflow with no Swift or Xcode source changes. |

Outcome:

- Phase 5 now has an approved `05-UI-SPEC.md` for native SwiftUI implementation planning.
- The initial spacing blocker was resolved by removing non-scale `12px` spacing and keeping `44px` only as a touch-target height.
- Planner can proceed with `$gsd-plan-phase 5` using the UI contract as design context.

### C-2026-06-18-gsd-phase-4-detection-and-coordinate-safety

| Field | Value |
| --- | --- |
| Completed | 2026-06-18 |
| Scope | Executed GSD Phase 4: added public input metadata and detection summaries, internal face selection and Vision detector seams, canonical coordinate mapping, Demo metadata propagation, safe detection status/debug models, privacy scans, root contract docs, and final verification evidence. |
| Requirements | PIPE-05, PIPE-07 |
| Files | `BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`, `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`, `BeautySDK/Sources/BeautyDetection/*.swift`, `BeautySDK/Tests/**/*.swift`, `BeautyDemo/BeautyDemo/Camera/*.swift`, `BeautyDemo/BeautyDemo/Editor/*.swift`, `BeautyDemo/BeautyDemoTests/*.swift`, `.planning/milestones/v1.0-phases/04-detection-and-coordinate-safety/*-SUMMARY.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 55 XCTest cases; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 61 Demo XCTest cases; internal import scan returned no matches; public geometry/raw framework/path scan returned no matches. |
| Build | SDK SwiftPM tests and Demo simulator tests passed. |

Outcome:

- `BeautyInputMetadata` now carries orientation, input mirroring, preview mirroring, source, and timestamp through camera and photo processing paths.
- `BeautyDetectionSummary` exposes only availability, redacted reason codes, counts, and timings; public/Demo surfaces do not expose face geometry, raw Vision objects, raw framework errors, or local paths.
- `BeautyDetection` contains internal face observation, landmark, selection, Vision adapter, and coordinate mapper contracts with deterministic XCTest coverage.
- Demo camera and photo snapshots retain metadata and detection summaries through the public `BeautySDK` facade; status copy is nonblocking and privacy-safe.
- Remaining manual risk: real-device front-camera mirroring and real Vision quality still need hardware smoke checks. Repro steps are tracked in `TD-008`.

### C-2026-06-12-gsd-phase-3-realtime-and-still-input-slice

| Field | Value |
| --- | --- |
| Completed | 2026-06-12 |
| Scope | Executed GSD Phase 3: enabled local-first Camera and Photo input in `BeautyDemo`, added bounded realtime processing, still-image processing, shared compare state, protected-resource purpose strings, privacy/static tests, and root contract evidence. |
| Requirements | PIPE-01, PIPE-02, PIPE-03, PIPE-04, PIPE-06, PIPE-08, DEMO-01 |
| Files | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautyDemo/BeautyDemo/Camera/*.swift`, `BeautyDemo/BeautyDemo/Editor/*.swift`, `BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift`, `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift`, `BeautyDemo/BeautyDemoTests/*.swift`, `.planning/milestones/v1.0-phases/03-realtime-and-still-input-slice/*-SUMMARY.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer /usr/bin/xcrun simctl list devices available` listed `iPhone 17` on iOS 26.5; focused `xcodebuild ... -only-testing:BeautyDemoTests/InputPipelinePrivacyTests -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test` passed with 18 tests; full `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 55 Demo XCTest cases; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 20 XCTest cases; purpose-string `rg` found Debug and Release Camera/Photo strings; static scans for `UIImage`, internal SDK imports, and network/upload/raw path/error copy returned no matches. |
| Build | Demo simulator tests and SDK SwiftPM tests passed. |

Outcome:

- Camera and Photo are enabled mode switches on the first editor screen; Camera permission is requested only after selecting Camera.
- Camera preview setup uses BGRA sample-buffer pixel buffers, routes frames through `CameraBeautyPipeline`, bounds in-flight work, drops stale pending frames, and preserves the last usable preview on recoverable processing failure.
- Photo input supports fixture and PhotosPicker-data paths through `ImageEditorPipeline`; cancellation is a no-op, loading overlays previous visuals, decode failures preserve previous output, and stale work is ignored.
- Shared before/after compare toggles display only and does not reset mode, category, subcategory, or parameters.
- `InputPipelinePrivacyTests` makes PIPE-08 machine-checkable: generated purpose strings are exact and local-first, Demo/Test imports stay on the public `BeautySDK` facade, input paths contain no network/upload/raw path/error copy, and realtime Camera source has no `UIImage` conversion.
- Remaining risk: real hardware camera behavior, iOS Settings round-trip, real Photos picker user path, visual effect quality, performance budgets, and long-run memory remain future/manual gates.

### C-2026-06-11-gsd-phase-2-demo-integration-shell

| Field | Value |
| --- | --- |
| Completed | 2026-06-11 |
| Scope | Executed GSD Phase 2: wired `BeautyDemo` through the public `BeautySDK` facade, rendered the editor shell/category skeleton, and added deterministic Demo view-state tests. |
| Files | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`, `BeautyDemo/BeautyDemo/Panel/*.swift`, `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`, `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift`, `BeautyDemo/BeautyDemoTests/*.swift`, `.planning/milestones/v1.0-phases/02-demo-integration-shell/*-SUMMARY.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK` passed with 20 XCTest cases; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` listed targets `BeautyDemo`, `BeautyDemoTests` and schemes `BeautyDemo`, `BeautySDK`; simulator `xcodebuild build` and `xcodebuild test` passed for `platform=iOS Simulator,name=iPhone 17,OS=26.5` with 22 Demo XCTest cases; forbidden internal import scan returned no matches; `Hello, world!` scan returned no matches; media/network scan returned no matches; requirement trace scan found `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08`; `git diff --check` exited 0. |
| Build | SDK package tests and Demo simulator build/test passed. |

Outcome:

- Demo app/test target imports the public `BeautySDK` facade and no internal SDK targets.
- Editor shell now uses feature directories for App, Editor, Panel, State, and Support.
- Demo first screen renders a static preview fixture, disabled Camera/Photo entries, descriptor-driven category rail, active panel, sliders, reset controls, and honest disabled/future availability states.
- Top-level categories and Facial Features subcategories are represented through deterministic descriptors and covered by tests.
- App-side parameter display values clamp and normalize into public `BeautyParameters` snapshots, including single-reset and reset-all behavior.
- Phase 2 requirement IDs `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08` are complete in `.planning/REQUIREMENTS.md`.
- Reproducibility correction: commit `195f362` tracks the current `BeautySDK` package sources/tests on `main` and ignores SwiftPM `.build/` output; `swift test --package-path BeautySDK` passed with 20 XCTest cases after staging that file set.

### C-2026-06-11-gsd-phase-1-sdk-foundation

| Field | Value |
| --- | --- |
| Completed | 2026-06-11 |
| Scope | Executed GSD Phase 1: created the local `BeautySDK` Swift Package foundation, facade-accessible public models, preset validation, no-op engine/copy path, and foundation XCTest coverage. |
| Files | `BeautySDK/Package.swift`, `BeautySDK/Sources/**`, `BeautySDK/Tests/**`, `.planning/milestones/v1.0-phases/01-sdk-foundation-and-public-facade/*-SUMMARY.md`, `ARCHITECTURE.md`, `SECURITY.md`, `QUALITY_SCORE.md`, `PLANS.md` |
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

- FUTURE-04 后续覆盖：2026-09-25 自然风格生成肖像的冻结失败已由 2026-09-26 有界源边界对齐修复；原输入和阈值下公开 CPU 正负例、目标/保护区、neutral、repeat、alpha 已通过。后续代码生成测试还覆盖深色背景正例、低对比保护、短局部遮挡和明暗方向冲突；弱或矛盾证据按当前规则退出。taxonomy 的 owner-local 状态据生成输入证据提升，不追溯改写 v1.23 历史回执。未覆盖发丝/耳侧、复杂光照、更多肤色或大量不同肖像；真人图片和真实设备仍为可选补充，不是当前完成门禁。人口泛化、设备性能和商业视觉质量未经证明。
- FUTURE-06：已由 `C-2026-09-26-future06-skin-texture` 完成有界空间纹理语义和生成像素验收；2026-09-24 审计时仅有饱和度/对比度代理的旧判断保留为历史事实。皮肤语义分割、真人泛化和设备性能均未签发。
- FUTURE-07：Metal 几何组合超过 256 个点现已显式返回 `BeautyError.invalidInput`，不再静默跳过效果。公开 43 控件组合在两种现有完整生成/观测支撑上分别为 115/102 点，已通过实际 GPU 输出回归，原条件性风险在这些输入上未复现。尚无覆盖所有 Vision 观测形状及所有强度的全局点数上界证明；仅在发现可达超限公开组合时，再决定是否拆分或收紧组合契约，不把该未证风险写成已发生的用户故障。
- FUTURE-08：当前纹理滤镜无需人脸支撑，也没有皮肤语义分割；满足低对比门槛的非面部纹理仍可能变化。5×5 CPU 处理及额外源/结果 raster 的大图吞吐、峰值内存和设备耗电尚未测量。仅在需要更强局部保护或具体性能预算时，另立输入、保护区和资源验收契约；不影响本次生成输入的有界效果信用。

### Phase 95 evidence-chain follow-up (2026-09-13 historical finding)

2026-09-22 disposition: full-closeout现已实现，旧声明计数lane已禁用；下文为发现时记录。
当时未完成项是后继测量接入、当前证据与finalize实现；这些事项已由 v1.22 完成记录收尾，见`.planning/V1.22-CURRENT.md`。
历史boundary误报后续修订见上方2026-09-13/14检查点；此旧描述不是新的阻塞判定。

The existing untracked `check-phase95-closeout.py` is not a complete final
closeout implementation: its compatibility/safety baseline commands emit
declared counters without executing their corresponding SwiftPM gates, and
`full-closeout` is absent. The `closeout` command also does not enforce its
declared independent review binding. This was discovered during the Plan 03
semantic repair; no such counters or independent approval are credited in this
repair. Do not mark the milestone complete until the execution-bound evidence
chain and independent review are genuinely satisfied. Historical baseline files
are preserved rather than silently reissued as verified evidence.

Archive verification passed, but the SDK-only boundary check rejects the
existing compatibility test's literal backend-source search string as GPU API
drift. Inspection confirms a string assertion, not a new backend branch. Its
review/freeze binding belongs to Plan 01; do not hide the literal from the
scanner or rewrite the historical binding to claim success. A reviewed
compatibility-test/binding correction remains necessary for final closeout.

| ID | Area | Debt | Impact | Suggested Next Step | Status |
| --- | --- | --- | --- | --- | --- |
| TD-001 | Project Structure | 根目录不是 Git 仓库，`.git` 位于 `BeautyDemo/` 下。 | 根级文档变更不一定被当前 Git 仓库追踪。 | 已将 `/Users/yakangwang/codes/beauty` 初始化为仓库根；原 `BeautyDemo` Git 历史已备份到 `.codex-backups/BeautyDemo_git_before_root_init_20260525_190709/`。 | `completed` |
| TD-002 | SDK Package | `BeautySDK` Swift Package 尚未创建。 | 根级架构文档已定义目标结构，但代码仍只有 Demo 模板。 | Phase 1 已创建 SPM 与 facade / internal targets；后续按 roadmap 扩展真实检测、资源、效果和 Demo 集成。 | `completed` |
| TD-003 | Demo UI | Historical initialization debt: `BeautyDemo` began as the default SwiftUI template. | None for the shipped shell; current Demo contains Home/editor, camera/photo, panels, compare, debug, and JSON flows. | Preserve facade-only integration and keep unsupported features visibly unavailable. | `completed` |
| TD-004 | Tests | Historical v1.16/Phase-71/Phase-74 baselines remain frozen at 702/728/765 tests. The current post-audit wrapper executes XCTest `776/0/0`, eight opt-ins exactly once, and zero skips on a Metal-available package host. | All ten audit findings are mutation-gated under bounded contracts; device/product evidence remains separate. | Preserve archive, boundary, backend, parity, consumer, CPU-oracle, opt-in, and one-child ordering. | `completed-bounded-v1.17` |
| TD-005 | Privacy Manifest | Phase 25 `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` found no privacy manifest, and `25-SECURITY-CLOSEOUT.md` explicitly defers adding one for current SDK/Demo behavior. | Future collection, required-reason API usage, third-party SDKs, network/cloud/analytics behavior, packaged example executables, or packaging/submission work can reopen compliance risk. | Reopen the manifest review when behavior or distribution scope changes; run the recorded rerun protocol and `plutil` checks if a manifest is added. | `closed/current-evidence` |
| TD-006 | Historical Docs | `docs/` 下历史长文档与根级文档存在重叠。 | Agent 可能读取到旧结论。 | 已将 `docs/README.md` 设为长文档入口，并在 `QUALITY_SCORE.md` 中加入旧文件名、source import JSON、关键术语一致性扫描规则。 | `completed` |
| TD-007 | GSD Traceability | Historical v2 `ADV-01` through `ADV-10` remain in archived `.planning/milestones/v1.0-REQUIREMENTS.md`, not in an active root requirements file. | No current audit warning or active traceability ambiguity remains after milestone archival. | Keep them historical/backlog-only unless a future milestone explicitly promotes one. | `completed` |
| TD-008 | Manual Device QA | Simulator, physical-iPhone, live-camera endurance, and 600-second preview evidence are not part of the current SDK algorithm/pipeline objective. | No impact on the planned SwiftPM CPU/GPU correctness claims; these checks would matter only for a future realtime/device or shipping milestone. | Keep explicitly out of scope and reopen only if realtime device behavior, performance budgets, or release claims are authorized. | `out-of-scope/sdk-first` |
| TD-009 | Historical UI QA | Application layout, screenshots, and UI automation belong to the retired legacy material. | No impact on SDK algorithm or renderer-output acceptance. | Review only through `archives/legacy-ui/README.md` in a temporary directory; do not reactivate UI validation. | `out-of-scope/archived` |
| TD-010 | Algorithm Output and Hardware QA | Generated CPU/Metal package-host comparison and all F-01 through F-10 dispositions now exist. Demo screenshots, physical-device testing, commercial review, packaging, and shipping remain separate scopes. | The bounded contracts intentionally exclude transparent input, end-to-end GPU local-retouch ownership, shared-instance parallel safety, and device/product claims. | Preserve the CPU oracle and bounded parity gate; authorize a new milestone before widening any excluded claim. | `completed-bounded/post-v1.17-audit` |
| TD-011 | Codebase Maps | Current structure/stack/testing maps were refreshed from the post-archive SDK-only tree on 2026-08-18. | No current stale application/test inventory or unresolved audit finding remains. | Refresh maps after material package, dependency, source-layout, test, or audit-status changes. | `completed` |
| TD-012 | Input Bounds | Public 32 MiB encoded and 50,000,000-pixel ceilings are source-/legacy-Codable-compatible and enforced at SDK plus current Demo boundaries. | PhotosPicker still materializes `Data` before the Demo can observe its size; downstream decode/render amplification is bounded. | Revisit only if a future transfer API exposes a pre-materialization size boundary. | `completed` |
| TD-013 | Public Concurrency | The unconditional arbitrary-payload `@unchecked Sendable` declaration was a public trust-boundary defect. | Resolved by the conditional `Output: Sendable` conformance, public compile/runtime transfer coverage, and boundary mutation rejection. | Preserve the conditional contract; reopen only if a future public result payload or backend boundary changes the concurrency model. | `completed-phase-69` |
| TD-014 | Legacy Application/UI Tree | The two original legacy roots were preserved in verified ZIP/manifests/digest records and removed by the exact digest-bound transaction. | No active application/UI source remains; accidental restoration would violate the SDK-only boundary. | Keep archive verification and post-archive scanning in the mandatory no-skip gate. | `completed-phase-66` |
| TD-015 | Render Backend | v1.17 delivered selectable `.cpu`/`.gpu` policy, package Metal runtime/passes, and bounded generated parity while retaining CPU as the oracle; the post-archive audit findings now have explicit dispositions. | The supported package-host contract is complete, but it intentionally excludes transparent input, end-to-end GPU local-retouch ownership, shared-instance parallel safety, and device/release evidence. | Preserve the bounded selectable-backend contract; require a new authorized milestone for broader claims. | `completed-bounded-contract` |
| TD-016 | Metal Local Retouch | F-02 is resolved as CPU-owned immutable-original/Q16 composition followed by identity Metal transport; masks, proposals, and support never enter Metal. | The `.gpu` path intentionally does not claim end-to-end GPU ownership for teeth/sclera retouch. | Preserve the ownership marker and mutation gate; add genuine GPU composition only in a separately authorized milestone. | `completed-narrowed-contract` |
| TD-017 | Still-Image Compatibility | F-04/F-05 are resolved as exact-opaque bounded non-extended RGB GPU input, named-sRGB output, and CPU-oracle Metal coefficient/lip math within max `<=2` / mean `<0.75`. | Transparent input remains unsupported; licensed/real-fixture and device evidence remain outside this generated package-host contract. | Preserve pre-detection rejection, named-sRGB output, shader pin, and tight generated oracle gate. | `completed-bounded-contract` |
| TD-018 | Parity Oracle Provenance | F-09 found that geometry safety parity derived its locality envelope from a separately generated face observation rather than the observation used by the rendered request. | Resolved: one immutable observation now owns geometry, plan, points, envelope, and request support, and the parity self-test rejects broken provenance. | Preserve the request equality proof and mutation-tested static gate. | `completed-followup` |
| TD-019 | Shared Runtime Concurrency | F-10 is resolved by documenting `BeautyEngine` as intentionally non-`Sendable`: callers serialize every `process`/`processResult`/`reset` access per instance, while independent instances may execute concurrently. | Same-instance parallel execution remains unsupported rather than unproven. | Preserve the exact public doc, negative sendability gate, serialized harness evidence, and independent-instance test. | `completed-bounded-contract` |
| TD-020 | v1.18 Decision Binding | The post-archive re-audit found that Phase 79 read mutable Phase-78 verification prose instead of consuming a machine-produced decision report and contract hash. | Resolved by `scripts/check-v1-18-decision-binding.py`: direct machine decision, strict schema/contract hash, exact no-bundle branch, and seven decision mutations. | Preserve commit `b45fe59` and the current exact-absence gate. | `completed-post-v1.18-reaudit` |
| TD-021 | v1.18 Support/Editor Integration | Phase-76 support and Phase-77 editor mechanics lacked a caller/test connecting one observation through support resolution, editor proposals, and immutable-source composition. | Resolved by the test-only package integration suite: 3/3 integration and 25/25 UpperEyelid tests pass with no public route. | Preserve commit `2d0f83b` and the package-only boundary. | `completed-post-v1.18-reaudit` |
| TD-022 | v1.18 Audit Reproducibility | The archived Phase-79 checker was cwd/path dependent and Phase 78 named rather than version-bound the Phase-77 baseline. | Resolved by pinned source/evidence digests, ten-test binding, seven archive-resolution checks, a 10/10 wrapper mutation gate, and current 800/0/0 closeout. | Preserve commits `876499a` and `a89e475`; keep immutable archives read-only. | `completed-post-v1.18-reaudit` |
| TD-023 | Multi-Face Documentation Contract | 原 `DESIGN.md` 将 `maximumFaceCount` 错写为每帧最多处理的脸数；既有 Phase04 测试与代码实际约束检测选入数，公开效果只消费主脸。 | `usedFaceCount` 原易被误读为效果处理脸数。 | 已纠正 `DESIGN.md` 与 `PRODUCT_SENSE.md`，保留11配置字段、单主脸效果与检测器原选择行为。 | `completed-documentation-correction` |
| TD-024 | Cross-Face Mapping Isolation | 原 `VisionFaceDetector.summarize` 在同一 throwing map 中映射全部候选，一张坏脸会抹去独立有效脸。 | 有效主脸可能在选脸前被坏观测连带抑制。 | 已逐脸隔离失败，双顺序及双检测purpose确定性回归通过；完整no-skip 938/0/0。 | `completed-source-repair` |

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
| Swift code compiles | Exact `swift build` or `swift test` command with exit status. |
| Historical UI material is readable | Archive verification plus temporary-directory restoration evidence. |
| Performance target met | Device/simulator, resolution, duration, metric result. |
| Security constraint met | Specific validation/logging/resource test. |

不要把未经验证的主观判断写成验证结论。
# Completed: Phase 34 Mouth Safety, Degradation, and Ledger Closeout

#### Phase 34 Execution Evidence

`gsd-execute-phase-34` completed MOUTH-05 through MOUTH-10 and DOC-01. Command-backed details are archived in `.planning/milestones/v1.8-phases/34-mouth-safety-degradation-and-ledger-closeout/34-MOUTH-SAFETY-EVIDENCE.md`.

full_suite_tests: 190

- Focused mouth tests: 13/13; renderer helper: 238/238 outputs, 30/30 geometry, 12/12 signed pairs, 6/6 lip color.
- Review clean; `threats_open: 0`; `unclassified_matches: 0`; no internal Demo/renderer imports, network/cloud, commercial/VIP/entitlement, new dependencies/public fields, or tracked generated files.
- Exactly `大小`, `宽度`, and `微笑` are promoted. `嘴唇` remains partial; `lipColor` is not true `丰唇`.
- No Demo build was required because Demo source was unchanged. Device/commercial visual, packaging, and launch-readiness claims remain out of scope.
### C-2026-08-22-phase-78-genuine-evaluation-and-candidate-decision

| Field | Value |
| --- | --- |
| Completed | 2026-08-22 |
| Scope | Integrate the frozen genuine-evidence evaluator, reject unapproved comparators, and produce the Phase 79 recommendation. |
| Files | `.planning/phases/78-genuine-evaluation-and-candidate-decision/`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md` |
| Verification | Candidate Node suite 6/0/0; evaluator self-test 12 checks/8 mutation rejections; boundary checker 8/8 and live pass; full no-skip 797/0/0; exact public 61/5/74; `git diff --check` passed. |
| Build | `bash scripts/run-no-skip-swiftpm.sh` passed with all opt-ins once and zero skips. |

Outcome:

- The Phase 75 evaluator remains authoritative; metadata-only evidence is mechanics-only.
- The deterministic editor is the baseline and the optional additive comparator is `not-admitted` without complete rights/safety/superiority proof.
- The single recommendation is `mechanics-only-not-promotion`; no genuine efficacy, naturalness, or public activation claim is made. Phase 79 owns exact failing-branch closeout.

### C-2026-08-22-phase-79-conditional-productization-and-sdk-only-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-22 |
| Scope | Consume the Phase-78 decision, materialize the failing public-absence branch, synchronize contract owners, and close v1.18 SDK-only validation. |
| Files | `.planning/phases/79-conditional-productization-and-sdk-only-closeout/`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `DESIGN.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `docs/README.md`, `docs/SDK_EFFECT_TAXONOMY.md`, `PLANS.md` |
| Verification | Phase-79 checker self-test rejected 8/8 mutations and live mode passed; exact public 61/5/74; full no-skip 797/0/0; all eight opt-ins exactly once; `git diff --check` passed. |
| Build | `bash scripts/run-no-skip-swiftpm.sh` passed with zero failures and zero skips; available-host parity executed 13/0/0 with no fallback. |

Outcome:

- `mechanics-only-not-promotion` selects verified exact public absence: no field, renderer case, route, resource, package dependency, or public/SPI activation was added.
- `去脂` remains future and `眼睛` remains partial. QUAL-01/02 are explicitly not satisfied because the required genuine bundle and blinded review were not supplied.
- CPU authority, selected GPU behavior, terminal `.metalUnavailable`, canonical image metadata, privacy, and all device/commercial/release nonclaims remain intact.

## Phase94 Historical Final Owner Snapshot (2026-09-11)

以下是当时封存条件，不要求后续PLANS停止记账；按对应历史版本复核，当前代码由Phase95重新验收。

Status: verifying (snapshot before independent goal decision). MOUTH-01 has
current41/41 acceptance and independent implementation review at CHECKS SHA256
`fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`.
Current Phase94 completion is determined solely by a valid current
`94-REMAINING-COMPLETE.json`; absent, stale or failed evidence means incomplete.
The final seven-owner binding includes this entire PLANS file without hash
normalization. Goal verification and receipt-only finalize must preserve these
bytes. Phase95 private portraits/final65/full no-skip remain separate; no device,
commercial or distribution qualification is granted.
