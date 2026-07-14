# Requirements: Beauty v1.10

**Defined:** 2026-07-14
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.10 Requirements

### Public Mouth Contract

- [ ] **MOUTH-01**: A host can set independent signed `mouthYPosition`, `mouthTilt`, and `mouthXPosition` public parameters in `-1...1`, each with default `0`, finite clamping, non-finite fallback, and no alias to a shipped mouth field.
- [ ] **MOUTH-02**: A host can set independent positive-only `lipPeakDefinition` and `lipPlump` public parameters in `0...1`, each with default `0`, finite clamping, non-finite fallback, and no alias to `mouthSize`, `mouthWidth`, `smile`, or `lipColor`.
- [ ] **MOUTH-03**: Existing 33-field JSON and bundled presets decode all five new fields at `0`, new 38-field values round-trip, existing source-style initializer calls retain neutral defaults, and the exact stored inventory is 37 numeric fields plus `filterId`.

### Lip Support and Independent Geometry

- [ ] **MOUTH-04**: Package-internal detection records Vision `innerLips` availability beside `outerLips`, and the geometry adapter creates finite, bounded, deterministic whole-mouth, upper-lip, lower-lip, and inner-lip supports without exposing raw geometry publicly or in diagnostics.
- [ ] **MOUTH-05**: `mouthYPosition`, `mouthTilt`, and `mouthXPosition` produce bounded whole-mouth vertical translation, center rotation, and horizontal translation respectively, preserve both signed directions, and remain mutually distinct.
- [ ] **MOUTH-06**: `lipPeakDefinition` produces bounded local upper-lip peak shaping from explicit upper/inner support and remains distinct from `smile`, `mouthSize`, and whole-mouth transforms.
- [ ] **MOUTH-07**: `lipPlump` produces bounded local upper/lower lip thickening from explicit outer/inner support and remains distinct from `lipColor`, `mouthSize`, and `lipPeakDefinition`.
- [ ] **MOUTH-08**: Provider-owned emissions represent all eight mouth geometry fields independently; missing, malformed, duplicate-only, non-finite, displacement-ineligible, or final-scale-empty support zeros only dependent fields while valid mouth siblings remain eligible and final effective strengths equal final emissions.

### Public-Facade Output Evidence

- [ ] **MOUTH-09**: `BeautyExampleRenderer` includes positive/negative isolated public-facade cases for each new signed field plus isolated `lipPeakDefinition` and `lipPlump` cases, expanding the current 36-case × 7-fixture matrix to 44 cases and 308 ignored outputs if fixture inventory is unchanged.
- [ ] **MOUTH-10**: A v1.10-owned strict output helper derives the complete case/fixture matrix, verifies every expected PNG is decodable, non-empty, and same-dimension, proves all usable portraits differ from baseline above the watermark, preserves each signed direction, and distinguishes peak/plump from their nearest shipped controls in the intended mouth ROI.
- [ ] **MOUTH-11**: Representative no-face outputs preserve extent and degrade safely, gallery/output routing remains an exact ignored bijection with renderer cases, and no generated output or gallery PNG is tracked.

### Safety and Geometry-Slice Closeout

- [ ] **MOUTH-12**: Evidence-backed exact natural caps, capped counts, normalization, warnings, metrics, and directionality are locked for all five new fields without changing their public signed or positive-only ranges.
- [ ] **MOUTH-13**: No-face, missing outer lips, missing inner lips, stale geometry, reused geometry at exact `0.5`, provider-empty fallback, and safe-domain continuation apply per support dependency across all eight mouth geometry fields while `lipColor` retains its independent color-domain policy and diagnostics remain redacted.
- [ ] **MOUTH-14**: Combined face, eye, six-field nose, and eight-field mouth geometry uses one provider-eligible retained baseline, weakens every active field exactly once, converges through at most fourteen nose/mouth mask removals, preserves every signed direction, and excludes unsupported work from totals, counts, warnings, metrics, and dispatch.
- [ ] **MOUTH-15**: Raw geometry, public support types, internal Demo/renderer imports, network/cloud, commercial paths, new dependencies, compatibility drift, unclassified source matches, and generated artifacts remain fail-closed through active-source scans and the full SDK suite.
- [ ] **MOUTH-16**: Exactly `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇` are promoted only after their own contract, support, provider, facade-output, safety, degradation, and boundary evidence passes; `白牙` remains future and branch-level `嘴唇` remains partial.
- [ ] **DOC-01**: Blueprint, root contracts, branch documentation, example validation, `QUALITY_SCORE.md`, `PROJECT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `STATE.md`, `PLANS.md`, verification, validation, security, and milestone audit agree with observed v1.10 evidence and conservative non-claims.

## Future Requirements

### Teeth and Extended Lip Semantics

- **MOUTH-F01**: Define teeth-region ownership, segmentation, local whitening/retouch behavior, containment, caps, and privacy evidence before promoting `白牙`.
- **MOUTH-F02**: Add separately adjustable upper- and lower-lip thickness only after explicit product demand and independent bidirectional support/output evidence.
- **MOUTH-F03**: Refine the package-internal lip landmark model only if the established outer/inner availability seam cannot reliably support the frozen five-field contract.

## Out of Scope

| Feature | Reason |
| --- | --- |
| `白牙` or `teethWhitening` | Teeth segmentation and color/retouch ownership are not mouth warp geometry and require a separate evidence slice. |
| Whole branch-level `嘴唇` completion | `白牙` remains unresolved even when the geometry subset is complete. |
| Treating `lipColor`, `mouthSize`, `mouthWidth`, or `smile` as evidence for a new row | Every new geometry control needs independent public, provider, and output evidence. |
| New SwiftUI Demo controls or screens | v1.10 is SDK-core only; Demo wiring is separate UI/product scope. |
| New package target, render pass, third-party dependency, or public geometry type | The controls must reuse existing module seams and unified local warp. |
| Network/cloud, account, payment, VIP, entitlement, or commercial execution paths | These violate the local-first SDK geometry boundary. |
| Tracked generated PNG baselines | Renderer outputs and galleries remain ignored local evidence under repository media policy. |
| ABI compatibility for already compiled binary clients | v1.10 preserves source rebuild and JSON compatibility; binary distribution remains separately scoped. |
| Device parity, commercial visual approval, broad Meitu parity, optimized performance certification, packaging, shipping, or launch readiness | These require separate setup-specific or commercial evidence. |
| Rewriting archived v1.8 mouth evidence | Historical four-field mouth/lip evidence remains immutable and cannot prove the five new fields. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| MOUTH-01 | Phase 38 | Pending |
| MOUTH-02 | Phase 38 | Pending |
| MOUTH-03 | Phase 38 | Pending |
| MOUTH-04 | Phase 38 | Pending |
| MOUTH-05 | Phase 38 | Pending |
| MOUTH-06 | Phase 38 | Pending |
| MOUTH-07 | Phase 38 | Pending |
| MOUTH-08 | Phase 38 | Pending |
| MOUTH-09 | Phase 39 | Pending |
| MOUTH-10 | Phase 39 | Pending |
| MOUTH-11 | Phase 39 | Pending |
| MOUTH-12 | Phase 40 | Pending |
| MOUTH-13 | Phase 40 | Pending |
| MOUTH-14 | Phase 40 | Pending |
| MOUTH-15 | Phase 40 | Pending |
| MOUTH-16 | Phase 40 | Pending |
| DOC-01 | Phase 40 | Pending |

**Coverage:**

- v1.10 requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0
- Duplicate mappings: 0
- Coverage: 100%

---
*Requirements defined: 2026-07-14*
*Last updated: 2026-07-14 after auto-mode scope confirmation*
