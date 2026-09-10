---
phase: "93"
slug: distinct-nose-bridge-and-root-repairs
status: verified
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
threats_total: 23
threats_closed: 23
threats_open: 0
threats_open_nonblocking: 0
accepted_risks_documented: 1
created: "2026-09-10"
native_gates_rerun: false
---

# Phase 93 — Security

All 23 unique planned threats are closed: 22 implementation/evidence mitigations verified by the independent auditor, plus the existing T-93-SC acceptance recorded below. The initial audit is preserved in `93-SECURITY-AUDIT.md`; its one open documentation gap is superseded by this record. No implementation mitigation gap was found.

## Trust boundaries

The audited boundaries are observation/adapter/source registration, proposed Float field/actual sampler admission, immutable oracle/attempt accounting, child process/resource cleanup, and request-local data/durable aggregate evidence. The scope remains the owner-local SDK and its generated validation inputs. No UI, private portrait, device qualification or external distribution claim is added.

## Verified mitigations


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

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale and bounded disposition | Recorded by | Date |
|---|---|---|---|---|
| AR-93-SC | T-93-SC | Carry forward the already-declared `accept` disposition in plans 02–05: Phase 93 proposes no package installation, dependency, external service or account change. Existing package/inventory authorities remain unchanged and were verified by the auditor. This records the existing authorized execution boundary; it does not approve new dependencies or accept an identified vulnerability. | Orchestrator, implementing the approved Phase 93 plans | 2026-09-10 |

T-93-SC (Tampering, package/dependency/service changes) is CLOSED by this explicit phase SECURITY.md record. Source plans omit severity; no severity is invented. The initial auditor's conservative critical gate accounting applied only while this acceptance record was absent, not to an established critical vulnerability.

## Audit trail

| Audit | Checked | Closed | Open | Evidence |
|---|---|---|---|---|
| Initial independent audit | 23 | 22 | 1 | `93-SECURITY-AUDIT.md`; no implementation gaps, acceptance record missing |
| Acceptance documentation | 23 | 23 | 0 | Existing plan disposition recorded as AR-93-SC above; unchanged implementation and owner evidence through receipt 59 |
| Independent bounded follow-up | 23 | 23 | 0 | Security auditor read AR-93-SC and the four original PLAN acceptance rows, confirmed SECURED; prior 22 mitigations carried forward, no file writes or native reruns |

The initial report reconciles all 186 frozen authorities, both candidate source hashes, chained history through event 59, native receipts 47/53/54/56 and seven owner hashes. No native rerun is claimed here. Summary files have no dedicated Threat Flags headings; their scope/privacy/deviation sections were audited and no unmapped flag was identified within scope.

## Sign-off

- [x] All planned threats have a verified mitigation or documented existing acceptance.
- [x] Existing acceptance is recorded with its bounded rationale.
- [x] No open threats remain.
- [x] No production, test, immutable authority or owner evidence was changed by this audit.

Status: verified, 2026-09-10. This is an owner-local phase audit, not release or distribution approval.
