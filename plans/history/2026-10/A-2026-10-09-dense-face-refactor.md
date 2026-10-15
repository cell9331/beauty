# A-2026-10-09-dense-face-refactor

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex / project owner |
| Started | 2026-10-09 |
| Completed | 2026-10-09 |
| Source Request | 所有者同意优化，并要求用好478点功能/优势、遵循行业实践、避免重复踩坑。 |
| Scope | 当前SDK静图管线的资源复用、478点语义/姿态利用、美肤机制与统一几何安全改造；公开字段/default、输入输出及请求内隐私契约保留。 |
| Current Step | 静图核心改造与文档收尾完成；完整SDK1098/0/0、9 opt-ins，原生iOS24/0/0。 |
| Verification Policy | 独立生成像素/几何正负例、组合/保护/元数据/失败恢复；定向SwiftPM、同一已有iOS验证宿主；最终archive-first完整no-skip SDK门禁。 |

## Decisions and boundaries

- 使用已授权固定的MediaPipe 1.1.0与float16/1模型；无需新权重、训练或远程推理。
- dense points/iris/pose只在请求内使用；没有逐点confidence时不伪造概率或可见性。
- 源空间、距离单位与像素中心明确；Vision兼容路线的冻结采样不能无证据批量替换。
- 单一静图几何映射先验证源/目标、覆盖与组合安全；固定拓扑不做逐帧Delaunay，
  不复制未经验证的68点骨架，不把3D脸面连接直接当全画布覆盖。
- CPU参考与selected-backend约定保留；共同CPU-owned阶段必须据实记录，不声称全程GPU。
- mask是有界几何保护，不冒称皮肤/牙齿/头发语义分割；host精确保留与碰撞回源不变。
- EYE/SEG终局与去脂暂停保持。新工作不重开已关闭研发、不弱化冻结挑战、不重签历史失败。
- 当前范围是静图。视频是原建议中的条件项：本轮不新增时间戳/身份/旧观测复用API，
  不把image mode或检测跳帧称作视频跟踪；在记录中保留这一明确边界。
- 新的几何/像素规则只在本次验证域内声明；未测设备性能不作为完成阻塞或通过结论。

## Checklist

| Step | Status | Required evidence |
| --- | --- | --- |
| Record scope and prospective checks | `completed` | 当前owner/代码、原手册评审、一手原理；先固定正负例与判据。 |
| Reuse managed image resources | `completed` | 三种固定profile有限复用；8个并发独立raster请求输出隔离。 |
| Use dense semantic and pose support | `completed` | 原生两肖像姿态/可见虹膜；完整/部分环、闭眼/坏点、矩阵与退化轮廓检查。 |
| Improve skin texture processing | `completed` | 原像素单项、旧抵消组合、保护及暗肤色噪声判据通过；扩大足迹/多尺度未交付。 |
| Unify dense geometry and safety | `completed` | 固定覆盖、像素距离、400点组合/正面积、保护行、双向圆环/脉冲和非零extent通过。 |
| Native and complete SDK verification | `completed` | 同一模拟器24/0/0、CPU/GPU组合最大通道差≤2；最终完整SDK1098/0/0、9 opt-ins。 |
| Update owners and close record | `completed` | 架构/设计/安全/可靠性/使用/质量、taxonomy与手册同步；完成记录、计数和导航收尾。 |

## Prospective acceptance

- neutral/无脸/跳帧/禁用输出保留各路线原契约；坏点/矩阵与失败请求不能污染后续结果。
- 资源复用以输出与有限复用生命周期证明，速度变化仅在可比较的实测范围报告。
- 几何：非对称棋盘/脉冲/圆环/背景直线和预先生成的语义肖像；正向/反向、长宽比、
  边界与非零extent；源/目标网格有效且输出覆盖，无坏候选或静默丢点。
- 效果：源图确定的眼/鼻/唇/脸轮廓目标位移、负例、保护区域、重复、颜色/alpha/尺寸，
  以及强度组合；不能用变化像素数或新算法自己的admission作独立真值。
- 美肤：源定义的低对比细节、平坦负例、软边/高反差边缘、暗光噪声与不同肤色；
  平滑降低目标细节、锐化提高可用边缘、联合参数仍有可解释结果；保护像素精确。
- 本轮接受标准/输入不能在观察输出后放宽；失败候选不进入生产，改用有新假设的实现
  并保留失败原因，未交付部分明确记录。

## References

- [当前架构](../../../ARCHITECTURE.md)、[设计](../../../DESIGN.md)、[验收政策](../../../docs/IMAGE_EFFECT_ACCEPTANCE.md)。
- [实现与验证边界](../../../docs/DENSE_FACE_REFACTOR.md)、[学习手册](../../../docs/refactor-playbook/README.md)及原骨架静态评审。
- [Apple Core Image性能原则](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_performance/ci_performance.html)：context复用、减少纹理传输。
- [MediaPipe iOS任务](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker/ios)：模式、输出与时间戳边界。
- [Guided Image Filtering](https://people.csail.mit.edu/kaiming/eccv10/index.html)：保边/多尺度原理，方法仍需本域比较。

## Implementation checkpoints and rejected candidates

- 三种named Core Image context复用，未知profile不缓存；定向并发8个独立raster保持各自字节。
- 全478点分布生成固定连接画布网格；虹膜十点是必选节点，保护行也是必选节点。
  每三角梯度界与脸像素短边6%合成位移预算只会共同减弱计划，不截断控制点。
- 实际可见虹膜环替代dense路线上按脸宽构造的四点边界；近刚性旋转姿态衰减映射。
  pupil-size仍遵循原双眼配对契约，gaze逐侧独立；不声称瞳孔/遮挡/深度语义识别。
- 美肤采用小窗口双边权重亮度低频和分离的平滑/相干细节分支，保留±16、alpha、host
  mask与原3/5/7足迹。没有增加帧级浮点数组或Guided Filter/大尺度能力。
- 首个较窄range候选定向16项有14次断言失败；后续仍过弱的候选未满足原`.65`纹理
  方向阈值。均未保留为最终实现，阈值未放宽；最终范围权重/独立分支通过原方向和保护。
  初版组合测试误读了参数cap映射，已纠正成实际旧抵消组合`.5/.3`；旧criteria不变。
- 完整iris环必须全在眼内的候选在两张真实native输出上各失败一次，24项中1个用例、
  2次断言失败；未放宽native至少一侧有效的标准。新假设改为遮挡下只授权眼睑内环点，
  完整/部分/闭眼/坏中心和原生两图均通过。没有把隐藏环点作为可见点。
- 最终独立圆环/脉冲双向、实际CIImage非零extent与sRGB、暗肤色噪声、虹膜像素面积
  正向等12项定向测试全部通过。400点极端叠加每三角正面积≥源面积30%、梯度≤.45；
  圆环/脉冲中心位移各方向超过`.2 px`；生成虹膜暗盘面积增幅超过5%。
- 临时对照检查实际64×64纹理/软边源、平滑、锐化及组合原始输出，未见硬边污染或
  对声明保护区的改动；这仅限这些代码生成输入，不授予两张native肖像外观质量。
- 最终同一iPhone15Pro/iOS17.5原生`24/0/0`，xcresult独立核对；两图姿态/可见iris、
  public组合像素、CPU/GPU最大通道差≤2、alpha/尺寸、20次重复及失败恢复通过。
  外部宿主复用原稳定Build与单设备，无克隆、重置、签名或新App源修改；已释放占用。
- 生产shader/77字段/default/target/backend/模型不变；原Vision效果与EYE/SEG冻结终局
  保留。扩大纹理尺度、视频、GPU原生mesh和全链零拷贝列入候选，不声称已经完成。

## Final closeout

- 最终生产实现冻结后，archive-first完整SDK门禁退出0：**1098 tests / 0 failures /
  0 skips，9 opt-ins**。两个归档、SDK-only boundary及自测、backend可用性/一致性、
  consumer、CPU像素oracle和示例存储前置检查全部通过；不合并未执行的backend结果。
- 最终原生iOS独立xcresult摘要为**24 tests / 0 failures / 0 skips**，包括9项原探针
  和15项SDK测试；同一已有iPhone15Pro/iOS17.5，两张授权肖像。原生检查涵盖实际姿态、
  可见iris、组合输出、CPU/GPU最大通道差≤2、重复性与失败恢复；不签人口泛化或真机速度。
- 所有新增定向正负例进入完整门禁；测试数量由运行摘要核对，未将文件/断言数量当测试数。
  当前实现限生成几何/纹理验证域与两图原生集成，原taxonomy效果资格不批量提升。
- 收尾重新核对两个归档、post-archive边界、示例存储及`git diff --check`均通过；
  20份当前文档的259个本地链接全部存在，完成计划已迁入历史索引。
- SDK-only、固定模型依赖及历史证据保留；临时原始像素对照不进入仓库证据。后续候选
  见[当前技术债](../../debt/current.md)，本计划无剩余执行步骤、无新模型或视频任务。
