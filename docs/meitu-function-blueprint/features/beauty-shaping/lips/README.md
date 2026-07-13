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
- Implemented subtools: `大小` (`mouthSize`), `宽度` (`mouthWidth`), and `微笑` (`smile`) through Phase 33 facade output and Phase 34 safety/degradation evidence.
- Branch status remains `partial`: `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and `白牙` are unresolved. `lipColor` is visible color evidence only and is not true plump-lip geometry.

## Boundary

Do not mix makeup resource placement with geometry controls without a shared mouth-region model.
