# 美颜编辑器

所有者自用的独立 iPhone App，Swift 6 / SwiftUI / iOS 17+。
按 [Figma 设计](https://www.figma.com/design/l4srrGA4qSkYGT09nuAxXz) 的 12 个编辑状态实现，
直接调用 `project.yml` 中配置的所有者本地 SDK 包。图片在本机处理。

## 打开与运行

在 Xcode 打开 `BeautyEditor.xcodeproj`，选择 `BeautyEditor` scheme 和已有兼容设备运行。
当前宿主位于仓库内 `BeautyEditorApp/`，SDK 使用同仓库 `../BeautySDK`。
`Package.swift`、`project.yml` 与生成工程均使用此相对路径，不依赖旧脸型工作区。

工程已生成，无需先安装 XcodeGen；修改工程描述后可以运行 `xcodegen generate`。
保持使用 `.build` 作为这个 checkout 的稳定 DerivedData，不例行 clean。
当前 MediaPipe 模拟器二进制使用 arm64；命令行通用目标构建需显式使用
`ARCHS=arm64 ONLY_ACTIVE_ARCH=YES`，本轮未验证 x86_64 支持。

从相册或文件选择一张照片 → 切换分类、选择工具、拖动滑块 → 按住右侧对比原图 →
勾选确认 → 保存到相册或用系统分享保存 PNG。顶部提供撤销、重做、重置和更换照片。
确认后“继续编辑”可开始下一次调整，取消会恢复最近一次确认的参数。

模拟器使用 `com.yakang.beautyeditor.local`。真机配置复用现有 Personal Team 和
`com.yakang.wanneng1`；安装到手机会替换该 ID 当前对应的 App，因此真机安装前应先
说明替换关系并保留现有数据。2026-10-11 按所有者授权在 iPhone 13 Pro 安装并验证
鼻部候选；2026-10-12 账号/签名已恢复，iPad 已更新安装并完成三项鼻部 Release
原生复验，同时修复 A10 GPU dispatch 兼容崩溃。
实际构建、设备和验证范围见 [VALIDATION.md](VALIDATION.md)。

## 设计与能力边界

- 12 张画板是同一编辑页的六个分类及横向滚动状态：脸型、比例、眼睛、嘴唇、鼻子、眉毛。
  基础布局、原 60 个 SVG 资源、粉色选中态、背景保护和底部确认栏来自设计稿。
  所有调节滑杆按当前所有者要求统一为白底、浅灰轨道、浅灰描边的白色拇指；脸型和眼部有效段为粉色。
  眼部入口按本轮效果参考补齐并重排，未更改页面布局。
  `design-assets.json` 保留节点、尺寸与内容摘要，无临时资源 URL 或设计稿肖像副本。
- 目录保留59个工具位置；除既有去脂外，提肌、眼神矫正、对称、祛红血丝、去双下巴和
  去双下巴Pro现置灰禁用，当前52个入口可选。禁用仅作用于宿主入口，既有字段与SDK API
  保留，SDK眼部15字段不减少。
  下颌角使用 `jawSlim` 双向形变；下颌线独立使用 `jawlineShadow` 的 0…100 单向明暗控制，
  零位在左端，右侧增强下颌下方阴影，不改变下颌角参数；
  眼部上扬/眼尾上扬共享 `eyeTailLift`，数值同步。原「眼睑大小」改名「眼高」，保留工具 ID、
  独立连接 `eyeHeight`；「眼瞳大小」连接 `pupilSize`。新增五个眼部入口使用 iOS 17 支持的
  SF Symbols，已有 60 个 SVG 资源保持原字节。
  具体字段、范围与说明见 `Sources/ToolCatalog.swift`，SDK taxonomy 是算法语义 authority。
- “青管理”“3D 塑颜”在画板中只有分类标签，没有对应工具内容，保留但置灰禁用，不弹提示。
  “去脂”同样置灰禁用，参数始终为零；model 层直接调用也静默返回，不改变选择或历史。
  提肌、眼神矫正、对称和祛红血丝因本轮缺少参考，暂时置灰禁用；本轮不调整这些SDK算法。
  按所有者要求，去双下巴与去双下巴Pro保留原位置、图标、范围和字段，但不可选择或设置
  新值，静默返回；既有参数与撤销历史保留，不自动清零。脸宽、太阳穴、颧骨保持当前接线。
  “整体”为只读范围说明，没有单侧选择能力。不会重开已结束的算法研发。
- Pro/限免/OFF 是参考视觉标识；没有账号、订阅、收费或解锁服务。
- 单向参数使用 0…100，双向参数使用 −100…100，分别映射至该字段 SDK 已准入的安全上限及其负值。
  眼睛大小、上下、眼高、长度、眼距、眼瞳大小、下至、眼尾、倾斜、内眼角、外眼角使用
  SDK `BeautyEyeShapeSlider` 的独立 −100…100 映射，零位居中；大小/眼高/长度/眼瞳右侧增大，
  眼距右侧增宽、上下右侧下移；倾斜右侧外眼角向下、眼尾上扬右侧外眼角向上。
  当前保留眼瞳大小已有实现及已知限制；提肌、眼神矫正、对称和祛红血丝入口禁用，
  SDK接口保留。
  十一项（大小、上下、眼高、长度、眼距、眼瞳大小、下至、眼尾上扬、倾斜、内眼角、外眼角）
  使用参考滑杆几何：44pt触摸区域内
  白底、3pt浅灰轨、20pt白圆拇指及6pt灰色中心圆点；拇指的浅灰描边和轻阴影使其在白底上可辨识。
  粉色有效段只从零点延伸到当前拇指，白圆中心与填充/点按使用同一几何；12pt端点内距让20pt圆外再留2pt。
  参考十一项不显示旧常驻数值，可直接点按轨道或从任意位置连续拖动，参数保持浮点精度、
  不按整数吸附；辅助功能读数四舍五入，VoiceOver增减一步为1个显示单位。
  SDK方向与安全cap仍由helper拥有，未添加曲线或按滑杆样式改变算法强度。
  这十一项共用参考滑杆，面板结构保留。
  六项鼻部滑杆均为 −100…100，零位居中；例如鼻翼±100对应±0.35、山根±100对应±0.25。
  参数从init/Codable到planning/backend均保留负值；大小/鼻尖/翼/根/梁正向收缩、负向扩张，
  提升正向上移、负向下移。dense大小主要调整整体横向宽度并保持鼻底高度；鼻尖独立调整鼻球。
  山根/鼻梁使用不同的上部/中段连续宽度场，仍无3D高度/专用光影。
  单向滑块的中性位置在左侧；双向值保留正负方向。每个字段保留独立请求值及完整滑块范围，
  不再按旧总和1.0截停后选工具，也不提示组合额度。478点实际网格自动限制位移/梯度/姿态；
  源像素相关字段、刚性平移及macOS legacy仍有各自保守准入，任意组合不保证实际位移不减弱。
  别名共享同一字段，旧字段与撤销状态不被后选工具覆盖。
- 系统状态栏、原生照片/文件选择与系统分享由 iOS 呈现；实际输入图片等比显示，补黑边，
  不通过拉伸或裁切伪造画板中的同一张肖像。顶部导入/撤销和确认后的保存栏是完成编辑流程所需的补充。

这里交付的是本地编辑宿主及已验证的接线。它不改变 SDK 各效果的资格、语义局限或停用状态，
也不声称每个参数都有独立算法、所有照片都能识别，或具备商业视觉质量。

## 脸型参考滑杆（2026-10-15）

脸型保留13个现有入口，其中11个可选入口复用参考滑杆几何：白底、3pt浅灰轨、20pt白圆，44pt触摸范围，
可点按或从任意位置左右连续拖动，保留浮点精度。脸宽、小脸、太阳穴、颧骨、下巴长短、
尖下巴、下颌角、发际线使用−100…100及中心零点；V脸、面部流畅、下颌线使用0…100，
粉色有效段从左端原状延伸，双向段从中心延伸。两项去双下巴保留0…100字段范围但入口禁用。
端点内距12pt，旧常驻数值隐藏，
VoiceOver仍可读当前值并逐单位调整。

方向与现有SDK安全cap保持一致：脸宽右收窄、小脸右缩小、太阳穴右饱满、颧骨右收窄、
下巴长短右缩短、尖下巴右变圆、下颌角右收窄、发际线右下移；V脸/流畅右增强，
下颌线右侧只增强独立阴影。
下颌角与下颌线分别保存参数。尖下巴通过当前 `BeautyFaceShapeSlider` helper映射为负SDK值，右侧变圆。
眼鼻嘴字段、禁用资格、拖动合并撤销与底部
safeAreaInset保持。宿主直接构建同仓库当前SDK源码，包含所有者已决定保留的实现与其未达标限制；算法是否已安装及实际通过范围
见VALIDATION，不按滑杆或按钮完成宣布美图外观或一般区域保护资格。

## 当前眉部接线（2026-10-16）

六个既有眉工具统一使用当前 SDK `BeautyEyebrowSlider`，均为 −100…100、零位居中。
粗细、长短、间距、眉头间距右侧增强；倾斜右侧使外端向下，SDK 字段为负值；
眉峰左侧压平、右侧增强。SDK cap 均为 .25，参数反算、切换工具和撤销/重做沿用同一 helper。
本次不增加工具入口或改变 SDK 已记录的效果资格及保护限制。

## 实现责任

- `EditorModel` 在 MainActor 管理导入、参数、50 步撤销、拖动合并、确认事务和导出状态。
  预览以16 ms限制启动频率，初次立即发起；同一时间只运行一次渲染，并保留一个可被替换的最新请求。
  松手取消待启动计时器并提交最新值；若已有render运行，完成后立即处理最新请求。
  同一连续拖动合并为一步撤销。16 ms只限制启动间隔；实际计算较慢时自然降低频率，不保证帧率或输入到显示延迟。
  拖动中按顺序显示已完成帧，随后处理最新值；换图/取消的旧 worker 不能覆盖新会话。
  失败保留最近有效图片与参数，调试图像版本与请求参数版本分别显示。
- `PhotoRenderer` actor 串行拥有 `BeautyEngine` / CIContext / Vision mask。每次从未修改的
  导入图计算，交互预览最长边 960 px，导出重解码原尺寸；EXIF 八种方向只归一化一次。
  通常预览通过 SDK 显式固定图片 token 深拷贝缩略图栅格，按照片及 CPU/Metal engine 隔离。
  非零眼瞳预览是当前整改例外：独立CPU engine/token绑定原图，显式调用
  [source-first iris preview API](../docs/sdk/EYE_SHAPE_SLIDERS.md#原图先行的-iris-preview-api)，
  原尺寸iris prefix独立，默认mask=nil基准先缩原源再做view color/texture/refiners。
  同原prefix的BO缩图仅以精确未变化RGB跳过复制，original-owner仍唯一授权clip；
  其后剩余geometry一次，其他参数快照保留。原图grid显式mask保持原prefix基准，
  不借mask到view。零眼瞳沿用原缩略图路线，不使用新GPU入口。
  usable/noFace 检测按用途与 detector raster 复用；partial/不可用仍重试，不借旧点。
  换图释放CPU/Metal缩略图及独立original-iris的token/支撑；release/reset使各handle失效。
  参数变化仍从各自不可变source计算，不累积形变；导出用原尺寸fresh检测，
  不把960px预览支撑用于原图。debug额外复检、背景合成和异步版本门禁保留。
  需要检测的prepared结果以 `beauty.detection.preparedReuse` 0/1标记首次/命中。
  这没有新增视频导入、实时摄像头、时序滤波或fps/设备性能声明。
  合适的非模拟器输入复用现有 SDK Metal 后端；中性及模拟器走 CPU，
  Metal 的 typed 输入失败仍回退 CPU。包括山根在内的 dense 鼻部连续形变由
  CPU 拥有，CPU 与所选 Metal 后端共用该采样实现；没有新增 shader 或后端。
  iOS 人脸检测由 SDK 的固定 MediaPipe 1.1.0 / 478 点执行，不回退旧 Vision 人脸检测；
  系统 Vision 仅继续用于人物分割。原平台失败记录按当时 provider 保留。
- 顶部关键点图标或菜单「关键点调试」开关显示青色原图圈、黄色当前点。原图点按照片缓存，
  拖动/渲染期间暂停当前点复检并清除过期叠加，松手且预览稳定后只复检最终当前图。
  原图点继续按照片复用，版本不匹配的异步结果不显示；关闭调试即清除点。
  点与实际等比图片共享坐标投影，包含黑边偏移。它们通过 SDK 的 owner-only
  `OwnerDiagnostics` SPI 独立复检，复用渲染的生产 adapter / 固定模型：iOS 显示
  MediaPipe 478，macOS 辅助程序保留 Vision。诊断实例在 actor 上单独串行复用，
  不改变渲染 engine 的检测选择状态；输出按模型索引排序，不翻转 top-left 坐标。
  它们不是 SDK 已应用的形变控制点。面板显示实际模型名称、点数、版本、尺寸、耗时、后端、
  当前 SDK 字段值、组合项数及检测/警告原因；无有效点时显示零，不画伪造点。
  耗时只包含本次渲染和像素实例化，不包含排队及额外的关键点复检。
  额外检测只在开启调试时发生，点不写入照片、导出文件或持久日志。
- 背景保护通过系统 Vision 从原始预览分割人物，再以原图作为背景显式合成；mask 仅在内存中。
  识别失败不会显示“开启”，软边缘不构成像素级精确人工蒙版；它不识别同色贴片或完整唇部保护语义。
- `EditorScreen.safeAreaInset` 唯一负责底部内容占位与避让。面板的白色装饰背景单独延伸到容器底边，
  不硬编码 Home Indicator 高度。滑块和底部按钮有 44 pt 点击区域。
- `PhotoLibraryWriter` 只在点击保存时请求 add-only 相册权限；系统 PhotosPicker 不请求整个相册读权限。
  分享使用系统 activity controller；私有临时 PNG 在关闭分享后删除。导出为 upright sRGB PNG，
  不复制源 GPS、拍摄设备或文件名。没有上传、分析埋点、持久编辑数据库或用户照片日志。
- 文件先做 32 MiB 上限检查；ImageIO 检查单图、尺寸、方向和 RGB 色彩，最多 5000 万像素。
  SDK 仍执行自身资源/输入/计算预算 admission。全尺寸失败会提示，保留编辑状态。
  编辑状态在内存中，退出 App 后不恢复。2026-10-12 已在所有者 iPad 上验证鼻部预览、原尺寸导出和实际 CPU/Metal 输出，见 VALIDATION；iPad UI 布局、横屏和超大字体专项仍未验证。

## Demo 滑杆松手日志

每个可调工具在手指于控件内或控件外抬起时向控制台打印一条
`[BeautyEditor][slider_release] {JSON}`，Debug和Release均可用；在Xcode控制台搜索该前缀。
包含UTC时间、分类、工具ID/名称、SDK字段、手势初值/最终浮点值、滑杆范围、实际SDK请求值/cap、
参数版本、已显示预览版本、预览待更新标志和背景保护开关。`value`是显示范围内的调节值，
`sdkValue`是映射后的SDK请求值；`previewPending:true`表示最终请求尚未显示，不能当成效果已完成。

`slider_release`在连续拖动时不逐帧打印；一次手势即使数值没变化也只打印一次。取消触摸、切换工具/分类、
进入后台和VoiceOver的非触摸收尾不冒充手指松手。原来的历史合并与松手flush保持。
日志采用固定字段白名单，只写stdout；App不写日志文件、不上传、不使用OS日志持久化，
不打印照片/路径/文件名、EXIF、关键点/蒙版或原始错误。SDK自身的诊断配置与存储边界不变。

## 验证

实际执行、截图检查与限制见 [VALIDATION.md](VALIDATION.md)。默认测试输入是代码生成图，
不是随包附带的私人肖像。DEBUG 仅提供 `BEAUTY_TEST_IMAGE` 环境注入，与正式导入走相同的
有界解码路径；Release 不编译该入口。

```bash
python3 -B scripts/check-design-assets.py
python3 -B scripts/check-sdk-bindings.py
xcodebuild -project BeautyEditor.xcodeproj -scheme BeautyEditor \
  -destination 'platform=iOS Simulator,id=<已有设备 UDID>' \
  -derivedDataPath .build -parallel-testing-enabled NO \
  -maximum-concurrent-test-simulator-destinations 1 test CODE_SIGNING_ALLOWED=NO
```

额外的所有者肖像验收：将有权本地使用的正面肖像临时放到
`/private/tmp/beauty-editor-owner-check.png`，以
`OTHER_SWIFT_FLAGS='$(inherited) -DBEAUTY_OWNER_PORTRAIT_CHECK'` 运行 App 测试。
该组分别检查人脸变化、鼻子四档/连续组合/关键点复检、重复性与背景侧边区域不变；
**本台 iOS 17.5 模拟器的背景保护正例和持续 Vision 鼻子正例失败**，
系统分割返回无效蒙版；连续独立人脸检测会产生越界点。App 拒绝无效 support。
完整启用这组测试仍会明确报这些失败，
不能用基本交互测试的通过覆盖它。背景正例在同一生产 renderer 的 macOS 路径通过，
不冒充 iOS/真机通过。参考 ROI 针对本轮输入，
换图时须先调整 oracle，不能把脚本退出零等同于任意图片效果合格。结束后删除临时输入。

macOS 的独立像素检查复用完全相同的生产 renderer 文件，输出聚合 JSON，不输出图片/蒙版：

```bash
swift run --scratch-path .build/pixel-check BeautyEditorPixelCheck <有权使用的本地输入>
# 全部可用控件的独立接线诊断（像素变化不等于效果资格）
swift run --scratch-path .build/pixel-check BeautyEditorPixelCheck <有权使用的本地输入> --audit
# 六个鼻子工具四档、组合保留、点复检、CPU/Metal/透明回退及原尺寸导出
swift run --scratch-path .build/pixel-check BeautyEditorPixelCheck <有权使用的本地输入> --verify-controls
```

同仓库 `BeautyEditorApp/` 拥有 UI，`BeautySDK/` 保持独立 SwiftPM library 且不依赖宿主。没有源码、模型或权重的外部分发。

## 嘴部滑杆契约（2026-10-11）

大小、宽度、上下、倾斜、左右、M唇、丰唇、微笑均为 −100…100，零位居中；
白牙仍为 0…100。九项统一通过 SDK `BeautyMouthSlider` 映射和反算，
选择工具、撤销/重做和恢复参数时方向一致。向右依次为缩小、加宽、上移、
顺时针、右移、增强M唇、丰唇、上扬微笑及增白；大小及上下在 helper 中反向，
直接 SDK `mouthSize` 仍为正向放大、`mouthYPosition` 仍为正向下移，其他字段保持直接方向。
各项安全cap未提高；布局、照片输入和预览调度不变。本记录说明接线契约，
不授予与参考完全一致的外观资格；本轮实际验证状态见 VALIDATION。

## 眼部 C32 真机交付（2026-10-13）

所有者继续授权后五项参考优化并解锁现有 iPad 后，最终 C32 已更新安装到
`com.yakang.wanneng1` 并成功打开，复用现有 Team/profile，保留应用数据。
十项既有眼部 signed 滑杆继续把 SDK −1…1 映射为显示 −100…100；
本轮交付修复 SDK 后五项的源 RGB 局部三行注册，前五项整体眼形变及宿主 UI 不变。

同台 iPad 第7代/A10/iPadOS 18.7.9 的原尺寸20端点全部实际选择 Metal，
与独立 CPU 输出 RGBA 完全一致；725×960 CPU 预览覆盖后五项双向四档40设置。
冻结 V2 参考判据、固定核心保护与限定原生细节复核通过，前五项10端点及未受影响的
眼尾/倾斜/内眼角6端点与实际 C28 PNG exact。输入仍只有一张已经编辑的参考肖像，
缺共同未经编辑零态、美图数值及四档曲线；本记录不扩大为一般肖像、完整美图外观、
完整语义蒙版或真机性能资格。精确范围与保留产物见 [VALIDATION.md](VALIDATION.md)。

## 眼瞳大小当前整改状态（2026-10-14）

本轮仅继续眼瞳大小（IMG1939/1940）。C40因眼瞳非圆形、轮廓不符被所有者拒绝，
不能交付，当前整改中；整改要求只修改眼瞳并保护其他区域。此前原生原尺寸细节的
外观通过结论撤回。

2026-10-15 C58原图的冻结numeric、有限shape与声明保护通过；旧预览右眼正/负
中心漂移仍超冻结界限，未合格。十一帧original-first+owner-clip的离线检查通过
只属离线证据。C59非整数缩放保护失败保留；C60修正default view baseline并实际
通过fractional2与facade6；C61最终fractional3及facade6通过，C60新far-white
baseline失败保留。C74在SDK rendering source不变下实际原图/explicit CPU新预览各
1/0/0，四份冻结numeric/fixed26 partial-arc/声明保护/alpha/neutral/repeat及完整
binding gate通过。新预览右负/正中心漂移1.687788443/.521271475在原界限内。
独立复核仍见细gray lower rim，deep-donor试验变差已拒、未改生产源或oracle。
旧十项照片及宿主六项定向检查实际共 **7/0/0**，21张canonical PNG及完整RGBA与
C40/C53检查点一致。C74已沿用同一App ID更新现有iPad并保留应用数据；实际原图
Metal/独立CPU exact parity、原图网格CPU预览各 **1/0/0**，四份冻结图片协议通过。
本次iPad面板两次各 **0/1/0**，均在初始前台scene数为0时失败；第二次先明确
foreground launch成功，仍未执行布局断言。当前iPad布局或触摸效果未验证。
这些检查不声明完整circle/semantic mask、美图等价、泛化或性能。API与缓存约束由
[SDK眼瞳契约](../docs/sdk/EYE_SHAPE_SLIDERS.md#原图先行的-iris-preview-api)拥有。

此前C40检查点的宿主六项定向检查 **6/0/0**、两项新增真实UI检查 **2/0/0** 保留实际范围，
UI源码自C38保持。C40原尺寸及预览双向四档的冻结响应、纹理与保护判据通过，
旧十项20个cap与冻结canonical PNG exact。这些工程结果不证明眼瞳圆度与轮廓合格；
输入仍只有本轮一张已编辑肖像，美图四档曲线未知。

此前C40设备检查点，所有者改用现有iPad第7代/iPadOS 18.7.10，同一App ID更新安装及打开成功。
iPad原图、预览和原生面板三个配置实际各 **1/0/0**，原图实际Metal与独立CPU输出
一致、冻结判据通过；三配置通过不能覆盖C40外观失败。精确范围见 [VALIDATION.md](VALIDATION.md)。

2026-10-15 C74 final owner-device receipt: current App explicitly opens in the
iPad foreground, exit0, with source/signed artifact exact and same-ID data
preserved. Only the independently hash-admitted eye fixture root is targeted:
empty transfer/direct listing report exit1, followed by a separate successful
parent-directory exact-name read returning zero matches, independently proving
that task root absent. Failed cleanup receipts remain unchanged. No other App
data or production source is removed. Physical Panel admission failures remain
unqualified; current simulator iris Panel is part of the six passing hosted
contracts, without a physical touch claim.
