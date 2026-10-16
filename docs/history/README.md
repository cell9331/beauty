# 历史文档索引

本目录按主题保存初始设计、日期审计、已关闭研究，以及 2026-10-01 从现行说明移出的历史摘录。
它们用于追溯，不产生新的执行任务。原文中的“当前”“继续”“必须”均属于当时语境；
其中失败仍是失败，旧验收也只支持当时声明的范围。

现行状态见 [PLANS.md](../../PLANS.md)、[效果分类](../SDK_EFFECT_TAXONOMY.md)、
[验收政策](../validation/IMAGE_EFFECT_ACCEPTANCE.md)及[去脂根因与证据](upper-eyelid/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md)。

## 按主题查找

| 目录 | 范围 |
| --- | --- |
| [design/](design/README.md) | 01–09 初始产品、工程与算法设计，不能替代现行 owner |
| [audits/](audits/README.md) | 早期文档审计与 2026-10-01 日期观察 |
| [retouch/](retouch/README.md) | EYE/SEG 的有限试验、失败与终局处置，包含冻结契约导航 |
| [upper-eyelid/](upper-eyelid/README.md) | 去脂根因与皮肤语义研究，效果仍 suspended |

## 原有历史摘录

- [旧计划与技术债快照](remaining-effect-planning-snapshot-2026-10-01.md)：保留逐轮实验、旧待办和原 15 项二维效果的执行记录。
- [去脂实验记录](upper-eyelid-experiments-2026-10-01.md)：保留独立反例、候选失败、已修缺陷和各检查点的实际结果。
- [去脂技术历史](upper-eyelid-technical-history-2026-10-01.md)：保留旧候选机制和历史里程碑引用。

- [产品效果资格快照](product-effect-qualification-snapshot-2026-10-01.md)：保留当时资格声明的范围。

上述既有摘录、`plans/history/` 历史正文、`archives/` 和 archived milestone evidence 保留原字节。
2026-10-09 目录整理只迁移未签名文档并调整其导航，未修改试验数值、失败判据或资格。
历史记录中的旧路径按当时位置保留；查询迁移后的正文可用下方路径对照。

## 旧路径对照

| 原路径 | 分类后的正文 |
| --- | --- |
| `docs/01_product_feature_plan.md` | [01_product_feature_plan.md](design/01_product_feature_plan.md) |
| `docs/02_development_stages_full_plan.md` | [02_development_stages_full_plan.md](design/02_development_stages_full_plan.md) |
| `docs/03_architecture_spm_skeleton.md` | [03_architecture_spm_skeleton.md](design/03_architecture_spm_skeleton.md) |
| `docs/04_development_spec.md` | [04_development_spec.md](design/04_development_spec.md) |
| `docs/05_public_api_design.md` | [05_public_api_design.md](design/05_public_api_design.md) |
| `docs/06_beauty_parameters_spec.md` | [06_beauty_parameters_spec.md](design/06_beauty_parameters_spec.md) |
| `docs/07_face_landmarks_coordinate_system.md` | [07_face_landmarks_coordinate_system.md](design/07_face_landmarks_coordinate_system.md) |
| `docs/08_metal_render_pipeline_design.md` | [08_metal_render_pipeline_design.md](design/08_metal_render_pipeline_design.md) |
| `docs/09_algorithm_effects_implementation.md` | [09_algorithm_effects_implementation.md](design/09_algorithm_effects_implementation.md) |
| `docs/10_document_audit_report.md` | [10_document_audit_report.md](audits/10_document_audit_report.md) |
| `docs/CURRENT_BATCH_VALIDATION.md` | [CURRENT_BATCH_VALIDATION.md](../validation/CURRENT_BATCH_VALIDATION.md) |
| `docs/DENSE_FACE_REFACTOR.md` | [DENSE_FACE_REFACTOR.md](../sdk/DENSE_FACE_REFACTOR.md) |
| `docs/FEATURE_COMPLETION_INVENTORY_2026-10-01.md` | [FEATURE_COMPLETION_INVENTORY_2026-10-01.md](audits/FEATURE_COMPLETION_INVENTORY_2026-10-01.md) |
| `docs/GIT_OPERATIONS.md` | [GIT_OPERATIONS.md](../operations/GIT_OPERATIONS.md) |
| `docs/HOST_TEXTURE_PROTECTION.md` | [HOST_TEXTURE_PROTECTION.md](../sdk/HOST_TEXTURE_PROTECTION.md) |
| `docs/IMAGE_EFFECT_ACCEPTANCE.md` | [IMAGE_EFFECT_ACCEPTANCE.md](../validation/IMAGE_EFFECT_ACCEPTANCE.md) |
| `docs/PROJECT_STATUS_AUDIT_2026-10-01.md` | [PROJECT_STATUS_AUDIT_2026-10-01.md](audits/PROJECT_STATUS_AUDIT_2026-10-01.md) |
| `docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md` | [RETOUCH_FINAL_DISPOSITION_2026-10-03.md](retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md) |
| `docs/RETOUCH_INDUSTRY_DECISION_2026-10-03.md` | [RETOUCH_INDUSTRY_DECISION_2026-10-03.md](retouch/RETOUCH_INDUSTRY_DECISION_2026-10-03.md) |
| `docs/RETOUCH_MVP_PILOT_2026-10-03.md` | [RETOUCH_MVP_PILOT_2026-10-03.md](retouch/RETOUCH_MVP_PILOT_2026-10-03.md) |
| `docs/RETOUCH_PROBLEM_REVIEW_2026-10-04.md` | [RETOUCH_PROBLEM_REVIEW_2026-10-04.md](retouch/RETOUCH_PROBLEM_REVIEW_2026-10-04.md) |
| `docs/RETOUCH_RESEARCH_AND_V1_25_2026-10-03.md` | [RETOUCH_RESEARCH_AND_V1_25_2026-10-03.md](retouch/RETOUCH_RESEARCH_AND_V1_25_2026-10-03.md) |
| `docs/RETOUCH_TERMINAL_SCOPE_2026-10-03.md` | [RETOUCH_TERMINAL_SCOPE_2026-10-03.md](retouch/RETOUCH_TERMINAL_SCOPE_2026-10-03.md) |
| `docs/SEG_DEVELOPMENT_2026-10-03.md` | [SEG_DEVELOPMENT_2026-10-03.md](retouch/SEG_DEVELOPMENT_2026-10-03.md) |
| `docs/SEG_G0_FREEZE_2026-10-03.md` | [SEG_G0_FREEZE_2026-10-03.md](retouch/SEG_G0_FREEZE_2026-10-03.md) |
| `docs/SEG_G0_PROGRESS_2026-10-03.md` | [SEG_G0_PROGRESS_2026-10-03.md](retouch/SEG_G0_PROGRESS_2026-10-03.md) |
| `docs/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md` | [TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md](retouch/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md) |
| `docs/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md` | [UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md](upper-eyelid/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md) |
