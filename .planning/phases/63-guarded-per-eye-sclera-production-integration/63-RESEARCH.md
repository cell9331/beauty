---
phase: 63
slug: guarded-per-eye-sclera-production-integration
status: ready
researched: 2026-08-07
confidence: high
discovery_level: 0
security_standard: OWASP ASVS Level 1
planner_fallback: main-thread-sequential
---

# Phase 63 Research — Guarded Per-Eye Sclera Production Integration

## Executive Summary

Phase 63 needs no new dependency, model, Vision request, renderer pass or public
surface. The repository already owns the canonical RGBA8 source, one native
Vision landmark request, mapped request-local eye contours and pupils, explicit
anatomical-order state, opaque admission, and immutable-original composition.
The smallest safe production change is a package-only stateless sclera provider
that emits zero, one or two independently issued per-eye units, plus one engine
connection beside the existing teeth provider.

The central safety invariant is ordering: validate one eye, construct a binary
anatomical hard envelope, remove protected anatomy, and only then evaluate
redness. A radius-one softening step must be re-clipped to that exact envelope.
Targets read only the canonical source, partially reduce measured red excess,
restore luminance within a byte bound, and let the existing Q16 owner apply the
soft weight once. An uncertain eye abstains without suppressing its peer or an
eligible teeth/color/geometry effect.

The authorized Phase 62 positive/negative pair is sufficient for the minimum
private calibration gate. It remains ignored and is reachable only through the
fixed-output Phase 62 runner. This phase records no path, media name, rights
detail, reviewer identity, support, mask, pixel, digest or raw metric.

## Requirement Mapping

| Requirement | Production evidence |
| --- | --- |
| SCLERA-09 | One current `observedEyeSupport` array plus `.canonical` order; per-side validation; one existing detector invocation. |
| SCLERA-10 | Aperture raster minus contour margin, actual-pupil/iris guard, protected highlights and lash/margin exclusion before score. |
| SCLERA-11 | Score only inside the hard envelope, radius-one feather, same-envelope re-clip, explicit membership on every proposal. |
| SCLERA-12 | Source-only bounded red-excess target, deterministic byte rounding, luminance restoration, alpha/detail preservation, Q16 once. |
| SCLERA-13 | Per-eye local abstention for malformed/unsafe support, peer continuation, valid-invalid-valid/parallel/reset isolation. |

## Existing Authority and Integration Seam

- `VisionFaceDetector` already performs the only `VNDetectFaceLandmarksRequest`
  and maps actual left/right eye contours and pupil landmarks to normalized
  image space.
- `BeautyFaceObservation` carries package-only `BeautyObservedEyeSupport` and
  `BeautyObservedEyeOrder`; no public or Codable geometry is needed.
- `BeautyStillImageRequestContext` owns the current canonical image and selected
  observation for one call.
- `BeautyLocalRetouchCompositionOwner` already accepts multiple source-bound
  units, applies a Q16 weight once, preserves source alpha, rejects foreign
  units, and resolves collisions to the original pixel.
- `BeautyTeethWhiteningProvider` is the closest code pattern for checked ROI
  rasterization, soft-mask re-clipping, source-only targets and aggregate-only
  summaries. Sclera must not copy its mouth color assumptions or collapse two
  eyes into one unit.

## Recommended Provider Design

### Input and output

Add a package-only `BeautyScleraRednessProvider` taking one
`BeautyCanonicalStillImage`, the current optional eye-support array, explicit
eye order, normalized strength and the current composition owner. Invoke it
once for direct positive sclera intent. Return a non-optional aggregate result
containing zero-to-two units and fixed left/right outcome categories; returning
zero units is normal local abstention, not an error.

Reject all sclera work when side ownership is invalid or ambiguous. With
canonical order, validate each side independently: exactly one support row for
that side, a finite unit-bounded simple noncollapsed contour, and exactly one
finite unit-bounded polygon-contained plausible pupil. Missing or invalid peer
support must not erase an accepted eye.

### Per-eye hard envelope

For each accepted eye:

1. Rasterize the contour at pixel centers inside checked ROI arithmetic.
2. Reject collapsed, too-small, too-flat, implausibly large or malformed
   apertures using constants frozen by a declared deterministic sweep. The
   spike values `0.30` and `0.14` are only calibration seeds.
3. Erode a conservative contour-boundary band so lash, lid and skin adjacency
   are absent before scoring.
4. Exclude an uncertainty-inflated iris/pupil ellipse centered only at that
   eye's actual mapped pupil; never mirror, infer, cache or borrow a peer.
5. Exclude source-derived near-white highlights and dark lash/margin candidates,
   each expanded by a bounded neighborhood.
6. If no plausible sclera remains, abstain for that eye.

The guard is geometry-first. A native dark iris producing a zero color score
does not prove safe containment and cannot substitute for the iris exclusion.

### Score, feather and transform

Compute a sclera-likelihood term from source luminance and low saturation only
inside the hard envelope, multiply it by positive red excess, require a
material score and plausible area, apply one radius-one blur, then multiply by
the same binary envelope. Exact threshold, area, margin and uncertainty values
must be frozen before the final private run and must not be relaxed after an
unfavorable result.

The transform should use normalized source channels and a measured excess such
as `max(0, red - max(green, blue))`. At bounded effective strength, reduce only
that excess, add small compensating green/blue movement, restore original
luminance within an explicit byte cap, clamp, round
`.toNearestOrAwayFromZero`, and preserve source alpha. Neutral/low-redness or
unchanged targets return no proposal. The target must not multiply the soft
mask; the composition owner applies the final Q16 weight exactly once.

## Engine and Lifecycle Design

Extend the admitted still-image branch to create one owner when teeth, sclera
or opaque composition work is present. Invoke the teeth provider only for
direct teeth intent and the sclera provider exactly once only for direct
sclera intent. Append all accepted units and compose once. Teeth-only,
sclera-only and both-intent requests therefore share one canonicalize/detect/
map/context/composition lifecycle without either feature granting authority to
the other.

Testing observations may expose only fixed counts/outcomes: provider
invocations, accepted left/right unit counts and abstention classes. They must
not expose coordinates, pupils, masks, candidate colors, raw metrics or stable
identity. Clear both provider observations at still-call start, pixel-buffer
entry and reset. Stateless provider code plus valid-invalid-valid, parallel,
interrupted and independent-engine tests prove there is no stale state.

## Private Calibration and Genuine Fixture Gate

Use the Phase 62 fixed-output runner to discover the one ignored authorized
sclera bundle and inject its path only into an opt-in XCTest child. The test
runs the production facade through actual native Vision, resolves roles in
memory, and emits a fixed pass/fail status. Freeze before execution:

- positive: at least one accepted eye and changed reviewed-mask pixel; positive
  mean red excess decreases; mean luminance and maximum channel movement stay
  within conservative declared bounds; alpha/dimensions remain exact; detail
  energy remains within a declared naturalness band; zero changed pixel lies
  outside the reviewed mask;
- negative: zero outside-mask change; either provider abstention or small
  bounded mean RGB/luminance change; detail/alpha/dimensions remain exact;
- both: one canonical Vision request, no path-dependent test relaxation, and
  only fixed aggregate output.

If the bundle is absent/ambiguous, Vision cannot run, support is unusable, or a
frozen bound fails, Phase 63 remains blocked. The private gate is corroborative
production evidence, not Phase 64 visible-output promotion.

## Validation Architecture

| Layer | Test owner | Phase 63 proof |
| --- | --- | --- |
| Provider geometry | SwiftPM XCTest | side uniqueness, contour/pupil validation, checked ROI and per-eye abstention |
| Hard envelope | SwiftPM XCTest | protected guard before score, exclusion expansion, empty-envelope abstention |
| Score/transform | SwiftPM XCTest | post-feather re-clip, source-only bounded target, luminance/detail/alpha/Q16 once |
| Engine lifecycle | SwiftPM XCTest | one request/provider invocation/composition, peer and teeth isolation, recovery |
| Genuine pair | Opt-in XCTest through fixed-output Node runner | actual Vision, frozen positive/negative aggregate bounds, zero reviewed-mask escape |
| Static security | Python standard-library checker | eight isolated HIGH owners plus mutation self-test |
| Compatibility | Full SwiftPM and explicit Demo XCTest | 61 fields, five presets, 73 render cases, three disabled rows |
| Privacy/lifecycle | Tracked/staged scan and GSD inventories | no sensitive durable state and exact requirement/decision/task/threat ownership |

Quick provider and integration filters run after each task. Completed waves run
the checker and all available focused tests. Final closeout requires the private
pair, checker self/live/eight isolated threats, full SwiftPM, explicit Demo
build/test, owner synchronization and diff hygiene. A broad suite cannot waive
one missing private or HIGH gate.

## Spec-less Probe Resolution

The deterministic fallback surfaced eleven edges because Phase 63 has no
separate SPEC. Plans cover them explicitly:

- interrupted/parallel requests remain request-local and deterministic;
- every geometry, color, area and Q16 threshold is tested at, below and above
  its boundary with deterministic rounding;
- touching protected/exterior regions remain excluded, while cross-unit pixel
  collisions preserve the source;
- empty, missing and single-eye inputs produce zero or one local unit without
  peer suppression;
- duplicate/equal-side support rejects ambiguous ownership; canonical output
  unit ordering is left then right regardless of support array order;
- empty score/unchanged target emits no proposal; blur is always re-clipped;
- one-eye rejection and every listed unsafe scenario are exercised directly.

The two unclassified probes (post-feather ownership and listed unsafe-state
coverage) are resolved by D-08/D-14 plus executable tests, not silently
dismissed. Prohibition recall keeps three flagged boundaries in every relevant
plan: no anatomy guessing/protected modification, no private data durability,
and no Phase 64/Demo/realtime/model/release scope expansion.

## Security and Nonclaims

All T-63-01 through T-63-08 are HIGH. Missing files, unclassified source,
skipped private execution, missing threat mode, scanner error or owner drift
fails closed. Phase 63 does not add a renderer case, saved output mode, Demo
mapping, realtime/pixel-buffer path, external model, network, production
upper-eyelid/`去脂`, product-ledger promotion or release claim. Phase 64 remains
the sole owner of color-independent geometry, recolored-iris final-output proof,
strict facade output, final original-detail review and promotion.

## Package Legitimacy Audit

Not applicable. The implementation uses existing SwiftPM targets, Apple Vision,
Core Image/Core Graphics carriers, Node/Python standard-library gates and the
existing local fixture runner. No package or service is added.

