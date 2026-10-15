# A-2026-10-15-branch-preservation-cleanup

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-10-15 |
| Scope | 保存两个脸型工作区的未提交代码，再清理已证实冗余的本地分支。 |
| Source Request | 用户要求先保存、确认不丢代码后清理重复分支，未完成功能保留。 |
| Expected Behavior | 两工作区各有可恢复WIP提交；其不同代码与工作区保留；只删除已有保留分支覆盖的playbook分支。 |
| Current Step | 两份WIP提交已校验，唯一重复分支已删除；两个工作区及未完成功能保留。 |
| Verification Policy | 显式路径/原始字节与Git blob核对、HEAD/父提交/祖先验证、排除参考资料原地摘要保护；不修改算法或重跑效果测试，不把WIP认定完成。 |

现有main未提交AGENTS修改和原始参考目录保持原样；两个工作区的ignored构建、媒体、缓存不清理；不删除工作区、不推送、不合并未达标效果。保存操作按本次明确授权执行，不受历史计划“暂不提交”的旧执行状态限制。

## 保存结果

| Branch | WIP commit | Saved changed files | Preserved source/document bytes |
| --- | --- | --- | --- |
| `codex/face-selected-delivery-20261015` | `feb8c9b17d121a067c344291098e1fe04163ce91` | 124 | 3570914 |
| `codex/face-shape-reference-20261014` | `a7f7f2d83c34e1bcae00f604db1bca54376a377c` | 109 | 2975804 |

两份快照都直接以 `15f6e46deb8d76b3316cf296c6a71a1e38350f81` 为父提交。
保存范围包括原先修改的tracked文件和非忽略的新代码、测试及文档；没有改写代码字节。
两工作区各25份原始参考副本保持未跟踪并原地保留，摘要逐文件不变；ignored媒体、
构建与缓存不删除、不移动、不打包入Git。新文件二进制、私钥/token与私有媒体路径
检查无命中；冻结历史文件未编辑。

## 去重依据与处置

- 共同改动路径中85项内容相同、30项不同；selected另有34项独有路径，shape另有19项。
  该比较包含原地参考副本，不能把两份工作区当成重复代码整体删除。
- 删除的唯一分支：`codex/playbook-sdk-refactor`，旧tip为`15f6e46d`。
  删除前以`merge-base --is-ancestor`确认它同时被眉分支和两个已保存的脸型分支覆盖；
  在descendant脸型工作区使用非force的`git branch -d`删除。
- 保留：`codex/archive-sdk-foundation-wip`、`codex/eyebrow-reference-refactor`、
  `codex/face-selected-delivery-20261015`、`codex/face-shape-reference-20261014`。
  四个分支分别保有历史快照、眼眉嘴鼻研究记录、脸型部分交付候选及独立脸型保护研究。
- 两个脸型工作区继续存在，可直接在那里继续；上述提交是可恢复基线。
  需要检查快照可用`git show <commit>:<repository-relative-path>`读取原文件，或
  在原工作区用`git diff <commit>`查看后续变化；无需重置工作区。

### C-2026-10-15-branch-preservation-cleanup

| Field | Value |
| --- | --- |
| Completed | 2026-10-15 |
| Status | `completed`（仅保存与去重范围） |
| Scope | 两份WIP快照，233项文件改动；删除一个被保留历史完整覆盖的分支引用。 |
| Rationale | 原先三个同tip分支不能仅按名字/指针删除，两工作区有真实独有内容。 |
| Verification | 暂存路径集精确匹配、每个Git blob SHA256与保存前文件一致、提交后再次读取blob匹配；全部工作区文件和原始参考摘要未变；父提交、分支HEAD及祖先关系通过；暂存diff检查通过。 |
| Build | 未构建或执行效果测试：本轮保存原有字节，没有算法修复、效果合并或资格提升。 |
| Limits | WIP可包含失败候选与未完成实现；保存不是效果通过。main只增加整理文档，不带入WIP算法。未推送，未清理工作区/缓存。 |

main原先未提交的AGENTS修改保持未暂存；所有者原始参考资料保持本地。现有眼瞳保留/
暂停决定不变，本次不把两个工作区旧计划中的眼瞳active字样当作新的续作授权。
