# Requirements: Beauty v1.5 SDK Geometry Output Foundation and Face Shape Slice

**Defined:** 2026-07-04
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.5 Requirements

### Geometry Output Foundation

- [x] **GEO-01**: SDK public facade can run geometry-enabled still-image processing through `BeautyEngine.processResult(...)`.
- [x] **GEO-02**: Detection and landmark results can feed geometry render planning without exposing raw landmark payloads or sensitive diagnostics.
- [x] **GEO-03**: Geometry render output preserves input dimensions and produces deterministic saved-output evidence through `BeautyExampleRenderer` or an equivalent SDK-only path.
- [x] **GEO-04**: Geometry output verification covers no-face, missing-landmark, stale/reused-landmark, and combined-strength degradation paths.

### Face Shape Slice

- [x] **FACE-01**: `脸宽` is SDK-complete through existing `faceSlim`.
- [x] **FACE-02**: `小脸` is SDK-complete through existing `faceSmall`.
- [x] **FACE-03**: `下巴长短` is SDK-complete through existing `chinLength`.
- [x] **FACE-04**: `V脸` is SDK-complete through existing `faceVShape`.
- [x] **FACE-05**: `下颌角` is SDK-complete through existing `jawSlim`.
- [x] **FACE-06**: `下颌线` is explicitly handled as either a documented `jawSlim` alias or a separate SDK behavior decision, with ledger evidence.

### Documentation and Evidence

- [x] **DOC-01**: `SHAPE_FEATURE_LEDGER.md` marks only verified `脸型` tools as `implemented`.
- [x] **DOC-02**: Beauty-shaping branch docs, `FEATURE_MATRIX.md`, and `EXAMPLE_IMAGE_VALIDATION.md` match the new SDK evidence.
- [x] **DOC-03**: Phase verification records exact test, renderer, scan, and blocker evidence without claiming UI, commercial, or full Meitu parity.

## Future Requirements

### Broader Shape and Facial Feature Groups

- **EYE-01**: Promote existing `眼睛` parameters after the geometry saved-output path is proven for the first face-shape slice.
- **NOSE-01**: Promote existing `鼻子` parameters after the geometry saved-output path is proven for the first face-shape slice.
- **MOUTH-01**: Promote existing `嘴唇` parameters after the geometry saved-output path is proven and `丰唇` is separated from color-only `lipColor` behavior.
- **PROP-01**: Promote additional `比例` tools only after product-neutral parameters and geometry behavior are designed.
- **SCULPT-01**: Promote `3D塑颜` only after pose-aware symmetry/translation/tilt design and output evidence exist.
- **BROW-01**: Promote `眉毛` only after landmark/resource ownership is designed.

## Out of Scope

| Feature | Reason |
| --- | --- |
| New SwiftUI or Demo UI work | v1.5 is SDK-core only; UI remains a separate milestone unless explicitly scoped. |
| `眼睛`, `鼻子`, `嘴唇`, `比例`, `3D塑颜`, `眉毛` implementation | The first v1.5 slice is geometry output foundation plus `脸型` existing parameters only. |
| New cloud, network AI, account, VIP, payment, or commercial entitlement behavior | The SDK remains local-first and no-network by default. |
| Full Meitu parity or commercial visual-quality claims | v1.5 verifies SDK behavior and evidence, not market parity or release-readiness. |
| Marking provider-only geometry evidence as complete | Geometry tools require facade-visible saved-output evidence before `implemented` status. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
| --- | --- | --- |
| GEO-01 | Phase 26 | Complete - `26-VERIFICATION.md` records `BeautyEngineGeometryFacadeTests`, focused compatibility/detector tests, and full `swift test --package-path BeautySDK` evidence for geometry-triggered still-image facade detection. |
| GEO-02 | Phase 26 | Complete - `26-VERIFICATION.md` records selected-face resolver/degradation tests plus public/SPI raw geometry export and active-source redaction scans. |
| GEO-03 | Phase 27 | Complete - `27-VERIFICATION.md` records `BeautyExampleRenderer` build/run evidence, 66 ignored PNG outputs, `check_geometry_renderer_outputs.py`, same-dimension checks, 5/5 portrait geometry-vs-baseline top-region comparisons, no-face output presence, and renderer matrix tests. |
| GEO-04 | Phase 27 | Complete - `27-VERIFICATION.md` records no-face saved-output evidence plus focused missing-landmark, stale/reused, combined-strength, and face-shape conflict-cap tests with redacted summaries and scans. |
| FACE-01 | Phase 28 | Complete - `28-VERIFICATION.md` records `faceSlim_0p35` renderer evidence, focused safety/degradation tests, 102-output helper evidence, and ledger promotion for `脸宽`. |
| FACE-02 | Phase 28 | Complete - `28-VERIFICATION.md` records `faceSmall_0p35` renderer evidence, focused safety/degradation tests, 102-output helper evidence, and ledger promotion for `小脸`. |
| FACE-03 | Phase 28 | Complete - `28-VERIFICATION.md` records `chinLength_plus0p30` and `chinLength_minus0p30` renderer evidence, signed-chin tests, helper evidence, and ledger promotion for `下巴长短`. |
| FACE-04 | Phase 28 | Complete - `28-VERIFICATION.md` records `faceVShape_0p35` renderer evidence, focused safety/degradation tests, helper evidence, and ledger promotion for `V脸`. |
| FACE-05 | Phase 28 | Complete - `28-VERIFICATION.md` records `jawSlim_0p35` renderer evidence, focused safety/degradation tests, helper evidence, and ledger promotion for `下颌角`. |
| FACE-06 | Phase 28 | Complete - `28-VERIFICATION.md` records `下颌线` as alias-backed by `jawSlim`, sharing `jawSlim_0p35` evidence with `下颌角` and avoiding a distinct parameter or algorithm. |
| DOC-01 | Phase 28 | Complete - `28-VERIFICATION.md` and `SHAPE_FEATURE_LEDGER.md` mark only `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` as implemented. |
| DOC-02 | Phase 28 | Complete - `28-VERIFICATION.md` cites synchronized beauty-shaping docs, `FEATURE_MATRIX.md`, and `EXAMPLE_IMAGE_VALIDATION.md`, with branch-level `脸型` still partial. |
| DOC-03 | Phase 28 | Complete - `28-VERIFICATION.md` records focused tests, renderer build/run, helper output, static scans, ignored-output policy, and blocker-free closeout without UI, commercial, or broad reference-app parity claims. |
| EYE-01 | Future | Deferred - promote existing `眼睛` parameters only after a scoped phase adds saved-output evidence and ledger updates. |
| NOSE-01 | Future | Deferred - promote existing `鼻子` parameters only after a scoped phase adds saved-output evidence and ledger updates. |
| MOUTH-01 | Future | Deferred - promote existing `嘴唇` parameters only after geometry evidence exists and `丰唇` is separated from color-only behavior. |
| PROP-01 | Future | Deferred - promote additional `比例` tools only after product-neutral parameters and geometry behavior are designed. |
| SCULPT-01 | Future | Deferred - promote `3D塑颜` only after pose-aware design and saved-output evidence exist. |
| BROW-01 | Future | Deferred - promote `眉毛` only after landmark/resource ownership is designed. |

**Coverage:**
- v1.5 requirements: 13 total
- Mapped to phases: 13
- Future requirements tracked: 6
- Unmapped: 0
- Complete: 13
- Pending: 0

---
*Requirements defined: 2026-07-04*
*Last updated: 2026-07-08 after Phase 28 verification*
