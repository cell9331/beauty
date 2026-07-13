# Feature Research

**Domain:** Remaining nose tools (`山根` and `提升`) and branch closeout for a local-first iOS beauty SDK.
**Researched:** 2026-07-13
**Confidence:** HIGH for repository scope, compatibility, safety, and evidence requirements; MEDIUM for the final natural caps and fixture thresholds until the two new facade cases are rendered.

## Recommended Independent Semantics

The two remaining labels need new public fields. Neither is an alias for the four shipped nose fields.

| Reference row | Recommended public field | Public range / default | Observable geometry contract | Explicit non-equivalence |
| --- | --- | --- | --- | --- |
| `山根` | `noseRootNarrowing` | Positive-only `[0, 1]`; default `0` | Symmetrically contracts only the uppermost nasal-root band toward the face/nose centerline. Horizontal displacement is equal and opposite on the two sides; vertical position and the lower bridge, wings, and tip remain unchanged. This is a 2D apparent-root-definition control, not a claim of true depth or lighting reconstruction. | Not `noseBridge`: shipped `noseBridge` centers the broader upper bridge region. Root evidence must use a smaller, independently selected top-root subset and must produce a distinguishable control-point/output footprint. |
| `提升` | `noseLift` | Positive-only `[0, 1]`; default `0` | Moves the lower nose/tip support region upward in image-normalized coordinates as a locally blended translation. It preserves horizontal coordinates and approximate lower-nose width, so it changes vertical placement without scaling the tip. | Not signed `noseTipSize`: shipped tip size moves lower points radially toward/away from the nose center and can change both axes. Lift is one-way upward translation, must not narrow wings, and must not reuse either tip-size direction as evidence. |

These names state the controllable 2D behavior rather than importing a competitor label. `noseRootHeight` is not recommended for the current renderer because a 2D warp cannot establish physical nasal height; `noseRoot` alone is too ambiguous to be a stable host-facing contract. If implementation cannot select a genuinely localized root subset from current internal geometry, `山根` must remain partial rather than falling back to `noseBridge`.

Both fields should follow the existing public compatibility convention: finite values clamp to their declared unit range, all non-finite values normalize to `0`, `0` is a true no-op, initializers default to `0`, and decoding older JSON with either key absent yields `0`. Adding them expands the public numeric inventory from 31 to 33 fields; it must not reinterpret or rename any shipped field.

## Feature Landscape

### Table Stakes (Milestone Completion Requires These)

| Feature | Why Expected | Complexity | Notes |
| --- | --- | --- | --- |
| Independent public parameter contracts | The milestone exists to resolve two rows that v1.7 deliberately left unsupported. A host must be able to request either effect without changing `noseBridge` or `noseTipSize`. | HIGH | Add `noseRootNarrowing` and `noseLift` as distinct `Codable`, `Equatable`, `Sendable` fields with unit normalization, no-op defaults, and missing-key decode compatibility. |
| Provider-level spatial separation | A new key is not an independent feature if it emits the same control points as an existing key. | HIGH | Root uses only a top-root subset and horizontal symmetric contraction. Lift uses the lower nose/tip subset and vertical-only upward translation. Lock source region, axis, symmetry, extent, and nonzero direction in tests. |
| Public-facade single-parameter outputs | Ledger promotion requires visible results through `BeautySDK`, not provider-only or Demo-only proof. | MEDIUM | Add exactly one isolated max-safe renderer case per new positive-only field. Each case must set only its new public parameter and import only `BeautySDK`. |
| Independence comparisons | Baseline difference alone could hide an alias or accidental reuse of shipped behavior. | HIGH | Root must differ from both baseline and `noseBridge_0p30`; lift must differ from baseline and both signed `noseTipSize` outputs. Use a nose-centered ROI above the watermark plus provider axis/region assertions. |
| Deterministic ignored matrix evidence | The eye, nose, and mouth milestones established decodable, non-empty, same-dimension, portrait-difference, no-face, gallery, and artifact-containment gates. | MEDIUM | The current renderer has 34 cases over seven fixtures. Two cases imply 36 cases and 252 outputs if those inventories remain unchanged. Derive counts from the actual lists; likely new portrait comparisons are 12/12 with the current six usable portraits. |
| Exact natural caps and normalization | Unit public values must not turn into unbounded facial deformation. | MEDIUM | Choose conservative caps only after fixture calibration; a starting hypothesis no greater than `0.25` per new field is reasonable, but research does not promote that hypothesis to contract. Tests must lock the selected exact caps and capped-count metrics. |
| Nose freshness and missing-input degradation | All nose tools consume face-derived geometry and must remain safe for no-face, missing-nose, reused, and stale states. | HIGH | Missing/no-face/stale must skip `.nose` and zero all six effective nose strengths. Reused geometry keeps the established non-eye `0.5` scale for both new fields. Independent safe domains continue. |
| Six-field combined weakening | Adding fields outside the conflict budget would permit stronger aggregate warps than the shipped naturalness contract. | HIGH | Include both new magnitudes in total load, nonzero counts, zeroing helpers, reuse scaling, and conflict weakening alongside the four shipped nose fields. Positive-only direction must remain positive after scaling. |
| Redacted diagnostics and public boundary containment | Completion cannot leak raw biometric geometry or internal targets. | MEDIUM | Warnings and metrics remain categorical/count-only: no points, rectangles, observation dumps, image bytes, paths, or framework errors. Demo and renderer stay facade-only; no dependency/network/commercial path is added. |
| Atomic two-row and branch promotion | Branch-level `鼻子` becomes complete only when every listed second-level row has independent evidence and every owner agrees. | LOW | Promote `山根` and `提升` only after output and safety gates pass, then promote branch-level `鼻子`. Preserve the four shipped rows and their archived v1.7 evidence unchanged. |

### Differentiators (Aligned With Core Value)

| Feature | Value Proposition | Complexity | Notes |
| --- | --- | --- | --- |
| Semantically orthogonal nose controls | Host apps can combine root definition, bridge shaping, tip size, lift, wing slim, and overall slim without duplicate sliders controlling the same warp. | HIGH | Orthogonality is proved by affected region and displacement axis, not merely by public names. |
| Compatibility-safe public inventory growth | Existing presets and JSON payloads continue producing exactly their prior behavior while new payloads gain two opt-in controls. | MEDIUM | Missing keys decode to zero; default construction stays a no-op; no existing coding key changes meaning. |
| Conservative failure isolation | Unusable nose geometry disables nose work while skin, color, filter, and independently usable geometry domains can continue. | HIGH | Preserve the shipped warning/metric and safe-domain-continuation pattern across all six nose strengths. |
| Evidence-backed branch closeout | The feature ledger becomes a trustworthy capability contract rather than a label checklist. | LOW | Pair black-box facade pixels with provider/resolver semantics, safety scans, and exact documentation guards before changing status. |

### Anti-Features (Explicitly Excluded)

| Feature | Why Requested | Why Problematic | Alternative |
| --- | --- | --- | --- |
| Alias `山根` to `noseBridge` | Reusing shipped code looks fast and the regions are adjacent. | v1.7 explicitly assigns `noseBridge` evidence to `鼻梁`; an alias would erase the product distinction and double-count one output path. | Add a localized root parameter and prove a distinct source region/output, or leave `山根` partial. |
| Implement `提升` with positive `noseTipSize` | The current positive tip warp already moves some lower points toward the center. | Radial scaling changes horizontal width as well as vertical position and is bidirectional size behavior, not vertical lift. | Add vertical-only `noseLift` and compare it directly with both tip-size directions. |
| Claim physical 3D height from a 2D warp | “山根变高” is familiar consumer language. | Current geometry/rendering has no depth, normals, relighting, or 3D face model; the claim would exceed observable evidence. | Expose localized 2D root narrowing/definition and state the visual proxy honestly. |
| Give either new field signed semantics without a product need | Bidirectional controls appear more flexible. | The two labels describe enhancements, while negative root widening or nose lowering adds extra direction, safety, UI mapping, and evidence obligations not requested by this milestone. | Use unit-valued positive-only fields; design signed lowering/widening later if a separate host need is documented. |
| Re-research or modify the four shipped nose tools | A full branch closeout may invite algorithm cleanup. | `大小`, `鼻翼`, `鼻梁`, and `鼻尖` already have archived v1.7 contracts and evidence; changing them expands risk and invalidates comparisons. | Treat existing cases as immutable controls and touch shared routing only where the new fields must join it. |
| Promote the branch after pixels alone | Two new output files can make the checklist look complete. | Pixels do not prove normalization, independence, degradation, redaction, combined safety, or compatibility. | Require provider, resolver, facade, artifact, security, and synchronized-ledger gates before promotion. |
| Add Demo UI, new dependencies, or cloud/3D processing | These could improve presentation or visual realism. | v1.9 is SDK-core/local-only and explicitly excludes UI, dependency, network, commercial, and parity scope. | Validate via the public facade and defer UI/device/commercial/3D work to separately authorized milestones. |
| Commit generated PNG baselines | Checked-in images appear convenient for reviewers. | This conflicts with the established ignored runtime-evidence policy and creates repository/toolchain drift. | Keep outputs/gallery ignored; commit deterministic helpers and command-backed evidence records. |

## Feature Dependencies

```text
Backward-compatible BeautyParameters expansion (31 -> 33 numeric fields)
    ├──> noseRootNarrowing normalization + natural cap
    │       └──> localized upper-root point selection
    │               └──> horizontal symmetric root warp
    └──> noseLift normalization + natural cap
            └──> lower nose/tip point selection
                    └──> vertical-only upward warp

Both new warps
    └──> existing nose freshness / missing-input policy
            └──> six-field reuse scaling + conflict weakening
                    └──> BeautyRender unified geometry pipeline
                            └──> isolated public-facade cases
                                    └──> output helper + ignored gallery
                                            └──> exact row and branch closeout

noseRootNarrowing ──must-differ-from──> noseBridge
noseLift ──must-differ-from──> noseTipSize (+ and -)
missing/stale nose geometry ──disables──> all six nose strengths only
```

### Dependency Notes

- **Both features require compatibility-safe model expansion:** `BeautyParameters`, coding keys, initializer, normalization, effective strengths, geometry detection trigger, and tests must all recognize the fields. Older payloads must decode them as zero.
- **Root narrowing requires a stable top-root subset:** the current internal `FaceGeometry.nose` can be ordered by image-normalized `y`, but current facade geometry is a synthetic mapped shape gated by nose-group availability. Tests must prove that the selected subset is nonempty, deterministic, localized above the broader bridge/lower-nose split, and not dependent on array order. If real landmark fidelity is later required, `noseCrest` mapping is a separate detection-quality dependency, not permission to alias `noseBridge` now.
- **Lift requires lower-region selection but not a new render pass:** `NoseWarpProvider` already selects lower nose points. The new behavior can reuse that selection while emitting `(x, y - displacement)` targets rather than the radial target used by tip size.
- **Safety closeout depends on shared routing updates:** geometry-required detection, cap accounting, domain activation, zeroing, reuse scaling, combined total/count calculations, and render-provider reconstruction must include both fields or the public plan and output can disagree.
- **Facade evidence depends on semantic tests:** a changed PNG establishes visibility, while provider tests establish axis and region. Pairwise comparisons against existing cases establish non-aliasing. No one evidence class substitutes for the others.
- **Branch promotion depends on all gates:** `山根`, `提升`, and branch-level `鼻子` can change together only after runtime, safety, compatibility, privacy, boundary, and artifact evidence pass. Existing rows are prerequisites, not implementation work for v1.9.

## v1.9 Definition

### Launch With

- [ ] `noseRootNarrowing` and `noseLift` with the independent positive-only semantics above, true zero defaults, finite normalization, and missing-key decode compatibility.
- [ ] Provider tests proving root-only horizontal symmetric contraction and lower-nose vertical-only lift, including direct non-equivalence to `noseBridge` and both `noseTipSize` directions.
- [ ] Two isolated public-facade renderer cases across the established fixture matrix, with decodable/non-empty/same-dimension output, nose-ROI baseline differences, pairwise independence checks, representative no-face preservation, ignored gallery routing, and zero tracked generated PNGs.
- [ ] Calibrated exact natural caps plus cap-count, no-face, missing, reused `0.5`, stale, six-field combined weakening, redaction, and safe-domain-continuation evidence.
- [ ] Active-source scans proving no raw geometry, internal renderer/Demo imports, network/cloud/commercial path, new dependency, or tracked generated artifact.
- [ ] Promotion of exactly the two remaining rows and branch-level `鼻子`, synchronized across every current owning contract, without changing archived v1.7 claims.

### Add After Validation

- [ ] Real-landmark or `noseCrest`-driven root refinement if fixture/device evidence shows the synthetic internal root proxy is insufficient.
- [ ] Optional signed root widening or downward nose movement only after a distinct host-facing use case, natural caps, and both-direction evidence are specified.
- [ ] SwiftUI controls for the two new public fields in a separate Demo-scoped milestone.

### Future Consideration

- [ ] 3D depth, relighting, or learned face-model semantics for true physical root/bridge projection; these need separate architecture, privacy, performance, and dependency review.
- [ ] Physical-device parity, long-run preview, optimized performance profiling, commercial visual approval, packaging, and launch-readiness evidence.
- [ ] Broad Meitu/Xingtu parity or any account, payment, VIP, entitlement, cloud, analytics, or commerce path.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
| --- | --- | --- | --- |
| `noseRootNarrowing` public contract and provider semantics | HIGH | HIGH | P1 |
| `noseLift` public contract and provider semantics | HIGH | MEDIUM | P1 |
| Backward-compatible 33-field model expansion | HIGH | MEDIUM | P1 |
| Public-facade output and pairwise independence evidence | HIGH | HIGH | P1 |
| Six-field degradation and combined weakening | HIGH | HIGH | P1 |
| Redaction, boundary, artifact, and exact closeout gates | HIGH | MEDIUM | P1 |
| Real `noseCrest` refinement | MEDIUM | HIGH | P2 |
| Signed widening/lowering variants | LOW | HIGH | P3 |
| Demo UI and device/commercial review | MEDIUM | HIGH | P3 |
| 3D height/relighting implementation | LOW for v1.9 | HIGH | P3 |

## Repository Feature Comparison

| Capability | Existing `noseBridge` (`鼻梁`) | Existing signed `noseTipSize` (`鼻尖`) | New `noseRootNarrowing` (`山根`) | New `noseLift` (`提升`) |
| --- | --- | --- | --- | --- |
| Public range | `[0, 1]` | `[-1, 1]` | `[0, 1]` | `[0, 1]` |
| Primary region | Broader upper nose/bridge | Lower nose/tip | Uppermost root only | Lower nose/tip support |
| Displacement | Horizontal toward centerline | Radial toward/away from nose center | Horizontal, symmetric, localized toward centerline | Vertical upward only |
| Must preserve | Lower nose outside bridge intent | Signed opposite directions | Vertical position and lower bridge/wing/tip | Horizontal position and approximate lower-nose width |
| Required independence proof | Archived v1.7 evidence remains unchanged | Archived positive/negative v1.7 evidence remains unchanged | Baseline difference plus pairwise difference from bridge and provider region assertions | Baseline difference plus pairwise difference from both tip-size directions and provider axis assertions |
| v1.9 role | Immutable comparison/control | Immutable comparison/control | New P1 capability | New P1 capability |

## Sources

- `.planning/PROJECT.md` — v1.9 goal, active requirements, SDK-only boundary, and explicit non-claims.
- `.planning/milestones/v1.7-REQUIREMENTS.md` — archived four-tool nose evidence and the two deferred semantic decisions.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — authoritative `鼻子` row statuses and prohibition on borrowing bridge evidence for `山根`.
- `docs/meitu-function-blueprint/features/beauty-shaping/nose/README.md` — branch ownership, current dependencies, public coverage, and root/lift gaps.
- `DESIGN.md` and `PRODUCT_SENSE.md` — public parameter, natural-cap, degradation, redaction, manual-control, and Phase 32 acceptance contracts.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — current 31-field coding/default/normalization pattern.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` — shipped bridge/tip region and displacement semantics that the new tools must not duplicate.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`, `BeautyEffectPlan.swift`, `BeautySafetyCaps.swift`, and `GeometryConflictResolver.swift` — current nose activation, caps, degradation, reuse, and combined-strength dependencies.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` and `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` — current internal proxy geometry and coordinate/freshness model.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` and nose-focused tests under `BeautySDK/Tests/` — current facade matrix, archived case IDs, provider direction, missing/reused/stale, cap, redaction, and output boundaries.
- `$HOME/.codex/get-shit-done/templates/research-project/FEATURES.md` — research structure and prioritization guidance.

---
*Feature research for: v1.9 Nose Remaining Tools and Branch Closeout*
*Researched: 2026-07-13*
