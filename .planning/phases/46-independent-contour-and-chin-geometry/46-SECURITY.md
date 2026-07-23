---
phase: 46
slug: independent-contour-and-chin-geometry
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
created: 2026-07-23
---

# Phase 46 — Security

> Per-phase security contract for consuming private observed face support in four package-internal geometry providers.

## Trust Boundaries

| Boundary | Description | Data Crossing |
|---|---|---|
| Public parameters → resolver | Four caller-controlled positive scalars are untrusted until normalized and capped. | Public scalar intent |
| Validated support → provider | Biometric-adjacent contour/median/apex evidence may authorize only its owning fields. | Request-local package values |
| Provider → conflict resolver | Only finite, renderable named emissions may enter the retained baseline. | Strengths and aggregate control points |
| Conflict resolver → renderer | Removed work must not re-enter, duplicate, or affect final evidence. | Final effective strengths |
| Internal geometry → facade diagnostics | Coordinates, semantic sources, indices, and provider details must not escape. | Fixed warnings and aggregate metrics |
| Repository → downstream feature status | Output evidence, final safety, and deferred tools must not be activated by Phase 46. | Source, ledger, renderer, and artifact state |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation / Evidence | Status |
|---|---|---|---|---|---|---|
| T-46-01 | Spoofing / Tampering | provider contracts | high | mitigate | Exact asymmetric source arrays, proxy-only negatives, named emissions, and shipped-array equality pass. | closed |
| T-46-02 | Information Disclosure / Tampering | boundary checker | high | mitigate | Classified fail-closed scans, pinned blobs, adversarial mutations, artifact/status gates, and 24/24 self-tests pass. | closed |
| T-46-03 | Tampering | resolver lifecycle | high | mitigate | Exact cap/trigger, contour/centerline/proxy, sibling, and provider-empty matrices pass. | closed |
| T-46-04 | Denial of Service | convergence contract | high | mitigate | One exact `0..<37` loop, subset-only retained baseline, equality termination, and source-level gate pass. | closed |
| T-46-05 | Repudiation / Tampering | conflict arithmetic | high | mitigate | Exact 37-row, 11.70 total, count 37, scale 1/11.70, and per-field once-only tests pass. | closed |
| T-46-06 | Tampering / Spoofing | degradation lifecycle | high | mitigate | Missing/malformed/provider-empty and fresh→reused→stale→fresh tests prove field-local, stateless behavior. | closed |
| T-46-07 | Information Disclosure | public facade | high | mitigate | Isolated facade requests expose preserved extent, fixed summaries, and aggregate metrics only; redaction scans pass. | closed |
| T-46-08 | Tampering / Repudiation | unified dispatch | high | mitigate | Exact final-provider concatenation and metric-to-point equality prevent omission or duplication. | closed |
| T-46-09 | Tampering / Denial of Service | provider math | high | mitigate | Fixed support ceilings, finite/unit preflight, O(n) contour work, bounded displacement/radius/falloff, and direct tests pass. | closed |
| T-46-10 | Spoofing | observed vs proxy support | high | mitigate | New helpers read only `observedFaceSupport`; the seven-point proxy remains exclusive to shipped fields. | closed |
| T-46-11 | Tampering | named ownership | high | mitigate | Exact 7+2 named arrays, per-field sanitization, disjoint sources, and shipped compatibility regressions pass. | closed |
| T-46-12 | Denial of Service | resolver convergence | high | mitigate | Retained fields only decrease across at most 37 passes; no recursive or unbounded retry path exists. | closed |
| T-46-13 | Tampering / Repudiation | final accounting | high | mitigate | All-provider pre/post sanitization plus exact total/count/scale/domain/point evidence derive from one retained set. | closed |
| T-46-14 | Information Disclosure | testing SPI / facade | high | mitigate | Deterministic support enters through the production mapper/adapter; no raw payload reaches the public result. | closed |
| T-46-15 | Tampering | freshness and eligibility | high | mitigate | No-face/stale zero, exact reused 0.5, local support failure, and no-carryover tests pass. | closed |
| T-46-16 | Repudiation | validation and owner docs | high | mitigate | Fresh exact command counts, clean review, 18/18 verification, completed Nyquist audit, and phase-range diff hygiene pass. | closed |
| T-46-17 | Information Disclosure | security/docs/diagnostics | high | mitigate | Package/public/SPI, Codable/persistence/cache, raw diagnostic, network/model/resource, and artifact scans pass. | closed |
| T-46-18 | Tampering / Elevation of Privilege | feature/status ledger | high | mitigate | Seven future rows, two partial branch rows, zero renderer cases, and explicit Phase 47/48 ownership pass the checker. | closed |
| T-46-SC | Tampering | package/dependency boundary | medium | mitigate | No install occurred; `Package.swift` git-blob hash remains `6f03b078816ad1f7a426e3f70d4f57503f3152e9`; no target/dependency/resource drift exists. | closed |

## Repository-Specific Governance Inputs

The three descriptor-less Plan 01 prohibitions were intentionally left unverified until this independent audit. They now have repository-scoped dispositions:

| Prohibition | Audit evidence | Status |
|---|---|---|
| Observed support must not become identity, recognition, authentication, or biometric-profiling data. | The carriers remain package-only, non-Codable, ephemeral values; consumers are limited to geometry validation/providers; active-source scans find no identity/auth/profile, persistence, cache, model, resource, dependency, or network path. | verified for current repository scope |
| The seven-point synthetic proxy must not be represented or consumed as observed support. | Providers read only `FaceGeometry.observedFaceSupport`; proxy-only fixtures produce empty new emissions; shipped compatibility arrays remain separate. | verified |
| Deferred double-chin, Pro, hairline, or branch-completion behavior must not be silently enabled. | The feature ledger retains the rows as `future`, both branch rows remain `partial`, and the checker finds no provider/model/resource/network/status/renderer activation. | verified |

These findings verify current repository behavior, not future host-app policy or external uses that do not exist in this source tree.

## Accepted Risks

No accepted risks. Provisional visual constants and downstream output/final-safety work are scoped product-validation deferrals, not open Phase 46 security threats.

## Security Audit 2026-07-23

| Metric | Count |
|---|---:|
| Threats registered | 19 |
| Closed | 19 |
| Open | 0 |
| Governance inputs resolved | 3 |

Fresh audit evidence:

- Phase 46 checker — **24/24 self-tests and 14/14 live checks passed**.
- Full SwiftPM verifier rerun — **368 executed, 3 opt-in Apple Vision skips, 0 failures**.
- Standard review — **clean after one documentation-whitespace fix**.
- Goal verification — **18/18**.
- Nyquist audit — **0 gaps**.
- Complete phase-range `git diff --check` — **passed**.

ASVS L1 short-circuit applies because the threat register was authored during planning, every registered threat has direct implementation/test/static evidence, all three flagged governance inputs received explicit repository-scoped dispositions, and `threats_open: 0` at the configured high blocking threshold.

## Sign-Off

- [x] Every registered threat has a disposition.
- [x] All high-severity threats are closed.
- [x] All flagged governance inputs have explicit evidence and scope.
- [x] No accepted risk is hidden.
- [x] `threats_open: 0` confirmed.
- [x] `status: verified` set in frontmatter.

**Approval:** verified — 2026-07-23
