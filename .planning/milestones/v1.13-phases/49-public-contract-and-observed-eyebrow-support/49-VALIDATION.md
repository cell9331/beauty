---
phase: 49
slug: public-contract-and-observed-eyebrow-support
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-24
---

# Phase 49 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | Focused suites: under 2 minutes; full suite: host dependent |

The authorized portrait fixtures were restored from `example-images/parked-portraits/`, whose exact byte sizes match the repository's 2026-07-09 fixture record. Fixture preflight passes and the complete SwiftPM suite executes 411 tests with three explicit opt-in Apple Vision skips and zero failures.

## Sampling Rate

- **After every task commit:** Run the narrow owning XCTest suite and `python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py`.
- **After every plan wave:** Run parameter, resource, resolver, mapping, adapter, and detector focused suites plus `git diff --check`.
- **Before phase verification:** Run the full SwiftPM suite after fixture preflight, every focused suite, boundary self-tests/live checks, preset hash checks, and the owner-document audit.
- **Max feedback latency:** 2 minutes for the normal focused loop.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 49-01-01 | 01 | 1 | BROW-02, SUPP-03 | T-49-04, T-49-06 | Fail-closed privacy and scope checker | static + adversarial self-test | `python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py --self-test` | ✅ | ✅ 42/42 |
| 49-02-01 | 02 | 2 | BROW-01, BROW-02 | — | Exact neutral 59-field contract | unit + resource + resolver | focused parameter/resource/resolver commands | ✅ | ✅ 37 + 10 + 23 |
| 49-03-01 | 03 | 2 | SUPP-01, SUPP-02 | T-49-01, T-49-02, T-49-03 | Direct bounded actual-source mapping exactly once | unit + integration | `swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ | ✅ 66, 2 opt-in skips |
| 49-04-01 | 04 | 3 | SUPP-02, SUPP-03 | T-49-02, T-49-04, T-49-05 | Open-path validation, redaction, request isolation | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ | ✅ 45, 1 opt-in skip |
| 49-05-01 | 05 | 4 | BROW-01, BROW-02, SUPP-01, SUPP-02, SUPP-03 | all | Owner and evidence agreement without downstream claims | full/static | live checker, fixture preflight, full SwiftPM | ✅ | ✅ 411, 3 opt-in skips |

## Wave 0 Requirements

- [x] `check_eyebrow_support_boundaries.py` — 42/42 self-tests and 15/15 live classified checks.
- [x] Brow-specific fixture builders and topology matrices in `BeautyFaceGeometryAdapterTests.swift`.
- [x] Counting-mapper and orientation × mirror × reversal fixtures in `FaceObservationMappingTests.swift`.
- [x] Direct actual-property capture and sibling-local-failure fixtures in `VisionFaceDetectorTests.swift`.
- [x] Environment preflight for `example-images/input/portraits/e1.png`.

## Executed Evidence — 2026-07-24

| Gate | Actual result |
| --- | --- |
| Boundary checker self-test | PASS, 42/42 |
| `BeautyParametersTests` | PASS, 37/37 |
| `BeautyResourceCatalogTests` | PASS, 10/10 |
| `BeautyEffectResolverTests` | PASS, 23/23 |
| `BeautyDetectionTests` | PASS, 66 executed / 2 opt-in skips / 0 failures |
| `BeautyFaceGeometryAdapterTests` | PASS, 45 executed / 1 opt-in skip / 0 failures |
| Boundary checker live | PASS, 15/15; no unclassified match |
| ASVS L1 active-source/diff review | PASS for independently reviewable scope; 0 unresolved HIGH findings across spoofed provenance, raw-coordinate disclosure, fail-open evidence, malformed-input denial, and unauthorized public/downstream expansion |
| `git diff --check` | PASS |
| Fixture preflight | PASS, readable/non-empty regular `e1.png` restored from the byte-identical historical parked fixture set |
| Full `swift test --package-path BeautySDK` | PASS, 411 executed / 3 opt-in skips / 0 failures |

All Phase 49 requirement evidence is complete. Wave 0 is complete and the validation contract is Nyquist compliant.

## Manual-Only Verifications

All phase behaviors are designed for automated verification. Any unavailable authorized fixture or Apple Vision host capability is an explicit environment blocker, not a manual product-approval substitute.

## Validation Sign-Off

- [x] All tasks have `<automated>` verification or Wave 0 dependencies.
- [x] Sampling continuity: no three consecutive tasks without automated verification.
- [x] Wave 0 covers all missing references.
- [x] No watch-mode flags.
- [x] Focused feedback latency remains under two minutes.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-07-24
