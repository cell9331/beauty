---
phase: 80-genuine-evidence-and-qualification-gate
plan: "08"
status: complete
completed: 2026-08-24
requirements: [EVID-03, EVID-04, EVID-05, QUAL-03, QUAL-04, QUAL-05]
---

# Plan 80-08 Summary

Candidate v2 is now frozen independently from the terminal v1 run.

- The exact four source owners and six evidence owners are content-bound to
  the post-remediation implementation commit.
- The private qualification run is fixed at editor strength `1.0`; it cannot
  be changed after real-image outcomes are visible.
- The v1 evaluator is reused only for content-addressed JSON/file safety
  primitives; the v2 schema, thresholds, rubric, bindings, and decision are
  separately versioned, and v1 bindings are explicitly rejected.
- The pixel matrix retains efficacy, containment, texture, protected geometry,
  metadata, determinism, alpha, extent, rejected-source, and color gates.
- New exact requirements bound adjacent correction jumps to 5 sRGB8 values,
  require feather-to-zero, and add a fixed `boundary-artifact` human-review
  failure.
- Fifteen Node tests and thirteen independent Python preflight checks pass.
- Preflight remains intentionally non-promotable without external v2 inputs,
  and public absence remains exactly 61/5/74.

No candidate-v2 private output was generated or viewed before this freeze.
