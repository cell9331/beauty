# faceContourSmooth feasibility assessment — 2026-09-23

## Decision

`faceContourSmooth` is callable and fail-closed, but its effectiveness remains
`partial`. The current control-point approach has no demonstrated path to the
frozen FACE-01 semantic and protection gates. Do not resume Phase 90's revision
series or mark FUTURE-04 complete. A separately scoped v1.23 feasibility study
is reasonable only if it evaluates a genuinely different contour-owned raster
mapping with a fixed go/no-go gate before production integration.

This is a source, test, and historical-evidence assessment. It changes no
production behavior and makes no new visual-quality or device claim.

**Later result:** The [single fixed side-band mechanics probe](FACE-CONTOUR-STRIP-FEASIBILITY-2026-09-23.md)
failed its first-stage continuity and protection gates. Its pre-run containment
estimate omitted the lower chin endpoints. Do not implement that candidate;
semantic side ownership must be resolved before proposing a successor.
The [subsequent contour-only lateral fit](FACE-CONTOUR-LATERAL-FIT-FEASIBILITY-2026-09-23.md)
resolved the generated chin-leak problem but reached only `+7 Q16` against
the frozen `+16` floor. It also stopped without a production change.
Three further fixed side-local constructions reached `-2`, `0`, and `-2 Q16`
gain and stopped at the same first stage. The subsequent [source-only
roughness localization](FACE-CONTOUR-ROUGHNESS-LOCALIZATION-2026-09-23.md)
found 93.5% of lateral roughness between sampled contour joints, where the
source geometry is piecewise linear and the metric is sensitive to raster
steps. The useful next action is to review FACE-01's semantic acceptance
intent before proposing another point-geometry target. None of these scratch
results changes the current SDK or its `partial` status.

## Evidence

| Observation | Source | Meaning |
| --- | --- | --- |
| The current provider derives centered lateral deltas from observed contour neighbors, caps each displacement at `0.012 * faceWidth`, and emits radial points with radius `0.08 * faceWidth` and falloff `2`. Invalid support returns no FACE-01 points. | `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift`, `smoothContourPoints` | Existing safety and request-local support are real, but provider geometry is not an output-effectiveness proof. |
| The generated fixture has face width `0.80`, so each current radial point has radius `0.064` in normalized image units. A left point at `x = 0.220` can influence through `x = 0.284`, beyond the left target ROI ending at `x = 0.240` and into the protected central ROI starting at `x = 0.250`. | `FaceContourSmoothRepairTests.swift`, generated contour and regions | This is a geometric reachability calculation, not a claim that every reachable pixel changes. It explains why radius changes trade signal against locality. |
| The focused `FaceContourSmoothRepairTests` run on the present worktree passed 3/0/0. Its generated-output test deliberately asserts that all eight frozen semantic/protection predicate groups remain failing; its pass is evidence of honest deferral, not FACE-01 acceptance. | `swift test --package-path BeautySDK --filter FaceContourSmoothRepairTests` on 2026-09-23; `testFACE01GeneratedCPUFixtureRemainsExplicitlyDeferredUnderFrozenContract` | Current behavior and failure classification reproduce. |
| The original frozen baseline was `+12 Q16` versus required `+16`; outside was `2724/284565` versus `<=500/1500`, and central was `909/138177` versus `<=128/512`. Local bounded candidates produced at most `+5`; wider support reached `+9` but leaked outside. | `90-01-ATTEMPT.md` | The historical provider-only attempts did not satisfy signal and locality together. These are dated aggregates, not a proof that every possible algorithm is impossible. |
| Phase 90 ended FACE-01 at revision 22 as diagnostic-only, with no GREEN result; `FUTURE-04` retains the deferred requirement. | `90-01-SUMMARY.md`, `.planning/REQUIREMENTS.md` | Historical attempt logs and receipts stay immutable. |

## Original bounded design question and later disposition

The one useful new hypothesis is a **contour-owned, side-local raster map**:
derive a smooth displacement along each observed contour side, apply it only
inside a narrow side band, and force displacement to zero at the band boundary.
This may separate contour continuity from the wide circular support used today.
It is a hypothesis, not an approved implementation or a passing result.
The five fixed mechanics probes linked above and in `PLANS.md` did not pass
their first-stage gate. The source-only localization now makes acceptance
intent review the prerequisite to any further candidate; it does not itself
authorize replacing the frozen oracle.

Before any source change, a v1.23 feasibility plan should specify the exact
side band, continuity metric, inverse-map/no-fold proof, original-pixel
sampling, protected-region ownership, absent/malformed/stale support behavior,
and explicit CPU/GPU routing. A generated, in-memory prototype may test the
mechanics. It must use the fixed FACE-01 fixture/ROI/thresholds and report
aggregate results only; no output-guided threshold or fixture adjustment.
The existing generic geometry path and public 62-field/5-preset/75-case shape
remain unchanged unless a new design independently justifies a scoped change.

## Go/no-go for a later implementation

1. The fixed generated FACE-01 oracle must show source and neutral continuity
   margins `>= +16 Q16`, every frozen and strengthening sibling distinctness
   margin `>=16 Q16`, its existing target-signal floors, outside
   `<=500 pixels / <=1500 absolute RGB`, central `<=128 / <=512`, and exact
   background/watermark preservation. Keep the original oracle and its frozen
   measurements; add successor tests rather than rewriting historical tests.
2. Prove neutral identity, deterministic repeats, field-local rejection and
   recovery, orientation/extent/color/alpha compatibility, bounded runtime and
   memory, and a positive inverse-map safety margin on the actual sampled map.
   Unsupported explicit GPU behavior must be typed and must not silently use
   another backend.
3. Only after a candidate passes those generated gates should an authorized
   owner-local real portrait batch and the archive-first no-skip SwiftPM gate
   be considered for promotion. A generated pass alone cannot establish visual
   quality across portraits. `faceContourSmooth` stays `partial` until the
   separate acceptance is signed for the changed code.

If the fixed generated oracle fails under the new mapping, stop the feasibility
study with its aggregate failure and leave the current implementation and
taxonomy unchanged. The current evaluation does not start v1.23 or authorize
another Phase 90 revision.
