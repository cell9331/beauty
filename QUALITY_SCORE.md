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

Current repository state after the post-archive v1.15 adversarial remediation; the
Phase 64/65 statements below remain historical evidence for the `v1.15` tag:

| Area | Score | Evidence | Next Move |
| --- | --- | --- | --- |
| Root docs | 4 | All nine root owners exist. The consolidation audit corrected `ARCHITECTURE.md` so current pixel-buffer processing, still-image detection/geometry, and placeholder Render foundations match compiled code. | Keep current facts in root owners; keep milestone narratives in archives. |
| Historical docs | 3 | `docs/README.md` remains the long-doc entry. `.planning/codebase/*` is explicitly stale background and historical phase/milestone artifacts are not current contracts. | Refresh codebase maps only in an explicitly scoped remap. |
| GSD planning | 4 | Phase 64/65 and the independent 40/40 audit remain archived. Post-archive review and adversarial Full Sclera remediation are completed without changing the tag. | Start the next milestone with fresh requirements. |
| SDK Package | 4 | The package/facade boundary is intact; per-eye mapping is local, teeth ownership is fixed-inner-aperture only, and teeth/sclera compose through one canonical request owner. Exact inventory remains 61 public fields, five neutral presets, and 74 renderer cases. | Preserve original-pixel composition, fixed-only teeth ownership, and named-sRGB output. |
| Demo App | 4 | The unchanged Demo builds and passes 121/121 on iPhone 17e / iOS 26.5; teeth, sclera-redness, and `去脂` rows remain disabled with nil mappings. | Preserve disabled taxonomy through milestone closeout. |
| Tests | 4 | Focused Full/composition/adversarial/integration/Focal suites pass 60/60; the authorized Full Sclera pair passes 2/2. Full current SwiftPM passes 650 tests with eight documented opt-in skips; the archived tag retains its separate 638/0/0 no-skip evidence. | Keep colored-interior, sparse-trigger, pre-allocation budget, and strict area-ceiling regressions mandatory. |
| Security | 4 | Outer-lip adaptive teeth growth is removed; malformed eye mapping is per-side; Full Sclera requires connected proportional evidence and per-pixel color qualification; sensitive state remains request-local and aggregate-only. | Require approved tooth-specific support before broader teeth ownership and preserve the Full Sclera fail-closed gates. |
| Reliability | 3 | Backpressure, stale work, reset, detection degradation, and the repaired camera lifecycle are test-backed. Realtime geometry/Metal dispatch, 600-second preview, and device endurance are not current evidence. | Keep claims bounded and run the setup-specific long-run/device gates when authorized. |
| Product acceptance | 4 | Bounded SDK-core opaque still-image `白牙` now uses fixed inner-aperture coverage only; `祛红血丝` remains implemented, `眼睛` remains partial solely because `去脂` is future, and all three Demo rows remain disabled. No universal semantic claim is made for color-indistinguishable tissue inside coarse lip support. | Add approved tooth-specific support before broader coverage; keep all release-readiness exclusions. |

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
- Current fixture cutover (2026-07-30): future live tests discover only the local, Git-ignored, rights-approved `p1.jpg` smiling portrait plus `no-face-gradient.png`. The replacement 2628×1778 active JPEG is 1,587,765 bytes, remains below the 16 MiB acquisition ceiling, and carries no GPS, capture-time, device, author, copyright, orientation, or screenshot-comment metadata. `e1`–`e6` and their prior generated outputs are parked outside active paths. Historical phase counts above remain evidence for their original fixtures and are not silently transferred to `p1`.
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

### 3.18 TD-012 Production Image Input Bounds

Recorded 2026-07-28:

- Focused SDK configuration/engine tests pass 23/23; focused `ImageEditorPipelineTests` pass 12/12 on iPhone 17e / iOS 26.5.
- Full SwiftPM passes 457 tests with six expected skips and zero failures; the full `BeautyDemo` simulator suite passes 118/118.
- Default 32 MiB encoded and 50,000,000-pixel ceilings, custom positive values, non-positive normalization, current/legacy Codable behavior, exact/one-over boundaries, fail-fast ordering, friendly recovery, and stale-work isolation are automated.
- Security rises from 3 to 4 for this verified boundary only. Physical-device, screenshot, optimized-performance, 600-second, commercial, packaging, shipping, and release-readiness evidence remains unchanged.

## 4. Product Domain Scorecard

| Domain | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| SDK Integration | 5 | 4 | App imports only `BeautySDK`; `BeautyEngine` init/process/reset compile and have typed errors. |
| Realtime Camera | 5 | 3 | Camera frames process off-main through a bounded latest-frame pipeline with no `UIImage`; lifecycle, permission, pause, and backpressure paths are tested. The current pixel-buffer facade has no Vision/geometry or Metal-warp dispatch, and device/long-run evidence is absent. |
| Still Image Editing | 4 | 4 | Fixed fixture and PhotosPicker-data seam process through SDK, loading/error preservation is tested, compare state is covered, and Phase 6 image output has deterministic effect evidence. |
| Presets | 4 | 4 | Built-in JSON presets decode, validate, apply deterministically, and sync UI controls. |
| Skin Beauty | 4 | 4 | Default no-op, visible skin/color fixture output, high-strength safety caps, and no-face combined skip behavior are tested. |
| Face Shape | 4 | 4 | Nine public face/chin fields have provider, degradation, convergence, facade, and 413/413 strict output evidence; three semantic-region rows remain future and branch `脸型` remains partial. |
| Eyes | 4 | 4 | Fourteen geometry rows have exact cap/degradation/convergence and 385/385 facade-output evidence; bounded SDK-core still-image `祛红血丝` is implemented in promotion-pending state, `去脂` remains future, and branch `眼睛` remains partial. |
| Nose | 4 | 4 | Phase 37 passes 228/228 full SwiftPM plus unchanged 252/252 output, independent root/lift comparisons, exact `0.25` caps, all-six degradation/transitions, provider-empty removal, exactly-once convergence, redaction, and `threats_open: 0`. The exact six-row SDK-core `鼻子` branch is implemented; Demo/device/commercial readiness remains separate. |
| Mouth | 4 | 4 | Eight geometry rows have exact cap/degradation/convergence and 308/308 facade-output evidence; `lipColor` remains color-only, `白牙` remains future, and branch `嘴唇` remains partial. |
| Eyebrows | 4 | 4 | Seven independent rows have actual request-local support, exact `0.25` caps, 44-field convergence, 72/72 portrait output, thirteen no-face comparisons, and exact branch promotion. |
| Filters | 4 | 4 | `filterId nil`, missing filter, intensity 0/1, metadata filter IDs, and Demo filter selection are covered; real LUT decode remains Phase 6+ render scope. |
| Makeup | 3 | 0 | Resource manifest, missing-resource behavior, landmark attachment tests. |
| Background / Segmentation | 3 | 0 | Mask edge fixtures, no-person fallback, device downgrade behavior. |
| Body Shape | 3 | 0 | Human landmark contract, half/full-body fixtures, safety caps. |
| Video Export | 3 | 0 | Progress, cancel, orientation, audio preservation, failure recovery. |

## 5. Code Layer Scorecard

| Layer | Target Score | Current | Required Evidence For 4+ |
| --- | --- | --- | --- |
| `BeautyCore` | 5 | 3 | Value/Codable/normalization/error contracts are tested, but generic `BeautyResult<Output>` currently uses unconditional `@unchecked Sendable`; the public concurrency claim needs a compatibility-safe redesign. |
| `BeautyDetection` | 4 | 4 | Detector protocol, Vision adapter seams, face selection, coordinate mapper, mapping failures, and safe public summaries are tested. |
| `BeautyRender` | 5 | 3 | `RenderGraph`, `RenderPass`, `CopyRenderPass`, `PixelBufferFactory`, and `Warp.metal` placeholder exist with copy/pass-order tests; Phase 6 adds deterministic MVP color/geometry proxy evidence through `BeautyEffects`. |
| `BeautyEffects` | 4 | 4 | Effect resolver, safety caps, skin/color/filter output, face/eye/nose/mouth providers, lip color, combined weakening, no-face skips, missing-landmark degradation, and preset evidence are tested. |
| `BeautyResources` | 4 | 4 | Bundle loading, schema-versioned manifest validation, metadata filters, preset lookup, missing/invalid resource tests, and traversal-like ID rejection are covered. |
| `BeautySDK` facade | 5 | 4 | Facade tests import only `BeautySDK` and access public foundation, metadata, result, and detection summary types; render test helpers are exposed only through testing SPI. |
| `BeautyDemo` | 4 | 4 | Demo shell, parameter panel, preview fixture, enabled Camera/Photo modes, Camera session/pipeline, Photo pipeline, compare state, privacy scans, import-boundary tests, and view-state tests exist. |

## 6. Test Coverage Scorecard

| Test Area | Target Score | Current | Minimum Coverage |
| --- | --- | --- | --- |
| Parameter tests | 5 | 4 | Exact 59-field inventory, legacy 31/33/38/48/52 payload neutrality, independent storage, ranges, non-finite reset, `Sendable`, presets, and Codable round trips are covered. |
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

Pass: no `fatalError` or `try!`; the sole `as!` is the UIKit structural cast in
`CameraPreviewLayerView`, where the same class overrides `layerClass` to
`AVCaptureVideoPreviewLayer.self`. Any additional match requires review.

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
test -f .planning/PROJECT.md && test -f .planning/STATE.md && test -f .planning/ROADMAP.md
if rg -q '^\*\*Current milestone:\*\* None' .planning/PROJECT.md; then
  test ! -e .planning/REQUIREMENTS.md
else
  test -f .planning/REQUIREMENTS.md
fi
```

Pass: project/state/roadmap owners exist; active requirements exist exactly when
a milestone is active and are absent after an archived lifecycle closeout.

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
| 1 | Repair `BeautyResult<Output>` sendability without lying or silently breaking clients. | Unconditional `@unchecked Sendable` permits arbitrary non-sendable output types; the public API compatibility strategy needs a separate decision. |
| 2 | Run dedicated 600-second preview and physical iPhone checks when setup is available. | Short simulator and fixture evidence cannot establish camera/Vision parity, memory, thermal, or endurance behavior. |
| 3 | Rerun current Demo screenshot/UI evidence. | Model and simulator tests pass, but current layout screenshots and UI automation were not produced in this audit. |
| 4 | Design external resource package trust before enabling dynamic packages. | Current bundled metadata/presets do not prove download, cache, checksum/signature, model, LUT, or package-integrity behavior. |
| 5 | Defer formal `.planning/codebase/*` remap until explicitly scoped. | Current source, root contracts, and live planning owners remain authoritative over stale maps. |

## 15. Quality Decision Log

### v1.10 Phase 40 Mouth Geometry Closeout

- Fresh full SwiftPM evidence passes 265/265 (up from the Phase 39 baseline of 260); the unchanged Phase 39 strict renderer gate passes 308/308 decoded same-dimension outputs with all visibility, signed-direction, independence, and no-face comparisons.
- Requirement-focused Phase 40 suites pass 106 cases, the promotion checker passes 63/63 mutation self-tests and all live owner/boundary checks, standard code review is clean, and ASVS L1 records `threats_open: 0`.
- Exactly five mouth geometry rows are promoted while `白牙` and branch-level `嘴唇` remain future/partial. Scores do not gain credit for Demo UI, device parity, subjective/commercial visual quality, optimized performance, packaging, shipping, or launch readiness.

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | Scores distinguish current state from target state. | The repo has strong planning docs but little SDK implementation yet. |
| 2026-05-25 | A score above `3` requires verification evidence. | Prevents optimistic scoring without tests or checks. |
| 2026-05-25 | Historical `docs/` count as background, not current contract. | Root docs are now the Agent-first source of truth. |
| 2026-06-10 | Build checks must use an explicit iOS Simulator destination. | The default `xcodebuild ... build` command can select an incompatible `My Mac` destination even when the iOS simulator build succeeds. |
| 2026-06-10 | `.planning/PROJECT.md`, `.planning/STATE.md`, and `.planning/ROADMAP.md` are persistent GSD context; `.planning/REQUIREMENTS.md` exists only for an active milestone. | Prevents archived closeouts from failing a stale always-present requirement check. |
| 2026-07-28 | Current-state scores are evidence-bounded rather than milestone-inherited. | Realtime and security scores were reduced where compiled paths or input-limit enforcement do not satisfy the owning contracts. |
| 2026-07-28 | TD-012 raises Security from 3 to 4 after focused and full automated input-bound evidence passes. | Public SDK and Demo boundaries now reject oversized production inputs before the available expensive work while retaining the explicit PhotosPicker pre-transfer allocation residual. |
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

### v1.11 Phase 44 Eye Geometry Evidence Score

- Fresh focused evidence passes 4/4 caps, 19/19 resolver, 16/16 provider, 40/40 degradation, 12/12 conflict, 13/13 combined, and 13/13 facade; full SwiftPM passes 314/314.
- Unchanged strict saved-output evidence passes 385/385 decode/dimensions, 66/66 visibility, 6/6 direct tilt, 60/60 semantic distinctions, 132/132 portraits, and 11/11 no-face comparisons.
- The boundary self-test passes 57/57 and live pre-promotion/promotion checks pass 13/13 and 14/14. Review status is clean with zero findings; ASVS L1 records `threats_open: 0`.
- These automated scores do not replace device, subjective/commercial, optimized-performance, packaging, shipping, launch, or independent milestone-audit evidence.

### v1.12 Phase 48 Face Safety Evidence Score

- Fresh Phase 48 focused evidence passes 132/132; full SwiftPM passes 375 tests with three explicit opt-in Apple Vision skips and zero failures.
- The unchanged strict output gate passes 413/413 decode/dimensions, 18/18 visibility/locality, 49/49 fixed-neighbor, 6/6 ineligible, and 4/4 no-face comparisons; the exact 413-file ignored gallery remains untracked and unstaged.
- The boundary checker compiles, passes 70/70 self-test mutations, 17/17 pre-promotion checks, and 18/18 promotion checks. Standard review is clean; ASVS L1 records `threats_open: 0`.
- Exactly four rows are promoted while three rows remain future and branch `脸型` remains partial. Scores gain no credit for device, subjective/commercial quality, optimized performance, Demo work, packaging, shipping, launch, or independent milestone-audit evidence.

### v1.13 Phase 51 Eyebrow Output Evidence Score

- Fresh focused evidence passes renderer 16/16, provider 12/12, and facade 18 passes with one explicit opt-in Apple Vision integration skip. After a fail-closed zero-extent projection correction, the fresh full SwiftPM retry passes 438 executed with six opt-in skips and zero failures.
- The final guarded clean render and frozen strict helper pass 72/72 `e6` portrait outputs, 13/13 visibility, 6/6 signed direction, 21/21 semantic distinctions, 40/40 direct portrait comparisons, and thirteen separately counted no-face no-ops.
- Gallery publication is exactly 144 regular PNGs with thirteen eyebrow groups and a 144/144 output/gallery name bijection. Output, gallery, and bounded quarantine are ignored, untracked, and unstaged; staging is absent. Fourteen actual images were opened at original detail and the recorded visual verdict passes.
- These counts close Phase 51 output evidence only. They do not raise quality credit for final caps, exhaustive safety, row/branch promotion, Demo/device/commercial naturalness, optimized performance, packaging, shipping, launch readiness, or Phase 52 completion.

### v1.13 Phase 52 Eyebrow Safety Evidence Score

- Fresh focused evidence passes caps 7/7, resolver 27/27, provider 14/14, degradation 51/51, conflict 14/14, combined 17/17, pipeline 4/4, and facade 20 executed with one opt-in skip. Full SwiftPM executes 450 tests with six expected skips and zero failures.
- The unchanged `BeautyDemo` scheme discovers `iPhone 17 Pro` on iOS 26.5 and passes both explicit-simulator build and test commands; `git diff --name-only -- BeautyDemo` remains empty.
- The unchanged frozen output gate passes 72/72 `e6` portraits, 13/13 visibility/locality, 6/6 signed direction, 21/21 semantic distinction, and 40/40 direct comparisons; thirteen no-face comparisons remain separate. Output and gallery are an exact ignored, untracked, unstaged 144-file bijection, and all fourteen actual images retain a recorded PASS.
- The archived fail-closed checker passes exactly 130/130 adversarial self-tests and passed 35/35 post-verification/pre-audit readiness checks; ASVS L1 records `threats_open: 0`. The archived 28-file `.planning/milestones/v1.13-phases/52-eyebrow-safety-and-branch-closeout/52-REVIEW.md` is clean with critical/warning/info/total findings 0/0/0/0, combining an independent 18-file base and a labeled 10-file inline checker/governance delta; its focused regression passes 154 tests with one documented skip. The exact lowercase `nyquist` lifecycle is `validated` at 23/23 green task rows.
- Independent `.planning/milestones/v1.13-phases/52-eyebrow-safety-and-branch-closeout/52-VERIFICATION.md` passes 16/16 and closes all four prior gaps. Phase 50's three retained source judgments pass 3/3, and Phase 50/52 validation is `validated`. The independent v1.13 audit passes 21/21 requirements, 4/4 phases, 12/12 integrations, 6/6 flows, and 4/4 Nyquist ledgers with no residual debt. Exactly seven eyebrow rows and branch `眉毛` are implemented at SDK-core scope. Archive and cleanup are complete; quality credit does not extend to v1.14-v1.16, new UI/Demo behavior, device parity, commercial naturalness, optimized performance, packaging, shipping, or launch/release evidence.

### v1.14 Phase 53 Canonical Still-Image Foundation Evidence Score

- The fail-closed checker passes six self-test cases and live source classification with exact edge equality `16 = 13 automated + 3 flagged`; the flagged rows remain `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY`.
- The named foundation/compatibility gate passes 83/83, the unchanged renderer regression passes 18/18, and full SwiftPM passes 495 tests with six documented opt-in skips and zero failures. All ASVS Level 1 HIGH mitigations are exercised; no HIGH row is skipped.
- Exact 59-field storage/Codable shape, 58 neutral numeric defaults plus nil `filterId`, legacy source and missing-key neutrality, five preset IDs/source hashes, 72 renderer cases, inactive pixels/metadata, explicit-sRGB admitted routing, and aggregate-only privacy are locked.
- This raises evidence only for the private still-image foundation. It does not admit a candidate, qualify feature-specific rights/naturalness, or add UI/Demo, realtime, transparent/HDR, model/cloud, device/performance, packaging, shipping, commercial, or release-readiness credit.

### v1.14 Phase 54 Evidence and Eligibility — Validated Post-Fix Score

- EVID-01 through EVID-05 and LID-01 have focused mutation coverage for manifest/path/budget validation and independently trusted grant resolution bound to fixture/feature/polarity/expected-target/use/classification plus exact original/mask/after keys and SHA-256 byte digests. Digests are computed before snapshot selection; substituted bytes, rekeyed or swapped triples, manifest-controlled target policy, invented/mismatched/reused grants, and self-promoted assertions remain closed. The tracked registry is empty until a complete real triple is independently pinned.
- The repository decision ledger is regenerated from an explicit empty eligible/review inventory. Its three independent rows have zero eligible/reviewed/accepted/rejected counts and zero naturalness weight; teeth and sclera each record both missing genuine polarities, while upper-eyelid fullness also records `non_warp_design_unqualified`.
- Post-fix Phase 54 evidence-governance credit is validated. The canonical threat inventory independently pins exactly T-54-01…T-54-08 and rejects coordinated missing/extra/replacement drift; current automated live mode passes the exact named `8/8`. No product activation, device, population, commercial-naturalness, performance, packaging, shipping, launch, or release credit is claimed; Phase 53 exact-empty production admission and SDK/Demo absence remain mandatory.
- Final Phase 54 review-fix evidence adds adversarial PNG/JPEG header mutations and instruments the rejection path to prove oversized dimensions/pixel counts create neither `Image` nor object URL. Bounded headers proceed to exactly one decode and must match decoded dimensions; this replaces the prior post-decode dimension-only claim.
- Current post-fix automation passes 33/33 core, 38/38 reviewer, 119/119 checker, exact live `8/8`, 500 SwiftPM tests with six documented skips and zero failures, explicit iPhone 17e/iOS 26.5 Demo build and xcresult-backed 118/118 tests, schema/UI/diff gates, and a clean standard review. The prior 2026-08-01 browser evidence remains historical only; a fresh 2026-08-03 direct local smoke and 1,640-byte allowlisted export pass.
- Nyquist/final evidence is validated after the user-confirmed direct `file://` smoke covered blinded exact media, invalid/wrong replacement recovery, input re-enable, transactional URL cleanup/navigation containment, later valid replacement, export, reload, and responsive behavior. All three product gates remain safely closed with zero eligible/reviewed/accepted/rejected counts and zero naturalness weight.

### v1.14 Phase 55 Composition Core Evidence Score

- Exact task/validation traceability is 9/9; COMP-01 through COMP-05 are 5/5; paired context/plan decisions D-01/D-55-01 through D-20/D-55-20 are 20/20; T-55-01 through T-55-07 are 7/7 machine-green HIGH mitigations.
- The post-review checker passes a 27-case self-test, including 14 executable mutations of temporary copies of the actual Swift fixtures/classifier, plus live classification. This supersedes the historical 44-case synthetic-contract count; current focused regression counts are recorded in the Phase 55 evidence artifact.
- Post-fix focused gates pass composition 21/21, facade/foundation 29/29, and compatibility 74/74. Full SwiftPM passes 534 executed with six documented opt-in Vision skips and zero failures. Explicit iPhone 17e/iOS 26.5 Demo build/test passes; the retained xcresult-backed Demo denominator is 118/118 with zero failures/skips. Schema, UI, and diff gates are green.
- Credit is limited to private feature-neutral composition mechanics, facade adjacency, privacy shape, and recovery. It does not admit a candidate or raise product, UI, realtime, device, naturalness, optimized-performance, commercial, packaging, shipping, launch, or release-readiness scores.

### v1.14 Phase 56 Closed Teeth Evidence Score

- Exact traceability passes 5/5 task rows, TEETH-01 through TEETH-06 6/6 conditional dispositions, D-56-01 through D-56-16 16/16, and T-56-01 through T-56-07 7/7 machine-green HIGH mitigations.
- Post-verification focused SwiftPM passes 96/96 and focused Demo passes 28/28; the checker passes 111 aggregate mutation/scanner/inventory cases, per-threat totals `38 / 32 / 22 / 23 / 31 / 19 / 24`, all seven modes, and live 59/5/72 classification. The matrix includes complete-production-Swift `enamel`/`dentition` scanning and neutrally named provider mutations for T-56-02/T-56-03. Full SwiftPM executes 539 tests with six documented opt-in Vision skips and zero failures; explicit iPhone 17e/iOS 26.5 Demo build passes and Demo tests pass 119/119.
- Quality credit is limited to exact closed-gate enforcement, compatibility, privacy, and regression safety. TEETH-02 through TEETH-05 remain `not_applicable_closed_gate`; no algorithm, containment, effectiveness, naturalness, image review, device/performance, commercial, packaging, shipping, launch, or release credit is added.

### v1.14 Phase 57 Closed Eye-Retouch Evidence Score

- Exact traceability passes 7/7 task rows, SCLERA-01 through SCLERA-06 plus LID-02 through LID-05 10/10 conditional dispositions, D-57-01 through D-57-20 20/20, and T-57-01 through T-57-08 8/8 machine-green HIGH mitigations.
- Final focused SwiftPM passes 141/141. The post-verification-gap checker passes 519 aggregate live-fixture mutation/scanner/inventory/owner cases, per-threat totals `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42`, all eight independent modes, and clean decision/live classification. It covers 44 sclera and 74 upper-eyelid camelCase, snake_case, dotted Demo-ID, and owned Chinese identities, one neutral-file proxy relation per identity, recursive Demo routes with only two exact disabled declarations allowlisted, exact evidence schemas/privacy shapes, fixed-output subprocess failures, and owner deletion/duplication/contradiction. Full SwiftPM executes 544 tests with six documented opt-in Vision skips and zero failures; explicit iPhone 17e/iOS 26.5 Demo build passes and Demo tests pass 120/120.
- Quality credit is limited to independent exact closed-gate enforcement, LID-04 proxy rejection, compatibility, privacy, and regression safety. No algorithm, per-eye containment, effectiveness, naturalness, non-warp result, image/human review, device/performance, commercial, packaging, shipping, launch, or release credit is added.

### v1.14 Phase 58 Combined Closeout Evidence Score

- Exact traceability is `7/7` task rows, `7/7` dispositions, `20/20` decisions, and `8/8` machine-green HIGH identities. The Phase 58 checker passes `276` aggregate cases with per-threat totals `80 / 33 / 37 / 34 / 28 / 31 / 25 / 8`; the frozen Phase 57 fixture remains `519/519`.
- Full SwiftPM executes `553` with six expected Vision skips and zero failures; the separate opt-in Vision gate executes `6/0/0`; explicit iPhone 17e/iOS 26.5 Demo build/tests pass `120/120`. Schema/UI/decision/traceability/diff and exact historical drift gates are green.
- Quality credit is limited to exact zero-admission enforcement, privacy, request-local recovery, compatibility, and regression safety. External review/fix, independent verifier, and milestone audit remain lifecycle work; no feature-effect, naturalness, device, performance, commercial, packaging, shipping, launch, or release credit is added.

### v1.15 Phase 59 Open Teeth Intent Score

- The canonical teeth decision is serializer-open at `2/2/2/0/2` with exactly two fixed structured reviews; sclera redness and upper-eyelid fullness remain closed. EVID-07 and the TEETH-07/08 intent seam are exercised without granting provider/output credit.
- Final executed automation is green: private evidence contracts `9/9`, focused SDK `147/147`, full SwiftPM `558/0/6`, full Demo `121/121`, checker mutations `235/235`, and isolated HIGH identities `8/8`. Fresh serializer-ledger reproduction, five preset hashes, 72 renderer IDs, three disabled Demo rows, 16/16 decision coverage, tracked/staged privacy, JSON, Python syntax, and diff hygiene pass.
- The locked compatibility boundary is exactly 60 stored/CodingKey/initializer fields, five unchanged neutral presets, 72 renderer cases, one opaque demand, and three disabled local-retouch Demo rows. No provider, mask/transform, renderer/output behavior, active Demo mapping, realtime/pixel-buffer route, model/network route, sclera surface, or `去脂` surface exists.
- Quality credit is limited to exact evidence admission, scalar compatibility, binary request intent, privacy, and downstream absence. The mechanics-only candidate adds no product credit. Phase 60 provider safety and Phase 61 public output remain unrun, and no visible-effect, population, device, performance, commercial, packaging, shipping, launch, or release credit is added.

Command-level evidence is recorded in the [Phase 59 validation strategy](.planning/milestones/v1.15-phases/59-teeth-evidence-and-admission-contract/59-VALIDATION.md) and [exact-open boundary summary](.planning/milestones/v1.15-phases/59-teeth-evidence-and-admission-contract/59-07-SUMMARY.md).

### v1.15 Phase 60 Teeth Provider Evidence Score

- Exact traceability passes 4/4 plans, 8/8 task rows, TEETH-09 through
  TEETH-14 6/6, D-01 through D-16 16/16, and T-60-01 through T-60-08 8/8
  machine-green HIGH mitigations.
- Provider tests pass 12/12; provider plus composition passes 33/33; the final
  integration suite passes 10/10. The broader integration/foundation/
  composition set passes 49/49, while integration/foundation/metadata/geometry
  compatibility executes 59 with zero failures and one existing opt-in skip.
- The authorized private genuine pair passes frozen positive, negative,
  containment, texture, alpha, and bounded-color gates through fixed-output
  execution. The checker passes 8/8 mutation cases, 99 live assertions, and all
  eight isolated HIGH modes with per-threat totals `11 / 14 / 10 / 18 / 7 / 6 /
  21 / 12`.
- Full SwiftPM executes 581 tests with seven documented opt-in skips and zero
  failures. Explicit iPhone 17e / iOS 26.5 Demo build succeeds and tests pass
  121/121 with no skips.
- Quality credit is limited to the package-only still-image provider, bounded
  transform, request-local integration, genuine-pair aggregate bounds,
  compatibility, privacy, and recovery. Phase 61 public-output evidence and
  exact promotion remain unrun; no population, realtime, device/performance,
  commercial, packaging, shipping, launch, or release credit is added.

Command-level evidence is recorded in [Phase 60 verification](.planning/milestones/v1.15-phases/60-teeth-provider-and-production-integration/60-VERIFICATION.md).

### v1.15 Phase 61 Teeth Output and Promotion Evidence Score

- Exact traceability passes 4/4 plans, 8/8 task rows, TEETH-15/16 2/2, and
  T-61-01 through T-61-08 8/8 machine-green HIGH mitigations with zero open
  findings.
- Post-promotion focused execution passes renderer 21/21, provider 12/12,
  integration 10/10, and adversarial final-output 6/6. The strict helper passes
  18/18; the required positive/negative/no-face matrix passes 6/6; the checker
  passes 8/8 mutation probes, 64 live post assertions, and all eight isolated
  threat modes.
- Full SwiftPM executes 587 tests with seven documented opt-in skips and zero
  failures. Explicit iPhone 17e / iOS 26.5 Demo build succeeds and tests pass
  121/121 with no skips. The retained Phase 60 checker passes 8 mutations and
  99 live assertions; tracked/staged privacy scans 1,357 files successfully.
- Quality credit is limited to the bounded still-image SDK-core teeth output,
  original-detail review, exact `白牙`/`嘴唇` promotion, compatibility, privacy,
  protected-region safety, and recovery. No population, realtime, device/
  performance, commercial, packaging, shipping, launch, release, sclera, or
  upper-eyelid credit is added.

Command-level evidence is recorded in [Phase 61 verification](.planning/milestones/v1.15-phases/61-teeth-output-safety-and-independent-closeout/61-VERIFICATION.md).

### v1.15 Phase 62 Sclera Evidence and Intent Score

- Exact traceability passes 5/5 plans, 10/10 task rows, EVID-06/08/09/10 and
  SCLERA-07/08 6/6, plus T-62-01 through T-62-08 8/8 machine-green HIGH
  mitigations with zero open findings.
- Required private evidence and fresh serializer equality pass. Model/preset
  filters pass 73/73, admission/foundation/teeth/renderer filters pass 87/87,
  checker self-test rejects 144 mutations, and all eight isolated threat modes
  pass.
- Full SwiftPM executes 590 tests with seven documented non-required opt-in
  skips and zero failures. Explicit iPhone 17e / iOS 26.5 Demo build and tests
  pass 121/121 with no skips. Tracked/staged privacy, Python, JSON, preset-byte
  and diff gates pass.
- Quality credit is limited to independent evidence, the trailing 61st scalar,
  exact `0/1/1/2` request intent, compatibility, privacy and downstream
  absence. No provider, visible sclera output, Demo/product promotion,
  population, realtime, device/performance, commercial, packaging, shipping,
  launch or release credit is added.

Command-level evidence is recorded in [Phase 62 verification](.planning/milestones/v1.15-phases/62-sclera-evidence-and-admission-contract/62-VERIFICATION.md).

### v1.15 Phase 63 Guarded Sclera Provider Score

- Exact traceability passes 4/4 plans, 8/8 task rows, SCLERA-09 through
  SCLERA-13 5/5, D-01 through D-16 16/16 and T-63-01 through T-63-08 8/8
  machine-green HIGH mitigations with zero open findings.
- The final private native-Vision pair passes through fixed-output execution;
  provider/integration passes 20/20; checker self/live and eight isolated
  threat modes pass. Acceptance bounds remain unchanged and tracked evidence is
  aggregate-only.
- Full SwiftPM executes 612 tests with eight documented non-required opt-in
  skips and zero failures. Explicit iPhone 17e / iOS 26.5 Demo build succeeds
  and tests pass 121/121 with no skips. Python, JSON, privacy, inventory and diff
  gates pass.
- Quality credit is limited to current-support ownership, per-eye guard,
  immutable-source transform, peer isolation, recovery, compatibility and
  privacy. No strict public output, adversarial recolored-anatomy proof, final
  visual review, product promotion, population, realtime, device/performance,
  commercial, packaging, shipping, launch or release credit is added.

Command-level evidence is recorded in [Phase 63 verification](.planning/milestones/v1.15-phases/63-guarded-per-eye-sclera-production-integration/63-VERIFICATION.md).

### v1.15 Phase 64 Sclera Output and Promotion Evidence Score

- The current exact inventory is 21 plans / 38 task IDs. Plans 64-01 through
  64-20 account for the first 37 IDs; only `64-21-01` remains pending. Fresh
  terminal R2 evidence and the guarded candidate cover SCLERA-14 through
  SCLERA-18 and OUT-05 without substituting for canonical final authority.
- The terminal R2 conjunction passes focused 74/74, strict helper 14/14,
  positive/negative/no-face output 6/6, four-item original-detail review,
  checker/no-skip self-tests, exact full SwiftPM 637/0/0 with all eight opt-ins,
  Demo build, and Demo tests 121/0/0.
- Fresh independent code review records zero HIGH and zero warnings. Fresh ASVS
  L1 security closes all eight T-64-01 through T-64-08 HIGH identities. Both
  artifacts are bound to the exact 19-path source tree and cannot be outweighed
  or replaced by aggregate prose.
- Quality credit now includes bounded SDK-core standalone output, bilateral
  protected-anatomy identity, peer/recovery isolation, compatibility, privacy,
  and product-facing `祛红血丝` implemented in promotion-pending state. `眼睛`
  remains partial and `去脂` remains future. Phase 65 is blocked and
  DeviceRGB/named-sRGB receives zero Phase 64 credit because it remains
  exclusively Phase 65 SAFE-06 scope. No combined-facade, population,
  realtime, device/performance, commercial, packaging, shipping, launch, or
  release credit is added.

This state is promotion pending terminal candidate/final verification;
canonical `64-VERIFICATION.md` remains `gaps_found`. Fresh authority is recorded
in [terminal R2 output evidence](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-SCLERA-OUTPUT-EVIDENCE.md), [original-detail review](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-REVIEW.md), [code review](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-CODE-REVIEW.md), [review-fix disposition](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-REVIEW-FIX.md), [ASVS L1 security audit](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-SECURITY.md), and [independent eligibility](.planning/milestones/v1.15-phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-TERMINAL-R2-PRE-PROMOTION-VERIFICATION.md).

### v1.15 Phase 65 Archived Closeout

<!-- PHASE65_FINAL_OWNER_BEGIN -->
owner: QUALITY_SCORE
phase: 65
milestone: v1.15
public_fields: 61
neutral_presets: 5
renderer_cases: 74
disabled_demo_rows: 3
teeth: implemented
mouth: implemented
sclera_redness: implemented
eyes: partial
eye_fat: future
safe_06: closed
lifecycle: archived
release: non-release
<!-- PHASE65_FINAL_OWNER_END -->

- Phase 65 records 4 plans, 8 task rows, 11 requirements and eight HIGH owners
  with zero open finding. Combined byte/failure/lifecycle tests, the 42-case
  checker mutation inventory and every isolated T-65-01 through T-65-08 mode
  pass.
- Both private standalone saved-output matrices pass 6/6 and their strict PNG
  decoders reject missing explicit-sRGB metadata. Actual renderer outputs are
  named sRGB, have no EXIF orientation, preserve dimensions and decode with
  opaque alpha.
- Full SwiftPM passes 638/638 with zero failures and zero skips, including all
  eight opt-in Vision/private test identities. Explicit iPhone 17e / iOS 26.5
  Demo build and tests pass 121/121 with zero skips.
- Exact compatibility remains 61 public fields, five neutral presets, 74
  renderer cases and three disabled nil-mapped Demo rows. Product equality is
  implemented `白牙`/`嘴唇`, implemented `祛红血丝`, partial `眼睛`, and future
  `去脂`.
- Quality credit is bounded to SDK-core opaque still images. No population,
  realtime/pixel-buffer, target-device performance, commercial, packaging,
  shipping, launch or release-readiness credit is added.

Command-level evidence is recorded in [Phase 65 verification](.planning/milestones/v1.15-phases/65-combined-facade-privacy-and-milestone-closeout/65-VERIFICATION.md).

### Post-v1.15 Focal Review Remediation Score

- Fresh review remediation closes five findings: per-eye mapping locality,
  coarse-lip teeth ownership, already-light exact no-op, concave nesting, and
  reviewed-mask geometry/orientation validation.
- New deterministic coverage includes malformed-eye peer/lip continuation,
  seven connected enamel-colored lookalikes inside the former adaptive region,
  material-yellow bright no-op samples, a concave outer polygon whose inner
  vertices pass while an edge crosses the notch, and exact mask
  size/origin/finite/orientation rejection.
- Focused suites pass `45/45`; combined/integration/renderer/private-host suites
  pass `59/59` with two expected opt-in skips; full SwiftPM passes `641/641`
  with eight documented opt-in skips and zero failures.
- The archived Phase 60 checker still encodes the tag's adaptive outer-growth
  contract and therefore is historical rather than current authority after this
  safety correction. Current credit comes from the fixed-only source invariant,
  focused adversarial tests, full SwiftPM, and fresh post-fix review. The `v1.15`
  tag and archive artifacts remain unchanged.
- A fresh exact-tag comparison found the archived sclera result changed only 33
  pixels on one image half with maximum channel delta 2/255. Current authority
  therefore adds visible-effect floors rather than crediting nonzero output:
  bilateral minimum counts, `max(100, 8%)` reviewed-mask coverage, minimum
  channel delta 20, at least 20% weighted-red reduction, and an exact negative.
- The sclera transform now uses weighted conjunctival redness, one material
  gate, bounded mask gain, and a small `0.018` luminance ceiling. Pupil/iris and
  lid protection remain independently adversarially verified; zero protected
  intersection and zero reviewed-mask escape are mandatory.

### Post-v1.15 Full Sclera Quality Delta

- The prior implementation is retained as named `Focal` source, transform, and
  15-test baseline. New `Full` source/transform tests prove bilateral broad
  coverage, neutral and lower-crescent participation, exact facade routing,
  caruncle-only rejection, bounded channel movement, and stronger red removal.
- The full-resolution protected oracle adds the caruncle family and retains
  zero intersection and zero output mismatch across 1,648 recolored protected
  pixels. The opted-in positive/negative test treats the previous mask as a
  Focal anchor, requires intentional but bounded positive expansion, and keeps
  the natural negative byte-exact.
- Adversarial hardening adds accepted-eye colored-interior and two-pixel
  amplification regressions. Final proposals now require light/low-saturation
  qualification, admission requires proportional connected redness, oversized
  grids fail before mask allocation, and the real-fixture edit ceiling uses
  `min(12_000, 1% of canonical pixels)`.
