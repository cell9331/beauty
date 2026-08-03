# Phase 55: Original-Pixel Composition and Failure-Isolation Core - Research

**Researched:** 2026-08-03
**Domain:** Swift package-internal original-RGBA8 pixel composition, ownership sanitization, and smallest-unit failure isolation
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Admission and Package Boundary

- Keep `BeautyEffectResolver.localRetouchAdmission(parameters:)` and
  `BeautyLocalRetouchAdmission.none` exact-empty in production. A closed Phase
  54 decision must not create an inert candidate route.
- Implement only package-internal, feature-neutral composition values and one
  request-local owner. No type or diagnostic may expose teeth, sclera, eyelid,
  mask coordinates, pixels, landmarks, pupils, or owner identities publicly,
  through SPI, Codable, persistence, or logs.
- Wire the core far enough that package tests prove it consumes the same
  `BeautyCanonicalStillImage` carried by `BeautyStillImageRequestContext` and
  cannot be orphaned. Any facade-path activation is opaque/testing-only and
  must remain unreachable from production parameters, presets, Demo, and
  pixel-buffer/reset routes.
- Preserve the shipped no-admission path byte-for-byte and structurally. Local
  composition failure must never suppress unrelated existing face-agnostic
  color/filter work.

### Immutable Original-Pixel and Contribution Contract

- Every accepted local pixel proposal is bound to the immutable canonical
  `rgba8Data` owned by the current request. The composition core reads source
  pixels only from that carrier; it never reads another contribution's output
  or a partially composed frame.
- Each contribution represents one smallest independently rejectable unit and
  carries enough source binding for the core to prove that its proposals refer
  to the current canonical dimensions and original bytes. Exact representation
  is implementation discretion; trust-by-call-order or an unverified second
  raster is not acceptable.
- Validate all dimensions, counts, indices, arithmetic, weights, and source
  bindings before accepting a unit. Structural failure rejects that unit as an
  abstention without throwing away valid siblings. A failure of the canonical
  carrier itself remains a request-level typed failure.
- Keep composition deterministic and order-independent. Use an integer-defined
  RGBA8 blend/rounding contract, preserve canonical alpha, and avoid
  device-dependent color conversion or unordered reduction behavior.

### Hard Containment and Single Ownership

- A contribution distinguishes its hard anatomical envelope from its final
  soft/feathered weight. The composition boundary clamps the weight and
  re-intersects it with the hard envelope after all provider-side growth, blur,
  or feathering; pre-filter containment is never treated as sufficient.
- A valid pixel has zero or one effective owner. A duplicate claim within one
  unit is structurally invalid for that unit rather than silently merged.
- If two or more accepted units claim the same pixel, suppress every local
  proposal at that pixel, copy the canonical source pixel unchanged, and
  increment one aggregate collision-pixel count. Do not select by array order,
  strength, max weight, anatomy, provider priority, or last write.
- Every pixel outside the final owned union remains byte-identical to canonical
  source. A zero-weight proposal is unowned and cannot affect output or counts.

### Smallest-Unit Failure Isolation

- Treat teeth, each sclera eye, and any future eyelid band as independently
  accept-or-abstain units without implementing those named providers in this
  phase.
- A teeth-unit failure removes only teeth work. A left- or right-eye failure
  removes only that eye. A whole-sclera/provider failure is represented by both
  eye units abstaining while unrelated teeth or future eyelid units remain
  unchanged.
- Collision suppression is pixel-local rather than a whole-unit rejection;
  noncolliding pixels from every otherwise valid unit still compose from the
  original source.
- Deterministic failure injection must prove that standalone accepted siblings
  byte-match their portions of fused output and that valid-invalid-valid
  requests retain no prior pixels, claims, masks, or summary state.

### Verification, Privacy, and Nonclaims

- Author Wave 0 tests before implementation for COMP-01 through COMP-05. Use
  tiny opaque mechanics-only canonical rasters and independently authored
  expected byte arrays, not captured output from the system under test.
- Freeze byte-level oracles for standalone, explicitly merged, fused disjoint,
  duplicate-claim, cross-owner collision, outside-union identity, hard
  re-clipping, and teeth/whole-sclera/left-eye/right-eye failure scenarios.
- Keep observations package-only and aggregate-only: accepted/rejected unit
  counts, owned/changed/outside-union/collision pixel counts, and bounded timing
  only where already allowed. Do not expose masks, coordinates, source/output
  pixels, anatomy labels, local paths, or raw errors.
- Treat the Spike 012 whole-frame CPU measurements as mechanics baselines, not
  a performance win or device budget. Phase 55 may choose bounded sparse/ROI or
  dense implementation based on correctness and allocation safety, but claims
  no device, latency, memory, commercial, packaging, shipping, or release result.

### the agent's Discretion

- Choose the smallest dependency-correct file/type layout in `BeautyEffects`
  and the narrowest package wiring in `BeautySDK` that prevents an orphaned
  core without creating a production candidate route.
- Choose the internal hard-envelope/soft-weight/source-binding representation,
  checked allocation ceilings, stable owner token, and exact integer blend
  formula, provided every decision above is mechanically testable.
- Choose opaque test-only scenarios and aggregate counters that prove request
  integration without exposing raw support or anatomy through SPI.

### Deferred Ideas (OUT OF SCOPE)

- Teeth whitening algorithms, mapped-lip candidate growth, public field,
  provider, renderer/output evidence, and promotion belong to Phase 56 only if
  the independent teeth gate later passes; current closed input requires
  complete absence.
- Per-eye sclera scoring/transforms and conditional upper-eyelid work belong to
  Phase 57 only if their independent gates pass; otherwise exact absence is the
  deliverable.
- Combined public-facade output, repeated/parallel/canceled stress, final
  ledgers, and milestone closeout belong to Phase 58.
- Transparent/HDR/gain-map/multi-face policy, realtime/pixel-buffer local
  retouch, Demo UI, models/cloud, tracked media, device/performance budgets,
  packaging, shipping, launch, and release readiness remain outside v1.14.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| COMP-01 | Each anatomical unit fails closed without disabling valid siblings or shipped face-agnostic effects. | Use one opaque contribution per independently rejectable unit, reject malformed units before ownership reduction, and prove sibling byte identity plus facade color continuation. [VERIFIED: `55-CONTEXT.md`, `.planning/REQUIREMENTS.md`] |
| COMP-02 | Every accepted edit derives from immutable original canonical pixels under one request-local owner. | Bind units to the exact canonical storage identity/dimensions and let one request-local composition owner read source bytes and perform the only blend. [VERIFIED: `55-CONTEXT.md`, `BeautyCanonicalStillImage.swift`, Spike 012] |
| COMP-03 | Hard envelopes are re-applied after filtering and all unowned pixels remain byte-identical. | Carry hard containment separately from Q16 soft weight, compute `effectiveWeight = hard ? min(raw, 65_536) : 0`, initialize output from canonical bytes, and write only uniquely owned RGB channels. [VERIFIED: `55-CONTEXT.md`, still-image integration skill] |
| COMP-04 | Unexpected cross-provider overlap is aggregate-counted and preserves source. | Group effective claims by pixel after unit validation; two-or-more distinct owners produce one collision count and no write. [VERIFIED: `55-CONTEXT.md`, Spike 012] |
| COMP-05 | Fused disjoint output matches independent oracles and failure injection preserves unaffected output. | Freeze literal-byte standalone/merge/fused/reversed-order tests plus opaque whole-unit and subunit rejection matrices. [VERIFIED: `55-CONTEXT.md`, Spike 012 self-tests] |
</phase_requirements>

## Summary

The repository already has the correct source boundary: `BeautyCanonicalStillImage` owns immutable, opaque, up-oriented sRGB RGBA8 bytes; `BeautyStillImageRequestContext` carries that exact value on the admitted still-image stack; and `BeautyEngine` has an opaque testing-only admission path while production admission remains exact-empty. `BeautyEffects` is the dependency-correct owner because it already depends downward on `BeautyCore`, while `BeautySDK` alone can connect the composer to the request context without creating a reverse import. [VERIFIED: `BeautyCanonicalStillImage.swift`, `BeautyStillImageRequestContext.swift`, `BeautyEngine.swift`, `Package.swift`]

Implement one feature-neutral `BeautyLocalRetouchCompositionOwner` in `BeautyEffects`. It captures one canonical source, issues opaque request-local unit tokens, validates and normalizes sparse pixel proposals, and performs a stable multiway merge over proposal indices. A unit uses a separate hard-containment bit, unsigned Q16 soft weight, and target RGB; the owner blends once from canonical RGB with an exact integer formula, copies canonical alpha, rejects duplicate claims within a unit, rejects foreign/duplicate unit tokens, and converts cross-unit overlap into source pixels. This is a prescriptive design derived from the locked constraints and avoids a dense per-pixel ownership allocation. [VERIFIED: design derivation from `55-CONTEXT.md`, `55-PATTERNS.md`, and Spike 012]

Wire it only through an opaque composition fixture on the existing testing hooks after `BeautyStillImageRequestContext` creation. The default hook and every production call provide no fixture and therefore pass the original canonical carrier through unchanged; pixel-buffer and `reset()` remain structurally unaware. Core tests own literal byte oracles. Facade-adjacent tests may compute an output digest locally from the already-public returned `CIImage`, while Testing SPI exposes only invocation/source-match flags and aggregate counts—never an output digest or portrait-derived stable identifier. [VERIFIED: design derivation from `BeautyEngineTestingSupport.swift`, `BeautyEngineLocalRetouchFoundationTests.swift`, and locked context]

**Primary recommendation:** Add a sparse, package-only, request-local composition owner in `BeautyEffects`, use exact source identity plus Q16 integer blending and sorted claim reduction, then connect it to the existing admitted still-image branch solely through opaque Testing SPI while leaving all Phase 54 gates and production admission exact-empty. [VERIFIED: synthesis of locked context and live dependency direction]

## Architectural Responsibility Map

| Capability | Primary Tier / Target | Secondary Tier | Rationale |
|---|---|---|---|
| Immutable source identity | `BeautyCore` | `BeautyEffects` | The canonical carrier already owns storage shared by SDK, Detection, and Effects; expose only an exact package-level binding value, not pixels or a new dependency. [VERIFIED: `BeautyCanonicalStillImage.swift`, `Package.swift`] |
| Proposal validation, ownership, integer blend | `BeautyEffects` | `BeautyCore` source carrier | Effects owns transformations and already imports Core; placing the core in SDK would make future providers depend upward. [VERIFIED: `Package.swift`, `ARCHITECTURE.md`, `55-PATTERNS.md`] |
| Request-local lifecycle and facade wiring | `BeautySDK` | `BeautyEffects` | Only the facade can access `BeautyStillImageRequestContext` without a dependency cycle and can guarantee stack-local construction after one canonicalize/detect/map pass. [VERIFIED: `BeautyEngine.swift`, `BeautyStillImageRequestContext.swift`] |
| Opaque mechanics activation | `BeautySDK` Testing SPI | `BeautyEffectsTests` / `BeautyCoreTests` | Existing locked hooks already inject only opaque demand and aggregate observations; raw proposal bytes stay in package tests. [VERIFIED: `BeautyEngineTestingSupport.swift`, `55-CONTEXT.md`] |
| Production admission | `BeautyEffects` resolver | `BeautySDK` guard | Resolver must keep returning `.none`; Phase 55 has no candidate or inert route. [VERIFIED: `BeautyEffectResolver.swift`, Phase 54 decision ledger] |
| Realtime/pixel-buffer/reset | Existing `BeautySDK` path | — | These paths currently create no canonical request context and are explicitly outside the phase. [VERIFIED: `BeautyEngine.swift`, `55-CONTEXT.md`] |

## Project Constraints (from AGENTS.md)

- Read `PLANS.md` before changes; preserve the active plan, leave traceable change/why/verification records, and do not infer repository facts that are not written. [VERIFIED: `AGENTS.md`]
- Code/tests outrank `PLANS.md`, specialist contracts, and historical `docs/`; update the owning root contract when architecture/design/security/reliability/product/quality behavior changes. [VERIFIED: `AGENTS.md`]
- Preserve unrelated edits, do not broaden scope, and record extra issues as debt rather than fixing them opportunistically. [VERIFIED: `AGENTS.md`]
- Apply the `spike-findings-beauty` still-image integration rules: one normalized source, one detection context, request-local support, original-pixel ownership, hard re-clip, collision-to-source, aggregate-only diagnostics, and no realtime/device/product claim. [VERIFIED: `.codex/skills/spike-findings-beauty/SKILL.md`, `references/still-image-integration.md`]
- Swift/Xcode verification must report real environment failures; simulator commands must name an available iOS Simulator explicitly. [VERIFIED: `AGENTS.md`]

## Standard Stack

### Core

| Technology | Version / deployment | Purpose | Why Standard |
|---|---|---|---|
| Swift / SwiftPM | tools 6.0; local Swift 6.3.3 | Package access, checked integer arithmetic, value types, XCTest | Existing package toolchain; no dependency or target change is needed. [VERIFIED: `BeautySDK/Package.swift`, `swift --version`] |
| Foundation `Data` | Apple platform framework | Immutable canonical input and one output byte buffer | Already used by the canonical carrier and supports an exact RGBA8 byte representation. [VERIFIED: `BeautyCanonicalStillImage.swift`] |
| Core Image | Existing Apple framework | Create the canonical CIImage view for the final handoff | Already owned by `BeautyCanonicalStillImage`; composition itself should do no color conversion/filter evaluation. [VERIFIED: `BeautyCanonicalStillImage.swift`] |
| XCTest | Apple toolchain | Literal-byte unit and facade integration oracles | All package targets already use XCTest test targets. [VERIFIED: `Package.swift`, `BeautySDK/Tests`] |

### Supporting

| Component | Version | Purpose | When to Use |
|---|---|---|---|
| Existing Python boundary checker pattern | Python 3.9.6 locally | Mutation-tested public/SPI/scope/dependency/inventory scans | Add in Wave 0 beside the phase artifacts. [VERIFIED: local `python3 --version`, Phase 53 checker] |
| `spike-findings-beauty` Spike 012 source | wrapped 2026-07-30 | Behavioral oracle for original-source, collision, and failure isolation | Use for semantics only; do not copy feature names/transforms/performance claims into production. [VERIFIED: skill source README] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|---|---|---|
| Sorted sparse proposals | Dense full-frame masks/owner arrays | Dense arrays simplify indexing but add allocation proportional to the full 50,000,000-pixel configured ceiling even when work is facially local; sparse sorted claims keep allocations bounded by validated proposals. [VERIFIED: `BeautyConfiguration.swift`, design analysis] |
| One source-owned integer blend | Sequential effect frames | Sequential frames are compact but become order-dependent at unexpected overlap; Spike 012 used them only as a disjoint oracle. [VERIFIED: Spike 012 README] |
| Exact backing identity | Byte digest or dimension-only binding | Digests add full-frame work and dimensions allow an unverified same-sized raster; exact immutable storage identity binds without serialization. [VERIFIED: design analysis from `BeautyCanonicalStillImage.Storage`] |

**Installation:** none. Use only existing Swift/Apple frameworks; no Package.swift target, product, dependency, resource, model, or package install is required. [VERIFIED: recommended architecture and locked scope]

## Package Legitimacy Audit

Not applicable: Phase 55 installs no external package. [VERIFIED: Standard Stack and locked scope]

## Architecture Patterns

### System Architecture Diagram

```text
existing CIImage facade (production admission = empty)
  ├─ empty admission ───────────────────────────────> unchanged legacy render
  └─ opaque Testing demand only
       -> canonicalize once
       -> detect/map once
       -> BeautyStillImageRequestContext
            canonicalImage ───────────────┐
            mapped observation            │
                                          v
                          request-local composition owner
                         /        unit preflight          \
              valid sparse unit   invalid unit -> abstain
                         \        hard re-clip            /
                          sorted pixel ownership reduction
                              ├─ 0 owners -> source
                              ├─ 1 owner  -> integer blend from source
                              └─ 2+ owners -> source + aggregate collision
                                          |
                              canonical-byte-backed result
                                          |
                              existing still render handoff
                                          |
                              output + aggregate-only test evidence

pixel-buffer / reset ---------------------> existing path; no composition owner
```

This flow preserves the current entry and canonicalization/detection boundaries while making composition callable only from the opaque admitted test route. [VERIFIED: design derivation from `BeautyEngine.swift` and `55-CONTEXT.md`]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift       # exact package source binding
├── Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift # opaque units + owner + result
├── Sources/BeautySDK/BeautyEngine.swift                             # narrow test-only orchestration
├── Sources/BeautySDK/BeautyEngineTestingSupport.swift               # opaque fixture/aggregate bridge
├── Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift # literal byte mechanics
└── Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift # facade-adjacent wiring
.planning/phases/55-.../
└── check_phase55_composition_boundaries.py                          # mutation-tested scope/privacy gate
```

No feature provider, renderer case, parameter, CodingKey, preset, Demo file, realtime file, model, or resource belongs in this layout. [VERIFIED: `55-CONTEXT.md`, Phase 54 closed decisions]

### Pattern 1: Exact Source Binding and Request-Local Token Issuance

Add a package-only `BeautyCanonicalPixelSourceBinding` that strongly retains an opaque identity object owned by canonical storage plus width, height, rowBytes, and byteCount. Compare the retained objects with `===`; do not persist their addresses as bare `ObjectIdentifier` values because allocator reuse after deallocation can authorize stale work. The composition owner captures that binding and canonical value; every issued unit strongly retains the request-local owner identity plus a monotonically issued opaque token. A unit from a different owner/source rejects locally even when dimensions and bytes happen to match. Repeating one token in the compose input rejects every occurrence of that duplicated token while unrelated unique units remain eligible. [VERIFIED: post-review implementation and lifetime-churn regression]

Recommended type seam:

```swift
package struct BeautyCanonicalPixelSourceBinding: Equatable, Sendable {
    private let identity: BeautyCanonicalPixelSourceIdentity
    package let width: Int
    package let height: Int
    package let rowBytes: Int
    package let byteCount: Int
}

package struct BeautyLocalPixelProposal: Equatable, Sendable {
    package let pixelIndex: Int
    package let isInsideHardEnvelope: Bool
    package let softWeightQ16: UInt32
    package let targetRed: UInt8
    package let targetGreen: UInt8
    package let targetBlue: UInt8
}

package final class BeautyLocalRetouchCompositionOwner {
    package static let maximumUnitCount = 8
    package init(source: BeautyCanonicalStillImage)
    package func makeUnit(proposals: [BeautyLocalPixelProposal]) -> BeautyLocalRetouchUnit?
    package func compose(_ units: [BeautyLocalRetouchUnit]) throws -> BeautyLocalRetouchCompositionResult
}
```

Use an effective issuance limit of `min(maximumUnitCount, pixelCount)`. Validate empty/effective-empty, over-cap, duplicate-index, index/offset, and hard-envelope proposal structure before consuming any slot or token, so arbitrarily many malformed attempts cannot starve a later valid sibling. The static eight-unit ceiling covers the milestone's five conceptual smallest units (one mouth unit, two eye units, and up to two future eyelid bands) with bounded headroom, while the pixel-count minimum keeps tiny mechanics rasters arithmetically bounded; this is an internal mechanics ceiling, not a public feature inventory or product-capability claim. [VERIFIED: post-review starvation regression and design choice under `55-CONTEXT.md` discretion]

### Pattern 2: Unit-Local Preflight Before Ownership

For each unit, check exact source binding; issued token; claim count `1...max(1, pixelCount / effectiveUnitLimit)`; checked `width * height`, `pixelIndex * 4`, and total byte relations; in-range indices; and duplicate raw indices before filtering zero/outside-envelope claims. Sort proposals by index with a stable deterministic comparator. Any structural failure rejects only that unit. A valid unit with no effective claim after hard re-clip/zero-weight removal also abstains and contributes only to the aggregate rejected count. [VERIFIED: design derivation from checked carrier arithmetic and locked smallest-unit rules]

The `pixelCount / effectiveUnitLimit` per-unit ceiling and `effectiveUnitLimit <= pixelCount` bound total accepted raw claims to at most the canonical pixel count without allocating a dense ownership frame; all multiply/add operations still use reporting-overflow APIs before allocation or indexing. [VERIFIED: arithmetic consequence of the prescribed cap]

### Pattern 3: Post-Filter Hard Re-Clip and Integer RGBA8 Blend

Define `effectiveWeightQ16` only at the composition boundary:

```swift
let weight: UInt32 = proposal.isInsideHardEnvelope
    ? min(proposal.softWeightQ16, 65_536)
    : 0
```

Weight zero is removed before ownership grouping. For the single effective owner of a pixel, blend each RGB channel using an unsigned Q16 denominator and numeric round-half-up, then retain source alpha:

```swift
func blend(source: UInt8, target: UInt8, weightQ16: UInt32) -> UInt8 {
    let w = UInt64(min(weightQ16, 65_536))
    let numerator = UInt64(source) * (65_536 - w)
        + UInt64(target) * w
        + 32_768
    return UInt8(numerator / 65_536)
}
```

This produces exact source at weight 0, exact target at 65,536, deterministic channel bytes at intermediate weights, and no float/CI color conversion in composition. Output starts as canonical `Data`; only RGB offsets of uniquely owned pixels may be written, so alpha and all other bytes stay canonical. [VERIFIED: direct integer arithmetic and locked deterministic/alpha rules]

### Pattern 4: Sorted Multiway Ownership Reduction

After unit preflight, walk the current smallest proposal index across the at-most-eight sorted units. One effective claim blends from canonical. Two or more distinct valid units at the same index increment `collisionPixelCount` exactly once, advance all claim cursors at that index, and make no write. This makes result bytes and aggregates independent of contribution-array order and avoids `Set`/dictionary iteration or a dense owner buffer. [VERIFIED: algorithmic derivation from COMP-02/04 and the fixed unit cap]

The summary contains exactly `acceptedUnitCount`, `rejectedUnitCount`, `ownedPixelCount`, `changedPixelCount`, `changedOutsideUnionPixelCount`, and `collisionPixelCount`. Do not add anatomy counts, token values, coordinates, bytes, source/output digests, raw rejection errors, or descriptions beyond this allowlist; Testing SPI may map these aggregates but must not expose the package units. [VERIFIED: `55-CONTEXT.md` privacy decision]

### Pattern 5: Facade-Adjacent Opaque Wiring

Extend `BeautyLocalRetouchTestingHooks` with an optional opaque composition scenario. Only when that optional test fixture is present, construct the owner from `requestContext.canonicalImage`, ask the hook to populate mechanics units through that same owner's token-issuing `makeUnit` API, call `compose` once, record source-binding match/invocation/aggregate output, and pass its canonical result to the existing canonical render overload. Existing foundation hooks default to no composition fixture and retain the exact Phase 53 `canonicalize, detectAndMap, makeRequestContext, render` trace and same-backing assertions. Production has no hooks and stays on the pre-existing guard/legacy branch. [VERIFIED: design derivation from live hook defaulting and locked no-admission behavior]

Use public Testing SPI only for scenario selection and a redacted result containing dimensions, invocation count, source-binding-matched Boolean, and the six aggregate counts. Literal source/expected/output bytes, pixel positions, and output digests remain inside package/facade tests and never cross SPI. [VERIFIED: existing SPI pattern and locked privacy boundary]

### Anti-Patterns to Avoid

- **Feature enum in the core:** it turns mechanics into a candidate inventory and conflicts with all three closed gates; use opaque units/tokens. [VERIFIED: Phase 54 ledger, `55-CONTEXT.md`]
- **Sequential composition:** it feeds one effect's output to another and creates overlap order semantics; blend only from canonical source. [VERIFIED: Spike 012 README]
- **Max-weight/priority/last-write collision resolution:** it hides corrupt ownership; all competing proposals must be suppressed at that pixel. [VERIFIED: COMP-04]
- **Pre-feather-only clipping:** filtering can expand support; hard containment must be checked on the final weight presented to the composer. [VERIFIED: still-image integration reference]
- **Address-only source identity:** `backingIdentity` remains an `Int` hash solely for older observational tests. Authorization must strongly retain an opaque storage-owned identity and compare it with `===`; neither hashes nor bare `ObjectIdentifier` addresses are lifetime-safe authorization. [VERIFIED: post-review lifetime-churn regression]
- **Dense whole-frame owner arrays:** they allocate by the 50,000,000-pixel input ceiling despite sparse facial work; use bounded sorted proposals. [VERIFIED: `BeautyConfiguration.swift`, design analysis]
- **Shared/static composition owner:** it permits stale masks/claims across requests; construct it after request context creation and release it before facade return. [VERIFIED: SAFE request-local contracts and `55-CONTEXT.md`]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Canonical image normalization | A second decoder, orientation transform, or color render | Existing `BeautyCanonicalStillImage` from the Phase 53 canonicalizer | A second raster breaks exact source binding and single color/orientation ownership. [VERIFIED: Phase 53 verification] |
| Feature admission | Candidate names or inert parameter plumbing | Existing exact-empty `BeautyLocalRetouchAdmission.none` plus Testing hooks | All Phase 54 feature decisions are closed. [VERIFIED: `54-EVIDENCE-DECISIONS.json`] |
| Ownership conflict policy | Priority tables or sequential passes | One sorted collision-to-source reduction | COMP-04 defines the outcome exactly. [VERIFIED: `.planning/REQUIREMENTS.md`] |
| Blend rounding | Float/Core Image filters or platform-dependent conversion | The fixed Q16 integer formula above | COMP-02/05 require byte-level deterministic oracles. [VERIFIED: `55-CONTEXT.md`] |
| Proposal persistence/diagnostics | Codable masks, coordinate lists, debug images, raw errors | Package-only ephemeral units and aggregate summary | Raw portrait-derived support is forbidden from SPI/persistence/logs. [VERIFIED: `SECURITY.md`, `55-CONTEXT.md`] |
| Expected test output | Snapshots generated by production helpers | Literal independently authored RGBA arrays and standalone merge logic | Circular oracles cannot prove integer/source ownership semantics. [VERIFIED: `55-CONTEXT.md`] |

**Key insight:** the hard part is not a color formula; it is maintaining one immutable source and an auditable zero/one/many-owner state for every affected pixel while malformed work fails at unit scope. [VERIFIED: synthesis of COMP-01..05]

## Common Pitfalls

### Pitfall 1: Binding Only Dimensions
**What goes wrong:** A proposal created for another same-sized raster is accepted. **Why:** width/height validate addressability, not source identity. **Avoid:** compare exact canonical storage identity plus dimensions/rowBytes/byteCount. **Warning sign:** a byte-equal independently constructed carrier passes a foreign-unit test. [VERIFIED: source-binding analysis and locked constraint]

### Pitfall 2: Duplicate Detection After Filtering
**What goes wrong:** one unit can claim the same raw pixel twice but escape rejection because one duplicate has zero weight or lies outside the hard envelope. **Why:** sanitization hides malformed structure. **Avoid:** detect duplicate raw indices before re-clip/zero filtering and reject the whole unit. **Warning sign:** duplicate tests vary with claim weights. [VERIFIED: locked duplicate decision]

### Pitfall 3: Collision Count Per Claim
**What goes wrong:** three owners at one pixel increment three times or output depends on iteration. **Why:** claims, not pixels, are being counted. **Avoid:** group all current claims by index and increment once per colliding pixel. **Warning sign:** collision count changes when a third owner is added at the same index. [VERIFIED: COMP-04]

### Pitfall 4: Blending From Mutable Output
**What goes wrong:** reversed unit order changes bytes even when the intended masks are disjoint or collide. **Why:** the destination buffer is read as the next source. **Avoid:** every blend reads `sourceData`; destination is write-only. **Warning sign:** reversed-order oracle differs. [VERIFIED: Spike 012 and COMP-02]

### Pitfall 5: Replacing the Canonical Carrier on Empty/Rejected Work
**What goes wrong:** Phase 53 identity tests and no-admission behavior drift despite no accepted pixel. **Why:** an unnecessary Data/CIImage copy is created. **Avoid:** return the original carrier when no RGB byte changes, while retaining aggregate summary in the result. **Warning sign:** default testing hooks report a new backing identity. [VERIFIED: Phase 53 carrier identity contract and design analysis]

### Pitfall 6: Facade Tests Leak Mechanics
**What goes wrong:** Testing SPI exposes indices, masks, targets, owner tokens, bytes, or a stable digest of portrait-derived output. **Why:** core test fixtures are reused as public SPI DTOs. **Avoid:** facade SPI selects opaque scenarios and returns only dimensions/Booleans/allowlisted counts; keep bytes and locally computed digests inside tests. **Warning sign:** sensitive-term scan finds `pixelIndex`, `mask`, anatomy, or digest fields in the public SPI result. [VERIFIED: locked privacy decision]

### Pitfall 7: Treating Managed-Sandbox Failures as Product Failures
**What goes wrong:** Core Image/CoreVideo host resource failures are misreported as regressions. **Why:** SwiftPM builds but Apple framework initialization is blocked in the managed environment. **Avoid:** preserve raw logs, run pure core/checker tests where possible, and repeat full suites in the known-good host environment. **Warning sign:** widespread `unsupportedPixelFormat` at canonicalizer context initialization or `pixelBufferCreationFailed` without source changes. [VERIFIED: 2026-08-03 local run and Phase 54 verification]

## Code Examples

### Unit Preflight Skeleton

```swift
// Source: repository design derived from 55-CONTEXT.md and
// BeautyCanonicalStillImage.swift checked-arithmetic pattern.
func validatedUnit(_ unit: BeautyLocalRetouchUnit) -> ValidatedUnit? {
    guard unit.sourceBinding == source.pixelSourceBinding,
          issuedTokens.contains(unit.token),
          (1...maximumClaimsPerUnit).contains(unit.proposals.count)
    else { return nil }

    let sorted = unit.proposals.sorted { $0.pixelIndex < $1.pixelIndex }
    for index in sorted.indices {
        let claim = sorted[index]
        guard claim.pixelIndex >= 0, claim.pixelIndex < pixelCount else { return nil }
        let (_, overflow) = claim.pixelIndex.multipliedReportingOverflow(by: 4)
        guard !overflow else { return nil }
        if index > sorted.startIndex,
           sorted[index - 1].pixelIndex == claim.pixelIndex { return nil }
    }
    return ValidatedUnit(/* hard-reclipped nonzero claims */)
}
```

### Collision-to-Source Reduction Skeleton

```swift
// Source: repository design derived from COMP-04 and Spike 012.
while let pixelIndex = smallestCurrentIndex(in: validatedUnits) {
    let claims = currentClaims(at: pixelIndex, in: validatedUnits)
    if claims.count == 1 {
        writeBlend(from: sourceData, claim: claims[0], to: &outputData)
        ownedPixelCount += 1
    } else {
        collisionPixelCount += 1
        // outputData began as sourceData: intentionally do not write.
    }
    advanceAllClaims(at: pixelIndex)
}
```

### Safe Facade Handoff

```swift
// Source: existing BeautyEngine admitted branch plus Phase 55 opaque hook design.
let renderCarrier: BeautyCanonicalStillImage
if let hooks = localRetouchTestingHooks,
   hooks.hasOpaqueCompositionScenario {
    let owner = BeautyLocalRetouchCompositionOwner(
        source: requestContext.canonicalImage
    )
    let units = hooks.makeOpaqueCompositionUnits(using: owner)
    let result = try owner.compose(units)
    hooks.recordComposition(result.summary)
    renderCarrier = result.canonicalImage
} else {
    renderCarrier = requestContext.canonicalImage
}

let output = BeautyColorEffectPipeline.apply(
    to: renderCarrier,
    plan: route.plan,
    selectedFaceObservation: requestContext.selectedFaceObservation
)
```

The implementation should keep error handling package-internal: a valid canonical carrier plus malformed units produces an original/no-local result, while an impossible canonical reconstruction error remains the existing typed request failure. [VERIFIED: locked failure boundary]

## State of the Art

| Old / Spike Approach | Phase 55 Approach | Why It Changes |
|---|---|---|
| Float masks and feature-named teeth/sclera branches in Spike 012 | Opaque unit proposals with Q16 final weights | Phase 55 is feature-neutral and needs exact integer byte oracles. [VERIFIED: Spike 012 source, Phase 54 ledger] |
| Whole-frame CPU loop | Bounded sparse sorted claim merge | Spike 012 validated semantics but measured 2.6–3.1× slower than sparse sequential loops; Phase 55 makes no speed claim. [VERIFIED: Spike 012 README] |
| Sequential local effects | One canonical-source blend with collision suppression | Removes feedback and implicit overlap priority. [VERIFIED: COMP-02/04] |
| Phase 53 exact-empty foundation with no composer | Opaque test-only facade adjacency plus still-empty production admission | Prevents an orphaned core without promoting a closed feature. [VERIFIED: Phase 53/54 verification, `55-CONTEXT.md`] |

**Deprecated/outdated:** feature-named Spike masks/transforms, float blend rounding, sequential ordering as an ownership contract, and the claim that a fused CPU loop is a performance optimization must not enter Phase 55 production documentation. [VERIFIED: still-image integration skill and Spike 012]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| — | None. The implementation choices above are within the explicitly delegated agent discretion; all repository-state claims were checked against current code/artifacts. | — | — |

## Open Questions

None block planning. The exact future feature algorithms and public activation remain intentionally closed/deferred; Phase 55 should implement only the prescribed mechanics contract. [VERIFIED: Phase 54 decisions and `55-CONTEXT.md`]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift / SwiftPM | Package build/tests | ✓ | Swift 6.3.3 | — [VERIFIED: local CLI] |
| Xcode toolchain | Apple framework compilation | ✓ | Xcode 26.6 (17F113) | — [VERIFIED: local CLI] |
| Python 3 | Boundary checker | ✓ | 3.9.6 | — [VERIFIED: local CLI] |
| Core Image/CoreVideo runtime access under managed sandbox | Existing facade tests | ✗ for this session | Framework initialization blocked | Run pure composition/checker gates here; preserve logs and repeat facade/full suite in known-good host execution. [VERIFIED: local focused run and Phase 54 verification] |

**Missing dependencies with no fallback:** none; the framework issue is execution-environment access, not a missing SDK/toolchain. [VERIFIED: build completed before runtime failures]

**Missing dependencies with fallback:** facade/full SwiftPM verification must use the previously working host context if managed sandbox initialization continues to fail. [VERIFIED: Phase 54 recorded 500 passing SwiftPM tests and documented the same managed-environment limitation]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM, Swift tools 6.0 [VERIFIED: `Package.swift`] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: codebase] |
| Quick run command | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --disable-sandbox --package-path BeautySDK --filter BeautyLocalRetouchCompositionTests` |
| Facade run command | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --disable-sandbox --package-path BeautySDK --filter 'BeautyEngineLocalRetouchCompositionTests|BeautyEngineLocalRetouchFoundationTests'` |
| Full suite command | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --disable-sandbox --package-path BeautySDK` |
| Boundary commands | `python3 .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py --self-test` then the same command without `--self-test` |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| COMP-01 | Invalid unit, whole conceptual region, and individual subunit abstention preserve every valid sibling; invalid local work preserves brightness/filter output; valid-invalid-valid retains nothing. | unit + facade integration | quick + facade commands | ❌ Wave 0 |
| COMP-02 | Foreign byte-equal carrier rejects; exact carrier copy accepts; standalone/fused/reversed unit order use only original bytes; alpha unchanged. | unit | quick command | ❌ Wave 0 |
| COMP-03 | Hard-false/nonzero weight and zero weight are unowned; outside-union bytes equal literals; checked count/index/offset caps reject locally. | unit + mutation checker | quick + checker commands | ❌ Wave 0 |
| COMP-04 | Duplicate raw index rejects only its unit; duplicate token rejects all copies only; 2/3-owner same-pixel collision counts once and stays source; noncolliding sibling pixels compose. | unit | quick command | ❌ Wave 0 |
| COMP-05 | Literal standalone, independent merge, fused and reversed-order arrays match; teeth/whole-sclera/left/right conceptual failure matrix byte-matches unaffected oracle. | unit | quick command | ❌ Wave 0 |

### Required Byte-Oracle Matrix

| Case | Required assertion |
|---|---|
| Q16 endpoints and midpoint | Literal bytes for weight `0`, `32_768`, `65_536`, and oversized `UInt32.max` clamp; alpha exact. [VERIFIED: prescribed formula] |
| Standalone A/B/C | Each unit output equals a literal expected RGBA array independently. [VERIFIED: COMP-05] |
| Explicit merge | Test-authored merge of standalone literal arrays equals fused output; production blend helper is not called by oracle. [VERIFIED: `55-CONTEXT.md`] |
| Reversed order | All permutations of three disjoint units produce same bytes and summary. [VERIFIED: COMP-02/05] |
| Hard re-clip | Hard-false/soft-positive pixel remains source, not owned, not collision-counted. [VERIFIED: COMP-03] |
| Duplicate claim | Two raw entries at one index reject that unit even if one is zero/outside; valid sibling unchanged. [VERIFIED: locked duplicate rule] |
| Duplicate token | Same unit supplied twice rejects both occurrences; unrelated unit remains. [VERIFIED: prescribed stable-token semantics] |
| Collision | Two then three owners at one index each produce exactly one collision count/source byte; adjacent unique claims still blend. [VERIFIED: COMP-04] |
| Source mismatch | Unit made from distinct same-size/same-byte canonical carrier rejects; output uses current source. [VERIFIED: COMP-02 source binding] |
| Failure injection | Opaque A rejection, B+C rejection, B-only rejection, C-only rejection map to teeth/whole-sclera/left/right requirement scenarios without production anatomy types. [VERIFIED: COMP-01/05] |
| Request recovery | valid-invalid-valid facade calls yield first/third scenario-specific digests computed locally by the test from public results, with zero retained owner/claims/summary between calls and no digest crossing Testing SPI. [VERIFIED: `55-CONTEXT.md`] |
| Compatibility | production admission count/names exact zero; 59 fields, five presets, 72 renderer cases, no-admission bytes/warnings/metrics/summary unchanged; pixel-buffer/reset composition count zero. [VERIFIED: Phase 53 closeout contracts] |

### Sampling Rate

- **Per task commit:** quick composition suite plus checker live mode. [VERIFIED: recommended narrow gate]
- **Per facade-wiring commit:** quick + facade suite + Phase 53 foundation tests. [VERIFIED: impacted seam]
- **Per wave merge:** named compatibility suites (`BeautyParametersTests`, `BeautyResourceCatalogTests`, `BeautyRendererOutputRegressionTests`) plus checker self/live. [VERIFIED: Phase 53 compatibility owners]
- **Phase gate:** full SwiftPM suite green in a framework-capable environment, checker self/live green, `git diff --check`, and exact source/public/SPI/candidate scans green before verification. [VERIFIED: repository workflow and environment limitation]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift` — literal mechanics coverage for COMP-01..05.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift` — same-canonical opaque facade wiring, unrelated-effect continuation, recovery, and non-route coverage.
- [ ] `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py` — mutation-tested scope/privacy/arithmetic/orphan/compatibility gate.
- [ ] Testing SPI opaque fixture/result additions — no raw proposal or anatomy surface.

The current 2026-08-03 focused baseline built but failed at host Core Image/CoreVideo resource initialization (`unsupportedPixelFormat` at canonicalizer context setup and `pixelBufferCreationFailed`), matching the managed-environment limitation documented by Phase 54; do not label those failures Phase 55 RED or code regressions. [VERIFIED: local command output and `54-VERIFICATION.md`]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | No identity/authentication surface in package-local image mechanics. [VERIFIED: phase boundary] |
| V3 Session Management | no | Request-local owner is an in-process lifetime boundary, not a user session. [VERIFIED: phase boundary] |
| V4 Access Control | yes, package boundary | `package` production types; no public/SPI unit, binding, byte, mask, or owner surface. [VERIFIED: locked privacy rules] |
| V5 Input Validation | yes | Exact source binding; checked dimensions/counts/offsets; eight-unit and per-unit claim caps; duplicate/token/index validation; Q16 clamping; hard re-clip. [VERIFIED: prescribed architecture] |
| V6 Cryptography | no | No persistence/network/authenticity requirement; do not add hashing as an identity substitute. [VERIFIED: phase boundary] |
| V7 Error/Logging | yes | Existing typed payload-free canonical error; malformed units abstain; only allowlisted aggregate counts cross test observation. [VERIFIED: `SECURITY.md`, `RELIABILITY.md`, `55-CONTEXT.md`] |
| V12 File/Resource | no new file input | Composition consumes the already validated canonical carrier only. [VERIFIED: Phase 53 boundary] |

### Known Threat Patterns for the Swift Composition Core

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Same-sized or byte-equal foreign raster is presented as current source | Spoofing/Tampering | Exact immutable storage binding and request-owner identity; foreign unit abstains. [VERIFIED: COMP-02 design] |
| Overflowed pixel count/offset or excessive proposal allocation | Denial of Service/Tampering | Reporting-overflow arithmetic, exact canonical byte relations, effective unit limit `min(8, pixelCount)`, max `pixelCount/effectiveUnitLimit` raw claims per unit, sparse merge, one output Data allocation. [VERIFIED: prescribed caps] |
| Duplicate claims/tokens smuggle order-dependent ownership | Tampering | Raw duplicate index rejection; duplicate token frequency rejects every duplicate; grouping by pixel independent of array order. [VERIFIED: locked duplicate/order rules] |
| Cross-unit overlap receives hidden priority | Tampering | Suppress all claims at that pixel, preserve source, increment one aggregate pixel count. [VERIFIED: COMP-04] |
| Masks/indices/owner IDs/source bytes leak through SPI/logs | Information Disclosure | Package-only non-Codable types; opaque Testing SPI; exact sensitive-term/source scan; aggregate allowlist only. [VERIFIED: SAFE policy and locked Phase 55 privacy] |
| Stale owner survives repeated/canceled/reset requests | Information Disclosure/Tampering | Construct owner after request context on the stack, retain nothing on engine, valid-invalid-valid/realtime/reset zero-work tests. [VERIFIED: request-local architecture] |
| Local failure suppresses shipped color/filter work | Denial of Service | Convert malformed units to local abstention and continue the existing render plan; facade digest comparison. [VERIFIED: COMP-01 and locked safe-domain continuation] |

### Boundary Checker Requirements

The checker must fail closed if the composition source/test files are absent, and mutation self-tests must cover: public/SPI/Codable sensitive surface; candidate names/providers/renderers/fields/presets; nonempty admission; Demo/pixel-buffer/reset activation; new targets/dependencies/models/network/persistence; missing checked arithmetic; missing hard re-clip; missing collision-to-source; missing facade reference; missing byte/failure/recovery tests; and drift in 59 fields/five presets/72 renderer cases. [VERIFIED: Phase 53 checker pattern and `55-PATTERNS.md`]

## Explicit Nonclaims

- No teeth, sclera, or upper-eyelid provider, transform, parameter, renderer case, preset, visible output, eligibility, effectiveness, naturalness, or branch promotion is implemented or evidenced. [VERIFIED: Phase 54 closed ledger]
- No public/SPI local-retouch API, mask/geometry support, output helper, Demo/UI, realtime/pixel-buffer, multi-face, transparent/HDR/gain-map, model/cloud, or tracked-media behavior is added. [VERIFIED: `55-CONTEXT.md`]
- Mechanics fixtures and literal rasters prove only composition invariants; they provide zero product/naturalness weight. [VERIFIED: EVID-02 and Phase 54 verification]
- Spike 012 CPU time/RSS values are baselines only; sparse composition is chosen for bounded correctness and no device latency, memory, throughput, performance-win, commercial, packaging, shipping, launch, or release claim follows. [VERIFIED: Spike 012 README]
- Same-engine parallelism, cancellation, and final repeated/parallel/canceled stress remain Phase 58/TD-013 work; do not mark them passed here. [VERIFIED: `55-CONTEXT.md`, Phase 53 foundation tests]

## Sources

### Primary (HIGH confidence)

- `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/55-CONTEXT.md` — locked scope, ownership, failure, privacy, verification, and nonclaim decisions. [VERIFIED: repository]
- `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md` — COMP-01..05 and Phase 55 success criteria. [VERIFIED: repository]
- `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift` — immutable RGBA8 storage and checked byte contract. [VERIFIED: codebase]
- `BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift`, `BeautyEngine.swift`, and `BeautyEngineTestingSupport.swift` — live request-local/facade/testing seams. [VERIFIED: codebase]
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift`, `BeautyEffectResolver.swift`, and `Package.swift` — exact-empty production admission and dependency direction. [VERIFIED: codebase]
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md` and `sources/012-guarded-local-retouch-composition/README.md` — original-source, hard-reclip, collision, failure-isolation mechanics and performance nonclaims. [VERIFIED: project skill sources]
- `.planning/phases/53-.../53-VERIFICATION.md` and `.planning/phases/54-.../54-VERIFICATION.md` — completed foundation/closed eligibility gates and current regression evidence. [VERIFIED: repository]

### Secondary (MEDIUM confidence)

- `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/55-PATTERNS.md` — current code analog mapping and recommended file seams. [VERIFIED: codebase pattern analysis]
- Root `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `PLANS.md` — current owner contracts and active milestone state. [VERIFIED: repository]

### Tertiary (LOW confidence)

- None. No web-only or training-knowledge claim is used. [VERIFIED: research log]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — existing Swift package and Apple frameworks only; local tool versions checked. [VERIFIED: codebase and CLI]
- Architecture: HIGH — dependency direction and facade/request seams are live; choices are constrained by exact locked decisions and Spike 012. [VERIFIED: codebase, context, skill]
- Pitfalls: HIGH — each follows from executable prior spike behavior, current carrier/wiring, or explicit requirement semantics. [VERIFIED: cited repository sources]
- Validation: HIGH — existing XCTest/checker patterns are live; only the new Wave 0 files are absent. [VERIFIED: `Package.swift`, Phase 53/54 artifacts]

**Research date:** 2026-08-03
**Valid until:** 2026-09-02 (stable internal Swift/package design; re-research if Phase 54 eligibility, package targets, canonical carrier, or admission changes)
