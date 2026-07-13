# Requirements: Beauty v1.9

**Defined:** 2026-07-13
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.9 Requirements

### Public Nose Contract

- [ ] **NOSE-01**: A host can set independent positive-only `noseRootNarrowing` and `noseTipLift` public parameters in `0...1`, with default `0`, finite clamping, non-finite fallback, and no alias to an existing nose field.
- [ ] **NOSE-02**: Existing 31-field JSON and bundled presets decode with both new fields at `0`, new 33-field values round-trip, and existing source-style initializer calls retain neutral defaults.
- [ ] **NOSE-03**: Either new field independently triggers the established face-geometry route and propagates through effective strengths, activation, metrics, degradation, conflict handling, and the existing public facade without exposing raw geometry.

### Independent Nose Geometry

- [ ] **NOSE-04**: `noseRootNarrowing` produces bounded symmetric horizontal contraction only in a deterministic upper-root subset, preserves vertical coordinates, and is observably distinct from `noseBridge`.
- [ ] **NOSE-05**: `noseTipLift` produces bounded upward motion only in a deterministic lower-tip subset, preserves horizontal coordinates, and is observably distinct from both directions of signed `noseTipSize`.
- [ ] **NOSE-06**: Missing or insufficient upper-root/lower-tip geometry fails closed without substituting legacy bridge or tip-size control points, while valid provider output remains deterministic, finite, bounded, and non-empty.

### Public-Facade Output Evidence

- [ ] **NOSE-07**: `BeautyExampleRenderer` includes exactly one isolated public-facade case for each new field, expanding the current 34-case × 7-fixture matrix to 36 cases and 252 ignored outputs if the fixture inventory is unchanged.
- [ ] **NOSE-08**: A v1.9-owned output helper verifies every expected PNG is decodable, non-empty, and same-dimension; both new cases differ from baseline on all usable portraits above the watermark; and each differs from its nearest legacy nose effect in the intended nose ROI.
- [ ] **NOSE-09**: Representative no-face outputs preserve extent and degrade safely, gallery/output routing remains ignored, and no generated output or gallery PNG is tracked.

### Safety and Branch Closeout

- [ ] **NOSE-10**: Evidence-backed exact natural caps, capped counts, normalization, warnings, and metrics are locked for both new fields without changing the public `0...1` contract.
- [ ] **NOSE-11**: No-face, missing nose landmarks, stale geometry, reused geometry at exact `0.5`, provider-empty fallback, and safe-domain continuation apply consistently to all six nose fields with redacted diagnostics.
- [ ] **NOSE-12**: Combined face, eye, mouth, and six-field nose geometry weakens each active field exactly once, preserves every shipped signed direction, and does not regress previously completed face/eye/nose/mouth behavior.
- [ ] **NOSE-13**: Raw geometry, internal Demo/renderer imports, network/cloud, commercial paths, public geometry, dependencies, compatibility boundaries, and generated artifacts remain fail-closed through active-source scans and the full SDK suite.
- [ ] **NOSE-14**: `山根` and `提升` are promoted only after their own contract, provider, facade-output, safety, degradation, and boundary evidence passes; branch-level `鼻子` is then marked complete for SDK-core scope without borrowing archived v1.7 evidence.
- [ ] **DOC-01**: Blueprint, root contracts, branch documentation, example validation, `QUALITY_SCORE.md`, `PROJECT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `STATE.md`, `PLANS.md`, verification, validation, security, and milestone audit agree with observed v1.9 evidence and conservative non-claims.

## Future Requirements

### Extended Nose Semantics

- **NOSE-F01**: Support root height/depth, projection, or relighting only through a separately designed capability with appropriate geometry or render-domain evidence.
- **NOSE-F02**: Add signed root widening or downward tip movement only after explicit product demand and bidirectional safety/output evidence.
- **NOSE-F03**: Refine the internal nose landmark model only if the current package-only geometry cannot reliably isolate the frozen upper-root and lower-tip regions.

## Out of Scope

| Feature | Reason |
| --- | --- |
| New SwiftUI Demo controls or screens | v1.9 closes the SDK-core branch; Demo wiring is a separate product/UI scope. |
| New package target, render pass, external dependency, or public geometry type | Both tools must reuse the existing public model, resolver, nose provider, and unified local warp. |
| Network/cloud, account, payment, VIP, entitlement, or commercial execution paths | These violate the local-first SDK branch boundary. |
| Tracked generated PNG baselines | Renderer outputs and galleries remain ignored local evidence. |
| ABI compatibility for already compiled binary clients | v1.9 preserves source rebuild and JSON compatibility; binary distribution remains separately scoped. |
| Device parity, commercial visual approval, broad Meitu parity, packaging, or launch readiness | These require separate setup-specific or commercial evidence. |
| Rewriting archived v1.7 evidence | Historical four-field nose evidence remains immutable and cannot prove the two new fields. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |

**Coverage:**
- v1.9 requirements: 15 total
- Mapped to phases: 0
- Unmapped: 15 ⚠️

---
*Requirements defined: 2026-07-13*
*Last updated: 2026-07-13 after initial v1.9 definition*
