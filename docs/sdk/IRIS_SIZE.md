# 眼瞳大小：保留当前版本

## 当前决定（2026-10-15）

所有者要求“眼瞳暂时不弄，保留现在效果，合并main并写文档”。本轮保存已有
眼瞳实现，暂停进一步灰边优化和模型评估。该决定是接受保留当前版本，**不是**
完整美图外观达标：缩小极值仍可能看到虹膜下缘细灰边/短线；此前失败不改签。
未给出新目标、信息或资源前，不从旧计划的下一步自动恢复研究。

这里只整合眼瞳及必要的已完成固定原图/共享stage依赖，未导入眼形、眉、嘴、鼻、
脸型的后续连续参考map，也未修改外部编辑器或更新设备应用。

## 参数与采样

- `BeautyParameters.pupilSize` 为双向 `-1...1`，零为中性；非有限值归零。
  effective cap沿用 `±BeautySafetyCaps.pupilSize`（0.25），组合预算按绝对值计算。
  负值缩小、正值放大，保留现有Codable键，不增参数字段或非零默认值。
- dense静图路线使用源空间反向径向重映射。可见虹膜核心统一等比缩放，外侧过渡
  带平滑回到恒等；不再叠加dense虹膜的旧网格拉点。几何窗、眼睑开口、源采样
  支撑及目标/保护材料在请求内准入；不确定输入、闭眼、坏环或姿态不合适时退出。
- 原图像素、圆注册、源owner及修复材料均不进入持久诊断或公开结果。缩小暴露的
  已准入眼白使用保留的有限光照重建；它不能证明未知混合边缘的真实材料归属。
- 本次保留main的其他几何行为；没有dense支撑的旧正向兼容路径不因此取得新的
  圆度/精确区域或负向效果资格。单独眼瞳的保护结论不表示同时启用兄弟效果时
  全图都不变：兄弟效果仍按其自身作用域执行。

算法源文件从原开发分支逐字保留；本次仅适配共享stage及公开预览接线，未继续
更改圆注册、采样系数、灰边修复或验收阈值。历史检查点不能覆盖此次集成版本。

## 所有者调用

常规原尺寸静图继续使用 `processResult`，CPU/GPU选择沿用原契约；dense眼瞳采样
在两条路线共用CPU-owned阶段。显式CPU预览将眼瞳放在原图上采样，再缩略并执行
main已有的其他几何；只从prepared原图出发，不检测编辑后的输出：

```swift
let engine = try BeautyEngine(configuration: .init(renderBackend: .cpu))
let photo = try engine.prepareStillImage(image: originalCGImage)
let preview = try engine.processIrisPreviewResult(
    preparedImage: photo,
    maximumPreviewEdge: 960,
    parameters: BeautyParameters(pupilSize: -0.25)
)
let fullResolution = try engine.processResult(
    preparedImage: photo,
    parameters: BeautyParameters(pupilSize: -0.25)
)
engine.releasePreparedStillImage()
```

`maximumPreviewEdge` 只允许1...960；显式GPU预览、过期/外来handle或非法上限在
执行前抛出 `invalidInput`。输出为有界不透明sRGB缩略图，原图优先预览有独立
aggregate metrics，不冒称GPU预览。exclusion mask仍使用原图canonical grid，
不挪作虹膜owner。固定原图生命周期见[固定照片编辑](PREPARED_PHOTO_EDITING.md)。

## 验证和限制

本轮实际检查、运行次数、初次失败及最终结果由[整合记录](../../plans/history/2026-10/A-2026-10-15-iris-current-effect-integration.md)
拥有。既有23项重映射、5项材质、6项预览及3项分数缩放
检查保留原断言，另检查参数、共享stage、prepared生命周期、兄弟组合与实际Metal。
这些检查不替代原照片的完整美图外观验收，不新增泛化、触摸手感或设备性能声明。
