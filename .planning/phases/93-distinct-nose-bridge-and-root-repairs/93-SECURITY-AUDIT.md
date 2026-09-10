---
phase: 93-distinct-nose-bridge-and-root-repairs
audited: 2026-09-10
status: open_threats
asvs_level: 1
block_on: high
threats_total: 23
threat_declarations: 26
threats_closed: 22
threats_open: 1
threats_open_nonblocking: 0
accepted_risks_documented: 0
unregistered_flags: 0
summary_threat_flags_sections_present: 0
native_gates_rerun: false
implementation_modified: false
---

## OPEN_THREATS

**Phase:** 93 — Distinct Nose Bridge and Root Repairs
**Closed:** 22/23 | **Open:** 1/23
**ASVS Level:** 1 | **Block threshold:** high
**threats_open:** 1

The 22 declared code/evidence mitigations are present. T-93-SC has an acceptance-record gap: four plans declare `accept`, but the existing root SECURITY.md has no corresponding accepted-risk log entry. No implementation vulnerability or dependency change is established by that gap.

All five registers omit severity. The referenced auditor's missing-severity rule therefore treats the open threat as critical for gate accounting only; this is not an assessed critical supply-chain exploit. The repeated T-93-SC declarations in plans 02–05 represent one unique threat, not four separate blockers. There are no transfer dispositions.

### Scope and method

Read the requested auditor instructions, AGENTS.md, PLANS.md, all five PLAN threat models, all five summaries, root SECURITY.md, 93-REVIEW.md, attempt-2/timeout/regression reviews and dispositions, and 93-VERIFICATION.md. Applied the project spike-findings-beauty privacy guidance. Serena was unavailable; verification used scoped rg/source inspection and read-only hash/JSON reconciliation.

Only the existing Phase 93 planned threats were checked. No native build, test, renderer, gate, portrait, device, or full milestone validation was rerun. Native results below are existing recorded evidence, independently reconciled to current source and receipt identities. No implementation, test, gate, owner, ledger, CHECKS, historical artifact, or Git commit was modified. This phase SECURITY.md is the sole audit write required by the active auditor instructions; it does not create the missing risk acceptance or alter root SECURITY.md.

### Evidence identities and reconciliation

| Artifact | Current SHA-256 |
|---|---|
| Provider | bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45 |
| Adapter | cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9 |
| Final regression-closeout runner | 7ff1598beb9708ba1917e3f8f1d7ca995de2fdd98eaed2adcd1a1eeb0f784378 |
| 93-CHECKS.json | db249c9e963d4de82794f6abfe31a8a466c20f28447a028c82d951172f5e63c6 |
| 93-ATTEMPTS.md through event 59 | 089b0cd5b75bb068308a203558eaef847331d306f921141d43f1bb264fa335c5 |
| Root SECURITY.md | b45395db73b82a26aed8a054d8776dec3a55c63fca2961e9f2804fbca2bad515 |
| 93-VERIFICATION.md | 5f3ee5fdea90d3dabf8f88772e94cd7737dc8a55a6995d0f54c5ac72b3a1e89a |

Read-only reconciliation matched all 186 frozen authorities, the two fixture pins, 17 attempt-2 pins, 14 current CHECKS identity entries, 13 prior identity entries, all seven current owner hashes, and the preserved registration/RED/provider-RED bindings and amendment chain. Ledger hash chaining and immutable prefixes through 26, 40 and 55 matched. Exactly two begin events remain; no failure follows event 55 through inspected event 59. All CHECKS receipt objects equal their ledger objects.

| Existing receipt | Recorded result | Provenance |
|---|---|---|
| 47 — core revalidation | 36 discovered / 36 passed / 0 failed / 0 skipped | Pinned timeout-runner identity; five core receipts 42–46, repeated 48–52 |
| 53 — compatibility | 229 / 229 / 0 / 0 | Pinned timeout-runner identity |
| 54 — script checks | 8 / 8 / 0 / 0 commands | Pinned timeout-runner identity; cleanup count 6 |
| 56 — supplemental regression | 106 / 106 / 0 / 0 | Current regression-closeout identity |
| 59 — owners | 7 / 7 / 0 / 0 owner checks | Current regression-closeout identity; goal_verification passed |

Current authority is the final regression-closeout entrypoint. It delegates through reviewed, pinned recovery code, preserves the prior runner identity on receipts 47/53/54, and requires receipt 56 at its own current identity. Earlier entrypoints are historical/delegated evidence, not independently current acceptance authority.

Canonical pixel receipts 45/51 were reconciled against the frozen conjunction and sibling digests. Bridge has 611 changed target pixels, 29460 RGB, +383 Q8 source/neutral margins and minimum sibling margin 373; root has 1043, 43917, +24 Q16 and minimum sibling margin 24. Comparison counts are 6/5, repeat flags 1/1, and outside/protected/background/watermark maxima are all zero. Historical baseline passes, candidate-1 failure, timeout 39/rollback 40 and scope failure 55 retain their original classifications.

### Closed

All rows have disposition `mitigate`, status CLOSED and severity unspecified in the source plan. Paths are repository-relative; ledger references identify sequence numbers, not test counts.

| Threat ID | Category | Disposition | Implementation/evidence verified |
|---|---|---|---|
| T-93-01 | Spoofing/Tampering | mitigate | `BeautySDK/Tests/BeautyCoreTests/NoseRepairFixture.swift:30` builds the fixed source in memory; `NoseFixtureRegistrationTests.swift:94,177` calls real detector mapping and adapter registration against independent source anatomy. Adapter nose-group admission is at `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift:80,136`; root template at :1018. Frozen fixture/registration pins and receipts 43/49 match. |
| T-93-02 | Tampering/Repudiation | mitigate | `scripts/check-phase93-nose-repair.py:703,723` freezes RED and requires it before provider evaluation; :535 appends chained ledger events. `scripts/check-phase93-attempt2.py:115,143` pins failed history and admits only attempt 2. `scripts/check-phase93-timeout-recovery.py:155,175` restores only the two pinned production originals. Ledger begins are exactly [1,2]. |
| T-93-03 | Tampering/Denial of Service | mitigate | `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:138,275,305,376` checks finiteness, caps, support disks, reconstructed displacement and final whole-field budget. `BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift:178` asserts dense and mixed-field behavior; 22 provider methods passed at receipt 42/48. |
| T-93-04 | Information Disclosure | mitigate | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift:176,272,313` uses Boolean byte comparisons and redacted diagnostics. `scripts/check-phase93-nose-repair.py:158,646,1231` bounds memory-only child capture, validates fixed aggregate keys and exports sanitized failure fields. |
| T-93-05 | Elevation of Privilege | mitigate | `scripts/check-phase93-nose-repair.py:458,499` limits adapter/SPI/provider edits and enforces frozen SDK inventory; `scripts/check-phase93-attempt2.py:115` rejects a third begin. `scripts/check-phase93-regression-closeout.py:206` exposes only the bounded regression/authority/closeout dispatch. Current 186 pins, reviews and two-begin history match. |
| T-93-02-01 | Spoofing/Tampering | mitigate | `BeautySDK/Tests/BeautyCoreTests/NoseSemanticMetricTests.swift:263,278,290,335` implements all four required polarity/admission/mutation methods, including exact units, comparison sets, alias and protection rejection. The public caller at `BeautyEngineNoseRepairTests.swift:197` evaluates actual output; frozen metric/fixture hashes and 4/0/0 metric receipts 44/50 match. |
| T-93-02-02 | Repudiation | mitigate | `scripts/check-phase93-nose-repair.py:35,646,693,703` requires exact assertion identities, independently classifies protection failures, verifies baseline provider identity and freezes per-direction verdicts. RED retains two honest baseline_pass values and exact current oracle pins; historical failures 15/18 remain hash-bound under precise amendments. |
| T-93-02-03 | Information Disclosure | mitigate | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift:201,272,280,313` restricts export to fixed aggregates/hashes, keeps RGBA in memory and uses Boolean equality. `scripts/check-phase93-nose-repair.py:158,646` and `scripts/check-phase93-regression-closeout.py:138` sanitize child capture and exceptional exits. |
| T-93-02-04 | Denial of Service | mitigate | `BeautySDK/Tests/BeautyCoreTests/NoseSemanticMetricTests.swift:14,110,133,162,184` checks byte/dimension ceilings, Int64 overflow and denominators. `scripts/check-phase93-nose-repair.py:158,579` applies an 8 MiB shared capture cap and 60-second per-method deadline; reviewed class exception is separately bounded. |
| T-93-03-01 | Tampering/Denial of Service | mitigate | `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:333,367,376` validates rounded allocation, actual Float sign/magnitude/cutoff and final 0.45 budget. `BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift:96,124,178,212` checks actual hypot budgets, 2/4/16/64 traces, dense/mixed maps and boundary/cutoff cases; current provider receipts pass. |
| T-93-03-02 | Spoofing | mitigate | `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift:18,79,88,143` keeps root ownership explicit and sanitizes only non-emitting fields. `BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift:67` checks missing/malformed pairs, no substitution and surviving tip work; public missing-support source identity at `BeautyEngineNoseRepairTests.swift:84`. |
| T-93-03-03 | Repudiation/Tampering | mitigate | `scripts/check-phase93-attempt2.py:24,68,115,143` binds D-10 authorization/review, immutable RED/history and the second candidate. `scripts/check-phase93-regression-closeout.py:35,53,119,138` admits only the pinned historical scope failure and latches new failures. Prefixes 26/40/55 and begin/finish history reconcile. |
| T-93-03-04 | Information Disclosure | mitigate | `scripts/check-phase93-nose-repair.py:753` limits original rollback paths to adapter/provider and verifies pinned blobs. `scripts/check-phase93-timeout-recovery.py:100,137,145,155,175` stages atomic owned replacement, rejects unowned partial states and records only status/count/hash metadata. Historical rollback receipts 26/40 remain exact. |
| T-93-03-05 | Elevation of Privilege | mitigate | `scripts/check-phase93-nose-repair.py:458,499,743` restricts private helper changes, verifies authorities and compares every legacy sibling output digest with RED. Current closeout :53/:85 delegates those scope/binding checks. All immutable source/test pins and sibling hashes match. |
| T-93-04-01 | Spoofing/Repudiation | mitigate | `scripts/check-phase93-regression-closeout.py:35,53,75,85,92` validates history, prior receipt identity/digests, current regression receipt and transparent CHECKS provenance. `scripts/check-phase93-nose-repair.py:889,917` requires exact candidate review hashes. Receipts 47/53/54/56/59 reconcile to current source and reviews. |
| T-93-04-02 | Tampering | mitigate | `scripts/check-phase93-nose-repair.py:458,499,872` enforces source allowlists, immutable SDK/package/renderer/backend/shader hashes and exact inventory preflight. All 186 frozen files match; current 229 compatibility and eight script-command receipts retain the 62/5/75 surface and sibling contract. |
| T-93-04-03 | Information Disclosure | mitigate | `scripts/check-phase93-nose-repair.py:158,646,872` uses bounded memory capture, fixed aggregate parsing and cleanup probes; `scripts/check-phase93-timeout-recovery.py:181` scopes temporary child resources and verifies removal. Receipt 54 reports cleanup 6; owner receipt 59 comes from the boundary/cleanup-checking owners path :930. |
| T-93-04-04 | Elevation of Privilege | mitigate | `scripts/check-phase93-nose-repair.py:917` requires independent review before closeout; `scripts/check-phase93-regression-closeout.py:53,106` additionally validates the exact independent regression review and excludes precisely two portrait methods. Current code and goal reports pass at the verified hashes; Phase 95 remains separate in owner sections. |
| T-93-04-05 | Denial of Service | mitigate | `scripts/check-phase93-nose-repair.py:158,579,872` supplies bounded captures/deadlines; `scripts/check-phase93-timeout-recovery.py:22,181` supplies the reviewed 1839-second class envelope and owned cleanup. `scripts/check-phase93-regression-closeout.py:119,138` adds the 600-second regression envelope, rejects re-execution and records wait timeouts without raw error text. |
| T-93-05-01 | Spoofing/Repudiation | mitigate | `scripts/check-phase93-nose-repair.py:898,917,938` binds owners to accepted evidence, code review and the separate goal verdict. Current closeout :92 retains prior receipt provenance. All seven owner hashes equal receipt 59 and their Phase 93 numerical claims match pixel receipts 45/51 and core/compatibility/regression counts. |
| T-93-05-02 | Information Disclosure | mitigate | `scripts/check-phase93-nose-repair.py:898,912,941` rejects raw geometry array patterns and exports owner hashes/status only. Inspected Phase 93 sections in DESIGN:1585, PRODUCT_SENSE:476, RELIABILITY:669, SECURITY:591, QUALITY_SCORE:614, taxonomy:241 and PLANS:35 contain contracts and fixed aggregates rather than request payloads. Source arithmetic formulas are implementation contracts, not captured biometric tuples. |
| T-93-05-03 | Elevation of Privilege | mitigate | `scripts/check-phase93-nose-repair.py:458,917,938` limits D-09 scope and checks separate code/goal verdicts; final regression-closeout :53 validates independent infrastructure review. Exact current candidate/review bindings, two attempts and owner receipt 59 support bounded owner-local completion; Phase 95/device/distribution claims remain excluded. |

### Open

| Threat ID | Category | Disposition | Severity / blocking rule | Expected evidence | Files searched |
|---|---|---|---|---|---|
| T-93-SC | Tampering | accept | Unspecified; critical only for fail-closed gate accounting. BLOCKER. | An explicit accepted-risk log entry for the existing no-dependency-installation/service/account-change disposition, with bounded Phase 93 rationale. | Root `SECURITY.md` (all 625 lines; no T-93-SC or accepted-risk-log entry); `93-02-PLAN.md:103`, `93-03-PLAN.md:109`, `93-04-PLAN.md:89`, `93-05-PLAN.md:98`. |

The root default restrictions on external packages and the unchanged Package.swift support the factual no-new-dependency boundary. They do not fulfill the declared `accept` verification method, which requires a recorded acceptance in SECURITY.md. This audit records the gap without inventing acceptance or changing the plan's disposition.

**Open non-blocking threats:** none.

### Unregistered Flags

No unmapped attack surface was identified within the inspected planned changes. All five summaries omit a `## Threat Flags` section; their absence is recorded explicitly and is not proof that a flag inventory was supplied. Their privacy/scope/deviation sections were read.

The implementation's reviewed recovery entrypoints map to existing ledger/admission/rollback/child-timeout threats: T-93-02, T-93-03-03/04, T-93-04-01/03/05 and T-93-05-01. No broad scan or unrelated threat registration was performed.

### Accepted Risks Log

No verified pre-existing SECURITY.md acceptance entry was found for T-93-SC. This section does not accept that risk; it remains OPEN pending the owner/orchestrator's explicit record of the already planned disposition.

Next: record the existing T-93-SC accepted-risk disposition in SECURITY.md, preserving hash-bound owner evidence through the owning workflow, then re-run the bounded security audit. No SDK implementation change is indicated by this finding.

This verdict is limited to owner-local SDK source and generated evidence. It does not grant UI, portrait, physical-device, commercial, release, or external-distribution qualification.
