# Beauty Shaping Branch: Proportion

## Business Logic

Proportion tools adjust perceived head/face ratios: small head, head-to-face ratio, crown, forehead, mid-face, philtrum, lower face, short face.

## Technical Core

- Needs facial region anchors and vertical ratio controls.
- Some controls can map to existing chin/face parameters; full coverage likely needs new parameter fields.
- Effects must be softened when combined with face-shape tools.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `faceSmall` covers small-head style behavior indirectly.
- Future parameter needs: forehead, mid-face, philtrum, lower-face, short-face, and head-face controls.
- Evidence expectation: current provider/resolver evidence is partial; visible completion needs public facade saved-image geometry output.

## Boundary

No body/head segmentation assumptions without a detection design.
