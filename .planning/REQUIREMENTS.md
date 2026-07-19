# Requirements: Beauty v1.11

**Defined:** 2026-07-16
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.11 Requirements

### Public Eye Contract

- [x] **EYE-01**: A host can set independent positive-only `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry` values in `0...1`, each with default `0`, finite clamping, non-finite fallback, and no forwarding alias.
- [x] **EYE-02**: A host can set independent signed `eyeTilt` in `-1...1`, with default `0`, finite clamping, non-finite fallback, and both directions preserved end to end.
- [x] **EYE-03**: Existing complete 38-field JSON and bundled presets decode all ten new values at `0`, new 48-field unequal values round-trip, existing source-style initializer calls retain neutral defaults, and the exact stored inventory is 47 numeric fields plus `filterId`.
- [x] **EYE-04**: With all ten new fields at zero, the four shipped eye fields retain their exact public values, safety caps, provider vectors, JSON behavior, and facade evidence; each new field remains independently distinguishable from every shipped and new neighbor.

### Observed Eye Support

- [x] **EYE-05**: Package-internal detection captures finite bounded left/right Vision eye-contour points and independently optional left/right pupil points for the current request, converts their face-bounds lower-left coordinates into the repository image-normalized convention, and exposes no raw points publicly, persistently, or through diagnostics.
- [x] **EYE-06**: The geometry adapter canonicalizes each observed eye into deterministic side-aware upper/lower lid, inner/outer corner, center, span, tilt, and optional pupil support, rejecting non-finite, out-of-bounds, oversized, degenerate, duplicate-only, side-inverted, or implausible structures before provider use.
- [x] **EYE-07**: Missing or implausible pupil support, including blink-like outliers, removes only `pupilSize` and `gazeCorrection`; valid contour-dependent shipped and new eye siblings remain eligible, while missing either required eye contour retains the established complete eye-domain skip.

### Independent Eye Geometry

- [x] **EYE-08**: `eyeHeight` and `eyeLength` produce bounded vertical-aperture and horizontal-span vectors respectively on both eyes, remain distinct from radial `eyeSize`, signed `eyeDistance`, and each other, and preserve stable centers unless their own semantics require local movement.
- [x] **EYE-09**: `upperEyelidLift` and `lowerEyelidDrop` produce bounded upper-lid-only lift and lower-lid-only drop vectors respectively, preserve opposite lids and corners outside their local falloff, and remain distinct from `eyeYPosition`, `eyeHeight`, and `eyeTailLift`.
- [x] **EYE-10**: Signed `eyeTilt` rotates both observed eye contours around stable per-eye centers with opposite tangential motion for positive and negative values, bounded radius error, and no alias to `eyeTailLift` or vertical position.
- [x] **EYE-11**: `innerCornerOpen` and `outerCornerOpen` use side-aware nasal and temporal corner support respectively, emit bounded local opening vectors on both eyes, and remain distinct from `eyeLength`, `eyeTailLift`, and each other.
- [x] **EYE-12**: `pupilSize` produces bounded pupil-local radial geometry from a validated pupil center and its containing eye contour, preserves the surrounding eye contour outside its local falloff, and never borrows `eyeSize` evidence.
- [x] **EYE-13**: `gazeCorrection` reduces a validated pupil-to-neutral-center offset by a bounded monotonic fraction, emits no work inside a neutral dead zone or for implausible support, and does not expose or accept a manual gaze direction.
- [x] **EYE-14**: `eyeSymmetry` reduces only measured paired-eye center, aperture, span, or tilt differences toward a conservative midpoint, emits no work for already-neutral or implausible pairs, and never mirrors one eye or replaces identity-specific geometry.
- [x] **EYE-15**: Provider-owned named emissions represent all fourteen eye geometry fields independently; preflight- or final-scale-ineligible work becomes zero before totals, counts, warnings, metrics, domains, and dispatch, while valid eye siblings continue and any isolated new field triggers the existing public-facade geometry route.

### Public-Facade Output Evidence

- [x] **EYE-16**: `BeautyExampleRenderer` includes one isolated public-facade case for each positive-only new field plus positive and negative `eyeTilt` cases, expanding the current 44-case matrix to exactly 55 cases and 385 outputs if the seven-fixture inventory is unchanged.
- [x] **EYE-17**: A v1.11-owned strict bounded output helper derives the complete case/fixture matrix, decodes every expected non-empty same-dimension PNG, proves contour controls visible on every eligible portrait, proves both tilt directions, and distinguishes lid/corner/pupil/correction/symmetry families from their nearest neighbors in fixed eye-local regions without treating field-local safe no-ops as success.
- [x] **EYE-18**: The output evidence inventories contour and pupil/correction eligibility explicitly, proves automatic correction reduces measured deviation on at least one eligible fixture and safely no-ops on neutral/ineligible fixtures, preserves representative no-face extent/no-op behavior, publishes a duplicate-free ignored gallery, and tracks no generated output or gallery image.

### Safety and Geometry-Slice Closeout

- [x] **EYE-19**: Evidence-backed exact natural caps, neutral dead zones, capped counts, normalization, warnings, metrics, and signed/positive-only directionality are locked for all ten new fields without changing their public ranges.
- [x] **EYE-20**: No-face, missing either eye contour, missing/implausible pupil, malformed support, provider-empty work, reused geometry, stale geometry, and fresh/reused/stale transitions apply according to each dependency across all fourteen eye fields; the established reused/stale complete-domain eye skip remains explicit, safe non-eye domains continue, and diagnostics remain redacted.
- [x] **EYE-21**: Combined face, fourteen-field eye, six-field nose, and eight-field mouth geometry uses one provider-eligible retained baseline, weakens every active field exactly once, converges through at most twenty-eight eye/nose/mouth mask removals, preserves signed directions, and excludes unsupported work from totals, counts, warnings, metrics, domains, and dispatch.
- [x] **EYE-22**: Raw eye/pupil geometry, public support types, persistent landmark state, internal Demo/renderer imports, network/cloud, commercial paths, new dependencies, compatibility drift, unclassified active-source matches, and generated artifacts remain fail-closed through self-tested active-source gates and the full SDK suite.
- [x] **EYE-23**: Exactly `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称` are promoted only after their own contract, support, provider, facade-output, safety, degradation, and boundary evidence passes; `去脂` and `祛红血丝` remain future and branch-level `眼睛` remains partial.
- [x] **DOC-01**: Blueprint, root contracts, eye-branch documentation, example validation, `QUALITY_SCORE.md`, `PROJECT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `STATE.md`, `PLANS.md`, verification, validation, security, review, and milestone audit agree with observed v1.11 evidence and conservative non-claims.

## Future Requirements

### Eye Retouch and Extended Direction Controls

- **EYE-F01**: Define eye-fat region ownership, segmentation/retouch behavior, containment, caps, and privacy evidence before promoting `去脂`.
- **EYE-F02**: Define redness-region ownership, local color/vascular retouch behavior, containment, caps, and privacy evidence before promoting `祛红血丝`.
- **EYE-F03**: Add manual horizontal/vertical gaze-redirection controls only after explicit product demand, stronger iris-region support, and separate visual-risk evidence.
- **EYE-F04**: Add per-eye manual asymmetry controls only after explicit product demand; v1.11 symmetry remains automatic bounded reduction of measured differences.

## Out of Scope

| Feature | Reason |
| --- | --- |
| `去脂` | Local texture/segmentation retouch is not eye geometry and needs separate ownership. |
| `祛红血丝` | Eye-region color/vascular retouch needs separate containment and safety evidence. |
| Treating shipped `eyeSize`, `eyeDistance`, `eyeYPosition`, or `eyeTailLift` as evidence for a new row | Every new control requires independent public, provider, and output evidence. |
| Fabricated proxy-only gaze or symmetry correction | Automatic correction must reduce an observed private deviation rather than synthesize one. |
| Public or persisted eye-contour/pupil geometry | The SDK remains scalar-public and local-first; biometric-adjacent geometry is package-internal and request-scoped. |
| New SwiftUI Demo controls or screens | v1.11 is SDK-core only; Demo wiring is separate UI/product scope. |
| New package target, render pass, third-party dependency, downloadable model, or public geometry type | The milestone must reuse current module seams, Vision request, and unified local warp. |
| Network/cloud, account, payment, VIP, entitlement, or commercial execution paths | These violate the local-first SDK geometry boundary. |
| Tracked generated PNG baselines | Renderer outputs and galleries remain ignored local evidence under repository media policy. |
| ABI compatibility for already compiled binary clients | v1.11 preserves source rebuild and JSON compatibility; binary distribution remains separately scoped. |
| Device parity, commercial visual approval, broad Meitu parity, optimized performance certification, packaging, shipping, or launch readiness | These require separate setup-specific or commercial evidence. |
| Rewriting archived v1.6 eye evidence | Historical four-field eye evidence remains immutable and cannot prove the ten new controls. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| EYE-01 | Phase 41 | Complete |
| EYE-02 | Phase 41 | Complete |
| EYE-03 | Phase 41 | Complete |
| EYE-04 | Phase 41 | Complete |
| EYE-05 | Phase 41 | Complete |
| EYE-06 | Phase 41 | Complete |
| EYE-07 | Phase 41 | Complete |
| EYE-08 | Phase 42 | Complete |
| EYE-09 | Phase 42 | Complete |
| EYE-10 | Phase 42 | Complete |
| EYE-11 | Phase 42 | Complete |
| EYE-12 | Phase 42 | Complete |
| EYE-13 | Phase 42 | Complete |
| EYE-14 | Phase 42 | Complete |
| EYE-15 | Phase 42 | Complete |
| EYE-16 | Phase 43 | Complete |
| EYE-17 | Phase 43 | Complete |
| EYE-18 | Phase 43 | Complete |
| EYE-19 | Phase 44 | Complete |
| EYE-20 | Phase 44 | Complete |
| EYE-21 | Phase 44 | Complete |
| EYE-22 | Phase 44 | Complete |
| EYE-23 | Phase 44 | Complete |
| DOC-01 | Phase 44 | Complete |

**Coverage:**

- v1.11 requirements: 24 total
- Mapped to phases: 24
- Unmapped: 0
- Duplicate mappings: 0
- Coverage: 100%

---
*Requirements defined: 2026-07-16*
*Last updated: 2026-07-19 after independent v1.11 milestone audit*
