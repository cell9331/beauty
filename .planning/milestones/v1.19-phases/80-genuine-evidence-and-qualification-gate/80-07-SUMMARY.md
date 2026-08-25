---
phase: 80-genuine-evidence-and-qualification-gate
plan: "07"
status: complete
completed: 2026-08-24
requirements: []
implementation_commit: 4cf736c
---

# Plan 80-07 Summary

Candidate-v2 mechanics replace candidate v1's eye-aligned hard rectangle and
per-channel gray-128 correction.

Implemented behavior:

- same-side eye plus eyebrow are required to create a request;
- the permitted envelope lies strictly between brow and eye and rejects
  missing, crossed, implausible, or undersized geometry per eye;
- semantic approval remains independently required;
- every accepted pixel carries a validated elliptical Q16 feather ceiling;
- the editor flattens only supported low-frequency luminance toward a weighted
  regional reference, applies equal RGB deltas capped to `±16`, and carries the
  exact original high-frequency residual;
- immutable-original exterior/protected/collision, alpha, extent, metadata,
  and deterministic behavior remain intact.

Verification:

- focused upper-eyelid remediation: 24 tests, 0 failures;
- full plain SwiftPM: 803 tests, 0 failures, 8 established opt-in skips;
- generated texture-retention assertion: `>= 0.98`;
- adjacent correction jump bound and no-rectangle protected-row checks: pass;
- post-archive SDK-only boundary: pass;
- `git diff --check`: pass.

This plan creates no public field, route, renderer case, preset, resource,
model, backend, or taxonomy promotion. Candidate v2 still requires a baseline
and rubric frozen before any new private outcome is inspected.
