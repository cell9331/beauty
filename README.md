# BeautySDK

本仓库包含 Apple 平台本地美颜 SDK、所有者自用照片编辑器与集成检查入口。
使用 Swift 6；SDK 最低支持 iOS 17 / macOS 14，编辑器最低支持 iOS 17。
当前以本地源码开发和所有者授权输入为范围，不据此声明可对外分发源码、模型或图片。

## 从这里开始

| 目录 | 用途 |
| --- | --- |
| [BeautySDK/](BeautySDK/) | SwiftPM library；含 Core、Detection、Render、Effects、Resources 和公开 facade，以及模块测试。 |
| [BeautyEditorApp/](BeautyEditorApp/README.md) | SwiftUI 照片编辑宿主；产品流程、参数接线、输入隐私契约见其 README，实际验收与限制见 [VALIDATION.md](BeautyEditorApp/VALIDATION.md)。 |
| [IntegrationTests/](IntegrationTests/) | macOS 独立消费者 smoke 与 [MediaPipe iOS 原生集成入口](IntegrationTests/MediaPipeIOS/README.md)。 |
| [beauty-sdk-playbook/](beauty-sdk-playbook/README.md) | 架构、478 点索引及算法参考；其中设计骨架和建议阈值需要实测，不是当前实现或验收结果。 |
| `example-images/` | 本地参考图片；目录存在不代表图片可再分发。仅使用已获授权的输入。 |

日常入口是 `BeautyEditorApp/BeautyEditor.xcodeproj` 的 `BeautyEditor` scheme：

```bash
open BeautyEditorApp/BeautyEditor.xcodeproj
```

生成工程已在仓库内。宿主的 `project.yml`、`Package.swift` 和 Xcode 工程均依赖同仓库
`../BeautySDK`，消费者 smoke 依赖 `../../BeautySDK`；无需另找旧工作区。
SDK 的 iOS MediaPipe Tasks 1.1.0 二进制依赖由 SwiftPM 按固定 URL/checksum 解析，
首次解析需要网络；图片推理与编辑在本机执行。

## 最小检查入口

以下命令从仓库根目录执行。按本次改动选择必要检查，不默认全量测试。

```bash
# 宿主资源与当前 SDK 字段/cap 接线静态检查
python3 -B BeautyEditorApp/scripts/check-design-assets.py
python3 -B BeautyEditorApp/scripts/check-sdk-bindings.py

# macOS 独立 SwiftPM 消费者 smoke
swift run --package-path IntegrationTests/BeautySDKConsumer BeautySDKConsumer

# 定向单元测试示例：仅在改动眉部滑杆映射时选择这一组
swift test --package-path BeautySDK --filter BeautyEyebrowSliderTests
```

原生 iOS 检测、实际照片渲染、导出或界面交互应沿对应入口验证；静态检查、消费者 smoke
和参数映射测试不能互相替代。工具可选择、参数接通或像素发生变化，都不等于参考外观合格。
本页不记录本轮测试通过结论，具体执行范围以对应验证记录为准。

## 协作、缓存与设备

会话遵守全局工作约定及 [宿主 AGENTS.md](BeautyEditorApp/AGENTS.md)。Serena 服务按项目复用，
固定在本仓库；符号操作及服务排障按 [Serena 项目服务指南](/Users/yakangwang/.codex/guides/serena-project-service.md) 执行，不切换共享实例到其他项目。

复用各 package 的 `.build`，编辑器 Xcode 构建使用 `BeautyEditorApp/.build` 作为稳定 DerivedData，
不例行 clean 或清缓存；详见 [构建与磁盘管理](/Users/yakangwang/.codex/guides/ios-build-storage.md)。
需要模拟器时按 [共享模拟器池与测试范围](/Users/yakangwang/.codex/guides/ios-simulator-testing.md)
选择已有兼容空闲设备，每次一台，按 UDID 原子 claim 并及时释放。
无工具原生占用接口时使用 [claim CLI](/Users/yakangwang/.codex/tools/simulator-claim.py)，
状态目录为 `/Users/yakangwang/.codex/state/simulator-claims`；不新建、克隆或抢占设备。

## 输入、授权与文档边界

MediaPipe 模型与二进制来源、校验值和本地授权范围见
[ThirdParty/MediaPipe/README.md](BeautySDK/ThirdParty/MediaPipe/README.md)，
上游许可见 [LICENSE](BeautySDK/ThirdParty/MediaPipe/LICENSE)。依赖许可不自动授予照片授权。
照片、关键点及蒙版按宿主的本地输入/隐私契约处理；只使用有权本地使用的照片，
不将私人肖像、蒙版或关键点写入源码、资源包或持久日志。分享临时 PNG 在关闭分享后删除。

根目录历史 `docs/`、`scripts/`、`plans/` 已移除，旧文档中仍可能保留相应链接。
当前实现以源码、[宿主 README](BeautyEditorApp/README.md) 及 [VALIDATION](BeautyEditorApp/VALIDATION.md)
为准；保留的 `beauty-sdk-playbook/docs/` 是参考手册。不要根据失效链接恢复历史目录，
或把旧阶段验收扩大为当前版本、一般照片、完整区域保护或设备性能资格。
