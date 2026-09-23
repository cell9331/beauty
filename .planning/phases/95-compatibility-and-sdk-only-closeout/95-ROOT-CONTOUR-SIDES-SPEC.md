# Declared-contour lateral support — source-only semantic feasibility

2026-09-22. Separate successor; prior observations and definitions stay immutable.
No metric admission, source registration, candidate scoring or production change.

The topology-correct diagnostic found three cross sections. A cross-midline
closure/cap may produce a second intersection without supporting the opposite
root side. The same problem could occur at ANY segment index, so last-to-first
is neither categorically accepted nor categorically rejected.

Retain original16 row bins, ROI, midpoint, actual Vision topology and every
intersection/ambiguity rule. At each crossing, label the entire original segment
left only if both endpoints are strictly left of midpoint, right only if both
are strictly right, otherwise non-lateral. Coincident crossings with incompatible
incident labels retain non-lateral ambiguity, never choose the favorable edge.
A geometrically paired row has lateral support only if its left crossing is
supported by a left segment AND its right crossing by a right segment.

This is a conservative sufficient geometric rule, not an anatomical theorem or
claim that every natural root must satisfy it. It does not use outputs, arbitrary
angle thresholds, guessed closure, emitted warp points or assumed detector
accuracy. A declared closing segment that actually completes a same-side contour
can pass. A cross-midline cap must not become a side merely by changing path start.

Counters export paired/ambiguous/unsupported rows (sum16) plus side_supported and
cap_dependent (sum paired). All are integers0..16. All qualification/acceptance
flags remain false even if lateral support is found. No coordinates, raw pixels,
private paths or child transcripts persist. Existing source/contract admission,
bounded in-memory Swift transport and repeated-run snapshot validation remain.

Generated34 checks retain all23 previous cases and add a valid closing side,
a slanted cap that fabricates bilateral intersections, all cyclic starts and
reversals of that cap, a midline endpoint with no strict lateral support, and
coincident incident-label conflicts in both path directions.
This diagnostic alone does not verify actual pixel correspondence or detector
localization error. Half-pixel quantization is not a detector error certificate.

Independent review binds --review-inputs15 files with schema
phase95-contour-sides-review-v1, status pass, reviewer_agent_id, exact files and
empty findings, in95-ROOT-CONTOUR-SIDES-REVIEW.json. It permits one invocation
containing two source-only calls using the previously verified unsandboxed Vision
environment. No automated retries or subsequent scoring. A nonempty side cohort
would still require versioned width/uncertainty semantics and pixel validation;
an empty cohort cannot be repaired by lowering the old12-row threshold.
