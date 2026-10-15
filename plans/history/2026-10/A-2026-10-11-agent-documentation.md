# A-2026-10-11-agent-documentation

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex / project owner |
| Started | 2026-10-11 |
| Source Request | 优化项目 AGENTS.md 与相关文档，按第一性原理修复文档漂移。 |
| Scope | 精简代理入口，明确文档职责、授权与证据关系、条件化验证；同步相关现行指南。 |
| Verification Policy | 前后本地链接/锚点差异、当前声明与代码/脚本核对、SDK-only boundary live/self-test、归档验证、no-skip wrapper self-test、差异与保护摘要；不运行 SwiftPM/App 全量。 |

## Checklist

- [x] 读取入口、相关 owner 与现行脚本，确认并行眼/鼻/嘴改动及历史边界。
- [x] 重写 AGENTS 并同步现行 owner、导航与计划模板。
- [x] 完成最小充分文档/边界验证，记录原有断链及共享工作树限制。
- [x] 记录结果、剩余边界并转入 completed。

## Preservation

不修改 SDK 源码/测试、脚本、模型、媒体、冻结契约或既有历史证据；不恢复 UI、不重启已关闭效果。PLANS 仅增补本任务和维护规则，保留既有 Active 工作。

## 依据与设计选择

正确修改首先需要明确的授权范围、行为契约和能够拒绝错误结果的证据。
AGENTS 只保留会影响操作决策的长期规则与任务入口；实现细节、状态、失败和
可变库存由各自 owner 维护。这样减少重复维护点，也避免“实现存在”“计划完成”
和“效果合格”互相替代。

参考的一手资料（2026-10-11 核对）：

- [AGENTS.md 开放规范](https://agents.md/)：代理入口包含项目上下文、命令、测试和安全约定；格式按项目需要选择。
- [Codex 项目指令指南](https://developers.openai.com/codex/guides/agents-md/)：区分全局/项目作用域，保持规则简洁并写明例外；本轮不改全局配置或拆出重复入口。
- [Google 工程评审指南](https://google.github.io/eng-practices/review/reviewer/looking-for.html#documentation)：行为、构建或使用方式改变时同步相关文档；本项目结合既有政策按直接影响选择检查。
- 项目 [spike-findings-beauty](../../../.codex/skills/spike-findings-beauty/SKILL.md)：核对隐私、夹具与 suspended 效果的边界；未执行 spike 或读取/改动媒体。

## 修复清单

| 原问题 | 本轮处置 |
| --- | --- |
| AGENTS 重复细则、库存与历史处置，旧 v1.16 限制被写成入口现行总禁令 | 保留 shader/backend/API 工程边界，算法工作按现行授权计划；细则直接引用 owner。 |
| “代码 > 计划 > 文档”混淆事实、要求与授权 | 区分实现事实、契约要求、执行状态和回执；差异先判断实现缺陷或文档漂移。 |
| 仓库 UI 禁令没有显式说明外部宿主例外 | 明确仓库源码边界与已授权外部宿主范围，既有授权无需重复确认，SDK任务不自动包含宿主。 |
| SECURITY 要求所有代码改动全量 gate，与最小充分验证政策冲突 | QUALITY 定义条件化检查表；AGENTS、SECURITY、RELIABILITY、模板使用一致范围。完整里程碑 gate 保留。 |
| `.planning` 被入口笼统标为 active，原材料副本易成为第二 owner | 当前任务从 PLANS 进入；日期快照、历史与导入参考各有用途，不生成授权/续作。 |
| docs 索引漏掉已实施 prepared-photo 接入指南 | 补齐 canonical 链接，定义文档类型和入站引用维护规则。 |
| 产品正文仍称 preferredProcessingSize 只限制 Vision | 根据 MediaPipeDetectionRaster 与 Vision 的实际缩放路径改为平台 detector raster。 |
| 可靠性/学习手册仍暗示静图统一一次采样 | 补已验证连续脸型 ROI 后置阶段，各阶段限幅不等于全字段统一 6% 界限；合并仍为目标。 |
| 模板沿用迁移前编号与 P-ID，缺最小验证及并行保护要求 | 对齐 A-ID/现行目录、状态与完成流程，增加预期行为、保留契约和验证范围。 |

动态库存保留 QUALITY 原有日期，不重签旧测试或冻结效果资格。
并行眼、鼻、嘴候选不在本轮审查或验收范围。

## 实际验证与限制

| 检查 | 结果与范围 |
| --- | --- |
| 本地 Markdown 链接/锚点前后核验 | 仓库 owner、分类 docs、plans、相关 SDK/集成/媒体文档及当前 `.planning` 导航；检查实际目标与 Markdown 标题锚点，扫描器留在临时目录。最终聚合见下方。 |
| `python3 -B scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | 退出 0，两份固定归档验证通过；没有恢复或改动归档。 |
| `bash scripts/check-sdk-only-boundary.sh --self-test` | 退出 0，SDK BOUNDARY SELF-TEST PASSED；修改拒绝控制保留。 |
| `bash scripts/run-no-skip-swiftpm.sh --self-test` | 退出 0，14 checks / 14 mutation rejections；transcript 控制也通过，未启动 SwiftPM child。 |
| `bash scripts/check-sdk-only-boundary.sh --post-archive` | 退出 1：既有未跟踪 `BeautyEngineMouthReferenceTests.swift` 的 `renderBackend` 引用尚未被当前 GPU 边界接受。测试文件与任务初始摘要一致；文档 owner 扫描先于此失败。SDK-GATE-01 记录此独立缺口，不声称 live 通过。 |
| 现行声明静态核对 | 包/平台、已有模型授权、外部宿主、关闭研究、检测缩放、连续脸型阶段与 owner/代码/脚本/日期记录对齐；不是算法或图片效果重验。 |
| 差异/保护检查 | `git diff --check` 与初始文件摘要对照；完成摘要见下方。本轮仅写文档，已有并行代码变化按实际范围记录。 |

没有运行 SwiftPM、完整 SDK gate、批量像素工具、App/原生 iOS、真机或图片生成；
这些不由本轮纯文档修改触发。本任务完成仅表示入口/相关现行文档已优化，
不证明当前共享工作树代码整体通过，不改变任何效果资格或分发边界。

## 完成聚合（2026-10-11）

- 本轮共更新13份既有文档并新增本记录；AGENTS 从171行缩至99行。
- 最终链接检查：187份 Markdown、915个本地链接、8个标题锚点，0断链；
  修改前也无断链，本轮修复的是内容/职责漂移。`git diff --check` 退出0。
- 初始2608文件摘要中，2594份非本任务文件保持一致；13份既有文档为本轮
  改动。另1份并行文件 `BeautyBackendContract.swift` 在任务期间变化，属于
  现有 SDK 工作，本轮未写入或回退。无初始文件删除。
- 被边界拒绝的嘴部测试保持初始字节；归档、脚本、冻结契约、既有历史证据
  和其他初始源码/测试摘要保持一致。本轮没有 SDK 编译或效果资格声明。
- 当前 boundary live 仍未通过；该现状由 SDK-GATE-01 跟踪。其他已执行文档、
  归档及控制自测通过，不合并成“全项目通过”。
