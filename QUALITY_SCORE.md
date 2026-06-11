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

Current repository state as of 2026-06-11:

| Area | Score | Evidence | Next Move |
| --- | --- | --- | --- |
| Root docs | 4 | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `PLANS.md`, `QUALITY_SCORE.md` exist and separate current state from target architecture. | Keep root docs synced when `.planning/PROJECT.md`, `docs/10_document_audit_report.md`, or implementation contracts change. |
| Historical docs | 3 | `docs/README.md` is the long-doc entry, lists current implementation status, and routes historical `docs/superpowers/` planning artifacts as background. | Continue conflict scans against root contracts and fresh command output. |
| GSD planning | 3 | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, and Phase 1/2 plan artifacts exist. | Keep summaries, verification, and roadmap state synced as phases execute. |
| SDK Package | 3 | `BeautySDK/Package.swift` exists with `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and facade `BeautySDK` targets; `swift test --package-path BeautySDK` passes. | Wire Demo integration in Phase 2 and broaden target-specific implementation beyond foundation no-op behavior. |
| Demo App | 3 | `BeautyDemo` imports `BeautySDK`, renders the Phase 2 editor shell, static preview, disabled Camera/Photo entries, descriptor-driven categories/panels/sliders, and has no `Hello, world!` source matches. | Add real camera/photo input in Phase 3 and later connect visual effects in Phase 6. |
| Tests | 3 | `BeautySDK/Tests` has 20 passing XCTest cases; `BeautyDemoTests` has 22 passing XCTest cases covering import boundary, categories, disabled states, slider normalization, reset behavior, and view-state evidence. | Add detection, resource, effect, UI automation, and performance coverage in later phases. |
| Security | 3 | Parameter normalization and preset validation tests cover non-finite values, unknown fields, unknown filter IDs, and redacted typed errors; privacy manifest still absent. | Add resource/package validation and privacy manifest review when SDK distribution behavior exists. |
| Reliability | 3 | `BeautyError`, no-op unsupported format mapping, SDK-created output, and idempotent `reset()` are tested; runtime metrics implementation is still absent. | Add metrics, degradation, and long-run tests when render/detection pipelines mature. |
| Product acceptance | 3 | `PRODUCT_SENSE.md` defines journeys and acceptance criteria. | Attach tests and fixtures to each MVP journey. |

## 4. Product Domain Scorecard

| Domain | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| SDK Integration | 5 | 4 | App imports only `BeautySDK`; `BeautyEngine` init/process/reset compile and have typed errors. |
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
| `BeautyCore` | 5 | 3 | Value models compile, `Sendable`, Codable tests, parameter normalization tests, typed errors, and no-op engine tests exist. |
| `BeautyDetection` | 4 | 0 | Detector protocol, Vision adapter, coordinate tests, smoothing state tests. |
| `BeautyRender` | 5 | 2 | `RenderGraph`, `RenderPass`, `CopyRenderPass`, `PixelBufferFactory`, and `Warp.metal` placeholder exist with copy/pass-order tests. |
| `BeautyEffects` | 4 | 0 | Effect requirements, provider tests, safety caps, degradation tests. |
| `BeautyResources` | 4 | 0 | Bundle loading, manifest validation, missing/invalid resource tests. |
| `BeautySDK` facade | 5 | 3 | Facade tests import only `BeautySDK` and access public foundation types; render test helpers are exposed only through testing SPI. |
| `BeautyDemo` | 4 | 3 | Demo shell, parameter panel, preview fixture, disabled modes, descriptor-driven category rail, slider/reset state, import-boundary tests, and view-state tests exist. |

## 6. Test Coverage Scorecard

| Test Area | Target Score | Current | Minimum Coverage |
| --- | --- | --- | --- |
| Parameter tests | 5 | 3 | Defaults, 31 stored fields, ranges, NaN/infinity reset, Sendable, and Codable round trip. |
| Preset tests | 4 | 3 | Decode, unknown fields, invalid ID, no built-in registry, and missing filter resource typed errors. |
| Coordinate tests | 5 | 0 | Front/back, portrait/landscape, EXIF orientation, preview mirroring. |
| Detection tests | 4 | 0 | No face, low confidence, missing landmarks, reuse window, reset. |
| Render tests | 4 | 2 | Copy pass preserves BGRA bytes, unsupported copy input maps to `BeautyError`, and RenderGraph pass order is tested. |
| Effect fixture tests | 4 | 0 | Naturalness fixtures, high-strength safety, no-face degradation. |
| Performance tests | 4 | 0 | 720p frame budget, dropped frames, memory long-run, quality modes. |
| Security tests | 4 | 0 | Invalid JSON, path traversal, oversized resources, log redaction. |
| UI tests | 3 | 2 | View-state XCTest covers launch-shell data, categories, disabled controls, slider mapping, reset surface, and import boundary; UI automation remains future work. |

## 7. Documentation Scorecard

| Doc | Target Score | Current | Required Evidence For 5 |
| --- | --- | --- | --- |
| `AGENTS.md` | 5 | 4 | Stays near 100 lines, routes every root doc, no business details. |
| `ARCHITECTURE.md` | 5 | 4 | Matches actual Package targets, facade boundary, and dependency graph. |
| `DESIGN.md` | 5 | 4 | Matches actual public models, direct process APIs, no-op semantics, and RenderGraph. |
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
| Error typing | 5 | 3 | Public foundation failures map to `BeautyError`; broader render/detection/resource failures need later coverage. |
| Degradation | 5 | 2 | No face, missing landmark, missing resource, GPU overload paths tested. |
| Observability | 4 | 2 | Logger levels, metrics, signposts, disabled mode tested. |
| Performance budgets | 4 | 1 | 720p target, dropped frames, memory long-run recorded. |
| Reset behavior | 4 | 3 | Phase 1 verifies idempotent engine `reset()` and user parameter immutability; Phase 2 verifies single-slider and reset-all Demo parameter state. Future detection/render transient state still needs coverage. |

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
rg -n "TO""DO|TB""D|FIX""ME|待""定|占""位|Lor""em" AGENTS.md ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md
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

```bash
rg -n "docs/00_""index|docs/02_""development_spec_and_engineering_guidelines|docs/03_""development_stages_full_plan|docs/04_""architecture_spm_skeleton|docs/05_""external_api_design|docs/06_""beauty_parameters_reference|docs/07_""face_landmarks_and_coordinate_system|docs/08_""metal_rendering_pipeline|beauty_""sdk_product_feature_plan|ios_""beauty_sdk" AGENTS.md ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md
```

Pass: no root-level references to removed or pre-import `docs/` filenames.

```bash
node -e "const fs=require('fs'); const root='docs'; const text=fs.readFileSync('docs/README.md','utf8'); const links=[...text.matchAll(/\\]\\(([^)]+\\.md)\\)/g)].map(m=>m[1]); const missing=links.filter(p=>!fs.existsSync(root+'/'+p)); if(missing.length){ console.error(missing.join('\\n')); process.exit(1); } console.log('README links OK:', links.length);"
```

Pass: every Markdown link in `docs/README.md` resolves to an existing long-form doc.

```bash
rg -n "docs_""total\\.json" AGENTS.md ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md docs/README.md
```

Pass: `docs_total.json` appears only as `docs/_source/docs_total.json` source-import context, not as a reading entry.

```bash
test -f .planning/PROJECT.md && test -f .planning/STATE.md && test -f .planning/ROADMAP.md && test -f .planning/REQUIREMENTS.md
```

Pass: GSD project, state, roadmap, and requirement tracking files exist and are updated as phases execute.

```bash
rg --glob '!docs/_source/**' --glob '!docs/10_document_audit_report.md' -n "waitUntil""Completed|Beauty""Warp\\.metal|Beauty""Configuration|Beauty""Parameters|Beauty""Error|Beauty""Logger|BeautyCore/""Diagnostics" ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md docs
```

Pass: key API, shader, diagnostics, and realtime synchronization terms do not contradict `docs/10_document_audit_report.md`.

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

Pass: target / scheme `BeautyDemo` is listed.

```bash
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=<Simulator Name>,OS=<OS Version>' build
```

Pass: Demo shell builds for an explicitly selected available iOS Simulator. Do not treat a default-destination `My Mac` failure as a Swift compile failure.

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
| 1 | Add realtime camera and still-image input slice. | Unlocks Phase 3 host-app data flow and permission/error-state validation. |
| 2 | Add detection/resource/effect implementations beyond foundation placeholders. | Raises code-layer scores beyond compile/no-op baseline. |
| 3 | Add resource validation and privacy manifest review. | Raises security gate before distribution-like SDK claims. |
| 4 | Add performance, degradation, and long-run reliability tests. | Raises reliability gate beyond typed errors and reset smoke tests. |
| 5 | Keep `docs/README.md`, `docs/10_document_audit_report.md`, root docs, and `.planning/PROJECT.md` synchronized. | Reduces conflict risk for future Agents. |

## 15. Quality Decision Log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | Scores distinguish current state from target state. | The repo has strong planning docs but little SDK implementation yet. |
| 2026-05-25 | A score above `3` requires verification evidence. | Prevents optimistic scoring without tests or checks. |
| 2026-05-25 | Historical `docs/` count as background, not current contract. | Root docs are now the Agent-first source of truth. |
| 2026-06-10 | Build checks must use an explicit iOS Simulator destination. | The default `xcodebuild ... build` command can select an incompatible `My Mac` destination even when the iOS simulator build succeeds. |
| 2026-06-10 | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, and `.planning/REQUIREMENTS.md` are current GSD execution context. | Prevents future agents from relying only on historical docs or stale chat context. |
| 2026-06-11 | Phase 2 raises Demo evidence through view-state tests, not UI automation. | The shell is deterministic before camera/photo input exists; later phases still need simulator UI workflows for permissions, compare, and media states. |
