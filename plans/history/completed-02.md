# Completed records 02

### C-2026-09-23-v1-22-root-repair-and-sdk-closeout

- Status: completed（2026-09-23）；7/7 阶段、33/33 计划、11/11 当前需求。FACE-01 按已批准范围延期到 FUTURE-04。
- 根因修复：内侧鼻背 source 定位、root/bridge 像素行保护、默认 Vision named-sRGB CGImage 与原 ROI 检测入口一致；保留 source/ROI/阈值和公开字段。文档已移除错误的外基底边界认证和人工确认前置要求。
- 真实验收：65/65 输出两次一致，七个有效方向与一项明确延期；山根固定31对、五组区间 [260, 373] Q16，目标 10774 像素/RGB217300，outside 与 bridge/tip/background/watermark 全部0。
- 同身份门禁：安全1/0/0、兼容4/0/0；archive-first、SDK-only 和完整 SwiftPM 937/0/0，全部8项 opt-in 各一次。首次因 Metal 专项旧计数34停止，修正为实际35后重新执行最终完整门禁；未改效果门槛。
- 独立实现/安全审核与不同作者的目标审核通过；`finalize` 和 `verify-complete` 已验证有效 [95-COMPLETE.json](../../.planning/phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json)。规范身份 `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`。
- 默认 CPU 支持修复后的 observed root；显式 Metal 对不能表示的新保护边界 typed invalidInput 并可恢复。62字段、5预设、75 renderer cases及后端选择策略保留，不宣称该新效果CPU/GPU等价。
- 完成范围为所有者本地 SDK 验证；无需用户标注或真机操作。归档和历史失败记录保留，不涉及设备表现或外部分发结论。
- 当前入口：[v1.22完成记录](../../.planning/V1.22-CURRENT.md)。行政同步后再次 verify-complete；后续规范代码/契约变更须对应重新验证。

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

- 用户要求先核对文档，暂停新算法/原图试验；[审核报告](../../.planning/V1.22-DOCUMENT-AUDIT.md)确认6项文档/执行对齐问题。
- 收回“跨行模型是下一必做路线”的表述：它仅为未验证候选；固定16行权重也非产品硬要求。
- 当前真正缺口是宽度语义与完整测量接入。v3行数/实现名单写死、producer仍v2，必须在选定方法后一起版本化；不靠重复现有诊断推进。
- 当前已完成18包runtime/12生成检查/两次source诊断/929全量回归，后文安装失败等均是历史记录。
- 本轮只审核及修正行政说明；未改代码、冻结测量规范或验收阈值，不新增通过信用。

#### 审核后最小设计（2026-09-22）

- 已完成[最小测量修订设计](../../.planning/V1.22-MEASUREMENT-DESIGN.md)：明确宽度变化的量、原阈值/比较、可复用组件假设和六环节同步接入。
- 新确认：除v3准入外，correlated-change聚合函数也写死12..16行；水平RGB对应不能无条件覆盖所有sibling。后继不能仅改文档/报告版本号。
- 当前尚无证据选定合格的自然图像宽度标记，因此没有开始跨行模型或新原图试跑。下一问题限于该语义依据，不是补下载、覆盖计数或全量测试。
- 设计没有授予注册/效果通过；代码和历史凭证保持不变。本轮仅做设计及文档一致性验证。

#### 当前执行状态（2026-09-22）

- Status: active；95-03人像准入blocked，95-04工具准备可继续；里程碑未完成。
- 唯一当前执行细则：[v1.22当前口径](../../.planning/V1.22-CURRENT.md)。
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
