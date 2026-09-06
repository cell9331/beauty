# Phase 92: Signed Eyebrow-Head Spacing - Pattern Map

**Mapped:** 2026-09-06  
**Files classified:** 10 expected, 2 conditional  
**Analogs found:** 12 / 12  
**Repository rule:** Every analog named below was confirmed by `git ls-files`; ignored output/report mirrors are not pattern sources.

## File Classification

| New/Modified File | Role | Data Flow | Closest Tracked Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` | provider | transform | same file, `headSpacingPoints` and `spacingPoints` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` | test | transform | same file, dead-zone, cap, per-side, provider-empty, lifecycle tests | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineEyebrowHeadSpacingRepairTests.swift` (create) | test | request-response + transform | `BeautyEngineGazeCorrectionRepairTests.swift`; `BeautyEngineChinTaperRepairTests.swift` | exact role/flow |
| `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift` (conditional) | test utility | transform | same file | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` (conditional, avoid if possible) | test provider | request-response | existing fixture/provider seam in same file, as used by gaze repair tests | exact |
| `DESIGN.md` | owner document | transform | Phase 49 eyebrow contract and Phase 91 current-state section | role-match |
| `PRODUCT_SENSE.md` | owner document | request-response | Phase 91 owner journey | exact role |
| `RELIABILITY.md` | owner document | request-response | Phase 91 reliability contract | exact role |
| `QUALITY_SCORE.md` | owner document | batch | Phase 91 quality evidence | exact role |
| `docs/SDK_EFFECT_TAXONOMY.md` | owner taxonomy | transform | existing `eyebrowHeadSpacing` row | exact |
| `PLANS.md` | ledger | event-driven | completed Phase 91 ledger entry | exact role |
| `.planning/phases/92-signed-eyebrow-head-spacing/92-0X-SUMMARY.md` (created by execution, one per plan) | summary | event-driven | Phase 91 summaries | exact role |

The implementation should not modify the frozen manifest, comparator, runner, boundary test, shared geometry pipeline, renderer-report schema, public parameters, `Warp.metal`, `ARCHITECTURE.md`, or `SECURITY.md`. Those are verification authorities or unchanged boundaries, not Phase 92 edit targets.

## Pattern Assignments

### `EyebrowWarpProvider.swift` (provider, transform)

**Primary analog:** `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift`

**Imports and private-provider convention** (lines 1-3, 31-34):

```swift
import Foundation
import BeautyDetection

struct EyebrowWarpProvider: WarpControlPointProvider {
    private let strengthDeadZone = Float.ulpOfOne
    private let geometryEpsilon: Float = 0.000_001
```

Keep all repair math private to this provider. Add no public type or report schema.

**Side-local routing** (lines 54, 71-72, 82-85):

```swift
let traces = semanticTraces(in: face)
eyebrowHeadSpacing: isSignedWork(strengths.eyebrowHeadSpacing, maximum: headSpacingCap)
    ? traces.flatMap { headSpacingPoints(trace: $0, face: face,
        strength: strengths.eyebrowHeadSpacing, maximum: headSpacingCap) } : []

private func semanticTraces(in face: FaceGeometry) -> [BeautyEyebrowSemanticTrace] {
    guard let support = face.observedEyebrowSupport else { return [] }
    return [support.left, support.right].compactMap { $0 }
}
```

Copy this independent `compactMap`/`flatMap` ownership: each valid side emits from its own trace. Do not introduce paired eligibility, mirroring, or peer borrowing.

**Whole-brow sibling contrast** (lines 154-168):

```swift
guard validFace(face), let support = face.observedEyebrowSupport,
      support.pairedEligible, let left = support.left, let right = support.right,
      left.side == .left, right.side == .right,
      validTrace(left), validTrace(right), let axis = normalized(right.center - left.center)
else { return [] }
let sources = left.points + right.points
let targets = left.points.map { $0 - axis * displacement } +
    right.points.map { $0 + axis * displacement }
```

This is the deliberate anti-pattern for head spacing: `eyebrowSpacing` requires a pair and translates full traces. Phase 92 must remain observably different.

**Current repair seam** (lines 171-188):

```swift
guard validFace(face), validTrace(trace), trace.points.count >= 2,
      let axis = normalized(trace.outerEndpoint - trace.innerEndpoint)
else { return [] }
// Existing implementation chooses [innerEndpoint, points[1]] and one fixed radius.
```

Replace only the seam's carrier/displacement/radius construction. Follow research attempt-one: cumulative polyline progress from the canonical inner endpoint, carriers only for `p < 0.5`, smoothstep-complement taper, signed own-axis motion, and target-centered radius bounded by positive clearance to the private head-zone cutoff. Any non-finite, non-positive, or out-of-unit result returns no points for that side.

**Shared fail-closed admission** (lines 246-264, 267-301):

```swift
guard sources.count == targets.count, !sources.isEmpty,
      radius.isFinite, radius > geometryEpsilon, radius <= 1,
      strength.isFinite, strength > strengthDeadZone, strength <= maximumStrength,
      sources.indices.allSatisfy({ isUnitPoint(sources[$0]) && isUnitPoint(targets[$0]) })
else { return [] }
let representablePairs = zip(sources, targets).filter { $0.0 != $0.1 }
guard !representablePairs.isEmpty else { return [] }
```

If tapered carriers need individual radii, preserve these same checks in a private one-carrier helper; do not weaken `validFace`, `validTrace`, unit bounds, cap, or the exact `Float.ulpOfOne` dead zone.

### `EyebrowWarpProviderTests.swift` (test, transform)

**Primary analog:** existing `EyebrowWarpProviderTests`.

Use its `@testable` imports and direct provider seam (lines 1-5). Extend, rather than replace, the table-driven safety vocabulary.

**Exact dead zone and first eligible magnitude** (lines 28-53):

```swift
for neutral in [Float.zero, Float.ulpOfOne] + (row.isSigned ? [-Float.ulpOfOne] : []) {
    let emissions = provider.fieldEmissions(face: face, strengths: row.strengths(neutral))
    XCTAssertTrue(row.emission(emissions).isEmpty)
}
let firstEligible = Float.ulpOfOne.nextUp
```

Retain this exact boundary. Provider-coordinate assertions may prove admission and direction, but they do not replace final-pixel acceptance.

**Head-only locality** (lines 257-263):

```swift
let emissions = EyebrowWarpProvider().fieldEmissions(face: face(left: left), strengths: headSpacingStrength(0.25))
assertRenderable(emissions.eyebrowHeadSpacing)
XCTAssertTrue(emissions.eyebrowHeadSpacing.contains { $0.source == left.innerEndpoint })
XCTAssertFalse(emissions.eyebrowHeadSpacing.contains { $0.source == left.outerEndpoint })
```

Add both signs and both sides using axis-dot assertions; verify normalized-progress carrier selection, monotone displacement/radius taper, no source at or beyond `p == 0.5`, target/unit safety, mixed valid/invalid peers in both orientations, provider-empty behavior, determinism, and valid-invalid-valid recovery.

**Request isolation** (lines 321-337): reuse the `valid, missing, valid, left-only, right-only` immutable fixture sequence. Assert the first and third head-spacing emissions are identical and invalid peer state cannot leak.

### `BeautyEngineEyebrowHeadSpacingRepairTests.swift` (new test, request-response + transform)

**Closest analogs:** `BeautyEngineGazeCorrectionRepairTests.swift` and `BeautyEngineChinTaperRepairTests.swift`.

**Production-facade imports and in-memory RGBA8 path** (gaze lines 1-6, 384-401):

```swift
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
return CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
    size: CGSize(width: width, height: height), format: .RGBA8,
    colorSpace: colorSpace)
```

Generate deterministic 512x512 pixels in memory. Render source, neutral, head `+0.25`, head `-0.25`, whole-brow `+0.25`, and whole-brow `-0.25` through `BeautyEngine.processResult`; preserve extent, explicit sRGB, RGBA8, alpha, neutral identity, repeated-byte determinism, and metadata assertions.

**Actual-pixel threshold structure** (chin lines 44-63):

```swift
XCTAssertEqual(neutral.bytes, source)
XCTAssertEqual(active.bytes, repeated.bytes)
let targetSignal = signal(source, active.bytes, width: width, height: height, regions: [target])
XCTAssertGreaterThanOrEqual(targetSignal.changedPixels, 500)
let outside = signal(source, active.bytes, width: width, height: height) { x, y in
    !target.contains(x: x, y: y, width: width, height: height)
}
```

Use the Phase 89 BROW-01 constants unchanged: target `>=500` changed and `>=2,000` RGB delta against source and neutral; signed inner-head-gap Q16 `>=+16` / `<=-16`; each opposite-sign and whole-brow sibling difference `>=16`; outside `<=128/512`; each outer-anchor and eye region `<=64/256`; background and watermark exactly `0/0`.

**Independent fixed-point oracle** (chin lines 194-209):

```swift
let lumaQ8 = Int64(bytes[offset]) * 77
    + Int64(bytes[offset + 1]) * 150
    + Int64(bytes[offset + 2]) * 29
let darkness = max(0, Int64(255 * 256) - lumaQ8)
```

Mirror the comparator's integer darkness-centroid definition and independently declared PPM rectangles. Never derive expected marker positions or regions from provider targets.

**Per-side safety and lifecycle** (gaze lines 87-125, 127-161): use table-driven left-only/right-only/malformed-peer cases and a reused `SDKTestingFaceDetectionProvider([valid, invalid, valid])`. One-sided cases prove survivability and source-exact peer protection only; do not apply the bilateral head-gap requirement to them.

**Redaction assertion** (gaze lines 281-297): scan warnings, metric keys, and detection reasons for forbidden anatomy/pixel/path/transcript terms. No new semantic production aggregate is expected for Phase 92.

### Conditional test support files

Prefer direct mixed-side `FaceGeometry` construction in `EyebrowWarpProviderTests.swift`. Edit `EyebrowSafetyFixtures.swift` only if the fixture is reusable across several focused tests; follow its production-adapter validation pattern (lines 127-175) and immutable `FaceGeometry` builder (lines 178-200). Edit `BeautyEngineTestingSupport.swift` only if the public-facade lifecycle cannot be expressed with its existing paired, left-only, right-only, missing, and malformed cases. Any addition remains testing SPI and request-local; it is not a production API.

### Owner documents and ledger

Use narrow current-state append/update patterns only after behavior passes:

- `DESIGN.md`: follow the precise eyebrow contract style at lines 202-208. Document private head-only axis/taper/fail-closed mechanics without changing the seven-field public contract or `0.25` cap.
- `PRODUCT_SENSE.md`: follow Phase 91 lines 424-450: owner-visible sign behavior, measured aggregate results, unchanged inventories, Phase 95 handoff, and explicit nonclaims.
- `RELIABILITY.md`: follow Phase 91 lines 611-640: request-local failure/recovery, deterministic valid-invalid-valid behavior, exact gates and cleanup, unchanged API/backend/shader, and nonclaims.
- `QUALITY_SCORE.md`: follow Phase 91 lines 539-581: record the shared implementation attempt, exact actual-pixel aggregates, case coverage, package-host/preflight/boundary results, and what did not run.
- `docs/SDK_EFFECT_TAXONOMY.md`: update only the existing row at line 145; keep `eyebrowHeadSpacing` and do not invent a new control.
- `PLANS.md`: mirror the completed Phase 91 ledger shape: scope, attempt count, implementation, contract, exact evidence, compatibility, privacy, and Phase 95 handoff.

### Phase summaries and shared two-attempt contract

**Analog:** `.planning/phases/91-independent-gaze-correction/91-01-SUMMARY.md` lines 1-38 and `.planning/phases/91-independent-gaze-correction/91-04-SUMMARY.md` lines 62-70, 95-105, 193-199.

Every Phase 92 plan summary must contain exactly one common frontmatter field:

```yaml
implementation_attempt: 1  # or 2, but identical across every Phase 92 summary
```

The closeout must admit every summary as a tracked regular non-symlink file and require exactly one matching attempt record per summary. Attempt two is shared across the whole phase, not reset per plan. If attempt two fails the unchanged frozen oracle, stop for an explicit owner decision; do not write attempt three, retune thresholds, or relabel semantic failure as infrastructure failure.

## Shared Patterns

### Frozen package-host final authority

**Sources:** `scripts/run-face-feature-batches.sh` lines 21-32, 744-810, 892-943; frozen manifest/comparator.

The runner renders each manifest case through the package executable with `--backend cpu`, produces two fresh attempts, compares canonical stable payloads/digests, verifies exact run inventory, cleans temporary reports/workspaces/repeat media, then atomically publishes only aggregate JSON. Phase 92 must execute the exact existing `eyebrowHeadSpacing_plus0p25` and `eyebrowHeadSpacing_minus0p25` rows and their frozen siblings; it must not edit their IDs, parameters, rectangles, metric, or thresholds.

### Aggregate-only evidence and cleanup

**Sources:** `scripts/run-face-feature-batches.sh` lines 901-913, 927-939; `scripts/test-face-feature-batch-boundaries.py` lines 92-105, 229-246.

Durable evidence may contain fixed counts, bounded deltas, signed Q16 margins, digests, status, and pass/fail facts. Reject path/media/transcript terms, preserve infrastructure failure envelopes, and require cleanup fault-injection success. Never persist pixels, images, masks, eyebrow coordinates, renderer reports, private fixture locators, or child-agent transcripts.

### Error handling and recovery

Provider errors fail closed per side by returning an empty point list; the public facade preserves source or unaffected sibling output. A missing/invalid peer cannot suppress a valid side. A valid-invalid-valid reused engine must reproduce the first output and aggregates on the third request. No thrown error, warning, or metric may serialize private geometry.

### No new report contract

The existing independently declared `innerBrowHeadGap` darkness-centroid over final PNG pixels already binds acceptance to production output. Do not add a renderer report schema or provider-intent aggregate unless execution first proves a concrete binding gap; research found none.

## No Analog Found

None. The new public-facade repair test has two strong completed-repair analogs, and every conditional or documentation file has a tracked in-repository pattern.

## Metadata

**Search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `scripts`, root owner documents, Phase 89 frozen verification, and completed Phase 91 summaries.  
**Ignored mirrors excluded:** owner-local batch output and local-test-record paths were not used as source authority.  
**Pattern extraction date:** 2026-09-06.

## PATTERN MAPPING COMPLETE
