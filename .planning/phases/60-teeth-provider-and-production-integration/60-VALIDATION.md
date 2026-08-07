---
phase: 60
slug: teeth-provider-and-production-integration
status: planned
nyquist_compliant: true
wave_0_complete: false
created: 2026-08-07
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [TEETH-09, TEETH-10, TEETH-11, TEETH-12, TEETH-13, TEETH-14]
---

# Phase 60 - Validation Strategy

Phase 60 validates a stateless still-image teeth provider and its production
integration. It does not claim Phase 61 public-output promotion or activate the
Demo.

## Infrastructure and invariants

| Property | Owner |
| --- | --- |
| Canonical source | Existing `BeautyCanonicalStillImage` and source binding |
| Actual support | Existing one-request `BeautyObservedLipSupport` mapping |
| Selection/transform | New package-only stateless teeth provider |
| Pixel ownership | Existing `BeautyLocalRetouchCompositionOwner` |
| Real fixtures | Existing ignored bundle through fixed-output private runner |
| Static security | Eight isolated HIGH threats plus mutation self-test |
| Compatibility | Exact 60 fields, five presets, disabled Demo, no sibling/realtime/model/network routes |

## Per-task verification map

| Task ID | Wave | Requirements | Automated evidence | Status |
| --- | ---: | --- | --- | --- |
| `60-01-01` | 1 | TEETH-09, TEETH-10, TEETH-11 | RED support, geometry, baseline, growth, hard-envelope tests | passed as RED; missing provider/transform seams only |
| `60-01-02` | 1 | TEETH-12, TEETH-13, TEETH-14 | RED transform, protected-tissue, no-op, recovery, private-fixture contracts | passed as RED; missing provider observation/wiring only |
| `60-02-01` | 2 | TEETH-09, TEETH-10, TEETH-11 | Provider implementation and focused selection tests | planned |
| `60-02-02` | 2 | TEETH-11, TEETH-12, TEETH-13 | Source-derived target unit, composition, containment tests | planned |
| `60-03-01` | 3 | TEETH-09, TEETH-12, TEETH-14 | One-request production facade wiring and unrelated-effect continuation | planned |
| `60-03-02` | 3 | TEETH-09, TEETH-14 | No-face/missing/malformed/already-light/recovery/parallel/reset tests | planned |
| `60-04-01` | 4 | TEETH-12, TEETH-13, TEETH-14 | Private genuine pair, checker self/live/per-threat, privacy | planned |
| `60-04-02` | 4 | TEETH-09, TEETH-10, TEETH-11, TEETH-12, TEETH-13, TEETH-14 | Full SDK/Demo regression, owners, requirements, lifecycle handoff | planned |

Task count equality target: **8 plan task IDs = 8 validation rows**.

## Required final gates

1. Focused provider, composition, Vision-support, and facade lifecycle suites.
2. Opt-in genuine positive/negative test through the fixed-output private runner;
   absence or inability to run blocks rather than skips.
3. Checker self-test, live mode, and isolated `T-60-01` through `T-60-08`.
4. Exact 60-field, five-preset, disabled-Demo, sibling/realtime/model/network
   absence and tracked/staged privacy checks.
5. Full SwiftPM plus explicit iPhone 17e / iOS 26.5 Demo build and test.
6. Non-skipped decision coverage, exact plan/task/requirement/threat inventory,
   JSON/Python syntax, and diff hygiene.

No later broad pass replaces a missing private fixture, containment, recovery,
privacy, or isolated HIGH gate.

## Nonclaims

Phase 60 passing means the provider implementation and production still-image
connection meet their bounded tests. Phase 61 still owns independent strict
public-output evidence, adversarial closeout, original-detail final review, and
promotion. No population, realtime, device-performance, commercial,
packaging, shipping, launch, or release claim follows.
