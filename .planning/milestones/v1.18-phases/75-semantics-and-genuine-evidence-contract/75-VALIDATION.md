---
phase: 75
slug: semantics-and-genuine-evidence-contract
status: validated
nyquist_compliant: true
wave_0_complete: true
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SEM-01, SEM-02, EVID-01, EVID-02]
---

# Phase 75 — Validation Strategy

This map is the phase-owned command authority. A broad test suite never
substitutes for an isolated HIGH owner. The public SDK remains exactly absent:
the current inventory is 61 stored `BeautyParameters` fields, five preset
references, and 74 renderer cases.

## Test infrastructure

| Property | Value |
| --- | --- |
| Framework | Node built-in test and Python standard library |
| Private data | No real bundle supplied; self-tests use metadata-only records only |
| Durable output | Fixed IDs/counts, hashes, aggregate values, normalized reasons, decisions |
| Scope | `.planning/phases/75...` evidence artifacts; no Swift/package/resource changes |

## Per-task verification map

| Task ID | Plan | Wave | Requirements | Threat owner | Automated command | Status |
| --- | ---: | ---: | --- | --- | --- | --- |
| 75-01-01 | 01 | 1 | SEM-01, SEM-02 | T-75-01, T-75-02, T-75-04 | `node --test 75-semantics.contract.test.js` | green |
| 75-01-02 | 01 | 1 | SEM-01, SEM-02 | T-75-03, T-75-05, T-75-06, T-75-07, T-75-08, T-75-SC | `python3 check_phase75_semantics_evidence_boundaries.py --self-test --repo-root .` plus `--contract --absence` | green |
| 75-02-01 | 02 | 2 | EVID-01, EVID-02 | T-75-01, T-75-02, T-75-03, T-75-04 | `node --test 75-semantics.contract.test.js 75-rights-evidence.contract.test.js` | green |
| 75-02-02 | 02 | 2 | EVID-01, EVID-02 | T-75-03, T-75-05, T-75-08 | `node 75-private-evidence-evaluator.js --self-test` | green |
| 75-02-03 | 02 | 2 | EVID-01, EVID-02 | T-75-05, T-75-06, T-75-07 | explicit validate/aggregate/export, exact absence, and isolated T-75 modes | green |

## Isolated HIGH ownership

| Threat | Required isolated mode | Pass rule |
| --- | --- | --- |
| T-75-01 | `--threat T-75-01` | independent proxy mutation is rejected |
| T-75-02 | `--threat T-75-02` | semantic test predicates are present |
| T-75-03 | `--threat T-75-03` | checker output is path/private-value free |
| T-75-04 | `--threat T-75-04` | landmark authority mutation is rejected |
| T-75-05 | `--threat T-75-05` | malformed/missing input remains classified and nonzero |
| T-75-06 | `--threat T-75-06` | field inventory mutation is rejected |
| T-75-07 | `--threat T-75-07` | every task/threat has a command owner |
| T-75-08 | `--threat T-75-08` | child diagnostics remain normalized and path-free |
| T-75-SC | `--threat T-75-SC` | no package-manager or dependency path exists |

## Phase closeout commands

```text
node --check .planning/phases/75-semantics-and-genuine-evidence-contract/75-semantics.contract.test.js
node --test .planning/phases/75-semantics-and-genuine-evidence-contract/75-semantics.contract.test.js
node --test .planning/phases/75-semantics-and-genuine-evidence-contract/75-rights-evidence.contract.test.js
node .planning/phases/75-semantics-and-genuine-evidence-contract/75-private-evidence-evaluator.js --self-test --emit-manifest /private/tmp/beauty-phase75-metadata-only-manifest.json
node .planning/phases/75-semantics-and-genuine-evidence-contract/75-private-evidence-evaluator.js --validate --manifest /private/tmp/beauty-phase75-metadata-only-manifest.json
node .planning/phases/75-semantics-and-genuine-evidence-contract/75-private-evidence-evaluator.js --aggregate --manifest /private/tmp/beauty-phase75-metadata-only-manifest.json
node .planning/phases/75-semantics-and-genuine-evidence-contract/75-private-evidence-evaluator.js --export --manifest /private/tmp/beauty-phase75-metadata-only-manifest.json
python3 -m json.tool .planning/phases/75-semantics-and-genuine-evidence-contract/75-THREAT-INVENTORY.json
PYTHONPYCACHEPREFIX=/private/tmp/beauty-phase75-pycache python3 -m py_compile .planning/phases/75-semantics-and-genuine-evidence-contract/check_phase75_semantics_evidence_boundaries.py
python3 .planning/phases/75-semantics-and-genuine-evidence-contract/check_phase75_semantics_evidence_boundaries.py --self-test --repo-root .
python3 .planning/phases/75-semantics-and-genuine-evidence-contract/check_phase75_semantics_evidence_boundaries.py --contract --absence --repo-root .
for id in T-75-01 T-75-02 T-75-03 T-75-04 T-75-05 T-75-06 T-75-07 T-75-08 T-75-SC; do python3 .planning/phases/75-semantics-and-genuine-evidence-contract/check_phase75_semantics_evidence_boundaries.py --threat "$id" --repo-root .; done
git diff --check
```

## Evidence state

No rights-approved genuine positive/negative bundle is present in this
workspace. The automated admission contract is complete, but metadata-only
self-tests cannot establish genuine efficacy, naturalness, coverage, or a
productization claim.

The contract and evaluator requirements are nevertheless verified as
fail-closed infrastructure: incomplete or missing genuine evidence returns a
typed failure, while metadata-only self-tests return
`mechanics-only-not-promotion` and never authorize a public route.

## Validation Audit 2026-08-22

| Metric | Count |
| --- | ---: |
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

All four phase requirements map to green automated contract, mutation,
privacy, and exact-absence commands. Genuine quality remains a later
conditional product gate rather than a missing Phase-75 automation owner.
