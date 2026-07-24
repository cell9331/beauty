---
phase: 45
slug: public-contract-and-observed-face-support
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
created: 2026-07-23
---

# Phase 45 — Security

> Per-phase security contract for the compatibility-safe public scalar expansion and private observed face-support pipeline.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Host input → `BeautyParameters` | Public floats and decoded JSON are untrusted until normalized. | Public scalar values and legacy payloads |
| Vision → detector mapping | Contour and median landmark arrays are biometric-adjacent, optional, and untrusted. | Raw normalized point arrays |
| Detector → effects adapter | Mapped points remain untrusted until face-specific topology and cross-support validation pass. | Request-local package values |
| Observed support → shipped geometry | Observed evidence must remain separate from the synthetic seven-point compatibility proxy. | Validated contour/median eligibility |
| Implementation → diagnostics/docs | Coordinates, bounds, semantic indices, or overstated guarantees must not escape. | Aggregate-only counts and fixed reasons |
| Repository/tool output → closeout | Tool errors, missing paths, drift, and unclassified matches must fail closed. | Source scans, hashes, test outcomes |

---

## Threat Register

The plans did not assign per-row severity. This audit conservatively classifies every registered threat at the configured `high` blocking threshold; each therefore required executable closure evidence.

| Threat ID | Category | Component | Severity | Disposition | Mitigation / Evidence | Status |
|-----------|----------|-----------|----------|-------------|-----------------------|--------|
| T-45-01 | Repudiation | boundary checker | high | mitigate | Fail-closed classifications and adversarial branches; checker self-test passes 36/36. | closed |
| T-45-02 | Information Disclosure | observed support types | high | mitigate | Package/internal, non-Codable carriers with aggregate-only descriptions/reflection; privacy tests pass. | closed |
| T-45-03 | Spoofing | synthetic proxy provenance | high | mitigate | Separate proxy and observed-support properties/types plus exact seven-point compatibility tests. | closed |
| T-45-04 | Tampering | deferred semantic scope | high | mitigate | Boundary checker blocks dependency/model/resource/network/semantic drift. | closed |
| T-45-05 | Tampering | public construction/decode | high | mitigate | Finite positive-only normalization and exact negative/overflow/non-finite tests. | closed |
| T-45-06 | Spoofing | independent field storage | high | mitigate | Unequal 52-key round trip and exact inventory/label tests prevent aliasing. | closed |
| T-45-07 | Denial of Service | legacy/preset decode | high | mitigate | Missing-key zero defaults, unchanged bounded decode paths, and fixed preset hashes. | closed |
| T-45-08 | Elevation of Privilege | premature activation | high | mitigate | Resolver/provider neutrality tests and active-source checks prove no Phase 45 routing. | closed |
| T-45-09 | Tampering / DoS | raw contour/median arrays | high | mitigate | Count ceilings and finite/unit/cardinality checks run before mapping with field-local rejection. | closed |
| T-45-10 | Tampering | canonical orientation | high | mitigate | Mapper-derived axes, whole-array reversal only, and full orientation/mirror tests. | closed |
| T-45-11 | Information Disclosure | provider/summary output | high | mitigate | Immediate value copy, no retained Vision region, and aggregate-only diagnostic tests. | closed |
| T-45-12 | Repudiation | exactly-once mapping | high | mitigate | One landmarks request, one call-local mapper path, and repeated/concurrent lifecycle tests. | closed |
| T-45-13 | Tampering / DoS | adapter topology | high | mitigate | Fixed counts, finite/unit/unique/open-path predicates, derived-math guards, and exact boundaries. | closed |
| T-45-14 | Spoofing | legacy proxy provenance | high | mitigate | No fallback from synthetic proxy into observed support; exact isolation tests pass. | closed |
| T-45-15 | Tampering | side/apex consistency | high | mitigate | Chord, direction, apex, interior, side-distribution, and self-intersection validation. | closed |
| T-45-16 | Information Disclosure | derived semantic support | high | mitigate | Immutable package values, redacted reflection/descriptions, and active-source scans. | closed |
| T-45-17 | Repudiation | stale/cross-request support | high | mitigate | Pure adapter and valid→invalid→valid plus retained-prior-result lifecycle tests. | closed |
| T-45-18 | Spoofing | proxy/observed documentation | high | mitigate | Owner docs state provenance and the live checker/test suite blocks substitution. | closed |
| T-45-19 | Information Disclosure | docs/logs/evidence | high | mitigate | Only fixed reasons, counts, and ranges are recorded; raw-coordinate scans pass. | closed |
| T-45-20 | Tampering / DoS | checker and oversized input | high | mitigate | Checker self/live modes, fixed ceilings, focused boundary suites, and full regression suite pass. | closed |
| T-45-21 | Repudiation | validation closeout | high | mitigate | Exact commands/results are recorded; independent verification passes 20/20. | closed |
| T-45-22 | Elevation of Privilege | public/dependency/model/network scope | high | mitigate | Baseline and active-source scans block unauthorized surface or dependency expansion. | closed |
| T-45-SC | Tampering | supply chain / semantic fallback | high | mitigate | No install/manifest/resource/provider drift; checker live mode passes 13/13. | closed |

---

## Accepted Risks Log

No accepted risks. All 23 plan-time threats have implemented and verified mitigations.

---

## Security Audit 2026-07-23

| Metric | Count |
|--------|-------|
| Threats found | 23 |
| Closed | 23 |
| Open | 0 |

ASVS L1 short-circuit applies because the register was authored during planning, every registered threat has direct implementation or test evidence, `threats_open: 0`, and the configured blocking threshold is `high`. Fresh closeout evidence is recorded in `45-VERIFICATION.md`: boundary checker 36/36 self-tests and 13/13 live checks, full SwiftPM 354 executed / 3 opt-in skips / 0 failures, opt-in Vision suites with zero skips, and no human-only gap.

---

## Sign-Off

- [x] All threats have a disposition.
- [x] Accepted risks are explicitly absent.
- [x] `threats_open: 0` confirmed at the configured high threshold.
- [x] `status: verified` set in frontmatter.

**Approval:** verified — 2026-07-23
