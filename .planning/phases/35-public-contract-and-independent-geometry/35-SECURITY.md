---
phase: 35
review: ASVS L1
threats_open: 0
---

# Phase 35 Security Review

## Scope and Blocking Rule

The ASVS L1 review covers the public-model compatibility boundary, biometric-adjacent package-internal geometry, malformed input handling, public diagnostics, dependencies/external paths, evidence integrity, and product-status honesty. Any open high-severity item blocks Phase 35 immediately. Task `35-04-02` rescanned the synchronized contracts and ledgers before setting the numeric result to zero.

Assets: source/JSON compatibility, raw geometry privacy, deterministic fail-closed behavior, evidence integrity, dependency containment, and honest product status.

Trust boundaries: host scalar parameters and payloads enter the public model; package-only detector supports enter geometry planning; aggregate diagnostics cross the public facade; runtime evidence enters durable root/planning contracts.

## Threat Register

| ID | Threat | Severity | Mitigation | Automated evidence | Residual risk | Provisional status |
| --- | --- | --- | --- | --- | --- | --- |
| T35-01 | Raw geometry, supports, coordinates, bounds, or control points cross the public/SPI facade | high | Keep `FaceGeometry`, `WarpControlPoint`, `noseRoot`, and `noseTip` package-internal; expose redacted summaries/counts only | Public/SPI diff scan plus facade redaction tests passed | Future facade changes require the Phase 37 active-source rerun | mitigated; closed |
| T35-02 | Non-finite, malformed, out-of-bounds, asymmetric, duplicate, or insufficient private supports produce unsafe vectors | high | Validate source provenance and geometry before clamping; field-specific zero and no legacy fallback | 13 provider tests and 16 degradation tests passed | Real detector landmark quality and visual calibration remain later evidence | mitigated; closed |
| T35-03 | Upper-root or lower-tip work aliases the legacy nose proxy or borrows bridge/tip-size fallback | high | Explicit default-empty support arrays; legacy center guard scoped to legacy fields; structural non-alias tests | Provider vector/non-alias/fallback tests passed | Phase 36 must prove facade-visible output distinction | mitigated; closed |
| T35-04 | Public source growth breaks legacy JSON/preset/source compatibility | high | Defaulted initializer arguments, missing-key zero decode, unchanged presets, exact inventory and round trip | 14 model and 7 resource tests passed | ABI compatibility for already compiled clients is not claimed | mitigated; closed |
| T35-05 | Manual resolver or conflict enumeration omits one new field | medium | Isolated route/cap/reuse/zero/conflict/facade tests and hotspot scans | Resolver 14, conflict 8, combined 10, facade 11 tests passed | Phase 37 owns exhaustive exactly-once matrix | mitigated; closed |
| T35-06 | Public diagnostics disclose raw support or framework detail | high | Fixed redacted reason codes and aggregate numeric metrics only | Resolver/facade redaction assertions and lexical review passed | Newly added diagnostic keys require renewed review | mitigated; closed |
| T35-07 | New dependency, target, network/cloud, account, or commercial path expands scope | high | No manifest edit; deny scans for network/cloud/commercial tokens | Package diff and active-source token scans passed | Packaging/distribution review remains outside Phase 35 | mitigated; closed |
| T35-08 | Renderer, Demo, generated artifact, or product status drifts into provider-only evidence | medium | Explicit non-edit lists and tracked-artifact/status scans | Renderer/Demo/ledger/matrix/README and generated-PNG gates passed | Phase 36/37 intentionally change later owners | mitigated; closed |
| T35-09 | Archived v1.7 evidence is rewritten to backfill new-field proof | high | Treat archive as immutable and diff exact archive paths | Archived roadmap/requirements/phases scan passed | None inside Phase 35 scope | mitigated; closed |
| T35-10 | Copied or zero-test output spoofs verification | high | Require nonzero observed XCTest counts and fresh full-suite output | 94/94 focused and final 207/207 full XCTest tests passed | Later phases require their own fresh evidence | mitigated; closed |

## Evidence Classification

- Public inventory: 33 stored values, exactly 32 numeric fields plus optional `filterId`.
- Package-internal supports: default-empty, finite/bounded/provenance validated before any output clamp.
- Compatibility: old JSON and unchanged presets default both new fields to zero; source-style calls retain defaults.
- Alias/fallback: new helpers consume only explicit supports and never substitute the legacy four-point proxy.
- Diagnostics: category and aggregate evidence is redacted; no raw geometry payload was found.
- Dependencies/scope: no new dependency, target, renderer, Demo, network/cloud, entitlement, purchase, payment, or generated artifact surface.
- Open high-severity findings: none. The post-synchronization ASVS L1 rerun found zero open threats.

## Residual Risk

Phase 35 proves provider/resolver/facade contracts, not natural visual calibration or release readiness. Phase 36 owns output/ROI evidence; Phase 37 owns final caps, exhaustive six-field safety, active-source closeout, and promotion. Device, commercial, packaging, and launch evidence remain external scope.
