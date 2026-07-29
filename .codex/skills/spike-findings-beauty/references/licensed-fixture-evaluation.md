# Licensed Fixture Evaluation

## Requirements

- AI-generated and `mechanics_only` fixtures may exercise tools but may not
  contribute product-feasibility evidence.
- Every real fixture needs an opaque fixture ID, positive/negative polarity,
  supported feature, rights status, rights-record ID, and complete
  original/mask/after assets.
- Product evidence opens only when every selected fixture is
  `approved_internal_evaluation`, all assets are present, and the bundle has at
  least one positive and one negative.
- Review stays local and blinded. Persistent export contains structured
  judgments and aggregates, never media, filenames, paths, rights records,
  documentation records, raw geometry, or freeform reviewer text.
- Define feature acceptance criteria before review; do not inspect outcomes and
  then invent the pass rule.

## How to Build It

1. Create a dataset manifest matching
   `sources/006-licensed-fixture-review-gate/fixture-manifest.schema.json`:

```json
{
  "schema_version": 1,
  "dataset": {
    "dataset_id": "opaque_dataset_id",
    "documentation_record_id": "opaque_document_id",
    "intended_use": "internal_product_evaluation",
    "retention_policy": "project-owned retention rule"
  },
  "fixtures": []
}
```

2. For every fixture, allow only `teeth_whitening`, `sclera_redness`, or
   `upper_eyelid_fullness`; `positive` or `negative`; and
   `approved_internal_evaluation`, `mechanics_only`, or `rejected`. Restrict IDs
   to opaque `[A-Za-z0-9_-]{1,64}` values and assets to safe relative paths.
3. Validate both manifest semantics and the browser-selected asset inventory.
   Reject absolute paths, traversal, duplicate IDs, missing assets, unsupported
   enums, missing rights records, and incomplete positive/negative coverage.
4. Keep the product gate explicit:

```javascript
const productEvidenceReady = errors.length === 0
  && counts.fixtures > 0
  && counts.approved === counts.fixtures
  && counts.positive > 0
  && counts.negative > 0
  && hasAssetInventory;
```

5. Use the static browser reviewer with local File API object URLs. Present only
   a blinded item number, feature, and original/mask/after at original detail;
   do not upload or run a local server.
6. Capture structured judgments per fixture: target presence, mask coverage
   1–5, protected leakage, naturalness 1–5, structure change, accept/reject,
   and a fixed reason code.
7. Build export from the manifest plus validated reviews. Retain only opaque
   fixture ID, feature, polarity, judgments, decisions, and aggregate counts by
   feature. Remove asset paths, rights/documentation identifiers, retention
   text, media, and reviewer freeform text.
8. Keep event data in memory until export and allow only timestamps, categories,
   and aggregate gate/review counts.
9. Verify the pure core before each evaluation bundle:

```bash
cd .codex/skills/spike-findings-beauty
node sources/006-licensed-fixture-review-gate/test-review-core.js
open sources/006-licensed-fixture-review-gate/review.html
```

10. For teeth, compare fixed versus adaptive coverage and explicitly score lip,
    tongue, gum, braces, occlusion, and naturalness. For sclera, calibrate guard
    safety/retention across open, partial, blink, gaze, glasses/contacts, iris
    color, pose, and redness. Keep `去脂` gated on genuine positives and
    identity/detail review.

## What to Avoid

- Do not treat a structurally valid `mechanics_only` manifest as product
  evidence; it must remain visibly `GATE CLOSED`.
- Do not accept a bundle with approved positives but no negatives, or vice versa.
- Do not put absolute filesystem paths, personal filenames, subject names, or
  rights/documentation records in review exports.
- Do not persist review media or expose raw masks/landmarks through diagnostics.
- Do not add a server, upload, analytics beacon, or network request to the local
  reviewer without a separate privacy/retention design.
- Do not use freeform notes as the primary acceptance record; use fixed fields
  and reason codes that can be audited and aggregated.
- Do not infer demographic, product, or commercial readiness from fixture count
  alone; document dataset composition and limitations.

## Constraints

- The chosen reviewer is browser-local and single-reviewer; directory selection
  is browser-mediated and there is no shared review backend.
- Spike 006's pure JavaScript core passes 9/9 tests and its runtime contains no
  fetch, XHR, WebSocket, beacon, or network URL.
- The sample manifest is intentionally `mechanics_only`; no rights-approved real
  fixture bundle was supplied, so the evaluation gate is `PARTIAL`.
- The reviewer proves asset/rights/review/export mechanics, not inter-rater
  reliability or statistical sufficiency. Those need an explicit evaluation
  plan once real data ownership exists.

## Origin

Synthesized from spike: 006

Source files available in:
`sources/006-licensed-fixture-review-gate/`.
