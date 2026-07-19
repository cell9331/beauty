---
phase: 43
slug: public-facade-eye-geometry-output-evidence
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-16
---

# Phase 43 — Validation Strategy

| Task | Wave | Requirements | Automated verification |
|---|---:|---|---|
| 43-01-01 | 1 | EYE-16 | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` and source inventory/diff checks |
| 43-01-02 | 1 | EYE-18 | focused renderer XCTest with eleven no-face requests and redaction/extent assertions |
| 43-02-01 | 2 | EYE-17 | helper `--self-test`, `python3 -m py_compile`, bounded decoder negative-path checks |
| 43-02-02 | 2 | EYE-17, EYE-18 | clean renderer build/run, measurement, frozen strict helper on exactly 385 outputs |
| 43-03-01 | 3 | EYE-18 | gallery self-test, one publication, exact 385-file bijection, ignore/tracked/staged scans |
| 43-03-02 | 3 | EYE-16..18 | focused/full SwiftPM, package-internal aggregate gaze evidence test, final strict helper, read-only gallery/containment/scope scans, `git diff --check` |

All six task rows passed on 2026-07-16; the post-phase gaze evidence fix additionally passes the focused provider aggregate test and helper adversarial self-tests. Focused renderer evidence is 13/13, full SwiftPM is 305/305 before the fix, the strict matrix is 385/385, gallery publication is 385/385, and helper/gallery negative-path self-tests pass.

## Wave 0 Requirements

- Phase-owned strict helper and self-tests exist before output calibration.
- Renderer/test source inventory and no-face tests cover all eleven new IDs.
- Eligibility inventory records contour, pupil/gaze, symmetry, neutral/ineligible, and no-face roles without raw geometry.

## Sign-Off

`nyquist_compliant: true` and `wave_0_complete: true` follow the final clean strict 385/385 run, 305/305 full suite, 385-file gallery containment, and scope gates. EYE-19..23 and DOC-01 remain deferred.
