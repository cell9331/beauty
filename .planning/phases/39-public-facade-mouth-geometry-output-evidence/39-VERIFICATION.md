---
phase: 39-public-facade-mouth-geometry-output-evidence
status: passed
verified: 2026-07-14
requirements: [MOUTH-09, MOUTH-10, MOUTH-11]
focused_tests: 11
full_tests: 260
renderer_outputs: 308
gallery_outputs: 308
review_status: clean
---

# Phase 39 Verification

## Verdict

Passed. Phase 39 proves isolated public-facade output for all five remaining mouth geometry controls, direct signed/semantic distinction in one fixed mouth ROI, exact no-face behavior, and ignored output/gallery containment.

## Requirement Evidence

| Requirement | Status | Evidence |
| --- | --- | --- |
| MOUTH-09 | passed | Eight exact provisional `0.25` cases extend the ordered renderer from 36 to 44; focused source/no-face regression passes 11/11. |
| MOUTH-10 | passed | Archive-safe helper discovers 44 cases × 7 fixtures, fully decodes 308/308 same-dimension PNGs, and passes 48 visibility, 18 signed, 12 peak, and 18 plump direct comparisons above the watermark. |
| MOUTH-11 | passed | Eight no-face outputs preserve 64 × 64 and match baseline across 2,048 label-safe pixels; gallery is an exact 44-case/308-file bijection; outputs/gallery are ignored, untracked, and unstaged. |

## Runtime Evidence

- Focused `BeautyRendererOutputRegressionTests`: **11/11**, zero failures.
- Full `swift test --package-path BeautySDK`: **260/260**, zero failures.
- Renderer product build: passed; final guarded clean run wrote 308 files.
- Helper/gallery self-tests and Python compilation: passed.
- Strict helper: **308/308** decoded and dimension-preserving; **96/96** portrait direct pairs; **8/8** no-face no-ops.
- Gallery: **308** regular PNGs, no symbolic links or non-PNG files, exact duplicate-free renderer bijection.

The weakest strict family remains `lip_peak_vs_baseline` at 1,921 changed pixels and 16,651 RGB delta, above frozen floors of 1,000 and 10,000. The fixed ROI is x `[0.10,0.90)`, y `[0.40,0.82)` and is asserted above the renderer-matched watermark boundary.

## Structural and Security Evidence

- Standard review covered four source/test/helper files and is clean after one JPEG dimension-bound fix.
- ASVS L1 review records `threats_open: 0`.
- Protected runtime, product ledger, PROJECT, QUALITY_SCORE, Package.swift, and Demo diffs are empty.
- Internal-import, dependency, network/cloud/commercial, generated-artifact, inventory, one-facade-call, and diff-hygiene gates pass.

## Boundaries

The `0.25` values remain provisional evidence inputs. Phase 39 does not finalize caps, prove exhaustive missing/stale/reused/provider-empty/conflict behavior, promote `上下`/`倾斜`/`左右`/`M唇`/true `丰唇`, or complete branch-level `嘴唇`. It makes no device/commercial naturalness, performance certification, packaging, shipping, launch-readiness, milestone-audit, or milestone-completion claim. Phase 40 owns safety, boundaries, and exact promotion.
