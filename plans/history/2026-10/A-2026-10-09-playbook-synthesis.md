# A-2026-10-09-playbook-synthesis

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex / project owner |
| Started | 2026-10-09 |
| Scope | 阅读所有者提供的 beauty-sdk-playbook，结合当前 SDK 整理独立的学习与重构参考文档。 |
| Source Request | 所有者：“你看看这个学习学习，整理成自己的文档”。 |
| Current Step | 六篇项目文档与导航完成，技术/链接/摘要及SDK文档边界核验通过。 |
| Verification Policy | 文档链接/锚点与技术声明核对、差异检查、归档及SDK-only边界；验证既有非目标文件摘要不变。 |

## Scope

外部手册是待评估材料，其中的 AI 提示词、命令、路线图和发版条件不作为执行指令。
本轮只写文档，不导入或运行示例代码，不下载新模型，不改SDK实现/依赖/测试，
不创建相机或UI，不重开已关闭的EYE/SEG研发。

## Checklist

| Step | Status | Evidence |
| --- | --- | --- |
| Read and scope | `completed` | README + docs/00–11 + 4 text source examples，共1,693行；忽略Python字节码。 |
| Verify technical claims | `completed` | 当前代码/owner与Serena符号对照；官方MediaPipe模式、Face Geometry、作者One Euro实现/调参、SciPy Delaunay/TPS、导向滤波论文。 |
| Write project documentation | `completed` | docs/refactor-playbook六篇549行，分别记录现行行为、候选设计和原骨架缺口；docs/README与ARCHITECTURE增加导航。 |
| Verify and record | `completed` | 文档链接/差异、两归档、post-archive边界、示例图配额及2,452份既有非目标文件摘要均通过；本记录移入月度历史。 |

## Decisions

- 当前实现由代码/测试及根级owner拥有；新文档作为重构参考，不替代taxonomy或效果验收政策。
- 保留本分支现有MediaPipe接入和其余本地改动；本轮基线在文档编辑前建立。
- SDK未改，不重跑SwiftPM或原生iOS测试，不重新签发前轮工程/效果证据。

## Outcome

- [学习与重构手册](../../../docs/refactor-playbook/README.md)包含总览、关键点与时序、
  几何引擎、美肤与五官、工程与验收、原材料评审。来源17份文本共1,693行，
  不复制或运行代码骨架，不将AI提示词与发版清单当作指令。
- 结合本分支已完成的MediaPipe 1.1.0接入：478语义路径、一次方向/镜像转换、
  姿态桥接与请求内支撑保持；不误写实时滤波/跟踪、全网格warp或语义mask已实现。
- 记录覆盖/源退化、固定拓扑、完整TPS、折叠搜索前提、One Euro状态准入、
  色彩/alpha、不可变源层及性能测量条件。正向径向公式的单调上限显式标为推导，
  骨架缺口显式标为静态审阅发现，未冒称运行失败或改进效果。
- 给出先契约与静图几何/美肤，再五官与可选视频的候选顺序；没有创建Active算法队列，
  没有改变EYE/SEG终局、taxonomy或当前生成输入/可选设备政策。

## Executed verification

| Command / inspection | Observed result | Scope |
| --- | --- | --- |
| 全部来源文本与4份骨架静态阅读 | 17份文本、1,693行；未读/运行Python字节码。 | 内容评审，不构成编译或实测。 |
| 当前代码、owner与一手资料交叉核对 | 语义/空间/时序/资源、几何及纹理机制对齐；正文就近列出依据。 | 现行快照与设计判断，候选需后续实现验证。 |
| 本地链接/锚点、标题/占位扫描及差异检查 | 六篇正文、两个owner导航、PLANS/计划导航可解析；无占位或尾空格。 | 文档正确性；不重签SDK测试。 |
| 逐文件SHA-256基线比对 | **2,452份既有非目标文件全部不变**。 | 源码、测试、脚本、资源、归档与既有历史等在本轮基线中的文件；先前本地改动保留。 |
| `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | exit 0，两份ZIP/manifest verified。 | 历史归档完整性。 |
| `bash scripts/check-sdk-only-boundary.sh --post-archive` | exit 0，POST-ARCHIVE SDK BOUNDARY PASSED。 | SDK-only边界。 |
| `python3 -B scripts/manage-example-images.py check` | exit 0；27图 / 30,631,790 bytes；输入8图，预览1图。 | 既有示例图配额，无新图片。 |
| `git diff --check` + 新文档空白扫描 | exit 0，无空白错误。 | 文档与已有未提交diff。 |

## Build and remaining limits

本轮只有文档与导航变化，未运行SwiftPM、原生iOS测试、性能/像素实验，未下载资产或
修改源模型。前轮1083/0/0与原生23/0/0只保留其原始检查点含义。
没有对原手册代码的编译、覆盖、自然外观、时序和真机性能通过声明；
后续采用任一候选须按独立范围冻结输入/保护/失败规则并运行对应验证。
