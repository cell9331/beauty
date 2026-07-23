---
phase: 46
slug: independent-contour-and-chin-geometry
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| 46-W0-01 | asymmetric observed-support fixtures | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-01, T-46-05 | deterministic package-only fixtures distinguish exact source ownership without raw diagnostic output | unit fixture/Wave 0 | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend | ⬜ pending |
| 46-W0-02 | observed-support facade fixture | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-04 | public requests use deterministic valid contour/median data while results remain aggregate and redacted | facade fixture/Wave 0 | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend | ⬜ pending |
| 46-PROV-01 | smooth contour emission | GEOM-01 | T-46-02, T-46-05 | raw finite neighbor-chord deltas are mean-centered before one uniform finite scale; final displacements stay within the exact ceiling, sum/mean stay zero within `1e-6`, roughness strictly decreases, and no-improvement/proxy cases emit nothing | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend | ⬜ pending |
| 46-PROV-02 | temple fullness emission | GEOM-02 | T-46-02, T-46-05 | upper-lateral sources move outward and remain disjoint from cheek/shipped source sets | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend | ⬜ pending |
| 46-PROV-03 | cheekbone slim emission | GEOM-03 | T-46-02, T-46-05 | mid-lateral sources move inward and remain disjoint from temple/jaw/whole-face source sets | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend | ⬜ pending |
| 46-PROV-04 | chin taper emission | GEOM-04 | T-46-01, T-46-02, T-46-05 | contour+median+apex required; only apex neighbors move in X and chin/apex Y remains unchanged | provider unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend | ⬜ pending |
| 46-PLAN-01 | effective strengths, caps, trigger, preflight | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-01, T-46-06 | provider-empty fields are removed before domains, totals, warnings, metrics, point counts, or dispatch | resolver integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend | ⬜ pending |
| 46-CONF-01 | shared 37-field convergence | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-03, T-46-06 | retained-baseline mask is monotone and bounded; every emitting field contributes exactly once | conflict unit/integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ extend | ⬜ pending |
| 46-DEGR-01 | missing/malformed/freshness/provider-empty transitions | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-01, T-46-06 | failure remains field-local; valid siblings continue; reused is exact 0.5 and stale/no-face are zero | degradation integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ extend | ⬜ pending |
| 46-COMB-01 | representative combined geometry | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-03 | face/eye/nose/mouth convergence excludes empty work and never revives removed fields | combined integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.CombinedEffectSafetyTests` | ✅ extend | ⬜ pending |
| 46-PIPE-01 | unified dispatch and accounting | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-03, T-46-04 | final effective values dispatch through one existing warp path and provider point counts are not duplicated | pipeline integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ extend | ⬜ pending |
| 46-FACADE-01 | isolated public-facade route | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-04, T-46-07 | each scalar triggers one detection route, produces positive aggregate geometry evidence, preserves extent, and leaks no support data | facade integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend | ⬜ pending |
| 46-BOUND-01 | privacy/scope/diff gate | GEOM-01, GEOM-02, GEOM-03, GEOM-04 | T-46-04, T-46-07, T-46-08 | no public support type, persistence, cache, dependency, model, network, Demo, renderer-case, or generated-output expansion | static/security | `git diff --check` plus scoped `rg`/git inventory commands recorded by the final plan | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

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

- [ ] Extend `FaceShapeWarpProviderTests.swift` with reusable asymmetric complete, contour-only, missing-centerline, and legacy-proxy-only `FaceGeometry` fixtures.
- [ ] Extend `BeautyEngineTestingSupport.swift` so deterministic `.usableFace` carries valid asymmetric raw contour and median support without adding a public geometry type.
- [ ] Replace the Phase 45 nonzero-unrouted resolver expectation with Phase 46 positive routing while retaining explicit-zero neutrality.
- [ ] Add table-driven key-path helpers for the four new `BeautyEffectiveStrengths` fields and their named emissions.
- [ ] Define a fail-closed Phase 46 boundary/static command set without weakening the historical Phase 45 checker.

---

## Manual-Only Verifications

All Phase 46 acceptance is automatable through provider vectors, resolver/conflict accounting, deterministic facade routing, privacy scans, and SwiftPM tests. Decoded output visibility, ROI comparison, visual naturalness, final caps, and product promotion are intentionally deferred to Phases 47–48 rather than treated as manual Phase 46 gates.

---

## Validation Sign-Off

- [ ] Every finalized plan task has an `<automated>` command or explicit Wave 0 dependency.
- [ ] Sampling continuity: no three consecutive tasks without automated verification.
- [ ] Wave 0 covers asymmetric provider fixtures, observed-support facade routing, table-driven field helpers, and fail-closed boundary commands.
- [ ] Provider tests inspect exact sources and vectors rather than only aggregate counts.
- [ ] Conflict tests prove monotone bounded removal and exactly-once accounting.
- [ ] No watch-mode flags are used.
- [ ] Focused feedback latency remains under 120 seconds.
- [ ] Full SwiftPM and diff/security gates pass.
- [ ] `nyquist_compliant: true` and `wave_0_complete: true` are set only after executed evidence is recorded.

**Approval:** pending execution and post-phase Nyquist audit
