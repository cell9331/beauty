---
phase: 52
slug: eyebrow-safety-and-branch-closeout
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-27
---

# Phase 52 — Validation Strategy

> Per-phase validation contract for final eyebrow safety, exact convergence, evidence-gated promotion, and milestone-audit handoff.

## Test Infrastructure

| Property | Value |
| --- | --- |
| **Framework** | XCTest via SwiftPM 6.3.3; Python 3.9 standard-library self-tests and static gates |
| **Config file** | `BeautySDK/Package.swift`; no new target or dependency |
| **Quick run command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` |
| **Full suite command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |
| **Static gate** | `python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py` |
| **Strict output gate** | Phase 51 helper against a guarded clean `example-images/output` render, without `--measure` |
| **Estimated runtime** | Focused feedback under 3 minutes; full/output closeout host-dependent |

## Exact Evidence Vocabulary

- Public inventory: exactly 59 stored fields, 58 numeric plus `filterId`.
- Eyebrow inventory: exactly seven named fields; six signed and one positive-only.
- Complete geometry inventory: exactly 44 fields = 9 face/chin + 14 eye + 7 eyebrow + 6 nose + 8 mouth.
- Final all-field arithmetic: exact unscaled total `13.45`, count/weakened count `44`, one scale `1 / 13.45`, and final total `1`.
- Output evidence remains the unchanged Phase 51 contract: 72 `e6` portrait outputs, thirteen separate no-face comparisons, and 144 total disposable two-fixture files.

## Sampling Rate

- **After every task commit:** Run the narrow owning XCTest suite or checker mode plus `git diff --check`.
- **After every plan wave:** Run all suites touched in that wave, checker self-test/live mode when available, and diff hygiene.
- **Before promotion:** Run all focused suites, full SwiftPM, guarded Phase 51 strict output/gallery/actual-image evidence, standard review, Nyquist audit, ASVS L1 audit, default checker, artifact scans, and diff hygiene.
- **Before `$gsd-verify-work`:** Full SwiftPM, unchanged strict output/gallery, post-promotion/owner/final checker modes, requirements/roadmap analysis, and artifact containment must be green.
- **Max normal focused feedback latency:** 180 seconds.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| 52-01-01 | 01 | 1 | SAFE-01 | T-52-01–02 | One final cap authority; exact dead-zone/cap adjacency, overflow, direction, count, warning, and metric semantics | unit | Safety-cap + resolver focused suites | ✅ extend | ⬜ pending |
| 52-01-02 | 01 | 1 | SAFE-01, SAFE-02 | T-52-01–04, T-52-07 | Seven-field finite/unit/radius and nil/single-side/missing/malformed/provider-empty matrix with no support fabrication | unit | Provider + degradation focused suites | ✅ extend | ⬜ pending |
| 52-01-03 | 01 | 1 | SAFE-02 | T-52-05–08 | Stateless complete lifecycle/transitions, parallel/interrupted isolation, safe siblings, unchanged extent, aggregate-only facade diagnostics | integration | Degradation + facade focused suites | ✅ extend | ⬜ pending |
| 52-02-01 | 02 | 2 | SAFE-01, SAFE-02 | T-52-09–10 | Exact 44-field inventory, 13.45/44/1÷13.45 arithmetic, threshold adjacency, and preserved signs | unit | Conflict + combined focused suites | ✅ extend | ⬜ pending |
| 52-02-02 | 02 | 2 | SAFE-02 | T-52-10–12 | At most 44 monotone removals; final effective/emission/metric/dispatch equality | unit + integration | Resolver + pipeline focused suites | ✅ extend | ⬜ pending |
| 52-03-01 | 03 | 3 | SAFE-03, DOC-01 | T-52-13–18, T-52-22–23, T-52-SC | Fail-closed pre/post-promotion, owner, privacy, dependency, artifact, concurrency/interruption, and lifecycle checker | static + adversarial | Checker compile + self-test + default live | ❌ Wave 0 | ⬜ pending |
| 52-03-02 | 03 | 3 | SAFE-01, SAFE-02, SAFE-03 | T-52-17–20, T-52-22 | Fresh runtime plus unchanged strict output/gallery, fourteen reopened images, and disposable artifact evidence | full + integration | Focused/full SwiftPM + guarded strict/gallery commands | ✅ reuse | ⬜ pending |
| 52-03-03 | 03 | 3 | SAFE-03 | T-52-19, T-52-21, T-52-23 | Clean standard review, fourteen-task Nyquist coverage, ASVS L1 zero-open precondition, and unchanged pre-promotion state | review + security | Review/security/validation artifact gates | ❌ Wave 3 | ⬜ pending |
| 52-04-01 | 04 | 4 | DOC-01 | T-52-24, T-52-26 | Fresh evidence reauthorizes only the exact eyebrow status transaction | static | Default checker + evidence/precondition gates | ❌ Wave 0 | ⬜ pending |
| 52-04-02 | 04 | 4 | DOC-01 | T-52-25–27 | Exactly seven rows and branch `眉毛` become implemented at SDK-core scope; all nonclaims preserved | docs/static | Post-promotion checker mode | ❌ Wave 0 | ⬜ pending |
| 52-05-01 | 05 | 5 | SAFE-03, DOC-01 | T-52-28 | Example owners retain exact 72/13/144 vocabulary, fourteen-file review, disposable artifacts, and final cap/safety result | docs/static | Example-owner checker mode + helper/gallery self-tests | ❌ Wave 0 | ⬜ pending |
| 52-05-02 | 05 | 5 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-29–30 | Routed root owners agree on caps, lifecycle, privacy, reliability, product, quality, and nonclaims | docs/static | Per-owner and aggregate owner checker modes | ❌ Wave 0 | ⬜ pending |
| 52-06-01 | 06 | 6 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-31–34 | Close exact requirements/plans only after executable evidence; independent audit remains pending | docs/static | Requirement/roadmap/state/plans checker modes | ❌ Wave 0 | ⬜ pending |
| 52-06-02 | 06 | 6 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-19, T-52-21, T-52-31–34 | Goal-backward verification and complete final gate hand off honestly to milestone audit | verify | Full final command bundle + final checker | ❌ Wave 6 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

## Wave 0 Requirements

- [ ] `check_eyebrow_safety_boundaries.py` — compose Phase 49/50 classified boundaries and add cap, convergence, promotion, owner, lifecycle, and adversarial command/path/status modes.
- [ ] `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift` — one shared typed seven-field cap/dead-zone/radius/lifecycle/local-failure descriptor consumed by existing safety/resolver/provider/degradation tests.
- [ ] Final Phase 52 late-removal/reused/mixed-sign rows in existing convergence/pipeline tests.
- [ ] `52-EYEBROW-SAFETY-EVIDENCE.md`, `52-SECURITY.md`, and `52-VERIFICATION.md` — created only when their owning waves obtain real evidence.

## Manual-Only Verifications

Commercial naturalness, physical-device parity, long-run performance, packaging, shipping, and launch readiness are outside Phase 52. The required fourteen-file actual-image review is inherited from Phase 51 and must be reconfirmed against the unchanged final-cap render before promotion; it supplements but does not replace the automated strict gate.

## Validation Sign-Off

- [ ] All tasks have `<automated>` verification or an explicit Wave 0 dependency.
- [ ] Sampling continuity: no three consecutive tasks lack automated verification.
- [ ] Wave 0 covers all missing references before dependent promotion tasks.
- [ ] No watch-mode flags.
- [ ] Normal focused feedback latency remains under 180 seconds.
- [ ] All SAFE/DOC requirements have automated coverage plus the inherited actual-image acceptance gate.
- [ ] `nyquist_compliant: true` is set only after every task row has fresh evidence.

**Approval:** pending execution.
