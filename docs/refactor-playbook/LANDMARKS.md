# 关键点、坐标与时序

[返回入口](README.md)。本章将当前 MediaPipe 接入与未来视频稳定性设计分开。

## 478 点能提供什么

当前 iOS 模型输出478个三维点，可选面部变换矩阵；SDK关闭 blendshapes。
Face Landmarker 是定位与表情任务，不提供身份识别结果。
官方任务说明见 [Face Landmarker 概览](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker)。

| 支撑 | 当前 SDK 使用 | 含义边界 |
| --- | --- | --- |
| 眼周与虹膜中心 | 两侧16眼周点、468/473中心及各4点虹膜环；可见环点供大小/视线准入。 | 中心点不是精确瞳孔边界、眼白蒙版或遮挡可靠性证明。 |
| 眉毛 | 各5点有序trace；双边10点眉包络加入纹理保护。 | 当前不是眉毛毛发分割，也未提供移动后的纹理补全。 |
| 鼻 | 7点鼻脊、16点轮廓、各3点山根/鼻尖支撑。 | 点位更细不等于鼻孔mask或真实鼻部高度。 |
| 唇 | 各20点外/内唇路径。 | 内唇围成的区域包含牙、舌、口腔与阴影，不能全部白牙。 |
| 下脸与脸界 | 21点下轮廓、36点oval用于bounds/合格多边形纹理准入；全478点分布用于网格密度。 | oval上缘不是实际发际线、头发外缘或颅顶。 |
| z / 4×4矩阵 | 有限z；可选矩阵经布局、齐次行、非奇异检查。 | 不是每像素深度、相机标定或直接二维warp。 |

点位 authority 是 [MediaPipeFaceTopology](../../BeautySDK/Sources/BeautyDetection/BeautyFaceMesh.swift)，
不再按 dlib 68 点的0–67编号编写规则。SDK左右指**规范图像侧**，
与 MediaPipe 解剖学 `LEFT_EYE` / `RIGHT_EYE` 命名不同；镜像前后不要靠名称猜方向。

## 统一空间，明确边界

当前区域支撑采用**正向后的图像栅格、左上原点、归一化x/y**。
已经按 `isInputMirrored` 校正的输入不是手册所说的固定“未镜像传感器空间”。
预览镜像属于显示元数据，不参与检测像素或算法坐标。

```text
原图 + 显式方向/输入镜像
  → 正向且输入镜像已校正的检测像素（必要时仅检测端缩小）
  → MediaPipe 图像归一化坐标 → 区域准入 → 几何/像素算法
  → 宿主自己的显示尺寸、裁切与预览镜像
```

MediaPipe 接收已正向的 `MPImage`，不得再经过 Vision 的翻y/方向路径。
Vision 仍由 [CoordinateMapper](../../BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift)
从左下归一化转换。当前公开SDK不输出原始点，也不承诺UI叠加坐标接口。

距离类运算需先将 `x/y` 换到相同单位：`p = (u·W, v·H)`。
归一化方形空间直接取欧氏距离在宽屏/竖屏会改变圆形半径；引入新规则时应显式
采用像素距离或等价宽高比校正，保留既有规则直到其重新验收。
像素中心建议统一为 `((i+0.5)/W, (j+0.5)/H)`；
当前存在兼容采样分支，不能无验证把所有 `W−1` 约定替换。

测试参照 [MediaPipeAdapterTests](../../BeautySDK/Tests/BeautyDetectionTests/MediaPipeAdapterTests.swift)：
八种EXIF方向×两种输入镜像，使用非对称色块检查实际像素排列；另外验证
非零extent、检测缩放、输出尺寸、预览镜像独立性和一次转换。

## 姿态与准入

矩阵描述标准脸到检测脸的映射。MediaPipe 1.1.0 的 packed column-major 数据
在SDK边界显式转换为 row-major；细节由
[资源与布局记录](../../BeautySDK/ThirdParty/MediaPipe/README.md)拥有。
当前在近等尺度、正交与右手旋转检查后，以正向z余弦衰减dense统一映射；
背向/强侧转退出映射，roll不削弱正脸。矩阵不直接乘到像素上；
具体规则见[实现契约](../DENSE_FACE_REFACTOR.md)。

未来若计算 yaw/pitch/roll，要先定义坐标轴、左右符号、旋转顺序与镜像下的解释，
确认3×3部分满足所采用的旋转分解条件；存在尺度/数值残差时先归一化或正交化，
异常矩阵只撤销姿态支撑。合成已知旋转应能恢复角度，真实点位方向再作补充校验。
不要把有限可逆矩阵直接当作已标定的纯旋转。
屏幕z与度量3D空间的区别参见官方旧版
[Face Geometry 概念](https://chuoling.github.io/mediapipe/solutions/face_mesh.html#face-geometry-module)；
该资料解释几何概念，不替代本版本 Tasks 桥接契约。

当前整张 mesh 必须满足478点、x/y有限且在 `[0,1]`、z有限；不合格脸拒绝，
有效同帧其他脸保留。姿态失效不抹掉有效点，后续区域仍须通过自身准入。
内部 `confidence = 1` 表示通过任务阈值，不是100%置信概率；无逐点质量输出时
不能凭空构造逐点置信度或“可见”标志。

## 时域稳定性是另一份契约

当前 CPU image mode 是逐次图片推理；复用模型初始化，不复用结果。
indexed camera/video 的跳帧会撤销依赖人脸的效果，`detectionFrameInterval` 不代表跟踪。
官方 video/liveStream 模式具有不同调用和时间戳要求，且 `numFaces = 1` 才应用其平滑。
见 [官方 iOS 模式说明](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker/ios)。

如以后增加视频能力，先明确这些问题再添加滤波：

| 问题 | 建议先定义的行为 |
| --- | --- |
| 结果属于哪帧 | 单调时间戳 + 输入/结果身份；限制观测年龄，过期退出。 |
| 推理跟不上 | 有界最新帧队列；丢帧策略与返回结果明确，禁止积压。 |
| 换人或主脸切换 | 稳定身份仅用于请求流跟踪；切换、方向/尺寸变化和reset清空状态。 |
| 丢脸 | 没有可靠当前支撑时停止几何；若希望渐隐，必须另证明支撑仍有效或跟踪可靠。 |
| 多人脸 | 每脸独立状态；数组下标或面积排序不是持久ID。 |
| 脱离静图 | 图片调用保持历史无状态确定性；视频状态不污染静图结果。 |

用上一帧补NaN或低质量点会改变SDK当前安全退出契约。渐隐强度也不会修正旧点位的
空间错位；“最近结果”不能替代时间对齐。眨眼EAR、张嘴度和姿态门控的阈值
均需根据实际语义路径标定，不能照搬68点常数。

## One Euro 的学习要点

One Euro 根据速度调整截止频率，基本形式为
`alpha = 1 / (1 + 1/(2π·cutoff·dt))`，
`cutoff = minCutoff + beta·abs(filteredVelocity)`。
先令beta为零调静止抖动，再增加beta减运动延迟；坐标单位变化要重新解释beta。
这是作者的 [调参方法](https://gery.casiez.net/1euro/)，并非必须优于一切EMA的保证。

候选做法是将刚体相似变换与局部残差分开：可靠稳定锚点估计平移/旋转/尺度，
局部残差滤波后还原。只滤局部残差无法消除该变换自身的抖动；嘴、眉等表情点
参与配准还可能把真实表情吸入刚体估计。位移再滤波会增加延迟，应与点位滤波联合测量。

原示例缺少有限参数/输入、重复/倒序时间戳、长间隔、空点集、退化尺度与身份重置处理。
不可依赖 `precondition` 对外部数据崩溃；状态提交应发生在全量校验后，拒绝帧不能污染
后续好帧。静止噪声、匀速、阶跃、丢帧和恢复分别验收方差/滞后，
不能仅验“方差下降80%”。作者
[参考实现](https://raw.githubusercontent.com/casiez/OneEuroFilter/main/python/OneEuroFilter/OneEuroFilter.py)
也使用前次滤波值估计导数；原骨架此处不应被误判为错误。
