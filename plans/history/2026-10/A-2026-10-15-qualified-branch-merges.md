# A-2026-10-15-qualified-branch-merges

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-10-15 |
| Scope | 审核八个未合并本地分支，仅合并完成且验证通过范围。 |
| Source Request | 用户要求已完成且验证通过先合并main，未达标效果保留。 |
| Expected Behavior | main保留历史边界；不导入最新未达标参考效果、归档UI或未验证候选。 |
| Current Step | 已完成两次本地合并及最终来源/排除核对。 |
| Verification Policy | 对比提交/补丁等价、完成记录；检测映射、dense几何/保护、图像资源及美肤公开像素oracle定向回归；归档、SDK边界、依赖变异检查及diff。不扩大为完整SDK或新真机验收。 |

保留原始参考本地副本和所有分支，不推送。full-refactor包含face-parsing祖先；后续四分支含未达标眼眉嘴鼻参考效果，禁止整体合并。archive快照明确禁止整体合并。remaining三个提交git cherry全部为等价已存在补丁，仅考虑无内容变更的祖先关系合并，保留main较新状态。

## 提交前验证（2026-10-15）

- 合并输入：main `6c392e6d`；full-refactor `5348c9ad`，其祖先包含face-parsing `efa4e4f7`。源实现与候选分支一致，无算法补写。
- 定向命令：`swift test --package-path BeautySDK --filter 'BeautyImageContextsTests|MediaPipeAdapterTests|VisionFaceDetectorTests|BeautyDenseGeometryTests|BeautyDenseSupportTests|GeneratedSkinTexturePublicOracleTests'`：选择70项，首次67实际通过、3项Vision opt-in跳过，0失败。
- 显式开启原Vision开关后 `BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 swift test --package-path BeautySDK --filter VisionFaceDetectorTests`：36/0/0；前次3个跳过均实际执行通过。两次去重70个用例均通过，不把首次skip抹除。
- `bash scripts/check-backend-parity.sh`：14定向用例，退出0；`metal_available=1 metal_unavailable=0 parity_executed=1`。
- `bash scripts/check-sdk-only-boundary.sh --post-archive`、`--self-test` 与两归档 verify 均退出0。
- `python3 -B scripts/validate-sdk-dependencies.py`、`--self-test`通过（11变异拒绝）；最初用不支持的`--help`返回invalid arguments，随后按脚本实际入口运行成功，无修改脚本。
- 历史完成记录1098/0/0仅为2026-10-09检查点；本次未重跑完整SDK、iOS/真机或美图外观验收，不重新签发历史资格。
- remaining三组稳定patch-id完全相同：cf989352=a489a6a7、caedad45=1d34097f、9dee34bd=8dddcec5。不能普通三路合并旧计划/测试冲突而回退现行边界；只用ours记录祖先关系，合并前后树必须相同。

## 最终处置

| 分支 | 结论 |
| --- | --- |
| codex/face-parsing-coreml-evaluation | 随full-refactor祖先进入main；现行模拟器背景失败记录保留，不导入新CoreML候选。 |
| codex/full-refactor | a16bc56d合并已完成的固定MediaPipe/静图基础改造；测试与现有有界资格保留，非完整美图外观声明。 |
| codex/remaining-effect-qualification | 4a7d0bad只补记等价补丁祖先；与合并前tree完全相同。 |
| codex/archive-sdk-foundation-wip | 保留，ARCHIVE_SNAPSHOT明确禁止整体合并；旧UI和未验证WIP不导入。 |
| codex/eyebrow-reference-refactor | 保留，眉严格保护未通过、眼瞳灰边未达标、嘴部重做未完成。 |
| codex/face-selected-delivery-20261015 | 保留，与下两分支同在15f6e46d，包含未结清脸/鼻参考外观目标。 |
| codex/face-shape-reference-20261014 | 保留，同上；分支名不能替代验收证据。 |
| codex/playbook-sdk-refactor | 保留，同上；不能因祖先基础工作通过而整体导入后续未达标效果。 |

### C-2026-10-15-qualified-branch-merges

| Field | Value |
| --- | --- |
| Completed | 2026-10-15 |
| Status | `completed`（八分支审查与选择性合并范围） |
| Scope | 两次合并使三个分支祖先已纳入main，五个分支保留。 |
| Rationale | 隔离已完成基础改造、重复历史与未达标参考效果。 |
| Verification | 上述70个去重定向用例最终执行通过，另14项actual Metal一致性及边界/依赖/归档通过；最终SDK/scripts与5348c9ad逐路径无差异；重复分支合并前后tree相同；三个分支祖先关系通过。 |
| Build | SwiftPM增量测试构建成功；未执行完整SDK或iOS设备矩阵。 |
| Limits | 未达标眼/眉/嘴/鼻/脸参考候选未导入；无新商业外观、一般语义或设备性能声明。未推送、未删分支、未修改其他worktree或外部宿主。 |

最终未引入独立BeautyIrisScaleRemap及Eye/Eyebrow/Mouth/Nose连续参考map文件。原始参考目录保持未跟踪。历史冻结记录、归档和原失败保留；本次不更改现行效果分类以获取合并资格。
