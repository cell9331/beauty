# A-2026-10-09-mediapipe-landmarker-probe

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex / project owner |
| Started / Completed | 2026-10-09 |
| Source Request | 所有者：先下载 MediaPipe Face Landmarker，然后新建项目测试。 |
| Scope | 官方资源下载和独立 iOS 图片检测项目；生产 SDK / 算法未改。 |
| Verification Policy | 同一已有模拟器的实际正负例、478 点有限/有界、4×4 矩阵/表情输出、重复检测和错误路径。 |

## Authorization and isolation

本次所有者明确授权下载官方 Face Landmarker 模型及其 iOS 依赖并进行本地测试。
新工程、模型、媒体、构建缓存和原生测试结果全部在仓库外临时项目中；仓库只增加
计划/安全说明和本聚合记录。输入复用两个既有授权本地肖像，包含真人和生成图，
不改变它们的原始字节或授权范围。未采集、训练、转换或分发模型/图片。
未恢复 v1.25 的 EYE/SEG 终局目标，未提升美颜效果资格。

## Official assets and integrity

源码清单来源为 `google-ai-edge/mediapipe`，本次记录的公开源引用为
`76f1d78eb1c350f882536adfa84d248ad0c84a60`；保存清单的 SHA-256 为
`585c61417e9782dcd6f63914c004273c896127c135ed20135d82161c1a26cb19`。
依赖 URL/预期摘要来自该清单。模型固定为官方 `face_landmarker/float16/1`。

| Asset | Bytes | SHA-256 | Check |
| --- | ---: | --- | --- |
| `face_landmarker.task` | 3,758,596 | `64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff` | 固定来源/完整长度/ZIP CRC；MD5 与官方 ETag 一致；测试 bundle 字节摘要再次核对。 |
| `MediaPipeTasksCommon-1.1.0.xcframework.zip` | 4,945,185 | `d2194b929b91f0c866b2f8d65003e08c474f6c85e8ca7293511e9ff4a780aa68` | 官方清单 SHA-256、完整长度、ZIP CRC。 |
| `MediaPipeTaskGraphs-1.1.0.xcframework.zip` | 112,810,926 | `6e59def0a86dcf8b357d6dc4220c8f45a3704449e7c7734677f2db50671c7def` | 官方清单 SHA-256、完整长度、ZIP CRC。 |
| `MediaPipeTasksVision-1.1.0.xcframework.zip` | 524,284 | `d66d9929a28febdd52aba49b3336e1550e4526ab0b772c49321db05af5c7614e` | 官方清单 SHA-256、完整长度、ZIP CRC。 |

源码 LICENSE、BlazeFace Short Range / Face Mesh V2 / Blendshape V2 的官方模型卡
均已核对 Apache-2.0 声明；本地 PDF 实际解码分别为6/7/6页。模型卡完整长度分别
434,425 / 3,476,420 / 2,324,099 bytes。资源只供所有者本地使用。

首次整文件 HTTP 下载提前结束，原 ZIP/模型卡长度不足；不接受错误摘要。
分段补齐后重新检查完整长度、CRC 和官方摘要。最终依赖校验全部通过。
初次工程配置把图运行库目录写为 `MediaPipeTaskGraphs.xcframework`，构建失败且
无测试执行；按 ZIP 内实际 `MediaPipeTaskGraphs_library.xcframework` 修正后通过。
失败没有被记为模型结果或测试通过。

## Independent project

新建 UIKit iOS App `FaceLandmarkerLab` 和 hosted XCTest target，使用 XcodeGen
生成工程；直接链接官方 Common/Graphs/Vision 三个预编译组件，保留上游要求的
`-all_load` 图计算器注册与系统库。未改官方二进制，未接入原 SDK，未验证官方
SwiftPM 清单声明的其他 Tasks 组件或完整入口。

界面提供两个本地样本及系统照片选择器。显示图片上的478点和面数、矩阵数、
表情数、单次检测时间；原始点/矩阵只在内存中，不写入诊断。UI 输入统一为
正向不透明图并限制长边2048px；单元测试采用原始本地输入。
应用已实际打开，肖像点位叠加位置和统计显示已检查；未计入样本切换/照片导入
交互通过声明。未保存界面媒体到仓库或长期报告。

## Executed verification

环境：Xcode 26.6 (17F113)、arm64 iPhone 15 Pro / iOS 17.5、既有设备 UDID
`2CE927C9-9303-4A9B-9C03-F28C42045186`。查询进程/占用记录后复用，仅使用该设备，
未克隆、重置、新建设备或改变字体/方向。任务占用记录在收尾释放；设备保留。
工程只使用一个增量 DerivedData。

应用和测试的 Swift 接口检查通过；最终命令 `run-tests.sh` 调用同一 destination 的
`xcodebuild test CODE_SIGNING_ALLOWED=NO`，设置
`-parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1`。
原生结果实际为 **9 total / 9 passed / 0 failed / 0 skipped**，退出0；由
`xcresulttool get test-results summary` 独立提取计数。

| Test | Actual assertion/result |
| --- | --- |
| Pinned model | bundle 内模型长度/固定 SHA-256 一致。 |
| Authorized portrait 001 | 1脸、478点、1矩阵、52表情；点有限且x/y有界，矩阵4×4有限/可逆，表情有限/有界。 |
| Generated portrait 002 | 相同输出形状和有效性检查通过。 |
| Repeat twenty times | 同一 detector、同一输入，20次点/矩阵/表情最大绝对差异0；预先门槛1e-5。 |
| Extras disabled | 保持1脸/478点，矩阵和表情输出均为空。 |
| No-face / recovery | 灰色输入无脸且其他输出为空；随后正例恢复正常。 |
| Missing model | 初始化抛出错误。 |
| Corrupt model | 初始化抛出错误，临时损坏副本移除。 |
| Wrong running mode | 图片模式调用视频接口抛错，随后图片检测恢复正常。 |

重复正例的预热后纯检测中位 **6.55225 ms**，不包括模型初始化、UIImage→MPImage、
UI 归一化或绘制。此数值仅属于该模拟器/样本/设置；没有真机、端到端或实时性能资格。
报告只保留计数、固定标识、布尔结果、资产摘要及聚合差异/时间，无原始关键点、
矩阵、像素、私有输入路径或子进程原始记录。

两个历史归档验证、post-archive SDK-only boundary、示例图存储检查和
`git diff --check` 通过。SDK 源/测试/脚本未改，未重跑或重签全量1076/0/0。

## Remaining boundary

未测独立标注误差、姿态校准、遮挡/光照泛化、方向/镜像矩阵、视频/实时流、
物理设备、外部宿主接线或美颜算法效果。矩阵/关键点有效性不等于精度合格。
临时项目和有效模型/依赖/构建结果保留供所有者复用；更换检测层或合入 SDK 需
后续明确的实现范围和契约设计。本次无新的自动研发队列。

## Sources

- [Face Landmarker overview](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker)
- [iOS guide](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker/ios)
- [Pinned source manifest](https://github.com/google-ai-edge/mediapipe/blob/76f1d78eb1c350f882536adfa84d248ad0c84a60/Package.swift)
- [Source license](https://github.com/google-ai-edge/mediapipe/blob/76f1d78eb1c350f882536adfa84d248ad0c84a60/LICENSE)
- [Official model](https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task)
- [BlazeFace model card](https://storage.googleapis.com/mediapipe-assets/MediaPipe%20BlazeFace%20Model%20Card%20%28Short%20Range%29.pdf)
- [Face Mesh V2 model card](https://storage.googleapis.com/mediapipe-assets/Model%20Card%20MediaPipe%20Face%20Mesh%20V2.pdf)
- [Blendshape V2 model card](https://storage.googleapis.com/mediapipe-assets/Model%20Card%20Blendshape%20V2.pdf)
