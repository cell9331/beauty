# A-2026-10-04-repository-disk-cleanup

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-10-04 |
| Scope | 盘点项目剩余占用，删除已识别的可重建构建缓存和重复实验输出。 |
| Source Request | 所有者要求继续盘点并清理项目中可删除的磁盘占用。 |
| Current Step | 清理与验证完成，项目约 4.6 GiB → 696 MiB。 |
| Verification Policy | 受保护文件摘要不变；清理目标 ignored 且无 tracked 文件；归档/boundary/image-storage 检查；清理前后容量和差异检查。 |

| Step | Status | Evidence |
| --- | --- | --- |
| Define scope | `completed` | 当前约 4.6 GiB；主要为 SDK .build 2.5 GiB、consumer 462 MiB、两处历史工具编译缓存约 1 GiB；冻结原始源不能随 .build 整体删除。 |
| Clean | `completed` | 删除 23,447 个 ignored/未跟踪缓存或重复输出条目，按分配块统计约 3.9 GiB（4,205,117,440 字节）；保留所有非目标文件。 |
| Verify | `completed` | 35 项冻结源/作者摘要有效；2,824 个非清理目标文件字节或链接目标不变；归档、boundary、example-storage 和差异检查通过。 |
| Record | `completed` | AGENTS 和 SECURITY 记录混合 .build 边界，QUALITY_SCORE、PLANS 和历史索引同步。 |

不重开效果实验，不修改 SDK、技能源或任何既有 archived evidence。
持久记录仅包含类别、计数和容量，不记录私有源定位符、像素或 child transcript。

## Completion

| Field | Value |
| --- | --- |
| Completed | 2026-10-04 |
| Scope | 全项目磁盘盘点及可重建缓存、衍生重复输出清理。 |
| Files | 仅删除 ignored/未跟踪缓存及工作输出；记录更新 AGENTS、SECURITY、QUALITY_SCORE、PLANS 与本计划。 |
| Verification | Git tracked-target 拒绝、冻结摘要、未删除文件摘要、归档/boundary/storage 和 git diff --check 全部通过。 |
| Build | 无新编译或 SwiftPM 测试；源码/测试未改，避免重新生成缓存。此前 1076/0/0 仍为前轮结果。 |

清理分类（按文件分配块，不等于新的性能或效果声明）：

| 类别 | 删除条目 | 字节 | 约合 |
| --- | ---: | ---: | ---: |
| SDK 编译/索引、批量工具编译副本、衍生复核图 | 12,671 | 2,597,519,360 | 2.42 GiB |
| Consumer 索引/构建缓存 | 3,493 | 484,618,240 | 462 MiB |
| 历史实验工具编译缓存 | 4,755 | 609,452,032 | 581 MiB |
| 项目技能内工具编译缓存 | 2,528 | 513,527,808 | 490 MiB |
| 合计 | 23,447 | 4,205,117,440 | 3.92 GiB |

保留项：历史 spike 证据约 306 MiB、Git 约 186 MiB、已验证 UI ZIP 约
84 MiB、冻结输入/回执约 34 MiB、必要示例图约 29 MiB、Serena 状态约
22 MiB，以及源码/文档/小型本地备份。未分类的本地状态与原有未跟踪文件
保留。活跃编译进程为零，语言服务未打开待清理索引；没有停止或切换 Serena。

`.build` 根目录保留冻结原始源和回执，现有历史脚本的本地源仍可摘要核对；
本轮不重跑已关闭的效果实验。派生复核图已删除，不能宣称仍有这些本地副本；
历史聚合结论和脚本/输入保持原字节。后续构建/索引会按需重新生成缓存。

本轮盘点/摘要/清理辅助文件位于临时目录，用完删除，不新增永久清理脚本。
