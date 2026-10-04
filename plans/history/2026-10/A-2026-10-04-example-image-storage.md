# A-2026-10-04-example-image-storage

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex |
| Started | 2026-10-04 |
| Scope | 清理可重建的本地图片缓存，并限制图片数量、存储体积及压缩展示图。 |
| Source Request | 所有者要求删除无用示例图、增加限制并压缩。 |
| Current Step | 清理、压缩、限制和验证完成，无续作。 |
| Verification Policy | 清理前后必要夹具摘要一致；工具边界回归、实际图片编码、夹具定向测试、archive/boundary 与差异检查。 |

| Step | Status | Evidence |
| --- | --- | --- |
| Define scope | `completed` | 初始约 5.4 GiB，主要为旧输出和重复副本；8 个输入、6 个停用兼容夹具及两个验收包的 12 张清单图片保留。 |
| Implement or edit | `completed` | 删除 1,800 个缓存/重复文件，共 5,728,068,134 字节；目录约 5.4 GiB → 29 MiB。新增 check/clean/preview 和本地 ImageIO 编码助手；容量检查接入 archive-first wrapper 及其 mutation gate。 |
| Verify | `completed` | 15 个 Python 边界测试、3 个实际像素/元数据编码案例、14 checks / 14 wrapper mutation rejections、定向 SwiftPM 1/0/0 与 26/0/0；全量门禁退出 0，1076/0/0、9 opt-ins。28 个必要夹具/清单文件逐字节摘要不变；重复清理删除 0 文件。 |
| Record outcome | `completed` | AGENTS、示例图 README、SECURITY、RELIABILITY、QUALITY_SCORE、PLANS 及历史索引同步。 |

长期证据只保存聚合统计，不保存私有夹具定位符、像素、几何或原始日志。
本任务不重开已关闭的效果研发、不改变 SDK/API 或历史证据。

## Completion

| Field | Value |
| --- | --- |
| Completed | 2026-10-04 |
| Scope | 可重建图片缓存清理、容量硬门禁与压缩展示图。 |
| Files | scripts/manage-example-images.py、example-image-preview.swift、两份工具回归、run-no-skip-swiftpm.sh、check-no-skip-wrapper.py、.gitignore 及对应 owner 文档。 |
| Verification | 全量 archive-first gate、15 个存储回归、3 个编码案例、14 个 wrapper 变异拒绝、必要资产摘要、文档链接和 git diff --check 全部通过。 |
| Build | 最终 bash scripts/run-no-skip-swiftpm.sh 退出 0：1076 tests / 0 failures / 0 skips / 9 opt-ins；archive/boundary/backend/Metal parity/consumer/CPU oracle 前置检查通过。 |

- 限制：总计 128 MiB / 160 图，单张 16 MiB；input 最多 16 图 / 32 MiB；
  preview 最多 32 张 JPEG、单张 512 KiB、长边 1600 px。全尺寸像素验收使用
  临时原图输出，不以有损展示图替代 oracle。
- 当前 27 张图片：8 个输入、6 个停用兼容夹具、12 张验收清单资产和 1 张
  JPEG 展示图。展示图 1600×1082、260,967 字节，必要源/清单原字节不变。
- 初次 Swift 编译缓存写入及随后绝对路径 SwiftPM manifest 的嵌套 sandbox
  被执行环境拒绝，不计通过。编码助手使用私有临时模块缓存；全量门禁在
  自动批准的正常系统缓存权限下成功，不改生产或历史门禁以绕过验证。
- 编码前置检查曾拒绝 ImageIO 自动合成的 EXIF 尺寸字典；助手移除 JPEG
  可选元数据段后再解码验证。像素控制生成器改为明确的 sRGB 分量填充，
  保持原红色/白色比例及容差断言，最终 3 案例通过。
- 不覆盖原有本地终局文档修改，不持久化私有定位符或原始子进程日志。
