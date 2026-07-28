---
phase: 50
slug: independent-eyebrow-geometry-and-pipeline-integration
status: validated
nyquist_compliant: true
wave_0_complete: true
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
| **Measured runtime** | Focused gate 70 s total; all BeautyEffects 22 s; full SwiftPM 76 s. Commands are non-watch and single-job. |

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
| 50-01-01 | 01 | 1 | GEOM-01–07, PIPE-01–02 | T-50-02, T-50-03 | Fail-closed privacy, scope, and exact-accounting boundary | static/adversarial | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py --self-test` | ✅ | ✅ 4/4 |
| 50-01-02 | 01 | 1 | GEOM-01–07, PIPE-01 | T-50-01 | Canonical-source, brow-local, field-isolated provider contracts | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ✅ | ✅ 11/11 |
| 50-01-03 | 01 | 1 | PIPE-01 | T-50-02 | Request-local fixtures expose no raw eyebrow support | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ | ✅ 18/18 |
| 50-02-01 | 02 | 2 | GEOM-01–03, PIPE-01 | T-50-04–06 | Finite canonical per-side emissions and local empty removal | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ✅ | ✅ 11/11 |
| 50-02-02 | 02 | 2 | GEOM-04–07, PIPE-01 | T-50-04–06 | Pair/chord/apex prerequisites without fallback or disclosure | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ✅ | ✅ 11/11 |
| 50-03-01 | 03 | 3 | GEOM-01–07, PIPE-01 | T-50-07, T-50-09 | Same-name capped routing with aggregate eyebrow domain | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ | ✅ 26/26 |
| 50-03-02 | 03 | 3 | PIPE-01, PIPE-02 | T-50-07–09 | Freshness, local preflight, redacted metrics, and monotone 44-name convergence | unit/integration | same resolver command | ✅ | ✅ 26/26 |
| 50-04-01 | 04 | 3 | PIPE-02 | T-50-10 | Seven eyebrow names occur exactly once in all conflict inventories | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ | ✅ 14/14 |
| 50-04-02 | 04 | 3 | PIPE-02 | T-50-11 | Exact provisional 13.45/44/one-scale arithmetic and polarity | unit | same conflict command | ✅ | ✅ 14/14 |
| 50-05-01 | 05 | 4 | GEOM-01–07, PIPE-01–02 | T-50-12 | Field-local degradation and final-mask/provider agreement | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.CombinedEffectSafetyTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ extend | ✅ 15/15 + 48/48 |
| 50-05-02 | 05 | 4 | PIPE-01, PIPE-02 | T-50-13 | Exactly-once eyebrow insertion in unified dispatch | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ extend | ✅ 3/3 |
| 50-05-03 | 05 | 4 | GEOM-01–07, PIPE-01 | T-50-14 | Redacted public-facade routing and request isolation | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend | ✅ 18/18 |
| 50-06-01 | 06 | 5 | GEOM-01–07, PIPE-01–02 | T-50-15–17 | Fresh complete evidence; failed or stale output cannot become proof | full/static | fixture + checker + focused + BeautyEffects + full SwiftPM gate below | ✅ | ✅ 433/433, 3 opt-in skips |
| 50-06-02 | 06 | 5 | GEOM-01–07, PIPE-01–02 | T-50-16, T-50-17 | Owner contracts preserve privacy, boundaries, and downstream nonclaims | static | owner checker/grep/diff command | ✅ | ✅ passed |
| 50-06-03 | 06 | 5 | GEOM-01–07, PIPE-01–02 | T-50-15–17 | Reliability, acceptance, and ledger claims match fresh bounded evidence | static | owner checker/grep/diff command | ✅ | ✅ passed |

---

## Wave 0 Requirements

- [x] `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` — asymmetric paired, single-side, nil-apex, degenerate-chord, mirrored-direction, field-isolation, distinction, and immutable sibling fixtures.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTestingSupport.swift` — valid raw eyebrow traces plus missing/malformed fixtures.
- [x] Existing resolver/conflict/combined fixtures — exact named inventory extended from 37 to 44 with explicit-zero neutrality and positive routing.
- [x] Phase 50 checker — adversarial self-tests, fixture preflight, and live checks.
- [x] Readable, nonempty, regular `e1.png` fixture preflight passed before the full suite.

## Fresh Wave 5 Evidence — 2026-07-24

All commands exited `0` on the local macOS host. Provider 11/11 (3 s), resolver 26/26 (4 s), conflict 14/14 (2 s), combined 15/15 (5 s), degradation 48/48 (17 s), pipeline 3/3 (2 s), and facade 18/18 (12 s) passed. The complete focused gate, including fixture/checker work, took 70 s. All `BeautyEffectsTests` passed 243 executed with one opt-in Apple Vision skip in 22 s. Full SwiftPM passed 433 executed with three opt-in Apple Vision skips and zero failures in 76 s.

The fixture preflight, 4/4 adversarial checker self-tests, live checker, pinned `Package.swift` hash `6f03b078…` and unchanged Phase 49 checker hash `7a8716c…`, dependency/target/resource, public/SPI, reflection/persistence, network, Demo-source, generated-artifact containment, exact 59-row renderer/gallery inventory, unchanged seven `future` eyebrow ledger rows, scoped status/diff, and `git diff --check` gates passed. Ignored output/gallery directories remain untracked and unstaged.

The three retained judgment-tier prohibitions were dispositioned on 2026-07-28
in `50-HUMAN-REVIEW.md`: production support is not used for identity,
recognition, authentication, or profiling; observed support has no synthetic,
generated, eye-derived, or test-only production substitute; and Phase 50 does
not claim downstream phase, future-milestone, UI/device/commercial, or release
scope. The review is deliberately narrower than commercial naturalness or
release readiness.

---

## Manual-Only Verifications

All Phase 50 behaviors have automated source, unit, integration, facade, and boundary verification. Decoded visual direction/locality/distinction evidence is explicitly deferred to Phase 51, so no manual visual pass may substitute for this phase's compiled evidence.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Focused and full feedback latency measured and recorded
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** Phase 50 compiled SDK-core provider/routing validation is
validated. Phase 51 decoded output/gallery and Phase 52 final safety/promotion
were subsequently completed and remain separately owned by their phase
artifacts.

## Validation Audit Trail — 2026-07-28

| Check | Result |
| --- | --- |
| Nyquist frontmatter and task coverage | PASS — all declared task rows remain green and `nyquist_compliant: true`. |
| Phase verifier | PASS — `50-VERIFICATION.md` is `status: passed` with 4/4 must-haves. |
| Retained judgment-tier items | PASS — 3/3 recorded in `50-HUMAN-REVIEW.md`. |
| Boundary checker | PASS — self-test 4/4 and live mode pass. |

The validation lifecycle status is normalized from historical `complete` to
the current `validated` vocabulary. Historical execution counts above remain
the evidence recorded at Phase 50 closeout and are not rewritten as current
Phase 52 counts.
