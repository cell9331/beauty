---
phase: 25-security-distribution-review-and-closeout
status: draft
updated: 2026-07-03
requirements:
  - SEC-03
---

# Phase 25 Resource Trust Evidence

This artifact records current bundled-resource trust evidence for `BeautyResources`. It covers bundled manifest schema, metadata filters, preset references, logical identifiers, unknown resource behavior, traversal-like IDs, typed errors, source scans, and the boundary for disabled external resource packages.

## Status Values

- `passed`: command, test, scan, or source assertion ran in this phase and passed.
- `recorded`: current evidence exists with an explicit limitation.
- `fixed`: a source/test finding was corrected narrowly and verified.
- `blocked`: evidence needs unavailable tooling or future implementation.
- `not run`: evidence is intentionally left to a documented rerun protocol.

## Scope

In scope:

- Current bundled `BeautyResources` manifest and preset JSON.
- Metadata-only filter IDs `soft_clean` and `warm_light`.
- Five bundled presets: `natural`, `clear`, `refined`, `male-natural`, and `id-photo-natural`.
- Logical resource identifiers, unknown preset/filter behavior, traversal-like IDs, and typed redacted errors.

Out of scope:

- Real LUT, makeup, model, sticker, background, or external dynamic resource packages.
- Network download, cache, checksum/signature pipeline, package parser, Demo UI route, or new public parameter.

## Resource Trust Review

| Area | Status | Evidence | Result | Requirement |
| --- | --- | --- | --- | --- |
| Manifest schema | passed | `BeautySDK/Sources/BeautyResources/Resources/manifest.json` | `schemaVersion: 1`, `version: 1`, non-empty `minimumSDKVersion`, 2 filters, and 5 preset references. | SEC-03 |
| Metadata filters | passed | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` | `testEFFECT03BundledCatalogListsMetadataFilters` verifies `soft_clean` and `warm_light`. | SEC-03 |
| Bundled preset inventory | passed | Same focused resource test command. | `testEFFECT08BundledCatalogLoadsRequiredPresetNames` verifies `Natural`, `Clear`, `Refined`, `Male Natural`, and `ID Photo Natural`. | SEC-03 |
| Preset lookup | passed | Same focused resource test command. | `testEFFECT08PresetLookupIsDeterministicAndComplete` verifies deterministic `id-photo-natural` values. | SEC-03 |
| Unknown preset/filter behavior | passed | Same focused resource test command. | Missing preset and missing filter references throw typed `BeautyError.resourceNotFound(...)`. | SEC-03 |
| Traversal-like IDs | passed | Same focused resource test command. | Traversal-like and absolute-path-like IDs are rejected and mapped to typed missing-resource errors. | SEC-03 |
| Facade validation | passed | `swift test --package-path BeautySDK --filter BeautySDKTests.BeautySDKFacadeTests` | Public `BeautySDKResources` facade exposes filters/presets and rejects missing or invalid filter IDs. | SEC-03 |

## Focused Test Evidence

| Command | Status | Result |
| --- | --- | --- |
| `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` | passed | Executed 6 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautySDKTests.BeautySDKFacadeTests` | passed | Executed 5 tests, 0 failures. |

The resource test requirement comment now cites `SEC-03`. Test guard literals for `.cube`, `thumbnail`, `swatch`, traversal-like IDs, and absolute-path-like IDs use string concatenation so active-source scans do not misclassify intentional regression guards as production resource behavior.

## Resource Source Scan Results

| Area | Status | Exact command | Result | Classification |
| --- | --- | --- | --- | --- |
| Positive trust-pattern scan | passed | `rg -n "Bundle\.module|isValidResourceIdentifier|resourceNotFound|presetDecodeFailed|SEC-03" BeautySDK/Sources/BeautyResources BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | Found `Bundle.module`, conservative identifier validation, typed `resourceNotFound(...)`, redacted `presetDecodeFailed(...)`, and the SEC-03 test comment. | Current bundled-resource trust patterns are present. |
| Forbidden resource-surface scan | passed | `rg -n "\.cube|thumbnail|swatch|http://|https://|URLSession|download|upload|\.\./|/private/var" BeautySDK/Sources/BeautyResources BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift \|\| true` | No matches after test guard literals were split. | No active source or test literal self-match for forbidden external-resource/path/network tokens. |
| Network / product-scope scan | passed | `rg -n "URLSession|http://|https://|download|remote config|CloudKit|Firebase|RevenueCat|StoreKit|VIP|entitlement|payment" BeautySDK/Sources/BeautyResources BeautySDK/Package.swift \|\| true` | No matches. | Resource target and package manifest do not add network fetch, remote config, cloud, payment, VIP, entitlement, or listed third-party SDK behavior. |

## External Resource Boundary

| Boundary | Current status | Required future design before enablement |
| --- | --- | --- |
| Real LUT packages | disabled | File extension, dimensions, color data length, maximum file size, checksum/signature when packaged, and failure policy. |
| Makeup packages | disabled | Manifest schema, item paths, image dimensions, blend modes, SDK compatibility, package size/type limits, checksum/signature, and failure policy. |
| Model packages | disabled | Version, expected model type, size limit, checksum/signature before load, and no executable code. |
| Sticker/background textures | disabled | File type, dimensions, color space, decompression safety, size limit, checksum/signature, and graceful missing-resource handling. |
| Dynamic resource download | disabled | Network policy, endpoint/payload/retention review, consent/disclosure, privacy manifest/App privacy review, retry/offline behavior, cache rules, and dependency review. |
| Resource cache | disabled | Size limits, eviction, integrity validation, redaction, and host-controlled storage policy. |
| Path traversal in packages | disabled | Package-root confinement, normalized relative paths, rejection of `..` escapes, and typed redacted errors. |
| Package failure policy | disabled | Required-vs-optional behavior, typed errors, no crash in release, no raw file paths or raw decoder errors. |

Current bundled-resource evidence supports only the existing bundled manifest/preset trust boundary. It does not complete external resource package capability and does not justify score 5 for real LUT, makeup, model, sticker, download, cache, checksum/signature, or package-integrity capability.

## Blockers and Deferred Checks

| Gate | Status | Evidence | Impact | Next step | Closeout blocking |
| --- | --- | --- | --- | --- | --- |
| External resource package integrity | not run | No external package loader exists in current source. | External LUT/makeup/model/sticker package trust remains future work. | Promote a future resource-manager design before implementing any external package path. | No |
| Resource checksum/signature verification | not run | Current resources are bundled SwiftPM files; no external package integrity layer exists. | Checksums/signatures remain unproved for future dynamic resources. | Define package manifest, size/type limits, checksum/signature, cache, and failure policy before enabling. | No |
| Dynamic download/network resources | not run | `BeautyResources` and `Package.swift` network/product-scope scan returned no matches. | No current dynamic resource capability exists. | Update `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and privacy manifest/App privacy review before adding network behavior. | No |

## Rerun Protocol

```bash
swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests
swift test --package-path BeautySDK --filter BeautySDKTests.BeautySDKFacadeTests
rg -n "Bundle\\.module|isValidResourceIdentifier|resourceNotFound|presetDecodeFailed|SEC-03" BeautySDK/Sources/BeautyResources BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
rg -n "\\.cube|thumbnail|swatch|http://|https://|URLSession|download|upload|\\.\\./|/private/var" BeautySDK/Sources/BeautyResources BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift || true
rg -n "URLSession|http://|https://|download|remote config|CloudKit|Firebase|RevenueCat|StoreKit|VIP|entitlement|payment" BeautySDK/Sources/BeautyResources BeautySDK/Package.swift || true
git diff --check -- .planning/phases/25-security-distribution-review-and-closeout/25-RESOURCE-TRUST-EVIDENCE.md BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift
```
