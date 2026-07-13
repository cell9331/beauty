# Phase 32: Nose Safety, Ledger, and Closeout - Context

**Gathered:** 2026-07-13
**Status:** Ready for planning
**Mode:** Autonomous `--auto`; all locked decisions accepted

<domain>
## Phase Boundary
Lock exact nose semantics, degradation, combined safety, boundaries, exact four-row promotion, and milestone documentation. No new UI/API/dependency/remote/commercial scope.
</domain>

<decisions>
## Implementation Decisions

### Exact semantics
- `noseSlim` and `noseWingSlim` are positive-only with exact cap `0.35`; `noseBridge` is positive-only with exact cap `0.30`.
- `noseTipSize` remains signed with exact cap `±0.30`; both directions must survive normalization, capping, weakening, provider output, and renderer output.

### Degradation
- Missing required nose geometry and stale geometry fail closed: skip nose, zero all four effective strengths, emit category-level warning and aggregate metrics only.
- Reused nose geometry follows the non-eye contract: retain the domain at exact `0.5` scale.
- No-face preserves output extent and allows safe color/filter domains to continue.

### Combined safety and boundaries
- Combined weakening covers all four fields and both tip directions alongside face/eye/mouth geometry.
- Raw geometry, internal imports, new fields/dependencies, network/cloud, commercial paths, and tracked generated artifacts must remain absent.

### Ledger and claims
- Promote exactly `大小`→`noseSlim`, `鼻翼`→`noseWingSlim`, `鼻梁`→`noseBridge`, and `鼻尖`→`noseTipSize`.
- `山根` must not borrow `noseBridge`; `提升` and branch-level `鼻子` remain partial/future.
- Synchronize every current owner and preserve all device/commercial/parity/packaging/launch non-claims.

### the agent's Discretion
- Test names, evidence table formatting, and scan command shapes may follow Phase 30 patterns.
</decisions>

<code_context>
## Existing Code Insights
- Phase 31 already proves 196/196 outputs, 30/30 portrait comparisons, and 6/6 signed tip comparisons.
- Resolver already has exact caps and reuse scaling; it needs explicit zeroing for missing/no-face/stale nose paths.
- Phase 30 eye safety artifacts provide the closest closeout structure.
</code_context>

<specifics>
## Specific Ideas
All NOSE-04 through NOSE-08 and DOC-01 criteria from the milestone objective are locked.
</specifics>

<deferred>
## Deferred Ideas
`山根` alias/parameter design, `提升`, device parity, commercial review, packaging, and launch readiness.
</deferred>
