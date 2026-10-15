# A-2026-10-09-document-cleanup

| Field | Value |
| --- | --- |
| Status | `completed` |
| Started | 2026-10-09 |
| Source Request | 删除没用的文档，修复剩余的文档漂移。 |
| Scope | 删除无当前依赖的重复导入/未执行方案，收敛当前 owner 与导航；不改 SDK、脚本实现、冻结契约和历史验收结果。 |
| Verification Policy | 代码/字段/库存静态核对；本地链接及锚点；archive、boundary、自测与wrapper控制；原文件摘要和diff校验。 |

## Decisions

- 删除 `docs/_source/docs_total.json`：已导入到保留的01–09长文，当前代码、测试和门禁不读取它；仅旧审计/历史账本提到导入过程。
- 删除 `docs/人脸解析模型转 Core ML 与评估方案.md`：无当前入站引用、未运行/未接入的孤立下载转换/微调方案，与终局无续作边界冲突。删除不把未执行模型计为失败。
- 保留被历史记录引用的初始设计、superpowers、blueprint、active旧路径重定向；冻结 R2/G0 和历史实验/里程碑证据只读。当前索引将它们明确归为历史。
- 六份根级 owner 以当前源码/测试取代累计阶段叙述，动态文件/行数只放QUALITY_SCORE；保留原有外部宿主修复和模拟器失败记录。
- `.planning/MILESTONES.md`只修九个迁移前导航路径及说明；归档文件、原状态与回执不变。`.planning/PROJECT.md`只修当前核心价值中无证据的自然/实时承诺。

## Checklist

| Step | Status | Evidence |
| --- | --- | --- |
| 文件依赖/冻结引用与当前源码核对 | completed | Serena确认固定beauty项目；2465个原文件摘要快照；静态85源/140测试文件，77参数/11配置/99注册98默认/9opt-in。 |
| 删除与现行契约/导航修复 | completed | 两项删除；六owner收敛；当前batch不再排EYE G0；当前验收政策将R2标为历史关闭。 |
| 窄范围验证 | completed | 两archive验证、boundary live/self-test、wrapper 14/14、storage、当前链接/锚点、源码/冻结摘要与diff核对通过。 |
| 记录结项与剩余历史导航限制 | completed | PLANS和月度索引更新；记录以下只读历史范围。 |

## Evidence boundary

本轮仅文档，未运行SwiftPM、图片效果、生成输入或模型；最近1076/0/0仍为原日期的工程检查点。已关闭的EYE/SEG及模拟器持续检测/分割失败不因整理变成通过。

## Verification and outcome

- 六owner：8,391 → 947行（减少约89%）；只保留现行设计/接入/安全/恢复/验收与关键失败边界。原有两段模拟器Vision记录逐字保留，FRONTEND原字节未改。
- 静态工作树：85 Swift源文件/23,499行、140 Swift测试文件/53,897行；字段77/11、资源5预设/2滤镜、renderer99注册/98默认、九项opt-in/五个显式环境输入与源码相符。它们不是新的运行分母。
- `python3 -B scripts/archive-legacy-ui.py verify --output archives/legacy-ui`：两个原ZIP摘要通过。
- `bash scripts/check-sdk-only-boundary.sh --post-archive` 与 `--self-test`：退出0。
- `bash scripts/run-no-skip-swiftpm.sh --self-test`：退出0，14 checks/14 mutation rejections；只运行控制自测，不是完整SwiftPM。
- `python3 -B scripts/manage-example-images.py check`：退出0，27图、8输入、1预览，30,631,790 bytes；未改媒体。
- 全仓804个本地Markdown链接/锚点扫描与变更前比对无新增坏链接；当前owner/指南/索引全通过，9个旧里程碑导航已修复。仍有86条原有坏链接，全部属于只读phase/archived roadmap/历史分片/实验revision快照；不修改这些冻结文件。历史查询先经当前索引定位实际归档，不把旧路径当当前依赖。
- 对2465个原文件建立摘要基线，2450个原字节不变；生产源码、测试、脚本、ZIP、冻结R2/G0、实验/里程碑回执与原历史计划正文未变。两个删除文件之外只改当前文档及导航索引。G0回执绑定的三份文档摘要仍精确有效。
- `git diff --check`通过；未构建/测试SDK、操作设备、生成输入、运行候选或下载/训练模型。1076/0/0仍引用2026-10-08原工程检查点；没有效果/设备新资格。

## Removed material identities

| Removed file | Former SHA-256 | Why removable |
| --- | --- | --- |
| `docs/_source/docs_total.json` | `ab72b783debfe6d9df14a1e49f9b93837d21796f8686c4662081648ba1ec07ff` | 重复导入；已保留生成的历史长文，无当前代码/门禁读取。 |
| `docs/人脸解析模型转 Core ML 与评估方案.md` | `ca76eda2514c44c6c2490bf8eb4adb40e325bf2341157d6badd003ad190181fd` | 未运行、无当前引用/接入；不能作为已授权续作或模型失败证据。 |

旧记录对已删除材料的纯文本文件名描述保留当时含义；当前索引不再链接它们。初始设计、superpowers、blueprint和旧active重定向因历史引用/追溯保留，未批量删除。该整理不恢复两条关闭路线，也不修复宿主持续Vision/分割正例失败。
