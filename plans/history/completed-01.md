# Completed records 01



### C-2026-09-27-remaining-sdk-effects-and-risks

- Status: completed。所有者要求在现有 owner-local SDK 边界内逐项完成本账本剩余效果、配置与条件性风险。每项先固定独立语义、正负例、目标/保护区、元数据、确定性和 typed failure 验收，再修改实现；完成一项即记录对应验证，不以其他项的通过代替。历史回执与归档只读。对缺少头发/颏下语义支撑的五项，所有者明确选择独立二维像素效果且保留 taxonomy `partial`，待更广肖像验收。
- 下列嵌套进度、失败与“待运行”句子记录各自检查点的当时状态；本计划的最终状态与完整门禁结果以末项为准。
- [x] 校正 `.planning/STATE.md` 的现行 FACE-01 描述，保留 v1.23 签名快照的历史含义。未跟踪的 `.gsd/dispatch-isolation-sentinel.json`、`.planning/milestone.lock` 和旧 Phase 96 计划/尝试日志属于工作流材料；当前任务不删除或覆盖。`git diff --check` 通过。
- [x] FUTURE-04：扩充 FACE-01 发丝/耳侧、复杂光照、更多肤色和多样生成肖像的方向与保护区验收；不把有限输入结果写成人口泛化或商业质量。
  - 2026-09-26 完成追加验收：冻结的第二组自然风格生成正负例在不改源身份、ROI 或阈值下通过公开 CPU oracle。正例右侧粗糙度 `5.150→4.206`（至少改善 10%），平滑负例 `3.194→3.194`；正例目标/总变化 `7802/7802`，两图发丝及保护区变化均为 0，neutral、repeat、alpha 通过。按肤色、相反明暗背景、短及持续发丝遮挡补充的内存生成测试覆盖整侧安全退出和未遮挡侧继续处理；CPU 与 Metal 共用遮挡侧控制点筛选。FACE-01 相关聚焦 `23/0/0`，完整 archive-first no-skip 命令返回 0、8 opt-in 全执行、0 skip，SDK-owned 前置检查通过。只授予这些生成输入的 owner-local 效果证据，不推断群体、设备或商业视觉质量。
  - 进行中：新增深/中/浅三组代码生成肤色粗糙正例和平滑负例、左右相反明暗背景及上耳保护、短段深色发丝跨边界保护。发丝例首次复现 90 个受保护行变化像素；竞争边缘阈值由 75% 收紧到 40%，使该行退出且相邻脸颊仍变化。局部测试类 `11/0/0`，公开 facade 方向/镜像/错误恢复 `2/0/0`；原冻结生成肖像公开 CPU oracle 在相同输入与阈值下仍通过（粗糙正例双侧 `6.106/6.731 → 4.000/5.044`，平滑负例 `2.806/2.638 → 2.431/2.331`，保护区 0、neutral/repeat/alpha 通过）。当前树完整 no-skip `977/0/0`、8 opt-in、0 skip；更多自然风格肖像仍待验收。
  - 新自然风格生成正负例在同一虚构成人的深肤色、斜光和发丝条件下，先经源图预检入选（右侧粗糙度 `5.150/3.194`）；修复前公开 CPU 探针失败：正例右侧仍为 `5.150`，左侧暗发丝保护区变化 62 像素。neutral/repeat/alpha 通过，负例未恶化。源身份、ROI 与阈值固定在 `scripts/check-face01-diversity-effect.swift`，图片只保留在忽略的本地输入目录。下一步修复复杂光照方向判断和发丝行回退，不用旧肖像通过替代新失败。
  - 曾试验按邻域色度区分深发丝与脸侧的候选，旧 FACE-01 聚焦测试虽通过 `11/0/0`，新自然风格肖像右侧仍无改善且发丝变化扩大至 507 像素；候选已完全撤回，冻结失败输入和阈值保留。此失败不计为 FUTURE-04 完成。
- [x] 去脂：保持 provisional 安全边界，用代码生成的混合明暗凸起正例与平面/细皱纹负例补强逐眼判定，并以自然风格生成肖像检查实际像素。
  - 旧均值门在新自然风格生成肖像左眼得分 `0.789` 而拒绝，右眼 `9.490` 通过；左眼中心残差上四分位 `8.174`、达旧阈值的面积约 39%。新增局部凸起备用判定：均值非负、上四分位至少 8、中心至少 35% 像素超过旧凸起阈值，仍须每眼独立通过既有语义、范围和源图边界。代码生成混合明暗凸起正例旧均值 `3.158 < 3.5`，新门通过且校正后局部凸起下降至少 15%；平面光照/细皱纹负例不通过。`BeautyUpperEyelidFullnessEditorTests` `8/0/0`。
  - 同一忽略目录中的生成自然风格肖像经公开 CPU renderer 重渲染，左/右上睑分别变化 `3884/3920` 像素，单通道最大变化 16；左眼在旧代码为 0，右眼输出保持一致，远背景 0。原尺寸目视仍属温和变化，保持 provisional，不声称广泛肖像或商业视觉质量。最终完整门禁尚待运行；原图、输出与像素位置不入持久证据。
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
- [x] FUTURE-08：纹理滤镜已新增代码生成的冷色低对比非面部负例，旧实现每个控制在保护区改变 132 像素；窄色彩保护后深浅肤色目标仍变化、冷色背景 0 变化，生成纹理 suite `8/0/0`。活跃纹理请求另设 8,388,608 像素上限，编码声明前置、解码/像素缓冲区和 backend request 复核，超限 typed `invalidInput`、随后小图恢复；生成的大尺寸编码 PNG 声明预检及恢复通过，backend/encoded/texture 聚焦 `24/0/0`。当时完整 archive-first no-skip `1008/0/0`、8 opt-in、0 skip。CPU 静态图纹理步骤拥有的三个 RGBA8 buffer 合计至多 96 MiB，Core Image/系统、Metal 附加 buffer 峰值及设备性能未测。当时暖色等非面部低对比纹理仍可能变化，故继续追加新鲜人脸支撑与保护区。
  - 现已让公开静态图和像素缓冲区的活跃纹理请求获取本次 Vision 人脸，CPU/Metal 共用其人脸框内部 `0.43×` 椭圆处理域；缺脸、禁用或跳帧时纹理源图一致，其他色彩控制独立。生成暖色低对比背景和深浅脸颊目标验收通过，静态图与像素缓冲区正例、负例、alpha、方向镜像、重复、typed 上限/恢复及可用 GPU 对齐聚焦纹理 suite `11/0/0`，含同一 Engine 缺脸/有脸/缺脸、禁用检测和索引跳帧；相关检测/质量/Engine suite `39/0/1 skipped`（未启用 opt-in）。无解剖皮肤分割，脸域内部相似颜色的非皮肤内容仍可能变化；不作设备时间或总峰值内存声明。
  - 首次广域诊断（暂跳过慢速性能专项）只发现此前 77 字段新增后残留的配置/预设测试旧 68 字段断言；已修正，配置和资源目录 `25/0/0`。post-archive SDK-only boundary 已通过，完整 no-skip 留待所有改动后运行。
  - 最终追加脸框相对的宽眼/睑和唇部源图保护区。低对比暖色纹理特征负例在双控制下保持源图一致、脸颊正例变化，生成 suite `12/0/0`；一张自然风格生成肖像重渲染的双侧脸颊所选区域分别变化 `15203/15060` 像素，所选双眼、唇核、发丝和远背景区域均为 0。对脸域内其他非皮肤内容仍无语义分割承诺；最终完整门禁见本计划末行。
- [x] 比例「小头」：实现独立于现有 `faceSmall` 的中性比例语义和像素验收；taxonomy 按所有者选择保留 `partial`。
  - `headSmall` 已作为独立于 `faceSmall` 的正向四点二维局部缩小控制接入，生成公开标记方向、保护区、neutral/no-face/方向镜像/repeat/Codable/typed failure 聚焦 `2/0/0`；更广肖像、真实头发与颅骨语义前 taxonomy 保持 `partial`。
- [x] 3D 塑颜：分别定义并实现「对称」「上下」「左右」「倾斜」四项中性整体几何控制。
  - 「对称」新增 `wholeFaceSymmetry`，仅在有效观察轮廓左右宽度差达到阈值时发出两点有界二维修正；对称负例不发点。生成公开像素/保护区及四方向镜像、neutral/no-face/repeat/Codable/typed failure `3/0/0`；不声称 3D 效果，taxonomy 暂记 `partial`。最终门禁待运行。
  - 「倾斜」候选契约：新增 `wholeFaceTilt` 签名字段，零值源图一致；正值在规范图像坐标中局部顺时针，负值逆时针。以脸框中心和四个有界局部锚点构成二维图像平面旋转，不宣称三维头部姿态或深度。先固定顶部与左侧两个不同颜色生成标记的正反移动、远背景/alpha/extent、重复、缺脸退出和 Codable 中性兼容，再接入 resolver、冲突缩放与 CPU/Metal 共享几何。此公开验收在未实现字段时按预期编译失败；更多肖像证据前 taxonomy 至多 `partial`。
  - 「倾斜」当前进度：新字段、解析/冲突缩放、四点有界旋转、renderer 正负案例和当前清单已接入。公开生成标记方向、方向/镜像、neutral、repeat、外部/alpha、无脸和 typed failure/recovery `3/0/0`，provider `21/0/0`，Metal 47 行点预算 `7/0/0`，renderer/去脂集成过滤 `53/0/0`。首次完整门禁发现一个旧 64 字段断言并已更新为 65；最终完整 archive-first no-skip `1001/0/0`、8 opt-in、0 skip，各专项与 SDK-only 边界通过。当前 taxonomy 仅记二维 `partial`，不认定 3D 姿态或广泛肖像效果。
  - 首项「上下」候选契约：公开 `wholeFaceYPosition` 签名强度，零值源图一致；正值在图像坐标中向下、负值向上。使用已选人脸的有界局部像素变形，不宣称深度/三维网格。生成脸部标记正反方向须沿期望方向移动至少 1 像素，图像远背景与 alpha 保持，缺失/无效人脸按现有 face-shape 规则退出；方向镜像、元数据、重复性、组合和 typed failure 按公开 SDK 路径验收。若所有者要求真正三维效果，替换此候选契约，不用二维结果冒充。
  - 进行中：`wholeFaceYPosition` 已接入公开参数、解析、冲突缩放和 face-shape 点，正负两项 renderer case。公开生成标记 `4/0/0`，含参数/Codable、正反方向、四方向×输入镜像、neutral、repeat、extent、远背景/alpha、无脸和 typed failure/recovery；provider `19/0/0`、Metal 几何 `7/0/0` 覆盖有界点及当前 45 行组合；post-archive SDK 边界通过。首次完整 no-skip 发现九项旧 62/75 当前清单断言，已保留 Phase 95 冻结投影并修正当前清单，相关聚焦 `55/0/0`；最终完整 no-skip `977/0/0`、8 opt-in、0 skip，archive-first 及所有专项通过。当前只对这组二维像素授予方向证据，taxonomy 标为 `partial`；更多肖像仍待验收。
  - 「左右」候选契约：`wholeFaceXPosition` 为独立签名强度，零值源图一致；正值在图像坐标中向右、负值向左。仅对已选人脸执行有界二维局部位移，不能称为深度或三维网格。先固定生成标记的正反方向至少 1 像素、远背景/alpha/extent、四方向和输入镜像、neutral/repeat、无脸退出及 typed failure/recovery；参数、Codable、冲突缩放、Metal 点预算和 renderer inventory 均须回归。更多肖像验收前 taxonomy 最多 `partial`。
  - 进行中：新增公开字段、解析/冲突缩放、face-shape 有界水平点与正负 renderer case。实现前公开测试因字段不存在按预期编译失败；实现后新公开像素 `4/0/0`。当前清单的 40 条失败均来自旧 63 字段或 77 renderer case 数量断言，已按 64/79 现行数量修正并保留 Phase 95 的 62 字段冻结投影；参数、renderer、资源、provider 和当前 Metal 点组合聚焦 `137/0/0`，post-archive SDK boundary 通过。首次完整门禁在遗漏的配置测试旧 63 字段断言停止，补正后配置专项 `20/0/0`；最终完整 archive-first no-skip `984/0/0`、8 opt-in、0 skip。taxonomy 保留 `partial`，更多肖像仍待验收。
- [x] 比例：分别定义并实现「头包脸」「颅顶」「额头」「中庭」「人中」「下庭」「短脸」七项控制。
  - 「短脸」候选契约：独立正向 `faceShortening`，零值逐像素保留；对足够纵长的已选脸框，上额与下巴两个源区沿图像纵轴相向移动，中心参考区和远背景保持，整体可测上下标记距离缩短。以有界二维 Warp 点实现，不能称为头骨缩短或三维形变。先用内存生成标记固定方向/负例/保护区、方向镜像、重复、无脸、alpha/extent 与 typed failure，再接参数解析、冲突缩放和 CPU/Metal 同源点；更广肖像证据前 taxonomy 至多 `partial`。
  - 「短脸」已接入独立公开字段、有效强度上限 `0.30`、脸框纵横比保护、两点相向局部变形及 CPU/Metal 共享点源。生成公开像素、参数/Codable、方向镜像、neutral/repeat、中心/远背景/alpha/extent、无脸与 typed failure/recovery `3/0/0`，当前参数/资源/renderer/provider/Metal 清单聚焦 `90/0/0`。完整 archive-first no-skip `1012/0/0`、8 opt-in、0 skip；taxonomy 仅升至二维 `partial`，仍需自然肖像覆盖。
  - 「额头」「中庭」候选契约：独立签名 `foreheadHeight` 与 `midfaceLength`，零值源图一致；前者正值将脸框上部中央局部区域上移，负值下移，后者正值将眉眼与鼻部之间的中段局部区域下移，负值上移。仅在已选有效脸框与 contour 内发出各自有界二维控制点，不声称头骨结构或三维比例。先用三色内存生成图锁定两处标记的正反方向、互不串扰的保护标记、远背景/alpha/extent、方向镜像、重复、缺脸、Codable 与 typed failure，然后接入 resolver、冲突缩放、CPU/Metal 共享点和当前清单。更广肖像验收前 taxonomy 至多 `partial`。
  - 「额头」「中庭」已接入独立公开签名字段、`±0.30` 有效上限和共享 CPU/Metal 点源。预实现公开测试按预期因字段缺失失败，接入后两处标记的正反方向、互相保护、远背景/alpha/extent、四方向×镜像、neutral/repeat、缺脸、Codable 与 typed failure/recovery `4/0/0`。当前清单/renderer/provider/Metal 聚焦组合 152 项仅有一条旧 66 字段断言失败，修正后去脂集成 `5/0/0`，SDK-only post-archive 边界通过；完整 archive-first no-skip `1017/0/0`、8 opt-in、0 skip。taxonomy 仅记二维 `partial`，尚无自然肖像泛化证据。
  - 「头包脸」「颅顶」各自新增 `headWrap`、`cranialCrownHeight` 有界上侧二维局部点，前者正值左右外移、后者正负值上下移动。生成公开标记及保护区/元数据/失败恢复 `2/0/0`，provider 有界点和缺脸退出 `1/0/0`；无头发分割与颅骨语义，taxonomy 均暂记 `partial`。
  - 「人中」「下庭」按所有者选择的独立二维像素口径，新增签名 `philtrumLength` 和 `lowerFaceLength`；前者仅在有效鼻尖—上唇间距中发点，后者仅在嘴唇—下巴间距中发点，正值向下、负值向上。目标标记正负方向、相互保护、远背景/alpha/extent、四方向×镜像、neutral/repeat、缺脸、旧 JSON 默认值及 typed failure/recovery 公开测试 `2/0/0`，provider `1/0/0`、参数清单 `50/0/0`、旧字段投影 `4/0/0`、renderer 回归 `24/0/0`。taxonomy 暂记二维 `partial`；更广肖像及最终 no-skip 尚待完成。
- [x] 脸型：分别定义并实现「去双下巴」「去双下巴 Pro」「发际线」三项局部效果，沿用已授权的 request-local 二维语义支撑。
  - 「去双下巴」新增 `doubleChinReduction` 单点下颏上提，「去双下巴 Pro」新增独立 `doubleChinReductionPro` 三点上提与两侧内收；均只用已有几何，不调用模型、权重或新资源。两档生成公开像素均使下颏目标上移，Pro 相对基础档有独立两侧变化；上脸/远背景/alpha 保护、neutral/no-face/方向镜像/repeat/Codable/typed failure `3/0/0`，provider 点数/方向/对称负例 `1/0/0`。taxonomy 暂记二维 `partial`，不声称已分割或去除颏下脂肪。
  - 现行 77 字段、99 渲染案例及 Metal 点预算清单已同步；公开/参数/兼容/CLI/Metal 聚焦联合 `104/0/0`，post-archive SDK-only 边界通过。最终 archive-first no-skip 尚待其余风险项收敛后运行。
  - 「发际线」按独立二维边界点口径新增 `hairlineHeight`，两侧上脸点随签名强度反向移动。生成公开标记方向、外部与中央保护、alpha/extent、镜像/方向、neutral/no-face/repeat/Codable/typed failure `2/0/0`；不声称已识别真实发际线，taxonomy 暂记 `partial`。
  - 现行 Metal 几何组合清单已纳入上述六个新参数行，聚焦 `9/0/0`；当前 74 字段参数、96 渲染案例、公开像素和旧字段投影聚焦 `94/0/0`，post-archive SDK 边界通过。完整 no-skip 留待全项收敛后运行。
- [x] 每项效果经公开输入/输出像素与元数据验收后更新 taxonomy、产品/设计/安全/可靠性 owner；最终 `bash scripts/run-no-skip-swiftpm.sh` 返回 0，archive-first 和 SDK-owned 前置检查通过，SwiftPM `1032/0/0`，8 opt-in 全执行、0 skip；`git diff --check` 通过。现行 77 字段、99 渲染案例；taxonomy 0 项 `future`、15 项二维效果 `partial`。去脂继续遵守已接受的 provisional 视觉质量边界；更广肖像语义与真实设备数据均未签发。


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
- 新建 [`docs/IMAGE_EFFECT_ACCEPTANCE.md`](../../docs/IMAGE_EFFECT_ACCEPTANCE.md) 作为统一政策；同步 `AGENTS.md`、根级 owner、taxonomy、当前 GSD project/requirements/roadmap/state 与 v1.23/v1.24 当前说明、示例图与授权说明、blueprint 入口和项目级 local-retouch skill。历史签发回执、归档和已完成阶段证据保持原貌。
- 生成正/负例仍须源图先行目标/保护区、效果方向、负例与不恶化、真实输出像素/元数据、确定性和错误恢复；原 v1.23 两图回执因未测试这些效果谓词继续保持有界机械结论，不能仅凭换政策追认。
- 验证：当前规范性用语扫描、14 个关键政策文档的存在与引用检查、`git diff --check` 通过。纯文档/skill 文本修改，未运行 SwiftPM；此前代码修复的 `951/0/0` 门禁仍是独立历史验证，不冒充本次验证。

### C-2026-09-24-audit-repair

- Status: completed；用户将 `fix all` 限定为本次审计的代码、测试、文档和脚本问题，14 项 future 功能及真人像效果另立范围。
- 修复 still-image 高光/阴影空操作、EXIF 非法枚举回落、像素上限与后端硬限不一致、无效尺寸晚拒绝、Metal 组合点数超限静默跳过；配置未执行字段与 skin 色彩代理改为真实声明，更新 taxonomy 的 v1.23 状态。
- 过期 Phase 96 本地续跑脚本在任何写入或批处理前返回 `phase96_superseded` / exit 2；更新三个专项门禁的旧静态断言与测试数。
- 验证：archive-first no-skip 完整门禁 `951/0/0`、8 opt-in、0 skip；最终加强的 parity 测试再由 13 项专项门禁确认；`bash -n`、过期脚本 fail-closed 检查、`git diff --check` 通过。详见 `QUALITY_SCORE.md`。
- 未纳入本轮：FUTURE-04 真人像效果、FUTURE-05 保留配置字段行为、FUTURE-06 真实空间纹理算法及 taxonomy 其余 future 项。

### C-2026-09-24-v1.24-upper-eyelid-effect-improvement

- Status: completed（有界生成输入机制改进）；[冻结目标、源码身份与聚合证据](../../.planning/V1.24-UPPER-EYELID-CURRENT.md)。全强度旧夹具比值 `0.1068` 接近地板，改以半强度旧比值 `0.4537424`，固定目标 `≤0.35` 且多改善至少 10 个百分点；新比值 `0.3422654`，改善 `0.1114770`。
- [x] Phase 97：冻结旧实现 commit/editor hash；固定目标测试在旧实现上失败。复审指出统一变暗反例缺口，补半强度非均匀修正、公开保护像素与双眼独立性 oracle。
- [x] Phase 98：只将 `BeautyExperimentalUpperEyelidReliefEditor` 内部 gain `1.5 → 1.8`，公开参数、双 still-image 入口、62/5/75 兼容及 fail-closed 边界不变；聚焦编辑器/公开测试 `12/0/0`。
- [x] Phase 99：初次 `945/0/0` 是复审补测前的中间门禁；最终源码重跑 archive-first no-skip 完整 SDK 门禁，归档、SDK-only、后端/Metal、consumer、CPU-reference、8 项 opt-in 均通过，非零 SwiftPM 测试、0 失败、0 skip。二次[独立只读复审](../../.planning/V1.24-INDEPENDENT-REVIEW.md)无剩余 Swift 问题；`git diff --check` 通过。
- 边界：只签发生成输入像素机制改进，不能宣称真实人像视觉有效或商业质量；去脂仍为效果偏弱的 provisional owner-local API。`faceContourSmooth` 真实人像效果继续留在 FUTURE-04；历史 Phase 96 草稿与签发回执未改。

### C-2026-09-24-face-contour-synthetic-mechanics

- Status: completed（2026-09-24，`synthetic-mechanics-only`）；所有者接受两张生成图作为有界机制验收输入。v1.22 原快照和映射修复追加式验收各自保留，不回写历史 Phase90/95 回执。
- [x] 核对现行 taxonomy、FUTURE-04、Phase89 manifest、portrait comparator、SwiftPM 冻结测试及当前 provider：数值契约一致，但逐行整数像素重心的二阶差分大量计入几何直线段的栅格阶梯；五个仅按轮廓曲率构造的候选均未通过。
- [x] 独立生成输入的亚像素机制改善原冻结指标并守住目标与保护区；探索值和正式 SwiftPM 验收已分开记录，见 [v1.23 当前契约与证据](../../.planning/V1.23-FACE01-CURRENT.md)。
- [x] 在现有 SDK/后端内接入双侧外轮廓的有界候选，保留原 `+16 Q16` 八项阈值；生成 SwiftPM、公开 facade 像素/恢复、CPU/Metal still-image 对比、尺寸/alpha 通过。稀疏轮廓使 44 字段合并测试漏掉 FACE-01，已修正并通过该 17 项测试类。
- [x] 补充独立生成剪影边界测试，不复用条纹重心指标：已知轮廓就近取整的粗糙正例平均边缘二阶差分约 `0.709 → 0.172`，平直轮廓负例保持原图，重复输出和中央/背景保护通过。原候选对内收取整边缘从约 `0.706` 恶化到 `1.213`，因此新增只在单一强边缘可辨时使用源像素边界的有界对齐；当前正例两种取整方式都降至源粗糙度一半以下，原冻结八谓词不变且 8 项 FACE-01 聚焦测试通过。仍不能替代真人像效果验收，详情见 [v1.23 当前契约与证据](../../.planning/V1.23-FACE01-CURRENT.md)。
- 原始效果目标延期：在真实人像预注册的轮廓与图像边界上确认像素对齐不会使粗糙度恶化；生成两种对齐方式已通过，但没有粗糙真人像正例，不能签发效果信用。
- [x] 识别真实人像验收契约问题：历史 comparator 未给 FACE-01 登记人像 ROI，65/65 双次输出中其他七方向仍通过，FACE-01 的 5,647 个变化像素被旧固定区全部误计在中央；源图先行的临时 ROI 探针将它们归入脸侧目标且区外为 0，但连续性与 sibling 均为 `0 Q16`，未达到原门槛。该诊断批次早于后续仅影响稀疏轮廓的修正，不是最终源码身份的签发回执；临时探针已移除，历史比较器/回执不改。
- 原始效果目标延期：用权利明确且确有粗糙脸侧轮廓的正例和平滑负例，预注册源图目标与保护区，验证真实边缘/纹理的可见改善及方向；在此之前 taxonomy 维持 `partial`，不以生成夹具或像素信号代替效果信用。
- [x] 最终源码重跑 archive-first no-skip 完整门禁：源边缘对齐修复后 SwiftPM `944/0/0`，8 项 opt-in 全执行、0 skip，归档、SDK-only、后端/Metal/consumer/CPU-reference 各门禁通过；`git diff --check` 通过。已同步 `DESIGN.md`、`ARCHITECTURE.md`、`PRODUCT_SENSE.md`、`SECURITY.md`、`RELIABILITY.md`、`QUALITY_SCORE.md`、taxonomy、v1.23 当前契约和本账本；未满足的真人像效果边界仍明确保留。
- [x] 最终源码另运行一次隔离输出的 65 案例机械诊断，但该直接 runner 未加载 Phase95 源注册环境，聚合 `semantic_fail` 不可与此前已注册的七方向通过批次对比，也不用于签发；FACE-01 旧固定 ROI 下仍为 `5,647/126,841` 像素/RGB 变化。该次生成输出与临时报告已清理。
- [x] 2026-09-24 使用 Phase95 源注册环境、隔离临时输出重跑当前树 65 案例双轮诊断：七个既有方向均 `semantic_pass`，FACE-01 仍因旧固定 ROI 的目标信号、方向、保护区、区外及 sibling 检查为 `semantic_fail`；该批次只作诊断，临时图像与报告已清理。当前树 archive-first no-skip 全门禁再次通过，8 项 opt-in、0 skip；此门禁不授予缺失的真人像效果信用。
- [x] 为机制探针生成两张虚构肖像，放在忽略的本地输入目录；CPU 公共 renderer 的 FACE-01 与 neutral 均能输出，候选对两张都有像素变化。生成器没有可靠地造出可测的粗糙真人像正例，故这些图不能进入权利批准的实际人像正负证据，也不能用变化像素数替代边缘改善。
- 原始效果目标延期：取得权利明确的真实粗糙脸侧正例和平滑负例，在输出前完成源图轮廓/边缘及目标和保护区登记；同一最终代码身份上运行方向、不恶化、确定性及完整 SDK 验收，并经独立复审后签发单独的真人像效果回执。当前本地正式输入只有一张原有肖像，缺少正负成对授权记录；所有者已将本次验收限定为生成输入机制。不得凭生成图或本轮诊断将 taxonomy 从 `partial` 提升。

- [x] 所有者指定的两张虚构生成图在最终源码身份 `ec2589298925422dc6c3dfc65a68285caea4b6bdd913dffb3c0821673c6d3319` 下完成公开 CPU neutral/candidate/repeat 像素检查；8 项 FACE-01 聚焦测试通过，注册 65 案例双轮保留七个既有方向，FACE-01 旧 ROI 判定按失败记录，archive-first SwiftPM `944/0/0`、8 opt-in、零 skip。独立复审无未解决问题；[追加式 COMPLETE](../../.planning/qualifications/v1.23-synthetic/attempt-20260924T045750Z-9429627d/COMPLETE.json) 签发并只读 verify 通过。此回执仅为合成机制，不授予真实人像效果信用；taxonomy 维持 `partial`。

### C-2026-09-23-face-contour-roughness-localization

- Status: completed（2026-09-23）；对未改动的 FACE-01 生成源夹具做只读分区统计，见 [方法、聚合量与边界](../../.planning/FACE-CONTOUR-ROUGHNESS-LOCALIZATION-2026-09-23.md)。Swift `Float`/整数列复现源连续性 `-51 Q16`；总粗糙度55508，脸侧41217、下巴过渡14291；脸侧点间窗口38547，占脸侧93.5%，采样点邻域2670。
- 原门槛 `+16` 要求粗糙度至少减少16773；只消除过渡段至多得到 `+13`。该指标在几何直线段上也主要计入像素列阶梯，故继续仅按采样点曲率选择目标缺少依据；这不是证明原门槛不可能或生产算法正确。已核对 Phase89 manifest、portrait comparator、SwiftPM 冻结测试、taxonomy 与 FUTURE-04：现行数值门槛一致，仍缺少指标与“面部流畅”视觉意图的一致性证明；旧冻结测试、历史回执及 `partial` 状态不变。
- 本步骤没有生产代码或测试改动，也没有运行实际 SDK 输出/人像；只读临时脚本未落盘，输出仅为聚合数字。验证：源指标复现 `-51 Q16` 的断言通过；`git diff --check` 通过；映射修复追加式回执 `verify` 仍返回 `phase_complete=true`。

### C-2026-09-23-face-contour-absolute-curvature-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；用七点/侧 contour 的绝对相邻斜率变化构造凸目标，并沿固定保序行映射做生成机械首关。[方法和聚合结果](../../.planning/FACE-CONTOUR-ABSOLUTE-CURVATURE-FEASIBILITY-2026-09-23.md)。
- 首次 ADMM 20000轮未收敛且未输出候选；未见效果输出前改用五自由变量的穷举顶点法求同一目标，每侧32个可行顶点。原图连续性-51，候选-53，改善-2低于+16；目标15985/4015479，全部保护区0/0且重复一致。该候选停止，不能从几何绝对曲率优化推断像素连续性通过。
- 生产源码、冻结测试及旧回执未改；临时实验脚本删除。下一步是只读定位原夹具的语义粗糙度来源，不开始 v1.23 效果实现或签发。

### C-2026-09-23-face-contour-curvature-target-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；用 contour 行位置的平方二阶差分最小化构造唯一目标曲线，再以左右侧分段保序逆映射生成一次机械结果。[方法和聚合结果](../../.planning/FACE-CONTOUR-CURVATURE-TARGET-FEASIBILITY-2026-09-23.md)。
- 首次预注册坐标下降在2000轮内未收敛且无图像输出；未看候选结果前改用同一凸目标的加速投影求解，15584轮达到 `<=1e-9` 残差。原图/候选连续性均 `-51 Q16`，改善0低于+16；目标 `15049/2974476`，所有保护区0/0、重复一致。平方曲率目标不等于冻结绝对曲率指标，不得据此调整输出门槛或声称效果通过。
- 生产 Swift、冻结测试和历史证据未改；仓库外临时脚本删除。当前未启动 v1.23、未运行 sibling/实际SDK/人像/完整 no-skip，因为首关失败。

### C-2026-09-23-face-contour-monotone-map-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；第三个预注册生成机械候选保留前次七点/侧支撑与二次曲线，仅以保持顺序的分段行逆映射替代三角权重位移场。[方法和聚合结果](../../.planning/FACE-CONTOUR-MONOTONE-MAP-FEASIBILITY-2026-09-23.md)。
- 原图连续性 `-51 Q16`，候选 `-53 Q16`，改善 `-2 Q16 < +16`；目标 `17506/5767164`，outside/central/background/watermark 全部 `0/0`，重复一致。局部性安全不能替代语义效果；该二次拟合目标和分段映射组合停止，不改源码或原测试。
- 仓库外临时脚本已删除；需先找到有独立依据的轮廓连续性目标，才值得做下一个固定候选。当前无 FACE-01 效果通过信用、v1.23 正式里程碑或新 SDK 验收声明。

### C-2026-09-23-face-contour-lateral-fit-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；继续 FACE-01 可行性研究，先按 contour 自身的左右外侧连续链排除中央下巴弧，再用一个预注册二次拟合窄带映射做仓库外生成探针。[方法与聚合结果](../../.planning/FACE-CONTOUR-LATERAL-FIT-FEASIBILITY-2026-09-23.md)。没有修改生产 Swift、冻结测试或历史回执。
- 初次 scratch 执行误将下巴弧也从源夹具剔除，source continuity 为 -38 而非原 -51，判为无效；修正输入生成后，同一映射参数和门槛下得到 source -51、candidate -44、改善 `+7 Q16 < +16`。目标 `15419/5168211` 达下限，outside/central/background/watermark 均 `0/0`，重复一致。首关因语义强度不足停止；没有 sibling、SDK、真实人像或完成信用。
- 临时探针删除，当前无 v1.23 正式里程碑；要继续需提出与这两个失败窄带构造不同且预先固定的新机制，不能从保护区通过推导效果通过。
- 验证：修正夹具输入后的临时脚本退出0并仅输出聚合量，已删除；`git diff --check` 通过，`python3 scripts/check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266` 仍为 `phase_complete=true`。未运行完整 SwiftPM 或真实65人像，因为机械首关未达到原语义门槛且 SDK 源码未改。

### C-2026-09-23-face-contour-strip-feasibility

- Status: completed（2026-09-23，结论为 `STOP`）；所有者要求继续 FACE-01 的受控可行性验证。预先固定的单个双侧窄带映射在仓库外临时 Swift 生成夹具中执行一次；没有修改 SDK 生产代码、冻结测试或历史回执。[完整聚合记录](../../.planning/FACE-CONTOUR-STRIP-FEASIBILITY-2026-09-23.md)。
- 结果：连续性 `+6 Q16 < +16`；目标 `15581/4654212` 达信号下限，但 outside `1684/428172` 与 central `1583/385749` 均超原保护上限；背景/水印为0/0，重复一致。预设的“窄带均在目标 ROI 内”推论遗漏了下巴端点，已在记录中更正。该候选停用，不按输出调参或冒充原 SwiftPM 冻结 oracle 通过。
- 后续问题只限于先确定排除中央下巴弧的轮廓侧支撑所有权，再提出独立的新候选；尚无 v1.23 里程碑或 FACE-01 效果通过信用。
- 验证：临时原型退出0并仅输出聚合量，执行后已删除；`git diff --check` 通过，`python3 scripts/check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266` 仍为 `phase_complete=true`。未运行完整 SwiftPM 或真实65人像，因为首关已失败且 SDK 源码未改。

### C-2026-09-23-face-contour-smooth-feasibility-assessment

- Status: completed（2026-09-23）；按所有者要求评估 `faceContourSmooth` 的下一步，不启动新里程碑或修改生产代码。结论与证据见 [FACE-CONTOUR-SMOOTH-ASSESSMENT-2026-09-23.md](../../.planning/FACE-CONTOUR-SMOOTH-ASSESSMENT-2026-09-23.md)。
- 当前 provider 和生成测试表明字段可调用、失效时 fail-closed，但八组冻结语义/保护谓词仍未满足；Phase 90 的既有点场尝试未同时达到连续性与局部性。建议先界定不同于旧圆形点场的双侧窄带映射可行性，并以原冻结生成验收为 go/no-go；未证明可行前不写生产修复或声称 FACE-01 完成。
- 验证：`swift test --package-path BeautySDK --filter FaceContourSmoothRepairTests` 3/0/0；其中输出测试明确要求仍为 deferred，不能把通过计作效果通过。原 v1.22 与映射修复追加式验收回执保持不变。

### C-2026-09-23-v1-22-mapping-followup-qualification

- Status: completed（2026-09-23）；所有者授权为映射修复后的当前代码新增追加式验收。新契约、执行工具、生成测试及全部回执在 [.planning/qualifications/v1.22-mapping-followup/](../../.planning/qualifications/v1.22-mapping-followup)；历史 Phase95 文件未覆盖或移动。
- 当前身份 `0debce887ab95a49a4970f78dbb53f3500aca75d67861e4d493f011a176204af`。独立实现/安全审查与不同审查者的目标复核均为0未解决发现；当前真实65/65输出、双次一致、七有效一延期，山根31对及五组 [260,373] Q16，目标10774像素/RGB217300，outside与全部保护区变化0。安全1/0/0、兼容4/0/0；完整archive-first SwiftPM 938/0/0、8项 opt-in、零skip。
- 生成回执测试2/2、自测8项拒绝控制、临时目录实际预检75/65/8通过；`python3 scripts/check-v122-mapping-followup.py verify --attempt attempt-20260923T083240Z-16509266` 通过。[新 COMPLETE](../../.planning/qualifications/v1.22-mapping-followup/attempt-20260923T083240Z-16509266/COMPLETE.json) SHA256 `0fc220c8863f7063bd32b27034191f7d48d8b4b6ea3f90c9759c18647230a7c2`；旧 COMPLETE 保持 `33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4`，旧 portrait/BINDING/CHECKS 哈希逐一不变。
- 完成声明仅为当前代码在同一范围内的所有者本地 SDK 验收；不补发 `faceContourSmooth` 效果信用，也不产生设备、商业视觉质量、发布或外部分发资格。旧 `verify-complete` 仍按原一次性快照返回 `review_missing_or_stale`，不是新回执失败。

### C-2026-09-23-v1-22-post-closeout-document-audit

- Status: completed（2026-09-23）；在继续 Phase95 重签前核对当前状态文档、一次性签发代码和旧回执，见 [后续文档与工具核对](../../.planning/V1.22-POST-CLOSEOUT-DOC-AUDIT-2026-09-23.md)。
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

- Status: completed（2026-09-23）；对 v1.0–v1.22 历史里程碑账本、v1.22 当前回执与现行多脸检测/渲染调用链进行复核，记录于 [历史里程碑代码复审](../../.planning/HISTORICAL-MILESTONE-REAUDIT-2026-09-23.md)。
- 结论：当前 v1.22 `verify-complete` 有效且完整 archive-first no-skip gate 本次通过；v1.18 独立复审仍有 EVID-01/02 partial 与 QUAL-01/02 unsatisfied、v1.19 已取消、v1.22 的 FACE-01 已明确延期，均不能被“所有原始目标完成”概括。
- 当时记录 TD-023/TD-024 两项多脸问题；后续复核将 TD-023 纠正为文档过度承诺、TD-024 定位为源码缺陷并修复（见上方完成记录）。本次原审计未修改生产代码或历史归档，也未将静态路径证明冒充新增人像效果验收。
- 本次门禁最初在受限执行环境内因 SwiftPM 编译器模块缓存写入被拒而停下；使用获准的文件系统权限重跑同一命令通过，8项 opt-in、零skip。
