# QUALITY_SCORE.md

> `beauty` 的质量评分板与 doc-gardening 规则。
> 本文件用于定期扫描产品域、代码层、测试覆盖、文档一致性、安全与可靠性。

## 1. Purpose

质量评分不是主观评价。它是 Agent 和维护者判断“下一步该补哪里”的仪表盘。

评分目标：

- 发现没有文档 owner 的行为。
- 发现没有测试或验收证据的能力。
- 发现根级文档与历史 `docs/` 资料冲突。
- 发现架构边界、隐私边界、可靠性边界被代码绕过。
- 给未来 AI 代码园丁提供可重复扫描的修复队列。

## 2. Score Scale

| Score | Meaning | Required Action |
| --- | --- | --- |
| 0 | 不存在或完全不可验证。 | 建立 owner、计划和最小验证。 |
| 1 | 有想法或历史资料，但无当前契约。 | 迁移到根级文档或 `PLANS.md`。 |
| 2 | 有当前文档，但无代码或测试。 | 建立实现计划和最小测试。 |
| 3 | 有代码和基本验证，但覆盖不完整。 | 补边界测试和失败路径。 |
| 4 | 主要路径、失败路径和文档同步。 | 加性能、回归和质量门禁。 |
| 5 | 可发布级：自动化、可观测、回归稳定。 | 维持并定期巡检。 |

Quality gate:

- MVP 开发前，根级文档层必须平均 `4+`。
- SDK 1.0 前，核心代码层必须平均 `4+`。
- 发布前，安全、可靠性、产品验收不得低于 `4`。

## 3. Current Snapshot

Current repository state as of 2026-05-25:

| Area | Score | Evidence | Next Move |
| --- | --- | --- | --- |
| Root docs | 4 | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `PLANS.md` exist. | Add this scorecard and start conflict scans. |
| Historical docs | 2 | `docs/` contains rich long-form notes, but some overlap root contracts. | Mark root docs authoritative and scan conflicts. |
| SDK Package | 0 | No `BeautySDK/Package.swift` exists. | Create SPM package and targets. |
| Demo App | 1 | `BeautyDemo` exists but still has default SwiftUI template. | Build minimal integration UI. |
| Tests | 0 | No SDK test targets exist. | Create unit/render/UI test skeletons. |
| Security | 3 | `SECURITY.md` exists; no implementation or privacy manifest yet. | Add validation tests when SDK exists. |
| Reliability | 3 | `RELIABILITY.md` exists; no runtime metrics implementation yet. | Add typed errors and metrics when SDK exists. |
| Product acceptance | 3 | `PRODUCT_SENSE.md` defines journeys and acceptance criteria. | Attach tests and fixtures to each MVP journey. |

## 4. Product Domain Scorecard

| Domain | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| SDK Integration | 5 | 0 | App imports only `BeautySDK`; `BeautyEngine` init/process/reset compile and have typed errors. |
| Realtime Camera | 5 | 1 | Camera frames process through SDK, no realtime `UIImage`, UI remains responsive, fallback works. |
| Still Image Editing | 4 | 0 | Fixed image fixture processes with orientation preserved and typed error handling. |
| Presets | 4 | 2 | Built-in JSON presets decode, validate, apply deterministically, and sync UI controls. |
| Skin Beauty | 4 | 1 | Default no-op, medium naturalness fixture, high-strength safety cap, render regression. |
| Face Shape | 4 | 1 | Control points generated safely, background distortion checked, no-face skip tested. |
| Eyes | 4 | 1 | Missing-eye landmarks skip effects; eye size and eye position remain plausible. |
| Nose | 4 | 1 | Side-face and missing-nose cases degrade without distortion. |
| Mouth | 4 | 1 | Smile/lip effects avoid tooth/lip stretching in fixtures. |
| Filters | 4 | 1 | `filterId nil`, missing filter, intensity 0/1, LUT parse failure covered. |
| Makeup | 3 | 0 | Resource manifest, missing-resource behavior, landmark attachment tests. |
| Background / Segmentation | 3 | 0 | Mask edge fixtures, no-person fallback, device downgrade behavior. |
| Body Shape | 3 | 0 | Human landmark contract, half/full-body fixtures, safety caps. |
| Video Export | 3 | 0 | Progress, cancel, orientation, audio preservation, failure recovery. |

## 5. Code Layer Scorecard

| Layer | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| `BeautyCore` | 5 | 0 | Value models compile, `Sendable`, Codable tests, parameter normalization tests. |
| `BeautyDetection` | 4 | 0 | Detector protocol, Vision adapter, coordinate tests, smoothing state tests. |
| `BeautyRender` | 5 | 0 | Metal context, texture cache, RenderGraph tests, pass skip tests, no per-frame forbidden allocations. |
| `BeautyEffects` | 4 | 0 | Effect requirements, provider tests, safety caps, degradation tests. |
| `BeautyResources` | 4 | 0 | Bundle loading, manifest validation, missing/invalid resource tests. |
| `BeautySDK` facade | 5 | 0 | Public API hides internals, errors mapped, basic process API compiles. |
| `BeautyDemo` | 4 | 1 | Demo shell, parameter panel, preview path, permission/error UI, UI smoke test. |

## 6. Test Coverage Scorecard

| Test Area | Target Score | Current | Minimum Coverage |
| --- | --- | --- | --- |
| Parameter tests | 5 | 0 | Defaults, ranges, NaN/infinity rejection, Codable round trip. |
| Preset tests | 4 | 0 | Decode, schema version, deterministic application, missing resource. |
| Coordinate tests | 5 | 0 | Front/back, portrait/landscape, EXIF orientation, preview mirroring. |
| Detection tests | 4 | 0 | No face, low confidence, missing landmarks, reuse window, reset. |
| Render tests | 4 | 0 | Copy pass, Color pass, LUT pass, FaceWarp plan, zero-strength skip. |
| Effect fixture tests | 4 | 0 | Naturalness fixtures, high-strength safety, no-face degradation. |
| Performance tests | 4 | 0 | 720p frame budget, dropped frames, memory long-run, quality modes. |
| Security tests | 4 | 0 | Invalid JSON, path traversal, oversized resources, log redaction. |
| UI tests | 3 | 0 | Launch, permission denied, slider mapping, preset sync, compare toggle. |

## 7. Documentation Scorecard

| Doc | Target Score | Current | Required Evidence For 5 |
| --- | --- | --- | --- |
| `AGENTS.md` | 5 | 4 | Stays near 100 lines, routes every root doc, no business details. |
| `ARCHITECTURE.md` | 5 | 4 | Matches actual Package targets and dependency graph. |
| `DESIGN.md` | 5 | 4 | Matches actual public models, state machines, and RenderGraph. |
| `FRONTEND.md` | 4 | 4 | Matches actual Demo directories, state ownership, and UI tests. |
| `SECURITY.md` | 5 | 3 | Matches validation code, privacy manifest, resource checks, log redaction tests. |
| `RELIABILITY.md` | 5 | 3 | Matches error enums, metrics code, performance tests, reset behavior. |
| `PRODUCT_SENSE.md` | 4 | 4 | Each MVP journey has automated or recorded manual acceptance. |
| `PLANS.md` | 5 | 4 | Every active task is updated before and after work. |
| `QUALITY_SCORE.md` | 5 | 2 | Scores are refreshed after each substantial implementation milestone. |
| Historical `docs/` | 3 | 2 | Conflicts with root docs are removed, linked, or marked historical. |

## 8. Security and Reliability Scorecard

| Gate | Target | Current | Required Evidence |
| --- | --- | --- | --- |
| Privacy default | 5 | 3 | No upload path; no frame/landmark persistence; log scan proves redaction. |
| Permissions | 4 | 1 | Camera/photo permission states tested in Demo. |
| Resource validation | 5 | 1 | Manifest, checksum, size, type, traversal tests. |
| Error typing | 5 | 1 | All public failures map to `BeautyError`. |
| Degradation | 5 | 2 | No face, missing landmark, missing resource, GPU overload paths tested. |
| Observability | 4 | 2 | Logger levels, metrics, signposts, disabled mode tested. |
| Performance budgets | 4 | 1 | 720p target, dropped frames, memory long-run recorded. |
| Reset behavior | 4 | 1 | Detection, smoothing, caches, in-flight state reset tests. |

## 9. Architecture Fitness Checks

Run these scans during doc-gardening and before large refactors.

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects" BeautyDemo
```

Pass: no matches in Demo code.

```bash
rg -n "SwiftUI|UIKit" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects 2>/dev/null
```

Pass: no SDK core/effect/render/detection UI dependencies.

```bash
rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
```

Pass: no `UIImage` in realtime pipeline code. Still image UI adapters must be explicitly documented if they use it at boundaries.

```bash
rg -n "fatalError|try!|as!" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
```

Pass: no release-path crash shortcuts.

## 10. Documentation Gardening Checks

Run these before claiming doc health:

```bash
wc -l AGENTS.md
```

Pass: approximately 100 lines.

```bash
rg -n "TO""DO|TB""D|FIX""ME|待""定|占""位|Lor""em" *.md docs
```

Pass: no unresolved placeholders in root docs. Historical docs may contain old planning language only if marked historical.

```bash
rg -n "BeautyEyeSDK|BeautyNoseSDK|BeautyMouthSDK|BeautyFaceSDK" *.md docs
```

Pass: only appears as an anti-pattern, never as recommended architecture.

```bash
rg -n "上传|云端|网络|remote|upload" *.md docs
```

Pass: any network behavior is routed through `SECURITY.md`, `RELIABILITY.md`, and `PRODUCT_SENSE.md`.

```bash
rg -n "UIImage" ARCHITECTURE.md DESIGN.md RELIABILITY.md PRODUCT_SENSE.md docs
```

Pass: realtime `UIImage` usage appears only as a prohibition or boundary note.

## 11. Release Quality Gates

MVP readiness:

| Gate | Required Score |
| --- | --- |
| Root documentation average | `4+` |
| SDK Integration | `3+` |
| Realtime Camera | `3+` |
| Still Image Editing | `3+` |
| Parameters and Presets | `4+` |
| Security | `3+` |
| Reliability | `3+` |

SDK 1.0 readiness:

| Gate | Required Score |
| --- | --- |
| All MVP product domains | `4+` |
| Core code layers | `4+` |
| Test coverage areas | `4+` average, none below `3` |
| Security and reliability gates | none below `4` |
| Historical docs conflict score | `3+` |
| Long-run preview evidence | present |
| Public API documentation | present and current |

## 12. Doc-Gardening Workflow

1. Read `AGENTS.md` and `PLANS.md`.
2. Run documentation scans from this file.
3. Compare actual repo structure to `ARCHITECTURE.md`.
4. Compare public models to `DESIGN.md`.
5. Compare Demo behavior to `FRONTEND.md` and `PRODUCT_SENSE.md`.
6. Compare validation/logging/resource behavior to `SECURITY.md`.
7. Compare errors, metrics, performance, and reset behavior to `RELIABILITY.md`.
8. Update score tables with evidence.
9. Add follow-up items to `PLANS.md` Tech Debt instead of silently fixing unrelated issues.

## 13. Score Update Rules

- Increase a score only when evidence exists in code, tests, command output, or current docs.
- Decrease a score when implementation drifts from the owning document.
- A score above `3` requires some automated verification or a recorded manual check.
- A score of `5` requires automated regression coverage or a release-grade manual protocol.
- Do not give credit for historical `docs/` content if a root document contradicts it.
- Record major score changes in `PLANS.md` or release notes.

## 14. Current Top Repair Queue

| Priority | Item | Why |
| --- | --- | --- |
| 1 | Create `BeautySDK` Swift Package skeleton. | Most code-layer scores are blocked at 0. |
| 2 | Add `BeautyCore` models and parameter tests. | Unlocks design, preset, and API verification. |
| 3 | Add `BeautyRender` minimal copy pipeline. | Unlocks realtime/image processing smoke tests. |
| 4 | Replace default Demo UI with integration shell. | Unlocks product journey validation. |
| 5 | Add validation and redaction tests. | Raises security and reliability gates. |
| 6 | Mark historical docs as reference or migrate them. | Reduces conflict risk for future Agents. |

## 15. Quality Decision Log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | Scores distinguish current state from target state. | The repo has strong planning docs but little SDK implementation yet. |
| 2026-05-25 | A score above `3` requires verification evidence. | Prevents optimistic scoring without tests or checks. |
| 2026-05-25 | Historical `docs/` count as background, not current contract. | Root docs are now the Agent-first source of truth. |
