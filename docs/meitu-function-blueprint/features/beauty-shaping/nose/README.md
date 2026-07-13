# Beauty Shaping Branch: Nose

## Business Logic

Nose tools include size, lift, wing slim, root, bridge, and tip.

## Technical Core

- Existing MVP supports nose slim/wing/tip/bridge-like parameters.
- Root/bridge/tip effects require stable nose landmark mapping.
- Missing or stale nose geometry fails closed by skipping the nose domain and zeroing all four effective strengths; reused non-eye geometry retains the domain at `0.5` scale.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` nose landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge`.
- Future parameter needs: lift, root/bridge split, and additional nose shaping controls.
- Evidence: Phase 31 proves 196/196 outputs, 30/30 portrait comparisons, and both signed `noseTipSize` directions through the public facade. Phase 32 proves exact caps, degradation, combined weakening, and boundary containment.
- Implemented rows: `大小` → `noseSlim`, `鼻翼` → `noseWingSlim`, `鼻梁` → `noseBridge`, and `鼻尖` → signed `noseTipSize`.
- `山根` remains partial and does not borrow `noseBridge`; `提升` remains future. Branch-level `鼻子` remains `partial`.

## Boundary

No internal landmark coordinates in Demo debug UI.
