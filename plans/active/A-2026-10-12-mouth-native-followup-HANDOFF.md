# 嘴部优化验收与收尾记录

| Field | Value |
| --- | --- |
| Updated | 2026-10-14，Asia/Shanghai |
| Status | `completed`，限定F−/image-X改善及响应验收；完整参考未满足，设备目录清理未确认，分别保留债务 |
| Scope | 负向收薄、嘴巴左右移动与滑杆响应；保持口腔及鼻眼保护，尽量接近美图 |
| Current Step | 本轮限定验收、预览及App打开已完成，同一计划已移至history/2026-10；无自动续作。保留参考及设备媒体限制、并行改动，不提交/推送 |
| Production | 当前74e27忠实集成与publictest463已完成限定验收；原dbbe5d、原4f503失败及所有拒绝候选只读保留；并行改动保留、不提交/推送 |

本文件保留原接续路径。现行状态以表格及下方“最终iPhone验收”为准；后面的交接停点保留各自日期，不作为当前未完成项。完整失败与冻结准则见[同计划记录](../history/2026-10/A-2026-10-12-mouth-native-followup.md)，入口见[PLANS](../../PLANS.md)。


## 2026-10-14 最终iPhone验收

所有者明确换到iPhone13Pro/iPhone14,2/A15、iOS26.4.2(23E261)，沿用已有
profile与主AppID，保留数据。实际combined增量签名build0/37.882s；同手机
shadow1/0/0、10PNG/16X/F2后，新fresh6-first原7/7及1:1细节通过。
首次final基础设施启动取消0原方法/0PNG，失败保留；有界复用同签名产物接续
实际原五项5/0/0、36PNG、14完整RGBA身份。summary3e3b503c、inventory22ae9bdf。
两张neutral实际RGB/type2，其余34 RGBA/type6，仅元数据role检查校正；source
完整RGBA/alpha不变，没有重渲或改变数值门。

同手机8控制先冻结（baseline0c3f6215），独立正式review92fbded9/provenancedf213d52
验收F−/X改善及双图原生1:1细节。A F辅助改善.8576/.8020px、主78/75→77/74；
B63/59→63/58不恶化；X原7/7，A三窗40.1951/40.2189/40.2375px。
M/F完整口腔场/像素与物理鼻眼RGBA保持，physical-field只诊断，B负F.1030690346px；
X另有physical-field零，口腔随整嘴移动。F四档验收来自实际SDK31原生成夹具。

参考仍未满足：X低于45.6–68.4，F主差21/23px、辅助差21.8412/23.6440px。
MOUTH-REF-01保留；不自动开启后续研究，不声明全尺寸导出、手机GPU、完整SDK/App、
UI/FPS、性能/温升/耗电/长稳或一般美图等价。两张display-only预览已通过既有
ImageIO helper发布为mouth-ref-007/008，媒体库存check通过；旧图未覆盖。

## 历史接续信息

以下保留当时状态及失败含义，执行顺序已由上方实际结果结清；不据旧待办重启任务。

## 授权、共享工作及暂停位置

用户已明确授权本轮算法/滑杆优化、算法/原生/像素代理分工、使用现有 iPad，以及沿用现有 App ID 更新安装并保留数据。2026-10-13 用户说“已解锁”，之后多次要求继续；换线程交接后，用户明确要求从R11接续、沿用已有授权与验收标准、保留并行改动且不提交/推送。R11已实测完成。解锁是当时事实，下次仍核查当前状态；不重复询问已有范围授权。

- SDK：`/Users/yakangwang/codes/beauty`；授权宿主：`/Users/yakangwang/codes/BeautyEditorApp`。
- 不调整 UI 布局，不提交/推送/创建 worktree，不启动范围外任务、全量回归或新设备/runtime。
- 工作树存在大量眼部、鼻部、backend、文档并行改动；当前 mouth map/test 本身为 untracked，不能用 git restore/clean 覆盖或删除。
- 本次沿用算法/原生/像素分工：原生完成R11，像素独立6/7拒绝；算法转单一新源证明，root及独立代理审查后才决定是否产生候选。不把代理汇报作为新的外部消息授权。
- root 负责嘴部生产源/计划/SDK及研究编译；原生代理负责外部宿主与其稳定构建缓存；像素代理只读固定 oracle 和独立像素复核。共享缓存不得同时写。
- 保持 SDK-only、自用许可、固定模型及 retained Metal/GPU 边界；不重启 closed EYE/SEG 或 suspended 去脂。
- raw pixels、masks、landmarks、私有夹具路径及 child transcripts 不写持久记录。授权媒体仅在本地 ignored/临时区，持久证据仅允许匿名聚合。

## 当前结果：不能把 Mac 通过当作生产或真机通过

1. F−候选已有 Mac/早期原生改善证据，但最终同 iPad 的 F−像素改善尚未验收。
2. d96 的实际 iPad R10 工程检查通过 **1/0/0**，独立效果仅 **6/7**，已拒绝。
3. 新 d2 候选通过独立静态审查、实际 **17影子测试/0失败/0跳过，4.893s**、新 Mac4 工程保护及独立 **7/7**。
4. **d2 的四张新 Mac 输出与 d96 的四张 Mac 输出全RGBA一致**。这是实际新渲染的结果；未证明新的 Mac 像素修复，也不能推导真机场无变化或真机必定通过。
5. R11已实际签名构建与执行 **1/0/0，4.792s，10PNG/16四档/F2内存身份**；独立fresh6-first **6/7 FAIL**。d2/忠实转换ed2均拒绝。
6. radial750经证明/静态、实际原17/Mac7后，R12同iPad实际 **1/0/0，5.497s，10PNG/16四档/F2内存身份**。独立fresh6-first正式 **6/7 FAIL**：B19负端span **.7544% > .75%**，原尺寸细节及身份通过，750/忠实bdd不选用。
7. R13 f160复用产物工程1/0/0及独立原7/细节PASS。忠实74e仅集成mouth map后，实际SDK31为31执行/30方法通过/1方法失败/4断言失败/0skip，公开水平标记跨度122.4053 vs124±.45、Y−.35893 vs0±.3（双向）。原17和实际Metal32用例通过不能覆盖该失败。public14、最终5原生/36PNG/14身份未执行；尚未交付本轮算法。

## 冻结源及关键证据

研究根目录 `BeautySDK/.build/mouth-native-followup-20261012/`，下文研究路径相对此目录。它包含仍需使用的源码、构建与冻结证据，禁止整树删除。

| 对象 | SHA256 |
| --- | --- |
| 当前实验生产 `BeautySDK/Sources/BeautyEffects/Render/BeautyContinuousMouthMap.swift` | `74e27bbb521a80238025dbcbde3cb6ec550b878e00668be676ff402c2339cdab` |
| 精确保留的此前生产 `candidate/production-preparation/production-before-dbbe.swift`（terminal-jet目录） | `dbbe5d135ec95edc4d416633985432fa762badacb2ac02773bd47622ee1022f7` |
| 原17测试 `BeautySDK/Tests/BeautyEffectsTests/MouthContinuousMapTests.swift` | `c32c9cb64d9cf6bcf93c461b067401aaf45a7ebf864b5d48c63496a2f4046f59` |
| F− `fullness/MouthFullnessRecoveredCandidateMap.swift` | `dd9b822d9006de29f12cc5714a318b0a3fcc8ccea9846145c1ea4f6f9f98919b` |
| F helper `fullness/BeautyMouthScalarMinorant.swift` | `5bf1a2549710b936a9cec587805b410571d55343ee241dca32035b38775952aa` |
| dbbe控制 `mac-shadow/MouthFrozenDbbeControlMap.swift` | `3770a13eb3b25f4c1bb2184379bfe53746cdb4c9e84c20c4ee3de7ff340c90e0` |
| 固定 matcher `pixel-review/fixed_oracles.py` | `f663d92fdb3afa3d9d7e8853774d673ac07dee0a512c7c977be194b5a7ed486a` |

换线程前的交接实际再次核对生产源、原测试、d2候选、证明、静态审查、17测试回执、Mac7/7、matcher 和 final adapter 摘要一致；该次交接未重跑SDK或图片测试。本次接续的R11执行与失败另见下文。

## 已拒绝候选 d2：有限 source-basis 边界结点耦合

候选目录 `analytic-distance-representation/corner-basis-knot-coupling/`。

| 文件 | SHA256 |
| --- | --- |
| `PROOF.md` | `f433e0a365ae81900754924579326554c2d64cfdc2297f5b2e045a70bd6e8842` |
| `candidate/MouthCornerKnotCandidateMap.swift` | `d2ce7fa7d3421f03ea7147374e3bb8f8d2d77b63bd88c07578677d04616ead85` |
| `candidate/STATIC_REVIEW_ALGORITHM.md` | `cf75a9565dc683cc7a42e64ceaacbcf866942426b76f82cfbaa7963eb30dbbd7` |
| `candidate/test-result.json` | `33e4b4f4b4fc70c18a9ad08e48ab86c917d3c12f9546ee0e24621669498f35ee` |
| `candidate/mac-runner/source-identity.json` | `8cee94bab5bfa2e1c69684e1ac44e8ebb129c4ec9867ead3ec3b97170742ccdc` |
| `candidate/mac-runner/run-receipt.json` | `8d175bdefcfed37cbbc0c039b1f4641c167b72658046e4e64bec7942b87762f8` |
| `pixel-review/corner-basis-knot-mac-review/aggregate.json` | `0677bee0f56ce47236d7b954a75d06a783e772b75b39fc3ce8c71436f539b0c4` |

先有证明及原断言，再实现和出图；六项授权增量逆变换可恢复整份 d96，F/O、原 H/T、零集合及实际断言不变。证明/源码为公式细节 owner，下面只作接续提示：

- 保留 d96 严格非零双线性系数中心的 H、嘴角扫掠集合 S、原64次向内准入、全域上限 T、原 local L/physical P/halo 零集合。
- 从两个 `B_i=S_i+[-1,1]^2` 的8个外顶点取有限边界条件，不扩大 rigid/admission H，不声称整个 B 都受等应变约束。
- 原 `b=.45*(1−1e−10)`、`k=.02`；`lambda=b*dist(S,Z)`、`W=.45px`、`Gamma=W*(1−b)`，均从源/已有准则导出，无调参。
- `m_j=h_T(max(0,lambda−b*r_j))`，`Q_j=m_j+h_Gamma(T−m_j)`，`phi(z)=z²/(z+k*T)`；最终 `min(g0, Q_j+phi(b*distance(y,v_j)))`。
- 证明平台恒T、原零集合、全局 b-Lipschitz、最大T、pose/fraction一次；有限差分分支切换仍需实际原门禁。局部结点条件不等于 RGB 纹理保证。
- 未实现/未选择 continuous full-belt infimum；不把它当已验证方案，不扫域、系数或窗口。

Mac 实际新4图：工程保护通过，old46 PNG 与26非本轮端点身份保持；physical field/RGBA、local、halo、exterior、alpha为零变化，材料宽度/Y漂移0，有限采样梯度最大 `.449999999957`。
独立7/7：A RGB15/19/23增益 `3.9244/3.9812/4.0173px`，最大span `.3987%`、error增加 `.0591pp`；B19/23增益 `5.7157/5.7118px`、最大span `.0095%`，误差改善；无搜索边界，原尺寸未见新的口缝/夹点/唇波/鼻底台阶。另列Mac参考G54通过，不能外推原生。

## 已拒绝 X 版本与 R10 最近失败

完整失败留在当前计划及原回执。不要重跑失败版本、复用其生产草稿或把单个窗口替代全部窗口。

| 候选 | 拒绝原因 |
| --- | --- |
| 59f14 格网 physical enclosure / R5 | A19/23不足+2，B幅度/纹理失败 |
| a2ef 解析 enclosing / R6 | 原生幅度/宽度/误差未全部通过 |
| d5f 原 anchor frames / R7 | B负端span `.9011/.8723%`、error增加 `.2658/.2729pp` |
| 156 完整 tent-support domain / R8 | span/error通过，A19/23仅 `.967/.946px`，B幅度变差 |
| 105 解除全域幅度抑制 | Mac span约 `1.5–2.18%`、error `1.1–1.8pp`，未上iPad |
| d96 coefficient-center H / R10 | 仅B19负端绝对span `.7692% > .75%`，6/7；703生产草稿一并拒绝 |
| d2 finite basis-knots / R11 | 仅B19负端绝对span `.7690% > .75%`，6/7；忠实ed2生产草稿与其public14准备不准入 |
| radial750 full radial profile / R12 | 正式6/7 FAIL，B19负端绝对span `.7544% > .75%`；原尺寸细节通过，忠实bdd草稿及public14准备不准入 |

R10 真机同平台 fresh6 baseline先冻结：A RGB pair `36.3500/37.3789/37.3957`；B `39.5027/40.5814/40.6557`。
候选A增益 `3.9330/2.9181/2.9189px` 均通过；B19/23幅度和error也通过，但 B23 `.7472%` 不能代替 B19失败。原尺寸细节未见新问题不能覆盖硬门失败。另列参考 G40/RGB约40.3仍未达45.6。

- 宿主 R10恢复后 summary：`.verification/mouth-ipad-coefficient-cell-r10-restored-20261013-summary.json`，SHA `31a8925450a060be98d525a205b959ee85e46faeef31a8398569bbf81c67136c`。
- 独立 `pixel-review/ipad-corner-cell-r10-restored-20261013-baseline-validation.json`，SHA `e94a924b44657039e2733d4f3271127483d858301925834220eaa6805cf5dc6d`。
- 独立 `pixel-review/ipad-corner-cell-r10-restored-20261013-review.json`，SHA `7d7bd8d0a253a3a0f8a0c675b33e40a8d6e21ee1446631cfb37899159b064cb0`。
- 实际R10 **1/0/0，4.902s，10PNG，16四档，F2内存身份**；这不是最终5原生。
- 16次CPU调用 construction median2.7582/p959.18046ms，sampling median5.40469/p9512.40079ms；不是FPS、完整渲染或拖动性能。

旧R10曾因锁屏取消，actual methods0/PNG0，而xcresult有环境伪测试1failed1；保留这次失败，不算算法失败或测试通过。并行眼部构建曾由Xcode清掉旧Release App，后来按冻结配置重建；xctestrun/profile相同但App/test二进制不同。恢复回执及入口在宿主 `.verification/mouth-native-harness/device-preparation-ipad-20261012/R10-ARTIFACT-RESTORATION-20261013.md`。恢复后运行已完成，不要再次等待或重跑旧R10。

## R11：已完成的冻结入口与回执

本节保留R11复现与身份入口。该轮已执行并因原硬门失败拒绝，不再重跑或使用其草稿集成；下列准备和GO条件记录的是当时的执行流程。

宿主准备根目录 `.verification/mouth-native-harness/device-preparation-ipad-20261012/`。

- 目录 `mouth-ipad-basis-knot-r11/`，包含 `MouthNativeIPadXOnlyTests.swift`、精确d2/F/helper、`frozen-config.json`、`prepared-receipt.json`。
- harness SHA `9317a847131e2e1f643c0ff6518ba9f78c6e3c868bacb203e1219c17edc5798f`。
- config SHA `266d2bc7a0fa222066e1afa38b924dee79e1d6df18368c7df160d8132682fe65`。
- 驱动 `r11-ipad-build.py`（已记录前缀544f81abe045）、`r11-ipad-execute.py`（前缀f3e358e82afd）。接续先读入口和真实参数，别猜命令或跳过gate。
- 原R10方法/断言逆归一化完全相同；仅源/type/元数据改变，明确有限8结点边界，不声称whole B。静态Python解析通过，尚未实际构建。
- root 可根据已冻结 static cf75、17回执33e4、Mac review0677和精确source d2/config266，给原生代理 R11签名构建/执行GO。已有用户范围授权足够；无须为“进入下一步”再询问。
- 仍执行原 **1测试/10PNG/16X四档/F2内存身份**，所有physical field0、RGBA、宽度、Y和梯度旧断言保留。
- 像素代理必须先读并冻结该次**新同设备6张baseline**，之后才读4张候选，再做原7项硬门及原尺寸检查。不能用R10或Mac baseline代替。

## R11实际结果与下一项证明

R11新签名构建exit0、47.07s；同iPad的实际工程检查 **1/0/0，4.792s，10PNG、16X四档、F2内存身份**。原physical field/RGBA、local、halo/exterior、alpha/repeat、material width/Y及cap门通过。工程配置/临时源码精确恢复，保存的眼部App不变，设备claim在输出取回后finally释放。实际transport为localNetwork；未删除应用或数据。

- 宿主 `.verification/mouth-ipad-basis-knot-r11-summary.json` SHA `428fb88be5e73b19e57ddaf96dbae19d094f8292c6aa3915147c65f19cf526cb`。
- 独立目录 `pixel-review/ipad-basis-knot-r11-20261013/`；fresh6-first `baseline-validation.json` SHA `9a85eb3ee3f598daa7a837fb5d2d43f2535005f301cd5af21d28f80141268ab8`，冻结时candidate_pixels_read=false。
- 正式 `review.json` SHA `67d0f4b95fafb5168388dfe3ee51dfc21551fc6cb3135f5974e75c3b9d353bee`，**6/7 FAIL**。A RGB15/19/23增益 `3.9154/2.8989/2.9010px`、span/error通过；B19/23增益/error通过，但B19负端span `.7690% > .75%`。B23 `.7467%`不能替代。原尺寸四端点无清晰新增口缝/夹点/唇波/鼻底台阶；NCC/搜索边界及库存/源码身份通过。另列美图目标仍未达。
- `r10-r11-RGBA-diagnostic.json` SHA `87fd5ef7ca4f06a54c315d3495563546a75c063b701f4534f84414136d786b98`：同input/device/OS及6controls全RGBA exact；候选A−/A+/B−/B+各仅6/5/6/6像素变化，最大通道差5/6/2/4，alpha exact。实际有微小输出变化，不能宣称纹理修复或整场相同。

忠实ed2草稿 SHA `ed2effdbe7347bfe1241f83252ceac833079770b07a544e02c200eb35de39239` 与public14静态准备保留在d2 `candidate/production-preparation/`，均不选用、未编译/出图/绑定。最终31/public14/native5仍为0。

径向证明目录 `analytic-distance-representation/corner-basis-radial-profile/`，`PROOF.md` SHA `eadf447ce2b0ace94316114d6f18a74856a7647061c7bdbd261f214b13c468fc`、独立审查 `08a659d155a90f7ea16e655d4aa15c230e71e33756ce97287284d3ec962a6536`均由root完整读取冻结后生成唯一750源码。它用原tensor support的 `sqrt(2)` 距离层级约束替代有限结点，原H/S/T、Gamma/b/k、零集/cap/pose均保持；径向carrier含部分square B外点，是过渡约束而非扩大刚性/准入域。实际原17/0/0、Mac7/7和R12工程通过，未通过R12像素准入，不能重用草稿集成。

R12工程summary SHA `c3000d3dd20132c6c604781151206c6243854ea356d92f1cb93730f606217ea3`，inventory `06922bc3dcf137c82bf8b1052d3db7e9531acf44151c1c4e455ad169d4316b63`。独立目录 `pixel-review/ipad-radial-profile-r12-20261013/`，fresh6-first baseline SHA `b77fe71cc274988021972d232ca68cc49f66573400ba58eaddc41a2610313efe`先于candidate4读取。numeric SHA `3d4f6d2ba8d59e5bc99f04e60b4f7cb73c8fd190309d06fababaf80d311d5d93`：A三档增益3.8852/2.8723/2.8729px、span/error通过；B19/23幅度/error通过，但B19.7544%超过.75%，B23.7343%不能替代。正式review SHA `f76e8c2fb9138348cb879737f1ff96a5e3592bddc0174e8d5a842315aa33f153`，6/7 FAIL；原尺寸细节通过、NCC A.9953/B.9916、boundary0。R11→R12固定窗聚合诊断SHA `acb52f19721b2d86cd15211b39ebab14d8fa528b1aeb5db5cc0a7dd3405cfb0a`：同设备/input/OS及6controls exact，B19仅改善.0146pp仍超.0044pp，不宣称private geometry相同或因果修复。

下一单一proof位于 `analytic-distance-representation/corner-basis-terminal-jet/PROOF.md`，SHA `d7faf2957d6ebc7a50db46e292ade35cf767dd331916b30a9fd9be48d5fe98a3`。root已读完整推导及独立review SHA `1903044845ff128e654b417c2f3b5a404790a29a72441e3570b2ceb8e8d9d50e`，rootgate `23818ea3297d883edda89995e5355f0715d00a89ef8def54d6d410d4f79ec61f`已冻结，仅GO单一source/原17/Mac准备。它保留原R/phi/q_R与m lower corridor，用 `max(m,min(g750,q_R+phi(b*abs(r-R))))`重建原R边界内侧；r>=R逐点同750，H/S平台T由maxfloor保持，零集合及全局b-Lipschitz不变。仅V径向R连接C1，不称最终场全C1或RGB修复；原17实际finite-difference门仍必要。旧54 Mac精确保护manifest SHA `d955588c2ac0792bc8f7a1e880f4632159aaf3a13f261bd286bf662e858604e5`已先冻结。唯一sourcef160 SHA `f160d9e68167cbe6a769b4322de4da5dcf81cfd4a81e6a039f68a29ef0b33937`及身份7117已冻结；source独立review `ea819825593e3dfdb0cfa249103a4819bec8ecd7eb2ca8f57b3937413d03a874`和wrapper review036f由root完整读取。实际原17/0/0、4.452s回执 `6a71732e4ed3475cdb73d0d828eaa7c6e9fa307db5da8b37985f01e1bc54846d`；新Mac4 exit0、old54 exact，run `4eb27ad6f77c010d7731607eb0b51f086fec3b5eb8520128a35ab82ed42c8ff0`/aggregate `4b71f1ac86b0a8bb518d574ca9967391830e37ce60de0a7b653a873d5199150c`，独立7/detail待完成。R13静态harness93ea/config4adc/prepared4dbf及全R12逆身份已备，root-release-gate尚无；无native执行或生产选择。

最终build/execute拒绝集合已最小加入750及bdd；回执SHA `7967975cc69f75bf4e4f9e78b6da565eb22c820319056989cab7916642f0f03b`，各17项静态membership控制通过，不执行final。当前driver SHA分别 `79af11f422842d4f0b99677f0fa25c5e05e8cd91138b74937cace6c4a0cdeec3`、`472c2d853e4c7367dcb87c889f4e9ad4abee669cab8ba72b1aff9522ccc9c473`，R11/R12冻结driver/config及unbound final template/adapter/保存eyeApp保持。

## R13历史前检停点：签名产物保持，已于10月14日接续

Mac原7/细节review SHA `a94c50e61997196435642213472f8e9a175bcb72a95616818defdb3f5edf0348`已由root读取准入；native rootgate SHA `dabe43dcfff11292a3da327fb8f76eb01b4b30f8bf57f9314d7df37555be08ed`。
R13 Release build实际exit0，build receipt SHA `b56459f7fc01ce74eada69dbce0e8039104fd5d21ec0235d5d1936f91eded186`，project/source/scheme恢复、saved eyeApp exact。
首次execute只到fresh lock preflight：passcodeRequired=true，未install/stage/XCTest；0方法/0PNG，xcresult、run-receipt、media/input包均不存在，claim finally释放。保留旧runlog SHA `25be985603bd343794162430dbab6b37966081efc47caacac118a2817fe5c126`和匿名locked receipt SHA `6e1c71d2570042da562e5cc9dd2de89beade93c17416fcaa0317c81e148ccdf6`，不能算算法失败或通过。该当时停点已收到10/14用户解锁回复，实际接续见下节。

root已读完整/逆身份验证恢复脚本：`/private/tmp/beauty-mouth-r13-execute-resume1.py` SHA `dcdb451602a69d8d31e3e5a7cf66195feec6242f5d43a087c1032b155c91a3ad`，仅LOG/tmp details/lock namespace变化；`/private/tmp/beauty-mouth-r13-summarize-resume1.py` SHA `b1160c3f27198aec5cee48c2639ee2cdbcdecabc12e0bb19e5dd2d24e3c0eed4`，仅LOG变化，整源逆回原入口。解锁后依次执行两脚本，无额外参数；execute会fresh claim/lock/artifact recheck，成功后summarize取actual1/10/16/F2头部/身份，之后像素代理fresh6-first审查。不要再次执行旧LOG入口或覆盖失败记录，不因时间经过当作解锁/批准；不默认重建。

新条件生产草稿74e27 SHA `74e27bbb521a80238025dbcbde3cb6ec550b878e00668be676ff402c2339cdab`，root已完整读两diff/review；public14 `candidate/production-preparation/mac-final/` prepared identityc3c55已读完整main/link差异及gate/run。全部native/SDK31/integration/final仍为空；未选择或改生产。

## 2026-10-14 R13现行实际状态

用户明确已解锁亮屏并复用产物；四个原签名artifact及source/test/config/driver精确核对，无重建。resume1 fresh lock为false，但发现系统更新18.7.10(22H374)，旧18.7.9 assert在install/stage/test前停止，actual0methods/0PNG；历史匿名OS-preflight receipt SHA `a6c1c7c6d805f9b4c287fd5df6ac16e499176eec94a38a2235f8aff5fea03428`保留，不算算法失败。

root及native独立审查resume2 metadata-only环境适配，execute SHA `58943b758bb9ef410989c893b4cdb4119bd19ef08e33ca11228e011945da6803`，summary SHA `8344c461d556910850f3ffeb8552af1b19b5ec82a4c5a544ac961995dd8c0650`；全逆身份保持原实际方法/断言/math，frozen driver/config/build不改，严格匹配当前OS18.7.10/build22H374。

实际resume2已exit0：**1/0/0，5.207s，10PNG、16X四档、F2内存身份**，同iPad/wired/Release。summary SHA `05079816209233b1d17c0fbd97ebacb6a018705de7bf9a61f64fda73965581c1`，inventory `7b24ac467d807787410b9b35ad8e6a39eb7021a9ec0396745d4be999698f568b`；source/artifact/project/eyeApp exact、claim已释放。本次仅shadow工程，不是final5或新F像素验收。

独立fresh6-first baseline SHA `b8897772f5da11fb741c03cfa3ee1860b2e1c292d655d170cc10882ca5fe5e7b`先冻结，candidate_pixels_read=false。随后正式review SHA `70003664f5763ee007a055c86ccfa805c9b5b169d0c9837ee51b95ac38433b52`确认原7/原尺寸细节PASS：A三窗口增益3.8451/2.8400/2.8418px；B19/23负端span .7385/.7211%，原.75%门保持。美图45.6..68.4独立目标仍未达，F2只有身份范围。

Root完整读review及忠实转换两diff，集成唯一74e嘴部源；回执SHA `2a1431328f41488003a39e1c386be68974e39da4b130c42fde9f5a746dc84602`。随后实际三类SDK31退出1，31方法中30通过，1方法4断言失败，0skip。失败为原公开路径`testPositionsMoveWholeMouthWithoutStretchingAtFourSignedSteps`水平可见标记宽度及正交Y；原17、三滑杆和实际Metal32方法均通过。失败回执SHA `370793eb368b49c242ddb98199cb77d605289f8ea901dd815417488dd5c1fb9b`，完整log及before位于terminal-jet `candidate/production-preparation/final31-preparation/`。

接续源码/数学及公开调用链只读诊断；未改原测试、fixture、匹配器或门限。public14/finalnative5尚未执行，不用影子照片PASS覆盖公开标记FAIL。当前74e仅供诊断，原dbbe精确保留；保留全部并行改动，不提交/推送。

## 设备、缓存和并行眼部任务

iPad7,11/A10，10/14实际iOS18.7.10(22H374)，此前18.7.9记录保留；UDID `f4ef3f178ce25d79e7f963ff6fe0261b127f4865`；CoreDevice ID `99F26BB9-15A1-5B8E-AEF9-534E3A265827`。
既有 Team `UHKD6CZHH3`、App ID `com.yakang.wanneng1`、既有profile覆盖设备至2026-10-18。复用现有身份/应用/数据，不新建资源。

真机占用采用 `/private/tmp/codex-ios-device-claims/<UDID>.json` 与 `.json.lock`、flock/owner/token，finally释放。不存在claim文件不代表已拥有。上次R10已释放，本次交接没占用；下次重新检查其他任务当前占用，不能抢占、删除他人claim或杀他人进程。

外部宿主 `.build` 为稳定缓存，不同时编译。并行眼部当前入口为 `plans/history/2026-10/A-2026-10-13-eye-physical-delivery.md`，其保存的 `.verification/eye-physical-delivery/BeautyEditor.app` 不得覆盖。当前物理安装版本可能被其他任务更新，不能仅凭历史记录推定。当前root权限为danger-full-access、approval never，按现有授权直接执行必要宿主写入/构建，不传sandbox_permissions；子代理旧权限不能写宿主时仅准备临时脚本，由root审查后执行。不改变全局开发者账号。

## 新候选通过同iPad准入后的依赖顺序

1. **先准入**：d2/R11已失败，不能选用。新候选须先经证明、原17及新Mac/独立门，再在同iPad独立原7/7与细节全部通过，才选择。失败则保留回执、拒绝候选/草稿；提出单一有源码/数学依据的新假设，先证明再输出，不调门限或扫描参数。
2. **忠实转换**：算法代理可为新候选条件准备生产草稿/public14，root读完整diff与逆转换身份。删除研究import/type/diagnostic等必须证明所有live算术不变。d96/703及d2/ed2均已拒绝，不可拿来集成；现有d2 public14只作未执行准备证据。
3. **最小生产集成**：仅授权mouth map及必要private F helper，保留并行eye/nose/backend。同步所改行为owner，不新增public API/backend。
4. **最终SDK实际31/0/0**：下方三个类17+11+3，含所选路径actual Metal32；skip不算通过。复用缓存，不跑全SDK/App。

```sh
swift test --package-path BeautySDK --filter 'MouthContinuousMapTests|BeautyEngineMouthReferenceTests|BeautyMouthSliderTests'
```

5. **public14**：为实际所选新候选绑定 `mac-final/`准备脚本，实际生产14输出与所选X/Fdd/未变冻结控制全RGBA一致。旧d96或d2 public14准备均不可当新候选通过。
6. **最终iPad5**：原3滑杆契约+2肖像，fresh selected production签名构建；36PNG为原34+2 fresh dbbe F−控制；14个neutral/M±/F±/X±实际渲染与同次standalone参照全RGBA一致。
7. **最终独立F/X**：同平台新F−改善和X各窗口、原尺寸、完整保护全部实际测量，再记录最终结果与限制。

最终宿主准备名仍为 `mouth-ipad-final-selected-r7/`，是未绑定的通用模板，不能按名字推定选择R7。入口 `final-ipad-build.py` / `final-ipad-execute.py` 有失败源denylist（包含d96/703），要求 native效果PASS、最终SDK31实际Metal32、public14以及忠实转换证据后才能绑定。
最终schema2还用4个内存fresh dbbe X± RGBA摘要与已准入shadow controls核对，不另加4PNG。

最终有两条真实检测路径：helper以 `.geometry` 观测获得standalone/control参照；实际PhotoRenderer走自身cached prepare。诚实报告两条，不伪称单次检测，也不持久化几何。
F/M要求完整原oral field/RGBA0、local field/RGBA0、physical RGBA0；X还要求physical field0。F/M的physical field只作原诊断，不能混淆或静默增加/撤销门限。

最终像素适配器 `pixel-review/review_final_native.py` SHA `965ad3eadac14705c639c2a54be0206c51db0f66906465a7bbf831e26064e435`，直接调用冻结matcher/原native数学；8个metadata控制自测通过，但未读最终像素。先冻结8 controls（final neutral2+fresh Fdbbe2+admitted shadow Xdbbe4），核验5/36/14、同设备OS/input、selected X与freshcontrol身份后才验F与X。不能用原一测试review_native替代final5范围。

## 原准则：继续时不可放宽

- F/M完整原口腔带不动；X整嘴移动，口腔随之移动，不能要求或宣称X oral-zero。
- 原P为image-axis AABB四边2px，鼻底额外 `max(3px,.03*mouthspan)`，中心`x+.5/y+.5`；原L/halo/exterior/alpha/neutral/key/default/cap保留。
- 梯度≤.45、位移≤`min(.20*mouthspan,.06*face shortside)`、pose一次、signed-half source-fixed预算；材料嘴角宽度误差≤.45 native/source px。
- 20°生成输入Y漂移≤.3px；near-neutral组合跳变<.01px；实际有限差分epsilon .001、原容差 .450001不变。
- F−：A固定aux1.65/1.75各改善≥.2px，主阈值不增厚，B不恶化；生成四档误差≤.045、端点>1px。F−采用source-fixed local edge/Dijkstra minorant与`f/(1+.45*(1-f))`，pose一次、端点/neutral不变，F+不变。
- 早期F证据：Mac A72/69→71/68，aux改善1.0875/1.0477；早期原生A78/75→77/74、aux .8576/.802，B63/59→63/58。只保留其旧范围；R10/R11的F2只证明内存身份，不等于新iPad效果验收。
- X：A RGB15/19/23各pair增益≥2canonical px；B19/23幅度不恶化，B15旧歧义仍诊断。
- 绝对纹理span≤.75%，同窗口绝对误差恶化≤.25pp；NCC/无搜索边界/1:1口缝、夹点、唇波、鼻底台阶均要检查。
- 美图区间45.6..68.4独立记录；未完整追平就保留差距，不拿局部增益声称完全一致，也不把旧模型必要界写成普遍不可能。

## 收尾、文档及精确清理

全部最终验收后同步 DESIGN、RELIABILITY、MOUTH_SLIDERS、QUALITY及匹配taxonomy/技术债MOUTH-REF-01、计划/PLANS。旧29 SDK/5原生及本次候选17/R10一测试都保留原日期与范围。更新RELIABILITY的旧pure-X lattice描述为实际解析证书/有限差分范围；当前owner正文替换过期说法，不覆盖历史回执。

随后按 example-images/README 管理规则发布新压缩预览，核查现有库存避免与眼部并行预览冲突，不覆盖旧图，不假定007/008仍空闲。当前Mac固定旧54 PNG（含750成功重放4，不含空失败目录），宿主R11/R12各已新增10；其他轮次以实际精确清单为准。
只有全部最后使用者确认结束后，按owned精确清单清理派生媒体；保留失败聚合/源码/logs/receipts/xcresult、稳定cache、冻结夹具及授权master输入，绝不整树清理 `.build`。

最终沿用现有ID更新并打开已验证App，数据保留；不宣称未测的UI/FPS、温升/耗电/长稳、一般外观或全量回归。任务完成记录按 plans/TEMPLATES，当前未满足时不标completed。

## 新线程启动检查

1. 读AGENTS、PLANS、本交接与当前计划最新段；查看git状态，保留其他线程所有改动。
2. 按Serena指南确认beauty长期服务并initial一次，不切共享实例；读取适用spike-findings-beauty、build/storage和真机/signing指南。原线程已读不等于新线程工具已初始化。
3. 核对关键源码/回执及当前设备/缓存占用；不要从旧`.planning/` next-step另开任务。
4. **R11/d2/ed2与R12/750/bdd均已因原硬门拒绝，不重跑或选用**。R12正式6/7及细节回执已完成，terminalf160已完成证明/静态/实际原17与Mac7/detail；R13已在10/14同iPad当前18.7.10复用签名产物实际1/0/0，fresh6-first原7/detail已通过；忠实74e实际SDK31失败，接续公开标记机制诊断，public14/final5暂停；不要重跑已完成R13或旧resume入口；完整证明与独立审查先于新源码、原17、新Mac/原7/细节及同iPadfresh6-first。本交接不授权跳过门禁，也没有给最终生产通过资格。

## 2026-10-14 最新接续补充

见现行计划“public marker ownership correction”段：真实corner weight1596/foreign61精确重组旧失败；纯fixture blue身份修正不改标准，root接受回执7e2556ff及独立实际V4 f006c33。currentpublictest463（原4f503源码只读保留），原17c32/matcherf663/production74e不变。实际SDK31 receipt66312466与public14 e5882f49分别通过。旧31 failure370793、两次finalcompileexit65及恢复回执保留，不伪造最终5通过。当前新namespace为`mouth-ipad-final-terminal-jet-r13-static1`；pure sample helper静态化的整源逆身份审查与root增量签名build已完成，见下节。原final模板与actor0/actor1失败只读。不重跑R13已通过影子或扩展矩阵、不扫算法参数/门限、不提交/推送。

## 2026-10-14 最终签名产物与 USB 接续

static1只将无状态sample声明改为`private nonisolated static func`并将7个调用改为`Self.sample`，函数body/math/assertions不变，逆转换精确恢复actor0源码。实际Release build exit0、226.981117s，回执SHA `b950ef39ad3c380b065bb9dfe44127fcf736a786d02e3775bf8979b0be361195`，存于宿主`.verification/mouth-native-harness/device-state/mouth-ipad-final-terminal-jet-r13-static1-build/build-receipt.json`。现有四个签名artifact、project/source/scheme与保存eyeApp均精确核对；不再重建。

首次final前检发现实际通道localNetwork而非wired，在install前停止。随后如实记录localNetwork的两个安装尝试均因IXRemote/XPC“Connection interrupted”失败，实际0stage/0方法/0PNG，失败log与各run-receipt保留，匿名聚合`install-network-failures-20261014.json` SHA `0116b2004a10ebaa34c07cb4799ff69ab125672ac8ff858b13d0d520212f3f5e`。已创建的匿名输入包保持精确SHA供复用，不覆盖失败入口或原driver。

用户回复“iPad已经链接好了，手机没有链接”。只继续原UDID iPad，无需手机；IORegistry物理USB serial与原UDID精确匹配，xcdevice同UDID为usb/available，但CoreDevice目前仍报告localNetwork。USB2严格wired入口尚未执行，不能伪称已切为wired；当前核实工具通道或以新USB存在证据作一次有界接续。如仍安装失败，保留产物与失败，停止重复相同条件安装。全部claim已释放，最终5/36/14与独立F/X尚未发生。

## 2026-10-14 现行设备改为 iPhone13Pro

用户随后明确“更换到iPhone13pro了”。iPad USB3入口在物理USB前检停止，exit1但0install/0stage/0方法/0PNG，无run-receipt，claim finally释放；不是第三次安装失败。手机新前检回执`candidate/production-preparation/phone-migration-preflight-20261014.json` SHA `b5696d6a61cc34d182a6051054374b5cd8c7148f6b193979952d13906d3c2eeb`。

现在仅用 iPhone13Pro/iPhone14,2，UDID `00008110-0001453E21B9801E`，CoreDevice `9BA53BC6-570F-57A4-AC25-44FF09B700E2`，iOS26.4.2(23E261)，实际wired/DDIavailable。已有Team/profile覆盖手机，App family1/2、arm64/min17兼容；同主AppID更新手机且保留数据关系已明确告知。旧iPad资格只证明iPad，不能直接用于phone准入。

旧R13 shadow App/test共享路径已被static1产物替换，不能复用其旧四件套回执。准备一次HOST稳定`.build`的增量联合编译，临时8源去重；编译shadow1与原final5六方法不代表实际通过。实际执行仍顺序独立shadow1/10/16/F2→same-phone fresh6-first原7/细节→final5/36/14→8controls-first原F/X，每步独立回执。生产已74e，故新shadow基线由冻结377dbbe同freshgeometry/source直接合成；新增actual74e renderer与selectedf160四端点全RGBA硬身份，元数据明确基线不是当前actualrenderer。原mask/阈值/matcher/math保持，v3草稿SHA `d5bdc590abcd9daca5ec8f39cb7c20e7e5f3dc11da6408948c875049391bbd1e`已由root读完整diff，尚未部署/构建。手机原五用例和效果尚未通过；不提交/推送。

### 手机实际构建与影子工程检查已完成

Root已整读并部署8源/config7a7/build629/compile-only gate0988；实际增量Release build exit0、37.882s，receipt SHA `a5e1002a111b8df0d529ed4e7dc1444d09bf2428fbf430cca16e32964ba73801`，project/source/scheme恢复exact，savedeyeApp不变。compiled6但actual0，该receipt不能当测试通过。原iPad claimhelper硬编码UDID在静态审查被发现，未执行；新`/private/tmp/beauty-mouth-iphone13pro-physical-device-run-v1.py` SHA `c6b62119cfd30917bb129c2ac4f6a41f92e43d6c1f3e75ae3cba2b9e627654cd`仅UID/purpose两literal，完整共享flock/owner/token/heartbeat/finally保持。新shadow launcherv2 `bc7a5a21`已实际用该helper。

实际phone install/stage/shadow/retrieve exit0，**1/0/0、5.216s、10PNG、16X四档、F2内存身份**；summary SHA `93cdf1dbf15c9554a288ccde5ae054005ac865a71c8ef5eab108dbcee4196f87`，inventory `7a76e5660547fb3d3fdeeb7cc64bba153218fb7825e1110617cf7505a384a35a`，位于宿主`.verification/mouth-iphone13pro-terminal-jet-r13-shadow-*.json`。current74e/f160/frozen377字段与四个当前actual→selectedRGBA0硬身份通过，八源与四产物exact，claim finally释放。

Phone metadata-only独立adapter新版本`review_native_phone_v1.py` SHA420c270、`review_final_native_phone_v1.py` ca8549，位于`pixel-review/iphone13pro-terminal-f160-20261014/`；root已完整读diff/逆身份，原bcb/965/math/matcher不变，不能改原文件。Fresh6-first已冻结`shadow-baseline-validation.json` SHA `3115017e0abfb5d480aed0bdfe0367e9fde8d4351cc33ad47b231586646a2acf`，cand=false且root已准入，正在读candidate4做原7/1:1正式review，输出应为`review.json`。最终条件gate/driver模板仅预备，flagsFalse/GATE_SHA=None，实际final5/36/14未发生；后续版本注意把旧预备的`baseline-validation.json`改为此手机实际`shadow-baseline-validation.json`文件名，保留冻结文件不改名/复制、不伪造PASS。

## 最终收尾状态

当前iPhone App已成功foreground launch，PID44189。两个display-only JPEG预览
007/008保留；本机162项精确副本/441152876bytes清理后无listed残留，30保护身份
exact，包括原始素材、14冻结Mac输入/golden、oracles、源/测试、4签名artifact和保存眼App。
未删除整个.build、日志/JSON/xcresult或未知早期媒体。

手机第一次exact shadow空目录copy退出1；随后精确文件服务列表，包括所有者解锁后，
仍返回CoreDevice.ActionError3。未执行final目录copy，不声明设备目录被清空或现存
数量；旧iPad断连，本次未新核/清理。相关失败和scope留MOUTH-DEVICE-MEDIA-01。
同一计划已按模板归档；本文件原路径保留作完成记录入口，不据历史“下一步”继续研究。
