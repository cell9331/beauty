# Beauty Shaping Branch: Face Shape

## Business Logic

Face-shape tools include face width, small face, smooth face contour, temple, cheekbone, chin length, double-chin removal, V face, jaw angle, jawline, and hairline.

## Technical Core

- Existing MVP supports parts of face slim, small face, V shape, jaw, and chin.
- Advanced cheekbone, temple, double-chin, and hairline need additional landmarks or segmentation.
- Safety caps must prevent extreme contour collapse.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`.
- Future parameter needs: smooth face, temple, cheekbone, double chin, pointed chin, and hairline.
- Evidence expectation: current provider/resolver evidence is partial; visible completion needs public facade saved-image geometry output.

## Boundary

`Pro` variants are capability labels only until entitlement and algorithm support exist.
