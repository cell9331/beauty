---
phase: 39
slug: public-facade-mouth-geometry-output-evidence
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-14
---

# Phase 39 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Swift XCTest through Swift Package Manager plus Python 3 standard library |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | ~15 seconds focused; ~45 seconds full; renderer matrix ~2 minutes |

## Sampling Rate

- **After every task commit:** Run the narrowest focused XCTest or helper self-test named by the task.
- **After every plan wave:** Run focused tests plus `git diff --check`; run the full suite after the generated-output wave and at closeout.
- **Before phase verification:** A fresh guarded 44 × 7 render, strict helper, read-only gallery validation, full SwiftPM suite, containment scans, and no-promotion scans must be green.
- **Max feedback latency:** 60 seconds for focused source/helper checks; generated matrix work is an explicit longer evidence gate.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 39-01-01 | 01 | 1 | MOUTH-09 | T-39-01 | Exact isolated public cases cannot bypass the facade or alias another field | contract | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | ✅ | ⬜ pending |
| 39-01-02 | 01 | 1 | MOUTH-11 | T-39-02 | Representative no-face output preserves extent and aggregate-only diagnostics | integration | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | ✅ | ⬜ pending |
| 39-02-01 | 02 | 2 | MOUTH-10, MOUTH-11 | T-39-03 | Untrusted image/output files are bounded, strictly decoded, and cannot satisfy stale or watermark-only evidence | helper | `python3 check_mouth_remaining_renderer_outputs.py --self-test` | ❌ W0 | ⬜ pending |
| 39-02-02 | 02 | 2 | MOUTH-09..11 | T-39-03 | Acceptance uses frozen ROI/floors on a fresh exact matrix | end-to-end | guarded renderer build/run plus strict helper | ❌ W0 | ⬜ pending |
| 39-03-01 | 03 | 3 | MOUTH-11 | T-39-04 | Gallery routes are exact, descriptor-anchored, ignored, and untracked | integration | gallery self-test, one publication, exact 308 read-only count/bijection checks | ✅ | ⬜ pending |
| 39-03-02 | 03 | 3 | MOUTH-09..11 | T-39-01..05 | Final claims match fresh evidence and Phase 40 promotion owners remain untouched | regression/structural | focused/full tests, strict helper, containment, scope and diff gates | ✅ | ⬜ pending |

## Wave 0 Requirements

- [ ] `check_mouth_remaining_renderer_outputs.py` — Phase-owned self-contained strict matrix/ROI/no-face helper with deterministic self-tests.
- [ ] `39-MOUTH-OUTPUT-EVIDENCE.md` — aggregate-only observed calibration and accepting-run record.

Existing SwiftPM targets, committed fixtures, renderer, gallery generator, and regression suite cover every other dependency; no new framework or package is required.

## Manual-Only Verifications

All Phase 39 requirements have automated public-facade, decoded-output, direction, independence, no-face, gallery, and containment checks. Subjective naturalness, device parity, and commercial review are deliberately outside this phase.

## Validation Sign-Off

- [ ] All tasks have automated verification.
- [ ] Sampling continuity: no three consecutive tasks lack automated verification.
- [ ] Wave 0 helper/evidence dependencies exist and pass.
- [x] No watch-mode flags.
- [ ] Focused feedback latency stays below 60 seconds.
- [ ] `nyquist_compliant: true` set only after the final accepting rerun.

**Approval:** approved 2026-07-14 for planning; final sign-off pending execution evidence.
