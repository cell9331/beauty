---
phase: "93"
slug: "distinct-nose-bridge-and-root-repairs"
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-09-09"
---

# Phase 93 — Validation Strategy

> Validate common observation-to-raster registration before any production candidate, then require provider and public-pixel evidence for both distinct nose semantics.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest through SwiftPM |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter NoseWarpProviderTests` |
| **Full suite command** | Focused nose registration, public repair, provider, compatibility, comparator, boundary and SDK-only gates listed below |
| **Estimated runtime** | Not measured; no latency promise |

## Sampling Rate

- **After every task commit:** Run the task's narrow discovered-test-count and focused XCTest command.
- **After every plan wave:** Run every focused suite introduced or modified in that wave.
- **Before goal verification:** Run the complete focused conjunction and immutable-authority checks.
- **Max feedback latency:** Unmeasured; split registration, provider and public-pixel filters to preserve fast diagnosis.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 93-01-01 | 01 | 0 | NOSE-01, NOSE-02 | T-93-01 | One common independently justified observation registers bridge/root support to frozen ROIs | integration registration | `swift test --package-path BeautySDK --filter NoseFixtureRegistrationTests` | ❌ W0 | ⬜ pending |
| 93-01-02 | 01 | 0 | NOSE-01, NOSE-02 | T-93-02 | Exact integer metrics and immutable public-pixel RED distinguish the controls | public integration | `swift test --package-path BeautySDK --filter BeautyEngineNoseRepairTests` | ❌ W0 | ⬜ pending |
| 93-02-01 | 02 | 1 | NOSE-01, NOSE-02 | T-93-03 | Finite renderer-effective fields satisfy caps, fail closed, and remain dense-safe | provider unit | `swift test --package-path BeautySDK --filter NoseWarpProviderTests` | ✅ extend | ⬜ pending |
| 93-02-02 | 02 | 1 | NOSE-01, NOSE-02 | T-93-01, T-93-03 | Actual pixels pass frozen target, sibling and protection gates | public integration | `swift test --package-path BeautySDK --filter BeautyEngineNoseRepairTests` | ❌ W0 | ⬜ pending |
| 93-03-01 | 03 | 2 | NOSE-01, NOSE-02 | T-93-04 | Accepted evidence is aggregate-only and frozen authorities remain unchanged | compatibility/boundary | focused conjunction plus comparator, cleanup and SDK-only scripts | ✅ existing plus W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyEffectsTests/NoseFixtureRegistrationTests.swift` — common source/observation/adapter registration; stop production planning if unresolved.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift` — exact bridge/root metrics, lifecycle and immutable public-pixel RED.
- [ ] Discover each required new test exactly once before relying on its result; zero discovered tests is failure.
- [ ] Pin relevant source recipe, observation, metric-helper, provider and frozen authority blobs before the first production edit.

## Manual-Only Verifications

All Phase 93 acceptance behavior is automated. Physical-device and portrait evaluation are optional or owned by Phase 95 and do not gate this phase.

## Phase Gates

```bash
swift test --package-path BeautySDK --filter NoseFixtureRegistrationTests
swift test --package-path BeautySDK --filter BeautyEngineNoseRepairTests
swift test --package-path BeautySDK --filter NoseWarpProviderTests
swift test --package-path BeautySDK --filter 'BeautySafetyCapsTests|BeautyEffectResolverTests|GeometryConflictResolverTests|CombinedEffectSafetyTests|MissingLandmarkDegradationTests|CPUReferenceGeometryOracleTests|CPUReferenceFacadeFixtureTests|CPUReferenceDeterminismTests|BeautyEngineGeometryFacadeTests|BeautyParametersTests'
swift scripts/compare-face-feature-batches.swift --self-test
bash scripts/run-face-feature-batches.sh --self-test-boundaries
bash scripts/run-face-feature-batches.sh --self-test-report-cleanup
bash scripts/check-backend-neutral-contract.sh
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
git diff --check
```

The registration test must pass before any edit to `NoseWarpProvider.swift`. A registration failure is a prerequisite finding, does not earn semantic credit, and does not consume either authorized implementation attempt. New and focused nose tests require a nonzero denominator, zero failures and zero skips. Existing opt-in portrait skips remain outside Phase 93 acceptance. Full 65-output and no-skip closeout remain Phase 95.

## Validation Sign-Off

- [ ] All tasks have an automated verification or a Wave 0 dependency.
- [ ] Registration precedes RED; RED precedes production mutation.
- [ ] No three consecutive implementation tasks lack an automated check.
- [ ] Every new test is discovered exactly once and cannot silently select zero tests.
- [ ] Frozen manifest, comparator, renderer, shared sampler and retained shader remain unchanged.
- [ ] Aggregate-only evidence contains no raw pixels, geometry, masks, private paths or transcripts.
- [ ] `nyquist_compliant: true` is set only after independent validation audit.

**Approval:** pending independent plan check
