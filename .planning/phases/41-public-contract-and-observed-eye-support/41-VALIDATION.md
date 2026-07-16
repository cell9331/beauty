---
phase: 41
slug: public-contract-and-observed-eye-support
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-16
---

# Phase 41 — Validation Strategy

> Per-phase validation contract for compatibility-safe eye parameters and private observed support.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via SwiftPM |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | < 120 seconds on the observed local toolchain |

## Sampling Rate

- **After every task commit:** Run the task's focused `swift test --package-path BeautySDK --filter ...` command and `git diff --check` when documents or source boundaries change.
- **After every plan wave:** Run `swift test --package-path BeautySDK`.
- **Before `$gsd-verify-work`:** Full SwiftPM suite and the boundary scan below must be green.
- **Max feedback latency:** 120 seconds for the full package suite.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 41-01-01 | 01 | 1 | EYE-01, EYE-02 | T41-01 | finite bounded scalar normalization | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ | ⬜ pending |
| 41-01-02 | 01 | 1 | EYE-03, EYE-04 | T41-01 | legacy neutrality and no provider drift | unit/regression | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | ✅ | ⬜ pending |
| 41-02-01 | 02 | 1 | EYE-05 | T41-02 | request-scoped non-Codable observed support | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ | ⬜ pending |
| 41-02-02 | 02 | 1 | EYE-05 | T41-02 | one mapper boundary and redacted failures | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.CoordinateMapperTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ | ⬜ pending |
| 41-03-01 | 03 | 2 | EYE-06 | T41-03 | bounded support validation and canonical ordering | unit/Wave 0 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ❌ W0 created by task | ⬜ pending |
| 41-03-02 | 03 | 2 | EYE-07 | T41-03 | pupil-local invalidation and complete-eye gating | integration/unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | ✅ | ⬜ pending |
| 41-04-01 | 04 | 3 | EYE-01, EYE-02, EYE-03, EYE-04, EYE-05, EYE-06, EYE-07 | T41-04 | fail-closed source/privacy/artifact boundary helper | self-test | `python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py --self-test` | ❌ W0 created by task | ⬜ pending |
| 41-04-02 | 04 | 3 | EYE-01, EYE-02, EYE-03, EYE-04, EYE-05, EYE-06, EYE-07 | T41-04 | synchronized owners and live boundary gate | package + boundary | `swift test --package-path BeautySDK` plus helper self-test/live mode | ✅ | ⬜ pending |

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` — synthetic reversed-winding, side/orientation, duplicate-only, malformed, over-ceiling, pupil containment, pupil offset, and paired-ratio fixtures (created as the first action of Task 41-03-01).
- [ ] `check_eye_support_boundaries.py` — adversarial self-test and live fail-closed scans are created by Task 41-04-01.

## Boundary Scan Contract

The Task 41-04-01/02 helper verification must fail closed (`set -euo pipefail`; each forbidden-match scan classifies exit 0/1/>1 and exits on tool errors) and must cover all active SDK sources, the `f1c28fa` manifest/Demo baseline, and both real output/gallery roots. The checked-in helper is the canonical command rather than an inline shell approximation.

```bash
python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py --self-test
python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py
```

The helper must retain explicit failure behavior and record its output in `41-04-SUMMARY.md`.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|-----------|-------------------|
| None | — | All Phase 41 behaviors use injected Vision fixtures and package tests; real portrait pupil inventory is exploratory Phase 43 work. | — |

## Validation Sign-Off

- [ ] All tasks have focused automated verification or explicit Wave 0 dependency.
- [ ] Sampling continuity: no three consecutive tasks without automated verification.
- [ ] Wave 0 artifacts are created by Task 41-03-01 and Task 41-04-01 before validation is marked complete.
- [x] No watch-mode flags.
- [ ] Feedback latency remains below 120 seconds.
- [ ] `nyquist_compliant: true` set after execution evidence is recorded.

**Approval:** pending
