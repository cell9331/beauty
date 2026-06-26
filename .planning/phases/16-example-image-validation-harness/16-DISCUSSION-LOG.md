# Phase 16: Example Image Validation Harness - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-26
**Phase:** 16-example-image-validation-harness
**Areas discussed:** Phase 16 收口口径, 验证证据标准, 输出证据保存策略, 几何输出限制写法, fixture 输入规则

---

## Phase 16 收口口径

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Phase 16 应该按什么口径收口？ | 记录现状 | 把已完成的 renderer 准备工作正式沉淀为 Phase 16，不再扩展实现范围。 | ✓ |
| Phase 16 应该按什么口径收口？ | 轻量加固 | 允许 planner 补少量验证/文档 hardening 任务后再收口。 |  |
| Phase 16 应该按什么口径收口？ | 重新实现 | 把 renderer 当作未完成，重新规划实现和验证。 |  |
| Phase 16 的计划应该如何组织？ | 两段式 | 保留 roadmap 的 `16-01` renderer 验证、`16-02` 文档/账本收口。 | ✓ |
| Phase 16 的计划应该如何组织？ | 单计划 | 合并成一个 formalization plan，流程更短但证据颗粒度较粗。 |  |
| Phase 16 的计划应该如何组织？ | 三计划 | 拆为实现、验证、文档三步，记录更细但可能重复已完成工作。 |  |
| Phase 16 是否允许修改产品代码？ | 只修阻断 | 只允许修编译/运行阻断问题；不主动扩展 renderer 功能。 | ✓ |
| Phase 16 是否允许修改产品代码？ | 可小改 | 允许小幅调整 CLI case、watermark 或文档一致性。 |  |
| Phase 16 是否允许修改产品代码？ | 不改代码 | 只写 GSD artifacts，不碰 `BeautySDK` 或 docs 内容。 |  |
| PREP-01 到 PREP-04 的完成判定依据是什么？ | 复跑验证为准 | 用本次 Phase 16 命令输出重新证明，再标记完成。 | ✓ |
| PREP-01 到 PREP-04 的完成判定依据是什么？ | 采信既有记录 | 沿用 `PLANS.md` 已记录的 v1.3 prep 验证证据。 |  |
| PREP-01 到 PREP-04 的完成判定依据是什么？ | 二者都要 | 引用既有记录，同时复跑最小命令防止状态漂移。 |  |

**User's choice:** `1A, 2A, 3A, 4A`
**Notes:** 用户选择记录现状、两段式计划、只修阻断、以本次复跑验证作为完成依据。

---

## 验证证据标准

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Phase 16 完成时必须复跑哪些命令？ | 最小复跑 | `swift build --product BeautyExampleRenderer` + 单 case renderer + `file` 尺寸检查。 | ✓ |
| Phase 16 完成时必须复跑哪些命令？ | 完整复跑 | 最小复跑 + `swift test --package-path BeautySDK`。 |  |
| Phase 16 完成时必须复跑哪些命令？ | 全 case 复跑 | 构建后运行所有内置 case，并检查输出数量。 |  |
| 单 case 默认用哪个 case？ | `skinWhitening_0p50` | 已有记录使用它，输出文件和文档都对齐。 | ✓ |
| 单 case 默认用哪个 case？ | `skinCombo_0p50` | 覆盖更多基础皮肤参数，但比较难定位单参数变化。 |  |
| 单 case 默认用哪个 case？ | `filter_warmLight_0p50` | 能证明资源/滤镜路径，但不代表基础皮肤路径。 |  |
| 视觉抽查要写到什么程度？ | 简短人工观察 | 确认水印可读、不盖脸、输出非空，不做主观美感评价。 | ✓ |
| 视觉抽查要写到什么程度？ | 只写机器检查 | 只记录尺寸/文件类型，不写人工观察。 |  |
| 视觉抽查要写到什么程度？ | 更详细视觉验收 | 记录皮肤变化、水印位置、输入/输出对比观感。 |  |
| 失败时怎么处理 Phase 16？ | 阻断收口 | build/run/file 任一失败就不标记 PREP 完成，先修阻断。 | ✓ |
| 失败时怎么处理 Phase 16？ | 记录为已知问题 | 允许 CONTEXT/PLAN 继续，但 SUMMARY 记录未完成项。 |  |
| 失败时怎么处理 Phase 16？ | 只阻断 build | 运行输出失败可作为后续 Phase 18/19 的问题。 |  |

**User's choice:** `1A, 2A, 3A, 4A`
**Notes:** 用户选择最小复跑证据、默认 `skinWhitening_0p50`、简短视觉观察，并让任一验证失败阻断收口。

---

## 输出证据保存策略

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| `example-images/out/` 的定位是什么？ | 本地临时验证输出 | 继续被 git ignore，不作为长期证据目录。 | ✓ |
| `example-images/out/` 的定位是什么？ | 半正式输出 | 仍 ignore，但 SUMMARY 必须列出本次生成的文件名。 |  |
| `example-images/out/` 的定位是什么？ | 正式输出 | 挑选部分 PNG 进入版本库或 evidence 目录。 |  |
| `.planning/evidence/v1.3/` 是否要新增图片证据？ | 不新增图片 | Phase 16 只记录命令、文件类型、尺寸、人工观察文字。 | ✓ |
| `.planning/evidence/v1.3/` 是否要新增图片证据？ | 新增文字证据文件 | 创建 `VISUAL-EVIDENCE.md`，不提交 PNG。 |  |
| `.planning/evidence/v1.3/` 是否要新增图片证据？ | 新增 PNG 截图/样图 | 保留代表性输出图作为 planning evidence。 |  |
| 输出文件存在旧结果时怎么处理？ | 覆盖同名输出 | renderer 当前行为可直接覆盖，SUMMARY 记录本次命令。 | ✓ |
| 输出文件存在旧结果时怎么处理？ | 执行前清空 out | 避免旧文件混入，但会删除本地临时样图。 |  |
| 输出文件存在旧结果时怎么处理？ | 写时间戳目录 | 每次保留独立结果，但会偏离现有文档规则。 |  |
| SUMMARY 里如何描述输出？ | 只列关键样例 | 记录 `e2__skinWhitening_0p50.png` 与尺寸匹配。 | ✓ |
| SUMMARY 里如何描述输出？ | 列出全部生成文件 | 更完整，但 Phase 16 默认只跑单 case。 |  |
| SUMMARY 里如何描述输出？ | 只说命令通过 | 不列文件名，减少维护成本。 |  |

**User's choice:** `1A, 2A, 3A, 4A`
**Notes:** 用户选择 `example-images/out/` 继续作为 ignored 本地临时输出，不新增 v1.3 图片 evidence，允许覆盖同名输出，并在 SUMMARY 只列关键样例。

---

## 几何输出限制写法

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Phase 16 对几何类分支的完成口径是什么？ | 明确不算视觉完成 | Phase 16 只记录限制，几何保存图输出由后续阶段补齐。 | ✓ |
| Phase 16 对几何类分支的完成口径是什么？ | 预留但不阻断 | Phase 16 添加 placeholder case 名称，但不运行。 |  |
| Phase 16 对几何类分支的完成口径是什么？ | 强制当前补齐 | Phase 16 必须让几何类也产出可见图。 |  |
| 文档里如何表述几何限制？ | blocked by integration | 已有 provider/test，但缺 face detection + geometry render image-output integration。 | ✓ |
| 文档里如何表述几何限制？ | future only | 把几何类都视为未来能力，避免误会。 |  |
| 文档里如何表述几何限制？ | partial visual | 称为部分视觉可用，但保存图还没接好。 |  |
| 后续哪个阶段负责补齐几何保存图？ | Phase 19 | Beauty Shaping Core Modules 负责塑形/五官几何输出状态和验证。 | ✓ |
| 后续哪个阶段负责补齐几何保存图？ | Phase 18 | 皮肤阶段顺手补 harness 视觉输出能力。 |  |
| 后续哪个阶段负责补齐几何保存图？ | Phase 20 | closeout 阶段统一补所有缺口。 |  |
| Phase 16 是否要定义后续接入条件？ | 定义条件 | 只有 public facade 能从 `example-images/input/` 产出同尺寸水印 PNG，才算图像证据。 | ✓ |
| Phase 16 是否要定义后续接入条件？ | 不定义 | 后续阶段自行决定。 |  |
| Phase 16 是否要定义后续接入条件？ | 只要求测试 | 只要 provider/unit tests 通过就可声明完成。 |  |

**User's choice:** `1A, 2A, 3A, 4A`
**Notes:** 用户选择明确不把几何分支算作 Phase 16 视觉完成，限制写成 integration blocker，并把补齐责任放到 Phase 19。

---

## fixture 输入规则

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| `example-images/input/` 在 Phase 16 的规则是什么？ | 固定当前 5 张 | Phase 16 只验证现有样例可运行，不扩大 fixture 策略。 | ✓ |
| `example-images/input/` 在 Phase 16 的规则是什么？ | 定义最低覆盖 | 至少正脸、侧脸、不同光照等，但不一定现在补齐。 |  |
| `example-images/input/` 在 Phase 16 的规则是什么？ | 立即扩展样例 | Phase 16 要新增更多输入图。 |  |
| 输入图片是否纳入版本库？ | 保留为当前项目样例 | 输入样例是验证入口，允许被追踪；输出继续 ignore。 | ✓ |
| 输入图片是否纳入版本库？ | 全部本地化不追踪 | 输入输出都作为本机临时文件。 |  |
| 输入图片是否纳入版本库？ | 只追踪合成图 | 真人/参考图不进版本库。 |  |
| fixture 命名规则要不要在 Phase 16 锁定？ | 轻量锁定 | 接受 `e1.png` 到 `e5.png`，后续新增用短稳定 ID。 | ✓ |
| fixture 命名规则要不要在 Phase 16 锁定？ | 详细锁定 | 要求语义命名、尺寸、光照/姿态标签。 |  |
| fixture 命名规则要不要在 Phase 16 锁定？ | 不锁定 | 只要 renderer 能枚举 PNG/JPEG 即可。 |  |
| 后续阶段新增 fixture 时需要什么约束？ | 必须更新验证文档 | 新增样例或 case 要同步 `EXAMPLE_IMAGE_VALIDATION.md`。 | ✓ |
| 后续阶段新增 fixture 时需要什么约束？ | 只更新 SUMMARY | 执行阶段记录即可，不改长期文档。 |  |
| 后续阶段新增 fixture 时需要什么约束？ | 不要求记录 | fixture 是实现细节。 |  |

**User's choice:** `1A, 2A, 3A, 4A`
**Notes:** 用户选择固定当前五张输入，输入样例作为验证入口保留，轻量锁定命名，并要求后续新增 fixture/case 时同步长期验证文档。

## Agent 自由裁量

- None.

## Deferred Ideas

- Expanding fixture coverage beyond the current five images.
- Adding new renderer cases before later phases change visible module behavior.
- Saved-image geometry output for shaping/facial-feature branches.
- Long-term visual QA, perceptual diffing, production render quality, hardware parity, and release-like naturalness.
