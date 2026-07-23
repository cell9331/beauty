---
phase: 45-public-contract-and-observed-face-support
verified: 2026-07-23T07:36:51Z
status: passed
score: 20/20 must-haves verified
overrides_applied: 0
---

# Phase 45: Public Contract and Observed Face Support Verification Report

**Phase Goal:** Establish compatibility-safe public semantics and honest observed face support for the four contour-driven controls.
**Verified:** 2026-07-23T07:36:51Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

The phase goal is achieved. This conclusion is based on the current implementation, direct source inspection, a fresh boundary scan, focused tests, the full package test suite, and opt-in Apple Vision integration tests. SUMMARY claims were not used as proof.

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | The public parameter surface is exactly 52 stored fields: 51 numeric values and `filterId`. | ✓ VERIFIED | `BeautyParameters.swift` contains exactly 52 stored public properties; the boundary checker independently reports `52/51/1`. |
| 2 | The four new fields are independent, positive-only, neutral by default, and do not change signed `chinLength` behavior. | ✓ VERIFIED | The four fields have independent `clampUnit` assignments and zero defaults; `chinLength` still uses `clampSigned`. `BeautyParametersTests` passed 32/32. |
| 3 | Coding and normalization preserve all four fields without mutation or field swapping. | ✓ VERIFIED | Each field is present in `CodingKeys`, initialization, decoding, and `normalized()` forwarding. Unequal-value round-trip and non-mutating normalization tests pass. |
| 4 | Legacy 48-field payloads decode with the four additions neutral. | ✓ VERIFIED | Legacy decoding uses `decodeFloatIfPresent(..., default: 0)` for each field; the explicit legacy-48 test passes. |
| 5 | Historical 31-, 33-, and reconstructed 38-field compatibility remains unchanged. | ✓ VERIFIED | Historical compatibility tests pass and retain their literal inventory assertions. |
| 6 | Existing shipped presets remain unchanged and omit the four new keys. | ✓ VERIFIED | The checker reports 5/5 preset hashes unchanged and 5/5 presets with all four keys absent; `BeautyResourceCatalogTests` passed 9/9. |
| 7 | Explicit zero and nonzero values for the four new controls do not activate runtime effects in this phase. | ✓ VERIFIED | Production references are confined to `BeautyParameters`; resolver equality and nonzero-neutrality tests pass in `BeautyEffectResolverTests` (20/20). |
| 8 | Observed support is a package-only immutable value copied at the Vision boundary, with no public geometry leakage. | ✓ VERIFIED | `BeautyObservedFaceSupport` is internal/package-scoped, value-based, `Equatable`/`Sendable`, not `Codable`; the checker finds no public geometry type. |
| 9 | Diagnostic description, debug description, reflection, and dumps expose only aggregate counts rather than coordinates. | ✓ VERIFIED | Custom descriptions and `CustomReflectable` exist for observations, detection observations, geometry, and semantic support; privacy/reflection tests pass after the final review fixes. |
| 10 | Actual Vision contour and median landmarks are captured from one landmarks request and immediately copied into package values. | ✓ VERIFIED | `VisionFaceDetector` creates one `VNDetectFaceLandmarksRequest`, copies `faceContour` and `medianLine` normalized points, and retains no Vision region objects. Opt-in Vision tests passed. |
| 11 | A request uses one coordinate mapper and maps each support point exactly once into canonical image coordinates. | ✓ VERIFIED | `mapObservation` receives the request-local mapper; `mapFaceRegion` performs the single point mapping. Orientation/mirror matrix and mapping lifecycle tests pass. |
| 12 | Canonical ordering is stable across orientation, preview mirroring, and wholly reversed Vision paths. | ✓ VERIFIED | Ordering uses projections onto mapper-derived right/down axes and only whole-array reversal; 4-orientation × 2-mirror, preview-mirror, adjacency, and reversed-path tests pass. |
| 13 | Invalid contour and median data is rejected independently without discarding an otherwise valid observation. | ✓ VERIFIED | Finite, closed-unit, cardinality, projection, topology, and face-bound checks are fail-closed and independently optional; invalid-region-isolation tests pass. |
| 14 | Selected-face behavior remains intact while optional support is attached, and no support state leaks across requests. | ✓ VERIFIED | `FaceSelectionPolicy` persists only `previousPrimaryStableID`; provider-once, concurrent/sequential, and prior-request-retention tests pass. |
| 15 | Observed support and the legacy seven-point synthetic proxy remain explicitly separate. | ✓ VERIFIED | `BeautyFaceGeometryAdapter` preserves the legacy proxy path and separately derives `observedFaceSupport`; tests distinguish injected observed fixtures from proxy geometry. |
| 16 | Contour and median semantic eligibility use face-specific thresholds and topology rather than eye/polygon proxy rules. | ✓ VERIFIED | The adapter enforces the planned contour/median counts, span, curvature, direction, chord/apex, side-distribution, uniqueness, and self-intersection rules. |
| 17 | Contour and centerline support remain independently usable. | ✓ VERIFIED | A malformed median degrades to contour-only support; an invalid contour yields no contour support. Cross-support and independent-failure tests pass. |
| 18 | Missing or malformed observed support changes only the four future controls and preserves legacy sibling behavior. | ✓ VERIFIED | The four controls have no active resolver/provider path; adapter fallback and alternating-call tests demonstrate stateless isolation, while resolver tests preserve legacy plans. |
| 19 | Double-chin, professional refinement, and hairline remain explicitly deferred with blockers recorded. | ✓ VERIFIED | The feature ledger retains all three rows as future work; product/design docs do not claim active downstream effects. Boundary scan reports `3/3` future rows. |
| 20 | The source, tests, boundary contract, and owner documentation agree on the delivered phase boundary. | ✓ VERIFIED | Fresh boundary scan passed 13/13; focused suites passed; full SwiftPM suite passed 354 executed / 3 skipped / 0 failed; both opt-in Vision suites passed with no skips. |

**Score:** 20/20 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | Exact public parameter and compatibility contract | ✓ VERIFIED | Exists, substantive, used throughout the SDK, and covers declaration, coding, initialization, clamping, decoding, and normalization. |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | Private observed-support carrier | ✓ VERIFIED | Exists, substantive, wired into detector output, immutable by value, and diagnostics are aggregate-only. |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | One-request raw Vision capture and canonical mapping | ✓ VERIFIED | Exists, substantive, wired into detection, independently validates contour and median, and retains no framework landmark regions. |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | Honest observed semantic support plus legacy proxy isolation | ✓ VERIFIED | Exists, substantive, wired through `FaceGeometry`, validates exact thresholds/topology, and keeps proxy and observed data separate. |
| `BeautySDK/Sources/BeautyEffects/Planning/WarpControlPoint.swift` | Geometry value used by legacy and observed planning paths | ✓ VERIFIED | Exists and is used by the adapter/provider planning code without making observed geometry public. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | Public inventory and backward-compatibility coverage | ✓ VERIFIED | 32/32 focused tests passed. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyResourceCatalogTests.swift` | Preset compatibility coverage | ✓ VERIFIED | 9/9 focused tests passed. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | Runtime-neutrality coverage | ✓ VERIFIED | 20/20 focused tests passed. |
| `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` | Coordinate and canonical-order coverage | ✓ VERIFIED | 15/15 focused tests passed. |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | Raw capture, lifecycle, and real Vision coverage | ✓ VERIFIED | Default focused run passed; opt-in run passed 20/20 with zero skips. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` | Semantic thresholds, malformed input, and real portrait coverage | ✓ VERIFIED | Default focused run passed; opt-in run passed 32/32 with zero skips. |
| `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` | Auditable fail-closed phase boundary | ✓ VERIFIED | Self-test passed 36/36 and live repository scan passed 13/13. |
| `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, feature ledger | Owner contract and future-boundary documentation | ✓ VERIFIED | Current owner docs match the 52-field, privacy, reliability, neutrality, and future-feature boundaries. |

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| Four new `BeautyParameters` properties | Codable and normalized value | `CodingKeys`, initializer, decoder, `normalized()` | ✓ WIRED | Unequal-value round-trip prevents swaps or dropped values. |
| Existing preset JSON | Neutral new controls | missing-key decoding defaults | ✓ WIRED | All five preset hashes are unchanged and omit the four keys. |
| `VNFaceLandmarks2D` | `VisionDetectionObservation` | immediate normalized-point copy | ✓ WIRED | One request captures actual contour/median data without retaining Vision regions. |
| `VisionDetectionObservation` | `BeautyFaceObservation` | request-local `CoordinateMapper` | ✓ WIRED | Point mapping and canonical ordering are verified across orientation/mirror cases. |
| `BeautyFaceObservation` | `FaceGeometry.observedFaceSupport` | `BeautyFaceGeometryAdapter` | ✓ WIRED | Independent validation and fail-closed degradation produce real semantic support. |
| Legacy face proxy | Existing geometry consumers | `FaceGeometry.faceContour` | ✓ WIRED | Existing seven-point proxy remains available only on its legacy path. |
| Observed support | Four new runtime controls | intentionally absent in Phase 45 | ✓ VERIFIED NEUTRAL | No resolver/provider activation exists; this is the required phase boundary, not orphaned wiring. |
| Boundary checker | Active sources, manifests, presets, baseline, feature ledger | repository scan | ✓ WIRED | Self-test proves fail-closed behavior; live scan passed every invariant. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|---|---|---|---|---|
| `BeautyParameters.swift` | four contour-control floats | host initializer or decoded JSON | Yes; values round-trip and normalize independently | ✓ FLOWING |
| `VisionFaceDetector.swift` | contour and median points | actual `VNFaceLandmarks2D` regions | Yes; opt-in Apple Vision integration test passed | ✓ FLOWING |
| `BeautyFaceObservation.swift` | optional `observedSupport` | mapped request-local detection observation | Yes; lifecycle tests prove per-request values and no stale reuse | ✓ FLOWING |
| `BeautyFaceGeometryAdapter.swift` | `observedFaceSupport` | observed contour/median plus exact face bounds | Yes; six opt-in portrait fixtures and malformed-input matrix passed | ✓ FLOWING |
| Legacy geometry path | seven-point `faceContour` proxy | existing normalized bounds/landmarks | Yes; existing providers remain unchanged and separately exercised | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| Checker rejects its negative fixtures | `python3 .../check_face_support_boundaries.py --self-test` | 36/36 passed | ✓ PASS |
| Current repository satisfies Phase 45 boundary | `python3 .../check_face_support_boundaries.py` | 13/13 passed | ✓ PASS |
| Focused public/compatibility behavior | `swift test --package-path BeautySDK --disable-sandbox --filter ...` | Parameters 32/32; catalog 9/9; resolver 20/20 | ✓ PASS |
| Focused detection/geometry behavior | `swift test --package-path BeautySDK --disable-sandbox --filter ...` | mapping 15/15; detector 20 executed with 2 default opt-in skips; adapter 32 executed with 1 default opt-in skip | ✓ PASS |
| Complete package regression suite | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` | 354 executed, 3 skipped, 0 failures | ✓ PASS |
| Actual Apple Vision capture | `BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 swift test ... --filter BeautyDetectionTests.VisionFaceDetectorTests` | 20/20 passed, zero skipped | ✓ PASS |
| Actual portrait semantic support | `BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 swift test ... --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | 32/32 passed, zero skipped | ✓ PASS |

The initial sandboxed full-suite attempt could not access host CoreImage/CoreVideo/Vision services. The required host-capable rerun above passed; the initial environment failure is not an implementation failure.

### Probe Execution

No `scripts/**/tests/probe-*.sh` file or shell probe is declared for this phase. The phase-specific executable checker was run directly:

| Probe | Command | Result | Status |
|---|---|---|---|
| Boundary checker negative corpus | `python3 .../check_face_support_boundaries.py --self-test` | 36/36 passed | PASS |
| Boundary checker repository scan | `python3 .../check_face_support_boundaries.py` | 13/13 passed | PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| FACE-07 | 45-02, 45-05 | Face-contour-smoothing public semantic is compatibility-safe | ✓ SATISFIED | Exact field/coding/clamp/default coverage and runtime-neutrality tests pass. |
| FACE-08 | 45-02, 45-05 | Temple-fullness public semantic is compatibility-safe | ✓ SATISFIED | Exact field/coding/clamp/default coverage and runtime-neutrality tests pass. |
| FACE-09 | 45-02, 45-05 | Cheekbone-slim public semantic is compatibility-safe | ✓ SATISFIED | Exact field/coding/clamp/default coverage and runtime-neutrality tests pass. |
| FACE-12 | 45-02, 45-05 | Chin-taper public semantic is compatibility-safe | ✓ SATISFIED | Exact field/coding/clamp/default coverage and runtime-neutrality tests pass. |
| SUPP-01 | 45-03, 45-04, 45-05 | Honest observed contour/median support is captured and validated | ✓ SATISFIED | Actual Vision integration, mapping matrix, and adapter matrix pass. |
| SUPP-02 | 45-01, 45-03, 45-04, 45-05 | Support remains private, request-scoped, and fail-closed | ✓ SATISFIED | Package-only carrier, no cache, aggregate diagnostics, and lifecycle/isolation tests pass. |
| SUPP-04 | 45-01, 45-03, 45-04, 45-05 | Legacy proxy and future activation boundaries remain explicit | ✓ SATISFIED | Proxy separation, neutral resolver behavior, and three future ledger rows verified. |

No orphaned Phase 45 requirement was found: every requirement mapped to the phase in `REQUIREMENTS.md` is claimed by at least one plan and has implementation evidence.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| Phase implementation and tests | — | No unreferenced `TBD`, `FIXME`, `XXX`, `TODO`, `HACK`, placeholder, empty production implementation, or hardcoded visible empty-data stub | — | No blocker found. Test-helper `return []` branches are intentional count-edge fixtures, not production stubs. |
| `45-VALIDATION.md`, `45-05-SUMMARY.md` | historical result sections | Pre-review totals still show 34 checker self-tests and 347 package tests | ℹ️ Info | Later review fixes increased the totals to 36 and 354. Current owner docs, fix records, and this fresh verifier run contain the authoritative results; behavior and goal achievement are unaffected. |

### Human Verification Required

None. Visual appearance and interactive UI are outside this phase's contract, and the otherwise external Apple Vision behavior was exercised directly through the opt-in integration suites.

### Gaps Summary

No blocking, warning-level, or human-only gap remains. The four controls have compatibility-safe public value semantics, real observed contour/median data is privately captured and validated without synthetic substitution, legacy behavior is isolated, and downstream activation remains explicitly deferred.

---

_Verified: 2026-07-23T07:36:51Z_
_Verifier: the agent (gsd-verifier)_
