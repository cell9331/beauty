---
spike: 002b
name: teeth-coreml
type: comparison
validates: "Given the same portraits, when the EasyPortrait Core ML teeth head runs locally, then its mask improves useful coverage without creating a redistributable-model claim."
verdict: PARTIAL
related: [002a, 004, 005]
tags: [teeth, coreml, license-gate]
---

# Spike 002b: Teeth Core ML

## What This Validates

Tests whether an existing Core ML face-parsing port can materially improve
teeth coverage over the Vision/color baseline while remaining an external,
research-only dependency.

## Research

- [EasyPortrait](https://github.com/hukenovs/easyportrait) defines a dedicated
  `TEETH` class and its [paper](https://arxiv.org/abs/2304.13509) describes
  40,000 images, 13,705 users, nine classes, and diversity across pose,
  lighting, demographics, and expression.
- The tested [unofficial Core ML port](https://github.com/john-rocky/easyportrait-coreml)
  contains a compiled 512×512, nine-output model but no visible repository
  license. The upstream dataset/model uses a custom CC BY-SA variant with a
  separate PDF. That chain is not sufficient for product redistribution.
- The temporary clone was pinned to commit
  `62f0a58dd553d1b064254dffd0d06b40dc9cd57e`. No model or weight was copied
  into this repository; hashes are recorded in `model-audit.txt`.

## How to Run

```bash
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode teeth-coreml \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/002-b-teeth-coreml/artifacts/e6-release \
  --model /path/to/easyportrait.mlmodelc
```

## What to Expect

The learned mask covers more visible teeth than Spike 002a. A cold process may
pay a large model-load cost; the next warm process should be materially faster.

## Observability

The log adds output count plus aggregate load and inference durations. It does
not include tensors, mask geometry, model paths, or face coordinates.

## Investigation Trail

1. Inspected the sample's nine output heads and confirmed teeth is `out3`.
2. Loaded the compiled model from `/tmp`, ran it locally, and converted only the
   teeth head into the shared bounded color transform.
3. The e6 mask captured 9,572 pixels versus the heuristic's 6,099 and included
   darker side teeth.
4. Cold model load was 1,680.6 ms; a subsequent process reported 21.4 ms load
   and 15.8 ms inference, showing a material cold/warm split.
5. Audited repository and model provenance; the conversion repository exposes
   no license, so technical success cannot become a shipping decision.

## Results

**Verdict: PARTIAL — mask-quality winner, production blocked.**

The e6 run changed 9,518 pixels with zero outside-mask change and 0.102 maximum
channel delta. The learned mask is visibly more complete than the deterministic
baseline. Peak RSS reached 197.8 MB in the cold high-resolution run.

Do not vendor this model. A production plan needs either a legally approved,
pinned model and data chain or a newly trained/owned teeth segmenter with an
explicit evaluation dataset and cold-start/resource budget.
