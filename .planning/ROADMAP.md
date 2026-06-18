# Roadmap: Beauty

## Overview

Beauty v1 builds a modular iOS beauty SDK and a rich Demo app in vertical slices. The path starts with a host-app-importable no-op SDK, then proves Demo integration, realtime/still-image input, detection and coordinate safety, resource-backed filters/presets, core beauty effects, and finally a polished Meitu/Xingtu-style Demo QA surface. Advanced makeup, segmentation, body shaping, stickers, AI style, and video export remain v2+ work.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: SDK Foundation and Public Facade** - Host apps can import and exercise a no-op modular SDK. (completed 2026-06-11)
- [x] **Phase 2: Demo Integration Shell** - Demo uses only the public facade and exposes the rich category skeleton. (completed 2026-06-11)
- [x] **Phase 3: Realtime and Still Input Slice** - Demo can send camera frames and still images through the SDK safely. (completed 2026-06-12)
- [ ] **Phase 4: Detection and Coordinate Safety** - SDK can reason about faces, orientation, mirroring, and safe degraded frames.
- [ ] **Phase 5: Filters, Presets, and Resource Flow** - Users can apply safe color/filter controls and built-in presets.
- [ ] **Phase 6: Core Beauty Effects** - Users can tune skin, face, eye, nose, and mouth MVP controls with safety caps.
- [ ] **Phase 7: Rich Demo QA Surface** - Demo becomes a complete validation surface with compare, reset, debug, and tests.

## Phase Details

### Phase 1: SDK Foundation and Public Facade

**Goal:** Host app code can import `BeautySDK`, create public models, call a no-op engine path, and run foundation tests.
**Mode:** mvp
**Depends on:** Nothing (first phase)
**Requirements:** SDK-01, SDK-02, SDK-03, SDK-04, SDK-05, SDK-06, SDK-07
**Success Criteria** (what must be TRUE):

  1. Developer can build `BeautySDK` as a local Swift Package with the required internal targets.
  2. Host-app-style test code can import only `BeautySDK` and access the public facade types.
  3. Default processing preserves frame/image input within no-op tolerance.
  4. Invalid parameters and recoverable errors produce typed SDK behavior and redacted diagnostics.
  5. Package tests cover facade imports, value models, validation, presets, no-op processing, and error mapping.

**Plans:** 4/4 plans complete
Plans:
**Wave 1**

- [x] 01-01: Create Swift Package target structure and public facade target.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-02: Implement public value models, defaults, validation, clamping, and preset decoding.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-03: Implement no-op `BeautyEngine` process/reset behavior and typed errors.

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 01-04: Add foundation package tests and build verification.

### Phase 2: Demo Integration Shell

**Goal:** Demo behaves like a real host app by importing `BeautySDK` only and showing the planned editor categories with unavailable states.
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** SDK-08, DEMO-02, DEMO-03, DEMO-04, DEMO-05, DEMO-08
**Success Criteria** (what must be TRUE):

  1. Demo source imports `BeautySDK` and no internal SDK target.
  2. Demo shows bottom categories for Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, and Style.
  3. Demo shows Eyes, Nose, Mouth, Eyebrows, Teeth, and Hairline subcategories under Facial Features.
  4. Unimplemented v1 and v2 controls are disabled or clearly marked coming later.
  5. View-state or UI tests cover category visibility, disabled controls, slider normalization, and import boundaries.

**Plans:** 3/3 plans complete
Plans:
**Wave 1**

- [x] 02-01: Refactor Demo app shell into feature directories and SDK-only dependency wiring.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 02-02: Build editor category, subcategory, slider, and disabled-state view models.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 02-03: Add Demo view-state/import-boundary tests.

### Phase 3: Realtime and Still Input Slice

**Goal:** Demo can send live camera frames and still images through the SDK no-op path with stable permission, loading, compare, and privacy behavior.
**Mode:** mvp
**Depends on:** Phase 2
**Requirements:** PIPE-01, PIPE-02, PIPE-03, PIPE-04, PIPE-06, PIPE-08, DEMO-01
**Success Criteria** (what must be TRUE):

  1. User can choose camera mode or still-image editing mode in the Demo.
  2. Demo can request camera permission and receive realtime frames through AVFoundation.
  3. Realtime processing avoids `UIImage` conversion and uses bounded in-flight processing with stale-frame drops.
  4. Demo can process a still image through the SDK image path.
  5. Before/after comparison works without resetting parameters or changing crop/orientation.
  6. Camera/photo purpose strings and local-first privacy boundaries are present before protected-resource access.

**Plans:** 4/4 plans complete
Plans:

**Wave 1**

- [x] 03-01: Add camera permission and AVFoundation frame capture shell.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 03-02: Add bounded realtime SDK invocation without `UIImage` conversion.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 03-03: Add still-image input, processing, loading, and compare states.

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 03-04: Add purpose strings, privacy checks, and input pipeline tests.

### Phase 4: Detection and Coordinate Safety

**Goal:** SDK and Demo preserve orientation/mirroring, detect usable face state, and degrade safely for no-face or partial-face inputs.
**Mode:** mvp
**Depends on:** Phase 3
**Requirements:** PIPE-05, PIPE-07
**Success Criteria** (what must be TRUE):

  1. SDK and Demo pass explicit orientation and mirroring metadata through frame and image processing.
  2. Face detection and coordinate mapping use a canonical image-normalized model.
  3. No-face and partial-face frames produce safe output and diagnosable state instead of crashes.
  4. Fixture tests cover orientation, mirroring, no-face, and missing-landmark scenarios.

**Plans:** 4/5 plans executed

Plans:

**Wave 1**

- [x] 04-01: Add public metadata/result contracts and BeautyEngine compatibility.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 04-02: Add internal detection models, face selection, and Vision adapter seams.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 04-03: Add canonical coordinate spaces and orientation/mirroring mappers.

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 04-04: Add Demo metadata propagation and safe detection status/debug models.

**Wave 5** *(blocked on Wave 4 completion)*

- [ ] 04-05: Add privacy scans, root contract updates, and final verification plan.

### Phase 5: Filters, Presets, and Resource Flow

**Goal:** Users can apply safe color/filter controls and built-in presets backed by validated SDK resources.
**Mode:** mvp
**Depends on:** Phase 4
**Requirements:** EFFECT-02, EFFECT-03, EFFECT-08
**Success Criteria** (what must be TRUE):

  1. User can adjust brightness, contrast, saturation, temperature, tint, exposure, highlight, and shadow controls.
  2. User can apply a filter by `filterId` and adjust `filterIntensity`.
  3. Missing filter resources produce typed errors or visibly disabled UI.
  4. User can apply Natural, Clear, Refined, Male Natural, and ID Photo Natural presets.
  5. Preset and resource validation tests cover schema, missing resources, and slider sync.

**Plans:** 4 plans

Plans:

- [ ] 05-01: Add resource manifest model and built-in preset resources.
- [ ] 05-02: Add color/filter parameter mapping and render/resource placeholders.
- [ ] 05-03: Wire preset and filter controls into Demo through the facade.
- [ ] 05-04: Add resource, preset, and missing-filter tests.

### Phase 6: Core Beauty Effects

**Goal:** Users can tune the MVP skin, face, eye, nose, and mouth effects with naturalness caps and safe degradation.
**Mode:** mvp
**Depends on:** Phase 5
**Requirements:** EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07, EFFECT-09
**Success Criteria** (what must be TRUE):

  1. User can adjust skin smoothing, whitening, rosy tone, and sharpen controls.
  2. User can adjust face slim, small face, V shape, jaw, and chin controls.
  3. User can adjust eye size, eye distance, eye vertical position, and eye tail lift controls.
  4. User can adjust nose slim, nose wing, nose tip, nose bridge, mouth size, mouth width, smile, and lip color controls.
  5. Default values are no-op, natural presets stay conservative, high intensity values are safety-capped, and face-dependent effects degrade safely.

**Plans:** 5 plans

Plans:

- [ ] 06-01: Implement skin and color-adjacent effect passes with fixture checks.
- [ ] 06-02: Implement face-shape warp controls with naturalness caps.
- [ ] 06-03: Implement eye and nose MVP controls with coordinate fixtures.
- [ ] 06-04: Implement mouth and lip MVP controls with safe missing-landmark behavior.
- [ ] 06-05: Add combined-effect safety, no-face degradation, and visual/regression tests.

### Phase 7: Rich Demo QA Surface

**Goal:** Demo becomes a complete SDK validation surface with preset/reset/JSON workflows, compare/debug states, and v1 readiness evidence.
**Mode:** mvp
**Depends on:** Phase 6
**Requirements:** DEMO-06, DEMO-07
**Success Criteria** (what must be TRUE):

  1. User can select presets, reset one parameter, reset all parameters, and import/export basic parameter JSON.
  2. User can compare before/after output and inspect debug overlay states for detection, degradation, and recoverable errors.
  3. Demo clearly distinguishes implemented, disabled, and future categories.
  4. Automated checks cover final Demo workflows and SDK boundary rules.
  5. Requirements traceability shows all 33 v1 requirements mapped to phases.

**Plans:** 3 plans

Plans:

- [ ] 07-01: Add preset/reset/JSON workflows and state persistence boundaries.
- [ ] 07-02: Add final compare/debug overlay UX and unavailable-state polish.
- [ ] 07-03: Add final Demo QA tests, traceability audit, and v1 readiness documentation.

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. SDK Foundation and Public Facade | 4/4 | Complete    | 2026-06-11 |
| 2. Demo Integration Shell | 3/3 | Complete    | 2026-06-11 |
| 3. Realtime and Still Input Slice | 4/4 | Complete    | 2026-06-12 |
| 4. Detection and Coordinate Safety | 1/5 | In Progress|  |
| 5. Filters, Presets, and Resource Flow | 0/4 | Not started | - |
| 6. Core Beauty Effects | 0/5 | Not started | - |
| 7. Rich Demo QA Surface | 0/3 | Not started | - |
