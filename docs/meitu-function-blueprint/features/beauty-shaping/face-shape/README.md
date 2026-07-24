# Beauty Shaping Branch: Face Shape

## Business Logic

Face-shape tools include face width, small face, smooth face contour, temple, cheekbone, chin length, double-chin removal, V face, jaw angle, jawline, and hairline.

## Technical Core

- The current SDK supports five prior face/chin controls plus independent smooth-contour, temple-fullness, cheekbone-slim, and pointed-chin geometry.
- Double-chin and hairline capabilities still need approved local semantic-region/segmentation behavior and reproducible clean-clone fixtures.
- Safety caps must prevent extreme contour collapse.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`, `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`.
- Future parameter/resource needs: `去双下巴`, `去双下巴 Pro`, and `发际线`.
- Evidence expectation: Phase 28 covers the six prior rows; Phases 45-48 independently cover the four added rows.

## Phase 28 Scoped Completion

Phase 28 marks these second-level rows implemented in `SHAPE_FEATURE_LEDGER.md`: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`.

Evidence:

- Renderer cases: `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, and `jawSlim_0p35`.
- `下颌线` is alias-backed by `jawSlim` and shares `jawSlim_0p35` with `下颌角`.
- `28-FACE-SHAPE-RENDERER-EVIDENCE.md` records 102 ignored outputs and 30/30 top-region comparisons.
- `28-VERIFICATION.md` records focused XCTest, helper, ledger, redaction, and wording guards.

## Phase 48 Scoped Completion

Phase 48 marks exactly `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` implemented after the complete evidence chain:

- Phase 45: exact 52-field public contract and private observed contour/centerline support.
- Phase 46: independent named providers, field-local eligibility, and monotone conflict routing.
- Phase 47: 413/413 decoded public-facade outputs, including 18/18 visibility/locality, 49/49 fixed-neighbor distinctions, 6/6 ineligible no-ops, and 4/4 no-face no-ops.
- Phase 48: final exact `0.25` caps, nine-field degradation/transitions, exact 37-field convergence, clean review, privacy/security boundaries, and fail-closed promotion evidence.

`去双下巴`, `去双下巴 Pro`, and `发际线` remain future until approved local semantic-region/segmentation implementations and reproducible clean-clone fixtures exist. The branch status remains `partial`; no Demo, device, commercial, performance, packaging, shipping, or launch-readiness claim is made.

## Boundary

`Pro` variants are capability labels only until entitlement and algorithm support exist. Phases 28 and 45-48 add no Demo UI, commercial gate, device parity claim, broad reference-app parity claim, new geometry group, or launch-readiness claim.
