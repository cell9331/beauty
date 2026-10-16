# A-2026-10-14-face-reference-protection

## 2026-10-16 当前终止决定

所有者明确要求即使未完成也保留现有实现并统一合入main，本次到此结束。
本轮未实现的外观/保护目标按`closed_with_unmet_objectives`结清，不改写旧失败、
阈值、历史限定通过或照片证据。以下旧下一步、待授权模型和候选计划不再自动执行；
换思路需要新的明确范围。统一整合记录见[本轮收尾](../history/2026-10/A-2026-10-16-integrate-retained-effects.md)。


| Field | Value |
| --- | --- |
| Status | `closed_with_unmet_objectives`（2026-10-16 所有者结束本轮） |
| Owner | Codex |
| Started | 2026-10-14 |
| Scope | 独立分支核对脸型参考响应与保护；当前按所有者选择保留流畅C48，修发际线/下颌光度，两项去双下巴置灰，脸宽/太阳穴/颧骨冻结。 |
| Source Request | 所有者要求新建分支，对照提供的脸型材料，修复不佳效果并保护其他内容。 |
| Expected Behavior | 脸型有明确、平滑、连续的目标变化；鼻眉眼嘴细节、目标域外内容与alpha保持。参考缺失的零态/数值不假定存在。 |
| Current Step | 现有代码按新授权合入main，本轮到此结束；未达标缺口保留，不继续旧候选或模型评估。 |
| Verification Policy | 八项连续脸型、公开CPU/Metal路径、脸型修整及实际参考图的方向/幅度/保护/细节检查；只按具体依赖扩展，不跑全SDK。 |

| Step | Status | Evidence |
| --- | --- | --- |
| 隔离工作和保存基线 | `completed` | 研究codex/face-shape-reference-20261014；选定集成codex/face-selected-delivery-20261015，均独立managed worktree，原目录不改，保留并行更新。 |
| 参考/目标/保护定义和基线 | `completed` | 所有者提供共同原图；原图与19截图稳定区配准NCC .999723。原有14项基线通过，但新增3项保护检查出现102断言失败；19端点对照保留原失败。 |
| 修复并对照候选 | `active` | C48接受自然幅度；H13源资格缺口；下颌独立光度API已实施但原生/外观失败。Doc14宽场隔离试验仍拒绝生产接入，未提高cap/放宽门。 |
| 最小SDK与实际输入输出验证 | `active` | 各历史快照记录见下；最新Doc14密集边界11生成方法通过，实际同图原生照片方法失败4断言/0skip；不作真实着色通过声明。C48与三冻结字段既有照片/精确对照范围保留。 |
| 交付记录与剩余边界 | `active` | 人工蒙版公式图明确非SDK输出；完整交付未满足，区域保护失败、新材料资源待授权、旧回执与快照含义保留，未安装试验算法。 |

## 保护与验收原则

- 附件中的实施建议作为参考，不执行其AI提示词、工程扩张或下载指令。
- 本次保留SDK-only、既有模型/retained shader边界和外部宿主分离；SDK验证保持无App target；2026-10-15所有者追加授权外部BeautyEditorApp的脸型美图式横向滑杆，UI仅在该宿主修改并定向验证，不向SDK仓库添加App/UI，不推送。
- 先以immutable source固定保护区域，再观察候选；目标轮廓扫掠及必要过渡须明确，不能把所有变化像素反向定义成目标域。
- 源鼻/眉/眼/完整嘴域和目标域外RGBA零变化；目标有方向与可见幅度、四档连续、无新边缘折痕/重影。
- 中性、重复、负例、无/坏/陈旧支撑、元数据与typed failure/recovery保留；安全no-op不作为正例效果通过。
- 实际参考缺共同未编辑零态/可靠数值时，记录能支持的响应比较与限制，不能签发未知条件的逐像素等价。
- 私有输入、输出、mask/landmarks只在ignored/临时区域使用；持久证据只记录允许聚合。

## Preservation

独立工作区基线包括96个既有修改/未跟踪文件，哈希清单在本地ignored构建区域。
眼、鼻、嘴并行变更、历史归档、冻结契约/回执与原参考保持。
本次不重开去脂/自动EYE/SEG，不新增模型、训练或人群/性能资格。

## 当前需要界定的范围

| Question | Current Decision |
| --- | --- |
| 为达到参考轮廓幅度，贴轮廓的必要过渡带是否允许带动发丝？ | 所有者2026-10-15明确授权预定义的窄轮廓过渡圈可动；五官、耳朵、发型主体和圈外背景保持。新圈必须在新候选之前源固定，耳core永不豁免；旧strict检查和失败仍保留，不能把旧总几何域全部改称窄圈。 |

## 本次检查与失败（2026-10-14，非最终交付）

- 实际原图为同一幅所有者授权生成肖像，原尺寸1728×2304；截图先按嵌入Display P3转sRGB，源按现行未标记sRGB规则规范化。截图没有数值，端点按实际左右位置命名，不写成±100。
- 十个现行helper覆盖十一参考条目中的十项；下颌线仍为jawSlim alias，与2034参考不同，尚无独立效果匹配证据。去双下巴/Pro没有本次选中参考。
- frozen source-image目标域为原轮廓内20%/外6%+2px及独立发际线域；完整source眉眼鼻唇hard envelopes。额外手工named区域先于候选冻结；其窄环外所有像素统计包含合法内侧皮肤，须与named语义保护区分别报告，不反改旧mask。
- C1源材料硬裁虽通过11相关测试，但原照片出现尖黑楔/双边，拒绝交付。C3取消材料硬裁、改固定窄带平滑衰减；旧下巴与15/26像素近背景挑战仍失败。C4近背景/接缝通过，但旧下巴凸性失败。C5解析小脸inverse后原12项全部通过，旧阈值保持。
- 发际线H1竞争曲线负例失败；H2修旧soft成功绕过竞争检查的短路，原色彩/alpha/斜率/刘海阈值及headWrap硬边资格保持。原图诊断证明preview的新source分支有效；旧代理点空会清零请求，H3改planning mask/dispatch并保留真实point count。
- C6扩完整眼/眉/唇材料collars并合并同器官dense框；与H3和直接调用路径27项Release测试0失败/0跳过。actual Metal只由生成公开face-slider案例证明，不是本次照片Metal或原生MediaPipe证据。
- 照片C6/H3全十项能力：执行1方法/8断言失败/0跳过；面部流畅仍noop，原尺寸发际线仍noop，preview发际线已活跃但越出预先定义的source域。整张参考效果尚未合格。
- 初始照片matcher的coarse搜索和三点抛物线有source-only错误；前向source-bilinear预测修复大误差，但600控制中的少数完整合法full-resolution分数仍偏差>.1px，保持失败/不可判定。不得用测量器修正掩盖实际保护/目标失败。
- 新测试的RGBA身份断言使用boolean精确比较，避免失败打印raw像素。本轮曾生成的数组失败日志已去除raw payload，保留原失败方法、counts与allowlisted聚合；既有历史证据不改。

## 后续实际检查（2026-10-15，仍未交付）

- C7增加固定上侧头部attachment几何reserve；C8/C9局部投影替代单一最陡collar对全脸的衰减，smallFace保留解析inverse。C11按参考修正下颌角负向、V脸和尖下巴宽向响应。C12合并相距不足0.125源像素的lattice knots，避免数值病态；梯度.45、6%位移和原保护门保持。
- C13源固定attachment资格支撑已进入实际RGBA调用；严格skin/cleft/outer-attachment gate在本图两侧都未准入，不能写成已恢复颧骨幅度。生成6方法通过，原图rejection诊断保留。正在验证独立的inner-skin recovery，未知外侧仍保留。
- 流畅S4恢复持续头发保护，旧15项ObservedCheek方法通过；实际原图有1078变化像素、preview仅3，不能签为可用流畅效果。新generated方向/粗糙度与公开preview检查仍失败。
- 发际线H5-3使用同一source cap形态、保守源材料footprints和有界物理分析，原尺寸/preview四档一致性检查通过；generated512横发丝图的连续候选仍断裂，继续修复，不能用退出通过正例。
- 单台已有iOS17.5模拟器、无App target的SDK测试实际执行MediaPipe推理。基线全十项端点1方法/10断言失败/0跳过：preview流畅幅度不足，原尺寸流畅47像素越出几何域，发际线两向分别9116/9122像素越出预先定义域。其余端点在该几何保护检查中为0，但独立精细语义core检查仍显示发丝牵动，不能宣称完整区域保护。该原生结果对应修正前的固定二进制，后续候选须重建重测。
- source-only测量器控制保持0.1像素界限。C14的16失败都来自无法证明量化兼容区的有限不确定度；C15连续二维兼容域微型2方法仍16失败，没有实际byte-compatible见证。保留原失败，不用高NCC或近似位移替代测量资格。
- 原先人工粗mask包含部分皮肤/颈衣，保持冻结；后续细语义core由原图单独冻结。两类统计分开报告，不把候选变化像素改成允许区。实际轮廓扫掠与固定外侧材料的冲突仍需明确处置。
- SDK-only live check及其mutation self-test通过；仅更新经逐项审核的脸型滑杆测试摘要，保留Metal/GPU/backend保护。未执行完整SDK。

目前不声明完整美图外观、完整耳/发丝/颈部语义保护、真机、性能或全量SDK通过。原生MediaPipe只声明上述固定基线的实际执行与失败。只修改独立worktree；无提交/推送或外部宿主编辑。

## C16 定向进展（2026-10-15，非最终交付）

- `swift test --package-path BeautySDK -c release --filter` 选择两个连续测量micro、attachment10方法及相关滑杆/连续场/保护：26方法/0失败/0跳过。测量器在同搜索域严格核对全部243 rounded bytes的真实见证，再给出兼容域不确定度。
- `--skip-build --filter BeautyEngineFaceReferenceTests/testSourceOnlyQualifiedDirectionalObservabilityAnchorsV2`：1方法内300个已知位移控制全部通过，0.1像素界限保持。旧16失败记录保留。
- 局部投影64轮使实际faceWidth cap residual梯度由.639降至.498、下巴长短由.526降至.456，最终梯度界仍.45。actual严格attachment0/newinner0，不能声明该恢复分支已改善本图。
- `--skip-build --filter BeautyEngineFaceReferenceTests/testEightSourceFixedPhotoControlsOrGeneratedNoFaceRecovery`：1方法/56断言失败/0跳过；当时五项四档目标断言通过依赖未取得实际非均匀测量资格的fit，已在下节撤回效果资格。所有120输出的源几何feature/exterior/alpha检查为0变化；这是几何保护，不是额外完整发丝core合格。
- 当前renderer另外输出19个preview候选并与19参考对照，旧大型固定模板的失效/不可判定仍保留；不会用模板高NCC和活跃像素改写目标/语义保护失败。

## C17 / C18 进展与测量资格修正

- C16五项方向断言通过仅说明当时的nonuniform least-squares读数过门，未证明该模型在实际非均匀形变的精度；现撤回其实际方向/幅度资格。脸宽反向值来自另一块未编辑静态纹理的alias，不是已证明的生产方向反转。新测量器对这类fit返回typed inconclusive并继续全部控件；300个常量位移控制的既有通过仍保持原范围。
- C17 Release定向68方法/3942断言失败/0跳过；其中新增departure分支有3方法3940失败（大量是同一wholeouter保护的逐像素assertion），流畅公开preview及新generated粗糙度各1失败。失败回执保留；随后把逐像素完全相同要求聚合为零变化count，避免重复日志。
- C17实际全十项能力1方法/10失败/0跳过。发际线仍越出冻结manual source band，流畅preview仍弱；活跃不等于保护/外观交付。
- C18 Release定向66方法/18失败/0跳过：attachment12、连续场/滑杆/保护14、planning4、Hairline8、旧ObservedCheek15均通过。新source-edge source-only1方法12失败，公开preview1失败，新generatedsmooth1方法5失败。新source-edge总60预登记候选全部不合格，23控制bank未执行，不能写成测量验证通过。
- C18 departure只证明强暗departure之前的内侧皮肤，不赋予外侧材料编辑权；外侧整片到图像边缘继续reserve。原图严格/inner两分支均0，新增departure右侧25行/1侧取得资格，左侧仍退出。
- S6纠正clean-analysis邻近头发保护距离的物理单位：直接preview有61变化像素（原3），max shift .913源像素（原.092）；公开preview只有9变化像素仍未过原16门，生成源固定邻域出现19/22变化像素且cap粗糙度仍失败。保留旧源定义保护predicate及数值，不以放宽门交付。
- 局部投影所有15个原尺寸cap的节点方向反转计数为0；这仅是场诊断，不能替代实际像素方向测量。

## C19 至 C22 的有界修复与实际范围

- C19独立source-edge生成bank一方法内23个已知非均匀形变控制通过；原图source-only一方法仍12失败，60个预登记候选均不可资格化。其主要限制是完整采样footprint和原core冲突、色彩分离不足或多边界。未运行该新模型的实际方向方法，不能把生成控制通过写成原图测量合格。
- C19两层原图hairline源诊断发现曲线约71%在冻结目标band内，约29%在外；作用半径并未超过预定band半宽。问题是亮发丝/肤色候选归属，不能通过改band掩盖。诊断方法通过只证明记录完整，不证明发际线效果。
- C20 S7/hairline/旧cheek共37方法/4失败/0跳过：旧source保护保持，流畅生成粗糙度和实际preview活动仍失败。其过宽暗材料halo及全局拟合候选保留为失败。
- C21 H6共12方法/0失败/0跳过，新增源连接皮肤/金冷色竞争/断开/鼻部矛盾/alpha负例通过。实际原图额头肤色prototype因单块鼻点颜色冲突拒绝，两层发际线均no-op；生成门通过不赋予原图正例资格。
- C22 S8共30方法/0失败/0跳过：3个公开流畅、11个生成流畅、15个旧ObservedCheek及1个hairline源诊断。S8使用原物理带宽限制完整细发丝halo并以源曲率fairing替代全局曲线拟合，旧保护、粗糙度和四档阈值保持；公开原图full/preview最小活动门已通过。直接流畅两层分别1409/112变化像素、alpha均0，最大位移2.333/.885源像素。这是局部流畅可用性改进，尚无对应当前PNG外观/参考幅度/原生MediaPipe资格。
- C22发际线两层单块鼻patch均报告红/蓝颜色冲突，同时预登记的三个桥部patch均与额头prototype相容。后续假设是替换错误的单块选择、要求多块独立corroboration；不得放宽原family/竞争阈值。现仍不声明原图hairline正例。
- C18另行固定语义core统计显示多项连续场牵动发丝主体。手工恢复core的本地原型只能支持自动材料归属/最终合成的下一假设，不能作为SDK候选、生产mask或交付通过。自动源归属必须在候选之前建立，未知材料拒绝，source core不得被复制，destination core保持原像素。

## C23 当前公开路径的实际限制

- H6-3替换单块鼻patch为三个预定桥部patch的AND corroboration，颜色/luminance/MAD门保持。Hairline14方法/0失败/0跳过；实际两层prototype及三个patch通过，但分别92/173、93/174列没有未保护可信peak，曲线仍不完整，发际线两向均no-op。继续诊断source family/connection/branch，未放宽旧门或目标band。
- 当前S8/H6-3公开全十项端点一方法/6失败/0跳过：发际线四个no-op，流畅两层RMS分别.221/.118低于原.25门。流畅的最小变化像素门通过不覆盖这个更强的幅度门；不通过放大残差或改变门槛签发参考效果。全部36输出repeat、metadata、几何features/exterior/alpha检查为0变化。
- 当前PNG放大检查未见旧黑楔、双轮廓或明显接缝，但流畅整体变化很轻，未取得参考跨度/外观资格。独立冻结细core统计中，完整眉眼鼻唇耳均0；连续八项多有hair-core改动，太阳穴另有crossing-hair改动；流畅full仍16个hair-core像素改动、最大RGB差9，preview为0。该16位于混合肤色/头发边缘，原dark70/alpha/几何footprint门不是完整语义材料证明，失败保持。
- 下一候选仅对脸宽/太阳穴/颧骨验证不可变源材料归属。unknown/证明core固定，完整source footprints阻止core复制；源C1约束在最终恢复之前限制位移。局部安全拒绝仍不能替代目标效果通过，自动分类不读取任务人工mask。

## C24 源控制与材料候选（尚未接入公开脸型）

- 新context-v2 observer允许只读opaque protected RGB作为定位上下文，不赋予生产搬运权。生成24-bank、独立core-composition及弱/竞争/透明/plateau负例三方法通过；原图source-only一方法8失败/0跳过。脸宽full/preview两侧共4 slots、96个已知inverse-Frobenius≤.45且位移≤6%的控制通过，最大误差.047837像素；太阳穴/颧骨其余8 slots不可资格化。预登记60候选实际因first-qualified选择只检查44，未声称全部60执行或全脸测量合格。控制本身可移动背景作校准，productionQualified=false；固定core下受裁剪的truth单独测，不能继承完整位移。未用SDK候选选点。
- 初次C24编译因诊断Mirror泛型不匹配失败，最小修正为KeyValuePairs。随后测试夹具用2点malformed brow却访问第三点，xctest signal5中断；修正夹具为保留4点仅首点NaN。两次失败日志保持，不声称该中断已执行完所选检查。
- C24r2材料候选12方法/5失败/0跳过，hairline source诊断2方法通过，共14方法/5失败。材料候选生成mixed正例两处0，uniform headwrap误标头发，原图两层seedUnavailable；未接入SDK连续场，也未宣称自动语义保护通过。继续修复源证明/纹理分类和皮肤采样，不靠fallback扩大编辑权。
- 发际线冻结band内可信候选full2420（branch0、family1886、connection356、retained178），preview2477（branch0、family1936、connection355、retained186）。证明global肤色family和连接是当前拒绝主因，不能通过削弱发丝保护门解决。下一源假设验证局部光照连续性和独立皮肤连接，同时保留竞争曲线、矛盾颜色和alpha门。

## C25 至 C28：源归属及公开脸宽的实际检查

- C25源归属13方法/2失败/0跳过：生成方法通过，原图两层几何采样种子仍落入feature reserve而拒绝。后续采样只在预定侧脸格内按几何距离选择，不用颜色重试寻找有利种子。C27源归属15方法/0失败/0跳过，两层原图均取得材料证据；这只证明源分类可运行，未证明SDK输出受保护。
- C26公开脸宽context-v2一方法/58失败/0跳过：两层、两侧、四档的预定上侧脸宽探针位移均为0；完整hair core仍被牵动。几何features/exterior/alpha、中性、重复及metadata通过。参考同弧仅原尺寸右侧取得当时的身份校准，显示端点位移约17.38/18.76像素，SDK为0；其余弧的真实原图身份校准失败，保持不可判定。生成24控制自洽不能代替真实配准身份资格。后续修正像素中心坐标转换尚待重测。
- C27发际线H7新增光照/颜色挑战失败，17方法/8断言失败/0跳过；旧15方法通过不能覆盖新挑战。H8收紧为源RGB共同衰减解释并保持全局颜色家族、完整列、竞争、alpha及冻结目标域，18方法/0失败/0跳过；原图两层仍没有完整可信曲线，仍为no-op。原失败及原输入保留，不以改目标域交付。
- C28源归属18方法/3失败/0跳过，失败来自mixed材料正例与新增几何attachment reserve的相交；H8的18方法通过，共36方法/3失败/0跳过。源editable区域与独立细core的相交已减少，但仍有部分hair/crossing-hair混合边缘，不能由分类统计签发精确保护。新增细发丝ridge只在生成源中取得证据，本图没有该证据。
- 当前三项侧脸候选要求独立源归属，unknown/core不可编辑、完整source采样足迹不得搬运core，最终合成恢复当前stage的固定像素；保留原几何attachment、.45梯度及6%位移界。此接入尚未编译验证，其他连续脸型及组合不据此获得保护资格。
- 已向所有者明确上侧轮廓幅度与紧邻发丝固定的冲突，等待界定必要过渡范围；未据默认选项或等待时间扩大编辑权。当前按保守保护继续验证。

## C29 至 C32：材料保护接入与颜色顺序修复

- C29 Release编译及定向62方法/3失败/0跳过，源码在执行期间固定。源归属23、连续场/保护11、公开滑杆3、planning4均通过；H10发际线21方法中，合法阴影正例在960分析尺度有3失败。mixed只读材质分类与几何编辑权分离后，旧输入/位置/断言原样通过；新增三字段独立源标记双向四档移动、已知发丝含AA/背景/五官固定、无core复制及拒绝无证据均通过。
- C30公开原图两方法/50失败/0跳过。脸宽32个四档/侧别观察中，独立冻结core、域外和alpha全部0变化，上侧色边位移全部0；46失败来自方向/端点活动及已校准参考幅度。像素中心修正后，原尺寸右侧及预览两侧共3弧通过24控制及真实原图身份门，参考单侧位移约15.52–18.78display像素；原尺寸左侧真实身份误差.178659仍不可判定。未用候选改探针或放宽.1像素门。
- 同轮限定颜色组合实际执行CPU/Metal的16个输出，当前颜色baseline的fine core/域外/alpha、lower响应、repeat和neutral均通过；4失败为颜色+脸宽输出RGB最大差6/6/3/4，超过原2门。C31补诊断label后确认只有颜色组合失败，pure脸宽通过；H11发际线21方法/0失败/0跳过，两者共22方法/4失败。H11只补齐原固定额头ROI的物理core采样覆盖，保持合法阴影和暖棕伪曲线原输入、色域及容差，不能作为原图发际线正例资格。
- 具体缺陷是CPU着色后建材料证据、Metal着色前建证据。修复在现有颜色/geometry caller显式传入同相位、同尺寸的着色前sRGB源证明，仅三字段使用；采样和最终恢复仍用CURRENT阶段字节。错位/损坏而存在的证明保持拒绝，其他continuous字段不使用此proof。保留backend/shader代码；与磨皮/锐化及其他几何组合退出，12项固定坐标颜色字段保留。
- C32当前Release39方法/0失败/0跳过：源归属24、连续场/保护11、公开滑杆3、公开颜色/actual Metal1。新增stage测试证明raw proof有效而着色后资格无效时，结果仍等于raw-qualified map采样CURRENT；current core/alpha精确，PRESENT空proof无fallback，其他字段兼容保留。实际颜色组合回到原RGB容差，未扩大门槛。H11源码未再变更，其21方法通过范围仍保持；没有执行完整SDK。

## C33 至 C35：当前照片及原生范围

- C33十项公开端点1方法/12失败/0跳过，36输出的几何features/exterior/alpha及repeat/metadata检查通过。失败为两层太阳穴四端点、预览颧骨两端点、流畅两层幅度和发际线四端点。独立V2 named core复查中，三项源保护路线全部0变化；其余19输出仍有hair core变化，流畅full仍16。该统计保持原mask，不把已变像素改成目标。
- C34当前二进制的公开脸宽四档1方法/46失败/0跳过：32观察的fine core/域外/alpha仍0，上侧色边仍0位移，保留真实参考幅度失败。C30/C31/C32/C33/C34的失败/通过各自对应其注明源码与输入，不互相替代。
- C33原生为无App target的SDK hostless、单台已有iPad Pro 11-inch M4/iOS17.5模拟器，先确认无其他测试活动并原子claim；原iPhone被其他任务占用，未抢占。MediaPipe/XNNPACK真实执行，1方法/29断言失败/0跳过、36输出，使用额外冻结fine-core mask。三项源保护路线均无该core/exterior失败，太阳穴活动不足；其余小脸/下巴/下颌角/V脸仍有core改动，流畅full2121个core及47个几何域外像素改动、preview幅度不足，发际线四端点仍未满足。原生进程完成后claim已释放，无设备/方向/字体矩阵、无宿主修改。此轮包含比旧基线更细的core检查，不能按失败数直接比较退步。
- 原生快照固定于C32算法及当时的测试二进制；随后C35只修内部qualifier对PRESENT空/过短eye support的强解包风险。公开map原先已拒绝此输入，保留legacy count/mean，不扩大准入；25个源归属方法/0失败/0跳过，含左右空/3点/NaN typed拒绝、有效不变正例及原图源诊断。没有把该新增内部guard说成已在上述原生二进制执行。
- 当前正在定位原生流畅的47个域外像素来源；不通过移动冻结domain、放宽core或扩大幅度门修复。完整交付仍未满足。

## C36 至 C39：流畅采样所有权、原域与注册相位

- 已定位两个执行缺口：source-raster修整后仍能保留smooth coarse/dense代理；旧wide/subpixel采样只跟随搜索到的色边，没有固定原轮廓域。观察支撑现在由source-raster单独拥有流畅，包括局部拒绝；其他字段的point work保留。两个新生成Stage用例要求合法源实际活动、拒绝源不恢复proxy及crown sibling保留，均通过。
- 旧两支改为局部cap场，先检查原轮廓内20%/外6%域和整水平采样sweep/alpha；拒绝格和一圈边界为零。Wide在最终场各cell四角限制Frobenius≤.45后按档位采样；`.05`现在用于cap residual，原quarter硬切谓词发生了明确相位调整。未使用dark70泛保护来冻结合法暗背景；S8规范化源曲线及其source-helper后缀保持原字节。
- C36首次编译因新uniform夹具推断为`[Any]`失败，未执行测试；只补显式`[UInt8]`，输入/断言不变。C37定向32方法/5失败/0跳过，相关31方法通过，照片仍full16个fine-core改动和preview幅度失败。
- C38四角场限制误作用于逐行量化注册相位，定向35方法/7失败/0跳过；新增两失败为既有generated完整gate及silhouette粗糙度，不修改原输入/阈值。独立数值复算证实局部削幅破坏原源相位关系，末尾global scale未触发。C39注册支单独保留原fractional≤.5、唯一强边≤1.5门，逐行统一缩幅只限制横向导数≤.45；y不变的水平inverse保持单调，不声明其全二维Frobenius≤.45。Wide的四角门保持，新增4个数值/坏输入/注册相位用例通过。
- C39 Release实际36方法/5断言失败/0跳过：3公开Engine、11流畅、15旧ObservedCheek、2 Stage、4场/注册方法均通过，共35；同图照片1方法仍5断言失败。其原尺寸direct/stage/dense/public均有16个fine-core改动；preview RMS .139574低于原.25门。生成门通过不抵销这些照片失败。
- C39单台已有iPad Pro 11-inch M4/iOS17.5、无App target的SDK hostless实际MediaPipe/XNNPACK，1方法/5失败/0跳过。direct、stage、dense与public的fine-core变化一致，smooth代理数0；full域外由C33的47降为0、core由2121降为1598，preview core/exterior均0、RMS .121208仍弱。full合法目标活动RMS .346087，但完整保护失败；重复、neutral、alpha与metadata通过。此轮只复测流畅，两层、同一台设备；不重签C33全十项或完整SDK资格。源码/测试在编译与执行期间固定，claim已释放。
- SDK-only live check及精确摘要mutation self-test通过；新增context测试只按已审核SHA使用既有CPU/Metal设置，未放宽目录/API白名单。基线2631文件复查：18个本任务允许修改文件、0缺失，其余2613保持原字节；原目录和眼鼻嘴并行内容未覆盖。`git diff --check`通过。没有提交/推送、宿主、真机或性能声明。

当前检查点仍`active`。已修复源证据颜色顺序、部分保护、映射方向和流畅域外/重复代理缺陷；上侧脸宽参考跨度、其他字段发丝保护、流畅完整保护/preview幅度和发际线正例仍未交付。后续不得通过放宽冻结保护或能力门把当前失败写成通过。

## C40 只读排查：现有材料证据的适用边界

- 复用已冻结的三控件联合source mask和C39输出作只读交集：full现有变化中，Mac518/1409、native692/3393满足该mask的正安全距离，当前Mac16/native1598个被改动的hair core均被排除。但Mac preview112个变化中仅1个满足该距离，且完整crossing-hair core仍有3个正距离像素、只是C39没有改到它们。该mask未重新取得smooth或native自身geometry资格，不能据交集签发新route；单纯复用会几乎消除preview活动。未接入生产、未运行候选、不把安全no-op当改进正例。
- H11复查复用C31记录：prototype及3个鼻桥corroboration通过，独立family46/44，sampling gap=0；合格source像素93.8%/97.0%已连通，但full/preview仍39/24列无可用峰。窗口首个失败中unsupported material占74.0%/82.4%，不能当连接噪声补洞；branchRejected=0也不能证明没有混合发丝或遮挡。
- Source seed颜色与非负公共高光分量的解释仍未取得源残差及旧负例区分证据。可参考[原始双分量反射研究](https://onlinelibrary.wiley.com/doi/10.1002/col.5080100409)理解假设，但颜色拟合不能单独证明skin身份；不能凭此放宽family、`.025`关联容差或完整列门补全H11。未宣称该模型已被本图实验否证，也未引入模型/下载或重开自动EYE/SEG。现有SourceRGB与冻结证据尚不足以给这条发际线补全签发安全资格。
- 此节只读，无新增SDK实现或测试执行；源码快照仍与C39构建/实际测试一致。后续需所有者界定轮廓材料过渡范围，或取得独立可信的边界/材料证据，才能继续对相应缺口提出合格修复。

## 2026-10-15 追加宿主滑杆范围（执行中）

所有者要求将脸型滑杆改为美图秀秀样式并支持左右连续滑动。复用宿主既有眼部参考轨道，双向项目零位居中，V脸/流畅保留单向原状至增强；填充起点随单向/双向语义变化。保持眼、鼻、嘴接线、禁用资格、撤销与唯一safeAreaInset。真实UI仅在相邻BeautyEditorApp；该目录无Git，修改前保存本次文件基线摘要。宿主仍引用原SDK，不能把宿主UI通过写成worktree算法已集成交付。待冻结源码后只跑方向/连续触摸/历史与底部布局相关检查，沿用一台已有兼容模拟器；本条尚无通过结论。

## C41 内部窄圈候选预定义（新输出前冻结）

内部候选只验证脸宽，不替换公开strict默认，不提升通用耳保护资格。源raw contour法向tube半宽固定为min(.06×detector face span,48×longEdge/1920)，先把原contour逐段裁到local y起点max(.32×chin,noseBottom+.008×span)、终点.70×chin，再以自然圆头tube定义圈（像素可越过该centreline裁剪端点）；裁入旧总几何域，永久原feature boxes仍保持。圆外所有RGBA及完整source footprint固定；衰减进入场后再做原.45/6%限制。调用方须对整个tube+texel collar与冻结source耳core做独立零交集检查，不能仅测三个arc中心；若交集非零拒绝本源候选，不改变圈定义。圈内发丝/背景例外只属已授权局部过渡，圈外发型主体保持。该scope没有耳分割证据，不得默认用于任意新输入或作为最终生产准入。V2人工mask仅独立oracle，不进入Map。

## C41/C42 窄圈候选实际结果与C43预定义

C41新增测试的processResult实参顺序错误导致编译失败，未执行所选测试；修正调用顺序后C42
实际19方法/0失败/0跳过：新圈7、原连续场4、原保护7、同源候选1。16个原图/preview双向
四档输出，整个新circle与source耳/五官oracle零重叠；输出永久耳/五官、圈外与alpha变化
均0；这不是通用耳分割或公开默认通过。所有旧strict门保持。C42固定source observer先独立
24/24已知控制通过（max .0233523source px），之后full side1双向四档方向/递增通过，但
端点9.29835/8.82844 display不足参考17.38242/18.76358的原35%幅度门。候选被拒绝交付；
原source0/full注册和preview测量资格限制仍保持。局部1:1未见旧黑楔/双边不覆盖幅度失败。

C43在新输出前固定扩展假设：circle半宽、裁剪弧、圆头、永久features和所有原阈值不变；
允许原raw polygon内部、原20%内侧域且source材料已证明connectedSkin的像素参与内肩。
该域与窄圈取union后重建唯一fixed-set距离；圈外unknown/hair/background继续fixed，
完整source footprint和最终CURRENT合成都用相同union。原strict不变，人工V2只预先检查
整个effective admitted set的永久core零交集，绝不输入Map。此条尚无C43通过声明。

## 追加宿主滑杆交付检查

宿主13脸型入口已改参考style，9signed居中、4unit从左端填充。宿主仅4生产/3tests变更，
相邻原SDK路径保持；实际只用已有iPadPro11 M4/iOS17.5。首轮8方法5通过/3UI坐标失败，
修正仅测试12pt轨道坐标、保持原值/白黑阈值后原3UI复测3/0/0，合计8个不同定向方法通过，
分属两个快照，不能写成一次8/0。已检查实际左右端点、归零、连续拖动、撤销重做、填充和
底部safe-area；设计60资源及56SDK bindings静态检查通过。宿主README/VALIDATION同步，
无真机安装、方向/字体矩阵或全App回归；UI交付不代表worktree算法已集成或十项媲美美图。

## C43 失败处置（2026-10-15）

实际21方法/16断言失败/0skip：20个生成/旧保护相关方法通过，照片一方法16输出全部
圈外body-hair失败；full双向四档53–161px、preview5–15px，耳/五官、effective域外和alpha
均0。connectedSkin的几何union不能作为完整材料证明。拒绝C43，所有16失败、原输出、
五份完整失败源码及其摘要保留在ignored证据。恢复已验证C42的全部Sources/Tests，
新circle不放大、原semantic masks/阈值不改，公开strict默认与宿主SDK路径均保持。
照片测试的source预检只覆盖耳/五官，body-hair是在输出后被独立检查拒绝；不能写成其
整个扩展域已预先通过材料证明。未对失败C43追加参考幅度或原生验收。

### C-2026-10-15-face-reference-slider-host

| Field | Value |
| --- | --- |
| Completed | 2026-10-15（仅追加宿主滑杆） |
| Status | `completed`，父计划算法仍`active` |
| Scope | 相邻BeautyEditorApp的13脸型入口采用已有美图参考横轨；9signed居中，4unit由左填充。 |
| Rationale | 补齐双向脸型控制和连续触摸，保持各字段安全cap、别名与历史。 |
| Files | 宿主BeautySlider/BeautyEditorChrome/EditorState/ToolCatalog、3定向测试及README/VALIDATION；SDK无App/UI文件。 |
| Verification | 同台iPadPro11M4/iOS17.5，首轮5hosted通过，修正测试坐标后3真实UI通过；合计8个不同定向方法，0skip。设计60资源、56bindings静态检查通过；实际截图复核。 |
| Build | 稳定宿主.build增量build-for-testing两次成功；每次源码稳定，单destination/parallelNO，claim已释放。 |
| Limits | SDK路径仍相邻原包，未集成脸型worktree算法；无真机、设备/方向/字体矩阵、全App/SDK回归或性能资格。 |

Outcome:

- 用户可点按并左右连续拖动，双向中心原状、单向左端原状；undo/redo和底边避让保持。
- 真实照片脸型参考/完整材料保护仍未交付，不能把此次UI完成扩大成父任务完成。

C43处置后全Sources/Tests快照SHA256已确认精确恢复为
41762f04bc271fb5c0c25bcf55703f275c7dc916da3c212e49b80d34d51487b3，
与实际C42/19方法0失败回执相同。未为同字节源码重复编译；稳定.build最新测试产物仍是
失败C43，下一次运行须增量重建，不能用skip-build把它当作当前二进制。最终SDK-only live
边界与diff检查通过；原基线2631文件中2613字节保持、18个明确本任务修改、0缺失，
其余新候选/测试单独保留，无提交/推送。宿主7修改源文件与最终通过的冻结摘要保持。

## 2026-10-15 所有者要求按功能核对、部分暂交付（核对记录）

所有者在实际iPad体验后提出部分功能可先交付、部分差距很大，要求先找出项目共同核对。
本轮只读审计与同图重渲，不改SDK/宿主算法或taxonomy，不在核对前将所有项一并判交付。

版本溯源：当前宿主仍引用相邻原SDK，六个脸型算法核心与初始拷贝摘要一致；原native
baseline构建日志却明确resolve了实验worktree，不能代理刚装iPad。C33/C39/C42只属各自
实验检查点，不把它们的输出、无效或幅度数字写成当前App的事实。初期CPU图片缺完整
binary/source签收链，也只作辅助。

因此本轮对当前原SDK增量构建BeautyExampleRenderer（0.20s），重新用同一授权原图的
720×960规范化输入渲染21个孤立设置（8双向的16端点、V/流畅2、双下巴2、neutral1）。
21次CLI均成功，source在渲染前后稳定；source快照
574480db67f56a1146f428196da0a26badc3d138d17e943e19be9c976cc20c86，
renderer摘要4dd9e537d694d42123e2b5e3c508f758eb5f962a8c33c4611407cdd64b657df2。
这是当前源码macOS/Vision/CPU诊断，不是iPad/MediaPipe/Metal的实际输出或21项质量测试。
私有输出/同图三列比较及摘要留在ignored任务证据。

| 分组提案 | 项目 | 当前可支持的判断 |
| --- | --- | --- |
| 观感可优先保留，等所有者核对 | 小脸、下巴长短、尖下巴、V脸、下颌角 | 形变响应可见且有相应下脸/下巴作用。仍有与美图外观差异，不据此提升通用质量/保护资格。 |
| 明确短板 | 面部流畅、发际线 | 本次同图当前Mac输出与neutral完全相同；原图具可见发际线，不能将安全no-op算效果交付。iPad表现仍由所有者核对。 |
| 重点核对 | 脸宽、太阳穴、颧骨 | 当前原SDK均实际有变化，不能套用C33严格分支的弱/no-op判断；视觉上目标轮廓/作用范围与参考仍有差距。 |
| 独立能力缺口 | 下颌线 | 宿主与下颌角共用jawSlim；不能作为已实现的独立美图下颌线功能。 |
| 此源不适合判断正例 | 去双下巴、去双下巴Pro | 同图无明显双下巴，两输出均noop；这是缺适用目标，不自动判为算法缺陷或正例通过。 |

候选“暂保留”只提出逐项核对名单，不表示所有者已选定这五项或取消圈外保护。
既有失败、预定义窄圈、五官/耳/发型主体/圈外背景要求与独立效用/保护检查保持。
本轮没有新真机测试、全SDK/App回归、源码改动、提交或推送。

## 2026-10-15 所有者确认后的实施范围（新候选前声明）

所有者明确要求两项去双下巴宿主入口置灰禁用，保留 SDK 字段、显式能力、原值与历史。
面部流畅和发际线继续修复；下颌线另建局部明暗参数，核对原参考后取消与下颌角共用
`jawSlim` 的宿主映射。脸宽、太阳穴、颧骨本轮冻结，以当前已装 App 使用的原 SDK 行为
为准；不把实验分支的三项 strict 改动或旧眼嘴快照整包替换到宿主。

流畅新候选只在完整观察支持时统一由 source fairing 所有；局部拒绝不复活旧逐行
registration。预先定义的编辑几何为 C42 原 raw contour 圆头窄圈，半宽、逐段裁弧与
三像素保守足迹边界不扩大；完整五官和保守耳附着区固定。全圈外 RGBA、圈外发型主体、
alpha 保持；圈内邻近轮廓发丝只属已授权过渡。独立照片观察仍保留旧目标区域、`.25`
RMS、max3、changed16 的活动门，不缩小分母获得通过。旧 C39 完整 hair-core 失败记录
保持，不按新圈许可反写旧资格；native 必须使用其自身 source 几何，Vision 不代理。

发际线继续要求独立源边界与皮肤佐证，保留 family/关联容差/完整列及竞争边界门；不能
凭采样成功或 RGB 近肤色绕过发丝、头发主体、耳和五官保护。下颌线候选限定沿源下颌
的皮肤带做亮度变化，默认零、无坐标采样变形；新增字段与旧 `jawSlim` 独立。几何与
皮肤证据必须在候选前固定，证据不足拒绝，保护和四档单调性独立测试；颜色模拟不
自动获得美图等价资格。具体实现先冻结源带、颜色变化上限与负例，再生成输出。

验证只覆盖两项禁用交互、上述三条直接调用路径、实际原图/预览及必要保留路径。
稳定增量缓存、单台已有兼容模拟器及原子 claim；真机继续使用既有 iPad、App ID 与数据。
未达到照片保护/活动门的候选不进入 App，完成记录分开写实现、实际通过和未交付效果。

## C46 完整源几何趋势假设（新输出前声明）

C45实际23生成方法通过；同图full/preview活动仍未过原门，永久耳五官、圈外、
发型主体和alpha保持。新假设区分RGB可见残差与fresh实测几何：完整raw侧轮廓
的低频趋势提供geometry term，只有通过既有可见边界准入的行提供RGB残差项。
完整几何不把圈内发丝声明为皮肤，只在既定窄圈许可的材料过渡中参与形变。
持续遮挡/竞争边界原负例仍须source-exact；缺失、陈旧或不可信几何不用于补全。
raw圈、feature/ear attachment、全source sweep、位移上限与.45门保持，代理不恢复，
不得降低原活动/粗糙度门或根据输出移动圈。新源资格及负例须先冻结后输出。

选定集成另基于原目录2648个非ignored文件的稳定快照，只移入本次修复；原目录不改。
脸宽、太阳穴、颧骨以原App SDK行为冻结，不把实验三字段或旧眼嘴整包替换到宿主。

## J2 下颌阴影新光照假设（输出前声明）

J1公共原图四档虽有暗化，独立许可域外54–106像素变化且preview固定活动域无响应，
已拒绝；局部目视有硬描边。新候选保留原.005…045span几何域和18%上限，以
源法向有界搜索注册宽缓的单一亮暗下降，固定皮肤/连接和完整原生footprint判据；
原18-native-luma-range仅作诊断，不能再据合法光照梯度拒绝皮肤。这是新的光照
资格假设，旧实际失败/原6方法/手工许可与活动mask及全部输出门保持。新增尺寸、
错位正例及竞争/无边界负例，先生成再原图/preview，不凭sourceQualified签发效果。

## 2026-10-15 当前已执行检查（阶段记录）

- 宿主12个直接相关hosted/UI方法一次12/0/0；单台已有iPadPro11 M4/iOS17.5，
  原子claim已释放。实际截图已核对两按钮灰色、下颌线左端零位/连续滑动及底部避让。
  57字段/cap绑定及60设计资产静态检查通过；此次不是算法或真机交付。
- selected首次SDK定向86方法/10断言失败/0skip。流畅C46两生成方法出现中央纹理
  回归和粗糙度不足；不是圈外泄漏。下颌public生成正例的闭环眉被原Adapter拒绝，
  已保留旧输入作负例并准备合法开放眉正例；3项legacy JSON需剔新增key保持原投影。
- 同source实际5照片方法/52断言失败/0skip：C46流畅两层保护/活动、Hairline V2
  source-only三槽各11平移控制、下颌direct source均通过；52失败全属下颌public。
  J1 full域外54–106px、preview活动0；永久五官/耳、发型主体、对照/alpha均0变化。
  CPU/实际Metal四档及pointwise颜色结果逐RGBA一致，不能抵销效果/范围失败。
- H12首次移植编译因test diagnostic缺少独立geometry helper失败，未执行方法。
  不整体拷贝FaceShapeWarpProvider改变三项冻结字段；只补测试诊断兼容入口。
- retained backend/runtime/shader及连续FaceMap、FaceShapeWarpProvider、Slider均与
  selected原SDK基线字节一致；SDK-only live与精确mutation self-test通过。新GPU照片
  测试仅按审核SHA调用既有backend设置，没有新GPU API或shader。

以上各回执保留各自固定源码和输入范围，未签发C47/J2/H12照片效果、完整美图外观、
全SDK/App回归或iPad实际安装资格；新候选仍待统一重建验证。

## 后续源策略与候选冻结（新照片输出前）

- C48完整源趋势与可见边界残差只合成一次，避免重复叠加。36个相关生成方法中，
  流畅和下颌公共生成正例均通过；仅下颌半尺寸竞争源的两断言失败。
- 下颌后续修复在原搜索范围内直接检查原生像素下降、恢复和再次下降，竞争边界
  在产生场之前拒绝；不调整原许可mask、活动域、强度、四档或输出保护门。
- 发际线旧人工带与保守整眉矩形有源内重叠，旧细语义保护区无重叠。
  新source-policy-v3在候选之前从许可带扣除所有完整五官和永久保护区；不改
  原mask/hash、原活动分母、三源槽、11个平移控制、.1像素容差和全部保护零变化门。
  旧严格不交叠策略及其失败保留，新策略另有保护区变化反例，不能借扣除掩盖修改。
- 当前SDK-only native候选仅编译成功，尚未执行；旧二进制不能代理后续源码。

## C48 / J3-context 当前实际结果

C48全套相关生成检查通过；原图和preview实际public照片的原活动分母/门及
完整五官、耳、发型主体、窄圈外和alpha保护通过，neutral/repeat exact。
真实照片效用尚须目视，活动门不等于美图外观或真实照片粗糙度改善资格。

J3初次source competition修复13生成方法通过，却使原图/preview因7/5条只读
foreign上下文被整条拒绝；实际3照片方法80断言失败，旧失败保留。context修复将
审核限于含原合法暗侧anchor的连续材料段，不跨foreign拼接，竞争阈值、原编辑域和
全部输出门保持。当前13生成方法及3照片方法各0失败0skip；照片覆盖流畅及下颌
CPU/实际Metal、原图/preview、四档、pointwise亮度组合，所有保护零变化，RGBA parity。

三项冻结侧脸控制的neutral和两端共7个preview输出，与原App SDK原输出逐RGBA相同。
原目录在选定快照后有独立iris/eyebrow更新；只同步其两个生产文件及对应眉测试，
不把脸型测试当成这些并行功能的新资格，也未修改原目录。

下颌单项通过之后才准备最小continuous-face组合：原图提供只读证据，对CURRENT
颜色作用，再由既有连续脸场运输。source prefix、solo阶段顺序及三个冻结控制不变；
未证明的其他几何继续拒绝。新增组合检查须比较shape-only与shape+shadow的增量，
不能把原shape已有变化算成阴影泄漏或用整图活动替代实际阴影效用。

发际线H13快照将旧材料与独立平面光照的连接图分开，候选颜色family及连续源路径
必须由同一proof证明；小步颜色过渡也检查累计源上限，避免采样变小后借桥连接
暖棕异物。旧23生成方法与新增平面光照/暖棕负例不改，先验证再读取实际候选输出。

## 原生 H13 / C48 / J3-context 与下一源假设

单台已有iPad Pro11 M4/iOS17.5的SDK-only native实际4照片方法执行1通过/3失败/0skip，
94断言失败，claim已释放。C48通过其自身MediaPipe源原图/preview活动、保护、neutral/
repeat门。H13两层双向四档均noop，独立三源边界观察与原效用门失败；完整保护仍通过。
H13原23生成及1新source-policy反例均通过，不能代理实际照片资格。Mac H13同样不合格；
source-only诊断显示family/连接拒绝导致完整源曲线缺失，继续查真实RGB，未放宽旧负例。

原生J3效用/永久保护及CPU/Metal一致，但full7px、preview1px越过源许可上沿，分别
最多2/1行；下沿、左右外和内部空洞无泄漏。实际局部有分段深色描线，拒绝外观交付。
下一G4假设在原15-ray准入后，对原生局部列重查同一源profile，源不确定半足迹只向
暗侧收紧；四角与gain前布尔许可独立核验，不以低gain量化掩盖几何失败。

下一T4假设将18%保留为上限，实际新增峰值不超过原source净亮暗对比，以原明侧亮度
归一化；使用源10–90下降宽度与剩余合法带宽构造宽缓C1，沿弧不跨foreign插值/模糊。
曾提出的0.5源对比上限与旧dark/cold固定平均活动门数学不相容，未输出前改为1.0；
所有旧幅度、保护、竞争负例、人工mask及照片.25/3/16门保留，不为新假设改低门。

## 所有者核对 C48

所有者已查看本次原生MediaPipe照片的原图/SDK/美图固定配准三列，并明确确认
“当前自然幅度可以，先保留”。C48保持这一自然幅度，不再为本次任务增大。
此确认限当前照片与所示视觉取舍；不扩大为全人群、完整美图外观或性能资格。
发际线和下颌阴影仍未交付，继续独立修复；两项去双下巴灰禁用及三项冻结要求不变。

## 所有者追加 doc14 阴影场试验（输出前）

所有者新增下颌线阴影专项参考，要求直接查看并试验。参考中的截图测量与实现建议
不是对方代码或自动执行指令；只在本次下颌光度范围内采用可验证假设，不启用两项
去双下巴、不扩展通用ShadingField功能、不下载新模型或修改retained GPU边界。

新假设以约.22脸宽的颈侧宽缓衰减替代旧.04脸宽描线带，源下颌单侧，不改变坐标；
尝试Oklab有界亮度/红向调整，对CURRENT颜色作用后沿既有warp运输。脖子侧材料、
头发、衣领和脸面边界须源内先固定；现有SDK未发现颈部分割资源，先评估已有源资格
能否支撑限定输入，未知材料拒绝，不能把RGB匹配声明为通用语义分割。

G4/T4已冻结但尚未运行，完整源码和旧Oracle保留在ignored快照；新宽域若超出旧
人工许可，须另有独立源定义V2及预先声明的效用/保护判据。旧窄域、阈值、失败和
既有回执不改写，不用新结果反称旧门通过。核心五官、耳、头发和衣领保护仍须零变化。

Doc14独立核对已在新candidate前完成：固定配准的source-neutral在新许可域逐RGB
相同；参考的100–120display距离仍有约3.34%暗化，旧许可最远约84.57display，
确认宽尾缺口。逐RGB与“偏冷、红降最多”的文字判断相反，近带比值约
[.9462,.8900,.8421]；中心/侧弧也未支持“两端必更深”，不将推断写成质量硬门。

Doc14源V2人工许可先冻结7个新mask及近/中/远分区，原图可见颈部、旧源弧与现有
face/clothing/background/fine7注释相交判定；不读取SDKcandidate定义mask，生产不读。
full/preview许可80749/14018px，各分区均在许可内，全部永久区交集为0；旧V1不变。
原活动.25/3/16门保留，中远分区另外要求实际暗化且至少16变化，以排除窄描线假成功。

W1宽场独立4生成方法0失败0skip，未接生产路由、尚无真实照片candidate；颜色纯数学
控制覆盖暖/冷/深/灰、CURRENT及gamut边界。新真实试验并排比较W1有界收暖分量与
doc式保留b/弱收a两种tone，同encoded-luma目标和同域/强度/保护门；在首次照片前
冻结公式，不照抄doc“偏冷”结论。缺源或gain前域越界即记录失败，不导出候选图。

## Doc14 首轮实际照片试验（2026-10-15）

| Field | Result |
| --- | --- |
| Scope | 宽缓单侧阴影与两种冻结tone的隔离试验；尚未接入公共生产路径。 |
| Build | 首次因生成反例夹具被推断为`[Any]`而编译失败，未执行方法；仅显式补齐`[UInt8]`类型，像素值与门槛不变。原生准备脚本另外修复mask名含数字的解析，旧失败与回执保留。 |
| Mac | release定向10方法：9通过、1实际照片方法失败、0skip，共6断言；8生成tone/宽场与1策略反例通过，不能代替照片效果。 |
| Mac source | 原图/preview均因独立注册弧段不足拒绝，分别16/11段，原18段门不变；双neck/skin源family已过，但不构成完整材料证明。 |
| Native | 单台已有iPad Pro11 M4/iOS17.5，478点MediaPipe自身源；1实际照片方法失败、0skip，4断言，claim已释放。 |
| Native source | 原图/preview许可分别32360/5338px；gain前外域4721/636px，其中hair核心201/4px，脸面/衣物及其他细核心均0。 |
| Candidate | 两平台均在着色前拒绝，无候选PNG、无着色/当前颜色实际照片通过声明，未安装iPad。 |

失败表明两组neck采样加连续RGB走廊仍不能可靠区分同色发丝；不以降低gain、改人工
oracle、删除hair核心或取消效用门解决。下一步只读导出原生源许可域定位误识别，并
另作明确标注的人工源蒙版公式示意，以区分“宽场光度有无视觉价值”与“自动材料
保护能否成立”；人工示意不参与SDK验收，不被生产读取，也不作SDK输出或交付证明。

## Doc14 密集边界收紧与公式示意

源诊断独立导出后，发现36段carrier只验证注册端点及中间profile存在，没有逐像素
验证位于密集源暗侧包络之外。v2将源许可与中心及4角的密集暗侧半平面相交，缺列
拒绝，不增加支撑、不补洞；原18段门、宽度、增益、tone及人工oracle均保持。
原8生成方法加3个独立弦跨界/完整足迹/缺列反例共11方法0失败0skip；原生同一
实际照片方法再次失败、4断言、0skip。两次源诊断重跑均沿用同一设备并释放claim。

独立源图登记确认新域严格包含于旧域，新增许可0；full/preview删3840/1053px。
实际仍有外域3832/410px，其中源弧上沿654/28、hair核心201/4、原可见neck envelope外
2977/378；各分类互斥且总数与SDK一致。未越过.25W下缘、无人工域内部空洞；中央
无许可是生产源资格缺口。hair冲突未减少，收紧几何不能代替材料识别。

另完成预览及原尺寸的人工源蒙版公式示意：固定旧源弧、新source-v2及原affine，
不读SDK候选定域、不重新配准；并排原图/W1/doc式保留b/美图。所有图显式标注
`Manual-mask formula study / NOT SDK output`，不能作为SDK安全/效用门通过。
目视宽缓阴影具有接近参考的方向，但仍有色调/边界差距；不作媲美美图声明。
原尺寸W1/doc分别15/31个颜色无正支撑，doc3391个预算受限；预览W1无颜色拒绝，
doc3拒绝/594受限。均完整报告，不能把返回原像素视为自然度成功。

### 拟议的材料验证（尚待所有者新增授权）

当前只准入固定Face Landmarker模型；纹理排除mask仅排除平滑/锐化，不提供下颌
皮肤所有权。现有MediaPipeTasksVision1.1.0二进制有ImageSegmenter接口，但没有
可直接用于颈部/头发/衣物的已准入权重；不会挪用其他眼部实验的模型授权。

具体建议为一次隔离、本地的官方SelfieMulticlass256模型验证，固定`float32/1`，
文件16371837bytes；只做HEAD元数据核对，未下载本地权重或运行推理。
[官方类别说明](https://developers.google.com/edge/mediapipe/solutions/vision/image_segmenter)
列有body-skin、face-skin、hair、clothes等六类；
[模型卡](https://storage.googleapis.com/mediapipe-assets/Model%20Card%20Multiclass%20Segmentation.pdf)
声明Apache2.0且不保证像素精确，不能把模型概率直接视为细发丝所有权证书。

若获授权，范围仅该固定模型的下载/hash固定和现有原生runtime本地静态图可行性
试验；不训练、转换、上传图片、增加其他模型、改retained GPU或自动进入生产。
先在当前冻结source-v2/fine7及独立负例验证材料边界、完整保护与中远效用，再决定
能否接入下颌光度；不预承诺单个模型足以交付。当前公共生产路径及iPad未换此候选。
