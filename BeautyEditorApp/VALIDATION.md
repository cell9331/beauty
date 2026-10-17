# 本地验证

## 2026-10-16 间距增幅与双侧眉峰

仅调整眉毛间距、眉头间距及共享数值界。源站点末端 `L*48/48` 与精确 `L` 可差一个 ULP，
Bernstein 系数裕量除以这个极窄区间会虚增导数界，导致左侧间距与眉峰被误限幅。
修复保留原裕量，并增加按真实 ramp 宽度计算的解析产品导数界；使用两种完整上界的较小值，
不合并近邻断点，也不放宽保护条件。两个水平间距使用面部坐标 `W=diag(1,2)` 的统一收缩证书，
组合在一个统一范数下复核，逆解仍检查真实像素残差。其他五项的幅度系数未改。

同一授权原图的 720×960 预览按左右分别测量，正向满档的实际核心响应为：

| 项目 | 修改前左／右 | 修改后左／右 |
| --- | --- | --- |
| 间距：眉头外移 | 约 0.35／4.05 px | 约 5.26／5.29 px |
| 眉头间距：眉头外移 | 约 3.87／4.11 px | 约 5.32／5.38 px |
| 眉峰：设计峰位上移 | 约 0.99／4.59 px | 约 4.45／4.59 px |

实际局部验证，ignored 证据根仍为 `../BeautySDK/.build/eyebrow-native/`：

- `spacing-peak-fixed-tests-r2.log`：眉部模型、连续 map、dense 几何 **42 项通过**，包括实际 ULP 邻接断点、独立 Jacobian 上界检查、非对称眉形的双侧响应、连续强度和 spacing＋peak 单侧失去源归属后的整对 spacing 回退。
- `spacing-peak-final.xcresult`：**1 项原生原图探针通过**，8 个直接场（3 项正负端点及 2 个组合）、CPU／实际 Metal 各 6 个端点、峰值重复与 neutral 恢复；实际应用两侧，眼鼻唇独立机械框和 alpha 变化计数均为 0。单项两侧间距均要求大于 5 px，峰值均大于 3.8 px、双侧幅度比大于 0.85。
- `spacing-peak-receipt.json` 保存前后标量回执。`git diff --check` 通过；没有保存新原图或逐点材料。

本轮开始复用 iPhone 15 Pro / iOS 17.5；后因它由其他项目占用，最终原图探针改用池中已有
iPhone 15 / iOS 17.5 / `194FB6B2-CD65-4197-8830-E7AA3DF611F8`，每个阶段只占用一台，
原子 claim 后及时释放，未新增或克隆设备。不是 SDK 全量回归；未安装真机或宣布参考方案拟合达标。

## 2026-10-16 眉毛七项完整入口与连续强度

补齐眉毛上下入口，七项统一使用 SDK helper；默认仍为粗细。SDK 改为先按每项满档预算
归一化、再检查组合总预算，避免单项中高档提前饱和。上下、粗细、长短、间距、眉头间距、
倾斜、眉峰均覆盖正负方向、精确归零、近零有效请求及旧预览诊断。

本地 ignored 证据位于 `../BeautySDK/.build/eyebrow-native/`。仅复用已有
iPhone 15 Pro / iOS 17.5 / `2CE927C9-9303-4A9B-9C03-F28C42045186`，竖屏、现有字体，
设备阶段原子 claim 后释放；增量复用既有 DerivedData，没有清理缓存或新增设备。

| 实际检查 | 结果与范围 |
| --- | --- |
| `all-seven-tests.log` | SDK 40 项定向测试通过，涵盖七项双侧正负逐档响应、连续场与梯度、源归属/成对拒绝、保护与后端计数。不是 SDK 全量回归。 |
| `all-seven-native-r2.xcresult` | 1 个原生原图探针通过：一次 fresh 478 点检测，14 个单项端点及 2 个粗细/长短组合分别走 CPU 和实际 Metal；56 个直接场逐档响应检查；七项 direct/CPU/Metal 的满档→0→微量序列通过。眼/鼻/唇独立机械框及 alpha 变化计数均为 0，重复结果精确。 |
| `all-seven-editor.xcresult` | 11 个宿主单测通过：6 个会话方法逐项覆盖七眉工具，另 5 个绑定、方向、库存、符号与历史方法。该轮 UI 因错误假设原生 AX 调到 .5 必然精确为 0 而失败；实测为 −3，原失败保留。 |
| `all-seven-editor-ui-r2.xcresult` | 修正 UI 测试为读取真实值并有限闭环微调后，仅复跑对应 UI，1 项通过；实际横滚到末项、七项选择、上下正负/归零、撤销重做、粗细独立保留及底部确认点击通过。生产滑杆未因 AX 近似而改动。 |
| 截图与静态 | `all-seven-ui-screenshots/` 保留 3 张全容器截图，实际查看上下零位与末项眉峰：白背景连续至底边，按钮避让 Home Indicator；绑定 58 字段、60 设计资产/60 工具位置/6 个系统符号及 diff 检查通过。 |

同一原图 720×960 预览的单项满档核心实际最大位移：上下约 2.94 px、长短约 3.64–4.19 px、
间距约 4.10 px、眉头间距约 4.11 px、眉峰约 4.09–4.58 px；粗细平均厚度约 ±23%，
倾斜两眉平均角度约 ±3.48°。这些是候选实现的本图测量，不是七份参考方案拟合达标结论。
首轮原图探针仅因把单项字段数 1 错写为组合字段数 2 失败；修正测试计数后重跑上述原图探针通过，
实际应用侧数始终独立要求为 2。未运行全功能回归、扩展环境矩阵或真机安装。

## 2026-10-16 Demo滑杆松手console日志

所有者授权为每个可调工具增加松手日志。真实touch-up与cancel/非touch收尾分开，
同一手势只输出一次，保留最终浮点值、历史合并和release flush；换工具/禁用后丢弃旧手势，
四个UI闭包按捕获toolID校验，防止SwiftUI刷新前旧触摸串到新工具。
15字段固定白名单JSON仅打印stdout，不含图片/路径/关键点/蒙版/错误文本，不改SDK日志或算法。

复用已有 **iPhone15Pro/iOS17.5/2CE927C9-9303-4A9B-9C03-F28C42045186**，
现有字体/竖屏；稳定`.build`增量build-for-testing两次均成功，无clean。每次设备阶段由共享
claim CLI原子领取并释放；单destination、parallel-testing NO、maximum并发destination 1。
仅按真实方法名筛选test-without-building，本地ignored证据根为`.verification/slider-release-logging/`。

| 实际证据 | 结果与范围 |
| --- | --- |
| `native.xcresult` | **7通过/1失败/0跳过**：4个日志model方法通过，覆盖52个可调工具149次release的字段/数值/正负范围/cap/15键白名单/JSON/ISO时间、最终值/单undo、静默边界及preview pending/flush；2个事件桥方法和六分类真实UI通过。取消/AX桥方法错误假设离屏legacy UISlider的系统accessibility方法必发valueChanged，实际2 !>2；原失败保留。 |
| 首轮后的修正 | 非touch `.valueChanged` 仍严格验证静默收尾与零release；只有自定义reference AX方法断言会发事件，不改系统AX生产行为。同时根据独立review补齐旧手势丢弃和捕获toolID校验，避免修改/误报新工具。日志model未再改，不重复其已通过4方法。 |
| `native-final.xcresult` | **5/0/0**：4个原生事件/整合方法（inside/outside、去重、cancel/AX、换ID/禁用/移除、默认console logger与单步undo）+六分类实际拖动/端点/undo/redo/末项/确认恢复取消及底部白背景UI；独立xcresult摘要一致。 |
| 默认stdout核对 | host unit整合方法通过生产默认`print`输出**2条**：reference脸宽和legacy嘴大小；独立解析前缀、真实工具ID、最终值与精确15字段通过。此处不是把注入sink冒充真实stdout，也不声称已从UI测试子App捕获6条stdout。 |
| 静态与截图 | bindings/diff检查通过；保存六分类全容器截图，实际查看本轮脸/眉截图，白色滑杆与底部避让保持。未新加产品UI或日志展示面板。 |

本轮9个不同相关方法分别通过（首轮4 model +末轮5），不称为一次9/0/0或全App/SDK回归。
控件外抬手路径仅以UIControl事件方法验证，六分类UI使用正常内部拖动；未执行物理VoiceOver、
扩展字体/方向/设备矩阵、真机安装、Release独立执行或图片效果新验收。

## 2026-10-16 同仓库当前 SDK 与白色滑杆

三个依赖入口（project.yml、生成工程、Package.swift）均固定同仓库 `../BeautySDK`，
本次直接增量构建当前源码。六个眉工具改用当前 SDK helper：眉峰 signed，倾斜右侧
外端向下；尖下巴 setter 去掉旧版本兼容分支，统一当前 helper。工具仍59个、可用52个、
canonical字段57个，停用资格及 SDK 算法未改。

所有滑杆白底、浅灰轨、白圆配浅灰边和轻阴影；脸/眼 reference 的粉色段从真实零点延伸，
其他原生滑杆双灰轨。原生 track 使用 original 可伸缩图，避免 SwiftUI 环境 tint 恢复系统蓝。
保留44pt触摸区、signed/unit范围、点按/连续拖动、历史和唯一底部safeAreaInset。

仅复用已有 **iPhone15Pro / iOS17.5 / 2CE927C9-9303-4A9B-9C03-F28C42045186**，
现有字体/竖屏。迁入后的本路径沿用`.build`为稳定DerivedData，保留`.build/index-build`
SwiftPM缓存，无clean。每段设备操作由共享claim CLI原子占用，固定单destination、
`-parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1`，全部已释放。
构建使用`build-for-testing CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES`，
执行用`test-without-building`并按下表方法筛选。

| 实际检查点（本地 ignored `.verification/sdk-white-sliders/`） | 结果与范围 |
| --- | --- |
| `native.xcresult` | **17/0/0**：5个参数契约（含两项新眉部/历史）、4个生产renderer像素/neutral/prepared/原尺寸PNG导出、4个面板、4个真实UI方法。初次截图仍发现原生灰轨被染蓝；该checkpoint不作为最终配色通过。 |
| `native-light-track.xcresult` | original灰轨生产修正后 **4通过/1失败/0跳过**：四面板通过，六分类UI新轨道像素断言失败，单行midline读白色（距灰色目标22）。失败保留；随后采样在accessibility中线±2pt寻找2pt原生轨，每通道RGB容差仍6，不允许蓝色通过。 |
| `native-light-track-recheck.xcresult` | 只复验受影响六分类方法，**1/0/0**，57.302s；六分类首项两端、真实连续拖动、undo/redo、末项可达与选择、白底/双灰轨/底边像素、确认/继续和取消/放弃通过。独立xcresult摘要一致。 |
| 静态与构建 | 当前源码增量build-for-testing通过；57字段/cap及三依赖路径检查、60设计资产/59工具图标位置检查、`git diff --check`通过。 |

本轮共17个不同相关方法分别通过，末轮仅重跑实际受影响UI，不把它写成最终一次17/0/0。
已查看`final-screenshots/`的六张全容器原生截图：各分类均白底白圆浅灰轨，无蓝色或黑色
滑杆块；底部白背景连续，Home Indicator和按钮安全区正常，末项与必要操作可达。
截图中的平面色块是临时代码生成无脸输入，提示与原图保留符合既有契约。

本次未执行完整SDK/App回归、字体/方向/设备矩阵、真人/生成肖像效果新验收或真机安装。
现有眉部保护与其他参考效果未达标范围仍由SDK现行记录拥有，本次接线/UI不重签效果资格。

## 2026-10-10 固定原图连续编辑

借鉴连续处理中的固定输入复用：预览按照片和CPU/Metal engine准备不可变原图，
按检测用途复用有效结果；参数、网格、像素和背景合成逐次从原图计算。
换图清除token，导出重新解码原尺寸并走普通fresh检测。未新增视频/摄像头、
时序跟踪或效果；未开发分类及去脂仍置灰禁用。

| 本次证据 | 实际结果 |
| --- | --- |
| SDK定向 | **65个不同测试 / 0 failures / 0 skips**，含9个新prepared测试与实际Metal；生命周期、不可变副本、用途/栅格隔离、失败重试、原图独立像素、方向/镜像/P3/alpha/蒙版及直接facade/local/encoded/cadence调用。不是完整SDK回归。 |
| macOS生产renderer | `.verification/prepared-editing-macos.json`：六鼻子工具×四档、CPU/Metal通道最大差<=1、重复一致、既有值保留、debug像素无影响、alpha CPU fallback、neutral及原尺寸sRGB PNG/no GPS通过。不是原生iOS或性能证据。 |
| 原生编译 | 复用稳定`.build`，`build-for-testing`成功；等待其他项目释放后复用相同源码/二进制`test-without-building`，一个固定destination、关闭parallel，无设备克隆。 |
| 原生执行 | `prepared-editing-20261010.xcresult`：**13/0/0**（9pipeline+3session+1UI），独立解析汇总一致。真实MediaPipe单脸478点，四个参数快照的prepared/fresh输出逐像素完全一致，正例变化、返回首值、换图重检、no-face复用及原尺寸fresh导出通过；连续拖动/最新请求/旧结果拦截和实际UI debug/鼻翼/既有值保留通过。聚合回执`.verification/prepared-editing-native.json`。 |

原生执行于10:26:40领取已释放的设备，10:27:13归还占用记录，保留设备/App数据。
本轮只使用既有iPhone15Pro/iOS17.5、现有字体/方向与UDID
`2CE927C9-9303-4A9B-9C03-F28C42045186`。没有全App/全设备回归、
真实iPhone安装或帧率/温升/耗电声明。既有失败和限制保留在下方原记录。

## 2026-10-09 独立组合与置灰入口

取消旧总和1.0的宿主滑块余额截停及组合额度提示；SDK fresh dense字段保留独立cap，
由最终实际位移/梯度/姿态保护。九个源像素相关/平移字段与legacy仍保留保守预算。
未开发分类及去脂保留置灰禁用，直接model调用和实际点击无提示、无选择/参数变化。
同一已有iPhone15Pro/iOS17.5、现有字体/方向、稳定`.build`，仅相关用例。

| 本次证据 | 实际结果 |
| --- | --- |
| SDK定向 | **25 tests / 0 failures / 0 skips**，四新组合、七网格、十四legacy冲突；独立值/方向、源预算、fresh条件、实际像素/边缘/alpha/重复、正面积及位移/梯度界。不是完整SDK回归。 |
| 宿主首轮 | `combination-ui-20261009.xcresult`：12项中11通过/1失败/0跳过，10 unit全部通过，满档组合UI通过；禁用入口UI已验证点击无alert，但测试错误读取不存在提示元素的label。原失败保留。 |
| 禁用入口重验 | `combination-ui-20261009-disabled-r2.xcresult`：**1/0/0**。直接断言提示不存在；两分类及去脂实际禁用语义、点击、置灰截图。 |
| 最终fresh代码复核 | `combination-ui-20261009-fresh-final.xcresult`：真实MediaPipe满档组合像素单项 **1/0/0**，为已执行用例重验，不增加不同用例总数。 |
| 最终覆盖 | **12个不同相关用例最终通过**（10 unit + 2 UI），三份xcresult独立解析；汇总见 `.verification/combination-ui-current.json`。不能把首轮失败bundle称为12/0/0。 |
| 组合/接线 | 51 canonical字段/cap与SDK一致，别名同步；脸宽/内眼角/鼻翼/反向嘴宽均保留满档请求，前字段/撤销/事务不变；依次加入每字段实际输出不同，重复一致、alpha/尺寸保持，最终复检478点；六鼻子四档相关回归通过。 |
| 底部面板 | 实际查看编辑/确认/恢复及禁用分类/眼部5张生成输入全容器截图；单safeAreaInset、184pt面板、44pt控制区域、内容避让与白背景贴底断言通过。临时提取副本检查后清理。 |
| 辅助编译/静态检查 | 既有macOS PixelCheck增量编译通过，失效setter调用为零，51绑定检查通过；macOS仍是legacy组合，不把其合法降幅警告改写成dense失败。 |

SDK早期新增测试的初始化方式、小脸cap输入及stale脸型保留字段/跳过域的预期已修正；
没有降低cap或生产安全阈值。实际网格超界仍可以共同减弱，保留请求值不等于足量输出。
无脸/缺点/真正处理失败继续说明。debug显示实际模型与组合项数，不再把参数总和称为容量。
“整体”只读，Pro/限免仍是参考标识；后续候选已登记，未开发入口不假装完成。
本次未跑App全功能/SDK全量、扩展设备矩阵或安装手机；旧provider/人物分割失败保留。

## 2026-10-09 MediaPipe 实际宿主与478点调试修复

SDK iOS渲染早已切换，但宿主调试仍独立调用Vision且标签写死；现改为SDK的
`OwnerDiagnostics`生产adapter入口，不复制模型或另建MediaPipe包装。
继续复用同一iPhone15Pro/iOS17.5、UDID `2CE927C9-9303-4A9B-9C03-F28C42045186`、
现有字体/方向和稳定`.build`；只执行直接受影响的3项unit + 1项UI，未跑App全功能或SDK全量。

| 检查 | 本轮实际结果 |
| --- | --- |
| 原生相关门禁 | `.verification/mediapipe-debug-20261009-r2.xcresult`：**4 tests / 0 failures / 0 skips**，独立解析xcresult摘要；固定授权生成肖像。 |
| 实际模型/调试 | 原图和渲染输出各478点，实际名称MediaPipe 478；有限、有界、原生重复相同，无脸为空后恢复；开启复检不改变相同参数的输出字节。 |
| 连续鼻子/组合 | 原持续用例的强断言保留：六工具各25/50/75/100四档不同、使用1脸、无缺点/cap警告，累积字段保留，重复输出一致；此次输入为固定授权生成肖像，不能覆盖历史Vision同图失败。 |
| 异步与UI | 旧worker不覆盖最终版本；真实App调试面板显示MediaPipe 478且原图/当前均478点，切鼻翼保留前一字段，关闭debug清除面板。 |
| SDK新诊断入口 | 独立SwiftPM定向**3/0/0**：索引/坐标不翻转、反射脱敏、无脸/失败不借旧点、reset及非法输入前置拒绝/恢复。不是完整SDK回归。 |

早期设置失败保留：首轮unit筛选误用不存在的类导致0执行，UI因已清理的临时输入缺失失败，
不算通过；恢复授权临时输入并核对实际类名后重跑4项。SDK新测试最初类型推断编译失败、
透明输入错误类别预期与既有canonicalizer不符，修正测试构造/预期，生产判据未放宽。
本轮没有手机安装或签名变更；用户截图里的手机二进制需重新运行新构建才能更新。
系统Vision人物分割、历史背景正例失败及真机性能限制保留；原始图片/点不进入持久报告。

下文是旧provider/旧构建的执行记录，不作为本次MediaPipe失败或重新执行的结论。

## 2026-10-09 控件与关键点调试修复

仍复用下文记录的同一 iPhone 15 Pro / iOS 17.5、竖屏和字体，先等待其他项目的占用结束。
没有改动 SDK 生产代码、模型、预算或效果资格；没有真机安装、签名变更或设备性能声明。

| 检查 | 实际结果 |
| --- | --- |
| 接线与范围 | `check-sdk-bindings.py`：53 个可用位置、51 个字段及 cap 与当前 SDK 一致，总形变阈值 1.0 一致；共享别名只计一次。60 SVG / 54 图标资源检查也通过。 |
| 原图接线诊断 | `--audit`：该输入 53 个位置中 45 个改变像素；8 个条件不满足的工具无变化。像素变化只验证可达性，不签发自然外观或算法资格。 |
| 六个鼻子工具 | macOS 生产 renderer `--verify-controls`：每个工具 25/50/75/100 四档均与上一档不同，检测 1 张脸，无缺点/cap 警告；重复 100 档像素完全相同。CPU/Metal 最大字节差 ≤1，山根使用 CPU。 |
| 累积效果 | 原始五工具 71 档序列会将全部形变乘以约 0.5556；修复后旧字段逐个精确保留，只限制当前字段到剩余总预算，SDK 不再发 `combined_geometry_weakened`。预算用尽会明确提示。 |
| macOS 复检/导出/alpha | `.verification/controls-verified-final.json`：原图/输出各 87 个聚合点，调试检测不改变像素，neutral identity、1122×1402 原尺寸 sRGB PNG 逐像素 round trip、无源 GPS；透明 Display P3 输入转 sRGB 后回退 CPU，与参考像素及 alpha 完全一致。交互预览为 768×960。 |
| 原生业务回归 | `.verification/editor-debug-behavior-final.xcresult`：24 tests / 0 failures / 0 skips（23 unit + 1 UI），包含字段范围、预算/别名、持续拖动显示完成帧、最终版本、调试异步隔离、导入、色彩/alpha、方向、失败恢复与原尺寸导出。 |
| 额外 UI 复核 | `.verification/editor-debug-visual-final.xcresult`：1 / 0 / 0。等待图像与参数版本相同，实际切鼻翼、保留脸宽、关 debug 清除面板。临时截图仅用于检查后删除，不作为长期真人/关键点附件。 |
| 布局截图 | 已看真实宿主的编辑、确认导出、返回编辑三张生成图截图；白色面板背景贴底，内容避让，单一 safeAreaInset 几何断言通过。真人调试截图验证叠加和版本显示；其中复检点漂移属于下列检测失败，不能算关键点视觉准确性通过。 |
| **iOS 持续鼻子正例** | **未通过**。`editor-debug-regression-r3.xcresult` 中 21 unit 里 20 通过、1 项有 39 个断言失败，全部来自持续鼻子正例；同次 UI 1 / 0。初始鼻子档位有效，后续检测退化为 `.partial / mappingFailed`，相关效果安全跳过。失败回执保留，测试判据不降低。 |
| 独立 Vision 诊断 | 不经过 SDK 的同一原图连续请求也复现：rev3 第 9 次有 4 个图像归一化点越界，第 12 次 76 个全部越界；原图实际像素未变。rev2、legacy CPU、新建独立 CGContext 输入均没有消除退化。只记录计数，不记录坐标。显式选择其宣告可用的 GPU 则立即返回 Vision code 9，不能作为替代。临时诊断测试已移除。此为平台相关的可复现异常，Apple 内部原因未定位，不能归咎于控件调用或归一化投影。 |
| 背景保护 / 真机 | 原 iOS 17.5 背景保护正例失败继续单列；本轮 no-person 拒绝测试通过不能覆盖正例。没有真实 iPhone 连续检测/速度证据。 |

修复的生产行为：滑块映射各自安全 cap；总预算优先保留旧字段；一个运行中的渲染加一个
最新候选替代反复取消防抖；960 px 交互预览与原尺寸导出分开；已有 SDK Metal 在适用输入
使用并允许 typed CPU 回退。debug 用青圈原图/黄点当前，按实际 aspect-fit 位置投影，
缓存原图点、每个已接受预览复检，单独显示图像/参数版本及检测原因。点只在内存中，
不写进导出图。检测输出异常会显示出来，debug 不保证 Vision 推断本身正确。

早期失败保持可追溯：`editor-debug-regression.xcresult` 是同步 actor 方法/async protocol
默认实现选择问题与持续 Vision 失败的初次结果；`editor-debug-regression-r2` 是测试 helper
作用域编译错误；均已修正对应宿主代码。r3 的平台持续检测失败没有被这些修正解决。
随后业务回归明确限定通过范围，不包含失败的持续鼻子或背景保护正例。

macOS 的 Debug 诊断中位耗时从旧 CPU 原尺寸约 124 ms 变为当前适用 Metal 预览约 42 ms，
分辨率和后端都变了，含首次初始化差异；这只是定位记录，不是公平基准或 iPhone 性能结果。
SDK 全量 1076 / 0 / 0 是下文前次实际执行的结果，本轮 SDK 源未变，没有重复签发。

额外复现项选择 `PhotoPipelineTests/testOwnerPortraitNoseRangeCompositionAndDebugReDetection`，
编译 `-DBEAUTY_OWNER_PORTRAIT_CHECK` 并临时提供有权本地使用的输入；当前模拟器会明确报错。
macOS 的 `--verify-controls` 在本轮输入通过；默认无标志 helper 仍使用前次约定的背景 ROI，
换输入不能直接复用该 ROI 判据。

## 2026-10-08 初次宿主验证

复用已有 **iPhone 15 Pro / iOS 17.5**，UDID
`2CE927C9-9303-4A9B-9C03-F28C42045186`。原生窗口 393×852 pt，竖屏、既有默认字体。
所有 Xcode 测试显式指定该设备，`-parallel-testing-enabled NO`，无克隆、无新设备、无 runtime 下载。
Xcode DerivedData 固定 `.build`；macOS 像素辅助程序固定 `.build/pixel-check`。

| 检查 | 结果与边界 |
| --- | --- |
| Figma 资源 | 60 SVG / 54 工具图标，尺寸、非空几何、SHA-256、生产调用关系通过。运行时远程 URL 为零。 |
| 原生肖像编辑 | `portrait-face-verified.xcresult`：2 tests / 0 failures / 0 skips。真实 SDK 识别 1 张脸，实际像素改变、重复相等；真实 App 滑杆、按住对比与松手复原，生成肖像截图。 |
| 基本编辑/导入/导出/布局 | `basic-editor-bounded-final.xcresult`：20 tests / 0 failures / 0 skips（17 unit + 3 UI）；全部实际像素/元数据、状态、布局与业务检查通过。 |
| 原生系统相册保存 | `native-save-final.xcresult`：1 test / 0 failures / 0 skips，实际 add-only 授权及保存成功；模拟器中新增一张代码生成测试图，未操作既有照片。 |
| 测试运行器之外打开 | 通过：从本台模拟器主屏点按 App，原生编辑页正常显示；最终小尺寸截图为中性预览。 |
| SDK 回归 | 归档优先完整 `scripts/run-no-skip-swiftpm.sh`：退出 0，1076 tests / 0 failures / 0 skips，9 opt-ins，全部归档、边界、CPU oracle 等前置检查通过。 |
| macOS 实际肖像像素 | 同一生产 renderer 的 neutral identity、瘦脸变化/重复、alpha、背景已约定 ROI 不变、前景改变、原尺寸 PNG 逐像素 round trip 通过。见 ignored `.verification/pixel-check.json` 聚合回执。 |
| **iOS 背景保护正例** | **失败，未资格通过**。`validation-r3`、`validation-r4`、`portrait-r5` 保留失败。两张已有授权肖像均未获得有效人物 mask；fast/balanced/accurate 的 CPU 诊断最大置信字节分别为 0/3/18，阈值 128 的前景占用均为 0。App 拒绝开启，不输出伪保护结果。 |
| 真机 | 未执行；用户 iPhone 13 Pro 被其他任务占用，本次未抢占、替换应用或改动数据。没有设备性能、温升、能耗和长稳声明。 |

早期失败及修正：SDK 原有 Vision 默认计算路径在此模拟器报 `com.apple.Vision / 9`，
使用其支持的 CPU 后，原生人脸检测与形变恢复。只在 simulator 条件编译中改变检测计算选择，
物理设备与 macOS 保留默认选择，没有 public API 或新模型。背景分割的 CPU/legacy CPU 尝试
没有修复空蒙版，未降低 occupancy admission，已去除无效的 legacy workaround。

其他已修正失败：初版关闭人脸检测、neutral 导出未统一 EXIF 方向、父层 identifier 覆盖原生滑块，
以及中文/英文系统 Cancel 定位；修正后重新生成测试结果。SDK 安全强度上限现在说明“效果仍已应用”，
不被误报为编辑失败。失败替换输入/开启背景保护之后会恢复尚未完成的预览。

原生布局与交互清单：

| 适用项 | 状态 |
| --- | --- |
| 编辑底栏白色背景覆盖容器底边，Home Indicator 下无黑色缝隙 | 通过：运行截图与实际底部像素抽样。 |
| 184 pt 内容只由 safeAreaInset 占位，44 pt 滑块避让实际 safe-area bottom | 通过：UIHostingController 中真实窗口/滑块几何断言。 |
| 编辑 → 确认导出 → 继续编辑，取消恢复最近确认参数 | 通过：状态测试、宿主截图、UI 实际点按。 |
| 工具分类切换，脸型滚到最后发际线可点，眉/鼻/眼/比例/嘴工具状态 | 通过：UI 实际滚动/点按及截图。 |
| 撤销/重做、一次拖动合并、异步过期结果拦截 | 通过：状态测试与 UI 实际滑动。 |
| PhotosPicker 打开/取消、系统分享打开/关闭 | 通过：原生 UI 测试与截图。 |
| 更换照片的来源 sheet → 系统 Files → 取消后返回 | 通过：原生 UI 实际打开、点按与返回截图。 |
| 键盘显示/收起 | 不适用：编辑器没有文本输入；系统文件选择走正常浏览，不测试搜索输入。 |
| 横屏、大字体、多设备、iPad、物理设备 UI | 未执行，默认单设备范围之外。 |

完整容器截图与失败诊断保存在 ignored `.verification/*.xcresult`，不进入 SDK 证据。
最终展示预览为 metadata-stripped JPEG、长边 ≤1600、≤512 KiB；不是像素验收原图。
验收输入只临时提供，不随 App 打包；SDK 记录只保留来源摘要、聚合计数与结论。

默认运行：

```bash
xcodebuild -project BeautyEditor.xcodeproj -scheme BeautyEditor -configuration Debug \
  -destination 'platform=iOS Simulator,id=2CE927C9-9303-4A9B-9C03-F28C42045186' \
  -derivedDataPath .build -parallel-testing-enabled NO \
  -maximum-concurrent-test-simulator-destinations 1 \
  -resultBundlePath .verification/basic-editor-bounded-final.xcresult test CODE_SIGNING_ALLOWED=NO
```

所有者额外的原生人脸正例选择
`PhotoPipelineTests/testOwnerPortraitFaceEditingChangesPixelsAndRepeats` 与
`EditorUITests/testOwnerPortraitEditorAndComparePreview`，编译开启
`-DBEAUTY_OWNER_PORTRAIT_CHECK`。同组中原始的强背景正例
`testOwnerPortraitChangesFacePixelsAndPreservesBackground` 原判据保留：在本台模拟器依然失败，
不属于基本编辑通过声明；更完整的保护通过只能由该正例实际成功得出。

这是所有者本地编辑宿主的验证记录，不是所有控制效果、商业视觉质量、外部分发或发布 readiness。

## 2026-10-10 鼻部双向与预览响应

本轮20个不同相关原生用例最终通过，0失败/0跳过：ControlContractTests 5、
EditorSessionTests 11、PhotoPipelineTests 3、EditorUITests 1。同一既有 iPhone 15 Pro
/iOS17.5/UDID 2CE927C9-9303-4A9B-9C03-F28C42045186，原有字体/竖屏，
关闭并行，复用 `.build`。无全App回归、字体/方向矩阵或真实手机安装。

- 首轮19个unit/pipeline通过；UI直接tap越界分类误点确认，失败结果保留。
  显式滚动分类后，六工具两侧值、撤销按钮和底部安全区交互通过。
- FakeRenderer验证两秒待启动限频仍被松手立即flush、最新pending替换、连续显示、
  最终版本及旧worker隔离、一步撤销/导出；调试在拖动期间暂停、松手后只检测最终输出。
- 实际PhotoRenderer六鼻部各±25/50/75/100，共48输出，478点、固定原图、warning、
  组合重复、prepared/fresh逐字节一致、原尺寸去元数据导出通过；最终单项补验输出尺寸、sRGB与alpha。
- 初版48次SDK+实例化耗时median308.0ms；仅采样有位移单元后124.9ms，
  最后元数据复验103.9ms。Debug模拟器范围，不含排队/额外debug检测，不是25fps或真机性能承诺。

Native receipts (ignored):
`.verification/nose-signed-preview-20261010.xcresult`（19通过+1UI失败）；
`.verification/nose-signed-preview-final-20261010.xcresult`（3pipeline+1UI通过）；
`.verification/nose-metadata-final-20261010.xcresult`（最终鼻部pipeline1通过）。
长边≤1600、去元数据UI预览：`.verification/previews/nose-positive.jpg`、
`.verification/previews/nose-negative.jpg`；检查了中心零标、±82状态、44pt控件和白色背景贴底。

SDK不同定向85/0/0（含强制CPU/Metal parity）；完整实现/失败/保护域见相邻
`beauty/plans/history/2026-10/A-2026-10-10-nose-signed-preview.md`。
生成像素方向/幅度成立，不等于美图秀秀外观、全照片可见强度、3D高度或鼻部光影合格。
原iOS17.5背景分割正例失败记录保持；本轮不修复/重跑该无关路线。

## 2026-10-11 嘴部滑杆与实际像素定向验收

八项几何控件居中双向，白牙保持单向；统一使用 `BeautyMouthSlider` 处理范围、
大小/上下反向和撤销反算。九项安全cap未提高，未改布局、图片输入或预览调度。

复用既有 **iPhone 15 Pro / iOS 17.5 / 2CE927C9-9303-4A9B-9C03-F28C42045186**、
现有字体/竖屏及稳定 `.build`，等待眼部任务释放后登记独占，关闭并行；
未新建、克隆、重置设备，未执行真机安装或全量回归。测试结束已释放设备 claim。

首轮算法校准及 UI 测试修正后，**10个不同相关用例通过**（下方新算法重验单独记录）：

- `MouthControlContractTests` 3项：九项清单、正负四档/零位、SDK方向、Codable保留、
  其他字段不变及历史恢复。直接SDK仍正向放大/下移，宿主右端缩小/上移。
- `ControlContractTests` 3项：所有字段独立绑定、历史分组/redo失效、
  独立范围及别名的直接受影响路径。
- `MouthPortraitAcceptanceTests` 3项：两张所有者实际输入各16个几何端点，
  另有已知有符号位移的独立像素配准oracle校准。实际MediaPipe 478检测和720×960输出，
  32/32端点方向通过；固定源鼻部及完整眼区、嘴部外区改变均为0像素，
  32/32重复逐字节相同、alpha保持，sRGB/尺寸、neutral identity/恢复及源图未改通过。
  原图不打包或提交；像素、关键点及原尺寸结果只进入内存或本轮临时目录。
- `MouthUITests` 1项：实际选择八工具、正负拖动及数值、逐项归零、横滚末项、
  白牙单向范围与撤销可达通过。使用临时生成色块输入，截图中的无脸提示符合预期。

回执独立解析：`.verification/mouth-native-r1.xcresult` 为 **9通过/1 UI失败/0跳过**；
首轮测试在重置菜单收起期间把暂时不可点击误判为需向左滚动，随后目标移出可视区。
仅修正测试为按实际frame滚动并等待菜单消失，
`.verification/mouth-ui-r2.xcresult` 为 **1通过/0失败/0跳过**；未重复运行已通过的9项。
两份原生回执均保留，不能把首轮bundle称为全通过。
聚合像素回执：`.verification/mouth-native-r1-aggregate-a.json` 与
`.verification/mouth-native-r1-aggregate-b.json`，只含汇总指标，不含私有路径/关键点/像素。

已实际查看通过回执的 `mouth-negative-generated-input` 与 `mouth-positive-generated-input`
完整容器截图：微笑数值−86/+82、中心刻度、可见滑杆与末项控件正确；
白背景覆盖底边，取消/完成按钮及内容避开底部安全区。
静态绑定检查56个canonical字段/cap与SDK一致；Swift语法及Xcode工程plist检查通过。
本轮支持指定样本的方向、保护和宿主接线，不证明与美图秀秀外观完全一致、
白牙算法资格或真机性能；原背景分割正例失败记录保持。


薄唇及实际照片校准后的候选 v5 单独增量 `build-for-testing` 成功，再使用刚生成的
`.xctestrun` 重验上述两照片用例；不是重复使用旧二进制。复用同一 iPhone 15 Pro / iOS 17.5，
鼻部任务明确释放设备和宿主 `.build` 后，通过按 UDID 的排他文件锁登记本任务 claim，
关闭并行；两个用例执行结束即释放自己的 claim，保留模拟器状态与缓存。
`.verification/mouth-native-visibility-r2.xcresult` 独立解析为 **1通过/1失败/0跳过**。
第一照片 16/16 端点方向通过，第二照片 15/16；第二照片 M 唇 +100 的独立纹理配准方向
为 −0.561683 preview px，未满足正向 >0.02 px 的既有要求；该轮失败回执保留，
独立像素与测量控制复核见下方 r3。r2 当时未修改方向 oracle、阈值或保护边界来接受该失败。

这次两照片的 32/32 端点仍满足逐字节重复、alpha 保持，固定源鼻部/完整眼区和嘴部外区
改变为 0 像素；720×960、sRGB、neutral identity/恢复、源图未变通过且无警告。
M 唇 −100/+100 的方向值：第一照片 −0.374485/+0.431094 px，第二照片 −0.310167/−0.561683 px；
丰唇分别为 −5.125469/+4.749960 px 与 −5.389010/+4.751490 px。
新聚合回执 `.verification/mouth-native-visibility-r2-aggregate-a.json`、
`.verification/mouth-native-visibility-r2-aggregate-b.json` 只含汇总数据；失败回执保留。
r2 重验没有增加不同用例总数；首轮通过记录不能覆盖候选 v5 的这份失败 bundle，
也不能证明与美图秀秀外观等价。


最终 v5 的独立复核发现，M 唇的 5×5 RGB 窗口同时包含移动的外上唇缘与固定的口腔带；
要求整个窗口作刚性平移会混淆两者。原 2D 配准和 1D 窗口结果保留为诊断，
M 方向改用源图定义的上唇红色度边界：原嘴角法线、固定五点切向带、1/32 px 采样，
以源图皮肤/唇色对比的 25/37.5/50/62.5/75% 五个阈值匹配同一 ROI 的边缘上升 crossing，
用位移中位数和中心相对双峰位移衡量 M 曲率。source 边缘保留前后 0.5 px 稳定性准入；
output 必须有相应上升 crossing，但不要求边缘后的固定口腔带维持唇色。
source 最小 contrast 4、至少三个阈值、方向 >0.02 px 均未降低；其余七项方向测量未改。
没有用 SDK 位移场或输出关键点作方向 oracle，也没有针对第二照片换 ROI/阈值。

测量代码先在无 SDK 的独立生成输入运行 **35 个数值控制**：5 个 RGB 纹理平移、
3 种皮肤/唇色 × 5 个边界平移、3 种颜色 × 5 个曲率（含正负 ±0.125/±0.5 px 和 neutral）；
另检查无对比输入拒绝和 **21,600 个固定口腔通道相等断言**。全部通过，
平移 ±0.09375 px、曲率 ±0.25 px 容差保留；测量实现与宿主方法逐块比对一致。
第一次生成曲率控制因 output 的 0.5 px 唇色稳定性条件不适用于薄唇/固定口腔而失败，
该失败日志保留；只修正上述 output crossing 条件后，完整控制通过。

随后使用稳定 `.build` 增量 `build-for-testing` 成功及新 `.xctestrun`，
`.verification/mouth-native-boundary-r3.xcresult` 独立解析为 **3通过/0失败/0跳过**：
两照片及新增亚像素/固定口腔控制用例。原有 10 个不同用例加这一控制，
本轮 **11 个不同相关用例最终通过**；两照片属于重验，未额外计数。
同一现有设备按 UDID 原子领取于 19:16:19，19:18:13 释放（2026-10-11，Asia/Shanghai）；
关闭并行，保留设备状态及缓存，未新建、克隆、重置、shutdown 或安装真机。

最终两照片 **32/32 端点方向通过**。M 唇 −100/+100 的主测量分别为
**−0.344490/+0.721494 px**、**−0.343046/+0.536213 px**；
源 contrast 最小 41.562/33.351、有效阈值最少 5/4，最大阈值位移 spread 0.384/0.343 px。
第二照片正向的旧 2D 诊断仍为 −0.561683 px，1D 窗口为 +0.515625 px，
新边界为 +0.536213 px；没有删除旧诊断或将 r2 失败 bundle 改写为通过。
丰唇 −100/+100 分别为 **−5.125469/+4.749960 px**、**−5.389010/+4.751490 px**。
32/32 逐字节重复、alpha 保持，固定源鼻部 envelope/完整眼区及嘴部外区改变为 0 像素；
720×960、sRGB、MediaPipe 478、neutral identity/恢复、源图未变与无警告通过。
保护声明仅覆盖测试的固定源区域，不表示鼻部周围全部像素不变。

新聚合回执 `.verification/mouth-native-boundary-r3-aggregate-a.json`、
`.verification/mouth-native-boundary-r3-aggregate-b.json`、
`.verification/mouth-boundary-controls-aggregate.json` 仅保留聚合数据，
不含私有输入路径、像素/蒙版或关键点。原 r1/UI 重验与 r2 失败回执均保留。
这些是指定照片的有界方向与保护证据；独立外观复核由 SDK 嘴部计划记录，
不声称与美图秀秀外观等价、任意照片可见强度、露齿形变或真机性能通过。


最终微笑补上参考的嘴角横向展开：在同一局部 corner × cornerVertical 中加入
0.030-mouth-span 的有符号横向分量，保留 0.044 的纵向分量、中央唇缝及原 cap/保护/梯度限制。
新增独立生成像素检查同时要求双角横向/纵向四档单调、中央唇缝精确和 width/微笑语义区别。
最终 SDK 三类定向 **25通过/0失败/0跳过**（11连续场 + 11公开像素路径 + 3 helper），
包含实际 Metal 用例；不是全 SDK 回归。相邻 SDK 计划拥有其他直接相关用例的库存及参考外观复核。

冻结这份源后再次增量 `build-for-testing`，只执行原两照片用例；不例行重跑
已通过且方法未变的 M 控制、控件或 UI。
`.verification/mouth-native-smile-r4.xcresult` 独立 summary/测试树解析为 **2通过/0失败/0跳过**。
宿主新增微笑嘴角轴上的 span change 断言 **>0.02 px**，继续保留原纵向 score 断言，
其他七项原方向、M 源定义边缘方法及所有保护/重复/neutral/元数据断言均保留。
新生成聚合使用 schema 4 的可选 `smileHorizontalSpanChangePixels`；新 oracle 文本
明确固定源鼻部 envelope/完整眼区，没有改写 r2/r3 原回执。

两照片 **32/32 原有方向和 4/4 新微笑横向条件通过**。
微笑 −100/+100 的 horizontal span change 为 **−7.001478/+6.501994 px**、
**−7.857456/+6.987270 px**；保留的 vertical score 为
**−5.061945/+4.749448 px**、**−5.445028/+5.126268 px**。
M/丰唇方向数值与 r3 相同；32/32 逐字节重复、alpha 保持，固定源鼻部/完整眼区及
嘴部外区改变为 0 像素，720×960/sRGB/MediaPipe 478、neutral identity/恢复、
源图未变及无警告通过。这两照片是已有用例重验，**不同相关原生用例总数仍为 11**。

本轮同一既有 iPhone 15 Pro/iOS 17.5 按 UDID 原子领取于 19:36:42，
19:38:34 释放（2026-10-11，Asia/Shanghai），等待鼻部任务释放宿主 `.build` 后串行增量构建；
保留设备状态与稳定缓存，无新建/克隆、设备设置变化、shutdown 或真机安装。
聚合 `.verification/mouth-native-smile-r4-aggregate-a.json`、
`.verification/mouth-native-smile-r4-aggregate-b.json` 仅含汇总数据；此前失败回执保留。
本记录证明指定输入的双轴微笑方向与原保护，不把方向通过等同于完整美图外观一致，
不声称一般肖像、露齿变形、性能或全 App/设备验证通过。

最终有界版本 v9 冻结为嘴部 map SHA256
`3c5d0c3d2bd0d398758bae96fc70a07c976ce9e1f21f4a8832ab3ac90a0dee14`。
丰唇正负端采用同一既有 `softLinear` 外侧 0.26-mouth-span 衰减与横向权重，
消除外侧的重复纵向衰减；M 正端的唇体 depth ramp 使用既有 `softLinear`。
negative M、微笑及其他字段、口腔固定带、availability/depth、安全 cap、0.45 梯度上限和
所有保护边界保持。这次没有改宿主测量方法、阈值或 UI。

最终同版 SDK 三类定向重新实际执行 **25通过/0失败/0跳过**，仍为
11 连续场 + 11 公开像素路径 + 3 helper，包含实际 Metal 端点用例；不是全 SDK 回归。
本轮跨阶段累计 **86 个不同 SDK 相关用例**由相邻 SDK 嘴部计划记录；
最终冻结源码本次实际重验的是上述 25 项，不表示再次执行 86 项或全量测试。
初次尝试因并行眼部测试表达式编译超时而 **0 用例执行**，日志保留；
负责方作等价类型检查拆分后重试通过，不将此编译依赖修复算作眼部效果验证。
聚合 `.verification/mouth-sdk-final-v9-aggregate.json` 记录最终源摘要和实际范围。

同版增量 `build-for-testing` 成功且重新生成 `.xctestrun` 后，仅执行原两照片用例。
`.verification/mouth-native-final-r5.xcresult` 独立 summary 与测试树解析为
**2通过/0失败/0跳过**；未重跑方法未变的 M 控制、控件、UI 或全 App 测试。
32/32 原方向及 4/4 微笑横向条件通过；M 唇 −100/+100 分别为
**−0.344490/+0.721494 px**、**−0.343046/+0.532942 px**，
丰唇分别为 **−5.875463/+5.999950 px**、**−5.518233/+5.625973 px**。
微笑横向 span 和原纵向 score 与 r4 数值一致，两类方向断言均保留。
32/32 逐字节重复、alpha 保持，固定源鼻部 envelope/完整眼区及嘴部外区改变为 0 像素；
720×960、sRGB、MediaPipe 478、neutral identity/恢复、源图未变与无警告通过。
这次两照片仍属重验，**不同相关原生用例总数仍为 11**。

本轮使用固定 `/Users/yakangwang/.codex/tools/simulator-claim.py run` 及固定共享状态
`/Users/yakangwang/.codex/state/simulator-claims`，领取已启动且空闲的同一现有
iPhone 15 Pro / iOS 17.5 / `2CE927C9-9303-4A9B-9C03-F28C42045186`。
领取于 23:20:30，自动释放回报于 23:22:15（2026-10-11，Asia/Shanghai；
释放时刻取最后一条 release 回报的日志修改时间）；随后固定 CLI status 确认无占用记录。
编译阶段不领取设备，关闭测试并行；保留设备状态与稳定 `.build`，
未使用旧临时 claim、新建/克隆/重置/shutdown 设备或执行真机安装。
`.verification/mouth-native-final-r5-run-receipt.json` 保存同源、范围与释放依据，
`.verification/mouth-native-final-r5-summary.json`、
`.verification/mouth-native-final-r5-aggregate-a.json`、
`.verification/mouth-native-final-r5-aggregate-b.json` 只保留匿名汇总与测试元数据，
不保存私有输入路径、原始像素、蒙版、关键点或占用令牌；此前失败和历史回执原样保留。
本记录证明指定输入的方向与固定源保护；参考外观的独立复核由 SDK 嘴部计划拥有，
不把方向通过等同于美图秀秀外观完全一致或一般肖像、露齿、真机性能已验证。

## 2026-10-12 嘴部幅度续作：最终生产定向重验

本轮依据所有者明确续作，集成 M3/F5/X4 有界算法；行为、参考目标及剩余幅度差距
由相邻 SDK [本轮完成记录](../plans/history/2026-10/A-2026-10-12-mouth-amplitude.md) 拥有。
最终嘴部 map SHA256 为
`dbbe5d135ec95edc4d416633985432fa762badacb2ac02773bd47622ee1022f7`。
八项居中双向控件与白牙单向契约保持；本轮没有改 UI 布局、宿主测试阈值或测量方法。

SDK 同版最终三类定向实际执行 **29通过/0失败/0跳过**，包含实际 Metal；
这是相关 SDK 验证，不能视作全 SDK 回归或重新执行历史累计用例。
宿主复用稳定 `.build`，在移除临时诊断源、项目引用及测试编译标志后，重新增量
`build-for-testing` 成功，`.xctestrun`、App 与测试二进制摘要在运行前后逐项一致。
本次使用实际生产 PhotoRenderer，未沿用诊断 binary。

[最终原生结果](.verification/mouth-native-amplitude-final-r4.xcresult) 的独立
summary/测试树确认 **5通过/0失败/0跳过**：原有 `MouthControlContractTests` 三项与
原有两项 `MouthPortraitAcceptanceTests`，仅此五项；没有重跑 UI、M 测量控制或全 App。
32/32 原方向及 4/4 微笑横向条件通过，方向阈值仍为 **>0.02 preview px**。
两照片 M 唇 −100/+100 分别为 **−0.830314/+1.029449 px**、
**−0.436808/+0.696202 px**；丰唇为 **−6.750968/+5.999950 px**、
**−6.147160/+5.625973 px**；左右位置为 **−7.687564/+7.218689 px**、
**−8.815886/+7.785245 px**。这些是原有源图测量方法的方向分数，不能换算成参考外观达标。
32/32 逐字节重复与 alpha 保持，固定源 observed 鼻部 envelope、完整眼区和嘴部外区
改变均为 0 像素；720×960、sRGB、MediaPipe 478、neutral identity/恢复、源图未变及无警告通过。

独立像素复核确认最终库存 34 张 PNG/schema4 完整；其中 neutral 与 M/丰唇/左右位置
所选 **14 张**与 r2 临时选定候选 full RGBA 逐字节一致，生产与影子回执身份分开。
固定源区域、原阈值 1.65/1.75 的补充读数折算到原始 1728 照片轴：A 的 M 端点对深度
由 a06b 的 3.5/2.5 改善到 **4/3.5 px**，负丰唇厚度由 79/75.5 改善到 **78/75 px**；
左右位置的端点对位移 A 由 34 改善到 **37.5 px**、B 由 36 改善到 **39.5 px**。
这些补充原图轴读数与上面的 720 preview 方向分数分别报告。
原尺寸所选图片未见明确新增嘴角挤压、唇缘波浪或鼻底台阶；
**完整 M 端点对、负收薄与原生 X 的参考幅度目标仍未达到**。
素材嘴角模型的宽度约束不等于纹理刚性，不声称美图秀秀外观完全一致。
该独立检查没有对其他控件重新作参考幅度测量。
[像素 identity](.verification/mouth-native-amplitude-final-r4-pixel-identity.json)、
[库存](.verification/mouth-native-amplitude-final-r4-pixel-inventory.json) 与
[固定像素复核](.verification/mouth-native-amplitude-final-r4-pixel-review.json) 保存实际范围。

编译时未占设备；使用固定 claim CLI/state，只领取现有
PineFrame-Editor-Validation / iPhone 15 Pro / iOS 17.5 / UDID
`732EEC08-3851-4E3E-8441-830633BEC514`，关闭并行。
2026-10-12 01:56:05.672113（Asia/Shanghai）领取，01:57:06.351866 自动释放回报，
释放时刻取最后 release 回报日志修改时间；之后固定 status 为空。
没有新建、克隆、重置或 shutdown 设备，没有真机安装或全设备矩阵。

[运行回执](.verification/mouth-native-amplitude-final-r4-run-receipt.json)、
[构建回执](.verification/mouth-native-amplitude-final-r4-build-receipt.json)、
[测试摘要](.verification/mouth-native-amplitude-final-r4-summary.json)、
[照片 A 聚合](.verification/mouth-native-amplitude-final-r4-aggregate-a.json) 和
[照片 B 聚合](.verification/mouth-native-amplitude-final-r4-aggregate-b.json)
仅保留同源、实际范围、匿名聚合与释放依据，不保存私有输入路径、像素、蒙版、
关键点或占用令牌。此前 r1 已通过候选、r2/r3 临时研究及 2026-10-11 失败和回执均保留历史范围。


## 2026-10-11 眼部双向滑杆

补齐大小、上下、长度、眼距、眼瞳大小五个独立入口，眼高保留既有 ID 并更正标题；
十一种几何字段及上扬别名均接 SDK `BeautyEyeShapeSlider`，零位居中、双向范围、独立快照。
倾斜右端由 helper 反向映射，外眼角向下；眼尾上扬右端仍抬升外眼角。新增控件使用
实际系统验证可用的 SF Symbols，原 60 个资源字节及安全区布局保持。

复用既有 **iPhone 15 Pro / iOS 17.5 / 2CE927C9-9303-4A9B-9C03-F28C42045186**、
现有字体/竖屏与稳定 `.build`，关闭并行；先等待同宿主鼻部真机任务释放构建目录，
再在已 released 的模拟器 claim 上登记独占。未新建/重置设备，未执行真机安装或全量回归。

- `.verification/eye-sliders-20261011.xcresult`：xcodebuild 退出 0，独立解析摘要
  **10 tests / 0 failures / 0 skips**。
- `ControlContractTests` **7项**：59位置/58可用/56 canonical 字段、cap、独立眼部绑定、
  ±100/±50/0、Codable/neutral、倾斜符号、既有别名、5个原生符号实际加载通过。
- `EditorSessionTests/testEyeSizeAndIrisSlidersKeepIndependentHistoryAndNeutralReset` **1项**：
  眼大小与虹膜大小独立、负值保持、撤销/重做、单项归零、确认后取消恢复通过。
- `PanelLayoutTests/testPanelUsesOneSafeAreaOwnerAndBackgroundReachesContainerBottom` **1项**：
  眼部 −100…100、中心零位、44pt滑杆、同一安全区位置以及底部白色像素通过。
- `EditorUITests/testElevenEyeSlidersExposeBothDirectionsAndRemainReachable` **1项**：
  实际选择十一工具、双向拖动、末项滚动可达、完成按钮与撤销/重做通过。
- `check-sdk-bindings.py`：56 canonical 绑定/cap及十一signed字段通过；
  `check-design-assets.py`：原60资产SHA/尺寸/几何、59工具及5个SF Symbol分支通过。
  6个修改Swift文件的语法解析通过。

已实际查看同回执内的 `native-eye-centered-panel-generated-input`、
`eye-size-negative-generated-input`、`eye-iris-positive-generated-input`、
`eye-corners-positive-generated-input` 四张完整容器截图：中心刻度及正负值可见；
白色背景覆盖底边，完整按钮与滑杆处于安全区，末项可以操作。
这些使用代码生成渐变/色块，真实UI中无脸请求明确保留原图；只验证宿主控件与布局，
**不能证明眼部外观或美图效果一致**。原始截图留在本次 xcresult 中，临时导出副本阅后清理。
去脂与祛红血丝效果不在本轮范围；原背景分割正例失败记录保持。

## 2026-10-11 鼻部参考算法与拖动调度（选定候选6）

按同照片美图参考将六项鼻部接入 SDK 连续鼻场；大小以整体横向宽度为主，
鼻尖独立调整鼻球，山根/鼻梁分别作用短上段和较长鼻背。六滑杆继续保留
−100…100、中心零位和独立参数。密集山根路径可以选择 Metal，实际鼻部几何
仍由两后端共享的 CPU-owned 静图阶段执行；没有新增 GPU API 或 Shader。

`EditorModel` 启动限频由40ms改为16ms，仍是一项运行中工作加一个最新待处理快照；
拖动中按序显示已完成帧，松手取消待发定时器并在当前工作后立即提交末值，
保留 revision 拦截、一次拖动一次撤销和拖动结束后调试分析。
16ms是启动间隔，不是实测输入到显示延迟或60fps保证。

复用固定 `.build`、单台既有 iPhone 15 Pro/iOS 17.5，关闭并行：

- `.verification/nose-reference-candidate5.xcresult`：**7通过/0失败/0跳过**，
  包含48档原生预览、12个原尺寸端点、prepared/fresh与换图以及4项调度保护。
- `.verification/nose-reference-candidate6.xcresult`：仅重验两个改变的照片用例，
  **2通过/0失败/0跳过**。最终源码恢复该候选的鼻场字节；未改动另外五个已通过用例。
  合计是**7个不同相关原生用例**，不是同次最终源码的7项全跑或完整App回归。
- SDK选定鼻场最终 `BeautyContinuousNoseMapTests` 与 `NoseContinuousIntegrationTests`
  **13通过/0失败/0跳过**，实际CPU/Metal端点一致性执行；不是完整SDK回归。
- 一张授权生成原图实际MediaPipe 478点：720×960预览、1728×2304原尺寸各
  **90/90**独立预冻结可靠端点方向/幅度检查通过。48预览档、12原尺寸端点的
  完整原生眼/眉/外唇包围域加2像素均零改变；neutral、恢复、重复、alpha/sRGB、
  源图未改与原尺寸upright lossless PNG round trip通过。

参考效果资格与XCTest捕获通过分开：正鼻尖仍略宽圆，宽度profile代理
预览0.745–0.755、原尺寸0.750–0.760，对照0.710–0.730；额外外鼻翼纵向残差
和更宽显示矩形的微小字节不等继续保留。候选7的局部profile仅多改善约0.005，
外翼残差更大，未被选为最终版本。参见SDK当前
[鼻部计划](../plans/active/A-2026-10-11-nose-reference-implementation.md)。
固定端点通过不表示所有姿态、照片、组合或美图完整外观一致。

所有者授权的iPhone 13 Pro曾运行候选2 Release：12个实际Metal端点与CPU字节一致，
720×960、4次预热/24次计时的CPU中位/p95为7.39/8.72ms，选择Metal为9.04/9.71ms。
这是候选2的限定计时；不转给最终源码，也不表示FPS、温升、能耗或持续运行通过。
随后连接的iPad不在原签名配置中，Xcode报 `No Accounts`；所有者明确稍后处理账号，
先继续算法。未新建Bundle ID、替换账号或绕过签名，没有最终iPad安装/测试。

初次候选3/4的固定生成外翼隔离失败保留；未修改0.8px判据或参考阈值。
缺少独立prepared临时输入导致的首轮失败及无测试执行的缓存/架构构建错误
保留在各自原日志中。候选5/6结果不重新签发这些失败。
本轮未修改底部安全区布局或新增UI自动化。


## 2026-10-12 iPad 鼻部真机复验与 A10 dispatch 修复

所有者再次确认 iPad 已连接/解锁，沿用原 Personal Team 和主标识
`com.yakang.wanneng1`。签名/设备登记已恢复，Release 应用更新安装，保留数据，
测试结束后成功打开应用。只使用这台已有 iPad（第7代，A10，iOS 18.7.9），
稳定 `.build`、关闭并行；测试输入仅在专属 Documents 临时目录。

首次 `.verification/nose-ipad-selected6-20261012.xcresult` 独立汇总为
**1通过/2失败/0跳过**：48档 CPU 预览通过，原尺寸与 Metal parity 均触发
`NSException APINotSupported`。SDK 两处 nonuniform `dispatchThreads` 改为
rounded-up uniform `dispatchThreadgroups`；既有 kernel 已有图像边界检查。
保留 shader、公开 GPU API/backend、鼻部候选6、保护与准入阈值，不改成 CPU
fallback 掩盖此设备失败。更改属于 SDK，宿主 UI 和渲染选择未改。

增量重建安装后，`.verification/nose-ipad-uniform-20261012.xcresult`
独立汇总为 **3通过/0失败/0跳过**，范围为三个现有 `PhotoPipelineTests`：

- `testOwnerPortraitNoseReferenceIsolationAndExport`：六独立项各 ±25/50/75/100，
  共48档 CPU 预览，720×960，实际478点，无警告；neutral/恢复/重复通过。
- `testOwnerPortraitNoseOriginalResolutionEndpointsAndRecovery`：12个实际Metal
  原尺寸端点，1728×2304，完整源眼/眉/外唇 envelope 加2 native px 精确；
  alpha、sRGB、方向/尺寸、lossless PNG、原输入不变通过。
- `testOwnerPortraitNoseCPUAndGPUParityAndBoundedTiming`：12个端点均实际Metal，
  与 CPU max-channel 和 mean-RGB 差为0，无静默CPU替代。

以上48预览和12原尺寸输出均为全源眼/眉/外唇保护区零变更。独立评价复用冻结
90项可靠方向/位移、参考模板、全局对齐和阈值，7/7文件摘要未变；两尺寸各
**90/90**，全部可判定。正向鼻尖仍略宽圆（预览0.745–0.755，原尺寸0.750–0.760，
参考0.710–0.730）；附加外鼻翼纵向残差和更宽显示矩形微小不等继续记录。
原尺寸细节未见明显新接缝或鼻孔破损，不把此单照片几何检查当成完整美图外观一致。
新压缩对照：`../example-images/previews/nose-ipad-reference-20261012.jpg`。

本轮 scoped SDK `BeautyMetalRuntimeTests` + `NoseContinuousIntegrationTests`
为 **16通过/0失败/0跳过**，含新30次实际Metal宽度/行末/alpha/资源回收检查。
首次新测试编译失败（零执行），第二次的新零位移夹具有57个断言失败；
将几何作用域移到像素之外，同时保留真实 geometry dispatch 和所有严格断言后，
第三次16项全部通过。先前失败日志与原生失败bundle保留，未放宽判据或修改冻结shader。

Release 720×960 限量耗时：共4次准备渲染，随后每后端12个不同端点，总24次测量。
CPU median/p95 为30.404/38.733ms，selected Metal 为37.293/50.715ms；12样本p95
等于最大值。包含共享 CPU 鼻场和 Metal staging，不是每端点12次或原尺寸耗时，
也不代表触摸到显示延迟、60fps、温升/耗电或长稳。未基于此少量样本改选后端。
先前候选2 iPhone数字仍仅属于其旧版本。未重跑 prepared/scheduling 未改用例、
iPad实际拖动/UI布局、SDK/App全套或扩展设备矩阵。

当前鼻场/runtime/PhotoRenderer/EditorModel 摘要均与本次设备构建快照一致；
保留 shader 摘要匹配。设备占用已释放，现行未结清项仍见
[鼻部计划](../plans/active/A-2026-10-11-nose-reference-implementation.md)。


本轮测量、原尺寸细节检查和压缩图发布后，精确删除47个新本机媒体副本
（122,879,785 logical bytes）；保留冻结oracle、aggregate/profile、失败日志、
结果bundle和新压缩图。设备专属 `Documents/OwnerNoseReference` 先逐项确认用途，
清理命令首次参数缺bool值未执行，补值后CoreDevice返回目标file node错误；
后续只读父目录元数据确认该测试目录已不存在，不把失败copy写成传输成功。
没有清理该目录之外的用户照片/应用数据，没有卸载应用或删除稳定构建缓存。


## 2026-10-12 前五眼部参考滑杆

按用户指定聚焦大小、上下、眼高、长度和眼距；只有这五项启用参考样式。
在美图原1170px截图中，轨道竖run为9px、thumb直径60px、中心点18px，
对应本轮宿主3pt细轨、20pt白圆和6pt圆点。44pt点击区域保持，初版轨道两端留10pt，
黑色背景仅属于slider自身44pt区域。有效白段从中点至thumb；其他面板及工具布局不变。
方向仍为向右放大/下移/增高/加长/分开，helper线性映射及SDK cap未改变。

复用 **iPhone 15 Pro / iOS 17.5 / 2CE927C9-9303-4A9B-9C03-F28C42045186**、
现有字体/竖屏及稳定 `.build`。两次设备阶段均由共享claim CLI `run` 原子领取并自动释放；
未新建设备、未操作真机、未执行全量App回归。只运行以下相关范围：

- `.verification/eye-five-sliders-20261012.xcresult`：**14 tests / 0 failures / 0 skips**。
  `ControlContractTests`8项、眼部独立历史Session2项、Panel2项及眼部UI2项。
  覆盖限定5样式、±端点/中点、分数值不量化、五项独立参数、一次拖动一步撤销、
  切换恢复、去脂停用、原11项实际滑动及末项可达。
- 首次逻辑/触摸通过后，实际截图发现自定义灰轨覆盖原生thumb，零点白圆被切开。
  已将参考轨/白段/零点放到原生thumb背后，保留该首次回执作为当时范围，
  不把14项逻辑通过冒充首次外观正确。
- `.verification/eye-five-sliders-20261012-visual-fix.xcresult`：受影响Panel2项及前五UI1项
  **3 tests / 0 failures / 0 skips**。实际从任意轨道位置点按、逐项负侧拖至正侧、
  ±100/0、撤销/重做、切换后五个独立值恢复通过。无整数snap或SDKresponse curve；
  连续触摸仍为Float，辅助功能每次增减1个显示单位、读数取整。
- 实际查看视觉修复回执的 `eye-five-reference-left-generated-input`、
  `eye-five-reference-right-generated-input`、`eye-five-reference-neutral-generated-input`、
  `eye-five-reference-spacing-drag-generated-input` 四张完整截图：白圆能覆盖轨道，
  填充方向正确，中点可见，底部背景连续且完成/取消/滑杆触摸可达。
  后续原尺寸复核发现右端圆边跨出黑底被白面板吞掉，旧常驻100读数也贴近顶边；
  该3项通过并未检查这两个外观缺陷，不能称端点整圆已通过。
- `check-design-assets.py` 与 `check-sdk-bindings.py` 通过；六个相关Swift文件语法解析通过。

端点修复使用透明44pt原生thumb及独立20pt白圆layer，轨/填充/点按/白圆共用同一中心；
端点内距改为12pt，白圆外保留2pt黑底，前五项隐藏旧常驻数值、保留辅助功能读数。
新增原生±100/0四方向白圆与外侧黑底像素断言，并在前五实际点按/拖动UI用例检查。
`.verification/eye-five-native-candidate1-20261012.xcresult` 的滑杆3项为1通过/2失败/0跳过：
轨/连续值单测通过，Panel外框18个黑像素断言和首UI端点黑像素断言失败。
原尺寸截图证明UIKit alignment rectangle比view bounds两侧各小2pt，采样的view边缘已在白面板；
参考样式现单独使用零alignmentInsets，使bounds、黑底、轨/白圆共用呈现框，原样式不变。
原白>245/黑<5阈值保留。
`.verification/eye-five-native-candidate2-20261012.xcresult` 的滑杆定向3项全部通过：
**Panel2 + 前五真实触摸UI1 / 0失败 / 0跳过**，实际检查五项各−100/0/+100共15状态的
白圆四向内部白像素和外侧黑底，44pt区域/连续Float/点按拖动/单步撤销重做/五值切换恢复通过。
该bundle中另一个独立肖像capture用例仍因临时输入admission guard失败、0帧输出，
所以只声明这3项滑杆检查通过，不声明整个4项bundle或算法效果通过。
已重新导出并实际查看该回执的4张完整左右端/零态/眼距拖动截图：两端整圆处于黑带内部，
填充、零点与白圆几何一致，旧常驻读数隐藏，底部背景连续，完成/取消与滑杆可达；
无旋转/字体/多设备/真机扩大，也没有重复之前14项逻辑回归。
本节UI截图均为生成渐变输入，无脸请求保持原图；只证明控件、接线、历史与布局。
实际MediaPipe眼部输出及美图效果资格由独立SDK/肖像验收记录说明，不能从UI测试推导。
原xcresult与匿名聚合保留，临时截图导出在最后使用者查看后清理。

## 2026-10-12 前五眼部 C7 生产输出与 iPad 原尺寸检查

本轮冻结 C7 大小、上下、眼高、长度和眼距。实际使用
`EyeFivePortraitAcceptanceTests/testProductionPortraitFiveEyeFramesAndMechanicalContracts`
同一个测试方法，分三种配置执行，共 **3 次执行 / 0 失败 / 0 跳过**；不是三个不同用例，
也不是完整 SDK/App 回归。滑杆三个不同用例的结果仍由上文的 iPhone 验证拥有，
未在 iPad 重跑 UI、方向、字体或交互矩阵。

- 已有 iPhone 15 Pro / iOS 17.5：725×960 CPU 预览 40 档，1170×1550 CPU
  原尺寸 10 端点；两次执行共 50 个参数输出。预览重复渲染检查覆盖十个端点，
  其余三十档未逐帧重复。neutral、重复 neutral、恢复、输出尺寸、alpha、sRGB、
  实际 MediaPipe 478 点及 usedFaceCount=1 均检查通过。
- 所有者已连接的 iPad / iOS 18.7.9：沿用 `com.yakang.wanneng1` 更新现有
  BeautyEditor，没有卸载、重置或新建主标识。Release 原尺寸十个端点全部实际
  选择 **Metal**，没有 CPU fallback 伪装；每端点使用独立 CPU renderer/photo
  对照，RGBA 字节完全一致，Metal 重复、neutral 及恢复也完全一致。
- Simulator 的 App、production debug dylib、Test、实际 `.xctestrun` 摘要在
  运行前后一致；iPad Release App、Test、原 `.xctestrun` 摘要也一致。
  临时 SDK 诊断日志已删除，普通运行没有额外源几何输出。

工程捕获和机械检查与图片效果资格分开；冻结方向、幅度、跨字段影响、保护区、
人工原细节与不同输出尺寸的图片 oracle 由 SDK 眼部记录拥有。本轮输入是所有者
提供的已编辑参考端点，不能当未编辑原图或完整美图外观等价的证据。
没有测量实际拖动到显示延迟、性能、温升、功耗或长稳。

当前匿名机械摘要：`.verification/eye-five-native-selected7-20261012-mechanical.json`。
三个最终结果是 `eye-five-native-candidate7-full-20261012.xcresult`、
`eye-five-native-candidate7-preview-20261012.xcresult` 和
`eye-five-ipad-candidate7-20261012.xcresult`；均位于 `.verification/`。
仅保留聚合、源码/编译物摘要及范围，不持久化原点、矩阵或私人输入路径。

C6 原尺寸 size 跨眼距超过冻结容差的失败保留，不作最终通过。
物理准备首轮因未使用的 UI runner profile 缺失而零执行；改用已有仅含
App/AppTests 的 `BeautyNoseReference` 私有 scheme。第二轮缺 Release
`-enable-testing`，仍零执行；用命令覆盖 `ENABLE_TESTABILITY=YES` 后成功，
没有改变工程签名设置或开发者账号。首次 C7 预览领取遇到其他项目占用，
零执行且未抢占；复查共享池时原已启动设备已释放并空闲，随后原子领取成功。

## 2026-10-12 眼部第二批五项参考优化与十项滑杆

按所有者本轮明确请求，追加优化下至、眼尾上扬、倾斜、内眼角和外眼角；
精确十个已选工具 ID 共用参考滑杆，旧别名与其余眼部工具保留原接线。
中点零位、左右双向、3pt轨/20pt白圆/6pt零点/44pt触摸、12pt内距、零到拇指
填充、连续点按/拖动及辅助功能一步1均保留；没有常驻数值或整数拖动吸附。

最终 C28 Debug 增量 build-for-testing 通过。同一已有 iPhone15Pro/iOS17.5
模拟器按 UDID 原子占用并释放，没有新建/克隆或抢占设备。
ControlContract 1、PanelLayout 2 与新旧两批滑杆 UI 各1，共 **5/0/0**；
两批十项±100/0共30状态/像素检查，连续点按拖动、撤销重做及反向工具顺序
独立恢复通过。两张完整viewport和八张原生滑杆面板crop实际复核，安全区
保持单一补偿owner。UI采用生成的no-face输入，效果验证另走真实照片方法。

`EyeFivePortraitAcceptanceTests/testProductionPortraitFiveEyeFramesAndMechanicalContracts`
分别执行一次原尺寸1170×1550的20端点（后五项10+前五项回归10）和准备预览
725×960的后五项40双向四档，每配置 **1/0/0**。实际MediaPipe478/CPU，
单张已有编辑参考端点按嵌入P3先转换为tagged sRGB；一张有效脸、无警告，
neutral/重复/恢复、alpha/sRGB/尺寸与source不变通过。只重复20个原尺寸cap
和10个预览cap，其余30预览档未重复。后五项两尺寸的冻结幅度、方向、分离、
固定核心保护与原生眼区细节/必要弱尺度身份复核通过，前五项cap与同输入C7
实现基线PNG exact 10/10。SDK直接路径23/0/0，含公开CPU/actual Metal；
后端字段通过不能代替美图外观验收，当前回执分别保留两类检查。

输入缺共同未经编辑neutral、数值和中间参考轨迹；不声明完整美图外观、
一般人群/姿态/组合、严格尺寸不变、完整语义蒙版、真机性能或全量App/SDK回归。
部分非目标读数靠近冻结限值；一般P3非中性±1量化并未在本轮修复。
当前iPad锁屏，本批没有新增真机安装、Metal肖像捕获或真机UI验证。
范围、失败、源码/产物哈希与聚合见相邻SDK的
[后五项完成记录](../plans/history/2026-10/A-2026-10-12-eye-next-five-match.md)和
[本轮回执](../docs/validation/EYE_NEXT_FIVE_20261012.json)。旧记录保留原日期/范围。


## 2026-10-13 嘴部 R11 iPad 有限结点候选工程与效果复验

按当前嘴部交接与 root GO，仅验证 d2ce7fa7 有限 source-basis 边界结点候选；
生产嘴部仍为 dbbe5d，未选择、集成或交付候选。使用已有 iPad7,11/A10、
iOS18.7.9(22H355)，UDID `f4ef3f178ce25d79e7f963ff6fe0261b127f4865`。
先等待并行眼部用例结束并自行释放，再串行复用宿主 `.build`。
现有 Team UHKD6CZHH3、profile 覆盖该设备至 2026-10-18；同一
`com.yakang.wanneng1` 测试 App 更新替换当时的眼部 App，保留应用数据，
保存的 `.verification/eye-physical-delivery/BeautyEditor.app` 字节未变。
运行前原子 claim 内复查 passcodeRequired=false、unlockedSinceBoot=true；
当前预检 transport 为 localNetwork，不沿用旧回执的 USB 描述。

冻结 R11 harness 9317a847、config 266d2bc7 与候选 d2 的签名 Release
build-for-testing 成功；新 App/Test/xctestrun 身份按本次构建记录，不能沿用
R10 二进制回执。临时四份测试源、项目 refs/flags 与私有 scheme 已移除；
project 精确恢复，原 scheme 不变。构建没有占用设备 claim。

实际只运行 `MouthNativeIPadXOnlyTests/testFreshProductionAndFrozenXCandidate`
一次，独立 xcresult summary 为 **1通过/0失败/0跳过**，方法 4.792s。
两输入各 720×960；新增 PNG 共10张（neutral2、fresh生产 X±4、candidate X±4），
X 双向四档共16行。实际 PhotoRenderer 与同次 frozen dbbe standalone 参照
全RGBA一致；候选 neutral 为 nil/恒等，F−只做2个内存 DD 身份，未增加 F
图片效果验收。X 原 physical field 严格0、保护/外围 RGBA0、alpha、重复、
四档方向与单调、原梯度/位移界均通过；材料嘴角宽度与 image-Y 变化为0。
X 口腔随整嘴移动，本测试没有声称 X oral-zero。

16次既有 CPU 调用的 construction median/p95 为2.77656/3.45538ms；
sampling median/p95 为7.82990/8.00492ms。p95为本次16样本最大值，
不是完整渲染、拖动、FPS、功耗或长稳结果，未额外运行性能测试。
source/config/artifacts 在运行前后一致，专属输出取回成功，claim finally释放。
新 `.verification/mouth-ipad-basis-knot-r11.xcresult`、build/run日志、匿名
summary/aggregate/inventory 与稳定缓存保留。持久记录无 source geometry。

独立像素代理实际先冻结本次同 iPad 的6张新基线，再读取4张候选；
原7项硬门结果为 **6通过/1失败**。仅 B RGB19 负端绝对纹理span
0.7690% 超原0.75%；B RGB23 的0.7467%不能替代该窗口失败。
A RGB15/19/23 pair增益3.9154/2.8989/2.9010px，最大span0.3292%、
最大误差恶化0.1044pp均通过；B RGB19/23增益1.7023/1.6589px、
误差恶化0.1337/0.1473pp通过。NCC A最低0.9953/B最低0.9916、
搜索边界0；4端点原尺寸细节未见明确新的口缝、夹点、唇波或鼻底台阶，
不能覆盖B19硬门失败。fresh6/10PNG身份均exact。
独立review SHA256为
`67d0f4b95fafb5168388dfe3ee51dfc21551fc6cb3135f5974e75c3b9d353bee`。
因此 d2 候选及其生产转换被拒绝，工程1/0/0保留其范围，不作为效果通过。
没有重跑 R10、Mac、17项影子、UI或全App/SDK；最终31/public14/5原生尚未执行。
验收状态与后续决定见相邻 SDK 的
[现行嘴部计划](../plans/history/2026-10/A-2026-10-12-mouth-native-followup.md)。


R11拒绝后，未绑定的 `final-ipad-build.py` 与 `final-ipad-execute.py`
只扩展既有 failed-source denylist：加入 d2ce7fa7 候选与其 ed2effdb 生产草稿。
全部旧拒绝项、final31/Metal32/public14/native5/conversion门禁、模板和数学保持；
逐文件逆移除两项恢复原文本exact，AST parse/compile与各15个独立membership
控制通过。该控制没有运行final driver、build或设备；R11冻结driver及独立
final像素适配器不改。新hash与完整diff见
`.verification/mouth-native-harness/device-preparation-ipad-20261012/final-r11-rejection-gate-receipt-20261013.json`。
新方案当前只在SDK侧准备证明，尚无新候选或R12原生GO；本宿主没有继续执行。

## 2026-10-13 眼部 C32 iPad 最终交付与后五项预览验收

所有者明确继续后五项参考任务并解锁现有 iPad。最终 SDK 眼部 map SHA256 为
`e0fe7884f5410a81f3b8b1116c42ac29511eca9d7a2e8da4b38d908ecdd53806`。
C32 在九行源 RGB 候选中选择最宽的三行一致局部注册；原 contrast/coherence
准入与保护阈值保留，前五项整体眼形变不改。十项既有 signed 滑杆继续使用
SDK −1…1 / 显示 −100…100 接线，本轮没有新增宿主 UI 修改或触摸测试。

最终同版 SDK 直接路径实际执行 **8个不同相关测试 / 0失败 / 0跳过**，
另追加同一 row-gap 采样间隔用例 **1次执行 / 0失败 / 0跳过**，不增加不同用例数。
C31 的先前24项属于此前版本记录，未作为 C32 的再次执行或完整 SDK 回归。

本轮只使用已有 iPad 第7代/A10/iPadOS 18.7.9，UDID
`f4ef3f178ce25d79e7f963ff6fe0261b127f4865`，按共享 claim 串行安排本轮构建与设备操作，复用稳定缓存。
最终签名 Release App 保存在
[C32 就绪应用](.verification/eye-physical-delivery-c32/BeautyEditor.app)。
沿用现有 `com.yakang.wanneng1`、Team/profile 更新应用，最终安装与打开均退出0，
保留用户数据；自己的设备 claim 已释放。最终编译物身份如下：

| 产物 | SHA256 |
| --- | --- |
| App main executable | `3f07cf1b95996374776eebd8ec70095924e08821ef340c1be9c17adb445a398f` |
| AppTests executable | `dc41c6197c9394d3c9ada6e8d3942ee449b6490415b453ac10f67a23c13c4d02` |
| Provisioning profile | `229b78bb756d980d9b45c818d70393531e881c06ddcea95ec5517a5ffad3dc84` |

| 本轮原生证据 | 实际执行及范围 |
| --- | --- |
| [原尺寸结果](.verification/eye-ten-ipad-c32-20261013.xcresult) | **1通过/0失败/0跳过**；1170×1550，十项正负 cap 共20输出全部实际 Metal，逐端点与独立 CPU 的 RGBA 完全一致；20端点重复完全一致。neutral、source 不变、alpha、sRGB、extent、实际 MediaPipe 单脸478点及 noWarning 通过。 |
| [预览结果](.verification/eye-next-ipad-c32-preview-20261013.xcresult) | **1通过/0失败/0跳过**；725×960 CPU，后五项 ±25/50/75/100 共40设置；10个 cap 重复完全一致，其余30档未逐帧重复。相同冻结参考判据、四档方向/单调与固定核心保护通过。 |

工程捕获与独立图片判据分别检查。两尺寸均通过冻结 V2 参考和固定核心保护
oracle，原尺寸前五项10端点、未受影响的眼尾/倾斜/内眼角6端点与实际 C28
PNG exact。原尺寸冻结幅度读数如下，容差继续使用 max(1 pixel, 目标的10%)：

| 后五项 | 冻结目标（px） | C32（px） |
| --- | ---: | ---: |
| 下至 | 7.684474 | 6.965290 |
| 眼尾上扬 | 16.264609 | 15.255883 |
| 倾斜 | 20.092528 | 18.474064 |
| 内眼角 | 30.163689 | 31.051080 |
| 外眼角 | 19.384978 | 18.773829 |

九项必要弱特征身份复核已用原生细节完成；原尺寸和预览 cap 的已检查区域未见
新的明显接缝、重复轮廓或虹膜破损。最终
[压缩对照](../example-images/previews/eye-next-five-ipad-20261013.jpg)
为1600×950展示 JPEG，不作像素 oracle。示例媒体容量检查通过：47张图、21张预览，
共37,433,813 bytes。精确范围、源码/产物身份和匿名聚合由相邻 SDK 的
[最终回执](../docs/validation/EYE_PHYSICAL_20261013.json)与
[完成记录](../plans/history/2026-10/A-2026-10-13-eye-physical-delivery.md)拥有。

输入仍是单张已编辑参考肖像，真实零态、美图数值与四档参考曲线未知。
本轮结果不声称完整美图外观、一般人群/姿态/组合、完整语义蒙版、性能、温升、
耗电、长稳或 iPad UI 触摸资格，也未重跑 App/SDK 全套。C28/C31 失败及旧回执
保留原版本、日期与范围，不由最终通过重写。

最初 C28 构建曾误清理并行嘴部待运行的 Release 产物；已按冻结 R10 配置恢复并
另签新构建回执，恢复过程中 **0个设备测试执行**。后续 C32 preflight 尊重 R11
设备 claim，精确保护/恢复当时最新 R11 App、Test 和 runfile，未用旧 R10 覆盖新 R11。
最终 C32 就绪 App、两份 xcresult、冻结历史与稳定缓存继续保留。

设备上本任务专属临时媒体根清理前已列明542个条目（532文件、10目录）。
删除命令在根已移除后报 CoreDevice 7000、退出1；随后独立 fresh inventory 确认
该根不存在、退出0，因此只声明专属根已清除，不把失败删除命令写成退出0。
设备其他应用数据保持；本机临时媒体的清理结果由 SDK 最终完成记录拥有。


## 2026-10-13 嘴部 R12 iPad 径向源 basis 候选工程与效果复验

R12静态准备由完整R11 oracle只改namespace/type/source与匿名元数据；
逐份harness/config/driver逆归一身份和AST通过。新source750efdae是固定
sqrt(2) source-basis径向载体，保留原H/T/64准入、零域与cap；条件几何profile
界不作为完整RGB纹理保证。原17为17/0/0，实际Mac独立7/7后root才给原生GO；
Mac首次Failure.detect/0PNG及同binary重放的实际范围保留在SDK计划。

root复用稳定`.build`完成签名Release新构建，并用原子claim串行使用已有
iPad7,11/A10、iOS18.7.9(22H355)与同一`com.yakang.wanneng1`。
测试App更新替换同ID当时App，保留应用数据；保存的眼部App身份不变。
claim内新device details/lockState确认ready，未新建设备、ID或签名资源。

实际 `MouthNativeIPadXOnlyTests/testFreshProductionAndFrozenXCandidate`
单方法执行 **1通过/0失败/0跳过**，5.497s。
两输入各720×960，10PNG为neutral2/fresh生产X±4/candidateX±4，另有
16个X双向四档和2个F−内存DD身份。helper `.geometry` 与实际PhotoRenderer
cached prepare是两条检测路径；新dbbe控制与同次actual renderer全RGBA一致。
physical field0、保护/外围RGBA0、材料嘴角宽度/image-Y0、neutral、source、
alpha、重复、原方向/单调/梯度/位移断言通过。X口腔随整嘴移动；F2没有
提供新的F厚度/四档像素效果资格。source/config/artifacts前后exact，工程
临时refs/flags/scheme/source精确恢复，输出取回成功，claim finally释放。

16次既有CPU调用construction median/p95为
2.94206/4.49596ms；
sampling为11.60665/14.18625ms，
16样本p95为最大值；不是完整渲染、拖动/FPS、耗电或长稳结果。

独立像素代理先冻结本次fresh6基线，再读candidate4；正式原7门为
**6/7，FAIL**。
B RGB19负端绝对span 0.7544%超过原0.75%，B23的
0.7343%通过不能替代19；正式1:1细节检查已完成，其通过不能覆盖
硬门失败。review SHA256 `f76e8c2fb9138348cb879737f1ff96a5e3592bddc0174e8d5a842315aa33f153`。
因此750efdae与其bdddf7ee忠实生产草稿被拒绝；生产仍dbbe5d，未集成或发布。
R12工程1/0/0只保留其范围，未执行依赖的final31/public14/最终5原生，
未跑UI、全App/SDK或其他设备矩阵，未清理此轮待复核证据。

新R12 xcresult/build/run日志、summary/aggregate/inventory与稳定缓存保留；
持久回执无raw geometry。现行决定见
[嘴部计划](../plans/history/2026-10/A-2026-10-12-mouth-native-followup.md)。


R12拒绝后，未绑定的 `final-ipad-build.py` 与 `final-ipad-execute.py`
只扩展既有 failed-source denylist：加入 750efdae 候选与其 bdddf7ee 生产草稿。
全部旧拒绝项、final31/Metal32/public14/native5/conversion门禁、模板和数学保持；
逐文件逆移除两项恢复原文本exact，AST parse/compile与各17个独立membership
控制通过。该控制没有运行final driver、build或设备；R12冻结driver及独立
final像素适配器不改。新hash与完整diff见
`.verification/mouth-native-harness/device-preparation-ipad-20261012/final-r12-rejection-gate-receipt-20261013.json`。
后续候选需重新通过既有门禁；本次未运行任何final或后续原生测试。


## 2026-10-13 嘴部 R13 签名构建与锁屏预检

terminalf160经过完整证明/独立source及wrapper审查、实际原17/0/0（4.452s）和
独立Mac原7/细节PASS后，root绑定native gate dabe43dc并完成新签名Release
构建exit0。复用稳定cache、既有Team/App ID/同iPad，project/source/scheme
精确恢复，保存的眼部App不变。Mac新4与上一750 Mac全RGBA一致；没有据此
推断原生修复。build receipt SHA256
`b56459f7fc01ce74eada69dbce0e8039104fd5d21ec0235d5d1936f91eded186`。

首次execute在fresh claim内的lockState报告passcodeRequired=true，原始
入口在install/stage/XCTest前中止。实际0安装/0输入stage/0方法/0PNG，
xcresult/run-receipt/media/input包不存在；claim finally释放，signed产物和
saved eyeApp保持。匿名locked-preflight receipt SHA256
`6e1c71d2570042da562e5cc9dd2de89beade93c17416fcaa0317c81e148ccdf6`。
这次是当前设备可用性阻断，既非候选效果失败也非原生工程通过。

2026-10-13当时仅请求所有者解锁并准备resume1：仅LOG/tmp details/lock
命名变化，整源逆回原execute；summary-resume1仅LOG替换，原1/10/16/F2
检查不变。本节保留当日签名build与locked preflight范围。2026-10-14实际
恢复执行及独立效果结果见下一节；此前两次环境预检失败和原日志均保留。


## 2026-10-14 嘴部 R13 iPad terminal-jet 实际恢复执行与独立效果复验

R13 source f160、harness93ea、config4adc、proof/原17/Mac7及签名build
继续保持2026-10-13冻结身份；实际设备执行日期为2026-10-14。
所有者解锁后，resume1仍在安装与测试前因iPad夜间升级为18.7.10(22H374)、
旧launcher期待18.7.9而停止。匿名历史OS-preflight回执与原日志保留，
该attempt为0安装/0stage/0方法/0PNG，claim finally释放；不作为候选失败。
此前10/13 locked-preflight失败也按原日期保留。

root只对resume2 launcher的OS/build守卫、LOG/tmp命名及summary OS/date
元数据作最小适配；whole inverse exact，原frozen执行driver8002、config、
所有测试方法/断言、数学及已签名App/test/xctestrun不变，无重建。
实际使用同iPad7,11/A10、iOS18.7.10(22H374)、wired及同一
`com.yakang.wanneng1`，更新测试App保留应用数据与保存的眼部App。
fresh6基线与candidate4均由本次同设备/同系统新生成，没有借用旧18.7.9媒体。

实际 `MouthNativeIPadXOnlyTests/testFreshProductionAndFrozenXCandidate`
单方法 **1通过/0失败/0跳过**，5.207s。
两输入各720×960，10PNG为neutral2/fresh生产X±4/candidateX±4，
16个X双向四档及2个F−内存DD身份。actual PhotoRenderer与同次frozen
dbbe参照全RGBA一致；physical field严格0、保护/外围RGBA0、材料嘴角
宽度与image-Y0、neutral/source/alpha/重复、原方向/单调/梯度/位移
断言通过。X口腔随整嘴移动，本轮未声称X oral-zero；F2未增加F像素资格。
source/config/artifacts前后exact，project/source/scheme精确恢复，
输出取回成功，saved eye App不变，claim finally释放。

16次既有CPU调用construction median/p95为
2.79440/7.20371ms；
sampling为11.90281/21.90700ms。
16样本p95为本次最大值；不是完整渲染、触摸/FPS、耗电或长稳结果，
本轮没有新增计时执行。

独立像素代理先冻结本次同18.7.10 fresh6，再读candidate4；正式原7门为
**7/7，PASS**，原尺寸1:1细节检查已完成。
B RGB19/23负端绝对纹理span分别为
0.7385%/0.7211%，
继续逐窗使用原0.75%绝对span与0.25pp误差增加门限；B23不能替代B19。
失败项：无。
正式review SHA256 `70003664f5763ee007a055c86ccfa805c9b5b169d0c9837ee51b95ac38433b52`。
本次仅取得 R13 有界 X 阶段的同设备效果准入；生产转换与最终资格另需 root 门禁，尚未执行。

生产嘴部仍dbbe，final31/Metal32/public14/最终5原生与最终F/X未执行；
没有重跑R11/R12、17、Mac、UI、全App/SDK或其他设备矩阵。
本轮xcresult/build/run日志、summary/aggregate/inventory及稳定cache保留；
无清理、提交或推送，持久证据无raw geometry或私有输入路径。
现行决定见[嘴部计划](../plans/history/2026-10/A-2026-10-12-mouth-native-followup.md)。


## 2026-10-14 嘴部最终生产门禁与真机安装停点

R13同设备影子工程1/0/0和原7/细节通过保留其范围。SDK31旧4f503
合成标记窗口混入上唇fiducial；actual34矩分解和32次paired-blue公开
渲染证实归属混合，仅修正合成源blue身份与corner归属，不改几何、窗口、
R120、方向、0.45px宽度或0.3px跨轴容差。新test463实际SDK31/0/0含
原Metal32断言通过，原17/matcher不变，旧FAIL不回填PASS。Public14新
生产输出全RGBA对direct/reference/repeat一致，通过14库存；本轮未全量。

最终模板5/36/14/schema2与原数值断言保持。actor0与actor1两次只到
Swift并发隔离编译失败，0方法/PNG且project/temporary refs/scheme精确恢复。
单一static1修正只将纯sample声明nonisolated/static及7处Self调用，
完整计算正文不变且逆还原原harness；现有稳定.build增量签名构建exit0，
226.981s，build receipt b950ef39，保存eye App5b612不变，工程精确恢复。

最终设备前检仍是同iPad7,11/18.7.10(22H374)、DDItrue及解锁。连接变为
localNetwork，wired-only预检在install前停止；实际连接元数据适配后，
相同签名产物的两次数据保留安装均因IXRemote/XPC连接中断失败，
均无staging/无XCTest/无PNG，不能说最终5通过。源、签名产物、精确owned
PACK与两次失败log/run receipts保留，设备claim均finally释放。
该检查点当时等待所有者USB连接后复用同产物继续，不重建或重复局域网安装，
不卸载应用或删除其数据。最终F/X独立像素准入尚未执行；没有预览发布
或媒体清理。当前源74e为待最终验收的忠实集成，现行嘴部计划继续拥有停点。

## 2026-10-14 眼瞳大小续作与宿主入口当前验证

按所有者当前范围，仅继续优化眼瞳大小（IMG1939/1940）。原十项加眼瞳大小共十一项
使用参考滑杆；提肌、眼神矫正、对称和祛红血丝宿主入口为 `enabled:false`，
SDK API及眼部15字段保留。

C40因眼瞳非圆形、轮廓不符被所有者拒绝，不能交付，当前整改中；
整改要求只修改眼瞳并保护其他区域。C40眼部map SHA256为
`8d3feb4b0bd39f0f546e28e9b0de94cb157973402e6b93a5819e6959ee0c832a`。
同版C40 SDK实际执行 **14个不同相关测试/0失败/0跳过**，范围为本轮定向检查。
宿主检查与实际图片验收分别记录：

| 检查 | 实际结果及范围 |
| --- | --- |
| [既有宿主定向结果](.verification/iris-ui-contracts-20261014.xcresult) | **6通过/0失败/0跳过**。 |
| [新增真实UI结果](.verification/iris-real-ui-c38-20261014.xcresult) | **2通过/0失败/0跳过**；UI源码自C38保持，C40未再次修改UI。 |
| C40模拟器原尺寸眼瞳 | 双向四档共8设置，**1通过/0失败/0跳过**；冻结响应、纹理与保护判据全部通过。 |
| C40模拟器预览眼瞳 | 双向四档共8设置，**1通过/0失败/0跳过**；冻结响应、纹理与保护判据全部通过。 |
| C40旧十项回归 | 共20个cap，**1通过/0失败/0跳过**；canonical PNG exact **20/20**。 |

此前将C40原生原尺寸细节视为通过的外观结论撤回。实际工程、数值、纹理和保护检查
通过不能覆盖所有者指出的眼瞳圆度与轮廓失败。效果证据仅覆盖本轮一张已编辑参考
肖像；真实未经编辑零态、美图数值及四档参考曲线未知，不扩大为一般外观质量或完整
美图效果一致。C32及其他历史结果保留原版本、日期与范围，没有全App/SDK回归声明。

此前iPhone13Pro已沿用同一App ID更新，原图实际Metal与独立CPU parity配置为
**1通过/0失败/0跳过**，冻结判据通过；随后preview runner连接hang，设备后断开。
这份原图结果不包含手机预览或面板通过，也不作为当前iPad的验收结论。

所有者随后改用现有iPad第7代/iPadOS 18.7.10。同一App ID的安装、打开及
source round-trip检查均退出0；iPad原图、预览和原生面板三个配置实际各
**1通过/0失败/0跳过**。原图实际Metal与独立CPU parity、原有冻结oracle检查通过，
保留其工程、数值与保护范围，不作为眼瞳圆度、轮廓或外观通过的证据。
本轮聚合回执由相邻SDK的
[眼瞳回执](../docs/validation/EYE_IRIS_20261014.json)维护；C40非圆外观仍判失败，后续C74的限定修复/安装结果分别记录如下。

2026-10-15 C58定向SDK **23/0/0**、448.865s（新材质用例74.125s包含其中），
正确dense public actual CPU/Metal **1/0/0**、42.858s；正常原生原图/预览各
**1/0/0**、36.002s/16.060s。原图冻结numeric、有限shape、声明保护、neutral及
repeats全部通过；旧预览numeric/保护/neutral/repeats通过，但右眼负/正cap中心
漂移2.417508945/2.952131420>2.296617432，shape仍失败。十一帧fixed ImageIO
original-first+source-owner clip的冻结检查离线通过，不是新route原生验收。

C59新CPU API的非整数缩放/color/texture保护失败保留，先前23/6/public1定向通过
不能取消该失败。C61最终fractional三用例 **3/0/0**、4.680s及facade六用例
**6/0/0**、20.553s；新far-white冻结C60 baseline **1case/1failure/0skip**、1.314s，
唯一actual==BV delta139，C61在原断言下通过。当前默认mask=nil基准
先缩原源再做view prefix；原尺寸IR prefix独立，BO精确未变化copy guard不能替代
几何owner。显式原图grid mask保持原prefix基准。C74在C61 SDK rendering source
保持下实际原图/explicit CPU新预览各 **1/0/0**；四份冻结numeric、fixed26 partial-arc、
声明保护/alpha、neutral及repeat协议required均TRUE，完整artifact/source/runtime/
result binding gate通过。新预览右负/正中心漂移1.687788443/.521271475低于原冻结
2.296617432；旧C58离线及旧预览失败仍保留原范围。独立细节复核确认细gray lower
rim（右侧更明显）；一次deep-donor试验变差拒绝，生产源及oracle未改。
这只是单张已编辑肖像及source/CPU新API的有界验收，不是完整circle/semantic mask、
美图等价或population/性能资格。

同一C74源码和实际产物继续完成下列最小相关检查；没有全App/SDK回归：

| C74检查 | 实际结果及范围 |
| --- | --- |
| [旧十项照片](.verification/c74-prior-ten-full.xcresult) | **1通过/0失败/0跳过**；21张canonical PNG及完整RGBA（含alpha）与C40/C53冻结检查点完全一致。 |
| [宿主定向检查](.verification/c74-prior-ten-ui.xcresult) | **6通过/0失败/0跳过**；十一眼项滑杆、四禁用入口、单字段接线、独立历史/neutral及模拟器面板布局。 |
| iPad原尺寸图片 | **1通过/0失败/0跳过**；实际Metal与独立CPU RGBA exact parity，双向四档及重复捕获；原图冻结numeric及fixed26 partial-arc协议通过。 |
| iPad原图网格CPU预览 | **1通过/0失败/0跳过**；双向四档，实际source-first CPU路线；预览冻结numeric及fixed26 partial-arc协议通过。 |
| iPad面板检查与前台重试 | 两次各 **0通过/1失败/0跳过**；初始foregroundActive scene数均为0，未执行布局断言。第二次先以`--activate --terminate-existing`明确打开App，launch退出0后仍失败（0.110s、两处初始断言）；保留两次实际失败。 |

实际使用已有iPad第7代/A10/iPadOS18.7.10，沿用`com.yakang.wanneng1`更新安装，
保留应用数据，未卸载、reset或恢复旧App。输入source round-trip身份一致；两组照片
的四份冻结协议均通过，不把两次面板失败或模拟器布局结果记为iPad布局通过。
生产UI/滑杆本轮未改；本次限定更新已通过同版模拟器六项宿主定向检查，当前iPad
布局和触摸尚未验证，面板harness场景准入问题单独保留。
准确API/原图
网格mask/缓存及指标限制见[单一SDK契约](../docs/sdk/EYE_SHAPE_SLIDERS.md#原图先行的-iris-preview-api)，
当前执行由[眼瞳完成记录](../plans/history/2026-10/A-2026-10-14-eye-iris-reference-delivery.md)拥有。
所有旧失败、冻结协议和单张已编辑参考肖像的范围保留，未扩大为全SDK/App或性能。

## 2026-10-14 嘴部 iPhone13Pro 最终限定验收

所有者明确换到 iPhone13Pro/iPhone14,2/A15，当前 iOS26.4.2(23E261)。
沿用已有 Team/profile、主 App ID 与数据保留安装，不创建签名资源或改变设备设置。
iPad R13 已通过的结果仍限 iPad；两次局域网安装失败和 USB3 前检停点保留。
旧 shadow 测试包在共享缓存中已被替换，故只做一次稳定 `.build` 增量联合签名
构建：exit0，37.882s，临时8源/工程/scheme精确恢复，保存眼App5b612不变。
编译6方法不冒充实际执行。build receipt a5e1002a 保留。

同手机先实际 shadow1/0/0，5.216s、10PNG/16X四档/F2内存身份；冻结dbbe
同freshgeometry控制独立于当前74e renderer，四个actual74e→selectedf160
完整RGBA身份为0。新手机fresh6-first独立原7/7与原生1:1细节通过，summary93cdf1db、
inventory7a76e566、formal8bead1cf分别保留。原数值、保护、matcher、cap不变。

首次最终启动在安装/staging后卡在Xcode基础设施，五个原方法均未开始。
Root只中断该任务已核实PID；取消result中的synthetic failure不是嘴部算法方法失败。
匿名failure8762a3c8及完整失败xcresult保留，0原方法/0PNG。一次有界接续复用相同
签名App/xctestrun/输入，明确arm64与有限超时后实际通过；不据此断言卡顿原因。

最终原五项实际5/0/0：三滑杆契约、两照片（6.544s/6.352s），36PNG＝原34加
fresh dbbe F−两图；14个neutral/M±/F±/X±完整RGBA与direct/selected/repeat精确一致。
summary3e3b503c、inventory22ae9bdf及final arch1 result独立保留。仅两张neutral
PNG实际为RGB/type2，其余34张RGBA/type6；元数据按两个精确role修正，未重渲/改图，
neutral解码alpha全255与source完整RGBA仍exact，原alpha检查及数值门保持。

独立F/X先冻结同手机8控制图，baseline0c3f6215；正式review92fbded9、
provenancedf213d52、numeric5e1785a9。A负收薄辅助两阈值改善.8576/.8020px，
达到原≥.2px，主78/75→77/74；B63/59→63/58且不恶化。X原7/7，A三固定窗增益
3.8451/2.8400/2.8418px，B19/23原span/error门通过；双图F−/X±原生未缩放细节
未见明确新增裂缝、嘴角夹痕、唇缘波纹或鼻底台阶。Root看同原尺寸图同意限定准入。
局部M/F口腔场/像素保持；物理鼻眼RGBA不变。M/F物理场仅诊断（B F−.1030690346px），
不能写成物理场零；X另有物理场零，口腔随整嘴移动。F四档响应限已执行SDK31生成夹具，
不冒充照片四档、触摸或FPS。实际SDK31/0/0含Metal32与public14由SDK记录拥有。

参考仍UNMET：A X40.1951/40.2189/40.2375px低于45.6–68.4；F主仍差21/23px、
辅助差21.8412/23.6440px，MOUTH-REF-01保留。此次仅限定两张720×960预览F−/X与
当前滑杆/保护/身份，不宣称手机GPU、全尺寸导出、一般美图外观、全SDK/App、UI、
性能、温升、耗电或长稳；不提交/推送。完整记录由相邻SDK的
[同一计划完成记录](../plans/history/2026-10/A-2026-10-12-mouth-native-followup.md)拥有。

本轮收尾：原主AppID已安装应用foreground launch实际exit0/PID44189；保存eye App、
四签名artifact仍exact，所有claim finally释放。007/008压缩预览与库存check通过，
本机162项/441152876bytes精确清理，14冻结Mac输入/golden、原始素材/registration、
所有源码/oracle、失败日志/JSON/xcresult及构建保留。设备一个exact shadow空目录
copy退出1，后续shadow/final文件服务读取（含解锁后）仍失败，无法确认设备清空
或当前残留数；final目录copy未执行，旧iPad断连未检查。清理失败与锁屏停点独立
保存；不推断失败因果，不卸载/全容器清除/重建/继续重试。本轮限定验收已归档，
MOUTH-REF-01及MOUTH-DEVICE-MEDIA-01保持明确边界，不提交或推送。

2026-10-15 C74 final owner-device receipt: current App explicitly opens in the
iPad foreground, exit0, with source/signed artifact exact and same-ID data
preserved. Only the independently hash-admitted eye fixture root is targeted:
empty transfer/direct listing report exit1, followed by a separate successful
parent-directory exact-name read returning zero matches, independently proving
that task root absent. Failed cleanup receipts remain unchanged. No other App
data or production source is removed. Physical Panel admission failures remain
unqualified; current simulator iris Panel is part of the six passing hosted
contracts, without a physical touch claim.

## 2026-10-15 脸型美图式横向滑杆

所有者追加授权真实宿主滑杆；本次仅4个宿主生产文件与3个定向测试文件。目录无Git，
改前7文件原字节及SHA保存在本地ignored任务证据。SDK依赖路径、EditorModel历史逻辑、
EditorScreen唯一safeAreaInset、眼鼻嘴生产接线及可用性均未改。脸型9个signed入口居中，
4个unit入口从左端填充；黑底/暗灰轨/白圆与原11眼部参考style共享。

选择已有兼容且空闲iPad Pro11 M4/iOS17.5（40F8BD90-75E6-4D92-95FB-258704E6A3E5），
两次设备阶段均按UDID原子claim、单destination、parallel-testing NO，结束后释放。
稳定.build增量build-for-testing两次成功。首轮8方法实际5通过/3UI失败/0skip：方向/cap/
其他字段保持、连续拖动合并历史、单向/双向track几何、旧眼轨道及底部safe-area通过。
三个UI失败由测试点按采用固定.02而非12pt轨道端点造成：实际读−99，unit约.4显示0却
按exact0预测圆心。检查原生PNG/事件及视频后，仅修测试坐标和同窗口截图映射，保留
±100/0与白245/黑5等原阈值；生产未变。失败记录保留。

同台重建后原3个UI方法实际3/0/0：脸宽/下巴长短/尖下巴/发际线实际点按左右端点、
归零、连续拖动与状态恢复；流畅/V脸白段从左端、左右拖动、undo/redo及按钮可达；
旧眼瞳参考滑杆实际同流程通过。合计8个不同定向方法通过，分属首轮5与修正后3，
不是一次8/0运行。原生生成输入截图已检查：白圆完整、填充起点正确、底边背景连续且
按钮/滑杆避开safe-area。未执行方向/字体/设备矩阵、真实肖像效果、真机安装或全App回归。

本地ignored evidence根.verification/face-slider-ui-20261015：首轮source snapshot
78050ec0bd1fa5b039ad608fb72ec6d5a1c57f1741c28a3605dbbda4ecc29717，修正后
b17857baeb025c1025ede7787aa71a073ddd744915d4a6c667f4c75188a9328c；两次
source在各自构建/执行期间稳定。最终7个修改文件bundle
dfc02c55a4407c1ffe1a63bb653621d7aaf403f9e3f1a9aae78d19fed14afc41。
静态SDK bindings检查56字段/caps通过，设计资源检查通过。算法效果仍由SDK独立计划拥有，
宿主仍连原相邻SDK；本记录不宣称脸型媲美美图、通用耳/发型保护或性能。

## 2026-10-15 所有者要求在iPad运行滑杆版本

按所有者明确真机指令，使用现有myipad/iPad第7代/iPadOS18.7.10；复用既有Team与
com.yakang.wanneng1，稳定.build的Debug真机增量build成功，codesign strict验证通过。
同ID保留数据更新安装成功，foreground launch成功（activatedWhenStarted=true，PID1415）；
未卸载、未改账号/签名/entitlements/设备设置，也未运行真机测试或声明图片效果通过。
沿用现有physical-device claim registry，两个install/launch阶段均原子claim并finally释放；
未操作被其他任务占用的iPad模拟器。App保持前台交给所有者体验；本次没有自动导入原图，
需在App左上角选择照片。宿主仍链接原相邻SDK，新脸型实验未接入。
本地ignored安装/启动回执在.verification/face-slider-ui-20261015/ipad-preview。

## 2026-10-15 两项去双下巴禁用及独立下颌线接线

两项去双下巴保留原字段/位置/图标/旧值与历史，入口置灰禁用。下颌线使用独立
`jawlineShadow` 单向0…100、SDK cap .25，不再跟随下颌角，且不计几何强度总和。
选定包是当前原SDK稳定快照上的最小脸型集成，不整包采用旧实验分支；算法仍在验证。

实际仅已有iPad Pro11 M4/iOS17.5（40F8BD90-75E6-4D92-95FB-258704E6A3E5），
一次12方法/0失败/0跳过：9个hosted覆盖字段独立/禁用守卫/历史，3个真实UI覆盖
双下巴禁用、四个眼入口禁用、流畅/V脸/下颌线单向点按与连续拖动/撤销重做。
原子claim覆盖设备阶段，完成已释放；未新增/克隆/旋转设备或改变字体。
实际截图复核灰色图标文字、下颌线左端原状、轨道填充及底部避让。57字段/cap绑定和
60资源/59图标静态检查通过，SDK与UI源码在build/test期间稳定。

固定build/test源摘要f20ec5ae91fbd712052057fc5388e0bb80cfd02bde11f0a2b011152eaf9be113；
完整selector、xcresult、截图及aggregate保存在ignored的
`.verification/face-jawline-shadow-20261015`。这12项证明宿主交互，不是SDK照片效果、
完整美图外观或全App/SDK回归；此次尚未更新真机。算法后续源码变更另行验证和记录。


## 2026-10-16 — 仓库内迁移与路径验证

所有者授权将宿主移入 `BeautyEditorApp/` 并提交备份；SDK 仍为独立 library，
应用依赖同仓库 `../BeautySDK`。SwiftPM manifest、XcodeGen 配置、Xcode 工程
与文档相对链接已同步；旧工作区不再作为生产依赖。

实际检查：57 项字段/cap 绑定、60 项设计资产（含59工具图标、5个原生符号调用）、
工程 plist、SwiftPM dump-package、README/本文件本地链接、SDK boundary
post-archive 及 self-test 均通过。Xcode showBuildSettings 与 arm64 iOS Simulator
Debug build 成功，禁用签名，复用 `.build`；未启动或安装模拟器。

首轮失败保留其含义：搬迁后的包缓存仍指向旧根目录，三项现存二进制依赖路径
在缓存元数据中精确重定向后解除。通用双架构 build 后因当前 MediaPipe 二进制
缺少 x86_64 符号失败；显式 `ARCHS=arm64 ONLY_ACTIVE_ARCH=YES` 后成功。
本轮不声明 x86_64 支持、真机/UI回归、图片视觉达标或既有未完成效果已修复。
缓存、原图、私有验证素材与结果包未提交。

## 2026-10-16 — 脸型 Debug 延迟、原图识别与预览完成日志

单台已有iPhone15Pro/iOS17.5模拟器，arm64，复用稳定.build；每轮原子claim后释放。
同一已有授权肖像/实际MediaPipe单脸478点/生产PhotoRenderer CPU脸宽−100：
原版10.611s，最终**382.099ms**，完整canonical RGBA与原版**exact**，
仍7920字节变化、无警告。此为单个预览case，不能推广为A15真机或持续帧率。

iOS Debug只优化SDK的BeautyEffects，保留Debug断言/DEBUG/testing，App等仍Onone。
原生实际swiftc参数顺序已检查；source ownership/contour solver的等价缩减不放宽保护。
同时修正provider Data比较导致相同像素被误判不同，改为固定紧行sRGB RGBA8预览比较，
原尺寸导出跳过该比较。每个实际预览任务新增一条12字段preview_render完成stdout，
可区分旧帧/最新帧、耗时、原图保持、取消和稳定失败码，无自由文本或图像/support。

最终`face-preview-no-change/preview-final.xcresult`：**10方法/0失败/0跳过**。
范围：真实负端点+neutral 1、73×97非整行宽度neutral/亮度1、完成日志3、
原松手日志4、旧worker不能覆盖最终帧1。新日志case包含120次更新后最终−.6显示，
请求与当前/显示版本独立、取消换图及SDK/editor/unknown错误的脱敏。
独立离线SwiftPM **7个不同SDK case/0/0**（4 solver逐位等价+3 ownership/actual-stage），
while改动后仅重复3个直接相关case，仍3/0/0；57项绑定和diff检查通过。

失败保留：初次xctestrun格式误读、空sample、嵌套sandbox、async autoclosure编译错误；
中间原生8方法1失败准确揭示neutral identity误判，修复后最终10/0/0。
完整过程与范围见[修复记录](../plans/history/2026-10/A-2026-10-16-owner-editor-face-preview-no-change.md)。
没有重跑全量SDK/App/UI，没有使用所有者反馈照片或安装/测试A15真机；
未重新认定参考效果、任意照片准入、全组合、原尺寸性能或真机流畅度。
最后无复现宏的普通Debug build成功，实际确认Effects优化且Debug断言保留、App仍Onone；
测试后只更新文档，没有重复无关测试。

## 2026-10-17：脸型后五项分支真机交付

用户要求安装新分支供亲自验收。由 `codex/face-five-displacement-analysis-20261016`
当前工作区构建普通 Debug 包，使用本 worktree 稳定 `.build`、既有签名和
`com.yakang.wanneng1`，安装到 iPhone 13 Pro（iOS 26.4.2）。Xcode build、签名校验、
安装及启动成功；启动三秒后确认应用进程仍在运行。未卸载应用、未清除数据，设备 claim 已释放。

本次只做构建与部署检查，太阳穴、颧骨、下巴长短、尖下巴、V脸的真机效果待用户验收；
没有新增全 SDK/App/UI 回归。源码/签名产物摘要及设备安装回执存于本地忽略资料，
具体模型、参考核对和此前定向测试见[后五项 SDK 改造记录](../example-images/参考效果分析/脸型/后五项SDK改造记录.md)。

## 2026-10-17：下颌角、发际线、下颌线改造与真机交付

当前 `codex/face-five-displacement-analysis-20261016` 工作区完成三项模型/范围改造及
本轮参考校幅。下颌角与发际线使用源固定二维场；下颌线为连续宽阴影，支持与这两项
在源着色后一次逆采样。其余未审计几何/纹理组合仍拒绝下颌线。

macOS SwiftPM 108项相关回归通过；最后组件越界与阴影入口修正后，25项直接相关测试
再次通过，共109个不同方法。参考照片的公共CPU/实际Metal、字段/direct输出一致，
单源Vision测量保留模型残差和色域/中性限制，未扩称原生iOS效果或全量回归通过。

复用稳定`.build`与现有签名，普通Debug真机构建及codesign strict检查通过，构建前后
生产源码摘要一致；安装前再次校验源码与签名payload。原子claim内确认设备无需密码，
覆盖安装iPhone13Pro现有`com.yakang.wanneng1`，启动3秒后确认PID58207仍在运行。
未卸载或清数据，claim已释放。三项真机外观、实际触摸与更多照片待用户亲自验收。

完整实现、参考统计、失败修正与能力边界见
[后三项SDK改造记录](../example-images/参考效果分析/脸型/后三项SDK改造记录.md)。

## 2026-10-17：下颌线入口与发际线侧缘反馈修正

当前 worktree 修正源光照入口与颈肤材质佐证、发际线侧缘保护。31 个不同定向方法通过：
首次 30 项为 29 过/1 失败，修正量化窗口竞争误判后 17 项通过，最终颈肤修改后 18 项
直接测试再次通过，其余 13 项相关生产代码未再变更。不扩称全 SDK/App/UI 回归。

同一参考源的真实公共输出：固定入口四分箱中位差从 9.484 降至 3.605/255，原发际线
左右背景窗各 99750 像素，两端均零改变；CPU/实际 Metal/direct 一致，四档无反向，
组合为一次源阴影后一次逆采样。测量限本图 macOS Vision，仍保留参考零态与局部残差。

复用稳定 `.build` 与现有签名，普通 Debug build 和 strict 签名检查通过，127 个生产
Swift 文件构建前后摘要一致，安装前再核对源码和签名产物。按原子 claim 协议覆盖安装
iPhone 13 Pro 现有 `com.yakang.wanneng1`，启动 3 秒后 PID58551 仍运行。未卸载或
清数据，claim 已释放；最终外观和触摸待用户验收。没有新增模拟器或运行全量回归。
完整模型、实际统计、失败和部署范围见[两项修正记录](../example-images/参考效果分析/脸型/入口与侧缘修正记录.md)。
