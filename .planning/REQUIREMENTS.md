# Requirements: Beauty

**Defined:** 2026-06-10
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1 Requirements

Requirements for the initial SDK milestone. Each requirement must map to exactly one roadmap phase.

### SDK Foundation

- [ ] **SDK-01**: Developer can build a local `BeautySDK` Swift Package with internal targets for `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and the public `BeautySDK` facade.
- [ ] **SDK-02**: Host app code can import only `BeautySDK` and access `BeautyEngine`, `BeautyConfiguration`, `BeautyParameters`, `BeautyPreset`, `BeautyResult`, and `BeautyError`.
- [ ] **SDK-03**: Developer can create a `BeautyParameters` 1.0 value covering skin, color, face shape, eyes, nose, mouth, and filter domains with the 31 fields defined by `DESIGN.md`.
- [ ] **SDK-04**: SDK processing with default parameters preserves input visually within no-op tolerance for both frame and image paths.
- [ ] **SDK-05**: SDK validates, clamps, or rejects invalid parameters and resources before rendering.
- [ ] **SDK-06**: SDK reports recoverable failures through typed `BeautyError` values and redacted diagnostics rather than crashes or raw framework errors.
- [ ] **SDK-07**: Automated package tests cover public facade imports, value models, parameter validation, preset decoding, no-op processing, and error mapping.
- [ ] **SDK-08**: Demo source imports `BeautySDK` only and does not import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources`.

### Input Pipelines

- [ ] **PIPE-01**: Demo can request camera permission and receive realtime camera frames through AVFoundation.
- [ ] **PIPE-02**: Realtime camera processing avoids `UIImage` as an intermediate format and passes sample-buffer, pixel-buffer, or texture-backed input to SDK code.
- [ ] **PIPE-03**: Realtime processing uses bounded in-flight work and drops stale frames instead of allowing unbounded queue growth.
- [ ] **PIPE-04**: Demo can select or provide a still image and process it through the SDK image path.
- [ ] **PIPE-05**: SDK and Demo preserve image orientation and front-camera mirroring through explicit metadata and normalization.
- [ ] **PIPE-06**: Demo provides before/after comparison for camera or still-image output without resetting parameters or shifting crop/orientation.
- [ ] **PIPE-07**: Demo handles loading, processing errors, denied permission, no-face frames, and partial-face frames without crashing.
- [ ] **PIPE-08**: Camera/photo features include required Info.plist purpose strings and conform to the local-first privacy boundary.

### MVP Effects

- [ ] **EFFECT-01**: User can adjust skin smoothing, skin whitening, rosy tone, and skin sharpen controls through Demo sliders backed by SDK parameters.
- [ ] **EFFECT-02**: User can adjust brightness, contrast, saturation, temperature, tint, exposure, highlight, and shadow controls through Demo sliders backed by SDK parameters.
- [ ] **EFFECT-03**: User can apply a filter by `filterId` and adjust `filterIntensity`, with missing filter resources handled as typed errors or visibly disabled UI.
- [ ] **EFFECT-04**: User can adjust face slim, small face, V shape, jaw/chin controls through SDK-backed parameters.
- [ ] **EFFECT-05**: User can adjust eye size, eye distance, eye vertical position, and eye tail lift through SDK-backed parameters.
- [ ] **EFFECT-06**: User can adjust nose slim, nose wing, nose tip, and nose bridge controls through SDK-backed parameters.
- [ ] **EFFECT-07**: User can adjust mouth size, mouth width, smile, and lip color controls through SDK-backed parameters.
- [ ] **EFFECT-08**: User can apply at least five built-in presets: Natural, Clear, Refined, Male Natural, and ID Photo Natural.
- [ ] **EFFECT-09**: Default parameters are no-op, natural presets are conservative, high-intensity values are safety-capped, and face-dependent effects safely degrade when face or landmarks are missing.

### Rich Demo

- [ ] **DEMO-01**: Demo main flow offers camera mode and still-image editing mode.
- [ ] **DEMO-02**: Demo exposes bottom-level categories for Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, and Style.
- [ ] **DEMO-03**: Demo shows v1-unimplemented categories or controls, including advanced makeup, stickers, background, and style, as disabled or coming-later states rather than active features.
- [ ] **DEMO-04**: Demo exposes Facial Features subcategories for Eyes, Nose, Mouth, Eyebrows, Teeth, and Hairline, with v1-unimplemented items disabled.
- [ ] **DEMO-05**: Demo sliders support `0...100` and `-100...100` display ranges and normalize values before passing parameters to the SDK.
- [ ] **DEMO-06**: Demo supports preset selection, single-parameter reset, reset-all, and basic parameter JSON import/export.
- [ ] **DEMO-07**: Demo provides before/after compare and debug overlay states for detection, degradation, and recoverable errors.
- [ ] **DEMO-08**: Automated Demo tests or view-state tests cover visible categories, disabled unavailable controls, slider normalization, and no internal SDK target imports.

## v2 Requirements

Deferred to later releases. These are valuable but not in the first roadmap unless explicitly promoted.

### Advanced Beauty Modules

- **ADV-01**: User can use makeup templates such as daily, commute, clear, sweet, Korean, Hong Kong, retro, ID photo, and male natural makeup.
- **ADV-02**: User can apply local makeup components for base makeup, concealer, contour, highlight, eye shadow, eyeliner, eyelashes, blush, lipstick, and brow style.
- **ADV-03**: User can adjust advanced skin repair such as blemish removal, dark circles, tear trough, nasolabial folds, wrinkles, and localized repair brush.
- **ADV-04**: User can adjust eyebrows, teeth whitening, hairline, forehead, and advanced facial sub-features beyond the 1.0 parameter set.
- **ADV-05**: User can process multiple faces with main-face selection and per-face parameters.
- **ADV-06**: User can use portrait segmentation features such as background blur, background replacement, transparent background, portrait outline, and depth effects.
- **ADV-07**: User can use body shaping features such as long legs, slimming, shoulder/waist/limb adjustment, and head-body ratio optimization.
- **ADV-08**: User can apply stickers, AR masks, light effects, AI style effects, and advanced style templates.
- **ADV-09**: User can export processed video with progress, cancellation, orientation preservation, and audio preservation.
- **ADV-10**: SDK can support commercial resource packs, binary distribution, compatibility matrices, and distribution-grade privacy manifests.

## Out of Scope

Explicitly excluded from v1 to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Standalone consumer App Store product | The confirmed product is an SDK; Demo validates SDK capabilities but is not the primary consumer product. |
| Demo direct imports of internal targets | Demo must behave like a real host app and use the public `BeautySDK` facade only. |
| Cloud upload or network processing by default | Faces, photos, landmarks, presets, and diagnostics are sensitive; v1 is local-first. |
| Full Meitu/Xingtu feature parity in v1 | Advanced makeup, segmentation, body, stickers, AI style, and video export depend on stable foundation and are deferred. |
| Treating ignored `.worktrees/` implementation as delivered code | Only tracked main-worktree implementation counts for roadmap progress. |
| Third-party beauty SDK as the core implementation | Current direction is local Swift/Metal/Vision/Core Image implementation unless explicitly changed later. |
| Camera/photo permission prompts from SDK internals | Host app or Demo owns protected-resource permission UX. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SDK-01 | TBD | Pending |
| SDK-02 | TBD | Pending |
| SDK-03 | TBD | Pending |
| SDK-04 | TBD | Pending |
| SDK-05 | TBD | Pending |
| SDK-06 | TBD | Pending |
| SDK-07 | TBD | Pending |
| SDK-08 | TBD | Pending |
| PIPE-01 | TBD | Pending |
| PIPE-02 | TBD | Pending |
| PIPE-03 | TBD | Pending |
| PIPE-04 | TBD | Pending |
| PIPE-05 | TBD | Pending |
| PIPE-06 | TBD | Pending |
| PIPE-07 | TBD | Pending |
| PIPE-08 | TBD | Pending |
| EFFECT-01 | TBD | Pending |
| EFFECT-02 | TBD | Pending |
| EFFECT-03 | TBD | Pending |
| EFFECT-04 | TBD | Pending |
| EFFECT-05 | TBD | Pending |
| EFFECT-06 | TBD | Pending |
| EFFECT-07 | TBD | Pending |
| EFFECT-08 | TBD | Pending |
| EFFECT-09 | TBD | Pending |
| DEMO-01 | TBD | Pending |
| DEMO-02 | TBD | Pending |
| DEMO-03 | TBD | Pending |
| DEMO-04 | TBD | Pending |
| DEMO-05 | TBD | Pending |
| DEMO-06 | TBD | Pending |
| DEMO-07 | TBD | Pending |
| DEMO-08 | TBD | Pending |

**Coverage:**
- v1 requirements: 33 total
- Mapped to phases: 0
- Unmapped: 33 pending roadmap

---
*Requirements defined: 2026-06-10*
*Last updated: 2026-06-10 after initial definition*
