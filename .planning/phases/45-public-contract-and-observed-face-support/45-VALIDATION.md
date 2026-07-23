---
phase: 45
slug: public-contract-and-observed-face-support
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-21
---

# Phase 45 — Validation Strategy

> Per-phase validation contract for the 52-field public model and private observed face contour/median-line support.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via SwiftPM; Python 3 standard library for fail-closed boundary checks |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Measured runtime** | Fresh post-review rerun: 354 executed, 3 opt-in skips, 0 failures |

## Sampling Rate

- **After every task commit:** Run the narrowest affected `swift test --package-path BeautySDK --filter ...` command plus `git diff --check`.
- **After every plan wave:** Run `swift test --package-path BeautySDK`.
- **Before phase verification:** Full SwiftPM, boundary-helper self-test/live modes, preset neutrality, and diff hygiene must be green.
- **Max feedback latency:** 120 seconds; never allow three consecutive implementation tasks without an automated focused test.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 45-01-01 | 01 | 1 | SUPP-04 | T-45-01, T-45-SC | fail-closed public/privacy/dependency/resource/Demo classifier | self-test/Wave 0 | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test` | ✅ current | ✅ green — 36/36 |
| 45-01-02 | 01 | 1 | SUPP-02, SUPP-04 | T-45-02, T-45-03 | package-only support contracts plus face-specific fixtures and exact legacy proxy | compile/unit/Wave 0 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ current | ✅ green — 32 executed / 1 opt-in skip |
| 45-02-01 | 02 | 2 | FACE-07, FACE-08, FACE-09, FACE-12 | T-45-05 | finite positive-only 52-field public contract | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ current | ✅ green — 32/32 |
| 45-02-02 | 02 | 2 | FACE-07, FACE-08, FACE-09, FACE-12 | T-45-06, T-45-08 | 48-key compatibility, preset bytes, and shipped-domain neutrality | unit/resource/integration | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests && swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ current | ✅ green — 32/32 + 9/9 + 20/20 |
| 45-03-01 | 03 | 2 | SUPP-01, SUPP-02, SUPP-04 | T-45-09, T-45-11 | actual one-request Vision capture with independent bounded mapping and redaction | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ current | ✅ green — 20 executed / 2 opt-in skips; opt-in run 20/20 |
| 45-03-02 | 03 | 2 | SUPP-01, SUPP-02 | T-45-10, T-45-12 | one-time mapping and reversal-only canonical direction across metadata | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ current | ✅ green — 15/15 + 20 executed / 2 opt-in skips |
| 45-04-01 | 04 | 3 | SUPP-02 | T-45-13, T-45-15 | bounded face-specific open-path topology validation | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ current | ✅ green — 32 executed / 1 opt-in skip; opt-in run 32/32 |
| 45-04-02 | 04 | 3 | SUPP-01, SUPP-02, SUPP-04 | T-45-14, T-45-16, T-45-17 | independent eligibility, exact proxy/sibling isolation, and stateless requests | integration/unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests && swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ current | ✅ green — adapter, detector, and mapping focused suites passed |
| 45-05-01 | 05 | 4 | FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, SUPP-04 | T-45-18, T-45-19 | synchronized authoritative contracts and downstream nonclaims | static/docs | `rg -n "chinWidth|faceLift|foreheadHairline|mouthCornerLift|observedFaceSupport|52" DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md PLANS.md && git diff --check` | ✅ current | ✅ green — owner matches present; diff clean |
| 45-05-02 | 05 | 4 | FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, SUPP-04 | T-45-20, T-45-21, T-45-22 | live fail-closed boundary and full requirement closeout | package/boundary | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test && python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py && swift test --package-path BeautySDK && git diff --check` | ✅ current | ✅ green — 36/36 + 13/13 + 354 executed / 3 skips / 0 failures; diff clean |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

## Exact Validation Matrices

### Public Contract

- For each new field: negative clamps to `0`, distinct in-range value survives, overflow clamps to `1`, and NaN/+∞/−∞ become `0`.
- `normalized()` reapplies all four rules without mutating the source instance.
- Reflection and encoded JSON contain exactly 52 stored fields: 51 numeric fields plus `filterId`; each new label appears once.
- A 52-key unequal-value round trip proves independent storage; a payload with the four new keys removed contains 48 keys and decodes all four as zero.
- Historical 31/33 payload fixtures retain their original counts; the legacy 38-key reconstruction removes the ten eye and four new face keys.
- The five bundled preset files omit all four keys, retain the research-recorded SHA-256 values, and decode each new field as zero.

### Detection Mapping and Canonical Direction

- Forward/reversed contour and median inputs produce identical canonical arrays through whole-array reversal only; adjacency is never sorted.
- `.up`, `.right`, `.left`, and `.down` each pass with input mirroring false and true; preview mirroring does not alter image-normalized support.
- Closed-unit face-local edges `0` and `1` are accepted; just-outside, NaN, infinity, invalid shared bounds, and oversized payloads reject at the correct boundary.
- Invalid contour + valid median, valid contour + invalid median, both absent, and both valid remain distinct without removing the selected face.
- The default Vision provider over committed portraits records aggregate availability only and never emits coordinates.

### Adapter Topology and Isolation

- Contour counts exercise `6/7/8` and `31/32/33`; median counts exercise `2/3/4` and `15/16/17`.
- Duplicate, adjacent duplicate, all-identical, non-finite, out-of-unit, flat/collinear, undersized span, coincident direction, and each exact/inside/outside geometry threshold are covered.
- Median direction, side consistency, apex distance, and interior-apex constraints have exact boundary evidence.
- Valid contour plus invalid median preserves contour eligibility; malformed or missing observed support preserves the exact seven-point legacy contour and all eligible sibling geometry.

## Wave 0 Requirements

- [x] Plan `45-01-01` created `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` before implementation waves — fail-closed `rg` status classification, path containment, public/Codable/persistence/diagnostic/Demo/dependency/semantic-resource checks, fixed preset SHA-256 checks, and adversarial `--self-test`.
- [x] Plan `45-01-02` created package-private support contracts plus face-specific topology fixtures and exact threshold matrices in `BeautyFaceGeometryAdapterTests.swift` before production validation; no opaque reuse of eye constants.
- [x] Baseline comparisons use pre-phase commit `9aedd6b40a7c033ac86cea2c75e06bac138cf9ef` for `BeautySDK/Package.swift` and `BeautyDemo`, plus the five preset hashes recorded in `45-RESEARCH.md`.

## Security Threat References

| Threat | Risk | Automated Control |
|--------|------|-------------------|
| T45-01 | Non-finite/out-of-range values or key aliasing alter public behavior | Exact normalization, inventory, missing-key, and unequal round-trip tests |
| T45-02 | Oversized/malformed points or orientation inversion corrupt mapping | Fixed ceilings before mapping, mapper-axis reversal, full orientation/mirror tests |
| T45-03 | Synthetic proxy spoofed as observed support or malformed support disables siblings | Parallel support paths and field-local adapter degradation tests |
| T45-04 | Coordinates leak or semantic/dependency/resource scope enters silently | Package-only non-Codable model plus adversarial fail-closed boundary checker |

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| None | — | All Phase 45 behavior is covered by injected observations, aggregate fixture evidence, static boundary checks, and SwiftPM tests. | — |

## Executed Closeout Evidence

All commands below were executed successfully on 2026-07-23 against the completed Plans 45-01 through 45-04 implementation and the synchronized Plan 45-05 owner contracts.

The first post-edit full-suite attempt inside the restricted filesystem sandbox was blocked while Swift tried to write its user Clang module cache (`Operation not permitted`). The exact `swift test --package-path BeautySDK` command was then rerun with host/module-cache and Apple Vision service access and passed 347/347; no source or package change was made for the environment-only failure.

| Gate | Executed command | Actual outcome |
| --- | --- | --- |
| Checker self-test | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test` | PASS — 36/36 positive and adversarial checks |
| Checker live mode | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` | PASS — 13/13 live checks; 52 stored/51 numeric/one `filterId`/four face fields; five preset hashes and missing keys unchanged; zero unclassified scope/privacy matches |
| Public model | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | PASS — 32/32 |
| Bundled resources | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` | PASS — 9/9 |
| Shipped resolver neutrality | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` | PASS — 20/20 |
| Default detector and request lifecycle | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | PASS — 20 executed, 2 opt-in skips, zero failures |
| Mapping/canonical direction | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` | PASS — 15/15 |
| Adapter topology/isolation | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | PASS — 32 executed, 1 opt-in skip, zero failures |
| Complete detection target | `swift test --package-path BeautySDK --filter BeautyDetectionTests` | PASS — focused detector and mapping suites passed with zero failures |
| Full package | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` | PASS — 354 executed, 3 opt-in skips, zero failures |
| Owner/static acceptance | `rg -n "chinWidth|faceLift|foreheadHairline|mouthCornerLift|observedFaceSupport|52" DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md PLANS.md && git diff --check` | PASS — current owner matches present and diff hygiene clean; the four implemented identifiers remain `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` |
| Final diff hygiene | `git diff --check` | PASS |

### Requirement Closure

| Requirement | Executable evidence | Result | Phase 45 boundary |
| --- | --- | --- | --- |
| FACE-07 | `BeautyParametersTests`, `BeautyResourceCatalogTests`, `BeautyEffectResolverTests` | PASS | Independent positive-only `faceContourSmooth`; storage/compatibility only |
| FACE-08 | Same public/resource/resolver suites | PASS | Independent positive-only `templeFullness`; no alias or routing |
| FACE-09 | Same public/resource/resolver suites | PASS | Independent positive-only `cheekboneSlim`; no borrowed shipped output |
| FACE-12 | Same public/resource/resolver suites | PASS | Independent positive-only `chinTaper`; signed `chinLength` unchanged |
| SUPP-01 | `VisionFaceDetectorTests`, `FaceObservationMappingTests`, `BeautyFaceGeometryAdapterTests` | PASS | Actual Vision contour/median, one request-local mapping path, no proxy substitution |
| SUPP-02 | Mapping, adapter, complete detection, and full suites | PASS | Canonical bounded open paths, independent eligibility, malformed/cross-support rejection |
| SUPP-04 | Checker self/live, detector lifecycle, adapter statelessness, and source/diff review | PASS | Package-only, ephemeral, non-Codable, non-persistent, aggregate-only evidence |

### Final A1 Support Envelope

| Predicate | Final inclusive bound |
| --- | ---: |
| Contour count | `7...32` |
| Median count | `3...16` |
| Contour relative width | `0.50...1.00` |
| Contour relative height | `0.20...1.00` |
| Endpoint horizontal separation | `>= 0.35` |
| Maximum chord-perpendicular curvature | `>= 0.10` |
| Median net-down projection | `>= 0.25` |
| Direction magnitude | `>= 0.000001` |
| Median-bottom chord position | `0.15...0.85` |
| Nearest-apex distance | `<= 0.40` |
| Contour points on each apex side | `>= 2` |

All six committed portraits were evaluated through aggregate availability/count and pass/fail evidence only. Every complete support observed in the aggregate fixture test passed contour, median, and cross-support validation; no coordinates, bounds, samples, framework-region descriptions, or identity claims were recorded.

## Validation Audit 2026-07-23

| Metric | Count |
|--------|-------|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

The post-review Nyquist audit cross-referenced all seven Phase 45 requirements against the current focused suites, boundary checker, opt-in Vision integrations, and the independent 20/20 phase verification. Every requirement remains covered by executable evidence; no manual-only or missing-test gap was found.

### Active-Source and Diff Review

- The pre-phase-to-closeout production delta is limited to `BeautyParameters.swift`, `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `BeautyFaceGeometryAdapter.swift`, and `WarpControlPoint.swift`; the corresponding six focused test files and planning/owner documents contain the evidence.
- `BeautySDK/Package.swift`, `BeautyDemo`, resource manifests, presets, provider implementations, production resolver/conflict files, `BeautySDK` facade, `BeautyRender`, and `BeautyExampleRenderer` have no Phase 45 implementation drift. The five preset SHA-256 values exactly match the locked baseline.
- Active-source scans find exactly one `VNDetectFaceLandmarksRequest`, no public/SPI face support, no raw-coordinate diagnostic or persistence sink, no network/cloud path, no semantic model/resource, no Demo/internal import, and no generated artifact escape.
- `observedFaceSupport` remains confined to detection transport, internal geometry storage, and the adapter trust boundary. No provider, resolver, facade, renderer, metric, or Demo consumer exists.
- T-45-18 through T-45-22 and T-45-SC are mitigated by the owner contracts, exact proxy equality, bounded tests, checker self/live results, immutable baselines, and explicit downstream nonclaims. Unresolved HIGH threats: **0**.

## Validation Sign-Off

- [x] Every finalized plan task has a focused automated command or explicit Wave 0 dependency.
- [x] Sampling continuity: no three consecutive tasks without automated verification.
- [x] Wave 0 covers the boundary checker and face-specific fixture/threshold gaps.
- [x] No watch-mode flags are used.
- [x] Feedback latency remained below 120 seconds.
- [x] Full SwiftPM and boundary helper self-test/live modes pass.
- [x] The four new fields are not routed to providers in Phase 45.
- [x] `nyquist_compliant: true` and `wave_0_complete: true` were set only after the executed evidence above passed.

**Approval:** validated after post-review Nyquist audit — 2026-07-23
