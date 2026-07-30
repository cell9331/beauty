---
spike: 012
name: guarded-local-retouch-composition
type: standard
validates: "Given Spike 009's adaptive teeth mask and Spike 011's guarded per-eye sclera masks, when both bounded transforms are composed once from the original image and region failures or mask overlap are injected, then the fused output byte-matches the disjoint standalone oracle, changes no pixel outside the sanitized union or protected eye regions, suppresses ambiguous overlap, and preserves every unaffected region."
verdict: VALIDATED
related: [003, 004, 005, 009, 010, 011]
tags: [integration, teeth, sclera, compositing, safety, privacy]
---

# Spike 012: Guarded Local-Retouch Composition

## What This Validates

Composes Spike 009's adaptive teeth selector and Spike 011's guarded per-eye
sclera selector behind one color loop that always reads the original image.
Both selectors share one request-local Vision landmark result. Their bounded
transforms remain independent, and a missing or rejected teeth/eye region
cannot disable an accepted peer region.

The baseline masks are anatomically disjoint. The harness also injects one
synthetic cross-mask collision into positive teeth fixtures. A collision keeps
the original pixel rather than relying on transform order or a hidden priority.
This is deliberately conservative: a mouth/eye overlap indicates corrupt
support, not a normal compositing case.

## Research

- Apple's [`VNDetectFaceLandmarksRequest`](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest)
  detects facial features after locating faces, so one request can own the
  landmark context used by both local selectors.
- [`VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d)
  exposes eye, pupil, inner-lip, and outer-lip regions in normalized face
  coordinates. The harness converts these once and never persists the points.
- [`CIColorKernel`](https://developer.apple.com/documentation/coreimage/cicolorkernel)
  models a final output color computed from input samples. The chosen CPU oracle
  mirrors that ownership: each accepted output pixel derives from the original
  pixel, not another local effect's output.

| Approach | Benefit | Risk | Decision |
| --- | --- | --- | --- |
| Sequential teeth then sclera transforms | Existing behavior; compact CPU code | Output becomes order-dependent if masks unexpectedly overlap | Correctness oracle only while masks are disjoint |
| Independently transform two full frames, then merge by masks | Strong, easily audited reference | Two output frames and a separate merge; not the intended final ownership | Standalone byte oracle |
| One original-image color loop with explicit overlap rejection | No implicit precedence; one final owner per pixel; local failures remain independent | The current whole-frame Swift loop is not performance-optimized | **Chosen for composition semantics** |

## How to Run

```bash
swift build -c release \
  --package-path .planning/spikes/retouch-lab \
  --scratch-path /tmp/beauty-spike-012-build

/tmp/beauty-spike-012-build/release/retouch-spike-lab \
  --mode guarded-local-composition \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/012-guarded-local-retouch-composition/artifacts/e6 \
  --iterations 9

/tmp/beauty-spike-012-build/release/retouch-spike-lab --mode self-test
open .planning/spikes/012-guarded-local-retouch-composition/review.html
```

Repeat the composition run with `example-images/parked-portraits/e2.png` and
`e3.png`. The no-face gradient must exit 1 with
`No usable face landmarks were detected`.

## What to Expect

- `legacy-after.png` and `fused-after.png` compare the old selectors with the
  adaptive-teeth plus guarded-sclera composition.
- `adaptive-teeth-mask.png`, `guarded-sclera-mask.png`, and
  `fused-union-mask.png` expose the disposable visual supports.
- `teeth-rejected-after.png` and `sclera-rejected-after.png` prove whole-region
  isolation. The two eye-rejected files prove per-eye isolation.
- `overlap-injected-after.png` must retain the original colliding pixel.
- `comparison.json` contains aggregate counts and timings only. It stores no
  landmark, coordinate, mask sample, or per-region geometry.

## Observability

The tracked event allowlist contains only mode; face, eye, pupil, and lip-point
counts; one-request count and duration; aggregate teeth/sclera candidate counts;
aggregate baseline overlap, oracle mismatch, failure mismatch, and duration.
Raw contours, pupil positions, masks, overlap position, RGB values, and
vessel-like descriptors never enter events.

## Investigation Trail

1. Reused Spike 009's fixed-seeded adaptive teeth selection and Spike 011's
   validate-per-eye → hard envelope → score → feather → hard re-clip sclera
   selection without changing their thresholds or transforms.
2. Added one shared landmark detection and separate fail-closed providers. A
   rejected pupil empties only its eye; absent teeth candidates leave accepted
   sclera output intact.
3. Factored the existing teeth and sclera transforms into exact per-pixel
   functions. The fused loop, standalone transforms, and sequential reference
   therefore share formulas and byte rounding but differ in composition path.
4. Compared the fused result against independently transformed full-frame
   outputs merged by the masks and against the previous teeth-then-sclera order.
   Both references match exactly on all three disjoint baselines.
5. Injected zero teeth, zero whole-sclera, rejected left eye, and rejected right
   eye. Every fused result exactly matches the expected unaffected standalone
   output. e3 additionally exercises a naturally empty teeth selector while
   retaining both accepted sclera masks.
6. Injected a cross-mask collision into the first strong teeth pixel on e6/e2.
   The compositor records and suppresses exactly one collision; that pixel is
   byte-identical to the input. e3 has no strong teeth pixel and injects none.
7. Reduced the initial fused prototype from four whole-frame preparation/color
   passes to one combined loop. Even after that change, the CPU prototype is
   2.6–3.1× slower than the sparse sequential Swift loops. Correctness is
   validated; a product path still needs bounded ROI or Metal/Core Image
   performance work and device measurement.
8. Added three deterministic composition tests. Release build and all 19/19
   shared harness self-tests pass.

## Results

**Verdict: VALIDATED — original-image composition, local failure isolation, and fail-closed overlap semantics pass; this does not validate product coverage, naturalness, or performance.**

| Fixture | Adaptive teeth strong | Guarded sclera candidates (L + R) | Baseline overlap | Fused/oracle mismatches | Outside / iris / highlight changes | Failure mismatches | Injected overlap changed | Fused vs sequential median |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| e6 | 7,396 | 1,868 (901 + 967) | 0 | 0 / 0 | 0 / 0 / 0 | 0 | 0 / 1 | 6.634 ms / 2.570 ms |
| e2 | 805 | 223 (105 + 118) | 0 | 0 / 0 | 0 / 0 / 0 | 0 | 0 / 1 | 0.774 ms / 0.290 ms |
| e3 | 0 | 144 (56 + 88) | 0 | 0 / 0 | 0 / 0 / 0 | 0 | 0 / 0 | 0.789 ms / 0.255 ms |

All three fixtures use one detection request. Fused output is byte-identical to
both the independent standalone merge and the old sequential order while masks
are disjoint. It changes no pixel outside the sanitized union and no protected
iris or highlight pixel. All four region-failure injections have zero mismatch.
The no-face input exits 1 as required.

The result is intentionally narrow. The fixtures are AI-generated, e3 correctly
fails closed for teeth, and visual inspection can establish only obvious mask
placement—not real-user coverage or naturalness. The current CPU prototype is
also slower and reaches 518 MB peak RSS on the 1728×2304 evidence run because
the harness retains several oracle frames and float masks at once; that is not a
device budget. Licensed real positive/negative review, ROI/Metal implementation,
device profiling, API ownership, realtime design, and v1.14 activation remain
separate decisions. No production source or public contract changed.
