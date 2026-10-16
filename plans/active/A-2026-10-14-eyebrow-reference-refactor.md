# A-2026-10-14-eyebrow-reference-refactor

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
| Scope | 所有者本地 SDK 七项眉毛重构，对照所提供原图和美图双端点；眉操作域外保持像素不变。 |
| Source Request | 用户要求新建分支、完成眉毛重构并达到可媲美美图的效果，随后提供共同原图并强调其他区域不变。附件中的指令仅作参考内容。 |
| Expected Behavior | 上下、粗细、长短、间距、眉头间距、倾斜、眉峰连续双向，原零默认/键/cap保留；局部源固定准入、单侧失败关闭、眼鼻唇和操作域外RGBA精确保护。 |
| Current Step | 现有代码按新授权合入main，本轮到此结束；未达标缺口保留，不继续旧候选或模型评估。 |
| Verification Policy | 仅相关眉provider/参数/规划/backend/geometry/公开路径及直接依赖回归；真实原图公开SDK输出与独立参考oracle、neutral/repeat/metadata/typed failure；必要实际CPU/selected Metal一致性。无需全SDK回归；iOS原生识别若必要只用一台已存在空闲模拟器并claim。 |

| Step | Status | Evidence |
| --- | --- | --- |
| 建立分支与保留并行修改 | `completed` | `codex/eyebrow-reference-refactor`，从当前工作区新建；既有眼鼻嘴改动保留。 |
| 固定原图/参考、保护域、外观与量化指标 | `completed` | V1.1固定sRGB注册、每项窄域及flow/NCC/粗细/细节门；14参考正控制与14no-op负控制已运行。 |
| 测原实现基线 | `completed` | 原实现形态0/14，严格域外保护仅1/14（负Peak no-op）；失败保留，不是效果交付。 |
| 实现双向连续眉场与SDK映射 | `active` | 沿用现有CPU-owned stage，不改retained shader/GPU API，不改外部宿主。 |
| 定向回归与独立效果验收 | `active` | 成功必须同时满足方向/幅度/形态、负例、保护、细节；不放宽已冻结阈值。 |
| 记录实际结果和未验证范围 | `planned` | 通过才声明相应范围，完整美图目标未达则如实保留未达项。 |

Preservation and exclusions:

- 不覆盖既有眼鼻嘴源码/文档修改、冻结历史阈值与失败回执；仅增量接线共享stage。
- 不在仓库增加App/UI/lifecycle/UI automation，不自动扩大到外部宿主或真机安装。
- 不下载新模型、不训练、不上传或分发；去脂和关闭的自动EYE/SEG保持原状态。
- 素材、裁切、原始检测点和临时oracle置于`BeautySDK/.build/brow-refactor-20261014/`；持久证据仅允许聚合数据。
- 通用人群、全部姿态/遮挡、触摸/FPS/温升/耗电/长稳均须另外实际验证，不借本轮声明。

## 独立冻结与首轮失败（2026-10-14）

- `BROW-REFERENCE-20261014-V1.1`先对原图/14美图端点注册，Display P3截图转sRGB。14参考正控制适用性通过，14no-op负控制被拒绝。
- 每项操作域独立来自源眉毛、参考端点union及6截图像素窄rim；域外RGBA零变化。形态门：纹理flow RMSE≤2截图像素、median绝对误差≤1.25、最大≤4，非意图跨轴≤1.5，粗细ratio误差≤.04，逐眉模板median NCC≥.85；细节必须无鬼影/硬缝/断裂。
- 原实现720×960预览：形态0/14；域外保护1/14（唯一通过是负眉峰no-op，效果失败），其余泄漏1765–16948像素。中性、重复14/14与alpha保持通过，但不代表效果。
- 连续皮肤field首候选原尺寸1728×2304：14/14输出完全不变，保护通过、效果0/14，候选拒绝。源眉几何planning mask127、实际采样未生效；且大过渡域与新窄域硬保护不相容。
- 首轮定向SwiftPM实际执行40tests/63 assertion failures/0 skips，exit1。包括5新map用例1失败、旧public头间距15断言失败、BROW07手工非canonical支持/新准入44断言失败及连续零point度量等；保留原效果阈值，逐项区分实现缺陷和已改规划模型断言。不能算交付或全SDK通过。
- 后续假设：源固定RGB眉材料残差局部提取、原位皮肤补偿和单次原材料逆采样，可在窄域保持外部RGBA精确；提取歧义按侧退出。待实际纹理、幅度、保护、正负例及细节验收。

- C2材料候选首次编译SIMD表达式type-check超时，无测试执行；拆typed子表达式后47tests/139 assertion failures/0 skips、exit1。原图14/14 no-op，两側均在dark-band准入退出。独立源码测试诊断锁定合成弓眉连续厚度.1591L合格却被离散bin宽.171111L拒绝；改连续RGB crossing测量，.17L真实宽限和全部独立效果/保护阈值保持。C3继续验证。

- C3/C4原图仍14/14 no-op，真实效果0/14；当前固定stage诊断为两側core边界拒绝。C3定向方向单用例1/3失败；C4标量/backend/规划5用例通过，但新方向单用例仍2断言失败（厚度积分与spacing测量ROI需区分真实缺陷/测量截裁）。不以这些标量通过替代图片交付。
- 参考文件标签补正：初始baseline helper的Y/tilt是direct API符号，参考按slider符号，两者反向。保持原oracle/domain/flow及旧回执，独立仅交换文件对应后复验这4端点仍全部FAIL；此前其余10项对应正确，所以整体0/14形态结论不变。Y部分匹配触搜索边缘，仅作拒绝证据，不报告为准确真实位移。C4开始输出真正slider标签。

- C5单vertical+仍no-op（top boundary拒绝），未声称14端点通过。C6扩大只读剖面并保持强核宽/精确写入域，Mac原图单vertical+仍no-op（两侧head-body fringe boundary）；独立冻结阈值未变。继续原位纹理剖面诊断，不把planning准入计数当效果。
- 原生SDK测试自建ignored tests-only workspace引用现有BeautyCoreTests，仅排除mac CLI Process测试编译；aggregate package scheme因AppKit、首次custom scheme因Process各编译失败均保留。随后custom scheme build成功，复用已启动且无App/测试活动的PineFrame-Editor-Validation（iPhone15Pro iOS17.5，732EEC08-3851-4E3E-8441-830633BEC514），原子claim实际运行1 native photo test，真实MediaPipe478成功，但首端点no-op，1failure/0skip/exit65；claim已自动释放。未计作效果交付。临时probe和授权媒体仅ignored本地，完成后移除临时测试副本。

- C6合成源固定map5tests/0failure/0skip通过（含七项双向、mixed/exterior/alpha、跨零、侧失败与透明负例），范围仅本生成源模型。新增实际public CPU/selected Metal亮度+眉毛组合先1test/2fail（Metal无眉效果、channel误差216）；Metal采用自己color-only immutable carrier准备眉材料，保留后续原stage/geometry顺序后，复验1/0/0通过，域外相对于各backend色彩基线精确。该通过不替代原图参考指标。

- C6完整新public类实际7tests/30assertion失败/0skip，145.6s；失败包括普通decodedCI输出DeviceRGB被错误要求taggedsRGB，以及全眉范围chromatic marker积分受灰眉/棕皮插值污染。CPU/Metal实际14端点parity及保护本身无失败，但方向未通过，不算交付。仅canonical carrier承诺taggedsRGB；测试据现行输入/输出owner修正适用元数据门，并在输出前固定源marker局部cap窗口/60通道色标判别及独立±3px整数平移正控制，保留原方向阈值与首轮失败。
- 原生C6新增私有source诊断首次Data.write atomic+withoutOverwriting不兼容导致1test/1异常失败，修正单withoutOverwriting后原生1test仍首端点no-op，两側head-cap fringe拒绝；真实478、geometry与source仅ignored供原位审查，claim释放。旧Phase89/92深色大矩形眉夹具已核实冻结，未改source/阈值，不重新宣称旧gate通过；本轮临时改过该冻结test的point metric断言已原样恢复。新source-material正例必须独立版本化，不能置换旧失败。

- C6源固定局部marker校准2tests/0failure/0skip：源cap局部窗口/60通道色标阈值独立±3px整数控制通过，七项signed输出方向与保护通过；普通RGB与canonicaltaggedsRGB分别按现行owner验证，不改原方向阈值。C7原图single仍no-op（左central/righthead sourcebranch拒绝），继续按实际源诊断修正，不算参考通过。
- 新prospective头间距正例先4/16fail仅metadata，改active canonical后4/8fail仅neutral强制mask导致额外检测；源/effect/全部保护门在两轮均无失败。neutral恢复无mask等待定向复验。旧冻结positive仍不以新源结果替代。

- C8修复spacing late-target/late-source双侧原子性，保持材料算法为C7。2个新direct adversarial tests/0failure/0skip通过；同次4个source-head tests中配对效果/源信号/缺失恢复/旧block负例通过，但unilateral在相邻peer域泄漏30–37px/12328–16299RGB，4assertion失败；不是完成。该新tight-head源揭示在被拒peer仍存在源材料时，缺失peer保护须用source固定界限/有效位移准入，不能修改保护阈值。待修复。

- C8原生1photo test/1failure/0skip，首端点no-op、兩側材料拒绝，未完成14渲染；真实MediaPipe478与neutral/source identity已证实，claim自动释放。旧诊断白名单未覆盖新region回调，保留unclassified计数而不强作seed-width结论；C9临时privateprobe增加固定阶段码和真实native保护路径，仍仅ignored原位研究。
- Unilateral紧头源独立审查发现两条具体原因：source cap可读到跨中线peer材料，interior无差分白隙可被设成alpha1运输。拟修正为真实差分资格、源固定侧所有权与整体分量安全位移准入；不可改变zero peer保护阈值或逐像素裁断头形。实际phase命名还用于区分粗肤色seed宽与近donor注册后的真实.17宽，原组织宽门保持。

- C9先编译ownedSample tuple-generic表达式typecheck超时（Mac/iOS均未执行测试）；显式四个SIMD2 Bool修复后源码bab015c…，native build通过，Mac定向map7+sourceHead4实际11tests/0failure/0skip，69.39s。此前unilateral peer泄漏已归零；paired source signals631/656 changed pixels、66659/68121 RGB、Q16+145/-145，500/2000/±16及所有保护阈值保持，旧block新negative source-exact。sourceHead当前version51fe6b0…，maptestb3faabdf…；此生成源工程通过仍不代表照片匹配。

- C9原生精确诊断实际1test/1failure/0skip，首端点no-op；左registered-dark-core-boundary（central body）、右registered-skin-sampling（tail cap）拒绝。真实478及四条source protected paths已仅ignored输出供原位审查，native neutral仍同源精确。该照片失败保留；C9十一项生成/安全通过不可写为照片通过，继续按真实注册剖面与已有dense上下眉envelope检查取样。

- C9增加独立late alpha kernel回归：仅改变material union外一处双线性相邻skin alpha，pure spacing须保留整输入；正control仍两侧可见。实际1test/0failure/0skip，source snapshot bab015c…前后精确，maptests10a13f0…，与C9前11个结果分开记录。
- C10原位假设由精确native四保护路径复现和独立原图核对支持：coarse sourceLine是upper path，深核在其下；已有dense上下闭包中点可作为定位prior，不能硬clip所有真实眉毛。far tail cap已进入长鬓发，不可视作眉材料；候选限制cap source支撑后，仍须照片原细节验证无真眉尾ghost。oracle/domain/全部门保持，照片结果尚未通过。

- C9 compiled snapshot新public8tests/0failure/0skip（169.64s）包括实际selected Metal14端点、color组合、七项signed方向/域外、marker独立平移、无效输入/恢复与neutral/repeat/metadata。C10只增native闭包定位，未以此重新声称照片。
- C10 native源码72c2edf…，14实际端点及14repeat全部产生非中性输出，alpha/完整眼鼻唇sourceboxes/metadata/repeat/reset通过各自guard并写15PNG；最终执行库存断言失败（canonicalneutral两次额外detect与原预期28冲突），actual1test/1failure/0skip，104.85s。修研究probe neutral无mask而不改production；失败保留，未记为测试PASS。
- 独立adapter对15真实PNG逐SHA复制/neutral原图RGBA exact，原V1.1实际full14：numerical shape仅3/14（厚度两端、负Peak），strict domain containment0/14，overall0/14；每项域外变化712–3798px。原细节明确浅色锯齿/波浪皮肤带、source-head-hole硬缝和额发附近割裂，detail FAIL。这不是已交付，美图目标仍未达；必须修原位错误材料/补肤连续性，不能事后按oracle域clip输出或改阈值/只报部分数值通过。


## C11 原图子集与连续边界修正（2026-10-15）

- C11 source `1c95b941…` 改为source-only robust连续肤色面、真实短纤维资格及RGB合法前景；去除opaque core乘soft confidence。最小SwiftPM直接路径实际12tests/0failures/0skips（map8 + prospective sourceHead4，101.54s），未重跑完整SDK。
- 原生复用同一已存在空闲设备并原子claim，实际1test/0failures/0skips（27.18s），仅Y+与headSpacing+两个原尺寸端点及repeat；两端点可见，neutral/reset、alpha、完整native眼鼻唇sourceboxes、metadata通过，实际4次注入检测。执行库存修复为neutral无mask、显式subset计数；没有把2项写成14项。claim已释放。
- 独立V1.1子集形态0/2、strict domain0/2、overall0/2：Y+域外219px、flow RMSE1.933/max6.346、cross-axis2.066；headSpacing+域外190px、RMSE4.145/max15.059、cross-axis2.212。NCC达到门限不替代整体效果。原细节2/2失败，眉下斑块、浅色缺口和硬边仍明显。所有源、域、阈值与旧失败保持。
- C12继续在本次授权内修材料连续性/原位补偿，不先调motion。新的连续ownership必须让effective background、erasure、opacity与premult同步重建，不能机械乘残差或复制opaque core产生double brow。只有实际原图保护及原细节通过才进行full14验收。

- 同C11已编译Mac快照仅测原尺寸Y+公开CPU/Vision：单脸fresh眉支持存在、neutral/repeat/alpha/extent通过，但输出source-exact无效果；两側registered皮肤取样分别在tail-cap/tail-body退出。仅原生dense两端点产生效果，不能声称此照片Mac/Vision路径已交付。该失败与原生外观失败分别保留。

- C12 source `0be0db5c…` 改连续matte、短纤维1px closing和最近安全皮肤局部校正；同一设备原子claim actual native subset2 1test/0failures/0skips（31.82s），内部可见、repeat/neutral/reset/alpha/完整眼鼻唇/metadata门通过、claim释放。原图肉眼仍见原位条纹，独立2项验收待收；未重跑生成/Metal或声称此候选外观通过。

- C12独立2项已完成：shape/domain/overall均0/2；Y+域外295px、RMSE1.898/max6.307/median1.083、cross2.018/NCC.9573；headSpacing+域外166px、RMSE4.094/max15.031/median1.060、cross2.008/NCC.9536。原细节2/2失败，浅色条纹与锯齿仍在；两项最大flow误差仍是真实稀薄内眉头，不能删测点或只报median。
- C13 source `9fb9d1a2…` 仅将registered body weakprofile纳入连续源资格，texture不再必须逐pixel存在；同一已有设备claim actual native subset2 1test/0failures/0skips（31.77s）、内部原图guards通过/claim释放，独立验收继续；肉眼浅色轮廓仍明显，不能声明达到目标。下一步核profile边界仍有颜色差却硬截止的具体缺陷，保留历史所有失败。

- C13独立V1.1仍shape/domain/overall均0/2：Y+域外24px、RMSE7.797/max32.950/median1.243/cross31.018/NCC.9464，新增最大异常为image-left内眉头邻前发固定点8；headSpacing+域外12px、RMSE4.120/max15.011/median1.165/cross1.971/NCC.9517，最大仍image-right稀薄内眉头固定点0。原细节2/2失败，平坦棕色块/锯齿与旧位浅带仍在。未删测点、未扩域、未以更少泄漏宣称效果通过。
- C14 source `d187f7c9…` 将registered profile尾部继续至弱score1（新源材料资格调整，不是放宽冻结效果门）；原生same subset2完成，独立2项验收待收。同参数field的compact source-owned原RGB逆采样替代方案进入本授权内对照，不增加模型/GPU API或oracle裁图；其结果同样必须通过实际原图形态、细节、forelock/器官/域外保护、neutral/repeat/alpha与相关安全回归。

- C14独立2项与C13基本同值，形态/domain/detail/overall均0/2，阈值调整未解决棕色cutout/锯齿和残带；native actual1test/0failures/0skips（27.01s）仅证明内部两端点guards，不是外观通过。
- C15 source `e96c2673…` 改为immutable原图RGB逆采样，采用source continuous raw body ROI与target union、源定义窄裸肤rim，保持field/component预算，前发source-only候选p/q排除与原alpha。native same subset2 actual1/0/0（70.99s），原图天然texture明显恢复、棕块和多层大浅带消退；claim已释放。
- C15独立V1.1仍shape/domain/overall0/2：Y+域外1356px、RMSE1.860/max6.249/median1.077/cross1.769/NCC.9798；headSpacing+域外1357px、RMSE2.618/max5.008/median.964/cross2.075/NCC.9822。两最大点都是真实稀薄内眉头。两detail失败，head+前发复制/角状错接，Y旧位浅边，不能声称forelock语义保护或已达美图。
- C15 root定向12tests/1failure/0skips（map8+prospective sourceHead4，196.89s）：7map及4head实际通过；唯一失败是alpha-footprint用例找不到“灰肤紧邻hair但在material union外”的源候选，这个旧材料域premise不适合含裸肤rim的rawROI。保留源码10a13f0…与本失败；后续仅版本化寻找真实operation boundary外、实际inverse stencil内的opaque254负例，仍要求整个spacingpair保持原图精确，不删除用例或弱化保护门。
- C16计划最小raw支持域/前发与显式p同側全场准入修复。独立静态review确认C15 q/四邻域byte/alpha与pair接线，但p中线许可尚欠显式验证；Hessian source候选有限，不等同通用前发识别。sampled field的.45不能声称raw blend结果梯度界限。未重跑完整SDK或声称新照片/Metal表现通过。

- C16 source `ded6e875…` / maptests `de1fecea…` 加p全inverse-union同側准入、raw core+窄fringe支持与source前发tangent延续；native same subset2 actual1/0/0（72.19s），claim释放。新版alpha-footprint单用例actual1/0/0（2.36s）：边界外真实opaque skin变254仍取消整对spacing、参数/source/精确门保留；不能由此声称照片保护达标。
- C16独立V1.1仍shape/domain/overall0/2：Y+域外186px、RMSE2.330/max6.363/median1.115/cross5.816/NCC.9759；headSpacing+域外63px、RMSE4.187/max15.099/median1.030/cross1.982/NCC.9719。实际源细节2/2失败，收窄ROI同时漏掉真实稀薄眉头，head最大误差退回15；前发角状复制、Y旧位浅边/纹理错接仍在。未删固定测点、未把减少泄漏算整体通过。
- C15原位独立泄漏归类已证实ordinary皮肤带为主、差值max44/37，forelock错接多数在域内；C17必须分别处理真细头source归属、forelock原位/采样排除与紧凑自然边界，继续raw texture路线而不回退错误B层。相同scope内迭代，无新模型/宿主/全量回归授权。
- C17 source `948c6dd6…` 将完整细头剖面与紧凑body分离，前发外部来源判断独立于render窄域，增加有限源ridge桥接及AA窄边；未改变七项motion。原生same subset2 actual1/0/0（76.725s），内部neutral/reset/repeat/alpha/完整眼鼻唇/metadata通过，claim释放；独立V1.1与原细节尚待核验，不视为外观或严格操作域通过。
- C17独立subset2实际shape/domain均0/2：Y+域外531px、RMSE8.994/max24.454/median3.890/cross24.380；head+域外216px、RMSE4.569/max16.315/median1.887/cross2.026。1:1细节仍有前发浅黄断裂/锯齿和未完整移动的细眉头，不能交付。
- 新ignored局部原生几何CPU replay逐字编译map算法，仅替换载体类型名，实际C17 neutral及已有native两端逐RGBA零差；同原生局部记录不补造完整mesh，鼻crest路径未完整保存是明确限制，最终仍须真实native公开路径。C15快照在该工具上亦与已有native两端逐RGBA零差。工具不是新的生产检测路径。
- 重放全14和独立V1.1：C17形态0/14/域0/14，粗细倍率退至负.962/.966、正1.084/1.063；C15形态2/14（spacing+、peak−）/域0/14，粗细负.837/.830、正1.173/1.177，两端误差.041565/.041791略超.04。两候选14端点均非neutral/repeat exact/alpha exact，但不能替代实际效果通过。证据表明压缩body同时漏掉真实眉毛，应分别修源资格/ordinary skin边界与运动标定，而非继续收窄真实眉体。
- C18仅将Y/head方向改为图像纵/横轴；C19恢复C15完整source support并保留显式p/q同侧准入；C20 `00adba40…` 在该基线上标定粗细.23、外延长.055、负spacing.080/正.055、正head.085/负.095与纵向Peak。局部几何replay全14非neutral/repeat/neutral/alpha exact，独立V1.1形态9/14（粗细±、长+、spacing±、head±、peak±），域0/14（每端868–4464px域外）。Y±、长−、tilt±及所有严格保护/原细节未通过，不能声称交付；未把局部重放当真实native14或新Metal通过。

## 所有者新授权的有界模型可行性试验（2026-10-15）

现行固定SAM2.1授权属于另一项iris试验，不自动授权眉毛用途。所有者随后明确选择“允许本地分割验证”，仅批准下述可审查范围；不改SDK资源或依赖。

- 仅复用本机已有同一官方SAM2.1 Hiera Tiny代码/checkpoint及隔离CPU依赖；核原SHA `7402e0d864fa82708a20fbd15bc84245c2f26dff0eb43a4b5b93452deb34be69`。无新下载、第二模型、训练、照片上传或分发。
- 仅本任务已授权原图，两侧眉毛各最多4个事先冻结的源几何prompt配置，共最多8次CPU预测；输出只在ignored临时目录。模型mask/logit不是混合像素alpha或前景所有权证书。
- 只验证能否排除普通皮肤与长前发，同时覆盖真实细眉头；独立冻结V1.1与原细节、眉外RGBA零变化要求不变。可在ignored prototype重放全14检查，不构成SDK/App集成许可或效果通过。
- 失败保留并结束此模型候选；额外模型、prompt追试或SDK/CoreML集成另定范围。现有纯RGB候选和回归工作可继续，不以等待新授权为由误报已完成。

- 实际已完成8/8次CPU predict、4次set_image，每次单mask，无补跑/调参/下载/安装。首推理前freeze config SHA `de4673782756112d187fec4b1b6ec086220887d8023e89aa58967a0bf6c0e943`、runner SHA `765e244270980c7de1811db3b491453747a5342bc6df8c90ed6f5be7dca6a248`，checkpoint/code与原批准exact。固定384/640源crop × box/box+源暗核点各两侧；8mask与完整眼鼻唇路径交集0，但不证明语义保护。粗眉定位改善，细头和交叉额发未认证；推理预算用尽，后续仅既定mask的ignored prototype，不能追加推理或声称集成。
- C20最小直接回归实际18tests/1failure/0skips（272.457s），map8、slider3、signedPeak参数/backend/预算3通过，prospective sourceHead4中1失败：head与负wholeSpacing的Q16间距差12<原16门。新负spacing幅度与head接近，必须保留区分性门并改行为；不改冻结夹具或阈值。此结果不是全SDK通过。
- C21 `54e806f1…` 将负wholeSpacing幅度.080调为.075，原失败paired sourceHead单用例实际1/0/0（8.793s），原16门保持；原图局部重放形态仍9/14、严格域0/14。C22 `79355396…` 仅移除已被raw支持完全覆盖的旧B/unmix计算和未使用颜色buffer/sample，neutral+14端点逐RGBA与C21零差；没有借清理宣称效果改善。
- C22公开CPU/实际selected Metal类实际8tests/22assertion failures/0skips（853.800s）：缺失/恢复、typed failure、neutral/repeat/metadata、方向与marker控制通过；失败来自生成源compact exterior的4–32px泄漏（包括color组合）。CPU/Metal逐通道一致性未报失败，但不能写本类或外域保护通过；门保持，待源支持修复。
- 固定SAM mask的6方案（原4cfg+2px、四cfg源并/交集无扩张）实际84端点+84repeat，新增预测0：形态分别5/5/7/5/5/3，严格域0/0/0/0/0/8，总合格0/0/0/0/0/3，所有方案整体FAIL。交集保域改善伴随粗细近neutral；1:1仍有弱毛残影、皮肤硬缝及前发copy，未获得集成资格。
- 独立源边界对照仅ignored：closed-form matting两固定阈值均shape9/14/domain0，原位ghost/前发copy未消；C13资格作raw coverage为shape7/domain2；harmonic背景additive hair residual为shape6/domain0；固定模型core沿source纹理geodesic生长为shape7/domain0。均新增SAM预测0、neutral/alpha/repeat通过；这些工程或数值局部通过不能替代细节与严格保护，失败全保留，不集成模型。
- 后续同源有限对照：自写RGB-GMM+Dinic固定5轮（3小图穷举控制、整套独立重复、code复核）仍shape3/domain0；外部长发曲线两候选shape8/6、domain0，出现保留原眉窄带而未修主前发；global half+1 body上限shape8/domain0，仍裁掉弱眉。均无新模型推理或资源，未集成。不能从这些失败宣称“自动分割不可能”，只限定本次实际假设。

## C23 cap真实细头修复（2026-10-15）

- 私有源诊断确认right固定细头在head cap范围、rawBand法向范围和source侧/opaque内，非organ或前发排除；二次背景外推反而比原RGB暗12.42级，原3/1颜色门拒绝真实细毛。V1.1固定点/门没有改变。
- C23 source `0a7147b2…` 仅将cap资格的背景改为邻近rawBand外法向2–8px、距离优先的安全上下bare patch；原3/1/.96资格、cap范围和field保持。14端点局部几何重放shape10/domain0；Y±最大误差1.840/2.672、tilt±最大1.981/1.825。剩余Y跨轴、length−最大和tilt−median仍失败，严格域每端/整体均未通过。
- 新独立合成亮肤weak-head回归保留原8map用例和阈值：C22 RED actual1test/6failures/0skips（7.451s），C23 GREEN actual1/0/0（7.800s）；双向真实marker移动和alpha所有权被捕捉。新数组精确比较改为Bool断言以免失败打印像素，精确要求不变。
- 同一已有空闲设备原子claim，C23原生公开CPU same subset2 actual1/0/0（144.315s），fresh478、两端非neutral/repeat、neutral/reset、alpha/完整眼鼻唇/metadata通过，claim释放。独立同V1.1 shape1/2、domain0/2：Y+RMSE.991/max2.672/cross2.277、域外1595px；head+RMSE1.269/max2.535/cross.594、域外1107px。机械内部PASS不是严格保护或外观PASS；未声明新native14/Metal photo或Mac/Vision照片通过。
- C23复用已确认源码的现有green构建，`--skip-build`定向5项map安全+4项sourceHead实际9tests/3assertion failures/0skips（57.300s）。sourceHead四项、weak cap、单侧和late source/footprint通过；target-alpha用例有3断言失败，包含应发生的sampling拒绝/pair取消及独立head结果精确比较。保持原用例和门，正在核实新局部cap donor对源边界的影响；不能声称安全回归已通过。实际native两端1:1审查仍见polygon边/前发copy，细节2/2失败。

## C24 分类取样缺证与独立修复（2026-10-15）

- 生成源固定失败点诊断表明：目标alpha254改变cap donor/texture资格，右侧visible材料新增1px，源所有权预算随之缩小位移，使原透明洞退出实际union。不是原洞已安全通过；不能用动态换测试点掩盖。潜在支持足迹两个误接线及修正版本均保留失败，未集成。
- C24 source `08a931c3…` 为实际分类color/skinPatch四邻取样、texture/Hessian整数读取记录alpha缺证；不读取nonopaque RGB，不以换donor继续获得安全准入。field逐侧拒绝并触发spacing pair回退，独立head按侧重验；没有扩大写域或改变不透明输入公式/预算。ignored固定点11断言通过，opaque独立head和组合与C23逐RGBA零差。
- 实际SwiftPM定向map全9项及sourceHead4项：**13 tests / 0 failures / 0 skips，360.997s**。原target-alpha、late source/target/四邻透明footprint、弱头和所有原门保持。不是公开CPU/Metal完整类通过，也不是照片保护或外观通过。
- source-only长前发global读保护唯一原型all14：shape10/domain0，415px源tube全部RGBA精确（其中162px在旧材料ROI外），但旧baseline已有12端点全tube精确，实际改善很小；1:1平行条纹、静止原眉窄带/硬边仍在，不集成该私有mask或宣称前发修好。
- 冻结raw source支持经radius3 closing作harmonic背景，随后同一additive residual全14：背景边界受头发污染，1:1仍有明显色块；shape/domain/细节均未整体合格。模型调用新增0，保留失败，不集成。
