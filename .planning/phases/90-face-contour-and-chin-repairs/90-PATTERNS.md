# Phase 90: Face Contour and Chin Repairs - Pattern Map

**Mapped:** 2026-08-26
**Files analyzed:** 14 likely new/modified files
**Analogs found:** 14 / 14

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` | provider | transform | same file, observed-contour `templeFullness` / `cheekboneSlim` and existing continuity implementation | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` | provider | transform | same file, centerline-gated taper and signed `chinLength` isolation | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | request-response / transform | same file, provider-owned preflight and monotone retained-set convergence | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | dispatcher | streaming transform / pixel I/O | same file, CPU unified warp path | exact |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | test | transform | same file, Phase 46/48 source, direction, cap, isolation, and fail-closed matrices | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | request-response | same file, cap/provider-empty/freshness behavior | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | same file, shared-scale retained-strength arithmetic | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform | same file, convergence and sibling-combination safety | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | event-driven state transition | same file, no-face/missing/malformed/reused/stale recovery tables | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift` | test | streaming transform / pixel I/O | same file, generated gradient raster and local pixel movement | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | test | request-response / pixel I/O | same file, public facade, source-safe degradation, redaction, and output equality | exact |
| `scripts/compare-face-feature-batches.swift` | validation utility | batch / file-I/O / transform | same file, frozen Phase 89 `contourContinuityGain` and `centerlineTaper` contracts | exact (consume, do not weaken) |
| `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `docs/SDK_EFFECT_TAXONOMY.md` | contract docs | batch | their existing Phase 45–48 face contracts and Phase 89 validation entries | exact |
| `PLANS.md` and Phase 90 planning artifacts | ledger / config | event-driven / batch | existing v1.21 and Phase 89 closeout entries | exact |

No public parameter, preset, renderer case, facade signature, package target,
resource, model, Metal source, or backend file should be created or modified.
In particular, `BeautySafetyCaps.swift` is an assertion source, not a repair
seam: `faceContourSmooth` and `chinTaper` remain exactly `0.25`.

## Pattern Assignments

### `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` (provider, transform)

**Primary analog:** the same file's observed-contour field ownership and
fail-closed emission structure.

**Named emission and per-field sanitization pattern** (lines 1-30):

```swift
struct FaceShapeWarpFieldEmissions: Equatable, Sendable {
    let faceContourSmooth: [WarpControlPoint]
    // sibling arrays remain independently owned

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.faceContourSmooth != 0, faceContourSmooth.isEmpty {
            sanitized.faceContourSmooth = 0
        }
        return sanitized
    }
}
```

Keep `fieldEmissions`' stable face-field order and preserve every shipped
sibling body byte-for-byte unless a test proves an unavoidable interaction.
The repair belongs inside `smoothContourPoints`, not in `faceSlim`, `faceSmall`,
`faceVShape`, or `jawSlim` and not in the shared renderer.

**Observed-support-only guard** (lines 157-178):

```swift
guard strength.isFinite,
      strength > 0,
      face.bounds.width.isFinite,
      face.bounds.width > 0,
      let support = face.observedFaceSupport,
      support.contourEligible
else { return [] }

let contour = support.contour
guard contour.count >= 4,
      contour.allSatisfy(isFiniteUnitPoint)
else { return [] }
```

Retain this ownership: never fall back to `face.faceContour` for
`faceContourSmooth`. The legacy contour remains available only to the shipped
controls. Validate all intermediate values before clamping and return an empty
named emission on any malformed/non-finite/ineligible state.

**Closest repair mechanics:** the existing continuity algorithm at lines
180-291 and contour-band algorithm at lines 392-485. Reuse their concrete
shape:

```swift
let rawDeltas = eligibleIndices.map { index in
    (contour[index - 1].x + contour[index + 1].x) / 2 - contour[index].x
}
let rawMean = rawDeltas.reduce(0, +) / Float(rawDeltas.count)
let centeredDeltas = rawDeltas.map { $0 - rawMean }

let ceiling =
    0.012 * face.bounds.width * strength / BeautySafetyCaps.faceContourSmooth
```

The useful pattern is contour-order-aware, mean-centered, bounded lateral
motion with unchanged Y, excluded endpoints/horizontal extrema, finite targets,
and a local radius/falloff. The current low-amplitude/quantization-heavy
implementation is the likely repair target; do not change the established
`0.25` strength cap or Phase 89 thresholds. Prefer a deterministic correction
that survives the CPU raster at the renderer fixture resolution while still
reducing both eligible and whole-contour roughness and preserving net lateral
centering.

**Validated point pattern** (lines 506-530):

```swift
guard isFiniteUnitPoint(source), isFiniteUnitPoint(target),
      radius.isFinite, radius > 0,
      strength.isFinite, strength > 0,
      falloff.isFinite, falloff > 0
else { return nil }
return WarpControlPoint(
    source: source, target: target,
    radius: min(max(radius, 0.04), 0.35),
    strength: strength, falloff: falloff
)
```

### `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` (provider, transform)

**Analog:** the same file's independent `chinLength` / `chinTaper` emission
ownership (lines 1-42).

```swift
struct ChinWarpFieldEmissions: Equatable, Sendable {
    let chinLength: [WarpControlPoint]
    let chinTaper: [WarpControlPoint]

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.chinLength != 0, chinLength.isEmpty { sanitized.chinLength = 0 }
        if strengths.chinTaper != 0, chinTaper.isEmpty { sanitized.chinTaper = 0 }
        return sanitized
    }
}
```

The repair stays inside `chinTaperPoints`; `chinLengthPoints` is the exact
sibling distinctness oracle and must retain its signed vertical apex motion.

**Centerline-gated support and inward-only transform** (lines 71-142):

```swift
guard let support = face.observedFaceSupport,
      support.centerlineEligible,
      let medianLine = support.medianLine,
      medianLine.count >= 2,
      let apexIndex = support.apexIndex,
      apexIndex > support.contour.startIndex,
      apexIndex < support.contour.index(before: support.contour.endIndex)
else { return [] }

let sourceIndices = [apexIndex - 1, apexIndex + 1]
let maximumDisplacement =
    0.016 * face.bounds.width * strength / BeautySafetyCaps.chinTaper
```

For each flank, interpolate the median X at that source Y, move horizontally
toward that axis, keep Y exact, and prove the target is strictly closer. Keep
the apex itself unmoved. If the current two-neighbor field is too weak in the
Phase 89 centerline ROI, extend only within a centerline-gated lower-chin band
derived from the same observed contour/median ownership; do not borrow
`faceVShape`, `jawSlim`, or `chinLength` sources/vectors.

### `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` (service, request-response / transform)

**Analog:** existing cap, preflight, retained-set convergence, and final
emission accounting.

**Exact cap pattern** (lines 145-169):

```swift
strengths.faceContourSmooth = capUnit(
    normalized.faceContourSmooth,
    cap: BeautySafetyCaps.faceContourSmooth,
    cappedCount: &cappedCount
)
strengths.chinTaper = capUnit(
    normalized.chinTaper,
    cap: BeautySafetyCaps.chinTaper,
    cappedCount: &cappedCount
)
```

**Provider-owned preflight** (lines 339-370):

```swift
strengths = faceProvider
    .fieldEmissions(face: faceGeometry, strengths: strengths)
    .sanitizing(strengths)
strengths = chinProvider
    .fieldEmissions(face: faceGeometry, strengths: strengths)
    .sanitizing(strengths)
```

**Monotone convergence** (lines 655-713): emissions are evaluated at conflict-
scaled strengths and sanitize the retained unscaled baseline; a removed field
must never re-enter. Preserve the exact 44-field bound and stable provider
order. Final effective strengths, active domains, warnings, and
`geometryPointCount` must continue to come from the final named emissions
(lines 443-473), not from requested values or changed pixels.

No new warnings should include field names, contour/median values, indices,
coordinates, bounds, or paths. Existing aggregate metrics are sufficient.

### `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` (dispatcher, streaming pixel transform)

**Analog:** same file, unified provider dispatch and original-source CPU warp.

**Exactly-once provider order** (lines 7-21):

```swift
return FaceShapeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    ChinWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    EyeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    EyebrowWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    NoseWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    MouthWarpProvider().makeControlPoints(face: face, strengths: strengths).points
```

Do not add a pass or special-case either repair here. The CPU path rasterizes
once in explicit sRGB (lines 55-135), samples every changed pixel from the
immutable source bytes (lines 142-202), and crops back to the original extent.
That is the required public still-image route. `Warp.metal`, the backend
contract, and both public facade signatures remain untouched.

### `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` (provider tests, transform)

**Analog:** existing face-continuity assertions at lines 325-422 and chin-taper
assertions at lines 566-620.

For `faceContourSmooth`, copy the current concrete assertions:

- emitted sources are the eligible observed-contour interior subset;
- Y is unchanged, horizontal extrema are excluded, all points are finite and
  bounded, and displacement stays under the established geometric ceiling;
- signed displacement sum/mean remain approximately zero;
- eligible and complete contour lateral roughness decrease;
- the array differs from `faceSmall` and repeated calls are identical;
- missing/malformed observed support and zero strength emit nothing.

For `chinTaper`, retain and extend:

- sources flank but exclude `apexIndex`;
- Y is unchanged and each target is closer to interpolated median X;
- displacement remains under `0.016 * width * requested / 0.25` unless the
  implementation changes its provider-local geometric ceiling deliberately;
- sources remain disjoint from `chinLength`, `faceVShape`, and `jawSlim`;
- missing/invalid centerline and zero strength emit nothing;
- cap, reused `0.5`, stale/no-face, and recovery transitions stay exact.

Add adversarial generated contours that previously quantized to no visible
output, plus source-order/asymmetry cases. Assert semantic geometry (roughness
gain or lower-chin width reduction), not only non-empty arrays or point counts.

### `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift` (pixel-output tests)

**Analog:** generated in-memory gradient fixture and pixel sampling at lines
180-218 and 265-340.

```swift
let input = gradientRGBABytes(width: width, height: height)
let image = CIImage(
    bitmapData: Data(input), bytesPerRow: width * 4,
    size: CGSize(width: width, height: height),
    format: .RGBA8, colorSpace: colorSpace
)
let output = BeautyGeometryEffectPipeline.applyMVPProxy(
    to: image, plan: plan, face: fixture
)
```

Create separate deterministic raster tests for the two repaired fields at the
actual public-renderer strength (`0.25`). Measure output pixels inside the
Phase 89 semantic ROI and protected regions. Required evidence:

- neutral input is byte-identical;
- active output changes target pixels and improves contour continuity or
  contracts centerline chin width in the required sign;
- background and named protected anatomy are exact or within their frozen
  Phase 89 ceilings;
- output extent, alpha, and explicit color-space behavior remain unchanged;
- repeated runs are byte-identical;
- each output differs semantically from the named sibling outputs, not merely
  by hash or changed-pixel count.

Generated/in-memory fixtures are the mandatory mechanics authority. Do not add
portrait media or raw output evidence to the repository.

### `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` (public-facade tests)

**Analog:** isolated route table at lines 7-52 and missing/malformed sibling
continuation at lines 142-203.

```swift
let result = try engine.processResult(
    image: Self.image,
    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
    parameters: row.parameters
)
XCTAssertEqual(provider.invocationCount, 1)
XCTAssertEqual(result.output.extent, Self.image.extent)
XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
XCTAssertTrue(result.warnings.isEmpty)
assertRedacted(result)
```

Upgrade the two relevant rows from route-only evidence to actual output-pixel
evidence. Keep the missing/malformed support oracle: requesting a repaired
field beside `faceSlim` must render byte-identically to the sibling-only
baseline, with equal aggregate domains/warnings/metrics and no support details.
Add no-face, stale, reused, malformed, recovery, determinism, metadata, and
protected-region checks here or in the established focused safety files.

### `scripts/compare-face-feature-batches.swift` and Phase 89 contract (validation utility, batch/file-I/O)

**Analog/authority:** the Phase 89 implementation is a consumer gate, not a
repair seam.

The frozen inventory and sibling comparisons are at lines 203-267:

```swift
.init(
    caseID: "faceContourSmooth_0p25",
    metric: .contourContinuityGain,
    sign: .positive,
    comparisons: ["source", "geometryBaseline_noop", "faceSmall_0p35", "faceSlim_0p35"]
)
.init(
    caseID: "chinTaper_0p25",
    metric: .centerlineTaper,
    sign: .positive,
    comparisons: ["source", "geometryBaseline_noop", "chinLength_plus0p30",
                  "chinLength_minus0p30", "faceVShape_0p35", "jawSlim_0p35"]
)
```

The protected-region ordering is frozen at lines 1418-1426:

```swift
"faceContourSmooth_0p25": ["centralAnatomy", "background", "watermark"],
"chinTaper_0p25": ["upperFace", "mouth", "background", "watermark"],
```

Do not change the semantic digest, contract regions, signs, thresholds, or
sibling lists to make the repair pass. Phase 90 should run comparator self-test
plus the live aggregate command only after focused generated pixel tests pass.
Authorized portrait inputs, paths, rows, and images stay outside durable
evidence; only aggregate counts/verdicts are admissible.

### Contract documents (docs/config, batch)

Update only facts whose behavior changed:

- `DESIGN.md`: provider-local contour/chin mechanics, unchanged exact caps,
  retained-set behavior, and automated evidence limits.
- `ARCHITECTURE.md`: only if the implementation boundary changes; the preferred
  result leaves the unified CPU/provider architecture unchanged.
- `SECURITY.md`: observed contour/median remain request-local, no proxy support,
  source-safe malformed/stale handling, protected-region evidence.
- `RELIABILITY.md`: deterministic recovery, per-field degradation, aggregate-
  only diagnostics, source output on rejected work.
- `QUALITY_SCORE.md`: focused semantic pixel gates and Phase 89 comparator gate.
- `docs/SDK_EFFECT_TAXONOMY.md`: retain `implemented` and clarify repaired
  observed-contour continuity / centerline taper only after evidence passes.
- `PLANS.md` and phase artifacts: record commands and aggregate outcomes; no
  raw portrait paths, pixels, masks, landmarks, or per-fixture reports.

## Shared Patterns

### Support ownership and failure isolation

`faceContourSmooth` consumes only `observedFaceSupport.contourEligible`.
`chinTaper` additionally requires `centerlineEligible`, a validated median,
and a valid contour apex. Missing, malformed, stale, or non-emitting support
zeros only its own field. An independently valid shipped sibling continues.
Neither repair may borrow sibling geometry as a proxy.

### Exact compatibility

Assert, do not edit, the current public snapshot: 62 stored parameter fields,
five presets, 75 renderer cases, unchanged Codable/default/neutral behavior,
two public still-image facade signatures, and the existing CPU/GPU contract.
Do not touch retained `Warp.metal` or introduce a GPU/Metal API/backend.

### Geometry and source-pixel safety

Use finite image-normalized points, pre-clamp validation, bounded targets,
local radii, falloff 2, and original-source CPU sampling. Keep target/protected
ROI assertions tied to actual rendered pixels. An arbitrary difference,
watermark pixel, provider point count, or successful process exit is not proof.

### Privacy-safe evidence

Raw contour/median coordinates, landmarks, masks, image pixels, fixture paths,
authorized portraits, and per-portrait details remain request-local or ignored.
Persistent diagnostics and planning evidence contain only fixed reason codes,
aggregate counts, and aggregate verdicts. Generated deterministic fixtures are
mechanics evidence, not population, device, commercial-quality, or release
evidence.

## No Analog Found

None. Both repairs already have exact provider, resolver, CPU warp, facade,
semantic comparator, and generated-test analogs. The planner should prefer
minimal edits in the two providers plus focused tests; a new helper is justified
only if it remains package-private and genuinely shares finite centerline or
contour math without merging semantic ownership.

## Metadata

**Analog search scope:** `BeautySDK/Sources/BeautyEffects/{Planning,Warp,Render,Backend}`,
`BeautySDK/Sources/BeautySDK`, `BeautySDK/Tests/{BeautyEffectsTests,BeautyCoreTests}`,
`scripts/compare-face-feature-batches.swift`, Phase 89 artifacts, archived
Phases 46–48 pattern/plan records, and current root owner documents.

**Strong analogs read:** 5 production files, 3 focused test files, the Phase 89
semantic utility/contracts, and the archived Phase 46/48 pattern maps.

**Pattern extraction date:** 2026-08-26
