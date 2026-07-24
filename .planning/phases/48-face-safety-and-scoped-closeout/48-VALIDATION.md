---
phase: 48
slug: face-safety-and-scoped-closeout
status: verified
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-24
---

# Phase 48 — Validation Strategy

## Test Infrastructure

| Property | Value |
|---|---|
| Framework | XCTest + Swift Package Manager; Python 3 standard library |
| Config | `BeautySDK/Package.swift`; no new dependencies |
| Full suite | `swift test --package-path BeautySDK` |
| Output regression | Phase 47 helper plus exact 413-output/gallery containment |
| Feedback target | focused <120s; full/output <300s |

## Sampling

- After each task: run its focused automated command and `git diff --check`.
- After each plan: run all suites and scripts owned by that wave.
- Before promotion: full SwiftPM, Phase 47 strict helper/gallery, Phase 48 checker default mode, review, security, and artifact gates.
- Before phase verification: full allow-promotion checker, full SwiftPM, helper self-tests, roadmap analysis, and diff hygiene.

## Per-Task Verification Map

| Task | Plan | Requirement | Automated evidence | Status |
|---|---:|---|---|---|
| 48-01-01 | 01 | SAFE-01 | cap + resolver focused suites | passed |
| 48-01-02 | 01 | SAFE-01 | face provider + degradation suites | passed |
| 48-01-03 | 01 | SAFE-01 | degradation + facade transition suites | passed |
| 48-02-01 | 02 | SAFE-02 | conflict resolver exact arithmetic | passed |
| 48-02-02 | 02 | SAFE-02 | combined/degradation final-mask equality | passed |
| 48-03-01 | 03 | SAFE-03 | checker compile/self-test/default live | passed |
| 48-03-02 | 03 | SAFE-01..03 | focused/full SwiftPM + Phase 47 strict/gallery | passed |
| 48-03-03 | 03 | SAFE-03 | review/security/evidence source gates | passed |
| 48-04-01 | 04 | DOC-01 | default pre-promotion gate | passed |
| 48-04-02 | 04 | DOC-01 | exact four-owner promotion gate | passed |
| 48-05-01 | 05 | DOC-01 | example owners + strict helper self-test | passed |
| 48-05-02 | 05 | SAFE-03,DOC-01 | six root-owner gates | passed |
| 48-06-01 | 06 | SAFE-01..03,DOC-01 | requirement/ledger/verification cross-check | passed |
| 48-06-02 | 06 | SAFE-01..03,DOC-01 | allow-promotion + full regression + roadmap analysis | passed |

## Required Commands

```bash
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautySafetyCapsTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK
PYTHONPYCACHEPREFIX=/tmp/beauty-pycache python3 -m py_compile .planning/phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py
python3 .planning/phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py --self-test
python3 .planning/phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py
python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py --self-test
python3 example-images/generate_gallery.py --self-test
git diff --check
```

The strict live renderer/output gate is required in Plan 03. Its exact command and environment are recorded in `48-FACE-SAFETY-EVIDENCE.md` when executed.

## Wave 0 Requirements

- [x] Phase 48 boundary checker exists and passes self-test/default live.
- [x] Phase 48 safety evidence exists with fresh command counts.
- [x] Review and security artifacts exist before promotion; verification remains Plan 06.
- [x] Existing XCTest and Phase 47 output infrastructure require no installation.

## Manual-Only Verification

None. Subjective naturalness, physical-device parity, commercial approval, optimized performance, packaging, shipping, and launch readiness are out of scope rather than hidden manual gates.

## Sign-Off

- [x] Every planned task has automated evidence.
- [x] No three consecutive tasks lack automated verification.
- [x] Wave 0 dependencies complete.
- [x] `nyquist_compliant: true` only after final execution.
- [x] Approval set to `passed` only after final verification.

**Approval:** passed — 2026-07-24
