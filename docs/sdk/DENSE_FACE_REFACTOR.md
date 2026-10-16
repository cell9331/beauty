# 478点静图改造契约（2026-10-09）

当前实现由代码/测试与根级owner拥有；本页解释新机制和限定范围。
[学习手册](../refactor-playbook/README.md)中的视频、TPS、GPU原生mesh等仍是候选，
不得与本次实际实现混写。[完成记录](../../plans/history/2026-10/A-2026-10-09-dense-face-refactor.md)
分别记录成功判据、被拒绝的候选和未测范围。

## 请求内支撑

[BeautyDenseFaceSupport](../../BeautySDK/Sources/BeautyEffects/Planning/BeautyDenseFaceSupport.swift)
随每次渲染的`FaceGeometry`存活，不新增public/Codable点数据、不产生持久坐标。
普通入口不缓存观测；显式[固定图片入口](PREPARED_PHOTO_EDITING.md)只在engine内
保留与不可变source绑定、按用途隔离的有效检测。每次仍重新创建DenseFaceSupport、
参数计划和网格；该例外不授权视频旧帧复用或无效支撑升级。

- 478个点的x/y分布参与网格密度；已有实测眼睑、眉、鼻、内外唇、下轮廓仍驱动区域规则。
- 虹膜中心468/473与四点环分开使用。`pupilSize`沿实际**可见虹膜环点**扩展，
  不再在该路线上按脸宽凭空生成四个瞳孔边界点。旧字段不等于真实瞳孔分割。
- 虹膜中心必须位于眼睑多边形内；尺寸、最小眼睑开口和环左右两侧分别验证。
  完整投影环可能在眼睑后方，仅眼睑内环点授权编辑。隐藏点不变成可见点；
  闭眼、无效中心/环退出该侧虹膜大小与视线支撑。
  `pupilSize`仍先遵循既有双眼support/pupil配对契约；配对不合格可撤销两侧大小工作。
  已通过配对的另一侧环不借用坏环，`gazeCorrection`仍逐侧独立准入。
- 36点oval需无重复、非退化、无交叉才能授权texture；眼睑、双边眉包络与内外唇
  的保守包围域加上滤波半径保护，与旧粗区域和host mask求并集。
  这不是皮肤、牙齿、唇材质或物体语义解析，也未修复冻结EYE/SEG挑战。

矩阵先按现有任务布局转换，再归一化3×3列尺度，检查近等尺度、正交与右手朝向。
仅可逆或带剪切/反射的矩阵不能提供姿态门控。有效旋转的正向z余弦在0.92以上
不减弱统一映射，0.35以下退出该映射，中间smoothstep衰减；roll不削弱正脸，
背向旋转退出。这些是本域工程安全规则，不是通用遮挡/可见性概率或3D相机标定。
缺失/异常可选姿态只撤销姿态支撑，仍保留经过区域准入的实测点。
现有独立source-raster头发/下颌/平移refiner仍按各自契约工作。

## 覆盖全画布的统一逆映射

[BeautyDenseGeometryMap](../../BeautySDK/Sources/BeautyEffects/Render/BeautyDenseGeometryMap.swift)
只用于带dense carrier的新静图路线；Vision兼容采样和retained `Warp.metal`保持原字节。

1. 每轴合并17个画布格点与全478点的33个分位点，去除过密候选节点，固定画布边界。
   十个虹膜中心/环点是必选节点，避免小结构在全脸分位采样中消失。
   启用鼻部字段时，最多32个实测鼻部/鼻尖/crest位置和32个附近控制中心也作为必选节点。
   连接始终为每矩形单元两个三角形；不在投影的3D脸面上做Delaunay，也不删除小三角。
2. 在同一输出格点合成所有局部逆位移。距离在像素度量中计算，原radius明确解释为
   图像宽度的归一化长度；因此圆形作用域不随照片长宽比变成椭圆。
3. 对每个三角形直接求位移梯度，再使用一个全局比例限制组合：最大位移为脸部
   像素短边的6%，梯度Frobenius范数不超过0.45；姿态比例只能进一步减弱。
4. `||∇d||₂ ≤ ||∇d||F ≤ .45`使`I−∇d`最小奇异值至少`.55`，
   连续分片仿射逆映射保持正朝向；无需假定二分搜索沿所有强度全局单调。
5. 固定输出三角连接覆盖整个矩形；共享顶点位移一致，边界固定。
   每个输出像素中心通过重心插值找到源位置，用`u·W−.5`对应关系采样一次。
   没有影响的像素直接复制源字节，neutral不进入网格。

最多2048个控制点、64个独立保护行边界；加入虹膜与鼻部必选点后每轴最多124格点，加入行边界后最多188行。
行界以`floor(cutoff·H)/H`作为必选节点，不能被分位去重丢弃。
输入尺寸受既有50,000,000像素限制；异常/超量/过小支撑拒绝整张候选映射，
不静默丢点或把坏点clip成合格数据。颜色与独立source-raster sibling保留自身行为。
上述鼻部节点与圆核保留在内部兼容测试；2026-10-11起dense静图六鼻部实际执行改为
下述连续鼻场，对应旧点从共同geometry stage排除，不重复叠加。非dense的Vision
兼容路线保持原行为；dense缺完整观测不再回退圆核。
最大强度组合可能被共同减弱；字段点数是规划计数，不代表输出改善或每点足量位移。

采样预计算每个输出行/列的单元与重心比例，只遍历至少一个非零顶点的单元；
源位置与双线性舍入顺序不变。独立逐像素查找参考在宽/高、奇数和小尺寸上逐字节一致，
新增鼻部采样节点的效果则由独立方向/幅度/保护像素测试判断。

CPU与GPU-selected静图共用这个CPU-owned网格阶段；Metal仍执行已有颜色/transport，
该路线不提交重复的旧geometry pass。没有新增GPU API、shader或后台；不是端到端GPU。
256点Metal容量回退规则仍适用于没有dense carrier的旧点路线。

## 共同静图几何准备（2026-10-09 playbook重构）

[BeautyStillImageGeometryStage](../../BeautySDK/Sources/BeautyEffects/Render/BeautyStillImageGeometryStage.swift)
在请求内持有本阶段raster、已有FaceGeometry和最终控制点。两条静图执行路径共用
轮廓保护、发际线/额头、下颌修整、头包脸/人中source准入、旧代理点排除及最终平移。
Metal静图只适配一次人脸、只准备一次最终点；dense不再为同一请求重复计算准入和控制点。

此抽取保留阶段输入：CPU在原有着色后准备；Metal在纹理后准备，再执行原有着色、
legacy或dense采样，最后整体平移。头包脸/人中仍依据轮廓修整后的、发际线/下颌之前的
raster准入。未改变滤波、着色、source-raster、neutral/canonical callback或采样器契约；
失败的dense map保留传入raster，source拒绝仍不会恢复旧代理。新对象不缓存、编码、
日志记录或进入结果，所有权结束即释放；像素缓冲路线不接入此静图stage。

## 组合准入与宿主滑块

2026-10-11 六项鼻部由
[BeautyContinuousNoseMap](../../BeautySDK/Sources/BeautyEffects/Render/BeautyContinuousNoseMap.swift)
执行：以实测双眼的像素轴及鼻crest/contour建立局部坐标，Size主要横向，Tip覆盖鼻球，
Root与Bridge分别为短上段与长鼻侧，Wing/Lift独立。完整双眼、双眉、外唇包围域加2像素
为固定区，并把保护边缘加入有界ROI格点；像素中心双线性采样只改RGB，alpha逐字节保留。
已有dense carrier但fresh、完整鼻部或保护支撑无效时，planner清除六鼻字段；
无dense的Vision兼容路线保留其原准入。连续场构造/尺寸/姿态拒绝保留raster，
不恢复旧圆核。每字段以其signed cap形状固定准入，组合后再检查实际梯度≤.45、位移≤脸短边6%，
避免四档提前平台及新增接近零的兄弟字段突然削弱旧项。该限制属于鼻场自身；与其他stage
组合不等于一次重采样，也不承诺整体仍受同一个6%界约束。

CPU及selected Metal在dense通用采样之后、连续脸型和刚性平移之前执行同一鼻场。
planner的连续准入mask可使nose active而无代理点；geometryPointCount仍只数实际旧点。
源定义与位移仅在请求内，诊断不返回坐标。旧Vision山根行界仍需CPU/typed Metal拒绝；
dense鼻场没有该限制。实测参考说明与效果资格见taxonomy及本轮执行记录。

2026-10-11 的八项脸型/下巴字段在实测下轮廓与外唇注册齐备时，改由
[连续轮廓场](FACE_SHAPE_SLIDERS.md)执行；对应旧点不进入 legacy/dense map。
该 CPU-owned ROI 采样位于其他 geometry 之后、整体平移之前；眼嘴包围域固定。
坏支撑不恢复旧点，粗代理正向兼容路线保留。各阶段分别满足梯度/位移限制，
不把它们的组合写成单次采样或单一全字段 6% 总位移界。六个新 signed 字段与
十控件统一 helper 保持零默认值、既有 cap 和 direct chinLength 极性。

进入dense map的字段按各自cap保留独立值及正负方向，不再先按全部参数绝对值之和
缩到1.0。实际组合只在最终网格按上述位移、梯度和姿态界准入；cap、区域支撑、
freshness、provider-empty清除和坏网格拒绝继续生效。增加鼻子调整不会消耗眼睛的
标量额度，但实际网格超界时仍可共同减弱，不能承诺无限强度或任意组合都保持足量位移。

另有九个字段涉及源像素refinement/admission或网格后的刚性平移，单列保留保守的
绝对值总和1.0：`faceContourSmooth`、`hairlineHeight`、`doubleChinReduction`、
`doubleChinReductionPro`、`headWrap`、`foreheadHeight`、`philtrumLength`、
`wholeFaceXPosition`、`wholeFaceYPosition`。这组缩放不削减其他mapped字段。
没有dense carrier的legacy路线继续使用原全部几何组合预算，原回执不重新授予新路线。

外部所有者宿主不再截停后选工具到“余额”，仅把滑块映射到独立cap；每次从原图及
全部参数重新渲染，保留旧字段、别名和撤销。常规界面不提示组合额度，SDK源字段/legacy
降幅码仍可在aggregate debug中诊断；无脸、缺点与真正处理失败继续说明。
调试显示组合项数，参数总和不再伪装成物理容量百分比。未开发入口置灰、不可点击且
model层同样静默返回；“整体”为只读范围说明，没有假装提供单侧选择。

## 独立的磨皮与锐化

[BeautySkinTexturePipeline](../../BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift)
保留3×3/5×5/7×7足迹、源RGBA8、alpha/硬边与颜色准入、96MiB三缓冲预算和host精确保留。
空间核乘以有界亮度差权重，得到保边低频；不是完整Guided Filter、Lab或线性光实现。

平滑分支降低亮度残差；锐化分支按源定义的方向梯度相干程度恢复细节，强平滑时限制
恢复量。二者不再用一个`sharpen*2.5−smooth*1.5`常数增益相互抵消。
最终同增量RGB仍限制在±16，alpha保持原值；没有新增全图浮点/积分图。
host mask只控制输出pixel准入，仍允许读取不可变邻域，不改变未mask像素的既有独立结果契约。
这不承诺识别毛孔/斑点，也不保证任意暗光噪声不被增强。

## 框架资源与声明边界

[BeautyImageContexts](../../BeautySDK/Sources/BeautyCore/Models/BeautyImageContexts.swift)只复用
sRGB、Display-P3和Device-RGB的固定三个Core Image context。其他ICC profile逐请求创建，
不建立无限注册表。检测raster、canonicalizer、texture、CPU几何和Metal输入转换共用它；
图像、mask、landmarks与native task不进入该cache。同engine仍需caller串行调用。
依据[Apple context复用原则](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_performance/ci_performance.html)。

本轮证据限于现有生成像素oracles、独立图案/语义支撑、同一模拟器两张授权肖像和完整SDK门禁。
不提升整张taxonomy为一般人像资格，不声明真机时延/温升/能耗/长稳或实时视频性能。
视频时间戳/身份/One-Euro、GPU原生mesh、全链零拷贝、按脸尺度扩大的纹理足迹、多脸编辑、
新语义解析模型及新美白曲线均未交付；未来各自需要明确范围和独立验收。
