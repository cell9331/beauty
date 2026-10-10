# A-2026-10-09-owner-mediapipe-debug

Status: `completed`（2026-10-09）。所有者截图仍显示Vision复检87点，要求新模型在实际App中生效。

## Scope and finding

- SDK的iOS production factory已经使用固定MediaPipe；外部BeautyEditorApp本地包指向正确。
- 宿主debug仍独立调用VNDetectFaceLandmarksRequest，显示文字写死为Vision；此前SDK
  集成验证没有更新/验证该宿主与手机已安装二进制，属于交付接线遗漏。
- 新增owner-only、非Codable、输出/Mirror脱敏的瞬时诊断SPI，复用SDK生产adapter/
  canonicalizer/固定模型。宿主actor独立持有诊断实例，不污染渲染engine选择状态；
  原图缓存和当前输出复检仍限debug开启的当前内存会话。
- 不复制模型/另建MediaPipe包装；Vision仅保留系统人物分割与macOS既有检测用途。
- 本轮仅SDK诊断新入口、宿主debug/实际渲染接线及直接依赖验证；按所有者最新规则
  不运行完整SDK或App全功能回归，不操作真机安装/签名或改变设备环境矩阵。

## Actual verification and closure

- SwiftPM定向 **3 tests / 0 failures / 0 skips**：新入口保持478点索引顺序与top-left
  坐标；description/Mirror只显示名称/计数；无脸/错误为空、reset后恢复，非法透明
  输入在provider调用前以既有typed invalidInput拒绝。没有运行完整SDK门禁。
- 实际宿主原生 **4 tests / 0 failures / 0 skips**（3 unit + 1 UI），独立解析xcresult
  result=Passed和4/4/0/0，不把筛选/编译成功当执行。固定授权生成肖像，原图/输出均
  478点、有限有界、重复相同；调试复检不改变实际渲染像素，无脸后恢复。
- 原持续鼻子用例的强断言保留：六工具各25/50/75/100四档像素不同、使用1脸、无
  缺点/cap警告，组合字段保留/重复一致。此次验证源是授权生成肖像，不重签原Vision
  旧图失败，也不授予六工具自然外观或人群泛化资格。
- 独立异步状态用例和真实App UI核对模型名MediaPipe 478、原图/当前478、图像/参数
  版本一致、切鼻翼保留前一字段、关闭debug清除面板。
- App主资源bundle恰有一个固定task，SHA-256匹配既有pin；测试插件另有SwiftPM
  资源副本且同哈希，不误当另接模型。依赖/target不变，post-archive边界通过。
- 早期设置失败不算通过：首轮unit类名筛选错误造成0执行，UI缺失原临时输入失败；
  恢复授权临时源并核对实际类名后重跑4项。新增SwiftPM测试初版类型推断编译失败，
  后续透明输入错误类别预期写错；修正构造/预期，生产admission和效果强断言未放宽。
- 复用同一已有iPhone15Pro/iOS17.5、UDID `2CE927C9-9303-4A9B-9C03-F28C42045186`、
  宿主稳定`.build`、字体/方向；独立claim/释放，无克隆/重置/真机操作。新增临时
  生成输入副本完成后删除，既有lab授权源与构建缓存保留。
- 同步SDK架构/设计/安全/可靠性/使用/前端/质量和宿主README/VALIDATION；旧Vision
  provider/分割失败保留。手机已安装二进制尚未更新或验证，需要用户重新运行新版App。

## References

- [SDK瞬时诊断入口](../../../BeautySDK/Sources/BeautySDK/BeautyOwnerLandmarkDetector.swift)
  与[定向契约测试](../../../BeautySDK/Tests/BeautyCoreTests/BeautyOwnerLandmarkDetectorTests.swift)。
- [使用契约](../../../PRODUCT_SENSE.md)、[安全边界](../../../SECURITY.md)、
  [现行质量范围](../../../QUALITY_SCORE.md)。实际宿主源码/原生结果在外部BeautyEditorApp，
  不把App、私有输入、原始点或完整child transcript复制进SDK记录。
