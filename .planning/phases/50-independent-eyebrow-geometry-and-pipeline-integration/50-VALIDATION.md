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
| 50-01-01 | 01 | 1 | GEOM-01–07 | T-50-01 | Brow-local immutable geometry; no eye/face-array alias | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ❌ W0 | ⬜ pending |
| 50-02-01 | 02 | 2 | PIPE-01 | T-50-02 | Field-local removal and aggregate-only evidence | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend | ⬜ pending |
| 50-03-01 | 03 | 2 | PIPE-01, PIPE-02 | T-50-03 | Exact 44-field monotone convergence with no re-entry | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ extend | ⬜ pending |
| 50-04-01 | 04 | 3 | PIPE-01, PIPE-02 | T-50-04 | Exactly-once unified dispatch and redacted facade routing | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ extend | ⬜ pending |
| 50-05-01 | 05 | 3 | GEOM-01–07, PIPE-01–02 | T-50-05 | No dependency/resource/UI/network/persistence/raw-geometry drift | static/adversarial | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py` | ❌ W0 | ⬜ pending |

Task IDs and plan assignment are provisional until PLAN.md files are generated; the planner must preserve complete requirement coverage even if it chooses a different partition.

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
