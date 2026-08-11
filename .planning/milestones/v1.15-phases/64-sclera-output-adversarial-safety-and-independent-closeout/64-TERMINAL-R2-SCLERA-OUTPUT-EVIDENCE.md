---
phase: 64
artifact: terminal-r2-sclera-output-evidence
status: passed
verification_stage: terminal_r2_conjunction
source_commit: 2b243dd
relevant_source_tree_oid: 65acf03d82a3a8389d50c037d9bce7ed345870a4
route: public-facade
private_media: ignored-disposable
metrics: bounded-aggregate-only
---

# Phase 64 Terminal R2 Conjunction Evidence

## Required command order

| order | gate | exit | fixed result |
| ---: | --- | ---: | --- |
| 1 | focused provider/composition/integration/adversarial/renderer tests | 0 | 74 passed; 0 failed; 0 skipped |
| 2 | renderer-helper self-test | 0 | 14 passed |
| 3 | private public-facade output | 0 | 6/6 decoded outputs; helper self-test and live child passed |
| 4 | opaque original-detail preparation | 0 | 4 opaque items; helper self-test and live child passed |
| 5 | repaired checker self-test | 0 | 21 plans; 38 tasks; 16 transition rejections; 3 scoped continuation rejections; 1 scoped positive fixture |
| 6 | no-skip runner self-test | 0 | 14 mutation rejections |
| 7 | one no-skip live SwiftPM child | 0 | 637 executed; 0 failed; 0 skipped; 8 opt-ins |
| 8 | simulator discovery and scheme membership | 0 | one available iPhone simulator selected at execution time |
| 9 | explicit Demo build | 0 | build succeeded |
| 10 | explicit Demo test | 0 | 121 passed; 0 failed; 0 skipped |

## Exact no-skip aggregate

executed_tests: 637
failed_tests: 0
skipped_tests: 0
opt_in_tests_executed: 8
opt_in_test: VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture passed
opt_in_test: VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload passed
opt_in_test: VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload passed
opt_in_test: BeautyEngineGeometryFacadeTests.testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade passed
opt_in_test: BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope passed
opt_in_test: BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope passed
opt_in_test: BeautyTeethWhiteningRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds passed
opt_in_test: BeautyScleraRednessRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds passed

## Fixed aggregate assertions

| category | fixed result |
| --- | --- |
| ordered adversarial inventory | 27 scenarios; 23 accepted; 4 rejected; exact baseline/left/right/rejected ordering |
| bilateral perturbations | 11 left-only; 11 right-only; all six protected families nonzero for each eye |
| proposal and truth population | 744 actual proposals; 1,632 protected-truth pixels; 1,632 recolored protected pixels |
| containment mismatches | all protected, outside, count, and rejected-eye mismatch aggregates are zero |
| rejected-eye peer activity | 4 active-peer scenarios; 64 active-peer proposals |
| renderer inventory | 74 unique cases; one exact public-facade sclera case |
| private output | 6 decoded outputs in fixed positive/negative/no-face baseline/active order; 4 opaque review items |
| positive bound | channel delta at most 44; luminance delta at most 0.018; texture ratio 0.82 through 1.18 |
| negative bound | mean RGB delta at most 0.010; luminance delta at most 0.006; texture ratio 0.82 through 1.18 |
| no-face bound | byte-identical baseline and active output |

## Fifteen specification probes

| requirement | probe | result | fixed predicate |
| --- | --- | --- | --- |
| SCLERA-14 | adjacency | pass | intended endpoint only |
| SCLERA-14 | empty | pass | proposal and protected-truth populations are nonempty |
| SCLERA-14 | ordering | pass | exact ordered 27-scenario inventory |
| SCLERA-15 | boundary | pass | protected intersection and outside mismatch counts are zero |
| SCLERA-15 | precision | pass | RGBA-byte equality for protected and outside truth |
| SCLERA-16 | boundary | pass | positive, negative, and no-face rows satisfy distinct frozen envelopes |
| SCLERA-16 | precision | pass | frozen decimal and byte-exact comparisons retained |
| SCLERA-17 | unclassified | pass | all six output roles explicitly classified |
| SCLERA-18 | adjacency | pass | every gate ran in the fixed serial conjunction |
| SCLERA-18 | empty | pass | no gate was missing, zero, failed, or skipped |
| SCLERA-18 | ordering | pass | focused, helper, private, checker, no-skip, discovery, build, test order retained |
| OUT-05 | adjacency | pass | public and private evidence remain adjacent without runtime coupling |
| OUT-05 | empty | pass | six output roles and four opaque items are nonempty |
| OUT-05 | ordering | pass | positive, negative, no-face and baseline/active order is fixed |
| OUT-05 | concurrency | pass | request-local work roots isolate concurrent invocations |

Only fixed commands, exits, counts, categories, and bounds persist. No private locator, content-derived digest, media, mask, support geometry, pixel, identity, rights detail, raw child output, or freeform review prose is retained.
