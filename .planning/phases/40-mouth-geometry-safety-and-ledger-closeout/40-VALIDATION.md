---
phase: 40
status: complete
nyquist_compliant: true
requirements: [MOUTH-12, MOUTH-13, MOUTH-14, MOUTH-15, MOUTH-16, DOC-01]
---

# Phase 40 Validation Strategy

| Plan | Requirement | Automated evidence | Status |
| --- | --- | --- | --- |
| 40-01 | MOUTH-12 | cap/resolver/provider/degradation/facade focused suites | passed |
| 40-01 | MOUTH-13 | eight-field support/freshness/provider/transition tables | passed |
| 40-02 | MOUTH-14 | exact combined/conflict/degradation/provider suites | passed |
| 40-03 | MOUTH-15 | 63/63 self-tested active-source checker, 265/265 SwiftPM, 308/308 renderer, artifact gates | passed |
| 40-04 | MOUTH-16 | exact promotion assertions and allow-promotion boundary run | pending until Plan 40-04 |
| 40-04 | DOC-01 | owner-consistency checker, full tests, verification/security/review artifacts | pending until Plan 40-04 |

No manual-only requirement is expected. Device/commercial visual validation is explicitly outside this phase and is not a substitute for any automated gate.

## Nyquist Sign-Off

Plans 40-01 through 40-03 are fully automated and green. Plan 40-04 has deterministic allow-promotion and owner-consistency commands prepared; its two rows become passed only in the final transaction. There are no manual-only gaps.


## Blocking Gates

- Every selected XCTest command must execute a nonzero test count with zero failures.
- Full SwiftPM and unchanged Phase 39 strict output evidence must pass.
- Boundary checker self-test, pre-promotion live mode, and post-promotion allow mode must pass.
- Review must be clean; Security must report `threats_open: 0`.
- Generated output/gallery files remain ignored, untracked, and unstaged.
