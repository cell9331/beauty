---
phase: 75
artifact: genuine-evidence-contract
version: 1
status: frozen
authority: phase-owned-private-evidence-only
---

# Phase 75 Genuine Evidence Contract

This contract freezes the admission and review rules before any candidate
result is used to make a product decision. The bundle is local and private;
the repository stores only this contract, executable checks, and aggregate
evidence schemas. A generated or metadata-only self-test can prove mechanics,
but cannot satisfy genuine efficacy or naturalness.

<!-- CANONICAL_EVIDENCE_RECORDS_BEGIN -->
```json
{
  "version": 1,
  "feature_id": "upper-eyelid-fullness-reduction",
  "manifest_schema": {
    "required_categories": [
      "genuine-positive",
      "genuine-negative",
      "ambiguity",
      "pose-occlusion",
      "identity-diversity",
      "protected-structure"
    ],
    "required_fixture_keys": [
      "feature_id",
      "fixture_id",
      "polarity",
      "rights_status",
      "rights_record_id",
      "owner_provenance_version",
      "content_hash",
      "asset_roles",
      "categories"
    ],
    "rights_status": "approved_internal_evaluation",
    "polarity_values": ["positive", "negative"],
    "asset_roles": ["original", "support-envelope", "candidate-output"]
  },
  "admission": {
    "requires_genuine_positive": true,
    "requires_genuine_negative": true,
    "generated_fixture_weight": 0,
    "metadata_only_self_test_is_mechanics_only": true,
    "missing_bundle_reason": "evidence.missing-bundle",
    "incomplete_reason": "evidence.incomplete-taxonomy"
  },
  "metrics": [
    {"id": "efficacy", "direction": "minimum", "threshold": 0.1, "tolerance": 0.02},
    {"id": "containment", "direction": "maximum", "threshold": 0.0, "tolerance": 0.0},
    {"id": "texture-high-frequency-retention", "direction": "minimum", "threshold": 0.98, "tolerance": 0.02},
    {"id": "geometry-protected-structures", "direction": "maximum", "threshold": 0.01, "tolerance": 0.01},
    {"id": "metadata-integrity", "direction": "exact", "threshold": 1.0, "tolerance": 0.0},
    {"id": "no-op", "direction": "maximum", "threshold": 0.0, "tolerance": 0.0},
    {"id": "deterministic-repeatability", "direction": "exact", "threshold": 1.0, "tolerance": 0.0}
  ],
  "review": {
    "mode": "blinded-original-detail",
    "scale": "binary-pass-fail-plus-fixed-reasons",
    "required_fields": [
      "target-fullness-reduced",
      "prohibited-proxy-absent",
      "protected-structures-preserved",
      "original-detail-natural",
      "review-decision",
      "reason-code"
    ],
    "reason_codes": [
      "target-not-visible",
      "proxy-present",
      "protected-structure-change",
      "detail-unnatural",
      "occlusion-or-pose-ambiguous",
      "review-failure"
    ],
    "reviewer_sees_private_locator": false,
    "reviewer_sees_candidate_identity": false,
    "freeform_text": false
  },
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
      "raw",
      "pixels",
      "outputs",
      "masks",
      "landmarks",
      "private-locator",
      "reviewer-prose",
      "identity-descriptor"
    ]
  },
  "failure_states": [
    "missing-bundle",
    "rights-failure",
    "incomplete-taxonomy",
    "malformed-manifest",
    "review-failure",
    "privacy-export-failure"
  ]
}
```
<!-- CANONICAL_EVIDENCE_RECORDS_END -->

## Admission rules

The private manifest must identify this exact feature, use opaque fixture IDs,
bind each fixture to an approved rights record and owner provenance version,
include a content hash and the three declared asset roles, and cover every
required category. The union of categories must include genuine positive and
negative cases, ambiguity, pose/occlusion stress, identity diversity, and
protected-structure coverage. Fixture IDs, polarity, hashes, rights records,
and categories are exact; duplicates, substitutions, missing bindings,
malformed values, and unapproved rights fail closed.

The evaluator may inspect the caller-supplied local bundle in a child process,
but it must never copy media into the repository or print private locators.
The absence of a complete local bundle is reported as a typed evidence-gate
failure. It is not permission to tune on generated fixtures or to infer the
effect from landmarks, anatomy, pose, texture, or color.

## Frozen measurements

The metric records above are versioned before candidate evaluation. Efficacy is
the genuine positive target score; containment is the maximum exterior or
collision leakage; texture retention is source high-frequency retention;
geometry is protected eye/lash/crease/brow change; metadata is exact contract
preservation; no-op is the maximum change for negative/ambiguous/unsupported
cases; and deterministic repeatability is exact repeated output. Image tests
must use real input/output pixels and metadata where an image candidate exists.
The thresholds are not tunable after results are visible; changing one creates
a new contract version and invalidates prior candidate results.

## Blinded original-detail review

Review is local and blinded. Reviewers receive original-detail views without
candidate identity, private locators, fixture names, or freeform notes. Each
review records only the fixed fields, a fixed reason code, and a binary
decision. A positive case must show less visible fullness with no prohibited
proxy and preserved protected structures/detail. Negative, ambiguous,
occluded, blinking/closed, and extreme-pose cases must remain exact source
identity or within the frozen no-op tolerance.

## Durable output and nonclaims

Only the explicit durable-output allowlist may leave the evaluator: contract
and manifest hashes, opaque fixture IDs, aggregate metric values/counts,
normalized reason counts, and one decision. Raw images, outputs, masks,
landmarks, geometry, pixels, private paths, reviewer prose, identity
descriptors, and device details are never persisted. Aggregate mechanics
output does not claim genuine efficacy, naturalness, device performance,
commercial visual approval, packaging, shipping, launch, or release readiness.

