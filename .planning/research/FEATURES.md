# Feature Research

**Domain:** Remaining SDK-core eye geometry controls
**Researched:** 2026-07-16
**Confidence:** HIGH for scope; MEDIUM for final visual calibration

## Feature Landscape

### Geometry Scope for v1.11

| Ledger row | Proposed public semantic | Range family | Required private support | Distinction to prove |
| --- | --- | --- | --- | --- |
| `眼高` | `eyeHeight` | positive-only | upper/lower contour | Vertical aperture, not radial `eyeSize`. |
| `长度` | `eyeLength` | positive-only | inner/outer corners | Horizontal span, not `eyeDistance`. |
| `提肌` | `upperEyelidLift` | positive-only | upper lid | Upper-lid-local lift, not whole-eye Y position. |
| `眼瞳大小` | `pupilSize` | positive-only | contour + pupil | Pupil-local radial geometry, not eye enlargement. |
| `眼神矫正` | `gazeCorrection` | positive-only automatic correction | contour + pupil | Moves an offset pupil toward a validated neutral center; does not invent a gaze direction. |
| `眼睑下至` | `lowerEyelidDrop` | positive-only | lower lid | Lower-lid-local drop, not height or size alias. |
| `倾斜` | `eyeTilt` | signed | both contours and centers | Opposite rotations preserve direction and differ from tail lift. |
| `内眼角` | `innerCornerOpen` | positive-only | side-aware inner corners | Nasal-corner-local opening, not length. |
| `外眼角` | `outerCornerOpen` | positive-only | side-aware outer corners | Temporal-corner-local opening, not tail lift or length. |
| `对称` | `eyeSymmetry` | positive-only automatic correction | both observed contours | Reduces measured inter-eye height/center/tilt difference without mirroring identity or forcing a synthetic face. |

### Table Stakes

- Every public value is independent, normalized, default-zero, Codable-compatible, and source-compatible.
- Every control has distinct provider vectors and isolated public-facade output evidence.
- Contour-only work survives missing pupil support; pupil/gaze work fails closed independently.
- Automatic gaze and symmetry controls only reduce a measured deviation; already-neutral or implausible support is a no-op.
- Missing, malformed, blinking/implausible, reused, stale, and no-face inputs produce fixed redacted evidence and safe continuation.
- Generated outputs and galleries remain ignored and untracked.

### Explicitly Deferred

| Feature | Reason |
| --- | --- |
| `去脂` | Local texture/retouch or segmentation work, not geometry. |
| `祛红血丝` | Eye-region color/vascular retouch with separate containment and safety ownership. |
| Manual X/Y gaze controls | The product row is correction, not gaze redirection; directional controls would need separate semantics and stronger visual-risk review. |
| Demo sliders/screens | v1.11 is SDK-core and public-facade evidence only. |

## Feature Dependencies

```text
38-field compatibility
  -> private observed eye contours
     -> height / length / lids / tilt / corners
     -> private optional pupil support
        -> pupil size / gaze correction
     -> paired-contour comparison
        -> symmetry correction
  -> provider-owned per-field eligibility
     -> resolver/conflict/facade integration
        -> saved-output evidence
           -> final safety and exact promotion
```

## Prioritization

| Group | User value | Cost | Priority |
| --- | --- | --- | --- |
| Contract and private support | HIGH | HIGH | P1 |
| Contour/lid/corner transforms | HIGH | HIGH | P1 |
| Pupil/gaze/symmetry correction | HIGH | HIGH | P1, after observed support |
| Output and safety evidence | HIGH | HIGH | P1 |
| Eye-fat/redness retouch | MEDIUM | HIGH and different domain | Future |

## Acceptance Shape

Completion means exactly the ten geometry rows move from `future` to `implemented` only after public contract, private support, provider, facade output, safety, degradation, security, and documentation evidence agree. Branch-level `眼睛` remains `partial` because the two retouch rows remain unresolved.

## Sources

- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — authoritative row inventory and current status.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` — shipped four-field contract and future gaps.
- `.planning/milestones/v1.6-*` — immutable evidence for the four shipped eye controls.
- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — available contour and pupil inputs.

---
*Feature research for: Beauty v1.11 Eye Remaining Geometry Controls*
*Researched: 2026-07-16*
