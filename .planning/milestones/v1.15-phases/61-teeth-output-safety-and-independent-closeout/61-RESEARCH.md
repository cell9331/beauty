---
phase: 61
slug: teeth-output-safety-and-independent-closeout
status: ready
researched: 2026-08-07
confidence: high
---

# Phase 61: Teeth Output, Safety, and Independent Closeout - Research

## Summary

Phase 60 already implements the entire runtime teeth path. Phase 61 should not
change the provider by default; it should expose one exact saved-output case in
the existing public example renderer, freeze a bounded decoder around a tiny
private matrix, add adversarial final-output oracles, inspect fresh genuine
outputs, and only then update product status.

The existing renderer writes a watermark whose text differs by case. Exact
outside-mask comparison therefore needs an opt-in presentation-free mode.
Adding `--no-watermark` while retaining the current default output is smaller
and more trustworthy than teaching the helper to ignore a large mutable label
band. It does not bypass the public SDK: both baseline and active images still
come from `BeautyEngine.processResult` with public parameters.

## Requirement mapping

| Requirement | Planned evidence |
| --- | --- |
| TEETH-15 | Exact 73-case renderer source, one isolated `teethWhitening_1p00` case, `--no-watermark` strict mode, six decoded outputs, genuine positive improvement, negative/no-face no-op, exact dimensions/alpha/containment, and source scans rejecting Testing-only activation. |
| TEETH-16 | Deterministic geometry and recolored-protected oracles, fresh genuine original-detail review, compatibility/privacy/full regressions, eight-HIGH checker, exact product-owner transaction, and separate post-promotion verification. |

## Output architecture

### Renderer surface

Append exactly one case:

- ID `teethWhitening_1p00`;
- display name `teethWhitening 1.00`;
- parameters `BeautyParameters(teethWhitening: 1)` and no other nonzero field.

Add the exact CLI switch `--no-watermark`. When absent, output remains byte- and
behavior-compatible with prior renderer presentation. When present, serialize
the engine-produced `CGImage` directly as PNG. The option must not select a
different engine, parameter, detector, mask, provider, or composition path.

All historical 72-count assertions must advance to 73. Historical tests that
froze teeth absence should be narrowed to their still-valid period/sibling
boundary rather than deleted wholesale: sclera and upper-eyelid candidates
remain absent, aliases remain absent, and the one exact teeth case is the sole
new renderer surface.

### Private six-output matrix

Extend the fixed-output private-runner pattern. In an ignored review root,
stage three opaque regular inputs:

1. authorized discoloration positive original;
2. authorized already-light negative original;
3. existing deterministic no-face input.

Run the renderer twice with `--case geometryBaseline_noop --no-watermark` and
`--case teethWhitening_1p00 --no-watermark`. Require exactly six output PNGs.
The runner discovers the ignored bundle internally and exports only fixed
status plus bounded aggregate counts. It must reject symlinks, duplicate roles,
unexpected manifest structure, output-root escapes, stale output, subprocess
errors, and skipped evidence.

### Strict decoder

Reuse the archived standard-library PNG parser rather than introducing a
dependency. Keep no-follow descriptor reads, file identity checks, CRC and
chunk validation, dimension/decompressed-byte budgets, scanline unfiltering,
exact file inventory, and mutation self-tests. Add alpha decoding and private
mask decoding because Phase 61's truth is pixel ownership, not rectangular ROI
approximation.

Frozen live predicates should match the already-passed Phase 60 private test:

- positive: changed reviewed pixels greater than zero, mean yellow excess
  decreases, mean luminance delta in `(0, 0.03]`, maximum channel delta at most
  `48`, texture-energy ratio `0.85...1.15`, zero reviewed-mask exterior and
  alpha changes;
- negative: mean absolute RGB delta at most `0.012`, absolute mean luminance
  delta at most `0.006`, texture-energy ratio `0.85...1.15`, zero exterior and
  alpha changes;
- no-face: active output RGB and alpha byte-identical to baseline;
- all: candidate and baseline dimensions equal their corresponding input.

The helper must also statically confirm the exact renderer case and public-only
initializer. Metrics are corroboration only and never mutate admission.

## Adversarial safety architecture

The current deterministic provider tests cover protected colors under fixed
support. Phase 61 adds two independent closeout layers:

1. **Color-independent geometry perturbation:** for a table of complete,
   plausible outer/inner lip support perturbations, retain literal protected
   truth coordinates independent of provider scoring. Any issued ownership at
   those coordinates fails even if their RGB resembles enamel.
2. **Recolored final output:** recolor protected lip, tongue, gum, brace,
   facial-hair, skin, and aperture-exterior truth to score-attractive values,
   then execute provider, blur/re-clip, transform, composition, and output.
   Protected and exterior RGBA must remain byte-identical.

Add local failure/recovery cases around malformed/partial/unsafe support and
valid-invalid-valid/parallel requests. Synthetic oracles have zero
naturalness/evidence weight.

## Original-detail review

After thresholds and code are frozen, the private runner generates a local
blinded review set. The executing agent opens positive and negative baseline
and active outputs at original detail. Fixed judgments cover target presence,
visible but bounded de-yellowing, tooth locality, protected leakage, enamel
texture/shading/edges, natural color, and negative stability. The durable
record stores only opaque roles and fixed categorical values. A visual failure
blocks and any tuning requires a fresh complete run.

## Promotion transaction

Create a fail-closed checker with default pre-promotion mode and
`--allow-promotion` post mode. Default requires `白牙` future and `嘴唇`
partial. After focused, private, adversarial, visual, compatibility, privacy,
full-regression, review, and security gates pass, atomically change:

- `白牙`: `future` to `implemented`, citing Phases 59, 60, and 61;
- branch `嘴唇`: `partial` to `implemented`, because every child row is then
  implemented.

No other product row or branch status may change. `祛红血丝` and `去脂` stay
future; `眼睛` stays partial. Post mode then requires exact synchronized owners,
complete TEETH-15/16 evidence, zero open HIGH threats, and no lifecycle
overclaim before Phase 62 is unblocked.

## Spec-less edge resolution

The deterministic fallback probe returned four unresolved items. Planning
resolves them explicitly:

- TEETH-15 unclassified behavior is the exact one-case/six-output contract.
- Any adjacent or conflicting gate state resolves to blocked, never partial
  promotion.
- Empty/null/missing evidence blocks promotion and cannot count as a skip/pass.
- Order is fixed: freeze/test/review in pre-promotion state, atomic owner update,
  then independent post-promotion verification.

## Security and privacy

The Phase 61 checker should own eight HIGH classes: public-output authenticity,
bounded parser/artifact containment, geometry oracle integrity, final-output
protected identity, genuine review integrity, private-data containment, exact
promotion scope, and independent lifecycle sequencing. Each needs a mutation
self-test and isolated live disposition.

No external research, package, model, API, network, Demo control, realtime
path, pixel-buffer path, or new render pass is needed.

