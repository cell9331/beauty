# Stack Research

**Domain:** Local-first iOS SDK eye geometry controls
**Researched:** 2026-07-16
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
| --- | --- | --- | --- |
| Swift / SwiftPM | Swift tools 6.0; observed Swift 6.3.3 | Public model, detector seam, providers, tests | Existing package and concurrency boundaries already own every required capability. |
| Apple Vision | iOS 17 deployment baseline | Eye contours and optional pupil locations | `VNFaceLandmarks2D` exposes left/right eye outlines and left/right pupil points in face-bounds-normalized coordinates. |
| Existing unified local warp | Repository implementation | Contour, lid, corner, pupil, correction, and symmetry vectors | Preserves the single geometry pipeline and public `BeautySDK` facade. |
| Core Image / Metal-backed render path | Existing platform stack | Still-image output evidence | Already produces deterministic same-dimension facade output without a new render pass. |

### Supporting Tools

| Tool | Purpose | When to Use |
| --- | --- | --- |
| XCTest | Contract, geometry, degradation, facade, and boundary evidence | Every phase; table-driven for scalar contracts and focused tests for vector semantics. |
| Python 3 standard library | Strict decoded output and gallery checks | Phase 43; keep the helper self-contained and bounded. |
| Existing promotion checker pattern | Active-source/privacy/artifact fail-closed gate | Phase 44 before any ledger row changes. |

## Stack Decision

No package, target, third-party SDK, model download, network service, or new public result type is needed. The one material stack change is how existing Vision results are represented internally: v1.11 needs private, frame-scoped normalized eye-contour and pupil support rather than availability-only symmetric proxies for advanced correction fields.

## What NOT to Use

| Avoid | Why | Use Instead |
| --- | --- | --- |
| Third-party face/beauty SDK | Adds privacy, licensing, binary, and supply-chain scope | Apple Vision plus existing package-owned warp. |
| Core ML gaze model | A new model/resource/runtime contract is not required for bounded center correction | Validate pupil position relative to its observed eye contour. |
| Persisted landmarks or public geometry types | Expands biometric-adjacent data exposure | Package-internal, frame-scoped value support consumed before public results. |
| Deterministic symmetric proxy points for gaze/symmetry evidence | Cannot represent an observed offset or asymmetry | Actual private contour/pupil points with strict validation. |
| New eye-only render pass | Splits conflict accounting and output behavior | Existing unified local warp and facade route. |

## Version Compatibility

| Component | Compatible With | Notes |
| --- | --- | --- |
| `BeautySDK` package | iOS 17+, macOS 14+ | Preserve current `Package.swift` platforms and tools version. |
| Legacy public model | Exact 38 stored fields | Missing ten v1.11 keys must decode to zero; new inventory becomes 48 stored fields = 47 numeric plus `filterId`. |
| Existing presets | Current bundled JSON | Leave payloads textually unchanged; missing keys prove neutral compatibility. |
| Existing eye fields | `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift` | Zero-default new fields must not change their vectors, caps, or evidence. |

## Sources

- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — eye contours, pupil regions, and face-bounds-normalized coordinates.
- [Apple `VNFaceLandmarkRegion2D`](https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d) — normalized point arrays and point counts.
- [Apple `leftPupil`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil) — optional pupil location and documented blink inaccuracy.
- `BeautySDK/Package.swift`, `EyeWarpProvider.swift`, `VisionFaceDetector.swift`, and `BeautyFaceGeometryAdapter.swift` — current repository stack and integration seams.

---
*Stack research for: Beauty v1.11 Eye Remaining Geometry Controls*
*Researched: 2026-07-16*
