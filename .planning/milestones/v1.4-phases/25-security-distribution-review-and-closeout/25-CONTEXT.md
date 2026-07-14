# Phase 25: Security, Distribution Review, and Closeout - Context

**Gathered:** 2026-07-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 25 closes v1.4 with security, privacy, resource-trust, distribution-readiness review, and traceability synchronization. It covers `SEC-01`, `SEC-02`, `SEC-03`, `SEC-04`, `DOC-01`, `DOC-02`, and `DOC-03`.

This is a closeout and evidence phase. It should assess privacy manifest needs from actual SDK/Demo behavior, Apple required-reason API usage, and distribution risk; run active-surface security scans; review current resource trust boundaries; and synchronize final evidence across quality, planning, and requirements ledgers.

Phase 25 must not add product-feature breadth, new public `BeautyParameters`, new UI routes, hidden network/cloud behavior, analytics, remote config, payment/VIP entitlement behavior, external resource-package implementation, or broad historical-document rewrites. Final wording may say v1.4 is audit-ready or traceability-ready only when supported by evidence; it must not claim App Store readiness, commercial distribution readiness, all-device readiness, or market visual-quality readiness without direct evidence.

</domain>

<decisions>
## Implementation Decisions

### Privacy Manifest Disposition
- **D-01:** Start with an evidence-backed privacy manifest assessment. Phase 25 should inspect actual SDK/Demo data behavior, whether any user data is collected, uploaded, or persisted, and Apple required-reason API usage before deciding whether to add or explicitly defer `PrivacyInfo.xcprivacy`.
- **D-02:** If Phase 25 finds required-reason API usage or distribution risk, add the smallest fact-matching `PrivacyInfo.xcprivacy`; do not defer a manifest solely because the current SDK/Demo has no data collection or upload.
- **D-03:** Store the privacy assessment in a dedicated Phase 25 evidence document, then synchronize the conclusion into `SECURITY.md`, `QUALITY_SCORE.md`, and `.planning/REQUIREMENTS.md`.
- **D-04:** The assessment must describe SDK behavior separately from host App responsibility. The SDK remains local-first by default: no image/frame/landmark upload, no raw-frame persistence, and no sensitive path or geometry logging.

### Security Scan Boundary
- **D-05:** Hard-gate active SDK/Demo source and tests for known v1.4 risk surfaces: no-network/no-upload, raw path/error leakage, face geometry leakage, raw JSON or serialized diagnostic leakage, third-party SDKs, and hidden product scope.
- **D-06:** Active-surface sensitive leaks are FAIL items. Test guard literals, fixture strings, and documentation forbidden examples must be classified explicitly and not misread as active leaks.
- **D-07:** Third-party SDK, analytics, remote config, cloud, payment, VIP, and entitlement checks must include `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, and active source-token scans.
- **D-08:** If scans find active leaks, fix them with narrow changes when possible. If a finding is caused by tooling, environment, historical context, or out-of-scope background text, record blocker, impact, and rerun protocol without broad rewrites.

### Resource Trust Review
- **D-09:** Review current bundled resources: built-in presets, metadata filters, resource identifiers, manifest validation, unknown filter or preset behavior, traversal-like IDs, and missing-resource typed errors.
- **D-10:** Close resource-trust evidence with tests, scans, and `SECURITY.md` synchronization. Static scans alone are not enough if existing tests can verify the behavior.
- **D-11:** Keep real LUT, makeup, model, sticker, and external resource packages forbidden or disabled until an explicit future design defines manifest schema, size/type limits, checksum or signature rules, path traversal rules, cache behavior, and failure policy.
- **D-12:** Allow small evidence-backed `QUALITY_SCORE.md` updates for current resource-trust evidence. Do not raise future external-resource capability to complete or score 5 based only on current bundled-resource review.

### Closeout Evidence Sync
- **D-13:** Use a traceability gate before Phase 25 completion. `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` must agree with Phase 25 evidence, closed or deferred debt, and reasons for unrun checks.
- **D-14:** Unrun or blocked release-like checks require an explicit blocker/deferred table with command or protocol, reason, impact, next step, and whether the item blocks v1.4 closeout. Never record an unrun check as pass evidence.
- **D-15:** Run all locally available verification before closeout: full SDK tests, relevant focused tests and scans, and Demo commands when the local toolchain allows. Unavailable checks require exact blocker and rerun protocol.
- **D-16:** Final milestone wording must stay conservative. Acceptable: audit-ready, traceability-ready, current-evidence baseline. Forbidden without direct evidence: App Store submission approval, commercial packaging completion, broad-device coverage, market visual-quality acceptance, hardware parity, and broad release claims.

### the agent's Discretion
The planner may choose exact evidence filenames, scan command shapes, test filters, privacy manifest file placement if needed, and final ledger wording. Keep the phase evidence-first and conservative: narrow fixes for active leaks, no feature expansion, no broad docs sweep, no external resource prototype, and no readiness overclaim.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger, update rules, completed v1.4 phase outcomes, and technical-debt routing.
- `.planning/PROJECT.md` - Defines v1.4 as stability, QA, performance, security, and debt cleanup without product-feature expansion.
- `.planning/REQUIREMENTS.md` - Defines `SEC-01` through `SEC-04` and `DOC-01` through `DOC-03`.
- `.planning/ROADMAP.md` - Defines Phase 25 goal, success criteria, dependency on Phases 21-24, and planned status.
- `.planning/STATE.md` - Records current focus as Phase 25 and carries v1.4 blocker context.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` - Records current privacy manifest absence, active privacy scans, Demo blocker context, and v1.4 debt routing.
- `.planning/phases/22-automated-demo-qa-and-screenshot-evidence/22-CONTEXT.md` - Locks blocker-honest Demo evidence and no-new-route policy.
- `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` - Records current Demo screenshot blocker and rerun protocol.
- `.planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md` - Locks performance evidence, redaction, optional logging, and non-claim policy.
- `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` - Records redacted performance evidence, blocked long-run/device evidence, and over-budget baseline classification.
- `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md` - Locks renderer evidence, geometry guard, no-overclaim, and generated-output policies.
- `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` - Records current renderer matrix evidence and generated-output invariant results.

### Root Contracts
- `SECURITY.md` - Owns local-first privacy, privacy manifest rule, resource trust, dependency policy, logging redaction, and SDK distribution security.
- `RELIABILITY.md` - Owns typed errors, metrics/log redaction, optional logs, performance/long-run gates, reset/recovery, and release-readiness caveats.
- `QUALITY_SCORE.md` - Owns evidence-backed score updates and current top repair queue, including Phase 25 privacy manifest/resource trust/closeout work.
- `PRODUCT_SENSE.md` - Owns product acceptance and release-hardening caveats; prevents unsupported release-readiness or market-quality claims.
- `ARCHITECTURE.md` - Owns SDK/Demo boundaries, facade-only Demo rule, target dependency direction, and no UI in SDK targets.
- `DESIGN.md` - Owns public models, parameter boundaries, detection summaries, resource IDs, metrics, and no public parameter expansion by default.
- `FRONTEND.md` - Owns Demo UI state and launch behavior; relevant for confirming Phase 25 does not add Demo routes or redesign scope.

### Current Code and Test Surfaces
- `BeautySDK/Package.swift` - Declares SDK targets, dependencies, products, and absence/presence of SwiftPM external package dependencies.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` - Declares Demo build settings, purpose strings, and Xcode project package references.
- `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` - Owns default `enablePerformanceLog` and `logLevel` behavior.
- `BeautySDK/Sources/BeautyCore/Models/BeautyLogLevel.swift` - Owns public log-level enum.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` - Owns warnings and metrics output surface that must remain redacted.
- `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift` - Owns warning shape and redaction-sensitive messages.
- `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` - Owns public geometry-free detection summary.
- `BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift` - Owns schema, identifier, filter, preset, and traversal-like validation.
- `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift` - Owns bundled manifest/preset loading and missing-resource typed errors.
- `BeautySDK/Sources/BeautyResources/Resources/manifest.json` - Current bundled resource manifest for metadata filters and presets.
- `BeautySDK/Sources/BeautyResources/Resources/Presets/` - Current bundled preset JSON resources.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` - Existing resource manifest, identifier, missing preset, and traversal-like ID evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` - Existing logging/default configuration evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` - Existing allowlisted, redacted performance evidence output.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - Existing facade warnings/metrics redaction evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyResultDetectionSummaryTests.swift` - Existing public detection summary redaction evidence.
- `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift` - Existing public facade and resource validation evidence.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Existing Demo no-network/no-upload/raw-path/raw-error, facade-only import, purpose string, JSON/debug, and geometry-free privacy scans.
- `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` - Existing Demo import-boundary evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `InputPipelinePrivacyTests` already scans active Demo camera/editor/support paths for `URLSession`, `http://`, `https://`, upload, raw `/private/var`, `NSError`, and `AVError`, and also verifies generated Info.plist camera/photo purpose strings.
- `InputPipelinePrivacyTests` already covers facade-only Demo imports, copy/paste-only JSON behavior, redacted preview debug overlay, future unavailable copy, and public detection summary leakage scans.
- `BeautyResourceManifest.isValidResourceIdentifier(_:)` validates resource IDs through `BeautyPreset.isValidIdentifier` and rejects `..`.
- `BeautyResourceCatalog.bundled()` and `preset(id:)` map missing manifest/preset resources to `BeautyError.resourceNotFound(...)`, and manifest/preset schema problems to redacted `BeautyError.presetDecodeFailed(...)`.
- `BeautyConfiguration` defaults `enablePerformanceLog` to `false` and `logLevel` to `.error`; existing tests cover those defaults.
- `BeautyExampleRenderer` prints output paths as CLI evidence. Phase 25 should classify renderer CLI paths separately from active SDK/Demo logging surfaces if path tokens appear in scans.

### Established Patterns
- Active SDK/Demo behavior is verified with narrow XCTest and scoped `rg` scans, while historical docs and test guard strings are classified rather than blindly rewritten.
- Current source, root docs, and `.planning` ledgers override stale `.planning/codebase/*` maps.
- Hardware/tooling blockers are acceptable only with exact command, environment, impact, next step, and rerun protocol.
- Quality scores increase only when code, tests, command output, or recorded manual checks support the change.
- Existing v1.4 phases use non-claim wording: evidence baseline, blocker, rerun protocol, no release-grade overclaim.

### Integration Points
- Phase 25 should add a dedicated evidence artifact under `.planning/phases/25-security-distribution-review-and-closeout/`, likely covering privacy manifest assessment, security scans, resource trust, blockers/deferred items, and final closeout traceability.
- If `PrivacyInfo.xcprivacy` is added, planner must update the relevant SDK or Demo project/resource configuration and include build/scan evidence that the file is present where intended.
- Phase 25 closeout must synchronize `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/PROJECT.md`, `QUALITY_SCORE.md`, `SECURITY.md`, and `PLANS.md` after evidence exists.
- Verification should include `swift test --package-path BeautySDK`, focused resource/security/redaction tests, active-surface scans, dependency/package-reference scans, and Demo build/test commands when the local toolchain allows.

</code_context>

<specifics>
## Specific Ideas

- Treat `PrivacyInfo.xcprivacy` as evidence-driven: assess first, add the smallest factual manifest if required-reason API or distribution risk exists.
- Use active-surface security leaks as hard failures, but classify test guard literals and documentation examples honestly.
- Keep resource trust focused on current bundled presets and metadata filters, while explicitly keeping real external resource packages disabled until future design.
- Make Phase 25 a traceability gate for v1.4, not a broad rewrite or release-candidate declaration.

</specifics>

<deferred>
## Deferred Ideas

- Full App Store privacy-detail review for a host app remains outside Phase 25 unless required by the SDK privacy manifest assessment.
- Full external resource manager, package download, cache, checksum/signature pipeline, and real LUT/makeup/model/sticker package implementation remain future work.
- Broad root-doc, `docs/`, or `.planning/codebase/*` historical cleanup remains deferred unless a specific Phase 25 evidence conflict blocks closeout.
- App Store submission approval, commercial packaging completion, broad-device coverage, market visual-quality acceptance, hardware parity, and release-grade naturalness remain unclaimed unless future evidence directly supports them.

</deferred>

---

*Phase: 25-Security, Distribution Review, and Closeout*
*Context gathered: 2026-07-03*
