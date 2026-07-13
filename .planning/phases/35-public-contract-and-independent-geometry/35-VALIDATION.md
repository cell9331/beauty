---
phase: 35
slug: public-contract-and-independent-geometry
status: draft
nyquist_compliant: false
wave_0_complete: true
created: 2026-07-13
---

# Phase 35 — Validation Strategy

> Per-phase validation contract for the public nose contract, independent provider geometry, and facade-safe routing.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest through Swift Package Manager (Swift 6.3.3 observed during research) |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter <affected-suite>` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | Focused suites under 30 seconds each; full-suite duration recorded during execution |

---

## Sampling Rate

- **After every task commit:** Run the narrowest affected XCTest suite and `git diff --check`.
- **After every plan wave:** Run all focused Phase 35 suites named below.
- **Before `$gsd-verify-work`:** The complete `swift test --package-path BeautySDK` suite and all structural/boundary scans must be green.
- **Max feedback latency:** 30 seconds for focused test feedback; the full suite is the wave/phase gate.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 35-01-01 | 01 | 1 | NOSE-01, NOSE-02 | T35-01 | Non-finite values become zero; old payloads/presets remain neutral | unit/compatibility | `swift test --package-path BeautySDK --filter BeautyParametersTests` | ✅ | ⬜ pending |
| 35-01-02 | 01 | 1 | NOSE-01, NOSE-02 | T35-01 | Resource decoding adds no implicit nonzero nose behavior | integration | `swift test --package-path BeautySDK --filter BeautyResourceCatalogTests` | ✅ | ⬜ pending |
| 35-02-01 | 02 | 2 | NOSE-04, NOSE-05, NOSE-06 | T35-02 | Package-internal supports remain fail-closed and never expose raw geometry | unit | `swift test --package-path BeautySDK --filter NoseWarpProviderTests` | ✅ | ⬜ pending |
| 35-02-02 | 02 | 2 | NOSE-04, NOSE-05, NOSE-06 | T35-02 | Invalid/insufficient supports cannot borrow legacy bridge/tip points | unit | `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests` | ✅ | ⬜ pending |
| 35-03-01 | 03 | 3 | NOSE-03, NOSE-06 | T35-03 | Missing/stale/provider-empty geometry zeros affected strengths with aggregate-only diagnostics | integration | `swift test --package-path BeautySDK --filter BeautyEffectResolverTests && swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` | ✅ | ⬜ pending |
| 35-03-02 | 03 | 3 | NOSE-03 | T35-03 | Both new fields participate in caps, counts, reuse, and conflict weakening | integration | `swift test --package-path BeautySDK --filter BeautySafetyCapsTests && swift test --package-path BeautySDK --filter GeometryConflictResolverTests && swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` | ✅ | ⬜ pending |
| 35-03-03 | 03 | 3 | NOSE-03 | T35-04 | Public facade reveals only redacted summaries/metrics, never raw landmarks/control points | facade | `swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests` | ✅ | ⬜ pending |
| 35-04-01 | 04 | 4 | NOSE-01–NOSE-06 | T35-01–T35-04 | Focused/full implementation and ASVS L1 evidence is captured but remains explicitly non-final until contract synchronization | regression/security | `swift test --package-path BeautySDK && git diff --check` | ✅ | ⬜ pending |
| 35-04-02 | 04 | 4 | NOSE-01–NOSE-06 | T35-01–T35-04 | Contract/ledger synchronization, no-promotion and no-overclaim checks pass before the final full/scoped rerun sets verification, security, and Nyquist states green | regression/boundary | `swift test --package-path BeautySDK && git diff --check` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Threat References

| Ref | Threat | Required mitigation/evidence |
| --- | --- | --- |
| T35-01 | Public-model growth breaks source/JSON/preset compatibility or aliases legacy fields | Defaulted initializer arguments, missing-key zero decoding, independent stored fields, exact 33-field and round-trip tests |
| T35-02 | New provider semantics borrow legacy points, accept malformed supports, or emit invalid vectors | Dedicated supports/helpers, subset sufficiency guards, axis/direction/symmetry/non-alias/finiteness/bounds tests |
| T35-03 | Manual resolver/conflict lists omit a new field or leave unsafe effective strength active | Isolated activation plus caps, zeroing, reuse, provider-empty, conflict-total/count/scaling tests |
| T35-04 | Facade evidence exposes raw geometry or expands into Demo/renderer/status scope | Redacted aggregate assertions and source/diff scans for public geometry, Demo, renderer, dependencies, and ledger promotion |

---

## Wave 0 Requirements

Existing SwiftPM/XCTest infrastructure and all required suite files already exist. No new framework, target, test runner, or dependency is required. New fixtures and test cases are implementation tasks inside the owning plans, not Wave 0 setup.

---

## Manual-Only Verifications

All Phase 35 runtime behaviors have automated verification. Structural scope checks require human classification of expected internal lexical matches, but their commands and pass conditions are deterministic:

- no new public/SPI `FaceGeometry`, landmarks, or warp control-point exposure;
- no `BeautyExampleRenderer`, Demo UI, feature-ledger promotion, package-target, or dependency changes;
- archived v1.7 evidence remains untouched.

---

## Required Focused Commands

```bash
swift test --package-path BeautySDK --filter BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyResourceCatalogTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautySafetyCapsTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.NoseWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK
git diff --check
```

Use the actual suite names reported by SwiftPM when a module-qualified filter selects zero tests. Record post-change executed counts rather than reusing the research baseline.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verification or an explicit structural gate.
- [ ] Sampling continuity: no three consecutive tasks lack automated verification.
- [x] Wave 0 covers all infrastructure references.
- [x] No watch-mode flags are used.
- [ ] Focused feedback latency remains below 30 seconds.
- [ ] Full SwiftPM and boundary scans pass.
- [ ] `nyquist_compliant: true` is set after execution evidence is recorded.

**Approval:** pending execution
