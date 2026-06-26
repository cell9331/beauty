# Beauty Shaping Branch: Lips

## Business Logic

Lip tools include size, width, vertical position, tilt, horizontal position, M lip, plump lip, smile, and teeth whitening.

## Technical Core

- Existing MVP supports mouth size, mouth width, smile, and lip color.
- M lip and plump lip need upper/lower lip landmark shaping.
- Teeth whitening is region color processing and may belong with `skin-retouch/teeth-hairline`.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` mouth landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `mouthSize`, `mouthWidth`, `smile`, and `lipColor`.
- Future parameter needs: M-lip, vertical position, tilt, horizontal position, and teeth whitening handoff.
- Evidence expectation: lip color has visible color evidence; geometry subtools still need public facade saved-image geometry output.

## Boundary

Do not mix makeup resource placement with geometry controls without a shared mouth-region model.
