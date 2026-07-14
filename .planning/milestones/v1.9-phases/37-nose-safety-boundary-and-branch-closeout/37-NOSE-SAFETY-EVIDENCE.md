---
phase: 37
status: passed
requirements: [NOSE-10, NOSE-11, NOSE-12, NOSE-13]
observed_at: 2026-07-14T03:01:39Z
promotion: pending-plan-37-04
---

# Phase 37 Nose Safety and Boundary Evidence

## Verdict

The pre-promotion gate passes from current source. NOSE-10 through NOSE-13 have fresh nonzero runtime, output, boundary, artifact, review, and ASVS L1 evidence. `提升` remains `future`, `山根` remains `partial`, and branch-level `鼻子` remains `partial`; Plan 37-04 is the only authorized promotion owner.

## Fresh SwiftPM Evidence

Every filtered command executed a nonzero XCTest suite. The separate Swift Testing footer reporting zero tests in zero suites is not used as evidence.

| Command | Observed result |
| --- | --- |
| `swift test --package-path BeautySDK --filter BeautySafetyCapsTests` | 2/2, zero failures |
| `swift test --package-path BeautySDK --filter BeautyEffectResolverTests` | 15/15, zero failures |
| `swift test --package-path BeautySDK --filter NoseWarpProviderTests` | 16/16, zero failures |
| `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` | 30/30, zero failures |
| `swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` | 10/10, zero failures |
| `swift test --package-path BeautySDK --filter GeometryConflictResolverTests` | 9/9, zero failures |
| `swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests` | 11/11, zero failures |
| `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | 10/10, zero failures |
| Focused aggregate | **103/103**, zero failures |
| `swift test --package-path BeautySDK` | **228/228**, zero failures; 15.749 s XCTest |

The exact-cap matrix proves independent `noseRootNarrowing` and `noseTipLift` behavior at exact `0.25`. The six-field matrices include both signed `noseTipSize` directions, zero/no-face/missing/provider-empty/stale/reused transitions, redaction, and final provider eligibility. Combined evidence observes exact retained totals `1.75`, `1.70`, `1.65`, `6.65`, `2.95`, and `1.40` at the fixtures documented by Plans 37-01/02; removed work contributes zero times.

## Renderer and Unchanged Phase 36 Helper

| Command | Observed result |
| --- | --- |
| `swift build --package-path BeautySDK --product BeautyExampleRenderer` | passed |
| `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` | passed; renderer wrote the expected matrix |
| Phase 36 strict helper `--self-test` | passed its duplicate/missing/extra/corrupt, bounded-decode, descriptor-race, and ROI/watermark negatives |
| Phase 36 strict helper live | exactly **36 cases x 7 fixtures = 252/252** non-empty, fully decoded, same-dimension PNGs |
| New-field baseline comparisons | **12/12** |
| Independent root/bridge comparisons | **6/6**; `noseRootNarrowing` does not borrow `noseBridge` evidence |
| Independent lift/signed-tip comparisons | **12/12**; `noseTipLift` does not borrow either signed `noseTipSize` direction |
| Representative no-face comparisons | **2/2** |
| `python3 example-images/generate_gallery.py --self-test` | passed bounded descriptor, copy, staging, publication, quarantine, and containment negatives |

The live helper also retained the committed fixed minima: root/baseline 1,130 changed pixels and 5,125 absolute RGB delta; lift/baseline 1,644 and 26,334; root/bridge 1,291 and 5,951; lift/positive-tip 1,839 and 20,433; lift/negative-tip 2,132 and 34,911.

## Fail-Closed Boundary and Artifact Evidence

| Gate | Observed result |
| --- | --- |
| `python3 -m py_compile .../check_nose_safety_boundaries.py` | passed |
| Boundary checker `--self-test` after review fixes | **33/33** deterministic positive/adversarial checks |
| Boundary checker default live | **13/13**; exact 33 fields = 32 numeric plus `filterId`; dependencies 0; classified public/SPI guard 1; forbidden imports/network/commercial/diagnostic matches 0 |
| Boundary checker `--allow-promotion` against current repository | expected nonzero; promotion owners and lifecycle state are deliberately absent/pending |
| Generated paths | output 252 local PNGs; gallery 252 local PNGs; tracked 0; staged 0; representative paths ignored |
| Archive/worktree state | no active archive or `.worktrees` changes |
| `git diff --check` | passed |

The checker treats search exit 0 as matches requiring classification, exit 1 as no matches, and every other exit or missing tool as blocking. Known testing-SPI and guard literals are explicitly classified; tool errors are never suppressed.

## Review, Security, and Authorization Boundary

- The scoped Phase 37 review found three checker-test/owner-correlation warnings; all are fixed and recorded in `37-REVIEW-FIX.md`.
- The post-fix re-review in `37-REVIEW.md` is clean: 0 critical, 0 warning, 0 informational findings.
- `37-SECURITY.md` closes T37-01 through T37-08 at ASVS Level 1 with `threats_open: 0` after the full live gate.
- Generated images are disposable local evidence. No output, gallery, staging, or quarantine artifact enters git.
- This evidence authorizes Plan 37-04 to perform one atomic product-owner promotion. It does not itself promote a row, branch, requirement ledger, PROJECT, QUALITY_SCORE, or root product contract.

## Non-Claims

No physical-device parity, subjective/commercial naturalness, optimized performance qualification, packaging, shipping, launch readiness, milestone audit, archive, tag, or cleanup result is claimed. The independent v1.9 milestone audit remains later lifecycle work.
