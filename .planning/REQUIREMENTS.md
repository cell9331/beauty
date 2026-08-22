# Requirements: Beauty v1.18

**Defined:** 2026-08-22
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## Standing Project Validation Requirements

These requirements apply to all current and future SDK milestones. They are
project policy rather than additional v1.18 traceability rows, so the active
milestone count below remains 18.

| ID | Requirement |
| --- | --- |
| PROJECT-VALIDATION-01 | Physical iPhone testing is optional post-SDK user evaluation and must not be a default milestone requirement, dependency, checkpoint, completion gate, or blocker. It becomes mandatory only through an explicit later user decision. |
| PROJECT-VALIDATION-02 | Milestone authority is deterministic SwiftPM coverage plus SDK-owned scripts with nonzero execution, zero failures, zero unexpected skips, and fail-closed handling of malformed or incomplete evidence. |
| PROJECT-VALIDATION-03 | Image-producing behavior is accepted only when automation evaluates real input/output pixels and metadata against the owning contract, including applicable dimensions/extent, orientation/mirroring, color space, alpha, neutral identity, intended-region movement, protected-region preservation, bounded tolerance, determinism, and typed failure. Process success alone is insufficient. |
| PROJECT-VALIDATION-04 | Generated in-memory fixtures are the default repeatable mechanism. An algorithm owner may separately require rights-approved local positive/negative fixtures, but those remain script-driven, private, and distinct from physical-device validation. |
| PROJECT-VALIDATION-05 | User device feedback received after SDK completion is supplemental evidence: actionable findings enter `PLANS.md` and should gain an automated regression where reproducible; absence of that feedback does not stop the current plan or later milestone work. |
| PROJECT-VALIDATION-06 | Without separately authorized hardware/product evidence, automated SDK completion makes no device performance, thermal, battery, endurance, commercial visual-quality, packaging, shipping, launch, or release-readiness claim. This is a nonclaim boundary, not a blocker. |
| PROJECT-VALIDATION-07 | Durable evidence remains aggregate and privacy-safe: do not persist raw inputs/outputs, masks, landmarks, private fixture locators, device photos, or unredacted feedback payloads. |

## v1.18 Requirements

### Product Semantics

- [ ] **SEM-01**: An SDK integrator can request a cosmetic effect defined only as visually reducing upper-eyelid fullness, without inferring physical fat, anatomy, health, or a surgical outcome.
- [ ] **SEM-02**: The named effect cannot be satisfied by smoothing, whitening, eye enlargement, brow movement, crease invention, upper-eyelid lift, or geometric warp proxies.

### Evidence and Rights

- [ ] **EVID-01**: The milestone evaluates the effect through a complete rights-approved local bundle of genuine positives, negatives, ambiguous cases, pose/occlusion stress cases, identity diversity, and protected-structure cases with a fail-closed provenance manifest.
- [ ] **EVID-02**: Efficacy and safety metrics, thresholds, and blinded original-detail review rules are frozen before final candidate evaluation, and persistent outputs contain only opaque fixture IDs, hashes, aggregate metrics, normalized reasons, and decisions.

### Per-Eye Support Ownership

- [ ] **SUP-01**: A still-image request performs one shared Vision observation and uses eye/brow landmarks only for conservative envelopes and pose guards; editable fullness support requires a separately approved semantic owner.
- [ ] **SUP-02**: Left and right eyes receive independent support, confidence, reason, mask, and failure outcomes so an unsupported eye is source-exact and one eye cannot authorize, suppress, or modify the other.

### Candidate Algorithms

- [ ] **ALG-01**: The deterministic baseline reduces only bounded low-frequency fullness cues inside approved per-eye support while carrying original high-frequency detail and preserving geometry and alpha exactly.
- [ ] **ALG-02**: An optional learned candidate may emit only bounded additive color maps, must have approved model/data/redistribution rights, and is eligible only if it materially outperforms the deterministic baseline without weakening any safety gate; generation, inpainting, and warp candidates remain prohibited.

### Safety and Image Contract

- [ ] **SAFE-01**: Composition changes only pixels owned by one approved request-local per-eye mask, keeps every pixel outside support source-exact, and resolves local-mask collisions to the immutable source pixel.
- [ ] **SAFE-02**: The selected candidate preserves protected eye, lash, crease, and brow geometry plus source skin texture within frozen automated and blinded-review tolerances.
- [ ] **SAFE-03**: The complete route preserves canonical extent, orientation/mirroring, named color space, alpha, finite bounded math, deterministic repeated output, request-local ownership, and typed fail-closed behavior.

### Genuine Quality Gate

- [ ] **QUAL-01**: Genuine positive cases pass the frozen automated criteria and blinded original-detail review by demonstrating reduced upper-eyelid fullness without a prohibited proxy or protected-structure regression.
- [ ] **QUAL-02**: Genuine negative, ambiguous, unsupported, occluded, closed/blinking, and extreme-pose cases are source-exact or remain within a predeclared no-op tolerance, and generated adversarial fixtures prove containment and metadata mechanics independently.

### Compatibility and Backend Contract

- [ ] **COMPAT-01**: Before promotion, public compatibility remains exactly 61 `BeautyParameters` fields, five neutral presets, and 74 renderer cases, with no placeholder field, route, preset, or public/SPI activation that implies the effect exists.
- [ ] **COMPAT-02**: If and only if every promotion gate passes, the SDK appends exactly one default-zero public parameter and one renderer case for an exact 62-field/five-preset/75-case inventory while preserving Codable migration, normalization, reset, equality, neutral identity, and legacy call behavior.
- [ ] **BACKEND-01**: The CPU implementation remains the authoritative oracle and the selected GPU route satisfies the existing output contract or typed availability failure without modifying retained `Warp.metal`, adding a Metal/GPU API/backend, or claiming device performance.

### Conditional Promotion and Documentation

- [ ] **PROMOTE-01**: A reproducible aggregate decision promotes the public field and route only when every semantic, rights, support, efficacy, safety, privacy, compatibility, and backend gate passes; any failed gate leaves the field and route exactly absent and keeps `eyes` partial.
- [ ] **DOCS-01**: Root contract owners, `PLANS.md`, quality evidence, public SDK guidance, and `docs/SDK_EFFECT_TAXONOMY.md` record the selected branch and preserve explicit nonclaims for UI/Demo, realtime/video, device, commercial quality, packaging, shipping, launch, and release readiness.

## Future Requirements

### Later Input and Runtime Expansion

- **INPUT-FUTURE-01**: Transparent-input support is designed and validated through a separately scoped canonical-input milestone.
- **INPUT-FUTURE-02**: HDR, wide-gamut preservation beyond the current named-sRGB contract, and gain-map behavior receive independent image-contract evidence.
- **RUNTIME-FUTURE-01**: Realtime/pixel-buffer and video support receive independent latency, temporal stability, memory, failure, and privacy requirements.

### Later Product and Device Evidence

- **PRODUCT-FUTURE-01**: UI/Demo controls and interaction behavior are considered only if the SDK-only product boundary is explicitly changed.
- **PRODUCT-FUTURE-02**: Device performance, thermal, battery, long-run stability, commercial visual approval, packaging, distribution, shipping, launch, and release readiness require separately authorized product/hardware evidence.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Medical fat estimation, anatomy diagnosis, surgical simulation, or clinical claims | v1.18 owns a bounded cosmetic visual effect only. |
| Eye enlargement, upper-eyelid lift, crease invention, brow movement, whitening, smoothing, or warp aliases | They change different visual variables and cannot satisfy the named effect. |
| Full-pixel generation, inpainting, cloud inference, network models, or remote assets | They violate original-pixel ownership, local-first privacy, and deterministic distribution boundaries. |
| Public activation before the genuine gate passes | The user selected conditional productization; exact absence is the required failed-gate result. |
| New Metal/GPU API or backend, retained `Warp.metal` changes, or a new unrelated algorithm | v1.18 extends the existing still-image local-retouch path only. |
| SwiftUI screens, Demo behavior, application lifecycle, or UI automation | The repository remains an SDK-only Swift package and legacy UI stays archive-only. |
| Realtime/video, transparent input, HDR/gain maps, device validation, performance budgets, commercial approval, packaging, shipping, launch, or release readiness | Each requires independent contracts and evidence and is not implied by SDK automation. |
| Tracked fixture media, raw inputs/outputs, masks, landmarks, private paths, or biometric-like descriptors | Private local evidence must remain request-local or outside persistent repository artifacts. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| SEM-01 | Phase 75 | Complete — frozen cosmetic-only semantic contract and independent proxy mutations |
| SEM-02 | Phase 75 | Complete — seven prohibited proxies independently fail closed |
| EVID-01 | Phase 75 | Complete — rights/category-complete manifest admission is fail closed; no private bundle persisted |
| EVID-02 | Phase 75 | Complete — frozen rubric/blinded-review schema and aggregate-only evaluator output |
| SUP-01 | Phase 76 | Complete — one shared mapped observation, package-only semantic approval, and CoordinateMapper-only conversion |
| SUP-02 | Phase 76 | Complete — independent typed per-eye outcomes, source-exact rejection, and overlap-to-source composition |
| ALG-01 | Phase 77 | Pending |
| SAFE-01 | Phase 77 | Pending |
| SAFE-02 | Phase 77 | Pending |
| ALG-02 | Phase 78 | Pending |
| QUAL-01 | Phase 78 | Pending |
| QUAL-02 | Phase 78 | Pending |
| SAFE-03 | Phase 79 | Pending |
| COMPAT-01 | Phase 79 | Pending |
| COMPAT-02 | Phase 79 | Pending |
| BACKEND-01 | Phase 79 | Pending |
| PROMOTE-01 | Phase 79 | Pending |
| DOCS-01 | Phase 79 | Pending |

**Coverage:**

- v1.18 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0
- Duplicate mappings: 0
- Coverage: 100%

---
*Requirements defined: 2026-08-22*
*Last updated: 2026-08-22 after Phase 76 support ownership verification*
