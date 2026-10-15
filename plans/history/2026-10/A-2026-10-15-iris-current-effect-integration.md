# A-2026-10-15-iris-current-effect-integration

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-10-15 |
| Scope | 按所有者新决定保留当前眼瞳效果、暂停进一步灰边优化，单独整合至main。 |
| Source Request | 眼瞳暂时不弄，保留现在效果，合并main并写文档。 |
| Expected Behavior | 保留源空间等比径向眼瞳、保护与原图优先CPU预览；记录缩小灰边已知限制，不宣称美图达标；不带入其他未达标参考map。 |
| Current Step | 选择性整合及定向验证完成，随本记录提交并合入main。 |
| Verification Policy | 现有23虹膜/5材质/6预览/3分数缩放保护及参数/路由/组合/共享stage直接依赖定向测试，边界/归档与实际CPU/Metal一致性；不全量或新真机验收。 |

保留原失败阈值、旧回执与原算法文件字节；只适配main既有兄弟几何接线，不引入未达标眼形/眉/嘴/鼻/脸参考连续map。不新开研究、不下载模型、不修改外部宿主；原开发分支保留。当前授权仅本地合并与文档，不自动推送。

## 集成核对

- 来源分支保留：`codex/eyebrow-reference-refactor`。重映射源SHA256 `797bcd44615cf1120c07037bcbafd46d0f17ca89fcd8c0b3505f141d4f0f1db8`，与原分支逐字一致。
- 原23项iris测试SHA256 `f94a7ff22d3ba4268114163f35d93733b072f842d6e3dfce551066fde62349f9`不变；5材质、6预览、3分数缩放文件也均逐字一致。
- 必要依赖截至已完成`d9ba5921`：固定照片快照/检测复用、共享静图stage、组合强度独立与owner诊断；不包含其后的脸/鼻参考变更。
- 相比d9ba5921，鼻/嘴/眉provider、Metal backend及检测接线无差异；只保留主线兄弟几何。参数/后端/冲突预算仅给pupilSize增加signed语义。
- preview的原图owner/resize保护算法保留，仅将后续连续参考map调用适配为main已有共享几何。新增单项公开CPU/Metal方向、保护与重复性检查，不改原验收阈值。
- SDK-only live/self-test与两归档校验已通过；算法/测试source精确核对及新guide本地链接通过。

## 实际验证（2026-10-15）

| Command / scope | Result |
| --- | --- |
| `swift test --package-path BeautySDK --filter 'BeautyIrisScaleRemapTests\|BeautyIrisExposedScleraTests\|BeautyEngineIrisPreviewTests\|BeautyEngineIrisPreviewFractionalProtectionTests'` | 37 tests / 0 failures / 0 skips，901.470s。原23+5+6+3断言保留。 |
| `swift test --package-path BeautySDK --filter 'BeautyParametersTests\|BeautyEffectResolverTests\|BeautyBackendContractTests\|GeometryConflictResolverTests\|BeautyPreparedStillImageTests\|BeautyStillImageGeometryStageTests\|BeautyDenseCombinationTests\|BeautyGeometryEffectPipelineTests\|BeautyEngineRetainedIrisIntegrationTests'` | 133 tests / 0 failures / 0 skips，含原尺寸双向iris实际CPU/Metal、方向、源定义眼区外保护、neutral及重复。 |
| `swift test --package-path BeautySDK --filter BeautyOwnerLandmarkDetectorTests` | 3 tests / 0 failures / 0 skips，仅验证随已完成依赖保留的SPI。 |
| `bash scripts/check-backend-parity.sh` | 14 focused tests；退出0，metal_available=1 / metal_unavailable=0 / parity_executed=1。与上述范围分别记录，不相加称不同用例。 |
| boundary `--post-archive` / `--self-test` | 均退出0；仅增加精确审查的iris预览/公开整合测试哈希与相应变异检查，不开放新的GPU API。 |
| archive verify | 两归档原SHA校验通过。 |
| preserved-source / guide links / diff | 原算法及四个既有测试文件逐字匹配原分支；本地链接与暂存空白检查通过。 |

没有完整SDK、原照片重新验收、外部宿主构建/安装、UI触摸或设备性能新结果。
新增参数测试只把pupilSize移出旧positive-only矩阵，单独核对signed/Codable/cap；
其他字段规则未变。未改原23虹膜及其材质/预览保护阈值。

### C-2026-10-15-iris-current-effect-integration

| Field | Value |
| --- | --- |
| Completed | 2026-10-15 |
| Status | `completed`（保留现版本、选择性合并与文档范围） |
| Scope | 当前源空间眼瞳与显式原图优先CPU预览，及已完成的必要基础依赖。 |
| Rationale | 所有者决定暂缓继续优化，保留当前效果，不等候灰边修复。 |
| Files | IrisScaleRemap、IrisPreviewCutpoint、共享stage/iris signed接线、定向测试及所属owner文档；其他参考map不纳入。 |
| Verification | 上述37、133、3及单列14项一致性检查通过；增量构建成功。 |
| Limits | 极值缩小灰边/短线未解决，未宣称媲美美图或一般分割正确性；优化暂停。未推送、未改外部宿主，未删除原开发分支。 |

结果：保留当前眼瞳版本；不是把失败改为达标，也不重开SAM/接触边界研究。
原失败及旧检查点仍在来源分支的日期记录中，本轮不覆盖或重签。
