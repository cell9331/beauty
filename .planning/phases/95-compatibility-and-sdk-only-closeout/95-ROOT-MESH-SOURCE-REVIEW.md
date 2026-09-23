---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T09:12:41Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - scripts/phase95-root-mesh-source-diagnostic.py
  - scripts/phase95-root-mesh-source-worker.py
  - scripts/test-phase95-root-mesh-source-diagnostic.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-MESH-SOURCE-SPEC.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
source_registration_admission: false
portrait_acceptance: false
---

# Mesh source applicability diagnostic review

## Narrative Findings (AI reviewer)

Final version has no unresolved finding for one invocation containing exactly two observations of the already authorized original source. The accompanying `phase95-mesh-source-review-v1` JSON binds the final 26-entry `--review-inputs` snapshot. It permits only this source-only applicability diagnostic under the already established local Vision execution environment; it grants no structural registration, measurement, output-image scoring, or milestone acceptance.

### Resolved CR-01 — BLOCKER: runtime payload checks omitted executable additions and cached bytecode

The initial snapshot checked expected wheel files but did not reject additional `.pth`, `sitecustomize.py`, unlisted modules or bytecode. These could change what Python executes without changing the reported wheel payload identity, despite `-I`.

Final `runtime_extras` (diagnostic lines 30–45) scans the complete site-packages tree, rejects symlinks and unexpected files, and binds the limited known distribution bookkeeping. Only caches associated with already checked source files are tolerated. `predict`/`predict_with_cache` (lines 120–127) use a newly created empty private temporary cache prefix together with `-I -B`; old caches are not used. The directory is removed after process cleanup on success or failure. The added generated test covers extra startup/module files, standalone bytecode, symlink directories, and unknown versus known-source cache entries.

### Resolved WR-01 — WARNING: horizontal mapping mixed image-edge and sample-center coordinates

The initial Y query used `(y+0.5)/H`, whereas horizontal normalized intersections were multiplied by W directly before comparison with integer-indexed profile samples. This introduced a half-sample horizontal offset in the declared coordinate convention and could alter applicability near a search boundary.

Final `profile_coordinate` (lines 166–167), its call at line 201, and the specification use `x*W-0.5`. Generated odd/even and noninteger-scale checks verify center round trips and nearest-center sampling quantization. This repairs coordinate consistency; the one-small-image-pixel padding remains a search choice, not a detector-error bound or anatomical certification.

## Identity, privacy and process checks

The native definition composes the existing hash-bound source adapter and preserves original source/contract identity, canonical opaque pixels, root ROI, 16 original rows and eye-excluded limits. Only its in-memory return payload gains a longest-side-at-most-512 nearest-center RGB sample and row coordinates. The original image used for effect validation is not resized or replaced. No comparator/output dispatcher is executed by this diagnostic.

Worker input is strict bounded JSON/base64 with exact fields, integer dimensions and exact RGB length. The fixed model is checked before use. Worker CPU/IMAGE mode sets `num_faces=2`; zero or multiple detected faces are rejected by the parent, and a sole face must contain exactly 478 finite in-range XY predictions. A network-denial probe precedes third-party imports, and the actual worker invocation supplies deny-network sandboxing and isolated Python. This is detection-count ambiguity handling, not a proof that a detector cannot miss another face.

The source transport retains its existing 180-second/16-MiB bound; the worker uses a 90-second/1-MiB combined-stream bound. Raw worker stderr is drained but not used as protocol. Source profiles, RGB and predicted points remain in the two internal pipes and process memory. Parent output is constructed from fixed count/hash fields and fixed false qualification flags; generic failures emit a fixed redacted reason. Owned process groups are killed/reaped in finalization, and generated tests exercised cleanup on normal, rejected, over-limit and timeout paths.

Snapshot validation covers source dependencies, all final scripts/tests/specification, model, interpreter, configuration, locked 18-wheel inventory, checked installed payload and allowed installation bookkeeping. Existing trusted platform Python/Swift/Vision libraries remain the execution environment; this is not a claim to audit every operating-system file. The reviewed local dependency/license scope is inherited from `95-ROOT-MESH-RUNTIME-PREFLIGHT-REVIEW.md` without granting broader distribution or private-data uses.

## Meaning of coverage

All intersections of the declared open candidate-chain segments are retained, including horizontal-segment endpoints. There is no extrapolation, invented closing edge, output-based selection or polarity-based bilateral filtering. The hull plus search padding defines conditional source-only search bands; out-of-bounds or unsupported bands and fitting/ambiguity budget failures remain unavailable. The visible module preserves its finite support/error assumptions.

The resulting counts say only whether these specific predicted-chain search bands meet the local visible-knot model on the original fixed rows. They do not establish that a knot is a root side rather than texture/occlusion, that the candidate family is anatomically complete, or that a detector error has been bounded. Identical counts across the two observations do not establish identical landmark geometry or registered structure. `source_registered`, `portrait_acceptance` and `acceptance_credit` remain false regardless of coverage. Original full-image Q16 units, 16-Q16 criteria, siblings and protection predicates are unchanged and receive no pass credit here.

## Independent validation performed

- Final five generated protocol/coordinate/runtime tests passed under ordinary Python and `-O`.
- Generated subprocess responses: one positive and 14 invalid face-count/point-inventory/type/range/schema/exit cases; all 15 owned children cleaned, and a simulated sensitive stderr sentinel never escaped.
- Three additional generated faults (combined output overflow, simulated deadline expiry, duplicate JSON keys) rejected and cleaned.
- Mocked review gate: one positive two-observation path and 13 invalid-review/aggregate-drift/snapshot-drift rejections; invalid review blocked observations entirely.
- Final cache wrapper: generated successful and failing child paths each received a distinct empty cache directory with `-I -B -X`; both directories were removed.
- Final `--review-inputs` completed successfully and was checked again before writing the review binding.

No private source was read and no model inference was executed by this reviewer. The orchestrator's earlier native compile-only and generated black-image checks are separate reported evidence, not additional executions claimed here. No historical review or observation was overwritten.

## Primary reviewed hashes

| File | SHA256 |
| --- | --- |
| scripts/phase95-root-mesh-source-diagnostic.py | 6b4a7b010ee04fe1bf846415cbf3d4dc2b028344dff805c5cfe558fa8b974007 |
| scripts/phase95-root-mesh-source-worker.py | aee0bad28fd0463c2d18b4277d66fe77013918d327f749390057eaaad979f0cb |
| scripts/test-phase95-root-mesh-source-diagnostic.py | 12bedc985b51fa432384a852c06fad058acd458d95256f68ece8d8087d48c2f2 |
| 95-ROOT-MESH-SOURCE-SPEC.md | 429a3b38057b41ba563bd29d7b205b99c0b984bd721acd6b254eff2f7175f6d8 |

The accompanying JSON preserves every dependency hash in the final snapshot. Reviewer: independent closeout review agent.
