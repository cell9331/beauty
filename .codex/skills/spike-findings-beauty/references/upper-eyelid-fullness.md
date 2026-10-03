# Upper-Eyelid Fullness: Current Boundary and Historical Findings

## Current disposition

`去脂` is `suspended` as of 2026-10-01. The SDK retains
`upperEyelidFullnessReduction` and explicit calls for compatibility, but omits
it from default renderer discovery/batches and recommended examples. Natural-
appearance effect qualification has failed. See the repository's current
`PLANS.md`, `docs/SDK_EFFECT_TAXONOMY.md` and
`docs/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md` for the governing decision.

The retained mechanism performs bounded upper-lid luminance correction. Its
brightness proxy does not reliably identify fullness on natural backgrounds;
failed candidates that improve admission still lose most correction during
reconstruction, while relaxing protection can reintroduce artifacts. These
results reject the tried mechanisms, not every possible no-model method.

## Rules for using this reference

- This reference creates no current implementation or training task. General
  requests to continue do not restart去脂 development.
- Keep explicit-call safety, zero-default compatibility and existing failure
  behavior. Do not alias去脂 to eye opening, lid lifting, global smoothing,
  eye-bag removal or dark-circle removal.
- Raw landmarks, masks and pixels remain request-local and absent from
  persisted/public diagnostics.
- If the owner explicitly restarts the research, first define a new hypothesis,
  applicable inputs, fixed positive/negative examples, independent effect and
  protection criteria, and a stop condition. No learned or deterministic route
  is preselected or promised to succeed.
- Authorized generated portraits are eligible inputs. A failed suitable-source
  effect test remains a failure; lack of genuine human photos is not the cause
  or a mandatory blocker.

## Historical spike observations

The 2026-07 tone/frequency prototype used eye/eyebrow geometry to bound a
feathered band, altered low-frequency luminance and retained high-frequency
detail. Texture-energy ratios of 0.9996 and 0.9866 with zero mask leakage showed
those measured properties only; the fixtures did not prove the desired effect.
The interior vertical warp produced ratios of 0.9305 and 0.9188 without a
clearer fullness benefit and was rejected. These observations are not a
current build recipe, parameter recommendation or qualification verdict.

Original spike sources remain unchanged in `sources/001a-upper-lid-tone/`,
`sources/001b-upper-lid-warp/` and `sources/shared-retouch-lab/`.
