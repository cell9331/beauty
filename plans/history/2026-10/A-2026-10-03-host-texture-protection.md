# Owner-supplied object and lip texture protection

Status: `completed`。一般继续授权下，本轮仅落实此前已推荐的正确显式蒙版使用路径，新增常规 SDK 回归与主机接入说明；不研发自动物体/五官识别，不重开去脂，不改生产源码、公开 API 或旧失败实验。

## 事前固定范围

- 输入采用 [既有冻结挑战](../../../scripts/experiments/texture-semantic-probe/TextureSemanticProbeTests.swift)的同一 64×64 不透明 sRGB 生成源、双肤色、目标区域与方向门槛。其 SHA-256 `a535def54fb100b7e9591a488ff09ee0c15ce3d52f296b1b81ae133de3e27b62` 保持不变。
- 主机额外提供已知右颊物体区域与完整已知唇区的并集排除蒙版，表示新的外部信息。它不是自动算法，也不修改旧物体专用蒙版挑战的输入或保护断言。
- 必须同时通过：右颊物体、完整源唇、眼、远背景及 alpha 源精确；对侧平滑邻接亮度变化至少降低 20%、锐化至少增加 10%；未排除像素精确匹配同请求无蒙版基线，RGB 改变量最多 16；neutral、repeat、extent/色彩空间与 typed failure/recovery。
- 覆盖 decoded 与内存编码 PNG；decoded 的八种方向 × 两种输入镜像；CPU 与 GPU-selected 路径或明确 typed `metalUnavailable`，不得 skip；全排除、无脸、零/未提供蒙版和请求恢复反例。
- 新增测试和接入文档；静态边界扫描按既有精确源摘要机制登记本文件对现有 backend 设置的调用，并自测追加新 backend 声明或任何字节变更仍被拒绝。没有新增 GPU API/backend/Metal 源。若正确指定像素仍失败，保留失败并记录限制，不进入自动算法/调参重试。

## Tasks

- [x] 阅读 owner 与现有 API/测试，冻结范围与谓词。
- [x] 新增并运行主机物体 + 唇区保护的 SDK 公开路径回归。
- [x] 给出具体二值蒙版调用说明，并同步当前 owner/状态文档。
- [x] archive-first no-skip 完整门禁、文档链接与保护文件哈希检查。

研究暂停的原挑战与处置见 [2026-10-03 冻结结果](../../../docs/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)。一般无蒙版自动识别与粗略唇域覆盖仍未合格；本轮只验证主机知道保护区域时的已有 API。

复核发现便捷检测注入器默认执行器为 CPU；新增回归已改用既有真实后端工厂，仍只注入源图对应的 face observation。首次仅 CPU 执行器的完整运行被停止、不计作完成凭证。真实后端聚焦回归重新通过 8/0/0；最终全门禁按新源摘要重新执行。

## 结果与验证

- 主机提供正确物体 + 完整唇区并集后，原深肤色唇缘反例也精确保留；另一侧皮肤仍满足原 20%/10% 方向门槛。无蒙版仍改动唇缘，自动守卫未修复。
- 新测试 4/0/0，原蒙版与新测试合计 8/0/0；64 个方向/镜像效果组合，CPU/GPU-selected 纹理路径及内存 PNG、typed failure/recovery、neutral/repeat、alpha/色彩空间/extent、全排除/平坦/无脸与无残留请求状态通过。接入示例类型检查通过。
- 本次 archive-first 完整 SDK 门禁返回 0：1076 tests / 0 failures / 0 skips，9 个 opt-in 测试身份全部执行。
- 边界扫描最初因新测试的既有 backend 类型引用尚未登记而拒绝。仅用原精确源摘要机制准入审阅的新测试（SHA `d88c1ef8eb25a5f2bfc2fb3f75a52f2d33782e6324ffbe6757361d2145e4c890`），追加 backend 声明自测继续拒绝。没有生产/API/GPU 算法改动。
- wrapper 自测 13/13、文档链接与 `git diff --check` 通过；1,756 个既有保护文件仅边界脚本是本任务明确修改项，其余 1,755 个哈希保持不变。原冻结生成源与失败挑战不变，未写入像素、蒙版、私有定位或 transcript。

具体用法见 [主机接入说明](../../../docs/HOST_TEXTURE_PROTECTION.md)。这是额外主机信息的已有 API 验收，通用自动识别和去脂继续暂停。
