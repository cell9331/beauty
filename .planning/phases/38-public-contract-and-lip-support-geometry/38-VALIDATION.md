---
phase: 38
slug: public-contract-and-lip-support-geometry
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-14
---

# Phase 38 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Swift Testing / XCTest through Swift Package Manager |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter <focused-suite>` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | ~15 seconds focused; ~35 seconds full |

---

## Sampling Rate

- **After every task commit:** Run the narrowest named Swift test suite for the changed contract.
- **After every plan wave:** Run `swift test --package-path BeautySDK`.
- **Before phase verification:** Full suite, structural boundary scans, and `git diff --check` must be green.
- **Max feedback latency:** 60 seconds for focused suites.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 38-01-01 | 01 | 1 | MOUTH-01..03 | T-38-01 | Non-finite input normalizes to zero; legacy payloads stay neutral | contract | `swift test --package-path BeautySDK --filter BeautyParametersTests` | ✅ | ✅ 21/21 passed |
| 38-01-02 | 01 | 1 | MOUTH-03 | T-38-01 | Bundled payload absence remains safe and local | integration | `swift test --package-path BeautySDK --filter BeautyResourceCatalogTests` | ✅ | ✅ 8/8 passed; caps 3/3 |
| 38-02-01 | 02 | 1 | MOUTH-04 | T-38-02 | Inner availability does not expose raw landmarks or disable outer-only faces | unit | `swift test --package-path BeautySDK --filter VisionFaceDetectorTests` | ✅ | ✅ 10/10 passed |
| 38-02-02 | 02 | 1 | MOUTH-04 | Package-only supports are finite, bounded, deterministic, and default-empty | unit | `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests` | ✅ | ✅ 12/12 passed |
| 38-03-01 | 03 | 2 | MOUTH-05..08 | T-38-03 | Each provider field validates its own support and fails closed independently | unit | `swift test --package-path BeautySDK --filter MouthWarpProviderTests` | ✅ | ✅ 16/16 passed |
| 38-04-01 | 04 | 3 | MOUTH-01..08 | T-38-04 | Effective strengths, convergence, diagnostics, and emissions share one retained set | integration | `swift test --package-path BeautySDK --filter BeautyEffectResolverTests && swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests && swift test --package-path BeautySDK --filter GeometryConflictResolverTests && swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` | ✅ | ✅ 70/70 passed |
| 38-04-02 | 04 | 3 | MOUTH-08 | T-38-05 | Public facade exposes only aggregate redacted evidence | integration | `swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests` | ✅ | ✅ 12/12 passed |
| 38-04-03 | 04 | 3 | MOUTH-01..08 | T-38-01..05 | No public geometry, dependency, network, Demo, renderer, promotion, or generated-artifact drift | structural | `swift test --package-path BeautySDK && git diff --check` | ✅ | ✅ 259/259 and final gates passed |

---

## Wave 0 Requirements

Existing SwiftPM targets, focused suites, deterministic fixtures, facade testing provider, and full-suite command cover all phase requirements. No new test framework or test-only dependency is required.

---

## Manual-Only Verifications

All Phase 38 behaviors have automated contract, vector, resolver, facade, and structural verification. Visible output naturalness and ROI calibration are explicitly deferred to Phase 39.

---

## Validation Sign-Off

- [x] All planned tasks have automated verification.
- [x] Sampling continuity: no three consecutive tasks lack automated verification.
- [x] Existing infrastructure covers all required test references.
- [x] No watch-mode flags.
- [x] Focused feedback latency target is below 60 seconds.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-07-14 for Phase 38 planning

**Final sign-off:** passed 2026-07-14 after 152/152 focused tests, 259/259 full SwiftPM tests, clean standard review, ASVS L1 `threats_open: 0`, contract synchronization, and final boundary checks.
