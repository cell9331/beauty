# 当前 SDK 批量验证工具

2026-10-03。Phase104 的独立工程交付，算法分支未合格不阻塞此工具。
实现入口：`python3 -B scripts/current-batch/run.py`。旧75项脚本、manifest、比较器
及历史回执保持只读；本入口不重新研发 SEG/EYE，不改变默认98/注册99的范围。

## 先固定的工具契约

1. [独立库存](../scripts/current-batch/inventory.json)明确列出98个有序默认身份和
   一个仅显式兼容的旧去脂身份。它从已有规范测试核对后冻结，不在运行时从
   CLI输出生成。构建当前 renderer，实际 `--list-cases` 必须逐项、逐序一致，
   重复、缺失、同数量替换、意外恢复隐藏项均拒绝。注册源摘要同时绑定99项。
2. 每次使用新建的忽略目录，只处理显式本地 PNG 或代码生成图，固定 CPU、
   `--no-watermark`。源文件先校验摘要并复制为逻辑身份；默认批量执行两遍，
   精确核对报告身份、数量、状态和实际文件集合，再逐案例比较像素。
3. 全部图像要求有效 opaque sRGB、有限尺寸、方向为正向；输出尺寸/色彩空间/
   alpha保留、重复像素一致。逐例 oracle 来自执行前的 suite，源精确、正常
   退出或方向/保护条件分开。没有 oracle 记 `unverified`，不能补成成功。
4. `passed`、`abstained`、`effect_failed`、`execution_error`、`unverified`
   分列；缺失/重复/非预期产物属于执行错误。非零子进程不因已有PNG或报告声称
   succeeded而通过。退出0仅表示本批次声明的像素契约通过（可含明确正常退出），
   1为效果失败，2为执行/输入错误，3为验收缺项。
5. 不输出私有路径、标记、像素或子进程原始日志。新建运行目录内保存本地图片，
   请求文件用后清理；持久汇总只含逻辑ID、摘要、计数和有限指标。结果不更新
   SDK效果 taxonomy，不代替真人/设备/商业质量或两个自动分支的 G1–G3。

## 默认工具自验输入

采用固定256×192不含人脸的彩色渐变，先定义判据再运行：90个依赖人脸的默认
案例预期正常源精确退出，neutral源精确通过；其余7个全局颜色案例按明确方向
检查亮度、红蓝差或亮度标准差。亮度/红蓝差至少增加1个8位码值，对比度的
亮度标准差至少增加0.1；全部上限64，保持alpha、sRGB、尺寸及重复性。
变化像素数仅作诊断，不能单独决定效果通过。这是工具与无脸行为测试，不是
98种人像正例效果重新验收。测试须用错误方向、无变化、保护泄漏和报告损坏
等控制证明分类器会失败，不能只跑全绿正常路径。

## 本地 suite

`--suite <ignored-local.json>` 支持所有者已定义参考的有权本地使用的输入。
JSON包含 `schema: beauty.current-batch.suite.v1`、`fixtures`；每个 fixture
有唯一逻辑 `id`、本地 `path`、`sha256` 和 `oracles`（以规范case ID为键）。
不读取目录中的其他图片；最多4输入，每个≤16MiB、≤1,048,576像素。

oracle 的 `kind` 为 `exact`、`abstain` 或 `metrics`。metrics 必须有非空
`checks`，每项为 `metric`、`minimum`、`maximum`；metric支持 `luma_delta`、
`contrast_delta`、`red_blue_delta`。可给 `target` 和 `protected`，均为归一化
矩形 `[x0,y0,x1,y1]`，后者所有像素必须源精确。这些标记仅送比较器，renderer
和算法不接收。私有 suite 不得用候选输出反向制作，工具通过不能证明作者独立性。

`--preflight-only` 仅构建并检查库存，明确输出 `preflight_only`，不签像素验收。
成功或失败汇总存入每次新建的 `.build/current-batch/` 运行目录；控制台只打印
聚合JSON。运行错误的固定原因码与工具边界测试见对应实现和测试。
