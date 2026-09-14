# Root structural correspondence — generated-only draft 2

Status: implementation prototype, not approved for portrait registration or
scoring. The owner authorized the measurement repair after the independent
review confirmed both false-negative and false-positive legacy measurements.
Original ROI, thresholds, source identity and all historical failures remain.
`rootStructuralEdgeSpanQ16_v2_draft2` is not a passing gate identity.
Draft 1 was independently rejected in `95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v2.md`
(commit `a74b8c33`). This revision does not retroactively approve that draft.

## Fixed mathematical domain

The prototype accepts only in-memory planes: width 32...8192, height 16...8192,
at most 16,777,216 samples, finite luminance 0...255 quantized in 1/256 units.
The eventual adapter must supply the existing orientation-normalized opaque
sRGB carrier's integer lumaQ8/256. It must retain all original pixel/metadata
checks; this prototype does not implement that adapter or read any image file.
The executable exposes `--self-test` only and rejects other invocations.

The measurement ROI is the unchanged registered root rectangle. Source-owned
eye boxes are explicit *measurement registration exclusions*, not modifications
of the target/protected acceptance rectangles. At a sampled Y overlapping an
eye, the complete horizontal matching stencil stays medial to that eye. Outside
the eye's Y range it may use the original root rectangle. These exclusions,
rows, templates and windows participate in the registration commitment; they
must not be described as an invisible no-contract-change implementation detail.
The future real-source registrar must obtain both eye boxes from the same
canonical source observation and commit them before any output is read.

## Source-only registration rules

- Sample exactly 16 equidistant row-bin centers, using integer
  `minY + (2*i+1)*height/32`; ROI height must be at least 16.
- Split X by the original integer midpoint. Within each half, respecting the
  eye exclusion, require a complete ten-pixel guard on each side of an anchor.
- Select the largest absolute adjacent-pixel difference deterministically,
  breaking a local tie by smaller X. Require it to exceed twice every competing
  peak more than ten pixels away. A remote competing edge rejects registration
  as ambiguous; it is not dropped to improve row coverage.
- Require absolute endpoint contrast over offsets -4...4 to be at least 10
  luminance units. Both edges must have opposite polarity; registered rows must
  keep that polarity and move each edge at most four pixels between consecutive
  admitted rows. This is a bounded image-edge assumption, not proof of anatomy.
- Missing/weak rows may be omitted only during source registration. At least
  12/16 rows must register. All admitted rows and equal weights are frozen;
  candidate/neutral/siblings may not change the row set or replace an edge.
- Each source edge must also uniquely match itself under the full nuisance
  model below. Disconnected matches, search-boundary matches, or a position set
  spanning over six pixels are ambiguous and reject registration.
- A search window is source edge +/- `max(8, ceil(fullImageWidth/32))` pixels,
  clipped once to the source half/eye-excluded region's ten-pixel guard.

Validate ordered bounds `0 <= min < max <= dimension` BEFORE any subtraction,
midpoint or row arithmetic. Extreme and reversed endpoints return invalidInput.
  Output matching does not move or resize this window.

All numerical choices above are draft, source-independent rules selected and
tested on generated data only. None has been scored or tuned on the portrait.
The independent implementation review may reject this draft; a future source
registration may also correctly return unavailable. Neither permits retuning
against outputs or choosing a new fixture.

## Correspondence and uncertainty

Each anchor freezes 21 raw source luminance samples at offsets -10...10 in
memory/commitment. Its piecewise-linear interpolant is P. Matching uses thirteen
INTEGER candidate samples at `floor(position)+offset`, offsets -6...6. This
longer window retains plateau evidence across blur support and the admissible
three-pixel localization half-span; endpoint contrast remains measured at +/-4
and inter-row continuity remains four pixels, independently of window size.

The exact forward sampling order is `C[k] = gain * sum_s(weight[k,s] *
P(k-displacement+s)) + offset + error[k]`, with nonnegative weights summing to
one, support `s in [-2,2]`, gain/offset shared per template, and error including
final Q8 quantization. Spatially varying and asymmetric convex kernels are
included. There is NO reverse interpolation of C. For each displacement cell,
compute extrema of P over `k-displacement +/- (2+1/32)` using endpoints and every
integer knot; these bound every allowed kernel and every displacement in the
cell. Independent per-sample ranges are an overapproximation, never a favorable
best kernel. This does **not** cover arbitrary blur, sharpening or new texture.

The candidate nuisance model permits positive affine gain 0.5...2, unrestricted
offset without clipping, and per-sample absolute error <=2 luminance units.
This noise bound is a newly declared measurement model, not borrowed from the
legacy changed-pixel tolerance. Saturated matching samples are unavailable.
Real pipeline claims must remain limited to this tested model; pixel data alone
cannot distinguish an exactly repainted matching structure from deformation.

Search on a fixed 1/16-pixel grid. Each grid point stands for a closed
half-step cell (+/-1/32). Evaluate the FORWARD source interpolation envelope
as above; candidate integer samples receive only the declared noise interval.
Keep **all** positions compatible with the template's blur envelopes, noise
and one shared gain/offset per local template. Compatibility is linear
feasibility in gain/offset (pairwise interval inequalities), not best-fit error.
The quantized samples and binary grid keep additive coefficients exact;
division bounds round outward. A valid no-motion/photometric/blur explanation
must remain in the set. No argmax switch or midpoint shortcut is allowed.

The returned interval is the hull of the accepted cells, rounded outward.
Disconnected accepted sets, a hull spanning over six pixels, and matches at
either search limit fail typed `ambiguous`/`unavailable`. The six-pixel limit
applies to the complete mathematical cell hull: `lastTick-firstTick+1 <= 96`.
Subsequent nextDown/nextUp only enclose floating representation of those bounds;
they do not admit another tick. All registered rows
must match in every required image; one missing row fails the measurement.

For each row compute `[R.lo-L.hi, R.hi-L.lo]`. Aggregate equal row weights,
normalize by **full image width** and multiply by 65536, rounding lower down and
upper up. Strictly positive, ordered edge intervals are required. Interval
margins are:

- signed: `min(source.lo-candidate.hi, neutral.lo-candidate.hi)`;
- each sibling distance: `max(0, sibling.lo-candidate.hi, candidate.lo-sibling.hi)`;
- distinctness: minimum of the original three sibling distances.

Both remain subject to the original >=16 Q16 threshold. No area/ROI-width
renormalization or scale multiplier is allowed. Source, neutral and all three
siblings are mandatory. Existing target-signal and every outside/protected
predicate remain separate conjunctions; this draft does not grant exemptions.

## Commitment and required live integration

The prototype commitment uses SHA-256 with an explicit domain, metric draft ID,
canonical source-plane digest, dimensions, unchanged ROI, sorted exclusions,
row/edge/window identities and templates. Integers and IEEE754 values are
encoded as fixed 64-bit big-endian words with counts before variable sequences.
Only commitments/counts/status may be persisted, never the underlying words,
rows, templates, pixels or anatomical positions. Scoring takes an independent
expected commitment and recomputes it to reject mutations before matching.

This is only the inner mathematical commitment. Before live integration an
independently reviewed `95-ROOT-METRIC-AMENDMENT-v2.json` must bind the original
v1 registration file hash, manifest/source/ROI identities, this spec, exact
implementation and test identities, implementation review, canonicalization
environment, and two matching source-registration commitments. The scorer must
verify that amendment before reading outputs and recheck identities afterward.
Legacy schema/default math remains distinguishable; a v1 report with a newly
computed digest cannot become v2. Full report/reconciliation/classifier and
genuine closeout consumers still need this plumbing. None is enabled here.

## Current evidence and gaps

The legacy comparator and v1 registration were preserved in commit `7d3d336b`
before the case-to-metric identity fix. The original manifest is unchanged.
The identity fix rejects eight recomputed-digest metric substitution attacks;
comparator self-test passes 597 probes. The old v1 driver correctly rejects the
changed comparator hash; its binding has not been overwritten to bypass review.

The provider's generated structure test independently tracks the known
40/220 boundary at 130 with +/-0.5 rounding uncertainty, rather than reusing
the defective dark centroid. Draft 2 computes the feasible crossing hull over
EVERY segment in each fixed generated half-strip, with strict endpoint
bracketing and monotonicity; threshold-equal samples cannot extrapolate a steep
segment over an adjacent shallow one. Original metric
counterexamples remain explicit diagnostic coverage, not provider acceptance.

Prototype tests include both polarities, low contrast, true contraction,
expansion, brightness/gain changes, blur/noise, common translation, missing and
ambiguous structures, source exclusion, clipping, deterministic commitments,
wrong commitments, copied siblings and exact 15/16/17 interval predicates.
The 175-check version adds sizes 256/513/1024, both polarities and four subpixel
phases with independently specified analytic area-coverage boundaries enclosed
by measured intervals, plus tampered-template rejection. An extended suite adds
six convex radius-two kernels (including asymmetric extremes), full +/-2 noise,
the two +1 impulse pattern, correlated noise, pixel-domain 15/16/17 boundaries
and common translations including search-window escape (draft 1: 250 checks).
Typed abstention is
acceptable on negative or threshold-uncertain cases, never on positive fixtures
declared measurable. Complete canonical metadata/binding integration and
independent definition/implementation review remain outstanding. No portrait has been processed
by this new definition and no effectiveness or closeout pass is claimed.

## Draft 2 repair evidence

The rejected draft's 250 passing checks did not establish conservative combined
blur/subpixel bounds. Its independent review and exact source identities remain
in the v2 implementation review; that history is not relabeled as approval.
Draft 2 changes the forward sampling order and committed source profile, fixes
the complete-cell hull inequality, and validates ordered ROI endpoints before
arithmetic. Thirteen-sample matching replaces nine-sample matching on generated
evidence only; a preliminary nine-sample forward model abstained on a declared
positive fractional fixture, so it was not accepted as the completed repair.

Regressions include all five reviewer subpixel phases crossed with three extreme
blur kernels, requiring each returned position/width interval to contain the
independent latent truth (or typed abstention) and no full margin false pass.
The original analytic area-rasterized size/phase cases remain as bound-or-abstain
checks; additional forward-sampled contractions for every case MUST return valid
bounds, as do the original strong bright/dark and low-contrast positive stripes.
This distinguishes rasterizing a continuous new stripe from translating the
frozen discrete source rather than silently claiming those operations identical.
Eight extreme/reversed/empty ROI inputs return typed invalidInput, and complete
95/96-center-interval hull boundaries are checked. A real ramp regression is
also included. Current draft-2 self-test passes 346 checks. The generated provider oracle now passes all 11 focused tests
(seven nose, two legacy metric diagnostics, two horizontal safety), zero failures
or skips; its initial strict two-sample version failed both rendered fixtures
at threshold-equal pixels, and was replaced by the conservative adjacent-segment
hull, not by skipping those assertions. Independent re-review remains required.
