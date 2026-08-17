# QUALITY_SCORE.md

> Current SDK-only quality scorecard and repeatable verification contract.
> Time-bounded application/UI evidence remains historical in archived milestones.

## 1. Score Scale

| Score | Meaning |
| --- | --- |
| 0 | absent or unverifiable |
| 1 | historical idea only |
| 2 | current contract without implementation evidence |
| 3 | implementation and basic tests with known gaps |
| 4 | main/failure paths plus synchronized automated evidence |
| 5 | release-like regression and required manual/runtime evidence |

## 2. Current Snapshot

| Area | Score | Current evidence | Next move |
| --- | ---: | --- | --- |
| Root owners | 4 | Current contracts consistently name SDK-only SwiftPM ownership and archive-only UI history. | Keep owners synchronized with code/tests. |
| SDK package | 4 | One public library, one SDK-owned renderer, six internal/library targets, no remote dependency. | Preserve facade and dependency direction. |
| Tests | 4 | 61 SwiftPM test files; public `BeautyResultConcurrencyTests` executes 3/0/0; generated CPU reference preflight executes 15 + 10 + 16 tests with zero skips; the v1.16 historical child executed 702 tests, Phase 71 executed 728, and current Phase 73 executes 753 with eight documented opt-ins; focused configuration/runtime coverage, renderer regression, and compiled Process coverage; bounded exact XCTest/Swift Testing accounting rejects both runners' skips and ambiguity. | Keep full conjunction mandatory. |
| External consumer / CLI | 4 | Public-only local-path consumer observes generated RGBA bytes/dimensions; compiled renderer covers 74-case discovery, reconciled reports, typed failures, and render/encode seams. | Preserve archive → boundary → consumer → no-skip ordering. |
| Archive integrity | 4 | Code-owned ZIP/manifest anchors, exact 45/26 inventories, bounded streamed extraction, frozen-retirement rollback, and safe restore self-tests pass. | Verify before every full closeout. |
| SDK-only boundary | 4 | Retired roots are absent; scanner rejects symlinks, restored application/UI sources, stale current owners/maps, tracked media, application artifacts, retained-shader drift, and backend/API drift. | Keep scanner fail-closed. |
| Security | 4 | Local-first input/resource/privacy and request-local local-retouch ownership are test-backed. | Reopen for any new trust boundary. |
| Reliability | 3 | Typed errors, deterministic degradation/recovery, input bounds, no-skip handling, and archive recovery are specified/tested; device/performance evidence is outside scope. | Add only when a later authorized milestone requires it. |
| Product acceptance | 4 | Bounded still-image teeth/sclera behavior and exact taxonomy remain SDK-core only. | Preserve nonclaims and `去脂` future status. |

No score of 5 is claimed. Package/fixture automation does not establish device
performance, population sufficiency, commercial quality, packaging,
shipping, launch, or release readiness.

## 3. Active Inventory

| Inventory | Value |
| --- | ---: |
| Swift source files | 66 |
| SwiftPM test files | 61 |
| Swift source lines | 14,952 |
| SwiftPM test lines | 29,995 |
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

The v1.16 historical wrapper evidence is 702 executed tests, zero failures, and
zero skips. The Phase-71 wrapper evidence is historically 728 executed tests,
zero failures, and zero skips. The current Phase-73 wrapper executes 753 tests
with zero failures and zero skips, all eight opt-ins exactly once, and separate
Metal availability classifications. Its archive → boundary self-test/live scan → consumer → generated
CPU → opt-in → one-child order is mandatory; the boundary self-test rejects an
unconditional generic `BeautyResult` sendability declaration. The public
concurrency focus is 3/0/0 and the current active inventory is 66 Swift source
files, 61 SwiftPM test files, 14,952 source lines, and 29,995 test lines.

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
| 1 | Replace unconditional generic `BeautyResult<Output>` sendability with a source-compatible conditional contract. | planned Phase 69 |
| 2 | Strengthen clean SwiftPM consumer and structured CLI input/output validation. | planned Phase 67 |
| 3 | Freeze compact deterministic CPU reference oracles without new algorithms. | planned Phase 68 |
| 4 | Complete selectable CPU/GPU backend policy and generated parity while preserving CPU as the oracle. | Phase 74 parity and SDK-only closeout complete |

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

`check-backend-configuration.sh` passes its self-test and focused configuration
suite with `16/0/0`; the runtime suite passes `34/0/0`. The public selector is
exactly `.cpu`/`.gpu`, defaults and missing legacy keys resolve to `.cpu`, and
explicit unavailable GPU is terminal `.metalUnavailable` without CPU fallback.
The archive-first wrapper then executes `753/0/0`, all eight opt-ins exactly
once, and separate `metal_available=1` / `metal_unavailable=0` classifications.
This closes configuration policy only; Phase 74 owns generated parity and
SDK-only closeout. No UI/Demo, device, performance, commercial, packaging,
shipping, launch, or release-readiness evidence is claimed.

## Phase 74 Generated Parity and Mandatory Gate Evidence

`check-backend-parity.sh` mutation-tests CPU-vs-GPU comparisons, exact neutral
bytes, pinned active tolerances, safety/containment/failure suites, raw-output
privacy, and available/unavailable accounting. It executes focused parity
coverage `12/0/0` with `metal_available=1` and `metal_unavailable=0` on the
current host. The archive-first `run-no-skip-swiftpm.sh` invokes parity exactly
once and completes the full child at `765/0/0`, with eight opt-ins exactly once,
zero skips, and zero failures.

CPU remains the permanent oracle. Evidence is aggregate-only and establishes
SDK/algorithm/Metal-pipeline correctness for the generated matrix, not UI/Demo,
simulator/device, performance, commercial, packaging, shipping, launch, or
release-readiness quality.
