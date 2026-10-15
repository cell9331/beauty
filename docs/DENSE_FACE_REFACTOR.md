# 478点静图改造契约（2026-10-09）

当前实现由代码/测试与根级owner拥有；本页解释新机制和限定范围。
[学习手册](refactor-playbook/README.md)中的视频、TPS、GPU原生mesh等仍是候选，
不得与本次实际实现混写。[完成记录](../plans/history/2026-10/A-2026-10-09-dense-face-refactor.md)
分别记录成功判据、被拒绝的候选和未测范围。

## 请求内支撑

[BeautyDenseFaceSupport](../BeautySDK/Sources/BeautyEffects/Planning/BeautyDenseFaceSupport.swift)
随`FaceGeometry`存活，不新增public/Codable数据、不缓存观测、不产生持久坐标。

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

[BeautyDenseGeometryMap](../BeautySDK/Sources/BeautyEffects/Render/BeautyDenseGeometryMap.swift)
只用于带dense carrier的新静图路线；Vision兼容采样和retained `Warp.metal`保持原字节。

1. 每轴合并17个画布格点与全478点的33个分位点，去除过密候选节点，固定画布边界。
   十个虹膜中心/环点是必选节点，避免小结构在全脸分位采样中消失。
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

最多2048个控制点、64个独立保护行边界；加入虹膜必选点后每轴最多60格点，加入行边界后最多124行。
行界以`floor(cutoff·H)/H`作为必选节点，不能被分位去重丢弃。
输入尺寸受既有50,000,000像素限制；异常/超量/过小支撑拒绝整张候选映射，
不静默丢点或把坏点clip成合格数据。颜色与独立source-raster sibling保留自身行为。
最大强度组合可能被共同减弱；字段点数是规划计数，不代表输出改善或每点足量位移。

CPU与GPU-selected静图共用这个CPU-owned网格阶段；Metal仍执行已有颜色/transport，
该路线不提交重复的旧geometry pass。没有新增GPU API、shader或后台；不是端到端GPU。
256点Metal容量回退规则仍适用于没有dense carrier的旧点路线。

## 独立的磨皮与锐化

[BeautySkinTexturePipeline](../BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift)
保留3×3/5×5/7×7足迹、源RGBA8、alpha/硬边与颜色准入、96MiB三缓冲预算和host精确保留。
空间核乘以有界亮度差权重，得到保边低频；不是完整Guided Filter、Lab或线性光实现。

平滑分支降低亮度残差；锐化分支按源定义的方向梯度相干程度恢复细节，强平滑时限制
恢复量。二者不再用一个`sharpen*2.5−smooth*1.5`常数增益相互抵消。
最终同增量RGB仍限制在±16，alpha保持原值；没有新增全图浮点/积分图。
host mask只控制输出pixel准入，仍允许读取不可变邻域，不改变未mask像素的既有独立结果契约。
这不承诺识别毛孔/斑点，也不保证任意暗光噪声不被增强。

## 框架资源与声明边界

[BeautyImageContexts](../BeautySDK/Sources/BeautyCore/Models/BeautyImageContexts.swift)只复用
sRGB、Display-P3和Device-RGB的固定三个Core Image context。其他ICC profile逐请求创建，
不建立无限注册表。检测raster、canonicalizer、texture、CPU几何和Metal输入转换共用它；
图像、mask、landmarks与native task不进入该cache。同engine仍需caller串行调用。
依据[Apple context复用原则](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_performance/ci_performance.html)。

本轮证据限于现有生成像素oracles、独立图案/语义支撑、同一模拟器两张授权肖像和完整SDK门禁。
不提升整张taxonomy为一般人像资格，不声明真机时延/温升/能耗/长稳或实时视频性能。
视频时间戳/身份/One-Euro、GPU原生mesh、全链零拷贝、按脸尺度扩大的纹理足迹、多脸编辑、
新语义解析模型及新美白曲线均未交付；未来各自需要明确范围和独立验收。
