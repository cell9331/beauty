---
phase: 61
slug: teeth-output-safety-and-independent-closeout
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-07
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [TEETH-15, TEETH-16]
---

# Phase 61 - Validation Strategy

Phase 61 validates saved public-facade teeth output, adversarial protected
identity, genuine original-detail naturalness, and exact promotion. It does not
activate the Demo or authorize sclera/upper-eyelid work.

## Test infrastructure

| Property | Value |
| --- | --- |
| Frameworks | XCTest / SwiftPM, standard-library Python and Node, Xcode Demo tests |
| Quick command | `python3 .planning/phases/61-teeth-output-safety-and-independent-closeout/check_phase61_teeth_closeout.py --self-test` |
| Focused command | `swift test --package-path BeautySDK --filter TeethWhitening` plus renderer regression |
| Full command | `swift test --package-path BeautySDK` and explicit iOS Simulator build/test |
| Private command | Phase 61 fixed-output runner with required-local-evidence mode |

## Per-task verification map

| Task ID | Plan | Wave | Requirement | Threat ref | Automated evidence | Status |
| --- | --- | ---: | --- | --- | --- | --- |
| 61-01-01 | 01 | 1 | TEETH-15 | T-61-01, T-61-02 | Exact 73-case/public-only/six-output contracts; 18/18 helper self-tests; expected renderer RED on missing production case/flag | executed |
| 61-01-02 | 01 | 1 | TEETH-16 | T-61-03–T-61-08 | Six adversarial/recovery tests; 8/8 checker mutations; default pre-promotion live pass | executed |
| 61-02-01 | 02 | 2 | TEETH-15 | T-61-01 | Renderer case, no-watermark mode, exact regression suites | pending |
| 61-02-02 | 02 | 2 | TEETH-15 | T-61-02, T-61-06 | Private runner, strict six-output live pass, artifact/privacy checks | pending |
| 61-03-01 | 03 | 3 | TEETH-16 | T-61-03, T-61-04 | Geometry perturbation, recolored protected output, recovery suites | pending |
| 61-03-02 | 03 | 3 | TEETH-16 | T-61-05, T-61-06 | Genuine strict metrics, blinded original-detail review, fixed evidence | pending |
| 61-04-01 | 04 | 4 | TEETH-16 | T-61-06–T-61-08 | Pre-promotion full conjunction and exact atomic owner update | pending |
| 61-04-02 | 04 | 4 | TEETH-15, TEETH-16 | T-61-01–T-61-08 | Post-promotion checker, full regression, independent verification | pending |

Task count equality target: **8 plan task IDs = 8 validation rows**.

## Required final gates

1. Exact 73 renderer cases with one `teethWhitening_1p00` public-only case and
   compatible default watermark behavior.
2. Strict helper self-test and fresh private six-output run; required local
   evidence cannot skip.
3. Positive target improvement; negative/no-face no-op; exact dimensions,
   alpha, reviewed-mask exterior, protected tissue, and artifact containment.
4. Color-independent geometry and recolored final-output matrices plus
   valid-invalid-valid and parallel recovery.
5. Fresh original-detail agent review with fixed verdicts and no post-review
   tuning.
6. Checker self-test/live/isolated `T-61-01` through `T-61-08`, zero open HIGH.
7. Exact 60 fields, five presets, disabled Demo, no sclera/upper-eyelid/model/
   network/realtime path, tracked/staged privacy, and diff hygiene.
8. Full SwiftPM and explicit iPhone 17e / iOS 26.5 Demo build/test before and
   after promotion.
9. Exact product-owner promotion and separate post-promotion independent
   verification with TEETH-15/16 complete before Phase 62.

No broad suite substitutes for missing private output, exact containment,
original-detail review, isolated HIGH disposition, or post-promotion verification.

## Manual-only verification

| Behavior | Requirement | Why manual | Instructions |
| --- | --- | --- | --- |
| Genuine result remains visibly natural | TEETH-16 | Texture, shading, edge quality, and residual color need image judgment beyond aggregate pixels. | Open the fresh blinded positive and negative baseline/active files at original detail, record fixed categorical verdicts before revealing roles, and block on contradiction. |

## Nonclaims

Passing Phase 61 means the still-image SDK-core teeth slice is independently
complete. It does not claim population validation, realtime support, device
performance, commercial readiness, packaging, shipping, launch, sclera output,
or upper-eyelid fullness reduction.
