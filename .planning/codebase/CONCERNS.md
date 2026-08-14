# Codebase Concerns

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## Current Technical Debt

### Generic `Sendable` promise

`BeautyResult<Output>` still declares unconditional `@unchecked Sendable`.
Arbitrary non-Sendable payloads can therefore cross concurrency domains without
compiler proof. A versioned conditional conformance or sendable media carrier
plus compile-time Swift 6 fixtures remains the safe remediation.

### Large implementation units

Several detection, geometry, resolver, full-sclera, and testing-support files
remain large and multi-responsibility. Future extraction must preserve package
visibility, the one-detection/one-mapping request flow, and all cross-family
regressions rather than change behavior opportunistically.

### Current versus historical documentation

Root contracts, `docs/README.md`, `docs/SDK_EFFECT_TAXONOMY.md`, and the seven
`.planning/codebase/` maps are current. Milestone/phase evidence and retained
archives are historical. The SDK-only boundary scanner now covers every current
owner/map class and rejects stale application commands or symlinked active trees.

## Security and Privacy Risks

- Images, landmarks, masks, pupils, teeth/eye geometry, and vein patterns are
  biometric-adjacent. They must remain package-only, request-local, non-Codable,
  and absent from durable logs/evidence.
- Licensed/generated image evidence must stay ignored; authorization metadata
  must remain redacted and must not expose local locators.
- Future external resources require trusted origins, schema/version checks,
  cryptographic integrity, bounded install/cache behavior, rollback, and license
  evidence before any runtime path is added.
- The historical ZIPs intentionally include large PNG references. The archive
  verifier pins exact ZIP/manifest digests, 45/26 path inventories, compressed
  and uncompressed totals, per-entry maxima, ratio ceilings, and safe streamed
  extraction. Adjacent mutable records cannot redefine that authority.

## Fragile Areas

### Local-retouch anatomy and composition

Small admission, morphology, blur/reclip, or ownership changes can escape into
lips, iris, pupil, highlight, lash, skin, caruncle, or aperture exterior. Preserve
geometry/color qualification, hard re-clipping, immutable-original composition,
pre-allocation budgets, and collision-to-source behavior.

### Vision mapping and degradation

Orientation, mirroring, semantic side, malformed sibling support, and request
reuse cross detection/mapping/provider boundaries. Normalize/map once, reject at
the smallest region, and never borrow proxy geometry.

### Concurrency and cancellation

The SDK does not yet promise same-engine parallel calls or cooperative
cancellation. Keep mutable request state local, audit unchecked conformances, and
add explicit race/cancellation evidence before widening the contract.

### No-skip transcript accounting

The mandatory child mixes XCTest and Swift Testing output. Its parser must retain
the 16 MiB/200,000-line streaming ceiling, exact one-run aggregates, nonzero
XCTest denominator, all opt-in identities, and rejection of both runners'
skip/disabled events. Transcript text is temporary, not durable evidence.

## Unclaimed Evidence

- Physical-device performance, thermal/endurance behavior, and population
  coverage are not established.
- Realtime landmark/local-retouch routing and GPU execution are absent.
- `去脂` lacks an approved production method and licensed real positive/negative
  evidence; it remains future without proxying existing controls.
- Commercial approval, packaging, distribution, shipping, launch, and release
  readiness remain future scopes.

Historical UI/Demo behavior can be reviewed only after verified restore into a
fresh outside-repository temporary directory. It is not current test coverage,
integration guidance, or a missing active feature.

---
*Concerns audit: 2026-08-14 after Phase 66 review remediation*
