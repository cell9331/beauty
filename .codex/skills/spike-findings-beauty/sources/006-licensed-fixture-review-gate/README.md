---
spike: 006
name: licensed-fixture-review-gate
type: standard
validates: "Given licensed positive/negative fixtures with rights metadata, when a local blinded reviewer consumes before/mask/after assets, then coverage, protected leakage, and naturalness judgments export without media, paths, or sensitive geometry."
verdict: PARTIAL
related: [002a, 002b, 003, 004, 005]
tags: [evaluation, fixtures, privacy, licensing]
---

# Spike 006: Licensed Fixture Review Gate

## What This Validates

Tests whether future real portrait fixtures can cross an explicit rights and
asset-integrity gate before contributing product evidence, then be reviewed
locally with a sanitized, non-media export. It also proves that existing
`mechanics_only` AI fixtures cannot accidentally open the product gate.

## Research

- [Datasheets for Datasets](https://arxiv.org/abs/1803.09010) argues for
  standardized documentation of why and how a dataset was created and used.
- [Model Cards for Model Reporting](https://research.google/pubs/model-cards-for-model-reporting/)
  separates intended use, evaluation conditions, subgroup performance, and
  limitations rather than reducing evidence to one aggregate number.
- [NIST AI RMF Measure](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/)
  calls for repeatable test/evaluation processes, benchmark comparisons,
  uncertainty, and formalized reporting.
- The [W3C File API](https://www.w3.org/TR/FileAPI/) supports local `File` and
  `Blob` access plus document-scoped object URLs, allowing an offline reviewer
  without a server or upload.

| Approach | Pros | Cons | Status |
| --- | --- | --- | --- |
| Browser-only File API | No server, upload, dependency, or persisted media; easy visual review | Directory selection is browser-mediated; no shared multi-reviewer backend | **Chosen** |
| Local HTTP review server | Easier asset routing and team sessions | Adds a service, ports, retention, and a larger privacy boundary | Rejected for this gate |
| Native macOS reviewer | Strong filesystem integration | Higher build cost and not needed to answer the gate question | Deferred |

**Chosen approach:** one static local page plus a pure JavaScript validation and
export core. The UI can review valid mechanics fixtures while visibly keeping
the product gate closed; only fully approved positive and negative fixtures
with all selected assets can open it.

## How to Run

```bash
node .planning/spikes/006-licensed-fixture-review-gate/test-review-core.js
open .planning/spikes/006-licensed-fixture-review-gate/review.html
```

Load `sample-mechanics-manifest.json`, then choose a directory containing the
three relative assets for every fixture. Use
`fixture-manifest.schema.json` when creating a real evaluation bundle.

## What to Expect

- The sample manifest is structurally valid but displays `GATE CLOSED` because
  its rights state is `mechanics_only`.
- Absolute/traversal paths, duplicate IDs, missing assets, missing rights
  records, absent positives, and absent negatives prevent product evidence.
- Review cards show only a blinded item number, feature, and before/mask/after.
- Export contains opaque fixture IDs, ratings, decisions, reason codes, and
  aggregate event/count data; it excludes filenames, asset paths, rights record
  IDs, documentation records, and media.

## Observability

The page keeps an in-memory event list with timestamps and aggregate metadata
for manifest load, asset load, gate checks, completed reviews, and export. It
does not log file paths, filenames, pixels, masks, landmarks, or reviewer text.

## Investigation Trail

1. Defined a manifest with dataset documentation, retention policy, opaque
   fixture/rights IDs, polarity, feature, rights status, and safe relative asset
   paths.
2. Made the product gate require all fixtures to be
   `approved_internal_evaluation`, selected assets to be complete, and both
   positive and negative examples to exist.
3. Allowed structurally valid `mechanics_only` fixtures into the visual tool but
   kept their product-evidence gate closed, preventing test mechanics from
   becoming a product claim.
4. Added structured coverage, leakage, naturalness, structure-change, decision,
   and reason-code judgments. Freeform notes were intentionally omitted from
   the persistent export.
5. Added pure-core tests for gate separation, approved assets, unsafe paths,
   duplicate IDs, complete export, and removal of paths/rights/documentation.

## Results

**Verdict: PARTIAL — the offline evidence gate works; product evidence is absent.**

The pure core passes 9/9 checks. JavaScript syntax and both JSON documents
parse, and a static scan finds no `fetch`, XHR, WebSocket, beacon, or network
URL in the runtime. The gate successfully distinguishes valid mechanics data
from rights-approved positive/negative evidence and produces a sanitized review
export.

No licensed real portrait fixtures were supplied, so this spike cannot validate
white-teeth, sclera-redness, or upper-eyelid product feasibility. It establishes
the required handoff and a concrete checkpoint for those inputs.
