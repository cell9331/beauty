---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T07:54:13Z
depth: standard
files_reviewed: 5
files_reviewed_list:
  - /tmp/beauty-root-mesh-lab/face_landmarker.task.partial
  - /tmp/beauty-root-mesh-lab/canonical_face_model.obj
  - /tmp/beauty-root-mesh-lab/face_geometry_from_landmarks_graph.cc
  - /tmp/beauty-root-mesh-lab/geometry_pipeline_metadata.proto
  - /tmp/beauty-root-mesh-lab/mesh_3d.proto
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
review_scope: offline-public-asset-and-declared-index-relationship
runtime_execution: false
private_source_permission: false
measurement_admission: false
portrait_acceptance: false
---

# Public mesh index relationship review

## Narrative Findings (AI reviewer)

The stated static asset/index relationship is independently confirmed for the
exact files below. No unresolved BLOCKER or WARNING was found in that bounded
claim. This is not a model-runtime, license, anatomical or private-image approval.

The reviewer read the supplied inspection script as context, then used a separate
in-memory ZIP/protobuf parser and independent comparisons. No model was executed,
package installed, network accessed, private image read or asset extracted into
the repository. Existing specifications and reviews were not changed.

## Independently established facts

The file named face_landmarker.task.partial is 3,758,596 bytes and matches the
expected SHA-256. Despite its suffix, it is a complete readable ZIP for this
pinned identity: four uniquely named members pass ZIP CRC checks and bounded
size checks. This says nothing about executing or licensing its model contents.

The embedded geometry metadata decodes under the supplied proto definitions:

- Exactly one canonical mesh; input_source is 1, FACE_LANDMARK_PIPELINE.
- Vertex type 0 is VERTEX_PT: five float32 values per vertex, XYZ followed by UV.
- Primitive type 0 is TRIANGLE: three uint32 vertex indices.
- 468 vertices, finite float values and 898 triangles with indices in 0..467.

Every canonical OBJ XYZ position, rounded to float32, matches the embedded
XYZ bytes at the SAME vertex index: 468/468. This is an ordered identity check,
not a coordinate-set comparison or nearest-neighbor remapping.

The triangle comparison is stronger than the initial set claim:
all 898 oriented index triples occur in the same sequence as the OBJ.
The unordered triangle multiset also matches, with 898 unique triangles and
no repeated-index triangle. Duplicate faces cannot be hidden by set equality.

These checks establish XYZ/vertex-ID and triangle-index identity. UV equivalence
was not separately compared and is not needed for the stated candidate-chain
vertex/edge relationship.

## Source-declared landmark relationship

The supplied geometry_pipeline_metadata.proto:52-56 explicitly associates
canonical mesh vertex IDs with face landmark IDs. mesh_3d.proto:22-40 defines
the checked packed vertex and triangle layouts.

The supplied face_geometry_from_landmarks_graph.cc:58-62 configures a split
beginning at 0 and ending at 468, with a comment identifying the first 468 face
landmarks and exclusion of iris landmarks. Its graph connects that split
landmark stream through the end-loop node to the geometry pipeline at
lines 168-191. This is a declared [0,468) geometry-input convention, not an
assumption that a 478-landmark result has an unrelated 468-point ordering.

Consequently, the earlier generic 478-versus-468 static compatibility question
is resolved for this exact bundle metadata and the supplied graph/schema
contract. Candidate canonical vertex IDs in 0..467 have an explicit source
contract for their corresponding non-iris landmark IDs. This does not establish
that an installed runtime actually executes these source files or uses this
bundle; that binding remains to be checked when a runtime exists.

The source files were supplied as fixed-version public assets. This offline
review binds their actual hashes; it did not independently re-fetch or
authenticate the repository tag or download provenance.

## Remaining boundaries

Index compatibility does not label a selected path as a visible root side,
prove candidate-set completeness, validate source ROI coverage, supply a
detector uncertainty bound or justify symmetry/visibility on an individual face.
Those semantic gaps in the public-prior review remain.

CRC, model-member hashes and geometry parsing do not demonstrate valid inference,
the model's actual output shape under a selected runtime, package compatibility,
license approval or output-pixel effect correctness. No private source or
generated inference permission follows from this report. No approval JSON,
source registration or milestone receipt was created.

## Exact input identities

All five inputs reside in the public temporary research directory named in the
scope above. Their bytes were read without modification.

| Public asset | Bytes | SHA-256 |
| --- | ---: | --- |
| canonical_face_model.obj | 45999 | 8bac80443397e113f41a8b565ea72c59390bc031d9defab289dba7bc0c54e618 |
| face_geometry_from_landmarks_graph.cc | 8744 | 9ee9a5c6a81c59cb4d7fe91fd7a46bf56ed91a3cad287e57c69e9caf5eb726fa |
| face_landmarker.task.partial | 3758596 | 64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff |
| geometry_pipeline_metadata.proto | 2430 | 4c8605cbe4fd4f8e01fb49dd78238c80057c1cd7e6d7f0bc2547035834ae9950 |
| mesh_3d.proto | 1369 | 91f6f0dafc51e370929ddf88963817ec9b6607952bb4b86c1928039f91488db3 |

## Bundle member identities

| Member | Bytes | SHA-256 |
| --- | ---: | --- |
| face_blendshapes.tflite | 955312 | 4f36dded049db18d76048567439b2a7f58f1daabc00d78bfe8f3ad396a2d2082 |
| face_detector.tflite | 229746 | b4578f35940bf5a1a655214a1cce5cab13eba73c1297cd78e1a04c2380b0152f |
| face_landmarks_detector.tflite | 2553590 | c7d54204ce0448474c7f3fa9af494787c0965cbdd6f20fc72867e43046bd43d5 |
| geometry_pipeline_metadata_landmarks.binarypb | 19376 | bdbcda96dfcb7da883da124aaa2c55dee49770d934f0fcc71747f8c21bdc75b4 |

_Independent reviewer: closeout-review-20260922. Offline public-asset inspection only._
