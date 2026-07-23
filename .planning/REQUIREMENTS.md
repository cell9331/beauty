# Requirements: Beauty v1.12 Face Shape Remaining Capabilities

**Defined:** 2026-07-21
**Rescoped:** 2026-07-21 after the semantic-resource feasibility blocker
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.12 Requirements

### Public Face Contract

- [x] **FACE-07**: An SDK integrator can request independent positive-only smooth-contour adjustment through `faceContourSmooth`, with zero-default source and Codable compatibility.
- [x] **FACE-08**: An SDK integrator can request independent positive-only temple fullness through `templeFullness`, without aliasing `faceSmall` or `faceSlim`.
- [x] **FACE-09**: An SDK integrator can request independent positive-only cheekbone narrowing through `cheekboneSlim`, without borrowing whole-cheek slimming evidence.
- [x] **FACE-12**: An SDK integrator can request independent positive-only chin taper through `chinTaper`, without changing signed `chinLength` semantics.

### Private Face Support

- [x] **SUPP-01**: New contour-dependent fields use actual Vision face-contour and median-line points mapped once into image-normalized coordinates, not the legacy synthetic face-box proxy.
- [x] **SUPP-02**: Observed contour and centerline support is canonicalized and rejected when non-finite, out of bounds, duplicate, undersized, side-inverted, or internally inconsistent.
- [x] **SUPP-04**: Observed support remains request-scoped, package-internal, non-Codable, non-public, non-persistent, and absent from logs, metrics, errors, and Demo imports.

### Contour Geometry

- [ ] **GEOM-01**: Smooth-contour output reduces local lateral contour irregularity without globally shrinking the face or changing the five shipped face controls.
- [ ] **GEOM-02**: Temple output applies bounded upper-lateral outward movement that is spatially distinct from `faceSmall` and `faceSlim`.
- [ ] **GEOM-03**: Cheekbone output applies bounded mid-lateral inward movement that is spatially distinct from whole-cheek slimming and jaw narrowing.
- [ ] **GEOM-04**: Chin-taper output narrows adjacent lower-contour points toward the apex without lengthening or shortening the chin.

### Public Output Evidence

- [ ] **OUT-01**: The public `BeautySDK` facade has one isolated renderer case for each of the four new controls, with no case borrowing a shipped face field.
- [ ] **OUT-02**: A bounded strict helper verifies decoded same-dimension output, fixed-region visibility, locality, and independence across the established fixture matrix.
- [ ] **OUT-03**: No-face, missing-contour, and malformed-contour cases remain safe; generated output and galleries are ignored, untracked, and descriptor-safe.

### Safety and Scoped Closeout

- [ ] **SAFE-01**: All four fields have exact final caps or dead zones plus field-local no-face, malformed, missing, reused, stale, and provider-empty transition evidence.
- [ ] **SAFE-02**: Combined face, eye, nose, and mouth geometry converges monotonically on provider-eligible emitted work, with final strengths, totals, counts, scales, warnings, metrics, and dispatch in exact agreement.
- [ ] **SAFE-03**: Active-source privacy, diagnostics redaction, public inventory, Demo import, network/commercial exclusion, and generated-artifact gates fail closed with no unresolved high-severity finding.
- [ ] **DOC-01**: Exactly `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` become `implemented`; `去双下巴`, `去双下巴 Pro`, `发际线`, and branch-level `脸型` remain future or partial with the blocker recorded.

## Future Requirements

### Semantic-Region Face Tools

- Basic and refined double-chin reduction require a licensed, versioned, hash-verified local semantic support implementation plus clean-clone representative fixtures.
- Signed hairline adjustment requires a validated hair/skin boundary implementation and reproducible containment evidence.

### Product and Release Evidence

- Physical-device camera/Vision parity remains future.
- Commercial visual review, optimized profiling, and Demo UI remain separately scoped.

## Out of Scope

| Feature | Reason |
| --- | --- |
| `去双下巴`, `去双下巴 Pro`, and `发际线` | No approved semantic resource or clean-clone annotated fixture exists; user selected reduced scope instead of model authorization. |
| SwiftUI Demo screens or sliders | v1.12 is SDK-core and public-facade output evidence only. |
| Runtime model download, cloud inference, or remote processing | Violates the local-first and resource-trust boundary. |
| Payment, VIP, account, or entitlement behavior | No commercial behavior is included. |
| Third-party beauty SDK or semantic model | Not authorized for the reduced v1.12 scope. |
| `比例`, `3D塑颜`, `眉毛`, `白牙`, `去脂`, and `祛红血丝` | Outside the contour-driven `脸型` scope. |
| Device parity, commercial approval, optimized performance, packaging, shipping, or launch readiness | Requires separate setup-specific evidence after functional completion. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| FACE-07 | Phase 45 | Complete |
| FACE-08 | Phase 45 | Complete |
| FACE-09 | Phase 45 | Complete |
| FACE-12 | Phase 45 | Complete |
| SUPP-01 | Phase 45 | Complete |
| SUPP-02 | Phase 45 | Complete |
| SUPP-04 | Phase 45 | Complete |
| GEOM-01 | Phase 46 | Pending |
| GEOM-02 | Phase 46 | Pending |
| GEOM-03 | Phase 46 | Pending |
| GEOM-04 | Phase 46 | Pending |
| OUT-01 | Phase 47 | Pending |
| OUT-02 | Phase 47 | Pending |
| OUT-03 | Phase 47 | Pending |
| SAFE-01 | Phase 48 | Pending |
| SAFE-02 | Phase 48 | Pending |
| SAFE-03 | Phase 48 | Pending |
| DOC-01 | Phase 48 | Pending |

**Coverage:**

- v1.12 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0 ✓

---
*Requirements defined: 2026-07-21*
*Last updated: 2026-07-21 after semantic-resource blocker rescope*
