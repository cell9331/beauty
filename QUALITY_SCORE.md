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

Current repository state as of 2026-07-14 after Phase 37 exact nose safety, boundary, and SDK-core branch closeout:

| Area | Score | Evidence | Next Move |
| --- | --- | --- | --- |
| Root docs | 4 | `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `PLANS.md`, and `QUALITY_SCORE.md` still exist as current owner docs. Phase 21 root placeholder scan found only historical `PLANS.md` verification prose, not unresolved contract placeholders. | Keep root docs synced when `.planning/PROJECT.md`, `.planning/ROADMAP.md`, implementation contracts, or Phase 22-25 evidence change. |
| Historical docs | 3 | `docs/README.md` remains the long-doc entry. Phase 21 records `.planning/codebase/*` maps as stale background because they still contradict the current Swift package, tests, and planning ledgers. | Continue conflict scans and defer any formal `.planning/codebase/*` remap until explicitly scoped. |
| GSD planning | 4 | v1.9 Phases 35-37 and all 11 plans are complete. Phase 37 validation is Nyquist compliant and verification passes 6/6 requirements; the independent milestone audit remains pending. | Run `$gsd-audit-milestone`; archive/tag/cleanup only after its independent result passes. |
| SDK Package | 4 | `BeautySDK` retains the existing package/facade structure and exact 33-field public inventory (32 numeric plus `filterId`). Phase 37 full `swift test --package-path BeautySDK` passes 228/228 after six-field nose safety and convergence evidence. | Optimized profiling, physical-device checks, and packaging remain future gates. |
| Demo App | 4 | Existing archived Demo evidence remains valid for shipped behavior. Phase 22 recorded blocker-form Home/editor review notes and no current v1.4 PNG screenshots. Phase 23 focused camera pipeline xcodebuild passed on `platform=iOS Simulator,name=iPhone 17,OS=26.5`; Phase 25 focused privacy/import xcodebuild passed with 17 tests, but screenshot and long-run routes were not rerun. | Rerun the screenshot protocol before claiming current screenshot evidence; keep physical iPhone checks blocked until hardware evidence exists. |
| Tests | 4 | Phase 37 focused suites pass 103/103 and cover exact caps, all-six degradation/transitions/provider-empty handling, public no-face continuation, and exact retained-set convergence; full SwiftPM passes 228/228. | Add tests only for separately scoped future tools; retain device/Demo gaps explicitly. |
| Security | 4 | Phase 37 fail-closed scans cover public/SPI raw geometry, forbidden imports, network/cloud, commercial paths, exact public inventory, dependencies, diagnostics, and tracked/staged generated artifacts; review is clean and `threats_open: 0`. | Reopen manifest, dependency, network, resource-integrity, and raw-geometry review when behavior changes or packaging starts. |
| Reliability | 4 | All six nose fields fail closed for zero/no-face/missing/provider-empty/stale input, reused eligible geometry uses exact `0.5`, transitions carry no prior emissions, and provider-empty work is excluded from final convergence evidence. | Keep the 600-second preview, physical iPhone, screenshot, and optimized profiling routes future. |
| Product acceptance | 4 | Phase 37 closes exactly the six-row SDK-core `鼻子` branch after fresh 228/228 full tests and unchanged 252/252 output with independent root/lift comparisons; Demo/device/commercial/packaging/launch claims remain excluded. | Run the independent v1.9 milestone audit; do not infer broader readiness. |

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

### 3.6 Phase 21 v1.4 Baseline Audit

Recorded 2026-06-30 in `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`:

- `swift --version`, `xcodebuild -version`, `swift test --package-path BeautySDK --list-tests`, `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`, and `xcrun simctl list devices available` established the current command inventory. No CoreSimulator version mismatch appeared in this run.
- `swift test --package-path BeautySDK` passed with 141 XCTest cases.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` wrote 45 ignored PNG outputs across 5 fixtures and 9 current skin/color/filter cases.
- Output checks found no zero-byte renderer PNGs and representative outputs matched input dimensions.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` is blocked by a missing local Metal Toolchain while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`; Demo tests are therefore blocked until the same prerequisite is repaired.
- Current import, SDK UI-dependency, active Demo local-first, sensitive raw/geometry, public `BeautyParameters`, renderer geometry-case, privacy manifest, and root placeholder scans passed or were classified with exact limitations.
- No `PrivacyInfo.xcprivacy` exists, so TD-005 remains routed to Phase 25.
- TD-008 splits to Phase 22/Phase 23 with physical iPhone checks blocked until hardware evidence exists; TD-009 routes to Phase 22; TD-010 splits across Phases 22, 23, 24, and 25.
- `.planning/codebase/*` maps are stale for current v1.4 source truth and remain deferred background material, not current authority.

### 3.7 Phase 22 Automated Demo QA Evidence

Recorded 2026-07-01 in `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` and `.planning/phases/22-automated-demo-qa-and-screenshot-evidence/22-VERIFICATION.md`:

- Exact iPhone 17 / iOS 26.5 Demo build and focused `BeautyDemoViewStateTests` commands both exit 65 while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` because the local Metal Toolchain is missing.
- No current v1.4 screenshot PNGs exist or are claimed under `.planning/evidence/v1.4/`.
- Home first screen, Home sticky state, and editor beauty/photo tool-panel review notes are recorded in blocked form with exact rerun commands and UI-SPEC focal points.
- Static route/model scans confirm unsupported/future Home and editor areas remain inactive while Demo XCTest is blocked by the same build prerequisite.
- `swift test --package-path BeautySDK` passed with 141 XCTest cases after Phase 22 execution.
- Phase 22 does not claim commercial visual quality, effect quality, physical-device camera/Vision parity, screenshot-diff baselines, exact commercial Meitu parity, new product routes, hidden network/cloud behavior, or public API expansion.

### 3.8 Phase 23 Performance and Reliability Evidence

Recorded 2026-07-02 in `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` and `23-VALIDATION.md`:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` passed with 3 tests and 0 failures.
- `swift test --package-path BeautySDK` passed with 148 tests and 0 failures.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` passed with 7 camera tests and 0 failures.
- The SDK `1280x720` timing matrix records `default_noop`, `skin_color_filter`, and `high_capped` as over-budget baseline cases against `RELIABILITY.md`; this is evidence for comparison, not a readiness claim.
- The memory evidence is a short SDK fixture loop with unavailable resident-memory sampling and a 600-second rerun protocol.
- SDK quality-mode, engine reset, degradation, safety-cap, redacted metric, Demo backpressure/reset, and still-image recovery regressions are test-backed.
- Redaction and no-overclaim scans over the Phase 23 evidence passed.
- Physical iPhone, screenshot acceptance, optimized profiling, and 600-second preview evidence remain blocked or not run.

### 3.9 Phase 24 Renderer Output Regression Evidence

Recorded 2026-07-02 in `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md`, `24-VERIFICATION.md`, and `24-VALIDATION.md`:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 2 tests and 0 failures.
- `swift test --package-path BeautySDK` passed with 150 tests and 0 failures.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 45 ignored local PNG outputs for 5 fixtures times 9 current renderer cases.
- `python3 .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py --input example-images/input --output example-images/output` passed for all expected outputs, checking existence, non-empty files, same dimensions, and input/output byte difference.
- Public facade import, renderer geometry-case exclusion, geometry status, no-overclaim, decision-coverage, and scoped diff checks passed.
- Geometry saved-output, reference-app parity, broad device evidence, and market visual-quality evidence remain outside Phase 24.

### 3.10 Phase 25 Security and Distribution Closeout Evidence

Recorded 2026-07-03 in `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md`, `25-RESOURCE-TRUST-EVIDENCE.md`, and `25-VALIDATION.md`:

- `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` found no existing manifest; Phase 25 explicitly defers adding `PrivacyInfo.xcprivacy` for current SDK/Demo behavior and records rerun triggers.
- Required-reason seed scans found no active SDK facade or Demo app use of `UserDefaults`, file timestamp, disk-space, system boot-time, active keyboard, or POSIX stat APIs; the only `FileManager.default` seed hit is classified as local example-renderer fixture enumeration.
- Active-source scans and focused Demo privacy/import tests found no default network, upload, cloud, analytics, telemetry, tracking, raw path/error, face geometry payload, raw JSON, image bytes, hidden third-party SDK, payment, VIP, or entitlement behavior after the narrow Demo copy fix.
- Bundled resource trust evidence covers manifest schema, metadata filters, five bundled presets, conservative identifiers, traversal-like ID rejection, unknown preset/filter behavior, and typed redacted missing-resource errors.
- `swift test --package-path BeautySDK` passed with 150 XCTest cases after Wave 1; focused `BeautyResourceCatalogTests`, `BeautySDKFacadeTests`, `BeautyConfigurationTests`, and Demo privacy/import xcodebuild checks passed.
- External LUT, makeup, model, sticker, dynamic download, cache, checksum/signature, package-integrity, screenshot, physical iPhone, 600-second preview, and commercial packaging evidence remain future or blocked/not-run checks.

### 3.11 Phase 26 Geometry Facade and Landmark Routing Evidence

Recorded 2026-07-06 in `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md` and `26-VALIDATION.md`:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 4 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineMetadataCompatibilityTests` passed with 4 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` passed with 6 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` passed with 10 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` passed with 14 tests and 0 failures.
- `swift test --package-path BeautySDK` passed with 159 tests and 0 failures.
- Public/SPI raw geometry export scans and active-source raw-leak scans passed with zero matches.
- Renderer geometry-case exclusion and `SHAPE_FEATURE_LEDGER.md` implemented-status guard scans passed, preserving Phase 27/28 ownership.
- Phase 26 does not claim saved-output geometry rendering, generated PNG evidence, Demo UI behavior, commercial visual quality, full Meitu parity, release readiness, or `脸型` implementation status.

### 3.12 Phase 27 Geometry Render Output Evidence

Recorded 2026-07-07 in `.planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md`, `27-GEOMETRY-RENDERER-EVIDENCE.md`, and `27-VALIDATION.md`:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 8 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 4 tests and 0 failures.
- Focused missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict-cap tests each passed with 0 failures.
- `swift test --package-path BeautySDK` passed with 167 tests and 0 failures.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` wrote 77 ignored PNG outputs across 7 fixtures and 11 cases after `e6.jpg` was added.
- `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/output` passed with 77/77 outputs, same-dimension buckets, 6/6 portrait geometry-vs-baseline top-region comparisons, and no-face output presence.
- Public/SPI raw geometry export scans, active-source redaction scans, renderer public-import scans, renderer scope scans, Demo internal-import scans, overclaim scans, evidence raw-leak scans, and `SHAPE_FEATURE_LEDGER.md` implemented-status guard scans passed.
- Phase 27 does not claim Demo UI behavior, broad geometry-domain saved-output completion, generated PNG baselines, public raw geometry APIs, or face-shape implementation status.

### 3.13 Phase 28 Face-Shape Slice Evidence

Recorded 2026-07-08 in `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-VERIFICATION.md`, `28-FACE-SHAPE-RENDERER-EVIDENCE.md`, and `28-VALIDATION.md`:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 6 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests` passed with 8 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests/testCIImageGeometryWarpMovesLocalPixelsWithoutGlobalColorBias` passed with 1 test and 0 failures after replacing the global color proxy with local control-point warp.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` passed with 5 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests` passed with 7 tests and 0 failures.
- `swift test --package-path BeautySDK` passed with 172 tests and 0 failures after the spatial-warp regression was added.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` wrote 119 ignored PNG outputs across 7 fixtures and 17 cases after `e6.jpg` was added.
- `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output` passed with 119/119 outputs, same-dimension buckets, 36/36 portrait face-shape-vs-baseline top-region comparisons, and no-face face-shape output presence.
- `example-images/input/` source fixtures are now committed under `portraits/` and `negatives/`; `BeautyExampleRenderer` recursively reads nested input fixtures while keeping generated output filenames flat under ignored `example-images/output/`.
- `example-images/input/` source fixtures were compressed or accepted on 2026-07-09: PNG portrait fixtures now use a 900 px maximum edge, `e6.jpg` is a 1728x2304 JPEG source fixture at 591,802 bytes, the no-face negative fixture is 64 px, and every committed source fixture is below 1,000,000 bytes.
- `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 119 ignored gallery PNGs grouped by feature family and case ID.
- `git check-ignore` confirmed representative `example-images/output/*.png` and `example-images/gallery/**/*.png` artifacts are ignored.
- Public/import boundary scans, hidden public-surface scans, evidence redaction scans, ignored-output checks, no-overclaim scans, ledger guards, Demo internal-import scans, and GSD decision coverage passed.
- Phase 28 promotes only `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`; branch-level `脸型` remains partial.

### 3.14 Phase 29 Eye Renderer Output Evidence

Recorded 2026-07-09 in `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md`, `29-EYE-RENDERER-EVIDENCE.md`, and `29-VALIDATION.md`:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 7 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` passed with 6 tests.
- `swift test --package-path BeautySDK` passed with 173 tests.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` wrote 161 ignored PNG outputs across 7 fixtures and 23 cases.
- `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` passed with 161/161 outputs, same-dimension buckets, 36/36 portrait eye-vs-baseline top-region comparisons, and representative no-face output `no-face-gradient__eyeSize_0p35.png` presence.
- `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 161 ignored gallery PNGs, including the `example-images/gallery/eyes/` group.
- Representative `git check-ignore` checks passed for generated eye output and gallery paths; `git ls-files example-images/output example-images/gallery` returned zero tracked generated files.
- Public-boundary, Demo/renderer internal-import, raw-leak, no-overclaim, and GSD decision-coverage checks passed.
- Phase 29 records renderer evidence for existing public eye parameters only. Phase 30 subsequently passed the safety, degradation, redaction, and scoped status gates and promoted exactly four rows; branch-level `眼睛` remains `partial` because other eye tools remain future.

### 3.15 Phase 30 Eye Safety, Ledger, and Closeout Evidence

Recorded 2026-07-11 in `.planning/phases/30-eye-safety-ledger-and-closeout/30-EYE-SAFETY-EVIDENCE.md`:

full_suite_tests: 178

- EYE-04 observed tests passed: `testEYE04EyeInputsNormalizePositiveOnlySignedOverflowAndNonFiniteValues`, `testEYE04EyeCapsResolveExactValuesDirectionsWarningsAndCounts`, and `testEYE04NegativePositiveOnlyEyeInputsAreNoOps`.
- EYE-05 observed tests passed for either-eye missing input, complete-domain zeroing, reused-eye skip, stale-eye skip, preserved non-eye reuse, public no-face behavior, and redacted metadata. Reused eyes skip entirely; reused face shape keeps scale `0.5`, reused nose keeps scale `0.5`, and reused mouth keeps scale `0.5`.
- EYE-06 observed tests passed: `testEYE06EachVisibleEyeBehaviorWeakensWithFaceShapeAndPreservesDirection` and `testEYE06AllEyeMultiDomainCaseEmitsStableWeakeningEvidence`.
- EYE-07 boundary gates passed with zero public/SPI raw-geometry candidates, zero forbidden Demo/renderer internal imports, zero network/cloud paths, zero StoreKit/entitlement execution paths, the unchanged 31-field public inventory, exactly two classified static VIP occurrences, `unclassified_matches: 0`, and no tracked generated output/gallery artifacts.
- The unchanged Phase 29 regression produced 161 outputs; the helper passed 161/161 outputs and 36/36 portrait eye comparisons. Generated outputs remain ignored local evidence.
- `30-REVIEW.md` is clean and `30-SECURITY.md` remains verified with `threats_open: 0`.
- EYE-08 and DOC-01 closeout promoted exactly `大小`, `上下`, `眼距`, and `眼尾上扬`; branch-level `眼睛` remains `partial` with future tools explicitly unimplemented.
- A Demo build was not required because Demo source was unchanged.
- Future eye tools, physical-device evidence, commercial visual review, broader reference parity, packaging, and launch readiness remain separate work.

### 3.16 Phases 31-32 Nose Slice Evidence

Recorded 2026-07-13 in `31-NOSE-RENDERER-EVIDENCE.md`, `32-NOSE-SAFETY-EVIDENCE.md`, and both phase verifications:

- The public-facade renderer passed 196/196 decoded same-dimension outputs, 30/30 portrait nose comparisons, 6/6 signed tip comparisons, and representative no-face extent preservation.
- All required focused suites passed; a fresh full SDK suite passed 186 tests with zero failures.
- Exact caps, signed tip semantics, missing/stale zeroing, reused `0.5`, safe no-face continuation, all-field combined weakening, and redacted aggregate evidence are locked.
- Fail-closed scans passed for raw geometry, internal imports, network/cloud, commercial paths, dependency/public inventory drift, sign loss, and tracked generated artifacts.
- Exactly `大小`, `鼻翼`, `鼻梁`, and `鼻尖` are implemented. `山根`, `提升`, and branch-level `鼻子` remain partial/future; no readiness/parity claim is made.

### 3.17 Phases 35-37 Final Nose Branch Evidence

Recorded 2026-07-14 in `35-VERIFICATION.md`, `36-VERIFICATION.md`, `37-NOSE-SAFETY-EVIDENCE.md`, and `37-VERIFICATION.md`:

- Phase 37 focused suites pass 103/103 and full SwiftPM passes 228/228 with exact `0.25` caps, all-six degradation/transitions, provider-empty removal, and one retained-set convergence.
- The unchanged Phase 36 gate passes 252/252 outputs, 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons; generated artifacts remain ignored and untracked.
- ASVS L1 and active-source boundaries pass with a clean review and `threats_open: 0`.
- Exactly `大小`, `提升`, `鼻翼`, `山根`, `鼻梁`, and `鼻尖` form the implemented six-row SDK-core branch. `山根` uses only `noseRootNarrowing`; `提升` uses only `noseTipLift`.
- This Phase 37 quality result does not claim Demo/device/commercial/packaging/shipping/launch readiness, and the independent milestone audit remains pending.

## 4. Product Domain Scorecard

| Domain | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| SDK Integration | 5 | 4 | App imports only `BeautySDK`; `BeautyEngine` init/process/reset compile and have typed errors. |
| Realtime Camera | 5 | 4 | Camera frames process through SDK, no realtime `UIImage`, UI remains responsive in unit/pipeline tests, bounded backpressure is tested, permission fallback state is covered, and Phase 6 effects route through the shared engine path. |
| Still Image Editing | 4 | 4 | Fixed fixture and PhotosPicker-data seam process through SDK, loading/error preservation is tested, compare state is covered, and Phase 6 image output has deterministic effect evidence. |
| Presets | 4 | 4 | Built-in JSON presets decode, validate, apply deterministically, and sync UI controls. |
| Skin Beauty | 4 | 4 | Default no-op, visible skin/color fixture output, high-strength safety caps, and no-face combined skip behavior are tested. |
| Face Shape | 4 | 4 | Control points are generated safely, combined geometry weakens, no-face skips, and CIImage local warp evidence is tested. |
| Eyes | 4 | 4 | Positive-only/signed inputs, exact caps, missing-eye skips, reused/stale eye-domain skips, combined weakening, and redacted aggregate evidence are tested; 161/161 outputs and 36/36 comparisons pass. Exactly four rows are implemented while branch-level `眼睛` remains partial. |
| Nose | 4 | 4 | Phase 37 passes 228/228 full SwiftPM plus unchanged 252/252 output, independent root/lift comparisons, exact `0.25` caps, all-six degradation/transitions, provider-empty removal, exactly-once convergence, redaction, and `threats_open: 0`. The exact six-row SDK-core `鼻子` branch is implemented; Demo/device/commercial readiness remains separate. |
| Mouth | 4 | 4 | Phase 34 exact caps, signed normalization, exact-zero missing/no-face/stale geometry, reused `0.5`, independent lip-color policy, and combined matrix pass; observed 13/13 focused, 190/190 full SDK, and helper 238/238, 30/30, 12/12, 6/6. Branch `嘴唇` remains partial. |
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
| Detection tests | 4 | 4 | No face, low confidence, missing landmarks, mapping failure, face limit, selection stability, detector unavailable, timeout, reset, public still-image geometry gating, and selected-face routing coverage exists. |
| Render tests | 4 | 3 | Copy pass preserves BGRA bytes, unsupported copy input maps to `BeautyError`, RenderGraph pass order is tested, and Phase 6 has deterministic MVP color/geometry/lip fixture evidence. |
| Effect fixture tests | 4 | 4 | Naturalness-oriented visible fixtures, high-strength safety caps, all-domain combined weakening, no-face degradation, partial landmark skips, reused/stale behavior, and preset output are tested. |
| Performance tests | 4 | 3 | Phase 23 adds repeatable 720p timing, dropped-frame/backpressure, quality-mode, reset/degradation, safety-cap, and redacted evidence tests; 600-second preview and optimized profiling remain future checks. |
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
| `QUALITY_SCORE.md` | 5 | 4 | Phase 21 refreshed the v1.4 baseline from `21-BASELINE-AUDIT.md`; score increases still require command, test, or recorded manual evidence. |
| Historical `docs/` | 3 | 2 | Conflicts with root docs are removed, linked, or marked historical. |

## 8. Security and Reliability Scorecard

| Gate | Target | Current | Required Evidence |
| --- | --- | --- | --- |
| Privacy default | 5 | 4 | Phase 3 static scans show no upload/network path, no raw path/error copy, and no realtime `UIImage` in input paths; no frame/landmark persistence is introduced. |
| Permissions | 4 | 3 | Camera permission mapping and purpose strings are tested; real Settings round-trip remains manual. |
| Resource validation | 5 | 4 | Manifest schema, metadata filter registry, built-in preset lookup, missing-resource typed errors, and traversal-like ID tests. Checksums and byte-size limits remain future work for real assets. |
| Error typing | 5 | 3 | Public foundation failures map to `BeautyError`; broader render/detection/resource failures need later coverage. |
| Degradation | 5 | 4 | No face, partial/missing landmark, low-confidence, stale, skipped/reused, mapping failure, combined effect skip/weakening, and Demo status debounce paths are tested; resource and GPU overload paths remain future work. |
| Observability | 4 | 3 | Logger defaults, disabled mode, redacted warning/metric keys, and optional performance evidence fields are tested; full signpost/MetricKit coverage remains future work. |
| Performance budgets | 4 | 3 | Bounded in-flight work, dropped-frame counters, 720p timing matrix, over-budget classification, and memory rerun protocol are recorded; 600-second preview and optimized profiling remain future checks. |
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
- A score of `5` requires automated regression coverage or a release-like manual protocol.
- Do not give credit for historical `docs/` content if a root document contradicts it.
- Record major score changes in `PLANS.md` or release notes.

## 14. Current Top Repair Queue

| Priority | Item | Why |
| --- | --- | --- |
| 1 | Run the independent v1.9 milestone audit. | Phase 37 is internally complete at 6/6, but audit, archive, tag, cleanup, packaging, and readiness have separate lifecycle owners. |
| 2 | Run dedicated 600-second preview and physical iPhone checks when setup is available. | Phase 23 records a short fixture loop and focused simulator pass evidence, but long-run preview and device evidence remain blocked or not run. |
| 3 | Rerun current Demo screenshot evidence. | Phase 22 completed the documented blocker path; current PNG capture still requires rerunning the exact build/test/screenshot commands and recording pass or blocker status. |
| 4 | Design external resource package trust before enabling any dynamic packages. | Phase 25 covers bundled resources only; LUT, makeup, model, sticker, download, cache, checksum/signature, and package-integrity capability remain disabled. |
| 5 | Keep renderer regression gates current when the renderer matrix changes. | Phase 27 protects the current 11-case matrix, 6 fixtures, and 66 ignored generated outputs; future renderer cases need matching tests, helper inventory, and evidence updates. |
| 6 | Defer formal `.planning/codebase/*` remap until explicitly scoped. | Phase 21 and the Phase 22 drift warning found the maps stale; current source, root contracts, and `.planning` ledgers are authoritative. |

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
| 2026-06-30 | Phase 21 establishes the v1.4 evidence baseline from `21-BASELINE-AUDIT.md`. | SDK tests and renderer commands pass now; Demo build/test is blocked by the missing Metal Toolchain; unresolved visual, hardware, performance, privacy, renderer-regression, and stale-map work routes to Phases 22 through 25. |
| 2026-07-02 | Phase 24 adds renderer output regression gates without changing product scope. | Focused renderer tests, full SDK tests, all-case renderer run, output helper, geometry guard scans, and no-overclaim scans now back RENDER-01 through RENDER-04. |
| 2026-07-01 | Phase 22 records automated Demo QA evidence through the blocker-honest path. | Current screenshot capture is still blocked by the missing Metal Toolchain, but the repo now has exact commands, per-state blocked review notes, route/model honesty evidence, no-PNG inventory, and rerun protocol for QA-01 through QA-04. |
| 2026-07-02 | Phase 23 records performance and reliability evidence from `23-PERFORMANCE-EVIDENCE.md`. | SDK performance evidence, full SDK tests, focused Demo camera tests, quality/reset/degradation regressions, and scans pass; over-budget timing, 600-second preview, screenshot, and physical iPhone gaps remain explicit follow-up work. |
| 2026-07-03 | Phase 25 records security/distribution closeout evidence without raising unsupported capability scores. | Privacy manifest deferral, active-source negative scans, bundled-resource trust tests, focused Demo privacy/import tests, and traceability sync pass; external resources, screenshot rerun, long-run preview, hardware checks, and commercial packaging remain future or blocked/not-run evidence. |
| 2026-07-06 | Phase 26 records public still-image geometry facade/routing evidence without raising saved-output or release-quality claims. | Focused facade/detector/effects tests, full 159-test SDK suite, public/SPI raw geometry export scans, active-source raw-leak scans, renderer-case exclusion, and ledger-status guard pass; Phase 27/28 still own saved-output geometry and `脸型` completion. |
| 2026-07-07 | Phase 27 records saved-output geometry foundation evidence without promoting per-tool face-shape status. | Focused facade/renderer/degradation tests, full 167-test SDK suite, 66 ignored renderer outputs, Phase 27 helper checks, redaction scans, renderer scope scans, and ledger-status guard pass; Phase 28 still owns `脸型` completion. |
