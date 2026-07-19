---
phase: 41-public-contract-and-observed-eye-support
verified: 2026-07-19T22:00:00Z
status: passed
score: 9/9 must-haves verified
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 8/9
  gaps_closed:
    - "Private semantic support now carries deterministic image-normalized span and signed winding-independent tilt."
    - "Production Vision mapping derives anatomical side order and rejects swapped, duplicate, missing, coincident, or non-finite pairs while preserving valid orientation and input-mirror identity."
    - "The complete EYE-06 contour, pupil, and paired-ratio exact/inside/outside matrix is executable through production predicates and composed degradation tests."
    - "41-VALIDATION.md is complete with Wave 0 evidence and Nyquist sign-off."
  gaps_remaining: []
  regressions: []
---

# Phase 41: Public Contract and Observed Eye Support Verification Report

**Phase Goal:** Hosts can configure ten independent eye geometry controls through source- and JSON-compatible public parameters, and the SDK obtains validated private contour/pupil support without exposing biometric-adjacent geometry.
**Verified:** 2026-07-16T06:21:35Z
**Status:** passed
**Re-verification:** Yes — after EYE-06 gap-closure plans 41-05-01 and 41-05-02

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Existing source-style initialization, 38-field JSON, and bundled presets remain neutral while hosts can round-trip exactly ten new fields in a 48-field stored model. | ✓ VERIFIED | `BeautyParameters.swift` stores, decodes, normalizes, and round-trips all ten fields; focused compatibility tests pass 28/28. |
| 2 | Zero-default v1.11 values preserve every shipped eye field and provider behavior while all ten new fields remain independently stored and normalized. | ✓ VERIFIED | Neutral `EyeWarpProvider` regressions and independent scalar normalization pass; full SwiftPM suite passes 295/295. |
| 3 | Vision contours and optional pupils cross one face-local-to-image mapping boundary into finite private request-scoped support with side/orientation/mirror preservation. | ✓ VERIFIED | `VisionFaceDetector.mapPoints` validates local points, composes `visionBounds`, and invokes `CoordinateMapper` once; mapping suite passes 8/8, including non-unit bounds, four orientations, mirror, malformed points, and missing bounds. |
| 4 | The adapter emits deterministic upper/lower/inner/outer/corner/center/span/tilt/pupil support and rejects every malformed, implausible, duplicate-only, side-inverted, or strict-boundary case before provider use. | ✓ VERIFIED | `BeautyFaceGeometryAdapter` exposes package-internal span/tilt and production validation predicates; adapter suite passes 13/13 with winding/cyclic determinism, side inversion, complete contour/pupil/ratio matrix, and composed precedence fixtures. |
| 5 | Missing or implausible pupils are field-local while missing either observed contour preserves complete-eye skip and safe siblings. | ✓ VERIFIED | Pupil validation clears only pupil support; explicit invalid/missing sides produce empty eye geometry without proxy fallback; degradation/provider suites pass 37/37 and 8/8. |
| 6 | The fail-closed helper enforces the immutable manifest/Demo baseline and explicit `rg` 0/1/error classification. | ✓ VERIFIED | `check_eye_support_boundaries.py --self-test` passes 24/24 adversarial checks; live mode passes 10/10 against baseline `f1c28fa`. |
| 7 | Active SDK sources are fail-closed scanned for public/SPI, persistence/Codable, raw diagnostics, network/cloud, commercial, and forbidden imports. | ✓ VERIFIED | Live boundary scan reports zero unclassified matches in every prohibited category. |
| 8 | Output/gallery/staging/quarantine artifacts remain ignored and absent from tracked, staged, and non-ignored-untracked state. | ✓ VERIFIED | Live boundary scan reports tracked=0, staged=0, nonignored_untracked=0, representatives_not_ignored=0. |
| 9 | DESIGN, SECURITY, RELIABILITY, PRODUCT_SENSE, and PLANS agree on the Phase 41 contract and downstream non-claims. | ✓ VERIFIED | Owner sections consistently record ten fields, one-mapper private lifecycle, span/tilt and side-order rules, threshold ceilings, pupil-local degradation, privacy boundary, and Phase 42 ownership. |

**Score:** 9/9 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `BeautyParameters.swift` | Exact compatible ten-field scalar contract | ✓ VERIFIED | Public storage/Codable/normalization and compatibility tests are substantive and wired. |
| `BeautyFaceObservation.swift` / `VisionFaceDetector.swift` | Request-scoped private contours and optional pupils with one coordinate conversion | ✓ VERIFIED | Package-only support, face-bounds composition, finite bounds checks, and production-derived order are implemented and exercised. |
| `BeautyFaceGeometryAdapter.swift` / `WarpControlPoint.swift` | Complete bounded semantic support | ✓ VERIFIED | Canonical subsets, center, span, signed tilt, pupil eligibility, and strict validation are substantive and consumed by `FaceGeometry`. |
| `BeautyFaceGeometryAdapterTests.swift` / `FaceObservationMappingTests.swift` | Full EYE-06 boundary and orientation/mirror evidence | ✓ VERIFIED | 13 adapter tests and 8 mapping tests pass, including pure predicates and composed fail-closed behavior. |
| `check_eye_support_boundaries.py` | Deterministic source/privacy/artifact gate | ✓ VERIFIED | Self-test and live modes pass 24/24 and 10/10. |
| `41-VALIDATION.md` and five owner documents | Completed validation ledger and synchronized contract | ✓ VERIFIED | Ledger is `nyquist_compliant: true`, `wave_0_complete: true`, all rows/sign-offs checked; owner docs agree and preserve Phase 42 non-claims. |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | --- | --- | ------ | ------- |
| Public scalar initializer | Codable/normalized model | same ten named fields | ✓ WIRED | Storage, coding keys, initializer, decoder, and normalized copy agree. |
| Vision face-local regions | `BeautyFaceObservation` | compose with `visionBounds`, then one `CoordinateMapper` call | ✓ WIRED | Non-unit bounds and all orientation/mirror fixtures pass. |
| Mapped observed support | `FaceGeometry` | production order gate, adapter validation/canonicalization | ✓ WIRED | Canonical span/tilt and all semantic subsets reach private `FaceGeometry`; invalid order/sides fail closed. |
| Empty observed side | resolver eye degradation | empty left/right geometry and complete-eye gate | ✓ WIRED | Degradation tests prove eye skip and safe sibling continuation. |
| Source/artifact state | completion gate | checked-in boundary helper | ✓ WIRED | Adversarial and live checks classify failures fail-closed. |

### Data-Flow Trace (Level 4)

| Artifact | Data | Source | Produces Real Data | Status |
| -------- | ---- | ------ | ------------------ | ------ |
| `VisionFaceDetector` | contours and optional pupils | `VNFaceLandmarks2D` or injected request fixture | Yes; mapping and production order tests consume mapped values | ✓ FLOWING |
| `BeautyFaceGeometryAdapter` | semantic support including span/tilt | selected mapped observation | Yes; strict validators produce non-empty support only for valid contours and field-local pupils | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Semantic span/tilt, winding, side inversion, and strict matrix | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | 13 tests, 0 failures | ✓ PASS |
| Production-derived order across orientation/input mirror and swapped/duplicate rejection | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` | 8 tests, 0 failures | ✓ PASS |
| Full SDK regression | `swift test --package-path BeautySDK` | 295 tests, 0 failures | ✓ PASS |
| Boundary helper adversarial behavior | `python3 .../check_eye_support_boundaries.py --self-test` | 24/24 checks passed | ✓ PASS |
| Boundary helper live state | `python3 .../check_eye_support_boundaries.py` | 10/10 checks passed | ✓ PASS |
| Diff hygiene | `git diff --check` | exit 0 | ✓ PASS |

### Probe Execution

No separate probe scripts are declared. The checked-in boundary helper is the phase's runnable probe and passed in both self-test and live modes.

### Requirements Coverage

| Requirement | Source Plans | Status | Evidence |
| ----------- | ---------- | ------ | -------- |
| EYE-01 | 41-01, 41-04 | ✓ SATISFIED | Independent positive-only fields, finite normalization, defaults, and no aliases pass focused tests. |
| EYE-02 | 41-01, 41-04 | ✓ SATISFIED | Signed `eyeTilt` clamps to `[-1,1]`, defaults to zero, and preserves both directions. |
| EYE-03 | 41-01, 41-04 | ✓ SATISFIED | Legacy 38-key decode, neutral source defaults, unequal 48-field round-trip, and exact inventory pass. |
| EYE-04 | 41-01, 41-04 | ✓ SATISFIED for Phase 41 boundary | Zero defaults preserve shipped eye inputs/provider behavior; vector distinction remains Phase 42 scope. |
| EYE-05 | 41-02, 41-04 | ✓ SATISFIED | Private optional support, face-local composition, one mapper, orientation/mirror, fail-closed bounds, and leakage gate pass. |
| EYE-06 | 41-03, 41-04, 41-05 | ✓ SATISFIED | Span/tilt, production-derived side order, and exhaustive strict threshold evidence pass. |
| EYE-07 | 41-03, 41-04 | ✓ SATISFIED | Pupil-local invalidation, no-proxy explicit-side behavior, complete-eye skip, safe siblings, and redaction pass. |

The requirement ledger's lifecycle checkboxes are updated by the phase-completion workflow; no implementation or evidence gap remains.

### Anti-Patterns Found

None in the reviewed implementation, tests, owner documents, or boundary scans. The previous draft validation-state finding is closed: `41-VALIDATION.md` is complete and signed.

### Human Verification Required

None. Phase 41 declares synthetic/package fixtures authoritative for support validation; no visual, device, commercial, renderer, or launch claim is made.

### Gaps Summary

All prior verification gaps are closed. The implementation now includes deterministic private span/tilt, production-derived side-order validation that preserves orientation/mirror identity, and executable exact/inside/outside coverage for every locked contour, pupil, and paired-ratio predicate. Fresh focused and full SwiftPM suites, boundary helper self-test/live modes, and diff hygiene all pass. Phase 42 remains the owner of provider transforms, caps, emissions, resolver convergence, and facade output.

---

_Verified: 2026-07-16T06:21:35Z_  
_Verifier: the agent (gsd-verifier)_
