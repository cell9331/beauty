---
phase: 76
slug: per-eye-semantic-support-ownership
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
created: 2026-08-22
---

# Phase 76 — Security

## Trust Boundaries

| Boundary | Sensitive crossing | Required control |
| --- | --- | --- |
| Vision observation → semantic owner | Face-derived mapped geometry | One immutable observation; landmarks constrain envelopes but never authorize semantics. |
| Left eye ↔ right eye | Independent support/confidence/mask outcomes | Separate state and typed source-exact rejection. |
| Support → composition | Request-local pixel ownership | Finite, unique, contained indices; overlap returns immutable source. |
| Request data → diagnostics | Masks, landmarks, coordinates, fixture details | Package-only non-Codable carriers and aggregate-only reflection. |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation evidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T-76-01 | Tampering | Observation reuse | high | mitigate | One provider and owner call; selected identity reuse is tested. | closed |
| T-76-02 | Elevation of Privilege | Eye-side ownership | high | mitigate | Peer authorization/suppression mutations fail. | closed |
| T-76-03 | Elevation of Privilege | Semantic approval | high | mitigate | Provider-owned approval is mandatory. | closed |
| T-76-04 | Tampering | Rejection fallback | high | mitigate | Every rejected eye is typed `.sourceExactNoOp`. | closed |
| T-76-05 | Denial of Service | Support dimensions/indices | high | mitigate | Finite, bounds, uniqueness, confidence, and containment checks pass. | closed |
| T-76-06 | Tampering | Coordinate mapping | high | mitigate | Existing mapper remains the only orientation/mirror conversion owner. | closed |
| T-76-07 | Tampering | Composition overlap | high | mitigate | Overlap returns source and records one aggregate collision. | closed |
| T-76-08 | Information Disclosure | Diagnostics | high | mitigate | Raw support/path leakage mutation is rejected. | closed |

## Accepted Risks Log

No accepted risks.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
| --- | ---: | ---: | ---: | --- |
| 2026-08-22 | 8 | 8 | 0 | autonomous inline ASVS-L1 audit |

## Sign-Off

- [x] All threats have a disposition.
- [x] `threats_open: 0` confirmed.
- [x] Raw masks, landmarks, coordinates, and fixture details remain non-persistent.

**Approval:** verified 2026-08-22
