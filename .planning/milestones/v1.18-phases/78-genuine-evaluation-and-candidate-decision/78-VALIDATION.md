---
phase: 78-genuine-evaluation-and-candidate-decision
status: validated
nyquist_compliant: false
wave_0_complete: true
requirements: [ALG-02, QUAL-01, QUAL-02]
---

# Phase 78 Validation Record

## Plan task coverage

- `78-01-01`: Phase-75-integrated aggregate candidate decision gate.
- `78-01-02`: missing, metadata-only, rights, comparator, frozen-review, and
  privacy tests.
- `78-02-01`: standard-library live and mutation boundary checker.
- `78-02-02`: archive-first SDK and no-skip closeout.

## Threat and mutation coverage

| ID | Boundary |
| --- | --- |
| T-78-01 | Missing-bundle guard cannot be bypassed |
| T-78-02 | Metadata-only mechanics cannot become promotion |
| T-78-03 | Model-rights approval is required |
| T-78-04 | Data-rights approval is required |
| T-78-05 | Comparator must remain a bounded additive map |
| T-78-06 | Comparator must pass every safety gate |
| T-78-07 | Durable output privacy check cannot be removed |
| T-78-08 | Mechanics-only decision cannot be replaced by promotion |

## Executed evidence

- `node --check .planning/phases/78-genuine-evaluation-and-candidate-decision/78-candidate-decision.js`: passed.
- `node --test .planning/phases/78-genuine-evaluation-and-candidate-decision/78-candidate-decision.test.js`: 6 executed, 0 failures, 0 skips.
- `node .planning/phases/78-genuine-evaluation-and-candidate-decision/78-candidate-decision.js --self-test`: 12 checks, 8 mutation rejections, `mechanics-only-not-promotion`.
- `python3 .planning/phases/78-genuine-evaluation-and-candidate-decision/check_phase78_candidate_boundaries.py --self-test --repo-root .`: 8/8 mutation rejections.
- `python3 .planning/phases/78-genuine-evaluation-and-candidate-decision/check_phase78_candidate_boundaries.py --live --repo-root .`: passed after closeout artifacts were written.
- Full no-skip result is recorded as `797/0/0` (executed/failures/skips).
- `bash scripts/run-no-skip-swiftpm.sh`: 797 executed, 0 failures, 0 skips; all archive, boundary, oracle, opt-in, and consumer gates passed.
- `git diff --check`: passed.

## Decision

No rights-approved private genuine bundle is present. The evaluator therefore
returns one aggregate recommendation: `mechanics-only-not-promotion`. The
deterministic editor remains a mechanics-only baseline, and the optional
additive comparator is `not-admitted`. ALG-02, QUAL-01, and QUAL-02 remain
pending genuine evidence; generated mechanics do not receive efficacy weight.

No raw pixels, masks, landmarks, private locators, reviewer prose, or private
fixture files were added to the repository.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
| --- | --- | --- | --- |
| Genuine positive efficacy and blinded original-detail review | QUAL-01 | Requires a complete rights-approved private genuine bundle and independent blinded reviewers; no such bundle was supplied. | Supply the private bundle outside the repository and run the frozen Phase-75 evaluator/review protocol. |
| Genuine negative/no-op quality over ambiguity, pose, occlusion, and eye-state cases | QUAL-02 | Generated fixtures prove mechanics only and cannot substitute for the required private genuine cases. | Run the same frozen evaluator against the complete negative/stress categories and retain aggregate-only output. |

## Validation Audit 2026-08-22

| Metric | Count |
| --- | ---: |
| Gaps found | 2 |
| Resolved | 0 |
| Escalated | 2 |

ALG-02 is automated and green. QUAL-01/02 remain intentionally unsatisfied
manual evidence gates and select `mechanics-only-not-promotion`; no test or
fixture was fabricated to turn them green.
