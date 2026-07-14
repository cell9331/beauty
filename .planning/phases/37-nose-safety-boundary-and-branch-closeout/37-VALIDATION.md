---
phase: 37
slug: nose-safety-boundary-and-branch-closeout
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-14
---

# Phase 37 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest plus repository Python 3 self-tests/helpers |
| **Config file** | `BeautySDK/Package.swift`; existing test targets and Phase 36 helper |
| **Quick run command** | `swift test --package-path BeautySDK --filter <affected-suite>` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Output regression** | Build/run `BeautyExampleRenderer`, then run the Phase 36 strict helper self-test and live 252-output check |
| **Estimated runtime** | Focused suite under 60 seconds; full SDK/output/security gate several minutes |

## Sampling Rate

- **After every task commit:** Run the directly affected nonzero focused XCTest suite; shared resolver/convergence changes also run mouth provider/degradation coverage.
- **After every plan wave:** Run the aggregate suites named for that wave; Wave 3 includes full SwiftPM, renderer/helper, security, boundary, artifact, and diff-hygiene gates.
- **Before phase verification:** Full SwiftPM and the live Phase 36 36 × 7 output regression must be green from the current source.
- **After closeout edits:** Rerun exact promotion/current-owner/requirement scans and any runtime gate affected by a subsequent source change.
- **Max feedback latency:** One implementation task; zero-test or failed commands are blocking, never green evidence.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 37-01-01 | 01 | 1 | NOSE-10 | T37-01 | Aggregate-only cap evidence | unit | `swift test --package-path BeautySDK --filter BeautyEffectResolverTests` | ✅ | ✅ passed 15/15 |
| 37-01-02 | 01 | 1 | NOSE-11 | T37-02 | No prior or sibling emission survives unsupported input | unit/integration | `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests && swift test --package-path BeautySDK --filter NoseWarpProviderTests` | ✅ | ✅ passed 30/30 + 16/16 |
| 37-01-03 | 01 | 1 | NOSE-11 | T37-03 | No-face results preserve extent and redact geometry | facade | `swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests` | ✅ | ✅ passed 11/11 |
| 37-02-01 | 02 | 2 | NOSE-12 | T37-04 | Every retained field counted/scaled once | unit/integration | `swift test --package-path BeautySDK --filter CombinedEffectSafetyTests && swift test --package-path BeautySDK --filter GeometryConflictResolverTests` | ✅ | ✅ passed 10/10 + 9/9 |
| 37-02-02 | 02 | 2 | NOSE-11, NOSE-12 | T37-04 | Final effective strengths equal final emissions | integration | `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests && swift test --package-path BeautySDK --filter NoseWarpProviderTests && swift test --package-path BeautySDK --filter MouthWarpProviderTests` | ✅ | ✅ passed; exact 2.95/8 and 1.40/3 convergence locked |
| 37-03-01 | 03 | 3 | NOSE-13 | T37-01 through T37-08 | ASVS L1, HIGH blocking, fail-closed active-source scan | security | Phase-owned boundary script with default and `--allow-promotion` self-tests/live modes | ✅ | ✅ passed 33/33 self-test, 13/13 default, threats_open 0 |
| 37-03-02 | 03 | 3 | NOSE-13 | T37-05 | Exact public facade and ignored-artifact regression | runtime/output | Full SwiftPM plus renderer build/run and Phase 36 helper self-test/live run | ✅ | ✅ passed 228/228 and 252/252 exact output gate |
| 37-04-01 | 04 | 4 | NOSE-14 | T37-06 | Promotion changes exactly two rows then one SDK-core branch | contract scan | Exact ledger/matrix/README status and evidence-reference scans | ✅ | ✅ exactly six implemented rows and SDK-core branch |
| 37-04-02 | 04 | 4 | DOC-01 | T37-07 | Current owners agree without audit/readiness overclaim | documentation/lifecycle | Requirement/status/non-claim/current-owner scans plus `git diff --check` | ✅ | ✅ synchronized; audit remains next |

## Wave 0 Requirements

Existing SwiftPM/XCTest and Python helper infrastructure covers all requirements; no Wave 0 install or test stub is missing. The boundary checker is an explicit Plan 37-03 task-produced artifact, not a pre-plan dependency.

## Manual-Only Verifications

All in-scope phase behaviors have automated verification. Subjective naturalness, physical-device parity, commercial approval, packaging, shipping, and launch readiness are excluded scope, not manual acceptance gates.

## Blocking Final Gates

- Exact `0.25` normalized/effective cap values, counts, warnings, and aggregate metrics.
- Six fields plus both signed tip directions across zero, no-face, missing support, provider-empty, stale, reused exact `0.5`, and both transition families.
- Exact converged retained total, weakened count, scale, warning multiplicity, effective strengths, and provider emissions.
- Fresh nonzero focused suites and full SwiftPM with zero failures.
- Exact unchanged 36 cases × 7 fixtures = 252 decoded outputs; 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face checks.
- ASVS Level 1 with no open HIGH and final `threats_open: 0`.
- Fail-closed public/SPI, import, dependency, network/cloud, commercial, privacy, compatibility, and generated-artifact scans.
- Atomic two-row and SDK-core branch promotion, synchronized current owners, and no pre-authored milestone audit/archive/tag/cleanup claim.

## Validation Sign-Off

- [x] All planned task families have an automated command or explicit Wave 0 dependency.
- [x] Sampling continuity permits no implementation task without a focused automated check.
- [x] Wave 0 has no missing framework, fixture, or test reference.
- [x] No watch-mode flags are used.
- [x] Focused feedback latency is bounded to one task.
- [x] `nyquist_compliant: true` is set in frontmatter.

**Approval:** Plans 37-01 through 37-04 passed on 2026-07-14. Phase verification is 6/6; the independent milestone audit remains the next lifecycle action.
