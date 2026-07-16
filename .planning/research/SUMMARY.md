# Project Research Summary

**Project:** Beauty
**Domain:** Remaining local-first eye geometry controls
**Researched:** 2026-07-16
**Confidence:** HIGH for scope and boundaries; MEDIUM for final calibration

## Executive Summary

v1.11 can complete ten unresolved eye geometry rows without a new dependency, target, facade method, or render pass. The existing Swift/Vision/unified-warp stack is sufficient, but the current availability-only symmetric eye proxy is not sufficient for honest pupil, gaze, or symmetry behavior. The required architectural addition is package-internal, frame-scoped observed eye contour and optional pupil support derived from the existing Vision landmark request.

The milestone should include `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称`. It should exclude `去脂` and `祛红血丝`, which belong to retouch/color ownership. The largest risks are coordinate/side inversion, blink-inaccurate pupil input, aliases between similar controls, overaggressive automatic correction, and accounting that claims work the provider did not emit.

## Key Findings

### Recommended Stack

- Keep SwiftPM, Apple Vision, Core Image/Metal-backed output, the existing unified local warp, XCTest, and the bounded Python helper pattern.
- Add no dependency or public geometry API.
- Extend only the private detection-to-effects seam with validated request-scoped eye support.

### Expected Features

**Must have:** ten independent default-zero public controls, exact 38-to-48 compatibility, observed contour/pupil support, fourteen named eye emissions, isolated facade output, exact safety/degradation, and redacted diagnostics.

**Defer:** eye-fat removal, redness removal, manual gaze redirection, Demo UI, device/commercial/performance/packaging/launch claims.

### Architecture Approach

Detection converts Vision eye contours and optional pupils into a private canonical coordinate representation. The adapter derives side-aware supports; the provider emits each of fourteen eye fields independently; the resolver removes unsupported work before and after conflict scaling; the unified warp renders; the facade exposes only images and aggregate redacted evidence.

### Critical Pitfalls

1. Proxy-only gaze/symmetry evidence — require observed support.
2. Origin, winding, or side inversion — canonicalize and lock conversion tests.
3. Blink-implausible pupils — validate and fail only pupil-dependent fields.
4. Vector aliases — prove full source/target displacement differences.
5. Correction overreach — use dead zones and bounded reduction of measured deviation.
6. Effective/emitted mismatch — use named emissions and bounded convergence.

## Implications for Roadmap

### Phase 41: Public Contract and Observed Eye Support
**Rationale:** Every advanced control depends on compatibility-safe scalar semantics and honest private support.
**Delivers:** Exact 48-field contract, Vision contour/pupil capture, canonical conversion, validation, and privacy boundary.

### Phase 42: Independent Eye Geometry and Pipeline Integration
**Rationale:** Provider semantics must exist and be field-locally eligible before image evidence is meaningful.
**Delivers:** Ten distinct transforms/corrections, fourteen named emissions, resolver/conflict/facade routing, and synthetic geometry evidence.

### Phase 43: Public-Facade Eye Geometry Output Evidence
**Rationale:** Product rows require decoded saved-output visibility, direction, independence, correction, no-face, and artifact evidence.
**Delivers:** Eleven isolated cases (signed tilt has two directions), derived 55-case matrix and 385 files if the seven-fixture inventory is unchanged, eligibility-aware strict checks, and ignored gallery.

### Phase 44: Eye Geometry Safety and Ledger Closeout
**Rationale:** Final caps and promotion must follow output calibration and exhaustive transition evidence.
**Delivers:** All-fourteen degradation, exact provider-eligible convergence, boundary checker, ten-row promotion, and owner synchronization.

### Phase Ordering Rationale

- Observed support precedes correction semantics so gaze/symmetry are not fabricated.
- Provider eligibility precedes renderer claims so output cases cannot borrow sibling work.
- Final cap and ledger promotion follow strict decoded output and exhaustive safety evidence.

### Research Flags

- **Phase 41:** Deep planning should lock coordinate conversion, side canonicalization, support storage ceilings, and no-persistence enforcement.
- **Phase 42:** Deep planning should define exact correction dead zones and symmetry dimensions without identity mirroring.
- **Phase 43:** Planning must inspect actual fixture pupil/contour eligibility before freezing comparison counts.
- **Phase 44:** Use established v1.9/v1.10 boundary-checker and convergence patterns.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Stack | HIGH | Existing stack and official Vision regions are sufficient. |
| Features | HIGH | Repository ledger provides exact remaining rows and exclusions. |
| Architecture | MEDIUM-HIGH | Boundary is clear; exact private representation belongs to Phase 41 planning. |
| Pitfalls | HIGH | Official blink caveat and prior provider/convergence failures give concrete gates. |

### Gaps to Address

- Actual portrait fixture pupil availability and measurable deviation must be inventoried before Phase 43 freezes strict eligible-pair counts.
- Final numeric caps, correction dead zones, and ROI thresholds remain provisional until visible output evidence.
- Physical-device and commercial-naturalness validation remain explicitly outside this milestone.

## Sources

### Primary

- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — eye contours, pupils, normalization.
- [Apple `VNFaceLandmarkRegion2D`](https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d) — normalized point arrays.
- [Apple pupil documentation](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil) — blink inaccuracy caveat.
- Repository source and root contracts — current model, detector, adapter, provider, facade, safety, privacy, and ledger behavior.

### Secondary

- Archived v1.6, v1.9, and v1.10 planning/evidence — established eye output and provider-owned convergence patterns.

---
*Research completed: 2026-07-16*
*Ready for roadmap: yes*
