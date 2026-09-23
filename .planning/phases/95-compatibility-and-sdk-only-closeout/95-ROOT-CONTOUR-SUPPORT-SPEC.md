# Source contour support feasibility — 2026-09-22

Diagnostic only. The existing Vision nose polyline may or may not provide two
observed sides in the original root ROI. Vertical extent alone is insufficient.
Do not create an implicit closing edge, extend endpoints, replace the nose with
crest points, choose inner texture or read any output image.

Retain the original16 bin centers and integer ROI midpoint. Intersect every
consecutive observed nose segment with each row, within the original X bounds.
Deduplicate identical intersections; horizontal segments on a row are ambiguous.
Exactly two intersections on opposite sides of the midpoint count as paired.
More than two intersections count as ambiguous. Every other row is unsupported.
These counters partition16 rows. Generated tests cover full/partial bilateral,
single-sided, multiple crossings, clipping, horizontal, open path, reversal and
invalid input. Exact Double endpoint arithmetic is a diagnostic convention, not
a certified anatomical or subpixel measurement. Eye exclusions are not applied
here: paired counts are only an upper-bound feasibility observation, not admission.

Reuse the unchanged pinned source admission, canonicalization and bounded
in-memory Swift transport. Original source/contracts identity is checked before
and after source access. Only aggregate counts, identities and explicit false
qualification flags leave memory; no geometry, images, private paths or child
transcripts persist. Failures are generic sanitized output.

Before private source access an independent review must bind --review-inputs
with schema phase95-contour-support-review-v1, status pass, reviewer_agent_id,
files and empty findings. This permits exactly two source-only runs in this
investigation. They must agree and the snapshot must remain unchanged. No retries
or scoring follow automatically. Any successor definition needs its own review.

Even paired16 is not a width registration: polyline topology, root ownership,
localization uncertainty, source pixel correspondence, neutral, three siblings
and protection checks are still required. This observation cannot issue a
measurement admission, effect PASS, milestone receipt or manual-owner task.
