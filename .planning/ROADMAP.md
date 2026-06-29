# Roadmap: Beauty

## Overview

Beauty v1.3 is a no-new-UI core beauty module milestone. It references the Meitu Xiuxiu beauty editor taxonomy, narrows scope to core beauty, prepares a direct example-image validation path, and then designs/implements promoted SDK-level beauty modules behind existing boundaries.

This milestone does not add SwiftUI screens, Home/discovery surfaces, resource/style systems, AI/background flows, video/body flows, gallery/account flows, payment, VIP, or entitlement behavior.

## Milestones

- ✅ **v1.0 MVP** - Phases 1-7, shipped 2026-06-23. See `.planning/milestones/v1.0-ROADMAP.md`.
- ✅ **v1.1 Meitu UI** - Phases 8-10, implemented and verified 2026-06-24.
- ✅ **v1.2 HTML Reference Fidelity** - Phase 11 completed 2026-06-25; Phases 12-15 canceled 2026-06-26.
- 🚧 **v1.3 Meitu Core Beauty Module Design and Implementation** - Phases 16-18 completed; Phases 19-20 remain planned.

## v1.3 Meitu Core Beauty Module Design and Implementation

### Phase 16: Example Image Validation Harness

**Goal:** Prepare the code-level image validation path before implementing more core beauty logic.
**Mode:** implementation prep
**Depends on:** existing `BeautySDK` facade, `example-images/input/`
**Requirements:** PREP-01, PREP-02, PREP-03, PREP-04
**Success Criteria**:

1. `BeautyExampleRenderer` builds as a SwiftPM executable product.
2. The renderer imports only public `BeautySDK`, loads images from `example-images/input/`, and writes PNG outputs to `example-images/out/`.
3. Output file names and watermarks include the parameter and strength, and output dimensions match input dimensions.
4. `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` records commands, current cases, and geometry-output limitations.

**Plans:** 2/2 plans complete
**Wave 1**

- [x] 16-01: Add and verify the `BeautyExampleRenderer` executable and ignored output directory.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 16-02: Update documentation and planning files so v1.3 starts from executable code-level validation.

**Cross-cutting constraints:**

- D-13: geometry-heavy branches do not count as visually complete in Phase 16.
- D-15: Phase 19 owns geometry saved-output status and verification for face/facial-feature shaping branches.

### Phase 17: Core Beauty Contracts and Module Boundaries

**Goal:** Finalize taxonomy, branch status, and module ownership before branch implementation.
**Mode:** design
**Depends on:** Phase 16
**Requirements:** CBT-01, CBT-02, CBT-03, MOD-01
**Success Criteria**:

1. `docs/meitu-function-blueprint/README.md`, `MINDMAP.md`, `FEATURE_MATRIX.md`, and `MODULES.md` describe the active core beauty scope.
2. Branch folders exist only for minimal editor support, beauty shaping, and skin retouch.
3. Deferred families are explicitly excluded and cannot be mistaken for active scope.
4. Demo ownership and SDK ownership are separated before implementation starts.

**Plans:** 2/2 plans complete
**Wave 1**

- [x] 17-01: Finalize taxonomy, feature matrix, and module ownership for core beauty only.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 17-02: Verify contracts against `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, and current SDK targets.

### Phase 18: Skin Retouch Core Modules

**Goal:** Implement promoted skin-retouch module logic behind SDK boundaries and verify visible outputs where available.
**Mode:** implementation
**Depends on:** Phases 16-17
**Requirements:** SKIN-01, SKIN-02, SKIN-03
**Success Criteria**:

1. Basic skin behavior is covered by focused tests and example-image output cases.
2. Skin repair and teeth/hairline branches remain documented future branches unless local inputs and degradation behavior become clear in a later phase.
3. Safety caps, warnings, no-face behavior, and parameter clamping are verified.

**Plans:** 3/3 plans complete
**Wave 1**

- [x] 18-01: Audit current skin controls and map them to the v1.3 branch contracts.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 18-02: Implement promoted skin-retouch module improvements behind SDK boundaries.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 18-03: Verify skin-retouch tests and saved example-image outputs.

### Phase 19: Beauty Shaping Core Modules

**Goal:** Implement or prepare promoted face/facial-feature shaping logic behind SDK boundaries, with honest geometry-output status.
**Mode:** implementation
**Depends on:** Phases 16-17
**Requirements:** BSHAPE-01, BSHAPE-02, BSHAPE-03
**Success Criteria**:

1. `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛` branches have clear implemented/partial/future status.
2. Promoted shaping logic has provider/unit evidence and degradation behavior.
3. Saved image-output evidence is required only after face detection plus geometry rendering can produce visible output through the public facade.

**Plans:** 0/5 plans complete
**Wave 1**

- [ ] 19-01: Audit existing shaping providers, parameters, and geometry-output gaps.

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 19-02: Harden face/chin/proportion plus eye/nose provider evidence behind SDK boundaries.
- [ ] 19-03: Harden mouth/lip, resolver degradation, and redaction evidence behind SDK boundaries.

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 19-04: Verify BeautySDK shaping tests and update blueprint/example-image status honestly.

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 19-05: Run final negative scans and close Phase 19 planning ledgers.

### Phase 20: Core Module Closeout

**Goal:** Close v1.3 with editor-support contracts, verification evidence, and planning ledger consistency.
**Mode:** verification
**Depends on:** Phases 16-19
**Requirements:** EDITOR-01, EDITOR-02, EDITOR-03, MOD-02, MOD-03, MOD-04
**Success Criteria**:

1. Editor support remains app-side and no new SwiftUI screens are added.
2. Promoted visible effects have unit/integration evidence plus example-image output evidence.
3. Planning documents, docs, and root contracts reflect actual implemented behavior and remaining limitations.

**Plans:** 0/2 plans complete

- [ ] 20-01: Finalize editor support contracts, delivery boundary, and root contract updates.
- [ ] 20-02: Run closeout tests, example-image renderer, scope scans, and planning consistency checks.

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
| --- | --- | ---: | --- | --- |
| 1. SDK Foundation and Public Facade | v1.0 | 4/4 | Complete | 2026-06-11 |
| 2. Demo Integration Shell | v1.0 | 3/3 | Complete | 2026-06-11 |
| 3. Realtime and Still Input Slice | v1.0 | 4/4 | Complete | 2026-06-12 |
| 4. Detection and Coordinate Safety | v1.0 | 5/5 | Complete | 2026-06-18 |
| 5. Filters, Presets, and Resource Flow | v1.0 | 4/4 | Complete | 2026-06-19 |
| 6. Core Beauty Effects | v1.0 | 5/5 | Complete | 2026-06-22 |
| 7. Rich Demo QA Surface | v1.0 | 3/3 | Complete | 2026-06-23 |
| 8. Meitu Home Rebuild | v1.1 | 4/4 | Complete | 2026-06-24 |
| 9. Meitu Editor Tool Panel | v1.1 | 4/4 | Complete | 2026-06-24 |
| 10. Home-to-Editor Flow and v1.1 QA | v1.1 | 3/3 | Complete | 2026-06-24 |
| 11. HTML Reference Baselines | v1.2 | 4/4 | Complete | 2026-06-25 |
| 12. HTML-to-SwiftUI Delta Contract | v1.2 | 0/3 | Canceled | 2026-06-26 |
| 13. Home SwiftUI Fidelity Pass | v1.2 | 0/3 | Canceled | 2026-06-26 |
| 14. Editor SwiftUI Fidelity Pass | v1.2 | 0/3 | Canceled | 2026-06-26 |
| 15. v1.2 Visual QA and Closeout | v1.2 | 0/3 | Canceled | 2026-06-26 |
| 16. Example Image Validation Harness | v1.3 | 2/2 | Complete | 2026-06-26 |
| 17. Core Beauty Contracts and Module Boundaries | v1.3 | 2/2 | Complete | 2026-06-26 |
| 18. Skin Retouch Core Modules | v1.3 | 3/3 | Complete | 2026-06-27 |
| 19. Beauty Shaping Core Modules | v1.3 | 0/3 | Planned | - |
| 20. Core Module Closeout | v1.3 | 0/2 | Planned | - |

## Backlog

Future milestone candidates:

- Home/discovery feature system planning.
- Filters, makeup, stickers, templates, and resource-pack planning.
- AI retouch, background segmentation, cutout, and eraser planning.
- Video beauty, body shaping, and export pipeline planning.
- Gallery, account, search, VIP, payment, and entitlement planning.
- Automated visual QA with pixel/perceptual diffing and device sweeps.
