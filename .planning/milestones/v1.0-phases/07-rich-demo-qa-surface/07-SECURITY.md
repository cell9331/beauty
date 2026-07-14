---
phase: 07
slug: rich-demo-qa-surface
status: verified
threats_open: 0
asvs_level: 1
created: 2026-06-23T02:21:03Z
updated: 2026-06-23T02:21:03Z
register_authored_at_plan_time: true
---

# Phase 07 - Security

> Per-phase security contract for the Rich Demo QA Surface: threat register, accepted risks, and audit trail.

## Trust Boundaries

| Boundary | Description | Data Crossing |
| --- | --- | --- |
| Pasted JSON -> Demo parser | User-provided JSON is untrusted and must be size-limited, schema-checked, decoded, and facade-validated before preview/apply. | Parameter preference JSON |
| JSON preview -> current parameter store | Preview state must not mutate current parameters until explicit Apply. | Validated `BeautyParameters` candidate |
| Exported parameters -> clipboard/manual copy | Export must contain only parameter preference data and no image, detection, debug, path, source, timestamp, or build metadata. | Deterministic parameter JSON |
| Resource IDs -> facade validation | `filterId` is an identifier only; it must not be interpreted as a path, URL, or dynamic resource. | Filter identifier |
| SDK detection summary -> Demo debug overlay | Only public, geometry-free summary fields can reach UI. | Redacted detection summary |
| Processing failure -> user/debug copy | Failures must be redacted into stable codes and friendly copy. | Stable error code and status copy |
| Debug toggle -> preview state | Toggle must only affect overlay visibility and must not alter processing, compare, parameter, or detection state. | Visibility state |
| Future category copy -> product claims | Disabled copy must not imply v1 support for deferred domains. | Availability labels and reasons |
| Verification evidence -> requirement status | Requirements can be marked complete only after tests/scans pass. | Test and scan evidence |
| Debug/JSON implementation -> documentation | Docs must describe only implemented behavior and verified boundaries. | Root docs and planning ledger |
| Manual release risks -> product claims | Manual naturalness, hardware, real Vision, long-run, and production quality claims need proof before being upgraded from risk to evidence. | Release-risk statements |

## Threat Register

| Threat ID | Category | Component | Disposition | Mitigation | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| T-07-01-01 | Tampering | JSON import apply | mitigate | Decode to preview first; Apply is the only mutating action; failed imports keep current settings unchanged. | closed | `ParameterJSONCoding.previewImport`, `ParameterJSONSheetView` Apply gating, and focused Demo tests passed. |
| T-07-01-02 | Information Disclosure | JSON export and errors | mitigate | Export only `schemaVersion` and `parameters`; error copy avoids raw JSON, paths, framework strings, and debug metrics. | closed | `ParameterJSONCodingTests.testExportUsesOnlySchemaAndParametersTopLevelKeys` and raw-token source scans passed. |
| T-07-01-03 | Denial of Service | Pasted JSON size | mitigate | Reject payloads over 65,536 UTF-8 bytes before decoding. | closed | `ParameterJSONCoding.maximumPayloadBytes` and oversized-payload test passed. |
| T-07-01-04 | Spoofing/Tampering | Unknown filter IDs | mitigate | Validate through `BeautySDKResources.validate(parameters:)` and reject unavailable filters before preview/apply. | closed | `ParameterJSONCoding.previewImport` facade validation and unknown-filter test passed. |
| T-07-01-SC | Supply Chain | UI dependencies | accept | Native SwiftUI only; no registry, remote component, or package dependency was introduced. | closed | No new package or UI registry scope in Phase 7 artifacts. |
| T-07-02-01 | Information Disclosure | Debug overlay | mitigate | Overlay state uses `BeautyDetectionSummary` and redacted codes only; tests and scans reject geometry/raw tokens. | closed | `PreviewDebugOverlayState`, `CompareStateTests`, and source-only debug/privacy scans passed. |
| T-07-02-02 | Tampering | Debug toggle | mitigate | Debug visibility changes preserve compare, parameters, category selection, and snapshots. | closed | `CompareStateTests.testD15DebugTogglePreservesEditorSelectionParametersAndCompareDisplay` passed. |
| T-07-02-03 | Information Disclosure | Recoverable error copy | mitigate | Map failures to `processing_paused` and `photo_decode_failed`; do not store raw `Error` or paths. | closed | `PreviewDebugOverlayState` redacted codes and privacy tests passed. |
| T-07-02-04 | Spoofing | Future category availability | mitigate | Deferred categories remain disabled and visible with explicit `Not in v1` reasons. | closed | `BeautyCategoryModels`, `BeautyCategoryModelTests`, and `BeautyDemoViewStateTests` passed. |
| T-07-02-SC | Supply Chain | UI dependencies | accept | Native SwiftUI only; no remote UI registry or third-party component was added. | closed | No dependency or registry changes in Phase 7. |
| T-07-03-01 | Repudiation | Traceability closeout | mitigate | Record exact commands and files in summaries, root docs, roadmap, requirements, and `PLANS.md`. | closed | `07-03-SUMMARY.md`, `07-VERIFICATION.md`, and `PLANS.md` contain command/file evidence. |
| T-07-03-02 | Information Disclosure | Final scans | mitigate | Static scans cover internal imports, geometry/raw framework/path/error tokens, raw JSON dumps, and network/file scope creep. | closed | Focused import and active-source privacy scans passed in this audit. |
| T-07-03-03 | Spoofing | Release readiness claims | mitigate | Docs and ledger keep unproven visual/hardware/long-run checks as explicit release risks. | closed | `PLANS.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `RELIABILITY.md` preserve manual release-risk language. |
| T-07-03-04 | Tampering | Requirements/roadmap status | mitigate | Update requirement status only after verification passes and summaries exist. | closed | `07-VERIFICATION.md` reports 5/5 must-haves verified; `phase-plan-index 7` reports all summaries present. |

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
| --- | --- | --- | --- | --- |
| AR-07-01-SC | T-07-01-SC | Parameter JSON UI used only native SwiftUI and added no external UI/runtime dependency, so the supply-chain risk is accepted as no new dependency surface. | Phase 7 plan threat model | 2026-06-23 |
| AR-07-02-SC | T-07-02-SC | Debug overlay and unavailable-state UI used only native SwiftUI and added no remote UI registry or third-party component. | Phase 7 plan threat model | 2026-06-23 |

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
| --- | --- | --- | --- | --- |
| 2026-06-23 | 14 | 14 | 0 | Codex secure-phase |

### Evidence

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/ParameterJSONCodingTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests -only-testing:BeautyDemoTests/BeautyCategoryModelTests` passed.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- Active source scan for network/upload/file-import/export/raw JSON/path/raw framework/debug leak tokens returned no matches.
- Active debug-overlay source scan for `CGPoint` and `CGRect` returned no matches; the broader source scan found only the existing non-debug `ImageInputModels.extent: CGRect` image helper.
- `git diff --check -- .planning/phases/07-rich-demo-qa-surface SECURITY.md PLANS.md` returned no output before this report was written.

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-06-23
