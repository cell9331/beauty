# Gaze correction — 眼神矫正

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Reference analysis library](../../README.md)

Status: **menu only; no measured effect pair**. Reviewed on 2026-10-16. The menu icon reads `OFF` in the supplied sequence. No screenshot selects this control or shows a qualified enabled result. Its output, any intensity setting, and its target gaze direction are therefore unknown.

## What the supplied evidence supports

The menu label and disabled-state icon establish availability in the photographed UI. They do not establish whether the feature moves iris texture, changes an eye opening, synthesizes exposed sclera, uses another appearance operation, or combines these behaviors. An apparent gaze change would not by itself prove a pure translation: changing occlusion or contrast can also change the perceived direction.

There is no source/target pair with a documented control transition. The original outdoor portrait is a source candidate, but it is not a missing enabled-state observation. The [input inventory](../输入清单.md) records the controls that do have selected screenshots and explains why a shared neutral state has not been certified.

## Minimum additional evidence

Capture the same photograph with this control visibly disabled and enabled, without changing crop, zoom, other adjustments, or background-protection state. Record the selected state, any target-direction choice, any strength, and any per-eye scope. Include a photograph with a clearly visible initial gaze offset if the present portrait produces an imperceptible result. A repeated disabled capture is useful to separate the effect from display or encoding variation.

For any claim about gaze-dependent behavior, a single off/on pair is insufficient: add at least one different initial gaze direction under the same capture protocol. Do not infer this response from the existing iris-size pair.

## How the new evidence would discriminate mechanisms

After stable-region alignment, compare independently selected iris, pupil, lid-margin, and scleral texture correspondences. Relative iris motion with stable lid boundaries would support an interior-eye operation. Lid motion or changing occlusion would require a larger geometric model. Missing or newly appearing texture would limit what a two-dimensional displacement field can explain and should be marked as an appearance/disocclusion uncertainty.

Measure the two eyes separately and report correspondence acceptance and failures, especially where the iris is occluded. No model download, gaze estimator, synthesized target, or color study is authorized merely by this menu label. The present result is an evidence-gap record; effect measurement and an implementation proposal remain pending.
