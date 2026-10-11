# Documentation Index

The current repository is an owner-local SDK-only SwiftPM package. Start with
[AGENTS.md](../AGENTS.md) and [PLANS.md](../PLANS.md), then read the matching
owner below. Code/tests own implemented behavior; dated design and experiment
records do not create current tasks or override current contracts.

## 按目录查找

| 目录 | 内容 |
| --- | --- |
| [sdk/](sdk/README.md) | 当前静图实现与宿主接入指南 |
| [validation/](validation/README.md) | 图片效果验收政策、当前批量验证工具 |
| [operations/](operations/README.md) | 仓库 Git 操作与账号约定 |
| [history/design/](history/design/README.md) | 01–09 初始产品、架构、API、参数与算法设计 |
| [history/audits/](history/audits/README.md) | 文档审计、日期功能清单与进度快照 |
| [history/retouch/](history/retouch/README.md) | 已关闭的 EYE/SEG 研究、试验结果与终局处置 |
| [history/upper-eyelid/](history/upper-eyelid/README.md) | 去脂根因与皮肤语义研究 |
| [history/](history/README.md) | 历史摘录总索引及旧文件路径对照 |
| [refactor-playbook/](refactor-playbook/README.md) | 对照当前代码整理的项目学习与重构手册 |
| [beauty-sdk-playbook/](beauty-sdk-playbook/README.md) | 所有者导入的外部手册原文，作为参考材料 |
| [meitu-function-blueprint/](meitu-function-blueprint/README.md) | 历史功能蓝图与 UI 参考 |
| [superpowers/](superpowers/specs/2026-05-25-sdk-foundation-design.md) | 早期 foundation 规格与计划 |

`SDK_EFFECT_TAXONOMY.md` 保留固定权威路径。三份摘要绑定的 R2/G0
契约保留原路径和原字节，在研究索引中统一导航；另有 14 份短入口供冻结
契约和只读历史记录的旧链接使用。短入口不重复保存正文。
新增正文应进入匹配目录，不再平铺到 `docs/` 根目录。

## Current owners and guides

| Topic | Authority |
| --- | --- |
| Targets, dependencies and processing routes | [ARCHITECTURE](../ARCHITECTURE.md) |
| Parameters, input, detection, composition and result models | [DESIGN](../DESIGN.md) |
| Owner-host integration and bounded effect use | [PRODUCT_SENSE](../PRODUCT_SENSE.md) |
| Errors, recovery, resource bounds and known platform failures | [RELIABILITY](../RELIABILITY.md) |
| Privacy, input/resource trust and archive/media retention | [SECURITY](../SECURITY.md) |
| Dated inventory, executed receipts and validation gates | [QUALITY_SCORE](../QUALITY_SCORE.md) |
| External owner editor and historical UI boundary | [FRONTEND](../FRONTEND.md) |
| Current work and limitations | [PLANS](../PLANS.md), [current debt](../plans/debt/current.md) |
| Exact control/parameter mappings and effect status | [SDK_EFFECT_TAXONOMY](SDK_EFFECT_TAXONOMY.md) |
| Eligible inputs and independent effect/protection acceptance | [IMAGE_EFFECT_ACCEPTANCE](validation/IMAGE_EFFECT_ACCEPTANCE.md) |
| Current 98-default/99-canonical batch validation (face slider opt-ins separate) | [CURRENT_BATCH_VALIDATION](validation/CURRENT_BATCH_VALIDATION.md), [tool usage](../scripts/current-batch/README.md) |
| Host-supplied object + complete-lip texture masks | [HOST_TEXTURE_PROTECTION](sdk/HOST_TEXTURE_PROTECTION.md) |
| Dense static-image semantics, map safety and resource reuse | [DENSE_FACE_REFACTOR](sdk/DENSE_FACE_REFACTOR.md) |
| Face slider polarity, continuous fields and reference limits | [FACE_SHAPE_SLIDERS](sdk/FACE_SHAPE_SLIDERS.md) |
| Git identity and remote operations | [GIT_OPERATIONS](operations/GIT_OPERATIONS.md) |
| Fixture storage, previews and classified cleanup | [example-images](../example-images/README.md) |

Generated positives/negatives may qualify an effect under the current policy;
genuine portraits and physical devices are optional. Swift `public` permits
the owner's local hosts, not third-party source/binary/model distribution.
Current SDK engineering and effect evidence have separate scopes.
Current citations should use the classified guide paths in the table directly.
The root compatibility pages are navigation for older citations; they do not
duplicate or override a contract. Dated `.planning/codebase/` maps link to these
owners but retain their original analysis scope.

## Learning and refactor references

[BeautySDK 学习与重构手册](refactor-playbook/README.md) synthesizes the owner's
external playbook against the current MediaPipe/geometry/texture contracts. It
covers landmarks and timing, candidate mesh geometry, effects, engineering and
acceptance, with a review of the source examples. Proposed designs and budgets
are distinguished from implemented behavior; reading it does not activate its
AI prompts, roadmap, model downloads or closed retouch work.

## Closed research and dated evidence

v1.25 is [closed with unmet objectives](history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md):
EYE and SEG each rejected two methods/four versions. Neither automatic target
was delivered. Upper-eyelid compatibility stays suspended/default-hidden;
host masks and the current batch tool remain usable. There is no automatic G0,
fifth candidate, model/training or production-integration task. Ordinary
“continue” does not reopen the work; a new owner scope/hypothesis/resources is required.

The [R3 scope](history/retouch/RETOUCH_TERMINAL_SCOPE_2026-10-03.md),
[terminal requirements](../.planning/REQUIREMENTS.md) and
[closed plan](../plans/history/2026-10/A-2026-10-03-v1-25-retouch-repair.md)
record that disposition. The [problem review](history/retouch/RETOUCH_PROBLEM_REVIEW_2026-10-04.md)
and [industry comparison](history/retouch/RETOUCH_INDUSTRY_DECISION_2026-10-03.md) distinguish
measured failures from unexecuted alternatives; they grant no download or training authorization.

Frozen historical contracts: [R2](RETOUCH_MVP_REQUIREMENTS.md),
[G0 design](RETOUCH_G0_VALIDATION_PLAN.md), [case manifest](RETOUCH_G0_CASE_MANIFEST.md),
[SEG freeze](history/retouch/SEG_G0_FREEZE_2026-10-03.md). Earlier pending/next-step wording in
these files is a snapshot, not current execution. Their signed identities and
thresholds remain unchanged. Results are preserved in the
[SEG development](history/retouch/SEG_DEVELOPMENT_2026-10-03.md),
[pilot](history/retouch/RETOUCH_MVP_PILOT_2026-10-03.md),
[finite semantic probe](history/retouch/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md) and owning
experiment receipts. Candidate holdout evaluations remain zero.

The [2026-10-01 feature inventory](history/audits/FEATURE_COMPLETION_INVENTORY_2026-10-01.md)
and [audit](history/audits/PROJECT_STATUS_AUDIT_2026-10-01.md) are dated observations.
Current counts/statuses come from the owners above. Full historical navigation
starts at [plans/history](../plans/history/README.md),
[2026-10 records](../plans/history/2026-10/README.md) and
[terminal index](../plans/history/2026-10/TERMINAL.md).

## Initial design material

The [01–09 initial designs](history/design/README.md),
[dated audits](history/audits/README.md), `docs/superpowers/`,
`docs/meitu-function-blueprint/`, prior `.planning` snapshots/maps and archived milestones retain
historical context and references. Their proposed APIs, UI/camera flows, old
counts, toolchain observations and qualification rules are not current contracts.
Use them only for a specific history question, through existing historical citations.
The duplicate import and isolated unexecuted Core ML proposal were removed in
[the 2026-10-09 cleanup](../plans/history/2026-10/A-2026-10-09-document-cleanup.md).

Historical UI/Demo contents are available only from
[verified archives](../archives/legacy-ui/README.md), restored into a fresh
outside-repository temporary directory. They are not build or acceptance input.
