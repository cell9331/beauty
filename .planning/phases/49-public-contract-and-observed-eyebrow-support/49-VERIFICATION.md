---
phase: 49-public-contract-and-observed-eyebrow-support
verified: 2026-07-24T09:09:15Z
status: passed
score: 4/4 must-haves verified
behavior_unverified: 0
overrides_applied: 0
re_verification: true
previous_status: gaps_found
previous_verified: 2026-07-24T09:05:42Z
gaps: []
---

# Phase 49: Public Contract and Observed Eyebrow Support Verification Report

**Phase Goal:** Establish compatibility-safe public eyebrow semantics and honest request-scoped support from actual Apple Vision eyebrow traces.
**Verified:** 2026-07-24T09:09:15Z
**Status:** passed
**Re-verification:** Yes — the single prior documentation-consistency gap was fully rechecked; previously passed executable gates received a regression check.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | `BeautyParameters` has exactly 59 stored fields (58 numeric plus `filterId`), with seven neutral finite-normalized eyebrow fields and legacy 52-field/source/preset compatibility. | ✓ VERIFIED | Production model contains the seven independent fields across storage, coding, initialization, decoding, and normalization. Fresh full SwiftPM passed; focused model/resource/resolver tests exercise 59/58 inventory, six signed ranges, one unit range, non-finite-to-zero behavior, legacy 52-key decode, five unchanged presets, reset/diff/equality/round-trip behavior, and runtime inertness. Live checker independently reports `stored=59; numeric=58; filterId=1; eyebrow_fields=7/7` and preset hashes `5/5`. |
| 2 | The existing single selected-face Vision request copies actual left/right eyebrow regions and maps accepted points exactly once through request-local metadata. | ✓ VERIFIED | `VisionFaceDetector` reads `landmarks.leftEyebrow`/`rightEyebrow`, independently preflights open paths at 1...16, copies values request-locally, and maps accepted points once plus four fixed axis probes. Fresh tests cover actual-property provenance, one provider invocation, zero rejected-point calls, exact map arithmetic, orientation/mirror matrices, and parallel isolation. |
| 3 | Eyebrow traces are independently bounded, open-path validated, side/order canonicalized, locally rejected when malformed, and never replaced by eye/synthetic proxies. | ✓ VERIFIED | Adapter code applies 4...16 count, exact-bit uniqueness, finite closed-unit coordinates, chord 0.08...0.50, vertical span <=0.25, non-adjacent intersection rejection, and 1e-6 projection policy. Tests cover boundaries, whole-array reversal, local sibling preservation, four eligibility combinations, wrong side/order, topology failure, and valid-invalid-valid lifecycle. Live checker reports actual provenance markers `4/4`, no substitution, and no downstream activation. |
| 4 | Raw/derived eyebrow support is private and ephemeral, diagnostics are aggregate-only, and Phase 49 makes no provider/output/promotion claim. | ✓ VERIFIED | Raw carrier is package-scoped and semantic carrier is target-internal; both are immutable `Equatable, Sendable`, non-Codable, and surfaced through fixed counts/booleans. Reflection/dump/lifecycle tests pass. Checker live gates report no public/SPI geometry, network/cloud, Demo import, model/resource expansion, generated artifacts, or Phase 49 downstream activation. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautyParameters.swift` | Seven-field neutral public contract | ✓ VERIFIED | Exists, substantive, compiled, decoded/normalized, and exercised by compatibility tests. |
| `BeautyFaceObservation.swift` | Package-only raw support envelope | ✓ VERIFIED | Exists, substantive, wired from detector mapping, with aggregate-only diagnostics. |
| `VisionFaceDetector.swift` | Actual Vision capture and request-local canonical mapping | ✓ VERIFIED | Exists, substantive, wired through the existing observation provider and mapper. |
| `WarpControlPoint.swift` | Internal semantic support and `FaceGeometry` seam | ✓ VERIFIED | Exists, substantive, wired to adapter output; no provider consumer exists by design. |
| `BeautyFaceGeometryAdapter.swift` | Independent open-path validation and semantic attachment | ✓ VERIFIED | Exists, substantive, wired from observed support to private `FaceGeometry` support. |
| `check_eyebrow_support_boundaries.py` | Fail-closed fixture/privacy/scope gate | ✓ VERIFIED | Fresh preflight 1/1, self-test 42/42, and live 15/15 all pass. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `VNFaceLandmarks2D.leftEyebrow/rightEyebrow` | `VisionDetectionObservation.observedEyebrowSupport` | Bounded immediate value copy in the existing request | ✓ WIRED | Direct production symbols and provenance tests present. |
| Detection observation support | `BeautyFaceObservation.observedEyebrowSupport` | One request-local mapper pass and face-axis canonicalization | ✓ WIRED | Exact call-count and 64-row orientation/mirror/source-order behavior tests pass. |
| `BeautyFaceObservation.observedEyebrowSupport` | `FaceGeometry.observedEyebrowSupport` | Independent adapter validation and semantic envelope attachment | ✓ WIRED | Four presence combinations, malformed-side isolation, and sibling-preservation tests pass. |
| Seven public eyebrow values | Existing resolver | Deliberate Phase 49 non-consumption | ✓ VERIFIED PROHIBITION | Nonzero-vs-zero resolver plan equality passes and live checker finds no downstream activation. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `VisionFaceDetector.swift` | observed left/right eyebrow arrays | Actual optional Vision `leftEyebrow`/`rightEyebrow` regions from the selected face | Yes | ✓ FLOWING |
| `BeautyFaceGeometryAdapter.swift` | semantic left/right eyebrow traces | Canonical mapped request-local arrays | Yes, when independently valid | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Authorized fixture prerequisite | `python3 .../check_eyebrow_support_boundaries.py --preflight-fixtures` | `1/1 checks passed` | ✓ PASS |
| Checker adversarial behavior | `python3 .../check_eyebrow_support_boundaries.py --self-test` | `42/42 checks passed` | ✓ PASS |
| Live repository boundaries | `python3 .../check_eyebrow_support_boundaries.py` | `15/15 checks passed` | ✓ PASS |
| Full compiled behavior | `swift test --package-path BeautySDK` | Fresh run completed successfully; 411 tests, 3 explicit opt-in skips, 0 failures | ✓ PASS |
| Fixture provenance | `stat` over parked and input e1...e5 | Both sets match historical bytes: 929129, 650316, 680540, 731951, 717292 | ✓ PASS |
| Prior closeout-record gap | Scoped stale-claim scan plus direct review of `STATE.md` and `49-05-SUMMARY.md` | Current status, blocker, next-step, requirement, fixture, and full-suite claims consistently describe completed fixture-backed closeout; one remaining stale accomplishment sentence was corrected during re-verification | ✓ PASS |
| Diff hygiene | `git diff --check` | Exit 0 | ✓ PASS |

### Probe Execution

No conventional `probe-*.sh` is declared. The phase-declared Python checker was executed independently in all three required modes; all passed as recorded above.

### Requirements Coverage

| Requirement | Source Plans | Status | Evidence |
| --- | --- | --- | --- |
| BROW-01 | 49-02, 49-05 | ✓ SATISFIED | Exact seven fields, domains, defaults, independence, and finite normalization are implemented and tested. |
| BROW-02 | 49-01, 49-02, 49-05 | ✓ SATISFIED | 59/58 inventory, legacy 52-key compatibility, preset bytes, reset/diff/equality/round-trip, and inertness pass. |
| SUPP-01 | 49-03, 49-05 | ✓ SATISFIED | Actual Vision properties, one request, bounded copy, and exactly-once mapping pass. |
| SUPP-02 | 49-01, 49-03, 49-04, 49-05 | ✓ SATISFIED | Independent open-path validation, canonical side/order, local failure, and no proxy substitution pass. |
| SUPP-03 | 49-01, 49-03, 49-04, 49-05 | ✓ SATISFIED | Package/internal request lifetime, redaction, no persistence/network, and isolation pass. |

No Phase 49 requirement is orphaned. Later GEOM/PIPE/OUT/SAFE/DOC requirements remain explicitly assigned to Phases 50-52 and are not Phase 49 gaps.

### Anti-Patterns Found

| File | Location | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | — | No current Phase 49 closeout contradiction or unreferenced debt marker found | — | Prior gap resolved. Historical blocked evidence in earlier plan records remains intentionally historical. |

No `TBD`, `FIXME`, or `XXX` marker was found in the Phase 49 production/checker artifacts.

### Human Verification Required

None. The phase goal is SDK contract, mapping, validation, privacy, and lifecycle behavior with direct automated coverage; visual output is explicitly deferred.

### Gaps Summary

None. The prior closeout-consistency gap is resolved: current Phase 49 tracking and summary surfaces agree that the authorized fixtures are restored, fixture preflight and the full 411-test SwiftPM suite pass, all five requirements are complete, and Phase 49 is ready to advance. The previously verified implementation truths remain green under checker and full-suite regression checks.

---

_Verified: 2026-07-24T09:09:15Z_
_Verifier: the agent (gsd-verifier)_
