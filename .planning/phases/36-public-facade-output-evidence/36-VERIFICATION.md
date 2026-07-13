---
phase: 36
status: passed
verified: 2026-07-13
requirements: [NOSE-07, NOSE-08, NOSE-09]
---

# Phase 36 Verification

## Verdict

Passed. Fresh command evidence verifies exactly the Phase 36 public-facade renderer, strict output helper, ignored gallery, representative no-face, privacy, and containment contract for NOSE-07 through NOSE-09. No Phase 37 safety, cap, boundary-closeout, product-promotion, or readiness claim is included.

The complete focused/full SwiftPM, renderer build, guarded clean renderer/helper/gallery, containment, no-promotion, schema-drift, and diff-hygiene sequence was rerun after these Phase 36 closeout documents and ledgers were written; the observed results below are from that final post-documentation pass.

## Observed Runtime Evidence

| Gate | Observed result |
| --- | --- |
| Focused renderer XCTest | 10/10 `BeautyRendererOutputRegressionTests` passed, zero failures |
| Full SwiftPM | 220/220 XCTest cases passed, zero failures |
| Renderer product build | `BeautyExampleRenderer` built successfully with Xcode developer tools |
| Guarded clean render | exact physical ignored output root; 36 cases × 7 fixtures wrote 252 PNGs |
| Strict decoder/helper | 252/252 non-empty, fully decoded, same-dimension PNGs; no missing or unexpected output |
| Gallery | exact duplicate-free renderer/gallery case bijection; clean generation wrote 252 PNGs |
| Generated-artifact containment | representative output/gallery paths ignored; zero tracked or staged files under output/gallery |

## Output and Independence Results

- The discovered inventory is 36 renderer cases and seven recursive fixtures, including exactly one `noseRootNarrowing_0p25` and one `noseTipLift_0p25` case.
- All 252 output PNGs preserve their fixture dimensions: 36 at 64 × 64, 144 at 506 × 900, 36 at 675 × 900, and 36 at 1728 × 2304.
- The fixed top-origin ROI is x `[0.25, 0.75)` and y `[0.20, 0.70)`, wholly above the renderer-matched watermark boundary. Acceptance floors were already frozen at 500 changed pixels and 2,000 absolute RGB delta.
- Root visibility passed 6/6 with minima 1,130 changed pixels and 5,125 RGB delta; lift visibility passed 6/6 with minima 1,644 and 26,334. Aggregate new-field-to-baseline evidence is 12/12.
- Root-to-bridge independence passed 6/6 with minima 1,291 and 5,951. Lift-to-positive-tip passed 6/6 with minima 1,839 and 20,433; lift-to-negative-tip passed 6/6 with minima 2,132 and 34,911. Aggregate lift-to-signed-tip evidence is 12/12.
- Both new no-face outputs fully decode, preserve 64 × 64 extent, and are baseline-identical across the fixed 2,048-pixel watermark-safe fallback (2/2). Focused facade XCTest separately verifies `.noFace`, `.noFaceDetected`, zero used faces, category-only warning/metrics, and redacted diagnostics.

## Boundary and Hygiene Gates

| Gate | Observed result |
| --- | --- |
| Public/internal renderer import | Only `BeautySDK` plus AppKit/CoreImage/Foundation/ImageIO; exactly one `engine.processResult` call site |
| Raw geometry/privacy | No renderer import or use of package-internal geometry, landmarks, control points, or raw geometry payloads |
| Dependency/network/cloud/commercial | Package.swift, active product sources, and Demo are unchanged from the Phase 36-03 baseline; renderer token scan is clear |
| No promotion | SHAPE_FEATURE_LEDGER, FEATURE_MATRIX, nose README, PROJECT, QUALITY_SCORE, caps/providers/resolvers, Package.swift, and Demo are unchanged |
| Product state | `提升` remains future, `山根` remains partial, and branch-level `鼻子` remains partial |
| Schema/drift | GSD `verify.schema-drift 36` reports `drift_detected: false` |
| Diff hygiene | `git diff --check` passed |

## Requirement Verdicts

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| NOSE-07 | passed | Exactly two isolated public-facade additions produce the discovered 36-case × 7-fixture = 252 ignored matrix |
| NOSE-08 | passed | The v1.9 helper fully decodes 252/252 and separately passes 12 baseline, 6 root/bridge, and 12 lift/signed-tip ROI comparisons |
| NOSE-09 | passed | Representative no-face extent/degradation is safe; gallery/output paths are ignored; no generated PNG is tracked or staged |

## Precise Non-Claims

- `0.25` is a provisional renderer input, not a final natural cap or commercial calibration.
- `noseRootNarrowing` is not an alias for `noseBridge`; `noseTipLift` is not either signed `noseTipSize` direction.
- `山根`, `提升`, and branch-level `鼻子` are not promoted by Phase 36.
- Phase 37 retains final caps, exhaustive six-field degradation/provider-empty behavior, exactly-once combined safety, final active-source boundaries, and atomic owner promotion.
- Device parity, commercial naturalness, packaging, shipping, launch readiness, and broad reference-app parity are outside this evidence.

## Gaps

None within NOSE-07 through NOSE-09. The named Phase 37 work is deferred scope, not a Phase 36 verification gap.
