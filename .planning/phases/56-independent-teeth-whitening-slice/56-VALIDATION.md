---
phase: 56
slug: independent-teeth-whitening-slice
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-03
security_standard: OWASP ASVS Level 1
block_on: HIGH
---

# Phase 56 — Validation Strategy

> Validate the false branch of the conditional teeth contract. The immutable
> Phase 54 decision is closed, so the successful Phase 56 result is exact
> absence: no `teethWhitening` product surface and no claim that a tooth
> algorithm, containment result, naturalness result, or saved-output effect was
> implemented.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | SwiftPM XCTest, Python standard-library live-fixture mutation checker, existing GSD schema/codebase/UI gates, explicit iOS Simulator Xcode regression |
| Config file | `BeautySDK/Package.swift`; no new target, dependency, resource, model, network, storage, or package |
| Focused SDK suite | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase56-clang-module-cache swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineLocalRetouchFoundationTests'` |
| Focused Demo suite | Explicit iPhone 17e/iOS 26.5 `xcodebuild ... test` with `-only-testing:BeautyDemoTests/BeautyDemoViewStateTests` when supported; otherwise the complete Demo test target is recorded |
| Boundary checker | `python3 .planning/phases/56-independent-teeth-whitening-slice/check_phase56_teeth_boundaries.py --self-test` plus default live mode |
| Final-only regression | Full SwiftPM plus explicit iPhone 17e/iOS 26.5 Demo build/test in `56-03-01` only |
| Security | OWASP ASVS Level 1, `block_on: HIGH`; every named T-56 HIGH row must be machine-green before its task, plan, or phase completes |
| Diff hygiene | `git diff --check` in every task and the final gate |

## Sampling Contract

- Wave 0 adds exact-absence XCTest coverage and the complete fail-closed checker
  before any owner document may record the Phase 56 result.
- There is no planned production RED/GREEN implementation seam. The closed gate
  is already the valid runtime state; tests and checker fixtures must pass
  against it and fail only after a named adversarial mutation.
- Plans 56-01 and 56-02 use focused SDK/Demo/checker samples. They do not run the
  full SwiftPM or complete Demo regression.
- `56-03-01` alone owns full SwiftPM, Demo build/test, GSD schema/codebase/UI
  gates, exact requirement/decision/task/threat traceability, validation
  promotion, evidence closeout, and root-owner synchronization.
- A later full gate does not silently convert an earlier unrun row to passed.
  Every row records its own actual command and result.
- Phase 56 selects no files, runs no human image review, generates no
  before/mask/after output, and reads no ignored portrait. Missing evidence is
  the validated admission input, not a checkpoint.

## Planned Per-Task Verification Map

The planner may change file grouping, but it must preserve these five semantic
rows or update this table one-for-one with the final XML task IDs before plan
checking.

| Planned task ID | Wave | Requirements | Required focused evidence | Status |
| --- | ---: | --- | --- | --- |
| `56-01-01` | 0 | TEETH-01, TEETH-06 | Exact XCTest inventory for no public/stored/CodingKey/SPI/alias route, literal `.none` production admission, unchanged still facade/no-admission output, 59 fields, five presets, 72 renderer cases | pending |
| `56-01-02` | 0 | TEETH-01..06 | Disabled `白牙` Demo taxonomy and future/partial ledger tests plus checker/threat inventory; self-test rejects every named T-56 mutation and scanner/missing-file failures | pending |
| `56-02-01` | 1 | TEETH-01..06 | Live checker derives the exact closed teeth row from Phase 54, pins both missing-polarity reasons and zero counts/weight, and rejects status/reason/count/row tampering | pending |
| `56-02-02` | 1 | TEETH-01, TEETH-06 | Live checker proves no provider/transform/render-plan/renderer/preset/resource/dependency/model/admission/Demo activation, no aliasing, exact compatibility totals, and exact ledger no-promotion | pending |
| `56-03-01` | 2 | TEETH-01..06 | Final focused/checker/full SwiftPM/Demo/schema/UI/codebase/diff/ASVS/traceability/owner-doc gate; creates canonical closed-gate evidence and promotes validation | pending |

Task count target: **5 actual XML task IDs = 5 validation rows = 2 Wave 0 +
2 focused live-gate tasks + 1 final closeout**.

## Wave 0 Deliverables

- [ ] Existing SDK compatibility tests are extended or phase-named to pin the
  false branch without duplicating the full 59/5/72 oracle.
- [ ] Facade tests pin both still-image public entries, unrelated shipped-color
  continuation, exact no-admission output/warnings/metrics/detection summary,
  and pixel-buffer/reset zero local-retouch work.
- [ ] Demo tests preserve exactly the static disabled
  `unsupported("lips.teeth", title: "白牙", ...)` taxonomy row and reject an
  active control, binding, processor mapping, slider, or availability change.
- [ ] `check_phase56_teeth_boundaries.py` self-tests temporary copies of real
  source, test, upstream decision, and ledger fixtures and fails closed for
  missing files, malformed JSON, scanner errors, and unclassified subprocess
  results.
- [ ] `56-THREAT-INVENTORY.json` pins every active HIGH row by exact ID and gate,
  not by count alone.
- [ ] Tests/checker artifacts contain no portrait path/hash, rights/grant
  payload, mask, coordinate, pixel, output digest, raw source match, or raw
  exception text.

## Requirement-to-Evidence Map

| Requirement | Closed-gate disposition and evidence owner |
| --- | --- |
| TEETH-01 | Conditional false branch: `teethWhitening` and aliases remain absent from public/stored/CodingKey/SPI/default/JSON/product routes; exact compatibility and admission tests pass |
| TEETH-02 | `not_applicable_closed_gate`; upstream decision projection proves no candidate is eligible, and source/checker scans prove no support/provider/transform implementation was admitted |
| TEETH-03 | `not_applicable_closed_gate`; no owned teeth mask or candidate output exists, so no containment/effectiveness claim is made |
| TEETH-04 | `not_applicable_closed_gate`; zero naturalness weight and missing genuine positive/negative evidence prohibit discoloration or naturalness claims |
| TEETH-05 | `not_applicable_closed_gate`; no runtime teeth route exists, so abstention is provided by non-admission rather than an implemented classifier claim |
| TEETH-06 | `no_promotion`; SDK facade, saved-output absence, privacy, regression, disabled Demo taxonomy, `白牙 = future`, and branch `嘴唇 = partial` agree exactly |

## Exact Absence and Compatibility Matrix

| Group | Required cases |
| --- | --- |
| Gate authority | Exact `teeth_whitening` identity; `closed`; ordered reasons `missing_genuine_positive`, `missing_genuine_negative`; eligible/reviewed/accepted/rejected `0`; naturalness weight `0`; no duplicate/extra/missing row |
| Public surface | No stored field, initializer label, CodingKey, encoded/default/reflection member, public/SPI candidate, JSON key, saved-output option, or inert zero field |
| Aliasing | No teeth alias to global whitening, brightness, `lipColor`, lip/mouth geometry, another candidate, or Testing mechanics |
| Runtime | Literal `.none` resolver admission; zero admitted candidates; no provider, support, transform, render-plan field, renderer case, preset, resource, dependency, target, model, network, storage, realtime, pixel-buffer, or reset route |
| Compatibility | Exactly 59 stored/CodingKey/encoded fields, five preset IDs and current source hashes, 72 renderer cases, legacy decode/source call behavior, both CIImage entries and no-admission output unchanged |
| Demo | Disabled `lips.teeth` / `白牙` taxonomy row remains; no active control, slider, parameter mapping, processor route, enabled state, or changed future copy |
| Ledgers | `白牙 = future`; branch `嘴唇 = partial`; no sibling-evidence borrowing or promotion wording |
| Evidence | TEETH-01 false branch; TEETH-02..05 exact `not_applicable_closed_gate`; TEETH-06 exact `no_promotion`; no image/human/mechanics/readiness claims |

## ASVS Level 1 HIGH Inventory

| ID | Threat | Required mitigation/evidence |
| --- | --- | --- |
| T-56-01 | Upstream gate authority tampering | Exact Phase 54 row parser plus live mutations of status, reasons, counts, weight, row identity, JSON shape, and missing/unreadable input |
| T-56-02 | Premature public or production activation | Exact field/CodingKey/SPI/admission/provider/renderer/preset/resource/dependency/model absence scans and executable live mutations |
| T-56-03 | Alias or inert-route smuggling | Candidate alias set, initializer/default/JSON/Testing scans, literal `.none`, and mutations that route through an existing whitening/color/geometry control |
| T-56-04 | Demo activation disguised as taxonomy | Preserve the exact disabled row while mutations adding binding/control/slider/processor/enabled availability fail |
| T-56-05 | Evidence or privacy disclosure | Fixed status/reason/count/total allowlist; no paths, hashes, rights payload, media, masks, coordinates, pixels, digests, raw matches, or raw errors |
| T-56-06 | Ledger promotion or sibling borrowing | Exact `白牙 = future` and `嘴唇 = partial` assertions; mutations of status, branch closure, or sibling evidence fail |
| T-56-07 | Compatibility/scanner failure misclassified as green | Exact 59/5/72 and facade inventories; missing fixtures, parse errors, scanner exceptions, and unclassified subprocess results fail closed |

Every plan must declare ASVS Level 1 and `block_on: HIGH`. A failed, skipped,
unrun, count-only, or unclassified HIGH row blocks its task, plan, and phase. No
waiver or later broad regression converts missing evidence to green.

## Forbidden Source, Claim, and Privacy Surface

The checker must fail closed on:

- public/SPI/Codable/persisted/logged teeth candidate state, raw support,
  landmark/coordinate/mask/pixel/output/digest data, rights/grant/reviewer
  payload, filename/path, or raw error;
- candidate field, CodingKey, initializer/default/JSON key, provider, support,
  transform, render-plan field, renderer case, preset, resource, dependency,
  model, admission, active Demo mapping, realtime/pixel-buffer/reset route, or
  inert zero-work branch;
- aliasing teeth to global whitening, brightness, lip color, mouth/lip geometry,
  another feature, or Phase 55 opaque Testing mechanics;
- Phase 54 status/reason/count/weight drift, eligibility reinterpretation, use
  of `p1.jpg` as a genuine positive/complete negative, or a new human-review
  result;
- promotion of `白牙`, closure of `嘴唇`, deletion/activation of the legitimate
  disabled Demo taxonomy row, or sibling-evidence borrowing;
- weakening exact equality to approximate/contains-only checks, missing
  required fixtures, malformed JSON, scanner exceptions, or unclassified
  command outcomes.

## Final-Only Phase Gate

Task `56-03-01` must execute and record:

1. Swift/Python/JSON syntax and test discovery checks.
2. Complete focused SDK and Demo exact-absence/compatibility suites.
3. Checker `--self-test` and live mode with exact named T-56 denominator.
4. Existing Phase 53 foundation, Phase 54 decision, and Phase 55 composition/
   compatibility regressions needed to prove no route was activated.
5. Full `swift test --package-path BeautySDK` in the known-good host context.
6. Explicit iPhone 17e/iOS 26.5 Demo build and complete test.
7. GSD `verify.schema-drift` and `ui.safety-gate`; separately classify only the
   historical `PRODUCT_SENSE.md`, `example-images`, `meituxiuxiu` codebase-drift
   warning.
8. Exact TEETH-01..06, D-56-01..16, XML-task/validation-row, T-56, public/SPI,
   candidate, dependency, privacy, Demo, ledger, and owner-document scans.
9. `git diff --check`.
10. Create `56-TEETH-CLOSED-GATE-EVIDENCE.md`; promote this file only after all
    rows are green, then update PLANS/PRODUCT_SENSE/QUALITY_SCORE and planning
    requirement/validation state with actual counts and explicit nonclaims.

## Validation Sign-Off

- [ ] Final PLAN XML task count equals this validation table exactly.
- [ ] Wave 0 tests/checker exist and pass clean fixtures while rejecting every
  named live mutation.
- [ ] TEETH-01..06 have exact conditional dispositions with no implementation
  claim for TEETH-02..05.
- [ ] Every active T-56 HIGH row is named and machine-green; no waiver exists.
- [ ] Exact-empty production admission, disabled Demo taxonomy, future/partial
  ledgers, and 59/5/72 compatibility are unchanged.
- [ ] No sensitive support/digest, candidate surface, image review, Demo/
  realtime route, or unsupported readiness claim is added.
- [ ] Full SwiftPM and explicit Demo regression pass in the known-good host
  context.
- [ ] `56-TEETH-CLOSED-GATE-EVIDENCE.md` exists with actual command/count
  evidence before validation promotion.

**Approval:** pending all five task rows, six requirements, sixteen decisions,
seven HIGH mitigations, focused/final regressions, and owner evidence.
