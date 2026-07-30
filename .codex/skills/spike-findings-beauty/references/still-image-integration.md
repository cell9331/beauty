# Still-Image Local-Retouch Integration

## Requirements

- Keep this architecture on the still-image path until a separate realtime
  design owns detection, scheduling, memory, and latency.
- Detect support once per request, keep all masks private/request-local, and
  compose bounded transforms once.
- Missing support degrades per region without contaminating accepted regions.
- Derive every accepted color edit from the original pixel under one explicit
  mask owner. Unexpected cross-mask overlap is invalid support and must retain
  the original pixel instead of receiving an implicit priority.
- Persist only aggregate counts/timings; never coordinates, masks, teeth
  geometry, pupil positions, tensors, or vein-like descriptors.
- AI fixtures and macOS measurements prove mechanics only.

## How to Build It

Use this private pipeline shape:

```text
validated still image
  -> one Vision face-landmark request
  -> private request context (eye/brow/pupil/inner-lip support)
  -> independent fail-closed mask providers
       sclera: per-eye guard -> color score -> feather -> hard re-clip
  -> sanitize ownership (expected disjoint masks; overlap -> original pixel)
  -> bounded teeth and sclera color transforms reading the original input
  -> one composite output
  -> aggregate-only metrics/events
```

1. Validate image bytes/pixels using the repository's existing production
   input ceilings before detection or allocation-heavy work.
2. Run one `VNDetectFaceLandmarksRequest`. Define explicit multi-face ownership
   in the future product contract; the spike selected the largest face only for
   mechanics and does not authorize that behavior.
3. Create a private request context. Do not add public fields for landmarks or
   masks.
4. Invoke teeth and sclera providers independently. Validate the two eyes
   independently inside the sclera provider. A failure returns an empty local
   mask for only that region/eye; it must not fail, guess, or reuse stale support
   globally.
5. Intersect masks with their anatomical containment before scoring/growth and
   again after every blur or feather that can expand support. Keep masks disjoint
   where expected. At the composition boundary, clamp both masks and reject any
   pixel claimed by both providers. Record only the aggregate overlap count and
   keep the source pixel unchanged; do not choose teeth/sclera precedence.
6. Factor the two bounded transforms into deterministic per-pixel functions.
   Read from the original input and invoke exactly one accepted transform for
   each owned pixel:

```swift
let teeth = clamp(teethMask[index])
let sclera = clamp(scleraMask[index])
if teeth > 0.001, sclera > 0.001 {
    overlapPixels += 1
    continue // preserve the original pixel
}
if teeth > 0.001 {
    output[index] = whitenedTeethPixel(input, index: index, localMask: teeth)
} else if sclera > 0.001 {
    output[index] = reducedScleraPixel(input, index: index, localMask: sclera)
}
```

   A sequential teeth-then-sclera frame is an oracle only while masks are
   disjoint, never the ownership contract.
7. Report only this allowlisted event shape:

```text
start:     mode
detection: faces, eye/lip support counts, durationMs
model:     output count, loadMs, inferenceMs (only when applicable)
result:    maskPixels, changedPixels, changedOutsideMask, durationMs
```

8. Add executable invariants:
   - all transforms change at least one accepted-mask pixel on a positive;
   - `changedOutsideMask == 0`;
   - closed/no-face/implausible inputs fail closed;
   - sclera final output changes zero protected iris/highlight pixels under both
     color-independent geometry and request-local color-adversarial oracles;
   - failure of one eye leaves an accepted peer eye unchanged and active;
   - fused disjoint output byte-matches independently transformed/merged
     standalone outputs and the prior sequential ordering;
   - zero teeth, zero whole-sclera, and rejected left/right eye injections each
     byte-match the expected unaffected standalone output;
   - expected baseline masks have zero overlap; an injected collision is
     counted, suppressed, and byte-identical to the original pixel;
   - luminance and texture ratios remain within feature-specific reviewed bounds;
   - JSON event keys match an allowlist and sensitive-key scans remain empty;
   - no unapproved model/weights exist in the repository.
9. Build and benchmark release on target iOS devices. Separate Vision, mask,
   color-pass, cold model, warm model, and peak-memory measurements.
10. Require an original-detail before/mask/after review surface for human UAT.

The release macOS harness measured a median color pass of 0.273 ms at 506×900
and 2.647 ms at 1728×2304 after masks existed. The larger full integration run
used 159.9 MB peak RSS and Vision took about 58.4 ms. These are baselines, not
budgets or device claims. Spike 012's whole-frame CPU ownership prototype was
correct but slower than the sparse sequential loops: 6.634 vs 2.570 ms at
1728×2304, and 0.774–0.789 vs 0.255–0.290 ms at 506×900. Its 518 MB evidence-run
peak retained multiple oracle frames and float masks. Preserve these as explicit
performance nonclaims; use bounded ROI or Metal/Core Image and target-device
profiling before proposing a product budget.

## What to Avoid

- Do not wire this directly into the current pixel-buffer path; it does not own
  face detection.
- Do not re-run Vision for each local effect.
- Do not apply global color changes or repeatedly feed output back as input.
- Do not resolve unexpected cross-mask overlap by transform order, max strength,
  or an undocumented teeth/sclera priority. Invalid ownership remains original.
- Do not let one region's missing support disable or corrupt another region.
- Do not assume a pre-feather intersection is final containment; re-intersect
  the filtered mask with its hard anatomical envelope before compositing.
- Do not let native appearance serve as the only safety oracle. A dark iris can
  hide unsafe support until the color input changes.
- Do not silently pick a face in production without a product/API decision.
- Do not serialize raw support or include model paths/tensors in logs.
- Do not benchmark debug builds or report macOS numbers as iOS performance.
- Do not describe a single original-image composition loop as a speedup. The
  tested Swift CPU implementation was 2.6–3.1× slower than sparse sequential
  loops and requires a different production execution strategy.

## Constraints

- The shared harness is Swift 6/macOS 14 and uses Apple Vision, Core Graphics,
  Core Image, Core ML, ImageIO, and Uniform Type Identifiers.
- Only the isolated still-image harness is `VALIDATED`; product masks, public
  ownership, camera integration, device performance, and v1.14 remain unproven.
- The guarded sclera ordering is validated only on a bounded mechanics grid. Its
  24.6%–38.2% legacy-mask retention and 270/360 fail-closed stress cases require
  licensed real-data calibration before product planning.
- Original-pixel composition, regional/eye failure isolation, and fail-closed
  overlap ownership are narrowly `VALIDATED` on three AI mechanics fixtures.
  Product coverage, naturalness, optimized performance, memory, and device
  budgets remain unvalidated.
- Production code and public API were intentionally untouched by all spikes.
- Binary visual artifacts stay local per repository policy; commands, source,
  metrics, and event logs preserve reproducibility.

## Origin

Synthesized from spikes: 004, 005, 011, 012

Source files available in:
`sources/004-local-color-retouch/`, `sources/005-still-image-integration/`,
`sources/011-guarded-sclera-color-integration/`,
`sources/012-guarded-local-retouch-composition/`, and
`sources/shared-retouch-lab/`.
