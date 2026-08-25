# Codebase Concerns

**Analysis Date:** 2026-08-18
**Boundary:** SDK-only SwiftPM repository
**Policy Sync:** 2026-08-25

**Distribution:** Owner-only and non-distributed. Any commercialization,
third-party use, package publication, or model/weight transfer would be a new
project risk requiring a full license/security/privacy/product audit.

## Current Technical Debt

### Post-archive CPU/GPU contract boundaries

The v1.17 archive is historical rather than current broad-parity authority.
Current contracts intentionally keep local-retouch composition on CPU before
identity Metal transport, reject non-opaque/unsupported RGB `.gpu` still images,
materialize named-sRGB output, align Metal still-image coefficients/lip math to
the CPU oracle, and require callers to serialize each non-`Sendable` engine.
Backend-result alpha/extent publication fails closed; geometry safety provenance
derives the envelope and request from one immutable observation with mutation-
tested ownership. Unavailable hosts report `parity_executed=0` and never receive
GPU parity credit. Transparent input, end-to-end GPU local-retouch ownership,
and shared-instance parallel safety remain explicit nonclaims, not open defects.

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

The SDK explicitly requires caller serialization for same-engine calls and does
not promise cooperative cancellation. Keep mutable request state local, reject
`BeautyEngine` sendability drift, and require separately authorized evidence
before widening the contract.

### No-skip transcript accounting

The mandatory child mixes XCTest and Swift Testing output. Its parser must retain
the 16 MiB/200,000-line streaming ceiling, exact one-run aggregates, nonzero
XCTest denominator, all opt-in identities, and rejection of both runners'
skip/disabled events. Transcript text is temporary, not durable evidence.

## Unclaimed Evidence

- Physical-device performance, thermal/endurance behavior, and population
  coverage are not established.
- Realtime landmark/local-retouch routing remains absent. Selectable GPU
  execution exists for the bounded SDK path, but local-retouch computation is
  not end-to-end GPU-owned and shared-instance parallel use is unsupported.
- `去脂` lacks an approved owner-local method, exact-target training data, and licensed real positive/negative
  evidence; it remains future without proxying existing controls.
- Commercial approval, packaging, distribution, shipping, launch, and release
  readiness are prohibited by the owner-only contract unless explicitly reopened.

Historical UI/Demo behavior can be reviewed only after verified restore into a
fresh outside-repository temporary directory. It is not current test coverage,
integration guidance, or a missing active feature.

---
*Concerns audit: 2026-08-17 during v1.17 post-archive audit remediation*
