# Owner-local MediaPipe iOS SDK verification

This is test source, not an application target. It exercises the current
BeautySDK local-path product in a separately authorized external iOS host.
The host supplies two authorized bundle fixtures named `portrait_001.jpg` and
`portrait_002.png`; no images, decoded pixels, raw points or private fixture
locations are tracked here. Missing fixtures fail the positive tests.

The external host's XCTest target includes this source plus:

- `BeautySDK/Tests/BeautyDetectionTests/MediaPipeAdapterTests.swift`
- `BeautySDK/Tests/BeautyDetectionTests/MediaPipeNativeTests.swift`

Link the **BeautySDK** package product by local path. For package-only assertion
access, the external test target uses Swift flags `-package-name beautysdk` and
Debug testability. This is validation-only access, not a public geometry API.
Application targets import only the public facade for normal SDK use.
The native task/graph dependencies and model bundle come from BeautySDK;
do not also link a second copy of the MediaPipe static runtimes.

Tests check both actual portrait meshes/pose and regional effect support,
public face geometry reaching output pixels, exact repeat output across 20
scheduled calls, no-face recovery/reset, interval/disabled abstention, raster
direction/mirroring, model corruption and bounded native face-budget admission.
They also require usable native pose/visible iris rings and compare the shared
CPU/GPU dense/texture combination, with repeated pixels, extent and alpha.
They do not qualify all effects, segmentation, arbitrary portrait accuracy or
physical-device performance. macOS's complete SwiftPM gate retains its Vision
fixture oracles; this separate native suite supplies the iOS dependency evidence.

Reuse the current single simulator and stable external build directory under
the global testing/storage guides. The whole-package native test scheme also
builds the AppKit command-line product, which is macOS-only; the external host
selects the SDK library and these tests without changing that CLI.
Executed evidence and current temporary harness location belong to the
integration record linked from [PLANS.md](../../PLANS.md).
