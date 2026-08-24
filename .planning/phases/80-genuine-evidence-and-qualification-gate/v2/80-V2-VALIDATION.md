---
phase: 80
candidate: v2
status: gate-ready
external_v2_input_present: false
decision: qualification-not-passed
---

# Candidate-v2 Qualification Preflight

The candidate-v2 contract, evaluator, and independent checker were frozen
before any private candidate-v2 output was generated or viewed.

Sanitized preflight:

- baseline: `brow-to-lid-feathered-editor-v2`;
- evaluator: `phase80-qualification-evaluator-v2`;
- canonical contract hash:
  `81686faf3598a65bb1743feb24315ec75006920d62e4ae71ae4c3e0b38b47d84`;
- Node evaluator tests: 15 passed, 0 failed;
- independent checker: 13 checks passed;
- v1 contract/evaluator/test hashes remain exact and immutable;
- source, focused evidence, helper, semantic, evidence, rubric, and public
  absence mutations fail closed;
- public absence remains exactly 61 parameter fields, 5 presets, and 74
  renderer cases;
- without external v2 inputs the only result is
  `qualification-not-passed`.

No private locator, rights record, source mapping, media, pixel, mask,
landmark, geometry, review row, or reviewer identity is recorded here.
