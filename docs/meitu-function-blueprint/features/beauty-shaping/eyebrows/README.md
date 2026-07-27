# Beauty Shaping Branch: Eyebrows

## Business Logic

Eyebrow tools include vertical position, thickness, length, spacing, inner spacing, tilt, and arch/peak.

## Technical Core

- Status: `implemented` at SDK-core scope.
- Primary owner: `BeautyEffects`, dispatched through the existing `BeautyRender` unified warp.
- Dependencies: package-internal, request-scoped left/right eyebrow traces copied from the existing selected-face Apple Vision request; no resource pack or remote model.
- Current public `BeautyParameters` coverage: signed `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, and `eyebrowTilt`, plus positive-only `eyebrowPeakDefinition`.
- Exact branch scope: `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`.
- Future parameter needs: none for this exact seven-row taxonomy; any additional eyebrow capability requires separate design and evidence.
- Evidence expectation: SDK behavior, public-facade output, exact safety/degradation, and privacy/boundary gates must all remain green.

## Phase 52 Evidence

Phase 49 established the seven-field public contract and validated actual
request-scoped observed eyebrow support. Phase 50 added seven independent named
providers, exact resolver/convergence accounting, and unified dispatch. Phase
51 accepted thirteen isolated public-facade outputs through fixed
direction/locality/distinction gates. Phase 52 freezes exact final caps,
dead-zone and lifecycle behavior, complete 44-field convergence, aggregate-only
diagnostics, privacy/artifact boundaries, and the evidence-gated seven-row
promotion.

Together these phases implement the complete seven-row `眉毛` branch at
SDK-core scope. The status does not claim SwiftUI or Demo UI, physical-device
parity, commercial naturalness, optimized performance, packaging, shipping,
launch readiness, an independent milestone audit, archive, tag, or cleanup.

## Boundary

No eyebrow makeup asset schema, texture synthesis, generated hair, public raw
landmarks/control points, persistence, or network/cloud processing is implied.
The v1.14-v1.16 retouch, hairline, and double-chin scopes remain future.
