# Requirements: Beauty v1.6 Broader `美型 / 五官` SDK Slice - Eyes

**Defined:** 2026-07-09
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.6 Requirements

### Eye Renderer Evidence

- [x] **EYE-01**: `BeautyExampleRenderer` can generate public-facade saved-output cases for the existing public eye parameters `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift` without importing internal SDK targets. Evidence: `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md` and `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md`.
- [x] **EYE-02**: The eye renderer helper verifies every expected eye output exists, is non-empty, preserves input dimensions, and differs from `geometryBaseline_noop` above the watermark band on usable portrait fixtures. Evidence: `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md` and `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md`.
- [x] **EYE-03**: Generated eye output and gallery artifacts stay under ignored `example-images/output/` and `example-images/gallery/`; no generated PNG baseline is committed. Evidence: `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md` and `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md`.

### Eye Safety And Degradation

- [x] **EYE-04**: Focused tests cover eye safety caps for existing public eye parameters and prove out-of-range public input resolves to conservative effective strengths.
- [x] **EYE-05**: Focused tests cover no-face and missing-eye-landmark degradation, including preserved dimensions, redacted warnings, and no stale or reused eye geometry.
- [x] **EYE-06**: Focused tests cover combined-geometry weakening when eye parameters are used with other face-dependent geometry domains.

### Boundaries And Documentation

- [x] **EYE-07**: Public/import scans prove the `眼睛` slice adds no public raw geometry API, no Demo internal SDK imports, no network/cloud behavior, and no commercial entitlement path.
- [ ] **EYE-08**: `SHAPE_FEATURE_LEDGER.md` promotes only evidence-backed existing-parameter `眼睛` rows: `大小`, `上下`, `眼距`, and `眼尾上扬`.
- [ ] **DOC-01**: `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, root contracts, `QUALITY_SCORE.md`, and `PLANS.md` are synchronized after evidence passes, while branch-level `眼睛` remains `partial`.

## Future Requirements

### Broader `眼睛`

- **EYE-FUTURE-01**: Eye height, eye length, eye fat removal, lid, pupil, gaze correction, tilt, redness removal, inner corner, outer corner, and symmetry need separate product-neutral parameter/resource design before implementation.

### Other `美型 / 五官` Branches

- **SHAPE-FUTURE-01**: `鼻子`, `嘴唇`, `比例`, `3D塑颜`, and `眉毛` remain future or partial until a later milestone scopes them.

## Out of Scope

| Feature | Reason |
| --- | --- |
| New SwiftUI Demo controls | v1.6 is SDK-core evidence only; Demo UI remains a separate milestone. |
| New public `BeautyParameters` fields | v1.6 promotes only behavior already backed by existing public eye parameters. |
| Commercial visual approval or device parity | Requires separate review/hardware evidence beyond SDK saved-output correctness. |
| Full `眼睛` branch completion | Several second-level tools lack neutral SDK parameters or local algorithm/resource design. |
| Network, cloud AI, account, payment, VIP, or entitlement behavior | The project remains local-first and SDK-core for this milestone. |

## Traceability

| Requirement | Phase | Status | Evidence |
| --- | --- | --- | --- |
| EYE-01 | Phase 29 | Complete | `29-VERIFICATION.md` records six public-facade eye renderer cases, the 23-case matrix, and public-import boundary evidence; `29-EYE-RENDERER-EVIDENCE.md` records the case-to-parameter mapping. |
| EYE-02 | Phase 29 | Complete | `29-VERIFICATION.md` and `29-EYE-RENDERER-EVIDENCE.md` record 161/161 outputs, 36/36 eye-vs-baseline top-region comparisons, dimensions, and representative no-face output presence. |
| EYE-03 | Phase 29 | Complete | `29-VERIFICATION.md` and `29-EYE-RENDERER-EVIDENCE.md` record ignored output/gallery checks, generated `eyes/` gallery routing, and zero tracked generated output/gallery files. |
| EYE-04 | Phase 30 | Complete | `30-01-SUMMARY.md` records positive-only size/tail normalization, signed distance/Y behavior, exact caps, warning/count evidence, and abnormal-input/no-op coverage. |
| EYE-05 | Phase 30 | Complete | `30-02-SUMMARY.md` records either-eye missing, reused/stale zeroing, non-eye reuse preservation, public no-face extent/safe-domain behavior, and explicit redaction guards. |
| EYE-06 | Phase 30 | Complete | `30-02-SUMMARY.md` records six direction-specific normal-versus-combined cases and one exact six-field all-eye multi-domain weakening case. |
| EYE-07 | Phase 30 | Complete | `30-EYE-SAFETY-EVIDENCE.md` and `30-SECURITY.md` record zero public/SPI raw geometry, forbidden imports, network/cloud paths, commercial execution paths, and unclassified VIP matches. |
| EYE-08 | Phase 30 | Pending | Pending Phase 30 scoped `SHAPE_FEATURE_LEDGER.md` row evidence. |
| DOC-01 | Phase 30 | Pending | Pending Phase 30 documentation synchronization after safety and scoped ledger evidence. |

**Coverage:**

- v1.6 requirements: 9 total
- Mapped to phases: 9
- Unmapped: 0

---
*Requirements defined: 2026-07-09*
*Last updated: 2026-07-09 after Phase 29 renderer evidence closeout*
