# Phase 25: Security, Distribution Review, and Closeout - Pattern Map

**Mapped:** 2026-07-03
**Files analyzed:** 12 new/modified files
**Analogs found:** 12 / 12

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md` | evidence | batch + request-response commands | `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | role-match |
| `.planning/phases/25-security-distribution-review-and-closeout/25-VALIDATION.md` | evidence | batch verification | `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` | role-match |
| `BeautySDK/Sources/BeautySDK/Resources/PrivacyInfo.xcprivacy` | config | file-I/O + distribution resource | `BeautySDK/Package.swift` | role-match |
| `BeautySDK/Package.swift` | config | dependency/resource declaration | `BeautySDK/Package.swift` | exact |
| `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | config | build-setting/resource declaration | `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | role-match |
| `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | test | batch source scan | `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | exact |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | test | CRUD + file-I/O resource validation | `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | exact |
| `SECURITY.md` | documentation | policy sync | `SECURITY.md` | exact |
| `QUALITY_SCORE.md` | documentation | evidence ledger sync | `QUALITY_SCORE.md` | exact |
| `PLANS.md` | documentation | planning ledger sync | `PLANS.md` | exact |
| `.planning/REQUIREMENTS.md` | documentation | traceability status sync | `.planning/REQUIREMENTS.md` | exact |
| `.planning/ROADMAP.md`, `.planning/PROJECT.md`, `.planning/STATE.md` | documentation | phase status sync | `.planning/ROADMAP.md` | role-match |

## Pattern Assignments

### `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md` (evidence, batch + request-response commands)

**Analog:** `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md`

**Frontmatter pattern** (lines 1-11):

```markdown
---
phase: 23-performance-and-reliability-gates
status: final
updated: 2026-07-02
requirements:
  - PERF-01
  - PERF-02
  - PERF-03
  - PERF-04
  - PERF-05
---
```

Copy this structure with `phase: 25-security-distribution-review-and-closeout`, `status: draft` until final closeout, and requirements `SEC-01`, `SEC-02`, `SEC-03`, `SEC-04`, `DOC-01`, `DOC-02`, `DOC-03`.

**Status vocabulary and non-claims pattern** (lines 19-32):

```markdown
Status values:

- `passed`: command or scan ran in this phase and passed.
- `recorded`: current-environment evidence exists but includes a limitation or risk.
- `blocked`: hardware or tooling needed for that evidence is unavailable.
- `not run`: evidence was intentionally left to the documented rerun protocol.

## Non-claims

- Current timing is SwiftPM debug XCTest baseline data, not shipped frame-rate readiness.
- Phase 23 does not assert commercial visual review, real-device parity, screenshot acceptance, or market fitness.
```

For Phase 25, keep the same explicit statuses and replace non-claims with the locked wording: audit-ready or traceability-ready only when supported; no App Store submission, commercial packaging, broad-device, market visual-quality, hardware-parity, or release-completion claims.

**Exact command table pattern** (lines 50-62):

```markdown
| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Focused SDK evidence tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | Executed 3 tests, 0 failures, 11.292 seconds. | PERF-01, PERF-04, PERF-05 |
| Full SDK suite | passed | `swift test --package-path BeautySDK` | Executed 148 tests, 0 failures, 15.153 seconds. | PERF-01, PERF-03, PERF-04, PERF-05 |
| Scoped redaction scan | passed | Plan 23-04 scoped forbidden-token scan over this artifact | No matches after final edits. | PERF-05 |
```

Use the same table for privacy manifest inventory, required-reason seed scan, no-network/no-upload scan, raw path/error/geometry scan, third-party SDK/product-scope scan, resource tests, full SDK tests, focused Demo privacy tests, and final no-overclaim/traceability scans.

**Blocker/rerun protocol pattern** (lines 138-145):

```markdown
| Gate | Status | Evidence | Impact | Next step |
| --- | --- | --- | --- | --- |
| Demo simulator long-run preview | not run | No 600-second simulator preview loop was collected in Phase 23. | Long-run preview memory behavior remains unproved. | Run a dedicated 600-second preview route with aggregate memory/thermal notes and retain non-claims. |
| Physical iPhone long-run camera route | blocked | No physical iPhone run exists in the repository evidence. | Device camera/Vision behavior and hardware thermal/memory behavior remain unproved. | When hardware is available, record device class, OS, route, duration, aggregate memory/thermal observations, pass/blocker status, and limitations. |
```

Copy this shape for any unrun Demo command, simulator/toolchain issue, Apple-doc lookup limitation, or manifest placement verification that cannot run locally. Do not record a blocked item as pass evidence.

### `.planning/phases/25-security-distribution-review-and-closeout/25-VALIDATION.md` (evidence, batch verification)

**Analog:** `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md`

**Scope and status pattern** (lines 14-24):

```markdown
## Scope

This artifact records the Phase 24 renderer-output regression evidence for the current public-facade `BeautyExampleRenderer` path.

Status values:

- `passed`: command, helper, scan, or representative inspection ran in this phase and passed.
- `recorded`: evidence exists with an explicit limitation.
- `blocked`: tooling or future implementation is required before the evidence can exist.
- `not run`: evidence is intentionally left to a documented rerun protocol.
```

Use this for a separate validation artifact only if the planner splits validation from `25-SECURITY-CLOSEOUT.md`. Otherwise keep validation sections inside the closeout artifact.

**Evidence field allowlist pattern** (lines 93-98):

```markdown
## Evidence Field Allowlist

This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, file-size/change status, factual watermark notes, blocker class, impact, next step, and rerun protocol.

It does not include raw pixel payloads, machine-local absolute paths, facial measurement payloads, unredacted framework diagnostics, service-transfer claims, or committed PNG baselines.
```

For Phase 25, allow only command status, relative paths, requirement IDs, scan classes, blocker class, impact, next step, and rerun protocol. Exclude raw frames, image bytes, absolute local paths, face geometry payloads, raw JSON, unredacted framework diagnostics, tokens, and user identifiers.

**Rerun command block pattern** (lines 105-114):

````markdown
## Rerun Protocol

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
python3 .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py --input example-images/input --output example-images/out
git check-ignore example-images/out/e1__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e5__skinCombo_0p50.png
```
````

Phase 25 rerun protocol should include `swift test --package-path BeautySDK`, focused resource/security tests, active `rg` scans, Demo focused xcodebuild when available, `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print`, and `plutil -lint`/`plutil -p` if a manifest is added.

### `BeautySDK/Sources/BeautySDK/Resources/PrivacyInfo.xcprivacy` (config, file-I/O + distribution resource)

**Analog:** `BeautySDK/Package.swift`

**Target/resource declaration pattern** (lines 23-35):

```swift
.target(
    name: "BeautyResources",
    dependencies: ["BeautyCore"],
    resources: [.process("Resources")]
),
.target(
    name: "BeautySDK",
    dependencies: ["BeautyCore", "BeautyDetection", "BeautyRender", "BeautyEffects", "BeautyResources"]
),
```

If a privacy manifest is required, add it to the smallest fact-matching target resources. For a facade-owned SDK manifest, the planner should add a `Resources` directory under `BeautySDK/Sources/BeautySDK/` and update the `BeautySDK` target to include `resources: [.process("Resources")]`, mirroring the existing `BeautyResources` target shape.

**Distribution product boundary pattern** (lines 11-14):

```swift
products: [
    .library(name: "BeautySDK", targets: ["BeautySDK"]),
    .executable(name: "BeautyExampleRenderer", targets: ["BeautyExampleRenderer"])
],
```

The SDK distribution product is the `BeautySDK` library facade. Manifest placement should not imply the Demo host app and SDK collect the same data; the evidence artifact must describe SDK behavior separately from host App responsibility.

### `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` (test, batch source scan)

**Analog:** `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`

**Imports pattern** (lines 1-4):

```swift
import Foundation
import XCTest
import BeautySDK
@testable import BeautyDemo
```

Use this import shape for Demo-side privacy/source scan tests. Keep public SDK imports through `BeautySDK`; do not import internal SDK targets into Demo tests unless the existing import-boundary tests are intentionally changed.

**Info.plist purpose string and local-first scan pattern** (lines 7-18):

```swift
func testPIPE08D09GeneratedInfoPlistPurposeStringsAreLocalFirst() throws {
    let project = try readTextFile("BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj")
    let cameraPurpose = "Use the camera to preview beauty processing on this device."
    let photoPurpose = "Select photos to preview beauty processing on this device."

    XCTAssertEqual(occurrences(of: "INFOPLIST_KEY_NSCameraUsageDescription", in: project), 2)
    XCTAssertEqual(occurrences(of: "INFOPLIST_KEY_NSPhotoLibraryUsageDescription", in: project), 2)
    XCTAssertEqual(occurrences(of: cameraPurpose, in: project), 2)
    XCTAssertEqual(occurrences(of: photoPurpose, in: project), 2)
    XCTAssertFalse(project.localizedCaseInsensitiveContains("upload"))
    XCTAssertFalse(project.localizedCaseInsensitiveContains("cloud"))
}
```

Extend this style if Demo manifest or purpose-string evidence changes. Keep upload/cloud assertions as negative controls.

**Active no-network/no-upload/raw-error pattern** (lines 20-39):

```swift
let files = try swiftFiles(in: [
    "BeautyDemo/BeautyDemo/Camera",
    "BeautyDemo/BeautyDemo/Editor",
    "BeautyDemo/BeautyDemo/Support"
])
let forbiddenTokens = [
    "URLSession",
    "http" + "://",
    "https" + "://",
    "up" + "load",
    "/private" + "/var",
    "NSError",
    "AV" + "Error"
]

let matches = try matches(for: forbiddenTokens, in: files)

XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
```

Use string concatenation for test guard literals so broad source scans do not misclassify the test itself as an active leak. Phase 25 can add SDK source directories to similar scan tests if active-source gaps appear.

**Facade-only import scan pattern** (lines 51-69):

```swift
let files = try swiftFiles(in: [
    "BeautyDemo/BeautyDemo",
    "BeautyDemo/BeautyDemoTests"
])
let internalImport = try NSRegularExpression(
    pattern: #"(?m)^\s*import Beauty(Core|Render|Detection|Effects|Resources)\b"#
)
var matches: [String] = []
for file in files {
    let text = try String(contentsOf: file, encoding: .utf8)
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    for match in internalImport.matches(in: text, range: range) {
        matches.append("\(relativePath(file)):\(lineNumber(for: match.range.location, in: text))")
    }
}

XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
```

Reuse this exact regex style for hidden SDK/product-scope scans where line-numbered findings matter.

**Geometry/raw framework leakage pattern** (lines 304-320):

```swift
let files = try swiftFiles(in: [
    "BeautySDK/Sources/BeautyCore",
    "BeautySDK/Sources/BeautySDK",
    "BeautyDemo/BeautyDemo/Camera",
    "BeautyDemo/BeautyDemo/Editor"
])
let forbiddenPatterns = [
    #"(?m)^\s*public\b[^\n]*(Point|Rect|bounding|landmark)"#,
    #"\bVNFaceObservation\b"#,
    #"\bNSError\b"#,
    #"/private/var"#
]

let matches = try matches(forRegexPatterns: forbiddenPatterns, in: files)

XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
```

This is the closest existing active SDK/Demo sensitive-surface scan. Extend with raw JSON/serialized diagnostic tokens only if Phase 25 finds a coverage gap.

**Shared source-scan helpers** (lines 323-400):

```swift
private func repoRoot() throws -> URL {
    var cursor = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

    while cursor.path != "/" {
        let projectPath = cursor.appendingPathComponent("BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj")
        if FileManager.default.fileExists(atPath: projectPath.path) {
            return cursor
        }
        cursor.deleteLastPathComponent()
    }

    throw SourceScanError.missingRepoRoot
}

private func matches(forRegexPatterns patterns: [String], in files: [URL]) throws -> [String] {
    let expressions = try patterns.map {
        try NSRegularExpression(pattern: $0)
    }
    var results: [String] = []
```

Copy these helpers for any new source-scan test file. They give deterministic repo-root discovery and line-numbered failures without shelling out from XCTest.

### `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` (test, CRUD + file-I/O resource validation)

**Analog:** `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift`

**Imports and requirement comment pattern** (lines 1-6):

```swift
import BeautyCore
import BeautyResources
import XCTest

// Requirement evidence: EFFECT-03, EFFECT-08.
final class BeautyResourceCatalogTests: XCTestCase {
```

For Phase 25 resource-trust additions, update the requirement comment to include `SEC-03` if new assertions are added here.

**Metadata-only resource pattern** (lines 41-60):

```swift
let catalog = try BeautyResourceCatalog.bundled()
let forbiddenTokens = ["/", "..", ".cube", "thumbnail", "swatch"]

XCTAssertEqual(catalog.manifest.schemaVersion, 1)
XCTAssertEqual(catalog.manifest.filters.count, 2)

for filter in catalog.manifest.filters {
    XCTAssertTrue(BeautyResourceManifest.isValidResourceIdentifier(filter.id))
    XCTAssertFalse(filter.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    XCTAssertTrue(forbiddenTokens.allSatisfy { !filter.id.contains($0) })
}
```

Use this as the core bundled-resource trust pattern. If adding tests for future-disabled resource classes, assert absence/disabled status rather than adding real LUT/makeup/model/sticker loading.

**Missing resource typed-error pattern** (lines 62-87):

```swift
XCTAssertThrowsError(try catalog.preset(id: "missing")) { error in
    XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing"))
}

let data = Data(
    #"""
    {
      "schemaVersion": 1,
      "id": "invalid_filter",
      "version": 1,
      "displayName": "Invalid Filter",
      "parameters": {
        "filterId": "missing_filter",
        "filterIntensity": 0.4
      }
    }
    """#.utf8
)

XCTAssertThrowsError(try BeautyPreset.decode(from: data, availableFilterIds: catalog.availableFilterIds)) { error in
    XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing_filter"))
}
```

Keep failures typed and redacted. Do not assert raw file paths or decoded JSON bodies in errors.

**Traversal-like ID rejection pattern** (lines 89-99):

```swift
XCTAssertFalse(BeautyResourceManifest.isValidResourceIdentifier("../natural"))
XCTAssertFalse(BeautyResourceManifest.isValidResourceIdentifier("Presets/natural"))
XCTAssertFalse(BeautyResourceManifest.isValidResourceIdentifier("/private/var/natural"))
XCTAssertTrue(BeautyResourceManifest.isValidResourceIdentifier("id-photo-natural"))

XCTAssertThrowsError(try catalog.preset(id: "/private/var/natural")) { error in
    XCTAssertEqual(error as? BeautyError, .resourceNotFound("invalid_preset"))
}
```

This is the exact traversal-like resource ID evidence Phase 25 should reuse for SEC-03.

### `BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift` (model/config, transform validation)

**Analog:** `BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift`

**Decode-to-redacted-error pattern** (lines 25-33):

```swift
public static func decode(from data: Data) throws -> BeautyResourceManifest {
    do {
        let manifest = try JSONDecoder().decode(BeautyResourceManifest.self, from: data)
        return try manifest.validated()
    } catch let error as BeautyError {
        throw error
    } catch {
        throw BeautyError.presetDecodeFailed("manifest_schema")
    }
}
```

If Phase 25 narrows manifest validation, preserve this redacted error shape. Do not expose raw decoder errors.

**Identifier validation pattern** (lines 53-84):

```swift
var filterIds = Set<String>()
for filter in filters {
    guard Self.isValidResourceIdentifier(filter.id) else {
        throw BeautyError.presetDecodeFailed("invalid_filter_id")
    }
    guard !filter.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        throw BeautyError.presetDecodeFailed("invalid_filter_name")
    }
    guard filterIds.insert(filter.id).inserted else {
        throw BeautyError.presetDecodeFailed("duplicate_filter_id")
    }
}

public static func isValidResourceIdentifier(_ id: String) -> Bool {
    BeautyPreset.isValidIdentifier(id) && !id.contains("..")
}
```

Do not replace this with path parsing or file-system resolution. Current resource IDs stay logical identifiers.

### `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift` (service, file-I/O + CRUD resource lookup)

**Analog:** `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift`

**Bundle lookup and missing-resource typed-error pattern** (lines 19-32):

```swift
public static func bundled() throws -> BeautyResourceCatalog {
    guard let manifestURL = Bundle.module.url(forResource: "manifest", withExtension: "json") else {
        throw BeautyError.resourceNotFound("manifest")
    }

    let data: Data
    do {
        data = try Data(contentsOf: manifestURL)
    } catch {
        throw BeautyError.resourceNotFound("manifest")
    }

    let manifest = try BeautyResourceManifest.decode(from: data)
    return BeautyResourceCatalog(manifest: manifest)
}
```

Keep bundled resource reads through `Bundle.module`; do not add arbitrary URL/file path loading for Phase 25.

**Preset lookup validation pattern** (lines 39-66):

```swift
public func preset(id: String) throws -> BeautyPreset {
    guard BeautyResourceManifest.isValidResourceIdentifier(id) else {
        throw BeautyError.resourceNotFound("invalid_preset")
    }
    guard let reference = manifest.presets.first(where: { $0.id == id }) else {
        throw BeautyError.resourceNotFound(id)
    }
    return try preset(reference: reference)
}
```

Use this as the service-level analog for SEC-03: validate identifier first, map unknown/missing resources to typed errors, and keep failures redacted.

### `QUALITY_SCORE.md`, `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/PROJECT.md`, `.planning/STATE.md` (documentation, traceability sync)

**Analog:** `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md`

**Requirement checklist pattern** (`.planning/REQUIREMENTS.md` lines 48-59):

```markdown
### Security and Distribution Review

- [ ] **SEC-01**: The repository contains a documented privacy manifest assessment, and `PrivacyInfo.xcprivacy` is added or explicitly deferred based on actual SDK/Demo behavior and Apple required-reason API usage.
- [ ] **SEC-02**: No-network, no-upload, no unredacted path, no unredacted framework error, no face-geometry payload leak, and no serialized diagnostic payload leak checks pass for active SDK and Demo surfaces.
- [ ] **SEC-03**: Resource trust boundaries are reviewed so bundled presets, metadata filters, identifiers, missing resources, and future external resource assumptions match `SECURITY.md`.
- [ ] **SEC-04**: v1.4 adds no hidden third-party SDK, analytics, remote config, cloud processing, dynamic downloads, payment, VIP, or entitlement behavior.
```

After evidence exists, update checkboxes and add a Phase 25 evidence paragraph mirroring the Phase 23/24 paragraphs above it. Do not mark requirements complete before the evidence artifact records pass/blocker status.

**Traceability table pattern** (`.planning/REQUIREMENTS.md` lines 105-111):

```markdown
| SEC-01 | Phase 25 | Planned |
| SEC-02 | Phase 25 | Planned |
| SEC-03 | Phase 25 | Planned |
| SEC-04 | Phase 25 | Planned |
| DOC-01 | Phase 25 | Planned |
| DOC-02 | Phase 25 | Planned |
| DOC-03 | Phase 25 | Planned |
```

Change `Planned` to `Complete` only after the Phase 25 artifact and ledger sync are done.

**Roadmap phase block pattern** (`.planning/ROADMAP.md` lines 113-129):

```markdown
### Phase 25: Security, Distribution Review, and Closeout

**Goal:** Close v1.4 with privacy/resource/log review, final negative scans, score updates, and traceability consistency.
**Mode:** security / closeout
**Depends on:** Phases 21-24
**Requirements:** SEC-01, SEC-02, SEC-03, SEC-04, DOC-01, DOC-02, DOC-03
```

Update `Plans`, current evidence, progress row, and next command after planning/execution. Keep the goal conservative; do not turn it into distribution-readiness marketing language.

**Quality score current snapshot pattern** (`QUALITY_SCORE.md` lines 43-49):

```markdown
| Security | 4 | Phase 21 import/privacy scans passed for facade-only Demo imports, non-UI SDK targets, active Demo no-network/no-upload/raw-path tokens, and public sensitive geometry/raw leakage. `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` found no privacy manifest, so TD-005 remains open. | Phase 25 should assess required-reason APIs and add or explicitly defer `PrivacyInfo.xcprivacy`. |
```

Update security/resource/planning rows only with command-backed evidence. Do not raise future external-resource capability to complete based on bundled-resource review.

**Tech debt routing pattern** (`PLANS.md` lines 1244-1249):

```markdown
| TD-005 | Privacy Manifest | Phase 21 `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` found no privacy manifest. | Future distribution or required-reason API usage can become a compliance risk if not assessed. | Route to Phase 25: assess actual SDK/Demo behavior and Apple required-reason API usage, then add or explicitly defer `PrivacyInfo.xcprivacy`. | `routed` |
| TD-010 | Phase 6 Visual and Hardware QA | Phase 23 adds 720p timing, over-budget classification, short memory protocol, quality/reset/degradation/cap tests, and focused Demo camera pass evidence. Phase 24 adds renderer matrix, no-op fixture, 45-output invariant, and watermark-evidence regression gates for current skin/color/filter renderer outputs. Commercial visual review, production GPU quality, real camera parity, automated screenshot diffing, 600-second preview, and physical iPhone evidence remain unproved. | Readiness claims could overstate visual quality or device behavior beyond current automated evidence. | Keep Phase 25 privacy/security implications routed; run 600-second and physical iPhone protocols when setup exists. | `partial/routed` |
```

Close or reroute these only with Phase 25 evidence. Preserve blockers and future checks instead of deleting unresolved risk.

## Shared Patterns

### Active Security Scans

**Source:** `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`
**Apply to:** SEC-02, SEC-04 tests and evidence artifact

Use the existing XCTest source-scan helpers for durable regression coverage, and use shell `rg` scans in the evidence artifact for broad one-time closeout. Split active source, tests, docs, and evidence artifacts so guard literals are not misread as active leaks.

Recommended command patterns from research:

```bash
find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print
rg -n "URLSession|http://|https://|upload|download|remote|cloud|analytics|telemetry|tracking" BeautySDK/Sources BeautyDemo/BeautyDemo BeautySDK/Package.swift BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj
rg -n "VNFaceObservation|boundingBox|landmark|NSError|AVError|/private/var|rawPresetJson|raw JSON|image bytes" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor
rg -n "Firebase|Alamofire|RevenueCat|StoreKit|VIP|entitlement|payment|remote|cloud|analytics" BeautySDK/Package.swift BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj BeautySDK/Sources BeautyDemo/BeautyDemo
```

### Privacy Manifest Decision

**Source:** `SECURITY.md` platform privacy rules and `BeautySDK/Package.swift`
**Apply to:** SEC-01 evidence, optional `PrivacyInfo.xcprivacy`, `SECURITY.md`, `QUALITY_SCORE.md`, `.planning/REQUIREMENTS.md`

Decision order:

```text
1. Inventory existing manifests.
2. Scan actual SDK/Demo data collection, upload, persistence, and logging behavior.
3. Scan required-reason API seed tokens and classify SDK vs Demo ownership.
4. If required, add the smallest fact-matching manifest to the target resources that own the behavior.
5. If not required, explicitly defer with evidence, host App responsibility, and rerun triggers.
```

If a manifest is added, verify with:

```bash
plutil -lint <chosen-target-resource-path>/PrivacyInfo.xcprivacy
plutil -p <chosen-target-resource-path>/PrivacyInfo.xcprivacy
swift test --package-path BeautySDK
```

### Resource Trust

**Source:** `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift`, `BeautyResourceManifest.swift`, `BeautyResourceCatalog.swift`
**Apply to:** SEC-03 tests, evidence artifact, `SECURITY.md`, `QUALITY_SCORE.md`

Copy the existing pattern: bundled resources only, `Bundle.module`, conservative logical IDs, no traversal-like IDs, metadata-only filters, missing-resource typed errors, and redacted decode failures. Real LUT, makeup, model, sticker, external package, dynamic download, cache, checksum, or signature behavior stays disabled/future unless a later phase explicitly designs it.

### Closeout Ledger Sync

**Source:** `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `PLANS.md`, `QUALITY_SCORE.md`
**Apply to:** DOC-01, DOC-02, DOC-03

Use evidence-first ordering:

```text
25-SECURITY-CLOSEOUT.md pass/blocker rows
  -> SECURITY.md conclusion
  -> QUALITY_SCORE.md score/evidence update
  -> .planning/REQUIREMENTS.md requirement checkboxes and traceability
  -> .planning/ROADMAP.md phase status/current evidence
  -> .planning/PROJECT.md and .planning/STATE.md current baseline
  -> PLANS.md completed entry and debt disposition
```

Final scans should include requirement IDs, Phase 25 references, forbidden overclaims, and scoped diff whitespace:

```bash
rg -n "SEC-01|SEC-02|SEC-03|SEC-04|DOC-01|DOC-02|DOC-03|Phase 25" QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md
claim_pattern='App Store rea''dy|commercial distribution rea''dy|all-device rea''dy|market visual-quality rea''dy|physical-device pari''ty|release-rea''dy|production-rea''dy'
rg -n "$claim_pattern" .planning/phases/25-security-distribution-review-and-closeout SECURITY.md QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md
git diff --check -- .planning/phases/25-security-distribution-review-and-closeout SECURITY.md QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md BeautySDK BeautyDemo
```

## No Analog Found

All expected Phase 25 file roles have usable analogs. The privacy manifest itself has no existing `PrivacyInfo.xcprivacy` analog in the repo, so use Apple plist requirements plus the existing SwiftPM `resources: [.process("Resources")]` target-resource pattern from `BeautySDK/Package.swift`.

## Metadata

**Analog search scope:** root contracts, `.planning` phase artifacts, SwiftPM package file, Demo Xcode project references, SDK source/tests, Demo source/tests.
**Files scanned:** AGENTS.md, PLANS.md, SECURITY.md, QUALITY_SCORE.md, `25-CONTEXT.md`, `25-RESEARCH.md`, `23-PERFORMANCE-EVIDENCE.md`, `24-RENDERER-EVIDENCE.md`, `24-PATTERNS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, active source/test analogs.
**Pattern extraction date:** 2026-07-03
