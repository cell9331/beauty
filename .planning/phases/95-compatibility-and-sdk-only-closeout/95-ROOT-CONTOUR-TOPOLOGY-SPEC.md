# Declared contour topology — source-only diagnostic successor

2026-09-22. No production, portrait scoring or measurement admission.

The preceding contour diagnostic always used an open sequence. Vision exposes
VNFaceLandmarkRegion2D.pointsClassification; the installed SDK's VNTypes.h defines
disconnected, openPath and closedPath, and VNFaceLandmarks.h describes this as how
the region's points should be interpreted. Ignoring a declared closing segment
can undercount intersections. This is not license to invent a closing segment
for an open curve or turn nose-crest points into an outline.

The successor reads actual source nose pointsClassification. Only closedPath
adds exactly last-to-first; openPath keeps adjacent segments only; disconnected
or unknown types reject. All prior16 rows, ROI midpoint, clipping, horizontal
ambiguity, multiple-intersection rejection and full source identity remain.
Prior10 generated checks remain;13 more cover topology dispatch, rejection of
unconnected support, an open rectangle that needs its declared closing segment,
and all cyclic starts/orientations of that closed rectangle. No topology is
selected from output success or inferred from endpoint proximity.

Only open/closed class, aggregate counts, source/contract hashes and false
qualification flags leave memory. No points, pixels, masks, private paths or
child transcripts persist. The unchanged source admission, canonical recipe,
bounded in-memory Swift transport and strict protocol checks are reused. This
does not prove that every closed polygon edge is a visible root side, or that
a resulting pair defines anatomical width.

Independent review binds15 inputs using --review-inputs and a separate
95-ROOT-CONTOUR-TOPOLOGY-REVIEW.json: schema phase95-contour-topology-review-v1,
status pass, reviewer_agent_id, exact files, empty findings. It permits one
invocation with two source-only runs using the already-established unsandboxed
Vision environment (generated sandbox control previously failed code9). Both
results and snapshots must agree. No repeat or scoring follows automatically.

Old code, specification, review and observation remain immutable. Old paired0
means no pair under its open-sequence convention; it did not inspect topology.
The new result may still be unavailable. Do not lower coverage, infer anatomical
precision from topology, extend the ROI, or claim milestone completion.
