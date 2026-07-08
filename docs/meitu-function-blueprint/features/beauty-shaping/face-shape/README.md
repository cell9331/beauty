# Beauty Shaping Branch: Face Shape

## Business Logic

Face-shape tools include face width, small face, smooth face contour, temple, cheekbone, chin length, double-chin removal, V face, jaw angle, jawline, and hairline.

## Technical Core

- Existing MVP supports parts of face slim, small face, V shape, jaw, and chin.
- Advanced cheekbone, temple, double-chin, and hairline need additional landmarks or segmentation.
- Safety caps must prevent extreme contour collapse.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`.
- Future parameter needs: smooth face, temple, cheekbone, double chin, pointed chin, and hairline.
- Evidence expectation: Phase 28 provides public-facade saved-output evidence for the scoped existing-parameter rows only.

## Phase 28 Scoped Completion

Phase 28 marks these second-level rows implemented in `SHAPE_FEATURE_LEDGER.md`: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`.

Evidence:

- Renderer cases: `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, and `jawSlim_0p35`.
- `下颌线` is alias-backed by `jawSlim` and shares `jawSlim_0p35` with `下颌角`.
- `28-FACE-SHAPE-RENDERER-EVIDENCE.md` records 102 ignored outputs and 30/30 top-region comparisons.
- `28-VERIFICATION.md` records focused XCTest, helper, ledger, redaction, and wording guards.

The branch status remains `partial` because `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, and `发际线` still need separate SDK design or evidence.

## Boundary

`Pro` variants are capability labels only until entitlement and algorithm support exist. Phase 28 adds no Demo UI, commercial gate, device parity claim, broad reference-app parity claim, new geometry group, or launch-readiness claim.
