---
phase: 78
slug: genuine-evaluation-and-candidate-decision
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: false
created: 2026-08-22
---

# Phase 78 — Security

This register was reconstructed retroactively from the decision gate, plans,
tests, evaluator contract, and mutation checker.

## Trust Boundaries

| Boundary | Sensitive crossing | Required control |
| --- | --- | --- |
| Private manifest → Phase-75 evaluator | Rights/category/hash metadata | Frozen fail-closed admission remains authoritative. |
| Evaluator → candidate gate | Aggregate decision data | Metadata-only evidence cannot receive genuine efficacy weight. |
| Optional comparator → decision | Model/data rights and additive output claims | Exact rights, bounded-map, all-safety, and superiority gates. |
| Decision → durable evidence/public branch | Aggregate report and authorization | Privacy allowlist and a single non-bypassable recommendation. |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation evidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T-78-01 | Elevation of Privilege | Missing-bundle guard | high | mitigate | Missing evidence remains typed and cannot promote. | closed |
| T-78-02 | Elevation of Privilege | Mechanics classification | high | mitigate | Metadata-only promotion mutation is rejected. | closed |
| T-78-03 | Spoofing | Comparator model rights | high | mitigate | Exact approval is required. | closed |
| T-78-04 | Spoofing | Comparator data rights | high | mitigate | Exact approval is required. | closed |
| T-78-05 | Tampering | Comparator output shape | high | mitigate | Only bounded additive maps are admissible. | closed |
| T-78-06 | Tampering | Safety gate set | high | mitigate | Every frozen safety gate is mandatory. | closed |
| T-78-07 | Information Disclosure | Durable report | high | mitigate | Sensitive key/value and path leakage mutations fail. | closed |
| T-78-08 | Elevation of Privilege | Recommendation | high | mitigate | `mechanics-only-not-promotion` replacement is rejected. | closed |

## Accepted Risks Log

No accepted risks. Missing genuine evidence is a product gate failure, not an
accepted security bypass.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
| --- | ---: | ---: | ---: | --- |
| 2026-08-22 | 8 | 8 | 0 | autonomous retroactive STRIDE ASVS-L1 audit |

## Sign-Off

- [x] Retroactive STRIDE register covers every Phase-78 mutation owner.
- [x] All threats have a disposition.
- [x] `threats_open: 0` confirmed.

**Approval:** verified 2026-08-22
