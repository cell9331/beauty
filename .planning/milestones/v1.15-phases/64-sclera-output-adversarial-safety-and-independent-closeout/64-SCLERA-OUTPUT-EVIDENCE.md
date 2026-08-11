---
phase: 64
artifact: standalone-sclera-output
status: passed
fresh_after_plans: [64-07, 64-08]
source_commit: 522917ee2ca2dbd9b5e3ab3fab65d8b05461a69a
source_tree: 2fb1c37ebda48dfc94aa2276788a24312f3a3c02
outputs: 6/6
route: public-facade
private_media: ignored-disposable
metrics: bounded-aggregate-only
strict_helper_self_test: pass
strict_helper_live: pass
---

# Phase 64 Fresh Standalone Sclera Conjunction Evidence

## Fixed Result Summary

| gate | exit | fixed result |
| --- | ---: | --- |
| focused provider/composition/integration/adversarial/renderer | 0 | 73/73; protected intersections 0; protected byte mismatches 0; outside-proposal byte mismatches 0 |
| private native Vision wrapper | 0 | pass |
| strict output helper self-test | 0 | 14/14 |
| private public-facade output | 0 | 6/6; helper self-test pass; helper live pass |
| private opaque review preparation | 0 | 4/4 opaque items prepared; helper self-test pass; helper live pass |
| closeout checker self-test | 0 | 18/18 aggregate mutations; 23 content-scan rejections; 7 source-freeze rejections |
| live pre-promotion checker | 0 | 8/8 HIGH owners |
| four-state repository privacy | 0 | tracked 1465; staged 1465; working 1; untracked 0 |
| full SwiftPM | 0 | 636 executed; 0 failures; 8 documented opt-in skips |
| execution-time iPhone Simulator discovery | 0 | iPhone 17 Pro / iOS 26.5 (UDID 85C6D6E8-67B4-4F82-BC7F-D30F82E0D160) present in scheme destinations |
| explicit Simulator Demo build | 0 | BUILD SUCCEEDED |
| explicit Simulator Demo tests | 0 | 121/121; 0 failures; 0 skips |

The eight full-suite skips are the existing explicitly opt-in Vision cases. The
required native Vision pair ran separately through the fixed private wrapper and
passed; no required command was skipped or conditionally credited.

## Commands Executed in Required Order

1. `swift test --package-path BeautySDK --filter 'BeautyScleraRednessProviderTests|BeautyLocalRetouchCompositionTests|BeautyEngineScleraRednessIntegrationTests|BeautyScleraRednessAdversarialCloseoutTests|BeautyRendererOutputRegressionTests'`
2. `PHASE62_REQUIRE_LOCAL_EVIDENCE=1 node .planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js -- env PHASE63_REQUIRE_LOCAL_EVIDENCE=1 swift test --package-path BeautySDK --filter BeautyScleraRednessRealFixtureTests`
3. `python3 .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py --self-test`
4. `PHASE64_REQUIRE_LOCAL_EVIDENCE=1 node .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js`
5. `PHASE64_REQUIRE_LOCAL_EVIDENCE=1 node .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js --prepare-review`
6. `python3 .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py --self-test`
7. `python3 .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py --pre-promotion`
8. `python3 .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py --pre-promotion --threat T-64-01` … `--threat T-64-08` (eight isolated invocations)
9. `swift test --package-path BeautySDK`
10. `xcrun simctl list devices available -j` → UDID `85C6D6E8-67B4-4F82-BC7F-D30F82E0D160` (iPhone 17 Pro, iOS 26.5); `xcodebuild -showdestinations` membership verified
11. `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,id=85C6D6E8-67B4-4F82-BC7F-D30F82E0D160' build` → ** BUILD SUCCEEDED **
12. `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,id=85C6D6E8-67B4-4F82-BC7F-D30F82E0D160' test` → 121/121 passed; 0 failed; 0 skipped

## Bounded Output Assertions

- Renderer inventory remains exactly 74 unique cases with one direct
  `scleraRednessReduction_1p00` public-facade case.
- The positive, negative, and no-face matrix produced exactly six decoded
  outputs; the positive improved at least one eye, the negative remained within
  frozen naturalness bounds, and no-face was byte exact.
- The bilateral oracle executed 27 ordered scenarios over all twelve protected
  eye/region families, with 744 actual proposals and 1,632 protected truth
  pixels. Every protected intersection, protected-byte mismatch,
  outside-proposal mismatch, proposal-count mismatch, and rejected-eye proposal
  count was zero; all four rejected scenarios retained an active peer.
- Strict-helper self-test and live execution were distinct child invocations
  with exact role-specific schemas.
- DeviceRGB/named-sRGB remains an unscored Phase 65 SAFE-06 warning.

## Source-Tree Freeze (T-64-05)

- Immutable tree OID: `2fb1c37ebda48dfc94aa2276788a24312f3a3c02`
- Recomputed via `git write-tree` at execution time
- 16 canonical Phase 64 relevant-source paths verified by
  `check_phase64_sclera_closeout.py validate_review_source_state`
- Any post-freeze change to one of these blobs invalidates the entire
  conjunction per D-16

This artifact contains fixed aggregate evidence only. It retains no private
media, locator, asset digest, rights detail, reviewer identity, support, mask,
geometry, coordinate, pixel value, or freeform review detail.
