---
phase: 80
candidate: v4
status: gate-ready
external_v4_input_present: false
decision: qualification-not-passed
---

# Candidate-v4 Qualification Preflight

Candidate v4 was frozen before any private v4 output existed.

- baseline: `boundary-anchored-relief-flattening-editor-v4`;
- qualification strength: `1.0`;
- semantic source convexity: at least `3.5` sRGB8;
- required convexity reduction: at least `35%` with formula consistency;
- spatial correction range: at least `6` sRGB8;
- target mean absolute change: at least `3` sRGB8;
- adjacent correction jump: at most `5` sRGB8;
- target channel cap: `16` sRGB8; protected target cap: exact `0`;
- texture retention: at least `0.98` with no tolerance;
- Node evaluator tests: 20 passed, 0 failed;
- independent checker: 18 checks passed;
- v1, v2, and v3 contract/evaluator/test artifacts remain immutable;
- earlier bindings and evidence cannot supply v4 qualification credit;
- human review independently requires visibly flatter relief and rejects a
  uniform tone-shift-only result;
- public absence remains exactly 61/5/74;
- without external v4 input the only result is
  `qualification-not-passed`.

No private locator, source mapping, rights detail, media, pixel, mask,
landmark, geometry, metric row, transcript, or reviewer identity is durable.
