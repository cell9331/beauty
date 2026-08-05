---
phase: 53
status: passed
security_standard: OWASP ASVS Level 1
block_on: HIGH
completed: 2026-07-31
---

# Phase 53 Canonical Still-Image Foundation Evidence

## Verdict

Phase 53 is green for PATH-01 through PATH-07 and D-01 through D-19. Production local-retouch admission remains exact-empty. This evidence adds no candidate field, public API, preset key, provider, renderer case, realtime/pixel-buffer behavior, Demo/UI behavior, model, network path, or visible retouch feature.

## Exact Command Results

All commands ran from the repository root.

| Gate | Exact command | Result |
|---|---|---|
| Checker self-test | `python3 .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py --self-test` | PASS; 6/6 self-test cases; exact `16 = 13 automated + 3 flagged` |
| Checker live mode | `python3 .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py` | PASS |
| Named foundation/compatibility suites | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter 'BeautyCanonicalStillImageTests\|BeautyEngineLocalRetouchFoundationTests\|StillImageRequestSupportTests\|BeautyParametersTests\|BeautyResourceCatalogTests'` | PASS; 83 tests, 0 failures, 0 skips |
| Inactive renderer compatibility | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | PASS; 18 tests, 0 failures, 0 skips |
| Final-only full phase gate | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK` | PASS; 495 tests, 6 skips, 0 failures |
| Diff hygiene | `git diff --check` | PASS |

The six full-suite skips are the existing opt-in local Apple Vision integration tests:

- `BeautyEngineGeometryFacadeTests.testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade`
- `BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope`
- `BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope`
- `VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload`
- `VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload`
- `VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture`

None is a Phase 53 HIGH mitigation or a PATH-01 through PATH-07 closeout test.

## Compatibility and Admission Evidence

- `BeautyParameters` remains exactly 59 stored fields and 59 CodingKeys: 58 numeric fields plus one `filterId`.
- All 58 default numeric values remain exact zero; `filterId` remains nil.
- Empty/missing-key JSON decodes to the neutral default. Legacy labeled construction retains supplied legacy values without adding candidate state.
- Encoding a complete nonnil-filter value produces the exact stored-key set.
- The bundled preset IDs remain exactly `natural`, `clear`, `refined`, `male-natural`, and `id-photo-natural`.
- The five preset source SHA-256 values remain:

| File | SHA-256 |
|---|---|
| `clear.json` | `58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8` |
| `id-photo-natural.json` | `d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609` |
| `male-natural.json` | `1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08` |
| `natural.json` | `bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da` |
| `refined.json` | `67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722` |

- The renderer inventory remains exactly 72 cases and contains no Phase 53 candidate.
- With exact-empty admission, both active fixtures retain dimensions and rendered RGBA bytes; warnings are empty, metrics are exactly the two zero counters, and detection summary is `.notRun`.
- Later admission remains an executable seven-item contract: independent positive-only `Float`, finite normalization to `0...1`, default zero, missing-key zero, trailing append, and exact stored/Codable inventory.

## Live Boundary Evidence

The fail-closed live checker verifies:

- required canonical carrier, canonicalizer, and request-context owners exist;
- no public or SPI canonical/support/mask/pupil/sclera/vein surface exists;
- no Codable/CodingKey raw canonical, landmark, lip, teeth, pupil, sclera, eyelid, mask, or vein surface exists;
- no `teethWhitening`, `scleraRednessReduction`, or `upperEyelidFullnessReduction` source/preset inventory exists;
- no runtime network path, local-foundation persistence path, model/weight artifact, external package dependency, target drift, or preset inventory drift exists;
- the canonicalizer and admitted geometry route name sRGB explicitly and do not reinterpret canonical pixels through device RGB;
- the pixel-buffer route contains no canonicalizer, local-retouch admission, request context, or observed-lip activation.

## Edge Manifest

| Edge ID | Status |
|---|---|
| PATH01-CONCURRENCY | flagged |
| PATH02-UNCLASSIFIED | automated |
| PATH03-UNCLASSIFIED | automated |
| PATH04-BOUNDARY | automated |
| PATH04-ADJACENCY | automated |
| PATH04-EMPTY | automated |
| PATH04-ORDERING | automated |
| PATH04-PRECISION | automated |
| PATH04-CONCURRENCY | flagged |
| PATH05-CONCURRENCY | flagged |
| PATH06-ADJACENCY | automated |
| PATH06-EMPTY | automated |
| PATH06-ORDERING | automated |
| PATH07-ADJACENCY | automated |
| PATH07-EMPTY | automated |
| PATH07-ORDERING | automated |

Equality is exact: 16 unique rows, 13 automated, and three flagged assumptions. Same-engine concurrency/cancellation remains under TD-013 and is not promoted into a passed claim.

## ASVS Level 1 HIGH Mitigations

| Threat | Result | Evidence |
|---|---|---|
| T-53-01 decoded-input DoS | PASS | checked ceiling/allocation tests plus live canonical-owner scan |
| T-53-02 alpha tampering | PASS | partial/zero-alpha rejection before Vision; no composite/force-alpha route |
| T-53-03 color tampering | PASS | unknown/non-RGB/extended rejection; explicit-sRGB admitted route; no canonical device-RGB reinterpretation |
| T-53-04 information disclosure | PASS | aggregate-only support tests plus public/SPI/Codable/persistence/network/model scans |
| T-53-05 lifecycle tampering | PASS | valid-invalid-valid, no-face/missing support, independent ownership, and no cache/static persistence |
| T-53-06 realtime privilege expansion | PASS | pixel-buffer/reset zero-work tests plus static pixel-buffer boundary scan |

All HIGH mitigations are verified. No failed, skipped, or not-run HIGH item exists.

## Bounded Claims and Nonclaims

This phase proves only the private still-image request foundation, compatibility, privacy, and fail-closed transport boundary. It does not claim or admit:

- feature-specific rights, positive/negative evidence, naturalness, or promotion;
- original-pixel mask composition or overlap ownership, which remain Phase 55;
- same-engine concurrency, cooperative cancellation, or cross-profile topology identity;
- encoded-byte/container/gain-map inspection, transparent support, HDR, or multi-face ownership;
- realtime/pixel-buffer local retouch, Demo/UI, cloud, model, device performance, commercial quality, packaging, shipping, or release readiness.
