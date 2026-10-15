# PLANS.md

> `beauty` 的当前执行入口。先读本页，再按链接读取当前计划或相关历史记录。
> 本页与 `plans/active/`、`plans/debt/current.md` 共同拥有当前计划和技术债；`plans/history/` 是历史快照。

当前图片效果验收政策见 [IMAGE_EFFECT_ACCEPTANCE.md](docs/validation/IMAGE_EFFECT_ACCEPTANCE.md)。有权使用的生成肖像可作正负例；真人图片和真实设备是可选补充。历史记录中相反的要求不约束新工作。

## 1. 阅读路径与更新规则

1. 每次工作先读本页；涉及现行任务，再读下方 Active 条目和[当前技术债](plans/debt/current.md)。
2. 查询已完成事项时，先读[历史索引](plans/history/README.md)或[2026-10 已完成索引](plans/history/2026-10/README.md)及[终局处置索引](plans/history/2026-10/TERMINAL.md)，再打开匹配分片。可用 `rg -l '记录 ID 或关键词' plans/history` 定位，不必加载整个历史账本。
3. 开始工作前确认已有匹配计划，优先更新现有计划；每完成可验证步骤更新 checklist。任务先写清行为、保留契约与最小充分验证，不默认扩大到全 SDK 或外部宿主。
4. 阻塞需记录原因、尝试及下一步；完成后记录验证证据与剩余风险，移入 Completed。
5. 发现范围外问题写入当前技术债；契约变化同步更新对应 owner，摘要直接链接正文。授权范围、实际实现、效果资格和日期回执分别记录；未验证要写明原因。
6. 新 Active 计划各用一个 `plans/active/<ID>.md`；完成时将其全文移至 `plans/history/YYYY-MM/<ID>.md`，并更新本页与历史索引。2026-09-28 前的旧记录保存在索引所列分片中。

状态词：`planned` 待开始；`active` 推进中；`blocked` 等待条件；`verifying` 验证中；`completed` 已验证；`canceled` 明确取消并留原因；`closed_with_unmet_objectives` 有限尝试结束、目标未实现且无续作队列。

## 2. 当前边界

- 产品面是所有者自用的 SDK-only SwiftPM library 与 SDK-owned 验证；本账本不授予设备、商业视觉质量或外部分发资格。
- 真实设备反馈可成为后续发现，不是当前自动化完成门禁。效果方向、保护区、重复性、元数据及 typed failure 以实际输入/输出为准。
- 历史分片保留当时的状态与证据，现行 taxonomy 以 [SDK_EFFECT_TAXONOMY.md](docs/SDK_EFFECT_TAXONOMY.md) 为准。
- 去脂仍为 `suspended`、默认隐藏并保留显式兼容；自动同肤色贴片识别未实现。v1.25两分支各2方法4版本均失败，按所有者终局要求关闭未交付目标。现有host物体+完整唇并集蒙版继续可用；辅助能力不计自动交付。见[最终处置](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)。普通“继续”不重启、失败缺口不再作为计划阻塞；未来重开须明确新范围与新信息/资源。

## 3. Active

- C-2026-10-15-batched-local-commits：四批本地提交保存基础契约、效果集成、Metal兼容与文档；归档/边界检查通过，未重跑Swift测试，不改变效果资格。见[完成记录](plans/history/2026-10/A-2026-10-15-batched-local-commits.md)。

- [A-2026-10-15-iris-gray-panel-repair](plans/active/A-2026-10-15-iris-gray-panel-repair.md)：灰边仍未达标、未最终交付。C75真机Panel原断言1/0/0；受限眼白光照修正及直接依赖37/0/0，流式存储调整后照明/保护复核3/0/0，原图C77双分辨率捕获2/0/0仍见下缘线。contact-matte及另行授权的SAM2.1 Tiny本地评估20次均未合格；当前原生重建因宿主并行引用缺少jawlineShadow字段而阻断。旧阈值/失败/并行嘴鼻眉及当前App保留。

- [A-2026-10-14-eyebrow-reference-refactor](plans/active/A-2026-10-14-eyebrow-reference-refactor.md)：`active`，分支`codex/eyebrow-reference-refactor`；七项双向映射/连续源RGB候选已实现，C23修复cap细眉头漏运，原图重放形态10/14、严格域0/14，未交付。已授权8次本地SAM验证及固定mask原型整体失败，未集成；继续查皮肤变化与前发错接，保留原门和眼鼻嘴并行工作，不扩大宿主。

- [嘴部整体重做](plans/active/A-2026-10-14-mouth-redesign-HANDOFF.md)：`active`，用户指定原图已在 iPad 核对预览身份；旧大小四端点嘴外泄漏已复现。playbook 全文/代码已复核，八项作用域已定义；两种隔离大小合成虽 U 外零变化，均因方向/外观拒绝（残边、填补、贴片硬边），未整合。下一前置是源嘴材料边界和暴露区纹理重建。生产74e、旧oracle及并行改动保留；不提交/推送，不能把机制测试通过当交付。




### A-2026-10-11-nose-reference-implementation

- Status: `verifying`。六项连续鼻场与16ms预览调度已实现；选定候选6，原13项鼻部SDK及7个不同相关原生用例通过。2026-10-12修复A10 GPU dispatch兼容问题，新增本轮16项直接SDK及3项iPad Release原生检查全部通过；同照片预览/原尺寸各90/90可靠端点、完整眼眉唇保护与12端点实际Metal一致性通过。已更新安装并打开iPad应用；正鼻尖仍稍宽圆，完整美图外观目标未结清，限量渲染耗时不代表拖动帧率或长稳。
- Scope: 固定单项原图/参考端点与比例、轮廓、眼唇保护验收；连续鼻部场替代局部拉点，并验证真实MediaPipe输出与必要外观增强。
- Plan: [实施假设、预先声明的像素/外观标准与最小验证](plans/active/A-2026-10-11-nose-reference-implementation.md)。不把旧生成测试或变化像素数当成此次外观达标。

本轮脸型接线与连续轮廓修复已完成其限定实现，见下方 C-2026-10-11；完整美图外观一致及发际线/面部流畅原图缺口保留 FACE-REF-01。

所有者编辑宿主的接线、范围、组合、调试显示与预览修复
已记录在下方。旧 iOS 17.5 模拟器 Vision provider 的连续检测异常仍为历史限制；
现行 iOS SDK 与宿主调试已使用 MediaPipe，该旧失败不是现行宿主阻塞，见[当前技术债](plans/debt/current.md)。
v1.25仍按`closed_with_unmet_objectives`结清，不恢复其自动效果研发。

## 3A. Historical Lifecycle Ledger（历史脚本锚点）

### A-2026-09-10-phase-93-registration-disposition（历史脚本查找锚点）

原记录已在[历史索引](plans/history/README.md)对应的 completed 分片。Phase 93 的 owner-local `93-CHECKS.json` 与 Phase 95 independent review 属于历史证据，不是当前 Active 计划。

## 4. Completed / terminal dispositions

### C-2026-10-14-eye-iris-reference-delivery

- Status: `completed`，限源空间IR等比圆形核心/严格owner与材质保护、原图preview切点及现有双向滑杆修复。完整美图外观目标仍有负端细灰边/完整语义与泛化缺口，未宣称全面等效。四无参考按钮灰禁用，11参考滑杆及SDK15眼字段/API保留。
- Verification: refactoredIR23、actual publicCPU/Metal1、final facade6/fractional3均0失败0跳过；C74原图/预览各1/0/0、四冻结协议与source/runtime绑定通过；旧十照片1+hostUI6为7/0/0，21PNG/完整RGBA与C40/C53 exact。UI6含当前irisPanel像素/安全区；iPad实际Metal/CPU原图及CPUpreview各1/0/0、四协议通过。两次真机Panel初始scene0失败，布局未执行，独立debt且原因未确认。
- Delivery: sameID保留数据更新iPad，实际图片复核及受管预览/匿名聚合已保存；App实际前台打开，精确task root独立父目录读取确认absent；124份重复下载PNG/231185891bytes精确清理，原资料/冻结失败/有效产物保留。初次build保存门拒绝保持：102移除文件中88精确补回、14旧compiler文件未恢复，当前App/dSYM/ready产物exact，补充source/signature/photo绑定接受当前已成功构建App。
- Record: [完整失败历史与完成范围](plans/history/2026-10/A-2026-10-14-eye-iris-reference-delivery.md)、[聚合](docs/validation/EYE_IRIS_20261014.json)。不提交/推送；无全量回归或physical触摸/性能资格。

### C-2026-10-14-mouth-thinning-research

- Status: `canceled`，用户改为嘴部整体重做；仅完成单项研究规划及只读准备，无新候选/证明/图片/研究编译，不能算实验成功或失败。
- Record: [原计划及取代原因](plans/history/2026-10/A-2026-10-14-mouth-thinning-research.md)、[新线程交接](plans/active/A-2026-10-14-mouth-redesign-HANDOFF.md)。生产未改；另有当前共享工作区36项定向集成检查通过，不能覆盖唇外脸部稳定性。

### C-2026-10-12-mouth-native-followup

- Status: `completed`，限负收薄与image-X改善/滑杆响应。f160忠实集成74e；仅修合成marker归属，原几何、保护、cap、数值门及照片matcher保留。完整参考仍未达到，MOUTH-REF-01保持。
- Verification: 实际SDK31/0/0含Metal32、public14；原iPad R13 shadow1/原7和当前iPhone13Pro26.4.2自身shadow1/原7分开记录。手机原final5/0/0、36PNG/14完整RGBA身份、8controls-first F−/X数值与双图原生1:1细节通过；A F辅助改善.8576/.8020px，X三窗增益3.8451/2.8400/2.8418px，负例不恶化。无全量回归。
- Delivery: 同原AppID保留数据安装，iPhone App已实际打开；007/008压缩预览与库存check通过。本机162项/441152876bytes精确清理，输入/golden/失败回执/构建与并行工作保留。手机精确目录清理及后续文件服务检查失败，未确认清理或残留数；旧iPad未连接未检查，见MOUTH-DEVICE-MEDIA-01。
- Record: [同一计划的完成记录](plans/history/2026-10/A-2026-10-12-mouth-native-followup.md)、[原交接路径](plans/active/A-2026-10-12-mouth-native-followup-HANDOFF.md)。保留所有旧失败，不提交/推送；无完整参考、一般外观、全尺寸/手机GPU、UI/FPS、性能/温升/耗电/长稳资格。


### C-2026-10-13-eye-physical-delivery

- Status: `completed`，完成现有iPad更新及限定参考响应交付。C32按原RGB一致性边界修复下至/外角局部框架，前五项默认注册、系数/cap及冻结V2谓词保持；原尺寸与预览五项响应、保护及必要原生细节/身份复核通过，C28–C31失败保持其版本含义。
- Verification: 最新 **8个不同最小SDK用例+一次扩展同回归/0失败/0跳过**；同一iPad生产照片方法actual Metal原图20端点、CPU prepared预览40档各 **1/0/0**。20原图端点重复及独立CPU RGBA exact，前五项10及未改动6端点与实际C28 PNG exact；预览10cap重复、30中间档未重复。
- Delivery: 同App ID保留数据更新打开；设备专属媒体根独立确认移除，本机539临时图及29一次性helper等659文件精确清理。有效App/结果/runfile/缓存、原始参考及并行嘴部最新产物保留。初次误清理R10已按冻结配置恢复，后续C32精确恢复当时最新R11产物。
- Record: [完成记录](plans/history/2026-10/A-2026-10-13-eye-physical-delivery.md)、[匿名回执](docs/validation/EYE_PHYSICAL_20261013.json)。单张已编辑源仍缺共同零態/美图数值/参考四档曲线；不扩大为一般美图、人群、完整语义蒙版、UI触摸、性能或全量回归资格。

### C-2026-10-12-eye-next-five-match

- Status: `completed` for bounded supplied-reference response and selected sliders.
- Result: 下至、眼尾上扬、倾斜、内外眼角选定C28；原尺寸/预览冻结幅度、双向响应、分离、核心保护与眼区细节通过。两批十项共用参考连续滑杆；前五项同一sRGB输入的C7实现基线PNG10/10 exact。
- Verification: **23直接SDK/0失败/0跳过**，含actual public CPU/Metal；**5原生滑杆/0/0**。同一MediaPipe照片方法两次CPU配置各**1/0/0**：原图20cap（新10+旧10），预览新五项40四档。必要弱尺度身份复核、边界、媒体与链接/diff检查通过；无全量回归。
- Cleanup: 原参考/冻结旧回执/构建和非探针失败xcresult保留，2104临时媒体、标注/helper/runfile及3个原始探针结果包精确移除；独立后检查确认零残留，两oracle hash不变。保留一张受管预览与允许聚合。
- Limit: 单张已编辑参考端点、sRGB验证协议，缺共同未编辑neutral/数值/中间轨迹；无完整美图/人群/组合/严格分辨率一致或本批真机/性能声明，P3±1另留债务。
- Record: [本批交付、失败、实际验证与清理](plans/history/2026-10/A-2026-10-12-eye-next-five-match.md)。

### C-2026-10-12-eye-five-match

- Status: `completed`，限前五项既定端点响应/分离/保护与已授权滑杆范围。
- Result: 大小、上下、眼高、长度、眼距选定C7；冻结参考幅度、跨轴、保护与眼区原尺寸复核全部通过，滑杆外观与连续点按/拖动/历史行为完成。
- Verification: **22项定向SDK / 0失败 / 0跳过**、**3项滑杆 / 0 / 0**；同一照片方法在模拟器CPU预览40档、CPU原尺寸10端点和iPad实际Metal原尺寸10端点三个配置各执行1次，均1/0/0。iPad十端点与独立CPU RGBA完全一致。
- Finish: iPad沿用原ID更新保留数据；本次独立fixture已核验移除，App已打开。精确清理本机400临时文件（365媒体、13坐标工具等），保留失败聚合、有效构建/xcresult和唯一展示图。
- Limit: 单张已编辑参考端点，缺共享未经编辑零态；不声明完整美图外观等价、其他六项幅度、真机UI/性能或全量回归，剩余边界见EYE-REF-01。
- Record: [选定结果、失败、实际检查与清理记录](plans/history/2026-10/A-2026-10-12-eye-five-match.md)。

### C-2026-10-12-mouth-amplitude

- Status: `completed` for bounded algorithm/slider-response optimization; complete reference amplitude remains unmet.
- Result: M唇趋平与薄组织正端、负收薄距离场与细网格、左右共同嘴角平台已优化；修复滑杆过零跳变和组合pose预算，保留完整口腔/鼻眼保护与原cap。
- Verification: 最终**29项定向SDK / 0失败 / 0跳过**，含实际Metal32调用；fresh原生**5/0/0**（3滑杆契约+2照片）。14公开输出与14所选原生端点对候选全RGBA一致，34原生库存/回执核对；固定参考测量、原尺寸复核、边界/链接/媒体检查通过。
- Limit: M与左右有实际增益，负收薄改善较小；完整M、负收薄和原生左右幅度目标仍未达，见MOUTH-REF-01。保留005/006新压缩预览，355临时派生图已精确清理；未全量/真机性能回归。
- Record: [选定实现、失败复现、真实验证与边界](plans/history/2026-10/A-2026-10-12-mouth-amplitude.md)。

### C-2026-10-11-eye-reference

- Status: `completed` on 2026-10-12 for bounded eye algorithm/slider implementation; complete Meitu appearance and sparse-pupil amplitude remain unmet.
- Result: 十项实测眼形连续局部场、dense 虹膜双向机制、十一中点滑杆与倾斜极性；眼高/眼瞳分离、五个宿主入口补齐、两处过零跳变及稀疏正向眼瞳眉保护修复。去脂、祛红血丝按所有者要求排除。
- Verification: **89项不同的直接相关SDK / 0失败 / 0跳过**，含实际CPU/Metal；单台已有模拟器的**10项宿主 / 0 / 0**。20实照眼形端点方向/分离/保护通过；眼瞳修复后保护通过，但深色面积+2.344%/+1.982%未达到预设>3%。边界/mutation、归档、媒体及链接/diff检查通过；没有全量回归。
- Limit: 照片本身是参考端点且缺零态/数值；该初始检查点未执行原生MediaPipe肖像重渲或完整外观等价。稀疏眼瞳幅度仍弱、负向退出；更早额外组合检查的鼻嘴夹具两断言失败另记当前债，不宣称该额外检查通过。
- Record: [实现、真实检查、失败与剩余范围](plans/history/2026-10/A-2026-10-11-eye-reference.md)，后续边界见 EYE-REF-01。

### C-2026-10-11-mouth-reference

- Status: `completed` for bounded algorithm/slider implementation and scoped validation; complete reference appearance remains unmet.
- Result: 八项实测连续嘴场、M/丰唇/微笑signed、九控件SDK及外部宿主映射；像素旋转、薄唇/外围重复衰减和微笑展开修正，口腔与鼻眼保护保留。
- Verification: 累计86个不同相关SDK用例最终通过；最终同版25/0/0含实际Metal。累计11个不同原生用例最终通过；最终两照片2/0/0，32双向+4微笑横向、重复/neutral/alpha/保护及478点/sRGB通过。14Vision/34原生实际输出独立复核，边界/归档/链接/媒体容量通过；旧失败保留，未全量回归。
- Limit: 微笑宽度与正向丰唇接近匹配参考；M双端、负丰唇与左右仍有幅度差距，见MOUTH-REF-01。两张忽略压缩预览保留，本轮334临时媒体副本已精确清理；未验收一般外观、露齿或真机性能。
- Record: [实现、失败修正、最终实际检查与剩余边界](plans/history/2026-10/A-2026-10-11-mouth-reference.md)。

### C-2026-10-11-agent-documentation

- Status: `completed`，限本轮文档优化与漂移修复。
- Result: AGENTS 精简为行动入口；明确授权/要求/实现/证据的职责，按影响选择检查，统一 SDK/外部宿主边界、导航与计划模板；修正 detector raster 和连续脸型多阶段采样描述。
- Verification: 本地链接/锚点与 diff 检查、两归档、boundary self-test、no-skip 控制自测通过。boundary live 因本轮开始前已有嘴部测试的 `renderBackend` 引用退出 1，已记录 SDK-GATE-01，未放宽扫描器；未执行 SwiftPM/App/图片效果回归。
- Record: [改动依据、修复清单、实际验证和共享工作树边界](plans/history/2026-10/A-2026-10-11-agent-documentation.md)。并行眼/鼻/嘴实现、模型、媒体、冻结契约和旧回执保留独立状态。

### C-2026-10-11-face-continuous

- Status: `completed` for bounded code/slider implementation; complete reference appearance remains unmet.
- Result: 六项 signed、十控件 SDK helper、八项连续轮廓及柔和发际线准入；小脸下巴波纹修复。direct chinLength 极性、旧粗代理正向、默认98/canonical99库存保留；新增50显式opt-in位置。
- Verification: **174相关SwiftPM / 0失败 / 0跳过**，含实际CPU/Metal、双向/四档幅度、眼嘴/外围/alpha、平滑下巴、neutral/退出/恢复及元数据；**38张macOS/Vision输出**，边界及mutation、归档、库存2例/两次CLI发现、媒体容量通过。未全量或原生iOS/宿主回归。
- Limit: 两图发际线及面部流畅仍退出；截图无数值，未交付全部外观/幅度一致。原图与nose本地改动保留，三张忽略压缩对比图；原尺寸临时输出已清理。
- Record: [实现、修正、验证与剩余边界](plans/history/2026-10/A-2026-10-11-face-continuous.md)，现行缺口见 FACE-REF-01。


### C-2026-10-10-face-reference

- Status: `completed` for comparison and rejected-candidate disposition (recorded 2026-10-11); face appearance repair remains unmet.
- Result: 18 isolated Meitu screenshots, both authorized originals and 26 actual macOS/Vision outputs compared. Positive-only width/small/jaw/temple/cheek/chin, uneven small-face chin and baseline-exact hairline/contour on both portraits identified. Three-field signed candidate failed dense monotonicity/protection and was withdrawn; no face code/test change retained.
- Verification: candidate 5 cases: 4 passed/1 failed; restored current face-provider tests **6/0/0**. Four bounded previews and aggregate evidence retained. No full suite, native iOS/MediaPipe portrait rerender or appearance-parity claim.
- Record: [comparison, oracle and disposition](plans/history/2026-10/A-2026-10-10-face-reference.md); remaining gaps tracked as FACE-REF-01.

### C-2026-10-10-nose-screenshot-comparison

- Status: `completed`，完成原图、八张双向截图与美图参考视频对照；外观问题未修复。
- Result: 大小/鼻尖接线独立，大小的下鼻纵向拉伸占主导且同组嘴唇样本被带动；山根/鼻梁/鼻尖有变化但作用局部、观感不足。美图同照片统一显示比例对照及现行代码/参考章节核对完成。
- Verification: 原尺寸照片区域像素对照、端点视频帧和未变化眼部/头发配准；仅聚合记录与压缩预览。未运行SDK/App测试、复现独立字段运行时或修改算法。后续必须冻结neutral其他字段/settled预览，补整体比例、局部形状与保护区oracle。
- Record: [截图对照、证据限制与新增验收缺口](plans/history/2026-10/A-2026-10-10-nose-screenshot-comparison.md)；未满足项归入NOSE-REF-01，旧85/20测试不代表此照片外观合格。

### C-2026-10-10-nose-signed-preview

- Status: `completed`，完成本次双向鼻部与响应修复；美图秀秀外观对齐仍未验收。
- Result: 六字段signed重建/归一化/cap/backend与六宿主双向滑杆；40ms启动限频、单运行+最新待处理、松手flush，调试延后。鼻部实测/控制节点、source核与cap准入修复漏采样及非单调衰减，大小/鼻尖/翼/提升/梁的dense局部幅度增强；ROI采样与参考逐字节一致。
- Verification: SDK **85个不同相关用例/0失败/0跳过**（含强制CPU/Metal parity）；同一既有iPhone15Pro/iOS17.5宿主 **20/0/0**。六项±四档48实际输出、方向/单调幅度/完整眼嘴与外围保护、元数据及两侧UI截图通过；模拟器Debug中位渲染耗时308→125ms，最终元数据复验104ms；不构成真机或fps声明。
- Record: [实现、失败修复、最小验证及剩余对照边界](plans/history/2026-10/A-2026-10-10-nose-signed-preview.md)。旧正向冻结像素/Shader/模型保持，未全量回归/安装真机；外观/3D光影差距保留NOSE-REF-01。

### C-2026-10-10-nose-reference-audit

- Status: `completed`，指视频/代码/文档核对完成；鼻部弱效果反馈未修复。
- Result: 所有者确认视频为美图秀秀参考。逐秒67样本及原尺寸鼻部裁剪显示六项双向参考；SDK仅鼻尖双向，大小/提升/山根/鼻梁存在作用语义差异。当前宿主100已到cap，近期四档断言没有可见幅度/尺寸/方向门禁；dense局部采样/衰减原因待运行时量测。
- Record: [具体对照、确认项、假设与验证范围](plans/history/2026-10/A-2026-10-10-nose-reference-audit.md)。现行taxonomy与质量声明限定到实际证据，缺口进入[NOSE-REF-01](plans/debt/current.md)；没有修改SDK/App算法或重新签发旧测试。

### C-2026-10-10-batched-local-commits

- Status: `completed`。按所有者要求分六批提交：OwnerDiagnostics、独立组合强度、共享几何渲染、固定原图检测复用、正式参考手册、文档分类与契约同步；仅本地Git提交。
- Pre-commit repair: 新Metal测试遗漏边界登记，使用既有精确SHA256机制补齐并新增修改拒绝自测；live/self-test与两归档通过，不放宽生产API/backend/shader边界。SDK/App源码和测试字节未改，先前定向结果保留其原范围，没有全量重跑。
- Record: [六批范围、提交、排除项和实际验证](plans/history/2026-10/A-2026-10-10-batched-local-commits.md)。独立Demo无Git历史；根级原始参考副本与Python缓存保留本地，正式资料从docs进入。

### C-2026-10-10-prepared-photo-editing

- Status: `completed`。所有者明确借鉴视频处理方案优化已有图片SDK与编辑Demo；研究并修正八项规划问题后实现固定原图、按用途隔离的有效检测复用。
- Result: engine只保留一个深拷贝source与最多六个检测入口；失败重试、换图/reset/release失效。独立Demo预览接入opaque token，每次参数从原图渲染，原尺寸导出仍fresh检测。
- Verification: SDK **65个不同定向用例/0失败/0跳过**（含实际Metal）；同一已有iPhone15Pro/iOS17.5原生 **13/0/0**（9pipeline+3session+1UI），真实478点复用与独立fresh像素完全一致、换图/导出和过期结果拦截通过。macOS生产renderer六鼻子四档、alpha/neutral/导出及相关门禁通过。
- Boundary: 无视频/摄像头、时序跟踪、新效果或灰色入口解锁；未全量回归、安装真机或宣称性能。保留既有改动与失败边界；[研究、规划修正和完整验证记录](plans/history/2026-10/A-2026-10-10-prepared-photo-editing.md)。

### C-2026-10-09-playbook-sdk-refactor

- Status: `completed`。在新分支`codex/playbook-sdk-refactor`先研究、规划审查并修正阶段顺序/失败保护问题，再重构已有SDK静图路径。
- Result: CPU/Metal共用请求内几何准备、source准入、最终点和后置平移；Metal适配一次face、复用prepared点，两backend共用有界诊断。修复parity门禁依赖首个断言顺序的既有缺口。
- Verification: **134个不同直接回归全部通过，0失败/0跳过**；实际Metal parity **14/0/0**单列，parity/neutral和SDK-only自测、归档、存储、链接/差异及非目标源码摘要核验通过。首次缓存权限/新测试编译与原自测失败在记录中分列；未弱化生产准入或验收标准。
- Boundary: 保留已有及并行文档改动；未重跑完整SDK、原生iOS/App或真机，未新增效果或解除灰色入口，未测性能。见[规划审查与完成记录](plans/history/2026-10/A-2026-10-09-playbook-sdk-refactor.md)。

### C-2026-10-09-document-drift-followup

- Status: `completed`，仅文档漂移修复；并行 SDK 重构保留独立状态。
- Result: 同步分类与 authority、七份 dated map 导航、dense/source/legacy 组合规则、OwnerDiagnostics 边界和已实施/候选区别；明确 v1.25/旧 phase 证据的历史范围及原材料评审覆盖。项目 skill 与四份参考文档使用分类后的规范路径。
- Verification: 当前导航/源码声明及旧断言扫描、3 份冻结 G0 绑定、2,077 份历史/冻结/试验/既有测试摘要、两归档、boundary live/self-test、wrapper 14/14 控制、storage 和 diff 检查通过，无新增断链。本任务未改代码/测试或运行 SwiftPM；QUALITY 库存为带时间的工作树采样，不复用旧 gate 证明并行代码。
- Record: [修复清单、共享工作树与实际验证范围](plans/history/2026-10/A-2026-10-09-document-drift-followup.md)。

### C-2026-10-09-docs-organization

- Status: `completed`，仅目录分类与文档导航维护。
- Result: 新建 7 个分类目录与索引，迁移 28 份正文；taxonomy 和 3 份摘要绑定契约保留固定路径，14 份短入口维持冻结/只读历史链接。顶层 Markdown 33 → 19，正文不重复保存。
- Verification: 本地链接/锚点无新增断链；2,532 份原文件摘要核对、3 份 G0 绑定、两归档、SDK-only boundary live/self-test、wrapper 14/14 自测、storage 和 diff 检查通过。代码与测试未改，未运行 SwiftPM 或重新签发图片/模型/设备证据。
- Record: [目录、兼容入口与实际验证范围](plans/history/2026-10/A-2026-10-09-docs-organization.md)；文档入口见 [docs 索引](docs/README.md)。原有历史断链和所有者本地改动保持原范围。

### C-2026-10-09-combination-ui

- Status: `completed`。移除宿主旧组合余额截停和quota提示；dense字段按独立cap及最终实际位移/梯度/姿态准入，九源像素相关字段和legacy保留保守预算。
- Result: 每个滑块保留独立值/方向、别名/撤销；debug显示组合项数。未开发分类和去脂保留置灰禁用，直接model调用无提示/无状态变化；实际无脸/缺点/错误继续说明。
- Verification: SDK定向 **25/0/0**；外部宿主 **12个不同相关用例最终通过**（10 unit + 2 UI，首轮11通过/1测试访问错误，单项修正重验通过；最终fresh路径另单项通过）。实际组合像素、五张生成输入布局截图/交互、字段绑定、helper编译与SDK-only边界通过。未全量回归、扩展设备或更新手机。
- Record: [完成范围、原始失败与限制](plans/history/2026-10/A-2026-10-09-combination-ui.md)。实际超界网格仍可能共同减弱；整体只读、装饰标识等后续候选入债务，不恢复新算法或EYE/SEG。

### C-2026-10-09-owner-mediapipe-debug

- Status: `completed`。修复截图暴露的宿主Vision调试遗漏：SDK渲染已使用MediaPipe，但独立debug仍调用Vision且文字写死。
- Result: 新增owner-only瞬时诊断SPI，复用生产adapter、canonicalizer与固定模型；宿主在独立actor-owned实例上复检，iOS原图/输出各478点，面板显示实际模型，原图/当前版本隔离保留。
- Verification: SDK定向 **3/0/0**，真实外部宿主相关 **4/0/0**（3 unit + 1 UI），覆盖478点、无脸/错误恢复、调试像素不变、六鼻子四档及组合、异步/UI开关；App主bundle模型哈希匹配。未运行完整SDK或App全功能回归。
- Boundary: 同一已有模拟器/稳定缓存，旧Vision/人物分割失败保留；手机已安装版本未更新/验证，需要用户重新运行新App。见[完成记录](plans/history/2026-10/A-2026-10-09-owner-mediapipe-debug.md)。

### C-2026-10-09-dense-face-refactor

- Status: `completed`。按所有者要求充分使用478点与姿态，在现有静图管线完成首批核心改造。
- Result: 有界Core Image context复用；可见虹膜环与眼/眉/唇几何保护；近刚性姿态衰减；全478点分布驱动的固定画布网格与位移/梯度预算；美肤平滑和相干细节分支独立，避免旧组合抵消。见[实现说明](docs/sdk/DENSE_FACE_REFACTOR.md)。
- Verification: 最终完整SDK **1098 tests / 0 failures / 0 skips，9 opt-ins**；同一已有iOS宿主 **24/0/0**，两图姿态/可见iris、CPU/GPU组合最大通道差≤2、重复及失败恢复通过。新增独立几何/虹膜/纹理像素正负例纳入完整门禁；失败候选与原因留档，原阈值未放宽。
- Boundary: 共享dense几何仍为CPU-owned阶段；公开字段/default、模型、retained shader和冻结终局保留。视频、GPU原生网格、扩大纹理尺度及全链零拷贝未交付，效果资格不批量提升。见[完成记录](plans/history/2026-10/A-2026-10-09-dense-face-refactor.md)。

### C-2026-10-09-playbook-synthesis

- Status: `completed`，按所有者要求学习外部 beauty-sdk-playbook 并整理为[项目手册](docs/refactor-playbook/README.md)。
- Result: 六篇549行，覆盖478点/坐标/时序、候选网格与位移安全、美肤/五官、工程/验收，以及原文和四份代码骨架评审；现行实现、建议设计和待验证结论分别标明。
- Verification: 一手资料与代码/owner核对、文档导航/差异、两归档、post-archive边界、示例存储通过；2,452份既有非目标文件SHA-256不变。
- Boundary: 仅文档，不运行/导入外部提示词与代码，不改SDK/模型/测试，不新开算法或EYE/SEG队列，不重签此前SwiftPM/原生检查点。见[完成记录](plans/history/2026-10/A-2026-10-09-playbook-synthesis.md)。

### C-2026-10-09-mediapipe-sdk-integration

- Status: `completed`。按所有者要求将 MediaPipe iOS 1.1.0 接入 BeautySDK；iOS 默认启用，macOS 保留 Vision，原公开调用方式不变。
- Result: 固定三个官方运行库与 float16/1 模型并校验哈希；478 点映射眼/眉/鼻/唇/脸支撑，既有几何使用实测点；列主序姿态正确转换并保留在请求内。CPU image mode 复用初始化，不复用观测；失败安全退出。
- Verification: 完整 SDK 门禁 **1083 tests / 0 failures / 0 skips，9 opt-ins**；同一 iPhone 15 Pro / iOS 17.5 原生 **23/0/0**（14 项 SDK 专属 + 9 项原探针），覆盖两个肖像、有效姿态/区域支撑、实际输出、20 次连续重复、无脸/重置恢复、跳帧与超限预算。固定依赖负向变异检查通过。
- Boundary: 完成检测器接入，不重新授予所有效果、泛化、真机性能或自动分割资格；旧 Vision 内部异常仍保留。见[完成记录](plans/history/2026-10/A-2026-10-09-mediapipe-sdk-integration.md)。

### C-2026-10-09-mediapipe-landmarker-probe

- Status: `completed`，限官方资源下载及仓库外独立 iOS 图片检测项目。
- Result: 官方 `face_landmarker/float16/1` 模型、MediaPipe iOS 1.1.0 的 Common/Graphs/Vision 三个运行库及三份 Apache-2.0 模型卡已完整下载；三个运行库均匹配官方 SHA-256。独立工程在已有 iPhone 15 Pro / iOS 17.5 上通过 **9 tests / 0 failures / 0 skips**。
- Verification: 真人/生成两个已授权本地正例各输出1脸、478点、1个有限可逆4×4矩阵和52个有限/有界表情系数；无脸/恢复、缺失/损坏模型、关闭可选输出和错误调用模式通过。同一输入20次重复，点/矩阵/表情最大差异0；预热后模拟器纯检测中位6.55ms，非端到端或真机性能。应用实际打开并检查肖像点位叠加。
- Boundary: 本次直接链接官方预编译组件，未声称完整官方SwiftPM入口接入通过；未接入BeautySDK、修改算法或重开终局目标。未评估独立标注精度、遮挡泛化、视频/实时流、方向矩阵或真机。归档、SDK-only boundary、示例存储及文档差异检查通过；未重签SDK全量门禁。见[完整记录](plans/history/2026-10/A-2026-10-09-mediapipe-landmarker-probe.md)。

### C-2026-10-09-document-cleanup

- Status: `completed`，仅文档删除与现行契约/导航修复。
- Scope: 删除重复原始导入和无接入/执行的孤立 Core ML 方案；六份根级 owner 从8,391行收敛为947行，更新实际参数/配置/库存、像素缓冲区纹理、无跨帧复用、GPU容量路线、九项opt-in和去脂未合格边界。现行索引隔离冻结历史，当前batch不再安排EYE G0；里程碑账本九个迁移前链接已修复。
- Verification: 当前链接/锚点与源码声明核对、两个archive验证、SDK-only boundary及其自测、wrapper自测14 checks/14 mutation rejections、示例图storage和`git diff --check`通过。代码/测试/脚本/归档/冻结契约与历史证据摘要不变；SDK未改，未重跑SwiftPM或图片/模型实验，不重签1076/0/0。
- Boundary: 历史只读记录内的旧路径仍按日期快照保留，详见[完整记录](plans/history/2026-10/A-2026-10-09-document-cleanup.md)。原有外部宿主修复和模拟器失败、本地锁/日志未覆盖；EYE/SEG终局不变。

### C-2026-10-09-owner-editor-debug

- Status: `completed`，限独立宿主的接线/参数范围、组合保留、关键点调试与预览调度修复。53 个可用工具位置连到 51 个字段；滑块按 SDK 各自 cap 映射，超出总预算只限制当前字段，保留之前的调整。
- Verification: 同一原生设备定向回归 `24/0/0`，额外 UI 复核 `1/0/0`；macOS 六个鼻子工具各四档、重复像素、CPU/Metal 一致性、原图/输出复检、透明回退与原尺寸 PNG 通过。生成图底栏截图和真人临时调试截图实际检查，后者暴露出检测漂移而非证明关键点准确。
- Remaining: iOS 17.5 模拟器的持续鼻子正例未通过；独立 Vision 连续同源检测同样产生越界点，未修复、不降低判据。原背景保护正例失败仍保留，真机速度未测。SDK 源码未变，本轮仅重新运行 boundary/storage/doc checks，不重复签发前次全量 SwiftPM。见[修复与失败记录](plans/history/2026-10/A-2026-10-08-owner-editor-debug.md)。

以下分项按发生时刻保留；较早记录的“Next”、pending、2/16等是历史快照，
不覆盖最上方终局状态，不产生自动续作任务。

### C-2026-10-08-agent-instructions

- Status: `completed`，仅指工作指引维护；不改变 SDK、算法状态或验证资格。
- Scope: 按所有者纠正，将两个 GitHub 账号与本仓库 SSH 用法只写入 [Git 操作指南](docs/operations/GIT_OPERATIONS.md)，由仓库 `AGENTS.md` 按 Git 任务触发读取。全局入口改为通用约束与五类指南导航，Serena 和真机签名细则单独存放；全局没有 GitHub 账号或密钥信息。
- Verification: 原全局 24 条规则逐项核对，Serena/真机细则原文保留，三个既有 iOS 指南摘要不变；全局入口从 5,869 缩至 2,567 bytes。本地链接、命令语法、post-archive SDK-only boundary 和 `git diff --check` 核对通过。
- Boundary: 本轮只改文档，未运行 SwiftPM、构建、设备操作或再次推送；本地锁/尝试日志保留。此前 `c2f5bc4f` 的成功推送只作为本仓库身份记录，不增加其他仓库的账号或推送授权。
- Record: [指引整理记录](plans/history/2026-10/A-2026-10-08-agent-instructions.md)。

### C-2026-10-08-owner-ios-editor

- Status: `completed`，指所有者明确新授权的独立 iOS 图片编辑宿主及核心导入/编辑/导出接线；不改变 SDK-only 仓库边界或算法效果资格。
- Scope: 相邻 `BeautyEditorApp` 工程根据 Figma 12 状态实现六分类、54 工具位置（53 可调用、51 字段）、撤销/对比/确认、原尺寸 PNG 分享与相册保存；未恢复历史 UI，未下载模型/权重。缺设计分类与去脂明确停用。
- Verification: 单台已有 iPhone 15 Pro / iOS 17.5 的基本测试 **20/0/0**，独立原生肖像人脸正例 **2/0/0**，系统相册真实保存与权限路径 **1/0/0**；截图、底部交互、安全区、八方向、P3/alpha、文件上限、导出与过期结果拦截通过。60 个 SVG 资源审计通过。
- SDK change: 仅模拟器 Vision 人脸请求按其支持的 CPU 逐阶段计算；完整 archive-first SDK 门禁退出0，**1076 tests / 0 failures / 0 skips、9 opt-ins**。物理设备/macOS 默认计算策略、API、Metal及算法资格未变。
- Limitation: iOS 模拟器人物分割正例未通过，空蒙版被拒绝并保持 OFF；失败和原强断言保留。相同生产 renderer 的 macOS 背景 ROI 保护通过单列，不能代替 iOS/真机资格。未真机安装或性能验收，不重开两个终局算法目标。
- Record: [独立宿主实现与验证](plans/history/2026-10/A-2026-10-08-owner-ios-editor.md)。

### C-2026-10-04-retouch-problem-review

- Status: `completed`，仅指[详细复盘报告](docs/history/retouch/RETOUCH_PROBLEM_REVIEW_2026-10-04.md)，不重开两个已关闭的自动目标。
- Scope: 对齐原需求/R2收窄/终局处置，复核上睑代理、环纹/重建、四版EYE与四版SEG、同观测反例和host辅助边界；明确经典问题分类、行业方案、模型未验证项和工程/效果混淆造成的推进问题。
- Verification: 依据冻结报告/聚合回执、Serena源符号及一手论文/官方文档；核对报告数字、本地引用和`git diff --check`。本轮受保护的1,773份既有源码、测试、实验/归档证据、规范及当前里程碑状态摘要未变。
- Boundary: 仅新增报告和导航记录；未运行算法、生成/修改图片、下载权重、训练或重跑SwiftPM。1076/0/0是已存工程检查点，不作为本报告的新执行或两个效果通过证据；5 verified/11 closed_unmet和空队列保持。

### C-2026-10-04-repository-disk-cleanup

- Status: `completed`。全项目约 **4.6 GiB → 696 MiB**，删除 23,447 个 ignored/
  未跟踪编译、索引缓存及重复工作输出，清理约 **3.92 GiB**。SDK/consumer
  及两处历史工具编译缓存均已核对；`.build` 中的冻结源和历史回执保留。
- Verification: 35 项冻结源/作者摘要有效，2,824 个非目标文件字节或链接目标
  不变；无活跃项目编译，语言服务未使用清理目标。归档验证、post-archive
  SDK-only boundary、示例图 storage 和 `git diff --check` 通过。
- Boundary: 源码/测试未改，本轮不重新编译以免再生成缓存；前轮 1076/0/0
  保留原检查点含义。历史 spike 媒体约 306 MiB、Git 186 MiB、归档 84 MiB、
  冻结输入/回执 34 MiB、示例图 29 MiB、Serena 22 MiB 及原有本地状态保留。
- Record: [盘点与清理记录](plans/history/2026-10/A-2026-10-04-repository-disk-cleanup.md)。
  不重开算法研发，不修改历史证据；后续构建和索引按需重新生成缓存。

### C-2026-10-04-example-image-storage

- Status: `completed`。删除 1,800 个可重建缓存/重复文件，`example-images/`
  从约 5.4 GiB 降至 29 MiB，释放约 5.3 GiB；28 个必要夹具/清单文件原字节不变。
- Change: [存储工具](scripts/manage-example-images.py)提供 check/clean/preview；
  总计限制 128 MiB / 160 图，input 16 图 / 32 MiB，展示图 32 张 JPEG、单张
  512 KiB、长边 1600 px。已生成约 255 KiB 的压缩展示图；原尺寸验收输出用完删除。
- Verification: 存储回归 15/0/0、编码实际像素/元数据案例 3/0/0、wrapper
  14 checks / 14 mutation rejections；最终 archive-first 全量门禁退出 0，
  **1076 tests / 0 failures / 0 skips、9 opt-ins**，含新容量检查及全部原前置检查。
  文档链接、必要夹具摘要、重复清理和 `git diff --check` 通过。环境缓存权限
  导致的早期失败不算通过，最终全量在自动批准的正常缓存权限下运行。
- Record: [归档计划](plans/history/2026-10/A-2026-10-04-example-image-storage.md)。
  原有终局文档本地修改保留，SDK/API/效果资格与历史证据未变。

### C-2026-10-03-v1-25-terminal-disposition

- Status: `closed_with_unmet_objectives`，工程收尾已完成，两自动目标未交付。
- Result: EYE最后三版加此前E1-v1均失败，SEG四版均失败；各2方法×2版本原预算耗尽，不重置或追加。保留去脂suspended/default-hidden和host辅助保护，无新自动入口。
- Evidence: [终局实验与结果](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)、[行业复核](docs/history/retouch/RETOUCH_INDUSTRY_DECISION_2026-10-03.md)；新控制1/0/0、测量3/0/0，但效果运行器退出1。首轮编译失败保留，候选字节未改。
- Closure: [16项终局需求](.planning/REQUIREMENTS.md)为5 verified/11 closed_unmet，无算法资格提升；[归档计划](plans/history/2026-10/A-2026-10-03-v1-25-retouch-repair.md)保留全过程，旧路径仅导航。
- Verification: 本轮实际archive-first全量门禁退出0，**1076 tests / 0 failures / 0 skips、9 opt-ins**；归档、SDK-only boundary、backend/consumer/CPU oracle前置检查通过。2,201个既有源码/测试/冻结证据摘要不变，受保护目录无新增实现；当前链接与`git diff --check`通过。[聚合回执](scripts/experiments/retouch-terminal/results/closeout.json)不保存原始日志或图片。
- Next: 无。当前里程碑、phase和next队列已清空；重开须所有者明确新范围和信息/资源。


### C-2026-10-03-current-batch-validation

- Status: `completed`，仅指[当前批量工具](docs/validation/CURRENT_BATCH_VALIDATION.md)及 BAT25-01/02；总需求2/16，Phase104的算法接入项及总里程碑未完成。
- Change: 新入口 `python3 -B scripts/current-batch/run.py`，独立98默认/99注册库存、两遍实际CPU输出、逐例像素/元数据/保护与明确oracle；通过、正常退出、效果失败、执行错误、缺项分列。旧75项wrapper/manifest/比较器保持只读。
- Verification: 工具17/0/0，含8真实像素控制和3文件/区域控制。默认98×2实际输出：7通过、91无脸正常退出，零失败/错误/缺项；自定义缺规则控制98×2：1通过、97未验证，正确退出3。
- Correction: 首轮误将skinCombo无脸退出列为必须提亮，退出1；原代码、契约和回执保留。依据既有resolver测试与DESIGN纠正，r1/r2全部98项测量及像素摘要一致，生产未改。
- Preservation: 2,179个既有源码、测试、脚本、冻结契约及历史文件摘要不变；SDK-only boundary、回执绑定、当前文档链接和`git diff --check`核对。未重跑完整SDK1076/0/0；不签98个人像效果、两个自动分支或设备资格。
- Next: 准备 EYE G0 的独立光影目标与控制；旧去脂保持suspended，E1-v1不直接续调。SEG四版预算耗尽，普通继续不追加候选。


### C-2026-10-03-seg-development-disposition

- Status: `completed`，仅指[有限开发比较与停止记录](docs/history/retouch/SEG_DEVELOPMENT_2026-10-03.md)。SEG 两方法四版本全部拒绝、原预算耗尽；自动功能、Phase 101 和 v1.25 均未完成，不追加第五版。
- Result: S1-v1 正/负例0/6、0/6；S1-v2为1/6、4/6；S2-v1为1/6、2/6；S2-v2为4/6、4/6且8/48比较保护硬失败，中肤色覆盖缺失。整图退出不计成功，冻结阈值、样本和原失败未改。
- Verification: 基线14/0/0，四候选各6/0/0仅为测量执行，效果运行器均退出1；正确 host 控制48项通过。观察/实际 public CPU/重复输出等价；接线前后153行基线及导出修正前后72行 S1-v1 一致。局部原尺寸视觉诊断已做，完整视觉资格、拒绝、旧唇回归、Metal和候选留出未做，不签 G1。
- Preservation: 2,111个既有源码、测试、脚本、冻结契约和历史文件哈希保持；SDK-only boundary、文档链接、聚合一致性和 `git diff --check` 核对。无生产/API/模型/训练变更；此前完整1076/0/0未重跑。
- Next: 继续独立的当前批量工具及 EYE G0 准备；旧去脂仍 suspended，E1-v1 保持拒绝，0/16需求完成。已完成的实验处置不代替两项自动功能交付。

### C-2026-10-03-seg-g0-freeze

- Status: `completed`，仅指 [SEG G0 验收准备](docs/history/retouch/SEG_G0_FREEZE_2026-10-03.md)。18 个独立源家族形成开发 12、留出 12、拒绝 6，共 30 逻辑案例、60 尺度栅格；SEG 全部 frozen，EYE 30 未准备，Phase 100 和 16 项正式需求仍未完成。
- Verification: 隔离 public CPU + 实际 Vision **20 tests / 0 failures / 0 skips**；96 项纹理控制、12 项拒绝栅格控制、128 次方向/镜像比较与输入故障恢复通过。支持覆盖 54.28–93.18%，平滑变化降低 33.92–56.12%，锐化增加 45.07–75.05%，保护违例与额外排除均为零。逐案例视觉记录、权利/来源/标记/栅格摘要及工具版本已冻结。
- Correction: 首轮回执收集失败，未计通过；改用独立原子聚合 JSON 后原输入原标准重跑成功。两轮 156 张本地复核图逐字节相同，旧版本和失败摘要保留。开发输入及判据未移动，没有算法预算重置。
- Preservation: 2,097 个既有生产/测试/脚本/历史文件摘要不变；SDK-only boundary、冻结绑定、60 案例状态、16 pending 需求、现行文档本地链接与 `git diff --check` 核对通过。
- Boundary: 留出只做 G0 可测性与正确 host 参考检查，候选留出评估仍为零；拒绝控制不是自动拒绝成功。生产/API/旧失败和上一轮开发控制保持不变，完整 SDK 1076/0/0 未重跑。下一步用冻结开发集验证自动候选；E1-v1 保持停止。

### C-2026-10-03-seg-g0-development-input-controls

- Status: `completed`，仅指 SEG 开发输入及局部控制。六个独立生成肖像形成 12 个配对案例、24 个双尺度栅格；完整 SEG G0 尚未通过。详情见 [进展记录](docs/history/retouch/SEG_G0_PROGRESS_2026-10-03.md)。
- Verification: 实际 Vision + public CPU 路径 **7 tests / 0 failures / 0 skips**，48 项效果控制通过；支持覆盖 54.28–69.69%，平滑变化降低 34.17–49.05%，锐化增加 46.63–65.40%，保护/alpha 无违例。观察器与公开输出逐字节一致；错网格恢复、neutral/repeat 和关键错误控制通过。这是正确 host 蒙版控制，不是自动识别结果。
- Corrections: r1 观察路径遗漏生产参数安全上限导致 8 个等价性失败，改为同一 resolver 后通过；r3 复核图未带家族前缀的问题在 r4 修正并重跑。原版本和聚合保留，皮肤 ROI、源栅格、贴片及阈值不变；补全脸外保护，未修改旧预检或生产实现。
- Preservation: 2,078 个既有生产/测试/脚本/历史文件摘要不变；SDK-only boundary、文档本地链接、回执与源码摘要绑定、60 案例状态、16 pending 需求和 `git diff --check` 核对通过。完整 SDK 1076/0/0 未重跑。
- Next: 开发 12 例为 controls_passed，其余 48 例 not_prepared，0 frozen。继续准备 SEG 的 12 个留出、6 个拒绝及其余控制/视觉复核，再冻结 G0；无自动候选或留出访问，方法/版本预算不增加，E1-v1 保持停止。

### C-2026-10-03-v1-25-development-pilot

- Status: `completed`，只指所有者允许的小规模预检。[结果](docs/history/retouch/RETOUCH_MVP_PILOT_2026-10-03.md)：S1-v1 在一个几何图家族的 12 正例/6 负例变体联合通过，保护无违例、平滑降低 50%、锐化增加约 250%、固定皮肤区支持 100%，负例双颊新增排除 0%。不是自然肖像或正式留出通过。
- EYE: E1-v1 全强度两眼分别改善 14.37%/0%，第一眼高通变化 13.45% 超过 10%；本候选拒绝并停止，不把单眼改善或降低目标当作整图通过。旧字段仍 suspended/default-hidden，两个正式效果都尚未交付。
- Verification: r3 控制 2/0/0（含 36 个 SEG 比较），候选测量 2/0/0，但运行器按真实判据退出 1；成功执行与算法失败分开。r1/r2 输入执行错误及源快照保留；实际 Core Image 预检定位缩放边缘 alpha，修加载器不改 SDK。两候选函数从 r1 到 r3 字节相同，每分支只用一个方法一个版本；未访问正式留出。
- Preservation: 2,063 个既有生产/测试/脚本/历史文件摘要不变；SDK-only boundary、13 份文档的 146 个本地链接与 `git diff --check` 通过。原尺寸输入/参考/候选代表图已查看，未授予上睑自然外观资格。正式 60 例仍未准备，16 需求仍 pending；此前完整 1076/0/0 未重新签发。

### C-2026-10-03-v1-25-g0-validation-design

- Status: `completed`，仅指 G0 的文档设计。新增 [验收准备方案](docs/RETOUCH_G0_VALIDATION_PLAN.md)与[逻辑案例清单](docs/RETOUCH_G0_CASE_MANIFEST.md)，两分支共 60 个唯一身份，全部 `not_prepared`；没有制作实际输入或实现验收器。
- Findings: 现有纹理函数只返回像素，新的处理支持覆盖指标尚无 public 观察面。方案规定以后使用隔离测试副本的请求内观察点，并先证明输出/错误/生命周期不变；不把变化像素数冒充覆盖，不新增公开原始蒙版。
- Verification: 60/60 身份唯一且开发/留出/拒绝数量正确，11 份文档本地链接/锚点通过，16 个需求继续 pending；`git diff --check` 通过。2,063 个既有代码、测试、脚本及历史文件哈希不变，受保护目录无新增实现文件。本轮未运行图片实验、SwiftPM 或新的候选。
- Next: 文档已具备可审查的实现交接。保持所有者“先规划、暂不写代码”的指示，明确进入验收器/输入准备实施后再执行 G0-A 至 G0-E；隔离实验、生成器和测试代码也属于实施。Phase 100 与效果资格尚未完成。

### C-2026-10-03-v1-25-mvp-requirements-r2

- Status: `completed`，仅指本轮需求规划与一致性核对。按所有者“降低初版标准、先规划不写代码”修订为 R2：自动上睑轻量光影修饰、可见边界同色贴片保护，有限覆盖/边缘误差、独立参考、G0–G3 和分支独立交付；未来强去脂/通用物体识别不作为初版门禁。
- Contract: [初版契约](docs/RETOUCH_MVP_REQUIREMENTS.md)统一定义数字和判定。先准备实际输入、验证正确/错误控制，再冻结并运行候选；不承诺任意未知输入皆可识别退出，也不把已有蒙版算自动成功。每分支有限开发预算，选定后一次留出评估，失败停止而不重置标准。
- Verification: 23 份现行/新快照文档本地链接和锚点通过，16/16 需求唯一映射 6 阶段，GSD 当前状态与下一步同步；两个历史归档和 post-archive SDK-only boundary 通过，`git diff --check` 通过。2,061 个既有代码/测试/脚本/档案和历史证据文件逐项哈希不变；降标前 requirements/roadmap 原字节复制为 R1 快照。
- Evidence boundary: 本轮无代码、测试源码、媒体/模型或已有历史证据修改，未运行新候选、生成新样本或重跑 SwiftPM。此前同日定向 5/0/0 与完整 1076/0/0 分别保留其原范围；新需求仍 0/16，G0 的实际输入/验收器尚未完成，去脂仍 suspended、99 注册/98 默认。
- Next: 按现行计划准备并冻结 G0 输入、独立目标参考与验收器；先证明验收有判别力，再做小规模算法可行性验证。

### C-2026-10-03-v1-25-milestone-creation

- Status: `completed`，仅指研究与里程碑建档完成，算法需求全为 pending。按所有者明确重开指示建立 v1.25：6 阶段、16 项需求，包括去脂新外观目标、命名同肤色遮挡域自动保护、唇区保护、当前批量工具与全量验收。预训练方法比较与资产准入分开，训练/微调不在本次范围。
- Research: 查阅 ABPN / ModelScope 官方 pipeline、Local Laplacian、FFaceNeRF、StyleRetoucher、FaceOcc / FaceExtraction、BiSeNet、FaceXFormer、SAM 2/3 的一手论文、作者代码/README 与相关许可；记录模型卡无法取得正文、权重/上游许可待核以及本地 CUDA 路径限制，未下载/执行候选。
- Verification: 16/16 需求各映射一次至 Phase 100–105；21 份现行/快照文档的 222 个本地链接（含 1 个锚点）检查通过。2,061 个既有生产、测试、脚本、档案和历史证据文件逐项哈希不变；旧当前 roadmap/requirements 原字节复制到新历史快照，既有 phase 目录/锁/回执未移动或改写。`git diff --check` 通过，GSD 当前里程碑识别为 v1.25。
- Boundary: 本次无生产算法/API 变更、模型推理/转换/训练、图片实验或 SwiftPM 重跑。此前真实完整检查点 1076/0/0、9 opt-in 未重新签发；旧自动探针 4/6/0 和去脂自然挑战 1/2/0 保持历史失败含义。去脂仍默认隐藏、效果 suspended；新研究授权不等于资格提升。
- Next: [现行计划](plans/active/A-2026-10-03-v1-25-retouch-repair.md) Phase 100，先冻结输入/目标/oracle。两自动效果需求未通过，不得以隐藏或研究处置按完整目标结项。

### C-2026-10-03-host-texture-protection-integration

- Status: `completed`。新增主机物体 + 完整唇区并集蒙版的公开路径回归与[接入说明](docs/sdk/HOST_TEXTURE_PROTECTION.md)。在原冻结生成源、双肤色与原目标/保护谓词下，物体与完整唇区源精确，对侧平滑变化降低至少 20%、锐化增加至少 10%。该额外主机信息不是自动分割，通用自动物体识别和去脂继续暂停；无蒙版粗略唇域未修复。
- Verification: 新回归 **4/0/0**、与原物体蒙版回归合计 **8/0/0**；64 个方向/镜像效果组合、CPU/GPU-selected 既有纹理路径、内存 PNG、neutral/repeat、RGB/alpha/extent/sRGB、全排除/无脸/平坦皮肤、错误网格恢复与后续无蒙版状态检查通过。接入示例通过 `swiftc -typecheck`。
- Full gate: `bash scripts/run-no-skip-swiftpm.sh` 实际返回 0，**1076 tests / 0 failures / 0 skips，9 opt-in**，archive-first 与 SDK-only boundary、backend/consumer/CPU oracle 门禁通过；wrapper 自测 13 checks / 13 mutation rejections 通过。最初静态门禁因新测试尚未登记既有 backend 引用而停，登记固定源摘要并 mutation 自测后重跑通过，未新增或放宽 GPU API。
- Preservation: 1,756 个既有生产/测试/脚本/历史文件中，仅边界脚本按既有审阅哈希机制登记新测试及追加声明拒绝自测；其余 1,755 个文件逐项哈希不变。原自动失败挑战 SHA 与 4/6/0 结果保持不变。文档链接与 `git diff --check` 通过，未改生产算法或公开 API。
- Record: [归档计划](plans/history/2026-10/A-2026-10-03-host-texture-protection.md)。后续任务需从明确的新范围进入，普通继续不重开已暂停算法。

### C-2026-10-03-texture-semantic-feasibility-disposition

- Status: `completed`，指有限可行性验证与范围处置完成。通用无蒙版同肤色物体自动辨认仍未完成且暂停，不提升效果状态；保留正确显式蒙版。原 15 项限定二维效果资格不变，去脂不重开。
- Result: 相同完整可观察输入不能满足矛盾材质语义输出；唯一周期纹理候选在保护物体时同时停掉有效皮肤处理，拒绝接入生产。新深肤色低对比唇缘越出粗略域的完整保护仍失败，作为未修复限制记录。
- Verification: 冻结挑战原宿主及外部临时 SwiftPM 包均为 **4 tests / 6 assertion failures / 0 skips，退出 1**，原显式蒙版回归 **4/0/0**；失败标准未改。完整 `bash scripts/run-no-skip-swiftpm.sh` 实际返回 0，**1072/0/0、9 opt-in**，archive-first、SDK-only boundary、wrapper 自测通过。两类结果分开引用；最初构建权限失败无测试结果，不算效果证据。
- Preservation: 1,751 个既有生产/测试/脚本/历史文件哈希未变；文档链接、Python 语法及 `git diff --check` 通过。没有生产 API/算法改动，没有模型、训练或设备声明。
- Record: [冻结结果](docs/history/retouch/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)、[全文归档计划](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)及[新月度索引](plans/history/2026-10/README.md)。以后若扩展自动能力，需明确可观察的新域和独立正负例后另行授权。

### C-2026-10-01-all-feature-completion-inventory

- Status: `completed`。完成[全部功能与完成状态清单](docs/history/audits/FEATURE_COMPLETION_INVENTORY_2026-10-01.md)：逐项列出 77 参数字段、11 配置字段、5 预设、2 滤镜及 SDK/工程支撑项目；将限定范围内已完成、当前活跃缺口、去脂暂停、未覆盖能力和范围外产品面分别标明。63 行旧控制映射全部由参数表覆盖，别名不计成独立算法。
- Verification: 参数/配置字段与源码、控制映射与现行 taxonomy、资源与 manifest 静态逐项核对通过；本地链接、post-archive SDK-only boundary、保护文件哈希及 `git diff --check` 通过。仅盘点文档，未重跑 SwiftPM 或图片效果验收；此前 `1072/0/0` 保留原检查点含义。
- Remaining at 2026-10-01: 盘点当时的活跃能力缺口为无排除蒙版时同肤色非皮肤物体自动辨认；该项后于 2026-10-03 有限研究处置中暂停。去脂暂停、历史批量 wrapper 库存技术债和其余泛化/输入/设备限制均按原状态列出，本清单不创建新研发任务。

### C-2026-10-01-current-document-drift-repair

- Status: `completed`。修复[项目审计](docs/history/audits/PROJECT_STATUS_AUDIT_2026-10-01.md)的 D01–D03、D05–D07 六组漂移：统一 `.planning` 当前状态/恢复入口，明确旧回执和旧代码地图的历史范围；产品正文收敛为原 15 项最终二维适用域，移出中途 partial 叙述；可靠性说明区分整脸上下的 provider 五点与静图刚性平移，并区分九个 opt-in 测试身份和五个显式环境输入；动态源码库存改为带日期的单一记录与复算命令。
- Verification: 两个 legacy 归档、post-archive SDK-only boundary、mandatory wrapper 自测（13 checks / 13 mutation rejections）与 `git diff --check` 通过；19 份文档的 171 个本地链接（含 2 个锚点）和 1 个入站锚点引用通过；15 项控制与 taxonomy、77 字段、99/98 清单、九个测试身份/五个环境输入静态核对通过。2,144 个受保护代码/脚本/既有历史证据文件哈希未变。仅文档修复，未重跑 SwiftPM 或效果验收；此前 `1072/0/0` 保留其原检查点含义。
- Remaining: 历史批量 wrapper 的 75 案例限制仍为独立技术债；同肤色物体无蒙版自动辨认仍是当前能力缺口。去脂继续 `suspended`，不恢复研发。

### C-2026-10-01-project-status-and-document-drift-audit

- Status: `completed`。完成[项目进度与文档漂移审计](docs/history/audits/PROJECT_STATUS_AUDIT_2026-10-01.md)：当前 77 参数、99 注册/98 默认案例、63 taxonomy 行中的 62 implemented + 1 suspended 与源码/现有测试对齐；原 15 项限定二维验收已完成，去脂暂停，同肤色物体自动辨认仍未完成。
- Findings: 确认 6 组文档问题，包括 `.planning` 当前状态/旧回执恢复入口、产品段落仍称 partial、上下移动路径、重复库存和 opt-in 测试/环境变量数量。纹理旧描述已有明确替代说明，已排除为当前漂移。确认项已记入技术债，本轮未批量修正文档、未启动旧阶段或算法研究。
- Verification: 归档验证、post-archive SDK-only boundary 和 CLI 只读清单通过；2,188 个代码/既有历史基线文件未变。最近完整门禁仍为此前实际执行的 `1072/0/0`、9 opt-in，本轮不重复签发。报告列出每项代码/测试依据及审计局限。

### C-2026-10-01-upper-eyelid-document-contract-rewrite

- Status: `completed`。按所有者要求重写去脂文档：以实际有界亮度修正说明现有机制；取消“已实现/弱效果可用但继续优化”的现行承诺，明确自然外观效果未合格；从当前计划和技术债移除重复实验及旧执行指令。历史事实与失败证据保留，暂停不等于算法完成。
- Verification: 27 份文档的 182 个本地链接（含 1 个锚点）、post-archive SDK-only boundary、`git diff --check` 与交叉复核通过；2,188 个受保护代码/既有历史文件的逐文件哈希未变。项目技能中的旧续作说明也已同步清理，原 spike 源未改。本轮仅文档，未重跑 SwiftPM、未重启算法实验；此前 `1072/0/0` 是代码变更检查点结果，不冒充本轮新测试。

### C-2026-10-01-upper-eyelid-suspension

- Status: `completed`。按所有者允许的收尾方向，暂停去脂研发并从 SDK-owned renderer 默认清单、批量和推荐示例隐藏；保留 public 字段、显式 CLI 旧名、安全回归和失败证据。自然图效果未合格，不把处置完成写成算法完成；只有明确重启授权才恢复研发。
- Verification: 新增真实 CLI 默认批量与显式兼容测试 `2/0/0`；完整 `bash scripts/run-no-skip-swiftpm.sh` 返回 0，`1072 tests / 0 failures / 0 skips`、9 opt-in，archive-first 与 SDK-only boundary 通过；边界脚本自测及独立审查通过。当前 77 参数字段、99 注册项、98 默认项。详情见 [归档处置记录](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)和[质量记录](QUALITY_SCORE.md)。

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
