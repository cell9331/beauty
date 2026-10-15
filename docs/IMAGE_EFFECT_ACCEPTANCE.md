# Image Effect Acceptance Policy (updated 2026-10-01)

This is the current owner-authorized acceptance policy for `BeautySDK` image
effects. It supersedes earlier planning language that made genuine or natural
human portraits a prerequisite for progress, effect qualification, taxonomy
promotion, or milestone completion. Dated results and signed historical
receipts remain facts about their own input and code snapshots.

## Eligible images

- Deterministic code-generated images and owner-authorized AI-generated
  portrait-like images are valid **effect acceptance inputs**, including
  positive, negative, adversarial, and protected-region examples. They are not
  confined to a mechanics-only tier merely because they are generated.
- Genuine human portraits and physical-device feedback are optional additional
  evidence. Their absence, or difficulty obtaining a complete set, is not a
  gate, dependency, unexpected skip, or progress blocker for current or future
  SDK milestones unless the owner explicitly changes this policy later.
- The owner must have permission for the actual local use of every input and
  generated output. Keep media and private source details local and ignored;
  persist only approved aggregate results and contract identities.

## What an effect pass must prove

API compatibility, mechanical safety and effect qualification are separate
claims, with different evidence:

| Claim | Required evidence | What it does not establish |
| --- | --- | --- |
| API compatibility | Field/default/decoding behavior and callable entry points retain their contract. | The requested effect is useful or visually correct. |
| Mechanical safety | Applicable bounds, protected pixels, neutral identity, determinism, metadata and failure behavior pass. | A bounded change reaches the intended target; a safe no-op is not a positive effect pass. |
| Effect qualification | Independent source-defined positives and negatives demonstrate meaningful intended change and protection together in the claimed input range. | General anatomical recognition, untested appearance ranges or device quality. |

None substitutes for another. A passing full SDK gate qualifies only the
assertions it executes; it cannot erase a separately frozen failing effect
challenge. A production admission score or post-edit version of the same
proxy cannot by itself serve as independent ground truth for the effect.
An unverified route is a hypothesis, not an available effect that merely needs
optimization.

Before observing candidate output, define an eligible positive that visibly
contains the target condition, a negative that lacks it or should remain
unchanged, and the source-fixed target and protected regions. The inputs must
be capable of testing the claimed effect; a changed-pixel count alone is not
evidence of the intended direction. Use the public SDK path and assert the
applicable output pixels, direction or visual improvement, negative behavior,
protection, bounded change, neutral identity, repeatability, dimensions,
orientation/mirroring, color space, alpha, and typed failure/recovery. When a
claim includes visual improvement or no worsening, inspect the output at
original detail against a predeclared artifact/protection oracle in addition
to numeric checks; a passing pixel count cannot override a visible artifact.
Record failures honestly; do not weaken thresholds after viewing output.
State whether the target is an image-space luminance/contour change or a
semantic/anatomical condition, and validate that exact claim. Changing a
brightness residual does not demonstrate removal or recognition of tissue.

A generated portrait set that meets the feature-specific effect oracle may
close owner-local effect acceptance and permit its taxonomy status to be
updated. Do not withhold that credit solely because the images are not genuine
people. The scope of the claim must identify generated-image validation; it
does not establish behavior across real people, populations, physical devices,
or commercial visual quality. A later real-image finding becomes a new
reproducible defect or follow-up, not a retroactive provenance gate.

Existing historical opt-in fixtures and signed receipts retain their recorded
meaning. For future work, a legacy real-image-only gate must be adapted to
equivalent eligible generated input rather than used to block a milestone for
missing genuine portraits. The normal archive-first, zero-failure, zero-skip
SwiftPM and SDK-owned script checks still apply to the resulting test suite.

## Owner-authorized initial-scope revisions

An explicit owner decision may define a weaker initial capability, narrower input
range, finite coverage or stated error tolerance. Write the changed claim and new
criteria before testing candidates; preserve old requirements, failures and signed
receipts. Reusing an old failure as a known diagnostic is permitted, but it is not
unseen holdout evidence and must not be relabeled a pass against its old contract.
The rule against weakening thresholds after output does not prohibit this explicit,
versioned product-scope change; it prohibits retrospective success claims.

For v1.25 the owner authorized such a revision on 2026-10-03. The frozen historical
[R2 MVP contract](RETOUCH_MVP_REQUIREMENTS.md) defined automatic eyelid-tone correction
and visible-boundary skin-colored patch protection. Numbers are prospective project
choices requiring pre-candidate oracle controls, not proof of feasibility or universal
perception thresholds. Exact key-feature protection, artifact checks, compatibility
and the current engineering gates remain. Photo-wide unknown-input recognition and
full high-quality fat reduction were not implied. Both branches later exhausted their
finite budgets and [closed as unmet](RETOUCH_FINAL_DISPOSITION_2026-10-03.md).
The original criteria remain historical evidence; they create no current G0,
holdout, model or training task. Any new branch requires its own authorized scope
and evidence under this policy.

## Failed and suspended routes

When a candidate improves a target score but fails protection, introduces an
artifact or misses the required effect, retain the failure and reject that
candidate. Do not repeatedly select sources, redefine target regions or relax
thresholds until the same approach passes. Failure does not prove that every
possible algorithm is impossible, and it does not justify promising that more
tuning will succeed.

A suspended effect is not a blocker for unrelated SDK work. Reopening requires
an explicit owner request and a separately stated, falsifiable hypothesis:
freeze the positive/negative inputs, independent effect and protection criteria,
and experiment limits or termination conditions before changing the algorithm.
The hypothesis must motivate the chosen method; this policy does not require
either a learned model or a deterministic implementation. An ordinary request
to continue does not authorize restarting suspended development.

## Current SDK gate inputs

`scripts/run-no-skip-swiftpm.sh` accepts an ignored, owner-controlled generated
portrait through `BEAUTYSDK_VISION_PORTRAIT_FIXTURE`. Set it to a **file name**
inside `example-images/input/portraits/` (for example,
`generated-vision.png`); paths and symbolic links are rejected. The default is
the existing `p1.jpg` for local compatibility, not a genuine-human requirement.
The replacement must still produce the face, eyebrow, and other observed
support required by the existing Apple Vision and public-facade assertions.

The same wrapper accepts generated positive/negative evidence bundles through
`PHASE59_TEETH_BUNDLE` and `PHASE62_SCLERA_BUNDLE`. Each override must point to
an ignored local directory with a `manifest.json` and assets meeting the
existing rights, mask, polarity, pixel, and safety checks. The default bundle
paths are retained for existing local runs. A generated fixture is not rejected
for being generated; an unsuitable input or failed effect oracle still fails.

The suspended upper-eyelid control retains a live Vision compatibility and
regression test using a separate, exact-hash generated base
named `upper-eyelid-generated-base.png` in the same ignored portrait directory.
`BEAUTYSDK_UPPER_EYELID_FIXTURE` may select another local `.png` name containing
those same authorized bytes; it does not admit arbitrary replacement content.
An additional fixed-hash `upper-eyelid-negative-control.png` supplies a second
authorized natural-style flat-lid control. Live face and two-eye observations
must exist before zero admission can count as a pass; all four public outputs
and repeats must preserve its entire RGBA raster, extent, sRGB color space
and dimensions.
The test rejects paths, symbolic links and oversized or mismatched input with
fixed errors. The wrapper now requires nine opt-in tests, including this one.
The calibrated source contains visible programmatic color blocks: its
independent dome/flat/shadow oracle proves the tested programmatic luminance
target through live Vision. It does not establish a natural-appearance range,
skin-texture preservation or tissue recognition. The separate frozen
natural-background challenge remains failed. These retained tests do not
reopen development or reverse the `suspended` disposition in the
[current taxonomy](SDK_EFFECT_TAXONOMY.md).
