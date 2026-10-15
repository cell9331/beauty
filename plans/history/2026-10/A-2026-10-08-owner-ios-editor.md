# C-2026-10-08-owner-ios-editor

| Field | Value |
| --- | --- |
| Completed | 2026-10-08 |
| Scope | 所有者新授权的独立 iOS 图像编辑宿主，连接现有 BeautySDK；核心导入/编辑/确认/分享/相册保存完成。 |
| Source Request | 查看 Figma `l4srrGA4qSkYGT09nuAxXz`，编写 iOS App 还原编辑页面并接通图片编辑逻辑。 |
| Location | 相邻 `BeautyEditorApp` 项目；App、UI tests、设计资源和宿主文档均在 SDK 仓库外。 |
| SDK Files | `VisionFaceDetector.swift` 单处模拟器计算兼容分支；`FRONTEND.md`、`RELIABILITY.md` 和计划导航记录。 |
| Build | 原生 Swift 6 / SwiftUI / iOS 17，复用固定 DerivedData，增量构建；未 clean、新建模拟器或下载 runtime。 |

## 实现与边界

Figma 的 12 个状态是同一页面的六分类与滚动位置。保留工具顺序、标签、精确 SVG、
滑轨、粉色选中、OFF/Pro/限免视觉、背景保护和底部确认栏。54 个位置中 53 个连接
51 个现有标量；两个别名成组同步，去脂无法启用，另两个没有工具设计的分类提示未开放。
原生图片等比显示而不强行裁成设计稿肖像；导入/撤销和确认后的保存栏补齐业务流程。

宿主 MainActor 状态机处理有界撤销、单次拖动合并、确认事务和异步版本拦截；独立 actor
拥有 BeautyEngine、CIContext 与内存 Vision mask。输入文件的实际读数受32 MiB限制，
单图/ImageIO/尺寸/RGB/方向及 SDK admission 继续检查。预览最长1600px，导出从原图
重新处理为 upright sRGB PNG，源 GPS、拍摄设备及原文件名不复制。系统 add-only 相册
和分享路径完成；照片、坐标、mask 和输入副本不进入 SDK 持久记录。

底部的 `safeAreaInset` 是内容与遮挡占位唯一负责层；面板白色装饰背景单独延伸到
容器底边。宿主 README 分别拥有产品、架构、输入/隐私和恢复契约，VALIDATION 拥有
运行截图、测试和平台声明。SDK 保持没有 App/UI targets，没有恢复归档或新增分发面。

## 实际验证

复用 iPhone 15 Pro / iOS17.5，UDID `2CE927C9-9303-4A9B-9C03-F28C42045186`，
393×852pt、既有字体、竖屏；所有 Xcode 测试显式指定该设备且关闭并行。
所有者的真实 iPhone13Pro被另一个任务占用，本次未抢占、安装、覆盖或清除任何真机数据。

| 执行 | 结果 | 资格边界 |
| --- | --- | --- |
| `scripts/run-no-skip-swiftpm.sh` | exit0；1076/0/0；9 opt-ins；archive/boundary/oracle等前置通过 | SDK完整工程回归，非外部发布/模型分发批准。 |
| 独立App基本原生tests | 20/0/0 |17个契约/状态/实际像素/布局测试与3个UI测试；包含八EXIF方向、P3、非opaque alpha、原尺寸导出、文件上限、失败恢复、过期输出与安全区。 |
| 原生肖像人脸tests | 2/0/0 |1张检测人脸，实际改变、重复一致；真实App滑杆、对比与截图。 |
| 扩充后的原生保存/UI路径 |1/0/0 |真实add-only权限、相册保存成功回执、系统分享、来源sheet、Files取消返回；模拟器中仅写入代码生成测试图。 |
|60 SVG资源审计|通过|来源节点、非空几何、尺寸/摘要、所有生产调用；临时Figma下载URL与肖像引用移除。 |
|同一renderer的macOS像素检查|通过|source SHA256 `ae25e9f0bb0e6ddb2353d7a9396f313a84772e3e8ca73164f3ffb51913af5706`；1199×1312；形变259587像素改变，重复相等、neutral identity、alpha、PNG逐像素round trip通过；已约定背景ROI0像素改变，未保护对照2624像素改变，保护后前景903636像素改变。 |

实际完整底边截图、UI点按/滚动、面板确认/返回、白色安全区连续性与真实滑块几何均检查。
没有编辑器文本输入，键盘路径不适用；未主动测试横屏、大字体、iPad、多设备或真机性能。
原始UI运行结果由外部宿主的ignored验证目录保管；本记录只保留聚合，不包含输入路径、
图像、坐标、mask或子进程完整transcripts。

## 失败保留与明确限制

原生默认Vision推理在本模拟器返回 `com.apple.Vision / 9`。直接比较默认和CPU计算后，
CPU检测1张脸；SDK仅在simulator条件分支按其支持的设备逐阶段选择CPU，原生真实形变恢复。
物理设备和macOS计算选择未变，没有新增public行为、模型或Metal代码。

系统人物分割在两张现有授权肖像上的fast/balanced/accurate最大置信字节为0/3/18，
阈值128的有效前景均为0。请求有结果不等于mask合格；现代CPU与legacy CPU尝试都未修复。
宿主保持occupancy admission与原始强背景正例，明确拒绝开启，不提供伪保护结果。
原正例失败、聚合诊断及其断言保留；iOS背景正例**未合格**，macOS背景通过不覆盖该失败。
因此这里的completed只签核心本地编辑宿主与上述通过范围，不签该模拟器背景保护正例。

早期关闭人脸检测、neutral导出方向未统一、外层identifier覆盖原生滑块及系统Cancel定位
失败均已修正并重新运行；SDK安全强度上限现在被准确提示而非误报编辑失败。
无效的legacy分割workaround已撤回。两个已结束的自动算法目标保持终局，不产生默认续作。

## 保留与后续

稳定DerivedData、SwiftPM编译缓存、最新有效结果和仍有诊断用途的失败材料保留。
只回收本任务的临时输入、下载URL元数据及一次性工作材料，不触碰SDK冻结输入/回执、
历史归档、Serena状态或其他任务模拟器。小尺寸UI展示图不作为像素验收输入。

本轮移除44,971 bytes的临时下载元数据；最终回收21个任务自有临时路径共19,319,243 bytes，
同卷可用空间由174,201,335,808增至174,221,053,952 bytes。原生App与构建缓存、
最新有效/待查失败结果和149,937-byte中性预览保留；只释放本任务的模拟器占用登记，
未关闭设备。App从模拟器主屏独立打开并实际显示编辑页，非测试运行器专有启动。

没有真机性能、温升、能耗、长稳、商业视觉质量或release readiness声明。
设备反馈和新算法范围仍需所有者另行明确；一般“继续”不重开已终局的两条自动分支。
