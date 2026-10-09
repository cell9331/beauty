# 美肤与五官：支撑、机制与效果分开

[返回入口](README.md)。以下讨论机制与候选改进，不新增或提升控制状态。
准确字段/范围由 [taxonomy](../SDK_EFFECT_TAXONOMY.md) 和
[BeautyParameters](../../BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift)拥有。

## 美肤的可吸收思路

磨皮应改变皮肤局部纹理而保留边缘和质感；美白/红润改变色调；锐化改变细节。
把饱和度/对比度变化当成磨皮，或把颜色变化当成形变，会让验收失去对象。
当前磨皮/锐化使用双边低频和独立细节分支，共享CPU实现、3×3/5×5/7×7邻域，
受新鲜主脸、保守椭圆、粗五官/颜色/硬边及dense几何保护限制；不是完整导向滤波或语义分割。
旧常数gain抵消已撤除；组合效果和保护按[本轮契约](../DENSE_FACE_REFACTOR.md)验证。
源码参照 [BeautySkinTexturePipeline](../../BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift)。

候选高低频分离可写为：`L = edgePreservingFilter(I)`，`H = I−L`，
`B = L + k·H`，`O = I + m·amount·(B−I)`。
中性amount=0必须恢复源图；k接近1保留更多细节，但仍需验证细节究竟是毛孔、瑕疵还是噪声。
这套公式不自动等于祛痘、去斑或肤色均匀化，也不能用加颗粒掩盖过度平滑。

导向滤波是可评估的保边方法：半径与正则参数影响细节/边缘行为；复杂度与像素数相关，
“O(1)”应理解为特定box实现每像素相对窗口半径的成本，不是全图常数时间。
降采样滤波后恢复全分辨率时，用原图引导并检查边缘污染。
依据：[作者的 Guided Image Filtering 论文与说明](https://people.csail.mit.edu/kaiming/eccv10/index.html)。

| 效果 | 候选机制 | 验收关注 |
| --- | --- | --- |
| 磨皮 | 保边低频 + 可控高频，按脸尺度标定半径。 | 低对比瑕疵改善；眉眼唇、头发、饰物及细节不误伤。 |
| 美白 | 明确工作空间的中间调曲线与高光压缩。 | 暗/中/深肤色保持可见层次，亮部不过曝，neutral精确。 |
| 红润 | 局部受控色度变化，与美白共享颜色预算。 | 鼻/颊权重与原色相适配；嘴眼和背景保护。 |
| 锐化 | 亮度细节增强、噪声门限与halo约束。 | 有效边缘增强同时不放大暗光噪声或帧间闪烁。 |

Lab和线性RGB不是可互换标签；转换时要写明原色、白点、传递函数、范围、alpha和输出空间。
仅保留Lab-L不保证出界颜色或亮部自然；RGBA16F也不会自行变成线性/宽色域。
滤镜/LUT前后、锐化前后必须用组合像素对照决定，不照搬统一顺序覆盖所有当前路线。
未来post-warp锐化若使用mask，也必须把mask或支撑同步到输出空间。

## mask 的职责

| mask来源 | 能证明什么 | 不能证明什么 |
| --- | --- | --- |
| 脸框/关键点多边形 | 大致空间区域。 | 其中所有像素都是皮肤、牙齿或眼白。 |
| 颜色/边缘阈值 | 满足某些源像素条件。 | 材料/解剖语义；同色物体仍可能混入。 |
| 语义解析模型 | 模型定义的分类预测，经本域验证后才能使用。 | 自动获得任意遮挡、肤色与纹理域资格。 |
| host独立蒙版 | host明确告知应保护的具体格点。 | SDK具有自动识别；当前也不保护所有着色或几何效果。 |

柔边权重适合局部着色，当前 `BeautyTextureExclusionMask` 的0/255则是**精确保留**契约，
不能为了羽化把保护值变软。该保护还应考虑滤波邻域跨区污染，按输出像素与邻域分别验证。
当前host蒙版仅影响磨皮/锐化，见 [保护指南](../HOST_TEXTURE_PROTECTION.md)。

478点密度不解决同肤色贴片和完整低对比唇缘自动保护缺口。
原手册提出的皮肤/头发/眼镜分割只能作为未验证方法，未授权下载或接入新的解析模型。

## 五官规则如何落到当前 SDK

每项新规则都先固定局部轴、正负方向、支撑和保护对象；参数名称相似不代表机制相同。

| 功能组 / 当前字段例 | 可吸收的规则 | 必须保留的边界 |
| --- | --- | --- |
| 脸型：`faceSlim`、`faceVShape`、`jawSlim`、`chinLength` | 轮廓成组位移，下巴/耳侧衰减，颧骨与下颌共享预算。 | 背景线条、发丝、耳饰；源边界准入不能只用脸框代理替代。 |
| 比例：`midfaceLength`、`philtrumLength`、`lowerFaceLength` | 改间距，联动邻近结构，避免直接压扁五官。 | 已合格的生成图二维范围，不扩大成骨骼/深度建模。 |
| 头部：`headSmall`、`headWrap`、`hairlineHeight` | 以实际源边界确认支撑，再定义外围补偿。 | 478点没有真实发际线/头顶；现有高对比发肤等限定范围保持。 |
| 整脸：`wholeFaceXPosition`、`wholeFaceYPosition`、`wholeFaceTilt` | 一致刚体/整体规则，避免五官独立撕裂。 | 当前为图像平面操作；照片姿态矩阵不授予3D塑颜。 |
| 眼：`eyeSize`、`eyeHeight`、`eyeTailLift`、角点控制 | 上下睑、内外角成组；明确每侧准入；检测睑线交叉。 | EAR门控需新验证；不能因单侧坏点抹去另一侧有效工作。 |
| 虹膜/视线：`pupilSize`、`gazeCorrection` | 区分虹膜中心、眼睑范围与视线目标；限定2D位移。 | 当前局部几何不是3D眼球重定向、眼神模型或精确虹膜分割。 |
| 眉：七个 `eyebrow*` 字段 | 整眉/眉头/眉尾规则独立；眉眼最小距离和重叠保护。 | 当前几何trace不包括毛发重绘/原眉擦除；完整纹理移动需新契约。 |
| 鼻：`noseSlim`、`noseWingSlim`、`noseTipSize`、`noseBridge`、`noseRootNarrowing`、`noseTipLift` | 鼻翼/孔成组，山根与鼻尖作用域分开，控制鼻唇联动。 | `noseRootNarrowing`是独立收窄；不能改成提亮或别名noseBridge。 |
| 嘴：`mouthSize`、`mouthWidth`、`smile`、`lipPeakDefinition`、`lipPlump` | 外/内唇与嘴角一致，中心/牙齿区域约束，张嘴状态另验收。 | 丰唇是几何，`lipColor`是颜色；微笑二维改动不等于完整表情重建。 |

MediaPipe让鼻/唇/轮廓使用实测坐标；目前又接入可见虹膜环、几何纹理保护和姿态衰减。
这不等于全部候选联动、EAR视频门控、眼球重定向或纹理补全已实现。
细节参照 [BeautyFaceGeometryAdapter](../../BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift)。

## 局部着色与高阶能力

白牙应在真实可用的牙区域里控制去黄/提亮并保留牙缝；内唇多边形加亮色阈值只是候选，
口腔高光、舌和外来白色物体需要负例。眼白去红需排除虹膜、睫毛、眼线和高光，
“降红色饱和度”不能自动保护结构。当前有界白牙/眼白静图能力的独立原像素生成与
碰撞回源合成规则由 [BeautyLocalRetouchComposition](../../BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift)拥有。

眉毛位移若采用完整区域搬移，可能需要源区域填补与目标纹理，但“先抹眉再warp”
也会让采样源失去眉毛。应明确不可变源、背景填补层、眉毛内容层及遮挡顺序；
连续图像warp与剪贴式搬移不同，不能规定所有眉毛几何都必须先inpaint。

去脂、眼袋、黑眼圈、泪沟、上睑提肌是不同目标。原手册把去脂写成下睑提亮/平滑，
与当前保留的上睑字段不一致；提亮或滤波不能证明脂肪识别/体积减少。
`upperEyelidFullnessReduction` 保持 `suspended`；EYE/SEG失败与关闭状态见
[终局记录](../RETOUCH_FINAL_DISPOSITION_2026-10-03.md)。
3D重建、补纹理、眼球重定向和泛化解析均需要新输入/模型/证据，本文不安排其实施。

## 强度如何标定

保留所有字段当前neutral默认和Codable兼容；UI的0–100刻度不直接等于SDK位移或亮度。
候选曲线分别标定低/中/高和正/负方向，并检查最大叠加后仍达到各项目标和保护。
闭眼、口罩和遮挡应以可靠支撑决定退出；不能只因为图上仍有478点就继续编辑。
结果失败时保留负例和原标准，不能调整mask/阈值直到同一输出过关。
