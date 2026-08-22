# Phase 80: Genuine Evidence and Qualification Gate - Pattern Map

**Mapped:** 2026-08-22
**Files analyzed:** 7 likely new/modified files
**Analogs found:** 7 / 7

Phase 80 has no `RESEARCH.md`; this map derives scope from `80-CONTEXT.md`, the Phase-80 roadmap and requirements, the frozen v1.18 Phase-75/78 artifacts, the current v1.18 decision-binding gate, and `spike-findings-beauty`. Archived v1.18 artifacts are read-only execution authorities: copy their patterns into new Phase-80 owners, but do not modify the archived files.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `.planning/phases/80-genuine-evidence-and-qualification-gate/80-QUALIFICATION-CONTRACT.md` | config / contract | transform | `.planning/milestones/v1.18-phases/75-semantics-and-genuine-evidence-contract/75-EVIDENCE-CONTRACT.md` | exact |
| `.planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.js` | service / gate | file-I/O, request-response, transform | `.planning/milestones/v1.18-phases/78-genuine-evaluation-and-candidate-decision/78-candidate-decision.js` | exact |
| `.planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.test.js` | test | file-I/O, request-response | `.planning/milestones/v1.18-phases/78-genuine-evaluation-and-candidate-decision/78-candidate-decision.test.js` | exact |
| `.planning/phases/80-genuine-evidence-and-qualification-gate/check_phase80_qualification_boundaries.py` | test / validation gate | batch, file-I/O | `scripts/check-v1-18-decision-binding.py` plus archived Phase-78 checker | exact composite |
| `.planning/phases/80-genuine-evidence-and-qualification-gate/80-QUALIFICATION-DECISION.json` | config / generated evidence record | transform | aggregate report returned by archived `78-candidate-decision.js` and `live_result()` in `scripts/check-v1-18-decision-binding.py` | role-match |
| `.planning/phases/80-genuine-evidence-and-qualification-gate/80-VALIDATION.md` | test evidence | batch | archived Phase-78 `78-VALIDATION.md` | exact |
| `.planning/phases/80-genuine-evidence-and-qualification-gate/80-VERIFICATION.md` | test evidence | batch | archived Phase-78 `78-VERIFICATION.md` | exact |

The names above are the minimal inferred ownership split; the planner may merge the contract into the executable gate or emit the decision only to stdout if it preserves a single machine-readable, baseline-bound aggregate authority. It must not invent a second mutable evidence contract.

## Pattern Assignments

### `80-QUALIFICATION-CONTRACT.md` (config/contract, transform)

**Analog:** archived Phase-75 `75-EVIDENCE-CONTRACT.md`

**Versioned canonical-record pattern** (lines 1-17):

```markdown
---
phase: 75
artifact: genuine-evidence-contract
version: 1
status: frozen
authority: phase-owned-private-evidence-only
---

<!-- CANONICAL_EVIDENCE_RECORDS_BEGIN -->
```json
```

Keep machine-parsed JSON between explicit markers and hash its canonical representation. Phase 80 should reference or bind the frozen Phase-75 contract, adding only Phase-80 qualification bindings that are not already owned there (completed structured review, evaluated editor baseline, and final decision schema).

**Admission and frozen metric pattern** (lines 47-84):

```json
"admission": {
  "requires_genuine_positive": true,
  "requires_genuine_negative": true,
  "generated_fixture_weight": 0,
  "metadata_only_self_test_is_mechanics_only": true,
  "missing_bundle_reason": "evidence.missing-bundle",
  "incomplete_reason": "evidence.incomplete-taxonomy"
},
"review": {
  "mode": "blinded-original-detail",
  "scale": "binary-pass-fail-plus-fixed-reasons",
  "freeform_text": false
}
```

Preserve the already frozen category, metric, tolerance, review-field, and fixed-reason vocabulary. Do not tune thresholds after outcomes are visible.

**Durable-output boundary** (lines 86-113):

```json
"durable_output": {
  "allowlist": [
    "contract_hash",
    "manifest_hash",
    "fixture_ids",
    "aggregate_metrics",
    "reason_counts",
    "decision"
  ],
  "deny_keys": [
    "raw", "pixels", "outputs", "masks", "landmarks",
    "private-locator", "reviewer-prose", "identity-descriptor"
  ]
}
```

For Phase 80, extend bindings with opaque hashes/versions rather than rights records, reviewer identity, review prose, local paths, or image-derived geometry.

---

### `80-qualification-decision.js` (service/gate, file-I/O + transform)

**Primary analogs:** archived Phase-75 evaluator and Phase-78 candidate decision.

**Imports and child-process isolation** (Phase-78 lines 1-15 and 98-111):

```javascript
"use strict";

const crypto = require("node:crypto");
const childProcess = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const child = childProcess.spawnSync(process.execPath, args, {
  encoding: "utf8",
  stdio: ["ignore", "pipe", "ignore"],
  timeout: 20_000,
});
```

Use standard-library-only local execution, bounded timeout/output, suppressed child stderr, and parsed JSON handoff. Never echo the caller's bundle locator.

**Fail-closed manifest admission** (Phase-75 evaluator lines 96-168):

```javascript
if (!manifest || typeof manifest !== "object" || Array.isArray(manifest)) {
  return ["evidence.malformed-manifest"];
}
// exact keys, contract version/hash, feature ID, admission mode
// exact opaque fixture IDs, rights status, hashes, asset roles and categories
for (const category of REQUIRED_CATEGORIES) {
  if (!categories.has(category)) errors.push(`evidence.category.${category}`);
}
if (!polarities.has("positive")) errors.push("evidence.missing-positive");
if (!polarities.has("negative")) errors.push("evidence.missing-negative");
return [...new Set(errors)].sort();
```

Phase 80 must additionally require every predeclared stress category and each required local asset, distinguish genuine-private input from mechanics-only input, and preserve deterministic normalized reason codes.

**Privacy-safe serializer** (Phase-75 evaluator lines 171-203):

```javascript
function outputIsSafe(value) {
  const encoded = JSON.stringify(value);
  if (encoded.includes("/") || encoded.includes("\\")) return false;
  const walk = (candidate) => {
    if (Array.isArray(candidate)) return candidate.every(walk);
    if (!candidate || typeof candidate !== "object") {
      return typeof candidate !== "string" || !SENSITIVE.test(candidate);
    }
    return Object.entries(candidate).every(
      ([key, entry]) => !SENSITIVE.test(key) && walk(entry),
    );
  };
  return walk(value);
}
```

Use an exact top-level allowlist as the primary control and recursive sensitive-key/path rejection as defense in depth.

**Decision flow** (Phase-78 lines 211-263):

```javascript
if (!manifestPath) {
  return reportFromFailure(["evidence.missing-bundle"]);
}
const validation = phase75Run("validate", manifestPath);
if (validation.status !== "pass") {
  return reportFromFailure(validation.reasons || ["evidence.malformed-manifest"]);
}
const aggregate = phase75Run("aggregate", manifestPath);
if (aggregate.status !== "pass") {
  return reportFromFailure(aggregate.reasons || ["evidence.privacy-export-failure"]);
}
if (aggregate.aggregate_metrics?.mechanics_only === true) {
  return reportFromFailure(["evidence.metadata-only-mechanics"], { /* aggregate only */ });
}
const evaluationFailures = evaluationErrors(evaluation);
if (evaluationFailures.length) return reportFromFailure(evaluationFailures, { /* aggregate only */ });
```

Phase 80 should remove the optional comparator branch unless explicitly required; v1.19 qualifies the existing deterministic editor. A pass must require genuine admission, all frozen pixel/metadata metrics, category-complete blinded review, and current baseline binding. Any absent/invalid input yields a non-promotion decision while retaining exact public 61/5/74.

---

### `80-qualification-decision.test.js` (test, file-I/O + request-response)

**Analog:** archived Phase-78 candidate tests.

**Test setup pattern** (lines 1-32):

```javascript
const assert = require("node:assert/strict");
const test = require("node:test");
const childProcess = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const root = fs.mkdtempSync(path.join(os.tmpdir(), "beauty-phase80-test-"));
// write temporary inputs mode 0o600; always remove them in finally
```

**Independent fail-closed assertions** (Phase-78 tests lines 35-75):

```javascript
test("missing bundle is typed and cannot promote", () => {
  const result = gate.decide();
  assert.equal(result.reason_counts["evidence.missing-bundle"], 1);
  assert.equal(result.aggregate_metrics.genuine_evaluation_executed, false);
});

test("metadata-only evidence remains mechanics-only", () => {
  const first = gate.decide({ manifestPath: fixture.file });
  const second = gate.decide({ manifestPath: fixture.file });
  assert.deepEqual(first, second);
  assert.equal(gate.outputIsSafe(first), true);
});
```

Add one test per EVID-03..05 and QUAL-03..05 dimension: missing asset, missing positive/negative/stress category, generated/mechanics-only substitution, rights failure, rubric/hash mutation, incomplete blinded review, each metric false/out of bound, category acceptance failure, baseline digest mismatch, sensitive key/value injection, repeat determinism, and a fully shaped sanitized passing fixture. All test inputs remain temporary metadata; tests must not manufacture genuine evidence or assert that mechanics fixtures qualify.

---

### `check_phase80_qualification_boundaries.py` (test/gate, batch + file-I/O)

**Analogs:** current `scripts/check-v1-18-decision-binding.py` and archived Phase-78 boundary checker.

**Imports and normalized privacy vocabulary** (`scripts/check-v1-18-decision-binding.py` lines 8-37):

```python
import argparse
import copy
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path

HASH_RE = re.compile(r"^[0-9a-f]{64}$")
OPAQUE_ID_RE = re.compile(r"^[A-Za-z0-9_-]{1,64}$")
REASON_RE = re.compile(r"^[a-z][a-z0-9.-]{0,127}$")
SENSITIVE_KEY_RE = re.compile(
    r"(?:path|locator|pixel|mask|landmark|coordinate|geometry|raw|private|"
    r"biometric|descriptor|prose|output)", re.IGNORECASE,
)
```

**Baseline owner binding** (lines 211-263):

```python
def aggregate_owner_digest(root: Path, owners: tuple[Path, ...], *, overrides=None) -> str:
    if not owners or tuple(sorted(owners, key=lambda value: value.as_posix())) != owners:
        fail("baseline.owner-allowlist")
    digest = hashlib.sha256()
    for owner in owners:
        candidate = root / owner
        if candidate.is_symlink() or not candidate.is_file():
            fail("baseline.owner-missing")
        contents = candidate.read_bytes()
        encoded_owner = owner.as_posix().encode("utf-8")
        digest.update(len(encoded_owner).to_bytes(4, "big"))
        digest.update(encoded_owner)
        digest.update(len(contents).to_bytes(8, "big"))
        digest.update(contents)
    return digest.hexdigest()
```

Bind the Phase-80 decision to the exact v1.18 source owners and focused evidence owners. Recompute the current digests; do not blindly copy historical digest constants if owner bytes have changed.

**Focused test attestation and canonical binding** (lines 266-372):

```python
if returncode != 0:
    fail("baseline.focused-tests-failed")
if not raw or len(raw.encode("utf-8")) > MAX_FOCUSED_OUTPUT_BYTES:
    fail("baseline.focused-tests-output")
if started_ids != expected_ids or passed_ids != expected_ids:
    fail("baseline.focused-tests-identity")

record = {
    "baseline_disposition": BASELINE_DISPOSITION,
    "baseline_id": BASELINE_ID,
    "contract_hash": contract_hash,
    "decision": report["decision"],
    "evidence_digest": evidence_digest,
    **attestation,
    "source_digest": source_digest,
}
canonical = json.dumps(record, sort_keys=True, separators=(",", ":"))
return hashlib.sha256(canonical.encode("utf-8")).hexdigest()
```

Phase 80's binding record must also cover evaluator version and sanitized blinded-review/evaluation hashes or aggregate attestations. It must never contain fixture locators, rights records, reviewer identity, or freeform responses.

**Mutation table pattern** (archived Phase-78 checker lines 208-231):

```python
mutations = [
    ("T-80-01", "evidence.missing-bundle", "evidence.bundle-present", "evidence.missing-bundle"),
    # one isolated mutation per admission, review, metric, privacy, baseline and public-absence guard
]
for threat, old, new, expected in mutations:
    mutated = source.replace(old, new)
    if mutated == source:
        errors.append(f"{threat}.mutation-not-applied")
    elif expected in script_errors(mutated):
        rejected += 1
    else:
        errors.append(f"{threat}.mutation-accepted")
```

Include live checks for archived-authority resolution, exact decision schema, exact 61 fields / 5 presets / 74 renderer cases before pass, no production/public edits in this phase, and isolated bypass mutations.

---

### `80-QUALIFICATION-DECISION.json` (generated evidence record, transform)

**Analogs:** Phase-78 report shape (lines 173-204) and current binding gate live result (lines 601-635).

```javascript
return {
  status,
  phase: PHASE,
  contract_hash: contractHash(),
  manifest_hash: manifestHash,
  fixture_ids: fixtureIds.slice().sort(),
  aggregate_metrics: { /* fixed aggregate fields only */ },
  reason_counts: reasonCounts(normalizedReasons),
  decision,
};
```

```python
return {
    "baseline_binding_hash": binding_hash,
    "baseline_evidence_digest": evidence_digest,
    "baseline_id": BASELINE_ID,
    "baseline_source_digest": source_digest,
    "contract_hash": contract_hash,
    "decision": report["decision"],
    "fields": 61,
    "presets": 5,
    "renderer_cases": 74,
    "status": "pass",
}
```

Use canonical sorted JSON, a closed exact schema, hashes/versions, aggregate counts/metrics, normalized reason counts, and exactly one decision. A missing bundle or review is a valid machine decision but never a passing promotion decision.

---

### `80-VALIDATION.md` and `80-VERIFICATION.md` (test evidence, batch)

**Analogs:** archived Phase-78 validation/verification records.

Copy their evidence structure: requirement/must-have table, exact commands, observed counts, mutation rejection totals, exact public inventory, and explicit nonclaims. Record only aggregate outputs and normalized reasons. If external genuine inputs are missing or invalid, mark EVID/QUAL requirements unsatisfied and Phase 81 blocked by the gate; do not convert successful self-tests into product-evidence completion.

## Shared Patterns

### Frozen authority and baseline binding

**Sources:** archived Phase-75 contract; `scripts/check-v1-18-decision-binding.py` lines 336-372.

Apply to the contract, decision service, checker, and durable report. Bind contract hash + evaluator version + deterministic-editor source digest + focused-test evidence digest + sanitized evaluation/review result. Any mismatch fails closed.

### Local-only external input

**Source:** `spike-findings-beauty/references/licensed-fixture-evaluation.md` lines 41-66.

Validate manifest semantics and asset inventory locally, use blinded original-detail review, keep event/review state in memory until export, and export structured judgments/aggregates only. No server, upload, analytics, or repository copy is part of this phase.

### Error handling

**Source:** archived Phase-75 evaluator lines 92-94 and 292-315.

```javascript
function errorResult(mode, reason) {
  return { status: "fail", mode, reasons: [reason], reason_count: 1 };
}
```

Expected gate failures produce stable typed results and nonzero process exit. Catch parse/I/O/subprocess failures and map them to normalized reasons without including exception text that may contain a path.

### Exact public absence

**Source:** archived Phase-78 checker lines 63-98.

Count `BeautyParameters` declarations and coding keys, assert the five preset IDs and 74 unique renderer cases, and scan production/package/resource owners for the prohibited Phase-81 identity. Phase 80 must not modify `BeautySDK`, package resources, public/SPI routes, presets, or renderer cases.

### Test hygiene

Use `node:test`, `node:assert/strict`, temporary directories, mode `0o600`, `try/finally` cleanup, byte-identical repeated output assertions, one mutation per guard, syntax checks, `git diff --check`, and the SDK-owned archive-first gate. Persist only counts/statuses, never child transcripts or private inputs.

## No Analog Found

None. Every likely Phase-80 owner has a strong v1.18 analog. The new semantic distinction is not structural but evidentiary: Phase 80 may emit a promotion pass only from actual complete authorized external inputs and frozen review/metric results, whereas archived self-tests remain mechanics-only.

## Files Explicitly Out of Scope

- Any file under `.planning/milestones/v1.18-phases/` (immutable archive).
- `BeautySDK/Sources/**`, `BeautySDK/Tests/**`, `BeautySDK/Package.swift`, resources, public/SPI routes, and the renderer.
- `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, root owner docs, and `PLANS.md` during the Phase-80 implementation tasks unless a later closeout plan explicitly authorizes ledger synchronization.
- Any tracked private manifest, media, masks, landmarks, pixels, rights record, reviewer identity, freeform review content, or private fixture locator.

## Metadata

**Analog search scope:** `.planning/milestones/v1.18-phases/{75,78}-*`, `scripts/check-v1-18-decision-binding.py`, `BeautySDK` baseline owner/test references, `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
**Strong analogs read:** 7
**Pattern extraction date:** 2026-08-22
**Privacy note:** excerpts intentionally omit private fixture data and contain only contract vocabulary, source-owner paths, normalized reasons, and aggregate schemas.
