# Feature Research

**Domain:** Modular iOS beauty SDK with rich Demo app
**Researched:** 2026-06-10
**Confidence:** HIGH for repo-defined MVP; MEDIUM for broader Meitu/Xingtu-class expansion

## Feature Landscape

### Table Stakes (Users Expect These)

Features host-app developers, product designers, and QA will expect before the SDK feels real.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Public SDK facade | Host apps should not import implementation targets | MEDIUM | `BeautyEngine`, configuration, parameters, result, and typed errors. |
| Modular package targets | User explicitly wants SDK modules | MEDIUM | Core, Detection, Render, Effects, Resources, facade. |
| Default no-op processing | First integration must prove safe input/output | MEDIUM | Same visual output within tolerance, useful for tests. |
| Realtime camera preview path | Beauty SDKs are judged by live preview | HIGH | Requires AVFoundation, pixel buffers, Metal, frame dropping, permission states. |
| Still-image processing path | Meitu/Xingtu-style apps need photo editing | HIGH | Requires orientation correctness, quality mode, loading/error UI. |
| Parameter model and normalization | Demo sliders must map to stable SDK values | MEDIUM | Existing design contract lists 31 fields for 1.0. |
| Presets | Users expect one-tap natural/refined looks | MEDIUM | Preset JSON/versioning and slider sync. |
| Skin beauty | Basic beauty effect users notice first | HIGH | Smoothing, whitening, rosy, sharpen with natural caps. |
| Face-shape controls | Core beauty expectation | HIGH | Slim face, small face, V shape, chin; depends on landmarks and warp. |
| Eyes/nose/mouth controls | Core fine-tuning expectation | HIGH | Eye size/distance/tail, nose slim/bridge, smile/lip. |
| Filters and color | Photo/video style control | MEDIUM | Brightness, contrast, saturation, temperature, LUT/filter ID. |
| Compare/reset behavior | Editing app UX expectation | LOW/MEDIUM | Before/after compare, reset single parameter, reset all. |
| Diagnostics/degradation | SDK integrators need stable failures | MEDIUM | No-face, missing-resource, invalid input, low-performance modes. |
| Tests | Required to trust modular SDK | MEDIUM | Value models, facade import, no-op processing, preset validation, UI mappings. |

### Differentiators (Competitive Advantage)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Rich Demo that feels like a real editor | Makes SDK capability easy to evaluate | MEDIUM/HIGH | Bottom tabs for beauty, face, features, makeup, filters, stickers, background, style. |
| Naturalness safety caps | Prevents fake/plastic results | HIGH | Product invariant, not just UI preference. |
| Resource manifest validation | Enables scalable presets/LUTs/makeup without unsafe loading | MEDIUM | Belongs in `BeautyResources`. |
| Multi-face policy | Supports group photos and camera scenes | HIGH | Main-face strategy, per-face params later. |
| Makeup modules | Moves toward full Meitu/Xingtu-class capability | HIGH | Requires resource geometry, blending, face pose, color matching. |
| Background/person segmentation | Adds portrait-editor features | HIGH | Depends on Vision segmentation and mask refinement. |
| Parameter import/export | Useful for QA, designers, and presets | LOW/MEDIUM | Must be validated and schema-versioned. |
| Video export | Commercial SDK expansion path | HIGH | Needs orientation, audio, progress, cancellation, performance. |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| All beauty features in phase one | Looks like faster progress | Delays foundation, hides integration and performance risks | Stage foundation and MVP effects first. |
| Direct Demo access to internal modules | Easier during development | Breaks SDK facade realism and host-app contract | Add public facade APIs for needed capability. |
| Cloud-based face/photo processing by default | May seem easier for advanced AI effects | Violates local-first privacy posture and adds network/compliance risk | On-device first; explicit future opt-in only. |
| Vendor beauty SDK wrapper as core | Fast visual demo | Product becomes integration shell, not reusable internal SDK | Use Apple frameworks/local pipeline unless explicitly approved. |
| Hidden auto-enhancement without visible state | Makes screenshots look better | Users and QA cannot reason about output | Every visible effect maps to parameters or documented presets. |

## Feature Dependencies

```text
Swift Package + Facade
    -> Value Models + Validation
        -> No-op Processing
            -> Demo Facade Wiring
                -> Camera Path + Still Image Path
                    -> Detection + Coordinates
                        -> RenderGraph + Resource Loading
                            -> Filters + Skin
                                -> Face/Eyes/Nose/Mouth
                                    -> Presets + Rich Demo UX
                                        -> Makeup / Segmentation / Body / Video
```

### Dependency Notes

- **Realtime camera requires no-op processing first:** The pipeline should prove safe frame movement before effects mutate pixels.
- **Geometry effects require detection and coordinate mapping:** Face, eye, nose, mouth, and multi-face work depend on reliable landmarks.
- **Presets require parameter validation:** Presets are only safe when the model clamps or rejects invalid values.
- **Makeup requires resources and landmarks:** Makeup should not start until resource manifests and face-space mapping exist.
- **Background features require segmentation:** Background blur/replacement is a separate mask pipeline, not a color filter.

## MVP Definition

### Launch With (v1)

Minimum SDK milestone that validates the product direction.

- [ ] `BeautySDK` package with public facade and internal targets — proves modular SDK shape.
- [ ] No-op `BeautyEngine` process path for frames/images — proves input/output safety.
- [ ] `BeautyParameters` 1.0 with skin, color, face, eyes, nose, mouth, filter domains — provides controllable API.
- [ ] Built-in presets: natural, clear, refined, male natural, ID photo natural — proves one-tap flow.
- [ ] Realtime camera and still-image Demo paths — proves host app integration and user-facing feedback.
- [ ] Basic filters/color and core skin controls — first visible effects with lower algorithm risk.
- [ ] Detection/coordinate foundation and first geometry effects — unlocks face/eyes/nose/mouth MVP.
- [ ] Tests and diagnostics for validation, no-face, invalid input, and missing resources — prevents demo-only success.

### Add After Validation (v1.x)

- [ ] More fine-grained eye/nose/mouth controls — add after landmark/warp quality is verified.
- [ ] Advanced skin repair such as blemish, dark circles, wrinkles — add after segmentation/masking quality improves.
- [ ] Makeup templates and local makeup components — add after resources and face attachment are stable.
- [ ] Multi-face individual tuning — add after single-face pipeline and tracking are stable.
- [ ] LUT pack expansion and custom preset import/export — add after resource validation is hardened.

### Future Consideration (v2+)

- [ ] Body shaping — high UX and geometry risk; defer until face pipeline is robust.
- [ ] Background replacement and style effects — depends on segmentation, masks, resource UI, and edge quality.
- [ ] AR stickers and dynamic effects — needs tracking, resources, and performance work.
- [ ] AI style/photo generation — likely changes privacy and compute assumptions.
- [ ] Video export and commercial SDK distribution — requires performance, privacy manifest, documentation, and integration tests.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| SDK facade/package | HIGH | MEDIUM | P1 |
| No-op processing | HIGH | MEDIUM | P1 |
| Parameter model | HIGH | MEDIUM | P1 |
| Realtime camera path | HIGH | HIGH | P1 |
| Still image path | HIGH | HIGH | P1 |
| Presets | HIGH | MEDIUM | P1 |
| Skin/color/filter MVP | HIGH | MEDIUM/HIGH | P1 |
| Face/eye/nose/mouth MVP | HIGH | HIGH | P1 |
| Rich Demo category UI | HIGH | MEDIUM | P1 |
| Makeup | MEDIUM/HIGH | HIGH | P2 |
| Segmentation/background | MEDIUM/HIGH | HIGH | P2 |
| Multi-face individual tuning | MEDIUM | HIGH | P2 |
| Body shaping | MEDIUM | HIGH | P3 |
| AI style/stickers/video export | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when foundation is stable
- P3: Future consideration

## Competitor Feature Analysis

| Feature Area | Meitu/Xingtu/Qingyan-style Expectation | Our Approach |
|--------------|----------------------------------------|--------------|
| Beauty basics | Skin, face shape, facial features, filters, presets | Implement as SDK modules, expose through facade, validate through Demo. |
| Advanced editing | Makeup, blemish repair, segmentation, stickers, style | Stage after core pipeline and resource system. |
| UX | Category tabs, sliders, before/after, reset, presets | Demo mirrors this UX without putting UI inside SDK targets. |
| Trust | Natural output and responsive preview | Safety caps, bounded processing, diagnostics, fallback states. |

## Sources

- Local `docs/01_product_feature_plan.md` — full feature landscape and priority suggestions.
- Local `PRODUCT_SENSE.md` — MVP experience contract and acceptance criteria.
- Local `DESIGN.md` — 31-field 1.0 parameter model and preset rules.
- Local `.planning/PROJECT.md` — user-confirmed SDK + rich Demo direction.
- Apple Developer Documentation for AVFoundation, Vision, Metal, Core Image, Swift Package Manager, Observation, and privacy manifests — platform constraints.

---
*Feature research for: modular iOS beauty SDK*
*Researched: 2026-06-10*
