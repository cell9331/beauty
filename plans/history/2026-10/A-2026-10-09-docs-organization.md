# A-2026-10-09-docs-organization

| Field | Value |
| --- | --- |
| Status | `completed` |
| Started | 2026-10-09 |
| Source Request | 整理 docs，增加文件夹并分类管理。 |
| Scope | 按现行 SDK、验证、操作指南及历史设计/审计/研究分类；只迁移文档和调整导航，不改变 SDK 行为或效果资格。 |
| Current Step | 分类、导航、摘要与文档门禁已验证，完成结项。 |
| Verification Policy | 本地链接/导航与迁移前比对；冻结契约和非目标文件 SHA-256；archive/boundary/storage 与文档差异检查。 |

## Decisions

- 保留根级 owner 和 `docs/SDK_EFFECT_TAXONOMY.md` 的权威入口，避免修改依赖其固定路径的历史门禁。
- 三份 G0 摘要绑定契约保留原路径和原字节；通过历史研究索引分类。为冻结契约和只读历史记录实际引用的 14 个旧路径保留短导航入口，避免改写历史正文或新增断链。
- 初始设计与日期报告归入 `docs/history/`，历史归档、实验 revision/results、计划正文和 archived milestone evidence 不改写。
- 现行指南和未签名报告只调整文件位置与链接；保留原有本地改动。

## Checklist

| Step | Status | Evidence |
| --- | --- | --- |
| 目录、引用与冻结绑定盘点 | completed | Serena 固定 beauty 项目；33 份顶层 Markdown，2,532 份原文件摘要基线。 |
| 分类迁移与导航维护 | completed | 新建 7 个分类目录和 7 份目录索引，迁移 28 份正文；保留 taxonomy、3 份冻结契约与 14 份历史链接入口。 |
| 最小充分验证 | completed | 本地链接/锚点无新增断链；3 份 G0 绑定精确匹配；两归档、boundary live/self-test、wrapper 14/14 控制自测、storage 和 diff 检查通过。 |
| 结项记录 | completed | 更新 PLANS、月度历史索引及 docs 导航；不重新签发 SDK 测试证据。 |

## Outcome and verification scope

- 分类包括 `sdk/`、`validation/`、`operations/`、`history/design/`、`history/audits/`、`history/retouch/` 和 `history/upper-eyelid/`。原有 playbook、blueprint 与 superpowers 子目录保留。
- 顶层 Markdown 从 33 份降为 19 份，其中正文/总索引只有 5 份，其余 14 份为只读历史及冻结契约所需的短导航入口，不重复正文。旧路径对照集中在 `docs/history/README.md`。
- 对原有 2,532 份非 ignored 文件建立 SHA-256 基线：除四份有意更新的计划/目录索引，其余文件均原字节不变，或可仅反向还原路径/链接后精确匹配。代码、测试、资源、归档、三份冻结契约、历史计划正文、实验 revision/results 和已有导入手册保持原字节；已有本地改动没有覆盖。
- 全仓本地 Markdown 链接/锚点扫描无新增坏链接。原有 86 条历史失效路径/锚点仍限于只读阶段、历史账本或实验快照；不因目录整理改写其原始证据。14 个兼容入口避免了原历史链接因本次迁移新增断链。
- `python3 -B scripts/archive-legacy-ui.py verify --output archives/legacy-ui`：两个 ZIP 身份验证通过。
- `bash scripts/check-sdk-only-boundary.sh --post-archive` 与 `--self-test`：退出 0。
- `bash scripts/run-no-skip-swiftpm.sh --self-test`：退出 0，14 checks / 14 mutation rejections；只验证 wrapper 控制，不是完整 SwiftPM。
- `python3 -B scripts/manage-example-images.py check`：退出 0，27 图、8 输入、1 预览，30,637,971 bytes；媒体没有改动。
- `git diff --check`：通过。仅文档迁移与导航，未运行 SwiftPM、构建、设备测试、图片效果或模型实验；既有 SDK/原生检查点没有重新签发。
