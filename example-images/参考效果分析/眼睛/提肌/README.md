# Eyelid lift — 提肌

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Reference analysis library](../../README.md)

Status: **menu only; no measured effect pair**. Reviewed on 2026-10-16. The control is visible in the screenshot sequence, and its icon reads `OFF`. None of the 23 screenshots selects this control or supplies its enabled result. The icon establishes the visible UI state; it does not establish an implementation mechanism or certify that every other eye adjustment is neutral.

## What the supplied evidence supports

The control exists in the eye menu. There is no qualified source/target pair for its effect, no enabled-state capture, and no observed intensity or scope response. The outdoor original is a same-content source candidate for this batch, but an original image cannot supply a missing enabled target. See the [input inventory](../输入清单.md) for the captured controls and state limitations.

The label can suggest an intended appearance, but it cannot distinguish upper-lid movement, a crease adjustment, a local texture change, or a combination. The name also does not identify a fixed anchor, support boundary, displacement sign, or amplitude. None of these quantities has been measured for this control.

## Minimum additional evidence

Capture the control explicitly disabled and explicitly enabled on the same photograph, with the same display crop and scale. Record the selected control, its visible state, and any intensity or left/right scope setting. Keep other adjustments and background-protection state fixed and documented. If an intensity slider appears, include its neutral setting and both available endpoints; if the control has only two states, the disabled/enabled pair is sufficient for an initial comparison.

The photograph should show both upper-lid margins, creases, iris boundaries, and nearby brow texture clearly. An unchanged repeat of the disabled capture provides a useful display/recompression control.

## How the new evidence would discriminate mechanisms

Register only stable texture outside the candidate effect area, then measure source-to-target horizontal and vertical correspondence. Upper-lid margin motion with quieter iris and brow texture would support a local lid deformation. A crease-only change would require checking whether corresponding texture actually moves before describing it as geometry. A visual change without reliable geometric correspondence would leave the displacement mechanism unidentifiable and would require a separately defined appearance study if desired.

Measure each eye independently before proposing shared amplitudes or symmetry. No displacement map, candidate formula, implementation, or reference-match claim is justified by the present menu-only evidence. This item is documented as an evidence gap, and its effect analysis remains pending.
