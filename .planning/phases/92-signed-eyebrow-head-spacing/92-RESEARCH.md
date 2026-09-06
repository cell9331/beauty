# Phase 92: Signed Eyebrow-Head Spacing - Research

**Researched:** 2026-09-06  
**Domain:** Owner-local Swift eyebrow geometry, CPU warp rendering, and actual-pixel semantic validation  
**Confidence:** HIGH for the current failure and integration boundaries; MEDIUM for the proposed private coefficients until they pass the frozen oracle

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

## Implementation Decisions

### Signed Direction and Side Eligibility
- **D-01:** Preserve the frozen public sign semantics from Phase 89: positive `eyebrowHeadSpacing` increases the distance between the two inner brow heads, while negative values decrease it.
- **D-02:** Each eligible side moves along its own canonical inner-to-outer eyebrow axis. Positive motion follows that axis away from the facial midline; negative motion reverses it toward the midline.
- **D-03:** Preserve the established per-side eligibility contract for this control. A valid eyebrow may emit head-spacing geometry when its peer is missing or invalid; the provider must not fabricate, mirror, or borrow peer geometry.
- **D-04:** When both sides are eligible, effectiveness evidence must observe the intended bilateral head-gap change. A one-sided or invalid-peer safety case proves local survivability, not the bilateral effectiveness requirement.
- **D-05:** Preserve the existing exact dead zone at `Float.ulpOfOne`, the public magnitude cap of `0.25`, request-local observations, and fail-closed behavior. This phase may repair effective motion inside that contract but must not widen it.

### Local Influence and Outer-Anchor Protection
- **D-06:** Keep the implementation repair inside the narrow `EyebrowWarpProvider.headSpacingPoints` seam, or a private helper owned by that seam. Do not change `Warp.metal`, the shared backend, the public parameters, or the behavior of whole-brow spacing and the other five eyebrow controls.
- **D-07:** Influence must remain centered on the independently observed inner endpoint and only the limited adjacent carriers needed for a stable local deformation. Motion and radius/support must taper before the outer-anchor regions rather than translating the whole trace.
- **D-08:** The exact Phase 89 outer-anchor and non-brow protection limits are immutable acceptance contracts: each outer-anchor region permits at most 64 changed pixels and 256 total RGB delta; eye regions use the same limits; background and watermark regions permit zero change and zero delta.
- **D-09:** Research and planning may choose the exact private displacement scale, taper, number of adjacent carrier points, and anatomy-bounded radius. Those choices must make both signs clear at the frozen thresholds without weakening thresholds or globally expanding support.

### Effectiveness Evidence and Semantic Distinction
- **D-10:** Use the exact Phase 89 frozen cases `eyebrowHeadSpacing_plus0p25` and `eyebrowHeadSpacing_minus0p25` as the end-to-end acceptance oracle. Do not rename the cases, alter their parameters, or lower their thresholds.
- **D-11:** Each case must begin with real target signal in the source and neutral render, then satisfy at least 500 changed target pixels, 2,000 total target RGB delta, and the signed `innerBrowHeadGap` Q16 threshold of magnitude 16 in the documented direction.
- **D-12:** Both signs must be tested from actual rendered pixels and metadata, using deterministic generated 512×512 explicit-sRGB RGBA8 input rather than provider-coordinate assertions alone.
- **D-13:** Each candidate must remain measurably distinct from its opposite-sign sibling and from both whole-brow `eyebrowSpacing` siblings. A repair that merely reproduces whole-brow spacing does not satisfy BROW-01.
- **D-14:** Retain the existing independently declared dark-centroid `innerBrowHeadGap` metric and protected-region comparator as the default proof path. Unlike the retired eye-pixel pupil proxy, this metric directly measures the independently declared brow-head markers in the generated oracle.
- **D-15:** Do not add a renderer report schema or new semantic aggregate by default. Research may recommend one only if it demonstrates a concrete production-output binding gap that the current actual-pixel oracle cannot close; any such addition must stay fixed-size, aggregate-only, and independently asserted.

### Failure Recovery, Privacy, and Closeout
- **D-16:** Retain or add focused coverage for neutral identity, exact dead zone, no face, missing/stale/reused/malformed support, missing or invalid individual sides, provider-empty behavior, valid-invalid-valid lifecycle recovery, determinism, and package-host execution.
- **D-17:** Persist only counts, bounded deltas, pass/fail facts, and other fixed aggregate evidence. Never persist raw pixels, masks, eyebrow coordinates, private fixture locators, generated images, renderer reports, or child-agent transcripts.
- **D-18:** Phase 92 gets one research pass, one independently checked plan, and at most two implementation attempts shared across all plans and summaries. A second failed implementation attempt ends in an explicit owner decision rather than silent threshold drift or a third attempt.
- **D-19:** Phase 92 closeout is the focused generated/package-host BROW-01 gate plus relevant SwiftPM safety tests and SDK-owned boundary checks. Live owner-controlled portraits and the milestone-wide no-skip closeout remain Phase 95 work.
- **D-20:** Passing this phase supports only the owner-local generated-fixture contract. It does not establish real-device performance, portrait quality, commercial visual quality, packaging, shipping, launch, external distribution, or release readiness.

### the agent's Discretion
- The private local-warp math inside the locked provider seam: displacement curve, carrier taper, bounded radius, and internal helper naming.
- The smallest focused SwiftPM test organization and generated-fixture construction needed to prove the locked contracts without adding production API surface.
- Whether a fixed aggregate report bridge is genuinely necessary after research; the default is to avoid one because the current brow metric is independently declared and pixel-derived.
- Exact ordering of focused tests and SDK-owned scripts, provided the Phase 89 manifest remains the final end-to-end BROW-01 authority.

### Deferred Ideas (OUT OF SCOPE)
- Phase 95 owns live owner-controlled portrait runs, optional rights-approved local fixture feedback, milestone-wide integration, and the final SDK-owned no-skip closeout.
- Any model, training data, weight, Metal/GPU backend, application/UI, public API expansion, packaging, commercialization, or external distribution work requires a separately authorized future milestone.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| BROW-01 | Positive and negative `eyebrowHeadSpacing` move only the two inner eyebrow heads in opposite documented directions, preserve the outer eyebrow anchors and non-brow protected regions, and remain semantically distinct from whole-brow `eyebrowSpacing`. | A provider-local, per-side axis warp with a normalized head-zone taper; independent provider safety tests; and the unchanged Phase 89 production-pixel oracle jointly cover direction, locality, protection, and sibling distinction. [VERIFIED: `.planning/REQUIREMENTS.md`, `92-CONTEXT.md`, and Phase 89 manifest/comparator] |
</phase_requirements>

## Summary

The current control is not empty: both signed cases already alter roughly 14.5k target pixels and hundreds of thousands of target RGB units. It fails because that large pixel disturbance produces only `+5` and `-7` Q16 of inner-head-gap motion, below the immutable magnitude `16`, remains only `2` and `8` Q16 from its closest sibling, and exceeds the outside-target RGB budget (`1,861` and `2,131` versus `512`). All four protected-region aggregates are currently zero. [VERIFIED: latest admitted aggregate-only face-feature report, read 2026-09-06] This evidence localizes the problem to low semantic leverage and diffuse support, not to parameter routing or a provider that emits nothing. [VERIFIED: aggregate report plus `EyebrowWarpProvider.swift` routing] The mechanism diagnosis—that two fixed-radius, index-selected kernels overlap too broadly while moving the adjacent carrier by only half—is a code-and-output inference rather than a separately measured fact. [ASSUMED]

The repair should remain entirely inside `headSpacingPoints`: select carriers by normalized progress through the inner half of each independently observed trace, move them on that side's inner-to-outer axis with a smooth taper, and use a smaller radius that tapers and is additionally bounded by remaining clearance to a private head-zone cutoff plane. [ASSUMED] The recommended attempt-one maximum is `0.065 × face width`, with carrier weight `1 - smoothstep(progress / 0.5)`, nominal radius `faceWidth × (0.020 + 0.025 × weight)`, and a radius cap at one half of the axis clearance from the moved target to the 50% head-zone plane. [ASSUMED] This raises endpoint motion from the current `0.020 × face width` by the approximately 3.2× indicated by the weakest measured positive result, while reducing and anatomy-bounding the affected disk. [VERIFIED: current coefficient and measured `+5` margin] [ASSUMED: linear first-order scaling and final adequacy]

No renderer schema or semantic aggregate bridge is needed. The frozen comparator reads final renderer PNG pixels, independently locates declared dark brow-head markers, calculates a Q16 centroid gap, and compares the candidate with source, neutral, opposite sign, and both whole-brow siblings. [VERIFIED: `scripts/compare-face-feature-batches.swift` and `scripts/face-feature-batch-manifest.json`] That is a stronger production-output binding for this control than reporting provider intent. [ASSUMED]

**Primary recommendation:** freeze the private formula above as implementation attempt one, prove its invariants at provider level, and let the unchanged 512×512 Phase 89 cases be the final authority; do not tune the oracle to the implementation. [ASSUMED]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Signed per-side brow-head geometry | `BeautyEffects` field provider | Observed eyebrow adapter | The provider owns private control-point emission; the adapter only supplies request-local semantic traces. [VERIFIED: `ARCHITECTURE.md`, `EyebrowWarpProvider.swift`] |
| Pixel deformation | Shared CPU geometry pipeline | Core Image boundary | The pipeline performs target-centered inverse sampling for all geometry fields and is deliberately outside this repair. [VERIFIED: `BeautyGeometryEffectPipeline.swift`, D-06] |
| Public parameter and render state | `BeautyCore` / SDK facade | Provider resolver | `eyebrowHeadSpacing` already has its public cap, neutral semantics, and request-local state; this phase changes none of them. [VERIFIED: `DESIGN.md`, `BeautyParameters.swift`, D-05/D-06] |
| Semantic acceptance | SDK-owned batch runner and comparator | SwiftPM focused tests | The script path renders through the package host and judges final pixels; provider tests prove local failure and geometry invariants. [VERIFIED: Phase 89 verification and batch scripts] |
| Durable evidence | Aggregate report payload | Temporary run directory | Only bounded counts, deltas, signed margins, digests, and verdicts persist; images and renderer reports remain temporary. [VERIFIED: `SECURITY.md`, runner/comparator, D-17] |

## Project Constraints (from AGENTS.md)

- The repository remains an SDK-only Swift Package; historical UI/demo archives are not build, test, or requirement inputs, and no application/UI/lifecycle or UI automation may be added. [VERIFIED: `AGENTS.md` §§1, 5]
- The SDK is owner-local and not a third-party distribution promise; source, binaries, models, weights, private fixtures, or derived data must not be distributed outside owner-controlled environments. [VERIFIED: `AGENTS.md` §5]
- `Warp.metal`, Metal/GPU APIs/backends, and new algorithms are outside the current boundary. [VERIFIED: `AGENTS.md` §5 and D-06]
- Image-effect evidence must assert actual pixels and metadata, including applicable extent, orientation, color space, alpha, neutral identity, target changes, protected-region identity, tolerance, determinism, and typed failure; a successful script exit alone is insufficient. [VERIFIED: `AGENTS.md` §6]
- Mandatory fixtures should be deterministic and generated in code/in memory; durable evidence must not contain raw pixels, masks, landmarks, private paths, or generated images. [VERIFIED: `AGENTS.md` §6]
- Real-iPhone testing is optional post-SDK feedback unless a later milestone explicitly elevates it; its absence limits claims but does not block Phase 92. [VERIFIED: `AGENTS.md` §6 and D-19/D-20]
- Preserve target boundaries and naming/abstraction levels, run the narrowest meaningful SwiftPM/script checks, and update the current-state owner documents only after verified behavior changes. [VERIFIED: `AGENTS.md` §§7–9]
- The authoritative control status is `docs/SDK_EFFECT_TAXONOMY.md`; contract changes must update the document that owns the contract. [VERIFIED: `AGENTS.md` §§2, 4]

## Current Failure: Exact Diagnosis

### Existing geometry

`headSpacingPoints` normalizes `outerEndpoint - innerEndpoint`, scales signed displacement by `face.bounds.width × 0.020 × strength / 0.25`, chooses exactly `[innerEndpoint, points[1]]`, applies displacement weights `[1.0, 0.5]`, and gives both carriers the same `0.06 × face width` radius and falloff `2`. [VERIFIED: `EyebrowWarpProvider.swift:171-188`] The trace collection compact-maps left and right independently, so a valid side is already eligible without its peer. [VERIFIED: `EyebrowWarpProvider.swift:54-85`] Whole-brow `spacingPoints` is intentionally different: it requires paired support and translates every point on the left/right traces around their shared center axis with coefficient `0.025` and radius `0.08 × face width`. [VERIFIED: `EyebrowWarpProvider.swift:154-168`]

The CPU renderer evaluates influence inside a disk centered on each **target**, uses `(1 - distance/radius)^2`, subtracts each weighted source-to-target displacement from the sample coordinate, and sums overlapping point contributions before bilinear sampling. [VERIFIED: `BeautyGeometryEffectPipeline.swift:142-203,252-288`] Provider `strength` metadata does not further multiply pixel displacement in that loop; the signed displacement is already encoded in each target. [VERIFIED: `BeautyGeometryEffectPipeline.swift:167-180`]

### Frozen-case evidence

| Case | Target changed / RGB delta | Signed gap Q16 | Closest sibling Q16 | Outside changed / RGB delta | Protected regions | Result |
|---|---:|---:|---:|---:|---:|---|
| `eyebrowHeadSpacing_plus0p25` | `14,757 / 464,824` | `+5` (needs `≥+16`) | `2` (needs `≥16`) | `57 / 1,861` (needs `≤128 / ≤512`) | all `0 / 0` | semantic fail [VERIFIED: local aggregate report] |
| `eyebrowHeadSpacing_minus0p25` | `14,504 / 339,046` | `-7` (needs `≤-16`) | `8` (needs `≥16`) | `93 / 2,131` (needs `≤128 / ≤512`) | all `0 / 0` | semantic fail [VERIFIED: local aggregate report] |

The high target signal rules out an inactive parameter and the zero protected-region deltas show the current disks do not reach the four named protected groups in the admitted input. [VERIFIED: local aggregate report] The failed outside RGB budget nevertheless proves that the influence is too diffuse beyond the two target boxes, while the weak signed centroid margins prove that the disturbance has low leverage on the independently marked inner heads. [VERIFIED: manifest thresholds and aggregate report] Indexing `points[1]` makes the physical support depend on trace sample density, and assigning it the same radius as the endpoint prevents radius taper even though displacement is halved. [VERIFIED: provider source] The conclusion that those choices cause the measured inefficiency is the most likely explanation, but must be tested by the frozen oracle. [ASSUMED]

## Standard Stack

### Core

| Component | Version / contract | Purpose | Why standard here |
|---|---|---|---|
| Swift Package Manager | tools version `6.0`; local Swift `6.3.3` | Build and test the owner-local SDK | Existing package and quality gates use SwiftPM. [VERIFIED: `Package.swift`, environment probe 2026-09-06] |
| XCTest | SDK toolchain | Provider, facade, and actual-pixel tests | Existing test targets and fixtures already use XCTest. [VERIFIED: `BeautySDK/Tests`] |
| `BeautyEyebrowSemanticTrace` | existing private contract | Independent inner/outer endpoints and ordered trace points | It supplies the semantic anatomy needed without public API changes. [VERIFIED: provider/adapter sources] |
| CPU `BeautyGeometryEffectPipeline` | existing shared backend | Deterministic RGBA warp and final production pixels | It is the current integrated renderer and must remain unchanged. [VERIFIED: pipeline source and D-06] |
| Phase 89 manifest/comparator/runner | frozen BROW-01 contract | Package-host semantic and locality acceptance | It already binds exact cases to final pixels and aggregate-only evidence. [VERIFIED: Phase 89 verification] |

### Supporting

| Component | Purpose | When to use |
|---|---|---|
| `EyebrowSafetyFixtures` | Deterministic five-point traces and failure shapes | Provider sign, cap, side eligibility, neutral, and lifecycle tests. [VERIFIED: `EyebrowSafetyFixtures.swift`] |
| `BeautyEngineTestingSupport` SPI | Request-local injected observations | Package-facade pixel tests without widening production API. [VERIFIED: `BeautyEngineTestingSupport.swift`] |
| Python boundary tests | Manifest, admission, cleanup, and fault-injection contracts | Before the frozen end-to-end BROW gate. [VERIFIED: `test-face-feature-batch-boundaries.py`] |

### Alternatives considered

| Instead of | Could use | Disposition and tradeoff |
|---|---|---|
| Progress-normalized tapered carriers | Increase the current two displacements only | Rejected: it preserves sample-density coupling and the two broad uniform radii while outside RGB already fails. [VERIFIED: current code/report] [ASSUMED: predicted locality result] |
| Provider-local repair | Change the shared CPU pipeline or `Warp.metal` | Rejected: it expands blast radius across geometry controls and violates D-06. [VERIFIED: locked scope] |
| Existing pixel comparator | New renderer semantic aggregate | Rejected by default: it would report intent beside an oracle that already observes production pixels independently. [VERIFIED: D-14/D-15] [ASSUMED: no additional value] |
| Generated fixture | Live owner portrait | Deferred to Phase 95 and unnecessary for Phase 92 completion. [VERIFIED: D-19] |

No external package is needed, so there is no installation command or package-legitimacy gate for Phase 92. [VERIFIED: `BeautySDK/Package.swift` has no remote package dependencies; proposed design uses SDK/toolchain code only]

## Package Legitimacy Audit

Not applicable: Phase 92 installs no external package. [VERIFIED: package manifest and proposed provider-local scope]

## Recommended Private Warp Mathematics

### Invariants before coefficients

For each trace independently: validate the face and trace, normalize `outerEndpoint - innerEndpoint`, normalize strength by the existing `0.25` maximum, and return `[]` for any non-finite input, invalid trace, degenerate axis, strength in the existing exact dead zone, or non-unit source/target. [VERIFIED: current validation helpers and D-03/D-05] Never consult the peer side inside this helper. [VERIFIED: D-03]

Define cumulative polyline distance from the inner endpoint and normalized progress `p = distanceFromInner / totalTraceLength`. Select only points with `0 ≤ p < 0.5`; this removes dependence on whether an accepted trace has 4, 5, or 16 samples while excluding the outer half. [ASSUMED] Always derive progress from the trace's validated canonical order; never sort by screen `x`, because side, rotation, and pose make `x` an unreliable semantic axis. [VERIFIED: semantic trace contract] [ASSUMED: 50% cutoff adequacy]

For each selected carrier, set `t = clamp(p / 0.5, 0...1)` and `w = 1 - t²(3 - 2t)`. [ASSUMED] This gives the inner endpoint weight `1`, reaches `0` continuously at the head-zone boundary, and gives a five-point trace's first adjacent quarter-progress carrier weight `0.5`. [VERIFIED: algebra] The signed displacement is:

```text
unitStrength = strength / 0.25
delta = axis × (faceWidth × 0.065 × unitStrength × w)
target = source + delta
```

[ASSUMED: coefficient; VERIFIED: sign follows D-01/D-02 by construction]

Use a tapered nominal radius `faceWidth × (0.020 + 0.025 × w)`. [ASSUMED] Then construct a private cutoff plane at `innerEndpoint + axis × (0.5 × chordLength)` and cap each target-centered radius to at most half the positive axis clearance from the moved target to that plane:

```text
clearance = dot(headLimit - target, axis)
radius = min(nominalRadius, 0.5 × clearance)
```

[ASSUMED] Reject the side if the target is outside unit space or any required clearance/radius is non-finite or non-positive; do not clamp a target, borrow another side, or silently reverse direction. [ASSUMED: recommended failure policy; VERIFIED: consistent with existing fail-closed contract]

At the existing deterministic fixture's `faceWidth = 0.4`, full-strength endpoint motion would be `0.026` normalized units (about `13.3` pixels at 512), endpoint nominal radius `0.018` (about `9.2` pixels), and a quarter-progress carrier would move `0.013` with nominal radius `0.014`. [VERIFIED: arithmetic against existing fixture dimensions] These are planning estimates, not acceptance evidence. [ASSUMED]

### Why this formula is the narrowest credible repair

- It preserves exact signed axes and side independence already present in the provider. [VERIFIED: formula and D-02/D-03]
- It raises semantic displacement where the current Q16 result is weakest while reducing the two uniform `0.06 × faceWidth` disks. [VERIFIED: current geometry/report] [ASSUMED: expected effect]
- It makes carrier choice sampling-density independent and tapers both motion and support before the outer half. [VERIFIED: formula] [ASSUMED: suitability for all accepted traces]
- It cannot become whole-brow spacing because it never requires or computes a cross-brow center axis and never emits outer-half carriers. [VERIFIED: formula contrasted with `spacingPoints`]
- It changes neither shared rasterization nor public state. [VERIFIED: proposed file boundary]

The planner should freeze these attempt-one constants in the plan. If the unchanged oracle rejects them, any second attempt must be justified by which frozen aggregate failed; a second failure must stop for owner decision. [VERIFIED: D-18] Do not create an open-ended coefficient-search loop. [VERIFIED: D-18]

## Architecture Patterns

### System Architecture Diagram

```text
owner-local parameter + request-local observation
                    |
                    v
        immutable render-state resolver
                    |
                    v
     EyebrowWarpProvider.fieldEmissions
       |                               |
       | eyebrowHeadSpacing            | eyebrowSpacing (unchanged sibling)
       v                               v
 per-side valid trace?             paired support?
   | no -> emit none                 | no -> emit none
   v yes                             v yes
 inner-half tapered carriers       translate both full traces
   |                                 |
   +---------------+-----------------+
                   v
 shared CPU geometry pipeline (unchanged)
 target-centered inverse sampling -> explicit-sRGB RGBA8 pixels
                   |
                   v
 package-host outputs in temporary run directory
                   |
                   v
 Phase 89 comparator
   |- target signal + changed pixels/RGB
   |- signed innerBrowHeadGap Q16
   |- opposite-sign + whole-brow sibling distinction
   `- outside/protected-region budgets
                   |
                   v
 fixed aggregate verdict/digest only; temporary media cleaned
```

[VERIFIED: current resolver/provider/pipeline/runner/comparator architecture; ASSUMED: proposed tapered-carrier stage]

### Recommended project structure and minimal file surface

```text
BeautySDK/
├── Sources/BeautyEffects/Warp/
│   └── EyebrowWarpProvider.swift                 # required implementation edit
├── Sources/BeautySDK/
│   └── BeautyEngineTestingSupport.swift          # only if mixed valid/invalid SPI case is needed
├── Tests/BeautyEffectsTests/
│   ├── EyebrowWarpProviderTests.swift            # required provider invariant tests
│   └── EyebrowSafetyFixtures.swift               # edit only for a reusable mixed-side fixture
└── Tests/BeautyCoreTests/
    └── BeautyEngineEyebrowHeadSpacingRepairTests.swift  # recommended Wave 0 pixel/facade test
```

[ASSUMED: recommended minimal edit set]

The production edit is one file. [ASSUMED] Prefer constructing valid-left/invalid-right and invalid-left/valid-right `FaceGeometry` directly in `EyebrowWarpProviderTests`; that avoids expanding testing SPI or shared fixtures. [ASSUMED] The facade pixel test can use existing paired, left-only, right-only, missing, and malformed observation cases; add a testing-SPI enum case only if a mixed valid/invalid side cannot be expressed through an existing test seam. [VERIFIED: current test support cases] [ASSUMED: preferred test organization]

No edit is expected in `Warp.metal`, `BeautyGeometryEffectPipeline.swift`, public parameters, manifest, comparator, runner, boundary script, or renderer-report schema. [VERIFIED: D-06/D-10/D-15] `CPUReferenceGeometryOracleTests.swift` and `BeautyExampleRendererProcessTests.swift` should be run as compatibility coverage, not edited unless the implementation exposes a real integration regression. [ASSUMED]

After the code passes, update only current-state wording whose owner actually changed: private geometry in `DESIGN.md`, verified owner-local behavior in `PRODUCT_SENSE.md`, recovery/evidence status in `RELIABILITY.md` and `QUALITY_SCORE.md`, the control row in `docs/SDK_EFFECT_TAXONOMY.md`, and the active record in `PLANS.md`. [VERIFIED: `AGENTS.md` routing and 92-CONTEXT integration points] `ARCHITECTURE.md` and `SECURITY.md` need no contract edit if target boundaries and trust boundaries remain unchanged. [ASSUMED]

### Pattern 1: Side-local emission

**What:** call the head helper once for each compact-mapped semantic trace and concatenate results. [VERIFIED: current provider]  
**When:** always for `eyebrowHeadSpacing`, including when the peer is absent or invalid. [VERIFIED: D-03]

```swift
// Planning sketch, not drop-in code. Source basis: current EyebrowWarpProvider.swift.
let traces = semanticTraces(in: face)
return traces.flatMap {
    headSpacingPoints(trace: $0, face: face, strength: strength, maximum: maximum)
}
```

[VERIFIED: existing pattern]

### Pattern 2: Smooth head-zone taper

**What:** use semantic progress and a smooth endpoint-to-zero weight rather than hard-coding a point index. [ASSUMED]  
**When:** producing private head-spacing carriers after trace validation. [ASSUMED]

```swift
// Planning sketch. Coefficients are the Phase 92 implementation hypothesis.
let t = min(max(progress / 0.5, 0), 1)
let weight = 1 - t * t * (3 - 2 * t)
let displacement = axis * (face.bounds.width * 0.065 * strength / maximum * weight)
```

[ASSUMED]

### Pattern 3: Oracle independent of provider intent

**What:** draw deterministic brow-head markers from independently declared fixture regions, render through the public package facade, and derive Q16 movement from final pixel darkness moments. [VERIFIED: Phase 89 comparator pattern and D-12/D-14]  
**When:** the focused mechanics test and final frozen batch gate. [VERIFIED: D-12/D-19]

### Anti-patterns to avoid

- **Raise displacement and keep the two large radii:** likely worsens the already-failing outside RGB budget. [VERIFIED: current outside failure] [ASSUMED: predicted worsening]
- **Move all trace points or reuse `spacingPoints`:** aliases head spacing to whole-brow spacing and violates D-06/D-07/D-13. [VERIFIED: locked decisions]
- **Infer side from screen `x` or use one shared face-horizontal axis:** loses each trace's canonical inner-to-outer direction under pose. [VERIFIED: D-02 and semantic trace model]
- **Require paired support for head spacing:** breaks established per-side eligibility. [VERIFIED: D-03]
- **Mirror, synthesize, or borrow the missing peer:** violates request-local observed-support and fail-closed contracts. [VERIFIED: D-03/D-16]
- **Clamp invalid targets and continue:** obscures malformed geometry and can silently weaken or reverse the signed contract; reject the affected side instead. [ASSUMED: recommended fail-closed behavior]
- **Tune manifest boxes, thresholds, case names, or sibling lists:** invalidates the frozen baseline. [VERIFIED: D-08/D-10/D-11]
- **Prove only provider coordinates:** does not establish actual rendered pixels, metadata, locality, or semantic distinction. [VERIFIED: D-12/D-13]
- **Add a provider-derived renderer aggregate:** creates circular evidence and an unnecessary schema/privacy surface because the brow metric is already pixel-derived. [VERIFIED: D-14/D-15] [ASSUMED: circularity assessment]
- **Persist generated media or detailed geometry:** violates aggregate-only evidence boundaries. [VERIFIED: D-17]

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---|---|---|---|
| Public parameter routing or cap | A new eyebrow API/state field | Existing `eyebrowHeadSpacing` render-state path | The `0.25` cap and dead zone are already established and frozen. [VERIFIED: D-05/D-06] |
| Warp rasterizer | A dedicated brow sampler, Metal kernel, or new backend | Existing CPU geometry pipeline | The shared target-centered inverse sampler already provides deterministic integrated pixels. [VERIFIED: pipeline source and D-06] |
| Semantic image metric | A provider-coordinate or self-reported displacement | Frozen `innerBrowHeadGap` comparator | It observes independent dark markers in final pixels and enforces sibling distinction. [VERIFIED: comparator/manifest] |
| Batch/report schema | A new per-brow renderer payload | Existing aggregate semantic payload | There is no demonstrated production-output binding gap. [VERIFIED: current scripts] [ASSUMED: no bridge needed] |
| Fixture/media store | Saved generated PNGs or live portraits | In-memory deterministic fixture plus temporary runner outputs | The phase permits generated owner-local evidence only and durable aggregates only. [VERIFIED: D-12/D-17/D-19] |
| Missing-side recovery | Mirroring or cached support | Independent compact-map plus fail-closed side rejection | Missing/invalid peers must not contaminate a valid side or a later request. [VERIFIED: D-03/D-16] |

**Key insight:** the hard problem is not emitting a warp point; it is obtaining strong signed centroid motion from a tightly bounded final-pixel field. The existing backend and oracle already solve rasterization and measurement, so Phase 92 should change only the local field geometry. [VERIFIED: current output and architecture] [ASSUMED: design conclusion]

## Common Pitfalls

### Pitfall 1: Mistaking high pixel delta for semantic effectiveness

**What goes wrong:** thousands of target pixels change, but the independently measured brow-head gap moves only a few Q16 units. [VERIFIED: local aggregate report]  
**Why:** broad interpolation around textured markers can create large deltas without moving their darkness centroid enough. [ASSUMED]  
**Avoidance:** require source and neutral target signal, signed Q16 direction, and sibling distinction in the same test. [VERIFIED: manifest contract]  
**Warning:** changed-pixel/RGB gates pass while `source_direction`, `neutral_direction`, or `sibling_alias` fails. [VERIFIED: comparator failure codes]

### Pitfall 2: Bounding sources but forgetting target-centered support

**What goes wrong:** a source lies in the inner zone but positive motion moves its target/radius toward outer regions. [VERIFIED: renderer centers disks on targets]  
**Avoidance:** compute cutoff clearance from the moved target, not only from the source. [ASSUMED]  
**Warning:** outer anchors or outside-target RGB increase only for the positive sign. [ASSUMED]

### Pitfall 3: Sample-count-dependent anatomy

**What goes wrong:** `points[1]` can mean a different physical fraction of the brow for traces of different density. [VERIFIED: current index-based selection and accepted trace-count variability]  
**Avoidance:** cumulative normalized progress with a semantic cutoff. [ASSUMED]

### Pitfall 4: Proving bilateral effect with a one-sided survivor

**What goes wrong:** a valid-side/missing-peer case passes and is incorrectly treated as evidence that the two-head gap changes. [VERIFIED: D-04]  
**Avoidance:** use paired support for the signed Q16 effectiveness gate; use one-sided cases only for eligibility/locality. [VERIFIED: D-04]

### Pitfall 5: State leakage across reused-engine calls

**What goes wrong:** a valid trace or deformation persists through an invalid middle request. [VERIFIED: D-16 identifies this risk]  
**Avoidance:** run `valid → invalid → valid` on the same engine, assert the invalid output is neutral/local as appropriate, and assert first/third bytes and aggregates are identical. [ASSUMED: test pattern consistent with existing lifecycle tests]

### Pitfall 6: Making the generated oracle circular

**What goes wrong:** fixture marker placement or expected motion is derived from provider-emitted targets, so implementation and oracle can be wrong together. [ASSUMED]  
**Avoidance:** independently declare marker rectangles and protected regions, then measure only final pixels. [VERIFIED: D-12/D-14]

### Pitfall 7: Quiet threshold drift after a failed attempt

**What goes wrong:** boxes, siblings, or thresholds are adjusted to make the candidate pass, consuming attempts without preserving Phase 89 meaning. [VERIFIED: D-08/D-10/D-18]  
**Avoidance:** hash/check the unchanged manifest/comparator contract before implementation and use failure aggregates only to choose whether the single remaining attempt is warranted. [ASSUMED]

## Code Examples

### Per-side sign assertion

```swift
// Source pattern: EyebrowWarpProviderTests.swift; exact helper names may differ.
let axis = normalized(trace.outerEndpoint - trace.innerEndpoint)!
let positive = emittedPoint(strength: 0.25, side: trace.side)
let negative = emittedPoint(strength: -0.25, side: trace.side)

XCTAssertGreaterThan(dot(positive.target - positive.source, axis), 0)
XCTAssertLessThan(dot(negative.target - negative.source, axis), 0)
```

[ASSUMED: recommended test code; VERIFIED: sign invariant from D-02]

### Fixed-point darkness centroid

```text
lumaQ8 = 77×R + 150×G + 29×B
darkness = max(0, 255×256 - lumaQ8)
centroidQ16 = sum(pixelCenterQ16 × darkness) / sum(darkness)
innerBrowHeadGap = rightCentroidQ16 - leftCentroidQ16
```

[VERIFIED: `scripts/compare-face-feature-batches.swift:596-685`] The focused SwiftPM test should duplicate this independent integer definition, not call provider geometry to derive the expected centroid. [ASSUMED]

## State of the Art in This Repository

| Previous pattern | Current Phase 92 pattern | Evidence date | Planning impact |
|---|---|---|---|
| Two hard-coded carriers with one fixed radius | Progress-normalized inner-half carriers with displacement and radius taper [ASSUMED] | Proposed 2026-09-06 | Provider-only implementation task plus focused invariants. [ASSUMED] |
| Provider-coordinate/renderability checks | Public-facade 512×512 RGBA8 pixel semantics plus provider invariants | Frozen in Phase 89 [VERIFIED] | Coordinate tests are necessary but insufficient. [VERIFIED] |
| Older eyebrow branch closeout and helper metrics | Phase 89 exact cases, Q16 direction, sibling distinction, and protected budgets | Phase 89 verification [VERIFIED] | Historical passes do not override the current frozen oracle. [VERIFIED: Phase 52 and Phase 89 records] |
| Potential renderer-reported semantic intent | Independently declared dark-marker pixel metric | Frozen in Phase 89 [VERIFIED] | Do not add a report bridge by default. [VERIFIED: D-14/D-15] |

## Validation Architecture

### Test framework

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM; Swift tools `6.0`, local Swift `6.3.3`. [VERIFIED: package/environment] |
| Existing config | `BeautySDK/Package.swift`; no separate test config. [VERIFIED: codebase scan] |
| Quick run | `swift test --package-path BeautySDK --filter 'EyebrowWarpProviderTests|BeautyEngineEyebrowHeadSpacingRepairTests'` [ASSUMED: new test name] |
| Comparator self-test | `swift scripts/compare-face-feature-batches.swift --self-test` [VERIFIED: script interface] |
| Boundary contract | `python3 scripts/test-face-feature-batch-boundaries.py` [VERIFIED: repository command] |

### Phase requirements → test map

| Requirement / contract | Behavior | Test type | Automated command | File exists? |
|---|---|---|---|---|
| BROW-01 direction | Both sides follow/reverse their own inner-to-outer axes; bilateral pixels produce `≥+16` / `≤-16` Q16 | Unit + actual-pixel integration | Quick run, then frozen batch gate | Provider file ✅; focused pixel file ❌ Wave 0 |
| BROW-01 locality | Only inner-half carriers; outer anchors, eyes, background, watermark remain within exact budgets | Unit geometry boundary + pixel comparator | Quick run and frozen batch gate | Partial ✅; focused additions required |
| BROW-01 distinction | Candidate differs from opposite sign and whole-brow `eyebrowSpacing` ± | Actual-pixel sibling comparison | Frozen batch gate | ✅ frozen manifest/comparator |
| D-03 side eligibility | left valid/right invalid and right valid/left invalid emit only the valid side | Provider unit | Quick run | Partial ✅; mixed-invalid cases required |
| D-05 neutral/dead zone | `0`, `±Float.ulpOfOne` emit nothing; allowed values do not alter cap | Provider/facade unit | Quick run | Partial ✅; exact signed cases required |
| D-16 provider empty/no face | no face, missing, malformed-both, or no usable side is neutral/provider-empty | Unit + facade pixel | Quick run | Existing coverage ✅; retain and bind to repair |
| D-16 lifecycle | valid → invalid → valid on reused engine is request-local and deterministic | Integration | Quick run | Pattern ✅; repair-specific case ❌ Wave 0 |
| D-12 metadata | 512×512 extent, explicit sRGB, RGBA8/alpha behavior, deterministic bytes | Actual-pixel integration | Quick run | Oracle patterns ✅; repair-specific case ❌ Wave 0 |
| D-19 package host | Exact case inventory and parameter survive CLI/package host | Process + preflight + batch | compatibility filters and frozen batch gate | Existing ✅ |

### Focused test design

1. **Provider invariants.** Add assertions for `0`, both exact dead-zone endpoints, both signs at `0.25`, both sides' axis-dot direction, decreasing carrier displacement/radius, no carrier at or beyond head progress `0.5`, target unit-space validation, one valid/one invalid side in both orientations, missing/malformed support, and provider-empty behavior. [ASSUMED: test design] Retain existing cap/overflow/no-face/stale/reused tests. [VERIFIED: existing provider suite]
2. **Neutral and first-outside-dead-zone separation.** Exact `±Float.ulpOfOne` must remain empty; a value immediately outside the dead zone may be asserted at provider geometry level, but should not be given an invented pixel-effect threshold because the shared renderer intentionally drops displacements with L1 magnitude `≤0.0001`. [VERIFIED: current dead-zone decision and `RenderableWarpPoint` guard]
3. **Generated public-facade pixel oracle.** Build a deterministic 512×512 explicit-sRGB RGBA8 image in memory with independently declared dark/textured head markers, brow-body/tail sentinels, eye sentinels, background, and alpha variation where applicable. [ASSUMED: focused fixture design] Render source, neutral, head `+0.25`, head `-0.25`, whole-brow spacing `+0.25`, and whole-brow spacing `-0.25` through `BeautyEngine.processResult` with request-local test support. [VERIFIED: facade/SPI pattern; ASSUMED: new test organization]
4. **Use the frozen math locally.** Require source and neutral marker darkness, candidate-vs-source and candidate-vs-neutral target signal `≥500` changed pixels and `≥2,000` RGB delta, signed head-gap magnitude `≥16`, closest sibling difference `≥16`, outside `≤128/512`, outer anchors and eyes `≤64/256` each, and background/watermark `0/0`. [VERIFIED: Phase 89 manifest] Compare outside/protected conservatively against both source and neutral exactly as the comparator does. [VERIFIED: comparator]
5. **One-sided safety.** For left-only, right-only, and valid/invalid-peer requests, require change only in the valid head target and exact identity in the absent/invalid peer target and protected regions; do not apply the bilateral gap threshold. [VERIFIED: D-03/D-04] [ASSUMED: exact focused assertion]
6. **Lifecycle and determinism.** On one reused engine render valid-paired → invalid/malformed → valid-paired; first and third results must match byte-for-byte and fixed aggregates, the middle request must fail closed or affect only its independently valid side, and no private geometry appears in warnings/logs. [ASSUMED: test design consistent with D-16/D-17]
7. **Final authority.** Run the unchanged manifest cases through the existing package-host runner and comparator. Store only the existing fixed aggregate report/digest; clean rendered outputs and renderer reports on success and failure. [VERIFIED: D-10/D-17/D-19]

### Sampling rate and command order

- **Per implementation task:** `swift test --package-path BeautySDK --filter 'EyebrowWarpProviderTests|BeautyEngineEyebrowHeadSpacingRepairTests'`. [ASSUMED]
- **Compatibility gate:** run relevant existing eyebrow facade, missing-landmark, CPU oracle, and renderer-process filters using their discovered test names; do not weaken unrelated failures. [VERIFIED: existing suites] [ASSUMED: filter grouping]
- **Script contract:** `swift scripts/compare-face-feature-batches.swift --self-test`, then `python3 scripts/test-face-feature-batch-boundaries.py`, then `bash scripts/run-face-feature-batches.sh --preflight-only`. [VERIFIED: existing interfaces]
- **Phase gate:** execute the exact eyebrow-head cases through the SDK-owned package-host batch path, require frozen BROW-01 aggregate pass, then run `bash scripts/check-sdk-only-boundary.sh --post-archive`. [VERIFIED: D-10/D-19 and AGENTS]
- **Deferred:** do not run or require live portraits or the milestone-wide `bash scripts/run-no-skip-swiftpm.sh`; Phase 95 owns those. [VERIFIED: D-19]

### Wave 0 gaps

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineEyebrowHeadSpacingRepairTests.swift` — generated 512×512 facade pixel/metadata, both signs, sibling distinction, protection, side eligibility, lifecycle, and determinism. [ASSUMED]
- [ ] Focused mixed valid/invalid peer builders in `EyebrowWarpProviderTests.swift` (preferred) or, only if necessary, `EyebrowSafetyFixtures.swift` / test SPI. [ASSUMED]
- [ ] A test helper mirroring the frozen integer darkness-centroid and region-delta definitions with independently declared rectangles. [ASSUMED]

No test framework installation is needed. [VERIFIED: XCTest already available]

## Environment Availability

| Dependency | Required by | Available | Version | Fallback |
|---|---|---:|---|---|
| Swift toolchain | Build/tests/comparator | ✓ | `6.3.3` | none needed [VERIFIED: environment probe] |
| SwiftPM | SDK build/tests | ✓ | package tools `6.0` | none needed [VERIFIED: package manifest/environment] |
| Python 3 | Boundary tests | ✓ | `3.9.6` | none needed [VERIFIED: environment probe] |
| Node | GSD graph/init tooling only | ✓ | `26.0.0` | direct tool script already worked [VERIFIED: environment probe] |
| Xcode SDK | Apple image/render APIs | ✓ | `26.6` | SwiftPM host remains the prescribed path [VERIFIED: environment probe] |
| Live portraits / device | Not required by Phase 92 | not probed | — | Phase 95 [VERIFIED: D-19] |

**Missing dependencies with no fallback:** none identified. [VERIFIED: environment audit]  
**Missing dependencies with fallback:** none identified. [VERIFIED: environment audit]

## Security Domain

Security enforcement is enabled at ASVS level 1 in `.planning/config.json`. [VERIFIED: project config]

### Applicable ASVS categories

| ASVS Category | Applies | Standard control |
|---|---|---|
| V2 Authentication | No | Owner-local SDK operation has no new authentication surface. [VERIFIED: project boundary] |
| V3 Session Management | No | Request lifecycle is in-process and immutable; no session protocol is introduced. [VERIFIED: architecture] |
| V4 Access Control | Yes, package boundary | Keep geometry private/internal and testing injection under existing SPI; add no public production surface. [VERIFIED: D-06 and architecture owner] |
| V5 Input Validation | Yes | Existing finite/unit-space, face/trace validity, strength cap/dead zone, side identity, and fail-closed guards; add finite progress/clearance checks. [VERIFIED: current provider] [ASSUMED: added private guards] |
| V6 Cryptography | No new control logic | Keep existing SHA-256 aggregate/contract digests; do not invent cryptography for warp behavior. [VERIFIED: comparator] |
| V7 Error/Logging | Yes | Typed/fail-closed results and redacted aggregate-only diagnostics. [VERIFIED: `RELIABILITY.md`, D-17] |
| V8 Data Protection | Yes | Generated/in-memory fixture input, temporary rendered media, durable fixed aggregates only. [VERIFIED: `SECURITY.md`, D-17] |
| V12 Files/Resources | Yes in batch validation | Existing admission, symlink, bounded-size, cleanup, and path-containment checks remain unchanged. [VERIFIED: comparator/runner/boundary tests] |
| V14 Configuration | Yes | Frozen manifest digest, exact case IDs, thresholds, siblings, and inventory checks. [VERIFIED: Phase 89 verification and comparator constants] |

### Known threat patterns

| Pattern | STRIDE | Standard mitigation |
|---|---|---|
| Peer geometry fabrication or borrowing | Tampering | Independently validate/emit each side; no mirroring or cache reuse. [VERIFIED: D-03] |
| Stale request support | Tampering / information disclosure | `valid-invalid-valid` reused-engine test and request-local observations. [VERIFIED: D-16] |
| Oracle weakened to accept candidate | Tampering | Do not modify frozen cases, regions, thresholds, siblings, or comparator digest. [VERIFIED: D-08/D-10] |
| Provider self-report mistaken for output proof | Spoofing | Independently calculate final-pixel dark-centroid and region deltas. [VERIFIED: D-12/D-14] |
| Radius crosses outer/eye support | Tampering | Target-based cutoff clearance plus frozen protected-region gates. [ASSUMED: implementation mitigation; VERIFIED: acceptance gate] |
| Raw/generated media persisted | Information disclosure | Temporary directories and aggregate-only durable evidence; fault-injection cleanup tests. [VERIFIED: D-17 and scripts] |
| Malformed target leaves unit space | Tampering / denial of service | Reject the affected side before `makePoints`; do not clamp semantic targets. [ASSUMED]

## Assumptions Log

| # | Claim | Section | Risk if wrong |
|---|---|---|---|
| A1 | `0.065 × faceWidth` is sufficient endpoint displacement at full strength. | Recommended math | The case can remain below signed Q16 `16`, consuming attempt one. |
| A2 | Inner-half progress and smoothstep complement give enough carriers across accepted trace densities. | Recommended math | Too few changed pixels or unstable shapes may fail the target-signal gate. |
| A3 | Radius `0.020 + 0.025×weight`, capped at half target-to-cutoff clearance, balances `≥500/2,000` target signal with `≤128/512` outside locality. | Recommended math | It may be too narrow for signal or still too broad for locality. |
| A4 | No renderer aggregate bridge is needed because the existing brow pixel oracle closes the production-output binding. | Summary / Don't Hand-Roll | If package-host output bypassed the provider, an additional independent binding test would be required; current routing and pixel effects show it does not. |
| A5 | Mixed valid/invalid peer construction can remain local to provider tests; existing facade SPI cases suffice for production-pixel lifecycle coverage. | Minimal file surface | A tiny test-support fixture addition may be needed, but no production API change. |
| A6 | Rejecting an out-of-unit target or non-positive cutoff clearance for that side is safer than clamping it. | Recommended math / anti-patterns | Fail-closed behavior may reduce availability for an extreme but otherwise accepted trace; clamping would need separate signed-semantics proof. |
| A7 | The proposed one-production-file, focused-test, and current-owner-doc surface is sufficient. | Project structure | An unforeseen integration gap could require a narrow test-support edit, but D-06 still forbids shared backend/public changes. |

These are implementation hypotheses, not locked acceptance facts. The unchanged Phase 89 oracle resolves A1–A4; test compilation resolves A5. [VERIFIED: acceptance design]

## Open Questions

1. **Will the proposed first-attempt coefficients satisfy all frozen budgets simultaneously?**
   - What is known: current target signal is ample, signed motion is 3.2× too small in the weaker positive case, protected groups are zero, and outside RGB is 3.6–4.2× over budget. [VERIFIED: aggregate report]
   - What is uncertain: bilinear resampling and overlapping disks are nonlinear, so coefficient arithmetic cannot prove final Q16/locality results. [VERIFIED: renderer algorithm] [ASSUMED: outcome uncertainty]
   - Recommendation: freeze the formula, execute the focused pixel test and unchanged final oracle once, and use only named aggregate failures to decide whether the one permitted second attempt is justified. [VERIFIED: D-18]

2. **Is a mixed valid/invalid test-SPI case necessary?**
   - What is known: provider tests can construct asymmetric semantic support directly, and facade test support already exposes paired, left-only, right-only, missing, and malformed cases. [VERIFIED: current tests/testing support]
   - What is uncertain: the cleanest compilation boundary for a public-facade mixed case should be decided during Wave 0. [ASSUMED]
   - Recommendation: keep it provider-local unless the facade test cannot cover request-local invalid-peer recovery with existing SPI; if needed, add test support only, never a production API. [ASSUMED]

No open question changes the scope, frozen thresholds, or planning readiness. [VERIFIED: all uncertainties fall under agent discretion]

## Sources

### Primary — HIGH confidence

- `AGENTS.md`, `PLANS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `docs/SDK_EFFECT_TAXONOMY.md` — repository boundaries and contract owners. [VERIFIED: codebase]
- `.planning/phases/92-signed-eyebrow-head-spacing/92-CONTEXT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/PROJECT.md` — scope, BROW-01, locked decisions, attempts, and nonclaims. [VERIFIED: codebase]
- `.planning/phases/89-semantic-validation-baseline/89-VERIFICATION.md`, `scripts/face-feature-batch-manifest.json`, `scripts/compare-face-feature-batches.swift`, `scripts/run-face-feature-batches.sh`, `scripts/test-face-feature-batch-boundaries.py` — frozen actual-pixel oracle and durable-evidence behavior. [VERIFIED: codebase]
- `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift`, `BeautyGeometryEffectPipeline.swift`, eyebrow fixtures/tests, CPU oracle tests, and renderer process tests — current implementation and test seams. [VERIFIED: codebase]
- Phase 49/50 contexts and Phase 52 verification — established seven-control, semantic-trace, per-side, dead-zone, cap, and lifecycle history. [VERIFIED: codebase]
- Latest admitted local aggregate-only face-feature report, read 2026-09-06 — current signed/locality failure measurements. [VERIFIED: local aggregate report; no private locator or media copied]
- `.codex/skills/spike-findings-beauty/SKILL.md` and `references/still-image-integration.md` — generated-fixture, privacy, output-level assertion, and nonclaim rules. [VERIFIED: project skill]

### Secondary — MEDIUM confidence

- None. No external framework research was required because the phase introduces no package or new backend. [VERIFIED: proposed scope]

### Tertiary — LOW confidence

- None. All unverified design hypotheses are explicitly listed in the Assumptions Log. [VERIFIED: this document]

## Metadata

**Confidence breakdown:**
- Current failure: HIGH — exact code and aggregate output agree that the control is active but semantically weak and too diffuse. [VERIFIED]
- Architecture/integration: HIGH — the provider, resolver, rasterizer, package host, and comparator were traced in the live codebase. [VERIFIED]
- Frozen acceptance contract: HIGH — exact cases, signs, regions, thresholds, siblings, and metric were read from Phase 89 artifacts. [VERIFIED]
- Proposed coefficients: MEDIUM — anatomy-bounded and evidence-guided, but final pixel behavior requires execution. [ASSUMED]
- Security/privacy: HIGH — no new dependency, public surface, data source, persistent media, or trust boundary is recommended. [VERIFIED: proposed scope]

**Research date:** 2026-09-06  
**Valid until:** 2026-10-06, or until the provider, Phase 89 manifest/comparator, or Phase 92 context changes. [ASSUMED]

## What Might Have Been Missed

- The knowledge graph was absent, so no graph-derived cross-document relationships were available; direct code and repository-owner tracing was used instead. [VERIFIED: environment audit]
- No Serena tool was available in this agent environment; symbol/reference discovery used direct source reads and `rg`. [VERIFIED: tool inventory]
- No negative capability claim depends on external documentation; the phase is wholly inside the existing repository stack. [VERIFIED: scope]
- Runtime State Inventory is intentionally omitted because this is neither a rename nor a persisted-data/config migration; all affected state is request-local. [VERIFIED: phase boundary and current architecture]
