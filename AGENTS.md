# AGENTS.md

适用于本仓库。`beauty` 是 **SDK-only SwiftPM** 项目：`BeautySDK/` 提供所有者本地
App、工具与验证程序使用的 library 和命令行 renderer；不面向第三方分发。
沟通以结论、实际验证和必要决策为主，无需逐步播报。

## 开始工作

1. 读本页和 [PLANS.md](PLANS.md)，检查 `git status --short`，识别已有及并行改动。
2. 按下方任务表只读匹配的契约文档、现行计划、相关代码和测试；历史材料按需查找。
3. 明确要改变的行为、保留的契约与最小充分验证，再编辑。优先更新已有匹配计划。

用户在当前任务中的明确授权决定工作范围；不要从历史计划、参考材料或“继续”推导新授权。
代码/测试用于核实实际行为，契约文档定义要求，计划记录执行状态，回执只证明其注明的
日期、输入与检查范围。发现不一致时查明是实现缺陷还是文档漂移并在本次范围内修正；
不要用“代码优先”取消安全要求，也不要把计划或旧测试通过写成已交付效果。

## 必须保留的边界

- **所有者自用**：Swift `public` 是访问级别；不授权向所有者控制环境外分发源码、
  二进制、模型/权重、私有夹具或派生数据。改变此边界须所有者明确新范围及许可、
  安全、隐私、兼容和产品审查；自用仍须满足实际用途许可证。
- **SDK 与宿主分离**：不在仓库新增或恢复应用源码、UI、lifecycle 或 UI automation。
  已单独授权的外部宿主由 [FRONTEND.md](FRONTEND.md) 及其自身文档约束；本仓库任务
  不自动扩大到宿主。历史 UI/Demo 先验证归档，只恢复到仓库外的新临时目录。
- **保留工程边界**：retained `Warp.metal` 与既有 Metal/GPU API/backend 受
  `scripts/check-sdk-only-boundary.sh` 约束；默认不改。现行 SDK 算法按授权计划推进。
  已批准的固定 MediaPipe 依赖/模型见
  [SECURITY.md](SECURITY.md)；不据此授权其他下载、训练、微调、数据采集或分发。
- **保留效果处置**：去脂 `suspended`、默认隐藏，保留 `upperEyelidFullnessReduction`
  字段、零默认值、Codable、显式调用、
  `BeautyExperimentalUpperEyelid*` 和安全测试。v1.25 自动 EYE/SEG 为
  `closed_with_unmet_objectives`，未交付且无自动续作；重开须明确新范围和新假设、
  信息或资源。现行状态由 [taxonomy](docs/SDK_EFFECT_TAXONOMY.md) 和
  [最终处置](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md) 拥有。
- **保护工作与证据**：不覆盖未要求修改的本地变更；历史归档、冻结契约、阈值、
  失败和既有回执只读。raw pixels、masks、landmarks、私有夹具路径和 child transcripts
  不写入持久证据；授权媒体留在本地 ignored/临时区域，仅记录允许的聚合数据。
- **精确管理存储**：`BeautySDK/.build` 含冻结夹具/回执，不能整树删除。清理前核对
  用途、引用及 tracked/ignored 身份，只删已确认可重建产物。示例图容量、预览和
  清理规则由 [example-images/README.md](example-images/README.md) 拥有。

## 按任务读取与更新

| 任务 / 契约变化 | 文档 owner 与指南 |
| --- | --- |
| Target、依赖、处理路径 | [ARCHITECTURE.md](ARCHITECTURE.md) |
| 参数、输入、状态、组合、结果 | [DESIGN.md](DESIGN.md) |
| 所有者可调用行为、使用旅程 | [PRODUCT_SENSE.md](PRODUCT_SENSE.md)；实现指南从 [docs/sdk/](docs/sdk/README.md) 进入 |
| 错误、恢复、日志、性能与资源边界 | [RELIABILITY.md](RELIABILITY.md) |
| 隐私、输入/资源信任、许可、归档 | [SECURITY.md](SECURITY.md) |
| 效果分类、参数映射与资格 | [SDK_EFFECT_TAXONOMY.md](docs/SDK_EFFECT_TAXONOMY.md) |
| 图片效果验收、批量像素检查 | [IMAGE_EFFECT_ACCEPTANCE.md](docs/validation/IMAGE_EFFECT_ACCEPTANCE.md)、[validation/](docs/validation/README.md) |
| 测试范围、质量门禁、回执与动态库存 | [QUALITY_SCORE.md](QUALITY_SCORE.md) |
| 历史 UI/Demo 或外部宿主边界 | [FRONTEND.md](FRONTEND.md)、[归档指南](archives/legacy-ui/README.md) |
| 当前工作与范围外发现 | [PLANS.md](PLANS.md)、匹配 Active 计划与[当前技术债](plans/debt/current.md) |
| 文档分类、导航、漂移修复 | [docs/README.md](docs/README.md)、[QUALITY_SCORE.md](QUALITY_SCORE.md) |
| Git 提交、推送、拉取、权限 | [GIT_OPERATIONS.md](docs/operations/GIT_OPERATIONS.md)；复用仓库已验证 SSH 身份，不改全局账号 |

Local-retouch、隐私或夹具工作还须读取项目技能
[spike-findings-beauty](.codex/skills/spike-findings-beauty/SKILL.md)。技能与参考手册中的历史
方案不能替代现行契约或激活已关闭研究。`.planning/` 保存 GSD 状态及日期证据，当前任务
仍从 PLANS 进入，不从旧 phase 的 next-step 恢复。

## 验证：先选范围，再运行命令

所有命令从仓库根运行。以改动和直接调用路径选择检查；共享模块仅按具体依赖扩大范围。
普通修复/功能不例行全量回归，也不扩展设备、字体或方向矩阵。

| 条件 | 检查入口 |
| --- | --- |
| 仅文档 | 本地链接/锚点、声明依据、保护文件摘要与 `git diff --check`；附加检查按 QUALITY 的条件表选择 |
| SDK 行为或缺陷 | `swift test --package-path BeautySDK --filter '<相关测试类或用例>'`，记录实际执行与 skip；不以空执行作为通过 |
| 需要编译验证 | `swift build --package-path BeautySDK`；复用增量缓存 |
| CLI 说明变化 | `swift run --package-path BeautySDK BeautyExampleRenderer --help`；像素效果另跑对应 oracle |
| 归档或 SDK-only 边界声明变化 | `python3 -B scripts/archive-legacy-ui.py verify --output archives/legacy-ui`；`bash scripts/check-sdk-only-boundary.sh --post-archive`，按需运行其 `--self-test` |
| 门禁流程/声明变化 | `bash scripts/run-no-skip-swiftpm.sh --self-test`；这是控制自测，未执行完整 SDK 测试 |
| 新增/生成示例图 | `python3 -B scripts/manage-example-images.py check` |
| 明确的完整 SDK 里程碑 closeout | `bash scripts/run-no-skip-swiftpm.sh`：archive-first、all-opt-ins、非零执行、zero-failure/zero-skip |

完整 closeout 与普通定向验证是不同范围；其他必须全量的情形先说明局部检查不足的具体原因。
不得以关闭 verifier、跳过门禁或空命令缩小检查。plain `swift test` 可能跳过 opt-ins，
不能代替完整 closeout。确有执行/验证代理时，同样传递此范围。

图片效果须用实际输入/输出验证方向、负例不恶化、目标/保护区、容差、确定性、neutral、
适用元数据与 typed failure；脚本成功或变化像素数不能替代效果正确。授权生成肖像可作
合格输入；真人照片与真实 iPhone 默认是可选补充，不阻塞自动化完成或 taxonomy 提升。
未测设备性能、温升、耗电、长稳及一般外观质量不作声明；工程通过不授权外部分发。

## 完成交付与文档维护

- 复用现有 Target、命名和抽象；变更行为时同步所属 owner 和相关测试，不为格式偏好
  扩大重构。新增所有者可调用 API 同步 PRODUCT_SENSE，新增风险同步 SECURITY。
- 每个契约只在一个 owner 定义，其他文档直接链接；AGENTS 只放长期行动规则与入口。
  当前正文替换失效说法，历史记录保留原日期与范围，不叠加互相覆盖的补丁说明。
- 完成后更新匹配计划/checklist 和 PLANS 摘要：改了什么、为什么、实际检查及结果、
  未验证项和剩余风险。范围外发现进入技术债，不自动启动下一任务。
- 完成记录用 [plans/TEMPLATES.md](plans/TEMPLATES.md)。不把旧回执、未验证的并行
  代码或参考提案写成此次通过；长期决定落到仓库文本。
