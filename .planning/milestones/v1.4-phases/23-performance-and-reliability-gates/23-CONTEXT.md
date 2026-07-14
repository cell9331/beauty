# Phase 23: Performance and Reliability Gates - Context

**Gathered:** 2026-07-01
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 23 turns `RELIABILITY.md` budgets and recovery rules into repeatable performance and reliability evidence. It covers `PERF-01`, `PERF-02`, `PERF-03`, `PERF-04`, and `PERF-05`.

This is a reliability and performance evidence phase. It should create or reuse narrow commands, tests, or helper output that measure current 720p processing timing, backpressure/latest-frame-wins behavior, long-run memory/preview stability, quality-mode/reset/degradation behavior, and redacted performance artifacts.

Phase 23 must not add product-feature breadth, new public `BeautyParameters`, new Demo UI controls, new product routes, broad renderer-output regression, production naturalness review, physical-device parity claims, or a full logging subsystem. Hardware and local toolchain blockers are acceptable only when recorded with exact commands, environment, impact, and rerun protocol.

</domain>

<decisions>
## Implementation Decisions

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger, current v1.4 next steps, and technical-debt routing.
- `.planning/PROJECT.md` - Defines v1.4 as stability, QA, performance, security, and debt cleanup without product-feature expansion.
- `.planning/REQUIREMENTS.md` - Defines `PERF-01`, `PERF-02`, `PERF-03`, `PERF-04`, and `PERF-05`.
- `.planning/ROADMAP.md` - Defines Phase 23 goal, success criteria, dependency, and planned status.
- `.planning/STATE.md` - Records current focus as Phase 23 and carries Phase 21/22 blocker context.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md` - Locks evidence-first baseline, stale codebase-map handling, and blocker honesty rules.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` - Records current SDK pass evidence, Demo Metal Toolchain blocker, and routing of TD-008/TD-010 into Phase 23.
- `.planning/phases/22-automated-demo-qa-and-screenshot-evidence/22-CONTEXT.md` - Locks current Demo blocker-honesty policy and non-claim rules.
- `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` - Records current Demo build/test/screenshot blocker and exact rerun protocol.

### Root Contracts
- `RELIABILITY.md` - Owns timing budgets, 10-minute long-run gate, quality-mode matrix, reset/recovery rules, backpressure/latest-frame-wins behavior, and metrics/log redaction requirements.
- `QUALITY_SCORE.md` - Current quality snapshot; identifies Phase 23 timing, long-run, quality-mode, reset/degradation, and redacted metric checks as top repair queue.
- `SECURITY.md` - Owns privacy, no raw-path/raw-framework-error/raw-JSON leakage, and redaction boundaries that Phase 23 evidence must preserve.
- `DESIGN.md` - Owns public value models and the no-public-parameter-expansion boundary.
- `FRONTEND.md` - Owns Demo pipeline/UI state behavior and the no-new-UI hardening boundary.
- `ARCHITECTURE.md` - Owns SDK/Demo boundary, facade-only Demo rule, and dependency direction.

### Current Code Surfaces
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Current public facade processing and reset path for pixel-buffer/image timing and reset evidence.
- `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` - Current render quality, performance log, debug mode, log level, and processing-size configuration model.
- `BeautySDK/Sources/BeautyCore/Models/BeautyRenderQuality.swift` - Current `.performance`, `.balanced`, `.quality` model.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` - Current warnings/metrics/detection summary result surface.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Current warning/metric/cap/degradation source for regression evidence.
- `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` - Current in-flight, pending latest-frame, dropped-frame, paused recovery, and reset behavior.
- `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` - Current still-image stale-work, loading, failure, and recovery behavior.
- `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` - Existing backpressure, latest-frame-wins, pause, and detection-status tests.
- `BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift` - Existing BGRA and `alwaysDiscardsLateVideoFrames` evidence.
- `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` - Existing stale photo work, decode failure, and status persistence evidence.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Existing no-network/no-upload/no-raw-copy/no-realtime-UIImage/redaction scan patterns.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - Existing facade no-op, visible output, typed error, warning/metric, redaction, and reset evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` - Existing configuration default, clamp, Codable, and Sendable evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Existing warning/metric redaction and domain activation evidence.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` - Existing caps, weakening, and redacted metric evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Existing missing-landmark, stale, reused, and redacted degradation evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` can drive SDK-level synthetic 720p timing without requiring Demo simulator success.
- `BeautyEngine.processResult(image:metadata:parameters:)` remains available for still-image comparison, but is not the primary realtime timing path.
- `BeautyConfiguration` already exposes `renderQuality`, `preferredProcessingSize`, `enablePerformanceLog`, `enableDebugMode`, and `logLevel`, but most quality/performance fields are currently configuration evidence rather than full behavior.
- `BeautyResult.metrics` and `BeautyValidationWarning` already carry redacted resolver evidence for caps, active domains, skipped domains, and geometry points.
- `CameraBeautyPipeline` already enforces `maxInFlight`, keeps one pending latest frame, increments `droppedFrameCount`, records `.backpressure`, preserves last usable preview on failure, and exposes `reset()`.
- `ImageEditorPipeline` already ignores stale image work, preserves previous visual on failure, and has deterministic idle waiting for tests.

### Established Patterns
- Evidence claims must use exact commands, scoped outputs, and pass/fail/blocker status.
- SDK/Demo validation stays facade-only; Demo must not import internal SDK targets.
- Hardware/tooling blockers are acceptable only with command, environment, concise failure summary, impact, next step, and rerun protocol.
- Current source, root docs, and `.planning` ledgers override stale `.planning/codebase/*` maps.
- Phase 23 should extend focused XCTest/helper evidence rather than introduce broad UI automation, public API expansion, or full observability infrastructure.

### Integration Points
- Phase 23 evidence should live under the Phase 23 directory, with any broader v1.4 evidence references kept explicit.
- Timing/long-run helpers, if added, should be narrow, deterministic, and runnable from the local toolchain that currently passes `swift test --package-path BeautySDK`.
- If Demo simulator build/test remains blocked by the Metal Toolchain, Phase 23 should preserve the blocker protocol from Phase 21/22 and continue with SDK fixture evidence.
- Redaction checks should reuse `InputPipelinePrivacyTests` and existing effect/engine redaction assertions where possible, adding only scoped scans for new Phase 23 output.

</code_context>

<specifics>
## Specific Ideas

- Favor reproducible baselines and budget comparison over immediate optimization.
- The first timing and memory evidence can establish a baseline without claiming release-grade performance.
- Use current runnable SDK paths to avoid letting the Demo Metal Toolchain blocker prevent all Phase 23 progress.
- Keep performance artifacts boring and structured so future agents can compare them without parsing raw logs.

</specifics>

<deferred>
## Deferred Ideas

- Full renderer output regression, no-op tolerance for saved outputs, and all renderer-case matrix hardening belong to Phase 24.
- Privacy manifest assessment, resource trust closeout, and final security/distribution scans belong to Phase 25.
- Physical iPhone long-run stability and camera/Vision parity remain blocked until hardware evidence exists.
- Full public logging subsystem, MetricKit integration, signpost infrastructure, and per-frame logging behavior are deferred unless separately promoted.
- Release-grade naturalness, production render quality, and all-device 30 fps claims remain outside Phase 23 unless actual release-like evidence exists.

</deferred>

---

*Phase: 23-Performance and Reliability Gates*
*Context gathered: 2026-07-01*
