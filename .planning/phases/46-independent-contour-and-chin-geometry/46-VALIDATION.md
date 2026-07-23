---
phase: 46
slug: independent-contour-and-chin-geometry
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-23
---

# Phase 46 — Validation Strategy

> Per-phase validation contract for four independent observed-contour/chin provider behaviors, routing, and field-local accounting.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Swift Package Manager |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` |
| **Full suite command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |
| **Feedback budget** | Focused suites under 120 seconds; full suite at phase gates |

---

## Sampling Rate

- **After every provider task commit:** Run `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests`.
- **After every resolver/conflict task commit:** Run focused `BeautyEffectResolverTests` and `GeometryConflictResolverTests`.
- **After every integration task commit:** Run the affected degradation, combined-safety, pipeline, or facade suite.
- **After every plan wave:** Run `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests`.
- **Before phase verification:** Run the full SwiftPM suite, scoped privacy/boundary scans, and `git diff --check`.
- **Max feedback latency:** 120 seconds for ordinary task-level sampling; no three consecutive implementation tasks may pass without an automated focused run.

---

## Requirement Verification Map

| Task ID | Planned Area | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|--------------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 46-W0-01 | asymmetric observed-support fixtures | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-01, T-46-05 | deterministic package-only fixtures distinguish exact source ownership without raw diagnostic output | unit fixture/Wave 0 | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ exists | ✅ green |
| 46-W0-02 | observed-support facade fixture | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-04 | public requests use deterministic valid contour/median data while results remain aggregate and redacted | facade fixture/Wave 0 | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ exists | ✅ green |
| 46-PROV-01 | smooth contour emission | GEOM-01 | T-46-02, T-46-05 | raw finite neighbor-chord deltas are mean-centered before one uniform finite scale; final displacements stay within the exact ceiling, sum/mean stay zero within `1e-6`, roughness strictly decreases, and no-improvement/proxy cases emit nothing | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ exists | ✅ green |
| 46-PROV-02 | temple fullness emission | GEOM-02 | T-46-02, T-46-05 | upper-lateral sources move outward and remain disjoint from cheek/shipped source sets | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ exists | ✅ green |
| 46-PROV-03 | cheekbone slim emission | GEOM-03 | T-46-02, T-46-05 | mid-lateral sources move inward and remain disjoint from temple/jaw/whole-face source sets | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ exists | ✅ green |
| 46-PROV-04 | chin taper emission | GEOM-04 | T-46-01, T-46-02, T-46-05 | contour+median+apex required; only apex neighbors move in X and chin/apex Y remains unchanged | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ exists | ✅ green |
| 46-PLAN-01 | effective strengths, caps, trigger, preflight | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-01, T-46-06 | provider-empty fields are removed before domains, totals, warnings, metrics, point counts, or dispatch | resolver integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ exists | ✅ green |
| 46-CONF-01 | shared 37-field convergence | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-03, T-46-06 | retained-baseline mask is monotone and bounded; every emitting field contributes exactly once | conflict unit/integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ exists | ✅ green |
| 46-DEGR-01 | missing/malformed/freshness/provider-empty transitions | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-01, T-46-06 | failure remains field-local; valid siblings continue; reused is exact 0.5 and stale/no-face are zero | degradation integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ exists | ✅ green |
| 46-COMB-01 | representative combined geometry | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-03 | face/eye/nose/mouth convergence excludes empty work and never revives removed fields | combined integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.CombinedEffectSafetyTests` | ✅ exists | ✅ green |
| 46-PIPE-01 | unified dispatch and accounting | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-03, T-46-04 | final effective values dispatch through one existing warp path and provider point counts are not duplicated | pipeline integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ exists | ✅ green |
| 46-FACADE-01 | isolated public-facade route | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-04, T-46-07 | each scalar triggers one detection route, produces positive aggregate geometry evidence, preserves extent, and leaks no support data | facade integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ exists | ✅ green |
| 46-BOUND-01 | privacy/scope/diff gate | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-04, T-46-07, T-46-08 | no public support type, persistence, cache, dependency, model, network, Demo, renderer-case, or generated-output expansion | static/security | `python3 .planning/phases/46-independent-contour-and-chin-geometry/check_face_geometry_boundaries.py --self-test && python3 .planning/phases/46-independent-contour-and-chin-geometry/check_face_geometry_boundaries.py && git diff --check` | ✅ exists | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Executed Evidence

Fresh results on 2026-07-23:

| Gate | Result |
|------|--------|
| Provider | `FaceShapeWarpProviderTests`: 17 executed, 0 failed |
| Resolver | `BeautyEffectResolverTests`: 21 executed, 0 failed |
| Conflict | `GeometryConflictResolverTests`: 13 executed, 0 failed |
| Combined | `CombinedEffectSafetyTests`: 14 executed, 0 failed |
| Pipeline | `BeautyGeometryEffectPipelineTests`: 2 executed, 0 failed |
| Degradation | `MissingLandmarkDegradationTests`: 43 executed, 0 failed |
| Facade | `BeautyEngineGeometryFacadeTests`: 15 executed, 0 failed |
| Effects target | `--filter BeautyEffectsTests`: 205 executed, 1 opt-in Apple Vision integration skip, 0 failed |
| Full SwiftPM | `--jobs 1`: 368 executed, 3 opt-in Apple Vision integration skips, 0 failed |
| Boundary self-test | 24/24 passed |
| Boundary live | 14/14 passed |
| Pins | `Package.swift` = `6f03b078816ad1f7a426e3f70d4f57503f3152e9`; Phase 45 checker = `7f7cb4ad0ec7463e065ad7b88c6858c0fceb10c4` |
| Hygiene | `git diff --check` passed; no tracked generated evidence or renderer/Demo/ledger-promotion change |

At Plan 06 evidence close, the three repository-specific governance inputs remained **unverified**: observed support must not become biometric profiling data; the seven-point proxy must not be presented as observed support; and deferred double-chin/hairline/branch-completion behavior must not be silently enabled. Concrete source manifestations passed the boundary checker. The subsequent independent audit in `46-SECURITY.md` now verifies all three for current repository scope with `threats_open: 0`.

---

## Exact Fixture Matrix

| Fixture | Required Evidence |
|---------|-------------------|
| Asymmetric complete support | Exact source arrays for all four fields; temple/cheek sets disjoint; direction, locality, finite/unit/radius/falloff bounds |
| Contour-only support | Smooth/temple/cheek non-empty; taper empty and final taper strength zero |
| Legacy proxy without observed contour | Four new emissions empty; five shipped face/chin emissions unchanged |
| Valid contour with missing/malformed median | Three contour fields survive; taper alone is zero |
| Provider-empty work | Field absent from final strength, total, count, scale, weakened count, domains, warnings, metrics, points, and dispatch |
| Valid shipped sibling plus invalid new field | Face domain remains active from sibling; invalid new field is zero and emits nothing |
| Fresh → reused → stale → fresh | Fresh emits; eligible reused is cap × 0.5; stale/no-face zero; final fresh restores without carryover |
| Deterministic facade usable face | One detection call, geometry required, usable result, positive aggregate point count, preserved extent, redacted diagnostics |

---

## Wave 0 Requirements

- [x] Extend `FaceShapeWarpProviderTests.swift` with reusable asymmetric complete, contour-only, missing-centerline, and legacy-proxy-only `FaceGeometry` fixtures.
- [x] Extend `BeautyEngineTestingSupport.swift` so deterministic `.usableFace` carries valid asymmetric raw contour and median support without adding a public geometry type.
- [x] Replace the Phase 45 nonzero-unrouted resolver expectation with Phase 46 positive routing while retaining explicit-zero neutrality.
- [x] Add table-driven key-path helpers for the four new `BeautyEffectiveStrengths` fields and their named emissions.
- [x] Define a fail-closed Phase 46 boundary/static command set without weakening the historical Phase 45 checker.

---

## Manual-Only Verifications

All Phase 46 acceptance is automatable through provider vectors, resolver/conflict accounting, deterministic facade routing, privacy scans, and SwiftPM tests. Decoded output visibility, ROI comparison, visual naturalness, final caps, and product promotion are intentionally deferred to Phases 47–48 rather than treated as manual Phase 46 gates.

---

## Validation Audit 2026-07-23

| Metric | Count |
|--------|-------|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

The post-review Nyquist audit cross-referenced GEOM-01 through GEOM-04 against every finalized plan task, the 12-row requirement map, the seven focused suites, the complete SwiftPM regression suite, the fail-closed checker, and the independent 18/18 goal verification. Provider vector, resolver lifecycle, conflict accounting, degradation, unified dispatch, facade routing, privacy/scope, and diff-hygiene behavior all have executable evidence. No missing-test or manual-only Phase 46 gap remains.

The standard review found only three trailing spaces in `46-RESEARCH.md`; commit `5a75293` removed them, and the complete phase range now passes `git diff --check`. The fresh verifier rerun executes 368 tests with 3 opt-in Apple Vision skips and 0 failures. Phase 47 output evidence and Phase 48 final safety/promotion remain explicit downstream requirements rather than validation omissions.

---

## Validation Sign-Off

- [x] Every finalized plan task has an `<automated>` command or explicit Wave 0 dependency.
- [x] Sampling continuity: no three consecutive tasks without automated verification.
- [x] Wave 0 covers asymmetric provider fixtures, observed-support facade routing, table-driven field helpers, and fail-closed boundary commands.
- [x] Provider tests inspect exact sources and vectors rather than only aggregate counts.
- [x] Conflict tests prove monotone bounded removal and exactly-once accounting.
- [x] No watch-mode flags are used.
- [x] Focused feedback latency remains under 120 seconds.
- [x] Full SwiftPM and diff/security gates pass.
- [x] `nyquist_compliant: true` and `wave_0_complete: true` are set only after executed evidence is recorded.

**Approval:** validated after post-review Nyquist audit — 2026-07-23
