---
phase: 50
slug: independent-eyebrow-geometry-and-pipeline-integration
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-24
---

# Phase 50 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Swift Package Manager (Swift 6.3.3 toolchain) |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` |
| **Full suite command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |
| **Estimated runtime** | Establish during Wave 0; commands are non-watch and single-job |

---

## Sampling Rate

- **After every provider task commit:** Run the eyebrow provider suite.
- **After every resolver/conflict task commit:** Run resolver, conflict, and combined-safety suites named by the task.
- **After every integration task commit:** Run degradation, pipeline, facade, and boundary checks named by the task.
- **After every plan wave:** Run `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests`.
- **Before `$gsd-verify-work`:** Fixture preflight, focused suites, boundary checker self-test/live modes, and the full SwiftPM suite must be green.
- **Max feedback latency:** Record measured focused/full runtimes during Wave 0; keep task-local verification narrower than the wave suite.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 50-01-01 | 01 | 1 | GEOM-01–07, PIPE-01–02 | T-50-02, T-50-03 | Fail-closed privacy, scope, and exact-accounting boundary | static/adversarial | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py --self-test && python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py --pre-implementation` | ❌ W0 | ⬜ pending |
| 50-01-02 | 01 | 1 | GEOM-01–07, PIPE-01 | T-50-01 | Canonical-source, brow-local, field-isolated RED provider contracts | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ❌ W0 | ⬜ pending |
| 50-01-03 | 01 | 1 | PIPE-01 | T-50-02 | Request-local fixtures expose no raw eyebrow support | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend | ⬜ pending |
| 50-02-01 | 02 | 2 | GEOM-01–03, PIPE-01 | T-50-04–06 | Finite canonical per-side emissions and local empty removal | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ❌ W0 | ⬜ pending |
| 50-02-02 | 02 | 2 | GEOM-04–07, PIPE-01 | T-50-04–06 | Pair/chord/apex prerequisites without fallback or disclosure | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ❌ W0 | ⬜ pending |
| 50-03-01 | 03 | 3 | GEOM-01–07, PIPE-01 | T-50-07, T-50-09 | Same-name capped routing with aggregate eyebrow domain | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend | ⬜ pending |
| 50-03-02 | 03 | 3 | PIPE-01, PIPE-02 | T-50-07–09 | Freshness, local preflight, redacted metrics, and monotone 44-name convergence | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend | ⬜ pending |
| 50-04-01 | 04 | 3 | PIPE-02 | T-50-10 | Seven eyebrow names occur exactly once in all conflict inventories | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ extend | ⬜ pending |
| 50-04-02 | 04 | 3 | PIPE-02 | T-50-11 | Exact provisional 13.45/44/one-scale arithmetic and polarity | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ extend | ⬜ pending |
| 50-05-01 | 05 | 4 | GEOM-01–07, PIPE-01–02 | T-50-12 | Field-local degradation and final-mask/provider agreement | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.CombinedEffectSafetyTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ extend | ⬜ pending |
| 50-05-02 | 05 | 4 | PIPE-01, PIPE-02 | T-50-13 | Exactly-once eyebrow insertion in unified dispatch | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ extend | ⬜ pending |
| 50-05-03 | 05 | 4 | GEOM-01–07, PIPE-01 | T-50-14 | Redacted public-facade routing and request isolation | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend | ⬜ pending |
| 50-06-01 | 06 | 5 | GEOM-01–07, PIPE-01–02 | T-50-15–17 | Fresh complete evidence; failed or stale output cannot become proof | full/static | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py --preflight-fixtures && python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py --self-test && python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py && swift test --package-path BeautySDK --disable-sandbox --jobs 1` | ✅ update | ⬜ pending |
| 50-06-02 | 06 | 5 | GEOM-01–07, PIPE-01–02 | T-50-16, T-50-17 | Owner contracts preserve privacy, boundaries, and downstream nonclaims | static | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py && rg -n "Phase 50|provisional|44|13\.45|Phase 51|Phase 52" ARCHITECTURE.md DESIGN.md SECURITY.md` | ✅ extend | ⬜ pending |
| 50-06-03 | 06 | 5 | GEOM-01–07, PIPE-01–02 | T-50-15–17 | Reliability, acceptance, and ledger claims match fresh bounded evidence | static | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py && rg -n "Phase 50|GEOM-01|GEOM-07|PIPE-01|PIPE-02|Phase 51|Phase 52" RELIABILITY.md PRODUCT_SENSE.md PLANS.md` | ✅ extend | ⬜ pending |

---

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` — asymmetric paired, single-side, nil-apex, degenerate-chord, mirrored-direction, field-isolation, distinction, and immutable sibling fixtures.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTestingSupport.swift` — valid raw eyebrow traces plus missing/malformed fixtures.
- [ ] Existing resolver/conflict/combined fixtures — extend exact named inventory from 37 to 44 and replace Phase 49 runtime-inert evidence with explicit-zero neutrality plus positive Phase 50 routing.
- [ ] `.planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py` — adversarial self-tests and live classified checks.
- [ ] Preserve readable/non-empty `e1.png` fixture preflight before the full suite.

---

## Manual-Only Verifications

All Phase 50 behaviors have automated source, unit, integration, facade, and boundary verification. Decoded visual direction/locality/distinction evidence is explicitly deferred to Phase 51, so no manual visual pass may substitute for this phase's compiled evidence.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Focused and full feedback latency measured and recorded
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
