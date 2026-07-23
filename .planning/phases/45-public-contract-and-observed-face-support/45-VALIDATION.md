---
phase: 45
slug: public-contract-and-observed-face-support
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| **Estimated runtime** | < 30 seconds for the current 314-test baseline |

## Sampling Rate

- **After every task commit:** Run the narrowest affected `swift test --package-path BeautySDK --filter ...` command plus `git diff --check`.
- **After every plan wave:** Run `swift test --package-path BeautySDK`.
- **Before phase verification:** Full SwiftPM, boundary-helper self-test/live modes, preset neutrality, and diff hygiene must be green.
- **Max feedback latency:** 120 seconds; never allow three consecutive implementation tasks without an automated focused test.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 45-01-01 | 01 | 1 | SUPP-04 | T-45-01, T-45-SC | fail-closed public/privacy/dependency/resource/Demo classifier | self-test/Wave 0 | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test` | ❌ Wave 0 | ⬜ pending |
| 45-01-02 | 01 | 1 | SUPP-02, SUPP-04 | T-45-02, T-45-03 | package-only support contracts plus face-specific fixtures and exact legacy proxy | compile/unit/Wave 0 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ extend existing | ⬜ pending |
| 45-02-01 | 02 | 2 | FACE-07, FACE-08, FACE-09, FACE-12 | T-45-05 | finite positive-only 52-field public contract | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ extend existing | ⬜ pending |
| 45-02-02 | 02 | 2 | FACE-07, FACE-08, FACE-09, FACE-12 | T-45-06, T-45-08 | 48-key compatibility, preset bytes, and shipped-domain neutrality | unit/resource/integration | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests && swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend existing | ⬜ pending |
| 45-03-01 | 03 | 2 | SUPP-01, SUPP-02, SUPP-04 | T-45-09, T-45-11 | actual one-request Vision capture with independent bounded mapping and redaction | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ extend existing | ⬜ pending |
| 45-03-02 | 03 | 2 | SUPP-01, SUPP-02 | T-45-10, T-45-12 | one-time mapping and reversal-only canonical direction across metadata | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ extend existing | ⬜ pending |
| 45-04-01 | 04 | 3 | SUPP-02 | T-45-13, T-45-15 | bounded face-specific open-path topology validation | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ extend existing | ⬜ pending |
| 45-04-02 | 04 | 3 | SUPP-01, SUPP-02, SUPP-04 | T-45-14, T-45-16, T-45-17 | independent eligibility, exact proxy/sibling isolation, and stateless requests | integration/unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests && swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ extend existing | ⬜ pending |
| 45-05-01 | 05 | 4 | FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, SUPP-04 | T-45-18, T-45-19 | synchronized authoritative contracts and downstream nonclaims | static/docs | `rg -n "chinWidth|faceLift|foreheadHairline|mouthCornerLift|observedFaceSupport|52" DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md PLANS.md && git diff --check` | ✅ extend existing | ⬜ pending |
| 45-05-02 | 05 | 4 | FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, SUPP-04 | T-45-20, T-45-21, T-45-22 | live fail-closed boundary and full requirement closeout | package/boundary | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test && python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py && swift test --package-path BeautySDK && git diff --check` | ❌ Wave 0 checker | ⬜ pending |

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

- [ ] Plan `45-01-01` creates `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` before implementation waves — fail-closed `rg` status classification, path containment, public/Codable/persistence/diagnostic/Demo/dependency/semantic-resource checks, fixed preset SHA-256 checks, and adversarial `--self-test`.
- [ ] Plan `45-01-02` creates package-private support contracts plus face-specific topology fixtures and exact threshold matrices in `BeautyFaceGeometryAdapterTests.swift` before production validation; no opaque reuse of eye constants.
- [ ] Baseline comparisons use pre-phase commit `9aedd6b40a7c033ac86cea2c75e06bac138cf9ef` for `BeautySDK/Package.swift` and `BeautyDemo`, plus the five preset hashes recorded in `45-RESEARCH.md`.

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

## Validation Sign-Off

- [ ] Every finalized plan task has a focused automated command or explicit Wave 0 dependency.
- [ ] Sampling continuity: no three consecutive tasks without automated verification.
- [ ] Wave 0 covers the boundary checker and face-specific fixture/threshold gaps.
- [ ] No watch-mode flags are used.
- [ ] Feedback latency remains below 120 seconds.
- [ ] Full SwiftPM and boundary helper self-test/live modes pass.
- [ ] The four new fields are not routed to providers in Phase 45.
- [ ] `nyquist_compliant: true` and `wave_0_complete: true` are set only after recorded execution evidence exists.

**Approval:** pending
