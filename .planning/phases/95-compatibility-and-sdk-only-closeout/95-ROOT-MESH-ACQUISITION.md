# Dense-mesh acquisition continuation — 2026-09-22

Status: public-only research; no installation, inference, source registration or
milestone acceptance. The earlier feasibility specification and its review are
unchanged; their acquisition statements describe the earlier attempt.

## Completed model-card recovery

Bounded HTTP/1.1 resume recovered the complete official Face Mesh V2 model card:
https://storage.googleapis.com/mediapipe-assets/Model%20Card%20MediaPipe%20Face%20Mesh%20V2.pdf

Length3476420 bytes; SHA256
c6add060f4ebfb37b2690136b6c711c7e5fcb7038baa2649ae3338b83979565a.
Strict local PDF parsing succeeds for all7 pages. This is the observed artifact
identity, not a separately published authoritative digest. The earlier truncated
file is not reused as evidence.

The card states Apache2.0 and478 output landmarks, with10 additional iris points
in its release notes. Its error statistics average across landmarks and samples;
they do not establish a per-root-point worst-case localization interval. This
card alone does not bind the exact downloaded task bundle or its other models.

## Index mapping investigation

Fixed v0.10.32 primary implementation sources:
- https://raw.githubusercontent.com/google-ai-edge/mediapipe/v0.10.32/mediapipe/tasks/cc/vision/face_landmarker/face_landmarker_graph.cc
- https://raw.githubusercontent.com/google-ai-edge/mediapipe/v0.10.32/mediapipe/tasks/cc/vision/face_geometry/libs/geometry_pipeline.cc

The landmarker graph reads geometry_pipeline_metadata_landmarks.binarypb from
its task bundle when geometry is requested. Geometry conversion checks landmark
count against the canonical matrix. This identifies a concrete next check:
compare the selected bundle canonical metadata and indexing to the pinned OBJ,
instead of inferring compatibility from package names. No index mapping is
admitted by this note. Even a matching mapping would not qualify candidate nose
paths as visible root-width landmarks or bound their instance prediction error.

## Acquisition controls

Downloads contain public assets only and stay outside the repository. Curl calls
have connection and wall-clock deadlines; wheel continuation has bounded attempt
count and stops after consecutive no-progress attempts. Only the complete wheel
matching the already pinned official size and SHA256 may be used. No private
fixture, derived support or repository content is sent to the download hosts.

## Complete bundle static observation

The official float16/1 task bundle was fully recovered,3758596 bytes, SHA256
64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff.
All four ZIP members pass CRC validation; nothing is loaded as executable code.
Observed identities (not independently published upstream checksums):

| Public member | Bytes | SHA256 |
| --- | --- | --- |
| face_detector.tflite | 229746 | b4578f35940bf5a1a655214a1cce5cab13eba73c1297cd78e1a04c2380b0152f |
| face_landmarks_detector.tflite | 2553590 | c7d54204ce0448474c7f3fa9af494787c0965cbdd6f20fc72867e43046bd43d5 |
| geometry_pipeline_metadata_landmarks.binarypb | 19376 | bdbcda96dfcb7da883da124aaa2c55dee49770d934f0fcc71747f8c21bdc75b4 |
| face_blendshapes.tflite | 955312 | 4f36dded049db18d76048567439b2a7f58f1daabc00d78bfe8f3ad396a2d2082 |

A bounded temporary standard-library protobuf inspection, following the fixed
upstream schemas, finds468 vertices and898 triangles. All468 XYZ positions match
the pinned OBJ at float32 precision in index order. Triangle sets also match.

The fixed upstream FaceGeometryFromLandmarksGraph explicitly takes indices
[0,468) from the detected landmarks before geometry conversion:
https://raw.githubusercontent.com/google-ai-edge/mediapipe/v0.10.32/mediapipe/tasks/cc/vision/face_geometry/face_geometry_from_landmarks_graph.cc

Its SHA256 is9ee9a5c6a81c59cb4d7fe91fd7a46bf56ed91a3cad287e57c69e9caf5eb726fa.
The geometry metadata schema states that canonical vertex IDs and landmark IDs
are the same; its SHA256 is
4c8605cbe4fd4f8e01fb49dd78238c80057c1cd7e6d7f0bc2547035834ae9950.
Mesh schema SHA256 is
91f6f0dafc51e370929ddf88963817ec9b6607952bb4b86c1928039f91488db3.
Both schemas come from the same v0.10.32 face_geometry/proto directory.

This supports the selected public assets' index correspondence. It does not
establish anatomical meaning of our selected root paths, source visibility,
localization bounds or an inference result. Independent static review is complete:95-ROOT-MESH-INDEX-REVIEW.md confirms
the468 ordered XYZ matches and the entire898-triangle oriented index sequence,
plus the upstream[0,468)mapping. It grants no runtime or measurement admission.

## Complete wheel recovery

The fixed MediaPipe0.10.32 macOS ARM64 wheel completed at19386286 bytes;
SHA256 b62178b7585e0bb8789075c43bbb3e352fbc4a8f765797fded509f86a098b29b
matches the previously pinned official PyPI checksum. All ZIP members pass CRC.
Static METADATA identifies Apache2.0 and declares absl-py~=2.3, numpy,
sounddevice~=0.5, flatbuffers~=25.9, opencv-contrib-python and matplotlib.
The wheel includes libmediapipe.dylib. No wheel module or native library has been
executed. Complete acquisition of these two primary artifacts is now resolved;
installed dependency completeness, license review and generated CPU inference
remain separate and unverified.

## Remaining dependency resolution failure

A new official-index hash-lock resolution used the completed local wheel and an
isolated cache. The wrapper imposed90 seconds wall time with owned process-group
cleanup; uv used15-second HTTP timeout and zero automatic retries. It exited2
before the wrapper deadline because https://pypi.org/simple/absl-py/ timed out.
No lock was produced and no installation/inference took place. The next attempt
must reuse the verified primary assets and address dependency acquisition rather
than redownload the wheel or task. No permission rejection or user annotation
request is involved.

## Dependency recovery continuation

A system-TLS uv resolution also exceeded its50-second wrapper deadline; its
owned process group was cleaned. Switching to the official PyPI JSON endpoint
recovered absl-py2.3.1 completely:135811 bytes, official SHA256
 eeecf07f0c2a93ace0772c92e596ace6d3d3996c042b2128459aaae2a76de11d.
ZIP CRC passes; wheel metadata declares Apache-2.0 and its bundled license text
is present. It declares no runtime dependencies. This is acquisition only;
the wheel is not installed. Other MediaPipe dependencies remain unresolved.

## Dependency resolution recovered

The second pip dry-run completed with exit0 using the official index, the complete
local wheel and an absl-py2.3.1 constraint. It resolved18 packages without
installation. Exact names, versions and archive SHA256 values are recorded in
95-ROOT-MESH-DEPENDENCY-RESOLUTION.json. The corresponding temporary hash-pinned
requirements.lock SHA256 is
f8ba252e0f40533ac46813c8b9e3e1964f84f6e9802aa5b09cea6a467b6381bb.
This supersedes dependency-resolution failure as the current status, while
preserving prior failures. Only metadata resolution is complete: full dependency
wheel acquisition, license review, isolated installation and generated CPU
inference remain. No private image or model execution occurred.

## Complete dependency acquisition

All18 selected wheels are now complete,99928045 bytes in total, each matching
the hash-pinned resolution and passing ZIP CRC. The last OpenCV archive was
retrieved with checked Content-Range segments and the final full SHA256, not
accepted on segment success alone. No package or model has yet been executed.

License preflight for the isolated owner-local generated-input evaluation reads
wheel metadata and bundled license notices. Declared package licenses are
Apache2.0, MIT/MIT-0/MIT-CMU, BSD-family, matplotlib's permissive license, and
NumPy's listed permissive component licenses. OpenCV also carries a separate
third-party notice (179634 bytes); no redistribution or SDK packaging is proposed.
Flatbuffers lacks a separate dist-info LICENSE but its module header and metadata
both explicitly identify Apache2.0. Preserve all installed notices.

Official model cards checked in this continuation:
- https://storage.googleapis.com/mediapipe-assets/MediaPipe%20BlazeFace%20Model%20Card%20(Short%20Range).pdf
- https://storage.googleapis.com/mediapipe-assets/Model%20Card%20Blendshape%20V2.pdf
- Face Mesh V2 card already recorded above.

The three cards identify Apache2.0; the official Face Landmarker guide links its
model bundle and constituent model documentation. This records the published
license declarations for this bounded use, not a new claim about detector
accuracy, a distribution approval or an independent audit of training data.
Runtime execution remains separate from static asset and index checks.

## Isolated installation and executed generated CPU validation

All18 packages were installed offline with --no-index and --require-hashes in a
fresh runtime whose include-system-site-packages is false. The independent
runtime review confirms2587 installed payload files match the verified wheels.
Composite third-party notices remain intact; top-level permissive declarations
are not a complete licensing inventory.

The final strict-protocol wrapper actually passed:12 generated constant-color
inputs across two dimensions and two fresh detector contexts, zero detected
faces, unchanged input arrays, CPU/IMAGE mode, Python-I and enforced network
denial. The first attempt could not start nested sandbox-exec inside the outer
sandbox; the reviewed wrapper was then run outside that outer restriction while
retaining its child deny-network sandbox. This was an environment launch issue,
not a failed face test. A final run after strict JSON validation was added passed.

95-ROOT-MESH-RUNTIME-OBSERVATION.json records fixed aggregates and identities.
This resolves acquisition/installation/generated no-face runtime mechanics only;
positive face localization, source semantics and effect acceptance are separate.
A new source-only worker also rejected a generated black64x64 input through its
bounded private-pipe protocol. Native RGB-export code compiled with its source
entry replaced by a fixed marker; no source image was read by that compile check.
