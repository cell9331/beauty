---
phase: 80-genuine-evidence-and-qualification-gate
plan: "11"
status: complete
completed: 2026-08-24
implementation_commit: 94400c0
requirements: []
---

# Plan 80-11 Summary

Candidate v3 replaces candidate v2's per-pixel sign-flipping luminance field
with one clipping-safe non-positive contour correction per accepted eye.

- Strength `1` requests a `-10` center correction while the existing `±16`
  safety cap remains unchanged.
- One whole-support clipping bound guarantees the same pre-feather correction
  for every RGB channel and every accepted pixel.
- The existing curved Q16 ownership is the only spatial falloff, so the
  correction cannot flip from negative to positive between neighbors.
- Missing geometry or semantic approval still produces typed source-exact
  no-op; no target region is invented for rejected negative/stress cases.
- Focused upper-eyelid coverage passed 25 tests with zero failures, including
  single-sign, exact detail/channel-difference, texture, adjacent-jump,
  protected exterior, alpha, extent, collision, and determinism assertions.

This is a new mechanics version only. No v3 private output has been generated
or viewed, and public absence remains exact 61/5/74.
