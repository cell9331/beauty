# PLANS.md

> `beauty` 的当前执行入口。先读本页，再按链接读取当前计划或相关历史记录。
> 本页与 `plans/active/`、`plans/debt/current.md` 共同拥有当前计划和技术债；`plans/history/` 是历史快照。

当前图片效果验收政策见 [IMAGE_EFFECT_ACCEPTANCE.md](docs/IMAGE_EFFECT_ACCEPTANCE.md)。有权使用的生成肖像可作正负例；真人图片和真实设备是可选补充。历史记录中相反的要求不约束新工作。

## 1. 阅读路径与更新规则

1. 每次工作先读本页；涉及现行任务，再读下方 Active 条目和[当前技术债](plans/debt/current.md)。
2. 查询已完成事项时，先读[历史索引](plans/history/README.md)或[2026-10 已完成索引](plans/history/2026-10/README.md)及[终局处置索引](plans/history/2026-10/TERMINAL.md)，再打开匹配分片。可用 `rg -l '记录 ID 或关键词' plans/history` 定位，不必加载整个历史账本。
3. 开始工作前确认已有匹配计划，优先更新现有计划；每完成可验证步骤更新 checklist。
4. 阻塞需记录原因、尝试及下一步；完成后记录验证证据与剩余风险，移入 Completed。
5. 发现范围外问题写入当前技术债；契约变化同步更新对应根级 owner。未验证要写明原因。
6. 新 Active 计划各用一个 `plans/active/<ID>.md`；完成时将其全文移至 `plans/history/YYYY-MM/<ID>.md`，并更新本页与历史索引。2026-09-28 前的旧记录保存在索引所列分片中。

状态词：`planned` 待开始；`active` 推进中；`blocked` 等待条件；`verifying` 验证中；`completed` 已验证；`canceled` 明确取消并留原因；`closed_with_unmet_objectives` 有限尝试结束、目标未实现且无续作队列。

## 2. 当前边界

- 产品面是所有者自用的 SDK-only SwiftPM library 与 SDK-owned 验证；本账本不授予设备、商业视觉质量或外部分发资格。
- 真实设备反馈可成为后续发现，不是当前自动化完成门禁。效果方向、保护区、重复性、元数据及 typed failure 以实际输入/输出为准。
- 历史分片保留当时的状态与证据，现行 taxonomy 以 [SDK_EFFECT_TAXONOMY.md](docs/SDK_EFFECT_TAXONOMY.md) 为准。
- 去脂仍为 `suspended`、默认隐藏并保留显式兼容；自动同肤色贴片识别未实现。v1.25两分支各2方法4版本均失败，按所有者终局要求关闭未交付目标。现有host物体+完整唇并集蒙版继续可用；辅助能力不计自动交付。见[最终处置](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)。普通“继续”不重启、失败缺口不再作为计划阻塞；未来重开须明确新范围与新信息/资源。

## 3. Active

无活跃计划。v1.25已按`closed_with_unmet_objectives`结清；两个自动目标未交付，
不继续候选、G0、批量工具开发或模型工作。现有可用SDK能力不受此研发缺口阻塞。

## 3A. Historical Lifecycle Ledger（历史脚本锚点）

### A-2026-09-10-phase-93-registration-disposition（历史脚本查找锚点）

原记录已在[历史索引](plans/history/README.md)对应的 completed 分片。Phase 93 的 owner-local `93-CHECKS.json` 与 Phase 95 independent review 属于历史证据，不是当前 Active 计划。

## 4. Completed / terminal dispositions

以下分项按发生时刻保留；较早记录的“Next”、pending、2/16等是历史快照，
不覆盖最上方终局状态，不产生自动续作任务。

### C-2026-10-04-example-image-storage

- Status: `completed`。删除 1,800 个可重建缓存/重复文件，`example-images/`
  从约 5.4 GiB 降至 29 MiB，释放约 5.3 GiB；28 个必要夹具/清单文件原字节不变。
- Change: [存储工具](scripts/manage-example-images.py)提供 check/clean/preview；
  总计限制 128 MiB / 160 图，input 16 图 / 32 MiB，展示图 32 张 JPEG、单张
  512 KiB、长边 1600 px。已生成约 255 KiB 的压缩展示图；原尺寸验收输出用完删除。
- Verification: 存储回归 15/0/0、编码实际像素/元数据案例 3/0/0、wrapper
  14 checks / 14 mutation rejections；最终 archive-first 全量门禁退出 0，
  **1076 tests / 0 failures / 0 skips、9 opt-ins**，含新容量检查及全部原前置检查。
  文档链接、必要夹具摘要、重复清理和 `git diff --check` 通过。环境缓存权限
  导致的早期失败不算通过，最终全量在自动批准的正常缓存权限下运行。
- Record: [归档计划](plans/history/2026-10/A-2026-10-04-example-image-storage.md)。
  原有终局文档本地修改保留，SDK/API/效果资格与历史证据未变。

### C-2026-10-03-v1-25-terminal-disposition

- Status: `closed_with_unmet_objectives`，工程收尾已完成，两自动目标未交付。
- Result: EYE最后三版加此前E1-v1均失败，SEG四版均失败；各2方法×2版本原预算耗尽，不重置或追加。保留去脂suspended/default-hidden和host辅助保护，无新自动入口。
- Evidence: [终局实验与结果](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)、[行业复核](docs/RETOUCH_INDUSTRY_DECISION_2026-10-03.md)；新控制1/0/0、测量3/0/0，但效果运行器退出1。首轮编译失败保留，候选字节未改。
- Closure: [16项终局需求](.planning/REQUIREMENTS.md)为5 verified/11 closed_unmet，无算法资格提升；[归档计划](plans/history/2026-10/A-2026-10-03-v1-25-retouch-repair.md)保留全过程，旧路径仅导航。
- Verification: 本轮实际archive-first全量门禁退出0，**1076 tests / 0 failures / 0 skips、9 opt-ins**；归档、SDK-only boundary、backend/consumer/CPU oracle前置检查通过。2,201个既有源码/测试/冻结证据摘要不变，受保护目录无新增实现；当前链接与`git diff --check`通过。[聚合回执](scripts/experiments/retouch-terminal/results/closeout.json)不保存原始日志或图片。
- Next: 无。当前里程碑、phase和next队列已清空；重开须所有者明确新范围和信息/资源。


### C-2026-10-03-current-batch-validation

- Status: `completed`，仅指[当前批量工具](docs/CURRENT_BATCH_VALIDATION.md)及 BAT25-01/02；总需求2/16，Phase104的算法接入项及总里程碑未完成。
- Change: 新入口 `python3 -B scripts/current-batch/run.py`，独立98默认/99注册库存、两遍实际CPU输出、逐例像素/元数据/保护与明确oracle；通过、正常退出、效果失败、执行错误、缺项分列。旧75项wrapper/manifest/比较器保持只读。
- Verification: 工具17/0/0，含8真实像素控制和3文件/区域控制。默认98×2实际输出：7通过、91无脸正常退出，零失败/错误/缺项；自定义缺规则控制98×2：1通过、97未验证，正确退出3。
- Correction: 首轮误将skinCombo无脸退出列为必须提亮，退出1；原代码、契约和回执保留。依据既有resolver测试与DESIGN纠正，r1/r2全部98项测量及像素摘要一致，生产未改。
- Preservation: 2,179个既有源码、测试、脚本、冻结契约及历史文件摘要不变；SDK-only boundary、回执绑定、当前文档链接和`git diff --check`核对。未重跑完整SDK1076/0/0；不签98个人像效果、两个自动分支或设备资格。
- Next: 准备 EYE G0 的独立光影目标与控制；旧去脂保持suspended，E1-v1不直接续调。SEG四版预算耗尽，普通继续不追加候选。


### C-2026-10-03-seg-development-disposition

- Status: `completed`，仅指[有限开发比较与停止记录](docs/SEG_DEVELOPMENT_2026-10-03.md)。SEG 两方法四版本全部拒绝、原预算耗尽；自动功能、Phase 101 和 v1.25 均未完成，不追加第五版。
- Result: S1-v1 正/负例0/6、0/6；S1-v2为1/6、4/6；S2-v1为1/6、2/6；S2-v2为4/6、4/6且8/48比较保护硬失败，中肤色覆盖缺失。整图退出不计成功，冻结阈值、样本和原失败未改。
- Verification: 基线14/0/0，四候选各6/0/0仅为测量执行，效果运行器均退出1；正确 host 控制48项通过。观察/实际 public CPU/重复输出等价；接线前后153行基线及导出修正前后72行 S1-v1 一致。局部原尺寸视觉诊断已做，完整视觉资格、拒绝、旧唇回归、Metal和候选留出未做，不签 G1。
- Preservation: 2,111个既有源码、测试、脚本、冻结契约和历史文件哈希保持；SDK-only boundary、文档链接、聚合一致性和 `git diff --check` 核对。无生产/API/模型/训练变更；此前完整1076/0/0未重跑。
- Next: 继续独立的当前批量工具及 EYE G0 准备；旧去脂仍 suspended，E1-v1 保持拒绝，0/16需求完成。已完成的实验处置不代替两项自动功能交付。

### C-2026-10-03-seg-g0-freeze

- Status: `completed`，仅指 [SEG G0 验收准备](docs/SEG_G0_FREEZE_2026-10-03.md)。18 个独立源家族形成开发 12、留出 12、拒绝 6，共 30 逻辑案例、60 尺度栅格；SEG 全部 frozen，EYE 30 未准备，Phase 100 和 16 项正式需求仍未完成。
- Verification: 隔离 public CPU + 实际 Vision **20 tests / 0 failures / 0 skips**；96 项纹理控制、12 项拒绝栅格控制、128 次方向/镜像比较与输入故障恢复通过。支持覆盖 54.28–93.18%，平滑变化降低 33.92–56.12%，锐化增加 45.07–75.05%，保护违例与额外排除均为零。逐案例视觉记录、权利/来源/标记/栅格摘要及工具版本已冻结。
- Correction: 首轮回执收集失败，未计通过；改用独立原子聚合 JSON 后原输入原标准重跑成功。两轮 156 张本地复核图逐字节相同，旧版本和失败摘要保留。开发输入及判据未移动，没有算法预算重置。
- Preservation: 2,097 个既有生产/测试/脚本/历史文件摘要不变；SDK-only boundary、冻结绑定、60 案例状态、16 pending 需求、现行文档本地链接与 `git diff --check` 核对通过。
- Boundary: 留出只做 G0 可测性与正确 host 参考检查，候选留出评估仍为零；拒绝控制不是自动拒绝成功。生产/API/旧失败和上一轮开发控制保持不变，完整 SDK 1076/0/0 未重跑。下一步用冻结开发集验证自动候选；E1-v1 保持停止。

### C-2026-10-03-seg-g0-development-input-controls

- Status: `completed`，仅指 SEG 开发输入及局部控制。六个独立生成肖像形成 12 个配对案例、24 个双尺度栅格；完整 SEG G0 尚未通过。详情见 [进展记录](docs/SEG_G0_PROGRESS_2026-10-03.md)。
- Verification: 实际 Vision + public CPU 路径 **7 tests / 0 failures / 0 skips**，48 项效果控制通过；支持覆盖 54.28–69.69%，平滑变化降低 34.17–49.05%，锐化增加 46.63–65.40%，保护/alpha 无违例。观察器与公开输出逐字节一致；错网格恢复、neutral/repeat 和关键错误控制通过。这是正确 host 蒙版控制，不是自动识别结果。
- Corrections: r1 观察路径遗漏生产参数安全上限导致 8 个等价性失败，改为同一 resolver 后通过；r3 复核图未带家族前缀的问题在 r4 修正并重跑。原版本和聚合保留，皮肤 ROI、源栅格、贴片及阈值不变；补全脸外保护，未修改旧预检或生产实现。
- Preservation: 2,078 个既有生产/测试/脚本/历史文件摘要不变；SDK-only boundary、文档本地链接、回执与源码摘要绑定、60 案例状态、16 pending 需求和 `git diff --check` 核对通过。完整 SDK 1076/0/0 未重跑。
- Next: 开发 12 例为 controls_passed，其余 48 例 not_prepared，0 frozen。继续准备 SEG 的 12 个留出、6 个拒绝及其余控制/视觉复核，再冻结 G0；无自动候选或留出访问，方法/版本预算不增加，E1-v1 保持停止。

### C-2026-10-03-v1-25-development-pilot

- Status: `completed`，只指所有者允许的小规模预检。[结果](docs/RETOUCH_MVP_PILOT_2026-10-03.md)：S1-v1 在一个几何图家族的 12 正例/6 负例变体联合通过，保护无违例、平滑降低 50%、锐化增加约 250%、固定皮肤区支持 100%，负例双颊新增排除 0%。不是自然肖像或正式留出通过。
- EYE: E1-v1 全强度两眼分别改善 14.37%/0%，第一眼高通变化 13.45% 超过 10%；本候选拒绝并停止，不把单眼改善或降低目标当作整图通过。旧字段仍 suspended/default-hidden，两个正式效果都尚未交付。
- Verification: r3 控制 2/0/0（含 36 个 SEG 比较），候选测量 2/0/0，但运行器按真实判据退出 1；成功执行与算法失败分开。r1/r2 输入执行错误及源快照保留；实际 Core Image 预检定位缩放边缘 alpha，修加载器不改 SDK。两候选函数从 r1 到 r3 字节相同，每分支只用一个方法一个版本；未访问正式留出。
- Preservation: 2,063 个既有生产/测试/脚本/历史文件摘要不变；SDK-only boundary、13 份文档的 146 个本地链接与 `git diff --check` 通过。原尺寸输入/参考/候选代表图已查看，未授予上睑自然外观资格。正式 60 例仍未准备，16 需求仍 pending；此前完整 1076/0/0 未重新签发。

### C-2026-10-03-v1-25-g0-validation-design

- Status: `completed`，仅指 G0 的文档设计。新增 [验收准备方案](docs/RETOUCH_G0_VALIDATION_PLAN.md)与[逻辑案例清单](docs/RETOUCH_G0_CASE_MANIFEST.md)，两分支共 60 个唯一身份，全部 `not_prepared`；没有制作实际输入或实现验收器。
- Findings: 现有纹理函数只返回像素，新的处理支持覆盖指标尚无 public 观察面。方案规定以后使用隔离测试副本的请求内观察点，并先证明输出/错误/生命周期不变；不把变化像素数冒充覆盖，不新增公开原始蒙版。
- Verification: 60/60 身份唯一且开发/留出/拒绝数量正确，11 份文档本地链接/锚点通过，16 个需求继续 pending；`git diff --check` 通过。2,063 个既有代码、测试、脚本及历史文件哈希不变，受保护目录无新增实现文件。本轮未运行图片实验、SwiftPM 或新的候选。
- Next: 文档已具备可审查的实现交接。保持所有者“先规划、暂不写代码”的指示，明确进入验收器/输入准备实施后再执行 G0-A 至 G0-E；隔离实验、生成器和测试代码也属于实施。Phase 100 与效果资格尚未完成。

### C-2026-10-03-v1-25-mvp-requirements-r2

- Status: `completed`，仅指本轮需求规划与一致性核对。按所有者“降低初版标准、先规划不写代码”修订为 R2：自动上睑轻量光影修饰、可见边界同色贴片保护，有限覆盖/边缘误差、独立参考、G0–G3 和分支独立交付；未来强去脂/通用物体识别不作为初版门禁。
- Contract: [初版契约](docs/RETOUCH_MVP_REQUIREMENTS.md)统一定义数字和判定。先准备实际输入、验证正确/错误控制，再冻结并运行候选；不承诺任意未知输入皆可识别退出，也不把已有蒙版算自动成功。每分支有限开发预算，选定后一次留出评估，失败停止而不重置标准。
- Verification: 23 份现行/新快照文档本地链接和锚点通过，16/16 需求唯一映射 6 阶段，GSD 当前状态与下一步同步；两个历史归档和 post-archive SDK-only boundary 通过，`git diff --check` 通过。2,061 个既有代码/测试/脚本/档案和历史证据文件逐项哈希不变；降标前 requirements/roadmap 原字节复制为 R1 快照。
- Evidence boundary: 本轮无代码、测试源码、媒体/模型或已有历史证据修改，未运行新候选、生成新样本或重跑 SwiftPM。此前同日定向 5/0/0 与完整 1076/0/0 分别保留其原范围；新需求仍 0/16，G0 的实际输入/验收器尚未完成，去脂仍 suspended、99 注册/98 默认。
- Next: 按现行计划准备并冻结 G0 输入、独立目标参考与验收器；先证明验收有判别力，再做小规模算法可行性验证。

### C-2026-10-03-v1-25-milestone-creation

- Status: `completed`，仅指研究与里程碑建档完成，算法需求全为 pending。按所有者明确重开指示建立 v1.25：6 阶段、16 项需求，包括去脂新外观目标、命名同肤色遮挡域自动保护、唇区保护、当前批量工具与全量验收。预训练方法比较与资产准入分开，训练/微调不在本次范围。
- Research: 查阅 ABPN / ModelScope 官方 pipeline、Local Laplacian、FFaceNeRF、StyleRetoucher、FaceOcc / FaceExtraction、BiSeNet、FaceXFormer、SAM 2/3 的一手论文、作者代码/README 与相关许可；记录模型卡无法取得正文、权重/上游许可待核以及本地 CUDA 路径限制，未下载/执行候选。
- Verification: 16/16 需求各映射一次至 Phase 100–105；21 份现行/快照文档的 222 个本地链接（含 1 个锚点）检查通过。2,061 个既有生产、测试、脚本、档案和历史证据文件逐项哈希不变；旧当前 roadmap/requirements 原字节复制到新历史快照，既有 phase 目录/锁/回执未移动或改写。`git diff --check` 通过，GSD 当前里程碑识别为 v1.25。
- Boundary: 本次无生产算法/API 变更、模型推理/转换/训练、图片实验或 SwiftPM 重跑。此前真实完整检查点 1076/0/0、9 opt-in 未重新签发；旧自动探针 4/6/0 和去脂自然挑战 1/2/0 保持历史失败含义。去脂仍默认隐藏、效果 suspended；新研究授权不等于资格提升。
- Next: [现行计划](plans/active/A-2026-10-03-v1-25-retouch-repair.md) Phase 100，先冻结输入/目标/oracle。两自动效果需求未通过，不得以隐藏或研究处置按完整目标结项。

### C-2026-10-03-host-texture-protection-integration

- Status: `completed`。新增主机物体 + 完整唇区并集蒙版的公开路径回归与[接入说明](docs/HOST_TEXTURE_PROTECTION.md)。在原冻结生成源、双肤色与原目标/保护谓词下，物体与完整唇区源精确，对侧平滑变化降低至少 20%、锐化增加至少 10%。该额外主机信息不是自动分割，通用自动物体识别和去脂继续暂停；无蒙版粗略唇域未修复。
- Verification: 新回归 **4/0/0**、与原物体蒙版回归合计 **8/0/0**；64 个方向/镜像效果组合、CPU/GPU-selected 既有纹理路径、内存 PNG、neutral/repeat、RGB/alpha/extent/sRGB、全排除/无脸/平坦皮肤、错误网格恢复与后续无蒙版状态检查通过。接入示例通过 `swiftc -typecheck`。
- Full gate: `bash scripts/run-no-skip-swiftpm.sh` 实际返回 0，**1076 tests / 0 failures / 0 skips，9 opt-in**，archive-first 与 SDK-only boundary、backend/consumer/CPU oracle 门禁通过；wrapper 自测 13 checks / 13 mutation rejections 通过。最初静态门禁因新测试尚未登记既有 backend 引用而停，登记固定源摘要并 mutation 自测后重跑通过，未新增或放宽 GPU API。
- Preservation: 1,756 个既有生产/测试/脚本/历史文件中，仅边界脚本按既有审阅哈希机制登记新测试及追加声明拒绝自测；其余 1,755 个文件逐项哈希不变。原自动失败挑战 SHA 与 4/6/0 结果保持不变。文档链接与 `git diff --check` 通过，未改生产算法或公开 API。
- Record: [归档计划](plans/history/2026-10/A-2026-10-03-host-texture-protection.md)。后续任务需从明确的新范围进入，普通继续不重开已暂停算法。

### C-2026-10-03-texture-semantic-feasibility-disposition

- Status: `completed`，指有限可行性验证与范围处置完成。通用无蒙版同肤色物体自动辨认仍未完成且暂停，不提升效果状态；保留正确显式蒙版。原 15 项限定二维效果资格不变，去脂不重开。
- Result: 相同完整可观察输入不能满足矛盾材质语义输出；唯一周期纹理候选在保护物体时同时停掉有效皮肤处理，拒绝接入生产。新深肤色低对比唇缘越出粗略域的完整保护仍失败，作为未修复限制记录。
- Verification: 冻结挑战原宿主及外部临时 SwiftPM 包均为 **4 tests / 6 assertion failures / 0 skips，退出 1**，原显式蒙版回归 **4/0/0**；失败标准未改。完整 `bash scripts/run-no-skip-swiftpm.sh` 实际返回 0，**1072/0/0、9 opt-in**，archive-first、SDK-only boundary、wrapper 自测通过。两类结果分开引用；最初构建权限失败无测试结果，不算效果证据。
- Preservation: 1,751 个既有生产/测试/脚本/历史文件哈希未变；文档链接、Python 语法及 `git diff --check` 通过。没有生产 API/算法改动，没有模型、训练或设备声明。
- Record: [冻结结果](docs/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)、[全文归档计划](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)及[新月度索引](plans/history/2026-10/README.md)。以后若扩展自动能力，需明确可观察的新域和独立正负例后另行授权。

### C-2026-10-01-all-feature-completion-inventory

- Status: `completed`。完成[全部功能与完成状态清单](docs/FEATURE_COMPLETION_INVENTORY_2026-10-01.md)：逐项列出 77 参数字段、11 配置字段、5 预设、2 滤镜及 SDK/工程支撑项目；将限定范围内已完成、当前活跃缺口、去脂暂停、未覆盖能力和范围外产品面分别标明。63 行旧控制映射全部由参数表覆盖，别名不计成独立算法。
- Verification: 参数/配置字段与源码、控制映射与现行 taxonomy、资源与 manifest 静态逐项核对通过；本地链接、post-archive SDK-only boundary、保护文件哈希及 `git diff --check` 通过。仅盘点文档，未重跑 SwiftPM 或图片效果验收；此前 `1072/0/0` 保留原检查点含义。
- Remaining at 2026-10-01: 盘点当时的活跃能力缺口为无排除蒙版时同肤色非皮肤物体自动辨认；该项后于 2026-10-03 有限研究处置中暂停。去脂暂停、历史批量 wrapper 库存技术债和其余泛化/输入/设备限制均按原状态列出，本清单不创建新研发任务。

### C-2026-10-01-current-document-drift-repair

- Status: `completed`。修复[项目审计](docs/PROJECT_STATUS_AUDIT_2026-10-01.md)的 D01–D03、D05–D07 六组漂移：统一 `.planning` 当前状态/恢复入口，明确旧回执和旧代码地图的历史范围；产品正文收敛为原 15 项最终二维适用域，移出中途 partial 叙述；可靠性说明区分整脸上下的 provider 五点与静图刚性平移，并区分九个 opt-in 测试身份和五个显式环境输入；动态源码库存改为带日期的单一记录与复算命令。
- Verification: 两个 legacy 归档、post-archive SDK-only boundary、mandatory wrapper 自测（13 checks / 13 mutation rejections）与 `git diff --check` 通过；19 份文档的 171 个本地链接（含 2 个锚点）和 1 个入站锚点引用通过；15 项控制与 taxonomy、77 字段、99/98 清单、九个测试身份/五个环境输入静态核对通过。2,144 个受保护代码/脚本/既有历史证据文件哈希未变。仅文档修复，未重跑 SwiftPM 或效果验收；此前 `1072/0/0` 保留其原检查点含义。
- Remaining: 历史批量 wrapper 的 75 案例限制仍为独立技术债；同肤色物体无蒙版自动辨认仍是当前能力缺口。去脂继续 `suspended`，不恢复研发。

### C-2026-10-01-project-status-and-document-drift-audit

- Status: `completed`。完成[项目进度与文档漂移审计](docs/PROJECT_STATUS_AUDIT_2026-10-01.md)：当前 77 参数、99 注册/98 默认案例、63 taxonomy 行中的 62 implemented + 1 suspended 与源码/现有测试对齐；原 15 项限定二维验收已完成，去脂暂停，同肤色物体自动辨认仍未完成。
- Findings: 确认 6 组文档问题，包括 `.planning` 当前状态/旧回执恢复入口、产品段落仍称 partial、上下移动路径、重复库存和 opt-in 测试/环境变量数量。纹理旧描述已有明确替代说明，已排除为当前漂移。确认项已记入技术债，本轮未批量修正文档、未启动旧阶段或算法研究。
- Verification: 归档验证、post-archive SDK-only boundary 和 CLI 只读清单通过；2,188 个代码/既有历史基线文件未变。最近完整门禁仍为此前实际执行的 `1072/0/0`、9 opt-in，本轮不重复签发。报告列出每项代码/测试依据及审计局限。

### C-2026-10-01-upper-eyelid-document-contract-rewrite

- Status: `completed`。按所有者要求重写去脂文档：以实际有界亮度修正说明现有机制；取消“已实现/弱效果可用但继续优化”的现行承诺，明确自然外观效果未合格；从当前计划和技术债移除重复实验及旧执行指令。历史事实与失败证据保留，暂停不等于算法完成。
- Verification: 27 份文档的 182 个本地链接（含 1 个锚点）、post-archive SDK-only boundary、`git diff --check` 与交叉复核通过；2,188 个受保护代码/既有历史文件的逐文件哈希未变。项目技能中的旧续作说明也已同步清理，原 spike 源未改。本轮仅文档，未重跑 SwiftPM、未重启算法实验；此前 `1072/0/0` 是代码变更检查点结果，不冒充本轮新测试。

### C-2026-10-01-upper-eyelid-suspension

- Status: `completed`。按所有者允许的收尾方向，暂停去脂研发并从 SDK-owned renderer 默认清单、批量和推荐示例隐藏；保留 public 字段、显式 CLI 旧名、安全回归和失败证据。自然图效果未合格，不把处置完成写成算法完成；只有明确重启授权才恢复研发。
- Verification: 新增真实 CLI 默认批量与显式兼容测试 `2/0/0`；完整 `bash scripts/run-no-skip-swiftpm.sh` 返回 0，`1072 tests / 0 failures / 0 skips`、9 opt-in，archive-first 与 SDK-only boundary 通过；边界脚本自测及独立审查通过。当前 77 参数字段、99 注册项、98 默认项。详情见 [归档处置记录](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)和[质量记录](QUALITY_SCORE.md)。

### C-2026-09-28-progressive-planning-ledger

- Status: `completed`。将原 250 条 completed / lifecycle 记录、当前 Active 正文、当前与历史技术债、模板和历史附录拆分；本页保留当前状态与导航。原声明与状态不变，24 个相对链接改为指向原仓库文件的新路径。
- Verification: 与拆分前 `PLANS.md` 对照，35 条 completed、215 条 lifecycle 记录、Active、技术债、模板和附录均完整；迁移后的 Markdown 链接全部可解析。`git diff --check` 和 post-archive SDK-only boundary 通过；Phase 93 自测 `108/0/0`、Phase 94 自测 `16/0/0`；`bash scripts/run-no-skip-swiftpm.sh` 返回 0，8 个 opt-in 全执行、0 skip。历史回执未修改或重签。

最近已完成事项从[历史索引](plans/history/README.md)进入；2026-09-27 的 SDK 效果和风险记录在 [completed-01](plans/history/completed-01.md)。归档材料和旧回执不因本次移动而重新签发。

## 5. Tech Debt

- [当前技术债](plans/debt/current.md)：发际线语义、不足的泛化和皮肤语义边界；已完成或有界处理事项在正文按原记录说明。
- 历史账本导航限制（本轮发现，不阻塞终局）：`.planning/MILESTONES.md`旧v1.16/v1.19/v1.20段有9个链接仍指向迁移前路径；HEAD中已存在，实际文件在`.planning/milestones/`，历史正文未改。本轮当前文档及新增终局段链接单独核对。
- [历史技术债](plans/debt/historical.md)：Phase 95 当时发现及 TD-001 至 TD-024 状态快照。历史状态不能直接用作当前缺陷清单。

## 6. 模板与验证

新计划、完成记录和验证日志格式见 [TEMPLATES.md](plans/TEMPLATES.md)。仅文档调整也须记录差异校验和对应文档门禁；SwiftPM 全量门禁只有运行成功时才能写为通过。

## Phase94 Historical Final Owner Snapshot（历史脚本查找锚点）

此锚点复述当时封存条件，原文在[历史验证附录](plans/history/legacy-verification-appendix.md)。
Status: verifying (snapshot before independent goal decision).
MOUTH-01 的 Phase94 current41/41 验收绑定 CHECKS SHA256 `fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`；Phase95 与 full no-skip 是独立门禁。
当时 `94-REMAINING-COMPLETE.json` 缺失、过期或失败均意味着 incomplete；该历史条件不改变当前计划状态。
