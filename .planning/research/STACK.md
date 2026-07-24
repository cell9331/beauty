# Stack Research

**Domain:** Local-first SDK eyebrow geometry
**Researched:** 2026-07-24
**Confidence:** HIGH

## Recommended Stack

| Technology | Baseline | v1.13 role | Decision |
| --- | --- | --- | --- |
| Swift / SwiftPM | Existing tools 6.0 package, iOS 17+, macOS 14+ | Public model, private support, providers, tests, renderer | Keep unchanged. |
| Apple Vision `VNFaceLandmarks2D` | Installed iPhoneOS 26.5 SDK | `leftEyebrow` and `rightEyebrow` open traces | Extend the existing single landmarks request; add no second request. |
| Existing `CoordinateMapper` | Repository implementation | Face-local Vision points to image-normalized support | Map accepted points exactly once with the same orientation/mirror metadata. |
| Existing unified local warp | Repository implementation | Seven named eyebrow transforms | Extend provider-owned emissions; add no separate global render pass. |
| Core Image / Metal-backed output | Repository implementation | Same-dimension public-facade evidence | Reuse the current local warp and renderer/helper/gallery pattern. |
| XCTest + bounded Python helper | Existing tooling | Contract, degradation, output, security, artifact gates | Keep self-contained; generated images remain ignored. |

## Stack Decision

The installed Apple Vision headers expose `leftEyebrow` and `rightEyebrow` as `VNFaceLandmarkRegion2D` traces. v1.13 therefore needs no third-party runtime, model, download, or resource pack. The detector should copy only point values from the existing request, map them through the current request-local coordinate boundary, and discard framework objects immediately.

All seven tools can be specified as bounded geometry over the observed traces:

- vertical position: whole-trace signed translation;
- thickness: signed trace-normal expansion/compression of a protected local strip;
- length: signed endpoint-local extension/contraction;
- spacing: symmetric whole-brow horizontal translation;
- inner-head spacing: inner-endpoint-local horizontal adjustment;
- tilt: signed rotation about each brow center;
- peak: positive-only apex definition relative to the local endpoint chord.

Thickness remains geometry, not eyebrow makeup, texture synthesis, hair generation, or an asset schema.

## Compatibility Contract

- Expand `BeautyParameters` from 52 to exactly 59 stored fields: 58 numeric values plus `filterId`.
- Keep all seven additions default-zero, finite-normalized, Codable, and source-compatible through defaulted initializer arguments.
- Preserve bundled preset bytes and legacy 52-field payload neutrality.
- Add no SwiftUI/Demo source, dependency, network/cloud path, account/commercial behavior, or tracked generated image.

## What Not to Add

| Avoid | Reason |
| --- | --- |
| Public/Codable eyebrow points | Raw geometry is biometric-adjacent and must remain request-scoped. |
| Reusing eye contours as eyebrow support | It would fabricate support and blur field-local degradation. |
| Makeup assets or texture synthesis | Outside the geometry-only v1.13 contract. |
| Second Vision request | Duplicates work and can disagree with the selected face/request metadata. |
| Runtime model/resource download | Unnecessary for Vision eyebrow traces and violates local-first scope. |

## Sources

- Installed `Vision.framework/Headers/VNFaceLandmarks.h` — authoritative `leftEyebrow` and `rightEyebrow` region declarations.
- `BeautySDK/Package.swift` — current SPM platforms, targets, dependencies, and resources.
- `VisionFaceDetector.swift`, `BeautyFaceObservation.swift`, `BeautyFaceGeometryAdapter.swift` — current request-local mapping seam.
- `GeometryConflictResolver.swift`, existing warp providers, renderer, and phase evidence — current geometry/output pattern.

---
*Stack research for: Beauty v1.13 Eyebrow Geometry Controls*
