---
phase: 56
slug: independent-teeth-whitening-slice
status: complete
researched: 2026-08-03
scope: exact-absence closed-gate validation
---

# Phase 56 Research — Independent Teeth Whitening Slice

## Executive Summary

Phase 56 has no admissible production implementation branch. The Phase 54
authority records `teeth_whitening` as `closed`, with both
`missing_genuine_positive` and `missing_genuine_negative`, all review/product
counts equal to zero, and zero naturalness weight. The roadmap's if-and-only-if
language therefore resolves the phase to an exact-absence validation slice.

The implementation work is test/checker/evidence work only. It must prove that
the current SDK, renderer, saved-output behavior, Demo taxonomy, and product
ledgers unanimously keep teeth whitening unpromoted. Adding a zero-valued field,
an internal provider, a renderer case that always abstains, or an active Demo
control would violate the conditional contract just as much as shipping an
untested effect.

No external framework research is needed. Current repository code/tests, the
independently validated Phase 54 decision ledger, and the hardened Phase 55
checker pattern are the authoritative implementation sources.

## Immutable Inputs

### Phase 54 admission authority

The exact teeth row in
`54-EVIDENCE-DECISIONS.json.feature_decisions` is:

```json
{
  "feature": "teeth_whitening",
  "status": "closed",
  "reasons": [
    "missing_genuine_positive",
    "missing_genuine_negative"
  ],
  "eligible_count": 0,
  "reviewed_count": 0,
  "accepted_count": 0,
  "rejected_count": 0,
  "naturalness_weight": 0
}
```

Phase 56 may validate and project this row into evidence, but it may not make a
new eligibility decision or create a competing canonical ledger.

### Current product/runtime state

- `BeautyEffectResolver.localRetouchAdmission(parameters:)` returns literal
  `.none`.
- `BeautyParameters` compatibility is exactly 59 stored/CodingKey/encoded
  fields.
- Resource compatibility is exactly five preset IDs with current source hashes.
- Renderer regression inventory is exactly 72 cases.
- Existing compatibility tests already forbid `teethWhitening` alongside the
  two other milestone candidates.
- The Demo contains one legitimate static disabled taxonomy row:
  `unsupported("lips.teeth", title: "白牙", icon: "sparkles")`.
- Product ledgers keep `白牙` as `future`; branch `嘴唇` remains `partial`
  solely because that item is future.
- Phase 55's composition machinery is package-only, opaque, feature-neutral,
  and reached only through Testing support. It does not authorize a teeth
  candidate.

## Requirement Interpretation

| Requirement | Correct Phase 56 disposition | Forbidden interpretation |
| --- | --- | --- |
| TEETH-01 | Conditional false branch: public `teethWhitening` remains exactly absent | Adding an inert/zero field or alias and calling it conditional |
| TEETH-02 | `not_applicable_closed_gate` | Claiming mapped lip support or candidate growth is product-ready from a spike |
| TEETH-03 | `not_applicable_closed_gate` | Claiming zero spill without an admitted candidate and rights-approved challenge set |
| TEETH-04 | `not_applicable_closed_gate` | Treating already-light `p1.jpg` or mechanics output as a discoloration-positive naturalness result |
| TEETH-05 | `not_applicable_closed_gate` | Claiming a production classifier/abstention algorithm that was not admitted |
| TEETH-06 | `no_promotion` | Promoting `白牙`, closing `嘴唇`, or borrowing sibling evidence |

This is a successful conditional result, not a skipped phase. Success requires
machine evidence that no surface was admitted and that all owners agree on the
closed decision.

## Recommended Architecture

### 1. Keep production source read-only

The following are validation fixtures rather than planned implementation files:

- `BeautyParameters` and its CodingKeys/default/serialization behavior;
- `BeautyLocalRetouchAdmission` and `BeautyEffectResolver`;
- render-plan/renderer/provider/resource/package manifests;
- both public still-image facade entries and their no-admission lifecycle;
- pixel-buffer/reset paths;
- Demo tool models and processor/view-model mappings.

Only tests may need additions. If a production file changes, the plan must stop
and demonstrate why the change is not an unauthorized feature route. The
expected diff contains no SDK/Demo production behavior change.

### 2. Extend existing exact inventories instead of inventing parallel oracles

Reuse the current tests as the canonical runtime/compatibility view:

- `BeautyParametersTests.swift` for stored/CodingKey/encoded/default/source-call
  equality and candidate-name absence;
- `BeautyResourceCatalogTests.swift` for five presets, source hashes, 59-field
  decoded values, and forbidden preset keys;
- `BeautyRendererOutputRegressionTests.swift` for exact 72-case inventory,
  aliases, saved-output/no-admission behavior, warnings/metrics/detection
  summary, and renderer-source scans;
- `BeautyEngineLocalRetouchFoundationTests.swift` for both CIImage entries,
  no-face/missing support recovery, unrelated effects, and pixel-buffer/reset
  zero work;
- `BeautyDemoViewStateTests.swift` for the disabled `白牙` taxonomy and the
  absence of an active binding/control/processor route.

Phase-specific test methods can group the assertions, but must not duplicate
large expected lists in a new file unless an existing owner cannot express the
contract.

### 3. Use one Phase 56 fail-closed boundary checker

Create `check_phase56_teeth_boundaries.py` by combining two proven patterns:

1. Phase 54's exact feature decision parsing: validate full JSON structure,
   exact feature identity, exact status/reason set/order, numeric types/zeros,
   and no duplicate/missing/extra teeth row.
2. Phase 55's temporary-copy live mutation testing: copy the exact real source,
   test, Demo, ledger, upstream-decision, and threat-inventory fixtures into a
   temporary root; mutate one anchored fact; run the same live checker; require
   the expected fixed rule ID; restore in `finally`.

The checker must distinguish allowed occurrences from forbidden routes. The
Chinese title `白牙` is expected in the disabled Demo row and future ledgers;
`teethWhitening` is expected in tests that assert absence. Repository-wide
substring bans would produce false positives and are not acceptable.

Scanner execution is tri-state and fail-closed:

- return 0 means a match was found;
- return 1 with empty stdout/stderr means no match;
- any other return code or unexpected output is an unclassified failure.

Top-level failures report only a fixed rule ID/count. They must not echo the
matched line, local path, JSON payload, or raw exception.

### 4. Keep one canonical security inventory

`56-THREAT-INVENTORY.json` should use exact whole-document equality with ordered
T-56 IDs, `OWASP ASVS Level 1`, severity `HIGH`, `block_on: HIGH`, and an
executable owner for every gate. Seven coherent threat groups cover the phase:

1. upstream gate tampering;
2. public/production activation;
3. alias or inert-route smuggling;
4. Demo activation hidden behind taxonomy;
5. privacy/evidence disclosure;
6. ledger promotion or sibling borrowing;
7. compatibility/scanner failure misclassification.

Every HIGH row is blocking. Counts are presentation data only; the checker must
compare the exact ordered IDs and gate definitions.

### 5. Produce a projection report, not a new decision source

`56-TEETH-CLOSED-GATE-EVIDENCE.md` should include:

- Phase 54 row projection and its source path;
- TEETH-01 false-branch disposition;
- TEETH-02..05 exact `not_applicable_closed_gate` dispositions;
- TEETH-06 exact `no_promotion` reconciliation;
- fixed compatibility totals and admission/Demo/ledger results;
- exact commands and actual test/checker counts;
- ASVS T-56 dispositions;
- explicit nonclaims and privacy statement.

It must not include portrait identifiers/paths/hashes, rights/grant payloads,
reviewer/session data, masks, coordinates, pixels, before/after images, output
digests, containment/effectiveness metrics, raw matches, or raw errors.

## Live Mutation Matrix

The checker self-test should mutate real fixture copies for at least these
families:

| Family | Required mutations |
| --- | --- |
| Decision | `closed` to open/passed; remove either reason; add a reason; make any count/weight nonzero; rename/duplicate/delete teeth row; malformed/missing/unreadable JSON |
| Public surface | Add stored field, CodingKey, initializer label, encoded/default key, public or Testing SPI candidate, or saved-output option |
| Alias | Route teeth through skin whitening, brightness, `lipColor`, mouth/lip geometry, another candidate, or opaque mechanics name |
| Runtime | Change literal `.none`; add candidate admission, provider, transform, render-plan member, renderer case, preset, resource, dependency, model, network/storage, realtime, pixel-buffer, reset, or inert route |
| Compatibility | Change 59/5/72; alter preset IDs/hash; weaken exact expected lists; change no-admission facade output/warning/metric/detection expectations |
| Demo | Delete/rename the disabled row; convert it to active; add control ID, binding, slider, processor mapping, or enabled availability |
| Ledger | Promote `白牙`; close/promote `嘴唇`; rewrite the branch reason; cite sibling evidence |
| Privacy/robustness | Insert a forbidden path/hash/mask/pixel/digest/raw-error key; remove a required fixture; force scanner exception or unclassified subprocess result |

Each mutation must have a unique expected rule ID or a stable rule family plus
case ID. The clean fixture and every mutation must run through the same live
checker code path.

## Testing Strategy

### Focused samples

Run only the relevant existing suites during construction:

```bash
CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase56-clang-module-cache \
  swift test --package-path BeautySDK \
  --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineLocalRetouchFoundationTests'
```

Run the checker in `--self-test` and live modes after every checker/fixture
change. Run the focused Demo view-state suite when Xcode's selected-test syntax
is stable; otherwise record the complete Demo target count without hiding it as
a focused sample.

### Final-only gate

Reserve full SwiftPM and explicit iPhone 17e/iOS 26.5 Demo build/test for the
single final task. Also run schema drift and UI safety; classify codebase drift
separately and accept only the already recorded historical warning involving
`PRODUCT_SENSE.md`, `example-images`, and `meituxiuxiu`.

Final traceability must compare exact sets, not just totals:

- TEETH-01..06;
- D-56-01..16;
- actual XML task IDs versus validation rows;
- T-56 inventory IDs versus executable results;
- exact 59/5/72 compatibility inventories;
- exact Demo and ledger statements;
- owner-document updates and explicit nonclaims.

## Plan Structure Recommendation

Use three serial plans with five executable tasks:

1. **Wave 0 / 56-01 — exact-absence specifications**
   - SDK/facade/59-5-72 exact-absence tests.
   - Demo/ledger tests plus initial checker and threat inventory.
2. **Wave 1 / 56-02 — authoritative closed-gate enforcement**
   - Exact Phase 54 decision parsing and decision-mutation coverage.
   - Production/API/Demo/ledger/privacy live mutation coverage and evidence
     projection draft.
3. **Wave 2 / 56-03 — final closeout**
   - Focused and full regressions, ASVS/schema/UI/drift/traceability gates,
     evidence finalization, validation promotion, and owner synchronization.

Plans are serial because the checker and evidence tasks consume the Wave 0 test
fixtures, and the final closeout consumes every prior result. Full SwiftPM/Demo
must appear only in the final task.

## Common Failure Modes

- Treating a closed gate as permission to add an inert public field.
- Calling TEETH-02..05 implemented because generic Phase 55 mechanics exist.
- Using the current already-light portrait as a genuine discoloration positive
  or complete negative bundle.
- Removing the legitimate disabled Demo taxonomy row to satisfy a broad absence
  scan.
- Searching for `白牙` or `teethWhitening` globally without distinguishing
  allowed tests/docs from forbidden production declarations.
- Reporting only test counts or HIGH counts without exact identity equality.
- Letting missing files, malformed JSON, scanner errors, or unclassified tool
  results pass as absence.
- Updating `白牙`/`嘴唇` ledgers before all automated gates pass.
- Copying raw matches, paths, or errors into committed evidence.
- Running a human/browser/image workflow even though Phase 54 already provides
  the closed decision.

## Research Conclusion

Phase 56 should make no production feature change. The complete deliverable is
a stronger automated proof that the conditional false branch is enforced
across admission, public API, compatibility, facade output, Demo taxonomy,
privacy, and product ledgers. If any test discovers an active route or if the
upstream decision differs from the exact closed row, execution must stop rather
than repair the discrepancy by implementing teeth whitening.
