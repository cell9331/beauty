---
phase: 75
slug: semantics-and-genuine-evidence-contract
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
created: 2026-08-22
---

# Phase 75 — Security

## Trust Boundaries

| Boundary | Sensitive crossing | Required control |
| --- | --- | --- |
| Research/contract → evaluator | Semantic labels and frozen rubric | Parse canonical records; reject proxy or post-result mutation. |
| Private bundle → local evaluator | Rights metadata and private fixture bindings | Require complete rights/category/hash admission; never copy bundle content into the repository. |
| Child process → durable evidence | Aggregate results and failures | Fixed path-free allowlist; reject sensitive keys and raw values. |
| Evidence mechanics → public SDK | Candidate authorization | Exact inventory and package/source boundary checks. |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation evidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T-75-01 | Tampering | Semantic contract | high | mitigate | Seven independent prohibited-proxy mutations pass. | closed |
| T-75-02 | Repudiation | Semantic tests | high | mitigate | Positive, negative, protected, and nonclaim predicates are executable. | closed |
| T-75-03 | Information Disclosure | Checker output | high | mitigate | Fixed IDs/counts only; privacy mutation is rejected. | closed |
| T-75-04 | Elevation of Privilege | Semantic authority | high | mitigate | Medical/landmark-only authorization fails closed. | closed |
| T-75-05 | Denial of Service | Evaluator/checker intake | high | mitigate | Missing, malformed, unknown-mode, and subprocess failures are typed and bounded. | closed |
| T-75-06 | Tampering | Public/package inventory | high | mitigate | Phase-close verification proved exact 61/5/74 and no activation. | closed |
| T-75-07 | Repudiation | Validation ownership | high | mitigate | Every Phase-75 task/threat has a command owner. | closed |
| T-75-08 | Information Disclosure | Child diagnostics | high | mitigate | Matched values, paths, and private identifiers are redacted. | closed |
| T-75-SC | Tampering | Dependency supply chain | high | accept | Phase 75 installs no package and changes no dependency. | closed |

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
| --- | --- | --- | --- | --- |
| AR-75-01 | T-75-SC | No package-manager or dependency operation exists in this phase, so no new supply-chain surface is introduced. | Project contract | 2026-08-22 |

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
| --- | ---: | ---: | ---: | --- |
| 2026-08-22 | 9 | 9 | 0 | autonomous inline ASVS-L1 audit |

## Sign-Off

- [x] All threats have a disposition.
- [x] Accepted risk is documented.
- [x] `threats_open: 0` confirmed.
- [x] Aggregate-only privacy and fail-closed authorization remain authoritative.

**Approval:** verified 2026-08-22
