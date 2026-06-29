# Phase 19: Beauty Shaping Core Modules - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-29
**Phase:** 19-Beauty Shaping Core Modules
**Areas discussed:** Geometry output status, Public parameter boundary, Branch promotion and verification scope, Future branch exclusions

---

## Initial Scope Clarification

The user selected all proposed gray areas and clarified that the phase should remain focused on `BeautySDK`, not UI. The agent summarized current SDK capability and ran `swift test --package-path BeautySDK`; all 129 tests passed with 0 failures.

---

## Geometry Output Status

| Option | Description | Selected |
|--------|-------------|----------|
| 不打通，诚实保持 partial（推荐） | 加固 provider/tests/docs，明确 geometry renderer blocker，不冒险改主链路。 | ✓ |
| 尝试最小打通 | 让 public facade 在测试/renderer 路径能用 fixture geometry 产出 saved image，但风险和改动更大。 | |
| 只做文档审计 | 不改 SDK 算法，只整理 branch status 和现有测试证据。 | |

**User's choice:** 1  
**Notes:** Phase 19 will not attempt public facade geometry saved-image output. Geometry provider/unit/control-point evidence may support `partial`, not `implemented`.

---

## Public Parameter Boundary

| Option | Description | Selected |
|--------|-------------|----------|
| 不新增 public 参数（推荐） | Phase 19 只加固现有参数、provider、tests、docs；高级子项继续写成 future needs。 | ✓ |
| 只在必要时新增少量参数 | 例如为比例/眉毛/3D塑颜补参数；会牵涉 `DESIGN.md`、Demo mapping、测试和兼容性。 | |
| 大幅扩展参数模型 | 把 Meitu 子工具尽量补齐；会明显扩大 Phase 19 范围。 | |

**User's choice:** 1  
**Notes:** Existing `BeautyParameters` are the only public parameter surface for Phase 19.

---

## Branch Promotion and Verification Scope

| Option | Description | Selected |
|--------|-------------|----------|
| 按上述保守口径锁定（推荐） | 脸型、眼睛、鼻子、嘴唇、比例保持 partial；3D塑颜保持 blocked-by-geometry-output；眉毛保持 future。 | ✓ |
| 把现有 provider 分支提升为 implemented | Provider evidence would be treated as enough for implementation status. | |
| 只锁定 status，不做 provider/test 加固 | Documentation status only, with minimal SDK evidence work. | |

**User's choice:** 1  
**Notes:** Existing provider branches should be strengthened but not over-promoted.

---

## Future Branch Exclusions

| Option | Description | Selected |
|--------|-------------|----------|
| 按这个验证门槛锁定（推荐） | Run `swift test --package-path BeautySDK`; focused shaping tests; scans for no overclaim, no new public parameters, no UI/SwiftUI, no renderer geometry case/fake saved-image claim, and redacted warnings/metrics. | ✓ |
| 只跑全量 `swift test`，少做扫描 | Less complete guardrail against overclaim and scope creep. | |
| 更严格，加 renderer build 和现有 skin/color/filter cases 作为回归 | Extra evidence, but not required for geometry-only Phase 19. | |

**User's choice:** 1  
**Notes:** Renderer build and existing skin/color/filter cases may be optional regression evidence, but not required.

---

## the agent's Discretion

- The planner may choose exact plan split, focused test grouping, scan commands, and document wording.
- The executor may strengthen existing providers/tests/docs as long as public API, UI, and geometry-output decisions remain unchanged.

## Deferred Ideas

- Public facade geometry saved-image output.
- New public shaping parameters.
- 3D sculpt implementation.
- Eyebrow implementation.
- Production-grade geometry renderer and release-quality visual QA.
