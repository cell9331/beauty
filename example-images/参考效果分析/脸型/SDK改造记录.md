# 脸型三项 SDK 改造记录

日期：2026-10-16。实现范围为 SDK 的静态照片 CPU/Metal 共同几何阶段，包括照片预览所用的同一阶段。代码已落地，参考幅度标定与真实照片效果由用户后续审核；本记录不声明参考外观已复现。

## 本次实现

| 功能 | 新的照片实现 | 已替换的行为 |
| --- | --- | --- |
| [脸宽](脸宽/README.md) | 双侧脸颊水平内收与侧下颌上提分开定义；鼻核心独立保护 | 单纯横向内收、整片眼嘴鼻眉硬保护 |
| [小脸](小脸/README.md) | 独立横纵收拢、上部稳定过渡、眼核心保护；嘴与下巴参与，往下连续衰减 | 嘴部硬固定、轮廓窄带内共用收缩系数 |
| [面部流畅](面部流畅/README.md) | 下脸两段固定法向 C² 局部场，可同时产生横纵运动 | 三次轮廓趋势与 RGB 边缘残差驱动的预处理 |

三项在同一个源坐标中合成；每项的保护只作用于自己的场，不会因为流畅保护嘴而冻结小脸对嘴的上提。完整导数包含所有窗口和保护权重；使用解析保守全域梯度界，必要时统一减幅。对每个目标像素迭代求逆，检查前向残差，然后从不可变输入采样一次；失败拒绝整项组合，不逐像素拼接回退。

照片路径不再恢复这三项旧控制点，也不在前置阶段重复运行旧流畅像素修整器。规划改用独立观测资格，允许源轮廓本来平滑时仍尝试新流畅场；缺少可靠观测时拒绝三项，其他已准入功能保留。

本次没有新增实时 pixelBuffer 的连续场执行器。该输入种类仍属于既有独立后端路径，不能用本次照片测试宣称实时效果也已改造或验证。其他部位及其他脸型控制仍按既有阶段执行，三项之间的一次采样保证不扩展成全 SDK 所有功能的合成保证。

## 代码入口

- [数学模型](../../../BeautySDK/Sources/BeautyEffects/Render/BeautyFaceDisplacementModel.swift)：C² 紧支撑/平台、独立组件保护、完整 Jacobian、全域梯度认证、逆解。
- [源几何与初始参数](../../../BeautySDK/Sources/BeautyEffects/Render/BeautyFaceDisplacementGeometry.swift)：眼距坐标、观测轮廓定位、三个候选场、pose 与完整支撑边界检查。
- [采样器](../../../BeautySDK/Sources/BeautyEffects/Render/BeautyFaceDisplacementMap.swift)：整数像素中心、目标到源求逆、精确恒等区域及原图单次采样。
- [照片阶段](../../../BeautySDK/Sources/BeautyEffects/Render/BeautyStillImageGeometryStage.swift)：新三项接线与旧路径抑制。
- [CPU 几何入口](../../../BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift)：新流畅场不依赖旧控制点触发渲染。
- [规划准入](../../../BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift)及[域状态](../../../BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift)：保留合格强度，拒绝不执行的代理路径。

## 工程初值与待审核边界

局部轴由眼对确定，尺度为眼距。脸宽、小脸沿用 SDK 的有符号滑杆接口；正负对称属于初始设计，不是把端点测量除二得到的事实。流畅仍为单向强度。

当前幅度、窗口宽度、保护核心大小及其响应是代码中集中的工程初值，尚未由本轮参考拟合。解析限幅可能进一步降低实际幅度，不能将系数或安全测试等同于参考像素达标。

要求新鲜的观测脸缘、成对观测眼和观测外唇；脸宽及流畅还要求观测鼻部。拒绝退化/交叉/越界支撑及不合格 pose，不回退猜测脸框或旧拉点。仅有外唇形状不能证明闭嘴；下巴后的窗口延伸也不证明检测了真实颈部。当前采样仅接受全不透明栅格，其他输入原样返回。这些均是后续真实输入审核需要确认的范围。

面部流畅先落实有现有证据支持的下脸两段；上部相反方向没有新增可迁移证据，本次没有扩成更多自由控制点。它仍是待审核的局部校形候选，不称闭源曲率算法真相。

## 实际代码验证

使用既有 `BeautySDK/.build` 做 macOS SwiftPM 增量构建及定向测试，最终 **69 项通过、0 失败**：

| 测试类 | 数量 | 覆盖 |
| --- | ---: | --- |
| BeautyFaceDisplacementModelTests | 9 | 完整导数差分、C² 边界、独立保护、解析限幅、逆残差 |
| BeautyFaceDisplacementGeometryTests | 8 | 双分量、眼/鼻核心、嘴/下巴趋势、roll、pose、异常几何 |
| BeautyFaceDisplacementMapTests | 9 | 独立纹理/嘴标记的实际采样、组合单次采样、外围字节、拒绝 |
| BeautyFaceDisplacementPlanningTests | 7 | 平滑轮廓准入、有符号保留、组合冲突缩幅、coarse 拒绝与域状态 |
| BeautyStillImageGeometryStageTests | 4 | 缺失几何、拒绝保留兄弟工作、dense pose 与栅格保护 |
| FaceShapeWarpProviderTests | 26 | 直接受影响 provider 的既有字段/边界行为 |
| FaceSmoothSourceStageTests | 2 | 不再前置运行旧 smoother，不恢复旧点，保留兄弟字段 |
| FaceSourceRefinementPlanningTests | 4 | 共享规划下发际线和其他已准入工作保持 |

最终命令：

```sh
swift test --package-path BeautySDK --jobs 4 --filter 'BeautyFaceDisplacement(Model|Geometry|Map|Planning)Tests|BeautyStillImageGeometryStageTests|FaceSmoothSourceStageTests|FaceSourceRefinementPlanningTests|FaceShapeWarpProviderTests'
```

[最终本地日志](本地测量/SDK改造/related-tests-final.log)保存在忽略目录。早期测试修正了组合冲突缩幅的错误断言，以及旧测试对新三项已废弃代理路径的依赖。最终结果来自新构建，不复用旧测试结果。

本轮没有运行全 SDK 测试、模拟器/设备回归、实际参考照片拟合或人眼外观验收。单元测试只证明上述代码级行为，最终照片审核由用户进行。
