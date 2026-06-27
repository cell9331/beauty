# Requirements: Beauty

**Defined:** 2026-06-26
**Milestone:** v1.3 Meitu Core Beauty Module Design and Implementation
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.3 Requirements

Requirements for the core beauty module milestone. v1.3 does not write new SwiftUI screens. It prepares and then implements SDK-level core beauty modules behind existing boundaries, using code-level tests and example-image output where visible rendering is available.

### Preparation and Example Image Validation

- [x] **PREP-01**: A SwiftPM executable can load portrait fixtures from `example-images/input/`, run them through the public `BeautySDK` facade, and save PNG outputs under `example-images/out/`.
- [x] **PREP-02**: Output file names include the source image, modified parameter, and parameter strength, and generated images keep the same pixel dimensions as the source image.
- [x] **PREP-03**: Output images include a readable bottom watermark with the parameter and strength, placed so it does not cover the face.
- [x] **PREP-04**: The validation document records build/run commands, current visible cases, and the geometry-output limitation for face-shape/eye/nose/mouth/eyebrow/3D-sculpt branches.

### Core Beauty Taxonomy

- [x] **CBT-01**: The milestone has a local mind map and feature matrix for core Meitu-style beauty functions.
- [x] **CBT-02**: Core beauty function families are limited to minimal editor shell, beauty shaping, and skin retouch.
- [x] **CBT-03**: Home/discovery, resource/style systems, AI/background, video/body, gallery/account, search, VIP, payment, and entitlement surfaces are explicitly excluded from this milestone.

### Beauty Shaping Modules

- [ ] **BSHAPE-01**: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛` each have branch documentation and module ownership.
- [ ] **BSHAPE-02**: Promoted beauty-shaping branches implement core logic behind SDK boundaries with safety caps, degradation behavior, and tests.
- [ ] **BSHAPE-03**: Branch status is honest: implemented, partial, blocked by geometry visual output, or future.

### Skin Retouch Modules

- [x] **SKIN-01**: Basic skin, skin repair, and teeth/hairline branches each have branch documentation and module ownership.
- [x] **SKIN-02**: Promoted skin-retouch branches implement core logic behind SDK boundaries with degradation behavior, parameter caps, and tests.
- [x] **SKIN-03**: Current MVP skin controls stay separated from future local repair or region-based retouch capabilities.

### Editor Support Contract

- [ ] **EDITOR-01**: Minimal editor shell support is documented for input routing, preview chrome, bottom panel, and commit flow.
- [ ] **EDITOR-02**: Editor shell documentation clarifies Demo ownership versus SDK ownership for core beauty tools.
- [ ] **EDITOR-03**: Cancel/confirm, compare/debug, slider, category rail, and parameter snapshot semantics remain app-side support logic, not SDK algorithm logic.

### Module and Verification Planning

- [x] **MOD-01**: Module boundaries map Demo, `BeautySDK`, `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, and `BeautyResources` ownership for core beauty.
- [ ] **MOD-02**: The roadmap decomposes v1.3 into preparation, contracts, skin, shaping, and closeout phases with 100% requirement traceability.
- [ ] **MOD-03**: `PLANS.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` describe v1.3 as a no-new-UI core module design/implementation milestone.
- [ ] **MOD-04**: Promoted visible effects must provide unit/integration evidence and example-image output evidence before being considered complete.

## Future Requirements

Deferred to later milestones unless explicitly promoted.

### Deferred Meitu Product Areas

- **FUT-HOME-01**: Home/discovery feature system planning.
- **FUT-STYLE-01**: Filters, makeup, stickers, templates, and resource-pack planning.
- **FUT-AI-01**: AI retouch, background segmentation, cutout, and eraser planning.
- **FUT-VIDEO-01**: Video beauty, body shaping, and export pipeline planning.
- **FUT-ACCOUNT-01**: Gallery, account, search, VIP, payment, and entitlement planning.

## Out of Scope

| Feature | Reason |
| --- | --- |
| New SwiftUI screens | User narrowed v1.3 to core module design, encapsulation, implementation, and direct code-level verification. |
| Home/discovery surfaces | Core beauty module work only. |
| Filters, makeup, stickers, templates | Resource/style systems are deferred. |
| AI/background/cutout/eraser | AI and segmentation are deferred. |
| Video/body/export | Video and body pipelines are deferred. |
| Gallery/account/search/VIP/payment | Product/account surfaces are deferred. |
| Commercial asset parity | Reference taxonomy may be used; commercial assets are not production inputs. |
| Broad host-facing API expansion | Any required public API or parameter change must be explicitly documented in the owning root contract. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| PREP-01 | Phase 16 | Complete |
| PREP-02 | Phase 16 | Complete |
| PREP-03 | Phase 16 | Complete |
| PREP-04 | Phase 16 | Complete |
| CBT-01 | Phase 17 | Complete |
| CBT-02 | Phase 17 | Complete |
| CBT-03 | Phase 17 | Complete |
| MOD-01 | Phase 17 | Complete |
| SKIN-01 | Phase 18 | Complete |
| SKIN-02 | Phase 18 | Complete |
| SKIN-03 | Phase 18 | Complete |
| BSHAPE-01 | Phase 19 | Pending |
| BSHAPE-02 | Phase 19 | Pending |
| BSHAPE-03 | Phase 19 | Pending |
| EDITOR-01 | Phase 20 | Pending |
| EDITOR-02 | Phase 20 | Pending |
| EDITOR-03 | Phase 20 | Pending |
| MOD-02 | Phase 20 | Pending |
| MOD-03 | Phase 20 | Pending |
| MOD-04 | Phase 20 | Pending |

**Coverage:**

- v1.3 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0

---
*Requirements defined: 2026-06-26*
*Last updated: 2026-06-27 after Phase 18 skin-retouch execution*
