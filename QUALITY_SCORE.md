# QUALITY_SCORE.md

> Current SDK-only quality scorecard and repeatable verification contract.
> Time-bounded application/UI evidence remains historical in archived milestones.

## Current Post-Archive Audit Status

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
the verified `776/0/0` closeout above. F-01 through F-10 are dispositioned with
bounded contracts: CPU-owned local-retouch composition, exact-opaque GPU RGB
input and named-sRGB output, tight generated still-image math parity, and
caller serialization for a non-`Sendable` engine instance. Scores and acceptance
remain bounded and make no transparent-input, end-to-end GPU local-retouch,
shared-instance parallel, device, commercial, packaging, shipping, launch, or
release-readiness claim.

## 1. Score Scale

| Score | Meaning |
| --- | --- |
| 0 | absent or unverifiable |
| 1 | historical idea only |
| 2 | current contract without implementation evidence |
| 3 | implementation and basic tests with known gaps |
| 4 | milestone-grade main/failure paths plus synchronized automated image/output evidence |
| 5 | separately authorized release-like device/product evidence in addition to automation |

## 2. Current Snapshot

| Area | Score | Current evidence | Next move |
| --- | ---: | --- | --- |
| Root owners | 4 | Current contracts consistently name SDK-only SwiftPM ownership and archive-only UI history. | Keep owners synchronized with code/tests. |
| SDK package | 4 | One public library, one SDK-owned renderer, six internal/library targets, no remote dependency. | Preserve facade and dependency direction. |
| Tests | 4 | 74 SwiftPM test files; current mutation-tested preflights and archive-first XCTest `776/0/0` pass with eight opt-ins and zero skips. Historical counts remain labeled historical; all ten audit findings are dispositioned. | Preserve deterministic pixel/metadata oracles; physical-iPhone feedback is optional and non-blocking. |
| External consumer / CLI | 4 | Public-only local-path consumer observes generated RGBA bytes/dimensions; compiled renderer covers 74-case discovery, reconciled reports, typed failures, and render/encode seams. | Preserve archive → boundary → consumer → no-skip ordering. |
| Archive integrity | 4 | Code-owned ZIP/manifest anchors, exact 45/26 inventories, bounded streamed extraction, frozen-retirement rollback, and safe restore self-tests pass. | Verify before every full closeout. |
| SDK-only boundary | 4 | Retired roots are absent; scanner rejects symlinks, restored application/UI sources, stale current owners/maps, tracked media, application artifacts, retained-shader drift, and backend/API drift. | Keep scanner fail-closed. |
| Security | 4 | Local-first input/resource/privacy and request-local local-retouch ownership are test-backed. | Reopen for any new trust boundary. |
| Reliability | 3 | Typed errors, deterministic degradation/recovery, input bounds, no-skip handling, and archive recovery are specified/tested; device/performance evidence is outside scope. | Add only when a later authorized milestone requires it. |
| Product acceptance | 3 | Bounded still-image teeth/sclera behavior and exact taxonomy remain SDK-core only; supported package-host parity is current but transparent/end-to-end-GPU/device claims remain excluded. | Preserve nonclaims and keep `去脂` future. |

No score of 5 is claimed. Package/fixture automation does not establish device
performance, population sufficiency, commercial quality, packaging,
shipping, launch, or release readiness. Score 4 is sufficient for an SDK
milestone when its automated contract is complete; the absence of score-5
device/product evidence cannot block planning or milestone progression.

## 3. Active Inventory

| Inventory | Value |
| --- | ---: |
| Swift source files | 72 |
| SwiftPM test files | 74 |
| Swift source lines | 16,824 |
| SwiftPM test lines | 33,569 |
| Public `BeautyParameters` stored fields | 61 |
| `BeautyConfiguration` stored fields | 11 |
| Built-in neutral presets | 5 |
| Renderer cases | 74 |
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
verification, the SDK-only scanner, the external consumer, and the generated
CPU reference preflight before its
existing one-child SwiftPM
transcript parser. Streaming capture is limited to 16 MiB and 200,000 lines. The
parser accepts only all eight opt-ins exactly once, one nonzero zero-failure
XCTest aggregate, one passed Swift Testing aggregate when that runner starts,
and zero skip/disabled events from either format.

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
concurrency focus is 3/0/0 and the current active inventory is 72 Swift source
files, 74 SwiftPM test files, 16,824 source lines, and 33,569 test lines. The
current remediation closeout is XCTest `776/0/0`, all eight opt-ins exactly
once, and `skipped_tests=0`.

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

Phase 77 adds seven focused editor/safety tests covering neutral identity,
low-frequency/detail reconstruction, bounded deltas, invalid-input isolation,
actual RGBA8 exterior/protected/alpha/metadata preservation, and
overlap-to-source collision behavior. The boundary checker rejects 8/8
mutations covering public-surface drift, privacy leakage, unbounded edits,
composition bypass, and peer coupling. Archive-first
`run-no-skip-swiftpm.sh` passes 797 tests with zero failures and zero skips.
This is deterministic package mechanics evidence only and does not promote the
effect or establish genuine efficacy, naturalness, device, commercial,
packaging, shipping, launch, or release-readiness quality.

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
