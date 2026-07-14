# Phase 25: Security, Distribution Review, and Closeout - Research

**Researched:** 2026-07-03  
**Domain:** iOS SDK privacy/security closeout, SwiftPM distribution review, resource trust, traceability synchronization  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

Source: `.planning/phases/25-security-distribution-review-and-closeout/25-CONTEXT.md` [VERIFIED: codebase]

### Locked Decisions

#### Privacy Manifest Disposition
- **D-01:** Start with an evidence-backed privacy manifest assessment. Phase 25 should inspect actual SDK/Demo data behavior, whether any user data is collected, uploaded, or persisted, and Apple required-reason API usage before deciding whether to add or explicitly defer `PrivacyInfo.xcprivacy`.
- **D-02:** If Phase 25 finds required-reason API usage or distribution risk, add the smallest fact-matching `PrivacyInfo.xcprivacy`; do not defer a manifest solely because the current SDK/Demo has no data collection or upload.
- **D-03:** Store the privacy assessment in a dedicated Phase 25 evidence document, then synchronize the conclusion into `SECURITY.md`, `QUALITY_SCORE.md`, and `.planning/REQUIREMENTS.md`.
- **D-04:** The assessment must describe SDK behavior separately from host App responsibility. The SDK remains local-first by default: no image/frame/landmark upload, no raw-frame persistence, and no sensitive path or geometry logging.

#### Security Scan Boundary
- **D-05:** Hard-gate active SDK/Demo source and tests for known v1.4 risk surfaces: no-network/no-upload, raw path/error leakage, face geometry leakage, raw JSON or serialized diagnostic leakage, third-party SDKs, and hidden product scope.
- **D-06:** Active-surface sensitive leaks are FAIL items. Test guard literals, fixture strings, and documentation forbidden examples must be classified explicitly and not misread as active leaks.
- **D-07:** Third-party SDK, analytics, remote config, cloud, payment, VIP, and entitlement checks must include `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, and active source-token scans.
- **D-08:** If scans find active leaks, fix them with narrow changes when possible. If a finding is caused by tooling, environment, historical context, or out-of-scope background text, record blocker, impact, and rerun protocol without broad rewrites.

#### Resource Trust Review
- **D-09:** Review current bundled resources: built-in presets, metadata filters, resource identifiers, manifest validation, unknown filter or preset behavior, traversal-like IDs, and missing-resource typed errors.
- **D-10:** Close resource-trust evidence with tests, scans, and `SECURITY.md` synchronization. Static scans alone are not enough if existing tests can verify the behavior.
- **D-11:** Keep real LUT, makeup, model, sticker, and external resource packages forbidden or disabled until an explicit future design defines manifest schema, size/type limits, checksum or signature rules, path traversal rules, cache behavior, and failure policy.
- **D-12:** Allow small evidence-backed `QUALITY_SCORE.md` updates for current resource-trust evidence. Do not raise future external-resource capability to complete or score 5 based only on current bundled-resource review.

#### Closeout Evidence Sync
- **D-13:** Use a traceability gate before Phase 25 completion. `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` must agree with Phase 25 evidence, closed or deferred debt, and reasons for unrun checks.
- **D-14:** Unrun or blocked release-like checks require an explicit blocker/deferred table with command or protocol, reason, impact, next step, and whether the item blocks v1.4 closeout. Never record an unrun check as pass evidence.
- **D-15:** Run all locally available verification before closeout: full SDK tests, relevant focused tests and scans, and Demo commands when the local toolchain allows. Unavailable checks require exact blocker and rerun protocol.
- **D-16:** Final milestone wording must stay conservative. Acceptable: audit-ready, traceability-ready, current-evidence baseline. Forbidden without direct evidence: App Store submission approval, commercial packaging completion, broad-device coverage, market visual-quality acceptance, hardware parity, and broad release claims.

### the agent's Discretion
The planner may choose exact evidence filenames, scan command shapes, test filters, privacy manifest file placement if needed, and final ledger wording. Keep the phase evidence-first and conservative: narrow fixes for active leaks, no feature expansion, no broad docs sweep, no external resource prototype, and no readiness overclaim.

### Deferred Ideas (OUT OF SCOPE)

- Full App Store privacy-detail review for a host app remains outside Phase 25 unless required by the SDK privacy manifest assessment.
- Full external resource manager, package download, cache, checksum/signature pipeline, and real LUT/makeup/model/sticker package implementation remain future work.
- Broad root-doc, `docs/`, or `.planning/codebase/*` historical cleanup remains deferred unless a specific Phase 25 evidence conflict blocks closeout.
- App Store submission approval, commercial packaging completion, broad-device coverage, market visual-quality acceptance, hardware parity, and release-grade naturalness remain unclaimed unless future evidence directly supports them.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SEC-01 | Privacy manifest assessment; add or defer `PrivacyInfo.xcprivacy` based on actual behavior and required-reason API usage. | Use Apple privacy-manifest docs, current `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy`, package/project scans, and active-source data-flow scans. [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files] [VERIFIED: codebase] |
| SEC-02 | Active SDK/Demo no-network, no-upload, no raw path/error/geometry/serialized diagnostic leakage checks pass. | Extend existing `InputPipelinePrivacyTests` and active-source `rg` scans across SDK/Demo source while classifying test guard literals separately. [VERIFIED: codebase] |
| SEC-03 | Resource trust boundaries match `SECURITY.md` for bundled presets, filters, identifiers, missing resources, and future assumptions. | Reuse `BeautyResourceCatalogTests`, `BeautyResourceManifest`, manifest JSON, and `SECURITY.md` resource rules. [VERIFIED: codebase] |
| SEC-04 | No hidden third-party SDK, analytics, remote config, cloud, dynamic download, payment, VIP, or entitlement behavior. | Scan `BeautySDK/Package.swift`, `BeautyDemo.xcodeproj`, and active source tokens. Current SwiftPM package has no external dependencies. [VERIFIED: codebase] |
| DOC-01 | Refresh `QUALITY_SCORE.md` after v1.4 evidence exists. | Update only after Phase 25 evidence file records pass/blocker results. [VERIFIED: codebase] |
| DOC-02 | `PLANS.md` records v1.4 outcomes, debt disposition, evidence, and unrun checks. | Close TD-005/TD-010 routing conservatively; preserve blocker-honest wording. [VERIFIED: codebase] |
| DOC-03 | `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` maintain 100% v1.4 traceability. | Run traceability scans and update Phase 25 status without unsupported readiness claims. [VERIFIED: codebase] |
</phase_requirements>

## Summary

Phase 25 should be planned as a closeout evidence phase, not a feature phase. Current repository contracts make local-first behavior, no upload, redacted diagnostics, facade-only Demo imports, metadata-only filters, and bundled preset validation the security baseline. [VERIFIED: codebase] Apple documents privacy manifests for apps and third-party SDKs, including Swift packages, and says required-reason API use must be reported in the relevant app or SDK manifest. [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files] [CITED: developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api]

The main planning shape is: create a dedicated Phase 25 evidence artifact, run privacy manifest assessment and active-surface scans first, fix only active leaks if found, then synchronize root and planning ledgers. [VERIFIED: codebase] Existing tests already cover most Demo privacy and resource trust checks; the planner should reuse them and add only narrow coverage if the assessment finds a gap. [VERIFIED: codebase]

**Primary recommendation:** Plan two waves: Wave 1 for privacy/security/resource evidence and narrow fixes; Wave 2 for ledger synchronization, traceability gate, and conservative closeout wording. [VERIFIED: codebase]

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md`, then `PLANS.md`, then task-owner docs before edits. [VERIFIED: AGENTS.md]
- Repository text is the system of record; facts absent from repository text must not be assumed as current behavior. [VERIFIED: AGENTS.md]
- Do not expand task scope; record extra issues in `PLANS.md`. [VERIFIED: AGENTS.md]
- Do not overwrite user changes. [VERIFIED: AGENTS.md]
- If security/privacy boundaries change, update `SECURITY.md`. [VERIFIED: AGENTS.md]
- If reliability/error/logging behavior changes, update `RELIABILITY.md`. [VERIFIED: AGENTS.md]
- If public behavior changes, update `PRODUCT_SENSE.md`. [VERIFIED: AGENTS.md]
- Xcode commands must use explicit iOS Simulator destinations and must record real blocker output if local Xcode setup fails. [VERIFIED: AGENTS.md]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Privacy manifest assessment | SDK package / Demo target resources | Documentation ledgers | Manifest status depends on actual SDK/Demo behavior and Apple-required declarations; docs record the conclusion. [VERIFIED: codebase] [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files] |
| Required-reason API scan | SDK/Demo active source | Apple documentation | The codebase owns API usage; Apple docs define which API categories require declarations. [CITED: developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api] |
| No-network/no-upload scan | SDK/Demo active source | XCTest scan helpers | Current policy forbids default network/upload behavior; tests and `rg` scans provide evidence. [VERIFIED: SECURITY.md] [VERIFIED: codebase] |
| Resource trust review | `BeautyResources` target | `BeautySDK` facade tests | Resource schema, IDs, bundled presets, and typed errors are implemented in `BeautyResources` and surfaced through facade validation. [VERIFIED: codebase] |
| Third-party SDK/distribution review | Package/project declarations | Active source scan | External dependencies or product-scope behavior would appear in SwiftPM, Xcode project references, or active source tokens. [VERIFIED: codebase] |
| Closeout traceability | `.planning` and root docs | Phase 25 evidence artifact | `DOC-01` through `DOC-03` are documentation synchronization requirements gated by evidence. [VERIFIED: .planning/REQUIREMENTS.md] |

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Swift Package Manager / Swift | Package declares `swift-tools-version: 6.0`; local Swift is `6.3.3`. | SDK build, test, and target/resource declarations. | Current SDK is a Swift package and Phase 21-24 evidence uses SwiftPM. [VERIFIED: codebase] |
| XCTest | Xcode 26.6 local toolchain. | Unit and integration evidence for SDK and Demo tests. | Existing test suites are XCTest-based. [VERIFIED: codebase] |
| Xcode / `xcodebuild` | Xcode `26.6`, build `17F113`. | Demo project inventory and explicit simulator test/build commands. | Demo is an Xcode project; existing evidence uses explicit iOS Simulator destinations. [VERIFIED: local command] |
| `rg` | `15.1.0`. | Negative security scans and traceability scans. | Repo guidance prefers `rg`; existing phase evidence uses it. [VERIFIED: local command] |
| `plutil` | macOS tool available. | Lint and inspect `PrivacyInfo.xcprivacy` if added. | Apple privacy manifests are property list files named `PrivacyInfo.xcprivacy`. [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk] [VERIFIED: local command] |

### Supporting

| Tool | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Python 3 | `3.9.6`. | Existing renderer helper execution if closeout reruns Phase 24 evidence. | Only if Phase 25 decides to rerun renderer evidence. [VERIFIED: local command] |
| Node.js | `v26.0.0`. | Direct GSD tool invocation when `gsd-tools` is not on PATH. | Use `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs` for decision/traceability checks if needed. [VERIFIED: local command] |
| `xcrun simctl` | Xcode 26.6 toolchain. | Simulator inventory and screenshot rerun protocols. | Only for Demo commands where local tooling allows. [VERIFIED: local command] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Existing XCTest + `rg` scans | New third-party security scanner | Not needed for Phase 25; adds dependency review burden without current package need. [VERIFIED: codebase] |
| Evidence-backed `PrivacyInfo.xcprivacy` decision | Always add a generic manifest | Generic manifests risk mismatch; Phase 25 decisions require fact-matching content. [VERIFIED: 25-CONTEXT.md] |
| Narrow root/planning ledger sync | Broad historical-doc rewrite | Deferred by context unless an evidence conflict blocks closeout. [VERIFIED: 25-CONTEXT.md] |

**Installation:**

```bash
# No external package install is recommended for Phase 25.
```

**Version verification:** Local versions checked during research: Swift `6.3.3`, Xcode `26.6`, Python `3.9.6`, Node `v26.0.0`, `rg 15.1.0`. [VERIFIED: local command]

## Package Legitimacy Audit

No new external packages are recommended or required. The Package Legitimacy Gate is not applicable because Phase 25 should not install packages. [VERIFIED: codebase]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| none | — | — | — | — | — | No install |

**Packages removed due to slopcheck [SLOP] verdict:** none  
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
Apple privacy rules + repo security contracts
        |
        v
Phase 25 evidence artifact
        |
        +--> Privacy manifest assessment
        |       |
        |       +--> scan SDK/Demo data collection, network, persistence
        |       +--> scan required-reason API seed list
        |       +--> decision: add smallest manifest OR explicitly defer
        |
        +--> Active security scans
        |       |
        |       +--> source-token scans
        |       +--> focused XCTest privacy/resource tests
        |       +--> classify test guard literals vs active leaks
        |
        +--> Resource trust review
        |       |
        |       +--> bundled manifest and presets
        |       +--> identifier and traversal guards
        |       +--> missing resource typed errors
        |
        v
Ledger synchronization
        |
        +--> SECURITY.md / QUALITY_SCORE.md / PLANS.md
        +--> PROJECT.md / REQUIREMENTS.md / ROADMAP.md / STATE.md
        |
        v
Audit-ready, traceability-ready v1.4 closeout wording only
```

### Recommended Project Structure

```text
.planning/phases/25-security-distribution-review-and-closeout/
├── 25-CONTEXT.md
├── 25-RESEARCH.md
├── 25-SECURITY-CLOSEOUT.md      # recommended evidence artifact
├── 25-VALIDATION.md             # optional if planner keeps validation separate
└── 25-*-PLAN.md                 # planner-created execution plans
```

`25-SECURITY-CLOSEOUT.md` should record exact commands, results, blocker/deferred tables, privacy-manifest decision, resource-trust evidence, and ledger sync checklist. [VERIFIED: 25-CONTEXT.md]

### Pattern 1: Evidence Ledger Before Ledgers

**What:** Record Phase 25 scan/test results in a dedicated evidence file before editing `QUALITY_SCORE.md`, `SECURITY.md`, `.planning/REQUIREMENTS.md`, or `PLANS.md`. [VERIFIED: 25-CONTEXT.md]  
**When to use:** Always for Phase 25 closeout. [VERIFIED: 25-CONTEXT.md]  
**Example:**

```markdown
## Privacy Manifest Assessment

| Area | Status | Evidence | Decision |
| --- | --- | --- | --- |
| Required-reason API scan | passed/failed/blocked | `rg ...` | Add or defer manifest |
| Data collection/upload | passed/failed | `rg ...` + tests | SDK no collection / fix leak |
| Host App responsibility | recorded | SECURITY.md sync | Host owns camera/photo permission and App Store privacy answers |
```

### Pattern 2: Active Leak Classification

**What:** Treat active SDK/Demo leak matches as failures, but classify tests, docs, and guard literals separately. [VERIFIED: 25-CONTEXT.md]  
**When to use:** For forbidden tokens such as `/private/var`, `NSError`, `AVError`, `rawPresetJson`, `VNFaceObservation`, `boundingBox`, `landmark`, network URLs, payment, and VIP. [VERIFIED: codebase]  
**Example command set:**

```bash
rg -n "URLSession|http://|https://|upload|download|remote|cloud|analytics|telemetry|tracking" \
  BeautySDK/Sources BeautyDemo/BeautyDemo BeautySDK/Package.swift BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj

rg -n "VNFaceObservation|boundingBox|landmark|NSError|AVError|/private/var|rawPresetJson|image bytes" \
  BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor
```

### Pattern 3: Privacy Manifest Decision Tree

**What:** Decide manifest action from evidence, not from a blanket rule. [VERIFIED: 25-CONTEXT.md]  
**When to use:** Before adding or deferring `PrivacyInfo.xcprivacy`. [VERIFIED: 25-CONTEXT.md]  
**Decision tree:**

```text
Does active SDK code collect data, enable host data collection, contact tracking domains,
or use Apple required-reason APIs?
  |
  +-- yes --> add smallest fact-matching PrivacyInfo.xcprivacy to the correct target resources
  |
  +-- no  --> record explicit deferral with scan evidence, host App responsibility, and rerun trigger
```

Apple states apps and third-party SDKs, including Swift packages, can contain a manifest named `PrivacyInfo.xcprivacy`; the file is added to target resources. [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files] [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk]

### Anti-Patterns to Avoid

- **Generic privacy manifest:** Do not add declarations that do not match current SDK/Demo behavior. [VERIFIED: 25-CONTEXT.md]
- **String-scan panic:** Do not rewrite docs/tests just because forbidden examples or guard literals contain negative tokens. [VERIFIED: 25-CONTEXT.md]
- **Security-by-doc-only:** Do not mark resource trust complete from `SECURITY.md` text alone; run existing tests or add narrow tests. [VERIFIED: 25-CONTEXT.md]
- **Closeout overclaim:** Do not claim App Store, commercial, physical-device, market-quality, or all-device readiness without direct evidence. [VERIFIED: 25-CONTEXT.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Privacy manifest schema validation | Custom plist parser | Xcode App Privacy file + `plutil -lint`/`plutil -p` | Manifest is a property list resource; platform tools reduce schema/format mistakes. [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk] |
| Resource trust for future external packages | Ad hoc file loader or URL downloader | Keep external resources disabled until a designed `BeautyResourceManager` exists | `SECURITY.md` requires manifest/schema/path/size/checksum/cache/failure policy before enabling external packages. [VERIFIED: SECURITY.md] |
| Third-party SDK inventory | Manual eyeballing only | `Package.swift`, `project.pbxproj`, and source-token scans | Hidden dependencies can enter through package/project references or active source. [VERIFIED: codebase] |
| Leak detection | Broad unclassified search only | Existing XCTest privacy tests plus scoped active-source `rg` scans | Tests already classify active Demo surfaces and guard literals better than a single broad grep. [VERIFIED: codebase] |
| Readiness narrative | Marketing summary | Evidence ledger with pass/blocker/deferred status | Phase 25 explicitly forbids unsupported readiness claims. [VERIFIED: 25-CONTEXT.md] |

**Key insight:** The hard part is not writing new security code; it is preserving evidence fidelity so closeout docs say exactly what the repository proves. [VERIFIED: 25-CONTEXT.md]

## Common Pitfalls

### Pitfall 1: Treating No Upload As No Manifest Needed
**What goes wrong:** The plan defers `PrivacyInfo.xcprivacy` only because no upload/data collection is found. [VERIFIED: 25-CONTEXT.md]  
**Why it happens:** Required-reason APIs and SDK distribution risk are separate from upload behavior. [CITED: developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api]  
**How to avoid:** Scan required-reason API seed tokens and document distribution context before deciding. [VERIFIED: 25-CONTEXT.md]  
**Warning signs:** Manifest decision appears before scan results. [VERIFIED: 25-CONTEXT.md]

### Pitfall 2: Misclassifying Test Guard Literals
**What goes wrong:** Tests that intentionally contain forbidden strings are reported as active leaks. [VERIFIED: codebase]  
**Why it happens:** Broad source scans include tests and docs without classification. [VERIFIED: codebase]  
**How to avoid:** Split active source, tests, docs, and evidence artifacts into separate scan sections. [VERIFIED: 25-CONTEXT.md]  
**Warning signs:** Findings point to `InputPipelinePrivacyTests.swift` forbidden token arrays. [VERIFIED: codebase]

### Pitfall 3: Raising Resource Scores For Future Assets
**What goes wrong:** Current bundled preset evidence is used to mark external LUT/makeup/model/sticker packages complete. [VERIFIED: 25-CONTEXT.md]  
**Why it happens:** Current `BeautyResources` covers metadata filters and bundled presets, not external package integrity. [VERIFIED: codebase]  
**How to avoid:** Update scores only for current bundled-resource trust; keep external resource packages future/deferred. [VERIFIED: SECURITY.md]

### Pitfall 4: Closeout Ledgers Drift
**What goes wrong:** `QUALITY_SCORE.md`, `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/PROJECT.md`, and `.planning/STATE.md` disagree after evidence is added. [VERIFIED: 25-CONTEXT.md]  
**Why it happens:** Evidence and ledger edits are done in different tasks without a final traceability gate. [VERIFIED: 25-CONTEXT.md]  
**How to avoid:** Reserve a final Wave 2 closeout task for requirement status, debt routing, and wording scans. [VERIFIED: 25-CONTEXT.md]

## Code Examples

Verified patterns from current codebase and official sources:

### Active Privacy Scan Commands

```bash
find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print

rg -n "URLSession|http://|https://|upload|download|remote|cloud|analytics|telemetry|tracking" \
  BeautySDK/Sources BeautyDemo/BeautyDemo BeautySDK/Package.swift BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj

rg -n "VNFaceObservation|boundingBox|landmark|NSError|AVError|/private/var|rawPresetJson|raw JSON|image bytes" \
  BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor
```

Source: current Phase 21/25 scan patterns and `InputPipelinePrivacyTests`. [VERIFIED: codebase]

### Required-Reason API Seed Scan

```bash
rg -n "UserDefaults|FileManager\\.default|attributesOfItem|attributesOfFileSystem|creationDate|modificationDate|contentModificationDateKey|fileModificationDate|systemUptime|mach_absolute_time|activeInputModes|stat\\(|fstat\\(|lstat\\(" \
  BeautySDK/Sources BeautyDemo/BeautyDemo
```

Source: Apple required-reason documentation defines covered API declarations; the exact seed list is an audit starting point and must be checked against Apple docs during execution. [CITED: developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api] [ASSUMED]

### Focused XCTest Evidence

```bash
swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyResultDetectionSummaryTests
swift test --package-path BeautySDK --filter BeautySDKTests.BeautySDKFacadeTests
swift test --package-path BeautySDK
```

Source: current test inventory lists these suites and Phase 24 full suite passed with 150 XCTest cases. [VERIFIED: codebase]

### Demo Privacy Test Command

```bash
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj \
  -scheme BeautyDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -only-testing:BeautyDemoTests/InputPipelinePrivacyTests \
  -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests \
  test
```

Source: project inventory lists `BeautyDemo` scheme and available iPhone 17 / iOS 26.5 simulator; tests exist in current codebase. [VERIFIED: local command] [VERIFIED: codebase]

### Manifest Lint If Added

```bash
plutil -lint BeautySDK/Sources/BeautySDK/Resources/PrivacyInfo.xcprivacy
plutil -p BeautySDK/Sources/BeautySDK/Resources/PrivacyInfo.xcprivacy
```

Source: `plutil` is available locally; exact manifest path should follow the target-resource placement chosen during execution. [VERIFIED: local command] [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| App privacy review handled only by App Store privacy answers | Privacy manifests can describe app and third-party SDK privacy practices, and Xcode can aggregate manifests into privacy reporting. | Introduced at WWDC23; App Store submission enforcement began in 2024 for listed cases. [CITED: developer.apple.com/videos/play/wwdc2023/10060/] [CITED: developer.apple.com/news/?id=3d8a9yyh] | Phase 25 must assess SDK manifest status, not only Demo Info.plist purpose strings. |
| Required-reason API usage could be undocumented | Apple requires approved reasons for listed API usage in app manifests for app code and SDK manifests for SDK code. | May 1, 2024 enforcement for new or updated app submissions. [CITED: developer.apple.com/news/?id=pvszzano] | Phase 25 must scan SDK and Demo source for covered API usage. |
| Third-party SDK inventory could be informal | Apple lists commonly used SDKs that require privacy manifests and signatures in submission scenarios. | 2024 Apple third-party SDK requirements. [CITED: developer.apple.com/support/third-party-SDK-requirements/] | Phase 25 should prove no hidden listed SDKs or analytics/cloud SDKs entered `Package.swift` or the Xcode project. |

**Deprecated/outdated:**
- Treating `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` as the whole privacy review is incomplete; protected-resource purpose strings and privacy manifests answer different questions. [VERIFIED: SECURITY.md] [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The required-reason seed scan token list covers likely iOS API families but is not an authoritative full Apple list. | Code Examples / Validation Architecture | Planner might miss a newly listed API unless execution cross-checks Apple docs. |
| A2 | `BeautySDK/Sources/BeautySDK/Resources/PrivacyInfo.xcprivacy` is a plausible manifest location if the facade target owns the SDK manifest. | Code Examples | Execution may choose `BeautyCore` or another target resource location based on actual API use and SwiftPM resource packaging. |

## Open Questions (RESOLVED)

1. **RESOLVED for planning: Does the final active source use any Apple required-reason API after Phase 25 scans?**
   - What we know: Research scan found no current `PrivacyInfo.xcprivacy`; a broad token scan found `FileManager.default` in `BeautyExampleRenderer` and `remoteInfo` project metadata, not active SDK/Demo behavior. [VERIFIED: codebase]
   - Planning resolution: Plan `25-01` owns required-reason API classification as an execution evidence step. The executor must cross-check active-source matches against current Apple documentation, record the checked date in `25-SECURITY-CLOSEOUT.md`, and then add the smallest fact-matching manifest or explicitly defer with evidence. [VERIFIED: 25-CONTEXT.md]
   - Execution rule: The final declaration decision is a planned SEC-01 evidence gate, not an open planning question. [VERIFIED: 25-VALIDATION.md]

2. **RESOLVED for planning: If a manifest is added, which target owns it?**
   - What we know: Apple says manifests are added to target resources, and `BeautySDK` is distributed as a Swift package library facade. [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk] [VERIFIED: codebase]
   - Planning resolution: Plan `25-01` owns manifest target placement if evidence requires a manifest. The executor must choose the smallest fact-matching target resource path based on the code path that triggers declaration, with `BeautySDK/Sources/BeautySDK/Resources/PrivacyInfo.xcprivacy` as the facade-owned candidate only when the facade target owns the SDK declaration. [VERIFIED: 25-PATTERNS.md]
   - Execution rule: Target ownership is a planned SEC-01 implementation decision with required package/project inclusion evidence and `plutil` validation when a manifest is added, not an open planning question. [VERIFIED: 25-VALIDATION.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Swift | SDK tests | yes | Apple Swift `6.3.3` | None needed. [VERIFIED: local command] |
| Xcode | Demo tests/build, simulator | yes | Xcode `26.6`, build `17F113` | If Demo command fails, record exact blocker and rerun protocol. [VERIFIED: local command] |
| iOS Simulator | Demo test destination | yes | iOS `26.5`, `iPhone 17` available | Use another listed iOS 26.5 simulator only if command is updated explicitly. [VERIFIED: local command] |
| `rg` | scans | yes | `15.1.0` | None needed. [VERIFIED: local command] |
| `plutil` | manifest lint | yes | system tool | Use Xcode editor inspection if needed. [VERIFIED: local command] |
| Python 3 | optional renderer helper | yes | `3.9.6` | Skip unless rerunning Phase 24 helper. [VERIFIED: local command] |
| Node.js | GSD direct tool fallback | yes | `v26.0.0` | Use shell/manual scans if GSD command fails. [VERIFIED: local command] |
| `ctx7` | optional docs lookup | no | — | Official Apple docs via web were used. [VERIFIED: local command] |
| `gsd-tools` on PATH | GSD CLI shorthand | no | — | Use `node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs`. [VERIFIED: local command] |

**Missing dependencies with no fallback:** none identified for Phase 25 research/planning. [VERIFIED: local command]  
**Missing dependencies with fallback:** `ctx7`, `gsd-tools` PATH shorthand. [VERIFIED: local command]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest through SwiftPM and Xcode. [VERIFIED: codebase] |
| Config file | `BeautySDK/Package.swift` and `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`. [VERIFIED: codebase] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` |
| Full suite command | `swift test --package-path BeautySDK` |
| Demo focused command | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/InputPipelinePrivacyTests -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests test` |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SEC-01 | Manifest assessment matches actual SDK/Demo behavior and required-reason API usage. | scan + artifact + optional plist lint | `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print`; required-reason seed `rg`; `plutil -lint <manifest>` if added | Existing scans yes; evidence file new |
| SEC-02 | Active no-network/no-upload/raw-path/error/geometry/raw-diagnostic checks pass. | unit + source scan | Demo focused xcodebuild command above; active-source `rg` commands in Code Examples | yes |
| SEC-03 | Bundled resource manifest, filters, presets, identifiers, and missing resources stay trusted. | unit + source scan | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` | yes |
| SEC-04 | No hidden third-party SDK, analytics, cloud, dynamic download, payment, VIP, or entitlement behavior. | source/config scan | `rg -n "Firebase|Alamofire|RevenueCat|StoreKit|VIP|entitlement|payment|remote|cloud|analytics" BeautySDK/Package.swift BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj BeautySDK/Sources BeautyDemo/BeautyDemo` | yes |
| DOC-01 | Quality score updated only from evidence. | doc scan | `rg -n "Phase 25|SEC-01|SEC-02|SEC-03|SEC-04|DOC-01" QUALITY_SCORE.md .planning/phases/25-security-distribution-review-and-closeout` | doc exists |
| DOC-02 | Plans ledger records Phase 25 outcome and blockers honestly. | doc scan | `rg -n "Phase 25|TD-005|TD-010|privacy manifest|security" PLANS.md` | doc exists |
| DOC-03 | Project/requirements/roadmap/state remain traceable. | doc scan | `rg -n "SEC-01|SEC-02|SEC-03|SEC-04|DOC-01|DOC-02|DOC-03|Phase 25" .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md` | docs exist |

### Sampling Rate

- **Per task commit:** focused test or scan for the touched surface; always run `git diff --check -- <touched files>`. [VERIFIED: AGENTS.md]
- **Per wave merge:** full `swift test --package-path BeautySDK` plus all Phase 25 active-source scans. [VERIFIED: codebase]
- **Phase gate:** full SDK tests, focused Demo privacy/import command or blocker record, final no-overclaim scan, and traceability scan before `$gsd-verify-work`. [VERIFIED: 25-CONTEXT.md]

### Wave 0 Gaps

- [ ] `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md` — create evidence artifact for SEC-01 through DOC-03. [VERIFIED: 25-CONTEXT.md]
- [ ] If `PrivacyInfo.xcprivacy` is added, add manifest lint/build verification for the chosen target resource path. [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk]
- [ ] If active scans find a source leak, add the narrowest regression test covering that leak before closeout. [VERIFIED: 25-CONTEXT.md]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No auth feature is in Phase 25 scope; payment/VIP/entitlement behavior must remain absent. [VERIFIED: 25-CONTEXT.md] |
| V3 Session Management | no | No sessions or accounts are in scope. [VERIFIED: .planning/REQUIREMENTS.md] |
| V4 Access Control | no | No protected backend resources are in scope. [VERIFIED: .planning/REQUIREMENTS.md] |
| V5 Input Validation | yes | Existing `BeautyResources`, `BeautyPreset`, and Demo JSON validation patterns; run resource and JSON/privacy tests. [VERIFIED: codebase] |
| V6 Cryptography | no for current bundled resources; future external packages require checksum/signature design | Do not hand-roll crypto; keep external resources disabled until explicit design. [VERIFIED: SECURITY.md] |
| V8 Data Protection | yes | Local-first processing, no upload, no raw-frame persistence, redacted logs, manifest assessment. [VERIFIED: SECURITY.md] |
| V9 Communications | yes as negative control | No network/upload by default; scan for network/cloud tokens. [VERIFIED: SECURITY.md] |
| V14 Configuration | yes | SwiftPM/Xcode project dependency and resource review. [VERIFIED: codebase] |

### Known Threat Patterns for iOS SDK/Demo

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Hidden network/upload of frames or landmarks | Information Disclosure | Source scans, no SDK network dependency, Demo privacy tests, `SECURITY.md` sync. [VERIFIED: codebase] |
| Raw path/framework error leakage | Information Disclosure | Redacted typed errors and focused forbidden-token scans. [VERIFIED: codebase] |
| Face geometry leakage through public summaries/debug UI | Information Disclosure | Geometry-free `BeautyDetectionSummary` tests and Demo overlay scans. [VERIFIED: codebase] |
| Resource ID path traversal | Tampering | `BeautyResourceManifest.isValidResourceIdentifier` and traversal-like ID tests. [VERIFIED: codebase] |
| Dependency surprise or third-party SDK policy drift | Supply Chain | `Package.swift`, `project.pbxproj`, and active source scans. [VERIFIED: codebase] [CITED: developer.apple.com/support/third-party-SDK-requirements/] |
| Privacy manifest mismatch | Compliance / Information Disclosure | Evidence-backed manifest assessment; `plutil` lint if added; ledger synchronization. [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files] |

## Sources

### Primary (HIGH confidence)

- `.planning/phases/25-security-distribution-review-and-closeout/25-CONTEXT.md` - locked Phase 25 decisions, boundaries, deferred ideas. [VERIFIED: codebase]
- `.planning/REQUIREMENTS.md` - SEC/DOC requirement definitions and traceability. [VERIFIED: codebase]
- `.planning/STATE.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `PLANS.md`, `QUALITY_SCORE.md` - current v1.4 status and debt routing. [VERIFIED: codebase]
- `SECURITY.md`, `RELIABILITY.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `PRODUCT_SENSE.md` - root contracts. [VERIFIED: codebase]
- `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`, `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` - implementation and tests. [VERIFIED: codebase]
- Apple Developer Documentation: Privacy manifest files, adding a privacy manifest, describing required-reason API use. [CITED: developer.apple.com/documentation/bundleresources/privacy-manifest-files] [CITED: developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk] [CITED: developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api]
- Apple Developer Support: Third-party SDK requirements. [CITED: developer.apple.com/support/third-party-SDK-requirements/]
- Apple Developer News: Privacy updates and May 1, 2024 requirements. [CITED: developer.apple.com/news/?id=3d8a9yyh] [CITED: developer.apple.com/news/?id=pvszzano]

### Secondary (MEDIUM confidence)

- Apple WWDC23 video page: privacy manifests and Xcode privacy report overview. [CITED: developer.apple.com/videos/play/wwdc2023/10060/]

### Tertiary (LOW confidence)

- Required-reason seed token list synthesized from Apple docs/search result snippets and common iOS audit practice; execution must cross-check against official Apple docs before final manifest decisions. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - local tools and package/project files were inspected. [VERIFIED: local command] [VERIFIED: codebase]
- Architecture: HIGH - phase context and root contracts define clear ownership boundaries. [VERIFIED: codebase]
- Pitfalls: HIGH for project-specific pitfalls from prior evidence; MEDIUM for required-reason seed coverage because Apple docs are JS-rendered and exact API list should be manually cross-checked during execution. [VERIFIED: codebase] [ASSUMED]

**Research date:** 2026-07-03  
**Valid until:** 2026-08-02 for repo-specific findings; 2026-07-10 for Apple privacy-manifest policy details because distribution rules can change. [ASSUMED]
