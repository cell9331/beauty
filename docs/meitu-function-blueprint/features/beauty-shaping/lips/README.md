# Beauty Shaping Branch: Lips

## Business Logic

Lip tools include size, width, vertical position, tilt, horizontal position, M lip, plump lip, smile, and teeth whitening.

## Technical Core

- The implemented geometry set is `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump`.
- `lipPeakDefinition` and true geometry `lipPlump` use package-internal upper/lower/inner lip support; `lipColor` remains an independent color-domain effect.
- Teeth whitening is region color processing and may belong with `skin-retouch/teeth-hairline`.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` mouth landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, `lipPlump`, and color-only `lipColor`.
- Future parameter need: `白牙` teeth-region segmentation and color-retouch handoff only.
- Implemented subtools: `大小`, `宽度`, and `微笑` through Phases 33-34; Phase 40 promotes exactly `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇` after Phases 38-40 contract, output, safety, privacy, and boundary evidence.
- Branch status remains `partial` solely because `白牙` is future. `lipColor` is visible color evidence only and is not true plump-lip geometry.

## Boundary

Do not mix makeup resource placement with geometry controls without a shared mouth-region model.
