---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T03:16:20Z
depth: standard
status: clean
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-subpixel-probe.py
  - BeautySDK/Tests/BeautyEffectsTests/Phase95ImageFormationTests.swift
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
repository_head: a2d1c94d46da9225269c61f512da40cbf24b2bec
input_sha256:
  scripts/phase95-root-subpixel-probe.py: 3388326c7027b416565239406c77260d04884debca28bd96616ddac263fee523
  BeautySDK/Tests/BeautyEffectsTests/Phase95ImageFormationTests.swift: cb2c668d50e681a592d38e68b87963f860ade21b09536f27c3737ddf9c6562fa
  BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift: bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-SUBPIXEL-MODEL.md: c65eb9541e06443ee2ee1ae35820d57584939ade4333cb3482b968d491fe3027
context_sha256:
  AGENTS.md: 13701c303143657a504312b7420ef0ba64f065e422a14d191a26c7109800ecf1
  PLANS.md: 58d112347f1edee5e88655cd14b07b2ddfaa3766dbaea02ad8f83d86ad3be513
  DESIGN.md: 12e1c812359a736d40edaeece5bcade9b0c5b14aea66c653c1764b4804577d3c
  QUALITY_SCORE.md: 5a5193f3bcb811b7d3deb5219aafce93d87cdeec448b87b93abfff12d495c3b1
dependency_context_sha256:
  BeautySDK/Package.swift: 540e729524cf2d2f0bcc1ed1d47a6b4a7927957adae881f1e99c24830103a694
  BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift: a9fefb23f771b655000e20aeb372a0d78e0e7ae2f261ca2d1f499d92d6f7e5a1
  BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift: 8683da97791e83283d72fb9b86fd70d1fc7b901effedab06280fb4e7d78aba2e
  BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift: ad7c291fb37e0fd31a37470b9aa57a4d2354d1fe24a19ee564617c07bd5ba1d1
validation:
  python_self_test:
    exit_code: 0
    sampler_cases: 126
    sampler_reference_matches: 126
    truth_containments: 126
    maximum_byte_error: 0.5
    declared_byte_bound: 0.501953125
    negative_rejections: 7
    asymmetric_blur_equivalence_retained: true
  swiftpm_focused:
    exit_code: 0
    tests: 2
    failures: 0
    skips: 0
  independent_math:
    complete_set_cases: 118
    matching_intervals: 92
    matching_rejections: 26
    checked_truth_containments: 83
    mismatches: 0
  in_memory_substitution_rejections: 3
portrait_scoring_attempts: 0
source_registration_authorized: false
acceptance_credit: false
phase_complete: false
---

# Phase 95: Independent narrow subpixel review

## Summary

No supported BLOCKER or WARNING was found in the two submitted files under the declared generated-only model. This conclusion follows direct code and sampler-dependency inspection, independent exact feasible-set reconstruction, and negative substitutions, as well as the requested test runs. It is not a claim that passing tests prove general correctness.

Both source files were read completely. The production sampler was read as a dependency, not modified or independently approved in its entirety. The four primary input hashes above matched before and after execution; the script's pinned sampler SHA matches the actual whole production file. HEAD alone does not identify these working-tree inputs.

## Narrative Findings (AI reviewer)

None within the narrow claims. There are no actionable defect findings or requested source fixes in this report. The documented unfinished obligations below are limitations, not findings.

### Interval arithmetic and truth checks

At `scripts/phase95-root-subpixel-probe.py:59-94`, the cell equation has the correct inverse-sampling sign: for `d` in `[j,j+1]`, the interpolated value is `b + (a-b)(d-j)`. Positive and negative slopes, zero slopes, closed endpoints, adjacent-cell unions, disconnected sets, and search-boundary rejection are handled consistently. The returned interval is the complete feasible set only when that set is connected and strictly inside the search limits; other sets reject explicitly.

At lines 97-105, interval subtraction encloses the left-minus-right contraction, and the margin requires the candidate lower bound to clear both source zero and the neutral upper bound by 16 Q16. At lines 161-194, actual sampler bytes are checked against independently generated rational pixels before truth containment or power is credited. Mandatory power at 32 Q16 and rejection of sub-threshold promotion are distinguished from reported observations at 17/20 Q16. The seven named negative controls and retained asymmetric-blur equivalence match their actual assertions at lines 209-239.

### Sampler and Swift oracle boundaries

The extracted `writeInterpolatedPixel` body is unchanged, guarded by whole-file SHA before execution and a byte comparison afterward (`scripts/phase95-root-subpixel-probe.py:108-146`). The wrapper supplies the same clamp helper, opaque equal rows, and explicit horizontal sample coordinates. This tests interpolation and rounding for the declared generated grid, not the entire renderer.

`Phase95ImageFormationTests.swift:41-55` checks neutral canonical pixels and an in-memory PNG round trip. Lines 58-112 check actual nonzero rendered changes, independent Double evaluation of the selected horizontal field, unchanged pixels outside its support, alpha, extent, and exact PNG round-trip bytes. Reading control points here is legitimate input to a sampler oracle; it is not independent evidence of semantic movement.

The Double reference rounds to an integer at lines 99-100 before applying the one-byte tolerance at lines 111-112. Thus that assertion alone implies at most 1.5 bytes relative to the unrounded Double value, not a certified continuous one-byte image-formation bound. The separately reported Python one-byte budget remains a hypothetical budget sensitivity run. The model already disclaims a certified full-pipeline budget, so this is not an implementation defect under the current claims.

## Actual aggregate execution results

Executed locally on 2026-09-15:

- `python3 scripts/phase95-root-subpixel-probe.py --self-test`: exit 0; 126 actual sampler/reference matches, 126 truth containments, maximum error 0.5 byte, seven negative rejections, retained asymmetric two-tap blur/translation equivalence.
- `swift test --package-path BeautySDK --filter Phase95ImageFormationTests`: exit 0; XCTest executed 2 methods, zero failures and zero skips. Both methods cover 64×48 and 257×193. The separate Swift Testing footer reported zero tests; it is not additional test credit. The tests assert the bounds described above but do not emit exact per-image error/change maxima, so none are invented here.

Each power entry below represents nine width/seed pairs. The threshold remained 16 Q16.

| Generator change Q16 | Passed with 0.501953125-byte budget | Passed with one-byte budget |
| --- | --- | --- |
| -32 | 0/9 | 0/9 |
| 0 | 0/9 | 0/9 |
| 15 | 0/9 | 0/9 |
| 16 | 0/9 | 0/9 |
| 17 | 9/9 | 3/9 |
| 20 | 9/9 | 9/9 |
| 32 | 9/9 | 9/9 |

### Independent adversarial checks

An in-memory exact-rational oracle independently enumerated every integer knot and every channel/error-band crossing, evaluated feasibility at all crossing points and intervening midpoints, then merged the resulting feasible pieces. Its complete set and rejection disposition agreed with the implementation in **118/118 cases: 92 accepted intervals, 26 rejections, zero mismatches**. Generator truth was separately checked in 83 admitted cases with error budgets at least half a byte; zero exclusions occurred. Accepted zero-error cases account for the remaining nine intervals.

Reproducible matrix: width 64, center 32, texture seeds 2/11/31; shifts `j + f` for every integer `j` from -4 through 3 and `f` in `{0, 1/7, 1/2, 6/7}`, plus +4. Error budgets cycle by shift index through `{0, 1/2, ERROR, 1, 2}`. These 99 cases were supplemented by five periodic sources with periods 1–5, and fourteen cases at shifts `{-27/7, -2, -1/1000, 0, 1/1000, 2, 27/7}` using seed 17: alternating ±1 channel perturbations with error 2, and a deliberately incompatible center pixel with the default error. This exercises all eight cells, exact integer joins, non-dyadic translations, endpoint searches, flat/disconnected alternatives, bounded noise, and infeasible data. Only aggregates are retained.

Three additional in-memory substitutions were rejected: returning identity pixels for requested shifts and reversing all requested shifts each raised `sampler_reference_mismatch`; substituting an all-zero expected SHA raised `sampler_identity`. No reviewed file was edited to perform these checks.

## Scope, preservation, and disposition

The review applied the gsd-code-review workflow inline under the owner's explicit two-file scope. Project instructions, current Phase95 active PLANS and DESIGN/QUALITY sections, the model, and the local skill index were read. The missing bootstrap path was resolved to its installed `.agents/gsd-core` location; the reviewer skill query returned no additional configured skills. Serena was not available, so dependency tracing used direct reads and searches. Neither scoped file is ignored; no structural pre-pass was supplied.

Arbitrary photometric safety, anatomical registration, spatially varying root correspondence, full-facade coverage, portrait scoring, and Phase95 completion remain outside these demonstrated claims. Opaque already-canonical sRGB fixtures and one generated mouth field cannot establish those properties. No source registration, scoring, production change, or completion permission follows from this report.

Only this new report was authored. No private inputs, network uploads, extra agents, commits, raw-pixel artifacts, or saved child transcripts were used. SwiftPM performed its normal ignored build/cache writes. Existing unrelated edits and prior review artifacts were preserved, including `95-REVIEW.md` (SHA256 `b266e3ab35a875377ca3d66293d167a88936939e3f84ad4413d1e9466405d062`).
