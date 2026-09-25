# Image Effect Acceptance Policy (2026-09-24)

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

Before observing candidate output, define a generated positive that visibly
contains the target condition, a negative that lacks it or should remain
unchanged, and the source-fixed target and protected regions. The inputs must
be capable of testing the claimed effect; a changed-pixel count alone is not
evidence of the intended direction. Use the public SDK path and assert the
applicable output pixels, direction or visual improvement, negative behavior,
protection, bounded change, neutral identity, repeatability, dimensions,
orientation/mirroring, color space, alpha, and typed failure/recovery. Human
original-detail review of generated portrait outputs may supplement objective
metrics where visual judgment is part of the claim. Record failures honestly;
do not weaken thresholds after viewing output.

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
