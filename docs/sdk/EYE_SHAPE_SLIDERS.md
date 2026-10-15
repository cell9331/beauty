# 眼部几何与滑杆契约

首次接线范围是所有者提供的 11 组眼部端点参考；2026-10-12进一步优化前五项
大小、上下、眼高、长度与眼距；随后另选五项下至、眼尾上扬、倾斜、内眼角、
外眼角优化。首次接线未优化去脂、祛红血丝、提肌、眼神矫正与对称。
2026-10-14新授权仅优化有参考的眼瞳大小 `pupilSize`；提肌、眼神矫正、对称、
祛红血丝四宿主入口置灰禁用。SDK的15个眼部字段、API、cap及默认值保留；
宿主置灰不降低SDK资格或移除显式调用，去脂仍为 `suspended`。

## 参数与宿主

`BeautyEyeShapeSlider` 是无 UI 状态的 owner-local helper。`applying(position:to:)`
接收 0...1 位置，0.5 为零；`position(in:)` 支持选中工具、撤销和恢复参数时反读。
越界位置夹紧到端点，非有限位置回中点；只修改选中字段，保留其他规范化参数。
既有 Codable key、零默认值和绝对 cap 保持。下面十一字段均支持 signed 请求，
新增负向是否执行仍取决于该次输入支撑。

| 滑杆 case / 名称 | 字段 | 绝对 cap | 向右的效果 |
| --- | --- | --- | --- |
| `eyeSize` / 大小 | `eyeSize` | .45 | 整体眼部放大 |
| `verticalPosition` / 上下 | `eyeYPosition` | .25 | 沿归一化图片竖轴向下 |
| `height` / 眼高 | `eyeHeight` | .35 | 纵向张开 |
| `length` / 长度 | `eyeLength` | .35 | 横向拉长 |
| `spacing` / 眼距 | `eyeDistance` | .30 | 沿归一化图片横轴分开 |
| `irisSize` / 眼瞳大小 | `pupilSize` | .25 | 可见虹膜增大 |
| `lowerEyelid` / 眼睑下至 | `lowerEyelidDrop` | .30 | 外半下睑下移 |
| `outerTail` / 眼尾上扬 | `eyeTailLift` | .30 | 外眼角上扬 |
| `tilt` / 倾斜 | `eyeTilt` | .25 | 外角下、内角上 |
| `innerCorner` / 内眼角 | `innerCornerOpen` | .25 | 内角朝鼻侧扩展 |
| `outerCorner` / 外眼角 | `outerCornerOpen` | .25 | 外角向外扩展 |

`tilt` helper 反转 direct `eyeTilt` 的符号：新实测眼路线 direct 正值使两侧外眼角
上扬。它与参考的右向倾斜相反，不能和“眼尾上扬”共用同一滑杆极性。
原粗支撑路线保持原正向输出，不能借它声明新增负向效果。

外部 `BeautyEditorApp` 补齐大小、上下、长度、眼距、眼瞳大小入口；保留旧工具 ID，
将原 `eye.eyelidSize` 标为“眼高”并继续接 `eyeHeight`，新虹膜工具单独接
`pupilSize`。全部几何滑杆使用上述 helper 和中点零标。两批共十项宿主滑杆采用参考的
黑底、白圆、中心圆点和从零位延伸的有效段，点按与连续拖动共享几何；尺寸和
交互记录由外部宿主 README/VALIDATION 拥有。布局和应用状态仍属于宿主。
本次眼瞳大小沿用同一双向参考轨道，11个不同参考滑杆可选。上述四个禁用入口
保持可见，其交互不得改变选择、参数或历史；既有参数和历史不因置灰被清零。

## 连续眼部形变

`BeautyContinuousEyeMap` 在两种静图 backend 共用的 CPU-owned stage 中执行。
实测眼睑与内外眦建立像素度量的局部正交轴；眼眶区域内的协调变换加平滑外围衰减，
取代少数控制点相互拉扯。眼高、眼长、下至及眼角使用不同的独立形变分量。
在有效可见虹膜环上，局部睑/角调整减弱虹膜区形变；大小、位移、倾斜使全眼协调移动。

前五项的缩放围绕实测眼孔上下界的中点，眼高在内外角附近衰减，避免把眼角一并
上下拉动。上下与眼距使用图片坐标的共同方向，避免两眼相反的眼角倾斜造成额外
外展。共同距离包络在眼区内保留平台，再向外围和固定保护区过渡；间距场在源固定
中线处归零，避免左右反向场重叠。鼻/root/tip分别保护，另保留眉间带和双眼内角
间中央桥区的保守保护；这些区域仍是几何约束，不是鼻或眉的精确语义分割。

共享阶段还从不可变请求栅格检查可见暗色眼缘，用于前五项的位置尺度和大小/长度
共同的横向轴心。
三个最宽扫描行须在RGB三通道上同时低于邻近肤色，左右边缘各自一致；可见跨度
最多为实测跨度1.18倍，轴心偏移最多为实测跨度12%。透明、单通道标记、越界、
过小或歧义暗边保留原几何，不产生新支撑或替代失效 detector。该检查不识别组织、
眼妆或遮挡语义，不新增模型；只保留请求内的尺度/轴心，像素和扫描结果不进入诊断。

下至沿图片竖轴调整外半下睑，与整体眼高分开。源观测轮廓的上睑包络提供距离
净空；上睑、中央纹理、内半侧及外角外围分别归零，取最小距离形成连续过渡，
平台末端使用一阶连续收尾。中央虹膜保护使用实测中心/半径下的保守圆形距离，
保留中央下方纹理，避免扩大横向保护而冻结外半下睑。没有有效虹膜环时不推断半径。
下至与外眼角的局部RGB注册，从所有采样行中选择左右边缘一致的最宽三行；
三行不要求相邻，不一致的更宽行不否决该组合。不透明、RGB对比、双边一致性及
可见跨度至少为几何跨度80%、轴心偏移最多22%的原限制保留；前五项仍使用
默认三个最宽行与98%/12%的严格准入。下至的上睑零位边界、中央形变区和外角
零位边界共用这个局部框架，外眼角平台也使用同一可见外缘。有效dense虹膜中心的
不透明三通道对比只用于选择上睑采样邻域；失败保留较宽保护，不重新定位瞳孔。
横向注册及核心对比同时通过时，中央平区按源眼孔轴心与实测虹膜中心的水平偏移
分配，最多占注册宽度6.5%，至少保留2像素邻域；缺少可信证据时使用保守宽度。
这些检查不增加支撑、语义分类或持久像素。眼尾使用外侧垂直场，倾斜使用全眼
协调旋转且保留相反极性；内外角使用各自横向距离场，避免通过整体眼长伪造局部效果。

网格节点来自不可变 source 和固定保护框，强度不移动核位置或采样节点。
连续眼形stage在连续脸型后执行；独立dense眼瞳remap在共享sourceRGBA进入geometry前执行，
其他鼻、嘴及最终整体平移仍各有自己的stage，
不能把整个组合说成单次采样或共用一个总位移界。实测眼路线的对应旧点被抑制；
新场拒绝时不恢复粗代理。未实测的旧粗支撑只保留兼容路径。

有效眼孔须有限、非退化、无自交且有合理眼角跨度和睁眼开口。无效侧退出；
间距要求双侧都有效、左右顺序正确且内角有正间隙；反置或重叠配对关闭间距，
保留独立眼项。虹膜双向调整要求 dense carrier 中有效的可见环和瞳孔支撑。
稀疏实测眼中，眼孔内且距边至少一像素的有效瞳孔中心允许有界正向兼容放大，
使用眼孔尺度和平滑边缘，眼孔外保持输入；它没有实测虹膜半径，负向退出。
无有效 dense 环时不借稀疏兼容补齐；完全未实测的旧粗眼路线仍保留旧正向输出。
虹膜分量始终在眼孔外逐像素排除，混合参数或强度过零不取消这个保护；
虹膜单独调整时眼孔之外保持输入，避免网格插值跨越眼睑。

### 独立 iris remap

当前SDK rendering source保持C61的独立 `BeautyIrisScaleRemap` 与explicit CPU
original-first preview。C74实际原图/新预览各1/0/0，四份冻结numeric/fixed26点
partial-arc/声明保护/alpha/neutral/repeat协议required均TRUE，完整artifact/source/
runtime/result binding gate通过。资格仅属当前单张已编辑肖像与这些门。
独立细节复核仍见缩小端细灰下缘rim，右侧更明显；较深donor试验变差已拒绝，未改
生产源或冻结oracle。C74旧十项照片及宿主UI6实际共7/0/0，21张canonical PNG及
完整RGBA与C40/C53一致。现有iPad已同ID保留数据更新，原图实际Metal/独立CPU
exact parity及原图网格CPU预览各1/0/0，四份冻结图片协议通过。iPad面板两次各
0/1/0，均在初始前台scene数为0时停止；第二次先明确foreground launch并退出0，
仍未进入布局断言。未获得当前iPad布局或触摸资格。
C58旧预览右负/正中心漂移2.417508945/2.952131420超界和C57拒绝仍是原版本失败；
C57的direct22/public1及原生numeric/声明保护通过不取消其失败，也不复用为当前结果。
额外sparse1/0/0仍是独立兼容范围，不代表dense新机制。C56的direct21/public1及原生原图/
预览工程通过。两眼两分辨率的numeric、声明保护及所有RMS/max谓词通过，但固定
26点的右侧三项center drift仍失败，候选拒绝、新版未交付或安装。C55的SDK20/public1及原生原图/预览
工程通过，两眼两分辨率的冻结numeric与保护谓词全部通过，但26个固定observed点
的右侧三项partial-shape仍失败，候选拒绝、新版未交付或安装。
C54的SDK/public已通过，
原图/预览两眼正负四档方向、单调性与声明的保护谓词通过，但右侧partial-arc及
部分幅度/光度仍不合格，新版未交付或安装。
共享静图stage先完成既有源栅格refiner，再在geometry前对该stage的不可变RGBA
作局部径向重映射；CPU与Metal executor共用这个CPU remap，随后其他geometry
搬运处理后的虹膜。dense `pupilSize`从EyeMap和旧点的strengths中移除，准入失败
不恢复旧代理；保留的C40 EyeMap不再拥有生产dense眼瞳。零值、稀疏兼容及其余
十项仍沿用原路线，retained shader/GPU API保持。

水平环点对和有效dense语义中心先提供观测圆model。C47加入的source-only注册
在原始固定owner内，从两侧多条射线的合法RGB三通道对比取得多个observed边缘点，
分开训练与held-out支撑，作有界center/radius圆拟合；owner不随拟合或强度移动，
中心、半径、支撑分布及held-out残差均须满足界限。弱或歧义支撑保留原model，
不夹取或猜测替代半径，不用四点一般椭圆；fallback不能算已修复圆度或取消照片失败。

signed强度与既有pose衰减决定scale。C55在注册后的源圆边界按5°取72个方向，
各方向四tap须通过bounds及strength-independent注册owner的最小窗口、8%眼角、
feature和开口SDF>1；f为72方向完整四tap几何所有权比例，不读RGBA，也不判断
opacity或blink。使用
完整owned方向数>24时沿用C55的 `gain=clamp(2f,.9,1)`；C56的离散class≤24
使用 `gain=max(.85,.88-.72*(1/3-f))`。scale仍为
`s=1/(1-.21*normalized*densePose*gain)`；最弱支撑最多衰减15%，f≥.5仍为gain1。
分支存在离散跃迁，限静图，不承诺时间连续性。这些常数是观察旧候选与输入支撑后
的开发预算选择，非blind holdout标定。这个source observer不是语义mask或
隐藏组织恢复，也不授权原采样门拒绝的材料。正向仍受最近眼角空间上限约束，
无放大空间不改成缩小。除下述已认证glint材质例外，核心逆半径为 `g(r)=r/s`；外白色保护带
以三次Hermite接回窗口外恒等，内斜率为 `1/s`、外斜率为1，均C1。解析检查该段
一阶径向导数（二次多项式）的最小值为正。目标像素保留固定1像素睑缘零位，其后
使用.25像素opening AA，覆盖过渡为SDF 1..1.25；在无glint例外、原采样合法且
其他coverage为1时，SDF≥1.25的核心保留raw g(r)=r/s颜色。C74已通过当前单图
冻结照片门，仍不声明一般外观无瑕疵，也不扩大源所有权或读取unknown。窗口保留√2源足迹与1像素AA，源固定眼角
collar为眼宽8%
及外1像素AA。窗口、开口和保护域之外拷贝该stage源RGBA。

C58仅为最终颜色搬运增加来源几何材质支撑：旧/新圆并集半径
`max(R0,s*R0)`加`1.3*(√.5+√2)`源像素平台，之后用1像素smoothstep
接回exact源颜色。该标量guard为C1，不声明量化整图C1，也不是调亮或颜色校正。
core/g/Hermite、注册、gain及所有mandatory采样/alpha/整眼退出仍保持；颜色权重
为零也不绕过先前采样门。新白纹理用例的C57 baseline只在far-white exact与
color fade失败。C58 direct23及正确dense public1实际通过；原图照片通过已测门，旧预览仍失败；
不把几何material bound或定向工程通过写成外观合格。

完整双线性采样先检查四个源像素中心的窗口/feature/canthus几何，每tap须在
观测开口内且SDF>1，再检查已拥有像素的alpha255；未知开口/睑缘外RGB与alpha
不能参与准入或估色。所需unsafe、已拥有alpha失配或缺少合法材料会取消该眼edit，
另一有效眼独立处理，重叠所有权保留源。除glint材质表的限定替换，原本合法采样
不被polar补全替代。正负核心仅在几何 `openingOcclusion` 时可使用同眼、同一
源半径上两种不同合法stencil的angular低频颜色估计；保护、bounds或alpha失败
不能触发补全。这是已观测侧颜色的有限估计，不恢复隐藏组织或真实隐藏纹理。
正向近limbus只有外白色过渡可尝试四次有界射线收缩，不能越过源limbus安全半径；
每次均作完整四tap终验，不让核心径向改形或读取排除的眼睑材质。估计donor的
catchlight veto仅作用于离源limbus至少√2像素的内核，不把白色AA边自动当反光。

Glint候选只从.75源半径内的合法opaque支撑估计channel/luma中位数；亮核须满足
固定+32/+50并由排除所有global core的同半径侧背景再次佐证。组件背景中位数的
+8/+12用于AA增长。最终bright+AA union≤4%πR0²；按8邻域重新分组件，每组件
inclusive像素bbox最大边≤.4R0。完整sampling footprint恰为AA的Chebyshev1
halo，全部须源owned、opaque、r<R0−√2，halo面积与4%材质面积分开认证。
C54仅为AA材质建立请求内RGB背景表：两个observed、distinct、同源半径donor
排除全部AA，不排除完整known halo。这实质改变旧whole-halo donor策略，采样
所有权不因此放宽。采样通过原geometry/alpha门后才替换AA tap；源AA RGB在原位
恢复一次，只有halo羽化，alpha不变。known halo-only RGB仍可能被重映射成弱副本，
样本无bright copy不能扩为整个halo无副本；材料边缘圆度和接缝仍需实际外观验收。
无认证glint保留空表原路线；材料、完整footprint或donor不足仍整眼退出。

[playbook doc13 §5](../../beauty-sdk-playbook/docs/13-眼瞳大小专项.md#5-质量增强可选)
只提供可选方向；代码README称其为骨架。骨架仅定义正向，inner Hermite的D只达C0，
四次射线缺最终四tap检查，不能照搬；signed/C1与终验由实现独立补齐。径向圆核
不自动证明材料边缘或照片完整圆度。几何、像素与修补表仅属于本请求；不增加
video、blendshape、One-Euro或模型。

眉和另一眼使用有效观测包围域；鼻、唇保护使用既有 `FaceGeometry` 路径，dense
输入可提供实测路径，稀疏 Vision 路线仍有粗模板兼容支撑。这些固定保护框不代表
完整器官语义边界。框外平滑过渡、框内零位移；alpha 保持原值，跨不同 alpha
的采样保留 source。地图逐请求释放，描述/反射只返回尺寸与节点数。
连续EyeMap中的每字段先按固定源/cap场独立准入，再乘实际/cap强度叠加；最终仅对实际组合限界，
新增极小字段不改变既有分量的准入。总场与眼孔外使用的 shape-only 双线性场都受
梯度 Frobenius 范数 .45、较小合格眼宽 15% 位移界约束，姿态只进一步衰减。
梯度界属于连续EyeMap网格场，不涵盖独立iris径向remap/颜色过渡或稀疏边缘feather的数学导数，
也不是所有 stage 的合成界；feather 在 shape-only 与总场之间插值，仍保留位移界。

## 原图先行的 iris preview API

所有者可在串行CPU engine上显式调用
`processIrisPreviewResult(preparedImage:maximumPreviewEdge:parameters:textureExclusionMask:)`。
prepared handle必须由该engine对当前原图`.photo` RGB8创建，不能把缩略图handle
当作原图支撑。`maximumPreviewEdge`为1...960、默认960，输出等比缩略为opaque、
upright sRGB；这条显式缩图入口不改变普通`processResult`的same-extent/backend契约。
GPU entry、越界edge或其他engine/失效handle返回typed `BeautyError.invalidInput`。
透明输入不进入这条opaque canonical路线。可选texture exclusion mask使用原图
canonical upright/input-mirror-corrected网格，宽高须匹配原图，不能传预览网格mask。

```swift
// cpuEngine 的 renderBackend 已设置为 .cpu；沿用同一个串行 owner。
let original = try cpuEngine.prepareStillImage(image: originalCGImage,
    metadata: BeautyInputMetadata(orientation: originalOrientation, source: .photo))
let preview = try cpuEngine.processIrisPreviewResult(preparedImage: original,
    maximumPreviewEdge: 960, parameters: parameters,
    textureExclusionMask: originalTextureMask)
// 换图、releasePreparedStillImage() 或 reset() 后须重新 prepare。
```

每次参数仍从不可变原图执行normalization/local composition。原尺寸独立
originalIRPrefix执行color/texture及source refiners，然后iris remap，固定ImageIO
缩图得到I。C60的默认mask=nil基准BV先把原源缩图，再运行已有view color/texture/
source refiners，保留旧view处理顺序；map/source及眉部准入读取BV的独立pre-refiner
view材料，不能拿iris结果替代资格。显式原图网格texture mask非nil时，BV仍沿用
原prefix缩图路线及其source admission，不猜测或把原图mask借到view网格。

C61另有同一原prefix的伴随缩图BO=T(originalIRPrefix)。只有I.RGB==BO.RGB的
精确未变化像素跳过复制，防止原图/view prefix顺序差异作为iris差异泄漏；RGB差异
本身不授权编辑，original-source几何hard owner仍是唯一授权，不是RGB语义mask。
默认mask=nil时，纯iris的BO复用原源thumbnail；color/texture/refiner令原prefix
字节不同才额外缩BO，不为BO再执行color或refiner。显式mask时BO直接复用原prefix
基准BV，没有额外BO缩图。通过copy guard及hard owner的I颜色拷入BV，随后
剩余geometry只执行一次，搬运组合结果；不传播五个map的owner carrier。
所有sibling参数保留，定向baseline/组合检查不替代实际照片和一般组合外观资格。

handle仍绑定原图；成功换图prepare替换旧handle，release/reset使其失效，换图必须
清理对应engine的source/support。原规则由[prepared契约](PREPARED_PHOTO_EDITING.md#复用与恢复)
拥有。请求内iris owner不能导出或缓存为semantic mask。结果中的
`beauty.irisPreview.originalFirstCPU`与source/output尺寸记录所选执行路线；
`beauty.irisPreview.completedEyeCount`只计完整完成采样的眼，不证明非零变化、圆度或
资格。指标同用`beauty.irisPreview.`前缀：默认mask=nil的
`originalIRPrefixPasses=1`、`previewBaselinePrefixPasses=1`，
`colorTexturePasses=2`及`sourceRefinerPasses=2`；显式mask路径分别为1、0、1、1。
`postGeometryPasses=1`。这些是实际执行的prefix/stage次数，不是性能或效果分数；
BO缩图没有新增prefix pass。

C59非整数缩放/color/texture保护失败保留，不能沿用其先前定向通过签发资格。
C61最终fractional三用例3/0/0、4.680s及facade六用例6/0/0、20.553s通过；
新far-white用例的冻结C60 baseline 1case/1failure/0skip、1.314s仍保留，唯一
actual==BV delta139，C61不改断言后通过。C74在相同SDK rendering source上实际
原图/explicit CPU preview各1/0/0，四份冻结协议与完整来源/运行/结果binding gate
通过。新预览右负/正cap中心漂移1.687788443/.521271475在冻结2.296617432内。
该source/CPU API只在当前单图numeric、fixed26 observed partial-arc、声明保护、
alpha、neutral及repeat范围通过；独立复核保留细gray lower rim限制，非artifact-free。
旧十项及宿主UI6已在同版C74完成7/0/0；iPad同ID更新与原图Metal/CPU、CPU预览
图片检查已完成；两次物理面板scene guard失败、布局未执行的范围见下方记录。C58十一帧
离线结果仍仅为当时离线证据，C57/C58旧预览失败不被替换。不声明完整semantic
circle、semantic mask、美图等价、population或性能。现行进度由
[完成记录](../../plans/history/2026-10/A-2026-10-14-eye-iris-reference-delivery.md)拥有。

## 参考与证据边界

11 对截图可支持组内端点方向与分离性：眼高主要改高度、长度主要改宽度、内外眼角
各自局部变化、倾斜与眼尾上扬极性相反。各组没有数值、零态或其他字段状态，
不能推断 ±100、精确响应曲线，也不能用一张参考端点当作未编辑原图。
代码生成解析标记用于独立方向、幅度、保护和重复性验收；真实 detector 输入/输出
及视觉检查另列，不能相互替代。

首次接线的实际检查及未满足项见
[执行记录](../../plans/history/2026-10/A-2026-10-11-eye-reference.md)；前五项幅度、
保护、原尺寸外观与原生验证由
[完成记录](../../plans/history/2026-10/A-2026-10-12-eye-five-match.md)记录：单张已编辑参考端点的冻结幅度/跨轴/保护与眼区复核通过，
同一照片方法在模拟器CPU预览/原尺寸和iPad实际Metal原尺寸三配置分别通过；
设备十端点与独立CPU RGBA完全一致，已更新打开App并清理本次fixture。
尚未建立与美图同源、同零态、同数值的完整外观等价验收；不声明商业视觉质量或真机性能。

后五项另经新授权优化；[2026-10-12后五项完成记录](../../plans/history/2026-10/A-2026-10-12-eye-next-five-match.md)
拥有C28当时的CPU原尺寸/预览幅度、方向、分离、核心保护和眼区细节结果，及两批十项
参考滑杆的实际触摸/历史验证。该检查点前五项原尺寸十端点与同一sRGB输入下的C7实现基线PNG完全一致。

[2026-10-13真机交付记录](../../plans/history/2026-10/A-2026-10-13-eye-physical-delivery.md)
拥有随后iPad暴露的C28下至/外眼角失败及C29–C31仍未通过的下至结果；C32按上述
局部注册修复后，同一方法的实际Metal原尺寸1170×1550二十端点、CPU prepared
预览725×960后五项四十档各1/0/0，冻结V2幅度/方向/跨项/核心谓词及所需多尺度
身份和原生细节复核通过。二十个Metal端点均重复且与独立CPU RGBA完全一致；
前五项十端点与实际设备C28的canonical PNG完全一致，未改动的尾/倾斜/内角六端点
也完全一致。预览十端点重复，其余三十档未重复。该C32检查点执行8个不同最小SDK用例
及一次扩展后的同一采样间隔回归，不把C31的24用例重写成C32重跑。
2026-10-13该次同App ID更新并打开，保留应用数据，其owned设备媒体根独立确认已不存在。
[聚合回执](../validation/EYE_PHYSICAL_20261013.json)绑定源码、输入和原oracle摘要。
单张源仍为已编辑参考端点，缺共享未编辑零态、数值及参考四档曲线；不扩展到完整
美图外观、整器官语义保护、泛化、真机触摸/性能或全SDK/App回归。一般P3的一码值
量化仍是独立边界；十项滑杆沿用此前实现与带日期的触摸证据。

[2026-10-14眼瞳续作](../../plans/history/2026-10/A-2026-10-14-eye-iris-reference-delivery.md)
仍在修复。C40实际14个不同SDK用例/0/0、宿主6/0/0、模拟器UI2/0/0及
照片原图/预览/旧十项配置各1/0/0；冻结幅度、光度/暗纹理、四档及14有限核心/
眼框外保护通过，旧十项孤立cap PNG20/20 exact。这些测量保留。
但所有者指出眼瞳非圆；原“原生细节通过”判断已撤回，C40外观失败、不能交付。
iPhone13Pro原图actual Metal/独立CPU方法1/0/0，预览runner未连接；随后按所有者
选择iPad7/iOS18.7.10，同ID更新保留数据，原图Metal/CPU、预览CPU和原生面板
各1/0/0。设备工程通过不覆盖圆度/轮廓失败。
2026-10-15 C56实际direct21/public1与原生原图/预览方法通过；两眼两分辨率numeric、
声明保护和全部cap RMS/max通过，固定26点的右原图正cap及预览右正/负cap中心漂移
仍超2.29661743，未合格或重新交付。C57只改opening AA .25，direct22、正确dense
public1及原生原图/预览通过工程谓词；原尺寸全部已测partial-shape通过，预览右负/
正center drift 2.417508945/2.952131420仍超2.296617432，重复同样失败。numeric/
声明保护及全部RMS/max通过不取消中心失败，预览右眼/缩小下缘细节仍待修复。
C57拒绝，旧十项未重跑。C58已激活新增source-defined material颜色权重guard，
新白纹理用例C57 baseline实际1case/30assertion failures/0skip、77.632s；仅far-white
exact与color fade失败，其余core/保护/unknown/neutral/活动/repeat未失败。
direct23/0/0、448.865s（新材质用例74.125s包含其中），正确dense public CPU/Metal
1/0/0、42.858s及safe Debug build exit0已完成；原生iris原图/预览各1/0/0，
36.002s/16.060s。原图numeric/声明保护/已测partial-shape全部通过，旧预览numeric/
声明保护通过但右负/正cap中心漂移仍失败，重复失败相同，未合格/安装。
离线原图先IR、相同ImageIO缩图再按原图owner截断的11帧通过全部冻结谓词；这是
离线检查，只证明其当时范围。当前C74实际原图/explicit CPU original-first预览各
1/0/0，四份冻结协议required与完整binding gate通过；新预览右负/正中心漂移
1.687788443/.521271475在原冻结界限内。细gray lower rim仍是独立复核限制，
一次deep-donor试验变差已拒绝，生产源与oracle未改。截断在后续geometry之前，
原图prepared token保留兄弟参数。C74旧十项照片1/0/0、宿主UI6/0/0完成；21张
canonical PNG及完整RGBA与C40/C53完全一致。现有iPad第7代/iOS18.7.10已同ID
保留数据更新，原图actual Metal/独立CPU exact parity和CPU新预览各1/0/0；
两组照片四份冻结协议通过。iPad面板两次各0/1/0在前台scene数为0时停止；第二次
先明确foreground launch成功，仍未执行布局断言。当前iPad布局与触摸未验证。
这些是实际限定更新与图片结果，不是全量回归。
旧预览失败和冻结门槛保留，不扩大为完整语义圆、mask、泛化或性能。
2026-10-15 C55实际direct20/public1及原生原图/预览方法通过，冻结方向、正负四档、
area/photometric/amplitude与声明保护在两眼、两分辨率全部通过。固定26点partial-arc
仍拒绝右原图正cap与预览右正/负cap；这是有限observed轮廓，不能声明完整语义圆。
C55未重新交付/安装，旧十项未重跑，后续仅计划源几何计数诊断，无新参数或候选。
2026-10-15 C54检查点实际direct19/0/0、public CPU/Metal1/0/0，原生原图/预览
方法各1/0/0。两眼正负四档方向、单调性与声明保护通过，预览左眼numeric通过；
右侧partial-arc及部分幅度/光度仍拒绝，新版未重新交付或安装。
C53定向工程通过，但实际原图/预览的冻结数值与partial-arc
验收仍拒绝，未重新交付或
安装；逐版本执行与失败由活动计划拥有。C41首次执行8个直接用例、56个断言失败、
0 skip，其中3个用例失败；C42修正白色limbus AA误判catchlight的拒绝条件，
这些早期版本和之后的失败仍按原范围保留。新source/reference partial-arc检查
拒绝C40原图/预览的全部cap眼样本，旧数值通过仍保留。当前C74仅通过上述单图
冻结部分圆弧与像素门；完整语义圆/边缘/纹理质量不由这些门证明；实际安装及
物理图片检查是上述独立范围。
旧稀疏幅度、共享neutral/数值/参考四档与一般P3边界保留。
