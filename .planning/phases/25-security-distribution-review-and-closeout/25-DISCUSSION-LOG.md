# Phase 25: Security, Distribution Review, and Closeout - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-07-03
**Phase:** 25-Security, Distribution Review, and Closeout
**Areas discussed:** Privacy manifest disposition, Security scan boundary, Resource trust review, Closeout evidence sync

---

## Privacy Manifest Disposition

| Option | Description | Selected |
|--------|-------------|----------|
| Assess First | Evaluate actual SDK/Demo behavior and required-reason API usage before deciding whether to add or explicitly defer `PrivacyInfo.xcprivacy`. | Yes |
| Add Manifest | Add a privacy manifest by default even before assessment. | |
| Explicit Defer | Do not add the file; record defer rationale and future triggers. | |

**User's choice:** Assess First.
**Notes:** Follow-up choices locked a behavior plus required-reason API assessment, conservative manifest addition if required-reason API or distribution risk is found, and Phase 25 evidence plus root/planning sync.

---

## Security Scan Boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Active Surfaces + Known Risks | Hard-gate active SDK/Demo source and tests for no-network/no-upload, raw path/error, face geometry, raw JSON/diagnostics, third-party SDKs, and hidden product scope. | Yes |
| Docs + Source Broad Scan | Expand to root docs, historical docs, and `.planning` text. | |
| Changed Files Only | Scan only files modified by Phase 25. | |

**User's choice:** Active Surfaces + Known Risks.
**Notes:** Follow-up choices locked fail-active-leaks/classify-test-fixtures behavior, manifest plus source dependency scans, and narrow-fix or blocker-honest handling for failures.

---

## Resource Trust Review

| Option | Description | Selected |
|--------|-------------|----------|
| Current Bundled Resources + Future Boundaries | Review current presets, metadata filters, resource IDs, missing resources, and confirm future external packages remain disabled until designed. | Yes |
| Current Resources Only | Review only currently bundled presets and filters. | |
| Full External Resource Design | Design external package manifest/checksum/cache/download behavior now. | |

**User's choice:** Current Bundled Resources + Future Boundaries.
**Notes:** Follow-up choices locked tests plus scans plus doc sync, forbidden-until-designed external resources, and small evidence-backed quality score updates without scoring future external resources as complete.

---

## Closeout Evidence Sync

| Option | Description | Selected |
|--------|-------------|----------|
| Traceability Gate | Require `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` to agree with Phase 25 evidence and blockers. | Yes |
| Minimal Closeout | Update only `PLANS.md` and `.planning/STATE.md` unless other files change directly. | |
| Docs Sweep Broad | Use Phase 25 for a broad cleanup of root docs, `docs/`, and `.planning/codebase/*`. | |

**User's choice:** Traceability Gate.
**Notes:** Follow-up choices locked explicit blocker/deferred tables for unrun checks, full locally available verification, and conservative audit-ready/traceability-ready wording rather than release-readiness claims.

---

## the agent's Discretion

- Planner may choose exact Phase 25 evidence filenames and scan command shapes.
- Planner may choose the smallest valid `PrivacyInfo.xcprivacy` placement and content if assessment shows it is required.
- Planner may choose exact focused test filters and static scans, provided active leaks are hard failures and test/document examples are classified.

## Deferred Ideas

- Full host-app App Store privacy-detail review unless required by SDK manifest assessment.
- External resource manager/package implementation.
- Broad historical documentation or stale codebase-map cleanup.
- App Store, commercial distribution, all-device, market visual-quality, physical-device parity, or release-candidate claims without direct evidence.
