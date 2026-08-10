---
phase: 64
artifact: post-repair-sclera-output-evidence
status: passed
verification_stage: post_repair_conjunction
source_commit: 0a19c92bb5a46b2e5302ec066a437627becc8b7e
relevant_source_tree_oid: dfb7944365fdd7943ad3c115b519caa9da444be9
route: public-facade
private_media: ignored-disposable
metrics: bounded-aggregate-only
---

# Phase 64 Post-Repair Conjunction Evidence

## Required command order

| order | command | exit | fixed result |
| ---: | --- | ---: | --- |
| 1 | `swift test --package-path BeautySDK --filter 'BeautyScleraRednessProviderTests\|BeautyLocalRetouchCompositionTests\|BeautyEngineScleraRednessIntegrationTests\|BeautyScleraRednessAdversarialCloseoutTests\|BeautyRendererOutputRegressionTests'` | 0 | 74 passed; 0 failed |
| 2 | `python3 .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py --self-test` | 0 | 14 passed |
| 3 | `PHASE64_REQUIRE_LOCAL_EVIDENCE=1 node .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js` | 0 | 6/6 decoded outputs; strict helper self-test passed; strict helper live passed |
| 4 | `PHASE64_REQUIRE_LOCAL_EVIDENCE=1 node .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js --prepare-review` | 0 | 4 opaque items; strict helper self-test passed; strict helper live passed |
| 5 | `python3 .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py --self-test` | 0 | 18 self-tests; 23 content-scan rejections; 28 review-source rejections; 20 candidate rejections; 19 plans; 34 tasks; 8 threats; 7 states |
| 6 | `node .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-no-skip-swiftpm-runner.js --self-test` | 0 | 14 mutation rejections |
| 7 | `node .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-no-skip-swiftpm-runner.js --run` | 0 | 637 executed; 0 failed; 0 skipped; 8 opt-in tests executed |
| 8 | `xcrun simctl list devices available` and `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -showdestinations` | 0 | iPhone 17e; iOS 26.5; selected UDID is a scheme destination |
| 9 | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,id=303A6825-7086-47E5-B617-D09AE5AB40A0' build` | 0 | BUILD SUCCEEDED |
| 10 | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,id=303A6825-7086-47E5-B617-D09AE5AB40A0' test` | 0 | 121 passed; 0 failed; 0 skipped |

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
| containment mismatches | 0 protected intersections; 0 protected-byte mismatches; 0 outside-proposal byte mismatches; 0 proposal-count mismatches; 0 rejected-eye proposals |
| rejected-eye peer activity | 4 active-peer scenarios; 64 active-peer proposals |
| renderer inventory | 74 unique cases; one direct public-facade sclera case; collision keys case-folded and canonically normalized |
| private output | 6 decoded outputs in fixed positive/negative/no-face baseline/active order; 4 opaque review items |
| positive frozen bounds | maximum channel delta 44; absolute luminance delta no greater than 0.018; texture ratio 0.82 through 1.18 |
| negative frozen bounds | mean RGB delta no greater than 0.010; luminance delta no greater than 0.006; texture ratio 0.82 through 1.18 |
| no-face frozen bound | byte-identical baseline and active output |

## Fifteen specification probes

| requirement | probe | result | fixed predicate |
| --- | --- | --- | --- |
| SCLERA-14 | adjacency | pass | intended endpoint only |
| SCLERA-14 | empty | pass | 744 proposals and 1,632 protected pixels are nonempty |
| SCLERA-14 | ordering | pass | exact ordered 27-scenario inventory |
| SCLERA-15 | boundary | pass | protected intersection and outside-proposal mismatch counts are zero |
| SCLERA-15 | precision | pass | RGBA-byte equality at protected and outside-proposal pixels |
| SCLERA-16 | boundary | pass | positive, negative, and no-face rows satisfy their distinct frozen envelopes |
| SCLERA-16 | precision | pass | frozen decimal and byte-exact comparisons retained |
| SCLERA-17 | unclassified | pass | all six output roles explicitly classified |
| SCLERA-18 | adjacency | pass | every required command ran in the fixed serial conjunction |
| SCLERA-18 | empty | pass | no required stage was missing, zero, failed, or skipped |
| SCLERA-18 | ordering | pass | focused, helper, private, checker, no-skip, discovery, build, test order retained |
| OUT-05 | adjacency | pass | public and private evidence are adjacent without runtime coupling |
| OUT-05 | empty | pass | six output roles and four opaque items are nonempty |
| OUT-05 | ordering | pass | positive, negative, no-face and baseline/active ordering is fixed |
| OUT-05 | concurrency | pass | request-local work roots isolate concurrent invocations |

The evidence retains only fixed commands, exit codes, allowlisted counts, categories, and bounds. It contains no private media, locator, digest, rights detail, identity, support, masks, coordinates, pixels, raw child output, or freeform review prose.
