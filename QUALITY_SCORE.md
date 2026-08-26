# QUALITY_SCORE.md

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
owner-local artifacts; repeat media, temporary reports, and transcripts are
removed, while durable records retain only aggregate counts and fixed reasons.

This evidence preserves exactly 62 public parameter fields, five presets, and
75 renderer cases; both public still-image facade signatures and the CPU
reference/public `.cpu`/`.gpu` selection with terminal
`.metalUnavailable` remain unchanged. Teeth, sclera, and upper-eyelid
local-retouch are outside v1.22 repairs. Physical-device evaluation remains
optional and non-blocking, and this owner-local validation establishes no
naturalness, population, performance, commercial, packaging, shipping, launch,
release-readiness, or distribution claim.

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
- Synthetic fixtures prove mechanics only; rights-approved local fixtures remain
  separate opt-in product gates.
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
