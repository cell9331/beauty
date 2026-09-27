# QUALITY_SCORE.md

## 2026-09-27 lower vertical generated-pixel acceptance

`philtrumLength` and `lowerFaceLength` independently move generated target
markers in both signed directions while the sibling marker, exterior and
alpha stay unchanged. Public neutral, no-face, repeat, four orientations,
input mirror, Codable and typed input-limit recovery tests pass `2/0/0`;
provider direction passes `1/0/0`, parameter inventory `50/0/0`, legacy
projection `4/0/0`, and renderer regression `24/0/0`. Full no-skip closeout
remains pending for the active plan. Taxonomy stays `partial`.

## 2026-09-27 forehead and midface generated marker acceptance

The independent `foreheadHeight` and `midfaceLength` public controls move
their respective generated markers in both signed directions while leaving
the other marker, a third protection marker, distant background and alpha
unchanged. Neutral, repeat, missing face, four orientations, input mirror,
Codable defaults and typed pixel-limit recovery pass `4/0/0`. Parameter,
resource, renderer, Metal geometry, face-provider and compatibility suites
pass; one old current-field-count assertion in the upper-eyelid integration
suite was corrected and its five tests pass `5/0/0`. The archive-first full
no-skip gate passes `1017/0/0`, eight opt-ins and zero skips. These inputs
support only bounded image-plane behavior; taxonomy remains `partial`.

## 2026-09-27 short-face generated marker acceptance

The independent public `faceShortening` control moves upper and lower
generated markers toward each other while preserving a central marker,
distant background, extent and alpha. Neutral, repeated output, missing face,
four orientations, input mirror, Codable normalization/defaults and typed
pixel-limit failure/recovery pass `3/0/0`. The face-shape provider checks
opposing bounded points and missing-contour exit; current parameter, renderer,
resource, compatibility, geometry and integration focused suites pass
`90/0/0`. The archive-first full no-skip gate passes `1012/0/0`, eight
opt-ins and zero skips. These generated-input results do not establish a
three-dimensional or broad portrait-quality effect; taxonomy remains
`partial`.

## 2026-09-27 texture negative and resource-budget probes

A generated portrait with a low-contrast cool background first failed the
public source-exact protection assertion with 132 changed background pixels
for each texture control. The guarded version passes on lighter and deeper
skin positives for smoothing and sharpening, with zero protected background
changes and alpha preserved. A lazy 2049×4096 texture input now fails typed
before rasterization, while a 2048×4096 backend request is admitted and a
later small public request recovers. A generated encoded PNG with declared
2049×4096 dimensions also fails typed before decode and a valid small encoded
request succeeds afterward. The generated texture suite passes `8/0/0`;
backend contract, encoded and texture focused suites pass `24/0/0`.
The guard does not prove all non-face colors are protected and no total memory
or device performance result is asserted. Complete archive-first no-skip
passes `1008/0/0`, all eight opt-ins and zero skips.

## 2026-09-27 dense geometry capacity evidence

An admitted 16-point paired-brow observation and 46 requested geometry controls
produce 288 points, above Metal's 256-point bound. A public GPU-selected
still-image request uses the capacity metric and renders exactly the same
generated pixels as the CPU reference without dropping the controls; a later
normal request has no fallback metric. Direct Metal still-image submission
continues to return typed `invalidInput`, as does the retained row-protection
case. Capacity, Metal geometry and backend routing focused suites pass
`20/0/0`; backend-neutral, Metal feature/runtime and SDK-only static gates and
their self-tests pass. Complete archive-first no-skip passes `1004/0/0`, all
eight opt-ins and zero skips.

## 2026-09-27 whole-face tilt generated marker probe

The public in-memory `128×128` marker test fixes positive clockwise and
negative counterclockwise movement at two differently colored sites. Neutral,
repeat, extent, alpha, distant-background, four orientations, input mirror,
missing-face and typed pixel-limit failure/recovery pass `3/0/0`. The
face-shape provider suite passes `21/0/0`; the current 47-control Metal
inventory and combined-point checks pass `7/0/0`. The public field's Codable
normalization and old-payload neutral default are covered. The larger
renderer and upper-eyelid integration filter passes `53/0/0` after current
inventory counts are updated. The complete archive-first no-skip gate passes
`1001/0/0`, with eight opt-ins and zero skips. Broader portrait visual evidence is still
required to promote the 3D taxonomy row beyond `partial`.

## 2026-09-26 diagnostic level focused evidence

Preimplementation public tests failed to compile because the closed event
type was absent. The completed `7/0/0` focused suite covers `.none` through
`.debug`, warning aggregation, debug gating, exact event order, repeated
requests, CIImage/encoded/pixel-buffer routes, pixel preservation, typed
failure/recovery, opt-in performance timing and result Sendable behavior.
Full archive-first no-skip passes `988/0/0`, eight opt-ins, zero skips.

## 2026-09-26 performance-result focused evidence

Two public tests cover disabled/enabled metrics on `CIImage`, in-memory encoded
PNG and `CVPixelBuffer` entries, compare actual output bytes, require finite
nonnegative duration, and check typed invalid-input recovery. The frozen
preimplementation tests failed four missing-metric assertions; implementation
passes `2/0/0`. The key was named for synchronous facade scope after the red
run because Core Image can evaluate pixels after return. Full archive-first
no-skip passes `986/0/0`, eight opt-ins, zero skips.

## 2026-09-26 whole-face horizontal generated marker probe

The public in-memory `128×128` opaque sRGB marker moves over one pixel right
and left at the signed cap. The four-direction and input-mirror metadata
matrix keeps the signed pair distinct, with exact exterior, extent and alpha.
Neutral, repeated, no-face and typed pixel-limit failure/recovery pass `4/0/0`.
The focused parameter, renderer, resource, provider and current Metal point
inventory suite passes `137/0/0`; post-archive SDK boundary passes. The full
archive-first no-skip gate passes `984/0/0`, eight opt-ins, zero skips.

## 2026-09-26 encoded byte-limit focused evidence

A generated in-memory `32×32` PNG at the exact configured byte limit produces
different brightness pixels with unchanged extent and alpha, and repeats
identically. One byte below its encoded size fails as typed `invalidInput`;
the same engine still accepts the decoded `CIImage` entry. Malformed/empty
data and a declared image above the configured pixel limit fail typed, then
the valid encoded image succeeds. The focused public suite passes `2/0/0`;
configuration plus entry tests pass `12/0/0`. The complete archive-first
no-skip gate passes `979/0/0`, eight opt-ins executed, zero skips.

## 2026-09-26 whole-face vertical generated marker probe

The new public still-image test uses an in-memory `128×128` opaque sRGB marker
and an existing synthetic selected-face detector. It asserts signed centroid
motion greater than one pixel in each direction, neutral identity, repeat,
far-background and alpha protection, extent and detection metadata, source-
exact missing-face behavior, and typed oversized-input recovery. Parameter
normalization/Codable compatibility and four orientation × two input-mirror
variants also pass in the four focused public tests (`4/0/0`). Face-shape
provider `19/0/0` and Metal geometry `7/0/0` cover signed emission and the
45-row bounded combination on the two existing generated/observed supports.
Archive-first boundary passes. The first complete no-skip run found nine old
current-inventory assertions (62 fields/75 cases); focused repaired suites
pass `55/0/0`. The final archive-first no-skip gate passes `977/0/0`, all
eight opt-ins and zero skips. Taxonomy remains `partial` while broader
generated portrait acceptance is pending.

## 2026-09-26 FACE-01 second generated portrait closeout

The second frozen natural-style generated portrait oracle passes without
changing source identity, ROI or thresholds. Right roughness `5.150→4.206`
versus a `≤4.635` gate; smooth-negative right `3.194→3.194`; target/total
changes `7802/7802`; both hair and protected-region counts zero; neutral,
repeat and alpha pass. Code-generated chroma boundaries and short/sustained
hair positive and protection tests cover source-local and whole-side behavior.
The shared CPU/Metal point filter keeps the unobstructed side active. FACE-01
focused suites pass `23/0/0`; the complete archive-first no-skip script exits
zero with all eight opt-ins and no skipped tests. This evidence is limited to
the generated inputs and does not establish population or device quality.

## 2026-09-26 FACE-01 expanded generated boundary checks

Three skin-color rough/smooth pairs, opposite left/right background lightness,
and a short dark hair occlusion now have code-generated pixel assertions. The
hair case failed before repair with 90 changed pixels on its protected rows;
the guarded source-edge selection makes the rows source-exact while lower
cheek rows still change. The local refiner class passes `11/0/0`, and the
public facade orientation/recovery filter passes `2/0/0`. The original frozen
natural-style generated portrait oracle passes without input or threshold
changes: rough-positive left/right `6.106/6.731 → 4.000/5.044`,
smooth-negative `2.806/2.638 → 2.431/2.331`, target/total changes
`15825/15825` and `9059/9059`, protected changes `0/0`, with neutral,
repeat and alpha passing. The added color/occlusion inputs are generated
silhouettes, so more portrait variety remains open. A second natural-style
generated pair with deep skin, oblique light and cheek-crossing hair passes
source admission on the measurable right side (`5.150` rough positive versus
`3.194` smooth negative), then fails the frozen public CPU effect oracle:
right roughness remains `5.150` and 62 dark-hair pixels change on the left.
Neutral, repeat, alpha and smooth-negative checks pass. The new failed probe
does not revoke the earlier pair's bounded result; FUTURE-04 stays open.
The current tree's complete archive-first no-skip gate passes `977/0/0`,
eight opt-ins and zero skips independently of this new effect failure.

## 2026-09-26 indexed frame interval evidence

The public SPI-backed test fixes seven explicit frame indices at interval
three and checks detector invocation count, scheduled/skip summaries, no-face
color path, unindexed compatibility, invalid index/source typed failures,
interval mutation normalization, and recovery. It compares all generated
96×96 sRGB output pixels on scheduled and skipped frames. The first oracle
used a legacy helper that sampled only the upper-left pixel and was corrected
before acceptance; focused `2/0/0`, combined with preferred-size `3/0/0`.
This establishes cadence and fail-closed routing, not perceptual video
continuity. The complete current config tree passed archive-first no-skip
`993/0/0`, eight opt-ins and zero skips.

## 2026-09-26 preferred Vision detection-size evidence

The preferred detection-size test was fixed before implementation and initially
failed to compile because Vision's input had no such field. A generated 12×8
two-color raster now checks 6×4 detection, translated source extent,
orientation/mirror metadata, no upscaling, 1×1 lower bound and configuration
propagation, including invalid post-init mutation normalization. The initial
version focused `1/0/0`; the mutation check and full gate remain pending. The
wider Vision suite was `36/0/3` without the
full gate's opt-ins. The complete current config tree passed archive-first
no-skip `993/0/0`, eight opt-ins and zero skips.

## 2026-09-26 FUTURE-06 generated texture evidence

The `renderQuality` public generated 80×80 texture oracle was fixed before
implementation and failed while modes were identical. It now asserts strict
source/performance/balanced/quality smoothing order, flat negative neutrality,
protected hard boundary and alpha, neutral identity, repetition, typed
pixel-limit recovery, and CPU/available-Metal byte parity. Focused test result:
`2/0/0`. This verifies the configured spatial choice on generated input;
there is no physical-device throughput or broad visual quality evidence.
The quality-only tree passed complete archive-first no-skip `990/0/0`, eight
opt-ins and zero skips. The first attempt stopped at the legacy static
backend-path allowlist for the new test's existing `.gpu` selector; its reviewed
test bytes are now pinned by SHA-256 in that boundary checker. The subsequent
full run passed. The later preferred-size change needs its own final gate.

The new public generated-image oracle fixes a checker-textured cheek positive,
a moderate soft-edge positive, flat and hard-edge negatives, alpha and distant
protections, plus a portrait-like skin-colored cheek input with hair/eye/mouth
exclusions. Before implementation, all four initial tests failed on the old
proxy behavior. The final six public tests pass `6/0/0`; they check target
direction rather than changed-pixel count alone, and cover neutral, repeat,
orientation/mirroring, sRGB/Display P3, extent, and typed pixel-limit recovery.
An available-Metal generated buffer/still test checks both texture controls
and a combined color case against CPU at max RGB delta `≤2`, mean `<0.75`;
the focused Metal color suite passes `7/0/0`. Historical global-color tests
now exclude the two controls because their effect no longer aliases saturation
or contrast. The final archive-first `bash scripts/run-no-skip-swiftpm.sh`
returned zero with every SDK-owned preflight passing, eight opt-ins executed,
and zero skips. Two preflight static markers were updated to reflect that
texture is CPU-owned on both backend selections; the failed preflight attempts
did not represent pixel-oracle failures.

## 2026-09-26 FACE-01 source-boundary repair

The follow-up robustness suite initially reproduced two defects: a dark
background rough-positive did not improve, and weak contrast changed
protected upper rows. An additional alternating-light adversarial input
reproduced a 339-pixel fail-closed leak. The shared refiner now accepts either
coherent brightness direction, treats coherent weak contrast and conflicting
directions as side-local no-ops, and skips short opaque double-edge rows.
The eight in-memory boundary tests and the original eight FACE-01 focused
tests pass. The unchanged natural-style generated-pair oracle still passes
with its original aggregates. The archive-first no-skip gate returned zero,
with all SDK-owned prechecks passing, eight opt-ins executed and zero skips;
`git diff --check` also passed. The evidence and remaining scope are recorded
in `PLANS.md`.

The previously frozen natural-style generated-pair public CPU oracle passes
without changing its inputs or thresholds. Positive left/right cheek
roughness changed `6.106/6.731 → 4.000/5.050` pixels; smooth-negative
`2.806/2.638 → 2.431/2.356` remains within the 110% ceiling. Target/total
changed pixels match at `15821/15821` and `9069/9069`; protected regions
remain `0/0`. Neutral, repeat, alpha, and boundedness checks pass. The prior
failed probe below remains the historical baseline. New in-memory rough,
smooth, competing-edge, and transparent-row tests pass `4/0/0`; existing
FACE-01 frozen focused tests pass `8/0/0` after the ambiguity correction.
The archive-first `bash scripts/run-no-skip-swiftpm.sh` gate returned zero:
all SDK-owned prechecks and the full SwiftPM run passed, all eight opt-ins
executed, and no tests were skipped. `git diff --check` passed. Generated
images remain ignored local inputs, and only aggregates are recorded.

## 2026-09-25 FACE-01 generated natural-style portrait effect probe

A fictional rough-positive/smooth-negative pair passed source-only admission
under a frozen cheek-edge metric (positive left/right `6.106/6.731`; negative
`2.806/2.638`). The public CPU renderer produced neutral, candidate and repeat
outputs for both inputs. Neutral and repeat bytes and alpha passed. The frozen
effect oracle failed: positive roughness was `6.106/6.838` instead of at most
90% of source on each side; negative `2.837/2.700` remained within the 110%
non-worsening ceiling. Protected center/far-background changes were zero, but
target coverage was `10315/11142` and `8820/10037`, below the fixed 95% floor.
The result is a reproduced natural-style generated-input effect failure, not a
suite regression or a taxonomy promotion. The source-registered oracle is
`scripts/check-face01-generated-effect.swift`; generated images stay ignored
and local. SDK-only post-archive boundary and `git diff --check` pass. Full
archive-first no-skip was not run after this failed effect gate.

## 2026-09-25 FACE-01 stylized public-path oracle

New in-memory code-generated face positives and negatives use public
`BeautyEngine.processResult` with test-only detection support. A predeclared
source-fixed edge metric improves from `0.651` to `0.173` pixels on the rough
positive; the straight-edge negative remains source-exact. Neutral identity,
repeatability, target/exterior/central/background checks, alpha, extent, current
legacy CI color metadata, and redacted diagnostics pass. The two new tests pass
2/0/0; running them with the eight existing FACE-01 tests passes 10/0/0. The
source is a stylized polygonal face; no natural-style portrait visual effect or
taxonomy promotion follows. The older v1.23 runner keeps its frozen eight-test
filter unchanged.

## 2026-09-25 Metal public-combination budget regression

The 43 GPU-supported public geometry controls fit the retained 256-point
Metal pass in two representative complete supports: the generated asymmetric
face uses 115 combined points (119 summed single-control points), and the
ordinary complete observation uses 102 (102 summed). Positive and negative
signed settings both fit. The package regression verifies the pass retains all
points and the available GPU produces changed, repeatable output with exact
alpha; the separate synthetic 257-point rejection still returns a typed error.
`BeautyMetalGeometryPassTests` passed 7/0/0 and the SDK-owned Metal feature
preflight passed with Metal available, 37/0/0 and zero skips. This does not
prove a global upper bound for every observation or qualify device performance.

## 2026-09-24 replaceable generated fixtures in the complete gate

The archive-first no-skip wrapper now accepts an owner-authorized generated
Vision portrait by `BEAUTYSDK_VISION_PORTRAIT_FIXTURE` file name and generated
teeth/sclera positive-negative bundles by `PHASE59_TEETH_BUNDLE` and
`PHASE62_SCLERA_BUNDLE`. The default historical fixtures remain available.
Selection does not change the mandatory 8 opt-ins, face/eyebrow assertions,
feature-specific pixel or mask checks, zero-failure/zero-skip accounting, or
private-bundle Git-ignore checks. Validation: wrapper mutation self-test
`11/11`, renderer regression `24/0/0`; five Vision/facade/renderer checks with
a temporary alternate file name `5/0/0`; `../` selection rejected with a
generic missing-fixture error; complete archive-first no-skip gate passed with
all 8 opt-ins and 0 skips. The alternate-name run checked substitution using
the existing authorized image's bytes; it is not a generated-effect pass.

## 2026-09-24 generated-portrait acceptance policy

The current [image-effect acceptance policy](docs/IMAGE_EFFECT_ACCEPTANCE.md)
allows owner-authorized generated portraits to provide full positive/negative
effect evidence. A real-person source is not a quality gate or milestone
blocker. Tests still need source-fixed targets and protected regions, actual
output pixels and metadata, intended direction, negative/non-worsening checks,
repeatability, and typed failure. The historical v1.23 two-image receipt remains
limited because its frozen checks only measured output change and determinism,
not because the images were generated.
This documentation-only policy update was checked with a current-wording scan,
existence/reference checks for 14 key documents, and `git diff --check`.
SwiftPM was not rerun for this text-only change; the `951/0/0` result below
belongs to the preceding code repair.

## 2026-09-24 SDK audit repair verification

The archive-first `scripts/run-no-skip-swiftpm.sh` gate passed on the repaired
source with 951 SwiftPM tests, 0 failures, 0 skips, and all 8 opt-ins executed;
archive, SDK-only, Metal feature, configuration, CPU/Metal parity, consumer,
and CPU-reference checks passed. After that run started, the existing
highlight/shadow parity assertion was strengthened to require a changed
output instead of retaining the obsolete no-op exception. The parity gate was
rerun against that final test version: Metal available, 13 focused tests,
0 failures. Focused Core Image alpha tests verify opaque, translucent and
transparent pixels; invalid EXIF, pixel ceiling and 257-point Metal rejection
have dedicated regressions. The stale Phase 96 driver passed `bash -n` and
returns exit 2 before any batch or log action; `git diff --check` passed.
These are generated fixture and SDK gate results, not actual-portrait effect
or device qualification.

## 2026-09-24 v1.24 去脂效果改进（有界完成）

[预先固定的目标与保护区](.planning/V1.24-UPPER-EYELID-CURRENT.md) 使用同一
内存生成凸起输入：半强度源图中央分数 `9.3623085`，旧输出/源图比值
`0.4537424`；内部 gain `1.5 → 1.8` 后比值 `0.3422654`，改善约
`0.1114770`，满足 `≤0.35` 且至少多改善 `0.10` 的固定谓词。新增测试在
生产改动前对旧实现失败；复审后补半强度非均匀性、公开保护像素与双眼
独立性断言，编辑器/公开双入口 `12/0/0`。初次完整 archive-first
门禁 `945/0/0`、8 opt-in、0 skip 早于复审补测，属于中间检查；最终
源码重新通过完整 archive-first no-skip 门禁：archive、SDK-only、
后端/Metal、consumer、CPU-reference 与所有 8 项 opt-in 通过，SwiftPM
非零测试、零失败、零 skip；二次独立只读复审无剩余 Swift 问题，
[复审摘要](.planning/V1.24-INDEPENDENT-REVIEW.md) 与
[最终身份](.planning/V1.24-UPPER-EYELID-CURRENT.md) 已记录。
本次有界完成只证明生成输入机制改善；历史真实私有矩阵失败、真实人像
视觉质量不足及 FUTURE-04 均不因该数值改变。

## 2026-09-24 v1.23 合成输入机制验收

所有者指定的两张虚构生成图按[冻结契约](.planning/qualifications/v1.23-synthetic/CONTRACT.md)
在同一源码身份 `ec2589298925422dc6c3dfc65a68285caea4b6bdd913dffb3c0821673c6d3319`
完成公开 CPU neutral/candidate/repeat 像素检查；两张图的候选变化像素数为
12,031 / 9,495，neutral 与源图一致，重复输出一致，尺寸与 alpha 不变。
FACE-01 聚焦 `8/0`；注册 65 例双轮中原有七方向通过，FACE-01 旧固定 ROI
仍为 `semantic_fail`；archive-first 完整 SDK `944/0/0`、8 opt-in、0 skip。
独立复审无未解决问题，[追加式 COMPLETE](.planning/qualifications/v1.23-synthetic/attempt-20260924T045750Z-9429627d/COMPLETE.json)
的只读 verify 通过。此结果仅授予合成机制完成信用，不证明真实粗糙轮廓改善或
平滑人像不恶化；taxonomy 保持 `partial`。

## 2026-09-23 审计修复后的身份状态

本次人脸映射隔离改动修改了 `VisionFaceDetector.swift` 与对应测试，并修正
`maximumFaceCount` 文档口径。下方 **937/0/0** 与原 Phase95 COMPLETE 仅证明
原 v1.22 规范快照；旧 `verify-complete` 对当前代码仍返回
`review_missing_or_stale`。现由[追加式 COMPLETE](.planning/qualifications/v1.22-mapping-followup/attempt-20260923T083240Z-16509266/COMPLETE.json)
独立绑定当时映射修复身份 `0debce887ab95a49a4970f78dbb53f3500aca75d67861e4d493f011a176204af`：
真实65/65双次一致、七有效一延期，山根31对及五组[260,373] Q16；安全1/0/0、
兼容4/0/0、archive-first SwiftPM **938/0/0**、8项 opt-in、零skip，
实现/安全与目标由不同审查者复核。新 `verify --attempt` 当时通过；后续 v1.23
FACE-01 源码改动后，对当前工作树返回 `review_missing_or_stale`，旧签发身份仍有效。
2026-09-24 当前源码再次通过 archive-first no-skip 全门禁（8项opt-in、零skip）；
带原 Phase95 源注册的隔离65案例双轮诊断中，七个既有方向通过，FACE-01
在旧固定ROI比较器下仍为 `semantic_fail`，不能用作其真人像效果回执。
原 CHECKS/BINDING/portrait/COMPLETE 保持字节不变；没有设备、商业质量或
外部分发资格结论。

## 原 v1.22 验收快照（2026-09-23）

当前完成凭证为 [95-COMPLETE.json](.planning/phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json)，
`python3 scripts/check-phase95-closeout.py verify-complete` 验证通过。
同一规范快照真实执行：安全1/0/0、兼容4/0/0、65/65输出双次一致，七个有效方向与一项批准延期；
archive-first、SDK-only、wrapper检查和完整SwiftPM **937/0/0**，全部8项opt-in各精确一次。

山根使用source固定31对内侧鼻背表面标记，五组比较区间均为 **[260, 373] Q16**；
目标10774像素/RGB217300，目标外、鼻梁、鼻尖、背景和水印变化全部为0。
实际SDK生成校准6/6、432/432位置、72移动点真值全部覆盖；测量仅绑定当前已审核方法。

首次完整验收的65结果保留为 FIRST-RUN-OBSERVATION；随后 Metal 专项固定测试计数从34修正到35，
独立复核与当前完整门禁重新通过。没有减少测试、放宽失败/skip条件或把历史失败改为通过。
取消自测的就绪消息观察竞态经25次复现定位：其中3次测试观察先后颠倒，25次真实进程清理均正确且无残留。
同步修复后串行6次与双并发6次均通过，每次624项；生产管道与山根测量算法未改。
默认CPU支持修复；显式GPU遇新保护边界返回typed invalidInput并可恢复，不能宣称该效果CPU/GPU功能等价。
FACE-01/faceContourSmooth保持deferred/partial（FUTURE-04）；没有设备、群体或商业视觉质量结论。

证据：[CHECKS](.planning/phases/95-compatibility-and-sdk-only-closeout/95-CLOSEOUT-CHECKS.json)、
[65项结果](.planning/phases/95-compatibility-and-sdk-only-closeout/95-CLEAN-65-REPORT.json)、
[独立目标审核](.planning/phases/95-compatibility-and-sdk-only-closeout/95-GOAL-VERIFICATION.json)。
PLANS/QUALITY等行政更新不改变规范快照；后续规范代码/契约修改需当前身份重新验证。

## 历史质量记录：以下 current/latest 均指所标日期与对应快照

## Current whole-package regression (2026-09-22)

The archive-first SDK-owned wrapper executed929 tests:0 failed,0 skipped, all8
opt-ins exactly once. Strict transcript identity/order accounting and before/after
normative snapshots passed. See95-CURRENT-REGRESSION-OBSERVATION.json. This replaces
925 as the latest observed full-suite count, but does not grant missing root
measurement,65-output portrait or milestone completion acceptance. Future normative
changes require their corresponding fresh checks.

## Latest isolated mesh validation (2026-09-22)

All18 dependencies are acquired and hash-verified, installed offline in a fresh
isolated Python runtime. Independent review verifies2587 installed wheel payloads.
Actual CPU inference under network denial passes12 generated gray-image cases
with no face detections and unchanged input arrays. This supersedes older
acquisition/runtime blockers below; it is not positive-face/effect acceptance.
The local visible registrar passes7 generated tests normal/optimized, including
mixed-polarity outward alternatives. Source-only diagnostic passes5 protocol,
executable-closure and pixel-center mapping tests normal/optimized and Swift
compile-only; final independent review has zero unresolved findings. Two actual
source observations agree: prior15/16 rows, visible pairs6/16,539 candidate pairs,
unavailable10. This is applicability coverage, not semantic width qualification.
No output-image scoring, source registration or milestone completion follows.

## 当前质量状态（2026-09-22）

当前执行以[里程碑细则](.planning/V1.22-CURRENT.md)为准。下文带日期的各次
“current/latest”描述是对应版本的历史验证，不是当前工作树的全量认证。
旧完整人像candidate6为6/7；旧山根指标有确定反例；后继方法未完成人像准入。
历史914/0/0不替代当前closeout，SAFE-01/COMPAT-01/CLOSE-01仍待当前证据。
历史owner快照与当前回归分开验证，不能因PLANS正常记账就否定历史完成。
随后已实现v3收尾校验与原子finalize；证据验证16项、结构聚合9项通过。
genuine-gate拒绝15类日志变体、6类review变体，子进程检查3项通过。
实际安全/兼容SwiftPM共5/0/0，SDK-only boundary通过；恢复验证包含有效输入
非neutral正控制。16行原生山根实验失败并撤除；不计作新图片效果证明。
独立工具复审v3为0 blocker/0 warning；12个身份正控制接受、32个后缀反例拒绝。
随后独立全量no-skip实际通过925/0/0、8项opt-in精确一次；其执行前后规范
snapshot未捕获，因此记录为回归观察，不是v3 closeout绑定。
多候选结构聚合14项正常/优化测试通过并经独立review；候选完备性与结构身份
仍待证明。经独立review后，原图候选诊断实际执行两次一致，返回
metric_unavailable / visible_coverage，未形成合格行集合；该有限模型不能授予
山根效果通过或失败。尚无人像准入或完成凭证。
后继仿射源模型6项、精确采样器6项均在正常/优化模式通过；原生山根图像
测试7/0/0。独立审查绑定23文件，随后源图双运行一致：完整16行扫描，
0个paired candidate rows，metric_unavailable / affine_visible_coverage。
这证明该模型不适用于当前输入，不证明山根无效果；没有新的人像通过凭证。
新增测试发生在925项全量回归之后，该总数不描述新增测试后的完整工作树。


## Remaining work and dependency continuation (2026-09-22)

Current work is tracked in four blocks in V1.22-CURRENT.md: root measurement,
65-output acceptance, current full regression, and final independent closeout.
Historical6/7 phases or29/33 plans do not measure remaining effort. The absl-py
2.3.1 wheel now matches official hash/size, passes ZIP CRC, and includes Apache-2.0
metadata/license. No package is installed and no model is executed. System-TLS uv
still timed out; the subsequent pip dry-run succeeded with18 exact package versions
and archive hashes. Dependency-resolution JSON and a temporary hash-pinned lock
were generated; actual dependency acquisition/installation and inference remain pending.

## Public artifact recovery (2026-09-22)

The primary wheel now matches the official pinned SHA256 and size; the complete
four-member task ZIP passes CRC and the model card parses all7 pages. Static
bundle comparison matches468 ordered XYZ positions at float32 precision and898
triangle sets against the pinned OBJ. The upstream graph explicitly selects the
first468 predicted points. See95-ROOT-MESH-ACQUISITION.md. No dependency installation,
CPU inference, source registration or effect acceptance is implied. Independent95-ROOT-MESH-INDEX-REVIEW.md confirms ordered vertices and the full
oriented triangle sequence. Earlier acquisition failures below remain historical
observations; the latest dependency lock attempt still times out at absl-py.

## Public dense-mesh prior (2026-09-22)

Six generated topology/identity/input tests pass normal and optimized. Exact
public canonical OBJ digest,468 vertices/898 faces and2 mirrored candidate-chain
hypotheses validate. Flags remain prior-only, nonqualified and nonscoring. The
wheel and model-card acquisitions are incomplete; no model/dependency installed,
no inference, no private input accessed. The isolated resolver was terminated;
offline resolution confirms missing MediaPipe. This is not a portrait failure
or success and adds no SwiftPM/full-closeout acceptance.

Independent public-only review reports zero unresolved implementation issues, verifies the final three file digests, and passes43 typed-input rejections,6 asset rejections and2 positive boundary controls. Anatomical ownership, hypothesis completeness,468/478 index compatibility and instance uncertainty remain unqualified; see95-ROOT-MESH-FEASIBILITY-REVIEW.md.

## Lateral contour support (2026-09-22)

The separate lateral-support diagnostic treats all segment indices equally:
both endpoints must remain strictly on the relevant side of the fixed midpoint.
Incident-label conflicts remain non-lateral. Generated34 checks pass; independent
review adds30 conflict checks and rejects37 protocol/8 review-stability mutations.
Two actual source runs agree: paired3, side_supported0, cap_dependent3,
unsupported13. Thus geometric closure corrected an undercount but did not admit
any bilateral root-side cohort under this sufficient rule. No output image was
read, no threshold changed and no effect or milestone acceptance was issued.
This is not a theorem that the photograph lacks root anatomy or that every
possible automatic recognizer must fail. Existing tests remain native root9/0/0;
this scripts-only diagnostic did not rerun or replace the full-package gate.

## Declared contour topology (2026-09-22)

The prior diagnostic omitted Vision's declared topology. The separate successor
honors closedPath with exactly one last-to-first segment, leaves openPath open,
and rejects disconnected/unknown topology. Generated23 checks and independent
25 protocol/8 review-stability rejections pass. Two actual source-only runs agree:
closed topology, paired3, ambiguous0, unsupported13. The prior open-convention0
is not a complete contour-support result. No source registration or effect score
is granted: a closing edge must not automatically be called a visible root side.
Old observations and reviewed versions are unchanged.

## Shared-source uncertainty verification (2026-09-22)

The generated-only correlated-change helper retains the same uncertain source
location in reference/candidate forward changes instead of subtracting independent
absolute-width envelopes. Twelve Python tests pass both normal and optimized;
actual canonical RGB integration adds a fixed +/-0.5px uncertain-source positive
and fixed-boundary negative, passing2/0/0. The whole related image-formation suite
passes9/0/0 with PYTHONOPTIMIZE=1; SDK-only boundary passes. Original16 Q16, source,
neutral, all three siblings and signed-before-absolute aggregation are retained.
Independent95-ROOT-CORRELATED-CHANGE-REVIEW.md has zero unresolved findings;
720 position differences,720 width differences and200 cohort oracles agree.
No new private-image observation or admission follows.925 remains the earlier
whole-package regression count, not the current post-addition suite total.

## Source contour feasibility (2026-09-22)

The new source-only nose-polyline diagnostic passes10 generated checks. Independent
review binds15 files and rejects19 protocol and7 review/stability mutations. A
sandbox execution failure is distinguished from image results by a generated-only
Vision control (sandbox code9, unsandboxed success). The independently reviewed
environment recovery then completes two matching source-only runs: paired0,
ambiguous0, unsupported16. No output image, registration or effect score is involved.
This rejects direct use of the current nose-polyline cross sections as width
support; it is not proof that every automatic semantic method is impossible.

## Forward measurement and coverage verification (2026-09-15)

Forward helper328 checks pass; independent13500-system/243-map review is clean.
Two actual canonical generated structure cases include genuine narrowing and
unchanged boundaries despite neighboring texture movement. Their initial
single-row positive-assumption failure is preserved, not credited as a pass.
Integration reviews v1/v2 exposed permissive JSON and cleanup verification
defects; v3 clears the repairs, independently detecting omitted-KILL/leader-only
mutations with no stranded processes. Exact final transport tests pass4/0/0.

Approved source-only inspection: two identical records, crest11/16 and contour
3/16 vertical coverage, zero source registrations/scoring attempts. This does
not qualify bilateral anatomy. See95-ROOT-ANATOMY-COVERAGE-OBSERVATION.json.
No current all-opt-ins/no-skip or milestone-completion credit follows.
Final optimized related SwiftPM29/0/0; post-archive SDK boundary and diff checks
pass. Existing unrelated compiler warnings were not represented as a warning-free
build and were not changed in this repair.

## Nonlinear generated measurement verification (2026-09-15)

Final generated self-test contains38 true displacements, passes both ambiguity
controls, and accepts2/2 at32 and1024Q16 against unchanged16Q16 margin. Negative,
zero and15/16/17/20Q16 cases accept0/2. Actual-root tests pass3/0/0 under
PYTHONOPTIMIZE=1. The prior assertion could disappear under optimization;
unconditional rejection now survives both modes. Independent v2 verifies two
exclusion rejections and two positive controls; v1's independent exhaustive
mathematical comparisons found no discrepancies. Neither review credits
anatomy, portrait acceptance or milestone completion. See95-ROOT-NONLINEAR-MODEL.md
and its v1/v2 review records. Historical no-skip evidence is not refreshed by
these focused tests. Final related selection passes23/0/0; post-archive SDK
boundary and diff checks pass. No fresh all-opt-ins/no-skip closeout was run.

## Actual-root sampler and model applicability (2026-09-15)

`Phase95RootImageFormationTests`:2/0/0. Six canonical executions cover256/512
and neutral/half/full root strength. Unrounded Double error<=1 byte, identity,
alpha, extent, outside-field preservation and memory-PNG equality pass.
Two generated full-strength fields exceed the affine experiment's unit-pixel
search and have five-sample affine residual lower bounds>0.05px. This records
model inapplicability, NOT root effectiveness or portrait acceptance. No new
full no-skip or independent acceptance review is credited. Related SwiftPM
selection passes30/0/0; SDK-only post-archive boundary and diff checks pass.

## Affine-motion measurement-power probe (2026-09-15)

Revised generated signed-affine/RGB self-test:42 paired cases,84 true-motion
containments; unchanged16Q16 margin passes32Q16 in6/6 and20Q16 in5/6, with
-32/0/15/16/17 each0/6. Flat/brightness-ramp ambiguity remains in the returned
hull instead of being discarded; a sign-crossing slope case is contained.
The earlier inward-only/one-channel draft's0/2 at32Q16 is retained as failed
measurement-power history, not promoted. Analytic fixture truth is not an
independent production-image oracle. No new SwiftPM, portrait, registration,
full-gate or completion credit. Independent review is clean:22 polytopes,
97 complete vertex-set comparisons and1172 active-set checks all agree.
Final main self-test also passes one error-budget widening, one crossing,
two ambiguity and three invalid-input controls. Exact source/model hashes
are recorded in NEW95-ROOT-AFFINE-REVIEW-v1.md; these are not portrait receipts.

## Subpixel and canonical image formation verification (2026-09-15)

New actual-sampler-backed exact interval experiment:126/126 reference matches
and truth containments, seven negative rejections, unchanged16Q16 threshold.
Independent review:118/118 complete feasible-set agreements, zero findings.
The wider one-byte budget detects20/32Q16 in9/9 cases each and17Q16 in3/9;
<=16Q16 is not promoted. It is not arbitrary photometric or root-field evidence.
Two new SwiftPM methods verify selected canonical sRGB/PNG chains; the reference
was strengthened to UNROUNDED Double and independently rechecked,2/0/0. Final
related selection (image formation, pixel-center, inward safety, nose provider)
passes21/0/0. Reviews: `95-ROOT-SUBPIXEL-REVIEW-v1.md` and `-v2.md`.
No new full no-skip, portrait scoring, source-registration or closeout credit.

## Measurement power investigation (2026-09-15)

The new generated-only identifiability probe measures actual 112→108 pixel
widths independently of the frozen metric: true512Q16 versus conservative
margin-594. Its18 integer correspondence cases and3 negative controls pass.
Independent review confirmed the nuisance equivalence and identified a truth
oracle regression gap; the fix is independently clean, and identity/expansion
substitutions now exit2. See `95-ROOT-IDENTIFIABILITY-REVIEW-v2.md` for exact
hashes. This proves a measurement-model limitation, not portrait success.
Near-threshold pixel-to-verdict sensitivity, subpixel uncertainty and anatomical
registration remain unvalidated. Prior914/0/0 is historical regression only;
no new full-suite or milestone completion is claimed.

## Current standalone regression (2026-09-14)

Archive-first all-opt-in no-skip gate actually passed: 914 tests, zero failures,
zero skips, eight opt-ins; actual Metal parity executed 13 focused tests with
zero unavailable tests. Complete run-time snapshot matched before/after.
Aggregate evidence: `95-RESUMED-REGRESSION-2026-09-14.json`. This supersedes older
ordinary-suite counts for regression only, not portrait acceptance or formal
Phase95 closeout. Source registration still rejects `remote_competing_edge`;
no successful registration, new-metric portrait score or completion is credited.

## Phase 95 independent metric defect review (2026-09-14)

Terminal evidence: reviewed v3 registrar actually rejects the source with
`ambiguous_structure`, exit2; zero successful source registrations. Transport
fix and its independent review pass 8/22/7 generated checks plus 12 reviewer
assertions. No new-metric portrait score or final no-skip is possible yet.
Current Plan03 remains blocked; see `95-ROOT-SOURCE-ATTEMPTS-v2.json`.

Latest: independent re-review v3 approved exact generic draft 2 (commit a205d973),
confirmed all four findings resolved and independently reproduced 346/11 passing
checks with additional combined-nuisance containment probes. The source-only
adapter now passes 8 generated carrier/exclusion checks plus 22 admission attacks;
its integration review and real source registration are not yet completed.

Current successor: implementation review `a74b8c33` rejected draft 1 despite its
250 passing checks. Draft 2 fixes the three blockers and crossing-oracle warning;
346 generated checks and focused SwiftPM 11/0/0 now pass. Independent re-review
is pending. The prior results below remain historical, not draft-2 approval.

The narrow independent review confirmed two blockers: a dark-centroid structural
measurement defect and missing per-row metric identity validation. It also found
the generated provider direction test reused the defective proxy. Review report:
`95-ROOT-METRIC-REVIEW.md`, preserved at commit `2eb0dee0`.

The identity guard now passes comparator self-test 597, including eight new
metric substitution rejections. The provider direction oracle now measures
generated boundary crossings with explicit rounding uncertainty; focused 10/0/0
passed before dead-branch cleanup. The replacement metric prototype passed
250 generated checks, including size/subpixel ground-truth intervals,
bounded-noise/blur and pixel-domain threshold adversaries.
After dead-branch cleanup, ordinary full SwiftPM passed 913 tests with zero
failures and eight opt-in skips. This is not the no-skip completion gate.
No current no-skip, amended portrait
success, implementation-review approval or Phase95 completion is credited.

## Internal contract revision qualification (2026-09-14)

Owner-approved candidate 6 revises internal chin/root bounds, preserving all
registered pixel acceptance criteria, public parameter caps and fixture identity.
Final focused source selection passes 14/0/0, including generated root-structure
contraction, inverse-map canthus containment and sub-cap admission. A rounding
failure at the canthus was fixed by an interior margin, not a weaker assertion.
Legacy chin/nose/mouth tests also passed before that final margin-only edit.
Live portrait evaluation is still required; no completion is inferred here.

The genuine closeout gate rejects seven mutated test transcripts and six invalid
review records and passes three child-output/deadline checks. The clean driver
self-test remains 16; actual SDK-only boundary and diff checks pass. Formal
current completion must be established by current hash-bound
`95-CLOSEOUT-CHECKS.json`, not by historical predeclared baseline counters.

## Phase 95 resumed repair verification (2026-09-13)

Candidate 3 passed 106 focused methods and ordinary full SwiftPM 906 methods
with zero failures and eight opt-in skips (not a no-skip completion gate).
Its two identical portrait runs pass five active directions; chin/root margins
14/0 remain below 16. Negative mouth passes at -32; all protected/outside deltas
are zero. FACE-01 now explicitly tests its unchanged failing predicates and
non-promotion under owner authorization instead of asserting a deferred pass.
Compatibility exact-backend hashing and hash-pinned CPU-only test fixtures pass
the boundary self-test and actual SDK-only scan. Original review bindings are
retained and not claimed to authorize the changed compatibility test.

Candidate 4 fixes a separately reproduced pixel-center defect. Fresh workspace
focused tests pass 22/0/0; registered portrait and current full-suite evaluation
completed: full SwiftPM exited zero, while two identical 65-case portrait
attempts still fail chin/root at 14/0. Candidate 5 redistributes unused chin
budget and centers root support within the canthus interval; focused 23/0/0
passes. Its two reconciled 65-case attempts also fail chin/root at 14/0;
the five other active directions pass with every outside/protected delta zero.
No candidate-5 full-suite/no-skip credit is inferred. No final receipt or independent
completion review is claimed.
See `95-REPAIR-RESUMPTION.md` for pre-run identities and rejected alternatives.

## Phase 95 registration repair verification (2026-09-12)

The original portrait semantic failure remains historical. Source-only
inspection found its fixed gaze targets disjoint from both actual eye
apertures. Owner-approved anatomy registration is independently computed before
output evaluation and frozen by digest. Comparator self-test now covers 589
probes, including target-identity and outside-leakage gaze attacks plus eleven
seven-active/one-deferred classifier probes. Driver self-test passes 16/16.
These tests validate evidence handling; they do not establish live semantic
success or complete Phase 95.

Candidate 1 passed the expanded 106-test generated selection twice from a fresh
scratch build; the earlier incremental-build crash remains recorded.
Candidate 2 passed 117 focused tests with zero failures, including unchanged
Phase 90–94 generated semantic oracles and new observed support/mapping tests.
Full registered portrait semantics and the archive-first no-skip gate remain
separate requirements, not inferred from those focused counts.

Terminal candidate-2 portrait result: 65/65 outputs twice identically, four
active directions pass, three remain below the fixed semantic margins. All
active target signals pass and outside/protected pixel/RGB measurements are
zero. Ordinary full SwiftPM reports 904 methods, eight opt-in skips and eight
assertion failures in one pre-existing deferred FACE-01 test (reproduced at
untouched HEAD). Archive verification passes; the existing compatibility-test
literal trips the frozen boundary scan. No final no-skip or phase completion
is credited. Detailed aggregates and identities are in `95-ROI-AMENDMENT.md`.

> Current SDK-only quality scorecard and repeatable verification contract.
> Time-bounded application/UI evidence remains historical in archived milestones.

## Current Post-Archive Audit Status

v1.21 is the current quality boundary for `去脂`: the existing bounded v4
mechanics now have a public owner-local still-image scalar and deterministic
facade pixel/metadata/failure coverage. The owner accepts the current result as
usable while explicitly rating its visual effect weak; no new blinded review
is claimed. This is score-3 provisional product acceptance, not device,
commercial-quality, packaging, shipping, launch, or release-readiness evidence.
The final archive-first no-skip closeout passed SwiftPM `816/0/0`, with all
eight opt-ins exactly once and zero skips.

v1.17 was historically archived at `afb04b4` with Metal-available focused
`12/0/0` and full `765/0/0` evidence. The current tree has repaired public raw
metadata compatibility (`53e8da1`), unavailable-host parity accounting
(`d29b90a`), and Metal geometry point binding beyond the 4 KiB inline limit
(`556499a`). Available parity now requires `focused_tests=13` and
`parity_executed=1`; unavailable-host typed coverage reports
`parity_executed=0` and cannot borrow GPU parity success.

The 2026-08-18 Metal-available branch recorded `metal_available=1`,
`metal_unavailable=0`, `parity_executed=1`, `focused_tests=13`, and
`unavailable_tests=0`. Focused preflights passed backend-neutral `24/0/0`,
Metal runtime `42/0/0`, Metal feature `34/0/0`, configuration `19/0/0`, and CPU
reference `41/0/0`. The archive-first closeout passed XCTest `776/0/0`, all
eight opt-ins exactly once, and `skipped_tests=0`.

The historical counts are not current full-gate evidence; the current count is
the verified v1.21 `816/0/0` closeout above. F-01 through F-10 are dispositioned with
bounded contracts: CPU-owned local-retouch composition, exact-opaque GPU RGB
input and named-sRGB output, tight generated still-image math parity, and
caller serialization for a non-`Sendable` engine instance. Scores and acceptance
remain bounded and make no transparent-input, end-to-end GPU local-retouch,
shared-instance parallel, device, commercial, packaging, shipping, launch, or
release-readiness claim.

## Phase 80 Candidate-v2 Remediation Quality Evidence

Candidate v1 remains non-promotable after its frozen texture failure and early
100%-detail weak-effect/rectangular-artifact finding. Candidate v2 mechanics add
twelve semantic-support tests plus editor, safety, composition, detector, and
package integration coverage. The focused remediation run is `24/0/0`; the
full plain SwiftPM run is `803/0/8`, with all skips belonging to the established
explicit opt-ins rather than the new mechanics. The post-archive SDK-only
boundary and diff hygiene also pass.

New pixel oracles cover strict brow/eye exclusion, typed missing/crossed support,
elliptical feather continuity, Q16 ceiling enforcement, hue preservation,
original high-frequency residual carry, texture retention `>= 0.98`, target
change, exact protected/exterior/alpha/extent/metadata behavior, peer isolation,
collision-to-source, and determinism. These generated tests qualify mechanics
only. Genuine efficacy/naturalness and any public promotion remain pending the
fresh candidate-v2 contract and private review.

## Phase 89 Semantic Validation Quality Evidence

Phase 89 completes shared validation machinery, not the five downstream
repairs. Code-review remediation independently pins every value in the eight
contracts and mutation-tests each threshold, ceiling, region edge, membership,
and order. Runner preflight still admits the exact live `75` renderer cases,
selected five-batch/`65` mechanical cases, and eight frozen directions.

The earlier owner-local `1/8 semantic_pass`, `7/8 semantic_fail` aggregate is
revoked as creditable evidence: `pupilToOwnEyeCenter` used target-box dark-pixel
centroids without independently admitted pupil and eye-contour anatomy. The
comparator now rejects that metric as `unsupported_metric`; the runner publishes
only a sanitized exit-2 `infrastructure_failure`. Generated lash/shadow, foreign
dark-patch, centered-pupil, and off-center-pupil probes all prove the proxy cannot
earn semantic credit. No new model, data, network, UI, or public API is added.

Semantic acceptance requires direction-specific target signal, polarity,
minimum signal, outside locality, documented sibling distinction, and every
protected-region ceiling. Arbitrary pixel change and pass-only threshold tuning
cannot earn acceptance. The report and retained first attempt remain ignored
owner-local artifacts. Successful semantic publication requires verified
repeat-media, temporary-report, workspace, and transcript cleanup. A
`cleanup_failure` earns no credit and requires owner-local
containment/remediation because physical deletion could not be verified.
Durable records retain only aggregate counts and fixed reasons.

This evidence preserves exactly 62 public parameter fields, five presets, and
75 renderer cases; both public still-image facade signatures and the CPU
reference/public `.cpu`/`.gpu` selection with terminal
`.metalUnavailable` remain unchanged. Teeth, sclera, and upper-eyelid
local-retouch are outside v1.22 repairs. Physical-device evaluation remains
optional and non-blocking, and this owner-local validation establishes no
naturalness, population, performance, commercial, packaging, shipping, launch,
release-readiness, or distribution claim.

## Phase 90 Chin Repair and Contour Deferral Evidence

Phase 90 closes two intentionally different outcomes. FACE-02 `chinTaper` is
complete; FACE-01 `faceContourSmooth` is `completed-deferred`, non-GREEN, and
remains `partial` under FUTURE-04. The owner-authorized boundary synchronization
changes exactly one expected taxonomy tuple in
`scripts/check-sdk-only-boundary.sh` from `implemented` to `partial`; production
source, tests, fixtures, thresholds, other scripts, public inventory, renderer,
backends, and retained `Warp.metal` remain unchanged.

Fresh bounded package-host evidence passed on 2026-09-04:

- The focused FACE-02 plus safe/current FACE-01 and geometry regression filter
  executed `142` tests with `0` failures and `0` skips. It deliberately omitted
  the frozen FACE-01 effectiveness method while retaining its two current
  safety/provider-behavior methods.
- The compatibility filter executed `154` tests with `0` failures and `1`
  existing Vision integration opt-in skip. It reconfirmed exactly 62 public
  fields, five neutral presets, 75 renderer cases, both still-image facades, and
  the existing CPU/GPU selection and terminal-unavailable policy.
- Comparator `--self-test` returned `PASS`, `mutations=554`, and inventories
  `5/65/8`. Runner `--preflight-only` returned `live=75`, `selected=65`, and
  `semantic=8`, preserving the aggregate `75/65/8` contract without rendering
  or publishing portrait output.
- Archive verification passed for `BeautyDemo`
  (`04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52`)
  and `meituxiuxiu`
  (`330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a`),
  followed by `POST-ARCHIVE SDK BOUNDARY PASSED`.

The focused evidence reconfirmed the completed FACE-02 contract: exact-cap
`chinTaper` keeps deterministic paired lower-chin ownership, X-only movement,
apex and Y preservation, request-local failure, protected-region preservation,
and sibling distinction. Its established generated/public measurement remains
target `1001/48557`, direction `+60 Q16`, and outside `0/0`. This is not
FACE-01 semantic credit; that field retains only its current safe/fail-closed
behavior and has no compliant frozen GREEN result.

Chin precision evidence stays split between direct tests and source-defined
behavior. Direct tests cover exact `Float.ulpOfOne` rejection,
`Float.ulpOfOne.nextDown` rejection, least-nonzero rejection, half strength
`0.125`, exact cap `0.25`, and over-cap request `1` equaling the cap. Source
defines strict `> Float.ulpOfOne`, `min(requestedStrength, cap)`, strict `<` for
quantization-hostile selection, and exact `== cap` for the three-pair band.
Phase 95 owns direct tests for `Float.ulpOfOne.nextUp`,
`BeautySafetyCaps.chinTaper.nextDown`,
`BeautySafetyCaps.chinTaper.nextUp`, and exact/one-representable-step values
around the `immediateDistance == maximumDisplacement * 0.5` quantization tie.
The strict comparison outcomes are source audit findings, not newly measured
runtime branches.

No live portrait command and no complete no-skip wrapper ran in Phase 90.
Phase 95 retains the clean 65-output publication, seven effective directions
plus one deferred direction, the precision/tie residuals, and the all-opt-ins
no-skip closeout. This evidence is owner-local SDK validation only and grants
no device, population, visual-quality, commercialization, packaging, shipping,
launch, external distribution, or release-readiness authority.

## 1. Score Scale

| Score | Meaning |
| --- | --- |
| 0 | absent or unverifiable |
| 1 | historical idea only |
| 2 | current contract without implementation evidence |
| 3 | implementation and basic tests with known gaps |
| 4 | milestone-grade main/failure paths plus synchronized automated image/output evidence |
| 5 | separately authorized owner-local device/product evidence in addition to automation |

## 2. Current Snapshot

| Area | Score | Current evidence | Next move |
| --- | ---: | --- | --- |
| Root owners | 4 | Current contracts consistently name SDK-only SwiftPM ownership and archive-only UI history. | Keep owners synchronized with code/tests. |
| SDK package | 4 | One public library, one SDK-owned renderer, six internal/library targets, no remote dependency. | Preserve facade and dependency direction. |
| Tests | 4 | 81 SwiftPM test files including public upper-eyelid facade pixel/metadata/failure coverage; historical gate counts remain labeled historical. | Preserve deterministic pixel/metadata oracles; physical-iPhone feedback is optional and non-blocking. |
| Repository consumer / CLI | 4 | Public-surface-only local-path fixture observes generated RGBA bytes/dimensions; compiled renderer covers 75-case discovery, reconciled reports, typed failures, and render/encode seams. | Preserve archive → boundary → consumer → no-skip ordering. |
| Archive integrity | 4 | Code-owned ZIP/manifest anchors, exact 45/26 inventories, bounded streamed extraction, frozen-retirement rollback, and safe restore self-tests pass. | Verify before every full closeout. |
| SDK-only boundary | 4 | Retired roots are absent; scanner rejects symlinks, restored application/UI sources, stale current owners/maps, tracked media, application artifacts, retained-shader drift, and backend/API drift. | Keep scanner fail-closed. |
| Security | 4 | Local-first input/resource/privacy and request-local local-retouch ownership are test-backed. | Reopen for any new trust boundary. |
| Reliability | 3 | Typed errors, deterministic degradation/recovery, input bounds, no-skip handling, and archive recovery are specified/tested; device/performance evidence is outside scope. | Add only when a later authorized milestone requires it. |
| Product acceptance | 3 | Bounded still-image teeth/sclera plus provisional owner-accepted `去脂` behavior are SDK-core only; the upper-eyelid visual result is known weak and transparent/end-to-end-GPU/device claims remain excluded. | Preserve nonclaims and optimize `去脂` only in a future explicit milestone. |

No score of 5 is claimed. Package/fixture automation does not establish device
performance, population sufficiency, or owner-local product visual approval.
Score 4 is sufficient for an internal SDK milestone when its automated contract
is complete; the absence of score-5 device/product evidence cannot block
planning or milestone progression. Packaging, shipping, external launch,
SDK commercialization, and release readiness are not higher-score goals: they
are excluded by the owner-only distribution contract.

## 3. Active Inventory

| Inventory | Value |
| --- | ---: |
| Swift source files | 76 |
| SwiftPM test files | 81 |
| Swift source lines | 18,857 |
| SwiftPM test lines | 36,008 |
| Public `BeautyParameters` stored fields | 62 |
| `BeautyConfiguration` stored fields | 11 |
| Built-in neutral presets | 5 |
| Renderer cases | 75 |
| Documented mandatory opt-ins | 8 |
| Legacy archive bundles | 2 |

Counts exclude `.build` and historical ZIP contents. Executed test totals, not
method-name scans, remain the runtime authority.

## 4. Mandatory Gates

```bash
swift build --package-path BeautySDK
swift test --package-path BeautySDK
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
git diff --check
bash scripts/check-swiftpm-consumer.sh
bash scripts/check-cpu-reference-oracles.sh
bash scripts/run-no-skip-swiftpm.sh
```

`scripts/run-no-skip-swiftpm.sh` is the complete gate. It must run archive
verification first, the SDK-only scanner, the archive-aware v1.18
decision/baseline self-test and live gate, the external consumer, and the
generated CPU reference preflight before its existing one-child SwiftPM
transcript parser. Streaming capture is limited to 16 MiB and 200,000 lines. The
parser accepts only all eight opt-ins exactly once, one nonzero zero-failure
XCTest aggregate, one passed Swift Testing aggregate when that runner starts,
and zero skip/disabled events from either format.

`scripts/check-v1-18-decision-binding.py --repo-root <root>` is the current
historical successor to the immutable Phase-79 checker. It resolves the
archived Phase-75/78/79 machine decision, rejects missing or invalid historical
inputs, and remains independent of caller cwd. It intentionally does not reject
the later v1.21 public field/route/case or bind current editor/test digests.
Durable output remains fixed aggregate status and normalized reasons—never
child transcripts, private locators, pixels, masks, landmarks, support, or
review prose.

Physical-iPhone access, a manual device checkpoint, or pending user feedback is
never an implicit prerequisite for this gate. Image-producing tests must assert
the owning pixel and metadata contract—applicable extent/dimensions,
orientation/mirroring, color/alpha, neutral identity, intended movement,
protected-region preservation, tolerance, determinism, and failure behavior—so
a zero exit status without validated output cannot earn completion credit.

The v1.16 historical wrapper evidence is 702 executed tests, zero failures, and
zero skips. The Phase-71 wrapper evidence is historically 728 executed tests,
zero failures, and zero skips. The historical Phase-73 wrapper executed 753 tests
with zero failures and zero skips, all eight opt-ins exactly once, and separate
Metal availability classifications. Its archive → boundary self-test/live scan → consumer → generated
CPU → opt-in → one-child order is mandatory; the boundary self-test rejects an
unconditional generic `BeautyResult` sendability declaration. The public
concurrency focus is 3/0/0. The current v1.21 active inventory is 76 Swift source
files, 81 SwiftPM test files, 18,857 source lines, and 36,008 test lines. The
current closeout is XCTest `816/0/0`, all eight opt-ins exactly once, and
`skipped_tests=0`.

## 5. Archive Quality Gate

The repository-owned archive verifier must prove:

- exact artifact filenames plus independent code-owned ZIP/manifest SHA-256,
  compressed-size, 45/26 count, path-inventory, per-entry, total-uncompressed,
  and compression-ratio anchors;
- CRC/integrity, sorted unique safe entries, normalized metadata, and file-only
  inventory;
- exact ZIP/manifest path, size, and content-hash equality;
- streamed hashing/extraction into a nonexistent child of a fresh private
  temporary directory with no symlink/path escape;
- no restoration of retired roots into the active repository.

The archive README is the only historical access contract. Raw archive contents
or large extraction transcripts are not durable quality evidence.

## 6. SDK and Test Rules

- Public behavior requires facade tests and owning-target tests.
- Safety-sensitive image effects require both positive movement and exact
  protected/out-of-mask preservation.
- Eligible generated portraits can prove both mechanics and owner-local effect
  quality when feature-specific direction, negative, protection, and visual or
  pixel assertions pass. Genuine human fixtures are optional additional input.
- Every required image fixture gate is code/script-driven and judges actual
  input/output content; rights-approved opt-ins are not physical-device tests.
- Physical-iPhone testing is optional post-SDK user evaluation. Its absence or
  delay cannot fail a milestone, create an unexpected skip, or stop the next
  plan unless the user explicitly authorizes a later device milestone.
- Reproducible device feedback should become an automated regression. Until
  separate device/product evidence exists, keep device performance, thermals,
  battery, endurance, commercial visual quality, and release claims unmade.
- Fixture media, region/landmark data, local locations, and child output stay
  out of tracked evidence.
- Tool failure, unknown output, missing test summary, unexpected skip, or zero
  execution is failure, never a warning.
- Historical application/UI tests do not satisfy current SDK requirements.

## 7. Doc Gardening

1. Read `AGENTS.md` and `PLANS.md`.
2. Compare package graph/source/test inventory with `ARCHITECTURE.md` and codebase maps.
3. Compare public model/taxonomy with `DESIGN.md` and `docs/SDK_EFFECT_TAXONOMY.md`.
4. Compare privacy/trust changes with `SECURITY.md`.
5. Compare errors/recovery/performance claims with `RELIABILITY.md`.
6. Run the post-archive scanner and mandatory no-skip gate.
7. Record out-of-scope work in `PLANS.md` rather than expanding the change.

## 8. Current Repair Queue

| Priority | Item | Status |
| --- | --- | --- |
| 1 | Enforce backend-result alpha/extent publication invariants (F-08). | remediated; focused regression coverage added |
| 2 | Preserve CPU-owned local-retouch composition and identity Metal transport (F-02). | resolved; no end-to-end GPU claim |
| 3 | Preserve opaque/named-sRGB GPU input policy and tight CPU-oracle still-image math (F-04/F-05). | resolved; transparent input remains unsupported |
| 4 | Preserve single-observation provenance and caller-serialized non-Sendable engine semantics (F-09/F-10). | resolved; no shared-instance parallel claim |

Historical UI/device/commercial work is not an active repair item.

## Phase 70 Contract Quality

Phase 70 adds a package-only backend-neutral contract without changing the
public inventory. The CPU policy remains the reference; Metal resources/passes
and public backend selection remain later-phase work. Contract tests cover both
input kinds, fail-closed admission, matching output kinds, deterministic bounded
diagnostics, and terminal executor errors without fallback. Aggregate status is
the only durable evidence; support, raster, geometry, path, and private fixture
data remain transient.

## Phase 71 Metal runtime Quality Evidence

The `check-metal-runtime.sh` preflight is the quality owner for the
package-internal runtime mechanics. It verifies regular-file ownership under
`BeautyRender`/`BeautyEffects`, the authorized shader inventory, bounded
dimensions/bytes and resource cleanup, synchronization/status handling, no
public selector or host lifecycle dependency, and aggregate-only diagnostics.
It mutation-tests cleanup removal, public schema drift, alternate execution,
private diagnostic fields, and target placement. Focused
`BeautyMetalRuntimeTests` and `BeautyMetalBackendTests`, plus the existing
backend contract/CPU suites, execute 26 tests with zero failures/skips on a
Metal-available host; an unavailable host is reported separately as
`metal_unavailable` and is never GPU success.

The archive-first wrapper runs this preflight after archive/boundary and
Phase-70 backend authorization and before consumer, generated CPU, opt-in, and
full-child stages. CPU remains the reference. Phase 72 owns feature passes,
Phase 73 owns public `.cpu`/`.gpu` configuration, and Phase 74 owns generated
parity/no-skip closeout. These are SDK-only aggregate/static claims, not
simulator/physical-device, performance, commercial, packaging, shipping,
launch, or release-readiness evidence.

## Phase 72 Feature-Pass Quality Evidence

`BeautyMetalLocalRetouchPassTests` adds generated in-memory coverage for
canonical Q16 composition, protected bytes, alpha, extent, named sRGB,
collision-to-source, malformed/foreign/duplicate isolation, mixed pass order,
and terminal resource cleanup. `check-metal-feature-passes.sh` requires the
color, geometry, local-retouch, and runtime suites, mutation-tests cleanup,
source binding, raw-payload privacy, alternate execution, public schema, and
target ownership, and reports Metal availability separately. The archive-first
wrapper invokes this gate exactly once before consumer, CPU-oracle, opt-in, and
full-child stages. CPU remains the reference; Phase 73 owns public selection
and Phase 74 owns parity/no-skip closeout.

## Phase 73 Public Configuration Quality Evidence

Historical Phase-73 evidence records the configuration self-test/focused suite
at `16/0/0` and the runtime suite at `34/0/0`. The public selector is
exactly `.cpu`/`.gpu`, defaults and missing legacy keys resolve to `.cpu`, and
explicit unavailable GPU is terminal `.metalUnavailable` without CPU fallback.
The archived wrapper executed `753/0/0`, all eight opt-ins exactly
once, and separate `metal_available=1` / `metal_unavailable=0` classifications.
This closes configuration policy only; Phase 74 owns generated parity and
SDK-only closeout. No UI/Demo, device, performance, commercial, packaging,
shipping, launch, or release-readiness evidence is claimed.

## Phase 74 Historical Generated Parity and Mandatory Gate Evidence

`check-backend-parity.sh` mutation-tests CPU-vs-GPU comparisons, exact neutral
bytes, pinned active tolerances, safety/containment/failure suites, raw-output
privacy, and available/unavailable accounting. It executes focused parity
coverage `12/0/0` with `metal_available=1` and `metal_unavailable=0` on the
archived host. The archived `run-no-skip-swiftpm.sh` run invoked parity exactly
once and completed the full child at `765/0/0`, with eight opt-ins exactly once,
zero skips, and zero failures.

CPU remains the permanent oracle. The current repaired gate grants GPU parity
credit only when `parity_executed=1`; unavailable coverage reports `0`. Current
bounded evidence is parity `13/0/0` and full `776/0/0`; it does not establish
transparent input, end-to-end GPU local retouch, shared-instance parallel safety, UI/Demo,
simulator/device, performance, commercial, packaging, shipping, launch, or
release-readiness quality.

## Phase 76 Per-Eye Support Quality Evidence

Phase 76 adds 10 adversarial semantic-owner tests, one-request/one-owner route
tests, and two original-pixel composition handoff tests. The focused closeout
executes 52 tests with zero failures; three existing Apple Vision integration
tests remain environment-gated opt-ins. The standard-library boundary checker
rejects eight isolated mutations covering shared-observation reuse, side
coupling, semantic approval bypass, typed no-op fallback, finite/containment
bypass, orientation/mirror duplication, overlap-to-source behavior, and
privacy leakage. The archive-first full gate passes 790 tests with zero
failures and zero skips. These are SDK mechanics and compatibility results;
they do not establish genuine efficacy, naturalness, device, commercial,
packaging, shipping, launch, or release-readiness quality.

## Phase 78 Genuine Evaluation and Candidate Decision Quality Evidence

The Phase 78 candidate suite executes 6 tests with zero failures or skips. The
integrated evaluator self-test records 12 checks and 8 mutation rejections;
the standard-library boundary checker independently rejects 8/8 mutations for
missing-bundle bypass, metadata-only promotion, comparator rights/boundedness/
safety weakening, privacy leakage, and decision drift. Exact public absence is
61 fields, five presets, and 74 renderer cases. Archive-first
`run-no-skip-swiftpm.sh` passes 797 tests with zero failures and zero skips.

No rights-approved genuine bundle was supplied, so the recorded recommendation
is `mechanics-only-not-promotion`; ALG-02 comparator admission and generated
mechanics are documented, while genuine positive/negative quality remains
pending. This evidence does not establish efficacy, naturalness, device,
commercial, packaging, shipping, launch, or release-readiness quality.

## Phase 77 Deterministic Editor Quality Evidence

Phase 77 added seven focused editor/safety tests covering neutral identity,
the then-current low-frequency/detail reconstruction, bounded deltas, invalid-input isolation,
actual RGBA8 exterior/protected/alpha/metadata preservation, and
overlap-to-source collision behavior. The boundary checker rejects 8/8
mutations covering public-surface drift, privacy leakage, unbounded edits,
composition bypass, and peer coupling. Archive-first
`run-no-skip-swiftpm.sh` passes 797 tests with zero failures and zero skips.
This is deterministic package mechanics evidence only and does not promote the
effect or establish genuine efficacy, naturalness, device, commercial,
packaging, shipping, launch, or release-readiness quality.

## Phase 80 Candidate-v3 Mechanics Quality Evidence

Candidate v2 is terminal after its real-image automated matrix passed only
14/19 rows; no human review occurred. Candidate v3 retains the generated
brow-to-lid elliptical support tests and replaces independently signed
per-pixel corrections with one clipping-safe, non-positive equal-RGB contour
per eye. The focused 25-test group now proves single-sign output, exact
pre-feather channel/spatial-detail preservation, curved feathering, adjacent
jump `<=5`, texture retention `>=0.98`, immutable exterior/protected pixels,
alpha, extent, metadata, collision-to-source, and determinism. This remains
mechanics-only until a separately frozen v3 genuine gate passes.

## Phase 79 Conditional Productization Quality Evidence

The failing branch consumes `mechanics-only-not-promotion` and proves exact
61-field/five-preset/74-case public absence. `去脂` remains future and `眼睛`
remains partial; package-only support/editor mechanics do not receive public or
genuine-quality weight. The closeout checker mutation-tests decision bypass,
surface drift, taxonomy promotion, backend fallback, metadata drift, and source
changes. Root contracts, public SDK guidance, taxonomy, PLANS, and the docs
index record the same branch and preserve all device/commercial/release
nonclaims. The checker passes live mode and rejects 8/8 isolated mutations;
archive-first `run-no-skip-swiftpm.sh` passes 797 tests with zero failures and
zero skips, with all eight opt-ins exactly once.

The current post-archive successor independently replays the machine decision,
hash-bound deterministic-editor baseline, ten focused package tests, exact
public absence, and five immutable Phase-79 contract artifacts through explicit
`--repo-root` resolution. Its self-test adds seven active/archive/outside-cwd
artifact checks and fails closed on ambiguity, absence, or symlink substitution.
The mandatory wrapper's own 10/10 mutation test pins archive-first order,
decision self/live exact-once execution, all eight opt-ins, one complete SwiftPM
child, and normalized aggregate output. This reproducibility evidence does not
satisfy EVID-01/02 or QUAL-01/02 and makes no genuine efficacy, naturalness,
device, commercial, packaging, shipping, launch, or release-readiness claim.

## Phase 80 Candidate-v4 Mechanics Quality Evidence

Candidate v3 is terminal because a uniform regional tone shift did not produce
a visible upper-eyelid fullness reduction. Candidate v4 now has 30 focused
upper-eyelid tests passing with zero failures. The generated positive oracle
requires spatially non-uniform relief correction, center delta below `-8`,
more than five correction values, and post-composition convexity below `55%`
of source. Negative planar-lighting and crease-only fixtures must remain
inapplicable.

Safety coverage retains exact equal-RGB/chroma carry before feathering,
high-frequency texture ratio `>=0.98`, adjacent composed correction jump
`<=5`, `±16` channel cap, protected/exterior source identity, alpha, extent,
metadata, deterministic repetition, peer isolation, and overlap-to-source.
The full plain SwiftPM result is `805/0/8`; it is a development check, not the
archive-first zero-skip closeout.

These generated checks established mechanics only. Candidate v4 could receive
no genuine efficacy, naturalness, or public-product weight without two private
automated passes and every required 100%-detail human judgment; its later
automated non-pass made those conditions ineligible.

## Phase 80 Learned-Path Decision Quality Evidence

The owner canceled the learned path on 2026-08-25 before Plans 80-21/22. The
boundary-only evidence below is retained, but learned efficacy is no longer an
active quality gate and no promotion closeout is expected for v1.19. Exact
61/5/74 absence was the final v1.19 result. Cancellation closeout passes 34/34
teeth/sclera/combined integration tests, 74/74 parameter/renderer-contract
tests, the rebound v1.18 absence gate with 15/15 mutation checks and 13/13
focused tests, and the archive-first all-opt-in SwiftPM gate at 813/0/0 with
eight opt-ins exactly once and zero skips.

Candidate v4 subsequently failed its frozen private automated matrix twice with
identical applicability, boundary-continuity, and minimum-relief dispositions;
review never opened. Candidate-v5 threshold tuning is canceled. Plan 80-19
selects an owned-data learned hybrid because visible fullness reduction needs
both a bounded upper-lid soft-tissue contour change and compatible low-frequency
shading, while source texture and protected regions remain immutable-owned.

The decision freezes data/license, paired-target, model, Core ML conversion,
pixel composition, fail-closed, automated, human-review, privacy, and stop
contracts before source remediation. It adds no quality credit: no model,
training data, public field, resource, route, renderer case, or new output
exists, and exact 61/5/74 public absence remains the v1.19 historical quality result.
Plan 80-20 proves only the unavailable/invalid-prediction boundary. Learned
efficacy remains blocked until actual-use-authorized identity-disjoint paired
data with exact fullness targets, model parity, fresh genuine automation, and
blinded review all pass. Research-only inputs and their derived models remain
local and receive no commercial or distribution claim.

Plan 80-20 adds no efficacy score. Its historical quality result is boundary-only:
`8/0/0` learned prediction tests, `23/0/0` all upper-eyelid tests, and plain full
SwiftPM `813/0/8`, plus archive, SDK-only boundary, exact 61/5/74 absence, and
diff-hygiene passes. Rejected mechanics are explicit experiments; the learned
owner has no model and produces no proposals. Final promotion closeout was
canceled with Plans 80-21/22; any future retry must create a new milestone and
requalify its data/model/evidence contract.

## v1.21 Provisional Upper-Eyelid Public Quality Evidence

The owner later superseded only the current public-surface decision, not the
v1.18/v1.19 evidence. v1.21 adds one generated end-to-end facade suite covering
the trailing scalar's clamp/Codable/legacy-neutral behavior, both public
still-image entries, actual changed pixels, deterministic repetition, exact
alpha, no changes outside the owned union, one request transaction, and
source-exact zero/no-face degradation. Static inventories now require 62 public
fields, five neutral presets, and 75 renderer cases.

This supports a provisional score of 3 for `去脂`: implementation and bounded
automated behavior exist, and the owner accepts use with a known visual-quality
gap. It does not erase failed genuine automation, claim a new human review,
qualify a learned model, or establish device/population/commercial quality.

## Phase 91 Independent Gaze Correction Quality Evidence

Phase 91 completed in shared implementation attempt 1 after one research pass
and one independently checked four-plan set. Generated 512×512 explicit-sRGB
RGBA8 public-facade evidence measured own-center reductions `201/203 Q16`,
target signal `1316` changed pixels / `51731` absolute RGB delta, and exact
`0/0` outside, eye-contour, eyebrow, background, and watermark signal. Neutral,
bilateral, single-side, missing/malformed peer, ratio-implausible peer, exact
dead zone, just-above boundary, cap, repeated cap, no-face, and valid-invalid-
valid paths passed with alpha, extent, metadata, and source-safe rejection.

The final six-field aggregate passed bilateral `2/2/0/1/0/688`, single
`1/1/0/1/0/688`, and abstaining `0/0/0/0/1/0` algebra. Comparator admission
keeps direction evidence bound to the exact successful output and still
requires every frozen actual-pixel target, sibling, locality, and protection
gate. Its self-test passed 576 mutations with inventories `5/65/8`; the runner
boundary suite passed with `report_cleanup=6` and `preflight_faults=3`; shell
syntax and exact preflight `live=75 selected=65 semantic=8` passed.

Fresh package-host closeout evidence is:

- The Phase-90-deferred frozen FACE-01 effectiveness oracle is discovered
  exactly once and remains intentionally non-GREEN. Every other current test
  passed `840/0/8`; the eight skips are established explicit opt-ins.
- Focused parameter/resource/renderer/metadata/backend compatibility passed
  `107/0/0` and reconfirmed exactly 62 stored fields, five presets, 75 renderer
  cases, both still-image facades, CPU reference, `.cpu`/`.gpu`, terminal
  `.metalUnavailable`, and unchanged retained `Warp.metal`.
- Backend-neutral gates passed 24 focused and 41 CPU-reference tests. The CPU
  reference inventory's two test-only gaze samples were moved from the aperture
  boundary to deterministic interior positions; no production behavior or
  assertion threshold changed.
- Archive verification passed for `BeautyDemo`
  (`04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52`)
  and `meituxiuxiu`
  (`330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a`),
  followed by `POST-ARCHIVE SDK BOUNDARY PASSED` and clean diff hygiene.

No live portrait batch, final clean 65-output publication, or
`scripts/run-no-skip-swiftpm.sh` ran. Phase 95 owns those gates. This evidence
supports EYE-01 owner-local mechanics and protection only; it establishes no
device, population, naturalness, performance, commercial, packaging, shipping,
launch, release-readiness, or external-distribution claim.

## Phase 92 Signed Eyebrow-Head Spacing Quality Evidence

Current accepted repair is R5 `470ae0d`, repair cycle 1 / cumulative attempt 7.
Independent review found and resolved R4 dense inverse-map folding; RED commit
`4a92373` reproduced 12 expected assertions in one new regression before the fix.
Independent R5 implementation review is clean (`92-REVIEW.md`).

Exact BROW discovery is 9 unique methods; full provider/public/registration
classes pass 18+3+2=23 with zero failures/skips. Actual pixels retain source and
neutral signs +48/-22 Q16, opposite 70, four whole-brow distinctions 26/35/96/35,
target 699/720 and RGB 61174/45676. All outside/outer/eye/background/watermark
maxima are 0/0. Unilateral changes 350/349 retain peers 0/0; recovery 699 is
byte-identical with rejected-source identity. Metadata/extent/alpha/sRGB,
neutral identity, deterministic bytes, independent registration and redaction pass.

Post-R5 compatibility/freshness: 217 discovered, 0 failures, 2 established portrait
opt-in skips; required compatibility 120/0/0 and freshness/resolver/combined 97/0/2.
The dense regression covers 4/5/16 samples, both sides/signs, low/half/cap
strengths and independently evaluated additive sampling. Prior chin/gaze/
upper-eyelid regression 15/0/0 passed before R5; those implementations are unchanged.
Comparator 576 mutations/inventories 5/65/8, runner boundary/report_cleanup 6,
syntax, preflight 75/65/8, backend-neutral 24 plus CPU-reference 41, both archive
hashes and post-archive SDK-only boundary pass. Frozen source identities and
diff hygiene pass. Full fixed evidence and archive hashes are in 92-03-SUMMARY.md.

Exactly 62 fields, 5 presets, 75 renderer cases, both facades, CPU/GPU policy and
retained Warp.metal remain unchanged. No raw media, geometry, private paths,
reports or transcripts were retained. Phase 95 alone owns portraits and the full
no-skip wrapper. No device, naturalness, commercial, launch or distribution
qualification is inferred from generated package-host evidence.

## Phase 94 Mouth Prerequisite Evidence

The reviewed metadata successor freshly passed **9 discovered / 9 passed /
0 failed / 0 skipped / 0 unexecuted**. This includes three actual registration
and rejection-control methods, two checked-integer oracle methods, two public
baseline methods and two unchanged provider methods. All 56 retained-row
outputs agree across wrappers and repeats; `94-METADATA-BASELINE.json` binds
14 row digests, the source digest and the positive aggregate.

Positive source/neutral comparisons each measured 2233 changed pixels,
728847 absolute RGB and +176 Q16 span. Signed-size margins are19/237 Q16.
Full and clipped protection checks pass: mouth-height/face/background/watermark
maxima0/0, outside0 changed/90 RGB. Color-only optional metadata must agree
across wrappers/repeats; neutral/geometry tags and named-sRGB extraction remain
strict. No production algorithm, source recipe or pixel threshold changed.

Original build failure and the later retained-row assertion failure remain in
their immutable histories. Exact compile and metadata corrections passed
independent review and pure checks35/0/0 and17/0/0 before fresh acceptance.
These results complete 94-01 prerequisites only. Negative width is unmeasured,
MOUTH-01 and Phase94 remain incomplete, and production attempts remain0/2.

## Phase 93 Distinct Nose Repair Quality Evidence

Candidate 2 supplies owner-local generated mechanics at provider
`bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`
and adapter
`cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9`.
[93-CHECKS.json](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-CHECKS.json)
binds the per-gate results and independent code review `ee6d55f9`
(`1d86dcdd42ca8c6fedf239f835c1abd070628b66039e3688017a4d165e8e6441`).
Independent goal verification passed.

Sequence references below are from `93-ATTEMPTS.md`. CHECKS directly contains
receipts 53/54/56 (and subsequent owner receipts when recorded); core receipt
47 remains in the ledger and is pinned by `93-REGRESSION-DISPOSITION.json`.

| Gate | Discovered / passed / failed / skipped | Ledger evidence |
|---|---:|---|
| Core | 36 / 36 / 0 / 0 | 42–47; repeated 48–52: provider 22, registration 4, metrics 4, pixels 2, lifecycle 4 |
| Compatibility, 11 classes | 229 / 229 / 0 / 0 | Receipt 53 |
| SDK-owned commands | 8 / 8 / 0 / 0 | Receipt 54; commands, not XCTest methods |
| Supplemental deterministic regression | 106 / 106 / 0 / 0 | Receipt 56 under reviewed scope correction `07664fa5` |

The eight commands independently establish: comparator self-test 576 mutations
and 5/65/8 inventory; runner-boundary/report-cleanup 6; batch-shell syntax;
preflight 75/65/8; backend-neutral 24 plus CPU-reference 41 tests; both historical
archive verifications; SDK-only boundary; and diff hygiene. They do not mean
the full no-skip suite or a 65-output portrait batch ran.

| Canonical control | Source and neutral changed pixels / RGB | Signed margin | Minimum sibling margin | Comparisons |
|---|---:|---:|---:|---:|
| Bridge | 611 / 29460 each | +383 Q8 | 373 Q8 | 6 |
| Root | 1043 / 43917 each | +24 Q16 | 24 Q16 | 5 |

Both repeat flags are 1; all outside, protected nose, background and watermark
maxima are 0 changed pixels / 0 RGB. All five legacy sibling digests agree.
The metric uses bridge Q8 and root Q16 without rescaling frozen thresholds.
Registration and both canonical semantic tests passed; the eight-orientation
loop proves bridge raw-facade agreement only, not all-orientation root semantics.
The raw emitting route retains Device RGB; measurement extracts named sRGB.
Dense/mixed, cutoff, malformed support, metadata and recovery evidence is
limited to the frozen generated cases.

CHECKS and the timeout/regression dispositions distinguish the unchanged
original gate `873dba5a...` from recovery entrypoints `4b07195c...`,
`eb7ccc0f...` and `7ff1598b...`. Receipts 47/53/54 are transparently reused
at their original identities; receipt 56 is fresh under the last entrypoint.
No historical receipt or frozen binding is rewritten.

The initial 16/0/0 provider baseline establishes unchanged-provider invariants
only; the earlier registration checkpoint is source-only, not runtime evidence.
Candidate-1 failure, candidate-2 timeout 39/rollback 40 and scope error 55 remain.
Error 55 classified an extra portrait opt-in selection after 34 passes, not a
numerical assertion failure. The corrected 106-method selection removes only
the two out-of-scope opt-ins, preserves the failed record and changes no tests,
thresholds or production candidate. Two substantive attempts remain consumed.

Phase 95 alone owns private portraits, final clean 65-output evidence, precision
residuals and full no-skip closeout. These results do not qualify naturalness,
device performance, commercial quality or external distribution.

Independent goal verdict: [93-VERIFICATION.md](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VERIFICATION.md), 18/18 must-haves and zero blockers.

## Phase94 Negative Mouth-Width Acceptance Evidence

MOUTH-01 policyB passed the current41-method acceptance:41 discovered/executed/
passed,0 failed/skipped/unexecuted, at the exact compiled/reviewed/sealed provider.
The current CHECKS SHA256 is `fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`.
Both source and neutral comparisons independently measured520 changed pixels,
73743 RGB and−24Q16 signed span. Positive-width/size-plus/size-minus separation
margins are200/181/37Q16. All outside/height/face/background/watermark protection
maxima are0/0;14 inherited row digests and the source digest remain exact.

Coverage includes three registration and two inherited oracle methods, two
public baseline methods, three new negative oracle methods and one actual
negative public method, four actual Float field methods, four signed lifecycle
methods, the16-method original mouth provider inventory and six degradation
methods (deduplicating the two inherited provider anchors gives41 total).
The new public negative method compares20 returned images across both wrappers
and repeats. Field tests prove actual fixed-support behavior; an inconclusive
sufficient bound alone never counts as a failure. Lifecycle checks preserve
raw orientation/mirror/metadata contracts without claiming canonical semantics
for every encoding. Independent implementation/security review has zero
correctness blockers or high-security findings.

History remains: prerequisite9/9; negative baseline13/12/1; full baseline
41/39/2 with protection leakage and actual crossing/reversal; attemptA41/40/1
with only392 changed pixels below500, then owned rollback; attemptB41/41.
The runner's reviewed authoring self-tests pass16/16 with72 attack rejections.
Research1, same checked plan set1, attempts2/2; thresholds, source and frozen
tests were not tuned after measurement. Phase95 private portraits/final65/full
no-skip remain separate. No population, device, commercial or distribution
qualification is inferred from these generated-source CPU checks.

## v1.23 FACE-01 Evidence Boundary

The current candidate passes the unchanged generated FACE-01 eight-predicate
oracle, generated public-facade pixel/metadata/recovery coverage, multi-size
alpha and central/background checks, and generated CPU/Metal still-image
parity. A source-only portrait batch completed all 65 cases twice; seven
previously active directions remained semantic passes. FACE-01 changed 5,647
pixels / 126,841 absolute RGB delta, but the historical comparator still
used its generated-image fixed FACE-01 ROIs and reported target `0`, fixed
central `5,647`, and direction `0 Q16`. An exploratory source-admitted lateral
ROI moved the same 5,647 changes into target with outside `0`, yet direction
and sibling distinction remained `0 Q16`. This is no portrait effectiveness
credit. The ROI experiment was not retained in the historical comparator.
The portrait run preceded the sparse-contour source correction, so it is a
diagnostic run rather than a final-current-identity acceptance receipt.

The first full no-skip gate failed one combined 44-field compatibility test
because sparse FACE-01 lateral admission was too narrow. The provider was
corrected without changing thresholds; the focused 17-test compatibility
class passes. An independent generated silhouette boundary oracle now covers
nearest and inward edge rasterization, with a straight-side negative. The
final-source archive-first gate passed `944/0/0`, with all eight opt-ins, zero skips,
archive and SDK-only checks, and all backend, Metal, consumer, and CPU-reference
gates. The bounded source-edge correction also passed all eight focused
FACE-01 tests. A direct 65-case diagnostic without Phase 95 source registration
returned `semantic_fail` and is excluded from comparison with the earlier
registered portrait batch. Positive/negative portrait
qualification remains outstanding, as recorded in
[v1.23 FACE-01 current](.planning/V1.23-FACE01-CURRENT.md). The taxonomy
remains `partial`; a generated mechanical pass does not establish natural
portrait quality, population behavior, device performance, or release scope.
