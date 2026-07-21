# Project Research Summary

**Project:** Beauty
**Domain:** Remaining local-first face-shape capabilities
**Researched:** 2026-07-21
**Confidence:** HIGH for exact scope, compatibility, and boundaries; MEDIUM for local semantic-region implementation until the first phase feasibility gate

## Executive Summary

v1.12 should complete exactly seven unresolved `脸型` rows: `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, and `发际线`. Four are bounded geometry problems that can extend the existing unified warp after the detector exposes actual private Vision face-contour and median-line points. The current adapter's synthetic seven-point face-box contour is not sufficient evidence for these new claims.

Double-chin refinement and hairline movement require semantic region support that Apple face landmarks do not expose. Apple person segmentation is useful context but does not distinguish hair from forehead or a submental fold. The milestone must therefore begin with a fail-closed local-resource feasibility gate. Only a bundled, licensed, versioned, hash-verified, no-network support implementation may unlock those rows; otherwise they remain blocked instead of being simulated by a coarse proxy.

The public contract expands from 48 to 55 stored fields, preserves zero-default legacy JSON/preset/source compatibility, and keeps all contours/masks request-scoped and package-internal. “Pro” is an independent higher-fidelity local refinement control, never payment or entitlement state.

## Key Findings

### Stack Additions

- Keep SwiftPM, Apple Vision, the existing unified warp, Core Image/Metal-backed output, XCTest, and bounded Python helpers.
- Extend the existing Vision request seam with actual face contour and median line.
- Permit a first-party bundled Core ML/Vision semantic support resource only after provenance, license, hash, platform, memory, and fixture gates pass.
- Add no third-party beauty SDK, runtime model download, cloud service, public geometry type, or face-only render pass.

### Feature Table Stakes

- Seven independent default-zero public controls; `hairlineHeight` signed, the other six positive-only.
- Four distinct observed-contour transforms, basic and refined double-chin behavior, and signed hairline movement.
- Field-local missing/malformed/reused/stale degradation and provider-eligible combined accounting.
- Isolated decoded public-facade output, direction/locality/independence evidence, safe no-ops, and ignored-gallery containment.
- Exact seven-row promotion and SDK-core `脸型` branch closeout without device/commercial/release claims.

### Watch Out For

1. Synthetic face-box proxies presented as observed contour behavior.
2. Aliasing new rows to the five shipped face fields.
3. Treating a person matte as hairline/submental semantics.
4. Letting a Pro badge create entitlement or network scope.
5. Region leakage into protected facial/background areas.
6. Effective-strength metrics disagreeing with final emitted work.
7. Deferring model provenance and license review until implementation closeout.

## Implications for Roadmap

### Phase 45: Public Contract and Local Face Support

Deliver the exact 55-field compatibility contract, actual observed contour/median-line mapping, support validation, private lifecycle, and semantic-resource feasibility gate. No downstream mask-dependent row may proceed on a coarse proxy.

### Phase 46: Independent Contour and Chin Geometry

Implement `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` as named, independently eligible emissions through resolver/conflict/facade routing. Lock vector/locality distinction from all shipped face fields.

### Phase 47: Double-Chin and Hairline Region Pipeline

Implement basic `doubleChinReduction`, distinct mask-contained `doubleChinRefinement`, and signed `hairlineHeight` using the approved local support. Lock containment, field-local failure, and no-network/resource boundaries.

### Phase 48: Public-Facade Face Output Evidence

Add isolated cases for every control and both hairline directions; verify decoded same-dimension output, fixed-region visibility, direction, independence, basic-versus-refined distinction, no-face/no-mask no-ops, and ignored gallery.

### Phase 49: Face Safety and Branch Closeout

Finalize caps/dead zones, all new and existing face-field transitions, provider-eligible multi-domain convergence, redacted diagnostics, active-source/security/resource/artifact gates, exact seven-row promotion, and branch-level `脸型` completion.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Exact scope | HIGH | Repository ledger names exactly seven unresolved rows. |
| Public compatibility | HIGH | Established v1.9-v1.11 defaulted-field pattern. |
| Observed contour geometry | HIGH | Official Vision contour/median-line support and existing mapper seam. |
| Semantic regions | MEDIUM | Boundary is clear; an acceptable local support resource must still be proven. |
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
