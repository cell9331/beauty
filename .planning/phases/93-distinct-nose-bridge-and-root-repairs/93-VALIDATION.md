---
phase: "93"
slug: "distinct-nose-bridge-and-root-repairs"
status: draft
nyquist_compliant: true
wave_0_complete: false
created: "2026-09-09"
updated: "2026-09-10"
planning_disposition: independently_checked_plan_set
registration_status: planned_not_executed
plan_count: 5
implementation_attempts_consumed: 0
---

# Phase 93 — Validation Strategy

> Current disposition: D-09 explicitly authorizes the bounded adapter root-positioning correction. Five executable plans are authored for independent checking. No production changes or semantic acceptance are claimed. The historical checkpoint below remains source-only evidence; its pending-authorization/zero-plan wording is superseded by D-09 and the current strategy appended after it.

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

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest through SwiftPM |
| **Config file** | `BeautySDK/Package.swift` |
| **Execution readiness** | Blocked before test authoring and production planning |
| **Future suite owners** | Nose registration, public repair, provider, compatibility, comparator, boundary and SDK-only gates |
| **Estimated runtime** | Not measured; no latency promise |

## Sampling Rate

- **After every task commit:** Run the task's narrow discovered-test-count and focused XCTest command.
- **After every plan wave:** Run every focused suite introduced or modified in that wave.
- **Before goal verification:** Run the complete focused conjunction and immutable-authority checks.
- **Max feedback latency:** Unmeasured; split registration, provider and public-pixel filters to preserve fast diagnosis.

## Per-Task Verification Map

Not assigned. No PLAN.md exists and no execution wave is approved. The future
checked plan must assign exact paths, discovered test methods, dependencies,
commands and an adjacent `fails_when` for every `automated` command after an
authorized registration disposition. The following obligations remain pending;
they are not tasks to execute from this checkpoint.

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyEffectsTests/NoseFixtureRegistrationTests.swift` — common source/observation/adapter registration; stop production planning if unresolved.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift` — exact bridge/root metrics, lifecycle and immutable public-pixel RED.
- [ ] Discover each required new test exactly once before relying on its result; zero discovered tests is failure.
- [ ] Pin relevant source recipe, observation, metric-helper, provider and frozen authority blobs before the first production edit.

## Manual-Only Verifications

All Phase 93 acceptance behavior is automated. Physical-device and portrait evaluation are optional or owned by Phase 95 and do not gate this phase.

## Phase Gates — suspended pending owner disposition

After the prerequisite is resolved, the single independently checked plan set
must order: registration GREEN → independent metrics and immutable actual-pixel
RED → bounded production candidates → focused provider/pixel/compatibility and
frozen-authority/cleanup/backend/archive/SDK-only gates → independent code review
and goal verification. Do not invoke missing tests as if they existed. At most
two substantive implementation attempts are shared by both requirements and
all plans; candidate failure cannot reset the budget. The second failed attempt
requires verified restoration of the approved baseline and an explicit owner
repair/defer/stop decision. No third candidate or threshold relaxation is authorized.

The registration test must pass before any edit to `NoseWarpProvider.swift`. A registration failure is a prerequisite finding, does not earn semantic credit, and does not consume either authorized implementation attempt. New and focused nose tests require a nonzero denominator, zero failures and zero skips. Existing opt-in portrait skips remain outside Phase 93 acceptance. Full 65-output and no-skip closeout remain Phase 95.

## Validation Sign-Off

- [ ] All tasks have an automated verification or a Wave 0 dependency.
- [ ] Registration precedes RED; RED precedes production mutation.
- [ ] No three consecutive implementation tasks lack an automated check.
- [ ] Every new test is discovered exactly once and cannot silently select zero tests.
- [ ] Frozen manifest, comparator, renderer, shared sampler and retained shader remain unchanged.
- [ ] Aggregate-only evidence contains no raw pixels, geometry, masks, private paths or transcripts.
- [ ] `nyquist_compliant: true` is set only after independent validation audit.

**Approval:** CHECKPOINT — awaiting explicit owner registration disposition.
No executable plan set has been independently checked; no phase approval or
new research/implementation budget is implied by this document.

## Current recovery strategy — D-09 approved, plan check pending

This section is the current execution strategy. Earlier checkpoint text is
preserved verbatim apart from its historical heading/banner and does not impose
a new scope approval. D-09 already authorizes the adapter's internal root
positioning correction, its regression/independent registration tests and
affected owner synchronization. This authorization supplies no pixel efficacy
and does not reset attempts. Existing RESEARCH and PATTERNS are reused; no new
research pass was performed.

The planner owns only 93-*-PLAN.md and this validation file. It does not change
production, tests, owner documents, roadmap, state or configuration, and does
not commit. The PLAN files describe future executor ownership.

### Evidence categories and present baseline

| Category | Current evidence | Credit |
|---|---|---|
| Historical source analysis | Earlier checkpoint's aggregate registration findings and source hashes | Source-only; no XCTest, render, pixel RED or impossibility claim |
| Current provider baseline | Orchestrator reports on 2026-09-10: `swift test --package-path BeautySDK --filter NoseWarpProviderTests`, exit 0, 16 tests, 0 failures, 0 skips; no production modifications | Existing provider regression baseline only; not NOSE semantic acceptance |
| D-09 | Explicit owner authorization recorded in CONTEXT and active PLANS | Bounded root-positioning scope approval only |
| Registration and public pixels | Planned; not executed by this planner | None |
| Research passes | Existing 1, new 0 | Existing research reused |
| Implementation attempts | 0 consumed / 2 maximum, shared across both controls and every plan | No new implementation during planning |
| Independent plan/code/goal review | Pending | Plans authored, not independently approved |

### Source-side correction and bounded uncertainty

Source inspection confirms that the current bounds-derived root lies below the
adapter's coarse eye band and between retained bridge samples. Plan 93-01
specifies one fixed internal upper-root positioning correction with its
source-side anatomical order and unchanged root pair ownership. Its generated
input is authored and frozen before rendering, with a single independent
observation shared by both controls and every sibling. The canonical fixture
remains unchanged as a historical control. No ROI center is used as a runtime
support source, and no output-guided anatomy/fixture search is authorized.

The new registration test must prove source anatomy, actual detector/coordinate
mapping, corrected adapter supports and predeclared source/cap-target support
envelopes before pixel scoring. Registration and the independent metric oracle
both use checked edgePPM*axisExtent / 1_000_000 for every raster edge: floor
for all four nonnegative edges, with exclusive maxima. The existing source
registration and metric-admission methods include the same literal nonintegral-
edge bounds/membership regression; metric admission also asserts exact integer
thirds and half partitions. Frozen source, manifest, comparator and thresholds
remain unchanged. Geometry stays in executable source/tests, not
this evidence document. Those envelope checks are a conservative sufficient
fixture check, not a replacement for the frozen pixel tolerances or a new
general public eligibility rule. A failed envelope produces a precise
prerequisite stop; it is not proof that the pixel goal is impossible.

The exact corrected adapter is the first production edit and starts shared
attempt 1. Only after registration GREEN does 93-02 establish the actual-pixel
RED/baseline_pass table against the original provider. That table, source,
observation, metrics and thresholds are immutable before effect tuning. A
baseline direction already passing is preserved honestly, never weakened to
manufacture RED. Unknown pixel effectiveness is resolved by the finite oracle
run; no further research or prolonged feasibility search is required.

### Waves, task dependencies and context bounds

| Wave | Plan | Tasks | Needs → creates | Approximate context |
|---|---|---:|---|---|
| 1 | 93-01 | 3 | D-09/current source → fixed fixture/gate, adapter correction, independent registration binding | 45–50% |
| 2 | 93-02 | 2 | GREEN registration → literal metrics, public pixels/lifecycle, immutable RED binding | 40–45% |
| 3 | 93-03 | 2 | Frozen RED → provider regression RED, bounded private repair and shared attempt outcome | 45–50% |
| 4 | 93-04 | 2 | Accepted candidate → current compatibility/cleanup receipts and independent code review | 25–35% |
| 5 | 93-05 | 2 | Accepted current receipts/review → measured owner synchronization and goal-verification handoff | 25–35% |

All tasks are autonomous; no repeated user scope approval is planned. Independent
review is an orchestrator/reviewer dependency, not a human UI checkpoint.
Registration/RED/attempt evidence and shared source ownership require sequential
waves. Every plan has nonempty NOSE requirement coverage; no same-wave file
overlap exists. Within each task, no more than five modified files are assigned.

### Exact automated verification map

Every gate command is implemented in 93-01 before use. Missing tests/artifacts
return `gate_not_ready` and nonzero exit, never success. First compile uses
`swift build --package-path BeautySDK --build-tests` (600-second ceiling), then
`swift test --package-path BeautySDK list` checks exact fully qualified unique
method discovery. After any Swift edit, rebuild before using
`swift test --package-path BeautySDK --skip-build --filter '<anchored escaped module.class/method>'`.
Method execution has a 60-second ceiling; first compilation is not promised
under that ceiling. No permanent raw child transcript is written.

| Task | Command(s) | fails_when |
|---|---|---|
| 93-01-01 | `python3 scripts/check-phase93-nose-repair.py self-test` | Any accepted parser/path/hash/budget mutation, zero denominator, nonzero exit |
| 93-01-02 | `python3 scripts/check-phase93-nose-repair.py registration --expect old-root-red`, then after admitted attempt-1 correction `python3 scripts/check-phase93-nose-repair.py registration --expect green` | Old RED includes anything except named root placement failure; GREEN is not exactly three new methods plus existing adapter regression passing, or any skip |
| 93-01-03 | `python3 scripts/check-phase93-nose-repair.py freeze-registration` | Non-GREEN registration, missing attempt-1 start, wrong/unsafe/stale binding |
| 93-02-01 | `python3 scripts/check-phase93-nose-repair.py metrics` | Any of four metric/admission/polarity/conjunction methods missing, failing or skipped; nonintegral-edge floor/floor bounds, exclusive membership or thirds/half partition mismatch |
| 93-02-02 | `python3 scripts/check-phase93-nose-repair.py red` then `python3 scripts/check-phase93-nose-repair.py freeze-red` | Registration/metrics/lifecycle failure, unexpected semantic-method assertion, missing comparison, provider drift or mutable RED |
| 93-03-01 | `python3 scripts/check-phase93-nose-repair.py provider --expect baseline-red` | 22 methods not uniquely discovered, missing/duplicate centered-bridge RED ID, zero named new regression failures, unexpected failure/skip, or frozen gate/pixel/registration drift |
| 93-03-02 | `python3 scripts/check-phase93-nose-repair.py provider`, `registration --expect green`, `metrics`, `pixels`, `lifecycle`, `authorities` (same script prefix, ordered conjunction) | Any gate fails, a frozen predicate/sibling digest changes, unexpected skip, or attempt ceiling exceeded |
| 93-04-01 | `python3 scripts/check-phase93-nose-repair.py compatibility` then `python3 scripts/check-phase93-nose-repair.py authorities` | Stale accepted identity, missing/duplicate/failed/skipped class/method or unplanned source/resource addition/change/deletion |
| 93-04-02 | `python3 scripts/check-phase93-nose-repair.py closeout --stage checks` | Comparator/preflight/cleanup/backend/archive/boundary failure, residue or missing/noncurrent independent review |
| 93-05-01 | `python3 scripts/check-phase93-nose-repair.py closeout --stage design` | Owner contract diverges from measured/current evidence or lacks scope limits |
| 93-05-02 | `python3 scripts/check-phase93-nose-repair.py closeout --stage owners` | Owner/history/taxonomy drift, raw data, boundary/cleanup failure or false independent-verification claim |

`pixels` runs the two semantic methods; `lifecycle` runs the four remaining
public methods. The focused inventory is 22 provider + 4 registration/regression
+ 4 metrics + 6 public = 36 unique methods, all zero-failure/zero-skip for
acceptance. Expected RED is classified by exact fixed assertion IDs and method
exit/result agreement, never generic exit 1. Before its initial hash freezes,
93-01-01 predeclares P93_CENTERED_BRIDGE_EMPTY,
P93_CENTERED_BRIDGE_TOTAL_FOUR and P93_CENTERED_BRIDGE_SANITIZED_ZERO, scoped
only to NoseWarpProviderTests/testLegacyFieldEmissionsUseEachHelpersActualPrerequisites.
93-03-01 updates exactly those three dependent expectations to bridge empty,
total count 4 and sanitized bridge strength 0, preserving every sibling
assertion. Baseline RED requires all three IDs separately plus the named new
regression failures; no whole-method whitelist or later gate edit is permitted.
After provider repair, all three assertions and all 22 provider methods must
pass without failure or skip. Runtime discovery counts are
verified against the planned inventory rather than assumed from the baseline.

`closeout --stage checks` executes the exact existing commands listed in
93-04: comparator self-test (576 mutations; 5/65/8), boundary/cleanup self-tests
(including cleanup 6), runner syntax, preflight-only (75/65/8), backend-neutral
(24 + 41), archive verification, post-archive SDK-only boundary and diff hygiene.
No portrait run or full no-skip wrapper is part of this phase. Script children
have finite timeouts/capture bounds, current receipts and sanitized output;
routine compile cost is distinct from method execution.

### Shared attempt and rollback boundary

- One existing research pass, one independently checked plan set, at most two
  substantive joint implementation attempts. Attempt 1 starts at the fixed
  adapter change, not separately for each provider. Test-only/source-only
  failures before that edit consume none.
- Both candidate radius choices and the same complete-field safety budget are
  predeclared in 93-01/93-03 before pixels. Attempt 2 is available only under the
  specified semantic-signal failure branch while all safety/protection/
  registration/infrastructure checks pass. No adaptive coefficient, fixture,
  support-position, threshold or sibling search occurs.
- A candidate passes only if both full semantic contracts and all applicable
  protections/safety/metadata/compatibility checks pass at the same hashes.
  A failed first candidate is preserved as failed even if the second passes.
- No third candidate follows code review or goal verification. A new substantive
  production correction counts against the same shared limit. At a terminal
  failure, restore only owned production bytes from admitted baseline blobs,
  keep new regression/RED tests and failed evidence, verify rollback and stop for
  explicit owner repair/defer/stop. Existing dirty state/config/owners and other
  threads' work are never reset. Restored source may intentionally fail the new
  root/scaling/effect regressions; that is recorded as retained RED, not a failed
  baseline suite silently changed to pass.
- Fixed source-only findings and current 16/0/0 baseline are separate records.
  No result from this recovery planning is claimed as a SwiftPM or pixel run.

### Multi-source coverage audit — all items planned, none claimed complete

| Source | Item | Plan/task coverage | Status |
|---|---|---|---|
| GOAL | Independently applicable bridge definition and root narrowing in own regions; all three roadmap success criteria | 93-01 through 93-05 | COVERED |
| REQ | NOSE-01 full definition, non-alias and protection | 93-02-02, 93-03-02, 93-04-01 | COVERED |
| REQ | NOSE-02 full root contraction, cap/fail-closed and bridge/tip/non-nose protection | 93-01-02, 93-02-02, 93-03-02, 93-04-01 | COVERED |
| RESEARCH | Root placement mismatch, common source/anatomy/provenance and canonical control | 93-01-01/02/03, D-09 correction | COVERED |
| RESEARCH | Actual target-source scaling; independent root pair; no sibling borrowing | 93-03-01/02 | COVERED |
| RESEARCH | Final Float/radius-floor/renderer-cutoff admission; half/reused/cap/near-cutoff strengths | 93-03-01/02 | COVERED |
| RESEARCH | Whole-field derivative budget, dense and combined safety; restricted injectivity claim | 93-03-01/02, 93-04-01 | COVERED |
| RESEARCH | Exact floor/floor integer PPM with exclusive maxima, nonintegral-edge membership/partition regression, bridge-Q8/root-Q16, polarity/admission/mutations and all frozen comparisons | 93-01-02, 93-02-01/02 | COVERED |
| RESEARCH | Textured protected guards, source/neutral identity, extent/orientation/color/alpha, deterministic bytes | 93-01-01, 93-02-02 | COVERED |
| RESEARCH | Missing/malformed/provider-empty, reuse/freshness, valid-invalid-valid and field isolation | 93-02-02, 93-03-01, 93-04-01 | COVERED |
| RESEARCH | Build freshness, source/authority bindings, honest RED and bounded retry/rollback | 93-01, 93-02-02, 93-03 | COVERED |
| RESEARCH | Existing stack/target patterns, no installs/services/migrations/new geometry payload | All plans; existing Testing SPI only | COVERED |
| RESEARCH | Comparison self-test, preflight, cleanup, backend, archive, SDK-only and inventory compatibility | 93-04 | COVERED |
| RESEARCH | Security/privacy, measured owner synchronization and independent review/goal verification | All threat models, 93-04-02, 93-05 | COVERED |
| RESEARCH | A1 candidate effectiveness is LOW confidence, not proven passing or impossible | Frozen oracle and finite stop in 93-02/03 | COVERED |
| CONTEXT | D-01 distinct controls and complete frozen comparisons | 93-02, 93-03, 93-04 | COVERED |
| CONTEXT | D-02 exact caps, fail-closed, no proxy support | 93-01, 93-03 | COVERED |
| CONTEXT | D-03 immutable regions, numeric gates and authorities | 93-01, 93-02, 93-04 | COVERED |
| CONTEXT | D-04 independent registration and actual public pixels/metadata/recovery | 93-01, 93-02, 93-03 | COVERED |
| CONTEXT | D-05 renderer-effective/overlapping fields | 93-03, 93-04 | COVERED |
| CONTEXT | D-06 private seams, retained public/sibling/backend scope | All plans, especially 93-04 | COVERED |
| CONTEXT | D-07 one research/checked plan set, shared two attempts | 93-01, 93-03, 93-04 | COVERED |
| CONTEXT | D-08 reviews, measured owners, history/privacy | All plans, 93-04/05 review dependencies | COVERED |
| CONTEXT | D-09 approved adapter root correction and tests, unchanged other boundaries | 93-01-02, 93-03, 93-05 | COVERED |

Deferred Phase95 portraits/final65/no-skip/precision residuals, FACE-01 repair,
UI/realtime/model/data/device and external-distribution work are exclusions,
not gaps. Research's obsolete provider-only checkpoint is resolved by D-09;
its efficacy uncertainty remains a falsifiable execution question.

### Current threat disposition and sign-off

Each PLAN includes STRIDE trust boundaries with concrete mitigation tasks:
source/observation/adapter registration; actual Float field/sampler admission;
immutable oracle and shared attempt evidence; finite child/filesystem receipt
admission; aggregate-only privacy; independent review and claim scope.
No dependency install, new service, credentials, model, private portrait or
manual-only test is planned.

- [x] Every task has exact automated verification and adjacent fails_when.
- [x] Wave-0 equivalents are assigned to 93-01 and 93-02 before effect tuning.
- [x] Every locked decision and required source item maps to concrete tasks.
- [x] Shared attempts, terminal stops and preservation of local edits are explicit.
- [ ] Independent plan checker has approved the set.
- [ ] Registration/metrics and intended RED have executed and frozen.
- [ ] Both semantic directions and current compatibility gates have passed.
- [ ] Independent code review and goal verification have passed.

`nyquist_compliant` and `wave_0_complete` remain false until their respective
independent audit/execution evidence exists. Planning completion is not phase
completion. No genuinely unresolved product/scope decision remains; a precise
fail-closed registration or pixel check can handle the remaining technical
uncertainty within the authorized budget.

### Recovery planner structural checks

All five plans passed `frontmatter.validate --schema plan` and
`verify.plan-structure` through the local GSD CLI: 10/10 checks, zero errors,
zero warnings, 11 tasks across five sequential waves. `git diff --check`
passed. These are document-structure checks only; independent deterministic
probes and plan review remain pending. No production/test edit, new SwiftPM
execution, render, research pass or implementation attempt was performed by
this recovery planner. Only the five PLAN files and this validation file were
edited; existing local changes were preserved and no commit was created.

## Independent plan check — passed

2026-09-10: Two initial blockers (raster upper-edge rounding and the three dependent centered-bridge expectations) were corrected and independently rechecked with zero remaining issues. See 93-PLAN-CHECK.md. Structural sampling is compliant; runtime registration and semantic gates remain unexecuted.
