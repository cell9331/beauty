# Beauty Shaping Branch: Nose

## Business Logic

Nose tools include size, lift, wing slim, root, bridge, and tip.

## Technical Core

- Existing MVP supports nose slim/wing/tip/bridge-like parameters.
- Root/bridge/tip effects require stable nose landmark mapping.
- Effects should degrade to no-op on missing or low-confidence landmarks.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` nose landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge`.
- Future parameter needs: lift, root/bridge split, and additional nose shaping controls.
- Evidence expectation: current provider/resolver evidence is partial; visible completion needs public facade saved-image geometry output.

## Boundary

No internal landmark coordinates in Demo debug UI.
