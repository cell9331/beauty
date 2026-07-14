# Phase 23: Performance and Reliability Gates - Research

**Researched:** 2026-07-01 [VERIFIED: local date/context]
**Domain:** SwiftPM/XCTest performance and reliability evidence for an iOS beauty SDK [VERIFIED: codebase grep]
**Confidence:** HIGH for codebase/test surfaces; MEDIUM for exact memory API choice because Phase 23 leaves that to planner discretion [VERIFIED: codebase grep] [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]

<user_constraints>
## User Constraints (from CONTEXT.md)

Source for all copied constraints in this section: [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]

### Locked Decisions

### Timing Gate Path
- **D-01:** Use an SDK 720p synthetic `CVPixelBuffer` loop as the primary timing path for `PERF-01`. This should run through `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` and avoid depending on the current Demo simulator Metal Toolchain blocker.
- **D-02:** The timing matrix should cover representative current cases: default no-op, current skin/color/filter processing, and high-but-capped parameter combinations. Do not expand this into the complete Phase 24 renderer-output matrix.
- **D-03:** Treat the first Phase 23 timing run as record-and-compare evidence, not a hard optimization gate. Compare results to the `RELIABILITY.md` 5 to 12 ms first-version render budget and pass-level reference budgets; if a case exceeds budget, classify the environment, result, impact, risk, and next action instead of silently failing or optimizing out of scope.
- **D-04:** Store timing evidence in Phase 23 evidence/verification Markdown with exact command, environment, case table, mean/max or equivalent summary, and budget comparison. A small XCTest or helper output is allowed if it emits structured, copyable results.

### Long-Run Evidence Bar
- **D-05:** Use an automated fixture loop as the primary long-run evidence path for `PERF-04`. It should exercise currently runnable SDK or Demo pipeline code without requiring live camera, physical iPhone, or Demo simulator success.
- **D-06:** Judge memory growth with a trend-based baseline on the first pass, not a strict MB threshold. Record start, end, peak or available memory metric, loop duration/count, input resolution, case mix, and whether there is visible steady growth.
- **D-07:** Keep the target aligned to the `RELIABILITY.md` 10-minute long-run gate when cheap. A shorter automated baseline is allowed only with an explicit non-claim: it does not satisfy release-like 10-minute preview stability and must include the rerun protocol.
- **D-08:** Demo simulator and physical iPhone long-run evidence are secondary. If the Metal Toolchain or device is unavailable, record blocker-honest commands/protocols and do not block SDK fixture-loop evidence.

### Quality, Reset, and Degradation Scope
- **D-09:** Verify the current `BeautyRenderQuality` contract and add only minimal meaningful internal behavior/tests if planning finds the current configuration-only state leaves `PERF-03` untestable. Do not add public API, public parameters, Demo UI controls, product routes, or a broad processing strategy rewrite.
- **D-10:** Reset evidence should cover both SDK engine and Demo pipeline layers: `BeautyEngine.reset()`, `CameraBeautyPipeline.reset()`, and still-image stale-work/selection-failure recovery. Do not claim GPU transient texture/cache reset evidence for caches that do not currently exist.
- **D-11:** Degradation and safety-cap evidence should be regression evidence over existing warning/metric/status paths. Phase 23 should prove timing, quality-mode, and reset work does not bypass caps, no-face behavior, stale/reused geometry degradation, missing-landmark degradation, or processing-paused recovery.
- **D-12:** If implementation changes are needed to make quality-mode evidence meaningful, keep them internal and test-focused. Allowed scope includes internal configuration use, test helpers, and existing warning/metric evidence. Forbidden scope includes new public surface, new Demo UI, new product routes, and broad renderer/effect strategy work.

### Metrics and Redaction Evidence
- **D-13:** Performance evidence must be structured and redacted. Allowed fields include case name, duration summary, resolution bucket, quality mode, dropped-frame count, and warning/metric codes. Forbidden fields include image bytes, local/private paths, face geometry, raw JSON, raw framework errors, user identifiers, tokens, and raw diagnostics.
- **D-14:** Keep logs optional and off by default. `BeautyConfiguration.enablePerformanceLog` should remain `false` by default, release default `logLevel` remains `.error`, and Phase 23 evidence should use structured helper/test output rather than enabling per-frame logging or creating new public logging behavior.
- **D-15:** Backpressure evidence should keep the existing `CameraBeautyPipelineTests` in-flight/pending/drop coverage and add or record a narrow stress case only if needed. `PERF-02` does not require live camera, simulator UI automation, or physical device proof.
- **D-16:** Phase 23 conclusions must avoid release-grade overclaims. Unless actual evidence exists, do not claim release-grade 30 fps, production naturalness, physical-device stability, all-device parity, screenshot visual pass, or market-ready performance. Acceptable conclusions are current-environment baseline, risk, blocker, and rerun protocol.

### the agent's Discretion
The planner may choose exact helper/test shape, sample count, warm-up count, case names, table columns, memory-measurement API, and artifact filenames. Keep the phase conservative: evidence first, narrow tests/helpers, explicit blockers, and no public/API/UI expansion.

### Deferred Ideas (OUT OF SCOPE)
- Full renderer output regression, no-op tolerance for saved outputs, and all renderer-case matrix hardening belong to Phase 24.
- Privacy manifest assessment, resource trust closeout, and final security/distribution scans belong to Phase 25.
- Physical iPhone long-run stability and camera/Vision parity remain blocked until hardware evidence exists.
- Full public logging subsystem, MetricKit integration, signpost infrastructure, and per-frame logging behavior are deferred unless separately promoted.
- Release-grade naturalness, production render quality, and all-device 30 fps claims remain outside Phase 23 unless actual release-like evidence exists.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PERF-01 | Maintainers can run a repeatable timing check for current 720p or fixture-based processing paths and compare the result to `RELIABILITY.md` budgets. [CITED: .planning/REQUIREMENTS.md] | Use an SDK SwiftPM XCTest/helper loop around `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)`; record mean/max and budget comparison instead of first-pass hard failure. [VERIFIED: codebase grep] |
| PERF-02 | Realtime backpressure, dropped-frame accounting, and latest-frame-wins behavior remain covered by tests or an equivalent reproducible harness. [CITED: .planning/REQUIREMENTS.md] | Existing `CameraBeautyPipelineTests` cover bounded in-flight work, dropped stale pending frames, latest parameters, and pause recovery; planner should preserve or extend these tests. [VERIFIED: codebase grep] |
| PERF-03 | Quality mode, reset, and degradation behavior are verified against `RELIABILITY.md`. [CITED: .planning/REQUIREMENTS.md] | Existing configuration, engine reset, Demo pipeline reset, resolver cap/no-face/stale/reused/missing-landmark tests are the baseline; quality-mode evidence may need minimal internal/test-only behavior. [VERIFIED: codebase grep] |
| PERF-04 | Long-run preview or processing stability has automated evidence, manual evidence, or an explicit hardware/tooling blocker. [CITED: .planning/REQUIREMENTS.md] | Prefer automated SDK fixture loop with memory trend summary; Demo simulator and physical-device loops are secondary or blocker records. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |
| PERF-05 | Logs, warnings, metrics, and performance evidence remain optional, redacted, and free of sensitive payloads. [CITED: .planning/REQUIREMENTS.md] | Reuse `BeautyConfigurationTests`, engine/effect redaction assertions, and `InputPipelinePrivacyTests`; scan new Phase 23 artifacts for forbidden tokens. [VERIFIED: codebase grep] |
</phase_requirements>

## Summary

Phase 23 should be planned as an evidence-gate phase, not an optimization phase. The primary runnable path is the SwiftPM SDK package: local `swift test --package-path BeautySDK` passed with 141 XCTest cases on 2026-07-01, while the explicit Demo iPhone 17 simulator build still exits 65 because `Warp.metal` cannot compile without the local Metal Toolchain. [VERIFIED: local command]

The most important planning decision is to introduce narrow timing and long-run evidence around current SDK behavior, then compare honestly against `RELIABILITY.md` budgets. `RELIABILITY.md` defines a 5 to 12 ms first-version processed-frame budget, pass-level reference budgets, and a 10-minute long-run preview target; the context locks first-run results as record-and-compare evidence, not a fail-fast optimization gate. [CITED: RELIABILITY.md] [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]

**Primary recommendation:** Add a small SDK-side performance evidence harness or XCTest target/file that creates synthetic 1280x720 BGRA `CVPixelBuffer`s, runs representative `BeautyEngine.processResult` cases with warmups and samples, emits redacted structured Markdown/console output, and pairs it with focused regression tests for backpressure, reset, quality mode, degradation, and artifact redaction. [VERIFIED: codebase grep]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| SDK 720p timing loop | API / Backend-equivalent SDK facade | Test harness | `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` is the current public facade processing path and avoids Demo simulator blockage. [VERIFIED: codebase grep] |
| Backpressure/latest-frame-wins | Frontend App pipeline | XCTest | `CameraBeautyPipeline` owns in-flight count, pending latest frame, dropped-frame count, and pause state; tests already exercise this behavior. [VERIFIED: codebase grep] |
| Quality mode contract | API / Backend-equivalent SDK core | Effects resolver | `BeautyConfiguration.renderQuality` and `BeautyRenderQuality` live in SDK models; meaningful behavior must remain internal/test-focused unless current configuration-only state is enough. [VERIFIED: codebase grep] |
| Reset/recovery | SDK facade and Demo pipeline | Effects/detection tests | `BeautyEngine.reset()` and `CameraBeautyPipeline.reset()` own separate state reset surfaces; still-image stale-work recovery lives in `ImageEditorPipeline`. [VERIFIED: codebase grep] |
| Long-run memory evidence | Test harness | SDK facade | Phase 23 locks an automated fixture loop as primary and permits shorter baseline only with explicit non-claim and rerun protocol. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |
| Redacted performance artifacts | Test/evidence layer | Security/reliability docs | `SECURITY.md` and `RELIABILITY.md` prohibit image bytes, face geometry, paths, tokens, raw errors, and raw JSON in metrics/logs/artifacts. [CITED: SECURITY.md] [CITED: RELIABILITY.md] |

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md`, `PLANS.md`, task-specific root docs, relevant code/tests, and history before changes. [CITED: AGENTS.md]
- Repository text is the record system; do not assume facts absent from repo text. [CITED: AGENTS.md]
- Keep changes scoped and do not overwrite unrelated local changes. [CITED: AGENTS.md]
- Reliability/performance work must update `RELIABILITY.md` if it changes performance, logging, error handling, or recovery contracts. [CITED: AGENTS.md]
- Security/risk boundary changes must update `SECURITY.md`; public behavior changes must update `PRODUCT_SENSE.md`; architecture boundary changes must update `ARCHITECTURE.md`. [CITED: AGENTS.md]
- Build the Demo only with an explicit compatible iOS Simulator destination; if local Xcode configuration fails, record the reproducible failure rather than claiming success. [CITED: AGENTS.md]
- Use `rg --files` for file discovery. [CITED: AGENTS.md]

## Standard Stack

### Core
| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| Apple Swift / SwiftPM | Apple Swift 6.3.3, swift-driver 1.148.6 | Build and test `BeautySDK`; run new SwiftPM timing/long-run tests or helpers. | Existing package and test suite use SwiftPM and passed locally. [VERIFIED: local command] |
| Xcode / XCTest | Xcode 26.6 build 17F113 | Unit, async, and performance-style tests. | Existing SDK and Demo tests are XCTest; Apple documents XCTest performance measurement APIs. [VERIFIED: local command] [CITED: https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests] |
| CoreVideo `CVPixelBuffer` | Platform SDK via Xcode 26.6 | Synthetic 720p BGRA input frames. | Current facade validates BGRA pixel buffers and existing tests already create `CVPixelBuffer` fixtures. [VERIFIED: codebase grep] |
| `BeautySDK` Swift package | Local package | Primary implementation and evidence target. | Demo simulator build is blocked; SwiftPM SDK tests are runnable. [VERIFIED: local command] |

### Supporting
| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| `xcodebuild` | Xcode 26.6 build 17F113 | Demo build/test blocker check and rerun protocol. | Use only for secondary Demo evidence or blocker recording until Metal Toolchain is installed. [VERIFIED: local command] |
| `xcrun simctl` | Xcode-selected toolchain | Simulator inventory and future rerun protocol. | Use for environment framing; current Phase 23 primary path must not depend on simulator success. [VERIFIED: local command] |
| `rg` | Available in repo workflow | Boundary and redaction scans. | Use to scan new evidence artifacts and source surfaces for forbidden sensitive tokens. [CITED: AGENTS.md] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SDK SwiftPM fixture loop | Demo simulator camera loop | More release-like but currently blocked by missing Metal Toolchain; keep as secondary/blocker evidence. [VERIFIED: local command] |
| Custom helper executable | XCTest performance-style test | Helper can emit copyable Markdown/JSON-like summaries without XCTest baseline behavior; XCTest integrates with existing test commands. [CITED: https://developer.apple.com/documentation/xctest/xctestcase/measure%28metrics%3Aoptions%3Ablock%3A%29] |
| Strict first-run budget failure | Record-and-compare evidence | Strict failure would overclaim device-independent performance; context requires classification and next action on over-budget cases. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |

**Installation:**
```bash
# No external package installation is recommended for Phase 23. [VERIFIED: codebase grep]
```

**Version verification:**
```bash
swift --version
xcodebuild -version
swift test --package-path BeautySDK
```
[VERIFIED: local command]

## Package Legitimacy Audit

No external packages are recommended or installed for this phase, so the package legitimacy gate is not applicable. [VERIFIED: codebase grep]

## Architecture Patterns

### System Architecture Diagram

```text
Synthetic 1280x720 BGRA CVPixelBuffer
    ↓
Timing / long-run harness selects case matrix
    ├─ default no-op parameters
    ├─ current skin/color/filter parameters
    └─ high-but-capped parameter combination
    ↓
BeautyEngine.processResult(pixelBuffer:metadata:parameters:)
    ↓
BeautySDKResources.validate(parameters:)
    ↓
BeautyEffectResolver.resolve(parameters:)
    ↓
BeautyColorEffectPipeline.apply(...)
    ↓
BeautyResult(output, warnings, metrics, detectionSummary)
    ↓
Structured redacted evidence table
    ├─ duration mean/max and budget comparison
    ├─ resolution bucket and quality mode
    ├─ warning/metric codes only
    └─ blocker/non-claim/rerun protocol when needed
```
[VERIFIED: codebase grep] [CITED: RELIABILITY.md]

### Recommended Project Structure
```text
BeautySDK/
├── Tests/
│   ├── BeautyCoreTests/
│   │   ├── BeautyEngineTests.swift
│   │   └── BeautyPerformanceEvidenceTests.swift   # recommended narrow new file
│   └── BeautyEffectsTests/
│       ├── CombinedEffectSafetyTests.swift
│       └── MissingLandmarkDegradationTests.swift
.planning/phases/23-performance-and-reliability-gates/
├── 23-RESEARCH.md
└── 23-PERFORMANCE-EVIDENCE.md                     # recommended evidence artifact
```
[VERIFIED: codebase grep] [ASSUMED]

### Pattern 1: Timing Evidence Is Structured Record-and-Compare
**What:** Create a deterministic 720p BGRA fixture, warm up, sample each case, summarize mean/max, and compare to `RELIABILITY.md` budgets without claiming release-grade performance. [CITED: RELIABILITY.md] [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
**When to use:** PERF-01 and PERF-04 SDK fixture baselines. [CITED: .planning/REQUIREMENTS.md]
**Example:**
```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift fixture pattern
let input = try PixelBufferFixtures.makePixelBuffer(
    width: 1280,
    height: 720,
    pixelFormat: kCVPixelFormatType_32BGRA
)
let result = try engine.processResult(
    pixelBuffer: input,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: parameters
)
```
[VERIFIED: codebase grep]

### Pattern 2: Backpressure Evidence Uses Injected Processor Control
**What:** Continue using injected `CameraFrameProcessor`, `DispatchSemaphore`, and `waitUntilIdle()` to prove one active frame, one pending latest frame, dropped stale frames, and latest parameter snapshot. [VERIFIED: codebase grep]
**When to use:** PERF-02 regression coverage and any narrow stress case. [CITED: .planning/REQUIREMENTS.md]
**Example:**
```swift
// Source: BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift
let pipeline = CameraBeautyPipeline(maxInFlight: 1, processor: processor)
pipeline.enqueue(frame: firstFrame, parameters: firstParameters)
pipeline.enqueue(frame: staleFrame, parameters: staleParameters)
pipeline.enqueue(frame: latestFrame, parameters: latestParameters)
await pipeline.waitUntilIdle()
```
[VERIFIED: codebase grep]

### Pattern 3: Redaction Evidence Uses Positive Allowed Fields and Negative Token Scans
**What:** Evidence should include only case name, duration summary, resolution bucket, quality mode, dropped-frame count, warning codes, metric keys, and blocker notes. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
**When to use:** PERF-05 and every new Markdown/helper output. [CITED: .planning/REQUIREMENTS.md]
**Example:**
```text
case=skin_color_filter resolution=1280x720 quality=balanced
samples=50 warmups=5 meanMs=... maxMs=...
warnings=[beauty_strength_capped] metrics=[beauty.effects.activeCount]
```
[CITED: RELIABILITY.md] [CITED: SECURITY.md]

### Anti-Patterns to Avoid
- **Optimizing inside the evidence phase:** Phase 23 should classify over-budget results and route next action instead of broad performance rewrites. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
- **Using Demo simulator success as a prerequisite:** Current Demo build is blocked by missing Metal Toolchain; SDK fixture evidence must proceed independently. [VERIFIED: local command]
- **Adding public API/UI to make tests easier:** Context forbids new public parameters, public API, Demo UI controls, product routes, and broad renderer/effect strategy work. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
- **Raw timing logs or raw diagnostics:** Metrics/logs/artifacts must not include image bytes, local paths, face geometry, raw errors, raw JSON, user identifiers, or tokens. [CITED: SECURITY.md] [CITED: RELIABILITY.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Unit/performance test runner | Custom test framework | XCTest through SwiftPM | Existing tests use XCTest and Apple documents performance measurement support. [VERIFIED: codebase grep] [CITED: https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests] |
| 720p pixel fixtures | Ad hoc image files or camera dependency | Synthetic BGRA `CVPixelBuffer` helpers | Existing test fixtures already use `CVPixelBufferCreate`; context requires avoiding Demo simulator dependency. [VERIFIED: codebase grep] |
| Backpressure scheduler | New queueing system | Existing `CameraBeautyPipeline` injected processor tests | Current pipeline owns in-flight/pending/drop behavior and has focused tests. [VERIFIED: codebase grep] |
| Redaction scanner | New logging subsystem | Existing `InputPipelinePrivacyTests` patterns plus scoped `rg` scans | Context defers full logging subsystem and requires optional/off-by-default logs. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |
| Memory proof | Release-grade device profiler claim | Trend-based SDK fixture loop plus blocker protocol | Context requires trend baseline first and explicit non-claim for shorter runs. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |

**Key insight:** The planner should use current code ownership boundaries as the reliability boundary: SDK timing/long-run evidence belongs around `BeautyEngine`, realtime freshness belongs in `CameraBeautyPipeline`, and redaction belongs in result/warning/metric artifacts rather than a new logging product. [VERIFIED: codebase grep]

## Common Pitfalls

### Pitfall 1: XCTest Baseline Overclaim
**What goes wrong:** A first performance test run is treated as a release-grade pass/fail gate. [CITED: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html]
**Why it happens:** XCTest performance baselines are device/configuration-specific, and Phase 23 is establishing first evidence. [CITED: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html] [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
**How to avoid:** Emit explicit current-environment evidence with mean/max, budget comparison, and next action classification. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
**Warning signs:** Wording like "stable 30 fps", "release-grade", or "all devices" without physical-device evidence. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]

### Pitfall 2: Demo Metal Toolchain Blocks All Progress
**What goes wrong:** Planning requires Demo simulator build/test before SDK timing evidence. [VERIFIED: local command]
**Why it happens:** Demo Phase 22 evidence is blocked at `CompileMetalFile` for `Warp.metal` with the missing Metal Toolchain. [VERIFIED: local command]
**How to avoid:** Keep SDK SwiftPM fixture loop primary and record Demo commands as secondary blocker/rerun protocol. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
**Warning signs:** Plan tasks that start with `xcodebuild ... test` and do not provide a SwiftPM SDK fallback. [VERIFIED: local command]

### Pitfall 3: Quality Mode Is Only Configuration
**What goes wrong:** Planner claims `performance`, `balanced`, and `quality` change runtime behavior when current source only exposes configuration fields and enum cases. [VERIFIED: codebase grep]
**Why it happens:** `BeautyConfiguration` stores `renderQuality`, but `BeautyEngine.processResult` currently does not branch on it. [VERIFIED: codebase grep]
**How to avoid:** Either limit evidence to contract/default/Codable behavior or plan minimal internal/test-focused behavior that emits safe evidence without public/API/UI expansion. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
**Warning signs:** Tests that assert quality-mode visual strategy changes without implementation or source support. [VERIFIED: codebase grep]

### Pitfall 4: Redaction Regression Through Artifacts
**What goes wrong:** Performance Markdown or helper output includes local paths, raw errors, raw JSON, image bytes, or geometry details. [CITED: SECURITY.md]
**Why it happens:** Benchmark/debug output often dumps raw values for convenience. [ASSUMED]
**How to avoid:** Define an allowlist schema and scan new artifacts for forbidden terms. [CITED: SECURITY.md] [CITED: RELIABILITY.md]
**Warning signs:** Artifact fields named `path`, `raw`, `json`, `bytes`, `landmark`, `bounding`, `NSError`, or `VNFaceObservation`. [CITED: SECURITY.md]

## Code Examples

### Synthetic 720p Pixel Buffer Timing Loop
```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift fixture style
let engine = try BeautyEngine(configuration: .default)
let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
let input = try PixelBufferFixtures.makePixelBuffer(
    width: 1280,
    height: 720,
    pixelFormat: kCVPixelFormatType_32BGRA
)
let start = ContinuousClock.now
_ = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: parameters)
let elapsed = start.duration(to: .now)
```
[VERIFIED: codebase grep] [ASSUMED]

### Backpressure Regression Shape
```swift
// Source: BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift
XCTAssertEqual(pipeline.inFlightCount, 1)
XCTAssertEqual(pipeline.droppedFrameCount, 1)
XCTAssertEqual(pipeline.lastDropReason, .backpressure)
XCTAssertEqual(processedTimestamps.values, [1, 3])
```
[VERIFIED: codebase grep]

### Artifact Redaction Scan
```bash
rg -n "/private/var|NSError|VNFaceObservation|bounding|landmark|rawPresetJson|image bytes|userToken|token|raw JSON" \
  .planning/phases/23-performance-and-reliability-gates
```
[CITED: SECURITY.md] [CITED: RELIABILITY.md]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Rely on manual release-risk notes for performance budgets | Add repeatable SDK timing and long-run evidence | Phase 23 planning, 2026-07-01 | Makes PERF-01/PERF-04 verifiable without claiming device parity. [CITED: .planning/REQUIREMENTS.md] |
| Treat Demo simulator as the main evidence path | Use SDK SwiftPM primary path and Demo blocker protocol | Phase 22/23, 2026-07-01 | Avoids blocking all performance evidence on missing Metal Toolchain. [VERIFIED: local command] |
| Broad logging/observability buildout | Structured helper/test output with optional/off logs | Phase 23 context, 2026-07-01 | Satisfies redacted evidence without public logging subsystem expansion. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |

**Deprecated/outdated:**
- `swift test --package-path BeautySDK --list-tests`: still works locally but prints a deprecation warning; prefer `swift test --package-path BeautySDK list` for inventory. [VERIFIED: local command]
- Any claim that Demo simulator build/test currently passes: local `xcodebuild` still fails at `Warp.metal` with missing Metal Toolchain. [VERIFIED: local command]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `BeautyPerformanceEvidenceTests.swift` is the best filename for a new timing/long-run XCTest file. | Recommended Project Structure | Low; planner can choose another narrow file name. |
| A2 | `ContinuousClock` is an acceptable timing primitive if the planner chooses a helper instead of XCTest `measure`. | Code Examples | Low; planner can use XCTest metrics or `DispatchTime` instead. |
| A3 | Benchmark/debug output often dumps raw values for convenience. | Common Pitfalls | Low; this is a general engineering caution and does not affect locked scope. |

## Open Questions

1. **Should timing be an XCTest or a helper executable?**
   - What we know: XCTest is established and Apple supports performance measurement; context allows a small XCTest or helper output. [VERIFIED: codebase grep] [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
   - What's unclear: The planner must choose whether copyable Markdown output is more important than XCTest integration. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
   - Recommendation: Prefer XCTest for regression coverage plus a deterministic printed/Markdown table if output remains redacted. [ASSUMED]

2. **Which memory measurement API should Phase 23 use?**
   - What we know: Context leaves memory-measurement API to planner discretion and requires trend-based start/end/peak evidence. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
   - What's unclear: Exact API reliability across macOS/iOS simulator and SwiftPM SDK tests. [ASSUMED]
   - Recommendation: Use a conservative API available in local SwiftPM tests or record loop count/duration and blocker if reliable memory sampling is unavailable. [ASSUMED]

3. **Is quality mode behavior meaningful enough without implementation changes?**
   - What we know: `BeautyRenderQuality` has three cases and `BeautyConfiguration` stores `renderQuality`; current `BeautyEngine.processResult` does not branch on it. [VERIFIED: codebase grep]
   - What's unclear: Whether PERF-03 accepts configuration-contract evidence only. [CITED: .planning/REQUIREMENTS.md]
   - Recommendation: Plan a small Wave 0 investigation; if untestable, add minimal internal/test-focused behavior only. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift / SwiftPM | SDK tests and timing harness | Yes | Apple Swift 6.3.3, swift-driver 1.148.6 | None needed. [VERIFIED: local command] |
| Xcode | XCTest, Demo build, simulator tools | Yes | Xcode 26.6 build 17F113 | SwiftPM SDK path remains primary. [VERIFIED: local command] |
| iOS Simulator runtime | Secondary Demo rerun protocol | Yes | iOS 26.5 devices listed, including iPhone 17 | SDK fixture loop if Demo remains blocked. [VERIFIED: local command] |
| Metal Toolchain component | Demo simulator build/test | No | Build fails with missing Metal Toolchain | Use SDK SwiftPM evidence; rerun after `xcodebuild -downloadComponent MetalToolchain`. [VERIFIED: local command] |
| Physical iPhone | Release-like long-run/camera parity | No evidence in repo/session | Unknown | Record blocker protocol; do not claim physical-device stability. [CITED: .planning/STATE.md] |
| `rg` | Source/artifact scans | Yes | Version not probed | Use existing repo scan patterns. [VERIFIED: codebase grep] |

**Missing dependencies with no fallback:**
- Physical iPhone evidence for release-like camera/Vision parity and physical-device long-run stability has no local substitute; record as blocked unless hardware evidence exists. [CITED: .planning/STATE.md]

**Missing dependencies with fallback:**
- Metal Toolchain blocks Demo simulator build/test, but SDK SwiftPM timing and long-run fixture loops are available. [VERIFIED: local command]

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest through SwiftPM and Xcode. [VERIFIED: codebase grep] |
| Config file | `BeautySDK/Package.swift`; Xcode project `BeautyDemo/BeautyDemo.xcodeproj`. [VERIFIED: codebase grep] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests/testSDK02DefaultConfigurationIsSafeForRelease` [VERIFIED: local command] |
| Full suite command | `swift test --package-path BeautySDK` [VERIFIED: local command] |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| PERF-01 | 720p timing and budget comparison | performance/unit evidence | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | No, Wave 0/new test. [VERIFIED: codebase grep] |
| PERF-02 | Backpressure/latest-frame-wins/drop accounting | unit | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | Yes, but currently blocked by Metal Toolchain. [VERIFIED: codebase grep] [VERIFIED: local command] |
| PERF-03 | Quality/reset/degradation/caps | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests` and `swift test --package-path BeautySDK --filter BeautyEffectsTests` | Partial; quality behavior gap likely needs Wave 0. [VERIFIED: codebase grep] |
| PERF-04 | Long-run memory/processing stability | performance/unit evidence | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | No, Wave 0/new test. [VERIFIED: codebase grep] |
| PERF-05 | Redacted optional logs/metrics/artifacts | unit/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests/testSDK02DefaultConfigurationIsSafeForRelease` plus scoped `rg` scan | Partial; new artifact scan needed. [VERIFIED: codebase grep] |

### Sampling Rate
- **Per task commit:** Run the focused test(s) touched plus the artifact redaction scan for any new Phase 23 evidence file. [ASSUMED]
- **Per wave merge:** Run `swift test --package-path BeautySDK`; run Demo focused `xcodebuild` tests only if Metal Toolchain is installed, otherwise record blocker. [VERIFIED: local command]
- **Phase gate:** Full SDK suite green, performance evidence Markdown present, Demo blocker/pass status explicit, and no forbidden tokens in Phase 23 artifacts. [CITED: .planning/REQUIREMENTS.md]

### Wave 0 Gaps
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` or equivalent helper: covers PERF-01 and PERF-04. [ASSUMED]
- [ ] Phase 23 evidence artifact such as `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md`: records exact command, environment, cases, mean/max, memory trend, and budget comparison. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]
- [ ] Quality-mode decision check: determine whether configuration-only evidence is enough or minimal internal/test-focused behavior is needed. [VERIFIED: codebase grep] [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | No | No auth surface in Phase 23. [VERIFIED: codebase grep] |
| V3 Session Management | No | No session surface in Phase 23. [VERIFIED: codebase grep] |
| V4 Access Control | No | Local SDK/Demo evidence only; no role/user boundary. [VERIFIED: codebase grep] |
| V5 Input Validation | Yes | Preserve `BeautyEngine` pixel-format/dimension validation and parameter/resource validation before timing loops. [VERIFIED: codebase grep] |
| V6 Cryptography | No | No crypto or secret handling in Phase 23. [VERIFIED: codebase grep] |
| V8 Data Protection | Yes | Do not persist raw frames, photos, face geometry, paths, raw JSON, or raw diagnostics in artifacts. [CITED: SECURITY.md] |
| V9 Communications | No | Current posture is local-first/no-network; Phase 23 must not add upload/telemetry. [CITED: SECURITY.md] |
| V10 Malicious Code | Yes | Do not add unverified external packages or script-executing benchmark dependencies. [VERIFIED: codebase grep] |
| V14 Configuration | Yes | Keep `enablePerformanceLog` false by default and `logLevel` `.error` by default. [VERIFIED: codebase grep] |

### Known Threat Patterns for Swift/XCTest Performance Evidence

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Sensitive image/face data in performance output | Information Disclosure | Allowlist artifact fields; scan forbidden tokens. [CITED: SECURITY.md] |
| Raw local paths or framework errors copied into blocker evidence | Information Disclosure | Summarize blocker with command, failure class, impact, next step, and rerun protocol; avoid raw private paths beyond repo-relative files. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] |
| Optimization bypasses safety caps/degradation | Tampering | Run resolver/cap/degradation tests with timing changes. [VERIFIED: codebase grep] |
| Tooling blocker misreported as pass | Repudiation | Record exact command, exit status, environment, failure summary, and non-claim. [CITED: AGENTS.md] |

## Sources

### Primary (HIGH confidence)
- `.planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md` - locked Phase 23 decisions, out-of-scope items, current code surfaces. [CITED]
- `.planning/REQUIREMENTS.md` - PERF-01 through PERF-05 definitions. [CITED]
- `.planning/STATE.md`, `.planning/ROADMAP.md`, `PLANS.md`, `QUALITY_SCORE.md` - v1.4 state, blocker routing, evidence expectations. [CITED]
- `RELIABILITY.md` - budgets, backpressure, quality mode, reset, long-run, logging/metrics policy. [CITED]
- `SECURITY.md` - redaction and sensitive data boundaries. [CITED]
- `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `AGENTS.md` - SDK/Demo boundaries, public model constraints, workflow rules. [CITED]
- Codebase grep/read of `BeautyEngine`, `BeautyConfiguration`, `BeautyRenderQuality`, `BeautyResult`, `BeautyEffectResolver`, `CameraBeautyPipeline`, `ImageEditorPipeline`, and related tests. [VERIFIED: codebase grep]
- Local commands: `swift --version`, `xcodebuild -version`, `xcodebuild -list`, `xcrun simctl list devices available`, `swift test --package-path BeautySDK`, `swift test --package-path BeautySDK list`, Demo `xcodebuild ... build`. [VERIFIED: local command]

### Secondary (MEDIUM confidence)
- Apple Developer XCTest performance docs: `https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests` and `https://developer.apple.com/documentation/xctest/xctestcase/measure%28metrics%3Aoptions%3Ablock%3A%29`. [CITED]
- SwiftPM `swift test` docs: `https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/swifttest/`. [CITED]
- Apple archived XCTest guide for baseline behavior: `https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html`. [CITED]

### Tertiary (LOW confidence)
- General caution that benchmark/debug output often dumps raw values if not designed around an allowlist. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - existing SwiftPM/XCTest stack and local versions were verified. [VERIFIED: local command]
- Architecture: HIGH - files and ownership boundaries were verified in root docs and source. [VERIFIED: codebase grep]
- Pitfalls: HIGH for Demo blocker and quality-mode configuration-only gap; MEDIUM for exact memory API choice. [VERIFIED: local command] [VERIFIED: codebase grep]

**Research date:** 2026-07-01 [VERIFIED: local date/context]
**Valid until:** 2026-07-08 for local toolchain/blocker status; 2026-07-31 for stable repo architecture assumptions. [ASSUMED]
