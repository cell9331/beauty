# MediaPipe Face Landmarker provenance

Owner-local iOS dependency authorized on 2026-10-09. Inference performs no
network requests. No training, conversion or external distribution is included.

- Runtime: MediaPipe Tasks iOS **1.1.0**, three binary targets in
  [Package.swift](../../Package.swift). URLs and SHA-256 match the
  [official v1.1.0 manifest](https://github.com/google-ai-edge/mediapipe/blob/v1.1.0/Package.swift).
  Platform dependencies and linker flags apply only to iOS. The graph ZIP's
  payload is `MediaPipeTaskGraphs_library.xcframework`.
- Bundled model: [face_landmarker.task](../../Sources/BeautyDetection/Resources/face_landmarker.task),
  official [float16/1 source](https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task),
  3,758,596 bytes, SHA-256
  `64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff`.
  This SHA is independently measured, not an upstream SHA publication. The
  download's MD5 matched the official object ETag. Initialization rechecks size
  and SHA-256 before using the model.
- [Upstream license](LICENSE): Apache-2.0 with the upstream file's exceptions
  preserved. The task bundle's three model cards explicitly declare Apache-2.0:
  [BlazeFace short range](https://storage.googleapis.com/mediapipe-assets/MediaPipe%20BlazeFace%20Model%20Card%20%28Short%20Range%29.pdf),
  [Face Mesh V2](https://storage.googleapis.com/mediapipe-assets/Model%20Card%20MediaPipe%20Face%20Mesh%20V2.pdf),
  [Blendshape V2](https://storage.googleapis.com/mediapipe-assets/Model%20Card%20Blendshape%20V2.pdf).
  Verified source/card hashes are in the initial
  [download record](../../../plans/history/2026-10/A-2026-10-09-mediapipe-landmarker-probe.md).
- Semantic point indices/paths follow
  [v1.1.0 face connections](https://github.com/google-ai-edge/mediapipe/blob/v1.1.0/mediapipe/tasks/python/vision/face_landmarker.py)
  and [canonical face model](https://github.com/google-ai-edge/mediapipe/blob/v1.1.0/mediapipe/modules/face_geometry/data/canonical_face_model.obj).
  Our left/right convention is upright image side. Eye/nose/lip/oval edges are
  upstream topology; median/root/tip paths are selected SDK adapter subsets.

The upstream calculator registry requires `-all_load`. BeautySDK is a local-path
SwiftPM consumer; these unsafe linker flags do not establish compatibility with
remote version-based package consumption or third-party distribution.
Blendshapes remain disabled because existing effects do not use them. Dense
landmarks and the optional row-major pose matrix are package-only data: ordinary
calls keep them request-local, while explicit prepared-photo editing retains
valid observations only for its immutable engine-owned source until release,
replacement or reset. They are never persisted;
neither appears in standard render diagnostics or persisted evidence. The
owner-only `OwnerDiagnostics` SPI separately permits transient x/y overlay points,
with aggregate-only descriptions/reflection and no persistence or pose export. The transform is
not used as a substitute for the current 2D warp algorithms.

The pinned [iOS result helper](https://github.com/google-ai-edge/mediapipe/blob/v1.1.0/mediapipe/tasks/ios/vision/face_landmarker/utils/sources/MPPFaceLandmarkerResult%2BHelpers.mm)
copies packed column-major MatrixData without its layout metadata. The
[matrix accessor implementation](https://github.com/google-ai-edge/mediapipe/blob/v1.1.0/mediapipe/tasks/ios/vision/face_landmarker/sources/MPPFaceLandmarkerResult.mm)
indexes that buffer as row-major. The SDK explicitly converts
[the documented packed layout](https://github.com/google-ai-edge/mediapipe/blob/v1.1.0/mediapipe/framework/formats/matrix_data.proto)
to row-major before validating the homogeneous row/determinant. Native positive
tests check that valid pose survives this bridge.
