# Phase 93: Distinct Nose Bridge and Root Repairs - Pattern Map

**Mapped:** 2026-09-09
**Files analyzed:** 9 proposed implementation/test/evidence owners
**Analogs found:** 9 / 9

This map is conditional on registration. The current canonical `.usableFace`
path is not a valid implementation fixture for both frozen semantics: the
adapter-generated `noseRoot` pair lies in the frozen bridge raster rather than
the frozen root raster. `NoseFixtureRegistrationTests` must establish one
independently justified common source/observation/adapter registration before
any edit to `NoseWarpProvider.swift`. If that gate fails, production work stops
and the result is recorded as a prerequisite finding; it is not semantic RED,
does not spend either implementation attempt, and cannot earn NOSE-02 credit.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | provider/service | transform | same file; accepted dense-budget pattern in `EyebrowWarpProvider.swift` | exact seam + role-match safety |
| `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` | test | transform | same file; dense regression in `EyebrowWarpProviderTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/NoseFixtureRegistrationTests.swift` (new) | test | request-response/transform | `BeautySDK/Tests/BeautyCoreTests/BeautyEyebrowFixtureRegistrationTests.swift` | role-match |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift` (new) | test | request-response + generated pixel I/O | `BeautyEngineEyebrowHeadSpacingRepairTests.swift`, then `BeautyEngineChinTaperRepairTests.swift` | role/data-flow match |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` (conditional) | testing provider | event-driven/request-response | Phase 92 fixture enum/provider in same file | exact |
| `.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPTS.md` (new) | evidence ledger | batch | `92-06-ATTEMPTS.md` | exact |
| Phase 93 `*-SUMMARY.md` files (new) | evidence/closeout | batch | `92-06-SUMMARY.md` and Phase 91 summaries | exact |
| Root owner documents (`DESIGN.md`, `PRODUCT_SENSE.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `PLANS.md`) (measured-outcome only) | config/documentation | transform/batch | Phase 91/92 completed owner sections | role-match |
| Frozen authority and boundary files (verification only) | config/test | batch/file-I/O | current manifest/comparator/runner | exact read-only authority |

`BeautySDK/Package.swift` needs no change. `BeautyEffectsTests` already depends on
`BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyResources`, and
`BeautyEffects` (lines 43-46), while `BeautyCoreTests` already depends on
`BeautyCore` and `BeautySDK` (line 41). Keep the registration test in
`BeautyEffectsTests` so it can exercise the adapter without exposing new public
geometry.

## Pattern Assignments

### `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift`

**Primary analog:** the existing named-emission and per-field sanitation seam in
the same file.

**Field ownership and fail-closed sanitation** (lines 1-38):

```swift
struct NoseWarpFieldEmissions: Equatable, Sendable {
    let noseBridge: [WarpControlPoint]
    let noseRootNarrowing: [WarpControlPoint]

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.noseBridge != 0, noseBridge.isEmpty { sanitized.noseBridge = 0 }
        if strengths.noseRootNarrowing != 0, noseRootNarrowing.isEmpty {
            sanitized.noseRootNarrowing = 0
        }
        return sanitized
    }
}
```

Preserve the six named arrays and sibling ordering. Bridge and root failures
must clear only their own effective field. Do not borrow legacy center, tip,
slim, eye, or other support.

**Independent dispatch** (lines 61-84): bridge uses legacy `nose` center and
upper membership; root calls its explicit pair owner without a center guard.
Keep this separation.

```swift
noseBridge: strengths.noseBridge > 0
    ? center.map { bridgePoints(face: face, center: $0, strength: strengths.noseBridge) } ?? []
    : [],
noseRootNarrowing: strengths.noseRootNarrowing > 0
    ? rootNarrowingPoints(face: face, strength: strengths.noseRootNarrowing)
    : []
```

**Root validation** (lines 88-119): copy its exact cardinality, finite width,
finite/in-face points, distinctness, equal-Y tolerance, midline straddle,
symmetry tolerance, and minimum room checks. The root remains pair-atomic.

**Actual displacement scaling** (root lines 138-176): follow the root branch's
`strength / BeautySafetyCaps...` target construction. The bridge's current
lines 290-303 target `center.x` regardless of strength; Phase 93 must change
actual `target-source` displacement because the CPU consumer ignores strength
metadata for amplitude.

**Final Float sum-budget pattern:** copy the accepted reconstruction approach
from `EyebrowWarpProvider.swift:248-272`, adapted to the quadratic kernel's
reviewed bound `2 * norm(displacement) / radius` and the Phase 93 proposed
per-field maximum `0.45`:

```swift
func displacementBudget(_ points: [(source: SIMD2<Float>, target: SIMD2<Float>, radius: Float)]) -> Double {
    points.reduce(0) { sum, point in
        let delta = point.target - point.source
        return sum + 2 * hypot(Double(delta.x), Double(delta.y)) / Double(point.radius)
    }
}
let budget = displacementBudget(candidates)
guard budget.isFinite else { return [] }
// Scale once with conservative Float slack when over budget, reconstruct,
// then recompute from actual Float source/target/radius and reject if > 0.45.
```

The numeric `0.45` is a reviewed candidate, not frozen acceptance or proven
efficacy. Do not retry alternate constants inside an attempt. Validate every
source, cap target, intermediate target center, radius, unit/face containment,
and arithmetic result. `makePoint` clamps radii to `0.03...0.20`
(`NoseWarpProvider.swift:312-324`), so admission must inspect final radii.

### `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift`

**Analog:** existing root invariants at lines 99-133, malformed pair table at
172-199, independence at 228-255, and per-field sanitation at 257-329.

Retain these exact patterns:

```swift
XCTAssertEqual(first, second)
XCTAssertEqual(first.points.count, 2)
XCTAssertGreaterThan(left.target.x - left.source.x, 0)
XCTAssertLessThan(right.target.x - right.source.x, 0)
XCTAssertEqual(left.target.y, left.source.y)
XCTAssertEqual(right.target.y, right.source.y)
```

Extend with a table over neutral/dead-zone, smallest renderer-effective work,
quarter, half/reused, cap-adjacent, cap, and representative post-conflict
strengths. Assert final Float displacements and emitted strengths, finite unit
coordinates, exact Y identity for root, bridge X-only motion, cap/reuse scaling,
field-local rejection, deterministic arrays, and renderer-effective nonzero
vectors. Update only the legacy bridge assertion at lines 257-292 if it expects
an emitted zero vector from a one-point centered bridge; preserve wing, tip,
slim, and root prerequisites.

**Dense regression analog:** `EyebrowWarpProviderTests.swift:269-275` computes
the full actual displacement/radius sum, then evaluates the additive inverse
field. Phase 93 should test dense samples across each field and combined
bridge+root overlap, plus representative unchanged siblings. Require each
repaired quadratic field budget `<= 0.45`, isolated total `<= 0.90`, finite
sampling, and no fold in the exact scoped regression. Do not claim arbitrary
mixed-field or clamped-raster injectivity.

### `BeautySDK/Tests/BeautyEffectsTests/NoseFixtureRegistrationTests.swift`

**Analog:** `BeautyEyebrowFixtureRegistrationTests.swift:74-113`.

**Imports** (analog lines 1-7):

```swift
import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@_spi(Testing) import BeautySDK
```

The new file is in `BeautyEffectsTests`, so add `@testable import BeautyEffects`
and use the existing target dependencies. Trace the common observation through
`VisionFaceDetector` and the production adapter. Derive expected raster
membership independently with integer PPM rules, as the analog does at lines
75-87, and use Boolean assertions so raw support never appears in failure text:

```swift
XCTAssertTrue(rootSupportRegistersWithFrozenRootROI, "root registration")
XCTAssertTrue(bridgeSupportRegistersWithFrozenBridgeROI, "bridge registration")
XCTAssertEqual(provider.invocationCount, 1)
```

The production adapter currently synthesizes all nose groups from admitted
bounds (`BeautyFaceGeometryAdapter.swift:130-138`). Its exact local templates
are legacy nose at lines 1009-1015 and root pair at 1018-1022. With canonical
`.usableFace`, Testing SPI uses bounds `(0.30,0.20,0.40,0.60)`
(`BeautyEngineTestingSupport.swift:256-267`). That mapping is the known frozen
root-ROI mismatch. The registration file must be GREEN before production
mutation. A new common fixture is allowed only when its source anatomy and
observation are justified independently of candidate output and the same input,
neutral, observation, and sibling set serve both controls.

### `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift`

**Primary analog:** `BeautyEngineEyebrowHeadSpacingRepairTests.swift`; use chin
and gaze tests only where their simpler one-direction or recovery cases fit.

**Public route and deterministic fixture** (eyebrow lines 19-45, 372-433):
construct a 512x512 in-memory RGBA8/sRGB fixture, render source/neutral, bridge
`+0.30`, root `+0.25`, repeated candidates, and every frozen sibling through
`BeautyEngine.processResult`. Require neutral source identity, repeated byte /
metrics / warnings equality, extent, orientation, color space, alpha, one
detector invocation for active rows, and redacted diagnostics.

**Target/protection structure** (eyebrow lines 47-96 and 209-280): measure every
candidate separately against source and neutral. Preserve exactly:

```swift
XCTAssertGreaterThanOrEqual(sourceSignal.changedPixels, 500)
XCTAssertGreaterThanOrEqual(sourceSignal.absoluteRGBDelta, 2_000)
XCTAssertGreaterThanOrEqual(neutralSignal.changedPixels, 500)
XCTAssertGreaterThanOrEqual(neutralSignal.absoluteRGBDelta, 2_000)
```

Use outside maxima `128/512`, each protected nose group `64/256`, and
background/watermark `0/0`. Sum RGB differences across every included pixel;
count a changed pixel only when maximum channel delta is greater than 2.

**Independent integer metrics:** copy comparator equations, never provider
helpers. The darkness primitive follows eyebrow lines 289-307:

```swift
let lumaQ8 = Int64(r) * 77 + Int64(g) * 150 + Int64(b) * 29
let darkness = max(0, Int64(255 * 256) - lumaQ8)
```

Bridge is center-third mean darkness minus outer-thirds mean darkness using
integer PPM rasterization and integer division. It remains Q8; do not multiply
it into Q16 despite report naming. Root is the negative Q16 separation of the
two half-region darkness centroids. Assert nonzero denominators and source- and
neutral-relative gains `>=16`, plus minimum absolute candidate/sibling metric
difference `>=16`. Add independently authored flat/defined bridge and
wide/narrow root polarity checks; identical, uniform-shift, protected-only, and
watermark-only inputs must fail the conjunction and never count as provider
evidence.

**Exact frozen rows:** bridge compares source, neutral,
`noseRootNarrowing_0p25`, `noseSlim_0p35`, `noseTipSize_plus0p30`, and
`noseTipSize_minus0p30`. Root compares source, neutral, `noseBridge_0p30`,
`noseSlim_0p35`, and `noseTipLift_0p25`.

**Failure and recovery** (eyebrow lines 99-169; chin lines 93-136): cover
missing, malformed, provider-empty and applicable valid-invalid-valid reuse.
Invalid work remains source exact; the third valid request equals the first in
bytes and bounded metadata. Use the redaction scan at eyebrow lines 310-325.

Wave 0 must freeze hashes of the source recipe, observation, metric helpers,
test thresholds, provider baseline, manifest, comparator, and retained shader.
With production baseline restored, public semantic assertions must be RED only
after registration is GREEN. Keep infrastructure and semantic failures distinct.

### `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` (conditional)

**Analog:** fixture enum/provider at lines 209-255 and Phase 92 branches at
338-376. Prefer existing `.usableFace` only if registration actually passes.
If a new common fixture is independently justified, add the smallest fixed enum
case and switch branch, preserve the lock/invocation counter, stable fixed ID,
complete landmark admission, and request-local observation. Do not add a public
nose payload, per-effect relocated fixtures, debug geometry, or persisted path.

### `93-ATTEMPTS.md` and Phase summaries

**Attempt-ledger analog:** `92-06-ATTEMPTS.md:7-14,16-39,106-119`.
Start with registration and immutable RED evidence. For each substantive
production candidate record one shared phase attempt number, candidate/provider
blob, provider and public-pixel discovered/pass/fail/skip counts, bounded metric
and protection aggregates, failure class, independent review status, and exact
rollback/accepted state. Do not persist geometry, pixels, images, masks, private
locators, temporary report paths, or transcripts.

Phase 93 has at most two implementation attempts across the whole phase. The
budget does not reset per plan or per requirement. Registration failure spends
zero attempts. Compile or harness failures are recorded honestly; they do not
create a third candidate. If attempt two fails the unchanged oracle, restore the
approved baseline and stop for explicit owner repair/defer/stop.

**Summary analog:** `92-06-SUMMARY.md:1-14,28-53,62-85`. Every summary must carry
the same final `implementation_attempt` value and accepted hashes/status. Record
executed gates, exact bounded aggregates, unchanged frozen blobs, compatibility,
privacy, limitations, deviations, and remaining closeout. Require tracked,
regular, non-symlink summaries and exactly one matching ledger record per
attempt. Do not rewrite failed or archived evidence.

### Owner synchronization and closeout

After measured acceptance only, follow the Phase 91/92 owner-section shape:

- `DESIGN.md`: exact private bridge/root displacement, support ownership,
  renderer-effective admission, field-sum budget, cap/dead-zone/failure rules.
- `PRODUCT_SENSE.md`: owner-visible distinct behavior, unchanged public
  inventory, measured mechanics evidence, and explicit nonclaims.
- `RELIABILITY.md`: deterministic recovery, dense overlap scope, conservative
  Float reconstruction, and failure isolation.
- `QUALITY_SCORE.md`: exact discovered/pass/fail/skip counts, pixel aggregates,
  immutable hashes, focused/package boundary gates, and what did not run.
- `PLANS.md`: scope, research/plan/attempt count, implementation, contract,
  evidence, compatibility, privacy, review/verification, and Phase 95 handoff.

Do not synchronize a passing contract from a failed registration or RED. Add
`SECURITY.md` or `ARCHITECTURE.md` only if execution reveals an actual changed
contract; no such change is currently proposed.

## Shared Patterns

### Frozen authority

Treat `scripts/face-feature-batch-manifest.json`,
`scripts/compare-face-feature-batches.swift`, the runner, shared geometry
pipeline/sampler, backends, renderer schema, and `Warp.metal` as read-only.
Before each acceptance decision, recapture and compare their hashes with Wave 0.
No threshold, ROI, sibling list, metric equation, renderer, shader, public field,
preset, renderer-case inventory, facade, or backend-policy edit is authorized.

### Evidence admission and privacy

Use generated memory-only pixels and Boolean equality assertions. Durable
evidence may contain fixed counts, signed/bounded Q8/Q16 margins, aggregate RGB
deltas, hashes, statuses, and verdicts. It must not contain raw pixels,
landmarks, control points, masks, private paths/locators, media/reports, or agent
transcripts. Cleanup or authority mismatch is infrastructure failure and cannot
be relabeled semantic failure.

### Verification sequence

1. Discover and pass `NoseFixtureRegistrationTests`; stop production if it fails.
2. Discover and freeze `BeautyEngineNoseRepairTests`; confirm intended semantic
   assertions are RED against restored production while infrastructure passes.
3. Extend provider tests, then run the first reviewed production candidate.
4. Run provider, public pixels, registration, compatibility/freshness, comparator
   self-test, runner boundary/cleanup, backend-neutral, archive, SDK-only, and
   diff gates with nonzero discovered counts and zero nose skips.
5. Obtain independent code review and goal verification before completion.

Full portrait evaluation, final clean 65-output publication,
`scripts/run-no-skip-swiftpm.sh`, direct final precision residuals, and any
device/naturalness/commercial/release claim belong exclusively to Phase 95.
Phase 93 must neither run them for completion credit nor claim them.

## No Analog Found

None. Both new test files, the conditional Testing SPI extension, production
provider work, attempt ledger, summaries, owner synchronization, and closeout
gates have tracked repository analogs.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, Phase 90-92
plans/summaries/pattern maps/attempt ledgers, and current SDK-owned scripts.

**Strong analogs used:** 5 (`NoseWarpProvider`, `NoseWarpProviderTests`, eyebrow
registration, eyebrow/chin public repair tests, Phase 92 R5 attempt/summary).

**Pattern extraction date:** 2026-09-09
