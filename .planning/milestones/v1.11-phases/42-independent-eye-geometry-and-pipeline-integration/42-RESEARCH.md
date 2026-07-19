# Phase 42: Independent Eye Geometry and Pipeline Integration — Research

**Researched:** 2026-07-16  
**Confidence:** HIGH for repository seams and provider/resolver patterns; MEDIUM for provisional visual constants (Phase 44 must calibrate them).

## Scope and Constraints

Phase 41 supplies ten normalized public scalars and package-private
`BeautyEyeSemanticSupport` on `FaceGeometry`. Phase 42 must implement EYE-08
through EYE-15 only. It must not add renderer/gallery cases (Phase 43), final
caps/promotion/boundary ledger (Phase 44), public geometry, Demo UI, or new
dependencies.

## Existing Seams to Reuse

| Concern | Existing seam | Required Phase 42 extension |
|---|---|---|
| Effective values | `BeautyEffectResolver` fills `BeautyEffectiveStrengths` after `BeautyParameters.normalized()` | Add ten fields to caps, strengths, geometry requirement scan, requested-work and zeroing helpers. |
| Named provider work | `NoseWarpFieldEmissions` and `MouthWarpFieldEmissions` expose per-field arrays and `sanitizing(_:)` | Add equivalent `EyeWarpFieldEmissions` with all fourteen eye names and field-local empty-output zeroing. |
| Eye vectors | `EyeWarpProvider` currently uses `leftEye`/`rightEye` centers and four shipped helpers | Prefer `leftEyeSupport`/`rightEyeSupport` semantic subsets, preserving nil-support legacy proxy behavior for shipped compatibility. |
| Geometry route | `BeautyGeometryEffectPipeline.controlPoints(for:strengths:face:)` concatenates providers | Keep this route; no new pass or facade type. |
| Conflict accounting | `GeometryConflictResolver` scales geometry strengths; resolver re-evaluates nose/mouth emissions | Include all fourteen eye fields in total/scaling and re-evaluate eye+nose+mouth emissions from one retained baseline, bounded by 28 field removals. |
| Degradation | Resolver skips reused/stale complete eye domain and zeros missing provider work | Preserve complete-eye skip; clear only pupil fields for pupil absence; keep siblings active. |

## Geometry Design Guidance

The existing coordinate convention is image-normalized with increasing `y`
downward. Therefore upper-lid lift targets smaller `y`, lower-lid drop targets
larger `y`, and positive `eyeTilt` must have the opposite tangential sign from
negative `eyeTilt`. Semantic supports already provide stable centers, upper,
lower, inner, outer, corners, span, tilt, and optional pupil. Providers should
derive each source subset once and clamp source/target to the unit square through
the existing `WarpControlPoint` construction pattern.

Recommended field mapping:

* `eyeHeight`: upper/lower lid points move away from or toward the center in
  `y`, preserving center and corners.
* `eyeLength`: inner/outer points move along the horizontal eye axis, preserving
  center and aperture.
* `upperEyelidLift` / `lowerEyelidDrop`: one lid subset only, fixed direction,
  local radius.
* `eyeTilt`: rotate non-central contour points around the per-eye center with a
  signed angle; do not use `eyeTailLift`'s tail-only sources.
* `innerCornerOpen` / `outerCornerOpen`: corner source only, side-aware semantic
  inner/outer arrays.
* `pupilSize`: pupil source only, radial vector relative to pupil center (or
  owning contour center) and local radius.
* `gazeCorrection`: pupil source only, move pupil toward owning contour center;
  no-op in a small normalized dead zone and when pupil is absent.
* `eyeSymmetry`: pair both supports, calculate center/span/tilt differences,
  move each eye toward a midpoint only for measured non-neutral differences.

These are semantic distinctions to test at provider level; exact effect caps and
naturalness are intentionally provisional until Phase 44.

## Eligibility and Aggregate Accounting

`NoseWarpFieldEmissions` and `MouthWarpFieldEmissions` demonstrate the needed
pattern: each named field returns an array, and `sanitizing(_:)` clears a
nonzero strength when its array is empty. The eye implementation should apply
the same pattern before the resolver computes `activeDomains`, geometry point
counts, weakened counts, warnings, or metrics. Pupil invalidity must only clear
the two pupil-dependent values. Missing either contour must return an empty
aggregate result so the resolver inserts `.eyes` in `skippedDomains` with the
existing redacted warning.

The conflict resolver currently counts 23 geometry fields (5 face + 4 eye + 6
nose + 8 mouth). Phase 42 expands it to 33 (5 + 14 + 6 + 8), and its iterative
mask recomputation must include eye emissions. The loop must remain bounded and
monotone: a pass can only clear an emission-ineligible field, never reintroduce
one. Phase 44 owns the final exact convergence ledger, but Phase 42 tests the
bounded implementation and aggregate exclusion.

## Compatibility and Privacy

`BeautyParameters` already normalizes positive-only fields to `[0,1]` and signed
fields to `[-1,1]`; adding corresponding `BeautyEffectiveStrengths` members is
internal and does not alter the 48-field public inventory. `FaceGeometry` and
semantic support remain package-internal, non-Codable, and request-scoped. All
warnings/metrics must retain aggregate reason codes and counts only. No raw
contours, pupils, side labels, offsets, or support values may cross the
diagnostic/public facade.

## Focused Verification Recommendations

1. `EyeWarpProviderTests`: each new field isolated, field arrays named and
   non-empty with valid support; nearest-neighbor distinction and sign/locality
   assertions; malformed/missing/pupil/dead-zone no-ops.
2. `BeautyEffectResolverTests` and `MissingLandmarkDegradationTests`:
   ten-field caps/defaults, complete-eye gating, pupil-local zeroing, stale/
   reused behavior, active/skipped domain and redacted metadata.
3. `GeometryConflictResolverTests` (or existing combined safety suite): all
   fourteen eye fields included once in totals and convergence; final-empty eye
   fields excluded while valid nose/mouth siblings survive.
4. `swift test --package-path BeautySDK` plus `git diff --check`; leave strict
   output/gallery evidence to Phase 43.

## Resolved Open Questions

- **Support source:** use Phase 41 semantic support whenever present; retain
  existing coarse `leftEye`/`rightEye` fallback only for nil observed payloads
  so legacy shipped tests remain neutral.
- **Gaze direction:** derive only from pupil-to-contour-center observed offset;
  no manual gaze vector or fabricated neutral pupil.
- **Symmetry policy:** reduce measured paired differences toward midpoint and
  no-op for neutral/implausible pairs; never mirror or swap identities.
- **Caps/dead zone:** select conservative provisional values and test finite
  bounded behavior now; Phase 44 is the authority for exact natural constants.

