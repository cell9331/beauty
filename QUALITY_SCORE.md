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

Current repository state as of 2026-06-23:

| Area | Score | Evidence | Next Move |
| --- | --- | --- | --- |
| Root docs | 4 | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `PLANS.md`, `QUALITY_SCORE.md` exist and separate current state from target architecture. | Keep root docs synced when `.planning/PROJECT.md`, `docs/10_document_audit_report.md`, or implementation contracts change. |
| Historical docs | 3 | `docs/README.md` is the long-doc entry, lists current implementation status, and routes historical `docs/superpowers/` planning artifacts as background. | Continue conflict scans against root contracts and fresh command output. |
| GSD planning | 4 | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, Phase 1 through Phase 7 plan artifacts, and v1.1 Phase 8 through Phase 10 verification artifacts close Meitu UI traceability. | Choose the next milestone and keep release-hardening risks separate from v1.1 Meitu UI acceptance. |
| SDK Package | 4 | `BeautySDK/Package.swift` exists with `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and facade `BeautySDK` targets; `swift test --package-path BeautySDK` passes with 119 XCTest cases. | Replace MVP geometry/color proxies with production-quality render passes and performance evidence. |
| Demo App | 4 | `BeautyDemo` imports `BeautySDK`, launches into a Meitu-style Home, routes supported Home actions to existing camera/photo/editor paths, renders the Meitu-style editor panel, preserves Camera/Photo modes, camera permission/session states, bounded realtime pipeline, photo input pipeline, compare/debug toolbar, copy/paste Parameter JSON sheet, preset/import/custom source state, reset semantics, preset/filter chips, color controls, and deterministic view-state coverage for v1.1 Home/editor behavior. | Add automated screenshot/UI comparison, multi-device layout sweeps, and manual visual QA for final layout and naturalness. |
| Tests | 4 | `BeautySDK/Tests` has 119 passing XCTest cases; `BeautyDemoTests` full simulator suite passed on iPhone 17 iOS 26.5 after the v1.1 Home/editor rewrite. Coverage includes import boundary, Camera, realtime pipeline, Photo, compare/debug, parameter JSON, privacy scans, resources, presets, filters, panel state, parameter source/reset state, metadata, coordinate, detection degradation, visual effect fixtures, provider output, combined caps, no-face skips, Demo Phase 7 panel paths, and v1.1 Home/editor view-state/routes/taxonomy/mapping. | Add performance, production render regression, simulator UI automation, screenshot diffing, and long-run coverage in later phases. |
| Security | 4 | Parameter/preset/resource validation tests plus purpose-string, no-upload/no-network, no raw path/error copy, facade-only import, Demo resource-control source scans, public geometry/raw framework leakage scans, 64 KB parameter JSON limit, schema validation, raw JSON non-echo tests, and active JSON/debug surface scans pass; privacy manifest still absent. | Add privacy manifest review when SDK distribution behavior exists. |
| Reliability | 4 | `BeautyError`, no-op unsupported format mapping, SDK-created output, idempotent `reset()`, realtime backpressure, stale-frame drops, photo stale-work handling, previous-visual preservation, coordinate mapping failures, no-face/partial/low-confidence summaries, resource-not-found validation, combined effect caps, targeted missing-landmark skips, stale/reused geometry degradation, Demo warning/resource failure copy, recoverable debug status codes, and non-mutating JSON import failures are tested; runtime metrics and long-run checks are still absent. | Add production render-resource degradation, performance budgets, and long-run tests when render/effects pipelines mature. |
| Product acceptance | 4 | `PRODUCT_SENSE.md` defines journeys and now records Phase 3 through Phase 7 automated evidence plus v1.1 Meitu Home/editor acceptance for realtime Camera, still image editing, compare/debug, local-first privacy, metadata, coordinate mapping, safe detection degradation, built-in presets, filters, parameter JSON round-trip, reset/source semantics, unavailable-state honesty, color/filter output, skin/face/eye/nose/mouth/lip MVP output, conservative presets, Demo panel smoke, Home first screen, Home sticky state, and editor tool-panel structure. | Attach manual/hardware smoke evidence and automated screenshot comparison before release-like visual fidelity or naturalness claims. |

### 3.1 Phase 4 Final Verification

Recorded 2026-06-18:

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 55 XCTest cases.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 61 Demo XCTest cases.
- `rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `rg -n "public .*Point|public .*Rect|public .*bounding|public .*landmark|VNFaceObservation|NSError|/private/var" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor` returned no matches.

### 3.2 Phase 5 Final Verification

Recorded 2026-06-19:

- `swift test --package-path BeautySDK` passed with 71 XCTest cases.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 66 Demo XCTest cases.
- `rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `rg -n "\.cube|LUTPass|ColorPass|thumbnail|swatch" BeautySDK/Sources/BeautyResources BeautyDemo/BeautyDemo/Panel` returned no matches.
- `rg -n "/private/var|NSError|Bundle\.|rawPresetJson|BeautyResources|\.\./" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Panel BeautyDemo/BeautyDemo/State` returned one intentional internal facade import: `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift:2:import BeautyResources`. Demo source and tests remain facade-only.

### 3.3 Phase 6 Final Verification

Recorded 2026-06-22:

- `swift test --package-path BeautySDK` passed with 119 XCTest cases.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 67 Demo XCTest cases.
- Focused Demo test command for `BeautyParameterStoreTests`, `BeautyDemoViewStateTests`, `BeautyDemoImportBoundaryTests`, and `InputPipelinePrivacyTests` passed after the RED/GREEN copy update.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- Exact stale pending-visual Phase 6 copy scan across BeautyDemo, BeautySDK, and root docs returned no matches.
- Public geometry/raw framework/path scan over `BeautySDK/Sources/BeautyCore`, `BeautySDK/Sources/BeautySDK`, `BeautyDemo/BeautyDemo/Camera`, and `BeautyDemo/BeautyDemo/Editor` returned no matches.
- Broad raw-token scan still reports expected policy examples in root docs and guard strings in tests; it is not evidence of an active SDK/Demo surface leak.

### 3.4 Phase 7 Final Verification

Recorded 2026-06-23:

- Focused Demo `xcodebuild` command for `BeautyParameterStoreTests`, `ParameterJSONCodingTests`, `BeautyDemoViewStateTests`, `CompareStateTests`, `InputPipelinePrivacyTests`, and `BeautyDemoImportBoundaryTests` passed on `platform=iOS Simulator,name=iPhone 17,OS=26.5`.
- Full Demo `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed after aligning stale future-subcategory copy coverage with `Not in v1`.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 XCTest cases.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- The exact broad JSON/debug privacy scan reported expected XCTest guard literals and existing non-debug `CGRect` image helpers; the scoped active JSON/debug surface scan returned no matches.
- Simulator screenshot/UI automation, manual visual naturalness review, real-device camera/Vision parity, production render quality, performance budgets, and long-run hardware checks were not run and remain release-risk gates.

### 3.5 v1.1 Meitu UI Final Verification

Recorded 2026-06-24:

- Focused Demo `xcodebuild` command for `BeautyDemoTests/BeautyDemoViewStateTests` passed on `platform=iOS Simulator,name=iPhone 17,OS=26.5`.
- Full Demo `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed after the Home/editor rewrite.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 XCTest cases.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- Screenshot-backed evidence is recorded in `.planning/evidence/v1.1/home-first-screen.png`, `.planning/evidence/v1.1/home-sticky-state.png`, and `.planning/evidence/v1.1/editor-tool-panel.png`.
- XcodeBuildMCP simulator listing could not find `simctl` in its tool PATH, so visual evidence capture used shell `xcrun simctl` with explicit `DEVELOPER_DIR`.
- Full commercial Meitu parity, automated screenshot diffing, multi-device visual sweeps, real-device camera/Vision parity, performance budgets, and long-run hardware checks remain future gates.

## 4. Product Domain Scorecard

| Domain | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| SDK Integration | 5 | 4 | App imports only `BeautySDK`; `BeautyEngine` init/process/reset compile and have typed errors. |
| Realtime Camera | 5 | 4 | Camera frames process through SDK, no realtime `UIImage`, UI remains responsive in unit/pipeline tests, bounded backpressure is tested, permission fallback state is covered, and Phase 6 effects route through the shared engine path. |
| Still Image Editing | 4 | 4 | Fixed fixture and PhotosPicker-data seam process through SDK, loading/error preservation is tested, compare state is covered, and Phase 6 image output has deterministic effect evidence. |
| Presets | 4 | 4 | Built-in JSON presets decode, validate, apply deterministically, and sync UI controls. |
| Skin Beauty | 4 | 4 | Default no-op, visible skin/color fixture output, high-strength safety caps, and no-face combined skip behavior are tested. |
| Face Shape | 4 | 4 | Control points are generated safely, combined geometry weakens, no-face skips, and MVP proxy evidence is tested. |
| Eyes | 4 | 4 | Eye provider output, caps, reused/stale reduction, and missing-eye landmark skips are tested. |
| Nose | 4 | 4 | Nose provider output, caps, reused/stale reduction, and missing-nose landmark skips are tested. |
| Mouth | 4 | 4 | Mouth provider output, lip-color fixture output, reused/stale reduction, and missing-mouth/lip skips are tested. |
| Filters | 4 | 4 | `filterId nil`, missing filter, intensity 0/1, metadata filter IDs, and Demo filter selection are covered; real LUT decode remains Phase 6+ render scope. |
| Makeup | 3 | 0 | Resource manifest, missing-resource behavior, landmark attachment tests. |
| Background / Segmentation | 3 | 0 | Mask edge fixtures, no-person fallback, device downgrade behavior. |
| Body Shape | 3 | 0 | Human landmark contract, half/full-body fixtures, safety caps. |
| Video Export | 3 | 0 | Progress, cancel, orientation, audio preservation, failure recovery. |

## 5. Code Layer Scorecard

| Layer | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| `BeautyCore` | 5 | 4 | Value models compile, `Sendable`, Codable tests, parameter normalization tests, typed errors, metadata/result summaries, and no-op engine tests exist. |
| `BeautyDetection` | 4 | 4 | Detector protocol, Vision adapter seams, face selection, coordinate mapper, mapping failures, and safe public summaries are tested. |
| `BeautyRender` | 5 | 3 | `RenderGraph`, `RenderPass`, `CopyRenderPass`, `PixelBufferFactory`, and `Warp.metal` placeholder exist with copy/pass-order tests; Phase 6 adds deterministic MVP color/geometry proxy evidence through `BeautyEffects`. |
| `BeautyEffects` | 4 | 4 | Effect resolver, safety caps, skin/color/filter output, face/eye/nose/mouth providers, lip color, combined weakening, no-face skips, missing-landmark degradation, and preset evidence are tested. |
| `BeautyResources` | 4 | 4 | Bundle loading, schema-versioned manifest validation, metadata filters, preset lookup, missing/invalid resource tests, and traversal-like ID rejection are covered. |
| `BeautySDK` facade | 5 | 4 | Facade tests import only `BeautySDK` and access public foundation, metadata, result, and detection summary types; render test helpers are exposed only through testing SPI. |
| `BeautyDemo` | 4 | 4 | Demo shell, parameter panel, preview fixture, enabled Camera/Photo modes, Camera session/pipeline, Photo pipeline, compare state, privacy scans, import-boundary tests, and view-state tests exist. |

## 6. Test Coverage Scorecard

| Test Area | Target Score | Current | Minimum Coverage |
| --- | --- | --- | --- |
| Parameter tests | 5 | 3 | Defaults, 31 stored fields, ranges, NaN/infinity reset, Sendable, and Codable round trip. |
| Preset tests | 4 | 4 | Decode, unknown fields, invalid ID, schema version, built-in registry, and missing filter resource typed errors. |
| Coordinate tests | 5 | 4 | Front/back, portrait/landscape, EXIF orientation, input mirroring, preview mirroring, VisionNormalized, ImageNormalized, pixel, texture, and preview mapping tests exist. |
| Detection tests | 4 | 4 | No face, low confidence, missing landmarks, mapping failure, face limit, selection stability, detector unavailable, timeout, and reset coverage exists. |
| Render tests | 4 | 3 | Copy pass preserves BGRA bytes, unsupported copy input maps to `BeautyError`, RenderGraph pass order is tested, and Phase 6 has deterministic MVP color/geometry/lip fixture evidence. |
| Effect fixture tests | 4 | 4 | Naturalness-oriented visible fixtures, high-strength safety caps, all-domain combined weakening, no-face degradation, partial landmark skips, reused/stale behavior, and preset output are tested. |
| Performance tests | 4 | 0 | 720p frame budget, dropped frames, memory long-run, quality modes. |
| Security tests | 4 | 4 | Invalid JSON and redacted typed errors are tested in SDK; Demo adds purpose strings, no-upload/no-network, no raw path/error copy, no realtime `UIImage`, facade-only import scans, and public detection geometry/raw framework leakage scans. |
| UI tests | 3 | 3 | View-state XCTest covers launch-shell data, enabled Camera/Photo modes, permission/unavailable/loading/error states, compare labels, categories, disabled controls, slider mapping, reset surface, and import boundary; UI automation remains future work. |

## 7. Documentation Scorecard

| Doc | Target Score | Current | Required Evidence For 5 |
| --- | --- | --- | --- |
| `AGENTS.md` | 5 | 4 | Stays near 100 lines, routes every root doc, no business details. |
| `ARCHITECTURE.md` | 5 | 4 | Matches actual Package targets, facade boundary, and dependency graph. |
| `DESIGN.md` | 5 | 4 | Matches actual public models, metadata/result summaries, coordinate mapper semantics, direct process APIs, no-op semantics, and RenderGraph. |
| `FRONTEND.md` | 4 | 4 | Matches actual Demo directories, state ownership, and UI tests. |
| `SECURITY.md` | 5 | 4 | Matches validation code and Phase 4 public summary/debug redaction tests; privacy manifest and resource checks remain future gates. |
| `RELIABILITY.md` | 5 | 4 | Matches error enums, input pipeline recovery, detection degradation, coordinate mapping failure, and reset behavior; metrics and long-run performance remain future gates. |
| `PRODUCT_SENSE.md` | 4 | 4 | Each MVP journey has automated or recorded manual acceptance. |
| `PLANS.md` | 5 | 4 | Every active task is updated before and after work. |
| `QUALITY_SCORE.md` | 5 | 2 | Scores are refreshed after each substantial implementation milestone. |
| Historical `docs/` | 3 | 2 | Conflicts with root docs are removed, linked, or marked historical. |

## 8. Security and Reliability Scorecard

| Gate | Target | Current | Required Evidence |
| --- | --- | --- | --- |
| Privacy default | 5 | 4 | Phase 3 static scans show no upload/network path, no raw path/error copy, and no realtime `UIImage` in input paths; no frame/landmark persistence is introduced. |
| Permissions | 4 | 3 | Camera permission mapping and purpose strings are tested; real Settings round-trip remains manual. |
| Resource validation | 5 | 4 | Manifest schema, metadata filter registry, built-in preset lookup, missing-resource typed errors, and traversal-like ID tests. Checksums and byte-size limits remain future work for real assets. |
| Error typing | 5 | 3 | Public foundation failures map to `BeautyError`; broader render/detection/resource failures need later coverage. |
| Degradation | 5 | 4 | No face, partial/missing landmark, low-confidence, stale, skipped/reused, mapping failure, combined effect skip/weakening, and Demo status debounce paths are tested; resource and GPU overload paths remain future work. |
| Observability | 4 | 2 | Logger levels, metrics, signposts, disabled mode tested. |
| Performance budgets | 4 | 2 | Bounded in-flight work and dropped-frame counters are tested; 720p timing and memory long-run remain future checks. |
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
| 1 | Replace MVP effect proxies with production render quality and manual visual QA evidence. | Pixel/provider fixtures prove deterministic changes, but not final naturalness or release-grade GPU quality. |
| 2 | Add performance, simulator UI automation, and long-run reliability tests. | Raises reliability and UI gates beyond unit/pipeline coverage. |
| 3 | Add resource validation and privacy manifest review. | Raises security gate before distribution-like SDK claims. |
| 4 | Expand render-resource degradation and GPU overload tests. | Current degradation coverage is strong for detection/effect routing but not render-resource failure modes. |
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
| 2026-06-12 | Phase 3 raises Realtime Camera and Still Image Editing to score 3 through deterministic pipeline, privacy, and view-state tests. | The Camera/Photo input slice is now test-backed, while real hardware smoke, visual effects, and long-run performance remain later gates. |
| 2026-06-22 | Phase 6 raises BeautyEffects and MVP effect domains to score 4 through resolver, provider, fixture, degradation, and Demo panel tests. | Deterministic automated evidence now exists; production render quality, hardware smoke, and manual naturalness review remain release-like gates. |
