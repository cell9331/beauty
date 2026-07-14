---
phase: 30-eye-safety-ledger-and-closeout
status: passed
verified: 2026-07-11
requirements:
  - EYE-04
  - EYE-05
  - EYE-06
  - EYE-07
---

# Phase 30 Eye Safety Evidence

full_suite_tests: 178

## Scope

This artifact records command-backed SDK-only evidence for the existing four public eye parameters. It covers input/cap safety, eye-specific degradation, combined weakening, and the unchanged Phase 29 renderer regression. It does not authorize any status-ledger edit.

## Requirement Mapping

| Requirement | Evidence | Result |
| --- | --- | --- |
| EYE-04 | `testEYE04EyeInputsNormalizePositiveOnlySignedOverflowAndNonFiniteValues`, `testEYE04EyeCapsResolveExactValuesDirectionsWarningsAndCounts`, `testEYE04NegativePositiveOnlyEyeInputsAreNoOps` | passed |
| EYE-05 | `testMissingEitherEyeInputReturnsStableSkipReasonWithoutPoints`, `testMissingEitherEyeGroupSkipsEyesZerosStrengthsAndKeepsOtherDomainsActive`, `testReusedEyeGeometrySkipsEyesZerosStrengthsAndPreservesNonEyeReuseReduction`, `testStaleEyeGeometrySkipsEyesZerosStrengthsWithDistinctReason`, `testEyeNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata` | passed |
| EYE-06 | `testEYE06EachVisibleEyeBehaviorWeakensWithFaceShapeAndPreservesDirection`, `testEYE06AllEyeMultiDomainCaseEmitsStableWeakeningEvidence` | passed |

## Focused Test Evidence

| Suite | Observed result |
| --- | --- |
| `BeautyParametersTests` | 7 tests, 0 failures |
| `BeautyEffectResolverTests` | 12 tests, 0 failures |
| `EyeWarpProviderTests` | 6 tests, 0 failures |
| `MissingLandmarkDegradationTests` | 13 tests, 0 failures |
| `CombinedEffectSafetyTests` | 7 tests, 0 failures |
| `BeautyEngineGeometryFacadeTests` | 9 tests, 0 failures |
| `BeautyRendererOutputRegressionTests` | 7 tests, 0 failures |
| Full `swift test --package-path BeautySDK` | 178 tests, 0 failures |

## Input and Cap Matrix

| Field | Public behavior | Exact resolver evidence |
| --- | --- | --- |
| `eyeSize` | negative becomes zero; overflow becomes 1; non-finite becomes zero | positive cap 0.45; negative is a silent no-op |
| `eyeDistance` | signed overflow becomes +1 or -1; non-finite becomes zero | signed caps +0.30 and -0.30 |
| `eyeYPosition` | signed overflow becomes +1 or -1; non-finite becomes zero | signed caps +0.25 and -0.25 |
| `eyeTailLift` | negative becomes zero; overflow becomes 1; non-finite becomes zero | positive cap 0.30; negative is a silent no-op |

Each independent cap case records `beauty_strength_capped` and `beauty.effects.cappedCount == 1`. The abnormal-input matrix covers 12 field/value non-finite combinations.

## Degradation Matrix

| Condition | Stable code | Aggregate behavior |
| --- | --- | --- |
| Either eye group incomplete | `eye_inputs_missing` | eyes skipped, four eye strengths zero, `beauty.effects.skippedEyeDomains == 1` |
| Reused eye geometry | `eye_geometry_reused_skipped` | eyes skipped and zero; non-eye reusable geometry keeps scale 0.5 |
| Stale eye geometry | `eye_geometry_stale_skipped` | eyes skipped, four eye strengths zero, no eye-only geometry point metric |
| Public no-face request | `face_effects_skipped_no_face` | output extent preserved; color/filter continue; detection counts remain aggregate |

The degradation suites explicitly reject eye-side labels and raw geometry vocabulary in warnings and metric keys.

## Combined-Weakening Matrix

Six normal-versus-combined cases cover positive size, both signed distance directions, both signed vertical directions, and positive tail lift. Each combined case uses face-shape geometry, preserves the applicable sign, emits `combined_geometry_weakened`, records `beauty.effects.weakenedCount > 0`, and records `beauty.effects.geometryStrengthScale < 1`.

The all-eye multi-domain case activates eyes, face shape, and nose, preserves negative distance and positive vertical direction, and records exactly six weakened fields.

## Phase 29 Renderer Regression

- `BeautyExampleRenderer` built successfully and wrote 161 outputs for 23 cases across 7 fixtures.
- The unchanged helper passed: 161/161 outputs.
- Portrait eye-vs-baseline top-region comparisons passed: 36/36.
- Representative no-face eye output is present for `eyeSize_0p35`.
- Observed dimension groups: 64x64, 506x900, 675x900, and 1728x2304.
- Gallery generation was not rerun because gallery logic did not change.

## Generated-Artifact Policy

Representative eye outputs are ignored. `git ls-files example-images/output example-images/gallery` returned no tracked generated files. Generated PNGs remain local evidence and are not committed baselines.

## Active-Source Boundary Classification

| Gate | Observed result |
| --- | --- |
| Public/SPI raw geometry across six SDK roots | `public_geometry_candidates: 0` |
| Demo/renderer internal SDK imports | 0 matches |
| API-shaped network/cloud paths | 0 matches |
| StoreKit/purchase/subscription/receipt/paywall/entitlement paths | 0 matches |
| New public eye stored fields | 0 additions; 31-field inventory test passed |
| `VIP-COMMERCIAL-ALLOW-01` | `vipChip use` is a static Home view reference |
| `VIP-COMMERCIAL-ALLOW-02` | `private vipChip declaration` is a private static view declaration |

unclassified_matches: 0

These results satisfy EYE-07 for the frozen pre-promotion source. Neither static `vipChip` occurrence is an API-shaped commercial execution path.

## Evidence Field Allowlist

Durable fields are limited to relative paths, commands, test names/counts, case IDs, dimensions, warning codes, aggregate metric names/counts, statuses, and limitations.

## Non-Claims

This evidence does not claim a Demo change, new public parameter, device parity, commercial visual review, broad reference-product parity, launch completion, committed image baseline, or whole eye-branch completion.

## Rerun Protocol

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output
git check-ignore example-images/output/e1__eyeSize_0p35.png example-images/output/e1__eyeDistance_minus0p25.png example-images/output/no-face-gradient__eyeSize_0p35.png
git ls-files example-images/output example-images/gallery
```
