# Dense face-mesh feasibility — public assets only

Date: 2026-09-22. Status: candidate research, NOT a source registrar or effect gate.

## Scope and provenance

The tested Vision contour route has no admitted lateral pair. Evaluate a denser
local landmark candidate without changing production, SwiftPM dependencies, the
source/ROI,16 Q16 threshold, siblings or prior failures. No private portrait has
been read by this work. Research assets stay in an isolated temporary directory;
no model/weight is added to the repository or SDK.

Candidate package: MediaPipe0.10.32, an explicitly pinned macOS ARM64 version.
The official PyPI wheel SHA256 is
b62178b7585e0bb8789075c43bbb3e352fbc4a8f765797fded509f86a098b29b
(size19386286). A complete hash-verified wheel is required before use. This is
not a claim that this version is latest or installed.

Primary sources:
- https://pypi.org/project/mediapipe/0.10.32/
- https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker
- https://raw.githubusercontent.com/google-ai-edge/mediapipe/v0.10.32/LICENSE
- https://raw.githubusercontent.com/google-ai-edge/mediapipe/v0.10.32/mediapipe/modules/face_geometry/data/canonical_face_model.obj

The fixed-tag repository LICENSE is Apache2.0, downloaded SHA256
8707eef0533987efc5b155d64761eeb6e20793f50b9bd1a68dad1cf4719d0ed8.
This does not by itself audit the model bundle or every transitive dependency.
The official model cards distinguish landmark estimation accuracy from geometric
truth. Published average error or input-transform stability is not a worst-case
source-boundary uncertainty bound. An incomplete PDF download is not evidence
of a complete local license record; no model inference is authorized here.

## Public canonical prior

The downloaded fixed-tag canonical OBJ has468 vertices and898 triangles, SHA256
8bac80443397e113f41a8b565ea72c59390bc031d9defab289dba7bc0c54e618.
The checker requires this exact asset before parsing. Candidate chain choices
were made from PUBLIC template geometry before any private-image inference:

- inner candidate:55,193,122,196; mirror285,417,351,419;
- outer alternative:55,193,189,244,128; mirror285,417,413,464,357.

These are our geometric hypotheses, not official named anatomical boundary
labels. Both alternatives are retained; successful inner movement must not
silently discard a stationary outer interpretation. Exact mirror coordinates,
strict same-side vertices, descending canonical Y and every adjacent triangle
edge are verified. No edge is invented to complete a chain. The checker exports
only counts/hash and explicit prior-only/nonqualified/nonscoring flags. It does
not output coordinates or process image input.

Six generated tests check mirror/edge/domain/monotonicity rejection, changed
asset/symlink rejection and malformed-input handling in normal and optimized
Python. Successful checks establish template topology only, not real-face
coverage, source ownership, a complete hypothesis set or a localization bound.

## Remaining before any private-image diagnostic

1. Complete hash-verified isolated dependencies and confirm the chosen bundle's
   license and exact identity. Truncated downloads are never installed.
2. Exercise CPU image-mode inference on deterministic generated no-face inputs,
   with no network access and bounded process/output/cleanup, before private IO.
3. Specify source-only semantic ownership, uncertainty and unchanged ROI mapping.
   A predicted mesh vertex cannot automatically be called a visible boundary;
   canonical symmetry must not force source symmetry or hide occluded support.
4. Obtain an independent review binding the complete implementation/model/runtime
   before a bounded source-only observation. Do not redetect each output to
   improve scores or export source geometry. Scoring needs separate admission.

This research does not supersede archived observations or authorize looser
metrics, owner annotation requests, raw private evidence, external distribution,
model training, production ML dependencies or milestone completion.

## Actual runtime acquisition outcome

Repository license and canonical OBJ downloaded completely; public OBJ topology
inspection succeeds (2 hypotheses/4 chains),6 tests pass normal and optimized.
The software wheel was NOT acquired: curl timed out after partial transfer then
reported HTTP2 framing failure; a length-checked range attempt failed before all
parts could be assembled and verified. No incomplete wheel was installed.
The face-mesh model-card PDF is truncated (parser EOF failure), so it is not
credited as a locally verified model-license artifact. The model bundle HEAD
reported3758596 bytes; this is metadata only, not a downloaded model.

An isolated temporary venv was created using the existing bundled Python3.12;
no package was installed. Official-index hash-lock resolution did not complete
and its exactly matched owned process was terminated. A subsequent offline
resolution explicitly reports mediapipe missing from cache. There is no lock,
no working MediaPipe runtime, no CPU inference and no source diagnostic credit.
These failures are network/acquisition limitations, not failed private-image
inference and not automatic-approval rejection. Next progress needs a complete
verified runtime/model acquisition, followed by the remaining review steps above.
