# 94-02 negative Swift source review

**Source-only findings closed. Not a TEST-REVIEW, build result, freeze approval or measurement authorization.**

```yaml
review_scope: source_only
source_findings: resolved
remaining_source_blockers: 0
remaining_source_warnings: 0
build: not_run
native_tests: not_run
freeze_authorized: false
final_test_review: pending_runner_and_build
phase_complete: false
```

No machine-admissible `phase94.test-review.1` PASS header is supplied. Final independent TEST-REVIEW must cover the reviewed runner, successful compile-only evidence and exact current Swift identities before freeze/measurement.

## Source identities

| File/version | SHA-256 |
|---|---|
| MouthNegativeOracleTests.swift — initial reviewed source | `fec663ba3c30ca2a193a4e03f5f763ddd85538441fa806c44a17120423d01aa8` |
| MouthNegativeOracleTests.swift — revised source | `5f76e3c6587bc68c0b3fcbaf2eee0f7a488bdbb4d303a154529a77141a418109` |
| BeautyEngineMouthNegativeTests.swift — unchanged P1 | `f6bf8d3c9ce59ce25ac09c9e0b4147a61e5e54d9e397abfd6ee35c2b4e4cc65a` |

Current revised oracle and unchanged P1 hashes were independently verified. This follow-up inspects the three reported source findings, not Jason's concurrent runner repair.

## Initial findings and exact resolutions

| ID | Initial severity and finding | Revised implementation | Disposition |
|---|---|---|---|
| S94-01 | BLOCKER: O2's passing record used zero protection values, so tests did not establish that equality at each nonzero upper bound is accepted. A mistaken strict inequality could escape detection. | The passing record now explicitly uses outside 128/512, height 64/256 and face 64/256; background/watermark remain at their zero limits. Admission must pass at these exact bounds. Each existing mutation changes one field to limit+1 and requires precisely its one predicate to fail while all others remain legal. Signal/sign/sibling exact boundaries and nineteen single-field mutations remain intact. | RESOLVED by source inspection; assertions not executed. |
| S94-02 | WARNING: O1 lacked direct nonintegral floor/exclusive, swapped-target span and delta2/3 assertions despite its method contract; some coverage existed only in inherited tests. | O1 now asserts the literal 13×17 raster bounds 1/11/3/13, inclusion and exclusion at all four edges; two-pixel examples assert delta2 gives changed=0/RGB=2 and delta3 gives changed=1/RGB=3; reversing target order must preserve a positive span. | RESOLVED by source inspection; assertions not executed. |
| S94-03 | WARNING: rejects() accepted every thrown error despite claiming typed rejection coverage, allowing unrelated failures to satisfy the test. | rejects() now accepts only `MouthBaselineOracle.Failure`; any other error produces the fixed `P94N_STAGE_METRIC` failure. Returning without throwing also fails. No error object is printed. | RESOLVED by source inspection; assertions not executed. |

## Preserved source-review conclusions

The initial review inspected O1–O3 and P1 against 94-02 and the remaining validation contract. Checked primitive arithmetic, negative source/neutral margins, three sibling distinctions, seventeen predicate outcomes, real array identity/outward/alias/leakage controls, and clipped/full source-neutral protection conjunction were connected in the inspected implementation. The revisions above add tests and typed rejection discrimination without changing the measurement policy.

Unchanged P1's normal path requests five rows through both wrappers twice, totaling twenty returned images. It compares four retained row hashes plus source against the hash-pinned prerequisite receipt, checks neutral/geometry metadata, wrapper/repeat equality, alpha/extent and named-sRGB extraction, and emits the complete negative metric/predicate record before semantic assertions. Throw handling uses fixed stage/row/orientation markers without interpolated error or image objects. These remain static coverage observations, not compilation, runtime completion or negative-effect evidence.

Only this source-review summary was written. No build/native execution, runner inspection, authoring-source edit, freeze, commit or evidence/state modification occurred. The final TEST-REVIEW remains pending runner repair/review and successful compile-only validation.
