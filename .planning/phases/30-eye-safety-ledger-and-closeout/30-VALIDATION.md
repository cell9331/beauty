---
phase: 30
slug: eye-safety-ledger-and-closeout
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-10
---

# Phase 30 — Validation Strategy

> Per-phase validation contract for eye input semantics, eye-specific geometry degradation, combined weakening, active-source boundaries, and atomic ledger promotion.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, `BeautyExampleRenderer`, the Phase 29 Python helper, focused `rg` scans, git artifact/ledger guards, and GSD coverage checks |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | Run the narrowest changed suites from `BeautyParametersTests`, `BeautyEffectResolverTests`, `EyeWarpProviderTests`, `MissingLandmarkDegradationTests`, `CombinedEffectSafetyTests`, and `BeautyEngineGeometryFacadeTests`, followed by the relevant static scan and scoped `git diff --check`. |
| **Full suite command** | `swift test --package-path BeautySDK`; `swift build --package-path BeautySDK --product BeautyExampleRenderer`; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output`; `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` |
| **Estimated runtime** | Under 5 minutes for changed focused suites and scans; under 30 minutes for the full phase gate |

## Sampling Rate

- **After every task commit:** Run the narrowest changed-surface XCTest filter, relevant active-source or ledger guard, and scoped `git diff --check`.
- **After every plan wave:** Run every focused suite touched by the wave and all boundary checks relevant to that wave.
- **Before evidence is marked passed:** Run the full SDK suite, renderer build/run, Phase 29 helper, ignored/generated-artifact guards, EYE-07 active-source scans, redaction/no-overclaim scans, and GSD coverage checks.
- **Before ledger promotion:** Require passing/clean/verified Phase 30 verification, validation, review, and security artifacts.
- **After ledger promotion:** Rerun the exact four-row/branch-partial guards, requirement/decision coverage, no-overclaim scan, and scoped `git diff --check`.
- **Max feedback latency:** 30 minutes.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 30-01-01 | 01 | 1 | EYE-04 | T-30-01 | `eyeSize` and `eyeTailLift` normalize negative/non-finite input to zero; `eyeDistance` and `eyeYPosition` preserve signed finite direction. | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | Existing suite; exact Phase 30 matrix missing | ⬜ pending |
| 30-01-02 | 01 | 1 | EYE-04 | T-30-01 | Each eye field has exact effective cap/direction, `beauty_strength_capped`, and exact capped-count evidence without spurious missing-eye warnings. | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` | Existing suite; exact per-field matrix missing | ⬜ pending |
| 30-02-01 | 02 | 2 | EYE-05 | T-30-02, T-30-03, T-30-04 | Missing either eye, reused eye geometry, and stale eye geometry skip the whole eye domain, zero all four effective strengths, emit distinct redacted reasons, and preserve unrelated safe domains. | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests`; `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | Existing suites; right-eye/zeroing/distinct-reason assertions missing | ⬜ pending |
| 30-02-02 | 02 | 2 | EYE-05 | T-30-02, T-30-04 | Public no-face eye requests preserve output extent, continue safe color/filter work, and expose aggregate redacted metadata only. | integration | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | Existing suite; eye-specific case missing | ⬜ pending |
| 30-02-03 | 02 | 2 | EYE-06 | T-30-01 | Six visible eye behaviors plus one all-eye multi-domain case are weakened through the existing conflict resolver while signed directions are preserved. | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` | Existing suite; seven required cases missing | ⬜ pending |
| 30-03-01 | 03 | 3 | EYE-04, EYE-05, EYE-06 | T-30-01, T-30-02, T-30-03, T-30-04 | Focused and full suites pass, and Phase 29 visible-output evidence remains exactly 161/161 outputs and 36/36 comparisons before promotion. | integration/regression | Full SDK suite; renderer build/run; Phase 29 helper | Existing infrastructure; Phase 30 evidence artifact missing | ⬜ pending |
| 30-03-02 | 03 | 3 | EYE-07 | T-30-04, T-30-05, T-30-08 | Active source exposes no raw public/SPI geometry, forbidden internal imports, network/cloud behavior, commercial entitlement path, new public eye field, or tracked generated PNG. | static/security | Active-source `rg` scans, 31-field inventory test, `git ls-files example-images/output example-images/gallery` | Existing patterns; Phase 30 results missing | ⬜ pending |
| 30-04-01 | 04 | 4 | EYE-08 | T-30-06, T-30-07 | Exactly `大小`, `上下`, `眼距`, and `眼尾上扬` promote together only after every gate; no other eye row promotes and branch-level `眼睛` stays `partial`. | doc/static guard | Exact ledger row-name/count guard and `FEATURE_MATRIX.md` branch guard | Rows currently partial; promotion guards missing | ⬜ pending |
| 30-04-02 | 04 | 4 | DOC-01 | T-30-04, T-30-07 | Owning contracts and planning ledgers cite command-backed evidence and retain privacy, device, commercial, parity, and whole-branch non-claims. | doc/GSD coverage | No-overclaim/redaction scans, EYE/DOC traceability, D-01–D-21 coverage, scoped `git diff --check` | Phase 30 closeout artifacts missing | ⬜ pending |

## Wave 0 Requirements

- [ ] Add the exact four-field public normalization and finite/non-finite matrix.
- [ ] Add the exact per-field cap/direction/warning/capped-count resolver matrix.
- [ ] Prove negative size/tail values are no-ops without missing-eye warnings or unnecessary detection intent.
- [ ] Add missing-right-eye provider fixture/test coverage.
- [ ] Add missing-eye resolver zero-all-strengths and unaffected-domain continuation assertions.
- [ ] Replace reused-eye reduction expectations with skip/zero/no-point assertions while retaining non-eye reuse regression coverage.
- [ ] Add stale-eye distinct-reason and zero-all-strengths assertions.
- [ ] Add the eye-specific public-facade no-face test.
- [ ] Add six per-behavior combined-weakening cases and one all-eye multi-domain warning/metric case.
- [ ] Create Phase 30 evidence, review, security, verification, and final validation artifacts during execution.
- [ ] Capture and classify active-source EYE-07 scan results.
- [ ] Add atomic four-row promotion and branch-partial guards.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Evidence wording review | EYE-08, DOC-01 | Automated scans constrain known overclaims, but a human wording pass is needed to keep four-row completion distinct from whole-branch, commercial-quality, device-parity, broad-reference-parity, or launch-readiness claims. | Review every touched root, blueprint, planning, evidence, review, security, and verification artifact after automated gates pass; record only observed commands, counts, results, limitations, and ownership-based contract changes. |
| Demo build/test | EYE-07, DOC-01 | No Demo behavior is in scope unless an executor unexpectedly edits Demo source. | If Demo source is unchanged, record that no Demo build was required and run the internal-import/commercial/network scans. If Demo source changes, run the explicit simulator build from `AGENTS.md`. |

## Validation Sign-Off

- [ ] All tasks have automated verification or an explicit manual-only rationale.
- [ ] Sampling continuity: no three consecutive tasks proceed without automated verification.
- [ ] Wave 0 gaps are implemented and passing.
- [ ] No watch-mode flags are used.
- [ ] Feedback latency remains below 30 minutes.
- [ ] `nyquist_compliant: true` is set after final evidence passes.

**Approval:** Pending Phase 30 implementation and command-backed evidence.
