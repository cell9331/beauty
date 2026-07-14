# Beauty Shaping Branch: Nose

## Business Logic

Nose tools include size, lift, wing slim, root, bridge, and tip.

## Technical Core

- Current SDK-core support is exactly six independent fields: `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, and `noseTipLift`.
- Missing/no-face/stale aggregate nose geometry zeros all six; reused eligible non-eye geometry applies exact `0.5`; field-specific missing/provider-empty work is removed independently while supported siblings may continue.
- Status: `implemented` for the exact six-row SDK-core branch.
- Primary owner: `BeautyEffects`.
- Dependencies: package-internal `BeautyDetection` nose/root/tip supports and `BeautyRender` unified warp output; no raw geometry crosses the public facade.
- Evidence: Phases 31-32 prove the four legacy rows; Phase 35 proves independent root/tip contracts and provider paths; Phase 36 proves 252/252 public-facade output with separate baseline/non-alias comparisons; Phase 37 proves final exact `0.25` caps, exhaustive six-field degradation/transitions, exactly-once convergence, redaction, and active-source boundaries.
- Implemented rows: `大小` → `noseSlim`, `提升` → `noseTipLift`, `鼻翼` → `noseWingSlim`, `山根` → `noseRootNarrowing`, `鼻梁` → `noseBridge`, `鼻尖` → signed `noseTipSize`.
- `山根` does not borrow `noseBridge`, and `提升` does not borrow signed `noseTipSize`. Branch completion is SDK-core only and does not claim Demo/device/commercial/packaging/launch readiness.

## Boundary

No internal landmark coordinates in Demo debug UI.
