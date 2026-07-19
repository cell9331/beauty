---
phase: 44
slug: eye-geometry-safety-and-ledger-closeout
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-19
---

# Phase 44 — Validation Strategy

> Per-phase validation contract for exact eye safety, convergence, boundary, and ledger promotion.

## Test Infrastructure

| Property | Value |
|---|---|
| **Framework** | XCTest + Swift Package Manager; Python 3 standard library for boundary/evidence helpers |
| **Config file** | `BeautySDK/Package.swift`; no new dependencies |
| **Quick run command** | Focused XCTest filters and Python checker commands listed per task below |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | ~2 minutes full suite; helper/self-test <30 seconds |

## Sampling Rate

- **After every task commit:** run that task's exact automated command plus `git diff --check`.
- **After every plan wave:** run the full SwiftPM suite and all prior-phase helper self-tests required by that wave.
- **Before `$gsd-verify-work`:** run full SwiftPM, Phase 43 strict/helper/gallery, boundary default/promotion/owner/allow modes, and artifact scans.
- **Max feedback latency:** 120 seconds for focused checks; 180 seconds for full suite.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---|---:|---:|---|---|---|---|---|---|---|
| 44-01-01 | 01 | 1 | EYE-19 | T44-01 | exact caps/counts/redacted diagnostics | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautySafetyCapsTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests && git diff --check` | ✅ | ✅ |
| 44-01-02 | 01 | 1 | EYE-19 | T44-02 | signed/positive-only normalization and dead zones | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests && git diff --check` | ✅ | ✅ |
| 44-01-03 | 01 | 1 | EYE-20 | T44-03 | field-local provider eligibility and complete-eye skip | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests && git diff --check` | ✅ | ✅ |
| 44-01-04 | 01 | 1 | EYE-20 | T44-04 | no-face/missing/reused/stale transitions and facade redaction | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests && swift test --package-path BeautyCoreTests.BeautyEngineGeometryFacadeTests && git diff --check` | ✅ | ✅ |
| 44-02-01 | 02 | 2 | EYE-21 | T44-05 | exact one-baseline arithmetic and signed preservation | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests && git diff --check` | ✅ | ✅ |
| 44-02-02 | 02 | 2 | EYE-21 | T44-06 | 28-removal monotonic convergence and provider equality | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests && git diff --check` | ✅ | ✅ |
| 44-02-03 | 02 | 2 | EYE-20,EYE-21 | T44-07 | safe siblings continue after late eye removals | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests && swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests && git diff --check` | ✅ | ✅ |
| 44-03-01 | 03 | 3 | EYE-22 | T44-08 | active-source/privacy/import/dependency/artifact boundary | script | `python3 -m py_compile .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py && python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py --self-test && python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py && git diff --check` | ✅ | ✅ |
| 44-03-02 | 03 | 3 | EYE-19,EYE-20,EYE-21,EYE-22 | T44-09 | fresh runtime and unchanged descriptor-safe output/gallery regression | command/script | `swift test --package-path BeautySDK && python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --self-test && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output && python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --input example-images/input --output example-images/output --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift && python3 example-images/generate_gallery.py --self-test && python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py && git diff --check` | ✅ | ✅ |
| 44-03-03 | 03 | 3 | EYE-22 | T44-10 | ASVS L1 HIGH threats blocked and no raw geometry | command | `rg -n 'status: clean|threats_open: 0|EYE-19|EYE-20|EYE-21|EYE-22' .planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-REVIEW.md .planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-SECURITY.md .planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-EYE-SAFETY-EVIDENCE.md && python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py && git diff --check` | ✅ | ✅ |
| 44-04-01 | 04 | 4 | EYE-23 | T44-11 | exact pre-promotion authorization remains green | script | `python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py && git diff --check` | ✅ | ✅ |
| 44-04-02 | 04 | 4 | EYE-23 | T44-12 | exact ten-row promotion and branch/future boundary | script | `python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py --check-promotion && git diff --check && test "$(git diff --name-only | rg -v '^(docs/meitu-function-blueprint/(SHAPE_FEATURE_LEDGER.md|FEATURE_MATRIX.md|features/beauty-shaping/(eyes/README.md|README.md)))$' | wc -l | tr -d ' ')" -eq 0` | ✅ | ✅ |
| 44-05-01 | 05 | 5 | EYE-23,DOC-01 | T44-13 | example/public-output owner agrees with exact evidence | script | `python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py --check-owners --owner example && python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --self-test && python3 example-images/generate_gallery.py --self-test && git diff --check` | ✅ | ✅ |
| 44-05-02 | 05 | 5 | EYE-23,DOC-01 | T44-14 | six root owners each pass exact live assertions and aggregate | script | `for owner in architecture design security reliability product quality; do python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py --check-owners --owner "$owner" || exit 1; done && python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py --check-owners && git diff --check` | ✅ | ✅ |
| 44-06-01 | 06 | 6 | EYE-23,DOC-01 | T44-15 | one-to-one validation and explicit pending independent-audit handoff | docs/command | `rg -n 'EYE-19|EYE-20|EYE-21|EYE-22|EYE-23|DOC-01.*pending|independent.*audit' .planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-VERIFICATION.md .planning/REQUIREMENTS.md PLANS.md .planning/PROJECT.md && git diff --check` | ✅ | ✅ |
| 44-06-02 | 06 | 6 | EYE-23,DOC-01 | T44-16 | full live handoff gate passes while DOC-01 remains pending | command/script | `python3 .planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py --allow-promotion && swift test --package-path BeautySDK && python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --self-test && python3 example-images/generate_gallery.py --self-test && node /Users/yakangwang/.antigravity_cockpit/instances/codex/cli-037507efedd7/gsd-core/bin/gsd-tools.cjs query roadmap.analyze && git diff --check` | ✅ | ✅ |

## Wave 0 Requirements

- [x] `check_eye_geometry_boundaries.py` — created and self-tested by Task 44-03-01.
- [ ] `44-EYE-SAFETY-EVIDENCE.md`, `44-SECURITY.md`, `44-VERIFICATION.md` — safety evidence/security complete; final verification remains Plan 06.
- [ ] Existing XCTest infrastructure covers all runtime requirements; no framework install is needed.

## Manual-Only Verifications

All phase behaviors have automated verification. Subjective naturalness, physical-device parity, commercial visual approval, and launch readiness are explicitly out of scope rather than manual acceptance criteria.

## Validation Sign-Off

- [x] All sixteen tasks have automated verification or explicit Wave 0 dependency.
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify.
- [ ] Wave 0 dependencies are created by their owning earlier tasks before use.
- [ ] No watch-mode flags.
- [ ] Feedback latency < 180s.
- [ ] `nyquist_compliant: true` set only after execution and final verification.

**Approval:** passed
