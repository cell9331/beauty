# Requirements: Beauty v1.12 Face Shape Remaining Capabilities

**Defined:** 2026-07-21
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.12 Requirements

### Public Face Contract

- [ ] **FACE-07**: An SDK integrator can request independent positive-only smooth-contour adjustment through `faceContourSmooth`, with zero-default source and Codable compatibility.
- [ ] **FACE-08**: An SDK integrator can request independent positive-only temple fullness through `templeFullness`, without aliasing `faceSmall` or `faceSlim`.
- [ ] **FACE-09**: An SDK integrator can request independent positive-only cheekbone narrowing through `cheekboneSlim`, without borrowing whole-cheek slimming evidence.
- [ ] **FACE-10**: An SDK integrator can request independent positive-only basic double-chin reduction through `doubleChinReduction`, without aliasing `jawSlim`.
- [ ] **FACE-11**: An SDK integrator can request independent positive-only refined double-chin treatment through `doubleChinRefinement`; the capability carries no payment, entitlement, account, or remote-service semantics.
- [ ] **FACE-12**: An SDK integrator can request independent positive-only chin taper through `chinTaper`, without changing signed `chinLength` semantics.
- [ ] **FACE-13**: An SDK integrator can request signed hairline-height adjustment through `hairlineHeight`, with positive and negative directions preserved end to end.

### Private Face Support

- [ ] **SUPP-01**: New contour-dependent fields use actual Vision face-contour and median-line points mapped once into image-normalized coordinates, not the legacy synthetic face-box proxy.
- [ ] **SUPP-02**: Observed contour and centerline support is canonicalized and rejected when non-finite, out of bounds, duplicate, undersized, side-inverted, or internally inconsistent.
- [ ] **SUPP-03**: Mask-dependent fields use a bundled local semantic support implementation whose license, provenance, version, hash, supported platforms, bounded output, and no-network behavior are verified before use.
- [ ] **SUPP-04**: Contours and masks remain request-scoped, package-internal, non-Codable, non-public, non-persistent, and absent from logs, metrics, errors, and Demo imports.

### Contour Geometry

- [ ] **GEOM-01**: Smooth-contour output reduces local lateral contour irregularity without globally shrinking the face or changing the five shipped face controls.
- [ ] **GEOM-02**: Temple output applies bounded upper-lateral outward movement that is spatially distinct from `faceSmall` and `faceSlim`.
- [ ] **GEOM-03**: Cheekbone output applies bounded mid-lateral inward movement that is spatially distinct from whole-cheek slimming and jaw narrowing.
- [ ] **GEOM-04**: Chin-taper output narrows adjacent lower-contour points toward the apex without lengthening or shortening the chin.

### Local Region Effects

- [ ] **REGN-01**: Basic double-chin reduction produces bounded lower-contour/submental behavior only when its required lower-face support is eligible.
- [ ] **REGN-02**: Refined double-chin treatment produces a mask-contained result distinguishable from basic reduction and is a no-op when refined semantic support is unavailable.
- [ ] **REGN-03**: Hairline-height output moves an eligible hair/skin boundary in both signed directions while preserving pixels outside the bounded hairline region.

### Public Output Evidence

- [ ] **OUT-01**: The public `BeautySDK` facade has isolated renderer cases for all seven controls, including both hairline directions and distinct basic-versus-refined double-chin behavior.
- [ ] **OUT-02**: A bounded strict helper verifies decoded same-dimension output, fixed-region visibility, locality, direction, and independence across the committed fixture matrix.
- [ ] **OUT-03**: No-face, missing-contour, missing-mask, and ineligible-region cases remain safe; generated output and galleries are ignored, untracked, and descriptor-safe.

### Safety and Closeout

- [ ] **SAFE-01**: All seven fields have exact final caps or dead zones plus field-local no-face, malformed, missing, reused, stale, and provider-empty transition evidence.
- [ ] **SAFE-02**: Combined face, eye, nose, and mouth geometry converges monotonically on provider-eligible emitted work, with final strengths, totals, counts, scales, warnings, metrics, and dispatch in exact agreement.
- [ ] **SAFE-03**: Active-source privacy, model/resource trust, network/commercial exclusion, diagnostics redaction, public inventory, Demo import, and generated-artifact gates fail closed with no unresolved high-severity finding.
- [ ] **DOC-01**: Exactly the seven remaining `脸型` rows and branch-level `脸型` become `implemented` only after all contract, support, output, safety, security, and owner-document evidence passes.

## Future Requirements

### Product and Release Evidence

- **REL-01**: Physical-device camera/Vision parity is measured for the new contour and semantic-region support.
- **REL-02**: Commercial visual review and optimized performance profiling approve the new effects for distribution.
- **UI-01**: Demo or host-app controls expose the seven capabilities through a separately scoped public UI contract.

## Out of Scope

| Feature | Reason |
| --- | --- |
| SwiftUI Demo screens or sliders | v1.12 is SDK-core and public-facade output evidence only. |
| Runtime model download, cloud inference, or remote processing | Violates the local-first and resource-trust boundary. |
| Payment, VIP, account, or entitlement behavior for “Pro” | The reference label does not define commercial SDK semantics. |
| Third-party beauty SDK | Core implementation and evidence remain repository-owned. |
| `比例`, `3D塑颜`, `眉毛`, `白牙`, `去脂`, and `祛红血丝` | Outside the exact remaining `脸型` branch scope. |
| Device parity, commercial approval, optimized performance, packaging, shipping, or launch readiness | Requires separate setup-specific evidence after functional completion. |
| Tracked generated image baselines | Renderer and gallery artifacts remain disposable, ignored local evidence. |

## Traceability

Traceability is populated during roadmap creation. Every v1.12 requirement must map to exactly one phase.

| Requirement | Phase | Status |
| --- | --- | --- |
| FACE-07..FACE-13 | TBD | Pending |
| SUPP-01..SUPP-04 | TBD | Pending |
| GEOM-01..GEOM-04 | TBD | Pending |
| REGN-01..REGN-03 | TBD | Pending |
| OUT-01..OUT-03 | TBD | Pending |
| SAFE-01..SAFE-03 | TBD | Pending |
| DOC-01 | TBD | Pending |

**Coverage:**

- v1.12 requirements: 25 total
- Mapped to phases: 0
- Unmapped: 25 ⚠️

---
*Requirements defined: 2026-07-21*
*Last updated: 2026-07-21 after v1.12 requirement definition*
