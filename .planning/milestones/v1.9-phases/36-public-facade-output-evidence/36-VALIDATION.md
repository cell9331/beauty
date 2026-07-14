---
phase: 36
slug: public-facade-output-evidence
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-13
---

# Phase 36 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM/XCTest plus Python 3 standard-library image helper |
| **Config file** | `BeautySDK/Package.swift`; helper is self-contained |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | focused under 30 seconds; renderer matrix plus full suite under 5 minutes |

## Sampling Rate

- **After every task commit:** Run the task's focused XCTest/helper/source gate and `git diff --check`.
- **After every plan wave:** Run the accumulated focused tests; after renderer generation, rerun the complete output helper.
- **Before phase verification:** Full SwiftPM, clean 252-output matrix, 252-gallery matrix, containment scans, and no-promotion scans must be green.
- **Max feedback latency:** 5 minutes for the generated-output wave; under 60 seconds for source-only tasks.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 36-01-01 | 01 | 1 | NOSE-07 | T-36-01 | public-facade-only renderer cases; no raw geometry import | focused XCTest/source scan | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | ✅ | ✅ green |
| 36-01-02 | 01 | 1 | NOSE-09 | T-36-02 | no-face output preserves extent and redacted aggregate result | focused XCTest | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | ✅ | ✅ green |
| 36-02-01 | 02 | 2 | NOSE-08 | T-36-03 | discovered inventory rejects duplicates, missing/extra/corrupt outputs, and extent drift | helper negative/positive fixtures | `python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --help` | ✅ | ✅ green |
| 36-02-02 | 02 | 2 | NOSE-08 | T-36-04 | above-watermark fixed ROI proves separate baseline and legacy non-alias families | renderer + helper | `python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --input example-images/input --output example-images/output --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift` | ✅ | ✅ green |
| 36-03-01 | 03 | 3 | NOSE-09 | T-36-05 | output/gallery paths remain ignored and no generated PNG is tracked | gallery/count/git gates | `test -z "$(git ls-files example-images/output example-images/gallery)"` | ✅ | ✅ green |
| 36-03-02 | 03 | 3 | NOSE-07, NOSE-08, NOSE-09 | T-36-06 | evidence closes only Phase 36 requirements with no promotion or readiness overclaim | full regression + scope scans | `swift test --package-path BeautySDK && git diff --check` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

## Wave 0 Requirements

- [x] `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py` — created by Plan 36-02 before generated-output validation.
- [x] Helper uses only the Python standard library and remains runnable after milestone archival; it imports no sibling or archived helper.
- [x] Helper self-tests reject duplicate renderer IDs, duplicate fixture stems, missing/extra/corrupt output, and ROI/watermark overlap before live outputs pass.

Existing SwiftPM/XCTest, renderer, fixtures, and gallery infrastructure cover all other requirements.

## Manual-Only Verifications

All Phase 36 behaviors have automated verification. Visual/commercial naturalness review is explicitly outside this phase and cannot substitute for decoded ROI evidence.

## Validation Sign-Off

- [x] All tasks have `<automated>` verification or satisfied Wave 0 dependencies.
- [x] Sampling continuity: no 3 consecutive tasks without automated verification.
- [x] Wave 0 covers all helper references and negative paths.
- [x] No watch-mode flags.
- [x] Feedback latency remained below 5 minutes.
- [x] `nyquist_compliant: true` was set only after the final post-documentation focused/full SwiftPM and clean renderer/helper/gallery rerun passed.

**Approval:** passed. The final post-documentation rerun observed 10/10 focused and 220/220 full XCTest cases, 252/252 strict outputs, 252 gallery files, 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, 2/2 no-face, containment, no-promotion, schema-drift, and diff-hygiene gates.
