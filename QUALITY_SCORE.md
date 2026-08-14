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
| Tests | 4 | 50 SwiftPM test files; default 650-test baseline with eight documented opt-ins; mandatory no-skip gate executes all eight with zero skip/failure. | Keep full conjunction mandatory. |
| Archive integrity | 4 | Two independently verified ZIPs, sorted manifests, SHA-256 records, safe extraction, and digest-bound retirement evidence. | Verify before every full closeout. |
| SDK-only boundary | 4 | Retired roots are absent; scanner rejects restored application/UI sources, tracked media, application artifacts, retained-shader drift, and backend/API drift. | Keep scanner fail-closed. |
| Security | 4 | Local-first input/resource/privacy and request-local local-retouch ownership are test-backed. | Reopen for any new trust boundary. |
| Reliability | 3 | Typed errors, deterministic degradation/recovery, input bounds, no-skip handling, and archive recovery are specified/tested; device/performance evidence is outside scope. | Add only when a later authorized milestone requires it. |
| Product acceptance | 4 | Bounded still-image teeth/sclera behavior and exact taxonomy remain SDK-core only. | Preserve nonclaims and `去脂` future status. |

No score of 5 is claimed. Package/fixture automation does not establish target-
device performance, population sufficiency, commercial quality, packaging,
shipping, launch, or release readiness.

## 3. Active Inventory

| Inventory | Value |
| --- | ---: |
| Swift source files | 64 |
| SwiftPM test files | 50 |
| Swift source lines | 14,294 |
| SwiftPM test lines | 27,494 |
| Public `BeautyParameters` stored fields | 61 |
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
bash scripts/run-no-skip-swiftpm.sh
```

`scripts/run-no-skip-swiftpm.sh` is the complete gate. It must run archive
verification and the SDK-only scanner before its existing one-child SwiftPM
transcript parser. The parser accepts only all eight opt-ins exactly once, zero
failures, zero skips, and nonzero executed tests.

## 5. Archive Quality Gate

The repository-owned archive verifier must prove:

- exact artifact filenames and recorded ZIP SHA-256 values;
- CRC/integrity, sorted unique safe entries, normalized metadata, and file-only
  inventory;
- exact ZIP/manifest path, size, and content-hash equality;
- extraction into a new temporary directory with no symlink/path escape;
- no restoration of retired roots into the active repository.

The archive README is the only historical access contract. Raw archive contents
or large extraction transcripts are not durable quality evidence.

## 6. SDK and Test Rules

- Public behavior requires facade tests and owning-target tests.
- Safety-sensitive image effects require both positive movement and exact
  protected/out-of-mask preservation.
- Synthetic fixtures prove mechanics only; rights-approved local fixtures remain
  separate opt-in product gates.
- Raw fixtures, pixels, masks, landmarks, local paths, and child transcripts stay
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
| 4 | Add a separately selectable GPU backend only after v1.16 closes, while preserving CPU as the oracle. | queued v1.17 |

Historical UI/device/commercial work is not an active repair item.
