# Project Research Summary

**Project:** Beauty
**Domain:** Remaining local-first face-shape capabilities
**Researched:** 2026-07-21
**Confidence:** HIGH for approved scope, compatibility, and boundaries

## Executive Summary

v1.12 completes four unresolved contour-driven `脸型` rows: `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴`. They can extend the existing unified warp after the detector exposes actual private Vision face-contour and median-line points. The current adapter's synthetic seven-point face-box contour is not sufficient evidence for these new claims.

Double-chin refinement and hairline movement require semantic region support that Apple face landmarks do not expose. Apple person segmentation does not distinguish hair from forehead or a submental fold. Because the repository has no approved local resource or reproducible clean-clone fixture evidence, those rows remain future instead of being simulated by a coarse proxy.

The public contract expands from 48 to 52 stored fields, preserves zero-default legacy JSON/preset/source compatibility, and keeps all observed points request-scoped and package-internal.

## Scope Decision — 2026-07-21

Repository inspection found no approved semantic model, license/provenance/hash metadata, or clean-clone annotated fixtures for hairline or submental regions. The user selected the reduced-scope option rather than authorizing a third-party model. Active v1.12 therefore contains only `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`, expands the model from 48 to 52 stored fields, and uses actual observed contour/median-line support. `去双下巴`, `去双下巴 Pro`, and `发际线` remain future; the `脸型` branch remains `partial`.

The original seven-row analysis below is retained as background research, but `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md` are authoritative for the approved reduced scope.

## Key Findings

### Stack Additions

- Keep SwiftPM, Apple Vision, the existing unified warp, Core Image/Metal-backed output, XCTest, and bounded Python helpers.
- Extend the existing Vision request seam with actual face contour and median line.
- Permit a first-party bundled Core ML/Vision semantic support resource only after provenance, license, hash, platform, memory, and fixture gates pass.
- Add no third-party beauty SDK, runtime model download, cloud service, public geometry type, or face-only render pass.

### Feature Table Stakes

- Four independent positive-only, default-zero public controls.
- Four distinct observed-contour transforms with no semantic-region proxy.
- Field-local missing/malformed/reused/stale degradation and provider-eligible combined accounting.
- Isolated decoded public-facade output, direction/locality/independence evidence, safe no-ops, and ignored-gallery containment.
- Exact four-row promotion while SDK-core `脸型` remains partial, without device/commercial/release claims.

### Watch Out For

1. Synthetic face-box proxies presented as observed contour behavior.
2. Aliasing new rows to the five shipped face fields.
3. Treating a person matte as hairline/submental semantics.
4. Letting a Pro badge create entitlement or network scope.
5. Region leakage into protected facial/background areas.
6. Effective-strength metrics disagreeing with final emitted work.
7. Deferring model provenance and license review until implementation closeout.

## Implications for Roadmap

### Phase 45: Public Contract and Observed Face Support

Deliver the exact 52-field compatibility contract, actual observed contour/median-line mapping, support validation, and private lifecycle. Keep all semantic-region rows future.

### Phase 46: Independent Contour and Chin Geometry

Implement `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` as named, independently eligible emissions through resolver/conflict/facade routing. Lock vector/locality distinction from all shipped face fields.

### Phase 47: Public-Facade Face Output Evidence

Add isolated cases for every scoped control; verify decoded same-dimension output, fixed-region visibility, locality, independence, no-face/missing-contour/malformed-contour no-ops, and ignored gallery.

### Phase 48: Face Safety and Scoped Closeout

Finalize caps/dead zones, all new and existing face-field transitions, provider-eligible multi-domain convergence, redacted diagnostics, active-source/security/artifact gates, exact four-row promotion, and preserved partial `脸型` status.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Exact scope | HIGH | User approved the four-row contour-driven subset after the semantic-resource blocker. |
| Public compatibility | HIGH | Established v1.9-v1.11 defaulted-field pattern. |
| Observed contour geometry | HIGH | Official Vision contour/median-line support and existing mapper seam. |
| Semantic regions | HIGH | Explicitly future until an approved local resource and fixtures exist. |
| Output/safety gating | HIGH | Existing renderer, helper, convergence, and promotion-checker patterns are reusable. |

## Sources

- `.planning/research/STACK.md`
- `.planning/research/FEATURES.md`
- `.planning/research/ARCHITECTURE.md`
- `.planning/research/PITFALLS.md`
- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d)
- [Apple person segmentation](https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest)
- [Apple `MLModelConfiguration`](https://developer.apple.com/documentation/coreml/mlmodelconfiguration)

---
*Research summary for: Beauty v1.12 Face Shape Remaining Capabilities*
