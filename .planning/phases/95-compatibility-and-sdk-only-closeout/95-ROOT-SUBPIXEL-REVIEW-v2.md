---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T03:20:07Z
depth: standard
review_mode: fix_only
status: clean
files_reviewed: 1
files_reviewed_list:
  - BeautySDK/Tests/BeautyEffectsTests/Phase95ImageFormationTests.swift
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
input_sha256:
  BeautySDK/Tests/BeautyEffectsTests/Phase95ImageFormationTests.swift: 8d73baf5bdb182d7b6819af571256811b777720b088285ed6f615a003368375b
unchanged_dependency_sha256:
  scripts/phase95-root-subpixel-probe.py: 3388326c7027b416565239406c77260d04884debca28bd96616ddac263fee523
  BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift: bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a
prior_test_sha256: cb2c668d50e681a592d38e68b87963f860ade21b09536f27c3737ddf9c6562fa
preserved_review_sha256:
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-SUBPIXEL-REVIEW-v1.md: 8f2527e1069b0ca5e4d7cb727d5c19b7ccb3acad4e5f17d8188d306e9609a196
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-REVIEW.md: b266e3ab35a875377ca3d66293d167a88936939e3f84ad4413d1e9466405d062
validation:
  focused_swiftpm:
    exit_code: 0
    tests: 2
    failures: 0
    skips: 0
  exact_delta_reconstruction: passed
  broader_math_rerun: false
  python_probe_rerun: false
rounded_reference_limitation: resolved_for_selected_generated_grid
source_registration_authorized: false
portrait_scoring_attempts: 0
acceptance_credit: false
phase_complete: false
---

# Phase 95: Fix-only continuous-reference recheck

## Summary

The change resolves v1's rounded-reference limitation for the selected generated fixtures. No BLOCKER or WARNING was found in this delta. This report supplements v1 and preserves its historical results and broader scope limits.

## Narrative Findings (AI reviewer)

None. At `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/Phase95ImageFormationTests.swift:81`, `maximumError` now infers `Double`. Lines 100–102 retain the unrounded Double interpolation result and compare `abs(Double(output[index]) - expected)` directly. Lines 112–113 still require a maximum error of at most 1 byte and describe the unrounded reference correctly. There is no intervening integer conversion or reference rounding that could introduce the former extra half-byte allowance.

Delta verification was exact: reversing only these numeric-reference edits and the assertion-message update in memory reproduced the complete v1-reviewed test SHA256. The fixture generation, field, dimensions, support checks, alpha/extent checks, PNG equality, and neutral test are unchanged. No source file was written for this comparison.

## Actual focused validation

`swift test --package-path BeautySDK --filter Phase95ImageFormationTests` completed with exit 0 on 2026-09-15: **2 XCTest methods, 0 failures, 0 skips**. Both the horizontal-field/PNG method and the canonical-neutral/PNG method passed. The separate Swift Testing footer's zero tests is not additional test credit.

For the generated opaque canonical sRGB images at **64×48 and 257×193**, with the existing `mouthWidth: -0.35` horizontal field, every sampled RGB output channel is within **1 byte of the unrounded Double reference** in this run. Exact output-versus-PNG-reload equality also passed, so the same bound applies to those reloaded bytes. This is a continuous-valued reference comparison on the finite generated pixel grids. Exact observed maxima are not printed by the tests and are not claimed here.

## Limits and preservation

This result does not establish a universal continuous image-formation bound, exact-real arithmetic certification, arbitrary photometric safety, spatially varying root correspondence, anatomical motion, full-facade coverage, or portrait accuracy. Control points remain inputs to a sampling oracle, not independent semantic truth. The Python probe and broader interval mathematics were not rerun; their historical results remain in v1. The probe and production sampler hashes still match v1.

Only this new v2 report was authored. The original reviews and unrelated edits were preserved. No private input, upload, raw-pixel artifact, saved child transcript, extra agent, production edit, or commit was used. SwiftPM performed its normal ignored build/cache writes. This recheck grants no source-registration, scoring, or Phase95-completion permission.
