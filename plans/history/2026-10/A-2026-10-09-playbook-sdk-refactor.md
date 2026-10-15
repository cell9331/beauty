# A-2026-10-09-playbook-sdk-refactor

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex / project owner |
| Started | 2026-10-09 |
| Scope | 在新分支保留既有改动，按 playbook 的计划/执行分离原则，合并现有静图几何准备与 backend 聚合诊断，保持已有能力和像素/失败契约。 |
| Source Request | 所有者要求新建分支、参考 beauty-sdk-playbook，先研究/规划/验证并修正问题，再完整实施有把握的 SDK 重构；新效果须有把握并同步 UI 可用性。 |
| Current Step | 共同geometry stage/有界诊断及parity门禁修复完成；134项不同定向回归、live parity与必要门禁通过。 |
| Verification Policy | 复用 BeautySDK/.build；相关 SwiftPM 测试、backend 静态/自测门禁、SDK-only/归档/存储、文档链接与既有非目标文件摘要核对。不是完整 SDK milestone closeout，不自动运行全量回归。 |

## Research and scope decisions

- 分支 `codex/playbook-sdk-refactor` 从当前 `codex/full-refactor` 创建；已有未提交改动原样保留。实现前的工作树基线包含 2,572 个文件；临时摘要不作为旧里程碑的新签名。
- 阅读所有者原手册 README、docs/00–11、四份文本骨架，结合现行 [架构](../../../ARCHITECTURE.md)、[设计](../../../DESIGN.md)、[dense 契约](../../../docs/sdk/DENSE_FACE_REFACTOR.md)、[项目学习手册](../../../docs/refactor-playbook/README.md)和相关代码/测试。
- 现有 478 点、固定全画布逆网格、最终位移/梯度限制、可见虹膜、双边纹理与 context 复用已实施，不重复换引擎，不直接导入未验证骨架。
- 核实外部 `BeautyEditorApp` 的 54 个工具位置：53 可调用 / 51 个字段；去脂停用，两项没有工具内容的分类保持禁用。UI 标签存在不证明有独立算法或可定义的新功能。playbook 未给出足以推翻 EYE/SEG 终局的新信息；本轮不新增未合格效果，不解除这些灰色入口。
- 生产重构集中在已有静图能力：source-raster 准入/修整、最终控制点、dense 执行和整体平移。计划值与执行像素分层，不扩展 public API、backend、依赖、模型、视频/3D 或语义解析。

## Plan review and corrections (before production edits)

| Initial risk / question | Evidence and corrected plan |
| --- | --- |
| 直接合并 CPU/Metal 完整管线会改变顺序 | CPU 在着色后做 source-raster 准备；Metal 在着色前准备。只抽取同一几何阶段责任，各 backend 仍在原位置传入自己的 raster，不调整着色/纹理/局部修饰顺序。 |
| dense 与 legacy 可能重复采样或丢特殊效果 | 共同准备一次最终控制点；dense 共用 CPU-owned map，legacy 各保留原采样器；整体平移仍在几何之后，不把 source-raster 特殊路线误合成一次普通 warp。 |
| 准入失败可能重新启用代理点 | 发际线/额头/下颌请求仍排除其旧点；头包脸/人中仍根据修整后的原有准入 raster 决定排除；左右轮廓保护与整体平移排除照旧。 |
| canonical 输入或无效/neutral 请求多一次 rasterize | CPU 原有 control-point preflight、尺寸检查、色彩空间和 canonical rasterize callback 保持；无几何仍原路径返回。 |
| 多次 adaptation 和 provider 求值 | Metal still 路线只构建一次 FaceGeometry，prepared stage 只构建一次最终点；Metal 色彩图复用该 face 与 prepared 点，dense 不提交旧几何 pass。 |
| 聚合诊断提取扩大敏感数据面 | 只合并既有四个计数的有界计算；新值只在 backend 请求内，结果不携带像素、点、mask 或路径。 |
| “有把握”不等于新增未开发效果 | 能力盘点与 taxonomy 保持一致；缺少可测新目标的入口不激活。本轮完成指已验证的重构范围，不称全部未知能力已经开发。 |
| 测试范围会不必要扩展 | shared 准备涉及所有已有静图 geometry provider/refiner，所以覆盖这些直接依赖和 CPU/Metal 契约；纹理/局部修饰只跑相关组合/保护，不跑历史研究挑战、全 App、设备矩阵或全 SDK。 |

## Implementation plan

执行中发现既有 parity self-test 用“文件中首个相等断言”作变异；前轮加入的保护测试
也有同一断言，造成变异未击中 neutral 测试且宽泛静态检查误接受。相关脚本与测试在本轮
基线中均未变，因此这是被本轮验证暴露的既有门禁缺口。修正为指定 neutral case 内的
精确像素断言与定点变异，其他测试的相等断言不能代替 neutral 证据；不放宽门禁。

1. 建立直接受影响的 geometry/support/combination、backend/parity 与 facade routing 基线；失败先定位，不把执行成功当像素通过。
2. 新增内部请求内静图 geometry stage，唯一拥有 refinement、source admission、最终控制点、dense 应用与几何后平移；不持久缓存任何请求数据。
3. CPU 与 Metal still 路线接入同一 stage；Metal 色彩图接受已经准备好的 face/点，不重新 adaptation 或再计算同一准入。
4. 在既有 backend diagnostics value 内合并相同有界计数构造；CPU/Metal 共用，保持诊断及错误结果不变。
5. 运行直接依赖的 source-raster/geometry/facade/metadata/protection 与 backend 检查；审查差异与来源摘要，更新契约 owner 和学习手册，记录实际范围。

## Checklist

| Step | Status | Evidence |
| --- | --- | --- |
| Research and capability inventory | `completed` | 原手册、现行 owner/taxonomy、SDK 符号与外部 ToolCatalog 已对照。 |
| Plan validation and repair | `completed` | 上表八项风险均给出保持契约的实现决定；未改生产源码。 |
| Baseline verification | `completed` | 10个相关suite，65 tests / 0 failures / 0 skips；第一次沙盒缓存权限失败未执行测试，复用原缓存后通过。 |
| Shared geometry / diagnostics implementation | `completed` | 四份既有生产源接入内部stage/共同诊断，新增一份stage源；pixel-buffer语义保持。 |
| Regression and review | `completed` | 134项不同定向回归最终通过，实际Metal parity 14/0/0及mutation门禁通过；差异/存储/归档/边界核验。 |
| Record outcome | `completed` | 本文记录范围、过程失败和限制，并入月度完成索引；没有新效果/UI解锁或全量回归声明。 |

## Outcome

- 共同 `BeautyStillImageGeometryStage` 成为 contour/hairline/submental修整、source准入、最终点及几何后平移的单一owner。CPU/Metal静图各自在原来的位置调用，着色/纹理/局部修饰、canonical回调、neutral、extent/alpha及typed failure保持。
- Metal静图只适配一次FaceGeometry并复用一次最终点准备；不再重复运行dense分支的同一准入/点生成。legacy仍用原采样器，dense仍用共享CPU-owned map，retained shader与model原字节未变。
- 两backend共用有界composition counters构造；新overflow回归证明计数界与既有8字段聚合面，不增加raw数据面。
- 修复既有parity静态检查与变异自测的test-order依赖：断言必须属于指定neutral case，额外保护测试不能冒充neutral像素证据。
- 未新增未经验收的效果；77字段、已有cap/default/Codable、taxonomy资格、renderer99/98和外部host53/51映射保持。本轮没有足够依据开发去脂或为无工具内容的分类定义新效果，因此没有改变灰色按钮。

## Executed verification

| Command / inspection | Observed result | Scope |
| --- | --- | --- |
| `swift test --package-path BeautySDK --filter 'BeautyDenseGeometryTests\|BeautyDenseSupportTests\|BeautyDenseCombinationTests\|BeautyGeometryEffectPipelineTests\|BeautyBackendParityTests\|BeautyBackendSafetyParityTests\|BeautyCPUBackendTests\|BeautyMetalBackendTests\|BeautyBackendContractTests\|BeautyEngineBackendRoutingTests'` | 实施前65/0/0；实施后同组65/0/0，并设置`BEAUTYSDK_REQUIRE_METAL_PARITY_EXECUTION=1`。 | geometric mechanics、组合、CPU/Metal像素与错误/容量/facade路由。首次沙盒缓存权限失败没有运行测试，复用现有缓存权限后执行成功。 |
| source-raster/protection/canonical相关SwiftPM filter | 68 tests / 0 failures / 0 skips。 | `RemainingEffectSemanticCandidateTests`、`BeautyEngineCombinedLocalRetouchCloseoutTests`、`BeautyCanonicalStillImageTests`、`BeautySkinTextureHostProtectionTests`、`CPUReferenceGeometryOracleTests`、`FaceContourSmoothRepairTests`（也匹配2项facade修复）、`BeautyHairlineBrowSafetyTests`、`BeautyEngineLocalRetouchCompositionTests`和当时3项新stage测试。实际CPU/Metal host texture输出各执行一次。 |
| `swift test --package-path BeautySDK --filter BeautyStillImageGeometryStageTests` | 最终4/0/0；前三项已在上一组通过，新增诊断overflow项通过。 | no-face、九个source字段拒绝时不恢复proxy/不撤销有效sibling、pose拒绝/后续恢复、border/alpha/repeat与aggregate bounds。前三项首次编译因测试数组推断和Swift参数顺序失败，修正测试声明后通过；没有因此改变生产准入或oracle。 |
| 独立测试身份去重 | **134个不同直接回归全部通过、0失败/0跳过**；不把基线、复跑或parity重叠项叠加。 | 上述三份成功运行中的XCTest身份。 |
| `bash scripts/check-backend-parity.sh --self-test` | 修正后exit0，`backend_parity_self_test_passed`；先前原自测exit1，原因是既有首个断言变异未击中neutral测试。 | 错误证据必须被拒绝，未放宽CPU比较、容差、required Metal执行或无raw输出规则。 |
| `bash scripts/check-backend-parity.sh` | exit0，Metal available=1，parity executed=1，focused tests=14/0/0。 | 实际CPU/Metal像素与determinism/独立engine测试；与直接回归有重叠，单列不重复计入134。 |
| `bash scripts/check-backend-neutral-contract.sh --self-test` | exit0，静态与mutation自测通过。 | backend边界/typed result与聚合诊断契约；未额外执行该脚本的完整CPU-oracle分支。 |
| `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | exit0，两份ZIP/manifest verified。 | 历史归档完整性，不恢复UI。 |
| `bash scripts/check-sdk-only-boundary.sh --post-archive`及`--self-test` | 均exit0。 | SDK-only、retained Metal及现有GPU/API边界。 |
| `python3 -B scripts/manage-example-images.py check` | exit0，27图/30,637,971 bytes，输入8图/预览1图。 | 没有新持久图片。 |
| 生产差异及工作树摘要核对、文档本地链接、`git diff --check` | 1,880份非目标SDK/脚本/归档/冻结文件摘要全部不变，含89份既有Swift源与147份既有SwiftPM测试；160个本地链接/锚点全部可解析，diff无空白错误。 | 本轮四份既有生产Swift源与一个脚本单列；当前工作树同时有独立文档维护，按实际身份保留，不把这些文本变化归给本轮，也不宣称全2,572文件未变。 |

## Remaining limits

这是完成的有界SDK重构，不是新算法里程碑或全功能重写。没有运行完整SwiftPM gate、
外部App/UI全功能、原生iOS或真机测试；旧1098/0/0与native24/0/0仍是旧检查点。
现行生成图限定资格没有提升为一般肖像/语义保护/3D或视频资格；未测时延、温升、
能耗、人口泛化。没有模型下载/训练或外部分发，也未将安全no-op计为新效果成功。
