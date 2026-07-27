# Requirements: Beauty v1.13 Eyebrow Geometry Controls

**Defined:** 2026-07-24
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.13 Requirements

### Public Eyebrow Contract

- [x] **BROW-01**: An SDK integrator can request seven independent normalized eyebrow controls—vertical position, thickness, length, overall spacing, inner-head spacing, tilt, and peak definition—with zero-default product-neutral semantics.
- [x] **BROW-02**: Existing source calls, legacy 52-field JSON payloads, all bundled preset bytes, normalization, equality, reset, diff, and round-trip behavior remain compatible when the stored model expands to exactly 59 fields.

### Private Observed Eyebrow Support

- [x] **SUPP-01**: A geometry-enabled request copies actual left/right Apple Vision eyebrow traces from the existing single selected-face landmarks request and maps each accepted point exactly once through the request-local coordinate metadata.
- [x] **SUPP-02**: Eyebrow traces are independently bounded, validated as open paths, canonicalized for side and inner/outer order across orientation and mirroring, and rejected locally when malformed without substituting eye contours or synthetic proxies.
- [x] **SUPP-03**: Raw and derived eyebrow support remains package-only, request-scoped, non-Codable, non-persistent, non-networked, and absent from public API and raw diagnostics; only fixed reasons and aggregate counts may escape.

### Independent Eyebrow Geometry

- [x] **GEOM-01**: Signed eyebrow vertical position translates eligible complete brow traces up or down without moving the eyes or aliasing eye vertical position.
- [x] **GEOM-02**: Signed eyebrow thickness performs bounded trace-normal expansion or compression inside a protected brow-local strip without makeup, texture synthesis, or resource placement.
- [x] **GEOM-03**: Signed eyebrow length extends or contracts outer endpoint neighborhoods while preserving inner heads and avoiding whole-brow scaling.
- [x] **GEOM-04**: Signed overall eyebrow spacing translates complete paired brows symmetrically around the face center.
- [x] **GEOM-05**: Signed eyebrow-head spacing moves only canonical inner endpoint neighborhoods and remains distinguishable from overall spacing.
- [x] **GEOM-06**: Signed eyebrow tilt rotates each eligible brow locally around its center and preserves direction across orientation and mirroring.
- [x] **GEOM-07**: Positive-only eyebrow peak definition adjusts a bounded interior apex relative to the endpoint chord without translating the whole brow.

### Resolver and Unified Pipeline

- [x] **PIPE-01**: All seven eyebrow fields have named provider emissions, field-local eligibility, provider-empty removal, resolver/facade routing, and safe continuation of eligible sibling and non-eyebrow domains.
- [x] **PIPE-02**: Combined face, eye, eyebrow, nose, and mouth geometry converges monotonically over one exact 44-field provider-eligible retained set whose final strengths, totals, counts, scale, warnings, metrics, and unified dispatch agree.

### Public-Facade Output Evidence

- [x] **OUT-01**: `BeautyExampleRenderer` contains thirteen isolated eyebrow cases—both directions for six signed controls and one peak case—expanding the exact matrix from 59 to 72 cases without bypassing `BeautySDK`.
- [x] **OUT-02**: A bounded strict helper decodes all 72 expected portrait outputs from the sole active portrait fixture `e6.jpg`, preserves dimensions, proves brow-local visibility and protected-region locality, preserves signed directions, and distinguishes all seven semantic families; the no-face negative is verified separately.
- [x] **OUT-03**: No-face and representative missing/malformed/partial eyebrow inputs produce safe public results, while renderer/output/gallery inventories remain exact, descriptor-safe, ignored, untracked, unstaged, and disposable.

### Safety, Privacy, and Closeout

- [x] **SAFE-01**: All seven controls have evidence-backed exact caps, neutral/dead-zone behavior, correct signed or positive-only directionality, and bounded influence radii.
- [x] **SAFE-02**: No-face, missing, malformed, provider-empty, fresh, reused, stale, and valid-invalid-valid transitions degrade according to field prerequisites without stale carryover or suppression of safe siblings.
- [x] **SAFE-03**: Public/SPI, diagnostics, persistence, reflection, Demo imports, dependency, network/cloud, commercial, generated-artifact, and active-source gates fail closed with no unresolved high-severity issue.
- [x] **DOC-01**: Current owners promote exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`, mark branch-level `眉毛` implemented at SDK-core scope, and preserve v1.14-v1.16 plus UI/device/commercial/release nonclaims.

## Future Requirements

### v1.14 Local Facial Retouch

- **RET-01**: Implement local eye-fat reduction (`去脂`) with bounded under-eye eligibility and texture-preserving behavior.
- **RET-02**: Implement local eye-redness reduction (`祛红血丝`) with sclera-contained color correction.
- **RET-03**: Implement local teeth whitening (`白牙`) with teeth-contained color correction.

### v1.15 Hairline and Semantic Masking

- **SEM-01**: Approve and package a local-only, redistributable, versioned, checksum-pinned semantic-region resource with bounded output and no runtime download.
- **HAIR-01**: Implement signed hairline adjustment with mask-contained output and safe unsupported-input degradation.

### v1.16 Double-Chin and Facial-Feature Closeout

- **CHIN-01**: Implement independent basic double-chin reduction through validated local submental support.
- **CHIN-02**: Implement independently observable Pro refinement without entitlement, payment, remote inference, or aliasing the basic control.
- **CHIN-03**: Audit and close the narrow 51-row face/eye/nose/mouth/eyebrow taxonomy only when every row has current SDK behavior and evidence.

## Out of Scope

| Feature | Reason |
| --- | --- |
| SwiftUI or Demo UI changes | The user explicitly limited this sequence to SDK SPM work. |
| Eyebrow makeup, texture synthesis, generated hair, color/style assets, templates, and resource packs | v1.13 is geometry-only and must not silently become a makeup milestone. |
| `3D塑颜` and `比例` | These broader shaping groups are outside the narrow five-feature sequence. |
| Eye retouch, teeth, hairline, and double-chin implementation | Explicitly scheduled for v1.14-v1.16, not v1.13. |
| Third-party beauty SDK, cloud processing, remote model download, account, entitlement, payment, or VIP behavior | Violates the local-first SDK boundary and is unnecessary for eyebrow traces. |
| Physical-device parity, commercial visual approval, optimized profiling, packaging, shipping, or launch readiness | Separate evidence scopes; v1.13 proves SDK-core functional behavior only. |
| Tracked generated renderer/gallery images | Generated evidence remains ignored and disposable. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| BROW-01 | Phase 49 | Complete |
| BROW-02 | Phase 49 | Complete |
| SUPP-01 | Phase 49 | Complete |
| SUPP-02 | Phase 49 | Complete |
| SUPP-03 | Phase 49 | Complete |
| GEOM-01 | Phase 50 | Complete |
| GEOM-02 | Phase 50 | Complete |
| GEOM-03 | Phase 50 | Complete |
| GEOM-04 | Phase 50 | Complete |
| GEOM-05 | Phase 50 | Complete |
| GEOM-06 | Phase 50 | Complete |
| GEOM-07 | Phase 50 | Complete |
| PIPE-01 | Phase 50 | Complete |
| PIPE-02 | Phase 50 | Complete |
| OUT-01 | Phase 51 | Complete |
| OUT-02 | Phase 51 | Complete |
| OUT-03 | Phase 51 | Complete |
| SAFE-01 | Phase 52 | Complete |
| SAFE-02 | Phase 52 | Complete |
| SAFE-03 | Phase 52 | Complete |
| DOC-01 | Phase 52 | Complete |

**Coverage:**

- v1.13 requirements: 21 total
- Mapped to phases: 21
- Unmapped: 0 ✓

---
*Requirements defined: 2026-07-24*
*Last updated: 2026-07-27 after Phase 52 requirement closeout; independent v1.13 milestone audit pending*
