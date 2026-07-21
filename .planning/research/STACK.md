# Stack Research

**Domain:** Local-first iOS SDK remaining face-shape capabilities
**Researched:** 2026-07-21
**Confidence:** HIGH for existing geometry stack; MEDIUM for submental/hairline support until a licensed local resource passes the feasibility gate

## Recommended Stack

| Technology | Version / baseline | Purpose | Decision |
| --- | --- | --- | --- |
| Swift / SwiftPM | Existing Swift tools 6.0 package; observed Swift 6.3.3 | Public model, private support, providers, tests | Keep. No package split. |
| Apple Vision face landmarks | Existing iOS 17+ baseline | Observed cheek-to-chin contour and median-line evidence | Extend the current request once; map private points through `CoordinateMapper`. |
| Core ML + Vision request seam | Existing Apple frameworks | Optional first-party local hair/skin/submental semantic mask | Permit only a repository-approved bundled model with provenance, license, hash, finite output bounds, and no runtime download. |
| Existing unified local warp | Repository implementation | Smooth contour, temple, cheekbone, pointed chin, basic lower-face shaping | Extend named face-field emissions; do not add a face-only render pass. |
| Existing Core Image / Metal-backed output | Repository implementation | Mask-contained refinement and public-facade saved output | Reuse same-dimension render/output path and bounded helper pattern. |
| XCTest + Python standard library | Existing tooling | Contract, support, degradation, strict output, gallery, boundary gates | Keep helpers self-contained and generated artifacts ignored. |

## Stack Decision

Four rows (`面部流畅`, `太阳穴`, `颧骨`, `尖下巴`) can build on actual Vision face contour plus median-line evidence and the existing unified warp. The current repository only records face-contour availability and then synthesizes a seven-point contour from the face box; v1.12 must add private observed face support before claiming these rows independently.

Three rows (`去双下巴`, `去双下巴 Pro`, `发际线`) need region evidence that Apple face landmarks do not provide. Apple documents `faceContour` as cheek-to-chin only. Person segmentation isolates a person from background, not hair from forehead or a submental fold. Therefore these rows require a feasibility gate for a local, repository-approved semantic support implementation. A fabricated face-box region, runtime download, remote API, or unlicensed model is not acceptable completion evidence.

## What Not to Add

| Avoid | Why | Use instead |
| --- | --- | --- |
| Third-party beauty SDK or cloud retouch | Violates local-first, supply-chain, and product ownership boundaries | Apple frameworks plus repository-owned providers/resources. |
| Public/Codable raw contour or masks | Expands biometric-adjacent persistence and diagnostics | Request-scoped package-only support values. |
| Alias new rows to `faceSlim`, `jawSlim`, `faceVShape`, or `chinLength` | Would borrow shipped evidence and make seven false product claims | Independent public scalars and named provider emissions. |
| Treat person matte as a hairline/submental semantic mask | It only separates a person from background | Prove exact semantic eligibility or fail the feasibility gate. |
| Runtime model download | Adds network, cache, integrity, versioning, and privacy behavior | Bundled, versioned, hash-verified local resource only. |
| Tracked generated galleries | Bloats repository and may retain sensitive inputs | Existing ignored output/gallery roots plus artifact scans. |

## Compatibility Contract

- Preserve iOS 17+ and macOS 14+ package platforms unless a separately approved resource forces a change.
- Expand the exact stored model from 48 to 55 fields: 54 numeric fields plus `filterId`.
- Keep all seven new values zero by default; legacy 48-field JSON and bundled preset files remain neutral without textual edits.
- `hairlineHeight` is signed; the other six public controls are positive-only.
- `去双下巴 Pro` maps to a product-neutral independent refinement control, not entitlement or pricing state.

## Sources

- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — normalized regions, face contour, and median line.
- [Apple `faceContour`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/facecontour) — contour covers left cheek through chin to right cheek, not hairline or submental semantics.
- [Apple person segmentation](https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest) — person matte capability and quality-level trade-off.
- [Apple `MLModelConfiguration`](https://developer.apple.com/documentation/coreml/mlmodelconfiguration) — local model configuration and compute-unit selection.
- `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `BeautyFaceGeometryAdapter.swift`, `FaceShapeWarpProvider.swift`, and `SECURITY.md` — current repository seams and boundaries.

---
*Stack research for: Beauty v1.12 Face Shape Remaining Capabilities*
