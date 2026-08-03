---
phase: 55
slug: original-pixel-composition-and-failure-isolation-core
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-03
security_standard: OWASP ASVS Level 1
block_on: HIGH
---

# Phase 55 — Validation Strategy

> Validated architecture for a feature-neutral composition foundation.
> A deterministic exact-empty production outcome is expected: mechanics tests
> may exercise package wiring, but no named feature field/provider/renderer/
> preset/admission route may appear while all Phase 54 gates remain closed.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | SwiftPM XCTest, Python standard-library mutation checker, existing GSD schema/codebase/UI gates, explicit iOS Simulator Xcode regression |
| Config file | `BeautySDK/Package.swift`; no new target, product, dependency, resource, model, or package |
| Quick suite | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase55-clang-module-cache swift test --package-path BeautySDK --filter BeautyLocalRetouchCompositionTests` |
| Facade suite | Same prefix with `--filter 'BeautyEngineLocalRetouchCompositionTests|BeautyEngineLocalRetouchFoundationTests'` |
| Compatibility suite | Same prefix with `--filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests'` |
| Boundary checker | `python3 .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py --self-test` plus default live mode |
| Final-only regression | Full SwiftPM plus explicit iPhone 17e/iOS 26.5 Demo build/test in `55-05-01` only |
| Security | OWASP ASVS Level 1, `block_on: HIGH`; all named T-55 HIGH rows must be machine-green before their task/plan/phase completes |
| Diff hygiene | `git diff --check` in every GREEN task and the final gate |

If the managed sandbox blocks Core Image/CoreVideo/CoreSimulator resources,
record the exact environment failure without classifying it as implementation
RED; the final phase gate must still be rerun in the repository's known-good
host context before validation is promoted.

## Sampling Contract

- Wave 0 authors the complete unit/facade specifications and a fail-closed
  mutation checker before the composition implementation exists.
- An acceptable Wave 0 RED is an exact missing Phase 55 production artifact or
  seam marker after the test/checker harness itself compiles and self-tests.
  Syntax, discovery, toolchain, privacy-scan, or arbitrary runtime failures are
  not acceptable RED.
- Plans 55-02 through 55-04 use focused unit/facade/compatibility samples. They
  do not run full SwiftPM or Demo regression.
- `55-05-01` alone owns the full SwiftPM, Demo build/test, GSD drift/UI gates,
  exact requirement/decision/task traceability, validation promotion, evidence
  closeout, and all root-owner synchronization.
- A later full gate does not silently convert an earlier unrun task row to
  passed. Every row records its own actual command/result.
- Tests use tiny opaque in-memory canonical rasters and literal or independently
  authored expected bytes. They commit no portrait, mask, output, digest, path,
  or generated baseline.

## Planned Per-Task Verification Map

The planner may change file grouping, but it must preserve these nine semantic
rows or update this table one-for-one with the final XML task IDs before plan
checking.

| Planned task ID | Wave | Requirements | Required focused evidence | Status |
| --- | ---: | --- | --- | --- |
| `55-01-01` | 0 | COMP-01..05 | Unit RED matrix compiles; exact missing composition artifact oracle; literal byte tables cover source binding, Q16, hard reclip, duplicates, collision, failure isolation, order, and recovery | passed |
| `55-01-02` | 0 | COMP-01..05 | Facade/checker RED harness; checker self-test mutates every T-55/UI/scope/compatibility rule and names only planned missing seams | passed |
| `55-02-01` | 1 | COMP-02, COMP-03 | Strong lifetime-retained canonical identity binding plus checked dimensions/row/byte/index arithmetic; quick suite and checker source mode | passed |
| `55-02-02` | 1 | COMP-01, COMP-02, COMP-04 | Opaque request-local identity/token issuance after proposal validation, unit caps, foreign/duplicate token and raw duplicate claim rejection; quick suite | passed |
| `55-03-01` | 2 | COMP-02..05 | Hard reclip, zero-weight elimination, exact Q16 blend, original-alpha preservation, stable order-independent ownership reduction; quick suite | passed |
| `55-03-02` | 2 | COMP-01, COMP-03..05 | Pixel-local collision-to-source, local invalid-unit abstention, aggregate-only summary, literal standalone/merge/fused/failure oracles; quick suite + checker privacy mode | passed |
| `55-04-01` | 3 | COMP-01, COMP-02, COMP-05 | Opaque Testing activation consumes the exact request-context canonical source, composes once, exposes aggregates only, and leaves production admission empty | passed |
| `55-04-02` | 3 | COMP-01, COMP-05 | Both public CIImage entries, unrelated color continuation, valid-invalid-valid recovery, pixel-buffer/reset zero work, exact no-admission compatibility | passed |
| `55-05-01` | 4 | COMP-01..05 | Complete unit/facade/checker/compatibility/full SwiftPM/Demo/schema/UI/codebase/diff/ASVS/traceability/owner-doc gate | passed |

Task count target: **9 actual XML task IDs = 9 validation rows = 2 Wave 0 +
6 focused GREEN + 1 final closeout**.

## Wave 0 Deliverables

- [x] `BeautyLocalRetouchCompositionTests.swift` freezes literal-byte mechanics
  for COMP-01 through COMP-05 without importing production helpers into its
  expected-value oracle.
- [x] `BeautyEngineLocalRetouchCompositionTests.swift` freezes same-canonical
  facade adjacency, unrelated-effect continuation, opaque aggregate output,
  recovery, and no production/pixel-buffer/reset route.
- [x] `check_phase55_composition_boundaries.py` self-tests clean and mutated
  fixtures and fails closed on missing files, scanner errors, and unclassified
  subprocess outcomes.
- [x] A canonical `55-THREAT-INVENTORY.json` (or an equivalently exact checker
  inventory if the planner proves no separate file is needed) pins every active
  HIGH row with no count-only denominator.
- [x] Wave 0 inputs remain tiny opaque in-memory bytes; no real media, masks,
  coordinates, output digest, stable portrait identifier, or anatomy-specific
  production symbol is added.

## Requirement-to-Evidence Map

| Requirement | Exact evidence owners |
| --- | --- |
| COMP-01 | Unit-local invalid/absent/duplicate rejection; opaque whole-region and subunit failure table; unrelated shipped-color facade continuation; valid-invalid-valid nonretention |
| COMP-02 | Exact canonical storage identity/dimension binding; original-source-only blend; foreign byte-equal carrier rejection; order/permutation equality; exact alpha |
| COMP-03 | Separate hard-envelope and Q16 weight; post-filter reclip; zero-weight unowned behavior; checked arithmetic/caps; literal outside-union equality |
| COMP-04 | Raw duplicate rejection; duplicate-token local rejection; 2/3-owner collision counted once per pixel; source byte retained; no priority/order branch |
| COMP-05 | Literal standalone A/B/C, independently merged, fused, and reversed-order bytes; teeth/whole-sclera/left/right conceptual failure injections without production anatomy types |

## Required Byte and Failure Matrix

| Group | Required cases |
| --- | --- |
| Integer blend | Q16 `0`, midpoint `32_768`, full `65_536`, oversized clamp; round-half-up literals; source alpha exact |
| Source binding | Exact carrier accepted; distinct same-size/same-byte carrier rejected locally; checked row/byte/index offset relations |
| Containment | hard false + positive weight; zero weight; outside-union bytes; all claimed alpha; invalid/overflowed indices/counts |
| Duplicates | duplicate raw index even if filtered later; duplicate unit token supplied twice; unrelated valid unit preserved |
| Collision | 2-owner and 3-owner same pixel count once and preserve source; adjacent unique claims still blend |
| Fusion | standalone literal arrays; independently authored merge; fused/reversed/permuted input equality; summary equality |
| Failure isolation | conceptual teeth-only rejection; whole-sclera pair rejection; left-only; right-only; future band; valid siblings byte-identical |
| Lifecycle | empty, valid-invalid-valid, no-face/missing support, both CIImage entries, pixel-buffer/reset zero composition work |
| Compatibility | exact 59 stored/CodingKey fields, five presets, 72 renderer cases, zero candidate names/admission, unchanged no-admission bytes/warnings/metrics/detection summary |

## ASVS Level 1 HIGH Inventory

| ID | Threat | Required mitigation/evidence |
| --- | --- | --- |
| T-55-01 | Foreign or stale source spoofing | Strong lifetime-retained canonical/owner identities, identity equality, foreign byte-equal negative test, and stale-unit carrier/owner churn regression |
| T-55-02 | Count/index/offset overflow or allocation denial | Proposal validation before slot/token consumption, reporting-overflow arithmetic, bounded unit/claim totals, and malformed-attempt starvation regression |
| T-55-03 | Duplicate/token/order tampering | Pre-filter duplicate rejection, duplicate-token frequency rejection, all input permutations byte/summary equal |
| T-55-04 | Hidden overlap priority or double edit | 2/3-owner collision-to-source, one aggregate count per collision pixel, no anatomy/strength/order priority source branch |
| T-55-05 | Mask/pixel/owner/digest disclosure | Package-only non-Codable units; no public/SPI raw claims or stable output digest; exact aggregate allowlist and source scans |
| T-55-06 | Cross-request retention or realtime activation | Stack-local owner, valid-invalid-valid isolation, engine stores no claims/output, pixel-buffer/reset zero work |
| T-55-07 | Closed-gate/product-scope tampering | Exact-empty production admission; no candidate field/provider/renderer/preset/Demo/model/network/resource/dependency; compatibility inventories unchanged |

Every plan must declare ASVS Level 1 and `block_on: HIGH`. A failed, skipped,
unrun, count-only, or unclassified HIGH row blocks its owning task, plan, and
phase. No waiver converts missing evidence to green.

## Forbidden Source and Privacy Surface

The checker must fail closed on:

- public/SPI/Codable/persisted/logged contribution, token, source binding,
  pixel index, coordinate, hard/soft mask, target/source/output byte, raw error,
  or stable output digest;
- feature-named field, CodingKey, preset key, provider, transform, renderer
  case, admission, teeth/sclera/eyelid branch, or inert zero route;
- production nonempty local admission, Demo or pixel-buffer/reset composition,
  new target/dependency/resource/model/network/storage/file path;
- unchecked count/index/offset allocation, floating/platform-dependent blend,
  sequential local feedback, priority/max/last-write collision resolution,
  pre-feather-only containment, or output initialized from noncanonical bytes;
- missing literal-byte/failure/recovery tests, changed 59/5/72 compatibility
  inventories, or weakening exact equality to contains/approximate assertions;
- scanner exceptions, missing required files, malformed JSON, or unclassified
  command results.

## Final-Only Phase Gate

Task `55-05-01` must execute and record:

1. Swift and Python syntax/discovery checks.
2. Complete Phase 55 unit and facade suites.
3. Checker `--self-test` and live mode with exact named T-55 denominator.
4. Existing Phase 53 foundation plus parameter/resource/renderer compatibility suites.
5. Full `swift test --package-path BeautySDK` in the known-good host context.
6. Explicit iPhone 17e/iOS 26.5 Demo build and test.
7. GSD `verify.schema-drift` and `ui.safety-gate`; separately classify only the
   historical `PRODUCT_SENSE.md`, `example-images`, `meituxiuxiu` codebase-drift warning.
8. Exact requirement, decision, XML-task/validation-row, HIGH, public/SPI,
   candidate, dependency, privacy, and owner-document scans.
9. `git diff --check`.
10. Create `55-COMPOSITION-EVIDENCE.md`, promote this file only after all rows
    are green, and update PLANS/owner docs/QUALITY_SCORE with actual counts and
    explicit nonclaims.

## Validation Sign-Off

- [x] Final PLAN XML task count equals this validation table exactly.
- [x] Wave 0 tests/checker exist and fail only through exact planned missing seams.
- [x] COMP-01..05 have current behavior-level byte/failure/facade evidence.
- [x] Every active T-55 HIGH row is named and machine-green; no waiver exists.
- [x] Exact-empty production admission and 59/5/72 compatibility are unchanged.
- [x] No sensitive support/digest, candidate surface, Demo/realtime route, or unsupported readiness claim is added.
- [x] Full SwiftPM and explicit Demo regression pass in a framework-capable host context.
- [x] `55-COMPOSITION-EVIDENCE.md` exists with actual command/count evidence before validation promotion.

**Approval:** validated after all nine task rows, five requirements, twenty
decisions, seven HIGH mitigations, focused/final regressions, and owner evidence
passed. Independent phase verification remains a downstream lifecycle gate.
