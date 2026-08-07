# Beauty Shaping Branch: Lips

## Business Logic

Lip tools include size, width, vertical position, tilt, horizontal position, M lip, plump lip, smile, and teeth whitening.

## Technical Core

- The implemented geometry set is `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump`.
- `lipPeakDefinition` and true geometry `lipPlump` use package-internal upper/lower/inner lip support; `lipColor` remains an independent color-domain effect.
- Teeth whitening is bounded request-local still-image region color processing; `BeautyEffects` owns the provider/transform and the existing local-retouch composition owner applies it from immutable source pixels.
- Status: `implemented` at SDK-core still-image scope.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` mouth landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, `lipPlump`, and color-only `lipColor`.
- Implemented subtools: `大小`, `宽度`, and `微笑` through Phases 33-34; Phase 40 promotes exactly `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇` after Phases 38-40 contract, output, safety, privacy, and boundary evidence; Phase 61 promotes `白牙` after Phase 59 evidence/admission and Phase 60 provider/integration.
- All exact child rows are implemented, so branch `嘴唇` is `implemented`. The teeth claim is limited to the bounded still-image SDK-core slice with strict public output, adversarial containment, and original-detail review. The Demo remains disabled; realtime/pixel-buffer, population, device/performance, commercial, packaging, shipping, launch, `祛红血丝`, and `去脂` are not implied. `lipColor` remains an independent color effect and is not plump-lip geometry or teeth evidence.

## Boundary

Do not mix makeup resource placement with geometry controls without a shared mouth-region model.
