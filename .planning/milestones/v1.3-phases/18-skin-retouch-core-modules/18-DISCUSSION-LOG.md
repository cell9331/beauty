# Phase 18: Skin Retouch Core Modules - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-27
**Phase:** 18-Skin Retouch Core Modules
**Areas discussed:** Basic skin ambition, Face and no-face skin behavior, Future branch promotion, Verification threshold

---

## Basic Skin Ambition

| Option | Description | Selected |
|--------|-------------|----------|
| 改进公式 | 保留现有四个公开 skin 参数，允许改进当前 `BeautyColorEffectPipeline` 里的皮肤输出公式，并补测试和 renderer 证据。 | ✓ |
| 只加证据 | 不改算法输出，只审计现有行为、补足测试、示例输出和文档状态。 | |
| 新增参数 | 扩展公开 skin 参数模型，需要同步根级契约和兼容边界。 | |

**User's choice:** 改进公式。  
**Notes:** 中等强度应自然保守；实现深度限制在现有管线，不新增 pass/target；`skinSmoothing` 保持轻量柔化代理，不做真实局部修复。

---

## Face and No-Face Skin Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| 保持 facade 可见 | 公开 facade / renderer 路径继续让 Basic skin 在无检测或未运行检测时产生轻量全图输出。 | ✓ |
| 严格人脸依赖 | 无脸或未检测时跳过 Basic skin，只保留 color/filter。 | |
| 混合策略 | 部分 skin 参数全图，部分参数需要人脸或更严格降级。 | |

**User's choice:** 保持 facade 可见，并明确分层解释。  
**Notes:** 公开 facade 无检测时 Basic skin 可以全图输出；显式 no-face resolver 上下文可跳过 skin，用于未来检测集成。未来低质量人脸可保守弱化并记录 redacted result metadata，不新增 UI 文案或几何 payload。

---

## Future Branch Promotion

| Option | Description | Selected |
|--------|-------------|----------|
| 不提升 | Skin repair、Teeth/hairline 保持 `future`，Phase 18 只澄清边界。 | ✓ |
| 只做设计预备 | 不实现输出，但补更具体的未来参数/算法/降级设计。 | |
| 提升窄子集 | 实现很小本地-only 子集，例如 texture cleanup 或 teeth whitening。 | |

**User's choice:** 不提升 future 分支。  
**Notes:** Phase 18 应加入防误实现扫描，确认没有新增 public parameters、renderer cases、resource ownership、segmentation/AI/upload、teeth/hairline 输出声明。文档语气应明确禁止当前实现和完成声明。

---

## Verification Threshold

| Option | Description | Selected |
|--------|-------------|----------|
| 聚焦 + renderer | 跑相关 XCTest、`BeautyExampleRenderer` build/run skin cases、尺寸检查、负向扫描。 | ✓ |
| 全 SDK 测试 + renderer | 跑完整 SwiftPM 测试和 renderer 全部 case。 | |
| 只跑聚焦 XCTest | 只验证代码单元，不证明 example-image 输出路径。 | |

**User's choice:** 聚焦 + renderer。  
**Notes:** Renderer 需要跑全部当前 skin cases：`skinSmoothing_0p50`、`skinWhitening_0p50`、`skinRosy_0p40`、`skinSharpen_0p40`、`skinCombo_0p50`。视觉检查只记录事实性结论，不做商业级自然度或 release-readiness 质量声明。完整 `swift test --package-path BeautySDK` 可作为额外验证，但不是固定完成门槛。

## the agent's Discretion

- Planner may choose exact plan split, test names, formula constants, warning/metric key names, and scan command details as long as decisions in `18-CONTEXT.md` remain intact.

## Deferred Ideas

- True skin repair, blemish/pore/texture cleanup, teeth whitening, hairline adjustment, segmentation, production `SkinPass`, dense mesh, and release-readiness visual QA are deferred outside Phase 18.
