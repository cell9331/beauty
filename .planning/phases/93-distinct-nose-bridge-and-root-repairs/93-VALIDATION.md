---
phase: "93"
slug: "distinct-nose-bridge-and-root-repairs"
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-09-09"
updated: "2026-09-10"
planning_disposition: independently_checked_plan_set
registration_status: executed_passed
semantic_status: executed_passed
provider_status: executed_passed
compatibility_status: executed_passed
owner_status: executed_passed
independent_goal_verification: passed
plan_count: 5
task_count: 11
tasks_covered: 11
implementation_attempts_consumed: 2
coverage_gaps: 0
---

# Phase 93 — Validation Audit

Current disposition: **validated; 11/11 tasks covered; no gaps**. This documentation-only Nyquist post-hook audits the five PLAN/SUMMARY pairs against recorded execution and independent verification. It creates no tests, performs no native reruns and does not commit. The historical source-only checkpoint below is preserved verbatim and supplies no current execution credit.

## Test infrastructure and authoritative evidence

XCTest runs through SwiftPM (`BeautySDK/Package.swift`); SDK-owned Python/shell gates enforce exact discovery, nonzero denominators, zero failures/skips, immutable authorities and aggregate-only receipts. The current final entrypoint is `python3 scripts/check-phase93-regression-closeout.py`, SHA-256 `7ff1598beb9708ba1917e3f8f1d7ca995de2fdd98eaed2adcd1a1eeb0f784378`. Its reviewed delegation chain retains the timeout-recovery and attempt2 wrappers and the original frozen nose gate; original gate and frozen bindings remain unchanged. Historical commands in PLAN files describe their execution stage, not an instruction to restart an earlier entrypoint or refreeze evidence.

The accepted provider is `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`; adapter is `cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9`. `93-CHECKS.json` directly retains receipts 53/54/56/57/58/59 and identity provenance. Core 47 is in `93-ATTEMPTS.md`, pinned through `93-REGRESSION-DISPOSITION.md`; CHECKS plus ledger/disposition preserve the full chain. Receipt numbers below are ledger sequence numbers.

| Evidence | Executed result | Authority |
|---|---|---|
| Core conjunction | 36 passed / 0 failed / 0 skipped: provider 22, registration 4, metrics 4, pixels 2, lifecycle 4 | 42–47; focused repeat 48–52 |
| Compatibility | 229 passed / 0 failed / 0 skipped | 53 |
| Script commands | 8 passed / 0 failed / 0 skipped | 54 |
| Supplemental deterministic regression | 106 passed / 0 failed / 0 skipped | 56 |
| Design owners | 3 passed / 0 failed / 0 skipped | 57 |
| Seven owners | 7 passed / 0 failed / 0 skipped; repeated after goal verification | 58, then 59 |
| Independent code review | Passed, no actionable blockers | `93-REVIEW.md`, review commit `ee6d55f9` |
| Independent goal verification | 18/18 must-haves; NOSE-01/02 and D-01–D-10 verified; no gaps | `93-VERIFICATION.md`; evidence/source audit, not a native rerun |

Counts describe their own receipts, not a sum of disjoint tests. The eight script commands cover comparator self-test (576 mutations; 5/65/8), cleanup/boundary self-tests (cleanup 6), runner syntax, preflight (75/65/8), backend-neutral checks (24 focused + 41 CPU), archive verification, SDK-only boundary and diff hygiene.

## Per-task verification map

Every task covers NOSE-01 and NOSE-02. All five plans have executed summaries; historical pending statements are interpreted at their recorded checkpoint, with current completion established by the later receipts and independent verdict.

| Task | Wave | Automated coverage and evidence | State |
|---|---:|---|---|
| 93-01-01 | 1 | Gate self-tests and independent generated `NoseRepairFixture.swift`/Testing SPI; initial 50 and reviewed amended 69 self-tests passed; source admission exercised by registration | COVERED — executed |
| 93-01-02 | 1 | `NoseFixtureRegistrationTests` plus existing adapter regression: expected old-root RED 7; corrected GREEN 9/10; current 43/49 each 4/4 | COVERED — executed |
| 93-01-03 | 1 | Freeze-registration receipt 11 and immutable `93-REGISTRATION.json`; current authority/identity checks retain binding | COVERED — executed |
| 93-02-01 | 2 | Four `NoseSemanticMetricTests` check independent integer arithmetic, admission, polarity and full comparison conjunction; 12 and current 44/50 passed | COVERED — executed |
| 93-02-02 | 2 | `BeautyEngineNoseRepairTests`: actual-pixel baseline 22 honestly records both baseline_pass; lifecycle 21; freeze 23 (`93-RED.json`); current pixels 45/51 and lifecycle 46/52 passed | COVERED — executed |
| 93-03-01 | 3 | 16 `NoseWarpProviderTests` + 6 `NoseRepairFieldTests`; expected baseline RED 24 (22 discovered, 17 passed, 5 failed), exact assertion binding in `93-PROVIDER-RED.json`; current 42/48 all 22 passed | COVERED — executed |
| 93-03-02 | 3 | Provider/registration/metrics/pixels/lifecycle and immutable-authority conjunction; exact candidate2 revalidation 47: 36/0/0 | COVERED — executed |
| 93-04-01 | 4 | Eleven compatibility classes and authorities: 53, 229/0/0; reviewed supplemental regression 56, 106/0/0 | COVERED — executed |
| 93-04-02 | 4 | Eight closeout script commands 54 and independent `93-REVIEW.md`; current identity provenance retained | COVERED — executed |
| 93-05-01 | 5 | Design owner closeout 57: 3/0/0 | COVERED — executed |
| 93-05-02 | 5 | Seven-owner closeout 58/59: 7/0/0; independent goal verification 18/18 | COVERED — executed |

## Requirement and safety coverage

NOSE-01 and NOSE-02 are covered by independent registration, literal checked integer metric tests, actual public-output pixels, lifecycle/fail-closed tests, the complete reconstructed Float field safety conjunction and compatibility. Provider tests retain exact caps, strength scaling, pair-atomic strict cutoff, complete-field budget, dense/combined fields and sibling isolation. Candidate2 uses conservative Double accumulation and inward Float target quantization with explicit reconstructed checks, retains the final 0.45 bound and R1 radii; no empirical margin sweep, third candidate or test relaxation supplies acceptance.

| Canonical public-pixel result | Bridge | Root |
|---|---:|---:|
| Changed pixels / RGB absolute delta | 611 / 29460 | 1043 / 43917 |
| Semantic margin | 383 Q8 | 24 Q16 |
| Minimum sibling margin | 373 Q8 | 24 Q16 |
| Frozen comparisons | 6 | 5 |
| Repeated deterministic comparison | 1 | 1 |

Outside/protected/background/watermark changed-pixel and RGB deltas are zero; retained sibling outputs match the frozen baseline. Canonical pixels cover both controls. The eight-orientation loop establishes **bridge raw/facade agreement only**, not root semantic behavior across all orientations. The adapter root anatomy bound is bounds-derived 0.30, not observed anatomy. Metadata/identity, malformed/missing inputs, recovery and reuse are covered by the public lifecycle and compatibility evidence; no device or broader visual-quality claim follows.

## Historical failures and recovery disposition

Two substantive implementation attempts remain consumed. Candidate1's failure and rollback (25/26) remain failed history. Candidate2's initial 36-pass acceptance (33) was revoked after compatibility timeout 39; that receipt establishes 67 passes + 1 timeout + 161 unexecuted out of 229, **zero established assertion failures**. The timed-out method was `BeautyCoreTests.BeautyExampleRendererProcessTests/testCompiledRendererBindsOnlyExactSuccessfulGazeAggregate`. Receipt 40 restores both production files to the admitted baseline. This is not negative arithmetic or pixel evidence.

Reviewed infrastructure-only recovery resumed the exact same candidate at 41 and produced current core 47 and compatibility 53; it did not create a third candidate. Scope error 55 remains a failed record for including deferred portrait opt-ins. Its reviewed scope correction produced deterministic 106/0/0 at 56, without modifying tests or rewriting the failure. `93-ATTEMPTS.md` and recovery/regression dispositions remain the detailed history authorities.

## Wave 0 and validation sign-off

- [x] Independent registration tests exist in `BeautySDK/Tests/BeautyCoreTests/NoseFixtureRegistrationTests.swift`; source/adapter registration passed before provider repair.
- [x] Metric and public-pixel/lifecycle tests exist, executed and are frozen with their source and authorities.
- [x] Exact test discovery and nonzero denominators are enforced; expected historical RED is distinct from current zero-failure acceptance.
- [x] All 11 tasks have automated coverage or executed prerequisite bindings; no three consecutive implementation tasks lack checks.
- [x] Frozen manifest, comparator, renderer, shared sampler, retained shader and numeric predicates remain unchanged.
- [x] Current compatibility, scripts, supplemental regression, owners and independent code/goal reviews passed.
- [x] Evidence remains aggregate-only; no raw pixels, geometry, masks, private paths or child transcripts are added here.

Sampling was executed in dependency order: registration → frozen metrics/pixel baseline → provider RED/repair → compatibility/scripts/review → owners/goal verification. Expected RED commands and freezes are completed historical steps, not rerun requests. Feedback latency is not claimed; reviewed cold-build/cache timeout handling is an infrastructure disposition, not relaxed result acceptance.

All in-scope acceptance is automated; no manual-only verification gap exists. Owner-local Phase 95 retains independent per-gate obligations for private portraits, final 65-output/full no-skip closeout and deferred precision residuals. FACE-01 semantic repair, UI/realtime/model/data, device qualification and external distribution remain outside Phase 93. These exclusions do not weaken either NOSE contract.

## Nyquist audit trail — 2026-09-10

| Audit measure | Result |
|---|---:|
| Plans / tasks audited | 5 / 11 |
| Tasks covered | 11 |
| Coverage gaps found / resolved / escalated | 0 / 0 / 0 |
| New tests / native reruns in this post-hook | 0 / 0 |

**Sign-off:** validated against current recorded evidence and independent 18/18 verification. The earlier independent plan check (`93-PLAN-CHECK.md`) resolved its two initial blockers with zero remaining issues; its 10/10 structural checks were planning evidence, superseded for execution status by the receipts above.

---

The following preserved checkpoint is historical only. Its zero-attempt, blocked and pending-authorization statements describe the pre-D-09 planning state and do not override the current validated disposition.

## Historical Planning Checkpoint — 2026-09-10 (preserved; scope disposition superseded by D-09)

本次仅复用既有 RESEARCH/PATTERNS 并作源代码约束分析；没有新增研究轮次、
SwiftPM 执行、渲染、像素 oracle、生产候选或测试修改。以下是前提分析，
不是已执行的 XCTest 结果、语义 RED、效果失败或 NOSE-01/02 完成证据。
现有草案中的推测任务编号和波次在此撤下，防止下游误认为执行已经获准。

### Aggregate findings

| Finding | Value |
|---------|-------|
| Existing research passes | 1 |
| New research passes | 0 |
| Canonical root supports | 2 |
| Canonical root centers registered in frozen root ROI | 0 |
| Canonical current root disks disjoint from frozen root ROI | true |
| Noncentral upper bridge supports | 2 |
| Root vertically bracketed by retained bridge supports | true |
| Common translation/positive scaling registers all retained supports | false |
| Retained-radius, disjoint-owner disk containment feasible | false |
| Exact-arithmetic containment contradiction exceeds 1024 binary32 epsilons | true |
| All possible provider-local alternatives disproved | false |
| Independently justified replacement registration established | false |
| Public-pixel RED executions / production attempts / render invocations | 0 / 0 / 0 |
| Executable plans / independently checked executable plan sets | 0 / 0 |

### Analytical scope and independent recheck

核对链为 canonical Testing SPI observation、既有 adapter 回归、
`BeautyFaceGeometryAdapter.makeBounds/point/nose/noseRoot`、
`NoseWarpProvider.bridgePoints/rootNarrowingPoints/makePoint` 和共享 CPU 采样器。
adapter 与 CPU 均使用向下增长的规范图像坐标；更换 EXIF、镜像或观察中的
鼻部原始坐标不会另行指定 adapter 的鼻部模板。

独立检查者可在内存中从上述源文件提取常数，以冻结 manifest 为区域 authority：
先按当前 upper-membership 和非中心条件选出 bridge 支撑，验证其与 root 的
纵向顺序；再将 root 支撑圆必须位于 root 区域的条件化为共同 face-height
上界，与最低 bridge 支撑圆进入 bridge 区域所需的间距比较。使用现有
`makePoint` 半径下限，即使只考虑最低的既有 bridge 支撑，该间距条件仍不成立。
本次用源常数的有理数算术检查这些必要条件，没有搜索夹具、候选或像素输出。
检查输出只允许布尔值、计数、状态和摘要；不要输出坐标或几何中间值。

上述不相容结论限于研究候选保留的支撑、X-only 位移、半径下限和完整支撑圆
归属条件。完整支撑圆归属是研究提出的保守充分条件，不等同于 D-03 的实际
像素容差；本记录不把它升级为新的用户门禁，也不声称全部 provider 方案或
冻结像素目标数学上不可能。当前缺少的是能独立证明、同时服务两个控制和完整
sibling 集合的共同配准。仅调整参数把支撑挪入评分区域，不能构成该证明。

### Required owner disposition

建议由 orchestrator 请求一个明确范围决定：是否允许将 Phase 93 从现有
provider 修复扩展为先修正内部 root 支撑定位契约，涉及
`BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`
的 `noseRoot(in:)`、
`BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift`
的对应 root 期望及独立配准测试，并同步实际受影响的 owner 契约。
该扩展必须先明确 source-side root 解剖归属依据；不能把任意新位置或重新
命名旧支撑当成已经获准。legacy nose、tip 和其他 sibling 行为仍须保持，
manifest、comparator、renderer、共享 sampler、shader、公共面和数值门禁仍冻结。

这项扩展尚未获准，也不保证随后像素验收成功。若所有者不批准扩展且没有新的
独立共同配准依据，应由所有者明确选择延期或停止；planner 不自行改变需求
状态，不只交付 NOSE-01 来掩盖 NOSE-02 缺口。当前 CHECKPOINT 同时保留两项需求。
阻塞来自任务明示的配准前提及 D-01/D-02/D-04/D-06，非 UI/drift advisory、
环境、真实设备、依赖安装或技能要求的额外审批。

### Source audit — retained, execution blocked

所有行的执行状态均为 `BLOCKED / plan NONE`，不标记 COVERED 或完成。

| Source | Item | Disposition |
|--------|------|-------------|
| GOAL | 独立 bridge definition、root narrowing 及三项 ROADMAP success criteria | 共同配准未获证明 |
| REQ | NOSE-01 | 保留；无执行计划、无完成信用 |
| REQ | NOSE-02 | 保留；配准前提阻塞 |
| RESEARCH | adapter/provenance、规范坐标与共同 source/neutral/siblings 配准 | 静态分析完成；授权处置待定 |
| RESEARCH | 实际 target-source scaling、独立 root pair、effective-work admission | 候选未执行 |
| RESEARCH | Float 重建、half/cap/cutoff、dense/combined field 安全 | 保留为后续计划义务；无测量信用 |
| RESEARCH | 独立整数 bridge/root metrics、metric admission/polarity、完整 frozen comparisons | 保留；未创建或执行 RED |
| RESEARCH | 元数据、保护纹理、neutral identity、确定性、失败隔离和恢复 | 保留；未验证 |
| RESEARCH | 不变量摘要、有限尝试、兼容、cleanup/boundary、owner 同步和独立审查 | 保留；不从历史结果推断当前成功 |
| CONTEXT | D-01 | 两项语义及完整比较集合均保留 |
| CONTEXT | D-02 | caps/fail-closed/独立支撑保留；不借用 tip/slim |
| CONTEXT | D-03 | 区域、门限与 manifest/comparator 不变 |
| CONTEXT | D-04 | 配准在实际像素 RED 和生产之前；当前在此前停止 |
| CONTEXT | D-05 | 完整有效场和重叠安全义务保留；无注入性宣称 |
| CONTEXT | D-06 | 无擅自扩展；内部支撑契约改变需所有者明确处置 |
| CONTEXT | D-07 | 既有研究计数保留；实现消耗 0/2；不新增研究或第三次尝试 |
| CONTEXT | D-08 | 独立代码审查和目标验证仍必需；只保存汇总，历史只读 |

Phase 95 portraits/final65-output/no-skip、设备、UI、模型/数据及其他明确
deferred 项不属于本阶段缺口。front-end=false；drift advisory 不构成此阻塞。

<threat_model>

## Trust Boundaries

| Boundary | Contract |
|----------|----------|
| observation → adapter → source raster | 未配准支撑不能成为语义证据 |
| field proposal → frozen oracle | 不可通过改变夹具、区域或门限制造成功 |
| request-local source analysis → durable evidence | 仅汇总计数、布尔值、状态与哈希 |
| planning disposition → executor | CHECKPOINT 不得被解释为可执行计划或新增预算 |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-93-01 | Spoofing / Tampering | registration and semantic admission | mitigate | 配准未解除即停止；0 计划；不得以另一解剖区域代替 root |
| T-93-02 | Tampering / Repudiation | source recipe and oracle authority | mitigate | 保留 frozen authority hashes；RED 必须在生产前冻结；无本次语义信用 |
| T-93-03 | Tampering / Denial of Service | provider effective and overlapping fields | mitigate | 在可执行计划中落实 finite/admission/dense tests 前不授权生产候选 |
| T-93-04 | Information Disclosure | analysis and evidence | mitigate | 原始 source/support/pixels 不复制到新增证据；仅汇总和摘要 |
| T-93-05 | Elevation of Privilege / Repudiation | execution scope and attempt budget | mitigate | 契约扩展必须明示；保留 0/2；不借用 Phase 92 重开授权 |

</threat_model>

### Source bindings (SHA-256)

| Source | Digest |
|--------|--------|
| BeautyFaceGeometryAdapter.swift | `7b3ca8d3dafad4068a49ee6fae963183601e59d10bb5eb40b0fdd8ee7f3e515d` |
| NoseWarpProvider.swift | `0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8` |
| BeautyGeometryEffectPipeline.swift | `1e66a90509b1b70d31707bb675d39b4a81145d96a9b8a58750f5b9231b78238a` |
| BeautyEngineTestingSupport.swift | `6b585542abb4266dbbcf330c8241fc49eb7ad40aff08fd3c2fc3194d5bbd058c` |
| FaceShapeWarpProviderTests.swift | `53999676dc011ce5acdc2915bff6ac4ce385da22ad000b1c94a89bb04021dc07` |
| face-feature-batch-manifest.json | `5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e` |
| compare-face-feature-batches.swift | `4d51f4727646ae88460ce5d17f9d661fa63a461da1dc6e15e58afa06803a9ffa` |

<!-- End preserved historical checkpoint. Current disposition is validated above. -->
