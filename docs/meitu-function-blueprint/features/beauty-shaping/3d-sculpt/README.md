# Beauty Shaping Branch: 3D Sculpt

## Business Logic

`3D塑颜` adjusts perceived 3D face orientation or balance: symmetry, vertical offset, horizontal offset, and tilt.

## Technical Core

- Requires pose-aware face model beyond simple 2D sliders.
- Likely needs roll/yaw-aware control generation and stricter safety caps.
- Status: `blocked-by-geometry-output`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` pose/landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: none.
- Future parameter needs: symmetry, vertical, horizontal, and tilt controls.
- Evidence expectation: public facade detection plus geometry render integration must produce saved example-image output before this branch can be marked `implemented`.

## Boundary

Do not expose 3D mesh or pose internals publicly in the SDK facade.
