# A-2026-10-16-integrate-retained-effects

| Field | Value |
| --- | --- |
| Status | `completed`（仅代码整合与本轮处置） |
| Owner | Codex |
| Started | 2026-10-16 |
| Scope | 按所有者新决定将眉/眼形/嘴/鼻/脸型/下颌阴影现有分支代码统一合入main并结束本轮优化。 |
| Source Request | 即使功能未完成也合并，本次到此结束，未来改用新思路；另一个文档线程不处理。 |
| Expected Behavior | 保存所有研究与现有可调用实现，消解并行接线冲突；不将未完成效果改签为达标，不继续算法调参或下载模型。 |
| Current Step | 三个功能分支整合完成；未达标目标终止，已知失败保留。 |
| Verification Policy | 增量构建、按冲突和实际依赖选择参数/路由/共享stage/源保护及CPU-Metal定向检查、边界/归档；不跑全SDK或新照片/真机验收。失败如为已知效果缺口保留，不因收尾放宽断言。 |

保留来源分支和工作区、旧失败/冻结证据、原始参考及文档线程目录；历史archive分支不合并。仅整合既有代码，关闭本轮未达标目标的继续执行，不擅自开始新思路研究。眼瞳暂停决定保持。

## 合并来源与选择

| Source branch | Frozen tip | Result |
| --- | --- | --- |
| codex/eyebrow-reference-refactor | b37f585a | 合并提交4b344306；保留较新的眉材料alpha保护、眼形/嘴/鼻连续map及滑杆。 |
| codex/face-selected-delivery-20261015 | 31e3837a | 合并提交cf5c3528；保留C48、发际线/下颌光度和宽阴影试验。 |
| codex/face-shape-reference-20261014 | a7f7f2d8 | 本记录所在合并提交；保留源材料/轮廓连接研究及其严格脸型map。 |

- 三方同时修改共享stage、CPU/Metal接线与源证明。整合保留原图优先iris和连续眉、嘴、鼻，
  并把脸型源材料证明及下颌源证明接到同一不可变、着色前源图；采样和保护恢复仍读取当前阶段。
- 对11个核心算法模块逐字核对来源：iris、brow、mouth、nose、face map、source ownership、
  source attachments、contour refiner、hairline refiner、jawline shadow及wide-shadow trial均匹配
  所选分支。未改算法系数、原像素oracle、阈值或容差；不同分支的冲突依据在以上明确列出。
- 新增jawlineShadow使public参数78个；一个脸型opt-in生成器使源码RenderCase构造点100个。
  同步五个现行backend/runtime脚本的精确库存数；两个runtime脚本的必需marker对应已保留的
  dispatchThreadgroups，shader及原像素阈值不变。脸型helper测试更新为来源分支已有尖下巴
  slider极性验证，源码审查后仅重绑定该精确哈希；新source-context测试保持来源哈希。
- 来源分支/工作区不删除；archive-sdk-foundation-wip不合并；文档线程目录不暂存、不编辑。

## 实际验证及失败（2026-10-16）

| Scope | Observed result |
| --- | --- |
| swift build --package-path BeautySDK | 成功，增量构建9.43s。 |
| 定向契约/源保护/试验组 | 202 tests / 0 failures / 0 skips，253.202s。 |
| 首次定向测试链接 | 0用例执行；BeautySDKFacadeTests旧对象引用77字段init，链接失败。只删除已确认可重建的该.swift.o，复用同一.build后重编译成功，未清空缓存或冻结夹具。 |
| 初始公开完整端点组 | 已输出眼形4/0/0。眉毛GPU与CPU compact exterior原断言失败；本轮不修，完整矩阵SIGINT结束、退出1，无完整汇总。不把它写成通过或零执行通过。 |
| 最小公开调用补充 | 24 tests / 0 failures / 0 skips，70.788s；覆盖眉入口/invalid恢复、脸型helper/neutral、嘴缺支撑、jawline、iris preview/fractional/原尺寸CPU-Metal及六个nose集成。它不覆盖或取消上述眉失败。 |
| uniform-threadgroup实际Metal边界 | 1 test / 0 failures / 0 skips，含不同宽度、行、neutral及原边缘保护。 |
| backend parity live | 14 focused tests，metal_available=1 / metal_unavailable=0 / parity_executed=1；退出0，与其他执行范围分开计数。 |
| backend parity / neutral / configuration / runtime / feature self-tests | 五个控制自测最终均通过；这是门禁控制验证，不是完整SDK执行。初始旧77字段/99构造点及dispatchThreads marker失败如实保留，按实际接入契约更新精确声明后重跑。 |
| SDK-only boundary live/self-test | 最终均通过；初始拒绝新脸型测试哈希，经逐行审查仅极性/保留字段断言变化后更新精确绑定，未放宽scanner。 |
| 两历史归档verify | 原SHA校验通过。 |

具体执行过滤器（未执行全SDK）：

```text
BeautyParametersTests|BeautyEyebrowSliderTests|BeautyMouthSliderTests|BeautyEyeSliderContractTests|BeautyBackendContractTests|BeautyEffectResolverTests|GeometryConflictResolverTests|FaceSourceRefinementPlanningTests|BeautyStillImageGeometryStageTests|WideJawlineShadowDenseEnvelopeTests|WideJawlineShadowTrialTests|WideJawlineShadowToneComparisonTests|JawlineShadowTests|FaceContourTransitionScopeTests|BeautyFaceSourceOwnershipTests|BeautySourceContourAttachmentsTests

BeautyEngineEyebrowContinuousTests.testInvalidInputFailsBeforeDetectionAndValidSiblingStillRecovers|BeautyEngineFaceSliderTests.testChinTaperReferenceSliderReversesDirectPolarityAndPreservesOtherFields|BeautyEngineFaceSliderTests.testPublicNeutralNoFaceAndTypedFailureRecovery|BeautyEngineMouthReferenceTests.testMissingInnerSupportAbstainsOnlyForBowAndPlump|BeautyEngineJawlineShadowTests|BeautyEngineRetainedIrisIntegrationTests|BeautyEngineIrisPreviewTests|BeautyEngineIrisPreviewFractionalProtectionTests|NoseContinuousIntegrationTests
```

以上分别通过`swift test --package-path BeautySDK --filter '<过滤器>'`执行。
中止组原来选择完整Eye/Brow/Mouth/Face/Jawline/Iris public类及nose integration；
失败不删断言、不改fixture域、不归因成仅有旧问题。当前整合版本的眉保护失败尚未定位。
未重放全部真实照片、原生UI或真机，不宣称完整SDK/美图外观、人口泛化或性能通过。

## 终止范围

眉/眼形/嘴/鼻/脸型/下颌阴影本轮未实现的参考外观与保护目标按所有者明确决定
`closed_with_unmet_objectives`结清。现有代码保留不等于目标达标；已有小范围接受和
失败保留各自日期与输入含义。眼瞳保留版本及灰边限制不变；去脂suspended和v1.25
终局不变。未授权的分割模型提案不再继续，不下载、训练、转换或上传媒体。
新的优化思路需要新范围，本次不自动开始。未推送、未改外部App、不处理另一个文档线程。

### C-2026-10-16-integrate-retained-effects

| Field | Value |
| --- | --- |
| Completed | 2026-10-16 |
| Status | completed for code consolidation; effect objectives closed_with_unmet_objectives |
| Scope | 三功能分支历史和六类效果现有代码统一进入main；源分支、历史archive及所有有效证据保留。 |
| Verification | 构建、202定向、24最小公开、1线程分组及单列14 actual parity通过；眉公开保护失败仍在，未签全量/外观。 |
| Limits | 域外保护、外观幅度、源材料识别及照片失败均未修复；本轮结束，后续另定新思路。 |
