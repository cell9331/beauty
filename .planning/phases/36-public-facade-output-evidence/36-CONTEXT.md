# Phase 36: Public-Facade Output Evidence - Context

**Gathered:** 2026-07-13
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`--auto` recommendations accepted)

<domain>
## Phase Boundary

Produce deterministic public-facade renderer, output-helper, and ignored-gallery evidence for the two independent Phase 35 nose fields. This phase owns output visibility, independence, extent, inventory, and artifact-containment evidence only. Final cap calibration, exhaustive six-field safety, boundary closeout, documentation promotion, and SDK-core branch completion remain Phase 37 scope.

</domain>

<decisions>
## Implementation Decisions

### Renderer Cases
- Add exactly two isolated renderer cases named `noseRootNarrowing_0p25` and `noseTipLift_0p25`; each must construct public `BeautyParameters` and flow only through `BeautyEngine.processResult`.
- Do not call package-internal resolvers, providers, geometry adapters, or raw-landmark APIs from the renderer or helper.
- Derive the rendered inventory from the actual renderer case list and fixture files. The expected frozen result is `36 cases × 7 fixtures = 252 PNGs` if neither source inventory changes; fail with an explicit inventory mismatch rather than silently hard-coding a stale total.

### Output and Independence Evidence
- Verify all expected PNGs are present, decodable, non-empty, and preserve the corresponding input dimensions.
- Compare both new cases against `geometryBaseline_noop` for every usable portrait above the rendered watermark. With the current six usable portrait fixtures, this is exactly 12 baseline comparisons.
- Compare `noseRootNarrowing_0p25` against `noseBridge_0p30` inside a deterministic nose ROI and compare `noseTipLift_0p25` against both `noseTipSize_plus0p30` and `noseTipSize_minus0p30` inside that ROI.
- Report root-vs-bridge and lift-vs-tip positive/signed evidence separately so a single aggregate diff cannot mask aliasing. The current seven-fixture inventory is expected to yield 6 root-vs-bridge portrait comparisons plus 12 lift-vs-signed-tip portrait comparisons.
- A comparison passes only on deterministic pixel-difference evidence in the intended ROI; file inequality, watermark text, labels, timestamps, and whole-image differences alone are insufficient.

### ROI and Watermark Boundary
- Define the nose ROI deterministically from image dimensions as a documented normalized rectangle centered on the nose region, following the established Phase 31/33 helper patterns where applicable.
- Exclude the bottom watermark band from every visual comparison; the nose ROI must be wholly above that band.
- Keep thresholds explicit and evidence-backed in the helper and evidence document so reruns fail closed when output becomes invisible or aliases a legacy case.

### No-Face and Artifact Containment
- Representative no-face outputs for both new cases must exist, decode, remain non-empty, and preserve input extent; safe no-op/degradation is acceptable and must not be reported as portrait visibility evidence.
- Renderer output and gallery routes remain repository-ignored. No generated output PNG or gallery PNG may be staged or tracked.
- The helper and evidence document are repository-owned; generated PNGs are local evidence only.

### Documentation Boundary
- Close only NOSE-07 through NOSE-09 in this phase.
- Do not promote `山根`, `提升`, or branch-level `鼻子`, and do not synchronize production-readiness/current-owner documentation as complete. Phase 37 owns atomic promotion after final safety and boundary gates.
- Do not claim physical-device parity, commercial visual approval, packaging, shipping, or launch readiness.

### the agent's Discretion
- Exact helper function names, image-decoding library choices already available in the repository environment, numeric ROI bounds, and diff thresholds may follow the established Phase 31 nose and Phase 33 mouth evidence patterns, provided the values are deterministic, documented, above-watermark, and verified against current outputs.
- The gallery presentation layout may reuse the current renderer-gallery tooling without adding product UI.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` currently declares 34 public-facade cases, including `geometryBaseline_noop`, `noseBridge_0p30`, and both signed `noseTipSize` cases.
- `.planning/milestones/v1.7-phases/31-nose-renderer-output-evidence/check_nose_renderer_outputs.py` is the nearest nose-specific inventory, dimension, ROI, no-face, and ignored-artifact precedent.
- `.planning/milestones/v1.8-phases/33-mouth-renderer-output-evidence/check_mouth_renderer_outputs.py` is the most recent facade-renderer helper pattern.
- Phase 35 verification proves the new fields already route through public-facade detection and package-internal geometry without raw geometry exposure.

### Integration Points
- Renderer source changes belong only in `BeautyExampleRenderer`; the v1.9-owned helper and evidence files belong in this Phase 36 directory.
- Output generation uses `example-images/input`, `example-images/output`, and the established ignored gallery route.
- Phase verification must inspect actual renderer cases and actual fixture files before asserting `36 × 7 = 252`.

</code_context>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone Contract
- `.planning/ROADMAP.md` — Phase 36 goal, success criteria, and Phase 37 boundary.
- `.planning/REQUIREMENTS.md` — NOSE-07 through NOSE-09 acceptance contract.
- `.planning/phases/35-public-contract-and-independent-geometry/35-VERIFICATION.md` — verified public-facade routing, provisional caps, and non-promotion handoff.

### Renderer and Helper Patterns
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — actual public-facade case inventory and output naming.
- `.planning/milestones/v1.7-phases/31-nose-renderer-output-evidence/check_nose_renderer_outputs.py` — nearest nose ROI and output-evidence precedent.
- `.planning/milestones/v1.8-phases/33-mouth-renderer-output-evidence/check_mouth_renderer_outputs.py` — newest renderer/helper inventory and artifact pattern.

</canonical_refs>

<specifics>
## Specific Ideas

Treat `36 × 7 = 252`, 12 new-vs-baseline portrait comparisons, 6 root-vs-bridge comparisons, and 12 lift-vs-signed-tip comparisons as expected current evidence counts, not permanent magic numbers detached from the actual case and fixture lists.

</specifics>

<deferred>
## Deferred Ideas

- Final exact-cap calibration, exhaustive all-six-nose degradation/reuse/provider-empty coverage, and once-only combined weakening — Phase 37.
- Active-source privacy/import/network/commercial/dependency boundary closeout, atomic ledger promotion, and branch completion — Phase 37.
- Demo UI, physical-device, commercial visual, packaging, shipping, and launch evidence — outside v1.9.

</deferred>

---

*Phase: 36-public-facade-output-evidence*
*Context gathered: 2026-07-13 via autonomous smart discuss*
