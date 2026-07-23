---
phase: 47
slug: public-facade-face-output-evidence
status: planned
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-23
---

# Phase 47 — Validation Strategy

> Per-phase validation contract for decoded public-facade output, fixed face-local semantics, representative degradation, and ignored artifact containment.

## Test Infrastructure

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM; Python 3 standard library helper |
| Package | `BeautySDK/Package.swift` |
| Quick source command | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` |
| Quick facade command | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` |
| Helper command | `python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py --self-test` |
| Full suite | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |
| Feedback budget | Focused tasks under 120 seconds; render/full-suite at wave gates |

## Sampling Rate

- After renderer/test edits: focused source/no-face suite plus `git diff --check`.
- After testing-fixture/facade edits: focused facade suite plus Phase 46 live checker.
- After helper edits: self-test, `py_compile`, and diff hygiene.
- After matrix calibration: guarded clean render, measurement, freeze, second clean render, strict helper.
- After gallery/docs: generator self-test, one publication, exact containment scans.
- Before phase verification: focused/full SwiftPM, helper self/live, gallery bijection, privacy/scope/status/artifact checks, and complete phase-range diff hygiene.

## Requirement Verification Map

| Task ID | Planned behavior | Requirement | Threats | Automated command | File exists | Status |
|---|---|---|---|---|---|---|
| 47-W0-01 | exact four-case renderer/source inventory | OUT-01 | T-47-01, T-47-02 | focused renderer XCTest and exact 59 source count | existing to extend | ⬜ pending |
| 47-W0-02 | representative public degradation fixtures | OUT-03 | T-47-03, T-47-04 | focused facade XCTest and Phase 46 checker | existing to extend | ⬜ pending |
| 47-HELP-01 | bounded decoder/inventory/self-tests | OUT-02, OUT-03 | T-47-05, T-47-06 | helper `--self-test` plus `py_compile` | new | ⬜ pending |
| 47-OUT-01 | exact 413 same-dimension output matrix | OUT-01, OUT-02 | T-47-05, T-47-07 | clean renderer plus strict helper | new helper | ⬜ pending |
| 47-OUT-02 | fixed visibility/locality/independence | OUT-02 | T-47-07, T-47-08 | strict helper family gates | new helper | ⬜ pending |
| 47-OUT-03 | eligibility and no-face safe no-ops | OUT-02, OUT-03 | T-47-03, T-47-08 | strict helper plus facade XCTest | new/helper existing tests | ⬜ pending |
| 47-GAL-01 | descriptor-safe exact gallery bijection | OUT-03 | T-47-09, T-47-10 | generator self-test, publication, 413/count/ignore scans | existing to extend | ⬜ pending |
| 47-CLOSE-01 | full regression, privacy/scope, no-promotion | OUT-01, OUT-02, OUT-03 | T-47-11, T-47-SC | full SwiftPM, checker, helper, artifact/status/diff gates | planned | ⬜ pending |

## Exact Validation Matrices

### Renderer/source

- Ordered inventory is exactly 59 IDs with 55 existing IDs preserved.
- Each new snippet contains exactly one matching public field at `0.25`.
- No alias/combo/internal import/provider/adapter/raw-support/Demo/network path.
- Exactly one `engine.processResult(` call remains.

### Decoded output

- Seven regular committed fixtures and 59 cases imply exactly 413 expected PNGs.
- Every expected output is present, regular, non-empty, strictly decoded, and
  exactly the source dimensions.
- No unexpected output exists.

### Face-local semantics

- Four new cases cross fixed baseline visibility floors on every eligible
  portrait.
- Each crosses a fixed intended-region floor and locality rule.
- Smooth, temple, cheekbone, and taper each differ from their fixed nearest
  shipped/new comparators.
- Watermark-only and outside-region-only changes cannot pass.

### Representative degradation

- Four no-face requests preserve extent and are watermark-safe baseline no-ops
  with established aggregate degradation.
- Missing observed contour zeros all four new fields; shipped sibling remains.
- Malformed observed contour fails the same way through production validation.
- No raw contour/median/apex/coordinate/provider/path detail reaches results.

### Artifact containment

- Output and gallery each contain exactly 413 expected regular PNGs.
- Renderer IDs and gallery case groups are a duplicate-free exact set.
- Representative paths are ignored.
- Tracked, staged, and non-ignored-untracked generated artifacts are zero.
- Staging/quarantine state is absent after publication.

## Wave 0 Requirements

- [ ] Add exact four-case renderer inventory/source contract.
- [ ] Add no-face, missing-contour, and malformed-contour facade fixtures/tests.
- [ ] Create Phase 47 helper by adapting the latest bounded archived decoder.
- [ ] Add self-tests for path, decode, inventory, threshold, locality, and stale-output failures before live acceptance.

## Manual-Only Verifications

None for OUT-01 through OUT-03. Subjective naturalness, final cap calibration,
exhaustive transition/safety behavior, product promotion, device parity,
commercial review, performance, packaging, shipping, and launch readiness are
downstream or future scope rather than hidden manual Phase 47 gates.

## Sign-Off Conditions

- [ ] Every plan task has a focused automated command.
- [ ] Wave 0 contracts exist before accepting output.
- [ ] Helper self-tests fail closed on malformed and adversarial inputs.
- [ ] Measurement and strict acceptance use separate clean renders.
- [ ] Strict constants are fixed and non-dynamic.
- [ ] Full SwiftPM, gallery, privacy/scope, no-promotion, and diff gates pass.
- [ ] OUT-01 through OUT-03 have direct evidence.
- [ ] `nyquist_compliant: true` and `wave_0_complete: true` are set only after execution.

**Approval:** pending execution
