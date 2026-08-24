---
phase: 80-genuine-evidence-and-qualification-gate
plan: "15"
status: complete
completed: 2026-08-24
requirements: [QUAL-03, QUAL-04]
---

# Plan 80-15 Summary

Candidate v4 replaces candidate v3's visually ineffective uniform contour with
request-local boundary-anchored relief flattening. The implementation filters
only the admitted brow-to-lid support, fits an affine illumination plane from
its feather boundary, rejects sub-threshold central convexity, and applies a
bounded spatially varying equal-RGB residual correction through immutable-source
Q16 composition.

Generated positive coverage requires more than five correction values, a
central correction below `-8`, and post-composition central convexity below
`55%` of source. Planar lighting and crease-only detail reject without output.
Existing peer isolation, protected/exterior identity, alpha, extent, metadata,
texture, smooth-boundary, collision-to-source, and determinism guarantees remain
active.

Verification:

- focused upper-eyelid SwiftPM: `30/0/0`;
- full plain SwiftPM: `805/0/8` (the eight established opt-ins remain skipped);
- `swift build`: pass;
- post-archive SDK-only boundary: pass;
- diff hygiene: pass.

No candidate-v4 private output was generated or inspected during this plan.
The mechanics remain package-only and carry no genuine efficacy, public API,
device, commercial, packaging, shipping, launch, or release-readiness claim.
