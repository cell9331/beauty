---
phase: quick-260728-gan
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
  - BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift
  - BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift
  - BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift
  - DESIGN.md
  - SECURITY.md
  - RELIABILITY.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - PLANS.md
  - .planning/STATE.md
autonomous: true
requirements:
  - TD-012
must_haves:
  truths:
    - "Existing callers can construct and decode BeautyConfiguration without supplying the new limits, while callers that opt in can choose smaller positive limits."
    - "BeautyEngine rejects over-limit CIImage and CVPixelBuffer inputs with the existing typed BeautyError.invalidInput before detection, effect resolution, copy, or render allocation; inputs at or below the limit keep current behavior."
    - "The Demo rejects over-limit PhotosPicker bytes before CIImage decoding and rejects over-limit decoded extents before SDK processing or display rendering, preserves the last usable photo, and accepts a later valid photo."
    - "Current root contracts, quality score, TD-012 ledger state, and persistent project state agree on the implemented boundary without claiming pre-transfer PhotosPicker allocation control or new product scope."
  artifacts:
    - path: "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
      provides: "Source-compatible public byte and pixel ceilings with legacy Codable defaults"
      contains: "maximumInputByteCount"
    - path: "BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
      provides: "Overflow-safe image and pixel-buffer preflight gates"
      contains: "maximumInputPixelCount"
    - path: "BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift"
      provides: "Pre-decode byte and pre-processing decoded-extent rejection with recoverable photo state"
    - path: "BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift"
      provides: "Exact-limit, one-over-limit, ordering, and valid-input regressions"
    - path: "BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift"
      provides: "No-decode/no-process oversized-input and recovery regressions"
    - path: "SECURITY.md"
      provides: "Authoritative production image-input trust boundary and residual limitation"
    - path: "PLANS.md"
      provides: "Completed TD-012 execution record and verification evidence"
  key_links:
    - from: "BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
      to: "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
      via: "configuration.maximumInputPixelCount checked at both public processing entry points"
      pattern: "configuration\\.maximumInputPixelCount"
    - from: "BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift"
      to: "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
      via: "one configuration snapshot supplies both byte and decoded-pixel ceilings"
      pattern: "maximumInput(Byte|Pixel)Count"
    - from: "BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift"
      to: "BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift"
      via: "oversized inputs become the existing recoverable failed state while retaining latestSnapshot"
      pattern: "previousSnapshot"
---

<objective>
Close TD-012 by adding finite, configurable production input ceilings to the public SDK contract and enforcing them at every cheap boundary currently available, without changing supported beauty behavior or adding product features.

Purpose: Prevent oversized local images and pixel buffers from reaching expensive decode, detection, copy, or render work while retaining source compatibility, existing typed recovery, stale-work semantics, privacy-safe copy, and valid-input output.
Output: Additive public configuration, overflow-safe SDK and Demo gates, focused regressions, and synchronized current-state documentation.
</objective>

<execution_context>
@/Users/yakangwang/.codex/get-shit-done/workflows/execute-plan.md
@/Users/yakangwang/.codex/get-shit-done/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@PLANS.md
@SECURITY.md
@RELIABILITY.md
@QUALITY_SCORE.md
@DESIGN.md
@PRODUCT_SENSE.md
@.planning/STATE.md
@BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift
@BeautySDK/Sources/BeautyCore/Models/BeautyError.swift
@BeautySDK/Sources/BeautySDK/BeautyEngine.swift
@BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift
@BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
@BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift
@BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift
@BeautyDemo/BeautyDemo/Editor/EditorShellView.swift
@BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift
@BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift

No active milestone or root REQUIREMENTS.md exists. This quick plan is limited to TD-012 hardening and must not create v1.14 scope, add a feature row, change effect output, or claim device/commercial/release readiness.
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Add source-compatible public limits and fail-fast SDK enforcement</name>
  <files>BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift, BeautySDK/Sources/BeautySDK/BeautyEngine.swift, BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift, BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift</files>
  <behavior>
    - Default contract: `maximumInputByteCount == 33_554_432` (32 MiB) and `maximumInputPixelCount == 50_000_000`, chosen to retain ordinary compressed local photos including current 48 MP-class stills while bounding encoded and four-byte decoded memory exposure; non-positive custom values normalize back to these defaults.
    - Compatibility: the two initializer arguments are trailing and defaulted, existing source call sites compile unchanged, full/current JSON round-trips, and legacy JSON with neither new key decodes to the defaults through explicit `decodeIfPresent` handling.
    - Pixel boundary: a CIImage or CVPixelBuffer whose width × height is exactly the configured pixel limit proceeds unchanged; one pixel over throws `BeautyError.invalidInput`.
    - Ordering: over-limit input wins over an invalid filter/resource request, proving rejection occurs before resource validation, face detection, color/effect planning, output-buffer copying, and rendering.
    - Arithmetic safety: zero, negative, non-finite image extents and multiplication-overflow-shaped dimensions fail without multiplying `Int` dimensions or converting an unbounded `CGFloat` product.
  </behavior>
  <action>Write the focused boundary tests first, then add public `maximumInputByteCount` and `maximumInputPixelCount` stored properties, public default constants, and trailing defaulted initializer parameters to `BeautyConfiguration`. Preserve `Codable`, `Equatable`, and `Sendable`; implement legacy missing-key decoding by routing decoded values through the designated initializer so sanitization has one authority. In `BeautyEngine`, validate CIImage extent and CVPixelBuffer dimensions against `configuration.maximumInputPixelCount` at the start of both `processResult` routes, before any resource validation, detection, effect pipeline, or output allocation. Compare by division after positive/finite checks to avoid integer/product overflow. Reuse `BeautyError.invalidInput` deliberately: do not add a `BeautyError` enum case, rename existing APIs, reinterpret `preferredProcessingSize`, or silently resize/downsample caller input, because TD-012 requires a source-compatible recoverable rejection rather than a new processing behavior.</action>
  <verify>
    <automated>CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter 'BeautyCoreTests\.(BeautyConfigurationTests|BeautyEngineTests)'</automated>
  </verify>
  <done>Both public process families reject over-limit inputs as `BeautyError.invalidInput` before downstream work, exact-limit and existing valid no-op/effect cases pass, default/custom/legacy configuration cases pass, and no new public error or image-resizing behavior exists.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Bound the Demo PhotosPicker pipeline before decode and allocation-heavy work</name>
  <files>BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift, BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift, BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift</files>
  <behavior>
    - Compressed-byte boundary: PhotosPicker Data at the configured byte limit reaches the decoder; Data one byte over is rejected synchronously before the decode closure or processing queue runs.
    - Decoded-pixel boundary: a decoded fixture or PhotosPicker CIImage at the configured pixel limit reaches the processor; one pixel over is rejected before the processor and `ImageDisplayRenderer` run.
    - Recovery: byte-limit and pixel-limit failures retain the previous snapshot, use the existing friendly recoverable photo-failure copy without raw error/path/size leakage, settle `waitUntilIdle`, and a later valid input replaces the failure.
    - Stale work: an oversized stale selection cannot replace the latest current success or disturb the existing generation semantics.
  </behavior>
  <action>Write spy-backed pipeline tests with deliberately tiny injected limits so the suite does not allocate production-sized fixtures. Add one internal overflow-safe input-bounds value in `ImageInputModels.swift`, derived from a `BeautyConfiguration` snapshot, and make `ImageEditorPipeline` own that snapshot. Reject PhotosPicker `Data.count` in `process` before state is queued for decoding, then validate every decoded CIImage extent before calling `StillImageProcessor` or either display render. Pass the same configuration into the production `BeautyEngineStillImageProcessor` so Demo and SDK cannot drift. Keep `EditorShellView` on its existing `loadTransferable(type: Data.self)` flow: the PhotosPicker API has already materialized Data before the app can count it, so claim only pre-decode/pre-render protection, not pre-transfer allocation control. Preserve cancellation, loading-over-previous, generation/stale-work, compare, metadata, and existing friendly error behavior; do not add UI, downsampling, network, file-path, or raw-error handling.</action>
  <verify>
    <automated>DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' -only-testing:BeautyDemoTests/ImageEditorPipelineTests test</automated>
  </verify>
  <done>Oversized encoded data cannot invoke the decoder, oversized decoded extents cannot invoke SDK processing/display rendering, both failures preserve a usable snapshot and recover on the next valid selection, and all prior photo pipeline tests remain green.</done>
</task>

<task type="auto">
  <name>Task 3: Synchronize contract owners, quality evidence, TD-012, and persistent state</name>
  <files>DESIGN.md, SECURITY.md, RELIABILITY.md, PRODUCT_SENSE.md, QUALITY_SCORE.md, PLANS.md, .planning/STATE.md</files>
  <action>Update each fact only in its routed owner and use links/references instead of copying the full contract everywhere. DESIGN owns the two exact public configuration fields/defaults, positive-value normalization, legacy decoding, and the invariant that limits reject rather than resize. SECURITY replaces the TD-012 gap with the encoded-byte, CIImage, and CVPixelBuffer enforcement order and explicitly records the unavoidable residual that PhotosPicker Data is materialized before its size is observable. RELIABILITY owns `BeautyError.invalidInput`, previous-snapshot preservation, stale/cancellation continuity, and the focused recovery evidence. PRODUCT_SENSE adds oversized input to the existing invalid-image acceptance without adding a feature or readiness claim. QUALITY_SCORE updates Security from 3 to 4 only after the planned automated evidence passes, removes TD-012 as the top repair item, records actual focused/full test results, and leaves Reliability at 3 plus all device/600-second/screenshot limitations unchanged. PLANS adds one completed quick-hardening record with defaults, compatibility choice, exact commands/results, changes TD-012 to `completed`, and does not activate a milestone. STATE updates last activity/current focus, records the TD-012 decision and closure evidence, removes it from live concerns, and continues to say the repository awaits an explicitly scoped next milestone. Do not rewrite historical milestone artifacts or change TD-013 or deferred product scope.</action>
  <verify>
    <automated>git diff --check &amp;&amp; rg -n 'maximumInputByteCount|maximumInputPixelCount|TD-012' DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning/STATE.md &amp;&amp; ! rg -n 'TD-012.*open/design-required|production image inputs still lack|no public configured byte/pixel ceiling' PLANS.md SECURITY.md QUALITY_SCORE.md .planning/STATE.md</automated>
  </verify>
  <done>All current owners agree on exact limits, source compatibility, fail-fast ordering, typed recovery, PhotosPicker residual risk, and verified evidence; TD-012 is closed while TD-013 and all nonclaims remain untouched.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| PhotosPicker transfer → Demo pipeline | Untrusted local encoded bytes enter the app; byte count is visible only after `loadTransferable(Data.self)` returns. |
| Decoded CIImage → Demo processor | Metadata-controlled extents can trigger detection, output image creation, and CGImage rendering. |
| CIImage/CVPixelBuffer → BeautyEngine | Caller-owned dimensions cross the public SDK facade before effects and SDK-created output allocation. |
| Public configuration → validation gates | Caller-selected ceilings must remain positive, overflow-safe, Codable-compatible, and consistently applied. |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- |
| T-260728-01 | Denial of Service | PhotosPicker encoded Data | mitigate | Check `Data.count` against `maximumInputByteCount` before CIImage construction, queueing, SDK processing, or display rendering. |
| T-260728-02 | Denial of Service | CIImage and CVPixelBuffer dimensions | mitigate | Use finite/positive and division-based pixel-count gates before detection, effect resolution, buffer copy, or rendering. |
| T-260728-03 | Tampering | Configuration and crafted dimensions | mitigate | Normalize non-positive limits to documented defaults, decode missing legacy keys safely, and test zero/non-finite/overflow-shaped inputs. |
| T-260728-04 | Information Disclosure | SDK/Demo rejection paths | mitigate | Return only `BeautyError.invalidInput` and existing friendly Demo copy; do not expose bytes, dimensions, paths, framework errors, or image contents. |
| T-260728-05 | Denial of Service | PhotosPicker transfer allocation | accept | Current `PhotosPickerItem.loadTransferable(Data.self)` materializes Data before its count is visible; document this residual and enforce immediately afterward without claiming pre-transfer control. |
| T-260728-06 | Tampering | Stale asynchronous photo work | mitigate | Preserve generation checks and prove oversized stale work cannot overwrite the latest accepted result. |
| T-260728-SC | Tampering | Package supply chain | accept | No dependency or package installation occurs in this plan. |
</threat_model>

<source_audit>
SOURCE | ID | Feature/Requirement | Plan | Status | Notes
--- | --- | --- | --- | --- | ---
GOAL | — | Resolve production image input bounds without product expansion | 01 | COVERED | Tasks 1-3 implement SDK, Demo, regression, and owner synchronization.
REQ | TD-012 | Public limits plus pre-decode/pre-render byte and pixel enforcement | 01 | COVERED | Tasks 1-2 close both SDK and Demo boundaries.
RESEARCH | — | No research artifact by quick-mode instruction | 01 | COVERED | Existing source and current root contracts are sufficient; no dependency is added.
CONTEXT | — | Preserve source compatibility and valid-input behavior | 01 | COVERED | Trailing defaults, legacy decoding, existing error, exact-limit passes, and no resizing.
CONTEXT | — | Exact automated verification and root/state synchronization | 01 | COVERED | Each task has an automated command; Task 3 updates all routed owners and state.
CONTEXT | — | Reject cheaply wherever current API permits | 01 | COVERED | Byte guard precedes decode; pixel guards precede processor/detection/render; PhotosPicker pre-transfer residual is explicit.
CONTEXT | — | No product features | 01 | COVERED | No parameter, effect, UI, resource, network, or milestone scope is added.
</source_audit>

<verification>
1. Run `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter 'BeautyCoreTests\.(BeautyConfigurationTests|BeautyEngineTests)'`.
2. Run `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' -only-testing:BeautyDemoTests/ImageEditorPipelineTests test`.
3. Run the full regressions: `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` and `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' test`.
4. Run `git diff --check` and the Task 3 current-owner scans; record actual counts/results in `PLANS.md`, `QUALITY_SCORE.md`, and `.planning/STATE.md` rather than copying planned claims.
</verification>

<success_criteria>
- Public limits are additive, defaulted, legacy-Codable, positive, and exact: 32 MiB encoded bytes and 50,000,000 decoded pixels.
- SDK entry points reject over-limit CIImage and CVPixelBuffer inputs as `BeautyError.invalidInput` before downstream work while exact-limit/current valid inputs behave unchanged.
- Demo rejects oversized PhotosPicker bytes before decode and oversized decoded extents before processing/render, preserves the last usable visual, ignores stale work, and recovers with a valid input.
- Focused and full SDK/Demo suites pass on the recorded toolchain/simulator, or any environment failure is recorded honestly without closing TD-012 or raising the Security score.
- DESIGN, SECURITY, RELIABILITY, PRODUCT_SENSE, QUALITY_SCORE, PLANS, and STATE agree; no historical archive, TD-013, product inventory, or readiness claim changes.
</success_criteria>

<output>
Create `.planning/quick/260728-gan-resolve-td-012-production-image-input-bo/260728-gan-SUMMARY.md` when done.
</output>
